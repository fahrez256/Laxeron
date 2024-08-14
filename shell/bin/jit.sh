$AXFUN
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
jit "$@"