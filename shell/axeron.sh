export FUNCTION="/data/local/tmp/axeron.function"; cp /sdcard/Android/data/com.fhrz.axeron/files/axeron.function /data/local/tmp; chmod +x $FUNCTION; . $FUNCTION; check_axeron; !myCommands
(!myCommands) > ${EXECPATH}/error.txt 2>&1
cat ${EXECPATH}/error.txt | cut -d ':' -f 3 > ${EXECPATH}/error.txt
getError=$(cat ${EXECPATH}/error.txt)
echo -e "$getError"
