From: David Teigland <teigland@sourceware.org>
Date: Thu, 23 May 2019 14:09:22 -0400
Subject: master - separate code for setting devices from metadata parsing
Message-ID: <201905231809.x4NI9ME3006869@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=645dd276049e8dbab37b169b27cf6af29a8bd8e5
Commit:        645dd276049e8dbab37b169b27cf6af29a8bd8e5
Parent:        ef2d61fea81dbae3d1a32d20ee22d2afae7701af
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 5 11:32:54 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 23 11:57:38 2019 -0500

separate code for setting devices from metadata parsing

Pull the code that sets devs for PVs out of the metadata
parsing code and call it separately.
---
 lib/format_text/archiver.c    |    3 ++
 lib/format_text/import.c      |    8 +++--
 lib/format_text/import_vsn1.c |   51 ----------------------------
 lib/metadata/metadata.c       |   75 +++++++++++++++++++++++++++++++++++++++++
 lib/metadata/metadata.h       |    2 +
 tools/pvscan.c                |    2 +
 6 files changed, 87 insertions(+), 54 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 34eff55..052c2bd 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -320,6 +320,9 @@ struct volume_group *backup_read_vg(struct cmd_context *cmd,
 		break;
 	}
 
+	if (vg)
+		set_pv_devices(tf, vg);
+
 	if (!vg)
 		tf->fmt->ops->destroy_instance(tf);
 
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index d487100..64fbb08 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -229,9 +229,11 @@ static struct volume_group *_import_vg_from_config_tree(const struct dm_config_t
 		 */
 		if (!(vg = (*vsn)->read_vg(fid, cft, allow_lvmetad_extensions)))
 			stack;
-		else if ((vg_missing = vg_missing_pv_count(vg))) {
-			log_verbose("There are %d physical volumes missing.",
-				    vg_missing);
+		else {
+			set_pv_devices(fid, vg);
+
+			if ((vg_missing = vg_missing_pv_count(vg)))
+				log_verbose("There are %d physical volumes missing.", vg_missing);
 			vg_mark_partial_lvs(vg, 1);
 			/* FIXME: move this code inside read_vg() */
 		}
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 8dad8e9..43ec10b 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -206,21 +206,6 @@ static int _read_pv(struct format_instance *fid,
 
         pv->is_labelled = 1; /* All format_text PVs are labelled. */
 
-	/*
-	 * Convert the uuid into a device.
-	 */
-	if (!(pv->dev = lvmcache_device_from_pvid(fid->fmt->cmd, &pv->id, &pv->label_sector))) {
-		char buffer[64] __attribute__((aligned(8)));
-
-		if (!id_write_format(&pv->id, buffer, sizeof(buffer)))
-			buffer[0] = '\0';
-
-		if (fid->fmt->cmd && !fid->fmt->cmd->pvscan_cache_single)
-			log_error_once("Couldn't find device with uuid %s.", buffer);
-		else
-			log_debug_metadata("Couldn't find device with uuid %s.", buffer);
-	}
-
 	if (!(pv->vg_name = dm_pool_strdup(mem, vg->name)))
 		return_0;
 
@@ -231,15 +216,6 @@ static int _read_pv(struct format_instance *fid,
 		return 0;
 	}
 
-	if (!pv->dev)
-		pv->status |= MISSING_PV;
-
-	if ((pv->status & MISSING_PV) && pv->dev && pv_mda_used_count(pv) == 0) {
-		pv->status &= ~MISSING_PV;
-		log_info("Recovering a previously MISSING PV %s with no MDAs.",
-			 pv_dev_name(pv));
-	}
-
 	/* Late addition */
 	if (dm_config_has_node(pvn, "dev_size") &&
 	    !_read_uint64(pvn, "dev_size", &pv->size)) {
@@ -292,33 +268,6 @@ static int _read_pv(struct format_instance *fid,
 	pv->pe_align = 0;
 	pv->fmt = fid->fmt;
 
-	/*
-	 * It would be nice to check this earlier, e.g. in or after label scan,
-	 * but this is first time we get far enough through the vg metadata to
-	 * see the PV size, and can finally compare it with the device size.
-	 */
-	if (pv->dev && (pv->size != pv->dev->size)) {
-		if (dev_is_md_component(pv->dev, NULL, 1)) {
-			log_warn("WARNING: device %s is an md component, ignoring PV.", dev_name(pv->dev));
-			return_0;
-		}
-	}
-
-	/* Fix up pv size if missing or impossibly large */
-	if ((!pv->size || pv->size > (1ULL << 62)) && pv->dev) {
-		if (!dev_get_size(pv->dev, &pv->size)) {
-			log_error("%s: Couldn't get size.", pv_dev_name(pv));
-			return 0;
-		}
-		log_verbose("Fixing up missing size (%s) "
-			    "for PV %s", display_size(fid->fmt->cmd, pv->size),
-			    pv_dev_name(pv));
-		size = pv->pe_count * (uint64_t) vg->extent_size + pv->pe_start;
-		if (size > pv->size)
-			log_warn("WARNING: Physical Volume %s is too large "
-				 "for underlying device", pv_dev_name(pv));
-	}
-
 	if (!alloc_pv_segment_whole_pv(mem, pv))
 		return_0;
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index e9d4fa2..8f6de26 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3866,6 +3866,9 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			continue;
 		}
 
+		if (vg)
+			set_pv_devices(fid, vg);
+
 		/* Use previous VG because checksum matches */
 		if (!vg) {
 			vg = correct_vg;
@@ -4073,6 +4076,9 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 				continue;
 			}
 
+			if (vg)
+				set_pv_devices(fid, vg);
+
 			/* Use previous VG because checksum matches */
 			if (!vg) {
 				vg = correct_vg;
@@ -4498,6 +4504,75 @@ bad:
 	return NULL;
 }
 
+/*
+ * FIXME: we only want to print the warnings when this is called from
+ * vg_read, not from import_vg_from_metadata, so do the warnings elsewhere
+ * or avoid calling this from import_vg_from.
+ */
+static void _set_pv_device(struct format_instance *fid,
+			   struct volume_group *vg,
+			   struct physical_volume *pv)
+{
+	char buffer[64] __attribute__((aligned(8)));
+	uint64_t size;
+
+	if (!(pv->dev = lvmcache_device_from_pvid(fid->fmt->cmd, &pv->id, &pv->label_sector))) {
+		if (!id_write_format(&pv->id, buffer, sizeof(buffer)))
+			buffer[0] = '\0';
+
+		if (fid->fmt->cmd && !fid->fmt->cmd->pvscan_cache_single)
+			log_error_once("Couldn't find device with uuid %s.", buffer);
+		else
+			log_debug_metadata("Couldn't find device with uuid %s.", buffer);
+	}
+
+	/*
+	 * A previous command wrote the VG while this dev was missing, so
+	 * the MISSING flag was included in the PV.
+	 */
+	if ((pv->status & MISSING_PV) && pv->dev)
+		log_warn("WARNING: VG %s was previously updated while PV %s was missing.", vg->name, dev_name(pv->dev));
+
+	/*
+	 * If this command writes the VG, we want the MISSING flag to be
+	 * written for this PV with no device.
+	 */
+	if (!pv->dev)
+		pv->status |= MISSING_PV;
+
+	/* is this correct? */
+	if ((pv->status & MISSING_PV) && pv->dev && (pv_mda_used_count(pv) == 0)) {
+		pv->status &= ~MISSING_PV;
+		log_info("Found a previously MISSING PV %s with no MDAs.", pv_dev_name(pv));
+	}
+
+	/* Fix up pv size if missing or impossibly large */
+	if ((!pv->size || pv->size > (1ULL << 62)) && pv->dev) {
+		if (!dev_get_size(pv->dev, &pv->size)) {
+			log_error("%s: Couldn't get size.", pv_dev_name(pv));
+			return;
+		}
+		log_verbose("Fixing up missing size (%s) for PV %s", display_size(fid->fmt->cmd, pv->size),
+			    pv_dev_name(pv));
+		size = pv->pe_count * (uint64_t) vg->extent_size + pv->pe_start;
+		if (size > pv->size)
+			log_warn("WARNING: Physical Volume %s is too large "
+				 "for underlying device", pv_dev_name(pv));
+	}
+}
+
+/*
+ * Finds the 'struct device' that correponds to each PV in the metadata,
+ * and may make some adjustments to vg fields based on the dev properties.
+ */
+void set_pv_devices(struct format_instance *fid, struct volume_group *vg)
+{
+	struct pv_list *pvl;
+
+	dm_list_iterate_items(pvl, &vg->pvs)
+		_set_pv_device(fid, vg, pvl->pv);
+}
+
 int get_vgnameids(struct cmd_context *cmd, struct dm_list *vgnameids,
 		  const char *only_this_vgname, int include_internal)
 {
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 8e9c18a..a140c29 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -502,4 +502,6 @@ struct id pv_vgid(const struct physical_volume *pv);
 uint64_t find_min_mda_size(struct dm_list *mdas);
 char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tagsl);
 
+void set_pv_devices(struct format_instance *fid, struct volume_group *vg);
+
 #endif
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 6d89426..d41345f 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -617,6 +617,8 @@ static int _online_pvscan_one(struct cmd_context *cmd, struct device *dev,
 		if (pvid_without_metadata)
 			*pvid_without_metadata = dm_pool_strdup(cmd->mem, dev->pvid);
 		fmt->ops->destroy_instance(baton.fid);
+	} else {
+		set_pv_devices(baton.fid, baton.vg);
 	}
 
 	if (baton.vg && vg_is_shared(baton.vg)) {


