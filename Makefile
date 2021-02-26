all: loader

loader:
	make -C bootloader

clean:
	make -C bootloader clean

run:
	qemu-system-x86_64 -fda bootloader/bootloader.bin