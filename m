From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 20 Jul 2017 13:17:46 -0400
Subject: master - tidy: declaration names match implementation
Message-ID: <201707201717.v6KHHkch023967@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=876c4a1b3bdf2d2f9202438a406a803efa01bf9a
Commit:        876c4a1b3bdf2d2f9202438a406a803efa01bf9a
Parent:        39ebacdb5a4df1c9e1ef1258082de40d0bff1cba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 20 19:13:32 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 20 19:16:41 2017 +0200

tidy: declaration names match implementation

Put in sync some naming used for function declaration and
actual in-code implementation.
---
 lib/activate/activate.h          |    6 ++--
 lib/cache/lvmcache.h             |    2 +-
 lib/format_text/import-export.h  |    2 +-
 lib/metadata/lv.h                |    2 +-
 lib/metadata/lv_alloc.h          |   16 +++++++-------
 lib/metadata/metadata-exported.h |   42 +++++++++++++++++++-------------------
 lib/metadata/metadata.h          |   18 ++++++++--------
 lib/metadata/pv.h                |    2 +-
 lib/metadata/pv_map.h            |    2 +-
 9 files changed, 46 insertions(+), 46 deletions(-)

diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 09d25c5..25b7cc8 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -174,7 +174,7 @@ int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health);
 int lv_raid_mismatch_count(const struct logical_volume *lv, uint64_t *cnt);
 int lv_raid_sync_action(const struct logical_volume *lv, char **sync_action);
 int lv_raid_message(const struct logical_volume *lv, const char *msg);
-int lv_cache_status(const struct logical_volume *lv,
+int lv_cache_status(const struct logical_volume *cache_lv,
 		    struct lv_status_cache **status);
 int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
 			 dm_percent_t *percent);
@@ -202,12 +202,12 @@ int lv_has_target_type(struct dm_pool *mem, const struct logical_volume *lv,
 		       const char *layer, const char *target_type);
 
 int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume *lv,
-			   const struct lv_activate_opts *laopts, int do_reg);
+			   const struct lv_activate_opts *laopts, int monitor);
 
 #ifdef DMEVENTD
 #  include "libdevmapper-event.h"
 char *get_monitor_dso_path(struct cmd_context *cmd, const char *libpath);
-int target_registered_with_dmeventd(struct cmd_context *cmd, const char *libpath,
+int target_registered_with_dmeventd(struct cmd_context *cmd, const char *dso,
 				    const struct logical_volume *lv, int *pending);
 int target_register_events(struct cmd_context *cmd, const char *dso, const struct logical_volume *lv,
 			    int evmask __attribute__((unused)), int set, int timeout);
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 4b8b942..847c208 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -181,7 +181,7 @@ int lvmcache_foreach_ba(struct lvmcache_info *info,
 			int (*fun)(struct disk_locn *, void *),
 			void *baton);
 
-int lvmcache_foreach_pv(struct lvmcache_vginfo *vg,
+int lvmcache_foreach_pv(struct lvmcache_vginfo *vginfo,
 			int (*fun)(struct lvmcache_info *, void *), void * baton);
 
 uint64_t lvmcache_device_size(struct lvmcache_info *info);
diff --git a/lib/format_text/import-export.h b/lib/format_text/import-export.h
index 4b47636..2f39e2a 100644
--- a/lib/format_text/import-export.h
+++ b/lib/format_text/import-export.h
@@ -64,7 +64,7 @@ int print_flags(char *buffer, size_t size, enum pv_vg_lv_e type, int mask, uint6
 int read_flags(uint64_t *status, enum pv_vg_lv_e type, int mask, const struct dm_config_value *cv);
 
 int print_segtype_lvflags(char *buffer, size_t size, uint64_t status);
-int read_segtype_lvflags(uint64_t *status, char *segtype_scr);
+int read_segtype_lvflags(uint64_t *status, char *segtype_str);
 
 int text_vg_export_file(struct volume_group *vg, const char *desc, FILE *fp);
 size_t text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf);
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 9f871d6..bd6643c 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -157,7 +157,7 @@ char *lvseg_kernel_discards_dup(struct dm_pool *mem, const struct lv_segment *se
 int lv_set_creation(struct logical_volume *lv,
 		    const char *hostname, uint64_t timestamp);
 int lv_active_change(struct cmd_context *cmd, struct logical_volume *lv,
-		     enum activation_change activate, int needs_exlusive);
+		     enum activation_change activate, int needs_exclusive);
 
 /* LV dup functions */
 char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_with_info_and_seg_status *lvdm);
diff --git a/lib/metadata/lv_alloc.h b/lib/metadata/lv_alloc.h
index cf2c579..df51df2 100644
--- a/lib/metadata/lv_alloc.h
+++ b/lib/metadata/lv_alloc.h
@@ -47,20 +47,20 @@ int release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t s, uint
 struct alloc_handle;
 struct alloc_handle *allocate_extents(struct volume_group *vg,
 				      struct logical_volume *lv,
-                                      const struct segment_type *segtype,
-                                      uint32_t stripes,
-                                      uint32_t mirrors, uint32_t log_count,
-				      uint32_t log_region_size, uint32_t extents,
-                                      struct dm_list *allocatable_pvs,
+				      const struct segment_type *segtype,
+				      uint32_t stripes,
+				      uint32_t mirrors, uint32_t log_count,
+				      uint32_t region_size, uint32_t extents,
+				      struct dm_list *allocatable_pvs,
 				      alloc_policy_t alloc, int approx_alloc,
 				      struct dm_list *parallel_areas);
 
 int lv_add_segment(struct alloc_handle *ah,
 		   uint32_t first_area, uint32_t num_areas,
 		   struct logical_volume *lv,
-                   const struct segment_type *segtype,
-                   uint32_t stripe_size,
-                   uint64_t status,
+		   const struct segment_type *segtype,
+		   uint32_t stripe_size,
+		   uint64_t status,
 		   uint32_t region_size);
 
 int lv_add_mirror_areas(struct alloc_handle *ah,
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 4e198d1..92b38de 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -863,9 +863,9 @@ uint32_t extents_from_percent_size(struct volume_group *vg, const struct dm_list
 				   percent_type_t percent, uint64_t size);
 
 struct logical_volume *find_pool_lv(const struct logical_volume *lv);
-int pool_is_active(const struct logical_volume *pool_lv);
+int pool_is_active(const struct logical_volume *lv);
 int pool_supports_external_origin(const struct lv_segment *pool_seg, const struct logical_volume *external_lv);
-int thin_pool_feature_supported(const struct logical_volume *pool_lv, int feature);
+int thin_pool_feature_supported(const struct logical_volume *lv, int feature);
 int recalculate_pool_chunk_size_with_dev_hints(struct logical_volume *pool_lv,
 					       int chunk_size_calc_policy);
 int validate_cache_chunk_size(struct cmd_context *cmd, uint32_t chunk_size);
@@ -899,9 +899,9 @@ int attach_thin_external_origin(struct lv_segment *seg,
 				struct logical_volume *external_lv);
 int detach_thin_external_origin(struct lv_segment *seg);
 int attach_pool_metadata_lv(struct lv_segment *pool_seg,
-                            struct logical_volume *pool_metadata_lv);
+                            struct logical_volume *metadata_lv);
 int detach_pool_metadata_lv(struct lv_segment *pool_seg,
-                            struct logical_volume **pool_metadata_lv);
+                            struct logical_volume **metadata_lv);
 int attach_pool_data_lv(struct lv_segment *pool_seg,
                         struct logical_volume *pool_data_lv);
 int is_mirror_image_removable(struct logical_volume *mimage_lv, void *baton);
@@ -1011,7 +1011,7 @@ struct logical_volume *lv_create_single(struct volume_group *vg,
  * skip on next activations is stored directly in metadata for each LV
  * as ACTIVATION_SKIP flag.
  */
-void lv_set_activation_skip(struct logical_volume *lv, int override_default, int add_skip_flag);
+void lv_set_activation_skip(struct logical_volume *lv, int override_default, int add_skip);
 int lv_activation_skip(struct logical_volume *lv, activation_change_t activate,
 		       int override_lv_skip_flag);
 
@@ -1022,7 +1022,7 @@ int insert_layer_for_segments_on_pv(struct cmd_context *cmd,
 				    struct logical_volume *lv_where,
 				    struct logical_volume *layer_lv,
 				    uint64_t status,
-				    struct pv_list *pv,
+				    struct pv_list *pvl,
 				    struct dm_list *lvs_changed);
 int remove_layers_for_segments(struct cmd_context *cmd,
 			       struct logical_volume *lv,
@@ -1181,8 +1181,8 @@ int add_mirror_images(struct cmd_context *cmd, struct logical_volume *lv,
 		      uint32_t mirrors, uint32_t stripes, uint32_t stripe_size, uint32_t region_size,
 		      struct dm_list *allocatable_pvs, alloc_policy_t alloc,
 		      uint32_t log_count);
-struct logical_volume *detach_mirror_log(struct lv_segment *seg);
-int attach_mirror_log(struct lv_segment *seg, struct logical_volume *lv);
+struct logical_volume *detach_mirror_log(struct lv_segment *mirrored_seg);
+int attach_mirror_log(struct lv_segment *seg, struct logical_volume *log_lv);
 int remove_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 		      struct dm_list *removable_pvs, int force);
 struct logical_volume *prepare_mirror_log(struct logical_volume *lv,
@@ -1203,12 +1203,12 @@ int shift_mirror_images(struct lv_segment *mirrored_seg, unsigned mimage);
 
 /* ++  metadata/replicator_manip.c */
 int replicator_add_replicator_dev(struct logical_volume *replicator_lv,
-				  struct lv_segment *rdev_seg);
+				  struct lv_segment *replicator_dev_seg);
 struct logical_volume *replicator_remove_replicator_dev(struct lv_segment *rdev_seg);
 int replicator_add_rlog(struct lv_segment *replicator_seg, struct logical_volume *rlog_lv);
 struct logical_volume *replicator_remove_rlog(struct lv_segment *replicator_seg);
 
-int replicator_dev_add_slog(struct replicator_device *rdev, struct logical_volume *slog_lv);
+int replicator_dev_add_slog(struct replicator_device *rdev, struct logical_volume *slog);
 struct logical_volume *replicator_dev_remove_slog(struct replicator_device *rdev);
 int replicator_dev_add_rimage(struct replicator_device *rdev, struct logical_volume *lv);
 struct logical_volume *replicator_dev_remove_rimage(struct replicator_device *rdev);
@@ -1234,11 +1234,11 @@ int lv_raid_split(struct logical_volume *lv, int yes, const char *split_name,
 int lv_raid_split_and_track(struct logical_volume *lv,
 			    int yes,
 			    struct dm_list *splittable_pvs);
-int lv_raid_merge(struct logical_volume *lv);
+int lv_raid_merge(struct logical_volume *image_lv);
 int lv_raid_convert(struct logical_volume *lv,
 		    const struct segment_type *new_segtype,
 		    int yes, int force,
-		    const unsigned stripes,
+		    const unsigned new_stripes,
 		    const unsigned new_stripe_size_supplied,
 		    const unsigned new_stripe_size,
 		    const uint32_t new_region_size,
@@ -1247,7 +1247,7 @@ int lv_raid_rebuild(struct logical_volume *lv, struct dm_list *rebuild_pvs);
 int lv_raid_replace(struct logical_volume *lv, int force,
 		    struct dm_list *remove_pvs, struct dm_list *allocate_pvs);
 int lv_raid_remove_missing(struct logical_volume *lv);
-int partial_raid_lv_supports_degraded_activation(const struct logical_volume *lv);
+int partial_raid_lv_supports_degraded_activation(const struct logical_volume *clv);
 uint32_t raid_rmeta_extents_delta(struct cmd_context *cmd,
 				  uint32_t rimage_extents_cur, uint32_t rimage_extents_new,
 				  uint32_t region_size, uint32_t extent_size);
@@ -1271,11 +1271,11 @@ struct lv_status_cache {
 };
 
 const char *display_cache_mode(const struct lv_segment *seg);
-const char *get_cache_mode_name(const struct lv_segment *cache_seg);
+const char *get_cache_mode_name(const struct lv_segment *pool_seg);
 int set_cache_mode(cache_mode_t *mode, const char *cache_mode);
-int cache_set_cache_mode(struct lv_segment *cache_seg, cache_mode_t mode);
-int cache_set_metadata_format(struct lv_segment *cache_seg, cache_metadata_format_t format);
-int cache_set_policy(struct lv_segment *cache_seg, const char *name,
+int cache_set_cache_mode(struct lv_segment *seg, cache_mode_t mode);
+int cache_set_metadata_format(struct lv_segment *seg, cache_metadata_format_t format);
+int cache_set_policy(struct lv_segment *seg, const char *name,
 		     const struct dm_config_tree *settings);
 int cache_set_params(struct lv_segment *seg,
 		     uint32_t chunk_size,
@@ -1295,8 +1295,8 @@ int update_cache_pool_params(struct cmd_context *cmd,
 int validate_lv_cache_chunk_size(struct logical_volume *pool_lv, uint32_t chunk_size);
 int validate_lv_cache_create_pool(const struct logical_volume *pool_lv);
 int validate_lv_cache_create_origin(const struct logical_volume *origin_lv);
-struct logical_volume *lv_cache_create(struct logical_volume *pool,
-				       struct logical_volume *origin);
+struct logical_volume *lv_cache_create(struct logical_volume *pool_lv,
+				       struct logical_volume *origin_lv);
 int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean);
 int lv_cache_remove(struct logical_volume *cache_lv);
 int wipe_cache_pool(struct logical_volume *cache_pool_lv);
@@ -1324,7 +1324,7 @@ struct dm_list *lvs_using_lv(struct cmd_context *cmd, struct volume_group *vg,
 			  struct logical_volume *lv);
 
 uint32_t find_free_lvnum(struct logical_volume *lv);
-dm_percent_t copy_percent(const struct logical_volume *lv_mirr);
+dm_percent_t copy_percent(const struct logical_volume *lv);
 char *generate_lv_name(struct volume_group *vg, const char *format,
 		       char *buffer, size_t len);
 char *top_level_lv_name(struct volume_group *vg, const char *lv_name);
@@ -1335,7 +1335,7 @@ struct glv_list *get_or_create_glvl(struct dm_pool *mem, struct logical_volume *
 /*
 * Begin skeleton for external LVM library
 */
-int pv_change_metadataignore(struct physical_volume *pv, uint32_t mda_ignore);
+int pv_change_metadataignore(struct physical_volume *pv, uint32_t mda_ignored);
 
 
 int vg_flag_write_locked(struct volume_group *vg);
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index a9eceaa..ab3db4a 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -172,7 +172,7 @@ struct metadata_area *mda_copy(struct dm_pool *mem,
 			       struct metadata_area *mda);
 
 unsigned mda_is_ignored(struct metadata_area *mda);
-void mda_set_ignored(struct metadata_area *mda, unsigned ignored);
+void mda_set_ignored(struct metadata_area *mda, unsigned mda_ignored);
 unsigned mda_locns_match(struct metadata_area *mda1, struct metadata_area *mda2);
 struct device *mda_get_device(struct metadata_area *mda);
 
@@ -405,7 +405,7 @@ int check_new_thin_pool(const struct logical_volume *pool_lv);
 /*
  * Remove a dev_dir if present.
  */
-const char *strip_dir(const char *vg_name, const char *dir);
+const char *strip_dir(const char *vg_name, const char *dev_dir);
 
 struct logical_volume *alloc_lv(struct dm_pool *mem);
 
@@ -423,7 +423,7 @@ int lv_has_constant_stripes(struct logical_volume *lv);
 /*
  * Checks that a replicator segment is correct.
  */
-int check_replicator_segment(const struct lv_segment *replicator_seg);
+int check_replicator_segment(const struct lv_segment *rseg);
 
 /*
  * Sometimes (eg, after an lvextend), it is possible to merge two
@@ -446,9 +446,9 @@ int remove_seg_from_segs_using_this_lv(struct logical_volume *lv, struct lv_segm
 
 int add_glv_to_indirect_glvs(struct dm_pool *mem,
 			     struct generic_logical_volume *origin_glv,
-			     struct generic_logical_volume *user_glv);
-int remove_glv_from_indirect_glvs(struct generic_logical_volume *glv,
-				  struct generic_logical_volume *user_glv);
+			     struct generic_logical_volume *glv);
+int remove_glv_from_indirect_glvs(struct generic_logical_volume *origin_glv,
+				  struct generic_logical_volume *glv);
 
 int for_each_sub_lv_except_pools(struct logical_volume *lv,
 				 int (*fn)(struct logical_volume *lv, void *data),
@@ -491,20 +491,20 @@ int fixup_imported_mirrors(struct volume_group *vg);
  * From thin_manip.c
  */
 int attach_pool_lv(struct lv_segment *seg, struct logical_volume *pool_lv,
-		   struct logical_volume *origin_lv,
+		   struct logical_volume *origin,
 		   struct generic_logical_volume *indirect_origin,
 		   struct logical_volume *merge_lv);
 int detach_pool_lv(struct lv_segment *seg);
 int attach_pool_message(struct lv_segment *pool_seg, dm_thin_message_t type,
 			struct logical_volume *lv, uint32_t delete_id,
-			int auto_increment);
+			int no_update);
 int lv_is_merging_thin_snapshot(const struct logical_volume *lv);
 int pool_has_message(const struct lv_segment *seg,
 		     const struct logical_volume *lv, uint32_t device_id);
 int pool_metadata_min_threshold(const struct lv_segment *pool_seg);
 int pool_below_threshold(const struct lv_segment *pool_seg);
 int pool_check_overprovisioning(const struct logical_volume *lv);
-int create_pool(struct logical_volume *lv, const struct segment_type *segtype,
+int create_pool(struct logical_volume *pool_lv, const struct segment_type *segtype,
 		struct alloc_handle *ah, uint32_t stripes, uint32_t stripe_size);
 
 /*
diff --git a/lib/metadata/pv.h b/lib/metadata/pv.h
index 9e8207d..e452ece 100644
--- a/lib/metadata/pv.h
+++ b/lib/metadata/pv.h
@@ -93,7 +93,7 @@ uint64_t pv_mda_free(const struct physical_volume *pv);
 uint64_t pv_used(const struct physical_volume *pv);
 uint32_t pv_mda_count(const struct physical_volume *pv);
 uint32_t pv_mda_used_count(const struct physical_volume *pv);
-unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned ignored);
+unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned mda_ignored);
 int is_orphan(const struct physical_volume *pv);
 int is_missing_pv(const struct physical_volume *pv);
 int is_used_pv(const struct physical_volume *pv);
diff --git a/lib/metadata/pv_map.h b/lib/metadata/pv_map.h
index d0f2481..4f8d0aa 100644
--- a/lib/metadata/pv_map.h
+++ b/lib/metadata/pv_map.h
@@ -65,7 +65,7 @@ struct pv_map {
 struct dm_list *create_pv_maps(struct dm_pool *mem, struct volume_group *vg,
 			    struct dm_list *allocatable_pvs);
 
-void consume_pv_area(struct pv_area *area, uint32_t to_go);
+void consume_pv_area(struct pv_area *pva, uint32_t to_go);
 void reinsert_changed_pv_area(struct pv_area *pva);
 
 uint32_t pv_maps_size(struct dm_list *pvms);


