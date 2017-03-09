From: Bryn Reeves <bmr@sourceware.org>
Date: Thu, 9 Mar 2017 13:53:58 -0500
Subject: master - daemons: add dmfilemapd
Message-ID: <201703091853.v29Irw95029499@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8b78982297bb9c8484f8add7fdf96e93c8238769
Commit:        8b78982297bb9c8484f8add7fdf96e93c8238769
Parent:        c98868181fa3ee0816d525ef186c1059a46f1d0b
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Dec 15 20:10:27 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Mar 9 18:50:15 2017 +0000

daemons: add dmfilemapd

Add a daemon that can be launched to monitor a group of regions
corresponding to the extents of a file, and to update the regions as the
file's allocation changes.

The daemon is intended to be started from a library interface, but can
also be run from the command line:

  dmfilemapd <fd> <group_id> <path> <mode> [<foreground>[<log_level>]]

Where fd is a file descriptor open on the mapped file, group_id is the
group identifier of the mapped group and mode is either "inode" or
"path". E.g.:

  # dmfilemapd 3 0 vm.img inode 1 3 3<vm.img
  ...

If foreground is non-zero, the daemon will not fork to run in the
background. If verbose is non-zero, libdm and daemon log messages will
be printed.

It is possible for the group identifier to change when regions are
re-mapped: this occurs when the group leader is deleted (regroup=1 in
dm_stats_update_regions_from_fd()), and another region is created before
the daemon has a chance to recreate the leader region.

The operation is inherently racey since there is currently no way to
atomically move or resize a dm_stats region while retaining its
region_id.

Detect this condition and update the group_id value stored in the
filemap monitor.

A function is also provided in the the stats API to launch the filemap
monitoring daemon:

  int dm_stats_start_filemapd(int fd, uint64_t group_id, const char *path,
                              dm_filemapd_mode_t mode, unsigned foreground,
                              unsigned verbose);

This carries out the first fork and execs dmfilemapd with the arguments
specified.

A dm_filemapd_mode_t value is specified by the mode argument: either
DM_FILEMAPD_FOLLOW_INODE, or DM_FILEMAPD_FOLLOW_PATH. A helper function,
dm_filemapd_mode_from_string(), is provided to parse a string containing
a valid mode name into the appropriate dm_filemapd_mode_t value.
---
 configure                           |   42 ++-
 configure.in                        |   17 +
 daemons/Makefile.in                 |    6 +-
 daemons/dmfilemapd/.gitignore       |    1 +
 daemons/dmfilemapd/Makefile.in      |   69 +++
 daemons/dmfilemapd/dmfilemapd.c     |  791 +++++++++++++++++++++++++++++++++++
 include/configure.h.in              |    3 +
 libdm/.exported_symbols.DM_1_02_138 |    2 +
 libdm/libdevmapper.h                |   63 +++
 libdm/libdm-stats.c                 |  155 +++++++
 10 files changed, 1147 insertions(+), 2 deletions(-)

diff --git a/configure b/configure
index 9b69964..f522c98 100755
--- a/configure
+++ b/configure
@@ -702,6 +702,7 @@ BLKDEACTIVATE
 FSADM
 ELDFLAGS
 DM_LIB_PATCHLEVEL
+DMFILEMAPD
 DMEVENTD_PATH
 DMEVENTD
 DL_LIBS
@@ -737,6 +738,7 @@ CLDNOWHOLEARCHIVE
 CLDFLAGS
 CACHE
 BUILD_NOTIFYDBUS
+BUILD_DMFILEMAPD
 BUILD_LOCKDDLM
 BUILD_LOCKDSANLOCK
 BUILD_LVMLOCKD
@@ -960,6 +962,7 @@ enable_use_lvmetad
 with_lvmetad_pidfile
 enable_use_lvmpolld
 with_lvmpolld_pidfile
+enable_dmfilemapd
 enable_notify_dbus
 enable_blkid_wiping
 enable_udev_systemd_background_jobs
@@ -1694,6 +1697,7 @@ Optional Features:
   --disable-use-lvmlockd  disable usage of LVM lock daemon
   --disable-use-lvmetad   disable usage of LVM Metadata Daemon
   --disable-use-lvmpolld  disable usage of LVM Poll Daemon
+  --enable-dmfilemapd     enable the dmstats filemap daemon
   --enable-notify-dbus    enable LVM notification using dbus
   --disable-blkid_wiping  disable libblkid detection of signatures when wiping
                           and use native code instead
@@ -12075,6 +12079,21 @@ _ACEOF
 
 
 ################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build dmfilemapd" >&5
+$as_echo_n "checking whether to build dmfilemapd... " >&6; }
+# Check whether --enable-dmfilemapd was given.
+if test "${enable_dmfilemapd+set}" = set; then :
+  enableval=$enable_dmfilemapd; DMFILEMAPD=$enableval
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $DMFILEMAPD" >&5
+$as_echo "$DMFILEMAPD" >&6; }
+BUILD_DMFILEMAPD=$DMFILEMAPD
+
+$as_echo "#define DMFILEMAPD 1" >>confdefs.h
+
+
+################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build notifydbus" >&5
 $as_echo_n "checking whether to build notifydbus... " >&6; }
 # Check whether --enable-notify-dbus was given.
@@ -15123,6 +15142,24 @@ done
 
 fi
 
+if test "$DMFILEMAPD" = yes; then
+	for ac_header in sys/inotify.h
+do :
+  ac_fn_c_check_header_mongrel "$LINENO" "sys/inotify.h" "ac_cv_header_sys_inotify_h" "$ac_includes_default"
+if test "x$ac_cv_header_sys_inotify_h" = xyes; then :
+  cat >>confdefs.h <<_ACEOF
+#define HAVE_SYS_INOTIFY_H 1
+_ACEOF
+
+else
+  hard_bailout
+fi
+
+done
+
+fi
+
+
 ################################################################################
 if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}modprobe", so it can be a program name with args.
@@ -15585,8 +15622,10 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
+
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile include/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile li!
 bdaemon/s
 erver/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_sys!
 temd_red_
 hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile include/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile !
 libdaemon
 /client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service!
  scripts/
 lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat@.service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -16294,6 +16333,7 @@ do
     "daemons/dmeventd/plugins/mirror/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/mirror/Makefile" ;;
     "daemons/dmeventd/plugins/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/snapshot/Makefile" ;;
     "daemons/dmeventd/plugins/thin/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/thin/Makefile" ;;
+    "daemons/dmfilemapd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmfilemapd/Makefile" ;;
     "daemons/lvmdbusd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmdbusd/Makefile" ;;
     "daemons/lvmdbusd/path.py") CONFIG_FILES="$CONFIG_FILES daemons/lvmdbusd/path.py" ;;
     "daemons/lvmetad/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmetad/Makefile" ;;
diff --git a/configure.in b/configure.in
index 55bc0be..bf7ad97 100644
--- a/configure.in
+++ b/configure.in
@@ -1272,6 +1272,16 @@ AC_DEFINE_UNQUOTED(DEFAULT_USE_LVMPOLLD, [$DEFAULT_USE_LVMPOLLD],
 		   [Use lvmpolld by default.])
 
 ################################################################################
+dnl -- Check dmfilemapd
+AC_MSG_CHECKING(whether to build dmfilemapd)
+AC_ARG_ENABLE(dmfilemapd, AC_HELP_STRING([--enable-dmfilemapd],
+					 [enable the dmstats filemap daemon]),
+	      DMFILEMAPD=$enableval)
+AC_MSG_RESULT($DMFILEMAPD)
+BUILD_DMFILEMAPD=$DMFILEMAPD
+AC_DEFINE([DMFILEMAPD], 1, [Define to 1 to enable the device-mapper filemap daemon.])
+
+################################################################################
 dnl -- Build notifydbus
 AC_MSG_CHECKING(whether to build notifydbus)
 AC_ARG_ENABLE(notify-dbus,
@@ -1855,6 +1865,10 @@ if test "$UDEV_SYNC" = yes; then
 	AC_CHECK_HEADERS(sys/ipc.h sys/sem.h,,hard_bailout)
 fi
 
+if test "$DMFILEMAPD" = yes; then
+	AC_CHECK_HEADERS([sys/inotify.h],,hard_bailout)
+fi
+
 ################################################################################
 AC_PATH_TOOL(MODPROBE_CMD, modprobe)
 
@@ -1994,6 +2008,7 @@ AC_SUBST(BUILD_LVMPOLLD)
 AC_SUBST(BUILD_LVMLOCKD)
 AC_SUBST(BUILD_LOCKDSANLOCK)
 AC_SUBST(BUILD_LOCKDDLM)
+AC_SUBST(BUILD_DMFILEMAPD)
 AC_SUBST(BUILD_NOTIFYDBUS)
 AC_SUBST(CACHE)
 AC_SUBST(CFLAGS)
@@ -2043,6 +2058,7 @@ AC_SUBST(DLM_LIBS)
 AC_SUBST(DL_LIBS)
 AC_SUBST(DMEVENTD)
 AC_SUBST(DMEVENTD_PATH)
+AC_SUBST(DMFILEMAPD)
 AC_SUBST(DM_LIB_PATCHLEVEL)
 AC_SUBST(ELDFLAGS)
 AC_SUBST(FSADM)
@@ -2158,6 +2174,7 @@ daemons/dmeventd/plugins/raid/Makefile
 daemons/dmeventd/plugins/mirror/Makefile
 daemons/dmeventd/plugins/snapshot/Makefile
 daemons/dmeventd/plugins/thin/Makefile
+daemons/dmfilemapd/Makefile
 daemons/lvmdbusd/Makefile
 daemons/lvmdbusd/path.py
 daemons/lvmetad/Makefile
diff --git a/daemons/Makefile.in b/daemons/Makefile.in
index 507855c..ebbd740 100644
--- a/daemons/Makefile.in
+++ b/daemons/Makefile.in
@@ -48,8 +48,12 @@ ifeq ("@BUILD_LVMDBUSD@", "yes")
   SUBDIRS += lvmdbusd
 endif
 
+ifeq ("@BUILD_DMFILEMAPD@", "yes")
+  SUBDIRS += dmfilemapd
+endif
+
 ifeq ($(MAKECMDGOALS),distclean)
-  SUBDIRS = clvmd cmirrord dmeventd lvmetad lvmpolld lvmlockd lvmdbusd
+  SUBDIRS = clvmd cmirrord dmeventd lvmetad lvmpolld lvmlockd lvmdbusd dmfilemapd
 endif
 
 include $(top_builddir)/make.tmpl
diff --git a/daemons/dmfilemapd/.gitignore b/daemons/dmfilemapd/.gitignore
new file mode 100644
index 0000000..6dcde30
--- /dev/null
+++ b/daemons/dmfilemapd/.gitignore
@@ -0,0 +1 @@
+dmfilemapd
diff --git a/daemons/dmfilemapd/Makefile.in b/daemons/dmfilemapd/Makefile.in
new file mode 100644
index 0000000..98fb9a8
--- /dev/null
+++ b/daemons/dmfilemapd/Makefile.in
@@ -0,0 +1,69 @@
+#
+# Copyright (C) 2016 Red Hat, Inc. All rights reserved.
+#
+# This file is part of the device-mapper userspace tools.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU Lesser General Public License v.2.1.
+#
+# You should have received a copy of the GNU Lesser General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+srcdir = @srcdir@
+top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
+
+SOURCES = dmfilemapd.c
+
+TARGETS = dmfilemapd
+
+.PHONY: install_dmeventd install_dmeventd_static
+
+INSTALL_DMFILEMAPD_TARGETS = install_dmfilemapd_dynamic
+
+CLEAN_TARGETS = dmfilemapd.static
+
+CFLOW_LIST = $(SOURCES)
+CFLOW_LIST_TARGET = $(LIB_NAME).cflow
+CFLOW_TARGET = dmfilemapd
+
+include $(top_builddir)/make.tmpl
+
+all: device-mapper
+device-mapper: $(TARGETS)
+
+LIBS += -ldevmapper
+LVMLIBS += -ldevmapper-event $(PTHREAD_LIBS)
+
+CFLAGS_dmeventd.o += $(EXTRA_EXEC_CFLAGS)
+
+dmfilemapd: $(LIB_SHARED) dmfilemapd.o
+	$(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -L. -o $@ dmfilemapd.o \
+	$(DL_LIBS) $(LVMLIBS) $(LIBS) -rdynamic
+
+dmfilemapd.static: $(LIB_STATIC) dmfilemapd.o $(interfacebuilddir)/libdevmapper.a
+	$(CC) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) -static -L. -L$(interfacebuilddir) -o $@ \
+	dmfilemapd.o $(DL_LIBS) $(LVMLIBS) $(LIBS) $(STATIC_LIBS)
+
+ifneq ("$(CFLOW_CMD)", "")
+CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
+-include $(top_builddir)/libdm/libdevmapper.cflow
+-include $(top_builddir)/lib/liblvm-internal.cflow
+-include $(top_builddir)/lib/liblvm2cmd.cflow
+-include $(top_builddir)/daemons/dmfilemapd/$(LIB_NAME).cflow
+endif
+
+install_dmfilemapd_dynamic: dmfilemapd
+	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
+
+install_dmfilemapd_static: dmfilemapd.static
+	$(INSTALL_PROGRAM) -D $< $(staticdir)/$(<F)
+
+install_dmfilemapd: $(INSTALL_DMEVENTD_TARGETS)
+
+install: install_dmfilemapd
+
+install_device-mapper: install_dmfilemapd
+
diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
new file mode 100644
index 0000000..edf66fc
--- /dev/null
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -0,0 +1,791 @@
+/*
+ * Copyright (C) 2016 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of the device-mapper userspace tools.
+ *
+ * It includes tree drawing code based on pstree: http://psmisc.sourceforge.net/
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "tool.h"
+
+#include "dm-logging.h"
+
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <unistd.h>
+#include <fcntl.h>
+#include <sys/inotify.h>
+#include <dirent.h>
+#include <ctype.h>
+
+#ifdef __linux__
+#  include "kdev_t.h"
+#else
+#  define MAJOR(x) major((x))
+#  define MINOR(x) minor((x))
+#  define MKDEV(x,y) makedev((x),(y))
+#endif
+
+/* limit to two updates/sec */
+#define FILEMAPD_WAIT_USECS 500000
+
+/* how long to wait for unlinked files */
+#define FILEMAPD_NOFILE_WAIT_USECS 100000
+#define FILEMAPD_NOFILE_WAIT_TRIES 10
+
+struct filemap_monitor {
+	dm_filemapd_mode_t mode;
+	const char *program_id;
+	uint64_t group_id;
+	char *path;
+	int fd;
+
+	int inotify_fd;
+	int inotify_watch_fd;
+
+	/* monitoring heuristics */
+	int64_t blocks; /* allocated blocks, from stat.st_blocks */
+	int64_t nr_regions;
+	int deleted;
+};
+
+static int _foreground;
+static int _verbose;
+
+const char *const _usage = "dmfilemapd <fd> <group_id> <path> <mode> "
+			   "[<foreground>[<log_level>]]";
+
+/*
+ * Daemon logging. By default, all messages are thrown away: messages
+ * are only written to the terminal if the daemon is run in the foreground.
+ */
+__attribute__((format(printf, 5, 0)))
+static void _dmfilemapd_log_line(int level,
+				 const char *file __attribute__((unused)),
+				 int line __attribute__((unused)),
+				 int dm_errno_or_class,
+				 const char *f, va_list ap)
+{
+	static int _abort_on_internal_errors = -1;
+	FILE *out = log_stderr(level) ? stderr : stdout;
+
+	level = log_level(level);
+
+	if (level <= _LOG_WARN || _verbose) {
+		if (level < _LOG_WARN)
+			out = stderr;
+		vfprintf(out, f, ap);
+		fputc('\n', out);
+	}
+
+	if (_abort_on_internal_errors < 0)
+		/* Set when env DM_ABORT_ON_INTERNAL_ERRORS is not "0" */
+		_abort_on_internal_errors =
+			strcmp(getenv("DM_ABORT_ON_INTERNAL_ERRORS") ? : "0", "0");
+
+	if (_abort_on_internal_errors &&
+	    !strncmp(f, INTERNAL_ERROR, sizeof(INTERNAL_ERROR) - 1))
+		abort();
+}
+
+__attribute__((format(printf, 5, 6)))
+static void _dmfilemapd_log_with_errno(int level,
+				       const char *file, int line,
+				       int dm_errno_or_class,
+				       const char *f, ...)
+{
+	va_list ap;
+
+	va_start(ap, f);
+	_dmfilemapd_log_line(level, file, line, dm_errno_or_class, f, ap);
+	va_end(ap);
+}
+
+/*
+ * Only used for reporting errors before daemonise().
+ */
+__attribute__((format(printf, 1, 2)))
+static void _early_log(const char *fmt, ...)
+{
+	va_list ap;
+
+	va_start(ap, fmt);
+	vfprintf(stderr, fmt, ap);
+	fputc('\n', stderr);
+	va_end(ap);
+}
+
+static void _setup_logging(void)
+{
+	dm_log_init_verbose(_verbose - 1);
+	dm_log_with_errno_init(_dmfilemapd_log_with_errno);
+}
+
+#define PROC_FD_DELETED_STR "(deleted)"
+/*
+ * Scan the /proc/<pid>/fd directory for pid and check for an fd
+ * symlink whose contents match path.
+ */
+static int _is_open_in_pid(pid_t pid, const char *path)
+{
+	char deleted_path[PATH_MAX + sizeof(PROC_FD_DELETED_STR)];
+	struct dirent *pid_dp = NULL;
+	char path_buf[PATH_MAX];
+	char link_buf[PATH_MAX];
+	DIR *pid_d = NULL;
+	ssize_t len;
+
+	if (pid == getpid())
+		return 0;
+
+	if (dm_snprintf(path_buf, sizeof(path_buf), "/proc/%d/fd", pid) < 0) {
+		log_error("Could not format pid path.");
+		goto bad;
+	}
+
+	/*
+	 * Test for the kernel 'file (deleted)' form when scanning.
+	 */
+	if (dm_snprintf(deleted_path, sizeof(deleted_path), "%s %s",
+			path, PROC_FD_DELETED_STR) < 0) {
+		log_error("Could not format check path.");
+	}
+
+	pid_d = opendir(path_buf);
+	if (!pid_d) {
+		log_error("Could not open proc path: %s.", path_buf);
+		goto bad;
+	}
+
+	while ((pid_dp = readdir(pid_d)) != NULL) {
+		if (pid_dp->d_name[0] == '.')
+			continue;
+		if ((len = readlinkat(dirfd(pid_d), pid_dp->d_name, link_buf,
+				      sizeof(link_buf))) < 0) {
+			log_error("readlink failed for /proc/%d/fd/.", pid);
+			goto bad;
+		}
+		link_buf[len] = '\0';
+		if (!strcmp(deleted_path, link_buf)) {
+			closedir(pid_d);
+			return 1;
+		}
+	}
+
+bad:
+	closedir(pid_d);
+	return 0;
+}
+
+/*
+ * Attempt to determine whether a file is open by any process by
+ * scanning symbolic links in /proc/<pid>/fd.
+ *
+ * This is a heuristic since it cannot guarantee to detect brief
+ * access in all cases: a process that opens and then closes the
+ * file rapidly may never be seen by the scan.
+ *
+ * The method will also give false-positives if a process exists
+ * that has a deleted file open that had the same path, but a
+ * different inode number, to the file being monitored.
+ *
+ * For this reason the daemon only uses _is_open() for unlinked
+ * files when the mode is DM_FILEMAPD_FOLLOW_INODE, since these
+ * files can no longer be newly opened by processes.
+ *
+ * In this situation !is_open(path) provides an indication that
+ * the daemon should shut down: the file has been unlinked from
+ * the file system and we appear to hold the final reference.
+ */
+static int _is_open(const char *path)
+{
+	struct dirent *proc_dp = NULL;
+	DIR *proc_d = NULL;
+	pid_t pid;
+
+	proc_d = opendir("/proc");
+	if (!proc_d)
+		return 0;
+	while ((proc_dp = readdir(proc_d)) != NULL) {
+		if (!isdigit(proc_dp->d_name[0]))
+			continue;
+		pid = strtol(proc_dp->d_name, NULL, 10);
+		if (!pid)
+			continue;
+		if (_is_open_in_pid(pid, path)) {
+			closedir(proc_d);
+			return 1;
+		}
+	}
+	closedir(proc_d);
+	return 0;
+}
+
+static void _filemap_monitor_wait(uint64_t usecs)
+{
+	if (_verbose) {
+		if (usecs == FILEMAPD_WAIT_USECS)
+			log_very_verbose("Waiting for check interval");
+		if (usecs == FILEMAPD_NOFILE_WAIT_USECS)
+			log_very_verbose("Waiting for unlinked path");
+	}
+	usleep((useconds_t) usecs);
+}
+
+static int _parse_args(int argc, char **argv, struct filemap_monitor *fm)
+{
+	char *endptr;
+
+	/* we don't care what is in argv[0]. */
+	argc--;
+	argv++;
+
+	if (argc < 5) {
+		_early_log("Wrong number of arguments.");
+		_early_log("usage: %s", _usage);
+		return 1;
+	}
+
+	memset(fm, 0, sizeof(*fm));
+
+	/*
+	 * We don't know the true nr_regions at daemon start time,
+	 * and it is not worth a dm_stats_list()/group walk to count:
+	 * we can assume that there is@least one region or the
+	 * daemon would not have been started.
+	 *
+	 * A correct value will be obtained following the first update
+	 * of the group's regions.
+	 */
+	fm->nr_regions = 1;
+
+	/* parse <fd> */
+	fm->fd = strtol(argv[0], &endptr, 10);
+	if (*endptr) {
+		_early_log("Could not parse file descriptor: %s", argv[0]);
+		return 0;
+	}
+
+	argc--;
+	argv++;
+
+	/* parse <group_id> */
+	fm->group_id = strtoull(argv[0], &endptr, 10);
+	if (*endptr) {
+		_early_log("Could not parse group identifier: %s", argv[0]);
+		return 0;
+	}
+
+	argc--;
+	argv++;
+
+	/* parse <path> */
+	if (!argv[0] || !strlen(argv[0])) {
+		_early_log("Path argument is required.");
+		return 0;
+	}
+	fm->path = dm_strdup(argv[0]);
+	if (!fm->path) {
+		_early_log("Could not allocate memory for path argument.");
+		return 0;
+	}
+
+	argc--;
+	argv++;
+
+	/* parse <mode> */
+	if (!argv[0] || !strlen(argv[0])) {
+		_early_log("Mode argument is required.");
+		return 0;
+	}
+
+	fm->mode = dm_filemapd_mode_from_string(argv[0]);
+	if (fm->mode == DM_FILEMAPD_FOLLOW_NONE)
+		return 0;
+
+	argc--;
+	argv++;
+
+	/* parse [<foreground>[<verbose>]] */
+	if (argc) {
+		_foreground = strtol(argv[0], &endptr, 10);
+		if (*endptr) {
+			_early_log("Could not parse debug argument: %s.",
+				   argv[0]);
+			return 0;
+		}
+		argc--;
+		argv++;
+		if (argc) {
+			_verbose = strtol(argv[0], &endptr, 10);
+			if (*endptr) {
+				_early_log("Could not parse verbose "
+					   "argument: %s", argv[0]);
+				return 0;
+			}
+			if (_verbose < 0 || _verbose > 3) {
+				_early_log("Verbose argument out of range: %d.",
+					   _verbose);
+				return 0;
+			}
+		}
+	}
+	return 1;
+}
+
+static int _filemap_fd_check_changed(struct filemap_monitor *fm)
+{
+	int64_t blocks, old_blocks;
+	struct stat buf;
+
+	if (fm->fd < 0) {
+		log_error("Filemap fd is not open.");
+		return -1;
+	}
+
+	if (fstat(fm->fd, &buf)) {
+		log_error("Failed to fstat filemap file descriptor.");
+		return -1;
+	}
+
+	blocks = buf.st_blocks;
+
+	/* first check? */
+	if (fm->blocks < 0)
+		old_blocks = buf.st_blocks;
+	else
+		old_blocks = fm->blocks;
+
+	fm->blocks = blocks;
+
+	return (fm->blocks != old_blocks);
+}
+
+static void _filemap_monitor_close_fd(struct filemap_monitor *fm)
+{
+	if (close(fm->fd))
+		log_error("Error closing file descriptor.");
+	fm->fd = -1;
+}
+
+static void _filemap_monitor_end_notify(struct filemap_monitor *fm)
+{
+	inotify_rm_watch(fm->inotify_fd, fm->inotify_watch_fd);
+}
+
+static int _filemap_monitor_set_notify(struct filemap_monitor *fm)
+{
+	int inotify_fd, watch_fd;
+
+	/*
+	 * Set IN_NONBLOCK since we do not want to block in event read()
+	 * calls. Do not set IN_CLOEXEC as dmfilemapd is single-threaded
+	 * and does not fork or exec.
+	 */
+	if ((inotify_fd = inotify_init1(IN_NONBLOCK)) < 0) {
+		_early_log("Failed to initialise inotify.");
+		return 0;
+	}
+
+	if ((watch_fd = inotify_add_watch(inotify_fd, fm->path,
+					  IN_MODIFY | IN_DELETE_SELF)) < 0) {
+		_early_log("Failed to add inotify watch.");
+		return 0;
+	}
+	fm->inotify_fd = inotify_fd;
+	fm->inotify_watch_fd = watch_fd;
+	return 1;
+}
+
+static int _filemap_monitor_reopen_fd(struct filemap_monitor *fm)
+{
+	int tries = FILEMAPD_NOFILE_WAIT_TRIES;
+
+	/*
+	 * In DM_FILEMAPD_FOLLOW_PATH mode, inotify watches must be
+	 * re-established whenever the file at the watched path is
+	 * changed.
+	 *
+	 * FIXME: stat file and skip if inode is unchanged.
+	 */
+	if (fm->fd > 0)
+		log_error("Filemap file descriptor already open.");
+
+	while ((fm->fd < 0) && --tries)
+		if (((fm->fd = open(fm->path, O_RDONLY)) < 0) && tries)
+			_filemap_monitor_wait(FILEMAPD_NOFILE_WAIT_USECS);
+
+	if (!tries && (fm->fd < 0)) {
+		log_error("Could not re-open file descriptor.");
+		return 0;
+	}
+
+	return _filemap_monitor_set_notify(fm);
+}
+
+static int _filemap_monitor_get_events(struct filemap_monitor *fm)
+{
+	/* alignment as per man(7) inotify */
+	char buf[sizeof(struct inotify_event) + NAME_MAX + 1]
+		__attribute__ ((aligned(__alignof__(struct inotify_event))));
+
+	struct inotify_event *event;
+	int check = 0;
+	ssize_t len;
+	char *ptr;
+
+	/*
+	 * Close the file descriptor for the file being monitored here
+	 * when mode=path: this will allow the inode to be de-allocated,
+	 * and an IN_DELETE_SELF event generated in the case that the
+	 * daemon is holding the last open reference to the file.
+	 */
+	if (fm->mode == DM_FILEMAPD_FOLLOW_PATH) {
+		_filemap_monitor_end_notify(fm);
+		_filemap_monitor_close_fd(fm);
+	}
+
+	len = read(fm->inotify_fd, (void *) &buf, sizeof(buf));
+
+	/* no events to read? */
+	if (len < 0 && (errno == EAGAIN))
+		goto out;
+
+	/* interrupted by signal? */
+	if (len < 0 && (errno == EINTR))
+		goto out;
+
+	if (len < 0)
+		return -1;
+
+	if (!len)
+		goto out;
+
+	for (ptr = buf; ptr < buf + len; ptr += sizeof(*event) + event->len) {
+		event = (struct inotify_event *) ptr;
+		if (event->mask & IN_DELETE_SELF)
+			fm->deleted = 1;
+		if (event->mask & IN_MODIFY)
+			check = 1;
+		/*
+		 * Event IN_IGNORED is generated when a file has been deleted
+		 * and IN_DELETE_SELF generated, and indicates that the file
+		 * watch has been automatically removed.
+		 *
+		 * This can only happen for the DM_FILEMAPD_FOLLOW_PATH mode,
+		 * since inotify IN_DELETE events are generated at the time
+		 * the inode is destroyed: DM_FILEMAPD_FOLLOW_INODE will hold
+		 * the file descriptor open, meaning that the event will not
+		 * be generated until after the daemon closes the file.
+		 *
+		 * The event is ignored here since inotify monitoring will
+		 * be reestablished (or the daemon will terminate) following
+		 * deletion of a DM_FILEMAPD_FOLLOW_PATH monitored file.
+		 */
+		if (event->mask & IN_IGNORED)
+			log_very_verbose("Inotify watch removed: IN_IGNORED "
+					 "in event->mask");
+	}
+
+out:
+	/*
+	 * Re-open file descriptor if required and log disposition.
+	 */
+	if (fm->mode == DM_FILEMAPD_FOLLOW_PATH)
+		if (!_filemap_monitor_reopen_fd(fm))
+			return -1;
+
+	log_very_verbose("exiting _filemap_monitor_get_events() with "
+			 "deleted=%d, check=%d", fm->deleted, check);
+	return check;
+}
+
+static void _filemap_monitor_destroy(struct filemap_monitor *fm)
+{
+	if (fm->fd > 0) {
+		_filemap_monitor_end_notify(fm);
+		_filemap_monitor_close_fd(fm);
+	}
+	dm_free(fm->program_id);
+}
+
+static int _filemap_monitor_check_same_file(int fd1, int fd2)
+{
+	struct stat buf1, buf2;
+
+	if ((fd1 < 0) || (fd2 < 0))
+		return 0;
+
+	if (fstat(fd1, &buf1)) {
+		log_error("Failed to fstat file descriptor %d", fd1);
+		return -1;
+	}
+
+	if (fstat(fd2, &buf2)) {
+		log_error("Failed to fstat file descriptor %d", fd2);
+		return -1;
+	}
+
+	return ((buf1.st_dev == buf2.st_dev) && (buf1.st_ino == buf2.st_ino));
+}
+
+static int _filemap_monitor_check_file_unlinked(struct filemap_monitor *fm)
+{
+	char path_buf[PATH_MAX];
+	char link_buf[PATH_MAX];
+	int same, fd, len;
+
+	fm->deleted = 0;
+
+	if ((fd = open(fm->path, O_RDONLY)) < 0)
+		goto check_unlinked;
+
+	if ((same = _filemap_monitor_check_same_file(fm->fd, fd)) < 0)
+		return 0;
+
+	if (close(fd))
+		log_error("Error closing fd %d", fd);
+
+	if (same)
+		return 1;
+
+check_unlinked:
+	/*
+	 * The file has been unlinked from its original location: test
+	 * whether it is still reachable in the filesystem, or if it is
+	 * unlinked and anonymous.
+	 */
+	if (dm_snprintf(path_buf, sizeof(path_buf),
+			"/proc/%d/fd/%d", getpid(), fm->fd) < 0) {
+		log_error("Could not format pid path.");
+		return 0;
+	}
+	if ((len = readlink(path_buf, link_buf, sizeof(link_buf))) < 0) {
+		log_error("readlink failed for /proc/%d/fd/%d.",
+			  getpid(), fm->fd);
+		return 0;
+	}
+
+	/*
+	 * Try to re-open the file, from the path now reported in /proc/pid/fd.
+	 */
+	if ((fd = open(link_buf, O_RDONLY)) < 0)
+		fm->deleted = 1;
+
+	if ((same = _filemap_monitor_check_same_file(fm->fd, fd)) < 0)
+		return 0;
+
+	if ((fd > 0) && close(fd))
+		log_error("Error closing fd %d", fd);
+
+	/* Should not happen with normal /proc. */
+	if ((fd > 0) && !same) {
+		log_error("File descriptor mismatch: %d and %s (read from %s) "
+			  "are not the same file!", fm->fd, link_buf, path_buf);
+		return 0;
+	}
+	return 1;
+}
+
+static int _daemonise(struct filemap_monitor *fm)
+{
+	pid_t pid = 0, sid;
+	int fd;
+
+	if (!(sid = setsid())) {
+		_early_log("setsid failed.");
+		return 0;
+	}
+
+	if ((pid = fork()) < 0) {
+		_early_log("Failed to fork daemon process.");
+		return 0;
+	}
+
+	if (pid > 0) {
+		if (_verbose)
+			_early_log("Started dmfilemapd with pid=%d", pid);
+		exit(0);
+	}
+
+	if (chdir("/")) {
+		_early_log("Failed to change directory.");
+		return 0;
+	}
+
+	if (!_verbose) {
+		if (close(STDIN_FILENO))
+			_early_log("Error closing stdin");
+		if (close(STDOUT_FILENO))
+			_early_log("Error closing stdout");
+		if (close(STDERR_FILENO))
+			_early_log("Error closing stderr");
+		if ((open("/dev/null", O_RDONLY) < 0) ||
+	            (open("/dev/null", O_WRONLY) < 0) ||
+		    (open("/dev/null", O_WRONLY) < 0)) {
+			_early_log("Error opening stdio streams.");
+			return 0;
+		}
+	}
+
+	for (fd = sysconf(_SC_OPEN_MAX) - 1; fd > STDERR_FILENO; fd--) {
+		if (fd == fm->fd)
+			continue;
+		close(fd);
+	}
+
+	return 1;
+}
+
+static int _update_regions(struct dm_stats *dms, struct filemap_monitor *fm)
+{
+	uint64_t *regions = NULL, *region, nr_regions = 0;
+
+	regions = dm_stats_update_regions_from_fd(dms, fm->fd, fm->group_id);
+	if (!regions) {
+		log_error("Failed to update filemap regions for group_id="
+			  FMTu64 ".", fm->group_id);
+		return 0;
+	}
+
+	for (region = regions; *region != DM_STATS_REGIONS_ALL; region++)
+		nr_regions++;
+
+	if (regions[0] != fm->group_id) {
+		log_warn("group_id changed from " FMTu64 " to " FMTu64,
+			 fm->group_id, regions[0]);
+		fm->group_id = regions[0];
+	}
+
+	fm->nr_regions = nr_regions;
+	return 1;
+}
+
+static int _dmfilemapd(struct filemap_monitor *fm)
+{
+	int running = 1, check = 0, open = 0;
+	const char *program_id;
+	struct dm_stats *dms;
+
+	/*
+	 * The correct program_id is retrieved from the group leader
+	 * following the call to dm_stats_list().
+	 */
+	dms = dm_stats_create(NULL);
+
+	if (!dm_stats_bind_from_fd(dms, fm->fd)) {
+		log_error("Could not bind dm_stats handle to file descriptor "
+			  "%d", fm->fd);
+		goto bad;
+	}
+
+	if (!_filemap_monitor_set_notify(fm))
+		goto bad;
+
+	if (!dm_stats_list(dms, NULL)) {
+		log_error("Failed to list stats handle.");
+		goto bad;
+	}
+
+	/*
+	 * Take the program_id for new regions (created by calls to
+	 * dm_stats_update_regions_from_fd()) from the value used by
+	 * the group leader.
+	 */
+	program_id = dm_stats_get_region_program_id(dms, fm->group_id);
+	if (program_id)
+		fm->program_id = dm_strdup(program_id);
+	else
+		fm->program_id = NULL;
+
+	do {
+		if (!dm_stats_group_present(dms, fm->group_id)) {
+			log_info("Filemap group removed: exiting.");
+			running = 0;
+			continue;
+		}
+
+		if ((check = _filemap_monitor_get_events(fm)) < 0)
+			goto bad;
+
+		if (!check)
+			goto wait;
+
+		if ((check = _filemap_fd_check_changed(fm)) < 0)
+			goto bad;
+
+		if (!check)
+			goto wait;
+
+		if (!_update_regions(dms, fm))
+			goto bad;
+
+wait:
+		_filemap_monitor_wait(FILEMAPD_WAIT_USECS);
+
+		running = !!fm->nr_regions;
+
+		/* mode=inode termination condions */
+		if (fm->mode == DM_FILEMAPD_FOLLOW_INODE) {
+			if (!_filemap_monitor_check_file_unlinked(fm))
+				goto bad;
+			if (fm->deleted && !(open = _is_open(fm->path))) {
+				log_info("File unlinked and closed: exiting.");
+				running = 0;
+			} else if (fm->deleted && open)
+				log_verbose("File unlinked and open: "
+					     "continuing.");
+		}
+
+		if (!dm_stats_list(dms, NULL)) {
+			log_error("Failed to list stats handle.");
+			goto bad;
+		}
+
+	} while (running);
+
+	_filemap_monitor_destroy(fm);
+	dm_stats_destroy(dms);
+	return 0;
+
+bad:
+	_filemap_monitor_destroy(fm);
+	dm_stats_destroy(dms);
+	log_error("Exiting");
+	return 1;
+}
+
+static const char * _mode_names[] = {
+	"inode",
+	"path"
+};
+
+/*
+ * dmfilemapd <fd> <group_id> <path> <mode> [<foreground>[<log_level>]]
+ */
+int main(int argc, char **argv)
+{
+	struct filemap_monitor fm;
+
+	if (!_parse_args(argc, argv, &fm))
+		return 1;
+
+	_setup_logging();
+
+	log_info("Starting dmfilemapd with fd=%d, group_id=" FMTu64 " "
+		 "mode=%s, path=%s", fm.fd, fm.group_id,
+		 _mode_names[fm.mode], fm.path);
+
+	if (!_foreground && !_daemonise(&fm))
+		return 1;
+
+	return _dmfilemapd(&fm);
+}
diff --git a/include/configure.h.in b/include/configure.h.in
index cf8dc94..89a5e48 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -127,6 +127,9 @@
 /* Path to dmeventd pidfile. */
 #undef DMEVENTD_PIDFILE
 
+/* Define to 1 to enable the device-mapper filemap daemon. */
+#undef DMFILEMAPD
+
 /* Define to enable compat protocol */
 #undef DM_COMPAT
 
diff --git a/libdm/.exported_symbols.DM_1_02_138 b/libdm/.exported_symbols.DM_1_02_138
index 6d658b9..0468294 100644
--- a/libdm/.exported_symbols.DM_1_02_138
+++ b/libdm/.exported_symbols.DM_1_02_138
@@ -1,6 +1,8 @@
 dm_bit_get_last
 dm_bit_get_prev
+dm_filemapd_mode_from_string
 dm_stats_update_regions_from_fd
 dm_bitset_parse_list
 dm_stats_bind_from_fd
+dm_stats_start_filemapd
 dm_tree_node_add_raid_target_with_params_v2
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index e1dc5a4..42f9229 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1369,6 +1369,69 @@ uint64_t *dm_stats_create_regions_from_fd(struct dm_stats *dms, int fd,
 uint64_t *dm_stats_update_regions_from_fd(struct dm_stats *dms, int fd,
 					  uint64_t group_id);
 
+
+/*
+ * The file map monitoring daemon can monitor files in two distinct
+ * ways: the mode affects the behaviour of the daemon when a file
+ * under monitoring is renamed or unlinked, and the conditions which
+ * cause the daemon to terminate.
+ *
+ * In both modes, the daemon will always shut down when the group
+ * being monitored is deleted.
+ *
+ * Follow inode:
+ * The daemon follows the inode of the file, as it was at the time the
+ * daemon started. The file descriptor referencing the file is kept
+ * open at all times, and the daemon will exit when it detects that
+ * the file has been unlinked and it is the last holder of a reference
+ * to the file.
+ *
+ * This mode is useful if the file is expected to be renamed, or moved
+ * within the file system, while it is being monitored.
+ *
+ * Follow path:
+ * The daemon follows the path that was given on the daemon command
+ * line. The file descriptor referencing the file is re-opened on each
+ * iteration of the daemon, and the daemon will exit if no file exists
+ * at this location (a tolerance is allowed so that a brief delay
+ * between unlink() and creat() is permitted).
+ *
+ * This mode is useful if the file is updated by unlinking the original
+ * and placing a new file at the same path.
+ */
+
+typedef enum {
+	DM_FILEMAPD_FOLLOW_INODE,
+	DM_FILEMAPD_FOLLOW_PATH,
+	DM_FILEMAPD_FOLLOW_NONE
+} dm_filemapd_mode_t;
+
+/*
+ * Parse a string representation of a dmfilemapd mode.
+ *
+ * Returns a valid dm_filemapd_mode_t value on success, or
+ * DM_FILEMAPD_FOLLOW_NONE on error.
+ */
+dm_filemapd_mode_t dm_filemapd_mode_from_string(const char *mode_str);
+
+/*
+ * Start the dmfilemapd filemap monitoring daemon for the specified
+ * file descriptor, group, and file system path. The daemon will
+ * monitor the file for allocation changes, and when a change is
+ * detected, call dm_stats_update_regions_from_fd() to update the
+ * mapped regions for the file.
+ *
+ * The mode parameter controls the behaviour of the daemon when the
+ * file being monitored is unlinked or moved: see the comments for
+ * dm_filemapd_mode_t for a full description and possible values.
+ *
+ * The daemon can be stopped at any time by sending SIGTERM to the
+ * daemon pid.
+ */
+int dm_stats_start_filemapd(int fd, uint64_t group_id, const char *path,
+			    dm_filemapd_mode_t mode, unsigned foreground,
+			    unsigned verbose);
+
 /*
  * Call this to actually run the ioctl.
  */
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index f0a7dbf..7552ac6 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4878,6 +4878,154 @@ out:
 	return NULL;
 }
 
+#ifdef DMFILEMAPD
+static const char *_filemapd_mode_names[] = {
+	"inode",
+	"path",
+	NULL
+};
+
+dm_filemapd_mode_t dm_filemapd_mode_from_string(const char *mode_str)
+{
+	dm_filemapd_mode_t mode = DM_FILEMAPD_FOLLOW_INODE;
+	const char **mode_name;
+
+	if (mode_str) {
+		for (mode_name = _filemapd_mode_names; *mode_name; mode_name++)
+			if (!strcmp(*mode_name, mode_str))
+				break;
+		if (*mode_name)
+			mode = DM_FILEMAPD_FOLLOW_INODE
+				+ (mode_name - _filemapd_mode_names);
+		else {
+			log_error("Could not parse dmfilemapd mode: %s",
+				  mode_str);
+			return DM_FILEMAPD_FOLLOW_NONE;
+		}
+	}
+	return mode;
+}
+
+#define DM_FILEMAPD "dmfilemapd"
+#define NR_FILEMAPD_ARGS 6
+/*
+ * Start dmfilemapd to monitor the specified file descriptor, and to
+ * update the group given by 'group_id' when the file's allocation
+ * changes.
+ *
+ * usage: dmfilemapd <fd> <group_id> <mode> [<foreground>[<log_level>]]
+ */
+int dm_stats_start_filemapd(int fd, uint64_t group_id, const char *path,
+			    dm_filemapd_mode_t mode, unsigned foreground,
+			    unsigned verbose)
+{
+	char fd_str[8], group_str[8], fg_str[2], verb_str[2];
+	const char *mode_str = _filemapd_mode_names[mode];
+	char *args[NR_FILEMAPD_ARGS + 1];
+	pid_t pid = 0;
+	int argc = 0;
+
+	if (fd < 0) {
+		log_error("dmfilemapd file descriptor must be "
+			  "non-negative: %d", fd);
+		return 0;
+	}
+
+	if (mode < DM_FILEMAPD_FOLLOW_INODE
+	    || mode > DM_FILEMAPD_FOLLOW_PATH) {
+		log_error("Invalid dmfilemapd mode argument: "
+			  "Must be DM_FILEMAPD_FOLLOW_INODE or "
+			  "DM_FILEMAPD_FOLLOW_PATH");
+		return 0;
+	}
+
+	if (foreground > 1) {
+		log_error("Invalid dmfilemapd foreground argument. "
+			  "Must be 0 or 1: %d.", foreground);
+		return 0;
+	}
+
+	if (verbose > 3) {
+		log_error("Invalid dmfilemapd verbose argument. "
+			  "Must be 0..3: %d.", verbose);
+		return 0;
+	}
+
+	/* set argv[0] */
+	args[argc++] = (char *) DM_FILEMAPD;
+
+	/* set <fd> */
+	if ((dm_snprintf(fd_str, sizeof(fd_str), "%d", fd)) < 0) {
+		log_error("Could not format fd argument.");
+		return 0;
+	}
+	args[argc++] = fd_str;
+
+	/* set <group_id> */
+	if ((dm_snprintf(group_str, sizeof(group_str), FMTu64, group_id)) < 0) {
+		log_error("Could not format group_id argument.");
+		return 0;
+	}
+	args[argc++] = group_str;
+
+	/* set <path> */
+	args[argc++] = (char *) path;
+
+	/* set <mode> */
+	args[argc++] = (char *) mode_str;
+
+	/* set <foreground> */
+	if ((dm_snprintf(fg_str, sizeof(fg_str), "%u", foreground)) < 0) {
+		log_error("Could not format foreground argument.");
+		return 0;
+	}
+	args[argc++] = fg_str;
+
+	/* set <verbose> */
+	if ((dm_snprintf(verb_str, sizeof(verb_str), "%u", verbose)) < 0) {
+		log_error("Could not format verbose argument.");
+		return 0;
+	}
+	args[argc++] = verb_str;
+
+	/* terminate args[argc] */
+	args[argc] = NULL;
+
+	log_very_verbose("Spawning daemon as '%s %d " FMTu64 " %s %s %u %u'",
+			 *args, fd, group_id, path, mode_str,
+			 foreground, verbose);
+
+	if (!foreground && ((pid = fork()) < 0)) {
+		log_error("Failed to fork dmfilemapd process.");
+		return 0;
+	}
+
+	if (pid > 0) {
+		log_very_verbose("Forked dmfilemapd process as pid %d", pid);
+		return 1;
+	}
+
+	execvp(args[0], args);
+	log_error("execvp() failed.");
+	if (!foreground)
+		_exit(127);
+	return 0;
+}
+# else /* !DMFILEMAPD */
+dm_filemapd_mode_t dm_filemapd_mode_from_string(const char *mode_str)
+{
+	return 0;
+};
+
+int dm_stats_start_filemapd(int fd, uint64_t group_id, const char *path,
+			    dm_filemapd_mode_t mode, unsigned foreground,
+			    unsigned verbose)
+{
+	log_error("dmfilemapd support disabled.");
+	return 0;
+}
+#endif /* DMFILEMAPD */
+
 #else /* HAVE_LINUX_FIEMAP */
 
 uint64_t *dm_stats_create_regions_from_fd(struct dm_stats *dms, int fd,
@@ -4895,6 +5043,13 @@ uint64_t *dm_stats_update_regions_from_fd(struct dm_stats *dms, int fd,
 	log_error("File mapping requires FIEMAP ioctl support.");
 	return 0;
 }
+
+int dm_stats_start_filemapd(struct dm_stats *dms, int fd, uint64_t group_id,
+			    const char *path)
+{
+	log_error("File mapping requires FIEMAP ioctl support.");
+	return 0;
+}
 #endif /* HAVE_LINUX_FIEMAP */
 
 /*


