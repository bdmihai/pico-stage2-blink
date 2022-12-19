#______________________________________________________________________________
#│                                                                            |
#│ COPYRIGHT (C) 2022 Mihai Baneu                                             |
#│                                                                            |
#| Permission is hereby  granted,  free of charge,  to any person obtaining a |
#| copy of this software and associated documentation files (the "Software"), |
#| to deal in the Software without restriction,  including without limitation |
#| the rights to  use, copy, modify, merge, publish, distribute,  sublicense, |
#| and/or sell copies  of  the Software, and to permit  persons to  whom  the |
#| Software is furnished to do so, subject to the following conditions:       |
#|                                                                            |
#| The above  copyright notice  and this permission notice  shall be included |
#| in all copies or substantial portions of the Software.                     |
#|                                                                            |
#| THE SOFTWARE IS PROVIDED  "AS IS",  WITHOUT WARRANTY OF ANY KIND,  EXPRESS |
#| OR   IMPLIED,   INCLUDING   BUT   NOT   LIMITED   TO   THE  WARRANTIES  OF |
#| MERCHANTABILITY,  FITNESS FOR  A  PARTICULAR  PURPOSE AND NONINFRINGEMENT. |
#| IN NO  EVENT SHALL  THE AUTHORS  OR  COPYRIGHT  HOLDERS  BE LIABLE FOR ANY |
#| CLAIM, DAMAGES OR OTHER LIABILITY,  WHETHER IN AN ACTION OF CONTRACT, TORT |
#| OR OTHERWISE, ARISING FROM,  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR  |
#| THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                 |
#|____________________________________________________________________________|
#|                                                                            |
#|  Author: Mihai Baneu                           Last modified: 16.Dec.2022  |
#|                                                                            |
#|____________________________________________________________________________|

CONFIG_BOARD                = RP2040-W25Q64JV
CONFIG_OPENOCD              = $(PWD)/tools/openocd/bin/openocd
CONFIG_OPENOCDCONFIGDIR     = $(PWD)/tools/openocd/tcl
CONFIG_OPENOCD_INTERFACE    = interface/wch-link.cfg
CONFIG_OPENOCD_TARGET       = target/rp2040-core0.cfg

.PHONY: all build clean

MAKECMDGOALS ?= all
all: build-with-commands

config:
	/usr/bin/qbs config-ui
	
build: 
	/usr/bin/qbs build -d build -f source/project.qbs --jobs 16 config:$(CONFIG_BOARD) qbs.installRoot:bin qbs.targetPlatform:$(CONFIG_BOARD)

build-product: 
	/usr/bin/qbs build -d build/$(PRODUCT) -f source/$(PRODUCT)/$(PRODUCT).qbs --jobs 1 config:$(CONFIG_BOARD) qbs.installRoot:bin qbs.targetPlatform:$(CONFIG_BOARD)

build-with-commands:
	/usr/bin/qbs build -d build -f source/project.qbs --jobs 16 config:$(CONFIG_BOARD) --command-echo-mode command-line qbs.installRoot:bin qbs.targetPlatform:$(CONFIG_BOARD)

clean:
	/usr/bin/qbs clean -d build config:$(CONFIG_BOARD)

debug:
	$(CONFIG_OPENOCD) -s $(CONFIG_OPENOCDCONFIGDIR) -f $(CONFIG_OPENOCD_INTERFACE) -f $(CONFIG_OPENOCD_TARGET)

reset:
	$(CONFIG_OPENOCD) -s $(CONFIG_OPENOCDCONFIGDIR) -f $(CONFIG_OPENOCD_INTERFACE) -f $(CONFIG_OPENOCD_TARGET) -c "init; reset; exit"

flash: all
	$(CONFIG_OPENOCD) -s $(CONFIG_OPENOCDCONFIGDIR) -f $(CONFIG_OPENOCD_INTERFACE) -f $(CONFIG_OPENOCD_TARGET) -c "program bin/application.bin 0x10000000 verify reset exit"

flash-banks:
	$(CONFIG_OPENOCD) -s $(CONFIG_OPENOCDCONFIGDIR) -f $(CONFIG_OPENOCD_INTERFACE) -f $(CONFIG_OPENOCD_TARGET) -c "init; echo [flash banks]; exit"

flash-list:
	$(CONFIG_OPENOCD) -s $(CONFIG_OPENOCDCONFIGDIR) -f $(CONFIG_OPENOCD_INTERFACE) -f $(CONFIG_OPENOCD_TARGET) -c "init; echo [flash list]; exit"

flash-probe:
	$(CONFIG_OPENOCD) -s $(CONFIG_OPENOCDCONFIGDIR) -f $(CONFIG_OPENOCD_INTERFACE) -f $(CONFIG_OPENOCD_TARGET) -c "init; echo [flash probe $(bank)]; exit"

flash-info:
	$(CONFIG_OPENOCD) -s $(CONFIG_OPENOCDCONFIGDIR) -f $(CONFIG_OPENOCD_INTERFACE) -f $(CONFIG_OPENOCD_TARGET) -c "init; echo [flash info $(bank)]; exit"

flash-erase:
	$(CONFIG_OPENOCD) -s $(CONFIG_OPENOCDCONFIGDIR) -f $(CONFIG_OPENOCD_INTERFACE) -f $(CONFIG_OPENOCD_TARGET) -c "init; reset; halt; echo [flash erase_sector $(bank) $(first) $(last)]; exit"

flash-write:
	$(CONFIG_OPENOCD) -s $(CONFIG_OPENOCDCONFIGDIR) -f $(CONFIG_OPENOCD_INTERFACE) -f $(CONFIG_OPENOCD_TARGET) -c "init; halt; program bin/application.bin 0x10000000 verify exit"

flash-read:
	$(CONFIG_OPENOCD) -s $(CONFIG_OPENOCDCONFIGDIR) -f $(CONFIG_OPENOCD_INTERFACE) -f $(CONFIG_OPENOCD_TARGET) -c "init; echo [flash read_bank $(bank) bin/flash_$(bank).hex $(offset) $(length)]; exit"

monitor:
	screen /dev/ttyACM0 115200

list-usb:
	$(PWD)/scripts/list-usb.sh
