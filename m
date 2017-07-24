From: David Teigland <teigland@sourceware.org>
Date: Mon, 24 Jul 2017 16:12:15 -0400
Subject: master - man: remove hyphen escapes from source
Message-ID: <201707242012.v6OKCFIq004033@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2938fa541aa66da66e32b9ea4b796dbedcf5062e
Commit:        2938fa541aa66da66e32b9ea4b796dbedcf5062e
Parent:        1460cac27391ace1047588bb915d2734e4703fa6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jul 20 16:26:13 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 24 14:12:08 2017 -0500

man: remove hyphen escapes from source

they are escaped by running sed in makefile
---
 tools/command-lines.in |   86 ++++++++++++++++++++++++------------------------
 1 files changed, 43 insertions(+), 43 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index f2ad915..6e9192e 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -338,7 +338,7 @@ OO: --mirrors SNumber, --regionsize RegionSize, --interval Number, --mirrorlog M
 OP: PV ...
 ID: lvconvert_raid_types
 DESC: Convert LV to type mirror (also see type raid1),
-DESC: (also see lvconvert \\-\\-mirrors).
+DESC: (also see lvconvert --mirrors).
 RULE: all not lv_is_locked lv_is_pvmove
 FLAGS: SECONDARY_SYNTAX
 
@@ -434,7 +434,7 @@ lvconvert --thin --thinpool LV LV_linear_striped_raid_cache
 OO: --type thin, --originname LV_new, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_thin_with_external
 DESC: Convert LV to a thin LV, using the original LV as an external origin
-DESC: (infers \\-\\-type thin).
+DESC: (infers --type thin).
 FLAGS: SECONDARY_SYNTAX
 RULE: all and lv_is_visible
 RULE: all not lv_is_locked
@@ -453,7 +453,7 @@ RULE: --poolmetadata not --readahead --stripesize --stripes_long
 lvconvert --cache --cachepool LV LV_linear_striped_raid_thinpool
 OO: --type cache, OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_cache_vol
-DESC: Convert LV to type cache (infers \\-\\-type cache).
+DESC: Convert LV to type cache (infers --type cache).
 RULE: all and lv_is_visible
 RULE: --poolmetadata not --readahead --stripesize --stripes_long
 FLAGS: SECONDARY_SYNTAX
@@ -497,8 +497,8 @@ OO: --type thin-pool, --stripes_long Number, --stripesize SizeKB,
 --discards Discards, OO_LVCONVERT_POOL, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_to_thinpool_or_swap_metadata
-DESC: Convert LV to type thin-pool (variant, use \\-\\-type thin-pool).
-DESC: Swap metadata LV in a thin pool (variant, use \\-\\-swapmetadata).
+DESC: Convert LV to type thin-pool (variant, use --type thin-pool).
+DESC: Swap metadata LV in a thin pool (variant, use --swapmetadata).
 FLAGS: PREVIOUS_SYNTAX
 RULE: all and lv_is_visible
 RULE: --poolmetadata not --readahead --stripesize --stripes_long
@@ -538,8 +538,8 @@ lvconvert --cachepool LV_linear_striped_raid_cachepool
 OO: --type cache-pool, OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_to_cachepool_or_swap_metadata
-DESC: Convert LV to type cache-pool (variant, use \\-\\-type cache-pool).
-DESC: Swap metadata LV in a cache pool (variant, use \\-\\-swapmetadata).
+DESC: Convert LV to type cache-pool (variant, use --type cache-pool).
+DESC: Swap metadata LV in a cache pool (variant, use --swapmetadata).
 FLAGS: PREVIOUS_SYNTAX
 RULE: all and lv_is_visible
 RULE: --poolmetadata not --readahead --stripesize --stripes_long
@@ -579,9 +579,9 @@ FLAGS: SECONDARY_SYNTAX
 lvconvert --merge LV_linear_striped_raid_thin_snapshot|VG|Tag ...
 OO: --background, --interval Number, OO_LVCONVERT
 ID: lvconvert_merge
-DESC: Merge LV that was split from a mirror (variant, use \\-\\-mergemirrors).
-DESC: Merge thin LV into its origin LV (variant, use \\-\\-mergethin).
-DESC: Merge COW snapshot LV into its origin (variant, use \\-\\-mergesnapshot).
+DESC: Merge LV that was split from a mirror (variant, use --mergemirrors).
+DESC: Merge thin LV into its origin LV (variant, use --mergethin).
+DESC: Merge COW snapshot LV into its origin (variant, use --mergesnapshot).
 RULE: all not lv_is_locked lv_is_pvmove lv_is_merging_origin lv_is_virtual_origin lv_is_external_origin lv_is_merging_cow
 FLAGS: SECONDARY_SYNTAX
 
@@ -694,7 +694,7 @@ RULE: all and lv_is_converting
 lvconvert LV_mirror_raid
 OO: OO_LVCONVERT
 ID: lvconvert_start_poll
-DESC: Poll LV to continue conversion (also see \\-\\-startpoll).
+DESC: Poll LV to continue conversion (also see --startpoll).
 RULE: all and lv_is_converting
 FLAGS: SECONDARY_SYNTAX
 
@@ -782,7 +782,7 @@ lvcreate --type striped --size SizeMB VG
 OO: --stripes Number, --stripesize SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_striped
-DESC: Create a striped LV (also see lvcreate \\-\\-stripes).
+DESC: Create a striped LV (also see lvcreate --stripes).
 FLAGS: SECONDARY_SYNTAX
 
 # R13 (just --stripes)
@@ -790,7 +790,7 @@ lvcreate --stripes Number --size SizeMB VG
 OO: --stripesize SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_striped
-DESC: Create a striped LV (infers \\-\\-type striped).
+DESC: Create a striped LV (infers --type striped).
 
 # R5,R7 (--type mirror with or without --mirrors)
 lvcreate --type mirror --size SizeMB VG
@@ -798,7 +798,7 @@ OO: --mirrors PNumber, --mirrorlog MirrorLog, --regionsize RegionSize,
 --stripes Number, --stripesize SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_mirror
-DESC: Create a mirror LV (also see \\-\\-type raid1).
+DESC: Create a mirror LV (also see --type raid1).
 FLAGS: SECONDARY_SYNTAX
 
 # R14 (just --mirrors)
@@ -807,7 +807,7 @@ lvcreate --mirrors PNumber --size SizeMB VG
 OO: --mirrorlog MirrorLog, --regionsize RegionSize, --minrecoveryrate SizeKB, --maxrecoveryrate SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_mirror_or_raid1
-DESC: Create a raid1 or mirror LV (infers \\-\\-type raid1|mirror).
+DESC: Create a raid1 or mirror LV (infers --type raid1|mirror).
 
 # R9,R10,R11,R12 (--type raid with any use of --stripes/--mirrors)
 lvcreate --type raid --size SizeMB VG
@@ -838,7 +838,7 @@ OO: --snapshot, --stripes Number, --stripesize SizeKB,
 OP: PV ...
 ID: lvcreate_cow_snapshot
 DESC: Create a COW snapshot LV of an origin LV
-DESC: (also see \\-\\-snapshot).
+DESC: (also see --snapshot).
 FLAGS: SECONDARY_SYNTAX
 
 lvcreate --snapshot --size SizeMB LV
@@ -856,7 +856,7 @@ OO: --snapshot, --chunksize SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_cow_snapshot_with_virtual_origin
 DESC: Create a sparse COW snapshot LV of a virtual origin LV
-DESC: (also see \\-\\-snapshot).
+DESC: (also see --snapshot).
 FLAGS: SECONDARY_SYNTAX
 
 lvcreate --snapshot --size SizeMB --virtualsize SizeMB VG
@@ -883,7 +883,7 @@ OO: --type thin-pool, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
 OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thinpool
-DESC: Create a thin pool (infers \\-\\-type thin-pool).
+DESC: Create a thin pool (infers --type thin-pool).
 FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin-pool
@@ -893,8 +893,8 @@ OO: --thin, --type thin-pool, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
 OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thinpool
-DESC: Create a thin pool named by the \\-\\-thinpool arg
-DESC: (infers \\-\\-type thin-pool).
+DESC: Create a thin pool named by the --thinpool arg
+DESC: (infers --type thin-pool).
 FLAGS: SECONDARY_SYNTAX
 
 ---
@@ -915,8 +915,8 @@ lvcreate --type cache-pool --size SizeMB --cachepool LV_new VG
 OO: --cache, OO_LVCREATE_POOL, OO_LVCREATE_CACHE, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_cachepool
-DESC: Create a cache pool named by the \\-\\-cachepool arg
-DESC: (variant, uses \\-\\-cachepool in place of \\-\\-name).
+DESC: Create a cache pool named by the --cachepool arg
+DESC: (variant, uses --cachepool in place of --name).
 FLAGS: SECONDARY_SYNTAX
 
 ---
@@ -934,7 +934,7 @@ OO: --thin, OO_LVCREATE_THIN, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_vol
 DESC: Create a thin LV in a thin pool named in the first arg
-DESC: (variant, also see \\-\\-thinpool for naming pool).
+DESC: (variant, also see --thinpool for naming pool).
 FLAGS: SECONDARY_SYNTAX
 
 # NB. this is the variant which can substitute
@@ -945,7 +945,7 @@ lvcreate --virtualsize SizeMB --thinpool LV_thinpool VG
 OO: --type thin, --thin, OO_LVCREATE_THIN, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_vol
-DESC: Create a thin LV in a thin pool (infers \\-\\-type thin).
+DESC: Create a thin LV in a thin pool (infers --type thin).
 
 # alternate form of lvcreate --type thin
 lvcreate --virtualsize SizeMB LV_thinpool
@@ -953,7 +953,7 @@ OO: --type thin, --thin, OO_LVCREATE_THIN, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_vol
 DESC: Create a thin LV in the thin pool named in the first arg
-DESC: (variant, infers \\-\\-type thin, also see \\-\\-thinpool for
+DESC: (variant, infers --type thin, also see --thinpool for
 DESC: naming pool.)
 FLAGS: SECONDARY_SYNTAX
 
@@ -972,7 +972,7 @@ OO: --type thin, OO_LVCREATE_THIN, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_snapshot
 DESC: Create a thin LV that is a snapshot of an existing thin LV
-DESC: (infers \\-\\-type thin).
+DESC: (infers --type thin).
 FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin
@@ -981,7 +981,7 @@ OO: --type thin, OO_LVCREATE_THIN, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_snapshot
 DESC: Create a thin LV that is a snapshot of an existing thin LV
-DESC: (infers \\-\\-type thin).
+DESC: (infers --type thin).
 
 lvcreate --type thin --thinpool LV_thinpool LV
 OO: --thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE
@@ -995,7 +995,7 @@ OO: --type thin, OO_LVCREATE_THIN, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_snapshot_of_external
 DESC: Create a thin LV that is a snapshot of an external origin LV
-DESC: (infers \\-\\-type thin).
+DESC: (infers --type thin).
 FLAGS: SECONDARY_SYNTAX
 
 ---
@@ -1023,7 +1023,7 @@ OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thin_vol_and_thinpool
 DESC: Create a thin LV, first creating a thin pool for it,
-DESC: where the new thin pool is named by the \\-\\-thinpool arg.
+DESC: where the new thin pool is named by the --thinpool arg.
 
 # alternate form of lvcreate --type thin
 lvcreate --virtualsize SizeMB --size SizeMB --thinpool LV_new
@@ -1033,8 +1033,8 @@ OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thin_vol_and_thinpool
 DESC: Create a thin LV, first creating a thin pool for it,
-DESC: where the new thin pool is named by the \\-\\-thinpool arg
-DESC: (variant, infers \\-\\-type thin).
+DESC: where the new thin pool is named by the --thinpool arg
+DESC: (variant, infers --type thin).
 FLAGS: SECONDARY_SYNTAX
 
 # same as prev but accepts VG pos arg
@@ -1046,8 +1046,8 @@ OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thin_vol_and_thinpool
 DESC: Create a thin LV, first creating a thin pool for it,
-DESC: where the new thin pool is named by the \\-\\-thinpool arg
-DESC: (variant, infers \\-\\-type thin).
+DESC: where the new thin pool is named by the --thinpool arg
+DESC: (variant, infers --type thin).
 FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin
@@ -1073,7 +1073,7 @@ ID: lvcreate_thin_vol_and_thinpool
 DESC: Create a thin LV, first creating a thin pool for it,
 DESC: where the new thin pool is named in the first arg,
 DESC: or the new thin pool name is generated when the first
-DESC: arg is a VG name (variant, infers \\-\\-type thin).
+DESC: arg is a VG name (variant, infers --type thin).
 FLAGS: SECONDARY_SYNTAX
 
 ---
@@ -1085,10 +1085,10 @@ OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thin_vol_with_thinpool_or_sparse_snapshot
 DESC: Create a thin LV, first creating a thin pool for it
-DESC: (infers \\-\\-type thin).
+DESC: (infers --type thin).
 DESC: Create a sparse snapshot of a virtual origin LV
-DESC: (infers \\-\\-type snapshot).
-DESC: Chooses \\-\\-type thin or \\-\\-type snapshot according to
+DESC: (infers --type snapshot).
+DESC: Chooses --type thin or --type snapshot according to
 DESC: config setting sparse_segtype_default.
 FLAGS: SECONDARY_SYNTAX
 
@@ -1105,7 +1105,7 @@ OP: PV ...
 ID: lvcreate_cache_vol_with_new_origin
 DESC: Create a cache LV, first creating a new origin LV,
 DESC: then combining it with the existing cache pool named
-DESC: by the \\-\\-cachepool arg.
+DESC: by the --cachepool arg.
 
 # alternate form of lvcreate --type cache
 lvcreate --size SizeMB --cachepool LV_cachepool VG
@@ -1115,7 +1115,7 @@ OP: PV ...
 ID: lvcreate_cache_vol_with_new_origin
 DESC: Create a cache LV, first creating a new origin LV,
 DESC: then combining it with the existing cache pool named
-DESC: by the \\-\\-cachepool arg (variant, infers \\-\\-type cache).
+DESC: by the --cachepool arg (variant, infers --type cache).
 FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type cache
@@ -1126,7 +1126,7 @@ OP: PV ...
 ID: lvcreate_cache_vol_with_new_origin
 DESC: Create a cache LV, first creating a new origin LV,
 DESC: then combining it with the existing cache pool named
-DESC: in the first arg (variant, also use \\-\\-cachepool).
+DESC: in the first arg (variant, also use --cachepool).
 FLAGS: SECONDARY_SYNTAX
 
 # This is a ridiculously crazy command which nobody could
@@ -1144,8 +1144,8 @@ FLAGS: SECONDARY_SYNTAX
 # ID: lvcreate_cache_vol_with_new_origin
 # DESC: Create a cache LV, first creating a new origin LV,
 # DESC: then combining it with the existing cache pool named
-# DESC: in the first arg (variant, infers \\-\\-type cache,
-# DESC: also use \\-\\-cachepool).
+# DESC: in the first arg (variant, infers --type cache,
+# DESC: also use --cachepool).
 #
 # 2. If LV is not a cachepool, then it's a disguised lvconvert.
 #
@@ -1175,7 +1175,7 @@ ID: lvcreate_cache_vol_with_new_origin_or_convert_to_cache_vol_with_cachepool
 DESC: When LV is a cache pool, create a cache LV,
 DESC: first creating a new origin LV, then combining it with
 DESC: the existing cache pool named in the first arg
-DESC: (variant, infers \\-\\-type cache, also use \\-\\-cachepool).
+DESC: (variant, infers --type cache, also use --cachepool).
 DESC: When LV is not a cache pool, convert the specified LV
 DESC: to type cache after creating a new cache pool LV to use
 DESC: (use lvconvert).


