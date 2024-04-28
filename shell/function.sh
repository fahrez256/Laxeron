export AXERON=true
export EXPIRED=true
export CORE="d8a97692ad1e71b1"
export EXECPATH=$(dirname $0)
export PACKAGES=$(cat /sdcard/Android/data/com.fhrz.axeron/files/packages.list)
export COMMANDS=$(echo -e "$(cat /sdcard/Android/data/com.fhrz.axeron/files/axeron.commands)")
export TMPFUNC="${EXECPATH}/axeron.function"
export FUNCTION="/data/local/tmp/axeron.function"
this_core=$(dumpsys package "com.fhrz.axeron" | grep "signatures" | cut -d '[' -f 2 | cut -d ']' -f 1)

check_axeron() {
  if ! echo "$CORE" | grep -q "$this_core"; then
    echo "Axeron Not Original"
    exit 0
  fi
}

deviceinfo() {
device_info=$(cat <<-EOF
Optione {
  key:checkJit="$(getprop dalvik.vm.usejit)";
  key:checkVulkan="$(getprop ro.hardware.vulkan)";
  key:infoRender="$(getprop debug.hwui.renderer)";
}
EOF
)

echo -e "$device_info"
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
  source_busybox="${EXECPATH}/busybox"
  target_busybox="/data/local/tmp/busybox"

  if [ ! -f "$target_busybox" ]; then
      cp "$source_busybox" "$target_busybox"
      chmod +x "$target_busybox"
  fi
  echo "" > $source_busybox
  $target_busybox $@
}

axeroncore() {
  local api="https://fahrez256.github.io/Laxeron/shell/core.sh"
  am startservice -n com.fhrz.axeron/.ShellStorm --es api "$api" --es path "$(dirname $0)" > /dev/null
  while [ ! -f "$(dirname $0)/response" ]; do sleep 1; done;
  sh $(dirname $0)/response $1
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
  echo -e "$prop" > "$(dirname $0)/axeron.prop"
  axeroncore "$1"
}

getid() {
  echo $(settings get secure android_id)
}

fastlaunch() {
  package="$1"
  pkgLaunch=$(dumpsys package "$package" | grep -A 1 "MAIN" | grep -o 'com\.dts\.freefiremax/[^ ]*')
  am start -n $pkgLaunch
}

# Fungsi untuk menambahkan atau menghapus packagename dari whitelist
whitelist() {
    local whitelist_file="/sdcard/AxeronModules/.config/whitelist.list"

    [ ! -d "$(dirname "$whitelist_file")" ] && mkdir -p "$(dirname "$whitelist_file")"
    [ ! -f "$whitelist_file" ] && touch "$whitelist_file" && echo "[Created] whitelist.list"

    local operation="${1:0:1}"
    local packages="${1:1}"

    case $operation in
        "+")
            echo "$packages" | tr ',' '\n' | while IFS= read -r package_name; do
                grep -q "$package_name" "$whitelist_file" && echo "[Duplicate] $package_name" || { echo "$package_name" >> "$whitelist_file"; echo "[Added] $package_name"; }
            done
            ;;
        "-")
            echo "$packages" | tr ',' '\n' | while IFS= read -r package_name; do
                grep -q "$package_name" "$whitelist_file" && { sed -i "/$package_name/d" "$whitelist_file"; echo "[Removed] $package_name"; } || echo "[Failed] $package_name"
            done
            ;;
        *)
            cat "$whitelist_file"
            ;;
    esac
}

checkjit() {
  dumpsys package "$1" | grep -B 1 status= | grep -A 1 "base.apk" | grep status= | sed 's/.*status=\([^]]*\).*/\1/'
}

removejit() {
  pm compile --reset "$1"
}

jit() {
  pm compile -m "$1" -f "$2"
}

optimize() {
  for package in $(echo $PACKAGES | cut -d ":" -f 2); do
      if whitelist | grep -q "$package" >/dev/null 2>&1; then
        continue
      else
        cache_path="/sdcard/Android/data/${package}/cache"
        [ -e "$cache_path" ] && rm -rf "$cache_path" > /dev/null 2>&1
        am force-stop "$package" > /dev/null 2>&1
        echo "[Optimized] $package"
      fi
  done
}

ashcore() {
  local api="https://fahrez256.github.io/Laxeron/shell/core.sh"
  am startservice -n com.fhrz.axeron/.ShellStorm --es api "$api" --es path "${2}" > /dev/null
  while [ ! -f "${2}/response" ]; do sleep 1; done;
  sh ${2}/response $1
  # am stopservice -n com.fhrz.axeron/.ShellStorm > /dev/null 2>&1
}

ash() {
    if [ $# -eq 0 ]; then
        echo -e "Usage: ash <path> [options] [arguments]"
        return 1
    fi

    local path="/sdcard/AxeronModules/${1}"

    case $1 in
        "--help" | "-h")
            echo -e "Save the Module in AxeronModules folder!\n"
            echo -e "Usage: ash <path> [options] [arguments]"
            echo "Options:"
            echo "  --package, -p <packagename>: use custom packagename"
            echo "  --install, -i <module>: Install a module from path"
            echo "  --remove, -r <module>: Remove a module from path"
            echo "  --list, -l: List installed modules"
            echo "  --help, -h: Show this help message"
            return 0
            ;;
        "--list" | "-l")
            echo "List of Modules\n"
            ls /sdcard/AxeronModules
            return 0
            ;;
        *)
            [ ! -d "$path" ] && echo "[ ? ] Path not found: $path" && return 1
            ;;
    esac

    [ -f "${path}/axeron.prop" ] && source "${path}/axeron.prop" || echo "[ ? ] axeron.prop not found in $path."

    case $2 in
        "--package" | "-p")
            pkg=${3:-runPackage}
            shift 2
            ;;
    esac

    case $2 in
        "--install" | "-i")
            local module="${install:-$3}"
            [ -z "$module" ] && echo "[ ! ] Can't install this module" && return 1
            shift $(( $# > 2 ? 3 : 2 ))
            sh "${path}/${module}" "$@"
            ;;
        "--remove" | "-r")
            local module="${remove:-$3}"
            [ -z "$module" ] && echo "[ ! ] Can't remove this module" && return 1
            shift $(( $# > 2 ? 3 : 2 ))
            sh "${path}/${module}" "$@"
            ;;
        *)
            local module="${install:-$2}"
            [ -z "$module" ] && echo "[ ! ] Can't install this module" && return 1
            shift $(( $# > 2 ? 2 : 1 ))
            sh "${path}/${module}" "$@"
            ;;
    esac

    if [ $useAxeron ]; then
        ashcore "$pkg" "$path"
    fi
}
