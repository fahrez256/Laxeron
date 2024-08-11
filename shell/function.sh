export AXERON=true
export EXPIRED=true
export CORE="d8a97692ad1e71b1"
export EXECPATH=$(dirname $0)
export APROPS=${EXECPATH}/axeron.prop
local THISPATH="/sdcard/Android/data/com.fhrz.axeron/files"
export PACKAGES=$(echo -e $(cat ${THISPATH}/packages.list))
export TMPFUNC="${THISPATH}/axeron.function"
export FUNCTION="/data/local/tmp/axeron.function"
export AXFUN=". $FUNCTION"
whitelist_file="/sdcard/AxeronModules/.config/whitelist.list"

import() {
	file=$(find "$(dirname $0)" -type f -name "$1")
 	if [ -z "$file" ]; then
  		dir="$(dirname $0)"
		while [ "$(dirname "$dir")" != "/data/local/tmp/axeron_cash" ]; do
	        	file=$(find "$dir" -maxdepth 1 -name "$filename" -print -quit)
	        	[ -n "$file" ] && break
	  		dir="$dir/.."
     			echo $dir
		done
	fi
	dos2unix $file
	source $file
 	eval path_$(echo "$1" | tr -cd '[:alnum:]_-')="$file"
}

toast() {
	case $# in
		1)
			title=""
			msg="$1"
			duration=3000
			;;
		2)
			case $2 in
				''|*[!0-9]*)
					title="$1"
					msg="$2"
					duration=0
					;;
				*)
					title=""
					msg="$1"
					duration="$2"
					;;
			esac
			;;
		3)
			title="$1"
			msg="$2"
			duration="$3"
			;;
		*)
			echo "Usage: toast <msg> | toast <title> <msg> | toast <msg> <duration> | toast <title> <msg> <duration>"
			return 1
			;;
	esac

	am broadcast -a axeron.show.TOAST --es title "$title" --es msg "$msg" --ei duration "$duration" > /dev/null 2>&1
}

openlink() {
	am broadcast -a axeron.show.ADS --es url "$1" > /dev/null 2>&1
}

buyvip() {
	openlink "https://sociabuzz.com/fahrezone/p/donatur-laxeron-vip-telegram-gc"
}

pkglist() {
	case $1 in
		-F|--full)
			pkgfile="packages_full.list"
			shift
			;;
		*)
			pkgfile="packages.list"
			;;
	esac
	case $1 in
		-L|--getLabel)
			if [ -z "$2" ]; then
				echo "Usage: pkglist $1 <package>"
				exit 0
			fi
			cat ${THISPATH}/${pkgfile} | grep "$2" | cut -d '|' -f 1
			;;
		-P|--getPackage)
			if [ -z "$2" ]; then
				echo "Usage: pkglist $1 <appname>"
				exit 0
			fi
			cat ${THISPATH}/${pkgfile} | grep -i "$2" | cut -d '|' -f 2
			;;
		*)
			cat ${THISPATH}/${pkgfile} | cut -d '|' -f 2
			;;
	esac
}

rozaq() {
	if [ -z "$1" ]; then
		echo "Error: No text provided."
		return 1
	fi
	
	echo "r17$(echo -n "$1" | base64 | tr A-Za-z R-ZA-Qr-za-q)"
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
	
	am start --activity-no-animation -n $(cmd package dump "$1" | awk '/MAIN/{getline; print $2}' | head -n 1) > /dev/null 2>&1
	 # am startservice -n com.fhrz.axeron/.Services.FastLaunch --es pkg "$1" > /dev/null
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

stream() {
    exec=false
    file_name="response"

    # Validate input
    if [ $# -eq 0 ]; then
        echo "Usage: storm <URL> [options]"
        return 0
    fi

    # Parse command-line arguments
    while [ $# -gt 0 ]; do
        case $1 in
            --exec|-x) exec=true; api=$2; shift 2 ;;
            --fname|-fn) file_name=$2; shift 2 ;;
            *) if [ -z "$api" ]; then api=$1; fi; shift ;;
        esac
    done

    if [ -z "$api" ]; then
        echo "Error: No API URL provided."
        return 1
    fi

    local runPath="$(dirname $0)"
    local responsePath="${THISPATH}/response"
    local errorPath="${THISPATH}/error"

    # Remove old files
    rm -f "$responsePath" "$errorPath"

    # Start request and handle response
    curl -s "$api" -o "$responsePath" || echo "Error fetching API" > "$errorPath"

    while [ ! -e "$responsePath" ] && [ ! -e "$errorPath" ]; do
        sleep 0.25
    done

    if [ -e "$responsePath" ]; then
        if [ "$exec" = true ]; then
            cp "$responsePath" "$runPath/$file_name"
            chmod +x "$runPath/$file_name"
            "$runPath/$file_name" "$@"
        else
            cat "$responsePath"
        fi
    elif [ -e "$errorPath" ]; then
        cat "$errorPath"
    fi
}

storm() {
	exec=false
	file_name="response"
	if [ $# -eq 0 ]; then
		echo "Usage: storm <URL>"
		return 0
	fi

	case $1 in
		--exec|-x)
			exec=true
			api=$2
			shift 2
			;;
		* )
			api=$1
			shift
			;;
	esac

	case $1 in
		--fname|-fn)
			file_name="$2"
			shift 2
			;;
		* )
			;;
	esac
	
	local runPath="$(dirname $0)"
	rm -f ${THISPATH}/response
	rm -f ${THISPATH}/error
	
	if am startservice -n com.fhrz.axeron/.Storm --es api "$api" --es path "$THISPATH" > /dev/null; then
		while true; do
			if [ -e ${THISPATH}/response ]; then
				if [ $exec = true ]; then
					cp "${THISPATH}/response" "${runPath}/${file_name}"
					mv "${runPath}/${file_name}" "${runPath}/${file_name}"
					chmod +x "$runPath/${file_name}"
					${runPath}/${file_name} $@
				else
					cat ${THISPATH}/response
				fi
				am stopservice -n com.fhrz.axeron/.Storm > /dev/null 2>&1
				break
			elif [ -e ${THISPATH}/error ]; then
				cat ${THISPATH}/error
				am stopservice -n com.fhrz.axeron/.Storm > /dev/null 2>&1
				break
			else 
				sleep 0.25
			fi
		done
	else
		echo "Error: Storm not supported"
	fi
}

xtorm() {
	storm -x $([[ "${1:0:3}" = "r17" ]] && echo "${1:3}" | tr R-ZA-Qr-za-q A-Za-z | base64 -d || echo "$1")
}

xperm() {
	#RiProG
	option=$(echo "$1" | tr '[:upper:]' '[:lower:]')
	case $option in
		--help|-h)
			echo "Usage: xperm [OPTIONS]"
			echo "OPTIONS:"
			echo "	--help, -h									 Display this help message"
			echo "	--recursive, -r <DIRECTORY>	Set permissions recursively for a directory"
			echo "															 <DIRECTORY>: Path to the directory"
			echo "	<FILE> <OWNER> <GROUP> <PERMISSION> <CONTEXT>"
			echo "	Example usage:"
			echo "		xperm /path/to/file.txt user1 group1 644"
			echo "		xperm -r /path/to/directory user1 group1 755 644"
			return 0
			;;
		--recursive|-r)
			directory="$2"
			if [ ! -d "$directory" ]; then
				echo "Directory not found"
				exit 1
			fi
			owner="$3"
			group="$4"
			dir_permission="$5"
			file_permission="$6"
			find "$directory" -type d -exec chown "$owner":"$group" {} +
			find "$directory" -type d -exec chmod "$dir_permission" {} +
			find "$directory" -type f -exec chown "$owner":"$group" {} +
			find "$directory" -type f -exec chmod "$file_permission" {} +
			;;
		*)
			file="$1"
			if [ ! -f "$file" ]; then
				echo "File not found"
				exit 1
			fi
			owner="$2"
			group="$3"
			permission="$4"
			context="$5"
			if ! chown "$owner":"$group" "$file"; then
				return 1
			fi
			if ! chmod "$permission" "$file"; then
				return 1
			fi
			if [ -z "$context" ]; then
				context=u:object_r:system_file:s0
			fi
			if ! chcon "$context" "$file"; then
				return 1
			fi
			;;
	esac
}

whitelist() {
	[ ! -d "$(dirname "$whitelist_file")" ] && mkdir -p "$(dirname "$whitelist_file")"
	[ ! -f "$whitelist_file" ] && touch "$whitelist_file" && echo "[Created] whitelist.list"
	
	local operation="${1:0:1}"
	local packages="${1:1}"
	
	case $operation in
		+)
			echo "$packages" | tr ',' '\n' | while IFS= read -r package_name; do
				grep -q "$package_name" "$whitelist_file" && echo "[Duplicate] $package_name" || { echo "$package_name" >> "$whitelist_file"; echo "[Added] $package_name"; }
			done
			;;
		-)
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
		--check|-c)
			if [ $2 == "--sdex" ]; then
				cmd package dump "$3" | grep -B 1 status= | grep -A 1 "split_" | grep status= | sed 's/.*status=\([^]]*\).*/\1/' | head -n 1
			else
				cmd package dump "$2" | grep -B 1 status= | grep -A 1 "base.apk" | grep status= | sed 's/.*status=\([^]]*\).*/\1/'
			fi
			;;
		--reset|-r)
			if [ $2 == "--sdex" ]; then
				pm compile --reset --secondary-dex "$3"
			else
				pm compile --reset "$2"
			fi
			;;
		--help|-h)
			echo "Usage: jit <mode> <package_name>"
			echo "Option:"
			echo "	--check, -c <package_name>: Check if the package is JIT compiled."
			echo "	--reset, -r <package_name>: Reset JIT compilation for the package."
			echo "Mode:"
			echo "	[verify/speed/etc] <package_name>: Compile package using JIT mode."
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

axprop() {
	if [ "$#" -lt 2 ]; then
		echo "Usage: axprop <filename> <key> [-s|--String] <value> | axprop <filename> -d <key> | axprop <filename> -g <key>"
		return 1
	fi

	local filename=$1 key=$2 value
	local sanitized_key=$(echo "$key" | tr -cd '[:alnum:]_-')

	[ ! -f "$filename" ] && echo "File $filename not found!" && return 1

	case $key in
		-d|--delete)
			key=$3
			sanitized_key=$(echo "$key" | tr -cd '[:alnum:]_-')
			if grep -q "^$sanitized_key=" "$filename"; then
				sed -i "/^$sanitized_key=/d" "$filename"
				echo "Deleted key $key"
			else
				echo "Key $key not found"
			fi
			;;
		-g|--get)
			key=$3
			sanitized_key=$(echo "$key" | tr -cd '[:alnum:]_-')
			if grep -q "^$sanitized_key=" "$filename"; then
				grep "^$sanitized_key=" "$filename" | cut -d '=' -f2-
			else
				echo "Key $key not found"
			fi
			;;
		*)
			if [ "$3" = "-s" ] || [ "$3" = "--String" ]; then
				value="\"$4\""
			else
				value=$3
			fi
			if grep -q "^$sanitized_key=" "$filename"; then
				sed -i "s/^$sanitized_key=.*/$sanitized_key=$value/" "$filename"
			else
				echo "$sanitized_key=$value" >> "$filename"
			fi
			echo "Updated $(basename $filename) with $sanitized_key=$value"
			;;
	esac
}

cashclear() {
	if rm -rf "/data/local/tmp/axeron_cash"; then
 		echo "CASH: Success to clear"
   	else
    		echo "CASH: Failed to clear"
    	fi
}

ax() {
    if [ $# -eq 0 ]; then
        echo "Usage: ax <id_module> [options] [arguments]"
        exit 1
    fi

    local ORANGE='\033[38;2;255;85;3m'
    local GREY='\033[38;2;105;105;105m' # Kode warna ANSI untuk oranye
    local NC='\033[0m'         # Kode untuk mengatur ulang warna (no color)
    local showLog=true

    log() { 
        [ "$showLog" = true ] && echo -e "${ORANGE}[$1]${NC} ${GREY}$2${NC}"; 
    }

    if [ "$1" = "--log" ]; then
        showLog=true
        shift
    fi

    local nameDir="$1"
    local cachePath="/sdcard/AxeronModules/.cache"
    local cash="/data/local/tmp/axeron_cash"
    mkdir -p "$cachePath" "$cash"

    case $1 in
        --help|-h)
            echo "Usage: ax <id_module> [options] [arguments]"
            echo "Options:"
            echo "  --remove, -r <module>: Remove a module from path"
            echo "  --list, -l: List installed modules"
            echo "  --help, -h: Show this help message"
            return 0
            ;;
        --list|-l)
            echo "Installed Modules:"
            find "$cash" -type f -name "axeron.prop" -exec dirname {} \; | xargs -n1 basename
            return 0
            ;;
    esac

    log "Starting AX" "$nameDir"

    rm -rf "$cachePath"
    mkdir -p "$cachePath"

    pathCash=$(find "$cash" -type d -iname "$nameDir")
    log "Cache dir" "$pathCash"

    if [ -n "$pathCash" ]; then
        pathCashProp=$(find "$pathCash" -type f -iname "axeron.prop")
        if [ -f "$pathCashProp" ]; then
            log "Loading prop from" "$pathCashProp"
            dos2unix "$pathCashProp"
            . "$pathCashProp"
        else
            log "No axeron.prop found in cache directory."
        fi
    else
        pathCash="${cash}/${nameDir}"
        log "No cached dir found. Using new path" "$pathCash"
    fi

    tmpVCode=${versionCode:-0}
    tmpTStamp=${timeStamp:-0}
    log "Init Version Code" "$tmpVCode"
    log "Init Timestamp" "$tmpTStamp"

    counter=0
    idFound=false

    IFS=$'\n'
    for file in $(find "/sdcard/AxeronModules" -type f -iname "*.zip*"); do
        counter=$((counter + 1))
        log "Processing file (${counter})" "$file"

        pathProp=$(unzip -l "$file" | awk '/axeron.prop/ {print $4; exit}')
        timeStamp=$(stat -c %Y "$file")
        log "File Timestamp" "$timeStamp"
        log "Path to axeron.prop" "$pathProp"

        if [ -z "$pathProp" ]; then
            log "axeron.prop not found in $file"
            continue
        fi

        cachePathProc="$cachePath/proc${counter}"
        mkdir -p "$cachePathProc"
        unzip -o "$file" "$pathProp" -d "$cachePathProc" > /dev/null 2>&1
        cachePathProp="${cachePathProc}/${pathProp}"
        log "Extracted axeron.prop to" "$cachePathProp"

        if [ ! -f "$cachePathProp" ]; then
            log "Failed to extract axeron.prop from" "$file"
            continue
        fi

        dos2unix "$cachePathProp"
        . "$cachePathProp"
        log "Loaded prop from" "$cachePathProp"

        if [ -n "$id" ] && echo "$id" | grep -iq "$nameDir"; then
            idFound=true
            log "ID $id matches $nameDir. Checking version and timestamp."

            if [ "$versionCode" -ge "$tmpVCode" ] && [ "$timeStamp" -gt "$tmpTStamp" ]; then
                tmpVCode=$versionCode
                tmpTStamp=$timeStamp

                pathParent=$(dirname $(unzip -l "$file" | awk '{print $4}' | grep 'axeron.prop' | head -n 1))
                if [ -n "$pathParent" ]; then
                    log "Found parent folder" "$pathParent"
                    mkdir -p "${cash}/${id}/tmp"
                    unzip -o "$file" -d "${cash}/${id}/tmp" > /dev/null 2>&1
                    for item in "${cash}/${id}/tmp/${pathParent%/}/"*; do
                        if [ -e "$item" ]; then
                            mv "$item" "${cash}/${id}/"
                        fi
                    done
                    rm -rf "${cash}/${id}/tmp"
                    log "Moved files from parent folder to" "${cash}/${id}/"
                else
                    unzip -o "$file" -d "${cash}/${id}" > /dev/null 2>&1
                    log "No parent folder. Extracted files directly to" "${cash}/${id}/"
                fi

                pathCash=$(find "$cash" -type d -iname "$nameDir")
                pathCashProp=$(find "$pathCash" -type f -iname "axeron.prop")
                axprop "$pathCashProp" timeStamp "$tmpTStamp"
                log "Updated prop with timestamp" "$tmpTStamp"
            else
                log "Version code or timestamp not updated."
            fi
        else
            log "ID $id does not match $nameDir."
        fi
    done

    log "ID found" "$idFound"

    if [ "$idFound" = false ]; then
        log "AX processing complete. No matching ID found."
        echo "ID not Found"
        exit 404
    fi

    dos2unix "$pathCashProp"
    . "$pathCashProp"
    log "Final prop from" "$pathCashProp"
    find "$pathCash" -type f -exec chmod +x {} \;
    log "Set executable permissions on files."

    install=$(find "$pathCash" -type f -iname "${install:-"install"}*")
    remove=$(find "$pathCash" -type f -iname "${remove:-"remove"}*")
    log "Install script" "$install"
    log "Remove script" "$remove"
    log "AX processing complete."
    echo
    
    case $2 in
        -r|--remove)
            if [ -n "$remove" ]; then
                shift 2
                "${remove}" $@
                rm -rf "$pathCash"
            else
                echo "[ ! ] Cannot remove this module: Remove script not found."
            fi
            ;;
        *)
            if [ -n "$install" ]; then
                shift
                "${install}" $@
            else
                echo "[ ! ] Cannot install this module: Install script not found."
            fi
            ;;
    esac
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
		unzip -o "/sdcard/${1}" -d "/sdcard/AxeronModules/" > /dev/null 2>&1
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
