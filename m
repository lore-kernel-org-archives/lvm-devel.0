From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 01:53:10 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20090726015310.5602.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 01:53:09

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : pvcreate.c 

Log message:
	Move bulk of pvcreate logic into library.
	
	In preparation for implicit pvcreate during vgcreate / vgextend,
	move bulk of pvcreate logic inside library.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.96&r2=1.97
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.261&r2=1.262
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82

--- LVM2/lib/metadata/metadata-exported.h	2009/07/15 17:26:26	1.96
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/26 01:53:09	1.97
@@ -337,6 +337,25 @@
 	struct logical_volume *lv;
 };
 
+struct pvcreate_params {
+	int zero;
+	uint64_t size;
+	uint64_t data_alignment;
+	int pvmetadatacopies;
+	uint64_t pvmetadatasize;
+	int64_t labelsector;
+	struct id id; /* FIXME: redundant */
+	struct id *idp; /* 0 if no --uuid option */
+	uint64_t pe_start;
+	uint32_t extent_count;
+	uint32_t extent_size;
+	const char *restorefile; /* 0 if no --restorefile option */
+	force_t force;
+	unsigned yes;
+};
+
+int pvcreate_single(struct cmd_context *cmd, const char *pv_name, void *handle);
+
 /*
 * Utility functions
 */
--- LVM2/lib/metadata/metadata.c	2009/07/26 01:52:19	1.261
+++ LVM2/lib/metadata/metadata.c	2009/07/26 01:53:09	1.262
@@ -28,6 +28,7 @@
 #include "locking.h"
 #include "archiver.h"
 #include "defaults.h"
+#include "filter-persistent.h"
 
 #include <sys/param.h>
 
@@ -63,6 +64,9 @@
 static uint32_t _vg_bad_status_bits(const struct volume_group *vg,
 				    uint32_t status);
 
+const char _really_init[] =
+    "Really INITIALIZE physical volume \"%s\" of volume group \"%s\" [y/n]? ";
+
 unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignment)
 {
 	if (pv->pe_align)
@@ -954,6 +958,222 @@
 	return 1;
 }
 
+/*
+ * See if we may pvcreate on this device.
+ * 0 indicates we may not.
+ */
+static int pvcreate_check(struct cmd_context *cmd, const char *name,
+			  struct pvcreate_params *pp)
+{
+	struct physical_volume *pv;
+	struct device *dev;
+	uint64_t md_superblock, swap_signature;
+	int wipe_md, wipe_swap;
+
+	/* FIXME Check partition type is LVM unless --force is given */
+
+	/* Is there a pv here already? */
+	pv = pv_read(cmd, name, NULL, NULL, 0, 0);
+
+	/*
+	 * If a PV has no MDAs it may appear to be an orphan until the
+	 * metadata is read off another PV in the same VG.  Detecting
+	 * this means checking every VG by scanning every PV on the
+	 * system.
+	 */
+	if (pv && is_orphan(pv)) {
+		if (!scan_vgs_for_pvs(cmd))
+			return_0;
+		pv = pv_read(cmd, name, NULL, NULL, 0, 0);
+	}
+
+	/* Allow partial & exported VGs to be destroyed. */
+	/* We must have -ff to overwrite a non orphan */
+	if (pv && !is_orphan(pv) && pp->force != DONT_PROMPT_OVERRIDE) {
+		log_error("Can't initialize physical volume \"%s\" of "
+			  "volume group \"%s\" without -ff", name, pv_vg_name(pv));
+		return 0;
+	}
+
+	/* prompt */
+	if (pv && !is_orphan(pv) && !pp->yes &&
+	    yes_no_prompt(_really_init, name, pv_vg_name(pv)) == 'n') {
+		log_print("%s: physical volume not initialized", name);
+		return 0;
+	}
+
+	if (sigint_caught())
+		return 0;
+
+	dev = dev_cache_get(name, cmd->filter);
+
+	/* Is there an md superblock here? */
+	if (!dev && md_filtering()) {
+		unlock_vg(cmd, VG_ORPHANS);
+
+		persistent_filter_wipe(cmd->filter);
+		lvmcache_destroy(cmd, 1);
+
+		init_md_filtering(0);
+		if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+			log_error("Can't get lock for orphan PVs");
+			init_md_filtering(1);
+			return 0;
+		}
+		dev = dev_cache_get(name, cmd->filter);
+		init_md_filtering(1);
+	}
+
+	if (!dev) {
+		log_error("Device %s not found (or ignored by filtering).", name);
+		return 0;
+	}
+
+	/*
+	 * This test will fail if the device belongs to an MD array.
+	 */
+	if (!dev_test_excl(dev)) {
+		/* FIXME Detect whether device-mapper itself is still using it */
+		log_error("Can't open %s exclusively.  Mounted filesystem?",
+			  name);
+		return 0;
+	}
+
+	/* Wipe superblock? */
+	if ((wipe_md = dev_is_md(dev, &md_superblock)) == 1 &&
+	    ((!pp->idp && !pp->restorefile) || pp->yes ||
+	     (yes_no_prompt("Software RAID md superblock "
+			    "detected on %s. Wipe it? [y/n] ", name) == 'y'))) {
+		log_print("Wiping software RAID md superblock on %s", name);
+		if (!dev_set(dev, md_superblock, 4, 0)) {
+			log_error("Failed to wipe RAID md superblock on %s",
+				  name);
+			return 0;
+		}
+	}
+
+	if (wipe_md == -1) {
+		log_error("Fatal error while trying to detect software "
+			  "RAID md superblock on %s", name);
+		return 0;
+	}
+
+	if ((wipe_swap = dev_is_swap(dev, &swap_signature)) == 1 &&
+	    ((!pp->idp && !pp->restorefile) || pp->yes ||
+	     (yes_no_prompt("Swap signature detected on %s. Wipe it? [y/n] ",
+			    name) == 'y'))) {
+		log_print("Wiping swap signature on %s", name);
+		if (!dev_set(dev, swap_signature, 10, 0)) {
+			log_error("Failed to wipe swap signature on %s", name);
+			return 0;
+		}
+	}
+
+	if (wipe_swap == -1) {
+		log_error("Fatal error while trying to detect swap "
+			  "signature on %s", name);
+		return 0;
+	}
+
+	if (sigint_caught())
+		return 0;
+
+	if (pv && !is_orphan(pv) && pp->force) {
+		log_warn("WARNING: Forcing physical volume creation on "
+			  "%s%s%s%s", name,
+			  !is_orphan(pv) ? " of volume group \"" : "",
+			  !is_orphan(pv) ? pv_vg_name(pv) : "",
+			  !is_orphan(pv) ? "\"" : "");
+	}
+
+	return 1;
+}
+
+int pvcreate_single(struct cmd_context *cmd, const char *pv_name, void *handle)
+{
+	struct pvcreate_params *pp = (struct pvcreate_params *) handle;
+	void *pv;
+	struct device *dev;
+	struct dm_list mdas;
+
+	if (pp->idp) {
+		if ((dev = device_from_pvid(cmd, pp->idp)) &&
+		    (dev != dev_cache_get(pv_name, cmd->filter))) {
+			log_error("uuid %s already in use on \"%s\"",
+				  pp->idp->uuid, dev_name(dev));
+			return 0;
+		}
+	}
+
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+		log_error("Can't get lock for orphan PVs");
+		return 0;
+	}
+
+	if (!pvcreate_check(cmd, pv_name, pp))
+		goto error;
+
+	if (sigint_caught())
+		goto error;
+
+	if (!(dev = dev_cache_get(pv_name, cmd->filter))) {
+		log_error("%s: Couldn't find device.  Check your filters?",
+			  pv_name);
+		goto error;
+	}
+
+	dm_list_init(&mdas);
+	if (!(pv = pv_create(cmd, dev, pp->idp, pp->size,
+			     pp->data_alignment, pp->pe_start,
+			     pp->extent_count, pp->extent_size,
+			     pp->pvmetadatacopies,
+			     pp->pvmetadatasize,&mdas))) {
+		log_error("Failed to setup physical volume \"%s\"", pv_name);
+		goto error;
+	}
+
+	log_verbose("Set up physical volume for \"%s\" with %" PRIu64
+		    " available sectors", pv_name, pv_size(pv));
+
+	/* Wipe existing label first */
+	if (!label_remove(pv_dev(pv))) {
+		log_error("Failed to wipe existing label on %s", pv_name);
+		goto error;
+	}
+
+	if (pp->zero) {
+		log_verbose("Zeroing start of device %s", pv_name);
+		if (!dev_open_quiet(dev)) {
+			log_error("%s not opened: device not zeroed", pv_name);
+			goto error;
+		}
+
+		if (!dev_set(dev, UINT64_C(0), (size_t) 2048, 0)) {
+			log_error("%s not wiped: aborting", pv_name);
+			dev_close(dev);
+			goto error;
+		}
+		dev_close(dev);
+	}
+
+	log_very_verbose("Writing physical volume data to disk \"%s\"",
+			 pv_name);
+	if (!(pv_write(cmd, (struct physical_volume *)pv, &mdas,
+		       pp->labelsector))) {
+		log_error("Failed to write physical volume \"%s\"", pv_name);
+		goto error;
+	}
+
+	log_print("Physical volume \"%s\" successfully created", pv_name);
+
+	unlock_vg(cmd, VG_ORPHANS);
+	return 1;
+
+      error:
+	unlock_vg(cmd, VG_ORPHANS);
+	return 0;
+}
+
 static void _free_pv(struct dm_pool *mem, struct physical_volume *pv)
 {
 	dm_pool_free(mem, pv);
--- LVM2/tools/pvcreate.c	2009/04/10 10:01:38	1.81
+++ LVM2/tools/pvcreate.c	2009/07/26 01:53:09	1.82
@@ -14,244 +14,7 @@
  */
 
 #include "tools.h"
-#include "metadata.h"
-
-struct pvcreate_params {
-	int zero;
-	uint64_t size;
-	uint64_t data_alignment;
-	int pvmetadatacopies;
-	uint64_t pvmetadatasize;
-	int64_t labelsector;
-	struct id id; /* FIXME: redundant */
-	struct id *idp; /* 0 if no --uuid option */
-	uint64_t pe_start;
-	uint32_t extent_count;
-	uint32_t extent_size;
-	const char *restorefile; /* 0 if no --restorefile option */
-	force_t force;
-	unsigned yes;
-};
-
-const char _really_init[] =
-    "Really INITIALIZE physical volume \"%s\" of volume group \"%s\" [y/n]? ";
-
-/*
- * See if we may pvcreate on this device.
- * 0 indicates we may not.
- */
-static int pvcreate_check(struct cmd_context *cmd, const char *name,
-			  struct pvcreate_params *pp)
-{
-	struct physical_volume *pv;
-	struct device *dev;
-	uint64_t md_superblock, swap_signature;
-	int wipe_md, wipe_swap;
-
-	/* FIXME Check partition type is LVM unless --force is given */
-
-	/* Is there a pv here already? */
-	pv = pv_read(cmd, name, NULL, NULL, 0, 0);
-
-	/*
-	 * If a PV has no MDAs it may appear to be an orphan until the
-	 * metadata is read off another PV in the same VG.  Detecting
-	 * this means checking every VG by scanning every PV on the
-	 * system.
-	 */
-	if (pv && is_orphan(pv)) {
-		if (!scan_vgs_for_pvs(cmd))
-			return_0;
-		pv = pv_read(cmd, name, NULL, NULL, 0, 0);
-	}
-
-	/* Allow partial & exported VGs to be destroyed. */
-	/* We must have -ff to overwrite a non orphan */
-	if (pv && !is_orphan(pv) && pp->force != DONT_PROMPT_OVERRIDE) {
-		log_error("Can't initialize physical volume \"%s\" of "
-			  "volume group \"%s\" without -ff", name, pv_vg_name(pv));
-		return 0;
-	}
-
-	/* prompt */
-	if (pv && !is_orphan(pv) && !pp->yes &&
-	    yes_no_prompt(_really_init, name, pv_vg_name(pv)) == 'n') {
-		log_print("%s: physical volume not initialized", name);
-		return 0;
-	}
-
-	if (sigint_caught())
-		return 0;
-
-	dev = dev_cache_get(name, cmd->filter);
-
-	/* Is there an md superblock here? */
-	if (!dev && md_filtering()) {
-		unlock_vg(cmd, VG_ORPHANS);
-
-		persistent_filter_wipe(cmd->filter);
-		lvmcache_destroy(cmd, 1);
-
-		init_md_filtering(0);
-		if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-			log_error("Can't get lock for orphan PVs");
-			init_md_filtering(1);
-			return 0;
-		}
-		dev = dev_cache_get(name, cmd->filter);
-		init_md_filtering(1);
-	}
-
-	if (!dev) {
-		log_error("Device %s not found (or ignored by filtering).", name);
-		return 0;
-	}
-
-	/*
- 	 * This test will fail if the device belongs to an MD array.
-	 */
-	if (!dev_test_excl(dev)) {
-		/* FIXME Detect whether device-mapper itself is still using it */
-		log_error("Can't open %s exclusively.  Mounted filesystem?",
-			  name);
-		return 0;
-	}
-
-	/* Wipe superblock? */
-	if ((wipe_md = dev_is_md(dev, &md_superblock)) == 1 &&
-	    ((!pp->idp && !pp->restorefile) || pp->yes ||
-	     (yes_no_prompt("Software RAID md superblock "
-			    "detected on %s. Wipe it? [y/n] ", name) == 'y'))) {
-		log_print("Wiping software RAID md superblock on %s", name);
-		if (!dev_set(dev, md_superblock, 4, 0)) {
-			log_error("Failed to wipe RAID md superblock on %s",
-				  name);
-			return 0;
-		}
-	}
-
-	if (wipe_md == -1) {
-		log_error("Fatal error while trying to detect software "
-			  "RAID md superblock on %s", name);
-		return 0;
-	}
-
-	if ((wipe_swap = dev_is_swap(dev, &swap_signature)) == 1 &&
-	    ((!pp->idp && !pp->restorefile) || pp->yes ||
-	     (yes_no_prompt("Swap signature detected on %s. Wipe it? [y/n] ",
-			    name) == 'y'))) {
-		log_print("Wiping swap signature on %s", name);
-		if (!dev_set(dev, swap_signature, 10, 0)) {
-			log_error("Failed to wipe swap signature on %s", name);
-			return 0;
-		}
-	}
-
-	if (wipe_swap == -1) {
-		log_error("Fatal error while trying to detect swap "
-			  "signature on %s", name);
-		return 0;
-	}
-
-	if (sigint_caught())
-		return 0;
-
-	if (pv && !is_orphan(pv) && pp->force) {
-		log_warn("WARNING: Forcing physical volume creation on "
-			  "%s%s%s%s", name,
-			  !is_orphan(pv) ? " of volume group \"" : "",
-			  !is_orphan(pv) ? pv_vg_name(pv) : "",
-			  !is_orphan(pv) ? "\"" : "");
-	}
-
-	return 1;
-}
-
-static int pvcreate_single(struct cmd_context *cmd, const char *pv_name,
-			   void *handle)
-{
-	struct pvcreate_params *pp = (struct pvcreate_params *) handle;
-	void *pv;
-	struct device *dev;
-	struct dm_list mdas;
-
-	if (pp->idp) {
-		if ((dev = device_from_pvid(cmd, pp->idp)) &&
-		    (dev != dev_cache_get(pv_name, cmd->filter))) {
-			log_error("uuid %s already in use on \"%s\"",
-				  pp->idp->uuid, dev_name(dev));
-			return 0;
-		}
-	}
-
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-		log_error("Can't get lock for orphan PVs");
-		return 0;
-	}
-
-	if (!pvcreate_check(cmd, pv_name, pp))
-		goto error;
-
-	if (sigint_caught())
-		goto error;
-
-	if (!(dev = dev_cache_get(pv_name, cmd->filter))) {
-		log_error("%s: Couldn't find device.  Check your filters?",
-			  pv_name);
-		goto error;
-	}
-
-	dm_list_init(&mdas);
-	if (!(pv = pv_create(cmd, dev, pp->idp, pp->size,
-			     pp->data_alignment, pp->pe_start,
-			     pp->extent_count, pp->extent_size,
-			     pp->pvmetadatacopies,
-			     pp->pvmetadatasize,&mdas))) {
-		log_error("Failed to setup physical volume \"%s\"", pv_name);
-		goto error;
-	}
-
-	log_verbose("Set up physical volume for \"%s\" with %" PRIu64
-		    " available sectors", pv_name, pv_size(pv));
-
-	/* Wipe existing label first */
-	if (!label_remove(pv_dev(pv))) {
-		log_error("Failed to wipe existing label on %s", pv_name);
-		goto error;
-	}
-
-	if (pp->zero) {
-		log_verbose("Zeroing start of device %s", pv_name);
-		if (!dev_open_quiet(dev)) {
-			log_error("%s not opened: device not zeroed", pv_name);
-			goto error;
-		}
-
-		if (!dev_set(dev, UINT64_C(0), (size_t) 2048, 0)) {
-			log_error("%s not wiped: aborting", pv_name);
-			dev_close(dev);
-			goto error;
-		}
-		dev_close(dev);
-	}
-
-	log_very_verbose("Writing physical volume data to disk \"%s\"",
-			 pv_name);
-	if (!(pv_write(cmd, (struct physical_volume *)pv, &mdas,
-		       pp->labelsector))) {
-		log_error("Failed to write physical volume \"%s\"", pv_name);
-		goto error;
-	}
-
-	log_print("Physical volume \"%s\" successfully created", pv_name);
-
-	unlock_vg(cmd, VG_ORPHANS);
-	return 1;
-
-      error:
-	unlock_vg(cmd, VG_ORPHANS);
-	return 0;
-}
+#include "metadata-exported.h"
 
 /*
  * Intial sanity checking of command-line arguments and fill in 'pp' fields.


