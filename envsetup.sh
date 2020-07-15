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
       
#git clone -j32 https://github.com/kdrag0n/proton-clang.git --depth=1 "${KERNELDIR}"/clang
#git clone https://github.com/Haseo97/Avalon-Clang-11.0.1.git --depth=1 "${KERNELDIR}"/clang
#COMPILER_STRING='Proton Clang'
#COMPILER_TYPE='clang'
# Default to GCC from Arter
#git clone -j32 https://github.com/Reinazhard/gcc.git -b 11.x-arm --depth=1 "${KERNELDIR}/gcc32"
#git clone -j32 https://github.com/milouk/gcc-prebuilt-elf-toolchains.git --depth=1 "${KERNELDIR}/gcc"
#COMPILER_STRING='GCC 11'
#COMPILER_TYPE='GCC'
git clone -j32 https://github.com/ItsVixano/aarch64-elf-9.3.0.git --depth=1 "${KERNELDIR}/gcc"
git clone -j32 https://github.com/ItsVixano/arm-eabi-9.3.0.git --depth=1 "${KERNELDIR}/gcc32"
COMPILER_STRING='GCC 9.3'
COMPILER_TYPE='GCC'

export COMPILER_STRING COMPILER_TYPE KERNELDIR SCRIPTS OUTDIR

git clone -j32 https://github.com/fabianonline/telegram.sh/ telegram

# Export Telegram.sh
TELEGRAM=${KERNELDIR}/telegram/telegram

export TELEGRAM JOBS
