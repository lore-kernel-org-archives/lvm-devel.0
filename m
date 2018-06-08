From: David Teigland <teigland@sourceware.org>
Date: Fri, 8 Jun 2018 11:03:32 -0400
Subject: master - Remove header declarations for removed functions
Message-ID: <201806081503.w58F3W0p031096@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=669b1295aef917e5f811f448b88c9592944cf18a
Commit:        669b1295aef917e5f811f448b88c9592944cf18a
Parent:        dbc3e62cc079c00bb48987848a6315fb0a7372f8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 8 10:01:05 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 8 10:01:05 2018 -0500

Remove header declarations for removed functions

---
 lib/cache/lvmcache.h             |   13 -------------
 lib/metadata/metadata-exported.h |   27 ---------------------------
 lib/metadata/vg.h                |    7 -------
 3 files changed, 0 insertions(+), 47 deletions(-)

diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 4808a0d..536f6fd 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -102,8 +102,6 @@ struct lvmcache_info *lvmcache_info_from_pvid(const char *pvid, struct device *d
 const char *lvmcache_vgname_from_vgid(struct dm_pool *mem, const char *vgid);
 const char *lvmcache_vgid_from_vgname(struct cmd_context *cmd, const char *vgname);
 struct device *lvmcache_device_from_pvid(struct cmd_context *cmd, const struct id *pvid, uint64_t *label_sector);
-const char *lvmcache_pvid_from_devname(struct cmd_context *cmd, const char *devname);
-char *lvmcache_vgname_from_pvid(struct cmd_context *cmd, const char *pvid);
 const char *lvmcache_vgname_from_info(struct lvmcache_info *info);
 const struct format_type *lvmcache_fmt_from_info(struct lvmcache_info *info);
 int lvmcache_vgs_locked(void);
@@ -111,16 +109,6 @@ int lvmcache_vgname_is_locked(const char *vgname);
 
 void lvmcache_seed_infos_from_lvmetad(struct cmd_context *cmd);
 
-/* Returns list of struct dm_str_list containing pool-allocated copy of vgnames */
-/* If include_internal is not set, return only proper vg names. */
-struct dm_list *lvmcache_get_vgnames(struct cmd_context *cmd,
-				     int include_internal);
-
-/* Returns list of struct dm_str_list containing pool-allocated copy of vgids */
-/* If include_internal is not set, return only proper vg ids. */
-struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd,
-				   int include_internal);
-
 int lvmcache_get_vgnameids(struct cmd_context *cmd, int include_internal,
                           struct dm_list *vgnameids);
 
@@ -180,7 +168,6 @@ uint64_t lvmcache_device_size(struct lvmcache_info *info);
 void lvmcache_set_device_size(struct lvmcache_info *info, uint64_t size);
 struct device *lvmcache_device(struct lvmcache_info *info);
 int lvmcache_is_orphan(struct lvmcache_info *info);
-int lvmcache_uncertain_ownership(struct lvmcache_info *info);
 unsigned lvmcache_mda_count(struct lvmcache_info *info);
 int lvmcache_vgid_is_cached(const char *vgid);
 uint64_t lvmcache_smallest_mda_size(struct lvmcache_info *info);
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index e95652e..bcd10a3 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -654,12 +654,6 @@ void vg_revert(struct volume_group *vg);
 struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vg_name,
 				      const char *vgid, uint32_t lockd_state, uint32_t warn_flags, int *consistent);
 
-#define get_pvs( cmd ) get_pvs_internal((cmd), NULL, NULL)
-#define get_pvs_perserve_vg( cmd, pv_list, vg_list ) get_pvs_internal((cmd), (pv_list), (vg_list))
-
-struct dm_list *get_pvs_internal(struct cmd_context *cmd,
-		struct dm_list *pvslist, struct dm_list *vgslist);
-
 /*
  * Add/remove LV to/from volume group
  */
@@ -668,11 +662,8 @@ int unlink_lv_from_vg(struct logical_volume *lv);
 void lv_set_visible(struct logical_volume *lv);
 void lv_set_hidden(struct logical_volume *lv);
 
-struct dm_list *get_vgnames(struct cmd_context *cmd, int include_internal);
-struct dm_list *get_vgids(struct cmd_context *cmd, int include_internal);
 int get_vgnameids(struct cmd_context *cmd, struct dm_list *vgnameids,
 		  const char *only_this_vgname, int include_internal);
-int scan_vgs_for_pvs(struct cmd_context *cmd, uint32_t warn_flags);
 
 int pv_write(struct cmd_context *cmd, struct physical_volume *pv, int allow_non_orphan);
 int move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
@@ -711,12 +702,6 @@ uint32_t vg_read_error(struct volume_group *vg_handle);
 struct physical_volume *pv_create(const struct cmd_context *cmd,
 				  struct device *dev, struct pv_create_args *pva);
 
-struct physical_volume *pvcreate_vol(struct cmd_context *cmd, const char *pv_name,
-				     struct pvcreate_params *pp, int write_now);
-
-int pvremove_many(struct cmd_context *cmd, struct dm_list *pv_names,
-		  unsigned force_count, unsigned prompt);
-
 int pv_resize_single(struct cmd_context *cmd,
 			     struct volume_group *vg,
 			     struct physical_volume *pv,
@@ -740,10 +725,7 @@ int vg_remove_direct(struct volume_group *vg);
 int vg_remove(struct volume_group *vg);
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
-int vg_extend(struct volume_group *vg, int pv_count, const char *const *pv_names,
-	      struct pvcreate_params *pp);
 int vg_extend_each_pv(struct volume_group *vg, struct pvcreate_params *pp);
-int vg_reduce(struct volume_group *vg, const char *pv_name);
 
 int vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 			    struct physical_volume *pv, int commit);
@@ -1029,15 +1011,6 @@ struct generic_logical_volume *find_historical_glv(const struct volume_group *vg
 
 int lv_name_is_used_in_vg(const struct volume_group *vg, const char *name, int *historical);
 
-struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
-					const char *pv_name,
-					int allow_orphan, int allow_unformatted);
-
-const char *find_vgname_from_pvname(struct cmd_context *cmd,
-				    const char *pvname);
-const char *find_vgname_from_pvid(struct cmd_context *cmd,
-				  const char *pvid);
-
 int lv_is_on_pv(struct logical_volume *lv, struct physical_volume *pv);
 int lv_is_on_pvs(struct logical_volume *lv, struct dm_list *pvs);
 int get_pv_list_for_lv(struct dm_pool *mem,
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 8e9917f..4c70406 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -32,13 +32,6 @@ typedef enum {
 	ALLOC_INHERIT
 } alloc_policy_t;
 
-struct pv_to_write {
-	struct dm_list list;
-	struct physical_volume *pv;
-	struct pvcreate_params *pp;
-	int new_pv;
-};
-
 #define MAX_EXTENT_COUNT  (UINT32_MAX)
 
 struct volume_group {


