From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 16 Dec 2011 11:42:57 -0000
Subject: LVM2/scripts lvm2_monitoring_init_red_hat.in l ...
Message-ID: <20111216114257.19521.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-12-16 11:42:56

Modified files:
	scripts        : lvm2_monitoring_init_red_hat.in 
	                 lvm2_monitoring_init_rhel4 

Log message:
	Use also normalized output for vgchange command in lvm2-monitor init script.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_monitoring_init_red_hat.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_monitoring_init_rhel4.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/scripts/lvm2_monitoring_init_red_hat.in	2011/12/07 12:29:41	1.6
+++ LVM2/scripts/lvm2_monitoring_init_red_hat.in	2011/12/16 11:42:56	1.7
@@ -51,7 +51,7 @@
 	VGSLIST=`$VGS --noheadings -o name --config 'log{command_names=0 prefix="  "}' 2> /dev/null`
 	for vg in $VGSLIST
 	do
-	    action "Starting monitoring for VG $vg:" $VGCHANGE --monitor y --poll y $vg || ret=$?
+	    action "Starting monitoring for VG $vg:" $VGCHANGE --monitor y --poll y --config 'log{command_names=0 prefix="  "}' $vg || ret=$?
 	done
 
 	return $ret
@@ -69,7 +69,7 @@
 	VGSLIST=`$VGS --noheadings -o name --config 'log{command_names=0 prefix="  "}' 2> /dev/null`
 	for vg in $VGSLIST
 	do
-	    action "Stopping monitoring for VG $vg:" $VGCHANGE --monitor n $vg || ret=$?
+	    action "Stopping monitoring for VG $vg:" $VGCHANGE --monitor n --config 'log{command_names=0 prefix="  "}' $vg || ret=$?
 	done
 	return $ret
 }
--- LVM2/scripts/lvm2_monitoring_init_rhel4	2011/12/07 12:29:41	1.5
+++ LVM2/scripts/lvm2_monitoring_init_rhel4	2011/12/16 11:42:56	1.6
@@ -34,7 +34,7 @@
 	VGS=`vgs --noheadings -o name --config 'log{command_names=0 prefix="  "}' 2> /dev/null`
 	for vg in $VGS
 	do
-	    action "Starting monitoring for VG $vg:" $VGCHANGE --monitor y $vg || ret=$?
+	    action "Starting monitoring for VG $vg:" $VGCHANGE --monitor y --config 'log{command_names=0 prefix="  "}' $vg || ret=$?
 	done
 
 	return $ret
@@ -52,7 +52,7 @@
 	VGS=`vgs --noheadings -o name --config 'log{command_names=0 prefix="  "}' 2> /dev/null`
 	for vg in $VGS
 	do
-	    action "Stopping monitoring for VG $vg:" $VGCHANGE --monitor n $vg || ret=$?
+	    action "Stopping monitoring for VG $vg:" $VGCHANGE --monitor n --config 'log{command_names=0 prefix="  "}' $vg || ret=$?
 	done
 	return $ret
 }


