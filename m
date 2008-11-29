From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sat, 29 Nov 2008 16:02:30 -0500
Subject: [PATCH 1/4] Move guts of pvcreate into library area - prep for vgcreate.
Message-ID: <1227992553-4381-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Preparation for allowing vgcreate on devices which are not currently PVs.
Move necessary pvcreate code from tools subdir into library so we can call
this higher-level pvcreate code from the vgcreate path in the library.
This will also get us a little closer to where we should be with libLVM,
though there is some cleanup to do (pvcreate_single and pv_create should
be merged into a single function exported by the libLVM).

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |   18 +++
 lib/metadata/metadata.c          |  196 +++++++++++++++++++++++++++++++++++
 tools/pvcreate.c                 |  213 +-------------------------------------
 3 files changed, 215 insertions(+), 212 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index d49eaba..829a894 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -353,6 +353,24 @@ vg_t *vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
 		       uint32_t lock_flags, uint32_t status_flags,
 		       uint32_t misc_flags);
 
+struct pvcreate_params {
+	int zero;
+	uint64_t size;
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
+int pvcreate_single(struct cmd_context *cmd, const char *pv_name,
+		    void *handle);
 /* pe_start and pe_end relate to any existing data so that new metadata
 * areas can avoid overlap */
 pv_t *pv_create(const struct cmd_context *cmd,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index e5a13e6..265b619 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -28,9 +28,13 @@
 #include "locking.h"
 #include "archiver.h"
 #include "defaults.h"
+#include "filter-persistent.h"
 
 #include <sys/param.h>
 
+const char _really_init[] =
+    "Really INITIALIZE physical volume \"%s\" of volume group \"%s\" [y/n]? ";
+
 /*
  * FIXME: Check for valid handle before dereferencing field or log error?
  */
@@ -879,6 +883,198 @@ static struct physical_volume *_pv_create(const struct format_type *fmt,
 	return NULL;
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
+	uint64_t md_superblock;
+
+	/* FIXME Check partition type is LVM unless --force is given */
+
+	/* Is there a pv here already? */
+	pv = pv_read(cmd, name, NULL, NULL, 0);
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
+		pv = pv_read(cmd, name, NULL, NULL, 0);
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
+ 	 * This test will fail if the device belongs to an MD array.
+	 */
+	if (!dev_test_excl(dev)) {
+		/* FIXME Detect whether device-mapper itself is still using it */
+		log_error("Can't open %s exclusively.  Mounted filesystem?",
+			  name);
+		return 0;
+	}
+
+	/* Wipe superblock? */
+	if (dev_is_md(dev, &md_superblock) &&
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
+int pvcreate_single(struct cmd_context *cmd, const char *pv_name,
+		    void *handle)
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
+	if (!(pv = pv_create(cmd, dev, pp->idp, pp->size, pp->pe_start,
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
 /* FIXME: liblvm todo - make into function that returns handle */
 struct pv_list *find_pv_in_vg(const struct volume_group *vg,
 			      const char *pv_name)
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index db1a0e2..f40cd2c 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -14,218 +14,7 @@
  */
 
 #include "tools.h"
-#include "metadata.h"
-
-struct pvcreate_params {
-	int zero;
-	uint64_t size;
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
-	uint64_t md_superblock;
-
-	/* FIXME Check partition type is LVM unless --force is given */
-
-	/* Is there a pv here already? */
-	pv = pv_read(cmd, name, NULL, NULL, 0);
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
-		pv = pv_read(cmd, name, NULL, NULL, 0);
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
-	if (dev_is_md(dev, &md_superblock) &&
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
-	if (!(pv = pv_create(cmd, dev, pp->idp, pp->size, pp->pe_start,
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
-- 
1.5.5.1


