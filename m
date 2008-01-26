From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Jan 2008 00:25:45 -0000
Subject: LVM2/test t-mirror-basic.sh
Message-ID: <20080126002545.5503.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-26 00:25:45

Modified files:
	test           : t-mirror-basic.sh 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-basic.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/t-mirror-basic.sh	2008/01/17 02:20:48	1.2
+++ LVM2/test/t-mirror-basic.sh	2008/01/26 00:25:45	1.3
@@ -302,6 +302,27 @@
 test_expect_success "(cleanup previous test)" \
   'check_and_cleanup_lvs_'
 
+# ---
+# resync
+# FIXME: using dm-delay to properly check whether the resync really started
+
+test_expect_success "force resync 2-way active mirror" \
+  'prepare_lvs_ &&
+   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
+   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
+   yes | lvchange --resync $vg/$lv1 &&
+   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
+   check_and_cleanup_lvs_'
+
+test_expect_success "force resync 2-way inactive mirror" \
+  'prepare_lvs_ &&
+   lvcreate -l2 -m1 -n $lv1 $vg $(pv_ 1) $(pv_ 2) $(pv_ 3):0-1 &&
+   lvchange -an $vg/$lv1 &&
+   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
+   lvchange --resync $vg/$lv1 &&
+   mirrorlog_is_on_ $vg/$lv1 $(pv_ 3) &&
+   check_and_cleanup_lvs_'
+
 # ---------------------------------------------------------------------
 
 test_done


