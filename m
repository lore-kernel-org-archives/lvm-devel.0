From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 31 Jan 2011 22:05:31 -0000
Subject: LVM2/test t-fsadm.sh t-vgchange-sysinit.sh lib ...
Message-ID: <20110131220531.26848.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-31 22:05:30

Modified files:
	test           : t-fsadm.sh t-vgchange-sysinit.sh 
	test/lib       : utils.sh 

Log message:
	Skip sysinit test for cluster
	Add #bin/bash to utils.sh
	and update fsadm test to current version of aux script

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-fsadm.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgchange-sysinit.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/utils.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/t-fsadm.sh	2011/01/05 00:16:20	1.5
+++ LVM2/test/t-fsadm.sh	2011/01/31 22:05:30	1.6
@@ -38,7 +38,7 @@
 cleanup_mounted_and_teardown()
 {
 	umount $mount_dir || true
-	teardown
+	aux teardown
 }
 
 fscheck_ext3()
@@ -68,7 +68,7 @@
 
 # Test for block sizes != 1024 (rhbz #480022)
 lvcreate -n $lv1 -L20M $vg
-trap 'aux cleanup_mounted_and_teardown' EXIT
+trap 'cleanup_mounted_and_teardown' EXIT
 
 if check_missing ext3; then
 	mkfs.ext3 -b4096 -j $dev_vg_lv
--- LVM2/test/t-vgchange-sysinit.sh	2011/01/31 19:52:41	1.1
+++ LVM2/test/t-vgchange-sysinit.sh	2011/01/31 22:05:30	1.2
@@ -14,6 +14,7 @@
 which mkfs.ext3 || exit 200
 
 aux prepare_pvs 2 8
+test -e LOCAL_CLVMD && exit 200
 
 var_lock="$DM_DEV_DIR/$vg1/$lv1"
 # keep in sync with aux configured lockingdir
--- LVM2/test/lib/utils.sh	2011/01/07 15:04:52	1.3
+++ LVM2/test/lib/utils.sh	2011/01/31 22:05:30	1.4
@@ -1,3 +1,4 @@
+#!/bin/bash
 # Copyright (C) 2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,


