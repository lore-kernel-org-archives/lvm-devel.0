From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 21 Feb 2011 12:13:41 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20110221121341.29659.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-02-21 12:13:40

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Add format instance support for pv_read code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.428&r2=1.429

--- LVM2/lib/metadata/metadata.c	2011/02/21 12:12:32	1.428
+++ LVM2/lib/metadata/metadata.c	2011/02/21 12:13:40	1.429
@@ -37,6 +37,7 @@
 static struct physical_volume *_pv_read(struct cmd_context *cmd,
 					struct dm_pool *pvmem,
 					const char *pv_name,
+					struct format_instance *fid,
 					struct dm_list *mdas,
 					uint64_t *label_sector,
 					int warnings, int scan_label_only);
@@ -166,6 +167,7 @@
 	dm_list_add(&vg->pvs, &pvl->list);
 	vg->pv_count++;
 	pvl->pv->vg = vg;
+	pvl->pv->fid = vg->fid;
 }
 
 void del_pvl_from_vgs(struct volume_group *vg, struct pv_list *pvl)
@@ -1823,7 +1825,7 @@
 	struct physical_volume *pv;
 
 	dm_list_init(&mdas);
-	if (!(pv = _pv_read(cmd, cmd->mem, pv_name, &mdas, NULL, 1, 0))) {
+	if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, &mdas, NULL, 1, 0))) {
 		log_error("Physical volume %s not found", pv_name);
 		return NULL;
 	}
@@ -1832,7 +1834,7 @@
 		/* If a PV has no MDAs - need to search all VGs for it */
 		if (!scan_vgs_for_pvs(cmd, 1))
 			return_NULL;
-		if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, NULL, 1, 0))) {
+		if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, NULL, NULL, 1, 0))) {
 			log_error("Physical volume %s not found", pv_name);
 			return NULL;
 		}
@@ -2657,7 +2659,8 @@
 	}
 
 	dm_list_iterate_items(info, &vginfo->infos) {
-		if (!(pv = _pv_read(cmd, mem, dev_name(info->dev), NULL, NULL, warnings, 0))) {
+		if (!(pv = _pv_read(cmd, mem, dev_name(info->dev), vg->fid,
+				    NULL, NULL, warnings, 0))) {
 			continue;
 		}
 		if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl)))) {
@@ -3377,18 +3380,20 @@
 				struct dm_list *mdas, uint64_t *label_sector,
 				int warnings, int scan_label_only)
 {
-	return _pv_read(cmd, cmd->mem, pv_name, mdas, label_sector, warnings, scan_label_only);
+	return _pv_read(cmd, cmd->mem, pv_name, NULL, mdas, label_sector, warnings, scan_label_only);
 }
 
 /* FIXME Use label functions instead of PV functions */
 static struct physical_volume *_pv_read(struct cmd_context *cmd,
 					struct dm_pool *pvmem,
 					const char *pv_name,
+					struct format_instance *fid,
 					struct dm_list *mdas,
 					uint64_t *label_sector,
 					int warnings, int scan_label_only)
 {
 	struct physical_volume *pv;
+	struct format_instance_ctx fic;
 	struct label *label;
 	struct lvmcache_info *info;
 	struct device *dev;
@@ -3427,6 +3432,18 @@
 	if (!alloc_pv_segment_whole_pv(pvmem, pv))
 		goto_bad;
 
+	if (fid)
+		fid_add_mdas(fid, &info->mdas, (const char *) &pv->id, ID_LEN);
+	else {
+		fic.type = FMT_INSTANCE_PV | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
+		fic.context.pv_id = (const char *) &pv->id;
+		if (!(pv->fid = pv->fmt->ops->create_instance(pv->fmt, &fic))) {
+			log_error("_pv_read: Couldn't create format instance "
+				  "for PV %s", pv_name);
+			goto bad;
+		}
+	}
+
 	return pv;
 bad:
 	_free_pv(pvmem, pv);
@@ -4244,5 +4261,5 @@
 	struct dm_list mdas;
 
 	dm_list_init(&mdas);
-	return _pv_read(cmd, cmd->mem, pv_name, &mdas, NULL, 1, 0);
+	return _pv_read(cmd, cmd->mem, pv_name, NULL, &mdas, NULL, 1, 0);
 }


