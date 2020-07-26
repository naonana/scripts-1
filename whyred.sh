#!/usr/bin/env bash
# Copyright (C) 2019-2020 Jago Gardiner (nysascape)
#
# Licensed under the Raphielscape Public License, Version 1.d (the "License");
# you may not use this file except in compliance with the License.
#
# CI build script

# Needed exports
export TELEGRAM_TOKEN=1176154929:AAEwBruEeSm92J2VgHGrLuJroL4oKkd0j-k #Plox dont kang my bot, make ur own
export ANYKERNEL=$(pwd)/anykernel3

# Avoid hardcoding things
KERNEL=Zhard
DEFCONFIG=whyred_defconfig
DEVICE=Whyred
CIPROVIDER=CircleCI
KERNELFW=Global
PARSE_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
PARSE_ORIGIN="$(git config --get remote.origin.url)"
COMMIT_POINT="$(git log --pretty=format:'%h : %s' -1)"

#Kearipan Lokal
export KBUILD_BUILD_USER=reina
export KBUILD_BUILD_HOST=Laptop-Sangar

# Kernel groups
CI_CHANNEL=-1001174078190
TG_GROUP=-1001167537075

#Datetime
DATE=$(TZ=Asia/Jakarta date +"%Y%m%d-%T")
BUILD_DATE=$(TZ=Asia/Jakarta date +"%Y%m%d-%H%M")

# Clang is annoying
PATH="${KERNELDIR}/clang/bin:$PATH"

# Kernel revision

# Function to replace defconfig versioning
setversioning() {
    	# For staging branch
	    KERNELNAME="${KERNEL}-${KERNELRELEASE}-${DEVICE}-Oldcam-${BUILD_DATE}"
	    sed -i "1s/.*/CONFIG_LOCALVERSION=\"-${KERNELNAME}\"/g" arch/arm64/configs/${DEFCONFIG}
    
    # Export our new localversion and zipnames
    export KERNELTYPE KERNELNAME
    export TEMPZIPNAME="${KERNELNAME}-unsigned.zip"
    export ZIPNAME="${KERNELNAME}.zip"
}

# Send to main group
tg_groupcast() {
    "${TELEGRAM}" -c "${TG_GROUP}" -H \
    "$(
		for POST in "${@}"; do
			echo "${POST}"
		done
    )"
}

# Send to channel
tg_channelcast() {
    "${TELEGRAM}" -c "${CI_CHANNEL}" -H -D \
    "$(
		for POST in "${@}"; do
			echo "${POST}"
		done
    )"
}


# Fix long kernel strings
kernelstringfix() {
    git config --global user.name "Reinazhard"
    git config --global user.email "muh.alfarozy@gmail.com"
    git add .
    git commit -m "stop adding dirty"
}

# Make the kernel
makekernel() {
    # Clean any old AnyKernel
    rm -rf ${ANYKERNEL}
    git clone https://github.com/Reinazhard/AnyKernel3 -b master anykernel3
    kernelstringfix
    export PATH="${KERNELDIR}/clang/bin:$PATH"
    #export CROSS_COMPILE=${KERNELDIR}/clang/bin/aarch64-linux-gnu-
    #export CROSS_COMPILE_ARM32=${KERNELDIR}/clang/bin/arm-linux-gnueabi-
    #export CROSS_COMPILE=${KERNELDIR}/gcc/bin/aarch64-elf-
    #export CROSS_COMPILE_ARM32=${KERNELDIR}/gcc32/bin/arm-eabi-
    make O=out ARCH=arm64 ${DEFCONFIG}
    make -j$(nproc --all) O=out ARCH=arm64 CC=clang CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- | tee buildlog.txt
    # Check if compilation is done successfully.
    if ! [ -f "${OUTDIR}"/arch/arm64/boot/Image.gz-dtb ]; then
	    END=$(date +"%s")
	    DIFF=$(( END - START ))
	    echo -e "build Failed LMAO !!, See buildlog to fix errors"
	    tg_channelcast "❌Build Failed in $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)!"
	    tg_groupcast "❌Build Failed in $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)! @eve_enryu @reinazhardci"
        "${TELEGRAM}" -f "buildlog.txt" -c "${CI_CHANNEL}"
	    exit 1
    fi
}

# Ship the compiled kernel
shipkernel() {
    # Copy compiled kernel
    cp "${OUTDIR}"/arch/arm64/boot/Image.gz-dtb "${ANYKERNEL}"/

    # Zip the kernel, or fail
    cd "${ANYKERNEL}" || exit
    zip -r9 "${ZIPNAME}" *


    # Ship it to the CI channel
    "${TELEGRAM}" -f "$ZIPNAME" -c "${CI_CHANNEL}"

    # Go back for any extra builds
    cd ..
}

setnewcam() {
    sed -i "s/# CONFIG_MACH_XIAOMI_NEW_CAMERA is not set/CONFIG_MACH_XIAOMI_NEW_CAMERA=y/g" arch/arm64/configs/${DEFCONFIG}
    echo -e "Newcam ready"
}

clearout() {
    rm -rf out
    mkdir -p out
}

#Setver 2 for newcam
setver2() {
    KERNELNAME="${KERNEL}-${KERNELRELEASE}-${DEVICE}-Newcam-${BUILD_DATE}"
    sed -i "1s/.*/CONFIG_LOCALVERSION=\"-${KERNELNAME}\"/g" arch/arm64/configs/${DEFCONFIG}
    export KERNELTYPE KERNELNAME
    export TEMPZIPNAME="${KERNELNAME}-unsigned.zip"
    export ZIPNAME="${KERNELNAME}.zip"
}

# Fix for CI builds running out of memory
fixcilto() {
    sed -i 's/CONFIG_LTO=y/# CONFIG_LTO is not set/g' arch/arm64/configs/${DEFCONFIG}
    sed -i 's/CONFIG_LD_DEAD_CODE_DATA_ELIMINATION=y/# CONFIG_LD_DEAD_CODE_DATA_ELIMINATION is not set/g' arch/arm64/configs/${DEFCONFIG}
}

## Start the kernel buildflow ##
setversioning
fixcilto
tg_groupcast "🔨 Compilation started at $(date +%Y%m%d-%H%M)!" \
   	"Kernel: <code>${KERNEL}, release ${KERNELRELEASE}</code>" \
   	"Branch : <code>${PARSE_BRANCH}</code>" \
	"Latest Commit: <code>${COMMIT_POINT}</code>"
tg_channelcast "🔨Kernel: <code>${KERNEL}, release ${KERNELRELEASE}</code>" \
	"Branch : <code>${PARSE_BRANCH}</code>" \
	"Latest Commit: <code>${COMMIT_POINT}</code>" 

START=$(date +"%s")
makekernel || exit 1
shipkernel
setver2
setnewcam
makekernel || exit 1
shipkernel
END=$(date +"%s")
DIFF=$(( END - START ))
tg_channelcast "✅Build for ${DEVICE} with ${COMPILER_STRING} took $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)!"
tg_groupcast "✅Build for ${DEVICE} with ${COMPILER_STRING} took $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)! @reinazhardci"
