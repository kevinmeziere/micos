# usage:
#   init.sh <target_dir>

set -e

MYDIR=`pwd`
cd $1

mkdir cdrom
mkdir micos-extra

cp -v ${MYDIR}/geniso.sh .

ln -fs ./cdrom/platform/i86pc/amd64 amd64
ln -fs ../micos-extra/micos cdrom/micos

cd -
