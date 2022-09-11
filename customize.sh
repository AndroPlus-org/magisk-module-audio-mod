REPLACE="
"

function getActivePolicyFile()
{
    dumpsys media.audio_policy | awk ' 
        /^ Config source: / {
            print $3
        }' 
}

# Board name e.g. "_cape"
BOARD=$(getprop ro.media.xml_variant.codecs)
FIRSTAPI=$(getprop ro.product.first_api_level)

if [ $FIRSTAPI -ge 31 ] ; then
	#Android 12 and later
	SEP=" "
else
	SEP=","
fi
# Better to use getActivePolicyFile but it can't handle OPLUS devices
APOLICY=/system/vendor/etc/audio/sku${BOARD}_qssi/
APOLICY_FILE=audio_policy_configuration.xml
MPROFILE_FILE=/system/vendor/etc/media_profiles${BOARD}.xml

#Copy original audio_policy_configuration.xml to the MODPATH
if [ -e "${APOLICY}${APOLICY_FILE}" ]; then
	mkdir -p ${MODPATH}${APOLICY}
	cp ${APOLICY}${APOLICY_FILE} ${MODPATH}${APOLICY}${APOLICY_FILE}

	# Disable DRC
	sed -i 's@speaker_drc_enabled="true"@speaker_drc_enabled="false"@' ${MODPATH}${APOLICY}${APOLICY_FILE}

	# Change sampling rate
	sed -i "/AUDIO_DEVICE_OUT_WIRED_HEADSET/{n;s/AUDIO_FORMAT_PCM_16_BIT/AUDIO_FORMAT_PCM_24_BIT_PACKED/;n;s/\"48000\"/\"48000${SEP}96000${SEP}192000\"/}" ${MODPATH}${APOLICY}${APOLICY_FILE}

	sed -i "/AUDIO_DEVICE_OUT_WIRED_HEADPHONE/{n;s/AUDIO_FORMAT_PCM_16_BIT/AUDIO_FORMAT_PCM_24_BIT_PACKED/;n;s/\"48000\"/\"48000${SEP}96000${SEP}192000\"/}" ${MODPATH}${APOLICY}${APOLICY_FILE}

	sed -i "/AUDIO_DEVICE_OUT_LINE/{n;s/AUDIO_FORMAT_PCM_16_BIT/AUDIO_FORMAT_PCM_24_BIT_PACKED/;n;s/\"48000\"/\"48000${SEP}96000${SEP}192000\"/}" ${MODPATH}${APOLICY}${APOLICY_FILE}

	sed -i "/name=\"primary output\"/{n;n;s/\"48000\"/\"48000${SEP}96000${SEP}192000\"/}" ${MODPATH}${APOLICY}${APOLICY_FILE}

	sed -i "/name=\"raw\"/{n;n;s/AUDIO_FORMAT_PCM_16_BIT/AUDIO_FORMAT_PCM_24_BIT_PACKED/;n;s/\"48000\"/\"48000${SEP}96000${SEP}192000\"/}" ${MODPATH}${APOLICY}${APOLICY_FILE}

	sed -i "/name=\"deep_buffer\"/{n;n;s/AUDIO_FORMAT_PCM_16_BIT/AUDIO_FORMAT_PCM_24_BIT_PACKED/;n;s/\"48000\"/\"48000${SEP}96000${SEP}192000\"/}" ${MODPATH}${APOLICY}${APOLICY_FILE}

fi

if [ -e "${MPROFILE_FILE}" ]; then
	cp ${MPROFILE_FILE} ${MODPATH}${MPROFILE_FILE}

	# Change audio bitrate
	sed -i '/AudioEncoderCap name="aac"/{n;s/maxBitRate="96000"/maxBitRate="288000"/}' ${MODPATH}${MPROFILE_FILE}
fi
