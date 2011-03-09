From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed,  9 Mar 2011 13:22:36 +0100
Subject: [PATCH 4/7] Add new free_pv_fid fn and use it throughout.
In-Reply-To: <1299673359-6784-1-git-send-email-prajnoha@redhat.com>
References: <1299673359-6784-1-git-send-email-prajnoha@redhat.com>
Message-ID: <1299673359-6784-5-git-send-email-prajnoha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Normally, when the PV structure is part of the VG
(vg->pvs/vg->removed->pvs list), a call to free_vg fn will also free the
PV fid part automatically (that will be in following patch). But for any
standalone PV structures, we have to call free_pv_fid directly now.

I meant this to be "free_pv" at first, but since PV does not have its
own "mem" yet, we have only the format instance part to deallocate
(therefore "free_pv_fid"). Whenever we have a mempool or anything else
to destroy/deallocate for the PV, we can just rename the free_pv_fid to
free_pv and add the code there. Just like we have the "free_vg".

Signed-off-by: Peter Rajnoha <prajnoha@redhat.com>
---
 lib/metadata/metadata-exported.h |    8 +++
 lib/metadata/metadata.c          |  116 ++++++++++++++++++++++++++------------
 lib/metadata/mirror.c            |    6 ++-
 tools/lvconvert.c                |    1 +
 tools/pvcreate.c                 |    4 +-
 tools/pvmove.c                   |    9 +++-
 tools/pvremove.c                 |   18 ++++--
 tools/pvresize.c                 |    2 +
 tools/pvscan.c                   |    4 +-
 tools/toollib.c                  |   13 ++++
 tools/vgconvert.c                |    3 +
 tools/vgreduce.c                 |    3 +
 12 files changed, 142 insertions(+), 45 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 4bdf40c..170b25c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -460,6 +460,14 @@ void del_pvl_from_vgs(struct volume_group *vg, struct pv_list *pvl);
 int remove_lvs_in_vg(struct cmd_context *cmd,
 		     struct volume_group *vg,
 		     force_t force);
+
+/*
+ * free_pv_fid() must be called on every struct physical_volume allocated
+ * by pv_create, pv_read, find_pv_by_name or pv_by_path to free it when
+ * no longer required.
+ */
+void free_pv_fid(struct physical_volume *pv);
+
 /*
  * free_vg() must be called on every struct volume_group allocated
  * by vg_create() or vg_read_internal() to free it when no longer required.
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index cfbc1b7..5e9d13a 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -644,8 +644,10 @@ static int vg_extend_single_pv(struct volume_group *vg, char *pv_name,
 		if (!pv)
 			return 0;
 	}
-	if (!add_pv_to_vg(vg, pv_name, pv))
+	if (!add_pv_to_vg(vg, pv_name, pv)) {
+		free_pv_fid(pv);
 		return 0;
+	}
 	return 1;
 }
 
@@ -1348,6 +1350,7 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 	 * system.
 	 */
 	if (pv && is_orphan(pv) && !dm_list_size(&pv->fid->metadata_areas_in_use)) {
+		free_pv_fid(pv);
 		if (!scan_vgs_for_pvs(cmd, 0))
 			return_0;
 		pv = pv_read(cmd, name, NULL, 0, 0);
@@ -1358,18 +1361,18 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 	if (pv && !is_orphan(pv) && pp->force != DONT_PROMPT_OVERRIDE) {
 		log_error("Can't initialize physical volume \"%s\" of "
 			  "volume group \"%s\" without -ff", name, pv_vg_name(pv));
-		return 0;
+		goto bad;
 	}
 
 	/* prompt */
 	if (pv && !is_orphan(pv) && !pp->yes &&
 	    yes_no_prompt(_really_init, name, pv_vg_name(pv)) == 'n') {
 		log_error("%s: physical volume not initialized", name);
-		return 0;
+		goto bad;
 	}
 
 	if (sigint_caught())
-		return 0;
+		goto_bad;
 
 	dev = dev_cache_get(name, cmd->filter);
 
@@ -1384,7 +1387,7 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 
 	if (!dev) {
 		log_error("Device %s not found (or ignored by filtering).", name);
-		return 0;
+		goto bad;
 	}
 
 	/*
@@ -1394,20 +1397,20 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 		/* FIXME Detect whether device-mapper itself is still using it */
 		log_error("Can't open %s exclusively.  Mounted filesystem?",
 			  name);
-		return 0;
+		goto bad;
 	}
 
 	if (!_wipe_sb(dev, "software RAID md superblock", name, 4, pp, dev_is_md))
-		return 0;
+		goto_bad;
 
 	if (!_wipe_sb(dev, "swap signature", name, 10, pp, dev_is_swap))
-		return 0;
+		goto_bad;
 
 	if (!_wipe_sb(dev, "LUKS signature", name, 8, pp, dev_is_luks))
-		return 0;
+		goto_bad;
 
 	if (sigint_caught())
-		return 0;
+		goto_bad;
 
 	if (pv && !is_orphan(pv) && pp->force) {
 		log_warn("WARNING: Forcing physical volume creation on "
@@ -1417,7 +1420,12 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 			  !is_orphan(pv) ? "\"" : "");
 	}
 
+	free_pv_fid(pv);
 	return 1;
+
+bad:
+	free_pv_fid(pv);
+	return 0;
 }
 
 void pvcreate_params_set_defaults(struct pvcreate_params *pp)
@@ -1455,7 +1463,7 @@ struct physical_volume * pvcreate_single(struct cmd_context *cmd,
 					 const char *pv_name,
 					 struct pvcreate_params *pp)
 {
-	struct physical_volume *pv;
+	struct physical_volume *pv = NULL;
 	struct device *dev;
 	struct dm_list mdas;
 	struct pvcreate_params default_pp;
@@ -1470,23 +1478,23 @@ struct physical_volume * pvcreate_single(struct cmd_context *cmd,
 		    (dev != dev_cache_get(pv_name, cmd->filter))) {
 			if (!id_write_format((const struct id*)&pp->idp->uuid,
 			    buffer, sizeof(buffer)))
-				return_NULL;
+				goto_bad;
 			log_error("uuid %s already in use on \"%s\"", buffer,
 				  dev_name(dev));
-			return NULL;
+			goto bad;;
 		}
 	}
 
 	if (!pvcreate_check(cmd, pv_name, pp))
-		goto error;
+		goto_bad;
 
 	if (sigint_caught())
-		goto error;
+		goto_bad;
 
 	if (!(dev = dev_cache_get(pv_name, cmd->filter))) {
 		log_error("%s: Couldn't find device.  Check your filters?",
 			  pv_name);
-		goto error;
+		goto bad;
 	}
 
 	dm_list_init(&mdas);
@@ -1497,7 +1505,7 @@ struct physical_volume * pvcreate_single(struct cmd_context *cmd,
 			     pp->labelsector, pp->pvmetadatacopies,
 			     pp->pvmetadatasize, pp->metadataignore))) {
 		log_error("Failed to setup physical volume \"%s\"", pv_name);
-		goto error;
+		goto bad;
 	}
 
 	log_verbose("Set up physical volume for \"%s\" with %" PRIu64
@@ -1506,20 +1514,20 @@ struct physical_volume * pvcreate_single(struct cmd_context *cmd,
 	/* Wipe existing label first */
 	if (!label_remove(pv_dev(pv))) {
 		log_error("Failed to wipe existing label on %s", pv_name);
-		goto error;
+		goto bad;
 	}
 
 	if (pp->zero) {
 		log_verbose("Zeroing start of device %s", pv_name);
 		if (!dev_open_quiet(dev)) {
 			log_error("%s not opened: device not zeroed", pv_name);
-			goto error;
+			goto bad;
 		}
 
 		if (!dev_set(dev, UINT64_C(0), (size_t) 2048, 0)) {
 			log_error("%s not wiped: aborting", pv_name);
 			dev_close(dev);
-			goto error;
+			goto bad;
 		}
 		dev_close(dev);
 	}
@@ -1529,22 +1537,18 @@ struct physical_volume * pvcreate_single(struct cmd_context *cmd,
 
 	if (!(pv_write(cmd, pv, 0))) {
 		log_error("Failed to write physical volume \"%s\"", pv_name);
-		goto error;
+		goto bad;
 	}
 
 	log_print("Physical volume \"%s\" successfully created", pv_name);
 
 	return pv;
 
-      error:
+bad:
+	free_pv_fid(pv);
 	return NULL;
 }
 
-static void _free_pv(struct dm_pool *mem, struct physical_volume *pv)
-{
-	dm_pool_free(mem, pv);
-}
-
 static struct physical_volume *_alloc_pv(struct dm_pool *mem, struct device *dev)
 {
 	struct physical_volume *pv = dm_pool_zalloc(mem, sizeof(*pv));
@@ -1683,7 +1687,8 @@ struct physical_volume *pv_create(const struct cmd_context *cmd,
 	return pv;
 
       bad:
-	_free_pv(mem, pv);
+	free_pv_fid(pv);
+	dm_pool_free(mem, pv);
 	return NULL;
 }
 
@@ -1835,25 +1840,30 @@ static struct physical_volume *_find_pv_by_name(struct cmd_context *cmd,
 
 	if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, NULL, 1, 0))) {
 		log_error("Physical volume %s not found", pv_name);
-		return NULL;
+		goto bad;
 	}
 
 	if (is_orphan_vg(pv->vg_name) && !dm_list_size(&pv->fid->metadata_areas_in_use)) {
 		/* If a PV has no MDAs - need to search all VGs for it */
 		if (!scan_vgs_for_pvs(cmd, 1))
-			return_NULL;
+			goto_bad;
+		free_pv_fid(pv);
 		if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, NULL, 1, 0))) {
 			log_error("Physical volume %s not found", pv_name);
-			return NULL;
+			goto bad;
 		}
 	}
 
 	if (is_orphan_vg(pv->vg_name)) {
 		log_error("Physical volume %s not in a volume group", pv_name);
-		return NULL;
+		goto bad;
 	}
 
 	return pv;
+
+bad:
+	free_pv_fid(pv);
+	return NULL;
 }
 
 /* Find segment at a given logical extent in an LV */
@@ -2632,7 +2642,7 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	struct lvmcache_info *info;
 	struct pv_list *pvl;
 	struct volume_group *vg;
-	struct physical_volume *pv;
+	struct physical_volume *pv = NULL;
 	struct dm_pool *mem;
 
 	lvmcache_label_scan(cmd, 0);
@@ -2683,6 +2693,7 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 
 	return vg;
 bad:
+	free_pv_fid(pv);
 	dm_pool_destroy(mem);
 	return NULL;
 }
@@ -2713,6 +2724,14 @@ static int _update_pv_list(struct dm_pool *pvmem, struct dm_list *all_pvs, struc
 	return 1;
 }
 
+static void _free_pv_list(struct dm_list *all_pvs)
+{
+	struct pv_list *pvl;
+
+	dm_list_iterate_items(pvl, all_pvs)
+		pvl->pv->fid->fmt->ops->destroy_instance(pvl->pv->fid);
+}
+
 int vg_missing_pv_count(const struct volume_group *vg)
 {
 	int ret = 0;
@@ -3021,6 +3040,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			if (!correct_vg) {
 				correct_vg = vg;
 				if (!_update_pv_list(cmd->mem, &all_pvs, correct_vg)) {
+					_free_pv_list(&all_pvs);
 					free_vg(vg);
 					return_NULL;
 				}
@@ -3045,6 +3065,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 					inconsistent_seqno = 1;
 				}
 				if (!_update_pv_list(cmd->mem, &all_pvs, vg)) {
+					_free_pv_list(&all_pvs);
 					free_vg(vg);
 					free_vg(correct_vg);
 					return_NULL;
@@ -3060,8 +3081,10 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		}
 
 		/* Give up looking */
-		if (!correct_vg)
+		if (!correct_vg) {
+			_free_pv_list(&all_pvs);
 			return_NULL;
+		}
 	}
 
 	/*
@@ -3084,20 +3107,25 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			 */
 			if (!inconsistent_seqno) {
 				*consistent = 0;
+				_free_pv_list(&all_pvs);
 				return correct_vg;
 			}
+			_free_pv_list(&all_pvs);
 			free_vg(correct_vg);
 			return NULL;
 		}
 
-		if (!*consistent)
+		if (!*consistent) {
+			_free_pv_list(&all_pvs);
 			return correct_vg;
+		}
 
 		/* Don't touch if vgids didn't match */
 		if (inconsistent_vgid) {
 			log_error("Inconsistent metadata UUIDs found for "
 				  "volume group %s", vgname);
 			*consistent = 0;
+			_free_pv_list(&all_pvs);
 			return correct_vg;
 		}
 
@@ -3114,6 +3142,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		cmd->handles_missing_pvs = 1;
 		if (!vg_write(correct_vg)) {
 			log_error("Automatic metadata correction failed");
+			_free_pv_list(&all_pvs);
 			free_vg(correct_vg);
 			cmd->handles_missing_pvs = saved_handles_missing_pvs;
 			return NULL;
@@ -3123,6 +3152,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		if (!vg_commit(correct_vg)) {
 			log_error("Automatic metadata correction commit "
 				  "failed");
+			_free_pv_list(&all_pvs);
 			free_vg(correct_vg);
 			return NULL;
 		}
@@ -3133,12 +3163,14 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 					goto next_pv;
 			}
 			if (!id_write_format(&pvl->pv->id, uuid, sizeof(uuid))) {
+				_free_pv_list(&all_pvs);
 				free_vg(correct_vg);
 				return_NULL;
 			}
 			log_error("Removing PV %s (%s) that no longer belongs to VG %s",
 				  pv_dev_name(pvl->pv), uuid, correct_vg->name);
 			if (!pv_write_orphan(cmd, pvl->pv)) {
+				_free_pv_list(&all_pvs);
 				free_vg(correct_vg);
 				return_NULL;
 			}
@@ -3150,6 +3182,8 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		}
 	}
 
+	_free_pv_list(&all_pvs);
+
 	if (vg_missing_pv_count(correct_vg)) {
 		log_verbose("There are %d physical volumes missing.",
 			    vg_missing_pv_count(correct_vg));
@@ -3209,6 +3243,15 @@ struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgnam
 	return vg;
 }
 
+void free_pv_fid(struct physical_volume *pv)
+{
+	if (!pv)
+		return;
+
+	if (pv->fid)
+		pv->fid->fmt->ops->destroy_instance(pv->fid);
+}
+
 void free_vg(struct volume_group *vg)
 {
 	if (!vg)
@@ -3455,7 +3498,8 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 
 	return pv;
 bad:
-	_free_pv(pvmem, pv);
+	free_pv_fid(pv);
+	dm_pool_free(pvmem, pv);
 	return NULL;
 }
 
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 03e73cd..793a68b 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1463,11 +1463,15 @@ struct logical_volume *find_pvmove_lv_from_pvname(struct cmd_context *cmd,
 						  uint32_t lv_type)
 {
 	struct physical_volume *pv;
+	struct logical_volume *lv;
 
 	if (!(pv = find_pv_by_name(cmd, name)))
 		return_NULL;
 
-	return find_pvmove_lv(vg, pv->dev, lv_type);
+	lv = find_pvmove_lv(vg, pv->dev, lv_type);
+	free_pv_fid(pv);
+
+	return lv;
 }
 
 struct dm_list *lvs_using_lv(struct cmd_context *cmd, struct volume_group *vg,
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index b35bc81..f8b5587 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -791,6 +791,7 @@ static void _remove_missing_empty_pv(struct volume_group *vg, struct dm_list *re
 			vg->free_count -= pvl_vg->pv->pe_count;
 			vg->extent_count -= pvl_vg->pv->pe_count;
 			del_pvl_from_vgs(vg, pvl_vg);
+			free_pv_fid(pvl_vg->pv);
 
 			removed++;
 		}
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index a955d37..90fd2b4 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -93,6 +93,7 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 	int i;
 	int ret = ECMD_PROCESSED;
 	struct pvcreate_params pp;
+	struct physical_volume *pv;
 
 	pvcreate_params_set_defaults(&pp);
 
@@ -111,11 +112,12 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 
 		unescape_colons_and_at_signs(argv[i], NULL, NULL);
 
-		if (!pvcreate_single(cmd, argv[i], &pp)) {
+		if (!(pv = pvcreate_single(cmd, argv[i], &pp))) {
 			stack;
 			ret = ECMD_FAILED;
 		}
 
+		free_pv_fid(pv);
 		unlock_vg(cmd, VG_ORPHANS);
 		if (sigint_caught())
 			return ret;
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 51f442f..c661e62 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -431,11 +431,13 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 		if (!(lv_name = _extract_lvname(cmd, pv_vg_name(pv),
 						arg_value(cmd, name_ARG)))) {
 			stack;
+			free_pv_fid(pv);
 			return EINVALID_CMD_LINE;
 		}
 
 		if (!validate_name(lv_name)) {
 			log_error("Logical volume name %s is invalid", lv_name);
+			free_pv_fid(pv);
 			return EINVALID_CMD_LINE;
 		}
 	}
@@ -510,6 +512,7 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 	/* LVs are all in status LOCKED */
 	r = ECMD_PROCESSED;
 out:
+	free_pv_fid(pv);
 	unlock_and_free_vg(cmd, vg, pv_vg_name(pv));
 	return r;
 }
@@ -600,6 +603,7 @@ static struct volume_group *_get_move_vg(struct cmd_context *cmd,
 					 const char *uuid __attribute__((unused)))
 {
 	struct physical_volume *pv;
+	struct volume_group *vg;
 
 	/* Reread all metadata in case it got changed */
 	if (!(pv = find_pv_by_name(cmd, name))) {
@@ -608,7 +612,10 @@ static struct volume_group *_get_move_vg(struct cmd_context *cmd,
 		return NULL;
 	}
 
-	return _get_vg(cmd, pv_vg_name(pv));
+	vg = _get_vg(cmd, pv_vg_name(pv));
+	free_pv_fid(pv);
+
+	return vg;
 }
 
 static struct poll_functions _pvmove_fns = {
diff --git a/tools/pvremove.c b/tools/pvremove.c
index 36da62d..060303e 100644
--- a/tools/pvremove.c
+++ b/tools/pvremove.c
@@ -49,31 +49,34 @@ static int pvremove_check(struct cmd_context *cmd, const char *name)
 		if (!scan_vgs_for_pvs(cmd, 0)) {
 			log_error("Rescan for PVs without metadata areas "
 				  "failed.");
-			return 0;
+			goto bad;
 		}
+		free_pv_fid(pv);
 		if (!(pv = pv_read(cmd, name, NULL, 1, 0))) {
 			log_error("Failed to read physical volume %s", name);
-			return 0;
+			goto bad;
 		}
 	}
 
 	/* orphan ? */
-	if (is_orphan(pv))
+	if (is_orphan(pv)) {
+		free_pv_fid(pv);
 		return 1;
+	}
 
 	/* Allow partial & exported VGs to be destroyed. */
 	/* we must have -ff to overwrite a non orphan */
 	if (arg_count(cmd, force_ARG) < 2) {
 		log_error("PV %s belongs to Volume Group %s so please use vgreduce first.", name, pv_vg_name(pv));
 		log_error("(If you are certain you need pvremove, then confirm by using --force twice.)");
-		return 0;
+		goto bad;
 	}
 
 	/* prompt */
 	if (!arg_count(cmd, yes_ARG) &&
 	    yes_no_prompt(_really_wipe, name, pv_vg_name(pv)) == 'n') {
 		log_error("%s: physical volume label not removed", name);
-		return 0;
+		goto bad;
 	}
 
 	if (arg_count(cmd, force_ARG)) {
@@ -84,7 +87,12 @@ static int pvremove_check(struct cmd_context *cmd, const char *name)
 			  !is_orphan(pv) ? "\"" : "");
 	}
 
+	free_pv_fid(pv);
 	return 1;
+
+bad:
+	free_pv_fid(pv);
+	return 0;
 }
 
 static int pvremove_single(struct cmd_context *cmd, const char *pv_name,
diff --git a/tools/pvresize.c b/tools/pvresize.c
index 31d8929..b12fcbc 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -126,6 +126,8 @@ out:
 		log_error("Use pvcreate and vgcfgrestore "
 			  "to repair from archived metadata.");
 	unlock_vg(cmd, vg_name);
+	if (is_orphan_vg(vg_name))
+		free_pv_fid(pv);
 	if (!old_vg)
 		free_vg(vg);
 	return r;
diff --git a/tools/pvscan.c b/tools/pvscan.c
index b24b7ab..b40be6d 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -183,8 +183,10 @@ int pvscan(struct cmd_context *cmd, int argc __attribute__((unused)),
 	pv_max_name_len += 2;
 	vg_max_name_len += 2;
 
-	dm_list_iterate_items(pvl, pvslist)
+	dm_list_iterate_items(pvl, pvslist) {
 	    _pvscan_display_single(cmd, pvl->pv, NULL);
+	    free_pv_fid(pvl->pv);
+	}
 
 	if (!pvs_found) {
 		log_print("No matching physical volumes found");
diff --git a/tools/toollib.c b/tools/toollib.c
index e671987..2e95f3a 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -658,6 +658,9 @@ static int _process_all_devs(struct cmd_context *cmd, void *handle,
 			pv = &pv_dummy;
 		}
 		ret = process_single_pv(cmd, NULL, pv, handle);
+
+		free_pv_fid(pv);
+
 		if (ret > ret_max)
 			ret_max = ret;
 		if (sigint_caught())
@@ -757,6 +760,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 						continue;
 					}
 					scanned = 1;
+					free_pv_fid(pv);
 					if (!(pv = pv_read(cmd, argv[opt],
 							   NULL, 1,
 							   scan_label_only))) {
@@ -770,6 +774,14 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 			}
 
 			ret = process_single_pv(cmd, vg, pv, handle);
+
+			/*
+			 * Free PV only if we called pv_read before,
+			 * otherwise the PV structure is part of the VG.
+			 */
+			if (!vg)
+				free_pv_fid(pv);
+
 			if (ret > ret_max)
 				ret_max = ret;
 			if (sigint_caught())
@@ -823,6 +835,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 			dm_list_iterate_items(pvl, pvslist) {
 				ret = process_single_pv(cmd, NULL, pvl->pv,
 						     handle);
+				free_pv_fid(pvl->pv);
 				if (ret > ret_max)
 					ret_max = ret;
 				if (sigint_caught())
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index 5c42f3b..76da0d8 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -146,6 +146,7 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 				  pv_dev_name(pv));
 			log_error("Use pvcreate and vgcfgrestore to repair "
 				  "from archived metadata.");
+			free_pv_fid(pv);
 			return ECMD_FAILED;
 		}
 
@@ -156,11 +157,13 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 				  pv_dev_name(pv));
 			log_error("Use pvcreate and vgcfgrestore to repair "
 				  "from archived metadata.");
+			free_pv_fid(pv);
 			return ECMD_FAILED;
 		}
 		log_verbose("Physical volume \"%s\" successfully created",
 			    pv_dev_name(pv));
 
+		free_pv_fid(pv);
 	}
 
 	log_verbose("Deleting existing metadata for VG %s", vg_name);
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index d497c76..1cabc8d 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -40,6 +40,7 @@ static int _remove_pv(struct volume_group *vg, struct pv_list *pvl, int silent)
 	vg->free_count -= pvl->pv->pe_count;
 	vg->extent_count -= pvl->pv->pe_count;
 	del_pvl_from_vgs(vg, pvl);
+	free_pv_fid(pvl->pv);
 
 	return 1;
 }
@@ -450,6 +451,8 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 	log_print("Removed \"%s\" from volume group \"%s\"", name, vg->name);
 	r = ECMD_PROCESSED;
 bad:
+	if (pvl)
+		free_pv_fid(pvl->pv);
 	unlock_and_free_vg(cmd, orphan_vg, VG_ORPHANS);
 	return r;
 }
-- 
1.7.4


