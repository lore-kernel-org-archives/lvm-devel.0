From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 25 Feb 2011 13:59:48 -0000
Subject: LVM2/lib format_text/archiver.c format_text/fo ...
Message-ID: <20110225135948.28606.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-02-25 13:59:47

Modified files:
	lib/format_text: archiver.c format-text.c 
	lib/metadata   : metadata.c 

Log message:
	Read PV metadata information from cache if pv_setup called with pv->fid == vg->fid.
	
	If the PV is already part of the VG (so the pv->fid == vg->fid), it makes no
	sense to attach the mdas information from PV to a VG. Instead, we read new
	PV metadata information from cache and attach it to the VG fid.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.167&r2=1.168
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.433&r2=1.434

--- LVM2/lib/format_text/archiver.c	2011/02/21 12:24:16	1.41
+++ LVM2/lib/format_text/archiver.c	2011/02/25 13:59:47	1.42
@@ -294,8 +294,6 @@
 int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg)
 {
 	struct pv_list *pvl;
-	struct physical_volume *pv;
-	struct lvmcache_info *info;
 	struct format_instance *fid;
 	struct format_instance_ctx fic;
 
@@ -305,7 +303,7 @@
 	 */
 
 	/* Attempt to write out using currently active format */
-	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
+	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = vg->name;
 	fic.context.vg_ref.vg_id = NULL;
 	if (!(fid = cmd->fmt->ops->create_instance(cmd->fmt, &fic))) {
@@ -322,20 +320,9 @@
 
 	/* Add any metadata areas on the PVs */
 	dm_list_iterate_items(pvl, &vg->pvs) {
-		pv = pvl->pv;
-		if (!(info = info_from_pvid(pv->dev->pvid, 0))) {
-			log_error("PV %s missing from cache",
-				  pv_dev_name(pv));
-			return 0;
-		}
-		if (cmd->fmt != info->fmt) {
-			log_error("PV %s is a different format (seqno %s)",
-				  pv_dev_name(pv), info->fmt->name);
-			return 0;
-		}
-		if (!vg->fid->fmt->ops->pv_setup(vg->fid->fmt, pv, vg)) {
+		if (!vg->fid->fmt->ops->pv_setup(vg->fid->fmt, pvl->pv, vg)) {
 			log_error("Format-specific setup for %s failed",
-				  pv_dev_name(pv));
+				  pv_dev_name(pvl->pv));
 			return 0;
 		}
 	}
--- LVM2/lib/format_text/format-text.c	2011/02/25 13:50:02	1.167
+++ LVM2/lib/format_text/format-text.c	2011/02/25 13:59:47	1.168
@@ -1645,20 +1645,42 @@
 {
 	struct format_instance *fid = pv->fid;
 	const char *pvid = (const char *) (*pv->old_id.uuid ? &pv->old_id : &pv->id);
+	struct lvmcache_info *info;
 	unsigned mda_index;
 	struct metadata_area *pv_mda;
 	struct mda_context *pv_mdac;
 	uint64_t pe_count;
 	uint64_t size_reduction = 0;
 
-	/* Add any further mdas on this PV to VG's format instance. */
-	for (mda_index = 0; mda_index < FMT_TEXT_MAX_MDAS_PER_PV; mda_index++) {
-		if (!(pv_mda = fid_get_mda_indexed(fid, pvid, ID_LEN, mda_index)))
-			continue;
-
-		/* Be sure it's not already in VG's format instance! */
-		if (!fid_get_mda_indexed(vg->fid, pvid, ID_LEN, mda_index))
-			fid_add_mda(vg->fid, pv_mda, pvid, ID_LEN, mda_index);
+	/* If PV has its own format instance, add mdas from pv->fid to vg->fid. */
+	if (pv->fid != vg->fid) {
+		for (mda_index = 0; mda_index < FMT_TEXT_MAX_MDAS_PER_PV; mda_index++) {
+			if (!(pv_mda = fid_get_mda_indexed(fid, pvid, ID_LEN, mda_index)))
+				continue;
+
+			/* Be sure it's not already in VG's format instance! */
+			if (!fid_get_mda_indexed(vg->fid, pvid, ID_LEN, mda_index))
+				fid_add_mda(vg->fid, pv_mda, pvid, ID_LEN, mda_index);
+		}
+	}
+	/*
+	 * Otherwise, if the PV is already a part of the VG (pv->fid == vg->fid),
+	 * reread PV mda information from the cache and add it to vg->fid.
+	 */
+	else {
+		if (!(info = info_from_pvid(pv->dev->pvid, 0))) {
+			log_error("PV %s missing from cache", pv_dev_name(pv));
+			return 0;
+		}
+
+		if (fmt != info->fmt) {
+			log_error("PV %s is a different format (seqno %s)",
+				  pv_dev_name(pv), info->fmt->name);
+			return 0;
+		}
+
+		if (!fid_add_mdas(vg->fid, &info->mdas, pvid, ID_LEN))
+			return_0;
 	}
 
 	/* If there's the 2nd mda, we need to reduce
--- LVM2/lib/metadata/metadata.c	2011/02/21 12:29:21	1.433
+++ LVM2/lib/metadata/metadata.c	2011/02/25 13:59:47	1.434
@@ -4105,7 +4105,7 @@
 		mda_new = mda_copy(fid->fmt->cmd->mem, mda);
 		if (!mda_new)
 			return_0;
-
+		fid_remove_mda(fid, NULL, key, key_len, mda_index);
 		fid_add_mda(fid, mda_new, key, key_len, mda_index);
 		mda_index++;
 	}


