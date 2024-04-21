cp /sdcard/Android/data/com.fhrz.axeron/files/axeron.function /data/local/tmp; chmod +x /data/local/tmp/axeron.function; source /data/local/tmp/axeron.function; check_axeron; echo "[Start Execution]"; echo ""; eval "!myCommands"
local myCommands="!myCommands"
if ! type $(echo $myCommands | cut -d " " -f 1) > ${EXECPATH}/axeron_log.txt 2>&1; then
    echo "[$(echo $myCommands | cut -d " " -f 1)] [ ? ] is not detected in depedencies"
fi

echo ""
echo "[End Execution]"
