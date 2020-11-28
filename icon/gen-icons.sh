#!/bin/bash

ios_res=(20 29 40 58 60 76 80 87 120 152 167 180 1024)
# wos_res=(48 55 58 80 87 88 100 172 196 216 1024)

SD="$(dirname "$0")"
SRC_IMG="$SD/icon.png"

IOS_DIR="$SD/../podcast-shuffler/Assets.xcassets/AppIcon.appiconset/"
#WOS_DIR="$SD/../watchapp/Assets.xcassets/AppIcon.appiconset/"

echo "Source Image: $SRC_IMG"

for res in "${ios_res[@]}"
do
    echo "Converting iOS icon $res"
    convert "$SRC_IMG" -resize "${res}x${res}" "$IOS_DIR/$res.png"
done

#for res in "${wos_res[@]}"
#do
    #echo "Converting Watch OS icon $res"
    #convert "$SRC_IMG" -resize "${res}x${res}" "$WOS_DIR/Icon-$res.png"
#done
