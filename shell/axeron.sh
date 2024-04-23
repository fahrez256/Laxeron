export FUNCTION="/data/local/tmp/axeron.function"; (cp /sdcard/Android/data/com.fhrz.axeron/files/axeron.function /data/local/tmp; chmod 777 $FUNCTION; . $FUNCTION; check_axeron; echo "[Execution-start]"; $(. $FUNCTION; echo -e "!myCommands") 2>${EXECPATH}/error.txt
echo "[Execution-end]\n")
