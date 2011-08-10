From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Aug 2011 20:25:36 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20110810202536.20988.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-08-10 20:25:31

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	lib/activate   : activate.c 
	lib/cache      : lvmcache.c 
	lib/format_pool: format_pool.c 
	lib/format_text: archive.c archiver.c format-text.c 
	                 import_vsn1.c 
	lib/locking    : locking.h 
	lib/metadata   : metadata-exported.h metadata.c 
	                 replicator_manip.c vg.c vg.h 
	liblvm         : lvm_vg.c 
	tools          : lvconvert.c lvcreate.c lvrename.c lvresize.c 
	                 polldaemon.c pvchange.c pvcreate.c pvdisplay.c 
	                 pvmove.c pvresize.c reporter.c toollib.c 
	                 vgcreate.c vgextend.c vgmerge.c vgreduce.c 
	                 vgrename.c vgsplit.c 

Log message:
	Replace free_vg with release_vg
	
	Move the free_vg() to  vg.c  and replace free_vg  with release_vg
	and make the _free_vg internal.
	
	Patch is needed for sharing VG in vginfo cache so the release_vg function name
	is a better fit here.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2057&r2=1.2058
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.121&r2=1.122
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.209&r2=1.210
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.112&r2=1.113
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archive.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.182&r2=1.183
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.89&r2=1.90
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.195&r2=1.196
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.461&r2=1.462
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/replicator_manip.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.h.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.166&r2=1.167
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.232&r2=1.233
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvrename.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.133&r2=1.134
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.95&r2=1.96
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.227&r2=1.228
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.112&r2=1.113
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.107&r2=1.108

--- LVM2/WHATS_NEW	2011/08/10 20:17:33	1.2057
+++ LVM2/WHATS_NEW	2011/08/10 20:25:29	1.2058
@@ -1,5 +1,6 @@
 Version 2.02.87 - 
 ===============================
+  Replace free_vg with release_vg and move it to vg.c.
   Remove INCONSISTENT_VG flag from the code.
   Remove lock from cache even if unlock fails.
   Initialise clvmd locks before lvm context to avoid open descriptor leaks.
--- LVM2/daemons/clvmd/lvm-functions.c	2011/08/10 11:00:32	1.121
+++ LVM2/daemons/clvmd/lvm-functions.c	2011/08/10 20:25:29	1.122
@@ -840,7 +840,7 @@
 	else
 		log_error("Error backing up metadata, can't find VG for group %s", vgname);
 
-	free_vg(vg);
+	release_vg(vg);
 	dm_pool_empty(cmd->mem);
 
 	pthread_mutex_unlock(&lvm_lock);
--- LVM2/lib/activate/activate.c	2011/07/08 15:35:50	1.209
+++ LVM2/lib/activate/activate.c	2011/08/10 20:25:29	1.210
@@ -521,7 +521,7 @@
 		origin_only = 0;
 
 	r = lv_info(cmd, lv, origin_only, info, with_open_count, with_read_ahead);
-	free_vg(lv->vg);
+	release_vg(lv->vg);
 
 	return r;
 }
@@ -1267,10 +1267,10 @@
 	r = 1;
 out:
 	if (lv_pre)
-		free_vg(lv_pre->vg);
+		release_vg(lv_pre->vg);
 	if (lv) {
 		lv_release_replicator_vgs(lv);
-		free_vg(lv->vg);
+		release_vg(lv->vg);
 	}
 
 	return r;
@@ -1351,7 +1351,7 @@
 	r = 1;
 out:
 	if (lv)
-		free_vg(lv->vg);
+		release_vg(lv->vg);
 
 	return r;
 }
@@ -1458,7 +1458,7 @@
 out:
 	if (lv) {
 		lv_release_replicator_vgs(lv);
-		free_vg(lv->vg);
+		release_vg(lv->vg);
 	}
 
 	return r;
@@ -1488,7 +1488,7 @@
 	r = 1;
 out:
 	if (lv)
-		free_vg(lv->vg);
+		release_vg(lv->vg);
 
 	return r;
 }
@@ -1557,7 +1557,7 @@
 out:
 	if (lv) {
 		lv_release_replicator_vgs(lv);
-		free_vg(lv->vg);
+		release_vg(lv->vg);
 	}
 
 	return r;
--- LVM2/lib/cache/lvmcache.c	2011/07/18 13:26:08	1.112
+++ LVM2/lib/cache/lvmcache.c	2011/08/10 20:25:30	1.113
@@ -683,7 +683,7 @@
 	return vg;
 
 bad:
-	free_vg(vg);
+	release_vg(vg);
 	_free_cached_vgmetadata(vginfo);
 	return NULL;
 }
--- LVM2/lib/format_pool/format_pool.c	2011/03/11 15:10:16	1.44
+++ LVM2/lib/format_pool/format_pool.c	2011/08/10 20:25:30	1.45
@@ -156,7 +156,7 @@
 	return vg;
 
 bad:
-	free_vg(vg);
+	release_vg(vg);
 
 	return NULL;
 }
--- LVM2/lib/format_text/archive.c	2011/03/11 15:08:32	1.43
+++ LVM2/lib/format_text/archive.c	2011/08/10 20:25:30	1.44
@@ -332,7 +332,7 @@
 	log_print("Description:\t%s", desc ? : "<No description>");
 	log_print("Backup Time:\t%s", ctime(&when));
 
-	free_vg(vg);
+	release_vg(vg);
 }
 
 int archive_list(struct cmd_context *cmd, const char *dir, const char *vgname)
--- LVM2/lib/format_text/archiver.c	2011/03/11 15:08:32	1.46
+++ LVM2/lib/format_text/archiver.c	2011/08/10 20:25:30	1.47
@@ -362,7 +362,7 @@
 		log_error("Cannot restore Volume Group %s with %i PVs "
 			  "marked as missing.", vg->name, missing_pvs);
 
-	free_vg(vg);
+	release_vg(vg);
 	return r;
 }
 
@@ -447,7 +447,7 @@
 	    (vg->seqno == vg_backup->seqno) &&
 	    (id_equal(&vg->id, &vg_backup->id))) {
 		log_suppress(old_suppress);
-		free_vg(vg_backup);
+		release_vg(vg_backup);
 		return;
 	}
 	log_suppress(old_suppress);
@@ -455,7 +455,7 @@
 	if (vg_backup) {
 		if (!archive(vg_backup))
 			stack;
-		free_vg(vg_backup);
+		release_vg(vg_backup);
 	}
 	if (!archive(vg))
 		stack;
--- LVM2/lib/format_text/format-text.c	2011/06/15 17:45:02	1.182
+++ LVM2/lib/format_text/format-text.c	2011/08/10 20:25:30	1.183
@@ -855,7 +855,7 @@
 	 * check that it contains the correct volume group.
 	 */
 	if (vgname && strcmp(vgname, vg->name)) {
-		free_vg(vg);
+		release_vg(vg);
 		log_error("'%s' does not contain volume group '%s'.",
 			  read_path, vgname);
 		return NULL;
@@ -1091,7 +1091,7 @@
 							     path))) {
 					/* FIXME Store creation host in vg */
 					lvmcache_update_vg(vg, 0);
-					free_vg(vg);
+					release_vg(vg);
 				}
 			}
 
--- LVM2/lib/format_text/import_vsn1.c	2011/08/02 22:07:22	1.89
+++ LVM2/lib/format_text/import_vsn1.c	2011/08/10 20:25:30	1.90
@@ -814,7 +814,7 @@
 	if (lv_hash)
 		dm_hash_destroy(lv_hash);
 
-	free_vg(vg);
+	release_vg(vg);
 	return NULL;
 }
 
--- LVM2/lib/locking/locking.h	2011/06/01 21:16:56	1.66
+++ LVM2/lib/locking/locking.h	2011/08/10 20:25:30	1.67
@@ -156,10 +156,10 @@
 			sync_dev_names(cmd); \
 		lock_vol(cmd, vol, LCK_VG_UNLOCK); \
 	} while (0)
-#define unlock_and_free_vg(cmd, vg, vol) \
+#define unlock_and_release_vg(cmd, vg, vol) \
 	do { \
 		unlock_vg(cmd, vol); \
-		free_vg(vg); \
+		release_vg(vg); \
 	} while (0)
 
 #define resume_lv(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_RESUME)
--- LVM2/lib/metadata/metadata-exported.h	2011/08/02 22:07:22	1.195
+++ LVM2/lib/metadata/metadata-exported.h	2011/08/10 20:25:30	1.196
@@ -479,12 +479,6 @@
  */
 void free_pv_fid(struct physical_volume *pv);
 
-/*
- * free_vg() must be called on every struct volume_group allocated
- * by vg_create() or vg_read_internal() to free it when no longer required.
- */
-void free_vg(struct volume_group *vg);
-
 /* Manipulate LVs */
 struct logical_volume *lv_create_empty(const char *name,
 				       union lvid *lvid,
--- LVM2/lib/metadata/metadata.c	2011/08/10 20:17:33	1.461
+++ LVM2/lib/metadata/metadata.c	2011/08/10 20:25:30	1.462
@@ -374,7 +374,7 @@
 		}
 	}
 out:
-	free_vg(vg);
+	release_vg(vg);
 	return r;
 }
 
@@ -928,7 +928,7 @@
 	/* is this vg name already in use ? */
 	if ((vg = vg_read_internal(cmd, vg_name, NULL, 1, &consistent))) {
 		log_error("A volume group called '%s' already exists.", vg_name);
-		unlock_and_free_vg(cmd, vg, vg_name);
+		unlock_and_release_vg(cmd, vg, vg_name);
 		return _vg_make_handle(cmd, NULL, FAILED_EXIST);
 	}
 
@@ -980,7 +980,7 @@
 	return _vg_make_handle(cmd, vg, SUCCESS);
 
 bad:
-	unlock_and_free_vg(cmd, vg, vg_name);
+	unlock_and_release_vg(cmd, vg, vg_name);
 	/* FIXME: use _vg_make_handle() w/proper error code */
 	return NULL;
 }
@@ -2730,7 +2730,7 @@
 	return vg;
 bad:
 	free_pv_fid(pv);
-	free_vg(vg);
+	release_vg(vg);
 	return NULL;
 }
 
@@ -2865,7 +2865,7 @@
 		*consistent = 1;
 		return correct_vg;
 	} else {
-		free_vg(correct_vg);
+		release_vg(correct_vg);
 		correct_vg = NULL;
 	}
 
@@ -2911,7 +2911,7 @@
 		    (!use_precommitted &&
 		     !(vg = mda->ops->vg_read(fid, vgname, mda)))) {
 			inconsistent = 1;
-			free_vg(vg);
+			release_vg(vg);
 			continue;
 		}
 
@@ -2930,7 +2930,7 @@
 				inconsistent = 1;
 
 			if (vg->seqno > correct_vg->seqno) {
-				free_vg(correct_vg);
+				release_vg(correct_vg);
 				correct_vg = vg;
 			} else {
 				mda->status |= MDA_INCONSISTENT;
@@ -2939,7 +2939,7 @@
 		}
 
 		if (vg != correct_vg)
-			free_vg(vg);
+			release_vg(vg);
 	}
 
 	/* Ensure every PV in the VG was in the cache */
@@ -3015,7 +3015,7 @@
 			if (critical_section())
 				inconsistent = 1;
 			else {
-				free_vg(correct_vg);
+				release_vg(correct_vg);
 				correct_vg = NULL;
 			}
 		} else dm_list_iterate_items(pvl, &correct_vg->pvs) {
@@ -3024,14 +3024,14 @@
 			if (!str_list_match_item(pvids, pvl->pv->dev->pvid)) {
 				log_debug("Cached VG %s had incorrect PV list",
 					  vgname);
-				free_vg(correct_vg);
+				release_vg(correct_vg);
 				correct_vg = NULL;
 				break;
 			}
 		}
 
 		if (correct_vg && inconsistent_mdas) {
-			free_vg(correct_vg);
+			release_vg(correct_vg);
 			correct_vg = NULL;
 		}
 	}
@@ -3076,7 +3076,7 @@
 				correct_vg = vg;
 				if (!_update_pv_list(cmd->mem, &all_pvs, correct_vg)) {
 					_free_pv_list(&all_pvs);
-					free_vg(vg);
+					release_vg(vg);
 					return_NULL;
 				}
 				continue;
@@ -3099,12 +3099,12 @@
 
 				if (!_update_pv_list(cmd->mem, &all_pvs, vg)) {
 					_free_pv_list(&all_pvs);
-					free_vg(vg);
-					free_vg(correct_vg);
+					release_vg(vg);
+					release_vg(correct_vg);
 					return_NULL;
 				}
 				if (vg->seqno > correct_vg->seqno) {
-					free_vg(correct_vg);
+					release_vg(correct_vg);
 					correct_vg = vg;
 				} else {
 					mda->status |= MDA_INCONSISTENT;
@@ -3113,7 +3113,7 @@
 			}
 
 			if (vg != correct_vg)
-				free_vg(vg);
+				release_vg(vg);
 		}
 
 		/* Give up looking */
@@ -3159,7 +3159,7 @@
 				return correct_vg;
 			}
 			_free_pv_list(&all_pvs);
-			free_vg(correct_vg);
+			release_vg(correct_vg);
 			return NULL;
 		}
 
@@ -3191,7 +3191,7 @@
 		if (!vg_write(correct_vg)) {
 			log_error("Automatic metadata correction failed");
 			_free_pv_list(&all_pvs);
-			free_vg(correct_vg);
+			release_vg(correct_vg);
 			cmd->handles_missing_pvs = saved_handles_missing_pvs;
 			return NULL;
 		}
@@ -3200,7 +3200,7 @@
 		if (!vg_commit(correct_vg)) {
 			log_error("Automatic metadata correction commit "
 				  "failed");
-			free_vg(correct_vg);
+			release_vg(correct_vg);
 			return NULL;
 		}
 
@@ -3211,14 +3211,14 @@
 			}
 			if (!id_write_format(&pvl->pv->id, uuid, sizeof(uuid))) {
 				_free_pv_list(&all_pvs);
-				free_vg(correct_vg);
+				release_vg(correct_vg);
 				return_NULL;
 			}
 			log_error("Removing PV %s (%s) that no longer belongs to VG %s",
 				  pv_dev_name(pvl->pv), uuid, correct_vg->name);
 			if (!pv_write_orphan(cmd, pvl->pv)) {
 				_free_pv_list(&all_pvs);
-				free_vg(correct_vg);
+				release_vg(correct_vg);
 				return_NULL;
 			}
 
@@ -3242,7 +3242,7 @@
 			  "volume group %s", correct_vg->name);
 		log_error("Please restore the metadata by running "
 			  "vgcfgrestore.");
-		free_vg(correct_vg);
+		release_vg(correct_vg);
 		return NULL;
 	}
 
@@ -3262,7 +3262,7 @@
 	if (!check_pv_segments(vg)) {
 		log_error(INTERNAL_ERROR "PV segments corrupted in %s.",
 			  vg->name);
-		free_vg(vg);
+		release_vg(vg);
 		return NULL;
 	}
 
@@ -3270,7 +3270,7 @@
 		if (!check_lv_segments(lvl->lv, 0)) {
 			log_error(INTERNAL_ERROR "LV segments corrupted in %s.",
 				  lvl->lv->name);
-			free_vg(vg);
+			release_vg(vg);
 			return NULL;
 		}
 	}
@@ -3282,7 +3282,7 @@
 		if (!check_lv_segments(lvl->lv, 1)) {
 			log_error(INTERNAL_ERROR "LV segments corrupted in %s.",
 				  lvl->lv->name);
-			free_vg(vg);
+			release_vg(vg);
 			return NULL;
 		}
 	}
@@ -3299,22 +3299,6 @@
 		pv->fid->fmt->ops->destroy_instance(pv->fid);
 }
 
-void free_vg(struct volume_group *vg)
-{
-	if (!vg)
-		return;
-
-	vg_set_fid(vg, NULL);
-
-	if (vg->cmd && vg->vgmem == vg->cmd->mem) {
-		log_error(INTERNAL_ERROR "global memory pool used for VG %s",
-			  vg->name);
-		return;
-	}
-
-	dm_pool_destroy(vg->vgmem);
-}
-
 /* This is only called by lv_from_lvid, which is only called from
  * activate.c so we know the appropriate VG lock is already held and
  * the vg_read_internal is therefore safe.
@@ -3341,7 +3325,7 @@
 					  "inconsistent", vg->name);
 			return vg;
 		}
-		free_vg(vg);
+		release_vg(vg);
 	}
 
 	/* Mustn't scan if memory locked: ensure cache gets pre-populated! */
@@ -3370,12 +3354,12 @@
 			if (!consistent) {
 				log_error("Volume group %s metadata is "
 					  "inconsistent", vgname);
-				free_vg(vg);
+				release_vg(vg);
 				return NULL;
 			}
 			return vg;
 		}
-		free_vg(vg);
+		release_vg(vg);
 	}
 
 	return NULL;
@@ -3409,7 +3393,7 @@
 
 	return lvl->lv;
 out:
-	free_vg(vg);
+	release_vg(vg);
 	return NULL;
 }
 
@@ -3616,12 +3600,12 @@
 			dm_list_iterate_items(pvl, &vg->pvs) {
 				if (!(pvl_copy = _copy_pvl(cmd->mem, pvl))) {
 					log_error("PV list allocation failed");
-					free_vg(vg);
+					release_vg(vg);
 					return 0;
 				}
 				dm_list_add(results, &pvl_copy->list);
 			}
-		free_vg(vg);
+		release_vg(vg);
 	}
 	init_pvmove(old_pvmove);
 
@@ -3838,7 +3822,7 @@
 		return_NULL;
 
 	if (!consistent) {
-		free_vg(vg);
+		release_vg(vg);
 		return_NULL;
 	}
 
@@ -3910,7 +3894,7 @@
 
 	/* consistent == 0 when VG is not found, but failed == FAILED_NOTFOUND */
 	if (!consistent && !failure) {
-		free_vg(vg);
+		release_vg(vg);
 		if (!(vg = _recover_vg(cmd, vg_name, vgid))) {
 			log_error("Recovery of volume group \"%s\" failed.",
 				  vg_name);
--- LVM2/lib/metadata/replicator_manip.c	2010/12/08 20:50:50	1.7
+++ LVM2/lib/metadata/replicator_manip.c	2011/08/10 20:25:30	1.8
@@ -597,9 +597,9 @@
 	/* Backward iterate cmd_vg list */
 	dm_list_iterate_back_items(cvl, cmd_vgs) {
 		if (vg_read_error(cvl->vg))
-			free_vg(cvl->vg);
+			release_vg(cvl->vg);
 		else
-			unlock_and_free_vg(cvl->vg->cmd, cvl->vg, cvl->vg_name);
+			unlock_and_release_vg(cvl->vg->cmd, cvl->vg, cvl->vg_name);
 		cvl->vg = NULL;
 	}
 }
@@ -687,7 +687,7 @@
 
 	dm_list_iterate_back_items(rsite, &first_seg(lv)->replicator->rsites)
 		if (rsite->vg_name && rsite->vg) {
-			free_vg(rsite->vg);
+			release_vg(rsite->vg);
 			rsite->vg = NULL;
 		}
 }
--- LVM2/lib/metadata/vg.c	2011/06/01 19:29:33	1.10
+++ LVM2/lib/metadata/vg.c	2011/08/10 20:25:30	1.11
@@ -17,6 +17,7 @@
 #include "metadata.h"
 #include "display.h"
 #include "activate.h"
+#include "toolcontext.h"
 
 struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 			      const char *vg_name)
@@ -51,6 +52,27 @@
 	return vg;
 }
 
+static void _free_vg(struct volume_group *vg)
+{
+	vg_set_fid(vg, NULL);
+
+	if (vg->cmd && vg->vgmem == vg->cmd->mem) {
+		log_error(INTERNAL_ERROR "global memory pool used for VG %s",
+			  vg->name);
+		return;
+	}
+
+	dm_pool_destroy(vg->vgmem);
+}
+
+void release_vg(struct volume_group *vg)
+{
+	if (!vg)
+		return;
+
+	_free_vg(vg);
+}
+
 char *vg_fmt_dup(const struct volume_group *vg)
 {
 	if (!vg->fid || !vg->fid->fmt)
--- LVM2/lib/metadata/vg.h	2011/06/01 19:29:33	1.12
+++ LVM2/lib/metadata/vg.h	2011/08/10 20:25:30	1.13
@@ -111,6 +111,12 @@
 struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 			      const char *vg_name);
 
+/*
+ * release_vg() must be called on every struct volume_group allocated
+ * by vg_create() or vg_read_internal() to free it when no longer required.
+ */
+void release_vg(struct volume_group *vg);
+
 char *vg_fmt_dup(const struct volume_group *vg);
 char *vg_name_dup(const struct volume_group *vg);
 char *vg_system_id_dup(const struct volume_group *vg);
--- LVM2/liblvm/lvm_vg.c	2011/04/01 13:44:51	1.52
+++ LVM2/liblvm/lvm_vg.c	2011/08/10 20:25:30	1.53
@@ -56,7 +56,7 @@
 	vg = vg_create((struct cmd_context *)libh, vg_name);
 	/* FIXME: error handling is still TBD */
 	if (vg_read_error(vg)) {
-		free_vg(vg);
+		release_vg(vg);
 		return NULL;
 	}
 	vg->open_mode = 'w';
@@ -160,9 +160,9 @@
 int lvm_vg_close(vg_t vg)
 {
 	if (vg_read_error(vg) == FAILED_LOCKING)
-		free_vg(vg);
+		release_vg(vg);
 	else
-		unlock_and_free_vg(vg->cmd, vg, vg->name);
+		unlock_and_release_vg(vg->cmd, vg, vg->name);
 	return 0;
 }
 
@@ -197,7 +197,7 @@
 	vg = vg_read((struct cmd_context *)libh, vgname, NULL, internal_flags);
 	if (vg_read_error(vg)) {
 		/* FIXME: use log_errno either here in inside vg_read */
-		free_vg(vg);
+		release_vg(vg);
 		return NULL;
 	}
 	/* FIXME: combine this with locking ? */
--- LVM2/tools/lvconvert.c	2011/07/08 19:42:11	1.166
+++ LVM2/tools/lvconvert.c	2011/08/10 20:25:31	1.167
@@ -1615,7 +1615,7 @@
 {
 	/*
 	 * Returns NULL if the requested LV doesn't exist;
-	 * otherwise the caller must free_vg(lv->vg)
+	 * otherwise the caller must release_vg(lv->vg)
 	 * - it is also up to the caller to unlock_vg() as needed
 	 */
 	struct volume_group *vg;
@@ -1623,13 +1623,13 @@
 
 	vg = _get_lvconvert_vg(cmd, vg_name, NULL);
 	if (vg_read_error(vg)) {
-		free_vg(vg);
+		release_vg(vg);
 		return_NULL;
 	}
 
 	if (!(lv = _get_lvconvert_lv(cmd, vg, lv_name, NULL, 0))) {
 		log_error("Can't find LV %s in VG %s", lv_name, vg_name);
-		unlock_and_free_vg(cmd, vg, vg_name);
+		unlock_and_release_vg(cmd, vg, vg_name);
 		return NULL;
 	}
 
@@ -1682,7 +1682,7 @@
 		ret = poll_logical_volume(cmd, lp->lv_to_poll,
 					  lp->wait_completion);
 
-	free_vg(lv->vg);
+	release_vg(lv->vg);
 out:
 	init_ignore_suspended_devices(saved_ignore_suspended_devices);
 	return ret;
@@ -1732,7 +1732,7 @@
 		}
 	}
 
-	free_vg(refreshed_lv->vg);
+	release_vg(refreshed_lv->vg);
 
 	return ret;
 }
--- LVM2/tools/lvcreate.c	2011/08/02 22:07:23	1.232
+++ LVM2/tools/lvcreate.c	2011/08/10 20:25:31	1.233
@@ -600,7 +600,7 @@
 	log_verbose("Finding volume group \"%s\"", lp.vg_name);
 	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
-		free_vg(vg);
+		release_vg(vg);
 		stack;
 		return ECMD_FAILED;
 	}
@@ -615,6 +615,6 @@
 		r = ECMD_FAILED;
 	}
 out:
-	unlock_and_free_vg(cmd, vg, lp.vg_name);
+	unlock_and_release_vg(cmd, vg, lp.vg_name);
 	return r;
 }
--- LVM2/tools/lvrename.c	2010/12/08 20:50:51	1.57
+++ LVM2/tools/lvrename.c	2011/08/10 20:25:31	1.58
@@ -104,7 +104,7 @@
 	log_verbose("Checking for existing volume group \"%s\"", vg_name);
 	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
-		free_vg(vg);
+		release_vg(vg);
 		stack;
 		return ECMD_FAILED;
 	}
@@ -123,6 +123,6 @@
 
 	r = ECMD_PROCESSED;
 error:
-	unlock_and_free_vg(cmd, vg, vg_name);
+	unlock_and_release_vg(cmd, vg, vg_name);
 	return r;
 }
--- LVM2/tools/lvresize.c	2011/06/15 10:56:52	1.133
+++ LVM2/tools/lvresize.c	2011/08/10 20:25:31	1.134
@@ -773,7 +773,7 @@
 	log_verbose("Finding volume group %s", lp.vg_name);
 	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
-		free_vg(vg);
+		release_vg(vg);
 		stack;
 		return ECMD_FAILED;
 	}
@@ -781,7 +781,7 @@
 	if (!(r = _lvresize(cmd, vg, &lp)))
 		stack;
 
-	unlock_and_free_vg(cmd, vg, lp.vg_name);
+	unlock_and_release_vg(cmd, vg, lp.vg_name);
 
 	return r;
 }
--- LVM2/tools/polldaemon.c	2011/02/18 15:05:40	1.44
+++ LVM2/tools/polldaemon.c	2011/08/10 20:25:31	1.45
@@ -187,7 +187,7 @@
 		/* Locks the (possibly renamed) VG again */
 		vg = parms->poll_fns->get_copy_vg(cmd, name, uuid);
 		if (vg_read_error(vg)) {
-			free_vg(vg);
+			release_vg(vg);
 			log_error("ABORTING: Can't reread VG for %s", name);
 			/* What more could we do here? */
 			return 0;
@@ -198,23 +198,23 @@
 		if (!lv && parms->lv_type == PVMOVE) {
 			log_print("%s: no pvmove in progress - already finished or aborted.",
 				  name);
-			unlock_and_free_vg(cmd, vg, vg->name);
+			unlock_and_release_vg(cmd, vg, vg->name);
 			return 1;
 		}
 
 		if (!lv) {
 			log_error("ABORTING: Can't find LV in %s for %s",
 				  vg->name, name);
-			unlock_and_free_vg(cmd, vg, vg->name);
+			unlock_and_release_vg(cmd, vg, vg->name);
 			return 0;
 		}
 
 		if (!_check_lv_status(cmd, vg, lv, name, parms, &finished)) {
-			unlock_and_free_vg(cmd, vg, vg->name);
+			unlock_and_release_vg(cmd, vg, vg->name);
 			return_0;
 		}
 
-		unlock_and_free_vg(cmd, vg, vg->name);
+		unlock_and_release_vg(cmd, vg, vg->name);
 
 		/*
 		 * FIXME Sleeping after testing, while preferred, also works around
--- LVM2/tools/pvchange.c	2011/02/28 13:19:03	1.91
+++ LVM2/tools/pvchange.c	2011/08/10 20:25:31	1.92
@@ -218,7 +218,7 @@
 			}
 			vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 			if (vg_read_error(vg)) {
-				free_vg(vg);
+				release_vg(vg);
 				stack;
 				continue;
 			}
@@ -232,7 +232,7 @@
 			total++;
 			done += _pvchange_single(cmd, vg,
 						 pvl->pv, NULL);
-			unlock_and_free_vg(cmd, vg, vg_name);
+			unlock_and_release_vg(cmd, vg, vg_name);
 		}
 	} else {
 		log_verbose("Scanning for physical volume names");
@@ -253,7 +253,7 @@
 			dm_list_iterate_items(sll, vgnames) {
 				vg = vg_read_for_update(cmd, sll->str, NULL, 0);
 				if (vg_read_error(vg)) {
-					free_vg(vg);
+					release_vg(vg);
 					stack;
 					continue;
 				}
@@ -263,7 +263,7 @@
 								 pvl->pv,
 								 NULL);
 				}
-				unlock_and_free_vg(cmd, vg, sll->str);
+				unlock_and_release_vg(cmd, vg, sll->str);
 			}
 		}
 		unlock_vg(cmd, VG_GLOBAL);
--- LVM2/tools/pvcreate.c	2011/06/01 19:29:34	1.95
+++ LVM2/tools/pvcreate.c	2011/08/10 20:25:31	1.96
@@ -74,7 +74,7 @@
 		pp->pe_start = pv_pe_start(existing_pvl->pv);
 		pp->extent_size = pv_pe_size(existing_pvl->pv);
 		pp->extent_count = pv_pe_count(existing_pvl->pv);
-		free_vg(vg);
+		release_vg(vg);
 	}
 
 	if (arg_sign_value(cmd, physicalvolumesize_ARG, 0) == SIGN_MINUS) {
--- LVM2/tools/pvdisplay.c	2010/12/08 20:50:51	1.55
+++ LVM2/tools/pvdisplay.c	2011/08/10 20:25:31	1.56
@@ -32,7 +32,7 @@
 		vg = vg_read(cmd, vg_name, (char *)&pv->vgid, 0);
 		if (vg_read_error(vg)) {
 			log_error("Skipping volume group %s", vg_name);
-			free_vg(vg);
+			release_vg(vg);
 			/* FIXME If CLUSTERED should return ECMD_PROCESSED here */
 			return ECMD_FAILED;
 		}
@@ -85,7 +85,7 @@
 	if (vg_name)
 		unlock_vg(cmd, vg_name);
 	if (!old_vg)
-		free_vg(vg);
+		release_vg(vg);
 
 	return ret;
 }
--- LVM2/tools/pvmove.c	2011/06/11 00:03:07	1.84
+++ LVM2/tools/pvmove.c	2011/08/10 20:25:31	1.85
@@ -460,7 +460,7 @@
 
 	vg = _get_vg(cmd, pv_vg_name(pv));
 	if (vg_read_error(vg)) {
-		free_vg(vg);
+		release_vg(vg);
 		stack;
 		return ECMD_FAILED;
 	}
@@ -526,7 +526,7 @@
 	r = ECMD_PROCESSED;
 out:
 	free_pv_fid(pv);
-	unlock_and_free_vg(cmd, vg, pv_vg_name(pv));
+	unlock_and_release_vg(cmd, vg, pv_vg_name(pv));
 	return r;
 }
 
--- LVM2/tools/pvresize.c	2011/06/01 19:29:34	1.45
+++ LVM2/tools/pvresize.c	2011/08/10 20:25:31	1.46
@@ -52,7 +52,7 @@
 		vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 
 		if (vg_read_error(vg)) {
-			free_vg(vg);
+			release_vg(vg);
 			log_error("Unable to read volume group \"%s\".",
 				  vg_name);
 			return 0;
@@ -129,7 +129,7 @@
 	if (is_orphan_vg(vg_name))
 		free_pv_fid(pv);
 	if (!old_vg)
-		free_vg(vg);
+		release_vg(vg);
 	return r;
 }
 
--- LVM2/tools/reporter.c	2011/03/09 12:44:43	1.66
+++ LVM2/tools/reporter.c	2011/08/10 20:25:31	1.67
@@ -142,7 +142,7 @@
 		vg = vg_read(cmd, vg_name, (char *)&pv->vgid, 0);
 		if (vg_read_error(vg)) {
 			log_error("Skipping volume group %s", vg_name);
-			free_vg(vg);
+			release_vg(vg);
 			return ECMD_FAILED;
 		}
 
@@ -182,7 +182,7 @@
 		unlock_vg(cmd, vg_name);
 
 	if (!old_vg)
-		free_vg(vg);
+		release_vg(vg);
 
 	return ret;
 }
--- LVM2/tools/toollib.c	2011/06/01 19:29:34	1.227
+++ LVM2/tools/toollib.c	2011/08/10 20:25:31	1.228
@@ -403,7 +403,7 @@
 
 		vg = vg_read(cmd, vg_name, NULL, 0);
 		if (vg_read_error(vg)) {
-			free_vg(vg);
+			release_vg(vg);
 			log_error("Skipping volume group %s", vg_name);
 			return ECMD_FAILED;
 		}
@@ -415,7 +415,7 @@
 		if (!(pvl = find_pv_in_vg(vg, pv_dev_name(pv)))) {
 			 log_error("Unable to find %s in volume group %s",
 				   pv_dev_name(pv), vg_name);
-			 unlock_and_free_vg(cmd, vg, vg_name);
+			 unlock_and_release_vg(cmd, vg, vg_name);
 			 return ECMD_FAILED;
 		}
 
@@ -438,7 +438,7 @@
 	if (vg_name)
 		unlock_vg(cmd, vg_name);
 	if (!old_vg)
-		free_vg(vg);
+		release_vg(vg);
 
 	return ret_max;
 }
@@ -795,7 +795,7 @@
 				vg = vg_read(cmd, sll->str, NULL, flags);
 				if (vg_read_error(vg)) {
 					ret_max = ECMD_FAILED;
-					free_vg(vg);
+					release_vg(vg);
 					stack;
 					continue;
 				}
@@ -804,7 +804,7 @@
 							    handle,
 							    process_single_pv);
 
-				unlock_and_free_vg(cmd, vg, sll->str);
+				unlock_and_release_vg(cmd, vg, sll->str);
 
 				if (ret > ret_max)
 					ret_max = ret;
--- LVM2/tools/vgcreate.c	2011/02/18 14:47:31	1.83
+++ LVM2/tools/vgcreate.c	2011/08/10 20:25:31	1.84
@@ -56,7 +56,7 @@
 			log_error("A volume group called %s already exists.", vp_new.vg_name);
 		else
 			log_error("Can't get lock for %s.", vp_new.vg_name);
-		free_vg(vg);
+		release_vg(vg);
 		return ECMD_FAILED;
 	}
 
@@ -120,13 +120,13 @@
 	log_print("%s%colume group \"%s\" successfully created",
 		  clustered_message, *clustered_message ? 'v' : 'V', vg->name);
 
-	free_vg(vg);
+	release_vg(vg);
 	return ECMD_PROCESSED;
 
 bad:
 	unlock_vg(cmd, VG_ORPHANS);
 bad_orphan:
-	free_vg(vg);
+	release_vg(vg);
 	unlock_vg(cmd, vp_new.vg_name);
 	return ECMD_FAILED;
 }
--- LVM2/tools/vgextend.c	2011/02/18 14:47:31	1.63
+++ LVM2/tools/vgextend.c	2011/08/10 20:25:31	1.64
@@ -72,7 +72,7 @@
 	log_verbose("Checking for volume group \"%s\"", vg_name);
 	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
-		free_vg(vg);
+		release_vg(vg);
 		stack;
 		return ECMD_FAILED;
 	}
@@ -92,7 +92,7 @@
 	} else { /* no --restore, normal vgextend */
 		if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 			log_error("Can't get lock for orphan PVs");
-			unlock_and_free_vg(cmd, vg, vg_name);
+			unlock_and_release_vg(cmd, vg, vg_name);
 			return ECMD_FAILED;
 		}
 
@@ -135,6 +135,6 @@
 bad:
 	if (!arg_count(cmd, restoremissing_ARG))
 		unlock_vg(cmd, VG_ORPHANS);
-	unlock_and_free_vg(cmd, vg, vg_name);
+	unlock_and_release_vg(cmd, vg, vg_name);
 	return r;
 }
--- LVM2/tools/vgmerge.c	2011/03/30 14:35:00	1.73
+++ LVM2/tools/vgmerge.c	2011/08/10 20:25:31	1.74
@@ -22,7 +22,7 @@
 	log_verbose("Checking for volume group \"%s\"", vg_name);
 	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
-		free_vg(vg);
+		release_vg(vg);
 		return NULL;
 	}
 	return vg;
@@ -54,7 +54,7 @@
 		vg_to = _vgmerge_vg_read(cmd, vg_name_to);
 		if (!vg_to) {
 			stack;
-			unlock_and_free_vg(cmd, vg_from, vg_name_from);
+			unlock_and_release_vg(cmd, vg_from, vg_name_from);
 			return ECMD_FAILED;
 		}
 	} else {
@@ -67,7 +67,7 @@
 		vg_from = _vgmerge_vg_read(cmd, vg_name_from);
 		if (!vg_from) {
 			stack;
-			unlock_and_free_vg(cmd, vg_to, vg_name_to);
+			unlock_and_release_vg(cmd, vg_to, vg_name_to);
 			return ECMD_FAILED;
 		}
 	}
@@ -153,10 +153,10 @@
 bad:
 	/*
 	 * Note: as vg_to is referencing moved elements from vg_from
-	 * the order of free_vg calls is mandatory.
+	 * the order of release_vg calls is mandatory.
 	 */
-	unlock_and_free_vg(cmd, vg_to, vg_name_to);
-	unlock_and_free_vg(cmd, vg_from, vg_name_from);
+	unlock_and_release_vg(cmd, vg_to, vg_name_to);
+	unlock_and_release_vg(cmd, vg_from, vg_name_from);
 
 	return r;
 }
--- LVM2/tools/vgreduce.c	2011/07/08 19:42:11	1.112
+++ LVM2/tools/vgreduce.c	2011/08/10 20:25:31	1.113
@@ -194,7 +194,7 @@
 bad:
 	if (pvl)
 		free_pv_fid(pvl->pv);
-	unlock_and_free_vg(cmd, orphan_vg, VG_ORPHANS);
+	unlock_and_release_vg(cmd, orphan_vg, VG_ORPHANS);
 	return r;
 }
 
@@ -268,7 +268,7 @@
 			goto out;
 		}
 
-		free_vg(vg);
+		release_vg(vg);
 		log_verbose("Trying to open VG %s for recovery...", vg_name);
 
 		vg = vg_read_for_update(cmd, vg_name, NULL,
@@ -314,7 +314,7 @@
 	}
 out:
 	init_ignore_suspended_devices(saved_ignore_suspended_devices);
-	unlock_and_free_vg(cmd, vg, vg_name);
+	unlock_and_release_vg(cmd, vg, vg_name);
 
 	return ret;
 
--- LVM2/tools/vgrename.c	2011/02/18 14:47:31	1.75
+++ LVM2/tools/vgrename.c	2011/08/10 20:25:31	1.76
@@ -25,7 +25,7 @@
 	   nevertheless. */
 	vg = vg_read_for_update(cmd, vg_name_old, vgid, READ_ALLOW_EXPORTED);
 	if (vg_read_error(vg)) {
-		free_vg(vg);
+		release_vg(vg);
 		return_NULL;
 	}
 
@@ -117,7 +117,7 @@
 			return_0;
 
 		if (!_lock_new_vg_for_rename(cmd, vg_name_new)) {
-			unlock_and_free_vg(cmd, vg, vg_name_old);
+			unlock_and_release_vg(cmd, vg, vg_name_old);
 			return_0;
 		}
 	} else {
@@ -170,7 +170,7 @@
 		stack;
 
 	unlock_vg(cmd, vg_name_new);
-	unlock_and_free_vg(cmd, vg, vg_name_old);
+	unlock_and_release_vg(cmd, vg, vg_name_old);
 
 	log_print("Volume group \"%s\" successfully renamed to \"%s\"",
 		  vg_name_old, vg_name_new);
@@ -184,9 +184,9 @@
       error:
 	if (lock_vg_old_first) {
 		unlock_vg(cmd, vg_name_new);
-		unlock_and_free_vg(cmd, vg, vg_name_old);
+		unlock_and_release_vg(cmd, vg, vg_name_old);
 	} else {
-		unlock_and_free_vg(cmd, vg, vg_name_old);
+		unlock_and_release_vg(cmd, vg, vg_name_old);
 		unlock_vg(cmd, vg_name_new);
 	}
 	return 0;
--- LVM2/tools/vgsplit.c	2011/04/29 00:21:16	1.107
+++ LVM2/tools/vgsplit.c	2011/08/10 20:25:31	1.108
@@ -224,16 +224,16 @@
 	vg_to = vg_create(cmd, vg_name_to);
 	if (vg_read_error(vg_to) == FAILED_LOCKING) {
 		log_error("Can't get lock for %s", vg_name_to);
-		free_vg(vg_to);
+		release_vg(vg_to);
 		return NULL;
 	}
 	if (vg_read_error(vg_to) == FAILED_EXIST) {
 		*existing_vg = 1;
-		free_vg(vg_to);
+		release_vg(vg_to);
 		vg_to = vg_read_for_update(cmd, vg_name_to, NULL, 0);
 
 		if (vg_read_error(vg_to)) {
-			free_vg(vg_to);
+			release_vg(vg_to);
 			stack;
 			return NULL;
 		}
@@ -259,7 +259,7 @@
 
 	vg_from = vg_read_for_update(cmd, vg_name_from, NULL, 0);
 	if (vg_read_error(vg_from)) {
-		free_vg(vg_from);
+		release_vg(vg_from);
 		return NULL;
 	}
 	return vg_from;
@@ -334,7 +334,7 @@
 
 		vg_to = _vgsplit_to(cmd, vg_name_to, &existing_vg);
 		if (!vg_to) {
-			unlock_and_free_vg(cmd, vg_from, vg_name_from);
+			unlock_and_release_vg(cmd, vg_from, vg_name_from);
 			stack;
 			return ECMD_FAILED;
 		}
@@ -346,7 +346,7 @@
 		}
 		vg_from = _vgsplit_from(cmd, vg_name_from);
 		if (!vg_from) {
-			unlock_and_free_vg(cmd, vg_to, vg_name_to);
+			unlock_and_release_vg(cmd, vg_to, vg_name_to);
 			stack;
 			return ECMD_FAILED;
 		}
@@ -463,7 +463,7 @@
 	 * Finally, remove the EXPORTED flag from the new VG and write it out.
 	 */
 	if (!test_mode()) {
-		free_vg(vg_to);
+		release_vg(vg_to);
 		vg_to = vg_read_for_update(cmd, vg_name_to, NULL,
 					   READ_ALLOW_EXPORTED);
 		if (vg_read_error(vg_to)) {
@@ -491,8 +491,8 @@
 	 * vg_to references elements moved from vg_from
 	 * so vg_to has to be freed first.
 	 */
-	unlock_and_free_vg(cmd, vg_to, vg_name_to);
-	unlock_and_free_vg(cmd, vg_from, vg_name_from);
+	unlock_and_release_vg(cmd, vg_to, vg_name_to);
+	unlock_and_release_vg(cmd, vg_from, vg_name_from);
 
 	return r;
 }


