FROM espressif/idf:v4.4

RUN apt-get update
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y git wget curl libssl-dev libncurses-dev flex bison gperf python3 python3-pip python3-setuptools python3-serial python3-click python3-cryptography python3-future python3-pyparsing python3-pyelftools cmake ninja-build ccache
RUN pip install --upgrade pip

# Install the ESP32 Arduino Lib Builder 
WORKDIR /opt/esp
RUN git clone https://github.com/espressif/esp32-arduino-lib-builder
WORKDIR /opt/esp/esp32-arduino-lib-builder
ENV IDF_PATH=/opt/esp/idf
RUN ./build.sh

# Install the Arduino CLI
RUN mkdir /opt/arduino
WORKDIR /opt/arduino
RUN wget https://downloads.arduino.cc/arduino-cli/arduino-cli_latest_Linux_64bit.tar.gz \
    && tar zxvf arduino-cli_latest_Linux_64bit.tar.gz \
    && rm arduino-cli_latest_Linux_64bit.tar.gz

# Install the standard ESP32 Arduino Core
RUN ./arduino-cli config init \
  --additional-urls https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
RUN ./arduino-cli update && ./arduino-cli core install esp32:esp32@2.0.3

# Override the precompiled SDK files with the freshly-built core
ENV ESP32_ARDUINO=/root/.arduino15/packages/esp32/hardware/esp32/2.0.3
WORKDIR /opt/esp/esp32-arduino-lib-builder
RUN ./tools/copy-to-arduino.sh
RUN mkdir $ESP32_ARDUINO/tools/esptool
RUN cp $ESP32_ARDUINO/tools/esptool.py $ESP32_ARDUINO/tools/esptool

ENV PATH="/opt/arduino:${PATH}"
# The following is required for idf.py menuconfig
ENV LANG="C"
WORKDIR /opt/arduino
