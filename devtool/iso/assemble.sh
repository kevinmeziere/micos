# usage: assemble.sh <micos-ver> <boot-archive-dir> <iso-path> <extra-dir>

MICOS_VER=$1
BOOT_ARCHIVE_DIR=$2
ISO_PATH=$3
EXTRA_DIR=$4

# prepare dirs & symlinks
rm -rf cdrom; mkdir cdrom
ln -fs ./cdrom/platform/i86pc/amd64 amd64
ln -fs ${EXTRA_DIR}/micos cdrom/micos

# prepare iso & mount
rm -rf isomnt; mkdir isomnt
sdev=$(lofiadm -a ${ISO_PATH})
mount -o ro -F hsfs $sdev isomnt

# copy iso files
cp -rvL isomnt/* cdrom/

# copy micos boot_archive
cp -rvL $BOOT_ARCHIVE_DIR/boot_archive* ./amd64/

# copy extra files
cp -rvL ../../../extra/* ./cdrom/ # we are in build/dist/iso/

# gen iso
LC_ALL=C mkisofs -R -b boot/grub/stage2_eltorito --follow-links -no-emul-boot -boot-load-size 4 -boot-info-table -quiet -o ${MICOS_VER}.iso cdrom/

# cleanup
umount isomnt
lofiadm -d $sdev

