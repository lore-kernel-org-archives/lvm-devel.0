From: David Teigland <teigland@sourceware.org>
Date: Fri, 16 Aug 2019 14:28:31 -0400
Subject: master - md component detection addition in vg_read
Message-ID: <201908161828.x7GISVBv006480@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=65bcd16be2cb46c73f6243e553b4a8685c159b7a
Commit:        65bcd16be2cb46c73f6243e553b4a8685c159b7a
Parent:        ad560a286a0b5d08086324e6194b060c136e9353
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 1 14:43:19 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 16 13:24:34 2019 -0500

md component detection addition in vg_read

Usually md components are eliminated in label scan and/or
duplicate resolution, but they could sometimes get into
the vg_read stage, where set_pv_devices compares the
device to the PV.

If set_pv_devices runs an md component check and finds
one, vg_read should eliminate the components.

In set_pv_devices, run an md component check always
if the PV is smaller than the device (this is not
very common.)  If the PV is larger than the device,
(more common), do the component check when the config
setting is "auto" (the default).
---
 lib/format_text/archiver.c |    2 +-
 lib/format_text/import.c   |    2 +-
 lib/metadata/metadata.c    |   80 ++++++++++++++++++++++++++++++++++++--------
 lib/metadata/metadata.h    |    2 +-
 tools/pvscan.c             |    2 +-
 5 files changed, 70 insertions(+), 18 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 052c2bd..3a741da 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -321,7 +321,7 @@ struct volume_group *backup_read_vg(struct cmd_context *cmd,
 	}
 
 	if (vg)
-		set_pv_devices(tf, vg);
+		set_pv_devices(tf, vg, NULL);
 
 	if (!vg)
 		tf->fmt->ops->destroy_instance(tf);
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 743077b..79276dd 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -230,7 +230,7 @@ static struct volume_group *_import_vg_from_config_tree(const struct dm_config_t
 		if (!(vg = (*vsn)->read_vg(fid, cft, allow_lvmetad_extensions)))
 			stack;
 		else {
-			set_pv_devices(fid, vg);
+			set_pv_devices(fid, vg, NULL);
 
 			if ((vg_missing = vg_missing_pv_count(vg)))
 				log_verbose("There are %d physical volumes missing.", vg_missing);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0f5154d..09000de 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3546,12 +3546,14 @@ bad:
  */
 static void _set_pv_device(struct format_instance *fid,
 			   struct volume_group *vg,
-			   struct physical_volume *pv)
+			   struct physical_volume *pv,
+			   int *found_md_component)
 {
 	char buffer[64] __attribute__((aligned(8)));
 	struct cmd_context *cmd = fid->fmt->cmd;
 	struct device *dev;
 	uint64_t size;
+	int do_check = 0;
 
 	if (!(dev = lvmcache_device_from_pvid(cmd, &pv->id, &pv->label_sector))) {
 		if (!id_write_format(&pv->id, buffer, sizeof(buffer)))
@@ -3565,19 +3567,26 @@ static void _set_pv_device(struct format_instance *fid,
 
 	/*
 	 * If the device and PV are not the size, it's a clue that we might
-	 * be reading an MD component (but not necessarily). Skip this check:
-	 * . if md component detection is disabled
-	 * . if we are already doing full a md check in label scan
-	 * . if md_component_checks is auto, not none (full means use_full_md_check is set)
+	 * be reading an MD component (but not necessarily). Skip this check
+	 * if md component detection is disabled or if we are already doing
+	 * full a md check in label scan
 	 */
-	if (dev && (pv->size != dev->size) && cmd &&
-	    cmd->md_component_detection &&
-	    !cmd->use_full_md_check &&
-	    !strcmp(cmd->md_component_checks, "auto")) {
-		if (dev_is_md_component(dev, NULL, 1)) {
+	if (dev && cmd && cmd->md_component_detection && !cmd->use_full_md_check) {
+
+		/* PV larger than dev not common, check for md component */
+		if (pv->size > dev->size)
+			do_check = 1;
+
+		/* dev larger than PV can be common, limit check to auto mode */
+		else if ((pv->size < dev->size) && !strcmp(cmd->md_component_checks, "auto"))
+			do_check = 1;
+
+		if (do_check && dev_is_md_component(dev, NULL, 1)) {
 			log_warn("WARNING: device %s is an md component, not setting device for PV.",
 				 dev_name(dev));
 			dev = NULL;
+			if (found_md_component)
+				*found_md_component = 1;
 		}
 	}
 
@@ -3622,12 +3631,12 @@ static void _set_pv_device(struct format_instance *fid,
  * Finds the 'struct device' that correponds to each PV in the metadata,
  * and may make some adjustments to vg fields based on the dev properties.
  */
-void set_pv_devices(struct format_instance *fid, struct volume_group *vg)
+void set_pv_devices(struct format_instance *fid, struct volume_group *vg, int *found_md_component)
 {
 	struct pv_list *pvl;
 
 	dm_list_iterate_items(pvl, &vg->pvs)
-		_set_pv_device(fid, vg, pvl->pv);
+		_set_pv_device(fid, vg, pvl->pv, found_md_component);
 }
 
 int pv_write(struct cmd_context *cmd,
@@ -4565,9 +4574,11 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	struct volume_group *vg, *vg_ret = NULL;
 	struct metadata_area *mda, *mda2;
 	unsigned use_precommitted = precommitted;
-	struct device *mda_dev, *dev_ret;
+	struct device *mda_dev, *dev_ret, *dev;
 	struct cached_vg_fmtdata *vg_fmtdata = NULL;	/* Additional format-specific data about the vg */
+	struct pv_list *pvl;
 	int found_old_metadata = 0;
+	int found_md_component = 0;
 	unsigned use_previous_vg;
 
 	log_debug_metadata("Reading VG %s %s", vgname ?: "<no name>", vgid ?: "<no vgid>");
@@ -4780,7 +4791,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	vg = NULL;
 
 	if (vg_ret)
-		set_pv_devices(fid, vg_ret);
+		set_pv_devices(fid, vg_ret, &found_md_component);
 
 	fid->ref_count--;
 
@@ -4790,6 +4801,47 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	}
 
 	/*
+	 * Usually md components are eliminated during label scan, or duplicate
+	 * resolution, but sometimes an md component can get through and be
+	 * detected in set_pv_device() (which will do an md component check if
+	 * the device/PV sizes don't match.)  In this case we need to fix up
+	 * lvmcache to drop the component dev and fix up metadata_areas_in_use
+	 * to drop it also.
+	 */
+	if (found_md_component) {
+		dm_list_iterate_items(pvl, &vg_ret->pvs) {
+			if (!(dev = lvmcache_device_from_pvid(cmd, &pvl->pv->id, NULL)))
+				continue;
+
+			/* dev_is_md_component set this flag if it was found */
+			if (!(dev->flags & DEV_IS_MD_COMPONENT))
+				continue;
+
+			log_debug_metadata("Drop dev for MD component from cache %s", dev_name(dev));
+			lvmcache_del_dev(dev);
+
+			dm_list_iterate_items(mda, &fid->metadata_areas_in_use) {
+				if (mda_get_device(mda) != dev)
+					continue;
+				log_debug_metadata("Drop mda from MD component from mda list %s", dev_name(dev));
+				dm_list_del(&mda->list);
+				break;
+			}
+		}
+	}
+
+	/*
+	 * After dropping MD components there may be no remaining legitimate
+	 * devices for this VG.
+	 */
+	if (!lvmcache_vginfo_from_vgid(vgid)) {
+		log_debug_metadata("VG %s not found on any remaining devices.", vgname);
+		release_vg(vg_ret);
+		vg_ret = NULL;
+		goto out;
+	}
+
+	/*
 	 * Correct the lvmcache representation of the VG using the metadata
 	 * that we have chosen above (vg_ret).
 	 *
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 2fc0015..6516e62 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -517,6 +517,6 @@ struct id pv_vgid(const struct physical_volume *pv);
 uint64_t find_min_mda_size(struct dm_list *mdas);
 char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tagsl);
 
-void set_pv_devices(struct format_instance *fid, struct volume_group *vg);
+void set_pv_devices(struct format_instance *fid, struct volume_group *vg, int *found_md_component);
 
 #endif
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 2a88eaa..168d509 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -618,7 +618,7 @@ static int _online_pvscan_one(struct cmd_context *cmd, struct device *dev,
 			*pvid_without_metadata = dm_pool_strdup(cmd->mem, dev->pvid);
 		fmt->ops->destroy_instance(baton.fid);
 	} else {
-		set_pv_devices(baton.fid, baton.vg);
+		set_pv_devices(baton.fid, baton.vg, NULL);
 	}
 
 	/* This check repeated because set_pv_devices can do new md check. */


