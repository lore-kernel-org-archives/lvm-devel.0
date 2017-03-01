From: David Teigland <teigland@sourceware.org>
Date: Wed, 1 Mar 2017 11:23:21 -0500
Subject: master - commands: SECONDARY flag changes in cmd defs
Message-ID: <201703011623.v21GNLNP031495@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=eb9586bd3bc6741a3819147b35546ae35f363de1
Commit:        eb9586bd3bc6741a3819147b35546ae35f363de1
Parent:        d6dd700bf75d218a6f7627451d020232d3d88c31
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 28 16:15:11 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 1 10:22:48 2017 -0600

commands: SECONDARY flag changes in cmd defs

Add/remove the SECONDARY_SYNTAX flag to cmd defs.
cmd defs with this flag will be listed under the
ADVANCED USAGE man page section, so that the main
USAGE section contains the most common commands
without distraction.

- When multiple cmd defs do the same thing, one variant
  can be displayed in the first list.
- Very advanced, unusual or uncommon commands should be
  in the second list.
---
 tools/command-lines.in |   26 ++++++++++++++------------
 1 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 1727bbb..5f65093 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -340,6 +340,7 @@ OP: PV ...
 ID: lvconvert_raid_types
 DESC: Convert LV to type mirror (also see type raid1).
 RULE: all not lv_is_locked lv_is_pvmove
+FLAGS: SECONDARY_SYNTAX
 
 # When LV is already raid, this changes the raid layout
 # (changing layout of raid0 and raid1 not allowed.)
@@ -379,6 +380,7 @@ ID: lvconvert_change_region_size
 DESC: Change the region size of an LV.
 RULE: all not lv_is_locked lv_is_pvmove
 RULE: all not LV_raid0
+FLAGS: SECONDARY_SYNTAX
 
 ---
 
@@ -411,6 +413,7 @@ OP: PV ...
 ID: lvconvert_change_mirrorlog
 DESC: Change the type of mirror log used by a mirror LV.
 RULE: all not lv_is_locked lv_is_pvmove
+FLAGS: SECONDARY_SYNTAX
 
 ---
 
@@ -543,6 +546,7 @@ lvconvert --uncache LV_cache_thinpool
 OO: OO_LVCONVERT
 ID: lvconvert_split_and_remove_cachepool
 DESC: Separate and delete the cache pool from a cache LV.
+FLAGS: SECONDARY_SYNTAX
 
 ---
 
@@ -550,6 +554,7 @@ lvconvert --swapmetadata --poolmetadata LV LV_thinpool_cachepool
 OO: --chunksize SizeKB, OO_LVCONVERT
 ID: lvconvert_swap_pool_metadata
 DESC: Swap metadata LV in a thin pool or cache pool (for repair only).
+FLAGS: SECONDARY_SYNTAX
 
 ---
 
@@ -597,6 +602,7 @@ OO: OO_LVCONVERT
 ID: lvconvert_split_cow_snapshot
 DESC: Separate a COW snapshot from its origin LV.
 RULE: all not lv_is_locked lv_is_pvmove lv_is_origin lv_is_external_origin lv_is_merging_cow
+FLAGS: SECONDARY_SYNTAX
 
 ---
 
@@ -614,9 +620,9 @@ OO: --snapshot, --chunksize SizeKB, --zero Bool, OO_LVCONVERT
 ID: lvconvert_combine_split_snapshot
 DESC: Combine a former COW snapshot (second arg) with a former
 DESC: origin LV (first arg) to reverse a splitsnapshot command.
-FLAGS: SECONDARY_SYNTAX
 RULE: all not lv_is_locked lv_is_pvmove
 RULE: all and lv_is_visible
+FLAGS: SECONDARY_SYNTAX
 
 lvconvert --snapshot LV LV_linear
 OO: --type snapshot, --chunksize SizeKB, --zero Bool, OO_LVCONVERT
@@ -625,6 +631,7 @@ DESC: Combine a former COW snapshot (second arg) with a former
 DESC: origin LV (first arg) to reverse a splitsnapshot command.
 RULE: all not lv_is_locked lv_is_pvmove
 RULE: all and lv_is_visible
+FLAGS: SECONDARY_SYNTAX
 
 ---
 
@@ -745,6 +752,7 @@ OO: --stripes Number, --stripesize SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_striped
 DESC: Create a striped LV.
+FLAGS: SECONDARY_SYNTAX
 
 lvcreate --stripes Number --size SizeMB VG
 OO: --type striped, --stripesize SizeKB, OO_LVCREATE
@@ -759,6 +767,7 @@ OO: --mirrors SNumber, --mirrorlog MirrorLog, --regionsize RegionSize, --stripes
 OP: PV ...
 ID: lvcreate_mirror
 DESC: Create a mirror LV (also see --type raid1).
+FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type raid1|mirror
 lvcreate --mirrors SNumber --size SizeMB VG
@@ -816,6 +825,7 @@ OO: --type snapshot, --chunksize SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_cow_snapshot_with_virtual_origin
 DESC: Create a sparse COW snapshot LV of a virtual origin LV.
+FLAGS: SECONDARY_SYNTAX
 
 ---
 
@@ -877,6 +887,7 @@ OO: --thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_vol
 DESC: Create a thin LV in a thin pool.
+FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin
 lvcreate --type thin --virtualsize SizeMB LV_thinpool
@@ -896,7 +907,6 @@ OO: --type thin, --thin, OO_LVCREATE_THIN, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_vol
 DESC: Create a thin LV in a thin pool (variant, infers --type thin).
-FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin
 lvcreate --virtualsize SizeMB LV_thinpool
@@ -915,6 +925,7 @@ OO: --thin, OO_LVCREATE_THIN, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_snapshot
 DESC: Create a thin LV that is a snapshot of an existing thin LV.
+FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin
 lvcreate --thin LV_thin
@@ -946,6 +957,7 @@ IO: --mirrors 0
 ID: lvcreate_thin_snapshot_of_external
 DESC: Create a thin LV that is a snapshot of an external origin LV
 DESC: (infers --type thin).
+FLAGS: SECONDARY_SYNTAX
 
 ---
 
@@ -1153,7 +1165,6 @@ OO: --alloc Alloc, --autobackup Bool, --force, --mirrors SNumber,
 --type SegType
 ID: lvextend_by_pv
 DESC: Extend an LV by specified PV extents.
-FLAGS: SECONDARY_SYNTAX
 
 lvextend --poolmetadatasize SizeMB LV_thinpool
 OO: --alloc Alloc, --autobackup Bool, --force, --mirrors SNumber,
@@ -1226,7 +1237,6 @@ OO: --alloc Alloc, --autobackup Bool, --force,
 --type SegType
 ID: lvresize_by_pv
 DESC: Resize an LV by specified PV extents.
-FLAGS: SECONDARY_SYNTAX
 
 lvresize --poolmetadatasize SizeMB LV_thinpool
 OO: --alloc Alloc, --autobackup Bool, --force,
@@ -1504,7 +1514,6 @@ vgexport --all
 OO: OO_VGEXPORT
 ID: vgexport_all
 DESC: Export all VGs.
-FLAGS: SECONDARY_SYNTAX
 
 ---
 
@@ -1628,14 +1637,12 @@ config
 OO: OO_CONFIG
 OP: String ...
 ID: lvmconfig_general
-FLAGS: SECONDARY_SYNTAX
 
 # use lvmconfig
 dumpconfig
 OO: OO_CONFIG
 OP: String ...
 ID: lvmconfig_general
-FLAGS: SECONDARY_SYNTAX
 
 devtypes
 OO: --aligned, --binary, --nameprefixes, --noheadings,
@@ -1669,7 +1676,6 @@ ID: version_general
 # deprecated
 pvdata
 ID: pvdata_general
-FLAGS: SECONDARY_SYNTAX
 
 segtypes
 ID: segtypes_general
@@ -1683,22 +1689,18 @@ ID: tags_general
 # deprecated
 lvmchange
 ID: lvmchange_general
-FLAGS: SECONDARY_SYNTAX
 
 # deprecated
 lvmdiskscan
 OO: --lvmpartition, --readonly
 ID: lvmdiskscan_general
-FLAGS: SECONDARY_SYNTAX
 
 # deprecated
 lvmsadc
 ID: lvmsadc_general
-FLAGS: SECONDARY_SYNTAX
 
 # deprecated
 lvmsar
 OO: --full, --stdin
 ID: lvmsar_general
-FLAGS: SECONDARY_SYNTAX
 


