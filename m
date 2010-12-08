From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Dec 2010 20:51:11 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20101208205111.30938.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-12-08 20:50:52

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	lib/activate   : activate.c 
	lib/cache      : lvmcache.c 
	lib/format_text: archive.c archiver.c format-text.c 
	lib/locking    : locking.h 
	lib/metadata   : metadata-exported.h metadata.c 
	                 replicator_manip.c 
	liblvm         : lvm_vg.c 
	tools          : lvconvert.c lvcreate.c lvrename.c lvresize.c 
	                 polldaemon.c pvchange.c pvcreate.c pvdisplay.c 
	                 pvmove.c pvresize.c reporter.c toollib.c 
	                 vgcreate.c vgextend.c vgmerge.c vgreduce.c 
	                 vgrename.c vgsplit.c 

Log message:
	Rename vg_release to free_vg.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1831&r2=1.1832
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.103&r2=1.104
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.181&r2=1.182
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archive.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.149&r2=1.150
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.172&r2=1.173
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.414&r2=1.415
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/replicator_manip.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.151&r2=1.152
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.226&r2=1.227
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvrename.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.126&r2=1.127
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.92&r2=1.93
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.216&r2=1.217
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.104&r2=1.105
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.102&r2=1.103

--- LVM2/WHATS_NEW	2010/12/08 19:26:35	1.1831
+++ LVM2/WHATS_NEW	2010/12/08 20:50:48	1.1832
@@ -1,7 +1,7 @@
 Version 2.02.79 -
 ===================================
   Cope better with an undefined target_percent operation in _percent_run.
-  Fix write to released memory in vg_release().  (2.02.78)
+  Fix write to released memory in vg_release and rename to free_vg.  (2.02.78)
 
 Version 2.02.78 - 6th December 2010
 ===================================
--- LVM2/daemons/clvmd/lvm-functions.c	2010/12/06 17:57:15	1.103
+++ LVM2/daemons/clvmd/lvm-functions.c	2010/12/08 20:50:48	1.104
@@ -863,7 +863,7 @@
 	else
 		log_error("Error backing up metadata, can't find VG for group %s", vgname);
 
-	vg_release(vg);
+	free_vg(vg);
 	dm_pool_empty(cmd->mem);
 
 	pthread_mutex_unlock(&lvm_lock);
--- LVM2/lib/activate/activate.c	2010/11/30 11:53:31	1.181
+++ LVM2/lib/activate/activate.c	2010/12/08 20:50:49	1.182
@@ -491,7 +491,7 @@
 		origin_only = 0;
 
 	r = lv_info(cmd, lv, origin_only, info, with_open_count, with_read_ahead);
-	vg_release(lv->vg);
+	free_vg(lv->vg);
 
 	return r;
 }
@@ -1052,10 +1052,10 @@
 	r = 1;
 out:
 	if (lv_pre)
-		vg_release(lv_pre->vg);
+		free_vg(lv_pre->vg);
 	if (lv) {
 		lv_release_replicator_vgs(lv);
-		vg_release(lv->vg);
+		free_vg(lv->vg);
 	}
 
 	return r;
@@ -1120,7 +1120,7 @@
 	r = 1;
 out:
 	if (lv)
-		vg_release(lv->vg);
+		free_vg(lv->vg);
 
 	return r;
 }
@@ -1213,7 +1213,7 @@
 out:
 	if (lv) {
 		lv_release_replicator_vgs(lv);
-		vg_release(lv->vg);
+		free_vg(lv->vg);
 	}
 
 	return r;
@@ -1243,7 +1243,7 @@
 	r = 1;
 out:
 	if (lv)
-		vg_release(lv->vg);
+		free_vg(lv->vg);
 
 	return r;
 }
@@ -1313,7 +1313,7 @@
 out:
 	if (lv) {
 		lv_release_replicator_vgs(lv);
-		vg_release(lv->vg);
+		free_vg(lv->vg);
 	}
 
 	return r;
--- LVM2/lib/cache/lvmcache.c	2010/12/01 10:39:29	1.98
+++ LVM2/lib/cache/lvmcache.c	2010/12/08 20:50:49	1.99
@@ -643,7 +643,7 @@
 
 	if (!(vg = import_vg_from_buffer(vginfo->vgmetadata, fid))) {
 		_free_cached_vgmetadata(vginfo);
-		vg_release(vg);
+		free_vg(vg);
 		return_NULL;
 	}
 
--- LVM2/lib/format_text/archive.c	2010/09/09 13:13:12	1.39
+++ LVM2/lib/format_text/archive.c	2010/12/08 20:50:49	1.40
@@ -329,7 +329,7 @@
 	log_print("Description:\t%s", desc ? : "<No description>");
 	log_print("Backup Time:\t%s", ctime(&when));
 
-	vg_release(vg);
+	free_vg(vg);
 	tf->fmt->ops->destroy_instance(tf);
 }
 
--- LVM2/lib/format_text/archiver.c	2010/09/09 13:07:14	1.34
+++ LVM2/lib/format_text/archiver.c	2010/12/08 20:50:49	1.35
@@ -365,7 +365,7 @@
 		log_error("Cannot restore Volume Group %s with %i PVs "
 			  "marked as missing.", vg->name, missing_pvs);
 
-	vg_release(vg);
+	free_vg(vg);
 	return r;
 }
 
@@ -446,14 +446,14 @@
 	    (vg->seqno == vg_backup->seqno) &&
 	    (id_equal(&vg->id, &vg_backup->id))) {
 		log_suppress(old_suppress);
-		vg_release(vg_backup);
+		free_vg(vg_backup);
 		return;
 	}
 	log_suppress(old_suppress);
 
 	if (vg_backup) {
 		archive(vg_backup);
-		vg_release(vg_backup);
+		free_vg(vg_backup);
 	}
 	archive(vg);
 	backup_locally(vg);
--- LVM2/lib/format_text/format-text.c	2010/11/29 11:16:58	1.149
+++ LVM2/lib/format_text/format-text.c	2010/12/08 20:50:49	1.150
@@ -857,7 +857,7 @@
 	 * check that it contains the correct volume group.
 	 */
 	if (vgname && strcmp(vgname, vg->name)) {
-		dm_pool_destroy(vg->vgmem);
+		free_vg(vg);
 		log_error("'%s' does not contain volume group '%s'.",
 			  read_path, vgname);
 		return NULL;
@@ -1085,7 +1085,7 @@
 							     path))) {
 					/* FIXME Store creation host in vg */
 					lvmcache_update_vg(vg, 0);
-					dm_pool_destroy(vg->vgmem);
+					free_vg(vg);
 				}
 			}
 
--- LVM2/lib/locking/locking.h	2010/08/17 19:25:05	1.58
+++ LVM2/lib/locking/locking.h	2010/12/08 20:50:50	1.59
@@ -143,10 +143,10 @@
 		0)
 
 #define unlock_vg(cmd, vol)	lock_vol(cmd, vol, LCK_VG_UNLOCK)
-#define unlock_and_release_vg(cmd, vg, vol) \
+#define unlock_and_free_vg(cmd, vg, vol) \
 	do { \
 		unlock_vg(cmd, vol); \
-		vg_release(vg); \
+		free_vg(vg); \
 	} while (0)
 
 #define resume_lv(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_RESUME)
--- LVM2/lib/metadata/metadata-exported.h	2010/11/30 11:53:32	1.172
+++ LVM2/lib/metadata/metadata-exported.h	2010/12/08 20:50:50	1.173
@@ -425,10 +425,10 @@
 		     struct volume_group *vg,
 		     force_t force);
 /*
- * vg_release() must be called on every struct volume_group allocated
+ * free_vg() must be called on every struct volume_group allocated
  * by vg_create() or vg_read_internal() to free it when no longer required.
  */
-void vg_release(struct volume_group *vg);
+void free_vg(struct volume_group *vg);
 
 /* Manipulate LVs */
 struct logical_volume *lv_create_empty(const char *name,
@@ -682,7 +682,7 @@
 struct cmd_vg *cmd_vg_lookup(struct dm_list *cmd_vgs,
 			     const char *vg_name, const char *vgid);
 int cmd_vg_read(struct cmd_context *cmd, struct dm_list *cmd_vgs);
-void cmd_vg_release(struct dm_list *cmd_vgs);
+void free_cmd_vgs(struct dm_list *cmd_vgs);
 
 int find_replicator_vgs(struct logical_volume *lv);
 
--- LVM2/lib/metadata/metadata.c	2010/12/08 10:45:37	1.414
+++ LVM2/lib/metadata/metadata.c	2010/12/08 20:50:50	1.415
@@ -366,7 +366,7 @@
 		}
 	}
 out:
-	vg_release(vg);
+	free_vg(vg);
 	return r;
 }
 
@@ -920,7 +920,7 @@
 	/* is this vg name already in use ? */
 	if ((vg = vg_read_internal(cmd, vg_name, NULL, 1, &consistent))) {
 		log_error("A volume group called '%s' already exists.", vg_name);
-		unlock_and_release_vg(cmd, vg, vg_name);
+		unlock_and_free_vg(cmd, vg, vg_name);
 		return _vg_make_handle(cmd, NULL, FAILED_EXIST);
 	}
 
@@ -988,7 +988,7 @@
 	return _vg_make_handle(cmd, vg, SUCCESS);
 
 bad:
-	unlock_and_release_vg(cmd, vg, vg_name);
+	unlock_and_free_vg(cmd, vg, vg_name);
 	/* FIXME: use _vg_make_handle() w/proper error code */
 	return NULL;
 }
@@ -2700,7 +2700,7 @@
 		}
 		return correct_vg;
 	} else {
-		vg_release(correct_vg);
+		free_vg(correct_vg);
 		correct_vg = NULL;
 	}
 
@@ -2741,7 +2741,7 @@
 		    (!use_precommitted &&
 		     !(vg = mda->ops->vg_read(fid, vgname, mda)))) {
 			inconsistent = 1;
-			vg_release(vg);
+			free_vg(vg);
 			continue;
 		}
 		if (!correct_vg) {
@@ -2760,13 +2760,13 @@
 				inconsistent_seqno = 1;
 			}
 			if (vg->seqno > correct_vg->seqno) {
-				vg_release(correct_vg);
+				free_vg(correct_vg);
 				correct_vg = vg;
 			}
 		}
 
 		if (vg != correct_vg)
-			vg_release(vg);
+			free_vg(vg);
 	}
 
 	/* Ensure every PV in the VG was in the cache */
@@ -2841,7 +2841,7 @@
 			if (memlock())
 				inconsistent = 1;
 			else {
-				vg_release(correct_vg);
+				free_vg(correct_vg);
 				correct_vg = NULL;
 			}
 		} else dm_list_iterate_items(pvl, &correct_vg->pvs) {
@@ -2850,14 +2850,14 @@
 			if (!str_list_match_item(pvids, pvl->pv->dev->pvid)) {
 				log_debug("Cached VG %s had incorrect PV list",
 					  vgname);
-				vg_release(correct_vg);
+				free_vg(correct_vg);
 				correct_vg = NULL;
 				break;
 			}
 		}
 
 		if (correct_vg && inconsistent_mdas) {
-			vg_release(correct_vg);
+			free_vg(correct_vg);
 			correct_vg = NULL;
 		}
 	}
@@ -2896,7 +2896,7 @@
 			if (!correct_vg) {
 				correct_vg = vg;
 				if (!_update_pv_list(cmd->mem, &all_pvs, correct_vg)) {
-					vg_release(vg);
+					free_vg(vg);
 					return_NULL;
 				}
 				continue;
@@ -2920,18 +2920,18 @@
 					inconsistent_seqno = 1;
 				}
 				if (!_update_pv_list(cmd->mem, &all_pvs, vg)) {
-					vg_release(vg);
-					vg_release(correct_vg);
+					free_vg(vg);
+					free_vg(correct_vg);
 					return_NULL;
 				}
 				if (vg->seqno > correct_vg->seqno) {
-					vg_release(correct_vg);
+					free_vg(correct_vg);
 					correct_vg = vg;
 				}
 			}
 
 			if (vg != correct_vg)
-				vg_release(vg);
+				free_vg(vg);
 		}
 
 		/* Give up looking */
@@ -2961,7 +2961,7 @@
 				*consistent = 0;
 				return correct_vg;
 			}
-			vg_release(correct_vg);
+			free_vg(correct_vg);
 			return NULL;
 		}
 
@@ -2989,7 +2989,7 @@
 		cmd->handles_missing_pvs = 1;
 		if (!vg_write(correct_vg)) {
 			log_error("Automatic metadata correction failed");
-			vg_release(correct_vg);
+			free_vg(correct_vg);
 			cmd->handles_missing_pvs = saved_handles_missing_pvs;
 			return NULL;
 		}
@@ -2998,7 +2998,7 @@
 		if (!vg_commit(correct_vg)) {
 			log_error("Automatic metadata correction commit "
 				  "failed");
-			vg_release(correct_vg);
+			free_vg(correct_vg);
 			return NULL;
 		}
 
@@ -3008,13 +3008,13 @@
 					goto next_pv;
 			}
 			if (!id_write_format(&pvl->pv->id, uuid, sizeof(uuid))) {
-				vg_release(correct_vg);
+				free_vg(correct_vg);
 				return_NULL;
 			}
 			log_error("Removing PV %s (%s) that no longer belongs to VG %s",
 				  pv_dev_name(pvl->pv), uuid, correct_vg->name);
 			if (!pv_write_orphan(cmd, pvl->pv)) {
-				vg_release(correct_vg);
+				free_vg(correct_vg);
 				return_NULL;
 			}
 
@@ -3036,7 +3036,7 @@
 			  "volume group %s", correct_vg->name);
 		log_error("Please restore the metadata by running "
 			  "vgcfgrestore.");
-		vg_release(correct_vg);
+		free_vg(correct_vg);
 		return NULL;
 	}
 
@@ -3056,7 +3056,7 @@
 	if (!check_pv_segments(vg)) {
 		log_error(INTERNAL_ERROR "PV segments corrupted in %s.",
 			  vg->name);
-		vg_release(vg);
+		free_vg(vg);
 		return NULL;
 	}
 
@@ -3064,7 +3064,7 @@
 		if (!check_lv_segments(lvl->lv, 0)) {
 			log_error(INTERNAL_ERROR "LV segments corrupted in %s.",
 				  lvl->lv->name);
-			vg_release(vg);
+			free_vg(vg);
 			return NULL;
 		}
 	}
@@ -3076,7 +3076,7 @@
 		if (!check_lv_segments(lvl->lv, 1)) {
 			log_error(INTERNAL_ERROR "LV segments corrupted in %s.",
 				  lvl->lv->name);
-			vg_release(vg);
+			free_vg(vg);
 			return NULL;
 		}
 	}
@@ -3084,14 +3084,16 @@
 	return vg;
 }
 
-void vg_release(struct volume_group *vg)
+void free_vg(struct volume_group *vg)
 {
-	if (!vg || !vg->vgmem)
+	if (!vg)
 		return;
 
-	if (vg->cmd && vg->vgmem == vg->cmd->mem)
+	if (vg->cmd && vg->vgmem == vg->cmd->mem) {
 		log_error(INTERNAL_ERROR "global memory pool used for VG %s",
 			  vg->name);
+		return;
+	}
 
 	dm_pool_destroy(vg->vgmem);
 }
@@ -3122,7 +3124,7 @@
 					  "inconsistent", vg->name);
 			return vg;
 		}
-		vg_release(vg);
+		free_vg(vg);
 	}
 
 	/* Mustn't scan if memory locked: ensure cache gets pre-populated! */
@@ -3151,12 +3153,12 @@
 			if (!consistent) {
 				log_error("Volume group %s metadata is "
 					  "inconsistent", vgname);
-				vg_release(vg);
+				free_vg(vg);
 				return NULL;
 			}
 			return vg;
 		}
-		vg_release(vg);
+		free_vg(vg);
 	}
 
 	return NULL;
@@ -3190,7 +3192,7 @@
 
 	return lvl->lv;
 out:
-	vg_release(vg);
+	free_vg(vg);
 	return NULL;
 }
 
@@ -3384,12 +3386,12 @@
 			dm_list_iterate_items(pvl, &vg->pvs) {
 				if (!(pvl_copy = _copy_pvl(cmd->mem, pvl))) {
 					log_error("PV list allocation failed");
-					vg_release(vg);
+					free_vg(vg);
 					return 0;
 				}
 				dm_list_add(results, &pvl_copy->list);
 			}
-		vg_release(vg);
+		free_vg(vg);
 	}
 	init_pvmove(old_pvmove);
 
@@ -3592,7 +3594,7 @@
 		return_NULL;
 
 	if (!consistent) {
-		vg_release(vg);
+		free_vg(vg);
 		return_NULL;
 	}
 
@@ -3664,7 +3666,7 @@
 
 	/* consistent == 0 when VG is not found, but failed == FAILED_NOTFOUND */
 	if (!consistent && !failure) {
-		vg_release(vg);
+		free_vg(vg);
 		if (!(vg = _recover_vg(cmd, vg_name, vgid))) {
 			log_error("Recovery of volume group \"%s\" failed.",
 				  vg_name);
--- LVM2/lib/metadata/replicator_manip.c	2010/05/21 14:07:19	1.6
+++ LVM2/lib/metadata/replicator_manip.c	2010/12/08 20:50:50	1.7
@@ -590,16 +590,16 @@
  *
  * \param cmd_vgs	Contains list of cmd_vg entries.
  */
-void cmd_vg_release(struct dm_list *cmd_vgs)
+void free_cmd_vgs(struct dm_list *cmd_vgs)
 {
 	struct cmd_vg *cvl;
 
 	/* Backward iterate cmd_vg list */
 	dm_list_iterate_back_items(cvl, cmd_vgs) {
 		if (vg_read_error(cvl->vg))
-			vg_release(cvl->vg);
+			free_vg(cvl->vg);
 		else
-			unlock_and_release_vg(cvl->vg->cmd, cvl->vg, cvl->vg_name);
+			unlock_and_free_vg(cvl->vg->cmd, cvl->vg, cvl->vg_name);
 		cvl->vg = NULL;
 	}
 }
@@ -687,7 +687,7 @@
 
 	dm_list_iterate_back_items(rsite, &first_seg(lv)->replicator->rsites)
 		if (rsite->vg_name && rsite->vg) {
-			vg_release(rsite->vg);
+			free_vg(rsite->vg);
 			rsite->vg = NULL;
 		}
 }
--- LVM2/liblvm/lvm_vg.c	2010/11/17 20:12:40	1.48
+++ LVM2/liblvm/lvm_vg.c	2010/12/08 20:50:51	1.49
@@ -56,7 +56,7 @@
 	vg = vg_create((struct cmd_context *)libh, vg_name);
 	/* FIXME: error handling is still TBD */
 	if (vg_read_error(vg)) {
-		vg_release(vg);
+		free_vg(vg);
 		return NULL;
 	}
 	vg->open_mode = 'w';
@@ -159,9 +159,9 @@
 int lvm_vg_close(vg_t vg)
 {
 	if (vg_read_error(vg) == FAILED_LOCKING)
-		vg_release(vg);
+		free_vg(vg);
 	else
-		unlock_and_release_vg(vg->cmd, vg, vg->name);
+		unlock_and_free_vg(vg->cmd, vg, vg->name);
 	return 0;
 }
 
@@ -196,7 +196,7 @@
 	vg = vg_read((struct cmd_context *)libh, vgname, NULL, internal_flags);
 	if (vg_read_error(vg)) {
 		/* FIXME: use log_errno either here in inside vg_read */
-		vg_release(vg);
+		free_vg(vg);
 		return NULL;
 	}
 	/* FIXME: combine this with locking ? */
--- LVM2/tools/lvconvert.c	2010/11/30 11:53:33	1.151
+++ LVM2/tools/lvconvert.c	2010/12/08 20:50:51	1.152
@@ -1619,7 +1619,7 @@
 {
 	/*
 	 * Returns NULL if the requested LV doesn't exist;
-	 * otherwise the caller must vg_release(lv->vg)
+	 * otherwise the caller must free_vg(lv->vg)
 	 * - it is also up to the caller to unlock_vg() as needed
 	 */
 	struct volume_group *vg;
@@ -1627,13 +1627,13 @@
 
 	vg = _get_lvconvert_vg(cmd, vg_name, NULL);
 	if (vg_read_error(vg)) {
-		vg_release(vg);
+		free_vg(vg);
 		return_NULL;
 	}
 
 	if (!(lv = _get_lvconvert_lv(cmd, vg, lv_name, NULL, 0))) {
 		log_error("Can't find LV %s in VG %s", lv_name, vg_name);
-		unlock_and_release_vg(cmd, vg, vg_name);
+		unlock_and_free_vg(cmd, vg, vg_name);
 		return NULL;
 	}
 
@@ -1686,7 +1686,7 @@
 		ret = poll_logical_volume(cmd, lp->lv_to_poll,
 					  lp->wait_completion);
 
-	vg_release(lv->vg);
+	free_vg(lv->vg);
 out:
 	init_ignore_suspended_devices(saved_ignore_suspended_devices);
 	return ret;
@@ -1736,7 +1736,7 @@
 		}
 	}
 
-	vg_release(refreshed_lv->vg);
+	free_vg(refreshed_lv->vg);
 
 	return ret;
 }
--- LVM2/tools/lvcreate.c	2010/11/30 11:53:33	1.226
+++ LVM2/tools/lvcreate.c	2010/12/08 20:50:51	1.227
@@ -546,7 +546,7 @@
 	log_verbose("Finding volume group \"%s\"", lp.vg_name);
 	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
-		vg_release(vg);
+		free_vg(vg);
 		stack;
 		return ECMD_FAILED;
 	}
@@ -561,6 +561,6 @@
 		r = ECMD_FAILED;
 	}
 out:
-	unlock_and_release_vg(cmd, vg, lp.vg_name);
+	unlock_and_free_vg(cmd, vg, lp.vg_name);
 	return r;
 }
--- LVM2/tools/lvrename.c	2009/09/14 22:47:49	1.56
+++ LVM2/tools/lvrename.c	2010/12/08 20:50:51	1.57
@@ -104,7 +104,7 @@
 	log_verbose("Checking for existing volume group \"%s\"", vg_name);
 	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
-		vg_release(vg);
+		free_vg(vg);
 		stack;
 		return ECMD_FAILED;
 	}
@@ -123,6 +123,6 @@
 
 	r = ECMD_PROCESSED;
 error:
-	unlock_and_release_vg(cmd, vg, vg_name);
+	unlock_and_free_vg(cmd, vg, vg_name);
 	return r;
 }
--- LVM2/tools/lvresize.c	2010/11/30 11:53:33	1.126
+++ LVM2/tools/lvresize.c	2010/12/08 20:50:51	1.127
@@ -738,7 +738,7 @@
 	log_verbose("Finding volume group %s", lp.vg_name);
 	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
-		vg_release(vg);
+		free_vg(vg);
 		stack;
 		return ECMD_FAILED;
 	}
@@ -746,7 +746,7 @@
 	if (!(r = _lvresize(cmd, vg, &lp)))
 		stack;
 
-	unlock_and_release_vg(cmd, vg, lp.vg_name);
+	unlock_and_free_vg(cmd, vg, lp.vg_name);
 
 	return r;
 }
--- LVM2/tools/polldaemon.c	2010/11/30 11:53:33	1.38
+++ LVM2/tools/polldaemon.c	2010/12/08 20:50:51	1.39
@@ -183,7 +183,7 @@
 		/* Locks the (possibly renamed) VG again */
 		vg = parms->poll_fns->get_copy_vg(cmd, name, uuid);
 		if (vg_read_error(vg)) {
-			vg_release(vg);
+			free_vg(vg);
 			log_error("ABORTING: Can't reread VG for %s", name);
 			/* What more could we do here? */
 			return 0;
@@ -193,16 +193,16 @@
 							parms->lv_type))) {
 			log_error("ABORTING: Can't find LV in %s for %s",
 				  vg->name, name);
-			unlock_and_release_vg(cmd, vg, vg->name);
+			unlock_and_free_vg(cmd, vg, vg->name);
 			return 0;
 		}
 
 		if (!_check_lv_status(cmd, vg, lv, name, parms, &finished)) {
-			unlock_and_release_vg(cmd, vg, vg->name);
+			unlock_and_free_vg(cmd, vg, vg->name);
 			return 0;
 		}
 
-		unlock_and_release_vg(cmd, vg, vg->name);
+		unlock_and_free_vg(cmd, vg, vg->name);
 
 		/*
 		 * FIXME Sleeping after testing, while preferred, also works around
--- LVM2/tools/pvchange.c	2010/11/11 17:29:06	1.85
+++ LVM2/tools/pvchange.c	2010/12/08 20:50:51	1.86
@@ -240,7 +240,7 @@
 			}
 			vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 			if (vg_read_error(vg)) {
-				vg_release(vg);
+				free_vg(vg);
 				stack;
 				continue;
 			}
@@ -254,7 +254,7 @@
 			total++;
 			done += _pvchange_single(cmd, vg,
 						 pvl->pv, NULL);
-			unlock_and_release_vg(cmd, vg, vg_name);
+			unlock_and_free_vg(cmd, vg, vg_name);
 		}
 	} else {
 		log_verbose("Scanning for physical volume names");
@@ -275,7 +275,7 @@
 			dm_list_iterate_items(sll, vgnames) {
 				vg = vg_read_for_update(cmd, sll->str, NULL, 0);
 				if (vg_read_error(vg)) {
-					vg_release(vg);
+					free_vg(vg);
 					stack;
 					continue;
 				}
@@ -285,7 +285,7 @@
 								 pvl->pv,
 								 NULL);
 				}
-				unlock_and_release_vg(cmd, vg, sll->str);
+				unlock_and_free_vg(cmd, vg, sll->str);
 			}
 		}
 	}
--- LVM2/tools/pvcreate.c	2010/09/23 12:02:34	1.92
+++ LVM2/tools/pvcreate.c	2010/12/08 20:50:51	1.93
@@ -74,7 +74,7 @@
 		pp->pe_start = pv_pe_start(existing_pvl->pv);
 		pp->extent_size = pv_pe_size(existing_pvl->pv);
 		pp->extent_count = pv_pe_count(existing_pvl->pv);
-		vg_release(vg);
+		free_vg(vg);
 	}
 
 	if (arg_sign_value(cmd, physicalvolumesize_ARG, 0) == SIGN_MINUS) {
--- LVM2/tools/pvdisplay.c	2009/11/24 17:07:09	1.54
+++ LVM2/tools/pvdisplay.c	2010/12/08 20:50:51	1.55
@@ -32,7 +32,7 @@
 		vg = vg_read(cmd, vg_name, (char *)&pv->vgid, 0);
 		if (vg_read_error(vg)) {
 			log_error("Skipping volume group %s", vg_name);
-			vg_release(vg);
+			free_vg(vg);
 			/* FIXME If CLUSTERED should return ECMD_PROCESSED here */
 			return ECMD_FAILED;
 		}
@@ -85,7 +85,7 @@
 	if (vg_name)
 		unlock_vg(cmd, vg_name);
 	if (!old_vg)
-		vg_release(vg);
+		free_vg(vg);
 
 	return ret;
 }
--- LVM2/tools/pvmove.c	2010/09/23 12:02:34	1.80
+++ LVM2/tools/pvmove.c	2010/12/08 20:50:51	1.81
@@ -445,7 +445,7 @@
 
 	vg = _get_vg(cmd, pv_vg_name(pv));
 	if (vg_read_error(vg)) {
-		vg_release(vg);
+		free_vg(vg);
 		stack;
 		return ECMD_FAILED;
 	}
@@ -510,7 +510,7 @@
 	/* LVs are all in status LOCKED */
 	r = ECMD_PROCESSED;
 out:
-	unlock_and_release_vg(cmd, vg, pv_vg_name(pv));
+	unlock_and_free_vg(cmd, vg, pv_vg_name(pv));
 	return r;
 }
 
--- LVM2/tools/pvresize.c	2010/10/25 12:01:38	1.36
+++ LVM2/tools/pvresize.c	2010/12/08 20:50:51	1.37
@@ -58,7 +58,7 @@
 		vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 
 		if (vg_read_error(vg)) {
-			vg_release(vg);
+			free_vg(vg);
 			log_error("Unable to read volume group \"%s\".",
 				  vg_name);
 			return 0;
@@ -164,7 +164,7 @@
 out:
 	unlock_vg(cmd, vg_name);
 	if (!old_vg)
-		vg_release(vg);
+		free_vg(vg);
 	return r;
 }
 
--- LVM2/tools/reporter.c	2010/11/17 22:26:42	1.63
+++ LVM2/tools/reporter.c	2010/12/08 20:50:51	1.64
@@ -65,7 +65,7 @@
 	};
 
         if (!(_free_vg.vgmem = dm_pool_create("_free_vg", 10240)))
-            return ECMD_FAILED;
+		return ECMD_FAILED;
 
 	struct logical_volume _free_logical_volume = {
 		.vg = vg ?: &_free_vg,
@@ -110,7 +110,7 @@
                 goto_out;
 	}
  out:
-        dm_pool_destroy(_free_vg.vgmem);
+	free_vg(&_free_vg);
 	return ret;
 }
 
@@ -145,7 +145,7 @@
 		vg = vg_read(cmd, vg_name, (char *)&pv->vgid, 0);
 		if (vg_read_error(vg)) {
 			log_error("Skipping volume group %s", vg_name);
-			vg_release(vg);
+			free_vg(vg);
 			return ECMD_FAILED;
 		}
 
@@ -185,7 +185,7 @@
 		unlock_vg(cmd, vg_name);
 
 	if (!old_vg)
-		vg_release(vg);
+		free_vg(vg);
 
 	return ret;
 }
--- LVM2/tools/toollib.c	2010/12/01 12:22:49	1.216
+++ LVM2/tools/toollib.c	2010/12/08 20:50:51	1.217
@@ -311,7 +311,7 @@
 		}
 
 		if (!cmd_vg_read(cmd, &cmd_vgs)) {
-			cmd_vg_release(&cmd_vgs);
+			free_cmd_vgs(&cmd_vgs);
 			if (ret_max < ECMD_FAILED) {
 				log_error("Skipping volume group %s", vgname);
 				ret_max = ECMD_FAILED;
@@ -337,7 +337,7 @@
 						  dm_pool_strdup(cmd->mem,
 								 lv_name + 1))) {
 					log_error("strlist allocation failed");
-					cmd_vg_release(&cmd_vgs);
+					free_cmd_vgs(&cmd_vgs);
 					return ECMD_FAILED;
 				}
 			}
@@ -355,7 +355,7 @@
 			dm_list_init(&lvnames);
 			dm_list_splice(&lvnames, &failed_lvnames);
 
-			cmd_vg_release(&cmd_vgs);
+			free_cmd_vgs(&cmd_vgs);
 			if (!cmd_vg_read(cmd, &cmd_vgs)) {
 				ret = ECMD_FAILED; /* break */
 				break;
@@ -364,7 +364,7 @@
 		if (ret > ret_max)
 			ret_max = ret;
 
-		cmd_vg_release(&cmd_vgs);
+		free_cmd_vgs(&cmd_vgs);
 		/* FIXME: logic for breaking command is not consistent */
 		if (sigint_caught())
 			return ECMD_FAILED;
@@ -392,7 +392,7 @@
 
 		vg = vg_read(cmd, vg_name, NULL, 0);
 		if (vg_read_error(vg)) {
-			vg_release(vg);
+			free_vg(vg);
 			log_error("Skipping volume group %s", vg_name);
 			return ECMD_FAILED;
 		}
@@ -404,7 +404,7 @@
 		if (!(pvl = find_pv_in_vg(vg, pv_dev_name(pv)))) {
 			 log_error("Unable to find %s in volume group %s",
 				   pv_dev_name(pv), vg_name);
-			 unlock_and_release_vg(cmd, vg, vg_name);
+			 unlock_and_free_vg(cmd, vg, vg_name);
 			 return ECMD_FAILED;
 		}
 
@@ -427,7 +427,7 @@
 	if (vg_name)
 		unlock_vg(cmd, vg_name);
 	if (!old_vg)
-		vg_release(vg);
+		free_vg(vg);
 
 	return ret_max;
 }
@@ -498,10 +498,10 @@
 		if (!cvl_vg->vg->cmd_missing_vgs)
 			break;
 
-		cmd_vg_release(&cmd_vgs);
+		free_cmd_vgs(&cmd_vgs);
 	}
 
-	cmd_vg_release(&cmd_vgs);
+	free_cmd_vgs(&cmd_vgs);
 
 	return (ret > ret_max) ? ret : ret_max;
 }
@@ -774,7 +774,7 @@
 				vg = vg_read(cmd, sll->str, NULL, flags);
 				if (vg_read_error(vg)) {
 					ret_max = ECMD_FAILED;
-					vg_release(vg);
+					free_vg(vg);
 					stack;
 					continue;
 				}
@@ -783,7 +783,7 @@
 							    handle,
 							    process_single_pv);
 
-				unlock_and_release_vg(cmd, vg, sll->str);
+				unlock_and_free_vg(cmd, vg, sll->str);
 
 				if (ret > ret_max)
 					ret_max = ret;
--- LVM2/tools/vgcreate.c	2010/11/11 17:29:06	1.81
+++ LVM2/tools/vgcreate.c	2010/12/08 20:50:51	1.82
@@ -56,7 +56,7 @@
 			log_error("A volume group called %s already exists.", vp_new.vg_name);
 		else
 			log_error("Can't get lock for %s.", vp_new.vg_name);
-		vg_release(vg);
+		free_vg(vg);
 		return ECMD_FAILED;
 	}
 
@@ -120,13 +120,13 @@
 	log_print("%s%colume group \"%s\" successfully created",
 		  clustered_message, *clustered_message ? 'v' : 'V', vg->name);
 
-	vg_release(vg);
+	free_vg(vg);
 	return ECMD_PROCESSED;
 
 bad:
 	unlock_vg(cmd, VG_ORPHANS);
 bad_orphan:
-	vg_release(vg);
+	free_vg(vg);
 	unlock_vg(cmd, vp_new.vg_name);
 	return ECMD_FAILED;
 }
--- LVM2/tools/vgextend.c	2010/10/18 17:27:10	1.61
+++ LVM2/tools/vgextend.c	2010/12/08 20:50:51	1.62
@@ -72,7 +72,7 @@
 	log_verbose("Checking for volume group \"%s\"", vg_name);
 	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
-		vg_release(vg);
+		free_vg(vg);
 		stack;
 		return ECMD_FAILED;
 	}
@@ -92,7 +92,7 @@
 	} else { /* no --restore, normal vgextend */
 		if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 			log_error("Can't get lock for orphan PVs");
-			unlock_and_release_vg(cmd, vg, vg_name);
+			unlock_and_free_vg(cmd, vg, vg_name);
 			return ECMD_FAILED;
 		}
 
@@ -135,6 +135,6 @@
 bad:
 	if (!arg_count(cmd, restoremissing_ARG))
 		unlock_vg(cmd, VG_ORPHANS);
-	unlock_and_release_vg(cmd, vg, vg_name);
+	unlock_and_free_vg(cmd, vg, vg_name);
 	return r;
 }
--- LVM2/tools/vgmerge.c	2010/07/09 15:34:48	1.69
+++ LVM2/tools/vgmerge.c	2010/12/08 20:50:51	1.70
@@ -22,7 +22,7 @@
 	log_verbose("Checking for volume group \"%s\"", vg_name);
 	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
-		vg_release(vg);
+		free_vg(vg);
 		return NULL;
 	}
 	return vg;
@@ -54,7 +54,7 @@
 		vg_to = _vgmerge_vg_read(cmd, vg_name_to);
 		if (!vg_to) {
 			stack;
-			unlock_and_release_vg(cmd, vg_from, vg_name_from);
+			unlock_and_free_vg(cmd, vg_from, vg_name_from);
 			return ECMD_FAILED;
 		}
 	} else {
@@ -67,7 +67,7 @@
 		vg_from = _vgmerge_vg_read(cmd, vg_name_from);
 		if (!vg_from) {
 			stack;
-			unlock_and_release_vg(cmd, vg_to, vg_name_to);
+			unlock_and_free_vg(cmd, vg_to, vg_name_to);
 			return ECMD_FAILED;
 		}
 	}
@@ -148,11 +148,11 @@
 	r = ECMD_PROCESSED;
 bad:
 	if (lock_vg_from_first) {
-		unlock_and_release_vg(cmd, vg_to, vg_name_to);
-		unlock_and_release_vg(cmd, vg_from, vg_name_from);
+		unlock_and_free_vg(cmd, vg_to, vg_name_to);
+		unlock_and_free_vg(cmd, vg_from, vg_name_from);
 	} else {
-		unlock_and_release_vg(cmd, vg_from, vg_name_from);
-		unlock_and_release_vg(cmd, vg_to, vg_name_to);
+		unlock_and_free_vg(cmd, vg_from, vg_name_from);
+		unlock_and_free_vg(cmd, vg_to, vg_name_to);
 	}
 	return r;
 }
--- LVM2/tools/vgreduce.c	2010/08/17 16:25:35	1.104
+++ LVM2/tools/vgreduce.c	2010/12/08 20:50:51	1.105
@@ -450,7 +450,7 @@
 	log_print("Removed \"%s\" from volume group \"%s\"", name, vg->name);
 	r = ECMD_PROCESSED;
 bad:
-	unlock_and_release_vg(cmd, orphan_vg, VG_ORPHANS);
+	unlock_and_free_vg(cmd, orphan_vg, VG_ORPHANS);
 	return r;
 }
 
@@ -524,7 +524,7 @@
 			goto out;
 		}
 
-		vg_release(vg);
+		free_vg(vg);
 		log_verbose("Trying to open VG %s for recovery...", vg_name);
 
 		vg = vg_read_for_update(cmd, vg_name, NULL,
@@ -570,7 +570,7 @@
 	}
 out:
 	init_ignore_suspended_devices(saved_ignore_suspended_devices);
-	unlock_and_release_vg(cmd, vg, vg_name);
+	unlock_and_free_vg(cmd, vg, vg_name);
 
 	return ret;
 
--- LVM2/tools/vgrename.c	2010/04/14 13:03:06	1.72
+++ LVM2/tools/vgrename.c	2010/12/08 20:50:51	1.73
@@ -25,7 +25,7 @@
 	   nevertheless. */
 	vg = vg_read_for_update(cmd, vg_name_old, vgid, READ_ALLOW_EXPORTED);
 	if (vg_read_error(vg)) {
-		vg_release(vg);
+		free_vg(vg);
 		return_NULL;
 	}
 
@@ -117,7 +117,7 @@
 			return_0;
 
 		if (!_lock_new_vg_for_rename(cmd, vg_name_new)) {
-			unlock_and_release_vg(cmd, vg, vg_name_old);
+			unlock_and_free_vg(cmd, vg, vg_name_old);
 			return_0;
 		}
 	} else {
@@ -168,7 +168,7 @@
 	backup_remove(cmd, vg_name_old);
 
 	unlock_vg(cmd, vg_name_new);
-	unlock_and_release_vg(cmd, vg, vg_name_old);
+	unlock_and_free_vg(cmd, vg, vg_name_old);
 
 	log_print("Volume group \"%s\" successfully renamed to \"%s\"",
 		  vg_name_old, vg_name_new);
@@ -182,9 +182,9 @@
       error:
 	if (lock_vg_old_first) {
 		unlock_vg(cmd, vg_name_new);
-		unlock_and_release_vg(cmd, vg, vg_name_old);
+		unlock_and_free_vg(cmd, vg, vg_name_old);
 	} else {
-		unlock_and_release_vg(cmd, vg, vg_name_old);
+		unlock_and_free_vg(cmd, vg, vg_name_old);
 		unlock_vg(cmd, vg_name_new);
 	}
 	return 0;
--- LVM2/tools/vgsplit.c	2010/09/23 12:02:34	1.102
+++ LVM2/tools/vgsplit.c	2010/12/08 20:50:51	1.103
@@ -223,16 +223,16 @@
 	vg_to = vg_create(cmd, vg_name_to);
 	if (vg_read_error(vg_to) == FAILED_LOCKING) {
 		log_error("Can't get lock for %s", vg_name_to);
-		vg_release(vg_to);
+		free_vg(vg_to);
 		return NULL;
 	}
 	if (vg_read_error(vg_to) == FAILED_EXIST) {
 		*existing_vg = 1;
-		vg_release(vg_to);
+		free_vg(vg_to);
 		vg_to = vg_read_for_update(cmd, vg_name_to, NULL, 0);
 
 		if (vg_read_error(vg_to)) {
-			vg_release(vg_to);
+			free_vg(vg_to);
 			stack;
 			return NULL;
 		}
@@ -258,7 +258,7 @@
 
 	vg_from = vg_read_for_update(cmd, vg_name_from, NULL, 0);
 	if (vg_read_error(vg_from)) {
-		vg_release(vg_from);
+		free_vg(vg_from);
 		return NULL;
 	}
 	return vg_from;
@@ -333,7 +333,7 @@
 
 		vg_to = _vgsplit_to(cmd, vg_name_to, &existing_vg);
 		if (!vg_to) {
-			unlock_and_release_vg(cmd, vg_from, vg_name_from);
+			unlock_and_free_vg(cmd, vg_from, vg_name_from);
 			stack;
 			return ECMD_FAILED;
 		}
@@ -345,7 +345,7 @@
 		}
 		vg_from = _vgsplit_from(cmd, vg_name_from);
 		if (!vg_from) {
-			unlock_and_release_vg(cmd, vg_to, vg_name_to);
+			unlock_and_free_vg(cmd, vg_to, vg_name_to);
 			stack;
 			return ECMD_FAILED;
 		}
@@ -462,7 +462,7 @@
 	 * Finally, remove the EXPORTED flag from the new VG and write it out.
 	 */
 	if (!test_mode()) {
-		vg_release(vg_to);
+		free_vg(vg_to);
 		vg_to = vg_read_for_update(cmd, vg_name_to, NULL,
 					   READ_ALLOW_EXPORTED);
 		if (vg_read_error(vg_to)) {
@@ -487,11 +487,11 @@
 
 bad:
 	if (lock_vg_from_first) {
-		unlock_and_release_vg(cmd, vg_to, vg_name_to);
-		unlock_and_release_vg(cmd, vg_from, vg_name_from);
+		unlock_and_free_vg(cmd, vg_to, vg_name_to);
+		unlock_and_free_vg(cmd, vg_from, vg_name_from);
 	} else {
-		unlock_and_release_vg(cmd, vg_from, vg_name_from);
-		unlock_and_release_vg(cmd, vg_to, vg_name_to);
+		unlock_and_free_vg(cmd, vg_from, vg_name_from);
+		unlock_and_free_vg(cmd, vg_to, vg_name_to);
 	}
 	return r;
 }


