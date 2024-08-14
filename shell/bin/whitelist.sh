$AXFUN
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
whitelist "$@"