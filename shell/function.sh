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
export AXBIN="/data/local/tmp/axeron_bin"
local whitelist_file="/sdcard/AxeronModules/.config/whitelist.list"
#color
local ORANGE='\033[38;2;255;85;3m'
local GREY='\033[38;2;105;105;105m'
local NC='\033[0m'
#local
local modulePath="/sdcard/AxeronModules"
local cachePath="/sdcard/AxeronModules/.cache"
local cash="/data/local/tmp/axeron_cash"
timeformat() { echo "$(date -d "@$1" +"%Y-%m-%d %H.%M.%S")"; }

#constructor
axfun_construct() {
	mkdir -p "$AXBIN"
}

rozaq() {
	if [ -z "$1" ]; then
		echo "Error: No text provided."
		return 1
	fi
	
	echo "r17$(echo -n "$1" | base64 | tr A-Za-z R-ZA-Qr-za-q)"
}

storm() {
    	exec=false
    	file_name="response"
     	runPath="$(dirname $0)"
     	#echo "start $@"

    	if [ $# -eq 0 ]; then
        	echo "Usage: storm <URL> [options]"
        	return 0
    	fi

	case $1 in
	    --runPath|-rP) 
	        if [ -d "$2" ]; then
	        	runPath="$2"
	        	shift 2
	  	else
    			shift 1
       		fi
	        ;;
	esac
 	#echo "runPath $runPath"
 
     	#local runPath="$(dirname $0)"
    	local responsePath="${THISPATH}/response"
    	local errorPath="${THISPATH}/error"

    	case $1 in
		--exec|-x) exec=true; api=$([[ "${2:0:3}" = "r17" ]] && echo "${2:3}" | tr R-ZA-Qr-za-q A-Za-z | base64 -d || echo "$2"); shift 2 ;;
		* ) api=$1; shift ;;
	esac

	case $1 in
		--fname|-fn) file_name="$2"; rm -f "{$runPath}/$file_name"; shift 2 ;;
	esac
 	#echo "after case $@"

    	if [ -z "$api" ]; then
        	echo "Error: No API URL provided."
        	return 1
    	fi

    	rm -f "$responsePath" "$errorPath"

    	am startservice -n com.fhrz.axeron/.Storm --es api "$api" --es path "$responsePath" > /dev/null 2>&1

    	while [ ! -e "$responsePath" ] && [ ! -e "$errorPath" ]; do
        	sleep 0.25
    	done

    	if [ -e "$responsePath" ]; then
        	if [ "$exec" = true ]; then
	 		#echo "storm -x $@"
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

import() {
	filename="$1"
	file=$(find "$(dirname "$0")" -type f -name "$filename")
	
	if [ -z "$file" ]; then
		    dir="$(dirname "$0")"
		    while [ "$dir" != "/data/local/tmp/axeron_cash" ]; do
			        # Cari file di direktori saat ini
			        file=$(find "$dir" -maxdepth 1 -name "$filename")
			        if [ -n "$file" ]; then
			            file="$file"
			            break
			        fi
			        dir="$(dirname "$dir")"
		    done
	fi
	dos2unix $file
	source $file
 	eval path_$(echo "$filename" | tr -cd '[:alnum:]_-')="$file"
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

xtorm() {
	storm -x $@
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

	local ORANGE='\033[38;2;255;85;3m'
    	local GREY='\033[38;2;105;105;105m' # Kode warna ANSI untuk oranye
    	local NC='\033[0m'
 	local showLog=false

    	log() { 
        	[ "$showLog" = true ] && echo -e "${ORANGE}${1}${NC} ${GREY}${2}${NC}"; 
    	}

    	if [ "$1" == "--log" ]; then
     		case $2 in
        		"true"|"false") showLog=$2; shift 2 ;;
	  		*) shift ;;
	 	esac
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
				log "[Deleted key]" "$key"
			else
				log "[Key $key not found]"
			fi
			;;
		-g|--get)
			key=$3
			sanitized_key=$(echo "$key" | tr -cd '[:alnum:]_-')
			if grep -q "^$sanitized_key=" "$filename"; then
				grep "^$sanitized_key=" "$filename" | cut -d '=' -f2-
			else
				log "[Key $key not found]"
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
			log "[\$] [Updated $(basename $filename) with $sanitized_key]" "$value"
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

shx() {
	storm -rP "$AXBIN" -x "https://raw.githubusercontent.com/fahrez256/Laxeron/main/shell/bin/shx.sh" -fn "shx" "$@"
}

ax() {
	storm -rP "$AXBIN" -x "https://raw.githubusercontent.com/fahrez256/Laxeron/main/shell/bin/ax.sh" -fn "ax" "$@"
}

ax2() {
	storm -rP "$AXBIN" -x "https://raw.githubusercontent.com/fahrez256/Laxeron/main/shell/bin/ax2.sh" -fn "ax2" "$@"
}

axfun_construct $@
