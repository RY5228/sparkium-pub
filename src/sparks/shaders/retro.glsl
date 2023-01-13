struct DisneyRetro {
    uint type;
    vec3 R;
    float roughness;
};

void Constructor(out DisneyRetro retro, vec3 R, float roughness) {
    retro.type = BSDF_REFLECTION | BSDF_DIFFUSE;
    retro.R = R;
    retro.roughness = roughness;
}
vec3 f(DisneyRetro retro, vec3 wo, vec3 wi) {
    vec3 wh = wi + wo;
    if (wh.x == 0 && wh.y == 0 && wh.z == 0) return vec3(0.);
    wh = normalize(wh);
    float cosThetaD = dot(wi, wh);

    float Fo = SchlickWeight(AbsCosTheta(wo)),
          Fi = SchlickWeight(AbsCosTheta(wi));
    float Rr = 2 * retro.roughness * cosThetaD * cosThetaD;

    // Burley 2015, eq (4).
    return retro.R * InvPi * Rr * (Fo + Fi + Fo * Fi * (Rr - 1));
}
vec3 rho(DisneyRetro retro, vec3 wo, int nSamples, vec2 samples) { 
    return retro.R; 
}
vec3 rho(DisneyRetro retro, int nSamples, vec2 samples1, vec2 samples2) { 
    return retro.R; 
}
float Pdf(DisneyRetro retro, vec3 wo, vec3 wi) {
    return SameHemisphere(wo, wi) ? AbsCosTheta(wi) * InvPi : 0;
}
vec3 Sample_f(DisneyRetro retro, vec3 wo, out vec3 wi, vec2 u,
                        out float pdf, inout uint sampledType) {
    // Cosine-sample the hemisphere, flipping the direction if necessary
    wi = CosineSampleHemisphere(u);
    if (wo.z < 0) wi.z *= -1;
    pdf = Pdf(retro, wo, wi);
    return f(retro, wo, wi);
}
bool MatchesFlags(DisneyRetro retro, uint t) { 
    return (retro.type & t) == retro.type; 
}
