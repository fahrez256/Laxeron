export FUNCTION="/data/local/tmp/axeron.function"; cp /sdcard/Android/data/com.fhrz.axeron/files/axeron.function /data/local/tmp; chmod +x $FUNCTION; . $FUNCTION; check_axeron; !myCommands
local getError=$(echo ( (!myCommands) | cut -d ':' -f 3 ))
echo -e "$getError"
