From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:23:53 +0000 (UTC)
Subject: master - cache: report stats for cache volumes usage
Message-ID: <20141103132353.2827460243@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ca9482b276c4a74021d158e4b9c8e8a18dd50e35
Commit:        ca9482b276c4a74021d158e4b9c8e8a18dd50e35
Parent:        b7bc28b7b7dfdcaf6be9f3d8050994d2df35d3e9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 3 12:38:29 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:33 2014 +0100

cache: report stats for cache volumes usage

Show some stats with 'lvs'
Display same info for active cache volume and cache-pool.

data% - #used cache blocks/#total cache blocks
meta% - #used metadata blocks/#total metadata blocks
copy% - #dirty/#used cache blocks

TODO: maybe there is a better mapping
 - should be seen as first-try-and-see.
---
 WHATS_NEW               |    1 +
 lib/report/properties.c |   29 +++++++++++++++++++++++++++--
 lib/report/report.c     |   23 +++++++++++++++++++++--
 3 files changed, 49 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index bb8cd8d..d824289 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Report some basic percentage info for cache pools.
   Introduce size_mb_arg_with_percent() for advanced size arg reading.
   Add extra support for '.' as decimal point in size args.
   Configurable support for creation of sparse volumes with thin-pools.
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 8f4f472..3389087 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -104,10 +104,21 @@ static dm_percent_t _snap_percent(const struct logical_volume *lv)
 static dm_percent_t _data_percent(const struct logical_volume *lv)
 {
 	dm_percent_t percent;
+	struct lv_status_cache *status;
 
 	if (lv_is_cow(lv))
 		return _snap_percent(lv);
 
+	if (lv_is_cache(lv) || lv_is_cache_pool(lv)) {
+		if (!lv_cache_status(lv, &status)) {
+			stack;
+			return DM_PERCENT_INVALID;
+		}
+		percent = status->dirty_usage;
+		dm_pool_destroy(status->mem);
+		return percent;
+	}
+
 	if (lv_is_thin_volume(lv))
 		return lv_thin_percent(lv, 0, &percent) ? percent : DM_PERCENT_INVALID;
 
@@ -117,8 +128,22 @@ static dm_percent_t _data_percent(const struct logical_volume *lv)
 static dm_percent_t _metadata_percent(const struct logical_volume *lv)
 {
 	dm_percent_t percent;
-
-	return lv_thin_pool_percent(lv, 1, &percent) ? percent : DM_PERCENT_INVALID;
+	struct lv_status_cache *status;
+
+	if (lv_is_cache(lv) || lv_is_cache_pool(lv)) {
+		if (!lv_cache_status(lv, &status)) {
+			stack;
+			return DM_PERCENT_INVALID;
+		}
+		percent = status->dirty_usage;
+		dm_pool_destroy(status->mem);
+		return percent;
+	}
+
+	if (lv_is_thin_pool(lv))
+		return lv_thin_pool_percent(lv, 1, &percent) ? percent : DM_PERCENT_INVALID;
+
+	return DM_PERCENT_INVALID;
 }
 
 /* PV */
diff --git a/lib/report/report.c b/lib/report/report.c
index f2ed0ae..c74bbfa 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -1057,13 +1057,18 @@ static int _copypercent_disp(struct dm_report *rh,
 			     const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
+	struct lv_status_cache *status;
 	dm_percent_t percent = DM_PERCENT_INVALID;
 
 	if (((lv_is_raid(lv) && lv_raid_percent(lv, &percent)) ||
 	     (lv_is_mirror(lv) && lv_mirror_percent(lv->vg->cmd, lv, 0, &percent, NULL))) &&
 	    (percent != DM_PERCENT_INVALID)) {
 		percent = copy_percent(lv);
-		return dm_report_field_percent(rh, field, &percent);
+	} else if (lv_is_cache(lv) || lv_is_cache_pool(lv)) {
+		if (lv_cache_status(lv, &status)) {
+			percent = status->dirty_usage;
+			dm_pool_destroy(status->mem);
+		}
 	}
 
 	return dm_report_field_percent(rh, field, &percent);
@@ -1149,6 +1154,7 @@ static int _datapercent_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	dm_percent_t percent = DM_PERCENT_INVALID;
+	struct lv_status_cache *status;
 
 	if (lv_is_cow(lv))
 		return _snpercent_disp(rh, mem, field, data, private);
@@ -1156,6 +1162,12 @@ static int _datapercent_disp(struct dm_report *rh, struct dm_pool *mem,
 		(void) lv_thin_pool_percent(lv, 0, &percent);
 	else if (lv_is_thin_volume(lv))
 		(void) lv_thin_percent(lv, 0, &percent);
+	else if (lv_is_cache(lv) || lv_is_cache_pool(lv)) {
+		if (lv_cache_status(lv, &status)) {
+			percent = status->data_usage;
+			dm_pool_destroy(status->mem);
+		}
+	}
 
 	return dm_report_field_percent(rh, field, &percent);
 }
@@ -1167,11 +1179,18 @@ static int _metadatapercent_disp(struct dm_report *rh,
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	dm_percent_t percent = DM_PERCENT_INVALID;
+	struct lv_status_cache *status;
 
 	if (lv_is_thin_pool(lv))
 		(void) lv_thin_pool_percent(lv, 1, &percent);
 	else if (lv_is_thin_volume(lv))
 		(void) lv_thin_percent(lv, 1, &percent);
+	else if (lv_is_cache(lv) || lv_is_cache_pool(lv)) {
+		if (lv_cache_status(lv, &status)) {
+			percent = status->metadata_usage;
+			dm_pool_destroy(status->mem);
+		}
+	}
 
 	return dm_report_field_percent(rh, field, &percent);
 }


