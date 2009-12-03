From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 3 Dec 2009 01:48:07 -0000
Subject: LVM2 ./WHATS_NEW test/t-lvcreate-usage.sh
Message-ID: <20091203014807.5443.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-12-03 01:48:07

Modified files:
	.              : WHATS_NEW 
	test           : t-lvcreate-usage.sh 

Log message:
	Add tests to check for readahead value in lvcreate.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1336&r2=1.1337
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/WHATS_NEW	2009/12/01 19:10:23	1.1336
+++ LVM2/WHATS_NEW	2009/12/03 01:48:05	1.1337
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Fix lvcreate --readahead.
   Fix clvmd memory leak in lv_info_by_lvid.
   Do not allow creating mirrors of more than 8 images.
   Use locking_type 3 (compiled in cluster locking) in lvmconf.
--- LVM2/test/t-lvcreate-usage.sh	2009/09/30 16:13:53	1.16
+++ LVM2/test/t-lvcreate-usage.sh	2009/12/03 01:48:07	1.17
@@ -125,3 +125,18 @@
 lvchange -a n $vg/$lv1
 lvremove $vg/$lv1
 lvremove -ff $vg
+
+# readahead default (auto), none, #, auto
+lvcreate -L 32m -n $lv $vg
+check_lv_field_ $vg/$lv lv_read_ahead "auto"
+lvremove -ff $vg
+lvcreate -L 32m -n $lv --readahead none $vg
+check_lv_field_ $vg/$lv lv_read_ahead "0"
+lvremove -ff $vg
+lvcreate -L 32m -n $lv --readahead 8k $vg
+check_lv_field_ $vg/$lv lv_read_ahead "8.00k"
+lvremove -ff $vg
+lvcreate -L 32m -n $lv --readahead auto $vg
+check_lv_field_ $vg/$lv lv_read_ahead "auto"
+lvremove -ff $vg
+


