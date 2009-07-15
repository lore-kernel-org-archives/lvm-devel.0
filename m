From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Jul 2009 17:26:27 -0000
Subject: LVM2/lib/metadata metadata-exported.h metadata.c
Message-ID: <20090715172627.5423.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-15 17:26:26

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 

Log message:
	Revert broken commit:
	2009-07-15 06:10:51  Un-export vg_read_internal.
	
	lvm-functions.c:774: warning: implicit declaration of function 'vg_read_internal'

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.95&r2=1.96
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.254&r2=1.255

--- LVM2/lib/metadata/metadata-exported.h	2009/07/15 06:10:51	1.95
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/15 17:26:26	1.96
@@ -343,6 +343,8 @@
 int vg_write(struct volume_group *vg);
 int vg_commit(struct volume_group *vg);
 int vg_revert(struct volume_group *vg);
+struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vg_name,
+			     const char *vgid, int *consistent);
 struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
 				struct dm_list *mdas, uint64_t *label_sector,
 				int warnings, int scan_label_only);
--- LVM2/lib/metadata/metadata.c	2009/07/15 06:10:51	1.254
+++ LVM2/lib/metadata/metadata.c	2009/07/15 17:26:26	1.255
@@ -31,9 +31,6 @@
 
 #include <sys/param.h>
 
-static struct volume_group *_vg_read_internal(struct cmd_context *cmd,
-					      const char *vgname,
-					      const char *vgid, int *consistent);
 /*
  * FIXME: Check for valid handle before dereferencing field or log error?
  */
@@ -253,8 +250,8 @@
 	struct pv_list *pvl;
 	int r = 0, consistent = 0;
 
-	if (!(vg = _vg_read_internal(fmt->cmd, vg_name, vgid, &consistent))) {
-		log_error("get_pv_from_vg_by_id: _vg_read_internal failed to read VG %s",
+	if (!(vg = vg_read_internal(fmt->cmd, vg_name, vgid, &consistent))) {
+		log_error("get_pv_from_vg_by_id: vg_read_internal failed to read VG %s",
 			  vg_name);
 		return 0;
 	}
@@ -626,7 +623,7 @@
 	/* FIXME: Is this vg_read_internal necessary? Move it inside
 	   vg_lock_newname? */
 	/* is this vg name already in use ? */
-	if ((vg = _vg_read_internal(cmd, vg_name, NULL, &consistent))) {
+	if ((vg = vg_read_internal(cmd, vg_name, NULL, &consistent))) {
 		log_error("A volume group called '%s' already exists.", vg_name);
 		unlock_and_release_vg(cmd, vg, vg_name);
 		return _vg_make_handle(cmd, NULL, FAILED_EXIST);
@@ -2042,7 +2039,7 @@
 
 	if (is_orphan_vg(vgname)) {
 		if (use_precommitted) {
-			log_error("Internal error: _vg_read_internal requires vgname "
+			log_error("Internal error: vg_read_internal requires vgname "
 				  "with pre-commit.");
 			return NULL;
 		}
@@ -2331,9 +2328,8 @@
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
@@ -2374,7 +2370,7 @@
 
 /* This is only called by lv_from_lvid, which is only called from
  * activate.c so we know the appropriate VG lock is already held and
- * the _vg_read_internal is therefore safe.
+ * the vg_read_internal is therefore safe.
  */
 static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 					    const char *vgid,
@@ -2407,7 +2403,7 @@
 	if (memlock())
 		goto out;
 
-	/* FIXME Need a genuine read by ID here - don't _vg_read_internal by name! */
+	/* FIXME Need a genuine read by ID here - don't vg_read_internal by name! */
 	/* FIXME Disabled vgrenames while active for now because we aren't
 	 *       allowed to do a full scan here any more. */
 
@@ -2598,7 +2594,7 @@
 			stack;
 			continue;
 		}
-		if (!(vg = _vg_read_internal(cmd, vgname, vgid, &consistent))) {
+		if (!(vg = vg_read_internal(cmd, vgname, vgid, &consistent))) {
 			stack;
 			continue;
 		}
@@ -2856,7 +2852,7 @@
 	if (!lock_vol(cmd, lock_name, lock_flags))
 		return_NULL;
 
-	if (!(vg = _vg_read_internal(cmd, vg_name, vgid, &consistent)))
+	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent)))
 		return_NULL;
 
 	if (!consistent) {
@@ -2913,7 +2909,7 @@
 	consistent_in = consistent;
 
 	/* If consistent == 1, we get NULL here if correction fails. */
-	if (!(vg = _vg_read_internal(cmd, vg_name, vgid, &consistent))) {
+	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent))) {
 		if (consistent_in && !consistent) {
 			log_error("Volume group \"%s\" inconsistent.", vg_name);
 			failure |= FAILED_INCONSISTENT;


