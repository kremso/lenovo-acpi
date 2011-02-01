#!/bin/sh
 # Default acpi script that takes an entry for all actions
 
 set $*

 
ev_type=`echo "$1" | cut -d/ -f1`
 
# We have to take special care for events send by ibm/hotkey:
if [ "$ev_type" = "ibm" ]; then
	ev_type=`echo "$1" | cut -d/ -f1`
 	event=`echo "$1" | cut -d/ -f2`
 	key="$2"\ "$3"\ "$4"
 
else 
 	# Take care about the way events are reported
 	ev_type=`echo "$1" | cut -d/ -f1`
 	if [ "$ev_type" = "$1" ]; then
 		event="$2";
 	else
 		event=`echo "$1" | cut -d/ -f2`
 	fi
fi
 
case "$ev_type" in
     button)
         case "$event" in
             power)
 		logger "acpid: power button pressed; starting shutdown"
                /sbin/init 0
 		break
                ;;
 	    sleep)
 		logger "acpid: sleep button pressed; initiating hibernate-ram"
 		/usr/sbin/pm-suspend
 		;;
             lid)
 		logger "acpid: lid event" 
 		;;
 	    *)
                logger "acpid: action $2 is not defined"
                ;;
         esac
     ;;
 
 # BEGIN customization for ibm/hotkey:
    ibm)
 	case "$event" in
 		hotkey)
 			case "$key" in
 				"HKEY 00000080 00001002")
 					logger "acpid: lock button (Fn+F2) pressed"
					/etc/acpi/actions/lock
 					;;
 		 		"HKEY 00000080 00001003")
                 		        logger "acpid: battery button (Fn+F3) pressed; switching display off"
					/etc/acpi/actions/battery
 					;;
 				"HKEY 00000080 00001004")
 		                        logger "acpid: sleep button (Fn+F4) pressed; initiating hibernate-ram"
					/etc/acpi/actions/suspend
 					;;
 				"HKEY 00000080 00001005")
 		                        logger "acpid: bluetooth button (Fn+F5) pressed; toggling bluetooth"
					/etc/acpi/actions/radio 
 					;;
 				"HKEY 00000080 00001007")
 		                        logger "acpid: screen toggle button (Fn+F7) pressed"
					/etc/acpi/actions/screen
 					;;
 				"HKEY 00000080 00001008")
                 		        logger "acpid: UltraNav toggle button (Fn+F8) pressed; toggling touchpad status"
					/etc/acpi/actions/touchpad
 					;;
 				"HKEY 00000080 00001009")
                 		        logger "acpid: eject button (Fn+F9) pressed"
					/etc/acpi/actions/eject
 					;;
 				"HKEY 00000080 0000100c")
                 		        logger "acpid: hibernate button (Fn+F12) pressed; initiating hibernate"
					/etc/acpi/actions/hibernate
 					;;
 				"HKEY 00000080 00007000")
                 		        logger "acpid: radio switch action; toggling all wireless devices"
					/etc/acpi/actions/killswitch
 					;;
 				"HKEY 00000080 00001010")
 					logger "acpid: increase brightness"
					/etc/acpi/actions/brightness up
 					break
 					;;
 				"HKEY 00000080 00001011")
 					logger "apcid: decrease brightness"
					/etc/acpi/actions/brightness down
 					break
 					;;
 				"HKEY 00000080 00005001")
 					# This is the lid CLOSE event
 					# as of now it is already handled above
 		                        ;;
 				"HKEY 00000080 00005002")
 		                        # This is the lid OPEN event
                 		        # as of now it is already handled above
 		                        ;;
 				*)
 					logger "acpid: $ev_type/$event $key is not defined"
 
 					;;
 			esac
   			;;			
 		dock)
 		    	case "$key" in
 				"GDCK 00000003 00000001")
 					logger "acpid: Dock eject request"
 					;;
 			        "GDCK 00000003 00000002")
 					logger "acpid: laptop was undocked"
 					;;
 				"GDCK 00000000 00000003")	
 					logger "acpid: laptop was docked"
 
 					;;
 				*)
 					logger "acpid: $ev_typ $event event $key is not defined"
 					;;
 			esac
 			;;
 		bay)
 			case "$key" in
 				"MSTR 00000003 00000000")
 					logger "acpid: got ultrabay eject request"
 					;;
 			        "MSTR 00000001 00000000")
 					logger "acpid: ultrabay eject lever inserted"
 
 					;;
 			esac
 			;;
     esac
     ;;	
     *)
         logger "ACPI group $1 / action $2 is not defined"
         ;;
 esac

