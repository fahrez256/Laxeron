$AXFUN
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
axprop "$@"