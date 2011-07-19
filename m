From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 19 Jul 2011 15:43:53 +0200
Subject: [PATCH 2/7] Change free_vg to release_vg
In-Reply-To: <cover.1311082436.git.zkabelac@redhat.com>
References: <cover.1311082436.git.zkabelac@redhat.com>
Message-ID: <99d0c4d901fceeeec44dd4adae1df3848132ad67.1311082436.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Move the free_vg() to  vg.c  and replace free_vg  with release_vg
and make the _free_vg internal.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/lvm-functions.c    |    2 +-
 lib/activate/activate.c          |   14 +++---
 lib/cache/lvmcache.c             |    2 +-
 lib/format_pool/format_pool.c    |    2 +-
 lib/format_text/archive.c        |    2 +-
 lib/format_text/archiver.c       |    6 +-
 lib/format_text/format-text.c    |    4 +-
 lib/format_text/import_vsn1.c    |    2 +-
 lib/locking/locking.h            |    4 +-
 lib/metadata/metadata-exported.h |    6 ---
 lib/metadata/metadata.c          |   82 +++++++++++++++----------------------
 lib/metadata/replicator_manip.c  |    6 +-
 lib/metadata/vg.c                |   22 ++++++++++
 lib/metadata/vg.h                |    6 +++
 liblvm/lvm_vg.c                  |    8 ++--
 tools/lvconvert.c                |   10 ++--
 tools/lvcreate.c                 |    4 +-
 tools/lvrename.c                 |    4 +-
 tools/lvresize.c                 |    4 +-
 tools/polldaemon.c               |   10 ++--
 tools/pvchange.c                 |    8 ++--
 tools/pvcreate.c                 |    2 +-
 tools/pvdisplay.c                |    4 +-
 tools/pvmove.c                   |    4 +-
 tools/pvresize.c                 |    4 +-
 tools/reporter.c                 |    4 +-
 tools/toollib.c                  |   10 ++--
 tools/vgcreate.c                 |    6 +-
 tools/vgextend.c                 |    6 +-
 tools/vgmerge.c                  |   12 +++---
 tools/vgreduce.c                 |    6 +-
 tools/vgrename.c                 |   10 ++--
 tools/vgsplit.c                  |   18 ++++----
 33 files changed, 150 insertions(+), 144 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index c10ce9d..520d59a 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -880,7 +880,7 @@ void lvm_do_backup(const char *vgname)
 	else
 		log_error("Error backing up metadata, can't find VG for group %s", vgname);
 
-	free_vg(vg);
+	release_vg(vg);
 	dm_pool_empty(cmd->mem);
 
 	pthread_mutex_unlock(&lvm_lock);
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index de66228..d368f38 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -521,7 +521,7 @@ int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s,
 		origin_only = 0;
 
 	r = lv_info(cmd, lv, origin_only, info, with_open_count, with_read_ahead);
-	free_vg(lv->vg);
+	release_vg(lv->vg);
 
 	return r;
 }
@@ -1267,10 +1267,10 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
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
@@ -1351,7 +1351,7 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 	r = 1;
 out:
 	if (lv)
-		free_vg(lv->vg);
+		release_vg(lv->vg);
 
 	return r;
 }
@@ -1458,7 +1458,7 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s)
 out:
 	if (lv) {
 		lv_release_replicator_vgs(lv);
-		free_vg(lv->vg);
+		release_vg(lv->vg);
 	}
 
 	return r;
@@ -1488,7 +1488,7 @@ int lv_activation_filter(struct cmd_context *cmd, const char *lvid_s,
 	r = 1;
 out:
 	if (lv)
-		free_vg(lv->vg);
+		release_vg(lv->vg);
 
 	return r;
 }
@@ -1557,7 +1557,7 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 out:
 	if (lv) {
 		lv_release_replicator_vgs(lv);
-		free_vg(lv->vg);
+		release_vg(lv->vg);
 	}
 
 	return r;
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 0e92fa3..a2d6aa1 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -684,7 +684,7 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 	return vg;
 
 bad:
-	free_vg(vg);
+	release_vg(vg);
 	_free_cached_vgmetadata(vginfo);
 	return NULL;
 }
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index a9eba24..6caa76a 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -156,7 +156,7 @@ static struct volume_group *_pool_vg_read(struct format_instance *fid,
 	return vg;
 
 bad:
-	free_vg(vg);
+	release_vg(vg);
 
 	return NULL;
 }
diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
index 4e7c8f1..c9fd0e9 100644
--- a/lib/format_text/archive.c
+++ b/lib/format_text/archive.c
@@ -332,7 +332,7 @@ static void _display_archive(struct cmd_context *cmd, struct archive_file *af)
 	log_print("Description:\t%s", desc ? : "<No description>");
 	log_print("Backup Time:\t%s", ctime(&when));
 
-	free_vg(vg);
+	release_vg(vg);
 }
 
 int archive_list(struct cmd_context *cmd, const char *dir, const char *vgname)
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index e3e9fe0..498b6f2 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -362,7 +362,7 @@ int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
 		log_error("Cannot restore Volume Group %s with %i PVs "
 			  "marked as missing.", vg->name, missing_pvs);
 
-	free_vg(vg);
+	release_vg(vg);
 	return r;
 }
 
@@ -447,7 +447,7 @@ void check_current_backup(struct volume_group *vg)
 	    (vg->seqno == vg_backup->seqno) &&
 	    (id_equal(&vg->id, &vg_backup->id))) {
 		log_suppress(old_suppress);
-		free_vg(vg_backup);
+		release_vg(vg_backup);
 		return;
 	}
 	log_suppress(old_suppress);
@@ -455,7 +455,7 @@ void check_current_backup(struct volume_group *vg)
 	if (vg_backup) {
 		if (!archive(vg_backup))
 			stack;
-		free_vg(vg_backup);
+		release_vg(vg_backup);
 	}
 	if (!archive(vg))
 		stack;
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index d53313c..4a025b2 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -855,7 +855,7 @@ static struct volume_group *_vg_read_file_name(struct format_instance *fid,
 	 * check that it contains the correct volume group.
 	 */
 	if (vgname && strcmp(vgname, vg->name)) {
-		free_vg(vg);
+		release_vg(vg);
 		log_error("'%s' does not contain volume group '%s'.",
 			  read_path, vgname);
 		return NULL;
@@ -1091,7 +1091,7 @@ static int _scan_file(const struct format_type *fmt, const char *vgname)
 							     path))) {
 					/* FIXME Store creation host in vg */
 					lvmcache_update_vg(vg, 0);
-					free_vg(vg);
+					release_vg(vg);
 				}
 			}
 
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index b068a00..14fb1a7 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -811,7 +811,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	if (lv_hash)
 		dm_hash_destroy(lv_hash);
 
-	free_vg(vg);
+	release_vg(vg);
 	return NULL;
 }
 
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index 6a18457..f8a2c25 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -156,10 +156,10 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
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
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 2c4c122..c42b86a 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -469,12 +469,6 @@ int remove_lvs_in_vg(struct cmd_context *cmd,
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
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d0255da..6401207 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -374,7 +374,7 @@ int get_pv_from_vg_by_id(const struct format_type *fmt, const char *vg_name,
 		}
 	}
 out:
-	free_vg(vg);
+	release_vg(vg);
 	return r;
 }
 
@@ -928,7 +928,7 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
 	/* is this vg name already in use ? */
 	if ((vg = vg_read_internal(cmd, vg_name, NULL, 1, &consistent))) {
 		log_error("A volume group called '%s' already exists.", vg_name);
-		unlock_and_free_vg(cmd, vg, vg_name);
+		unlock_and_release_vg(cmd, vg, vg_name);
 		return _vg_make_handle(cmd, NULL, FAILED_EXIST);
 	}
 
@@ -980,7 +980,7 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
 	return _vg_make_handle(cmd, vg, SUCCESS);
 
 bad:
-	unlock_and_free_vg(cmd, vg, vg_name);
+	unlock_and_release_vg(cmd, vg, vg_name);
 	/* FIXME: use _vg_make_handle() w/proper error code */
 	return NULL;
 }
@@ -2730,7 +2730,7 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	return vg;
 bad:
 	free_pv_fid(pv);
-	free_vg(vg);
+	release_vg(vg);
 	return NULL;
 }
 
@@ -2866,7 +2866,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		*consistent = 1;
 		return correct_vg;
 	} else {
-		free_vg(correct_vg);
+		release_vg(correct_vg);
 		correct_vg = NULL;
 	}
 
@@ -2912,7 +2912,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		    (!use_precommitted &&
 		     !(vg = mda->ops->vg_read(fid, vgname, mda)))) {
 			inconsistent = 1;
-			free_vg(vg);
+			release_vg(vg);
 			continue;
 		}
 
@@ -2932,7 +2932,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 				inconsistent_seqno = 1;
 			}
 			if (vg->seqno > correct_vg->seqno) {
-				free_vg(correct_vg);
+				release_vg(correct_vg);
 				correct_vg = vg;
 			} else {
 				mda->status |= MDA_INCONSISTENT;
@@ -2941,7 +2941,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		}
 
 		if (vg != correct_vg)
-			free_vg(vg);
+			release_vg(vg);
 	}
 
 	/* Ensure every PV in the VG was in the cache */
@@ -3017,7 +3017,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			if (critical_section())
 				inconsistent = 1;
 			else {
-				free_vg(correct_vg);
+				release_vg(correct_vg);
 				correct_vg = NULL;
 			}
 		} else dm_list_iterate_items(pvl, &correct_vg->pvs) {
@@ -3026,14 +3026,14 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
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
@@ -3078,7 +3078,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 				correct_vg = vg;
 				if (!_update_pv_list(cmd->mem, &all_pvs, correct_vg)) {
 					_free_pv_list(&all_pvs);
-					free_vg(vg);
+					release_vg(vg);
 					return_NULL;
 				}
 				continue;
@@ -3102,12 +3102,12 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 				}
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
@@ -3116,7 +3116,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			}
 
 			if (vg != correct_vg)
-				free_vg(vg);
+				release_vg(vg);
 		}
 
 		/* Give up looking */
@@ -3162,7 +3162,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 				return correct_vg;
 			}
 			_free_pv_list(&all_pvs);
-			free_vg(correct_vg);
+			release_vg(correct_vg);
 			return NULL;
 		}
 
@@ -3194,7 +3194,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		if (!vg_write(correct_vg)) {
 			log_error("Automatic metadata correction failed");
 			_free_pv_list(&all_pvs);
-			free_vg(correct_vg);
+			release_vg(correct_vg);
 			cmd->handles_missing_pvs = saved_handles_missing_pvs;
 			return NULL;
 		}
@@ -3203,7 +3203,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		if (!vg_commit(correct_vg)) {
 			log_error("Automatic metadata correction commit "
 				  "failed");
-			free_vg(correct_vg);
+			release_vg(correct_vg);
 			return NULL;
 		}
 
@@ -3214,14 +3214,14 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
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
 
@@ -3245,7 +3245,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			  "volume group %s", correct_vg->name);
 		log_error("Please restore the metadata by running "
 			  "vgcfgrestore.");
-		free_vg(correct_vg);
+		release_vg(correct_vg);
 		return NULL;
 	}
 
@@ -3265,7 +3265,7 @@ struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgnam
 	if (!check_pv_segments(vg)) {
 		log_error(INTERNAL_ERROR "PV segments corrupted in %s.",
 			  vg->name);
-		free_vg(vg);
+		release_vg(vg);
 		return NULL;
 	}
 
@@ -3273,7 +3273,7 @@ struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgnam
 		if (!check_lv_segments(lvl->lv, 0)) {
 			log_error(INTERNAL_ERROR "LV segments corrupted in %s.",
 				  lvl->lv->name);
-			free_vg(vg);
+			release_vg(vg);
 			return NULL;
 		}
 	}
@@ -3285,7 +3285,7 @@ struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgnam
 		if (!check_lv_segments(lvl->lv, 1)) {
 			log_error(INTERNAL_ERROR "LV segments corrupted in %s.",
 				  lvl->lv->name);
-			free_vg(vg);
+			release_vg(vg);
 			return NULL;
 		}
 	}
@@ -3302,22 +3302,6 @@ void free_pv_fid(struct physical_volume *pv)
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
@@ -3344,7 +3328,7 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 					  "inconsistent", vg->name);
 			return vg;
 		}
-		free_vg(vg);
+		release_vg(vg);
 	}
 
 	/* Mustn't scan if memory locked: ensure cache gets pre-populated! */
@@ -3373,12 +3357,12 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
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
@@ -3412,7 +3396,7 @@ struct logical_volume *lv_from_lvid(struct cmd_context *cmd, const char *lvid_s,
 
 	return lvl->lv;
 out:
-	free_vg(vg);
+	release_vg(vg);
 	return NULL;
 }
 
@@ -3619,12 +3603,12 @@ static int _get_pvs(struct cmd_context *cmd, int warnings, struct dm_list **pvsl
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
 
@@ -3841,7 +3825,7 @@ static struct volume_group *_recover_vg(struct cmd_context *cmd,
 		return_NULL;
 
 	if (!consistent) {
-		free_vg(vg);
+		release_vg(vg);
 		return_NULL;
 	}
 
@@ -3913,7 +3897,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 
 	/* consistent == 0 when VG is not found, but failed == FAILED_NOTFOUND */
 	if (!consistent && !failure) {
-		free_vg(vg);
+		release_vg(vg);
 		if (!(vg = _recover_vg(cmd, vg_name, vgid))) {
 			log_error("Recovery of volume group \"%s\" failed.",
 				  vg_name);
diff --git a/lib/metadata/replicator_manip.c b/lib/metadata/replicator_manip.c
index 79abca0..9f9dc97 100644
--- a/lib/metadata/replicator_manip.c
+++ b/lib/metadata/replicator_manip.c
@@ -597,9 +597,9 @@ void free_cmd_vgs(struct dm_list *cmd_vgs)
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
@@ -687,7 +687,7 @@ void lv_release_replicator_vgs(struct logical_volume *lv)
 
 	dm_list_iterate_back_items(rsite, &first_seg(lv)->replicator->rsites)
 		if (rsite->vg_name && rsite->vg) {
-			free_vg(rsite->vg);
+			release_vg(rsite->vg);
 			rsite->vg = NULL;
 		}
 }
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index af286fc..ef88a4d 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -17,6 +17,7 @@
 #include "metadata.h"
 #include "display.h"
 #include "activate.h"
+#include "toolcontext.h"
 
 struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 			      const char *vg_name)
@@ -51,6 +52,27 @@ struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
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
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index bebe6cf..a3dc218 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -111,6 +111,12 @@ struct volume_group {
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
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 08b4212..405a91a 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -56,7 +56,7 @@ vg_t lvm_vg_create(lvm_t libh, const char *vg_name)
 	vg = vg_create((struct cmd_context *)libh, vg_name);
 	/* FIXME: error handling is still TBD */
 	if (vg_read_error(vg)) {
-		free_vg(vg);
+		release_vg(vg);
 		return NULL;
 	}
 	vg->open_mode = 'w';
@@ -160,9 +160,9 @@ int lvm_vg_write(vg_t vg)
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
 
@@ -197,7 +197,7 @@ vg_t lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
 	vg = vg_read((struct cmd_context *)libh, vgname, NULL, internal_flags);
 	if (vg_read_error(vg)) {
 		/* FIXME: use log_errno either here in inside vg_read */
-		free_vg(vg);
+		release_vg(vg);
 		return NULL;
 	}
 	/* FIXME: combine this with locking ? */
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 73b9788..20ec617 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1615,7 +1615,7 @@ static struct logical_volume *get_vg_lock_and_logical_volume(struct cmd_context
 {
 	/*
 	 * Returns NULL if the requested LV doesn't exist;
-	 * otherwise the caller must free_vg(lv->vg)
+	 * otherwise the caller must release_vg(lv->vg)
 	 * - it is also up to the caller to unlock_vg() as needed
 	 */
 	struct volume_group *vg;
@@ -1623,13 +1623,13 @@ static struct logical_volume *get_vg_lock_and_logical_volume(struct cmd_context
 
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
 
@@ -1682,7 +1682,7 @@ bad:
 		ret = poll_logical_volume(cmd, lp->lv_to_poll,
 					  lp->wait_completion);
 
-	free_vg(lv->vg);
+	release_vg(lv->vg);
 out:
 	init_ignore_suspended_devices(saved_ignore_suspended_devices);
 	return ret;
@@ -1732,7 +1732,7 @@ static int lvconvert_merge_single(struct cmd_context *cmd, struct logical_volume
 		}
 	}
 
-	free_vg(refreshed_lv->vg);
+	release_vg(refreshed_lv->vg);
 
 	return ret;
 }
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 22f2866..6d57784 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -553,7 +553,7 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 	log_verbose("Finding volume group \"%s\"", lp.vg_name);
 	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
-		free_vg(vg);
+		release_vg(vg);
 		stack;
 		return ECMD_FAILED;
 	}
@@ -568,6 +568,6 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 		r = ECMD_FAILED;
 	}
 out:
-	unlock_and_free_vg(cmd, vg, lp.vg_name);
+	unlock_and_release_vg(cmd, vg, lp.vg_name);
 	return r;
 }
diff --git a/tools/lvrename.c b/tools/lvrename.c
index db47a8b..782f32b 100644
--- a/tools/lvrename.c
+++ b/tools/lvrename.c
@@ -104,7 +104,7 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 	log_verbose("Checking for existing volume group \"%s\"", vg_name);
 	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
-		free_vg(vg);
+		release_vg(vg);
 		stack;
 		return ECMD_FAILED;
 	}
@@ -123,6 +123,6 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 
 	r = ECMD_PROCESSED;
 error:
-	unlock_and_free_vg(cmd, vg, vg_name);
+	unlock_and_release_vg(cmd, vg, vg_name);
 	return r;
 }
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 8c23a5e..6fbc115 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -773,7 +773,7 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 	log_verbose("Finding volume group %s", lp.vg_name);
 	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
-		free_vg(vg);
+		release_vg(vg);
 		stack;
 		return ECMD_FAILED;
 	}
@@ -781,7 +781,7 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 	if (!(r = _lvresize(cmd, vg, &lp)))
 		stack;
 
-	unlock_and_free_vg(cmd, vg, lp.vg_name);
+	unlock_and_release_vg(cmd, vg, lp.vg_name);
 
 	return r;
 }
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 0555b94..9039240 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -187,7 +187,7 @@ static int _wait_for_single_lv(struct cmd_context *cmd, const char *name, const
 		/* Locks the (possibly renamed) VG again */
 		vg = parms->poll_fns->get_copy_vg(cmd, name, uuid);
 		if (vg_read_error(vg)) {
-			free_vg(vg);
+			release_vg(vg);
 			log_error("ABORTING: Can't reread VG for %s", name);
 			/* What more could we do here? */
 			return 0;
@@ -198,23 +198,23 @@ static int _wait_for_single_lv(struct cmd_context *cmd, const char *name, const
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
diff --git a/tools/pvchange.c b/tools/pvchange.c
index 58dd649..990d0f2 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -218,7 +218,7 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 			}
 			vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 			if (vg_read_error(vg)) {
-				free_vg(vg);
+				release_vg(vg);
 				stack;
 				continue;
 			}
@@ -232,7 +232,7 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 			total++;
 			done += _pvchange_single(cmd, vg,
 						 pvl->pv, NULL);
-			unlock_and_free_vg(cmd, vg, vg_name);
+			unlock_and_release_vg(cmd, vg, vg_name);
 		}
 	} else {
 		log_verbose("Scanning for physical volume names");
@@ -253,7 +253,7 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 			dm_list_iterate_items(sll, vgnames) {
 				vg = vg_read_for_update(cmd, sll->str, NULL, 0);
 				if (vg_read_error(vg)) {
-					free_vg(vg);
+					release_vg(vg);
 					stack;
 					continue;
 				}
@@ -263,7 +263,7 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 								 pvl->pv,
 								 NULL);
 				}
-				unlock_and_free_vg(cmd, vg, sll->str);
+				unlock_and_release_vg(cmd, vg, sll->str);
 			}
 		}
 		unlock_vg(cmd, VG_GLOBAL);
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 0108d77..7b50f70 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -74,7 +74,7 @@ static int pvcreate_restore_params_validate(struct cmd_context *cmd,
 		pp->pe_start = pv_pe_start(existing_pvl->pv);
 		pp->extent_size = pv_pe_size(existing_pvl->pv);
 		pp->extent_count = pv_pe_count(existing_pvl->pv);
-		free_vg(vg);
+		release_vg(vg);
 	}
 
 	if (arg_sign_value(cmd, physicalvolumesize_ARG, 0) == SIGN_MINUS) {
diff --git a/tools/pvdisplay.c b/tools/pvdisplay.c
index 1ae0339..2136721 100644
--- a/tools/pvdisplay.c
+++ b/tools/pvdisplay.c
@@ -32,7 +32,7 @@ static int _pvdisplay_single(struct cmd_context *cmd,
 		vg = vg_read(cmd, vg_name, (char *)&pv->vgid, 0);
 		if (vg_read_error(vg)) {
 			log_error("Skipping volume group %s", vg_name);
-			free_vg(vg);
+			release_vg(vg);
 			/* FIXME If CLUSTERED should return ECMD_PROCESSED here */
 			return ECMD_FAILED;
 		}
@@ -85,7 +85,7 @@ out:
 	if (vg_name)
 		unlock_vg(cmd, vg_name);
 	if (!old_vg)
-		free_vg(vg);
+		release_vg(vg);
 
 	return ret;
 }
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 79b17df..7a2fd14 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -460,7 +460,7 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 
 	vg = _get_vg(cmd, pv_vg_name(pv));
 	if (vg_read_error(vg)) {
-		free_vg(vg);
+		release_vg(vg);
 		stack;
 		return ECMD_FAILED;
 	}
@@ -526,7 +526,7 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 	r = ECMD_PROCESSED;
 out:
 	free_pv_fid(pv);
-	unlock_and_free_vg(cmd, vg, pv_vg_name(pv));
+	unlock_and_release_vg(cmd, vg, pv_vg_name(pv));
 	return r;
 }
 
diff --git a/tools/pvresize.c b/tools/pvresize.c
index 1c80c94..549661a 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -52,7 +52,7 @@ static int _pv_resize_single(struct cmd_context *cmd,
 		vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 
 		if (vg_read_error(vg)) {
-			free_vg(vg);
+			release_vg(vg);
 			log_error("Unable to read volume group \"%s\".",
 				  vg_name);
 			return 0;
@@ -129,7 +129,7 @@ out:
 	if (is_orphan_vg(vg_name))
 		free_pv_fid(pv);
 	if (!old_vg)
-		free_vg(vg);
+		release_vg(vg);
 	return r;
 }
 
diff --git a/tools/reporter.c b/tools/reporter.c
index c8a6bb4..a527253 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -142,7 +142,7 @@ static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 		vg = vg_read(cmd, vg_name, (char *)&pv->vgid, 0);
 		if (vg_read_error(vg)) {
 			log_error("Skipping volume group %s", vg_name);
-			free_vg(vg);
+			release_vg(vg);
 			return ECMD_FAILED;
 		}
 
@@ -182,7 +182,7 @@ out:
 		unlock_vg(cmd, vg_name);
 
 	if (!old_vg)
-		free_vg(vg);
+		release_vg(vg);
 
 	return ret;
 }
diff --git a/tools/toollib.c b/tools/toollib.c
index 2aa5506..b606df8 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -403,7 +403,7 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 
 		vg = vg_read(cmd, vg_name, NULL, 0);
 		if (vg_read_error(vg)) {
-			free_vg(vg);
+			release_vg(vg);
 			log_error("Skipping volume group %s", vg_name);
 			return ECMD_FAILED;
 		}
@@ -415,7 +415,7 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 		if (!(pvl = find_pv_in_vg(vg, pv_dev_name(pv)))) {
 			 log_error("Unable to find %s in volume group %s",
 				   pv_dev_name(pv), vg_name);
-			 unlock_and_free_vg(cmd, vg, vg_name);
+			 unlock_and_release_vg(cmd, vg, vg_name);
 			 return ECMD_FAILED;
 		}
 
@@ -438,7 +438,7 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 	if (vg_name)
 		unlock_vg(cmd, vg_name);
 	if (!old_vg)
-		free_vg(vg);
+		release_vg(vg);
 
 	return ret_max;
 }
@@ -795,7 +795,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 				vg = vg_read(cmd, sll->str, NULL, flags);
 				if (vg_read_error(vg)) {
 					ret_max = ECMD_FAILED;
-					free_vg(vg);
+					release_vg(vg);
 					stack;
 					continue;
 				}
@@ -804,7 +804,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 							    handle,
 							    process_single_pv);
 
-				unlock_and_free_vg(cmd, vg, sll->str);
+				unlock_and_release_vg(cmd, vg, sll->str);
 
 				if (ret > ret_max)
 					ret_max = ret;
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 62b5ac7..053b089 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -56,7 +56,7 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 			log_error("A volume group called %s already exists.", vp_new.vg_name);
 		else
 			log_error("Can't get lock for %s.", vp_new.vg_name);
-		free_vg(vg);
+		release_vg(vg);
 		return ECMD_FAILED;
 	}
 
@@ -120,13 +120,13 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
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
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 5d2b54d..d1adf21 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -72,7 +72,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	log_verbose("Checking for volume group \"%s\"", vg_name);
 	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
-		free_vg(vg);
+		release_vg(vg);
 		stack;
 		return ECMD_FAILED;
 	}
@@ -92,7 +92,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	} else { /* no --restore, normal vgextend */
 		if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 			log_error("Can't get lock for orphan PVs");
-			unlock_and_free_vg(cmd, vg, vg_name);
+			unlock_and_release_vg(cmd, vg, vg_name);
 			return ECMD_FAILED;
 		}
 
@@ -135,6 +135,6 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 bad:
 	if (!arg_count(cmd, restoremissing_ARG))
 		unlock_vg(cmd, VG_ORPHANS);
-	unlock_and_free_vg(cmd, vg, vg_name);
+	unlock_and_release_vg(cmd, vg, vg_name);
 	return r;
 }
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index 6b403bf..48aa127 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -22,7 +22,7 @@ static struct volume_group *_vgmerge_vg_read(struct cmd_context *cmd,
 	log_verbose("Checking for volume group \"%s\"", vg_name);
 	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
-		free_vg(vg);
+		release_vg(vg);
 		return NULL;
 	}
 	return vg;
@@ -54,7 +54,7 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 		vg_to = _vgmerge_vg_read(cmd, vg_name_to);
 		if (!vg_to) {
 			stack;
-			unlock_and_free_vg(cmd, vg_from, vg_name_from);
+			unlock_and_release_vg(cmd, vg_from, vg_name_from);
 			return ECMD_FAILED;
 		}
 	} else {
@@ -67,7 +67,7 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 		vg_from = _vgmerge_vg_read(cmd, vg_name_from);
 		if (!vg_from) {
 			stack;
-			unlock_and_free_vg(cmd, vg_to, vg_name_to);
+			unlock_and_release_vg(cmd, vg_to, vg_name_to);
 			return ECMD_FAILED;
 		}
 	}
@@ -153,10 +153,10 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
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
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index bcf3fb0..4d5220b 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -194,7 +194,7 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 bad:
 	if (pvl)
 		free_pv_fid(pvl->pv);
-	unlock_and_free_vg(cmd, orphan_vg, VG_ORPHANS);
+	unlock_and_release_vg(cmd, orphan_vg, VG_ORPHANS);
 	return r;
 }
 
@@ -268,7 +268,7 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 			goto out;
 		}
 
-		free_vg(vg);
+		release_vg(vg);
 		log_verbose("Trying to open VG %s for recovery...", vg_name);
 
 		vg = vg_read_for_update(cmd, vg_name, NULL,
@@ -314,7 +314,7 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 	}
 out:
 	init_ignore_suspended_devices(saved_ignore_suspended_devices);
-	unlock_and_free_vg(cmd, vg, vg_name);
+	unlock_and_release_vg(cmd, vg, vg_name);
 
 	return ret;
 
diff --git a/tools/vgrename.c b/tools/vgrename.c
index 2f83fc6..1f1f943 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -25,7 +25,7 @@ static struct volume_group *_get_old_vg_for_rename(struct cmd_context *cmd,
 	   nevertheless. */
 	vg = vg_read_for_update(cmd, vg_name_old, vgid, READ_ALLOW_EXPORTED);
 	if (vg_read_error(vg)) {
-		free_vg(vg);
+		release_vg(vg);
 		return_NULL;
 	}
 
@@ -117,7 +117,7 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 			return_0;
 
 		if (!_lock_new_vg_for_rename(cmd, vg_name_new)) {
-			unlock_and_free_vg(cmd, vg, vg_name_old);
+			unlock_and_release_vg(cmd, vg, vg_name_old);
 			return_0;
 		}
 	} else {
@@ -170,7 +170,7 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 		stack;
 
 	unlock_vg(cmd, vg_name_new);
-	unlock_and_free_vg(cmd, vg, vg_name_old);
+	unlock_and_release_vg(cmd, vg, vg_name_old);
 
 	log_print("Volume group \"%s\" successfully renamed to \"%s\"",
 		  vg_name_old, vg_name_new);
@@ -184,9 +184,9 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
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
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index f8660e1..0538459 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -224,16 +224,16 @@ static struct volume_group *_vgsplit_to(struct cmd_context *cmd,
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
@@ -259,7 +259,7 @@ static struct volume_group *_vgsplit_from(struct cmd_context *cmd,
 
 	vg_from = vg_read_for_update(cmd, vg_name_from, NULL, 0);
 	if (vg_read_error(vg_from)) {
-		free_vg(vg_from);
+		release_vg(vg_from);
 		return NULL;
 	}
 	return vg_from;
@@ -334,7 +334,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 
 		vg_to = _vgsplit_to(cmd, vg_name_to, &existing_vg);
 		if (!vg_to) {
-			unlock_and_free_vg(cmd, vg_from, vg_name_from);
+			unlock_and_release_vg(cmd, vg_from, vg_name_from);
 			stack;
 			return ECMD_FAILED;
 		}
@@ -346,7 +346,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		}
 		vg_from = _vgsplit_from(cmd, vg_name_from);
 		if (!vg_from) {
-			unlock_and_free_vg(cmd, vg_to, vg_name_to);
+			unlock_and_release_vg(cmd, vg_to, vg_name_to);
 			stack;
 			return ECMD_FAILED;
 		}
@@ -463,7 +463,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	 * Finally, remove the EXPORTED flag from the new VG and write it out.
 	 */
 	if (!test_mode()) {
-		free_vg(vg_to);
+		release_vg(vg_to);
 		vg_to = vg_read_for_update(cmd, vg_name_to, NULL,
 					   READ_ALLOW_EXPORTED);
 		if (vg_read_error(vg_to)) {
@@ -491,8 +491,8 @@ bad:
 	 * vg_to references elements moved from vg_from
 	 * so vg_to has to be freed first.
 	 */
-	unlock_and_free_vg(cmd, vg_to, vg_name_to);
-	unlock_and_free_vg(cmd, vg_from, vg_name_from);
+	unlock_and_release_vg(cmd, vg_to, vg_name_to);
+	unlock_and_release_vg(cmd, vg_from, vg_name_from);
 
 	return r;
 }
-- 
1.7.6


