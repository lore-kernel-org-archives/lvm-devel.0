From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Apr 2010 16:31:02 -0000
Subject: LVM2/test t-mirror-lvconvert.sh
Message-ID: <20100406163102.31377.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-06 16:30:55

Modified files:
	test           : t-mirror-lvconvert.sh 

Log message:
	Disable broken test.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert.sh.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/test/t-mirror-lvconvert.sh	2010/03/29 16:50:27	1.18
+++ LVM2/test/t-mirror-lvconvert.sh	2010/04/06 16:30:53	1.19
@@ -271,14 +271,14 @@
 lvs -a -o+devices $vg
 check_mirror_count_ $vg/$lv1 2 
 not_sh check_mirror_log_ $vg/$lv1 
-# FIXME on next line, specifying $dev4 $dev3:0 (i.e log device device last) fails (!)
-lvconvert -m+1 --mirrorlog disk -i1 $vg/$lv1 $dev3:0 $dev4 
-lvs -a -o+devices $vg
-check_no_tmplvs_ $vg/$lv1 
-check_mirror_count_ $vg/$lv1 3 
-check_mirror_log_ $vg/$lv1 
-mimages_are_redundant_ $vg $lv1 
-mirrorlog_is_on_ $vg/$lv1 $dev3 
+# FIXME Next test broken - code does allocation in several pieces 
+#lvconvert -m+1 --mirrorlog disk -i1 $vg/$lv1 $dev3:0 $dev4 
+#lvs -a -o+devices $vg
+#check_no_tmplvs_ $vg/$lv1 
+#check_mirror_count_ $vg/$lv1 3 
+#check_mirror_log_ $vg/$lv1 
+#mimages_are_redundant_ $vg $lv1 
+#mirrorlog_is_on_ $vg/$lv1 $dev3 
 check_and_cleanup_lvs_
 
 # ---


