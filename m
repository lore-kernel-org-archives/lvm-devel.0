From: Petr Rockai <prockai@redhat.com>
Date: Thu, 22 Jan 2009 11:10:10 +0100
Subject: [PATCH 14/14] Un-export vg_read_internal.
In-Reply-To: <1232619010-4858-14-git-send-email-prockai@redhat.com>
References: <1232619010-4858-1-git-send-email-prockai@redhat.com>
	<1232619010-4858-2-git-send-email-prockai@redhat.com>
	<1232619010-4858-3-git-send-email-prockai@redhat.com>
	<1232619010-4858-4-git-send-email-prockai@redhat.com>
	<1232619010-4858-5-git-send-email-prockai@redhat.com>
	<1232619010-4858-6-git-send-email-prockai@redhat.com>
	<1232619010-4858-7-git-send-email-prockai@redhat.com>
	<1232619010-4858-8-git-send-email-prockai@redhat.com>
	<1232619010-4858-9-git-send-email-prockai@redhat.com>
	<1232619010-4858-10-git-send-email-prockai@redhat.com>
	<1232619010-4858-11-git-send-email-prockai@redhat.com>
	<1232619010-4858-12-git-send-email-prockai@redhat.com>
	<1232619010-4858-13-git-send-email-prockai@redhat.com>
	<1232619010-4858-14-git-send-email-prockai@redhat.com>
Message-ID: <1232619010-4858-15-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Thu Jan 22 10:56:49 CET 2009  Petr Rockai <me@mornfall.net>
  * Un-export vg_read_internal.
diff -rN -u -p old-temp.4430/lib/metadata/metadata.c new-temp.4430/lib/metadata/metadata.c
--- old-temp.4430/lib/metadata/metadata.c	2009-01-22 11:02:58.730781531 +0100
+++ new-temp.4430/lib/metadata/metadata.c	2009-01-22 11:02:58.778780229 +0100
@@ -31,6 +31,9 @@
 
 #include <sys/param.h>
 
+static struct volume_group *_vg_read_internal(struct cmd_context *cmd,
+					      const char *vgname,
+					      const char *vgid, int *consistent);
 /*
  * FIXME: Check for valid handle before dereferencing field or log error?
  */
@@ -224,8 +227,8 @@ int get_pv_from_vg_by_id(const struct fo
 	struct pv_list *pvl;
 	int consistent = 0;
 
-	if (!(vg = vg_read_internal(fmt->cmd, vg_name, vgid, &consistent))) {
-		log_error("get_pv_from_vg_by_id: vg_read_internal failed to read VG %s",
+	if (!(vg = _vg_read_internal(fmt->cmd, vg_name, vgid, &consistent))) {
+		log_error("get_pv_from_vg_by_id: _vg_read_internal failed to read VG %s",
 			  vg_name);
 		return 0;
 	}
@@ -503,7 +506,7 @@ struct volume_group *vg_create(struct cm
 		return_NULL;
 
 	/* is this vg name already in use ? */
-	if (vg_read_internal(cmd, vg_name, NULL, &consistent)) {
+	if (_vg_read_internal(cmd, vg_name, NULL, &consistent)) {
 		log_err("A volume group called '%s' already exists.", vg_name);
 		goto bad;
 	}
@@ -1716,7 +1719,7 @@ static struct volume_group *_vg_read(str
 
 	if (is_orphan_vg(vgname)) {
 		if (use_precommitted) {
-			log_error("Internal error: vg_read_internal requires vgname "
+			log_error("Internal error: _vg_read_internal requires vgname "
 				  "with pre-commit.");
 			return NULL;
 		}
@@ -1974,8 +1977,9 @@ static struct volume_group *_vg_read(str
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
@@ -2002,7 +2006,7 @@ struct volume_group *vg_read_internal(st
 
 /* This is only called by lv_from_lvid, which is only called from
  * activate.c so we know the appropriate VG lock is already held and
- * the vg_read_internal is therefore safe.
+ * the _vg_read_internal is therefore safe.
  */
 static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 					    const char *vgid,
@@ -2034,7 +2038,7 @@ static struct volume_group *_vg_read_by_
 	if (memlock())
 		return NULL;
 
-	/* FIXME Need a genuine read by ID here - don't vg_read_internal by name! */
+	/* FIXME Need a genuine read by ID here - don't _vg_read_internal by name! */
 	/* FIXME Disabled vgrenames while active for now because we aren't
 	 *       allowed to do a full scan here any more. */
 
@@ -2218,7 +2222,7 @@ static int _get_pvs(struct cmd_context *
 			stack;
 			continue;
 		}
-		if (!(vg = vg_read_internal(cmd, vgname, vgid, &consistent))) {
+		if (!(vg = _vg_read_internal(cmd, vgname, vgid, &consistent))) {
 			stack;
 			continue;
 		}
@@ -2456,7 +2460,7 @@ static vg_t *_recover_vg(struct cmd_cont
 	if (!lock_vol(cmd, lock, lock_flags))
 		return_NULL;
 
-	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent)))
+	if (!(vg = _vg_read_internal(cmd, vg_name, vgid, &consistent)))
 		return_NULL;
 	if (!consistent)
 		return_NULL;
@@ -2515,7 +2519,7 @@ static vg_t *_vg_lock_and_read(struct cm
 	consistent_in = consistent;
 
 	/* If consistent == 1, we get NULL here if correction fails. */
-	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent))) {
+	if (!(vg = _vg_read_internal(cmd, vg_name, vgid, &consistent))) {
 		if (consistent_in && !consistent) {
 			log_error("Volume group \"%s\" inconsistent.", vg_name);
 			failure |= FAILED_INCONSISTENT;
diff -rN -u -p old-temp.4430/lib/metadata/metadata-exported.h new-temp.4430/lib/metadata/metadata-exported.h
--- old-temp.4430/lib/metadata/metadata-exported.h	2009-01-22 11:02:58.730781531 +0100
+++ new-temp.4430/lib/metadata/metadata-exported.h	2009-01-22 11:02:58.778780229 +0100
@@ -364,8 +364,6 @@ struct lv_list {
 int vg_write(struct volume_group *vg);
 int vg_commit(struct volume_group *vg);
 int vg_revert(struct volume_group *vg);
-struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vg_name,
-			     const char *vgid, int *consistent);
 struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
 				struct dm_list *mdas, uint64_t *label_sector,
 				int warnings);


