From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Jul 2013 16:26:48 +0000 (UTC)
Subject: master - thin: add pool metadata spare lv support
Message-ID: <20130718162648.1B33360DE4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=460d0254ebc7df514081997a12238a88e8b203c6
Commit:        460d0254ebc7df514081997a12238a88e8b203c6
Parent:        08df7ba844f837c4a09540feadaa734d7f3259f8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 5 17:10:47 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 18 18:22:43 2013 +0200

thin: add pool metadata spare lv support

Add support for pool's metadata spare volume.
---
 WHATS_NEW                        |    1 +
 lib/format_text/flags.c          |    1 +
 lib/format_text/import_vsn1.c    |   12 ++++++
 lib/metadata/metadata-exported.h |    8 +++-
 lib/metadata/metadata.c          |   21 +++++++++++
 lib/metadata/thin_manip.c        |   72 ++++++++++++++++++++++++++++++++++++++
 lib/metadata/vg.h                |    4 ++-
 lib/misc/lvm-string.c            |    1 +
 tools/args.h                     |    1 +
 9 files changed, 118 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f9cfa01..e87f781 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add support for poolmetadataspare LV, that will be used for pool recovery.
   Improve activation order when creating thin pools in non-clustered VG.
   List thin-pool and thin modules for thin volumes.
   Correct thin creation error paths.
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 66dd86b..5077576 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -61,6 +61,7 @@ static const struct flag _lv_flags[] = {
 	{LV_REBUILD, "REBUILD", STATUS_FLAG},
 	{LV_WRITEMOSTLY, "WRITEMOSTLY", STATUS_FLAG},
 	{LV_ACTIVATION_SKIP, "ACTIVATION_SKIP", COMPATIBLE_FLAG},
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
index f667139..65999cd 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -97,10 +97,11 @@
 #define THIN_POOL		UINT64_C(0x0000002000000000)	/* LV */
 #define THIN_POOL_DATA		UINT64_C(0x0000004000000000)	/* LV */
 #define THIN_POOL_METADATA	UINT64_C(0x0000008000000000)	/* LV */
+#define POOL_METADATA_SPARE	UINT64_C(0x0000010000000000)	/* LV internal */
 
-#define LV_WRITEMOSTLY		UINT64_C(0x0000010000000000)	/* LV (RAID1) */
+#define LV_WRITEMOSTLY		UINT64_C(0x0000020000000000)	/* LV (RAID1) */
 
-#define LV_ACTIVATION_SKIP	UINT64_C(0x0000020000000000)	/* LV */
+#define LV_ACTIVATION_SKIP	UINT64_C(0x0000040000000000)	/* LV */
 
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
@@ -160,6 +161,7 @@
 #define lv_is_raid_type(lv)	(((lv)->status & (RAID | RAID_IMAGE | RAID_META)) ? 1 : 0)
 
 #define lv_is_virtual(lv)	(((lv)->status & VIRTUAL) ? 1 : 0)
+#define lv_is_pool_metadata_spare(lv)	(((lv)->status & POOL_METADATA_SPARE) ? 1 : 0)
 
 /* Ordered list - see lv_manip.c */
 typedef enum {
@@ -665,6 +667,8 @@ struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
 					   uint32_t stripes, uint32_t stripe_size,
 					   uint64_t size, alloc_policy_t alloc,
 					   struct dm_list *pvh);
+int vg_set_pool_metadata_spare(struct logical_volume *lv);
+int vg_remove_pool_metadata_spare(struct volume_group *vg);
 
 int attach_thin_external_origin(struct lv_segment *seg,
 				struct logical_volume *external_lv);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index c8d35c9..ddcf0a5 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2293,6 +2293,7 @@ int vg_validate(struct volume_group *vg)
 	unsigned hidden_lv_count = 0, lv_count = 0, lv_visible_count = 0;
 	unsigned pv_count = 0;
 	unsigned num_snapshots = 0;
+	unsigned spare_count = 0;
 	struct validate_hash vhash = { NULL };
 
 	if (vg->alloc == ALLOC_CLING_BY_TAGS) {
@@ -2472,6 +2473,19 @@ int vg_validate(struct volume_group *vg)
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
@@ -2524,6 +2538,13 @@ int vg_validate(struct volume_group *vg)
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
index adb0a25..9ee8a55 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -727,3 +727,75 @@ struct logical_volume *alloc_pool_metadata(struct logical_volume *pool_lv,
 
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
+				"logical volume \"%s/%s\" to \"%s/%s\".",
+                                vg->name, lv->name, vg->name, new_name);
+
+	if (!lv_rename_update(vg->cmd, lv, new_name, 0))
+		return_0;
+
+	return 1;
+}
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 8db04d3..5cc5f6d 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
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
diff --git a/tools/args.h b/tools/args.h
index cde0f91..bac507c 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -74,6 +74,7 @@ arg(originname_ARG, '\0', "originname", string_arg, 0)
 arg(poll_ARG, '\0', "poll", yes_no_arg, 0)
 arg(poolmetadata_ARG, '\0', "poolmetadata", string_arg, 0)
 arg(poolmetadatasize_ARG, '\0', "poolmetadatasize", size_mb_arg, 0)
+arg(poolmetadataspare_ARG, '\0', "poolmetadataspare", yes_no_arg, 0)
 arg(discards_ARG, '\0', "discards", discards_arg, 0)
 arg(force_long_ARG, '\0', "force", NULL, ARG_COUNTABLE)
 arg(stripes_long_ARG, '\0', "stripes", int_arg, 0)


