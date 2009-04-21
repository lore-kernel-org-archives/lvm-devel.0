From: Milan Broz <mbroz@redhat.com>
Date: Tue, 21 Apr 2009 17:04:37 +0200
Subject: [PATCH] Alloc PV internal structure from VG mempool if possible
Message-ID: <49EDE085.4000305@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alloc PV internal structure from VG mempool, if possible.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/metadata.c |   20 +++++++++++---------
 1 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 544df6a..5b4e504 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -38,6 +38,7 @@
 	(((const struct physical_volume *)(handle))->field)
 
 static struct physical_volume *_pv_read(struct cmd_context *cmd,
+					struct dm_pool *pvmem,
 					const char *pv_name,
 					struct dm_list *mdas,
 					uint64_t *label_sector,
@@ -1070,7 +1071,7 @@ static struct physical_volume *_find_pv_by_name(struct cmd_context *cmd,
 {
 	struct physical_volume *pv;
 
-	if (!(pv = _pv_read(cmd, pv_name, NULL, NULL, 1, 0))) {
+	if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, NULL, 1, 0))) {
 		log_error("Physical volume %s not found", pv_name);
 		return NULL;
 	}
@@ -1079,7 +1080,7 @@ static struct physical_volume *_find_pv_by_name(struct cmd_context *cmd,
 		/* If a PV has no MDAs - need to search all VGs for it */
 		if (!scan_vgs_for_pvs(cmd))
 			return_NULL;
-		if (!(pv = _pv_read(cmd, pv_name, NULL, NULL, 1, 0))) {
+		if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, NULL, 1, 0))) {
 			log_error("Physical volume %s not found", pv_name);
 			return NULL;
 		}
@@ -1684,7 +1685,7 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	}
 
 	dm_list_iterate_items(info, &vginfo->infos) {
-		if (!(pv = _pv_read(cmd, dev_name(info->dev), NULL, NULL, 1, 0))) {
+		if (!(pv = _pv_read(cmd, mem, dev_name(info->dev), NULL, NULL, 1, 0))) {
 			continue;
 		}
 		if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl)))) {
@@ -2216,11 +2217,12 @@ struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
 				struct dm_list *mdas, uint64_t *label_sector,
 				int warnings, int scan_label_only)
 {
-	return _pv_read(cmd, pv_name, mdas, label_sector, warnings, scan_label_only);
+	return _pv_read(cmd, cmd->mem, pv_name, mdas, label_sector, warnings, scan_label_only);
 }
 
 /* FIXME Use label functions instead of PV functions */
 static struct physical_volume *_pv_read(struct cmd_context *cmd,
+					struct dm_pool *pvmem,
 					const char *pv_name,
 					struct dm_list *mdas,
 					uint64_t *label_sector,
@@ -2245,7 +2247,7 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 	if (label_sector && *label_sector)
 		*label_sector = label->sector;
 
-	if (!(pv = dm_pool_zalloc(cmd->mem, sizeof(*pv)))) {
+	if (!(pv = dm_pool_zalloc(pvmem, sizeof(*pv)))) {
 		log_error("pv allocation for '%s' failed", pv_name);
 		return NULL;
 	}
@@ -2263,8 +2265,8 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 
 	if (!pv->size)
 		return NULL;
-	
-	if (!alloc_pv_segment_whole_pv(cmd->mem, pv))
+
+	if (!alloc_pv_segment_whole_pv(pvmem, pv))
 		return_NULL;
 
 	return pv;
@@ -2918,7 +2920,7 @@ uint32_t vg_status(const vg_t *vg)
 pv_t *pv_by_path(struct cmd_context *cmd, const char *pv_name)
 {
 	struct dm_list mdas;
-	
+
 	dm_list_init(&mdas);
-	return _pv_read(cmd, pv_name, &mdas, NULL, 1, 0);
+	return _pv_read(cmd, cmd->mem, pv_name, &mdas, NULL, 1, 0);
 }



