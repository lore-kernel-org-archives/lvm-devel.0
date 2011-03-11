From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Mar 2011 14:56:58 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20110311145658.18457.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-03-11 14:56:56

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h metadata.c mirror.c 
	tools          : lvconvert.c pvcreate.c pvmove.c pvremove.c 
	                 pvresize.c pvscan.c toollib.c vgconvert.c 
	                 vgreduce.c 

Log message:
	Add new free_pv_fid fn and use it throughout to free all attached fids.
	
	Since format instances will use own memory pool, it's necessary to properly
	deallocate it. For now, only fid is deallocated. The PV structure itself
	still uses cmd mempool mostly, but anytime we'd like to add a mempool
	in the struct physical_volume, we can just rename this fn to free_pv and
	add the code (like we have free_vg fn for VGs).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1948&r2=1.1949
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.186&r2=1.187
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.444&r2=1.445
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.143&r2=1.144
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.157&r2=1.158
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.93&r2=1.94
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.224&r2=1.225
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.108&r2=1.109

--- LVM2/WHATS_NEW	2011/03/11 14:50:13	1.1948
+++ LVM2/WHATS_NEW	2011/03/11 14:56:56	1.1949
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Add new free_pv_fid fn and use it throughout to free all attached fids.
   Use only vg_set_fid and new pv_set_fid fn to assign the format instance.
   Make create_text_context fn static and move it inside create_instance fn.
   Add mem and ref_count fields to struct format_instance for own mempool use.
--- LVM2/lib/metadata/metadata-exported.h	2011/03/11 14:38:39	1.186
+++ LVM2/lib/metadata/metadata-exported.h	2011/03/11 14:56:56	1.187
@@ -460,6 +460,14 @@
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
--- LVM2/lib/metadata/metadata.c	2011/03/11 14:50:15	1.444
+++ LVM2/lib/metadata/metadata.c	2011/03/11 14:56:56	1.445
@@ -644,8 +644,10 @@
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
 
@@ -1319,6 +1321,7 @@
 	 * system.
 	 */
 	if (pv && is_orphan(pv) && !dm_list_size(&pv->fid->metadata_areas_in_use)) {
+		free_pv_fid(pv);
 		if (!scan_vgs_for_pvs(cmd, 0))
 			return_0;
 		pv = pv_read(cmd, name, NULL, 0, 0);
@@ -1329,18 +1332,18 @@
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
 
@@ -1355,7 +1358,7 @@
 
 	if (!dev) {
 		log_error("Device %s not found (or ignored by filtering).", name);
-		return 0;
+		goto bad;
 	}
 
 	/*
@@ -1365,20 +1368,20 @@
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
@@ -1388,7 +1391,12 @@
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
@@ -1426,7 +1434,7 @@
 					 const char *pv_name,
 					 struct pvcreate_params *pp)
 {
-	struct physical_volume *pv;
+	struct physical_volume *pv = NULL;
 	struct device *dev;
 	struct dm_list mdas;
 	struct pvcreate_params default_pp;
@@ -1441,23 +1449,23 @@
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
@@ -1468,7 +1476,7 @@
 			     pp->labelsector, pp->pvmetadatacopies,
 			     pp->pvmetadatasize, pp->metadataignore))) {
 		log_error("Failed to setup physical volume \"%s\"", pv_name);
-		goto error;
+		goto bad;
 	}
 
 	log_verbose("Set up physical volume for \"%s\" with %" PRIu64
@@ -1477,20 +1485,20 @@
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
@@ -1500,22 +1508,18 @@
 
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
@@ -1654,7 +1658,8 @@
 	return pv;
 
       bad:
-	_free_pv(mem, pv);
+	free_pv_fid(pv);
+	dm_pool_free(mem, pv);
 	return NULL;
 }
 
@@ -1806,25 +1811,30 @@
 
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
@@ -2638,7 +2648,7 @@
 	struct lvmcache_info *info;
 	struct pv_list *pvl;
 	struct volume_group *vg;
-	struct physical_volume *pv;
+	struct physical_volume *pv = NULL;
 
 	lvmcache_label_scan(cmd, 0);
 
@@ -2673,6 +2683,7 @@
 
 	return vg;
 bad:
+	free_pv_fid(pv);
 	free_vg(vg);
 	return NULL;
 }
@@ -2703,6 +2714,14 @@
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
@@ -3011,6 +3030,7 @@
 			if (!correct_vg) {
 				correct_vg = vg;
 				if (!_update_pv_list(cmd->mem, &all_pvs, correct_vg)) {
+					_free_pv_list(&all_pvs);
 					free_vg(vg);
 					return_NULL;
 				}
@@ -3035,6 +3055,7 @@
 					inconsistent_seqno = 1;
 				}
 				if (!_update_pv_list(cmd->mem, &all_pvs, vg)) {
+					_free_pv_list(&all_pvs);
 					free_vg(vg);
 					free_vg(correct_vg);
 					return_NULL;
@@ -3050,8 +3071,10 @@
 		}
 
 		/* Give up looking */
-		if (!correct_vg)
+		if (!correct_vg) {
+			_free_pv_list(&all_pvs);
 			return_NULL;
+		}
 	}
 
 	/*
@@ -3074,20 +3097,25 @@
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
 
@@ -3104,6 +3132,7 @@
 		cmd->handles_missing_pvs = 1;
 		if (!vg_write(correct_vg)) {
 			log_error("Automatic metadata correction failed");
+			_free_pv_list(&all_pvs);
 			free_vg(correct_vg);
 			cmd->handles_missing_pvs = saved_handles_missing_pvs;
 			return NULL;
@@ -3123,12 +3152,14 @@
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
@@ -3140,6 +3171,8 @@
 		}
 	}
 
+	_free_pv_list(&all_pvs);
+
 	if (vg_missing_pv_count(correct_vg)) {
 		log_verbose("There are %d physical volumes missing.",
 			    vg_missing_pv_count(correct_vg));
@@ -3199,6 +3232,15 @@
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
@@ -3445,7 +3487,8 @@
 
 	return pv;
 bad:
-	_free_pv(pvmem, pv);
+	free_pv_fid(pv);
+	dm_pool_free(pvmem, pv);
 	return NULL;
 }
 
--- LVM2/lib/metadata/mirror.c	2011/02/18 14:47:30	1.143
+++ LVM2/lib/metadata/mirror.c	2011/03/11 14:56:56	1.144
@@ -1463,11 +1463,15 @@
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
--- LVM2/tools/lvconvert.c	2011/02/03 01:24:47	1.157
+++ LVM2/tools/lvconvert.c	2011/03/11 14:56:56	1.158
@@ -791,6 +791,7 @@
 			vg->free_count -= pvl_vg->pv->pe_count;
 			vg->extent_count -= pvl_vg->pv->pe_count;
 			del_pvl_from_vgs(vg, pvl_vg);
+			free_pv_fid(pvl_vg->pv);
 
 			removed++;
 		}
--- LVM2/tools/pvcreate.c	2010/12/08 20:50:51	1.93
+++ LVM2/tools/pvcreate.c	2011/03/11 14:56:56	1.94
@@ -93,6 +93,7 @@
 	int i;
 	int ret = ECMD_PROCESSED;
 	struct pvcreate_params pp;
+	struct physical_volume *pv;
 
 	pvcreate_params_set_defaults(&pp);
 
@@ -111,11 +112,12 @@
 
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
--- LVM2/tools/pvmove.c	2010/12/08 20:50:51	1.81
+++ LVM2/tools/pvmove.c	2011/03/11 14:56:56	1.82
@@ -431,11 +431,13 @@
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
@@ -510,6 +512,7 @@
 	/* LVs are all in status LOCKED */
 	r = ECMD_PROCESSED;
 out:
+	free_pv_fid(pv);
 	unlock_and_free_vg(cmd, vg, pv_vg_name(pv));
 	return r;
 }
@@ -600,6 +603,7 @@
 					 const char *uuid __attribute__((unused)))
 {
 	struct physical_volume *pv;
+	struct volume_group *vg;
 
 	/* Reread all metadata in case it got changed */
 	if (!(pv = find_pv_by_name(cmd, name))) {
@@ -608,7 +612,10 @@
 		return NULL;
 	}
 
-	return _get_vg(cmd, pv_vg_name(pv));
+	vg = _get_vg(cmd, pv_vg_name(pv));
+	free_pv_fid(pv);
+
+	return vg;
 }
 
 static struct poll_functions _pvmove_fns = {
--- LVM2/tools/pvremove.c	2011/02/28 19:35:10	1.33
+++ LVM2/tools/pvremove.c	2011/03/11 14:56:56	1.34
@@ -49,31 +49,34 @@
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
@@ -84,7 +87,12 @@
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
--- LVM2/tools/pvresize.c	2011/02/28 17:08:09	1.43
+++ LVM2/tools/pvresize.c	2011/03/11 14:56:56	1.44
@@ -126,6 +126,8 @@
 		log_error("Use pvcreate and vgcfgrestore "
 			  "to repair from archived metadata.");
 	unlock_vg(cmd, vg_name);
+	if (is_orphan_vg(vg_name))
+		free_pv_fid(pv);
 	if (!old_vg)
 		free_vg(vg);
 	return r;
--- LVM2/tools/pvscan.c	2010/07/09 15:34:48	1.52
+++ LVM2/tools/pvscan.c	2011/03/11 14:56:56	1.53
@@ -183,8 +183,10 @@
 	pv_max_name_len += 2;
 	vg_max_name_len += 2;
 
-	dm_list_iterate_items(pvl, pvslist)
+	dm_list_iterate_items(pvl, pvslist) {
 	    _pvscan_display_single(cmd, pvl->pv, NULL);
+	    free_pv_fid(pvl->pv);
+	}
 
 	if (!pvs_found) {
 		log_print("No matching physical volumes found");
--- LVM2/tools/toollib.c	2011/03/02 20:00:09	1.224
+++ LVM2/tools/toollib.c	2011/03/11 14:56:56	1.225
@@ -658,6 +658,9 @@
 			pv = &pv_dummy;
 		}
 		ret = process_single_pv(cmd, NULL, pv, handle);
+
+		free_pv_fid(pv);
+
 		if (ret > ret_max)
 			ret_max = ret;
 		if (sigint_caught())
@@ -757,6 +760,7 @@
 						continue;
 					}
 					scanned = 1;
+					free_pv_fid(pv);
 					if (!(pv = pv_read(cmd, argv[opt],
 							   NULL, 1,
 							   scan_label_only))) {
@@ -770,6 +774,14 @@
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
@@ -823,6 +835,7 @@
 			dm_list_iterate_items(pvl, pvslist) {
 				ret = process_single_pv(cmd, NULL, pvl->pv,
 						     handle);
+				free_pv_fid(pvl->pv);
 				if (ret > ret_max)
 					ret_max = ret;
 				if (sigint_caught())
--- LVM2/tools/vgconvert.c	2011/02/28 13:19:03	1.50
+++ LVM2/tools/vgconvert.c	2011/03/11 14:56:56	1.51
@@ -146,6 +146,7 @@
 				  pv_dev_name(pv));
 			log_error("Use pvcreate and vgcfgrestore to repair "
 				  "from archived metadata.");
+			free_pv_fid(pv);
 			return ECMD_FAILED;
 		}
 
@@ -156,11 +157,13 @@
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
--- LVM2/tools/vgreduce.c	2011/02/28 13:19:03	1.108
+++ LVM2/tools/vgreduce.c	2011/03/11 14:56:56	1.109
@@ -40,6 +40,7 @@
 	vg->free_count -= pvl->pv->pe_count;
 	vg->extent_count -= pvl->pv->pe_count;
 	del_pvl_from_vgs(vg, pvl);
+	free_pv_fid(pvl->pv);
 
 	return 1;
 }
@@ -450,6 +451,8 @@
 	log_print("Removed \"%s\" from volume group \"%s\"", name, vg->name);
 	r = ECMD_PROCESSED;
 bad:
+	if (pvl)
+		free_pv_fid(pvl->pv);
 	unlock_and_free_vg(cmd, orphan_vg, VG_ORPHANS);
 	return r;
 }


