From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 25 Aug 2014 14:15:00 +0000 (UTC)
Subject: master - refactor: rename 'lv_type' field to 'lv_role'
Message-ID: <20140825141500.9738460FC7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=993f8d1b3f6cd6f04d0b9bfe858c35161e262dc4
Commit:        993f8d1b3f6cd6f04d0b9bfe858c35161e262dc4
Parent:        66326e2fb8c84b57505f1396d394a96ec25e12c3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Aug 25 09:07:03 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Aug 25 16:11:40 2014 +0200

refactor: rename 'lv_type' field to 'lv_role'

The 'lv_type' field name was a bit misleading. Better one is 'lv_role'
since this fields describes what's the actual use of the LV currently -
its 'role'.
---
 WHATS_NEW                        |    2 +-
 lib/metadata/lv_manip.c          |  144 +++++++++++++++++++-------------------
 lib/metadata/metadata-exported.h |    4 +-
 lib/report/columns.h             |    2 +-
 lib/report/properties.c          |    4 +-
 lib/report/report.c              |   14 ++--
 6 files changed, 85 insertions(+), 85 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index af6ced4..c42d1d5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -5,7 +5,7 @@ Version 2.02.110 -
   Allow conversion of raid1 LV into a snapshot LV or snapshot origin LV.
   Cleanly error when creating RAID with stripe size < PAGE_SIZE.
   Print name of LV which on activation triggers delayed snapshot merge.
-  Add lv_layout and lv_type LV reporting fields.
+  Add lv_layout and lv_role LV reporting fields.
   Properly display lvs lv_attr volume type and target type bit for cache origin.
   Fix pvcreate_check() to update cache correctly after signature wiping.
   Fix primary device lookup failure for partition when processing mpath filter.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d85f536..45ce19c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -151,27 +151,27 @@ static const char *_lv_type_names[] = {
 	[LV_TYPE_RAID_N_CONTINUE] =			"n-continue",
 };
 
-static int _lv_type_list_mirror(struct dm_pool *mem,
-				const struct logical_volume *lv,
-				struct dm_list *layout,
-				struct dm_list *type)
+static int _lv_layout_and_role_mirror(struct dm_pool *mem,
+				      const struct logical_volume *lv,
+				      struct dm_list *layout,
+				      struct dm_list *role)
 {
 	int top_level = 1;
 
 	if (lv_is_mirror_image(lv)) {
-		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_IMAGE]))
+		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_IMAGE]))
 			goto_bad;
 		top_level = 0;
 	} else if (lv_is_mirror_log(lv)) {
-		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_LOG]))
+		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_LOG]))
 			goto_bad;
 		if (lv_is_mirrored(lv) &&
 		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_MIRROR]))
 			goto_bad;
 		top_level = 0;
 	} else if (lv->status & PVMOVE) {
-		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_PVMOVE]) ||
-		    !str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_MIRROR]))
+		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_PVMOVE]) ||
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_MIRROR]))
 			goto_bad;
 	}
 
@@ -179,7 +179,7 @@ static int _lv_type_list_mirror(struct dm_pool *mem,
 		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_MIRROR]))
 			goto_bad;
 	} else {
-		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_MIRROR]))
+		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_MIRROR]))
 			goto_bad;
 	}
 
@@ -188,20 +188,20 @@ bad:
 	return 0;
 }
 
-static int _lv_type_list_raid(struct dm_pool *mem,
-			      const struct logical_volume *lv,
-			      struct dm_list *layout,
-			      struct dm_list *type)
+static int _lv_layout_and_role_raid(struct dm_pool *mem,
+				    const struct logical_volume *lv,
+				    struct dm_list *layout,
+				    struct dm_list *role)
 {
 	int top_level = 1;
 	const char *seg_name;
 
 	if (lv_is_raid_image(lv)) {
-		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_IMAGE]))
+		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_IMAGE]))
 			goto_bad;
 		top_level = 0;
 	} else if (lv_is_raid_metadata(lv)) {
-		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_METADATA]))
+		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_METADATA]))
 			goto_bad;
 		top_level = 0;
 	} else if (!strcmp(first_seg(lv)->segtype->name, SEG_TYPE_NAME_RAID1)) {
@@ -250,7 +250,7 @@ static int _lv_type_list_raid(struct dm_pool *mem,
 		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_RAID]))
 			goto_bad;
 	} else {
-		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_RAID]))
+		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_RAID]))
 			goto_bad;
 	}
 
@@ -259,41 +259,41 @@ bad:
 	return 0;
 }
 
-static int _lv_type_list_thin(struct dm_pool *mem,
-			      const struct logical_volume *lv,
-			      struct dm_list *layout,
-			      struct dm_list *type)
+static int _lv_layout_and_role_thin(struct dm_pool *mem,
+				    const struct logical_volume *lv,
+				    struct dm_list *layout,
+				    struct dm_list *role)
 {
 	int top_level = 1;
 	unsigned snap_count;
 	struct lv_segment *seg;
 
 	if (lv_is_thin_pool(lv)) {
-		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_THIN]) ||
-		    !str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_POOL]) ||
+		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_THIN]) ||
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_POOL]) ||
 		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_POOL]))
 			goto_bad;
 	} else if (lv_is_thin_pool_metadata(lv)) {
-		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_POOL]) ||
-		    !str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_METADATA]))
+		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_POOL]) ||
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_METADATA]))
 			goto_bad;
 		top_level = 0;
 	} else if (lv_is_thin_pool_data(lv)) {
-		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_POOL]) ||
-		    !str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_DATA]))
+		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_POOL]) ||
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_DATA]))
 			goto_bad;
 		top_level = 0;
 	} else if (lv_is_thin_volume(lv)) {
-		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_THIN]))
+		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_THIN]))
 			goto_bad;
 		if (lv_is_thin_origin(lv, &snap_count) &&
-		    !str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_ORIGIN]))
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_ORIGIN]))
 				goto_bad;
 		if (snap_count > 1 &&
-		    !str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_MULTIPLE]))
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_MULTIPLE]))
 			goto_bad;
 		if ((seg = first_seg(lv)) && (seg->origin || seg->external_lv))
-			if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_SNAPSHOT]))
+			if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_SNAPSHOT]))
 				goto_bad;
 	}
 
@@ -301,7 +301,7 @@ static int _lv_type_list_thin(struct dm_pool *mem,
 		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_THIN]))
 			goto_bad;
 	} else {
-		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_THIN]))
+		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_THIN]))
 			goto_bad;
 	}
 
@@ -310,26 +310,26 @@ bad:
 	return 0;
 }
 
-static int _lv_type_list_cache(struct dm_pool *mem,
-			       const struct logical_volume *lv,
-			       struct dm_list *layout,
-			       struct dm_list *type)
+static int _lv_layout_and_role_cache(struct dm_pool *mem,
+				     const struct logical_volume *lv,
+				     struct dm_list *layout,
+				     struct dm_list *role)
 {
 	int top_level = 1;
 
 	if (lv_is_cache_pool(lv)) {
-		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_CACHE]) ||
-		    !str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_POOL]) ||
+		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_CACHE]) ||
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_POOL]) ||
 		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_POOL]))
 			goto_bad;
 	} else if (lv_is_cache_pool_metadata(lv)) {
-		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_POOL]) ||
-		    !str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_METADATA]))
+		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_POOL]) ||
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_METADATA]))
 			goto_bad;
 		top_level = 0;
 	} else if (lv_is_cache_pool_data(lv)) {
-		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_POOL]) ||
-		    !str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_DATA]))
+		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_POOL]) ||
+		    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_DATA]))
 			goto_bad;
 		if (lv_is_cache(lv) &&
 		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_CACHE]))
@@ -341,7 +341,7 @@ static int _lv_type_list_cache(struct dm_pool *mem,
 		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_CACHE]))
 			goto_bad;
 	} else {
-		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_CACHE]))
+		if (!str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_CACHE]))
 			goto_bad;
 	}
 
@@ -350,79 +350,79 @@ bad:
 	return 0;
 }
 
-int lv_layout_and_type(struct dm_pool *mem, const struct logical_volume *lv,
-		       struct dm_list **layout, struct dm_list **type) {
+int lv_layout_and_role(struct dm_pool *mem, const struct logical_volume *lv,
+		       struct dm_list **layout, struct dm_list **role) {
 	int linear, striped, unknown;
 	struct lv_segment *seg;
 
-	*layout = *type = NULL;
+	*layout = *role = NULL;
 
 	if (!(*layout = str_list_create(mem))) {
 		log_error("LV layout list allocation failed");
 		goto bad;
 	}
 
-	if (!(*type = str_list_create(mem))) {
-		log_error("LV type list allocation failed");
+	if (!(*role = str_list_create(mem))) {
+		log_error("LV role list allocation failed");
 		goto bad;
 	}
 
 	/* Mirrors and related */
 	if (lv_is_mirror_type(lv) && !lv_is_raid(lv) &&
-	    !_lv_type_list_mirror(mem, lv, *layout, *type))
+	    !_lv_layout_and_role_mirror(mem, lv, *layout, *role))
 		goto_bad;
 
 	/* RAIDs and related */
 	if (lv_is_raid_type(lv) &&
-	    !_lv_type_list_raid(mem, lv, *layout, *type))
+	    !_lv_layout_and_role_raid(mem, lv, *layout, *role))
 		goto_bad;
 
 	/* Thins and related */
 	if (lv_is_thin_type(lv) &&
-	    !_lv_type_list_thin(mem, lv, *layout, *type))
+	    !_lv_layout_and_role_thin(mem, lv, *layout, *role))
 		goto_bad;
 
 	if (lv_is_external_origin(lv)) {
-		if (!str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_ORIGIN]) ||
-		    !str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_EXTERNAL]))
+		if (!str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_ORIGIN]) ||
+		    !str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_EXTERNAL]))
 			goto_bad;
 		if (lv->external_count > 1 &&
-		    !str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_MULTIPLE]))
+		    !str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_MULTIPLE]))
 			goto_bad;
 		if (!lv_is_thin_volume(lv) &&
-		    !str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_THIN]))
+		    !str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_THIN]))
 			goto_bad;
 	}
 
 	/* Caches and related */
 	if (lv_is_cache_type(lv) &&
-	    !_lv_type_list_cache(mem, lv, *layout, *type))
+	    !_lv_layout_and_role_cache(mem, lv, *layout, *role))
 		goto_bad;
 
 	if (lv_is_cache_origin(lv)) {
-		if (!str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_CACHE]) ||
-		    !str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_ORIGIN]))
+		if (!str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_CACHE]) ||
+		    !str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_ORIGIN]))
 			goto_bad;
 	}
 
 	/* Pool-specific */
 	if (lv_is_pool_metadata_spare(lv) &&
-	    (!str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_POOL]) ||
-	     !str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_METADATA]) ||
-	     !str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_SPARE])))
+	    (!str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_POOL]) ||
+	     !str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_METADATA]) ||
+	     !str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_SPARE])))
 		goto_bad;
 
 	/* Old-style origins/snapshots, virtual origins */
 	if (lv_is_origin(lv)) {
-		str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_ORIGIN]);
+		str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_ORIGIN]);
 		if (lv_is_virtual(lv) &&
 		    !str_list_add_no_dup_check(mem, *layout, _lv_type_names[LV_TYPE_VIRTUAL]))
 			goto_bad;
 		if (lv->origin_count > 1 &&
-		    !str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_MULTIPLE]))
+		    !str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_MULTIPLE]))
 			goto_bad;
 	} else if (lv_is_cow(lv)) {
-		if (!str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_SNAPSHOT]))
+		if (!str_list_add_no_dup_check(mem, *role, _lv_type_names[LV_TYPE_SNAPSHOT]))
 			goto_bad;
 	}
 
@@ -442,12 +442,12 @@ int lv_layout_and_type(struct dm_pool *mem, const struct logical_volume *lv,
 				 * This should not happen but if it does
 				 * we'll see that there's "unknown" layout
 				 * present. This means we forgot to detect
-				 * the type above and we need add proper
-				 * detection for such type!
+				 * the role above and we need add proper
+				 * detection for such role!
 				 */
 				unknown = 1;
 				log_error(INTERNAL_ERROR "Failed to properly detect "
-					  "layout and type for LV %s/%s",
+					  "layout and role for LV %s/%s",
 					  lv->vg->name, lv->name);
 			}
 		}
@@ -466,18 +466,18 @@ int lv_layout_and_type(struct dm_pool *mem, const struct logical_volume *lv,
 	}
 
 	/*
-	 * If type is not defined here yet, it means this is a pure top-level
+	 * If role is not defined here yet, it means this is a pure top-level
 	 * device that is not combined with any other type. So just copy what
-	 * we have set for "layout" and use it for "type" too.
+	 * we have set for "layout" and use it for "role" too.
 	 */
-	if (dm_list_empty(*type) &&
-	    !str_list_dup(mem, *type, *layout))
+	if (dm_list_empty(*role) &&
+	    !str_list_dup(mem, *role, *layout))
                 goto_bad;
 
 	return 1;
 bad:
-	if (*type)
-		dm_pool_free(mem, *type);
+	if (*role)
+		dm_pool_free(mem, *role);
 	if (*layout)
 		dm_pool_free(mem, *layout);
 	return 0;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index ff24911..0db4334 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -191,8 +191,8 @@
 #define lv_is_pool_metadata(lv)		(((lv)->status & (CACHE_POOL_METADATA | THIN_POOL_METADATA)) ? 1 : 0)
 #define lv_is_pool_metadata_spare(lv)	(((lv)->status & (POOL_METADATA_SPARE)) ? 1 : 0)
 
-int lv_layout_and_type(struct dm_pool *mem, const struct logical_volume *lv,
-		       struct dm_list **layout, struct dm_list **type);
+int lv_layout_and_role(struct dm_pool *mem, const struct logical_volume *lv,
+		       struct dm_list **layout, struct dm_list **role);
 
 /* Ordered list - see lv_manip.c */
 typedef enum {
diff --git a/lib/report/columns.h b/lib/report/columns.h
index d203f3d..78f5832 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -40,7 +40,7 @@ FIELD(LVS, lv, STR, "DMPath", lvid, 6, lvdmpath, lv_dm_path, "Internal device-ma
 FIELD(LVS, lv, STR, "Parent", lvid, 6, lvparent, lv_parent, "For LVs that are components of another LV, the parent LV.", 0)
 FIELD(LVS, lv, STR, "Attr", lvid, 4, lvstatus, lv_attr, "Various attributes - see man page.", 0)
 FIELD(LVS, lv, STR_LIST, "Layout", lvid, 10, lvlayout, lv_layout, "LV layout.", 0)
-FIELD(LVS, lv, STR_LIST, "Type", lvid, 10, lvtype, lv_type, "LV type.", 0)
+FIELD(LVS, lv, STR_LIST, "Role", lvid, 10, lvrole, lv_role, "LV role.", 0)
 FIELD(LVS, lv, BIN, "InitImgSync", lvid, 10, lvinitialimagesync, lv_initial_image_sync, "Set if mirror/RAID images underwent initial resynchronization.", 0)
 FIELD(LVS, lv, BIN, "ImgSynced", lvid, 10, lvimagesynced, lv_image_synced, "Set if mirror/RAID image is synchronized.", 0)
 FIELD(LVS, lv, BIN, "Merging", lvid, 10, lvmerging, lv_merging, "Set if snapshot LV is being merged to origin.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index eac8c2c..e0092db 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -181,8 +181,8 @@ GET_PV_NUM_PROPERTY_FN(pv_ba_size, SECTOR_SIZE * pv->ba_size)
 
 #define _lv_layout_set prop_not_implemented_set
 #define _lv_layout_get prop_not_implemented_get
-#define _lv_type_set prop_not_implemented_set
-#define _lv_type_get prop_not_implemented_get
+#define _lv_role_set prop_not_implemented_set
+#define _lv_role_get prop_not_implemented_get
 #define _lv_initial_image_sync_set prop_not_implemented_set
 #define _lv_initial_image_sync_get prop_not_implemented_get
 #define _lv_image_synced_get prop_not_implemented_get
diff --git a/lib/report/report.c b/lib/report/report.c
index 69151e0..32aca88 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1324,9 +1324,9 @@ static int _lvlayout_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct dm_list *lv_layout;
-	struct dm_list *lv_type;
+	struct dm_list *lv_role;
 
-	if (!lv_layout_and_type(mem, lv, &lv_layout, &lv_type)) {
+	if (!lv_layout_and_role(mem, lv, &lv_layout, &lv_role)) {
 		log_error("Failed to display layout for LV %s/%s.", lv->vg->name, lv->name);
 		return 0;
 	}
@@ -1334,20 +1334,20 @@ static int _lvlayout_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _field_set_string_list(rh, field, lv_layout, private);
 }
 
-static int _lvtype_disp(struct dm_report *rh, struct dm_pool *mem,
+static int _lvrole_disp(struct dm_report *rh, struct dm_pool *mem,
 			      struct dm_report_field *field,
 			      const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct dm_list *lv_layout;
-	struct dm_list *lv_type;
+	struct dm_list *lv_role;
 
-	if (!lv_layout_and_type(mem, lv, &lv_layout, &lv_type)) {
-		log_error("Failed to display type for LV %s/%s.", lv->vg->name, lv->name);
+	if (!lv_layout_and_role(mem, lv, &lv_layout, &lv_role)) {
+		log_error("Failed to display role for LV %s/%s.", lv->vg->name, lv->name);
 		return 0;
 	}
 
-	return _field_set_string_list(rh, field, lv_type, private);
+	return _field_set_string_list(rh, field, lv_role, private);
 }
 
 static int _lvinitialimagesync_disp(struct dm_report *rh, struct dm_pool *mem,


