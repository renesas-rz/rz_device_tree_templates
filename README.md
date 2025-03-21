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
## Device Tree Debugging Tips:
* Verify the loaded device tree:
   Once board is booted, verify that the kernel has loaded your device tree
   <pre>cat /proc/device-tree/model</pre>
* Verify the external clock configuration:
   <pre>dmesg | grep -i "extal\|clock"</pre>
* Check the clock rate
   <pre>cat /sys/kernel/debug/clk/extal/clk_rate</pre>
* Debugging I2C
   <pre>i2cdetect -l # list all detected I2C buses </pre>
   <pre>i2cdetec -y 1 # Shows all devices on the specified I2C bus </pre>
* Debugging DU (Display Unit)
  <pre>dmesg | grep -i "du\|display" # Check DU driver loading </pre>
* Debugging DRM devices
  <pre>la -la /dev/dri/ # Check available DRM devices</pre>
  
 ## How to add custom sample device tree file in Renesas yocto build
 The best approch to add sample device tree file in Renesas yocto build is by adding your own meta layer. This process keeps your customization seperate and makes easier to maintain across updates.
 Please find the simple steps to add your cutom device tree (sample_dts_g2lc.dts) in Renesas yocto build:
 1. Create a new layer for your device using Yocto bitbake-layers tools
    <pre>
     $ cd ~/rzg_vlp_3.0.6 # cd path to yocto
     $ source poky/oe-init-build-env 
     $ bitbake-layers create-layer ../meta-custom-rzg2lc
    </pre>
    The new layer includes following folder structure
    <pre>
     meta-custom-rzg2lc
     ├── conf
     │   └── layer.conf
     ├── COPYING.MIT
     ├── README
     └── recipes-example
         └── example
             └── example_0.1.bb
    </pre>
     
    </pre>
3. Add your new layer to the build configuration
   <pre>
    $ bitbake-layers add-layer ../meta-custom-rzg2lc
   </pre>
4. In your new layer, create a recipe to append to the Renesas kernel recipe:
   <pre>
    $ mkdir -p meta-custom-rzg2lc/recipes-kernel/linux
   </pre>
5. Create a directory for your device tree files:
   <pre>
    mkdir -p meta-custom-rzg2lc/recipes-kernel/linux/files
   </pre>
6. Place your custom device tree file in the files directory:
   <pre>
    cp /path/to/your/sample_dts_g2lc.dts meta-custom-rzg2l/recipes-kernel/linux/files/
   </pre>
7. Create a .bbappend file for the Renesas kernel recipe:
   <pre>
    $ touch meta-custom-rzg2l/recipes-kernel/linux/linux-renesas_%.bbappend
   </pre>
8. Edit the .bbappend file to include your custom device tree:
   <pre>
    FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

    # Add your custom DTS file
    SRC_URI += "file://sample_dts_g2lc.dts"
    
    # Add this to bbappend
    KERNEL_DEVICETREE:append = " renesas/sample_dts_g2lc.dtb"
    
    do_configure:append() {
        # Copy custom DTS to kernel source tree
        cp ${WORKDIR}/sample_dts_g2lc.dts ${S}/arch/arm64/boot/dts/renesas/
        
        # Update the Makefile to include our DTS if not already there
        MAKEFILE="${S}/arch/arm64/boot/dts/renesas/Makefile"
        if ! grep -q "sample_dts_g2lc.dtb" ${MAKEFILE}; then
            echo "" >> ${MAKEFILE}
            echo "# Custom DTB added by meta-custom-rzg2lc" >> ${MAKEFILE}
            echo "dtb-\$(CONFIG_ARCH_R9A07G044) += sample_dts_g2lc.dtb" >> ${MAKEFILE}
        fi
    }
   </pre> 
9. Build the kernel
    <pre>
     $ bitbake linux-renesas -c  cleanall #clean previous build
     $ bitbake linux-renesas  # to build and deploy
    </pre>
After build is completed successfully, your device tree will be available in /build/tmp/deploy/images/samrc-rzg2lc folder. Sample meta-custom-rzg2l layer is also added in the repository for your reference.
## Important Note on bbappend file:
Add your device tree in KERNEL_DEVICETREE to ensure it gets built. With this approach, Yocto will build your DTB automatically and place it in the deploy directory, following the same pattern as the Renesas DTBs.
