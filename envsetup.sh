#!/usr/bin/env bash
#
# Copyright (C) 2019 nysascape
#
# Licensed under the Raphielscape Public License, Version 1.d (the "License");
# you may not use this file except in compliance with the License.
#
# Probably the 3rd bad apple coming
# Enviroment variables

# Export KERNELDIR as en environment-wide thingy
# We start in scripts, so like, don't clone things there
KERNELDIR="$(pwd)"
SCRIPTS=${KERNELDIR}/kernelscripts
OUTDIR=${KERNELDIR}/out
       
git clone https://github.com/Reinazhard/proton-clang.git --depth=1 "${KERNELDIR}"/clang
#git clone https://github.com/Haseo97/Avalon-Clang-11.0.1.git --depth=1 "${KERNELDIR}"/clang
#git clone https://github.com/STRIX-Project/STRIX-clang.git --depth=1 "${KERNELDIR}"/clang
#git clone https://github.com/Panchajanya1999/azure-clang.git --depth=1 "${KERNELDIR}"/clang
COMPILER_STRING='Proton Clang'
#COMPILER_STRING='Avalon Clang'
COMPILER_TYPE='clang'
# Default to GCC from Arter
#git clone -j32 https://github.com/ItsVixano/aarch64-elf-9.3.0 --depth=1 "${KERNELDIR}/gcc"
#git clone -j32 https://github.com/ItsVixano/arm-eabi-9.3.0 --depth=1 "${KERNELDIR}/gcc32"
#COMPILER_STRING='GCC 9.3'
#COMPILER_TYPE='gcc'

export COMPILER_STRING COMPILER_TYPE KERNELDIR SCRIPTS OUTDIR

git clone https://github.com/fabianonline/telegram.sh/ telegram

# Export Telegram.sh
TELEGRAM=${KERNELDIR}/telegram/telegram

export TELEGRAM JOBS

#mkdir -p clang
#cd clang
#wget https://github.com/kdrag0n/proton-clang/archive/20200719.tar.gz --quiet
#tar -xf 20200719.tar.gz
#rm -rf 20200719.tar.gz
#cd ../