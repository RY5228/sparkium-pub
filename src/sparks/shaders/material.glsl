
struct Material {
  vec3 diffuse;
  int diffuse_texture_id;

  vec3 specular;
  int specular_texture_id;

  vec3 emission;
  int emission_texture_id;

  vec3 transmittance;
  float ior;

  vec3 albedo_color;
  int albedo_texture_id;

  vec3 scatterDistance;
  int scatterDistance_texture_id;

  float metallic;
  int metallic_texture_id;
  float roughness;
  int roughness_texture_id;

  float specularTint;
  int specularTint_texture_id;
  float sheen;
  int sheen_texture_id;

  float sheenTint;
  int sheenTint_texture_id;
  float clearcoat;
  int clearcoat_texture_id;

  float clearcoatGloss;
  int clearcoatGloss_texture_id;
  float anisotropy;
  int anisotropy_texture_id;

  float anisotropyRotation;
  int anisotropyRotation_texture_id;
  float specTrans;
  int specTrans_texture_id;

  float opacity;
  int opacity_texture_id;
  float flatness;
  int flatness_texture_id;

  float diffTrans;
  int diffTrans_texture_id;
  float bump;
  int bump_texture_id;
  
  bool thin;
  int normal_texture_id;
  float emission_strength;
  uint material_type;

  uint BxDFType;
};

#define MATERIAL_TYPE_LAMBERTIAN 0
#define MATERIAL_TYPE_SPECULAR 1
#define MATERIAL_TYPE_TRANSMISSIVE 2
#define MATERIAL_TYPE_PRINCIPLED 3
#define MATERIAL_TYPE_EMISSION 4

#define BSDF_REFLECTION (1 << 0)
#define BSDF_TRANSMISSION (1 << 1)
#define BSDF_DIFFUSE (1 << 2)
#define BSDF_GLOSSY (1 << 3)
#define BSDF_SPECULAR (1 << 4)
#define BSDF_ALL (BSDF_DIFFUSE | BSDF_GLOSSY | BSDF_SPECULAR | BSDF_REFLECTION | BSDF_TRANSMISSION)
