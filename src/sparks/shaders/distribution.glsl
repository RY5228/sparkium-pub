struct DisneyMicrofacetDistribution {
    bool sampleVisibleArea;
    float alphax;
    float alphay;
};

void Constructor(out DisneyMicrofacetDistribution distribution, 
    float alphax, float alphay) {
    distribution.sampleVisibleArea = true;
    distribution.alphax = max(0.001, alphax);
    distribution.alphay = max(0.001, alphay);
}

float RoughnessToAlpha(DisneyMicrofacetDistribution distribution, float roughness) {
    roughness = max(roughness, 1e-3);
    float x = log(roughness);
    return 1.62142f + 0.819955f * x + 0.1734f * x * x + 0.0171201f * x * x * x +
           0.000640711f * x * x * x * x;
}

float Lambda(DisneyMicrofacetDistribution distribution, vec3 w) {
    float absTanTheta = abs(TanTheta(w));
    if (isinf(absTanTheta)) return 0.;
    // Compute _alpha_ for direction _w_
    float alpha =
        sqrt(Cos2Phi(w) * distribution.alphax * distribution.alphax + 
             Sin2Phi(w) * distribution.alphay * distribution.alphay);
    float alpha2Tan2Theta = (alpha * absTanTheta) * (alpha * absTanTheta);
    return (-1 + sqrt(1.f + alpha2Tan2Theta)) / 2;
}

float G1(DisneyMicrofacetDistribution distribution, vec3 w) {
    //    if (Dot(w, wh) * CosTheta(w) < 0.) return 0.;
    return 1 / (1 + Lambda(distribution, w));
}

float D(DisneyMicrofacetDistribution distribution, vec3 wh) {
    float tan2Theta = Tan2Theta(wh);
    if (isinf(tan2Theta)) return 0.;
    float cos4Theta = Cos2Theta(wh) * Cos2Theta(wh);
    float e =
        (Cos2Phi(wh) / (distribution.alphax * distribution.alphax) + Sin2Phi(wh) / (distribution.alphay * distribution.alphay)) *
        tan2Theta;
    return 1 / (PI * distribution.alphax * distribution.alphay * cos4Theta * (1 + e) * (1 + e));
}

void TrowbridgeReitzSample11(float cosTheta, float U1, float U2,
                                    out float slope_x, out float slope_y) {
    // special case (normal incidence)
    if (cosTheta > .9999) {
        float r = sqrt(U1 / (1 - U1));
        float phi = 6.28318530718 * U2;
        slope_x = r * cos(phi);
        slope_y = r * sin(phi);
        return;
    }

    float sinTheta =
        sqrt(max(0, 1 - cosTheta * cosTheta));
    float tanTheta = sinTheta / cosTheta;
    float a = 1 / tanTheta;
    float G1 = 2 / (1 + sqrt(1.f + 1.f / (a * a)));

    // sample slope_x
    float A = 2 * U1 / G1 - 1;
    float tmp = 1.f / (A * A - 1.f);
    if (tmp > 1e10) tmp = 1e10;
    float B = tanTheta;
    float D = sqrt(
        max(float(B * B * tmp * tmp - (A * A - B * B) * tmp), float(0)));
    float slope_x_1 = B * tmp - D;
    float slope_x_2 = B * tmp + D;
    slope_x = (A < 0 || slope_x_2 > 1.f / tanTheta) ? slope_x_1 : slope_x_2;

    // sample slope_y
    float S;
    if (U2 > 0.5f) {
        S = 1.f;
        U2 = 2.f * (U2 - .5f);
    } else {
        S = -1.f;
        U2 = 2.f * (.5f - U2);
    }
    float z =
        (U2 * (U2 * (U2 * 0.27385f - 0.73369f) + 0.46341f)) /
        (U2 * (U2 * (U2 * 0.093073f + 0.309420f) - 1.000000f) + 0.597999f);
    slope_y = S * z * sqrt(1.f + slope_x * slope_x);
}

vec3 TrowbridgeReitzSample(vec3 wi, float alpha_x,
                                      float alpha_y, float U1, float U2) {
    // 1. stretch wi
    vec3 wiStretched =
        normalize(vec3(alpha_x * wi.x, alpha_y * wi.y, wi.z));

    // 2. simulate P22_{wi}(x_slope, y_slope, 1, 1)
    float slope_x, slope_y;
    TrowbridgeReitzSample11(CosTheta(wiStretched), U1, U2, slope_x, slope_y);

    // 3. rotate
    float tmp = CosPhi(wiStretched) * slope_x - SinPhi(wiStretched) * slope_y;
    slope_y = SinPhi(wiStretched) * slope_x + CosPhi(wiStretched) * slope_y;
    slope_x = tmp;

    // 4. unstretch
    slope_x = alpha_x * slope_x;
    slope_y = alpha_y * slope_y;

    // 5. compute normal
    return normalize(vec3(-slope_x, -slope_y, 1.));
}


vec3 Sample_wh(DisneyMicrofacetDistribution distribution, vec3 wo, vec2 u) {
    vec3 wh;
    if (!distribution.sampleVisibleArea) {
        return vec3(0,0,1);
        float cosTheta = 0, phi = (2 * PI) * u[1];
        if (distribution.alphax == distribution.alphay) {
            float tanTheta2 = distribution.alphax * distribution.alphax * u[0] / (1.0f - u[0]);
            cosTheta = 1 / sqrt(1 + tanTheta2);
        } else {
            phi =
                atan(distribution.alphay / distribution.alphax * tan(2 * PI * u[1] + .5f * PI));
            if (u[1] > .5f) phi += PI;
            float sinPhi = sin(phi), cosPhi = cos(phi);
            float alphax2 = distribution.alphax * distribution.alphax, alphay2 = distribution.alphay * distribution.alphay;
            float alpha2 =
                1 / (cosPhi * cosPhi / alphax2 + sinPhi * sinPhi / alphay2);
            float tanTheta2 = alpha2 * u[0] / (1 - u[0]);
            cosTheta = 1 / sqrt(1 + tanTheta2);
        }
        float sinTheta =
            sqrt(max(0., 1. - cosTheta * cosTheta));
        wh = SphericalDirection(sinTheta, cosTheta, phi);
        if (!SameHemisphere(wo, wh)) wh = -wh;
    } else {
        bool flip = wo.z < 0;
        wh = TrowbridgeReitzSample(flip ? -wo : wo, distribution.alphax, distribution.alphay, u[0], u[1]);
        if (flip) wh = -wh;
    }
    return wh;
}

float Pdf(DisneyMicrofacetDistribution distribution, vec3 wo, vec3 wh) {
    if (distribution.sampleVisibleArea)
        return D(distribution, wh) * 
               G1(distribution, wo) * 
               AbsDot(wo, wh) / AbsCosTheta(wo);
    else
        return D(distribution, wh) * 
               AbsCosTheta(wh);
}

float G(DisneyMicrofacetDistribution distribution, vec3 wo, vec3 wi) {
    // Disney uses the separable masking-shadowing model.
    return G1(distribution, wo) * G1(distribution, wi);
}

struct TrowbridgeReitzDistribution {
    bool sampleVisibleArea;
    float alphax;
    float alphay;
};

void Constructor(out TrowbridgeReitzDistribution distribution,
    float alphax, float alphay) {
    distribution.sampleVisibleArea = true;
    distribution.alphax = max(0.001, alphax);
    distribution.alphay = max(0.001, alphay);
}

float RoughnessToAlpha(TrowbridgeReitzDistribution distribution, float roughness) {
    roughness = max(roughness, 1e-3);
    float x = log(roughness);
    return 1.62142f + 0.819955f * x + 0.1734f * x * x + 0.0171201f * x * x * x +
           0.000640711f * x * x * x * x;
}

float Lambda(TrowbridgeReitzDistribution distribution, vec3 w) {
    float absTanTheta = abs(TanTheta(w));
    if (isinf(absTanTheta)) return 0.;
    // Compute _alpha_ for direction _w_
    float alpha =
        sqrt(Cos2Phi(w) * distribution.alphax * distribution.alphax + 
             Sin2Phi(w) * distribution.alphay * distribution.alphay);
    float alpha2Tan2Theta = (alpha * absTanTheta) * (alpha * absTanTheta);
    return (-1 + sqrt(1.f + alpha2Tan2Theta)) / 2;
}

float G1(TrowbridgeReitzDistribution distribution, vec3 w) {
    //    if (Dot(w, wh) * CosTheta(w) < 0.) return 0.;
    return 1 / (1 + Lambda(distribution, w));
}

float D(TrowbridgeReitzDistribution distribution, vec3 wh) {
    float tan2Theta = Tan2Theta(wh);
    if (isinf(tan2Theta)) return 0.;
    float cos4Theta = Cos2Theta(wh) * Cos2Theta(wh);
    float e =
        (Cos2Phi(wh) / (distribution.alphax * distribution.alphax) + Sin2Phi(wh) / (distribution.alphay * distribution.alphay)) *
        tan2Theta;
    return 1 / (PI * distribution.alphax * distribution.alphay * cos4Theta * (1 + e) * (1 + e));
}

vec3 Sample_wh(TrowbridgeReitzDistribution distribution, vec3 wo, vec2 u) {
    vec3 wh;
    if (!distribution.sampleVisibleArea) {
        float cosTheta = 0, phi = (2 * PI) * u[1];
        if (distribution.alphax == distribution.alphay) {
            float tanTheta2 = distribution.alphax * distribution.alphax * u[0] / (1.0f - u[0]);
            cosTheta = 1 / sqrt(1 + tanTheta2);
        } else {
            phi =
                atan(distribution.alphay / distribution.alphax * tan(2 * PI * u[1] + .5f * PI));
            if (u[1] > .5f) phi += PI;
            float sinPhi = sin(phi), cosPhi = cos(phi);
            float alphax2 = distribution.alphax * distribution.alphax, alphay2 = distribution.alphay * distribution.alphay;
            float alpha2 =
                1 / (cosPhi * cosPhi / alphax2 + sinPhi * sinPhi / alphay2);
            float tanTheta2 = alpha2 * u[0] / (1 - u[0]);
            cosTheta = 1 / sqrt(1 + tanTheta2);
        }
        float sinTheta =
            sqrt(max(0., 1. - cosTheta * cosTheta));
        wh = SphericalDirection(sinTheta, cosTheta, phi);
        if (!SameHemisphere(wo, wh)) wh = -wh;
    } else {
        bool flip = wo.z < 0;
        wh = TrowbridgeReitzSample(flip ? -wo : wo, distribution.alphax, distribution.alphay, u[0], u[1]);
        if (flip) wh = -wh;
    }
    return wh;
}

float Pdf(TrowbridgeReitzDistribution distribution, vec3 wo, vec3 wh) {
    if (distribution.sampleVisibleArea)
        return D(distribution, wh) * 
               G1(distribution, wo) * 
               AbsDot(wo, wh) / AbsCosTheta(wo);
    else
        return D(distribution, wh) * 
               AbsCosTheta(wh);
}

float G(TrowbridgeReitzDistribution distribution, vec3 wo, vec3 wi) {
        return 1 / (1 + Lambda(distribution, wo) + 
                    Lambda(distribution, wi));
}