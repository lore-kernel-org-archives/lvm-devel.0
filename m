From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 1 Jul 2009 17:00:57 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20090701170057.32189.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-01 17:00:52

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : lvchange.c lvdisplay.c lvremove.c lvscan.c 
	                 polldaemon.c reporter.c toollib.c toollib.h 
	                 vgcfgbackup.c vgchange.c vgck.c vgconvert.c 
	                 vgdisplay.c vgexport.c vgimport.c vgremove.c 
	                 vgscan.c 

Log message:
	Rework the toollib interface (process_each_*) on top of new vg_read.
	
	Sun May  3 12:32:30 CEST 2009  Petr Rockai <me@mornfall.net>
	* Rework the toollib interface (process_each_*) on top of new vg_read.
	
	Rebased 6/26/09 by Dave W.
	- Add skipping message to process_each_lv
	- Remove inconsistent_t.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.77&r2=1.78
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.228&r2=1.229
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.104&r2=1.105
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvdisplay.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvremove.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvscan.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.158&r2=1.159
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcfgbackup.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgck.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgdisplay.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgexport.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgimport.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgremove.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgscan.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34

--- LVM2/lib/metadata/metadata-exported.h	2009/06/09 14:29:10	1.77
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/01 17:00:50	1.78
@@ -155,16 +155,6 @@
 	DONT_PROMPT_OVERRIDE = 2 /* Skip prompt + override a second condition */
 } force_t;
 
-/*
- * What to do if VG is inconsistent
- * FIXME: remove this after vg_read changes
- */
-typedef enum {
-	VG_INCONSISTENT_ABORT    = 0, /* Abort operation */
-	VG_INCONSISTENT_CONTINUE = 1, /* Process operation but do not try repair */
-	VG_INCONSISTENT_REPAIR   = 2  /* Try to repair VG before processing */
-} inconsistent_t;
-
 struct cmd_context;
 struct format_handler;
 struct labeller;
@@ -445,7 +435,7 @@
 			       int pv_count, char **pv_names);
 int vg_remove(struct volume_group *vg);
 int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
-		     struct volume_group *vg, int consistent,
+		     struct volume_group *vg,
 		     force_t force);
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
--- LVM2/lib/metadata/metadata.c	2009/06/30 18:39:31	1.228
+++ LVM2/lib/metadata/metadata.c	2009/07/01 17:00:51	1.229
@@ -357,7 +357,7 @@
 
 /* FIXME: remove redundant vg_name */
 int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
-		     struct volume_group *vg, int consistent,
+		     struct volume_group *vg,
 		     force_t force __attribute((unused)))
 {
 	struct physical_volume *pv;
@@ -365,7 +365,7 @@
 	unsigned lv_count;
 	int ret = 1;
 
-	if (!vg || !consistent || vg_missing_pv_count(vg)) {
+	if (vg_read_error(vg) || vg_missing_pv_count(vg)) {
 		log_error("Volume group \"%s\" not found, is inconsistent "
 			  "or has PVs missing.", vg_name);
 		log_error("Consider vgreduce --removemissing if metadata "
--- LVM2/tools/lvchange.c	2009/06/06 22:00:20	1.104
+++ LVM2/tools/lvchange.c	2009/07/01 17:00:52	1.105
@@ -726,6 +726,6 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_lv(cmd, argc, argv, LCK_VG_WRITE, NULL,
+	return process_each_lv(cmd, argc, argv, READ_FOR_UPDATE, NULL,
 			       &lvchange_single);
 }
--- LVM2/tools/lvdisplay.c	2009/05/13 21:27:44	1.22
+++ LVM2/tools/lvdisplay.c	2009/07/01 17:00:52	1.23
@@ -54,6 +54,6 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_lv(cmd, argc, argv, LCK_VG_READ, NULL,
+	return process_each_lv(cmd, argc, argv, 0, NULL,
 			       &_lvdisplay_single);
 }
--- LVM2/tools/lvremove.c	2009/04/25 01:18:00	1.57
+++ LVM2/tools/lvremove.c	2009/07/01 17:00:52	1.58
@@ -41,6 +41,6 @@
 
 	cmd->handles_missing_pvs = 1;
 
-	return process_each_lv(cmd, argc, argv, LCK_VG_WRITE, NULL,
+	return process_each_lv(cmd, argc, argv, READ_FOR_UPDATE, NULL,
 			       &lvremove_single);
 }
--- LVM2/tools/lvscan.c	2009/05/13 21:27:44	1.38
+++ LVM2/tools/lvscan.c	2009/07/01 17:00:52	1.39
@@ -80,6 +80,6 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_lv(cmd, argc, argv, LCK_VG_READ, NULL,
+	return process_each_lv(cmd, argc, argv, 0, NULL,
 			       &lvscan_single);
 }
--- LVM2/tools/polldaemon.c	2009/07/01 16:59:37	1.18
+++ LVM2/tools/polldaemon.c	2009/07/01 17:00:52	1.19
@@ -175,7 +175,7 @@
 }
 
 static int _poll_vg(struct cmd_context *cmd, const char *vgname,
-		    struct volume_group *vg, int consistent, void *handle)
+		    struct volume_group *vg, void *handle)
 {
 	struct daemon_parms *parms = (struct daemon_parms *) handle;
 	struct lv_list *lvl;
@@ -183,7 +183,7 @@
 	const char *name;
 	int finished;
 
-	if (!vg_check_status(vg, EXPORTED_VG))
+	if (vg_read_error(vg))
 		return ECMD_FAILED;
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
@@ -208,9 +208,7 @@
 {
 	while (1) {
 		parms->outstanding_count = 0;
-		/* FIXME Should we silently recover it here or not? */
-		process_each_vg(cmd, 0, NULL, LCK_VG_WRITE,
-				VG_INCONSISTENT_ABORT, parms, _poll_vg);
+		process_each_vg(cmd, 0, NULL, READ_FOR_UPDATE, parms, _poll_vg);
 		if (!parms->outstanding_count)
 			break;
 		sleep(parms->interval);
--- LVM2/tools/reporter.c	2009/07/01 16:59:37	1.52
+++ LVM2/tools/reporter.c	2009/07/01 17:00:52	1.53
@@ -18,8 +18,11 @@
 
 static int _vgs_single(struct cmd_context *cmd __attribute((unused)),
 		       const char *vg_name, struct volume_group *vg,
-		       int consistent __attribute((unused)), void *handle)
+		       void *handle)
 {
+	if (vg_read_error(vg))
+		return ECMD_FAILED;
+
 	if (!report_object(handle, vg, NULL, NULL, NULL, NULL))
 		return ECMD_FAILED;
 
@@ -176,17 +179,21 @@
 
 static int _pvs_in_vg(struct cmd_context *cmd, const char *vg_name,
 		      struct volume_group *vg,
-		      int consistent __attribute((unused)),
 		      void *handle)
 {
+	if (vg_read_error(vg))
+		return ECMD_FAILED;
+
 	return process_each_pv_in_vg(cmd, vg, NULL, handle, &_pvs_single);
 }
 
 static int _pvsegs_in_vg(struct cmd_context *cmd, const char *vg_name,
 			 struct volume_group *vg,
-			 int consistent __attribute((unused)),
 			 void *handle)
 {
+	if (vg_read_error(vg))
+		return ECMD_FAILED;
+
 	return process_each_pv_in_vg(cmd, vg, NULL, handle, &_pvsegs_single);
 }
 
@@ -363,12 +370,11 @@
 
 	switch (report_type) {
 	case LVS:
-		r = process_each_lv(cmd, argc, argv, LCK_VG_READ, report_handle,
+		r = process_each_lv(cmd, argc, argv, 0, report_handle,
 				    &_lvs_single);
 		break;
 	case VGS:
-		r = process_each_vg(cmd, argc, argv, LCK_VG_READ,
-				    VG_INCONSISTENT_CONTINUE,
+		r = process_each_vg(cmd, argc, argv, 0,
 				    report_handle, &_vgs_single);
 		break;
 	case LABEL:
@@ -380,12 +386,11 @@
 			r = process_each_pv(cmd, argc, argv, NULL, LCK_VG_READ,
 					    0, report_handle, &_pvs_single);
 		else
-			r = process_each_vg(cmd, argc, argv, LCK_VG_READ,
-					    VG_INCONSISTENT_CONTINUE,
+			r = process_each_vg(cmd, argc, argv, 0,
 					    report_handle, &_pvs_in_vg);
 		break;
 	case SEGS:
-		r = process_each_lv(cmd, argc, argv, LCK_VG_READ, report_handle,
+		r = process_each_lv(cmd, argc, argv, 0, report_handle,
 				    &_lvsegs_single);
 		break;
 	case PVSEGS:
@@ -393,8 +398,7 @@
 			r = process_each_pv(cmd, argc, argv, NULL, LCK_VG_READ,
 					    0, report_handle, &_pvsegs_single);
 		else
-			r = process_each_vg(cmd, argc, argv, LCK_VG_READ,
-					    VG_INCONSISTENT_CONTINUE,
+			r = process_each_vg(cmd, argc, argv, 0,
 					    report_handle, &_pvsegs_in_vg);
 		break;
 	}
--- LVM2/tools/toollib.c	2009/06/10 11:15:29	1.158
+++ LVM2/tools/toollib.c	2009/07/01 17:00:52	1.159
@@ -164,7 +164,7 @@
 }
 
 int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
-		    uint32_t lock_type, void *handle,
+		    uint32_t flags, void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   struct logical_volume * lv,
 					   void *handle))
@@ -172,7 +172,6 @@
 	int opt = 0;
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
-	int consistent;
 
 	struct dm_list *tags_arg;
 	struct dm_list *vgnames;	/* VGs to process */
@@ -287,44 +286,14 @@
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
-			unlock_and_release_vg(cmd, vg, vgname);
-			if (ret_max < ECMD_FAILED)
+			if (ret_max < ECMD_FAILED) {
+				log_error("Skipping volume group %s", vgname);
 				ret_max = ECMD_FAILED;
+			}
 			continue;
 		}
 
@@ -383,8 +352,8 @@
 	if (is_pv(pv) && !vg && !is_orphan(pv)) {
 		vg_name = pv_vg_name(pv);
 
-		if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_READ,
-					    CLUSTERED, 0))) {
+		vg = vg_read(cmd, vg_name, NULL, 0);
+		if (vg_read_error(vg)) {
 			log_error("Skipping volume group %s", vg_name);
 			return ECMD_FAILED;
 		}
@@ -449,33 +418,18 @@
 static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
 			   const char *vgid,
 			   struct dm_list *tags, struct dm_list *arg_vgnames,
-			   uint32_t lock_type, inconsistent_t repair_vg, void *handle,
-			   int ret_max,
+			   uint32_t flags, void *handle, int ret_max,
 			   int (*process_single) (struct cmd_context * cmd,
 						  const char *vg_name,
 						  struct volume_group * vg,
-						  int consistent, void *handle))
+						  void *handle))
 {
 	struct volume_group *vg;
-	int consistent = 0;
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
-		ret_max = ECMD_FAILED;
-		goto out;
-	}
+	vg = vg_read(cmd, vg_name, vgid, flags);
 
 	if (!dm_list_empty(tags)) {
 		/* Only process if a tag matches or it's on arg_vgnames */
@@ -484,26 +438,7 @@
 			goto out;
 	}
 
-	if (!consistent)
-		switch (repair_vg) {
-		case VG_INCONSISTENT_ABORT:
-			log_error("Volume group %s inconsistent - skipping", vg_name);
-			ret_max = ECMD_FAILED;
-			goto out;
-		case VG_INCONSISTENT_CONTINUE:
-			log_error("Volume group %s inconsistent", vg_name);
-			break;
-		case VG_INCONSISTENT_REPAIR:
-			unlock_and_release_vg(cmd, vg, vg_name);
-			dev_close_all();
-			log_error("Volume group %s inconsistent", vg_name);
-			if (!(vg = recover_vg(cmd, vg_name, LCK_VG_WRITE)))
-				return ECMD_FAILED;
-			consistent = 1;
-			break;
-		}
-
-	if ((ret = process_single(cmd, vg_name, vg, consistent,
+	if ((ret = process_single(cmd, vg_name, vg,
 				  handle)) > ret_max) {
 		ret_max = ret;
 	}
@@ -514,11 +449,11 @@
 }
 
 int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
-		    uint32_t lock_type, inconsistent_t repair_vg, void *handle,
+		    uint32_t flags, void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   const char *vg_name,
 					   struct volume_group * vg,
-					   int consistent, void *handle))
+					   void *handle))
 {
 	int opt = 0;
 	int ret_max = ECMD_PROCESSED;
@@ -581,7 +516,7 @@
 				continue;
 			ret_max = _process_one_vg(cmd, vg_name, vgid, &tags,
 						  &arg_vgnames,
-					  	  lock_type, repair_vg, handle,
+						  flags, handle,
 					  	  ret_max, process_single);
 			if (sigint_caught())
 				return ret_max;
@@ -593,7 +528,7 @@
 				continue;	/* FIXME Unnecessary? */
 			ret_max = _process_one_vg(cmd, vg_name, NULL, &tags,
 						  &arg_vgnames,
-					  	  lock_type, repair_vg, handle,
+						  flags, handle,
 					  	  ret_max, process_single);
 			if (sigint_caught())
 				return ret_max;
@@ -1200,34 +1135,6 @@
 	return r;
 }
 
-/*
- * Attempt metadata recovery
- */
-struct volume_group *recover_vg(struct cmd_context *cmd, const char *vgname,
-				uint32_t lock_type)
-{
-	int consistent = 1;
-	struct volume_group *vg;
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
-	if (!(vg = vg_read_internal(cmd, vgname, NULL, &consistent)))
-		unlock_vg(cmd, vgname);
-
-	return vg;
-}
-
 int apply_lvname_restrictions(const char *name)
 {
 	if (!strncmp(name, "snapshot", 8)) {
--- LVM2/tools/toollib.h	2009/06/05 20:00:52	1.62
+++ LVM2/tools/toollib.h	2009/07/01 17:00:52	1.63
@@ -27,11 +27,11 @@
 				uint32_t lock_type);
 
 int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
-		    uint32_t lock_type, inconsistent_t repair_vg, void *handle,
+		    uint32_t flags, void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   const char *vg_name,
 					   struct volume_group * vg,
-					   int consistent, void *handle));
+					   void *handle));
 
 int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 		    struct volume_group *vg, uint32_t lock_type,
@@ -51,7 +51,7 @@
 						      void *handle));
 
 int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
-		    uint32_t lock_type, void *handle,
+		    uint32_t flags, void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   struct logical_volume * lv,
 					   void *handle));
--- LVM2/tools/vgcfgbackup.c	2009/06/05 20:00:52	1.27
+++ LVM2/tools/vgcfgbackup.c	2009/07/01 17:00:52	1.28
@@ -48,12 +48,15 @@
 }
 
 static int vg_backup_single(struct cmd_context *cmd, const char *vg_name,
-			    struct volume_group *vg, int consistent,
+			    struct volume_group *vg,
 			    void *handle)
 {
 	char **last_filename = (char **)handle;
 	char *filename;
 
+	if (vg_read_error(vg) && !vg_read_error(vg) == FAILED_INCONSISTENT)
+		return ECMD_FAILED;
+
 	if (arg_count(cmd, file_ARG)) {
 		if (!(filename = _expand_filename(arg_value(cmd, file_ARG),
 						  vg->name, last_filename))) {
@@ -64,7 +67,7 @@
 		if (!backup_to_file(filename, vg->cmd->cmd_line, vg))
 			return ECMD_FAILED;
 	} else {
-		if (!consistent) {
+		if (vg_read_error(vg) == FAILED_INCONSISTENT) {
 			log_error("No backup taken: specify filename with -f "
 				  "to backup an inconsistent VG");
 			stack;
@@ -90,8 +93,7 @@
 
 	init_pvmove(1);
 
-	ret = process_each_vg(cmd, argc, argv, LCK_VG_READ,
-			      VG_INCONSISTENT_CONTINUE,
+	ret = process_each_vg(cmd, argc, argv, 0,
 			      &last_filename, &vg_backup_single);
 
 	dm_free(last_filename);
--- LVM2/tools/vgchange.c	2009/06/05 20:00:52	1.73
+++ LVM2/tools/vgchange.c	2009/07/01 17:00:52	1.74
@@ -521,15 +521,13 @@
 }
 
 static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
-			   struct volume_group *vg, int consistent,
+			   struct volume_group *vg,
 			   void *handle __attribute((unused)))
 {
 	int r = ECMD_FAILED;
 
-	if (!(vg_status(vg) & LVM_WRITE) && !arg_count(cmd, available_ARG)) {
-		log_error("Volume group \"%s\" is read-only", vg->name);
+	if (vg_read_error(vg))
 		return ECMD_FAILED;
-	}
 
 	if (vg_status(vg) & EXPORTED_VG) {
 		log_error("Volume group \"%s\" is exported", vg_name);
@@ -620,7 +618,7 @@
 
 	return process_each_vg(cmd, argc, argv,
 			       (arg_count(cmd, available_ARG)) ?
-			       LCK_VG_READ : LCK_VG_WRITE,
-			       VG_INCONSISTENT_REPAIR, NULL,
+			       0 : READ_FOR_UPDATE,
+			       NULL,
 			       &vgchange_single);
 }
--- LVM2/tools/vgck.c	2009/06/05 20:00:52	1.21
+++ LVM2/tools/vgck.c	2009/07/01 17:00:52	1.22
@@ -18,7 +18,7 @@
 
 static int vgck_single(struct cmd_context *cmd __attribute((unused)),
 		       const char *vg_name,
-		       struct volume_group *vg, int consistent,
+		       struct volume_group *vg,
 		       void *handle __attribute((unused)))
 {
 	if (!vg_check_status(vg, EXPORTED_VG))
@@ -32,7 +32,6 @@
 
 int vgck(struct cmd_context *cmd, int argc, char **argv)
 {
-	return process_each_vg(cmd, argc, argv, LCK_VG_READ,
-			       VG_INCONSISTENT_ABORT, NULL,
+	return process_each_vg(cmd, argc, argv, 0, NULL,
 			       &vgck_single);
 }
--- LVM2/tools/vgconvert.c	2009/06/05 20:00:52	1.35
+++ LVM2/tools/vgconvert.c	2009/07/01 17:00:52	1.36
@@ -16,7 +16,7 @@
 #include "tools.h"
 
 static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
-			    struct volume_group *vg, int consistent,
+			    struct volume_group *vg,
 			    void *handle __attribute((unused)))
 {
 	struct physical_volume *pv, *existing_pv;
@@ -32,6 +32,9 @@
 	struct lvinfo info;
 	int active = 0;
 
+	if (vg_read_error(vg))
+		return ECMD_FAILED;
+
 	if (!vg_check_status(vg, LVM_WRITE | EXPORTED_VG))
 		return ECMD_FAILED;
 
@@ -220,7 +223,6 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_vg(cmd, argc, argv, LCK_VG_WRITE,
-			       VG_INCONSISTENT_REPAIR, NULL,
+	return process_each_vg(cmd, argc, argv, READ_FOR_UPDATE, NULL,
 			       &vgconvert_single);
 }
--- LVM2/tools/vgdisplay.c	2009/06/05 20:00:52	1.23
+++ LVM2/tools/vgdisplay.c	2009/07/01 17:00:52	1.24
@@ -16,10 +16,12 @@
 #include "tools.h"
 
 static int vgdisplay_single(struct cmd_context *cmd, const char *vg_name,
-			    struct volume_group *vg, int consistent,
+			    struct volume_group *vg,
 			    void *handle __attribute((unused)))
 {
 	/* FIXME Do the active check here if activevolumegroups_ARG ? */
+	if (vg_read_error(vg))
+		return ECMD_FAILED;
 
 	vg_check_status(vg, EXPORTED_VG);
 
@@ -91,8 +93,7 @@
 	}
 **********/
 
-	return process_each_vg(cmd, argc, argv, LCK_VG_READ,
-			       VG_INCONSISTENT_CONTINUE, NULL,
+	return process_each_vg(cmd, argc, argv, 0, NULL,
 			       vgdisplay_single);
 
 /******** FIXME Need to count number processed
--- LVM2/tools/vgexport.c	2009/06/05 20:00:52	1.20
+++ LVM2/tools/vgexport.c	2009/07/01 17:00:52	1.21
@@ -17,15 +17,14 @@
 
 static int vgexport_single(struct cmd_context *cmd __attribute((unused)),
 			   const char *vg_name,
-			   struct volume_group *vg, int consistent,
+			   struct volume_group *vg,
 			   void *handle __attribute((unused)))
 {
 	struct pv_list *pvl;
 	struct physical_volume *pv;
 
-	if (!vg_check_status(vg, EXPORTED_VG | LVM_WRITE)) {
+	if (vg_read_error(vg))
 		goto error;
-	}
 
 	if (lvs_in_vg_activated(vg)) {
 		log_error("Volume group \"%s\" has active logical volumes",
@@ -68,7 +67,6 @@
 		return ECMD_FAILED;
 	}
 
-	return process_each_vg(cmd, argc, argv, LCK_VG_WRITE,
-			       VG_INCONSISTENT_ABORT, NULL,
+	return process_each_vg(cmd, argc, argv, READ_FOR_UPDATE, NULL,
 			       &vgexport_single);
 }
--- LVM2/tools/vgimport.c	2009/06/05 20:00:52	1.19
+++ LVM2/tools/vgimport.c	2009/07/01 17:00:52	1.20
@@ -17,12 +17,15 @@
 
 static int vgimport_single(struct cmd_context *cmd __attribute((unused)),
 			   const char *vg_name,
-			   struct volume_group *vg, int consistent,
+			   struct volume_group *vg,
 			   void *handle __attribute((unused)))
 {
 	struct pv_list *pvl;
 	struct physical_volume *pv;
 
+	if (vg_read_error(vg))
+		goto error;
+
 	if (!(vg_status(vg) & EXPORTED_VG)) {
 		log_error("Volume group \"%s\" is not exported", vg_name);
 		goto error;
@@ -68,7 +71,8 @@
 		return ECMD_FAILED;
 	}
 
-	return process_each_vg(cmd, argc, argv, LCK_VG_WRITE,
-			       VG_INCONSISTENT_ABORT, NULL,
+	return process_each_vg(cmd, argc, argv,
+			       READ_FOR_UPDATE | READ_ALLOW_EXPORTED,
+			       NULL,
 			       &vgimport_single);
 }
--- LVM2/tools/vgremove.c	2009/06/05 20:00:52	1.48
+++ LVM2/tools/vgremove.c	2009/07/01 17:00:52	1.49
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
 
@@ -40,10 +40,8 @@
 		return ECMD_FAILED;
 	}
 
-	ret = process_each_vg(cmd, argc, argv, LCK_VG_WRITE,
-			      arg_count(cmd, force_ARG) ?
-			      VG_INCONSISTENT_REPAIR :
-			      VG_INCONSISTENT_ABORT,
+	ret = process_each_vg(cmd, argc, argv,
+			      READ_FOR_UPDATE | LOCK_NONBLOCKING,
 			      NULL, &vgremove_single);
 
 	unlock_vg(cmd, VG_ORPHANS);
--- LVM2/tools/vgscan.c	2009/06/05 20:00:52	1.33
+++ LVM2/tools/vgscan.c	2009/07/01 17:00:52	1.34
@@ -16,9 +16,12 @@
 #include "tools.h"
 
 static int vgscan_single(struct cmd_context *cmd, const char *vg_name,
-			 struct volume_group *vg, int consistent,
+			 struct volume_group *vg,
 			 void *handle __attribute((unused)))
 {
+	if (vg_read_error(vg))
+		return ECMD_FAILED;
+
 	log_print("Found %svolume group \"%s\" using metadata type %s",
 		  (vg_status(vg) & EXPORTED_VG) ? "exported " : "", vg_name,
 		  vg->fid->fmt->name);
@@ -47,8 +50,7 @@
 
 	log_print("Reading all physical volumes.  This may take a while...");
 
-	maxret = process_each_vg(cmd, argc, argv, LCK_VG_READ,
-				 VG_INCONSISTENT_REPAIR, NULL,
+	maxret = process_each_vg(cmd, argc, argv, 0, NULL,
 				 &vgscan_single);
 
 	if (arg_count(cmd, mknodes_ARG)) {


