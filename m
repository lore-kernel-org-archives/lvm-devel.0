From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Jul 2011 12:12:41 -0000
Subject: LVM2/test t-lvcreate-repair.sh
Message-ID: <20110718121241.11541.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-07-18 12:12:41

Modified files:
	test           : t-lvcreate-repair.sh 

Log message:
	Better version of failing 'should' test
	
	where the naming is left completely on lvm.
	(Commited code has been different version of test).
	So here it should be able to figure out new free name and create a new LV.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-repair.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/t-lvcreate-repair.sh	2011/07/18 12:04:42	1.1
+++ LVM2/test/t-lvcreate-repair.sh	2011/07/18 12:12:41	1.2
@@ -71,7 +71,7 @@
 dd if="$dev1" of=backup_i bs=256K count=1
 dd if="$dev2" of=backup_j bs=256K count=1
 
-lvcreate -l1 -n $lv1 $vg $dev1
+lvcreate -l1 $vg $dev1
 
 dd if=backup_j of="$dev2" bs=256K count=1
 dd if=backup_i of="$dev1" bs=256K count=1
@@ -94,4 +94,4 @@
 # device-mapper: create ioctl failed: Device or resource busy
 # Failed to activate new LV.
 
-should lvcreate -l1 -n $lv1 $vg $dev1
+should lvcreate -l1 $vg $dev1


