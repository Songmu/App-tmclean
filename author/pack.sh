#!/bin/sh
set -e
dst=tmclean
src=script/$dst
fatlib=fatlib

plenv local 5.10.1-vanilla

rm -rf $fatlib
cpanm -L $fatlib -nq --installdeps .

target="App Module TAP CPAN Parse ExtUtils JSON Test Test2 ok.pm Test2.pm darwin-2level"
for i in $target; do
  rm -rf fatlib/lib/perl5/$i
done

fatpack-simple --shebang '#!/usr/bin/env perl' "$src" -o "$dst"
chmod +x $dst
