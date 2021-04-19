From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Apr 2021 13:00:55 +0000 (GMT)
Subject: main - commands: update definitions for thin creation
Message-ID: <20210419130055.17564396901B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b1ad32acd63dedbd94b995f0d76f50343b751eff
Commit:        b1ad32acd63dedbd94b995f0d76f50343b751eff
Parent:        82e3b2e0adda88cd5542c97486ba6e8da28d2a47
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 16 18:31:27 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 19 14:40:14 2021 +0200

commands: update definitions for thin creation

Add missing VG into description of thin pool creation command.

Remove one duplicated thin-pool creation command.
Remove options --discards and --errorwhenfull from the list when the command describes
only creation of a thin volume - as these options do apply for thin-pool.
Also use here more correct name OO_LVCONVERT_THINPOOL instead of OO_LVCONVERT_THIN.

Reorder extra options for cache & thin-pool before common pool options.
Order consistenly --stripes and --stripesize after --extents option
so the options related to pools are better together.

Remove invalid snapshot creation description - since this case is
handled through our configurable spare volume creation.

Add some missing optional --type parameters for few command instancies.
---
 tools/command-lines.in | 134 ++++++++++++++++++++++---------------------------
 1 file changed, 60 insertions(+), 74 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 0a3359630..459e2afb6 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -318,7 +318,7 @@ OO_LVCONVERT_POOL: --poolmetadata LV, --poolmetadatasize SizeMB,
 --poolmetadataspare Bool, --readahead Readahead, --chunksize SizeKB,
 --zero Bool, --metadataprofile String
 
-OO_LVCONVERT_THIN: --discards Discards, --errorwhenfull Bool
+OO_LVCONVERT_THINPOOL: --discards Discards, --errorwhenfull Bool
 
 OO_LVCONVERT_CACHE: --cachemetadataformat CacheMetadataFormat,
 --cachemode CacheMode, --cachepolicy String,
@@ -519,7 +519,7 @@ RULE: all and lv_is_visible
 
 lvconvert --type thin-pool LV_linear_striped_raid_cache_error_zero
 OO: --stripes_long Number, --stripesize SizeKB,
-OO_LVCONVERT_THIN, OO_LVCONVERT_POOL, OO_LVCONVERT
+OO_LVCONVERT_THINPOOL, OO_LVCONVERT_POOL, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_to_thinpool
 DESC: Convert LV to type thin-pool.
@@ -551,7 +551,7 @@ RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 lvconvert --thinpool LV_linear_striped_raid_cache_thinpool
 OO: --type thin-pool, --stripes_long Number, --stripesize SizeKB,
-OO_LVCONVERT_THIN, OO_LVCONVERT_POOL, OO_LVCONVERT
+OO_LVCONVERT_THINPOOL, OO_LVCONVERT_POOL, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_to_thinpool_or_swap_metadata
 DESC: Convert LV to type thin-pool (variant, use --type thin-pool).
@@ -740,7 +740,7 @@ FLAGS: SECONDARY_SYNTAX
 # lvconvert --repair-cachepool LV_cachepool
 # DESC: Repair a cachepool.
 #
-# lvm may want to do different things, or allow different options 
+# lvm may want to do different things, or allow different options
 # depending on which operation is being run, but as it stands, it
 # cannot do anything operation-specific until after the VG is read
 # and the LV type is known.
@@ -806,7 +806,7 @@ OO_LVCREATE_CACHE: --cachemode CacheMode, --cachepolicy String, --cachesettings
 
 OO_LVCREATE_POOL: --poolmetadatasize SizeMB, --poolmetadataspare Bool, --chunksize SizeKB
 
-OO_LVCREATE_THIN: --discards Discards, --errorwhenfull Bool
+OO_LVCREATE_THINPOOL: --discards Discards, --errorwhenfull Bool
 
 OO_LVCREATE_VDO: --compression Bool, --deduplication Bool
 ---
@@ -867,7 +867,7 @@ DESC: Create a linear LV.
 # R12. c,d,e: raid10 with specified stripes and mirrors
 #
 # R13. d:     striped with specified stripes
-# R14. e:     mirror with specified mirrors   
+# R14. e:     mirror with specified mirrors
 # R15. d,e:   raid10 with specified mirrors
 
 # R1,R2 (--type striped with or without --stripes)
@@ -880,15 +880,15 @@ FLAGS: SECONDARY_SYNTAX
 
 # R13 (just --stripes)
 lvcreate --stripes Number --size SizeMB VG
-OO: --stripesize SizeKB, OO_LVCREATE
+OO: --stripesize SizeKB, --type striped, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_striped
 DESC: Create a striped LV (infers --type striped).
 
 # R5,R7 (--type mirror with or without --mirrors)
 lvcreate --type mirror --size SizeMB VG
-OO: --mirrors PNumber, --mirrorlog MirrorLog, --regionsize RegionSize,
---stripes Number, --stripesize SizeKB, OO_LVCREATE
+OO: --stripes Number, --stripesize SizeKB,
+--mirrors PNumber, --mirrorlog MirrorLog, --regionsize RegionSize, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_mirror
 DESC: Create a mirror LV (also see --type raid1).
@@ -897,15 +897,16 @@ FLAGS: SECONDARY_SYNTAX
 # R14 (just --mirrors)
 # alternate form of lvcreate --type raid1|mirror
 lvcreate --mirrors PNumber --size SizeMB VG
-OO: --mirrorlog MirrorLog, --regionsize RegionSize, --minrecoveryrate SizeKB, --maxrecoveryrate SizeKB, OO_LVCREATE
+OO: --stripes Number, --stripesize SizeKB,
+--mirrorlog MirrorLog, --regionsize RegionSize, --minrecoveryrate SizeKB, --maxrecoveryrate SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_mirror_or_raid1
 DESC: Create a raid1 or mirror LV (infers --type raid1|mirror).
 
 # R9,R10,R11,R12 (--type raid with any use of --stripes/--mirrors)
 lvcreate --type raid --size SizeMB VG
-OO: --mirrors PNumber, --stripes Number, --stripesize SizeKB,
---regionsize RegionSize, --minrecoveryrate SizeKB, --maxrecoveryrate SizeKB,
+OO: --stripes Number, --stripesize SizeKB,
+--mirrors PNumber, --regionsize RegionSize, --minrecoveryrate SizeKB, --maxrecoveryrate SizeKB,
 --raidintegrity Bool, --raidintegritymode String, --raidintegrityblocksize Number, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_raid_any
@@ -953,18 +954,11 @@ DESC: Create a sparse COW snapshot LV of a virtual origin LV
 DESC: (also see --snapshot).
 FLAGS: SECONDARY_SYNTAX
 
-lvcreate --snapshot --size SizeMB --virtualsize SizeMB VG
-OO: --type snapshot, --chunksize SizeKB, OO_LVCREATE
-OP: PV ...
-ID: lvcreate_cow_snapshot_with_virtual_origin
-DESC: Create a sparse COW snapshot LV of a virtual origin LV.
-FLAGS: SECONDARY_SYNTAX
-
 ---
 
 lvcreate --type thin-pool --size SizeMB VG
-OO: --thinpool LV_new, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
---stripes Number, --stripesize SizeKB
+OO: --thinpool LV_new, --stripes Number, --stripesize SizeKB,
+--thin, OO_LVCREATE_THINPOOL, OO_LVCREATE_POOL, OO_LVCREATE
 OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thinpool
@@ -972,8 +966,8 @@ DESC: Create a thin pool.
 
 # alternate form of lvcreate --type thin-pool
 lvcreate --thin --size SizeMB VG
-OO: --type thin-pool, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
---stripes Number, --stripesize SizeKB
+OO: --stripes Number, --stripesize SizeKB,
+--type thin-pool, OO_LVCREATE_THINPOOL, OO_LVCREATE_POOL, OO_LVCREATE
 OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thinpool
@@ -982,8 +976,8 @@ FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin-pool
 lvcreate --size SizeMB --thinpool LV_new VG
-OO: --thin, --type thin-pool, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
---stripes Number, --stripesize SizeKB
+OO: --stripes Number, --stripesize SizeKB,
+--thin, --type thin-pool, OO_LVCREATE_THINPOOL, OO_LVCREATE_POOL, OO_LVCREATE
 OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thinpool
@@ -999,14 +993,16 @@ FLAGS: SECONDARY_SYNTAX
 # --type cache-pool.
 
 lvcreate --type cache-pool --size SizeMB VG
-OO: --cache, OO_LVCREATE_POOL, OO_LVCREATE_CACHE, OO_LVCREATE
+OO: --stripes Number, --stripesize SizeKB,
+--cache, OO_LVCREATE_CACHE, OO_LVCREATE_POOL, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_cachepool
 DESC: Create a cache pool.
 
 # alternate form of lvcreate --type cache-pool
 lvcreate --type cache-pool --size SizeMB --cachepool LV_new VG
-OO: --cache, OO_LVCREATE_POOL, OO_LVCREATE_CACHE, OO_LVCREATE
+OO: --stripes Number, --stripesize SizeKB,
+--cache, OO_LVCREATE_CACHE, OO_LVCREATE_POOL, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_cachepool
 DESC: Create a cache pool named by the --cachepool arg
@@ -1016,7 +1012,7 @@ FLAGS: SECONDARY_SYNTAX
 ---
 
 lvcreate --type thin --virtualsize SizeMB --thinpool LV_thinpool VG
-OO: --thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE
+OO: --thin, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_vol
 DESC: Create a thin LV in a thin pool.
@@ -1024,7 +1020,7 @@ FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin
 lvcreate --type thin --virtualsize SizeMB LV_thinpool
-OO: --thin, OO_LVCREATE_THIN, OO_LVCREATE
+OO: --thin, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_vol
 DESC: Create a thin LV in a thin pool named in the first arg
@@ -1036,14 +1032,14 @@ FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin
 lvcreate --virtualsize SizeMB --thinpool LV_thinpool VG
-OO: --type thin, --thin, OO_LVCREATE_THIN, OO_LVCREATE
+OO: --type thin, --thin, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_vol
 DESC: Create a thin LV in a thin pool (infers --type thin).
 
 # alternate form of lvcreate --type thin
 lvcreate --virtualsize SizeMB LV_thinpool
-OO: --type thin, --thin, OO_LVCREATE_THIN, OO_LVCREATE
+OO: --type thin, --thin, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_vol
 DESC: Create a thin LV in the thin pool named in the first arg
@@ -1054,7 +1050,7 @@ FLAGS: SECONDARY_SYNTAX
 ---
 
 lvcreate --type thin LV_thin
-OO: --thin, OO_LVCREATE_THIN, OO_LVCREATE
+OO: --thin, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_snapshot
 DESC: Create a thin LV that is a snapshot of an existing thin LV.
@@ -1062,7 +1058,7 @@ FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin
 lvcreate --thin LV_thin
-OO: --type thin, OO_LVCREATE_THIN, OO_LVCREATE
+OO: --type thin, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_snapshot
 DESC: Create a thin LV that is a snapshot of an existing thin LV
@@ -1071,21 +1067,21 @@ FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin
 lvcreate --snapshot LV_thin
-OO: --type thin, OO_LVCREATE_THIN, OO_LVCREATE
+OO: --type thin, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_snapshot
 DESC: Create a thin LV that is a snapshot of an existing thin LV
 DESC: (infers --type thin).
 
 lvcreate --type thin --thinpool LV_thinpool LV
-OO: --thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE
+OO: --thin, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_snapshot_of_external
 DESC: Create a thin LV that is a snapshot of an external origin LV.
 
 # alternate form of lvcreate --type thin --thinpool LV_thinpool LV
 lvcreate --snapshot --thinpool LV_thinpool LV
-OO: --type thin, OO_LVCREATE_THIN, OO_LVCREATE
+OO: --type thin, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_snapshot_of_external
 DESC: Create a thin LV that is a snapshot of an external origin LV
@@ -1095,16 +1091,16 @@ FLAGS: SECONDARY_SYNTAX
 ---
 
 lvcreate --type vdo --size SizeMB VG
-OO: --vdo, --vdopool LV_new, OO_LVCREATE, OO_LVCREATE_VDO,
---virtualsize SizeMB, --stripes Number, --stripesize SizeKB,
+OO: --stripes Number, --stripesize SizeKB,
+--vdo, --virtualsize SizeMB, --vdopool LV_new, OO_LVCREATE_VDO, OO_LVCREATE
 OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_vdo_vol
 DESC: Create a LV that returns VDO when used.
 
 lvcreate --vdo --size SizeMB VG
-OO: --vdopool LV_new, OO_LVCREATE, OO_LVCREATE_VDO,
---virtualsize SizeMB, --stripes Number, --stripesize SizeKB
+OO: --stripes Number, --stripesize SizeKB,
+--type vdo, --virtualsize SizeMB, --vdopool LV_new, OO_LVCREATE_VDO, OO_LVCREATE
 OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_vdo_vol
@@ -1112,8 +1108,8 @@ DESC: Create a VDO LV with VDO pool.
 FLAGS: SECONDARY_SYNTAX
 
 lvcreate --vdopool LV_new --size SizeMB VG
-OO: --vdo, --type vdo, OO_LVCREATE, OO_LVCREATE_VDO,
---virtualsize SizeMB, --stripes Number, --stripesize SizeKB
+OO: --stripes Number, --stripesize SizeKB,
+--vdo, --type vdo, --virtualsize SizeMB, OO_LVCREATE_VDO, OO_LVCREATE
 OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_vdo_vol
@@ -1138,32 +1134,20 @@ FLAGS: SECONDARY_SYNTAX
 # definition.  Note that when LV_new is used in arg pos 1,
 # it needs to include a VG name, i.e. VG/LV_new
 
-lvcreate --type thin --virtualsize SizeMB --size SizeMB --thinpool LV_new
-OO: --thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
---stripes Number, --stripesize SizeKB
+lvcreate --type thin --virtualsize SizeMB --size SizeMB --thinpool LV_new VG
+OO: --stripes Number, --stripesize SizeKB,
+--thin, OO_LVCREATE_THINPOOL, OO_LVCREATE_POOL, OO_LVCREATE
 OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thin_vol_and_thinpool
 DESC: Create a thin LV, first creating a thin pool for it,
 DESC: where the new thin pool is named by the --thinpool arg.
-
-# alternate form of lvcreate --type thin
-lvcreate --virtualsize SizeMB --size SizeMB --thinpool LV_new
-OO: --thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
---stripes Number, --stripesize SizeKB
-OP: PV ...
-IO: --mirrors 0
-ID: lvcreate_thin_vol_and_thinpool
-DESC: Create a thin LV, first creating a thin pool for it,
-DESC: where the new thin pool is named by the --thinpool arg
-DESC: (variant, infers --type thin).
 FLAGS: SECONDARY_SYNTAX
 
-# same as prev but accepts VG pos arg
 # alternate form of lvcreate --type thin
 lvcreate --virtualsize SizeMB --size SizeMB --thinpool LV_new VG
-OO: --thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
---stripes Number, --stripesize SizeKB
+OO: --stripes Number, --stripesize SizeKB,
+--type thin, --thin, OO_LVCREATE_THINPOOL, OO_LVCREATE_POOL, OO_LVCREATE
 OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thin_vol_and_thinpool
@@ -1174,8 +1158,8 @@ FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin
 lvcreate --type thin --virtualsize SizeMB --size SizeMB LV_new|VG
-OO: --thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
---stripes Number, --stripesize SizeKB
+OO: --stripes Number, --stripesize SizeKB,
+--thin, OO_LVCREATE_THINPOOL, OO_LVCREATE_POOL, OO_LVCREATE
 OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thin_vol_and_thinpool
@@ -1187,8 +1171,8 @@ FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin
 lvcreate --thin --virtualsize SizeMB --size SizeMB LV_new|VG
-OO: OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
---stripes Number, --stripesize SizeKB
+OO: --stripes Number, --stripesize SizeKB,
+--type thin, OO_LVCREATE_THINPOOL, OO_LVCREATE_POOL, OO_LVCREATE
 OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thin_vol_and_thinpool
@@ -1201,8 +1185,9 @@ FLAGS: SECONDARY_SYNTAX
 ---
 
 lvcreate --size SizeMB --virtualsize SizeMB VG
-OO: --type snapshot, --snapshot, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
---stripes Number, --stripesize SizeKB
+OO: --stripes Number, --stripesize SizeKB,
+--type String, --snapshot, --thin,
+OO_LVCREATE_THINPOOL, OO_LVCREATE_POOL, OO_LVCREATE
 OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thin_vol_with_thinpool_or_sparse_snapshot
@@ -1221,8 +1206,8 @@ FLAGS: SECONDARY_SYNTAX
 # is used to create the cache LV
 
 lvcreate --type cache --size SizeMB --cachepool LV_cachepool VG
-OO: --cache, OO_LVCREATE_POOL, OO_LVCREATE_CACHE, OO_LVCREATE,
---stripes Number, --stripesize SizeKB
+OO: --stripes Number, --stripesize SizeKB,
+--cache, OO_LVCREATE_CACHE, OO_LVCREATE_POOL, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_and_attach_cachepool
 DESC: Create a new LV, then attach the specified cachepool
@@ -1231,8 +1216,8 @@ DESC: which converts the new LV to type cache.
 # alternate form of lvcreate --type cache
 # (omits the --type cache option which is inferred)
 lvcreate --size SizeMB --cachepool LV_cachepool VG
-OO: --type cache, --cache, OO_LVCREATE_CACHE, OO_LVCREATE,
---stripes Number, --stripesize SizeKB
+OO: --stripes Number, --stripesize SizeKB,
+--cache, --type cache, OO_LVCREATE_CACHE, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_and_attach_cachepool_v2
 DESC: Create a new LV, then attach the specified cachepool
@@ -1244,8 +1229,8 @@ FLAGS: SECONDARY_SYNTAX
 # (moves cachepool from option arg to position arg,
 # dropping the normal VG position arg)
 lvcreate --type cache --size SizeMB LV_cachepool
-OO: --cache, OO_LVCREATE_POOL, OO_LVCREATE_CACHE, OO_LVCREATE,
---stripes Number, --stripesize SizeKB
+OO: --stripes Number, --stripesize SizeKB,
+--cache, OO_LVCREATE_CACHE, OO_LVCREATE_POOL, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_and_attach_cachepool_v3
 DESC: Create a new LV, then attach the specified cachepool
@@ -1275,7 +1260,7 @@ FLAGS: SECONDARY_SYNTAX
 # the LV type is known.
 
 lvcreate --cache --size SizeMB LV
-OO: OO_LVCREATE_CACHE, OO_LVCREATE_POOL, OO_LVCREATE,
+OO: --type cache, OO_LVCREATE_CACHE, OO_LVCREATE_POOL, OO_LVCREATE,
 --stripes Number, --stripesize SizeKB
 OP: PV ...
 ID: lvcreate_new_plus_old_cachepool_or_lvconvert_old_plus_new_cachepool
@@ -1294,14 +1279,15 @@ FLAGS: SECONDARY_SYNTAX
 # the new LV to type cache or writecache.
 
 lvcreate --type cache --size SizeMB --cachevol LV VG
-OO: OO_LVCREATE, OO_LVCREATE_CACHE, --stripes Number, --stripesize SizeKB
+OO: --stripes Number, --stripesize SizeKB, OO_LVCREATE_CACHE, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_and_attach_cachevol_for_cache
 DESC: Create a new LV, then attach the specified cachevol
 DESC: which converts the new LV to type cache.
 
 lvcreate --type cache --size SizeMB --cachedevice PV VG
-OO: OO_LVCREATE, OO_LVCREATE_CACHE, --cachesize SizeMB, --stripes Number, --stripesize SizeKB
+OO: --stripes Number, --stripesize SizeKB,
+--cachesize SizeMB, OO_LVCREATE_CACHE, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_and_attach_cachedevice_for_cache
 DESC: Create a new LV, then attach a cachevol created from


