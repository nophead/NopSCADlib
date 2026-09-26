#!/bin/bash

if [ "$1" = "--for-real" ]
then
	command='sed -i'
	extra=''
elif [ "$1" = "--help" ]
then
	echo "Update variable names in your project"
	echo "defaults to dry run, use --for-real to run for real"
	echo "it is not safe to run twice on the same project. Make backups"
	exit
else
	command='sed -n '
	extra='p'
fi

replacements=(
	"s/02352A/disp_02352A/g"
	"s/02531A/disp_02531A/g"
	"s/10mm_disc/disc_10m/g"
	"s/28BYJ_48/step_28BYJ_48/g"
	"s/2p54boxhdr/boxhdr2p54/g"
	"s/2p54header/header2p54/g"
	"s/2p54joiner/joiner2p54/g"
	"s/2p54socket/socket2p54/g"
	"s/35BYGHJ75/step_35BYGHJ75/g"
	"s/5_160430_7/faston_5_160430_7/g"
	"s/6p4mm_disc/disc_6p4mm/g"
	"s/7_segment_\([^\.]\)/disp_7_segment\1/g"
	"s/7_segments\([^\.]\)/disp_7_segments\1/g"
	"s/80ST_faceplate/faceplate_80ST/g"
)

find . -name '*.scad' | while read file
do
	echo $file
	echo "-------------------------------------"
	for r in ${replacements[*]}
	do
		$command "${r}${extra}" $file
	done
done

