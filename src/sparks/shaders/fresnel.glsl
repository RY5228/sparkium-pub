struct DisneyFresnel {
    vec3 R0;
    float metallic, eta;
};

void Constructor(out DisneyFresnel fresnel, vec3 R0, float metallic, float eta) {
    fresnel.R0 = R0;
    fresnel.metallic = metallic;
    fresnel.eta = eta;
}

vec3 Evaluate(DisneyFresnel fresnel, float cosI) {
    return Lerp(fresnel.metallic, vec3(FrDielectric(cosI, 1, fresnel.eta)),
                FrSchlick(fresnel.R0, cosI));
}

struct FresnelDielectric {
    float etaI, etaT;
};

void Constructor(out FresnelDielectric fd, float etaI, float etaT) {
    fd.etaI = etaI;
    fd.etaT = etaT;
}

vec3 Evaluate(FresnelDielectric fd, float cosThetaI) {
    return vec3(FrDielectric(cosThetaI, fd.etaI, fd.etaT));
}
