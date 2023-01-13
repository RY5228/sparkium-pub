vec2 ConcentricSampleDisk(vec2 u) {
    // Map uniform random numbers to $[-1,1]^2$
    vec2 uOffset = 2.f * u - vec2(1.0, 1.0);

    // Handle degeneracy at the origin
    if (uOffset.x == 0 && uOffset.y == 0) return vec2(0, 0);

    // Apply concentric mapping to point
    float theta, r;
    if (abs(uOffset.x) > abs(uOffset.y)) {
        r = uOffset.x;
        theta = PiOver4 * (uOffset.y / uOffset.x);
    } else {
        r = uOffset.y;
        theta = PiOver2 - PiOver4 * (uOffset.x / uOffset.y);
    }
    return r * vec2(cos(theta), sin(theta));
}

vec3 CosineSampleHemisphere(vec2 u) {
    vec2 d = ConcentricSampleDisk(u);
    float z = sqrt(max(0, 1 - d.x * d.x - d.y * d.y));
    return vec3(d.x, d.y, z);
}

float CosineHemispherePdf(float cosTheta) { return cosTheta * InvPi; }

