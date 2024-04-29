export AXERON=true
export EXPIRED=true
export CORE="d8a97692ad1e71b1"
export EXECPATH=$(dirname $0)
export PACKAGES=$(cat /sdcard/Android/data/com.fhrz.axeron/files/packages.list)
export COMMANDS=$(echo -e "$(cat /sdcard/Android/data/com.fhrz.axeron/files/axeron.commands)")
export TMPFUNC="${EXECPATH}/axeron.function"
export FUNCTION="/data/local/tmp/axeron.function"
whitelist_file="/sdcard/AxeronModules/.config/whitelist.list"
this_core=$(dumpsys package "com.fhrz.axeron" | grep "signatures" | cut -d '[' -f 2 | cut -d ']' -f 1)

check_axeron() {
  if ! echo "$CORE" | grep -q "$this_core"; then
    echo "Axeron Not Original"
    exit 0
  fi
}

axeroncore() {
  echo "axeroncore not supported :("
  sleep 1
  link="https://t.me/fahrezone_gc"
  am start -a android.intent.action.VIEW -d "$link" > /dev/null 2>&1
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

# busybox() {
#   source_busybox="${EXECPATH}/busybox"
#   target_busybox="/data/local/tmp/busybox"

#   if [ ! -f "$target_busybox" ]; then
#       cp "$source_busybox" "$target_busybox"
#       chmod +x "$target_busybox"
#   fi
#   echo "" > $source_busybox
#   $target_busybox $@
# }

getid() {
  echo $(settings get secure android_id)
}

set_perm() {
  local file=$1
  local owner=$2
  local group=$3
  local permission=$4
  local context=$5

  chown "$owner":"$group" "$file" || return 1
  chmod "$permission" "$file" || return 1
  [ -z "$context" ] && context=u:object_r:system_file:s0
  chcon "$context" "$file" || return 1
}

set_perm_recursive() {
  local directory=$1
  local owner=$2
  local group=$3
  local dir_permission=$4
  local file_permission=$5

  find "$directory" -type d -exec chown "$owner":"$group" {} +
  find "$directory" -type d -exec chmod "$dir_permission" {} +
  find "$directory" -type f -exec chown "$owner":"$group" {} +
  find "$directory" -type f -exec chmod "$file_permission" {} +
}

# Fungsi untuk menambahkan atau menghapus packagename dari whitelist
whitelist() {
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

setUsingAxeron() {
    sed -i "s/useAxeron=.*/useAxeron=$1/g" $(dirname $0)/axeron.prop
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
            sed -i "s/runPackage=\"[^\"]*\"/runPackage=\"${pkg}\"/g" ${path}/axeron.prop
            echo "PackageName saved in axeron.prop"
            shift 2
            ;;
    esac

    case $2 in
        "--remove" | "-r")
            if [ -z "$remove" ]; then
                if [ -z "${3}" ]; then
                    echo "[ ! ] Cant remove this module"
                else
                    local pathRemove="${path}/${3}"
                    if ls "${pathRemove}" >/dev/null 2>&1; then
                        shift 3
                        sh "${pathRemove}" "$@"
                    else
                        echo "[ ! ] Cant remove this module"
                    fi
                fi
            else
                shift 2
                sh "${path}/${remove}" "$@"
            fi
            ;;
        *)
            if [ -z "$install" ]; then
                if [ -z "${2}" ]; then
                    echo "[ ! ] Cant install this module"
                else
                    local pathInstall="${path}/${2}"
                    if ls "${pathInstall}" >/dev/null 2>&1; then
                        shift 2
                        sh "${pathInstall}" $@
                    else
                        echo "[ ! ] Cant install this module"
                    fi
                fi
            else
                shift 
                sh "${path}/${install}" $@
            fi
            ;;
    esac

    [ -f "${path}/axeron.prop" ] && source "${path}/axeron.prop" || ( echo "[ ? ] axeron.prop not found in $path."; return 0 )

    if [ $useAxeron ] && [ $useAxeron = true ]; then
        [ ! -d "$(dirname "$whitelist_file")" ] && mkdir -p "$(dirname "$whitelist_file")"
        [ ! -f "$whitelist_file" ] && touch "$whitelist_file"
        grep -q "com.fhrz.axeron" "$whitelist_file" || echo "$package_name" >> "$whitelist_file"
        grep -q "moe.shizuku.privileged.api" "$whitelist_file" || echo "$package_name" >> "$whitelist_file"
        ashcore "$pkg" "$path"
    fi
}
