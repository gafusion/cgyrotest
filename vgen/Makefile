#----------------------------
# Toplevel makefile for vgen
#----------------------------

include ${GACODE_ROOT}/platform/build/make.inc.${GACODE_PLATFORM}

export EXTRA_LIBS = \
	${GACODE_ROOT}/neo/src/neo_lib.a \
	${GACODE_ROOT}/f2py/expro/expro_lib.a \
	${GACODE_ROOT}/f2py/geo/geo_lib.a \
	${GACODE_ROOT}/shared/math/math_lib.a \
	${GACODE_ROOT}/shared/UMFPACK/UMFPACK_lib.a \
	${GACODE_ROOT}/shared/nclass/nclass_lib.a

all:
	cd ${GACODE_ROOT}/neo ; make
	cd src ; make

clean:
	cd src ; make clean

.IGNORE:
