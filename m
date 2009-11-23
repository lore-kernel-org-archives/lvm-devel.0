From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 23 Nov 2009 10:44:52 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20091123104452.1396.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-11-23 10:44:51

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	lib/metadata   : metadata-exported.h metadata.c 

Log message:
	Revert vg_read_internal change, clvmd cannot use vg_read now. (2.02.55)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1320&r2=1.1321
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.122&r2=1.123
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.297&r2=1.298

--- LVM2/WHATS_NEW	2009/11/19 19:53:58	1.1320
+++ LVM2/WHATS_NEW	2009/11/23 10:44:50	1.1321
@@ -1,5 +1,6 @@
 Version 2.02.56 - 
 ====================================
+  Revert vg_read_internal change, clvmd cannot use vg_read now. (2.02.55)
 
 Version 2.02.55 - 19th November 2009
 ====================================
--- LVM2/daemons/clvmd/lvm-functions.c	2009/11/19 12:13:37	1.71
+++ LVM2/daemons/clvmd/lvm-functions.c	2009/11/23 10:44:51	1.72
@@ -774,14 +774,15 @@
 void lvm_do_backup(const char *vgname)
 {
 	struct volume_group * vg;
+	int consistent = 0;
 
 	DEBUGLOG("Triggering backup of VG metadata for %s. suspended=%d\n", vgname, suspended);
 
 	pthread_mutex_lock(&lvm_lock);
 
-	vg = vg_read(cmd, vgname, NULL /*vgid*/, 0 /*flags*/);
+	vg = vg_read_internal(cmd, vgname, NULL /*vgid*/, &consistent);
 
-	if (!vg_read_error(vg))
+	if (vg && consistent)
 		check_current_backup(vg);
 	else
 		log_error("Error backing up metadata, can't find VG for group %s", vgname);
--- LVM2/lib/metadata/metadata-exported.h	2009/11/19 12:13:37	1.122
+++ LVM2/lib/metadata/metadata-exported.h	2009/11/23 10:44:51	1.123
@@ -380,6 +380,8 @@
 int vg_write(struct volume_group *vg);
 int vg_commit(struct volume_group *vg);
 int vg_revert(struct volume_group *vg);
+struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vg_name,
+			     const char *vgid, int *consistent);
 struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
 				struct dm_list *mdas, uint64_t *label_sector,
 				int warnings, int scan_label_only);
@@ -470,7 +472,7 @@
 		     force_t force);
 /*
  * vg_release() must be called on every struct volume_group allocated
- * by vg_create() or vg_read() to free it when no longer required.
+ * by vg_create() or vg_read_internal() to free it when no longer required.
  */
 void vg_release(struct volume_group *vg);
 
--- LVM2/lib/metadata/metadata.c	2009/11/19 13:44:37	1.297
+++ LVM2/lib/metadata/metadata.c	2009/11/23 10:44:51	1.298
@@ -58,10 +58,6 @@
 static uint32_t _vg_bad_status_bits(const struct volume_group *vg,
 				    uint32_t status);
 
-static struct volume_group *_vg_read_internal(struct cmd_context *cmd,
-					      const char *vgname,
-					      const char *vgid, int *consistent);
-
 const char _really_init[] =
     "Really INITIALIZE physical volume \"%s\" of volume group \"%s\" [y/n]? ";
 
@@ -288,7 +284,7 @@
 	struct pv_list *pvl;
 	int r = 0, consistent = 0;
 
-	if (!(vg = _vg_read_internal(fmt->cmd, vg_name, vgid, &consistent))) {
+	if (!(vg = vg_read_internal(fmt->cmd, vg_name, vgid, &consistent))) {
 		log_error("get_pv_from_vg_by_id: vg_read_internal failed to read VG %s",
 			  vg_name);
 		return 0;
@@ -790,10 +786,10 @@
 		/* NOTE: let caller decide - this may be check for existence */
 		return _vg_make_handle(cmd, NULL, rc);
 
-	/* FIXME: Is this _vg_read_internal necessary? Move it inside
+	/* FIXME: Is this vg_read_internal necessary? Move it inside
 	   vg_lock_newname? */
 	/* is this vg name already in use ? */
-	if ((vg = _vg_read_internal(cmd, vg_name, NULL, &consistent))) {
+	if ((vg = vg_read_internal(cmd, vg_name, NULL, &consistent))) {
 		log_error("A volume group called '%s' already exists.", vg_name);
 		unlock_and_release_vg(cmd, vg, vg_name);
 		return _vg_make_handle(cmd, NULL, FAILED_EXIST);
@@ -2494,7 +2490,7 @@
 
 	if (is_orphan_vg(vgname)) {
 		if (use_precommitted) {
-			log_error("Internal error: _vg_read requires vgname "
+			log_error("Internal error: vg_read_internal requires vgname "
 				  "with pre-commit.");
 			return NULL;
 		}
@@ -2783,9 +2779,8 @@
 	return correct_vg;
 }
 
-static struct volume_group *_vg_read_internal(struct cmd_context *cmd,
-					      const char *vgname,
-					      const char *vgid, int *consistent)
+struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgname,
+			     const char *vgid, int *consistent)
 {
 	struct volume_group *vg;
 	struct lv_list *lvl;
@@ -3050,7 +3045,7 @@
 			stack;
 			continue;
 		}
-		if (!(vg = _vg_read_internal(cmd, vgname, vgid, &consistent))) {
+		if (!(vg = vg_read_internal(cmd, vgname, vgid, &consistent))) {
 			stack;
 			continue;
 		}
@@ -3284,7 +3279,7 @@
 	if (!lock_vol(cmd, lock_name, lock_flags))
 		return_NULL;
 
-	if (!(vg = _vg_read_internal(cmd, vg_name, vgid, &consistent)))
+	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent)))
 		return_NULL;
 
 	if (!consistent) {
@@ -3341,7 +3336,7 @@
 	consistent_in = consistent;
 
 	/* If consistent == 1, we get NULL here if correction fails. */
-	if (!(vg = _vg_read_internal(cmd, vg_name, vgid, &consistent))) {
+	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent))) {
 		if (consistent_in && !consistent) {
 			log_error("Volume group \"%s\" inconsistent.", vg_name);
 			failure |= FAILED_INCONSISTENT;


