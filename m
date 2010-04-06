From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Apr 2010 18:13:44 -0000
Subject: LVM2/test t-mirror-lvconvert.sh
Message-ID: <20100406181344.19576.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-06 18:13:43

Modified files:
	test           : t-mirror-lvconvert.sh 

Log message:
	disable another broken check in a test

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert.sh.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/test/t-mirror-lvconvert.sh	2010/04/06 16:30:53	1.19
+++ LVM2/test/t-mirror-lvconvert.sh	2010/04/06 18:13:43	1.20
@@ -309,7 +309,8 @@
 prepare_lvs_
 lvcreate -l2 -n $lv1 $vg $dev1
 lvconvert -m +1 --mirrorlog mirrored $vg/$lv1 $dev1 $dev2 --alloc anywhere
-mimages_are_redundant_ $vg $lv1
+# FIXME Disable next check: --alloc anywhere makes *no* guarantees about placement - that's the entire point of it!
+#mimages_are_redundant_ $vg $lv1
 check_and_cleanup_lvs_
 
 


