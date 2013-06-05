From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:05:59 +0000 (UTC)
Subject: dev-mornfall-lvmcache - lvmcache: Move device ptr from lvmcache_info into label.
Message-ID: <20130605120559.666B960F90@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ec5f5564de0d0e84c1e2359cad06af2477fa4031
Commit:        ec5f5564de0d0e84c1e2359cad06af2477fa4031
Parent:        1650e1467ca35e3a4dfece81bcda2e2c23bf046b
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Feb 18 19:46:09 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jun 5 12:37:36 2013 +0200

lvmcache: Move device ptr from lvmcache_info into label.

---
 lib/cache/lvmcache.c |   92 +++++++++++++++++++++++++------------------------
 lib/label/label.c    |    4 ++-
 lib/label/label.h    |    1 +
 3 files changed, 51 insertions(+), 46 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index d4e6f03..1c4da0f 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -40,7 +40,6 @@ struct lvmcache_info {
 	struct lvmcache_vginfo *vginfo;	/* NULL == unknown */
 	struct label *label; /* move to PV */
 	const struct format_type *fmt;
-	struct device *dev; /* dup'd from PV */
 	uint64_t device_size;	/* move to label */ /* Bytes */
 	uint32_t status;
 };
@@ -370,7 +369,7 @@ const struct format_type *lvmcache_fmt_from_vgname(struct cmd_context *cmd,
 			log_error("device_list element allocation failed");
 			return NULL;
 		}
-		devl->dev = info->dev;
+		devl->dev = info->label->dev;
 		dm_list_add(&devs, &devl->list);
 	}
 
@@ -526,7 +525,7 @@ static void _rescan_entry(struct lvmcache_info *info)
 	struct label *label;
 
 	if (info->status & CACHE_INVALID)
-		(void) label_read(info->dev, &label, UINT64_C(0));
+		(void) label_read(info->label->dev, &label, UINT64_C(0));
 }
 
 static int _scan_invalid(void)
@@ -786,7 +785,7 @@ struct dm_list *lvmcache_get_pvids(struct cmd_context *cmd, const char *vgname,
 
 	dm_list_iterate_items(info, &vginfo->infos) {
 		if (!str_list_add(cmd->mem, pvids,
-				  dm_pool_strdup(cmd->mem, info->dev->pvid))) {
+				  dm_pool_strdup(cmd->mem, info->label->dev->pvid))) {
 			log_error("strlist allocation failed");
 			return NULL;
 		}
@@ -805,15 +804,15 @@ static struct device *_device_from_pvid(const struct id *pvid,
 		if (lvmetad_active()) {
 			if (info->label && label_sector)
 				*label_sector = info->label->sector;
-			return info->dev;
+			return info->label->dev;
 		}
 
-		if (label_read(info->dev, &label, UINT64_C(0))) {
+		if (label_read(info->label->dev, &label, UINT64_C(0))) {
 			info = (struct lvmcache_info *) label->info;
-			if (id_equal(pvid, (struct id *) &info->dev->pvid)) {
+			if (id_equal(pvid, (struct id *) &info->label->dev->pvid)) {
 				if (label_sector)
 					*label_sector = label->sector;
-				return info->dev;
+				return info->label->dev;
                         }
 		}
 	}
@@ -952,11 +951,13 @@ static int _lvmcache_update_pvid(struct lvmcache_info *info, const char *pvid)
 	 */
 
 	if (((dm_hash_lookup(_pvid_hash, pvid)) == info) &&
-	    !strcmp(info->dev->pvid, pvid))
+	    !strcmp(info->label->dev->pvid, pvid))
 		return 1;
-	if (*info->dev->pvid)
-		dm_hash_remove(_pvid_hash, info->dev->pvid);
-	strncpy(info->dev->pvid, pvid, sizeof(info->dev->pvid));
+
+	if (*info->label->dev->pvid)
+		dm_hash_remove(_pvid_hash, info->label->dev->pvid);
+	strncpy(info->label->dev->pvid, pvid, sizeof(info->label->dev->pvid));
+
 	if (!dm_hash_insert(_pvid_hash, pvid, info)) {
 		log_error("_lvmcache_update: pvid insertion failed: %s", pvid);
 		return 0;
@@ -980,7 +981,7 @@ static int _lvmcache_update_vgid(struct lvmcache_info *info,
 		dm_hash_remove(_vgid_hash, vginfo->vgid);
 	if (!vgid) {
 		/* FIXME: unreachable code path */
-		log_debug_cache("lvmcache: %s: clearing VGID", info ? dev_name(info->dev) : vginfo->vgname);
+		log_debug_cache("lvmcache: %s: clearing VGID", info ? dev_name(info->label->dev) : vginfo->vgname);
 		return 1;
 	}
 
@@ -994,7 +995,7 @@ static int _lvmcache_update_vgid(struct lvmcache_info *info,
 
 	if (!is_orphan_vg(vginfo->vgname))
 		log_debug_cache("lvmcache: %s: setting %s VGID to %s",
-				(info) ? dev_name(info->dev) : "",
+				(info) ? dev_name(info->label->dev) : "",
 				vginfo->vgname, vginfo->vgid);
 
 	return 1;
@@ -1173,7 +1174,7 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 				else
 					mdabuf[0] = '\0';
 				log_debug_cache("lvmcache: %s: now in VG %s%s%s%s%s",
-						dev_name(info2->dev),
+						dev_name(info2->label->dev),
 						vgname, orphan_vginfo->vgid[0] ? " (" : "",
 						orphan_vginfo->vgid[0] ? orphan_vginfo->vgid : "",
 						orphan_vginfo->vgid[0] ? ")" : "", mdabuf);
@@ -1215,7 +1216,7 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 		else
 			mdabuf[0] = '\0';
 		log_debug_cache("lvmcache: %s: now in VG %s%s%s%s%s",
-				dev_name(info->dev),
+				dev_name(info->label->dev),
 				vgname, vginfo->vgid[0] ? " (" : "",
 				vginfo->vgid[0] ? vginfo->vgid : "",
 				vginfo->vgid[0] ? ")" : "", mdabuf);
@@ -1233,7 +1234,7 @@ static int _lvmcache_update_vgstatus(struct lvmcache_info *info, uint32_t vgstat
 
 	if ((info->vginfo->status & EXPORTED_VG) != (vgstatus & EXPORTED_VG))
 		log_debug_cache("lvmcache: %s: VG %s %s exported",
-				dev_name(info->dev), info->vginfo->vgname,
+				dev_name(info->label->dev), info->vginfo->vgname,
 				vgstatus & EXPORTED_VG ? "now" : "no longer");
 
 	info->vginfo->status = vgstatus;
@@ -1255,7 +1256,7 @@ static int _lvmcache_update_vgstatus(struct lvmcache_info *info, uint32_t vgstat
 	}
 
 	log_debug_cache("lvmcache: %s: VG %s: Set creation host to %s.",
-			dev_name(info->dev), info->vginfo->vgname, creation_host);
+			dev_name(info->label->dev), info->vginfo->vgname, creation_host);
 
 	return 1;
 }
@@ -1359,57 +1360,57 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 		label->info = info;
 		info->label = label;
 		dm_list_init(&info->list);
-		info->dev = dev;
+		info->label->dev = dev;
 
 		lvmcache_del_mdas(info);
 		lvmcache_del_das(info);
 		lvmcache_del_bas(info);
 	} else {
-		if (existing->dev != dev) {
+		if (existing->label->dev != dev) {
 			/* Is the existing entry a duplicate pvid e.g. md ? */
-			if (dev_subsystem_part_major(existing->dev) &&
+			if (dev_subsystem_part_major(existing->label->dev) &&
 			    !dev_subsystem_part_major(dev)) {
 				log_very_verbose("Ignoring duplicate PV %s on "
 						 "%s - using %s %s",
 						 pvid, dev_name(dev),
-						 dev_subsystem_name(existing->dev),
-						 dev_name(existing->dev));
+						 dev_subsystem_name(existing->label->dev),
+						 dev_name(existing->label->dev));
 				return NULL;
-			} else if (dm_is_dm_major(MAJOR(existing->dev->dev)) &&
+			} else if (dm_is_dm_major(MAJOR(existing->label->dev->dev)) &&
 				   !dm_is_dm_major(MAJOR(dev->dev))) {
 				log_very_verbose("Ignoring duplicate PV %s on "
 						 "%s - using dm %s",
 						 pvid, dev_name(dev),
-						 dev_name(existing->dev));
+						 dev_name(existing->label->dev));
 				return NULL;
-			} else if (!dev_subsystem_part_major(existing->dev) &&
+			} else if (!dev_subsystem_part_major(existing->label->dev) &&
 				   dev_subsystem_part_major(dev))
 				log_very_verbose("Duplicate PV %s on %s - "
 						 "using %s %s", pvid,
-						 dev_name(existing->dev),
-						 dev_subsystem_name(existing->dev),
+						 dev_name(existing->label->dev),
+						 dev_subsystem_name(existing->label->dev),
 						 dev_name(dev));
-			else if (!dm_is_dm_major(MAJOR(existing->dev->dev)) &&
+			else if (!dm_is_dm_major(MAJOR(existing->label->dev->dev)) &&
 				 dm_is_dm_major(MAJOR(dev->dev)))
 				log_very_verbose("Duplicate PV %s on %s - "
 						 "using dm %s", pvid,
-						 dev_name(existing->dev),
+						 dev_name(existing->label->dev),
 						 dev_name(dev));
 			/* FIXME If both dm, check dependencies */
 			//else if (dm_is_dm_major(MAJOR(existing->dev->dev)) &&
 				 //dm_is_dm_major(MAJOR(dev->dev)))
 				 //
-			else if (!strcmp(pvid_s, existing->dev->pvid)) 
+			else if (!strcmp(pvid_s, existing->label->dev->pvid)) 
 				log_error("Found duplicate PV %s: using %s not "
 					  "%s", pvid, dev_name(dev),
-					  dev_name(existing->dev));
+					  dev_name(existing->label->dev));
 		}
-		if (strcmp(pvid_s, existing->dev->pvid)) 
+		if (existing->label->dev && strcmp(pvid_s, existing->label->dev->pvid)) 
 			log_debug_cache("Updating pvid cache to %s (%s) from %s (%s)",
 					pvid_s, dev_name(dev),
-					existing->dev->pvid, dev_name(existing->dev));
+					existing->label->dev->pvid, dev_name(existing->label->dev));
 		/* Switch over to new preferred device */
-		existing->dev = dev;
+		existing->label->dev = dev; /* XXX */
 		info = existing;
 		/* Has labeller changed? */
 		if (info->label->labeller != labeller) {
@@ -1418,6 +1419,7 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 				/* FIXME leaves info without label! */
 				return_NULL;
 			info->label->info = info;
+			info->label->dev = dev;
 			lvmcache_del_mdas(info);
 			lvmcache_del_das(info);
 		}
@@ -1438,7 +1440,7 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 	if (!lvmcache_update_vgname_and_id(info, vgname, vgid, vgstatus, NULL)) {
 		if (!existing) {
 			dm_hash_remove(_pvid_hash, pvid_s);
-			strcpy(info->dev->pvid, "");
+			strcpy(info->label->dev->pvid, "");
 			dm_free(info);
 			label_destroy(label);
 		}
@@ -1451,7 +1453,7 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 static void _lvmcache_destroy_entry(struct lvmcache_info *info)
 {
 	_vginfo_detach_info(info);
-	strcpy(info->dev->pvid, "");
+	strcpy(info->label->dev->pvid, "");
 	label_destroy(info->label);
 	dm_free(info);
 }
@@ -1518,7 +1520,7 @@ int lvmcache_fid_add_mdas(struct lvmcache_info *info, struct format_instance *fi
 
 int lvmcache_fid_add_mdas_pv(struct lvmcache_info *info, struct format_instance *fid)
 {
-	return lvmcache_fid_add_mdas(info, fid, info->dev->pvid, ID_LEN);
+	return lvmcache_fid_add_mdas(info, fid, info->label->dev->pvid, ID_LEN);
 }
 
 int lvmcache_fid_add_mdas_vg(struct lvmcache_vginfo *vginfo, struct format_instance *fid)
@@ -1548,7 +1550,7 @@ static int _get_pv_if_in_vg(struct lvmcache_info *info,
 		memcpy(vgid, info->vginfo->vgid, sizeof(vgid));
 
 		if (get_pv_from_vg_by_id(info->fmt, vgname, vgid,
-					 info->dev->pvid, pv))
+					 info->label->dev->pvid, pv))
 			return 1;
 	}
 
@@ -1574,23 +1576,23 @@ int lvmcache_populate_pv_fields(struct lvmcache_info *info,
 	}
 
 	/* Orphan */
-	pv->dev = info->dev;
+	pv->dev = info->label->dev;
 	pv->fmt = info->fmt;
 	pv->size = info->device_size >> SECTOR_SHIFT;
 	pv->vg_name = FMT_TEXT_ORPHAN_VG_NAME;
-	memcpy(&pv->id, &info->dev->pvid, sizeof(pv->id));
+	memcpy(&pv->id, &info->label->dev->pvid, sizeof(pv->id));
 
 	/* Currently only support exactly one data area */
 	if (dm_list_size(&info->label->das) != 1) {
 		log_error("Must be exactly one data area (found %d) on PV %s",
-			  dm_list_size(&info->label->das), dev_name(info->dev));
+			  dm_list_size(&info->label->das), dev_name(info->label->dev));
 		return 0;
 	}
 
 	/* Currently only support one embedding area at most */
 	if (dm_list_size(&info->label->bas) > 1) {
 		log_error("Must be at most one embedding area (found %d) on PV %s",
-			  dm_list_size(&info->label->bas), dev_name(info->dev));
+			  dm_list_size(&info->label->bas), dev_name(info->label->dev));
 		return 0;
 	}
 
@@ -1609,7 +1611,7 @@ int lvmcache_check_format(struct lvmcache_info *info, const struct format_type *
 {
 	if (info->fmt != fmt) {
 		log_error("PV %s is a different format (seqno %s)",
-			  dev_name(info->dev), info->fmt->name);
+			  dev_name(info->label->dev), info->fmt->name);
 		return 0;
 	}
 	return 1;
@@ -1773,7 +1775,7 @@ void lvmcache_set_device_size(struct lvmcache_info *info, uint64_t size) {
 }
 
 struct device *lvmcache_device(struct lvmcache_info *info) {
-	return info->dev;
+	return info->label->dev;
 }
 
 int lvmcache_is_orphan(struct lvmcache_info *info) {
diff --git a/lib/label/label.c b/lib/label/label.c
index a38ba68..9c931f5 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -282,8 +282,10 @@ int label_read(struct device *dev, struct label **result,
 	if (!(l = _find_labeller(dev, buf, &sector, scan_sector)))
 		goto out;
 
-	if ((r = (l->ops->read)(l, dev, buf, result)) && result && *result)
+	if ((r = (l->ops->read)(l, dev, buf, result)) && result && *result) {
+		(*result)->dev = dev;
 		(*result)->sector = sector;
+	}
 
       out:
 	if (!dev_close(dev))
diff --git a/lib/label/label.h b/lib/label/label.h
index 60dd176..9a0e07e 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -43,6 +43,7 @@ struct label {
 	uint64_t sector;
 	struct labeller *labeller;
 	void *info;
+	struct device *dev;
 	struct dm_list mdas;	/* list head for metadata areas */
 	struct dm_list das;	/* list head for data areas */
 	struct dm_list bas;	/* list head for embedding areas */


