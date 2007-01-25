From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Jan 2007 14:37:50 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20070125143750.28040.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-25 14:37:48

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	lib/commands   : toolcontext.c 
	lib/config     : config.c 
	lib/device     : dev-io.c 
	lib/filters    : filter-persistent.c filter-sysfs.c filter.c 
	lib/format_text: archive.c format-text.c 
	lib/locking    : file_locking.c 
	lib/log        : log.c 
	lib/misc       : lvm-file.c 
	tools          : lvmcmdline.c reporter.c 

Log message:
	Add some missing close() and fclose() return code checks.
	Fix exit statuses of reporting tools (2.02.19).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.557&r2=1.558
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-sysfs.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archive.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-file.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/WHATS_NEW	2007/01/24 23:44:43	1.557
+++ LVM2/WHATS_NEW	2007/01/25 14:37:46	1.558
@@ -1,5 +1,7 @@
 Version 2.02.20 -
 ===================================
+  Add some missing close() and fclose() return code checks.
+  Fix exit statuses of reporting tools (2.02.19).
   Add init script for dmeventd monitoring.
   lvm.static no longer interacts with dmeventd unless explicitly asked to.
   Add field definitions to report help text.
--- LVM2/daemons/clvmd/lvm-functions.c	2007/01/23 15:58:05	1.27
+++ LVM2/daemons/clvmd/lvm-functions.c	2007/01/25 14:37:47	1.28
@@ -473,7 +473,8 @@
 		sync_unlock(vg, LCK_EXCL);
 
 	}
-	fclose(vgs);
+	if (fclose(vgs))
+		DEBUGLOG("vgs fclose failed: %s\n", strerror(errno));
 }
 
 /*
@@ -523,7 +524,8 @@
 			}
 		}
 	}
-	fclose(lvs);
+	if (fclose(lvs))
+		DEBUGLOG("lvs fclose failed: %s\n", strerror(errno));
 	return NULL;
 }
 
--- LVM2/lib/commands/toolcontext.c	2007/01/23 16:03:54	1.45
+++ LVM2/lib/commands/toolcontext.c	2007/01/25 14:37:47	1.46
@@ -59,8 +59,6 @@
 #  include <malloc.h>
 #endif
 
-static FILE *_log;
-
 static int _get_env_vars(struct cmd_context *cmd)
 {
 	const char *e;
@@ -1114,8 +1112,4 @@
 	activation_exit();
 	fin_log();
 	fin_syslog();
-
-	if (_log)
-		fclose(_log);
-
 }
--- LVM2/lib/config/config.c	2007/01/17 16:22:59	1.52
+++ LVM2/lib/config/config.c	2007/01/25 14:37:47	1.53
@@ -435,13 +435,13 @@
 	log_verbose("Dumping configuration to %s", file);
 	if (!argc) {
 		if (!_write_config(cft->root, 0, fp, 0)) {
-			log_error("Failure while writing configuration");
+			log_error("Failure while writing to %s", file);
 			r = 0;
 		}
 	} else while (argc--) {
 		if ((cn = find_config_node(cft->root, *argv))) {
 			if (!_write_config(cn, 1, fp, 0)) {
-				log_error("Failure while writing configuration");
+				log_error("Failure while writing to %s", file);
 				r = 0;
 			}
 		} else {
@@ -451,8 +451,10 @@
 		argv++;
 	}
 
-	if (fp != stdout)
-		fclose(fp);
+	if ((fp != stdout) && fclose(fp)) {
+		log_sys_error("fclose", file);
+		r = 0;
+	}
 
 	return r;
 }
--- LVM2/lib/device/dev-io.c	2006/11/30 23:11:40	1.55
+++ LVM2/lib/device/dev-io.c	2007/01/25 14:37:47	1.56
@@ -292,11 +292,14 @@
 
 	if (ioctl(fd, BLKSSZGET, &s) < 0) {
 		log_sys_error("ioctl BLKSSZGET", name);
-		close(fd);
+		if (close(fd))
+			log_sys_error("close", name);
 		return 0;
 	}
 
-	close(fd);
+	if (close(fd))
+		log_sys_error("close", name);
+
 	*size = (uint32_t) s;
 
 	log_very_verbose("%s: sector size is %" PRIu32 " bytes", name, *size);
--- LVM2/lib/filters/filter-persistent.c	2006/11/04 03:34:09	1.28
+++ LVM2/lib/filters/filter-persistent.c	2007/01/25 14:37:47	1.29
@@ -239,7 +239,10 @@
 	/* _write_array(pf, fp, "invalid_devices", PF_BAD_DEVICE); */
 
 	fprintf(fp, "}\n");
-	fclose(fp);
+	if (fclose(fp)) {
+		log_sys_error("fclose", tmp_file);
+		goto out;
+	}
 
 	if (rename(tmp_file, pf->file))
 		log_error("%s: rename to %s failed: %s", tmp_file, pf->file,
--- LVM2/lib/filters/filter-sysfs.c	2006/08/21 12:54:52	1.13
+++ LVM2/lib/filters/filter-sysfs.c	2007/01/25 14:37:47	1.14
@@ -54,7 +54,9 @@
 		}
 	}
 
-	fclose(fp);
+	if (fclose(fp))
+		log_sys_error("fclose", proc_mounts);
+
 	return r;
 }
 
@@ -156,7 +158,9 @@
 	}
 
 	r = _parse_dev(file, fp, result);
-	fclose(fp);
+
+	if (fclose(fp))
+		log_sys_error("fclose", file);
 
 	return r;
 }
--- LVM2/lib/filters/filter.c	2006/08/21 12:54:52	1.36
+++ LVM2/lib/filters/filter.c	2007/01/25 14:37:47	1.37
@@ -204,7 +204,8 @@
 			if (cv->type != CFG_STRING) {
 				log_error("Expecting string in devices/types "
 					  "in config file");
-				fclose(pd);
+				if (fclose(pd))
+					log_sys_error("fclose", proc_devices);
 				return 0;
 			}
 			dev_len = strlen(cv->v.str);
@@ -214,14 +215,16 @@
 				log_error("Max partition count missing for %s "
 					  "in devices/types in config file",
 					  name);
-				fclose(pd);
+				if (fclose(pd))
+					log_sys_error("fclose", proc_devices);
 				return 0;
 			}
 			if (!cv->v.i) {
 				log_error("Zero partition count invalid for "
 					  "%s in devices/types in config file",
 					  name);
-				fclose(pd);
+				if (fclose(pd))
+					log_sys_error("fclose", proc_devices);
 				return 0;
 			}
 			if (dev_len <= strlen(line + i) &&
@@ -232,7 +235,10 @@
 			}
 		}
 	}
-	fclose(pd);
+
+	if (fclose(pd))
+		log_sys_error("fclose", proc_devices);
+
 	return 1;
 }
 
--- LVM2/lib/format_text/archive.c	2006/08/21 12:54:52	1.24
+++ LVM2/lib/format_text/archive.c	2007/01/25 14:37:48	1.25
@@ -249,17 +249,23 @@
 
 	if (!(fp = fdopen(fd, "w"))) {
 		log_err("Couldn't create FILE object for archive.");
-		close(fd);
+		if (close(fd))
+			log_sys_error("close", temp_file);
 		return 0;
 	}
 
 	if (!text_vg_export_file(vg, desc, fp)) {
 		stack;
-		fclose(fp);
+		if (fclose(fp))
+			log_sys_error("fclose", temp_file);
 		return 0;
 	}
 
-	fclose(fp);
+	if (fclose(fp)) {
+		log_sys_error("fclose", temp_file);
+		/* Leave file behind as evidence of failure */
+		return 0;
+	}
 
 	/*
 	 * Now we want to rename this file to <vg>_index.vg.
--- LVM2/lib/format_text/format-text.c	2007/01/09 21:12:41	1.71
+++ LVM2/lib/format_text/format-text.c	2007/01/25 14:37:48	1.72
@@ -710,7 +710,8 @@
 
 	if (!(fp = fdopen(fd, "w"))) {
 		log_sys_error("fdopen", temp_file);
-		close(fd);
+		if (close(fd))
+			log_sys_error("fclose", temp_file);
 		return 0;
 	}
 
@@ -718,13 +719,15 @@
 
 	if (!text_vg_export_file(vg, tc->desc, fp)) {
 		log_error("Failed to write metadata to %s.", temp_file);
-		fclose(fp);
+		if (fclose(fp))
+			log_sys_error("fclose", temp_file);
 		return 0;
 	}
 
 	if (fsync(fd) && (errno != EROFS) && (errno != EINVAL)) {
 		log_sys_error("fsync", tc->path_edit);
-		fclose(fp);
+		if (fclose(fp))
+			log_sys_error("fclose", tc->path_edit);
 		return 0;
 	}
 
--- LVM2/lib/locking/file_locking.c	2006/08/21 12:54:52	1.25
+++ LVM2/lib/locking/file_locking.c	2007/01/25 14:37:48	1.26
@@ -163,8 +163,8 @@
 	log_very_verbose("Locking %s %c%c", ll->res, state,
 			 flags & LCK_NONBLOCK ? ' ' : 'B');
 	do {
-		if (ll->lf > -1)
-			close(ll->lf);
+		if ((ll->lf > -1) && close(ll->lf))
+			log_sys_error("close", file);
 
 		if ((ll->lf = open(file, O_CREAT | O_APPEND | O_RDWR, 0777))
 		    < 0) {
--- LVM2/lib/log/log.c	2007/01/19 22:21:45	1.36
+++ LVM2/lib/log/log.c	2007/01/25 14:37:48	1.37
@@ -120,7 +120,8 @@
 	}
 
 	if (_log_to_file) {
-		fclose(_log_file);
+		if (fclose(_log_file))
+			fprintf(stderr, "fclose() on log file failed: %s", strerror(errno));
 		_log_to_file = 0;
 	}
 }
--- LVM2/lib/misc/lvm-file.c	2006/11/04 03:34:10	1.17
+++ LVM2/lib/misc/lvm-file.c	2007/01/25 14:37:48	1.18
@@ -66,7 +66,8 @@
 		if (!fcntl(*fd, F_SETLK, &lock))
 			return 1;
 
-		close(*fd);
+		if (close(*fd))
+			log_sys_error("close", buffer);
 	}
 
 	return 0;
@@ -239,7 +240,8 @@
 	if (fsync(fd) && (errno != EROFS) && (errno != EINVAL))
 		log_sys_error("fsync", dir);
 
-	close(fd);
+	if (close(fd))
+		log_sys_error("close", dir);
 
       out:
 	dm_free(dir);
--- LVM2/tools/lvmcmdline.c	2007/01/23 15:58:06	1.39
+++ LVM2/tools/lvmcmdline.c	2007/01/25 14:37:48	1.40
@@ -1065,8 +1065,9 @@
 	char buffer[CMD_LEN];
 	int ret = 0;
 	int magic_number = 0;
+	char *script_file = argv[0];
 
-	if ((script = fopen(argv[0], "r")) == NULL)
+	if ((script = fopen(script_file, "r")) == NULL)
 		return ENO_SUCH_CMD;
 
 	while (fgets(buffer, sizeof(buffer), script) != NULL) {
@@ -1099,7 +1100,9 @@
 		lvm_run_command(cmd, argc, argv);
 	}
 
-	fclose(script);
+	if (fclose(script))
+		log_sys_error("fclose", script_file);
+
 	return ret;
 }
 
--- LVM2/tools/reporter.c	2007/01/16 18:06:12	1.17
+++ LVM2/tools/reporter.c	2007/01/25 14:37:48	1.18
@@ -25,7 +25,7 @@
 		return ECMD_FAILED;
 	}
 
-	if (!report_object(handle, vg, NULL, NULL, NULL, NULL));
+	if (!report_object(handle, vg, NULL, NULL, NULL, NULL))
 		return ECMD_FAILED;
 
 	check_current_backup(vg);
@@ -39,7 +39,7 @@
 	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
 
-	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL));
+	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL))
 		return ECMD_FAILED;
 
 	return ECMD_PROCESSED;
@@ -48,7 +48,7 @@
 static int _segs_single(struct cmd_context *cmd __attribute((unused)),
 			struct lv_segment *seg, void *handle)
 {
-	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL));
+	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL))
 		return ECMD_FAILED;
 
 	return ECMD_PROCESSED;
@@ -78,7 +78,7 @@
 		goto out;
 	}
 
-	if (!report_object(handle, vg, NULL, pv, NULL, pvseg));
+	if (!report_object(handle, vg, NULL, pv, NULL, pvseg))
 		ret = ECMD_FAILED;
 
 out:
@@ -128,7 +128,7 @@
 		}
 	}
 
-	if (!report_object(handle, vg, NULL, pv, NULL, NULL));
+	if (!report_object(handle, vg, NULL, pv, NULL, NULL))
 		ret = ECMD_FAILED;
 
 out:


