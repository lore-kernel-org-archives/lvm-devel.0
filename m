From: David Teigland <teigland@sourceware.org>
Date: Mon, 10 Jun 2019 11:39:58 -0400
Subject: master - lvmcache: remove unused code
Message-ID: <201906101539.x5AFdwY1019885@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5036244ce87f3854c7d6b14ab754f43eceaf24eb
Commit:        5036244ce87f3854c7d6b14ab754f43eceaf24eb
Parent:        a07cc8dbefc26503b27331dcb1e7632c954fb8cb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 7 13:51:33 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 10 10:38:32 2019 -0500

lvmcache: remove unused code

---
 lib/cache/lvmcache.c |  105 --------------------------------------------------
 lib/cache/lvmcache.h |   28 -------------
 2 files changed, 0 insertions(+), 133 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 60dc848..857a953 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -117,11 +117,6 @@ void lvmcache_unlock_vgname(const char *vgname)
 	}
 }
 
-int lvmcache_vgs_locked(void)
-{
-	return _vgs_locked;
-}
-
 /*
  * When lvmcache sees a duplicate PV, this is set.
  * process_each_pv() can avoid searching for duplicates
@@ -1006,43 +1001,6 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 	return r;
 }
 
-/*
- * lvmcache_label_scan() detects duplicates in the basic label_scan(), then
- * filters out some dups, and chooses preferred duplicates to use.
- */
-
-void lvmcache_pvscan_duplicate_check(struct cmd_context *cmd)
-{
-	struct device_list *devl;
-
-	/* Check if label_scan() detected any dups. */
-	if (!_found_duplicate_pvs)
-		return;
-
-	/*
-	 * Once all the dups are identified, they are moved from the
-	 * "found" list to the "unused" list to sort out.
-	 */
-	dm_list_splice(&_unused_duplicate_devs, &_found_duplicate_devs);
-
-	/*
-	 * Remove items from the dups list that we know are the same
-	 * underlying dev, e.g. md components, that we want to just ignore.
-	 */
-	_filter_duplicate_devs(cmd);
-
-	/*
-	 * no more dups after ignoring some
-	 */
-	if (!_found_duplicate_pvs)
-		return;
-
-	/* Duplicates are found where we would have to pick one. */
-
-	dm_list_iterate_items(devl, &_unused_duplicate_devs)
-		log_warn("WARNING: found device with duplicate %s", dev_name(devl->dev));
-}
-
 int lvmcache_get_vgnameids(struct cmd_context *cmd, int include_internal,
 			   struct dm_list *vgnameids)
 {
@@ -1072,49 +1030,6 @@ int lvmcache_get_vgnameids(struct cmd_context *cmd, int include_internal,
 	return 1;
 }
 
-struct dm_list *lvmcache_get_pvids(struct cmd_context *cmd, const char *vgname,
-				const char *vgid)
-{
-	struct dm_list *pvids;
-	struct lvmcache_vginfo *vginfo;
-	struct lvmcache_info *info;
-
-	if (!(pvids = str_list_create(cmd->mem))) {
-		log_error("pvids list allocation failed");
-		return NULL;
-	}
-
-	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid)))
-		return pvids;
-
-	dm_list_iterate_items(info, &vginfo->infos) {
-		if (!str_list_add(cmd->mem, pvids,
-				  dm_pool_strdup(cmd->mem, info->dev->pvid))) {
-			log_error("strlist allocation failed");
-			return NULL;
-		}
-	}
-
-	return pvids;
-}
-
-int lvmcache_get_vg_devs(struct cmd_context *cmd,
-			 struct lvmcache_vginfo *vginfo,
-			 struct dm_list *devs)
-{
-	struct lvmcache_info *info;
-	struct device_list *devl;
-
-	dm_list_iterate_items(info, &vginfo->infos) {
-		if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
-			return_0;
-
-		devl->dev = info->dev;
-		dm_list_add(devs, &devl->list);
-	}
-	return 1;
-}
-
 static struct device *_device_from_pvid(const struct id *pvid, uint64_t *label_sector)
 {
 	struct lvmcache_info *info;
@@ -2395,26 +2310,6 @@ uint32_t lvmcache_ext_flags(struct lvmcache_info *info) {
 	return info->ext_flags;
 }
 
-int lvmcache_is_orphan(struct lvmcache_info *info) {
-	if (!info->vginfo)
-		return 1; /* FIXME? */
-	return is_orphan_vg(info->vginfo->vgname);
-}
-
-int lvmcache_vgid_is_cached(const char *vgid) {
-	struct lvmcache_vginfo *vginfo;
-
-	vginfo = lvmcache_vginfo_from_vgid(vgid);
-
-	if (!vginfo || !vginfo->vgname)
-		return 0;
-
-	if (is_orphan_vg(vginfo->vgname))
-		return 0;
-
-	return 1;
-}
-
 uint64_t lvmcache_smallest_mda_size(struct lvmcache_info *info)
 {
 	if (!info)
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 1921709..379cc9d 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -94,9 +94,6 @@ void lvmcache_unlock_vgname(const char *vgname);
 const struct format_type *lvmcache_fmt_from_vgname(struct cmd_context *cmd, const char *vgname, const char *vgid, unsigned revalidate_labels);
 int lvmcache_lookup_mda(struct lvmcache_vgsummary *vgsummary);
 
-/* Decrement and test if there are still vg holders in vginfo. */
-int lvmcache_vginfo_holders_dec_and_test_for_zero(struct lvmcache_vginfo *vginfo);
-
 struct lvmcache_vginfo *lvmcache_vginfo_from_vgname(const char *vgname,
 					   const char *vgid);
 struct lvmcache_vginfo *lvmcache_vginfo_from_vgid(const char *vgid);
@@ -106,15 +103,10 @@ const char *lvmcache_vgid_from_vgname(struct cmd_context *cmd, const char *vgnam
 struct device *lvmcache_device_from_pvid(struct cmd_context *cmd, const struct id *pvid, uint64_t *label_sector);
 const char *lvmcache_vgname_from_info(struct lvmcache_info *info);
 const struct format_type *lvmcache_fmt_from_info(struct lvmcache_info *info);
-int lvmcache_vgs_locked(void);
 
 int lvmcache_get_vgnameids(struct cmd_context *cmd, int include_internal,
                           struct dm_list *vgnameids);
 
-/* Returns list of struct dm_str_list containing pool-allocated copy of pvids */
-struct dm_list *lvmcache_get_pvids(struct cmd_context *cmd, const char *vgname,
-				const char *vgid);
-
 void lvmcache_drop_metadata(const char *vgname, int drop_precommitted);
 void lvmcache_commit_metadata(const char *vgname);
 
@@ -167,9 +159,7 @@ int lvmcache_foreach_pv(struct lvmcache_vginfo *vginfo,
 uint64_t lvmcache_device_size(struct lvmcache_info *info);
 void lvmcache_set_device_size(struct lvmcache_info *info, uint64_t size);
 struct device *lvmcache_device(struct lvmcache_info *info);
-int lvmcache_is_orphan(struct lvmcache_info *info);
 unsigned lvmcache_mda_count(struct lvmcache_info *info);
-int lvmcache_vgid_is_cached(const char *vgid);
 uint64_t lvmcache_smallest_mda_size(struct lvmcache_info *info);
 
 struct metadata_area *lvmcache_get_mda(struct cmd_context *cmd,
@@ -180,8 +170,6 @@ struct metadata_area *lvmcache_get_mda(struct cmd_context *cmd,
 int lvmcache_found_duplicate_pvs(void);
 int lvmcache_found_duplicate_vgnames(void);
 
-void lvmcache_pvscan_duplicate_check(struct cmd_context *cmd);
-
 int lvmcache_get_unused_duplicate_devs(struct cmd_context *cmd, struct dm_list *head);
 
 int vg_has_duplicate_pvs(struct volume_group *vg);
@@ -193,32 +181,16 @@ void lvmcache_get_max_name_lengths(struct cmd_context *cmd,
 
 int lvmcache_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const char *vgid);
 
-void lvmcache_lock_ordering(int enable);
-
 int lvmcache_dev_is_unchosen_duplicate(struct device *dev);
 
 void lvmcache_remove_unchosen_duplicate(struct device *dev);
 
 int lvmcache_pvid_in_unchosen_duplicates(const char *pvid);
 
-int lvmcache_get_vg_devs(struct cmd_context *cmd,
-			 struct lvmcache_vginfo *vginfo,
-			 struct dm_list *devs);
-void lvmcache_set_independent_location(const char *vgname);
-
 bool lvmcache_scan_mismatch(struct cmd_context *cmd, const char *vgname, const char *vgid);
 
 int lvmcache_vginfo_has_pvid(struct lvmcache_vginfo *vginfo, char *pvid);
 
-/*
- * These are clvmd-specific functions and are not related to lvmcache.
- * FIXME: rename these with a clvm_ prefix in place of lvmcache_
- */
-void lvmcache_save_vg(struct volume_group *vg, int precommitted);
-struct volume_group *lvmcache_get_saved_vg(const char *vgid, int precommitted);
-struct volume_group *lvmcache_get_saved_vg_latest(const char *vgid);
-void lvmcache_drop_saved_vgid(const char *vgid);
-
 uint64_t lvmcache_max_metadata_size(void);
 void lvmcache_save_metadata_size(uint64_t val);
 


