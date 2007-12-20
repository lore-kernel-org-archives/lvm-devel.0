From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Dec 2007 22:37:43 -0000
Subject: LVM2 lib/metadata/lv_manip.c lib/metadata/meta ...
Message-ID: <20071220223743.14723.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-12-20 22:37:42

Modified files:
	lib/metadata   : lv_manip.c metadata-exported.h mirror.c 
	tools          : toollib.c toollib.h 

Log message:
	various cleanups in recent patches

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.138&r2=1.139
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.120&r2=1.121
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.53&r2=1.54

--- LVM2/lib/metadata/lv_manip.c	2007/12/20 18:55:46	1.138
+++ LVM2/lib/metadata/lv_manip.c	2007/12/20 22:37:42	1.139
@@ -2280,7 +2280,7 @@
 	struct segment_type *segtype;
 	struct lv_segment *mapseg;
 
-	if (!(segtype = get_segtype_from_string(lv_where->vg->cmd, "striped")))
+	if (!(segtype = get_segtype_from_string(cmd, "striped")))
 		return_NULL;
 
 	/* create an empty layer LV */
@@ -2310,7 +2310,7 @@
 	_move_lv_segments(layer_lv, lv_where, 0, 0);
 
 	/* allocate a new linear segment */
-	if (!(mapseg = alloc_lv_segment(lv_where->vg->cmd->mem, segtype,
+	if (!(mapseg = alloc_lv_segment(cmd->mem, segtype,
 					lv_where, 0, layer_lv->le_count,
 					status, 0, NULL, 1, layer_lv->le_count,
 					0, 0, 0)))
@@ -2520,3 +2520,51 @@
 
 	return 1;
 }
+
+/*
+ * Initialize the LV with 'value'.
+ */
+int set_lv(struct cmd_context *cmd, struct logical_volume *lv,
+	   uint64_t sectors, int value)
+{
+	struct device *dev;
+	char *name;
+
+	/*
+	 * FIXME:
+	 * <clausen> also, more than 4k
+	 * <clausen> say, reiserfs puts it's superblock 32k in, IIRC
+	 * <ejt_> k, I'll drop a fixme to that effect
+	 *	   (I know the device is at least 4k, but not 32k)
+	 */
+	if (!(name = dm_pool_alloc(cmd->mem, PATH_MAX))) {
+		log_error("Name allocation failed - device not cleared");
+		return 0;
+	}
+
+	if (dm_snprintf(name, PATH_MAX, "%s%s/%s", cmd->dev_dir,
+			 lv->vg->name, lv->name) < 0) {
+		log_error("Name too long - device not cleared (%s)", lv->name);
+		return 0;
+	}
+
+	log_verbose("Clearing start of logical volume \"%s\"", lv->name);
+
+	if (!(dev = dev_cache_get(name, NULL))) {
+		log_error("%s: not found: device not cleared", name);
+		return 0;
+	}
+
+	if (!dev_open_quiet(dev))
+		return 0;
+
+	dev_set(dev, UINT64_C(0),
+		sectors ? (size_t) sectors << SECTOR_SHIFT : (size_t) 4096,
+		value);
+	dev_flush(dev);
+	dev_close_immediate(dev);
+
+	return 1;
+}
+
+
--- LVM2/lib/metadata/metadata-exported.h	2007/12/20 18:55:46	1.27
+++ LVM2/lib/metadata/metadata-exported.h	2007/12/20 22:37:42	1.28
@@ -88,6 +88,10 @@
 #define CORRECT_INCONSISTENT    0x00000001U /* Correct inconsistent metadata */
 #define FAIL_INCONSISTENT       0x00000002U /* Fail if metadata inconsistent */
 
+/* Mirror conversion type flags */
+#define MIRROR_BY_SEG		0x00000001U	/* segment-by-segment mirror */
+#define MIRROR_BY_LV		0x00000002U	/* mirror by mimage LVs */
+
 /* Ordered list - see lv_manip.c */
 typedef enum {
 	ALLOC_INVALID,
@@ -355,6 +359,10 @@
 				       int import,
 				       struct volume_group *vg);
 
+/* Write out LV contents */
+int set_lv(struct cmd_context *cmd, struct logical_volume *lv,
+           uint64_t sectors, int value);
+
 /* Reduce the size of an LV by extents */
 int lv_reduce(struct logical_volume *lv, uint32_t extents);
 
@@ -457,9 +465,6 @@
 int lv_remove_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		      uint32_t mirrors, uint32_t log_count,
 		      struct list *pvs, uint32_t status_mask);
-/* conversion flags */
-#define MIRROR_BY_SEG	0x00000001U	/* segment-by-segment mirror */
-#define MIRROR_BY_LV	0x00000002U	/* mirror by mimage LVs */
 
 int is_temporary_mirror_layer(const struct logical_volume *lv);
 uint32_t lv_mirror_count(const struct logical_volume *lv);
--- LVM2/lib/metadata/mirror.c	2007/12/20 18:55:46	1.47
+++ LVM2/lib/metadata/mirror.c	2007/12/20 22:37:42	1.48
@@ -27,6 +27,11 @@
 
 #include "defaults.h" /* FIXME: should this be defaults.h? */
 
+/* These are necessary for _write_log_header() */
+#include "xlate.h"
+#define MIRROR_MAGIC 0x4D695272
+#define MIRROR_DISK_VERSION 2
+
 /* These are the flags that represent the mirror failure restoration policies */
 #define MIRROR_REMOVE            0
 #define MIRROR_ALLOCATE          1
@@ -332,7 +337,7 @@
 static int _merge_mirror_images(struct logical_volume *lv,
 				const struct list *mimages)
 {
-	int addition = list_size(mimages);
+	uint32_t addition = list_size(mimages);
 	struct logical_volume **img_lvs;
 	struct lv_list *lvl;
 	int i = 0;
@@ -893,60 +898,10 @@
 }
 
 /*
- * Initialize the LV with 'value'.
- */
-static int _set_lv(struct cmd_context *cmd, struct logical_volume *lv,
-	   uint64_t sectors, int value)
-{
-	struct device *dev;
-	char *name;
-
-	/*
-	 * FIXME:
-	 * <clausen> also, more than 4k
-	 * <clausen> say, reiserfs puts it's superblock 32k in, IIRC
-	 * <ejt_> k, I'll drop a fixme to that effect
-	 *	   (I know the device is at least 4k, but not 32k)
-	 */
-	if (!(name = dm_pool_alloc(cmd->mem, PATH_MAX))) {
-		log_error("Name allocation failed - device not cleared");
-		return 0;
-	}
-
-	if (dm_snprintf(name, PATH_MAX, "%s%s/%s", cmd->dev_dir,
-			 lv->vg->name, lv->name) < 0) {
-		log_error("Name too long - device not cleared (%s)", lv->name);
-		return 0;
-	}
-
-	log_verbose("Clearing start of logical volume \"%s\"", lv->name);
-
-	if (!(dev = dev_cache_get(name, NULL))) {
-		log_error("%s: not found: device not cleared", name);
-		return 0;
-	}
-
-	if (!dev_open_quiet(dev))
-		return 0;
-
-	dev_set(dev, UINT64_C(0),
-		sectors ? (size_t) sectors << SECTOR_SHIFT : (size_t) 4096,
-		value);
-	dev_flush(dev);
-	dev_close_immediate(dev);
-
-	return 1;
-}
-
-/*
  * This function writes a new header to the mirror log header to the lv
  *
  * Returns: 1 on success, 0 on failure
  */
-#include "xlate.h"
-#define MIRROR_MAGIC 0x4D695272
-#define MIRROR_DISK_VERSION 2
-
 static int _write_log_header(struct cmd_context *cmd, struct logical_volume *lv)
 {
 	struct device *dev;
@@ -1036,7 +991,7 @@
 			log_error("Failed to remove tag %s from mirror log.",
 				  sl->str);
 
-	if (activation() && !_set_lv(cmd, log_lv, log_lv->size,
+	if (activation() && !set_lv(cmd, log_lv, log_lv->size,
 				    in_sync ? -1 : 0)) {
 		log_error("Aborting. Failed to wipe mirror log.");
 		goto deactivate_and_revert_new_lv;
@@ -1072,11 +1027,10 @@
 	return 0;
 }
 
-static struct logical_volume *_create_mirror_log(struct cmd_context *cmd,
-					 struct logical_volume *lv,
-					 struct alloc_handle *ah,
-					 alloc_policy_t alloc,
-					 const char *lv_name)
+static struct logical_volume *_create_mirror_log(struct logical_volume *lv,
+						 struct alloc_handle *ah,
+						 alloc_policy_t alloc,
+						 const char *lv_name)
 {
 	struct logical_volume *log_lv;
 	char *log_name;
@@ -1108,7 +1062,7 @@
 						 struct alloc_handle *ah,
 						 struct logical_volume *lv,
 						 uint32_t log_count,
-						 uint32_t region_size,
+						 uint32_t region_size __attribute((unused)),
 						 alloc_policy_t alloc,
 						 int in_sync)
 {
@@ -1116,7 +1070,12 @@
 
 	init_mirror_in_sync(in_sync);
 
-	if (!(log_lv = _create_mirror_log(cmd, lv, ah, alloc, lv->name))) {
+	if (log_count != 1) {
+		log_error("log_count != 1 is not supported.");
+		return NULL;
+	}
+
+	if (!(log_lv = _create_mirror_log(lv, ah, alloc, lv->name))) {
 		log_error("Failed to create mirror log.");
 		return NULL;
 	}
@@ -1341,7 +1300,8 @@
  * 'mirror' is the number of mirrors to be removed.
  * 'pvs' is removable pvs.
  */
-int lv_remove_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
+int lv_remove_mirrors(struct cmd_context *cmd __attribute((unused)),
+		      struct logical_volume *lv,
 		      uint32_t mirrors, uint32_t log_count, struct list *pvs,
 		      uint32_t status_mask)
 {
--- LVM2/tools/toollib.c	2007/12/20 18:55:46	1.120
+++ LVM2/tools/toollib.c	2007/12/20 22:37:42	1.121
@@ -1246,50 +1246,3 @@
 
 	return 1;
 }
-
-/*
- * Initialize the LV with 'value'.
- */
-int set_lv(struct cmd_context *cmd, struct logical_volume *lv,
-	   uint64_t sectors, int value)
-{
-	struct device *dev;
-	char *name;
-
-	/*
-	 * FIXME:
-	 * <clausen> also, more than 4k
-	 * <clausen> say, reiserfs puts it's superblock 32k in, IIRC
-	 * <ejt_> k, I'll drop a fixme to that effect
-	 *	   (I know the device is at least 4k, but not 32k)
-	 */
-	if (!(name = dm_pool_alloc(cmd->mem, PATH_MAX))) {
-		log_error("Name allocation failed - device not cleared");
-		return 0;
-	}
-
-	if (dm_snprintf(name, PATH_MAX, "%s%s/%s", cmd->dev_dir,
-			 lv->vg->name, lv->name) < 0) {
-		log_error("Name too long - device not cleared (%s)", lv->name);
-		return 0;
-	}
-
-	log_verbose("Clearing start of logical volume \"%s\"", lv->name);
-
-	if (!(dev = dev_cache_get(name, NULL))) {
-		log_error("%s: not found: device not cleared", name);
-		return 0;
-	}
-
-	if (!dev_open_quiet(dev))
-		return 0;
-
-	dev_set(dev, UINT64_C(0),
-		sectors ? (size_t) sectors << SECTOR_SHIFT : (size_t) 4096,
-		value);
-	dev_flush(dev);
-	dev_close_immediate(dev);
-
-	return 1;
-}
-
--- LVM2/tools/toollib.h	2007/12/20 15:42:55	1.53
+++ LVM2/tools/toollib.h	2007/12/20 22:37:42	1.54
@@ -98,7 +98,4 @@
 
 int validate_new_vg_name(struct cmd_context *cmd, const char *vg_name);
 
-int set_lv(struct cmd_context *cmd, struct logical_volume *lv,
-	   uint64_t sectors, int value);
-
 #endif


