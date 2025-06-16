#!/bin/bash

# ВНИМАНИЕ! Если нет папки fv_utf8 то необходимо скачать эту библиотеку:
# git clone https://github.com/unxed/fv_utf8

rm settings_editor
rm -rf units
fpcmake
make
