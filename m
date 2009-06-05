From: Milan Broz <mbroz@redhat.com>
Date: Fri, 05 Jun 2009 15:34:20 +0200
Subject: [PATCH] Fix double releasing of vg when repairing of vg is requested
Message-ID: <4A291EDC.4060300@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix double releasing of vg when repairing of vg is requested.

Several commands calls process_each_vg() and in provided
callback it explicitly recovers VG if inconsistent.
(vgchange, vgconvert, vgscan)

It means that old VG is released and re-read  but the function
above (process_one_vg) tries to unlock and release old VG.

Patch moves the repair logic into _process_one_vg() function.

It always tries to read vg (even inconsistent) and then decides
what to do according new defined parameter.

Also patch unifies inconsistent error messages.

The only slight change if for vgremove command, where
it now tries to repair VG before it removes if force arg is given.
(It works similar way before, just the order of operation changed).

[maybe this somehow collide with proposed vg_read changes,
but this is serious bug which should be fixed asap...]

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/metadata-exported.h |   10 ++++++++++
 test/t-inconsistent-metadata.sh  |   10 +++++-----
 tools/polldaemon.c               |   15 +++------------
 tools/reporter.c                 |   24 ++++++------------------
 tools/toollib.c                  |   38 ++++++++++++++++++++++++++++----------
 tools/toollib.h                  |    2 +-
 tools/vgcfgbackup.c              |   13 +++----------
 tools/vgchange.c                 |   16 ++--------------
 tools/vgck.c                     |   13 ++-----------
 tools/vgconvert.c                |   16 ++--------------
 tools/vgdisplay.c                |   10 ++--------
 tools/vgexport.c                 |   13 ++-----------
 tools/vgimport.c                 |    9 ++-------
 tools/vgremove.c                 |    6 ++++--
 tools/vgscan.c                   |   17 ++---------------
 15 files changed, 74 insertions(+), 138 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 30725d6..f65df5c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -153,6 +153,16 @@ typedef enum {
 	DONT_PROMPT_OVERRIDE = 2 /* Skip prompt + override a second condition */
 } force_t;
 
+/*
+ * What to do if VG is inconsistent
+ * FIXME: remove this after vg_read changes
+ */
+typedef enum {
+	VG_INCONSISTENT_ABORT    = 0, /* Abort operation */
+	VG_INCONSISTENT_CONTINUE = 1, /* Process operation but do not try repair */
+	VG_INCONSISTENT_REPAIR   = 2  /* Try to repair VG before processing */
+} inconsistent_t;
+
 struct cmd_context;
 struct format_handler;
 struct labeller;
diff --git a/test/t-inconsistent-metadata.sh b/test/t-inconsistent-metadata.sh
index 92e6f49..1c6f366 100644
--- a/test/t-inconsistent-metadata.sh
+++ b/test/t-inconsistent-metadata.sh
@@ -26,7 +26,7 @@ init() {
 	lvresize -L 8192K $vg/resized
 	restore_dev $dev1
 }
-	
+
 check() {
 	lvs -o lv_name,lv_size --units k $vg | tee lvs.out
 	grep resized lvs.out | grep 8192
@@ -43,20 +43,20 @@ check
 # vgdisplay doesn't change anything
 init
 vgdisplay 2>&1 | tee cmd.out
-grep "Volume group \"$vg\" inconsistent" cmd.out
+grep "Volume group $vg inconsistent" cmd.out
 vgdisplay 2>&1 | tee cmd.out
-grep "Volume group \"$vg\" inconsistent" cmd.out
+grep "Volume group $vg inconsistent" cmd.out
 
 # lvs fixes up
 init
 lvs 2>&1 | tee cmd.out
 grep "Inconsistent metadata found for VG $vg - updating" cmd.out
 vgdisplay 2>&1 | tee cmd.out
-not grep "Volume group \"$vg\" inconsistent" cmd.out
+not grep "Volume group $vg inconsistent" cmd.out
 check
 
 # vgs doesn't fix up... (why?)
 init
 vgs 2>&1 | tee cmd.out
 vgdisplay 2>&1 | tee cmd.out
-grep "Volume group \"$vg\" inconsistent" cmd.out
+grep "Volume group $vg inconsistent" cmd.out
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index d491970..1adb521 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -182,17 +182,6 @@ static int _poll_vg(struct cmd_context *cmd, const char *vgname,
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
 	if (!vg_check_status(vg, EXPORTED_VG))
 		return ECMD_FAILED;
 
@@ -218,7 +207,9 @@ static void _poll_for_all_vgs(struct cmd_context *cmd,
 {
 	while (1) {
 		parms->outstanding_count = 0;
-		process_each_vg(cmd, 0, NULL, LCK_VG_WRITE, 1, parms, _poll_vg);
+		/* FIXME Should we silently recover it here or not? */
+		process_each_vg(cmd, 0, NULL, LCK_VG_WRITE,
+				VG_INCONSISTENT_ABORT, parms, _poll_vg);
 		if (!parms->outstanding_count)
 			break;
 		sleep(parms->interval);
diff --git a/tools/reporter.c b/tools/reporter.c
index 28393f8..d50d586 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -20,11 +20,6 @@ static int _vgs_single(struct cmd_context *cmd __attribute((unused)),
 		       const char *vg_name, struct volume_group *vg,
 		       int consistent __attribute((unused)), void *handle)
 {
-	if (!vg) {
-		log_error("Volume group %s not found", vg_name);
-		return ECMD_FAILED;
-	}
-
 	if (!report_object(handle, vg, NULL, NULL, NULL, NULL))
 		return ECMD_FAILED;
 
@@ -184,11 +179,6 @@ static int _pvs_in_vg(struct cmd_context *cmd, const char *vg_name,
 		      int consistent __attribute((unused)),
 		      void *handle)
 {
-	if (!vg) {
-		log_error("Volume group %s not found", vg_name);
-		return ECMD_FAILED;
-	}
-
 	return process_each_pv_in_vg(cmd, vg, NULL, handle, &_pvs_single);
 }
 
@@ -197,11 +187,6 @@ static int _pvsegs_in_vg(struct cmd_context *cmd, const char *vg_name,
 			 int consistent __attribute((unused)),
 			 void *handle)
 {
-	if (!vg) {
-		log_error("Volume group %s not found", vg_name);
-		return ECMD_FAILED;
-	}
-
 	return process_each_pv_in_vg(cmd, vg, NULL, handle, &_pvsegs_single);
 }
 
@@ -382,7 +367,8 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 				    &_lvs_single);
 		break;
 	case VGS:
-		r = process_each_vg(cmd, argc, argv, LCK_VG_READ, 0,
+		r = process_each_vg(cmd, argc, argv, LCK_VG_READ,
+				    VG_INCONSISTENT_CONTINUE,
 				    report_handle, &_vgs_single);
 		break;
 	case LABEL:
@@ -394,7 +380,8 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 			r = process_each_pv(cmd, argc, argv, NULL, LCK_VG_READ,
 					    0, report_handle, &_pvs_single);
 		else
-			r = process_each_vg(cmd, argc, argv, LCK_VG_READ, 0,
+			r = process_each_vg(cmd, argc, argv, LCK_VG_READ,
+					    VG_INCONSISTENT_CONTINUE,
 					    report_handle, &_pvs_in_vg);
 		break;
 	case SEGS:
@@ -406,7 +393,8 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 			r = process_each_pv(cmd, argc, argv, NULL, LCK_VG_READ,
 					    0, report_handle, &_pvsegs_single);
 		else
-			r = process_each_vg(cmd, argc, argv, LCK_VG_READ, 0,
+			r = process_each_vg(cmd, argc, argv, LCK_VG_READ,
+					    VG_INCONSISTENT_CONTINUE,
 					    report_handle, &_pvsegs_in_vg);
 		break;
 	}
diff --git a/tools/toollib.c b/tools/toollib.c
index 7c9ff44..c8e1f61 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -449,7 +449,7 @@ int process_each_segment_in_lv(struct cmd_context *cmd,
 static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
 			   const char *vgid,
 			   struct dm_list *tags, struct dm_list *arg_vgnames,
-			   uint32_t lock_type, int consistent, void *handle,
+			   uint32_t lock_type, inconsistent_t repair_vg, void *handle,
 			   int ret_max,
 			   int (*process_single) (struct cmd_context * cmd,
 						  const char *vg_name,
@@ -457,6 +457,7 @@ static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
 						  int consistent, void *handle))
 {
 	struct volume_group *vg;
+	int consistent = 0;
 	int ret = 0;
 
 	if (!lock_vol(cmd, vg_name, lock_type)) {
@@ -472,31 +473,48 @@ static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
 	}
 
 	if (!vg_check_status(vg, CLUSTERED)) {
-		unlock_and_release_vg(cmd, vg, vg_name);
-		return ECMD_FAILED;
+		ret_max = ECMD_FAILED;
+		goto out;
 	}
 
 	if (!dm_list_empty(tags)) {
 		/* Only process if a tag matches or it's on arg_vgnames */
 		if (!str_list_match_item(arg_vgnames, vg_name) &&
-		    !str_list_match_list(tags, &vg->tags)) {
+		    !str_list_match_list(tags, &vg->tags))
+			goto out;
+	}
+
+	if (!consistent)
+		switch (repair_vg) {
+		case VG_INCONSISTENT_ABORT:
+			log_error("Volume group %s inconsistent - skipping", vg_name);
+			ret_max = ECMD_FAILED;
+			goto out;
+		case VG_INCONSISTENT_CONTINUE:
+			log_error("Volume group %s inconsistent", vg_name);
+			break;
+		case VG_INCONSISTENT_REPAIR:
 			unlock_and_release_vg(cmd, vg, vg_name);
-			return ret_max;
+			dev_close_all();
+			log_error("Volume group %s inconsistent", vg_name);
+			if (!(vg = recover_vg(cmd, vg_name, LCK_VG_WRITE)))
+				return ECMD_FAILED;
+			consistent = 1;
+			break;
 		}
-	}
 
 	if ((ret = process_single(cmd, vg_name, vg, consistent,
 				  handle)) > ret_max) {
 		ret_max = ret;
 	}
 
+out:
 	unlock_and_release_vg(cmd, vg, vg_name);
-
 	return ret_max;
 }
 
 int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
-		    uint32_t lock_type, int consistent, void *handle,
+		    uint32_t lock_type, inconsistent_t repair_vg, void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   const char *vg_name,
 					   struct volume_group * vg,
@@ -563,7 +581,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 				continue;
 			ret_max = _process_one_vg(cmd, vg_name, vgid, &tags,
 						  &arg_vgnames,
-					  	  lock_type, consistent, handle,
+					  	  lock_type, repair_vg, handle,
 					  	  ret_max, process_single);
 			if (sigint_caught())
 				return ret_max;
@@ -575,7 +593,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 				continue;	/* FIXME Unnecessary? */
 			ret_max = _process_one_vg(cmd, vg_name, NULL, &tags,
 						  &arg_vgnames,
-					  	  lock_type, consistent, handle,
+					  	  lock_type, repair_vg, handle,
 					  	  ret_max, process_single);
 			if (sigint_caught())
 				return ret_max;
diff --git a/tools/toollib.h b/tools/toollib.h
index 09c58f7..cc09796 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -27,7 +27,7 @@ struct volume_group *recover_vg(struct cmd_context *cmd, const char *vgname,
 				uint32_t lock_type);
 
 int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
-		    uint32_t lock_type, int consistent, void *handle,
+		    uint32_t lock_type, inconsistent_t repair_vg, void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   const char *vg_name,
 					   struct volume_group * vg,
diff --git a/tools/vgcfgbackup.c b/tools/vgcfgbackup.c
index 7a67e6a..2d77e65 100644
--- a/tools/vgcfgbackup.c
+++ b/tools/vgcfgbackup.c
@@ -54,14 +54,6 @@ static int vg_backup_single(struct cmd_context *cmd, const char *vg_name,
 	char **last_filename = (char **)handle;
 	char *filename;
 
-	if (!vg) {
-		log_error("Volume group \"%s\" not found", vg_name);
-		return ECMD_FAILED;
-	}
-
-	if (!consistent)
-		log_error("WARNING: Volume group \"%s\" inconsistent", vg_name);
-
 	if (arg_count(cmd, file_ARG)) {
 		if (!(filename = _expand_filename(arg_value(cmd, file_ARG),
 						  vg->name, last_filename))) {
@@ -98,8 +90,9 @@ int vgcfgbackup(struct cmd_context *cmd, int argc, char **argv)
 
 	init_pvmove(1);
 
-	ret = process_each_vg(cmd, argc, argv, LCK_VG_READ, 0, &last_filename,
-			      &vg_backup_single);
+	ret = process_each_vg(cmd, argc, argv, LCK_VG_READ,
+			      VG_INCONSISTENT_CONTINUE,
+			      &last_filename, &vg_backup_single);
 
 	dm_free(last_filename);
 
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 84cbf1a..9c5b05b 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -526,19 +526,6 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 {
 	int r = ECMD_FAILED;
 
-	if (!vg) {
-		log_error("Unable to find volume group \"%s\"", vg_name);
-		return ECMD_FAILED;
-	}
-
-	if (!consistent) {
-		unlock_and_release_vg(cmd, vg, vg_name);
-		dev_close_all();
-		log_error("Volume group \"%s\" inconsistent", vg_name);
-		if (!(vg = recover_vg(cmd, vg_name, LCK_VG_WRITE)))
-			return ECMD_FAILED;
-	}
-
 	if (!(vg_status(vg) & LVM_WRITE) && !arg_count(cmd, available_ARG)) {
 		log_error("Volume group \"%s\" is read-only", vg->name);
 		return ECMD_FAILED;
@@ -633,6 +620,7 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 
 	return process_each_vg(cmd, argc, argv,
 			       (arg_count(cmd, available_ARG)) ?
-			       LCK_VG_READ : LCK_VG_WRITE, 0, NULL,
+			       LCK_VG_READ : LCK_VG_WRITE,
+			       VG_INCONSISTENT_REPAIR, NULL,
 			       &vgchange_single);
 }
diff --git a/tools/vgck.c b/tools/vgck.c
index 9d5773c..977f447 100644
--- a/tools/vgck.c
+++ b/tools/vgck.c
@@ -21,16 +21,6 @@ static int vgck_single(struct cmd_context *cmd __attribute((unused)),
 		       struct volume_group *vg, int consistent,
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
 	if (!vg_check_status(vg, EXPORTED_VG))
 		return ECMD_FAILED;
 
@@ -42,6 +32,7 @@ static int vgck_single(struct cmd_context *cmd __attribute((unused)),
 
 int vgck(struct cmd_context *cmd, int argc, char **argv)
 {
-	return process_each_vg(cmd, argc, argv, LCK_VG_READ, 0, NULL,
+	return process_each_vg(cmd, argc, argv, LCK_VG_READ,
+			       VG_INCONSISTENT_ABORT, NULL,
 			       &vgck_single);
 }
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index b37cf49..ec5032e 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -32,19 +32,6 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 	struct lvinfo info;
 	int active = 0;
 
-	if (!vg) {
-		log_error("Unable to find volume group \"%s\"", vg_name);
-		return ECMD_FAILED;
-	}
-
-	if (!consistent) {
-		unlock_and_release_vg(cmd, vg, vg_name);
-		dev_close_all();
-		log_error("Volume group \"%s\" inconsistent", vg_name);
-		if (!(vg = recover_vg(cmd, vg_name, LCK_VG_WRITE)))
-			return ECMD_FAILED;
-	}
-
 	if (!vg_check_status(vg, LVM_WRITE | EXPORTED_VG))
 		return ECMD_FAILED;
 
@@ -233,6 +220,7 @@ int vgconvert(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_vg(cmd, argc, argv, LCK_VG_WRITE, 0, NULL,
+	return process_each_vg(cmd, argc, argv, LCK_VG_WRITE,
+			       VG_INCONSISTENT_REPAIR, NULL,
 			       &vgconvert_single);
 }
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index 02fdc19..de38d8b 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -20,13 +20,6 @@ static int vgdisplay_single(struct cmd_context *cmd, const char *vg_name,
 			    void *handle __attribute((unused)))
 {
 	/* FIXME Do the active check here if activevolumegroups_ARG ? */
-	if (!vg) {
-		log_error("Volume group \"%s\" doesn't exist", vg_name);
-		return ECMD_FAILED;
-	}
-
-	if (!consistent)
-		log_error("WARNING: Volume group \"%s\" inconsistent", vg_name);
 
 	vg_check_status(vg, EXPORTED_VG);
 
@@ -98,7 +91,8 @@ int vgdisplay(struct cmd_context *cmd, int argc, char **argv)
 	}
 **********/
 
-	return process_each_vg(cmd, argc, argv, LCK_VG_READ, 0, NULL,
+	return process_each_vg(cmd, argc, argv, LCK_VG_READ,
+			       VG_INCONSISTENT_CONTINUE, NULL,
 			       vgdisplay_single);
 
 /******** FIXME Need to count number processed
diff --git a/tools/vgexport.c b/tools/vgexport.c
index 9b0734c..fce7e9f 100644
--- a/tools/vgexport.c
+++ b/tools/vgexport.c
@@ -23,16 +23,6 @@ static int vgexport_single(struct cmd_context *cmd __attribute((unused)),
 	struct pv_list *pvl;
 	struct physical_volume *pv;
 
-	if (!vg) {
-		log_error("Unable to find volume group \"%s\"", vg_name);
-		goto error;
-	}
-
-	if (!consistent) {
-		log_error("Volume group %s inconsistent", vg_name);
-		goto error;
-	}
-
 	if (!vg_check_status(vg, EXPORTED_VG | LVM_WRITE)) {
 		goto error;
 	}
@@ -78,6 +68,7 @@ int vgexport(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	return process_each_vg(cmd, argc, argv, LCK_VG_WRITE, 1, NULL,
+	return process_each_vg(cmd, argc, argv, LCK_VG_WRITE,
+			       VG_INCONSISTENT_ABORT, NULL,
 			       &vgexport_single);
 }
diff --git a/tools/vgimport.c b/tools/vgimport.c
index 25ab035..2be2c2f 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -23,12 +23,6 @@ static int vgimport_single(struct cmd_context *cmd __attribute((unused)),
 	struct pv_list *pvl;
 	struct physical_volume *pv;
 
-	if (!vg || !consistent) {
-		log_error("Unable to find exported volume group \"%s\"",
-			  vg_name);
-		goto error;
-	}
-
 	if (!(vg_status(vg) & EXPORTED_VG)) {
 		log_error("Volume group \"%s\" is not exported", vg_name);
 		goto error;
@@ -74,6 +68,7 @@ int vgimport(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	return process_each_vg(cmd, argc, argv, LCK_VG_WRITE, 1, NULL,
+	return process_each_vg(cmd, argc, argv, LCK_VG_WRITE,
+			       VG_INCONSISTENT_ABORT, NULL,
 			       &vgimport_single);
 }
diff --git a/tools/vgremove.c b/tools/vgremove.c
index 38f9ee3..e5ad15d 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -40,8 +40,10 @@ int vgremove(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	ret = process_each_vg(cmd, argc, argv,
-			      LCK_VG_WRITE, 1,
+	ret = process_each_vg(cmd, argc, argv, LCK_VG_WRITE,
+			      arg_count(cmd, force_ARG) ?
+			      VG_INCONSISTENT_REPAIR :
+			      VG_INCONSISTENT_ABORT,
 			      NULL, &vgremove_single);
 
 	unlock_vg(cmd, VG_ORPHANS);
diff --git a/tools/vgscan.c b/tools/vgscan.c
index 3ac0d84..083cb5a 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -19,20 +19,6 @@ static int vgscan_single(struct cmd_context *cmd, const char *vg_name,
 			 struct volume_group *vg, int consistent,
 			 void *handle __attribute((unused)))
 {
-	if (!vg) {
-		log_error("Volume group \"%s\" not found", vg_name);
-		return ECMD_FAILED;
-	}
-
-	if (!consistent) {
-		unlock_and_release_vg(cmd, vg, vg_name);
-		dev_close_all();
-		log_error("Volume group \"%s\" inconsistent", vg_name);
-		/* Don't allow partial switch to this program */
-		if (!(vg = recover_vg(cmd, vg_name, LCK_VG_WRITE)))
-			return ECMD_FAILED;
-	}
-
 	log_print("Found %svolume group \"%s\" using metadata type %s",
 		  (vg_status(vg) & EXPORTED_VG) ? "exported " : "", vg_name,
 		  vg->fid->fmt->name);
@@ -61,7 +47,8 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 
 	log_print("Reading all physical volumes.  This may take a while...");
 
-	maxret = process_each_vg(cmd, argc, argv, LCK_VG_READ, 0, NULL,
+	maxret = process_each_vg(cmd, argc, argv, LCK_VG_READ,
+				 VG_INCONSISTENT_REPAIR, NULL,
 				 &vgscan_single);
 
 	if (arg_count(cmd, mknodes_ARG)) {



