export AXERON=true
export EXPIRED=true
export CORE="d8a97692ad1e71b1"
local THISPATH="/sdcard/Android/data/com.fhrz.axeron/files"
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
local urlBin="https://raw.githubusercontent.com/fahrez256/Laxeron/main/shell/bin"
timeformat() { echo "$(date -d "@$1" +"%Y-%m-%d %H.%M.%S")"; }

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

	#testRealtimeExec

    	while [ ! -e "$responsePath" ] && [ ! -e "$errorPath" ]; do
        	sleep 0.1
    	done

    	if [ -e "$responsePath" ]; then
        	if [ "$exec" = true ]; then
	 		#echo "storm -x $@"
            		cp "$responsePath" "$runPath/$file_name"
            		chmod +x "$runPath/$file_name"
            		"${runPath}/$file_name" "$@"
        	else
            		cat "$responsePath"
        	fi
    	elif [ -e "$errorPath" ]; then
        	cat "$errorPath"
    	fi
}

toast() {
	storm -rP "$AXBIN" -x "${urlBin}/toast.sh" -fn "toast" "$@"
}

openlink() {
	am broadcast -a axeron.show.ADS --es url "$1" > /dev/null 2>&1
}

buyvip() {
	openlink "https://sociabuzz.com/fahrezone/p/donatur-laxeron-vip-telegram-gc"
}

pkglist() {
	storm -rP "$AXBIN" -x "${urlBin}/pkglist.sh" -fn "pkglist" "$@"
}

flaunch() {
	if [ $# -eq 0 ]; then
		echo "Usage: flaunch <package_name>"
		return 0
	fi
	
	am start --activity-no-animation -n $(cmd package dump "$1" | awk '/MAIN/{getline; print $2}' | head -n 1) > /dev/null 2>&1
}

deviceinfo() {
device_info="
Optione {
	key:checkJit=\"$(getprop dalvik.vm.usejit)\";
	key:checkVulkan=\"$(ls /system/lib/libvulkan.so > /dev/null 2>&1 && echo true || echo false)\";
	key:infoRender=\"$(getprop debug.hwui.renderer)\";
}
"
echo -e "$device_info"
}

xtorm() {
	storm -x $@
}

whitelist() {
	storm -rP "$AXBIN" -x "${urlBin}/whitelist.sh" -fn "whitelist" "$@"
}

jit() {
	storm -rP "$AXBIN" -x "${urlBin}/jit.sh" -fn "jit" "$@"
}

axprop() {
	storm -rP "$AXBIN" -x "${urlBin}/axprop.sh" -fn "axprop" "$@"
}

shx() {
	storm -rP "$AXBIN" -x "${urlBin}/shx.sh" -fn "shx" "$@"
}

ax() {
	storm -rP "$AXBIN" -x "${urlBin}/ax.sh" -fn "ax" "$@"
}

ax2() {
	storm -rP "$AXBIN" -x "${urlBin}/ax2.sh" -fn "ax2" "$@"
}

axfun_construct $@
