struct MicrofacetTransmissionThin {
    uint type;
    vec3 T;
    TrowbridgeReitzDistribution distribution;
    float etaA, etaB;
    FresnelDielectric fresnel;
    uint mode;
};

void Constructor(out MicrofacetTransmissionThin mt, 
                vec3 T, TrowbridgeReitzDistribution distribution, 
                float etaA, float etaB, uint mode) {
    mt.type = BSDF_TRANSMISSION | BSDF_GLOSSY;
    mt.T = T;
    mt.etaA = etaA;
    mt.distribution = distribution;
    mt.etaB = etaB;
    Constructor(mt.fresnel, etaA, etaB);
    mt.mode = mode;
}
vec3 f(MicrofacetTransmissionThin mt, vec3 wo, vec3 wi) {
    if (SameHemisphere(wo, wi)) return vec3(0);  // transmission only

    float cosThetaO = CosTheta(wo);
    float cosThetaI = CosTheta(wi);
    if (cosThetaI == 0 || cosThetaO == 0) return vec3(0);

    // Compute $\wh$ from $\wo$ and $\wi$ for microfacet transmission
    float eta = CosTheta(wo) > 0 ? (mt.etaB / mt.etaA) : (mt.etaA / mt.etaB);
    vec3 wh = normalize(wo + wi * eta);
    if (wh.z < 0) wh = -wh;

    // Same side?
    if (dot(wo, wh) * dot(wi, wh) > 0) return vec3(0);

    vec3 F = Evaluate(mt.fresnel, dot(wo, wh));

    float sqrtDenom = dot(wo, wh) + eta * dot(wi, wh);
    float factor = (mt.mode == TransportMode_Radiance) ? (1 / eta) : 1;

    return (vec3(1.f) - F) * mt.T *
           abs(D(mt.distribution, wh) * 
           G(mt.distribution, wo, wi) * eta * eta *
                    AbsDot(wi, wh) * AbsDot(wo, wh) * factor * factor /
                    (cosThetaI * cosThetaO * sqrtDenom * sqrtDenom));
}
float Pdf(MicrofacetTransmissionThin mt, vec3 wo, vec3 wi) {
    if (SameHemisphere(wo, wi)) return 0;
    // Compute $\wh$ from $\wo$ and $\wi$ for microfacet transmission
    float eta = CosTheta(wo) > 0 ? (mt.etaB / mt.etaA) : (mt.etaA / mt.etaB);
    vec3 wh = normalize(wo + wi * eta);

    if (dot(wo, wh) * dot(wi, wh) > 0) return 0;

    // Compute change of variables _dwh\_dwi_ for microfacet transmission
    float sqrtDenom = dot(wo, wh) + eta * dot(wi, wh);
    float dwh_dwi =
        abs((eta * eta * dot(wi, wh)) / (sqrtDenom * sqrtDenom));
    return Pdf(mt.distribution, wo, wh) * dwh_dwi;
}
vec3 Sample_f(MicrofacetTransmissionThin mt, vec3 wo, out vec3 wi, vec2 u,
                        out float pdf, inout uint sampledType) {
    if (wo.z == 0) return vec3(0.);
    vec3 wh = Sample_wh(mt.distribution, wo, u);
    if (dot(wo, wh) < 0) return vec3(0.);  // Should be rare

    float eta = CosTheta(wo) > 0 ? (mt.etaA / mt.etaB) : (mt.etaB / mt.etaA);
    if (!Refract(wo, wh, eta, wi)) return vec3(0.);
    pdf = Pdf(mt, wo, wi);
    return f(mt, wo, wi);
}
bool MatchesFlags(MicrofacetTransmissionThin mt, uint t) { 
    return (mt.type & t) == mt.type; 
}

struct MicrofacetTransmission {
    uint type;
    vec3 T;
    DisneyMicrofacetDistribution distribution;
    float etaA, etaB;
    FresnelDielectric fresnel;
    uint mode;
};

void Constructor(out MicrofacetTransmission mt, vec3 T, 
                DisneyMicrofacetDistribution distribution, 
                float etaA, float etaB, uint mode) {
    mt.type = BSDF_TRANSMISSION | BSDF_GLOSSY;
    mt.T = T;
    mt.distribution = distribution;
    mt.etaA = etaA;
    mt.etaB = etaB;
    Constructor(mt.fresnel, etaA, etaB);
    mt.mode = mode;
}
vec3 f(MicrofacetTransmission mt, vec3 wo, vec3 wi) {
    if (SameHemisphere(wo, wi)) return vec3(0);  // transmission only

    float cosThetaO = CosTheta(wo);
    float cosThetaI = CosTheta(wi);
    if (cosThetaI == 0 || cosThetaO == 0) return vec3(0);

    // Compute $\wh$ from $\wo$ and $\wi$ for microfacet transmission
    float eta = CosTheta(wo) > 0 ? (mt.etaB / mt.etaA) : (mt.etaA / mt.etaB);
    vec3 wh = normalize(wo + wi * eta);
    if (wh.z < 0) wh = -wh;

    // Same side?
    if (dot(wo, wh) * dot(wi, wh) > 0) return vec3(0);

    vec3 F = Evaluate(mt.fresnel, dot(wo, wh));

    float sqrtDenom = dot(wo, wh) + eta * dot(wi, wh);
    float factor = (mt.mode == TransportMode_Radiance) ? (1 / eta) : 1;

    return (vec3(1.f) - F) * mt.T *
           abs(D(mt.distribution, wh) * 
           G(mt.distribution, wo, wi) * eta * eta *
                    AbsDot(wi, wh) * AbsDot(wo, wh) * factor * factor /
                    (cosThetaI * cosThetaO * sqrtDenom * sqrtDenom));
}
float Pdf(MicrofacetTransmission mt, vec3 wo, vec3 wi) {
    if (SameHemisphere(wo, wi)) return 0;
    // Compute $\wh$ from $\wo$ and $\wi$ for microfacet transmission
    float eta = CosTheta(wo) > 0 ? (mt.etaB / mt.etaA) : (mt.etaA / mt.etaB);
    vec3 wh = normalize(wo + wi * eta);

    if (dot(wo, wh) * dot(wi, wh) > 0) return 0;

    // Compute change of variables _dwh\_dwi_ for microfacet transmission
    float sqrtDenom = dot(wo, wh) + eta * dot(wi, wh);
    float dwh_dwi =
        abs((eta * eta * dot(wi, wh)) / (sqrtDenom * sqrtDenom));
    return Pdf(mt.distribution, wo, wh) * dwh_dwi;
}
vec3 Sample_f(MicrofacetTransmission mt, vec3 wo, out vec3 wi, vec2 u,
                        out float pdf, inout uint sampledType) {
    // pdf = 0.1;
    // wi = wo;
    if (wo.z == 0) return vec3(0.);
    vec3 wh = Sample_wh(mt.distribution, wo, u);
// if (mt.distribution.sampleVisibleArea)
//     return vec3(0,0,1);
// else return vec3(0,1,0);
    if (dot(wo, wh) < 0) return vec3(0.);  // Should be rare

    float eta = CosTheta(wo) > 0 ? (mt.etaA / mt.etaB) : (mt.etaB / mt.etaA);
    if (!Refract(wo, wh, eta, wi)) return vec3(0.);
// return wi;
    pdf = Pdf(mt, wo, wi);
    return f(mt, wo, wi);
}
bool MatchesFlags(MicrofacetTransmission mt, uint t) { 
    return (mt.type & t) == mt.type; 
}
