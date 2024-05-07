export AXERON=true
export EXPIRED=true
export CORE="d8a97692ad1e71b1"
export EXECPATH=$(dirname $0)
local THISPATH="/sdcard/Android/data/com.fhrz.axeron/files"
export PACKAGES=$(cat ${THISPATH}/packages.list)
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

flaunch() {
  if [ $# -eq 0 ]; then
    echo "Usage: flaunch <package_name>"
    return 0
  fi
  
  am start --activity-no-animation -n $(cmd package dump "$1" | awk '/MAIN/{getline; print $2}' | head -n 1)
   # am startservice -n com.fhrz.axeron/.Services.FastLaunch --es pkg "$1" > /dev/null
}

axeroncore() {
  echo "axeroncore not supported :("
  sleep 1
  link="https://t.me/fahrezone_gc"
  am start -a android.intent.action.VIEW -d "$link" > /dev/null 2>&1
}

autocfg() {
    # Move folders containing axeron.prop to AxeronModules
    search=$(find /sdcard/*/axeron.prop) >/dev/null 2>&1
    if [ -n "$search" ]; then
        echo "$search" | xargs -n 1 dirname | xargs -n 1 basename | while IFS= read -r folder; do
            if [ -d "/sdcard/AxeronModules/$folder" ]; then
                echo "Duplicate - $folder"
            else
                mv "/sdcard/$folder" /sdcard/AxeronModules
                echo "Successfully installed - $folder"
            fi
        done
    fi

    # Extract folders with axeron.prop from zip files to AxeronModules
    search=$(find /sdcard/*.zip) >/dev/null 2>&1
    if [ -n "$search" ]; then
        echo "$search" | while IFS= read -r file; do
            axeron=$(unzip -l "$file" | awk '{print $4}' | grep -m 1 'axeron.prop')
            if [ -n "$axeron" ]; then
            folder=$(dirname "$axeron")
                if [ -d "/sdcard/AxeronModules/$folder" ]; then
                    echo "Duplicate - $folder"
                else
                    unzip "$file" "$folder/*" -d "/sdcard/AxeronModules/" >/dev/null 2>&1
                    echo "Successfully installed - $folder"
                fi
            fi
        done
    fi
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
  echo "[Cleaning] Optimizing cache: "
  available_before=$(df /data | awk 'NR==2{print $4}')
  pm trim-caches 999G
  available_after=$(df /data | awk 'NR==2{print $4}')
  cleared_cache=$((available_after - available_before))
  if [ "$cleared_cache" -ge 0 ]; then
    if [ "$cleared_cache" -lt 1024 ]; then
      echo "$((cleared_cache / 1)) KB"
    elif [ "$cleared_cache" -lt 1048576 ]; then
      echo "$((cleared_cache / 1024)) MB"
    elif [ "$cleared_cache" -lt 1073741824 ]; then
      echo "$((cleared_cache / 1048576)) GB"
    fi
  else
    echo "No cache found or cleaned."
  fi
}

dapp() {
  #RiProG
  package=$2
  package_list=$(pm list package | cut -f 2 -d : | grep "$package") > /dev/null 2>&1
  if [ "$package_list" ]; then
    option=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    case $option in
      -d|--debloat)
        echo "Debloating system app with package name $package..."
        pm uninstall "$package" > /dev/null 2>&1
        pm disable-user "$package" > /dev/null 2>&1
        pm clear "$package" > /dev/null 2>&1
        package_list=$(pm list packages -d | cut -f 2 -d : | grep "$package") > /dev/null 2>&1
        if [ "$package_list" ]; then
          echo "System app with package name $package has been successfully debloated."
        else
          echo "Failed to debloat system app with package name $package ."
        fi
        ;;
     -r|--restore)
        echo "Restoring system app with package name $package..."
        pm enable "$package" > /dev/null 2>&1
        package_list=$(pm list packages -d | cut -f 2 -d : | grep "$package") > /dev/null 2>&1
        if [ "$package_list" ]; then
          echo "Failed to restore system app with package name $package ."
        else
          echo "System app with package name $package has been successfully restored."
        fi
        ;;
      -l|--list)
        echo "List of disabled packages:"
        package_list=$(pm list packages -d | cut -f 2 -d :) > /dev/null 2>&1
        if [ "$package_list" ]; then
          echo "$package_list"
        else
          echo "No apps have been debloated yet."
        fi
        ;;
      *)
       echo "Invalid option."
        ;;
      esac
  else
      echo "Invalid package name."
  fi
}

aperm() {
  #RiProG
  package=$2
  package_list=$(pm list package | cut -f 2 -d : | grep "$package") > /dev/null 2>&1
  if [ "$package_list" ]; then
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
                  appops set "$package" "$permission" deny
                  echo "- $permission"
              done
              appops reset "$package"
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
  esac

  local pathCash="/data/local/tmp/axeron_cash"
  
  [ ! -d "$pathCash" ] && mkdir -p $pathCash
  [ -n "$(ls -A $pathCash)" ] && rm -r ${pathCash}/*

  path="/sdcard/AxeronModules/${1}"
  oriPath="$path"     
  
  if [ ! -d "$path" ]; then
    local sdpath=$(find /sdcard/ -type d -iname "${1}")
    if [ -n "$sdpath" ]; then
      mv "$sdpath" "/sdcard/AxeronModules/"
      echo "[${1}] Moved to AxeronModules folder"
    else
      echo "[ ? ] Path not found: $path"
      return 1
    fi
  fi
  
  cp -r $path $pathCash
  path="${pathCash}/${1}"
  
  find $path -type f -exec chmod +x {} \;

  [ -f "${oriPath}/axeron.prop" ] && source "${oriPath}/axeron.prop" || echo "[ ? ] axeron.prop not found in $oriPath."

  local install=${install:-"install.sh"}
  local remove=${remove:-"remove.sh"}

  case $2 in
    "--package" | "-p")
      pkg=${3:-runPackage}
      sed -i "s/runPackage=\"[^\"]*\"/runPackage=\"${pkg}\"/g" ${oriPath}/axeron.prop
      shift 2
      ;;
  esac
  
  case $2 in
    "--remove" | "-r")
      if [ -z "$remove" ]; then
        echo "[ ! ] Cant remove this module"
      else
        shift 2
        ${path}/${remove} $@
      fi
      ;;
    *)
      if [ -z "$install" ]; then
        echo "[ ! ] Cant install this module"
      else
        shift 
        ${path}/${install} $@
      fi
    ;;
  esac

  [ -f "${path}/axeron.prop" ] && source "${path}/axeron.prop" || ( echo "[ ? ] axeron.prop not found in $path."; return 0 )

  if [ $useAxeron ] && [ $useAxeron = true ]; then
    pm grant com.fhrz.axeron android.permission.SYSTEM_ALERT_WINDOW
    [ ! -d "$(dirname "$whitelist_file")" ] && mkdir -p "$(dirname "$whitelist_file")"
    [ ! -f "$whitelist_file" ] && touch "$whitelist_file"
    grep -q "com.fhrz.axeron" "$whitelist_file" || echo "com.fhrz.axeron" >> "$whitelist_file"
    grep -q "moe.shizuku.privileged.api" "$whitelist_file" || echo "moe.shizuku.privileged.api" >> "$whitelist_file"
    ashcore "$pkg" "$path"
  fi
}

zash() {
  axeron=$(unzip -l "/sdcard/${1}" | awk '{print $4}' | grep -m 1 'axeron.prop')
  if [ "${axeron}" ]; then
    folder=$(dirname "${axeron}")
    modpath="/sdcard/AxeronModules/${folder}"
    if [ ! -d "${modpath}" ]; then
      echo "Adding Axeron Modules"
    else
      echo "Updating Axeron Modules"
    fi
    unzip -o "/sdcard/${1}" -d "/sdcard/AxeronModules/" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      source "/sdcard/AxeronModules/${folder}/axeron.prop"
      echo "name: ${name}"
      echo "version: ${version}"
      echo "author: ${author}"
      echo "description: ${description}"
      echo "useAxeron; ${useAxeron}"
      echo "Axeron Modules Extracted"
    else
      echo "Axeron Modules failed to Extract"
    fi
  else
    echo "Zip file is not Axeron modules"
  fi
}
