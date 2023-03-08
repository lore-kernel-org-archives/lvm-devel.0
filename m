From: David Teigland <teigland@sourceware.org>
Date: Wed,  8 Mar 2023 22:34:45 +0000 (GMT)
Subject: main - tests: update missing-pv
Message-ID: <20230308223445.12C0B3858D33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e79c6feb080f30fc4bb4adbfd69c41ac90b6cde3
Commit:        e79c6feb080f30fc4bb4adbfd69c41ac90b6cde3
Parent:        69ea2e3f94815dc94b5fdd8284d30a667690f5df
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 8 17:17:30 2023 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 8 16:31:28 2023 -0600

tests: update missing-pv

add more checks and expand comments explaining behavior
---
 test/shell/missing-pv.sh | 106 ++++++++++++++++++++++++++++++++---------------
 1 file changed, 72 insertions(+), 34 deletions(-)

diff --git a/test/shell/missing-pv.sh b/test/shell/missing-pv.sh
index 3662483b0..e1ff65917 100644
--- a/test/shell/missing-pv.sh
+++ b/test/shell/missing-pv.sh
@@ -28,8 +28,12 @@ lvs -a -o+devices
 # Fail one leg of each mirror LV.
 aux disable_dev "$dev1"
 
-pvs
-vgs
+pvs -o+missing |tee out
+grep missing out |tee out2
+grep unknown out2
+vgs -o+partial,missing_pv_count
+check vg_field $vg vg_partial "partial"
+check vg_field $vg vg_missing_pv_count 1
 lvs -a -o+devices
 
 # Cannot do normal activate of either LV with a failed leg.
@@ -40,8 +44,12 @@ not lvchange -ay $vg/$lv2
 lvchange -ay --activationmode partial $vg/$lv1
 lvchange -ay --activationmode partial $vg/$lv2
 
-pvs
-vgs
+pvs -o+missing |tee out
+grep missing out |tee out2
+grep unknown out2
+vgs -o+partial,missing_pv_count
+check vg_field $vg vg_partial "partial"
+check vg_field $vg vg_missing_pv_count 1
 lvs -a -o+devices
 
 # Repair lv1 so it no longer uses failed dev.
@@ -54,8 +62,12 @@ pvck --dump metadata "$dev2" > meta
 grep MISSING meta
 rm meta
 
-pvs
-vgs
+pvs -o+missing |tee out
+grep missing out |tee out2
+grep unknown out2
+vgs -o+partial,missing_pv_count
+check vg_field $vg vg_partial "partial"
+check vg_field $vg vg_missing_pv_count 1
 lvs -a -o+devices
 
 # Verify normal activation is possible of lv1 since it's
@@ -68,8 +80,12 @@ vgchange -an $vg
 
 aux enable_dev "$dev1"
 
-pvs
-vgs
+pvs -o+missing |tee out
+grep missing out |tee out2
+grep "$dev1" out2
+vgs -o+partial,missing_pv_count
+check vg_field $vg vg_partial "partial"
+check vg_field $vg vg_missing_pv_count 1
 lvs -a -o+devices
 
 # TODO: check that lv2 has partial flag, lv1 does not
@@ -82,7 +98,6 @@ pvck --dump metadata "$dev2" > meta
 grep MISSING meta
 rm meta
 
-
 # The missing pv restrictions still apply even after
 # the dev has reappeared since it has the MISSING flag.
 not lvchange -ay $vg/$lv2
@@ -98,52 +113,75 @@ not lvcreate -l1 $vg
 # explicitly writes/fixes metadata.
 vgck --updatemetadata $vg
 
-pvs
-vgs
+pvs -o+missing |tee out
+grep missing out |tee out2
+grep "$dev1" out2
+vgs -o+partial,missing_pv_count
+check vg_field $vg vg_partial "partial"
+check vg_field $vg vg_missing_pv_count 1
 lvs -a -o+devices
 
-# Check that MISSING flag is still set in ondisk
-# metadata since the previously missing dev is still
-# used by lv2.
+# Check that MISSING flag is still set in ondisk metadata since the
+# previously missing dev is still used by lv2.
 pvck --dump metadata "$dev2" > meta
 grep MISSING meta
 rm meta
 
-
-# The missing pv restrictions still apply since it
-# has the MISSING flag.
+# The missing pv restrictions still apply since it has the MISSING flag.
 not lvchange -ay $vg/$lv2
 not lvcreate -l1 $vg
 
 lvchange -ay --activationmode partial  $vg/$lv2
 
-# After repair, no more LVs will be using the previously
-# missing PV.
+# Replace the missing leg of LV2 so no LV will be using the dev that was
+# missing.  The MISSING_PV flag will not have been cleared from the
+# metadata yet; that will take another metadata update.
 lvconvert --repair --yes $vg/$lv2
 
-pvs
-vgs
-lvs -a -o+devices
+lvs -a -o+devices | tee out
+not grep "$dev1" out
 
-vgchange -an $vg
-
-# The next write of the metadata will clear the MISSING
-# flag in ondisk metadata because the previously missing
-# PV is no longer used by any LVs.
+# The MISSING_PV flag hasn't been cleared from the metadata yet, but now
+# that the PV is not used by any more LVs, that flag will be cleared from
+# the metadata in the next update.
+pvck --dump metadata "$dev2" > meta
+grep MISSING meta
+rm meta
 
-# Run a command to write ondisk metadata, which should clear
-# the MISSING flag, could also use vgck --updatemetadata vg.
+# Reporting commands run vg_read which sees MISSING_PV in the metadata,
+# but vg_read then sees the dev is no longer used by any LV, so vg_read
+# clears the MISSING_PV flag in the vg struct (not in the metadata) before
+# returning the vg struct to the caller.  It's cleared in the vg struct so
+# that the limitations of having a missing PV are not applied to the
+# command.  The caller sees/uses/reports the VG as having no missing PV,
+# even though the metadata still contains MISSING_PV.  The MISSING_PV flag
+# is no longer needed in the metadata, but there has simply not been a
+# metadata update yet to clear it.
+# The message that's printed in this case is:
+# WARNING: VG %s has unused reappeared PV %s %s
+pvs -o+missing |tee out
+not grep missing out
+vgs -o+partial,missing_pv_count
+check vg_field $vg vg_partial ""
+check vg_field $vg vg_missing_pv_count 0
+
+# Run any command that updates the metadata, and the MISSING_PV flag will
+# be cleared.  Here just use lvcreate -l1, or we could use
+# vgck --updatemetadata.
 lvcreate -l1 $vg
 
-# Check that the MISSING flag is no longer set
-# in the ondisk metadata.
+# Now the MISSING flag is removed from the ondisk metadata.
 pvck --dump metadata "$dev2" > meta
 not grep MISSING meta
 rm meta
 
+# and commands continue to report no missing PV
+pvs -o+missing |tee out
+not grep missing out
+vgs -o+partial,missing_pv_count
+check vg_field $vg vg_partial ""
+check vg_field $vg vg_missing_pv_count 0
 
-pvs
-vgs
-lvs -a -o+devices
+vgchange -an $vg
 
 vgremove -ff $vg

