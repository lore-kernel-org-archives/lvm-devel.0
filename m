From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:48:40 +0000 (GMT)
Subject: dev-next - tests: use mdadm support
Message-ID: <20210331214840.0C40F3857C6F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=76d203517bc78508234706f3ee5ce8ce6d38bee4
Commit:        76d203517bc78508234706f3ee5ce8ce6d38bee4
Parent:        ada99f939fe24e23994244fdbe960014b355fd44
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 22 18:55:07 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 22 22:46:21 2021 +0100

tests: use mdadm support

Use for testing new mdadm_create  aux wrapper.
Place functionality into a 2 pass loop - one for 'auto' other for 'start'.
Share same tests between raid level 0 and level 1 version of raid.
---
 test/shell/duplicate-pvs-md0.sh | 381 +++++++++------------------
 test/shell/duplicate-pvs-md1.sh | 570 +---------------------------------------
 2 files changed, 129 insertions(+), 822 deletions(-)

diff --git a/test/shell/duplicate-pvs-md0.sh b/test/shell/duplicate-pvs-md0.sh
index 6ff9ba245..82a179915 100644
--- a/test/shell/duplicate-pvs-md0.sh
+++ b/test/shell/duplicate-pvs-md0.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2012-2021 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -22,28 +22,14 @@ HINTS="$RUNDIR/lvm/hints"
 _clear_online_files() {
         # wait till udev is finished
         aux udev_wait
-        rm -f "$PVS_ONLINE_DIR"/*
-        rm -f "$VGS_ONLINE_DIR"/*
+        rm -f "$PVS_ONLINE_DIR"/* "$VGS_ONLINE_DIR"/*
 }
 
 . lib/inittest
 
-test -f /proc/mdstat && grep -q raid0 /proc/mdstat || \
-        modprobe raid0 || skip
+MD_LEVEL=${MD_LEVEL-0}
 
-mddev="/dev/md33"
-not grep $mddev /proc/mdstat || skip
-
-aux lvmconf 'devices/md_component_detection = 1'
-
-# This stops lvm from asking udev if a dev is an md component.
-# LVM will ask udev if a dev is an md component, but we don't
-# want to rely on that ability in this test.
-aux lvmconf 'devices/obtain_device_list_from_udev = 0'
-
-aux extend_filter_md "a|/dev/md|"
-
-aux prepare_devs 4
+aux prepare_devs 4 10
 
 # Create an unused PV so that there is at least one PV in the hints
 # when the MD dev is stopped.  If there are no PVs, the hints are
@@ -55,92 +41,28 @@ pvcreate "$dev3"
 # PV on md raid1|raid0, md_component_checks auto|start, mddev start|stopped,
 # one raid dev disabled when mddev is stopped.
 
+# LVM will ask udev if a dev is an md component, but we don't
+# want to rely on that ability in this test so stops lvm from
+# asking udev if a dev is an md component.
+aux lvmconf "devices/obtain_device_list_from_udev = 0" \
+	    "devices/md_component_detection = 1" \
+	    "devices/md_component_checks = \"auto\""
 
-##########################################
-# PV on an md raid0 device, auto+started
-# md_component_checks: auto (not start)
-# mddev: started            (not stopped)
-#
-
-aux lvmconf 'devices/md_component_checks = "auto"'
-
-mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
-aux wait_md_create "$mddev"
-pvcreate "$mddev"
-PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
-echo $PVIDMD
-vgcreate $vg "$mddev"
-lvcreate -n $lv1 -l 2 -an $vg
-
-# pvs shows only the md dev as PV
-pvs "$mddev"
-not pvs "$dev1"
-not pvs "$dev2"
-pvs > out
-grep $mddev out
-not grep "$dev1" out
-not grep "$dev2" out
-grep "$mddev" $HINTS
-not grep "$dev1" $HINTS
-not grep "$dev2" $HINTS
-
-# normal activation works
-lvchange -ay $vg/$lv1
-lvs -o active $vg |tee out || true
-grep "active" out
-vgchange -an $vg
-
-# pvscan activation all works
-_clear_online_files
-pvscan --cache -aay
-ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-ls "$RUNDIR/lvm/vgs_online/$vg"
-lvs -o active $vg |tee out || true
-grep "active" out
-vgchange -an $vg
-
-# pvscan activation from mddev works
-_clear_online_files
-pvscan --cache -aay "$mddev"
-ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-ls "$RUNDIR/lvm/vgs_online/$vg"
-lvs -o active $vg |tee out || true
-grep "active" out
-vgchange -an $vg
-
-# pvscan activation from md components does nothing
-_clear_online_files
-pvscan --cache -aay "$dev1"
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-pvscan --cache -aay "$dev2"
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-lvs -o active $vg |tee out || true
-not grep "active" out
-
-vgchange -an $vg
-vgremove -f $vg
-mdadm --stop "$mddev"
-aux udev_wait
-aux wipefs_a "$dev1"
-aux wipefs_a "$dev2"
-aux udev_wait
+aux extend_filter_md "a|/dev/md|"
 
+# Run in 2 passes  - 1st. with "auto"    2nd. with "start" component checks
+for pass in "auto" "start" ; do
 
 ##########################################
-# PV on an md raid0 device, start+started
-# md_component_checks: start (not auto)
-# mddev: started             (not stopped)
+# PV on an md raidX device
+# md_component_checks: auto|start  (not start)
+# mddev: started                   (not stopped)
 #
+aux mdadm_create --metadata=1.0 --level="$MD_LEVEL" --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+mddev=$(< MD_DEV)
 
-aux lvmconf 'devices/md_component_checks = "start"'
-
-mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
-aux wait_md_create "$mddev"
 pvcreate "$mddev"
-PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
-echo $PVIDMD
+PVIDMD=$(get pv_field "$mddev" uuid | tr -d - )
 vgcreate $vg "$mddev"
 lvcreate -n $lv1 -l 2 -an $vg
 
@@ -148,71 +70,68 @@ lvcreate -n $lv1 -l 2 -an $vg
 pvs "$mddev"
 not pvs "$dev1"
 not pvs "$dev2"
-pvs > out
-grep $mddev out
+pvs | tee out
+grep "$mddev" out
 not grep "$dev1" out
 not grep "$dev2" out
 # N.B. in this case hints are disabled for duplicate pvs seen by scan
 # it would be preferrable if this didn't happen as in auto mode, but it's ok.
-# grep "$mddev" $HINTS
-not grep "$dev1" $HINTS
-not grep "$dev2" $HINTS
+test "$pass" = "auto" && grep "$mddev" "$HINTS"
+not grep "$dev1" "$HINTS"
+not grep "$dev2" "$HINTS"
 
 # normal activation works
 lvchange -ay $vg/$lv1
-lvs -o active $vg |tee out || true
-grep "active" out
+check active $vg $lv1
 vgchange -an $vg
 
 # pvscan activation all works
 _clear_online_files
 pvscan --cache -aay
-ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-ls "$RUNDIR/lvm/vgs_online/$vg"
-lvs -o active $vg |tee out || true
-grep "active" out
+test -e "$RUNDIR/lvm/pvs_online/$PVIDMD"
+test -e "$RUNDIR/lvm/vgs_online/$vg"
+check active $vg $lv1
 vgchange -an $vg
 
 # pvscan activation from mddev works
 _clear_online_files
 pvscan --cache -aay "$mddev"
-ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-ls "$RUNDIR/lvm/vgs_online/$vg"
-lvs -o active $vg |tee out || true
-grep "active" out
+test -f "$RUNDIR/lvm/pvs_online/$PVIDMD"
+test -f "$RUNDIR/lvm/vgs_online/$vg"
+check active $vg $lv1
 vgchange -an $vg
 
-# N.B. with raid0 the component because the PV/size difference
-# triggers and md component check, whereas with raid1 it doesn't.
+# pvscan activation from md components does nothing
 _clear_online_files
 pvscan --cache -aay "$dev1"
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-lvs -o active $vg |tee out || true
-not grep "active" out
+test ! -f "$RUNDIR/lvm/pvs_online/$PVIDMD"
+test ! -f "$RUNDIR/lvm/vgs_online/$vg"
+
+if [ "$pass" = "auto" ] ; then
+	pvscan --cache -aay "$dev2"
+	test ! -f "$RUNDIR/lvm/pvs_online/$PVIDMD"
+	test ! -f "$RUNDIR/lvm/vgs_online/$vg"
+fi
+# N.B. with raid0 the component because the PV/size difference
+# triggers and md component check, whereas with raid1 it doesn't.
+check inactive $vg $lv1
 
 vgchange -an $vg
 vgremove -f $vg
-mdadm --stop "$mddev"
-aux udev_wait
-aux wipefs_a "$dev1"
-aux wipefs_a "$dev2"
-aux udev_wait
+aux cleanup_md_dev
 
 
 ##########################################
-# PV on an md raid0 device, auto+stopped
-# md_component_checks: auto (not start)
-# mddev: stopped            (not started)
+# PV on an md raidX device
+# md_component_checks: auto|start
+# mddev: stopped       (not started)
 #
 
-aux lvmconf 'devices/md_component_checks = "auto"'
+aux mdadm_create --metadata=1.0 --level="$MD_LEVEL" --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+mddev=$(< MD_DEV)
 
-mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
-aux wait_md_create "$mddev"
 pvcreate "$mddev"
-PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
-echo $PVIDMD
+PVIDMD=$(get pv_field "$mddev" uuid | tr -d - )
 vgcreate $vg "$mddev"
 lvcreate -n $lv1 -l 2 -an $vg
 
@@ -223,14 +142,16 @@ cat /proc/mdstat
 not pvs "$mddev"
 not pvs "$dev1"
 not pvs "$dev2"
-pvs > out
-not grep $mddev out
+pvs | tee out
+not grep "$mddev" out
+# N.B. it would be preferrable if dev1 did not appear in hints but it's ok
+# not grep "$dev1" $HINTS
 not grep "$dev1" out
 not grep "$dev2" out
 pvscan --cache
-not grep "$mddev" $HINTS
-not grep "$dev1" $HINTS
-not grep "$dev2" $HINTS
+not grep "$mddev" "$HINTS"
+not grep "$dev1" "$HINTS"
+not grep "$dev2" "$HINTS"
 
 # the vg is not seen, normal activation does nothing
 not lvchange -ay $vg/$lv1
@@ -239,176 +160,120 @@ not lvs $vg
 # pvscan activation all does nothing
 _clear_online_files
 pvscan --cache -aay
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
+test ! -f "$RUNDIR/lvm/pvs_online/$PVIDMD"
+test ! -f "$RUNDIR/lvm/vgs_online/$vg"
 
 # pvscan activation from md components does nothing
 _clear_online_files
 pvscan --cache -aay "$dev1"
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
+test ! -f "$RUNDIR/lvm/pvs_online/$PVIDMD"
+test ! -f "$RUNDIR/lvm/vgs_online/$vg"
 pvscan --cache -aay "$dev2"
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-
-aux wipefs_a "$dev1"
-aux wipefs_a "$dev2"
-aux udev_wait
-
-##########################################
-# PV on an md raid0 device, start+stopped
-# md_component_checks: start (not auto)
-# mddev: stopped             (not started)
-#
-
-aux lvmconf 'devices/md_component_checks = "start"'
-
-mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
-aux wait_md_create "$mddev"
-pvcreate "$mddev"
-PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
-echo $PVIDMD
-vgcreate $vg "$mddev"
-lvcreate -n $lv1 -l 2 -an $vg
-
-mdadm --stop "$mddev"
-cat /proc/mdstat
-
-# pvs does not show the PV
-not pvs "$mddev"
-not pvs "$dev1"
-not pvs "$dev2"
-pvs > out
-not grep $mddev out
-not grep "$dev1" out
-not grep "$dev2" out
-pvscan --cache
-not grep "$mddev" $HINTS
-# N.B. it would be preferrable if dev1 did not appear in hints but it's ok
-# not grep "$dev1" $HINTS
-not grep "$dev2" $HINTS
-
-# the vg is not seen, normal activation does nothing
-not lvchange -ay $vg/$lv1
-not lvs $vg
-
-# pvscan activation all does nothing
-_clear_online_files
-pvscan --cache -aay
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
+test ! -f "$RUNDIR/lvm/pvs_online/$PVIDMD"
+test ! -f "$RUNDIR/lvm/vgs_online/$vg"
 
-# pvscan activation from md components does nothing
-_clear_online_files
-pvscan --cache -aay "$dev1" || true
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-pvscan --cache -aay "$dev2" || true
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-lvs -o active $vg |tee out || true
-not grep "active" out
+#lvs -o active $vg |tee out || true
+#not grep "active" out
 
 aux wipefs_a "$dev1"
 aux wipefs_a "$dev2"
 aux udev_wait
 
-
 ##########################################
-# PV on an md raid0 device, start+stopped
-# md_component_checks: start (not auto)
-# mddev: stopped             (not started)
+# PV on an md raidX device
+# md_component_checks: auto|start
+# mddev: stopped       (not started)
 # only one raid dev online
 #
 
-aux lvmconf 'devices/md_component_checks = "start"'
+aux mdadm_create --metadata=1.0 --level="$MD_LEVEL" --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+mddev=$(< MD_DEV)
 
-mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
-aux wait_md_create "$mddev"
 pvcreate "$mddev"
-PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
-echo $PVIDMD
+PVIDMD=$(get pv_field "$mddev" uuid | tr -d - )
 vgcreate $vg "$mddev"
 lvcreate -n $lv1 -l 2 -an $vg
 
 mdadm --stop "$mddev"
 cat /proc/mdstat
 
-# disable one dev of the md device
+# disable one leg
 aux disable_dev "$dev2"
 
 # pvs does not show the PV
 not pvs "$mddev"
 not pvs "$dev1"
 not pvs "$dev2"
-pvs > out
-not grep $mddev out
+pvs | tee out
+not grep "$mddev" out
 not grep "$dev1" out
 not grep "$dev2" out
 pvscan --cache
-not grep "$mddev" $HINTS
+not grep "$mddev" "$HINTS"
 # N.B. would be preferrable for this md component to not be in hints
 # grep "$dev1" $HINTS
-not grep "$dev2" $HINTS
+not grep "$dev1" "$HINTS"
+not grep "$dev2" "$HINTS"
 
+# the vg is not seen, normal activation does nothing
 not lvchange -ay $vg/$lv1
 not lvs $vg
 
+# pvscan activation all does nothing
 _clear_online_files
 pvscan --cache -aay
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
+test ! -f "$RUNDIR/lvm/pvs_online/$PVIDMD"
+test ! -f "$RUNDIR/lvm/vgs_online/$vg"
 
+# pvscan activation from md components does nothing
 _clear_online_files
 pvscan --cache -aay "$dev1"
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
+test ! -f "$RUNDIR/lvm/pvs_online/$PVIDMD"
+test ! -f "$RUNDIR/lvm/vgs_online/$vg"
+pvscan --cache -aay "$dev2"
+test ! -f "$RUNDIR/lvm/pvs_online/$PVIDMD"
+test ! -f "$RUNDIR/lvm/vgs_online/$vg"
 
 aux enable_dev "$dev2"
-aux aux udev_wait
-cat /proc/mdstat
-# for some reason enabling dev2 starts an odd md dev
-mdadm --stop $(lsblk -al -o NAME --noheadings "$dev2" | grep '^md') || true
-cat /proc/mdstat
-aux wipefs_a "$dev1" || true
-aux wipefs_a "$dev2" || true
+aux cleanup_md_dev
+
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
 aux udev_wait
 
+if [ "$MD_LEVEL" = "1" ] ; then
 ##########################################
-# PV on an md raid0 device, auto+stopped
-# md_component_checks: auto (not start)
-# mddev: stopped            (not started)
-# only one raid dev online
+# PV on an md raid1 device, auto+stopped
+# md_component_checks: auto|start
+# mddev: stopped       (not started)
+# three raid images
 #
+aux mdadm_create --metadata=1.0 --level="$MD_LEVEL" --chunk=64 --raid-devices=3 "$dev1" "$dev2" "$dev4"
+mddev=$(< MD_DEV)
 
-aux lvmconf 'devices/md_component_checks = "auto"'
-
-mdadm --create --metadata=1.0 "$mddev" --level 0 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
-aux wait_md_create "$mddev"
 pvcreate "$mddev"
-PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
-echo $PVIDMD
+PVIDMD=$(get pv_field "$mddev" uuid | tr -d - )
 vgcreate $vg "$mddev"
 lvcreate -n $lv1 -l 2 -an $vg
 
 mdadm --stop "$mddev"
 cat /proc/mdstat
 
-# disable one leg
-aux disable_dev "$dev2"
-
 # pvs does not show the PV
 not pvs "$mddev"
 not pvs "$dev1"
 not pvs "$dev2"
-pvs > out
-not grep $mddev out
+not pvs "$dev4"
+pvs | tee out
+not grep "$mddev" out
 not grep "$dev1" out
 not grep "$dev2" out
+not grep "$dev4" out
 pvscan --cache
-not grep "$mddev" $HINTS
-not grep "$dev1" $HINTS
-not grep "$dev2" $HINTS
+not grep "$mddev" "$HINTS"
+not grep "$dev1" "$HINTS"
+not grep "$dev2" "$HINTS"
+not grep "$dev4" "$HINTS"
 
 # the vg is not seen, normal activation does nothing
 not lvchange -ay $vg/$lv1
@@ -417,24 +282,28 @@ not lvs $vg
 # pvscan activation all does nothing
 _clear_online_files
 pvscan --cache -aay
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
+test ! -f "$RUNDIR/lvm/pvs_online/$PVIDMD"
+test ! -f "$RUNDIR/lvm/vgs_online/$vg"
 
 # pvscan activation from md components does nothing
 _clear_online_files
 pvscan --cache -aay "$dev1"
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
+test ! -f "$RUNDIR/lvm/pvs_online/$PVIDMD"
+test ! -f "$RUNDIR/lvm/vgs_online/$vg"
 pvscan --cache -aay "$dev2"
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
+test ! -f "$RUNDIR/lvm/pvs_online/$PVIDMD"
+test ! -f "$RUNDIR/lvm/vgs_online/$vg"
+pvscan --cache -aay "$dev4"
+test ! -f "$RUNDIR/lvm/pvs_online/$PVIDMD"
+test ! -f "$RUNDIR/lvm/vgs_online/$vg"
 
-aux enable_dev "$dev2"
-aux aux udev_wait
-cat /proc/mdstat
-# for some reason enabling dev2 starts an odd md dev
-mdadm --stop $(lsblk -al -o NAME --noheadings "$dev2" | grep '^md') || true
-cat /proc/mdstat
-aux wipefs_a "$dev1" || true
-aux wipefs_a "$dev2" || true
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
+aux wipefs_a "$dev4"
 aux udev_wait
+fi   # MD_LEVEL == 1
+
+# next loop with 'start'
+test "$pass" != "auto" || aux lvmconf "devices/md_component_checks = \"start\""
+
+done
diff --git a/test/shell/duplicate-pvs-md1.sh b/test/shell/duplicate-pvs-md1.sh
index d0016f166..e896c106a 100644
--- a/test/shell/duplicate-pvs-md1.sh
+++ b/test/shell/duplicate-pvs-md1.sh
@@ -1,6 +1,6 @@
 #!/usr/bin/env bash
 
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2012-2021 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -15,569 +15,7 @@
 # . dm wrapper around a PV
 # . a single PV/VG cloned plus a dm wrapper (two separate dups of a PV)
 
-SKIP_WITH_LVMPOLLD=1
-SKIP_WITH_LVMLOCKD=1
-
-RUNDIR="/run"
-test -d "$RUNDIR" || RUNDIR="/var/run"
-PVS_ONLINE_DIR="$RUNDIR/lvm/pvs_online"
-VGS_ONLINE_DIR="$RUNDIR/lvm/vgs_online"
-HINTS="$RUNDIR/lvm/hints"
-
-_clear_online_files() {
-        # wait till udev is finished
-        aux udev_wait
-        rm -f "$PVS_ONLINE_DIR"/*
-        rm -f "$VGS_ONLINE_DIR"/*
-}
-
-. lib/inittest
-
-test -f /proc/mdstat && grep -q raid1 /proc/mdstat || \
-        modprobe raid1 || skip
-
-mddev="/dev/md33"
-not grep $mddev /proc/mdstat || skip
-
-aux lvmconf 'devices/md_component_detection = 1'
-
-# This stops lvm from asking udev if a dev is an md component.
-# LVM will ask udev if a dev is an md component, but we don't
-# want to rely on that ability in this test.
-aux lvmconf 'devices/obtain_device_list_from_udev = 0'
-
-aux extend_filter_md "a|/dev/md|"
-
-aux prepare_devs 4
-
-# Create an unused PV so that there is at least one PV in the hints
-# when the MD dev is stopped.  If there are no PVs, the hints are
-# empty, and the code falls back to scanning all, and we do not end
-# up testing the code with hints actively used.
-pvcreate "$dev3"
-
-## Test variations:
-# PV on md raid1|raid0, md_component_checks auto|start, mddev start|stopped,
-# one leg disabled when mddev is stopped.
-
-
-##########################################
-# PV on an md raid1 device, auto+started
-# md_component_checks: auto (not start)
-# mddev: started            (not stopped)
-#
-
-aux lvmconf 'devices/md_component_checks = "auto"'
-
-mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
-aux wait_md_create "$mddev"
-pvcreate "$mddev"
-PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
-echo $PVIDMD
-vgcreate $vg "$mddev"
-lvcreate -n $lv1 -l 2 -an $vg
-
-# pvs shows only the md dev as PV
-pvs "$mddev"
-not pvs "$dev1"
-not pvs "$dev2"
-pvs > out
-grep $mddev out
-not grep "$dev1" out
-not grep "$dev2" out
-grep "$mddev" $HINTS
-not grep "$dev1" $HINTS
-not grep "$dev2" $HINTS
-
-# normal activation works
-lvchange -ay $vg/$lv1
-lvs -o active $vg |tee out || true
-grep "active" out
-vgchange -an $vg
-
-# pvscan activation all works
-_clear_online_files
-pvscan --cache -aay
-ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-ls "$RUNDIR/lvm/vgs_online/$vg"
-lvs -o active $vg |tee out || true
-grep "active" out
-vgchange -an $vg
-
-# pvscan activation from mddev works
-_clear_online_files
-pvscan --cache -aay "$mddev"
-ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-ls "$RUNDIR/lvm/vgs_online/$vg"
-lvs -o active $vg |tee out || true
-grep "active" out
-vgchange -an $vg
-
-# pvscan activation from md components does nothing
-_clear_online_files
-pvscan --cache -aay "$dev1"
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-pvscan --cache -aay "$dev2"
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-lvs -o active $vg |tee out || true
-not grep "active" out
-
-vgchange -an $vg
-vgremove -f $vg
-mdadm --stop "$mddev"
-aux udev_wait
-aux wipefs_a "$dev1"
-aux wipefs_a "$dev2"
-aux udev_wait
-
-
-
-##########################################
-# PV on an md raid1 device, start+started
-# md_component_checks: start (not auto)
-# mddev: started             (not stopped)
-#
-
-aux lvmconf 'devices/md_component_checks = "start"'
-
-mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
-aux wait_md_create "$mddev"
-pvcreate "$mddev"
-PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
-echo $PVIDMD
-vgcreate $vg "$mddev"
-lvcreate -n $lv1 -l 2 -an $vg
-
-# pvs shows only the md dev as PV
-pvs "$mddev"
-not pvs "$dev1"
-not pvs "$dev2"
-pvs > out
-grep $mddev out
-not grep "$dev1" out
-not grep "$dev2" out
-# N.B. in this case hints are disabled for duplicate pvs seen by scan
-# it would be preferrable if this didn't happen as in auto mode, but it's ok.
-# grep "$mddev" $HINTS
-not grep "$dev1" $HINTS
-not grep "$dev2" $HINTS
-
-# normal activation works
-lvchange -ay $vg/$lv1
-lvs -o active $vg |tee out || true
-grep "active" out
-vgchange -an $vg
-
-# pvscan activation all works
-_clear_online_files
-pvscan --cache -aay
-ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-ls "$RUNDIR/lvm/vgs_online/$vg"
-lvs -o active $vg |tee out || true
-grep "active" out
-vgchange -an $vg
-
-# pvscan activation from mddev works
-_clear_online_files
-pvscan --cache -aay "$mddev"
-ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-ls "$RUNDIR/lvm/vgs_online/$vg"
-lvs -o active $vg |tee out || true
-grep "active" out
-vgchange -an $vg
-
-# pvscan activation from component should do nothing
-_clear_online_files
-pvscan --cache -aay "$dev1"
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-lvs -o active $vg |tee out || true
-not grep "active" out
-
-# pvscan activation from mddev first, then try from component which fails
-_clear_online_files
-pvscan --cache -aay "$mddev"
-ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-ls "$RUNDIR/lvm/vgs_online/$vg"
-lvs -o active $vg |tee out || true
-grep "active" out
-rm "$RUNDIR/lvm/pvs_online/$PVIDMD"
-pvscan --cache -aay "$dev1"
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-
-
-vgchange -an $vg
-vgremove -f $vg
-mdadm --stop "$mddev"
-aux udev_wait
-aux wipefs_a "$dev1"
-aux wipefs_a "$dev2"
-aux udev_wait
-
-
-##########################################
-# PV on an md raid1 device, auto+stopped
-# md_component_checks: auto (not start)
-# mddev: stopped            (not started)
-#
-
-aux lvmconf 'devices/md_component_checks = "auto"'
-
-mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
-aux wait_md_create "$mddev"
-pvcreate "$mddev"
-PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
-echo $PVIDMD
-vgcreate $vg "$mddev"
-lvcreate -n $lv1 -l 2 -an $vg
-
-mdadm --stop "$mddev"
-cat /proc/mdstat
-
-# pvs does not show the PV
-not pvs "$mddev"
-not pvs "$dev1"
-not pvs "$dev2"
-pvs > out
-not grep $mddev out
-not grep "$dev1" out
-not grep "$dev2" out
-pvscan --cache
-not grep "$mddev" $HINTS
-not grep "$dev1" $HINTS
-not grep "$dev2" $HINTS
-
-# the vg is not seen, normal activation does nothing
-not lvchange -ay $vg/$lv1
-not lvs $vg
-
-# pvscan activation all does nothing
-_clear_online_files
-pvscan --cache -aay
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-
-# pvscan activation from md components does nothing
-_clear_online_files
-pvscan --cache -aay "$dev1"
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-pvscan --cache -aay "$dev2"
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-
-aux wipefs_a "$dev1"
-aux wipefs_a "$dev2"
-aux udev_wait
-
-
-##########################################
-# PV on an md raid1 device, start+stopped
-# md_component_checks: start (not auto)
-# mddev: stopped             (not started)
-#
-
-aux lvmconf 'devices/md_component_checks = "start"'
-
-mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
-aux wait_md_create "$mddev"
-pvcreate "$mddev"
-PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
-echo $PVIDMD
-vgcreate $vg "$mddev"
-lvcreate -n $lv1 -l 2 -an $vg
-
-mdadm --stop "$mddev"
-cat /proc/mdstat
-
-# pvs does not show the PV
-not pvs "$mddev"
-not pvs "$dev1"
-not pvs "$dev2"
-pvs > out
-not grep $mddev out
-not grep "$dev1" out
-not grep "$dev2" out
-pvscan --cache
-not grep "$mddev" $HINTS
-not grep "$dev1" $HINTS
-not grep "$dev2" $HINTS
-
-# the vg is not seen, normal activation does nothing
-rm $HINTS
-not lvs $vg
-not lvchange -ay $vg/$lv1
-
-_clear_online_files
-pvscan --cache -aay
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-
-_clear_online_files
-pvscan --cache -aay "$dev1"
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-
-aux wipefs_a "$dev1" || true
-aux wipefs_a "$dev2" || true
-
-
-##########################################
-# PV on an md raid1 device, start+stopped
-# md_component_checks: start (not auto)
-# mddev: stopped             (not started)
-# only one raid image online
-#
-
-aux lvmconf 'devices/md_component_checks = "start"'
-
-mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
-aux wait_md_create "$mddev"
-pvcreate "$mddev"
-PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
-echo $PVIDMD
-vgcreate $vg "$mddev"
-lvcreate -n $lv1 -l 2 -an $vg
-
-mdadm --stop "$mddev"
-cat /proc/mdstat
-
-# disable one leg of the md device, with raid1 this means duplicates
-# will not be seen for the legs.  duplicate handling can trigger
-# md component detection, so no duplicates means md components may
-# not be detected as easily.
-aux disable_dev "$dev2"
-
-# pvs does not show the PV
-rm $HINTS
-not pvs "$mddev"
-rm $HINTS
-not pvs "$dev1"
-rm $HINTS
-not pvs "$dev2"
-rm $HINTS
-pvs > out
-not grep $mddev out
-not grep "$dev1" out
-not grep "$dev2" out
-rm $HINTS
-pvscan --cache
-not grep "$mddev" $HINTS
-not grep "$dev1" $HINTS
-not grep "$dev2" $HINTS
-
-not lvs $vg
-
-_clear_online_files
-pvscan --cache -aay
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-not lvs $vg
-
-_clear_online_files
-pvscan --cache -aay "$dev1"
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-
-aux enable_dev "$dev2"
-aux udev_wait
-cat /proc/mdstat
-# for some reason enabling dev2 starts an odd md dev
-mdadm --stop $(lsblk -al -o NAME --noheadings "$dev2" | grep '^md') || true
-cat /proc/mdstat
-aux wipefs_a "$dev1" || true
-aux wipefs_a "$dev2" || true
-
-##########################################
-# PV on an md raid1 device, auto+stopped
-# md_component_checks: auto (not start)
-# mddev: stopped            (not started)
-# only one raid image online
-#
-
-aux lvmconf 'devices/md_component_checks = "auto"'
-
-mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
-aux wait_md_create "$mddev"
-pvcreate "$mddev"
-PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
-echo $PVIDMD
-vgcreate $vg "$mddev"
-lvcreate -n $lv1 -l 2 -an $vg
-
-mdadm --stop "$mddev"
-cat /proc/mdstat
-
-# disable one leg
-aux disable_dev "$dev2"
-
-# pvs does not show the PV
-not pvs "$mddev"
-not pvs "$dev1"
-not pvs "$dev2"
-pvs > out
-not grep $mddev out
-not grep "$dev1" out
-not grep "$dev2" out
-pvscan --cache
-not grep "$mddev" $HINTS
-not grep "$dev1" $HINTS
-not grep "$dev2" $HINTS
-
-# the vg is not seen, normal activation does nothing
-not lvchange -ay $vg/$lv1
-not lvs $vg
-
-# pvscan activation all does nothing
-_clear_online_files
-pvscan --cache -aay
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-
-# pvscan activation from md components does nothing
-_clear_online_files
-pvscan --cache -aay "$dev1"
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-pvscan --cache -aay "$dev2"
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-
-aux enable_dev "$dev2"
-aux udev_wait
-cat /proc/mdstat
-# for some reason enabling dev2 starts an odd md dev
-mdadm --stop $(lsblk -al -o NAME --noheadings "$dev2" | grep '^md') || true
-cat /proc/mdstat
-aux wipefs_a "$dev1" || true
-aux wipefs_a "$dev2" || true
-
-
-##########################################
-# PV on an md raid1 device, auto+stopped
-# md_component_checks: auto (not start)
-# mddev: stopped            (not started)
-# three raid images
-#
-
-aux lvmconf 'devices/md_component_checks = "auto"'
-
-mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=3 "$dev1" "$dev2" "$dev4"
-aux wait_md_create "$mddev"
-pvcreate "$mddev"
-PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
-echo $PVIDMD
-vgcreate $vg "$mddev"
-lvcreate -n $lv1 -l 2 -an $vg
-
-mdadm --stop "$mddev"
-cat /proc/mdstat
-
-# pvs does not show the PV
-not pvs "$mddev"
-not pvs "$dev1"
-not pvs "$dev2"
-not pvs "$dev4"
-pvs > out
-not grep $mddev out
-not grep "$dev1" out
-not grep "$dev2" out
-not grep "$dev4" out
-pvscan --cache
-not grep "$mddev" $HINTS
-not grep "$dev1" $HINTS
-not grep "$dev2" $HINTS
-not grep "$dev4" $HINTS
-
-# the vg is not seen, normal activation does nothing
-not lvchange -ay $vg/$lv1
-not lvs $vg
-
-# pvscan activation all does nothing
-_clear_online_files
-pvscan --cache -aay
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-
-# pvscan activation from md components does nothing
-_clear_online_files
-pvscan --cache -aay "$dev1"
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-pvscan --cache -aay "$dev2"
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-pvscan --cache -aay "$dev4"
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-
-aux wipefs_a "$dev1"
-aux wipefs_a "$dev2"
-aux wipefs_a "$dev4"
-aux udev_wait
-
-
-
-##########################################
-# PV on an md raid1 device, start+stopped
-# md_component_checks: start (not auto)
-# mddev: stopped             (not started)
-# three raid images
-
-aux lvmconf 'devices/md_component_checks = "start"'
-
-mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=3 "$dev1" "$dev2" "$dev4"
-aux wait_md_create "$mddev"
-pvcreate "$mddev"
-PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
-echo $PVIDMD
-vgcreate $vg "$mddev"
-lvcreate -n $lv1 -l 2 -an $vg
-
-mdadm --stop "$mddev"
-cat /proc/mdstat
-
-# pvs does not show the PV
-not pvs "$mddev"
-not pvs "$dev1"
-not pvs "$dev2"
-not pvs "$dev4"
-pvs > out
-not grep $mddev out
-not grep "$dev1" out
-not grep "$dev2" out
-not grep "$dev4" out
-pvscan --cache
-not grep "$mddev" $HINTS
-not grep "$dev1" $HINTS
-not grep "$dev2" $HINTS
-not grep "$dev4" $HINTS
-
-# the vg is not seen, normal activation does nothing
-not lvchange -ay $vg/$lv1
-not lvs $vg
-
-# pvscan activation all does nothing
-_clear_online_files
-pvscan --cache -aay
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-
-_clear_online_files
-pvscan --cache -aay "$dev1" || true
-not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
-not ls "$RUNDIR/lvm/vgs_online/$vg"
-
-aux enable_dev "$dev2"
-aux enable_dev "$dev4"
-aux udev_wait
-cat /proc/mdstat
-# for some reason enabling dev2 starts an odd md dev
-mdadm --stop $(lsblk -al -o NAME --noheadings "$dev2" | grep '^md') || true
-cat /proc/mdstat
-aux wipefs_a "$dev1" || true
-aux wipefs_a "$dev2" || true
-aux wipefs_a "$dev4" || true
 
+# Reuse same test just use raid level 1
+export MD_LEVEL=1
+. ./shell/duplicate-pvs-md0.sh


