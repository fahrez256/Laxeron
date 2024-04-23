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
      chmod 777 "$target_busybox"
  fi
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
    # Path ke file whitelist
    local whitelist_dir="/sdcard/AxeronModules/.config"
    local whitelist_file="${whitelist_dir}/whitelist.list"

    if [ ! -d "$whitelist_dir" ]; then
        mkdir "$whitelist_dir"
    fi
    
    if [ ! -f "$whitelist_file" ]; then
        # Jika file tidak ada, maka buat file tersebut
        touch "$whitelist_file"
        echo "[Created] whitelist.list"
    fi

    # Mengekstrak operasi dan nama paket dari parameter
    local operation="${1:0:1}"
    local packages="${1:1}"
    
    # Menambahkan atau menghapus paket dari daftar whitelist
    if [ "$operation" = "+" ]; then
      for package_name in $(echo $packages | tr ',' '\n'); do
          if grep -q "$package_name" "$whitelist_file" >/dev/null 2>&1; then
              echo "[Duplicate] $package_name"
          else
              echo "$package_name" >> "$whitelist_file"
              echo "[Added] $package_name"
          fi
        done
    elif [ "$operation" = "-" ]; then
      for package_name in $(echo $packages | tr ',' '\n'); do
          if grep -q "$package_name" "$whitelist_file" >/dev/null 2>&1; then
              sed -i "/$package_name/d" "$whitelist_file"
              echo "[Removed] $package_name"
          else
              echo "[Failed] $package_name"
          fi
        done
    else
        # Menampilkan seluruh daftar whitelist
        echo "$(cat "$whitelist_file")"
    fi
}

ash() {
    # Function to install or remove modules from a specified path

    # Usage: ash <path> [options] [arguments]
    # Options:
    #   --install, -i <module>: Install a module from the specified path
    #   --remove, -r <module>: Remove a module from the specified path
    #   --help, -h: Show this help message

    # Check if no arguments are provided
    if [ $# -eq 0 ]; then
        echo -e "Usage: ash <path> [options] [arguments]"
        return 1
    fi

    local path="/sdcard/AxeronModules/${1}"

    case $1 in
        "--help" | "-h")
            # Show usage information
            echo -e "Save the Module in AxeronModules folder!"
            echo ""
            echo -e "Usage: ash <path> [options] [arguments]"
            echo "Options:"
            echo "  --install, -i <module>: Install a module from path"
            echo "  --remove, -r <module>: Remove a module from path"
            echo "  --help, -h: Show this help message"
            return 0
            ;;
        "--list" | "-l")
            # Show usage information
            echo "List of Modules"
            echo ""
            ls /sdcard/AxeronModules
            return 0
            ;;
        *)
            # Check if the specified path exists
            if [ ! -d "$path" ]; then
                echo "[ ? ] Path not found: $path"
                return 1
            fi
            ;;
    esac

    # Check if axeron.prop exists in the specified path
    if ls "${path}/axeron.prop" >/dev/null 2>&1; then
        source "${path}/axeron.prop"
    else
        echo "[ ? ] axeron.prop not found in $path."
    fi

    case $2 in
        "--install" | "-i")
            if [ -z "$install" ]; then
                local pathInstall="${path}/${3}"
                if ls "${pathInstall}" >/dev/null 2>&1; then
                    shift 3
                    sh "${pathInstall}" "$@"
                else
                    echo "[ ! ] Cant install this module"
                fi
            else
                shift 2
                sh "${path}/${install}" "$@"
            fi
            ;;
        "--remove" | "-r")
            if [ -z "$remove" ]; then
                local pathRemove="${path}/${3}"
                if ls "${pathRemove}" >/dev/null 2>&1; then
                    shift 3
                    sh "${pathRemove}" "$@"
                else
                    echo "[ ! ] Cant remove this module"
                fi
            else
                shift 2
                sh "${path}/${remove}" "$@"
            fi
            ;;
        *)
            if [ -z "${3}" ]; then
                shift
                sh "${path}/${install}" "$@"
            else
                if [ -z "${install}" ]; then
                    local pathInstall="${path}/${2}"
                    if ls "${pathInstall}" >/dev/null 2>&1; then
                        shift 2
                        sh "${pathInstall}" "$@"
                    else
                        echo "[ ! ] Cant install this module"
                    fi
                else
                    shift
                    sh "${path}/${install}" "$@"
                fi
            fi
            ;;
    esac
}
