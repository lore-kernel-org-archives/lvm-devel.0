From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Nov 2010 01:56:18 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20101123015618.11963.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-11-23 01:56:02

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : pvremove.c toollib.c 

Log message:
	Suppress 'No PV label' message when removing several PVs without mdas.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1801&r2=1.1802
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.99&r2=1.100
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.170&r2=1.171
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.409&r2=1.410
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.212&r2=1.213

--- LVM2/WHATS_NEW	2010/11/22 21:39:47	1.1801
+++ LVM2/WHATS_NEW	2010/11/23 01:55:53	1.1802
@@ -1,5 +1,6 @@
 Version 2.02.78 - 
 ====================================
+  Suppress 'No PV label' message when removing several PVs without mdas.
   Fix default /etc/lvm permissions to be 0755. (2.02.66)
 
 Version 2.02.77 - 22nd November 2010
--- LVM2/daemons/clvmd/lvm-functions.c	2010/08/17 19:25:05	1.99
+++ LVM2/daemons/clvmd/lvm-functions.c	2010/11/23 01:55:58	1.100
@@ -848,7 +848,7 @@
 
 	pthread_mutex_lock(&lvm_lock);
 
-	vg = vg_read_internal(cmd, vgname, NULL /*vgid*/, &consistent);
+	vg = vg_read_internal(cmd, vgname, NULL /*vgid*/, 1, &consistent);
 
 	if (vg && consistent)
 		check_current_backup(vg);
--- LVM2/lib/metadata/metadata-exported.h	2010/11/11 17:29:06	1.170
+++ LVM2/lib/metadata/metadata-exported.h	2010/11/23 01:55:59	1.171
@@ -341,7 +341,7 @@
 int vg_commit(struct volume_group *vg);
 int vg_revert(struct volume_group *vg);
 struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vg_name,
-			     const char *vgid, int *consistent);
+			     const char *vgid, int warnings, int *consistent);
 struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
 				struct dm_list *mdas, uint64_t *label_sector,
 				int warnings, int scan_label_only);
@@ -357,7 +357,7 @@
 
 struct dm_list *get_vgnames(struct cmd_context *cmd, int include_internal);
 struct dm_list *get_vgids(struct cmd_context *cmd, int include_internal);
-int scan_vgs_for_pvs(struct cmd_context *cmd);
+int scan_vgs_for_pvs(struct cmd_context *cmd, int warnings);
 
 int pv_write(struct cmd_context *cmd, struct physical_volume *pv,
 	     struct dm_list *mdas, int64_t label_sector);
--- LVM2/lib/metadata/metadata.c	2010/11/09 12:34:42	1.409
+++ LVM2/lib/metadata/metadata.c	2010/11/23 01:55:59	1.410
@@ -344,7 +344,7 @@
 	struct pv_list *pvl;
 	int r = 0, consistent = 0;
 
-	if (!(vg = vg_read_internal(fmt->cmd, vg_name, vgid, &consistent))) {
+	if (!(vg = vg_read_internal(fmt->cmd, vg_name, vgid, 1, &consistent))) {
 		log_error("get_pv_from_vg_by_id: vg_read_internal failed to read VG %s",
 			  vg_name);
 		return 0;
@@ -918,7 +918,7 @@
 	/* FIXME: Is this vg_read_internal necessary? Move it inside
 	   vg_lock_newname? */
 	/* is this vg name already in use ? */
-	if ((vg = vg_read_internal(cmd, vg_name, NULL, &consistent))) {
+	if ((vg = vg_read_internal(cmd, vg_name, NULL, 1, &consistent))) {
 		log_error("A volume group called '%s' already exists.", vg_name);
 		unlock_and_release_vg(cmd, vg, vg_name);
 		return _vg_make_handle(cmd, NULL, FAILED_EXIST);
@@ -1343,7 +1343,7 @@
 	 * system.
 	 */
 	if (pv && is_orphan(pv) && mdas_empty_or_ignored(&mdas)) {
-		if (!scan_vgs_for_pvs(cmd))
+		if (!scan_vgs_for_pvs(cmd, 0))
 			return_0;
 		pv = pv_read(cmd, name, NULL, NULL, 0, 0);
 	}
@@ -1812,7 +1812,7 @@
 
 	if (is_orphan_vg(pv->vg_name) && mdas_empty_or_ignored(&mdas)) {
 		/* If a PV has no MDAs - need to search all VGs for it */
-		if (!scan_vgs_for_pvs(cmd))
+		if (!scan_vgs_for_pvs(cmd, 1))
 			return_NULL;
 		if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, NULL, 1, 0))) {
 			log_error("Physical volume %s not found", pv_name);
@@ -2513,6 +2513,7 @@
 
 /* Make orphan PVs look like a VG */
 static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
+					     int warnings,
 					     const char *orphan_vgname)
 {
 	struct lvmcache_vginfo *vginfo;
@@ -2554,7 +2555,7 @@
 	}
 
 	dm_list_iterate_items(info, &vginfo->infos) {
-		if (!(pv = _pv_read(cmd, mem, dev_name(info->dev), NULL, NULL, 1, 0))) {
+		if (!(pv = _pv_read(cmd, mem, dev_name(info->dev), NULL, NULL, warnings, 0))) {
 			continue;
 		}
 		if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl)))) {
@@ -2641,6 +2642,7 @@
 static struct volume_group *_vg_read(struct cmd_context *cmd,
 				     const char *vgname,
 				     const char *vgid,
+				     int warnings, 
 				     int *consistent, unsigned precommitted)
 {
 	struct format_instance *fid;
@@ -2667,7 +2669,7 @@
 			return NULL;
 		}
 		*consistent = 1;
-		return _vg_read_orphans(cmd, vgname);
+		return _vg_read_orphans(cmd, warnings, vgname);
 	}
 
 	/*
@@ -3035,12 +3037,12 @@
 }
 
 struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgname,
-			     const char *vgid, int *consistent)
+			     const char *vgid, int warnings, int *consistent)
 {
 	struct volume_group *vg;
 	struct lv_list *lvl;
 
-	if (!(vg = _vg_read(cmd, vgname, vgid, consistent, 0)))
+	if (!(vg = _vg_read(cmd, vgname, vgid, warnings, consistent, 0)))
 		return NULL;
 
 	if (!check_pv_segments(vg)) {
@@ -3104,7 +3106,7 @@
 	/* Is corresponding vgname already cached? */
 	if ((vginfo = vginfo_from_vgid(vgid)) &&
 	    vginfo->vgname && !is_orphan_vg(vginfo->vgname)) {
-		if ((vg = _vg_read(cmd, NULL, vgid,
+		if ((vg = _vg_read(cmd, NULL, vgid, 1,
 				   &consistent, precommitted)) &&
 		    !strncmp((char *)vg->id.uuid, vgid, ID_LEN)) {
 
@@ -3137,7 +3139,7 @@
 		if (!vgname)
 			continue;	// FIXME Unnecessary?
 		consistent = 0;
-		if ((vg = _vg_read(cmd, vgname, vgid, &consistent,
+		if ((vg = _vg_read(cmd, vgname, vgid, 1, &consistent,
 				   precommitted)) &&
 		    !strncmp((char *)vg->id.uuid, vgid, ID_LEN)) {
 
@@ -3208,7 +3210,7 @@
 		 * every PV on the system.
 		 */
 		if (mdas_empty_or_ignored(&info->mdas)) {
-			if (!scan_vgs_for_pvs(cmd)) {
+			if (!scan_vgs_for_pvs(cmd, 1)) {
 				log_error("Rescan for PVs without "
 					  "metadata areas failed.");
 				return NULL;
@@ -3323,7 +3325,7 @@
 	return lvmcache_get_vgids(cmd, include_internal);
 }
 
-static int _get_pvs(struct cmd_context *cmd, struct dm_list **pvslist)
+static int _get_pvs(struct cmd_context *cmd, int warnings, struct dm_list **pvslist)
 {
 	struct str_list *strl;
 	struct dm_list * uninitialized_var(results);
@@ -3364,7 +3366,7 @@
 			stack;
 			continue;
 		}
-		if (!(vg = vg_read_internal(cmd, vgname, vgid, &consistent))) {
+		if (!(vg = vg_read_internal(cmd, vgname, vgid, warnings, &consistent))) {
 			stack;
 			continue;
 		}
@@ -3398,15 +3400,15 @@
 {
 	struct dm_list *results;
 
-	if (!_get_pvs(cmd, &results))
+	if (!_get_pvs(cmd, 1, &results))
 		return NULL;
 
 	return results;
 }
 
-int scan_vgs_for_pvs(struct cmd_context *cmd)
+int scan_vgs_for_pvs(struct cmd_context *cmd, int warnings)
 {
-	return _get_pvs(cmd, NULL);
+	return _get_pvs(cmd, warnings, NULL);
 }
 
 int pv_write(struct cmd_context *cmd __attribute__((unused)),
@@ -3581,7 +3583,7 @@
 	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE))
 		return_NULL;
 
-	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent)))
+	if (!(vg = vg_read_internal(cmd, vg_name, vgid, 1, &consistent)))
 		return_NULL;
 
 	if (!consistent) {
@@ -3636,7 +3638,7 @@
 	consistent_in = consistent;
 
 	/* If consistent == 1, we get NULL here if correction fails. */
-	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent))) {
+	if (!(vg = vg_read_internal(cmd, vg_name, vgid, 1, &consistent))) {
 		if (consistent_in && !consistent) {
 			log_error("Volume group \"%s\" inconsistent.", vg_name);
 			failure |= FAILED_INCONSISTENT;
--- LVM2/tools/pvremove.c	2010/09/23 12:02:34	1.30
+++ LVM2/tools/pvremove.c	2010/11/23 01:56:02	1.31
@@ -48,7 +48,7 @@
 	 * PV on the system.
 	 */
 	if (is_orphan(pv) && !dm_list_size(&mdas)) {
-		if (!scan_vgs_for_pvs(cmd)) {
+		if (!scan_vgs_for_pvs(cmd, 0)) {
 			log_error("Rescan for PVs without metadata areas "
 				  "failed.");
 			return 0;
--- LVM2/tools/toollib.c	2010/11/17 10:19:30	1.212
+++ LVM2/tools/toollib.c	2010/11/23 01:56:02	1.213
@@ -629,7 +629,7 @@
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 
-	if (!scan_vgs_for_pvs(cmd)) {
+	if (!scan_vgs_for_pvs(cmd, 1)) {
 		stack;
 		return ECMD_FAILED;
 	}
@@ -744,7 +744,7 @@
 				if (!scanned && is_orphan(pv) &&
 				    !dm_list_size(&mdas)) {
 					if (!scan_label_only &&
-					    !scan_vgs_for_pvs(cmd)) {
+					    !scan_vgs_for_pvs(cmd, 1)) {
 						stack;
 						ret_max = ECMD_FAILED;
 						continue;


