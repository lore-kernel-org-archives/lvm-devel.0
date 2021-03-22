From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 22 Mar 2021 21:53:55 +0000 (GMT)
Subject: main - tests: convert to use mdadm_create
Message-ID: <20210322215355.40BDC3858D29@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a7d7471906501eebb6cf418ab3d0d9326805449f
Commit:        a7d7471906501eebb6cf418ab3d0d9326805449f
Parent:        b1483dcbac0ffbc3e449e6fb8b17988203f45c57
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 22 22:23:53 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 22 22:50:36 2021 +0100

tests: convert to use mdadm_create

Flip usage from prepare_md_dev to mdadm_create.
---
 test/shell/pvcreate-md-fake-hdr.sh | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/test/shell/pvcreate-md-fake-hdr.sh b/test/shell/pvcreate-md-fake-hdr.sh
index 82dd8d4bb..1550bc4c0 100644
--- a/test/shell/pvcreate-md-fake-hdr.sh
+++ b/test/shell/pvcreate-md-fake-hdr.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2018-2021 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -26,16 +26,17 @@ aux extend_filter_LVMTEST "a|/dev/md|"
 aux prepare_devs 4
 
 pvcreate "$dev2"
-aux prepare_md_dev 0 64 2 "$dev1" "$dev2"
-# Incorrectly shows  $dev2 as PV for 'raid0'
-pvs -vvvv
 
+aux mdadm_create --metadata=1.0 --level=0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+
+pvs | tee out
+not grep pv2 out
 
 vgcreate $SHARED $vg "$dev3" "$dev4"
 
 # create 2 disk MD raid1 array
 # by default using metadata format 1.0 with data at the end of device
-aux prepare_md_dev 1 64 2 "$dev1" "$dev2"
+aux mdadm_create --metadata=1.0 --level=1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
 
 mddev=$(< MD_DEV)
 pvdev=$(< MD_DEV_PV)
@@ -51,8 +52,8 @@ vgremove -f $vg
 sleep 3
 aux udev_wait
 # too bad  'dd' wakes up  md array reassembling
-should not mdadm --detail "$mddev"
-should not mdadm --stop "$mddev"
+mdadm --detail "$mddev" || true
+mdadm --stop "$mddev" || true
 sleep 3
 
 # print what  blkid thinks about each PV
@@ -64,12 +65,12 @@ done
 # expect open count for each PV to be 0
 dmsetup info -c
 
-pvs -vvvv  "$dev2" "$dev3" || true
+pvs "$dev2" "$dev3" || true
 
 # still expect open count for each PV to be 0
 dmsetup info -c
 
-pvs -vvvv  "$dev3" "$dev2" || true
+pvs "$dev3" "$dev2" || true
 
 # and again we expect open count for each PV to be 0
 dmsetup info -c
@@ -97,5 +98,5 @@ if mdadm --action=repair "$mddev" ; then
 	sleep 1
 	pvscan -vvvv
 	# should be showing correctly PV3 & PV4
-	pvs -vvvv "$dev3" "$dev4"
+	pvs "$dev3" "$dev4"
 fi


