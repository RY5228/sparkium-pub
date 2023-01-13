#pragma once
#include "cstdint"
#include "glm/glm.hpp"
#include "sparks/assets/util.h"

namespace sparks {

enum MaterialType : uint32_t {
  MATERIAL_TYPE_LAMBERTIAN = 0,
  MATERIAL_TYPE_SPECULAR = 1,
  MATERIAL_TYPE_TRANSMISSIVE = 2,
  MATERIAL_TYPE_PRINCIPLED = 3,
  MATERIAL_TYPE_EMISSION = 4
};

enum BxDFType : uint32_t {
    BSDF_REFLECTION = 1 << 0,
    BSDF_TRANSMISSION = 1 << 1,
    BSDF_DIFFUSE = 1 << 2,
    BSDF_GLOSSY = 1 << 3,
    BSDF_SPECULAR = 1 << 4,
    BSDF_ALL = BSDF_DIFFUSE | BSDF_GLOSSY | BSDF_SPECULAR | BSDF_REFLECTION | BSDF_TRANSMISSION,
};

class Scene;

struct Material {
  glm::vec3 diffuse{1.0f};
  int diffuse_texture_id{0};

  glm::vec3 specular{0.0f};
  int specular_texture_id{0};

  glm::vec3 emission{0.0f};
  int emission_texture_id{0};

  glm::vec3 transmittance{0.0f};
  float ior{1.5f};

  glm::vec3 albedo_color{0.8f};
  int albedo_texture_id{0};

  glm::vec3 scatterDistance{0.0f};
  int scatterDistance_texture_id{0};

  float metallic{0.0f};
  int metallic_texture_id{0};
  float roughness{0.5f};
  int roughness_texture_id{0};

  float specularTint{0.0f};
  int specularTint_texture_id{0};
  float sheen{0.0f};
  int sheen_texture_id{0};

  float sheenTint{0.0f};
  int sheenTint_texture_id{0};
  float clearcoat{0.0f};
  int clearcoat_texture_id{0};

  float clearcoatGloss{0.0f};
  int clearcoatGloss_texture_id{0};
  float anisotropy{0.0f};
  int anisotropy_texture_id{0};

  float anisotropyRotation{0.0f};
  int anisotropyRotation_texture_id{0};
  float specTrans{0.0f};
  int specTrans_texture_id{0};

  float opacity{1.0f};
  int opacity_texture_id{0};
  float flatness{0.0f};
  int flatness_texture_id{0};

  float diffTrans{0.0f};
  int diffTrans_texture_id{0};
  float bump{0.0f};
  int bump_texture_id{0};
  
  bool thin{false};
  int normal_texture_id{0};
  float emission_strength{1.0f};
  MaterialType material_type{MATERIAL_TYPE_LAMBERTIAN};

  BxDFType bsdf_type{0};
  int reserve[3];

  Material() = default;
  explicit Material(const glm::vec3 &albedo);
  Material(Scene *scene, const tinyxml2::XMLElement *material_element);
};
}  // namespace sparks
