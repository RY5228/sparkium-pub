#include "constants.glsl"
#include "bsdf_func.glsl"
#include "sampling.glsl"
#include "diffuse.glsl"
#include "fakess.glsl"
#include "bssrdf.glsl"
#include "retro.glsl"
#include "sheen.glsl"
#include "clearcoat.glsl"
#include "fresnel.glsl"
#include "distribution.glsl"
#include "specular_transmission.glsl"
#include "microfacet_reflection.glsl"
#include "microfacet_transmission.glsl"
#include "lambertian_transmission.glsl"
#include "bsdf.glsl"

void ComputeScatteringFunctions(out BSDF bsdf, out DisneyBSSRDF bssrdf, 
        HitRecord hit_record, uint mode) {
    Constructor(bsdf, hit_record.normal, hit_record.geometry_normal, hit_record.tangent);
    vec3 c = hit_record.base_color;
    float metallicWeight = hit_record.metallic;
    float e = hit_record.ior;
    float strans = hit_record.specTrans;
    float diffuseWeight = (1 - metallicWeight) * (1 - strans);
    float dt = hit_record.diffTrans / 2;
    float rough = hit_record.roughness;
    float lum = c.y;
    // normalize lum. to isolate hue+sat
    vec3 Ctint = lum > 0 ? (c / lum) : vec3(1.);

    float sheenWeight = hit_record.sheen;
    vec3 Csheen;
    if (sheenWeight > 0) {
        float stint = hit_record.sheenTint;
        Csheen = Lerp(stint, vec3(1.), Ctint);
    }

    bool thin = hit_record.thin;

    if (diffuseWeight > 0) {
        if (thin) {
            float flatness = hit_record.flatness;
            // Blend between DisneyDiffuse and fake subsurface based on
            // flatness.  Additionally, weight using diffTrans.
            DisneyDiffuse diffuse;
            Constructor(diffuse, diffuseWeight * (1 - flatness) * (1 - dt) * c);
            Add(bsdf, diffuse);
            DisneyFakeSS fakess;
            Constructor(fakess, diffuseWeight * flatness * (1 - dt) * c, rough);
            Add(bsdf, fakess);
        } else {
            vec3 sd = hit_record.scatterDistance;
            if (sd == vec3(0)) {
                // No subsurface scattering; use regular (Fresnel modified)
                // diffuse.
                DisneyDiffuse diffuse;
                Constructor(diffuse, diffuseWeight * c);
                Add(bsdf, diffuse);
            }
            else {
                // Use a BSSRDF instead.
                SpecularTransmission st;
                Constructor(st, vec3(1.f), 1.f, e, mode);
                Add(bsdf, st);
                // si->bssrdf = ARENA_ALLOC(arena, DisneyBSSRDF)(
                //     c * diffuseWeight, sd, *si, e, this, mode);
                bssrdf.a = 0;
            }
        }

        // Retro-reflection.
        DisneyRetro retro;
        Constructor(retro, diffuseWeight * c, rough);
        Add(bsdf, retro);

        // Sheen (if enabled)
        if (sheenWeight > 0) {
            DisneySheen sheen;
            Constructor(sheen, diffuseWeight * sheenWeight * Csheen);
            Add(bsdf, sheen);
        }
    }

    // Create the microfacet distribution for metallic and/or specular
    // transmission.
    float anisotropic = hit_record.anisotropy;
    float aspect = sqrt(1 - anisotropic * .9);
    float ax = max(float(.001), sqr(rough) / aspect);
    float ay = max(float(.001), sqr(rough) * aspect);
    DisneyMicrofacetDistribution distrib; 
    Constructor(distrib, ax, ay);

    // Specular is Trowbridge-Reitz with a modified Fresnel function.
    float specTint = hit_record.specularTint;
    vec3 Cspec0 =
        Lerp(metallicWeight,
             SchlickR0FromEta(e) * Lerp(specTint, vec3(1.), Ctint), c);
    DisneyFresnel fresnel;
    Constructor(fresnel, Cspec0, metallicWeight, e);
    MicrofacetReflection mr;
    Constructor(mr, vec3(1.), distrib, fresnel);
    Add(bsdf, mr);

    // Clearcoat
    float cc = hit_record.clearcoat;
    if (cc > 0) {
        float clearcoatGloss = hit_record.clearcoatGloss;
        DisneyClearcoat clearcoat;
        Constructor(clearcoat, cc, Lerp(clearcoatGloss, .1, .001));
        Add(bsdf, clearcoat);
    }

    // BTDF
    if (strans > 0) {
        // Walter et al's model, with the provided transmissive term scaled
        // by sqrt(color), so that after two refractions, we're back to the
        // provided color.
        vec3 T = (1 - metallicWeight) * strans * sqrt(c);
        if (thin) {
            // Scale roughness based on IOR (Burley 2015, Figure 15).
            float rscaled = (0.65f * e - 0.35f) * rough;
            float ax = max(float(.001), sqr(rscaled) / aspect);
            float ay = max(float(.001), sqr(rscaled) * aspect);
            TrowbridgeReitzDistribution scaledDistrib;
            Constructor(scaledDistrib, ax, ay);
            MicrofacetTransmissionThin mtt;
            Constructor(mtt, T, scaledDistrib, 1., e, mode);
            Add(bsdf, mtt);
        } else {
            MicrofacetTransmission mt;
            Constructor(mt, T, distrib, 1., e, mode);
            Add(bsdf, mt);
        }
    }
    if (thin) {
        // Lambertian, weighted by (1 - diffTrans)
        LambertianTransmission lt;
        Constructor(lt, dt * c);
        Add(bsdf, lt);
    }
}

