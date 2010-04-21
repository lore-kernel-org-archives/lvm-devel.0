From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 21 Apr 2010 14:04:27 -0000
Subject: LVM2 ./WHATS_NEW test/t-mirror-lvconvert.sh to ...
Message-ID: <20100421140427.10798.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-04-21 14:04:26

Modified files:
	.              : WHATS_NEW 
	test           : t-mirror-lvconvert.sh 
	tools          : lvconvert.c 

Log message:
	Disallow the addition of mirror images while a mirror up-convert
	is already occurring.  The addition of new legs can be retried
	once the current conversion is complete.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1533&r2=1.1534
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert.sh.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.129&r2=1.130

--- LVM2/WHATS_NEW	2010/04/21 13:55:08	1.1533
+++ LVM2/WHATS_NEW	2010/04/21 14:04:24	1.1534
@@ -1,5 +1,6 @@
 Version 2.02.64 -
 =================================
+  Disallow the addition of mirror images while a conversion is happening.
   Disallow primary mirror image removal when mirror is not in-sync.
   Remove obsolete --name parameter from vgcfgrestore.
   Add -S command to clvmd to restart the daemon preserving exclusive locks.
--- LVM2/test/t-mirror-lvconvert.sh	2010/04/21 13:55:08	1.24
+++ LVM2/test/t-mirror-lvconvert.sh	2010/04/21 14:04:26	1.25
@@ -155,11 +155,14 @@
 # add 1 mirror
 prepare_lvs_
 lvs -a -o+devices $vg
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+lvcreate -l5 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
 lvs -a -o+devices $vg
 check_mirror_count_ $vg/$lv1 2
 check_mirror_log_ $vg/$lv1
-lvconvert -m+1 -i1 $vg/$lv1 $dev4
+lvconvert -m+1 -i 20 -b $vg/$lv1 $dev4
+# Next convert should fail b/c we can't have 2 at once
+not lvconvert -m+1 -b $vg/$lv1 $dev5
+wait_conversion_ $vg/$lv1
 lvs -a -o+devices $vg
 check_no_tmplvs_ $vg/$lv1
 check_mirror_count_ $vg/$lv1 3
--- LVM2/tools/lvconvert.c	2010/04/20 12:18:31	1.129
+++ LVM2/tools/lvconvert.c	2010/04/21 14:04:26	1.130
@@ -995,6 +995,16 @@
 		}
 
 		/*
+		 * Is there already a convert in progress?  We do not
+		 * currently allow more than one.
+		 */
+		if (find_temporary_mirror(lv) || (lv->status & CONVERTING)) {
+			log_error("%s is already being converted.  Unable to start another conversion.",
+				  lv->name);
+			return 0;
+		}
+
+		/*
 		 * Log addition/removal should be done before the layer
 		 * insertion to make the end result consistent with
 		 * linear-to-mirror conversion.


