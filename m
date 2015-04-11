From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 11 Apr 2015 01:02:41 +0000 (UTC)
Subject: master - alloc: Respect cling_tag_list in contig alloc.
Message-ID: <20150411010241.D33B6606D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cc26085b62d8cad265fca86426c65c88491a7473
Commit:        cc26085b62d8cad265fca86426c65c88491a7473
Parent:        b851b74cba6dd8d1c2c831d5e3d2662734f987e8
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Apr 11 01:55:24 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Apr 11 01:55:24 2015 +0100

alloc: Respect cling_tag_list in contig alloc.

When performing initial allocation (so there is nothing yet to
cling to), use the list of tags in allocation/cling_tag_list to
partition the PVs.  We implement this by maintaining a list of
tags that have been "used up" as we proceed and ignoring further
devices that have a tag on the list.

https://bugzilla.redhat.com/983600
---
 WHATS_NEW                     |    1 +
 lib/format_text/format-text.c |    2 +-
 lib/metadata/lv_manip.c       |   80 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 82 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 164fe5a..b67635c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.119 - 
 ==================================
+  Respect allocation/cling_tag_list during intial contiguous allocation.
   Add A_PARTITION_BY_TAGS set when allocated areas should not share tags.
   Set correct vgid when updating cache when writing PV metadata.
   More efficient clvmd singlenode locking emulation.
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 8e5578c..759ad89 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1333,7 +1333,7 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 	/* Add a new cache entry with PV info or update existing one. */
 	if (!(info = lvmcache_add(fmt->labeller, (const char *) &pv->id,
 				  pv->dev, pv->vg_name,
-				  is_orphan_vg(pv->vg_name) ? pv->vg_name : pv->vg ? &pv->vg->id : NULL, 0)))
+				  is_orphan_vg(pv->vg_name) ? pv->vg_name : pv->vg ? (const char *) &pv->vg->id : NULL, 0)))
 		return_0;
 
 	label = lvmcache_get_label(info);
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index ef69e0e..85f727f 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2125,6 +2125,17 @@ static const char *_tags_list_str(struct alloc_handle *ah, struct physical_volum
 }
 
 /*
+ * Does PV area have a tag listed in allocation/cling_tag_list that
+ * matches a tag in the pv_tags list?
+ */
+static int _pv_has_matching_tag(const struct dm_config_node *cling_tag_list_cn,
+				struct physical_volume *pv1, uint32_t pv1_start_pe, uint32_t area_num,
+				struct dm_list *pv_tags)
+{
+	return _match_pv_tags(cling_tag_list_cn, pv1, pv1_start_pe, area_num, NULL, pv_tags, 0, NULL, NULL);
+}
+
+/*
  * Does PV area have a tag listed in allocation/cling_tag_list that 
  * matches a tag of the PV of the existing segment?
  */
@@ -2501,6 +2512,38 @@ static void _report_needed_allocation_space(struct alloc_handle *ah,
 			(metadata_count == 1) ? "" : "s",
 			metadata_size);
 }
+
+/* Work through the array, removing any entries with tags already used by previous areas. */
+static int _limit_to_one_area_per_tag(struct alloc_handle *ah, struct alloc_state *alloc_state,
+				      uint32_t ix_log_offset, unsigned *ix)
+{
+	uint32_t	s = 0, u = 0;
+	DM_LIST_INIT(pv_tags);
+
+	while (s < alloc_state->areas_size && alloc_state->areas[s].pva) {
+		/* Start again with an empty tag list when we reach the log devices */
+		if (u == ix_log_offset)
+			dm_list_init(&pv_tags);
+		if (!_pv_has_matching_tag(ah->cling_tag_list_cn, alloc_state->areas[s].pva->map->pv, alloc_state->areas[s].pva->start, s, &pv_tags)) {
+			/* The comparison fn will ignore any non-cling tags so just add everything */
+			if (!str_list_add_list(ah->mem, &pv_tags, &alloc_state->areas[s].pva->map->pv->tags))
+				return_0;
+
+			if (s != u)
+				alloc_state->areas[u] = alloc_state->areas[s];
+
+			u++;
+		} else
+			(*ix)--;	/* One area removed */
+
+		s++;
+	}
+
+	alloc_state->areas[u].pva = NULL;
+
+	return 1;
+}
+
 /*
  * Returns 1 regardless of whether any space was found, except on error.
  */
@@ -2722,6 +2765,43 @@ static int _find_some_parallel_space(struct alloc_handle *ah,
 		return 1;
 
 	/*
+	 * FIXME We should change the code to do separate calls for the log allocation 
+	 * and the data allocation so that _limit_to_one_area_per_tag doesn't have to guess
+	 * where the split is going to occur.
+	 */
+
+	/*
+	 * This code covers the initial allocation - after that there is something to 'cling' to
+	 * and we shouldn't get this far.
+	 * ix_offset is assumed to be 0 with A_PARTITION_BY_TAGS.
+	 *
+	 * FIXME Consider a second attempt with A_PARTITION_BY_TAGS if, for example, the largest area
+	 * had all the tags set, but other areas don't.
+	 */
+	if ((alloc_parms->flags & A_PARTITION_BY_TAGS) && !ix_offset) {
+		if (!_limit_to_one_area_per_tag(ah, alloc_state, ix_log_offset, &ix))
+			return_0;
+
+		/* Recalculate log position because we might have removed some areas from consideration */
+		if (alloc_state->log_area_count_still_needed) {
+			/* How many areas are too small for the log? */
+			too_small_for_log_count = 0;
+			while (too_small_for_log_count < ix &&
+			       (*(alloc_state->areas + ix - 1 - too_small_for_log_count)).pva &&
+			       (*(alloc_state->areas + ix - 1 - too_small_for_log_count)).used < ah->log_len)
+				too_small_for_log_count++;
+			if (ix < too_small_for_log_count + ah->log_area_count)
+				return 1;
+			ix_log_offset = ix - too_small_for_log_count - ah->log_area_count;
+		}
+
+		if (ix < devices_needed +
+		    (alloc_state->log_area_count_still_needed ? alloc_state->log_area_count_still_needed +
+					    too_small_for_log_count : 0))
+			return 1;
+	}
+
+	/*
 	 * Finally add the space identified to the list of areas to be used.
 	 */
 	if (!_alloc_parallel_area(ah, max_to_allocate, alloc_state, ix_log_offset))


