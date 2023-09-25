#!/bin/bash

dot_love() {
	echo "Create .love"
	zip -r game.love libs engine assets resource.lua main.lua conf.lua icon.png
}

check_args() {
	
	case $1 in
		-b | --build)
			dot_love
		;;

		-g | --git)
			git add .
			git commit -m "$2"
			git push
		;;

		-s | -srgb)
			echo "To sRGB..."
			for file in $(find "assets/spr" -maxdepth 1 -type f -regextype posix-extended -iregex ".*\.(png|jpg)$"); do
				echo $file
				magick $file -colorspace RGB -colorspace sRGB $file
			done
		;;
		-c | --clear)
			echo "Clear cache"
			rm -f *.png~
		;;

		*)
			echo
			echo "The parameters are set incorrectly!"
			exit 0
	esac
}

if [$1 == ""]; then
	dot_love
else
	check_args $1 $2
fi
