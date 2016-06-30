From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 30 Jun 2016 17:02:50 +0000 (UTC)
Subject: master - macros: Use is_power_of_2.
Message-ID: <20160630170250.402C56092B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aed8bc8ae7b2f1c20a84470b033daababfb7c166
Commit:        aed8bc8ae7b2f1c20a84470b033daababfb7c166
Parent:        a8e39530efdffc42d21e9bc968ab3966b719876a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jun 30 17:59:44 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jun 30 17:59:44 2016 +0100

macros: Use is_power_of_2.

---
 WHATS_NEW                       |    1 +
 lib/format_pool/import_export.c |    2 +-
 lib/metadata/lv_manip.c         |    4 ++--
 lib/metadata/thin_manip.c       |    2 +-
 lib/metadata/vg.c               |    4 ++--
 lib/thin/thin.c                 |    4 ++--
 tools/lvconvert.c               |    4 ++--
 tools/lvcreate.c                |    4 ++--
 tools/toollib.c                 |    2 +-
 9 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 619c64d..a73744e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.159 - 
 =================================
+  Introduce and use is_power_of_2 macro.
   Support conversions between striped and raid0 segment types.
   Add infrastructure for raid takeover lvconvert options.
 
diff --git a/lib/format_pool/import_export.c b/lib/format_pool/import_export.c
index 39b33ba..1529df5 100644
--- a/lib/format_pool/import_export.c
+++ b/lib/format_pool/import_export.c
@@ -181,7 +181,7 @@ static int _add_stripe_seg(struct dm_pool *mem,
 	unsigned j;
 	uint32_t area_len;
 
-	if (usp->striping & (usp->striping - 1)) {
+	if (!is_power_of_2(usp->striping)) {
 		log_error("Stripe size must be a power of 2");
 		return 0;
 	}
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index db71939..a706578 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -712,7 +712,7 @@ int get_default_region_size(struct cmd_context *cmd)
 {
 	int region_size = _get_default_region_size(cmd);
 
-	if (region_size & (region_size - 1)) {
+	if (!is_power_of_2(region_size)) {
 		region_size = _round_down_pow2(region_size);
 		log_verbose("Reducing region size to %u kiB (power of 2).",
 			    region_size / 2);
@@ -4329,7 +4329,7 @@ static int _validate_stripesize(const struct volume_group *vg,
 		lp->stripe_size = vg->extent_size;
 	}
 
-	if (lp->stripe_size & (lp->stripe_size - 1)) {
+	if (!is_power_of_2(lp->stripe_size)) {
 		log_error("Stripe size must be power of 2.");
 		return 0;
 	}
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 06d4242..3b92909 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -588,7 +588,7 @@ int update_thin_pool_params(const struct segment_type *segtype,
 		*zero = find_config_tree_bool(cmd, allocation_thin_pool_zero_CFG, profile);
 
 	if (!(attr & THIN_FEATURE_BLOCK_SIZE) &&
-	    (*chunk_size & (*chunk_size - 1))) {
+	    !is_power_of_2(*chunk_size)) {
 		log_error("Chunk size must be a power of 2 for this thin target version.");
 		return 0;
 	}
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 01dcad9..9f48a9b 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -379,7 +379,7 @@ int vg_check_new_extent_size(const struct format_type *fmt, uint32_t new_extent_
 	}
 
 	if ((fmt->features & FMT_NON_POWER2_EXTENTS)) {
-		if ((new_extent_size & (new_extent_size - 1)) &&
+		if (!is_power_of_2(new_extent_size) &&
 		    (new_extent_size % MIN_NON_POWER2_EXTENT_SIZE)) {
 			log_error("Physical Extent size must be a multiple of %s when not a power of 2.",
 				  display_size(fmt->cmd, (uint64_t) MIN_NON_POWER2_EXTENT_SIZE));
@@ -389,7 +389,7 @@ int vg_check_new_extent_size(const struct format_type *fmt, uint32_t new_extent_
 	}
 
 	/* Apply original format1 restrictions */
-	if ((new_extent_size & (new_extent_size - 1))) {
+	if (!is_power_of_2(new_extent_size)) {
 		log_error("Metadata format only supports Physical Extent sizes that are powers of 2.");
 		return 0;
 	}
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index a850757..1e29566 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -271,7 +271,7 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 	}
 
 	if (!(attr & THIN_FEATURE_BLOCK_SIZE) &&
-	    (seg->chunk_size & (seg->chunk_size - 1))) {
+	    !is_power_of_2(seg->chunk_size)) {
 		log_error("Thin pool target does not support %s chunk size (needs"
 			  " kernel >= 3.6).", display_size(cmd, seg->chunk_size));
 		return 0;
@@ -311,7 +311,7 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 		/* Use ignore for discards ignore or non-power-of-2 chunk_size and <1.5 target */
 		/* FIXME: Check whether underlying dev supports discards */
 		if (((!(attr & THIN_FEATURE_DISCARDS_NON_POWER_2) &&
-		      (seg->chunk_size & (seg->chunk_size - 1))) ||
+		      !is_power_of_2(seg->chunk_size)) ||
 		     (seg->discards == THIN_DISCARDS_IGNORE))) {
 			if (!dm_tree_node_set_thin_pool_discard(node, 1, 0))
 				return_0;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 8ceb1c7..3b98116 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -650,7 +650,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 
 		lp->chunk_size = arg_uint_value(cmd, chunksize_ARG, 8);
 		if (lp->chunk_size < 8 || lp->chunk_size > 1024 ||
-		    (lp->chunk_size & (lp->chunk_size - 1))) {
+		    !is_power_of_2(lp->chunk_size)) {
 			log_error("Chunk size must be a power of 2 in the "
 				  "range 4K to 512K");
 			return 0;
@@ -724,7 +724,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 			return 0;
 		}
 
-		if (lp->region_size & (lp->region_size - 1)) {
+		if (!is_power_of_2(lp->region_size)) {
 			log_error("Region size (%" PRIu32
 				  ") must be a power of 2", lp->region_size);
 			return 0;
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 6b99717..8db68c1 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -555,7 +555,7 @@ static int _read_mirror_and_raid_params(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (lp->region_size & (lp->region_size - 1)) {
+	if (!is_power_of_2(lp->region_size)) {
 		log_error("Region size (%" PRIu32 ") must be a power of 2",
 			  lp->region_size);
 		return 0;
@@ -1036,7 +1036,7 @@ static int _lvcreate_params(struct cmd_context *cmd,
 	if (lp->snapshot && (lp->extents || lcp->size)) {
 		lp->chunk_size = arg_uint_value(cmd, chunksize_ARG, 8);
 		if (lp->chunk_size < 8 || lp->chunk_size > 1024 ||
-		    (lp->chunk_size & (lp->chunk_size - 1))) {
+		    !is_power_of_2(lp->chunk_size)) {
 			log_error("Chunk size must be a power of 2 in the "
 				  "range 4K to 512K.");
 			return 0;
diff --git a/tools/toollib.c b/tools/toollib.c
index 35b687b..a76599c 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1294,7 +1294,7 @@ static int _validate_stripe_params(struct cmd_context *cmd, uint32_t *stripes,
 	}
 
 	if (*stripes > 1 && (*stripe_size < STRIPE_SIZE_MIN ||
-			     *stripe_size & (*stripe_size - 1))) {
+			     !is_power_of_2(*stripe_size))) {
 		log_error("Invalid stripe size %s.",
 			  display_size(cmd, (uint64_t) *stripe_size));
 		return 0;


