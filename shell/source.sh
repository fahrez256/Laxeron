export AXERONPKG="!axPkg"
export AXERONID="!axId"
thisfunc="/data/local/tmp/axeron.function"
thiscfg="/sdcard/AxeronModules/.prop"
cp /sdcard/Android/data/com.fhrz.axeron/files/axeron.function /data/local/tmp
chmod +x $thisfunc
. $thisfunc
[ -f $thiscfg ] && . $thiscfg
this_core=$(dumpsys package "$AXERONPKG" | grep "signatures" | cut -d '[' -f 2 | cut -d ']' -f 1)
[[ -z $AXERONPKG || $AXERONPKG != "com.fhrz.axeron" ]] && echo "Something wrong, may be need Update?" && exit 0
if ! echo "$CORE" | grep -q "$this_core"; then
  echo "Axeron Not Original"
  exit 0
fi
if storm "https://raw.githubusercontent.com/fahrez256/Laxeron/main/ban_list.txt" | grep -iq "$AXERONID"; then
  echo "Banned"
  exit 999
fi
