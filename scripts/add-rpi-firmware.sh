#!/bin/sh

set -e

# Firmware repos locations
bootFirmwareRepo=https://raw.githubusercontent.com/raspberrypi/firmware/master
nonFreeFirmwareRepo=https://raw.githubusercontent.com/RPi-Distro/firmware-nonfree/buster
bluezFirmwareRepo=https://raw.githubusercontent.com/RPi-Distro/bluez-firmware/master
kernelArtifacts=https://gitlab.com/ubports/community-ports/non-android/linux/-/jobs/artifacts/rpi-5.15.y/raw

# Work around resolver failure in debos' fakemachine
mv /etc/resolv.conf /etc/resolv2.conf
echo "nameserver 1.1.1.1" > /etc/resolv.conf

echo "Create tmp folder..."
mkdir -p /var/tmp && cd /var/tmp

echo "Download the kernel deb package..."
wget -nc -O linux-image.deb $kernelArtifacts/linux-image-5.15.12-v8_5.15.12-v8-1_arm64.deb?job=build
wget -nc -O linux-libc-dev.deb $kernelArtifacts/linux-libc-dev_5.15.12-v8-1_arm64.deb?job=build
wget -nc -O linux-headers.deb $kernelArtifacts/linux-headers-5.15.12-v8_5.15.12-v8-1_arm64.deb?job=build

echo "Install kernel and firmware..."
dpkg -i /var/tmp/*.deb && rm /var/tmp/* -r

echo "Copy firmware to the correct locations"
mkdir -p /boot/firmware/overlays
cp /usr/lib/linux-image-*/broadcom/* /boot/firmware/
cp /usr/lib/linux-image-*/overlays/* /boot/firmware/overlays/
cp /boot/vmlinuz-* /boot/firmware/vmlinuz

echo "Make directories for the boot firmware location and licence..."
cd /boot/firmware

echo "Download the firmware and licence..."
wget -nc $bootFirmwareRepo/boot/LICENCE.broadcom

echo "Download the bootcode..."
wget -nc $bootFirmwareRepo/boot/bootcode.bin

echo "Download the start files..."
wget -nc $bootFirmwareRepo/boot/start.elf
wget -nc $bootFirmwareRepo/boot/start4.elf
wget -nc $bootFirmwareRepo/boot/start4cd.elf
wget -nc $bootFirmwareRepo/boot/start4db.elf
wget -nc $bootFirmwareRepo/boot/start4x.elf
wget -nc $bootFirmwareRepo/boot/start_cd.elf
wget -nc $bootFirmwareRepo/boot/start_db.elf
wget -nc $bootFirmwareRepo/boot/start_x.elf

echo "Download the link files..."
wget -nc $bootFirmwareRepo/boot/fixup.dat
wget -nc $bootFirmwareRepo/boot/fixup4.dat
wget -nc $bootFirmwareRepo/boot/fixup4cd.dat
wget -nc $bootFirmwareRepo/boot/fixup4db.dat
wget -nc $bootFirmwareRepo/boot/fixup4x.dat
wget -nc $bootFirmwareRepo/boot/fixup_cd.dat
wget -nc $bootFirmwareRepo/boot/fixup_db.dat
wget -nc $bootFirmwareRepo/boot/fixup_x.dat

echo "Make directories for the wifi firmware location and licence..."
mkdir -p /lib/firmware/brcm/ && cd /lib/firmware/brcm/

echo "Download the firmware for the raspberry pi 3B..."
wget -nc $nonFreeFirmwareRepo/brcm/brcmfmac43430-sdio.bin
wget -nc $nonFreeFirmwareRepo/brcm/brcmfmac43430-sdio.txt
wget -nc $nonFreeFirmwareRepo/brcm/brcmfmac43430-sdio.raspberrypi-rpi.txt

echo "Download the firmware for the raspberry pi 3B+ and 4B..."
wget -nc $nonFreeFirmwareRepo/brcm/brcmfmac43455-sdio.bin
wget -nc $nonFreeFirmwareRepo/brcm/brcmfmac43455-sdio.clm_blob
wget -nc $nonFreeFirmwareRepo/brcm/brcmfmac43455-sdio.txt

echo "Link firmware configs..."
ln brcmfmac43430-sdio.raspberrypi-rpi.txt brcmfmac43430-sdio.raspberrypi,3-model-b.txt
ln brcmfmac43455-sdio.txt brcmfmac43455-sdio.raspberrypi,4-model-b.txt

echo "Download the copyright licence..."
wget -nc $nonFreeFirmwareRepo/LICENCE.broadcom_bcm43xx

echo "Successfully downloaded wifi firmware"

echo "Download the firmware for the raspberry pi 3B bluetooth..."
wget -nc $bluezFirmwareRepo/broadcom/BCM43430A1.hcd
echo "Download the firmware for the raspberry pi 3B+ and 4B bluetooth..."
wget -nc $bluezFirmwareRepo/broadcom/BCM4345C0.hcd

echo "Download the copyright licence..."
wget $bluezFirmwareRepo/broadcom/BCM-LEGAL.txt

echo "All downloads complete!"

# Undo changes to work around debos fakemachine resolver
rm /etc/resolv.conf
mv /etc/resolv2.conf /etc/resolv.conf
