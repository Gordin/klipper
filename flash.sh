#!/bin/bash

cp .config_stm32f401 .config
FLASH_DEVICE=$(find /dev/serial/by-id/ -name 'usb-Klipper_stm32f401xc*')
echo "Flashing STM32 (${FLASH_DEVICE})"
make clean && make all && sudo make flash FLASH_DEVICE="$FLASH_DEVICE"
cp .config_linux_process .config
echo Flashing Linux Process
make clean && sudo systemctl stop klipper makerbase-client && make all && sudo make flash && sudo systemctl start klipper makerbase-client
