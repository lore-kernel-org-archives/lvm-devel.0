From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 09:34:08 -0400
Subject: master - dmeventd: base vdo plugin
Message-ID: <201807091334.w69DY8gf030576@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=80e6097ea6bc56548304185715f04e8eaca2da48
Commit:        80e6097ea6bc56548304185715f04e8eaca2da48
Parent:        b98846998b7719360e9d41f83a24101c8389bc70
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 9 11:41:26 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 15:28:32 2018 +0200

dmeventd: base vdo plugin

Introduce VDO plugin for monitoring VDO devices.

This plugin can be used also by other users, as plugin checks
for UUID prefix 'LVM-' and run  lvm actions only on those
devices.

Non LVM- device are only monitored and log warnings
when usage threshold reaches 80%.
---
 WHATS_NEW_DM                                   |    1 +
 configure                                      |    3 +-
 configure.ac                                   |    1 +
 daemons/dmeventd/libdevmapper-event.c          |    1 +
 daemons/dmeventd/plugins/Makefile.in           |    9 +-
 daemons/dmeventd/plugins/vdo/.exported_symbols |    3 +
 daemons/dmeventd/plugins/vdo/Makefile.in       |   36 ++
 daemons/dmeventd/plugins/vdo/dmeventd_vdo.c    |  406 ++++++++++++++++++++++++
 8 files changed, 453 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 7a94016..ac4868c 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.147 -
 ====================================
+  Add vdo plugin for monitoring VDO devices.
 
 Version 1.02.147-rc1 - 24th May 2018
 ====================================
diff --git a/configure b/configure
index deaa8e9..fc5783d 100755
--- a/configure
+++ b/configure
@@ -13672,7 +13672,7 @@ _ACEOF
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl libdm/make.tmpl daemons/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/dm-tools/Makefile libdm/libdevmapper.pc man/Makefile po/Makefile scripts/blkdeactivate.sh scripts
 /blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile tools/Makefile udev/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl libdm/make.tmpl daemons/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmeventd/plugins/vdo/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/dm-tools/Makefile libdm/libdevmapper.pc man/Makefile po/Mak
 efile scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile tools/Makefile udev/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -14380,6 +14380,7 @@ do
     "daemons/dmeventd/plugins/mirror/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/mirror/Makefile" ;;
     "daemons/dmeventd/plugins/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/snapshot/Makefile" ;;
     "daemons/dmeventd/plugins/thin/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/thin/Makefile" ;;
+    "daemons/dmeventd/plugins/vdo/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/vdo/Makefile" ;;
     "daemons/lvmdbusd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmdbusd/Makefile" ;;
     "daemons/lvmdbusd/lvmdbusd") CONFIG_FILES="$CONFIG_FILES daemons/lvmdbusd/lvmdbusd" ;;
     "daemons/lvmdbusd/lvmdb.py") CONFIG_FILES="$CONFIG_FILES daemons/lvmdbusd/lvmdb.py" ;;
diff --git a/configure.ac b/configure.ac
index 699bbb6..21ff52c 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1775,6 +1775,7 @@ daemons/dmeventd/plugins/raid/Makefile
 daemons/dmeventd/plugins/mirror/Makefile
 daemons/dmeventd/plugins/snapshot/Makefile
 daemons/dmeventd/plugins/thin/Makefile
+daemons/dmeventd/plugins/vdo/Makefile
 daemons/lvmdbusd/Makefile
 daemons/lvmdbusd/lvmdbusd
 daemons/lvmdbusd/lvmdb.py
diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index e58a0ce..1c4607a 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -648,6 +648,7 @@ int dm_event_register_handler(const struct dm_event_handler *dmevh)
 	uuid = dm_task_get_uuid(dmt);
 
 	if (!strstr(dmevh->dso, "libdevmapper-event-lvm2thin.so") &&
+	    !strstr(dmevh->dso, "libdevmapper-event-lvm2vdo.so") &&
 	    !strstr(dmevh->dso, "libdevmapper-event-lvm2snapshot.so") &&
 	    !strstr(dmevh->dso, "libdevmapper-event-lvm2mirror.so") &&
 	    !strstr(dmevh->dso, "libdevmapper-event-lvm2raid.so"))
diff --git a/daemons/dmeventd/plugins/Makefile.in b/daemons/dmeventd/plugins/Makefile.in
index 27edf55..951dd2b 100644
--- a/daemons/dmeventd/plugins/Makefile.in
+++ b/daemons/dmeventd/plugins/Makefile.in
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2005, 2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2018 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -16,11 +16,7 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-SUBDIRS += lvm2 snapshot raid thin mirror
-
-ifeq ($(MAKECMDGOALS),distclean)
-  SUBDIRS = lvm2 mirror snapshot raid thin
-endif
+SUBDIRS += lvm2 snapshot raid thin mirror vdo
 
 include $(top_builddir)/make.tmpl
 
@@ -28,3 +24,4 @@ snapshot: lvm2
 mirror: lvm2
 raid: lvm2
 thin: lvm2
+vdo: lvm2
diff --git a/daemons/dmeventd/plugins/vdo/.exported_symbols b/daemons/dmeventd/plugins/vdo/.exported_symbols
new file mode 100644
index 0000000..b88c705
--- /dev/null
+++ b/daemons/dmeventd/plugins/vdo/.exported_symbols
@@ -0,0 +1,3 @@
+process_event
+register_device
+unregister_device
diff --git a/daemons/dmeventd/plugins/vdo/Makefile.in b/daemons/dmeventd/plugins/vdo/Makefile.in
new file mode 100644
index 0000000..bda738a
--- /dev/null
+++ b/daemons/dmeventd/plugins/vdo/Makefile.in
@@ -0,0 +1,36 @@
+#
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+srcdir = @srcdir@
+top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
+
+INCLUDES += -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
+CLDFLAGS += -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
+
+SOURCES = dmeventd_vdo.c
+
+LIB_NAME = libdevmapper-event-lvm2vdo
+LIB_SHARED = $(LIB_NAME).$(LIB_SUFFIX)
+LIB_VERSION = $(LIB_VERSION_LVM)
+
+CFLOW_LIST = $(SOURCES)
+CFLOW_LIST_TARGET = $(LIB_NAME).cflow
+
+include $(top_builddir)/make.tmpl
+
+LIBS += -ldevmapper-event-lvm2 $(INTERNAL_LIBS)
+
+install_lvm2: install_dm_plugin
+
+install: install_lvm2
diff --git a/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c b/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
new file mode 100644
index 0000000..d77ca79
--- /dev/null
+++ b/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
@@ -0,0 +1,406 @@
+/*
+ * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "lib/misc/lib.h"
+#include "dmeventd_lvm.h"
+#include "daemons/dmeventd/libdevmapper-event.h"
+#include "device_mapper/vdo/target.h"
+
+#include <sys/wait.h>
+#include <stdarg.h>
+
+/* First warning when VDO pool is 80% full. */
+#define WARNING_THRESH	(DM_PERCENT_1 * 80)
+/* Run a check every 5%. */
+#define CHECK_STEP	(DM_PERCENT_1 *  5)
+/* Do not bother checking VDO pool is less than 50% full. */
+#define CHECK_MINIMUM	(DM_PERCENT_1 * 50)
+
+#define MAX_FAILS	(256)  /* ~42 mins between cmd call retry with 10s delay */
+
+#define VDO_DEBUG 0
+
+struct dso_state {
+	struct dm_pool *mem;
+	int percent_check;
+	int percent;
+	uint64_t known_data_size;
+	unsigned fails;
+	unsigned max_fails;
+	int restore_sigset;
+	sigset_t old_sigset;
+	pid_t pid;
+	char *argv[3];
+	const char *cmd_str;
+	const char *name;
+};
+
+DM_EVENT_LOG_FN("vdo")
+
+static int _run_command(struct dso_state *state)
+{
+	char val[16];
+	int i;
+
+	/* Mark for possible lvm2 command we are running from dmeventd
+	 * lvm2 will not try to talk back to dmeventd while processing it */
+	(void) setenv("LVM_RUN_BY_DMEVENTD", "1", 1);
+
+	if (state->percent) {
+		/* Prepare some known data to env vars for easy use */
+		if (dm_snprintf(val, sizeof(val), "%d",
+				state->percent / DM_PERCENT_1) != -1)
+			(void) setenv("DMEVENTD_VDO_POOL", val, 1);
+	} else {
+		/* For an error event it's for a user to check status and decide */
+		log_debug("Error event processing.");
+	}
+
+	log_verbose("Executing command: %s", state->cmd_str);
+
+	/* TODO:
+	 *   Support parallel run of 'task' and it's waitpid maintainence
+	 *   ATM we can't handle signaling of  SIGALRM
+	 *   as signalling is not allowed while 'process_event()' is running
+	 */
+	if (!(state->pid = fork())) {
+		/* child */
+		(void) close(0);
+		for (i = 3; i < 255; ++i) (void) close(i);
+		execvp(state->argv[0], state->argv);
+		_exit(errno);
+	} else if (state->pid == -1) {
+		log_error("Can't fork command %s.", state->cmd_str);
+		state->fails = 1;
+		return 0;
+	}
+
+	return 1;
+}
+
+static int _use_policy(struct dm_task *dmt, struct dso_state *state)
+{
+#if VDO_DEBUG
+	log_debug("dmeventd executes: %s.", state->cmd_str);
+#endif
+	if (state->argv[0])
+		return _run_command(state);
+
+	if (!dmeventd_lvm2_run_with_lock(state->cmd_str)) {
+		log_error("Failed command for %s.", dm_task_get_name(dmt));
+		state->fails = 1;
+		return 0;
+	}
+
+	state->fails = 0;
+
+	return 1;
+}
+
+/* Check if executed command has finished
+ * Only 1 command may run */
+static int _wait_for_pid(struct dso_state *state)
+{
+	int status = 0;
+
+	if (state->pid == -1)
+		return 1;
+
+	if (!waitpid(state->pid, &status, WNOHANG))
+		return 0;
+
+	/* Wait for finish */
+	if (WIFEXITED(status)) {
+		log_verbose("Child %d exited with status %d.",
+			    state->pid, WEXITSTATUS(status));
+		state->fails = WEXITSTATUS(status) ? 1 : 0;
+	} else {
+		if (WIFSIGNALED(status))
+			log_verbose("Child %d was terminated with status %d.",
+				    state->pid, WTERMSIG(status));
+		state->fails = 1;
+	}
+
+	state->pid = -1;
+
+	return 1;
+}
+
+void process_event(struct dm_task *dmt,
+		   enum dm_event_mask event __attribute__((unused)),
+		   void **user)
+{
+	const char *device = dm_task_get_name(dmt);
+	struct dso_state *state = *user;
+	void *next = NULL;
+	uint64_t start, length;
+	char *target_type = NULL;
+	char *params;
+	int needs_policy = 0;
+	struct dm_task *new_dmt = NULL;
+	struct dm_vdo_status_parse_result vdop = { .status = NULL };
+
+#if VDO_DEBUG
+	log_debug("Watch for VDO %s:%.2f%%.", state->name,
+		  dm_percent_to_round_float(state->percent_check, 2));
+#endif
+	if (!_wait_for_pid(state)) {
+		log_warn("WARNING: Skipping event, child %d is still running (%s).",
+			 state->pid, state->cmd_str);
+		return;
+	}
+
+	if (event & DM_EVENT_DEVICE_ERROR) {
+#if VDO_DEBUG
+		log_debug("VDO event error.");
+#endif
+		/* Error -> no need to check and do instant resize */
+		state->percent = 0;
+		if (_use_policy(dmt, state))
+			goto out;
+
+		stack;
+
+		if (!(new_dmt = dm_task_create(DM_DEVICE_STATUS)))
+			goto_out;
+
+		if (!dm_task_set_uuid(new_dmt, dm_task_get_uuid(dmt)))
+			goto_out;
+
+		/* Non-blocking status read */
+		if (!dm_task_no_flush(new_dmt))
+			log_warn("WARNING: Can't set no_flush for dm status.");
+
+		if (!dm_task_run(new_dmt))
+			goto_out;
+
+		dmt = new_dmt;
+	}
+
+	dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
+
+	if (!target_type || (strcmp(target_type, "vdo") != 0)) {
+		log_error("Invalid target type.");
+		goto out;
+	}
+
+	if (!dm_vdo_status_parse(state->mem, params, &vdop)) {
+		log_error("Failed to parse status.");
+		goto out;
+	}
+
+	state->percent = dm_make_percent(vdop.status->used_blocks,
+					 vdop.status->total_blocks);
+
+#if VDO_DEBUG
+	log_debug("VDO %s status  %.2f%% " FMTu64 "/" FMTu64 ".",
+		  state->name, dm_percent_to_round_float(state->percent, 2),
+		  vdop.status->used_blocks, vdop.status->total_blocks);
+#endif
+
+	/* VDO pool size had changed. Clear the threshold. */
+	if (state->known_data_size != vdop.status->total_blocks) {
+		state->percent_check = CHECK_MINIMUM;
+		state->known_data_size = vdop.status->total_blocks;
+		state->fails = 0;
+	}
+
+	/*
+	 * Trigger action when threshold boundary is exceeded.
+	 * Report 80% threshold warning when it's used above 80%.
+	 * Only 100% is exception as it cannot be surpased so policy
+	 * action is called for:  >50%, >55% ... >95%, 100%
+	 */
+	if ((state->percent > WARNING_THRESH) &&
+	    (state->percent > state->percent_check))
+		log_warn("WARNING: VDO %s %s is now %.2f%% full.",
+			 state->name, device,
+			 dm_percent_to_round_float(state->percent, 2));
+	if (state->percent > CHECK_MINIMUM) {
+		/* Run action when usage raised more than CHECK_STEP since the last time */
+		if (state->percent > state->percent_check)
+			needs_policy = 1;
+		state->percent_check = (state->percent / CHECK_STEP + 1) * CHECK_STEP;
+		if (state->percent_check == DM_PERCENT_100)
+			state->percent_check--; /* Can't get bigger then 100% */
+	} else
+		state->percent_check = CHECK_MINIMUM;
+
+	/* Reduce number of _use_policy() calls by power-of-2 factor till frequency of MAX_FAILS is reached.
+	 * Avoids too high number of error retries, yet shows some status messages in log regularly.
+	 * i.e. PV could have been pvmoved and VG/LV was locked for a while...
+	 */
+	if (state->fails) {
+		if (state->fails++ <= state->max_fails) {
+			log_debug("Postponing frequently failing policy (%u <= %u).",
+				  state->fails - 1, state->max_fails);
+			return;
+		}
+		if (state->max_fails < MAX_FAILS)
+			state->max_fails <<= 1;
+		state->fails = needs_policy = 1; /* Retry failing command */
+	} else
+		state->max_fails = 1; /* Reset on success */
+
+	/* FIXME: ATM nothing can be done, drop 0, once it becomes useful */
+	if (0 && needs_policy)
+		_use_policy(dmt, state);
+out:
+	if (vdop.status)
+		dm_pool_free(state->mem, vdop.status);
+
+	if (new_dmt)
+		dm_task_destroy(new_dmt);
+}
+
+/* Handle SIGCHLD for a thread */
+static void _sig_child(int signum __attribute__((unused)))
+{
+	/* empty SIG_IGN */;
+}
+
+/* Setup handler for SIGCHLD when executing external command
+ * to get quick 'waitpid()' reaction
+ * It will interrupt syscall just like SIGALRM and
+ * invoke process_event().
+ */
+static void _init_thread_signals(struct dso_state *state)
+{
+	struct sigaction act = { .sa_handler = _sig_child };
+	sigset_t my_sigset;
+
+	sigemptyset(&my_sigset);
+
+	if (sigaction(SIGCHLD, &act, NULL))
+		log_warn("WARNING: Failed to set SIGCHLD action.");
+	else if (sigaddset(&my_sigset, SIGCHLD))
+		log_warn("WARNING: Failed to add SIGCHLD to set.");
+	else if (pthread_sigmask(SIG_UNBLOCK, &my_sigset, &state->old_sigset))
+		log_warn("WARNING: Failed to unblock SIGCHLD.");
+	else
+		state->restore_sigset = 1;
+}
+
+static void _restore_thread_signals(struct dso_state *state)
+{
+	if (state->restore_sigset &&
+	    pthread_sigmask(SIG_SETMASK, &state->old_sigset, NULL))
+		log_warn("WARNING: Failed to block SIGCHLD.");
+}
+
+int register_device(const char *device,
+		    const char *uuid,
+		    int major __attribute__((unused)),
+		    int minor __attribute__((unused)),
+		    void **user)
+{
+	struct dso_state *state;
+	const char *cmd;
+	char *str;
+	char cmd_str[PATH_MAX + 128 + 2]; /* cmd ' ' vg/lv \0 */
+        const char *name = "pool";
+
+	if (!dmeventd_lvm2_init_with_pool("vdo_pool_state", state))
+		goto_bad;
+
+	state->cmd_str = "";
+
+	/* Search for command for LVM- prefixed devices only */
+	cmd = (strncmp(uuid, "LVM-", 4) == 0) ? "_dmeventd_vdo_command" : "";
+
+	if (!dmeventd_lvm2_command(state->mem, cmd_str, sizeof(cmd_str), cmd, device))
+		goto_bad;
+
+	if (strncmp(cmd_str, "lvm ", 4) == 0) {
+		if (!(state->cmd_str = dm_pool_strdup(state->mem, cmd_str + 4))) {
+			log_error("Failed to copy lvm VDO command.");
+				goto bad;
+		}
+	} else if (cmd_str[0] == '/') {
+		if (!(state->cmd_str = dm_pool_strdup(state->mem, cmd_str))) {
+			log_error("Failed to copy VDO command.");
+			goto bad;
+		}
+
+		/* Find last space before 'vg/lv' */
+		if (!(str = strrchr(state->cmd_str, ' ')))
+			goto inval;
+
+		if (!(state->argv[0] = dm_pool_strndup(state->mem, state->cmd_str,
+						       str - state->cmd_str))) {
+			log_error("Failed to copy command.");
+			goto bad;
+		}
+
+		state->argv[1] = str + 1;  /* 1 argument - vg/lv */
+		_init_thread_signals(state);
+	} else if (cmd[0] == 0) {
+		state->name = "volume"; /* What to use with 'others?' */
+	} else/* Unuspported command format */
+		goto inval;
+
+	state->pid = -1;
+	state->name = name;
+	*user = state;
+
+	log_info("Monitoring VDO %s %s.", name, device);
+
+	return 1;
+inval:
+	log_error("Invalid command for monitoring: %s.", cmd_str);
+bad:
+	log_error("Failed to monitor VDO %s %s.", name, device);
+
+	if (state)
+		dmeventd_lvm2_exit_with_pool(state);
+
+	return 0;
+}
+
+int unregister_device(const char *device,
+		      const char *uuid __attribute__((unused)),
+		      int major __attribute__((unused)),
+		      int minor __attribute__((unused)),
+		      void **user)
+{
+	struct dso_state *state = *user;
+	const char *name = state->name;
+	int i;
+
+	for (i = 0; !_wait_for_pid(state) && (i < 6); ++i) {
+		if (i == 0)
+			/* Give it 2 seconds, then try to terminate & kill it */
+			log_verbose("Child %d still not finished (%s) waiting.",
+				    state->pid, state->cmd_str);
+		else if (i == 3) {
+			log_warn("WARNING: Terminating child %d.", state->pid);
+			kill(state->pid, SIGINT);
+			kill(state->pid, SIGTERM);
+		} else if (i == 5) {
+			log_warn("WARNING: Killing child %d.", state->pid);
+			kill(state->pid, SIGKILL);
+		}
+		sleep(1);
+	}
+
+	if (state->pid != -1)
+		log_warn("WARNING: Cannot kill child %d!", state->pid);
+
+	_restore_thread_signals(state);
+
+	dmeventd_lvm2_exit_with_pool(state);
+	log_info("No longer monitoring VDO %s %s.", name, device);
+
+	return 1;
+}


