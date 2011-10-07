From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 7 Oct 2011 14:56:02 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20111007145602.21371.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-10-07 14:56:01

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h raid_manip.c 
	test           : t-lvconvert-raid.sh 
	tools          : lvconvert.c 

Log message:
	Add the ability to convert LVs of "mirror" segtype to "raid1" segtype.
	
	Example:
	~> lvconvert --type raid1 vg/mirror_lv
	
	Steps to convert "mirror" to "raid1"
	1) Allocate a RAID metadata LV for each mirror image from the same PVs
	on which they are located.
	2) Clear the metadata LVs.  This involves writing LVM metadata, so we don't
	change any aspects of the mirror LV before this so that the user can easily
	remove LVs from the failed convert attempt while retaining the original
	mirror.
	3) Remove the mirror log, if it exists.
	4) Add metadata LVs to mirror LV
	5) Rename mirror sub-lvs (s/mimage/rimage/)
	6) Change flags and segtype from mirror to raid1

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2151&r2=1.2152
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.213&r2=1.214
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/raid_manip.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-raid.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.173&r2=1.174

--- LVM2/WHATS_NEW	2011/10/07 14:52:26	1.2151
+++ LVM2/WHATS_NEW	2011/10/07 14:56:01	1.2152
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Add ability to convert mirror segtype to RAID1 segtype.
   Add ability to convert from linear to RAID1.
   Add ability to extend mirrors with '--nosync' option.
   Fix splitmirror in cluster having different DM/LVM views of storage.
--- LVM2/lib/metadata/metadata-exported.h	2011/09/29 08:56:39	1.213
+++ LVM2/lib/metadata/metadata-exported.h	2011/10/07 14:56:01	1.214
@@ -770,6 +770,8 @@
 int lv_raid_split_and_track(struct logical_volume *lv,
 			    struct dm_list *splittable_pvs);
 int lv_raid_merge(struct logical_volume *lv);
+int lv_raid_reshape(struct logical_volume *lv,
+		    const struct segment_type *new_segtype);
 
 /* --  metadata/raid_manip.c */
 
--- LVM2/lib/metadata/raid_manip.c	2011/10/07 14:52:27	1.16
+++ LVM2/lib/metadata/raid_manip.c	2011/10/07 14:56:01	1.17
@@ -166,6 +166,16 @@
 	return 1;
 }
 
+/*
+ * _raid_in_sync
+ * @lv
+ *
+ * _raid_in_sync works for all types of RAID segtypes, as well
+ * as 'mirror' segtype.  (This is because 'lv_raid_percent' is
+ * simply a wrapper around 'lv_mirror_percent'.
+ *
+ * Returns: 1 if in-sync, 0 otherwise.
+ */
 static int _raid_in_sync(struct logical_volume *lv)
 {
 	percent_t sync_percent;
@@ -399,20 +409,22 @@
  * This function does not make metadata changes.
  */
 static int _alloc_image_component(struct logical_volume *lv,
+				  const char *alt_base_name,
 				  struct alloc_handle *ah, uint32_t first_area,
 				  uint64_t type, struct logical_volume **new_lv)
 {
 	uint64_t status;
 	size_t len = strlen(lv->name) + 32;
 	char img_name[len];
+	const char *base_name = (alt_base_name) ? alt_base_name : lv->name;
 	struct logical_volume *tmp_lv;
 	const struct segment_type *segtype;
 
 	if (type == RAID_META) {
-		if (dm_snprintf(img_name, len, "%s_rmeta_%%d", lv->name) < 0)
+		if (dm_snprintf(img_name, len, "%s_rmeta_%%d", base_name) < 0)
 			return_0;
 	} else if (type == RAID_IMAGE) {
-		if (dm_snprintf(img_name, len, "%s_rimage_%%d", lv->name) < 0)
+		if (dm_snprintf(img_name, len, "%s_rimage_%%d", base_name) < 0)
 			return_0;
 	} else {
 		log_error(INTERNAL_ERROR
@@ -490,13 +502,14 @@
 		 * allocated areas.  Thus, the metadata areas are pulled
 		 * from 's + count'.
 		 */
-		if (!_alloc_image_component(lv, ah, s + count,
+		if (!_alloc_image_component(lv, NULL, ah, s + count,
 					    RAID_META, &tmp_lv))
 			return_0;
 		lvl_array[s + count].lv = tmp_lv;
 		dm_list_add(new_meta_lvs, &(lvl_array[s + count].list));
 
-		if (!_alloc_image_component(lv, ah, s, RAID_IMAGE, &tmp_lv))
+		if (!_alloc_image_component(lv, NULL, ah, s,
+					    RAID_IMAGE, &tmp_lv))
 			return_0;
 		lvl_array[s].lv = tmp_lv;
 		dm_list_add(new_data_lvs, &(lvl_array[s].list));
@@ -519,6 +532,7 @@
 	struct dm_list allocatable_pvs;
 	struct alloc_handle *ah;
 	struct lv_segment *seg = first_seg(data_lv);
+	char *p, base_name[strlen(data_lv->name) + 1];
 
 	dm_list_init(&allocatable_pvs);
 
@@ -528,10 +542,9 @@
 		return 0;
 	}
 
-	if (strstr("_mimage_", data_lv->name)) {
-		log_error("Unable to alloc metadata device for mirror device");
-		return 0;
-	}
+	sprintf(base_name, "%s", data_lv->name);
+	if ((p = strstr(base_name, "_mimage_")))
+		*p = '\0';
 
 	if (!_get_pv_list_for_lv(data_lv, &allocatable_pvs)) {
 		log_error("Failed to build list of PVs for %s/%s",
@@ -545,7 +558,8 @@
 				    &allocatable_pvs, data_lv->alloc, NULL)))
 		return_0;
 
-	if (!_alloc_image_component(data_lv, ah, 0, RAID_META, meta_lv))
+	if (!_alloc_image_component(data_lv, base_name, ah, 0,
+				    RAID_META, meta_lv))
 		return_0;
 
 	alloc_destroy(ah);
@@ -1264,3 +1278,153 @@
 		  vg->name, lv->name);
 	return 1;
 }
+
+static int _convert_mirror_to_raid1(struct logical_volume *lv,
+				    const struct segment_type *new_segtype)
+{
+	uint32_t s;
+	struct lv_segment *seg = first_seg(lv);
+	struct lv_list lvl_array[seg->area_count], *lvl;
+	struct dm_list meta_lvs;
+	struct lv_segment_area *meta_areas;
+
+	dm_list_init(&meta_lvs);
+
+	if (!_raid_in_sync(lv)) {
+		log_error("Unable to convert %s/%s while it is not in-sync",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	meta_areas = dm_pool_zalloc(lv->vg->vgmem,
+				    lv_mirror_count(lv) * sizeof(*meta_areas));
+	if (!meta_areas) {
+		log_error("Failed to allocate memory");
+		return 0;
+	}
+
+	for (s = 0; s < seg->area_count; s++) {
+		log_debug("Allocating new metadata LV for %s",
+			  seg_lv(seg, s)->name);
+		if (!_alloc_rmeta_for_lv(seg_lv(seg, s), &(lvl_array[s].lv))) {
+			log_error("Failed to allocate metadata LV for %s in %s",
+				  seg_lv(seg, s)->name, lv->name);
+			return 0;
+		}
+		dm_list_add(&meta_lvs, &(lvl_array[s].list));
+	}
+
+	log_debug("Clearing newly allocated metadata LVs");
+	if (!_clear_lvs(&meta_lvs)) {
+		log_error("Failed to initialize metadata LVs");
+		return 0;
+	}
+
+	if (seg->log_lv) {
+		log_debug("Removing mirror log, %s", seg->log_lv->name);
+		if (!remove_mirror_log(lv->vg->cmd, lv, NULL, 0)) {
+			log_error("Failed to remove mirror log");
+			return 0;
+		}
+	}
+
+	seg->meta_areas = meta_areas;
+	s = 0;
+
+	dm_list_iterate_items(lvl, &meta_lvs) {
+		log_debug("Adding %s to %s", lvl->lv->name, lv->name);
+
+		/* Images are known to be in-sync */
+		lvl->lv->status &= ~LV_NOTSYNCED;
+		first_seg(lvl->lv)->status &= ~LV_NOTSYNCED;
+		lv_set_hidden(lvl->lv);
+
+		if (!set_lv_segment_area_lv(seg, s, lvl->lv, 0,
+					    lvl->lv->status)) {
+			log_error("Failed to add %s to %s",
+				  lvl->lv->name, lv->name);
+			return 0;
+		}
+		s++;
+	}
+
+	for (s = 0; s < seg->area_count; s++) {
+		char *new_name;
+
+		new_name = dm_pool_zalloc(lv->vg->vgmem,
+					  strlen(lv->name) +
+					  strlen("_rimage_XXn"));
+		if (!new_name) {
+			log_error("Failed to rename mirror images");
+			return 0;
+		}
+
+		sprintf(new_name, "%s_rimage_%u", lv->name, s);
+		log_debug("Renaming %s to %s", seg_lv(seg, s)->name, new_name);
+		seg_lv(seg, s)->name = new_name;
+		seg_lv(seg, s)->status &= ~MIRROR_IMAGE;
+		seg_lv(seg, s)->status |= RAID_IMAGE;
+	}
+	init_mirror_in_sync(1);
+
+	log_debug("Setting new segtype for %s", lv->name);
+	seg->segtype = new_segtype;
+	lv->status &= ~MIRRORED;
+	lv->status |= RAID;
+	seg->status |= RAID;
+
+	if (!vg_write(lv->vg)) {
+		log_error("Failed to write changes to %s in %s",
+			  lv->name, lv->vg->name);
+		return 0;
+	}
+
+	if (!suspend_lv(lv->vg->cmd, lv)) {
+		log_error("Failed to suspend %s/%s before committing changes",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	if (!vg_commit(lv->vg)) {
+		log_error("Failed to commit changes to %s in %s",
+			  lv->name, lv->vg->name);
+		return 0;
+	}
+
+	if (!resume_lv(lv->vg->cmd, lv)) {
+		log_error("Failed to resume %s/%s after committing changes",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
+ * lv_raid_reshape
+ * @lv
+ * @new_segtype
+ *
+ * Convert an LV from one RAID type (or 'mirror' segtype) to another.
+ *
+ * Returns: 1 on success, 0 on failure
+ */
+int lv_raid_reshape(struct logical_volume *lv,
+		    const struct segment_type *new_segtype)
+{
+	struct lv_segment *seg = first_seg(lv);
+
+	if (!new_segtype) {
+		log_error(INTERNAL_ERROR "New segtype not specified");
+		return 0;
+	}
+
+	if (!strcmp(seg->segtype->name, "mirror") &&
+	    (!strcmp(new_segtype->name, "raid1")))
+	    return _convert_mirror_to_raid1(lv, new_segtype);
+
+	log_error("Converting the segment type for %s/%s from %s to %s"
+		  " is not yet supported.", lv->vg->name, lv->name,
+		  seg->segtype->name, new_segtype->name);
+	return 0;
+}
--- LVM2/test/t-lvconvert-raid.sh	2011/10/07 14:52:27	1.2
+++ LVM2/test/t-lvconvert-raid.sh	2011/10/07 14:56:01	1.3
@@ -12,8 +12,8 @@
 
 . lib/test
 
-# is_raid_in_sync <VG/LV>
-function is_raid_in_sync()
+# is_in_sync <VG/LV>
+function is_in_sync()
 {
 	local dm_name
 	local a
@@ -26,7 +26,19 @@
 		echo "Unable to get sync status of $1"
 		exit 1
 	fi
-	idx=$((${#a[@]} - 1))
+
+	# 6th argument is the sync ratio for RAID and mirror
+	echo ${a[@]}
+	if [ ${a[2]} = "raid" ]; then
+		# Last argument is the sync ratio for RAID
+		idx=$((${#a[@]} - 1))
+	elif [ ${a[2]} = "mirror" ]; then
+		# 4th Arg tells us how far to the sync ratio
+		idx=$((${a[3]} + 4))
+	else
+		echo "Unable to get sync ratio for target type '${a[2]}'"
+		exit 1
+	fi
 	b=(`echo ${a[$idx]} | sed s:/:' ':`)
 
 	if [ ${b[0]} != ${b[1]} ]; then
@@ -39,16 +51,21 @@
 		exit 1
 	fi
 
-	echo "$dm_name (${a[3]}) is in-sync"
+	if [ ${a[2]} = "raid" ]; then
+		echo "$dm_name (${a[3]}) is in-sync"
+	else
+		echo "$dm_name (${a[2]}) is in-sync"
+	fi
+
 	return 0
 }
 
-# wait_for_raid_sync <VG/LV>
-function wait_for_raid_sync()
+# wait_for_sync <VG/LV>
+function wait_for_sync()
 {
 	local i=0
 
-	while ! is_raid_in_sync $1; do
+	while ! is_in_sync $1; do
 		sleep 2
 		i=$(($i + 1))
 		if [ $i -gt 500 ]; then
@@ -106,7 +123,7 @@
 			lvcreate -l 2 -n $lv1 $vg
 		else
 			lvcreate --type raid1 -m $(($i - 1)) -l 2 -n $lv1 $vg
-			wait_for_raid_sync $vg/$lv1
+			wait_for_sync $vg/$lv1
 		fi
 		lvconvert -m $((j - 1))  $vg/$lv1
 
@@ -128,7 +145,7 @@
 ###########################################
 # 3-way to 2-way/linear
 lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg
-wait_for_raid_sync $vg/$lv1
+wait_for_sync $vg/$lv1
 lvconvert --splitmirrors 1 -n $lv2 $vg/$lv1
 check lv_exists $vg $lv1
 check linear $vg $lv2
@@ -137,7 +154,7 @@
 
 # 2-way to linear/linear
 lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg
-wait_for_raid_sync $vg/$lv1
+wait_for_sync $vg/$lv1
 lvconvert --splitmirrors 1 -n $lv2 $vg/$lv1
 check linear $vg $lv1
 check linear $vg $lv2
@@ -146,8 +163,8 @@
 
 # 3-way to linear/2-way
 lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg
-wait_for_raid_sync $vg/$lv1
-# FIXME: Can't split off a mirror from a mirror yet
+wait_for_sync $vg/$lv1
+# FIXME: Can't split off a RAID1 from a RAID1 yet
 should lvconvert --splitmirrors 2 -n $lv2 $vg/$lv1
 #check linear $vg $lv1
 #check lv_exists $vg $lv2
@@ -159,10 +176,22 @@
 ###########################################
 # 3-way to 2-way/linear
 lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg
-wait_for_raid_sync $vg/$lv1
+wait_for_sync $vg/$lv1
 lvconvert --splitmirrors 1 --trackchanges $vg/$lv1
 check lv_exists $vg $lv1
 check linear $vg ${lv1}_rimage_2
 lvconvert --merge $vg/${lv1}_rimage_2
 # FIXME: ensure no residual devices
 lvremove -ff $vg
+
+###########################################
+# Mirror to RAID1 conversion
+###########################################
+for i in 1 2 3 ; do
+	lvcreate --type mirror -m $i -l 2 -n $lv1 $vg
+	wait_for_sync $vg/$lv1
+	lvconvert --type raid1 $vg/$lv1
+	lvremove -ff $vg
+done
+
+exit 0
--- LVM2/tools/lvconvert.c	2011/10/07 14:52:27	1.173
+++ LVM2/tools/lvconvert.c	2011/10/07 14:56:01	1.174
@@ -1452,6 +1452,9 @@
 	if (arg_count(cmd, mirrors_ARG))
 		return lv_raid_change_image_count(lv, image_count, lp->pvh);
 
+	if (arg_count(cmd, type_ARG))
+		return lv_raid_reshape(lv, lp->segtype);
+
 	log_error("Conversion operation not yet supported.");
 	return 0;
 }


