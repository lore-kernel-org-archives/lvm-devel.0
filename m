From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Feb 2009 15:48:02 -0000
Subject: LVM2 tools/lvresize.c lib/activate/activate.c ...
Message-ID: <20090224154802.16906.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2009-02-24 15:48:01

Modified files:
	tools          : lvresize.c 
	lib/activate   : activate.c 
	lib/misc       : lvm-exec.c lvm-exec.h 
	scripts        : fsadm.sh 
	.              : WHATS_NEW 

Log message:
	Fixed bug where lvresize option -t was not properly passed to fsadm.
	Using argv[] list in exec_cmd() to allow more params for external commands.
	Fsadm does not allow checking mounted filesystem.
	Fsadm no longer accepts 'any other key' as 'no' answer to y/n.
	Fsadm improved handling of command line options.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.100&r2=1.101
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.142&r2=1.143
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-exec.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-exec.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1051&r2=1.1052

--- LVM2/tools/lvresize.c	2009/01/15 14:44:49	1.100
+++ LVM2/tools/lvresize.c	2009/02/24 15:48:00	1.101
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -130,12 +130,30 @@
 	return 1;
 }
 
-static int do_resizefs_reduce(const struct cmd_context *cmd,
-			      const struct volume_group *vg,
-			      const struct lvresize_params *lp)
+enum fsadm_cmd_e { FSADM_CMD_CHECK, FSADM_CMD_RESIZE };
+
+static int fsadm_cmd(const struct cmd_context *cmd,
+		     const struct volume_group *vg,
+		     const struct lvresize_params *lp,
+		     enum fsadm_cmd_e fcmd)
 {
 	char lv_path[PATH_MAX];
 	char size_buf[SIZE_BUF];
+	const char *argv[10];
+	int i = 0;
+
+	argv[i++] = "fsadm"; /* FIXME: se configurable FSADM_CMD */
+
+	if (test_mode())
+		argv[i++] = "--dry-run";
+
+	if (verbose_level() > _LOG_WARN)
+		argv[i++] = "--verbose";
+
+	if (arg_count(cmd, force_ARG))
+		argv[i++] = "--force";
+
+	argv[i++] = (fcmd == FSADM_CMD_RESIZE) ? "resize" : "check";
 
 	if (dm_snprintf(lv_path, PATH_MAX, "%s%s/%s", cmd->dev_dir,
 			lp->vg_name, lp->lv_name) < 0) {
@@ -144,21 +162,21 @@
 		return 0;
 	}
 
-	if (dm_snprintf(size_buf, SIZE_BUF, "%" PRIu64 "K",
-			(uint64_t) lp->extents * vg->extent_size / 2) < 0) {
-		log_error("Couldn't generate new LV size string");
-		return 0;
-	}
+	argv[i++] = lv_path;
 
-	if (!lp->nofsck)
-		if (!exec_cmd("fsadm", "check", lv_path, NULL))
-			return_0;
+	if (fcmd == FSADM_CMD_RESIZE) {
+		if (dm_snprintf(size_buf, SIZE_BUF, "%" PRIu64 "K",
+				(uint64_t) lp->extents * vg->extent_size / 2) < 0) {
+			log_error("Couldn't generate new LV size string");
+			return 0;
+		}
 
-	if (lp->resize == LV_REDUCE)
-		if (!exec_cmd("fsadm", "resize", lv_path, size_buf))
-			return_0;
+		argv[i++] = size_buf;
+	}
 
-	return 1;
+	argv[i] = NULL;
+
+	return exec_cmd(argv);
 }
 
 static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
@@ -268,8 +286,6 @@
 	uint32_t seg_extents;
 	uint32_t sz, str;
 	struct dm_list *pvh = NULL;
-	char size_buf[SIZE_BUF];
-	char lv_path[PATH_MAX];
 
 	/* does LV exist? */
 	if (!(lvl = find_lv_in_vg(vg, lp->lv_name))) {
@@ -373,9 +389,12 @@
 	}
 
 	if (lp->extents == lv->le_count) {
-		log_error("New size (%d extents) matches existing size "
-			  "(%d extents)", lp->extents, lv->le_count);
-		return EINVALID_CMD_LINE;
+		if (!lp->resizefs) {
+			log_error("New size (%d extents) matches existing size "
+				  "(%d extents)", lp->extents, lv->le_count);
+			return EINVALID_CMD_LINE;
+		}
+		lp->resize = LV_EXTEND; /* lets pretend zero size extension */
 	}
 
 	seg_size = lp->extents - lv->le_count;
@@ -509,30 +528,22 @@
 		}
 	}
 
-	if (lp->extents == lv->le_count) {
-		log_error("New size (%d extents) matches existing size "
-			  "(%d extents)", lp->extents, lv->le_count);
-		return EINVALID_CMD_LINE;
-	}
-
 	if (lp->extents < lv->le_count) {
 		if (lp->resize == LV_EXTEND) {
 			log_error("New size given (%d extents) not larger "
 				  "than existing size (%d extents)",
 				  lp->extents, lv->le_count);
 			return EINVALID_CMD_LINE;
-		} else
-			lp->resize = LV_REDUCE;
-	}
-
-	if (lp->extents > lv->le_count) {
+		}
+		lp->resize = LV_REDUCE;
+	} else if (lp->extents > lv->le_count) {
 		if (lp->resize == LV_REDUCE) {
 			log_error("New size given (%d extents) not less than "
 				  "existing size (%d extents)", lp->extents,
 				  lv->le_count);
 			return EINVALID_CMD_LINE;
-		} else
-			lp->resize = LV_EXTEND;
+		}
+		lp->resize = LV_EXTEND;
 	}
 
 	if (lp->mirrors && activation() &&
@@ -562,14 +573,22 @@
 			log_warn("Ignoring PVs on command line when reducing");
 	}
 
-	if (lp->resize == LV_REDUCE || lp->resizefs) {
-		if (!confirm_resizefs_reduce(cmd, vg, lv, lp))
-			return ECMD_FAILED;
-	}
+	if ((lp->resizefs || (lp->resize == LV_REDUCE))
+	    && !confirm_resizefs_reduce(cmd, vg, lv, lp)) /* ensure active LV */
+		return ECMD_FAILED;
 
 	if (lp->resizefs) {
-		if (!do_resizefs_reduce(cmd, vg, lp))
-		    return ECMD_FAILED;
+		if (!lp->nofsck
+		    && !fsadm_cmd(cmd, vg, lp, FSADM_CMD_CHECK)) {
+			stack;
+			return ECMD_FAILED;
+		}
+
+		if ((lp->resize == LV_REDUCE)
+		    && !fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE)) {
+			stack;
+			return ECMD_FAILED;
+		}
 	}
 
 	if (!archive(vg)) {
@@ -587,7 +606,8 @@
 			stack;
 			return ECMD_FAILED;
 		}
-	} else if (!lv_extend(lv, lp->segtype, lp->stripes,
+	} else if ((lp->extents > lv->le_count) /* check we really do extend */
+		   && !lv_extend(lv, lp->segtype, lp->stripes,
 			      lp->stripe_size, lp->mirrors,
 			      lp->extents - lv->le_count,
 			      NULL, 0u, 0u, pvh, alloc)) {
@@ -628,22 +648,10 @@
 
 	log_print("Logical volume %s successfully resized", lp->lv_name);
 
-	if (lp->resizefs && (lp->resize == LV_EXTEND)) {
-		if (dm_snprintf(lv_path, PATH_MAX, "%s%s/%s", cmd->dev_dir,
-				lp->vg_name, lp->lv_name) < 0) {
-			log_error("Couldn't create LV path for %s",
-				  lp->lv_name);
-			return ECMD_FAILED;
-		}
-		if (dm_snprintf(size_buf, SIZE_BUF, "%" PRIu64 "K",
-				(uint64_t) lp->extents * vg->extent_size / 2) < 0) {
-		    log_error("Couldn't generate new LV size string");
-		    return ECMD_FAILED;
-		}
-		if (!exec_cmd("fsadm", "resize", lv_path, size_buf)) {
-			stack;
-			return ECMD_FAILED;
-		}
+	if (lp->resizefs && (lp->resize == LV_EXTEND)
+	    && !fsadm_cmd(cmd, vg, lp, FSADM_CMD_RESIZE)) {
+		stack;
+		return ECMD_FAILED;
 	}
 
 	return ECMD_PROCESSED;
--- LVM2/lib/activate/activate.c	2008/12/19 14:22:48	1.142
+++ LVM2/lib/activate/activate.c	2009/02/24 15:48:00	1.143
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -396,6 +396,7 @@
 	int ret = 0;
 #ifdef MODPROBE_CMD
 	char module[128];
+	const char *argv[3];
 
 	if (dm_snprintf(module, sizeof(module), "dm-%s", target_name) < 0) {
 		log_error("module_present module name too long: %s",
@@ -403,7 +404,11 @@
 		return 0;
 	}
 
-	ret = exec_cmd(MODPROBE_CMD, module, "", "");
+	argv[0] = MODPROBE_CMD;
+	argv[1] = module;
+	argv[2] = NULL;
+
+	ret = exec_cmd(argv);
 #endif
 	return ret;
 }
--- LVM2/lib/misc/lvm-exec.c	2008/01/30 14:00:00	1.3
+++ LVM2/lib/misc/lvm-exec.c	2009/02/24 15:48:01	1.4
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -19,16 +19,45 @@
 #include <unistd.h>
 #include <sys/wait.h>
 
+
+/*
+ * Create verbose string with list of parameters
+ */
+static char *verbose_args(const char *const argv[])
+{
+	char *buf = 0;
+	int pos = 0;
+	size_t sz = 0;
+	size_t len;
+	int i;
+
+	for (i = 0; argv[i] != NULL; i++) {
+		len = strlen(argv[i]);
+		if (pos + len >= sz) {
+			sz = 64 + (sz + len) * 2;
+			if (!(buf = realloc(buf, sz)))
+				break;
+		}
+		if (pos)
+			buf[pos++] = ' ';
+		memcpy(buf + pos, argv[i], len + 1); /* copy with '\0' */
+		pos += len;
+	}
+
+	return buf;
+}
+
 /*
  * Execute and wait for external command
  */
-int exec_cmd(const char *command, const char *fscmd, const char *lv_path,
-	     const char *size)
+int exec_cmd(const char *const argv[])
 {
 	pid_t pid;
 	int status;
+	char *buf = 0;
 
-	log_verbose("Executing: %s %s %s %s", command, fscmd, lv_path, size);
+	log_verbose("Executing: %s", buf = verbose_args(argv));
+	free(buf);
 
 	if ((pid = fork()) == -1) {
 		log_error("fork failed: %s", strerror(errno));
@@ -38,8 +67,8 @@
 	if (!pid) {
 		/* Child */
 		/* FIXME Use execve directly */
-		execlp(command, command, fscmd, lv_path, size, NULL);
-		log_sys_error("execlp", command);
+		execvp(argv[0], (char **const) argv); /* cast to match execvp prototype */
+		log_sys_error("execvp", argv[0]);
 		exit(errno);
 	}
 
@@ -56,7 +85,7 @@
 	}
 
 	if (WEXITSTATUS(status)) {
-		log_error("%s failed: %u", command, WEXITSTATUS(status));
+		log_error("%s failed: %u", argv[0], WEXITSTATUS(status));
 		return 0;
 	}
 
--- LVM2/lib/misc/lvm-exec.h	2007/08/20 20:55:27	1.3
+++ LVM2/lib/misc/lvm-exec.h	2009/02/24 15:48:01	1.4
@@ -18,6 +18,6 @@
 
 #include "lib.h"
 
-int exec_cmd(const char *command, const char *fscmd, const char *lv_path,
-	     const char *size);
+int exec_cmd(const char *const argv[]);
+
 #endif
--- LVM2/scripts/fsadm.sh	2009/02/06 14:28:06	1.9
+++ LVM2/scripts/fsadm.sh	2009/02/24 15:48:01	1.10
@@ -1,6 +1,6 @@
 #!/bin/sh
 #
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2009 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -176,8 +176,8 @@
 # get the full size of device in bytes
 detect_device_size() {
 	# check if blockdev supports getsize64
-	$BLOCKDEV 2>&1 | $GREP getsize64 >/dev/null 
-	if test $? -eq 0; then 
+	$BLOCKDEV 2>&1 | $GREP getsize64 >/dev/null
+	if test $? -eq 0; then
 		DEVSIZE=$($BLOCKDEV --getsize64 "$VOLUME") || error "Cannot read size of device \"$VOLUME\""
 	else
 		DEVSIZE=$($BLOCKDEV --getsize "$VOLUME") || error "Cannot read size of device \"$VOLUME\""
@@ -206,21 +206,22 @@
 
 yes_no() {
 	echo -n "$@? [Y|n] "
+
 	if [ -n "$YES" ]; then
-		ANS="y"; echo -n $ANS
-	else
-		read -n 1 ANS
+		echo y ; return 0
 	fi
-	test -n "$ANS" && echo
-	case "$ANS" in
-	  "y" | "Y" | "" ) return 0 ;;
-	esac
-	return 1
+
+	while read -r -s -n 1 ANS ; do
+		case "$ANS" in
+		 "y" | "Y" | "") echo y ; return 0 ;;
+		 "n" | "N") echo n ; return 1 ;;
+		esac
+	done
 }
 
 try_umount() {
 	yes_no "Do you want to unmount \"$MOUNTED\"" && dry $UMOUNT "$MOUNTED" && return 0
-	error "Cannot proceed test with mounted filesystem \"$MOUNTED\""
+	error "Can not proceed with mounted filesystem \"$MOUNTED\""
 }
 
 validate_parsing() {
@@ -250,7 +251,7 @@
 		FSFORCE="-f"
 	fi
 
-	verbose "Resizing \"$VOLUME\" $BLOCKCOUNT -> $NEWBLOCKCOUNT blocks ($NEWSIZE bytes, bs:$BLOCKSIZE)"
+	verbose "Resizing filesystem on device \"$VOLUME\" to $NEWSIZE bytes ($BLOCKCOUNT -> $NEWBLOCKCOUNT blocks of $BLOCKSIZE bytes)"
 	dry $RESIZE_EXT $FSFORCE "$VOLUME" $NEWBLOCKCOUNT
 }
 
@@ -260,12 +261,8 @@
 # - unmounted for downsize
 #############################
 resize_reiser() {
-	detect_mounted
-	if [ -n "$MOUNTED" ]; then
-		verbose "ReiserFS resizes only unmounted filesystem"
-		try_umount
-		REMOUNT=$MOUNTED
-	fi
+	detect_mounted && verbose "ReiserFS resizes only unmounted filesystem" && try_umount
+	REMOUNT=$MOUNTED
 	verbose "Parsing $TUNE_REISER \"$VOLUME\""
 	for i in $($TUNE_REISER "$VOLUME"); do
 		case "$i" in
@@ -322,7 +319,7 @@
 	NEWSIZE=$2
 	detect_fs "$1"
 	detect_device_size
-	verbose "Device \"$VOLUME\" has $DEVSIZE bytes"
+	verbose "Device \"$VOLUME\" size is $DEVSIZE bytes"
 	# if the size parameter is missing use device size
 	#if [ -n "$NEWSIZE" -a $NEWSIZE <
 	test -z "$NEWSIZE" && NEWSIZE=${DEVSIZE}b
@@ -343,6 +340,7 @@
 ###################
 check() {
 	detect_fs "$1"
+	detect_mounted && error "Can not fsck device \"$VOLUME\", filesystem mounted on $MOUNTED"
 	case "$FSTYPE" in
 	  "xfs") dry $XFS_CHECK "$VOLUME" ;;
 	  *) dry $FSCK $YES "$VOLUME" ;;
@@ -370,23 +368,24 @@
 $(echo Y | $GREP Y >/dev/null) || error "Grep does not work properly"
 
 
-if [ "$1" = "" ] ; then
+if [ "$#" -eq 0 ] ; then
 	tool_usage
 fi
 
-while [ "$1" != "" ]
+while [ "$#" -ne 0 ]
 do
-	case "$1" in
-	 "-h"|"--help") tool_usage ;;
-	 "-v"|"--verbose") VERB="-v" ;;
-	 "-n"|"--dry-run") DRY=1 ;;
-	 "-f"|"--force") FORCE="-f" ;;
-	 "-e"|"--ext-offline") EXTOFF=1 ;;
-	 "-y"|"--yes") YES="-y" ;;
-	 "-l"|"--lvresize") DO_LVRESIZE=1 ;;
-	 "check") shift; CHECK=$1 ;;
-	 "resize") shift; RESIZE=$1; shift; NEWSIZE=$1 ;;
-	 *) error "Wrong argument \"$1\". (see: $TOOL --help)"
+	 case "$1" in
+	  "") ;;
+	  "-h"|"--help") tool_usage ;;
+	  "-v"|"--verbose") VERB="-v" ;;
+	  "-n"|"--dry-run") DRY=1 ;;
+	  "-f"|"--force") FORCE="-f" ;;
+	  "-e"|"--ext-offline") EXTOFF=1 ;;
+	  "-y"|"--yes") YES="-y" ;;
+	  "-l"|"--lvresize") DO_LVRESIZE=1 ;;
+	  "check") CHECK="$2" ; shift ;;
+	  "resize") RESIZE="$2"; NEWSIZE="$3" ; shift 2 ;;
+	  *) error "Wrong argument \"$1\". (see: $TOOL --help)"
 	esac
 	shift
 done
--- LVM2/WHATS_NEW	2009/02/24 13:03:45	1.1051
+++ LVM2/WHATS_NEW	2009/02/24 15:48:01	1.1052
@@ -1,5 +1,10 @@
 Version 2.02.45 - 
 ===================================
+  Fixed bug where lvresize option -t was not properly passed to fsadm.
+  Using argv[] list in exec_cmd() to allow more params for external commands.
+  Fsadm does not allow checking mounted filesystem.
+  Fsadm no longer accepts 'any other key' as 'no' answer to y/n.
+  Fsadm improved handling of command line options.
   Add lib/lvm.h and lib/lvm_base.c for the new library interface.
   Move tools/version.h to lib/misc/lvm-version.h.
   Split LVM_VERSION into MAJOR, MINOR, PATCHLEVEL, RELEASE and RELEASE_DATE.


