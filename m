From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 27 May 2016 13:47:49 +0000 (UTC)
Subject: master - lv: introduce lvseg_percent_with_info_and_seg_status
Message-ID: <20160527134749.8B5436075A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=92eba53a797a011d1ce6fbd7bef88eab41af2072
Commit:        92eba53a797a011d1ce6fbd7bef88eab41af2072
Parent:        f7f395667ee5446e9127fe772deb46f3e4f3812e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 25 16:18:38 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 27 15:47:24 2016 +0200

lv: introduce lvseg_percent_with_info_and_seg_status

Add function to obtain percentage value for cache lv_seg_status.
This API is rather evolving 'middle' step as the ultimate goal
is segment API fuctionality.

But first we need to be clear at reporting level which values
are needed to be reported for which LVs and segments.
---
 WHATS_NEW         |    1 +
 lib/metadata/lv.c |   82 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 lib/metadata/lv.h |    9 ++++++
 3 files changed, 92 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2265c9b..9f270c6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.155 - 
 ================================
+  Add lvseg_percent_with_info_and_seg_status() for percent retrieval.
   Enhance internal seg_status handling to understand snapshots better.
   When refresh failed in suspend, call resume upon error path.
   Support passthrough cache mode when waiting for clean cache.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 0a531cf..92ea3a9 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -345,6 +345,88 @@ uint64_t lvseg_size(const struct lv_segment *seg)
 	return (uint64_t) seg->len * seg->lv->vg->extent_size;
 }
 
+dm_percent_t lvseg_percent_with_info_and_seg_status(const struct lv_with_info_and_seg_status *lvdm,
+						    percent_get_t type)
+{
+	dm_percent_t p;
+	uint64_t csize;
+	const struct lv_segment *seg;
+	const struct lv_seg_status *s = &lvdm->seg_status;
+
+	/*
+	 * TODO:
+	 *   Later move to segment methods, instead of using single place.
+	 *   Also handle logic for mirror segments and it total_* summing
+	 *   Esentially rework  _target_percent API for segtype.
+	 */
+	switch (s->type) {
+	case SEG_STATUS_CACHE:
+		if (s->cache->fail || s->cache->error)
+			p = DM_PERCENT_INVALID;
+		else {
+			switch (type) {
+			case PERCENT_GET_DIRTY:
+				p = dm_make_percent(s->cache->dirty_blocks,
+						    s->cache->used_blocks);
+				break;
+			case PERCENT_GET_METADATA:
+				p = dm_make_percent(s->cache->metadata_used_blocks,
+						    s->cache->metadata_total_blocks);
+				break;
+			default:
+				p = dm_make_percent(s->cache->used_blocks,
+						    s->cache->total_blocks);
+			}
+		}
+		break;
+	case SEG_STATUS_SNAPSHOT:
+		if (s->snapshot->invalid || s->snapshot->merge_failed)
+			p = DM_PERCENT_INVALID;
+		else if (s->snapshot->has_metadata_sectors &&
+			 (s->snapshot->used_sectors == s->snapshot->metadata_sectors))
+			p = DM_PERCENT_0;
+		else
+			p = dm_make_percent(s->snapshot->used_sectors,
+					    s->snapshot->total_sectors);
+		break;
+	case SEG_STATUS_THIN_POOL:
+		if (s->thin_pool->fail || s->thin_pool->error)
+			p = DM_PERCENT_INVALID;
+		else if (type == PERCENT_GET_METADATA)
+			p = dm_make_percent(s->thin_pool->used_metadata_blocks,
+					    s->thin_pool->total_metadata_blocks);
+		else
+			p = dm_make_percent(s->thin_pool->used_data_blocks,
+					    s->thin_pool->total_data_blocks);
+		break;
+	case SEG_STATUS_THIN:
+		if (s->thin->fail || (type != PERCENT_GET_DATA))
+			/* TODO: expose highest mapped sector */
+			p = DM_PERCENT_INVALID;
+		else {
+			seg = first_seg(lvdm->lv);
+			/* Pool allocates whole chunk so round-up to nearest one */
+			csize = first_seg(seg->pool_lv)->chunk_size;
+			csize = ((seg->lv->size + csize - 1) / csize) * csize;
+			if (s->thin->mapped_sectors <= csize)
+				p = dm_make_percent(s->thin->mapped_sectors, csize);
+			else {
+				log_warn("WARNING: Thin volume %s maps %s while the size is only %s.",
+					 display_lvname(seg->lv),
+					 display_size(lvdm->lv->vg->cmd, s->thin->mapped_sectors),
+					 display_size(lvdm->lv->vg->cmd, csize));
+				/* Don't show nonsense numbers like i.e. 1000% full */
+				p = DM_PERCENT_100;
+			}
+		}
+		break;
+	default:
+		p = DM_PERCENT_INVALID;
+	}
+
+	return p;
+}
+
 uint32_t lv_kernel_read_ahead(const struct logical_volume *lv)
 {
 	struct lvinfo info;
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 08fc090..9f871d6 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -197,4 +197,13 @@ char *lv_profile_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_lock_args_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lvseg_kernel_discards_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_with_info_and_seg_status *lvdm);
 char *lv_time_dup(struct dm_pool *mem, const struct logical_volume *lv, int iso_mode);
+
+typedef enum {
+	PERCENT_GET_DATA = 0,
+	PERCENT_GET_METADATA,
+	PERCENT_GET_DIRTY
+} percent_get_t;
+dm_percent_t lvseg_percent_with_info_and_seg_status(const struct lv_with_info_and_seg_status *lvdm,
+						    percent_get_t type);
+
 #endif /* _LVM_LV_H */


