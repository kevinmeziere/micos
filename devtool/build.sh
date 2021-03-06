# Auto build a MICOS from scratch

# debug switch
#set -x trace

# First please modify following conf vars

# ver 0.6.0
SMARTOS_VER=20140501T225642Z
FIFO_VER=0.6.0
JOYENT_VER=2014Q2 # ref http://pkgsrc.joyent.com/packages/SmartOS/
DATASETS_NAME=base64-14.2.0
DATASETS_UUID=d34c301e-10c3-11e4-9b79-5f67ca448df0

# ver 0.4.5
#SMARTOS_VER=20140501T225642Z
#FIFO_VER=0.4.5
#JOYENT_VER=2014Q1 # ref http://pkgsrc.joyent.com/packages/SmartOS/
#DATASETS_NAME=base64-13.2.1
#DATASETS_UUID=17c98640-1fdb-11e3-bf51-3708ce78e75a

MICOS_VER=MICOS-${SMARTOS_VER}-${FIFO_VER}

###############################################################################

# Internal vars

WGET="wget --no-check-certificate"

CWD=`pwd`
BTD=$(readlink -e $(dirname $0)) # build tool dir
MICOS=$(readlink -e $BTD/../) # micos repo dir

SKIP_DOWNLOAD=$1

if [[ -z "$SKIP_DOWNLOAD" ]]; then

# Step 1: download all required resources

# SmartOS distros
rm -rf smartos; mkdir smartos
cd smartos
  $WGET https://us-east.manta.joyent.com//Joyent_Dev/public/SmartOS/${SMARTOS_VER}/smartos-${SMARTOS_VER}.iso
  $WGET https://us-east.manta.joyent.com//Joyent_Dev/public/SmartOS/${SMARTOS_VER}/smartos-${SMARTOS_VER}-USB.img.bz2
  bunzip2 smartos-${SMARTOS_VER}-USB.img.bz2
cd -

# MICOS distro, in micos dir
rm -rf micos
  ln -s $MICOS micos # make symlink to micos repo

# chunter, in chunter dir
rm -rf chunter; mkdir chunter
cd chunter
  $WGET -i ${MICOS}/devtool/filelist/fifo-chunter-filelist-${FIFO_VER}.txt
  chunterver=$(basename $(cat ${MICOS}/devtool/filelist/fifo-chunter-filelist-${FIFO_VER}.txt)); chunterver=${chunterver/#chunter-/}; chunterver=${chunterver%.*}
  echo $chunterver >chunter.version
cd -

# prepare extra dir
mkdir -p extra/micos

# Fifo distro, in fifo dir
rm -rf pkgs/fifo-${FIFO_VER}; mkdir -p pkgs/fifo-${FIFO_VER}
cd pkgs/fifo-${FIFO_VER}
  #$WGET http://release.project-fifo.net/pkg/rel/pkg_summary.bz2
  #bunzip2 pkg_summary.bz2
  cp ${MICOS}/devtool/pkg_summary/fifo_pkg_summary-${FIFO_VER} pkg_summary
  gzip -c pkg_summary >pkg_summary.gz
  bzip2 pkg_summary
  $WGET -i ${MICOS}/devtool/filelist/fifo-filelist-${FIFO_VER}.txt
cd -
ln -s ../../pkgs/fifo-${FIFO_VER} extra/micos/fifo

# fifo zone img datasets
rm -rf datasets/${DATASETS_NAME}; mkdir -p datasets/${DATASETS_NAME}
cd datasets/${DATASETS_NAME}
  $WGET https://datasets.joyent.com/datasets/${DATASETS_UUID} -O ${DATASETS_NAME}.dsmanifest
  $WGET https://datasets.joyent.com/datasets/${DATASETS_UUID}/${DATASETS_NAME}.zfs.gz
cd -
ln -s ../../datasets/${DATASETS_NAME} extra/micos/datasets

# joyent pkgs, in joyent dir
rm -rf pkgs/joyent-{JOYENT_VER}; mkdir -p pkgs/joyent-${JOYENT_VER}
cd pkgs/joyent-${JOYENT_VER}
  cp ${MICOS}/devtool/pkg_summary/joyent_pkg_summary-${JOYENT_VER} pkg_summary
  gzip -c pkg_summary >pkg_summary.gz
  bzip2 pkg_summary
  $WGET -i ${MICOS}/devtool/filelist/joyent-filelist-${JOYENT_VER}.txt
cd -
ln -s ../../pkgs/joyent-${JOYENT_VER} extra/micos/joyent

# End of Step 1: download all required resources

else
  echo "as your wish, skipped downloading."
fi

# prepare the dist dir & change to it
rm -rf dist; mkdir dist
cd dist

# Step 2: assemble first boot_archive in dir dist
rm -rf boot_archive; mkdir boot_archive
cd boot_archive
  cp -v $CWD/micos/devtool/boot_archive/* .
  ./assemble.sh $CWD/smartos/smartos-${SMARTOS_VER}.iso $CWD/micos $CWD/chunter
cd -

# Step 3: assemble ISO
rm -rf iso; mkdir iso
cd iso
  cp -v $CWD/micos/devtool/iso/* .
  ./assemble.sh "micos-${SMARTOS_VER}-${FIFO_VER}" $CWD/dist/boot_archive $CWD/smartos/smartos-${SMARTOS_VER}.iso $CWD/extra
cd -

# Step 4: assemble USB
rm -rf usb; mkdir usb
cd usb
  cp -v $CWD/micos/devtool/usb/* .
  ./assemble.sh "micos-${SMARTOS_VER}-${FIFO_VER}" $CWD/dist/iso $CWD/smartos/smartos-${SMARTOS_VER}-USB.img
cd -

# Step 5: cleanup work
cd $CWD
