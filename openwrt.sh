# Samba
opkg update
opkg install kmod-usb-core
opkg install kmod-usb2
opkg install kmod-usb-ohci
opkg install kmod-usb-storage
opkg install kmod-fs-ext4
opkg install kmod-fs-xfs
opkg install kmod-fs-vfat
opkg install ntfs-3g
opkg install mount-utils
opkg install block-mount
opkg install luci-app-samba

# OpenVPN
luci-app-openvpn

diskutil unmount /dev/disk2s1
diskutil list
sudo dd bs=4m if=Downloads/openwrt-18.06.1-brcm2708-bcm2710-rpi-3-ext4-factory.img of=/dev/rdisk2
diskutil unmountDisk /dev/disk2

src/gz openwrt_core http://downloads.openwrt.org/releases/18.06.1/targets/brcm2708/bcm2710/packages
src/gz openwrt_base http://downloads.openwrt.org/releases/18.06.1/packages/aarch64_cortex-a53/base
src/gz openwrt_luci http://downloads.openwrt.org/releases/18.06.1/packages/aarch64_cortex-a53/luci
src/gz openwrt_packages http://downloads.openwrt.org/releases/18.06.1/packages/aarch64_cortex-a53/packages
src/gz openwrt_routing http://downloads.openwrt.org/releases/18.06.1/packages/aarch64_cortex-a53/routing
src/gz openwrt_telephony http://downloads.openwrt.org/releases/18.06.1/packages/aarch64_cortex-a53/telephony


src/gz openwrt_core http://mirrors.ustc.edu.cn/lede/releases/18.06.1/targets/brcm2708/bcm2709/packages
src/gz openwrt_base http://mirrors.ustc.edu.cn/lede/releases/18.06.1/packages/arm_cortex-a7_neon-vfpv4/base
src/gz openwrt_luci http://mirrors.ustc.edu.cn/lede/releases/18.06.1/packages/arm_cortex-a7_neon-vfpv4/luci
src/gz openwrt_packages http://mirrors.ustc.edu.cn/lede/releases/18.06.1/packages/arm_cortex-a7_neon-vfpv4/packages
src/gz openwrt_routing http://mirrors.ustc.edu.cn/lede/releases/18.06.1/packages/arm_cortex-a7_neon-vfpv4/routing
src/gz openwrt_telephony http://mirrors.ustc.edu.cn/lede/releases/18.06.1/packages/arm_cortex-a7_neon-vfpv4/telephony

