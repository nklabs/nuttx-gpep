#!/bin/bash
# build_ara_image.sh
#
# Copyright (c) 2015 Google, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its
# contributors may be used to endorse or promote products derived from this
# software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# ---------------------------------------------------------------
# 2015-03-25 - darryln - adapted from nuttx/tools/configure.sh
# ---------------------------------------------------------------

# define exit error codes
ARA_BUILD_CONFIG_ERR_BAD_PARAMS=1
ARA_BUILD_CONFIG_ERR_NO_NUTTX_TOPDIR=2
ARA_BUILD_CONFIG_ERR_CONFIG_NOT_FOUND=3
ARA_BUILD_CONFIG_ERR_CONFIG_COPY_FAILED=4

# Other build configuration.
ARA_MAKE_PARALLEL=1            # controls make's -j flag
ARA_MAKE_ALWAYS=""             # controls make's -B (--always-make) flag

canonicalize() {
    TARGET_FILE=$1

    cd `dirname $TARGET_FILE`
    TARGET_FILE=`basename $TARGET_FILE`

    # Iterate down a (possible) chain of symlinks
    while [ -L "$TARGET_FILE" ]
    do
        TARGET_FILE=`readlink $TARGET_FILE`
        cd `dirname $TARGET_FILE`
        TARGET_FILE=`basename $TARGET_FILE`
    done

    # Compute the canonicalized name by finding the physical path
    # for the directory we're in and appending the target file.
    PHYS_DIR=`pwd -P`
    RESULT=$PHYS_DIR/$TARGET_FILE
    echo $RESULT
}

echo "Project Ara firmware image builder"

USAGE="

USAGE:
    (1) rebuild specific image config
        ${0} [-j N] [-B] <config-path> <build-name>
    (2) rebuild all image configs under configs/ara
        ${0} [-j N] [-B] all

Options:
  -j N: do a parallel build with N processes
  -B  : --always-build

Arguments:
  <config-path> ...
  <build-name> ...

"

buildall=0

while getopts "j:B" opt; do
    case $opt in
        j)
            ARA_MAKE_PARALLEL=${OPTARG}
            echo "Using make option: '-j $OPTARG'"
            ;;
        B)
            ARA_MAKE_ALWAYS="-B"
            echo "Using make option: '--always-build'"
            ;;
        \?)
            echo "Unknown option: -$OPTARG." >&2
            echo $USAGE
            exit $ARA_BUILD_CONFIG_ERR_BAD_PARAMS
            ;;
        :)
            echo "Missing required argument for -$OPTARG." >&2
            echo $USAGE
            exit $ARA_BUILD_CONFIG_ERR_BAD_PARAMS
            ;;
    esac
done
shift $((OPTIND-1))

# determine NuttX top level folder absolute path
TOPDIR="`dirname \"$BASH_SOURCE\"`"  # relative
TOPDIR=$(canonicalize "`( cd \"$TOPDIR/nuttx\" && pwd )`")  # absolutized and normalized
if [ -z "$TOPDIR" ] ; then
  # error; for some reason, the path is not accessible
  # to the script (e.g. permissions)
  echo "Can't determine NuttX top level folder, fatal."
  exit $ARA_BUILD_CONFIG_ERR_NO_NUTTX_TOPDIR
fi

build_image_from_defconfig() {
  # configpath, defconfigFile, buildname, buildbase
  # must be defined on entry

  echo "Build config file   : $defconfigFile"
  echo "Build name          : '$buildname'"

  # define paths used during build process
  ARA_BUILD_CONFIG_PATH="$buildbase/$buildname/config"
  ARA_BUILD_IMAGE_PATH="$buildbase/$buildname/image"
  ARA_BUILD_TOPDIR="$buildbase/$buildname"

  echo "Build output folder : $ARA_BUILD_TOPDIR"
  echo "Image output folder : $ARA_BUILD_IMAGE_PATH"

  # delete build tree if it already exists
  if [ -d $ARA_BUILD_TOPDIR ] ; then
    rm -rf $ARA_BUILD_TOPDIR
  fi

  # create folder structure in build output tree
  mkdir -p "$ARA_BUILD_CONFIG_PATH"
  mkdir -p "$ARA_BUILD_IMAGE_PATH"
  mkdir -p "$ARA_BUILD_TOPDIR"

  # Copy nuttx tree to build tree
  cp -r $TOPDIR/../nuttx $ARA_BUILD_TOPDIR/nuttx
  cp -r $TOPDIR/../apps $ARA_BUILD_TOPDIR/apps
  cp -r $TOPDIR/../misc $ARA_BUILD_TOPDIR/misc
  cp -r $TOPDIR/../NxWidgets $ARA_BUILD_TOPDIR/NxWidgets

  pushd $ARA_BUILD_TOPDIR/nuttx > /dev/null

  make distclean

  # copy Make.defs to build output tree
  if ! install -m 644 -p ${configpath}/Make.defs ${ARA_BUILD_TOPDIR}/nuttx/Make.defs  >/dev/null 2>&1; then
      echo "Warning: Failed to copy Make.defs"
  fi

  # copy setenv.sh to build output tree
  if  install -p ${configpath}/setenv.sh ${ARA_BUILD_TOPDIR}/nuttx/setenv.sh >/dev/null 2>&1; then
  chmod 755 "${ARA_BUILD_TOPDIR}/nuttx/setenv.sh"
  fi

  # copy defconfig to build output tree
  if ! install -m 644 -p ${defconfigFile} ${ARA_BUILD_TOPDIR}/nuttx/.config ; then
      echo "ERROR: Failed to copy defconfig"
      exit $ARA_BUILD_CONFIG_ERR_CONFIG_COPY_FAILED
  fi

  # save config files
  cp ${ARA_BUILD_TOPDIR}/nuttx/.config   ${ARA_BUILD_CONFIG_PATH}/.config > /dev/null 2>&1
  cp ${ARA_BUILD_TOPDIR}/nuttx/Make.defs ${ARA_BUILD_CONFIG_PATH}/Make.defs > /dev/null 2>&1
  cp ${ARA_BUILD_TOPDIR}/nuttx/setenv.sh  ${ARA_BUILD_CONFIG_PATH}/setenv.sh > /dev/null 2>&1

  echo -n "Building '$buildname'" ...
  export ARA_BUILD_NAME=$buildname
  make  -j ${ARA_MAKE_PARALLEL} ${ARA_MAKE_ALWAYS} -r -f Makefile.unix  2>&1 | tee $ARA_BUILD_TOPDIR/build.log

  MAKE_RESULT=${PIPESTATUS[0]}

  popd > /dev/null
}

copy_image_files() {
  echo "Copying image files"
  imgfiles="nuttx nuttx.bin System.map"
  for fn in $imgfiles; do
    cp $ARA_BUILD_TOPDIR/nuttx/$fn $ARA_BUILD_TOPDIR/image/$fn  >/dev/null 2>&1
    rm -f $ARA_BUILD_TOPDIR/nuttx/$fn >/dev/null 2>&1
  done
  # if bridge image (i.e. *not* an svc image)
  # expand image to 2M using truncate utility
  # for more info, run "truncate --help"
  if [ -z $(echo $buildname | grep "svc")  ] ; then
    truncate -s 2M $ARA_BUILD_TOPDIR/image/nuttx.bin
  fi
}

main() {
  # check for "all" parameter
  if [ "$1" = "all" ] ; then
    echo "Building all configurations"
    buildall=1
  # validate parameters for board & image are present
  elif  [ "$#" -ne 2 ] ; then
    echo "Required parameters not specified."
    echo "$USAGE"
    configpath="bridge/es2-debug-apbridgea"  
    buildname="ara-es2-debug-apridgea"
    echo "using default parameters"
    echo "   configpath:" $configpath
    echo "    buildname:" $buildname
    #exit $ARA_BUILD_CONFIG_ERR_BAD_PARAMS
  #capture parameters for chip  & board
  else
    configpath=$1
    buildname=$2
  fi

  # set build output path
  buildbase="`( cd \"$TOPDIR/..\" && pwd )`/build"

  if [ $buildall -eq 1 ] ; then
    # build list of defconfigs
    defconfig_list=$(find $TOPDIR/configs/ara  -iname defconfig)
    # process list of defconfigs
    for cfg in $defconfig_list; do
      # save full path to defconfig
      defconfigFile=${cfg}
      # get abs path to defconfig
      configpath=$(canonicalize $(dirname "$cfg"))
      #create build name
      buildname=$(canonicalize $(dirname "$cfg"))
      #strip abs path
      buildname=$(echo "$buildname" | sed -e "s:^$TOPDIR/configs/::")
      # repl slash with dash
      buildname=$(echo "$buildname" | sed -e "s#/#-#g")

      # build the image
      build_image_from_defconfig
      # check build result
      if [ $MAKE_RESULT -ne 0 ] ; then
        echo "Build '$buildname' failed"
        exit 1
      fi
      echo "Build '$buildname' succeeded"
      copy_image_files
    done
    echo "Build all configurations succeeded"
    exit 0
  fi

  # set path to image config
  configpath=${TOPDIR}/configs/ara/${configpath}
  if [ ! -d "${configpath}" ]; then
    echo "Build config '${configpath}' does not exist"
    exit $ARA_BUILD_CONFIG_ERR_CONFIG_NOT_FOUND
  fi
  defconfigFile="${configpath}/defconfig"
  build_image_from_defconfig
  if [ $MAKE_RESULT -ne 0 ] ; then
    echo "Build '$buildname' failed"
    exit 1
  fi

  echo "Build '$buildname' succeeded"
  copy_image_files
  echo "Build complete"
  exit 0
}

if [ "`basename $0`" = "`basename $BASH_SOURCE`" ]; then
  main $*
fi
