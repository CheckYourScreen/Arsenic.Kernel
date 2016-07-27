
# Build script for Arsenic Kernel with uber 4.9 toolchain
# By- Nimit Mehta (CheckYourScreen)

#For Time Calculation
BUILD_START=$(date +"%s")
echo "enter version name for zip name (only number) :" 
read VER
# Housekeeping
KERNEL_DIR=$PWD
KERN_IMG=$KERNEL_DIR/arch/arm/boot/zImage
KERN_DTB=$KERNEL_DIR/arch/arm/boot/dt.img
OUT_DIR=$KERNEL_DIR/anykernel/

blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

make clean && make mrproper
export ARCH=arm
export CROSS_COMPILE="/home/nimit/uber4.9/bin/arm-linux-androideabi-"

compile_kernel ()
{
echo -e "**********************************************************************************************"
echo "                    "
echo "                                    Compiling Arsenic-Kernel with Uber 4.9                  "
echo "                    "
echo -e "**********************************************************************************************"
make onyx_defconfig
make -j8
if ! [ -a $KERN_IMG ];
then
echo -e "$red Kernel Compilation failed! Fix the errors! $nocol"
exit 1
fi
dtb
zipping
}

dtb() {
tools_sk/dtbtool -o $KERN_DTB -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/

}


zipping() {
rm -rf $OUT_DIR/arsenic*.zip
rm -rf $OUT_DIR/zImage
rm -rf $OUT_DIR/dtb
cp $KERN_IMG $OUT_DIR/zImage
cp $KERN_DTB $OUT_DIR/dtb
cd $OUT_DIR
echo "is it a test build ..? (y/n) :"
read buildtype
if [ $buildtype == 'y' ]
then
echo "test build number?:"
read BN
zip -r arsenic.kernel-onyx.R$VER-test-$BN-uber.zip *
else
zip -r arsenic.kernel-onyx.R$VER-uber-$(date +"%Y%m%d").zip *
fi
}

compile_kernel
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
