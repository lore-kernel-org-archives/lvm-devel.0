From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Jun 2011 09:43:28 -0000
Subject: LVM2/test t-lvcreate-usage.sh
Message-ID: <20110628094328.14597.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-28 09:43:28

Modified files:
	test           : t-lvcreate-usage.sh 

Log message:
	More readahead tests.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/test/t-lvcreate-usage.sh	2011/01/05 00:16:20	1.19
+++ LVM2/test/t-lvcreate-usage.sh	2011/06/28 09:43:28	1.20
@@ -131,11 +131,22 @@
 lvremove -ff $vg
 lvcreate -L 32m -n $lv --readahead none $vg
 check lv_field $vg/$lv lv_read_ahead "0"
+check lv_field $vg/$lv lv_kernel_read_ahead "0"
 lvremove -ff $vg
 lvcreate -L 32m -n $lv --readahead 8k $vg
 check lv_field $vg/$lv lv_read_ahead "8.00k"
+check lv_field $vg/$lv lv_kernel_read_ahead "8.00k"
 lvremove -ff $vg
 lvcreate -L 32m -n $lv --readahead auto $vg
 check lv_field $vg/$lv lv_read_ahead "auto"
+check lv_field $vg/$lv lv_kernel_read_ahead "128.00k"
+lvremove -ff $vg
+lvcreate -L 32m -n $lv -i2 --stripesize 16k --readahead auto $vg
+check lv_field $vg/$lv lv_read_ahead "auto"
+check lv_field $vg/$lv lv_kernel_read_ahead "128.00k"
+lvremove -ff $vg
+lvcreate -L 32m -n $lv -i2 --stripesize 128k --readahead auto $vg
+check lv_field $vg/$lv lv_read_ahead "auto"
+check lv_field $vg/$lv lv_kernel_read_ahead "512.00k"
 lvremove -ff $vg
 


