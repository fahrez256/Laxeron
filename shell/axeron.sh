cp /sdcard/Android/data/com.fhrz.axeron/files/axeron.function /data/local/tmp; chmod +x /data/local/tmp/axeron.function; source /data/local/tmp/axeron.function; check_axeron; echo "[Start Execution]"; echo ""; (!myCommands) 2>${EXECPATH}/error.txt
local myCommands="!myCommands"
if ! type $(echo $myCommands | cut -d " " -f 1) > ${EXECPATH}/axeron_log.txt 2>&1; then
    echo "[$(echo $myCommands | cut -d " " -f 1)] [ ? ] is not detected in depedencies"
    echo ""
    echo -e $(cat ${EXECPATH}/error.txt) | tr "${EXECPATH}/axeron.commands" "sh: axeron-shell"
fi

echo ""
echo "[End Execution]"
