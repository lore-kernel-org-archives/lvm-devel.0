From: Milan Broz <mbroz@redhat.com>
Date: Mon, 06 Apr 2009 10:33:24 +0200
Subject: [PATCH 6/6] vg mempool: fix tools
Message-ID: <49D9BE54.6020300@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Properly release VG memory pool in all CLI tools.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 tools/lvconvert.c  |    5 ++-
 tools/lvcreate.c   |    2 +-
 tools/lvrename.c   |   14 ++++-----
 tools/lvresize.c   |    2 +-
 tools/polldaemon.c |    6 ++--
 tools/pvchange.c   |   54 ++++++++++++++--------------------
 tools/pvcreate.c   |    1 +
 tools/pvdisplay.c  |    3 ++
 tools/pvmove.c     |   56 ++++++++++++-----------------------
 tools/pvresize.c   |   64 +++++++++++++++++-----------------------
 tools/reporter.c   |    4 ++
 tools/toollib.c    |   25 ++++++++++-----
 tools/vgchange.c   |    2 +-
 tools/vgconvert.c  |    2 +-
 tools/vgcreate.c   |    2 +
 tools/vgextend.c   |   16 ++++------
 tools/vgmerge.c    |   18 ++++-------
 tools/vgreduce.c   |   83 ++++++++++++++++++++-------------------------------
 tools/vgrename.c   |   16 +++++-----
 tools/vgscan.c     |    2 +-
 tools/vgsplit.c    |   43 +++++++++++++--------------
 21 files changed, 187 insertions(+), 233 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index cc9c5ca..2ded226 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -772,11 +772,12 @@ bad:
 	if (ret == ECMD_PROCESSED && lp.need_polling) {
 		if (!lv_info(cmd, lvl->lv, &info, 1, 0) || !info.exists) {
 			log_print("Conversion starts after activation");
-			return ret;
+			goto out;
 		}
 		ret = lvconvert_poll(cmd, lp.lv_name_full,
 				     lp.wait_completion ? 0 : 1U);
 	}
-
+out:
+	vg_release(vg);
 	return ret;
 }
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index e25ecdd..e5916db 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -904,6 +904,6 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 	if (!_lvcreate(cmd, vg, &lp))
 		r = ECMD_FAILED;
 
-	unlock_vg(cmd, lp.vg_name);
+	unlock_release_vg(cmd, vg, lp.vg_name);
 	return r;
 }
diff --git a/tools/lvrename.c b/tools/lvrename.c
index 1444566..f816152 100644
--- a/tools/lvrename.c
+++ b/tools/lvrename.c
@@ -27,8 +27,9 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 	char *lv_name_old, *lv_name_new;
 	const char *vg_name, *vg_name_new, *vg_name_old;
 	char *st;
+	int r = ECMD_FAILED;
 
-	struct volume_group *vg;
+	struct volume_group *vg = NULL;
 	struct lv_list *lvl;
 
 	if (argc == 3) {
@@ -115,14 +116,11 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 	if (!lv_rename(cmd, lvl->lv, lv_name_new))
 		goto error;
 
-	unlock_vg(cmd, vg_name);
-
 	log_print("Renamed \"%s\" to \"%s\" in volume group \"%s\"",
 		  lv_name_old, lv_name_new, vg_name);
 
-	return ECMD_PROCESSED;
-
-      error:
-	unlock_vg(cmd, vg_name);
-	return ECMD_FAILED;
+	r = ECMD_PROCESSED;
+error:
+	unlock_release_vg(cmd, vg, vg_name);
+	return r;
 }
diff --git a/tools/lvresize.c b/tools/lvresize.c
index b74978b..0f3ddc2 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -684,7 +684,7 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 	if (!(r = _lvresize(cmd, vg, &lp)))
 		stack;
 
-	unlock_vg(cmd, lp.vg_name);
+	unlock_release_vg(cmd, vg, lp.vg_name);
 
 	return r;
 }
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index b545eaf..0f6da37 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -157,17 +157,17 @@ static int _wait_for_single_mirror(struct cmd_context *cmd, const char *name,
 							     parms->lv_type))) {
 			log_error("ABORTING: Can't find mirror LV in %s for %s",
 				  vg->name, name);
-			unlock_vg(cmd, vg->name);
+			unlock_release_vg(cmd, vg, vg->name);
 			return 0;
 		}
 
 		if (!_check_mirror_status(cmd, vg, lv_mirr, name, parms,
 					  &finished)) {
-			unlock_vg(cmd, vg->name);
+			unlock_release_vg(cmd, vg, vg->name);
 			return 0;
 		}
 
-		unlock_vg(cmd, vg->name);
+		unlock_release_vg(cmd, vg, vg->name);
 	}
 
 	return 1;
diff --git a/tools/pvchange.c b/tools/pvchange.c
index 1ca7363..d5ca3f1 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -36,6 +36,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
 
 	int allocatable = 0;
 	int tagarg = 0;
+	int r = 0;
 
 	if (arg_count(cmd, addtag_ARG))
 		tagarg = addtag_ARG;
@@ -62,27 +63,24 @@ static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
 			return_0;
 
 		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
-			unlock_vg(cmd, vg_name);
 			log_error
 			    ("Unable to find \"%s\" in volume group \"%s\"",
 			     pv_name, vg->name);
-			return 0;
+			goto out;
 		}
 		if (tagarg && !(vg->fid->fmt->features & FMT_TAGS)) {
-			unlock_vg(cmd, vg_name);
 			log_error("Volume group containing %s does not "
 				  "support tags", pv_name);
-			return 0;
+			goto out;
 		}
 		if (arg_count(cmd, uuid_ARG) && lvs_in_vg_activated(vg)) {
-			unlock_vg(cmd, vg_name);
 			log_error("Volume group containing %s has active "
 				  "logical volumes", pv_name);
-			return 0;
+			goto out;
 		}
 		pv = pvl->pv;
 		if (!archive(vg))
-			return 0;
+			goto out;
 	} else {
 		if (tagarg) {
 			log_error("Can't change tag on Physical Volume %s not "
@@ -109,23 +107,22 @@ static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
 		    !(pv->fmt->features & FMT_ORPHAN_ALLOCATABLE)) {
 			log_error("Allocatability not supported by orphan "
 				  "%s format PV %s", pv->fmt->name, pv_name);
-			unlock_vg(cmd, vg_name);
-			return 0;
+			goto out;
 		}
 
 		/* change allocatability for a PV */
 		if (allocatable && (pv_status(pv) & ALLOCATABLE_PV)) {
 			log_error("Physical volume \"%s\" is already "
 				  "allocatable", pv_name);
-			unlock_vg(cmd, vg_name);
-			return 1;
+			r = 1;
+			goto out;
 		}
 
 		if (!allocatable && !(pv_status(pv) & ALLOCATABLE_PV)) {
 			log_error("Physical volume \"%s\" is already "
 				  "unallocatable", pv_name);
-			unlock_vg(cmd, vg_name);
-			return 1;
+			r = 1;
+			goto out;
 		}
 
 		if (allocatable) {
@@ -143,15 +140,13 @@ static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
 			if (!str_list_add(cmd->mem, &pv->tags, tag)) {
 				log_error("Failed to add tag %s to physical "
 					  "volume %s", tag, pv_name);
-				unlock_vg(cmd, vg_name);
-				return 0;
+				goto out;
 			}
 		} else {
 			if (!str_list_del(&pv->tags, tag)) {
 				log_error("Failed to remove tag %s from "
 					  "physical volume" "%s", tag, pv_name);
-				unlock_vg(cmd, vg_name);
-				return 0;
+				goto out;
 			}
 		}
 	} else {
@@ -159,13 +154,10 @@ static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
 		if (!id_create(&pv->id)) {
 			log_error("Failed to generate new random UUID for %s.",
 				  pv_name);
-			unlock_vg(cmd, vg_name);
-			return 0;
-		}
-		if (!id_write_format(&pv->id, uuid, sizeof(uuid))) {
-			unlock_vg(cmd, vg_name);
-			return_0;
+			goto out;
 		}
+		if (!id_write_format(&pv->id, uuid, sizeof(uuid)))
+			goto_out;
 		log_verbose("Changing uuid of %s to %s.", pv_name, uuid);
 		if (!is_orphan(pv)) {
 			orig_vg_name = pv_vg_name(pv);
@@ -181,8 +173,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
 			if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
 				log_error("pv_write with new uuid failed "
 					  "for %s.", pv_name);
-				unlock_vg(cmd, vg_name);
-				return 0;
+				goto out;
 			}
 			pv->vg_name = orig_vg_name;
 			pv->pe_alloc_count = orig_pe_alloc_count;
@@ -196,24 +187,23 @@ static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
 	log_verbose("Updating physical volume \"%s\"", pv_name);
 	if (!is_orphan(pv)) {
 		if (!vg_write(vg) || !vg_commit(vg)) {
-			unlock_vg(cmd, vg_name);
 			log_error("Failed to store physical volume \"%s\" in "
 				  "volume group \"%s\"", pv_name, vg->name);
-			return 0;
+			goto out;
 		}
 		backup(vg);
 	} else if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
-		unlock_vg(cmd, vg_name);
 		log_error("Failed to store physical volume \"%s\"",
 			  pv_name);
-		return 0;
+		goto out;
 	}
 
-	unlock_vg(cmd, vg_name);
-
 	log_print("Physical volume \"%s\" changed", pv_name);
+	r = 1;
+out:
+	unlock_release_vg(cmd, vg, vg_name);
+	return r;
 
-	return 1;
 }
 
 int pvchange(struct cmd_context *cmd, int argc, char **argv)
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 6ac2081..0f71df5 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -310,6 +310,7 @@ static int pvcreate_validate_params(struct cmd_context *cmd,
 		pp->pe_start = pv_pe_start(existing_pv);
 		pp->extent_size = pv_pe_size(existing_pv);
 		pp->extent_count = pv_pe_count(existing_pv);
+		vg_release(vg);
 	}
 
 	if (arg_count(cmd, yes_ARG) && !arg_count(cmd, force_ARG)) {
diff --git a/tools/pvdisplay.c b/tools/pvdisplay.c
index 0c76910..406e631 100644
--- a/tools/pvdisplay.c
+++ b/tools/pvdisplay.c
@@ -22,6 +22,7 @@ static int _pvdisplay_single(struct cmd_context *cmd,
 	struct pv_list *pvl;
 	int ret = ECMD_PROCESSED;
 	uint64_t size;
+	struct volume_group *old_vg = vg;
 
 	const char *pv_name = pv_dev_name(pv);
 	const char *vg_name = NULL;
@@ -82,6 +83,8 @@ static int _pvdisplay_single(struct cmd_context *cmd,
 out:
 	if (vg_name)
 		unlock_vg(cmd, vg_name);
+	if (!old_vg)
+		vg_release(vg);
 
 	return ret;
 }
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 6fb439d..f89ea93 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -355,6 +355,7 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 	struct logical_volume *lv_mirr;
 	unsigned first_time = 1;
 	unsigned exclusive;
+	int r = ECMD_FAILED;
 
 	pv_name_arg = argv[0];
 	argc--;
@@ -397,27 +398,22 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 		if (!(lvs_changed = lvs_using_lv(cmd, vg, lv_mirr))) {
 			log_error
 			    ("ABORTING: Failed to generate list of moving LVs");
-			unlock_vg(cmd, pv_vg_name(pv));
-			return ECMD_FAILED;
+			goto out;
 		}
 
 		/* Ensure mirror LV is active */
 		if (!_activate_lv(cmd, lv_mirr, exclusive)) {
 			log_error
 			    ("ABORTING: Temporary mirror activation failed.");
-			unlock_vg(cmd, pv_vg_name(pv));
-			return ECMD_FAILED;
+			goto out;
 		}
 
 		first_time = 0;
 	} else {
 		/* Determine PE ranges to be moved */
 		if (!(source_pvl = create_pv_list(cmd->mem, vg, 1,
-						  &pv_name_arg, 0))) {
-			stack;
-			unlock_vg(cmd, pv_vg_name(pv));
-			return ECMD_FAILED;
-		}
+						  &pv_name_arg, 0)))
+			goto_out;
 
 		alloc = arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
 		if (alloc == ALLOC_INHERIT)
@@ -425,33 +421,21 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 
 		/* Get PVs we can use for allocation */
 		if (!(allocatable_pvs = _get_allocatable_pvs(cmd, argc, argv,
-							     vg, pv, alloc))) {
-			stack;
-			unlock_vg(cmd, pv_vg_name(pv));
-			return ECMD_FAILED;
-		}
+							     vg, pv, alloc)))
+			goto_out;
 
-		if (!archive(vg)) {
-			unlock_vg(cmd, pv_vg_name(pv));
-			stack;
-			return ECMD_FAILED;
-		}
+		if (!archive(vg))
+			goto_out;
 
 		if (!(lv_mirr = _set_up_pvmove_lv(cmd, vg, source_pvl, lv_name,
 						  allocatable_pvs, alloc,
-						  &lvs_changed))) {
-			stack;
-			unlock_vg(cmd, pv_vg_name(pv));
-			return ECMD_FAILED;
-		}
+						  &lvs_changed)))
+			goto_out;
 	}
 
 	/* Lock lvs_changed and activate (with old metadata) */
-	if (!activate_lvs(cmd, lvs_changed, exclusive)) {
-		stack;
-		unlock_vg(cmd, pv_vg_name(pv));
-		return ECMD_FAILED;
-	}
+	if (!activate_lvs(cmd, lvs_changed, exclusive))
+		goto_out;
 
 	/* FIXME Presence of a mirror once set PVMOVE - now remove associated logic */
 	/* init_pvmove(1); */
@@ -459,17 +443,15 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 
 	if (first_time) {
 		if (!_update_metadata
-		    (cmd, vg, lv_mirr, lvs_changed, PVMOVE_FIRST_TIME)) {
-			stack;
-			unlock_vg(cmd, pv_vg_name(pv));
-			return ECMD_FAILED;
-		}
+		    (cmd, vg, lv_mirr, lvs_changed, PVMOVE_FIRST_TIME))
+			goto_out;
 	}
 
 	/* LVs are all in status LOCKED */
-	unlock_vg(cmd, pv_vg_name(pv));
-
-	return ECMD_PROCESSED;
+	r = ECMD_PROCESSED;
+out:
+	unlock_release_vg(cmd, vg, pv_vg_name(pv));
+	return r;
 }
 
 static int _finish_pvmove(struct cmd_context *cmd, struct volume_group *vg,
diff --git a/tools/pvresize.c b/tools/pvresize.c
index 1ff0a92..3b5f149 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -32,11 +32,13 @@ static int _pv_resize_single(struct cmd_context *cmd,
 	int consistent = 1;
 	uint64_t size = 0;
 	uint32_t new_pe_count = 0;
+	int r = 0;
 	struct dm_list mdas;
 	const char *pv_name = pv_dev_name(pv);
 	const char *vg_name;
 	struct lvmcache_info *info;
 	int mda_count = 0;
+	struct volume_group *old_vg = vg;
 
 	dm_list_init(&mdas);
 
@@ -69,52 +71,45 @@ static int _pv_resize_single(struct cmd_context *cmd,
 			return 0;
 		}
 
-		if (!vg_check_status(vg, CLUSTERED | EXPORTED_VG | LVM_WRITE)) {
-			unlock_vg(cmd, vg_name);
-			return 0;
-		}
+		if (!vg_check_status(vg, CLUSTERED | EXPORTED_VG | LVM_WRITE))
+			goto bad;
 
 		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
-			unlock_vg(cmd, vg_name);
 			log_error("Unable to find \"%s\" in volume group \"%s\"",
 				  pv_name, vg->name);
-			return 0;
+			goto bad;
 		}
 
 		pv = pvl->pv;
 
 		if (!(info = info_from_pvid(pv->dev->pvid, 0))) {
-			unlock_vg(cmd, vg_name);
 			log_error("Can't get info for PV %s in volume group %s",
 				  pv_name, vg->name);
-			return 0;
+			goto bad;
 		}
 
 		mda_count = dm_list_size(&info->mdas);
 
 		if (!archive(vg))
-			return 0;
+			goto bad;
 	}
 
 	/* FIXME Create function to test compatibility properly */
 	if (mda_count > 1) {
 		log_error("%s: too many metadata areas for pvresize", pv_name);
-		unlock_vg(cmd, vg_name);
-		return 0;
+		goto bad;
 	}
 
 	if (!(pv->fmt->features & FMT_RESIZE_PV)) {
 		log_error("Physical volume %s format does not support resizing.",
 			  pv_name);
-		unlock_vg(cmd, vg_name);
-		return 0;
+		goto bad;
 	}
 
 	/* Get new size */
 	if (!dev_get_size(pv_dev(pv), &size)) {
 		log_error("%s: Couldn't get size.", pv_name);
-		unlock_vg(cmd, vg_name);
-		return 0;
+		goto bad;
 	}
 	
 	if (new_size) {
@@ -129,15 +124,13 @@ static int _pv_resize_single(struct cmd_context *cmd,
 	if (size < PV_MIN_SIZE) {
 		log_error("%s: Size must exceed minimum of %ld sectors.",
 			  pv_name, PV_MIN_SIZE);
-		unlock_vg(cmd, vg_name);
-		return 0;
+		goto bad;
 	}
 
 	if (size < pv_pe_start(pv)) {
 		log_error("%s: Size must exceed physical extent start of "
 			  "%" PRIu64 " sectors.", pv_name, pv_pe_start(pv));
-		unlock_vg(cmd, vg_name);
-		return 0;
+		goto bad;
 	}
 
 	pv->size = size;
@@ -151,14 +144,11 @@ static int _pv_resize_single(struct cmd_context *cmd,
 				  "least one physical extent of "
 				  "%" PRIu32 " sectors.", pv_name,
 				  pv_pe_size(pv));
-			unlock_vg(cmd, vg_name);
-			return 0;
+			goto bad;
 		}
 
-		if (!pv_resize(pv, vg, new_pe_count)) {
-			unlock_vg(cmd, vg_name);
-			return_0;
-		}
+		if (!pv_resize(pv, vg, new_pe_count))
+			goto_bad;
 	}
 
 	log_verbose("Resizing volume \"%s\" to %" PRIu64 " sectors.",
@@ -167,25 +157,25 @@ static int _pv_resize_single(struct cmd_context *cmd,
 	log_verbose("Updating physical volume \"%s\"", pv_name);
 	if (!is_orphan_vg(pv_vg_name(pv))) {
 		if (!vg_write(vg) || !vg_commit(vg)) {
-			unlock_vg(cmd, pv_vg_name(pv));
 			log_error("Failed to store physical volume \"%s\" in "
 				  "volume group \"%s\"", pv_name, vg->name);
-			return 0;
+			goto bad;
 		}
 		backup(vg);
-		unlock_vg(cmd, vg_name);
-	} else {
-		if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
-			unlock_vg(cmd, VG_ORPHANS);
-			log_error("Failed to store physical volume \"%s\"",
-				  pv_name);
-			return 0;
-		}
-		unlock_vg(cmd, vg_name);
+	} else if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
+		log_error("Failed to store physical volume \"%s\"",
+			  pv_name);
+		goto bad;;
 	}
 
 	log_print("Physical volume \"%s\" changed", pv_name);
-	return 1;
+	r = 1;
+
+bad:
+	unlock_vg(cmd, vg_name);
+	if (!old_vg)
+		vg_release(vg);
+	return r;
 }
 
 static int _pvresize_single(struct cmd_context *cmd,
diff --git a/tools/reporter.c b/tools/reporter.c
index 7943e26..9d03f58 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -124,6 +124,7 @@ static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 	struct pv_list *pvl;
 	int ret = ECMD_PROCESSED;
 	const char *vg_name = NULL;
+	struct volume_group *old_vg = vg;
 
 	if (is_pv(pv) && !is_orphan(pv) && !vg) {
 		vg_name = pv_vg_name(pv);
@@ -155,6 +156,9 @@ out:
 	if (vg_name)
 		unlock_vg(cmd, vg_name);
 
+	if (!old_vg)
+		vg_release(vg);
+
 	return ret;
 }
 
diff --git a/tools/toollib.c b/tools/toollib.c
index aa2194c..72d08ca 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -279,6 +279,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 		}
 	}
 
+	vg = NULL;
 	dm_list_iterate_items(strl, vgnames) {
 		vgname = strl->str;
 		if (is_orphan_vg(vgname))
@@ -300,21 +301,24 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 				if (!vg_check_status(vg, CLUSTERED)) {
 					if (ret_max < ECMD_FAILED)
 						ret_max = ECMD_FAILED;
+					vg_release(vg);
 					continue;
 				}
 				log_error("Volume group \"%s\" "
 					  "inconsistent", vgname);
 			}
 
+			vg_release(vg);
 			if (!vg || !(vg = recover_vg(cmd, vgname, lock_type))) {
 				if (ret_max < ECMD_FAILED)
 					ret_max = ECMD_FAILED;
+				vg_release(vg);
 				continue;
 			}
 		}
 
 		if (!vg_check_status(vg, CLUSTERED)) {
-			unlock_vg(cmd, vgname);
+			unlock_release_vg(cmd, vg, vgname);
 			if (ret_max < ECMD_FAILED)
 				ret_max = ECMD_FAILED;
 			continue;
@@ -337,6 +341,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 						  dm_pool_strdup(cmd->mem,
 							      lv_name + 1))) {
 					log_error("strlist allocation failed");
+					vg_release(vg);
 					return ECMD_FAILED;
 				}
 			}
@@ -344,7 +349,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 
 		ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg,
 					    handle, process_single);
-		unlock_vg(cmd, vgname);
+		unlock_release_vg(cmd, vg, vgname);
 		if (ret > ret_max)
 			ret_max = ret;
 		if (sigint_caught())
@@ -368,6 +373,7 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 	const char *vg_name = NULL;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
+	struct volume_group *old_vg = vg;
 
 	if (!vg && !is_orphan(pv)) {
 		vg_name = pv_vg_name(pv);
@@ -385,6 +391,7 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 		if (!(pvl = find_pv_in_vg(vg, pv_dev_name(pv)))) {
 			 log_error("Unable to find %s in volume group %s",
 				   pv_dev_name(pv), vg_name);
+			vg_release(vg);
 			return ECMD_FAILED;
 		}
 
@@ -401,6 +408,8 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 
 	if (vg_name)
 		unlock_vg(cmd, vg_name);
+	if (!old_vg)
+		vg_release(vg);
 
 	return ret_max;
 }
@@ -453,7 +462,7 @@ static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
 	}
 
 	if (!vg_check_status(vg, CLUSTERED)) {
-		unlock_vg(cmd, vg_name);
+		unlock_release_vg(cmd, vg, vg_name);
 		return ECMD_FAILED;
 	}
 
@@ -461,7 +470,7 @@ static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
 		/* Only process if a tag matches or it's on arg_vgnames */
 		if (!str_list_match_item(arg_vgnames, vg_name) &&
 		    !str_list_match_list(tags, &vg->tags)) {
-			unlock_vg(cmd, vg_name);
+			unlock_release_vg(cmd, vg, vg_name);
 			return ret_max;
 		}
 	}
@@ -471,7 +480,7 @@ static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
 		ret_max = ret;
 	}
 
-	unlock_vg(cmd, vg_name);
+	unlock_release_vg(cmd, vg, vg_name);
 
 	return ret_max;
 }
@@ -743,12 +752,12 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 					continue;
 				}
 				if (!consistent) {
-					unlock_vg(cmd, sll->str);
+					unlock_release_vg(cmd, vg, sll->str);
 					continue;
 				}
 
 				if (!vg_check_status(vg, CLUSTERED)) {
-					unlock_vg(cmd, sll->str);
+					unlock_release_vg(cmd, vg, sll->str);
 					continue;
 				}
 
@@ -756,7 +765,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 							    handle,
 							    process_single);
 
-				unlock_vg(cmd, sll->str);
+				unlock_release_vg(cmd, vg, sll->str);
 
 				if (ret > ret_max)
 					ret_max = ret;
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 8831a23..eb2b816 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -532,7 +532,7 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 	}
 
 	if (!consistent) {
-		unlock_vg(cmd, vg_name);
+		unlock_release_vg(cmd, vg, vg_name);
 		dev_close_all();
 		log_error("Volume group \"%s\" inconsistent", vg_name);
 		if (!(vg = recover_vg(cmd, vg_name, LCK_VG_WRITE)))
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index 209d597..eb841d7 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -38,7 +38,7 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 	}
 
 	if (!consistent) {
-		unlock_vg(cmd, vg_name);
+		unlock_release_vg(cmd, vg, vg_name);
 		dev_close_all();
 		log_error("Volume group \"%s\" inconsistent", vg_name);
 		if (!(vg = recover_vg(cmd, vg_name, LCK_VG_WRITE)))
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index a4670c3..add394a 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -116,9 +116,11 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	log_print("%s%colume group \"%s\" successfully created",
 		  clustered_message, *clustered_message ? 'v' : 'V', vg->name);
 
+	vg_release(vg);
 	return ECMD_PROCESSED;
 
 bad:
+	vg_release(vg);
 	unlock_vg(cmd, vp_new.vg_name);
 	unlock_vg(cmd, VG_ORPHANS);
 	return ECMD_FAILED;
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 089c44e..5d99cce 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -19,6 +19,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 {
 	char *vg_name;
 	struct volume_group *vg = NULL;
+	int r = ECMD_FAILED;
 
 	if (!argc) {
 		log_error("Please enter volume group name and "
@@ -45,7 +46,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 				    CLUSTERED | EXPORTED_VG |
 				    LVM_WRITE | RESIZEABLE_VG,
 				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
-		 unlock_vg(cmd, VG_ORPHANS);
+		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
 	 }
 /********** FIXME
@@ -71,16 +72,11 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 		goto error;
 
 	backup(vg);
-
-	unlock_vg(cmd, vg_name);
-	unlock_vg(cmd, VG_ORPHANS);
-
 	log_print("Volume group \"%s\" successfully extended", vg_name);
+	r = ECMD_PROCESSED;
 
-	return ECMD_PROCESSED;
-
-      error:
-	unlock_vg(cmd, vg_name);
+error:
+	unlock_release_vg(cmd, vg, vg_name);
 	unlock_vg(cmd, VG_ORPHANS);
-	return ECMD_FAILED;
+	return r;
 }
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index c48fe0b..c847c7e 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -20,6 +20,7 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 {
 	struct volume_group *vg_to, *vg_from;
 	struct lv_list *lvl1, *lvl2;
+	int r = ECMD_FAILED;
 
 	if (!strcmp(vg_name_to, vg_name_from)) {
 		log_error("Duplicate volume group name \"%s\"", vg_name_from);
@@ -37,7 +38,7 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 					 LCK_VG_WRITE | LCK_NONBLOCK,
 					 CLUSTERED | EXPORTED_VG | LVM_WRITE,
 					 CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
-		unlock_vg(cmd, vg_name_to);
+		unlock_release_vg(cmd, vg_to, vg_name_to);
 		return ECMD_FAILED;
 	}
 
@@ -114,18 +115,13 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 	/* FIXME Remove /dev/vgfrom */
 
 	backup(vg_to);
-
-	unlock_vg(cmd, vg_name_from);
-	unlock_vg(cmd, vg_name_to);
-
 	log_print("Volume group \"%s\" successfully merged into \"%s\"",
 		  vg_from->name, vg_to->name);
-	return ECMD_PROCESSED;
-
-      bad:
-	unlock_vg(cmd, vg_name_from);
-	unlock_vg(cmd, vg_name_to);
-	return ECMD_FAILED;
+	r = ECMD_PROCESSED;
+bad:
+	unlock_release_vg(cmd, vg_from, vg_name_from);
+	unlock_release_vg(cmd, vg_to, vg_name_to);
+	return r;
 }
 
 int vgmerge(struct cmd_context *cmd, int argc, char **argv)
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 3b20a61..f8b1b07 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -381,8 +381,9 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 			    void *handle __attribute((unused)))
 {
 	struct pv_list *pvl;
-	struct volume_group *orphan_vg;
+	struct volume_group *orphan_vg = NULL;
 	int consistent = 1;
+	int r = ECMD_FAILED;
 	const char *name = pv_dev_name(pv);
 
 	if (pv_pe_alloc_count(pv)) {
@@ -403,10 +404,8 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 
 	pvl = find_pv_in_vg(vg, name);
 
-	if (!archive(vg)) {
-		unlock_vg(cmd, VG_ORPHANS);
-		return ECMD_FAILED;
-	}
+	if (!archive(vg))
+		goto bad;
 
 	log_verbose("Removing \"%s\" from volume group \"%s\"", name, vg->name);
 
@@ -418,8 +417,7 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 
 	if (!dev_get_size(pv_dev(pv), &pv->size)) {
 		log_error("%s: Couldn't get size.", pv_dev_name(pv));
-		unlock_vg(cmd, VG_ORPHANS);
-		return ECMD_FAILED;
+		goto bad;
 	}
 
 	vg->pv_count--;
@@ -429,45 +427,42 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 	if(!(orphan_vg = vg_read_internal(cmd, vg->fid->fmt->orphan_vg_name, NULL, &consistent)) ||
 	   !consistent) {
 		log_error("Unable to read existing orphan PVs");
-		unlock_vg(cmd, VG_ORPHANS);
-		return ECMD_FAILED;
+		goto bad;
 	}
 
 	if (!vg_split_mdas(cmd, vg, orphan_vg) || !vg->pv_count) {
 		log_error("Cannot remove final metadata area on \"%s\" from \"%s\"",
 			  name, vg->name);
-		unlock_vg(cmd, VG_ORPHANS);
-		return ECMD_FAILED;
+		goto bad;
 	}
 
 	if (!vg_write(vg) || !vg_commit(vg)) {
 		log_error("Removal of physical volume \"%s\" from "
 			  "\"%s\" failed", name, vg->name);
-		unlock_vg(cmd, VG_ORPHANS);
-		return ECMD_FAILED;
+		goto bad;
 	}
 
 	if (!pv_write(cmd, pv, NULL, INT64_C(-1))) {
 		log_error("Failed to clear metadata from physical "
 			  "volume \"%s\" "
 			  "after removal from \"%s\"", name, vg->name);
-		unlock_vg(cmd, VG_ORPHANS);
-		return ECMD_FAILED;
+		goto bad;
 	}
 
-	unlock_vg(cmd, VG_ORPHANS);
 	backup(vg);
 
 	log_print("Removed \"%s\" from volume group \"%s\"", name, vg->name);
-
-	return ECMD_PROCESSED;
+	r = ECMD_PROCESSED;
+bad:
+	unlock_release_vg(cmd, orphan_vg, VG_ORPHANS);
+	return r;
 }
 
 int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct volume_group *vg;
 	char *vg_name;
-	int ret = 1;
+	int ret = ECMD_FAILED;
 	int consistent = 1;
 	int fixed = 1;
 	int repairing = arg_count(cmd, removemissing_ARG);
@@ -523,64 +518,52 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 	if ((!(vg = vg_read_internal(cmd, vg_name, NULL, &consistent)) || !consistent)
 	    && !repairing) {
 		log_error("Volume group \"%s\" doesn't exist", vg_name);
-		unlock_vg(cmd, vg_name);
-		return ECMD_FAILED;
+		goto out;
 	}
 
-	if (vg && !vg_check_status(vg, CLUSTERED)) {
-		unlock_vg(cmd, vg_name);
-		return ECMD_FAILED;
-	}
+	if (vg && !vg_check_status(vg, CLUSTERED))
+		goto out;
 
 	if (repairing) {
 		if (vg && consistent && !vg_missing_pv_count(vg)) {
 			log_error("Volume group \"%s\" is already consistent",
 				  vg_name);
-			unlock_vg(cmd, vg_name);
-			return ECMD_PROCESSED;
+			ret = ECMD_PROCESSED;
+			goto out;
 		}
 
+		vg_release(vg);
 		consistent = !arg_count(cmd, force_ARG);
 		if (!(vg = vg_read_internal(cmd, vg_name, NULL, &consistent))) {
 			log_error("Volume group \"%s\" not found", vg_name);
-			unlock_vg(cmd, vg_name);
-			return ECMD_FAILED;
-		}
-		if (!vg_check_status(vg, CLUSTERED)) {
-			unlock_vg(cmd, vg_name);
-			return ECMD_FAILED;
-		}
-		if (!archive(vg)) {
-			unlock_vg(cmd, vg_name);
-			return ECMD_FAILED;
+			goto out;
 		}
+		if (!vg_check_status(vg, CLUSTERED))
+			goto out;
+		if (!archive(vg))
+			goto out;
 
 		if (arg_count(cmd, force_ARG)) {
-			if (!_make_vg_consistent(cmd, vg)) {
-				unlock_vg(cmd, vg_name);
-				return ECMD_FAILED;
-			}
+			if (!_make_vg_consistent(cmd, vg))
+				goto out;
 		} else
 			fixed = _consolidate_vg(cmd, vg);
 
 		if (!vg_write(vg) || !vg_commit(vg)) {
 			log_error("Failed to write out a consistent VG for %s",
 				  vg_name);
-			unlock_vg(cmd, vg_name);
-			return ECMD_FAILED;
+			goto out;
 		}
-
 		backup(vg);
 
 		if (fixed)
 			log_print("Wrote out consistent volume group %s",
 				  vg_name);
 
+		ret = ECMD_PROCESSED;
 	} else {
-		if (!vg_check_status(vg, EXPORTED_VG | LVM_WRITE | RESIZEABLE_VG)) {
-			unlock_vg(cmd, vg_name);
-			return ECMD_FAILED;
-		}
+		if (!vg_check_status(vg, EXPORTED_VG | LVM_WRITE | RESIZEABLE_VG))
+			goto out;
 
 		/* FIXME: Pass private struct through to all these functions */
 		/* and update in batch here? */
@@ -588,8 +571,8 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 				      _vgreduce_single);
 
 	}
-
-	unlock_vg(cmd, vg_name);
+out:
+	unlock_release_vg(cmd, vg, vg_name);
 
 	return ret;
 
diff --git a/tools/vgrename.c b/tools/vgrename.c
index d48aa10..697d27b 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -28,7 +28,7 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 	char *vg_name_new;
 	const char *vgid = NULL, *vg_name, *vg_name_old;
 	char old_path[NAME_LEN], new_path[NAME_LEN];
-	struct volume_group *vg, *vg_new;
+	struct volume_group *vg = NULL, *vg_new = NULL;
 
 	vg_name_old = skip_dev_dir(cmd, old_vg_path, NULL);
 	vg_name_new = skip_dev_dir(cmd, new_vg_path, NULL);
@@ -83,7 +83,7 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 	}
 
 	if (!vg_check_status(vg, CLUSTERED | LVM_WRITE)) {
-		unlock_vg(cmd, vg_name_old);
+		unlock_release_vg(cmd, vg, vg_name_old);
 		return 0;
 	}
 
@@ -91,7 +91,7 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 	vg_check_status(vg, EXPORTED_VG);
 
 	if (lvs_in_vg_activated_by_uuid_only(vg)) {
-		unlock_vg(cmd, vg_name_old);
+		unlock_release_vg(cmd, vg, vg_name_old);
 		log_error("Volume group \"%s\" still has active LVs",
 			  vg_name_old);
 		/* FIXME Remove this restriction */
@@ -101,7 +101,7 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 	log_verbose("Checking for new volume group \"%s\"", vg_name_new);
 
 	if (!lock_vol(cmd, vg_name_new, LCK_VG_WRITE | LCK_NONBLOCK)) {
-		unlock_vg(cmd, vg_name_old);
+		unlock_release_vg(cmd, vg, vg_name_old);
 		log_error("Can't get lock for %s", vg_name_new);
 		return 0;
 	}
@@ -151,8 +151,8 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 	backup(vg);
 	backup_remove(cmd, vg_name_old);
 
-	unlock_vg(cmd, vg_name_new);
-	unlock_vg(cmd, vg_name_old);
+	unlock_release_vg(cmd, vg_new, vg_name_new);
+	unlock_release_vg(cmd, vg, vg_name_old);
 
 	log_print("Volume group \"%s\" successfully renamed to \"%s\"",
 		  vg_name_old, vg_name_new);
@@ -164,8 +164,8 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 	return 1;
 
       error:
-	unlock_vg(cmd, vg_name_new);
-	unlock_vg(cmd, vg_name_old);
+	unlock_release_vg(cmd, vg_new, vg_name_new);
+	unlock_release_vg(cmd, vg, vg_name_old);
 	return 0;
 }
 
diff --git a/tools/vgscan.c b/tools/vgscan.c
index 3a0258c..e2543aa 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -25,7 +25,7 @@ static int vgscan_single(struct cmd_context *cmd, const char *vg_name,
 	}
 
 	if (!consistent) {
-		unlock_vg(cmd, vg_name);
+		unlock_release_vg(cmd, vg, vg_name);
 		dev_close_all();
 		log_error("Volume group \"%s\" inconsistent", vg_name);
 		/* Don't allow partial switch to this program */
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 9cc7702..87e74a4 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -286,10 +286,11 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	struct vgcreate_params vp_new;
 	struct vgcreate_params vp_def;
 	char *vg_name_from, *vg_name_to;
-	struct volume_group *vg_to, *vg_from;
+	struct volume_group *vg_to = NULL, *vg_from = NULL;
 	int opt;
 	int existing_vg;
 	int consistent;
+	int r = ECMD_FAILED;
 	const char *lv_name;
 
 	if ((arg_count(cmd, name_ARG) + argc) < 3) {
@@ -329,7 +330,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
 	if (!lock_vol(cmd, vg_name_to, LCK_VG_WRITE | LCK_NONBLOCK)) {
 		log_error("Can't get lock for %s", vg_name_to);
-		unlock_vg(cmd, vg_name_from);
+		unlock_release_vg(cmd, vg_from, vg_name_from);
 		return ECMD_FAILED;
 	}
 
@@ -358,15 +359,13 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		vp_def.clustered = 0;
 
 		if (fill_vg_create_params(cmd, vg_name_to, &vp_new, &vp_def)) {
-			unlock_vg(cmd, vg_name_from);
-			unlock_vg(cmd, vg_name_to);
-			return EINVALID_CMD_LINE;
+			r = EINVALID_CMD_LINE;
+			goto bad;
 		}
 
 		if (validate_vg_create_params(cmd, &vp_new)) {
-			unlock_vg(cmd, vg_name_from);
-			unlock_vg(cmd, vg_name_to);
-			return EINVALID_CMD_LINE;
+			r = EINVALID_CMD_LINE;
+			goto bad;
 		}
 
 		if (!(vg_to = vg_create(cmd, vg_name_to, vp_new.extent_size,
@@ -450,12 +449,14 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	 * Finally, remove the EXPORTED flag from the new VG and write it out.
 	 */
 	consistent = 1;
-	if (!test_mode() &&
-	    (!(vg_to = vg_read_internal(cmd, vg_name_to, NULL, &consistent)) ||
-	     !consistent)) {
-		log_error("Volume group \"%s\" became inconsistent: please "
-			  "fix manually", vg_name_to);
-		goto_bad;
+	if (!test_mode()) {
+		vg_release(vg_to);
+		if (!(vg_to = vg_read_internal(cmd, vg_name_to, NULL, &consistent)) ||
+		    !consistent) {
+			log_error("Volume group \"%s\" became inconsistent: please "
+				  "fix manually", vg_name_to);
+			goto_bad;
+		}
 	}
 
 	vg_to->status &= ~EXPORTED_VG;
@@ -465,16 +466,14 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 
 	backup(vg_to);
 
-	unlock_vg(cmd, vg_name_from);
-	unlock_vg(cmd, vg_name_to);
-
 	log_print("%s volume group \"%s\" successfully split from \"%s\"",
 		  existing_vg ? "Existing" : "New",
 		  vg_to->name, vg_from->name);
-	return ECMD_PROCESSED;
 
-      bad:
-	unlock_vg(cmd, vg_name_from);
-	unlock_vg(cmd, vg_name_to);
-	return ECMD_FAILED;
+	r = ECMD_PROCESSED;
+
+bad:
+	unlock_release_vg(cmd, vg_from, vg_name_from);
+	unlock_release_vg(cmd, vg_to, vg_name_to);
+	return r;
 }



