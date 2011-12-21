From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Dec 2011 13:08:16 -0000
Subject: LVM2 ./configure ./configure.in daemons/dmeven ...
Message-ID: <20111221130816.28879.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-12-21 13:08:14

Modified files:
	.              : configure configure.in 
	daemons/dmeventd/plugins: Makefile.in 
	doc            : example.conf.in 
	lib/activate   : activate.c 
	lib/config     : defaults.h 
	lib/thin       : thin.c 
Added files:
	daemons/dmeventd/plugins/thin: Makefile.in dmeventd_thin.c 

Log message:
	Thin add dmeventd support
	
	This is basic version with still few unresolved issue mainly in case,
	when the pool resize is failing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.162&r2=1.163
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.177&r2=1.178
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/Makefile.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/thin/Makefile.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/thin/dmeventd_thin.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.224&r2=1.225
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.90&r2=1.91
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37

--- LVM2/configure	2011/12/11 17:24:37	1.162
+++ LVM2/configure	2011/12/21 13:08:11	1.163
@@ -10231,7 +10231,7 @@
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/common/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts!
 /Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/common/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_mon!
 itoring_systemd_red_hat.service scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -10933,6 +10933,7 @@
     "daemons/dmeventd/plugins/raid/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/raid/Makefile" ;;
     "daemons/dmeventd/plugins/mirror/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/mirror/Makefile" ;;
     "daemons/dmeventd/plugins/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/snapshot/Makefile" ;;
+    "daemons/dmeventd/plugins/thin/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/thin/Makefile" ;;
     "daemons/lvmetad/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmetad/Makefile" ;;
     "doc/Makefile") CONFIG_FILES="$CONFIG_FILES doc/Makefile" ;;
     "doc/example.conf") CONFIG_FILES="$CONFIG_FILES doc/example.conf" ;;
--- LVM2/configure.in	2011/12/11 15:15:57	1.177
+++ LVM2/configure.in	2011/12/21 13:08:12	1.178
@@ -1419,6 +1419,7 @@
 daemons/dmeventd/plugins/raid/Makefile
 daemons/dmeventd/plugins/mirror/Makefile
 daemons/dmeventd/plugins/snapshot/Makefile
+daemons/dmeventd/plugins/thin/Makefile
 daemons/lvmetad/Makefile
 doc/Makefile
 doc/example.conf
--- LVM2/daemons/dmeventd/plugins/Makefile.in	2011/08/11 19:18:18	1.10
+++ LVM2/daemons/dmeventd/plugins/Makefile.in	2011/12/21 13:08:12	1.11
@@ -30,8 +30,12 @@
   SUBDIRS += raid
 endif
 
+ifneq ("@THIN@", "none")
+  SUBDIRS += thin
+endif
+
 ifeq ($(MAKECMDGOALS),distclean)
-  SUBDIRS = lvm2 mirror snapshot raid
+  SUBDIRS = lvm2 mirror snapshot raid thin
 endif
 
 include $(top_builddir)/make.tmpl
@@ -39,3 +43,4 @@
 snapshot: lvm2
 mirror: lvm2
 raid: lvm2
+thin: lvm2
/cvs/lvm2/LVM2/daemons/dmeventd/plugins/thin/Makefile.in,v  -->  standard output
revision 1.1
--- LVM2/daemons/dmeventd/plugins/thin/Makefile.in
+++ -	2011-12-21 13:08:14.930465000 +0000
@@ -0,0 +1,36 @@
+#
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+srcdir = @srcdir@
+top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
+
+INCLUDES += -I$(top_srcdir)/tools -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
+CLDFLAGS += -L$(top_builddir)/tools -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
+
+SOURCES = dmeventd_thin.c
+
+LIB_NAME = libdevmapper-event-lvm2thin
+LIB_SHARED = $(LIB_NAME).$(LIB_SUFFIX)
+LIB_VERSION = $(LIB_VERSION_LVM)
+
+CFLOW_LIST = $(SOURCES)
+CFLOW_LIST_TARGET = $(LIB_NAME).cflow
+
+include $(top_builddir)/make.tmpl
+
+LIBS += -ldevmapper-event-lvm2 -ldevmapper
+
+install_lvm2: install_dm_plugin
+
+install: install_lvm2
/cvs/lvm2/LVM2/daemons/dmeventd/plugins/thin/dmeventd_thin.c,v  -->  standard output
revision 1.1
--- LVM2/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ -	2011-12-21 13:08:15.044517000 +0000
@@ -0,0 +1,285 @@
+/*
+ * Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "lib.h"
+
+#include "lvm2cmd.h"
+#include "errors.h"
+#include "libdevmapper-event.h"
+#include "dmeventd_lvm.h"
+
+#include "lvm-string.h"
+
+#include <sys/wait.h>
+#include <syslog.h> /* FIXME Replace syslog with multilog */
+/* FIXME Missing openlog? */
+
+/* First warning when thin is 80% full. */
+#define WARNING_THRESH 80
+/* Run a check every 5%. */
+#define CHECK_STEP 5
+/* Do not bother checking thins less than 50% full. */
+#define CHECK_MINIMUM 50
+
+#define UMOUNT_COMMAND "/bin/umount"
+
+#define THIN_DEBUG 0
+
+struct dso_state {
+	struct dm_pool *mem;
+	int meta_percent_check;
+	int data_percent_check;
+	uint64_t known_meta_size;
+	uint64_t known_data_size;
+	char *vg, *lv, *layer;
+	char cmd_str[1024];
+};
+
+static int _extend(struct dso_state *state)
+{
+#if THIN_DEBUG
+	syslog(LOG_INFO, "dmeventd executes: %s.", state->cmd_str);
+#endif
+	return (dmeventd_lvm2_run(state->cmd_str) == ECMD_PROCESSED);
+}
+
+#if 0
+static int _run(const char *cmd, ...)
+{
+        va_list ap;
+        int argc = 1; /* for argv[0], i.e. cmd */
+        int i = 0;
+        const char **argv;
+        pid_t pid = fork();
+        int status;
+
+        if (pid == 0) { /* child */
+                va_start(ap, cmd);
+                while (va_arg(ap, const char *))
+                        ++argc;
+                va_end(ap);
+
+                /* + 1 for the terminating NULL */
+                argv = alloca(sizeof(const char *) * (argc + 1));
+
+                argv[0] = cmd;
+                va_start(ap, cmd);
+                while ((argv[++i] = va_arg(ap, const char *)));
+                va_end(ap);
+
+                execvp(cmd, (char **)argv);
+                syslog(LOG_ERR, "Failed to execute %s: %s.\n", cmd, strerror(errno));
+                exit(127);
+        }
+
+        if (pid > 0) { /* parent */
+                if (waitpid(pid, &status, 0) != pid)
+                        return 0; /* waitpid failed */
+                if (!WIFEXITED(status) || WEXITSTATUS(status))
+                        return 0; /* the child failed */
+        }
+
+        if (pid < 0)
+                return 0; /* fork failed */
+
+        return 1; /* all good */
+}
+
+/* FIXME: all thin pool users needs to be here */
+static void _umount(const char *device, int major, int minor)
+{
+	FILE *mounts;
+	char buffer[4096];
+	char *words[3];
+	struct stat st;
+
+	if (!(mounts = fopen("/proc/mounts", "r"))) {
+		syslog(LOG_ERR, "Could not read /proc/mounts. Not umounting %s.\n", device);
+		return;
+	}
+
+	while (!feof(mounts)) {
+		/* read a line of /proc/mounts */
+		if (!fgets(buffer, sizeof(buffer), mounts))
+			break; /* eof, likely */
+
+		/* words[0] is the mount point and words[1] is the device path */
+		dm_split_words(buffer, 3, 0, words);
+
+		/* find the major/minor of the device */
+		if (stat(words[0], &st))
+			continue; /* can't stat, skip this one */
+
+		if (S_ISBLK(st.st_mode) &&
+		    (int) major(st.st_rdev) == major &&
+		    (int) minor(st.st_rdev) == minor) {
+			syslog(LOG_ERR, "Unmounting invalid thin %s from %s.\n", device, words[1]);
+			if (!_run(UMOUNT_COMMAND, "-fl", words[1], NULL))
+				syslog(LOG_ERR, "Failed to umount thin %s from %s: %s.\n",
+				       device, words[1], strerror(errno));
+		}
+	}
+
+	if (fclose(mounts))
+		syslog(LOG_ERR, "Failed to close /proc/mounts.\n");
+}
+#endif
+
+void process_event(struct dm_task *dmt,
+		   enum dm_event_mask event __attribute__((unused)),
+		   void **private)
+{
+	const char *device = dm_task_get_name(dmt);
+	int percent;
+	struct dso_state *state = *private;
+	struct dm_status_thin_pool *tps;
+	void *next = NULL;
+	uint64_t start, length;
+	char *target_type = NULL;
+	char *params;
+
+#if 0
+	/* No longer monitoring, waiting for remove */
+	if (!state->meta_percent_check && !state->data_percent_check)
+		return;
+#endif
+	dmeventd_lvm2_lock();
+
+	dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
+
+	if (!target_type || (strcmp(target_type, "thin-pool") != 0)) {
+		syslog(LOG_ERR, "Invalid targe type.\n");
+		goto out;
+	}
+
+	if (!dm_get_status_thin_pool(state->mem, params, &tps)) {
+		syslog(LOG_ERR, "Failed to parse status.\n");
+#if 0
+		/* FIXME hmm what we should do? */
+		struct dm_info info;
+		if (dm_task_get_info(dmt, &info)) {
+			dmeventd_lvm2_unlock();
+			_umount(device, info.major, info.minor);
+		} /* else; too bad, but this is best-effort thing... */
+#endif
+		goto out;
+	}
+
+#if THIN_DEBUG
+	syslog(LOG_INFO, "%p: Got status %" PRIu64 " / %" PRIu64
+	       " %" PRIu64  " / %" PRIu64 ".\n", state,
+	       tps->used_meta_blocks, tps->total_meta_blocks,
+	       tps->used_data_blocks, tps->total_data_blocks);
+#endif
+
+	/* Thin pool size had changed. Clear the threshold. */
+	if (state->known_meta_size != tps->total_meta_blocks) {
+		state->meta_percent_check = CHECK_MINIMUM;
+		state->known_meta_size = tps->total_meta_blocks;
+	}
+
+	if (state->known_data_size != tps->total_data_blocks) {
+		state->data_percent_check = CHECK_MINIMUM;
+		state->known_data_size = tps->total_data_blocks;
+	}
+
+	percent = 100 * tps->used_meta_blocks / tps->total_meta_blocks;
+	if (percent >= state->meta_percent_check) {
+		/*
+		 * Usage has raised more than CHECK_STEP since the last
+		 * time. Run actions.
+		 */
+		state->meta_percent_check = (percent / CHECK_STEP) * CHECK_STEP + CHECK_STEP;
+
+		/* FIXME: extension of metadata needs to be written! */
+		if (percent >= WARNING_THRESH) /* Print a warning to syslog. */
+			syslog(LOG_WARNING, "Thin metadata %s is now %i%% full.\n",
+			       device, percent);
+		 /* Try to extend the metadata, in accord with user-set policies */
+		if (!_extend(state))
+			syslog(LOG_ERR, "Failed to extend thin metadata %s.\n",
+			       device);
+		/* FIXME: hmm READ-ONLY switch should happen in error path */
+	}
+
+	percent = 100 * tps->used_data_blocks / tps->total_data_blocks;
+	if (percent >= state->data_percent_check) {
+		/*
+		 * Usage has raised more than CHECK_STEP since
+		 * the last time. Run actions.
+		 */
+		state->data_percent_check = (percent / CHECK_STEP) * CHECK_STEP + CHECK_STEP;
+
+		if (percent >= WARNING_THRESH) /* Print a warning to syslog. */
+			syslog(LOG_WARNING, "Thin %s is now %i%% full.\n", device, percent);
+		/* Try to extend the thin data, in accord with user-set policies */
+		if (!_extend(state))
+			syslog(LOG_ERR, "Failed to extend thin %s.\n", device);
+		/* FIXME: hmm READ-ONLY switch should happen in error path */
+	}
+out:
+	if (tps)
+		dm_pool_free(state->mem, tps);
+
+	dmeventd_lvm2_unlock();
+}
+
+int register_device(const char *device,
+		    const char *uuid __attribute__((unused)),
+		    int major __attribute__((unused)),
+		    int minor __attribute__((unused)),
+		    void **private)
+{
+	struct dm_pool *statemem = NULL;
+	struct dso_state *state;
+
+	if (!dmeventd_lvm2_init() ||
+	    !(statemem = dm_pool_create("thin_pool_state", 2048)) ||
+	    !(state = dm_pool_zalloc(statemem, sizeof(*state))) ||
+	    !dm_split_lvm_name(statemem, device, &state->vg, &state->lv,
+			       &state->layer) ||
+	    (dm_snprintf(state->cmd_str, sizeof(state->cmd_str),
+			 "lvextend --use-policies %s/%s", state->vg, state->lv) < 0)) {
+		syslog(LOG_ERR, "Failed to monitor thin %s.\n", device);
+		if (statemem)
+			dm_pool_destroy(statemem);
+
+		return 0;
+	}
+
+	state->mem = statemem;
+	state->meta_percent_check = CHECK_MINIMUM;
+	state->data_percent_check = CHECK_MINIMUM;
+	*private = state;
+
+	syslog(LOG_INFO, "Monitoring thin %s.\n", device);
+
+	return 1;
+}
+
+int unregister_device(const char *device,
+		      const char *uuid __attribute__((unused)),
+		      int major __attribute__((unused)),
+		      int minor __attribute__((unused)),
+		      void **private)
+{
+	struct dso_state *state = *private;
+
+	dm_pool_destroy(state->mem);
+	dmeventd_lvm2_exit();
+
+	syslog(LOG_INFO, "No longer monitoring thin %s.\n", device);
+
+	return 1;
+}
--- LVM2/doc/example.conf.in	2011/12/06 19:30:16	1.38
+++ LVM2/doc/example.conf.in	2011/12/21 13:08:13	1.39
@@ -701,6 +701,15 @@
 
     snapshot_library = "libdevmapper-event-lvm2snapshot.so"
 
+    # thin_library is the library used when monitoring a thin device.
+    #
+    # "libdevmapper-event-lvm2thin.so" monitors the filling of
+    # pool and emits a warning through syslog when the use of
+    # the pool exceeds 80%. The warning is repeated when 85%, 90% and
+    # 95% of the pool is filled.
+
+    thin_library = "libdevmapper-event-lvm2thin.so"
+
     # Full path of the dmeventd binary.
     #
     # executable = "@DMEVENTD_PATH@"
--- LVM2/lib/activate/activate.c	2011/11/18 19:31:09	1.224
+++ LVM2/lib/activate/activate.c	2011/12/21 13:08:13	1.225
@@ -973,20 +973,32 @@
 	return path;
 }
 
+static char *_build_target_uuid(struct cmd_context *cmd, struct logical_volume *lv)
+{
+	const char *layer;
+
+	if (lv_is_thin_pool(lv))
+		layer = "tpool"; /* Monitor "tpool" for the "thin pool". */
+	else if (lv_is_origin(lv))
+		layer = "real"; /* Monitor "real" for "snapshot-origin". */
+	else
+		layer = NULL;
+
+	return build_dm_uuid(cmd->mem, lv->lvid.s, layer);
+}
+
 int target_registered_with_dmeventd(struct cmd_context *cmd, const char *dso,
 				    struct logical_volume *lv, int *pending)
 {
 	char *uuid;
 	enum dm_event_mask evmask = 0;
 	struct dm_event_handler *dmevh;
-
 	*pending = 0;
 
 	if (!dso)
 		return_0;
 
-	/* We always monitor the "real" device, never the "snapshot-origin" itself. */
-	if (!(uuid = build_dm_uuid(cmd->mem, lv->lvid.s, lv_is_origin(lv) ? "real" : NULL)))
+	if (!(uuid = _build_target_uuid(cmd, lv)))
 		return_0;
 
 	if (!(dmevh = _create_dm_event_handler(cmd, uuid, dso, 0, DM_EVENT_ALL_ERRORS)))
@@ -1019,7 +1031,7 @@
 		return_0;
 
 	/* We always monitor the "real" device, never the "snapshot-origin" itself. */
-	if (!(uuid = build_dm_uuid(cmd->mem, lv->lvid.s, lv_is_origin(lv) ? "real" : NULL)))
+	if (!(uuid = _build_target_uuid(cmd, lv)))
 		return_0;
 
 	if (!(dmevh = _create_dm_event_handler(cmd, uuid, dso, timeout,
--- LVM2/lib/config/defaults.h	2011/12/06 19:30:16	1.90
+++ LVM2/lib/config/defaults.h	2011/12/21 13:08:13	1.91
@@ -59,6 +59,7 @@
 #define DEFAULT_DMEVENTD_RAID_LIB "libdevmapper-event-lvm2raid.so"
 #define DEFAULT_DMEVENTD_MIRROR_LIB "libdevmapper-event-lvm2mirror.so"
 #define DEFAULT_DMEVENTD_SNAPSHOT_LIB "libdevmapper-event-lvm2snapshot.so"
+#define DEFAULT_DMEVENTD_THIN_LIB "libdevmapper-event-lvm2thin.so"
 #define DEFAULT_DMEVENTD_MONITOR 1
 #define DEFAULT_BACKGROUND_POLLING 1
 
--- LVM2/lib/thin/thin.c	2011/12/21 12:56:45	1.36
+++ LVM2/lib/thin/thin.c	2011/12/21 13:08:13	1.37
@@ -21,6 +21,7 @@
 #include "config.h"
 #include "activate.h"
 #include "str_list.h"
+#include "defaults.h"
 
 #ifdef DMEVENTD
 #  include "sharedlib.h"
@@ -297,7 +298,40 @@
 
 	return 1;
 }
-#endif
+
+static int _thin_pool_target_percent(void **target_state __attribute__((unused)),
+				     percent_t *percent,
+				     struct dm_pool *mem,
+				     struct cmd_context *cmd __attribute__((unused)),
+				     struct lv_segment *seg __attribute__((unused)),
+				     char *params,
+				     uint64_t *total_numerator,
+				     uint64_t *total_denominator)
+{
+	struct dm_status_thin_pool *s;
+	percent_t meta_percent;
+	percent_t data_percent;
+
+	if (!dm_get_status_thin_pool(mem, params, &s))
+		return_0;
+
+	/*
+	 * FIXME: how to handle exhaust of metadata space
+	 * pick the max from data and meta?
+	 * Support for metadata resize is needed.
+	 */
+	meta_percent = make_percent(s->used_meta_blocks,
+				    s->total_meta_blocks);
+	data_percent = make_percent(s->used_data_blocks,
+				    s->total_data_blocks);
+
+	*percent = data_percent;
+	*total_numerator += s->used_data_blocks;
+	*total_denominator += s->total_data_blocks;
+
+	return 1;
+}
+#endif /* DEVMAPPER_SUPPORT */
 
 static const char *_thin_name(const struct lv_segment *seg)
 {
@@ -378,17 +412,6 @@
 	return 1;
 }
 
-static int _thin_target_percent(void **target_state __attribute__((unused)),
-				percent_t *percent,
-				struct dm_pool *mem __attribute__((unused)),
-				struct cmd_context *cmd __attribute__((unused)),
-				struct lv_segment *seg __attribute__((unused)),
-				char *params, uint64_t *total_numerator,
-				uint64_t *total_denominator)
-{
-	return 1;
-}
-
 static int _thin_target_present(struct cmd_context *cmd,
 				const struct lv_segment *seg,
 				unsigned *attributes __attribute__((unused)))
@@ -404,6 +427,42 @@
 	return _present;
 }
 
+#  ifdef DMEVENTD
+static const char *_get_thin_dso_path(struct cmd_context *cmd)
+{
+	return get_monitor_dso_path(cmd, find_config_tree_str(cmd, "dmeventd/thin_library",
+							      DEFAULT_DMEVENTD_THIN_LIB));
+}
+
+/* FIXME Cache this */
+static int _target_registered(struct lv_segment *seg, int *pending)
+{
+	return target_registered_with_dmeventd(seg->lv->vg->cmd,
+					       _get_thin_dso_path(seg->lv->vg->cmd),
+					       seg->pool_lv, pending);
+}
+
+/* FIXME This gets run while suspended and performs banned operations. */
+static int _target_set_events(struct lv_segment *seg, int evmask, int set)
+{
+	/* FIXME Make timeout (10) configurable */
+	return target_register_events(seg->lv->vg->cmd,
+				      _get_thin_dso_path(seg->lv->vg->cmd),
+				      seg->pool_lv, evmask, set, 10);
+}
+
+static int _target_register_events(struct lv_segment *seg,
+				   int events)
+{
+	return _target_set_events(seg, events, 1);
+}
+
+static int _target_unregister_events(struct lv_segment *seg,
+				     int events)
+{
+	return _target_set_events(seg, events, 0);
+}
+#  endif /* DMEVENTD */
 #endif
 
 static int _thin_modules_needed(struct dm_pool *mem,
@@ -430,6 +489,7 @@
 	.text_export = _thin_pool_text_export,
 #ifdef DEVMAPPER_SUPPORT
 	.add_target_line = _thin_pool_add_target_line,
+	.target_percent = _thin_pool_target_percent,
 	.target_present = _thin_target_present,
 #endif
 	.modules_needed = _thin_modules_needed,
@@ -442,8 +502,12 @@
 	.text_export = _thin_text_export,
 #ifdef DEVMAPPER_SUPPORT
 	.add_target_line = _thin_add_target_line,
-	.target_percent = _thin_target_percent,
 	.target_present = _thin_target_present,
+#  ifdef DMEVENTD
+	.target_monitored = _target_registered,
+	.target_monitor_events = _target_register_events,
+	.target_unmonitor_events = _target_unregister_events,
+#  endif /* DMEVENTD */
 #endif
 	.modules_needed = _thin_modules_needed,
 	.destroy = _thin_destroy,
@@ -484,9 +548,9 @@
 
 #ifdef DEVMAPPER_SUPPORT
 #  ifdef DMEVENTD
-// FIXME		if (_get_thin_dso_path(cmd))
-// FIXME			segtype->flags |= SEG_MONITORED;
-#  endif	/* DMEVENTD */
+		if (_get_thin_dso_path(cmd))
+			segtype->flags |= SEG_MONITORED;
+#  endif /* DMEVENTD */
 #endif
 		if (!lvm_register_segtype(seglib, segtype))
 			return_0;


