void swap(inout float v1, inout float v2) {
    float tmp = v1;
    v1 = v2;
    v2 = tmp;
}

float Lerp(float t, float v1, float v2) { return (1 - t) * v1 + t * v2; }
vec3 Lerp(float t, vec3 v1, vec3 v2) { return (1 - t) * v1 + t * v2; }

vec3 SphericalDirection(float sinTheta, float cosTheta, float phi) {
    return vec3(sinTheta * cos(phi), sinTheta * sin(phi), cosTheta);
}

float AbsDot(vec3 v1, vec3 v2) { return abs(dot(v1, v2)); }

float CosTheta(vec3 w) { return w.z; }
float Cos2Theta(vec3 w) { return w.z * w.z; }
float AbsCosTheta(vec3 w) { return abs(w.z); }
float Sin2Theta(vec3 w) {
    return max(0.0, 1.0 - Cos2Theta(w));
}

float SinTheta(vec3 w) { return sqrt(Sin2Theta(w)); }

float TanTheta(vec3 w) { return SinTheta(w) / CosTheta(w); }

float Tan2Theta(vec3 w) {
    return Sin2Theta(w) / Cos2Theta(w);
}

float CosPhi(vec3 w) {
    float sinTheta = SinTheta(w);
    return (sinTheta == 0) ? 1 : clamp(w.x / sinTheta, -1, 1);
}

float SinPhi(vec3 w) {
    float sinTheta = SinTheta(w);
    return (sinTheta == 0) ? 0 : clamp(w.y / sinTheta, -1, 1);
}

float Cos2Phi(vec3 w) { return CosPhi(w) * CosPhi(w); }

float Sin2Phi(vec3 w) { return SinPhi(w) * SinPhi(w); }

float CosDPhi(vec3 wa, vec3 wb) {
    float waxy = wa.x * wa.x + wa.y * wa.y;
    float wbxy = wb.x * wb.x + wb.y * wb.y;
    if (waxy == 0.0 || wbxy == 0.0)
        return 1.0;
    return clamp((wa.x * wb.x + wa.y * wb.y) / sqrt(waxy * wbxy), -1, 1);
}

vec3 Reflect(vec3 wo, vec3 n) {
    return -wo + 2 * dot(wo, n) * n;
}

bool Refract(vec3 wi, vec3 n, float eta, out vec3 wt) {
    // Compute $\cos \theta_\roman{t}$ using Snell's law
    float cosThetaI = dot(n, wi);
    float sin2ThetaI = max(float(0), float(1 - cosThetaI * cosThetaI));
    float sin2ThetaT = eta * eta * sin2ThetaI;

    // Handle total internal reflection for transmission
    if (sin2ThetaT >= 1) return false;
    float cosThetaT = sqrt(1 - sin2ThetaT);
    wt = normalize(eta * -wi + (eta * cosThetaI - cosThetaT) * n);
    return true;
}

bool SameHemisphere(vec3 w, vec3 wp) {
    return w.z * wp.z > 0;
}

float SchlickWeight(float cosTheta) {
    float m = clamp(1 - cosTheta, 0, 1);
    return (m * m) * (m * m) * m;
}

float FrSchlick(float R0, float cosTheta) {
    return Lerp(SchlickWeight(cosTheta), R0, 1);
}

vec3 FrSchlick(vec3 R0, float cosTheta) {
    return Lerp(SchlickWeight(cosTheta), R0, vec3(1.));
}

float sqr(float x) { return x * x; }

// For a dielectric, R(0) = (eta - 1)^2 / (eta + 1)^2, assuming we're
// coming from air..
float SchlickR0FromEta(float eta) { return sqr(eta - 1) / sqr(eta + 1); }

float GTR1(float cosTheta, float alpha) {
    float alpha2 = alpha * alpha;
    return (alpha2 - 1) /
           (Pi * log(alpha2) * (1 + (alpha2 - 1) * cosTheta * cosTheta));
}

// Smith masking/shadowing term.
float smithG_GGX(float cosTheta, float alpha) {
    float alpha2 = alpha * alpha;
    float cosTheta2 = cosTheta * cosTheta;
    return 1 / (cosTheta + sqrt(alpha2 + cosTheta2 - alpha2 * cosTheta2));
}

float FrDielectric(float cosThetaI, float etaI, float etaT) {
    cosThetaI = clamp(cosThetaI, -1, 1);
    // Potentially swap indices of refraction
    bool entering = cosThetaI > 0.f;
    if (!entering) {
        swap(etaI, etaT);
        cosThetaI = abs(cosThetaI);
    }

    // Compute _cosThetaT_ using Snell's law
    float sinThetaI = sqrt(max(0, 1 - cosThetaI * cosThetaI));
    float sinThetaT = etaI / etaT * sinThetaI;

    // Handle total internal reflection
    if (sinThetaT >= 1) return 1;
    float cosThetaT = sqrt(max(0, 1 - sinThetaT * sinThetaT));
    float Rparl = ((etaT * cosThetaI) - (etaI * cosThetaT)) /
                  ((etaT * cosThetaI) + (etaI * cosThetaT));
    float Rperp = ((etaI * cosThetaI) - (etaT * cosThetaT)) /
                  ((etaI * cosThetaI) + (etaT * cosThetaT));
    return (Rparl * Rparl + Rperp * Rperp) / 2;
}
vec3 Faceforward(vec3 n, vec3 v) {
    return (dot(n, v) < 0.f) ? -n : n;
}
float MaxComponentValue(vec3 v) {
    return max(max(v.x, v.y), v.z);
}
float PowerHeuristic(int nf, float fPdf, int ng, float gPdf) {
    float f = nf * fPdf, g = ng * gPdf;
    return (f * f) / (f * f + g * g);
}

vec2 UniformSampleTriangle(vec2 u) {
    float su0 = sqrt(u[0]);
    return vec2(1 - su0, u[1] * su0);
}

vec3 UniformSampleHemisphere(vec2 u) {
    float z = u[0];
    float r = sqrt(max(0, 1. - z * z));
    float phi = 2 * Pi * u[1];
    return vec3(r * cos(phi), r * sin(phi), z);
}

float UniformHemispherePdf() { return Inv2Pi; }

vec3 UniformSampleSphere(vec2 u) {
    float z = 1 - 2 * u[0];
    float r = sqrt(max(0, 1 - z * z));
    float phi = 2 * Pi * u[1];
    return vec3(r * cos(phi), r * sin(phi), z);
}

float UniformSpherePdf() { return Inv4Pi; }

