From: agk@sourceware.org <agk@sourceware.org>
Date: 21 Nov 2006 17:44:46 -0000
Subject: LVM2 ./WHATS_NEW scripts/clvmd_init_rhel4
Message-ID: <20061121174446.19003.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-11-21 17:44:46

Modified files:
	.              : WHATS_NEW 
	scripts        : clvmd_init_rhel4 

Log message:
	Fix clvmd_init_rhel4 line truncation (2.02.14).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.504&r2=1.505
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/clvmd_init_rhel4.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/WHATS_NEW	2006/11/20 23:30:45	1.504
+++ LVM2/WHATS_NEW	2006/11/21 17:44:45	1.505
@@ -1,8 +1,9 @@
 Version 2.02.16 -
 ====================================
 
-Version 2.02.15 - 20th November 2006
+Version 2.02.15 - 21st November 2006
 ====================================
+  Fix clvmd_init_rhel4 line truncation (2.02.14).
   Install lvmdump by default.
   Fix check for snapshot module when activating snapshot.
   Fix pvremove error path for case when PV is in use.
--- LVM2/scripts/clvmd_init_rhel4	2006/11/01 18:25:26	1.9
+++ LVM2/scripts/clvmd_init_rhel4	2006/11/21 17:44:46	1.10
@@ -73,7 +73,7 @@
 			done
 		else
 			# Hack to only deactivate clustered volumes
-			clustervgs=`$VGDISPLAY 2> /dev/null | awk 'BEGIN {RS="VG Name"} {if (/Clustered/) print $1;}'
+			clustervgs=`$VGDISPLAY 2> /dev/null | awk 'BEGIN {RS="VG Name"} {if (/Clustered/) print $1;}'`
 			for vg in $clustervgs; do
 				if ! action "Deactivating VG $vg:" $VGCHANGE -anl $vg
 				then


