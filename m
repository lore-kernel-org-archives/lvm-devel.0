From: David Teigland <teigland@sourceware.org>
Date: Thu, 3 Oct 2019 16:11:21 -0400
Subject: master - tests: add wipefs wrapper
Message-ID: <201910032011.x93KBLjQ009712@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d69304114948451c72b399346194af6ed4e10f9c
Commit:        d69304114948451c72b399346194af6ed4e10f9c
Parent:        c2ff8876f97a5840cd9d6fcda1bec55ef6220dc3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 2 14:11:08 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 2 14:11:08 2019 -0500

tests: add wipefs wrapper

which falls back to using dd on old systems without
the wipefs command
---
 test/lib/aux.sh                       |   11 +++++++++
 test/shell/allow-mixed-block-sizes.sh |    5 +--
 test/shell/duplicate-pvs-md0.sh       |   26 ++++++++++------------
 test/shell/duplicate-pvs-md1.sh       |   38 +++++++++++++++-----------------
 test/shell/lvm-on-md.sh               |   14 +++++-------
 test/shell/pvcreate-operation-md.sh   |   10 +++-----
 6 files changed, 53 insertions(+), 51 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 3c7ee62..8ceb5db 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -797,6 +797,17 @@ wait_md_create() {
 	echo "$md" > WAIT_MD_DEV
 }
 
+wipefs_a() {
+	local dev=$1
+	shift
+
+	if wipefs -V >/dev/null; then
+		wipefs -a "$dev"
+	else
+		dd if=/dev/zero of="$dev" bs=1024 || true
+	fi
+}
+
 prepare_backing_dev() {
 	local size=${1=32}
 	shift
diff --git a/test/shell/allow-mixed-block-sizes.sh b/test/shell/allow-mixed-block-sizes.sh
index ec60bc6..b51232a 100644
--- a/test/shell/allow-mixed-block-sizes.sh
+++ b/test/shell/allow-mixed-block-sizes.sh
@@ -15,7 +15,6 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 losetup -h | grep sector-size || skip
-wipefs -V || skip
 
 dd if=/dev/zero of=loopa bs=$((1024*1024)) count=2 2> /dev/null
 dd if=/dev/zero of=loopb bs=$((1024*1024)) count=2 2> /dev/null
@@ -32,8 +31,8 @@ not vgcreate --config 'devices {allow_mixed_block_sizes=0 scan="/dev"}' $vg $LOO
 vgcreate --config 'devices {allow_mixed_block_sizes=1 scan="/dev"}' $vg $LOOP1 $LOOP2
 vgs --config 'devices {allow_mixed_block_sizes=1 scan="/dev"}' $vg
 
-wipefs -a $LOOP1
-wipefs -a $LOOP2
+aux wipefs_a $LOOP1
+aux wipefs_a $LOOP2
 
 vgcreate --config 'devices {allow_mixed_block_sizes=1 scan="/dev"}' $vg $LOOP1
 vgs --config 'devices {allow_mixed_block_sizes=1 scan="/dev"}' $vg
diff --git a/test/shell/duplicate-pvs-md0.sh b/test/shell/duplicate-pvs-md0.sh
index e3f453f..21f1442 100644
--- a/test/shell/duplicate-pvs-md0.sh
+++ b/test/shell/duplicate-pvs-md0.sh
@@ -28,8 +28,6 @@ _clear_online_files() {
 
 . lib/inittest
 
-wipefs -V || skip
-
 test -f /proc/mdstat && grep -q raid0 /proc/mdstat || \
         modprobe raid0 || skip
 
@@ -125,8 +123,8 @@ vgchange -an $vg
 vgremove -f $vg
 mdadm --stop "$mddev"
 aux udev_wait
-wipefs -a "$dev1"
-wipefs -a "$dev2"
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
 aux udev_wait
 
 
@@ -197,8 +195,8 @@ vgchange -an $vg
 vgremove -f $vg
 mdadm --stop "$mddev"
 aux udev_wait
-wipefs -a "$dev1"
-wipefs -a "$dev2"
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
 aux udev_wait
 
 
@@ -253,8 +251,8 @@ pvscan --cache -aay "$dev2"
 not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
 not ls "$RUNDIR/lvm/vgs_online/$vg"
 
-wipefs -a "$dev1"
-wipefs -a "$dev2"
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
 aux udev_wait
 
 ##########################################
@@ -311,8 +309,8 @@ not ls "$RUNDIR/lvm/vgs_online/$vg"
 lvs -o active $vg |tee out || true
 not grep "active" out
 
-wipefs -a "$dev1"
-wipefs -a "$dev2"
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
 aux udev_wait
 
 
@@ -372,8 +370,8 @@ cat /proc/mdstat
 # for some reason enabling dev2 starts an odd md dev
 mdadm --stop "$mddev" || true
 cat /proc/mdstat
-wipefs -a "$dev1" || true
-wipefs -a "$dev2" || true
+aux wipefs_a "$dev1" || true
+aux wipefs_a "$dev2" || true
 aux udev_wait
 
 ##########################################
@@ -437,6 +435,6 @@ cat /proc/mdstat
 # for some reason enabling dev2 starts an odd md dev
 mdadm --stop "$mddev" || true
 cat /proc/mdstat
-wipefs -a "$dev1" || true
-wipefs -a "$dev2" || true
+aux wipefs_a "$dev1" || true
+aux wipefs_a "$dev2" || true
 aux udev_wait
diff --git a/test/shell/duplicate-pvs-md1.sh b/test/shell/duplicate-pvs-md1.sh
index a642c55..be223df 100644
--- a/test/shell/duplicate-pvs-md1.sh
+++ b/test/shell/duplicate-pvs-md1.sh
@@ -33,8 +33,6 @@ _clear_online_files() {
 
 . lib/inittest
 
-wipefs -V || skip
-
 test -f /proc/mdstat && grep -q raid1 /proc/mdstat || \
         modprobe raid1 || skip
 
@@ -130,8 +128,8 @@ vgchange -an $vg
 vgremove -f $vg
 mdadm --stop "$mddev"
 aux udev_wait
-wipefs -a "$dev1"
-wipefs -a "$dev2"
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
 aux udev_wait
 
 
@@ -216,8 +214,8 @@ vgchange -an $vg
 vgremove -f $vg
 mdadm --stop "$mddev"
 aux udev_wait
-wipefs -a "$dev1"
-wipefs -a "$dev2"
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
 aux udev_wait
 
 
@@ -272,8 +270,8 @@ pvscan --cache -aay "$dev2"
 not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
 not ls "$RUNDIR/lvm/vgs_online/$vg"
 
-wipefs -a "$dev1"
-wipefs -a "$dev2"
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
 aux udev_wait
 
 
@@ -340,8 +338,8 @@ not pvscan --cache -aay "$dev1"
 ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
 ls "$RUNDIR/lvm/vgs_online/$vg"
 
-wipefs -a "$dev1" || true
-wipefs -a "$dev2" || true
+aux wipefs_a "$dev1" || true
+aux wipefs_a "$dev2" || true
 
 
 ##########################################
@@ -419,8 +417,8 @@ cat /proc/mdstat
 # for some reason enabling dev2 starts an odd md dev
 mdadm --stop "$mddev" || true
 cat /proc/mdstat
-wipefs -a "$dev1" || true
-wipefs -a "$dev2" || true
+aux wipefs_a "$dev1" || true
+aux wipefs_a "$dev2" || true
 
 ##########################################
 # PV on an md raid1 device, auto+stopped
@@ -483,8 +481,8 @@ cat /proc/mdstat
 # for some reason enabling dev2 starts an odd md dev
 mdadm --stop "$mddev" || true
 cat /proc/mdstat
-wipefs -a "$dev1" || true
-wipefs -a "$dev2" || true
+aux wipefs_a "$dev1" || true
+aux wipefs_a "$dev2" || true
 
 
 ##########################################
@@ -545,9 +543,9 @@ pvscan --cache -aay "$dev4"
 not ls "$RUNDIR/lvm/pvs_online/$PVIDMD"
 not ls "$RUNDIR/lvm/vgs_online/$vg"
 
-wipefs -a "$dev1"
-wipefs -a "$dev2"
-wipefs -a "$dev4"
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
+aux wipefs_a "$dev4"
 aux udev_wait
 
 
@@ -621,7 +619,7 @@ cat /proc/mdstat
 # for some reason enabling dev2 starts an odd md dev
 mdadm --stop "$mddev" || true
 cat /proc/mdstat
-wipefs -a "$dev1" || true
-wipefs -a "$dev2" || true
-wipefs -a "$dev4" || true
+aux wipefs_a "$dev1" || true
+aux wipefs_a "$dev2" || true
+aux wipefs_a "$dev4" || true
 
diff --git a/test/shell/lvm-on-md.sh b/test/shell/lvm-on-md.sh
index 726adf2..910ebc7 100644
--- a/test/shell/lvm-on-md.sh
+++ b/test/shell/lvm-on-md.sh
@@ -28,8 +28,6 @@ _clear_online_files() {
 
 . lib/inittest
 
-wipefs -V || skip
-
 test -f /proc/mdstat && grep -q raid1 /proc/mdstat || \
 	modprobe raid1 || skip
 
@@ -168,8 +166,8 @@ vgremove -f $vg
 
 mdadm --stop "$mddev"
 aux udev_wait
-wipefs -a "$dev1"
-wipefs -a "$dev2"
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
 aux udev_wait
 
 
@@ -293,8 +291,8 @@ vgremove -f $vg
 
 mdadm --stop "$mddev"
 aux udev_wait
-wipefs -a "$dev1"
-wipefs -a "$dev2"
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
 aux udev_wait
 
 
@@ -461,7 +459,7 @@ vgremove -f $vg
 
 mdadm --stop "$mddev"
 aux udev_wait
-wipefs -a "$dev1"
-wipefs -a "$dev2"
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
 aux udev_wait
 
diff --git a/test/shell/pvcreate-operation-md.sh b/test/shell/pvcreate-operation-md.sh
index 49edf4c..f4b2a0d 100644
--- a/test/shell/pvcreate-operation-md.sh
+++ b/test/shell/pvcreate-operation-md.sh
@@ -18,8 +18,6 @@ SKIP_WITH_LVMPOLLD=1
 # skip this test if mdadm or sfdisk (or others) aren't available
 which sfdisk || skip
 
-wipefs -V || skip
-
 test -f /proc/mdstat && grep -q raid0 /proc/mdstat || \
 	modprobe raid0 || skip
 mddev="/dev/md33"
@@ -115,8 +113,8 @@ fi
 
 mdadm --stop "$mddev"
 aux udev_wait
-wipefs -a "$dev1"
-wipefs -a "$dev2"
+aux wipefs_a "$dev1"
+aux wipefs_a "$dev2"
 aux udev_wait
 
 # Test newer topology-aware alignment detection w/ --dataalignment override
@@ -142,8 +140,8 @@ if aux kernel_at_least 2 6 33 ; then
 
     mdadm --stop "$mddev"
     aux udev_wait
-    wipefs -a "$dev1"
-    wipefs -a "$dev2"
+    aux wipefs_a "$dev1"
+    aux wipefs_a "$dev2"
     aux udev_wait
 
 fi


