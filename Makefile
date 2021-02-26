all: loader

loader:
	make -C bootloader

clean:
	make -C bootloader clean
