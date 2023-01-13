struct SpecularTransmission {
    uint type;
    vec3 T;
    float etaA, etaB;
    FresnelDielectric fresnel; 
    uint mode;
};

#define TransportMode_Radiance 0
#define TransportMode_Importance 1

void Constructor(out SpecularTransmission st, 
    vec3 T, float etaA, float etaB, uint mode
) {
    st.type = BSDF_TRANSMISSION | BSDF_SPECULAR;
    st.T = T;
    st.etaA = etaA;
    st.etaB = etaB;
    Constructor(st.fresnel, etaA, etaB);
    st.mode = mode;
}
vec3 f(SpecularTransmission st, vec3 wo, vec3 wi) {
    return vec3(0.0);
}
float Pdf(SpecularTransmission st, vec3 wo, vec3 wi) {
    return 0;
}
vec3 Sample_f(SpecularTransmission st, vec3 wo, out vec3 wi, vec2 u,
                        out float pdf, inout uint sampledType) {
    // Figure out which $\eta$ is incident and which is transmitted
    bool entering = CosTheta(wo) > 0;
    float etaI = entering ? st.etaA : st.etaB;
    float etaT = entering ? st.etaB : st.etaA;

    // Compute ray direction for specular transmission
    if (!Refract(wo, Faceforward(vec3(0, 0, 1), wo), etaI / etaT, wi))
        return vec3(0);
    pdf = 1;
    vec3 ft = st.T * (vec3(1.) - Evaluate(st.fresnel, CosTheta(wi)));
    // Account for non-symmetry with transmission to different medium
    if (st.mode == TransportMode_Radiance) ft *= (etaI * etaI) / (etaT * etaT);
    return ft / AbsCosTheta(wi);
}
bool MatchesFlags(SpecularTransmission st, uint t) { 
    return (st.type & t) == st.type; 
}

