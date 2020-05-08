#!/usr/bin/env bash
#
# Copyright (C) 2019 nysascape
#
# Licensed under the Raphielscape Public License, Version 1.d (the "License");
# you may not use this file except in compliance with the License.
#
# Local build script for Acrux.

function cleanupfail1
{
        rm -rf ${ANYKERNEL}
        rm -rf ${TELEGRAM}
	cd ../
	rm -rf telegram
        cd $1
        git reset --hard HEAD^
}

function cleanupfail2
{
        rm -rf ${ANYKERNEL}
        rm -rf ${TELEGRAM}
        cd ../
        rm -rf telegram
        cd $1
        git reset --hard HEAD~2
}

ACRUXPATH=home/reina/zhard
KERNELRELEASE=HMP
SCRIPTSPATH=$(pwd)
OUTDIR=${ACRUXPATH}/out

# Make sure our fekking token is exported ig?
export TELEGRAM_TOKEN=$tgtoken

# Some misc enviroment vars
DEVICE=whyred
CIPROVIDER=Local
KERNELFW=HMP

# Clone our AnyKernel3 branch to KERNELDIR
git clone https://github.com/Reinazhard/AnyKernel3 -b master ${ACRUXPATH}/anykernel3
export ANYKERNEL=${ACRUXPATH}/anykernel3

git clone https://github.com/fabianonline/telegram.sh/ telegram
# Export Telegram.sh
TELEGRAM=${SCRIPTSPATH}/telegram/telegram

# Examine our compilation threads
# 2x of our available CPUs
# Kanged from @raphielscape <3
CPU="$(grep -c '^processor' /proc/cpuinfo)"
JOBS="$(( CPU * 2 ))"

COMPILER_STRING='MAESTRO GCC 9.x'
COMPILER_TYPE='MAESTRO-GCC9.x'

cd ${ACRUXPATH}

# Always clean build
rm -rf ${OUTDIR}

# Parse git things
PARSE_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
PARSE_ORIGIN="$(git config --get remote.origin.url)"
COMMIT_POINT="$(git log --pretty=format:'%h : %s' -1)"

# Do some silly defconfig replacements
if [[ "${PARSE_BRANCH}" =~ "reina"* ]]; then
	# For staging branch
	KERNELTYPE=GABUT
	KERNELNAME="-ZHARD-${KERNELRELEASE}-Gabut-${KERNELFW}-$(date +%Y%m%d-%H%M)"
	sed -i "51s/.*/CONFIG_LOCALVERSION=\"-${KERNELNAME}\"/g" arch/arm64/configs/whyred_defconfig

else
	# Dunno when this will happen but we will cover, just in case
	KERNELTYPE=${PARSE_BRANCH}
	KERNELNAME="ZHARD-${KERNELRELEASE}-Gabut-${KERNELFW}-$(date +%Y%m%d-%H%M)"
        sed -i "51s/.*/CONFIG_LOCALVERSION=\"-${KERNELNAME}\"/g" arch/arm64/configs/whyred_defconfig
fi

export KERNELTYPE KERNELNAME

# Workaround for long af kernel strings
git add .
git commit -m "stop adding dirty"

# Might as well export our zip
export TEMPZIPNAME="${KERNELNAME}-unsigned.zip"
export ZIPNAME="${KERNELNAME}.zip"

# Our TG channels
CI_CHANNEL="-1001420038245"
TG_GROUP="-1001435271206"

# Send to main group
tg_groupcast() {
    "${TELEGRAM}" -c "${TG_GROUP}" -H \
    "$(
		for POST in "${@}"; do
			echo "${POST}"
		done
    )"
}

# sendcast to channel
tg_channelcast() {
    "${TELEGRAM}" -c "${CI_CHANNEL}" -H \
    "$(
		for POST in "${@}"; do
			echo "${POST}"
		done
    )"
}

# Let's announce our naisu new kernel!
tg_groupcast "Zhard compilation clocked at $(date +%Y%m%d-%H%M)!"
tg_channelcast "Compiler: <code>${COMPILER_STRING}</code>" \
	"Device: <b>${DEVICE}</b>" \
	"Kernel: <code>ZHARD, release ${KERNELRELEASE}</code>" \
	"Branch: <code>${PARSE_BRANCH}</code>" \
	"Commit point: <code>${COMMIT_POINT}</code>" \
	"Under <code>${CIPROVIDER}, with $(nproc --all) cores</code>" \
	"Clocked at: <code>$(date +%Y%m%d-%H%M)</code>" \
	"Started on <code>$(whoami)</code>"

# Make is shit so I have to pass thru some toolchains
# Let's build, anyway
PATH="${KERNELDIR}/clang/bin:${PATH}"
START=$(date +"%s")

make O=out ARCH=arm64 whyred_defconfig
make -j"${JOBS}" O=out ARCH=arm64 CLANG_TRIPLE=aarch64-maestro-linux-gnu-

## Check if compilation is done successfully.
if ! [ -f "${OUTDIR}"/arch/arm64/boot/Image.gz-dtb ]; then
	END=$(date +"%s")
	DIFF=$(( END - START ))
	echo -e "BUild Failed LMAO !!, See buildlog to fix errors"
	tg_channelcast "Build for ${DEVICE} <b>failed</b> in $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)! Check Semaphore for errors!"
	tg_groupcast "Build for ${DEVICE} <b>failed</b> in $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)! Check Semaphore for errors @eve_enryu"
	exit 1
fi

# Copy our !!hopefully!! compiled kernel
cp "${OUTDIR}"/arch/arm64/boot/Image.gz-dtb "${ANYKERNEL}"/

# POST ZIP OR FAILURE
cd "${ANYKERNEL}" || exit
zip -r9 "${TEMPZIPNAME}" *

## Sign the zip before sending it to telegram
curl -sLo zipsigner-3.0.jar https://raw.githubusercontent.com/baalajimaestro/AnyKernel2/master/zipsigner-3.0.jar
java -jar zipsigner-3.0.jar ${TEMPZIPNAME} ${ZIPNAME}

"${TELEGRAM}" -f "$ZIPNAME" -c "${CI_CHANNEL}"

cd ..

rm -rf "${ANYKERNEL}"
git clone https://github.com/Reinazhard/AnyKernel3.git -b master anykernel3



# Do some silly defconfig replacements
if [[ "${PARSE_BRANCH}" =~ "staging"* ]]; then
        # For staging branch
        KERNELTYPE=nightly
        KERNELNAME="Zhard-${KERNELRELEASE}-Gabut-${KERNELFW}-$(date +%Y%m%d-%H%M)"
        sed -i "51s/.*/CONFIG_LOCALVERSION=\"-${KERNELNAME}\"/g" arch/arm64/configs/whyred_defconfig
else
        # Dunno when this will happen but we will cover, just in case
        KERNELTYPE=${PARSE_BRANCH}
        KERNELNAME="Zhard-${KERNELRELEASE}-Gabut-${KERNELFW}-$(date +%Y%m%d-%H%M)"
        sed -i "51s/.*/CONFIG_LOCALVERSION=\"-${KERNELNAME}\"/g" arch/arm64/configs/whyred_defconfig
fi

export KERNELTYPE KERNELNAME

export TEMPZIPNAME="${KERNELNAME}-unsigned.zip"
export ZIPNAME="${KERNELNAME}.zip"
make O=out ARCH=arm64 whyred_defconfig
make -j$(nproc --all) O=out ARCH=arm64 CLANG_TRIPLE=aarch64-maestro-linux-gnu-

## Check if compilation is done successfully.
if ! [ -f "${OUTDIR}"/arch/arm64/boot/Image.gz-dtb ]; then
	END=$(date +"%s")
	DIFF=$(( END - START ))
        echo -e "Build Failed !! LMAO, See buildlog to fix errors"
        tg_channelcast "Build for ${DEVICE} <b>failed</b> in $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)! Check Semaphore for errors!"
        tg_groupcast "Build for ${DEVICE} <b>failed</b> in $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)! Check Semaphore for errors @eve_enryu"
        exit 1
fi

# Copy our !!hopefully!! compiled kernel
cp "${OUTDIR}"/arch/arm64/boot/Image.gz-dtb "${ANYKERNEL}"/

# POST ZIP OR FAILURE
cd "${ANYKERNEL}" || exit
zip -r9 "${TEMPZIPNAME}" *

## Sign the zip before sending it to telegram
curl -sLo zipsigner-3.0.jar https://raw.githubusercontent.com/baalajimaestro/AnyKernel2/master/zipsigner-3.0.jar
java -jar zipsigner-3.0.jar ${TEMPZIPNAME} ${ZIPNAME}

"${TELEGRAM}" -f "$ZIPNAME" -c "${CI_CHANNEL}"

END=$(date +"%s")
DIFF=$(( END - START ))
tg_channelcast "Build for ${DEVICE} with ${COMPILER_STRING} took $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)!"
tg_groupcast "Build for ${DEVICE} with ${COMPILER_STRING} took $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)! "


