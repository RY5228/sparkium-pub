struct MicrofacetReflection {
    uint type;
    vec3 R;
    DisneyMicrofacetDistribution distribution;
    DisneyFresnel fresnel;
};

void Constructor(out MicrofacetReflection mr, vec3 R,
                        DisneyMicrofacetDistribution distribution, 
                        DisneyFresnel fresnel) {
    mr.type = BSDF_REFLECTION | BSDF_GLOSSY;
    mr.R = R;
    mr.distribution = distribution;
    mr.fresnel = fresnel;
}
vec3 f(MicrofacetReflection mr, vec3 wo, vec3 wi) {
    float cosThetaO = AbsCosTheta(wo), cosThetaI = AbsCosTheta(wi);
    vec3 wh = wi + wo;
    // Handle degenerate cases for microfacet reflection
    if (cosThetaI == 0 || cosThetaO == 0) return vec3(0.);
    if (wh.x == 0 && wh.y == 0 && wh.z == 0) return vec3(0.);
    wh = normalize(wh);
    // For the Fresnel call, make sure that wh is in the same hemisphere
    // as the surface normal, so that TIR is handled correctly.
    vec3 F = Evaluate(mr.fresnel, dot(wi, Faceforward(wh, vec3(0,0,1))));
    return mr.R * D(mr.distribution, wh) * 
                G(mr.distribution, wo, wi) * F /
           (4 * cosThetaI * cosThetaO);
}
float Pdf(MicrofacetReflection mr, vec3 wo, vec3 wi) {
    if (!SameHemisphere(wo, wi)) return 0;
    vec3 wh = normalize(wo + wi);
    return Pdf(mr.distribution, wo, wh) / 
        (4 * dot(wo, wh));
}
vec3 Sample_f(MicrofacetReflection mr, vec3 wo, out vec3 wi, vec2 u,
                        out float pdf, inout uint sampledType) {
    if (wo.z == 0) return vec3(0.);
    vec3 wh = Sample_wh(mr.distribution, wo, u);
    if (dot(wo, wh) < 0) return vec3(0.);   // Should be rare
    wi = Reflect(wo, wh);
    if (!SameHemisphere(wo, wi)) return vec3(0.f);

    // Compute PDF of _wi_ for microfacet reflection
    pdf = Pdf(mr.distribution, wo, wh) / (4 * dot(wo, wh));
    return f(mr, wo, wi);
}
bool MatchesFlags(MicrofacetReflection mr, uint t) { 
    return (mr.type & t) == mr.type; 
}

