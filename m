From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Mar 2012 16:04:53 -0000
Subject: LVM2/test/shell lvcreate-thin.sh
Message-ID: <20120304160453.17892.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-04 16:04:52

Modified files:
	test/shell     : lvcreate-thin.sh 

Log message:
	Update thin test for thin_check
	
	Test if thin_check is present in system and disable its use, when its missing.
	
	Add testing for poolmetadatasize.
	
	FIXME: Allocation policy for metadata pool might need some relaxing.
	(For now it needs to put all block on one PV.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvcreate-thin.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/shell/lvcreate-thin.sh	2011/12/21 13:45:42	1.2
+++ LVM2/test/shell/lvcreate-thin.sh	2012/03/04 16:04:52	1.3
@@ -1,6 +1,6 @@
 #!/bin/sh
 
-# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -38,14 +38,15 @@
 #
 aux target_at_least dm-thin-pool 1 0 0 || skip
 
-aux prepare_devs 2 64
+aux prepare_pvs 2 64
 
-pvcreate $dev1 $dev2
+# disable thin_check if not present in system
+which thin_check || aux lvmconf 'global/thin_check_executable = ""'
 
 clustered=
 test -e LOCAL_CLVMD && clustered="--clustered y"
 
-vgcreate $clustered $vg -s 64K $dev1 $dev2
+vgcreate $clustered $vg -s 64K $(cat DEVICES)
 
 # Create named pool only
 lvcreate -l1 -T $vg/pool1
@@ -184,3 +185,32 @@
 lvcreate -L4M -V2G --name lv1 -T $vg/pool1
 # Origin name is not accepted
 not lvcreate -s $vg/lv1 -L4M -V2G --name $vg/lv4
+vgremove -ff $vg
+
+
+# Test --poolmetadatasize
+# allocating large devices for testing
+aux teardown_devs
+aux prepare_pvs 7 16500
+vgcreate $clustered $vg -s 64K $(cat DEVICES)
+
+lvcreate -L4M --chunksize 128 -T $vg/pool
+lvcreate -L4M --chunksize 128 --poolmetadatasize 0 -T $vg/pool1 2>out
+grep "WARNING: Minimum" out
+# FIXME: metadata allocation fails, if PV doesn't have at least 16GB
+# i.e. pool metadata device cannot be multisegment
+lvcreate -L4M --chunksize 128 --poolmetadatasize 17G -T $vg/pool2 2>out
+grep "WARNING: Maximum" out
+check lv_field $vg/pool_tmeta size  "2.00m"
+check lv_field $vg/pool1_tmeta size "2.00m"
+check lv_field $vg/pool2_tmeta size "16.00g"
+lvremove -ff $vg
+
+# check automatic calculation of poolmetadatasize
+lvcreate -L10G --chunksize 128 -T $vg/pool
+lvcreate -L10G --chunksize 256 -T $vg/pool1
+lvcreate -L60G --chunksize 1024 -T $vg/pool2
+check lv_field $vg/pool_tmeta size  "5.00m"
+check lv_field $vg/pool1_tmeta size "2.50m"
+check lv_field $vg/pool2_tmeta size "3.75m"
+vgremove -ff $vg


