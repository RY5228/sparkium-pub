#pragma once

namespace sparks {
struct RendererSettings {
  int num_samples{1};
  int num_bounces{16};
  float rrThreshold{0.8f};
};
}  // namespace sparks
