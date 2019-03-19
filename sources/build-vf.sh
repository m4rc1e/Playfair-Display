#!/bin/sh
set -e


echo "Generating VFs"
fontmake -g Playfair-Display-Roman.glyphs -o variable --output-path ../fonts/TTF/PlayfairDisplay-Roman-VF.ttf
fontmake -g Playfair-Display-Italic.glyphs -o variable --output-path ../fonts/TTF/PlayfairDisplay-Italic-VF.ttf

rm -rf master_ufo/ instance_ufo/


echo "Post processing VFs"
vfs=$(ls ../fonts/TTF/*-VF.ttf)
for vf in $vfs
do
	gftools fix-dsig -f $vf;
	ttfautohint $vf "$vf.fix";
	mv "$vf.fix" $vf;
	gftools fix-hinting $vf;
	mv "$vf.fix" $vf;
done


echo "Fixing VF Meta"
gftools fix-vf-meta $vfs;
for vf in $vfs
do
	mv "$vf.fix" $vf;
	ttx -f -x "MVAR" $vf; # Drop MVAR. Table has issue in DW
	rtrip=$(basename -s .ttf $vf)
	new_file=../fonts/TTF/$rtrip.ttx;
	rm $vf;
	ttx $new_file
	rm $new_file
done

python generate_gf_version.py

