// SSHT package to perform spin spherical harmonic transforms
// Copyright (C) 2011  Jason McEwen
// See LICENSE.txt for license details

/*! 
 * \file ssht_test.c
 * Applies SSHT algorithms to perform inverse and forward spherical
 * harmonic transforms (respectively) to check that the original
 * signal is reconstructed exactly (to numerical precision).  Test is
 * performed on a random signal with harmonic coefficients uniformly
 * sampled from (-1,1).
 *
 * Usage: ssht_test B spin, e.g. ssht_test 64 2
 *
 * \author <a href="http://www.jasonmcewen.org">Jason McEwen</a>
 */

#include <stdio.h>
#include <stdlib.h>
#include <complex.h>
#include <fftw3.h>  // Must be before fftw3.h
#include <time.h>

#include <b3slep_sampling.h>

int main(int argc, char *argv[]) {


  printf("Hello\n");


  printf("t2theta = %f\n", ssht_sampling_mw_t2theta(0, 128));


  return 0;
}

