# usage: ./first_assemble.sh <smartos-iso> <micos-dir> <chunter-dir>
SMARTOS_ISO_SRC=$1
MICOS_OVERLAY=$2/overlay
CHUNTER_DIR=$3

# init the workplace first
./workplace_init.sh
wdev=$(lofiadm -a boot_archive)
mount $wdev workplace

# copy & mount smartos iso
sdev=$(lofiadm -a ${SMARTOS_ISO_SRC})
rm -rf isomnt; mkdir -p isomnt
mount -o ro -F hsfs $sdev isomnt

# extract boot_archive in iso & umount iso
cp -v isomnt/platform/i86pc/amd64/boot_archive smartos_boot_archive
umount isomnt
lofiadm -d $sdev
bdev=$(lofiadm -a smartos_boot_archive)
rm -rf bamnt; mkdir -p bamnt
mount $bdev bamnt

# copy all from smartos iso to workplace
rsync -avz bamnt/ workplace/

# copy micos overlay
cp -rLv ${MICOS_OVERLAY}/* workplace/

# copy chutner release
cp -rLv ${CHUNTER_DIR}/* workplace/micos/share/fifo/

# now first pack
./pack.sh

# clean up
umount workplace
umount bamnt
lofiadm -d $bdev
lofiadm -d $wdev
