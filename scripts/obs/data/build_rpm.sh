#!/bin/sh -ex

if ! [ -d /home/$USER/rpmbuild/SOURCES ]; then
	set +x
	echo "ERROR: rpmdev-setuptree did not run"
	echo "If this is an rpm based system and you want to build the package"
	echo "here, run rpmdev-setuptree. Otherwise consider building the"
	echo "package in docker (-d)."
	exit 1
fi

yum_builddep="yum-builddep"
if [ -n "$INSIDE_DOCKER" ]; then
	yum_builddep="yum-builddep -y"
fi

spec="$(basename "$(find _temp/srcpkgs/"$PACKAGE" -name '*.spec')")"

su $USER -c "cp _temp/srcpkgs/$PACKAGE/$spec ~/rpmbuild/SPECS"
su $USER -c "cp _temp/srcpkgs/$PACKAGE/*.tar.* ~/rpmbuild/SOURCES"
su $USER -c "cp _temp/srcpkgs/$PACKAGE/rpmlintrc ~/rpmbuild/SOURCES"

$yum_builddep "/home/$USER/rpmbuild/SPECS/$spec"

su $USER -c "rpmbuild -bb ~/rpmbuild/SPECS/$spec"
