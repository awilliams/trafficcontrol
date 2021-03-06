#!/bin/bash
#
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#----------------------------------------
function checkEnvironment() {
	echo "Verifying the build configuration environment."
	local script=$(readlink -f "$0")
	local scriptdir=$(dirname "$script")
	export TR_DIR=$(dirname "$scriptdir")
	export TC_DIR=$(dirname "$TR_DIR")
	functions_sh="$TC_DIR/build/functions.sh"
	if [[ ! -r $functions_sh ]]; then
		echo "Error: Can't find $functions_sh"
		exit 1
	fi
	. "$functions_sh"

	#
	# get traffic_control src path -- relative to build_rpm.sh script
	export PACKAGE="tomcat"
	export WORKSPACE=${WORKSPACE:-$TC_DIR}
	export RPMBUILD="$WORKSPACE/rpmbuild"
	export DIST="$WORKSPACE/dist"
	export RPM="${PACKAGE}-${TOMCAT_VERSION}.${TOMCAT_RELEASE}-${BUILD_NUMBER}.${RHEL_VERSION}.x86_64.rpm"

	echo "=================================================="
	echo "WORKSPACE: $WORKSPACE"
	echo "TOMCAT_RELEASE: $TOMCAT_RELEASE" 	#defined in traffic_router
	echo "TOMCAT_VERSION: $TOMCAT_VERSION"	#defined in traffic_router
	echo "BUILD_NUMBER: $BUILD_NUMBER"		#defined in traffic_router
	echo "BUILD_LOCK: $BUILD_LOCK"			#defined in traffic_router
	echo "RPM: $RPM"
	echo "--------------------------------------------------"
}

# ---------------------------------------
function initBuildArea() {
        echo "Initializing the build area."
        mkdir -p "$RPMBUILD"/{SPECS,SOURCES,RPMS,SRPMS,BUILD,BUILDROOT} || { echo "Could not create $RPMBUILD: $?"; exit 1; }
        export VERSION=$TOMCAT_VERSION
        export RELEASE=$TOMCAT_RELEASE

        echo "Downloading Tomcat $VERSION.$RELEASE..."
        curl -fo "$RPMBUILD"/SOURCES/apache-tomcat-$VERSION.$RELEASE.tar.gz https://archive.apache.org/dist/tomcat/tomcat-8/v$VERSION.$RELEASE/bin/apache-tomcat-$VERSION.$RELEASE.tar.gz || \
        { echo "Could not download Tomcat $VERSION.$RELEASE: $?"; exit 1; }

        cp "$TR_DIR/tomcat-rpm/tomcat.service" "$RPMBUILD/SOURCES/" || { echo "Could not copy source files: $?"; exit 1; }
        cp "$TR_DIR/tomcat-rpm/tomcat.spec" "$RPMBUILD/SPECS/" || { echo "Could not copy spec files: $?"; exit 1; }

        echo "The build area has been initialized."
}

#----------------------------------------
function buildRpmTomcat () {
	export SPEC_FILE_NAME=tomcat.spec
	buildRpmForEl 7
}

function buildRpmForEl () {
        echo "Building the rpm for "$RHEL_VERSION"."

        cd $RPMBUILD
        rpmbuild --define "_topdir $(pwd)" \
                 --define "build_number $BUILD_NUMBER.$RHEL_VERSION" \
                 --define "tomcat_version $TOMCAT_VERSION.$TOMCAT_RELEASE" \
                 -ba SPECS/$SPEC_FILE_NAME || \
                 { echo "RPM BUILD FAILED: $?"; exit 1; }
        local rpm=$(find ./RPMS -name $RPM)
        if [[ -z $rpm ]]; then
                echo "Could not find rpm file $RPM in $(pwd)"
                exit 1;
        fi
        echo "========================================================================================"
        echo "RPM BUILD SUCCEEDED, See $DIST/$RPM for the newly built rpm."
        echo "========================================================================================"
        echo
        mkdir -p "$DIST" || { echo "Could not create $DIST: $?"; exit 1; }

        cp "$rpm" "$DIST/." || { echo "Could not copy $rpm to $DIST: $?"; exit 1; }
}

checkEnvironment
initBuildArea
buildRpmTomcat
