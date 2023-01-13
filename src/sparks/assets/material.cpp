#include "sparks/assets/material.h"

#include "grassland/grassland.h"
#include "sparks/assets/scene.h"
#include "sparks/assets/texture.h"
#include "sparks/util/util.h"

namespace sparks {

namespace {
std::unordered_map<std::string, MaterialType> material_name_map{
    {"lambertian", MATERIAL_TYPE_LAMBERTIAN},
    {"specular", MATERIAL_TYPE_SPECULAR},
    {"transmissive", MATERIAL_TYPE_TRANSMISSIVE},
    {"principled", MATERIAL_TYPE_PRINCIPLED},
    {"emission", MATERIAL_TYPE_EMISSION}};
}

Material::Material(Scene *scene, const tinyxml2::XMLElement *material_element)
    : Material() {
  if (!material_element) {
    return;
  }

  // diffuse = glm::vec3{1.0f};

  auto child_element = material_element->FirstChildElement("diffuse");
  if (child_element) {
    diffuse = StringToVec3(child_element->FindAttribute("value")->Value());
  }

  child_element = material_element->FirstChildElement("diffuse_texture");
  if (child_element) {
    std::string path = child_element->FindAttribute("value")->Value();
    Texture diffuse_texture(1, 1);
    if (Texture::Load(path, diffuse_texture)) {
      diffuse_texture_id =
          scene->AddTexture(diffuse_texture, PathToFilename(path));
    }
  }
  
  child_element = material_element->FirstChildElement("specular");
  if (child_element) {
    specular = StringToVec3(child_element->FindAttribute("value")->Value());
  }
  child_element = material_element->FirstChildElement("specular_texture");
  if (child_element) {
    std::string path = child_element->FindAttribute("value")->Value();
    Texture specular_texture(1, 1);
    if (Texture::Load(path, specular_texture)) {
      specular_texture_id =
          scene->AddTexture(specular_texture, PathToFilename(path));
    }
  }

  child_element = material_element->FirstChildElement("emission");
  if (child_element) {
    emission = StringToVec3(child_element->FindAttribute("value")->Value());
  }

  child_element = material_element->FirstChildElement("emission_texture");
  if (child_element) {
    std::string path = child_element->FindAttribute("value")->Value();
    Texture emission_texture(1, 1);
    if (Texture::Load(path, emission_texture)) {
      emission_texture_id =
          scene->AddTexture(emission_texture, PathToFilename(path));
    }
  }
  
  child_element = material_element->FirstChildElement("transmittance");
  if (child_element) {
    transmittance = StringToVec3(child_element->FindAttribute("value")->Value());
  }

  child_element = material_element->FirstChildElement("ior");
  if (child_element) {
    ior = std::stof(child_element->FindAttribute("value")->Value());
  }

  child_element = material_element->FirstChildElement("albedo");
  if (child_element) {
    albedo_color = StringToVec3(child_element->FindAttribute("value")->Value());
  }

  child_element = material_element->FirstChildElement("albedo_texture");
  if (child_element) {
    std::string path = child_element->FindAttribute("value")->Value();
    Texture albedo_texture(1, 1);
    if (Texture::Load(path, albedo_texture)) {
      albedo_texture_id =
          scene->AddTexture(albedo_texture, PathToFilename(path));
    }
  }

  child_element = material_element->FirstChildElement("scatterDistance");
  if (child_element) {
    scatterDistance = StringToVec3(child_element->FindAttribute("value")->Value());
  }

  child_element = material_element->FirstChildElement("scatterDistance_texture");
  if (child_element) {
    std::string path = child_element->FindAttribute("value")->Value();
    Texture scatterDistance_texture(1, 1);
    if (Texture::Load(path, scatterDistance_texture)) {
      scatterDistance_texture_id =
          scene->AddTexture(scatterDistance_texture, PathToFilename(path));
    }
  }

  child_element = material_element->FirstChildElement("metallic");
  if (child_element) {
    metallic = std::stof(child_element->FindAttribute("value")->Value());
  }

  child_element = material_element->FirstChildElement("metallic_texture");
  if (child_element) {
    std::string path = child_element->FindAttribute("value")->Value();
    Texture metallic_texture(1, 1);
    if (Texture::Load(path, metallic_texture)) {
      metallic_texture_id =
          scene->AddTexture(metallic_texture, PathToFilename(path));
    }
  }

  child_element = material_element->FirstChildElement("roughness");
  if (child_element) {
    roughness = std::stof(child_element->FindAttribute("value")->Value());
  }

  child_element = material_element->FirstChildElement("roughness_texture");
  if (child_element) {
    std::string path = child_element->FindAttribute("value")->Value();
    Texture roughness_texture(1, 1);
    if (Texture::Load(path, roughness_texture)) {
      roughness_texture_id =
          scene->AddTexture(roughness_texture, PathToFilename(path));
    }
  }

  child_element = material_element->FirstChildElement("specularTint");
  if (child_element) {
    specularTint = std::stof(child_element->FindAttribute("value")->Value());
  }

  child_element = material_element->FirstChildElement("specularTint_texture");
  if (child_element) {
    std::string path = child_element->FindAttribute("value")->Value();
    Texture specularTint_texture(1, 1);
    if (Texture::Load(path, specularTint_texture)) {
      specularTint_texture_id =
          scene->AddTexture(specularTint_texture, PathToFilename(path));
    }
  }

  child_element = material_element->FirstChildElement("sheen");
  if (child_element) {
    sheen = std::stof(child_element->FindAttribute("value")->Value());
  }

  child_element = material_element->FirstChildElement("sheen_texture");
  if (child_element) {
    std::string path = child_element->FindAttribute("value")->Value();
    Texture sheen_texture(1, 1);
    if (Texture::Load(path, sheen_texture)) {
      sheen_texture_id =
          scene->AddTexture(sheen_texture, PathToFilename(path));
    }
  }

  child_element = material_element->FirstChildElement("sheenTint");
  if (child_element) {
    sheenTint = std::stof(child_element->FindAttribute("value")->Value());
  }

  child_element = material_element->FirstChildElement("sheenTint_texture");
  if (child_element) {
    std::string path = child_element->FindAttribute("value")->Value();
    Texture sheenTint_texture(1, 1);
    if (Texture::Load(path, sheenTint_texture)) {
      sheenTint_texture_id =
          scene->AddTexture(sheenTint_texture, PathToFilename(path));
    }
  }

  child_element = material_element->FirstChildElement("clearcoat");
  if (child_element) {
    clearcoat = std::stof(child_element->FindAttribute("value")->Value());
  }

  child_element = material_element->FirstChildElement("clearcoat_texture");
  if (child_element) {
    std::string path = child_element->FindAttribute("value")->Value();
    Texture clearcoat_texture(1, 1);
    if (Texture::Load(path, clearcoat_texture)) {
      clearcoat_texture_id =
          scene->AddTexture(clearcoat_texture, PathToFilename(path));
    }
  }

  child_element = material_element->FirstChildElement("clearcoatGloss");
  if (child_element) {
    clearcoatGloss = std::stof(child_element->FindAttribute("value")->Value());
  }

  child_element = material_element->FirstChildElement("clearcoatGloss_texture");
  if (child_element) {
    std::string path = child_element->FindAttribute("value")->Value();
    Texture clearcoatGloss_texture(1, 1);
    if (Texture::Load(path, clearcoatGloss_texture)) {
      clearcoatGloss_texture_id =
          scene->AddTexture(clearcoatGloss_texture, PathToFilename(path));
    }
  }

  child_element = material_element->FirstChildElement("anisotropy");
  if (child_element) {
    anisotropy = std::stof(child_element->FindAttribute("value")->Value());
  }

  child_element = material_element->FirstChildElement("anisotropy_texture");
  if (child_element) {
    std::string path = child_element->FindAttribute("value")->Value();
    Texture anisotropy_texture(1, 1);
    if (Texture::Load(path, anisotropy_texture)) {
      anisotropy_texture_id =
          scene->AddTexture(anisotropy_texture, PathToFilename(path));
    }
  }

  child_element = material_element->FirstChildElement("anisotropyRotation");
  if (child_element) {
    anisotropyRotation = std::stof(child_element->FindAttribute("value")->Value());
  }

  child_element = material_element->FirstChildElement("anisotropyRotation_texture");
  if (child_element) {
    std::string path = child_element->FindAttribute("value")->Value();
    Texture anisotropyRotation_texture(1, 1);
    if (Texture::Load(path, anisotropyRotation_texture)) {
      anisotropyRotation_texture_id =
          scene->AddTexture(anisotropyRotation_texture, PathToFilename(path));
    }
  }

  child_element = material_element->FirstChildElement("specTrans");
  if (child_element) {
    specTrans = std::stof(child_element->FindAttribute("value")->Value());
  }

  child_element = material_element->FirstChildElement("specTrans_texture");
  if (child_element) {
    std::string path = child_element->FindAttribute("value")->Value();
    Texture specTrans_texture(1, 1);
    if (Texture::Load(path, specTrans_texture)) {
      specTrans_texture_id =
          scene->AddTexture(specTrans_texture, PathToFilename(path));
    }
  }

  child_element = material_element->FirstChildElement("opacity");
  if (child_element) {
    opacity = std::stof(child_element->FindAttribute("value")->Value());
  }

  child_element = material_element->FirstChildElement("opacity_texture");
  if (child_element) {
    std::string path = child_element->FindAttribute("value")->Value();
    Texture opacity_texture(1, 1);
    if (Texture::Load(path, opacity_texture)) {
      opacity_texture_id =
          scene->AddTexture(opacity_texture, PathToFilename(path));
    }
  }

  child_element = material_element->FirstChildElement("flatness");
  if (child_element) {
    flatness = std::stof(child_element->FindAttribute("value")->Value());
  }

  child_element = material_element->FirstChildElement("flatness_texture");
  if (child_element) {
    std::string path = child_element->FindAttribute("value")->Value();
    Texture flatness_texture(1, 1);
    if (Texture::Load(path, flatness_texture)) {
      flatness_texture_id =
          scene->AddTexture(flatness_texture, PathToFilename(path));
    }
  }

  child_element = material_element->FirstChildElement("diffTrans");
  if (child_element) {
    diffTrans = std::stof(child_element->FindAttribute("value")->Value());
  }

  child_element = material_element->FirstChildElement("diffTrans_texture");
  if (child_element) {
    std::string path = child_element->FindAttribute("value")->Value();
    Texture diffTrans_texture(1, 1);
    if (Texture::Load(path, diffTrans_texture)) {
      diffTrans_texture_id =
          scene->AddTexture(diffTrans_texture, PathToFilename(path));
    }
  }

  child_element = material_element->FirstChildElement("bump");
  if (child_element) {
    bump = std::stof(child_element->FindAttribute("value")->Value());
  }

  child_element = material_element->FirstChildElement("bump_texture");
  if (child_element) {
    std::string path = child_element->FindAttribute("value")->Value();
    Texture bump_texture(1, 1);
    if (Texture::Load(path, bump_texture)) {
      bump_texture_id =
          scene->AddTexture(bump_texture, PathToFilename(path));
    }
  }

  child_element = material_element->FirstChildElement("thin");
  if (child_element) {
    if (std::string(child_element->FindAttribute("value")->Value()) == "true") {
      thin = true;
    }
  }

  child_element = material_element->FirstChildElement("normal_texture");
  if (child_element) {
    std::string path = child_element->FindAttribute("value")->Value();
    Texture normal_texture(1, 1);
    if (Texture::Load(path, normal_texture)) {
      normal_texture_id =
          scene->AddTexture(normal_texture, PathToFilename(path));
    }
  }

  child_element = material_element->FirstChildElement("emission_strength");
  if (child_element) {
    emission_strength = std::stof(child_element->FindAttribute("value")->Value());
  }

  // child_element = material_element->FirstChildElement("emission_strength");
  // if (child_element) {
  //   emission_strength =
  //       std::stof(child_element->FindAttribute("value")->Value());
  // }

  // child_element = material_element->FirstChildElement("alpha");
  // if (child_element) {
  //   alpha = std::stof(child_element->FindAttribute("value")->Value());
  // }

  material_type =
      material_name_map[material_element->FindAttribute("type")->Value()];
}

Material::Material(const glm::vec3 &diffuse_color) : Material() {
  diffuse = diffuse_color;
}
}  // namespace sparks
