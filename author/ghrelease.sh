#!/bin/sh
set -e

app=tmclean

ver=$(perl -Ilib -MApp::$app -e "print \$App::$app::VERSION")
archive_base=${app}_${ver}_darwin_amd64
dist_dir=dist/$ver
mkdir -p $dist_dir

rm -f $dist_dir/$archive_base.zip

mkdir $archive_base
cp $app Changes README.md LICENSE $archive_base
zip -r $dist_dir/$archive_base.zip $archive_base

rm -rf $archive_base

ghr $ver dist/$ver
