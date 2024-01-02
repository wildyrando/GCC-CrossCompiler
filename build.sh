#!/bin/bash

# REPO: https://github.com/wildyrando/GCC-CrossCompiler

# >> install requirements
apt install ca-certificates libgmp-dev zip \
libmpc-dev libmpfr-dev libisl-dev xz-utils unzip \
texinfo patch bzip2 p7zip cmake make curl m4 gcc g++ -y

# >> Create path
VER="$2"
POWER="$1"
PTD="/build-gcc"
SOURCE="/build-gcc/source"
BUILD="/build-gcc/build/x86_64-w64-mingw32"
RESULT="/build-gcc/final-result"
rm -rf $PTD # >> delete if exists
mkdir -p $PTD
mkdir -p $SOURCE
mkdir -p $RESULT
cd $SOURCE

# Required files
export ZSTD="https://github.com/facebook/zstd/releases/download/v1.5.5/zstd-1.5.5.tar.gz"
export GMP="https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz"
export MPFR="https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.1.tar.xz"
export MPC="https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz"
export ISL="https://libisl.sourceforge.io/isl-0.26.tar.xz"
export EXPAT="https://github.com/libexpat/libexpat/releases/download/R_2_5_0/expat-2.5.0.tar.xz"
export BINUTILS="https://ftp.gnu.org/gnu/binutils/binutils-2.41.tar.xz"
export GCC="https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz"
export MINGW="https://onboardcloud.dl.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/mingw-w64-v11.0.1.zip"
export GDB="https://ftp.gnu.org/gnu/gdb/gdb-14.1.tar.xz"
export MAKES="https://ftp.gnu.org/gnu/make/make-4.4.tar.gz"

function download_extract() {
    # zstd
    wget -O ZSTD.temp $ZSTD
    tar -xvf ZSTD.temp
    mv zstd-*/ zstd
    rm -rf ZSTD.temp

    # gmp
    wget -O GMP.temp $GMP
    tar -xvf GMP.temp
    mv gmp-*/ gmp
    rm -rf GMP.temp

    # mpfr
    wget -O MPFR.temp $MPFR
    tar -xvf MPFR.temp
    mv mpfr-*/ mpfr
    rm -rf MPFR.temp

    # mpc
    wget -O MPC.temp $MPC
    tar -xvf MPC.temp
    mv mpc-*/ mpc
    rm -rf MPC.temp

    # isl
    wget -O ISL.temp $ISL
    tar -xvf ISL.temp
    mv isl-*/ isl
    rm -rf ISL.temp

    # expat
    wget -O EXPAT.temp $EXPAT
    tar -xvf EXPAT.temp
    mv expat-*/ expat
    rm -rf EXPAT.temp

    # binutils
    wget -O BINUTILS.temp $BINUTILS
    tar -xvf BINUTILS.temp
    mv binutils-*/ binutils
    rm -rf BINUTILS.temp

    # gcc
    wget -O GCC.temp $GCC
    tar -xvf GCC.temp
    mv gcc-*/ gcc
    rm -rf GCC.temp

    # mingw
    wget -O MINGW.temp $MINGW
    unzip -o MINGW.temp
    mv mingw-w64-*/ mingw
    rm -rf MINGW.temp

    # gdb
    wget -O GDB.temp $GDB
    tar -xvf GDB.temp
    mv gdb-*/ gdb
    rm -rf GDB.temp

    # make
    wget -O MAKE.temp $MAKES
    tar -xvf MAKE.temp
    mv make-*/ make
    rm -rf MAKE.temp
}

function build_binutils() {
    mkdir -p ${BUILD}/x-binutils
    cd ${BUILD}/x-binutils

    ${PTD}/source/binutils/configure                           \
    --prefix="${PTD}/bootstrap/x86_64-w64-mingw32"             \
    --with-sysroot="${PTD}/bootstrap/x86_64-w64-mingw32"       \
    --target="x86_64-w64-mingw32"                              \
    --disable-plugins                                          \
    --disable-nls                                              \
    --disable-shared                                           \
    --disable-multilib                                         \
    --disable-werror
    make -j ${POWER} && make install
}

function build_mingwheader() {
    mkdir -p ${BUILD}/x-mingw-w64-headers
    cd ${BUILD}/x-mingw-w64-headers

    ${PTD}/source/mingw/mingw-w64-headers/configure            \
    --prefix="${PTD}/bootstrap/x86_64-w64-mingw32"             \
    --host="x86_64-w64-mingw32"
    make -j ${POWER} && make install
    ln -sTf ${PTD}/bootstrap/x86_64-w64-mingw32 ${PTD}/bootstrap/x86_64-w64-mingw32/mingw
}

function build_gcc() {
    mkdir -p ${BUILD}/x-gcc
    cd ${BUILD}/x-gcc

    ${PTD}/source/gcc/configure                                \
    --prefix="${PTD}/bootstrap/x86_64-w64-mingw32"             \
    --with-sysroot="${PTD}/bootstrap/x86_64-w64-mingw32"       \
    --target="x86_64-w64-mingw32"                              \
    --enable-static                                            \
    --disable-shared                                           \
    --disable-lto                                              \
    --disable-nls                                              \
    --disable-multilib                                         \
    --disable-werror                                           \
    --disable-libgomp                                          \
    --enable-languages=c,c++                                   \
    --enable-threads=posix                                     \
    --enable-checking=release                                  \
    --enable-large-address-aware                               \
    --disable-libstdcxx-pch                                    \
    --disable-libstdcxx-verbose                                \
    --with-pkgversion="${VER}"
    make all-gcc -j ${POWER} && make install-gcc

    export PATH=${PTD}/bootstrap/x86_64-w64-mingw32/bin:$PATH
}

function build_mingwcrt() {
    mkdir -p ${BUILD}/x-mingw-w64-crt
    cd ${BUILD}/x-mingw-w64-crt

    ${PTD}/source/mingw/mingw-w64-crt/configure                \
    --prefix="${PTD}/bootstrap/x86_64-w64-mingw32"             \
    --with-sysroot="${PTD}/bootstrap/x86_64-w64-mingw32"       \
    --host="x86_64-w64-mingw32"                                \
    --disable-dependency-tracking                              \
    --enable-warnings=0                                        \
    --disable-lib32
    make -j ${POWER} && make install
}

function build_mingw_winpthread() {
    mkdir -p ${BUILD}/x-mingw-w64-winpthreads
    cd ${BUILD}/x-mingw-w64-winpthreads

    ${PTD}/source/mingw/mingw-w64-libraries/winpthreads/configure   \
    --prefix="${PTD}/bootstrap/x86_64-w64-mingw32"                  \
    --with-sysroot="${PTD}/bootstrap/x86_64-w64-mingw32"            \
    --host="x86_64-w64-mingw32"                                     \
    --disable-dependency-tracking                                   \
    --enable-static                                                 \
    --disable-shared
    make -j ${POWER} && make install
}

function rebuild_gcc() {
    cd ${BUILD}/x-gcc
    make -j ${POWER} && make install
}

function build_zstd() {
    mkdir -p ${BUILD}/zstd
    cd ${BUILD}/zstd

    cmake $PTD/source/zstd/build/cmake                             \
    -DCMAKE_BUILD_TYPE=Release                                     \
    -DCMAKE_SYSTEM_NAME=Windows                                    \
    -DCMAKE_INSTALL_PREFIX="${PTD}/prefix/x86_64-w64-mingw32"      \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER                      \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY                       \
    -DCMAKE_C_COMPILER="x86_64-w64-mingw32-gcc"                    \
    -DCMAKE_CXX_COMPILER="x86_64-w64-mingw32-g++"                  \
    -DZSTD_BUILD_STATIC=ON                                         \
    -DZSTD_BUILD_SHARED=OFF                                        \
    -DZSTD_BUILD_PROGRAMS=OFF                                      \
    -DZSTD_BUILD_CONTRIB=OFF                                       \
    -DZSTD_BUILD_TESTS=OFF
    make -j ${POWER} && make install
}

function build_gmp() {
    mkdir -p ${BUILD}/gmp
    cd ${BUILD}/gmp

    ${PTD}/source/gmp/configure                     \
    --prefix="${PTD}/prefix/x86_64-w64-mingw32"     \
    --host="x86_64-w64-mingw32"                     \
    --disable-shared                                \
    --enable-static                                 \
    --enable-fat
    make -j ${POWER} && make install
}

function build_mpfr() {
    mkdir -p ${BUILD}/mpfr
    cd ${BUILD}/mpfr

    ${PTD}/source/mpfr/configure                                 \
    --prefix="${PTD}/prefix/x86_64-w64-mingw32"                  \
    --host="x86_64-w64-mingw32"                                  \
    --disable-shared                                             \
    --enable-static                                              \
    --with-gmp-build="${PTD}/build/x86_64-w64-mingw32/gmp"
    make -j ${POWER} && make install
}

function build_mpc() {
    mkdir -p ${BUILD}/mpc
    cd ${BUILD}/mpc

    ${PTD}/source/mpc/configure                              \
    --prefix="${PTD}/prefix/x86_64-w64-mingw32"              \
    --host="x86_64-w64-mingw32"                              \
    --disable-shared                                         \
    --enable-static                                          \
    --with-{gmp,mpfr}="${PTD}/prefix/x86_64-w64-mingw32"
    make -j ${POWER} && make install
}

function build_isl() {
    mkdir -p ${BUILD}/isl
    cd ${BUILD}/isl

    ${PTD}/source/isl/configure                              \
    --prefix="${PTD}/prefix/x86_64-w64-mingw32"              \
    --host="x86_64-w64-mingw32"                              \
    --disable-shared                                         \
    --enable-static                                          \
    --with-gmp-prefix="${PTD}/prefix/x86_64-w64-mingw32"
    make -j ${POWER} && make install
}

function build_expat() {
    mkdir -p ${BUILD}/expat
    cd ${BUILD}/expat

    ${PTD}/source/expat/configure                            \
    --prefix="${PTD}/prefix/x86_64-w64-mingw32"              \
    --host="x86_64-w64-mingw32"                              \
    --disable-shared                                         \
    --enable-static                                          \
    --without-examples                                       \
    --without-tests
    make -j ${POWER} && make install
}

function build_binutils_re() {
    mkdir -p ${BUILD}/binutils
    cd ${BUILD}/binutils

    ${PTD}/source/binutils/configure                                     \
    --prefix="${PTD}/final-result"                                       \
    --with-sysroot="${PTD}/final-result"                                 \
    --host="x86_64-w64-mingw32"                                          \
    --target="x86_64-w64-mingw32"                                        \
    --enable-lto                                                         \
    --enable-plugins                                                     \
    --enable-64-bit-bfd                                                  \
    --disable-nls                                                        \
    --disable-multilib                                                   \
    --disable-werror                                                     \
    --with-{gmp,mpfr,mpc,isl}="${PTD}/prefix/x86_64-w64-mingw32"
    make -j ${POWER} && make install
}

function build_mingwheaders_re() {
    mkdir -p ${BUILD}/mingw-w64-headers
    cd ${BUILD}/mingw-w64-headers

    ${PTD}/source/mingw/mingw-w64-headers/configure     \
    --prefix="${PTD}/final-result/x86_64-w64-mingw32"   \
    --host="x86_64-w64-mingw32"
    make -j ${POWER} && make install
    ln -sTf ${PTD}/final-result/x86_64-w64-mingw32 ${PTD}/final-result/mingw
}

function build_mingwcrt_re() {
    mkdir -p ${BUILD}/mingw-w64-crt
    cd ${BUILD}/mingw-w64-crt

    ${PTD}/source/mingw/mingw-w64-crt/configure                   \
    --prefix="${PTD}/final-result/x86_64-w64-mingw32"             \
    --with-sysroot="${PTD}/final-result/x86_64-w64-mingw32"       \
    --host="x86_64-w64-mingw32"                                   \
    --disable-dependency-tracking                                 \
    --enable-warnings=0                                           \
    --disable-lib32
    make -j ${POWER} && make install
}

function build_gcc_re() {
    mkdir -p ${BUILD}/gcc
    cd ${BUILD}/gcc

    ${PTD}/source/gcc/configure                                            \
    --prefix="${PTD}/final-result"                                         \
    --with-sysroot="${PTD}/final-result"                                   \
    --target="x86_64-w64-mingw32"                                          \
    --host="x86_64-w64-mingw32"                                            \
    --disable-dependency-tracking                                          \
    --disable-nls                                                          \
    --disable-multilib                                                     \
    --disable-werror                                                       \
    --disable-shared                                                       \
    --enable-static                                                        \
    --enable-languages=c,c++                                               \
    --enable-threads=posix                                                 \
    --enable-checking=release                                              \
    --enable-mingw-wildcard                                                \
    --enable-large-address-aware                                           \
    --disable-libstdcxx-pch                                                \
    --disable-libstdcxx-verbose                                            \
    --disable-win32-registry                                               \
    --with-tune=intel                                                      \
    --with-pkgversion="${VER}"                                             \
    --with-{gmp,mpfr,mpc,isl,zstd}="$PTD/prefix/x86_64-w64-mingw32"
    make -j ${POWER} && make install
}

function build_mingw_winpthread_re() {
    mkdir -p ${BUILD}/mingw-w64-winpthreads
    cd ${BUILD}/mingw-w64-winpthreads

    ${PTD}/source/mingw/mingw-w64-libraries/winpthreads/configure                 \
    --prefix="${PTD}/final-result/x86_64-w64-mingw32"                             \
    --with-sysroot="${PTD}/final-result/x86_64-w64-mingw32"                       \
    --host="x86_64-w64-mingw32"                                                   \
    --disable-dependency-tracking                                                 \
    --disable-shared                                                              \
    --enable-static
    make -j ${POWER} && make install
}

function build_gdb_re() {
    mkdir -p ${BUILD}/gdb
    cd ${BUILD}/gdb

    ${PTD}/source/gdb/configure                                     \
    --prefix="${PTD}/final-result"                                  \
    --host="x86_64-w64-mingw32"                                     \
    --enable-64-bit-bfd                                             \
    --disable-werror                                                \
    --with-mpfr                                                     \
    --with-expat                                                    \
    --with-libgmp-prefix="${PTD}/prefix/x86_64-w64-mingw32"         \
    --with-libmpfr-prefix="${PTD}/prefix/x86_64-w64-mingw32"        \
    --with-libexpat-prefix="${PTD}/prefix/x86_64-w64-mingw32"
    make -j ${POWER}
    cp gdb/.libs/gdb.exe gdbserver/gdbserver.exe ${PTD}/final-result/bin/
}

function build_make() {
    mkdir -p ${BUILD}/make
    cd ${BUILD}/make

    ${PTD}/source/make/configure                    \
    --prefix="${PTD}/final-result"                  \
    --host="x86_64-w64-mingw32"                     \
    --disable-nls                                   \
    --disable-rpath                                 \
    --enable-case-insensitive-file-system
    make -j ${POWER} && make install

    rm -rf ${PTD}/final-result/bin/x86_64-w64-mingw32-*
    rm -rf ${PTD}/final-result/bin/ld.bfd.exe ${PTD}/final-result/x86_64-w64-mingw32/bin/ld.bfd.exe
    rm -rf ${PTD}/final-result/lib/bfd-plugins/libdep.dll.a
    rm -rf ${PTD}/final-result/share
    rm -rf ${PTD}/final-result/mingw
}

function final() {
    # >> Triming files output
    for ext in "exe" "dll" "o" "a"; do
        echo find ${PTD}/final-result -name "*.${ext}" -print0 | xargs -0 -n 8 -P 2 x86_64-w64-mingw32-strip --strip-unneeded
    done

    # >> Done success
    cd ${PTD}/final-result
    zip -r result.zip *
    cp result.zip /root/
}

function runner() {
    download_extract
    build_binutils
    build_mingwheader
    build_mingw_winpthread
    build_gcc
    build_mingwcrt
    build_mingw_winpthread
    rebuild_gcc
    build_zstd
    build_gmp
    build_mpfr
    build_mpc
    build_isl
    build_expat
    build_binutils_re
    build_mingwheaders_re
    build_mingwcrt_re
    build_gcc_re
    build_mingw_winpthread_re
    build_gdb_re
    build_make
    final
}

# >> call runner
runner
