From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 12:01:12 +0000 (GMT)
Subject: stable-2.02 - lvconvert: thin errorwhenfull and recalculation
Message-ID: <20210217120112.C23353896839@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7b51f39c844068e022c06b4523f220042f3bad14
Commit:        7b51f39c844068e022c06b4523f220042f3bad14
Parent:        6a1e8104f84849dc198af1be2f8d51942621a1e2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 17 00:10:32 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 11:56:12 2021 +0100

lvconvert: thin errorwhenfull and recalculation

When converting an existing LV to thin-pool,
user may now pass also '--errorwhenfull' option
like with 'lvcreate'.

Also recalculate chunksize when performace profile is
used with conversion (again matching lvcreate).

Adds missing flagging for uncropped metadata sizes.
---
 tools/command-lines.in |  6 ++++--
 tools/lvconvert.c      | 13 +++++++++++++
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 342b43cc4..c7fe577ab 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -309,6 +309,8 @@ OO_LVCONVERT_POOL: --poolmetadata LV, --poolmetadatasize SizeMB,
 --poolmetadataspare Bool, --readahead Readahead, --chunksize SizeKB,
 --zero Bool, --metadataprofile String
 
+OO_LVCONVERT_THIN: --discards Discards --errorwhenfull Bool
+
 OO_LVCONVERT_CACHE: --cachemetadataformat CacheMetadataFormat,
 --cachemode CacheMode, --cachepolicy String,
 --cachesettings String, --zero Bool
@@ -461,7 +463,7 @@ FLAGS: SECONDARY_SYNTAX
 
 lvconvert --type thin-pool LV_linear_striped_raid_cache
 OO: --stripes_long Number, --stripesize SizeKB,
---discards Discards, OO_LVCONVERT_POOL, OO_LVCONVERT
+OO_LVCONVERT_THIN, OO_LVCONVERT_POOL, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_to_thinpool
 DESC: Convert LV to type thin-pool.
@@ -493,7 +495,7 @@ RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 lvconvert --thinpool LV_linear_striped_raid_cache_thinpool
 OO: --type thin-pool, --stripes_long Number, --stripesize SizeKB,
---discards Discards, OO_LVCONVERT_POOL, OO_LVCONVERT
+OO_LVCONVERT_THIN, OO_LVCONVERT_POOL, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_to_thinpool_or_swap_metadata
 DESC: Convert LV to type thin-pool (variant, use --type thin-pool).
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index b885f9241..4d2b0365d 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2940,6 +2940,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	thin_crop_metadata_t crop_metadata;
 	thin_discards_t discards;
 	thin_zero_t zero_new_blocks;
+	int error_when_full;
 	int r = 0;
 
 	/* for handling lvmlockd cases */
@@ -3313,6 +3314,18 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		seg->chunk_size = chunk_size;
 		seg->discards = discards;
 		seg->zero_new_blocks = zero_new_blocks;
+		if (crop_metadata == THIN_CROP_METADATA_NO)
+			pool_lv->status |= LV_CROP_METADATA;
+		if (!recalculate_pool_chunk_size_with_dev_hints(pool_lv, chunk_calc))
+			goto_bad;
+
+		/* Error when full */
+		if (arg_is_set(cmd, errorwhenfull_ARG))
+			error_when_full = arg_uint_value(cmd, errorwhenfull_ARG, 0);
+		else
+			error_when_full = find_config_tree_bool(cmd, activation_error_when_full_CFG, vg->profile);
+		if (error_when_full)
+			pool_lv->status |= LV_ERROR_WHEN_FULL;
 	}
 
 	/*


