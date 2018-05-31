From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 17:22:52 -0400
Subject: master - tests: enable non-working tests with lvmlockd
Message-ID: <201805312122.w4VLMqXY001309@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=885eb2024ffff6757bba39666a1d334d6d72a066
Commit:        885eb2024ffff6757bba39666a1d334d6d72a066
Parent:        00f6a8466edfc386067efb1e000a808080966076
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 31 16:18:53 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 31 16:18:53 2018 -0500

tests: enable non-working tests with lvmlockd

Those that are failing for reasons other than lvmlockd
restrictions.
---
 test/shell/component-thin.sh                       |    2 +-
 test/shell/lvconvert-raid-allocation.sh            |    4 ++--
 test/shell/lvconvert-raid-reshape-load.sh          |    4 ++--
 .../lvconvert-raid-reshape-stripes-load-fail.sh    |    4 ++--
 .../lvconvert-raid-reshape-stripes-load-reload.sh  |    4 ++--
 test/shell/lvconvert-raid-reshape-stripes-load.sh  |    4 ++--
 test/shell/lvconvert-raid-reshape.sh               |    4 ++--
 test/shell/lvconvert-raid-status-validation.sh     |    4 ++--
 test/shell/lvconvert-raid5_to_raid10.sh            |    2 +-
 test/shell/lvcreate-large-raid.sh                  |    4 ++--
 test/shell/mirror-names.sh                         |    2 +-
 test/shell/pvcreate-md-fake-hdr.sh                 |    4 ++--
 test/shell/pvcreate-operation-md.sh                |    2 +-
 test/shell/thin-large.sh                           |    2 +-
 14 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/test/shell/component-thin.sh b/test/shell/component-thin.sh
index 4b1a35b..3cf02f3 100644
--- a/test/shell/component-thin.sh
+++ b/test/shell/component-thin.sh
@@ -12,7 +12,7 @@
 
 # Exercise activation of thin component devices
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-raid-allocation.sh b/test/shell/lvconvert-raid-allocation.sh
index 7529800..acdae0c 100644
--- a/test/shell/lvconvert-raid-allocation.sh
+++ b/test/shell/lvconvert-raid-allocation.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -20,7 +20,7 @@ aux have_raid 1 3 0 || skip
 aux prepare_pvs 5
 get_devs
 
-vgcreate -s 256k "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 256k "$vg" "${DEVICES[@]}"
 
 # Start with linear on 2 PV and ensure that converting to
 # RAID is not allowed to reuse PVs for different images.  (Bug 1113180)
diff --git a/test/shell/lvconvert-raid-reshape-load.sh b/test/shell/lvconvert-raid-reshape-load.sh
index cd72d09..11af24d 100644
--- a/test/shell/lvconvert-raid-reshape-load.sh
+++ b/test/shell/lvconvert-raid-reshape-load.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA2110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -35,7 +35,7 @@ aux prepare_pvs 16 32
 
 get_devs
 
-vgcreate -s 1M "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 1M "$vg" "${DEVICES[@]}"
 
 trap 'cleanup_mounted_and_teardown' EXIT
 
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
index 88722b0..feaf1e2 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA2110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -35,7 +35,7 @@ aux prepare_pvs 16 32
 
 get_devs
 
-vgcreate -s 1M "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 1M "$vg" "${DEVICES[@]}"
 
 trap 'cleanup_mounted_and_teardown' EXIT
 
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
index fc463bf..839e704 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA2110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -35,7 +35,7 @@ aux prepare_pvs 16 32
 
 get_devs
 
-vgcreate -s 1M "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 1M "$vg" "${DEVICES[@]}"
 
 trap 'cleanup_mounted_and_teardown' EXIT
 
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load.sh b/test/shell/lvconvert-raid-reshape-stripes-load.sh
index 1be8d61..29790aa 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA2110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -35,7 +35,7 @@ aux prepare_pvs 16 32
 
 get_devs
 
-vgcreate -s 1M "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 1M "$vg" "${DEVICES[@]}"
 
 trap 'cleanup_mounted_and_teardown' EXIT
 
diff --git a/test/shell/lvconvert-raid-reshape.sh b/test/shell/lvconvert-raid-reshape.sh
index e621318..ab3ea4e 100644
--- a/test/shell/lvconvert-raid-reshape.sh
+++ b/test/shell/lvconvert-raid-reshape.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA2110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 LVM_SKIP_LARGE_TESTS=0
@@ -34,7 +34,7 @@ fi
 
 get_devs
 
-vgcreate -s 1M "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 1M "$vg" "${DEVICES[@]}"
 
 function _lvcreate
 {
diff --git a/test/shell/lvconvert-raid-status-validation.sh b/test/shell/lvconvert-raid-status-validation.sh
index 3e91d23..c5396d7 100644
--- a/test/shell/lvconvert-raid-status-validation.sh
+++ b/test/shell/lvconvert-raid-status-validation.sh
@@ -15,7 +15,7 @@
 # 'dmsetup status' for RAID LVs - especially during various sync action
 # transitions, like: recover, resync, check, repair, idle, reshape, etc
 #######################################################################
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
@@ -33,7 +33,7 @@ aux have_raid 1 13 0 || skip
 aux prepare_pvs 9
 get_devs
 
-vgcreate -s 2m "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 2m "$vg" "${DEVICES[@]}"
 
 ###########################################
 # Upconverted RAID1 should never have all 'a's in status output
diff --git a/test/shell/lvconvert-raid5_to_raid10.sh b/test/shell/lvconvert-raid5_to_raid10.sh
index cc0e468..e38e4d3 100644
--- a/test/shell/lvconvert-raid5_to_raid10.sh
+++ b/test/shell/lvconvert-raid5_to_raid10.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA2110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index 3488db4..b66cfd2 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -12,7 +12,7 @@
 
 # 'Exercise some lvcreate diagnostics'
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -31,7 +31,7 @@ aux have_raid4 && segtypes="raid4 raid5"
 aux prepare_pvs 5 1000000000
 get_devs
 
-vgcreate "$vg1" "${DEVICES[@]}"
+vgcreate $SHARED "$vg1" "${DEVICES[@]}"
 
 aux lvmconf 'devices/issue_discards = 1'
 
diff --git a/test/shell/mirror-names.sh b/test/shell/mirror-names.sh
index a3bc80f..54d42e1 100644
--- a/test/shell/mirror-names.sh
+++ b/test/shell/mirror-names.sh
@@ -13,7 +13,7 @@
 
 test_description="check namings of mirrored LV"
 
-SKIP_WITH_LVMLOCKD=1
+
 
 . lib/inittest
 
diff --git a/test/shell/pvcreate-md-fake-hdr.sh b/test/shell/pvcreate-md-fake-hdr.sh
index 50a5b14..b89fe43 100644
--- a/test/shell/pvcreate-md-fake-hdr.sh
+++ b/test/shell/pvcreate-md-fake-hdr.sh
@@ -12,7 +12,7 @@
 
 
 # TODO: once code get fixed, add matching 'check' calls
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -25,7 +25,7 @@ aux extend_filter_LVMTEST "a|/dev/md|"
 
 aux prepare_devs 4
 
-vgcreate $vg "$dev3" "$dev4"
+vgcreate $SHARED $vg "$dev3" "$dev4"
 
 # create 2 disk MD raid1 array
 # by default using metadata format 1.0 with data at the end of device
diff --git a/test/shell/pvcreate-operation-md.sh b/test/shell/pvcreate-operation-md.sh
index f534785..11f0887 100644
--- a/test/shell/pvcreate-operation-md.sh
+++ b/test/shell/pvcreate-operation-md.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/thin-large.sh b/test/shell/thin-large.sh
index b1cf29a..714f91e 100644
--- a/test/shell/thin-large.sh
+++ b/test/shell/thin-large.sh
@@ -12,7 +12,7 @@
 
 # 'Exercise logic around boundary sizes of thin-pool data and chunksize
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest


