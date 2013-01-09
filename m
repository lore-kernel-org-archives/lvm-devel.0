From: Tony Asleson <tasleson@redhat.com>
Date: Tue,  8 Jan 2013 23:47:56 -0600
Subject: [PATCH] lvm2app: Implementation of pv resize (v5)
Message-ID: <1357710476-18432-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch correctly checks for update lock before allowing
resize to process and also requires lvm_vg_write to
make changes persistent.  As the API does not allow the
re-size of a orphaned pv this is accomplished through
the existing vg_write, vg_commit sequence which is done
in lvm_vg_write.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/metadata/metadata-exported.h |  8 +++++--
 lib/metadata/pv_manip.c          | 48 +++++++++++++++++++++++++++++++++++++++-
 liblvm/lvm2app.h                 |  5 +++--
 liblvm/lvm_pv.c                  | 21 ++++++++++++++----
 tools/pvresize.c                 | 36 +++++-------------------------
 5 files changed, 79 insertions(+), 39 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index ffec129..4af9edf 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -482,8 +482,12 @@ struct physical_volume *pv_create(const struct cmd_context *cmd,
 				  unsigned pvmetadatacopies,
 				  uint64_t pvmetadatasize,
 				  unsigned metadataignore);
-int pv_resize(struct physical_volume *pv, struct volume_group *vg,
-	      uint64_t size);
+
+int pv_resize(struct cmd_context *cmd,
+				struct volume_group *vg,
+				struct physical_volume *pv,
+				const uint64_t new_size);
+
 int pv_analyze(struct cmd_context *cmd, const char *pv_name,
 	       uint64_t label_sector);
 
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index d04ecab..4d37a6b 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -19,6 +19,7 @@
 #include "toolcontext.h"
 #include "locking.h"
 #include "defaults.h"
+#include "archiver.h"
 
 static struct pv_segment *_alloc_pv_segment(struct dm_pool *mem,
 					    struct physical_volume *pv,
@@ -485,7 +486,7 @@ static int _extend_pv(struct physical_volume *pv, struct volume_group *vg,
  * Resize a PV in a VG, adding or removing segments as needed.
  * New size must fit within pv->size.
  */
-int pv_resize(struct physical_volume *pv,
+static int _pv_resize(struct physical_volume *pv,
 	      struct volume_group *vg,
 	      uint64_t size)
 {
@@ -543,3 +544,48 @@ int pv_resize(struct physical_volume *pv,
 
 	return 1;
 }
+
+/*
+ * You need to have acquired the correct locks for vg or pv (if orphan) before
+ * calling this function.  vg can be NULL which implies orphan pv.
+ * Code to write changes out must be called after this to make persistent.
+ */
+int pv_resize(struct cmd_context *cmd,
+				struct volume_group *vg,
+				struct physical_volume *pv,
+				const uint64_t new_size)
+{
+	uint64_t size = 0;
+	int rc = 0;
+	const char *pv_name = pv_dev_name(pv);
+
+	if (!(pv->fmt->features & FMT_RESIZE_PV)) {
+		log_error("Physical volume %s format does not support resizing.",
+					pv_name);
+	} else {
+
+		/* Get new size */
+		if (!dev_get_size(pv_dev(pv), &size)) {
+			log_error("%s: Couldn't get size.", pv_name);
+		} else {
+
+			if (new_size) {
+				if (new_size > size)
+					log_warn("WARNING: %s: Overriding real size. "
+							"You could lose data.", pv_name);
+
+				log_verbose("%s: Pretending size is %" PRIu64 " not %"
+							PRIu64 " sectors.", pv_name, new_size, pv_size(pv));
+				size = new_size;
+			}
+
+			log_verbose("Resizing volume \"%s\" to %" PRIu64 " sectors.",
+					pv_name, pv_size(pv));
+
+			if (_pv_resize(pv, vg, size))
+				rc = 1;
+		}
+	}
+
+	return rc;
+}
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 93a78c3..00f92ab 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1624,9 +1624,10 @@ pv_t lvm_pv_from_uuid(vg_t vg, const char *uuid);
 /**
  * Resize physical volume to new_size bytes.
  *
- * \memberof pv_t
+ * Note: Make sure to do a lvm_vg_write on the containing vg to save the
+ * new size.
  *
- * NOTE: This function is currently not implemented.
+ * \memberof pv_t
  *
  * \param   pv
  * Physical volume handle.
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 90edaed..c12adf1 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -120,10 +120,23 @@ pv_t lvm_pv_from_uuid(vg_t vg, const char *uuid)
 	return NULL;
 }
 
-
 int lvm_pv_resize(const pv_t pv, uint64_t new_size)
 {
-	/* FIXME: add pv resize code here */
-	log_error("NOT IMPLEMENTED YET");
-	return -1;
+	uint64_t size = new_size >> SECTOR_SHIFT;
+
+	if (new_size % SECTOR_SIZE) {
+		log_errno(EINVAL, "Size not a multiple of 512");
+		return -1;
+	}
+
+	if (!vg_check_write_mode(pv->vg)) {
+		return -1;
+	}
+
+	if (!pv_resize(pv->vg->cmd, pv->vg, pv, size)) {
+		log_error("PV re-size failed!");
+		return -1;
+	} else {
+		return 0;
+	}
 }
diff --git a/tools/pvresize.c b/tools/pvresize.c
index 2f0693a..21980b3 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -30,7 +30,6 @@ static int _pv_resize_single(struct cmd_context *cmd,
 			     const uint64_t new_size)
 {
 	struct pv_list *pvl;
-	uint64_t size = 0;
 	int r = 0;
 	const char *pv_name = pv_dev_name(pv);
 	const char *vg_name = pv_vg_name(pv);
@@ -61,41 +60,18 @@ static int _pv_resize_single(struct cmd_context *cmd,
 		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
 			log_error("Unable to find \"%s\" in volume group \"%s\"",
 				  pv_name, vg->name);
-			goto out;
+			goto_out;
 		}
 
 		pv = pvl->pv;
 
 		if (!archive(vg))
-			goto out;
+			goto_out;
 	}
 
-	if (!(pv->fmt->features & FMT_RESIZE_PV)) {
-		log_error("Physical volume %s format does not support resizing.",
-			  pv_name);
-		goto out;
-	}
-
-	/* Get new size */
-	if (!dev_get_size(pv_dev(pv), &size)) {
-		log_error("%s: Couldn't get size.", pv_name);
-		goto out;
-	}
-
-	if (new_size) {
-		if (new_size > size)
-			log_warn("WARNING: %s: Overriding real size. "
-				  "You could lose data.", pv_name);
-		log_verbose("%s: Pretending size is %" PRIu64 " not %" PRIu64
-			    " sectors.", pv_name, new_size, pv_size(pv));
-		size = new_size;
-	}
-
-	log_verbose("Resizing volume \"%s\" to %" PRIu64 " sectors.",
-		    pv_name, pv_size(pv));
-
-	if (!pv_resize(pv, vg, size))
+	if( !pv_resize(cmd, vg, pv, new_size)) {
 		goto_out;
+	}
 
 	log_verbose("Updating physical volume \"%s\"", pv_name);
 
@@ -106,14 +82,14 @@ static int _pv_resize_single(struct cmd_context *cmd,
 	    !pv_write(cmd, pv, 1)) {
 		log_error("Failed to store physical volume \"%s\"",
 			  pv_name);
-		goto out;
+		goto_out;
 	}
 
 	if (!is_orphan_vg(vg_name)) {
 		if (!vg_write(vg) || !vg_commit(vg)) {
 			log_error("Failed to store physical volume \"%s\" in "
 				  "volume group \"%s\"", pv_name, vg_name);
-			goto out;
+			goto_out;
 		}
 		backup(vg);
 	}
-- 
1.7.11.7


