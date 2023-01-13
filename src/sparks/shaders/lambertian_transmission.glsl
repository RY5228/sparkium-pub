struct LambertianTransmission {
    uint type;
    vec3 T;
};

void Constructor(out LambertianTransmission lt, vec3 T) {
    lt.type = BSDF_TRANSMISSION | BSDF_DIFFUSE;
    lt.T = T;
}
vec3 f(LambertianTransmission lt, vec3 wo, vec3 wi) {
    return lt.T * InvPi;
}
vec3 rho(LambertianTransmission lt, vec3 wo, int nSamples, vec2 samples) { 
    return lt.T; 
}
vec3 rho(LambertianTransmission lt, int nSamples, vec2 samples1, vec2 samples2) { 
    return lt.T; 
}
float Pdf(LambertianTransmission lt, vec3 wo, vec3 wi) {
    return !SameHemisphere(wo, wi) ? AbsCosTheta(wi) * InvPi : 0;
}
vec3 Sample_f(LambertianTransmission lt, vec3 wo, out vec3 wi, vec2 u,
                        out float pdf, inout uint sampledType) {
    wi = CosineSampleHemisphere(u);
    if (wo.z > 0) wi.z *= -1;
    pdf = Pdf(lt, wo, wi);
    return f(lt, wo, wi);
}
bool MatchesFlags(LambertianTransmission lt, uint t) { 
    return (lt.type & t) == lt.type; 
}

