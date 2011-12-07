From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 7 Dec 2011 12:29:42 -0000
Subject: LVM2 ./WHATS_NEW_DM scripts/lvm2_monitoring_in ...
Message-ID: <20111207122942.24967.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-12-07 12:29:41

Modified files:
	.              : WHATS_NEW_DM 
	scripts        : lvm2_monitoring_init_red_hat.in 
	                 lvm2_monitoring_init_rhel4 

Log message:
	Fix lvm2-monitor init script to use normalized output when using vgs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.524&r2=1.525
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_monitoring_init_red_hat.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_monitoring_init_rhel4.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW_DM	2011/11/18 19:34:02	1.524
+++ LVM2/WHATS_NEW_DM	2011/12/07 12:29:41	1.525
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Fix lvm2-monitor init script to use normalized output when using vgs.
   Add test for max length (DM_MAX_TYPE_NAME) of target type name.
   Include a copy of kernel DM documentation in doc/kernel.
   Improve man page style for dmsetup.
--- LVM2/scripts/lvm2_monitoring_init_red_hat.in	2011/08/11 15:27:46	1.5
+++ LVM2/scripts/lvm2_monitoring_init_red_hat.in	2011/12/07 12:29:41	1.6
@@ -48,7 +48,7 @@
 {
 	ret=0
 	# TODO do we want to separate out already active groups only?
-	VGSLIST=`$VGS --noheadings -o name 2> /dev/null`
+	VGSLIST=`$VGS --noheadings -o name --config 'log{command_names=0 prefix="  "}' 2> /dev/null`
 	for vg in $VGSLIST
 	do
 	    action "Starting monitoring for VG $vg:" $VGCHANGE --monitor y --poll y $vg || ret=$?
@@ -66,7 +66,7 @@
 	   echo "Not stopping monitoring, this is a dangerous operation. Please use force-stop to override."
 	   return 1
 	fi
-	VGSLIST=`$VGS --noheadings -o name 2> /dev/null`
+	VGSLIST=`$VGS --noheadings -o name --config 'log{command_names=0 prefix="  "}' 2> /dev/null`
 	for vg in $VGSLIST
 	do
 	    action "Stopping monitoring for VG $vg:" $VGCHANGE --monitor n $vg || ret=$?
--- LVM2/scripts/lvm2_monitoring_init_rhel4	2007/06/28 17:33:44	1.4
+++ LVM2/scripts/lvm2_monitoring_init_rhel4	2011/12/07 12:29:41	1.5
@@ -31,7 +31,7 @@
 {
 	ret=0
 	# TODO do we want to separate out already active groups only?
-	VGS=`vgs --noheadings -o name 2> /dev/null`
+	VGS=`vgs --noheadings -o name --config 'log{command_names=0 prefix="  "}' 2> /dev/null`
 	for vg in $VGS
 	do
 	    action "Starting monitoring for VG $vg:" $VGCHANGE --monitor y $vg || ret=$?
@@ -49,7 +49,7 @@
 	   echo "Not stopping monitoring, this is a dangerous operation. Please use force-stop to override."
 	   return 1
 	fi
-	VGS=`vgs --noheadings -o name 2> /dev/null`
+	VGS=`vgs --noheadings -o name --config 'log{command_names=0 prefix="  "}' 2> /dev/null`
 	for vg in $VGS
 	do
 	    action "Stopping monitoring for VG $vg:" $VGCHANGE --monitor n $vg || ret=$?


