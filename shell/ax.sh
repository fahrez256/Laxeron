$AXFUN
ax() {
	if [ $# -eq 0 ]; then
		echo "Usage: ax <id_module> [options] [arguments]"
		exit 1
	fi

	local ORANGE='\033[38;2;255;85;3m'
	local GREY='\033[38;2;105;105;105m' # Kode warna ANSI untuk oranye
	local NC='\033[0m'		 # Kode untuk mengatur ulang warna (no color)
	local showLog=false

	log() { 
		[ "$showLog" = true ] && echo -e "${ORANGE}${1}${NC} ${GREY}${2}${NC}"; 
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
	
	start_time=$(date +%s%3N)
	log "[Starting AX]" "$nameDir"

	rm -rf "$cachePath"
	mkdir -p "$cachePath"

	pathCash=$(find "$cash" -type d -iname "$nameDir")
	log "[Cache dir]" "$pathCash"

	if [ -n "$pathCash" ]; then
		pathCashProp=$(find "$pathCash" -type f -iname "axeron.prop")
		if [ -f "$pathCashProp" ]; then
			log "[Loading prop from]" "$pathCashProp"
			dos2unix "$pathCashProp"
			. "$pathCashProp"
		else
			log "[No axeron.prop found in cache directory.]"
		fi
	else
		pathCash="${cash}/${nameDir}"
		log "[No cached dir found. Using new path]" "$pathCash"
	fi

	tmpVCode=${versionCode:-0}
	tmpTStamp=${timeStamp:-0}
	log "[Init Version Code]" "$tmpVCode"
	log "[Init Timestamp]" "$tmpTStamp"

	ctr=0
	idFound=false

	IFS=$'\n'
	for file in $(find "/sdcard/AxeronModules" -type f -iname "*.zip*"); do
		ctr=$((ctr + 1))
		log "\n[${ctr}] [Processing file]" "$file"

		pathProp=$(unzip -l "$file" | awk '/axeron.prop/ {print $4; exit}')
		timeStamp=$(stat -c %Y "$file")
		log "[${ctr}] [File Timestamp]" "$timeStamp"
		log "[${ctr}] [Path to axeron.prop]" "$pathProp"

		if [ -z "$pathProp" ]; then
			log "[axeron.prop not found in]" "$file"
			continue
		fi

		cachePathProc="$cachePath/proc${ctr}"
		mkdir -p "$cachePathProc"
		unzip -o "$file" "$pathProp" -d "$cachePathProc" > /dev/null 2>&1
		cachePathProp="${cachePathProc}/${pathProp}"
		log "[${ctr}] [Extracted axeron.prop to]" "$cachePathProp"

		if [ ! -f "$cachePathProp" ]; then
			log "[${ctr}] [Failed to extract axeron.prop from]" "$file"
			continue
		fi

		dos2unix "$cachePathProp"
		. "$cachePathProp"
		log "[${ctr}] [Loaded prop from]" "$cachePathProp"

		if [ -n "$id" ] && echo "$id" | grep -iq "$nameDir"; then
			idFound=true
			log "[\$] [ID $id matches $nameDir. Checking version and timestamp."

			if [ "$versionCode" -ge "$tmpVCode" ] && [ "$timeStamp" -gt "$tmpTStamp" ]; then
				tmpVCode=$versionCode
				tmpTStamp=$timeStamp

		rm -rf "${cash}/${id}" && log "[\$] [Old module has ben removed.]"
  		mkdir -p "${cash}/${id}/tmp" && log "[\$] [New tmp folder has ben created.]"
				pathParent=$(dirname $(unzip -l "$file" | awk '{print $4}' | grep 'axeron.prop' | head -n 1))
				if [ -n "$pathParent" ]; then
					log "[\$] [Found parent folder]" "$pathParent"
					unzip -o "$file" -d "${cash}/${id}/tmp" > /dev/null 2>&1
					for item in "${cash}/${id}/tmp/${pathParent%/}"/*; do
						if [ -e "$item" ]; then
							mv -f "$item" "${cash}/${id}/"
						fi
					done
					rm -rf "${cash}/${id}/tmp"
					log "[\$] [Moved files from parent folder to]" "${cash}/${id}/"
				else
					unzip -o "$file" -d "${cash}/${id}" > /dev/null 2>&1
					log "[\$] [No parent folder. Extracted files directly to]" "${cash}/${id}/"
				fi

				pathCash=$(find "$cash" -type d -iname "$nameDir")
				pathCashProp=$(find "$pathCash" -type f -iname "axeron.prop")
				axprop --log "$showLog" "$pathCashProp" timeStamp "$tmpTStamp"
				log "[\$] [Module successfully updated.]"
			else
				log "[!] [Version code or timestamp not updated.]"
			fi
		else
			log "[!] [ID $id does not match $nameDir.]"
		fi
	done

	log "\n[ID found successfully]" "$idFound"

		if [ "$idFound" = false ]; then
		log "[AX processing complete. No matching ID found.]"
		echo "ID not found"
		exit 404
	fi

	dos2unix "$pathCashProp"
	. "$pathCashProp"
	log "[Final prop from]" "$pathCashProp"
	find "$pathCash" -type f -exec chmod +x {} \;
	log "[Set executable permissions on files.]"

	install=$(find "$pathCash" -type f -iname "${install:-"install"}*")
	remove=$(find "$pathCash" -type f -iname "${remove:-"remove"}*")
	log "[Install script]" "$install"
	log "[Remove script]" "$remove"
	log "[AX processing complete.]"
	end_time=$(date +%s%3N)
	execution_time=$((end_time - start_time))
	log "[Execution time:]" "$execution_time milliseconds\n"
	
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
ax $@