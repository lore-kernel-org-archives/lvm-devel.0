From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 21 Mar 2008 22:00:37 -0000
Subject: LVM2/test t-vgsplit-operation.sh t-vgsplit-usa ...
Message-ID: <20080321220037.18305.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-03-21 22:00:33

Modified files:
	test           : t-vgsplit-operation.sh t-vgsplit-usage.sh 

Log message:
	Fixup vgsplit tests in preparation for vgsplit changes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/t-vgsplit-operation.sh	2008/03/21 21:14:38	1.13
+++ LVM2/test/t-vgsplit-operation.sh	2008/03/21 22:00:29	1.14
@@ -64,7 +64,7 @@
    fi &&
    lvcreate -l 4 -n $lv1 $vg1 $d1 &&
    vgchange -an $vg1 &&
-   vgsplit --force $vg1 $vg2 $d1 &&
+   vgsplit $vg1 $vg2 $d1 &&
    vg_validate_pvlv_counts_ $vg1 1 0 0 &&
    if [ $i == existing ]; then
       vg_validate_pvlv_counts_ $vg2 3 1 0
@@ -83,7 +83,7 @@
    fi &&
    lvcreate -l 4 -i 2 -n $lv1 $vg1 $d1 $d2 &&
    vgchange -an $vg1 &&
-   vgsplit --force $vg1 $vg2 $d1 $d2 &&
+   vgsplit $vg1 $vg2 $d1 $d2 &&
    if [ $i == existing ]; then
      vg_validate_pvlv_counts_ $vg2 4 1 0
    else
@@ -101,7 +101,7 @@
    lvcreate -l 64 -i 2 -n $lv1 $vg1 $d1 $d2 &&
    lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1 &&
    vgchange -an $vg1 &&
-   vgsplit --force $vg1 $vg2 $d1 $d2 &&
+   vgsplit $vg1 $vg2 $d1 $d2 &&
    if [ $i == existing ]; then
      vg_validate_pvlv_counts_ $vg2 4 1 1
    else
@@ -119,7 +119,7 @@
    fi &&
    lvcreate -l 64 -m1 -n $lv1 $vg1 $d1 $d2 $d3 &&
    vgchange -an $vg1 &&
-   vgsplit --force $vg1 $vg2 $d1 $d2 $d3 &&
+   vgsplit $vg1 $vg2 $d1 $d2 $d3 &&
    if [ $i == existing ]; then
      vg_validate_pvlv_counts_ $vg2 4 4 0
    else
--- LVM2/test/t-vgsplit-usage.sh	2008/03/04 19:48:32	1.1
+++ LVM2/test/t-vgsplit-usage.sh	2008/03/21 22:00:29	1.2
@@ -172,7 +172,6 @@
    vgchange -an $vg1 &&
    vgsplit $vg1 $vg2 $d3 2>err;
    status=$?; echo status=$?; test $status = 5 &&
-   grep "^  Physical volume $d3 not in volume group $vg1" err &&
    vgremove -f $vg2 &&
    vgremove -f $vg1'
 


