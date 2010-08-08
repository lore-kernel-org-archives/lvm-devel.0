From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun,  8 Aug 2010 10:57:23 +0200
Subject: [PATCH 11/25] Replicator: metadata update
In-Reply-To: <cover.1281256234.git.zkabelac@redhat.com>
References: <cover.1281256234.git.zkabelac@redhat.com>
Message-ID: <600a2c97fb0cdc09bbf682197b69f1036a6de98a.1281256235.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata-exported.h |   81 +++++++++++++++++++++++++++-----------
 1 files changed, 58 insertions(+), 23 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 41ef566..70a4c33 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -73,7 +73,8 @@
 #define MERGING			0x10000000U	/* LV SEG */
 
 #define REPLICATOR		0x20000000U	/* LV -internal use only for replicator */
-#define REPLICATOR_LOG		0x40000000U	/* LV -internal use only for replicator-dev */
+#define REPLICATOR_LOG		0x40000000U	/* LV -internal use only for replicated */
+#define REPLICATOR_NOTSYNCED   	0x80000000U	/* LV -internal use only for replicator */
 
 #define LVM_READ              	0x00000100U	/* LV VG */
 #define LVM_WRITE             	0x00000200U	/* LV VG */
@@ -327,7 +328,7 @@ typedef enum {
 
 struct replicator_site {
 	struct dm_list list;		/* Chained list of sites */
-	struct dm_list rdevices;	/* Device list */
+	struct dm_list rdevices;	/* List of replicated devices */
 
 	struct logical_volume *replicator; /* Reference to replicator */
 
@@ -336,23 +337,23 @@ struct replicator_site {
 	struct volume_group *vg;        /* resolved vg  (activate/deactive) */
 	unsigned site_index;
 	replicator_state_t state;	/* Active or pasive state of site */
-	dm_replicator_mode_t op_mode;	/* Operation mode sync or async fail|warn|drop|stall */
-	uint64_t fall_behind_data;	/* Bytes */
+	dm_replicator_policy_t policy;	/* Policy sync or async fail|warn|drop|stall */
 	uint32_t fall_behind_ios;	/* IO operations */
+	uint64_t fall_behind_size;	/* Bytes */
 	uint32_t fall_behind_timeout;	/* Seconds */
 };
 
-struct replicator_device {
+struct replicated_device {
 	struct dm_list list;		/* Chained list of devices from same site */
 
-	struct lv_segment *replicator_dev; /* Reference to replicator-dev segment */
+	struct lv_segment *replicated_seg; /* Reference to replicated segment */
 	struct replicator_site *rsite;	/* Reference to site parameters */
 
 	uint64_t device_index;
 	const char *name;		/* Device LV name */
 	struct logical_volume *lv;	/* LV from replicator site's VG */
 	struct logical_volume *slog;	/* Synclog lv from VG  */
-	const char *slog_name;		/* Debug - specify size of core synclog */
+	uint32_t slog_core;		/* Corelog size */
 };
 /* -- Replicator datatypes */
 
@@ -384,7 +385,7 @@ struct lv_segment {
 
 	struct lv_segment_area *areas;
 
-	struct logical_volume *replicator;/* For replicator-devs - link to replicator LV */
+	struct logical_volume *replicator;/* For replicated - link to replicator LV */
 	struct logical_volume *rlog_lv;	/* For replicators */
 	const char *rlog_type;		/* For replicators */
 	uint64_t rdevice_index_highest;	/* For replicators */
@@ -414,7 +415,7 @@ struct logical_volume {
 	struct dm_list snapshot_segs;
 	struct lv_segment *snapshot;
 
-	struct replicator_device *rdevice;/* For replicator-devs, rimages, slogs - reference to rdevice */
+	struct replicated_device *rdevice;/* For replicated, rimages, slogs - reference to rdevice */
 	struct dm_list rsites;	/* For replicators - all sites */
 
 	struct dm_list segments;
@@ -623,6 +624,8 @@ uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 struct lvcreate_params {
 	/* flags */
 	int snapshot; /* snap */
+	const char *replicator; /* replicator */
+	int replicated; /* replicated */
 	int zero; /* all */
 	int major; /* all */
 	int minor; /* all */
@@ -641,6 +644,9 @@ struct lvcreate_params {
 
 	uint32_t mirrors; /* mirror */
 
+	const char *rlog_type; /* replicator */
+	struct replicator_site rsite; /* replicator, use only parameters */
+
 	const struct segment_type *segtype; /* all */
 
 	/* size */
@@ -804,24 +810,53 @@ int collapse_mirrored_lv(struct logical_volume *lv);
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
-int lv_is_active_replicator_dev(const struct logical_volume *lv);
+int lv_is_active_replicated(const struct logical_volume *lv);
 int lv_is_replicator(const struct logical_volume *lv);
-int lv_is_replicator_dev(const struct logical_volume *lv);
+int lv_is_replicated(const struct logical_volume *lv);
 int lv_is_rimage(const struct logical_volume *lv);
 int lv_is_rlog(const struct logical_volume *lv);
 int lv_is_slog(const struct logical_volume *lv);
-struct logical_volume *first_replicator_dev(const struct logical_volume *lv);
+struct replicator_site *find_site_in_replicator(const struct logical_volume *replicator,
+						const char *site_name);
+struct replicator_site *find_local_site_in_replicator(const struct logical_volume *replicator);
+struct logical_volume *first_replicated(const struct logical_volume *lv);
+int replicator_add_rlog(struct lv_segment *replicator_seg, struct logical_volume *rlog_lv);
+struct logical_volume *replicator_remove_rlog(struct lv_segment *replicator_seg);
+int replicator_site_add_device(struct replicator_site *rsite,
+			       struct lv_segment *replicated_seg,
+			       const char *name,
+			       struct logical_volume *rimage,
+			       uint32_t slog_core,
+			       struct logical_volume *slog_lv,
+			       uint64_t device_index);
+int replicator_site_set_policy(struct replicator_site *rsite, const char *sitepolicy);
+const char *replicator_site_get_policy(const struct replicator_site *rsite);
+struct replicator_site *replicator_add_site(struct logical_volume *replicator,
+					    const char *site_name);
+void replicator_init(struct logical_volume *replicator);
+int replicator_add_replicated_seg(struct logical_volume *replicator,
+				  struct lv_segment *rdev_seg);
+
+int lv_add_replicated(struct logical_volume *replicator,
+		      struct logical_volume *lv);
+int lv_remove_replicated(struct logical_volume *replicated);
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
1.7.2.1


