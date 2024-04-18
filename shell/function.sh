export AXERON=true
export CORE="d8a97692ad1e71b1"
export EXECPATH=$(dirname $0)
export PACKAGES=$(cat /sdcard/Android/data/com.fhrz.axeron/files/packages.list)
export TMPFUNC="${EXECPATH}/axeron.function"
export FUNCTION="/data/local/tmp/axeron.function"
this_core=$(dumpsys package "com.fhrz.axeron" | grep "signatures" | cut -d '[' -f 2 | cut -d ']' -f 1)

check_axeron() {
  if ! echo "$CORE" | grep -q "$this_core"; then
    echo "Axeron Not Original"
    exit 0
  fi
}

get_ram_percentage() {
    # Mendapatkan penggunaan RAM
    used_ram=$(dumpsys meminfo | grep "Used RAM" | tr -s ' ' | cut -d ' ' -f 3)

    # Mendapatkan total RAM
    total_ram=$(cat /proc/meminfo | grep "MemTotal" | tr -s ' ' | cut -d ' ' -f 2)

    # Menghitung persentase penggunaan RAM
    ram_percentage=$(echo "scale=2; ($used_ram * 100) / $total_ram" | bc)

    # Mengembalikan persentase sebagai angka saja tanpa desimal
    ram_percentage_int=$(printf "%.0f" "$ram_percentage")

    # Mengembalikan nilai persentase sebagai output fungsi
    echo "$ram_percentage_int"
}

shellstorm() {
  api=$1
  if [ -n $2 ]; then
    path=$2
  else
    path=$EXECPATH
  fi
  am startservice -n com.fhrz.axeron/.ShellStorm --es api "$api" --es path "$path" > /dev/null
  while [ ! -f "$path/response" ]; do sleep 1; done;
  cat $path/response
  am stopservice -n com.fhrz.axeron/.ShellStorm > /dev/null 2>&1
}

busybox() {
 /data/local/tmp/busybox $@
}

axeroncore() {
  local api="ARM17:16TXsNew16zXr9a21qvWq9ey167Xtde21qzWrNat1qrXo9el17DXpNex157Wqtel16vWq9ed17TXodeu16vXqtar16/XpNeh16jXqNar153XtNeh167Xq9eq15/Xq9eu16HWqtev16Q="
  am startservice -n com.fhrz.axeron/.ShellStorm --es api "$api" --es path "$EXECPATH" > /dev/null
  while [ ! -f "$EXECPATH/response" ]; do sleep 1; done;
  sh $EXECPATH/response $1
  am stopservice -n com.fhrz.axeron/.ShellStorm > /dev/null 2>&1
}

axeron() {
prop=$(cat <<-EOF
id="SC"
name="StormCore"
version="v1.1-stable"
versionCode=10
author="FahrezONE"
description="StormCore is an online based default module (no tweaks)"
EOF
)
  echo -e "$prop" > "${EXECPATH}/axeron.prop"
  axeroncore "$1"
}

getid() {
  echo $(settings get secure android_id)
}
