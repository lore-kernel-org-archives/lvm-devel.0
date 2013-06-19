From: Petr Rockai <prockai@redhat.com>
Date: Wed, 19 Jun 2013 11:24:39 +0200
Subject: [PATCH 9/9] metadata: Nuke the exported "pv_read" function.
In-Reply-To: <1371633879-8879-1-git-send-email-prockai@redhat.com>
References: <1371633879-8879-1-git-send-email-prockai@redhat.com>
Message-ID: <1371633879-8879-9-git-send-email-prockai@redhat.com>
	(sfid-20130619_112442_393588_BFC3DDBF)
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 lib/metadata/metadata-exported.h |  3 ---
 lib/metadata/metadata.c          | 36 ------------------------------------
 2 files changed, 39 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 10aea9e..b08ef7c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -438,9 +438,6 @@ int vg_commit(struct volume_group *vg);
 void vg_revert(struct volume_group *vg);
 struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vg_name,
 				      const char *vgid, int warnings, int *consistent);
-struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
-				int warnings,
-				int scan_label_only);
 struct dm_list *get_pvs(struct cmd_context *cmd);
 
 /*
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index f28b067..0690903 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1337,20 +1337,6 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 	if (!(pv = find_pv_by_name(cmd, name, 1)))
 		stack;
 
-	/*
-	 * If a PV has no MDAs it may appear to be an orphan until the
-	 * metadata is read off another PV in the same VG.  Detecting
-	 * this means checking every VG by scanning every PV on the
-	 * system.
-	 */
-	if (pv && is_orphan(pv) && !dm_list_size(&pv->fid->metadata_areas_in_use)) {
-		free_pv_fid(pv);
-		if (!scan_vgs_for_pvs(cmd, 0))
-			return_0;
-		if (!(pv = pv_read(cmd, name, 0, 0)))
-			stack;
-	}
-
 	/* Allow partial & exported VGs to be destroyed. */
 	/* We must have -ff to overwrite a non orphan */
 	if (pv && !is_orphan(pv) && pp->force != DONT_PROMPT_OVERRIDE) {
@@ -3607,28 +3593,6 @@ const char *find_vgname_from_pvname(struct cmd_context *cmd,
 	return find_vgname_from_pvid(cmd, pvid);
 }
 
-/**
- * pv_read - read and return a handle to a physical volume
- * @cmd: LVM command initiating the pv_read
- * @pv_name: full device name of the PV, including the path
- * @mdas: list of metadata areas of the PV
- * @label_sector: sector number where the PV label is stored on @pv_name
- * @warnings:
- *
- * Returns:
- *   PV handle - valid pv_name and successful read of the PV, or
- *   NULL - invalid parameter or error in reading the PV
- *
- * Note:
- *   FIXME - liblvm todo - make into function that returns handle
- */
-struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
-				int warnings,
-				int scan_label_only)
-{
-	return _pv_read(cmd, cmd->mem, pv_name, NULL, warnings, scan_label_only);
-}
-
 /* FIXME Use label functions instead of PV functions */
 static struct physical_volume *_pv_read(struct cmd_context *cmd,
 					struct dm_pool *pvmem,
-- 
1.8.2


