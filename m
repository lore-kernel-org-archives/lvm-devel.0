From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 19 Sep 2008 16:10:47 -0000
Subject: LVM2/test t-mirror-vgreduce-removemissing.sh
Message-ID: <20080919161047.10115.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-09-19 16:10:46

Modified files:
	test           : t-mirror-vgreduce-removemissing.sh 

Log message:
	Fix vgreduce test,  now requires --force flag. (Jaroslav Stava)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-vgreduce-removemissing.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/t-mirror-vgreduce-removemissing.sh	2008/01/17 18:29:36	1.1
+++ LVM2/test/t-mirror-vgreduce-removemissing.sh	2008/09/19 16:10:46	1.2
@@ -218,7 +218,7 @@
    mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) &&
    mirrorlog_is_on_ $lv1 $(pv_ 3) &&
    fail_pv_ $(pv_ 2) &&
-   vgreduce --removemissing $vg &&
+   vgreduce --removemissing --force $vg &&
    lv_is_linear_ $lv1 &&
    lv_is_on_ $lv1 $(pv_ 1)'
 test_expect_success "cleanup" \
@@ -238,7 +238,7 @@
    mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) &&
    mirrorlog_is_on_ $lv1 $(pv_ 4) &&
    fail_pv_ $(pv_ $index) &&
-   vgreduce --removemissing $vg &&
+   vgreduce --removemissing --force $vg &&
    lvs -a -o+devices $vg &&
    mimages_are_on_ $lv1 $(rest_pvs_ $index 3) &&
    mirrorlog_is_on_ $lv1 $(pv_ 4)
@@ -266,7 +266,7 @@
    mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) &&
    mirrorlog_is_on_ $lv1 $(pv_ 4) &&
    fail_pv_ $(rest_pvs_ $index 3) &&
-   vgreduce --removemissing $vg &&
+   vgreduce --removemissing --force $vg &&
    lvs -a -o+devices $vg &&
    lv_is_linear_ $lv1 &&
    lv_is_on_ $lv1 $(pv_ $index)
@@ -295,7 +295,7 @@
    mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) $(pv_ 4) &&
    mirrorlog_is_on_ $lv1 $(pv_ 5) &&
    fail_pv_ $(pv_ $index) &&
-   vgreduce --removemissing $vg &&
+   vgreduce --removemissing --force $vg &&
    lvs -a -o+devices $vg &&
    mimages_are_on_ $lv1 $(rest_pvs_ $index 4) &&
    mirrorlog_is_on_ $lv1 $(pv_ 5)
@@ -324,7 +324,7 @@
    mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) $(pv_ 4) &&
    mirrorlog_is_on_ $lv1 $(pv_ 5) &&
    fail_pv_ $(rest_pvs_ $index 4) &&
-   vgreduce --removemissing $vg &&
+   vgreduce --removemissing --force $vg &&
    lvs -a -o+devices $vg &&
    (mimages_are_on_ $lv1 $(pv_ $index) || lv_is_on_ $lv1 $(pv_ $index)) &&
    ! mirrorlog_is_on_ $lv1 $(pv_ 5)
@@ -353,7 +353,7 @@
    mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) $(pv_ 4) &&
    mirrorlog_is_on_ $lv1 $(pv_ 5) &&
    fail_pv_ $(pv_ $index) &&
-   vgreduce --removemissing $vg &&
+   vgreduce --removemissing --force $vg &&
    lvs -a -o+devices $vg &&
    mimages_are_on_ $lv1 $(rest_pvs_ $index 4) &&
    mirrorlog_is_on_ $lv1 $(pv_ 5)
@@ -382,7 +382,7 @@
    mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) $(pv_ 4) &&
    mirrorlog_is_on_ $lv1 $(pv_ 5) &&
    fail_pv_ $(rest_pvs_ $index 4) &&
-   vgreduce --removemissing $vg &&
+   vgreduce --removemissing --force $vg &&
    lvs -a -o+devices $vg &&
    (mimages_are_on_ $lv1 $(pv_ $index) || lv_is_on_ $lv1 $(pv_ $index)) &&
    ! mirrorlog_is_on_ $lv1 $(pv_ 5)
@@ -406,7 +406,7 @@
    mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) &&
    mirrorlog_is_on_ $lv1 $(pv_ 5) &&
    fail_pv_ $(pv_ 5) &&
-   vgreduce --removemissing $vg &&
+   vgreduce --removemissing --force $vg &&
    mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) &&
    ! mirrorlog_is_on_ $lv1 $(pv_ 5)'
 test_expect_success "cleanup" \
@@ -420,7 +420,7 @@
    mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) &&
    mirrorlog_is_on_ $lv1 $(pv_ 5) &&
    fail_pv_ $(pv_ 5) &&
-   vgreduce --removemissing $vg &&
+   vgreduce --removemissing --force $vg &&
    mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) &&
    ! mirrorlog_is_on_ $lv1 $(pv_ 5)'
 test_expect_success "cleanup" \
@@ -436,7 +436,7 @@
    mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) &&
    mirrorlog_is_on_ $lv1 $(pv_ 5) &&
    fail_pv_ $(pv_ 1) $(pv_ 2) &&
-   vgreduce --removemissing $vg &&
+   vgreduce --removemissing --force $vg &&
    ! lvs $vg/$lv1'
 test_expect_success "cleanup" \
   "recover_vg_ $(pv_ 1) $(pv_ 2)"
@@ -449,7 +449,7 @@
    mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) $(pv_ 3) &&
    mirrorlog_is_on_ $lv1 $(pv_ 5) &&
    fail_pv_ $(pv_ 1) $(pv_ 2) $(pv_ 3) &&
-   vgreduce --removemissing $vg &&
+   vgreduce --removemissing --force $vg &&
    ! lvs $vg/$lv1'
 test_expect_success "cleanup" \
   "recover_vg_ $(pv_ 1) $(pv_ 2) $(pv_ 3)"
@@ -468,7 +468,7 @@
    mirrorlog_is_on_ $lv1 $(pv_ 5) &&
    mirrorlog_is_on_ $lv2 $(pv_ 5) &&
    fail_pv_ $(pv_ 2) &&
-   vgreduce --removemissing $vg &&
+   vgreduce --removemissing --force $vg &&
    mimages_are_on_ $lv2 $(pv_ 3) $(pv_ 4) &&
    mirrorlog_is_on_ $lv2 $(pv_ 5) &&
    lv_is_linear_ $lv1 &&
@@ -488,7 +488,7 @@
    mirrorlog_is_on_ $lv2 $(pv_ 5) &&
    fail_pv_ $(pv_ 2) &&
    fail_pv_ $(pv_ 4) &&
-   vgreduce --removemissing $vg &&
+   vgreduce --removemissing --force $vg &&
    lv_is_linear_ $lv1 &&
    lv_is_on_ $lv1 $(pv_ 1) &&
    lv_is_linear_ $lv2 &&
@@ -505,7 +505,7 @@
    lvchange -an $vg/$lv1 &&
    mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) &&
    mirrorlog_is_on_ $lv1 $(pv_ 5) &&
-   vgreduce --removemissing $vg &&
+   vgreduce --removemissing --force $vg &&
    mimages_are_on_ $lv1 $(pv_ 1) $(pv_ 2) &&
    mirrorlog_is_on_ $lv1 $(pv_ 5)'
 test_expect_success "cleanup" \


