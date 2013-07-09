From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  9 Jul 2013 01:51:46 +0000 (UTC)
Subject: master - tools: remove metadata.h
Message-ID: <20130709015146.C5148610A6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9d5bdc91ca51737be82c463e05e5818a833a1fea
Commit:        9d5bdc91ca51737be82c463e05e5818a833a1fea
Parent:        1280a3c7ed52e7af303c65a367f3d4fda941dfaa
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jul 9 02:51:24 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jul 9 02:51:24 2013 +0100

tools: remove metadata.h

---
 lib/metadata/metadata-exported.h |   11 +++++++++++
 lib/metadata/metadata.h          |   11 -----------
 tools/lvconvert.c                |    1 -
 tools/vgck.c                     |    1 +
 4 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 478337f..ef192d3 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -663,6 +663,17 @@ struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
 					   uint64_t size, alloc_policy_t alloc,
 					   struct dm_list *pvh);
 
+int attach_thin_external_origin(struct lv_segment *seg,
+				struct logical_volume *external_lv);
+int detach_thin_external_origin(struct lv_segment *seg);
+int attach_pool_metadata_lv(struct lv_segment *pool_seg,
+                            struct logical_volume *pool_metadata_lv);
+int detach_pool_metadata_lv(struct lv_segment *pool_seg,
+                            struct logical_volume **pool_metadata_lv);
+int attach_pool_data_lv(struct lv_segment *pool_seg,
+                        struct logical_volume *pool_data_lv);
+int is_mirror_image_removable(struct logical_volume *mimage_lv, void *baton);
+
 /*
  * Activation options
  */
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 80ad22b..d313198 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -462,12 +462,6 @@ int fixup_imported_mirrors(struct volume_group *vg);
 /*
  * From thin_manip.c
  */
-int attach_pool_metadata_lv(struct lv_segment *pool_seg,
-			    struct logical_volume *pool_metadata_lv);
-int detach_pool_metadata_lv(struct lv_segment *pool_seg,
-			    struct logical_volume **pool_metadata_lv);
-int attach_pool_data_lv(struct lv_segment *pool_seg,
-			struct logical_volume *pool_data_lv);
 int attach_pool_lv(struct lv_segment *seg, struct logical_volume *pool_lv,
 		   struct logical_volume *origin_lv);
 int detach_pool_lv(struct lv_segment *seg);
@@ -479,9 +473,6 @@ int pool_has_message(const struct lv_segment *seg,
 int pool_below_threshold(const struct lv_segment *pool_seg);
 int extend_pool(struct logical_volume *lv, const struct segment_type *segtype,
 		struct alloc_handle *ah, uint32_t stripes, uint32_t stripe_size);
-int attach_thin_external_origin(struct lv_segment *seg,
-				struct logical_volume *external_lv);
-int detach_thin_external_origin(struct lv_segment *seg);
 
 /*
  * Begin skeleton for external LVM library
@@ -493,8 +484,6 @@ struct id pv_vgid(const struct physical_volume *pv);
 int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 		 struct physical_volume *pv, struct pvcreate_params *pp);
 
-int is_mirror_image_removable(struct logical_volume *mimage_lv, void *baton);
-
 uint64_t find_min_mda_size(struct dm_list *mdas);
 char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tags);
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 3ea1987..5e7484e 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -15,7 +15,6 @@
 #include "tools.h"
 #include "polldaemon.h"
 #include "lv_alloc.h"
-#include "metadata.h"
 
 struct lvconvert_params {
 	int force;
diff --git a/tools/vgck.c b/tools/vgck.c
index eb0ecaf..e9c26a6 100644
--- a/tools/vgck.c
+++ b/tools/vgck.c
@@ -14,6 +14,7 @@
  */
 
 #include "tools.h"
+#include "metadata-exported.h"
 
 static int vgck_single(struct cmd_context *cmd __attribute__((unused)),
 		       const char *vg_name,


