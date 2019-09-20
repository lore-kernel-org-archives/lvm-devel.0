From: David Teigland <teigland@sourceware.org>
Date: Fri, 20 Sep 2019 11:00:46 -0400
Subject: master - cachevol: add dm uuid suffixes to hidden lvs
Message-ID: <201909201500.x8KF0k2K018841@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=515e37b6dd352bd71e63bdef24fc13e2ee75ff98
Commit:        515e37b6dd352bd71e63bdef24fc13e2ee75ff98
Parent:        d2c065789cfac0ebfc5b6f3d85d9b2ce84d90e55
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 20 09:46:03 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 20 09:59:37 2019 -0500

cachevol: add dm uuid suffixes to hidden lvs

to indicate they are private lvm devs
---
 lib/activate/dev_manager.c |   14 +++++++-------
 lib/cache_segtype/cache.c  |    4 ++--
 lib/misc/lvm-string.c      |    2 ++
 3 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 5ee5efe..b85237d 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -46,7 +46,7 @@ typedef enum {
 } action_t;
 
 /* This list must match lib/misc/lvm-string.c:build_dm_uuid(). */
-const char *uuid_suffix_list[] = { "pool", "cdata", "cmeta", "tdata", "tmeta", "vdata", "vpool", NULL};
+const char *uuid_suffix_list[] = { "pool", "cdata", "cmeta", "tdata", "tmeta", "vdata", "vpool", "cvol", NULL};
 
 struct dlid_list {
 	struct dm_list list;
@@ -859,9 +859,9 @@ int get_cache_vol_meta_data(struct cmd_context *cmd,
 	memcpy(&lvid_data.id[0], &lv->vg->id, sizeof(struct id));
 	memcpy(&lvid_data.id[1], &lvseg->data_id, sizeof(struct id));
 
-	if (!(dlid_meta = dm_build_dm_uuid(cmd->mem, UUID_PREFIX, (const char *)&lvid_meta.s, NULL)))
+	if (!(dlid_meta = dm_build_dm_uuid(cmd->mem, UUID_PREFIX, (const char *)&lvid_meta.s, "cmeta")))
 		return_0;
-	if (!(dlid_data = dm_build_dm_uuid(cmd->mem, UUID_PREFIX, (const char *)&lvid_data.s, NULL)))
+	if (!(dlid_data = dm_build_dm_uuid(cmd->mem, UUID_PREFIX, (const char *)&lvid_data.s, "cdata")))
 		return_0;
 	if (!(name_meta = dm_build_dm_name(cmd->mem, lv->vg->name, pool_lv->name, "_cmeta")))
 		return_0;
@@ -2500,9 +2500,9 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		memcpy(&lvid_data.id[0], &lv->vg->id, sizeof(struct id));
 		memcpy(&lvid_data.id[1], &lvseg->data_id, sizeof(struct id));
 
-		if (!(dlid_meta = dm_build_dm_uuid(dm->mem, UUID_PREFIX, (const char *)&lvid_meta.s, NULL)))
+		if (!(dlid_meta = dm_build_dm_uuid(dm->mem, UUID_PREFIX, (const char *)&lvid_meta.s, "cmeta")))
 			return_0;
-		if (!(dlid_data = dm_build_dm_uuid(dm->mem, UUID_PREFIX, (const char *)&lvid_data.s, NULL)))
+		if (!(dlid_data = dm_build_dm_uuid(dm->mem, UUID_PREFIX, (const char *)&lvid_data.s, "cdata")))
 			return_0;
 		if (!(name_meta = dm_build_dm_name(dm->mem, lv->vg->name, pool_lv->name, "_cmeta")))
 			return_0;
@@ -3242,9 +3242,9 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		memcpy(&lvid_data.id[0], &vg->id, sizeof(struct id));
 		memcpy(&lvid_data.id[1], &lvseg->data_id, sizeof(struct id));
 
-		if (!(dlid_meta = dm_build_dm_uuid(dm->mem, UUID_PREFIX, (const char *)&lvid_meta.s, NULL)))
+		if (!(dlid_meta = dm_build_dm_uuid(dm->mem, UUID_PREFIX, (const char *)&lvid_meta.s, "cmeta")))
 			return_0;
-		if (!(dlid_data = dm_build_dm_uuid(dm->mem, UUID_PREFIX, (const char *)&lvid_data.s, NULL)))
+		if (!(dlid_data = dm_build_dm_uuid(dm->mem, UUID_PREFIX, (const char *)&lvid_data.s, "cdata")))
 			return_0;
 
 		if (!(name_meta = dm_build_dm_name(dm->mem, vg->name, pool_lv->name, "_cmeta")))
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 20a4261..798b157 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -699,9 +699,9 @@ static int _cache_add_target_line(struct dev_manager *dm,
 		memcpy(&data_lvid.id[0], &seg->lv->vg->id, sizeof(struct id));
 		memcpy(&data_lvid.id[1], &seg->data_id, sizeof(struct id));
 
-		if (!(metadata_uuid = dm_build_dm_uuid(mem, UUID_PREFIX, (const char *)&metadata_lvid.s, NULL)))
+		if (!(metadata_uuid = dm_build_dm_uuid(mem, UUID_PREFIX, (const char *)&metadata_lvid.s, "cmeta")))
 			return_0;
-		if (!(data_uuid = dm_build_dm_uuid(mem, UUID_PREFIX, (const char *)&data_lvid.s, NULL)))
+		if (!(data_uuid = dm_build_dm_uuid(mem, UUID_PREFIX, (const char *)&data_lvid.s, "cdata")))
 			return_0;
 	}
 
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index fe24f23..b7c1c12 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -157,6 +157,7 @@ static const char *_lvname_has_reserved_component_string(const char *lvname)
 		"_cdata",
 		"_cmeta",
 		"_corig",
+		"_cvol",
 		"_mimage",
 		"_mlog",
 		"_rimage",
@@ -251,6 +252,7 @@ char *build_dm_uuid(struct dm_pool *mem, const struct logical_volume *lv,
 			(lv_is_cache(lv) && lv_is_pending_delete(lv)) ? "real" :
 			lv_is_cache_pool_data(lv) ? "cdata" :
 			lv_is_cache_pool_metadata(lv) ? "cmeta" :
+			lv_is_cache_vol(lv) ? "cvol" :
 			// FIXME: dm-tree needs fixes for mirrors/raids
 			//lv_is_mirror_image(lv) ? "mimage" :
 			//lv_is_mirror_log(lv) ? "mlog" :


