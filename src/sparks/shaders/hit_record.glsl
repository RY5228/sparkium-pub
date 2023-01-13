struct HitRecord {
  int hit_entity_id;
  vec3 position;
  vec3 normal;
  vec3 geometry_normal;
  vec3 tangent;
  vec2 tex_coord;
  bool front_face;

  vec3 base_color;
  vec3 emission;
  vec3 scatterDistance;
  float metallic;
  float roughness;
  float specularTint;
  float sheen;
  float sheenTint;
  float clearcoat;
  float clearcoatGloss;
  float anisotropy;
  float anisotropyRotation;
  float specTrans;
  float opacity;
  float flatness;
  float diffTrans;
  float bump;
  float ior;
  bool thin;
  // float alpha;
  uint material_type;
  uint BxDFType;
};

HitRecord GetHitRecord(RayPayload ray_payload, vec3 origin, vec3 direction) {
  HitRecord hit_record;
  ObjectInfo object_info = object_infos[ray_payload.object_id];
  Vertex v0 = GetVertex(
      object_info.vertex_offset +
      indices[object_info.index_offset + ray_payload.primitive_id * 3 + 0]);
  Vertex v1 = GetVertex(
      object_info.vertex_offset +
      indices[object_info.index_offset + ray_payload.primitive_id * 3 + 1]);
  Vertex v2 = GetVertex(
      object_info.vertex_offset +
      indices[object_info.index_offset + ray_payload.primitive_id * 3 + 2]);
  hit_record.hit_entity_id = int(ray_payload.object_id);

  mat3 object_to_world = mat3(ray_payload.object_to_world);
  hit_record.position = ray_payload.object_to_world *
                        vec4(mat3(v0.position, v1.position, v2.position) *
                                 ray_payload.barycentric,
                             1.0);

  hit_record.normal = normalize(transpose(inverse(object_to_world)) *
                                mat3(v0.normal, v1.normal, v2.normal) *
                                ray_payload.barycentric);
  hit_record.geometry_normal =
      normalize(transpose(inverse(object_to_world)) *
                cross(v1.position - v0.position, v2.position - v0.position));
  hit_record.tangent =
      normalize(object_to_world * mat3(v0.tangent, v1.tangent, v2.tangent) *
                ray_payload.barycentric);
  hit_record.tex_coord = mat3x2(v0.tex_coord, v1.tex_coord, v2.tex_coord) *
                         ray_payload.barycentric;

  Material mat = materials[hit_record.hit_entity_id];
  hit_record.base_color =
      mat.albedo_color *
      texture(texture_samplers[mat.albedo_texture_id], hit_record.tex_coord)
          .xyz;
  hit_record.emission = mat.emission * mat.emission_strength *
      texture(texture_samplers[mat.emission_texture_id], hit_record.tex_coord)
          .xyz;
  hit_record.scatterDistance =
      mat.scatterDistance *
      texture(texture_samplers[mat.scatterDistance_texture_id], hit_record.tex_coord)
          .xyz;
  hit_record.metallic =
      mat.metallic *
      texture(texture_samplers[mat.metallic_texture_id], hit_record.tex_coord)
          .x;
  hit_record.roughness =
      mat.roughness *
      texture(texture_samplers[mat.roughness_texture_id], hit_record.tex_coord)
          .x;
  hit_record.specularTint =
      mat.specularTint *
      texture(texture_samplers[mat.specularTint_texture_id], hit_record.tex_coord)
          .x;
  hit_record.sheen =
      mat.sheen *
      texture(texture_samplers[mat.sheen_texture_id], hit_record.tex_coord)
          .x;
  hit_record.sheenTint =
      mat.sheenTint *
      texture(texture_samplers[mat.sheenTint_texture_id], hit_record.tex_coord)
          .x;
  hit_record.clearcoat =
      mat.clearcoat *
      texture(texture_samplers[mat.clearcoat_texture_id], hit_record.tex_coord)
          .x;
  hit_record.clearcoatGloss =
      mat.clearcoatGloss *
      texture(texture_samplers[mat.clearcoatGloss_texture_id], hit_record.tex_coord)
          .x;
  hit_record.anisotropy =
      mat.anisotropy *
      texture(texture_samplers[mat.anisotropy_texture_id], hit_record.tex_coord)
          .x;
  hit_record.anisotropyRotation =
      mat.anisotropyRotation *
      texture(texture_samplers[mat.anisotropyRotation_texture_id], hit_record.tex_coord)
          .x;
  hit_record.specTrans =
      mat.specTrans *
      texture(texture_samplers[mat.specTrans_texture_id], hit_record.tex_coord)
          .x;
  hit_record.opacity =
      mat.opacity *
      texture(texture_samplers[mat.opacity_texture_id], hit_record.tex_coord)
          .x;
  hit_record.flatness =
      mat.flatness *
      texture(texture_samplers[mat.flatness_texture_id], hit_record.tex_coord)
          .x;
  hit_record.diffTrans =
      mat.diffTrans *
      texture(texture_samplers[mat.diffTrans_texture_id], hit_record.tex_coord)
          .x;
  hit_record.bump =
      mat.bump *
      texture(texture_samplers[mat.bump_texture_id], hit_record.tex_coord)
          .x;
  hit_record.ior = mat.ior;
  hit_record.thin = mat.thin;
  // hit_record.emission_strength = mat.emission_strength;
  // hit_record.alpha = mat.alpha;
  hit_record.material_type = mat.material_type;
  hit_record.BxDFType = mat.BxDFType;


  if (dot(hit_record.geometry_normal, hit_record.normal) < 0.0) {
    hit_record.geometry_normal = -hit_record.geometry_normal;
  }

  // hit_record.front_face = true;
  // if (dot(direction, hit_record.geometry_normal) > 0.0) {
  //   hit_record.front_face = false;
    // hit_record.geometry_normal = -hit_record.geometry_normal;
  //   hit_record.normal = -hit_record.normal;
  //   hit_record.tangent = -hit_record.tangent;
  // }

  return hit_record;
}
