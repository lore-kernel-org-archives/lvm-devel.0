From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 17 Oct 2012 13:43:24 +0000 (UTC)
Subject: master - cleanup: switch log_error to log_warn
Message-ID: <20121017134324.523231F38@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f260f99d5791791f0aef2172b199fa5cdb7f6102
Commit:        f260f99d5791791f0aef2172b199fa5cdb7f6102
Parent:        b89963a7c3aea97ff11083a13dff718b5895ccc9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 16 10:14:41 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 17 15:41:35 2012 +0200

cleanup: switch log_error to log_warn

Use log_warn to print non-fatal warning messages.

Use of log_error would confuse checker for testing
whether proper error has been reported for some real error.
---
 WHATS_NEW                 |    4 ++++
 lib/device/dev-cache.c    |   14 +++++++-------
 lib/format_text/flags.c   |    4 ++--
 lib/metadata/lv_manip.c   |    4 ++--
 lib/metadata/raid_manip.c |    4 ++--
 libdm/libdm-report.c      |    4 ++--
 tools/lvconvert.c         |   11 +++++------
 tools/pvchange.c          |    8 ++++----
 tools/toollib.c           |    6 +++---
 tools/vgchange.c          |   16 ++++++++--------
 10 files changed, 39 insertions(+), 36 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c0ae3df..370c7e5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,7 @@
+Version 2.02.99 - 
+===================================
+  Cleanup some log_error message and use log_warn instead.
+  
 Version 2.02.98 - 15th October 2012
 ===================================
   Switch from DEBUG() to DEBUGLOG() in lvmetad as -DDEBUG is already used.
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index d08b07f..2b2d32b 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -800,13 +800,13 @@ int dev_cache_add_dir(const char *path)
 	struct stat st;
 
 	if (stat(path, &st)) {
-		log_error("Ignoring %s: %s", path, strerror(errno));
+		log_warn("Ignoring %s: %s.", path, strerror(errno));
 		/* But don't fail */
 		return 1;
 	}
 
 	if (!S_ISDIR(st.st_mode)) {
-		log_error("Ignoring %s: Not a directory", path);
+		log_warn("Ignoring %s: Not a directory.", path);
 		return 1;
 	}
 
@@ -826,13 +826,13 @@ int dev_cache_add_loopfile(const char *path)
 	struct stat st;
 
 	if (stat(path, &st)) {
-		log_error("Ignoring %s: %s", path, strerror(errno));
+		log_warn("Ignoring %s: %s.", path, strerror(errno));
 		/* But don't fail */
 		return 1;
 	}
 
 	if (!S_ISREG(st.st_mode)) {
-		log_error("Ignoring %s: Not a regular file", path);
+		log_warn("Ignoring %s: Not a regular file.", path);
 		return 1;
 	}
 
@@ -873,9 +873,9 @@ const char *dev_name_confirmed(struct device *dev, int quiet)
 				  name, (int) MAJOR(dev->dev),
 				  (int) MINOR(dev->dev));
 		else
-			log_error("Path %s no longer valid for device(%d,%d)",
-				  name, (int) MAJOR(dev->dev),
-				  (int) MINOR(dev->dev));
+			log_warn("Path %s no longer valid for device(%d,%d)",
+				 name, (int) MAJOR(dev->dev),
+				 (int) MINOR(dev->dev));
 
 		/* Remove the incorrect hash entry */
 		dm_hash_remove(_cache.names, name);
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index dbca8c9..a3a3d0e 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -140,8 +140,8 @@ int print_flags(uint64_t status, int type, char *buffer, size_t size)
 		return 0;
 
 	if (status)
-		log_error("Metadata inconsistency: Not all flags successfully "
-			  "exported.");
+		log_warn("Metadata inconsistency: Not all flags successfully "
+			 "exported.");
 
 	return 1;
 }
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 5f006ab..d2aca00 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1104,7 +1104,7 @@ static int _alloc_parallel_area(struct alloc_handle *ah, uint32_t max_to_allocat
 	total_area_count = ah->area_count + alloc_state->log_area_count_still_needed;
 	total_area_count += ah->parity_count;
 	if (!total_area_count) {
-		log_error(INTERNAL_ERROR "_alloc_parallel_area called without any allocation to do.");
+		log_warn(INTERNAL_ERROR "_alloc_parallel_area called without any allocation to do.");
 		return 1;
 	}
 
@@ -2024,7 +2024,7 @@ static int _allocate(struct alloc_handle *ah,
 	alloc_state.allocated = lv ? lv->le_count : 0;
 
 	if (alloc_state.allocated >= ah->new_extents && !ah->log_area_count) {
-		log_error("_allocate called with no work to do!");
+		log_warn("_allocate called with no work to do!");
 		return 1;
 	}
 
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index c7910e8..b9f75ff 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1122,8 +1122,8 @@ int lv_raid_change_image_count(struct logical_volume *lv,
 	uint32_t old_count = lv_raid_image_count(lv);
 
 	if (old_count == new_count) {
-		log_error("%s/%s already has image count of %d",
-			  lv->vg->name, lv->name, new_count);
+		log_warn("%s/%s already has image count of %d.",
+			 lv->vg->name, lv->name, new_count);
 		return 1;
 	}
 
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 0bafa86..0984416 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -461,8 +461,8 @@ static int _add_sort_key(struct dm_report *rh, uint32_t field_num,
 		return 1;
 
 	if (found->flags & FLD_SORT_KEY) {
-		log_error("dm_report: Ignoring duplicate sort field: %s",
-			  rh->fields[field_num].id);
+		log_warn("dm_report: Ignoring duplicate sort field: %s.",
+			 rh->fields[field_num].id);
 		return 1;
 	}
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 132a69d..f23fc4b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1171,8 +1171,8 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 	uint32_t old_log_count = _get_log_count(lv);
 
 	if ((lp->mirrors == 1) && !(lv->status & MIRRORED)) {
-		log_error("Logical volume %s is already not mirrored.",
-			  lv->name);
+		log_warn("Logical volume %s is already not mirrored.",
+			 lv->name);
 		return 1;
 	}
 
@@ -1403,7 +1403,7 @@ static int _lvconvert_mirrors_repair(struct cmd_context *cmd,
 	lv_check_transient(lv); /* TODO check this in lib for all commands? */
 
 	if (!(lv->status & PARTIAL_LV)) {
-		log_error("%s is consistent. Nothing to repair.", lv->name);
+		log_warn("%s is consistent. Nothing to repair.", lv->name);
 		return 1;
 	}
 
@@ -1663,9 +1663,8 @@ static int lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *lp
 
 		/* "warn" if policy not set to replace */
 		if (arg_count(cmd, use_policies_ARG))
-			log_error("Use 'lvconvert --repair %s/%s' to "
-				  "replace failed device",
-				  lv->vg->name, lv->name);
+			log_warn("Use 'lvconvert --repair %s/%s' to replace "
+				 "failed device.", lv->vg->name, lv->name);
 		return 1;
 	}
 
diff --git a/tools/pvchange.c b/tools/pvchange.c
index 70f1e62..c282ec0 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -73,14 +73,14 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 
 		/* change allocatability for a PV */
 		if (allocatable && (pv_status(pv) & ALLOCATABLE_PV)) {
-			log_error("Physical volume \"%s\" is already "
-				  "allocatable", pv_name);
+			log_warn("Physical volume \"%s\" is already "
+				 "allocatable.", pv_name);
 			return 1;
 		}
 
 		if (!allocatable && !(pv_status(pv) & ALLOCATABLE_PV)) {
-			log_error("Physical volume \"%s\" is already "
-				  "unallocatable", pv_name);
+			log_warn("Physical volume \"%s\" is already "
+				 "unallocatable.", pv_name);
 			return 1;
 		}
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 48b9a86..62f59d8 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1076,18 +1076,18 @@ static int _create_pv_entry(struct dm_pool *mem, struct pv_list *pvl,
 
 	pvname = pv_dev_name(pvl->pv);
 	if (allocatable_only && !(pvl->pv->status & ALLOCATABLE_PV)) {
-		log_error("Physical volume %s not allocatable", pvname);
+		log_warn("Physical volume %s not allocatable.", pvname);
 		return 1;
 	}
 
 	if (allocatable_only && is_missing_pv(pvl->pv)) {
-		log_error("Physical volume %s is missing", pvname);
+		log_warn("Physical volume %s is missing.", pvname);
 		return 1;
 	}
 
 	if (allocatable_only &&
 	    (pvl->pv->pe_count == pvl->pv->pe_alloc_count)) {
-		log_error("No free extents on physical volume \"%s\"", pvname);
+		log_warn("No free extents on physical volume \"%s\".", pvname);
 		return 1;
 	}
 
diff --git a/tools/vgchange.c b/tools/vgchange.c
index a897a85..ccf31da 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -368,16 +368,16 @@ static int _vgchange_pesize(struct cmd_context *cmd, struct volume_group *vg)
 	uint32_t extent_size;
 
 	if (arg_uint64_value(cmd, physicalextentsize_ARG, 0) > MAX_EXTENT_SIZE) {
-		log_error("Physical extent size cannot be larger than %s",
-				  display_size(cmd, (uint64_t) MAX_EXTENT_SIZE));
+		log_warn("Physical extent size cannot be larger than %s.",
+			 display_size(cmd, (uint64_t) MAX_EXTENT_SIZE));
 		return 1;
 	}
 
 	extent_size = arg_uint_value(cmd, physicalextentsize_ARG, 0);
 	/* FIXME: remove check - redundant with vg_change_pesize */
 	if (extent_size == vg->extent_size) {
-		log_error("Physical extent size of VG %s is already %s",
-			  vg->name, display_size(cmd, (uint64_t) extent_size));
+		log_warn("Physical extent size of VG %s is already %s.",
+			 vg->name, display_size(cmd, (uint64_t) extent_size));
 		return 1;
 	}
 
@@ -427,11 +427,11 @@ static int _vgchange_metadata_copies(struct cmd_context *cmd,
 
 	if (mda_copies == vg_mda_copies(vg)) {
 		if (vg_mda_copies(vg) == VGMETADATACOPIES_UNMANAGED)
-			log_error("Number of metadata copies for VG %s is already unmanaged.",
-				  vg->name);
+			log_warn("Number of metadata copies for VG %s is already unmanaged.",
+				 vg->name);
 		else
-			log_error("Number of metadata copies for VG %s is already %" PRIu32,
-				  vg->name, mda_copies);
+			log_warn("Number of metadata copies for VG %s is already %u.",
+				 vg->name, mda_copies);
 		return 1;
 	}
 


