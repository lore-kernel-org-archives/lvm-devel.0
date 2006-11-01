From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Nov 2006 18:25:26 -0000
Subject: LVM2 ./WHATS_NEW scripts/clvmd_init_rhel4
Message-ID: <20061101182526.29421.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-11-01 18:25:26

Modified files:
	.              : WHATS_NEW 
	scripts        : clvmd_init_rhel4 

Log message:
	Fix clustered VG detection and default runlevels in clvmd_init_rhel4.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.487&r2=1.488
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/clvmd_init_rhel4.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/WHATS_NEW	2006/10/30 16:10:55	1.487
+++ LVM2/WHATS_NEW	2006/11/01 18:25:26	1.488
@@ -1,5 +1,6 @@
 Version 2.02.14 - 
 ===================================
+  Fix clustered VG detection and default runlevels in clvmd_init_rhel4.
   Fix high-level free space check for partial allocations.
 
 Version 2.02.13 - 27th October 2006
--- LVM2/scripts/clvmd_init_rhel4	2006/10/04 08:42:14	1.8
+++ LVM2/scripts/clvmd_init_rhel4	2006/11/01 18:25:26	1.9
@@ -1,6 +1,6 @@
 #!/bin/bash
 #
-# chkconfig: 345 24 76
+# chkconfig: - 24 76
 # description: Starts and stops clvmd
 #
 #	       
@@ -73,7 +73,7 @@
 			done
 		else
 			# Hack to only deactivate clustered volumes
-		        clustervgs=`$VGDISPLAY \`$VGS --noheadings -o name\` | awk 'BEGIN {RS="VG Name"} {if (/Clustered/) print $1;}'`
+			clustervgs=`$VGDISPLAY 2> /dev/null | awk 'BEGIN {RS="VG Name"} {if (/Clustered/) print $1;}'
 			for vg in $clustervgs; do
 				if ! action "Deactivating VG $vg:" $VGCHANGE -anl $vg
 				then


