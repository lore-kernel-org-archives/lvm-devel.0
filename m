From: Tony Asleson <tasleson@redhat.com>
Date: Tue, 16 Oct 2012 14:12:25 -0500
Subject: [PATCH] lvm2app: Possible implementation of missing pv resize (v2).
Message-ID: <1350414745-11420-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch implements pv resize and it appears to work in my
simple testing.  I would appreciate others who know the code
better to review and make suggestions.

Thanks,
-Tony

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/metadata/metadata-exported.h |   8 ++-
 lib/metadata/pv_manip.c          | 118 ++++++++++++++++++++++++++++++++++++++-
 liblvm/lvm_pv.c                  |  17 ++++--
 tools/pvresize.c                 | 113 +------------------------------------
 4 files changed, 138 insertions(+), 118 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index d149f95..cf38d9e 100644
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
index d04ecab..e4b5a66 100644
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
@@ -543,3 +544,118 @@ int pv_resize(struct physical_volume *pv,
 
 	return 1;
 }
+
+int pv_resize(struct cmd_context *cmd,
+				struct volume_group *vg,
+				struct physical_volume *pv,
+				const uint64_t new_size)
+{
+	struct pv_list *pvl;
+	uint64_t size = 0;
+	int r = 0;
+	const char *pv_name = pv_dev_name(pv);
+	const char *vg_name = pv_vg_name(pv);
+	struct volume_group *old_vg = vg;
+	int vg_needs_pv_write = 0;
+
+	/* If we are passed a vg we are assuming the caller has the appropriate locks */
+	if (!old_vg) {
+		if (is_orphan_vg(vg_name)) {
+			if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
+				log_error("Can't get lock for orphans");
+				return 0;
+			}
+
+			if (!(pv = pv_read(cmd, pv_name, 1, 0))) {
+				unlock_vg(cmd, vg_name);
+				log_error("Unable to read PV \"%s\"", pv_name);
+				return 0;
+			}
+		} else {
+			vg = vg_read_for_update(cmd, vg_name, NULL, 0);
+
+			if (vg_read_error(vg)) {
+				release_vg(vg);
+				log_error("Unable to read volume group \"%s\".",
+					vg_name);
+				return 0;
+			}
+
+			if (!(pvl = find_pv_in_vg(vg, pv_name))) {
+				log_error("Unable to find \"%s\" in volume group \"%s\"",
+					pv_name, vg->name);
+				goto out;
+			}
+
+			pv = pvl->pv;
+
+			if (!archive(vg))
+				goto out;
+		}
+	}
+
+	if (!(pv->fmt->features & FMT_RESIZE_PV)) {
+		log_error("Physical volume %s format does not support resizing.",
+			  pv_name);
+		goto out;
+	}
+
+	/* Get new size */
+	if (!dev_get_size(pv_dev(pv), &size)) {
+		log_error("%s: Couldn't get size.", pv_name);
+		goto out;
+	}
+
+	if (new_size) {
+		if (new_size > size)
+			log_warn("WARNING: %s: Overriding real size. "
+				  "You could lose data.", pv_name);
+		log_verbose("%s: Pretending size is %" PRIu64 " not %" PRIu64
+			    " sectors.", pv_name, new_size, pv_size(pv));
+		size = new_size;
+	}
+
+	log_verbose("Resizing volume \"%s\" to %" PRIu64 " sectors.",
+		    pv_name, pv_size(pv));
+
+	if (!_pv_resize(pv, vg, size))
+		goto_out;
+
+	log_verbose("Updating physical volume \"%s\"", pv_name);
+
+	/* Write PV label only if this an orphan PV or it has 2nd mda. */
+	if ((is_orphan_vg(vg_name) ||
+	     (vg_needs_pv_write = (fid_get_mda_indexed(vg->fid,
+			(const char *) &pv->id, ID_LEN, 1) != NULL))) &&
+	    !pv_write(cmd, pv, 1)) {
+		log_error("Failed to store physical volume \"%s\"",
+			  pv_name);
+		goto out;
+	}
+
+	if (!is_orphan_vg(vg_name)) {
+		if (!vg_write(vg) || !vg_commit(vg)) {
+			log_error("Failed to store physical volume \"%s\" in "
+				  "volume group \"%s\"", pv_name, vg_name);
+			goto out;
+		}
+		backup(vg);
+	}
+
+	log_print_unless_silent("Physical volume \"%s\" changed", pv_name);
+	r = 1;
+
+out:
+	if (!r && vg_needs_pv_write)
+		log_error("Use pvcreate and vgcfgrestore "
+			  "to repair from archived metadata.");
+
+	if (!old_vg) {
+		unlock_vg(cmd, vg_name);
+		if (is_orphan_vg(vg_name))
+			free_pv_fid(pv);
+
+		release_vg(vg);
+	}
+	return r;
+}
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 90edaed..446051a 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -120,10 +120,19 @@ pv_t lvm_pv_from_uuid(vg_t vg, const char *uuid)
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
+	if (!pv_resize(pv->vg->cmd, pv->vg, pv, size)) {
+		log_error("PV re-size failed!");
+		return -1;
+	} else {
+		return 0;
+	}
 }
diff --git a/tools/pvresize.c b/tools/pvresize.c
index 2f0693a..0b53ffb 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -24,115 +24,6 @@ struct pvresize_params {
 	unsigned total;
 };
 
-static int _pv_resize_single(struct cmd_context *cmd,
-			     struct volume_group *vg,
-			     struct physical_volume *pv,
-			     const uint64_t new_size)
-{
-	struct pv_list *pvl;
-	uint64_t size = 0;
-	int r = 0;
-	const char *pv_name = pv_dev_name(pv);
-	const char *vg_name = pv_vg_name(pv);
-	struct volume_group *old_vg = vg;
-	int vg_needs_pv_write = 0;
-
-	if (is_orphan_vg(vg_name)) {
-		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
-			log_error("Can't get lock for orphans");
-			return 0;
-		}
-
-		if (!(pv = pv_read(cmd, pv_name, 1, 0))) {
-			unlock_vg(cmd, vg_name);
-			log_error("Unable to read PV \"%s\"", pv_name);
-			return 0;
-		}
-	} else {
-		vg = vg_read_for_update(cmd, vg_name, NULL, 0);
-
-		if (vg_read_error(vg)) {
-			release_vg(vg);
-			log_error("Unable to read volume group \"%s\".",
-				  vg_name);
-			return 0;
-		}
-
-		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
-			log_error("Unable to find \"%s\" in volume group \"%s\"",
-				  pv_name, vg->name);
-			goto out;
-		}
-
-		pv = pvl->pv;
-
-		if (!archive(vg))
-			goto out;
-	}
-
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
-		goto_out;
-
-	log_verbose("Updating physical volume \"%s\"", pv_name);
-
-	/* Write PV label only if this an orphan PV or it has 2nd mda. */
-	if ((is_orphan_vg(vg_name) ||
-	     (vg_needs_pv_write = (fid_get_mda_indexed(vg->fid,
-			(const char *) &pv->id, ID_LEN, 1) != NULL))) &&
-	    !pv_write(cmd, pv, 1)) {
-		log_error("Failed to store physical volume \"%s\"",
-			  pv_name);
-		goto out;
-	}
-
-	if (!is_orphan_vg(vg_name)) {
-		if (!vg_write(vg) || !vg_commit(vg)) {
-			log_error("Failed to store physical volume \"%s\" in "
-				  "volume group \"%s\"", pv_name, vg_name);
-			goto out;
-		}
-		backup(vg);
-	}
-
-	log_print_unless_silent("Physical volume \"%s\" changed", pv_name);
-	r = 1;
-
-out:
-	if (!r && vg_needs_pv_write)
-		log_error("Use pvcreate and vgcfgrestore "
-			  "to repair from archived metadata.");
-	unlock_vg(cmd, vg_name);
-	if (is_orphan_vg(vg_name))
-		free_pv_fid(pv);
-	if (!old_vg)
-		release_vg(vg);
-	return r;
-}
-
 static int _pvresize_single(struct cmd_context *cmd,
 			    struct volume_group *vg,
 			    struct physical_volume *pv,
@@ -142,11 +33,11 @@ static int _pvresize_single(struct cmd_context *cmd,
 
 	params->total++;
 
-	if (!_pv_resize_single(cmd, vg, pv, params->new_size)) {
+	if (!pv_resize(cmd, vg, pv, params->new_size)) {
 		stack;
 		return ECMD_FAILED;
 	}
-	
+
 	params->done++;
 
 	return ECMD_PROCESSED;
-- 
1.7.11.7


