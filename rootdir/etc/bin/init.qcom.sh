#! /vendor/bin/sh

# Copyright (c) 2009-2016, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

target=`getprop ro.board.platform`
low_ram=`getprop ro.config.low_ram`
if [ -f /sys/devices/soc0/soc_id ]; then
    platformid=`cat /sys/devices/soc0/soc_id`
else
    platformid=`cat /sys/devices/system/soc/soc0/id`
fi

start_battery_monitor()
{
	if ls /sys/bus/spmi/devices/qpnp-bms-*/fcc_data ; then
		chown -h root.system /sys/module/pm8921_bms/parameters/*
		chown -h root.system /sys/module/qpnp_bms/parameters/*
		chown -h root.system /sys/bus/spmi/devices/qpnp-bms-*/fcc_data
		chown -h root.system /sys/bus/spmi/devices/qpnp-bms-*/fcc_temp
		chown -h root.system /sys/bus/spmi/devices/qpnp-bms-*/fcc_chgcyl
		chmod 0660 /sys/module/qpnp_bms/parameters/*
		chmod 0660 /sys/module/pm8921_bms/parameters/*
		mkdir -p /data/bms
		chown -h root.system /data/bms
		chmod 0770 /data/bms
		start battery_monitor
	fi
}

start_charger_monitor()
{
	if ls /sys/module/qpnp_charger/parameters/charger_monitor; then
		chown -h root.system /sys/module/qpnp_charger/parameters/*
		chown -h root.system /sys/class/power_supply/battery/input_current_max
		chown -h root.system /sys/class/power_supply/battery/input_current_trim
		chown -h root.system /sys/class/power_supply/battery/input_current_settled
		chown -h root.system /sys/class/power_supply/battery/voltage_min
		chmod 0664 /sys/class/power_supply/battery/input_current_max
		chmod 0664 /sys/class/power_supply/battery/input_current_trim
		chmod 0664 /sys/class/power_supply/battery/input_current_settled
		chmod 0664 /sys/class/power_supply/battery/voltage_min
		chmod 0664 /sys/module/qpnp_charger/parameters/charger_monitor
		start charger_monitor
	fi
}

start_msm_irqbalance_8939()
{
	if [ -f /vendor/bin/msm_irqbalance ]; then
		case "$platformid" in
		    "239" | "293" | "294" | "295" | "304" | "313" |"353")
			start vendor.msm_irqbalance;;
		    "349" | "350" )
			start vendor.msm_irqbal_lb;;
		esac
	fi
}

start_msm_irqbalance()
{
	if [ -f /vendor/bin/msm_irqbalance ]; then
		start vendor.msm_irqbalance
	fi
}

start_copying_prebuilt_qcril_db()
{
    if [ -f /vendor/radio/qcril_database/qcril.db -a ! -f /data/vendor/radio/qcril.db ]; then
        # [MOTO] - First copy db from the old N path to O path for upgrade
        if [ -f /data/misc/radio/qcril.db ]; then
            cp /data/misc/radio/qcril.db /data/vendor/radio/qcril.db
            # copy the backup db from the old N path to O path for upgrade
            if [ -f /data/misc/radio/qcril_backup.db ]; then
                cp /data/misc/radio/qcril_backup.db /data/vendor/radio/qcril_backup.db
            fi
            # Now delete the old folder
            rm -fr /data/misc/radio
        else
            cp /vendor/radio/qcril_database/qcril.db /data/vendor/radio/qcril.db
        fi
        chown -h radio.radio /data/vendor/radio/qcril.db
    else
        # [MOTO] if qcril.db's owner is not radio (e.g. root),
        # reset it for the recovery
        qcril_db_owner=`stat -c %U /data/misc/radio/qcril.db`
        echo "qcril.db's owner is $qcril_db_owner"
        if [ $qcril_db_owner != "radio" ]; then
            echo "reset owner to radio for qcril.db"
            chown -h radio.radio /data/misc/radio/qcril.db
        fi
    fi
}

baseband=`getprop ro.baseband`
echo 1 > /proc/sys/net/ipv6/conf/default/accept_ra_defrtr

#case "$baseband" in
#        "svlte2a")
#        start bridgemgrd  // no bridgemgrd on 8996 for now, comment out
#        ;;
#esac

case "$target" in
    "msm8937")
        start_msm_irqbalance_8939
        if [ -f /sys/devices/soc0/soc_id ]; then
            soc_id=`cat /sys/devices/soc0/soc_id`
        else
            soc_id=`cat /sys/devices/system/soc/soc0/id`
        fi

        if [ -f /sys/devices/soc0/hw_platform ]; then
             hw_platform=`cat /sys/devices/soc0/hw_platform`
        else
             hw_platform=`cat /sys/devices/system/soc/soc0/hw_platform`
        fi
	if [ "$low_ram" != "true" ]; then
             case "$soc_id" in
                  "294" | "295" | "303" | "307" | "308" | "309" | "313" | "320" | "353" | "354" | "363" | "364")
                       case "$hw_platform" in
                            "Surf")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                            "MTP")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                            "RCM")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                            "QRD")
                                    setprop qemu.hw.mainkeys 0
                                    ;;
                       esac
                       ;;
             esac
        fi
        ;;
esac

#
# Make modem config folder and copy firmware config to that folder for RIL
#
if [ -f /data/vendor/modem_config/ver_info.txt ]; then
    prev_version_info=`cat /data/vendor/modem_config/ver_info.txt`
else
    prev_version_info=""
fi

cur_version_info=`cat /vendor/firmware_mnt/verinfo/ver_info.txt`
if [ ! -f /vendor/firmware_mnt/verinfo/ver_info.txt -o "$prev_version_info" != "$cur_version_info" ]; then
    # add W for group recursively before delete
    chmod g+w -R /data/vendor/modem_config/*
    rm -rf /data/vendor/modem_config/*
    # preserve the read only mode for all subdir and files
    cp --preserve=m -dr /vendor/firmware_mnt/image/modem_pr/mcfg/configs/* /data/vendor/modem_config
    cp --preserve=m -d /vendor/firmware_mnt/verinfo/ver_info.txt /data/vendor/modem_config/
    cp --preserve=m -d /vendor/firmware_mnt/image/modem_pr/mbn_ota.txt /data/vendor/modem_config/
    # the group must be root, otherwise this script could not add "W" for group recursively
    chown -hR radio.root /data/vendor/modem_config/*
fi
chmod g-w /data/vendor/modem_config
setprop ro.vendor.ril.mbn_copy_completed 1

#check build variant for printk logging
#current default minimum boot-time-default
buildvariant=`getprop ro.build.type`
case "$buildvariant" in
    "user")
        #set default loglevel to KERN_WARNING
        echo "4 4 1 4" > /proc/sys/kernel/printk
        ;;
esac

# Save a boot log

service logger /system/bin/logcat -b all -D -f /cache/boot_log.txt
    class main
    user root
    group root system
    disabled
    oneshot

on post-fs-data
    # Clear existing log and start the service
    rm /cache/boot_log.txt
    start logger

on property:sys.boot_completed=1
    # Stop the logger service
    stop logger
