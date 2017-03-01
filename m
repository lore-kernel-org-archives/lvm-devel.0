From: David Teigland <teigland@sourceware.org>
Date: Wed, 1 Mar 2017 18:00:40 -0500
Subject: master - commands: tweak some descriptions
Message-ID: <201703012300.v21N0eL6028719@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=51dfbf1fb34199d00fcace378df50f580f7ed57d
Commit:        51dfbf1fb34199d00fcace378df50f580f7ed57d
Parent:        daf1d4cadc69aeb8f4d83e44697948150ffcfda3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 1 16:50:27 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 1 16:59:51 2017 -0600

commands: tweak some descriptions

---
 tools/command-lines.in |   47 +++++++++++++++++++++--------------------------
 1 files changed, 21 insertions(+), 26 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 5f65093..6956c15 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -338,7 +338,8 @@ lvconvert --type mirror LV
 OO: OO_LVCONVERT_RAID, OO_LVCONVERT, --mirrorlog MirrorLog
 OP: PV ...
 ID: lvconvert_raid_types
-DESC: Convert LV to type mirror (also see type raid1).
+DESC: Convert LV to type mirror (also see type raid1),
+DESC: (also see lvconvert --mirrors).
 RULE: all not lv_is_locked lv_is_pvmove
 FLAGS: SECONDARY_SYNTAX
 
@@ -431,8 +432,8 @@ RULE: all not lv_is_locked
 lvconvert --thin --thinpool LV LV_linear_striped_raid_cache
 OO: --type thin, --originname LV_new, --zero Bool, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_thin_with_external
-DESC: Convert LV to a thin LV, using the original LV as an external origin.
-DESC: (variant, infers --type thin).
+DESC: Convert LV to a thin LV, using the original LV as an external origin
+DESC: (infers --type thin).
 FLAGS: SECONDARY_SYNTAX
 RULE: all and lv_is_visible
 RULE: all not lv_is_locked
@@ -449,9 +450,9 @@ RULE: all and lv_is_visible
 lvconvert --cache --cachepool LV LV_linear_striped_raid_thinpool
 OO: --type cache, OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_cache_vol
-DESC: Convert LV to type cache (variant, infers --type cache).
-FLAGS: SECONDARY_SYNTAX
+DESC: Convert LV to type cache (infers --type cache).
 RULE: all and lv_is_visible
+FLAGS: SECONDARY_SYNTAX
 
 ---
 
@@ -664,7 +665,7 @@ lvconvert --replace PV LV_raid
 OO: OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_replace_pv
-DESC: Replace specific PV(s) in a raid* LV with another PV.
+DESC: Replace specific PV(s) in a raid LV with another PV.
 RULE: all not lv_is_locked lv_is_pvmove
 
 ---
@@ -683,7 +684,7 @@ RULE: all and lv_is_converting
 lvconvert LV_mirror_raid
 OO: OO_LVCONVERT
 ID: lvconvert_start_poll
-DESC: Poll LV to continue conversion.
+DESC: Poll LV to continue conversion (also see --startpoll).
 RULE: all and lv_is_converting
 FLAGS: SECONDARY_SYNTAX
 
@@ -733,17 +734,12 @@ ID: lvcreate_linear
 DESC: Create a linear LV.
 FLAGS: SECONDARY_SYNTAX
 
-# This is the one place we mention the optional --name
-# because it's the most common case and may be confusing
-# to people to not see the name parameter.
-
 lvcreate --size SizeMB VG
 OO: --type linear, OO_LVCREATE
 OP: PV ...
 IO: --mirrors 0, --stripes 1
 ID: lvcreate_linear
-DESC: Create a linear LV (default --type linear).
-DESC: When --name is omitted, the name is generated.
+DESC: Create a linear LV.
 
 ---
 
@@ -751,7 +747,7 @@ lvcreate --type striped --size SizeMB VG
 OO: --stripes Number, --stripesize SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_striped
-DESC: Create a striped LV.
+DESC: Create a striped LV (also see lvcreate --stripes).
 FLAGS: SECONDARY_SYNTAX
 
 lvcreate --stripes Number --size SizeMB VG
@@ -774,7 +770,7 @@ lvcreate --mirrors SNumber --size SizeMB VG
 OO: --type raid1, --type mirror, --mirrorlog MirrorLog, --stripes Number, OO_LVCREATE_RAID, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_mirror_or_raid1
-DESC: Create a raid1 or mirror LV (variant, infers --type raid1|mirror).
+DESC: Create a raid1 or mirror LV (infers --type raid1|mirror).
 
 ---
 
@@ -782,17 +778,14 @@ lvcreate --type raid --size SizeMB VG
 OO: OO_LVCREATE_RAID, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_raid_any
-DESC: Create a raid LV (a specific raid level must be used, e.g. raid1.)
+DESC: Create a raid LV (a specific raid level must be used, e.g. raid1).
 
 ---
 
-# FIXME: the LV created by these commands actually has type linear or striped,
+# The LV created by these commands actually has type linear or striped,
 # not snapshot as specified by the command.  If LVs never have type
 # snapshot, perhaps "snapshot" should not be considered an LV type, but
 # another new LV property?
-#
-# This is the one case where the --type variant is the unpreferred,
-# secondary syntax, because the LV type is not actually "snapshot".
 
 # alternate form of lvcreate --snapshot
 lvcreate --type snapshot --size SizeMB LV
@@ -800,7 +793,8 @@ OO: --snapshot, --stripes Number, --stripesize SizeKB,
 --chunksize SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_cow_snapshot
-DESC: Create a COW snapshot LV from an origin LV.
+DESC: Create a COW snapshot LV of an origin LV
+DESC: (also see --snapshot).
 FLAGS: SECONDARY_SYNTAX
 
 lvcreate --snapshot --size SizeMB LV
@@ -808,7 +802,7 @@ OO: --type snapshot, --stripes Number, --stripesize SizeKB,
 --chunksize SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_cow_snapshot
-DESC: Create a COW snapshot LV from an origin LV.
+DESC: Create a COW snapshot LV of an origin LV.
 
 ---
 
@@ -817,7 +811,8 @@ lvcreate --type snapshot --size SizeMB --virtualsize SizeMB VG
 OO: --snapshot, --chunksize SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_cow_snapshot_with_virtual_origin
-DESC: Create a sparse COW snapshot LV of a virtual origin LV.
+DESC: Create a sparse COW snapshot LV of a virtual origin LV
+DESC: (also see --snapshot).
 FLAGS: SECONDARY_SYNTAX
 
 lvcreate --snapshot --size SizeMB --virtualsize SizeMB VG
@@ -844,7 +839,7 @@ OO: --type thin-pool, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
 OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thinpool
-DESC: Create a thin pool (variant, infers --type thin-pool).
+DESC: Create a thin pool (infers --type thin-pool).
 FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin-pool
@@ -855,7 +850,7 @@ OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thinpool
 DESC: Create a thin pool named by the --thinpool arg
-DESC: (variant, infers --type thin-pool).
+DESC: (infers --type thin-pool).
 FLAGS: SECONDARY_SYNTAX
 
 ---
@@ -906,7 +901,7 @@ lvcreate --virtualsize SizeMB --thinpool LV_thinpool VG
 OO: --type thin, --thin, OO_LVCREATE_THIN, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_vol
-DESC: Create a thin LV in a thin pool (variant, infers --type thin).
+DESC: Create a thin LV in a thin pool (infers --type thin).
 
 # alternate form of lvcreate --type thin
 lvcreate --virtualsize SizeMB LV_thinpool


