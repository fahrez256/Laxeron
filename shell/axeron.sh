cp /sdcard/Android/data/com.fhrz.axeron/files/axeron.function /data/local/tmp; chmod +x /data/local/tmp/axeron.function; source /data/local/tmp/axeron.function; check_axeron; echo "[Execution-start]"; !myCommands 2>${EXECPATH}/error.txt
local myCommands="!myCommands"
IFS=$'\n;'
for cmd in $myCommands; do
    # Menghapus spasi tambahan dari setiap perintah
    cmd=$(echo "$cmd" | sed 's/^[[:space:]]*//')

    myOperator=$(echo "$cmd" | cut -d ' ' -f 1)
    myArgument=$(echo "$cmd" | cut -d ' ' -f 2-)

    # Memeriksa apakah myOperator tersedia
    if ! type "$myOperator" > "${EXECPATH}/axeron_log.txt" 2>&1; then
        # Menjalankan perintah myOperator jika direktori sesuai ditemukan
        if [ -d "/sdcard/AxeronModules/${myOperator}" ]; then
            ash "$myOperator" "$myArgument"
        else
            echo "sh: axeron-function[${myOperator}?]: inaccessible functions"
        fi
    fi
done
echo "[Execution-end]\n"
