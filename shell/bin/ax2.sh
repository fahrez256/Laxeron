$AXFUN
fax() {
	local showLog=true

	log() { 
		[ "$showLog" = true ] && echo -e "${ORANGE}${1}${NC} ${GREY}${2}${NC}"; 
	}

	if [ "$1" = "--log" ]; then
		showLog=true
		shift
	fi
	
	local nameDir="$1"
	
	start_time=$(date +%s%3N)
	log "[Starting FAX]" "$nameDir"
	
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
	for file in $(find "$modulePath" -type f -iname "*.zip*"); do
		ctr=$((ctr + 1))
		
		pathProp=$(unzip -l "$file" | awk '/axeron.prop/ {print $4; exit}')
		timeStamp=$(stat -c %Y "$file")
		cachePathProc="${cachePath}/proc${ctr}"
		cachePathProp="${cachePathProc}/${pathProp}"
		
		unzip -o "$file" -d "$cachePathProc" > /dev/null
		dos2unix "$cachePathProp"
		source "$cachePathProp"
		
		[ -n "$id" ] && echo "$id" | grep -iq "$nameDir" || continue
		idFound=true
		log "\n[Zip]" "$file"
		log "[File Last Update]" "$(timeformat $timeStamp)"
		
		[ "$versionCode" -ge "$tmpVCode" ] || continue
		tmpVCode=$versionCode
		log "[Lastest Version]" "$versionCode"
		
		[ "$timeStamp" -gt "$tmpTStamp" ] || continue
		tmpTStamp=$timeStamp
		log "[Lastest Update]" "$(timeformat $tmpTStamp)"
		
		# Mendapatkan direktori dari file 'axeron.prop' di dalam arsip zip
		pathParent="$(dirname $(unzip -l "$file" | awk '/axeron.prop/ {print $4}' | head -n 1))"
		[ "$pathParent" == "." ] && pathParent=""
		
		pathCash="${pathCash:-"${cash}/${id}"}"
		cachePathParent="${cachePathProc}/${pathParent}"
		
		log "[pathParent]" "$cachePathParent"
		
		[ -d "$pathCash" ] rm -r "$pathCash" && log "[Old module has been removed.]"
		mkdir -p "$pathCash" && log "[Installing new module.]"
		
		for item in "${cachePathParent%/}"/*; do
			if [ -e "$item" ]; then
				mv -f "$item" "${pathCash}/"
			fi
		done
		
		pathCashProp=$(find "$pathCash" -type f -iname "axeron.prop")
		axprop --log "$showLog" "$pathCashProp" timeStamp "$tmpTStamp"
		log "[\$] [Module successfully updated.]" "$(timeformat $tmpTStamp)"
	done
	
	if [ "$idFound" = false ]; then
		log "[AX processing complete. No matching ID found.]"
		echo "ID not found"
		exit 1
	fi
	
	find "$pathCash" -type f -exec chmod +x {} \;

	install=$(find "$pathCash" -type f -iname "${install:-"install"}*")
	remove=$(find "$pathCash" -type f -iname "${remove:-"remove"}*")
	execution_time=$(($(date +%s%3N) - start_time))
	log "[AX processing complete.]" "$execution_time milliseconds\n"
	
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

fax $@