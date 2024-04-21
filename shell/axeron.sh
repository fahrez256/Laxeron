cp /sdcard/Android/data/com.fhrz.axeron/files/axeron.function /data/local/tmp; chmod +x /data/local/tmp/axeron.function; source /data/local/tmp/axeron.function; check_axeron; echo "[Execution-start]\n"; !myCommands
local myCommands="!myCommands"
if ! type $(echo $myCommands | cut -d " " -f 1) > ${EXECPATH}/axeron_log.txt 2>&1; then
    echo "sh: axeron-function[$(echo $myCommands | cut -d " " -f 1)?]: inaccessible functions"
fi

echo "\n[Execution-end]\n"
