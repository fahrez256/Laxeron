echo "$# $@"
$AXFUN
local modulePath="/sdcard/AxeronModules"
local cash="/data/local/tmp/axeron_cash"

shx() {
	local ORANGE='\033[38;2;255;85;3m'
	local GREY='\033[38;2;105;105;105m'
	local NC='\033[0m'
	local showLog=true

	log() { 
		[ "$showLog" = true ] && echo -e "${ORANGE}${1}${NC} ${GREY}${2}${NC}"; 
	}
	
	timeformat() { echo "$(date -d "@$1" +"%Y-%m-%d %H.%M.%S")"; }
	
	local nameDir="$1"
	
	mkdir -p "$cash"
	
	start_time=$(date +%s%3N)
	log "[Starting SHX]" "$nameDir"
	
	pathCash=$(find "$cash" -type d -iname "$nameDir")
	
	[ -n "$pathCash" ] && pathCashProp=$(find "$pathCash" -type f -iname "axeron.prop") && log "[Path Cash]" "$pathCash"
	[ -n "$pathCashProp" ] && dos2unix "$pathCashProp" && source "$pathCashProp" && log "[Loading prop from]" "$pathCashProp"

	tmpVCode=${versionCode:-0}
	tmpTStamp=${timeStamp:-0}
	
	if [ -n "$pathCash" ]; then
		log "[Init Version Code]" "$tmpVCode"
		log "[Init Last Update]" "$(timeformat $tmpTStamp)"
	fi

	ctr=0
	idFound=false

	IFS=$'\n'
	for prop in $(find "$modulePath" -type d -path '*/.*' -prune -o -mindepth 2 -type f -iname "axeron.prop" -print); do
		ctr=$((ctr + 1))
		propFolder="$(dirname $prop)"
		grep -q $'\r' $prop && dos2unix "$prop"
		source "$prop"
		
		timeStamp=0
		for item in $(find "$propFolder" -type f); do
			ts=$(stat -c %Y "$item")
			[ "$ts" -gt "$timeStamp" ] && timeStamp="$ts"
		done
		
		[ -n "$id" ] && echo "$id" | grep -iq "$nameDir" || continue
		idFound=true
		log "\n[Prop Path]" "$prop"
		log "[Dirname]" "$propFolder"
		
		[ "$versionCode" -ge "$tmpVCode" ] || continue
		tmpVCode=$versionCode
		log "[Lastest Version]" "$versionCode"
		
		[ "$timeStamp" -gt "$tmpTStamp" ] || continue
		tmpTStamp=$timeStamp
		log "[Lastest Update]" "$(timeformat "$tmpTStamp")"
			
		pathCash="${cash}/$id"
		
		[ -d "$pathCash" ] && rm -r "$pathCash" && log "[Old module has been removed.]"
		mkdir -p "$pathCash" && log "[Installing new module.]"
		
		for item in "${propFolder%/}"/*; do
			echo $item
			if [ -e "$item" ]; then
				if [ -d "$item" ]; then
					cp -r "$item" "$pathCash"
				else
					cp "$item" "$pathCash"
				fi
			fi
		done
		
		pathCashProp=$(find "$pathCash" -type f -iname "axeron.prop")
		log "$pathCashProp"
		axprop --log "$showLog" "$pathCashProp" timeStamp "$tmpTStamp"
		log "[\$] [Module successfully updated.]" "$(timeformat $tmpTStamp)"
	done

	if [ "$idFound" = false ]; then
		log "[SHX processing complete. No matching ID found.]"
		echo "ID not found"
		exit 1
	fi
	
	#grep -q $'\r' $prop && dos2unix "$pathCashProp"
	#source "$pathCashProp"
	#log "[Final prop from]" "$pathCashProp"
	find "$pathCash" -type f -exec chmod +x {} \;

	install=$(find "$pathCash" -type f -iname "${install:-"install"}*" | head -n 1)
	remove=$(find "$pathCash" -type f -iname "${remove:-"remove"}*" | head -n 1)
	execution_time=$(($(date +%s%3N) - start_time))
	log "[SHX processing complete.]" "$execution_time milliseconds\n"
	
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

shx $@