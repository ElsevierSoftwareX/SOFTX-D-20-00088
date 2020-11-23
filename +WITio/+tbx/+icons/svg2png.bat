@echo off
set /p side="Enter icon side length in px: "

for %%f in (*.svg) do "c:\Program Files\Inkscape\inkscape.com" -f %%f -e %%~nf.png -C -h %side% -w %side% -y 1.0
