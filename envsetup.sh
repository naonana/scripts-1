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
SCRIPTS=${KERNELDIR}/buildscript
OUTDIR=${KERNELDIR}/out
BUILD_DATE=$(TZ=Asia/Jakarta date +"%Y%m%d-%H%M")

# Pick your poison
        # Default to GCC from kdrag0n
        git clone -j32 https://github.com/arter97/arm64-gcc.git --depth=1 "${KERNELDIR}/gcc"
        git clone -j32 https://github.com/arter97/arm32-gcc.git --depth=1 "${KERNELDIR}/gcc32"
        COMPILER_STRING='GCC 10'
        COMPILER_TYPE='GCC10'

export COMPILER_STRING COMPILER_TYPE KERNELDIR SCRIPTS OUTDIR BUILD_DATE

# Do some silly defconfig replacements
	# For staging branch
	KERNELTYPE=EAS
	KERNELNAME="${KERNEL}-${KERNELRELEASE}-${BUILD_DATE}"
	#sed -i 's/CONFIG_LTO=y/# CONFIG_LTO is not set/g' arch/arm64/configs/whyred_defconfig
    #	sed -i 's/CONFIG_LD_DEAD_CODE_DATA_ELIMINATION=y/# CONFIG_LD_DEAD_CODE_DATA_ELIMINATION is not set/g' arch/arm64/configs/whyred_defconfig

export KERNELTYPE KERNELNAME

# Might as well export our zip
TEMPZIPNAME="${KERNELNAME}-unsigned.zip"
ZIPNAME="${KERNELNAME}.zip"

# Some misc enviroment vars
DEVICE=Whyred
CIPROVIDER=Drone

# Our TG channels
CI_CHANNEL="-1001174078190"
TG_GROUP="-1001493260868"

export DEVICE CIPROVIDER TEMPZIPNAME ZIPNAME CI_CHANNEL TG_GROUP

# Export Telegram.sh Location
TELEGRAM=${KERNELDIR}/telegram/telegram
# Make sure our fekking token is exported ig?
TELEGRAM_TOKEN="1117408755:AAHBQzUtTUmO1WuayFIsHKNCaA3CA0OANHc"
# Export AnyKernel Location
ANYKERNEL=$(pwd)/anykernel3

# Examine our compilation threads
# 2x of our available CPUs
# Kanged from @raphielscape <3
CPU="$(grep -c '^processor' /proc/cpuinfo)"
JOBS="$((CPU * 2))"

#export CCACHE_DIR="$HOME/.ccache"
#export CC="ccache gcc"
#export CXX="ccache g++"
#export PATH="/usr/lib/ccache:$PATH"
#ccache -M 5G

# Parse git things
PARSE_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
PARSE_ORIGIN="$(git config --get remote.origin.url)"
COMMIT_POINT="$(git log --pretty=format:'%h : %s' -1)"

export TELEGRAM TELEGRAM_TOKEN JOBS ANYKERNEL PARSE_BRANCH PARSE_ORIGIN COMMIT_POINT
