FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Add your custom DTS file
SRC_URI += "file://sample_dts_g2lc.dts"

# Add this to your bbappend
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