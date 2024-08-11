$AXFUN
import axeron.prop
#echo $(realpath $0)
w="[ ! ]" #warn
i="[ ? ]" #info
p="[ • ]" #process
s="[ ✓ ]" #success
axeron="com.fhrz.axeron"
host="fahrez256.github.io"
host_path="/Laxeron/Core_2404.txt"
id_path="/Laxeron/Id_2404.txt"
log_path="/sdcard/Android/data/${axeron}/files"
log_file="${log_path}/log.txt"
this_core=$(dumpsys package ${axeron} | grep "signatures" | cut -d '[' -f 2 | cut -d ']' -f 1)
vCode=4100
vName="V4.2 ShellStorm"
vAxeron=10240121
androidId=$(settings get secure android_id)

#echo "core $@"

if [ -n "$1" ] && [ "$1" == "-p" ];then
        if [ -n "$2" ]; then
            axprop $path_axeronprop runPackage -s "$2"
            runPackage="$2"
            shift 2
        else
            shift
        fi
fi

axeron_core=$(cat <<-EOF
Optione {
  key:id="$id";
  key:name="$name";
  key:version="$version";
  key:versionCode=${versionCode};
  key:author="$author";
  key:description="$description";
  key:runPackage="$runPackage";
  key:install="$install";
  key:remove="$remove";
}
EOF
)

core_info=$(cat <<-EOF
Optione {
  key:versionCode=${vCode};
  key:versionAxeron=${vAxeron};
  key:androidId="$androidId";
  key:host="$host";
  key:hostPath="$host_path";
  key:idPath="$id_path";
  key:versionName="$vName";
  key:axeronSupport=${vAxeron};
}
EOF
)

join_channel() {
  sleep 1
  link="https://t.me/fahrezone_ch"
  am start -a android.intent.action.VIEW -d "$link" > /dev/null 2>&1
}

c_exit() {
  echo ""
  [ -f "response" ] && rm -f "response" > /dev/null 2>&1
  exit 0
}

optimize_app() {
  for package in $(echo $PACKAGES | cut -d ":" -f 2); do
      if whitelist | grep -q "$package" >/dev/null 2>&1; then
        continue
      else
        cache_path="/sdcard/Android/data/${package}/cache"
        [ -e "$cache_path" ] && rm -rf "$cache_path" > /dev/null 2>&1
        am force-stop "$package" > /dev/null 2>&1
      fi
  done
}

echo ""
if [ "$AXERON" ]; then
    if ! echo "$CORE" | grep -q "$this_core"; then
        echo "$w You must use the original version of Axeron"
        join_channel
        c_exit
    fi
else
    PACKAGES=$(cmd package list packages -3 | sed 's/package://')
fi

if [ -z "$runPackage" ]; then
  echo "$w PackageName is empty" && c_exit
elif ! echo "$PACKAGES" | grep -qw "$runPackage"; then
  echo "$w PackageName is not detected or installed" && c_exit
fi

mkdir -p "$log_path"

current_time=$(date +%s%3N)
last_time=$(cat "$log_file") > /dev/null 2>&1
time_diff=$((current_time - last_time))

if [ "$time_diff" -ge 3600000 ] || [ ! -e "$log_file" ]; then
  echo "$p Optimizing AxeronCore"
  optimize_app
  echo -n "$current_time" > "$log_file"
fi

if command -v am > /dev/null && command -v pm > /dev/null; then
  echo "$p Executing AxeronCore [${vName} (${vCode})]" && sleep 1
else
  echo "$w ActivityManager & PackageManager not Permitted" && c_exit
fi

if echo "$PACKAGES" | grep -qw "$axeron"; then
  echo "$s Axeron is detected [Fast Connect]" && sleep 1
else
  echo "$w Axeron not Installed"
  echo "$i Please download Axeron app from FahrezONE officially"
  join_channel
  c_exit
fi

sleep 1 && am start -a android.intent.action.VIEW -n "com.fhrz.axeron/.Process" --es AXERON "$axeron_core" --es CORE "$core_info" #> /dev/null 2>&1 || echo "$w Failed to open Axeron"
c_exit
