From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 24 Jan 2011 12:03:55 +0100
Subject: [PATCH 04/17] Add format_instance support for pv_read.
In-Reply-To: <1295867048-21558-1-git-send-email-prajnoha@redhat.com>
References: <1295867048-21558-1-git-send-email-prajnoha@redhat.com>
Message-ID: <1295867048-21558-5-git-send-email-prajnoha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We don't need to store metadata areas in a separate "mdas" parameter
since it is in the pv->fid now. If the fid is not defined yet and is
NULL, pv_read code will create a new one (if there's no VG fid yet
where the metadata areas read off of a PV should be attached to).

Signed-off-by: Peter Rajnoha <prajnoha@redhat.com>
---
 lib/metadata/metadata.c |   26 +++++++++++++++++++++-----
 1 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index ed2084d..f6ea0e5 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -37,6 +37,7 @@
 static struct physical_volume *_pv_read(struct cmd_context *cmd,
 					struct dm_pool *pvmem,
 					const char *pv_name,
+					struct format_instance *fid,
 					struct dm_list *mdas,
 					uint64_t *label_sector,
 					int warnings, int scan_label_only);
@@ -166,6 +167,7 @@ void add_pvl_to_vgs(struct volume_group *vg, struct pv_list *pvl)
 	dm_list_add(&vg->pvs, &pvl->list);
 	vg->pv_count++;
 	pvl->pv->vg = vg;
+	pvl->pv->fid = vg->fid;
 }
 
 void del_pvl_from_vgs(struct volume_group *vg, struct pv_list *pvl)
@@ -1813,7 +1815,7 @@ static struct physical_volume *_find_pv_by_name(struct cmd_context *cmd,
 	struct physical_volume *pv;
 
 	dm_list_init(&mdas);
-	if (!(pv = _pv_read(cmd, cmd->mem, pv_name, &mdas, NULL, 1, 0))) {
+	if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, &mdas, NULL, 1, 0))) {
 		log_error("Physical volume %s not found", pv_name);
 		return NULL;
 	}
@@ -1822,7 +1824,7 @@ static struct physical_volume *_find_pv_by_name(struct cmd_context *cmd,
 		/* If a PV has no MDAs - need to search all VGs for it */
 		if (!scan_vgs_for_pvs(cmd, 1))
 			return_NULL;
-		if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, NULL, 1, 0))) {
+		if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, NULL, NULL, 1, 0))) {
 			log_error("Physical volume %s not found", pv_name);
 			return NULL;
 		}
@@ -2644,7 +2646,8 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	}
 
 	dm_list_iterate_items(info, &vginfo->infos) {
-		if (!(pv = _pv_read(cmd, mem, dev_name(info->dev), NULL, NULL, warnings, 0))) {
+		if (!(pv = _pv_read(cmd, mem, dev_name(info->dev), vg->fid,
+				    NULL, NULL, warnings, 0))) {
 			continue;
 		}
 		if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl)))) {
@@ -3357,13 +3360,14 @@ struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
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
@@ -3407,6 +3411,18 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 	if (!alloc_pv_segment_whole_pv(pvmem, pv))
 		goto_bad;
 
+	if (fid)
+		fid_add_mdas(fid, &info->mdas, (const char *) &pv->id, ID_LEN);
+	else {
+		if (!(pv->fid = pv->fmt->ops->create_instance(pv->fmt,
+						(const char *) &pv->id,
+						NULL, NULL, NULL))) {
+			log_error("_pv_read: Couldn't create format instance "
+				  "for PV %s", pv_name);
+			goto bad;
+		}
+	}
+
 	return pv;
 bad:
 	_free_pv(pvmem, pv);
@@ -4213,5 +4229,5 @@ struct physical_volume *pv_by_path(struct cmd_context *cmd, const char *pv_name)
 	struct dm_list mdas;
 
 	dm_list_init(&mdas);
-	return _pv_read(cmd, cmd->mem, pv_name, &mdas, NULL, 1, 0);
+	return _pv_read(cmd, cmd->mem, pv_name, NULL, &mdas, NULL, 1, 0);
 }
-- 
1.7.3.4


