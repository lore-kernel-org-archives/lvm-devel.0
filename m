From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 22 Mar 2021 21:53:54 +0000 (GMT)
Subject: main - tests: more usage of new aux mdadm_create
Message-ID: <20210322215354.1FD7D3854820@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b1483dcbac0ffbc3e449e6fb8b17988203f45c57
Commit:        b1483dcbac0ffbc3e449e6fb8b17988203f45c57
Parent:        76d203517bc78508234706f3ee5ce8ce6d38bee4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 22 21:45:39 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 22 22:49:11 2021 +0100

tests: more usage of new aux mdadm_create

Condense tests and use the new mdadm_create.
---
 test/shell/lvm-on-md.sh             | 262 +++++++-----------------------------
 test/shell/pvcreate-operation-md.sh |  23 +---
 2 files changed, 59 insertions(+), 226 deletions(-)

diff --git a/test/shell/lvm-on-md.sh b/test/shell/lvm-on-md.sh
index 910ebc742..22d5b4ca4 100644
--- a/test/shell/lvm-on-md.sh
+++ b/test/shell/lvm-on-md.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2018-2021 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -22,166 +22,40 @@ HINTS="$RUNDIR/lvm/hints"
 _clear_online_files() {
         # wait till udev is finished
         aux udev_wait
-        rm -f "$PVS_ONLINE_DIR"/*
-        rm -f "$VGS_ONLINE_DIR"/*
+        rm -f "$PVS_ONLINE_DIR"/* "$VGS_ONLINE_DIR"/*
 }
 
 . lib/inittest
 
-test -f /proc/mdstat && grep -q raid1 /proc/mdstat || \
-	modprobe raid1 || skip
-
-mddev="/dev/md33"
-not grep $mddev /proc/mdstat || skip
-
-aux lvmconf 'devices/md_component_detection = 1'
 
 # This stops lvm from taking advantage of hints which
 # will have already excluded md components.
-aux lvmconf 'devices/hints = "none"'
 
 # This stops lvm from asking udev if a dev is an md component.
 # LVM will ask udev if a dev is an md component, but we don't
 # want to rely on that ability in this test.
-aux lvmconf 'devices/obtain_device_list_from_udev = 0'
+aux lvmconf "devices/md_component_detection = 1" \
+	"devices/hints = \"none\"" \
+	"devices/obtain_device_list_from_udev = 0"
 
 aux extend_filter_md "a|/dev/md|"
 
 aux prepare_devs 3
 
-# create 2 disk MD raid1 array
-# by default using metadata format 1.0 with data at the end of device
-
-mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
-aux wait_md_create "$mddev"
-vgcreate $vg "$mddev"
-
-PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
-echo $PVIDMD
-
-lvcreate -n $lv1 -l 2 $vg
-lvcreate -n $lv2 -l 2 -an $vg
-
-lvchange -ay $vg/$lv2
-check lv_field $vg/$lv1 lv_active "active"
-
-# lvm does not show md components as PVs
-pvs "$mddev"
-not pvs "$dev1"
-not pvs "$dev2"
-pvs > out
-not grep "$dev1" out
-not grep "$dev2" out
-
-sleep 1
-
-vgchange -an $vg
-sleep 1
-
-# When the md device is started, lvm will see that and know to
-# scan for md components, so stop the md device to remove this
-# advantage so we will test the fallback detection.
-mdadm --stop "$mddev"
-aux udev_wait
-
-# The md components should still be detected and excluded.
-not pvs "$dev1"
-not pvs "$dev2"
-pvs > out
-not grep "$dev1" out
-not grep "$dev2" out
-
-pvs 2>&1|tee out
-not grep "Not using device" out
-
-# should not activate from the md legs
-not vgchange -ay $vg
-
-# should not show an active lv
-rm out
-lvs -o active $vg |tee out || true
-not grep "active" out
-
-# should not allow updating vg
-not lvcreate -l1 $vg
-
-# should not activate from the md legs
-_clear_online_files
-pvscan --cache -aay "$dev1"
-pvscan --cache -aay "$dev2"
-
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-
-# should not show an active lv
-rm out
-lvs -o active $vg |tee out || true
-not grep "active" out
-
-mdadm --assemble "$mddev" "$dev1" "$dev2"
-aux udev_wait
+for level in 1 0 ; do
 
-not pvs "$dev1"
-not pvs "$dev2"
-pvs > out
-not grep "$dev1" out
-not grep "$dev2" out
-
-lvs $vg
-vgchange -an $vg
-
-# should not activate from the md legs
-_clear_online_files
-pvscan --cache -aay "$dev1"
-pvscan --cache -aay "$dev2"
-
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-
-# should not show an active lv
-rm out
-lvs -o active $vg |tee out || true
-not grep "active" out
-
-vgchange -ay $vg
-
-check lv_field $vg/$lv1 lv_active "active"
-
-vgchange -an $vg
-
-_clear_online_files
-pvscan --cache -aay "$mddev"
-
-ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-ls "$RUNDIR/lvm/vgs_online/$vg"
-
-lvs -o active $vg |tee out || true
-grep "active" out
-
-vgchange -an $vg
-
-aux udev_wait
-
-vgremove -f $vg
-
-mdadm --stop "$mddev"
-aux udev_wait
-aux wipefs_a "$dev1"
-aux wipefs_a "$dev2"
-aux udev_wait
-
-
-# create 2 disk MD raid0 array
+# create 2 disk MD raid1 array
 # by default using metadata format 1.0 with data at the end of device
+#
 # When a raid0 md array is stopped, the components will not look like
 # duplicate PVs as they do with raid1.
 
-mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
-aux wait_md_create "$mddev"
+aux mdadm_create --metadata=1.0 --level=$level --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+mddev=$(< MD_DEV)
+
 vgcreate $vg "$mddev"
 
-PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
-echo $PVIDMD
+PVIDMD=$(get pv_field "$mddev" uuid | tr -d - )
 
 lvcreate -n $lv1 -l 2 $vg
 lvcreate -n $lv2 -l 2 -an $vg
@@ -193,14 +67,11 @@ check lv_field $vg/$lv1 lv_active "active"
 pvs "$mddev"
 not pvs "$dev1"
 not pvs "$dev2"
-pvs > out
+pvs | tee out
 not grep "$dev1" out
 not grep "$dev2" out
 
-sleep 1
-
 vgchange -an $vg
-sleep 1
 
 # When the md device is started, lvm will see that and know to
 # scan for md components, so stop the md device to remove this
@@ -211,7 +82,7 @@ aux udev_wait
 # The md components should still be detected and excluded.
 not pvs "$dev1"
 not pvs "$dev2"
-pvs > out
+pvs | tee out
 not grep "$dev1" out
 not grep "$dev2" out
 
@@ -222,9 +93,7 @@ not grep "Not using device" out
 not vgchange -ay $vg
 
 # should not show an active lv
-rm out
-lvs -o active $vg |tee out || true
-not grep "active" out
+not dmsetup table $vg-$lv1
 
 # should not allow updating vg
 not lvcreate -l1 $vg
@@ -234,21 +103,18 @@ _clear_online_files
 pvscan --cache -aay "$dev1"
 pvscan --cache -aay "$dev2"
 
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
+test ! -f "$RUNDIR/lvm/pvs_online/$PVIDMD"
+test ! -f "$RUNDIR/lvm/vgs_online/$vg"
 
 # should not show an active lv
-rm out
-lvs -o active $vg |tee out || true
-not grep "active" out
+not dmsetup table $vg-$lv1
 
-# start the md dev
 mdadm --assemble "$mddev" "$dev1" "$dev2"
 aux udev_wait
 
 not pvs "$dev1"
 not pvs "$dev2"
-pvs > out
+pvs | tee out
 not grep "$dev1" out
 not grep "$dev2" out
 
@@ -260,13 +126,11 @@ _clear_online_files
 pvscan --cache -aay "$dev1"
 pvscan --cache -aay "$dev2"
 
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
+test ! -f "$RUNDIR/lvm/pvs_online/$PVIDMD"
+test ! -f "$RUNDIR/lvm/vgs_online/$vg"
 
 # should not show an active lv
-rm out
-lvs -o active $vg |tee out || true
-not grep "active" out
+not dmsetup table $vg-$lv1
 
 vgchange -ay $vg
 
@@ -277,37 +141,34 @@ vgchange -an $vg
 _clear_online_files
 pvscan --cache -aay "$mddev"
 
-ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-ls "$RUNDIR/lvm/vgs_online/$vg"
+test -f "$RUNDIR/lvm/pvs_online/$PVIDMD"
+test -f "$RUNDIR/lvm/vgs_online/$vg"
 
-lvs -o active $vg |tee out || true
-grep "active" out
+check active $vg $lv1
 
 vgchange -an $vg
-
-aux udev_wait
-
 vgremove -f $vg
 
-mdadm --stop "$mddev"
-aux udev_wait
+aux cleanup_md_dev
 aux wipefs_a "$dev1"
 aux wipefs_a "$dev2"
 aux udev_wait
 
+done
+
 
 # Repeat tests using the default config settings
 
-aux lvmconf 'devices/hints = "all"'
-aux lvmconf 'devices/obtain_device_list_from_udev = 1'
+aux lvmconf "devices/hints = \"all\"" \
+	"devices/obtain_device_list_from_udev = 1"
 
 # create 2 disk MD raid0 array
 # by default using metadata format 1.0 with data at the end of device
 # When a raid0 md array is stopped, the components will not look like
 # duplicate PVs as they do with raid1.
 
-mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
-aux wait_md_create "$mddev"
+aux mdadm_create --metadata=1.0 --level=0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+mddev=$(< MD_DEV)
 
 # Create an unused PV so that there is@least one PV in the hints
 # when the MD dev is stopped.  If there are no PVs, the hints are
@@ -317,8 +178,7 @@ pvcreate "$dev3"
 
 vgcreate $vg "$mddev"
 
-PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
-echo $PVIDMD
+PVIDMD=$(get pv_field "$mddev" uuid | tr -d - )
 
 lvcreate -n $lv1 -l 2 $vg
 lvcreate -n $lv2 -l 2 -an $vg
@@ -334,15 +194,12 @@ pvs > out
 not grep "$dev1" out
 not grep "$dev2" out
 
-grep "$mddev" $HINTS
-grep "$dev3" $HINTS
-not grep "$dev1" $HINTS
-not grep "$dev2" $HINTS
-
-sleep 1
+grep "$mddev" "$HINTS"
+grep "$dev3" "$HINTS"
+not grep "$dev1" "$HINTS"
+not grep "$dev2" "$HINTS"
 
 vgchange -an $vg
-sleep 1
 
 # When the md device is started, lvm will see that and know to
 # scan for md components, so stop the md device to remove this
@@ -367,7 +224,7 @@ not grep "$mddev" out2
 not grep "$dev1" out2
 not grep "$dev2" out2
 grep "$dev3" out2
-cat $HINTS
+cat "$HINTS"
 
 pvs 2>&1|tee out1
 grep -v WARNING out1 > out2
@@ -376,12 +233,12 @@ not grep "$mddev" out2
 not grep "$dev1" out2
 not grep "$dev2" out2
 grep "$dev3" out2
-cat $HINTS
+cat "$HINTS"
 
 # The md components should still be detected and excluded.
 not pvs "$dev1"
 not pvs "$dev2"
-pvs > out
+pvs | tee out
 not grep "$dev1" out
 not grep "$dev2" out
 grep "$dev3" out
@@ -390,9 +247,7 @@ grep "$dev3" out
 not vgchange -ay $vg
 
 # should not show an active lv
-rm out
-lvs -o active $vg |tee out || true
-not grep "active" out
+not dmsetup table $vg-$lv1
 
 # should not allow updating vg
 not lvcreate -l1 $vg
@@ -402,13 +257,11 @@ _clear_online_files
 pvscan --cache -aay "$dev1"
 pvscan --cache -aay "$dev2"
 
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
+test ! -f "$RUNDIR/lvm/pvs_online/$PVIDMD"
+test ! -f "$RUNDIR/lvm/vgs_online/$vg"
 
 # should not show an active lv
-rm out
-lvs -o active $vg |tee out || true
-not grep "active" out
+not dmsetup table $vg-$lv1
 
 # start the md dev
 mdadm --assemble "$mddev" "$dev1" "$dev2"
@@ -416,7 +269,7 @@ aux udev_wait
 
 not pvs "$dev1"
 not pvs "$dev2"
-pvs > out
+pvs | tee out
 not grep "$dev1" out
 not grep "$dev2" out
 
@@ -428,13 +281,11 @@ _clear_online_files
 pvscan --cache -aay "$dev1"
 pvscan --cache -aay "$dev2"
 
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
+test ! -f "$RUNDIR/lvm/pvs_online/$PVIDMD"
+test ! -f "$RUNDIR/lvm/vgs_online/$vg"
 
 # should not show an active lv
-rm out
-lvs -o active $vg |tee out || true
-not grep "active" out
+not dmsetup table $vg-$lv1
 
 vgchange -ay $vg
 
@@ -445,21 +296,12 @@ vgchange -an $vg
 _clear_online_files
 pvscan --cache -aay "$mddev"
 
-ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-ls "$RUNDIR/lvm/vgs_online/$vg"
+test -f "$RUNDIR/lvm/pvs_online/$PVIDMD"
+test -f "$RUNDIR/lvm/vgs_online/$vg"
 
-lvs -o active $vg |tee out || true
-grep "active" out
+check active $vg $lv1
 
 vgchange -an $vg
-
-aux udev_wait
-
 vgremove -f $vg
 
-mdadm --stop "$mddev"
-aux udev_wait
-aux wipefs_a "$dev1"
-aux wipefs_a "$dev2"
-aux udev_wait
-
+aux cleanup_md_dev
diff --git a/test/shell/pvcreate-operation-md.sh b/test/shell/pvcreate-operation-md.sh
index f4b2a0d92..fa76eb459 100644
--- a/test/shell/pvcreate-operation-md.sh
+++ b/test/shell/pvcreate-operation-md.sh
@@ -18,19 +18,14 @@ SKIP_WITH_LVMPOLLD=1
 # skip this test if mdadm or sfdisk (or others) aren't available
 which sfdisk || skip
 
-test -f /proc/mdstat && grep -q raid0 /proc/mdstat || \
-	modprobe raid0 || skip
-mddev="/dev/md33"
-not grep $mddev /proc/mdstat || skip
-
 aux lvmconf 'devices/md_component_detection = 1'
 aux extend_filter_md "a|/dev/md|"
 
 aux prepare_devs 2
 
 # create 2 disk MD raid0 array (stripe_width=128K)
-mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
-aux wait_md_create "$mddev"
+aux mdadm_create --metadata=1.0 --level=0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+mddev=$(< MD_DEV)
 
 pvdev="$mddev"
 
@@ -111,17 +106,16 @@ EOF
     fi
 fi
 
-mdadm --stop "$mddev"
-aux udev_wait
+aux cleanup_md_dev
 aux wipefs_a "$dev1"
 aux wipefs_a "$dev2"
-aux udev_wait
 
 # Test newer topology-aware alignment detection w/ --dataalignment override
 if aux kernel_at_least 2 6 33 ; then
 
-    mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=1024 --raid-devices=2 "$dev1" "$dev2"
-    aux wait_md_create "$mddev"
+    aux mdadm_create --metadata=1.0 --level 0 --chunk=1024 --raid-devices=2 "$dev1" "$dev2"
+    mddev=$(< MD_DEV)
+
     pvdev="$mddev"
 
     # optimal_io_size=2097152, minimum_io_size=1048576
@@ -138,10 +132,7 @@ if aux kernel_at_least 2 6 33 ; then
 	--config 'devices { md_chunk_alignment=0 }' "$pvdev"
     check pv_field "$pvdev" pe_start "192.00k"
 
-    mdadm --stop "$mddev"
-    aux udev_wait
+    aux cleanup_md_dev
     aux wipefs_a "$dev1"
     aux wipefs_a "$dev2"
-    aux udev_wait
-
 fi


