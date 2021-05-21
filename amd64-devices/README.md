# x86 devices config

This folder contains configuration for custom amd64 device images that don't work with mainline-generic itself.

## Generic

The `generic.yaml` configuration creates an EFI/Legacy bootable image for amd64 devices.

## Surface Go

The `surfacego.yaml` config installs the surface-linux kernel and firmware for the Microsoft Surface Go. Unfortunately, it cannot be booted with UEFI Secure Boot.

https://github.com/linux-surface/linux-surface/wiki/Surface-Go
