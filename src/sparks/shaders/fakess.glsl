struct DisneyFakeSS {
    uint type;
    vec3 R;
    float roughness;
};

void Constructor(out DisneyFakeSS fakess, vec3 R, float roughness) {
    fakess.type = BSDF_REFLECTION | BSDF_DIFFUSE;
    fakess.R = R;
    fakess.roughness = roughness;
}
vec3 f(DisneyFakeSS fakess, vec3 wo, vec3 wi) {
    vec3 wh = wi + wo;
    if (wh.x == 0 && wh.y == 0 && wh.z == 0) return vec3(0.);
    wh = normalize(wh);
    float cosThetaD = dot(wi, wh);

    // Fss90 used to "flatten" retroreflection based on roughness
    float Fss90 = cosThetaD * cosThetaD * fakess.roughness;
    float Fo = SchlickWeight(AbsCosTheta(wo)),
          Fi = SchlickWeight(AbsCosTheta(wi));
    float Fss = Lerp(Fo, 1.0, Fss90) * Lerp(Fi, 1.0, Fss90);
    // 1.25 scale is used to (roughly) preserve albedo
    float ss =
        1.25f * (Fss * (1 / (AbsCosTheta(wo) + AbsCosTheta(wi)) - .5f) + .5f);

    return fakess.R * InvPi * ss;
}
vec3 rho(DisneyFakeSS fakess, vec3 wo, int nSamples, vec2 samples) { 
    return fakess.R; 
}
vec3 rho(DisneyFakeSS fakess, int nSamples, vec2 samples1, vec2 samples2) { 
    return fakess.R; 
}
float Pdf(DisneyFakeSS fakess, vec3 wo, vec3 wi) {
    return SameHemisphere(wo, wi) ? AbsCosTheta(wi) * InvPi : 0;
}
vec3 Sample_f(DisneyFakeSS fakess, vec3 wo, out vec3 wi, vec2 u,
                        out float pdf, inout uint sampledType) {
    // Cosine-sample the hemisphere, flipping the direction if necessary
    wi = CosineSampleHemisphere(u);
    if (wo.z < 0) wi.z *= -1;
    pdf = Pdf(fakess, wo, wi);
    return f(fakess, wo, wi);
}
bool MatchesFlags(DisneyFakeSS fakess, uint t) { 
    return (fakess.type & t) == fakess.type; 
}
