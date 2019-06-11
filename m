From: David Teigland <teigland@sourceware.org>
Date: Tue, 11 Jun 2019 16:06:42 -0400
Subject: master - lvmcache: remove wrapper around lvmcache_get_vgnameids
Message-ID: <201906112006.x5BK6gVG022069@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4bb7d3da0e7472804361f639c6da5e2798b4e0d2
Commit:        4bb7d3da0e7472804361f639c6da5e2798b4e0d2
Parent:        0f350ba890f02eb73d6cdebe29420a709e2b5ae6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 11 14:09:13 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 11 14:10:14 2019 -0500

lvmcache: remove wrapper around lvmcache_get_vgnameids

This was left over from when there was an lvmetad
version of the function.
---
 lib/cache/lvmcache.c             |   18 ++++++++++++++++--
 lib/cache/lvmcache.h             |    6 ++++--
 lib/metadata/metadata-exported.h |    3 ---
 lib/metadata/metadata.c          |   22 ----------------------
 tools/toollib.c                  |    6 +++---
 tools/vgimportclone.c            |    2 +-
 6 files changed, 24 insertions(+), 33 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index e45764a..1d92e01 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -947,12 +947,26 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 	return r;
 }
 
-int lvmcache_get_vgnameids(struct cmd_context *cmd, int include_internal,
-			   struct dm_list *vgnameids)
+int lvmcache_get_vgnameids(struct cmd_context *cmd,
+			   struct dm_list *vgnameids,
+			   const char *only_this_vgname,
+			   int include_internal)
 {
 	struct vgnameid_list *vgnl;
 	struct lvmcache_vginfo *vginfo;
 
+	if (only_this_vgname) {
+		if (!(vgnl = dm_pool_alloc(cmd->mem, sizeof(*vgnl)))) {
+			log_error("vgnameid_list allocation failed.");
+			return 0;
+		}
+
+		vgnl->vg_name = dm_pool_strdup(cmd->mem, only_this_vgname);
+		vgnl->vgid = NULL;
+		dm_list_add(vgnameids, &vgnl->list);
+		return 1;
+	}
+
 	dm_list_iterate_items(vginfo, &_vginfos) {
 		if (!include_internal && is_orphan_vg(vginfo->vgname))
 			continue;
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 22c2c1f..5b78d7a 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -103,8 +103,10 @@ struct device *lvmcache_device_from_pvid(struct cmd_context *cmd, const struct i
 const char *lvmcache_vgname_from_info(struct lvmcache_info *info);
 const struct format_type *lvmcache_fmt_from_info(struct lvmcache_info *info);
 
-int lvmcache_get_vgnameids(struct cmd_context *cmd, int include_internal,
-                          struct dm_list *vgnameids);
+int lvmcache_get_vgnameids(struct cmd_context *cmd,
+                           struct dm_list *vgnameids,
+                           const char *only_this_vgname,
+                           int include_internal);
 
 void lvmcache_drop_metadata(const char *vgname, int drop_precommitted);
 void lvmcache_commit_metadata(const char *vgname);
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 10593a0..9029d3f 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -696,9 +696,6 @@ int unlink_lv_from_vg(struct logical_volume *lv);
 void lv_set_visible(struct logical_volume *lv);
 void lv_set_hidden(struct logical_volume *lv);
 
-int get_vgnameids(struct cmd_context *cmd, struct dm_list *vgnameids,
-		  const char *only_this_vgname, int include_internal);
-
 int pv_write(struct cmd_context *cmd, struct physical_volume *pv, int allow_non_orphan);
 int move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
 	    const char *pv_name);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index aceac5a..039a7d6 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3566,28 +3566,6 @@ void set_pv_devices(struct format_instance *fid, struct volume_group *vg)
 		_set_pv_device(fid, vg, pvl->pv);
 }
 
-int get_vgnameids(struct cmd_context *cmd, struct dm_list *vgnameids,
-		  const char *only_this_vgname, int include_internal)
-{
-	struct vgnameid_list *vgnl;
-
-	if (only_this_vgname) {
-		if (!(vgnl = dm_pool_alloc(cmd->mem, sizeof(*vgnl)))) {
-			log_error("vgnameid_list allocation failed.");
-			return 0;
-		}
-
-		vgnl->vg_name = dm_pool_strdup(cmd->mem, only_this_vgname);
-		vgnl->vgid = NULL;
-		dm_list_add(vgnameids, &vgnl->list);
-		return 1;
-	}
-
-	lvmcache_get_vgnameids(cmd, include_internal, vgnameids);
-
-	return 1;
-}
-
 int pv_write(struct cmd_context *cmd,
 	     struct physical_volume *pv, int allow_non_orphan)
 {
diff --git a/tools/toollib.c b/tools/toollib.c
index a3b5fea..506ad2d 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2262,7 +2262,7 @@ int process_each_vg(struct cmd_context *cmd,
 	 */
 	log_very_verbose("Obtaining the complete list of VGs to process");
 
-	if (!get_vgnameids(cmd, &vgnameids_on_system, NULL, include_internal)) {
+	if (!lvmcache_get_vgnameids(cmd, &vgnameids_on_system, NULL, include_internal)) {
 		ret_max = ECMD_FAILED;
 		goto_out;
 	}
@@ -3807,7 +3807,7 @@ int process_each_lv(struct cmd_context *cmd,
 	 */
 	log_very_verbose("Obtaining the complete list of VGs before processing their LVs");
 
-	if (!get_vgnameids(cmd, &vgnameids_on_system, NULL, 0)) {
+	if (!lvmcache_get_vgnameids(cmd, &vgnameids_on_system, NULL, 0)) {
 		ret_max = ECMD_FAILED;
 		goto_out;
 	}
@@ -4479,7 +4479,7 @@ int process_each_pv(struct cmd_context *cmd,
 	if (!(read_flags & PROCESS_SKIP_SCAN))
 		lvmcache_label_scan(cmd);
 
-	if (!get_vgnameids(cmd, &all_vgnameids, only_this_vgname, 1)) {
+	if (!lvmcache_get_vgnameids(cmd, &all_vgnameids, only_this_vgname, 1)) {
 		ret_max = ret;
 		goto_out;
 	}
diff --git a/tools/vgimportclone.c b/tools/vgimportclone.c
index f7b1c0b..a3af841 100644
--- a/tools/vgimportclone.c
+++ b/tools/vgimportclone.c
@@ -296,7 +296,7 @@ int vgimportclone(struct cmd_context *cmd, int argc, char **argv)
 		vgname_count = 1;
 	}
 
-	if (!get_vgnameids(cmd, &vgnameids_on_system, NULL, 0))
+	if (!lvmcache_get_vgnameids(cmd, &vgnameids_on_system, NULL, 0))
 		goto_out;
 
 retry_name:


