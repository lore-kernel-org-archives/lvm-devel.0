From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  7 Jul 2010 14:34:45 +0200
Subject: [PATCH 11/22] Replicator: metadata update
In-Reply-To: <cover.1278505885.git.zkabelac@redhat.com>
References: <cover.1278505885.git.zkabelac@redhat.com>
Message-ID: <bbdbab3b75ff5a6082897ac5b5da5d929fb52108.1278505885.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata-exported.h |   59 ++++++++++++++++++++++++++++++--------
 1 files changed, 47 insertions(+), 12 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 7824005..cb7fd3d 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -74,6 +74,7 @@
 
 #define REPLICATOR		0x20000000U	/* LV -internal use only for replicator */
 #define REPLICATOR_LOG		0x40000000U	/* LV -internal use only for replicator-dev */
+#define REPLICATOR_NOTSYNCED   	0x80000000U	/* LV -internal use only for replicator */
 
 #define LVM_READ              	0x00000100U	/* LV VG */
 #define LVM_WRITE             	0x00000200U	/* LV VG */
@@ -352,7 +353,7 @@ struct replicator_device {
 	const char *name;		/* Device LV name */
 	struct logical_volume *lv;	/* LV from replicator site's VG */
 	struct logical_volume *slog;	/* Synclog lv from VG  */
-	const char *slog_name;		/* Debug - specify size of core synclog */
+	uint32_t slog_core;		/* Corelog size */
 };
 /* -- Replicator datatypes */
 
@@ -622,6 +623,8 @@ uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 struct lvcreate_params {
 	/* flags */
 	int snapshot; /* snap */
+	const char *replicator; /* replicator */
+	int replicator_dev; /* replicator-dev */
 	int zero; /* all */
 	int major; /* all */
 	int minor; /* all */
@@ -640,6 +643,9 @@ struct lvcreate_params {
 
 	uint32_t mirrors; /* mirror */
 
+	const char *rlog_type; /* replicator */
+	struct replicator_site rsite; /* replicator, use only parameters */
+
 	const struct segment_type *segtype; /* all */
 
 	/* size */
@@ -803,24 +809,53 @@ int collapse_mirrored_lv(struct logical_volume *lv);
 int shift_mirror_images(struct lv_segment *mirrored_seg, unsigned mimage);
 
 /* ++  metadata/replicator_manip.c */
-int replicator_add_replicator_dev(struct logical_volume *replicator_lv,
-				  struct lv_segment *rdev_seg);
-struct logical_volume *replicator_remove_replicator_dev(struct lv_segment *rdev_seg);
-int replicator_add_rlog(struct lv_segment *replicator_seg, struct logical_volume *rlog_lv);
-struct logical_volume *replicator_remove_rlog(struct lv_segment *replicator_seg);
-
-int replicator_dev_add_slog(struct replicator_device *rdev, struct logical_volume *slog_lv);
-struct logical_volume *replicator_dev_remove_slog(struct replicator_device *rdev);
-int replicator_dev_add_rimage(struct replicator_device *rdev, struct logical_volume *lv);
-struct logical_volume *replicator_dev_remove_rimage(struct replicator_device *rdev);
-
 int lv_is_active_replicator_dev(const struct logical_volume *lv);
 int lv_is_replicator(const struct logical_volume *lv);
 int lv_is_replicator_dev(const struct logical_volume *lv);
 int lv_is_rimage(const struct logical_volume *lv);
 int lv_is_rlog(const struct logical_volume *lv);
 int lv_is_slog(const struct logical_volume *lv);
+struct replicator_site *find_site_in_replicator(const struct logical_volume *replicator,
+						const char *site_name);
+struct replicator_site *find_local_site_in_replicator(const struct logical_volume *replicator);
 struct logical_volume *first_replicator_dev(const struct logical_volume *lv);
+int replicator_add_rlog(struct lv_segment *replicator_seg, struct logical_volume *rlog_lv);
+struct logical_volume *replicator_remove_rlog(struct lv_segment *replicator_seg);
+int replicator_site_add_device(struct replicator_site *rsite,
+			       struct lv_segment *replicator_dev_seg,
+			       const char *name,
+			       struct logical_volume *rimage,
+			       uint32_t slog_core,
+			       struct logical_volume *slog_lv,
+			       uint64_t device_index);
+int replicator_site_set_op_mode(struct replicator_site *rsite, const char *sitemode);
+const char *replicator_site_get_op_mode(const struct replicator_site *rsite);
+struct replicator_site *replicator_add_site(struct logical_volume *replicator,
+					    const char *site_name);
+void replicator_init(struct logical_volume *replicator);
+int replicator_add_replicator_dev(struct logical_volume *replicator,
+				  struct lv_segment *rdev_seg);
+
+int lv_add_replicator_dev(struct logical_volume *replicator,
+			  struct logical_volume *lv);
+int lv_remove_replicator_dev(struct logical_volume *replicator_dev);
+
+int lv_add_replicator_site(struct logical_volume *replicator,
+			   const struct replicator_site *rsite);
+int lv_remove_replicator_site(struct logical_volume *replicator, const char *site_name);
+
+int lv_add_sync_log(struct logical_volume *replicator,
+		    unsigned site_index,
+		    uint64_t device_index,
+		    struct dm_list *allocatable_pvs,
+		    alloc_policy_t alloc);
+
+int vg_prearrange_replicator(struct volume_group *vg,
+			     const struct lvcreate_params *lp);
+int vg_add_replicator(struct logical_volume *replicator,
+		      const char *rlog_type,
+		      uint32_t region_size);
+int vg_remove_replicator(struct logical_volume *replicator);
 /* --  metadata/replicator_manip.c */
 struct cmd_vg *cmd_vg_add(struct dm_pool *mem, struct dm_list *cmd_vgs,
 			  const char *vg_name, const char *vgid,
-- 
1.7.1.1


