struct DisneyClearcoat {
    uint type;
    float weight, gloss;
};

void Constructor(out DisneyClearcoat clearcoat, float weight, float gloss) {
    clearcoat.type = BSDF_REFLECTION | BSDF_GLOSSY;
    clearcoat.weight = weight;
    clearcoat.gloss = gloss;
}
vec3 f(DisneyClearcoat clearcoat, vec3 wo, vec3 wi) {
    vec3 wh = wi + wo;
    if (wh.x == 0 && wh.y == 0 && wh.z == 0) return vec3(0.);
    wh = normalize(wh);

    // Clearcoat has ior = 1.5 hardcoded -> F0 = 0.04. It then uses the
    // GTR1 distribution, which has even fatter tails than Trowbridge-Reitz
    // (which is GTR2).
    float Dr = GTR1(AbsCosTheta(wh), clearcoat.gloss);
    float Fr = FrSchlick(.04, dot(wo, wh));
    // The geometric term always based on alpha = 0.25.
    float Gr =
        smithG_GGX(AbsCosTheta(wo), .25) * smithG_GGX(AbsCosTheta(wi), .25);

    return vec3(clearcoat.weight * Gr * Fr * Dr / 4);
}
float Pdf(DisneyClearcoat clearcoat, vec3 wo, vec3 wi) {
    if (!SameHemisphere(wo, wi)) return 0;

    vec3 wh = wi + wo;
    if (wh.x == 0 && wh.y == 0 && wh.z == 0) return 0;
    wh = normalize(wh);

    // The sampling routine samples wh exactly from the GTR1 distribution.
    // Thus, the final value of the PDF is just the value of the
    // distribution for wh converted to a mesure with respect to the
    // surface normal.
    float Dr = GTR1(AbsCosTheta(wh), clearcoat.gloss);
    return Dr * AbsCosTheta(wh) / (4 * dot(wo, wh));
}
vec3 Sample_f(DisneyClearcoat clearcoat, vec3 wo, out vec3 wi, vec2 u,
                        out float pdf, inout uint sampledType) {
    // TODO: double check all this: there still seem to be some very
    // occasional fireflies with clearcoat; presumably there is a bug
    // somewhere.
    if (wo.z == 0) return vec3(0.);

    float alpha2 = clearcoat.gloss * clearcoat.gloss;
    float cosTheta = sqrt(
        max(0, (1 - pow(alpha2, 1 - u[0])) / (1 - alpha2)));
    float sinTheta = sqrt(max(0, 1 - cosTheta * cosTheta));
    float phi = 2 * Pi * u[1];
    vec3 wh = SphericalDirection(sinTheta, cosTheta, phi);
    if (!SameHemisphere(wo, wh)) wh = -wh;

    wi = Reflect(wo, wh);
    if (!SameHemisphere(wo, wi)) return vec3(0.f);

    pdf = Pdf(clearcoat, wo, wi);
    return f(clearcoat, wo, wi);
}
bool MatchesFlags(DisneyClearcoat clearcoat, uint t) { 
    return (clearcoat.type & t) == clearcoat.type; 
}
