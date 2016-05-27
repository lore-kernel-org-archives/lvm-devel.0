From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 27 May 2016 13:47:36 +0000 (UTC)
Subject: master - cache: call status only on cache pool in use
Message-ID: <20160527134736.D668660642@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0424277c00a8c576082389e0f4cdd8fd64052a54
Commit:        0424277c00a8c576082389e0f4cdd8fd64052a54
Parent:        a4f8d1165cfed1a3d62b4b11fd46302fb7e9563c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 24 15:19:01 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 27 15:47:24 2016 +0200

cache: call status only on cache pool in use

Check show cache status only for cache pool in use.
---
 WHATS_NEW                        |    1 +
 lib/metadata/metadata-exported.h |    1 +
 lib/report/properties.c          |    4 ++--
 lib/report/report.c              |    6 +++---
 4 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 44be410..a6957bc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.155 - 
 ================================
+  Check cache status only for 'in-use' cache pools.
   Extend setup_task() to preset flushing for dm_task object.
   When checking LV is a merging COW, validate its a COW LV first.
   Correcting value in copy_percent() for 100%.
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index a850492..1a9d5d9 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -230,6 +230,7 @@
 
 #define lv_is_cache(lv)		(((lv)->status & CACHE) ? 1 : 0)
 #define lv_is_cache_pool(lv)	(((lv)->status & CACHE_POOL) ? 1 : 0)
+#define lv_is_used_cache_pool(lv)	(lv_is_cache_pool(lv) && !dm_list_empty(&(lv)->segs_using_this_lv))
 #define lv_is_cache_pool_data(lv)	(((lv)->status & CACHE_POOL_DATA) ? 1 : 0)
 #define lv_is_cache_pool_metadata(lv)	(((lv)->status & CACHE_POOL_METADATA) ? 1 : 0)
 #define lv_is_cache_type(lv)	(((lv)->status & (CACHE | CACHE_POOL | CACHE_POOL_DATA | CACHE_POOL_METADATA)) ? 1 : 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 46f58be..d3feb07 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -109,7 +109,7 @@ static dm_percent_t _data_percent(const struct logical_volume *lv)
 	if (lv_is_cow(lv))
 		return _snap_percent(lv);
 
-	if (lv_is_cache(lv) || lv_is_cache_pool(lv)) {
+	if (lv_is_cache(lv) || lv_is_used_cache_pool(lv)) {
 		if (!lv_cache_status(lv, &status)) {
 			stack;
 			return DM_PERCENT_INVALID;
@@ -130,7 +130,7 @@ static dm_percent_t _metadata_percent(const struct logical_volume *lv)
 	dm_percent_t percent;
 	struct lv_status_cache *status;
 
-	if (lv_is_cache(lv) || lv_is_cache_pool(lv)) {
+	if (lv_is_cache(lv) || lv_is_used_cache_pool(lv)) {
 		if (!lv_cache_status(lv, &status)) {
 			stack;
 			return DM_PERCENT_INVALID;
diff --git a/lib/report/report.c b/lib/report/report.c
index 8fa9daf..fd084f1 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2849,7 +2849,7 @@ static int _copypercent_disp(struct dm_report *rh,
 	     (lv_is_mirror(lv) && lv_mirror_percent(lv->vg->cmd, lv, 0, &percent, NULL))) &&
 	    (percent != DM_PERCENT_INVALID)) {
 		percent = copy_percent(lv);
-	} else if (lv_is_cache(lv) || lv_is_cache_pool(lv)) {
+	} else if (lv_is_cache(lv) || lv_is_used_cache_pool(lv)) {
 		if (lv_cache_status(lv, &status)) {
 			percent = status->dirty_usage;
 			dm_pool_destroy(status->mem);
@@ -2947,7 +2947,7 @@ static int _datapercent_disp(struct dm_report *rh, struct dm_pool *mem,
 		(void) lv_thin_pool_percent(lv, 0, &percent);
 	else if (lv_is_thin_volume(lv))
 		(void) lv_thin_percent(lv, 0, &percent);
-	else if (lv_is_cache(lv) || lv_is_cache_pool(lv)) {
+	else if (lv_is_cache(lv) || lv_is_used_cache_pool(lv)) {
 		if (lv_cache_status(lv, &status)) {
 			percent = status->data_usage;
 			dm_pool_destroy(status->mem);
@@ -2970,7 +2970,7 @@ static int _metadatapercent_disp(struct dm_report *rh,
 		(void) lv_thin_pool_percent(lv, 1, &percent);
 	else if (lv_is_thin_volume(lv))
 		(void) lv_thin_percent(lv, 1, &percent);
-	else if (lv_is_cache(lv) || lv_is_cache_pool(lv)) {
+	else if (lv_is_cache(lv) || lv_is_used_cache_pool(lv)) {
 		if (lv_cache_status(lv, &status)) {
 			percent = status->metadata_usage;
 			dm_pool_destroy(status->mem);


