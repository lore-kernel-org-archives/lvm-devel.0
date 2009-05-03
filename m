From: Petr Rockai <prockai@redhat.com>
Date: Sun,  3 May 2009 13:38:54 +0200
Subject: [PATCH 2/9] Rework the toollib interface (process_each_*) on top of new vg_read.
In-Reply-To: <1241350741-31349-2-git-send-email-prockai@redhat.com>
References: <1241350741-31349-1-git-send-email-prockai@redhat.com>
	<1241350741-31349-2-git-send-email-prockai@redhat.com>
Message-ID: <1241350741-31349-3-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Sun May  3 12:32:30 CEST 2009  Petr Rockai <me@mornfall.net>
  * Rework the toollib interface (process_each_*) on top of new vg_read.
diff -rN -u -p old-temp.31080/lib/metadata/metadata.c new-temp.31080/lib/metadata/metadata.c
--- old-temp.31080/lib/metadata/metadata.c	2009-05-03 13:29:27.774236967 +0200
+++ new-temp.31080/lib/metadata/metadata.c	2009-05-03 13:29:27.826236802 +0200
@@ -357,7 +357,7 @@ static int remove_lvs_in_vg(struct cmd_c
 
 /* FIXME: remove redundant vg_name */
 int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
-		     struct volume_group *vg, int consistent,
+		     struct volume_group *vg,
 		     force_t force __attribute((unused)))
 {
 	struct physical_volume *pv;
@@ -365,7 +365,7 @@ int vg_remove_single(struct cmd_context 
 	unsigned lv_count;
 	int ret = 1;
 
-	if (!vg || !consistent || vg_missing_pv_count(vg)) {
+	if (vg_read_error(vg) || vg_missing_pv_count(vg)) {
 		log_error("Volume group \"%s\" not found, is inconsistent "
 			  "or has PVs missing.", vg_name);
 		log_error("Consider vgreduce --removemissing if metadata "
diff -rN -u -p old-temp.31080/lib/metadata/metadata-exported.h new-temp.31080/lib/metadata/metadata-exported.h
--- old-temp.31080/lib/metadata/metadata-exported.h	2009-05-03 13:29:27.774236967 +0200
+++ new-temp.31080/lib/metadata/metadata-exported.h	2009-05-03 13:29:27.826236802 +0200
@@ -429,7 +429,7 @@ struct volume_group *vg_create(struct cm
 			       int pv_count, char **pv_names);
 int vg_remove(struct volume_group *vg);
 int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
-		     struct volume_group *vg, int consistent,
+		     struct volume_group *vg,
 		     force_t force);
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
diff -rN -u -p old-temp.31080/tools/lvchange.c new-temp.31080/tools/lvchange.c
--- old-temp.31080/tools/lvchange.c	2009-05-03 13:29:27.774236967 +0200
+++ new-temp.31080/tools/lvchange.c	2009-05-03 13:29:27.866236369 +0200
@@ -725,6 +725,6 @@ int lvchange(struct cmd_context *cmd, in
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_lv(cmd, argc, argv, LCK_VG_WRITE, NULL,
+	return process_each_lv(cmd, argc, argv, READ_FOR_UPDATE, NULL,
 			       &lvchange_single);
 }
diff -rN -u -p old-temp.31080/tools/lvdisplay.c new-temp.31080/tools/lvdisplay.c
--- old-temp.31080/tools/lvdisplay.c	2009-05-03 13:29:27.774236967 +0200
+++ new-temp.31080/tools/lvdisplay.c	2009-05-03 13:29:27.866236369 +0200
@@ -54,6 +54,6 @@ int lvdisplay(struct cmd_context *cmd, i
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_lv(cmd, argc, argv, LCK_VG_READ, NULL,
+	return process_each_lv(cmd, argc, argv, 0, NULL,
 			       &_lvdisplay_single);
 }
diff -rN -u -p old-temp.31080/tools/lvremove.c new-temp.31080/tools/lvremove.c
--- old-temp.31080/tools/lvremove.c	2009-05-03 13:29:27.774236967 +0200
+++ new-temp.31080/tools/lvremove.c	2009-05-03 13:29:27.870237506 +0200
@@ -41,6 +41,6 @@ int lvremove(struct cmd_context *cmd, in
 
 	cmd->handles_missing_pvs = 1;
 
-	return process_each_lv(cmd, argc, argv, LCK_VG_WRITE, NULL,
+	return process_each_lv(cmd, argc, argv, READ_FOR_UPDATE, NULL,
 			       &lvremove_single);
 }
diff -rN -u -p old-temp.31080/tools/lvscan.c new-temp.31080/tools/lvscan.c
--- old-temp.31080/tools/lvscan.c	2009-05-03 13:29:27.774236967 +0200
+++ new-temp.31080/tools/lvscan.c	2009-05-03 13:29:27.870237506 +0200
@@ -80,6 +80,6 @@ int lvscan(struct cmd_context *cmd, int 
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_lv(cmd, argc, argv, LCK_VG_READ, NULL,
+	return process_each_lv(cmd, argc, argv, 0, NULL,
 			       &lvscan_single);
 }
diff -rN -u -p old-temp.31080/tools/polldaemon.c new-temp.31080/tools/polldaemon.c
--- old-temp.31080/tools/polldaemon.c	2009-05-03 13:29:27.774236967 +0200
+++ new-temp.31080/tools/polldaemon.c	2009-05-03 13:29:27.870237506 +0200
@@ -175,7 +175,7 @@ static int _wait_for_single_mirror(struc
 }
 
 static int _poll_vg(struct cmd_context *cmd, const char *vgname,
-		    struct volume_group *vg, int consistent, void *handle)
+		    struct volume_group *vg, void *handle)
 {
 	struct daemon_parms *parms = (struct daemon_parms *) handle;
 	struct lv_list *lvl;
@@ -183,18 +183,7 @@ static int _poll_vg(struct cmd_context *
 	const char *name;
 	int finished;
 
-	if (!vg) {
-		log_error("Couldn't read volume group %s", vgname);
-		return ECMD_FAILED;
-	}
-
-	if (!consistent) {
-		log_error("Volume Group %s inconsistent - skipping", vgname);
-		/* FIXME Should we silently recover it here or not? */
-		return ECMD_FAILED;
-	}
-
-	if (!vg_check_status(vg, EXPORTED_VG))
+	if (vg_read_error(vg))
 		return ECMD_FAILED;
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
@@ -219,7 +208,7 @@ static void _poll_for_all_vgs(struct cmd
 {
 	while (1) {
 		parms->outstanding_count = 0;
-		process_each_vg(cmd, 0, NULL, LCK_VG_WRITE, 1, parms, _poll_vg);
+		process_each_vg(cmd, 0, NULL, READ_FOR_UPDATE, parms, _poll_vg);
 		if (!parms->outstanding_count)
 			break;
 		sleep(parms->interval);
diff -rN -u -p old-temp.31080/tools/reporter.c new-temp.31080/tools/reporter.c
--- old-temp.31080/tools/reporter.c	2009-05-03 13:29:27.770236808 +0200
+++ new-temp.31080/tools/reporter.c	2009-05-03 13:29:27.870237506 +0200
@@ -18,12 +18,10 @@
 
 static int _vgs_single(struct cmd_context *cmd __attribute((unused)),
 		       const char *vg_name, struct volume_group *vg,
-		       int consistent __attribute((unused)), void *handle)
+		       void *handle)
 {
-	if (!vg) {
-		log_error("Volume group %s not found", vg_name);
+	if (vg_read_error(vg))
 		return ECMD_FAILED;
-	}
 
 	if (!report_object(handle, vg, NULL, NULL, NULL, NULL))
 		return ECMD_FAILED;
@@ -181,26 +179,20 @@ static int _label_single(struct cmd_cont
 
 static int _pvs_in_vg(struct cmd_context *cmd, const char *vg_name,
 		      struct volume_group *vg,
-		      int consistent __attribute((unused)),
 		      void *handle)
 {
-	if (!vg) {
-		log_error("Volume group %s not found", vg_name);
+	if (vg_read_error(vg))
 		return ECMD_FAILED;
-	}
 
 	return process_each_pv_in_vg(cmd, vg, NULL, handle, &_pvs_single);
 }
 
 static int _pvsegs_in_vg(struct cmd_context *cmd, const char *vg_name,
 			 struct volume_group *vg,
-			 int consistent __attribute((unused)),
 			 void *handle)
 {
-	if (!vg) {
-		log_error("Volume group %s not found", vg_name);
+	if (vg_read_error(vg))
 		return ECMD_FAILED;
-	}
 
 	return process_each_pv_in_vg(cmd, vg, NULL, handle, &_pvsegs_single);
 }
@@ -378,12 +370,12 @@ static int _report(struct cmd_context *c
 
 	switch (report_type) {
 	case LVS:
-		r = process_each_lv(cmd, argc, argv, LCK_VG_READ, report_handle,
+		r = process_each_lv(cmd, argc, argv, 0, report_handle,
 				    &_lvs_single);
 		break;
 	case VGS:
-		r = process_each_vg(cmd, argc, argv, LCK_VG_READ, 0,
-				    report_handle, &_vgs_single);
+		r = process_each_vg(cmd, argc, argv, 0, report_handle,
+				    &_vgs_single);
 		break;
 	case LABEL:
 		r = process_each_pv(cmd, argc, argv, NULL, LCK_NONE,
@@ -394,11 +386,11 @@ static int _report(struct cmd_context *c
 			r = process_each_pv(cmd, argc, argv, NULL, LCK_VG_READ,
 					    0, report_handle, &_pvs_single);
 		else
-			r = process_each_vg(cmd, argc, argv, LCK_VG_READ, 0,
+			r = process_each_vg(cmd, argc, argv, 0,
 					    report_handle, &_pvs_in_vg);
 		break;
 	case SEGS:
-		r = process_each_lv(cmd, argc, argv, LCK_VG_READ, report_handle,
+		r = process_each_lv(cmd, argc, argv, 0, report_handle,
 				    &_lvsegs_single);
 		break;
 	case PVSEGS:
@@ -406,7 +398,7 @@ static int _report(struct cmd_context *c
 			r = process_each_pv(cmd, argc, argv, NULL, LCK_VG_READ,
 					    0, report_handle, &_pvsegs_single);
 		else
-			r = process_each_vg(cmd, argc, argv, LCK_VG_READ, 0,
+			r = process_each_vg(cmd, argc, argv, 0,
 					    report_handle, &_pvsegs_in_vg);
 		break;
 	}
diff -rN -u -p old-temp.31080/tools/toollib.c new-temp.31080/tools/toollib.c
--- old-temp.31080/tools/toollib.c	2009-05-03 13:29:27.770236808 +0200
+++ new-temp.31080/tools/toollib.c	2009-05-03 13:29:27.870237506 +0200
@@ -161,7 +161,7 @@ int process_each_lv_in_vg(struct cmd_con
 }
 
 int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
-		    uint32_t lock_type, void *handle,
+		    uint32_t flags, void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   struct logical_volume * lv,
 					   void *handle))
@@ -169,7 +169,6 @@ int process_each_lv(struct cmd_context *
 	int opt = 0;
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
-	int consistent;
 
 	struct dm_list *tags_arg;
 	struct dm_list *vgnames;	/* VGs to process */
@@ -284,42 +283,10 @@ int process_each_lv(struct cmd_context *
 		vgname = strl->str;
 		if (is_orphan_vg(vgname))
 			continue;	/* FIXME Unnecessary? */
-		if (!lock_vol(cmd, vgname, lock_type)) {
-			log_error("Can't lock %s: skipping", vgname);
-			ret_max = ECMD_FAILED;
-			continue;
-		}
-		if (lock_type & LCK_WRITE)
-			consistent = 1;
-		else
-			consistent = 0;
-		if (!(vg = vg_read_internal(cmd, vgname, NULL, &consistent)) || !consistent) {
-			unlock_vg(cmd, vgname);
-			if (!vg)
-				log_error("Volume group \"%s\" "
-					  "not found", vgname);
-			else {
-				if (!vg_check_status(vg, CLUSTERED)) {
-					if (ret_max < ECMD_FAILED)
-						ret_max = ECMD_FAILED;
-					vg_release(vg);
-					continue;
-				}
-				log_error("Volume group \"%s\" "
-					  "inconsistent", vgname);
-			}
+		vg = vg_read(cmd, vgname, NULL, flags);
 
+		if (vg_read_error(vg)) {
 			vg_release(vg);
-			if (!vg || !(vg = recover_vg(cmd, vgname, lock_type))) {
-				if (ret_max < ECMD_FAILED)
-					ret_max = ECMD_FAILED;
-				vg_release(vg);
-				continue;
-			}
-		}
-
-		if (!vg_check_status(vg, CLUSTERED)) {
-			unlock_release_vg(cmd, vg, vgname);
 			if (ret_max < ECMD_FAILED)
 				ret_max = ECMD_FAILED;
 			continue;
@@ -380,8 +347,8 @@ int process_each_segment_in_pv(struct cm
 	if (is_pv(pv) && !vg && !is_orphan(pv)) {
 		vg_name = pv_vg_name(pv);
 
-		if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_READ,
-					    CLUSTERED, 0))) {
+		vg = vg_read(cmd, vg_name, NULL, 0);
+		if (vg_read_error(vg)) {
 			log_error("Skipping volume group %s", vg_name);
 			return ECMD_FAILED;
 		}
@@ -446,32 +413,19 @@ int process_each_segment_in_lv(struct cm
 static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
 			   const char *vgid,
 			   struct dm_list *tags, struct dm_list *arg_vgnames,
-			   uint32_t lock_type, int consistent, void *handle,
+			   uint32_t flags, void *handle,
 			   int ret_max,
 			   int (*process_single) (struct cmd_context * cmd,
 						  const char *vg_name,
 						  struct volume_group * vg,
-						  int consistent, void *handle))
+						  void *handle))
 {
 	struct volume_group *vg;
 	int ret = 0;
 
-	if (!lock_vol(cmd, vg_name, lock_type)) {
-		log_error("Can't lock volume group %s: skipping", vg_name);
-		return ECMD_FAILED;
-	}
-
 	log_verbose("Finding volume group \"%s\"", vg_name);
-	if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent))) {
-		log_error("Volume group \"%s\" not found", vg_name);
-		unlock_vg(cmd, vg_name);
-		return ECMD_FAILED;
-	}
 
-	if (!vg_check_status(vg, CLUSTERED)) {
-		unlock_release_vg(cmd, vg, vg_name);
-		return ECMD_FAILED;
-	}
+	vg = vg_read(cmd, vg_name, vgid, flags);
 
 	if (!dm_list_empty(tags)) {
 		/* Only process if a tag matches or it's on arg_vgnames */
@@ -482,7 +436,7 @@ static int _process_one_vg(struct cmd_co
 		}
 	}
 
-	if ((ret = process_single(cmd, vg_name, vg, consistent,
+	if ((ret = process_single(cmd, vg_name, vg,
 				  handle)) > ret_max) {
 		ret_max = ret;
 	}
@@ -493,11 +447,11 @@ static int _process_one_vg(struct cmd_co
 }
 
 int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
-		    uint32_t lock_type, int consistent, void *handle,
+		    uint32_t flags, void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   const char *vg_name,
 					   struct volume_group * vg,
-					   int consistent, void *handle))
+					   void *handle))
 {
 	int opt = 0;
 	int ret_max = ECMD_PROCESSED;
@@ -560,7 +514,7 @@ int process_each_vg(struct cmd_context *
 				continue;
 			ret_max = _process_one_vg(cmd, vg_name, vgid, &tags,
 						  &arg_vgnames,
-					  	  lock_type, consistent, handle,
+					  	  flags, handle,
 					  	  ret_max, process_single);
 			if (sigint_caught())
 				return ret_max;
@@ -572,7 +526,7 @@ int process_each_vg(struct cmd_context *
 				continue;	/* FIXME Unnecessary? */
 			ret_max = _process_one_vg(cmd, vg_name, NULL, &tags,
 						  &arg_vgnames,
-					  	  lock_type, consistent, handle,
+					  	  flags, handle,
 					  	  ret_max, process_single);
 			if (sigint_caught())
 				return ret_max;
@@ -1179,30 +1133,6 @@ struct dm_list *clone_pv_list(struct dm_
 	return r;
 }
 
-/*
- * Attempt metadata recovery
- */
-struct volume_group *recover_vg(struct cmd_context *cmd, const char *vgname,
-				uint32_t lock_type)
-{
-	int consistent = 1;
-
-	/* Don't attempt automatic recovery without proper locking */
-	if (lockingfailed())
-		return NULL;
-
-	lock_type &= ~LCK_TYPE_MASK;
-	lock_type |= LCK_WRITE;
-
-	if (!lock_vol(cmd, vgname, lock_type)) {
-		log_error("Can't lock %s for metadata recovery: skipping",
-			  vgname);
-		return NULL;
-	}
-
-	return vg_read_internal(cmd, vgname, NULL, &consistent);
-}
-
 int apply_lvname_restrictions(const char *name)
 {
 	if (!strncmp(name, "snapshot", 8)) {
diff -rN -u -p old-temp.31080/tools/toollib.h new-temp.31080/tools/toollib.h
--- old-temp.31080/tools/toollib.h	2009-05-03 13:29:27.766236090 +0200
+++ new-temp.31080/tools/toollib.h	2009-05-03 13:29:27.870237506 +0200
@@ -27,11 +27,11 @@ struct volume_group *recover_vg(struct c
 				uint32_t lock_type);
 
 int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
-		    uint32_t lock_type, int consistent, void *handle,
+		    uint32_t flags, void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   const char *vg_name,
 					   struct volume_group * vg,
-					   int consistent, void *handle));
+					   void *handle));
 
 int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 		    struct volume_group *vg, uint32_t lock_type,
@@ -51,7 +51,7 @@ int process_each_segment_in_pv(struct cm
 						      void *handle));
 
 int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
-		    uint32_t lock_type, void *handle,
+		    uint32_t flags, void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   struct logical_volume * lv,
 					   void *handle));
diff -rN -u -p old-temp.31080/tools/vgcfgbackup.c new-temp.31080/tools/vgcfgbackup.c
--- old-temp.31080/tools/vgcfgbackup.c	2009-05-03 13:29:27.766236090 +0200
+++ new-temp.31080/tools/vgcfgbackup.c	2009-05-03 13:29:27.870237506 +0200
@@ -48,19 +48,14 @@ static char *_expand_filename(const char
 }
 
 static int vg_backup_single(struct cmd_context *cmd, const char *vg_name,
-			    struct volume_group *vg, int consistent,
+			    struct volume_group *vg,
 			    void *handle)
 {
 	char **last_filename = (char **)handle;
 	char *filename;
 
-	if (!vg) {
-		log_error("Volume group \"%s\" not found", vg_name);
+	if (vg_read_error(vg) && !vg_read_error(vg) == FAILED_INCONSISTENT)
 		return ECMD_FAILED;
-	}
-
-	if (!consistent)
-		log_error("WARNING: Volume group \"%s\" inconsistent", vg_name);
 
 	if (arg_count(cmd, file_ARG)) {
 		if (!(filename = _expand_filename(arg_value(cmd, file_ARG),
@@ -72,7 +67,7 @@ static int vg_backup_single(struct cmd_c
 		if (!backup_to_file(filename, vg->cmd->cmd_line, vg))
 			return ECMD_FAILED;
 	} else {
-		if (!consistent) {
+		if (vg_read_error(vg) == FAILED_INCONSISTENT) {
 			log_error("No backup taken: specify filename with -f "
 				  "to backup an inconsistent VG");
 			stack;
@@ -98,7 +93,7 @@ int vgcfgbackup(struct cmd_context *cmd,
 
 	init_pvmove(1);
 
-	ret = process_each_vg(cmd, argc, argv, LCK_VG_READ, 0, &last_filename,
+	ret = process_each_vg(cmd, argc, argv, 0, &last_filename,
 			      &vg_backup_single);
 
 	dm_free(last_filename);
diff -rN -u -p old-temp.31080/tools/vgchange.c new-temp.31080/tools/vgchange.c
--- old-temp.31080/tools/vgchange.c	2009-05-03 13:29:27.762235512 +0200
+++ new-temp.31080/tools/vgchange.c	2009-05-03 13:29:27.870237506 +0200
@@ -521,28 +521,13 @@ static int _vgchange_refresh(struct cmd_
 }
 
 static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
-			   struct volume_group *vg, int consistent,
+			   struct volume_group *vg,
 			   void *handle __attribute((unused)))
 {
 	int r = ECMD_FAILED;
 
-	if (!vg) {
-		log_error("Unable to find volume group \"%s\"", vg_name);
+	if (vg_read_error(vg))
 		return ECMD_FAILED;
-	}
-
-	if (!consistent) {
-		unlock_release_vg(cmd, vg, vg_name);
-		dev_close_all();
-		log_error("Volume group \"%s\" inconsistent", vg_name);
-		if (!(vg = recover_vg(cmd, vg_name, LCK_VG_WRITE)))
-			return ECMD_FAILED;
-	}
-
-	if (!(vg_status(vg) & LVM_WRITE) && !arg_count(cmd, available_ARG)) {
-		log_error("Volume group \"%s\" is read-only", vg->name);
-		return ECMD_FAILED;
-	}
 
 	if (vg_status(vg) & EXPORTED_VG) {
 		log_error("Volume group \"%s\" is exported", vg_name);
@@ -633,6 +618,6 @@ int vgchange(struct cmd_context *cmd, in
 
 	return process_each_vg(cmd, argc, argv,
 			       (arg_count(cmd, available_ARG)) ?
-			       LCK_VG_READ : LCK_VG_WRITE, 0, NULL,
+			       0 : READ_FOR_UPDATE, NULL,
 			       &vgchange_single);
 }
diff -rN -u -p old-temp.31080/tools/vgck.c new-temp.31080/tools/vgck.c
--- old-temp.31080/tools/vgck.c	2009-05-03 13:29:27.762235512 +0200
+++ new-temp.31080/tools/vgck.c	2009-05-03 13:29:27.870237506 +0200
@@ -18,30 +18,14 @@
 
 static int vgck_single(struct cmd_context *cmd __attribute((unused)),
 		       const char *vg_name,
-		       struct volume_group *vg, int consistent,
+		       struct volume_group *vg,
 		       void *handle __attribute((unused)))
 {
-	if (!vg) {
-		log_error("Volume group \"%s\" not found", vg_name);
-		return ECMD_FAILED;
-	}
-
-	if (!consistent) {
-		log_error("Volume group \"%s\" inconsistent", vg_name);
-		return ECMD_FAILED;
-	}
-
-	if (!vg_check_status(vg, EXPORTED_VG))
-		return ECMD_FAILED;
-
-	if (!vg_validate(vg))
-		return ECMD_FAILED;
-
 	return ECMD_PROCESSED;
 }
 
 int vgck(struct cmd_context *cmd, int argc, char **argv)
 {
-	return process_each_vg(cmd, argc, argv, LCK_VG_READ, 0, NULL,
+	return process_each_vg(cmd, argc, argv, 0, NULL,
 			       &vgck_single);
 }
diff -rN -u -p old-temp.31080/tools/vgconvert.c new-temp.31080/tools/vgconvert.c
--- old-temp.31080/tools/vgconvert.c	2009-05-03 13:29:27.762235512 +0200
+++ new-temp.31080/tools/vgconvert.c	2009-05-03 13:29:27.870237506 +0200
@@ -16,7 +16,7 @@
 #include "tools.h"
 
 static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
-			    struct volume_group *vg, int consistent,
+			    struct volume_group *vg,
 			    void *handle __attribute((unused)))
 {
 	struct physical_volume *pv, *existing_pv;
@@ -32,18 +32,8 @@ static int vgconvert_single(struct cmd_c
 	struct lvinfo info;
 	int active = 0;
 
-	if (!vg) {
-		log_error("Unable to find volume group \"%s\"", vg_name);
+	if (vg_read_error(vg))
 		return ECMD_FAILED;
-	}
-
-	if (!consistent) {
-		unlock_release_vg(cmd, vg, vg_name);
-		dev_close_all();
-		log_error("Volume group \"%s\" inconsistent", vg_name);
-		if (!(vg = recover_vg(cmd, vg_name, LCK_VG_WRITE)))
-			return ECMD_FAILED;
-	}
 
 	if (!vg_check_status(vg, LVM_WRITE | EXPORTED_VG))
 		return ECMD_FAILED;
@@ -233,6 +223,6 @@ int vgconvert(struct cmd_context *cmd, i
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_vg(cmd, argc, argv, LCK_VG_WRITE, 0, NULL,
+	return process_each_vg(cmd, argc, argv, READ_FOR_UPDATE, NULL,
 			       &vgconvert_single);
 }
diff -rN -u -p old-temp.31080/tools/vgdisplay.c new-temp.31080/tools/vgdisplay.c
--- old-temp.31080/tools/vgdisplay.c	2009-05-03 13:29:27.762235512 +0200
+++ new-temp.31080/tools/vgdisplay.c	2009-05-03 13:29:27.870237506 +0200
@@ -16,17 +16,12 @@
 #include "tools.h"
 
 static int vgdisplay_single(struct cmd_context *cmd, const char *vg_name,
-			    struct volume_group *vg, int consistent,
+			    struct volume_group *vg,
 			    void *handle __attribute((unused)))
 {
 	/* FIXME Do the active check here if activevolumegroups_ARG ? */
-	if (!vg) {
-		log_error("Volume group \"%s\" doesn't exist", vg_name);
+	if (vg_read_error(vg))
 		return ECMD_FAILED;
-	}
-
-	if (!consistent)
-		log_error("WARNING: Volume group \"%s\" inconsistent", vg_name);
 
 	vg_check_status(vg, EXPORTED_VG);
 
@@ -98,8 +93,7 @@ int vgdisplay(struct cmd_context *cmd, i
 	}
 **********/
 
-	return process_each_vg(cmd, argc, argv, LCK_VG_READ, 0, NULL,
-			       vgdisplay_single);
+	return process_each_vg(cmd, argc, argv, 0, NULL, vgdisplay_single);
 
 /******** FIXME Need to count number processed
 	  Add this to process_each_vg if arg_count(cmd,activevolumegroups_ARG) ?
diff -rN -u -p old-temp.31080/tools/vgexport.c new-temp.31080/tools/vgexport.c
--- old-temp.31080/tools/vgexport.c	2009-05-03 13:29:27.762235512 +0200
+++ new-temp.31080/tools/vgexport.c	2009-05-03 13:29:27.870237506 +0200
@@ -17,25 +17,14 @@
 
 static int vgexport_single(struct cmd_context *cmd __attribute((unused)),
 			   const char *vg_name,
-			   struct volume_group *vg, int consistent,
+			   struct volume_group *vg,
 			   void *handle __attribute((unused)))
 {
 	struct pv_list *pvl;
 	struct physical_volume *pv;
 
-	if (!vg) {
-		log_error("Unable to find volume group \"%s\"", vg_name);
+	if (vg_read_error(vg))
 		goto error;
-	}
-
-	if (!consistent) {
-		log_error("Volume group %s inconsistent", vg_name);
-		goto error;
-	}
-
-	if (!vg_check_status(vg, EXPORTED_VG | LVM_WRITE)) {
-		goto error;
-	}
 
 	if (lvs_in_vg_activated(vg)) {
 		log_error("Volume group \"%s\" has active logical volumes",
@@ -78,6 +67,6 @@ int vgexport(struct cmd_context *cmd, in
 		return ECMD_FAILED;
 	}
 
-	return process_each_vg(cmd, argc, argv, LCK_VG_WRITE, 1, NULL,
+	return process_each_vg(cmd, argc, argv, READ_FOR_UPDATE, NULL,
 			       &vgexport_single);
 }
diff -rN -u -p old-temp.31080/tools/vgimport.c new-temp.31080/tools/vgimport.c
--- old-temp.31080/tools/vgimport.c	2009-05-03 13:29:27.762235512 +0200
+++ new-temp.31080/tools/vgimport.c	2009-05-03 13:29:27.870237506 +0200
@@ -17,17 +17,14 @@
 
 static int vgimport_single(struct cmd_context *cmd __attribute((unused)),
 			   const char *vg_name,
-			   struct volume_group *vg, int consistent,
+			   struct volume_group *vg,
 			   void *handle __attribute((unused)))
 {
 	struct pv_list *pvl;
 	struct physical_volume *pv;
 
-	if (!vg || !consistent) {
-		log_error("Unable to find exported volume group \"%s\"",
-			  vg_name);
+	if (vg_read_error(vg))
 		goto error;
-	}
 
 	if (!(vg_status(vg) & EXPORTED_VG)) {
 		log_error("Volume group \"%s\" is not exported", vg_name);
@@ -74,6 +71,7 @@ int vgimport(struct cmd_context *cmd, in
 		return ECMD_FAILED;
 	}
 
-	return process_each_vg(cmd, argc, argv, LCK_VG_WRITE, 1, NULL,
+	return process_each_vg(cmd, argc, argv,
+			       READ_FOR_UPDATE | READ_ALLOW_EXPORTED, NULL,
 			       &vgimport_single);
 }
diff -rN -u -p old-temp.31080/tools/vgremove.c new-temp.31080/tools/vgremove.c
--- old-temp.31080/tools/vgremove.c	2009-05-03 13:29:27.762235512 +0200
+++ new-temp.31080/tools/vgremove.c	2009-05-03 13:29:27.874238783 +0200
@@ -16,10 +16,10 @@
 #include "tools.h"
 
 static int vgremove_single(struct cmd_context *cmd, const char *vg_name,
-			   struct volume_group *vg, int consistent,
+			   struct volume_group *vg,
 			   void *handle __attribute((unused)))
 {
-	if (!vg_remove_single(cmd, vg_name, vg, consistent,
+	if (!vg_remove_single(cmd, vg_name, vg,
 			      arg_count(cmd, force_ARG)))
 		return ECMD_FAILED;
 
@@ -41,7 +41,7 @@ int vgremove(struct cmd_context *cmd, in
 	}
 
 	ret = process_each_vg(cmd, argc, argv,
-			      LCK_VG_WRITE | LCK_NONBLOCK, 1,
+			      READ_FOR_UPDATE | LOCK_NONBLOCKING,
 			      NULL, &vgremove_single);
 
 	unlock_vg(cmd, VG_ORPHANS);
diff -rN -u -p old-temp.31080/tools/vgscan.c new-temp.31080/tools/vgscan.c
--- old-temp.31080/tools/vgscan.c	2009-05-03 13:29:27.762235512 +0200
+++ new-temp.31080/tools/vgscan.c	2009-05-03 13:29:27.874238783 +0200
@@ -16,22 +16,11 @@
 #include "tools.h"
 
 static int vgscan_single(struct cmd_context *cmd, const char *vg_name,
-			 struct volume_group *vg, int consistent,
+			 struct volume_group *vg,
 			 void *handle __attribute((unused)))
 {
-	if (!vg) {
-		log_error("Volume group \"%s\" not found", vg_name);
+	if (vg_read_error(vg))
 		return ECMD_FAILED;
-	}
-
-	if (!consistent) {
-		unlock_release_vg(cmd, vg, vg_name);
-		dev_close_all();
-		log_error("Volume group \"%s\" inconsistent", vg_name);
-		/* Don't allow partial switch to this program */
-		if (!(vg = recover_vg(cmd, vg_name, LCK_VG_WRITE)))
-			return ECMD_FAILED;
-	}
 
 	log_print("Found %svolume group \"%s\" using metadata type %s",
 		  (vg_status(vg) & EXPORTED_VG) ? "exported " : "", vg_name,
@@ -61,8 +50,7 @@ int vgscan(struct cmd_context *cmd, int 
 
 	log_print("Reading all physical volumes.  This may take a while...");
 
-	maxret = process_each_vg(cmd, argc, argv, LCK_VG_READ, 0, NULL,
-				 &vgscan_single);
+	maxret = process_each_vg(cmd, argc, argv, 0, NULL, &vgscan_single);
 
 	if (arg_count(cmd, mknodes_ARG)) {
 		ret = vgmknodes(cmd, argc, argv);


