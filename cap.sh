#!/bin/bash
choice=$1
N=$2

OUT=~/android/arm/nougat/out/target/product/deb/

push_systemui()
{
	if [ $choice -eq 1 ]; then
		. build/envsetup.sh
		lunch 38
		make SystemUI -j$N
	fi
	adb start-server
	#Find and kill SystemUI
	adb shell ps | grep com.android.systemui | awk '{print $2}' | xargs adb shell kill
	#remount /system as rw
	adb remount
	#push the apk
	adb push $OUT/system/priv-app/SystemUI/SystemUI.apk /system/priv-app/SystemUI/SystemUI.apk
	#fix permissions
	adb shell chmod 0644 /system/priv-app/SystemUI/SystemUI.apk
	sleep 1
	#start systemui service back again
	adb shell am startservice -n com.android.systemui/.SystemUIService
}

push_launcher3()
{
	if [ $choice -eq 3 ]; then
		. build/envsetup.sh
		lunch 38
		make Launcher3 -j$N
	fi
	adb start-server
	#remount /system as rw
	adb remount
	#push the apk
	adb push $OUT/system/app/Launcher3/Launcher3.apk /system/app/Launcher3/Launcher3.apk
	#fix permissions
	adb shell chmod 0644 /system/app/Launcher3/Launcher3.apk
	#reboot after pushing
	adb reboot
}

case $choice in
	1)
		echo "Compiling and Pushing SystemUI"
		push_systemui
		;;
	2)
		echo "Only Pushing SystemUI"
		push_systemui
		;;
	3)
		echo "Compiling and Pushing Launcher3"
		push_launcher3
		;;
	4)
		echo "Only Pushing Launcher3"
		push_launcher3
		;;
	*)
		echo "You high nigga ?"
		;;
esac