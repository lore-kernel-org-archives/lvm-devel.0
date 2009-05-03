From: Petr Rockai <prockai@redhat.com>
Date: Sun,  3 May 2009 13:39:00 +0200
Subject: [PATCH 8/9] Un-export vg_read_internal.
In-Reply-To: <1241350741-31349-8-git-send-email-prockai@redhat.com>
References: <1241350741-31349-1-git-send-email-prockai@redhat.com>
	<1241350741-31349-2-git-send-email-prockai@redhat.com>
	<1241350741-31349-3-git-send-email-prockai@redhat.com>
	<1241350741-31349-4-git-send-email-prockai@redhat.com>
	<1241350741-31349-5-git-send-email-prockai@redhat.com>
	<1241350741-31349-6-git-send-email-prockai@redhat.com>
	<1241350741-31349-7-git-send-email-prockai@redhat.com>
	<1241350741-31349-8-git-send-email-prockai@redhat.com>
Message-ID: <1241350741-31349-9-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Sun May  3 13:17:06 CEST 2009  Petr Rockai <me@mornfall.net>
  * Un-export vg_read_internal.
diff -rN -u -p old-temp.31080/lib/metadata/metadata.c new-temp.31080/lib/metadata/metadata.c
--- old-temp.31080/lib/metadata/metadata.c	2009-05-03 13:29:39.590237605 +0200
+++ new-temp.31080/lib/metadata/metadata.c	2009-05-03 13:29:39.638236373 +0200
@@ -31,6 +31,9 @@
 
 #include <sys/param.h>
 
+static struct volume_group *_vg_read_internal(struct cmd_context *cmd,
+					      const char *vgname,
+					      const char *vgid, int *consistent);
 /*
  * FIXME: Check for valid handle before dereferencing field or log error?
  */
@@ -244,8 +247,8 @@ int get_pv_from_vg_by_id(const struct fo
 	struct pv_list *pvl;
 	int r = 0, consistent = 0;
 
-	if (!(vg = vg_read_internal(fmt->cmd, vg_name, vgid, &consistent))) {
-		log_error("get_pv_from_vg_by_id: vg_read_internal failed to read VG %s",
+	if (!(vg = _vg_read_internal(fmt->cmd, vg_name, vgid, &consistent))) {
+		log_error("get_pv_from_vg_by_id: _vg_read_internal failed to read VG %s",
 			  vg_name);
 		return 0;
 	}
@@ -525,7 +528,7 @@ struct volume_group *vg_create(struct cm
 	struct dm_pool *mem;
 
 	/* is this vg name already in use ? */
-	if ((vg = vg_read_internal(cmd, vg_name, NULL, &consistent))) {
+	if ((vg = _vg_read_internal(cmd, vg_name, NULL, &consistent))) {
 		log_err("A volume group called '%s' already exists.", vg_name);
 		vg_release(vg);
 		return NULL;
@@ -1772,7 +1775,7 @@ static struct volume_group *_vg_read(str
 
 	if (is_orphan_vg(vgname)) {
 		if (use_precommitted) {
-			log_error("Internal error: vg_read_internal requires vgname "
+			log_error("Internal error: _vg_read_internal requires vgname "
 				  "with pre-commit.");
 			return NULL;
 		}
@@ -2058,8 +2061,9 @@ static struct volume_group *_vg_read(str
 	return correct_vg;
 }
 
-struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgname,
-			     const char *vgid, int *consistent)
+static struct volume_group *_vg_read_internal(struct cmd_context *cmd,
+					      const char *vgname,
+					      const char *vgid, int *consistent)
 {
 	struct volume_group *vg;
 	struct lv_list *lvl;
@@ -2100,7 +2104,7 @@ void vg_release(struct volume_group *vg)
 
 /* This is only called by lv_from_lvid, which is only called from
  * activate.c so we know the appropriate VG lock is already held and
- * the vg_read_internal is therefore safe.
+ * the _vg_read_internal is therefore safe.
  */
 static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 					    const char *vgid,
@@ -2133,7 +2137,7 @@ static struct volume_group *_vg_read_by_
 	if (memlock())
 		goto out;
 
-	/* FIXME Need a genuine read by ID here - don't vg_read_internal by name! */
+	/* FIXME Need a genuine read by ID here - don't _vg_read_internal by name! */
 	/* FIXME Disabled vgrenames while active for now because we aren't
 	 *       allowed to do a full scan here any more. */
 
@@ -2324,7 +2328,7 @@ static int _get_pvs(struct cmd_context *
 			stack;
 			continue;
 		}
-		if (!(vg = vg_read_internal(cmd, vgname, vgid, &consistent))) {
+		if (!(vg = _vg_read_internal(cmd, vgname, vgid, &consistent))) {
 			stack;
 			continue;
 		}
@@ -2583,7 +2587,7 @@ static vg_t *_recover_vg(struct cmd_cont
 	if (!lock_vol(cmd, lock_name, lock_flags))
 		return_NULL;
 
-	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent)))
+	if (!(vg = _vg_read_internal(cmd, vg_name, vgid, &consistent)))
 		return_NULL;
 
 	if (!consistent) {
@@ -2642,7 +2646,7 @@ static vg_t *_vg_lock_and_read(struct cm
 	consistent_in = consistent;
 
 	/* If consistent == 1, we get NULL here if correction fails. */
-	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent))) {
+	if (!(vg = _vg_read_internal(cmd, vg_name, vgid, &consistent))) {
 		if (consistent_in && !consistent) {
 			log_error("Volume group \"%s\" inconsistent.", vg_name);
 			failure |= FAILED_INCONSISTENT;
diff -rN -u -p old-temp.31080/lib/metadata/metadata-exported.h new-temp.31080/lib/metadata/metadata-exported.h
--- old-temp.31080/lib/metadata/metadata-exported.h	2009-05-03 13:29:39.590237605 +0200
+++ new-temp.31080/lib/metadata/metadata-exported.h	2009-05-03 13:29:39.638236373 +0200
@@ -360,8 +360,6 @@ struct lv_list {
 int vg_write(struct volume_group *vg);
 int vg_commit(struct volume_group *vg);
 int vg_revert(struct volume_group *vg);
-struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vg_name,
-			     const char *vgid, int *consistent);
 struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
 				struct dm_list *mdas, uint64_t *label_sector,
 				int warnings, int scan_label_only);


