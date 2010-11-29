From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Nov 2010 18:35:38 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM lib/metadata/m ...
Message-ID: <20101129183538.23978.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-11-29 18:35:37

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	lib/metadata   : metadata.c 
	lib/format_text: import_vsn1.c 

Log message:
	Fix memory leak when VG allocation policy in metadata is invalid.
	Ignore unrecognised allocation policy found in metadata instead of aborting.
	Fix another missing vg_release() in _vg_read_by_vgid.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1813&r2=1.1814
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.426&r2=1.427
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.411&r2=1.412
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78

--- LVM2/WHATS_NEW	2010/11/29 12:19:58	1.1813
+++ LVM2/WHATS_NEW	2010/11/29 18:35:37	1.1814
@@ -1,16 +1,22 @@
 Version 2.02.78 - 
 ====================================
-  Fix memory leak in outf macro error path of _print_vg/lv/pvs/segment().
-  Fix missing reset of vg pointer after vg_release() in _vg_read_by_vgid().
-  Fix test for empty system_dir string in _init_backup().
-  Certain lvconvert invocations are now required to be done in two steps.
-  Fix missing context desctruction in err path of lvm1 fallback in lvm2_main().
-  Fix memory leak in error path of parse_loop_device_name() from dmsetup.
-  Fix missing dlclose in _init_formats() error path from init_format call.
-  Fix missing fclose for _umount() in dmeventd snapshot plugin.
-  Fix out-of-scope variable usage in process_each_lv().
-  Fix dm_task_destroy(NULL) call in _node_clear_table() error path.
-  Fix resource leak in _rm_blks().
+  Fix memory leak when VG allocation policy in metadata is invalid.
+  Ignore unrecognised allocation policy found in metadata instead of aborting.
+  Factor out tag printing into _out_tags and avoid leaking string buffer.
+  Remove some unused variables & assignments.
+  Add missing vg_release calls in _vg_read_by_vgid.
+Still to fix: LCK_CACHE/CLUSTER_VG printing/FIXME
+  Fix test for no system_dir in _init_backup().
+  Disallow lvconvert ops that both allocate & free supplied PEs in a single cmd.
+  Fix liblvm seg_size to give bytes not sectors.
+  Add functions to look up LV/PV by name/uuid to liblvm.
+  Free cmd_context if fallback to LVM1 fails in lvm2_main().
+  Free device name buffer in dmsetup parse_loop_device_name() error paths.
+  Close format lib if init_format_fn fails in _init_formats().
+  Don't leave /proc/mounts open after dmeventd snapshot event processing.
+  Fix out-of-scope arg_vgnames use in process_each_lv().
+  Remove incorrect dm_task_destroy(NULL) from _node_clear_table() error path.
+  Add missing closedir in _rm_blks after removing stray LVM1 VG files.
   Suppress 'No PV label' message when removing several PVs without mdas.
   Fix default /etc/lvm permissions to be 0755. (2.02.66)
 
--- LVM2/WHATS_NEW_DM	2010/11/22 18:37:56	1.426
+++ LVM2/WHATS_NEW_DM	2010/11/29 18:35:37	1.427
@@ -1,5 +1,6 @@
 Version 1.02.59 - 
 ====================================
+  Remove superfluous checks for NULL before calling dm_free.
 
 Version 1.02.58 - 22nd November 2010
 ====================================
--- LVM2/lib/metadata/metadata.c	2010/11/29 11:08:14	1.411
+++ LVM2/lib/metadata/metadata.c	2010/11/29 18:35:37	1.412
@@ -3086,6 +3086,7 @@
 			  vg->name);
 
 	dm_pool_destroy(vg->vgmem);
+	vg->vgmem = NULL;
 }
 
 /* This is only called by lv_from_lvid, which is only called from
@@ -3098,7 +3099,7 @@
 {
 	const char *vgname;
 	struct dm_list *vgnames;
-	struct volume_group *vg = NULL;
+	struct volume_group *vg;
 	struct lvmcache_vginfo *vginfo;
 	struct str_list *strl;
 	int consistent = 0;
@@ -3109,20 +3110,17 @@
 		if ((vg = _vg_read(cmd, NULL, vgid, 1,
 				   &consistent, precommitted)) &&
 		    !strncmp((char *)vg->id.uuid, vgid, ID_LEN)) {
-
-			if (!consistent) {
+			if (!consistent)
 				log_error("Volume group %s metadata is "
 					  "inconsistent", vg->name);
-			}
 			return vg;
 		}
 		vg_release(vg);
-		vg = NULL; /* reset so memlock goto out is safe */
 	}
 
 	/* Mustn't scan if memory locked: ensure cache gets pre-populated! */
 	if (memlock())
-		goto out;
+		return_NULL;
 
 	/* FIXME Need a genuine read by ID here - don't vg_read_internal by name! */
 	/* FIXME Disabled vgrenames while active for now because we aren't
@@ -3132,7 +3130,7 @@
 	lvmcache_label_scan(cmd, 2);
 	if (!(vgnames = get_vgnames(cmd, 0))) {
 		log_error("vg_read_by_vgid: get_vgnames failed");
-		goto out;
+		return NULL;
 	}
 
 	dm_list_iterate_items(strl, vgnames) {
@@ -3143,18 +3141,17 @@
 		if ((vg = _vg_read(cmd, vgname, vgid, 1, &consistent,
 				   precommitted)) &&
 		    !strncmp((char *)vg->id.uuid, vgid, ID_LEN)) {
-
 			if (!consistent) {
 				log_error("Volume group %s metadata is "
 					  "inconsistent", vgname);
-				goto out;
+				vg_release(vg);
+				return NULL;
 			}
 			return vg;
 		}
+		vg_release(vg);
 	}
 
-out:
-	vg_release(vg);
 	return NULL;
 }
 
--- LVM2/lib/format_text/import_vsn1.c	2010/07/09 15:34:44	1.77
+++ LVM2/lib/format_text/import_vsn1.c	2010/11/29 18:35:37	1.78
@@ -529,8 +529,10 @@
 		}
 
 		lv->alloc = get_alloc_from_string(cv->v.str);
-		if (lv->alloc == ALLOC_INVALID)
-			return_0;
+		if (lv->alloc == ALLOC_INVALID) {
+			log_warn("WARNING: Ignoring unrecognised allocation policy %s for LV %s", cv->v.str, lv->name);
+			lv->alloc = ALLOC_INHERIT;
+		}
 	}
 
 	if (!_read_int32(lvn, "read_ahead", &lv->read_ahead))
@@ -660,7 +662,8 @@
 		return_NULL;
 
 	/* skip any top-level values */
-	for (vgn = cft->root; (vgn && vgn->v); vgn = vgn->sib) ;
+	for (vgn = cft->root; (vgn && vgn->v); vgn = vgn->sib)
+		;
 
 	if (!vgn) {
 		log_error("Couldn't find volume group in file.");
@@ -738,12 +741,14 @@
 		struct config_value *cv = cn->v;
 		if (!cv || !cv->v.str) {
 			log_error("allocation_policy must be a string.");
-			return 0;
+			goto bad;
 		}
 
 		vg->alloc = get_alloc_from_string(cv->v.str);
-		if (vg->alloc == ALLOC_INVALID)
-			return_0;
+		if (vg->alloc == ALLOC_INVALID) {
+			log_warn("WARNING: Ignoring unrecognised allocation policy %s for VG %s", cv->v.str, vg->name);
+			vg->alloc = ALLOC_NORMAL;
+		}
 	}
 
 	if (!_read_uint32(vgn, "metadata_copies", &vg->mda_copies)) {


