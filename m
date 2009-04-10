From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 10 Apr 2009 10:01:08 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20090410100108.21546.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-04-10 10:01:08

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Properly release VG memory pool in metadata manipulation code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.210&r2=1.211

--- LVM2/lib/metadata/metadata.c	2009/04/10 09:59:19	1.210
+++ LVM2/lib/metadata/metadata.c	2009/04/10 10:01:08	1.211
@@ -111,7 +111,7 @@
 {
 	struct pv_list *pvl;
 	struct format_instance *fid = vg->fid;
-	struct dm_pool *mem = fid->fmt->cmd->mem;
+	struct dm_pool *mem = vg->vgmem;
 
 	log_verbose("Adding physical volume '%s' to volume group '%s'",
 		    pv_name, vg->name);
@@ -241,7 +241,7 @@
 {
 	struct volume_group *vg;
 	struct pv_list *pvl;
-	int consistent = 0;
+	int r = 0, consistent = 0;
 
 	if (!(vg = vg_read_internal(fmt->cmd, vg_name, vgid, &consistent))) {
 		log_error("get_pv_from_vg_by_id: vg_read_internal failed to read VG %s",
@@ -257,13 +257,16 @@
 		if (id_equal(&pvl->pv->id, (const struct id *) pvid)) {
 			if (!_copy_pv(fmt->cmd->mem, pv, pvl->pv)) {
 				log_error("internal PV duplication failed");
-				return_0;
+				r = 0;
+				goto out;
 			}
-			return 1;
+			r = 1;
+			goto out;
 		}
 	}
-
-	return 0;
+out:
+	vg_release(vg);
+	return r;
 }
 
 static int validate_new_vg_name(struct cmd_context *cmd, const char *vg_name)
@@ -316,7 +319,7 @@
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name)
 {
-	struct dm_pool *mem = cmd->mem;
+	struct dm_pool *mem = vg->vgmem;
 	struct pv_list *pvl;
 
 	if (!(vg->name = dm_pool_strdup(mem, new_name))) {
@@ -1823,18 +1826,25 @@
 		    (!use_precommitted &&
 		     !(vg = mda->ops->vg_read(fid, vgname, mda)))) {
 			inconsistent = 1;
+			vg_release(vg);
 			continue;
 		}
 		if (!correct_vg) {
 			correct_vg = vg;
 			continue;
 		}
+
 		/* FIXME Also ensure contents same - checksum compare? */
 		if (correct_vg->seqno != vg->seqno) {
 			inconsistent = 1;
-			if (vg->seqno > correct_vg->seqno)
+			if (vg->seqno > correct_vg->seqno) {
+				vg_release(correct_vg);
 				correct_vg = vg;
+			}
 		}
+
+		if (vg != correct_vg)
+			vg_release(vg);
 	}
 
 	/* Ensure every PV in the VG was in the cache */
@@ -1884,14 +1894,17 @@
 
 			if (memlock())
 				inconsistent = 1;
-			else
+			else {
+				vg_release(correct_vg);
 				correct_vg = NULL;
+			}
 		} else dm_list_iterate_items(pvl, &correct_vg->pvs) {
 			if (pvl->pv->status & MISSING_PV)
 				continue;
 			if (!str_list_match_item(pvids, pvl->pv->dev->pvid)) {
 				log_debug("Cached VG %s had incorrect PV list",
 					  vgname);
+				vg_release(correct_vg);
 				correct_vg = NULL;
 				break;
 			}
@@ -1931,8 +1944,10 @@
 			}
 			if (!correct_vg) {
 				correct_vg = vg;
-				if (!_update_pv_list(cmd->mem, &all_pvs, correct_vg))
+				if (!_update_pv_list(cmd->mem, &all_pvs, correct_vg)) {
+					vg_release(vg);
 					return_NULL;
+				}
 				continue;
 			}
 
@@ -1945,11 +1960,19 @@
 			/* FIXME Also ensure contents same - checksums same? */
 			if (correct_vg->seqno != vg->seqno) {
 				inconsistent = 1;
-				if (!_update_pv_list(cmd->mem, &all_pvs, vg))
+				if (!_update_pv_list(cmd->mem, &all_pvs, vg)) {
+					vg_release(vg);
+					vg_release(correct_vg);
 					return_NULL;
-				if (vg->seqno > correct_vg->seqno)
+				}
+				if (vg->seqno > correct_vg->seqno) {
+					vg_release(correct_vg);
 					correct_vg = vg;
+				}
 			}
+
+			if (vg != correct_vg)
+				vg_release(vg);
 		}
 
 		/* Give up looking */
@@ -1964,6 +1987,7 @@
 		if (use_precommitted) {
 			log_error("Inconsistent pre-commit metadata copies "
 				  "for volume group %s", vgname);
+			vg_release(correct_vg);
 			return NULL;
 		}
 
@@ -1983,12 +2007,14 @@
 
 		if (!vg_write(correct_vg)) {
 			log_error("Automatic metadata correction failed");
+			vg_release(correct_vg);
 			return NULL;
 		}
 
 		if (!vg_commit(correct_vg)) {
 			log_error("Automatic metadata correction commit "
 				  "failed");
+			vg_release(correct_vg);
 			return NULL;
 		}
 
@@ -1997,12 +2023,16 @@
 				if (pvl->pv->dev == pvl2->pv->dev)
 					goto next_pv;
 			}
-			if (!id_write_format(&pvl->pv->id, uuid, sizeof(uuid)))
+			if (!id_write_format(&pvl->pv->id, uuid, sizeof(uuid))) {
+				vg_release(correct_vg);
 				return_NULL;
+			}
 			log_error("Removing PV %s (%s) that no longer belongs to VG %s",
 				  pv_dev_name(pvl->pv), uuid, correct_vg->name);
-			if (!pv_write_orphan(cmd, pvl->pv))
+			if (!pv_write_orphan(cmd, pvl->pv)) {
+				vg_release(correct_vg);
 				return_NULL;
+			}
       next_pv:
 			;
 		}
@@ -2019,6 +2049,7 @@
 			  "volume group %s", correct_vg->name);
 		log_error("Please restore the metadata by running "
 			  "vgcfgrestore.");
+		vg_release(correct_vg);
 		return NULL;
 	}
 
@@ -2038,6 +2069,7 @@
 	if (!check_pv_segments(vg)) {
 		log_error("Internal error: PV segments corrupted in %s.",
 			  vg->name);
+		vg_release(vg);
 		return NULL;
 	}
 
@@ -2045,6 +2077,7 @@
 		if (!check_lv_segments(lvl->lv, 1)) {
 			log_error("Internal error: LV segments corrupted in %s.",
 				  lvl->lv->name);
+			vg_release(vg);
 			return NULL;
 		}
 	}
@@ -2074,7 +2107,7 @@
 {
 	const char *vgname;
 	struct dm_list *vgnames;
-	struct volume_group *vg;
+	struct volume_group *vg = NULL;
 	struct lvmcache_vginfo *vginfo;
 	struct str_list *strl;
 	int consistent = 0;
@@ -2092,11 +2125,12 @@
 			}
 			return vg;
 		}
+		vg_release(vg);
 	}
 
 	/* Mustn't scan if memory locked: ensure cache gets pre-populated! */
 	if (memlock())
-		return NULL;
+		goto out;
 
 	/* FIXME Need a genuine read by ID here - don't vg_read_internal by name! */
 	/* FIXME Disabled vgrenames while active for now because we aren't
@@ -2105,7 +2139,7 @@
 	// The slow way - full scan required to cope with vgrename
 	if (!(vgnames = get_vgnames(cmd, 2))) {
 		log_error("vg_read_by_vgid: get_vgnames failed");
-		return NULL;
+		goto out;
 	}
 
 	dm_list_iterate_items(strl, vgnames) {
@@ -2120,12 +2154,14 @@
 			if (!consistent) {
 				log_error("Volume group %s metadata is "
 					  "inconsistent", vgname);
-				return NULL;
+				goto out;
 			}
 			return vg;
 		}
 	}
 
+out:
+	vg_release(vg);
 	return NULL;
 }
 
@@ -2148,14 +2184,17 @@
 	log_verbose("Found volume group \"%s\"", vg->name);
 	if (vg->status & EXPORTED_VG) {
 		log_error("Volume group \"%s\" is exported", vg->name);
-		return NULL;
+		goto out;
 	}
 	if (!(lvl = find_lv_in_vg_by_lvid(vg, lvid))) {
 		log_very_verbose("Can't find logical volume id %s", lvid_s);
-		return NULL;
+		goto out;
 	}
 
 	return lvl->lv;
+out:
+	vg_release(vg);
+	return NULL;
 }
 
 /**
@@ -2296,10 +2335,12 @@
 			dm_list_iterate_items(pvl, &vg->pvs) {
 				if (!(pvl_copy = _copy_pvl(cmd->mem, pvl))) {
 					log_error("PV list allocation failed");
+					vg_release(vg);
 					return 0;
 				}
 				dm_list_add(results, &pvl_copy->list);
 			}
+		vg_release(vg);
 	}
 	init_pvmove(old_pvmove);
 
@@ -2529,12 +2570,12 @@
 	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent)) ||
 	    ((misc_flags & FAIL_INCONSISTENT) && !consistent)) {
 		log_error("Volume group \"%s\" not found", vg_name);
-		unlock_vg(cmd, vg_name);
+		unlock_release_vg(cmd, vg, vg_name);
 		return NULL;
 	}
 
 	if (!vg_check_status(vg, status_flags)) {
-		unlock_vg(cmd, vg_name);
+		unlock_release_vg(cmd, vg, vg_name);
 		return NULL;
 	}
 
@@ -2549,9 +2590,17 @@
 			     struct volume_group *vg,
 			     uint32_t failure)
 {
-	if (!vg && !(vg = dm_pool_zalloc(cmd->mem, sizeof(*vg)))) {
-		log_error("Error allocating vg handle.");
-		return_NULL;
+	struct dm_pool *vgmem;
+
+	if (!vg) {
+		if (!(vgmem = dm_pool_create("lvm2 vg_handle", VG_MEMPOOL_CHUNK)) &&
+		    !(vg = dm_pool_zalloc(vgmem, sizeof(*vg)))) {
+			log_error("Error allocating vg handle.");
+			if (vgmem)
+				dm_pool_destroy(vgmem);
+			return_NULL;
+		}
+		vg->vgmem = vgmem;
 	}
 
 	vg->read_status = failure;
@@ -2579,8 +2628,10 @@
 	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent)))
 		return_NULL;
 
-	if (!consistent)
+	if (!consistent) {
+		vg_release(vg);
 		return_NULL;
+	}
 
 	return (vg_t *)vg;
 }
@@ -2600,7 +2651,7 @@
 			       const char *vgid, uint32_t lock_flags,
 			       uint32_t status_flags, uint32_t misc_flags)
 {
-	struct volume_group *vg = 0;
+	struct volume_group *vg = NULL;
 	const char *lock_name;
  	int consistent = 1;
 	int consistent_in;
@@ -2656,13 +2707,15 @@
 	}
 
 	/* consistent == 0 when VG is not found, but failed == FAILED_NOTFOUND */
-	if (!consistent && !failure)
+	if (!consistent && !failure) {
+		vg_release(vg);
 		if (!(vg = _recover_vg(cmd, lock_name, vg_name, vgid, lock_flags))) {
 			log_error("Recovery of volume group \"%s\" failed.",
 				  vg_name);
 			failure |= FAILED_INCONSISTENT;
 			goto_bad;
 		}
+	}
 	
 
 	failure |= _vg_bad_status_bits(vg, status_flags & ~CLUSTERED);


