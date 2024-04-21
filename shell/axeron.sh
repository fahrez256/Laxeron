cp /sdcard/Android/data/com.fhrz.axeron/files/axeron.function /data/local/tmp; chmod +x /data/local/tmp/axeron.function; source /data/local/tmp/axeron.function; check_axeron; !myCommands
if ! type "!myCommands" > /dev/null 2>&1; then
    echo "!myCommands not found"
fi
