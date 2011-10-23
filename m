From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 23 Oct 2011 14:30:51 -0000
Subject: LVM2/test t-lvcreate-large.sh
Message-ID: <20111023143051.21581.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-10-23 14:30:51

Modified files:
	test           : t-lvcreate-large.sh 

Log message:
	In t-lvcreate-large, do not create a clustered VG. LV activation/suspend does
	not work yet with singlenode clvmd in clustered VGs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-large.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/t-lvcreate-large.sh	2011/09/16 14:32:47	1.2
+++ LVM2/test/t-lvcreate-large.sh	2011/10/23 14:30:51	1.3
@@ -13,9 +13,6 @@
 
 . lib/test
 
-# FIXME: remove it later when locking in virtual origin is fixed
-test -e LOCAL_CLVMD && exit 200
-
 aux prepare_vg 4
 
 lvcreate -s -l 100%FREE -n $lv $vg --virtualsize 1024T
@@ -26,7 +23,7 @@
 aux lvmconf 'devices/filter = [ "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
 
 pvcreate $DM_DEV_DIR/$vg/$lv
-vgcreate $vg1 $DM_DEV_DIR/$vg/$lv
+vgcreate -c n $vg1 $DM_DEV_DIR/$vg/$lv
 
 lvcreate -l 100%FREE -n $lv1 $vg1
 check lv_field $vg1/$lv1 size "1024.00t"
@@ -40,4 +37,4 @@
 check lv_field $vg1/$lv1 size "737.28t"
 lvremove -ff $vg1/$lv1
 
-lvremove -ff $vg/$lv
\ No newline at end of file
+lvremove -ff $vg/$lv


