
# Build script for Arsenic Kernel
# By- Nimit Mehta (CheckYourScreen)

#For Time Calculation
BUILD_START=$(date +"%s")

# KBC
echo "enter version name for zip name (only number) :" 
read VER
echo "is it a test build ..? (y/n) :"
read buildtype

# Housekeeping
KERNEL_DIR=$PWD
cd ..
ROOT_PATH=$PWD
ROOT_DIR_NAME=`basename "$PWD"`
cd $KERNEL_DIR
KERN_IMG=$KERNEL_DIR/arch/arm/boot/zImage-dtb
KERN_DTB=$KERNEL_DIR/arch/arm/boot/dt.img
OUT_DIR=$KERNEL_DIR/anykernel/

blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

make clean && make mrproper
export ARCH=arm
export CROSS_COMPILE="$ROOT_PATH/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-"

compile_kernel ()
{
echo -e "**********************************************************************************************"
echo "                    "
echo "                                    Compiling Arsenic-Kernel with GCC 4.9                  "
echo "                    "
echo -e "**********************************************************************************************"
make onyx_defconfig
make -j16
if [ ! -e $KERN_IMG ];then
echo -e "$red Kernel Compilation failed! Fix the errors! $nocol"
exit 1
fi
# dtb
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
# cp $KERN_DTB $OUT_DIR/dtb
cd $OUT_DIR
case "$buildtype" in
	y | Y)
		echo "test build number?:"
		read BN
		zip -r -9 arsenic.kernel-onyx.R$VER-aosp-test-$BN.zip *
		echo "Test Build no. $BN of R$VER Ready..!"
		;;
	*)
		zip -r -9 arsenic.kernel-onyx.R$VER-aosp-$(date +"%Y%m%d").zip *
		echo "Release Build R$VER Ready..!!"
		;;
esac
}

compile_kernel
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
