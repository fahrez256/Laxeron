$AXFUN

logview() { 
	local ORANGE='\033[38;2;255;85;3m'
	local GREY='\033[38;2;105;105;105m'
	local NC='\033[0m'
	echo -e "${ORANGE}${1}${NC} ${GREY}${2}${NC}"; 
}

logview "[Parameter #$#]:" "$@"

fax() {
	local ORANGE='\033[38;2;255;85;3m'
	local GREY='\033[38;2;105;105;105m'
	local NC='\033[0m'
	local showLog=true

	log() { 
		[ "$showLog" = true ] && echo -e "${ORANGE}${1}${NC} ${GREY}${2}${NC}"; 
	}
	
	timeformat() { echo "$(date -d "@$1" +"%Y-%m-%d %H.%M.%S")"; }

	if [ "$1" = "--log" ]; then
		showLog=true
		shift
	fi
	
	local nameDir="$1"
	local modulePath="/sdcard/AxeronModules"
	local cachePath="/sdcard/AxeronModules/.cache"
	local cash="/data/local/tmp/axeron_cash"
	
	start_time=$(date +%s%3N)
	log "[Starting FAX]" "$nameDir"
	
	pathCash=$(find "$cash" -type d -iname "$nameDir")
	
	[ -n "$pathCash" ] && pathCashProp=$(find "$pathCash" -type f -iname "axeron.prop") && log "[Path Cash]" "$pathCash"
	[ -n "$pathCashProp" ] && dos2unix "$pathCashProp" && source "$pathCashProp" && log "[Loading prop from]" "$pathCashProp"

	tmpVCode=${versionCode:-0}
	tmpTStamp=${timeStamp:-0}
	log "[Init Version Code]" "$tmpVCode"
	log "[Init Last Update]" "$(timeformat $tmpTStamp)"

	ctr=0
	idFound=false

	IFS=$'\n'
	for file in $(find "$modulePath" -type f -iname "*.zip*"); do
		ctr=$((ctr + 1))
		
		pathProp=$(unzip -l "$file" | awk '/axeron.prop/ {print $4; exit}')
		timeStamp=$(stat -c %Y "$file")
		cachePathProc="${cachePath}/proc${ctr}"
		cachePathProp="${cachePathProc}/${pathProp}"
		
		log "\n[Zip]" "$file"
		log "[File Last Update]" "$(timeformat $timeStamp)"
		unzip -o "$file" -d "$cachePathProc" > /dev/null
		dos2unix "$cachePathProp"
		source "$cachePathProp"
		
		[ -n "$id" ] && echo "$id" | grep -iq "$nameDir" && log "[Module ID found]" "$id" || continue
		
		if [ "$versionCode" -ge "$tmpVCode" ]; then
			tmpVCode=$versionCode
			log "[Lastest Version]" "$versionCode"
		else
			continue
		fi
		
		if [ "$timeStamp" -gt "$tmpTStamp" ]; then
			tmpTStamp=$timeStamp
			log "[Lastest Update]" "$(timeformat $tmpTStamp)"
		else
			continue
		fi
		
		pathParent=$(dirname $(unzip -l "$file" | awk '{print $4}' | grep 'axeron.prop' | head -n 1))
		pathCash="${pathCash:-"${cash}/${id}"}"
		if [ -n "$pathParent" ]; then
			cachePathParent="${cachePathProp}/${pathParent}"
		else
			cachePathParent="${cachePathProp}"
		fi
		
		rm -r "$pathCash" && log "[Old module has ben removed.]"
  	mkdir -p "$pathCash" && log "[New tmp folder has ben created.]"
  	
  	for item in "${cachePathParent%/}"/*; do
			if [ -e "$item" ]; then
				mv -f "$item" "${pathCash}/"
			fi
		done
		
	done
}

fax $@