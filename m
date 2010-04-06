From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 6 Apr 2010 23:04:45 -0000
Subject: LVM2/test t-mirror-lvconvert.sh
Message-ID: <20100406230445.5293.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-04-06 23:04:45

Modified files:
	test           : t-mirror-lvconvert.sh 

Log message:
	Move a fragile testcase toward the end of t-mirror-lvconvert.sh.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert.sh.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/test/t-mirror-lvconvert.sh	2010/04/06 22:22:26	1.21
+++ LVM2/test/t-mirror-lvconvert.sh	2010/04/06 23:04:45	1.22
@@ -262,26 +262,6 @@
 check_and_cleanup_lvs_
 
 # ---
-# add mirror and disk log
-
-# "add 1 mirror and disk log" 
-prepare_lvs_ 
-lvs -a -o+devices $vg
-lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
-lvs -a -o+devices $vg
-check_mirror_count_ $vg/$lv1 2 
-not_sh check_mirror_log_ $vg/$lv1 
-# FIXME on next line, specifying $dev3:0 $dev4 (i.e log device first) fails (!)
-lvconvert -m+1 --mirrorlog disk -i1 $vg/$lv1 $dev4 $dev3:0
-lvs -a -o+devices $vg
-check_no_tmplvs_ $vg/$lv1 
-check_mirror_count_ $vg/$lv1 3 
-check_mirror_log_ $vg/$lv1 
-mimages_are_redundant_ $vg $lv1 
-mirrorlog_is_on_ $vg/$lv1 $dev3 
-check_and_cleanup_lvs_
-
-# ---
 # core log to mirrored log
 
 # change the log type from 'core' to 'mirrored'
@@ -463,3 +443,24 @@
 lvconvert -m1 --mirrorlog disk $vg/$lv1
 lvs -a -o+devices $vg
 check_mirror_log_ $vg/$lv1
+
+# ---
+# add mirror and disk log
+
+# "add 1 mirror and disk log" 
+prepare_lvs_ 
+lvs -a -o+devices $vg
+lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
+lvs -a -o+devices $vg
+check_mirror_count_ $vg/$lv1 2 
+not_sh check_mirror_log_ $vg/$lv1 
+# FIXME on next line, specifying $dev3:0 $dev4 (i.e log device first) fails (!)
+lvconvert -m+1 --mirrorlog disk -i1 $vg/$lv1 $dev4 $dev3:0
+lvs -a -o+devices $vg
+check_no_tmplvs_ $vg/$lv1 
+check_mirror_count_ $vg/$lv1 3 
+check_mirror_log_ $vg/$lv1 
+mimages_are_redundant_ $vg $lv1 
+mirrorlog_is_on_ $vg/$lv1 $dev3 
+check_and_cleanup_lvs_
+


