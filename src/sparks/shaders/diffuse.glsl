struct DisneyDiffuse {
    uint type;
    vec3 R;
};

void Constructor(out DisneyDiffuse diffuse, vec3 R) {
    diffuse.type = BSDF_REFLECTION | BSDF_DIFFUSE;
    diffuse.R = R;
}
vec3 f(DisneyDiffuse diffuse, vec3 wo, vec3 wi) {
    float Fo = SchlickWeight(AbsCosTheta(wo)),
          Fi = SchlickWeight(AbsCosTheta(wi));

    // Diffuse fresnel - go from 1 at normal incidence to .5 at grazing.
    // Burley 2015, eq (4).
    return diffuse.R * InvPi * (1 - Fo / 2) * (1 - Fi / 2);
}
vec3 rho(DisneyDiffuse diffuse, vec3 wo, int nSamples, vec2 samples) { 
    return diffuse.R; 
}
vec3 rho(DisneyDiffuse diffuse, int nSamples, vec2 samples1, vec2 samples2) { 
    return diffuse.R; 
}
float Pdf(DisneyDiffuse diffuse, vec3 wo, vec3 wi) {
    return SameHemisphere(wo, wi) ? AbsCosTheta(wi) * InvPi : 0;
}
vec3 Sample_f(DisneyDiffuse diffuse, vec3 wo, out vec3 wi, vec2 u,
                        out float pdf, inout uint sampledType) {
    // Cosine-sample the hemisphere, flipping the direction if necessary
    wi = CosineSampleHemisphere(u);
    if (wo.z < 0) wi.z *= -1;
    pdf = Pdf(diffuse, wo, wi);
    return f(diffuse, wo, wi);
}
bool MatchesFlags(DisneyDiffuse diffuse, uint t) { 
    return (diffuse.type & t) == diffuse.type; 
}

