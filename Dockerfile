FROM espressif/esp32-arduino-lib-builder

ENV ARDUINO_CORE_VERSION=3.0.5

WORKDIR /opt/esp/lib-builder
RUN ./entrypoint.sh 
RUN ./build.sh

# Install the Arduino CLI
RUN mkdir /opt/arduino
WORKDIR /opt/arduino
RUN wget https://downloads.arduino.cc/arduino-cli/arduino-cli_latest_Linux_64bit.tar.gz \
  && tar zxvf arduino-cli_latest_Linux_64bit.tar.gz \
  && rm arduino-cli_latest_Linux_64bit.tar.gz

# Install the standard ESP32 Arduino Core
ENV ESP32_ARDUINO=/root/.arduino15/packages/esp32/hardware/esp32/${ARDUINO_CORE_VERSION}
RUN mkdir -p $ESP32_ARDUINO && \
  git clone --depth 1 --branch ${ARDUINO_CORE_VERSION} https://github.com/espressif/arduino-esp32.git $ESP32_ARDUINO && \
  cd $ESP32_ARDUINO/tools && \
  python3 get.py

# Override the precompiled SDK files with the freshly-built core
WORKDIR /opt/esp/lib-builder
RUN ./tools/copy-to-arduino.sh

ENV PATH="/opt/arduino:${PATH}"
# The following is required for idf.py menuconfig
ENV LANG="C"
WORKDIR /opt/arduino
RUN arduino-cli update
