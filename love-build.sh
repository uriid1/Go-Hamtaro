#!/bin/bash

# 
case $1 in
	-b | --build)
		echo "Create .love"
		zip -r game.love libs engine assets resource.lua main.lua conf.lua
	;;

	-g | --git)
	# Create
	echo "# Go-Hamtaro" >> README.md
	git init
	git add README.md
	git commit -m "first commit"
	git branch -M main
	git remote add origin https://github.com/uriid1/Go-Hamtaro.git
	git push -u origin main	

	# Push
	git remote add origin https://github.com/uriid1/Go-Hamtaro.git
	git branch -M main
	git push -u origin main
	;;

	*)
		echo
		echo "The parameters are set incorrectly!"
		exit 0
esac

# 
case $2 in
	-srgb)
		echo "To sRGB..."
		for file in $(find "assets/spr" -maxdepth 1 -type f -regextype posix-extended -iregex ".*\.(png|PNG)$"); do
			echo $file
			magick $file -colorspace RGB -colorspace sRGB $file
		done
	;;
	-c | --clear)
		# Отчистка кеша
		echo "Clear cash"
		rm -f *.png~
	;;

	*)
		echo
		echo "The parameters are set incorrectly!"
		exit 0
esac