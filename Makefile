all: disk.img

loader:
	make -C bootloader

ker:
	make -C kernel

clean:
	make -C bootloader clean
	make -C kernel clean

disk.img: loader ker
	cat bootloader/bootloader.bin kernel/smos.bin > disk.img

run: disk.img
	qemu-system-x86_64 -fda disk.img