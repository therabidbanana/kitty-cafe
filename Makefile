compile: source/**/*.fnl
	./support/build.sh

build: compile
	pdc -k source test.pdx
	cp source/*.ldtk test.pdx/

launch: build
	playdate test.pdx

clean:
	rm ./source/main.lua ./test.pdx

win-compile: source/**/*.fnl
	powershell.exe "./support/build.ps1"

win-love-compile: source/**/*.fnl
	powershell.exe "./support/buildlove.ps1"

win-love-launch: win-love-compile
	powershell.exe "love source"

win-love-package: win-love-compile
	powershell.exe -noprofile -command "& {rm ./app.zip}"
	powershell.exe -noprofile -command "& {rm ./app.love}"
	powershell.exe "./support/packagelove.ps1"
	powershell.exe "mv app.zip app.love"

win-love-web: win-love-package
	powershell.exe "npx love.js.cmd -t Playdate -c .\app.love dist"

win-love-serve: win-love-web
	powershell.exe "Start-Process powershell.exe 'python -m http.server 8000 -d dist'"
	powershell.exe "Start-Process 'http://localhost:8000'"

win-build: win-compile
	powershell.exe "pdc -k source test.pdx"
	powershell.exe "cp source/*.ldtk test.pdx/"

win-launch: win-build
	powershell.exe "playdate test.pdx"

win-clean:
	powershell.exe -noprofile -command "& {rm ./source/main.lua}"
	powershell.exe -noprofile -command "& {rm ./test.pdx}"
