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
	#Stop launcher3 by disabling it
	adb shell pm disable com.android.launcher3.
	#remount /system as rw
	adb remount
	#push the apk
	adb push $OUT/system/app/Launcher3/Launcher3.apk /system/app/Launcher3/Launcher3.apk
	#fix permissions
	adb shell chmod 0644 /system/app/Launcher3/Launcher3.apk
	sleep 1
	#start launcher3 back again
	adb shell pm enable com.android.launcher3
	adb shell am start com.android.launcher3/com.android.launcher3.Launcher
}

push_framework_jar()
{
	if [ $choice -eq 5 ]; then
		. build/envsetup.sh
		lunch 38
		make framework -j$N
	fi
	adb start-server 
	#remount /system as rw
	adb remount
	#push the apk
	adb push $OUT/system/framework/framework.jar /system/framework/framework.jar
	adb push $OUT/system/framework/arm/* /system/framework/arm/
	#fix permissions
	adb shell chmod 0644 /system/framework/framework.jar
	sleep 1
	#perform a soft reboot
	adb shell ps | grep zygote | awk '{print $2}' | xargs adb shell kill
}

push_services()
{
	if [ $choice -eq 7 ]; then
		. build/envsetup.sh
		lunch 38
		make services -j$N
	fi
	adb start-server 
	#remount /system as rw
	adb remount
	#push the apk
	adb push $OUT/system/framework/services.jar /system/framework/services.jar
	#fix permissions
	adb shell chmod 0644 /system/framework/services.jar
	sleep 1
	#perform a soft reboot
	adb shell ps | grep zygote | awk '{print $2}' | xargs adb shell kill
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
	5)
		echo "Compiling and Pushing framework.jar"
		push_framework_jar
		;;
	6)
		echo "Only pushing framework.jar"
		push_framework_jar
		;;
	7)
		echo "Compiling and Pushing services"
		push_services
		;;
	8)
		echo "Only pushing services"
		push_services
		;;
	*)
		echo "You high nigga ?"
		;;
esac