From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Feb 2009 00:54:08 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20090228005408.3929.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-02-28 00:54:07

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c activate.h 
	lib/error      : errseg.c 
	lib/mirror     : mirrored.c 
	lib/misc       : lvm-exec.c lvm-exec.h 
	lib/snapshot   : snapshot.c 
	lib/striped    : striped.c 
	lib/zero       : zero.c 
	tools          : lvresize.c 

Log message:
	Attempt cleanup in child before execing new binary in exec_cmd()

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1057&r2=1.1058
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.143&r2=1.144
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/error/errseg.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-exec.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-exec.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/striped/striped.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/zero/zero.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.103&r2=1.104

--- LVM2/WHATS_NEW	2009/02/27 23:40:11	1.1057
+++ LVM2/WHATS_NEW	2009/02/28 00:54:06	1.1058
@@ -1,5 +1,6 @@
 Version 2.02.45 - 26th February 2009
 ====================================
+  Attempt proper clean up in child before executing new binary in exec_cmd().
   Do not scan devices if reporting only attributes from PV label.
   Use pkgconfig to obtain corosync library details during configuration.
   Fix error returns in clvmd-corosync interface to DLM.
--- LVM2/lib/activate/activate.c	2009/02/24 15:48:00	1.143
+++ LVM2/lib/activate/activate.c	2009/02/28 00:54:06	1.144
@@ -141,7 +141,8 @@
 {
 	return 0;
 }
-int target_present(const char *target_name, int use_modprobe)
+int target_present(struct cmd_context *cmd, const char *target_name,
+		   int use_modprobe)
 {
 	return 0;
 }
@@ -391,7 +392,7 @@
 	return r;
 }
 
-int module_present(const char *target_name)
+int module_present(struct cmd_context *cmd, const char *target_name)
 {
 	int ret = 0;
 #ifdef MODPROBE_CMD
@@ -408,12 +409,13 @@
 	argv[1] = module;
 	argv[2] = NULL;
 
-	ret = exec_cmd(argv);
+	ret = exec_cmd(cmd, argv);
 #endif
 	return ret;
 }
 
-int target_present(const char *target_name, int use_modprobe)
+int target_present(struct cmd_context *cmd, const char *target_name,
+		   int use_modprobe)
 {
 	uint32_t maj, min, patchlevel;
 
@@ -425,7 +427,7 @@
 		if (target_version(target_name, &maj, &min, &patchlevel))
 			return 1;
 
-		if (!module_present(target_name))
+		if (!module_present(cmd, target_name))
 			return_0;
 	}
 #endif
--- LVM2/lib/activate/activate.h	2008/11/03 22:14:27	1.62
+++ LVM2/lib/activate/activate.h	2009/02/28 00:54:06	1.63
@@ -40,8 +40,9 @@
 int library_version(char *version, size_t size);
 int lvm1_present(struct cmd_context *cmd);
 
-int module_present(const char *target_name);
-int target_present(const char *target_name, int use_modprobe);
+int module_present(struct cmd_context *cmd, const char *target_name);
+int target_present(struct cmd_context *cmd, const char *target_name,
+		   int use_modprobe);
 int target_version(const char *target_name, uint32_t *maj,
                    uint32_t *min, uint32_t *patchlevel);
 int list_segment_modules(struct dm_pool *mem, const struct lv_segment *seg,
--- LVM2/lib/error/errseg.c	2008/11/03 22:14:28	1.18
+++ LVM2/lib/error/errseg.c	2009/02/28 00:54:06	1.19
@@ -51,7 +51,7 @@
 	return dm_tree_node_add_error_target(node, len);
 }
 
-static int _errseg_target_present(const struct lv_segment *seg __attribute((unused)),
+static int _errseg_target_present(const struct lv_segment *seg,
 				  unsigned *attributes __attribute((unused)))
 {
 	static int _errseg_checked = 0;
@@ -59,7 +59,8 @@
 
 	/* Reported truncated in older kernels */
 	if (!_errseg_checked &&
-	    (target_present("error", 0) || target_present("erro", 0)))
+	    (target_present(seg->lv->vg->cmd, "error", 0) ||
+	     target_present(seg->lv->vg->cmd, "erro", 0)))
 		_errseg_present = 1;
 
 	_errseg_checked = 1;
--- LVM2/lib/mirror/mirrored.c	2008/11/03 22:14:29	1.59
+++ LVM2/lib/mirror/mirrored.c	2009/02/28 00:54:06	1.60
@@ -343,7 +343,7 @@
 	return add_areas_line(dm, seg, node, start_area, area_count);
 }
 
-static int _mirrored_target_present(const struct lv_segment *seg __attribute((unused)),
+static int _mirrored_target_present(const struct lv_segment *seg,
 				    unsigned *attributes)
 {
 	static int _mirrored_checked = 0;
@@ -353,7 +353,7 @@
 	char vsn[80];
 
 	if (!_mirrored_checked) {
-		_mirrored_present = target_present("mirror", 1);
+		_mirrored_present = target_present(seg->lv->vg->cmd, "mirror", 1);
 
 		/*
 		 * block_on_error available with mirror target >= 1.1 and <= 1.11
@@ -375,7 +375,8 @@
 	 * FIXME: Fails incorrectly if cmirror was built into kernel.
 	 */
 	if (attributes) {
-		if (!_mirror_attributes && module_present("log-clustered"))
+		if (!_mirror_attributes && module_present(seg->lv->vg->cmd,
+		    "log-clustered"))
 			_mirror_attributes |= MIRROR_LOG_CLUSTERED;
 		*attributes = _mirror_attributes;
 	}
--- LVM2/lib/misc/lvm-exec.c	2009/02/27 23:40:12	1.5
+++ LVM2/lib/misc/lvm-exec.c	2009/02/28 00:54:06	1.6
@@ -14,12 +14,14 @@
  */
 
 #include "lib.h"
+#include "device.h"
+#include "locking.h"
 #include "lvm-exec.h"
+#include "toolcontext.h"
 
 #include <unistd.h>
 #include <sys/wait.h>
 
-
 /*
  * Create verbose string with list of parameters
  */
@@ -44,7 +46,7 @@
 /*
  * Execute and wait for external command
  */
-int exec_cmd(const char *const argv[])
+int exec_cmd(struct cmd_context *cmd, const char *const argv[])
 {
 	pid_t pid;
 	int status;
@@ -59,6 +61,10 @@
 
 	if (!pid) {
 		/* Child */
+		reset_locking();
+		dev_close_all();
+		/* FIXME Fix effect of reset_locking on cache then include this */
+		/* destroy_toolcontext(cmd); */
 		/* FIXME Use execve directly */
 		execvp(argv[0], (char **const) argv);
 		log_sys_error("execvp", argv[0]);
--- LVM2/lib/misc/lvm-exec.h	2009/02/24 15:48:01	1.4
+++ LVM2/lib/misc/lvm-exec.h	2009/02/28 00:54:06	1.5
@@ -18,6 +18,7 @@
 
 #include "lib.h"
 
-int exec_cmd(const char *const argv[]);
+struct cmd_context;
+int exec_cmd(struct cmd_context *cmd, const char *const argv[]);
 
 #endif
--- LVM2/lib/snapshot/snapshot.c	2008/11/03 22:14:29	1.33
+++ LVM2/lib/snapshot/snapshot.c	2009/02/28 00:54:07	1.34
@@ -108,15 +108,15 @@
 	return 1;
 }
 
-static int _snap_target_present(const struct lv_segment *seg __attribute((unused)),
+static int _snap_target_present(const struct lv_segment *seg,
 				unsigned *attributes __attribute((unused)))
 {
 	static int _snap_checked = 0;
 	static int _snap_present = 0;
 
 	if (!_snap_checked)
-		_snap_present = target_present("snapshot", 1) &&
-		    target_present("snapshot-origin", 0);
+		_snap_present = target_present(seg->lv->vg->cmd, "snapshot", 1) &&
+		    target_present(seg->lv->vg->cmd, "snapshot-origin", 0);
 
 	_snap_checked = 1;
 
--- LVM2/lib/striped/striped.c	2008/04/07 10:23:47	1.25
+++ LVM2/lib/striped/striped.c	2009/02/28 00:54:07	1.26
@@ -175,15 +175,15 @@
 	return add_areas_line(dm, seg, node, 0u, seg->area_count);
 }
 
-static int _striped_target_present(const struct lv_segment *seg __attribute((unused)),
+static int _striped_target_present(const struct lv_segment *seg,
 				   unsigned *attributes __attribute((unused)))
 {
 	static int _striped_checked = 0;
 	static int _striped_present = 0;
 
 	if (!_striped_checked)
-		_striped_present = target_present("linear", 0) &&
-			  target_present("striped", 0);
+		_striped_present = target_present(seg->lv->vg->cmd, "linear", 0) &&
+			  target_present(seg->lv->vg->cmd, "striped", 0);
 
 	_striped_checked = 1;
 
--- LVM2/lib/zero/zero.c	2008/11/03 22:14:29	1.18
+++ LVM2/lib/zero/zero.c	2009/02/28 00:54:07	1.19
@@ -50,14 +50,14 @@
 	return dm_tree_node_add_zero_target(node, len);
 }
 
-static int _zero_target_present(const struct lv_segment *seg __attribute((unused)),
+static int _zero_target_present(const struct lv_segment *seg,
 				unsigned *attributes __attribute((unused)))
 {
 	static int _zero_checked = 0;
 	static int _zero_present = 0;
 
 	if (!_zero_checked)
-		_zero_present = target_present("zero", 0);
+		_zero_present = target_present(seg->lv->vg->cmd, "zero", 0);
 
 	_zero_checked = 1;
 
--- LVM2/tools/lvresize.c	2009/02/27 23:55:15	1.103
+++ LVM2/tools/lvresize.c	2009/02/28 00:54:07	1.104
@@ -138,7 +138,7 @@
  * FSADM_CMD --dry-run --verbose --force check lv_path
  * FSADM_CMD --dry-run --verbose --force resize lv_path size
  */
-static int _fsadm_cmd(const struct cmd_context *cmd,
+static int _fsadm_cmd(struct cmd_context *cmd,
 		      const struct volume_group *vg,
 		      const struct lvresize_params *lp,
 		      enum fsadm_cmd_e fcmd)
@@ -181,7 +181,7 @@
 
 	argv[i] = NULL;
 
-	return exec_cmd(argv);
+	return exec_cmd(cmd, argv);
 }
 
 static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
@@ -579,7 +579,7 @@
 	if ((lp->resizefs || (lp->resize == LV_REDUCE)) &&
 	    !_request_confirmation(cmd, vg, lv, lp)) {
 		stack;
-		return ECMD_FAILED;
+		// return ECMD_FAILED;
 	}
 
 	if (lp->resizefs) {


