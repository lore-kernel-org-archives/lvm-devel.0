From: David Teigland <teigland@sourceware.org>
Date: Thu, 27 Jan 2022 22:44:43 +0000 (GMT)
Subject: main - remove static autoactivation
Message-ID: <20220127224443.88FEC386483F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ee8fb0310c53ed003a43b324c99cdfd891dd1a7c
Commit:        ee8fb0310c53ed003a43b324c99cdfd891dd1a7c
Parent:        a425729da9e756a91a5729addb26029216bfd476
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 25 16:05:32 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jan 27 16:43:11 2022 -0600

remove static autoactivation

event based autoactivation is now the only method that lvm
provides for autoactivation.

Setting lvm.conf event_activation=0 can still be used to disable
event based autoactivation commands, but doing so will no longer
enable static autoactivation.
---
 lib/config/config_settings.h                       |  15 +-
 man/Makefile.in                                    |  12 +-
 man/lvm.8_main                                     |   1 -
 man/lvm2-activation-generator.8_main               |  58 -----
 man/lvmautoactivation.7_main                       |  49 +---
 man/see_also.end                                   |   1 -
 scripts/Makefile.in                                |  14 --
 .../blk_availability_systemd_red_hat.service.in    |   2 +-
 scripts/generator-internals.c                      | 221 -----------------
 .../lvm2_activation_generator_systemd_red_hat.c    | 233 ------------------
 scripts/lvm2_monitoring_systemd_red_hat.service.in |   2 +-
 spec/packages.inc                                  |   4 -
 test/unit/Makefile                                 |   1 -
 test/unit/activation-generator_t.c                 | 268 ---------------------
 test/unit/units.h                                  |   2 -
 15 files changed, 22 insertions(+), 861 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index d280e7adb..bda6207d7 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1119,16 +1119,11 @@ cfg(global_lvdisplay_shows_full_device_path_CFG, "lvdisplay_shows_full_device_pa
 	"was never a valid path in the /dev filesystem.\n")
 
 cfg(global_event_activation_CFG, "event_activation", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, 1, vsn(2, 3, 1), 0, 0, NULL,
-	"Activate LVs based on system-generated device events.\n"
-	"When a PV appears on the system, a system-generated uevent triggers\n"
-	"the lvm2-pvscan service which runs the pvscan --cache -aay command.\n"
-	"If the new PV completes a VG, pvscan autoactivates LVs in the VG.\n"
-	"When event_activation is disabled, the lvm2-activation services are\n"
-	"generated and run at fixed points during system startup.  These\n"
-	"services run vgchange -aay to autoactivate LVs in VGs that happen\n"
-	"to be present at that point in time.\n"
-	"See the --setautoactivation option or the auto_activation_volume_list\n"
-	"setting to configure autoactivation for specific VGs or LVs.\n")
+	"Disable event based autoactivation commands.\n"
+	"WARNING: setting this to zero may cause machine startup to fail.\n"
+	"Previously, setting this to zero would enable static autoactivation\n"
+	"services (via the lvm2-activation-generator), but the autoactivation\n"
+	"services and generator have been removed.\n")
 
 cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, 0, vsn(2, 2, 93), 0, vsn(2, 3, 0), NULL,
 	NULL)
diff --git a/man/Makefile.in b/man/Makefile.in
index ba6f2046f..d3f0f583a 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -47,7 +47,6 @@ MAN8=lvm.8 lvmdump.8 lvm-fullreport.8 lvm-lvpoll.8 \
 MAN8SO=lvm-config.8 lvm-dumpconfig.8
 MAN8DM=dmsetup.8 dmstats.8
 MAN8CLUSTER=
-MAN8SYSTEMD_GENERATORS=lvm2-activation-generator.8
 
 ifeq (,$(findstring $(MAKECMDGOALS), distclean all_man install_all_man))
   MAN7 += lvmcache.7 lvmthin.7 lvmvdo.7
@@ -119,7 +118,7 @@ TESTMAN=test.gen
 include $(top_builddir)/make.tmpl
 
 CLEAN_TARGETS+=$(MAN5) $(MAN7) $(MAN8) $(MAN8SO) $(MAN8:%.8=%.8_gen) $(MAN8CLUSTER) \
-	$(MAN8SYSTEMD_GENERATORS) $(MAN8DM) $(TESTMAN)
+	$(MAN8DM) $(TESTMAN)
 
 all: man device-mapper
 
@@ -127,11 +126,11 @@ all: man device-mapper
 
 device-mapper: $(MAN8DM)
 
-man: $(MAN5) $(MAN7) $(MAN8) $(MAN8SO) $(MAN8CLUSTER) $(MAN8SYSTEMD_GENERATORS)
+man: $(MAN5) $(MAN7) $(MAN8) $(MAN8SO) $(MAN8CLUSTER)
 
 all_man: man
 
-$(MAN5) $(MAN7) $(MAN8) $(MAN8SO) $(MAN8DM) $(MAN8CLUSTER) $(MAN8SYSTEMD_GENERATORS): Makefile
+$(MAN5) $(MAN7) $(MAN8) $(MAN8SO) $(MAN8DM) $(MAN8CLUSTER): Makefile
 
 $(MANGENERATOR):
 	@echo "    [MAKE] $<"
@@ -289,11 +288,6 @@ install_device-mapper: $(MAN8DM)
 	$(Q) $(INSTALL) -d $(MAN8DIR)
 	$(Q) $(INSTALL_DATA) $^ $(MAN8DIR)/
 
-install_systemd_generators: $(MAN8SYSTEMD_GENERATORS)
-	@echo "    [INSTALL] $^"
-	$(Q) $(INSTALL) -d $(MAN8DIR)
-	$(Q) $(INSTALL_DATA) $^ $(MAN8DIR)/
-
 install: install_lvm2 install_device-mapper install_cluster
 
 install_all_man: install install_systemd_generators
diff --git a/man/lvm.8_main b/man/lvm.8_main
index a008a3bc0..6e8a1d1d3 100644
--- a/man/lvm.8_main
+++ b/man/lvm.8_main
@@ -563,7 +563,6 @@ Prepends source file name and code line number with libdm debugging.
 .P
 .BR lvm-fullreport (8),
 .BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
 .BR blkdeactivate (8),
 .BR lvmdump (8),
 .P
diff --git a/man/lvm2-activation-generator.8_main b/man/lvm2-activation-generator.8_main
deleted file mode 100644
index 4c54da285..000000000
--- a/man/lvm2-activation-generator.8_main
+++ /dev/null
@@ -1,58 +0,0 @@
-.TH "LVM2-ACTIVATION-GENERATOR" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
-.
-.SH "NAME"
-.
-lvm2-activation-generator - generator for systemd units to activate LVM volumes on boot
-.
-.SH SYNOPSIS
-.
-.B #SYSTEMD_GENERATOR_DIR#/lvm2-activation-generator
-.
-.SH DESCRIPTION
-.
-The lvm2-activation-generator is called by \fBsystemd\fP(1) on boot to
-generate systemd units at runtime to activate LVM Logical Volumes (LVs)
-when global/event_activation=0 is set in \fBlvm.conf\fP(5).  These units use
-\fBvgchange -aay\fP to activate LVs.
-.P
-If event_activation=1, the lvm2-activation-generator exits immediately without
-generating any systemd units, and LVM fully relies on event-based
-activation to activate LVs.  In this case, event-generated
-.B pvscan --cache -aay
-commands activate LVs.
-.P
-These systemd units are generated by lvm2-activation-generator:
-.P
-.I lvm2-activation-early.service
-is run before systemd's special \fBcryptsetup.target\fP to activate
-LVs that are not layered on top of encrypted devices.
-.P
-.I lvm2-activation.service
-is run after systemd's special \fBcryptsetup.target\fP to activate
-LVs that are layered on top of encrypted devices.
-.P
-.I lvm2-activation-net.service
-is run after systemd's special \fBremote-fs-pre.target\fP to activate
-LVs that are layered on attached remote devices.
-.P
-Note that all the underlying LVM devices (Physical Volumes) need to be
-present when the service is run. If the there are any devices that appear
-to the system later, LVs using these devices need to be activated directly
-by \fBlvchange\fP(8) or \fBvgchange\fP(8).
-.P
-The lvm2-activation-generator implements the \fBGenerators Specification\fP
-as referenced in \fBsystemd\fP(1).
-.
-.SH SEE ALSO
-.nh
-.ad l
-.BR lvm.conf (5),
-.BR vgchange (8),
-.BR lvchange (8),
-.BR pvscan (8),
-.P
-.BR systemd (1),
-.BR systemd.target (5),
-.BR systemd.special (7),
-.P
-.BR udev (7)
diff --git a/man/lvmautoactivation.7_main b/man/lvmautoactivation.7_main
index 54dab718b..808ea0d9f 100644
--- a/man/lvmautoactivation.7_main
+++ b/man/lvmautoactivation.7_main
@@ -17,13 +17,11 @@ is another way to limit autoactivation.
 .
 .SS event autoactivation
 .P
-The most common form of autoactivation is "event based", in which complete
-VGs are activated in response to uevents which occur during system startup
-or at any time after the system has started.  Another form of
-autoactivation is "static" in which complete VGs are activated at a fixed
-point during system startup by a systemd service, and not in response to
-events.  This can be controlled with the lvm.conf setting
-event_activation.
+LVM autoactivation is "event based", in which complete VGs are activated
+in response to uevents which occur during system startup or at any time
+after the system has started.  An old form of autoactivation was "static"
+in which complete VGs are activated at a fixed point during system startup
+by a systemd service, and not in response to events.
 .P
 Event based autoactivation is driven by udev, udev rules, and systemd.
 When a device is attached to a machine, a uevent is generated by the
@@ -32,7 +30,7 @@ rules to process the new device.  Udev rules use blkid to identify the
 device as an LVM PV and then execute the lvm-specific udev rule for the
 device, which triggers autoactivation.
 .P
-There are two variations of event baed autoactivation that may be used on
+There are two variations of event based autoactivation that may be used on
 a system, depending on the LVM udev rule that is installed (found in
 /lib/udev/rules.d/.)  The following summarizes the steps in each rule
 which lead to autoactivation:
@@ -179,35 +177,12 @@ concurrent commands attempt to activate a VG at once.
 .
 .SS static autoactivation
 .P
-When event autoactivation is disabled by setting lvm.conf
-event_activation=0, autoactivation is performed at one or more static
-points during system startup. At these points, a vgchange -aay command is
-run to activate complete VGs from devices that are present on the system
-at that time. pvscan commands (and lvm2-pvscan services) do not perform
-autoactivation in this mode.  pvscan commands may still be run from
-uevents but will do nothing when they read the event_activation=0 setting.
-.P
-The static vgchange -aay commands are run by three systemd services at
-three points during startup: lvm2-activation-early, lvm2-activation, and
-lvm2-activation-net. These static activation services are "generated
-services", so the service files are created at run time by the
-lvm2-activation-generator command (run by systemd).
-lvm2-activation-generator creates the services if lvm.conf
-event_activation=0.
-.P
-The limitation of this method is that devices may not be attached to the
-system (or set up)@a reliable point in time during startup, and they
-may not be present when the services run vgchange.  In this case, the VGs
-will not be autoactivated.  So, the timing of device attachment/setup
-determines whether static autoactivation will produce the same results as
-event autoactivation.  For this reason, static autoactivation is not
-recommended.
-.P
-Sometimes, static autoactivation is mistakenly expected to disable all
-autoactivation of particular VGs. This may appear to be effective if those
-VGs are slow to be attached or set up. But, the only correct and reliable
-way to disable autoactivation is using vgchange/lvchange
---setautoactivation n, or lvm.conf auto_activation_volume_list.
+A static autoactivation method is no longer provided by lvm.
+Setting event_activation=0 still disables event based autoactivation.
+WARNING: disabling event activation without an alternative may prevent a
+system from booting.  A custom systemd service could be written to run
+autoactivation during system startup, in which case disabling event
+autoactivation may be useful.
 .
 .SH EXAMPLES
 .P
diff --git a/man/see_also.end b/man/see_also.end
index cf7834052..46c82802a 100644
--- a/man/see_also.end
+++ b/man/see_also.end
@@ -53,7 +53,6 @@
 .P
 .BR lvm-fullreport (8),
 .BR lvm-lvpoll (8),
-.BR lvm2-activation-generator (8),
 .BR blkdeactivate (8),
 .BR lvmdump (8),
 .P
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 0d7f45680..ebcea92f9 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -15,9 +15,6 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-SOURCES = lvm2_activation_generator_systemd_red_hat.c
-TARGETS = lvm2_activation_generator_systemd_red_hat
-
 include $(top_builddir)/make.tmpl
 
 ifeq ("@BUILD_DMEVENTD@", "yes")
@@ -78,17 +75,6 @@ ifeq ("@BLKDEACTIVATE@", "yes")
 	$(Q) $(INSTALL_SCRIPT) blk_availability_init_red_hat $(initdir)/blk-availability
 endif
 
-CFLAGS_lvm2_activation_generator_systemd_red_hat.o += $(EXTRA_EXEC_CFLAGS)
-
-lvm2_activation_generator_systemd_red_hat: $(OBJECTS) $(LVMINTERNAL_LIBS)
-	@echo "    [CC] $@"
-	$(Q) $(CC) -o $@ $(OBJECTS) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) $(LVMINTERNAL_LIBS) $(LIBS)
-
-install_systemd_generators:
-	@echo "    [INSTALL] systemd_generators"
-	$(Q) $(INSTALL_DIR) $(systemd_generator_dir)
-	$(Q) $(INSTALL_PROGRAM) lvm2_activation_generator_systemd_red_hat $(systemd_generator_dir)/lvm2-activation-generator
-
 install_systemd_units:	install_dbus_service
 	@echo "    [INSTALL] systemd_units"
 	$(Q) $(INSTALL_DIR) $(systemd_unit_dir)
diff --git a/scripts/blk_availability_systemd_red_hat.service.in b/scripts/blk_availability_systemd_red_hat.service.in
index 82d3b82d0..4102566be 100644
--- a/scripts/blk_availability_systemd_red_hat.service.in
+++ b/scripts/blk_availability_systemd_red_hat.service.in
@@ -1,7 +1,7 @@
 [Unit]
 Description=Availability of block devices
 Before=shutdown.target
-After=lvm2-activation.service iscsi-shutdown.service iscsi.service iscsid.service fcoe.service rbdmap.service
+After=iscsi-shutdown.service iscsi.service iscsid.service fcoe.service rbdmap.service
 DefaultDependencies=no
 Conflicts=shutdown.target
 
diff --git a/scripts/generator-internals.c b/scripts/generator-internals.c
deleted file mode 100644
index 733e8189c..000000000
--- a/scripts/generator-internals.c
+++ /dev/null
@@ -1,221 +0,0 @@
-/*
- * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
- *
- * This file is part of the device-mapper userspace tools.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-*/
-
-// This file contains the unit testable parts of
-// lvm2_activation_generator_systemd_red_hat
-
-#include "device_mapper/all.h"
-
-#include <ctype.h>
-#include <errno.h>
-#include <fcntl.h>
-#include <limits.h>		/* For PATH_MAX for musl libc */
-#include <stdarg.h>
-#include <stdbool.h>
-#include <stdio.h>
-#include <stdlib.h>
-#include <string.h>
-#include <syslog.h>
-#include <sys/stat.h>
-#include <sys/types.h>
-#include <sys/wait.h>
-#include <unistd.h>
-
-//----------------------------------------------------------------
-
-static void _error(const char *format, ...) __attribute__ ((format(printf, 1, 2)));
-
-//----------------------------------------------------------------
-
-// I'm rolling my own version of popen() here because I do not want to
-// go through the shell.
-
-struct child_process {
-	pid_t pid;
-	FILE *fp;
-};
-
-static bool _open_child(struct child_process *child, const char *cmd, const char *argv[])
-{
-	int r, pipe_fd[2];
-
-	r = pipe(pipe_fd);
-	if (r < 0) {
-		_error("call to pipe() failed: %d\n", r);
-		return false;
-	}
-
-	child->pid = fork();
-	if (child->pid < 0) {
-		(void) close(pipe_fd[0]);
-		(void) close(pipe_fd[1]);
-		_error("call to fork() failed: %d\n", r);
-		return false;
-	}
-
-	if (child->pid == 0) {
-		// child
-		(void) close(pipe_fd[0]);
-		if (pipe_fd[1] != STDOUT_FILENO) {
-			(void) dup2(pipe_fd[1], STDOUT_FILENO);
-			(void) close(pipe_fd[1]);
-		}
-
-		/* Suppressing any use of syslog */
-		(void) setenv("LVM_SUPPRESS_SYSLOG", "1", 1);
-
-		if (execv(cmd, (char *const *) argv) < 0)
-			_error("execv failed: %s\n", strerror(errno));
-		// Shouldn't get here unless exec failed.
-		exit(1);
-	} else {
-		// parent
-		(void) close(pipe_fd[1]);
-		child->fp = fdopen(pipe_fd[0], "r");
-		if (!child->fp) {
-			_error("call to fdopen() failed\n");
-			return false;
-		}
-	}
-
-	return true;
-}
-
-// Returns the child's exit status
-static bool _close_child(struct child_process *child)
-{
-	int status;
-
-	(void) fclose(child->fp);
-
-	while (waitpid(child->pid, &status, 0) < 0)
-		if (errno != EINTR)
-			return -1;
-
-	if (WIFEXITED(status) && !WEXITSTATUS(status))
-		return true;
-
-	return false;
-}
-
-//----------------------------------------------------------------
-// Aquiring config from the lvmconfig process
-
-#define LVM_CONF_EVENT_ACTIVATION "global/event_activation"
-#define LVM_CONF_USE_LVMPOLLD	  "global/use_lvmpolld"
-
-struct config {
-	bool event_activation;
-	bool sysinit_needed;
-};
-
-static bool _begins_with(const char *line, const char *prefix, const char **rest)
-{
-	size_t len = strlen(prefix);
-
-	if (strlen(line) < len)
-		return false;
-
-	if (strncmp(line, prefix, len))
-		return false;
-
-	*rest = line + len;
-
-	return true;
-}
-
-static bool _parse_bool(const char *val, bool * result)
-{
-	const char *b = val, *e;
-
-	while (*b && isspace(*b))
-		b++;
-
-	if (!*b)
-		goto parse_error;
-
-	e = b;
-	while (*e && !isspace(*e))
-		e++;
-
-	if ((e - b) != 1)
-		goto parse_error;
-
-	// We only handle '1', or '0'
-	if (*b == '1') {
-		*result = true;
-		return true;
-
-	} else if (*b == '0') {
-		*result = false;
-		return true;
-	}
-	// Fallthrough
-
- parse_error:
-	_error("couldn't parse bool value '%s'\n", val);
-	return false;
-}
-
-static bool _parse_line(const char *line, struct config *cfg)
-{
-	const char *val;
-
-	if (_begins_with(line, "event_activation=", &val)) {
-		return _parse_bool(val, &cfg->event_activation);
-
-	} else if (_begins_with(line, "use_lvmpolld=", &val)) {
-		bool r;
-		if (!_parse_bool(val, &r))
-			return false;
-		cfg->sysinit_needed = !r;
-		return true;
-	}
-
-	return false;
-}
-
-static bool _get_config(struct config *cfg, const char *lvmconfig_path)
-{
-	static const char *_argv[] = {
-		"lvmconfig", "--type", "full",
-		LVM_CONF_EVENT_ACTIVATION, LVM_CONF_USE_LVMPOLLD, NULL
-	};
-
-	bool r = true;
-	char buffer[256];
-	struct child_process child;
-
-	cfg->event_activation = false;
-	cfg->sysinit_needed = true;
-
-	if (!_open_child(&child, lvmconfig_path, _argv)) {
-		_error("couldn't open lvmconfig process\n");
-		return false;
-	}
-
-	while (fgets(buffer, sizeof(buffer), child.fp)) {
-		if (!_parse_line(buffer, cfg)) {
-			_error("_parse_line() failed\n");
-			r = false;
-		}
-	}
-
-	if (!_close_child(&child)) {
-		_error("lvmconfig failed\n");
-		r = false;
-	}
-
-	return r;
-}
diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
deleted file mode 100644
index 0f4ac8da2..000000000
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ /dev/null
@@ -1,233 +0,0 @@
-/*
- * Copyright (C) 2012 Red Hat, Inc. All rights reserved.
- *
- * This file is part of the device-mapper userspace tools.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-*/
-
-// Code in this file gets included in the unit tests.
-#include "generator-internals.c"
-
-// Logging
-
-#define KMSG_DEV_PATH		"/dev/kmsg"
-static int _kmsg_fd;
-
-static void _log_init(void)
-{
-	// failing is harmless
-	_kmsg_fd = open(KMSG_DEV_PATH, O_WRONLY | O_NOCTTY);
-}
-
-static void _log_exit(void)
-{
-	if (_kmsg_fd != -1)
-		(void) close(_kmsg_fd);
-}
-
-__attribute__ ((format(printf, 1, 2)))
-static void _error(const char *format, ...)
-{
-	int n;
-	va_list ap;
-	char message[PATH_MAX + 30];	/* +3 for '<n>' where n is the log level and +27 for lvm2-activation-generator: " prefix */
-
-	snprintf(message, 31, "<%d>lvm2-activation-generator: ", LOG_ERR);
-
-	va_start(ap, format);
-	n = vsnprintf(message + 30, PATH_MAX, format, ap);
-	va_end(ap);
-
-	if (_kmsg_fd < 0 || (n < 0 || ((unsigned) n + 1 > PATH_MAX)))
-		return;
-
-	/* The n+31: +30 for "<n>lvm2-activation-generator: " prefix and +1 for '\0' suffix */
-	if (write(_kmsg_fd, message, n + 31) < 0)
-		_error("Failed to write activation message %s: %m.\n", message);
-}
-
-//----------------------------------------------------------------
-
-#define UNIT_TARGET_LOCAL_FS  "local-fs-pre.target"
-#define UNIT_TARGET_REMOTE_FS "remote-fs-pre.target"
-
-struct generator {
-	const char *dir;
-	struct config cfg;
-
-	int kmsg_fd;
-	char unit_path[PATH_MAX];
-	char target_path[PATH_MAX];
-};
-
-enum {
-	UNIT_EARLY,
-	UNIT_MAIN,
-	UNIT_NET
-};
-
-static const char *_unit_names[] = {
-	[UNIT_EARLY] = "lvm2-activation-early.service",
-	[UNIT_MAIN] = "lvm2-activation.service",
-	[UNIT_NET] = "lvm2-activation-net.service"
-};
-
-//----------------------------------------------------------------
-
-static int register_unit_with_target(struct generator *gen, const char *unit,
-				     const char *target)
-{
-	int r = 1;
-
-	if (dm_snprintf(gen->target_path, PATH_MAX, "%s/%s.wants", gen->dir, target) < 0) {
-		r = 0;
-		goto out;
-	}
-
-	(void) dm_prepare_selinux_context(gen->target_path, S_IFDIR);
-	if (mkdir(gen->target_path, 0755) < 0 && errno != EEXIST) {
-		_error("Failed to create target directory %s: %m.\n", gen->target_path);
-		r = 0;
-		goto out;
-	}
-
-	if (dm_snprintf
-	    (gen->target_path, PATH_MAX, "%s/%s.wants/%s", gen->dir, target, unit) < 0) {
-		r = 0;
-		goto out;
-	}
-	(void) dm_prepare_selinux_context(gen->target_path, S_IFLNK);
-	if (symlink(gen->unit_path, gen->target_path) < 0) {
-		_error("Failed to create symlink for unit %s: %m.\n", unit);
-		r = 0;
-	}
- out:
-	dm_prepare_selinux_context(NULL, 0);
-	return r;
-}
-
-static int generate_unit(struct generator *gen, int unit)
-{
-	FILE *f;
-	const char *unit_name = _unit_names[unit];
-	const char *target_name =
-	    unit == UNIT_NET ? UNIT_TARGET_REMOTE_FS : UNIT_TARGET_LOCAL_FS;
-
-	if (dm_snprintf(gen->unit_path, PATH_MAX, "%s/%s", gen->dir, unit_name)
-	    < 0)
-		return 0;
-
-	if (!(f = fopen(gen->unit_path, "wxe"))) {
-		_error("Failed to create unit file %s: %m.\n", unit_name);
-		return 0;
-	}
-
-	fputs("# Automatically generated by lvm2-activation-generator.\n"
-	      "#\n"
-	      "# This unit is responsible for direct activation of LVM logical volumes\n"
-	      "# if event-based activation not used (global/event_activation=0 in\n"
-	      "# lvm.conf). Direct LVM activation requires udev to be settled!\n\n"
-	      "[Unit]\n"
-	      "Description=LVM direct activation of logical volumes\n"
-	      "Documentation=man:lvm2-activation-generator(8)\n"
-	      "SourcePath=/etc/lvm/lvm.conf\n" "DefaultDependencies=no\n", f);
-
-	fputs("Conflicts=shutdown.target\n", f);
-
-	if (unit == UNIT_NET) {
-		fprintf(f, "After=%s iscsi.service fcoe.service rbdmap.service\n"
-			"Before=remote-fs-pre.target shutdown.target\n\n"
-			"[Service]\n"
-			"ExecStartPre=/usr/bin/udevadm settle\n", _unit_names[UNIT_MAIN]);
-	} else {
-		if (unit == UNIT_EARLY)
-			fputs("After=systemd-udev-settle.service\n"
-			      "Before=cryptsetup.target\n", f);
-		else
-			fprintf(f, "After=%s cryptsetup.target\n", _unit_names[UNIT_EARLY]);
-
-		fputs("Before=local-fs-pre.target shutdown.target\n"
-		      "Wants=systemd-udev-settle.service\n\n" "[Service]\n", f);
-	}
-
-	fputs("ExecStart=" LVM_PATH " vgchange -aay", f);
-	if (gen->cfg.sysinit_needed)
-		fputs(" --sysinit", f);
-	fputs("\nType=oneshot\n", f);
-
-	if (fclose(f) < 0) {
-		_error("Failed to write unit file %s: %m.\n", unit_name);
-		return 0;
-	}
-
-	if (!register_unit_with_target(gen, unit_name, target_name)) {
-		_error("Failed to register unit %s with target %s.\n",
-		       unit_name, target_name);
-		return 0;
-	}
-
-	return 1;
-}
-
-static bool _parse_command_line(struct generator *gen, int argc, const char **argv)
-{
-	if (argc != 4) {
-		_error("Incorrect number of arguments for activation generator.\n");
-		return false;
-	}
-
-	gen->dir = argv[1];
-	return true;
-}
-
-static bool _run(int argc, const char **argv)
-{
-	bool r;
-	mode_t old_mask;
-	struct generator gen;
-
-	if (!_parse_command_line(&gen, argc, argv))
-		return false;
-
-	if (_get_config(&gen.cfg, LVMCONFIG_PATH)) {
-		if (gen.cfg.event_activation)
-			// If event_activation=1, pvscan --cache -aay does activation.
-			return true;
-	}
-
-	/*
-	 *  Create the activation units if:
-	 *    - _get_config succeeded and event_activation=0
-	 *    - _get_config failed, then this is a failsafe fallback
-	 */
-
-	/* mark lvm2-activation.*.service as world-accessible */
-	old_mask = umask(0022);
-
-	r = generate_unit(&gen, UNIT_EARLY) &&
-	    generate_unit(&gen, UNIT_MAIN) && generate_unit(&gen, UNIT_NET);
-
-	umask(old_mask);
-
-	return r;
-}
-
-int main(int argc, const char **argv)
-{
-	bool r;
-
-	_log_init();
-	r = _run(argc, argv);
-	if (!r)
-		_error("Activation generator failed.\n");
-	_log_exit();
-
-	return r ? EXIT_SUCCESS : EXIT_FAILURE;
-}
diff --git a/scripts/lvm2_monitoring_systemd_red_hat.service.in b/scripts/lvm2_monitoring_systemd_red_hat.service.in
index 4bf744a7f..c0c96e316 100644
--- a/scripts/lvm2_monitoring_systemd_red_hat.service.in
+++ b/scripts/lvm2_monitoring_systemd_red_hat.service.in
@@ -2,7 +2,7 @@
 Description=Monitoring of LVM2 mirrors, snapshots etc. using dmeventd or progress polling
 Documentation=man:dmeventd(8) man:lvcreate(8) man:lvchange(8) man:vgchange(8)
 Requires=dm-event.socket
-After=dm-event.socket dm-event.service lvm2-activation.service
+After=dm-event.socket dm-event.service
 Before=local-fs-pre.target shutdown.target
 DefaultDependencies=no
 Conflicts=shutdown.target
diff --git a/spec/packages.inc b/spec/packages.inc
index 9b4eba263..f8271533a 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -101,9 +101,6 @@ fi
 %{_mandir}/man8/lvm-config.8.gz
 %{_mandir}/man8/lvm-dumpconfig.8.gz
 %{_mandir}/man8/lvm.8.gz
-%if %{enable_systemd}
- %{_mandir}/man8/lvm2-activation-generator.8.gz
-%endif
 %{_mandir}/man8/lvmconfig.8.gz
 %{_mandir}/man8/lvmdevices.8.gz
 %{_mandir}/man8/lvmdiskscan.8.gz
@@ -190,7 +187,6 @@ fi
  %{_tmpfilesdir}/%{name}.conf
  %{_unitdir}/blk-availability.service
  %{_unitdir}/lvm2-monitor.service
- %attr(555, -, -) %{_prefix}/lib/systemd/system-generators/lvm2-activation-generator
  %if %{have_service lvmpolld}
   %{_unitdir}/lvm2-lvmpolld.service
   %{_unitdir}/lvm2-lvmpolld.socket
diff --git a/test/unit/Makefile b/test/unit/Makefile
index 5826f41c2..05e25012f 100644
--- a/test/unit/Makefile
+++ b/test/unit/Makefile
@@ -16,7 +16,6 @@
 UNIT_SOURCE=\
 	device_mapper/vdo/status.c \
 	\
-	test/unit/activation-generator_t.c \
 	test/unit/bcache_t.c \
 	test/unit/bcache_utils_t.c \
 	test/unit/bitset_t.c \
diff --git a/test/unit/activation-generator_t.c b/test/unit/activation-generator_t.c
deleted file mode 100644
index f1e2aeda4..000000000
--- a/test/unit/activation-generator_t.c
+++ /dev/null
@@ -1,268 +0,0 @@
-/*
- * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#include "units.h"
-#include "scripts/generator-internals.c"
-
-//----------------------------------------------------------------
-
-static void _error(const char *format, ...)
-{
-	va_list ap;
-
-	va_start(ap, format);
-	vfprintf(stderr, format, ap);
-	va_end(ap);
-}
-
-//----------------------------------------------------------------
-
-struct bw_test {
-	const char *input;
-	const char *prefix;
-	const char *val;
-};
-
-static void _test_begins_with(void *fixture)
-{
-	static struct bw_test _tests[] = {
-		{"", "foo", NULL},
-		{"lskdj", "foo", NULL},
-		{"foo", "foobar", NULL},
-		{"fish", "fish", ""},
-		{"foo=bar ", "foo=", "bar "},
-	};
-
-	unsigned i;
-	for (i = 0; i < DM_ARRAY_SIZE(_tests); i++) {
-		const char *val;
-		struct bw_test *t = _tests + i;
-		if (t->val) {
-			if (!_begins_with(t->input, t->prefix, &val))
-				test_fail("_begins_with('%s', '%s') failed", t->input, t->prefix);
-			if (strcmp(val, t->val))
-				test_fail("_begins_with('%s', '%s') -> '%s', expected '%s'",
-					  t->input, t->prefix, val, t->val);
-		} else {
-			if (_begins_with(t->input, t->prefix, &val))
-				test_fail("_begins_with('%s', '%s') unexpectedly succeeded",
-					  t->input, t->prefix);
-
-		}
-	}
-}
-
-struct pb_test {
-	const char *input;
-	bool parsed;
-	bool result;
-};
-
-static const char *_bool(bool v)
-{
-	return v ? "true" : "false";
-}
-
-static void _test_parse_bool(void *fixture)
-{
-	static struct pb_test _tests[] = {
-		{"", false, false},
-		{"fish", false, false},
-		{"true", false, false},
-		{"false", false, false},
-		{"1", true, true},
-		{" \t 1\t\t", true, true},
-		{"0", true, false},
-		{"  \t0  ", true, false}
-	};
-
-	unsigned i;
-
-	for (i = 0; i < DM_ARRAY_SIZE(_tests); i++) {
-		bool result;
-		struct pb_test *t = _tests + i;
-
-		if (t->parsed) {
-			if (!_parse_bool(t->input, &result))
-				test_fail("_parse_bool('%s') unexpectedly failed", t->input);
-			if (result != t->result)
-				test_fail("_parse_bool('%s') -> %s", t->input, _bool(result));
-		} else {
-			if (_parse_bool(t->input, &result))
-				test_fail("_parse_bool('%s') unexpectedly succeeded", t->input);
-		}
-	}
-}
-
-struct pl_test {
-	const char *input;
-	bool success;
-	bool event_activation;
-	bool sysinit_needed;
-};
-
-static void _test_parse_line(void *fixture)
-{
-	static struct pl_test _tests[] = {
-		{"", false, false, false},
-		{"sldkjfs", false, false, false},
-		{"event_activation=1", true, true, true},
-		{"event_activation=0", true, false, true},
-		{"use_lvmpolld=1", true, false, false},
-		{"use_lvmpolld=0", true, false, true}
-	};
-
-	unsigned i;
-
-	for (i = 0; i< DM_ARRAY_SIZE(_tests); i++) {
-		bool r;
-		struct config cfg = {
-			.sysinit_needed = true
-		};
-		struct pl_test *t = _tests + i;
-
-		r = _parse_line(t->input, &cfg);
-		if (t->success) {
-			if (!r)
-				test_fail("_parse_line('%s') failed", t->input);
-
-			if (cfg.event_activation != t->event_activation)
-				test_fail("_parse_line('%s') -> event_activation='%s'",
-					t->input, _bool(cfg.event_activation));
-
-			if (cfg.sysinit_needed != t->sysinit_needed)
-				test_fail("_parse_line('%s') -> sysinit_needed='%s'",
-					  t->input, _bool(cfg.sysinit_needed));
-		} else if (r)
-				test_fail("_parse_line('%s') succeeded", t->input);
-	}
-}
-
-static void _test_get_config_bad_path(void *fixture)
-{
-	struct config cfg;
-
-	if (_get_config(&cfg, "/usr/bin/no-such-file"))
-		test_fail("_get_config() succeeded despite a bad lvmconfig path");
-}
-
-static void _test_get_config_bad_exit(void *fixture)
-{
-	struct config cfg;
-
-	if (_get_config(&cfg, "/usr/bin/false"))
-		test_fail("_get_config() succeeded despite a bad lvmconfig exit");
-}
-
-struct gc_test {
-	const char *output;
-	bool success;
-	bool event_activation;
-	bool sysinit_needed;
-};
-
-static const char *_fake_lvmconfig(const char *output)
-{
-	const char *path = "./fake-lvmconfig";
-
-	FILE *fp = fopen(path, "w");
-	if (!fp)
-		return NULL;
-
-	fprintf(fp, "#!/usr/bin/env bash\n");
-	fprintf(fp, "cat <<EOF\n");
-	fprintf(fp, "%s", output);
-	fprintf(fp, "EOF\n");
-
-	(void) fclose(fp);
-	if (chmod(path, 0770))
-		test_fail("chmod 0777 failed on path %s", path);
-
-	return path;
-}
-
-static void _test_get_config(void *fixture)
-{
-	static struct gc_test _tests[] = {
-		{"", true, false, true},
-		{"lsdjkf\n\n\n", false, false, false},
-
-		{"event_activation=0\nuse_lvmpolld=1\n", true, false, false},
-		{"event_activation=1\nuse_lvmpolld=1\n", true, true, false},
-		{"event_activation=1\nuse_lvmpolld=0\n", true, true, true},
-	};
-
-	bool r;
-	unsigned i;
-	const char *path;
-
-	for (i = 0; i < DM_ARRAY_SIZE(_tests); i++) {
-		struct gc_test *t = _tests + i;
-		struct config cfg = {
-			.sysinit_needed = true
-		};
-
-		path = _fake_lvmconfig(t->output);
-		if (!path)
-			test_fail("couldn't create fake lvmconfig");
-
-		r = _get_config(&cfg, path);
-		if (t->success) {
-			if (!r)
-				test_fail("_get_config() <- '%s' failed", t->output);
-
-			if (t->event_activation != cfg.event_activation)
-				test_fail("_get_config() <- '%s', event_activation = %s",
-					  t->output, _bool(cfg.event_activation));
-
-			if (t->sysinit_needed != cfg.sysinit_needed)
-				test_fail("_get_config() <- '%s', sysinit = %s",
-					  t->output, _bool(cfg.sysinit_needed));
-		} else {
-			if (r)
-				test_fail("_get_config() <- '%s' unexpectedly succeeded", t->output);
-		}
-
-		(void) unlink(path);
-	}
-}
-
-//----------------------------------------------------------------
-
-#define T(path, desc, fn) register_test(ts, "/activation-generator/" path, desc, fn)
-
-static struct test_suite *_tests(void)
-{
-	struct test_suite *ts = test_suite_create(NULL, NULL);
-	if (!ts) {
-		fprintf(stderr, "out of memory\n");
-		exit(1);
-	};
-
-	T("begins-with", "Test cases for _begins_with()", _test_begins_with);
-	T("parse-bool", "Test cases for _parse_bool()", _test_parse_bool);
-	T("parse-line", "Test cases for _parse_line()", _test_parse_line);
-	T("get-config-bad-path", "_get_config() needs a valid lvmconfig path", _test_get_config_bad_path);
-	T("get-config-bad-exit", "lvmconfig bad exit code gets propagated", _test_get_config_bad_exit);
-	T("get-config", "Test cases for _get_config()", _test_get_config);
-
-	return ts;
-}
-
-void activation_generator_tests(struct dm_list *all_tests)
-{
-	dm_list_add(all_tests, &_tests()->list);
-}
-
-//----------------------------------------------------------------
diff --git a/test/unit/units.h b/test/unit/units.h
index bc0db8d13..d7ac6adc3 100644
--- a/test/unit/units.h
+++ b/test/unit/units.h
@@ -20,7 +20,6 @@
 //-----------------------------------------------------------------
 
 // Declare the function that adds tests suites here ...
-void activation_generator_tests(struct dm_list *suites);
 void bcache_tests(struct dm_list *suites);
 void bcache_utils_tests(struct dm_list *suites);
 void bitset_tests(struct dm_list *suites);
@@ -37,7 +36,6 @@ void vdo_tests(struct dm_list *suites);
 // ... and call it in here.
 static inline void register_all_tests(struct dm_list *suites)
 {
-        activation_generator_tests(suites);
 	bcache_tests(suites);
 	bcache_utils_tests(suites);
 	bitset_tests(suites);


