From: Guangliang Zhao <gzhao@suse.com>
Date: Mon, 17 Dec 2012 20:44:23 +0800
Subject: [PATCH 1/2] mirror: make mirror legs on different tag pvs
In-Reply-To: <1355748264-17077-1-git-send-email-gzhao@suse.com>
References: <1355748264-17077-1-git-send-email-gzhao@suse.com>
Message-ID: <1355748264-17077-2-git-send-email-gzhao@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The mirror legs could be placed on the PVs(with different
tags) from the other mirror legs with this patch.

The lvcreate allocates the replica "randomly" when creating
a mirrored logical volume now, so it could happen that both
copies end up on the same array (or on the same site), clearly
undesired.

We can't control the fist allocation, because didn't restrict
the areas into parallel space. This patch add the limit when
finding areas for parallel space, so that mirror legs will
always be placed on pvs with differnt tags.

Signed-off-by: Guangliang Zhao <gzhao@suse.com>
---
 doc/example.conf.in     |   17 +++++++++++++++++
 lib/config/defaults.h   |    1 +
 lib/metadata/lv_manip.c |   37 +++++++++++++++++++++++++++++++++++++
 man/lvcreate.8.in       |    3 +++
 4 files changed, 58 insertions(+)

diff --git a/doc/example.conf.in b/doc/example.conf.in
index f7344bb..57e00d6 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -224,6 +224,23 @@ allocation {
     # algorithm.
     maximise_cling = 1
 
+    # Set to 1 to guarantee that mirror leg will always be placed on
+    # different PVs(with different tags) from the other mirror legs.
+    #
+    # If you want to enable this feature, the following conditions
+    # must be met:
+    # 1) The mirror_legs_require_separate_pvs must be set to 1, the
+    #    default value is 0.
+    # 2) The cling_tag_list must be activated.
+    # 3) The length of all pvs with same tag must greater than or equal
+    #    to the mirror's.
+
+    # This feature is only for the first allocation, on the other hand
+    # when creating new mirrored lvs.
+    # Please note that the commond may fail if the number of all tags
+    # on the pvs less than the mirror legs number.
+    mirror_legs_require_separate_pvs = 0
+
     # Set to 1 to guarantee that mirror logs will always be placed on 
     # different PVs from the mirror images.  This was the default
     # until version 2.02.85.
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 9730a2d..d08d004 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -98,6 +98,7 @@
 #define DEFAULT_MAX_LV 0
 #define DEFAULT_ALLOC_POLICY ALLOC_NORMAL
 #define DEFAULT_MIRROR_LOGS_REQUIRE_SEPARATE_PVS 0
+#define DEFAULT_MIRROR_LEGS_REQUIRE_SEPARATE_PVS 0
 #define DEFAULT_MAXIMISE_CLING 1
 #define DEFAULT_CLUSTERED 0
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9f87854..fb0199f 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -684,6 +684,9 @@ struct alloc_handle {
 
 	unsigned maximise_cling;
 	unsigned mirror_logs_separate;	/* Force mirror logs on separate PVs? */
+	unsigned mirror_legs_separate;	/* Force mirror *legs* on separate PVs*/
+
+	const struct segment_type *segtype;
 
 	/*
 	 * RAID devices require a metadata area that accompanies each
@@ -868,6 +871,7 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 	ah->parity_count = parity_count;
 	ah->region_size = region_size;
 	ah->alloc = alloc;
+	ah->segtype = segtype;
 
 	/*
 	 * For the purposes of allocation, area_count and parity_count are
@@ -879,6 +883,8 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 	ah->area_multiple = _calc_area_multiple(segtype, area_count + parity_count, stripes);
 	ah->mirror_logs_separate = find_config_tree_bool(cmd, "allocation/mirror_logs_require_separate_pvs",
 							 DEFAULT_MIRROR_LOGS_REQUIRE_SEPARATE_PVS);
+	ah->mirror_legs_separate = find_config_tree_bool(cmd, "allocation/mirror_legs_require_separate_pvs",
+							 DEFAULT_MIRROR_LEGS_REQUIRE_SEPARATE_PVS);
 
 	if (segtype_is_raid(segtype)) {
 		if (metadata_area_count) {
@@ -1725,6 +1731,33 @@ static void _report_needed_allocation_space(struct alloc_handle *ah,
 	log_debug("  %" PRIu32 " %ss of %" PRIu32 " extents each",
 		  metadata_count, metadata_type, metadata_size);
 }
+
+/*
+ * Return -1 if we don't need check tags, or there aren't any areas in alloc_status
+ * have the same tag with pva, the index otherwise.
+ */
+static int check_areas_separate_tags(struct alloc_handle *ah,
+				     struct alloc_state *alloc_state,
+				     unsigned ix_start,
+				     unsigned ix_end,
+				     struct pv_area *pva)
+{
+	int i;
+
+	if (!segtype_is_mirrored(ah->segtype) ||
+			alloc_state->allocated ||
+			!ah->mirror_legs_separate ||
+			!ah->cling_tag_list_cn)
+		return -1;
+
+	for (i = ix_start; i < ix_end; i++)
+		if(_pvs_have_matching_tag(ah->cling_tag_list_cn,
+					alloc_state->areas[i].pva->map->pv,
+					pva->map->pv))
+			return i;
+	return -1;
+}
+
 /*
  * Returns 1 regardless of whether any space was found, except on error.
  */
@@ -1842,6 +1875,10 @@ static int _find_some_parallel_space(struct alloc_handle *ah, const struct alloc
 					continue;
 
 				case USE_AREA:
+					if(check_areas_separate_tags(ah, alloc_state, ix_offset,
+								     ix + ix_offset, pva) >= 0)
+						goto next_pv;
+
 					/*
 					 * Except with ALLOC_ANYWHERE, replace first area with this
 					 * one which is smaller but still big enough.
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index f374950..d7355b9 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -205,6 +205,9 @@ will create a persistent log that is itself mirrored.
 
 The optional argument --corelog is equivalent to --mirrorlog core.
 
+Every leg of the mirrored logical volume could be placed on the pvs with
+same tag, see details(mirror_legs_require_separate_pvs) in lvm.conf.
+
 .TP
 .IR \fB\-n ", " \fB\-\-name " " LogicalVolume { Name | Path }
 The name for the new logical volume.
-- 
1.7.10.4


