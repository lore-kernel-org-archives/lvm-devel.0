From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Dec 2011 13:45:43 -0000
Subject: LVM2/test/shell lvcreate-thin.sh
Message-ID: <20111221134543.13953.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-12-21 13:45:43

Modified files:
	test/shell     : lvcreate-thin.sh 

Log message:
	Thin update test case
	
	Use thin-pool instead of thin_pool type.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvcreate-thin.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/shell/lvcreate-thin.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvcreate-thin.sh	2011/12/21 13:45:42	1.2
@@ -54,9 +54,9 @@
 lvcreate -l1 --type thin $vg/pool4
 lvcreate -l1 --type thin --thinpool $vg/pool5
 lvcreate -l1 --type thin --thinpool pool6 $vg
-lvcreate -l1 --type thin_pool $vg/pool7
-lvcreate -l1 --type thin_pool --thinpool $vg/pool8
-lvcreate -l1 --type thin_pool --thinpool pool9 $vg
+lvcreate -l1 --type thin-pool $vg/pool7
+lvcreate -l1 --type thin-pool --thinpool $vg/pool8
+lvcreate -l1 --type thin-pool --thinpool pool9 $vg
 
 lvremove -ff $vg/pool1 $vg/pool2 $vg/pool3 $vg/pool4 $vg/pool5 $vg/pool6 $vg/pool7 $vg/pool8 $vg/pool9
 check vg_field $vg lv_count 0
@@ -65,7 +65,7 @@
 # Create default pool name
 lvcreate -l1 -T $vg
 lvcreate -l1 --type thin $vg
-lvcreate -l1 --type thin_pool $vg
+lvcreate -l1 --type thin-pool $vg
 
 lvremove -ff $vg/lvol0 $vg/lvol1 $vg/lvol2
 check vg_field $vg lv_count 0


