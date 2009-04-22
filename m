From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 22 Apr 2009 09:31:33 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20090422093133.12921.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-04-22 09:31:32

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Alloc PV internal structure from VG mempool if possible.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1091&r2=1.1092
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.211&r2=1.212

--- LVM2/WHATS_NEW	2009/04/21 14:31:57	1.1091
+++ LVM2/WHATS_NEW	2009/04/22 09:31:30	1.1092
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Alloc PV internal structure from VG mempool if possible.
   Fix metadata backup to run after vg_commit always.
   Tidy clvmd volume lock cache functions.
   Fix pvs report for orphan PVs when segment attributes are requested.
--- LVM2/lib/metadata/metadata.c	2009/04/10 10:01:08	1.211
+++ LVM2/lib/metadata/metadata.c	2009/04/22 09:31:31	1.212
@@ -38,6 +38,7 @@
 	(((const struct physical_volume *)(handle))->field)
 
 static struct physical_volume *_pv_read(struct cmd_context *cmd,
+					struct dm_pool *pvmem,
 					const char *pv_name,
 					struct dm_list *mdas,
 					uint64_t *label_sector,
@@ -1070,7 +1071,7 @@
 {
 	struct physical_volume *pv;
 
-	if (!(pv = _pv_read(cmd, pv_name, NULL, NULL, 1, 0))) {
+	if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, NULL, 1, 0))) {
 		log_error("Physical volume %s not found", pv_name);
 		return NULL;
 	}
@@ -1079,7 +1080,7 @@
 		/* If a PV has no MDAs - need to search all VGs for it */
 		if (!scan_vgs_for_pvs(cmd))
 			return_NULL;
-		if (!(pv = _pv_read(cmd, pv_name, NULL, NULL, 1, 0))) {
+		if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, NULL, 1, 0))) {
 			log_error("Physical volume %s not found", pv_name);
 			return NULL;
 		}
@@ -1684,7 +1685,7 @@
 	}
 
 	dm_list_iterate_items(info, &vginfo->infos) {
-		if (!(pv = _pv_read(cmd, dev_name(info->dev), NULL, NULL, 1, 0))) {
+		if (!(pv = _pv_read(cmd, mem, dev_name(info->dev), NULL, NULL, 1, 0))) {
 			continue;
 		}
 		if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl)))) {
@@ -2216,11 +2217,12 @@
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
@@ -2245,7 +2247,7 @@
 	if (label_sector && *label_sector)
 		*label_sector = label->sector;
 
-	if (!(pv = dm_pool_zalloc(cmd->mem, sizeof(*pv)))) {
+	if (!(pv = dm_pool_zalloc(pvmem, sizeof(*pv)))) {
 		log_error("pv allocation for '%s' failed", pv_name);
 		return NULL;
 	}
@@ -2263,8 +2265,8 @@
 
 	if (!pv->size)
 		return NULL;
-	
-	if (!alloc_pv_segment_whole_pv(cmd->mem, pv))
+
+	if (!alloc_pv_segment_whole_pv(pvmem, pv))
 		return_NULL;
 
 	return pv;
@@ -2918,7 +2920,7 @@
 pv_t *pv_by_path(struct cmd_context *cmd, const char *pv_name)
 {
 	struct dm_list mdas;
-	
+
 	dm_list_init(&mdas);
-	return _pv_read(cmd, pv_name, &mdas, NULL, 1, 0);
+	return _pv_read(cmd, cmd->mem, pv_name, &mdas, NULL, 1, 0);
 }


