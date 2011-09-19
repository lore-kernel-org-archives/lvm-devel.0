From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Sep 2011 13:52:22 -0000
Subject: LVM2/test t-fsadm.sh
Message-ID: <20110919135222.31358.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-19 13:52:22

Modified files:
	test           : t-fsadm.sh 

Log message:
	Enable  t-fsadm test
	
	Now all commands are executed from preffered directory.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-fsadm.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/t-fsadm.sh	2011/01/31 22:05:30	1.6
+++ LVM2/test/t-fsadm.sh	2011/09/19 13:52:22	1.7
@@ -1,5 +1,5 @@
 #!/bin/bash
-# Copyright (C) 2008-2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008-2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -10,7 +10,6 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description='Exercise fsadm filesystem resize'
-exit 200
 
 . lib/test
 
@@ -32,6 +31,8 @@
 vg_lv="$vg/$lv1"
 dev_vg_lv="$DM_DEV_DIR/$vg_lv"
 mount_dir="$TESTDIR/mnt"
+# for recursive call
+export LVM_BINARY=$(which lvm)
 
 test ! -d $mount_dir && mkdir $mount_dir
 
@@ -75,13 +76,13 @@
 
 	fsadm --lvresize resize $vg_lv 30M
 	# Fails - not enough space for 4M fs
-	not fsadm --lvresize resize $dev_vg_lv 4M
+	not fsadm -y --lvresize resize $dev_vg_lv 4M
 	lvresize -L+10M -r $vg_lv
 	lvreduce -L10M -r $vg_lv
 
 	fscheck_ext3
 	mount $dev_vg_lv $mount_dir
-	not fsadm --lvresize resize $vg_lv 9M
+	not fsadm -y --lvresize resize $vg_lv 4M
 	lvresize -L+20M -r -n $vg_lv
 	umount $mount_dir
 	fscheck_ext3
@@ -121,3 +122,5 @@
 
 	lvresize -f -L20M $vg_lv
 fi
+
+vgremove -ff $vg


