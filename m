From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Jan 2007 18:02:16 -0000
Subject: LVM2 ./WHATS_NEW scripts/lvm2_monitoring_init_ ...
Message-ID: <20070130180216.25040.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-30 18:02:15

Modified files:
	.              : WHATS_NEW 
	scripts        : lvm2_monitoring_init_rhel4 

Log message:
	Add warning to lvm2_monitoring_init_rhel4 if attempting to stop monitoring.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.565&r2=1.566
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_monitoring_init_rhel4.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2007/01/29 23:01:17	1.565
+++ LVM2/WHATS_NEW	2007/01/30 18:02:15	1.566
@@ -1,5 +1,6 @@
 Version 2.02.21 -
 ===================================
+  Add warning to lvm2_monitoring_init_rhel4 if attempting to stop monitoring.
   Fix vgsplit to handle mirrors.
   Reorder fields in reporting field definitions.
   Fix vgs to treat args as VGs even when PV fields are displayed.
--- LVM2/scripts/lvm2_monitoring_init_rhel4	2007/01/24 23:43:27	1.1
+++ LVM2/scripts/lvm2_monitoring_init_rhel4	2007/01/30 18:02:15	1.2
@@ -25,11 +25,11 @@
 . /etc/init.d/functions
 
 VGCHANGE="/usr/sbin/vgchange"
+WARN=1
 
 start()
 {
-    for ret in 0
-    do
+	ret=0
 	# TODO do we want to separate out already active groups only?
 	VGS=`vgs --noheadings -o name`
 	for vg in $VGS
@@ -40,50 +40,58 @@
 	    fi
 	done
 
-    done
-
-    return $ret
+	return $ret
 }
 
 
 stop()
 {
-    for ret in 0
-    do
+	ret=0
 	# TODO do we want to separate out already active groups only?
+	if test "$WARN" = "1"; then
+	   echo "Not stopping monitoring, this is a dangerous operation. Please use force-stop to override."
+	   return 1
+	fi
 	VGS=`vgs --noheadings -o name`
 	for vg in $VGS
 	do
-	    if ! action "Starting monitoring for VG $vg:" $VGCHANGE --monitor n $vg
+	    if ! action "Stopping monitoring for VG $vg:" $VGCHANGE --monitor n $vg
 	    then
 		ret=$?
 	    fi
 	done
-
-    done
-
+	return $ret
 }
 
-ret=1
+result=1
 
 # See how we were called.
 case "$1" in
   start)
 	start
-	ret=$?
+	result=$?
+	;;
+
+  force-stop)
+	WARN=0
+	stop
+	result=$?
 	;;
 
   stop)
+	test "$runlevel" = "0" && WARN=0
+	test "$runlevel" = "6" && WARN=0
 	stop
-	ret=$?
+	result=$?
 	;;
 
   restart)
+	WARN=0
 	if stop
 	then
 		start
 	fi 
-	ret=$?
+	result=$?
 	;;
 
   status)
@@ -91,8 +99,8 @@
 	;;
 
   *)
-	echo $"Usage: $0 {start|stop|restart|status}"
+	echo $"Usage: $0 {start|stop|restart|status|force-stop}"
 	;;
 esac
 
-exit $ret
+exit $result


