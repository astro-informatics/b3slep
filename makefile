# ======== COMPILER ========

CC      = gcc
OPT	= -Wall -O3 -DB3SLEP_VERSION=\"0.1\" -DB3SLEP_BUILD=\"`svnversion -n .`\"
#OPT	= -Wall -g -DB3SLEP_VERSION=\"1.0b1\" -DB3SLEP_BUILD=\"`svnversion -n .`\"


# ======== LINKS ========

UNAME := $(shell uname)
PROGDIR = ..

ifeq ($(UNAME), Linux)
  MLAB		= /usr/local/MATLAB/R2011b
  MLABINC	= ${MLAB}/extern/include
  MLABLIB	= ${MLAB}/extern/lib

  MEXEXT	= mexa64
  MEX 		= ${MLAB}/bin/mex
  MEXFLAGS	= -cxx
endif
ifeq ($(UNAME), Darwin)
  MLAB		= /Applications/MATLAB_R2011b.app
  MLABINC	= ${MLAB}/extern/include
  MLABLIB	= ${MLAB}/extern/lib

  MEXEXT	= mexmaci64
  MEX 		= ${MLAB}/bin/mex
  MEXFLAGS	= -cxx
endif

B3SLEPDIR  = $(PROGDIR)/b3slep
B3SLEPLIB  = $(B3SLEPDIR)/lib/c
B3SLEPLIBNM= b3slep
B3SLEPSRC  = $(B3SLEPDIR)/src/c
B3SLEPBIN  = $(B3SLEPDIR)/bin/c
B3SLEPOBJ  = $(B3SLEPSRC)
B3SLEPINC  = $(B3SLEPDIR)/include/c
B3SLEPDOC  = $(B3SLEPDIR)/doc/c

ifeq ($(UNAME), Linux)
  FFTWDIR      = $(PROGDIR)/fftw-3.2.2_fPIC
endif
ifeq ($(UNAME), Darwin)
  FFTWDIR      = $(PROGDIR)/fftw
endif

SSHTDIR  = $(PROGDIR)/ssht
SSHTLIB = $(SSHTDIR)/lib/c
SSHTINC = $(SSHTDIR)/include/c
SSHTLIBNM= ssht

FLAGDIR  = $(PROGDIR)/flag
FLAGLIB = $(FLAGDIR)/lib
FLAGINC = $(FLAGDIR)/include
FLAGLIBNM= flag

FFTWINC	     = $(FFTWDIR)/include
FFTWLIB      = $(FFTWDIR)/lib
FFTWLIBNM    = fftw3

B3SLEPSRCMAT	= $(B3SLEPDIR)/src/matlab
B3SLEPOBJMAT  	= $(B3SLEPSRCMAT)
B3SLEPOBJMEX  	= $(B3SLEPSRCMAT)


# ======== SOURCE LOCATIONS ========

vpath %.c $(B3SLEPSRC)
vpath %.h $(B3SLEPINC)
vpath %_mex.c $(B3SLEPSRCMAT)


# ======== FFFLAGS ========

FFLAGS  = -I$(FFTWINC) -I$(B3SLEPINC) -I$(SSHTINC) -I$(FLAGINC)
ifeq ($(UNAME), Linux)
  # Add -fPIC flag (required for mex build).
  # (Note that fftw must also be built with -fPIC.)
  FFLAGS += -fPIC
endif

# ======== LDFLAGS ========

LDFLAGS = -L$(B3SLEPLIB) -l$(B3SLEPLIBNM) \
          -L$(FLAGLIB) -l$(FLAGLIBNM) \
          -L$(SSHTLIB) -l$(SSHTLIBNM) \
          -L$(FFTWLIB) -l$(FFTWLIBNM) -lm

LDFLAGSMEX = -L$(B3SLEPLIB) -l$(B3SLEPLIBNM) \
             -L$(FLAGLIB) -l$(FLAGLIBNM) \
             -L$(SSHTLIB) -l$(SSHTLIBNM) \
             -L$(FFTWLIB) -l$(FFTWLIBNM)


# ======== OBJECT FILES TO MAKE ========

B3SLEPOBJS = $(B3SLEPOBJ)/b3slep_sampling.o    

B3SLEPHEADERS = b3slep_types.h     \
              b3slep_error.h     \
	      b3slep_sampling.h  

#B3SLEPOBJSMAT = $(B3SLEPOBJMAT)/ssht_sampling_mex.o        \
#              $(B3SLEPOBJMAT)/ssht_forward_mex.o         \
#              $(B3SLEPOBJMAT)/ssht_inverse_mex.o         \
#              $(B3SLEPOBJMAT)/ssht_forward_adjoint_mex.o \
#              $(B3SLEPOBJMAT)/ssht_inverse_adjoint_mex.o

#B3SLEPOBJSMEX = $(B3SLEPOBJMEX)/ssht_sampling_mex.$(MEXEXT)        \
#              $(B3SLEPOBJMEX)/ssht_forward_mex.$(MEXEXT)         \
#              $(B3SLEPOBJMEX)/ssht_inverse_mex.$(MEXEXT)         \
#              $(B3SLEPOBJMEX)/ssht_forward_adjoint_mex.$(MEXEXT) \
#              $(B3SLEPOBJMEX)/ssht_inverse_adjoint_mex.$(MEXEXT)


# ======== MAKE RULES ========

$(B3SLEPOBJ)/%.o: %.c $(B3SLEPHEADERS)
	$(CC) $(OPT) $(FFLAGS) -c $< -o $@

.PHONY: default
default: lib test about

.PHONY: test
test: $(B3SLEPBIN)/b3slep_test about
$(B3SLEPBIN)/b3slep_test: $(B3SLEPOBJ)/b3slep_test.o $(B3SLEPLIB)/lib$(B3SLEPLIBNM).a
	$(CC) $(OPT) $< -o $(B3SLEPBIN)/b3slep_test $(LDFLAGS) 

.PHONY: about
about: $(B3SLEPBIN)/b3slep_about
$(B3SLEPBIN)/b3slep_about: $(B3SLEPOBJ)/b3slep_about.o 
	$(CC) $(OPT) $< -o $(B3SLEPBIN)/b3slep_about

.PHONY: runtest
runtest: test
	$(B3SLEPBIN)/b3slep_test 64 0

.PHONY: all
all: lib test about matlab


# Library

.PHONY: lib
lib: $(B3SLEPLIB)/lib$(B3SLEPLIBNM).a
$(B3SLEPLIB)/lib$(B3SLEPLIBNM).a: $(B3SLEPOBJS)
	ar -r $(B3SLEPLIB)/lib$(B3SLEPLIBNM).a $(B3SLEPOBJS)


# Matlab

$(B3SLEPOBJMAT)/%_mex.o: %_mex.c $(B3SLEPLIB)/lib$(B3SLEPLIBNM).a
	$(CC) $(OPT) $(FFLAGS) -c $< -o $@ -I${MLABINC} 

$(B3SLEPOBJMEX)/%_mex.$(MEXEXT): $(B3SLEPOBJMAT)/%_mex.o $(B3SLEPLIB)/lib$(B3SLEPLIBNM).a
	$(MEX) $< -o $@ $(LDFLAGSMEX) $(MEXFLAGS) -L$(MLABLIB)

.PHONY: matlab
matlab: $(B3SLEPOBJSMEX)


# Documentation 

.PHONY: doc
doc:
	doxygen $(B3SLEPSRC)/doxygen.config
.PHONY: cleandoc
cleandoc:
	rm -f $(B3SLEPDOC)/html/*


# Cleaning up

.PHONY: clean
clean:	tidy
	rm -f $(B3SLEPOBJ)/*.o
	rm -f $(B3SLEPLIB)/lib$(B3SLEPLIBNM).a
	rm -f $(B3SLEPBIN)/b3slep_test
	rm -f $(B3SLEPBIN)/b3slep_about
	rm -f $(B3SLEPOBJMAT)/*.o
	rm -f $(B3SLEPOBJMEX)/*.$(MEXEXT)

.PHONY: tidy
tidy:
	rm -f *~ 

.PHONY: cleanall
cleanall: clean cleandoc