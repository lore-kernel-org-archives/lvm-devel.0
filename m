From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Oct 2010 21:15:24 -0000
Subject: LVM2 ./WHATS_NEW tools/vgchange.c
Message-ID: <20101029211524.6683.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-10-29 21:15:24

Modified files:
	.              : WHATS_NEW 
	tools          : vgchange.c 

Log message:
	Update VG metadata only once in vgchange when making multiple changes.
	Allow independent vgchange arguments to be used together.
	(Still more inconsistencies to iron out here.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1782&r2=1.1783
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.115&r2=1.116

--- LVM2/WHATS_NEW	2010/10/29 16:44:47	1.1782
+++ LVM2/WHATS_NEW	2010/10/29 21:15:23	1.1783
@@ -1,9 +1,11 @@
-Version 2.02.76
+Version 2.02.76 - 
 ===================================
+  Update VG metadata only once in vgchange when making multiple changes.
+  Allow independent vgchange arguments to be used together.
   Automatically unmount invalidated snapshots in dmeventd.
   Fix a deadlock caused by double close in clvmd.
   Add dmeventd -R to restart dmeventd without losing monitoring state. (2.02.75)
-  Fix NULL pointer dereference for too large MDA error path in _vg_read_raw_area().
+  Fix NULL pointer dereference on too-large MDA error path in _vg_read_raw_area.
   Use static for internal _align_chunk() and _new_chunk() from pool-fast.c.
   Fix vgchange to process -a, --refresh, --monitor and --poll like lvchange.
   Add lvm2app functions to query any pv, vg, or lv property / report field.
--- LVM2/tools/vgchange.c	2010/10/26 01:37:59	1.115
+++ LVM2/tools/vgchange.c	2010/10/29 21:15:23	1.116
@@ -25,7 +25,7 @@
 	struct logical_volume *lv;
 	struct lvinfo info;
 	int lv_active;
-	int r = ECMD_PROCESSED;
+	int r = 1;
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
@@ -42,7 +42,7 @@
 			continue;
 
 		if (!monitor_dev_for_events(cmd, lv, 0, reg)) {
-			r = ECMD_FAILED;
+			r = 0;
 			continue;
 		} else
 			(*count)++;
@@ -155,23 +155,24 @@
 			    (activate == CHANGE_AN || activate == CHANGE_ALN)?
 			    "Deactivated" : "Activated", count, vg->name);
 
-	return (expected_count != count) ? ECMD_FAILED : ECMD_PROCESSED;
+	return (expected_count != count) ? 0 : 1;
 }
 
 static int _vgchange_monitoring(struct cmd_context *cmd, struct volume_group *vg)
 {
-	int ret_max = ECMD_PROCESSED;
+	int r = 1;
 	int monitored = 0;
 
 	if (lvs_in_vg_activated(vg) &&
 	    dmeventd_monitor_mode() != DMEVENTD_MONITOR_IGNORE) {
-		ret_max = max(ret_max, _monitor_lvs_in_vg(cmd, vg, dmeventd_monitor_mode(), &monitored));
+		if (!_monitor_lvs_in_vg(cmd, vg, dmeventd_monitor_mode(), &monitored))
+			r = 0;
 		log_print("%d logical volume(s) in volume group "
 			    "\"%s\" %smonitored",
 			    monitored, vg->name, (dmeventd_monitor_mode()) ? "" : "un");
 	}
 
-	return ret_max;
+	return r;
 }
 
 static int _vgchange_background_polling(struct cmd_context *cmd, struct volume_group *vg)
@@ -186,13 +187,13 @@
 				  polled, vg->name);
 	}
 
-	return ECMD_PROCESSED;
+	return 1;
 }
 
 static int _vgchange_available(struct cmd_context *cmd, struct volume_group *vg)
 {
 	int lv_open, active, monitored = 0;
-	int available, ret_max = ECMD_PROCESSED;
+	int available, r = 1;
 	int activate = 1;
 
 	/*
@@ -210,7 +211,7 @@
 	if (!activate && (lv_open = lvs_in_vg_opened(vg))) {
 		log_error("Can't deactivate volume group \"%s\" with %d open "
 			  "logical volume(s)", vg->name, lv_open);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	/* FIXME Move into library where clvmd can use it */
@@ -221,7 +222,8 @@
 		log_verbose("%d logical volume(s) in volume group \"%s\" "
 			    "already active", active, vg->name);
 		if (dmeventd_monitor_mode() != DMEVENTD_MONITOR_IGNORE) {
-			ret_max = max(ret_max, _monitor_lvs_in_vg(cmd, vg, dmeventd_monitor_mode(), &monitored));
+			if (!_monitor_lvs_in_vg(cmd, vg, dmeventd_monitor_mode(), &monitored))
+				r = 0;
 			log_verbose("%d existing logical volume(s) in volume "
 				    "group \"%s\" %smonitored",
 				    monitored, vg->name,
@@ -229,13 +231,26 @@
 		}
 	}
 
-	ret_max = max(ret_max, _activate_lvs_in_vg(cmd, vg, available));
+	if (!_activate_lvs_in_vg(cmd, vg, available))
+		r = 0;
 
 	/* Print message only if there was not found a missing VG */
 	if (!vg->cmd_missing_vgs)
 		log_print("%d logical volume(s) in volume group \"%s\" now active",
 			  lvs_in_vg_activated(vg), vg->name);
-	return ret_max;
+	return r;
+}
+
+static int _vgchange_refresh(struct cmd_context *cmd, struct volume_group *vg)
+{
+	log_verbose("Refreshing volume group \"%s\"", vg->name);
+
+	if (!vg_refresh_visible(cmd, vg)) {
+		stack;
+		return 0;
+	}
+
+	return 1;
 }
 
 static int _vgchange_alloc(struct cmd_context *cmd, struct volume_group *vg)
@@ -244,32 +259,17 @@
 
 	alloc = arg_uint_value(cmd, alloc_ARG, ALLOC_NORMAL);
 
-	if (!archive(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
 	/* FIXME: make consistent with vg_set_alloc_policy() */
 	if (alloc == vg->alloc) {
 		log_error("Volume group allocation policy is already %s",
 			  get_alloc_string(vg->alloc));
-		return ECMD_FAILED;
-	}
-	if (!vg_set_alloc_policy(vg, alloc)) {
-		stack;
-		return ECMD_FAILED;
+		return 0;
 	}
 
-	if (!vg_write(vg) || !vg_commit(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (!vg_set_alloc_policy(vg, alloc))
+		return_0;
 
-	backup(vg);
-
-	log_print("Volume group \"%s\" successfully changed", vg->name);
-
-	return ECMD_PROCESSED;
+	return 1;
 }
 
 static int _vgchange_resizeable(struct cmd_context *cmd,
@@ -280,18 +280,13 @@
 	if (resizeable && vg_is_resizeable(vg)) {
 		log_error("Volume group \"%s\" is already resizeable",
 			  vg->name);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (!resizeable && !vg_is_resizeable(vg)) {
 		log_error("Volume group \"%s\" is already not resizeable",
 			  vg->name);
-		return ECMD_FAILED;
-	}
-
-	if (!archive(vg)) {
-		stack;
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (resizeable)
@@ -299,16 +294,7 @@
 	else
 		vg->status &= ~RESIZEABLE_VG;
 
-	if (!vg_write(vg) || !vg_commit(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
-	backup(vg);
-
-	log_print("Volume group \"%s\" successfully changed", vg->name);
-
-	return ECMD_PROCESSED;
+	return 1;
 }
 
 static int _vgchange_clustered(struct cmd_context *cmd,
@@ -319,33 +305,19 @@
 	if (clustered && (vg_is_clustered(vg))) {
 		log_error("Volume group \"%s\" is already clustered",
 			  vg->name);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (!clustered && !(vg_is_clustered(vg))) {
 		log_error("Volume group \"%s\" is already not clustered",
 			  vg->name);
-		return ECMD_FAILED;
-	}
-
-	if (!archive(vg)) {
-		stack;
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (!vg_set_clustered(vg, clustered))
-		return ECMD_FAILED;
+		return_0;
 
-	if (!vg_write(vg) || !vg_commit(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
-	backup(vg);
-
-	log_print("Volume group \"%s\" successfully changed", vg->name);
-
-	return ECMD_PROCESSED;
+	return 1;
 }
 
 static int _vgchange_logicalvolume(struct cmd_context *cmd,
@@ -353,26 +325,10 @@
 {
 	uint32_t max_lv = arg_uint_value(cmd, logicalvolume_ARG, 0);
 
-	if (!archive(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
-	if (!vg_set_max_lv(vg, max_lv)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (!vg_set_max_lv(vg, max_lv))
+		return_0;
 
-	if (!vg_write(vg) || !vg_commit(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
-	backup(vg);
-
-	log_print("Volume group \"%s\" successfully changed", vg->name);
-
-	return ECMD_PROCESSED;
+	return 1;
 }
 
 static int _vgchange_physicalvolumes(struct cmd_context *cmd,
@@ -380,70 +336,28 @@
 {
 	uint32_t max_pv = arg_uint_value(cmd, maxphysicalvolumes_ARG, 0);
 
-	if (arg_sign_value(cmd, maxphysicalvolumes_ARG, 0) == SIGN_MINUS) {
-		log_error("MaxPhysicalVolumes may not be negative");
-		return EINVALID_CMD_LINE;
-	}
-
-	if (!archive(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
-	if (!vg_set_max_pv(vg, max_pv)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
-	if (!vg_write(vg) || !vg_commit(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (!vg_set_max_pv(vg, max_pv))
+		return_0;
 
-	backup(vg);
-
-	log_print("Volume group \"%s\" successfully changed", vg->name);
-
-	return ECMD_PROCESSED;
+	return 1;
 }
 
 static int _vgchange_pesize(struct cmd_context *cmd, struct volume_group *vg)
 {
 	uint32_t extent_size;
 
-	if (arg_sign_value(cmd, physicalextentsize_ARG, 0) == SIGN_MINUS) {
-		log_error("Physical extent size may not be negative");
-		return EINVALID_CMD_LINE;
-	}
-
 	extent_size = arg_uint_value(cmd, physicalextentsize_ARG, 0);
 	/* FIXME: remove check - redundant with vg_change_pesize */
 	if (extent_size == vg->extent_size) {
 		log_error("Physical extent size of VG %s is already %s",
 			  vg->name, display_size(cmd, (uint64_t) extent_size));
-		return ECMD_PROCESSED;
+		return 1;
 	}
 
-	if (!archive(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (!vg_set_extent_size(vg, extent_size))
+		return_0;
 
-	if (!vg_set_extent_size(vg, extent_size)) {
-		stack;
-		return EINVALID_CMD_LINE;
-	}
-
-	if (!vg_write(vg) || !vg_commit(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
-	backup(vg);
-
-	log_print("Volume group \"%s\" successfully changed", vg->name);
-
-	return ECMD_PROCESSED;
+	return 1;
 }
 
 static int _vgchange_tag(struct cmd_context *cmd, struct volume_group *vg,
@@ -453,29 +367,23 @@
 
 	if (!(tag = arg_str_value(cmd, arg, NULL))) {
 		log_error("Failed to get tag");
-		return ECMD_FAILED;
+		return 0;
 	}
 
-	if (!archive(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (!vg_change_tag(vg, tag, arg == addtag_ARG))
+		return_0;
 
-	if (!vg_change_tag(vg, tag, arg == addtag_ARG)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
-	if (!vg_write(vg) || !vg_commit(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
-	backup(vg);
+	return 1;
+}
 
-	log_print("Volume group \"%s\" successfully changed", vg->name);
+static int _vgchange_addtag(struct cmd_context *cmd, struct volume_group *vg)
+{
+	return _vgchange_tag(cmd, vg, addtag_ARG);
+}
 
-	return ECMD_PROCESSED;
+static int _vgchange_deltag(struct cmd_context *cmd, struct volume_group *vg)
+{
+	return _vgchange_tag(cmd, vg, deltag_ARG);
 }
 
 static int _vgchange_uuid(struct cmd_context *cmd __attribute__((unused)),
@@ -485,46 +393,20 @@
 
 	if (lvs_in_vg_activated(vg)) {
 		log_error("Volume group has active logical volumes");
-		return ECMD_FAILED;
-	}
-
-	if (!archive(vg)) {
-		stack;
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (!id_create(&vg->id)) {
 		log_error("Failed to generate new random UUID for VG %s.",
 			  vg->name);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		memcpy(&lvl->lv->lvid, &vg->id, sizeof(vg->id));
 	}
 
-	if (!vg_write(vg) || !vg_commit(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
-	backup(vg);
-
-	log_print("Volume group \"%s\" successfully changed", vg->name);
-
-	return ECMD_PROCESSED;
-}
-
-static int _vgchange_refresh(struct cmd_context *cmd, struct volume_group *vg)
-{
-	log_verbose("Refreshing volume group \"%s\"", vg->name);
-
-	if (!vg_refresh_visible(cmd, vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
-	return ECMD_PROCESSED;
+	return 1;
 }
 
 static int _vgchange_metadata_copies(struct cmd_context *cmd,
@@ -539,36 +421,39 @@
 		else
 			log_error("Number of metadata copies for VG %s is already %" PRIu32,
 				  vg->name, mda_copies);
-		return ECMD_PROCESSED;
-	}
-
-	if (!archive(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
-
-	if (!vg_set_mda_copies(vg, mda_copies)) {
-		stack;
-		return EINVALID_CMD_LINE;
+		return 1;
 	}
 
-	if (!vg_write(vg) || !vg_commit(vg)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (!vg_set_mda_copies(vg, mda_copies))
+		return_0;
 
-	backup(vg);
-
-	log_print("Volume group \"%s\" successfully changed", vg->name);
-
-	return ECMD_PROCESSED;
+	return 1;
 }
 
 static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 			   struct volume_group *vg,
 			   void *handle __attribute__((unused)))
 {
-	int dmeventd_mode, r = ECMD_FAILED;
+	int dmeventd_mode;
+	int archived = 0;
+	int i;
+
+	static struct {
+		int arg;
+		int (*fn)(struct cmd_context *cmd, struct volume_group *vg);
+	} _vgchange_args[] = {
+		{ logicalvolume_ARG, &_vgchange_logicalvolume },
+		{ maxphysicalvolumes_ARG, &_vgchange_physicalvolumes },
+		{ resizeable_ARG, &_vgchange_resizeable },
+		{ deltag_ARG, &_vgchange_deltag },
+		{ addtag_ARG, &_vgchange_addtag },
+		{ physicalextentsize_ARG, &_vgchange_pesize },
+		{ uuid_ARG, &_vgchange_uuid },
+		{ alloc_ARG, &_vgchange_alloc },
+		{ clustered_ARG, &_vgchange_clustered },
+		{ vgmetadatacopies_ARG, &_vgchange_metadata_copies },
+		{ -1, NULL },
+	};
 
 	if (vg_is_exported(vg)) {
 		log_error("Volume group \"%s\" is exported", vg_name);
@@ -593,78 +478,78 @@
 						arg_int_value(cmd, poll_ARG,
 						DEFAULT_BACKGROUND_POLLING));
 
+	for (i = 0; _vgchange_args[i].arg >= 0; i++) {
+		if (arg_count(cmd, _vgchange_args[i].arg)) {
+			if (!archived && !archive(vg)) {
+				stack;
+				return ECMD_FAILED;
+			}
+			archived = 1;
+			if (!_vgchange_args[i].fn(cmd, vg)) {
+				stack;
+				return ECMD_FAILED;
+			}
+		}
+	}
+
+	if (archived) {
+		if (!vg_write(vg) || !vg_commit(vg)) {
+			stack;
+			return ECMD_FAILED;
+		}
+
+		backup(vg);
+
+		log_print("Volume group \"%s\" successfully changed", vg->name);
+	}
+
 	if (arg_count(cmd, available_ARG)) {
-		r = _vgchange_available(cmd, vg);
-		if (r != ECMD_PROCESSED)
-			return r;
+		if (!_vgchange_available(cmd, vg))
+			return ECMD_FAILED;
 	}
 
 	if (arg_count(cmd, refresh_ARG)) {
 		/* refreshes the visible LVs (which starts polling) */
-		r = _vgchange_refresh(cmd, vg);
-		if (r != ECMD_PROCESSED)
-			return r;
+		if (!_vgchange_refresh(cmd, vg))
+			return ECMD_FAILED;
 	}
 
 	if (!arg_count(cmd, available_ARG) &&
 	    !arg_count(cmd, refresh_ARG) &&
 	    arg_count(cmd, monitor_ARG)) {
 		/* -ay* will have already done monitoring changes */
-		r = _vgchange_monitoring(cmd, vg);
-		if (r != ECMD_PROCESSED)
-			return r;
+		if (!_vgchange_monitoring(cmd, vg))
+			return ECMD_FAILED;
 	}
 
 	if (!arg_count(cmd, refresh_ARG) &&
 	    arg_count(cmd, poll_ARG))
-		r = _vgchange_background_polling(cmd, vg);
-
-	else if (arg_count(cmd, resizeable_ARG))
-		r = _vgchange_resizeable(cmd, vg);
-
-	else if (arg_count(cmd, logicalvolume_ARG))
-		r = _vgchange_logicalvolume(cmd, vg);
-
-	else if (arg_count(cmd, maxphysicalvolumes_ARG))
-		r = _vgchange_physicalvolumes(cmd, vg);
-
-	else if (arg_count(cmd, addtag_ARG))
-		r = _vgchange_tag(cmd, vg, addtag_ARG);
-
-	else if (arg_count(cmd, deltag_ARG))
-		r = _vgchange_tag(cmd, vg, deltag_ARG);
+		if (!_vgchange_background_polling(cmd, vg))
+			return ECMD_FAILED;
 
-	else if (arg_count(cmd, physicalextentsize_ARG))
-		r = _vgchange_pesize(cmd, vg);
-
-	else if (arg_count(cmd, uuid_ARG))
-		r = _vgchange_uuid(cmd, vg);
-
-	else if (arg_count(cmd, alloc_ARG))
-		r = _vgchange_alloc(cmd, vg);
-
-	else if (arg_count(cmd, clustered_ARG))
-		r = _vgchange_clustered(cmd, vg);
-
-	else if (arg_count(cmd, vgmetadatacopies_ARG) ||
-		 arg_count(cmd, metadatacopies_ARG))
-		r = _vgchange_metadata_copies(cmd, vg);
-
-	return r;
+        return ECMD_PROCESSED;
 }
 
 int vgchange(struct cmd_context *cmd, int argc, char **argv)
 {
-	if (!
-	    (arg_count(cmd, available_ARG) + arg_count(cmd, logicalvolume_ARG) +
-	     arg_count(cmd, maxphysicalvolumes_ARG) +
-	     arg_count(cmd, resizeable_ARG) + arg_count(cmd, deltag_ARG) +
-	     arg_count(cmd, addtag_ARG) + arg_count(cmd, uuid_ARG) +
-	     arg_count(cmd, physicalextentsize_ARG) +
-	     arg_count(cmd, clustered_ARG) + arg_count(cmd, alloc_ARG) +
-	     arg_count(cmd, monitor_ARG) + arg_count(cmd, poll_ARG) +
-	     arg_count(cmd, refresh_ARG) + arg_count(cmd, metadatacopies_ARG) +
-	     arg_count(cmd, vgmetadatacopies_ARG))) {
+	/* Update commands that can be combined */
+	int update = 
+		arg_count(cmd, logicalvolume_ARG) ||
+		arg_count(cmd, maxphysicalvolumes_ARG) ||
+		arg_count(cmd, resizeable_ARG) ||
+		arg_count(cmd, deltag_ARG) ||
+		arg_count(cmd, addtag_ARG) ||
+		arg_count(cmd, uuid_ARG) ||
+		arg_count(cmd, physicalextentsize_ARG) ||
+		arg_count(cmd, clustered_ARG) ||
+		arg_count(cmd, alloc_ARG) ||
+		arg_count(cmd, vgmetadatacopies_ARG);
+
+	if (!update &&
+	    !arg_count(cmd, available_ARG) &&
+	    !arg_count(cmd, monitor_ARG) &&
+	    !arg_count(cmd, poll_ARG) &&
+	    !arg_count(cmd, refresh_ARG)) {
 		log_error("Need 1 or more of -a, -c, -l, -p, -s, -x, "
 			  "--refresh, --uuid, --alloc, --addtag, --deltag, "
 			  "--monitor, --poll, --vgmetadatacopies or "
@@ -672,25 +557,13 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	/* FIXME Cope with several changes at once! */
-	if (arg_count(cmd, available_ARG) + arg_count(cmd, logicalvolume_ARG) +
-	    arg_count(cmd, maxphysicalvolumes_ARG) +
-	    arg_count(cmd, resizeable_ARG) + arg_count(cmd, deltag_ARG) +
-	    arg_count(cmd, addtag_ARG) + arg_count(cmd, alloc_ARG) +
-	    arg_count(cmd, uuid_ARG) + arg_count(cmd, clustered_ARG) +
-	    arg_count(cmd, physicalextentsize_ARG) > 1) {
-		log_error("Only one of -a, -c, -l, -p, -s, -x, --uuid, "
-			  "--alloc, --addtag or --deltag allowed");
-		return EINVALID_CMD_LINE;
-	}
-
 	if (arg_count(cmd, available_ARG) && arg_count(cmd, refresh_ARG)) {
 		log_error("Only one of -a and --refresh permitted.");
 		return EINVALID_CMD_LINE;
 	}
 
 	if ((arg_count(cmd, ignorelockingfailure_ARG) ||
-	     arg_count(cmd, sysinit_ARG)) && !arg_count(cmd, available_ARG)) {
+	     arg_count(cmd, sysinit_ARG)) && update) {
 		log_error("Only -a permitted with --ignorelockingfailure and --sysinit");
 		return EINVALID_CMD_LINE;
 	}
@@ -715,12 +588,18 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_vg(cmd, argc, argv,
-			       (arg_count(cmd, available_ARG) ||
-				arg_count(cmd, refresh_ARG) ||
-				arg_count(cmd, monitor_ARG) ||
-				arg_count(cmd, poll_ARG)) ?
-			       0 : READ_FOR_UPDATE,
-			       NULL,
-			       &vgchange_single);
+	if (arg_count(cmd, maxphysicalvolumes_ARG) &&
+	    arg_sign_value(cmd, maxphysicalvolumes_ARG, 0) == SIGN_MINUS) {
+		log_error("MaxPhysicalVolumes may not be negative");
+		return EINVALID_CMD_LINE;
+	}
+
+	if (arg_count(cmd, physicalextentsize_ARG) &&
+	    arg_sign_value(cmd, physicalextentsize_ARG, 0) == SIGN_MINUS) {
+		log_error("Physical extent size may not be negative");
+		return EINVALID_CMD_LINE;
+	}
+
+	return process_each_vg(cmd, argc, argv, update ? READ_FOR_UPDATE : 0,
+			       NULL, &vgchange_single);
 }


