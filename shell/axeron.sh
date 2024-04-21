cp /sdcard/Android/data/com.fhrz.axeron/files/axeron.function /data/local/tmp; chmod +x /data/local/tmp/axeron.function; source /data/local/tmp/axeron.function; check_axeron; (!myCommands) 2>${EXECPATH}/error.txt
local myCommands="!myCommands"
if ! type $( $myCommands | cut -d " " -f 1 ) > ${EXECPATH}/axeron_log.txt 2>&1; then
    echo "[$myCommands] [ ? ] is not detected in depedencies"
    echo ""
    echo -e $(cat ${EXECPATH}/error.txt)
fi
