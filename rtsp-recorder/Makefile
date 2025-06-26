.PHONY: build-deb clean

export PACKAGE_NAME=rtsp-recorder

default: info

info:
	echo "Info for Makefile"

build-deb: 	
	dpkg-buildpackage --no-sign
	mkdir -p target
	mv ../${PACKAGE_NAME}_* target/

clean:
	rm -rf dist
	rm -rf target
	rm -rf *.egg-info
	rm -rf debian/.debhelper
	rm -f debian/files
	rm -f debian/*.substvars
	rm -f debian/*.log
	rm -f debian/debhelper-build-stamp
	rm -f debian/${PACKAGE_NAME}.postinst.debhelper
	rm -f debian/${PACKAGE_NAME}.postrm.debhelper
	rm -f debian/${PACKAGE_NAME}.prerm.debhelper
	rm -rf debian/${PACKAGE_NAME}
	rm -f *.tar.gz