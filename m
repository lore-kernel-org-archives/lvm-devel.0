From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Nov 2007 20:51:57 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20071112205157.21083.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-11-12 20:51:54

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c activate.h dev_manager.c 
	                 dev_manager.h 
	lib/display    : display.c 
	lib/metadata   : lv_manip.c 
	lib/report     : report.c 
	tools          : lvchange.c lvcreate.c lvresize.c lvscan.c 
	                 toollib.c vgchange.c vgconvert.c vgreduce.c 

Log message:
	readahead activation code (but no dm support yet)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.732&r2=1.733
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.127&r2=1.128
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.127&r2=1.128
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.h.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.133&r2=1.134
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.156&r2=1.157
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvscan.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.112&r2=1.113
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69

--- LVM2/WHATS_NEW	2007/11/12 13:34:14	1.732
+++ LVM2/WHATS_NEW	2007/11/12 20:51:53	1.733
@@ -1,9 +1,10 @@
 Version 2.02.29 -
 ==================================
   Attempt to remove incomplete LVs with lvcreate zeroing/activation problems.
+  Add read_ahead activation code.
   Add activation/readahead configuration option and FMT_RESTRICTED_READAHEAD.
   Extend readahead arg to accept "auto" and "none".
-  Add lv_read_ahead and lv_kernel_read_ahead fields to reports.
+  Add lv_read_ahead and lv_kernel_read_ahead fields to reports and lvdisplay.
   Prevent lvconvert -s from using same LV as origin and snapshot.
   Fix human-readable output of odd numbers of sectors.
   Add pv_mda_free and vg_mda_free fields to reports for raw text format.
--- LVM2/lib/activate/activate.c	2007/08/20 20:55:24	1.127
+++ LVM2/lib/activate/activate.c	2007/11/12 20:51:53	1.128
@@ -146,12 +146,12 @@
 	return 0;
 }
 int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, struct lvinfo *info,
-	    int with_open_count)
+	    int with_open_count, int with_read_ahead)
 {
 	return 0;
 }
 int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s,
-		    struct lvinfo *info, int with_open_count)
+		    struct lvinfo *info, int with_open_count, int with_read_ahead)
 {
 	return 0;
 }
@@ -425,7 +425,7 @@
  * Returns 1 if info structure populated, else 0 on failure.
  */
 static int _lv_info(struct cmd_context *cmd, const struct logical_volume *lv, int with_mknodes,
-		    struct lvinfo *info, int with_open_count, unsigned by_uuid_only)
+		    struct lvinfo *info, int with_open_count, int with_read_ahead, unsigned by_uuid_only)
 {
 	struct dm_info dminfo;
 	char *name = NULL;
@@ -439,7 +439,8 @@
 
 	log_debug("Getting device info for %s", name);
 	if (!dev_manager_info(lv->vg->cmd->mem, name, lv, with_mknodes,
-			      with_open_count, &dminfo)) {
+			      with_open_count, with_read_ahead, &dminfo,
+			      &info->read_ahead)) {
 		if (name)
 			dm_pool_free(cmd->mem, name);
 		return_0;
@@ -461,20 +462,20 @@
 }
 
 int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, struct lvinfo *info,
-	    int with_open_count)
+	    int with_open_count, int with_read_ahead)
 {
-	return _lv_info(cmd, lv, 0, info, with_open_count, 0);
+	return _lv_info(cmd, lv, 0, info, with_open_count, with_read_ahead, 0);
 }
 
 int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s,
-		    struct lvinfo *info, int with_open_count)
+		    struct lvinfo *info, int with_open_count, int with_read_ahead)
 {
 	struct logical_volume *lv;
 
 	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
 		return 0;
 
-	return _lv_info(cmd, lv, 0, info, with_open_count, 0);
+	return _lv_info(cmd, lv, 0, info, with_open_count, with_read_ahead, 0);
 }
 
 /*
@@ -510,7 +511,7 @@
 	if (!activation())
 		return 0;
 
-	if (!lv_info(cmd, lv, &info, 0))
+	if (!lv_info(cmd, lv, &info, 0, 0))
 		return_0;
 
 	if (!info.exists)
@@ -532,7 +533,7 @@
 {
 	struct lvinfo info;
 
-	if (!_lv_info(cmd, lv, 0, &info, 0, by_uuid_only)) {
+	if (!_lv_info(cmd, lv, 0, &info, 0, 0, by_uuid_only)) {
 		stack;
 		return -1;
 	}
@@ -544,7 +545,7 @@
 {
 	struct lvinfo info;
 
-	if (!lv_info(cmd, lv, &info, 1)) {
+	if (!lv_info(cmd, lv, &info, 1, 0)) {
 		stack;
 		return -1;
 	}
@@ -772,7 +773,7 @@
 		return 1;
 	}
 
-	if (!lv_info(cmd, lv, &info, 0))
+	if (!lv_info(cmd, lv, &info, 0, 0))
 		return_0;
 
 	if (!info.exists || info.suspended)
@@ -832,7 +833,7 @@
 		return 1;
 	}
 
-	if (!lv_info(cmd, lv, &info, 0))
+	if (!lv_info(cmd, lv, &info, 0, 0))
 		return_0;
 
 	if (!info.exists || !info.suspended)
@@ -878,7 +879,7 @@
 		return 1;
 	}
 
-	if (!lv_info(cmd, lv, &info, 1))
+	if (!lv_info(cmd, lv, &info, 1, 0))
 		return_0;
 
 	if (!info.exists)
@@ -949,7 +950,7 @@
 		return 1;
 	}
 
-	if (!lv_info(cmd, lv, &info, 0))
+	if (!lv_info(cmd, lv, &info, 0, 0))
 		return_0;
 
 	if (info.exists && !info.suspended && info.live_table)
@@ -992,7 +993,7 @@
 		return r;
 	}
 
-	if (!_lv_info(cmd, lv, 1, &info, 0, 0))
+	if (!_lv_info(cmd, lv, 1, &info, 0, 0, 0))
 		return_0;
 
 	if (info.exists)
--- LVM2/lib/activate/activate.h	2007/08/20 20:55:24	1.58
+++ LVM2/lib/activate/activate.h	2007/11/12 20:51:53	1.59
@@ -27,6 +27,7 @@
 	int read_only;
 	int live_table;
 	int inactive_table;
+	uint32_t read_ahead;
 };
 
 void set_activation(int activation);
@@ -62,9 +63,9 @@
  * Returns 1 if info structure has been populated, else 0.
  */
 int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, struct lvinfo *info,
-	    int with_open_count);
+	    int with_open_count, int with_read_ahead);
 int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s,
-		    struct lvinfo *info, int with_open_count);
+		    struct lvinfo *info, int with_open_count, int with_read_ahead);
 
 /*
  * Returns 1 if activate_lv has been set: 1 = activate; 0 = don't.
--- LVM2/lib/activate/dev_manager.c	2007/08/20 20:55:24	1.127
+++ LVM2/lib/activate/dev_manager.c	2007/11/12 20:51:53	1.128
@@ -118,7 +118,8 @@
 }
 
 static int _info_run(const char *name, const char *dlid, struct dm_info *info,
-		     int mknodes, int with_open_count)
+		     uint32_t *read_ahead, int mknodes, int with_open_count,
+		     int with_read_ahead)
 {
 	int r = 0;
 	struct dm_task *dmt;
@@ -141,6 +142,12 @@
 	if (!dm_task_get_info(dmt, info))
 		goto_out;
 
+	if (!with_read_ahead) {
+		if (read_ahead)
+			*read_ahead = DM_READ_AHEAD_NONE;
+	} else
+		; // FIXME *read_ahead = dm_task_get_read_ahead(dmt);
+
 	r = 1;
 
       out:
@@ -201,27 +208,32 @@
 }
 
 static int _info(const char *name, const char *dlid, int mknodes,
-		 int with_open_count, struct dm_info *info)
+		 int with_open_count, int with_read_ahead,
+		 struct dm_info *info, uint32_t *read_ahead)
 {
 	if (!mknodes && dlid && *dlid) {
-		if (_info_run(NULL, dlid, info, 0, with_open_count) &&
+		if (_info_run(NULL, dlid, info, read_ahead, 0, with_open_count,
+			      with_read_ahead) &&
 	    	    info->exists)
 			return 1;
 		else if (_info_run(NULL, dlid + sizeof(UUID_PREFIX) - 1, info,
-				   0, with_open_count) &&
+				   read_ahead, 0, with_open_count,
+				   with_read_ahead) &&
 			 info->exists)
 			return 1;
 	}
 
 	if (name)
-		return _info_run(name, NULL, info, mknodes, with_open_count);
+		return _info_run(name, NULL, info, read_ahead, mknodes,
+				 with_open_count, with_read_ahead);
 
 	return 0;
 }
 
 int dev_manager_info(struct dm_pool *mem, const char *name,
 		     const struct logical_volume *lv, int with_mknodes,
-		     int with_open_count, struct dm_info *info)
+		     int with_open_count, int with_read_ahead,
+		     struct dm_info *info, uint32_t *read_ahead)
 {
 	const char *dlid;
 
@@ -230,7 +242,8 @@
 		return 0;
 	}
 
-	return _info(name, dlid, with_mknodes, with_open_count, info);
+	return _info(name, dlid, with_mknodes, with_open_count, with_read_ahead,
+		     info, read_ahead);
 }
 
 /* FIXME Interface must cope with multiple targets */
@@ -631,7 +644,7 @@
 		return_0;
 
         log_debug("Getting device info for %s [%s]", name, dlid);
-        if (!_info(name, dlid, 0, 1, &info)) {
+        if (!_info(name, dlid, 0, 1, 0, &info, NULL)) {
                 log_error("Failed to get info for %s [%s].", name, dlid);
                 return 0;
         }
@@ -886,6 +899,9 @@
 	struct lv_layer *lvlayer;
 	struct dm_tree_node *dnode;
 	char *name, *dlid;
+	uint32_t max_stripe_size = UINT32_C(0);
+	uint32_t read_ahead = lv->read_ahead;
+	uint32_t flags = UINT32_C(0);
 
 	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
@@ -932,8 +948,17 @@
 			break;
 		if (lv_is_cow(lv) && !layer)
 			break;
+		if (max_stripe_size < seg->stripe_size)
+			max_stripe_size = seg->stripe_size;
 	}
 
+	if (read_ahead == DM_READ_AHEAD_AUTO)
+		read_ahead = max_stripe_size;
+	else
+		flags = DM_READ_AHEAD_MINIMUM_FLAG;
+
+	// FIXME dm_tree_node_set_read_ahead(dnode, read_ahead, flags);
+
 	return 1;
 }
 
--- LVM2/lib/activate/dev_manager.h	2007/08/20 20:55:24	1.27
+++ LVM2/lib/activate/dev_manager.h	2007/11/12 20:51:53	1.28
@@ -40,7 +40,8 @@
  */
 int dev_manager_info(struct dm_pool *mem, const char *name,
 		     const struct logical_volume *lv,
-		     int mknodes, int with_open_count, struct dm_info *info);
+		     int mknodes, int with_open_count, int with_read_ahead,
+		     struct dm_info *info, uint32_t *read_ahead);
 int dev_manager_snapshot_percent(struct dev_manager *dm,
 				 const struct logical_volume *lv,
 				 float *percent);
--- LVM2/lib/display/display.c	2007/11/05 17:13:54	1.82
+++ LVM2/lib/display/display.c	2007/11/12 20:51:53	1.83
@@ -381,7 +381,7 @@
 {
 	int inkernel;
 	struct lvinfo info;
-	inkernel = lv_info(lv->vg->cmd, lv, &info, 1) && info.exists;
+	inkernel = lv_info(lv->vg->cmd, lv, &info, 1, 0) && info.exists;
 
 	log_print("%s%s/%s:%s:%d:%d:-1:%d:%" PRIu64 ":%d:-1:%d:%d:%d:%d",
 		  lv->vg->cmd->dev_dir,
@@ -412,7 +412,7 @@
 		return 0;
 	}
 
-	inkernel = lv_info(cmd, lv, &info, 1) && info.exists;
+	inkernel = lv_info(cmd, lv, &info, 1, 1) && info.exists;
 
 	log_print("--- Logical volume ---");
 
@@ -493,7 +493,15 @@
 ***********/
 
 	log_print("Allocation             %s", get_alloc_string(lv->alloc));
-	log_print("Read ahead sectors     %u", lv->read_ahead);
+	if (lv->read_ahead == DM_READ_AHEAD_AUTO)
+		log_print("Read ahead sectors     auto");
+	else if (lv->read_ahead == DM_READ_AHEAD_NONE)
+		log_print("Read ahead sectors     0");
+	else
+		log_print("Read ahead sectors     %u", lv->read_ahead);
+
+	if (inkernel && lv->read_ahead != info.read_ahead)
+		log_print("- currently set to     %u", info.read_ahead);
 
 	if (lv->status & FIXED_MINOR) {
 		if (lv->major >= 0)
--- LVM2/lib/metadata/lv_manip.c	2007/11/09 16:51:54	1.133
+++ LVM2/lib/metadata/lv_manip.c	2007/11/12 20:51:53	1.134
@@ -1839,7 +1839,7 @@
 
 	/* FIXME Ensure not referred to by another existing LVs */
 
-	if (lv_info(cmd, lv, &info, 1)) {
+	if (lv_info(cmd, lv, &info, 1, 0)) {
 		if (info.open_count) {
 			log_error("Can't remove open logical volume \"%s\"",
 				  lv->name);
--- LVM2/lib/report/report.c	2007/11/09 16:51:54	1.65
+++ LVM2/lib/report/report.c	2007/11/12 20:51:54	1.66
@@ -227,7 +227,7 @@
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lvinfo info;
 
-	if (lv_info(lv->vg->cmd, lv, &info, 0) && info.exists)
+	if (lv_info(lv->vg->cmd, lv, &info, 0, 0) && info.exists)
 		return dm_report_field_int(rh, field, &info.major);
 
 	return dm_report_field_uint64(rh, field, &_minusone);
@@ -240,7 +240,7 @@
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lvinfo info;
 
-	if (lv_info(lv->vg->cmd, lv, &info, 0) && info.exists)
+	if (lv_info(lv->vg->cmd, lv, &info, 0, 0) && info.exists)
 		return dm_report_field_int(rh, field, &info.minor);
 
 	return dm_report_field_uint64(rh, field, &_minusone);
@@ -297,7 +297,7 @@
 	else
 		repstr[3] = '-';
 
-	if (lv_info(lv->vg->cmd, lv, &info, 1) && info.exists) {
+	if (lv_info(lv->vg->cmd, lv, &info, 1, 0) && info.exists) {
 		if (info.suspended)
 			repstr[4] = 's';	/* Suspended */
 		else if (info.live_table)
@@ -583,7 +583,12 @@
 			      const void *data,
 			      void *private __attribute((unused)))
 {
-	// FIXME after dm support is added
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	struct lvinfo info;
+
+	if (lv_info(lv->vg->cmd, lv, &info, 0, 1) && info.exists)
+		return dm_report_field_int(rh, field, &info.read_ahead);
+
 	return dm_report_field_uint64(rh, field, &_minusone);
 }
 
@@ -852,7 +857,7 @@
 	}
 
 	if (!lv_is_cow(lv) ||
-	    (lv_info(lv->vg->cmd, lv, &info, 0) && !info.exists)) {
+	    (lv_info(lv->vg->cmd, lv, &info, 0, 0) && !info.exists)) {
 		*sortval = UINT64_C(0);
 		dm_report_field_set_value(field, "", sortval);
 		return 1;
--- LVM2/tools/lvchange.c	2007/11/09 16:51:54	1.82
+++ LVM2/tools/lvchange.c	2007/11/12 20:51:54	1.83
@@ -36,7 +36,7 @@
 	}
 
 	if ((lv->status & MIRRORED) && (lv->vg->status & CLUSTERED) &&
-	    lv_info(cmd, lv, &info, 0) && info.exists) {
+	    lv_info(cmd, lv, &info, 0, 0) && info.exists) {
 		log_error("Cannot change permissions of mirror \"%s\" "
 			  "while active.", lv->name);
 		return 0;
@@ -85,7 +85,7 @@
 {
 	struct lvinfo info;
 
-	if (!lv_info(cmd, lv, &info, 0) || !info.exists) {
+	if (!lv_info(cmd, lv, &info, 0, 0) || !info.exists) {
 		log_error("Logical volume, %s, is not active", lv->name);
 		return 0;
 	}
@@ -195,7 +195,7 @@
 		return 0;
 	}
 
-	if (lv_info(cmd, lv, &info, 1)) {
+	if (lv_info(cmd, lv, &info, 1, 0)) {
 		if (info.open_count) {
 			log_error("Can't resync open logical volume \"%s\"",
 				  lv->name);
@@ -447,7 +447,7 @@
 			log_error("Major number must be specified with -My");
 			return 0;
 		}
-		if (lv_info(cmd, lv, &info, 0) && info.exists)
+		if (lv_info(cmd, lv, &info, 0, 0) && info.exists)
 			active = 1;
 		if (active && !arg_count(cmd, force_ARG) &&
 		    yes_no_prompt("Logical volume %s will be "
--- LVM2/tools/lvcreate.c	2007/11/12 20:02:55	1.156
+++ LVM2/tools/lvcreate.c	2007/11/12 20:51:54	1.157
@@ -680,7 +680,7 @@
 		/* Must zero cow */
 		status |= LVM_WRITE;
 
-		if (!lv_info(cmd, org, &info, 0)) {
+		if (!lv_info(cmd, org, &info, 0, 0)) {
 			log_error("Check for existence of snapshot origin "
 				  "'%s' failed.", org->name);
 			return 0;
@@ -918,7 +918,7 @@
 
 revert_new_lv:
 	/* FIXME Better to revert to backup of metadata? */
-	if (!lv_remove(lv) || !vg_write(vg) || backup(vg) || !vg_commit(vg))
+	if (!lv_remove(lv) || !vg_write(vg) || backup(vg), !vg_commit(vg))
 		log_error("Manual intervention may be required to remove "
 			  "abandoned LV(s) before retrying.");
 	return 0;
--- LVM2/tools/lvresize.c	2007/11/12 20:02:55	1.86
+++ LVM2/tools/lvresize.c	2007/11/12 20:51:54	1.87
@@ -95,7 +95,7 @@
 
 	memset(&info, 0, sizeof(info));
 
-	if (!lv_info(cmd, lv, &info, 1) && driver_version(NULL, 0)) {
+	if (!lv_info(cmd, lv, &info, 1, 0) && driver_version(NULL, 0)) {
 		log_error("lv_info failed: aborting");
 		return 0;
 	}
@@ -545,7 +545,7 @@
 	}
 
 	if (lp->mirrors && activation() &&
-	    lv_info(cmd, lv, &info, 0) && info.exists) {
+	    lv_info(cmd, lv, &info, 0, 0) && info.exists) {
 		log_error("Mirrors cannot be resized while active yet.");
 		return ECMD_FAILED;
 	}
@@ -559,7 +559,7 @@
 
 		memset(&info, 0, sizeof(info));
 
-		if (lv_info(cmd, lv, &info, 0) && info.exists) {
+		if (lv_info(cmd, lv, &info, 0, 0) && info.exists) {
 			log_error("Snapshot origin volumes can be resized "
 				  "only while inactive: try lvchange -an");
 			return ECMD_FAILED;
--- LVM2/tools/lvscan.c	2007/08/20 20:55:30	1.33
+++ LVM2/tools/lvscan.c	2007/11/12 20:51:54	1.34
@@ -30,7 +30,7 @@
 	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
 
-	inkernel = lv_info(cmd, lv, &info, 1) && info.exists;
+	inkernel = lv_info(cmd, lv, &info, 1, 0) && info.exists;
 	if (lv_is_origin(lv)) {
 		list_iterate_items_gen(snap_seg, &lv->snapshot_segs,
 				       origin_list) {
--- LVM2/tools/toollib.c	2007/11/12 20:02:55	1.112
+++ LVM2/tools/toollib.c	2007/11/12 20:51:54	1.113
@@ -1415,7 +1415,7 @@
 	}
 
 revert_new_lv:
-	if (!lv_remove(log_lv) || !vg_write(vg) || backup(vg) || !vg_commit(vg))
+	if (!lv_remove(log_lv) || !vg_write(vg) || backup(vg), !vg_commit(vg))
 		log_error("Manual intervention may be required to remove "
 			  "abandoned log LV before retrying.");
 	return NULL;
--- LVM2/tools/vgchange.c	2007/08/20 20:55:30	1.60
+++ LVM2/tools/vgchange.c	2007/11/12 20:51:54	1.61
@@ -27,7 +27,7 @@
 	list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
 
-		if (!lv_info(cmd, lv, &info, 0))
+		if (!lv_info(cmd, lv, &info, 0, 0))
 			lv_active = 0;
 		else
 			lv_active = info.exists;
--- LVM2/tools/vgconvert.c	2007/10/12 14:29:32	1.25
+++ LVM2/tools/vgconvert.c	2007/11/12 20:51:54	1.26
@@ -89,7 +89,7 @@
 				continue;
 			if (lvnum_from_lvid(&lv->lvid) < MAX_RESTRICTED_LVS)
 				continue;
-			if (lv_info(cmd, lv, &info, 0) && info.exists) {
+			if (lv_info(cmd, lv, &info, 0, 0) && info.exists) {
 				log_error("Logical volume %s must be "
 					  "deactivated before conversion.",
 					   lv->name);
--- LVM2/tools/vgreduce.c	2007/10/12 14:29:32	1.68
+++ LVM2/tools/vgreduce.c	2007/11/12 20:51:54	1.69
@@ -116,7 +116,7 @@
 	 * the mirrored LV also should be cleaned up.
 	 * Clean-up is currently done by caller (_make_vg_consistent()).
 	 */
-	if ((lv_info(cmd, lv, &info, 0) && info.exists)
+	if ((lv_info(cmd, lv, &info, 0, 0) && info.exists)
 	    || first_seg(lv)->mirror_seg) {
 		extents = lv->le_count;
 		mirror_seg = first_seg(lv)->mirror_seg;


