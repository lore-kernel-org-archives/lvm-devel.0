From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  8 Jul 2013 17:15:53 +0200
Subject: [PATCH 1/7] thin: add pool metadata spare lv support
In-Reply-To: <cover.1373296467.git.zkabelac@redhat.com>
References: <cover.1373296467.git.zkabelac@redhat.com>
Message-ID: <921e760baaf5d530ef4600e3307fa98295cb5f65.1373296467.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add support for pool's metadata spare volume.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/format_text/flags.c          |  1 +
 lib/format_text/import_vsn1.c    | 12 +++++++
 lib/metadata/metadata-exported.h |  4 +++
 lib/metadata/metadata.c          | 21 ++++++++++++
 lib/metadata/thin_manip.c        | 71 ++++++++++++++++++++++++++++++++++++++++
 lib/metadata/vg.h                |  2 ++
 lib/misc/lvm-string.c            |  1 +
 7 files changed, 112 insertions(+)

diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index cbccdfd..201ad4a 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -60,6 +60,7 @@ static const struct flag _lv_flags[] = {
 	{LV_NOTSYNCED, "NOTSYNCED", STATUS_FLAG},
 	{LV_REBUILD, "REBUILD", STATUS_FLAG},
 	{LV_WRITEMOSTLY, "WRITEMOSTLY", STATUS_FLAG},
+	{POOL_METADATA_SPARE, NULL, 0},
 	{RAID, NULL, 0},
 	{RAID_META, NULL, 0},
 	{RAID_IMAGE, NULL, 0},
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 54a4a9c..59603bb 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -617,6 +617,18 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 	if (timestamp && !lv_set_creation(lv, hostname, timestamp))
 		return_0;
 
+	if (!lv_is_visible(lv) && strstr(lv->name, "_pmspare")) {
+		if (vg->pool_metadata_spare_lv) {
+			log_error("Couldn't use another pool metadata spare "
+				  "logical volume %s/%s.", vg->name, lv->name);
+			return 0;
+		}
+		log_debug_metadata("Logical volume %s is pool metadata spare.",
+				   lv->name);
+		lv->status |= POOL_METADATA_SPARE;
+		vg->pool_metadata_spare_lv = lv;
+	}
+
 	return 1;
 }
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 412d29c..0250941 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -99,6 +99,7 @@
 #define THIN_POOL_METADATA	UINT64_C(0x0000008000000000)	/* LV */
 
 #define LV_WRITEMOSTLY		UINT64_C(0x0000010000000000)	/* LV (RAID1) */
+#define POOL_METADATA_SPARE	UINT64_C(0x0000020000000000)	/* LV internal */
 
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
@@ -158,6 +159,7 @@
 #define lv_is_raid_type(lv)	(((lv)->status & (RAID | RAID_IMAGE | RAID_META)) ? 1 : 0)
 
 #define lv_is_virtual(lv)	(((lv)->status & VIRTUAL) ? 1 : 0)
+#define lv_is_pool_metadata_spare(lv)	(((lv)->status & POOL_METADATA_SPARE) ? 1 : 0)
 
 /* Ordered list - see lv_manip.c */
 typedef enum {
@@ -664,6 +666,8 @@ struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
 					   uint32_t stripes, uint32_t stripe_size,
 					   uint64_t size, alloc_policy_t alloc,
 					   struct dm_list *pvh);
+int vg_set_pool_metadata_spare(struct logical_volume *lv);
+int vg_remove_pool_metadata_spare(struct volume_group *vg);
 
 /*
  * Activation options
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 96a636c..3796eb6 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2295,6 +2295,7 @@ int vg_validate(struct volume_group *vg)
 	unsigned hidden_lv_count = 0, lv_count = 0, lv_visible_count = 0;
 	unsigned pv_count = 0;
 	unsigned num_snapshots = 0;
+	unsigned spare_count = 0;
 	struct validate_hash vhash = { NULL };
 
 	if (vg->alloc == ALLOC_CLING_BY_TAGS) {
@@ -2474,6 +2475,19 @@ int vg_validate(struct volume_group *vg)
 			r = 0;
 		}
 
+		if (lv_is_pool_metadata_spare(lvl->lv)) {
+			if (++spare_count > 1) {
+				log_error(INTERNAL_ERROR "LV %s is %u. pool metadata spare (>1).",
+					  lvl->lv->name, spare_count);
+				r = 0;
+			}
+			if (vg->pool_metadata_spare_lv != lvl->lv) {
+				log_error(INTERNAL_ERROR "LV %s is not vg pool metadata spare.",
+					  lvl->lv->name);
+				r = 0;
+			}
+		}
+
 		if (!check_lv_segments(lvl->lv, 1)) {
 			log_error(INTERNAL_ERROR "LV segments corrupted in %s.",
 				  lvl->lv->name);
@@ -2526,6 +2540,13 @@ int vg_validate(struct volume_group *vg)
 		r = 0;
 	}
 
+	if (vg->pool_metadata_spare_lv &&
+	    !lv_is_pool_metadata_spare(vg->pool_metadata_spare_lv)) {
+		log_error(INTERNAL_ERROR "VG references non pool metadata spare LV %s.",
+			  vg->pool_metadata_spare_lv->name);
+		r = 0;
+	}
+
 	if (vg_max_lv_reached(vg))
 		stack;
 out:
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index f40fd74..721c1e2 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -721,3 +721,74 @@ struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
 
 	return metadata_lv;
 }
+
+int vg_set_pool_metadata_spare(struct logical_volume *lv)
+{
+	char new_name[NAME_LEN];
+	struct volume_group *vg = lv->vg;
+
+	if (vg->pool_metadata_spare_lv) {
+		if (vg->pool_metadata_spare_lv == lv)
+			return 1;
+		if (!vg_remove_pool_metadata_spare(vg))
+			return_0;
+	}
+
+	if (dm_snprintf(new_name, sizeof(new_name), "%s_pmspare", lv->name) < 0) {
+		log_error("Can't create pool metadata spare. Name of pool LV "
+			  "%s is too long.", lv->name);
+		return 0;
+	}
+
+	if (!lv_rename_update(vg->cmd, lv, new_name, 0))
+		return_0;
+
+	lv_set_hidden(lv);
+	lv->status |= POOL_METADATA_SPARE;
+	vg->pool_metadata_spare_lv = lv;
+
+	return 1;
+}
+
+int vg_remove_pool_metadata_spare(struct volume_group *vg)
+{
+	char new_name[NAME_LEN];
+	char *c;
+
+	struct logical_volume *lv = vg->pool_metadata_spare_lv;
+
+	if (!(lv->status & POOL_METADATA_SPARE)) {
+		log_error(INTERNAL_ERROR "LV %s is not pool metadata spare.",
+			  lv->name);
+		return 0;
+	}
+
+	vg->pool_metadata_spare_lv = NULL;
+	lv->status &= ~POOL_METADATA_SPARE;
+	lv_set_visible(lv);
+
+	/* Cut off suffix _pmspare */
+	(void) dm_strncpy(new_name, lv->name, sizeof(new_name));
+	if (!(c = strchr(new_name, '_'))) {
+		log_error(INTERNAL_ERROR "LV %s has no suffix for pool metadata spare.",
+			  new_name);
+		return 0;
+	}
+	*c = 0;
+
+	/* If the name is in use, generate new lvol%d */
+	if (find_lv_in_vg(vg, new_name) &&
+	    !generate_lv_name(vg, "lvol%d", new_name, sizeof(new_name))) {
+		log_error("Failed to generate unique name for "
+			  "pool metadata spare logical volume.");
+		return 0;
+	}
+
+	log_print_unless_silent("Renaming existing pool metadata spare "
+				"logical volume to \"%s\".", new_name);
+
+	if (!lv_rename_update(vg->cmd, lv, new_name, 0))
+		return_0;
+
+	return 1;
+}
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 8db04d3..bf3a59e 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -20,6 +20,7 @@ struct dm_pool;
 struct format_instance;
 struct dm_list;
 struct id;
+struct logical_volume;
 
 typedef enum {
 	ALLOC_INVALID,
@@ -121,6 +122,7 @@ struct volume_group {
 	uint32_t mda_copies; /* target number of mdas for this VG */
 
 	struct dm_hash_table *hostnames; /* map of creation hostnames */
+	struct logical_volume *pool_metadata_spare_lv; /* one per VG */
 };
 
 struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 9dcdb3d..8aa1f6c 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -105,6 +105,7 @@ int apply_lvname_restrictions(const char *name)
 	static const char * const _reserved_strings[] = {
 		"_mlog",
 		"_mimage",
+		"_pmspare",
 		"_rimage",
 		"_rmeta",
 		"_vorigin",
-- 
1.8.3.1


