From: tasleson <tasleson@fedoraproject.org>
Date: Tue,  2 Jul 2013 19:26:44 +0000 (UTC)
Subject: master - liblvm: Moved additional pv resize code
Message-ID: <20130702192644.7066160FB8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=50db109e2068d8d5645bd4117b6022acf4b7f8ba
Commit:        50db109e2068d8d5645bd4117b6022acf4b7f8ba
Parent:        40feaa7bbeaca9a89f9b8e87b684c457cd10aa57
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Jun 28 17:25:28 2013 -0400
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jul 2 14:24:34 2013 -0500

liblvm: Moved additional pv resize code

The pv resize code required that a lvm_vg_write be done
to commit the change.  When the method to add the ability
to list all PVs, including ones that are not assocated with
a VG we had no way for the user to make the change persistent.
Thus additional resize code was move and now liblvm calls into
a resize function that does indeed write the changes out, thus
not requiring the user to explicitly write out he changes.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/metadata/metadata-exported.h |    8 ++-
 lib/metadata/metadata.c          |    5 ++
 lib/metadata/pv_manip.c          |  115 +++++++++++++++++++++++++++++++++++++-
 liblvm/lvm_pv.c                  |    2 +-
 tools/pvresize.c                 |  112 +------------------------------------
 5 files changed, 127 insertions(+), 115 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 7743c47..d6c6acb 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -560,8 +560,12 @@ struct physical_volume *pv_create(const struct cmd_context *cmd,
 				  uint64_t pvmetadatasize,
 				  unsigned metadataignore,
 				  struct pvcreate_restorable_params *rp);
-int pv_resize(struct physical_volume *pv, struct volume_group *vg,
-	      uint64_t size);
+
+int pv_resize_single(struct cmd_context *cmd,
+			     struct volume_group *vg,
+			     struct physical_volume *pv,
+			     const uint64_t new_size);
+
 int pv_analyze(struct cmd_context *cmd, const char *pv_name,
 	       uint64_t label_sector);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index e594f7c..2d3f5ec 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3755,6 +3755,11 @@ static int _get_pvs(struct cmd_context *cmd, int warnings,
 				 */
 				if (!vgslist) {
 					pvl_copy->pv->vg = NULL;
+				} else {
+					/* Make sure the vg mode indicates writeable */
+					/* We should rework this function to take a parameter */
+					/* so that we could control this ... */
+					pvl_copy->pv->vg->open_mode = 'w';
 				}
 				have_pv = 1;
 				dm_list_add(pvslist, &pvl_copy->list);
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 3ec20ef..5ab2d24 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -22,6 +22,7 @@
 #include "lvmetad.h"
 #include "display.h"
 #include "label.h"
+#include "../../tools/tools.h"
 
 static struct pv_segment *_alloc_pv_segment(struct dm_pool *mem,
 					    struct physical_volume *pv,
@@ -487,7 +488,7 @@ static int _extend_pv(struct physical_volume *pv, struct volume_group *vg,
  * Resize a PV in a VG, adding or removing segments as needed.
  * New size must fit within pv->size.
  */
-int pv_resize(struct physical_volume *pv,
+static int pv_resize(struct physical_volume *pv,
 	      struct volume_group *vg,
 	      uint64_t size)
 {
@@ -516,7 +517,8 @@ int pv_resize(struct physical_volume *pv,
 	/* pv->pe_count is 0 now! We need to recalculate! */
 
 	/* If there's a VG, calculate new PE count value. */
-	if (vg) {
+	/* Don't do for orphan VG */
+	if (vg && !is_orphan_vg(vg->name)) {
 		/* FIXME: Maybe PE calculation should go into pv->fmt->resize?
 		          (like it is for pv->fmt->setup) */
 		if (!(new_pe_count = pv_size(pv) / vg->extent_size)) {
@@ -546,6 +548,115 @@ int pv_resize(struct physical_volume *pv,
 	return 1;
 }
 
+int pv_resize_single(struct cmd_context *cmd,
+			     struct volume_group *vg,
+			     struct physical_volume *pv,
+			     const uint64_t new_size)
+{
+	struct pv_list *pvl;
+	uint64_t size = 0;
+	int r = 0;
+	const char *pv_name = pv_dev_name(pv);
+	const char *vg_name = pv_vg_name(pv);
+	struct volume_group *old_vg = vg;
+	int vg_needs_pv_write = 0;
+
+	if (is_orphan_vg(vg_name)) {
+		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE, NULL)) {
+			log_error("Can't get lock for orphans");
+			return 0;
+		}
+
+		if (!(pv = pv_read(cmd, pv_name, 1, 0))) {
+			unlock_vg(cmd, vg_name);
+			log_error("Unable to read PV \"%s\"", pv_name);
+			return 0;
+		}
+	} else {
+		vg = vg_read_for_update(cmd, vg_name, NULL, 0);
+
+		if (vg_read_error(vg)) {
+			release_vg(vg);
+			log_error("Unable to read volume group \"%s\".",
+				  vg_name);
+			return 0;
+		}
+
+		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
+			log_error("Unable to find \"%s\" in volume group \"%s\"",
+				  pv_name, vg->name);
+			goto out;
+		}
+
+		pv = pvl->pv;
+
+		if (!archive(vg))
+			goto out;
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
+	if (!pv_resize(pv, vg, size))
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
+	unlock_vg(cmd, vg_name);
+	if (is_orphan_vg(vg_name))
+		free_pv_fid(pv);
+	if (!old_vg)
+		release_vg(vg);
+	return r;
+}
+
 const char _really_wipe[] =
     "Really WIPE LABELS from physical volume \"%s\" of volume group \"%s\" [y/n]? ";
 
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 9069f6f..8915e7c 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -219,7 +219,7 @@ int lvm_pv_resize(const pv_t pv, uint64_t new_size)
 		return -1;
 	}
 
-	if (!pv_resize(pv, pv->vg, size)) {
+	if (!pv_resize_single(pv->vg->cmd, pv->vg, pv, size)) {
 		log_error("PV re-size failed!");
 		return -1;
 	} else {
diff --git a/tools/pvresize.c b/tools/pvresize.c
index 251cf9a..a5f81f8 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -16,6 +16,7 @@
 
 #include "tools.h"
 #include "metadata.h"
+#include "metadata-exported.h"
 
 struct pvresize_params {
 	uint64_t new_size;
@@ -24,115 +25,6 @@ struct pvresize_params {
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
-		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE, NULL)) {
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
@@ -142,7 +34,7 @@ static int _pvresize_single(struct cmd_context *cmd,
 
 	params->total++;
 
-	if (!_pv_resize_single(cmd, vg, pv, params->new_size))
+	if (!pv_resize_single(cmd, vg, pv, params->new_size))
 		return_ECMD_FAILED;
 
 	params->done++;


