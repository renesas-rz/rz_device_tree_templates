# rz_device_tree_templates
A collection of Device Tree templates to be used as starting points
## Overview
This document describes the device tree source ('.dts') file for a custom board based on the Renesas RZ/G2L SoC. The device tree defines the hardware configuration of the board, including memory, peripherals, Ethernet, USB and pin assignments.
## Hardware Features
### Core Components
* SOC: Renesas R9A07G044 (RZ/G2L)
* Memory: Defines the system memory region. 'reg' must accurately reflect your DRAM configuration (address and size)
* reserved memory: Contiguous Memory Allocator reserved at 0x58000000
* Clock: 24MHz external clock (EXTAL)
### Communication Interfaces
* Serial Console: SCIFO configured at 115200 baud (8N1)
* Ethernet: Gigabit Ethernet (RGMII)
* I2C: I2C1 interface enabled
* Display: MIPI-DSI (4 lanes) with ADV7535 HDMI bridge
* HDMI Output: Type-D connector
* USB:
  * USB0: OTG mode (host/device capable)
  * USB1: Host-only mode
  * Both controllers support USB2.0 (EHCI) and USB 1.1 (OHCI)
* Storage:
  * eMMC: eMMC interface. Sets power supplies, bus width and other properties.
  * SD Card: SD card interface. Sets power supplies, bus width and card detect.
* Power Supplies:
  The board includes several fixed voltage regulators:
  * reg_1p1v: core voltage (1.1V)
  * reg_1p8v: 1.8V rail
  * reg_3p3V: 3.3V rail
  * vccq_sdhi1: Adjustable VccQ voltage for SD card (1.8V/3.3V)
  * usb0_vbud_otg: Regulator for USB OTG
* Timers:
  * Watchdog Timer: Enables the watchdog timer with a timeout of 60 Seconds
  * Operating System Timers: Enables operating system timers
## Pin Configurations
  The device tree configures pins for the following interfaces:
  * SCIF0: TxD (38,0), RxD (38,1)
  * eMMC: 8-bit data, clock, command, reset (all at 1.8V)
  * SD Card: 4-bit data, clock, command (switchable 1.8V/3.3V), card detect (19,0)
  * I2C1: SDA, SCL with input enabled
  * Ethernet: RGMII interface with MDC, MDIO, TX/RX pins (1.8V)
  * USB0: VBUS (4,0), OVC (5,0), OTG_ID (5,1)
  * USB1: VBUS (42,0), OVC (42,1)
 ## Device Aliases
 The following device aliases are configured:
 * serial0 : SCIF0 (/dev/ttySC0)
 * i2c1 : I2C1 controller
 * mmc0 : SDHI0 (eMMC, /dev/mmcblk0)
 * mmc1 : SDHI1 (SD card, /dev/mmcblk1)
 * ethernet0 : eth0 (Ethernet controller)
## Important Considearions:
### Board Identification:
  * Update the "compatible" property with your company and board name
  * Keep "renesas,r9a07g044" in the compatible string for driver compatibility
### Memory Configuration:
  * Verify and adjust the memory size according to your board's RAM configuration
  * The CMA size (256MB) can be adjusted based on your application needs
### Storage Configuration:
  * Uncomment mmc-hs200-1_8v in the eMMC node if your board supports HS200 mode
  * Uncomment sd-uhs-sdr50 and sd-uhs-sdr104 in the SD card node if UHS modes are supported
### Display Configuration:
  * The MIPI-DSI to HDMI bridge (ADV7535) is configured for 4-lane operation
  * HDMI connector is configured as type D (micro HDMI)
## Building the Device Tree:
* Add your sample device tree file into the Device Tree source directory arch/arm64/boot/dts/renesas
* Add your sample device file in Makefile located in arch/arm64/boot/dts/renesas/Makefile to build the Device Tree Blub (DTB)
* follow instruction here https://confluence.renesas.com/display/REN/Yocto+Information#YoctoInformation-BuildDTBonlywithYocto to build DTB
* Copy the built DTB yo your boot medium or the appropriate location where your bootloader expects to find it
