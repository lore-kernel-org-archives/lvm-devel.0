From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 21 Jul 2009 23:46:10 -0400
Subject: [PATCH] Change all liblvm2app API calls to return void and note use of lvm_errno.
Message-ID: <1248234370-12773-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Remove the return 'int' value for most of liblvm2app calls.  We now have
lvm_errno and lvm_errmsg.  Update test/api/vgtest.c

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/lvm.h      |   27 ++++++++-----------------
 liblvm/lvm_base.c |    5 ++-
 liblvm/lvm_vg.c   |   55 ++++++++++++++++++++++++++++------------------------
 test/api/vgtest.c |    9 +++----
 4 files changed, 46 insertions(+), 50 deletions(-)

diff --git a/liblvm/lvm.h b/liblvm/lvm.h
index e179d87..f2d0d93 100644
--- a/liblvm/lvm.h
+++ b/liblvm/lvm.h
@@ -69,7 +69,7 @@ void lvm_destroy(lvm_t libh);
  * \param   libh
  *          Handle obtained from lvm_create.
  */
-int lvm_reload_config(lvm_t libh);
+void lvm_reload_config(lvm_t libh);
 
 /**
  * Return stored error no describing last LVM API error.
@@ -110,8 +110,8 @@ const char *lvm_errmsg(lvm_t libh);
  * \param   libh
  *          Handle obtained from lvm_create.
  *
- * \return  A VG handle with error code set appropriately.
- * FIXME: Update error handling description after errno and logging patches
+ * \return  A VG handle or NULL upon failure.  Use lvm_errno() to verify
+ * success or failure and check the failure code.
  */
 vg_t *lvm_vg_create(lvm_t libh, const char *vg_name);
 
@@ -128,10 +128,8 @@ vg_t *lvm_vg_create(lvm_t libh, const char *vg_name);
  *
  * \param   device
  *          Name of device to add to VG.
- *
- * \return  Status code of 1 (success) or 0 (failure).
  */
-int lvm_vg_extend(vg_t *vg, const char *device);
+void lvm_vg_extend(vg_t *vg, const char *device);
 
 /**
  * Set the extent size of a VG.
@@ -146,10 +144,8 @@ int lvm_vg_extend(vg_t *vg, const char *device);
  *
  * \param   new_size
  *          New extent size to set (in sectors).
- *
- * \return  Status code of 1 (success) or 0 (failure).
  */
-int lvm_vg_set_extent_size(vg_t *vg, uint32_t new_size);
+void lvm_vg_set_extent_size(vg_t *vg, uint32_t new_size);
 
 /**
  * Write a VG to disk.
@@ -160,10 +156,8 @@ int lvm_vg_set_extent_size(vg_t *vg, uint32_t new_size);
  *
  * \param   vg
  *          VG handle obtained from lvm_vg_create.
- *
- * \return  Status code of 1 (success) or 0 (failure).
  */
-int lvm_vg_write(vg_t *vg);
+void lvm_vg_write(vg_t *vg);
 
 /**
  * Remove a VG from the system.
@@ -173,10 +167,8 @@ int lvm_vg_write(vg_t *vg);
  *
  * \param   vg
  *          VG handle obtained from lvm_vg_create.
- *
- * \return  Status code of 1 (success) or 0 (failure).
  */
-int lvm_vg_remove(vg_t *vg);
+void lvm_vg_remove(vg_t *vg);
 
 /**
  * Close a VG opened with lvm_vg_create
@@ -185,9 +177,8 @@ int lvm_vg_remove(vg_t *vg);
  *
  * \param   vg
  *          VG handle obtained from lvm_vg_create.
- *
- * \return  Status code of 1 (success) or 0 (failure).
+ * FIXME: note the handle can be obtained from vg_read once vg_read exported
  */
-int lvm_vg_close(vg_t *vg);
+void lvm_vg_close(vg_t *vg);
 
 #endif /* _LIB_LVM_H */
diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index 2414ed0..ab23279 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -65,10 +65,11 @@ void lvm_destroy(lvm_t libh)
 	destroy_toolcontext((struct cmd_context *)libh);
 }
 
-int lvm_reload_config(lvm_t libh)
+void lvm_reload_config(lvm_t libh)
 {
 	/* FIXME: re-init locking needed here? */
-	return refresh_toolcontext((struct cmd_context *)libh);
+	if (!refresh_toolcontext((struct cmd_context *)libh))
+		log_error("Error re-reading configuration\n");
 }
 
 int lvm_errno(lvm_t libh)
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index f434163..f3739cf 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -24,59 +24,64 @@ vg_t *lvm_vg_create(lvm_t libh, const char *vg_name)
 	return vg_create((struct cmd_context *)libh, vg_name);
 }
 
-int lvm_vg_extend(vg_t *vg, const char *device)
+void lvm_vg_extend(vg_t *vg, const char *device)
 {
-	if (vg_read_error(vg))
-		goto_bad;
+	if (vg_read_error(vg)) {
+		log_error("Invalid VG handle\n");
+		return;
+	}
 
-	return vg_extend(vg, 1, (char **) &device);
-bad:
-	return 0;
+	if (!vg_extend(vg, 1, (char **) &device))
+		log_error("Error extending device %s\n", device);
 }
 
-int lvm_vg_set_extent_size(vg_t *vg, uint32_t new_size)
+void lvm_vg_set_extent_size(vg_t *vg, uint32_t new_size)
 {
-	if (vg_read_error(vg))
-		goto_bad;
+	if (vg_read_error(vg)) {
+		log_error("Invalid VG handle\n");
+		return;
+	}
 
-	return vg_set_extent_size(vg, new_size);
-bad:
-	return 0;
+	if (!vg_set_extent_size(vg, new_size))
+		log_error("Error setting VG extent size\n");
 }
 
-int lvm_vg_write(vg_t *vg)
+void lvm_vg_write(vg_t *vg)
 {
-	if (vg_read_error(vg))
-		goto_bad;
+	if (vg_read_error(vg)) {
+		log_error("Invalid VG handle\n");
+		return;
+	}
 
 	if (!archive(vg)) {
+		log_error("Error archiving VG\n");
 		goto_bad;
 	}
 
 	/* Store VG on disk(s) */
 	if (!vg_write(vg) || !vg_commit(vg)) {
+		log_error("Error committing VG to disk\n");
 		goto_bad;
 	}
-	return 1;
 bad:
-	return 0;
+	return;
 }
 
-int lvm_vg_close(vg_t *vg)
+void lvm_vg_close(vg_t *vg)
 {
 	if (vg_read_error(vg) == FAILED_LOCKING)
 		vg_release(vg);
 	else
 		unlock_and_release_vg(vg->cmd, vg, vg->name);
-	return 1;
 }
 
-int lvm_vg_remove(vg_t *vg)
+void lvm_vg_remove(vg_t *vg)
 {
-	if (vg_read_error(vg))
-		goto_bad;
+	if (vg_read_error(vg)) {
+		log_error("Invalid VG handle\n");
+		return;
+	}
 
-	return vg_remove_single(vg);
-bad:
-	return 0;
+	if (!vg_remove_single(vg))
+		log_error("Error removing VG\n");
 }
diff --git a/test/api/vgtest.c b/test/api/vgtest.c
index 5d9e4fc..c0f0b9c 100644
--- a/test/api/vgtest.c
+++ b/test/api/vgtest.c
@@ -30,7 +30,6 @@ uint64_t size = 1024;
 
 int main(int argc, char *argv[])
 {
-	int status;
 
 	/* FIXME: input vgname, etc from cmdline */
 	/* FIXME: make the below messages verbose-only and print PASS/FAIL*/
@@ -50,7 +49,7 @@ int main(int argc, char *argv[])
 	}
 
 	printf("Extending VG %s\n", vg_name);
-	status = lvm_vg_extend(vg, device);
+	lvm_vg_extend(vg, device);
 	if (lvm_errno(handle)) {
 		fprintf(stderr, "Error extending volume group %s "
 			"with device %s\n", vg_name, device);
@@ -59,7 +58,7 @@ int main(int argc, char *argv[])
 	}
 
 	printf("Setting VG %s extent_size to %"PRIu64"\n", vg_name, size);
-	status = lvm_vg_set_extent_size(vg, size);
+	lvm_vg_set_extent_size(vg, size);
 	if (lvm_errno(handle)) {
 		fprintf(stderr, "Can not set physical extent "
 			"size '%"PRIu64"' for '%s'\n",
@@ -69,7 +68,7 @@ int main(int argc, char *argv[])
 	}
 
 	printf("Committing VG %s to disk\n", vg_name);
-	status = lvm_vg_write(vg);
+	lvm_vg_write(vg);
 	if (lvm_errno(handle)) {
 		fprintf(stderr, "Creation of volume group '%s' on "
 			"device '%s' failed\n",
@@ -79,7 +78,7 @@ int main(int argc, char *argv[])
 	}
 
 	printf("Removing VG %s from system\n", vg_name);
-	status = lvm_vg_remove(vg);
+	lvm_vg_remove(vg);
 	if (lvm_errno(handle)) {
 		fprintf(stderr, "Revmoval of volume group '%s' failed\n",
 			vg_name);
-- 
1.6.0.6


