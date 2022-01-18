# ESP32 Arduino Core Debug Environment

Docker container with ESP IDF + ESP32 Arduino Core with full debugging symbols

## Building the container

```
docker build -t wokwi/esp32-arduino-debug .
```

## Using the container

First, you need to compile the Arduino project using the copy of `arduino-cli` installed in the container. 

Assuming that your Sketch directory is /home/uri/projects/blink, run the following command:

```
docker run -v /home/uri/projects:/workspace wokwi/esp32-arduino-debug arduino-cli compile -e -b esp32:esp32:esp32doit-devkit-v1 /workspace/blink
```

You can replace `esp32:esp32:esp32doit-devkit-v1` with the FQBN (fully qualified board name) you want to compile your project for.

The compiled binary file (and the ELF file with the symbols) will reside in /home/uri/projects/blink/build/esp32.esp32.esp32doit-devkit-v1.

Then, run GDB as follows:

```
docker run -it -v /home/uri/projects:/workspace wokwi/esp32-arduino-debug xtensa-esp32-elf-gdb -ex "file /workspace/blink/esp32.esp32.esp32doit-devkit-v1/blink.ino.elf"
```

You can use a different GDB version (e.g. `xtensa-esp32s2-elf-gdb` or `xtensa-esp32s3-elf-gdb`), depending on the MCU you are working with.
