From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 23 Apr 2008 18:28:00 -0000
Subject: LVM2/test t-mirror-lvconvert.sh
Message-ID: <20080423182800.13307.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-04-23 18:27:59

Modified files:
	test           : t-mirror-lvconvert.sh 

Log message:
	Add test for rhbz440405 - lvconvert -m0 fails incorrectly if all PEs allocated.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/t-mirror-lvconvert.sh	2008/01/17 02:20:48	1.2
+++ LVM2/test/t-mirror-lvconvert.sh	2008/04/23 18:27:59	1.3
@@ -387,6 +387,16 @@
    mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
    check_and_cleanup_lvs_'
 
+test_expect_success "rhbz440405: lvconvert -m0 incorrectly fails if all PEs allocated" \
+  'prepare_lvs_ &&
+   lvcreate -l`pvs --noheadings -ope_count $(pv_ 1)` -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0 &&
+   check_mirror_count_ $vg/$lv1 2 &&
+   check_mirror_log_ $vg/$lv1 &&
+   lvconvert -m0 $vg/$lv1 $(pv_ 1) &&
+   check_no_tmplvs_ $vg/$lv1 &&
+   check_mirror_count_ $vg/$lv1 1 &&
+   check_and_cleanup_lvs_'
+
 # ---------------------------------------------------------------------
 
 test_done


