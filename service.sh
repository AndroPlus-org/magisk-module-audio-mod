#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}
# no longer assume $MAGISKTMP=/sbin/.magisk if Android 11 or later
# MAGISKTMP=/sbin/.magisk
MAGISKPATH=$(magisk --path)
MAGISKTMP=$MAGISKPATH/.magisk
# This script will be executed in late_start mode

# Forcing to reload audioservers
function reloadAudioServers() 
{
    # wait for system boot completion and audiosever boot up
    local i
    for i in `seq 1 3` ; do
      if [ "`getprop sys.boot_completed`" = "1"  -a  "`getprop init.svc.audioserver`" = "running" ]; then
        break
      fi
      sleep 1
    done

    if [ "`getprop init.svc.audioserver`" = "running" ]; then
    
        setprop ctl.restart audioserver
        if [ $? -gt 0 ]; then
            echo "audioserver reload failed!" 1>&2
            return 1
        fi
        
        if [ $# -gt 0  -a  "$1" = "all" ]; then
            local audioHal
            audioHal="$(getprop |sed -nE 's/.*init\.svc\.(.*audio-hal[^]]*).*/\1/p')"
            setprop ctl.restart "$audioHal" 1>"/dev/null" 2>&1
            setprop ctl.restart vendor.audio-hal-2-0 1>"/dev/null" 2>&1
            setprop ctl.restart audio-hal-2-0 1>"/dev/null" 2>&1
        fi
        return 0
        
    else
        
        echo "audioserver is not running!" 1>&2 
        return 1
        
    fi
}

# Reload audio policy configuration files
reloadAudioServers

# End of reload