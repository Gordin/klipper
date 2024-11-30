#!/bin/bash

cp ./.config_eddy .config
FLASH_DEVICE=2e8a:0003
echo "Flashing Eddy (${FLASH_DEVICE})"
make clean && sudo systemctl stop klipper makerbase-client && make all && sudo make flash FLASH_DEVICE="$FLASH_DEVICE" && sudo systemctl start klipper makerbase-client
