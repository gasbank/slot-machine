all: bootloader

bootloader:
	make -C bootloader

clean:
	make -C bootloader clean
