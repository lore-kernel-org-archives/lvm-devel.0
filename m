From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 26 Jun 2009 05:33:10 -0400
Subject: [PATCH 2/6] Rework the toollib interface (process_each_*) on top of new vg_read.
In-Reply-To: <1246008794-30493-2-git-send-email-dwysocha@redhat.com>
References: <1246008794-30493-1-git-send-email-dwysocha@redhat.com>
	<1246008794-30493-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1246008794-30493-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Sun May  3 12:32:30 CEST 2009  Petr Rockai <me@mornfall.net>
  * Rework the toollib interface (process_each_*) on top of new vg_read.

Rebased 6/26/09 by Dave W.
- Add skipping message to process_each_lv
- Remove inconsistent_t.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |   12 +---
 lib/metadata/metadata.c          |    4 +-
 tools/lvchange.c                 |    2 +-
 tools/lvdisplay.c                |    2 +-
 tools/lvremove.c                 |    2 +-
 tools/lvscan.c                   |    2 +-
 tools/polldaemon.c               |    8 +--
 tools/reporter.c                 |   26 +++++---
 tools/toollib.c                  |  125 +++++---------------------------------
 tools/toollib.h                  |    6 +-
 tools/vgcfgbackup.c              |   10 ++-
 tools/vgchange.c                 |   10 +--
 tools/vgck.c                     |    5 +-
 tools/vgconvert.c                |    8 ++-
 tools/vgdisplay.c                |    7 +-
 tools/vgexport.c                 |    8 +--
 tools/vgimport.c                 |   10 ++-
 tools/vgremove.c                 |   10 +--
 tools/vgscan.c                   |    8 ++-
 19 files changed, 84 insertions(+), 181 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 278d21c..b9e9591 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -155,16 +155,6 @@ typedef enum {
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
@@ -445,7 +435,7 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *name,
 			       int pv_count, char **pv_names);
 int vg_remove(struct volume_group *vg);
 int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
-		     struct volume_group *vg, int consistent,
+		     struct volume_group *vg,
 		     force_t force);
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 36e27fc..14ca01b 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -357,7 +357,7 @@ static int remove_lvs_in_vg(struct cmd_context *cmd,
 
 /* FIXME: remove redundant vg_name */
 int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
-		     struct volume_group *vg, int consistent,
+		     struct volume_group *vg,
 		     force_t force __attribute((unused)))
 {
 	struct physical_volume *pv;
@@ -365,7 +365,7 @@ int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
 	unsigned lv_count;
 	int ret = 1;
 
-	if (!vg || !consistent || vg_missing_pv_count(vg)) {
+	if (vg_read_error(vg) || vg_missing_pv_count(vg)) {
 		log_error("Volume group \"%s\" not found, is inconsistent "
 			  "or has PVs missing.", vg_name);
 		log_error("Consider vgreduce --removemissing if metadata "
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 5abb6e5..f64f6d1 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -726,6 +726,6 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_lv(cmd, argc, argv, LCK_VG_WRITE, NULL,
+	return process_each_lv(cmd, argc, argv, READ_FOR_UPDATE, NULL,
 			       &lvchange_single);
 }
diff --git a/tools/lvdisplay.c b/tools/lvdisplay.c
index 16e7052..f5531cb 100644
--- a/tools/lvdisplay.c
+++ b/tools/lvdisplay.c
@@ -54,6 +54,6 @@ int lvdisplay(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_lv(cmd, argc, argv, LCK_VG_READ, NULL,
+	return process_each_lv(cmd, argc, argv, 0, NULL,
 			       &_lvdisplay_single);
 }
diff --git a/tools/lvremove.c b/tools/lvremove.c
index 712f175..be2107a 100644
--- a/tools/lvremove.c
+++ b/tools/lvremove.c
@@ -41,6 +41,6 @@ int lvremove(struct cmd_context *cmd, int argc, char **argv)
 
 	cmd->handles_missing_pvs = 1;
 
-	return process_each_lv(cmd, argc, argv, LCK_VG_WRITE, NULL,
+	return process_each_lv(cmd, argc, argv, READ_FOR_UPDATE, NULL,
 			       &lvremove_single);
 }
diff --git a/tools/lvscan.c b/tools/lvscan.c
index a286fe1..21bf01c 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -80,6 +80,6 @@ int lvscan(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_lv(cmd, argc, argv, LCK_VG_READ, NULL,
+	return process_each_lv(cmd, argc, argv, 0, NULL,
 			       &lvscan_single);
 }
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index fedbb46..d137f5f 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -175,7 +175,7 @@ static int _wait_for_single_mirror(struct cmd_context *cmd, const char *name, co
 }
 
 static int _poll_vg(struct cmd_context *cmd, const char *vgname,
-		    struct volume_group *vg, int consistent, void *handle)
+		    struct volume_group *vg, void *handle)
 {
 	struct daemon_parms *parms = (struct daemon_parms *) handle;
 	struct lv_list *lvl;
@@ -183,7 +183,7 @@ static int _poll_vg(struct cmd_context *cmd, const char *vgname,
 	const char *name;
 	int finished;
 
-	if (!vg_check_status(vg, EXPORTED_VG))
+	if (vg_read_error(vg))
 		return ECMD_FAILED;
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
@@ -208,9 +208,7 @@ static void _poll_for_all_vgs(struct cmd_context *cmd,
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
diff --git a/tools/reporter.c b/tools/reporter.c
index 1e352b5..d1368d4 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
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
 
@@ -176,17 +179,21 @@ static int _label_single(struct cmd_context *cmd, struct volume_group *vg,
 
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
 
@@ -363,12 +370,11 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 
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
@@ -380,12 +386,11 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
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
@@ -393,8 +398,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 			r = process_each_pv(cmd, argc, argv, NULL, LCK_VG_READ,
 					    0, report_handle, &_pvsegs_single);
 		else
-			r = process_each_vg(cmd, argc, argv, LCK_VG_READ,
-					    VG_INCONSISTENT_CONTINUE,
+			r = process_each_vg(cmd, argc, argv, 0,
 					    report_handle, &_pvsegs_in_vg);
 		break;
 	}
diff --git a/tools/toollib.c b/tools/toollib.c
index 24fbe9f..1fe9249 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -164,7 +164,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 }
 
 int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
-		    uint32_t lock_type, void *handle,
+		    uint32_t flags, void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   struct logical_volume * lv,
 					   void *handle))
@@ -172,7 +172,6 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 	int opt = 0;
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
-	int consistent;
 
 	struct dm_list *tags_arg;
 	struct dm_list *vgnames;	/* VGs to process */
@@ -287,44 +286,14 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
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
 
@@ -383,8 +352,8 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 	if (is_pv(pv) && !vg && !is_orphan(pv)) {
 		vg_name = pv_vg_name(pv);
 
-		if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_READ,
-					    CLUSTERED, 0))) {
+		vg = vg_read(cmd, vg_name, NULL, 0);
+		if (vg_read_error(vg)) {
 			log_error("Skipping volume group %s", vg_name);
 			return ECMD_FAILED;
 		}
@@ -449,33 +418,18 @@ int process_each_segment_in_lv(struct cmd_context *cmd,
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
@@ -484,26 +438,7 @@ static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
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
@@ -514,11 +449,11 @@ out:
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
@@ -581,7 +516,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 				continue;
 			ret_max = _process_one_vg(cmd, vg_name, vgid, &tags,
 						  &arg_vgnames,
-					  	  lock_type, repair_vg, handle,
+						  flags, handle,
 					  	  ret_max, process_single);
 			if (sigint_caught())
 				return ret_max;
@@ -593,7 +528,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 				continue;	/* FIXME Unnecessary? */
 			ret_max = _process_one_vg(cmd, vg_name, NULL, &tags,
 						  &arg_vgnames,
-					  	  lock_type, repair_vg, handle,
+						  flags, handle,
 					  	  ret_max, process_single);
 			if (sigint_caught())
 				return ret_max;
@@ -1200,34 +1135,6 @@ struct dm_list *clone_pv_list(struct dm_pool *mem, struct dm_list *pvsl)
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
diff --git a/tools/toollib.h b/tools/toollib.h
index cc09796..273cb65 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -27,11 +27,11 @@ struct volume_group *recover_vg(struct cmd_context *cmd, const char *vgname,
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
@@ -51,7 +51,7 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 						      void *handle));
 
 int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
-		    uint32_t lock_type, void *handle,
+		    uint32_t flags, void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   struct logical_volume * lv,
 					   void *handle));
diff --git a/tools/vgcfgbackup.c b/tools/vgcfgbackup.c
index 2d77e65..c8ae40c 100644
--- a/tools/vgcfgbackup.c
+++ b/tools/vgcfgbackup.c
@@ -48,12 +48,15 @@ static char *_expand_filename(const char *template, const char *vg_name,
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
@@ -64,7 +67,7 @@ static int vg_backup_single(struct cmd_context *cmd, const char *vg_name,
 		if (!backup_to_file(filename, vg->cmd->cmd_line, vg))
 			return ECMD_FAILED;
 	} else {
-		if (!consistent) {
+		if (vg_read_error(vg) == FAILED_INCONSISTENT) {
 			log_error("No backup taken: specify filename with -f "
 				  "to backup an inconsistent VG");
 			stack;
@@ -90,8 +93,7 @@ int vgcfgbackup(struct cmd_context *cmd, int argc, char **argv)
 
 	init_pvmove(1);
 
-	ret = process_each_vg(cmd, argc, argv, LCK_VG_READ,
-			      VG_INCONSISTENT_CONTINUE,
+	ret = process_each_vg(cmd, argc, argv, 0,
 			      &last_filename, &vg_backup_single);
 
 	dm_free(last_filename);
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 9c5b05b..a5121fc 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -521,15 +521,13 @@ static int _vgchange_refresh(struct cmd_context *cmd, struct volume_group *vg)
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
@@ -620,7 +618,7 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 
 	return process_each_vg(cmd, argc, argv,
 			       (arg_count(cmd, available_ARG)) ?
-			       LCK_VG_READ : LCK_VG_WRITE,
-			       VG_INCONSISTENT_REPAIR, NULL,
+			       0 : READ_FOR_UPDATE,
+			       NULL,
 			       &vgchange_single);
 }
diff --git a/tools/vgck.c b/tools/vgck.c
index 977f447..63d2d41 100644
--- a/tools/vgck.c
+++ b/tools/vgck.c
@@ -18,7 +18,7 @@
 
 static int vgck_single(struct cmd_context *cmd __attribute((unused)),
 		       const char *vg_name,
-		       struct volume_group *vg, int consistent,
+		       struct volume_group *vg,
 		       void *handle __attribute((unused)))
 {
 	if (!vg_check_status(vg, EXPORTED_VG))
@@ -32,7 +32,6 @@ static int vgck_single(struct cmd_context *cmd __attribute((unused)),
 
 int vgck(struct cmd_context *cmd, int argc, char **argv)
 {
-	return process_each_vg(cmd, argc, argv, LCK_VG_READ,
-			       VG_INCONSISTENT_ABORT, NULL,
+	return process_each_vg(cmd, argc, argv, 0, NULL,
 			       &vgck_single);
 }
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index ec5032e..0996d95 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -16,7 +16,7 @@
 #include "tools.h"
 
 static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
-			    struct volume_group *vg, int consistent,
+			    struct volume_group *vg,
 			    void *handle __attribute((unused)))
 {
 	struct physical_volume *pv, *existing_pv;
@@ -32,6 +32,9 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 	struct lvinfo info;
 	int active = 0;
 
+	if (vg_read_error(vg))
+		return ECMD_FAILED;
+
 	if (!vg_check_status(vg, LVM_WRITE | EXPORTED_VG))
 		return ECMD_FAILED;
 
@@ -220,7 +223,6 @@ int vgconvert(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_vg(cmd, argc, argv, LCK_VG_WRITE,
-			       VG_INCONSISTENT_REPAIR, NULL,
+	return process_each_vg(cmd, argc, argv, READ_FOR_UPDATE, NULL,
 			       &vgconvert_single);
 }
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index de38d8b..bbabcee 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
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
 
@@ -91,8 +93,7 @@ int vgdisplay(struct cmd_context *cmd, int argc, char **argv)
 	}
 **********/
 
-	return process_each_vg(cmd, argc, argv, LCK_VG_READ,
-			       VG_INCONSISTENT_CONTINUE, NULL,
+	return process_each_vg(cmd, argc, argv, 0, NULL,
 			       vgdisplay_single);
 
 /******** FIXME Need to count number processed
diff --git a/tools/vgexport.c b/tools/vgexport.c
index fce7e9f..59627b9 100644
--- a/tools/vgexport.c
+++ b/tools/vgexport.c
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
@@ -68,7 +67,6 @@ int vgexport(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	return process_each_vg(cmd, argc, argv, LCK_VG_WRITE,
-			       VG_INCONSISTENT_ABORT, NULL,
+	return process_each_vg(cmd, argc, argv, READ_FOR_UPDATE, NULL,
 			       &vgexport_single);
 }
diff --git a/tools/vgimport.c b/tools/vgimport.c
index 2be2c2f..864a700 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
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
@@ -68,7 +71,8 @@ int vgimport(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	return process_each_vg(cmd, argc, argv, LCK_VG_WRITE,
-			       VG_INCONSISTENT_ABORT, NULL,
+	return process_each_vg(cmd, argc, argv,
+			       READ_FOR_UPDATE | READ_ALLOW_EXPORTED,
+			       NULL,
 			       &vgimport_single);
 }
diff --git a/tools/vgremove.c b/tools/vgremove.c
index e5ad15d..5956075 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
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
 
@@ -40,10 +40,8 @@ int vgremove(struct cmd_context *cmd, int argc, char **argv)
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
diff --git a/tools/vgscan.c b/tools/vgscan.c
index 083cb5a..769c5cf 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
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
@@ -47,8 +50,7 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 
 	log_print("Reading all physical volumes.  This may take a while...");
 
-	maxret = process_each_vg(cmd, argc, argv, LCK_VG_READ,
-				 VG_INCONSISTENT_REPAIR, NULL,
+	maxret = process_each_vg(cmd, argc, argv, 0, NULL,
 				 &vgscan_single);
 
 	if (arg_count(cmd, mknodes_ARG)) {
-- 
1.6.0.6


