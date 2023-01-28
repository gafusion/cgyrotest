all:
	cd shared ; make
	cd neo ; make
	cd vgen ; make
	cd tglf ; make
	cd cgyro ; make
	cd tgyro ; make
	cd f2py ; make
	@echo "GACODE build done"

clean:
	cd shared ; make clean
	cd neo ; make clean
	cd vgen ; make clean
	cd tglf ; make clean
	cd cgyro ; make clean
	cd tgyro ; make clean
	cd f2py ; make clean
	rm -f f2py/*/*.pyc
	rm -f f2py/*.pyc
	rm -f f2py/pygacode/*/*.pyc
	rm -rf f2py/*/__pycache__
	rm -rf f2py/__pycache__
	rm -rf f2py/pygacode/*/__pycache__
	rm -f modules/*genmod*
	rm -f *.log
	rm -rf *regression_test/
	rm -rf python
