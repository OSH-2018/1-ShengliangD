#!/bin/bash

qemu-system-x86_64 \
    -kernel linux/arch/x86/boot/bzImage \
    -initrd initrd.img \
    -append "root=/dev/raw init=/init console=ttyS0 nokaslr" \
    -gdb tcp::1234 -S \
    -nographic \
