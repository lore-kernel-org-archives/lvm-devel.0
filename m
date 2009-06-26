From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 26 Jun 2009 02:59:49 -0400
Subject: [PATCH] Convert the straight instances of vg_lock_and_read to new vg_read(_for_update).
Message-ID: <1245999589-2926-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Petr Rockai <prockai@redhat.com>

Sun May  3 11:40:51 CEST 2009  Petr Rockai <me@mornfall.net>
  * Convert the straight instances of vg_lock_and_read to new vg_read(_for_update).

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/lvconvert.c  |   16 +++++-----------
 tools/lvcreate.c   |    5 ++---
 tools/lvrename.c   |    5 ++---
 tools/lvresize.c   |    5 ++---
 tools/polldaemon.c |    3 ++-
 tools/pvchange.c   |    5 ++---
 tools/pvdisplay.c  |    4 ++--
 tools/pvmove.c     |   12 +++---------
 tools/pvresize.c   |   15 ++-------------
 tools/reporter.c   |    4 ++--
 tools/vgextend.c   |   11 +++++------
 tools/vgmerge.c    |   14 ++++++--------
 12 files changed, 35 insertions(+), 64 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index e2afd78..e2285fd 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -239,13 +239,8 @@ static struct volume_group *_get_lvconvert_vg(struct cmd_context *cmd,
 {
 	dev_close_all();
 
-	/*
-	 * uuid is here LV uuid, but vg_read will use only first part.
-	 */
-        return vg_lock_and_read(cmd, extract_vgname(cmd, lv_name),
-				uuid, LCK_VG_WRITE,
- 				CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				CORRECT_INCONSISTENT | FAIL_INCONSISTENT);
+        return vg_read_for_update(cmd, extract_vgname(cmd, lv_name),
+				  NULL, 0);
 }
 
 static struct logical_volume *_get_lvconvert_lv(struct cmd_context *cmd __attribute((unused)),
@@ -938,10 +933,9 @@ int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 
 	log_verbose("Checking for existing volume group \"%s\"", lp.vg_name);
 
-	if (!(vg = vg_lock_and_read(cmd, lp.vg_name, NULL, LCK_VG_WRITE,
-				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
-		goto out;
+	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
+	if (vg_read_error(vg))
+		return ECMD_FAILED;
 
 	if (!(lvl = find_lv_in_vg(vg, lp.lv_name))) {
 		log_error("Logical volume \"%s\" not found in "
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 37d30c6..030aa0c 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -994,9 +994,8 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 
 	log_verbose("Finding volume group \"%s\"", lp.vg_name);
-	if (!(vg = vg_lock_and_read(cmd, lp.vg_name, NULL, LCK_VG_WRITE,
-				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
+	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
+	if (vg_read_error(vg))
 		return ECMD_FAILED;
 
 	if (!_lvcreate(cmd, vg, &lp))
diff --git a/tools/lvrename.c b/tools/lvrename.c
index b5d3b38..53ea116 100644
--- a/tools/lvrename.c
+++ b/tools/lvrename.c
@@ -102,9 +102,8 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	log_verbose("Checking for existing volume group \"%s\"", vg_name);
-	if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_WRITE,
-				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
+	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
+	if (vg_read_error(vg))
 		return ECMD_FAILED;
 
 	if (!(lvl = find_lv_in_vg(vg, lv_name_old))) {
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 1c0f570..b558792 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -671,9 +671,8 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 
 	log_verbose("Finding volume group %s", lp.vg_name);
-	if (!(vg = vg_lock_and_read(cmd, lp.vg_name, NULL, LCK_VG_WRITE,
-				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
+	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
+	if (vg_read_error(vg)) {
 		stack;
 		return ECMD_FAILED;
 	}
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 1adb521..bdfd3de 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -147,7 +147,8 @@ static int _wait_for_single_mirror(struct cmd_context *cmd, const char *name, co
 		}
 
 		/* Locks the (possibly renamed) VG again */
-		if (!(vg = parms->poll_fns->get_copy_vg(cmd, name, uuid))) {
+		vg = parms->poll_fns->get_copy_vg(cmd, name);
+		if (vg_read_error(vg)) {
 			log_error("ABORTING: Can't reread VG for %s", name);
 			/* What more could we do here? */
 			return 0;
diff --git a/tools/pvchange.c b/tools/pvchange.c
index 98fe2f2..1c9d394 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -57,9 +57,8 @@ static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
 
 		log_verbose("Finding volume group %s of physical volume %s",
 			    vg_name, pv_name);
-		if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_WRITE,
-					    CLUSTERED | EXPORTED_VG | LVM_WRITE,
-					    CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
+		vg = vg_read_for_update(cmd, vg_name, NULL, 0);
+		if (vg_read_error(vg))
 			return_0;
 
 		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
diff --git a/tools/pvdisplay.c b/tools/pvdisplay.c
index 406e631..c8c4a88 100644
--- a/tools/pvdisplay.c
+++ b/tools/pvdisplay.c
@@ -29,8 +29,8 @@ static int _pvdisplay_single(struct cmd_context *cmd,
 
 	if (!is_orphan(pv) && !vg) {
 		vg_name = pv_vg_name(pv);
-		if (!(vg = vg_lock_and_read(cmd, vg_name, (char *)&pv->vgid,
-					    LCK_VG_READ, CLUSTERED, 0))) {
+		vg = vg_read(cmd, vg_name, (char *)&pv->vgid, 0);
+		if (vg_read_error(vg)) {
 		 	log_error("Skipping volume group %s", vg_name);
 			/* FIXME If CLUSTERED should return ECMD_PROCESSED here */
 		 	return ECMD_FAILED;
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 3d376e6..d288e6f 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -89,16 +89,9 @@ static const char *_extract_lvname(struct cmd_context *cmd, const char *vgname,
 
 static struct volume_group *_get_vg(struct cmd_context *cmd, const char *vgname)
 {
-	struct volume_group *vg;
-
 	dev_close_all();
 
-	if (!(vg = vg_lock_and_read(cmd, vgname, NULL, LCK_VG_WRITE,
-				    CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
-		 return NULL;
-
-	return vg;
+	return vg_read_for_update(cmd, vgname, NULL, 0);
 }
 
 /* Create list of PVs for allocation of replacement extents */
@@ -392,7 +385,8 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 	/* Read VG */
 	log_verbose("Finding volume group \"%s\"", pv_vg_name(pv));
 
-	if (!(vg = _get_vg(cmd, pv_vg_name(pv)))) {
+	vg = _get_vg(cmd, pv_vg_name(pv));
+	if (vg_read_error(vg)) {
 		stack;
 		return ECMD_FAILED;
 	}
diff --git a/tools/pvresize.c b/tools/pvresize.c
index 3b5f149..82c7936 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -29,7 +29,6 @@ static int _pv_resize_single(struct cmd_context *cmd,
 			     const uint64_t new_size)
 {
 	struct pv_list *pvl;
-	int consistent = 1;
 	uint64_t size = 0;
 	uint32_t new_pe_count = 0;
 	int r = 0;
@@ -59,19 +58,9 @@ static int _pv_resize_single(struct cmd_context *cmd,
 	} else {
 		vg_name = pv_vg_name(pv);
 
-		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
-			log_error("Can't get lock for %s", pv_vg_name(pv));
-			return 0;
-		}
-
-		if (!(vg = vg_read_internal(cmd, vg_name, NULL, &consistent))) {
-			unlock_vg(cmd, vg_name);
-			log_error("Unable to find volume group of \"%s\"",
-				  pv_name);
-			return 0;
-		}
+ 		vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 
-		if (!vg_check_status(vg, CLUSTERED | EXPORTED_VG | LVM_WRITE))
+		if (vg_read_error(vg))
 			goto bad;
 
 		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
diff --git a/tools/reporter.c b/tools/reporter.c
index d50d586..1e352b5 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -132,8 +132,8 @@ static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 	if (is_pv(pv) && !is_orphan(pv) && !vg) {
 		vg_name = pv_vg_name(pv);
 
-		if (!(vg = vg_lock_and_read(cmd, vg_name, (char *)&pv->vgid,
-					    LCK_VG_READ, CLUSTERED, 0))) {
+		vg = vg_read(cmd, vg_name, (char *)&pv->vgid, 0);
+		if (vg_read_error(vg)) {
 			log_error("Skipping volume group %s", vg_name);
 			return ECMD_FAILED;
 		}
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 4b2044c..aeb85ce 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -42,13 +42,12 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	log_verbose("Checking for volume group \"%s\"", vg_name);
-	if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_WRITE,
-				    CLUSTERED | EXPORTED_VG |
-				    LVM_WRITE | RESIZEABLE_VG,
-				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
-		unlock_vg(cmd, VG_ORPHANS);
+ 	vg = vg_read_for_update(cmd, vg_name, NULL,
+ 				READ_REQUIRE_RESIZEABLE | LOCK_NONBLOCKING);
+ 	if (vg_read_error(vg)) {
+ 		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
-	 }
+	}
 /********** FIXME
 	log_print("maximum logical volume size is %s",
 		  (dummy = lvm_show_size(LVM_LV_SIZE_MAX(vg) / 2, LONG)));
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index f507219..23b95a4 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -28,17 +28,15 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 	}
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_to);
-	if (!(vg_to = vg_lock_and_read(cmd, vg_name_to, NULL, LCK_VG_WRITE,
-				       CLUSTERED | EXPORTED_VG | LVM_WRITE,
-				       CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
+ 	vg_to = vg_read_for_update(cmd, vg_name_to, NULL, 0);
+ 	if (vg_read_error(vg_to))
 		 return ECMD_FAILED;
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_from);
-	if (!(vg_from = vg_lock_and_read(cmd, vg_name_from, NULL,
-					 LCK_VG_WRITE,
-					 CLUSTERED | EXPORTED_VG | LVM_WRITE,
-					 CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
-		unlock_and_release_vg(cmd, vg_to, vg_name_to);
+ 	vg_from = vg_read_for_update(cmd, vg_name_from, NULL,
+ 				     LOCK_NONBLOCKING);
+ 	if (vg_read_error(vg_from)) {
+		unlock_release_vg(cmd, vg_to, vg_name_to);
 		return ECMD_FAILED;
 	}
 
-- 
1.6.0.6


