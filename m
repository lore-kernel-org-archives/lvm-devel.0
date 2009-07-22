From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Jul 2009 15:52:26 -0400
Subject: [PATCH] Update vg_create to use lvm_errno and return NULL upon error.
Message-ID: <1248292346-14208-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We must update vgsplit and vgcreate at the same time or we break the
nightly tests.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   28 ++++++++++++++++------------
 tools/vgcreate.c        |    2 +-
 tools/vgsplit.c         |   11 ++++-------
 3 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 03e0810..f0a576d 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -597,10 +597,8 @@ int validate_vg_create_params(struct cmd_context *cmd,
 /*
  * Create a VG with default parameters.
  * Returns:
- * - vg_t* with SUCCESS code: VG structure created
- * - NULL or vg_t* with FAILED_* code: error creating VG structure
- * Use vg_read_error() to determine success or failure.
- * FIXME: cleanup usage of _vg_make_handle()
+ * - non-NULL vg_t*: VG structure created
+ * - NULL: error creating VG structure; use lvm_errno() for specific code
  */
 vg_t *vg_create(struct cmd_context *cmd, const char *vg_name)
 {
@@ -610,23 +608,29 @@ vg_t *vg_create(struct cmd_context *cmd, const char *vg_name)
 	uint32_t rc;
 
 	if (!validate_name(vg_name)) {
-		log_error("Invalid vg name %s", vg_name);
-		/* FIXME: use _vg_make_handle() w/proper error code */
+		log_errno(EINVAL, "Invalid vg name %s", vg_name);
 		return NULL;
 	}
 
 	rc = vg_lock_newname(cmd, vg_name);
-	if (rc != SUCCESS)
-		/* NOTE: let caller decide - this may be check for existence */
-		return _vg_make_handle(cmd, NULL, rc);
+	if (rc == FAILED_EXIST) {
+		log_errno(EEXIST, "A volume group called '%s' already exists.",
+			  vg_name);
+		return NULL;
+	}
+	if (rc == FAILED_LOCKING) {
+		log_error("Failed to lock vg name %s", vg_name);
+		return NULL;
+	}
 
 	/* FIXME: Is this vg_read_internal necessary? Move it inside
 	   vg_lock_newname? */
 	/* is this vg name already in use ? */
 	if ((vg = vg_read_internal(cmd, vg_name, NULL, &consistent))) {
-		log_error("A volume group called '%s' already exists.", vg_name);
+		log_errno(EEXIST, "A volume group called '%s' already exists.",
+			  vg_name);
 		unlock_and_release_vg(cmd, vg, vg_name);
-		return _vg_make_handle(cmd, NULL, FAILED_EXIST);
+		return NULL;
 	}
 
 	if (!(mem = dm_pool_create("lvm2 vg_create", VG_MEMPOOL_CHUNK)))
@@ -686,7 +690,7 @@ vg_t *vg_create(struct cmd_context *cmd, const char *vg_name)
 			  vg_name);
 		goto bad;
 	}
-	return _vg_make_handle(cmd, vg, SUCCESS);
+	return vg;
 
 bad:
 	unlock_and_release_vg(cmd, vg, vg_name);
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index c41c50f..d24c853 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -48,7 +48,7 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 
 	/* Create the new VG */
 	vg = vg_create(cmd, vp_new.vg_name);
-	if (vg_read_error(vg))
+	if (!vg)
 		goto_bad;
 
 	if (!vg_set_extent_size(vg, vp_new.extent_size) ||
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 35c425a..158a532 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -264,7 +264,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
 	/*
 	 * First try to create a new VG.  If we cannot create it,
-	 * and we get FAILED_EXIST (we will not be holding a lock),
+	 * and we get EEXIST (we will not be holding a lock),
 	 * a VG must already exist with this name.  We then try to
 	 * read the existing VG - the vgsplit will be into an existing VG.
 	 *
@@ -273,15 +273,12 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	 * system.  Thus, the split will be into a new VG.
 	 */
 	vg_to = vg_create(cmd, vg_name_to);
-	if (vg_read_error(vg_to) == FAILED_LOCKING) {
-		log_error("Can't get lock for %s", vg_name_to);
-		vg_release(vg_to);
+	if (!vg_to && stored_errno() != EXIST) {
 		unlock_and_release_vg(cmd, vg_from, vg_name_from);
 		return ECMD_FAILED;
 	}
-	if (vg_read_error(vg_to) == FAILED_EXIST) {
+	if (!vg_to && stored_errno() == EEXIST) {
 		existing_vg = 1;
-		vg_release(vg_to);
 		vg_to = vg_read_for_update(cmd, vg_name_to, NULL, 0);
 
 		if (vg_read_error(vg_to)) {
@@ -297,7 +294,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		}
 		if (!vgs_are_compatible(cmd, vg_from,vg_to))
 			goto_bad;
-	} else if (vg_read_error(vg_to) == SUCCESS) {
+	} else {
 		existing_vg = 0;
 
 		vp_def.vg_name = NULL;
-- 
1.6.0.6


