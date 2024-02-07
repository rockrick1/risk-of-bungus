shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
group_uniforms albedo;
uniform vec4 albedo : source_color = vec4(1.0);
uniform sampler2D texture_albedo : source_color,filter_linear_mipmap,repeat_enable;
group_uniforms metallic;
uniform float metallic : hint_range(0.0, 1.0, 0.01) = 0;
uniform sampler2D texture_metallic : hint_default_white,filter_linear_mipmap,repeat_enable;
uniform float specular : hint_range(0.0, 1.0, 0.01) = 0.5;
group_uniforms roughness;
uniform float roughness : hint_range(0,1) = 0.5;
uniform sampler2D texture_roughness : hint_roughness_r,filter_linear_mipmap,repeat_enable;
group_uniforms ambient_occlusion;
uniform sampler2D texture_ao : hint_default_white,filter_linear_mipmap,repeat_enable;
uniform float ao_effect : hint_range(0.0, 1.0, 0.1) = 0.0;
group_uniforms normal_map;
uniform sampler2D texture_normal : hint_roughness_normal,filter_linear_mipmap,repeat_enable;
uniform float normal_scale : hint_range(-16,16) = 1;
group_uniforms height;
uniform sampler2D texture_heightmap : hint_default_black,filter_linear_mipmap,repeat_enable;
uniform float heightmap_scale = 5;
uniform int heightmap_min_layers : hint_range(8, 64, 1) = 8;
uniform int heightmap_max_layers : hint_range(8, 64, 1) = 32;
uniform int shadow_min_layers : hint_range(8, 64, 1) = 8;
uniform int shadow_max_layers : hint_range(8, 64, 1) = 32;
uniform vec2 heightmap_flip= vec2(1.0);
uniform bool use_self_shadow = true;
group_uniforms uv;
uniform vec2 uv1_scale = vec2(1.0);
uniform vec2 uv1_offset = vec2(0);

varying vec2 base_uv;
varying mat3 tbn;

void vertex() {
	UV=UV*uv1_scale+uv1_offset;
}

float D_GGX(float cos_theta_m, float alpha) {
	float a = cos_theta_m * alpha;
	float k = alpha / (1.0 - cos_theta_m * cos_theta_m + a * a);
	return k * k * (1.0 / PI);
}

// From Earl Hammon, Jr. "PBR Diffuse Lighting for GGX+Smith Microsurfaces" https://www.gdcvault.com/play/1024478/PBR-Diffuse-Lighting-for-GGX
float V_GGX(float NdotL, float NdotV, float alpha) {
	return 0.5 / mix(2.0 * NdotL * NdotV, NdotL + NdotV, alpha);
}

float SchlickFresnel(float u) {
	float m = 1.0 - u;
	float m2 = m * m;
	return m2 * m2 * m; // pow(m,5)
}

vec3 F0(float mt, float spc, vec3 cl) {
	float dielectric = 0.16 * spc * spc;
	// use albedo * metallic as colored specular reflectance at 0 angle for metallic materials;
	// see https://google.github.io/filament/Filament.md.html
	return mix(vec3(dielectric), cl.rgb, vec3(mt));
}

// From https://stackoverflow.com/questions/55089830/adding-shadows-to-parallax-occlusion-map
float GetParallaxShadow(vec2 texCoord, vec3 lightDir)
{
    if ( lightDir.z >= 0.0 )
        return 0.0;

    float numLayers = mix(float(shadow_max_layers), float(shadow_min_layers), abs(dot(vec3(0.0, 0.0, 1.0), lightDir)));

    vec2 currentTexCoords = texCoord;
    float currentDepthMapValue = 1.0 - texture(texture_heightmap, currentTexCoords).r;
    float currentLayerDepth = currentDepthMapValue;

    float layerDepth = 1.0 / numLayers;
    vec2 P = lightDir.xy / lightDir.z * heightmap_scale * 0.01;
    vec2 deltaTexCoords = P / numLayers;

    while (currentLayerDepth <= currentDepthMapValue && currentLayerDepth > 0.0)
    {
        currentTexCoords += deltaTexCoords;
        currentDepthMapValue = 1.0 - texture(texture_heightmap, currentTexCoords).r;
        currentLayerDepth -= layerDepth;
    }

    float r = currentLayerDepth > currentDepthMapValue ? 0.0 : 1.0;
    return r;
}

void fragment() {
	base_uv = UV;
	{
		vec3 view_dir = normalize(normalize(-VERTEX + EYE_OFFSET) * mat3(TANGENT * heightmap_flip.x, -BINORMAL * heightmap_flip.y, NORMAL));
		float num_layers = mix(float(heightmap_max_layers),float(heightmap_min_layers), abs(dot(vec3(0.0, 0.0, 1.0), view_dir)));
		float layer_depth = 1.0 / num_layers;
		vec2 P = view_dir.xy / view_dir.z * heightmap_scale * 0.01;
		vec2 delta = P / num_layers;
		vec2 ofs = base_uv;
		float depth = 1.0 - texture(texture_heightmap, ofs).r;
		float current_depth = 0.0;
		while(current_depth < depth) {
			ofs -= delta;
			depth = 1.0 - texture(texture_heightmap, ofs).r;
			current_depth += layer_depth;
		}
		vec2 prev_ofs = ofs + delta;
		float after_depth  = depth - current_depth;
		float before_depth = ( 1.0 - texture(texture_heightmap, prev_ofs).r  ) - current_depth + layer_depth;
		float weight = after_depth / (after_depth - before_depth);
		ofs = mix(ofs,prev_ofs,weight);
		base_uv=ofs;
	}
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	float metallic_tex = texture(texture_metallic,base_uv).r;
	METALLIC = metallic_tex * metallic;
	vec4 roughness_texture_channel = vec4(1.0,0.0,0.0,0.0);
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
	AO = texture(texture_ao, base_uv).r;
	AO_LIGHT_AFFECT = ao_effect;
	NORMAL_MAP = texture(texture_normal,base_uv).rgb;
	NORMAL_MAP_DEPTH = normal_scale;
	tbn = mat3(TANGENT, -BINORMAL, NORMAL);
}

void light(){
	vec3 L = normalize(LIGHT);
	vec3 N = normalize(NORMAL);
	vec3 V = normalize(VIEW);
	vec3 light_dir = -L * tbn;
	float NdotL = min(dot(N, L), 1.0);
	float cNdotL = max(NdotL, 0.0);
	float NdotV = dot(N, V);
	float cNdotV = max(NdotV, 1e-4);
	vec3 H = normalize(V + L);
	float cLdotH = clamp(dot(L, H), 0.0, 1.0);
	float cNdotH = clamp(dot(N, H), 0.0, 1.0);
	float cLdotH5 = SchlickFresnel(cLdotH);
	float shadow = GetParallaxShadow(base_uv, light_dir);
	float diffuse_brdf_NL = cNdotL * (1.0 / PI); //built-in Godot lambert diffuse solution
	float D = D_GGX(cNdotH, ROUGHNESS);
	float G = V_GGX(cNdotL, cNdotV, ROUGHNESS);
	vec3 f0 = F0(METALLIC, specular, ALBEDO);
	float f90 = clamp(dot(f0, vec3(50.0 * 0.33)), METALLIC, 1.0);
	vec3 F = f0 + (f90 - f0) * cLdotH5;
	vec3 specular_brdf_NL = cNdotL * D * F * G; //built-in Godot specular SchlickGGX solution
	
	if(use_self_shadow)
		DIFFUSE_LIGHT += diffuse_brdf_NL * shadow * LIGHT_COLOR * ATTENUATION;
	else
		DIFFUSE_LIGHT += diffuse_brdf_NL * LIGHT_COLOR;
	SPECULAR_LIGHT += specular_brdf_NL * LIGHT_COLOR * SPECULAR_AMOUNT * ATTENUATION;
}