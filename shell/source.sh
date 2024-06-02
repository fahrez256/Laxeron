thisfunc="/data/local/tmp/axeron.function"
cp /sdcard/Android/data/com.fhrz.axeron/files/axeron.function /data/local/tmp
chmod +x $thisfunc
. $thisfunc
this_core=$(dumpsys package "$AXERONPKG" | grep "signatures" | cut -d '[' -f 2 | cut -d ']' -f 1)
check_axeron() {
  [[ -z $AXERONPKG || $AXERONPKG != "com.fhrz.axeron" ]] && echo "Hacked by Aldo (Chermods) (Maintenance)" && exit 0
  if echo "$CORE" | grep -q "$this_core"; then
    echo "Axeron Not Original"
    exit 0
  fi
}
