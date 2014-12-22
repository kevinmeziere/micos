echo "Now start to build MICOS..."
rm -rf build; mkdir build
cd build
../devtool/build.sh
cd -
echo "All done."
