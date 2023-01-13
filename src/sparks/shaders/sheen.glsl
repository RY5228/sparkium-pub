struct DisneySheen {
    uint type;
    vec3 R;
};

void Constructor(out DisneySheen sheen, vec3 R) {
    sheen.type = BSDF_REFLECTION | BSDF_DIFFUSE;
    sheen.R = R;
}
vec3 f(DisneySheen sheen, vec3 wo, vec3 wi) {
    vec3 wh = wi + wo;
    if (wh.x == 0 && wh.y == 0 && wh.z == 0) return vec3(0.);
    wh = normalize(wh);
    float cosThetaD = dot(wi, wh);

    return sheen.R * SchlickWeight(cosThetaD);
}
vec3 rho(DisneySheen sheen, vec3 wo, int nSamples, vec2 samples) { 
    return sheen.R; 
}
vec3 rho(DisneySheen sheen, int nSamples, vec2 samples1, vec2 samples2) { 
    return sheen.R; 
}
float Pdf(DisneySheen sheen, vec3 wo, vec3 wi) {
    return SameHemisphere(wo, wi) ? AbsCosTheta(wi) * InvPi : 0;
}
vec3 Sample_f(DisneySheen sheen, vec3 wo, out vec3 wi, vec2 u,
                        out float pdf, inout uint sampledType) {
    // Cosine-sample the hemisphere, flipping the direction if necessary
    wi = CosineSampleHemisphere(u);
    if (wo.z < 0) wi.z *= -1;
    pdf = Pdf(sheen, wo, wi);
    return f(sheen, wo, wi);
}
bool MatchesFlags(DisneySheen sheen, uint t) { 
    return (sheen.type & t) == sheen.type; 
}
