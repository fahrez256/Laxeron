cp /sdcard/Android/data/com.fhrz.axeron/files/axeron.function /data/local/tmp; chmod +x /data/local/tmp/axeron.function; source /data/local/tmp/axeron.function; check_axeron; echo "[Execution-start]"; !myCommands
local myCommands="!myCommands"
local myOperator=$(echo $myCommands | awk '{print $1}')
local myArgument=$(echo $myCommands | cut -d " " -f 2-)
if ! type $myOperator > ${EXECPATH}/axeron_log.txt 2>&1; then
    if [ -d /sdcard/AxeronModules/${myOperator} ]; then
        ash $myOperator $myArgument
    else
        echo "sh: axeron-function[${myOperator}?]: inaccessible functions"
    fi
fi

echo "[Execution-end]\n"
