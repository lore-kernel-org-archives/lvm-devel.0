From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 28 Feb 2011 13:19:04 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/format-text.c ...
Message-ID: <20110228131904.31109.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-02-28 13:19:03

Modified files:
	.              : WHATS_NEW 
	lib/format_text: format-text.c 
	lib/metadata   : metadata-exported.h metadata.c metadata.h 
	tools          : pvchange.c pvresize.c vgconvert.c vgreduce.c 

Log message:
	Allow non-orphan PVs with two metadata areas to be resized.
	
	We allow writing non-orphan PVs only for resize now. The "orphan PV" assert
	in pv_write fn uses the "allow_non_orphan" parameter to control this assert.
	However, we should find a more elaborate solution so we can remove this
	restriction altogether (pv_write together with vg_write is not atomic, we
	need to find a safe mechanism so there's an easy revert possible in case of
	an error).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1928&r2=1.1929
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.169&r2=1.170
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.183&r2=1.184
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.436&r2=1.437
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.239&r2=1.240
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.107&r2=1.108

--- LVM2/WHATS_NEW	2011/02/27 01:16:52	1.1928
+++ LVM2/WHATS_NEW	2011/02/28 13:19:02	1.1929
@@ -5,8 +5,8 @@
   Improve normal allocation algorithm to include clinging to existing areas.
   Add allocation/maximise_cling & mirror_logs_require_separate_pvs to lvm.conf.
   Fix metadata balance code to work with recent changes in metadata handling.
-  Add old_uuid field to physical_volume and fix pvchange -u for recent changes.
-  Allow pvresize on a PV with two metadata areas (for PVs not in a VG).
+  Add old_id field to physical_volume and fix pvchange -u for recent changes.
+  Allow pvresize on a PV with two metadata areas.
   Change pvcreate to use new metadata handling interface.
   Restructure existing pv_setup and pv_write fn, add pv_initialise fn.
   Add internal interface to support adding and removing metadata areas.
--- LVM2/lib/format_text/format-text.c	2011/02/25 14:08:55	1.169
+++ LVM2/lib/format_text/format-text.c	2011/02/28 13:19:02	1.170
@@ -1273,7 +1273,8 @@
 
 	/* Add a new cache entry with PV info or update existing one. */
 	if (!(info = lvmcache_add(fmt->labeller, (const char *) &pv->id,
-			pv->dev, FMT_TEXT_ORPHAN_VG_NAME, NULL, 0)))
+		      pv->dev, pv->vg ? pv->vg->name : FMT_TEXT_ORPHAN_VG_NAME,
+		      NULL, 0)))
 		return_0;
 
 	label = info->label;
@@ -2161,17 +2162,6 @@
 	/* If there's an mda at the end, move it to a new position. */
 	if ((mda = fid_get_mda_indexed(fid, pvid, ID_LEN, 1)) &&
 	    (mdac = mda->metadata_locn)) {
-		/*
-		 * FIXME: Remove this restriction - we need to
-		 *        allow writing PV labels on non-orphan VGs
-		 *        for this to work correctly.
-		 */
-		if (vg) {
-			log_error("Resizing a PV with two metadata areas "
-				  "that is part of a VG is not supported.");
-			return 0;
-		}
-
 		/* FIXME: Maybe MDA0 size would be better? */
 		mda_size = mdac->area.size >> SECTOR_SHIFT;
 		mda_ignored = mda_is_ignored(mda);
--- LVM2/lib/metadata/metadata-exported.h	2011/02/25 14:02:54	1.183
+++ LVM2/lib/metadata/metadata-exported.h	2011/02/28 13:19:02	1.184
@@ -384,7 +384,7 @@
 struct dm_list *get_vgids(struct cmd_context *cmd, int include_internal);
 int scan_vgs_for_pvs(struct cmd_context *cmd, int warnings);
 
-int pv_write(struct cmd_context *cmd, struct physical_volume *pv);
+int pv_write(struct cmd_context *cmd, struct physical_volume *pv, int allow_non_orphan);
 int move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
 	    const char *pv_name);
 int move_pvs_used_by_lv(struct volume_group *vg_from,
--- LVM2/lib/metadata/metadata.c	2011/02/25 14:08:55	1.436
+++ LVM2/lib/metadata/metadata.c	2011/02/28 13:19:02	1.437
@@ -586,7 +586,7 @@
 		}
 
 		/* FIXME Write to same sector label was read from */
-		if (!pv_write(vg->cmd, pv)) {
+		if (!pv_write(vg->cmd, pv, 0)) {
 			log_error("Failed to remove physical volume \"%s\""
 				  " from volume group \"%s\"",
 				  pv_dev_name(pv), vg->name);
@@ -1511,7 +1511,7 @@
 	log_very_verbose("Writing physical volume data to disk \"%s\"",
 			 pv_name);
 
-	if (!(pv_write(cmd, pv))) {
+	if (!(pv_write(cmd, pv, 0))) {
 		log_error("Failed to write physical volume \"%s\"", pv_name);
 		goto error;
 	}
@@ -3536,7 +3536,7 @@
 }
 
 int pv_write(struct cmd_context *cmd __attribute__((unused)),
-	     struct physical_volume *pv)
+	     struct physical_volume *pv, int allow_non_orphan)
 {
 	if (!pv->fmt->ops->pv_write) {
 		log_error("Format does not support writing physical volumes");
@@ -3549,7 +3549,8 @@
 	 *        to provide some revert mechanism since PV label together
 	 *        with VG metadata write is not atomic.
 	 */
-	if (!is_orphan_vg(pv->vg_name) || pv->pe_alloc_count) {
+	if (!allow_non_orphan &&
+	    (!is_orphan_vg(pv->vg_name) || pv->pe_alloc_count)) {
 		log_error("Assertion failed: can't _pv_write non-orphan PV "
 			  "(in VG %s)", pv->vg_name);
 		return 0;
@@ -3574,7 +3575,7 @@
 		return 0;
 	}
 
-	if (!pv_write(cmd, pv)) {
+	if (!pv_write(cmd, pv, 0)) {
 		log_error("Failed to clear metadata from physical "
 			  "volume \"%s\" after removal from \"%s\"",
 			  pv_dev_name(pv), old_vg_name);
--- LVM2/lib/metadata/metadata.h	2011/02/21 12:27:26	1.239
+++ LVM2/lib/metadata/metadata.h	2011/02/28 13:19:02	1.240
@@ -192,6 +192,7 @@
 void mda_set_ignored(struct metadata_area *mda, unsigned ignored);
 unsigned mda_locns_match(struct metadata_area *mda1, struct metadata_area *mda2);
 void vg_set_fid(struct volume_group *vg, struct format_instance *fid);
+/* FIXME: Add generic interface for mda counts based on given key. */
 int fid_add_mda(struct format_instance *fid, struct metadata_area *mda,
 		const char *key, size_t key_len, const unsigned sub_key);
 int fid_add_mdas(struct format_instance *fid, struct dm_list *mdas,
--- LVM2/tools/pvchange.c	2011/02/21 12:31:28	1.90
+++ LVM2/tools/pvchange.c	2011/02/28 13:19:03	1.91
@@ -140,7 +140,7 @@
 
 			pv->vg_name = pv->fmt->orphan_vg_name;
 			pv->pe_alloc_count = 0;
-			if (!(pv_write(cmd, pv))) {
+			if (!(pv_write(cmd, pv, 0))) {
 				log_error("pv_write with new uuid failed "
 					  "for %s.", pv_name);
 				return 0;
@@ -162,7 +162,7 @@
 			return 0;
 		}
 		backup(vg);
-	} else if (!(pv_write(cmd, pv))) {
+	} else if (!(pv_write(cmd, pv, 0))) {
 		log_error("Failed to store physical volume \"%s\"",
 			  pv_name);
 		return 0;
--- LVM2/tools/pvresize.c	2011/02/21 12:27:26	1.41
+++ LVM2/tools/pvresize.c	2011/02/28 13:19:03	1.42
@@ -15,6 +15,7 @@
  */
 
 #include "tools.h"
+#include "metadata.h"
 
 struct pvresize_params {
 	uint64_t new_size;
@@ -96,6 +97,16 @@
 		goto_out;
 
 	log_verbose("Updating physical volume \"%s\"", pv_name);
+
+	/* Write PV label only if this an orphan PV or it has 2nd mda. */
+	if ((is_orphan_vg(vg_name) ||
+	    fid_get_mda_indexed(vg->fid, (const char *) &pv->id, ID_LEN, 1)) &&
+	    !pv_write(cmd, pv, 1)) {
+		log_error("Failed to store physical volume \"%s\"",
+			  pv_name);
+		goto out;
+	}
+
 	if (!is_orphan_vg(vg_name)) {
 		if (!vg_write(vg) || !vg_commit(vg)) {
 			log_error("Failed to store physical volume \"%s\" in "
@@ -103,10 +114,6 @@
 			goto out;
 		}
 		backup(vg);
-	} else if (!(pv_write(cmd, pv))) {
-		log_error("Failed to store physical volume \"%s\"",
-			  pv_name);
-		goto out;
 	}
 
 	log_print("Physical volume \"%s\" changed", pv_name);
--- LVM2/tools/vgconvert.c	2011/02/25 14:02:54	1.49
+++ LVM2/tools/vgconvert.c	2011/02/28 13:19:03	1.50
@@ -151,7 +151,7 @@
 
 		log_very_verbose("Writing physical volume data to disk \"%s\"",
 				 pv_dev_name(pv));
-		if (!(pv_write(cmd, pv))) {
+		if (!(pv_write(cmd, pv, 0))) {
 			log_error("Failed to write physical volume \"%s\"",
 				  pv_dev_name(pv));
 			log_error("Use pvcreate and vgcfgrestore to repair "
--- LVM2/tools/vgreduce.c	2011/02/21 12:26:28	1.107
+++ LVM2/tools/vgreduce.c	2011/02/28 13:19:03	1.108
@@ -438,7 +438,7 @@
 		goto bad;
 	}
 
-	if (!pv_write(cmd, pv)) {
+	if (!pv_write(cmd, pv, 0)) {
 		log_error("Failed to clear metadata from physical "
 			  "volume \"%s\" "
 			  "after removal from \"%s\"", name, vg->name);


