From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 10 Mar 2016 17:40:05 +0000 (UTC)
Subject: master - cache: check for cache fail during flush
Message-ID: <20160310174005.1017F60EAA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5c415afd852b6d39021f97f63401a37e6408bf70
Commit:        5c415afd852b6d39021f97f63401a37e6408bf70
Parent:        569ba79abfef9b6cfc8d7c433834df5599f3188c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 10 17:56:43 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 10 18:38:53 2016 +0100

cache: check for cache fail during flush

Just WARN if the cache can't be flushed because it's failed.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |   18 ++++++++++++------
 lib/metadata/cache_manip.c |   18 ++++++++++++++----
 lib/metadata/lv.c          |   16 +++++++++++++---
 lib/report/report.c        |   12 ++++++++++++
 5 files changed, 52 insertions(+), 13 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 04d32d6..e5b28bb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.146 - 
 =================================
+  Use new cache status info and skip flushing for failed cache.
   Support --uncache with missing PVs.
   Tidy report field names, headings and widths.
   Add vgscan --notifydbus to send a dbus notification.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 2d59cf4..8e56b7a 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1334,12 +1334,18 @@ int dev_manager_cache_status(struct dev_manager *dm,
 
 	c = (*status)->cache;
 	(*status)->mem = dm->mem; /* User has to destroy this mem pool later */
-	(*status)->data_usage = dm_make_percent(c->used_blocks,
-						c->total_blocks);
-	(*status)->metadata_usage = dm_make_percent(c->metadata_used_blocks,
-						    c->metadata_total_blocks);
-	(*status)->dirty_usage = dm_make_percent(c->dirty_blocks,
-						 c->used_blocks);
+	if (c->fail || c->error) {
+		(*status)->data_usage =
+			(*status)->metadata_usage =
+			(*status)->dirty_usage = DM_PERCENT_INVALID;
+	} else {
+		(*status)->data_usage = dm_make_percent(c->used_blocks,
+							c->total_blocks);
+		(*status)->metadata_usage = dm_make_percent(c->metadata_used_blocks,
+							    c->metadata_total_blocks);
+		(*status)->dirty_usage = dm_make_percent(c->dirty_blocks,
+							 c->used_blocks);
+	}
 	r = 1;
 out:
 	dm_task_destroy(dmt);
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 115abcb..3962247 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -359,10 +359,16 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	 */
 	if (!lv_cache_status(cache_lv, &status))
 		return_0;
-	dirty_blocks = status->cache->dirty_blocks;
-	if (!(status->cache->feature_flags & DM_CACHE_FEATURE_WRITETHROUGH))
-		dirty_blocks++; /* Not writethrough - always dirty */
-	is_cleaner = !strcmp(status->cache->policy_name, "cleaner");
+	if (!status->cache->fail) {
+		is_cleaner = !strcmp(status->cache->policy_name, "cleaner");
+		dirty_blocks = status->cache->dirty_blocks;
+		if (!(status->cache->feature_flags & DM_CACHE_FEATURE_WRITETHROUGH))
+			dirty_blocks++; /* Not writethrough - always dirty */
+	} else {
+		log_warn("WARNING: Skippping flush for failed cache.");
+		is_cleaner = 0;
+		dirty_blocks = 0;
+	}
 	dm_pool_destroy(status->mem);
 
 	if (dirty_blocks && !is_cleaner) {
@@ -378,6 +384,10 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	while (dirty_blocks) {
 		if (!lv_cache_status(cache_lv, &status))
 			return_0;
+		if (status->cache->fail) {
+			log_warn("WARNING: Flushing of failing cache skipped.");
+			break;
+		}
 		dirty_blocks = status->cache->dirty_blocks;
 		dm_pool_destroy(status->mem);
 		if (dirty_blocks) {
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 9e9549d..cb30e2d 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -1137,10 +1137,12 @@ char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_
 			}
 		}
 
-		/* 'c' when thin-pool active with needs_check flag
+		/* 'c' when cache/thin-pool is active with needs_check flag
 		 * 'C' for suspend */
-		if (lv_is_thin_pool(lv) &&
-		    lvdm->seg_status.thin_pool->needs_check)
+		if ((lv_is_thin_pool(lv) &&
+		     lvdm->seg_status.thin_pool->needs_check) ||
+		    (lv_is_cache(lv) &&
+		     lvdm->seg_status.cache->needs_check))
 			repstr[4] = lvdm->info.suspended ? 'C' : 'c';
 
 		/*
@@ -1194,6 +1196,14 @@ char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_
 				repstr[8] = 'm';  /* RAID has 'm'ismatches */
 		} else if (lv->status & LV_WRITEMOSTLY)
 			repstr[8] = 'w';  /* sub-LV has 'w'ritemostly */
+	} else if (lv_is_cache(lv) &&
+		   (lvdm->seg_status.type != SEG_STATUS_NONE)) {
+		if (lvdm->seg_status.type == SEG_STATUS_UNKNOWN)
+			repstr[8] = 'X'; /* Unknown */
+		else if (lvdm->seg_status.cache->fail)
+			repstr[8] = 'F';
+		else if (lvdm->seg_status.cache->read_only)
+			repstr[8] = 'M';
 	} else if (lv_is_thin_pool(lv) &&
 		   (lvdm->seg_status.type != SEG_STATUS_NONE)) {
 		if (lvdm->seg_status.type == SEG_STATUS_UNKNOWN)
diff --git a/lib/report/report.c b/lib/report/report.c
index 9ec3381..7070092 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3487,6 +3487,14 @@ static int _lvhealthstatus_disp(struct dm_report *rh, struct dm_pool *mem,
 				health = "mismatches exist";
 		} else if (lv->status & LV_WRITEMOSTLY)
 			health = "writemostly";
+	} else if (lv_is_cache(lv) && (lvdm->seg_status.type != SEG_STATUS_NONE)) {
+		if (lvdm->seg_status.type != SEG_STATUS_CACHE)
+			return _field_set_value(field, GET_FIRST_RESERVED_NAME(health_undef),
+						GET_FIELD_RESERVED_VALUE(health_undef));
+		else if (lvdm->seg_status.cache->fail)
+			health = "failed";
+		else if (lvdm->seg_status.cache->read_only)
+			health = "metadata_read_only";
 	} else if (lv_is_thin_pool(lv) && (lvdm->seg_status.type != SEG_STATUS_NONE)) {
 		if (lvdm->seg_status.type != SEG_STATUS_THIN_POOL)
 			return _field_set_value(field, GET_FIRST_RESERVED_NAME(health_undef),
@@ -3512,6 +3520,10 @@ static int _lvcheckneeded_disp(struct dm_report *rh, struct dm_pool *mem,
 		return _binary_disp(rh, mem, field, lvdm->seg_status.thin_pool->needs_check,
 				    GET_FIRST_RESERVED_NAME(lv_check_needed_y), private);
 
+	if (lv_is_cache(lvdm->lv) && lvdm->seg_status.type == SEG_STATUS_CACHE)
+		return _binary_disp(rh, mem, field, lvdm->seg_status.cache->needs_check,
+				    GET_FIRST_RESERVED_NAME(lv_check_needed_y), private);
+
 	return _binary_undef_disp(rh, mem, field, private);
 }
 


