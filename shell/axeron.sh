export FUNCTION="/data/local/tmp/axeron.function"; cp /sdcard/Android/data/com.fhrz.axeron/files/axeron.function /data/local/tmp; chmod +x $FUNCTION; . $FUNCTION; check_axeron; !myCommands
(!myCommands) > ${EXECPATH}/error.txt 2>&1
getError=$(cat ${EXECPATH}/error.txt)
echo "$getError" | cut -d ':' -f 2
