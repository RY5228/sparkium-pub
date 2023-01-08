#version 450
#extension GL_GOOGLE_include_directive : require
#extension GL_EXT_nonuniform_qualifier : enable
#include "material.glsl"
#include "uniform_objects.glsl"
#include "constants.glsl"

layout(location = 0) in flat int instance_id;
layout(location = 1) in vec3 position;
layout(location = 2) in vec3 normal;
layout(location = 3) in vec3 tangent;
layout(location = 4) in vec2 tex_coord;
layout(location = 0) out vec4 color_out;
layout(location = 1) out uvec4 instance_out;

layout(binding = 0) readonly uniform global_uniform_object {
  GlobalUniformObject global_object;
};
layout(binding = 2) readonly buffer material_uniform_object {
  Material materials[];
};
layout(binding = 3) uniform sampler2D[] texture_samplers;

vec3 SampleEnvmap(vec3 direction) {
  float x = global_object.envmap_offset;
  float y = acos(direction.y) * INV_PI;
  if (length(vec2(direction.x, direction.y)) > 1e-4) {
    x += atan(direction.x, -direction.z);
  }
  x *= INV_PI * 0.5;
  return texture(texture_samplers[global_object.envmap_id], vec2(x, y))
      .xyz;  // textures_[envmap_id_].Sample(glm::);
}

void main() {
  Material material = materials[instance_id];
  vec3 light = global_object.envmap_minor_color;
  light = max(light, vec3(0.1));
  float sin_offset = sin(global_object.envmap_offset);
  float cos_offset = cos(global_object.envmap_offset);
  light += global_object.envmap_major_color *
           max(dot(global_object.envmap_light_direction, normal), 0.0) * 2.0;
  if (material.material_type == MATERIAL_TYPE_EMISSION) {
    color_out = vec4(material.emission, 1.0);
  } else if (material.material_type == MATERIAL_TYPE_SPECULAR) {
    mat4 camera_to_world = inverse(global_object.camera);
    mat4 screen_to_camera = inverse(global_object.projection);
    vec3 origin = vec3(camera_to_world * vec4(0, 0, 0, 1));
    vec3 wi = normalize(position - origin);
    vec3 wo = wi - 2.0 * normal * dot(normal, wi);
    color_out =
        vec4(material.specular * SampleEnvmap(wo), 1.0) *
        texture(texture_samplers[nonuniformEXT(material.specular_texture_id)],
                tex_coord);
  } else {
    color_out =
        vec4(material.diffuse * light, 1.0) *
        texture(texture_samplers[nonuniformEXT(material.diffuse_texture_id)],
                tex_coord);
  }
  instance_out = uvec4(instance_id);
}
