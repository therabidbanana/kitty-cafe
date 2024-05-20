compile: source/**/*.fnl
	./support/build.sh

build: compile
	pdc -k source kitty-cafe.pdx
	cp source/*.ldtk kitty-cafe.pdx/

launch: build
	playdate kitty-cafe.pdx

clean:
	rm ./source/main.lua ./kitty-cafe.pdx

win-compile: source/**/*.fnl
	powershell.exe "./support/build.ps1"

win-build: win-compile
	powershell.exe "pdc -k source kitty-cafe.pdx"
	powershell.exe "cp source/*.ldtk kitty-cafe.pdx/"

win-launch: win-build
	powershell.exe "playdate kitty-cafe.pdx"

win-clean:
	powershell.exe -noprofile -command "& {rm ./source/main.lua}"
	powershell.exe -noprofile -command "& {rm ./kitty-cafe.pdx}"
