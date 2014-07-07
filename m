From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  7 Jul 2014 15:02:22 +0000 (UTC)
Subject: master - lv_manip: pool-metadata-spare is just a spare LV, not tightly bound to thin or cache
Message-ID: <20140707150222.D534C60CDD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f6001465efe064611920b30f5b913c1d09004ded
Commit:        f6001465efe064611920b30f5b913c1d09004ded
Parent:        4b65d7ec72869ba7e70a1c93567ef0f271ed395e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jul 7 17:02:06 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jul 7 17:02:06 2014 +0200

lv_manip: pool-metadata-spare is just a spare LV, not tightly bound to thin or cache

---
 lib/metadata/lv_manip.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index fc98b2a..c55b31f 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -94,12 +94,11 @@ typedef enum {
 	LV_TYPE_THIN_POOL,
 	LV_TYPE_THIN_POOL_DATA,
 	LV_TYPE_THIN_POOL_METADATA,
-	LV_TYPE_THIN_POOL_METADATA_SPARE,
 	LV_TYPE_CACHE,
 	LV_TYPE_CACHE_POOL,
 	LV_TYPE_CACHE_POOL_DATA,
 	LV_TYPE_CACHE_POOL_METADATA,
-	LV_TYPE_CACHE_POOL_METADATA_SPARE,
+	LV_TYPE_POOL_METADATA_SPARE,
 	LV_TYPE_VIRTUAL,
 	LV_TYPE_RAID,
 	LV_TYPE_RAID_IMAGE,
@@ -122,12 +121,11 @@ static const char *_lv_type_names[] = {
 	[LV_TYPE_THIN_POOL] =                   "thin-pool",
 	[LV_TYPE_THIN_POOL_DATA] =              "thin-pool-data",
 	[LV_TYPE_THIN_POOL_METADATA] =          "thin-pool-metadata",
-	[LV_TYPE_THIN_POOL_METADATA_SPARE] =    "thin-pool-metadata-spare",
 	[LV_TYPE_CACHE] =                       "cache",
 	[LV_TYPE_CACHE_POOL] =                  "cache-pool",
 	[LV_TYPE_CACHE_POOL_DATA] =             "cache-pool-data",
 	[LV_TYPE_CACHE_POOL_METADATA] =         "cache-pool-metadata",
-	[LV_TYPE_CACHE_POOL_METADATA_SPARE] =   "cache-pool-metadata-spare",
+	[LV_TYPE_POOL_METADATA_SPARE] =         "pool-metadata-spare",
 	[LV_TYPE_VIRTUAL] =                     "virtual",
 	[LV_TYPE_RAID] =                        "raid",
 	[LV_TYPE_RAID_IMAGE] =                  "raid-image",
@@ -161,7 +159,7 @@ static lv_type_t _get_lv_type(const struct logical_volume *lv)
 	else if (lv_is_thin_pool_metadata(lv))
 		type = LV_TYPE_THIN_POOL_METADATA;
 	else if (lv_is_pool_metadata_spare(lv))
-		type = LV_TYPE_THIN_POOL_METADATA_SPARE;
+		type = LV_TYPE_POOL_METADATA_SPARE;
 	else if (lv_is_cache(lv))
 		type = LV_TYPE_CACHE;
 	else if (lv_is_cache_pool(lv))
@@ -170,8 +168,6 @@ static lv_type_t _get_lv_type(const struct logical_volume *lv)
 		type = LV_TYPE_CACHE_POOL_DATA;
 	else if (lv_is_cache_pool_metadata(lv))
 		type = LV_TYPE_CACHE_POOL_METADATA;
-	else if (lv_is_pool_metadata_spare(lv))
-		type = LV_TYPE_CACHE_POOL_METADATA_SPARE;
 	else if (lv_is_virtual(lv))
 		type = LV_TYPE_VIRTUAL;
 	else if (lv_is_raid(lv))


