#!/bin/sh
set -e
dst=tmclean
src=script/$dst
fatlib=fatlib
perlversion=5.10.1-vanilla

if ! plenv local $perlversion >/dev/null 2>&1; then
  plenv install 5.10.1 --as $perlversion -j4 -DDEBUGGING=-g
fi
plenv local $perlversion
trap 'rm .perl-version; plenv rehash' EXIT

plenv rehash
plenv install-cpanm
cpanm -qn App::FatPacker::Simple

rm -rf $fatlib
cpanm -L $fatlib -nq --installdeps .

target="App Module TAP CPAN Parse ExtUtils JSON Test Test2 ok.pm Test2.pm darwin-2level"
for i in $target; do
  rm -rf fatlib/lib/perl5/$i
done

fatpack-simple --shebang '#!/usr/bin/env perl' "$src" -o "$dst"
chmod +x $dst
