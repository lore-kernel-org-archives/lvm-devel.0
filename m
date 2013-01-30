From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 30 Jan 2013 17:03:11 -0600
Subject: [PATCH] rename 'mirror_region_size' to the more generic 'raid_region_size'
Message-ID: <1359586991.23103.0.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Someone was asking about the default region_size for RAID5 LVs on IRC.
I think it is somewhat confusing to refer them to 'mirror_region_size'
for this.  So, I've changed the name of this setting.

Thoughts?
 brassow

clean-up:  Rename lvm.conf setting 'mirror_region_size' to 'raid_region_size'

We have been using 'mirror_region_size' in lvm.conf as the default region
size for RAID logical volumes as well as mirror logical volumes.  Since,
"raid" is more inclusive and representative than "mirror", I have changed
the name of this setting.  We must still check for the old setting and warn
the user if we are overriding it with the new setting if both happen to be
present.


Index: lvm2/doc/example.conf.in
===================================================================
--- lvm2.orig/doc/example.conf.in
+++ lvm2/doc/example.conf.in
@@ -637,8 +637,12 @@ activation {
     #
     # read_only_volume_list = [ "vg1", "vg2/lvol1", "@tag1", "@*" ]
 
-    # Size (in KB) of each copy operation when mirroring
-    mirror_region_size = 512
+    # For RAID or 'mirror' segment types, 'raid_region_size' is the
+    # size (in kiB) of each:
+    # - synchronization operation when initializing
+    # - each copy operation when performing a 'pvmove' (using 'mirror' segtype)
+    # This setting has replaced 'mirror_region_size' since version 2.02.99
+    raid_region_size = 512
 
     # Setting to use when there is no readahead value stored in the metadata.
     #
Index: lvm2/lib/config/defaults.h
===================================================================
--- lvm2.orig/lib/config/defaults.h
+++ lvm2/lib/config/defaults.h
@@ -142,7 +142,7 @@
 
 #define DEFAULT_USE_LINEAR_TARGET 1
 #define DEFAULT_STRIPE_FILLER "error"
-#define DEFAULT_MIRROR_REGION_SIZE 512	/* KB */
+#define DEFAULT_RAID_REGION_SIZE   512	/* KB */
 #define DEFAULT_INTERVAL 15
 
 #ifdef READLINE_SUPPORT
Index: lvm2/lib/mirror/mirrored.c
===================================================================
--- lvm2.orig/lib/mirror/mirrored.c
+++ lvm2/lib/mirror/mirrored.c
@@ -162,10 +162,7 @@ static struct mirror_state *_mirrored_in
 		return NULL;
 	}
 
-	mirr_state->default_region_size = 2 *
-	    find_config_tree_int(cmd,
-			    "activation/mirror_region_size",
-			    DEFAULT_MIRROR_REGION_SIZE);
+	mirr_state->default_region_size = get_default_region_size(cmd);
 
 	return mirr_state;
 }
Index: lvm2/tools/lvcreate.c
===================================================================
--- lvm2.orig/tools/lvcreate.c
+++ lvm2/tools/lvcreate.c
@@ -457,9 +457,7 @@ static int _read_mirror_params(struct lv
 		}
 		lp->region_size = arg_uint_value(cmd, regionsize_ARG, 0);
 	} else {
-		region_size = 2 * find_config_tree_int(cmd,
-					"activation/mirror_region_size",
-					DEFAULT_MIRROR_REGION_SIZE);
+		region_size = get_default_region_size(cmd);
 		if (region_size < 0) {
 			log_error("Negative regionsize in configuration file "
 				  "is invalid");
Index: lvm2/lib/metadata/lv_manip.c
===================================================================
--- lvm2.orig/lib/metadata/lv_manip.c
+++ lvm2/lib/metadata/lv_manip.c
@@ -72,6 +72,49 @@ struct lv_names {
 	const char *new;
 };
 
+/*
+ * get_default_region_size
+ * @cmd
+ *
+ * 'mirror_region_size' and 'raid_region_size' are effectively the same thing.
+ * However, "raid" is more inclusive than "mirror", so the name has been
+ * changed.  This function checks for the old setting and warns the user if
+ * it is being overridden by the new setting (i.e. warn if both settings are
+ * present).
+ *
+ * Note that the config files give defaults in kiB terms, but we
+ * return the value in terms of sectors.
+ *
+ * Returns: default region_size in sectors
+ */
+int get_default_region_size(struct cmd_context *cmd)
+{
+	int mrs, rrs;
+
+	/*
+	 * 'mirror_region_size' is the old setting.  It is overridden
+	 * by the new setting, 'raid_region_size'.
+	 */
+	mrs = 2 * find_config_tree_int(cmd, "activation/mirror_region_size", 0);
+	rrs = 2 * find_config_tree_int(cmd, "activation/raid_region_size", 0);
+
+	if (!mrs && !rrs)
+		return DEFAULT_RAID_REGION_SIZE * 2;
+
+	if (!mrs)
+		return rrs;
+
+	if (!rrs)
+		return mrs;
+
+	if (mrs != rrs)
+		log_verbose("Overriding default 'mirror_region_size' setting"
+			    " with 'raid_region_size' setting of %u kiB",
+			    rrs / 2);
+
+	return rrs;
+}
+
 int add_seg_to_segs_using_this_lv(struct logical_volume *lv,
 				  struct lv_segment *seg)
 {
Index: lvm2/lib/metadata/metadata-exported.h
===================================================================
--- lvm2.orig/lib/metadata/metadata-exported.h
+++ lvm2/lib/metadata/metadata-exported.h
@@ -726,6 +726,7 @@ int vg_max_lv_reached(struct volume_grou
 /*
 * Mirroring functions
 */
+int get_default_region_size(struct cmd_context *cmd);  /* in lv_manip.c */
 struct lv_segment *find_mirror_seg(struct lv_segment *seg);
 int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		   uint32_t mirrors, uint32_t stripes, uint32_t stripe_size,
Index: lvm2/lib/metadata/raid_manip.c
===================================================================
--- lvm2.orig/lib/metadata/raid_manip.c
+++ lvm2/lib/metadata/raid_manip.c
@@ -21,8 +21,6 @@
 #include "lv_alloc.h"
 #include "lvm-string.h"
 
-#define RAID_REGION_SIZE 1024
-
 static int _lv_is_raid_with_tracking(const struct logical_volume *lv,
 				     struct logical_volume **tracking)
 {
@@ -528,7 +526,7 @@ static int _alloc_image_components(struc
 		return_0;
 
 	if (seg_is_linear(seg))
-		region_size = RAID_REGION_SIZE;
+		region_size = get_default_region_size(lv->vg->cmd);
 	else
 		region_size = seg->region_size;
 
@@ -730,7 +728,8 @@ static int _raid_add_images(struct logic
 		lv->status |= RAID;
 		seg = first_seg(lv);
 		seg_lv(seg, 0)->status |= RAID_IMAGE | LVM_READ | LVM_WRITE;
-		seg->region_size = RAID_REGION_SIZE;
+		seg->region_size = get_default_region_size(lv->vg->cmd);
+
 		/* MD's bitmap is limited to tracking 2^21 regions */
 		while (seg->region_size < (lv->size / (1 << 21))) {
 			seg->region_size *= 2;
Index: lvm2/tools/lvconvert.c
===================================================================
--- lvm2.orig/tools/lvconvert.c
+++ lvm2/tools/lvconvert.c
@@ -399,9 +399,7 @@ static int _read_params(struct lvconvert
 			}
 			lp->region_size = arg_uint_value(cmd, regionsize_ARG, 0);
 		} else {
-			region_size = 2 * find_config_tree_int(cmd,
-						"activation/mirror_region_size",
-						DEFAULT_MIRROR_REGION_SIZE);
+			region_size = get_default_region_size(cmd);
 			if (region_size < 0) {
 				log_error("Negative regionsize in "
 					  "configuration file is invalid");




