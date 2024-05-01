export AXERON=true
export EXPIRED=true
export CORE="d8a97692ad1e71b1"
export EXECPATH=$(dirname $0)
local THISPATH="/sdcard/Android/data/com.fhrz.axeron/files"
export PACKAGES=$(cat ${THISPATH}/packages.list)
export COMMANDS=$(echo -e "$(cat ${THISPATH}/axeron.commands)")
export TMPFUNC="${THISPATH}/axeron.function"
export FUNCTION="/data/local/tmp/axeron.function"
whitelist_file="/sdcard/AxeronModules/.config/whitelist.list"
this_core=$(dumpsys package "com.fhrz.axeron" | grep "signatures" | cut -d '[' -f 2 | cut -d ']' -f 1)

check_axeron() {
  if ! echo "$CORE" | grep -q "$this_core"; then
    echo "Axeron Not Original"
    exit 0
  fi
}

cactus() {
  #Rem01Gaming
  if [ $# -eq 0 ]; then
    echo "Usage: cactus <path>"
    return 0
  fi

  # Set the path of the folder containing the files
  folder_path=$(echo "$1" | sed 's/\/$//')
  
  # Iterate through each file in the folder
  for file in "$folder_path"/*; do
    # Check if the path is a file (not a subdirectory)
    if [ -f "$file" ]; then
      # Use the 'cat' command to display the contents of the file
      echo "$file"
      echo ""
      cat "$file"
      echo ""
    fi
  done
}

fastlaunch() {
   am startservice -n com.fhrz.axeron/.Services.FastLaunch --es pkg "$1" > /dev/null
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
  key:checkVulkan="$(ls /system/lib/libvulkan.so > /dev/null 2>&1 && echo true || echo false)";
  key:infoRender="$(getprop debug.hwui.renderer)";
}
EOF
)
echo -e "$device_info"
}

checkcode() {
  echo "Child exitCode: $?"
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

set_perm() {
  #RiProG
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
  #RiProG
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

cclean() {
  #RiProG
  echo -ne "[Cleaning] Optimizing cache: "
  available_before=$(df /data | awk 'NR==2{print $4}')
  pm trim-caches 999G
  available_after=$(df /data | awk 'NR==2{print $4}')
  
  cleared_cache=$((available_after - available_before))
  
  if (( cleared_cache < 1024 )); then
    echo "$cleared_cache Bytes"
  elif (( cleared_cache < 1048576 )); then
    echo "$((cleared_cache / 1024)) KB"
  elif (( cleared_cache < 1073741824 )); then
    echo "$((cleared_cache / 1048576)) MB"
  else
    echo "$((cleared_cache / 1073741824)) GB"
  fi
}

# debloat_app <packagename>
debloat_app() {
  #RiProG
  package="$1"
  echo "Debloating system app with package name $package..."
  pm uninstall "$package" > /dev/null 2>&1
  pm disable-user "$package" > /dev/null 2>&1
  pm clear "$package" > /dev/null 2>&1
  
  package_list=$(pm list packages -d | cut -f 2 -d : | grep "$package")
  if [ "$package_list" ]; then
    echo "System app with package name $package has been successfully debloated."
  else
    echo "Failed to debloat system app with package name $package."
  fi
}

# restore_app <packagename>
restore_app() {
  #RiProG
  package="$1"
  echo "Restoring system app with package name $package..."
  pm enable "$package" > /dev/null 2>&1
  
  package_list=$(pm list packages -d | cut -f 2 -d : | grep "$package")
  if [ "$package_list" ]; then
    echo "Failed to restore system app with package name $package."
  else
    echo "System app with package name $package has been successfully restored."
  fi
}

# debloat_list
debloat_list() {
  #RiProG
  echo "List of disabled packages:"
  package_list=$(pm list packages -d | cut -f 2 -d :)
  if [ "$package_list" ]; then
    echo "$package_list"
  else
    echo "No apps have been debloated yet."
  fi
}

# Permission Bypasser
aperm() {
  #RiProG
  package=$2
  if pm list package | cut -f 2 -d : | grep "$package"
  then
      app_permissions=$(appops get "$package" | tr ' ' '\n' | grep '_' | tr -d ':')
      option=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  
      case $option in
          -b|--bypass)
              echo "Permissions bypassed for application $package:"
              for permission in $app_permissions; do
                  appops set "$package" "$permission" allow
                  echo "- $permission"
              done
              am force-stop "$package"
              ;;
          -d|--default)
              echo "Permissions reverted to default for application $package:"
              for permission in $app_permissions; do
                  appops set "$package" "$permission" default
                  echo "- $permission"
              done
              am force-stop "$package"
              ;;
          *)
              echo "Invalid option. Please use -b or -d."
              ;;
      esac
  else
      echo "Invalid package name."
  fi
}

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

jit() {
  if [ $# -eq 0 ]; then
    echo "Usage: jit [option/mode] <package_name>"
    return 0
  fi
  
  case $1 in
    "--check" | "-c")
      if [ $2 == "--sdex" ]; then
        cmd package dump "$3" | grep -B 1 status= | grep -A 1 "split_" | grep status= | sed 's/.*status=\([^]]*\).*/\1/' | head -n 1
      else
        cmd package dump "$2" | grep -B 1 status= | grep -A 1 "base.apk" | grep status= | sed 's/.*status=\([^]]*\).*/\1/'
      fi
      ;;
    "--reset" | "-r")
      if [ $2 == "--sdex" ]; then
        pm compile --reset --secondary-dex "$3"
      else
        pm compile --reset "$2"
      fi
      ;;
    "--help" | "-h")
      echo "Usage: jit <mode> <package_name>"
      echo "Option:"
      echo "  --check, -c <package_name>: Check if the package is JIT compiled."
      echo "  --reset, -r <package_name>: Reset JIT compilation for the package."
      echo "Mode:"
      echo "  [verify/speed/etc] <package_name>: Compile package using JIT mode."
      ;;
    *)
      if [ $2 == "--sdex" ]; then
        pm compile -m "$1" --secondary-dex -f "$3"
      else
        pm compile -m "$1" -f "$2"
      fi
      ;;
  esac
}


optimize() {
  cclean
  for package in $(echo $PACKAGES | cut -d ":" -f 2); do
    if whitelist | grep -q "$package" >/dev/null 2>&1; then
      continue
    else
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
  am startservice -n com.fhrz.axeron/.ShellStorm --es api "$api" --es path "${THISPATH}" > /dev/null
  while [ ! -f "${THISPATH}/response" ]; do sleep 1; done;
  cp ${THISPATH}/response $2
  sh ${2}/response $1
  # am stopservice -n com.fhrz.axeron/.ShellStorm > /dev/null 2>&1
}

ash() {
  if [ $# -eq 0 ]; then
    echo -e "Usage: ash <path> [options] [arguments]"
    return 1
  fi
  
  nohup=false
  
  case $1 in
    "--help" | "-h")
      echo -e "Save the Module in AxeronModules folder!\n"
      echo -e "Usage: ash <path> [options] [arguments]"
      echo "Options:"
      echo "  --package, -p <packagename>: use custom packagename"
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
      # if [ $1 == "--nohup" ] || [ $1 == "-nh" ]; then
      #   nohup=true
      #   shift
      # fi
      local path="/sdcard/AxeronModules/${1}"
      ;;
  esac

  [ ! -d "$path" ] && echo "[ ? ] Path not found: $path" && return 1
  local pathCash="/data/local/tmp/axeron_cash"
  [ ! -d "$pathCash" ] && mkdir -p $pathCash
  [ -n "$(ls -A $pathCash)" ] && rm -r ${pathCash}/*

  cp -r $path $pathCash
  local path="${pathCash}/${1}"
  find $path -type f -exec chmod +x {} \;

  [ -f "${path}/axeron.prop" ] && source "${path}/axeron.prop" || echo "[ ? ] axeron.prop not found in $path."

  case $2 in
    "--package" | "-p")
      pkg=${3:-runPackage}
      sed -i "s/runPackage=\"[^\"]*\"/runPackage=\"${pkg}\"/g" ${path}/axeron.prop
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
            if [ $nohup = true ]; then
              nohup ${pathRemove} $@
            else
              ${pathRemove} $@
            fi
          else
            echo "[ ! ] Cant remove this module"
          fi
        fi
      else
        shift 2
        [ $nohup = true ] && nohup ${path}/${remove} $@ || ${path}/${remove} $@
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
            [ $nohup = true ] && nohup ${pathInstall} $@ || ${pathInstall} $@
          else
            echo "[ ! ] Cant install this module"
          fi
        fi
      else
        shift 
        if [ $nohup = true ]; then
          nohup ${path}/${install} $@ &
        else
          ${path}/${install} $@
        fi
      fi
    ;;
  esac

  [ -f "${path}/axeron.prop" ] && source "${path}/axeron.prop" || ( echo "[ ? ] axeron.prop not found in $path."; return 0 )

  if [ $useAxeron ] && [ $useAxeron = true ]; then
    pm grant com.fhrz.axeron android.permission.SYSTEM_ALERT_WINDOW
    [ ! -d "$(dirname "$whitelist_file")" ] && mkdir -p "$(dirname "$whitelist_file")"
    [ ! -f "$whitelist_file" ] && touch "$whitelist_file"
    grep -q "com.fhrz.axeron" "$whitelist_file" || echo "$package_name" >> "$whitelist_file"
    grep -q "moe.shizuku.privileged.api" "$whitelist_file" || echo "$package_name" >> "$whitelist_file"
    ashcore "$pkg" "$path"
  fi
}
