struct BSDF {
    vec3 ns, ng;
    vec3 ss, ts;
    int nBxDFs;
    DisneyDiffuse diffuse;
    DisneyFakeSS fakess;
    SpecularTransmission st;
    DisneyRetro retro;
    DisneySheen sheen;
    MicrofacetReflection mr;
    DisneyClearcoat clearcoat;
    MicrofacetTransmission mt;
    MicrofacetTransmissionThin mtt;
    LambertianTransmission lt;
    uint attrs;
    float eta;
};

#define MaxBxDFs 8

#define BSDF_ATTR_NONE 0
#define BSDF_ATTR_DIFFUSE (1 << 0)
#define BSDF_ATTR_FAKESS (1 << 1)
#define BSDF_ATTR_ST (1 << 2)
#define BSDF_ATTR_RETRO (1 << 3)
#define BSDF_ATTR_SHEEN (1 << 4)
#define BSDF_ATTR_MR (1 << 5)
#define BSDF_ATTR_CLEARCOAT (1 << 6)
#define BSDF_ATTR_MT (1 << 7)
#define BSDF_ATTR_MTT (1 << 8)
#define BSDF_ATTR_LT (1 << 9)

void Constructor(out BSDF bsdf, vec3 normal, vec3 gnormal, vec3 tangent, float eta) {
    bsdf.ns = normal;
    bsdf.ng = gnormal;
    bsdf.ss = normalize(tangent);
    bsdf.ts = cross(normal, tangent);
    bsdf.nBxDFs = 0;
    bsdf.attrs = 0;
    bsdf.eta = eta;
}

void Constructor(out BSDF bsdf, vec3 normal, vec3 gnormal, vec3 tangent) {
    bsdf.ns = normal;
    bsdf.ng = gnormal;
    bsdf.ss = normalize(tangent);
    bsdf.ts = cross(normal, tangent);
    bsdf.nBxDFs = 0;
    bsdf.attrs = 0;
    bsdf.eta = 1;
}

void Add(inout BSDF bsdf, DisneyDiffuse diffuse) {
    bsdf.diffuse = diffuse;
    bsdf.nBxDFs++;
    bsdf.attrs |= BSDF_ATTR_DIFFUSE;
}

void Add(inout BSDF bsdf, DisneyFakeSS fakess) {
    bsdf.fakess = fakess;
    bsdf.nBxDFs++;
    bsdf.attrs |= BSDF_ATTR_FAKESS;
}

void Add(inout BSDF bsdf, SpecularTransmission st) {
    bsdf.st = st;
    bsdf.nBxDFs++;
    bsdf.attrs |= BSDF_ATTR_ST;
}

void Add(inout BSDF bsdf, DisneyRetro retro) {
    bsdf.retro = retro;
    bsdf.nBxDFs++;
    bsdf.attrs |= BSDF_ATTR_RETRO;
}

void Add(inout BSDF bsdf, DisneySheen sheen) {
    bsdf.sheen = sheen;
    bsdf.nBxDFs++;
    bsdf.attrs |= BSDF_ATTR_SHEEN;
}

void Add(inout BSDF bsdf, MicrofacetReflection mr) {
    bsdf.mr = mr;
    bsdf.nBxDFs++;
    bsdf.attrs |= BSDF_ATTR_MR;
}

void Add(inout BSDF bsdf, DisneyClearcoat clearcoat) {
    bsdf.clearcoat = clearcoat;
    bsdf.nBxDFs++;
    bsdf.attrs |= BSDF_ATTR_CLEARCOAT;
}

void Add(inout BSDF bsdf, MicrofacetTransmission mt) {
    bsdf.mt = mt;
    bsdf.nBxDFs++;
    bsdf.attrs |= BSDF_ATTR_MT;
}

void Add(inout BSDF bsdf, MicrofacetTransmissionThin mtt) {
    bsdf.mtt = mtt;
    bsdf.nBxDFs++;
    bsdf.attrs |= BSDF_ATTR_MTT;
}

void Add(inout BSDF bsdf, LambertianTransmission lt) {
    bsdf.lt = lt;
    bsdf.nBxDFs++;
    bsdf.attrs |= BSDF_ATTR_LT;
}

vec3 WorldToLocal(BSDF bsdf, vec3 v) {
    return vec3(dot(v, bsdf.ss), dot(v, bsdf.ts), dot(v, bsdf.ns));
}
vec3 LocalToWorld(BSDF bsdf, vec3 v) {
    return mat3(bsdf.ss, bsdf.ts, bsdf.ns) * v;
    // return vec3(ss.x * v.x + ts.x * v.y + ns.x * v.z,
    //                 ss.y * v.x + ts.y * v.y + ns.y * v.z,
    //                 ss.z * v.x + ts.z * v.y + ns.z * v.z);
}

bool HasAttr(BSDF bsdf, uint attr) {
    return (bsdf.attrs & attr) == attr;
}

int NumComponents(BSDF bsdf, uint flags) {
    int num = 0;
    if (HasAttr(bsdf, BSDF_ATTR_DIFFUSE) && 
        MatchesFlags(bsdf.diffuse, flags)) 
        num++;
    if (HasAttr(bsdf, BSDF_ATTR_FAKESS) && 
        MatchesFlags(bsdf.fakess, flags)) 
        num++;
    if (HasAttr(bsdf, BSDF_ATTR_ST) && 
        MatchesFlags(bsdf.st, flags)) 
        num++;
    if (HasAttr(bsdf, BSDF_ATTR_RETRO) && 
        MatchesFlags(bsdf.retro, flags)) 
        num++;
    if (HasAttr(bsdf, BSDF_ATTR_SHEEN) && 
        MatchesFlags(bsdf.sheen, flags)) 
        num++;
    if (HasAttr(bsdf, BSDF_ATTR_MR) && 
        MatchesFlags(bsdf.mr, flags)) 
        num++;
    if (HasAttr(bsdf, BSDF_ATTR_CLEARCOAT) && 
        MatchesFlags(bsdf.clearcoat, flags)) 
        num++;
    if (HasAttr(bsdf, BSDF_ATTR_MT) && 
        MatchesFlags(bsdf.mt, flags)) 
        num++;
    if (HasAttr(bsdf, BSDF_ATTR_MTT) && 
        MatchesFlags(bsdf.mtt, flags)) 
        num++;
    if (HasAttr(bsdf, BSDF_ATTR_LT) && 
        MatchesFlags(bsdf.lt, flags)) 
        num++;
    return num;
}

float bxdfs_Pdf(BSDF bsdf, int i, vec3 wo, vec3 wi) {
    if (i < 0 || i >= bsdf.nBxDFs) return 0;
    if (HasAttr(bsdf, BSDF_ATTR_DIFFUSE) && i-- == 0) {
        return Pdf(bsdf.diffuse, wo, wi);
    }
    if (HasAttr(bsdf, BSDF_ATTR_FAKESS) && i-- == 0) {
        return Pdf(bsdf.fakess, wo, wi);
    }
    if (HasAttr(bsdf, BSDF_ATTR_ST) && i-- == 0) {
        return Pdf(bsdf.st, wo, wi);
    }
    if (HasAttr(bsdf, BSDF_ATTR_RETRO) && i-- == 0) {
        return Pdf(bsdf.retro, wo, wi);
    }
    if (HasAttr(bsdf, BSDF_ATTR_SHEEN) && i-- == 0) {
        return Pdf(bsdf.sheen, wo, wi);
    }
    if (HasAttr(bsdf, BSDF_ATTR_MR) && i-- == 0) {
        return Pdf(bsdf.mr, wo, wi);
    }
    if (HasAttr(bsdf, BSDF_ATTR_CLEARCOAT) && i-- == 0) {
        return Pdf(bsdf.clearcoat, wo, wi);
    }
    if (HasAttr(bsdf, BSDF_ATTR_MT) && i-- == 0) {
        return Pdf(bsdf.mt, wo, wi);
    }
    if (HasAttr(bsdf, BSDF_ATTR_MTT) && i-- == 0) {
        return Pdf(bsdf.mtt, wo, wi);
    }
    if (HasAttr(bsdf, BSDF_ATTR_LT) && i-- == 0) {
        return Pdf(bsdf.lt, wo, wi);
    }
    return 0;
}

vec3 bxdfs_f(BSDF bsdf, int i, vec3 wo, vec3 wi) {
    if (i < 0 || i >= bsdf.nBxDFs) return vec3(0);
    if (HasAttr(bsdf, BSDF_ATTR_DIFFUSE) && i-- == 0) {
        return f(bsdf.diffuse, wo, wi);
    }
    if (HasAttr(bsdf, BSDF_ATTR_FAKESS) && i-- == 0) {
        return f(bsdf.fakess, wo, wi);
    }
    if (HasAttr(bsdf, BSDF_ATTR_ST) && i-- == 0) {
        return f(bsdf.st, wo, wi);
    }
    if (HasAttr(bsdf, BSDF_ATTR_RETRO) && i-- == 0) {
        return f(bsdf.retro, wo, wi);
    }
    if (HasAttr(bsdf, BSDF_ATTR_SHEEN) && i-- == 0) {
        return f(bsdf.sheen, wo, wi);
    }
    if (HasAttr(bsdf, BSDF_ATTR_MR) && i-- == 0) {
        return f(bsdf.mr, wo, wi);
    }
    if (HasAttr(bsdf, BSDF_ATTR_CLEARCOAT) && i-- == 0) {
        return f(bsdf.clearcoat, wo, wi);
    }
    if (HasAttr(bsdf, BSDF_ATTR_MT) && i-- == 0) {
        return f(bsdf.mt, wo, wi);
    }
    if (HasAttr(bsdf, BSDF_ATTR_MTT) && i-- == 0) {
        return f(bsdf.mtt, wo, wi);
    }
    if (HasAttr(bsdf, BSDF_ATTR_LT) && i-- == 0) {
        return f(bsdf.lt, wo, wi);
    }
    return vec3(0);
}

bool bxdfs_MatchesFlags(BSDF bsdf, int i, uint type) {
    if (i < 0 || i >= bsdf.nBxDFs) return false;
    if (HasAttr(bsdf, BSDF_ATTR_DIFFUSE) && i-- == 0) {
        return MatchesFlags(bsdf.diffuse, type);
    }
    if (HasAttr(bsdf, BSDF_ATTR_FAKESS) && i-- == 0) {
        return MatchesFlags(bsdf.fakess, type);
    }
    if (HasAttr(bsdf, BSDF_ATTR_ST) && i-- == 0) {
        return MatchesFlags(bsdf.st, type);
    }
    if (HasAttr(bsdf, BSDF_ATTR_RETRO) && i-- == 0) {
        return MatchesFlags(bsdf.retro, type);
    }
    if (HasAttr(bsdf, BSDF_ATTR_SHEEN) && i-- == 0) {
        return MatchesFlags(bsdf.sheen, type);
    }
    if (HasAttr(bsdf, BSDF_ATTR_MR) && i-- == 0) {
        return MatchesFlags(bsdf.mr, type);
    }
    if (HasAttr(bsdf, BSDF_ATTR_CLEARCOAT) && i-- == 0) {
        return MatchesFlags(bsdf.clearcoat, type);
    }
    if (HasAttr(bsdf, BSDF_ATTR_MT) && i-- == 0) {
        return MatchesFlags(bsdf.mt, type);
    }
    if (HasAttr(bsdf, BSDF_ATTR_MTT) && i-- == 0) {
        return MatchesFlags(bsdf.mtt, type);
    }
    if (HasAttr(bsdf, BSDF_ATTR_LT) && i-- == 0) {
        return MatchesFlags(bsdf.lt, type);
    }
    return false;
}

uint bxdfs_type(BSDF bsdf, int i) {
    if (i < 0 || i >= bsdf.nBxDFs) return 0;
    if (HasAttr(bsdf, BSDF_ATTR_DIFFUSE) && i-- == 0) {
        return bsdf.diffuse.type;
    }
    if (HasAttr(bsdf, BSDF_ATTR_FAKESS) && i-- == 0) {
        return bsdf.fakess.type;
    }
    if (HasAttr(bsdf, BSDF_ATTR_ST) && i-- == 0) {
        return bsdf.st.type;
    }
    if (HasAttr(bsdf, BSDF_ATTR_RETRO) && i-- == 0) {
        return bsdf.retro.type;
    }
    if (HasAttr(bsdf, BSDF_ATTR_SHEEN) && i-- == 0) {
        return bsdf.sheen.type;
    }
    if (HasAttr(bsdf, BSDF_ATTR_MR) && i-- == 0) {
        return bsdf.mr.type;
    }
    if (HasAttr(bsdf, BSDF_ATTR_CLEARCOAT) && i-- == 0) {
        return bsdf.clearcoat.type;
    }
    if (HasAttr(bsdf, BSDF_ATTR_MT) && i-- == 0) {
        return bsdf.mt.type;
    }
    if (HasAttr(bsdf, BSDF_ATTR_MTT) && i-- == 0) {
        return bsdf.mtt.type;
    }
    if (HasAttr(bsdf, BSDF_ATTR_LT) && i-- == 0) {
        return bsdf.lt.type;
    }
    return 0;
}

vec3 bxdfs_Sample_f(BSDF bsdf, int i, vec3 wo, out vec3 wi, vec2 u,
                        out float pdf, inout uint sampledType) {
    if (i < 0 || i >= bsdf.nBxDFs) return vec3(0);
    if (HasAttr(bsdf, BSDF_ATTR_DIFFUSE) && i-- == 0) {
        return Sample_f(bsdf.diffuse, wo, wi, u, pdf, sampledType);
    }
    if (HasAttr(bsdf, BSDF_ATTR_FAKESS) && i-- == 0) {
        return Sample_f(bsdf.fakess, wo, wi, u, pdf, sampledType);
    }
    if (HasAttr(bsdf, BSDF_ATTR_ST) && i-- == 0) {
        return Sample_f(bsdf.st, wo, wi, u, pdf, sampledType);
    }
    if (HasAttr(bsdf, BSDF_ATTR_RETRO) && i-- == 0) {
        return Sample_f(bsdf.retro, wo, wi, u, pdf, sampledType);
    }
    if (HasAttr(bsdf, BSDF_ATTR_SHEEN) && i-- == 0) {
        return Sample_f(bsdf.sheen, wo, wi, u, pdf, sampledType);
    }
    if (HasAttr(bsdf, BSDF_ATTR_MR) && i-- == 0) {
        return Sample_f(bsdf.mr, wo, wi, u, pdf, sampledType);
    }
    if (HasAttr(bsdf, BSDF_ATTR_CLEARCOAT) && i-- == 0) {
        return Sample_f(bsdf.clearcoat, wo, wi, u, pdf, sampledType);
    }
    if (HasAttr(bsdf, BSDF_ATTR_MT) && i-- == 0) {
        return Sample_f(bsdf.mt, wo, wi, u, pdf, sampledType);
    }
    if (HasAttr(bsdf, BSDF_ATTR_MTT) && i-- == 0) {
        return Sample_f(bsdf.mtt, wo, wi, u, pdf, sampledType);
    }
    if (HasAttr(bsdf, BSDF_ATTR_LT) && i-- == 0) {
        return Sample_f(bsdf.lt, wo, wi, u, pdf, sampledType);
    }
    return vec3(0);
}

vec3 f(BSDF bsdf, vec3 woW, vec3 wiW, uint flags) {
    // vec3 wi = WorldToLocal(bsdf, wiW), wo = WorldToLocal(bsdf, woW);
    // if (wo.z == 0) return vec3(0.);
    // bool reflect_ = dot(wiW, bsdf.ng) * dot(woW, bsdf.ng) > 0;
    // vec3 f_ = vec3(0.f);
    // if (HasAttr(bsdf, BSDF_ATTR_DIFFUSE) && 
    //     MatchesFlags(bsdf.diffuse, flags) &&
    //     ((reflect_ && (bsdf.diffuse.type & BSDF_REFLECTION) == BSDF_REFLECTION) ||
    //      (!reflect_ && (bsdf.diffuse.type & BSDF_TRANSMISSION) == BSDF_TRANSMISSION))
    //    ) 
    //     f_ += f(bsdf.diffuse, wo, wi);
    // if (HasAttr(bsdf, BSDF_ATTR_FAKESS) && 
    //     MatchesFlags(bsdf.fakess, flags) &&
    //     ((reflect_ && (bsdf.fakess.type & BSDF_REFLECTION) == BSDF_REFLECTION) ||
    //      (!reflect_ && (bsdf.fakess.type & BSDF_TRANSMISSION) == BSDF_TRANSMISSION))
    //    ) 
    //     f_ += f(bsdf.fakess, wo, wi);
    // if (HasAttr(bsdf, BSDF_ATTR_ST) && 
    //     MatchesFlags(bsdf.st, flags) &&
    //     ((reflect_ && (bsdf.st.type & BSDF_REFLECTION) == BSDF_REFLECTION) ||
    //      (!reflect_ && (bsdf.st.type & BSDF_TRANSMISSION) == BSDF_TRANSMISSION))
    //    ) 
    //     f_ += f(bsdf.st, wo, wi);
    // if (HasAttr(bsdf, BSDF_ATTR_RETRO) && 
    //     MatchesFlags(bsdf.retro, flags) &&
    //     ((reflect_ && (bsdf.retro.type & BSDF_REFLECTION) == BSDF_REFLECTION) ||
    //      (!reflect_ && (bsdf.retro.type & BSDF_TRANSMISSION) == BSDF_TRANSMISSION))
    //    ) 
    //     f_ += f(bsdf.retro, wo, wi);
    // if (HasAttr(bsdf, BSDF_ATTR_SHEEN) && 
    //     MatchesFlags(bsdf.sheen, flags) &&
    //     ((reflect_ && (bsdf.sheen.type & BSDF_REFLECTION) == BSDF_REFLECTION) ||
    //      (!reflect_ && (bsdf.sheen.type & BSDF_TRANSMISSION) == BSDF_TRANSMISSION))
    //    ) 
    //     f_ += f(bsdf.sheen, wo, wi);
    // if (HasAttr(bsdf, BSDF_ATTR_MR) && 
    //     MatchesFlags(bsdf.mr, flags) &&
    //     ((reflect_ && (bsdf.mr.type & BSDF_REFLECTION) == BSDF_REFLECTION) ||
    //      (!reflect_ && (bsdf.mr.type & BSDF_TRANSMISSION) == BSDF_TRANSMISSION))
    //    ) 
    //     f_ += f(bsdf.mr, wo, wi);
    // if (HasAttr(bsdf, BSDF_ATTR_CLEARCOAT) && 
    //     MatchesFlags(bsdf.clearcoat, flags) &&
    //     ((reflect_ && (bsdf.clearcoat.type & BSDF_REFLECTION) == BSDF_REFLECTION) ||
    //      (!reflect_ && (bsdf.clearcoat.type & BSDF_TRANSMISSION) == BSDF_TRANSMISSION))
    //    ) 
    //     f_ += f(bsdf.clearcoat, wo, wi);
    // if (HasAttr(bsdf, BSDF_ATTR_MT) && 
    //     MatchesFlags(bsdf.mt, flags) &&
    //     ((reflect_ && (bsdf.mt.type & BSDF_REFLECTION) == BSDF_REFLECTION) ||
    //      (!reflect_ && (bsdf.mt.type & BSDF_TRANSMISSION) == BSDF_TRANSMISSION))
    //    ) 
    //     f_ += f(bsdf.mt, wo, wi);
    // if (HasAttr(bsdf, BSDF_ATTR_MTT) && 
    //     MatchesFlags(bsdf.mtt, flags) &&
    //     ((reflect_ && (bsdf.mtt.type & BSDF_REFLECTION) == BSDF_REFLECTION) ||
    //      (!reflect_ && (bsdf.mtt.type & BSDF_TRANSMISSION) == BSDF_TRANSMISSION))
    //    ) 
    //     f_ += f(bsdf.mtt, wo, wi);
    // if (HasAttr(bsdf, BSDF_ATTR_LT) && 
    //     MatchesFlags(bsdf.lt, flags) &&
    //     ((reflect_ && (bsdf.lt.type & BSDF_REFLECTION) == BSDF_REFLECTION) ||
    //      (!reflect_ && (bsdf.lt.type & BSDF_TRANSMISSION) == BSDF_TRANSMISSION))
    //    ) 
    //     f_ += f(bsdf.lt, wo, wi);
    // return f_;

    vec3 wi = WorldToLocal(bsdf, wiW), wo = WorldToLocal(bsdf, woW);
    if (wo.z == 0) return vec3(0.);
    bool reflect_ = dot(wiW, bsdf.ng) * dot(woW, bsdf.ng) > 0;
    vec3 f_ = vec3(0.f);
    for (int i = 0; i < bsdf.nBxDFs; ++i)
        if (bxdfs_MatchesFlags(bsdf, i, flags) &&
            ((reflect_ && (bxdfs_type(bsdf, i) & BSDF_REFLECTION) == BSDF_REFLECTION) ||
             (!reflect_ && (bxdfs_type(bsdf, i) & BSDF_TRANSMISSION) == BSDF_TRANSMISSION)))
            f_ += bxdfs_f(bsdf, i, wo, wi);
    return f_;
}

vec3 Sample_f(BSDF bsdf, vec3 woWorld, out vec3 wiWorld,
                        vec2 u, out float pdf, uint type,
                        inout uint sampledType) {
    // Choose which _BxDF_ to sample
    int matchingComps = NumComponents(bsdf, type);
    if (matchingComps == 0) {
        pdf = 0;
        sampledType = 0;
        return vec3(0);
    }
    int comp =
        min(int(floor(u[0] * matchingComps)), matchingComps - 1);

    // Get _BxDF_ pointer for chosen component
    int chosen = comp;
    // Remap _BxDF_ sample _u_ to $[0,1)^2$
    vec2 uRemapped = vec2(min(u[0] * matchingComps - comp, OneMinusEpsilon),
                      u[1]);

    // Sample chosen _BxDF_
    vec3 wi, wo = WorldToLocal(bsdf, woWorld);
    if (wo.z == 0) return vec3(0.);
    pdf = 0;
    uint bxdf_type = bxdfs_type(bsdf, chosen);
// wiWorld = woWorld;
// pdf = 1;
// if ((bxdf_type & BSDF_TRANSMISSION) == 0) 
//     return vec3(0);
// else 
//     return vec3(chosen * matchingComps);
    sampledType = bxdf_type;
    // if ((bxdf_type & BSDF_TRANSMISSION) > 0) {
    //     pdf = 0.1;
    //     wi = wo;
    //     return vec3(0,0,matchingComps);
    // }
    vec3 f_ = bxdfs_Sample_f(bsdf, chosen, wo, wi, uRemapped, pdf, sampledType);
// wiWorld = woWorld;
// pdf = 1;
// return f_ * 2;
    if (pdf == 0) {
        sampledType = 0;
        return vec3(0);
    }
    wiWorld = LocalToWorld(bsdf, wi);

    // Compute overall PDF with all matching _BxDF_s
    if (((bxdf_type & BSDF_SPECULAR) != BSDF_SPECULAR) && 
        matchingComps > 1)
        for (int i = 0; i < bsdf.nBxDFs; ++i)
            if (i != chosen && bxdfs_MatchesFlags(bsdf, i, type))
                pdf += bxdfs_Pdf(bsdf, i, wo, wi);
    if (matchingComps > 1) pdf /= matchingComps;

    // Compute value of BSDF for sampled direction
    if ((bxdf_type & BSDF_SPECULAR) != BSDF_SPECULAR) {
        bool reflect_ = dot(wiWorld, bsdf.ng) * dot(woWorld, bsdf.ng) > 0;
        f_ = vec3(0.);
        for (int i = 0; i < bsdf.nBxDFs; ++i)
            if (bxdfs_MatchesFlags(bsdf, i, type) &&
                ((reflect_ && (bxdfs_type(bsdf, i) & BSDF_REFLECTION) == BSDF_REFLECTION) ||
                 (!reflect_ && (bxdfs_type(bsdf, i) & BSDF_TRANSMISSION) == BSDF_TRANSMISSION)))
                f_ += bxdfs_f(bsdf, i, wo, wi);
    }
    return f_;
}

float Pdf(BSDF bsdf, vec3 woWorld, vec3 wiWorld, uint flags) {
    if (bsdf.nBxDFs == 0.f) return 0.f;
    vec3 wo = WorldToLocal(bsdf, woWorld), wi = WorldToLocal(bsdf, wiWorld);
    if (wo.z == 0) return 0.;
    float pdf = 0.f;
    int matchingComps = 0;
    for (int i = 0; i < bsdf.nBxDFs; ++i)
        if (bxdfs_MatchesFlags(bsdf, i, flags)) {
            ++matchingComps;
            pdf += bxdfs_Pdf(bsdf, i, wo, wi);
        }
    float v = matchingComps > 0 ? pdf / matchingComps : 0.f;
    return v;
}

