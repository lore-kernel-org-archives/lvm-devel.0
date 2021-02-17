From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 10:54:33 +0000 (GMT)
Subject: main - lvconvert: thin errorwhenfull and recalculation
Message-ID: <20210217105433.4FE3D3857C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=53666d6ee34260231b9589dddcdb28f77fdab506
Commit:        53666d6ee34260231b9589dddcdb28f77fdab506
Parent:        4486f08d51f4e6a6a47fa8cb484a70ca9a3ed541
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 17 00:10:32 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 11:21:35 2021 +0100

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
index c5c93abd3..7c7551405 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -318,6 +318,8 @@ OO_LVCONVERT_POOL: --poolmetadata LV, --poolmetadatasize SizeMB,
 --poolmetadataspare Bool, --readahead Readahead, --chunksize SizeKB,
 --zero Bool, --metadataprofile String
 
+OO_LVCONVERT_THIN: --discards Discards --errorwhenfull Bool
+
 OO_LVCONVERT_CACHE: --cachemetadataformat CacheMetadataFormat,
 --cachemode CacheMode, --cachepolicy String,
 --cachesettings String, --zero Bool
@@ -514,7 +516,7 @@ RULE: all and lv_is_visible
 
 lvconvert --type thin-pool LV_linear_striped_raid_cache
 OO: --stripes_long Number, --stripesize SizeKB,
---discards Discards, OO_LVCONVERT_POOL, OO_LVCONVERT
+OO_LVCONVERT_THIN, OO_LVCONVERT_POOL, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_to_thinpool
 DESC: Convert LV to type thin-pool.
@@ -546,7 +548,7 @@ RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 lvconvert --thinpool LV_linear_striped_raid_cache_thinpool
 OO: --type thin-pool, --stripes_long Number, --stripesize SizeKB,
---discards Discards, OO_LVCONVERT_POOL, OO_LVCONVERT
+OO_LVCONVERT_THIN, OO_LVCONVERT_POOL, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_to_thinpool_or_swap_metadata
 DESC: Convert LV to type thin-pool (variant, use --type thin-pool).
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 77afaf487..8df30ff02 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3054,6 +3054,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	thin_crop_metadata_t crop_metadata;
 	thin_discards_t discards;
 	thin_zero_t zero_new_blocks;
+	int error_when_full;
 	int r = 0;
 
 	/* for handling lvmlockd cases */
@@ -3428,6 +3429,18 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
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


