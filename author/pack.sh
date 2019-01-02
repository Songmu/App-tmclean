#!/bin/sh
set -ex
dst=tmclean
src=script/$dst
fatlib=fatlib

rm -rf $fatlib
cpanm -L $fatlib -nq --installdeps .
fatpack-simple --shebang '#!/usr/bin/env perl' "$src" -o "$dst"
chmod +x $dst