#include "yin.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

/**
 * Step 1: Calculates the squared difference of the signal with a shifted
 * version of itself.
 *
 * This is the Yin algorithms tweak on auto-correlation. Read
 * http://audition.ens.fr/adc/pdf/2002_JASA_YIN.pdf
 * for more details on what is in here and why it's done this way.
 */
void yin_auto_correlation(Yin PTR(yin), int16_t const PTR(buffer)) {
  // Calculate the difference for difference shift values (tau) for the half of
  // the samples
  for (size_t i = 0; i < yin->half_num_samples; ++i) {
    if ((int)i == yin->correlation_index) {
      for (size_t j = 0; j < yin->half_num_samples; ++j) {
        yin->auto_correlation_buffer[j] = (float)(buffer[j] - buffer[j + i]) / 32767.f;
      }
    }
    /* Take the difference of the signal with a shifted version of itself, then
     * square it.
     * (This is the Yin algorithm's tweak on auto-correlation) */
    yin->buffer[i] = 0;
    for (size_t j = 0; j < yin->half_num_samples; ++j) {
      float delta = (float)(buffer[j] - buffer[j + i]);
      yin->buffer[i] += delta * delta;
    }
  }
}


/**
 * Step 2: Calculate the cumulative mean on the normalised difference
 * calculated in step 1
 *
 * This goes through the Yin auto-correlation values and finds out roughly
 * where shift is which produced the smallest difference.
 */
void yin_cumulative_mean_normalized_difference(Yin PTR(yin)) {
  yin->buffer[0] = 1;

  // Sum all the values in the auto-correlation buffer and nomalise the result,
  // replacing the value in the auto-correlation buffer with a cumulative mean
  // of the normalised difference
  float cumulative_sum = 0;
  for (size_t i = 1; i < yin->half_num_samples; ++i) {
    cumulative_sum += yin->buffer[i];
    yin->buffer[i] *= (float)i / cumulative_sum;
  }
}

/**
 * Step 3: Search through the normalised cumulative mean array and find values
 * that are over the threshold
 *
 * @return Shift (tau) which caused the best approximate auto-correlation. -1
 * if no suitable value is found over the threshold.
 */
int16_t yin_absolute_threshold(Yin PTR(yin)) {
  // Search through the array of cumulative mean values, and look for ones that
  // are over the threshold. The first two positions in yinBuffer are always so
  // start at the third (index 2)

  const int16_t len = (int16_t)yin->half_num_samples;
  int16_t i = 2;
  float* buffer = yin->buffer;
  for (; i < len; ++i) {
    if (buffer[i] < yin->threshold) {
      while (i + 1 < len && buffer[i + 1] < buffer[i]) ++i;
      /* found tau, exit loop and return
       * store the probability
       * From the YIN paper: The yin->threshold determines the list of
       * candidates admitted to the set, and can be interpreted as the
       * proportion of aperiodic power tolerated
       * within a periodic signal.
       *
       * Since we want the periodicity and and not aperiodicity:
       * periodicity = 1 - aperiodicity */
      yin->probability = 1 - buffer[i];
      break;
    }
  }

  /* if no pitch found, tau => -1 */
  if (i == yin->half_num_samples || buffer[i] >= yin->threshold) {
    i = -1;
    yin->probability = 0;
  }

  return i;
}

/**
 * Step 4: Interpolate the shift value (tau) to improve the pitch estimate.
 *
 * The 'best' shift value for auto-correlation is most likely not an interger
 * shift of the signal. As we only auto-correlation using integer shifts we
 * should check that there isn't a better fractional shift value.
 */
float yin_parabolic_interpolation(Yin* yin, int16_t tauEstimate) {
  // Calculate the first polynomial coeffcient based on the current estimate of
  // tau.
  int16_t x0 = (int16_t)(tauEstimate < 1 ? tauEstimate : tauEstimate - 1);
  int16_t x2;
  if (tauEstimate + 1 < yin->half_num_samples) {
    x2 = (int16_t)(tauEstimate + 1);
  } else {
    x2 = tauEstimate;
  }

  // Algorithm to parabolically interpolate the shift value tau to find a
  // better estimate.
  float betterTau;
  if (x0 == tauEstimate) {
    if (yin->buffer[tauEstimate] <= yin->buffer[x2]) {
      betterTau = tauEstimate;
    } else {
      betterTau = x2;
    }
  } else if (x2 == tauEstimate) {
    if (yin->buffer[tauEstimate] <= yin->buffer[x0]) {
      betterTau = tauEstimate;
    } else {
      betterTau = x0;
    }
  } else {
    float s0, s1, s2;
    s0 = yin->buffer[x0];
    s1 = yin->buffer[tauEstimate];
    s2 = yin->buffer[x2];
    // fixed AUBIO implementation, thanks to Karl Helgason:
    // (2.0f * s1 - s2 - s0) was incorrectly multiplied with -1
    betterTau = (float)tauEstimate + (s2 - s0) / (2 * (2 * s1 - s2 - s0));
  }

  return betterTau;
}


/* ----------------------------------------------------------------------------
 * ---------------------------------------------------------- PUBLIC FUNCTIONS
 * --------------------------------------------------------------------------*/
void yin_init(
  Yin*     yin,
  uint16_t num_samples,
  float    sampling_frequency,
  float    threshold
) {
  // Initialise the fields of the Yin structure passed in.
  yin->num_samples        = num_samples;
  yin->half_num_samples   = num_samples / 2;
  yin->threshold          = threshold;
  yin->sampling_frequency = sampling_frequency;
  yin->probability        = 0.0f;
  yin->correlation_index  = -1;

  // Allocate dynamic memory
  size_t buffer_size = yin->half_num_samples * sizeof(float);
  yin->buffer                  = malloc(buffer_size);
  yin->auto_correlation_buffer = malloc(buffer_size);
  memset(yin->buffer, 0, buffer_size);
}

void destroy_yin(Yin PTR(yin)) {
  free(yin->buffer);
  free(yin->auto_correlation_buffer);
  yin->buffer                  = NULL;
  yin->auto_correlation_buffer = NULL;
}

float yin_get_pitch(Yin PTR(yin), int16_t PTR(buffer)) {
  float pitch_in_hertz = -1;

  yin_auto_correlation(yin, buffer);
  yin_cumulative_mean_normalized_difference(yin);
  int16_t tau_estimate = yin_absolute_threshold(yin);
  if (tau_estimate != -1) {
    float yin_pbi = yin_parabolic_interpolation(yin, tau_estimate);
    pitch_in_hertz = yin->sampling_frequency / yin_pbi;
  }

  return pitch_in_hertz;
}