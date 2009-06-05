From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 5 Jun 2009 20:00:54 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20090605200054.15348.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-06-05 20:00:53

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h 
	test           : t-inconsistent-metadata.sh 
	tools          : polldaemon.c reporter.c toollib.c toollib.h 
	                 vgcfgbackup.c vgchange.c vgck.c vgconvert.c 
	                 vgdisplay.c vgexport.c vgimport.c vgremove.c 
	                 vgscan.c 

Log message:
	Fix double releasing of vg when repairing of vg is requested.
	
	Several commands calls process_each_vg() and in provided
	callback it explicitly recovers VG if inconsistent.
	(vgchange, vgconvert, vgscan)
	
	It means that old VG is released and reread  but the function
	above (process_one_vg) tries to unlock and release old VG.
	
	Patch moves the repair logic into _process_one_vg() function.
	
	It always tries to read vg (even inconsistent) and then decides
	what to do according new defined parameter.
	
	Also patch unifies inconsistent error messages.
	
	The only slight change if for vgremove command, where
	it now tries to repair VG before it removes if force arg is given.
	(It works similar way before, just the order of operation changed).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1141&r2=1.1142
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.75&r2=1.76
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-inconsistent-metadata.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.155&r2=1.156
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcfgbackup.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgck.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgdisplay.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgexport.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgimport.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgremove.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgscan.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/WHATS_NEW	2009/06/04 12:01:15	1.1141
+++ LVM2/WHATS_NEW	2009/06/05 20:00:52	1.1142
@@ -1,5 +1,9 @@
 Version 2.02.48 - 
 ===============================
+  Try to repair vg before actual vgremove when force flag provided.
+  Fix possible double release of VG after recovery.
+  Add parameter to process_each_vg specifying what to do with inconsistent VG.
+  Unify error messages when procesing inconsistent volume group.
   Use lvconvert --repair instead of vgreduce in mirror dmeventd DSO.
   Introduce lvconvert --use_policies (repair policy according to lvm.conf).
   Fix clvmd-corosync to match new corosync API.
--- LVM2/lib/metadata/metadata-exported.h	2009/06/01 14:43:28	1.75
+++ LVM2/lib/metadata/metadata-exported.h	2009/06/05 20:00:52	1.76
@@ -153,6 +153,16 @@
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
--- LVM2/test/t-inconsistent-metadata.sh	2009/01/09 10:16:57	1.1
+++ LVM2/test/t-inconsistent-metadata.sh	2009/06/05 20:00:52	1.2
@@ -26,7 +26,7 @@
 	lvresize -L 8192K $vg/resized
 	restore_dev $dev1
 }
-	
+
 check() {
 	lvs -o lv_name,lv_size --units k $vg | tee lvs.out
 	grep resized lvs.out | grep 8192
@@ -43,20 +43,20 @@
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
--- LVM2/tools/polldaemon.c	2009/06/01 14:43:28	1.14
+++ LVM2/tools/polldaemon.c	2009/06/05 20:00:52	1.15
@@ -182,17 +182,6 @@
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
 
@@ -218,7 +207,9 @@
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
--- LVM2/tools/reporter.c	2009/05/13 21:27:44	1.48
+++ LVM2/tools/reporter.c	2009/06/05 20:00:52	1.49
@@ -20,11 +20,6 @@
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
 
@@ -184,11 +179,6 @@
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
 
@@ -197,11 +187,6 @@
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
 
@@ -382,7 +367,8 @@
 				    &_lvs_single);
 		break;
 	case VGS:
-		r = process_each_vg(cmd, argc, argv, LCK_VG_READ, 0,
+		r = process_each_vg(cmd, argc, argv, LCK_VG_READ,
+				    VG_INCONSISTENT_CONTINUE,
 				    report_handle, &_vgs_single);
 		break;
 	case LABEL:
@@ -394,7 +380,8 @@
 			r = process_each_pv(cmd, argc, argv, NULL, LCK_VG_READ,
 					    0, report_handle, &_pvs_single);
 		else
-			r = process_each_vg(cmd, argc, argv, LCK_VG_READ, 0,
+			r = process_each_vg(cmd, argc, argv, LCK_VG_READ,
+					    VG_INCONSISTENT_CONTINUE,
 					    report_handle, &_pvs_in_vg);
 		break;
 	case SEGS:
@@ -406,7 +393,8 @@
 			r = process_each_pv(cmd, argc, argv, NULL, LCK_VG_READ,
 					    0, report_handle, &_pvsegs_single);
 		else
-			r = process_each_vg(cmd, argc, argv, LCK_VG_READ, 0,
+			r = process_each_vg(cmd, argc, argv, LCK_VG_READ,
+					    VG_INCONSISTENT_CONTINUE,
 					    report_handle, &_pvsegs_in_vg);
 		break;
 	}
--- LVM2/tools/toollib.c	2009/05/27 18:19:21	1.155
+++ LVM2/tools/toollib.c	2009/06/05 20:00:52	1.156
@@ -449,7 +449,7 @@
 static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
 			   const char *vgid,
 			   struct dm_list *tags, struct dm_list *arg_vgnames,
-			   uint32_t lock_type, int consistent, void *handle,
+			   uint32_t lock_type, inconsistent_t repair_vg, void *handle,
 			   int ret_max,
 			   int (*process_single) (struct cmd_context * cmd,
 						  const char *vg_name,
@@ -457,6 +457,7 @@
 						  int consistent, void *handle))
 {
 	struct volume_group *vg;
+	int consistent = 0;
 	int ret = 0;
 
 	if (!lock_vol(cmd, vg_name, lock_type)) {
@@ -472,31 +473,48 @@
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
@@ -563,7 +581,7 @@
 				continue;
 			ret_max = _process_one_vg(cmd, vg_name, vgid, &tags,
 						  &arg_vgnames,
-					  	  lock_type, consistent, handle,
+					  	  lock_type, repair_vg, handle,
 					  	  ret_max, process_single);
 			if (sigint_caught())
 				return ret_max;
@@ -575,7 +593,7 @@
 				continue;	/* FIXME Unnecessary? */
 			ret_max = _process_one_vg(cmd, vg_name, NULL, &tags,
 						  &arg_vgnames,
-					  	  lock_type, consistent, handle,
+					  	  lock_type, repair_vg, handle,
 					  	  ret_max, process_single);
 			if (sigint_caught())
 				return ret_max;
--- LVM2/tools/toollib.h	2009/02/09 09:45:49	1.61
+++ LVM2/tools/toollib.h	2009/06/05 20:00:52	1.62
@@ -27,7 +27,7 @@
 				uint32_t lock_type);
 
 int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
-		    uint32_t lock_type, int consistent, void *handle,
+		    uint32_t lock_type, inconsistent_t repair_vg, void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   const char *vg_name,
 					   struct volume_group * vg,
--- LVM2/tools/vgcfgbackup.c	2008/09/19 06:42:00	1.26
+++ LVM2/tools/vgcfgbackup.c	2009/06/05 20:00:52	1.27
@@ -54,14 +54,6 @@
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
@@ -98,8 +90,9 @@
 
 	init_pvmove(1);
 
-	ret = process_each_vg(cmd, argc, argv, LCK_VG_READ, 0, &last_filename,
-			      &vg_backup_single);
+	ret = process_each_vg(cmd, argc, argv, LCK_VG_READ,
+			      VG_INCONSISTENT_CONTINUE,
+			      &last_filename, &vg_backup_single);
 
 	dm_free(last_filename);
 
--- LVM2/tools/vgchange.c	2009/05/21 03:04:53	1.72
+++ LVM2/tools/vgchange.c	2009/06/05 20:00:52	1.73
@@ -526,19 +526,6 @@
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
@@ -633,6 +620,7 @@
 
 	return process_each_vg(cmd, argc, argv,
 			       (arg_count(cmd, available_ARG)) ?
-			       LCK_VG_READ : LCK_VG_WRITE, 0, NULL,
+			       LCK_VG_READ : LCK_VG_WRITE,
+			       VG_INCONSISTENT_REPAIR, NULL,
 			       &vgchange_single);
 }
--- LVM2/tools/vgck.c	2009/03/16 15:19:29	1.20
+++ LVM2/tools/vgck.c	2009/06/05 20:00:52	1.21
@@ -21,16 +21,6 @@
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
 
@@ -42,6 +32,7 @@
 
 int vgck(struct cmd_context *cmd, int argc, char **argv)
 {
-	return process_each_vg(cmd, argc, argv, LCK_VG_READ, 0, NULL,
+	return process_each_vg(cmd, argc, argv, LCK_VG_READ,
+			       VG_INCONSISTENT_ABORT, NULL,
 			       &vgck_single);
 }
--- LVM2/tools/vgconvert.c	2009/05/21 03:04:53	1.34
+++ LVM2/tools/vgconvert.c	2009/06/05 20:00:52	1.35
@@ -32,19 +32,6 @@
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
 
@@ -233,6 +220,7 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_vg(cmd, argc, argv, LCK_VG_WRITE, 0, NULL,
+	return process_each_vg(cmd, argc, argv, LCK_VG_WRITE,
+			       VG_INCONSISTENT_REPAIR, NULL,
 			       &vgconvert_single);
 }
--- LVM2/tools/vgdisplay.c	2008/11/07 19:02:47	1.22
+++ LVM2/tools/vgdisplay.c	2009/06/05 20:00:52	1.23
@@ -20,13 +20,6 @@
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
 
@@ -98,7 +91,8 @@
 	}
 **********/
 
-	return process_each_vg(cmd, argc, argv, LCK_VG_READ, 0, NULL,
+	return process_each_vg(cmd, argc, argv, LCK_VG_READ,
+			       VG_INCONSISTENT_CONTINUE, NULL,
 			       vgdisplay_single);
 
 /******** FIXME Need to count number processed
--- LVM2/tools/vgexport.c	2008/11/03 22:14:30	1.19
+++ LVM2/tools/vgexport.c	2009/06/05 20:00:52	1.20
@@ -23,16 +23,6 @@
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
@@ -78,6 +68,7 @@
 		return ECMD_FAILED;
 	}
 
-	return process_each_vg(cmd, argc, argv, LCK_VG_WRITE, 1, NULL,
+	return process_each_vg(cmd, argc, argv, LCK_VG_WRITE,
+			       VG_INCONSISTENT_ABORT, NULL,
 			       &vgexport_single);
 }
--- LVM2/tools/vgimport.c	2008/11/03 22:14:30	1.18
+++ LVM2/tools/vgimport.c	2009/06/05 20:00:52	1.19
@@ -23,12 +23,6 @@
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
@@ -74,6 +68,7 @@
 		return ECMD_FAILED;
 	}
 
-	return process_each_vg(cmd, argc, argv, LCK_VG_WRITE, 1, NULL,
+	return process_each_vg(cmd, argc, argv, LCK_VG_WRITE,
+			       VG_INCONSISTENT_ABORT, NULL,
 			       &vgimport_single);
 }
--- LVM2/tools/vgremove.c	2009/05/13 13:02:56	1.47
+++ LVM2/tools/vgremove.c	2009/06/05 20:00:52	1.48
@@ -40,8 +40,10 @@
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
--- LVM2/tools/vgscan.c	2009/05/21 03:04:54	1.32
+++ LVM2/tools/vgscan.c	2009/06/05 20:00:52	1.33
@@ -19,20 +19,6 @@
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
@@ -61,7 +47,8 @@
 
 	log_print("Reading all physical volumes.  This may take a while...");
 
-	maxret = process_each_vg(cmd, argc, argv, LCK_VG_READ, 0, NULL,
+	maxret = process_each_vg(cmd, argc, argv, LCK_VG_READ,
+				 VG_INCONSISTENT_REPAIR, NULL,
 				 &vgscan_single);
 
 	if (arg_count(cmd, mknodes_ARG)) {


