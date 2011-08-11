From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Aug 2011 16:31:41 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20110811163141.24464.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-08-11 16:31:41

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Fix possible format instance memory leaks and premature releases in _vg_read.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2063&r2=1.2064
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.462&r2=1.463

--- LVM2/WHATS_NEW	2011/08/11 15:27:46	1.2063
+++ LVM2/WHATS_NEW	2011/08/11 16:31:40	1.2064
@@ -1,5 +1,6 @@
 Version 2.02.87 - 
 ===============================
+  Fix possible format instance memory leaks and premature releases in _vg_read.
   Suppress locking error messages in monitoring init scripts.
   If pipe in clvmd fails, return busy instead of using uninitialised descriptors.
   Add dmeventd monitoring shared library for RAID.
--- LVM2/lib/metadata/metadata.c	2011/08/10 20:25:30	1.462
+++ LVM2/lib/metadata/metadata.c	2011/08/11 16:31:40	1.463
@@ -2768,6 +2768,14 @@
 		pvl->pv->fid->fmt->ops->destroy_instance(pvl->pv->fid);
 }
 
+static void _destroy_fid(struct format_instance **fid)
+{
+	if (*fid) {
+		(*fid)->fmt->ops->destroy_instance(*fid);
+		*fid = NULL;
+	}
+}
+
 int vg_missing_pv_count(const struct volume_group *vg)
 {
 	int ret = 0;
@@ -2826,7 +2834,7 @@
 				     int warnings, 
 				     int *consistent, unsigned precommitted)
 {
-	struct format_instance *fid;
+	struct format_instance *fid = NULL;
 	struct format_instance_ctx fic;
 	const struct format_type *fmt;
 	struct volume_group *vg, *correct_vg = NULL;
@@ -2900,12 +2908,20 @@
 	}
 
 	/* Store pvids for later so we can check if any are missing */
-	if (!(pvids = lvmcache_get_pvids(cmd, vgname, vgid)))
+	if (!(pvids = lvmcache_get_pvids(cmd, vgname, vgid))) {
+		_destroy_fid(&fid);
 		return_NULL;
+	}
 
+	/*
+	 * We use the fid globally here so prevent the release_vg
+	 * call to destroy the fid - we may want to reuse it!
+	 */
+	fid->ref_count++;
 	/* Ensure contents of all metadata areas match - else do recovery */
 	inconsistent_mda_count=0;
 	dm_list_iterate_items(mda, &fid->metadata_areas_in_use) {
+
 		if ((use_precommitted &&
 		     !(vg = mda->ops->vg_read_precommit(fid, vgname, mda))) ||
 		    (!use_precommitted &&
@@ -2941,6 +2957,7 @@
 		if (vg != correct_vg)
 			release_vg(vg);
 	}
+	fid->ref_count--;
 
 	/* Ensure every PV in the VG was in the cache */
 	if (correct_vg) {
@@ -2972,8 +2989,10 @@
 				}
 				if (dm_list_size(&info->mdas)) {
 					if (!fid_add_mdas(fid, &info->mdas,
-							  info->dev->pvid, ID_LEN))
+							  info->dev->pvid, ID_LEN)) {
+						release_vg(correct_vg);
 						return_NULL;
+					}
 					 
 					log_debug("Empty mda found for VG %s.", vgname);
 
@@ -3002,11 +3021,14 @@
 				 */
 				lvmcache_update_vg(correct_vg, correct_vg->status & PRECOMMITTED);
 
-				if (!(pvids = lvmcache_get_pvids(cmd, vgname, vgid)))
+				if (!(pvids = lvmcache_get_pvids(cmd, vgname, vgid))) {
+					release_vg(correct_vg);
 					return_NULL;
+				}
 			}
 		}
 
+		fid->ref_count++;
 		if (dm_list_size(&correct_vg->pvs) !=
 		    dm_list_size(pvids) + vg_missing_pv_count(correct_vg)) {
 			log_debug("Cached VG %s had incorrect PV list",
@@ -3034,12 +3056,20 @@
 			release_vg(correct_vg);
 			correct_vg = NULL;
 		}
+		fid->ref_count--;
 	}
 
 	dm_list_init(&all_pvs);
 
 	/* Failed to find VG where we expected it - full scan and retry */
 	if (!correct_vg) {
+		/*
+		 * Free outstanding format instance that remained unassigned
+		 * from previous step where we tried to get the "correct_vg",
+		 * but we failed to do so (so there's a dangling fid now).
+		 */
+		_destroy_fid(&fid);
+
 		inconsistent = 0;
 
 		/* Independent MDAs aren't supported under low memory */
@@ -3061,6 +3091,11 @@
 			return NULL;
 		}
 
+		/*
+		 * We use the fid globally here so prevent the release_vg
+		 * call to destroy the fid - we may want to reuse it!
+		*/
+		fid->ref_count++;
 		/* Ensure contents of all metadata areas match - else recover */
 		inconsistent_mda_count=0;
 		dm_list_iterate_items(mda, &fid->metadata_areas_in_use) {
@@ -3076,6 +3111,7 @@
 				correct_vg = vg;
 				if (!_update_pv_list(cmd->mem, &all_pvs, correct_vg)) {
 					_free_pv_list(&all_pvs);
+					fid->ref_count--;
 					release_vg(vg);
 					return_NULL;
 				}
@@ -3099,6 +3135,7 @@
 
 				if (!_update_pv_list(cmd->mem, &all_pvs, vg)) {
 					_free_pv_list(&all_pvs);
+					fid->ref_count--;
 					release_vg(vg);
 					release_vg(correct_vg);
 					return_NULL;
@@ -3115,10 +3152,12 @@
 			if (vg != correct_vg)
 				release_vg(vg);
 		}
+		fid->ref_count--;
 
 		/* Give up looking */
 		if (!correct_vg) {
 			_free_pv_list(&all_pvs);
+			_destroy_fid(&fid);
 			return_NULL;
 		}
 	}


