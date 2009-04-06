From: Milan Broz <mbroz@redhat.com>
Date: Mon, 06 Apr 2009 10:33:04 +0200
Subject: [PATCH 5/6] vg mempool: fix metadata manipulation code
Message-ID: <49D9BE40.1060504@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Properly release VG memory pool in metadata manipulation code.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/metadata.c |  109 +++++++++++++++++++++++++++++++++++------------
 1 files changed, 81 insertions(+), 28 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index dd6ce54..1ded911 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -112,7 +112,7 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 {
 	struct pv_list *pvl;
 	struct format_instance *fid = vg->fid;
-	struct dm_pool *mem = fid->fmt->cmd->mem;
+	struct dm_pool *mem = vg->vgmem;
 
 	log_verbose("Adding physical volume '%s' to volume group '%s'",
 		    pv_name, vg->name);
@@ -242,7 +242,7 @@ int get_pv_from_vg_by_id(const struct format_type *fmt, const char *vg_name,
 {
 	struct volume_group *vg;
 	struct pv_list *pvl;
-	int consistent = 0;
+	int r = 0, consistent = 0;
 
 	if (!(vg = vg_read_internal(fmt->cmd, vg_name, vgid, &consistent))) {
 		log_error("get_pv_from_vg_by_id: vg_read_internal failed to read VG %s",
@@ -258,13 +258,16 @@ int get_pv_from_vg_by_id(const struct format_type *fmt, const char *vg_name,
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
@@ -317,7 +320,7 @@ int validate_vg_rename_params(struct cmd_context *cmd,
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name)
 {
-	struct dm_pool *mem = cmd->mem;
+	struct dm_pool *mem = vg->vgmem;
 	struct pv_list *pvl;
 
 	if (!(vg->name = dm_pool_strdup(mem, new_name))) {
@@ -1824,18 +1827,25 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
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
@@ -1885,14 +1895,17 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 
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
@@ -1932,8 +1945,10 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
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
 
@@ -1946,11 +1961,19 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
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
@@ -1965,6 +1988,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		if (use_precommitted) {
 			log_error("Inconsistent pre-commit metadata copies "
 				  "for volume group %s", vgname);
+			vg_release(correct_vg);
 			return NULL;
 		}
 
@@ -1984,12 +2008,14 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 
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
 
@@ -1998,12 +2024,16 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
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
@@ -2020,6 +2050,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			  "volume group %s", correct_vg->name);
 		log_error("Please restore the metadata by running "
 			  "vgcfgrestore.");
+		vg_release(correct_vg);
 		return NULL;
 	}
 
@@ -2039,6 +2070,7 @@ struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgnam
 	if (!check_pv_segments(vg)) {
 		log_error("Internal error: PV segments corrupted in %s.",
 			  vg->name);
+		vg_release(vg);
 		return NULL;
 	}
 
@@ -2046,6 +2078,7 @@ struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgnam
 		if (!check_lv_segments(lvl->lv, 1)) {
 			log_error("Internal error: LV segments corrupted in %s.",
 				  lvl->lv->name);
+			vg_release(vg);
 			return NULL;
 		}
 	}
@@ -2072,7 +2105,7 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 {
 	const char *vgname;
 	struct dm_list *vgnames;
-	struct volume_group *vg;
+	struct volume_group *vg = NULL;
 	struct lvmcache_vginfo *vginfo;
 	struct str_list *strl;
 	int consistent = 0;
@@ -2090,11 +2123,12 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
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
@@ -2103,7 +2137,7 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 	// The slow way - full scan required to cope with vgrename
 	if (!(vgnames = get_vgnames(cmd, 2))) {
 		log_error("vg_read_by_vgid: get_vgnames failed");
-		return NULL;
+		goto out;
 	}
 
 	dm_list_iterate_items(strl, vgnames) {
@@ -2118,12 +2152,14 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
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
 
@@ -2146,14 +2182,17 @@ struct logical_volume *lv_from_lvid(struct cmd_context *cmd, const char *lvid_s,
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
@@ -2294,10 +2333,12 @@ static int _get_pvs(struct cmd_context *cmd, struct dm_list **pvslist)
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
 
@@ -2527,12 +2568,12 @@ vg_t *vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
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
 
@@ -2547,9 +2588,17 @@ static vg_t *_vg_make_handle(struct cmd_context *cmd,
 			     struct volume_group *vg,
 			     uint32_t failure)
 {
-	if (!vg && !(vg = dm_pool_zalloc(cmd->mem, sizeof(*vg)))) {
-		log_error("Error allocating vg handle.");
-		return_NULL;
+	struct dm_pool *vgmem;
+
+	if (!vg) {
+		if (!(vgmem = dm_pool_create("lvm2 vg_handle", VG_MEMPOOL_SIZE)) &&
+		    !(vg = dm_pool_zalloc(vgmem, sizeof(*vg)))) {
+			log_error("Error allocating vg handle.");
+			if (vgmem)
+				dm_pool_destroy(vgmem);
+			return_NULL;
+		}
+		vg->vgmem = vgmem;
 	}
 
 	vg->read_status = failure;
@@ -2577,8 +2626,10 @@ static vg_t *_recover_vg(struct cmd_context *cmd, const char *lock_name,
 	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent)))
 		return_NULL;
 
-	if (!consistent)
+	if (!consistent) {
+		vg_release(vg);
 		return_NULL;
+	}
 
 	return (vg_t *)vg;
 }
@@ -2598,7 +2649,7 @@ static vg_t *_vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
 			       const char *vgid, uint32_t lock_flags,
 			       uint32_t status_flags, uint32_t misc_flags)
 {
-	struct volume_group *vg = 0;
+	struct volume_group *vg = NULL;
 	const char *lock_name;
  	int consistent = 1;
 	int consistent_in;
@@ -2654,13 +2705,15 @@ static vg_t *_vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
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



