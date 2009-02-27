From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Feb 2009 23:40:13 -0000
Subject: LVM2 ./VERSION ./WHATS_NEW lib/misc/lvm-exec.c ...
Message-ID: <20090227234013.31515.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-02-27 23:40:12

Modified files:
	.              : VERSION WHATS_NEW 
	lib/misc       : lvm-exec.c 
	tools          : lvresize.c 

Log message:
	fsadm cleanups & release prep

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.190&r2=1.191
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1056&r2=1.1057
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-exec.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.101&r2=1.102

--- LVM2/VERSION	2009/01/26 14:46:08	1.190
+++ LVM2/VERSION	2009/02/27 23:40:11	1.191
@@ -1 +1 @@
-2.02.45-cvs (2009-01-26)
+2.02.45-cvs (2009-02-26)
--- LVM2/WHATS_NEW	2009/02/25 23:29:06	1.1056
+++ LVM2/WHATS_NEW	2009/02/27 23:40:11	1.1057
@@ -1,5 +1,5 @@
-Version 2.02.45 - 
-===================================
+Version 2.02.45 - 26th February 2009
+====================================
   Do not scan devices if reporting only attributes from PV label.
   Use pkgconfig to obtain corosync library details during configuration.
   Fix error returns in clvmd-corosync interface to DLM.
--- LVM2/lib/misc/lvm-exec.c	2009/02/24 15:48:01	1.4
+++ LVM2/lib/misc/lvm-exec.c	2009/02/27 23:40:12	1.5
@@ -23,24 +23,18 @@
 /*
  * Create verbose string with list of parameters
  */
-static char *verbose_args(const char *const argv[])
+static char *_verbose_args(const char *const argv[], char *buf, size_t sz)
 {
-	char *buf = 0;
 	int pos = 0;
-	size_t sz = 0;
-	size_t len;
-	int i;
-
-	for (i = 0; argv[i] != NULL; i++) {
-		len = strlen(argv[i]);
-		if (pos + len >= sz) {
-			sz = 64 + (sz + len) * 2;
-			if (!(buf = realloc(buf, sz)))
-				break;
-		}
-		if (pos)
-			buf[pos++] = ' ';
-		memcpy(buf + pos, argv[i], len + 1); /* copy with '\0' */
+	int len;
+	unsigned i;
+
+	buf[0] = '\0';
+	for (i = 0; argv[i]; i++) {
+		if ((len = dm_snprintf(buf + pos, sz - pos,
+				       "%s ", argv[i])) < 0)
+			/* Truncated */
+			break;
 		pos += len;
 	}
 
@@ -54,10 +48,9 @@
 {
 	pid_t pid;
 	int status;
-	char *buf = 0;
+	char buf[PATH_MAX * 2];
 
-	log_verbose("Executing: %s", buf = verbose_args(argv));
-	free(buf);
+	log_verbose("Executing: %s", _verbose_args(argv, buf, sizeof(buf)));
 
 	if ((pid = fork()) == -1) {
 		log_error("fork failed: %s", strerror(errno));
@@ -67,7 +60,7 @@
 	if (!pid) {
 		/* Child */
 		/* FIXME Use execve directly */
-		execvp(argv[0], (char **const) argv); /* cast to match execvp prototype */
+		execvp(argv[0], (char **const) argv);
 		log_sys_error("execvp", argv[0]);
 		exit(errno);
 	}
--- LVM2/tools/lvresize.c	2009/02/24 15:48:00	1.101
+++ LVM2/tools/lvresize.c	2009/02/27 23:40:12	1.102
@@ -46,9 +46,9 @@
 	char **argv;
 };
 
-static int validate_stripesize(struct cmd_context *cmd,
-			       const struct volume_group *vg,
-			       struct lvresize_params *lp)
+static int _validate_stripesize(struct cmd_context *cmd,
+				const struct volume_group *vg,
+				struct lvresize_params *lp)
 {
 	if (arg_sign_value(cmd, stripesize_ARG, 0) == SIGN_MINUS) {
 		log_error("Stripesize may not be negative.");
@@ -85,10 +85,10 @@
 	return 1;
 }
 
-static int confirm_resizefs_reduce(struct cmd_context *cmd,
-				   const struct volume_group *vg,
-				   const struct logical_volume *lv,
-				   const struct lvresize_params *lp)
+static int _request_confirmation(struct cmd_context *cmd,
+				 const struct volume_group *vg,
+				 const struct logical_volume *lv,
+				 const struct lvresize_params *lp)
 {
 	struct lvinfo info;
 
@@ -99,55 +99,61 @@
 		return 0;
 	}
 
-	if (lp->resizefs && !info.exists) {
-		log_error("Logical volume %s must be activated "
-			  "before resizing filesystem", lp->lv_name);
-		return 0;
+	if (lp->resizefs) {
+		if (!info.exists) {
+			log_error("Logical volume %s must be activated "
+				  "before resizing filesystem", lp->lv_name);
+			return 0;
+		}
+		return 1;
 	}
 
-	if (info.exists && !lp->resizefs && (lp->resize == LV_REDUCE)) {
-		log_warn("WARNING: Reducing active%s logical volume "
-			 "to %s", info.open_count ? " and open" : "",
-			 display_size(cmd, (uint64_t) lp->extents *
-				      vg->extent_size));
-
-		log_warn("THIS MAY DESTROY YOUR DATA "
-			 "(filesystem etc.)");
-
-		if (!arg_count(cmd, force_ARG)) {
-			if (yes_no_prompt("Do you really want to "
-					  "reduce %s? [y/n]: ",
-					  lp->lv_name) == 'n') {
-				log_print("Logical volume %s NOT "
-					  "reduced", lp->lv_name);
-				return 0;
-			}
-			if (sigint_caught())
-				return 0;
+	if (!info.exists)
+		return 1;
+
+	log_warn("WARNING: Reducing active%s logical volume to %s",
+		 info.open_count ? " and open" : "",
+		 display_size(cmd, (uint64_t) lp->extents * vg->extent_size));
+
+	log_warn("THIS MAY DESTROY YOUR DATA (filesystem etc.)");
+
+	if (!arg_count(cmd, force_ARG)) {
+		if (yes_no_prompt("Do you really want to reduce %s? [y/n]: ",
+				  lp->lv_name) == 'n') {
+			log_print("Logical volume %s NOT reduced", lp->lv_name);
+			return 0;
 		}
+		if (sigint_caught())
+			return 0;
 	}
 
 	return 1;
 }
 
 enum fsadm_cmd_e { FSADM_CMD_CHECK, FSADM_CMD_RESIZE };
+#define FSADM_CMD "fsadm"
+#define FSADM_CMD_MAX_ARGS 6
 
-static int fsadm_cmd(const struct cmd_context *cmd,
-		     const struct volume_group *vg,
-		     const struct lvresize_params *lp,
-		     enum fsadm_cmd_e fcmd)
+/*
+ * FSADM_CMD --dry-run --verbose --force check lv_path
+ * FSADM_CMD --dry-run --verbose --force resize lv_path size
+ */
+static int _fsadm_cmd(const struct cmd_context *cmd,
+		      const struct volume_group *vg,
+		      const struct lvresize_params *lp,
+		      enum fsadm_cmd_e fcmd)
 {
 	char lv_path[PATH_MAX];
 	char size_buf[SIZE_BUF];
-	const char *argv[10];
-	int i = 0;
+	const char *argv[FSADM_CMD_MAX_ARGS + 2];
+	unsigned i = 0;
 
-	argv[i++] = "fsadm"; /* FIXME: se configurable FSADM_CMD */
+	argv[i++] = FSADM_CMD;
 
 	if (test_mode())
 		argv[i++] = "--dry-run";
 
-	if (verbose_level() > _LOG_WARN)
+	if (verbose_level() >= _LOG_NOTICE)
 		argv[i++] = "--verbose";
 
 	if (arg_count(cmd, force_ARG))
@@ -155,10 +161,9 @@
 
 	argv[i++] = (fcmd == FSADM_CMD_RESIZE) ? "resize" : "check";
 
-	if (dm_snprintf(lv_path, PATH_MAX, "%s%s/%s", cmd->dev_dir,
-			lp->vg_name, lp->lv_name) < 0) {
-		log_error("Couldn't create LV path for %s",
-			  lp->lv_name);
+	if (dm_snprintf(lv_path, PATH_MAX, "%s%s/%s", cmd->dev_dir, lp->vg_name,
+			lp->lv_name) < 0) {
+		log_error("Couldn't create LV path for %s", lp->lv_name);
 		return 0;
 	}
 
@@ -312,10 +317,9 @@
 		}
 	}
 
-	if (arg_count(cmd, stripesize_ARG)) {
-		if (!validate_stripesize(cmd, vg, lp))
-			return EINVALID_CMD_LINE;
-	}
+	if (arg_count(cmd, stripesize_ARG) &&
+	    !_validate_stripesize(cmd, vg, lp))
+		return EINVALID_CMD_LINE;
 
 	lv = lvl->lv;
 
@@ -420,8 +424,8 @@
 			sz = seg->stripe_size;
 			str = seg->area_count;
 
-			if ((seg_stripesize && seg_stripesize != sz
-			     && !lp->stripe_size) ||
+			if ((seg_stripesize && seg_stripesize != sz &&
+			     !lp->stripe_size) ||
 			    (seg_stripes && seg_stripes != str && !lp->stripes)) {
 				log_error("Please specify number of "
 					  "stripes (-i) and stripesize (-I)");
@@ -568,24 +572,25 @@
 		}
 	}
 
-	if (lp->resize == LV_REDUCE) {
-		if (lp->argc)
-			log_warn("Ignoring PVs on command line when reducing");
-	}
+	if ((lp->resize == LV_REDUCE) && lp->argc)
+		log_warn("Ignoring PVs on command line when reducing");
 
-	if ((lp->resizefs || (lp->resize == LV_REDUCE))
-	    && !confirm_resizefs_reduce(cmd, vg, lv, lp)) /* ensure active LV */
-		return ECMD_FAILED;
+	/* Request confirmation before operations that are often mistakes. */
+	if ((lp->resizefs || (lp->resize == LV_REDUCE)) &&
+	    !_request_confirmation(cmd, vg, lv, lp)) {
+		stack;
+		// return ECMD_FAILED;
+	}
 
 	if (lp->resizefs) {
-		if (!lp->nofsck
-		    && !fsadm_cmd(cmd, vg, lp, FSADM_CMD_CHECK)) {
+		if (!lp->nofsck &&
+		    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_CHECK)) {
 			stack;
 			return ECMD_FAILED;
 		}
 
-		if ((lp->resize == LV_REDUCE)
-		    && !fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE)) {
+		if ((lp->resize == LV_REDUCE) &&
+		    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE)) {
 			stack;
 			return ECMD_FAILED;
 		}
@@ -606,8 +611,8 @@
 			stack;
 			return ECMD_FAILED;
 		}
-	} else if ((lp->extents > lv->le_count) /* check we really do extend */
-		   && !lv_extend(lv, lp->segtype, lp->stripes,
+	} else if ((lp->extents > lv->le_count) && /* Ensure we extend */
+		   !lv_extend(lv, lp->segtype, lp->stripes,
 			      lp->stripe_size, lp->mirrors,
 			      lp->extents - lv->le_count,
 			      NULL, 0u, 0u, pvh, alloc)) {
@@ -648,8 +653,8 @@
 
 	log_print("Logical volume %s successfully resized", lp->lv_name);
 
-	if (lp->resizefs && (lp->resize == LV_EXTEND)
-	    && !fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE)) {
+	if (lp->resizefs && (lp->resize == LV_EXTEND) &&
+	    !_fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE)) {
 		stack;
 		return ECMD_FAILED;
 	}


