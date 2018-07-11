From: David Teigland <teigland@sourceware.org>
Date: Wed, 11 Jul 2018 12:28:35 -0400
Subject: master - Remove lvmetad
Message-ID: <201807111628.w6BGSZMf009378@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=117160b27e510dceb1ed6acf995115c040acd88d
Commit:        117160b27e510dceb1ed6acf995115c040acd88d
Parent:        edf3f86184a380994e383b9884364e702e4ac647
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jul 10 13:39:29 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 11 11:26:42 2018 -0500

Remove lvmetad

Native disk scanning is now both reduced and
async/parallel, which makes it comparable in
performance (and often faster) when compared
to lvm using lvmetad.

Autoactivation now uses local temp files to record
online PVs, and no longer requires lvmetad.

There should be no apparent command-level change
in behavior.
---
 Makefile.in                      |    3 +-
 configure.ac                     |   47 -
 daemons/lvmetad/.gitignore       |    2 -
 daemons/lvmetad/Makefile.in      |   64 -
 daemons/lvmetad/lvmetactl.c      |  249 ---
 daemons/lvmetad/lvmetad-client.h |   90 --
 daemons/lvmetad/lvmetad-core.c   | 3010 -------------------------------------
 daemons/lvmetad/test.sh          |   16 -
 daemons/lvmetad/testclient.c     |  147 --
 daemons/lvmlockd/lvmlockd-core.c |  135 +--
 include/Makefile.in              |    2 -
 lib/Makefile.in                  |    5 -
 lib/cache/lvmcache.c             |   68 +-
 lib/cache/lvmcache.h             |    3 -
 lib/cache/lvmetad.c              | 3075 --------------------------------------
 lib/cache/lvmetad.h              |  213 ---
 lib/commands/toolcontext.c       |  131 +--
 lib/commands/toolcontext.h       |    1 -
 lib/config/config_settings.h     |   44 +-
 lib/format_text/archiver.c       |    1 -
 lib/format_text/format-text.c    |   61 -
 lib/format_text/import.c         |    6 -
 lib/format_text/import_vsn1.c    |   27 +-
 lib/label/label.h                |    2 -
 lib/locking/locking.h            |    2 -
 lib/locking/lvmlockd.c           |   62 +-
 lib/metadata/metadata.c          |  104 +--
 lib/metadata/metadata.h          |    2 -
 lib/metadata/vg.c                |    7 -
 lib/metadata/vg.h                |   20 -
 tools/Makefile.in                |    4 -
 tools/args.h                     |    7 +-
 tools/command-lines.in           |   17 +-
 tools/command.c                  |    1 -
 tools/commands.h                 |   11 +-
 tools/lvchange.c                 |   14 -
 tools/lvmcmdline.c               |   56 +-
 tools/lvscan.c                   |   62 +-
 tools/polldaemon.c               |   22 +-
 tools/pvcreate.c                 |   11 -
 tools/pvdisplay.c                |   17 -
 tools/pvscan.c                   |  567 +-------
 tools/reporter.c                 |    5 +-
 tools/toollib.c                  |   24 +-
 tools/tools.h                    |    6 +-
 tools/vgcfgrestore.c             |   35 +-
 tools/vgchange.c                 |   14 -
 tools/vgck.c                     |    1 -
 tools/vgcreate.c                 |    3 +-
 tools/vgimport.c                 |   20 -
 tools/vgimportclone.c            |   25 -
 tools/vgmerge.c                  |    1 -
 tools/vgrename.c                 |    4 +-
 tools/vgscan.c                   |   66 +-
 tools/vgsplit.c                  |    7 -
 55 files changed, 102 insertions(+), 8497 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index d076088..6a1a990 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -83,7 +83,7 @@ endif
 DISTCLEAN_TARGETS += cscope.out
 CLEAN_DIRS += autom4te.cache
 
-check check_system check_cluster check_local check_lvmetad check_lvmpolld check_lvmlockd_test check_lvmlockd_dlm check_lvmlockd_sanlock: test
+check check_system check_cluster check_local check_lvmpolld check_lvmlockd_test check_lvmlockd_dlm check_lvmlockd_sanlock: test
 	$(MAKE) -C test $(@)
 
 conf.generate man.generate: tools
@@ -153,7 +153,6 @@ LCOV_TRACES = libdm.info lib.info tools.info \
 	test/unit.info \
 	daemons/clvmd.info \
 	daemons/dmeventd.info \
-	daemons/lvmetad.info \
 	daemons/lvmlockd.info \
 	daemons/lvmpolld.info
 
diff --git a/configure.ac b/configure.ac
index ab0c770..8f5349f 100644
--- a/configure.ac
+++ b/configure.ac
@@ -39,7 +39,6 @@ case "$host_os" in
 		LDDEPS="$LDDEPS .export.sym"
 		LIB_SUFFIX=so
 		DEVMAPPER=yes
-		BUILD_LVMETAD=no
 		BUILD_LVMPOLLD=no
 		LOCKDSANLOCK=no
 		LOCKDDLM=no
@@ -844,16 +843,6 @@ if test "$DEVMAPPER" = yes; then
 fi
 
 ################################################################################
-dnl -- Build lvmetad
-AC_MSG_CHECKING(whether to build LVMetaD)
-AC_ARG_ENABLE(lvmetad,
-	      AC_HELP_STRING([--enable-lvmetad],
-			     [enable the LVM Metadata Daemon]),
-	      LVMETAD=$enableval)
-test -n "$LVMETAD" && BUILD_LVMETAD=$LVMETAD
-AC_MSG_RESULT($BUILD_LVMETAD)
-
-################################################################################
 dnl -- Build lvmpolld
 AC_MSG_CHECKING(whether to build lvmpolld)
 AC_ARG_ENABLE(lvmpolld,
@@ -908,9 +897,7 @@ AC_MSG_RESULT($BUILD_LVMLOCKD)
 
 if test "$BUILD_LVMLOCKD" = yes; then
 	AS_IF([test "$LVMPOLLD" = no], [AC_MSG_ERROR([cannot build lvmlockd with --disable-lvmpolld.])])
-	AS_IF([test "$LVMETAD" = no], [AC_MSG_ERROR([cannot build lvmlockd with --disable-lvmetad.])])
 	AS_IF([test "$BUILD_LVMPOLLD" = no], [BUILD_LVMPOLLD=yes; AC_MSG_WARN([Enabling lvmpolld - required by lvmlockd.])])
-	AS_IF([test "$BUILD_LVMETAD" = no], [BUILD_LVMETAD=yes; AC_MSG_WARN([Enabling lvmetad - required by lvmlockd.])])
 	AC_MSG_CHECKING([defaults for use_lvmlockd])
 	AC_ARG_ENABLE(use_lvmlockd,
 		      AC_HELP_STRING([--disable-use-lvmlockd],
@@ -936,33 +923,6 @@ AC_DEFINE_UNQUOTED(DEFAULT_USE_LVMLOCKD, [$DEFAULT_USE_LVMLOCKD],
 		   [Use lvmlockd by default.])
 
 ################################################################################
-dnl -- Check lvmetad
-if test "$BUILD_LVMETAD" = yes; then
-	AC_MSG_CHECKING([defaults for use_lvmetad])
-	AC_ARG_ENABLE(use_lvmetad,
-		      AC_HELP_STRING([--disable-use-lvmetad],
-				     [disable usage of LVM Metadata Daemon]),
-		      [case ${enableval} in
-		       yes) DEFAULT_USE_LVMETAD=1 ;;
-		       *) DEFAULT_USE_LVMETAD=0 ;;
-		       esac], DEFAULT_USE_LVMETAD=1)
-	AC_MSG_RESULT($DEFAULT_USE_LVMETAD)
-	AC_DEFINE([LVMETAD_SUPPORT], 1, [Define to 1 to include code that uses lvmetad.])
-
-	AC_ARG_WITH(lvmetad-pidfile,
-		    AC_HELP_STRING([--with-lvmetad-pidfile=PATH],
-				   [lvmetad pidfile [PID_DIR/lvmetad.pid]]),
-		    LVMETAD_PIDFILE=$withval,
-		    LVMETAD_PIDFILE="$DEFAULT_PID_DIR/lvmetad.pid")
-	AC_DEFINE_UNQUOTED(LVMETAD_PIDFILE, ["$LVMETAD_PIDFILE"],
-			   [Path to lvmetad pidfile.])
-else
-	DEFAULT_USE_LVMETAD=0
-fi
-AC_DEFINE_UNQUOTED(DEFAULT_USE_LVMETAD, [$DEFAULT_USE_LVMETAD],
-		   [Use lvmetad by default.])
-
-################################################################################
 dnl -- Check lvmpolld
 if test "$BUILD_LVMPOLLD" = yes; then
 	AC_MSG_CHECKING([defaults for use_lvmpolld])
@@ -1662,7 +1622,6 @@ AC_SUBST(BLKID_PC)
 AC_SUBST(BUILD_CMIRRORD)
 AC_SUBST(BUILD_DMEVENTD)
 AC_SUBST(BUILD_LVMDBUSD)
-AC_SUBST(BUILD_LVMETAD)
 AC_SUBST(BUILD_LVMPOLLD)
 AC_SUBST(BUILD_LVMLOCKD)
 AC_SUBST(BUILD_LOCKDSANLOCK)
@@ -1699,7 +1658,6 @@ AC_SUBST(DEFAULT_SPARSE_SEGTYPE)
 AC_SUBST(DEFAULT_SYS_DIR)
 AC_SUBST(DEFAULT_SYS_LOCK_DIR)
 AC_SUBST(DEFAULT_USE_BLKID_WIPING)
-AC_SUBST(DEFAULT_USE_LVMETAD)
 AC_SUBST(DEFAULT_USE_LVMPOLLD)
 AC_SUBST(DEFAULT_USE_LVMLOCKD)
 AC_SUBST(DEVMAPPER)
@@ -1792,7 +1750,6 @@ AC_SUBST(VDO_INCLUDE)
 AC_SUBST(VDO_LIB)
 AC_SUBST(WRITE_INSTALL)
 AC_SUBST(DMEVENTD_PIDFILE)
-AC_SUBST(LVMETAD_PIDFILE)
 AC_SUBST(LVMPOLLD_PIDFILE)
 AC_SUBST(LVMLOCKD_PIDFILE)
 AC_SUBST(CMIRRORD_PIDFILE)
@@ -1832,7 +1789,6 @@ daemons/lvmdbusd/lvmdbusd
 daemons/lvmdbusd/lvmdb.py
 daemons/lvmdbusd/lvm_shell_proxy.py
 daemons/lvmdbusd/path.py
-daemons/lvmetad/Makefile
 daemons/lvmpolld/Makefile
 daemons/lvmlockd/Makefile
 conf/Makefile
@@ -1860,9 +1816,6 @@ scripts/dm_event_systemd_red_hat.service
 scripts/dm_event_systemd_red_hat.socket
 scripts/lvm2_cmirrord_systemd_red_hat.service
 scripts/lvm2_lvmdbusd_systemd_red_hat.service
-scripts/lvm2_lvmetad_init_red_hat
-scripts/lvm2_lvmetad_systemd_red_hat.service
-scripts/lvm2_lvmetad_systemd_red_hat.socket
 scripts/lvm2_lvmpolld_init_red_hat
 scripts/lvm2_lvmpolld_systemd_red_hat.service
 scripts/lvm2_lvmpolld_systemd_red_hat.socket
diff --git a/daemons/lvmetad/.gitignore b/daemons/lvmetad/.gitignore
deleted file mode 100644
index 773097e..0000000
--- a/daemons/lvmetad/.gitignore
+++ /dev/null
@@ -1,2 +0,0 @@
-lvmetad
-lvmetactl
diff --git a/daemons/lvmetad/Makefile.in b/daemons/lvmetad/Makefile.in
deleted file mode 100644
index 5738bbe..0000000
--- a/daemons/lvmetad/Makefile.in
+++ /dev/null
@@ -1,64 +0,0 @@
-#
-# Copyright (C) 2011-2012 Red Hat, Inc.
-#
-# This file is part of LVM2.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU Lesser General Public License v.2.1.
-#
-# You should have received a copy of the GNU Lesser General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-srcdir = @srcdir@
-top_srcdir = @top_srcdir@
-top_builddir = @top_builddir@
-
-SOURCES = lvmetad-core.c
-SOURCES2 = lvmetactl.c
-
-TARGETS = lvmetad lvmetactl
-
-.PHONY: install_lvmetad
-
-CFLOW_LIST = $(SOURCES)
-CFLOW_LIST_TARGET = $(LIB_NAME).cflow
-CFLOW_TARGET = lvmetad
-
-include $(top_builddir)/make.tmpl
-
-CFLAGS_lvmetactl.o += $(EXTRA_EXEC_CFLAGS)
-CFLAGS_lvmetad-core.o += $(EXTRA_EXEC_CFLAGS)
-INCLUDES += -I$(top_srcdir)/libdaemon/server
-LDFLAGS += -L$(top_builddir)/libdaemon/server $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS)
-LIBS += $(RT_LIBS) $(DAEMON_LIBS) $(PTHREAD_LIBS) -lm
-
-lvmetad: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
-		    $(top_builddir)/libdaemon/server/libdaemonserver.a \
-		    $(INTERNAL_LIBS)
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) -ldaemonserver $(INTERNAL_LIBS) $(LIBS)
-
-lvmetactl: lvmetactl.o $(top_builddir)/libdaemon/client/libdaemonclient.a \
-	$(top_builddir)/libdaemon/server/libdaemonserver.a \
-	$(INTERNAL_LIBS)
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ lvmetactl.o $(INTERNAL_LIBS) $(LIBS)
-
-CLEAN_TARGETS += lvmetactl.o
-
-# TODO: No idea. No idea how to test either.
-#ifneq ("$(CFLOW_CMD)", "")
-#CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
-#-include $(top_builddir)/libdm/libdevmapper.cflow
-#-include $(top_builddir)/lib/liblvm-internal.cflow
-#-include $(top_builddir)/lib/liblvm2cmd.cflow
-#-include $(top_builddir)/daemons/dmeventd/$(LIB_NAME).cflow
-#-include $(top_builddir)/daemons/dmeventd/plugins/mirror/$(LIB_NAME)-lvm2mirror.cflow
-#endif
-
-install_lvmetad: lvmetad
-	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
-
-install_lvm2: install_lvmetad
-
-install: install_lvm2
diff --git a/daemons/lvmetad/lvmetactl.c b/daemons/lvmetad/lvmetactl.c
deleted file mode 100644
index 7805409..0000000
--- a/daemons/lvmetad/lvmetactl.c
+++ /dev/null
@@ -1,249 +0,0 @@
-/*
- * Copyright (C) 2014 Red Hat, Inc.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU Lesser General Public License v.2.1.
- */
-
-#include "tools/tool.h"
-
-#include "daemons/lvmetad/lvmetad-client.h"
-
-daemon_handle h;
-
-static void print_reply(daemon_reply reply)
-{
-	const char *a = daemon_reply_str(reply, "response", NULL);
-	const char *b = daemon_reply_str(reply, "status", NULL);
-	const char *c = daemon_reply_str(reply, "reason", NULL);
-
-	printf("response \"%s\" status \"%s\" reason \"%s\"\n",
-	       a ? a : "", b ? b : "", c ? c : "");
-}
-
-int main(int argc, char **argv)
-{
-	daemon_reply reply;
-	char *cmd;
-	char *uuid;
-	char *name;
-	int val;
-	int ver;
-
-	if (argc < 2) {
-		printf("lvmetactl dump\n");
-		printf("lvmetactl pv_list\n");
-		printf("lvmetactl vg_list\n");
-		printf("lvmetactl get_global_info\n");
-		printf("lvmetactl vg_lookup_name <name>\n");
-		printf("lvmetactl vg_lookup_uuid <uuid>\n");
-		printf("lvmetactl pv_lookup_uuid <uuid>\n");
-		printf("lvmetactl set_global_invalid 0|1\n");
-		printf("lvmetactl set_global_disable 0|1\n");
-		printf("lvmetactl set_vg_version <uuid> <name> <version>\n");
-		printf("lvmetactl vg_lock_type <uuid>\n");
-		return -1;
-	}
-
-	cmd = argv[1];
-
-	h = lvmetad_open(NULL);
-
-	if (!strcmp(cmd, "dump")) {
-		reply = daemon_send_simple(h, "dump",
-					   "token = %s", "skip",
-					   "pid = " FMTd64, (int64_t)getpid(),
-					   "cmd = %s", "lvmetactl",
-					   NULL);
-		printf("%s\n", reply.buffer.mem);
-
-	} else if (!strcmp(cmd, "pv_list")) {
-		reply = daemon_send_simple(h, "pv_list",
-					   "token = %s", "skip",
-					   "pid = " FMTd64, (int64_t)getpid(),
-					   "cmd = %s", "lvmetactl",
-					   NULL);
-		printf("%s\n", reply.buffer.mem);
-
-	} else if (!strcmp(cmd, "vg_list")) {
-		reply = daemon_send_simple(h, "vg_list",
-					   "token = %s", "skip",
-					   "pid = " FMTd64, (int64_t)getpid(),
-					   "cmd = %s", "lvmetactl",
-					   NULL);
-		printf("%s\n", reply.buffer.mem);
-
-	} else if (!strcmp(cmd, "get_global_info")) {
-		reply = daemon_send_simple(h, "get_global_info",
-					   "token = %s", "skip",
-					   "pid = " FMTd64, (int64_t)getpid(),
-					   "cmd = %s", "lvmetactl",
-					   NULL);
-		printf("%s\n", reply.buffer.mem);
-
-	} else if (!strcmp(cmd, "set_global_invalid")) {
-		if (argc < 3) {
-			printf("set_global_invalid 0|1\n");
-			return -1;
-		}
-		val = atoi(argv[2]);
-
-		reply = daemon_send_simple(h, "set_global_info",
-					   "global_invalid = " FMTd64, (int64_t) val,
-					   "token = %s", "skip",
-					   "pid = " FMTd64, (int64_t)getpid(),
-					   "cmd = %s", "lvmetactl",
-					   NULL);
-		print_reply(reply);
-
-	} else if (!strcmp(cmd, "set_global_disable")) {
-		if (argc < 3) {
-			printf("set_global_disable 0|1\n");
-			return -1;
-		}
-		val = atoi(argv[2]);
-
-		reply = daemon_send_simple(h, "set_global_info",
-					   "global_disable = " FMTd64, (int64_t) val,
-					   "disable_reason = %s", LVMETAD_DISABLE_REASON_DIRECT,
-					   "token = %s", "skip",
-					   "pid = " FMTd64, (int64_t)getpid(),
-					   "cmd = %s", "lvmetactl",
-					   NULL);
-		print_reply(reply);
-
-	} else if (!strcmp(cmd, "set_vg_version")) {
-		if (argc < 5) {
-			printf("set_vg_version <uuid> <name> <ver>\n");
-			return -1;
-		}
-		uuid = argv[2];
-		name = argv[3];
-		ver = atoi(argv[4]);
-
-		if ((strlen(uuid) == 1) && (uuid[0] == '-'))
-			uuid = NULL;
-		if ((strlen(name) == 1) && (name[0] == '-'))
-			name = NULL;
-
-		if (uuid && name) {
-			reply = daemon_send_simple(h, "set_vg_info",
-						   "uuid = %s", uuid,
-						   "name = %s", name,
-						   "version = " FMTd64, (int64_t) ver,
-						   "token = %s", "skip",
-						   "pid = " FMTd64, (int64_t)getpid(),
-						   "cmd = %s", "lvmetactl",
-						   NULL);
-		} else if (uuid) {
-			reply = daemon_send_simple(h, "set_vg_info",
-						   "uuid = %s", uuid,
-						   "version = " FMTd64, (int64_t) ver,
-						   "token = %s", "skip",
-						   "pid = " FMTd64, (int64_t)getpid(),
-						   "cmd = %s", "lvmetactl",
-						   NULL);
-		} else if (name) {
-			reply = daemon_send_simple(h, "set_vg_info",
-						   "name = %s", name,
-						   "version = " FMTd64, (int64_t) ver,
-						   "token = %s", "skip",
-						   "pid = " FMTd64, (int64_t)getpid(),
-						   "cmd = %s", "lvmetactl",
-						   NULL);
-		} else {
-			printf("name or uuid required\n");
-			return -1;
-		}
-
-		print_reply(reply);
-
-	} else if (!strcmp(cmd, "vg_lookup_name")) {
-		if (argc < 3) {
-			printf("vg_lookup_name <name>\n");
-			return -1;
-		}
-		name = argv[2];
-
-		reply = daemon_send_simple(h, "vg_lookup",
-					   "name = %s", name,
-					   "token = %s", "skip",
-					   "pid = " FMTd64, (int64_t)getpid(),
-					   "cmd = %s", "lvmetactl",
-					   NULL);
-		printf("%s\n", reply.buffer.mem);
-
-	} else if (!strcmp(cmd, "vg_lookup_uuid")) {
-		if (argc < 3) {
-			printf("vg_lookup_uuid <uuid>\n");
-			return -1;
-		}
-		uuid = argv[2];
-
-		reply = daemon_send_simple(h, "vg_lookup",
-					   "uuid = %s", uuid,
-					   "token = %s", "skip",
-					   "pid = " FMTd64, (int64_t)getpid(),
-					   "cmd = %s", "lvmetactl",
-					   NULL);
-		printf("%s\n", reply.buffer.mem);
-
-	} else if (!strcmp(cmd, "vg_lock_type")) {
-		struct dm_config_node *metadata;
-		const char *lock_type;
-
-		if (argc < 3) {
-			printf("vg_lock_type <uuid>\n");
-			return -1;
-		}
-		uuid = argv[2];
-
-		reply = daemon_send_simple(h, "vg_lookup",
-					   "uuid = %s", uuid,
-					   "token = %s", "skip",
-					   "pid = " FMTd64, (int64_t)getpid(),
-					   "cmd = %s", "lvmetactl",
-					   NULL);
-		/* printf("%s\n", reply.buffer.mem); */
-
-		metadata = dm_config_find_node(reply.cft->root, "metadata");
-		if (!metadata) {
-			printf("no metadata\n");
-			goto out;
-		}
-
-		lock_type = dm_config_find_str(metadata, "metadata/lock_type", NULL);
-		if (!lock_type) {
-			printf("no lock_type\n");
-			goto out;
-		}
-		printf("lock_type %s\n", lock_type);
-
-	} else if (!strcmp(cmd, "pv_lookup_uuid")) {
-		if (argc < 3) {
-			printf("pv_lookup_uuid <uuid>\n");
-			return -1;
-		}
-		uuid = argv[2];
-
-		reply = daemon_send_simple(h, "pv_lookup",
-					   "uuid = %s", uuid,
-					   "token = %s", "skip",
-					   "pid = " FMTd64, (int64_t)getpid(),
-					   "cmd = %s", "lvmetactl",
-					   NULL);
-		printf("%s\n", reply.buffer.mem);
-
-	} else {
-		printf("unknown command\n");
-		goto out_close;
-	}
-out:
-	daemon_reply_destroy(reply);
-out_close:
-	daemon_close(h);
-	return 0;
-}
diff --git a/daemons/lvmetad/lvmetad-client.h b/daemons/lvmetad/lvmetad-client.h
deleted file mode 100644
index a9d4d83..0000000
--- a/daemons/lvmetad/lvmetad-client.h
+++ /dev/null
@@ -1,90 +0,0 @@
-/*
- * Copyright (C) 2011-2012 Red Hat, Inc.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU Lesser General Public License v.2.1.
- *
- * You should have received a copy of the GNU Lesser General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#ifndef _LVM_LVMETAD_CLIENT_H
-#define _LVM_LVMETAD_CLIENT_H
-
-#include "libdaemon/client/daemon-client.h"
-
-#define LVMETAD_SOCKET DEFAULT_RUN_DIR "/lvmetad.socket"
-
-#define LVMETAD_TOKEN_UPDATE_IN_PROGRESS "update in progress"
-
-#define LVMETAD_DISABLE_REASON_DIRECT		"DIRECT"
-#define LVMETAD_DISABLE_REASON_DUPLICATES	"DUPLICATES"
-#define LVMETAD_DISABLE_REASON_VGRESTORE	"VGRESTORE"
-#define LVMETAD_DISABLE_REASON_REPAIR		"REPAIR"
-
-struct volume_group;
-
-/* Different types of replies we may get from lvmetad. */
-
-typedef struct {
-	daemon_reply r;
-	const char **uuids; /* NULL terminated array */
-} lvmetad_uuidlist;
-
-typedef struct {
-	daemon_reply r;
-	struct dm_config_tree *cft;
-} lvmetad_vg;
-
-/* Get a list of VG UUIDs that match a given VG name. */
-lvmetad_uuidlist lvmetad_lookup_vgname(daemon_handle h, const char *name);
-
-/* Get the metadata of a single VG, identified by UUID. */
-lvmetad_vg lvmetad_get_vg(daemon_handle h, const char *uuid);
-
-/*
- * Add and remove PVs on demand. Udev-driven systems will use this interface
- * instead of scanning.
- */
-daemon_reply lvmetad_add_pv(daemon_handle h, const char *pv_uuid, const char *mda_content);
-daemon_reply lvmetad_remove_pv(daemon_handle h, const char *pv_uuid);
-
-/* Trigger a full disk scan, throwing away all caches. XXX do we eventually want
- * this? Probably not yet, anyway.
- *     daemon_reply lvmetad_rescan(daemon_handle h);
- */
-
-/*
- * Update the version of metadata of a volume group. The VG has to be locked for
- * writing for this, and the VG metadata here has to match whatever has been
- * written to the disk (under this lock). This initially avoids the requirement
- * for lvmetad to write to disk (in later revisions, lvmetad_supersede_vg may
- * also do the writing, or we probably add another function to do that).
- */
-daemon_reply lvmetad_supersede_vg(daemon_handle h, struct volume_group *vg);
-
-/* Wrappers to open/close connection */
-
-static inline daemon_handle lvmetad_open(const char *socket)
-{
-	daemon_info lvmetad_info = {
-		.path = "lvmetad",
-		.socket = socket ?: LVMETAD_SOCKET,
-		.protocol = "lvmetad",
-		.protocol_version = 1,
-		.autostart = 0
-	};
-
-	return daemon_open(lvmetad_info);
-}
-
-static inline void lvmetad_close(daemon_handle h)
-{
-	return daemon_close(h);
-}
-
-#endif
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
deleted file mode 100644
index cd44be5..0000000
--- a/daemons/lvmetad/lvmetad-core.c
+++ /dev/null
@@ -1,3010 +0,0 @@
-/*
- * Copyright (C) 2012-2015 Red Hat, Inc.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU Lesser General Public License v.2.1.
- *
- * You should have received a copy of the GNU Lesser General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#define _XOPEN_SOURCE 500  /* pthread */
-
-#define _REENTRANT
-
-#include "tools/tool.h"
-
-#include "libdaemon/client/daemon-io.h"
-#include "daemon-server.h"
-#include "daemon-log.h"
-#include "lvm-version.h"
-#include "daemons/lvmetad/lvmetad-client.h"
-
-#include <assert.h>
-#include <errno.h>
-#include <pthread.h>
-
-#define LVMETAD_SOCKET DEFAULT_RUN_DIR "/lvmetad.socket"
-
-/*
- * cache states:
- * . Empty: no devices visible to the system have been added to lvmetad
- * . Scanning: some devices visible to the system have been added to lvmetad
- * . Initialized: all devices visible to the system have been added to lvmetad
- * . Outdated: event on system or storage is not yet processed by lvmetad
- *   Outdated variations:
- *   - MissingDev: device added to system, not yet added to lvmetad
- *   - RemovedDev: device removed from system, not yet removed from lvmetad
- *   - MissingVG: new vg is written on disk, not yet added to lvmetad
- *   - RemovedVG: vg is removed on disk, not yet removed in lvmetad
- *   - ChangedVG: vg metadata is changed on disk, not yet updated in lvmetad
- *   - MissingPV: new pv is written on disk, not yet added to in lvmetad
- *   - RemovedPV: pv is removed on disk, not yet removed in lvmetad
- *   - ChangedPV: pv metadata is changed on disk, not yet updated in lvmetad
- * . Updated: events have been processed by lvmetad
- *
- * state transitions:
- * . Empty -> Scanning
- * . Scanning -> Initialized
- * . Initialized -> Scanning
- * . Initialized -> Outdated
- * . Outdated -> Updated
- * . Updated -> Outdated
- * . Updated -> Scanning
- * . Outdated -> Scanning
- *
- * state transitions caused by:
- * . Empty is caused by:
- *   - starting/restarting lvmetad
- * . Scanning is caused by:
- *   - running pvscan --cache
- *   - running any command with different global_filter (token mismatch)
- *   - running any command while lvmetad is Empty
- *   - running a report/display command with --foreign
- *   - running a report/display command with --shared
- *   - running a command using lvmlockd global lock where global state is changed
- * . Initialized is caused by:
- *   - completion of Scanning
- * . Outdated is caused by:
- *   - device being added or removed on the system
- *   - creating/removing/changing a VG
- *   - creating/removing/changing a PV
- * . Updated is caused by:
- *   - receiving and processing all events
- *
- * request handling:
- * . Empty: short period during startup, token error returned
- * . Scanning: should be very short, lvmetad responds to requests with
- *   the token error "updating"
- * . Initialized: lvmetad responds to requests
- * . Updated: lvmetad responds to requests
- * . Outdated: should be very short, lvmetad responds to requests
- *
- * In general, the cache state before and after the transition
- * "Updated -> Scanning -> Initialized" should match, unless
- * events occur during that transition.
- *
- * The Scanning state includes:
- * . receive a request to set the token to "updating" (Scanning state begins.)
- * . receive a pv_clear_all request to clear current cache
- * . receive a number of pv_found events to repopulate cache
- * . receive a request to set the token to a hash value (Initialized state begins.)
- *
- * The transition from Outdated to Updated depends on lvm commands
- * sending events to lvmetad, i.e. pv_found, pv_gone, vg_update,
- * vg_remove.  Prior to receiving these events, lvmetad is not aware
- * that it is in the Outdated state.
- *
- * When using a shared VG with lvmlockd, the Outdated state can last a
- * longer time, but it won't be used in that state.  lvmlockd forces a
- * transition "Outdated -> Scanning -> Initialized" before the cache
- * is used.
- */
-
-
-/*
- * valid/invalid state of cached metadata
- *
- * Normally when using lvmetad, the state is kept up-to-date through a
- * combination of notifications from clients and updates triggered by uevents.
- * When using lvmlockd, the lvmetad state is expected to become out of
- * date (invalid/stale) when other hosts make changes to the metadata on disk.
- *
- * To deal with this, the metadata cached in lvmetad can be flagged as invalid.
- * This invalid flag is returned along with the metadata when read by a
- * command.  The command can check for the invalid flag and decide that it
- * should either use the stale metadata (uncommon), or read the latest metadata
- * from disk rather than using the invalid metadata that was returned.  If the
- * command reads the latest metadata from disk, it can choose to send it to
- * lvmetad to update the cached copy and clear the invalid flag in lvmetad.
- * Otherwise, the next command to read the metadata from lvmetad will also
- * receive the invalid metadata with the invalid flag (and like the previous
- * command, it too may choose to read the latest metadata from disk and can
- * then also choose to update the lvmetad copy.)
- *
- * For purposes of tracking the invalid state, LVM metadata is considered
- * to be either VG-specific or global.  VG-specific metadata is metadata
- * that is isolated to a VG, such as the LVs it contains.  Global
- * metadata is metadata that is not isolated to a single VG.  Global
- * metdata includes:
- * . the VG namespace (which VG names are used)
- * . the set of orphan PVs (which PVs are in VGs and which are not)
- * . properties of orphan PVs (the size of an orphan PV)
- *
- * If the metadata for a single VG becomes invalid, the VGFL_INVALID
- * flag can be set in the vg_info struct for that VG.  If the global
- * metdata becomes invalid, the GLFL_INVALID flag can be set in the
- * lvmetad daemon state.
- *
- * If a command reads VG metadata and VGFL_INVALID is set, an
- * extra config node called "vg_invalid" is added to the config
- * data returned to the command.
- *
- * If a command reads global metdata and GLFL_INVALID is set, an
- * extra config node called "global_invalid" is added to the
- * config data returned to the command.
- *
- * If a command sees vg_invalid, and wants the latest VG metadata,
- * it only needs to scan disks of the PVs in that VG.
- * It can then use vg_update to send the latest metadata to lvmetad
- * which clears the VGFL_INVALID flag.
- *
- * If a command sees global_invalid, and wants the latest metadata,
- * it should scan all devices to update lvmetad, and then send
- * lvmetad the "set_global_info global_invalid=0" message to clear
- * GLFL_INVALID.
- *
- * (When rescanning devices to update lvmetad, the command must use
- * the global filter cmd->lvmetad_filter so that it processes the same
- * devices that are seen by lvmetad.)
- *
- * The lvmetad INVALID flags can be set by sending lvmetad the messages:
- *
- * . set_vg_info with the latest VG seqno.  If the VG seqno is larger
- *   than the cached VG seqno, VGFL_INVALID is set for the VG.
- *
- * . set_global_info with global_invalid=1 sets GLFL_INVALID.
- *
- * Different entities could use these functions to invalidate metadata
- * if/when they detected that the cache is stale.  How they detect that
- * the cache is stale depends on the details of the specific entity.
- *
- * In the case of lvmlockd, it embeds values into its locks to keep track
- * of when other nodes have changed metadata on disk related to those locks.
- * When acquring locks it can look at these values and detect that
- * the metadata associated with the lock has been changed.
- * When the values change, it uses set_vg_info/set_global_info to
- * invalidate the lvmetad cache.
- *
- * The values that lvmlockd distributes through its locks are the
- * latest VG seqno in VG locks and a global counter in the global lock.
- * When a host acquires a VG lock and sees that the embedded seqno is
- * larger than it was previously, it knows that it should invalidate the
- * lvmetad cache for the VG.  If the host acquires the global lock
- * and sees that the counter is larger than previously, it knows that
- * it should invalidate the global info in lvmetad.  This invalidation
- * is done before the lock is returned to the command.  This way the
- * invalid flag will be set on the metadata before the command reads
- * it from lvmetad.
- */
-
-struct vg_info {
-	int64_t external_version;
-	uint32_t flags; /* VGFL_ */
-};
-
-#define GLFL_INVALID                   0x00000001
-#define GLFL_DISABLE                   0x00000002
-#define GLFL_DISABLE_REASON_DIRECT     0x00000004
-				    /* 0x00000008 */
-#define GLFL_DISABLE_REASON_DUPLICATES 0x00000010
-#define GLFL_DISABLE_REASON_VGRESTORE  0x00000020
-#define GLFL_DISABLE_REASON_REPAIR     0x00000040
-
-#define GLFL_DISABLE_REASON_ALL (GLFL_DISABLE_REASON_DIRECT | GLFL_DISABLE_REASON_REPAIR | GLFL_DISABLE_REASON_DUPLICATES | GLFL_DISABLE_REASON_VGRESTORE)
-
-#define VGFL_INVALID 0x00000001
-
-#define CMD_NAME_SIZE 32
-
-typedef struct {
-	daemon_idle *idle;
-	log_state *log; /* convenience */
-	const char *log_config;
-
-	struct dm_hash_table *pvid_to_pvmeta;
-	struct dm_hash_table *device_to_pvid; /* shares locks with above */
-
-	struct dm_hash_table *vgid_to_metadata;
-	struct dm_hash_table *vgid_to_vgname;
-	struct dm_hash_table *vgid_to_outdated_pvs;
-	struct dm_hash_table *vgid_to_info;
-	struct dm_hash_table *vgname_to_vgid;
-	struct dm_hash_table *pvid_to_vgid;
-	char token[128];
-	char update_cmd[CMD_NAME_SIZE];
-	int update_pid;
-	int update_timeout;
-	uint64_t update_begin;
-	uint32_t flags; /* GLFL_ */
-	pthread_mutex_t token_lock;
-	pthread_mutex_t info_lock;
-	pthread_rwlock_t cache_lock;
-} lvmetad_state;
-
-static uint64_t _monotonic_seconds(void)
-{
-	struct timespec ts;
-
-	if (clock_gettime(CLOCK_MONOTONIC, &ts) < 0)
-		return 0;
-	return ts.tv_sec;
-}
-
-static void destroy_metadata_hashes(lvmetad_state *s)
-{
-	struct dm_hash_node *n = NULL;
-
-	dm_hash_iterate(n, s->vgid_to_metadata)
-		dm_config_destroy(dm_hash_get_data(s->vgid_to_metadata, n));
-
-	dm_hash_iterate(n, s->vgid_to_outdated_pvs)
-		dm_config_destroy(dm_hash_get_data(s->vgid_to_outdated_pvs, n));
-
-	dm_hash_iterate(n, s->pvid_to_pvmeta)
-		dm_config_destroy(dm_hash_get_data(s->pvid_to_pvmeta, n));
-
-	dm_hash_iterate(n, s->vgid_to_vgname)
-		free(dm_hash_get_data(s->vgid_to_vgname, n));
-
-	dm_hash_iterate(n, s->vgname_to_vgid)
-		free(dm_hash_get_data(s->vgname_to_vgid, n));
-
-	dm_hash_iterate(n, s->vgid_to_info)
-		free(dm_hash_get_data(s->vgid_to_info, n));
-
-	dm_hash_iterate(n, s->device_to_pvid)
-		free(dm_hash_get_data(s->device_to_pvid, n));
-
-	dm_hash_iterate(n, s->pvid_to_vgid)
-		free(dm_hash_get_data(s->pvid_to_vgid, n));
-
-	dm_hash_destroy(s->pvid_to_pvmeta);
-	dm_hash_destroy(s->vgid_to_metadata);
-	dm_hash_destroy(s->vgid_to_vgname);
-	dm_hash_destroy(s->vgid_to_outdated_pvs);
-	dm_hash_destroy(s->vgid_to_info);
-	dm_hash_destroy(s->vgname_to_vgid);
-
-	dm_hash_destroy(s->device_to_pvid);
-	dm_hash_destroy(s->pvid_to_vgid);
-}
-
-static void create_metadata_hashes(lvmetad_state *s)
-{
-	s->pvid_to_pvmeta = dm_hash_create(32);
-	s->device_to_pvid = dm_hash_create(32);
-	s->vgid_to_metadata = dm_hash_create(32);
-	s->vgid_to_vgname = dm_hash_create(32);
-	s->vgid_to_outdated_pvs = dm_hash_create(32);
-	s->vgid_to_info = dm_hash_create(32);
-	s->pvid_to_vgid = dm_hash_create(32);
-	s->vgname_to_vgid = dm_hash_create(32);
-}
-
-static response reply_fail(const char *reason)
-{
-	return daemon_reply_simple("failed", "reason = %s", reason, NULL);
-}
-
-static response reply_unknown(const char *reason)
-{
-	return daemon_reply_simple("unknown", "reason = %s", reason, NULL);
-}
-
-static struct dm_config_node *pvs(struct dm_config_node *vg)
-{
-	struct dm_config_node *pv = dm_config_find_node(vg, "metadata/physical_volumes");
-	if (pv)
-		pv = pv->child;
-	return pv;
-}
-
-static void filter_metadata(struct dm_config_node *vg) {
-	struct dm_config_node *pv = pvs(vg);
-	while (pv) {
-		struct dm_config_node *item = pv->child;
-		while (item) {
-			/* Remove the advisory device nodes. */
-			if (item->sib && !strcmp(item->sib->key, "device"))
-				item->sib = item->sib->sib;
-			item = item->sib;
-		}
-		pv = pv->sib;
-	}
-	vg->sib = NULL; /* Drop any trailing garbage. */
-}
-
-static void merge_pvmeta(struct dm_config_node *pv, struct dm_config_node *pvmeta)
-{
-	struct dm_config_node *tmp;
-
-	if (!pvmeta)
-		return;
-
-	tmp = pvmeta;
-	while (tmp->sib) {
-		/* drop the redundant ID and dev_size nodes */
-		if (!strcmp(tmp->sib->key, "id") || !strcmp(tmp->sib->key, "dev_size"))
-			tmp->sib = tmp->sib->sib;
-		if (!tmp->sib) break;
-		tmp = tmp->sib;
-		tmp->parent = pv;
-	}
-	tmp->sib = pv->child;
-	pv->child = pvmeta;
-	pvmeta->parent = pv;
-}
-
-/*
- * Either the "big" vgs lock, or a per-vg lock needs to be held before entering
- * this function.
- *
- * cft and vg is data being sent to the caller.
- */
-
-static int update_pv_status(lvmetad_state *s,
-			    struct dm_config_tree *cft,
-			    struct dm_config_node *vg)
-{
-	struct dm_config_node *pv;
-	const char *uuid;
-	struct dm_config_tree *pvmeta;
-	struct dm_config_node *pvmeta_cn;
-	int ret = 1;
-
-	for (pv = pvs(vg); pv; pv = pv->sib) {
-		if (!(uuid = dm_config_find_str(pv->child, "id", NULL))) {
-			ERROR(s, "update_pv_status found no uuid for PV");
-			continue;
-		}
-
-		pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, uuid);
-
-		set_flag(cft, pv, "status", "MISSING", !pvmeta);
-
-		if (pvmeta) {
-			if (!(pvmeta_cn = dm_config_clone_node(cft, pvmeta->root->child, 1))) {
-				ERROR(s, "update_pv_status out of memory");
-				ret = 0;
-				goto out;
-			}
-
-			merge_pvmeta(pv, pvmeta_cn);
-		}
-	}
-out:
-	return ret;
-}
-
-static struct dm_config_node *add_last_node(struct dm_config_tree *cft, const char *node_name)
-{
-	struct dm_config_node *cn, *last;
-
-	cn = cft->root;
-	last = cn;
-
-	while (cn->sib) {
-		last = cn->sib;
-		cn = last;
-	}
-
-	cn = dm_config_create_node(cft, node_name);
-	if (!cn)
-		return NULL;
-
-	cn->v = NULL;
-	cn->sib = NULL;
-	cn->parent = cft->root;
-	last->sib = cn;
-
-	return cn;
-}
-
-static struct dm_config_node *make_pv_node(lvmetad_state *s, const char *pvid,
-					   struct dm_config_tree *cft,
-					   struct dm_config_node *parent,
-					   struct dm_config_node *pre_sib)
-{
-	struct dm_config_tree *pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, pvid);
-	const char *vgid = dm_hash_lookup(s->pvid_to_vgid, pvid), *vgname = NULL;
-	struct dm_config_node *pv;
-	struct dm_config_node *cn = NULL;
-
-	if (!pvmeta)
-		return NULL;
-
-	if (vgid) {
-		vgname = dm_hash_lookup(s->vgid_to_vgname, vgid);
-	}
-
-	/* Nick the pvmeta config tree. */
-	if (!(pv = dm_config_clone_node(cft, pvmeta->root, 0)))
-		return 0;
-
-	if (pre_sib)
-		pre_sib->sib = pv;
-	if (parent && !parent->child)
-		parent->child = pv;
-	pv->parent = parent;
-	pv->key = pvid;
-
-	/* Add the "variable" bits to it. */
-
-	if (vgid && strcmp(vgid, "#orphan"))
-		cn = make_text_node(cft, "vgid", vgid, pv, cn);
-	if (vgname)
-		cn = make_text_node(cft, "vgname", vgname, pv, cn);
-
-	return pv;
-}
-
-static response pv_list(lvmetad_state *s, request r)
-{
-	struct dm_config_node *cn = NULL, *cn_pvs;
-	struct dm_hash_node *n;
-	const char *id;
-	response res = { 0 };
-
-	DEBUGLOG(s, "pv_list");
-
-	buffer_init( &res.buffer );
-
-	if (!(res.cft = dm_config_create()))
-		return res; /* FIXME error reporting */
-
-	/* The response field */
-	if (!(res.cft->root = make_text_node(res.cft, "response", "OK", NULL, NULL)))
-		return res; /* FIXME doomed */
-
-	cn_pvs = make_config_node(res.cft, "physical_volumes", NULL, res.cft->root);
-
-	dm_hash_iterate(n, s->pvid_to_pvmeta) {
-		id = dm_hash_get_key(s->pvid_to_pvmeta, n);
-		cn = make_pv_node(s, id, res.cft, cn_pvs, cn);
-	}
-
-	if (s->flags & GLFL_INVALID)
-		add_last_node(res.cft, "global_invalid");
-
-	return res;
-}
-
-static response pv_lookup(lvmetad_state *s, request r)
-{
-	const char *pvid = daemon_request_str(r, "uuid", NULL);
-	int64_t devt = daemon_request_int(r, "device", 0);
-	response res = { 0 };
-	struct dm_config_node *pv;
-
-	DEBUGLOG(s, "pv_lookup pvid %s", pvid);
-
-	buffer_init( &res.buffer );
-
-	if (!pvid && !devt)
-		return reply_fail("need PVID or device");
-
-	if (!(res.cft = dm_config_create()))
-		return reply_fail("out of memory");
-
-	if (!(res.cft->root = make_text_node(res.cft, "response", "OK", NULL, NULL)))
-		return reply_fail("out of memory");
-
-	if (!pvid && devt)
-		pvid = dm_hash_lookup_binary(s->device_to_pvid, &devt, sizeof(devt));
-
-	if (!pvid) {
-		WARN(s, "pv_lookup: could not find device %" PRIu64, devt);
-		dm_config_destroy(res.cft);
-		return reply_unknown("device not found");
-	}
-
-	pv = make_pv_node(s, pvid, res.cft, NULL, res.cft->root);
-	if (!pv) {
-		dm_config_destroy(res.cft);
-		return reply_unknown("PV not found");
-	}
-
-	pv->key = "physical_volume";
-
-	if (s->flags & GLFL_INVALID)
-		add_last_node(res.cft, "global_invalid");
-
-	return res;
-}
-
-static response vg_list(lvmetad_state *s, request r)
-{
-	struct dm_config_node *cn, *cn_vgs, *cn_last = NULL;
-	struct dm_hash_node *n;
-	const char *id;
-	const char *name;
-	response res = { 0 };
-
-	DEBUGLOG(s, "vg_list");
-
-	buffer_init( &res.buffer );
-
-	if (!(res.cft = dm_config_create()))
-                goto bad; /* FIXME: better error reporting */
-
-	/* The response field */
-	res.cft->root = cn = dm_config_create_node(res.cft, "response");
-	if (!cn)
-                goto bad; /* FIXME */
-	cn->parent = res.cft->root;
-	if (!(cn->v = dm_config_create_value(res.cft)))
-		goto bad; /* FIXME */
-
-	cn->v->type = DM_CFG_STRING;
-	cn->v->v.str = "OK";
-
-	cn_vgs = cn = cn->sib = dm_config_create_node(res.cft, "volume_groups");
-	if (!cn_vgs)
-		goto bad; /* FIXME */
-
-	cn->parent = res.cft->root;
-	cn->v = NULL;
-	cn->child = NULL;
-
-	dm_hash_iterate(n, s->vgid_to_vgname) {
-		id = dm_hash_get_key(s->vgid_to_vgname, n),
-		name = dm_hash_get_data(s->vgid_to_vgname, n);
-
-		if (!(cn = dm_config_create_node(res.cft, id)))
-			goto bad; /* FIXME */
-
-		if (cn_last)
-			cn_last->sib = cn;
-
-		cn->parent = cn_vgs;
-		cn->sib = NULL;
-		cn->v = NULL;
-
-		if (!(cn->child = dm_config_create_node(res.cft, "name")))
-			goto bad; /* FIXME */
-
-		cn->child->parent = cn;
-		cn->child->sib = 0;
-		if (!(cn->child->v = dm_config_create_value(res.cft)))
-			goto bad; /* FIXME */
-
-		cn->child->v->type = DM_CFG_STRING;
-		cn->child->v->v.str = name;
-
-		if (!cn_vgs->child)
-			cn_vgs->child = cn;
-		cn_last = cn;
-	}
-
-	if (s->flags & GLFL_INVALID)
-		add_last_node(res.cft, "global_invalid");
-bad:
-	return res;
-}
-
-static void mark_outdated_pv(lvmetad_state *s, const char *vgid, const char *pvid)
-{
-	struct dm_config_tree *pvmeta, *outdated_pvs;
-	struct dm_config_node *list, *cft_vgid;
-	struct dm_config_value *v;
-
-	pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, pvid);
-
-	/* if the MDA exists and is used, it will have ignore=0 set */
-	if (!pvmeta ||
-	    (dm_config_find_int64(pvmeta->root, "pvmeta/mda0/ignore", 1) &&
-	     dm_config_find_int64(pvmeta->root, "pvmeta/mda1/ignore", 1)))
-		return;
-
-	ERROR(s, "PV %s has outdated metadata for VG %s", pvid, vgid);
-
-	outdated_pvs = dm_hash_lookup(s->vgid_to_outdated_pvs, vgid);
-	if (!outdated_pvs) {
-		if (!(outdated_pvs = config_tree_from_string_without_dup_node_check("outdated_pvs/pv_list = []")) ||
-		    !(cft_vgid = make_text_node(outdated_pvs, "vgid", dm_pool_strdup(outdated_pvs->mem, vgid),
-						outdated_pvs->root, NULL)))
-			abort();
-		if (!dm_hash_insert(s->vgid_to_outdated_pvs, cft_vgid->v->v.str, outdated_pvs))
-			abort();
-		DEBUGLOG(s, "created outdated_pvs list for VG %s", vgid);
-	}
-
-	list = dm_config_find_node(outdated_pvs->root, "outdated_pvs/pv_list");
-	v = list->v;
-	while (v) {
-		if (v->type != DM_CFG_EMPTY_ARRAY && !strcmp(v->v.str, pvid))
-			return;
-		v = v->next;
-	}
-	if (!(v = dm_config_create_value(outdated_pvs)))
-		abort();
-	v->type = DM_CFG_STRING;
-	v->v.str = dm_pool_strdup(outdated_pvs->mem, pvid);
-	v->next = list->v;
-	list->v = v;
-}
-
-static void chain_outdated_pvs(lvmetad_state *s, const char *vgid, struct dm_config_tree *metadata_cft, struct dm_config_node *metadata)
-{
-	struct dm_config_tree *cft = dm_hash_lookup(s->vgid_to_outdated_pvs, vgid), *pvmeta;
-	struct dm_config_node *pv, *res, *out_pvs = cft ? dm_config_find_node(cft->root, "outdated_pvs/pv_list") : NULL;
-	struct dm_config_value *pvs_v = out_pvs ? out_pvs->v : NULL;
-	if (!pvs_v)
-		return;
-	if (!(res = make_config_node(metadata_cft, "outdated_pvs", metadata_cft->root, 0)))
-		return; /* oops */
-	res->sib = metadata->child;
-	metadata->child = res;
-	for (; pvs_v && pvs_v->type != DM_CFG_EMPTY_ARRAY; pvs_v = pvs_v->next) {
-		pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, pvs_v->v.str);
-		if (!pvmeta) {
-			WARN(s, "metadata for PV %s not found", pvs_v->v.str);
-			continue;
-		}
-		if (!(pv = dm_config_clone_node(metadata_cft, pvmeta->root, 0)))
-			continue;
-		pv->key = dm_config_find_str(pv, "pvmeta/id", NULL);
-		pv->sib = res->child;
-		res->child = pv;
-	}
-}
-
-static response vg_lookup(lvmetad_state *s, request r)
-{
-	struct dm_config_tree *cft;
-	struct dm_config_node *metadata, *n;
-	struct vg_info *info;
-	response res = { 0 };
-	const char *uuid = daemon_request_str(r, "uuid", NULL);
-	const char *name = daemon_request_str(r, "name", NULL);
-	int count = 0;
-
-	buffer_init( &res.buffer );
-
-	if (!uuid && !name) {
-		ERROR(s, "vg_lookup with no uuid or name");
-		return reply_unknown("VG not found");
-
-	} else if (!uuid || !name) {
-		DEBUGLOG(s, "vg_lookup vgid %s name %s needs lookup",
-			 uuid ?: "none", name ?: "none");
-
-		if (name && !uuid)
-			uuid = dm_hash_lookup_with_count(s->vgname_to_vgid, name, &count);
-		else if (uuid && !name)
-			name = dm_hash_lookup(s->vgid_to_vgname, uuid);
-
-		if (name && uuid && (count > 1)) {
-			DEBUGLOG(s, "vg_lookup name %s vgid %s found %d vgids",
-				 name, uuid, count);
-			return daemon_reply_simple("multiple", "reason = %s", "Multiple VGs found with same name", NULL);
-		}
-
-		if (!uuid || !name)
-			return reply_unknown("VG not found");
-
-	} else {
-		char *name_lookup = dm_hash_lookup(s->vgid_to_vgname, uuid);
-		char *uuid_lookup = dm_hash_lookup_with_val(s->vgname_to_vgid, name, uuid, strlen(uuid) + 1);
-
-		/* FIXME: comment out these sanity checks when not testing */
-
-		if (!name_lookup || !uuid_lookup) {
-			ERROR(s, "vg_lookup vgid %s name %s found incomplete mapping uuid %s name %s",
-			      uuid, name, uuid_lookup ?: "none", name_lookup ?: "none");
-			return reply_unknown("VG mapping incomplete");
-		} else if (strcmp(name_lookup, name) || strcmp(uuid_lookup, uuid)) {
-			ERROR(s, "vg_lookup vgid %s name %s found inconsistent mapping uuid %s name %s",
-			      uuid, name, uuid_lookup, name_lookup);
-			return reply_unknown("VG mapping inconsistent");
-		}
-	}
-
-	DEBUGLOG(s, "vg_lookup vgid %s name %s", uuid ?: "none", name ?: "none");
-
-	cft = dm_hash_lookup(s->vgid_to_metadata, uuid);
-	if (!cft || !cft->root) {
-		return reply_unknown("UUID not found");
-	}
-
-	metadata = cft->root;
-	if (!(res.cft = dm_config_create()))
-		goto nomem_un;
-
-	/* The response field */
-	if (!(res.cft->root = n = dm_config_create_node(res.cft, "response")))
-		goto nomem_un;
-
-	if (!(n->v = dm_config_create_value(cft)))
-		goto nomem_un;
-
-	n->parent = res.cft->root;
-	n->v->type = DM_CFG_STRING;
-	n->v->v.str = "OK";
-
-	if (!(n = n->sib = dm_config_create_node(res.cft, "name")))
-		goto nomem_un;
-
-	if (!(n->v = dm_config_create_value(res.cft)))
-		goto nomem_un;
-
-	n->parent = res.cft->root;
-	n->v->type = DM_CFG_STRING;
-	n->v->v.str = name;
-
-	/* The metadata section */
-	if (!(n = n->sib = dm_config_clone_node(res.cft, metadata, 1)))
-		goto nomem_un;
-	n->parent = res.cft->root;
-
-	if (!update_pv_status(s, res.cft, n))
-		goto nomem;
-	chain_outdated_pvs(s, uuid, res.cft, n);
-
-	if (s->flags & GLFL_INVALID)
-		add_last_node(res.cft, "global_invalid");
-
-	info = dm_hash_lookup(s->vgid_to_info, uuid);
-	if (info && (info->flags & VGFL_INVALID)) {
-		if (!add_last_node(res.cft, "vg_invalid"))
-			goto nomem;
-	}
-
-	return res;
-
-nomem_un:
-nomem:
-	reply_fail("out of memory");
-	ERROR(s, "vg_lookup vgid %s name %s out of memory.", uuid ?: "none", name ?: "none");
-	ERROR(s, "lvmetad could not be updated and is aborting.");
-	exit(EXIT_FAILURE);
-}
-
-static int vg_remove_if_missing(lvmetad_state *s, const char *vgid, int update_pvids);
-
-enum update_pvid_mode { UPDATE_ONLY, REMOVE_EMPTY, MARK_OUTDATED };
-
-/* You need to be holding the pvid_to_vgid lock already to call this. */
-static int _update_pvid_to_vgid(lvmetad_state *s, struct dm_config_tree *vg,
-				const char *vgid, int mode)
-{
-	struct dm_config_node *pv;
-	struct dm_hash_table *to_check;
-	struct dm_hash_node *n;
-	const char *pvid;
-	char *vgid_old;
-	char *vgid_dup;
-	const char *check_vgid;
-	int r = 0;
-
-	if (!vgid)
-		return 0;
-
-	if (!(to_check = dm_hash_create(32)))
-		goto abort_daemon;
-
-	for (pv = pvs(vg->root); pv; pv = pv->sib) {
-		if (!(pvid = dm_config_find_str(pv->child, "id", NULL))) {
-			ERROR(s, "PV has no id for update_pvid_to_vgid");
-			continue;
-		}
-
-		vgid_old = dm_hash_lookup(s->pvid_to_vgid, pvid);
-
-		if ((mode == REMOVE_EMPTY) && vgid_old) {
-			/* This copies the vgid_old string, doesn't reference it. */
-			if ((dm_hash_lookup(to_check, vgid_old) != (void*) 1) &&
-			    !dm_hash_insert(to_check, vgid_old, (void*) 1)) {
-				ERROR(s, "update_pvid_to_vgid out of memory for hash insert vgid_old %s", vgid_old);
-				goto abort_daemon;
-			}
-		}
-
-		if (mode == MARK_OUTDATED)
-			mark_outdated_pv(s, vgid, pvid);
-
-		if (!(vgid_dup = strdup(vgid))) {
-			ERROR(s, "update_pvid_to_vgid out of memory for vgid %s", vgid);
-			goto abort_daemon;
-		}
-
-		if (!dm_hash_insert(s->pvid_to_vgid, pvid, vgid_dup)) {
-			ERROR(s, "update_pvid_to_vgid out of memory for hash insert vgid %s", vgid_dup);
-			free(vgid_dup);
-			goto abort_daemon;
-		}
-
-		/* pvid_to_vgid no longer references vgid_old */
-		free(vgid_old);
-
-		DEBUGLOG(s, "moving PV %s to VG %s", pvid, vgid);
-	}
-
-	dm_hash_iterate(n, to_check) {
-		check_vgid = dm_hash_get_key(to_check, n);
-		vg_remove_if_missing(s, check_vgid, 0);
-	}
-
-	r = 1;
-	dm_hash_destroy(to_check);
-
-	return r;
-
-abort_daemon:
-	ERROR(s, "lvmetad could not be updated and is aborting.");
-	if (to_check)
-		dm_hash_destroy(to_check);
-	exit(EXIT_FAILURE);
-}
-
-/* A pvid map lock needs to be held if update_pvids = 1. */
-static int remove_metadata(lvmetad_state *s, const char *vgid, int update_pvids)
-{
-	struct dm_config_tree *meta_lookup;
-	struct dm_config_tree *outdated_pvs_lookup;
-	struct vg_info *info_lookup;
-	char *name_lookup = NULL;
-	char *vgid_lookup = NULL;
-
-	/* get data pointers from hash table so they can be freed */
-
-	info_lookup = dm_hash_lookup(s->vgid_to_info, vgid);
-	meta_lookup = dm_hash_lookup(s->vgid_to_metadata, vgid);
-	name_lookup = dm_hash_lookup(s->vgid_to_vgname, vgid);
-	outdated_pvs_lookup = dm_hash_lookup(s->vgid_to_outdated_pvs, vgid);
-	if (name_lookup)
-		vgid_lookup = dm_hash_lookup_with_val(s->vgname_to_vgid, name_lookup, vgid, strlen(vgid) + 1);
-
-	/* remove hash table mappings */
-
-	dm_hash_remove(s->vgid_to_info, vgid);
-	dm_hash_remove(s->vgid_to_metadata, vgid);
-	dm_hash_remove(s->vgid_to_vgname, vgid);
-	dm_hash_remove(s->vgid_to_outdated_pvs, vgid);
-	if (name_lookup)
-		dm_hash_remove_with_val(s->vgname_to_vgid, name_lookup, vgid, strlen(vgid) + 1);
-
-	/* update_pvid_to_vgid will clear/free the pvid_to_vgid hash */
-	if (update_pvids && meta_lookup)
-		(void) _update_pvid_to_vgid(s, meta_lookup, "#orphan", 0);
-
-	/* free the unmapped data */
-
-	if (meta_lookup)
-		dm_config_destroy(meta_lookup);
-	if (outdated_pvs_lookup)
-		dm_config_destroy(outdated_pvs_lookup);
-	free(info_lookup);
-	free(name_lookup);
-	free(vgid_lookup);
-	return 1;
-}
-
-/* The VG must be locked. */
-static int vg_remove_if_missing(lvmetad_state *s, const char *vgid, int update_pvids)
-{
-	struct dm_config_tree *vg;
-	struct dm_config_node *pv;
-	const char *vgid_check;
-	const char *pvid;
-	int missing = 1;
-
-	if (!vgid)
-		return 0;
-
-	if (!(vg = dm_hash_lookup(s->vgid_to_metadata, vgid)))
-		return 1;
-
-	for (pv = pvs(vg->root); pv; pv = pv->sib) {
-		if (!(pvid = dm_config_find_str(pv->child, "id", NULL)))
-			continue;
-
-		if ((vgid_check = dm_hash_lookup(s->pvid_to_vgid, pvid)) &&
-		    dm_hash_lookup(s->pvid_to_pvmeta, pvid) &&
-		    !strcmp(vgid, vgid_check))
-			missing = 0; /* at least one PV is around */
-	}
-
-	if (missing) {
-		DEBUGLOG(s, "removing empty VG %s", vgid);
-		remove_metadata(s, vgid, update_pvids);
-	}
-
-	return 1;
-}
-
-/*
- * Remove all hash table references to arg_name and arg_vgid
- * so that new metadata using this name and/or vgid can be added
- * without interference previous data.
- *
- * This is used if a command updates metadata in the cache,
- * but update_metadata finds that what's in the cache is not
- * consistent with a normal transition between old and new
- * metadata.  If this happens, it assumes that the command
- * is providing the correct metadata, so it first calls this
- * function to purge all records of the old metadata so the
- * new metadata can be added.
- */
-
-static void _purge_metadata(lvmetad_state *s, const char *arg_name, const char *arg_vgid)
-{
-	char *rem_vgid;
-
-	remove_metadata(s, arg_vgid, 1);
-
-	if ((rem_vgid = dm_hash_lookup_with_val(s->vgname_to_vgid, arg_name, arg_vgid, strlen(arg_vgid) + 1))) {
-		dm_hash_remove_with_val(s->vgname_to_vgid, arg_name, arg_vgid, strlen(arg_vgid) + 1);
-		free(rem_vgid);
-	}
-}
-
-/*
- * Updates for new vgid and new metadata.
- *
- * Remove any existing vg_info struct since it will be
- * recreated by lvmlockd if/when needed.
- *
- * Remove any existing outdated pvs since their metadata
- * will no longer be associated with this VG.
- */
-
-static int _update_metadata_new_vgid(lvmetad_state *s,
-				     const char *arg_name,
-				     const char *old_vgid,
-				     const char *new_vgid,
-				     struct dm_config_tree *old_meta,
-				     struct dm_config_tree *new_meta)
-{
-	struct vg_info *rem_info;
-	struct dm_config_tree *rem_outdated;
-	char *new_vgid_dup = NULL;
-	char *arg_name_dup = NULL;
-	int abort_daemon = 0;
-	int retval = 0;
-
-	if (!(new_vgid_dup = strdup(new_vgid)))
-		goto ret;
-
-	if (!(arg_name_dup = strdup(arg_name)))
-		goto ret;
-
-	/*
-	 * Temporarily orphan the PVs in the old metadata.
-	 */
-	if (!_update_pvid_to_vgid(s, old_meta, "#orphan", 0)) {
-		ERROR(s, "update_metadata_new_vgid failed to move PVs for %s old_vgid %s", arg_name, old_vgid);
-		abort_daemon = 1;
-		goto ret;
-	}
-
-	/*
-	 * Remove things related to the old vgid. (like remove_metadata)
-	 */
-
-	if ((rem_info = dm_hash_lookup(s->vgid_to_info, old_vgid))) {
-		dm_hash_remove(s->vgid_to_info, old_vgid);
-		free(rem_info);
-	}
-
-	if ((rem_outdated = dm_hash_lookup(s->vgid_to_outdated_pvs, old_vgid))) {
-		dm_hash_remove(s->vgid_to_outdated_pvs, old_vgid);
-		dm_config_destroy(rem_outdated);
-	}
-
-	dm_hash_remove(s->vgid_to_metadata, old_vgid);
-	dm_config_destroy(old_meta);
-	old_meta = NULL;
-
-	dm_hash_remove_with_val(s->vgname_to_vgid, arg_name, old_vgid, strlen(old_vgid) + 1);
-	dm_hash_remove(s->vgid_to_vgname, old_vgid);
-	free((char *)old_vgid);
-	old_vgid = NULL;
-
-	/*
-	 * Insert things with the new vgid.
-	 */
-
-	if (!dm_hash_insert(s->vgid_to_metadata, new_vgid, new_meta)) {
-		ERROR(s, "update_metadata_new_vgid out of memory for meta hash insert for %s %s", arg_name, new_vgid);
-		abort_daemon = 1;
-		goto out;
-	}
-
-	if (!dm_hash_insert(s->vgid_to_vgname, new_vgid, arg_name_dup)) {
-		ERROR(s, "update_metadata_new_vgid out of memory for name hash insert for %s %s", arg_name, new_vgid);
-		abort_daemon = 1;
-		goto out;
-	}
-
-	if (!dm_hash_insert_allow_multiple(s->vgname_to_vgid, arg_name, new_vgid_dup, strlen(new_vgid_dup) + 1)) {
-		ERROR(s, "update_metadata_new_vgid out of memory for vgid hash insert for %s %s", arg_name, new_vgid);
-		abort_daemon = 1;
-		goto out;
-	}
-
-	/*
-	 * Reassign PVs based on the new metadata.
-	 */
-	if (!_update_pvid_to_vgid(s, new_meta, new_vgid, 1)) {
-		ERROR(s, "update_metadata_new_name failed to update PVs for %s %s", arg_name, new_vgid);
-		abort_daemon = 1;
-		goto out;
-	}
-
-	DEBUGLOG(s, "update_metadata_new_vgid is done for %s %s", arg_name, new_vgid);
-	retval = 1;
-out:
-ret:
-	if (!new_vgid_dup || !arg_name_dup || abort_daemon) {
-		ERROR(s, "lvmetad could not be updated and is aborting.");
-		exit(EXIT_FAILURE);
-	}
-
-	if (!retval && new_meta)
-		dm_config_destroy(new_meta);
-	return retval;
-}
-
-/*
- * Updates for new name and new metadata.
- *
- * Remove any existing vg_info struct since it will be
- * recreated by lvmlockd if/when needed.
- *
- * Remove any existing outdated pvs since their metadata
- * will no longer be associated with this VG.
- */
-
-static int _update_metadata_new_name(lvmetad_state *s,
-				     const char *arg_vgid,
-				     const char *old_name,
-				     const char *new_name,
-				     struct dm_config_tree *old_meta,
-				     struct dm_config_tree *new_meta)
-{
-	struct vg_info *rem_info;
-	struct dm_config_tree *rem_outdated;
-	char *new_name_dup = NULL;
-	char *arg_vgid_dup = NULL;
-	int abort_daemon = 0;
-	int retval = 0;
-
-	if (!(new_name_dup = strdup(new_name)))
-		goto ret;
-
-	if (!(arg_vgid_dup = strdup(arg_vgid)))
-		goto ret;
-
-	/*
-	 * Temporarily orphan the PVs in the old metadata.
-	 */
-	if (!_update_pvid_to_vgid(s, old_meta, "#orphan", 0)) {
-		ERROR(s, "update_metadata_new_name failed to move PVs for old_name %s %s", old_name, arg_vgid);
-		abort_daemon = 1;
-		goto ret;
-	}
-
-	/*
-	 * Remove things related to the old name.
-	 */
-
-	if ((rem_info = dm_hash_lookup(s->vgid_to_info, arg_vgid))) {
-		dm_hash_remove(s->vgid_to_info, arg_vgid);
-		free(rem_info);
-	}
-
-	if ((rem_outdated = dm_hash_lookup(s->vgid_to_outdated_pvs, arg_vgid))) {
-		dm_hash_remove(s->vgid_to_outdated_pvs, arg_vgid);
-		dm_config_destroy(rem_outdated);
-	}
-
-	dm_hash_remove(s->vgid_to_metadata, arg_vgid);
-	dm_config_destroy(old_meta);
-	old_meta = NULL;
-
-	dm_hash_remove(s->vgid_to_vgname, arg_vgid);
-	dm_hash_remove_with_val(s->vgname_to_vgid, old_name, arg_vgid, strlen(arg_vgid) + 1);
-	free((char *)old_name);
-	old_name = NULL;
-
-	/*
-	 * Insert things with the new name.
-	 */
-
-	if (!dm_hash_insert(s->vgid_to_metadata, arg_vgid, new_meta)) {
-		ERROR(s, "update_metadata_new_name out of memory for meta hash insert for %s %s", new_name, arg_vgid);
-		abort_daemon = 1;
-		goto out;
-	}
-
-	if (!dm_hash_insert(s->vgid_to_vgname, arg_vgid, new_name_dup)) {
-		ERROR(s, "update_metadata_new_name out of memory for name hash insert for %s %s", new_name, arg_vgid);
-		abort_daemon = 1;
-		goto out;
-	}
-
-	if (!dm_hash_insert_allow_multiple(s->vgname_to_vgid, new_name, arg_vgid_dup, strlen(arg_vgid_dup) + 1)) {
-		ERROR(s, "update_metadata_new_name out of memory for vgid hash insert for %s %s", new_name, arg_vgid);
-		abort_daemon = 1;
-		goto out;
-	}
-
-	/*
-	 * Reassign PVs based on the new metadata.
-	 */
-	if (!_update_pvid_to_vgid(s, new_meta, arg_vgid, 1)) {
-		ERROR(s, "update_metadata_new_name failed to update PVs for %s %s", new_name, arg_vgid);
-		abort_daemon = 1;
-		goto out;
-	}
-
-	DEBUGLOG(s, "update_metadata_new_name is done for %s %s", new_name, arg_vgid);
-	retval = 1;
-out:
-ret:
-	if (!new_name_dup || !arg_vgid_dup || abort_daemon) {
-		ERROR(s, "lvmetad could not be updated and is aborting.");
-		exit(EXIT_FAILURE);
-	}
-
-	if (!retval && new_meta)
-		dm_config_destroy(new_meta);
-	return retval;
-}
-
-
-/*
- * Add new entries to all hash tables.
- */
-
-static int _update_metadata_add_new(lvmetad_state *s, const char *new_name, const char *new_vgid,
-				    struct dm_config_tree *new_meta)
-{
-	char *new_name_dup = NULL;
-	char *new_vgid_dup = NULL;
-	int abort_daemon = 0;
-	int retval = 0;
-
-	DEBUGLOG(s, "update_metadata_add_new for %s %s", new_name, new_vgid);
-
-	if (!(new_name_dup = strdup(new_name)))
-		goto out_free;
-
-	if (!(new_vgid_dup = strdup(new_vgid)))
-		goto out_free;
-
-	if (!dm_hash_insert(s->vgid_to_metadata, new_vgid, new_meta)) {
-		ERROR(s, "update_metadata_add_new out of memory for meta hash insert for %s %s", new_name, new_vgid);
-		abort_daemon = 1;
-		goto out;
-	}
-
-	if (!dm_hash_insert(s->vgid_to_vgname, new_vgid, new_name_dup)) {
-		ERROR(s, "update_metadata_add_new out of memory for name hash insert for %s %s", new_name, new_vgid);
-		abort_daemon = 1;
-		goto out;
-	}
-
-	if (!dm_hash_insert_allow_multiple(s->vgname_to_vgid, new_name, new_vgid_dup, strlen(new_vgid_dup) + 1)) {
-		ERROR(s, "update_metadata_add_new out of memory for vgid hash insert for %s %s", new_name, new_vgid);
-		abort_daemon = 1;
-		goto out;
-	}
-
-	if (!_update_pvid_to_vgid(s, new_meta, new_vgid, 1)) {
-		ERROR(s, "update_metadata_add_new failed to update PVs for %s %s", new_name, new_vgid);
-		abort_daemon = 1;
-		goto out;
-	}
-
-	DEBUGLOG(s, "update_metadata_add_new is done for %s %s", new_name, new_vgid);
-	retval = 1;
-out:
-out_free:
-	if (!new_name_dup || !new_vgid_dup || abort_daemon) {
-		free(new_name_dup);
-		free(new_vgid_dup);
-		ERROR(s, "lvmetad could not be updated and is aborting.");
-		exit(EXIT_FAILURE);
-	}
-
-	if (!retval && new_meta)
-		dm_config_destroy(new_meta);
-	return retval;
-}
-
-/*
- * No locks need to be held. The pointers are never used outside of the scope of
- * this function, so they can be safely destroyed after update_metadata returns
- * (anything that might have been retained is copied).
- *
- * When this is called from pv_found, the metadata was read from a single
- * PV specified by the pvid arg and ret_old_seq is not NULL.  The metadata
- * should match the existing metadata (matching seqno).  If the metadata
- * from pv_found has a smaller seqno, it means that the PV is outdated
- * (was previously used in the VG and now reappeared after changes to the VG).
- * The next command to access the VG will erase the outdated PV and then clear
- * the outdated pv record here.  If the metadata from pv_found has a larger
- * seqno than the existing metadata, it means ... (existing pvs are outdated?)
- *
- * When this is caleld from vg_update, the metadata is from a command that
- * has new metadata that should replace the existing metadata.
- * pvid and ret_old_seq are both NULL.
- */
-
-static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *arg_vgid,
-			    struct dm_config_node *new_metadata, int *ret_old_seq,
-			    const char *pvid)
-{
-	struct dm_config_tree *old_meta = NULL;
-	struct dm_config_tree *new_meta = NULL;
-	const char *arg_name_lookup; /* name lookup result from arg_vgid */
-	const char *arg_vgid_lookup; /* vgid lookup result from arg_name */
-	const char *old_name = NULL;
-	const char *new_name = NULL;
-	const char *old_vgid = NULL;
-	const char *new_vgid = NULL;
-	const char *new_metadata_vgid;
-	int new_seq;
-	int old_seq = -1;
-	int needs_repair = 0;
-	int abort_daemon = 0;
-	int retval = 0;
-	int count = 0;
-
-	if (!arg_vgid || !arg_name) {
-		ERROR(s, "update_metadata missing args arg_vgid %s arg_name %s pvid %s",
-		      arg_vgid ?: "none", arg_name ?: "none", pvid ?: "none");
-		return 0;
-	}
-
-	DEBUGLOG(s, "update_metadata begin arg_vgid %s arg_name %s pvid %s",
-		 arg_vgid, arg_name, pvid ?: "none");
-
-	/*
-	 * Begin by figuring out what has changed:
-	 * . the VG could be new - found no existing record of the vgid or name.
-	 * . the VG could have a new vgid - found an existing record of the name.
-	 * . the VG could have a new name - found an existing record of the vgid.
-	 * . the VG could have unchanged vgid and name - found existing record of both.
-	 */
-
-	arg_name_lookup = dm_hash_lookup(s->vgid_to_vgname, arg_vgid);
-	arg_vgid_lookup = dm_hash_lookup_with_val(s->vgname_to_vgid, arg_name, arg_vgid, strlen(arg_vgid) + 1);
-
-	/*
-	 * A new VG when there is no existing record of the name or vgid args.
-	 */
-	if (!arg_name_lookup && !arg_vgid_lookup) {
-		new_vgid = arg_vgid;
-		new_name = arg_name;
-
-		DEBUGLOG(s, "update_metadata new name %s and new vgid %s",
-			 new_name, new_vgid);
-		goto update;
-	}
-
-	/*
-	 * An existing name has a new vgid (new_vgid = arg_vgid).
-	 * A lookup of the name arg was successful in finding arg_vgid_lookup,
-	 * but that resulting vgid doesn't match the arg_vgid.
-	 */
-	if (arg_vgid_lookup && strcmp(arg_vgid_lookup, arg_vgid)) {
-		if (arg_name_lookup) {
-			/*
-			 * This shouldn't happen.
-			 * arg_vgid should be new and should not map to any name.
-			 */
-			ERROR(s, "update_metadata arg_vgid %s arg_name %s unexpected arg_name_lookup %s",
-			      arg_vgid, arg_name, arg_name_lookup);
-			needs_repair = 1;
-			goto update;
-		}
-
-		new_vgid = arg_vgid;
-		old_vgid = dm_hash_lookup_with_count(s->vgname_to_vgid, arg_name, &count);
-
-		/*
-		 * FIXME: this ensures that arg_name maps to only one existing
-		 * VG (old_vgid), because if it maps to multiple vgids, then we
-		 * don't know which one should get the new vgid (arg_vgid).  If
-		 * this function was given both the existing name and existing
-		 * vgid to identify the VG, then this wouldn't be a problem.
-		 * But as it is now, the vgid arg to this function is the new
-		 * vgid and the existing VG is specified only by name.
-		 */
-		if (old_vgid && (count > 1)) {
-			ERROR(s, "update_metadata arg_vgid %s arg_name %s found %d vgids for name",
-			      arg_vgid, arg_name, count);
-			old_vgid = NULL;
-		}
-
-		if (!old_vgid) {
-			/* This shouldn't happen. */
-			ERROR(s, "update_metadata arg_vgid %s arg_name %s no old_vgid",
-			      arg_vgid, arg_name);
-			needs_repair = 1;
-			goto update;
-		}
-
-		if (!(old_meta = dm_hash_lookup(s->vgid_to_metadata, old_vgid))) {
-			/* This shouldn't happen. */
-			ERROR(s, "update_metadata arg_vgid %s arg_name %s old_vgid %s no old_meta",
-			      arg_vgid, arg_name, old_vgid);
-			needs_repair = 1;
-			goto update;
-		}
-
-		DEBUGLOG(s, "update_metadata existing name %s has new vgid %s old vgid %s",
-			 arg_name, new_vgid, old_vgid);
-		goto update;
-	}
-
-	/*
-	 * An existing vgid has a new name (new_name = arg_name).
-	 * A lookup of the vgid arg was successful in finding arg_name_lookup,
-	 * but that resulting name doesn't match the arg_name.
-	 */
-	if (arg_name_lookup && strcmp(arg_name_lookup, arg_name)) {
-		if (arg_vgid_lookup) {
-			/*
-			 * This shouldn't happen.
-			 * arg_name should be new and should not map to any vgid.
-			 */
-			ERROR(s, "update_metadata arg_vgid %s arg_name %s unexpected arg_vgid_lookup %s",
-			      arg_vgid, arg_name, arg_vgid_lookup);
-			needs_repair = 1;
-			goto update;
-		}
-
-		new_name = arg_name;
-		old_name = dm_hash_lookup(s->vgid_to_vgname, arg_vgid);
-
-		if (!old_name) {
-			/* This shouldn't happen. */
-			ERROR(s, "update_metadata arg_vgid %s arg_name %s no old_name",
-			      arg_vgid, arg_name);
-			needs_repair = 1;
-			goto update;
-		}
-
-		if (!(old_meta = dm_hash_lookup(s->vgid_to_metadata, arg_vgid))) {
-			/* This shouldn't happen. */
-			ERROR(s, "update_metadata arg_vgid %s arg_name %s old_name %s no old_meta",
-			      arg_vgid, arg_name, old_name);
-			needs_repair = 1;
-			goto update;
-		}
-
-		DEBUGLOG(s, "update_metadata existing vgid %s has new name %s old name %s",
-			 arg_vgid, new_name, old_name);
-		goto update;
-	}
-
-	/*
-	 * An existing VG has unchanged name and vgid.
-	 */
-	if (!new_vgid && !new_name) {
-		if (!arg_vgid_lookup || !arg_name_lookup) {
-			/* This shouldn't happen. */
-			ERROR(s, "update_metadata arg_vgid %s arg_name %s missing lookups vgid %s name %s",
-			      arg_vgid ?: "none", arg_name ?: "none", arg_vgid_lookup ?: "none", arg_name_lookup ?: "none");
-			needs_repair = 1;
-			goto update;
-		}
-
-		if (strcmp(arg_name_lookup, arg_name)) {
-			/* This shouldn't happen. */
-			ERROR(s, "update_metadata arg_vgid %s arg_name %s mismatch arg_name_lookup %s",
-			      arg_vgid, arg_name, arg_name_lookup);
-			needs_repair = 1;
-			goto update;
-		}
-
-		if (strcmp(arg_vgid_lookup, arg_vgid)) {
-			/* This shouldn't happen.  Two VGs with the same name is handled above. */
-			ERROR(s, "update_metadata arg_vgid %s arg_name %s mismatch arg_vgid_lookup %s",
-			      arg_vgid, arg_name, arg_vgid_lookup);
-			needs_repair = 1;
-			goto update;
-		}
-
-		/* old_vgid == arg_vgid, and old_name == arg_name */
-
-		if (!(old_meta = dm_hash_lookup(s->vgid_to_metadata, arg_vgid))) {
-			/* This shouldn't happen. */
-			ERROR(s, "update_metadata arg_vgid %s arg_name %s no old_meta",
-			      arg_vgid, arg_name);
-			needs_repair = 1;
-			goto update;
-		}
-
-		DEBUGLOG(s, "update_metadata existing vgid %s and existing name %s",
-			 arg_vgid, arg_name);
-		goto update;
-	}
-
- update:
-	filter_metadata(new_metadata); /* sanitize */
-
-	/*
-	 * FIXME: verify that there's at least one PV in common between
-	 * the old and new metadata?
-	 */
-
-	if (!(new_meta = dm_config_create()) ||
-	    !(new_meta->root = dm_config_clone_node(new_meta, new_metadata, 0))) {
-		ERROR(s, "update_metadata out of memory for new metadata for %s %s",
-		      arg_name, arg_vgid);
-		/* FIXME: should we purge the old metadata here? */
-		retval = 0;
-		goto out;
-	}
-
-	/*
-	 * Get the seqno from existing (old) and new metadata and perform
-	 * sanity checks for transitions that generally shouldn't happen.
-	 * Sometimes ignore the new metadata and leave the existing metadata
-	 * alone, and sometimes purge the existing metadata and add the new.
-	 * This often depends on whether the new metadata comes from a single
-	 * PV (via pv_found) that's been scanned, or a vg_update sent from a
-	 * command.
-	 */
-
-	new_seq = dm_config_find_int(new_metadata, "metadata/seqno", -1);
-
-	if (old_meta)
-		old_seq = dm_config_find_int(old_meta->root, "metadata/seqno", -1);
-
-	if (ret_old_seq)
-		*ret_old_seq = old_meta ? old_seq : new_seq;
-
-	/*
-	 * The new metadata has an invalid seqno.
-	 * This shouldn't happen, but if it does, ignore the new metadata.
-	 */
-	if (new_seq <= 0) {
-		ERROR(s, "update_metadata ignore new metadata because of invalid seqno for %s %s",
-		      arg_vgid, arg_name);
-		DEBUGLOG_cft(s, "NEW: ", new_metadata);
-		retval = 0;
-		goto out;
-	}
-
-	/*
-	 * The new metadata is missing an internal vgid.
-	 * This shouldn't happen, but if it does, ignore the new metadata.
-	 */
-	if (!(new_metadata_vgid = dm_config_find_str(new_meta->root, "metadata/id", NULL))) {
-		ERROR(s, "update_metadata has no internal vgid for %s %s",
-		      arg_name, arg_vgid);
-		DEBUGLOG_cft(s, "NEW: ", new_metadata);
-		retval = 0;
-		goto out;
-	}
-
-	/*
-	 * The new metadata internal vgid doesn't match the arg vgid.
-	 * This shouldn't happen, but if it does, ignore the new metadata.
-	 */
-	if (strcmp(new_metadata_vgid, arg_vgid)) {
-		ERROR(s, "update_metadata has bad internal vgid %s for %s %s",
-		      new_metadata_vgid, arg_name, arg_vgid);
-		DEBUGLOG_cft(s, "NEW: ", new_metadata);
-		retval = 0;
-		goto out;
-	}
-
-	/*
-	 * A single PV appears with metadata that's inconsistent with
-	 * existing, ignore the PV.  FIXME: make it outdated?
-	 */
-	if (pvid && needs_repair) {
-		ERROR(s, "update_metadata ignore inconsistent metadata on PV %s seqno %d for %s %s seqno %d",
-		      pvid, new_seq, arg_vgid, arg_name, old_seq);
-		if (old_meta)
-			DEBUGLOG_cft(s, "OLD: ", old_meta->root);
-		DEBUGLOG_cft(s, "NEW: ", new_metadata);
-		retval = 0;
-		goto out;
-	}
-
-	/*
-	 * A VG update with metadata that's inconsistent with existing.
-	 */
-	if (!pvid && needs_repair) {
-		ERROR(s, "update_metadata inconsistent with cache for vgid %s and name %s",
-		      arg_vgid, arg_name);
-		if (old_meta)
-			DEBUGLOG_cft(s, "OLD: ", old_meta->root);
-		DEBUGLOG_cft(s, "NEW: ", new_metadata);
-		abort_daemon = 1;
-		retval = 0;
-		goto out;
-	}
-
-	/*
-	 * A single PV appears with metadata that's older than the existing,
-	 * e.g. an PV that had been in the VG has reappeared after the VG changed.
-	 * old PV: the PV that lvmetad was told about first
-	 * new PV: the PV that lvmetad is being told about here, second
-	 * old_seq: the larger seqno on the old PV, for the newer version of the VG
-	 * new_seq: the smaller seqno on the new PV, for the older version of the VG
-	 *
-	 * So, the new PV (by notification order) is "older" (in terms of
-	 * VG seqno) than the old PV.
-	 *
-	 * Make the new PV outdated so it'll be cleared and keep the existing
-	 * metadata from the old PV.
-	 */
-	if (pvid && (old_seq > 0) && (new_seq < old_seq)) {
-		ERROR(s, "update_metadata ignoring outdated metadata on PV %s seqno %d for %s %s seqno %d",
-		      pvid, new_seq, arg_vgid, arg_name, old_seq);
-		DEBUGLOG_cft(s, "OLD: ", old_meta->root);
-		DEBUGLOG_cft(s, "NEW: ", new_metadata);
-		mark_outdated_pv(s, arg_vgid, pvid);
-		retval = 0;
-		goto out;
-	}
-
-	/*
-	 * A single PV appears with metadata that's newer than the existing,
-	 * e.g. a PV has been found with VG metadata that is newer than the
-	 * VG metdata we know about.  This can happen when scanning PVs after
-	 * an outdated PV (with an older version of the VG metadata) has
-	 * reappeared.  The rescanning may initially scan the outdated PV
-	 * and notify lvmetad about it, and then scan a current PV from
-	 * the VG and notify lvmetad about it.
-	 * old PV: the PV that lvmetad was told about first
-	 * new PV: the PV that lvmetad is being told about here, second
-	 * old_seq: the smaller seqno on the old PV, for the older version of the VG
-	 * new_seq: the larger seqno on the new PV, for the newer version of the VG
-	 *
-	 * Make the existing PVs outdated, and use the new metadata.
-	 */
-	if (pvid && (old_seq > 0) && (new_seq > old_seq)) {
-		ERROR(s, "update_metadata found newer metadata on PV %s seqno %d for %s %s seqno %d",
-		      pvid, new_seq, arg_vgid, arg_name, old_seq);
-		DEBUGLOG_cft(s, "OLD: ", old_meta->root);
-		DEBUGLOG_cft(s, "NEW: ", new_metadata);
-		_update_pvid_to_vgid(s, old_meta, arg_vgid, MARK_OUTDATED);
-	}
-
-	/*
-	 * The existing/old metadata has an invalid seqno.
-	 * This shouldn't happen, but if it does, purge old and add the new.
-	 */
-	if (old_meta && (old_seq <= 0)) {
-		ERROR(s, "update_metadata bad old seqno %d for %s %s",
-		      old_seq, arg_name, arg_vgid);
-		DEBUGLOG_cft(s, "OLD: ", old_meta->root);
-		_purge_metadata(s, arg_name, arg_vgid);
-		new_name = arg_name;
-		new_vgid = arg_vgid;
-		old_name = NULL;
-		old_vgid = NULL;
-		old_meta = NULL;
-		old_seq = -1;
-	}
-
-	/*
-	 * A single PV appears with a seqno matching existing metadata,
-	 * but unmatching metadata content.  This shouldn't happen,
-	 * but if it does, ignore the PV.  FIXME: make it outdated?
-	 */
-	if (pvid && (new_seq == old_seq) && compare_config(new_metadata, old_meta->root)) {
-		ERROR(s, "update_metadata from pv %s same seqno %d with unmatching data for %s %s",
-		      pvid, new_seq, arg_name, arg_vgid);
-		DEBUGLOG_cft(s, "OLD: ", old_meta->root);
-		DEBUGLOG_cft(s, "NEW: ", new_metadata);
-		retval = 0;
-		goto out;
-	}
-
-	/*
-	 * A VG update with metadata matching existing seqno but unmatching content.
-	 * This shouldn't happen, but if it does, purge existing and add the new.
-	 */
-	if (!pvid && (new_seq == old_seq) && compare_config(new_metadata, old_meta->root)) {
-		ERROR(s, "update_metadata same seqno %d with unmatching data for %s %s",
-		      new_seq, arg_name, arg_vgid);
-		DEBUGLOG_cft(s, "OLD: ", old_meta->root);
-		DEBUGLOG_cft(s, "NEW: ", new_metadata);
-		_purge_metadata(s, arg_name, arg_vgid);
-		new_name = arg_name;
-		new_vgid = arg_vgid;
-		old_name = NULL;
-		old_vgid = NULL;
-		old_meta = NULL;
-		old_seq = -1;
-	}
-
-	/*
-	 * A VG update with metadata older than existing.  VG updates should
-	 * have increasing seqno.  This shouldn't happen, but if it does,
-	 * purge existing and add the new.
-	 */
-	if (!pvid && (new_seq < old_seq)) {
-		ERROR(s, "update_metadata new seqno %d less than old seqno %d for %s %s",
-		      new_seq, old_seq, arg_name, arg_vgid);
-		DEBUGLOG_cft(s, "OLD: ", old_meta->root);
-		DEBUGLOG_cft(s, "NEW: ", new_metadata);
-		_purge_metadata(s, arg_name, arg_vgid);
-		new_name = arg_name;
-		new_vgid = arg_vgid;
-		old_name = NULL;
-		old_vgid = NULL;
-		old_meta = NULL;
-		old_seq = -1;
-	}
-
-	/*
-	 * All the checks are done, do one of the four possible updates
-	 * outlined above:
-	 */
-
-	/*
-	 * Add metadata for a new VG to the cache.
-	 */
-	if (new_name && new_vgid)
-		return _update_metadata_add_new(s, new_name, new_vgid, new_meta);
-
-	/*
-	 * Update cached metadata for a VG with a new vgid.
-	 */
-	if (new_vgid)
-		return _update_metadata_new_vgid(s, arg_name, old_vgid, new_vgid, old_meta, new_meta);
-
-	/*
-	 * Update cached metadata for a renamed VG.
-	 */
-	if (new_name)
-		return _update_metadata_new_name(s, arg_vgid, old_name, new_name, old_meta, new_meta);
-
-	/*
-	 * If the old and new seqnos are the same, we've already compared the
-	 * old/new metadata and verified it's the same, so there's no reason
-	 * to replace old meta with new meta.
-	 */
-	if (old_seq == new_seq) {
-		DEBUGLOG(s, "update_metadata skipped for %s %s seqno %d is unchanged",
-			 arg_name, arg_vgid, old_seq);
-		dm_config_destroy(new_meta);
-		new_meta = NULL;
-		retval = 1;
-		goto out;
-	}
-
-	/*
-	 * Update cached metdata for a VG with unchanged name and vgid.
-	 * Replace the old metadata with the new metadata.
-	 * old_meta is the old copy of the metadata from the cache.
-	 * new_meta is the new copy of the metadata from the command.
-	 */
-	DEBUGLOG(s, "update_metadata for %s %s from %d to %d", arg_name, arg_vgid, old_seq, new_seq);
-
-	/*
-	 * The PVs in the VG may have changed in the new metadata, so
-	 * temporarily orphan all of the PVs in the existing VG.
-	 * The PVs that are still in the VG will be reassigned to this
-	 * VG below by the next call to _update_pvid_to_vgid().
-	 */
-	if (!_update_pvid_to_vgid(s, old_meta, "#orphan", 0)) {
-		ERROR(s, "update_metadata failed to move PVs for %s %s", arg_name, arg_vgid);
-		abort_daemon = 1;
-		retval = 0;
-		goto out;
-	}
-
-	/*
-	 * The only hash table update that is needed is the actual
-	 * metadata config tree in vgid_to_metadata.  The VG name
-	 * and vgid are unchanged.
-	 */
-
-	dm_hash_remove(s->vgid_to_metadata, arg_vgid);
-	dm_config_destroy(old_meta);
-	old_meta = NULL;
-
-	if (!dm_hash_insert(s->vgid_to_metadata, arg_vgid, new_meta)) {
-		ERROR(s, "update_metadata out of memory for hash insert for %s %s", arg_name, arg_vgid);
-		abort_daemon = 1;
-		retval = 0;
-		goto out;
-	}
-
-	/*
-	 * Map the PVs in the new metadata to the vgid.
-	 * All pre-existing PVs were temporarily orphaned above.
-	 * Previous PVs that were removed from the VG will not
-	 * be remapped.  New PVs that were added to the VG will
-	 * be newly mapped to this vgid, and previous PVs that
-	 * remain in the VG will be remapped to the VG again.
-	 */
-	if (!_update_pvid_to_vgid(s, new_meta, arg_vgid, 1)) {
-		ERROR(s, "update_metadata failed to update PVs for %s %s", arg_name, arg_vgid);
-		abort_daemon = 1;
-		retval = 0;
-	} else {
-		DEBUGLOG(s, "update_metadata is done for %s %s", arg_name, arg_vgid);
-		retval = 1;
-	}
-
-out:
-	if (abort_daemon) {
-		ERROR(s, "lvmetad could not be updated is aborting.");
-		exit(EXIT_FAILURE);
-	}
-
-	if (!retval && new_meta)
-		dm_config_destroy(new_meta);
-	return retval;
-}
-
-static response pv_gone(lvmetad_state *s, request r)
-{
-	const char *arg_pvid = NULL;
-	char *old_pvid = NULL;
-	const char *pvid;
-	int64_t device;
-	struct dm_config_tree *pvmeta;
-	char *vgid;
-
-	arg_pvid = daemon_request_str(r, "uuid", NULL);
-	device = daemon_request_int(r, "device", 0);
-
-	if (!arg_pvid && device > 0)
-		old_pvid = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device));
-
-	if (!arg_pvid && !old_pvid) {
-		DEBUGLOG(s, "pv_gone device %" PRIu64 " not found", device);
-		return reply_unknown("device not in cache");
-	}
-
-	pvid = arg_pvid ? arg_pvid : old_pvid;
-
-	DEBUGLOG(s, "pv_gone %s device %" PRIu64, pvid ?: "none", device);
-
-	if (!(pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, pvid))) {
-		DEBUGLOG(s, "pv_gone %s device %" PRIu64 " has no PV metadata",
-			 pvid ?: "none", device);
-		return reply_unknown("PVID does not exist");
-	}
-
-	vgid = dm_hash_lookup(s->pvid_to_vgid, pvid);
-
-	dm_hash_remove_binary(s->device_to_pvid, &device, sizeof(device));
-	dm_hash_remove(s->pvid_to_pvmeta, pvid);
-
-	if (vgid) {
-		char *vgid_dup;
-		/*
-		 * vg_remove_if_missing will clear and free the pvid_to_vgid
-		 * mappings for this vg, which will free the "vgid" string that
-		 * was returned above from the pvid_to_vgid lookup.
-		 */
-		if (!(vgid_dup = strdup(vgid)))
-			return reply_fail("out of memory");
-
-		vg_remove_if_missing(s, vgid_dup, 1);
-		free(vgid_dup);
-		vgid_dup = NULL;
-		vgid = NULL;
-	}
-
-	dm_config_destroy(pvmeta);
-	free(old_pvid);
-
-	return daemon_reply_simple("OK", NULL );
-}
-
-static response pv_clear_all(lvmetad_state *s, request r)
-{
-	DEBUGLOG(s, "pv_clear_all");
-
-	destroy_metadata_hashes(s);
-	create_metadata_hashes(s);
-
-	return daemon_reply_simple("OK", NULL);
-}
-
-/*
- * Returns 1 if PV metadata exists for all PVs in a VG.
- */
-static int _vg_is_complete(lvmetad_state *s, struct dm_config_tree *vgmeta)
-{
-	struct dm_config_node *vg = vgmeta->root;
-	struct dm_config_node *pv;
-	int complete = 1;
-	const char *pvid;
-
-	for (pv = pvs(vg); pv; pv = pv->sib) {
-		if (!(pvid = dm_config_find_str(pv->child, "id", NULL)))
-			continue;
-
-		if (!dm_hash_lookup(s->pvid_to_pvmeta, pvid)) {
-			complete = 0;
-			break;
-		}
-	}
-
-	return complete;
-}
-
-/*
- * pv_found: a PV has appeared and been scanned
- * It contains PV metadata, and optionally VG metadata.
- * Both kinds of metadata should be added to the cache
- * and hash table mappings related to the PV and device
- * should be updated.
- *
- * Input values from request:
- * . arg_pvmeta:  PV metadata from the found pv
- * . arg_pvid:    pvid from arg_pvmeta (pvmeta/id)
- * . arg_device:  device from arg_pvmeta (pvmeta/device)
- * . arg_vgmeta:  VG metadata from the found pv (optional)
- * . arg_name:    VG name from found pv (optional)
- * . arg_vgid:    VG vgid from arg_vgmeta  (optional)
- *
- * Search for existing mappings in hash tables:
- * . pvid_to_pvmeta (which produces pvid to device)
- * . device_to_pvid
- * . pvid_to_vgid
- *
- * Existing data from cache:
- * . old_pvmeta:         result of pvid_to_pvmeta(arg_pvid)
- * . arg_device_lookup:  result of old_pvmeta:pvmeta/device using arg_pvid
- * . arg_pvid_lookup:    result of device_to_pvid(arg_device)
- * . arg_vgid_lookup:    result of pvid_to_vgid(arg_pvid)
- *
- * When arg_pvid doesn't match arg_pvid_lookup:
- * . a new PV replaces a previous PV on arg_device
- * . prev_pvid_on_dev:   set to arg_pvid_lookup, pvid of the prev PV
- * . prev_pvmeta_on_dev: result pvid_to_pvmeta(prev_pvid_on_dev)
- * . prev_vgid_on_dev:   result of pvid_to_vgid(prev_pvid_on_dev)
- *
- * Old PV on old device
- * . no PV/device mappings have changed
- * . arg_pvid_lookup == arg_pvid && arg_device_lookup == arg_device
- * . arg_device was used to look up a PV and found a PV with
- *   the same pvid as arg_pvid
- * . arg_pvid was used to look up a PV and found a PV on the
- *   same device as arg_device
- * . new_pvmeta may be more recent than old_pvmeta
- *
- * New PV on new device
- * . add new mappings in hash tables
- * . !arg_pvid_lookup && !arg_device_lookup
- * . arg_device was used to look up a PV and found nothing
- * . arg_pvid was used to look up a PV and found nothing
- *
- * New PV on old device
- * . a new PV replaces a previous PV on a device
- * . arg_pvid_lookup != arg_pvid
- * . arg_device was used to look up a PV and found a PV with
- *   a different pvid than arg_pvid
- * . replace existing mappings for arg_device and arg_pvid
- * . replace existing old_pvmeta with new_pvmeta
- * . remove arg_device association with prev PV (prev_pvid_on_dev)
- * . possibly remove prev PV (if arg_device was previously a duplicate)
- *
- * Old PV on new device
- * . a duplicate PV
- * . arg_device_lookup != arg_device
- * . arg_pvid was used to look up a PV, and found that the PV
- *   has a different device than arg_device.
- */
-
-static response pv_found(lvmetad_state *s, request r)
-{
-	struct dm_config_node *arg_vgmeta = NULL;
-	struct dm_config_node *arg_pvmeta = NULL;
-	struct dm_config_tree *old_pvmeta = NULL;
-	struct dm_config_tree *new_pvmeta = NULL;
-	struct dm_config_tree *prev_pvmeta_on_dev = NULL;
-	struct dm_config_tree *vgmeta = NULL;
-	const char *arg_pvid = NULL;
-	const char *arg_pvid_lookup = NULL;
-	const char *new_pvid = NULL;
-	char *new_pvid_dup = NULL;
-	const char *arg_name = NULL;
-	const char *arg_vgid = NULL;
-	const char *arg_vgid_lookup = NULL;
-	const char *prev_pvid_on_dev = NULL;
-	const char *prev_vgid_on_dev = NULL;
-	const char *vg_status = NULL;
-	uint64_t arg_device = 0;
-	uint64_t arg_device_lookup = 0;
-	uint64_t new_device = 0;
-	uint64_t old_device = 0;
-	int arg_seqno = -1;
-	int old_seqno = -1;
-	int vg_status_seqno = -1;
-	int changed = 0;
-
-	/*
-	 * New input values.
-	 */
-
-	if (!(arg_pvmeta = dm_config_find_node(r.cft->root, "pvmeta"))) {
-		ERROR(s, "Ignore PV without PV metadata");
-		return reply_fail("Ignore PV without PV metadata");
-	}
-
-	if (!(arg_pvid = daemon_request_str(r, "pvmeta/id", NULL))) {
-		ERROR(s, "Ignore PV without PV UUID");
-		return reply_fail("Ignore PV without PV UUID");
-	}
-
-	if (!dm_config_get_uint64(arg_pvmeta, "pvmeta/device", &arg_device)) {
-		ERROR(s, "Ignore PV without device pvid %s", arg_pvid);
-		return reply_fail("Ignore PV without device");
-	}
-
-	if ((arg_vgmeta = dm_config_find_node(r.cft->root, "metadata"))) {
-		arg_name = daemon_request_str(r, "vgname", NULL);
-		arg_vgid = daemon_request_str(r, "metadata/id", NULL);
-		arg_seqno = daemon_request_int(r, "metadata/seqno", -1);
-
-		if (!arg_name || !arg_vgid || (arg_seqno < 0))
-			ERROR(s, "Ignore VG metadata from PV %s", arg_pvid);
-		if (!arg_name)
-			return reply_fail("Ignore VG metadata from PV without VG name");
-		if (!arg_vgid)
-			return reply_fail("Ignore VG metadata from PV without VG vgid");
-		if (arg_seqno < 0)
-			return reply_fail("Ignore VG metadata from PV without VG seqno");
-	}
-
-	/* Make a copy of the new pvmeta that can be inserted into cache. */
-	if (!(new_pvmeta = dm_config_create()) ||
-	    !(new_pvmeta->root = dm_config_clone_node(new_pvmeta, arg_pvmeta, 0))) {
-		ERROR(s, "pv_found out of memory for new pvmeta %s", arg_pvid);
-		goto nomem;
-	}
-
-	/*
-	 * Existing (old) cache values.
-	 */
-
-	old_pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, arg_pvid);
-	if (old_pvmeta)
-		dm_config_get_uint64(old_pvmeta->root, "pvmeta/device", &arg_device_lookup);
-
-	arg_pvid_lookup = dm_hash_lookup_binary(s->device_to_pvid, &arg_device, sizeof(arg_device));
-
-	/*
-	 * Determine which of the four possible changes is happening
-	 * by comparing the existing/old and new values:
-	 * old PV, old device
-	 * new PV, new device
-	 * new PV, old device
-	 * old PV, new device
-	 */
-
-	if (arg_pvid_lookup && arg_device_lookup &&
-	    (arg_device == arg_device_lookup) &&
-	    !strcmp(arg_pvid_lookup, arg_pvid)) {
-		/*
-		 * Old PV on old device (existing values unchanged)
-		 */
-		new_pvid = NULL;
-		new_device = 0;
-
-		DEBUGLOG(s, "pv_found pvid %s on device %" PRIu64 " matches existing",
-			arg_pvid, arg_device);
-
-	} else if (!arg_pvid_lookup && !arg_device_lookup) {
-		/*
-		 * New PV on new device (no existing values)
-		 */
-		new_pvid = arg_pvid;
-		new_device = arg_device;
-
-		DEBUGLOG(s, "pv_found pvid %s on device %" PRIu64 " is new",
-			arg_pvid, arg_device);
-
-	} else if (arg_pvid_lookup && strcmp(arg_pvid_lookup, arg_pvid)) {
-		/*
-		 * New PV on old device (existing device reused for new PV)
-		 */
-		new_pvid = arg_pvid;
-		new_device = 0;
-		prev_pvid_on_dev = arg_pvid_lookup;
-		prev_pvmeta_on_dev = dm_hash_lookup(s->pvid_to_pvmeta, arg_pvid_lookup);
-		prev_vgid_on_dev = dm_hash_lookup(s->pvid_to_vgid, arg_pvid_lookup);
-
-		DEBUGLOG(s, "pv_found pvid %s vgid %s on device %" PRIu64 " previous pvid %s vgid %s",
-			arg_pvid, arg_vgid ?: "none", arg_device,
-			prev_pvid_on_dev, prev_vgid_on_dev ?: "none");
-
-	} else if (arg_device_lookup && (arg_device_lookup != arg_device)) {
-		/*
-		 * Old PV on new device (existing PV on a new device, i.e. duplicate)
-		 */
-		new_device = arg_device;
-		new_pvid = NULL;
-		old_device = arg_device_lookup;
-
-		DEBUGLOG(s, "pv_found pvid %s vgid %s on device %" PRIu64 " duplicate %" PRIu64,
-			arg_pvid, arg_vgid ?: "none", arg_device, arg_device_lookup);
-
-	} else {
-		ERROR(s, "pv_found pvid %s vgid %s on device %" PRIu64 " unknown lookup %s %s %" PRIu64,
-		      arg_pvid,
-		      arg_vgid ?: "none",
-		      arg_device,
-		      arg_pvid_lookup ?: "none",
-		      arg_vgid_lookup ?: "none",
-		      arg_device_lookup);
-		return reply_fail("Ignore PV for unknown state");
-	}
-
-	/*
-	 * Make changes to hashes device_to_pvid and pvid_to_pvmeta for each case.
-	 */
-
-	if (!new_pvid && !new_device) {
-		/*
-		 * Old PV on old device (unchanged)
-		 * . add new_pvmeta, replacing old_pvmeta
-		 */
-		if (compare_config(old_pvmeta->root, new_pvmeta->root))
-			changed |= 1;
-
-		if (!dm_hash_insert(s->pvid_to_pvmeta, arg_pvid, new_pvmeta))
-			goto nomem_free1;
-
-	} else if (new_pvid && new_device) {
-		/*
-		 * New PV on new device (new entry)
-		 * . add new_device/new_pvid mapping
-		 * . add new_pvmeta
-		 */
-		changed |= 1;
-
-		DEBUGLOG(s, "pv_found new entry device_to_pvid %" PRIu64 " to %s",
-			 new_device, new_pvid);
-
-		if (!(new_pvid_dup = strdup(new_pvid)))
-			goto nomem_free1;
-
-		if (!dm_hash_insert_binary(s->device_to_pvid, &new_device, sizeof(new_device), new_pvid_dup))
-			goto nomem_free2;
-
-		if (!dm_hash_insert(s->pvid_to_pvmeta, new_pvid, new_pvmeta))
-			goto nomem_free1;
-
-	} else if (new_pvid && !new_device) {
-		/*
-		 * New PV on old device (existing device reused for new PV).
-		 * The previous PV on arg_device is replaced by the new one.
-		 *
-		 * Don't free prev_pvid or prev_vgid strings because they are
-		 * used at the end to check the VG metadata.
-		 */
-		changed |= 1;
-
-		if (prev_pvmeta_on_dev) {
-			DEBUGLOG(s, "pv_found new pvid device_to_pvid %" PRIu64 " to %s removes prev pvid %s",
-				 arg_device, new_pvid, prev_pvid_on_dev);
-
-			dm_hash_remove(s->pvid_to_pvmeta, prev_pvid_on_dev);
-			dm_config_destroy(prev_pvmeta_on_dev);
-			prev_pvmeta_on_dev = NULL;
-
-			/* removes arg_device/prev_pvid_on_dev mapping */
-			dm_hash_remove_binary(s->device_to_pvid, &arg_device, sizeof(arg_device));
-
-			/*
-			 * The new PV replacing the prev PV was copied from
-			 * another existing PV, creating a duplicate PV which
-			 * we ignore.
-			 */
-			if (dm_hash_lookup(s->pvid_to_pvmeta, new_pvid)) {
-				DEBUGLOG(s, "pv_found ignore duplicate device %" PRIu64 " of existing PV for pvid %s",
-				         arg_device, arg_pvid);
-				dm_config_destroy(new_pvmeta);
-				/* device_to_pvid no longer references prev_pvid_lookup */
-				free((void*)prev_pvid_on_dev);
-				s->flags |= GLFL_DISABLE;
-				s->flags |= GLFL_DISABLE_REASON_DUPLICATES;
-				return reply_fail("Ignore duplicate PV");
-			}
-		}
-
-
-		if (!(new_pvid_dup = strdup(new_pvid)))
-			goto nomem_free1;
-
-		if (!dm_hash_insert_binary(s->device_to_pvid, &arg_device, sizeof(arg_device), new_pvid_dup))
-			goto nomem_free2;
-
-		if (!dm_hash_insert(s->pvid_to_pvmeta, new_pvid, new_pvmeta))
-			goto nomem_free1;
-
-	} else if (new_device && !new_pvid) {
-		/*
-		 * Old PV on new device (duplicate)
-		 * Ignore it.
-		 */
-		DEBUGLOG(s, "pv_found ignore duplicate device %" PRIu64 " of existing device %" PRIu64 " for pvid %s",
-			 new_device, old_device, arg_pvid);
-		dm_config_destroy(new_pvmeta);
-		s->flags |= GLFL_DISABLE;
-		s->flags |= GLFL_DISABLE_REASON_DUPLICATES;
-		return reply_fail("Ignore duplicate PV");
-	}
-
-	if (old_pvmeta)
-		dm_config_destroy(old_pvmeta);
-
-	/*
-	 * Update VG metadata cache with arg_vgmeta from the PV, or
-	 * if the PV holds no VG metadata, then look up the vgid and
-	 * name of the VG so we can check if the VG is complete.
-	 */
-	if (arg_vgmeta) {
-		DEBUGLOG(s, "pv_found pvid %s has VG %s %s seqno %d", arg_pvid, arg_name, arg_vgid, arg_seqno);
-
-		if (!_update_metadata(s, arg_name, arg_vgid, arg_vgmeta, &old_seqno, arg_pvid)) {
-			ERROR(s, "Cannot use VG metadata for %s %s from PV %s on %" PRIu64,
-			      arg_name, arg_vgid, arg_pvid, arg_device);
-		}
-
-		changed |= (old_seqno != arg_seqno);
-	} else {
-		arg_vgid = dm_hash_lookup(s->pvid_to_vgid, arg_pvid);
-
-		if (arg_vgid) {
-			arg_name = dm_hash_lookup(s->vgid_to_vgname, arg_vgid);
-		}
-	}
-
-	/*
-	 * Check if the VG is complete (all PVs have been found) because
-	 * the reply indicates if the the VG is complete or partial.
-	 * The "vgmeta" from dm_hash_lookup will be a copy of arg_vgmeta that
-	 * was cloned and added to the cache by update_metadata.
-	 */
-	if (!arg_vgid || !strcmp(arg_vgid, "#orphan")) {
-		DEBUGLOG(s, "pv_found pvid %s on %" PRIu64 " not in VG %s",
-			 arg_pvid, arg_device, arg_vgid ?: "");
-		vg_status = "orphan";
-		goto prev_vals;
-	}
-
-	if (!(vgmeta = dm_hash_lookup(s->vgid_to_metadata, arg_vgid))) {
-		ERROR(s, "pv_found %s on %" PRIu64 " vgid %s no VG metadata found",
-		      arg_pvid, arg_device, arg_vgid);
-	} else {
-		vg_status = _vg_is_complete(s, vgmeta) ? "complete" : "partial";
-		vg_status_seqno = dm_config_find_int(vgmeta->root, "metadata/seqno", -1);
-	}
-
- prev_vals:
-	/*
-	 * If the device previously held a different VG (prev_vgid_on_dev),
-	 * then that VG should be removed if no devices are left for it.
-	 *
-	 * The mapping from the device's previous pvid to the previous vgid
-	 * is removed.
-	 */
-
-	if (prev_pvid_on_dev || prev_vgid_on_dev) {
-		DEBUGLOG(s, "pv_found pvid %s on %" PRIu64 " had prev pvid %s prev vgid %s",
-			 arg_pvid, arg_device,
-			 prev_pvid_on_dev ?: "none",
-			 prev_vgid_on_dev ?: "none");
-	}
-
-	if (prev_vgid_on_dev) {
-		char *tmp_vgid;
-
-	       	if (!arg_vgid || strcmp(arg_vgid, prev_vgid_on_dev)) {
-			tmp_vgid = strdup(prev_vgid_on_dev);
-			/* vg_remove_if_missing will clear and free
-			   the string pointed to by prev_vgid_on_dev. */
-			vg_remove_if_missing(s, tmp_vgid, 1);
-			free(tmp_vgid);
-		}
-
-		/* vg_remove_if_missing may have remapped prev_pvid_on_dev to orphan */
-		if ((tmp_vgid = dm_hash_lookup(s->pvid_to_vgid, prev_pvid_on_dev))) {
-			dm_hash_remove(s->pvid_to_vgid, prev_pvid_on_dev);
-			free(tmp_vgid);
-		}
-	}
-
-	/* This was unhashed from device_to_pvid above. */
-	free((void *)prev_pvid_on_dev);
-
-	return daemon_reply_simple("OK",
-				   "status = %s", vg_status,
-				   "changed = " FMTd64, (int64_t) changed,
-				   "vgid = %s", arg_vgid ? arg_vgid : "#orphan",
-				   "vgname = %s", arg_name ? arg_name : "#orphan",
-				   "seqno_before = " FMTd64, (int64_t) old_seqno,
-				   "seqno_after = " FMTd64, (int64_t) vg_status_seqno,
-				   NULL);
-
- nomem_free2:
-	free(new_pvid_dup);
- nomem_free1:
-	dm_config_destroy(new_pvmeta);
- nomem:
-	ERROR(s, "pv_found %s is out of memory.", arg_pvid);
-	ERROR(s, "lvmetad could not be updated is aborting.");
-	reply_fail("out of memory");
-	exit(EXIT_FAILURE);
-}
-
-static response vg_clear_outdated_pvs(lvmetad_state *s, request r)
-{
-	struct dm_config_tree *outdated_pvs;
-	const char *vgid = daemon_request_str(r, "vgid", NULL);
-
-	if (!vgid)
-		return reply_fail("need VG UUID");
-
-	DEBUGLOG(s, "vg_clear_outdated_pvs vgid %s", vgid);
-
-	if ((outdated_pvs = dm_hash_lookup(s->vgid_to_outdated_pvs, vgid))) {
-		dm_config_destroy(outdated_pvs);
-		dm_hash_remove(s->vgid_to_outdated_pvs, vgid);
-	}
-	return daemon_reply_simple("OK", NULL);
-}
-
-static void vg_info_update(lvmetad_state *s, const char *uuid,
-                           struct dm_config_node *metadata)
-{
-	struct vg_info *info;
-	int64_t cache_version;
-
-	cache_version = dm_config_find_int64(metadata, "metadata/seqno", -1);
-	if (cache_version == -1)
-		return;
-
-	info = (struct vg_info *) dm_hash_lookup(s->vgid_to_info, uuid);
-	if (!info)
-		return;
-
-	if (cache_version >= info->external_version)
-		info->flags &= ~VGFL_INVALID;
-}
-
-static response vg_update(lvmetad_state *s, request r)
-{
-	struct dm_config_node *metadata = dm_config_find_node(r.cft->root, "metadata");
-	const char *vgid = daemon_request_str(r, "metadata/id", NULL);
-	const char *vgname = daemon_request_str(r, "vgname", NULL);
-
-	DEBUGLOG(s, "vg_update vgid %s name %s", vgid ?: "none", vgname ?: "none");
-
-	if (metadata) {
-		if (!vgid) {
-			ERROR(s, "vg_update failed: need VG UUID");
-			reply_fail("vg_update: need VG UUID");
-			goto fail;
-		}
-		if (!vgname) {
-			ERROR(s, "vg_update failed: need VG name");
-			reply_fail("vg_update: need VG name");
-			goto fail;
-		}
-		if (daemon_request_int(r, "metadata/seqno", -1) < 0) {
-			ERROR(s, "vg_update failed: need VG seqno");
-			reply_fail("vg_update: need VG seqno");
-			goto fail;
-		}
-
-		/* TODO defer metadata update here; add a separate vg_commit
-		 * call; if client does not commit, die */
-
-		if (!_update_metadata(s, vgname, vgid, metadata, NULL, NULL)) {
-			ERROR(s, "vg_update failed: metadata update failed");
-			reply_fail("vg_update: failed metadata update");
-			goto fail;
-		}
-
-		vg_info_update(s, vgid, metadata);
-	}
-	return daemon_reply_simple("OK", NULL);
-
-fail:
-	ERROR(s, "lvmetad could not be updated is aborting.");
-	exit(EXIT_FAILURE);
-}
-
-static response vg_remove(lvmetad_state *s, request r)
-{
-	const char *vgid = daemon_request_str(r, "uuid", NULL);
-
-	if (!vgid)
-		return reply_fail("need VG UUID");
-
-	DEBUGLOG(s, "vg_remove: %s", vgid);
-
-	remove_metadata(s, vgid, 1);
-
-	return daemon_reply_simple("OK", NULL);
-}
-
-/*
- * Whether lvmetad is disabled is determined only by the single
- * flag GLFL_DISABLE.  The REASON flags are only explanatory
- * additions to GLFL_DISABLE, and do not control the disabled state.
- * The REASON flags can accumulate if multiple reasons exist for
- * the disabled flag.  When clearing GLFL_DISABLE, all REASON flags
- * are cleared.  The caller clearing GLFL_DISABLE should only do so
- * when all the reasons for it have gone.
- */
-
-static response set_global_info(lvmetad_state *s, request r)
-{
-	const int global_invalid = daemon_request_int(r, "global_invalid", -1);
-	const int global_disable = daemon_request_int(r, "global_disable", -1);
-	const char *reason;
-	uint32_t reason_flags = 0;
-
-	if ((reason = daemon_request_str(r, "disable_reason", NULL))) {
-		if (strstr(reason, LVMETAD_DISABLE_REASON_DIRECT))
-			reason_flags |= GLFL_DISABLE_REASON_DIRECT;
-		if (strstr(reason, LVMETAD_DISABLE_REASON_REPAIR))
-			reason_flags |= GLFL_DISABLE_REASON_REPAIR;
-		if (strstr(reason, LVMETAD_DISABLE_REASON_DUPLICATES))
-			reason_flags |= GLFL_DISABLE_REASON_DUPLICATES;
-		if (strstr(reason, LVMETAD_DISABLE_REASON_VGRESTORE))
-			reason_flags |= GLFL_DISABLE_REASON_VGRESTORE;
-	}
-
-	if (global_invalid != -1) {
-		DEBUGLOG(s, "set global info invalid from %d to %d",
-			 (s->flags & GLFL_INVALID) ? 1 : 0, global_invalid);
-	}
-
-	if (global_disable != -1) {
-		DEBUGLOG(s, "set global info disable from %d to %d %s",
-			 (s->flags & GLFL_DISABLE) ? 1 : 0, global_disable,
-			 reason ? reason : "");
-	}
-
-	if (global_invalid == 1)
-		s->flags |= GLFL_INVALID;
-
-	else if (global_invalid == 0)
-		s->flags &= ~GLFL_INVALID;
-
-	if (global_disable == 1) {
-		s->flags |= GLFL_DISABLE;
-		s->flags |= reason_flags;
-
-	} else if (global_disable == 0) {
-		s->flags &= ~GLFL_DISABLE;
-		s->flags &= ~GLFL_DISABLE_REASON_ALL;
-	}
-
-	return daemon_reply_simple("OK", NULL);
-}
-
-#define REASON_BUF_SIZE 64
-
-/*
- * Save the time when "updating" begins, and the config setting for how long
- * the update is allowed to take.  Before returning "updating" as the token
- * value in get_global_info, check if the update has exceeded the max allowed
- * time.  If so, then return "none" as the current token value (i.e.
- * uninitialized), so that the command will repopulate our cache.
- *
- * This automatically clears a stuck update, where a command started to update
- * the cache and then failed, leaving the token set to "update in progress".
- */
-
-static response get_global_info(lvmetad_state *s, request r)
-{
-	/* This buffer should be large enough to hold all the possible reasons. */
-	char reason[REASON_BUF_SIZE] = { 0 };
-	char flag_str[64];
-	int pid;
-
-	pid = (int)daemon_request_int(r, "pid", 0);
-
-	if (s->flags & GLFL_DISABLE) {
-		snprintf(reason, REASON_BUF_SIZE, "%s%s%s%s",
-			 (s->flags & GLFL_DISABLE_REASON_DIRECT)     ? LVMETAD_DISABLE_REASON_DIRECT "," : "",
-			 (s->flags & GLFL_DISABLE_REASON_REPAIR)     ? LVMETAD_DISABLE_REASON_REPAIR "," : "",
-			 (s->flags & GLFL_DISABLE_REASON_DUPLICATES) ? LVMETAD_DISABLE_REASON_DUPLICATES "," : "",
-			 (s->flags & GLFL_DISABLE_REASON_VGRESTORE)  ? LVMETAD_DISABLE_REASON_VGRESTORE "," : "");
-	}
-
-	if (!reason[0])
-		strcpy(reason, "none");
-
-	/*
-	 * If the current update has timed out, then return
-	 * token of "none" which means "uninitialized" so that
-	 * the caller will repopulate lvmetad.
-	 */
-	if (s->update_begin && s->update_timeout) {
-		if (_monotonic_seconds() - s->update_begin >= s->update_timeout) {
-			DEBUGLOG(s, "global info cancel update after timeout %d len %d begin %llu pid %d cmd %s",
-				 s->update_timeout,
-				 (int)(_monotonic_seconds() - s->update_begin),
-				 (unsigned long long)s->update_begin,
-				 s->update_pid, s->update_cmd);
-			memset(s->token, 0, sizeof(s->token));
-			s->update_begin = 0;
-			s->update_timeout = 0;
-			s->update_pid = 0;
-			memset(s->update_cmd, 0, CMD_NAME_SIZE);
-		}
-	}
-
-	memset(flag_str, 0, sizeof(flag_str));
-	if (s->flags & GLFL_INVALID)
-		strcat(flag_str, "Invalid");
-	if (s->flags & GLFL_DISABLE)
-		strcat(flag_str, "Disable");
-	if (!flag_str[0])
-		strcat(flag_str, "none");
-
-	DEBUGLOG(s, "%d global info flags %s reason %s token %s update_pid %d",
-		 pid, flag_str, reason, s->token[0] ? s->token : "none", s->update_pid);
-
-	return daemon_reply_simple("OK", "global_invalid = " FMTd64, (int64_t)((s->flags & GLFL_INVALID) ? 1 : 0),
-					 "global_disable = " FMTd64, (int64_t)((s->flags & GLFL_DISABLE) ? 1 : 0),
-					 "disable_reason = %s", reason,
-					 "daemon_pid = " FMTd64, (int64_t)getpid(),
-					 "token = %s", s->token[0] ? s->token : "none",
-					 "update_cmd = %s", s->update_cmd,
-					 "update_pid = " FMTd64, (int64_t)s->update_pid,
-					 "update_begin = " FMTd64, (int64_t)s->update_begin,
-					 "update_timeout = " FMTd64, (int64_t)s->update_timeout,
-					 NULL);
-}
-
-static response set_vg_info(lvmetad_state *s, request r)
-{
-	struct dm_config_tree *vg;
-	struct vg_info *info;
-	const char *name = NULL;
-	const char *uuid = NULL;
-	const int64_t new_version = daemon_request_int(r, "version", -1);
-	int64_t cache_version = -1;
-
-	if (new_version == -1)
-		goto out;
-
-	if (!(uuid = daemon_request_str(r, "uuid", NULL)))
-		goto use_name;
-
-	if ((vg = dm_hash_lookup(s->vgid_to_metadata, uuid)))
-		goto vers;
-use_name:
-	if (!(name = daemon_request_str(r, "name", NULL)))
-		goto out;
-
-	if (!(uuid = dm_hash_lookup(s->vgname_to_vgid, name)))
-		goto out;
-
-	/* 
-	 * FIXME: if we only have the name and multiple VGs have that name,
-	 * then invalidate each of them.
-	 */
-
-	if (!(vg = dm_hash_lookup(s->vgid_to_metadata, uuid)))
-		goto out;
-vers:
-	if (!new_version)
-		goto inval;
-
-	cache_version = dm_config_find_int64(vg->root, "metadata/seqno", -1);
-
-	if (cache_version != -1 && new_version != -1 && cache_version >= new_version)
-		goto out;
-inval:
-	DEBUGLOG(s, "set info VG name %s uuid %s cache_version %d new_version %d",
-		 name ?: "none", uuid ?: "none", (int)cache_version, (int)new_version);
-
-	info = dm_hash_lookup(s->vgid_to_info, uuid);
-	if (!info) {
-		if (!(info = zalloc(sizeof(struct vg_info))))
-			goto bad;
-		if (!dm_hash_insert(s->vgid_to_info, uuid, (void*)info))
-			goto bad;
-	}
-
-	info->external_version = new_version;
-	info->flags |= VGFL_INVALID;
-
-out:
-	return daemon_reply_simple("OK", NULL);
-bad:
-	return reply_fail("out of memory");
-}
-
-static void _dump_cft(struct buffer *buf, struct dm_hash_table *ht, const char *key_addr)
-{
-	struct dm_hash_node *n;
-
-	dm_hash_iterate(n, ht) {
-		struct dm_config_tree *cft = dm_hash_get_data(ht, n);
-		const char *key_backup = cft->root->key;
-		cft->root->key = dm_config_find_str(cft->root, key_addr, "unknown");
-		(void) dm_config_write_node(cft->root, buffer_line, buf);
-		cft->root->key = key_backup;
-	}
-}
-
-static void _dump_pairs(struct buffer *buf, struct dm_hash_table *ht, const char *name, int int_key)
-{
-	char *append;
-	struct dm_hash_node *n;
-
-	buffer_append(buf, name);
-	buffer_append(buf, " {\n");
-
-	dm_hash_iterate(n, ht) {
-		const char *key = dm_hash_get_key(ht, n),
-			   *val = dm_hash_get_data(ht, n);
-		if (int_key)
-			(void) dm_asprintf(&append, "    %d = \"%s\"\n", *(const int*)key, val);
-		else
-			(void) dm_asprintf(&append, "    %s = \"%s\"\n", key, val);
-		if (append)
-			buffer_append(buf, append);
-		free(append);
-	}
-	buffer_append(buf, "}\n");
-}
-
-static void _dump_info_version(struct buffer *buf, struct dm_hash_table *ht, const char *name, int int_key)
-{
-	char *append;
-	struct dm_hash_node *n = dm_hash_get_first(ht);
-	struct vg_info *info;
-
-	buffer_append(buf, name);
-	buffer_append(buf, " {\n");
-
-	while (n) {
-		const char *key = dm_hash_get_key(ht, n);
-		info = dm_hash_get_data(ht, n);
-		(void) dm_asprintf(&append, "    %s = %lld\n", key, (long long)info->external_version);
-		if (append)
-			buffer_append(buf, append);
-		free(append);
-		n = dm_hash_get_next(ht, n);
-	}
-	buffer_append(buf, "}\n");
-}
-
-static void _dump_info_flags(struct buffer *buf, struct dm_hash_table *ht, const char *name, int int_key)
-{
-	char *append;
-	struct dm_hash_node *n = dm_hash_get_first(ht);
-	struct vg_info *info;
-
-	buffer_append(buf, name);
-	buffer_append(buf, " {\n");
-
-	while (n) {
-		const char *key = dm_hash_get_key(ht, n);
-		info = dm_hash_get_data(ht, n);
-		(void) dm_asprintf(&append, "    %s = %llx\n", key, (long long)info->flags);
-		if (append)
-			buffer_append(buf, append);
-		free(append);
-		n = dm_hash_get_next(ht, n);
-	}
-	buffer_append(buf, "}\n");
-}
-
-static response dump(lvmetad_state *s)
-{
-	response res = { 0 };
-	struct buffer *b = &res.buffer;
-
-	buffer_init(b);
-
-	/* Lock everything so that we get a consistent dump. */
-
-	buffer_append(b, "# VG METADATA\n\n");
-	_dump_cft(b, s->vgid_to_metadata, "metadata/id");
-
-	buffer_append(b, "\n# PV METADATA\n\n");
-	_dump_cft(b, s->pvid_to_pvmeta, "pvmeta/id");
-
-	buffer_append(b, "\n# VGID to VGNAME mapping\n\n");
-	_dump_pairs(b, s->vgid_to_vgname, "vgid_to_vgname", 0);
-
-	buffer_append(b, "\n# VGID to outdated PVs mapping\n\n");
-	_dump_cft(b, s->vgid_to_outdated_pvs, "outdated_pvs/vgid");
-
-	buffer_append(b, "\n# VGNAME to VGID mapping\n\n");
-	_dump_pairs(b, s->vgname_to_vgid, "vgname_to_vgid", 0);
-
-	buffer_append(b, "\n# PVID to VGID mapping\n\n");
-	_dump_pairs(b, s->pvid_to_vgid, "pvid_to_vgid", 0);
-
-	buffer_append(b, "\n# DEVICE to PVID mapping\n\n");
-	_dump_pairs(b, s->device_to_pvid, "device_to_pvid", 1);
-
-	buffer_append(b, "\n# VGID to INFO version mapping\n\n");
-	_dump_info_version(b, s->vgid_to_info, "vgid_to_info", 0);
-
-	buffer_append(b, "\n# VGID to INFO flags mapping\n\n");
-	_dump_info_flags(b, s->vgid_to_info, "vgid_to_info", 0);
-
-	return res;
-}
-
-static response handler(daemon_state s, client_handle h, request r)
-{
-	response res;
-	lvmetad_state *state = s.private;
-	char prev_token[128] = { 0 };
-	const char *rq;
-	const char *token;
-	const char *cmd;
-	int prev_in_progress, this_in_progress;
-	int update_timeout;
-	int pid;
-	int cache_lock = 0;
-	int info_lock = 0;
-
-	rq = daemon_request_str(r, "request", "NONE");
-	token = daemon_request_str(r, "token", "NONE");
-	pid = (int)daemon_request_int(r, "pid", 0);
-	cmd = daemon_request_str(r, "cmd", "NONE");
-	update_timeout = (int)daemon_request_int(r, "update_timeout", 0);
-
-	pthread_mutex_lock(&state->token_lock);
-
-	/*
-	 * token_update: start populating the cache, i.e. a full update.
-	 * To populate the lvmetad cache, a command does:
-	 *
-	 * - token_update, setting token to "update in progress"
-	 *   (further requests during the update continue using
-	 *   this same "update in progress" token)
-	 * - pv_clear_all, to clear the current cache
-	 * - pv_gone, for each PV
-	 * - pv_found, for each PV to populate the cache
-	 * - token_update, setting token to filter hash
-	 */
-	if (!strcmp(rq, "token_update")) {
-		prev_in_progress = !strcmp(state->token, LVMETAD_TOKEN_UPDATE_IN_PROGRESS);
-		this_in_progress = !strcmp(token, LVMETAD_TOKEN_UPDATE_IN_PROGRESS);
-
-		if (!prev_in_progress && this_in_progress) {
-			/* New update is starting (filter token is replaced by update token) */
-
-			(void) dm_strncpy(prev_token, state->token, sizeof(prev_token));
-			(void) dm_strncpy(state->token, token, sizeof(state->token));
-			state->update_begin = _monotonic_seconds();
-			state->update_timeout = update_timeout;
-			state->update_pid = pid;
-			strncpy(state->update_cmd, cmd, CMD_NAME_SIZE - 1);
-
-			DEBUGLOG(state, "token_update begin %llu timeout %d pid %d cmd %s",
-				 (unsigned long long)state->update_begin,
-				 state->update_timeout,
-				 state->update_pid,
-				 state->update_cmd);
-
-		} else if (prev_in_progress && this_in_progress) {
-			/* Current update is cancelled and replaced by a new update */
-
-			DEBUGLOG(state, "token_update replacing pid %d begin %llu len %d cmd %s",
-				 state->update_pid,
-				 (unsigned long long)state->update_begin,
-				 (int)(_monotonic_seconds() - state->update_begin),
-				 state->update_cmd);
-
-			(void) dm_strncpy(prev_token, state->token, sizeof(prev_token));
-			(void) dm_strncpy(state->token, token, sizeof(state->token));
-			state->update_begin = _monotonic_seconds();
-			state->update_timeout = update_timeout;
-			state->update_pid = pid;
-			strncpy(state->update_cmd, cmd, CMD_NAME_SIZE - 1);
-
-			DEBUGLOG(state, "token_update begin %llu timeout %d pid %d cmd %s",
-				 (unsigned long long)state->update_begin,
-				 state->update_timeout,
-				 state->update_pid,
-				 state->update_cmd);
-
-		} else if (prev_in_progress && !this_in_progress) {
-			/* Update is finished, update token is replaced by filter token */
-
-			if (state->update_pid != pid) {
-				/* If a pid doing update was cancelled, ignore its token update at the end. */
-				DEBUGLOG(state, "token_update ignored from cancelled update pid %d", pid);
-				pthread_mutex_unlock(&state->token_lock);
-
-				return daemon_reply_simple("token_mismatch",
-							   "expected = %s", state->token,
-							   "received = %s", token,
-							   "update_pid = " FMTd64, (int64_t)state->update_pid,
-							   "reason = %s", "another command has populated the cache",
-							   NULL);
-			}
-
-			DEBUGLOG(state, "token_update end len %d pid %d new token %s",
-				 (int)(_monotonic_seconds() - state->update_begin),
-				 state->update_pid, token);
-
-			(void) dm_strncpy(prev_token, state->token, sizeof(prev_token));
-			(void) dm_strncpy(state->token, token, sizeof(state->token));
-			state->update_begin = 0;
-			state->update_timeout = 0;
-			state->update_pid = 0;
-			memset(state->update_cmd, 0, CMD_NAME_SIZE);
-		}
-		pthread_mutex_unlock(&state->token_lock);
-
-		return daemon_reply_simple("OK",
-					   "prev_token = %s", prev_token,
-					   "update_pid = " FMTd64, (int64_t)state->update_pid,
-					   NULL);
-	}
-
-	if (strcmp(token, state->token) && strcmp(rq, "dump") && strcmp(token, "skip")) {
-		pthread_mutex_unlock(&state->token_lock);
-
-		DEBUGLOG(state, "token_mismatch current \"%s\" got \"%s\" from pid %d cmd %s",
-			 state->token, token, pid, cmd ?: "none");
-
-		return daemon_reply_simple("token_mismatch",
-					   "expected = %s", state->token,
-					   "received = %s", token,
-					   "update_pid = " FMTd64, (int64_t)state->update_pid,
-					   "reason = %s", "another command has populated the cache",
-					   NULL);
-	}
-
-	/* If a pid doing update was cancelled, ignore its update messages. */
-	if (!strcmp(token, LVMETAD_TOKEN_UPDATE_IN_PROGRESS) &&
-	    state->update_pid && pid && (state->update_pid != pid)) {
-		pthread_mutex_unlock(&state->token_lock);
-
-		DEBUGLOG(state, "token_mismatch ignore update from pid %d current update pid %d",
-			 pid, state->update_pid);
-
-		return daemon_reply_simple("token_mismatch",
-					   "expected = %s", state->token,
-					   "received = %s", token,
-					   "update_pid = " FMTd64, (int64_t)state->update_pid,
-					   "reason = %s", "another command has populated the lvmetad cache",
-					   NULL);
-	}
-
-	pthread_mutex_unlock(&state->token_lock);
-
-
-	if (!strcmp(rq, "pv_found") ||
-	    !strcmp(rq, "pv_gone") ||
-	    !strcmp(rq, "vg_update") ||
-	    !strcmp(rq, "vg_remove") ||
-	    !strcmp(rq, "set_vg_info") ||
-	    !strcmp(rq, "pv_clear_all") ||
-	    !strcmp(rq, "vg_clear_outdated_pvs")) {
-		pthread_rwlock_wrlock(&state->cache_lock);
-		cache_lock = 1;
-		goto do_rq;
-	}
-
-	if (!strcmp(rq, "pv_lookup") ||
-	    !strcmp(rq, "vg_lookup") ||
-	    !strcmp(rq, "pv_list") ||
-	    !strcmp(rq, "vg_list") ||
-	    !strcmp(rq, "dump")) {
-		pthread_rwlock_rdlock(&state->cache_lock);
-		cache_lock = 1;
-		goto do_rq;
-	}
-
-	if (!strcmp(rq, "set_global_info") ||
-	    !strcmp(rq, "get_global_info")) {
-		pthread_mutex_lock(&state->info_lock);
-		info_lock = 1;
-		goto do_rq;
-	}
-
- do_rq:
-
-	if (!strcmp(rq, "pv_found"))
-		res = pv_found(state, r);
-
-	else if (!strcmp(rq, "pv_gone"))
-		res = pv_gone(state, r);
-
-	else if (!strcmp(rq, "pv_clear_all"))
-		res = pv_clear_all(state, r);
-
-	else if (!strcmp(rq, "pv_lookup"))
-		res = pv_lookup(state, r);
-
-	else if (!strcmp(rq, "vg_update"))
-		res = vg_update(state, r);
-
-	else if (!strcmp(rq, "vg_clear_outdated_pvs"))
-		res = vg_clear_outdated_pvs(state, r);
-
-	else if (!strcmp(rq, "vg_remove"))
-		res = vg_remove(state, r);
-
-	else if (!strcmp(rq, "vg_lookup"))
-		res = vg_lookup(state, r);
-
-	else if (!strcmp(rq, "pv_list"))
-		res = pv_list(state, r);
-
-	else if (!strcmp(rq, "vg_list"))
-		res = vg_list(state, r);
-
-	else if (!strcmp(rq, "set_global_info"))
-		res = set_global_info(state, r);
-
-	else if (!strcmp(rq, "get_global_info"))
-		res = get_global_info(state, r);
-
-	else if (!strcmp(rq, "set_vg_info"))
-		res = set_vg_info(state, r);
-
-	else if (!strcmp(rq, "dump"))
-		res = dump(state);
-
-	else
-		res = reply_fail("request not implemented");
-
-	if (cache_lock)
-		pthread_rwlock_unlock(&state->cache_lock);
-	if (info_lock)
-		pthread_mutex_unlock(&state->info_lock);
-
-	return res;
-}
-
-static int init(daemon_state *s)
-{
-	lvmetad_state *ls = s->private;
-	ls->log = s->log;
-
-	pthread_mutex_init(&ls->token_lock, NULL);
-	pthread_mutex_init(&ls->info_lock, NULL);
-	pthread_rwlock_init(&ls->cache_lock, NULL);
-	create_metadata_hashes(ls);
-
-	ls->token[0] = 0;
-
-	/* Set up stderr logging depending on the -l option. */
-	if (!daemon_log_parse(ls->log, DAEMON_LOG_OUTLET_STDERR, ls->log_config, 1))
-		return 0;
-
-	DEBUGLOG(s, "initialised state: vgid_to_metadata = %p", ls->vgid_to_metadata);
-	if (!ls->pvid_to_vgid || !ls->vgid_to_metadata)
-		return 0;
-
-	/* if (ls->initial_registrations)
-	   _process_initial_registrations(ds->initial_registrations); */
-
-	if (ls->idle)
-		ls->idle->is_idle = 1;
-
-	return 1;
-}
-
-static int fini(daemon_state *s)
-{
-	lvmetad_state *ls = s->private;
-
-	DEBUGLOG(s, "fini");
-	destroy_metadata_hashes(ls);
-	return 1;
-}
-
-static int process_timeout_arg(const char *str, unsigned *max_timeouts)
-{
-	char *endptr;
-	unsigned long l;
-
-	errno = 0;
-	l = strtoul(str, &endptr, 10);
-	if (errno || *endptr || l >= UINT_MAX)
-		return 0;
-
-	*max_timeouts = (unsigned) l;
-
-	return 1;
-}
-
-static void usage(const char *prog, FILE *file)
-{
-	fprintf(file, "Usage:\n"
-		"%s [-V] [-h] [-f] [-l level[,level ...]] [-s path] [-t secs]\n\n"
-		"   -V       Show version of lvmetad\n"
-		"   -h       Show this help information\n"
-		"   -f       Don't fork, run in the foreground\n"
-		"   -l       Logging message levels (all,fatal,error,warn,info,wire,debug)\n"
-		"   -p       Set path to the pidfile\n"
-		"   -s       Set path to the socket to listen on\n"
-		"   -t       Time to wait in seconds before shutdown on idle (missing or 0 = inifinite)\n\n", prog);
-}
-
-int main(int argc, char *argv[])
-{
-	signed char opt;
-	struct timeval timeout;
-	daemon_idle di = { .ptimeout = &timeout };
-	lvmetad_state ls = { .log_config = "" };
-	daemon_state s = {
-		.daemon_fini = fini,
-		.daemon_init = init,
-		.handler = handler,
-		.name = "lvmetad",
-		.pidfile = getenv("LVM_LVMETAD_PIDFILE") ? : LVMETAD_PIDFILE,
-		.private = &ls,
-		.protocol = "lvmetad",
-		.protocol_version = 1,
-		.socket_path = getenv("LVM_LVMETAD_SOCKET") ? : LVMETAD_SOCKET,
-	};
-
-	// use getopt_long
-	while ((opt = getopt(argc, argv, "?fhVl:p:s:t:")) != EOF) {
-		switch (opt) {
-		case 'h':
-			usage(argv[0], stdout);
-			exit(0);
-		case '?':
-			usage(argv[0], stderr);
-			exit(0);
-		case 'f':
-			s.foreground = 1;
-			break;
-		case 'l':
-			ls.log_config = optarg;
-			break;
-		case 'p':
-			s.pidfile = optarg;
-			break;
-		case 's': // --socket
-			s.socket_path = optarg;
-			break;
-		case 't':
-			if (!process_timeout_arg(optarg, &di.max_timeouts)) {
-				fprintf(stderr, "Invalid value of timeout parameter.\n");
-				exit(EXIT_FAILURE);
-			}
-			/* 0 equals to wait indefinitely */
-			if (di.max_timeouts)
-				s.idle = ls.idle = &di;
-			break;
-		case 'V':
-			printf("lvmetad version: " LVM_VERSION "\n");
-			exit(1);
-		}
-	}
-
-	daemon_start(s);
-
-	return 0;
-}
diff --git a/daemons/lvmetad/test.sh b/daemons/lvmetad/test.sh
deleted file mode 100755
index f937562..0000000
--- a/daemons/lvmetad/test.sh
+++ /dev/null
@@ -1,16 +0,0 @@
-#!/bin/bash
-
-export LD_LIBRARY_PATH="$1"
-
-test -n "$2" && {
-    rm -f /var/run/lvmetad.{socket,pid}
-    chmod +rx lvmetad
-    valgrind ./lvmetad -f &
-    PID=$!
-    sleep 1
-    ./testclient
-    kill $PID
-    exit 0
-}
-
-sudo ./test.sh "$1" .
diff --git a/daemons/lvmetad/testclient.c b/daemons/lvmetad/testclient.c
deleted file mode 100644
index 06fa332..0000000
--- a/daemons/lvmetad/testclient.c
+++ /dev/null
@@ -1,147 +0,0 @@
-/*
- * Copyright (C) 2011-2014 Red Hat, Inc.
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
-#include "tools/tool.h"
-
-#include "daemons/lvmetad/lvmetad-client.h"
-#include "lib/label/label.h"
-#include "lib/cache/lvmcache.h"
-#include "lib/metadata/metadata.h"
-
-const char *uuid1 = "abcd-efgh";
-const char *uuid2 = "bbcd-efgh";
-const char *vgid = "yada-yada";
-const char *uuid3 = "cbcd-efgh";
-
-const char *metadata2 = "{\n"
-	"id = \"yada-yada\"\n"
-	"seqno = 15\n"
-	"status = [\"READ\", \"WRITE\"]\n"
-	"flags = []\n"
-	"extent_size = 8192\n"
-	"physical_volumes {\n"
-	"    pv0 {\n"
-	"        id = \"abcd-efgh\"\n"
-	"    }\n"
-	"    pv1 {\n"
-	"        id = \"bbcd-efgh\"\n"
-	"    }\n"
-	"    pv2 {\n"
-	"        id = \"cbcd-efgh\"\n"
-	"    }\n"
-	"}\n"
-	"}\n";
-
-void _handle_reply(daemon_reply reply) {
-	const char *repl = daemon_reply_str(reply, "response", NULL);
-	const char *status = daemon_reply_str(reply, "status", NULL);
-	const char *vgid = daemon_reply_str(reply, "vgid", NULL);
-
-	fprintf(stderr, "[C] REPLY: %s\n", repl);
-	if (!strcmp(repl, "failed"))
-		fprintf(stderr, "[C] REASON: %s\n", daemon_reply_str(reply, "reason", "unknown"));
-	if (vgid)
-		fprintf(stderr, "[C] VGID: %s\n", vgid);
-	if (status)
-		fprintf(stderr, "[C] STATUS: %s\n", status);
-	daemon_reply_destroy(reply);
-}
-
-void _pv_add(daemon_handle h, const char *uuid, const char *metadata)
-{
-	daemon_reply reply = daemon_send_simple(h, "pv_add", "uuid = %s", uuid,
-						             "metadata = %b", metadata,
-						             NULL);
-	_handle_reply(reply);
-}
-
-int scan(daemon_handle h, char *fn) {
-	struct device *dev = dev_cache_get(fn, NULL);
-
-	struct label *label;
-	if (!label_read(dev, &label, 0)) {
-		fprintf(stderr, "[C] no label found on %s\n", fn);
-		return;
-	}
-
-	char uuid[64];
-	if (!id_write_format(dev->pvid, uuid, 64)) {
-		fprintf(stderr, "[C] Failed to format PV UUID for %s", dev_name(dev));
-		return;
-	}
-	fprintf(stderr, "[C] found PV: %s\n", uuid);
-	struct lvmcache_info *info = (struct lvmcache_info *) label->info;
-	struct physical_volume pv = { 0, };
-
-	if (!(info->fmt->ops->pv_read(info->fmt, dev_name(dev), &pv, 0))) {
-		fprintf(stderr, "[C] Failed to read PV %s", dev_name(dev));
-		return;
-	}
-
-	struct format_instance_ctx fic;
-	struct format_instance *fid = info->fmt->ops->create_instance(info->fmt, &fic);
-	struct metadata_area *mda;
-	struct volume_group *vg = NULL;
-	dm_list_iterate_items(mda, &info->mdas) {
-		struct volume_group *this = mda->ops->vg_read(fid, "", mda);
-		if (this && !vg || this->seqno > vg->seqno)
-			vg = this;
-	}
-	if (vg) {
-		char *buf = NULL;
-		/* TODO. This is not entirely correct, since export_vg_to_buffer
-		 * adds trailing garbage to the buffer. We may need to use
-		 * export_vg_to_config_tree and format the buffer ourselves. It
-		 * does, however, work for now, since the garbage is well
-		 * formatted and has no conflicting keys with the rest of the
-		 * request.  */
-		export_vg_to_buffer(vg, &buf);
-		daemon_reply reply =
-			daemon_send_simple(h, "pv_add", "uuid = %s", uuid,
-					      "metadata = %b", strchr(buf, '{'),
-					      NULL);
-		_handle_reply(reply);
-	}
-}
-
-void _dump_vg(daemon_handle h, const char *uuid)
-{
-	daemon_reply reply = daemon_send_simple(h, "vg_by_uuid", "uuid = %s", uuid, NULL);
-	fprintf(stderr, "[C] reply buffer: %s\n", reply.buffer);
-	daemon_reply_destroy(reply);
-}
-
-int main(int argc, char **argv) {
-	daemon_handle h = lvmetad_open();
-	/* FIXME Missing error path */
-
-	if (argc > 1) {
-		int i;
-		struct cmd_context *cmd = create_toolcontext(0, NULL, 0, 0, 1, 1);
-		for (i = 1; i < argc; ++i) {
-			const char *uuid = NULL;
-			scan(h, argv[i]);
-		}
-		destroy_toolcontext(cmd);
-		/* FIXME Missing lvmetad_close() */
-		return 0;
-	}
-
-	_pv_add(h, uuid1, NULL);
-	_pv_add(h, uuid2, metadata2);
-	_dump_vg(h, vgid);
-	_pv_add(h, uuid3, NULL);
-
-	daemon_close(h);	/* FIXME lvmetad_close? */
-	return 0;
-}
diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index f5fb0fa..d6ff8cc 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -17,7 +17,6 @@
 #include "libdaemon/client/daemon-io.h"
 #include "daemon-server.h"
 #include "lvm-version.h"
-#include "daemons/lvmetad/lvmetad-client.h"
 #include "daemons/lvmlockd/lvmlockd-client.h"
 #include "device_mapper/misc/dm-ioctl.h"
 
@@ -144,10 +143,6 @@ static const int lvmlockd_protocol_version = 1;
 static int daemon_quit;
 static int adopt_opt;
 
-static daemon_handle lvmetad_handle;
-static pthread_mutex_t lvmetad_mutex;
-static int lvmetad_connected;
-
 /*
  * We use a separate socket for dumping daemon info.
  * This will not interfere with normal operations, and allows
@@ -1009,54 +1004,6 @@ static void add_work_action(struct action *act)
 	pthread_mutex_unlock(&worker_mutex);
 }
 
-#define ERR_LVMETAD_NOT_RUNNING -200
-
-static daemon_reply send_lvmetad(const char *id, ...)
-{
-	daemon_reply reply;
-	va_list ap;
-	int retries = 0;
-	int err;
-
-	va_start(ap, id);
-
-	/*
-	 * mutex is used because all threads share a single
-	 * lvmetad connection/handle.
-	 */
-	pthread_mutex_lock(&lvmetad_mutex);
-retry:
-	if (!lvmetad_connected) {
-		lvmetad_handle = lvmetad_open(NULL);
-		if (lvmetad_handle.error || lvmetad_handle.socket_fd < 0) {
-			err = lvmetad_handle.error ?: lvmetad_handle.socket_fd;
-			pthread_mutex_unlock(&lvmetad_mutex);
-			log_debug("lvmetad_open reconnect error %d", err);
-			memset(&reply, 0, sizeof(reply));
-			reply.error = ERR_LVMETAD_NOT_RUNNING;
-			va_end(ap);
-			return reply;
-		} else {
-			log_debug("lvmetad reconnected");
-			lvmetad_connected = 1;
-		}
-	}
-
-	reply = daemon_send_simple_v(lvmetad_handle, id, ap);
-
-	/* lvmetad may have been restarted */
-	if ((reply.error == ECONNRESET) && (retries < 2)) {
-		daemon_close(lvmetad_handle);
-		lvmetad_connected = 0;
-		retries++;
-		goto retry;
-	}
-	pthread_mutex_unlock(&lvmetad_mutex);
-
-	va_end(ap);
-	return reply;
-}
-
 static int res_lock(struct lockspace *ls, struct resource *r, struct action *act, int *retry)
 {
 	struct lock *lk;
@@ -1253,6 +1200,18 @@ static int res_lock(struct lockspace *ls, struct resource *r, struct action *act
 	}
 
 	/*
+	 * lvmetad is no longer used, but the infrastructure for
+	 * distributed cache validation remains.  The points
+	 * where vg or global cache state would be invalidated
+	 * remain below and log_debug messages point out where
+	 * they would occur.
+	 *
+	 * The comments related to "lvmetad" remain because they
+	 * describe how some other local cache like lvmetad would
+	 * be invalidated here.
+	 */
+
+	/*
 	 * r is vglk: tell lvmetad to set the vg invalid
 	 * flag, and provide the new r_version.  If lvmetad finds
 	 * that its cached vg has seqno less than the value
@@ -1277,47 +1236,12 @@ static int res_lock(struct lockspace *ls, struct resource *r, struct action *act
 	 */
 
 	if (inval_meta && (r->type == LD_RT_VG)) {
-		daemon_reply reply;
-		char *uuid;
-
-		log_debug("S %s R %s res_lock set lvmetad vg version %u",
+		log_debug("S %s R %s res_lock invalidate vg state version %u",
 			  ls->name, r->name, new_version);
-	
-		if (!ls->vg_uuid[0] || !strcmp(ls->vg_uuid, "none"))
-			uuid = (char *)"none";
-		else
-			uuid = ls->vg_uuid;
-
-		reply = send_lvmetad("set_vg_info",
-				     "token = %s", "skip",
-				     "uuid = %s", uuid,
-				     "name = %s", ls->vg_name,
-				     "version = " FMTd64, (int64_t)new_version,
-				     NULL);
-
-		if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
-			if (reply.error != ERR_LVMETAD_NOT_RUNNING)
-				log_error("set_vg_info in lvmetad failed %d", reply.error);
-		}
-		daemon_reply_destroy(reply);
 	}
 
 	if (inval_meta && (r->type == LD_RT_GL)) {
-		daemon_reply reply;
-
-		log_debug("S %s R %s res_lock set lvmetad global invalid",
-			  ls->name, r->name);
-
-		reply = send_lvmetad("set_global_info",
-				     "token = %s", "skip",
-				     "global_invalid = " FMTd64, INT64_C(1),
-				     NULL);
-
-		if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
-			if (reply.error != ERR_LVMETAD_NOT_RUNNING)
-				log_error("set_global_info in lvmetad failed %d", reply.error);
-		}
-		daemon_reply_destroy(reply);
+		log_debug("S %s R %s res_lock invalidate global state", ls->name, r->name);
 	}
 
 	/*
@@ -4827,7 +4751,7 @@ static void close_client_thread(void)
 }
 
 /*
- * Get a list of all VGs with a lockd type (sanlock|dlm) from lvmetad.
+ * Get a list of all VGs with a lockd type (sanlock|dlm).
  * We'll match this list against a list of existing lockspaces that are
  * found in the lock manager.
  *
@@ -4838,6 +4762,9 @@ static void close_client_thread(void)
 
 static int get_lockd_vgs(struct list_head *vg_lockd)
 {
+	/* FIXME: get VGs some other way */
+	return -1;
+#if 0
 	struct list_head update_vgs;
 	daemon_reply reply;
 	struct dm_config_node *cn;
@@ -4994,6 +4921,7 @@ out:
 	}
 
 	return rv;
+#endif
 }
 
 static char _dm_uuid[DM_UUID_LEN];
@@ -5268,7 +5196,7 @@ static void adopt_locks(void)
 		gl_use_sanlock = 1;
 
 	list_for_each_entry(ls, &vg_lockd, list) {
-		log_debug("adopt lvmetad vg %s lock_type %s lock_args %s",
+		log_debug("adopt vg %s lock_type %s lock_args %s",
 			  ls->vg_name, lm_str(ls->lm_type), ls->vg_args);
 
 		list_for_each_entry(r, &ls->resources, list)
@@ -5333,7 +5261,7 @@ static void adopt_locks(void)
 		/*
 		 * LS in ls_found, not in vg_lockd.
 		 * An lvm lockspace found in the lock manager has no
-		 * corresponding VG in lvmetad.  This shouldn't usually
+		 * corresponding VG.  This shouldn't usually
 		 * happen, but it's possible the VG could have been removed
 		 * while the orphaned lockspace from it was still around.
 		 * Report an error and leave the ls in the lm alone.
@@ -5348,7 +5276,7 @@ static void adopt_locks(void)
 
 	/*
 	 * LS in vg_lockd, not in ls_found.
-	 * lockd vgs from lvmetad that do not have an existing lockspace.
+	 * lockd vgs that do not have an existing lockspace.
 	 * This wouldn't be unusual; we just skip the vg.
 	 * But, if the vg has active lvs, then it should have had locks
 	 * and a lockspace.  Should we attempt to join the lockspace and
@@ -5400,8 +5328,6 @@ static void adopt_locks(void)
 		memcpy(act->vg_args, ls->vg_args, MAX_ARGS);
 		act->host_id = ls->host_id;
 
-		/* set act->version from lvmetad data? */
-
 		log_debug("adopt add %s vg lockspace %s", lm_str(act->lm_type), act->vg_name);
 
 		rv = add_lockspace_thread(ls->name, act->vg_name, act->vg_uuid,
@@ -5860,24 +5786,12 @@ static int main_loop(daemon_state *ds_arg)
 	setup_worker_thread();
 	setup_restart();
 
-	pthread_mutex_init(&lvmetad_mutex, NULL);
-	lvmetad_handle = lvmetad_open(NULL);
-	if (lvmetad_handle.error || lvmetad_handle.socket_fd < 0)
-		log_debug("lvmetad_open error %d", lvmetad_handle.error);
-	else
-		lvmetad_connected = 1;
-
 	/*
 	 * Attempt to rejoin lockspaces and adopt locks from a previous
 	 * instance of lvmlockd that left behind lockspaces/locks.
 	 */
-	if (adopt_opt) {
-		/* FIXME: implement this without lvmetad */
-		if (!lvmetad_connected)
-			log_error("Cannot adopt locks without lvmetad running.");
-		else
-			adopt_locks();
-	}
+	if (adopt_opt)
+		adopt_locks();
 
 	while (1) {
 		rv = poll(pollfd, pollfd_maxi + 1, -1);
@@ -5993,7 +5907,6 @@ static int main_loop(daemon_state *ds_arg)
 	close_worker_thread();
 	close_client_thread();
 	closelog();
-	daemon_close(lvmetad_handle);
 	return 1; /* libdaemon uses 1 for success */
 }
 
diff --git a/include/Makefile.in b/include/Makefile.in
index 7993998..dd5dd68 100644
--- a/include/Makefile.in
+++ b/include/Makefile.in
@@ -71,8 +71,6 @@ CLEAN_TARGETS += \
  lvm2app.h \
  lvm2cmd.h \
  lvmcache.h \
- lvmetad-client.h \
- lvmetad.h \
  lvmlockd-client.h \
  lvmlockd.h \
  lvmnotify.h \
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 737208b..1b170ee 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -112,11 +112,6 @@ ifeq ("@HAVE_LIBDL@", "yes")
   SOURCES += misc/sharedlib.c
 endif
 
-ifeq ("@BUILD_LVMETAD@", "yes")
-  SOURCES +=\
-	cache/lvmetad.c
-endif
-
 ifeq ("@BUILD_LVMPOLLD@", "yes")
   SOURCES +=\
 	lvmpolld/lvmpolld-client.c
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index f20928b..46470a5 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -25,9 +25,6 @@
 #include "lib/format_text/format-text.h"
 #include "lib/config/config.h"
 
-#include "lib/cache/lvmetad.h"
-#include "daemons/lvmetad/lvmetad-client.h"
-
 /* One per device */
 struct lvmcache_info {
 	struct dm_list list;	/* Join VG members together */
@@ -98,21 +95,6 @@ int lvmcache_init(struct cmd_context *cmd)
 	return 1;
 }
 
-void lvmcache_seed_infos_from_lvmetad(struct cmd_context *cmd)
-{
-	if (!lvmetad_used() || _has_scanned)
-		return;
-
-	dev_cache_scan();
-
-	if (!lvmetad_pv_list_to_lvmcache(cmd)) {
-		stack;
-		return;
-	}
-
-	_has_scanned = 1;
-}
-
 void lvmcache_lock_vgname(const char *vgname, int read_only __attribute__((unused)))
 {
 	if (strcmp(vgname, VG_GLOBAL))
@@ -249,20 +231,10 @@ const struct format_type *lvmcache_fmt_from_vgname(struct cmd_context *cmd,
 	struct dm_list *devh, *tmp;
 	struct dm_list devs;
 	struct device_list *devl;
-	struct volume_group *vg;
-	const struct format_type *fmt;
 	char vgid_found[ID_LEN + 1] __attribute__((aligned(8)));
 
 	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid))) {
-		if (!lvmetad_used())
-			return NULL; /* too bad */
-		/* If we don't have the info but we have lvmetad, we can ask
-		 * there before failing. */
-		if ((vg = lvmetad_vg_lookup(cmd, vgname, vgid))) {
-			fmt = vg->fid->fmt;
-			release_vg(vg);
-			return fmt;
-		}
+		stack;
 		return NULL;
 	}
 
@@ -802,9 +774,6 @@ int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
 
-	if (lvmetad_used())
-		return 1;
-
 	dm_list_init(&devs);
 
 	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid)))
@@ -880,12 +849,6 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 
 	int r = 0;
 
-	if (lvmetad_used()) {
-		if (!label_scan_setup_bcache())
-			return 0;
-		return 1;
-	}
-
 	log_debug_cache("Finding VG info");
 
 	/* Avoid recursion when a PVID can't be found! */
@@ -969,11 +932,6 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 		 * the same device.
 		 */
 		_warn_duplicate_devs(cmd);
-
-		if (!_found_duplicate_pvs && lvmetad_used()) {
-			log_warn("WARNING: Disabling lvmetad cache which does not support duplicate PVs.");
-			lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_DUPLICATES);
-		}
 	}
 
 	r = 1;
@@ -993,14 +951,8 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 }
 
 /*
- * When not using lvmetad, lvmcache_label_scan() detects duplicates in
- * the basic label_scan(), then filters out some dups, and chooses
- * preferred duplicates to use.
- *
- * When using lvmetad, pvscan --cache does not use lvmcache_label_scan(),
- * only label_scan() which detects the duplicates.  This function is used
- * after pvscan's label_scan() to filter out some dups, print any warnings,
- * and disable lvmetad if any dups are left.
+ * lvmcache_label_scan() detects duplicates in the basic label_scan(), then
+ * filters out some dups, and chooses preferred duplicates to use.
  */
 
 void lvmcache_pvscan_duplicate_check(struct cmd_context *cmd)
@@ -1024,19 +976,15 @@ void lvmcache_pvscan_duplicate_check(struct cmd_context *cmd)
 	_filter_duplicate_devs(cmd);
 
 	/*
-	 * If no more dups after ignoring some, then we can use lvmetad.
+	 * no more dups after ignoring some
 	 */
 	if (!_found_duplicate_pvs)
 		return;
 
-	/* Duplicates are found where we would have to pick one, so disable lvmetad. */
+	/* Duplicates are found where we would have to pick one. */
 
 	dm_list_iterate_items(devl, &_unused_duplicate_devs)
 		log_warn("WARNING: found device with duplicate %s", dev_name(devl->dev));
-
-	log_warn("WARNING: Disabling lvmetad cache which does not support duplicate PVs.");
-	lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_DUPLICATES);
-	lvmetad_make_unused(cmd);
 }
 
 int lvmcache_get_vgnameids(struct cmd_context *cmd, int include_internal,
@@ -2192,9 +2140,6 @@ int lvmcache_is_orphan(struct lvmcache_info *info) {
 int lvmcache_vgid_is_cached(const char *vgid) {
 	struct lvmcache_vginfo *vginfo;
 
-	if (lvmetad_used())
-		return 1;
-
 	vginfo = lvmcache_vginfo_from_vgid(vgid);
 
 	if (!vginfo || !vginfo->vgname)
@@ -2285,9 +2230,6 @@ int lvmcache_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const ch
 	struct lvmcache_vginfo *vginfo;
 	int ret = 0;
 
-	if (lvmetad_used())
-		return lvmetad_vg_is_foreign(cmd, vgname, vgid);
-
 	if ((vginfo = lvmcache_vginfo_from_vgid(vgid)))
 		ret = !is_system_id_allowed(cmd, vginfo->system_id);
 
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 92e27a2..ba60405 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -64,7 +64,6 @@ struct lvmcache_vgsummary {
 };
 
 int lvmcache_init(struct cmd_context *cmd);
-void lvmcache_allow_reads_with_lvmetad(void);
 
 void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset);
 
@@ -106,8 +105,6 @@ const char *lvmcache_vgname_from_info(struct lvmcache_info *info);
 const struct format_type *lvmcache_fmt_from_info(struct lvmcache_info *info);
 int lvmcache_vgs_locked(void);
 
-void lvmcache_seed_infos_from_lvmetad(struct cmd_context *cmd);
-
 int lvmcache_get_vgnameids(struct cmd_context *cmd, int include_internal,
                           struct dm_list *vgnameids);
 
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
deleted file mode 100644
index a75b448..0000000
--- a/lib/cache/lvmetad.c
+++ /dev/null
@@ -1,3075 +0,0 @@
-/*
- * Copyright (C) 2012 Red Hat, Inc.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU Lesser General Public License v.2.1.
- *
- * You should have received a copy of the GNU Lesser General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#include "lib/misc/lib.h"
-#include "lib/commands/toolcontext.h"
-#include "lib/metadata/metadata.h"
-#include "lib/device/device.h"
-#include "lib/cache/lvmetad.h"
-#include "lib/cache/lvmcache.h"
-#include "daemons/lvmetad/lvmetad-client.h"
-#include "lib/format_text/format-text.h"
-#include "lib/misc/crc.h"
-#include "lib/misc/lvm-signal.h"
-#include "lib/locking/lvmlockd.h"
-#include "lib/datastruct/str_list.h"
-
-#include <time.h>
-
-static daemon_handle _lvmetad = { .error = 0 };
-static int _lvmetad_use = 0;
-static int _lvmetad_connected = 0;
-static int _lvmetad_daemon_pid = 0;
-
-static char *_lvmetad_token = NULL;
-static const char *_lvmetad_socket = NULL;
-static struct cmd_context *_lvmetad_cmd = NULL;
-static int64_t _lvmetad_update_timeout;
-
-static struct volume_group *_lvmetad_pvscan_vg(struct cmd_context *cmd, struct volume_group *vg, const char *vgid, struct format_type *fmt);
-
-static uint64_t _monotonic_seconds(void)
-{
-	struct timespec ts;
-
-	if (clock_gettime(CLOCK_MONOTONIC, &ts) < 0)
-		return 0;
-	return ts.tv_sec;
-}
-
-static int _log_debug_inequality(const char *name, struct dm_config_node *a, struct dm_config_node *b)
-{
-	int result = 0;
-	int final_result = 0;
-
-	if (a->v && b->v) {
-		result = compare_value(a->v, b->v);
-		if (result) {
-			struct dm_config_value *av = a->v;
-			struct dm_config_value *bv = b->v;
-
-			if (!strcmp(a->key, b->key)) {
-				if (a->v->type == DM_CFG_STRING && b->v->type == DM_CFG_STRING)
-					log_debug_lvmetad("VG %s metadata inequality at %s / %s: %s / %s",
-							  name, a->key, b->key, av->v.str, bv->v.str);
-				else if (a->v->type == DM_CFG_INT && b->v->type == DM_CFG_INT)
-					log_debug_lvmetad("VG %s metadata inequality at %s / %s: " FMTd64 " / " FMTd64,
-							  name, a->key, b->key, av->v.i, bv->v.i);
-				else
-					log_debug_lvmetad("VG %s metadata inequality at %s / %s: type %d / type %d",
-							  name, a->key, b->key, av->type, bv->type);
-			} else {
-				log_debug_lvmetad("VG %s metadata inequality at %s / %s", name, a->key, b->key);
-			}
-			final_result = result;
-		}
-	}
-
-	if (a->v && !b->v) {
-		log_debug_lvmetad("VG %s metadata inequality at %s / %s", name, a->key, b->key);
-		final_result = 1;
-	}
-
-	if (!a->v && b->v) {
-		log_debug_lvmetad("VG %s metadata inequality at %s / %s", name, a->key, b->key);
-		final_result = -1;
-	}
-
-	if (a->child && b->child) {
-		result = _log_debug_inequality(name, a->child, b->child);
-		if (result)
-			final_result = result;
-	}
-
-	if (a->sib && b->sib) {
-		result = _log_debug_inequality(name, a->sib, b->sib);
-		if (result)
-			final_result = result;
-	}
-	
-
-	if (a->sib && !b->sib) {
-		log_debug_lvmetad("VG %s metadata inequality at %s / %s", name, a->key, b->key);
-		final_result = 1;
-	}
-
-	if (!a->sib && b->sib) {
-		log_debug_lvmetad("VG %s metadata inequality at %s / %s", name, a->key, b->key);
-		final_result = -1;
-	}
-
-	return final_result;
-}
-
-void lvmetad_disconnect(void)
-{
-	if (_lvmetad_connected)
-		daemon_close(_lvmetad);
-
-	_lvmetad_connected = 0;
-	_lvmetad_use = 0;
-	_lvmetad_cmd = NULL;
-}
-
-int lvmetad_connect(struct cmd_context *cmd)
-{
-	if (!lvmetad_socket_present()) {
-		log_debug_lvmetad("Failed to connect to lvmetad: socket not present.");
-		_lvmetad_connected = 0;
-		_lvmetad_use = 0;
-		_lvmetad_cmd = NULL;
-		return 0;
-	}
-
-	_lvmetad_update_timeout = find_config_tree_int(cmd, global_lvmetad_update_wait_time_CFG, NULL);
-
-	_lvmetad = lvmetad_open(_lvmetad_socket);
-
-	if (_lvmetad.socket_fd >= 0 && !_lvmetad.error) {
-		log_debug_lvmetad("Successfully connected to lvmetad on fd %d.",
-				  _lvmetad.socket_fd);
-		_lvmetad_connected = 1;
-		_lvmetad_use = 1;
-		_lvmetad_cmd = cmd;
-		return 1;
-	}
-
-	log_debug_lvmetad("Failed to connect to lvmetad: %s", strerror(_lvmetad.error));
-	_lvmetad_connected = 0;
-	_lvmetad_use = 0;
-	_lvmetad_cmd = NULL;
-
-	return 0;
-}
-
-int lvmetad_used(void)
-{
-	return _lvmetad_use;
-}
-
-void lvmetad_make_unused(struct cmd_context *cmd)
-{
-	lvmetad_disconnect();
-
-	if (cmd && !refresh_filters(cmd))
-		stack;
-}
-
-int lvmetad_pidfile_present(void)
-{
-	const char *pidfile = getenv("LVM_LVMETAD_PIDFILE") ?: LVMETAD_PIDFILE;
-
-	return !access(pidfile, F_OK);
-}
-
-int lvmetad_socket_present(void)
-{
-	const char *socket = _lvmetad_socket ?: LVMETAD_SOCKET;
-	int r;
-
-	if ((r = access(socket, F_OK)) && errno != ENOENT)
-		log_sys_error("access", socket);
-
-	return !r;
-}
-
-void lvmetad_set_socket(const char *sock)
-{
-	_lvmetad_socket = sock;
-}
-
-/*
- * Use a crc of the strings in the filter as the lvmetad token.
- */
-void lvmetad_set_token(const struct dm_config_value *filter)
-{
-	int ft = 0;
-
-	free(_lvmetad_token);
-
-	while (filter && filter->type == DM_CFG_STRING) {
-		ft = calc_crc(ft, (const uint8_t *) filter->v.str, strlen(filter->v.str));
-		filter = filter->next;
-	}
-
-	if (dm_asprintf(&_lvmetad_token, "filter:%u", ft) < 0)
-		log_warn("WARNING: Failed to set lvmetad token. Out of memory?");
-}
-
-void lvmetad_release_token(void)
-{
-	free(_lvmetad_token);
-	_lvmetad_token = NULL;
-}
-
-/*
- * Check if lvmetad's token matches our token.  The token is a hash of the
- * global filter used to populate lvmetad.  The lvmetad token was set by the
- * last command to populate lvmetad, and it was set to the hash of the global
- * filter that command used when scanning to populate lvmetad.
- *
- * Our token is a hash of the global filter this command is using.
- *
- * If the lvmetad token is not set (or "none"), then lvmetad has not been
- * populated.  If the lvmetad token is "update in progress", then lvmetad is
- * currently being populated -- this should be temporary, so wait for a while
- * for the current update to finish and then compare our token with the new one
- * (hopefully it will match).  If the lvmetad token otherwise differs from
- * ours, then lvmetad was populated using a different global filter that we are
- * using.
- *
- * Return 1 if the lvmetad token matches ours.  We can use it as is.
- *
- * Return 0 if the lvmetad token does not match ours (lvmetad is empty or
- * populated using a different global filter).  The caller will repopulate
- * lvmetad (via lvmetad_pvscan_all_devs) before using lvmetad.
- *
- * If we time out waiting for an lvmetad update to finish, then disable this
- * command's use of lvmetad and return 0.
- */
-
-int lvmetad_token_matches(struct cmd_context *cmd)
-{
-	daemon_reply reply;
-	const char *daemon_token;
-	unsigned int delay_usec = 0;
-	unsigned int wait_sec = 0;
-	uint64_t now = 0, wait_start = 0;
-	int ret = 1;
-
-	wait_sec = (unsigned int)_lvmetad_update_timeout;
-
-retry:
-	log_debug_lvmetad("Sending lvmetad get_global_info");
-
-	reply = daemon_send_simple(_lvmetad, "get_global_info",
-				   "token = %s", "skip",
-				   "pid = " FMTd64, (int64_t)getpid(),
-				   "cmd = %s", get_cmd_name(),
-				   NULL);
-	if (reply.error) {
-		log_warn("WARNING: Not using lvmetad after send error (%d).", reply.error);
-		goto fail;
-	}
-
-	if (strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
-		log_warn("WARNING: Not using lvmetad after response error.");
-		goto fail;
-	}
-
-	if (!(daemon_token = daemon_reply_str(reply, "token", NULL))) {
-		log_warn("WARNING: Not using lvmetad with older version."); 
-		goto fail;
-	}
-
-	_lvmetad_daemon_pid = (int)daemon_reply_int(reply, "daemon_pid", 0);
-
-	/*
-	 * If lvmetad is being updated by another command, then sleep and retry
-	 * until the token shows the update is done, and go on to the token
-	 * comparison.
-	 *
-	 * Between retries, sleep for a random period between 1 and 2 seconds.
-	 * Retry in this way for up to a configurable period of time.
-	 */
-	if (!strcmp(daemon_token, LVMETAD_TOKEN_UPDATE_IN_PROGRESS)) {
-		if (!(now = _monotonic_seconds()))
-			goto fail;
-
-		if (!wait_start)
-			wait_start = now;
-
-		if (now - wait_start > wait_sec) {
-			log_warn("WARNING: Not using lvmetad after %u sec lvmetad_update_wait_time.", wait_sec);
-			goto fail;
-		}
-
-		log_warn("WARNING: lvmetad is being updated, retrying (setup) for %u more seconds.",
-			 wait_sec - (unsigned int)(now - wait_start));
-
-		/* Delay a random period between 1 and 2 seconds. */
-		delay_usec = 1000000 + lvm_even_rand(&_lvmetad_cmd->rand_seed, 1000000);
-		usleep(delay_usec);
-		daemon_reply_destroy(reply);
-		goto retry;
-	}
-
-	/*
-	 * lvmetad is empty, not yet populated.
-	 * The caller should do a disk scan to populate lvmetad.
-	 */
-	if (!strcmp(daemon_token, "none")) {
-		ret = 0;
-		goto out;
-	}
-
-	/*
-	 * lvmetad has an unmatching token; it was last populated using
-	 * a different global filter.
-	 * The caller should do a disk scan to populate lvmetad with
-	 * our global filter.
-	 */
-	if (strcmp(daemon_token, _lvmetad_token)) {
-		ret = 0;
-		goto out;
-	}
-
-out:
-	daemon_reply_destroy(reply);
-	return ret;
-
-fail:
-	daemon_reply_destroy(reply);
-	/* The command will not use lvmetad and will revert to scanning. */
-	lvmetad_make_unused(cmd);
-	return 0;
-}
-
-/*
- * Wait up to lvmetad_update_wait_time for the lvmetad updating state to be
- * finished.
- *
- * Return 0 if lvmetad is not updating or there's an error and we can't tell.
- * Return 1 if lvmetad is updating.
- */
-static int _lvmetad_is_updating(struct cmd_context *cmd, int do_wait)
-{
-	daemon_reply reply;
-	const char *daemon_token;
-	unsigned int wait_sec = 0;
-	uint64_t now = 0, wait_start = 0;
-	int ret = 0;
-
-	wait_sec = (unsigned int)_lvmetad_update_timeout;
-retry:
-	log_debug_lvmetad("Sending lvmetad get_global_info");
-
-	reply = daemon_send_simple(_lvmetad, "get_global_info",
-				   "token = %s", "skip",
-				   "pid = " FMTd64, (int64_t)getpid(),
-				   "cmd = %s", get_cmd_name(),
-				   NULL);
-	if (reply.error)
-		goto out;
-
-	if (strcmp(daemon_reply_str(reply, "response", ""), "OK"))
-		goto out;
-
-	if (!(daemon_token = daemon_reply_str(reply, "token", NULL)))
-		goto out;
-
-	if (!strcmp(daemon_token, LVMETAD_TOKEN_UPDATE_IN_PROGRESS)) {
-		ret = 1;
-
-		if (!do_wait)
-			goto out;
-
-		if (!(now = _monotonic_seconds()))
-			goto out;
-
-		if (!wait_start)
-			wait_start = now;
-
-		if (now - wait_start >= wait_sec)
-			goto out;
-
-		log_warn("WARNING: lvmetad is being updated, waiting for %u more seconds.",
-			 wait_sec - (unsigned int)(now - wait_start));
-
-		usleep(1000000);
-		daemon_reply_destroy(reply);
-		goto retry;
-	} else {
-		ret = 0;
-	}
-
-out:
-	daemon_reply_destroy(reply);
-	return ret;
-}
-
-static daemon_reply _lvmetad_send(struct cmd_context *cmd, const char *id, ...)
-{
-	va_list ap;
-	daemon_reply reply = { 0 };
-	daemon_request req;
-	const char *token_expected;
-	unsigned int delay_usec;
-	unsigned int wait_sec = 0;
-	uint64_t now = 0, wait_start = 0;
-	int daemon_in_update;
-	int we_are_in_update;
-
-	if (!_lvmetad_connected || !_lvmetad_use) {
-		reply.error = ECONNRESET;
-		return reply;
-	}
-
-	wait_sec = (unsigned int)_lvmetad_update_timeout;
-retry:
-	req = daemon_request_make(id);
-
-	if (!daemon_request_extend(req,
-				   "token = %s", _lvmetad_token ?: "none",
-				   "update_timeout = " FMTd64, (int64_t)wait_sec,
-				   "pid = " FMTd64, (int64_t)getpid(),
-				   "cmd = %s", get_cmd_name(),
-				   NULL)) {
-		reply.error = ENOMEM;
-		return reply;
-	}
-
-	va_start(ap, id);
-	daemon_request_extend_v(req, ap);
-	va_end(ap);
-
-	reply = daemon_send(_lvmetad, req);
-
-	daemon_request_destroy(req);
-
-	if (reply.error == ECONNRESET)
-		log_warn("WARNING: lvmetad connection failed, cannot reconnect."); 
-
-	/*
-	 * For the "token_update" message, the result is handled entirely
-	 * by the _token_update() function, so return the reply immediately.
-	 */
-	if (!strcmp(id, "token_update"))
-		return reply;
-
-	/*
-	 * For other messages it may be useful to retry and resend the
-	 * message, so check for that case before returning the reply.
-	 * The reply will be checked further in lvmetad_handle_reply.
-	 */
-
-	if (reply.error)
-		return reply;
-
-	if (!strcmp(daemon_reply_str(reply, "response", ""), "token_mismatch")) {
-		token_expected = daemon_reply_str(reply, "expected", "");
-		daemon_in_update = !strcmp(token_expected, LVMETAD_TOKEN_UPDATE_IN_PROGRESS);
-		we_are_in_update = !strcmp(_lvmetad_token, LVMETAD_TOKEN_UPDATE_IN_PROGRESS);
-
-		if (daemon_in_update && !we_are_in_update) {
-			/*
-			 * Another command is updating lvmetad, and we cannot
-			 * use lvmetad until the update is finished.  Retry our
-			 * request for a while; the update should finish
-			 * shortly.  This should not usually happen because
-			 * this command already checked that the token is
-			 * usable in lvmetad_token_matches(), but it's possible
-			 * for another command's rescan to slip in between the
-			 * time we call lvmetad_token_matches() and the time we
-			 * get here to lvmetad_send().
-			 */
-
-			if (!(now = _monotonic_seconds()))
-				goto out;
-
-			if (!wait_start)
-				wait_start = now;
-
-			if (!wait_sec || (now - wait_start >= wait_sec)) {
-				log_warn("WARNING: Cannot use lvmetad after %u sec lvmetad_update_wait_time.", wait_sec);
-				goto out;
-			}
-
-			log_warn("WARNING: lvmetad is being updated, retrying (%s) for %u more seconds.",
-				 id, wait_sec - (unsigned int)(now - wait_start));
-
-			/* Delay a random period between 1 and 2 seconds. */
-			delay_usec = 1000000 + lvm_even_rand(&_lvmetad_cmd->rand_seed, 1000000);
-			usleep(delay_usec);
-			daemon_reply_destroy(reply);
-			goto retry;
-
-		} else {
-			/* See lvmetad_handle_reply for handling other cases. */
-		}
-	}
-out:
-	return reply;
-}
-
-/*
- * token_update happens when starting or ending an lvmetad update.
- * When starting we set the token to "update in progress".
- * When ending we set the token to our filter:<hash>.
- *
- * From the perspective of a command, the lvmetad state is one of:
- * "none" - the lvmetad cache is not populated and an update is required.
- * "filter:<matching_hash>" - the command with can use the lvmetad cache.
- * "filter:<unmatching_hash>" - the lvmetad cache must be updated to be used.
- * "update in progress" - a command is updating the lvmetad cache.
- *
- * . If none, the command will update (scan and populate lvmetad),
- *   then use the cache.
- *
- * . If filter is matching, the command will use the cache.
- *
- * . If filter is unmatching, the command will update (scan and
- *   populate lvmetad), then use the cache.
- *
- * . If update in progress, the command will wait for a while for the state
- *   to become non-updating.  If it changes, see above, if it doesn't change,
- *   then the command either reverts to not using lvmetad, or does an update
- *   (scan and populate lvmetad) and then uses the cache.
- *
- * A command that is explicitly intended to update the cache will always do
- * that (it may wait for a while first to allow a current update to complete).
- * A command that is not explicitly intended to update the cache may choose
- * to revert to scanning and not use lvmetad.
- *
- * Because two different updates from two commands can potentially overlap,
- * lvmetad saves the pid of the latest update to start, so it can reject messages
- * from preempted updates.  This prevents an invalid mix of two different updates.
- * (The command makes use of the update_pid to print more informative messages.)
- *
- * If lvmetad detects that a command doing an update is taking too long, it will
- * change the token from "update in progress" to "none", which means a new update
- * is required, causing the next command to do an update.  This effectively
- * cancels/preempts a slow/stuck update, and helps to automatically resolve
- * some failure cases.
- */
-
-static int _token_update(int *replaced_update)
-{
-	daemon_reply reply;
-	const char *token_expected;
-	const char *prev_token;
-	const char *reply_str;
-	int update_pid;
-	int ending_our_update;
-
-	log_debug_lvmetad("Sending lvmetad token_update %s", _lvmetad_token);
-	reply = _lvmetad_send(NULL, "token_update", NULL);
-
-	if (replaced_update)
-		*replaced_update = 0;
-
-	if (reply.error) {
-		log_warn("WARNING: lvmetad token update error: %s", strerror(reply.error));
-		daemon_reply_destroy(reply);
-		return 0;
-	}
-
-	update_pid = (int)daemon_reply_int(reply, "update_pid", 0);
-	reply_str = daemon_reply_str(reply, "response", "");
-
-	/*
-	 * A mismatch can only happen when this command attempts to set the
-	 * token to filter:<hash> at the end of its update, but the update has
-	 * been preempted in lvmetad by a new one (from update_pid).
-	 */
-	if (!strcmp(reply_str, "token_mismatch")) {
-		token_expected = daemon_reply_str(reply, "expected", "");
-
-		ending_our_update = strcmp(_lvmetad_token, LVMETAD_TOKEN_UPDATE_IN_PROGRESS);
-
-		log_debug_lvmetad("Received token update mismatch expected \"%s\" our token \"%s\" update_pid %d our pid %d",
-				  token_expected, _lvmetad_token, update_pid, getpid());
-
-		if (ending_our_update && (update_pid != getpid())) {
-			log_warn("WARNING: lvmetad was updated by another command (pid %d).", update_pid);
-		} else {
-			/*
-			 * Shouldn't happen.
-			 * If we're ending our update and our pid matches the update_pid,
-			 * then there would not be a mismatch.
-			 * If we're starting a new update, lvmetad never returns a
-			 * token mismatch.
-			 * In any case, it doesn't hurt to just return an error here.
-			 */
-			log_error(INTERNAL_ERROR "lvmetad token update mismatch pid %d matches our own pid %d", update_pid, getpid());
-		}
-
-		daemon_reply_destroy(reply);
-		return 0;
-	}
-
-	if (strcmp(reply_str, "OK")) {
-		log_error("Failed response from lvmetad for token update.");
-		daemon_reply_destroy(reply);
-		return 0;
-	}
-
-	if ((prev_token = daemon_reply_str(reply, "prev_token", NULL))) {
-		if (!strcmp(prev_token, LVMETAD_TOKEN_UPDATE_IN_PROGRESS))
-			if (replaced_update && (update_pid != getpid()))
-				*replaced_update = 1;
-	}
-
-	daemon_reply_destroy(reply);
-	return 1;
-}
-
-/*
- * Helper; evaluate the reply from lvmetad, check for errors, print diagnostics
- * and return a summary success/failure exit code.
- *
- * If found is set, *found indicates whether or not device exists,
- * and missing device is not treated as an error.
- */
-static int _lvmetad_handle_reply(daemon_reply reply, const char *id, const char *object, int *found)
-{
-	const char *token_expected;
-	const char *action;
-	const char *reply_str;
-	int action_modifies = 0;
-	int daemon_in_update;
-	int we_are_in_update;
-	int update_pid;
-
-	if (!id)
-		action = "<none>";
-	else if (!strcmp(id, "pv_list"))
-		action = "list PVs";
-	else if (!strcmp(id, "vg_list"))
-		action = "list VGs";
-	else if (!strcmp(id, "vg_lookup"))
-		action = "lookup VG";
-	else if (!strcmp(id, "pv_lookup"))
-		action = "lookup PV";
-	else if (!strcmp(id, "pv_clear_all"))
-		action = "clear info about all PVs";
-	else if (!strcmp(id, "vg_clear_outdated_pvs"))
-		action = "clear the list of outdated PVs";
-	else if (!strcmp(id, "set_vg_info"))
-		action = "set VG info";
-	else if (!strcmp(id, "vg_update"))
-		action = "update VG";
-	else if (!strcmp(id, "vg_remove"))
-		action = "remove VG";
-	else if (!strcmp(id, "pv_found")) {
-		action = "update PV";
-		action_modifies = 1;
-	} else if (!strcmp(id, "pv_gone")) {
-		action = "drop PV";
-		action_modifies = 1;
-	} else {
-		log_error(INTERNAL_ERROR "Unchecked lvmetad message %s.", id);
-		action = "action unknown";
-	}
-
-	if (reply.error) {
-		log_error("lvmetad cannot be used due to error: %s", strerror(reply.error));
-		goto fail;
-	}
-
-	/*
-	 * Errors related to token mismatch.
-	 */
-	reply_str = daemon_reply_str(reply, "response", "");
-	if (!strcmp(reply_str, "token_mismatch")) {
-
-		token_expected = daemon_reply_str(reply, "expected", "");
-		update_pid = (int)daemon_reply_int(reply, "update_pid", 0);
-
-		log_debug("lvmetad token mismatch, expected \"%s\" our token \"%s\"",
-			  token_expected, _lvmetad_token);
-
-		daemon_in_update = !strcmp(token_expected, LVMETAD_TOKEN_UPDATE_IN_PROGRESS);
-		we_are_in_update = !strcmp(_lvmetad_token, LVMETAD_TOKEN_UPDATE_IN_PROGRESS);
-
-		if (daemon_in_update && we_are_in_update) {
-
-			/*
-			 * When we do not match the update_pid, it means our
-			 * update was cancelled and another process is now
-			 * updating the cache.
-			 */
-
-			if (update_pid != getpid()) {
-				log_warn("WARNING: lvmetad is being updated by another command (pid %d).", update_pid);
-			} else {
-				/* Shouldn't happen */
-				log_error(INTERNAL_ERROR "lvmetad update by pid %d matches our own pid %d", update_pid, getpid());
-			}
-			/* We don't care if the action was modifying during a token update. */
-			action_modifies = 0;
-			goto fail;
-
-		} else if (daemon_in_update && !we_are_in_update) {
-
-			/*
-			 * Another command is updating lvmetad, and we cannot
-			 * use lvmetad until the update is finished.
-			 * lvmetad_send resent this message up to the limit and
-			 * eventually gave up.  The caller may choose to not
-			 * use lvmetad at this point and revert to scanning.
-			 */
-
-			log_warn("WARNING: lvmetad is being updated and cannot be used.");
-			goto fail;
-
-		} else if (!daemon_in_update && we_are_in_update) {
-
-			/*
-			 * We are updating lvmetad after setting the token to
-			 * "update in progress", but lvmetad has a non-update
-			 * token and is rejecting our update messages.  This
-			 * must mean that lvmetad cancelled our update (we were
-			 * probably too slow, taking longer than the timeout),
-			 * so another command completed an update and set the
-			 * token based on its filter.  Here we've attempt to
-			 * continue our cache update, and find we've been
-			 * preempted, so we should just abort our failed
-			 * update.
-			 */
-
-			log_warn("WARNING: lvmetad was updated by another command.");
-			/* We don't care if the action was modifying during a token update. */
-			action_modifies = 0;
-			goto fail;
-
-		} else if (!daemon_in_update && !we_are_in_update) {
-
-			/*
-			 * Another command has updated the lvmetad cache, and
-			 * has done so using a different device filter from our
-			 * own, which has made the lvmetad token and our token
-			 * not match.  This should not usually happen because
-			 * this command has already checked for a matching token
-			 * in lvmetad_token_matches(), but it's possible for
-			 * another command's rescan to slip in between the time
-			 * we call lvmetad_token_matches() and the time we get
-			 * here to lvmetad_send().  With a mismatched token
-			 * (different set of devices), we cannot use the lvmetad
-			 * cache.
-			 *
-			 * FIXME: it would be nice to have this command ignore
-			 * lvmetad at this point and revert to disk scanning,
-			 * but the layers above lvmetad_send are not yet able
-			 * to switch modes in the middle of processing.
-			 *
-			 * (The advantage of lvmetad_check_token is that it
-			 * can rescan to get the token in sync, or if that
-			 * fails it can make the command revert to scanning
-			 * from the start.)
-			 */
-
-			log_warn("WARNING: Cannot use lvmetad while it caches different devices.");
-			goto fail;
-		}
-	}
-
-	/*
-	 * Non-token-mismatch related error checking.
-	 */
-
-	/* All OK? */
-	if (!strcmp(reply_str, "OK")) {
-		if (found)
-			*found = 1;
-		return 1;
-	}
-
-	/* Unknown device permitted? */
-	if (found && !strcmp(reply_str, "unknown")) {
-		log_very_verbose("Request to %s %s%sin lvmetad did not find any matching object.",
-				 action, object, *object ? " " : "");
-		*found = 0;
-		return 1;
-	}
-
-	/* Multiple VGs with the same name were found. */
-	if (found && !strcmp(reply_str, "multiple")) {
-		log_very_verbose("Request to %s %s%sin lvmetad found multiple matching objects.",
-				 action, object, *object ? " " : "");
-		if (found)
-			*found = 2;
-		return 1;
-	}
-
-	/*
-	 * Generic error message for error cases not specifically checked above.
-	 */
-	log_error("Request to %s %s%sin lvmetad gave response %s. Reason: %s",
-		  action, object, *object ? " " : "", 
-		  daemon_reply_str(reply, "response", "<missing>"),
-		  daemon_reply_str(reply, "reason", "<missing>"));
-fail:
-	/*
-	 * If the failed lvmetad message was updating lvmetad with new metadata
-	 * that has been changed by this command, it is important to restart
-	 * lvmetad (or at least rescan.)  (An lvmetad update that is just
-	 * scanning disks to populate the cache is not a problem, so we try to
-	 * avoid printing a "corruption" warning in that case.)
-	 */
-
-	if (action_modifies) {
-		/*
-		 * FIXME: experiment with killing the lvmetad process here, e.g.
-		 * kill(_lvmetad_daemon_pid, SIGKILL);
-		 */
-		log_warn("WARNING: To avoid corruption, restart lvmetad (or disable with use_lvmetad=0).");
-	}
-
-	return 0;
-}
-
-static int _read_mda(struct lvmcache_info *info,
-		     struct format_type *fmt,
-		     const struct dm_config_node *cn)
-{
-	struct metadata_area_ops *ops;
-
-	dm_list_iterate_items(ops, &fmt->mda_ops)
-		if (ops->mda_import_text && ops->mda_import_text(info, cn))
-			return 1;
-
-	return 0;
-}
-
-static int _pv_populate_lvmcache(struct cmd_context *cmd,
-				 struct dm_config_node *cn,
-				 struct format_type *fmt, dev_t fallback)
-{
-	struct device *dev;
-	struct id pvid, vgid;
-	char mda_id[32];
-	char da_id[32];
-	int i = 0;
-	struct dm_config_node *mda, *da;
-	uint64_t offset, size;
-	struct lvmcache_info *info;
-	const char *pvid_txt = dm_config_find_str(cn->child, "id", NULL),
-		   *vgid_txt = dm_config_find_str(cn->child, "vgid", NULL),
-		   *vgname = dm_config_find_str(cn->child, "vgname", NULL),
-		   *fmt_name = dm_config_find_str(cn->child, "format", NULL);
-	dev_t devt = dm_config_find_int(cn->child, "device", 0);
-	uint64_t devsize = dm_config_find_int64(cn->child, "dev_size", 0),
-		 label_sector = dm_config_find_int64(cn->child, "label_sector", 0);
-	uint32_t ext_flags = (uint32_t) dm_config_find_int64(cn->child, "ext_flags", 0);
-	uint32_t ext_version = (uint32_t) dm_config_find_int64(cn->child, "ext_version", 0);
-
-	if (!fmt && fmt_name)
-		fmt = get_format_by_name(cmd, fmt_name);
-
-	if (!fmt) {
-		log_error("PV %s not recognised. Is the device missing?", pvid_txt);
-		return 0;
-	}
-
-	dev = dev_cache_get_by_devt(cmd, devt, cmd->filter);
-	if (!dev && fallback)
-		dev = dev_cache_get_by_devt(cmd, fallback, cmd->filter);
-
-	if (!dev) {
-		log_warn("WARNING: Device for PV %s not found or rejected by a filter.", pvid_txt);
-		return 0;
-	}
-
-	if (!pvid_txt || !id_read_format(&pvid, pvid_txt)) {
-		log_error("Missing or ill-formatted PVID for PV: %s.", pvid_txt);
-		return 0;
-	}
-
-	if (vgid_txt) {
-		if (!id_read_format(&vgid, vgid_txt))
-			return_0;
-	} else
-		/* NB uuid is short and NUL-terminated. */
-		(void) dm_strncpy((char*)&vgid, fmt->orphan_vg_name, sizeof(vgid));
-
-	if (!vgname)
-		vgname = fmt->orphan_vg_name;
-
-	if (!(info = lvmcache_add(fmt->labeller, (const char *)&pvid, dev,
-				  vgname, (const char *)&vgid, 0)))
-		return_0;
-
-	lvmcache_get_label(info)->sector = label_sector;
-	lvmcache_get_label(info)->dev = dev;
-	lvmcache_set_device_size(info, devsize);
-	lvmcache_del_das(info);
-	lvmcache_del_mdas(info);
-	lvmcache_del_bas(info);
-
-	do {
-		sprintf(mda_id, "mda%d", i);
-		mda = dm_config_find_node(cn->child, mda_id);
-		if (mda)
-			_read_mda(info, fmt, mda);
-		++i;
-	} while (mda);
-
-	i = 0;
-	do {
-		sprintf(da_id, "da%d", i);
-		da = dm_config_find_node(cn->child, da_id);
-		if (da) {
-			if (!dm_config_get_uint64(da->child, "offset", &offset)) return_0;
-			if (!dm_config_get_uint64(da->child, "size", &size)) return_0;
-			lvmcache_add_da(info, offset, size);
-		}
-		++i;
-	} while (da);
-
-	i = 0;
-	do {
-		sprintf(da_id, "ba%d", i);
-		da = dm_config_find_node(cn->child, da_id);
-		if (da) {
-			if (!dm_config_get_uint64(da->child, "offset", &offset)) return_0;
-			if (!dm_config_get_uint64(da->child, "size", &size)) return_0;
-			lvmcache_add_ba(info, offset, size);
-		}
-		++i;
-	} while (da);
-
-	lvmcache_set_ext_flags(info, ext_flags);
-	lvmcache_set_ext_version(info, ext_version);
-
-	return 1;
-}
-
-static int _pv_update_struct_pv(struct physical_volume *pv, struct format_instance *fid)
-{
-	struct lvmcache_info *info;
-
-	if ((info = lvmcache_info_from_pvid((const char *)&pv->id, pv->dev, 0))) {
-		pv->label_sector = lvmcache_get_label(info)->sector;
-		pv->dev = lvmcache_device(info);
-		if (!pv->dev)
-			pv->status |= MISSING_PV;
-		if (!lvmcache_fid_add_mdas_pv(info, fid))
-			return_0;
-		pv->fid = fid;
-	} else
-		pv->status |= MISSING_PV; /* probably missing */
-
-	return 1;
-}
-
-struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgname, const char *vgid)
-{
-	struct volume_group *vg = NULL;
-	struct volume_group *vg2 = NULL;
-	daemon_reply reply;
-	int found;
-	char uuid[64];
-	struct format_instance *fid = NULL;
-	struct format_instance_ctx fic;
-	struct dm_config_node *top;
-	const char *name, *diag_name;
-	const char *fmt_name;
-	struct format_type *fmt;
-	struct dm_config_node *pvcn;
-	struct pv_list *pvl;
-	int rescan = 0;
-
-	if (!lvmetad_used())
-		return NULL;
-
-	if (vgid) {
-		if (!id_write_format((const struct id*)vgid, uuid, sizeof(uuid)))
-			return_NULL;
-	}
-
-	if (vgid && vgname) {
-		log_debug_lvmetad("Asking lvmetad for VG %s %s", uuid, vgname);
-		reply = _lvmetad_send(cmd, "vg_lookup",
-				      "uuid = %s", uuid,
-				      "name = %s", vgname,
-				      NULL);
-		diag_name = uuid;
-
-	} else if (vgid) {
-		log_debug_lvmetad("Asking lvmetad for VG vgid %s", uuid);
-		reply = _lvmetad_send(cmd, "vg_lookup", "uuid = %s", uuid, NULL);
-		diag_name = uuid;
-
-	} else if (vgname) {
-		log_debug_lvmetad("Asking lvmetad for VG %s", vgname);
-		reply = _lvmetad_send(cmd, "vg_lookup", "name = %s", vgname, NULL);
-		diag_name = vgname;
-
-	} else {
-		log_error(INTERNAL_ERROR "VG name required (VGID not available)");
-		return NULL;
-	}
-
-	if (_lvmetad_handle_reply(reply, "vg_lookup", diag_name, &found) && found) {
-
-		if ((found == 2) && vgname) {
-			log_error("Multiple VGs found with the same name: %s.", vgname);
-			log_error("See the --select option with VG UUID (vg_uuid).");
-			goto out;
-		}
-
-		if (!(top = dm_config_find_node(reply.cft->root, "metadata"))) {
-			log_error(INTERNAL_ERROR "metadata config node not found.");
-			goto out;
-		}
-
-		name = daemon_reply_str(reply, "name", NULL);
-
-		/* fall back to lvm2 if we don't know better */
-		fmt_name = dm_config_find_str(top, "metadata/format", "lvm2");
-		if (!(fmt = get_format_by_name(cmd, fmt_name))) {
-			log_error(INTERNAL_ERROR
-				  "We do not know the format (%s) reported by lvmetad.",
-				  fmt_name);
-			goto out;
-		}
-
-		fic.type = FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
-		fic.context.vg_ref.vg_name = name;
-		fic.context.vg_ref.vg_id = vgid;
-
-		if (!(fid = fmt->ops->create_instance(fmt, &fic)))
-			goto_out;
-
-		if ((pvcn = dm_config_find_node(top, "metadata/physical_volumes")))
-			for (pvcn = pvcn->child; pvcn; pvcn = pvcn->sib)
-				_pv_populate_lvmcache(cmd, pvcn, fmt, 0);
-
-		if ((pvcn = dm_config_find_node(top, "metadata/outdated_pvs")))
-			for (pvcn = pvcn->child; pvcn; pvcn = pvcn->sib)
-				_pv_populate_lvmcache(cmd, pvcn, fmt, 0);
-
-		top->key = name;
-		if (!(vg = import_vg_from_lvmetad_config_tree(reply.cft, fid)))
-			goto_out;
-
-		/*
-		 * Read the VG from disk, ignoring the lvmetad copy in these
-		 * cases:
-		 *
-		 * 1. The host is not using lvmlockd, but is reading lockd VGs
-		 * using the --shared option.  The shared option is meant to
-		 * let hosts not running lvmlockd look at lockd VGs, like the
-		 * foreign option allows hosts to look at foreign VGs.  When
-		 * --foreign is used, the code forces a rescan since the local
-		 * lvmetad cache of foreign VGs is likely stale.  Similarly,
-		 * for --shared, have the code reading the shared VGs below
-		 * not use the cached copy from lvmetad but to rescan the VG.
-		 *
-		 * 2. The host failed to acquire the VG lock from lvmlockd for
-		 * the lockd VG.  In this case, the usual mechanisms for
-		 * updating the lvmetad copy of the VG have been missed.  Since
-		 * we don't know if the cached copy is valid, assume it's not.
-		 *
-		 * 3. lvmetad has returned the "vg_invalid" flag, which is the
-		 * usual mechanism used by lvmlockd/lvmetad to cause a host to
-		 * reread a VG from disk that has been modified from another
-		 * host.
-		 */
-
-		if (vg_is_shared(vg) && cmd->include_shared_vgs) {
-			log_debug_lvmetad("Rescan VG %s because including shared", vgname);
-			rescan = 1;
-		} else if (vg_is_shared(vg) && cmd->lockd_vg_rescan) {
-			log_debug_lvmetad("Rescan VG %s because no lvmlockd lock is held", vgname);
-			rescan = 1;
-		} else if (dm_config_find_node(reply.cft->root, "vg_invalid")) {
-			if (!vg_is_shared(vg)) {
-				/* Can happen if a previous command failed/crashed without updating lvmetad. */
-				log_warn("WARNING: Reading VG %s from disk because lvmetad metadata is invalid.", vgname);
-			} else {
-				/* This is normal when the VG was modified by another host. */
-				log_debug_lvmetad("Rescan VG %s because lvmetad returned invalid", vgname);
-			}
-			rescan = 1;
-		}
-
-		/*
-		 * locking may have detected a newer vg version and
-		 * invalidated the cached vg.
-		 */
-		if (rescan) {
-			if (!(vg2 = _lvmetad_pvscan_vg(cmd, vg, vgid, fmt))) {
-				log_debug_lvmetad("VG %s from lvmetad not found during rescan.", vgname);
-				fid = NULL;
-				release_vg(vg);
-				vg = NULL;
-				goto out;
-			}
-			fid->ref_count++;
-			release_vg(vg);
-			fid->ref_count--;
-			fmt->ops->destroy_instance(fid);
-			vg = vg2;
-			fid = vg2->fid;
-		}
-
-		dm_list_iterate_items(pvl, &vg->pvs) {
-			if (!_pv_update_struct_pv(pvl->pv, fid)) {
-				vg = NULL;
-				goto_out;	/* FIXME: use an error path that disables lvmetad */
-			}
-		}
-
-		dm_list_iterate_items(pvl, &vg->pvs_outdated) {
-			if (!_pv_update_struct_pv(pvl->pv, fid)) {
-				vg = NULL;
-				goto_out;	/* FIXME: use an error path that disables lvmetad */
-			}
-		}
-
-		lvmcache_update_vg(vg, 0);
-		vg_mark_partial_lvs(vg, 1);
-	}
-
-out:
-	if (!vg && fid)
-		fid->fmt->ops->destroy_instance(fid);
-	daemon_reply_destroy(reply);
-
-	return vg;
-}
-
-struct _fixup_baton {
-	int i;
-	int find;
-	int ignore;
-};
-
-static int _fixup_ignored(struct metadata_area *mda, void *baton) {
-	struct _fixup_baton *b = baton;
-
-	if (b->i == b->find)
-		mda_set_ignored(mda, b->ignore);
-
-	b->i ++;
-
-	return 1;
-}
-
-/*
- * After the VG is written to disk, but before it's committed,
- * lvmetad is told the new seqno.  lvmetad sets the INVALID
- * flag on the cached VG and saves the new seqno.
- *
- * After the VG is committed on disk, the command sends the
- * new VG metadata, containing the new seqno.  lvmetad sees
- * that it has the updated metadata and clears the INVALID
- * flag on the cached VG.
- *
- * If the command fails after committing the metadata on disk
- * but before sending the new metadata to lvmetad, then the
- * next command that asks lvmetad for the metadata will get
- * back the INVALID flag.  That command will then read the
- * VG metadata from disk to use, and will send the latest
- * metadata from disk to lvmetad which will clear the
- * INVALID flag.
- */
-
-int lvmetad_vg_update_pending(struct volume_group *vg)
-{
-	char uuid[64] __attribute__((aligned(8)));
-	daemon_reply reply;
-
-	if (!lvmetad_used() || test_mode())
-		return 1; /* fake it */
-
-	if (!id_write_format(&vg->id, uuid, sizeof(uuid)))
-		return_0;
-
-	log_debug_lvmetad("Sending lvmetad pending VG %s (seqno %" PRIu32 ")", vg->name, vg->seqno);
-	reply = _lvmetad_send(vg->cmd, "set_vg_info",
-			      "name = %s", vg->name,
-			      "uuid = %s", uuid,
-			      "version = %"PRId64, (int64_t)vg->seqno,
-			      NULL);
-
-	if (!_lvmetad_handle_reply(reply, "set_vg_info", vg->name, NULL)) {
-		daemon_reply_destroy(reply);
-		return_0;
-	}
-
-	vg->lvmetad_update_pending = 1;
-
-	daemon_reply_destroy(reply);
-	return 1;
-}
-
-int lvmetad_vg_update_finish(struct volume_group *vg)
-{
-	char uuid[64] __attribute__((aligned(8)));
-	daemon_reply reply;
-	struct dm_hash_node *n;
-	struct metadata_area *mda;
-	char mda_id[128], *num;
-	struct volume_group *vgu;
-	struct dm_config_tree *vgmeta;
-	struct pv_list *pvl;
-	struct lvmcache_info *info;
-	struct _fixup_baton baton;
-
-	if (!vg->lvmetad_update_pending)
-		return 1;
-
-	if (!(vg->fid->fmt->features & FMT_PRECOMMIT))
-		return 1;
-
-	if (!lvmetad_used() || test_mode())
-		return 1; /* fake it */
-
-	if (!id_write_format(&vg->id, uuid, sizeof(uuid)))
-		return_0;
-
-	/*
-	 * vg->vg_committted is the state of the VG metadata when vg_commit()
-	 * was called.  Since then, 'vg' may have been partially modified and
-	 * not committed.  We only want to send committed metadata to lvmetad.
-	 *
-	 * lvmetad is sometimes updated in cases where the VG is not written
-	 * (no vg_committed).  In those cases 'vg' has just been read from
-	 * disk, and we can send 'vg' to lvmetad.  This happens when the
-	 * command finds the lvmetad cache invalid, so the VG has been read
-	 * from disk and is then sent to lvmetad.
-	 */
-
-	vgu = vg->vg_committed ? vg->vg_committed : vg;
-
-	if (!(vgmeta = export_vg_to_config_tree(vgu))) {
-		log_error("Failed to export VG to config tree.");
-		return 0;
-	}
-
-	log_debug_lvmetad("Sending lvmetad updated VG %s (seqno %" PRIu32 ")", vg->name, vg->seqno);
-	reply = _lvmetad_send(vg->cmd, "vg_update",
-			      "vgname = %s", vg->name,
-			      "metadata = %t", vgmeta,
-			      NULL);
-
-	dm_config_destroy(vgmeta);
-
-	if (!_lvmetad_handle_reply(reply, "vg_update", vg->name, NULL)) {
-		/*
-		 * In this failure case, the VG cached in lvmetad remains in
-		 * the INVALID state (from lvmetad_vg_update_pending).
-		 * A subsequent command will see INVALID, ignore the cached
-		 * copy, read the VG from disk, and update the cached copy.
-		 */
-		daemon_reply_destroy(reply);
-		return 0;
-	}
-
-	daemon_reply_destroy(reply);
-
-	n = (vgu->fid && vgu->fid->metadata_areas_index) ?
-		dm_hash_get_first(vgu->fid->metadata_areas_index) : NULL;
-	while (n) {
-		mda = dm_hash_get_data(vgu->fid->metadata_areas_index, n);
-		(void) dm_strncpy(mda_id, dm_hash_get_key(vgu->fid->metadata_areas_index, n), sizeof(mda_id));
-		if ((num = strchr(mda_id, '_'))) {
-			*num = 0;
-			++num;
-			if ((info = lvmcache_info_from_pvid(mda_id, NULL, 0))) {
-				memset(&baton, 0, sizeof(baton));
-				baton.find = atoi(num);
-				baton.ignore = mda_is_ignored(mda);
-				lvmcache_foreach_mda(info, _fixup_ignored, &baton);
-			}
-		}
-		n = dm_hash_get_next(vgu->fid->metadata_areas_index, n);
-	}
-
-	dm_list_iterate_items(pvl, &vgu->pvs) {
-		/* NB. the PV fmt pointer is sometimes wrong during vgconvert */
-		if (pvl->pv->dev && !lvmetad_pv_found(vg->cmd, &pvl->pv->id, pvl->pv->dev,
-						      vgu->fid ? vgu->fid->fmt : pvl->pv->fmt,
-						      pvl->pv->label_sector, NULL, NULL, NULL))
-			return_0;
-	}
-
-	vg->lvmetad_update_pending = 0;
-	return 1;
-}
-
-int lvmetad_vg_remove_pending(struct volume_group *vg)
-{
-	char uuid[64] __attribute__((aligned(8)));
-	daemon_reply reply;
-
-	if (!lvmetad_used() || test_mode())
-		return 1; /* fake it */
-
-	if (!id_write_format(&vg->id, uuid, sizeof(uuid)))
-		return_0;
-
-	/* Sending version/seqno 0 in set_vg_info will set the INVALID flag. */
-
-	log_debug_lvmetad("Sending lvmetad pending remove VG %s", vg->name);
-	reply = _lvmetad_send(vg->cmd, "set_vg_info",
-			      "name = %s", vg->name,
-			      "uuid = %s", uuid,
-			      "version = %"PRId64, (int64_t)0,
-			      NULL);
-
-	if (!_lvmetad_handle_reply(reply, "set_vg_info", vg->name, NULL)) {
-		daemon_reply_destroy(reply);
-		return_0;
-	}
-
-	daemon_reply_destroy(reply);
-	return 1;
-}
-
-int lvmetad_vg_remove_finish(struct volume_group *vg)
-{
-	char uuid[64];
-	daemon_reply reply;
-	int result;
-
-	if (!lvmetad_used() || test_mode())
-		return 1; /* just fake it */
-
-	vg->lvmetad_update_pending = 0;
-
-	if (!id_write_format(&vg->id, uuid, sizeof(uuid)))
-		return_0;
-
-	log_debug_lvmetad("Telling lvmetad to remove VGID %s (%s)", uuid, vg->name);
-	reply = _lvmetad_send(vg->cmd, "vg_remove", "uuid = %s", uuid, NULL);
-	result = _lvmetad_handle_reply(reply, "vg_remove", vg->name, NULL);
-
-	daemon_reply_destroy(reply);
-
-	return result;
-}
-
-int lvmetad_pv_lookup(struct cmd_context *cmd, struct id pvid, int *found)
-{
-	char uuid[64];
-	daemon_reply reply;
-	int result = 0;
-	struct dm_config_node *cn;
-
-	if (!lvmetad_used())
-		return_0;
-
-	if (!id_write_format(&pvid, uuid, sizeof(uuid)))
-		return_0;
-
-	log_debug_lvmetad("Asking lvmetad for PV %s", uuid);
-	reply = _lvmetad_send(cmd, "pv_lookup", "uuid = %s", uuid, NULL);
-	if (!_lvmetad_handle_reply(reply, "pv_lookup", "", found))
-		goto_out;
-
-	if (found && !*found)
-		goto out_success;
-
-	if (!(cn = dm_config_find_node(reply.cft->root, "physical_volume")))
-		goto_out;
-        else if (!_pv_populate_lvmcache(cmd, cn, NULL, 0))
-		goto_out;
-
-out_success:
-	result = 1;
-
-out:
-	daemon_reply_destroy(reply);
-
-	return result;
-}
-
-int lvmetad_pv_lookup_by_dev(struct cmd_context *cmd, struct device *dev, int *found)
-{
-	int result = 0;
-	daemon_reply reply;
-	struct dm_config_node *cn;
-
-	if (!lvmetad_used())
-		return_0;
-
-	log_debug_lvmetad("Asking lvmetad for PV on %s", dev_name(dev));
-	reply = _lvmetad_send(cmd, "pv_lookup", "device = %" PRId64, (int64_t) dev->dev, NULL);
-	if (!_lvmetad_handle_reply(reply, "pv_lookup", dev_name(dev), found))
-		goto_out;
-
-	if (found && !*found)
-		goto out_success;
-
-	cn = dm_config_find_node(reply.cft->root, "physical_volume");
-	if (!cn || !_pv_populate_lvmcache(cmd, cn, NULL, dev->dev))
-		goto_out;
-
-out_success:
-	result = 1;
-
-out:
-	daemon_reply_destroy(reply);
-
-	return result;
-}
-
-int lvmetad_pv_list_to_lvmcache(struct cmd_context *cmd)
-{
-	daemon_reply reply;
-	struct dm_config_node *cn;
-
-	if (!lvmetad_used())
-		return 1;
-
-	log_debug_lvmetad("Asking lvmetad for complete list of known PVs");
-	reply = _lvmetad_send(cmd, "pv_list", NULL);
-	if (!_lvmetad_handle_reply(reply, "pv_list", "", NULL)) {
-		daemon_reply_destroy(reply);
-		return_0;
-	}
-
-	if ((cn = dm_config_find_node(reply.cft->root, "physical_volumes")))
-		for (cn = cn->child; cn; cn = cn->sib)
-			_pv_populate_lvmcache(cmd, cn, NULL, 0);
-
-	daemon_reply_destroy(reply);
-
-	return 1;
-}
-
-int lvmetad_get_vgnameids(struct cmd_context *cmd, struct dm_list *vgnameids)
-{
-	struct vgnameid_list *vgnl;
-	struct id vgid;
-	const char *vgid_txt;
-	const char *vg_name;
-	daemon_reply reply;
-	struct dm_config_node *cn;
-
-	log_debug_lvmetad("Asking lvmetad for complete list of known VG ids/names");
-	reply = _lvmetad_send(cmd, "vg_list", NULL);
-	if (!_lvmetad_handle_reply(reply, "vg_list", "", NULL)) {
-		daemon_reply_destroy(reply);
-		return_0;
-	}
-
-	if ((cn = dm_config_find_node(reply.cft->root, "volume_groups"))) {
-		for (cn = cn->child; cn; cn = cn->sib) {
-			vgid_txt = cn->key;
-			if (!id_read_format(&vgid, vgid_txt)) {
-				stack;
-				continue;
-			}
-
-			if (!(vgnl = dm_pool_alloc(cmd->mem, sizeof(*vgnl)))) {
-				log_error("vgnameid_list allocation failed.");
-				return 0;
-			}
-
-			if (!(vg_name = dm_config_find_str(cn->child, "name", NULL))) {
-				log_error("vg_list no name found.");
-				return 0;
-			}
-
-			vgnl->vgid = dm_pool_strdup(cmd->mem, (char *)&vgid);
-			vgnl->vg_name = dm_pool_strdup(cmd->mem, vg_name);
-
-			if (!vgnl->vgid || !vgnl->vg_name) {
-				log_error("vgnameid_list member allocation failed.");
-				return 0;
-			}
-
-			dm_list_add(vgnameids, &vgnl->list);
-		}
-	}
-
-	daemon_reply_destroy(reply);
-
-	return 1;
-}
-
-int lvmetad_vg_list_to_lvmcache(struct cmd_context *cmd)
-{
-	struct volume_group *tmp;
-	struct id vgid;
-	const char *vgid_txt;
-	daemon_reply reply;
-	struct dm_config_node *cn;
-
-	if (!lvmetad_used())
-		return 1;
-
-	log_debug_lvmetad("Asking lvmetad for complete list of known VGs");
-	reply = _lvmetad_send(cmd, "vg_list", NULL);
-	if (!_lvmetad_handle_reply(reply, "vg_list", "", NULL)) {
-		daemon_reply_destroy(reply);
-		return_0;
-	}
-
-	if ((cn = dm_config_find_node(reply.cft->root, "volume_groups")))
-		for (cn = cn->child; cn; cn = cn->sib) {
-			vgid_txt = cn->key;
-			if (!id_read_format(&vgid, vgid_txt)) {
-				stack;
-				continue;
-			}
-
-			/* the call to lvmetad_vg_lookup will poke the VG into lvmcache */
-			tmp = lvmetad_vg_lookup(cmd, NULL, (const char*)&vgid);
-			release_vg(tmp);
-		}
-
-	daemon_reply_destroy(reply);
-
-	return 1;
-}
-
-struct extract_dl_baton {
-	int i;
-	struct dm_config_tree *cft;
-	struct dm_config_node *pre_sib;
-};
-
-static int _extract_mda(struct metadata_area *mda, void *baton)
-{
-	struct extract_dl_baton *b = baton;
-	struct dm_config_node *cn;
-	char id[32];
-
-	if (!mda->ops->mda_export_text) /* do nothing */
-		return 1;
-
-	(void) dm_snprintf(id, 32, "mda%d", b->i);
-	if (!(cn = make_config_node(b->cft, id, b->cft->root, b->pre_sib)))
-		return 0;
-	if (!mda->ops->mda_export_text(mda, b->cft, cn))
-		return 0;
-
-	b->i ++;
-	b->pre_sib = cn; /* for efficiency */
-
-	return 1;
-}
-
-static int _extract_disk_location(const char *name, struct disk_locn *dl, void *baton)
-{
-	struct extract_dl_baton *b = baton;
-	struct dm_config_node *cn;
-	char id[32];
-
-	if (!dl)
-		return 1;
-
-	(void) dm_snprintf(id, 32, "%s%d", name, b->i);
-	if (!(cn = make_config_node(b->cft, id, b->cft->root, b->pre_sib)))
-		return 0;
-	if (!config_make_nodes(b->cft, cn, NULL,
-			       "offset = %"PRId64, (int64_t) dl->offset,
-			       "size = %"PRId64, (int64_t) dl->size,
-			       NULL))
-		return 0;
-
-	b->i ++;
-	b->pre_sib = cn; /* for efficiency */
-
-	return 1;
-}
-
-static int _extract_da(struct disk_locn *da, void *baton)
-{
-	return _extract_disk_location("da", da, baton);
-}
-
-static int _extract_ba(struct disk_locn *ba, void *baton)
-{
-	return _extract_disk_location("ba", ba, baton);
-}
-
-static int _extract_mdas(struct lvmcache_info *info, struct dm_config_tree *cft,
-			 struct dm_config_node *pre_sib)
-{
-	struct extract_dl_baton baton = { .cft = cft };
-
-	if (!lvmcache_foreach_mda(info, &_extract_mda, &baton))
-		return 0;
-
-	baton.i = 0;
-	if (!lvmcache_foreach_da(info, &_extract_da, &baton))
-		return 0;
-
-	baton.i = 0;
-	if (!lvmcache_foreach_ba(info, &_extract_ba, &baton))
-		return 0;
-
-	return 1;
-}
-
-int lvmetad_pv_found(struct cmd_context *cmd, const struct id *pvid, struct device *dev, const struct format_type *fmt,
-		     uint64_t label_sector, struct volume_group *vg,
-		     struct dm_list *found_vgnames,
-		     struct dm_list *changed_vgnames)
-{
-	char uuid[64];
-	daemon_reply reply;
-	struct lvmcache_info *info;
-	struct dm_config_tree *pvmeta, *vgmeta;
-	const char *status = NULL, *vgname = NULL;
-	int64_t changed = 0;
-	int result, seqno_after;
-
-	if (!lvmetad_used() || test_mode())
-		return 1;
-
-	if (!id_write_format(pvid, uuid, sizeof(uuid)))
-                return_0;
-
-	pvmeta = dm_config_create();
-	if (!pvmeta)
-		return_0;
-
-	info = lvmcache_info_from_pvid((const char *)pvid, dev, 0);
-
-	if (!(pvmeta->root = make_config_node(pvmeta, "pv", NULL, NULL))) {
-		dm_config_destroy(pvmeta);
-		return_0;
-	}
-
-	/* TODO: resolve what does it actually mean  'info == NULL'
-	 *       missing info is likely an INTERNAL_ERROR */
-	if (!config_make_nodes(pvmeta, pvmeta->root, NULL,
-			       "device = %"PRId64, (int64_t) dev->dev,
-			       "dev_size = %"PRId64, (int64_t) (info ? lvmcache_device_size(info) : 0),
-			       "format = %s", fmt->name,
-			       "label_sector = %"PRId64, (int64_t) label_sector,
-			       "id = %s", uuid,
-			       "ext_version = %"PRId64, (int64_t) (info ? lvmcache_ext_version(info) : 0),
-			       "ext_flags = %"PRId64, (int64_t) (info ? lvmcache_ext_flags(info) : 0),
-			       NULL))
-	{
-		dm_config_destroy(pvmeta);
-		return_0;
-	}
-
-	if (info)
-		/* FIXME A more direct route would be much preferable. */
-		_extract_mdas(info, pvmeta, pvmeta->root);
-
-	if (vg) {
-		if (!(vgmeta = export_vg_to_config_tree(vg))) {
-			dm_config_destroy(pvmeta);
-			return_0;
-		}
-
-		log_debug_lvmetad("Telling lvmetad to store PV %s (%s) in VG %s", dev_name(dev), uuid, vg->name);
-		reply = _lvmetad_send(cmd, "pv_found",
-				      "pvmeta = %t", pvmeta,
-				      "vgname = %s", vg->name,
-				      "metadata = %t", vgmeta,
-				      NULL);
-		dm_config_destroy(vgmeta);
-	} else {
-		/*
-		 * There is no VG metadata stored on this PV.
-		 * It might or might not be an orphan.
-		 */
-		log_debug_lvmetad("Telling lvmetad to store PV %s (%s)", dev_name(dev), uuid);
-		reply = _lvmetad_send(NULL, "pv_found", "pvmeta = %t", pvmeta, NULL);
-	}
-
-	dm_config_destroy(pvmeta);
-
-	result = _lvmetad_handle_reply(reply, "pv_found", uuid, NULL);
-
-	if (vg && result) {
-		seqno_after = daemon_reply_int(reply, "seqno_after", -1);
-		if ((seqno_after != (int) vg->seqno) ||
-		    (seqno_after != daemon_reply_int(reply, "seqno_before", -1)))
-			log_warn("WARNING: Inconsistent metadata found for VG %s", vg->name);
-	}
-
-	if (result && found_vgnames) {
-		status = daemon_reply_str(reply, "status", NULL);
-		vgname = daemon_reply_str(reply, "vgname", NULL);
-		changed = daemon_reply_int(reply, "changed", 0);
-	}
-
-	/*
-	 * If lvmetad now sees all PVs in the VG, it returned the
-	 * "complete" status string.  Add this VG name to the list
-	 * of found VGs so that the caller can do autoactivation.
-	 *
-	 * If there was a problem notifying lvmetad about the new
-	 * PV, e.g. lvmetad was disabled due to a duplicate, then
-	 * no autoactivation is attempted.
-	 *
-	 * FIXME: there was a previous fixme indicating that
-	 * autoactivation might also be done for VGs with the
-	 * "partial" status.
-	 *
-	 * If the VG has "changed" by finding the PV, lvmetad returns
-	 * the "changed" flag.  The names of "changed" VGs are saved
-	 * in the changed_vgnames lists, which is used during autoactivation.
-	 * If a VG is changed, then autoactivation refreshes LVs in the VG.
-	 */
-
-	if (found_vgnames && vgname && status && !strcmp(status, "complete")) {
-		log_debug("VG %s is complete in lvmetad with dev %s.", vgname, dev_name(dev));
-		if (!str_list_add(cmd->mem, found_vgnames, dm_pool_strdup(cmd->mem, vgname)))
-			log_error("str_list_add failed");
-
-		if (changed_vgnames && changed) {
-			log_debug("VG %s is changed in lvmetad.", vgname);
-			if (!str_list_add(cmd->mem, changed_vgnames, dm_pool_strdup(cmd->mem, vgname)))
-				log_error("str_list_add failed");
-		}
-	}
-
-	daemon_reply_destroy(reply);
-
-	return result;
-}
-
-int lvmetad_pv_gone(dev_t devno, const char *pv_name)
-{
-	daemon_reply reply;
-	int result;
-	int found;
-
-	if (!lvmetad_used() || test_mode())
-		return 1;
-
-	/*
-	 *  TODO: automatic volume deactivation takes place here *before*
-	 *        all cached info is gone - call handler. Also, consider
-	 *        integrating existing deactivation script  that deactivates
-	 *        the whole stack from top to bottom (not yet upstream).
-	 */
-
-	log_debug_lvmetad("Telling lvmetad to forget any PV on %s", pv_name);
-	reply = _lvmetad_send(NULL, "pv_gone", "device = %" PRId64, (int64_t) devno, NULL);
-
-	result = _lvmetad_handle_reply(reply, "pv_gone", pv_name, &found);
-	/* We don't care whether or not the daemon had the PV cached. */
-
-	daemon_reply_destroy(reply);
-
-	return result;
-}
-
-int lvmetad_pv_gone_by_dev(struct device *dev)
-{
-	return lvmetad_pv_gone(dev->dev, dev_name(dev));
-}
-
-/*
- * The following code implements pvscan --cache.
- */
-
-struct _lvmetad_pvscan_baton {
-	struct cmd_context *cmd;
-	struct volume_group *vg;
-	struct format_instance *fid;
-};
-
-static int _lvmetad_pvscan_single(struct metadata_area *mda, void *baton)
-{
-	struct _lvmetad_pvscan_baton *b = baton;
-	struct volume_group *vg;
-
-	if (mda_is_ignored(mda) ||
-	    !(vg = mda->ops->vg_read(b->fid, "", mda, NULL, NULL)))
-		return 1;
-
-	/* FIXME Also ensure contents match etc. */
-	if (!b->vg || vg->seqno > b->vg->seqno)
-		b->vg = vg;
-	else if (b->vg)
-		release_vg(vg);
-
-	return 1;
-}
-
-/*
- * FIXME: handle errors and do proper comparison of metadata from each area
- * like vg_read and fall back to real vg_read from disk if there's any problem.
- */
-
-static int _lvmetad_pvscan_vg_single(struct metadata_area *mda, void *baton)
-{
-	struct _lvmetad_pvscan_baton *b = baton;
-	struct volume_group *vg = NULL;
-
-	if (mda_is_ignored(mda))
-		return 1;
-
-	if (!(vg = mda->ops->vg_read(b->fid, "", mda, NULL, NULL)))
-		return 1;
-
-	if (!b->vg)
-		b->vg = vg;
-	else if (vg->seqno > b->vg->seqno) {
-		release_vg(b->vg);
-		b->vg = vg;
-	} else
-		release_vg(vg);
-
-	return 1;
-}
-
-/*
- * The lock manager may detect that the vg cached in lvmetad is out of date,
- * due to something like an lvcreate from another host.
- * This is limited to changes that only affect the vg (not global state like
- * orphan PVs), so we only need to reread mdas on the vg's existing pvs.
- * But, a previous PV in the VG may have been removed since we last read
- * the VG, and that PV may have been reused for another VG.
- */
-
-static struct volume_group *_lvmetad_pvscan_vg(struct cmd_context *cmd, struct volume_group *vg,
-					      const char *vgid, struct format_type *fmt)
-{
-	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
-	char uuid[64] __attribute__((aligned(8)));
-	struct dm_config_tree *vgmeta;
-	struct pv_list *pvl, *pvl_new;
-	struct device_list *devl, *devlsafe;
-	struct dm_list pvs_scan;
-	struct dm_list pvs_drop;
-	struct lvmcache_vginfo *vginfo = NULL;
-	struct lvmcache_info *info = NULL;
-	struct format_instance *fid;
-	struct format_instance_ctx fic = { .type = 0 };
-	struct _lvmetad_pvscan_baton baton;
-	struct volume_group *save_vg;
-	struct dm_config_tree *save_meta;
-	struct device *save_dev = NULL;
-	uint32_t save_seqno = 0;
-	int found_new_pvs = 0;
-	int retried_reads = 0;
-	int found;
-
-	save_vg = NULL;
-	save_meta = NULL;
-	save_dev = NULL;
-	save_seqno = 0;
-
-	dm_list_init(&pvs_scan);
-	dm_list_init(&pvs_drop);
-
-	log_debug_lvmetad("Rescan VG %s to update lvmetad (seqno %u).", vg->name, vg->seqno);
-
-	/*
-	 * Make sure this command knows about all PVs from lvmetad.
-	 */
-	lvmcache_seed_infos_from_lvmetad(cmd);
-
-	/*
-	 * Start with the list of PVs that we last saw in the VG.
-	 * Some may now be gone, and some new PVs may have been added.
-	 */
-	dm_list_iterate_items(pvl, &vg->pvs) {
-		if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
-			return_NULL;
-		devl->dev = pvl->pv->dev;
-		dm_list_add(&pvs_scan, &devl->list);
-	}
-
-	/*
-	 * Rescan labels/metadata only from devs that we previously
-	 * saw in the VG.  If we find below that there are new PVs
-	 * in the VG, we'll have to rescan all devices to find which
-	 * device(s) are now being used.
-	 */
-	log_debug_lvmetad("Rescan VG %s scanning data from devs in previous metadata.", vg->name);
-
-	label_scan_devs(cmd, cmd->full_filter, &pvs_scan);
-
-	/*
-	 * Check if any pvs_scan entries are no longer PVs.
-	 * In that case, label_read/_find_label_header will have
-	 * found no label_header, and would have dropped the
-	 * info struct for the device from lvmcache.  So, if
-	 * we look up the info struct here and don't find it,
-	 * we can infer it's no longer a PV.
-	 *
-	 * FIXME: we should record specific results from the
-	 * label_read and then check specifically for whatever
-	 * result means "no label was found", rather than going
-	 * about this indirectly via the lvmcache side effects.
-	 */
-	dm_list_iterate_items_safe(devl, devlsafe, &pvs_scan) {
-		if (!(info = lvmcache_info_from_pvid(devl->dev->pvid, devl->dev, 0))) {
-			/* Another host removed this PV from the VG. */
-			log_debug_lvmetad("Rescan VG %s from %s dropping dev (no label).",
-					  vg->name, dev_name(devl->dev));
-			dm_list_move(&pvs_drop, &devl->list);
-		}
-	}
-
-	fic.type = FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
-	fic.context.vg_ref.vg_name = vg->name;
-	fic.context.vg_ref.vg_id = vgid;
-
- retry_reads:
-
-	if (!(fid = fmt->ops->create_instance(fmt, &fic))) {
-		/* FIXME: are there only internal reasons for failures here? */
-		log_error("Reading VG %s failed to create format instance.", vg->name);
-		return NULL;
-	}
-
-	/* FIXME: not sure if this is necessary */
-	fid->ref_count++;
-
-	baton.fid = fid;
-	baton.cmd = cmd;
-
-	/*
-	 * FIXME: this vg_read path does not have the ability to repair
-	 * any problems with the VG, e.g. VG on one dev has an older
-	 * seqno.  When vg_read() is reworked, we need to fall back
-	 * to using that from here (and vg_read's from lvmetad) when
-	 * there is a problem.  Perhaps by disabling lvmetad when a
-	 * VG problem is detected, causing commands to fully fall
-	 * back to disk, which will repair the VG.  Then lvmetad can
-	 * be repopulated and re-enabled (possibly automatically.)
-	 */
-
-	/*
-	 * Do a low level vg_read on each dev, verify the vg returned
-	 * from metadata on each device is for the VG being read
-	 * (the PV may have been removed from the VG being read and
-	 * added to a different one), and return this vg to the caller
-	 * as the current vg to use.
-	 *
-	 * The label scan above will have saved in lvmcache which
-	 * vg each device is used in, so we could figure that part
-	 * out without doing the vg_read.
-	 */
-	dm_list_iterate_items_safe(devl, devlsafe, &pvs_scan) {
-		if (!devl->dev)
-			continue;
-
-		log_debug_lvmetad("Rescan VG %s getting metadata from %s.",
-				  vg->name, dev_name(devl->dev));
-
-		/*
-		 * The info struct for this dev knows what and where
-		 * the mdas are for this dev (the label scan saved
-		 * the mda locations for this dev on the lvmcache info struct).
-		 */
-		if (!(info = lvmcache_info_from_pvid(devl->dev->pvid, devl->dev, 0))) {
-			log_debug_lvmetad("Rescan VG %s from %s dropping dev (no info).",
-					  vg->name, dev_name(devl->dev));
-			dm_list_move(&pvs_drop, &devl->list);
-			continue;
-		}
-
-		baton.vg = NULL;
-
-		/*
-		 * Read VG metadata from this dev's mdas.
-		 */
-		lvmcache_foreach_mda(info, _lvmetad_pvscan_vg_single, &baton);
-
-		/*
-		 * The PV may have been removed from the VG by another host
-		 * since we last read the VG.
-		 */
-		if (!baton.vg) {
-			log_debug_lvmetad("Rescan VG %s from %s dropping dev (no metadata).",
-					  vg->name, dev_name(devl->dev));
-			dm_list_move(&pvs_drop, &devl->list);
-			continue;
-		}
-
-		/*
-		 * The PV may have been removed from the VG and used for a
-		 * different VG since we last read the VG.
-		 */
-		if (strcmp(baton.vg->name, vg->name)) {
-			log_debug_lvmetad("Rescan VG %s from %s dropping dev (other VG %s).",
-					  vg->name, dev_name(devl->dev), baton.vg->name);
-			release_vg(baton.vg);
-			continue;
-		}
-
-		if (!(vgmeta = export_vg_to_config_tree(baton.vg))) {
-			log_error("VG export to config tree failed");
-			release_vg(baton.vg);
-			continue;
-		}
-
-		/*
-		 * The VG metadata read from each dev should match.  Save the
-		 * metadata from the first dev, and compare it to the metadata
-		 * read from each other dev.
-		 */
-
-		if (save_vg && (save_seqno != baton.vg->seqno)) {
-			/* FIXME: fall back to vg_read to correct this. */
-			log_warn("WARNING: inconsistent metadata for VG %s on devices %s seqno %u and %s seqno %u.",
-				 vg->name, dev_name(save_dev), save_seqno,
-				 dev_name(devl->dev), baton.vg->seqno);
-			log_warn("WARNING: temporarily disable lvmetad to repair metadata.");
-
-			/* Use the most recent */
-			if (save_seqno < baton.vg->seqno) {
-				release_vg(save_vg);
-				dm_config_destroy(save_meta);
-				save_vg = baton.vg;
-				save_meta = vgmeta;
-				save_seqno = baton.vg->seqno;
-				save_dev = devl->dev;
-			} else {
-				release_vg(baton.vg);
-				dm_config_destroy(vgmeta);
-			}
-			continue;
-		}
-
-		if (!save_vg) {
-			save_vg = baton.vg;
-			save_meta = vgmeta;
-			save_seqno = baton.vg->seqno;
-			save_dev = devl->dev;
-		} else {
-			struct dm_config_node *meta1 = save_meta->root;
-			struct dm_config_node *meta2 = vgmeta->root;
-			struct dm_config_node *sib1 = meta1->sib;
-			struct dm_config_node *sib2 = meta2->sib;
-
-			/*
-			 * Do not compare the extraneous data that
-			 * export_vg_to_config_tree() inserts next to the
-			 * actual VG metadata.  This includes creation_time
-			 * which may not match since it is generated separately
-			 * for each call to create the config tree.
-			 *
-			 * We're saving the sibling pointer and restoring it
-			 * after the compare because we're unsure if anything
-			 * later might want it.
-			 *
-			 * FIXME: make it clearer what we're doing here, e.g.
-			 * pass a parameter to export_vg_to_config_tree()
-			 * telling it to skip the extraneous data, or something.
-			 * It's very non-obvious that setting sib=NULL does that.
-			 */
-			meta1->sib = NULL;
-			meta2->sib = NULL;
-
-			if (compare_config(meta1, meta2)) {
-				/* FIXME: fall back to vg_read to correct this. */
-				log_warn("WARNING: inconsistent metadata for VG %s on devices %s seqno %u and %s seqno %u.",
-					 vg->name, dev_name(save_dev), save_seqno,
-					 dev_name(devl->dev), baton.vg->seqno);
-				log_warn("WARNING: temporarily disable lvmetad to repair metadata.");
-				log_error("VG %s metadata comparison failed for device %s vs %s",
-					  vg->name, dev_name(devl->dev), save_dev ? dev_name(save_dev) : "none");
-				_log_debug_inequality(vg->name, save_meta->root, vgmeta->root);
-
-				meta1->sib = sib1;
-				meta2->sib = sib2;
-
-				/* no right choice, just use the previous copy */
-				release_vg(baton.vg);
-				dm_config_destroy(vgmeta);
-			}
-			meta1->sib = sib1;
-			meta2->sib = sib2;
-			release_vg(baton.vg);
-			dm_config_destroy(vgmeta);
-		}
-	}
-
-	/* FIXME: see above */
-	fid->ref_count--;
-
-	/*
-	 * Look for any new PVs in the VG metadata that were not in our
-	 * previous version of the VG.
-	 *
-	 * (Don't look for new PVs after a rescan and retry.)
-	 */
-	found_new_pvs = 0;
-
-	if (save_vg && !retried_reads) {
-		dm_list_iterate_items(pvl_new, &save_vg->pvs) {
-			found = 0;
-			dm_list_iterate_items(pvl, &vg->pvs) {
-				if (pvl_new->pv->dev != pvl->pv->dev)
-					continue;
-				found = 1;
-				break;
-			}
-
-			/*
-			 * PV in new VG metadata not found in old VG metadata.
-			 * There's a good chance we don't know about this new
-			 * PV or what device it's on; a label scan is needed
-			 * of all devices so we know which device the VG is
-			 * now using.
-			 */
-			if (!found) {
-				found_new_pvs++;
-				strncpy(pvid_s, (char *) &pvl_new->pv->id, sizeof(pvid_s) - 1);
-				if (!id_write_format((const struct id *)&pvid_s, uuid, sizeof(uuid)))
-					stack;
-				log_debug_lvmetad("Rescan VG %s found new PV %s.", vg->name, uuid);
-			}
-		}
-	}
-
-	if (!save_vg && retried_reads) {
-		log_error("VG %s not found after rescanning devices.", vg->name);
-		goto out;
-	}
-
-	/*
-	 * Do a full rescan of devices, then look up which devices the
-	 * scan found for this VG name, and select those devices to
-	 * read metadata from in the loop above (rather than the list
-	 * of devices we created from our last copy of the vg metadata.)
-	 *
-	 * Case 1: VG we knew is no longer on any of the devices we knew it
-	 * to be on (save_vg is NULL, which means the metadata wasn't found
-	 * when reading mdas on each of the initial pvs_scan devices).
-	 * Rescan all devs and then retry reading metadata from the devs that
-	 * the scan finds associated with this VG.
-	 *
-	 * Case 2: VG has new PVs but we don't know what devices they are
-	 * so rescan all devs and then retry reading metadata from the devs
-	 * that the scan finds associated with this VG.
-	 *
-	 * (N.B. after a retry, we don't check for found_new_pvs.)
-	 */
-	if (!save_vg || found_new_pvs) {
-		if (!save_vg)
-			log_debug_lvmetad("Rescan VG %s did not find VG on previous devs.", vg->name);
-		if (found_new_pvs)
-			log_debug_lvmetad("Rescan VG %s scanning all devs to find new PVs.", vg->name);
-
-		label_scan(cmd);
-
-		if (!(vginfo = lvmcache_vginfo_from_vgname(vg->name, NULL))) {
-			log_error("VG %s vg info not found after rescanning devices.", vg->name);
-			goto out;
-		}
-
-		/*
-		 * Set pvs_scan to devs that the label scan found
-		 * in the VG and retry the metadata reading loop.
-		 */
-		dm_list_init(&pvs_scan);
-
-		if (!lvmcache_get_vg_devs(cmd, vginfo, &pvs_scan)) {
-			log_error("VG %s info devs not found after rescanning devices.", vg->name);
-			goto out;
-		}
-
-		log_debug_lvmetad("Rescan VG %s has %d PVs after label scan.",
-				  vg->name, dm_list_size(&pvs_scan));
-
-		if (save_vg)
-			release_vg(save_vg);
-		if (save_meta)
-			dm_config_destroy(save_meta);
-		save_vg = NULL;
-		save_meta = NULL;
-		save_dev = NULL;
-		save_seqno = 0;
-		found_new_pvs = 0;
-		retried_reads = 1;
-		goto retry_reads;
-	}
-
-	/*
-	 * Remove pvs_drop entries from lvmetad.
-	 */
-	dm_list_iterate_items(devl, &pvs_drop) {
-		if (!devl->dev)
-			continue;
-		log_debug_lvmetad("Rescan VG %s removing %s from lvmetad.", vg->name, dev_name(devl->dev));
-		if (!lvmetad_pv_gone_by_dev(devl->dev)) {
-			/* FIXME: use an error path that disables lvmetad */
-			log_error("Failed to remove %s from lvmetad.", dev_name(devl->dev));
-		}
-	}
-
-	/*
-	 * Update lvmetad with the newly read version of the VG.
-	 * When the seqno is unchanged the cached VG can be left.
-	 */
-	if (save_vg && (save_seqno != vg->seqno)) {
-		dm_list_iterate_items(devl, &pvs_scan) {
-			if (!devl->dev)
-				continue;
-			log_debug_lvmetad("Rescan VG %s removing %s from lvmetad to replace.",
-					  vg->name, dev_name(devl->dev));
-			if (!lvmetad_pv_gone_by_dev(devl->dev)) {
-				/* FIXME: use an error path that disables lvmetad */
-				log_error("Failed to remove %s from lvmetad.", dev_name(devl->dev));
-			}
-		}
-
-		log_debug_lvmetad("Rescan VG %s updating lvmetad from seqno %u to seqno %u.",
-				  vg->name, vg->seqno, save_seqno);
-
-		/*
-		 * If this vg_update fails the cached metadata in
-		 * lvmetad will remain invalid.
-		 */
-		save_vg->lvmetad_update_pending = 1;
-		if (!lvmetad_vg_update_finish(save_vg)) {
-			/* FIXME: use an error path that disables lvmetad */
-			log_error("Failed to update lvmetad with new VG meta");
-		}
-	}
-out:
-	if (!save_vg && fid)
-		fmt->ops->destroy_instance(fid);
-	if (save_meta)
-		dm_config_destroy(save_meta);
-	if (save_vg)
-		log_debug_lvmetad("Rescan VG %s done (new seqno %u).", save_vg->name, save_vg->seqno);
-	return save_vg;
-}
-
-int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
-			  struct dm_list *found_vgnames,
-			  struct dm_list *changed_vgnames)
-{
-	struct label *label;
-	struct lvmcache_info *info;
-	struct _lvmetad_pvscan_baton baton;
-	const struct format_type *fmt;
-	/* Create a dummy instance. */
-	struct format_instance_ctx fic = { .type = 0 };
-
-	log_debug_lvmetad("Scan metadata from dev %s", dev_name(dev));
-
-	if (!lvmetad_used()) {
-		log_error("Cannot proceed since lvmetad is not active.");
-		return 0;
-	}
-
-	if (udev_dev_is_mpath_component(dev)) {
-		log_debug("Ignore multipath component for pvscan.");
-		return 1;
-	}
-
-	if (!(info = lvmcache_info_from_pvid(dev->pvid, dev, 0))) {
-		log_print_unless_silent("No PV info found on %s for PVID %s.", dev_name(dev), dev->pvid);
-		if (!lvmetad_pv_gone_by_dev(dev))
-			goto_bad;
-		return 1;
-	}
-
-	if (!(label = lvmcache_get_label(info))) {
-		log_print_unless_silent("No PV label found for %s.", dev_name(dev));
-		if (!lvmetad_pv_gone_by_dev(dev))
-			goto_bad;
-		return 1;
-	}
-
-	fmt = lvmcache_fmt(info);
-
-	baton.cmd = cmd;
-	baton.vg = NULL;
-	baton.fid = fmt->ops->create_instance(fmt, &fic);
-
-	if (!baton.fid)
-		goto_bad;
-
-	lvmcache_foreach_mda(info, _lvmetad_pvscan_single, &baton);
-
-	if (!baton.vg)
-		fmt->ops->destroy_instance(baton.fid);
-
-	if (!lvmetad_pv_found(cmd, (const struct id *) &dev->pvid, dev, fmt,
-			      label->sector, baton.vg, found_vgnames, changed_vgnames)) {
-		release_vg(baton.vg);
-		goto_bad;
-	}
-
-	release_vg(baton.vg);
-	return 1;
-
-bad:
-	return 0;
-}
-
-/*
- * Update the lvmetad cache: clear the current lvmetad cache, and scan all
- * devs, sending all info from the devs to lvmetad.
- *
- * We want only one command to be doing this at a time.  When do_wait is set,
- * this will first check if lvmetad is currently being updated by another
- * command, and if so it will delay until that update is finished, or until a
- * timeout, at which point it will go ahead and do the lvmetad update.
- *
- * Callers that have already checked and waited for the updating state, e.g. by
- * using lvmetad_token_matches(), will generaly set do_wait to 0.  Callers that
- * have not checked for the updating state yet will generally set do_wait to 1.
- *
- * If another command doing an update failed, it left lvmetad in the "update in
- * progess" state, so we can't just wait until that state has cleared, but have
- * to go ahead after a timeout.
- *
- * The _lvmetad_is_updating check avoids most races to update lvmetad from
- * multiple commands (which shouldn't generally happen anway) but does not
- * eliminate them.  If an update race happens, the second will see that the
- * previous token was "update in progress" when it calls _token_update().  It
- * will then fail, and the command calling lvmetad_pvscan_all_devs() will
- * generally revert disk scanning and not use lvmetad.
- */
-
-int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait)
-{
-	struct dev_iter *iter;
-	struct device *dev;
-	daemon_reply reply;
-	char *future_token;
-	const char *reason;
-	int was_silent;
-	int replacing_other_update = 0;
-	int replaced_update = 0;
-	int retries = 0;
-	int ret = 1;
-
-	if (!lvmetad_used()) {
-		log_error("Cannot proceed since lvmetad is not active.");
-		return 0;
-	}
-
- retry:
-	/*
-	 * If another update is in progress, delay to allow it to finish,
-	 * rather than interrupting it with our own update.
-	 */
-	if (do_wait && _lvmetad_is_updating(cmd, 1)) {
-		log_warn("WARNING: lvmetad update is interrupting another update in progress.");
-		replacing_other_update = 1;
-	}
-
-	label_scan(cmd);
-
-	lvmcache_pvscan_duplicate_check(cmd);
-
-	if (lvmcache_found_duplicate_pvs()) {
-		log_warn("WARNING: Scan found duplicate PVs.");
-		return 0;
-	}
-
-	log_verbose("Scanning all devices to update lvmetad.");
-
-	if (!(iter = dev_iter_create(cmd->lvmetad_filter, 1))) {
-		log_error("dev_iter creation failed");
-		return 0;
-	}
-
-	future_token = _lvmetad_token;
-	_lvmetad_token = (char *) LVMETAD_TOKEN_UPDATE_IN_PROGRESS;
-
-	if (!_token_update(&replaced_update)) {
-		log_error("Failed to update lvmetad which had an update in progress.");
-		dev_iter_destroy(iter);
-		_lvmetad_token = future_token;
-		return 0;
-	}
-
-	/*
-	 * if _token_update() sets replaced_update to 1, it means that we set
-	 * "update in progress" when the lvmetad was already set to "udpate in
-	 * progress".  This detects a race between two commands doing updates
-	 * at once.  The attempt above to avoid this race using
-	 * _lvmetad_is_updating isn't perfect.
-	 */
-	if (!replacing_other_update && replaced_update) {
-		if (do_wait && !retries) {
-			retries = 1;
-			log_warn("WARNING: lvmetad update in progress, retrying update.");
-			dev_iter_destroy(iter);
-			_lvmetad_token = future_token;
-			goto retry;
-		}
-		log_warn("WARNING: lvmetad update in progress, skipping update.");
-		dev_iter_destroy(iter);
-		_lvmetad_token = future_token;
-		return 0;
-	}
-
-	log_debug_lvmetad("Telling lvmetad to clear its cache");
-	reply = _lvmetad_send(cmd, "pv_clear_all", NULL);
-	if (!_lvmetad_handle_reply(reply, "pv_clear_all", "", NULL))
-		ret = 0;
-	daemon_reply_destroy(reply);
-
-	was_silent = silent_mode();
-	init_silent(1);
-
-	while ((dev = dev_iter_get(cmd, iter))) {
-		if (sigint_caught()) {
-			ret = 0;
-			stack;
-			break;
-		}
-
-		if (!lvmetad_pvscan_single(cmd, dev, NULL, NULL)) {
-			ret = 0;
-			stack;
-			break;
-		}
-	}
-
-	init_silent(was_silent);
-
-	dev_iter_destroy(iter);
-
-	_lvmetad_token = future_token;
-
-	/*
-	 * If we failed to fully and successfully populate lvmetad just leave
-	 * the existing "update in progress" token in place so lvmetad will
-	 * time out our update and force another command to do it.
-	 * (We could try to set the token to empty here, but that doesn't
-	 * help much.)
-	 */
-	if (!ret)
-		return 0;
-
-	if (!_token_update(NULL)) {
-		log_error("Failed to update lvmetad token after device scan.");
-		return 0;
-	}
-
-	/*
-	 * If lvmetad is disabled, and no duplicate PVs were seen, then re-enable lvmetad.
-	 */
-	if (lvmetad_is_disabled(cmd, &reason) && !lvmcache_found_duplicate_pvs()) {
-		log_debug_lvmetad("Enabling lvmetad which was previously disabled.");
-		lvmetad_clear_disabled(cmd);
-	}
-
-	return ret;
-}
-
-int lvmetad_vg_clear_outdated_pvs(struct volume_group *vg)
-{
-	char uuid[64];
-	daemon_reply reply;
-	int result;
-
-	if (!id_write_format(&vg->id, uuid, sizeof(uuid)))
-		return_0;
-
-	log_debug_lvmetad("Sending lvmetad vg_clear_outdated_pvs");
-	reply = _lvmetad_send(vg->cmd, "vg_clear_outdated_pvs", "vgid = %s", uuid, NULL);
-	result = _lvmetad_handle_reply(reply, "vg_clear_outdated_pvs", vg->name, NULL);
-	daemon_reply_destroy(reply);
-
-	return result;
-}
-
-/*
- * Records the state of cached PVs in lvmetad so we can look for changes
- * after rescanning.
- */
-struct pv_cache_list {
-	struct dm_list list;
-	dev_t devt;
-	struct id pvid;
-	const char *vgid;
-	unsigned found : 1;
-	unsigned update_udev : 1;
-};
-
-/*
- * Get the list of PVs known to lvmetad.
- */
-static int _lvmetad_get_pv_cache_list(struct cmd_context *cmd, struct dm_list *pvc_list)
-{
-	daemon_reply reply;
-	struct dm_config_node *cn;
-	struct pv_cache_list *pvcl;
-	const char *pvid_txt;
-	const char *vgid;
-
-	if (!lvmetad_used())
-		return 1;
-
-	log_debug_lvmetad("Asking lvmetad for complete list of known PVs");
-
-	reply = _lvmetad_send(cmd, "pv_list", NULL);
-	if (!_lvmetad_handle_reply(reply, "pv_list", "", NULL)) {
-		daemon_reply_destroy(reply);
-		return_0;
-	}
-
-	if ((cn = dm_config_find_node(reply.cft->root, "physical_volumes"))) {
-		for (cn = cn->child; cn; cn = cn->sib) {
-			if (!(pvcl = dm_pool_zalloc(cmd->mem, sizeof(*pvcl)))) {
-				log_error("pv_cache_list allocation failed.");
-				return 0;
-			}
-
-			pvid_txt = cn->key;
-			if (!id_read_format(&pvcl->pvid, pvid_txt)) {
-				stack;
-				continue;
-			}
-
-			pvcl->devt = dm_config_find_int(cn->child, "device", 0);
-
-			if ((vgid = dm_config_find_str(cn->child, "vgid", NULL)))
-				pvcl->vgid = dm_pool_strdup(cmd->mem, vgid);
-
-			dm_list_add(pvc_list, &pvcl->list);
-		}
-	}
-
-	daemon_reply_destroy(reply);
-
-	return 1;
-}
-
-/*
- * Opening the device RDWR should trigger a udev db update.
- * FIXME: is there a better way to update the udev db than
- * doing an open/close of the device? - For example writing
- * "change" to /sys/block/<device>/uevent?
- */
-static void _update_pv_in_udev(struct cmd_context *cmd, dev_t devt)
-{
-
-	/*
-	 * FIXME: this is diabled as part of removing dev_opens
-	 * to integrate bcache.  If this is really needed, we
-	 * can do a separate open/close here.
-	 */
-	log_debug_devs("SKIP device %d:%d open to update udev",
-		       (int)MAJOR(devt), (int)MINOR(devt));
-
-#if 0
-	struct device *dev;
-
-	if (!(dev = dev_cache_get_by_devt(cmd, devt, cmd->lvmetad_filter))) {
-		log_error("_update_pv_in_udev no dev found");
-		return;
-	}
-
-	if (!dev_open(dev)) {
-		stack;
-		return;
-	}
-
-	if (!dev_close(dev))
-		stack;
-#endif
-}
-
-/*
- * Compare before and after PV lists from before/after rescanning,
- * and update udev db for changes.
- *
- * For PVs that have changed pvid or vgid in lvmetad from rescanning,
- * there may be information in the udev database to update, so open
- * these devices to trigger a udev update.
- *
- * "before" refers to the list of pvs from lvmetad before rescanning
- * "after" refers to the list of pvs from lvmetad after rescanning
- *
- * Comparing both lists, we can see which PVs changed (pvid or vgid),
- * and trigger a udev db update for those.
- */
-static void _update_changed_pvs_in_udev(struct cmd_context *cmd,
-					struct dm_list *pvc_before,
-					struct dm_list *pvc_after)
-{
-	struct pv_cache_list *before;
-	struct pv_cache_list *after;
-	char id_before[ID_LEN + 1];
-	char id_after[ID_LEN + 1];
-	int found;
-
-	dm_list_iterate_items(before, pvc_before) {
-		found = 0;
-
-		dm_list_iterate_items(after, pvc_after) {
-			if (after->found)
-				continue;
-
-			if (before->devt != after->devt)
-				continue;
-
-			if (!id_equal(&before->pvid, &after->pvid)) {
-				(void) dm_strncpy(id_before, (char *) &before->pvid, sizeof(id_before));
-				(void) dm_strncpy(id_after, (char *) &after->pvid, sizeof(id_after));
-
-				log_debug_devs("device %d:%d changed pvid from %s to %s",
-					       (int)MAJOR(before->devt), (int)MINOR(before->devt),
-					       id_before, id_after);
-
-				before->update_udev = 1;
-
-			} else if ((before->vgid && !after->vgid) ||
-				   (after->vgid && !before->vgid) ||
-				   (before->vgid && after->vgid && strcmp(before->vgid, after->vgid))) {
-
-				log_debug_devs("device %d:%d changed vg from %s to %s",
-					       (int)MAJOR(before->devt), (int)MINOR(before->devt),
-					       before->vgid ?: "none", after->vgid ?: "none");
-
-				before->update_udev = 1;
-			}
-
-			after->found = 1;
-			before->found = 1;
-			found = 1;
-			break;
-		}
-
-		if (!found) {
-			(void) dm_strncpy(id_before, (char *) &before->pvid, sizeof(id_before));
-
-			log_debug_devs("device %d:%d pvid %s vg %s is gone",
-				       (int)MAJOR(before->devt), (int)MINOR(before->devt),
-				       id_before, before->vgid ? before->vgid : "none");
-
-			before->update_udev = 1;
-		}
-	}
-
-	dm_list_iterate_items(before, pvc_before) {
-		if (before->update_udev)
-			_update_pv_in_udev(cmd, before->devt);
-	}
-
-	dm_list_iterate_items(after, pvc_after) {
-		if (after->update_udev)
-			_update_pv_in_udev(cmd, after->devt);
-	}
-}
-
-/*
- * Before this command was run, some external entity may have
- * invalidated lvmetad's cache of global information, e.g. lvmlockd.
- *
- * The global information includes things like a new VG, a
- * VG that was removed, the assignment of a PV to a VG;
- * any change that is not isolated within a single VG.
- *
- * The external entity, like a lock manager, would invalidate
- * the lvmetad global cache if it detected that the global
- * information had been changed on disk by something other
- * than a local lvm command, e.g. an lvm command on another
- * host with access to the same devices.  (How it detects
- * the change is specific to lock manager or other entity.)
- *
- * The effect is that metadata on disk is newer than the metadata
- * in the local lvmetad daemon, and the local lvmetad's cache
- * should be updated from disk before this command uses it.
- *
- * So, using this function, a command checks if lvmetad's global
- * cache is valid.  If so, it does nothing.  If not, it rescans
- * devices to update the lvmetad cache, then it notifies lvmetad
- * that it's cache is valid again (consistent with what's on disk.)
- * This command can then go ahead and use the newly refreshed metadata.
- *
- * 1. Check if the lvmetad global cache is invalid.
- * 2. If so, reread metadata from all devices and update the lvmetad cache.
- * 3. Tell lvmetad that the global cache is now valid.
- */
-
-void lvmetad_validate_global_cache(struct cmd_context *cmd, int force)
-{
-	struct dm_list pvc_before; /* pv_cache_list */
-	struct dm_list pvc_after; /* pv_cache_list */
-	const char *reason = NULL;
-	daemon_reply reply;
-	int global_invalid;
-
-	dm_list_init(&pvc_before);
-	dm_list_init(&pvc_after);
-
-	if (!lvmlockd_use()) {
-		log_error(INTERNAL_ERROR "validate global cache without lvmlockd");
-		return;
-	}
-
-	if (!lvmetad_used())
-		return;
-
-	log_debug_lvmetad("Validating global lvmetad cache");
-
-	if (force)
-		goto do_scan;
-
-	log_debug_lvmetad("lvmetad validate send get_global_info");
-
-	reply = daemon_send_simple(_lvmetad, "get_global_info",
-				   "token = %s", "skip",
-				   "pid = " FMTd64, (int64_t)getpid(),
-				   "cmd = %s", get_cmd_name(),
-				   NULL);
-
-	if (reply.error) {
-		log_error("lvmetad_validate_global_cache get_global_info error %d", reply.error);
-		goto do_scan;
-	}
-
-	if (strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
-		log_error("lvmetad_validate_global_cache get_global_info not ok");
-		goto do_scan;
-	}
-
-	global_invalid = daemon_reply_int(reply, "global_invalid", -1);
-
-	daemon_reply_destroy(reply);
-
-	if (!global_invalid)
-		return; /* cache is valid */
-
- do_scan:
-	/*
-	 * Save the current state of pvs from lvmetad so after devices are
-	 * scanned, we can compare to the new state to see if pvs changed.
-	 */
-	_lvmetad_get_pv_cache_list(cmd, &pvc_before);
-
-	log_debug_lvmetad("Rescan all devices to validate global cache.");
-
-	/*
-	 * Update the local lvmetad cache so it correctly reflects any
-	 * changes made on remote hosts.  (It's possible that this command
-	 * already refreshed the local lvmetad because of a token change,
-	 * but we need to do it again here since we now hold the global
-	 * lock.  Another host may have changed things between the time
-	 * we rescanned for the token, and the time we acquired the global
-	 * lock.)
-	 */
-	if (!lvmetad_pvscan_all_devs(cmd, 1)) {
-		log_warn("WARNING: Not using lvmetad because cache update failed.");
-		lvmetad_make_unused(cmd);
-		return;
-	}
-
-	if (lvmetad_is_disabled(cmd, &reason)) {
-		log_warn("WARNING: Not using lvmetad because %s.", reason);
-		lvmetad_make_unused(cmd);
-		return;
-	}
-
-	/*
-	 * Clear the global_invalid flag in lvmetad.
-	 * Subsequent local commands that read global state
-	 * from lvmetad will not see global_invalid until
-	 * another host makes another global change.
-	 */
-	log_debug_lvmetad("lvmetad validate send set_global_info");
-
-	reply = daemon_send_simple(_lvmetad, "set_global_info",
-				   "token = %s", "skip",
-				   "global_invalid = " FMTd64, INT64_C(0),
-				   "pid = " FMTd64, (int64_t)getpid(),
-				   "cmd = %s", get_cmd_name(),
-				   NULL);
-	if (reply.error)
-		log_error("lvmetad_validate_global_cache set_global_info error %d", reply.error);
-
-	if (strcmp(daemon_reply_str(reply, "response", ""), "OK"))
-		log_error("lvmetad_validate_global_cache set_global_info not ok");
-
-	daemon_reply_destroy(reply);
-
-	/*
-	 * Populate this command's lvmcache structures from lvmetad.
-	 */
-	lvmcache_seed_infos_from_lvmetad(cmd);
-
-	/*
-	 * Update the local udev database to reflect PV changes from
-	 * other hosts.
-	 *
-	 * Compare the before and after PV lists, and if a PV's
-	 * pvid or vgid has changed, then open that device to trigger
-	 * a uevent to update the udev db.
-	 *
-	 * This has no direct benefit to lvm, but is just a best effort
-	 * attempt to keep the udev db updated and reflecting current
-	 * lvm information.
-	 *
-	 * FIXME: lvmcache_seed_infos_from_lvmetad() and _lvmetad_get_pv_cache_list()
-	 * each get pv_list from lvmetad, and they could share a single pv_list reply.
-	 */
-	if (!dm_list_empty(&pvc_before)) {
-		_lvmetad_get_pv_cache_list(cmd, &pvc_after);
-		_update_changed_pvs_in_udev(cmd, &pvc_before, &pvc_after);
-	}
-
-	log_debug_lvmetad("Rescanned all devices");
-}
-
-int lvmetad_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const char *vgid)
-{
-	daemon_reply reply;
-	struct dm_config_node *top;
-	const char *system_id = NULL;
-	char uuid[64];
-	int ret;
-
-	if (!id_write_format((const struct id*)vgid, uuid, sizeof(uuid)))
-		return_0;
-
-	log_debug_lvmetad("Sending lvmetad vg_clear_outdated_pvs");
-	reply = _lvmetad_send(cmd, "vg_lookup",
-			      "uuid = %s", uuid,
-			      "name = %s", vgname,
-			       NULL);
-
-	if ((top = dm_config_find_node(reply.cft->root, "metadata")))
-		system_id = dm_config_find_str(top, "metadata/system_id", NULL);
-
-	ret = !is_system_id_allowed(cmd, system_id);
-
-	daemon_reply_destroy(reply);
-
-	return ret;
-}
-
-/*
- * lvmetad has a disabled state in which it continues running,
- * and returns the "disabled" flag in a get_global_info query.
- *
- * Case 1
- * ------
- * When "normal" commands start, (those not specifically
- * intended to rescan devs) they begin by checking lvmetad's
- * token and global info:
- *
- * - If the token doesn't match (should be uncommon), the
- * command first rescans devices to repopulate lvmetad with
- * the global_filter it is using.  After rescanning, the
- * lvmetad disabled state is set or cleared depending on
- * what the scan saw.
- *
- *     An unmatching token occurs when:
- *     . lvmetad was just started and has not been populated yet.
- *     . The global_filter has been changed in lvm.conf since the
- *       last command was run.
- *     . The global_filter is overriden on the command line.
- *       (There's little point in using lvmetad if global_filter
- *       is often changed/overridden.)
- *
- * - If the token does match (common case), the command and
- * lvmetad are using the same global_filter and the command
- * does not rescan devs to repopulate lvmetad, or change the
- * lvmetad disabled state.
- *
- * - After the token check/sync, the command checks if the
- * disabled flag is set in lvmetad.  If it is, the command will
- * not use the lvmetad cache and will revert to scanning, i.e.
- * it runs the same as if use_lvmetad=0.
- *
- * So, "normal" commands try to use the lvmetad cache to avoid
- * scanning devices.  In the uncommon case when the token doesn't
- * match, these commands will first rescan devs to repopulate the
- * lvmetad cache, and then attempt to use the lvmetad cache.
- * In the uncommon case where lvmetad is disabled (by a previous
- * command), the common commands do not rescan devs to repopulate
- * lvmetad, but revert the equivalent of use_lvmetad=0, reading
- * from disk instead of the cache.
- * The combination of those two uncommon cases means that a command
- * could begin by rescanning devs because of a token mismatch, then
- * disable lvmetad as a result of that scan, and continue without
- * using lvmetad.
- *
- * Case 2
- * ------
- * Commands that are meant to scan devices to repopulate the
- * lvmetad cache, e.g. pvscan --cache, will always rescan
- * devices and then set/clear the disabled state according to
- * what they found when scanning.  The global_filter is always
- * used when choosing which devices to scan to populate lvmetad.
- * The command-specific filter is never used when choosing
- * which devices to scan for repopulating the lvmetad cache.
- *
- * During a scan repopulating the lvmetad cache, a command looks
- * for PVs with lvm1 metadata, or duplicate PVs (two devices with
- * the same PVID).  If either of those are found during the scan,
- * the command sets the disabled state in lvmetad.  If none are
- * found, the command clears the disabled state in lvmetad.
- * (Other problems scanning may also cause the command to set the
- * disabled state.)
- *
- * Case 3
- * ------
- * The special command 'pvscan --cache <dev>' is meant to only
- * scan the specified device and send info from the dev to
- * lvmetad.  This single-dev pvscan will not detect duplicate PVs
- * since it only sees the one device.  If lvmetad already knows
- * about the same PV on another device, then lvmetad will be the
- * first to discover that a duplicate PV exists.  In this case,
- * lvmetad sets the disabled state for itself.
- *
- * Duplicates
- * ----------
- * The most common reasons for duplicate PVs to exist are:
- *
- * 1. Multipath.  When multipath is running, it creates a new
- * mpath device for the underlying "duplicate" devs.  lvm has
- * built in, automatic filtering that will hide the duplicate
- * devs of the underlying mpath dev, so the duplicates will
- * be skipping during scanning (multipath_component_detection).
- *
- * If multipath_component_detection=0, or if multipathd is not
- * running, or multipath is not set up to handle a particular
- * set of devs, then lvm will see the multipath paths as
- * duplicates.  lvm will choose one of them to use, consider
- * the other a duplicate, and disable lvmetad.  multipathd
- * should be configured and running to resolve these duplicates,
- * and multipath_component_detection enabled.
- *
- * 2. Cloning by copying.  One device is copied over another, e.g.
- * with dd.  This is a more concerning case because using the
- * wrong device could lead to corruption.  LVM will attempt to
- * choose the best device as the PV, but it may not always
- * be the right one.  In this case, lvmetad is disabled.
- * vgimportclone should be used on the new copy to resolve the
- * duplicates.
- *
- * 3. Cloning by hardware.  A LUN is cloned/snapshotted on
- * a hardware device.  The description here is the same as
- * cloning by copying.
- *
- * 4. Creating LVM snapshots of LVs being used as PVs.
- * If pvcreate is run on an LV, and lvcreate is used to
- * create a snapshot of that LV, then the two LVs will
- * appear to be duplicate PVs.
- *
- * Filtering duplicates
- * --------------------
- * 
- * If all but one copy of a PV is added to the global_filter,
- * then duplicates will not be seen when scanning to populate
- * the lvmetad cache.  Neither common commands nor scanning
- * commands will see the duplicates, and lvmetad will not be
- * disabled.
- *
- * If the global_filter is *not* used to hide duplicates,
- * then lvmetad will be disabled when they are scanned, but
- * common commands can use the command filter to hide the
- * duplicates and work with a selected instance of the PV.
- * The command will not use lvmetad in this case, but will
- * not see duplicate PVs itself because its command filter
- * is more restrictive than the global_filter and has hidden
- * the duplicates.
- */
-
-/*
- * FIXME: if we fail to disable lvmetad, then other commands could
- * potentially use incorrect cache data from lvmetad.  Should we
- * do something more severe if the disable messages fails, like
- * sending SIGKILL to the lvmetad pid?
- *
- * FIXME: log something in syslog any time we disable lvmetad?
- * At a minimum if we fail to disable lvmetad.
- */
-void lvmetad_set_disabled(struct cmd_context *cmd, const char *reason)
-{
-	daemon_reply reply;
-
-	if (!_lvmetad_use)
-		return;
-
-	log_debug_lvmetad("Sending lvmetad disabled %s", reason);
-
-	reply = daemon_send_simple(_lvmetad, "set_global_info",
-				   "token = %s", "skip",
-				   "global_disable = " FMTd64, (int64_t)1,
-				   "disable_reason = %s", reason,
-				   "pid = " FMTd64, (int64_t)getpid(),
-				   "cmd = %s", get_cmd_name(),
-				   NULL);
-	if (reply.error)
-		log_error("Failed to send message to lvmetad %d", reply.error);
-
-	if (strcmp(daemon_reply_str(reply, "response", ""), "OK"))
-		log_error("Failed response from lvmetad.");
-
-	daemon_reply_destroy(reply);
-}
-
-void lvmetad_clear_disabled(struct cmd_context *cmd)
-{
-	daemon_reply reply;
-
-	if (!_lvmetad_use)
-		return;
-
-	log_debug_lvmetad("Sending lvmetad disabled 0");
-
-	reply = daemon_send_simple(_lvmetad, "set_global_info",
-				   "token = %s", "skip",
-				   "global_disable = " FMTd64, (int64_t)0,
-				   "pid = " FMTd64, (int64_t)getpid(),
-				   "cmd = %s", get_cmd_name(),
-				   NULL);
-	if (reply.error)
-		log_error("Failed to send message to lvmetad %d", reply.error);
-
-	if (strcmp(daemon_reply_str(reply, "response", ""), "OK"))
-		log_error("Failed response from lvmetad.");
-
-	daemon_reply_destroy(reply);
-}
-
-int lvmetad_is_disabled(struct cmd_context *cmd, const char **reason)
-{
-	daemon_reply reply;
-	const char *reply_reason;
-	int ret = 0;
-
-	reply = daemon_send_simple(_lvmetad, "get_global_info",
-				   "token = %s", "skip",
-				   "pid = " FMTd64, (int64_t)getpid(),
-				   "cmd = %s", get_cmd_name(),
-				   NULL);
-
-	if (reply.error) {
-		*reason = "send error";
-		ret = 1;
-		goto out;
-	}
-
-	if (strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
-		*reason = "response error";
-		ret = 1;
-		goto out;
-	}
-
-	if (daemon_reply_int(reply, "global_disable", 0)) {
-		ret = 1;
-
-		reply_reason = daemon_reply_str(reply, "disable_reason", NULL);
-
-		if (!reply_reason) {
-			*reason = "<not set>";
-
-		} else if (strstr(reply_reason, LVMETAD_DISABLE_REASON_DIRECT)) {
-			*reason = "the disable flag was set directly";
-
-		} else if (strstr(reply_reason, LVMETAD_DISABLE_REASON_REPAIR)) {
-			*reason = "a repair command was run";
-
-		} else if (strstr(reply_reason, LVMETAD_DISABLE_REASON_DUPLICATES)) {
-			*reason = "duplicate PVs were found";
-
-		} else if (strstr(reply_reason, LVMETAD_DISABLE_REASON_VGRESTORE)) {
-			*reason = "vgcfgrestore is restoring VG metadata";
-
-		} else {
-			*reason = "<unknown>";
-		}
-	}
-out:
-	daemon_reply_destroy(reply);
-	return ret;
-}
-
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
deleted file mode 100644
index 3363607..0000000
--- a/lib/cache/lvmetad.h
+++ /dev/null
@@ -1,213 +0,0 @@
-/*
- * Copyright (C) 2012 Red Hat, Inc.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU Lesser General Public License v.2.1.
- *
- * You should have received a copy of the GNU Lesser General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#ifndef _LVM_METAD_H
-#define _LVM_METAD_H
-
-#include "libdaemon/client/config-util.h"
-
-#include <stdint.h>
-
-struct volume_group;
-struct cmd_context;
-struct dm_config_tree;
-enum activation_change;
-
-typedef int (*activation_handler) (struct cmd_context *cmd,
-				   const char *vgname, const char *vgid,
-				   int partial, int changed,
-				   enum activation_change activate);
-
-#ifdef LVMETAD_SUPPORT
-
-/*
- * lvmetad_connect: connect to lvmetad
- * lvmetad_disconnect: disconnect from lvmetad
- * lvmetad_make_unused: disconnect from lvmetad and refresh cmd filter
- * lvmetad_used: check if lvmetad is being used (i.e. is connected)
- */
-int lvmetad_connect(struct cmd_context *cmd);
-void lvmetad_disconnect(void);
-void lvmetad_make_unused(struct cmd_context *cmd);
-int lvmetad_used(void);
-
-
-/*
- * Configure the socket that lvmetad_init will use to connect to the daemon.
- */
-void lvmetad_set_socket(const char *);
-
-/*
- * Check if lvmetad socket is present (either the one set by lvmetad_set_socket
- * or the default one if not set).
- */
-int lvmetad_socket_present(void);
-
-/*
- * Check if lvmetad pidfile is present, indicating that the lvmetad
- * process is running or not.
- */
-int lvmetad_pidfile_present(void);
-
-/*
- * Set the "lvmetad validity token" (currently only consists of the lvmetad
- * filter. See lvm.conf.
- */
-void lvmetad_set_token(const struct dm_config_value *filter);
-
-/*
- * Release allocated token.
- */
-void lvmetad_release_token(void);
-
-// FIXME What's described here doesn't appear to be implemented yet.
-/*
- * Send a new version of VG metadata to lvmetad. This is normally called after
- * vg_write but before vg_commit. After vg_commit, lvmetad_vg_commit is called
- * to seal the transaction. The result of lvmetad_vg_update is that the new
- * metadata is stored tentatively in lvmetad, but it is not used until
- * lvmetad_vg_commit. The request is validated immediately and lvmetad_vg_commit
- * only constitutes a pointer update.
- */
-int lvmetad_vg_update_pending(struct volume_group *vg);
-int lvmetad_vg_update_finish(struct volume_group *vg);
-
-/*
- * Inform lvmetad that a VG has been removed. This is not entirely safe, but is
- * only needed during vgremove, which does not wipe PV labels and therefore
- * cannot mark the PVs as gone.
- */
-int lvmetad_vg_remove_pending(struct volume_group *vg);
-int lvmetad_vg_remove_finish(struct volume_group *vg);
-
-/*
- * Notify lvmetad that a PV has been found. It is not an error if the PV is
- * already marked as present in lvmetad. If a non-NULL vg pointer is supplied,
- * it is taken to represent the metadata read from the MDA(s) present on that
- * PV. It *is* an error if: the VG is already known to lvmetad, the sequence
- * number on the cached and on the discovered PV match but the metadata content
- * does not.
- */
-int lvmetad_pv_found(struct cmd_context *cmd, const struct id *pvid, struct device *dev,
-		     const struct format_type *fmt, uint64_t label_sector,
-		     struct volume_group *vg,
-		     struct dm_list *found_vgnames,
-		     struct dm_list *changed_vgnames);
-
-/*
- * Inform the daemon that the device no longer exists.
- */
-int lvmetad_pv_gone(dev_t devno, const char *pv_name);
-int lvmetad_pv_gone_by_dev(struct device *dev);
-
-/*
- * Request a list of all PVs available to lvmetad. If requested, this will also
- * read labels off all the PVs to populate lvmcache.
- */
-int lvmetad_pv_list_to_lvmcache(struct cmd_context *cmd);
-
-/*
- * Lookup an individual PV.
- * If found is not NULL, it is set according to whether or not the PV is found,
- * otherwise if the PV is not found an error is returned.
- */
-int lvmetad_pv_lookup(struct cmd_context *cmd, struct id pvid, int *found);
-int lvmetad_pv_lookup_by_dev(struct cmd_context *cmd, struct device *dev, int *found);
-
-/*
- * Request a list of all VGs available to lvmetad and use it to fill in
- * lvmcache..
- */
-int lvmetad_vg_list_to_lvmcache(struct cmd_context *cmd);
-
-/*
- * Request a list of vgid/vgname pairs for all VGs known to lvmetad.
- * Does not do vg_lookup's on each VG, and does not populate lvmcache.
- */
-int lvmetad_get_vgnameids(struct cmd_context *cmd, struct dm_list *vgnameids);
-
-/*
- * Find a VG by its ID or its name in the lvmetad cache. Gives NULL if the VG is
- * not found.
- */
-struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd,
-				       const char *vgname, const char *vgid);
-
-/*
- * Scan a single device and update lvmetad with the result(s).
- */
-int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
-			  struct dm_list *found_vgnames,
-			  struct dm_list *changed_vgnames);
-
-int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait);
-
-int lvmetad_vg_clear_outdated_pvs(struct volume_group *vg);
-void lvmetad_validate_global_cache(struct cmd_context *cmd, int force);
-int lvmetad_token_matches(struct cmd_context *cmd);
-
-int lvmetad_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const char *vgid);
-
-int lvmetad_is_disabled(struct cmd_context *cmd, const char **reason);
-void lvmetad_set_disabled(struct cmd_context *cmd, const char *reason);
-void lvmetad_clear_disabled(struct cmd_context *cmd);
-
-#  else		/* LVMETAD_SUPPORT */
-
-static inline int lvmetad_connect(struct cmd_context *cmd) {return 0;}
-static inline void lvmetad_disconnect(void) {}
-static inline void lvmetad_make_unused(struct cmd_context *cmd) {}
-static inline int lvmetad_used(void) {return 0;}
-static inline void lvmetad_set_socket(const char *thing) {}
-static inline int lvmetad_socket_present(void) {return 0;}
-static inline int lvmetad_pidfile_present(void) {return 0;}
-static inline void lvmetad_set_token(const struct dm_config_value *filter) {}
-static inline void lvmetad_release_token(void) {}
-static inline int lvmetad_vg_update_pending(struct volume_group *vg) {return 1;}
-static inline int lvmetad_vg_update_finish(struct volume_group *vg) {return 1;}
-static inline int lvmetad_vg_remove_pending(struct volume_group *vg) {return 1;}
-static inline int lvmetad_vg_remove_finish(struct volume_group *vg) {return 1;}
-static inline int lvmetad_pv_found(struct cmd_context *cmd, const struct id *pvid, struct device *dev,
-		     const struct format_type *fmt, uint64_t label_sector,
-		     struct volume_group *vg,
-		     struct dm_list *found_vgnames,
-		     struct dm_list *changed_vgnames) {return 1;}
-static inline int lvmetad_pv_gone(dev_t devno, const char *pv_name) {return 1;}
-static inline int lvmetad_pv_gone_by_dev(struct device *dev) {return 1;}
-static inline int lvmetad_pv_list_to_lvmcache(struct cmd_context *cmd) {return 1;}
-static inline int lvmetad_pv_lookup(struct cmd_context *cmd, struct id pvid, int *found) {return 0;}
-static inline int lvmetad_pv_lookup_by_dev(struct cmd_context *cmd, struct device *dev, int *found) {return 0;}
-static inline int lvmetad_vg_list_to_lvmcache(struct cmd_context *cmd) {return 1;}
-static inline int lvmetad_get_vgnameids(struct cmd_context *cmd, struct dm_list *vgnameids) {return 0;}
-static inline struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd,
-				       const char *vgname, const char *vgid) {return NULL;}
-static inline int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
-			  struct dm_list *found_vgnames,
-			  struct dm_list *changed_vgnames) {return 0;}
-
-static inline int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait) {return 0;}
-
-static inline int lvmetad_vg_clear_outdated_pvs(struct volume_group *vg) {return 0;}
-static inline void lvmetad_validate_global_cache(struct cmd_context *cmd, int force) {}
-static inline int lvmetad_token_matches(struct cmd_context *cmd) {return 1;}
-
-static inline int lvmetad_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const char *vgid) {return 0;}
-
-static inline int lvmetad_is_disabled(struct cmd_context *cmd, const char **reason) {return 0;}
-static inline void lvmetad_set_disabled(struct cmd_context *cmd, const char *reason) {}
-static inline void lvmetad_clear_disabled(struct cmd_context *cmd) {}
-
-#  endif	/* LVMETAD_SUPPORT */
-
-#endif
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index ec44bdb..961962c 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -29,7 +29,6 @@
 #include "lib/datastruct/str_list.h"
 #include "lib/metadata/segtype.h"
 #include "lib/cache/lvmcache.h"
-#include "lib/cache/lvmetad.h"
 #include "lib/format_text/archiver.h"
 #include "lib/lvmpolld/lvmpolld-client.h"
 
@@ -265,8 +264,6 @@ static int _parse_debug_classes(struct cmd_context *cmd)
 			debug_classes |= LOG_CLASS_ACTIVATION;
 		else if (!strcasecmp(cv->v.str, "allocation"))
 			debug_classes |= LOG_CLASS_ALLOC;
-		else if (!strcasecmp(cv->v.str, "lvmetad"))
-			debug_classes |= LOG_CLASS_LVMETAD;
 		else if (!strcasecmp(cv->v.str, "metadata"))
 			debug_classes |= LOG_CLASS_METADATA;
 		else if (!strcasecmp(cv->v.str, "cache"))
@@ -1075,14 +1072,12 @@ static struct dev_filter *_init_lvmetad_filter_chain(struct cmd_context *cmd)
 	}
 
 	/* regex filter. Optional. */
-	if (!lvmetad_used()) {
-		if ((cn = find_config_tree_node(cmd, devices_filter_CFG, NULL))) {
-			if (!(filters[nr_filt] = regex_filter_create(cn->v))) {
-				log_error("Failed to create regex device filter");
-				goto bad;
-			}
-			nr_filt++;
+	if ((cn = find_config_tree_node(cmd, devices_filter_CFG, NULL))) {
+		if (!(filters[nr_filt] = regex_filter_create(cn->v))) {
+			log_error("Failed to create regex device filter");
+			goto bad;
 		}
+		nr_filt++;
 	}
 
 	/* device type filter. Required. */
@@ -1093,9 +1088,7 @@ static struct dev_filter *_init_lvmetad_filter_chain(struct cmd_context *cmd)
 	nr_filt++;
 
 	/* usable device filter. Required. */
-	if (!(filters[nr_filt] = usable_filter_create(cmd->dev_types,
-						      lvmetad_used() ? FILTER_MODE_PRE_LVMETAD
-								     : FILTER_MODE_NO_LVMETAD))) {
+	if (!(filters[nr_filt] = usable_filter_create(cmd->dev_types, FILTER_MODE_NO_LVMETAD))) {
 		log_error("Failed to create usabled device filter");
 		goto bad;
 	}
@@ -1175,8 +1168,6 @@ bad:
 int init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)
 {
 	struct dev_filter *filter = NULL, *filter_components[2] = {0};
-	int nr_filt;
-	const struct dm_config_node *cn;
 
 	if (!cmd->initialized.connections) {
 		log_error(INTERNAL_ERROR "connections must be initialized before filters");
@@ -1198,27 +1189,8 @@ int init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)
 	 * and we use exactly one filter chain during device scanning ("filter"
 	 * that includes also "cmd->lvmetad_filter" chain).
 	 */
-	/* filter component 0 */
-	if (lvmetad_used()) {
-		nr_filt = 0;
-		if ((cn = find_config_tree_array(cmd, devices_filter_CFG, NULL))) {
-			if (!(filter_components[nr_filt] = regex_filter_create(cn->v))) {
-				log_verbose("Failed to create regex device filter.");
-				goto bad;
-			}
-			nr_filt++;
-		}
-		if (!(filter_components[nr_filt] = usable_filter_create(cmd->dev_types, FILTER_MODE_POST_LVMETAD))) {
-			log_verbose("Failed to create usable device filter.");
-			goto bad;
-		}
-		nr_filt++;
-		if (!(filter = composite_filter_create(nr_filt, 0, filter_components)))
-			goto_bad;
-	} else {
-		filter = cmd->lvmetad_filter;
-		cmd->lvmetad_filter = NULL;
-	}
+	filter = cmd->lvmetad_filter;
+	cmd->lvmetad_filter = NULL;
 
 	if (!(filter = persistent_filter_create(cmd->dev_types, filter))) {
 		log_verbose("Failed to create persistent device filter.");
@@ -1227,16 +1199,7 @@ int init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)
 
 	cmd->filter = filter;
 
-	if (lvmetad_used()) {
-		nr_filt = 0;
-		filter_components[nr_filt] = cmd->lvmetad_filter;
-		nr_filt++;
-		filter_components[nr_filt] = cmd->filter;
-		nr_filt++;
-		if (!(cmd->full_filter = composite_filter_create(nr_filt, 0, filter_components)))
-			goto_bad;
-	} else
-		cmd->full_filter = filter;
+	cmd->full_filter = filter;
 
 	cmd->initialized.filters = 1;
 	return 1;
@@ -1539,74 +1502,6 @@ static void _init_globals(struct cmd_context *cmd)
 	init_mirror_in_sync(0);
 }
 
-/*
- * init_connections();
- *   _init_lvmetad();
- *     lvmetad_disconnect();  (close previous connection)
- *     lvmetad_set_socket();  (set path from config)
- *     lvmetad_set_token();   (set token from filter config)
- *     if (find_config(use_lvmetad))
- *       lvmetad_connect();
- *
- * If lvmetad_connect() is successful, lvmetad_used() will
- * return 1.
- *
- * If the config has use_lvmetad=0, then lvmetad_connect()
- * will not be called, and lvmetad_used() will return 0.
- *
- * Other code should use lvmetad_used() to check if the
- * command is using lvmetad.
- *
- */
-
-static int _init_lvmetad(struct cmd_context *cmd)
-{
-	const struct dm_config_node *cn;
-	const char *lvmetad_socket;
-
-	lvmetad_disconnect();
-
-	lvmetad_socket = getenv("LVM_LVMETAD_SOCKET");
-	if (!lvmetad_socket)
-		lvmetad_socket = DEFAULT_RUN_DIR "/lvmetad.socket";
-
-	/* TODO?
-		lvmetad_socket = find_config_tree_str(cmd, "lvmetad/socket_path",
-						      DEFAULT_RUN_DIR "/lvmetad.socket");
-	*/
-
-	lvmetad_set_socket(lvmetad_socket);
-	cn = find_config_tree_array(cmd, devices_global_filter_CFG, NULL);
-	lvmetad_set_token(cn ? cn->v : NULL);
-
-	if (find_config_tree_int(cmd, global_locking_type_CFG, NULL) == 3 &&
-	    find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL)) {
-		log_warn("WARNING: Not using lvmetad because locking_type is 3 (clustered).");
-		return 1;
-	}
-
-	if (!find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL)) {
-		if (lvmetad_pidfile_present()) {
-			log_warn("WARNING: Not using lvmetad because config setting use_lvmetad=0.");
-			log_warn("WARNING: To avoid corruption, rescan devices to make changes visible (pvscan --cache).");
-		}
-		return 1;
-	}
-
-	if (!lvmetad_connect(cmd)) {
-		log_warn("WARNING: Failed to connect to lvmetad. Falling back to device scanning.");
-		return 1;
-	}
-
-	if (!lvmetad_used()) {
-		/* This should never happen. */
-		log_error(INTERNAL_ERROR "lvmetad setup incorrect");
-		return 0;
-	}
-
-	return 1;
-}
-
 static int _init_lvmpolld(struct cmd_context *cmd)
 {
 	const char *lvmpolld_socket;
@@ -1624,12 +1519,6 @@ static int _init_lvmpolld(struct cmd_context *cmd)
 
 int init_connections(struct cmd_context *cmd)
 {
-
-	if (!_init_lvmetad(cmd)) {
-		log_error("Failed to initialize lvmetad connection.");
-		goto bad;
-	}
-
 	if (!_init_lvmpolld(cmd)) {
 		log_error("Failed to initialize lvmpolld connection.");
 		goto bad;
@@ -2168,8 +2057,6 @@ void destroy_toolcontext(struct cmd_context *cmd)
 #endif
 	free(cmd);
 
-	lvmetad_release_token();
-	lvmetad_disconnect();
 	lvmpolld_disconnect();
 
 	release_log_memory();
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 2b730ea..3c7ef54 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -157,7 +157,6 @@ struct cmd_context {
 	unsigned lockd_vg_disable:1;
 	unsigned lockd_lv_disable:1;
 	unsigned lockd_gl_removed:1;
-	unsigned lockd_vg_rescan:1;
 	unsigned lockd_vg_default_sh:1;
 	unsigned lockd_vg_enforce_sh:1;
 	unsigned lockd_lv_sh:1;
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 3417127..7882e95 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -289,7 +289,6 @@ cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_COMMENT
 	"then the device is accepted. Be careful mixing 'a' and 'r' patterns,\n"
 	"as the combination might produce unexpected results (test changes.)\n"
 	"Run vgscan after changing the filter to regenerate the cache.\n"
-	"See the use_lvmetad comment for a special case regarding filters.\n"
 	"#\n"
 	"Example\n"
 	"Accept every block device:\n"
@@ -307,7 +306,7 @@ cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_COMMENT
 cfg_array(devices_global_filter_CFG, "global_filter", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#Sa|.*/|", vsn(2, 2, 98), NULL, 0, NULL,
 	"Limit the block devices that are used by LVM system components.\n"
 	"Because devices/filter may be overridden from the command line, it is\n"
-	"not suitable for system-wide device filtering, e.g. udev and lvmetad.\n"
+	"not suitable for system-wide device filtering, e.g. udev.\n"
 	"Use global_filter to hide devices from these LVM system components.\n"
 	"The syntax is the same as devices/filter. Devices rejected by\n"
 	"global_filter are not opened by LVM.\n")
@@ -800,11 +799,11 @@ cfg(log_activation_CFG, "activation", log_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(
 
 cfg(log_activate_file_CFG, "activate_file", log_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL, NULL)
 
-cfg_array(log_debug_classes_CFG, "debug_classes", log_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, "#Smemory#Sdevices#Sio#Sactivation#Sallocation#Slvmetad#Smetadata#Scache#Slocking#Slvmpolld#Sdbus", vsn(2, 2, 99), NULL, 0, NULL,
+cfg_array(log_debug_classes_CFG, "debug_classes", log_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, "#Smemory#Sdevices#Sio#Sactivation#Sallocation#Smetadata#Scache#Slocking#Slvmpolld#Sdbus", vsn(2, 2, 99), NULL, 0, NULL,
 	"Select log messages by class.\n"
 	"Some debugging messages are assigned to a class and only appear in\n"
 	"debug output if the class is listed here. Classes currently\n"
-	"available: memory, devices, io, activation, allocation, lvmetad,\n"
+	"available: memory, devices, io, activation, allocation,\n"
 	"metadata, cache, locking, lvmpolld. Use \"all\" to see everything.\n")
 
 cfg(backup_backup_CFG, "backup", backup_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_BACKUP_ENABLED, vsn(1, 0, 0), NULL, 0, NULL,
@@ -995,38 +994,11 @@ cfg(global_lvdisplay_shows_full_device_path_CFG, "lvdisplay_shows_full_device_pa
 	"Previously this was always shown as /dev/vgname/lvname even when that\n"
 	"was never a valid path in the /dev filesystem.\n")
 
-cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_LVMETAD, vsn(2, 2, 93), "@DEFAULT_USE_LVMETAD@", 0, NULL,
-	"Use lvmetad to cache metadata and reduce disk scanning.\n"
-	"When enabled (and running), lvmetad provides LVM commands with VG\n"
-	"metadata and PV state. LVM commands then avoid reading this\n"
-	"information from disks which can be slow. When disabled (or not\n"
-	"running), LVM commands fall back to scanning disks to obtain VG\n"
-	"metadata. lvmetad is kept updated via udev rules which must be set\n"
-	"up for LVM to work correctly. (The udev rules should be installed\n"
-	"by default.) Without a proper udev setup, changes in the system's\n"
-	"block device configuration will be unknown to LVM, and ignored\n"
-	"until a manual 'pvscan --cache' is run. If lvmetad was running\n"
-	"while use_lvmetad was disabled, it must be stopped, use_lvmetad\n"
-	"enabled, and then started. When using lvmetad, LV activation is\n"
-	"switched to an automatic, event-based mode. In this mode, LVs are\n"
-	"activated based on incoming udev events that inform lvmetad when\n"
-	"PVs appear on the system. When a VG is complete (all PVs present),\n"
-	"it is auto-activated. The auto_activation_volume_list setting\n"
-	"controls which LVs are auto-activated (all by default.)\n"
-	"When lvmetad is updated (automatically by udev events, or directly\n"
-	"by pvscan --cache), devices/filter is ignored and all devices are\n"
-	"scanned by default. lvmetad always keeps unfiltered information\n"
-	"which is provided to LVM commands. Each LVM command then filters\n"
-	"based on devices/filter. This does not apply to other, non-regexp,\n"
-	"filtering settings: component filters such as multipath and MD\n"
-	"are checked during pvscan --cache. To filter a device and prevent\n"
-	"scanning from the LVM system entirely, including lvmetad, use\n"
-	"devices/global_filter.\n")
-
-cfg(global_lvmetad_update_wait_time_CFG, "lvmetad_update_wait_time", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_LVMETAD_UPDATE_WAIT_TIME, vsn(2, 2, 151), NULL, 0, NULL,
-	"Number of seconds a command will wait for lvmetad update to finish.\n"
-	"After waiting for this period, a command will not use lvmetad, and\n"
-	"will revert to disk scanning.\n")
+cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 93), 0, vsn(3, 0, 0), NULL,
+	"This setting is no longer used.\n")
+
+cfg(global_lvmetad_update_wait_time_CFG, "lvmetad_update_wait_time", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, 0, vsn(2, 2, 151), NULL, vsn(3, 0, 0), NULL,
+	"This setting is no longer used.\n")
 
 cfg(global_use_lvmlockd_CFG, "use_lvmlockd", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 124), NULL, 0, NULL,
 	"Use lvmlockd for locking among hosts using LVM on shared storage.\n"
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 5cdbf6d..34eff55 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -18,7 +18,6 @@
 #include "lib/format_text/format-text.h"
 #include "lib/misc/lvm-string.h"
 #include "lib/cache/lvmcache.h"
-#include "lib/cache/lvmetad.h"
 #include "lib/mm/memlock.h"
 #include "lib/commands/toolcontext.h"
 #include "lib/locking/locking.h"
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index a1fce86..c7544aa 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -28,7 +28,6 @@
 #include "lib/mm/xlate.h"
 #include "lib/label/label.h"
 #include "lib/cache/lvmcache.h"
-#include "lib/cache/lvmetad.h"
 #include "lib/mm/memlock.h"
 
 #include <unistd.h>
@@ -1569,11 +1568,6 @@ static struct metadata_area_ops _metadata_text_file_backup_ops = {
 	.vg_commit = _vg_commit_file_backup
 };
 
-static int _mda_export_text_raw(struct metadata_area *mda,
-				struct dm_config_tree *cft,
-				struct dm_config_node *parent);
-static int _mda_import_text_raw(struct lvmcache_info *info, const struct dm_config_node *cn);
-
 static struct metadata_area_ops _metadata_text_raw_ops = {
 	.vg_read = _vg_read_raw,
 	.vg_read_precommit = _vg_read_precommit_raw,
@@ -1591,63 +1585,8 @@ static struct metadata_area_ops _metadata_text_raw_ops = {
 	.pv_analyze_mda = _pv_analyze_mda_raw,
 	.mda_locns_match = _mda_locns_match_raw,
 	.mda_get_device = _mda_get_device_raw,
-	.mda_export_text = _mda_export_text_raw,
-	.mda_import_text = _mda_import_text_raw
 };
 
-/* used only for sending info to lvmetad */
-
-static int _mda_export_text_raw(struct metadata_area *mda,
-				struct dm_config_tree *cft,
-				struct dm_config_node *parent)
-{
-	struct mda_context *mdc = (struct mda_context *) mda->metadata_locn;
-	char mdah[MDA_HEADER_SIZE]; /* temporary */
-
-	if (!mdc) {
-		log_error(INTERNAL_ERROR "mda_export_text_raw no mdc");
-		return 1; /* pretend the MDA does not exist */
-	}
-
-	/* FIXME: why aren't ignore,start,size,free_sectors available? */
-	if (!_raw_read_mda_header((struct mda_header *)mdah, &mdc->area, mda_is_primary(mda)))
-		return 1; /* pretend the MDA does not exist */
-
-	return config_make_nodes(cft, parent, NULL,
-				 "ignore = " FMTd64, (int64_t) mda_is_ignored(mda),
-				 "start = " FMTd64, (int64_t) mdc->area.start,
-				 "size = " FMTd64, (int64_t) mdc->area.size,
-				 "free_sectors = " FMTd64, (int64_t) mdc->free_sectors,
-				 NULL) ? 1 : 0;
-}
-
-/* used only for receiving info from lvmetad */
-
-static int _mda_import_text_raw(struct lvmcache_info *info, const struct dm_config_node *cn)
-{
-	struct device *device;
-	uint64_t offset;
-	uint64_t size;
-	int ignore;
-
-	if (!cn->child)
-		return 0;
-
-	cn = cn->child;
-	device = lvmcache_device(info);
-	size = dm_config_find_int64(cn, "size", 0);
-
-	if (!device || !size)
-		return 0;
-
-	offset = dm_config_find_int64(cn, "start", 0);
-	ignore = dm_config_find_int(cn, "ignore", 0);
-
-	lvmcache_add_mda(info, device, offset, size, ignore);
-
-	return 1;
-}
-
 static int _text_pv_setup(const struct format_type *fmt,
 			  struct physical_volume *pv,
 			  struct volume_group *vg)
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 0836662..d487100 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -246,9 +246,3 @@ struct volume_group *import_vg_from_config_tree(const struct dm_config_tree *cft
 {
 	return _import_vg_from_config_tree(cft, fid, 0);
 }
-
-struct volume_group *import_vg_from_lvmetad_config_tree(const struct dm_config_tree *cft,
-							struct format_instance *fid)
-{
-	return _import_vg_from_config_tree(cft, fid, 1);
-}
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 15d4422..c9b9275 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -19,7 +19,6 @@
 #include "lib/display/display.h"
 #include "lib/commands/toolcontext.h"
 #include "lib/cache/lvmcache.h"
-#include "lib/cache/lvmetad.h"
 #include "lib/locking/lvmlockd.h"
 #include "lib/metadata/lv_alloc.h"
 #include "lib/metadata/pv_alloc.h"
@@ -60,10 +59,6 @@ static int _vsn1_check_version(const struct dm_config_tree *cft)
 	const struct dm_config_node *cn;
 	const struct dm_config_value *cv;
 
-	// TODO if this is pvscan --cache, we want this check back.
-	if (lvmetad_used())
-		return 1;
-
 	/*
 	 * Check the contents field.
 	 */
@@ -186,8 +181,6 @@ static int _read_pv(struct format_instance *fid,
 	const struct dm_config_value *cv;
 	uint64_t size, ba_start;
 
-	int outdated = !strcmp(pvn->parent->key, "outdated_pvs");
-
 	if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl))) ||
 	    !(pvl->pv = dm_pool_zalloc(mem, sizeof(*pvl->pv))))
 		return_0;
@@ -233,13 +226,12 @@ static int _read_pv(struct format_instance *fid,
 
 	memcpy(&pv->vgid, &vg->id, sizeof(vg->id));
 
-	if (!outdated && !_read_flag_config(pvn, &pv->status, PV_FLAGS)) {
+	if (!_read_flag_config(pvn, &pv->status, PV_FLAGS)) {
 		log_error("Couldn't read status flags for physical volume.");
 		return 0;
 	}
 
-	/* TODO is the !lvmetad_used() too coarse here? */
-	if (!pv->dev && !lvmetad_used())
+	if (!pv->dev)
 		pv->status |= MISSING_PV;
 
 	if ((pv->status & MISSING_PV) && pv->dev && pv_mda_used_count(pv) == 0) {
@@ -255,13 +247,13 @@ static int _read_pv(struct format_instance *fid,
 		return 0;
 	}
 
-	if (!outdated && !_read_uint64(pvn, "pe_start", &pv->pe_start)) {
+	if (!_read_uint64(pvn, "pe_start", &pv->pe_start)) {
 		log_error("Couldn't read extent start value (pe_start) "
 			  "for physical volume.");
 		return 0;
 	}
 
-	if (!outdated && !_read_int32(pvn, "pe_count", &pv->pe_count)) {
+	if (!_read_int32(pvn, "pe_count", &pv->pe_count)) {
 		log_error("Couldn't find extent count (pe_count) for "
 			  "physical volume.");
 		return 0;
@@ -320,10 +312,7 @@ static int _read_pv(struct format_instance *fid,
 
 	vg->extent_count += pv->pe_count;
 	vg->free_count += pv->pe_count;
-	if (outdated)
-		dm_list_add(&vg->pvs_outdated, &pvl->list);
-	else
-		add_pvl_to_vgs(vg, pvl);
+	add_pvl_to_vgs(vg, pvl);
 
 	return 1;
 }
@@ -1148,12 +1137,6 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 		goto bad;
 	}
 
-	if (allow_lvmetad_extensions)
-		_read_sections(fid, "outdated_pvs", _read_pv, vg,
-			       vgn, pv_hash, lv_hash, 1);
-	else if (dm_config_has_node(vgn, "outdated_pvs"))
-		log_error(INTERNAL_ERROR "Unexpected outdated_pvs section in metadata of VG %s.", vg->name);
-
 	/* Optional tags */
 	if (dm_config_get_list(vgn, "tags", &cv) &&
 	    !(_read_str_list(vg->vgmem, &vg->tags, cv))) {
diff --git a/lib/label/label.h b/lib/label/label.h
index b86bf2b..a353a67 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -28,8 +28,6 @@
 
 struct labeller;
 
-void allow_reads_with_lvmetad(void);
-
 /* On disk - 32 bytes */
 struct label_header {
 	int8_t id[8];		/* LABELONE */
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index b2b69b8..2e2e992 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -60,8 +60,6 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
 
 #define unlock_vg(cmd, vg, vol)	\
 	do { \
-		if (vg && !lvmetad_vg_update_finish(vg)) \
-			stack; \
 		if (is_real_vg(vol) && !sync_local_dev_names(cmd)) \
 			stack; \
 		if (!lock_vol(cmd, vol, LCK_VG_UNLOCK, NULL)) \
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index a277246..d27c027 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -13,7 +13,6 @@
 #include "lib/metadata/metadata.h"
 #include "lib/metadata/segtype.h"
 #include "lib/activate/activate.h"
-#include "lib/cache/lvmetad.h"
 #include "lib/locking/lvmlockd.h"
 #include "lib/cache/lvmcache.h"
 #include "daemons/lvmlockd/lvmlockd-client.h"
@@ -1324,7 +1323,7 @@ int lockd_gl_create(struct cmd_context *cmd, const char *def_mode, const char *v
 		 *    lvmlockd to return NO_GL_LS/NO_LOCKSPACES.
 		 *
 		 * 2. No sanlock VGs are seen in lvmcache after the disk
-		 *    scan performed in lvmetad_validate_global_cache().
+		 *    scan performed.
 		 *
 		 * If both of those are true, we go ahead and create this new
 		 * VG which will have the global lock enabled.  However, this
@@ -1347,11 +1346,6 @@ int lockd_gl_create(struct cmd_context *cmd, const char *def_mode, const char *v
 		if ((lockd_flags & LD_RF_NO_GL_LS) &&
 		    (lockd_flags & LD_RF_NO_LOCKSPACES) &&
 		    !strcmp(vg_lock_type, "sanlock")) {
-			lvmetad_validate_global_cache(cmd, 1);
-			/*
-			 * lvmcache holds provisional VG lock_type info because
-			 * lvmetad_validate_global_cache did a disk scan.
-			 */
 			if (lvmcache_contains_lock_type_sanlock(cmd)) {
 				/* FIXME: we could check that all are started, and then check that none have gl enabled. */
 				log_error("Global lock failed: start existing sanlock VGs to access global lock.");
@@ -1391,8 +1385,6 @@ int lockd_gl_create(struct cmd_context *cmd, const char *def_mode, const char *v
 	/* --shared with vgcreate does not mean include_shared_vgs */
 	cmd->include_shared_vgs = 0;
 
-	lvmetad_validate_global_cache(cmd, 1);
-
 	return 1;
 }
 
@@ -1438,17 +1430,6 @@ int lockd_gl_create(struct cmd_context *cmd, const char *def_mode, const char *v
  * will continue running for a long time while not needing the global lock,
  * e.g. commands that poll to report progress.
  *
- * Acquiring the global lock also updates the local lvmetad cache if
- * necessary.  lockd_gl() first acquires the lock via lvmlockd, then
- * before returning to the caller, it checks that the global information
- * (e.g. VG namespace, set of orphans) is up to date in lvmetad.  If
- * not, it scans disks and updates the lvmetad cache before returning
- * to the caller.  It does this checking using a version number associated
- * with the global lock.  The version number is incremented each time
- * a change is made to the state associated with the global lock, and
- * if the local version number is lower than the version number in the
- * lock, then the local lvmetad state must be updated.
- *
  * There are two cases where the global lock can be taken in shared mode,
  * and then later converted to ex.  pvchange and pvresize use process_each_pv
  * which does lockd_gl("sh") to get the list of VGs.  Later, in the "_single"
@@ -1491,7 +1472,6 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
 	const char *mode = NULL;
 	const char *opts = NULL;
 	uint32_t lockd_flags;
-	int force_cache_update = 0;
 	int retries = 0;
 	int result;
 
@@ -1536,7 +1516,6 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
 		/* We can continue reading if a shared lock fails. */
 		if (!strcmp(mode, "sh")) {
 			log_warn("Reading without shared global lock.");
-			force_cache_update = 1;
 			goto allow;
 		}
 
@@ -1615,26 +1594,22 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
 
 		if (result == -ESTARTING) {
 			log_warn("Skipping global lock: lockspace is starting");
-			force_cache_update = 1;
 			goto allow;
 		}
 
 		if (result == -ELOCKIO || result == -EVGKILLED) {
 			log_warn("Skipping global lock: storage %s for sanlock leases",
 				  result == -ELOCKIO ? "errors" : "failed");
-			force_cache_update = 1;
 			goto allow;
 		}
 
 		if ((lockd_flags & LD_RF_NO_GL_LS) && (lockd_flags & LD_RF_WARN_GL_REMOVED)) {
 			log_warn("Skipping global lock: VG with global lock was removed");
-			force_cache_update = 1;
 			goto allow;
 		}
 
 		if ((lockd_flags & LD_RF_NO_GL_LS) || (lockd_flags & LD_RF_NO_LOCKSPACES)) {
 			log_warn("Skipping global lock: lockspace not found or started");
-			force_cache_update = 1;
 			goto allow;
 		}
 
@@ -1669,7 +1644,6 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
 	}
 
  allow:
-	lvmetad_validate_global_cache(cmd, force_cache_update);
 	return 1;
 }
 
@@ -1688,9 +1662,7 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
  * assessed in combination with vg->lock_type.
  *
  * The VG lock protects the VG metadata on disk from concurrent access
- * among hosts.  The VG lock also ensures that the local lvmetad cache
- * contains the latest version of the VG metadata from disk.  (Since
- * another host may have changed the VG since it was last read.)
+ * among hosts.
  *
  * The VG lock must be acquired before the VG is read, i.e. before vg_read().
  * The result from lockd_vg() is saved in the "lockd_state" variable, and
@@ -1700,13 +1672,6 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
  * looking at lockd_state.  If vg_read() sees that the VG is a local VG,
  * i.e. lock_type is not sanlock or dlm, then no lock is required, and it
  * ignores lockd_state (which would indicate no lock was found.)
- *
- * When acquiring the VG lock, lvmlockd checks if the local cached copy
- * of the VG metadata in lvmetad is up to date.  If not, it invalidates
- * the VG cached in lvmetad.  This would happen if another host changed
- * the VG since it was last read.  When lvm commands read the VG from
- * lvmetad, they will check if the metadata is invalid, and if so they
- * will reread it from disk, and update the copy in lvmetad.
  */
 
 int lockd_vg(struct cmd_context *cmd, const char *vg_name, const char *def_mode,
@@ -1726,24 +1691,6 @@ int lockd_vg(struct cmd_context *cmd, const char *vg_name, const char *def_mode,
 	 */
 	*lockd_state = 0;
 
-	/*
-	 * Use of lockd_vg_rescan.
-	 *
-	 * This is the VG equivalent of using lvmetad_validate_global_cache()
-	 * for the global lock (after failing to acquire the global lock).  If
-	 * we fail to acquire the VG lock from lvmlockd, then the lvmlockd
-	 * mechanism has been missed that would have updated the cached lvmetad
-	 * copy of the VG.  So, set lockd_vg_rescan to tell the VG reading code
-	 * to treat the lvmetad copy as if the invalid flag had been returned.
-	 * i.e. If a lockd VG is read without a lock, ignore the lvmetad copy
-	 * and read it from disk since we don't know if the cache is stale.
-	 *
-	 * Because lvmlockd requests return an error for local VGs, this will
-	 * be set for local VGs, but it ends up being ignored once the VG is
-	 * read and found to be a local VG.
-	 */
-	cmd->lockd_vg_rescan = 0;
-
 	if (!is_real_vg(vg_name))
 		return 1;
 
@@ -1812,7 +1759,6 @@ int lockd_vg(struct cmd_context *cmd, const char *vg_name, const char *def_mode,
 	 */
 	if (!_use_lvmlockd) {
 		*lockd_state |= LDST_FAIL_REQUEST;
-		cmd->lockd_vg_rescan = 1;
 		return 1;
 	}
 
@@ -1829,7 +1775,6 @@ int lockd_vg(struct cmd_context *cmd, const char *vg_name, const char *def_mode,
 		 * this error for local VGs, but we do care for lockd VGs.
 		 */
 		*lockd_state |= LDST_FAIL_REQUEST;
-		cmd->lockd_vg_rescan = 1;
 		return 1;
 	}
 
@@ -1848,15 +1793,12 @@ int lockd_vg(struct cmd_context *cmd, const char *vg_name, const char *def_mode,
 		break;
 	case -ENOLS:
 		*lockd_state |= LDST_FAIL_NOLS;
-		cmd->lockd_vg_rescan = 1;
 		break;
 	case -ESTARTING:
 		*lockd_state |= LDST_FAIL_STARTING;
-		cmd->lockd_vg_rescan = 1;
 		break;
 	default:
 		*lockd_state |= LDST_FAIL_OTHER;
-		cmd->lockd_vg_rescan = 1;
 	}
 
 	/*
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0ff38a2..3b28bf5 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -20,7 +20,6 @@
 #include "lib/misc/lvm-string.h"
 #include "lib/misc/lvm-file.h"
 #include "lib/cache/lvmcache.h"
-#include "lib/cache/lvmetad.h"
 #include "lib/mm/memlock.h"
 #include "lib/datastruct/str_list.h"
 #include "lib/metadata/pv_alloc.h"
@@ -542,11 +541,6 @@ int vg_remove_direct(struct volume_group *vg)
 	struct pv_list *pvl;
 	int ret = 1;
 
-	if (!lvmetad_vg_remove_pending(vg)) {
-		log_error("Failed to update lvmetad for pending remove.");
-		return 0;
-	}
-
 	if (!vg_remove_mdas(vg)) {
 		log_error("vg_remove_mdas %s failed", vg->name);
 		return 0;
@@ -578,9 +572,6 @@ int vg_remove_direct(struct volume_group *vg)
 		}
 	}
 
-	if (!lvmetad_vg_remove_finish(vg))
-		stack;
-
 	lockd_vg_update(vg);
 
 	set_vg_notify(vg->cmd);
@@ -2987,17 +2978,6 @@ int vg_write(struct volume_group *vg)
 
 	lockd_vg_update(vg);
 
-	/*
-	 * This tells lvmetad the new seqno it should expect to receive
-	 * the metadata for after the commit.  The cached VG will be
-	 * invalid in lvmetad until this command sends the new metadata
-	 * after it's committed.
-	 */
-	if (!lvmetad_vg_update_pending(vg)) {
-		log_error("Failed to prepare new VG metadata in lvmetad cache.");
-		return 0;
-	}
-
 	return 1;
 }
 
@@ -3030,7 +3010,6 @@ static int _vg_commit_mdas(struct volume_group *vg)
 		/* Update cache first time we succeed */
 		if (!failed && !cache_updated) {
 			lvmcache_update_vg(vg, 0);
-			// lvmetad_vg_commit(vg);
 			cache_updated = 1;
 		}
 	}
@@ -3070,14 +3049,6 @@ void vg_revert(struct volume_group *vg)
 	struct metadata_area *mda;
 	struct lv_list *lvl;
 
-	/*
-	 * This will leave the cached copy in lvmetad INVALID (from
-	 * lvmetad_vg_update_pending) and means the VG will be reread from disk
-	 * to update the lvmetad copy, which is what we want to ensure that the
-	 * cached copy is correct.
-	 */
-	vg->lvmetad_update_pending = 0;
-
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (lvl->lv->new_lock_args) {
 			lockd_free_lv(vg->cmd, vg, lvl->lv->name, &lvl->lv->lvid.id[1], lvl->lv->lock_args);
@@ -3646,7 +3617,6 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	struct dm_list all_pvs;
 	char uuid[64] __attribute__((aligned(8)));
 	int skipped_rescan = 0;
-	int reappeared = 0;
 	struct cached_vg_fmtdata *vg_fmtdata = NULL;	/* Additional format-specific data about the vg */
 	unsigned use_previous_vg;
 
@@ -3669,49 +3639,6 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 
 	log_very_verbose("Reading VG %s %s", vgname ?: "<no name>", vgid ? uuid : "<no vgid>");
 
-	if (lvmetad_used() && !use_precommitted) {
-		if ((correct_vg = lvmetad_vg_lookup(cmd, vgname, vgid))) {
-			dm_list_iterate_items(pvl, &correct_vg->pvs)
-				reappeared += _check_reappeared_pv(correct_vg, pvl->pv, enable_repair);
-			if (reappeared && enable_repair)
-				*mdas_consistent = _repair_inconsistent_vg(correct_vg, lockd_state);
-			else
-				*mdas_consistent = !reappeared;
-			if (_wipe_outdated_pvs(cmd, correct_vg, &correct_vg->pvs_outdated, lockd_state)) {
-				/* clear the list */
-				dm_list_init(&correct_vg->pvs_outdated);
-				lvmetad_vg_clear_outdated_pvs(correct_vg);
-                        }
-		}
-
-
-		if (correct_vg) {
-			if (update_old_pv_ext && !_vg_update_old_pv_ext_if_needed(correct_vg)) {
-				release_vg(correct_vg);
-				return_NULL;
-			}
-
-			if (strip_historical_lvs && !vg_strip_outdated_historical_lvs(correct_vg)) {
-				release_vg(correct_vg);
-				return_NULL;
-			}
-
-			/*
-		 	 * When a command reads the vg from lvmetad, and then
-			 * writes the vg, the write path does some disk reads
-		 	 * of the devs.
-		 	 * FIXME: when a command is going to write the vg,
-		 	 * we should just read the vg from disk entirely
-		 	 * and skip reading it from lvmetad.
-		 	 */
-			dm_list_iterate_items(pvl, &correct_vg->pvs)
-				label_scan_open(pvl->pv->dev);
-
-		}
-
-		return correct_vg;
-	}
-
 	/*
 	 * Rescan the devices that are associated with this vg in lvmcache.
 	 * This repeats what was done by the command's initial label scan,
@@ -4489,7 +4416,6 @@ int get_vgnameids(struct cmd_context *cmd, struct dm_list *vgnameids,
 		  const char *only_this_vgname, int include_internal)
 {
 	struct vgnameid_list *vgnl;
-	struct format_type *fmt;
 
 	if (only_this_vgname) {
 		if (!(vgnl = dm_pool_alloc(cmd->mem, sizeof(*vgnl)))) {
@@ -4503,32 +4429,7 @@ int get_vgnameids(struct cmd_context *cmd, struct dm_list *vgnameids,
 		return 1;
 	}
 
-	if (lvmetad_used()) {
-		/*
-		 * This just gets the list of names/ids from lvmetad
-		 * and does not populate lvmcache.
-		 */
-		lvmetad_get_vgnameids(cmd, vgnameids);
-
-		if (include_internal) {
-			dm_list_iterate_items(fmt, &cmd->formats) {
-				if (!(vgnl = dm_pool_alloc(cmd->mem, sizeof(*vgnl)))) {
-					log_error("vgnameid_list allocation failed.");
-					return 0;
-				}
-
-				vgnl->vg_name = dm_pool_strdup(cmd->mem, fmt->orphan_vg_name);
-				vgnl->vgid = NULL;
-				dm_list_add(vgnameids, &vgnl->list);
-			}
-		}
-	} else {
-		/*
-		 * The non-lvmetad case. This function begins by calling
-		 * lvmcache_label_scan() to populate lvmcache.
-		 */
-		lvmcache_get_vgnameids(cmd, include_internal, vgnameids);
-	}
+	lvmcache_get_vgnameids(cmd, include_internal, vgnameids);
 
 	return 1;
 }
@@ -4559,9 +4460,6 @@ int pv_write(struct cmd_context *cmd,
 
 	pv->status &= ~UNLABELLED_PV;
 
-	if (!lvmetad_pv_found(cmd, &pv->id, pv->dev, pv->fmt, pv->label_sector, NULL, NULL, NULL))
-		return_0;
-
 	return 1;
 }
 
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 1c4be48..164fba2 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -460,8 +460,6 @@ size_t export_vg_to_buffer(struct volume_group *vg, char **buf);
 struct dm_config_tree *export_vg_to_config_tree(struct volume_group *vg);
 struct volume_group *import_vg_from_config_tree(const struct dm_config_tree *cft,
 						struct format_instance *fid);
-struct volume_group *import_vg_from_lvmetad_config_tree(const struct dm_config_tree *cft,
-							struct format_instance *fid);
 
 /*
  * Mirroring functions
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 20c2aec..a9cb541 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -20,7 +20,6 @@
 #include "lib/commands/toolcontext.h"
 #include "lib/cache/lvmcache.h"
 #include "lib/format_text/archiver.h"
-#include "lib/cache/lvmetad.h"
 
 struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 			      const char *vg_name)
@@ -56,7 +55,6 @@ struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 
 	dm_list_init(&vg->pvs);
 	dm_list_init(&vg->pv_write_list);
-	dm_list_init(&vg->pvs_outdated);
 	dm_list_init(&vg->lvs);
 	dm_list_init(&vg->historical_lvs);
 	dm_list_init(&vg->tags);
@@ -90,11 +88,6 @@ void release_vg(struct volume_group *vg)
 	if (!vg || (vg->fid && vg == vg->fid->fmt->orphan_vg))
 		return;
 
-	if (vg->saved_in_clvmd) {
-		log_debug("release_vg skip saved %s %p", vg->name, vg);
-		return;
-	}
-
 	release_vg(vg->vg_committed);
 	release_vg(vg->vg_precommitted);
 	_free_vg(vg);
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 4c70406..3fd4756 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -42,8 +42,6 @@ struct volume_group {
 	struct lvmcache_vginfo *vginfo;
 	uint32_t seqno;		/* Metadata sequence number */
 	unsigned skip_validate_lock_args : 1;
-	unsigned lvmetad_update_pending: 1;
-	unsigned saved_in_clvmd: 1;
 
 	/*
 	 * The parsed committed (on-disk) copy of this VG; is NULL if this VG is committed
@@ -85,24 +83,6 @@ struct volume_group {
 	struct dm_list pv_write_list; /* struct pv_list */
 
 	/*
-	 * List of physical volumes that carry outdated metadata that belongs
-	 * to this VG. Currently only populated when lvmetad is in use. The PVs
-	 * on this list could still belong to the VG (but their MDA carries an
-	 * out-of-date copy of the VG metadata) or they could no longer belong
-	 * to the VG. With lvmetad, this list is populated with all PVs that
-	 * have a VGID matching ours, but seqno that is smaller than the
-	 * current seqno for the VG. The MDAs on still-in-VG PVs are updated as
-	 * part of the normal vg_write/vg_commit process. The MDAs on PVs that
-	 * no longer belong to the VG are wiped during vg_read.
-	 *
-	 * However, even though still-in-VG PVs *may* be on the list, this is
-	 * not guaranteed. The in-lvmetad list is cleared whenever out-of-VG
-	 * outdated PVs are wiped during vg_read.
-	 */
-
-	struct dm_list pvs_outdated;
-
-	/*
 	 * logical volumes
 	 * The following relationship should always hold:
 	 * dm_list_size(lvs) = user visible lv_count + snapshot_count + other invisible LVs
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 7d9dd93..e21ca63 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -135,10 +135,6 @@ man-generator: man-generator.o
 	@echo "    [CC] $@"
 	$(CC) $(CFLAGS) -o $@ $<
 
-ifeq ("@BUILD_LVMETAD@", "yes")
-lvm: $(top_builddir)/libdaemon/client/libdaemonclient.a
-endif
-
 lvm.static: $(OBJECTS) lvm-static.o $(top_builddir)/lib/liblvm-internal.a $(INTERNAL_LIBS)
 	@echo "    [CC] $@"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) -o $@ \
diff --git a/tools/args.h b/tools/args.h
index 0d4d3bc..9e83b12 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -96,11 +96,11 @@ arg(bootloaderareasize_ARG, '\0', "bootloaderareasize", sizemb_VAL, 0, 0,
 
 arg(cache_long_ARG, '\0', "cache", 0, 0, 0,
     "#pvscan\n"
-    "Scan one or more devices and send the metadata to lvmetad.\n"
+    "Scan one or more devices and record that they are online.\n"
     "#vgscan\n"
-    "Scan all devices and send the metadata to lvmetad.\n"
+    "This option is no longer used.\n"
     "#lvscan\n"
-    "Scan the devices used by an LV and send the metadata to lvmetad.\n")
+    "This option is no longer used.\n")
 
 arg(cachemetadataformat_ARG, '\0', "cachemetadataformat", cachemetadataformat_VAL, 0, 0,
     "Specifies the cache metadata format used by cache target.\n")
@@ -674,7 +674,6 @@ arg(sysinit_ARG, '\0', "sysinit", 0, 0, 0,
     "acts as a shortcut which selects an appropriate set of options. Currently,\n"
     "this is equivalent to using --ignorelockingfailure, --ignoremonitoring,\n"
     "--poll n, and setting env var LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES.\n"
-    "When used in conjunction with lvmetad enabled and running,\n"
     "vgchange/lvchange skip autoactivation, and defer to pvscan autoactivation.\n")
 
 arg(systemid_ARG, '\0', "systemid", string_VAL, 0, 0,
diff --git a/tools/command-lines.in b/tools/command-lines.in
index bf36738..6192b03 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1373,16 +1373,9 @@ ID: lvs_general
 lvscan
 OO: --all, --blockdevice, --ignorelockingfailure,
 --readonly, --reportformat ReportFmt
-IO: --partial
+IO: --partial, --cache_long
 ID: lvscan_general
 
-lvscan --cache_long
-OO: --blockdevice, --ignorelockingfailure,
---readonly, --reportformat ReportFmt
-OP: LV ...
-IO: --partial
-ID: lvscan_cache
-
 ---
 
 # None of these can function as a required option for pvchange.
@@ -1476,7 +1469,7 @@ ID: pvs_general
 pvscan
 OO: --ignorelockingfailure, --reportformat ReportFmt, --exported, --novolumegroup,
 --short, --uuid
-ID: pvscan_show
+ID: pvscan_display
 DESC: Display PV information.
 
 pvscan --cache_long
@@ -1484,7 +1477,7 @@ OO: --ignorelockingfailure, --reportformat ReportFmt, --background,
 --activate ay, --major Number, --minor Number
 OP: PV|String ...
 ID: pvscan_cache
-DESC: Populate the lvmetad cache by scanning PVs.
+DESC: Autoactivate a VG when all PVs are online.
 
 ---
 
@@ -1734,9 +1727,9 @@ ID: vgs_general
 ---
 
 vgscan
-OO: --cache_long, --ignorelockingfailure, --mknodes, --notifydbus,
+OO: --ignorelockingfailure, --mknodes, --notifydbus,
 --reportformat ReportFmt
-IO: --partial
+IO: --partial, --cache_long
 ID: vgscan_general
 
 ---
diff --git a/tools/command.c b/tools/command.c
index eefc124..42f9aa3 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -133,7 +133,6 @@ static inline int configtype_arg(struct cmd_context *cmd __attribute__((unused))
 #define NO_METADATA_PROCESSING  0x00000040
 #define IGNORE_PERSISTENT_FILTER 0x00000080
 #define MUST_USE_ALL_ARGS        0x00000100
-#define NO_LVMETAD_AUTOSCAN      0x00000200
 #define ENABLE_DUPLICATE_DEVS    0x00000400
 #define DISALLOW_TAG_ARGS        0x00000800
 #define GET_VGNAME_FROM_OPTIONS  0x00001000
diff --git a/tools/commands.h b/tools/commands.h
index 4af92c8..ef5763b 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -103,7 +103,7 @@ xx(lvs,
 
 xx(lvscan,
    "List all logical volumes in all volume groups",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | NO_LVMETAD_AUTOSCAN)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH)
 
 xx(pvchange,
    "Change attributes of physical volume(s)",
@@ -149,7 +149,7 @@ xx(pvs,
 
 xx(pvscan,
    "List all physical volumes",
-   PERMITTED_READ_ONLY | LOCKD_VG_SH | NO_LVMETAD_AUTOSCAN | IGNORE_PERSISTENT_FILTER)
+   PERMITTED_READ_ONLY | LOCKD_VG_SH | IGNORE_PERSISTENT_FILTER)
 
 xx(segtypes,
    "List available segment types",
@@ -201,11 +201,10 @@ xx(vgextend,
 
 xx(vgimport,
    "Register exported volume group with system",
-   ALL_VGS_IS_DEFAULT | NO_LVMETAD_AUTOSCAN)
+   ALL_VGS_IS_DEFAULT)
 
 xx(vgimportclone,
-   "Import a VG from cloned PVs",
-   NO_LVMETAD_AUTOSCAN)
+   "Import a VG from cloned PVs", 0)
 
 xx(vgmerge,
    "Merge volume groups",
@@ -233,7 +232,7 @@ xx(vgs,
 
 xx(vgscan,
    "Search for all volume groups",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | NO_LVMETAD_AUTOSCAN | IGNORE_PERSISTENT_FILTER)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | IGNORE_PERSISTENT_FILTER)
 
 xx(vgsplit,
    "Move physical volumes into a new or existing volume group",
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 6282a6f..07a578b 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1380,20 +1380,6 @@ static int _lvchange_activate_single(struct cmd_context *cmd,
 		}
 	}
 
-	/*
-	 * If --sysinit -aay is used and at the same time lvmetad is used,
-	 * we want to rely on autoactivation to take place. Also, we
-	 * need to take special care here as lvmetad service does
-	 * not neet to be running@this moment yet - it could be
-	 * just too early during system initialization time.
-	 */
-	if (arg_is_set(cmd, sysinit_ARG) && (arg_uint_value(cmd, activate_ARG, 0) == CHANGE_AAY)) {
-		if (lvmetad_used()) {
-			log_warn("WARNING: lvmetad is active, skipping direct activation during sysinit.");
-			return ECMD_PROCESSED;
-		}
-	}
-
 	if (!_lvchange_activate(cmd, lv))
 		return_ECMD_FAILED;
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 1146e7c..cb1753d 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -19,7 +19,6 @@
 #include "lib/label/label.h"
 #include "lvm-version.h"
 #include "lib/locking/lvmlockd.h"
-#include "daemons/lvmetad/lvmetad-client.h"
 
 #include "stub.h"
 #include "lib/misc/last-path-component.h"
@@ -147,6 +146,8 @@ static const struct command_function _command_functions[CMD_COUNT] = {
 	{ lvconvert_to_vdopool_CMD, lvconvert_to_vdopool_cmd },
 	{ lvconvert_to_vdopool_param_CMD, lvconvert_to_vdopool_param_cmd },
 
+	{ pvscan_display_CMD, pvscan_display_cmd },
+	{ pvscan_cache_CMD, pvscan_cache_cmd },
 };
 
 
@@ -2716,11 +2717,6 @@ static int _cmd_no_meta_proc(struct cmd_context *cmd)
 	return cmd->cname->flags & NO_METADATA_PROCESSING;
 }
 
-static int _cmd_no_lvmetad_autoscan(struct cmd_context *cmd)
-{
-	return cmd->cname->flags & NO_LVMETAD_AUTOSCAN;
-}
-
 static int _cmd_ignores_persistent_filter(struct cmd_context *cmd)
 {
 	return cmd->cname->flags & IGNORE_PERSISTENT_FILTER;
@@ -2729,7 +2725,6 @@ static int _cmd_ignores_persistent_filter(struct cmd_context *cmd)
 int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct dm_config_tree *config_string_cft, *config_profile_command_cft, *config_profile_metadata_cft;
-	const char *reason = NULL;
 	int ret = 0;
 	int locking_type;
 	int nolocking = 0;
@@ -2898,13 +2893,6 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		goto out;
 	}
 
-	if (cmd->command->command_enum == lvconvert_repair_CMD) {
-		log_warn("WARNING: Disabling lvmetad cache for repair command.");
-		lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_REPAIR);
-		log_warn("WARNING: Not using lvmetad because of repair.");
-		lvmetad_make_unused(cmd);
-	}
-
 	if (cmd->metadata_read_only &&
 	    !(cmd->cname->flags & PERMITTED_READ_ONLY)) {
 		log_error("%s: Command not permitted while global/metadata_read_only "
@@ -2951,46 +2939,6 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		goto_out;
 	}
 
-	/*
-	 * pvscan/vgscan/lvscan/vgimport want their own control over rescanning
-	 * to populate lvmetad and have similar code of their own.
-	 * Other commands use this general policy for using lvmetad.
-	 *
-	 * The lvmetad cache may need to be repopulated before we use it because:
-	 * - We are reading foreign VGs which others hosts may have changed
-	 *   which our lvmetad would not have seen.
-	 * - lvmetad may have just been started and no command has been run
-	 *   to populate it yet (e.g. no pvscan --cache was run).
-	 * - Another local command may have run with a different global filter
-	 *   which changed the content of lvmetad from what we want (recognized
-	 *   by different token values.)
-	 *
-	 * lvmetad may have been previously disabled (or disabled during the
-	 * rescan done here) because duplicate devices were seen.
-	 * In this case, disable the *use* of lvmetad by this command, reverting to
-	 * disk scanning.
-	 */
-	if (lvmetad_used() && !_cmd_no_lvmetad_autoscan(cmd)) {
-		if (cmd->include_foreign_vgs || !lvmetad_token_matches(cmd)) {
-			if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, cmd->include_foreign_vgs ? 1 : 0)) {
-				log_warn("WARNING: Not using lvmetad because cache update failed.");
-				lvmetad_make_unused(cmd);
-			}
-		}
-
-		if (lvmetad_used() && lvmetad_is_disabled(cmd, &reason)) {
-			log_warn("WARNING: Not using lvmetad because %s.", reason);
-			lvmetad_make_unused(cmd);
-
-			if (strstr(reason, "duplicate")) {
-				log_warn("WARNING: Use multipath or vgimportclone to resolve duplicate PVs?");
-				if (!find_config_tree_bool(cmd, devices_multipath_component_detection_CFG, NULL))
-					log_warn("WARNING: Set multipath_component_detection=1 to hide multipath duplicates.");
-				log_warn("WARNING: After duplicates are resolved, run \"pvscan --cache\" to enable lvmetad.");
-			}
-		}
-	}
-
 	if (cmd->command->functions)
 		/* A command-line-specific function is used */
 		ret = cmd->command->functions->fn(cmd, argc, argv);
diff --git a/tools/lvscan.c b/tools/lvscan.c
index c38208a..cba4d61 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -15,36 +15,6 @@
 
 #include "tools.h"
 
-static int _lvscan_single_lvmetad(struct cmd_context *cmd, struct logical_volume *lv)
-{
-	struct pv_list *pvl;
-	struct dm_list all_pvs;
-	char pvid_s[64] __attribute__((aligned(8)));
-
-	if (!lvmetad_used())
-		return ECMD_PROCESSED;
-
-	dm_list_init(&all_pvs);
-
-	if (!get_pv_list_for_lv(lv->vg->vgmem, lv, &all_pvs))
-		return ECMD_FAILED;
-
-	dm_list_iterate_items(pvl, &all_pvs) {
-		if (!pvl->pv->dev) {
-			if (!id_write_format(&pvl->pv->id, pvid_s, sizeof(pvid_s)))
-				stack;
-			else
-				log_warn("WARNING: Device for PV %s already missing, skipping.",
-					 pvid_s);
-			continue;
-		}
-		if (!lvmetad_pvscan_single(cmd, pvl->pv->dev, NULL, NULL))
-			return ECMD_FAILED;
-	}
-
-	return ECMD_PROCESSED;
-}
-
 static int _lvscan_single(struct cmd_context *cmd, struct logical_volume *lv,
 			  struct processing_handle *handle __attribute__((unused)))
 {
@@ -54,9 +24,6 @@ static int _lvscan_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 	const char *active_str, *snapshot_str;
 
-	if (arg_is_set(cmd, cache_long_ARG))
-		return _lvscan_single_lvmetad(cmd, lv);
-
 	if (!arg_is_set(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
 
@@ -91,32 +58,9 @@ static int _lvscan_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 int lvscan(struct cmd_context *cmd, int argc, char **argv)
 {
-	const char *reason = NULL;
-
-	if (argc && !arg_is_set(cmd, cache_long_ARG)) {
-		log_error("No additional command line arguments allowed");
-		return EINVALID_CMD_LINE;
-	}
-
-	if (!lvmetad_used() && arg_is_set(cmd, cache_long_ARG))
-		log_verbose("Ignoring lvscan --cache because lvmetad is not in use.");
-
-	/* Needed because this command has NO_LVMETAD_AUTOSCAN. */
-	if (lvmetad_used() && (!lvmetad_token_matches(cmd) || lvmetad_is_disabled(cmd, &reason))) {
-		if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, 0)) {
-			log_warn("WARNING: Not using lvmetad because cache update failed.");
-			lvmetad_make_unused(cmd);
-		}
-
-		if (lvmetad_used() && lvmetad_is_disabled(cmd, &reason)) {
-			log_warn("WARNING: Not using lvmetad because %s.", reason);
-			lvmetad_make_unused(cmd);
-		}
-
-		/*
-		 * FIXME: doing lvscan --cache after a full scan is pointless.
-		 * Should the cache case just exit here?
-		 */
+	if (arg_is_set(cmd, cache_long_ARG)) {
+		log_warn("Ignoring lvscan --cache because lvmetad is no longer used.");
+		return ECMD_PROCESSED;
 	}
 
 	return process_each_lv(cmd, argc, argv, NULL, NULL, 0, NULL, NULL, &_lvscan_single);
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 7ad45ca..8772476 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -397,16 +397,13 @@ static int _report_progress(struct cmd_context *cmd, struct poll_operation_id *i
 	int ret;
 
 	/*
-	 * It's reasonable to expect a lockd_vg("sh") here, but it should
-	 * not actually be needed, because we only report the progress on
-	 * the same host where the pvmove/lvconvert is happening.  This means
-	 * that the local pvmove/lvconvert/lvpoll commands are updating the
-	 * local lvmetad with the latest info they have, and we just need to
-	 * read the latest info that they have put into lvmetad about their
-	 * progress.  No VG lock is needed to protect anything here (we're
-	 * just reading the VG), and no VG lock is needed to force a VG read
-	 * from disk to get changes from other hosts, because the only change
-	 * to the VG we're interested in is the change done locally.
+	 * It's reasonable to expect a lockd_vg("sh") here, but it should not
+	 * actually be needed, because we only report the progress on the same
+	 * host where the pvmove/lvconvert is happening.  No VG lock is needed
+	 * to protect anything here (we're just reading the VG), and no VG lock
+	 * is needed to force a VG read from disk to get changes from other
+	 * hosts, because the only change to the VG we're interested in is the
+	 * change done locally.
 	 */
 
 	vg = vg_read(cmd, id->vg_name, NULL, 0, lockd_state);
@@ -602,11 +599,6 @@ static int _poll_daemon(struct cmd_context *cmd, struct poll_operation_id *id,
 			parms->progress_display = 0; /* Child */
 		/* FIXME Use wait_event (i.e. interval = 0) and */
 		/*       fork one daemon per copy? */
-
-		if ((daemon_mode == 1) && find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL)) {
-			if (!lvmetad_connect(cmd))
-				log_warn("WARNING: lvm polling process %d cannot connect to lvmetad.", getpid());
-		}
 	}
 
 	/*
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 0af9d49..4ffb12f 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -103,17 +103,6 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 	struct pvcreate_params pp;
 	int ret;
 
-	if (!argc) {
-		log_error("Please enter a physical volume path.");
-		return 0;
-	}
-
-	/*
-	 * Device info needs to be available for reading the VG backup file in
-	 * _pvcreate_restore_params_from_backup.
-	 */
-	lvmcache_seed_infos_from_lvmetad(cmd);
-
 	/*
 	 * Five kinds of pvcreate param values:
 	 * 1. defaults
diff --git a/tools/pvdisplay.c b/tools/pvdisplay.c
index 5f033f3..3c97a7f 100644
--- a/tools/pvdisplay.c
+++ b/tools/pvdisplay.c
@@ -60,7 +60,6 @@ out:
 
 int pvdisplay(struct cmd_context *cmd, int argc, char **argv)
 {
-	int lock_global = 0;
 	int ret;
 
 	if (arg_is_set(cmd, columns_ARG)) {
@@ -94,25 +93,9 @@ int pvdisplay(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	/*
-	 * If the lock_type is LCK_VG_READ (used only in reporting commands),
-	 * we lock VG_GLOBAL to enable use of metadata cache.
-	 * This can pause alongide pvscan or vgscan process for a while.
-	 */
-	if (!lvmetad_used()) {
-		lock_global = 1;
-		if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ, NULL)) {
-			log_error("Unable to obtain global lock.");
-			return ECMD_FAILED;
-		}
-	}
-
 	ret = process_each_pv(cmd, argc, argv, NULL,
 			      arg_is_set(cmd, all_ARG), 0,
 			      NULL, _pvdisplay_single);
 
-	if (lock_global)
-		unlock_vg(cmd, NULL, VG_GLOBAL);
-
 	return ret;
 }
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 393edb5..a4c0244 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -15,14 +15,11 @@
 
 #include "tools.h"
 
-#include "lib/cache/lvmetad.h"
 #include "lib/cache/lvmcache.h"
 #include "lib/metadata/metadata.h"
 
 #include <dirent.h>
 
-static int _pvscan_online_aa(struct cmd_context *cmd, int argc, char **argv);
-
 struct pvscan_params {
 	int new_pvs_found;
 	int pvs_found;
@@ -37,7 +34,6 @@ struct pvscan_params {
 struct pvscan_aa_params {
 	int refresh_all;
 	unsigned int activate_errors;
-	struct dm_list changed_vgnames;
 };
 
 static int _pvscan_display_pv(struct cmd_context *cmd,
@@ -131,551 +127,12 @@ static int _pvscan_display_single(struct cmd_context *cmd, struct volume_group *
 	return ECMD_PROCESSED;
 }
 
-static int _lvmetad_clear_dev(dev_t devno, int32_t major, int32_t minor)
-{
-	char buf[24];
-
-	(void) dm_snprintf(buf, sizeof(buf), FMTd32 ":" FMTd32, major, minor);
-
-	if (!lvmetad_pv_gone(devno, buf))
-		return_0;
-
-	log_print_unless_silent("Device %s not found. Cleared from lvmetad cache.", buf);
-
-	return 1;
-}
-
-/*
- * pvscan --cache does not perform any lvmlockd locking, and
- * pvscan --cache -aay skips autoactivation in lockd VGs.
- *
- * pvscan --cache populates lvmetad with VG metadata from disk.
- * No lvmlockd locking is needed.  It is expected that lockd VG
- * metadata that is read by pvscan and populated in lvmetad may
- * be immediately stale due to changes to the VG from other hosts
- * during or after this pvscan.  This is normal and not a problem.
- * When a subsequent lvm command uses the VG, it will lock the VG
- * with lvmlockd, read the VG from lvmetad, and update the cached
- * copy from disk if necessary.
- *
- * pvscan --cache -aay does not activate LVs in lockd VGs because
- * activation requires locking, and a lock-start operation is needed
- * on a lockd VG before any locking can be performed in it.
- *
- * An equivalent of pvscan --cache -aay for lockd VGs is:
- * 1. pvscan --cache
- * 2. vgchange --lock-start
- * 3. vgchange -aay -S 'locktype=sanlock || locktype=dlm'
- *
- * [We could eventually add support for autoactivating lockd VGs
- * using pvscan by incorporating the lock start step (which can
- * take a long time), but there may be a better option than
- * continuing to overload pvscan.]
- * 
- * Stages of starting a lockd VG:
- *
- * . pvscan --cache populates lockd VGs in lvmetad without locks,
- *   and this initial cached copy may quickly become stale.
- *
- * . vgchange --lock-start VG reads the VG without the VG lock
- *   because no locks are available until the locking is started.
- *   It only uses the VG name and lock_type from the VG metadata,
- *   and then only uses it to start the VG lockspace in lvmlockd.
- *
- * . Further lvm commands, e.g. activation, can then lock the VG
- *   with lvmlockd and use current VG metdata.
- */
-
-#define REFRESH_BEFORE_AUTOACTIVATION_RETRIES 5
-#define REFRESH_BEFORE_AUTOACTIVATION_RETRY_USLEEP_DELAY 100000
-
-static int _pvscan_autoactivate_single(struct cmd_context *cmd, const char *vg_name,
-				       struct volume_group *vg, struct processing_handle *handle)
-{
-	struct pvscan_aa_params *pp = (struct pvscan_aa_params *)handle->custom_handle;
-	unsigned int refresh_retries = REFRESH_BEFORE_AUTOACTIVATION_RETRIES;
-	int refresh_done = 0;
-
-	if (vg_is_clustered(vg))
-		return ECMD_PROCESSED;
-
-	if (vg_is_exported(vg))
-		return ECMD_PROCESSED;
-
-	if (vg_is_shared(vg))
-		return ECMD_PROCESSED;
-
-	log_debug("pvscan autoactivating VG %s.", vg_name);
-
-	/*
-	 * Refresh LVs in a VG that has "changed" from finding a PV.
-	 * The meaning of "changed" is determined in lvmetad, and is
-	 * returned to the command as a flag.
-	 *
-	 * FIXME: There's a tiny race when suspending the device which is part
-	 * of the refresh because when suspend ioctl is performed, the dm
-	 * kernel driver executes (do_suspend and dm_suspend kernel fn):
-	 *
-	 *          step 1: a check whether the dev is already suspended and
-	 *                  if yes it returns success immediately as there's
-	 *                  nothing to do
-	 *          step 2: it grabs the suspend lock
-	 *          step 3: another check whether the dev is already suspended
-	 *                  and if found suspended, it exits with -EINVAL now
-	 *
-	 * The race can occur in between step 1 and step 2. To prevent premature
-	 * autoactivation failure, we're using a simple retry logic here before
-	 * we fail completely. For a complete solution, we need to fix the
-	 * locking so there's no possibility for suspend calls to interleave
-	 * each other to cause this kind of race.
-	 *
-	 * Remove this workaround with "refresh_retries" once we have proper locking in!
-	 */
-	if (pp->refresh_all || str_list_match_item(&pp->changed_vgnames, vg_name)) {
-		while (refresh_retries--) {
-			log_debug_activation("Refreshing VG %s before autoactivation.", vg_name);
-			if (vg_refresh_visible(cmd, vg)) {
-				refresh_done = 1;
-				break;
-			}
-			usleep(REFRESH_BEFORE_AUTOACTIVATION_RETRY_USLEEP_DELAY);
-		}
-
-		if (!refresh_done)
-			log_warn("%s: refresh before autoactivation failed.", vg->name);
-	}
-
-	log_debug_activation("Autoactivating VG %s.", vg_name);
-
-	if (!vgchange_activate(cmd, vg, CHANGE_AAY)) {
-		log_error("%s: autoactivation failed.", vg->name);
-		pp->activate_errors++;
-		goto out;
-	}
-
-out:
-	return ECMD_PROCESSED;
-}
-
-static int _pvscan_autoactivate(struct cmd_context *cmd, struct pvscan_aa_params *pp,
-				int all_vgs, struct dm_list *vgnames)
-{
-	struct processing_handle *handle = NULL;
-	int ret;
-
-	if (!all_vgs && dm_list_empty(vgnames)) {
-		log_debug("No VGs to autoactivate.");
-		return ECMD_PROCESSED;
-	}
-
-	if (!lvmetad_used())
-		log_warn("WARNING: Autoactivation reading from disk instead of lvmetad.");
-
-	if (!(handle = init_processing_handle(cmd, NULL))) {
-		log_error("Failed to initialize processing handle.");
-		return ECMD_FAILED;
-	}
-
-	handle->custom_handle = pp;
-
-	if (all_vgs) {
-		cmd->cname->flags |= ALL_VGS_IS_DEFAULT;
-		pp->refresh_all = 1;
-	}
-
-	ret = process_each_vg(cmd, 0, NULL, NULL, vgnames, READ_FOR_UPDATE, 0, handle, _pvscan_autoactivate_single);
-
-	destroy_processing_handle(cmd, handle);
-
-	return ret;
-}
-
-static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
-{
-	struct pvscan_aa_params pp = { 0 };
-	struct dm_list single_devs;
-	struct dm_list found_vgnames;
-	struct device *dev;
-	struct device_list *devl;
-	const char *pv_name;
-	const char *reason = NULL;
-	int32_t major = -1;
-	int32_t minor = -1;
-	int devno_args = 0;
-	struct arg_value_group_list *current_group;
-	dev_t devno;
-	int do_activate;
-	int all_vgs = 0;
-	int remove_errors = 0;
-	int add_errors = 0;
-	int ret = ECMD_PROCESSED;
-
-	dm_list_init(&found_vgnames);
-	dm_list_init(&pp.changed_vgnames);
-
-	if ((do_activate = arg_is_set(cmd, activate_ARG))) {
-		if (arg_uint_value(cmd, activate_ARG, 0) != CHANGE_AAY) {
-			log_error("Only --activate ay allowed with pvscan.");
-			return EINVALID_CMD_LINE;
-		}
-
-		if (!lvmetad_used() &&
-		    !find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL)) {
-			log_verbose("Ignoring pvscan --cache -aay because lvmetad is not in use.");
-			return ret;
-		}
-	} else {
-		if (!lvmetad_used()) {
-			log_verbose("Ignoring pvscan --cache because lvmetad is not in use.");
-			return ret;
-		}
-	}
-
-	if (arg_is_set(cmd, major_ARG) + arg_is_set(cmd, minor_ARG))
-		devno_args = 1;
-
-	if (devno_args && (!arg_is_set(cmd, major_ARG) || !arg_is_set(cmd, minor_ARG))) {
-		log_error("Both --major and --minor required to identify devices.");
-		return EINVALID_CMD_LINE;
-	}
-	
-	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ, NULL)) {
-		log_error("Unable to obtain global lock.");
-		return ECMD_FAILED;
-	}
-
-	/*
-	 * This a special case where use_lvmetad=1 in lvm.conf but pvscan
-	 * cannot use lvmetad for some reason.  In this case pvscan should
-	 * still activate LVs even though it's not updating the cache.
-	 */
-	if (do_activate && !lvmetad_used()) {
-		log_verbose("Activating all VGs without lvmetad.");
-		all_vgs = 1;
-		devno_args = 0;
-		goto activate;
-	}
-
-	/*
-	 * Scan all devices when no args are given.
-	 */
-	if (!argc && !devno_args) {
-		log_verbose("Scanning all devices.");
-
-		if (!lvmetad_pvscan_all_devs(cmd, 1)) {
-			log_warn("WARNING: Not using lvmetad because cache update failed.");
-			lvmetad_make_unused(cmd);
-		}
-		if (lvmetad_used() && lvmetad_is_disabled(cmd, &reason)) {
-			log_warn("WARNING: Not using lvmetad because %s.", reason);
-			lvmetad_make_unused(cmd);
-		}
-		all_vgs = 1;
-		goto activate;
-	}
-       
-	/*
-	 * FIXME: when specific devs are named, we generally don't want to scan
-	 * any other devs, but if lvmetad is not yet populated, the first
-	 * 'pvscan --cache dev' does need to do a full scan.  We want to remove
-	 * the need for this case so that 'pvscan --cache dev' is guaranteed to
-	 * never scan any devices other than those specified.
-	 */
-	if (!lvmetad_token_matches(cmd)) {
-		log_verbose("Scanning all devices to initialize lvmetad.");
-
-		if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, 0)) {
-			log_warn("WARNING: Not using lvmetad because cache update failed.");
-			lvmetad_make_unused(cmd);
-		}
-		if (lvmetad_used() && lvmetad_is_disabled(cmd, &reason)) {
-			log_warn("WARNING: Not using lvmetad because %s.", reason);
-			lvmetad_make_unused(cmd);
-		}
-		all_vgs = 1;
-		goto activate;
-	}
-
-	/*
-	 * When args are given, scan only those devices.  If lvmetad is already
-	 * disabled, a full scan is required to reenable it, so there's no
-	 * point in doing individual device scans, so go directly to
-	 * autoactivation.  (FIXME: Should we also skip autoactivation in this
-	 * case since that will read disks with lvmetad disabled?
-	 * i.e. avoid disk access and not activate LVs, or or read from disk
-	 * and activate LVs?)
-	 */
-	if (lvmetad_is_disabled(cmd, &reason)) {
-		log_warn("WARNING: Not using lvmetad because %s.", reason);
-		lvmetad_make_unused(cmd);
-		all_vgs = 1;
-		goto activate;
-	}
-
-	/*
-	 * Step 1: for each device, if it's no longer found, then tell lvmetad
-	 * to drop it.  If the device exists, read metadata from it and send
-	 * that to lvmetad.
-	 *
-	 * When given a device name, check if the device is not visible to
-	 * lvmetad, but still visible to the system, and if so, tell lvmetad to
-	 * drop it (using the major:minor from the system).
-	 *
-	 * When given a major:minor which is not visible to the system, just
-	 * tell lvmetad to drop it directly using that major:minor.
-	 *
-	 * When a device has left the system, it must be dropped using
-	 * --major/--minor because we cannot map the device name to major:minor
-	 *  after the device has left.  (A full rescan could of course be used
-	 *  to drop any devices that have left.)
-	 */
-
-	if (argc || devno_args) {
-		log_verbose("Scanning devices on command line.");
-		cmd->pvscan_cache_single = 1;
-	}
-
-	/* Creates a list of dev names from /dev, sysfs, etc; does not read any. */
-	dev_cache_scan();
-
-	dm_list_init(&single_devs);
-
-	while (argc--) {
-		pv_name = *argv++;
-		if (pv_name[0] == '/') {
-			if (!(dev = dev_cache_get(cmd, pv_name, cmd->lvmetad_filter))) {
-				/* Remove device path from lvmetad. */
-				log_debug("Removing dev %s from lvmetad cache.", pv_name);
-				if ((dev = dev_cache_get(cmd, pv_name, NULL))) {
-					if (!_lvmetad_clear_dev(dev->dev, MAJOR(dev->dev), MINOR(dev->dev)))
-						remove_errors++;
-				} else {
-					log_error("Physical Volume %s not found.", pv_name);
-					ret = ECMD_FAILED;
-				}
-			} else {
-				/*
-				 * Scan device.  This dev could still be
-				 * removed from lvmetad below if it doesn't
-				 * pass other filters.
-				 */
-				log_debug("Scanning dev %s for lvmetad cache.", pv_name);
-
-				if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
-					return_0;
-				devl->dev = dev;
-				dm_list_add(&single_devs, &devl->list);
-			}
-		} else {
-			if (sscanf(pv_name, "%d:%d", &major, &minor) != 2) {
-				log_warn("WARNING: Failed to parse major:minor from %s, skipping.", pv_name);
-				continue;
-			}
-			devno = MKDEV((dev_t)major, (dev_t)minor);
-
-			if (!(dev = dev_cache_get_by_devt(cmd, devno, cmd->lvmetad_filter))) {
-				/* Remove major:minor from lvmetad. */
-				log_debug("Removing dev %d:%d from lvmetad cache.", major, minor);
-				if (!_lvmetad_clear_dev(devno, major, minor))
-					remove_errors++;
-			} else {
-				/*
-				 * Scan device.  This dev could still be
-				 * removed from lvmetad below if it doesn't
-				 * pass other filters.
-				 */
-				log_debug("Scanning dev %d:%d for lvmetad cache.", major, minor);
-
-				if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
-					return_0;
-				devl->dev = dev;
-				dm_list_add(&single_devs, &devl->list);
-			}
-		}
-
-		if (sigint_caught()) {
-			ret = ECMD_FAILED;
-			goto_out;
-		}
-	}
-
-	if (!dm_list_empty(&single_devs)) {
-		label_scan_devs(cmd, cmd->lvmetad_filter, &single_devs);
-
-		dm_list_iterate_items(devl, &single_devs) {
-			dev = devl->dev;
-
-			if (dev->flags & DEV_FILTER_OUT_SCAN) {
-				log_debug("Removing dev %s from lvmetad cache after scan.", dev_name(dev));
-				if (!_lvmetad_clear_dev(dev->dev, MAJOR(dev->dev), MINOR(dev->dev)))
-					remove_errors++;
-				continue;
-			}
-
-			/*
-			 * Devices that exist and pass the lvmetad filter
-			 * are added to lvmetad.
-			 */
-			if (!lvmetad_pvscan_single(cmd, dev, &found_vgnames, &pp.changed_vgnames))
-				add_errors++;
-		}
-	}
-
-	if (!devno_args)
-		goto activate;
-
-	dm_list_init(&single_devs);
-
-	/* Process any grouped --major --minor args */
-	dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
-		major = grouped_arg_int_value(current_group->arg_values, major_ARG, major);
-		minor = grouped_arg_int_value(current_group->arg_values, minor_ARG, minor);
-
-		if (major < 0 || minor < 0)
-			continue;
-
-		devno = MKDEV((dev_t)major, (dev_t)minor);
-
-		if (!(dev = dev_cache_get_by_devt(cmd, devno, cmd->lvmetad_filter))) {
-			/* Remove major:minor from lvmetad. */
-			log_debug("Removing dev %d:%d from lvmetad cache.", major, minor);
-			if (!_lvmetad_clear_dev(devno, major, minor))
-				remove_errors++;
-		} else {
-			/* Add major:minor to lvmetad. */
-			log_debug("Scanning dev %d:%d for lvmetad cache.", major, minor);
-
-			if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
-				return_0;
-			devl->dev = dev;
-			dm_list_add(&single_devs, &devl->list);
-		}
-
-		if (sigint_caught()) {
-			ret = ECMD_FAILED;
-			goto_out;
-		}
-	}
-
-	if (!dm_list_empty(&single_devs)) {
-		label_scan_devs(cmd, cmd->lvmetad_filter, &single_devs);
-
-		dm_list_iterate_items(devl, &single_devs) {
-			dev = devl->dev;
-
-			if (dev->flags & DEV_FILTER_OUT_SCAN) {
-				log_debug("Removing dev %s from lvmetad cache after scan.", dev_name(dev));
-				if (!_lvmetad_clear_dev(dev->dev, MAJOR(dev->dev), MINOR(dev->dev)))
-					remove_errors++;
-				continue;
-			}
-
-			/*
-			 * Devices that exist and pass the lvmetad filter
-			 * are added to lvmetad.
-			 */
-			if (!lvmetad_pvscan_single(cmd, devl->dev, &found_vgnames, &pp.changed_vgnames))
-				add_errors++;
-		}
-	}
-
-	/*
-	 * In the process of scanning devices, lvmetad may have become
-	 * disabled.  If so, revert to scanning for the autoactivation step.
-	 * Only autoactivate the VGs that were found during the dev scans.
-	 */
-	if (lvmetad_used() && lvmetad_is_disabled(cmd, &reason)) {
-		log_warn("WARNING: Not using lvmetad because %s.", reason);
-		lvmetad_make_unused(cmd);
-	}
-
-activate:
-	/*
-	 * Step 2: when the PV was sent to lvmetad, the lvmetad reply
-	 * indicated if all the PVs for the VG are now found.  If so,
-	 * the vgname was added to the list, and we can attempt to
-	 * autoactivate LVs in the VG.
-	 */
-	if (do_activate)
-		ret = _pvscan_autoactivate(cmd, &pp, all_vgs, &found_vgnames);
-
-out:
-	if (remove_errors || add_errors || pp.activate_errors)
-		ret = ECMD_FAILED;
-
-	if (!sync_local_dev_names(cmd))
-		stack;
-	unlock_vg(cmd, NULL, VG_GLOBAL);
-	return ret;
-}
-
-/*
- * Three main pvscan cases related to lvmetad usage:
- * 1. pvscan
- * 2. pvscan --cache
- * 3. pvscan --cache <dev>
- *
- * 1. The 'pvscan' command (without --cache) may or may not attempt to
- * repopulate the lvmetad cache, and may or may not use the lvmetad
- * cache to display PV info:
- *
- * i. If lvmetad is being used and is in a normal state, then 'pvscan'
- * will simply read and display PV info from the lvmetad cache.
- *
- * ii. If lvmetad is not being used, 'pvscan' will read all devices to
- * display the PV info.
- *
- * iii. If lvmetad is being used, but has been disabled (because of
- * duplicate devs), or has a non-matching token
- * (because the device filter is different from the device filter last
- * used to populate lvmetad), then 'pvscan' will begin by rescanning
- * devices to repopulate lvmetad.  If lvmetad is enabled after the
- * rescan, then 'pvscan' will simply read and display PV info from the
- * lvmetad cache (like case i).  If lvmetad is disabled after the
- * rescan, then 'pvscan' will read all devices to display PV info
- * (like case ii).
- *
- * 2. The 'pvscan --cache' command (without named devs) will always
- * attempt to repopulate the lvmetad cache by rescanning all devs
- * (regardless of whether lvmetad was previously disabled or had an
- * unmatching token.)  lvmetad may be enabled or disabled after the
- * rescan (depending on whether duplicate devs).
- *
- * 3. The 'pvscan --cache <dev>' command will attempt to repopulate the
- * lvmetad cache by rescanning all devs if lvmetad has a non-matching
- * token (e.g. because it has not yet been populated, see FIXME above).
- * Otherwise, the command will only rescan the named <dev> and send
- * their metadata to lvmetad.
- */
-
-int pvscan(struct cmd_context *cmd, int argc, char **argv)
+int pvscan_display_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct pvscan_params params = { 0 };
 	struct processing_handle *handle = NULL;
-	const char *reason = NULL;
 	int ret;
 
-	if (arg_is_set(cmd, cache_long_ARG) && !lvmetad_used())
-		return _pvscan_online_aa(cmd, argc, argv);
-
-	if (arg_is_set(cmd, cache_long_ARG))
-		return _pvscan_cache(cmd, argc, argv);
-
-	if (argc) {
-		log_error("Too many parameters on command line.");
-		return EINVALID_CMD_LINE;
-	}
-
-	if (arg_is_set(cmd, activate_ARG)) {
-		log_error("--activate is only valid with --cache.");
-		return EINVALID_CMD_LINE;
-	}
-
-	if (arg_is_set(cmd, major_ARG) || arg_is_set(cmd, minor_ARG)) {
-		log_error("--major and --minor are only valid with --cache.");
-		return EINVALID_CMD_LINE;
-	}
-
 	if (arg_is_set(cmd, novolumegroup_ARG) && arg_is_set(cmd, exported_ARG)) {
 		log_error("Options -e and -n are incompatible");
 		return EINVALID_CMD_LINE;
@@ -686,19 +143,6 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 			  arg_is_set(cmd, exported_ARG) ?
 			  "of exported volume group(s)" : "in no volume group");
 
-	/* Needed because this command has NO_LVMETAD_AUTOSCAN. */
-	if (lvmetad_used() && (!lvmetad_token_matches(cmd) || lvmetad_is_disabled(cmd, &reason))) {
-		if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, 0)) {
-			log_warn("WARNING: Not using lvmetad because cache update failed.");
-			lvmetad_make_unused(cmd);
-		}
-
-		if (lvmetad_used() && lvmetad_is_disabled(cmd, &reason)) {
-			log_warn("WARNING: Not using lvmetad because %s.", reason);
-			lvmetad_make_unused(cmd);
-		}
-	}
-
 	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_WRITE, NULL)) {
 		log_error("Unable to obtain global lock.");
 		return ECMD_FAILED;
@@ -1148,7 +592,7 @@ static int _pvscan_aa(struct cmd_context *cmd, struct pvscan_aa_params *pp,
 	return ret;
 }
 
-static int _pvscan_online_aa(struct cmd_context *cmd, int argc, char **argv)
+int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct pvscan_aa_params pp = { 0 };
 	struct dm_list single_devs;
@@ -1369,3 +813,10 @@ out:
 	return ret;
 }
 
+int pvscan(struct cmd_context *cmd, int argc, char **argv)
+{
+	log_error(INTERNAL_ERROR "Missing function for command definition %d:%s.",
+		  cmd->command->command_index, cmd->command->command_id);
+	return ECMD_FAILED;
+}
+
diff --git a/tools/reporter.c b/tools/reporter.c
index faaff37..cd2a41e 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -1104,8 +1104,7 @@ static int _do_report(struct cmd_context *cmd, struct processing_handle *handle,
 	 * We lock VG_GLOBAL to enable use of metadata cache.
 	 * This can pause alongide pvscan or vgscan process for a while.
 	 */
-	if (single_args->args_are_pvs && (report_type == PVS || report_type == PVSEGS) &&
-	    !lvmetad_used()) {
+	if (single_args->args_are_pvs && (report_type == PVS || report_type == PVSEGS)) {
 		lock_global = 1;
 		if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ, NULL)) {
 			log_error("Unable to obtain global lock.");
@@ -1421,8 +1420,6 @@ static int _report(struct cmd_context *cmd, int argc, char **argv, report_type_t
 		return ECMD_FAILED;
 	}
 
-	lvmcache_seed_infos_from_lvmetad(cmd);
-
 	if (single_args->report_type == FULL) {
 		handle->custom_handle = &args;
 		r = process_each_vg(cmd, argc, argv, NULL, NULL, 0, 1, handle, &_full_report_single);
diff --git a/tools/toollib.c b/tools/toollib.c
index 62e1ecf..36ae125 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -106,8 +106,6 @@ int become_daemon(struct cmd_context *cmd, int skip_lvm)
 
 	strncpy(*cmd->argv, "(lvm2)", strlen(*cmd->argv));
 
-	lvmetad_disconnect();
-
 	if (!skip_lvm) {
 		reset_locking();
 		lvmcache_destroy(cmd, 1, 1);
@@ -1475,7 +1473,6 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_LABEL);
 
 	lvmcache_label_scan(cmd);
-	lvmcache_seed_infos_from_lvmetad(cmd);
 
 	if (argc) {
 		for (; opt < argc; opt++) {
@@ -2064,10 +2061,8 @@ static int _resolve_duplicate_vgnames(struct cmd_context *cmd,
 				continue;
 
 			/*
-			 * Without lvmetad, a label scan has already populated
-			 * lvmcache vginfo with this information.
-			 * With lvmetad, this function does vg_lookup on this
-			 * name/vgid and checks system_id in the metadata.
+			 * label scan has already populated lvmcache vginfo with
+			 * this information.
 			 */
 			if (lvmcache_vg_is_foreign(cmd, vgnl->vg_name, vgnl->vgid)) {
 				if (!id_write_format((const struct id*)vgnl->vgid, uuid, sizeof(uuid)))
@@ -3912,8 +3907,6 @@ static int _get_all_devices(struct cmd_context *cmd, struct dm_list *all_devices
 
 	log_debug("Getting list of all devices");
 
-	lvmcache_seed_infos_from_lvmetad(cmd);
-
 	if (!(iter = dev_iter_create(cmd->full_filter, 1))) {
 		log_error("dev_iter creation failed.");
 		return ECMD_FAILED;
@@ -4574,7 +4567,6 @@ int process_each_pv(struct cmd_context *cmd,
 		log_verbose("Some PVs were not found in first search, retrying.");
 
 		lvmcache_label_scan(cmd);
-		lvmcache_seed_infos_from_lvmetad(cmd);
 
 		ret = _process_pvs_in_vgs(cmd, read_flags, &all_vgnameids, &all_devices,
 					  &arg_missed, &arg_tags, 0, 0,
@@ -5770,12 +5762,6 @@ do_command:
 			continue;
 		}
 
-		if (!lvmetad_pv_gone_by_dev(pd->dev)) {
-			log_error("Failed to remove PV %s from lvmetad.", pd->name);
-			dm_list_move(&pp->arg_fail, &pd->list);
-			continue;
-		}
-
 		log_print_unless_silent("Labels on physical volume \"%s\" successfully wiped.",
 					pd->name);
 	}
@@ -5790,12 +5776,6 @@ do_command:
 			continue;
 		}
 
-		if (!lvmetad_pv_gone_by_dev(pd->dev)) {
-			log_error("Failed to remove PV %s from lvmetad.", pd->name);
-			dm_list_move(&pp->arg_fail, &pd->list);
-			continue;
-		}
-
 		lvmcache_remove_unchosen_duplicate(pd->dev);
 
 		log_print_unless_silent("Labels on physical volume \"%s\" successfully wiped.",
diff --git a/tools/tools.h b/tools/tools.h
index d605768..405910f 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -23,7 +23,6 @@
 #include "lib/activate/activate.h"
 #include "lib/format_text/archiver.h"
 #include "lib/cache/lvmcache.h"
-#include "lib/cache/lvmetad.h"
 #include "lib/locking/lvmlockd.h"
 #include "lvm-version.h"
 #include "lib/config/config.h"
@@ -128,8 +127,6 @@ struct arg_value_group_list {
 #define IGNORE_PERSISTENT_FILTER 0x00000080
 /* Command must use all specified arg names and fail if all cannot be used. */
 #define MUST_USE_ALL_ARGS        0x00000100
-/* Command wants to control the device scan for lvmetad itself. */
-#define NO_LVMETAD_AUTOSCAN      0x00000200
 /* Command should process unused duplicate devices. */
 #define ENABLE_DUPLICATE_DEVS    0x00000400
 /* Command does not accept tags as args. */
@@ -270,4 +267,7 @@ int lvconvert_merge_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_to_vdopool_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_to_vdopool_param_cmd(struct cmd_context *cmd, int argc, char **argv);
 
+int pvscan_display_cmd(struct cmd_context *cmd, int argc, char **argv);
+int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv);
+
 #endif
diff --git a/tools/vgcfgrestore.c b/tools/vgcfgrestore.c
index 0dd7d4d..84032f1 100644
--- a/tools/vgcfgrestore.c
+++ b/tools/vgcfgrestore.c
@@ -14,7 +14,6 @@
  */
 
 #include "tools.h"
-#include "daemons/lvmetad/lvmetad-client.h"
 #include "device_mapper/all.h"
 #include "device_mapper/misc/dm-ioctl.h"
 
@@ -77,7 +76,6 @@ out:
 int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 {
 	const char *vg_name = NULL;
-	int lvmetad_rescan = 0;
 	unsigned found = 0;
 	int ret;
 
@@ -121,22 +119,6 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 
-	/*
-	 * lvmetad does not handle a VG being restored, which would require
-	 * vg_remove of the existing VG, then vg_update of the restored VG.  A
-	 * command failure after removing the existing VG from lvmetad would
-	 * not be easily recovered from.  So, disable the lvmetad cache before
-	 * doing the restore.  After the VG is restored on disk, rescan
-	 * metadata from disk to populate lvmetad from scratch which will pick
-	 * up the VG that was restored on disk.
-	 */
-
-	if (lvmetad_used()) {
-		lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_VGRESTORE);
-		lvmetad_disconnect();
-		lvmetad_rescan = 1;
-	}
-
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
 		log_error("Unable to lock orphans.");
 		return ECMD_FAILED;
@@ -161,7 +143,7 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 		unlock_vg(cmd, NULL, VG_ORPHANS);
 		log_error("Restore failed.");
 		ret = ECMD_FAILED;
-		goto rescan;
+		goto out;
 	}
 
 	ret = ECMD_PROCESSED;
@@ -169,21 +151,6 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 
 	unlock_vg(cmd, NULL, VG_ORPHANS);
 	unlock_vg(cmd, NULL, vg_name);
-rescan:
-	if (lvmetad_rescan) {
-		if (!lvmetad_connect(cmd)) {
-			log_warn("WARNING: Failed to connect to lvmetad.");
-			log_warn("WARNING: Update lvmetad with pvscan --cache.");
-			goto out;
-		}
-		if (!refresh_filters(cmd))
-			stack;
-		if (!lvmetad_pvscan_all_devs(cmd, 1)) {
-			log_warn("WARNING: Failed to scan devices.");
-			log_warn("WARNING: Update lvmetad with pvscan --cache.");
-			goto out;
-		}
-	}
 out:
 	return ret;
 }
diff --git a/tools/vgchange.c b/tools/vgchange.c
index fa0fd53..c8f894d 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -769,20 +769,6 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	/*
-	 * If --sysinit -aay is used and at the same time lvmetad is used,
-	 * we want to rely on autoactivation to take place. Also, we
-	 * need to take special care here as lvmetad service does
-	 * not neet to be running at this moment yet - it could be
-	 * just too early during system initialization time.
-	 */
-	if (arg_is_set(cmd, sysinit_ARG) && (arg_uint_value(cmd, activate_ARG, 0) == CHANGE_AAY)) {
-		if (lvmetad_used()) {
-			log_warn("WARNING: lvmetad is active, skipping direct activation during sysinit");
-			return ECMD_PROCESSED;
-		}
-	}
-
 	if (arg_is_set(cmd, clustered_ARG) && !argc && !arg_is_set(cmd, yes_ARG) &&
 	    (yes_no_prompt("Change clustered property of all volumes groups? [y/n]: ") == 'n')) {
 		log_error("No volume groups changed.");
diff --git a/tools/vgck.c b/tools/vgck.c
index 54bc9d6..a126c29 100644
--- a/tools/vgck.c
+++ b/tools/vgck.c
@@ -37,7 +37,6 @@ static int vgck_single(struct cmd_context *cmd __attribute__((unused)),
 
 int vgck(struct cmd_context *cmd, int argc, char **argv)
 {
-	lvmetad_make_unused(cmd);
 	return process_each_vg(cmd, argc, argv, NULL, NULL, 0, 0, NULL,
 			       &vgck_single);
 }
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 94f95ec..2a40bc7 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -84,8 +84,7 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	lvmcache_label_scan(cmd);              /* Does nothing when using lvmetad. */
-	lvmcache_seed_infos_from_lvmetad(cmd); /* Does nothing unless using lvmetad. */
+	lvmcache_label_scan(cmd);
 
 	if (lvmcache_fmt_from_vgname(cmd, vp_new.vg_name, NULL, 0)) {
 		unlock_vg(cmd, NULL, vp_new.vg_name);
diff --git a/tools/vgimport.c b/tools/vgimport.c
index 8ef8709..26c6363 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -61,8 +61,6 @@ bad:
 
 int vgimport(struct cmd_context *cmd, int argc, char **argv)
 {
-	const char *reason = NULL;
-
 	if (!argc && !arg_is_set(cmd, all_ARG) && !arg_is_set(cmd, select_ARG)) {
 		log_error("Please supply volume groups or -S for selection or use -a for all.");
 		return EINVALID_CMD_LINE;
@@ -89,24 +87,6 @@ int vgimport(struct cmd_context *cmd, int argc, char **argv)
 		cmd->handles_missing_pvs = 1;
 	}
 
-	/*
-	 * Rescan devices and update lvmetad.  lvmetad may hold a copy of the
-	 * VG from before it was exported, if it was exported by another host.
-	 * We need to reread it to see that it's been exported before we can
-	 * import it.
-	 */
-	if (lvmetad_used()) {
-		if (!lvmetad_pvscan_all_devs(cmd, 1)) {
-			log_warn("WARNING: Not using lvmetad because cache update failed.");
-			lvmetad_make_unused(cmd);
-		}
-
-		if (lvmetad_used() && lvmetad_is_disabled(cmd, &reason)) {
-			log_warn("WARNING: Not using lvmetad because %s.", reason);
-			lvmetad_make_unused(cmd);
-		}
-	}
-
 	return process_each_vg(cmd, argc, argv, NULL, NULL,
 			       READ_FOR_UPDATE | READ_ALLOW_EXPORTED,
 			       0, NULL,
diff --git a/tools/vgimportclone.c b/tools/vgimportclone.c
index e37b897..b7fae61 100644
--- a/tools/vgimportclone.c
+++ b/tools/vgimportclone.c
@@ -14,7 +14,6 @@
 
 #include "tools.h"
 #include "lib/cache/lvmcache.h"
-#include "daemons/lvmetad/lvmetad-client.h"
 #include "lib/filters/filter.h"
 
 struct vgimportclone_params {
@@ -204,7 +203,6 @@ int vgimportclone(struct cmd_context *cmd, int argc, char **argv)
 	char base_vgname[NAME_LEN] = { 0 };
 	char tmp_vgname[NAME_LEN] = { 0 };
 	unsigned int vgname_count;
-	int lvmetad_rescan = 0;
 	int ret = ECMD_FAILED;
 
 	if (!argc) {
@@ -219,12 +217,6 @@ int vgimportclone(struct cmd_context *cmd, int argc, char **argv)
 
 	vp.import_vg = arg_is_set(cmd, import_ARG);
 
-	if (lvmetad_used()) {
-		lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_DUPLICATES);
-		lvmetad_disconnect();
-		lvmetad_rescan = 1;
-	}
-
 	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		return ECMD_FAILED;
@@ -362,22 +354,5 @@ out:
 	init_internal_filtering(0);
 	destroy_processing_handle(cmd, handle);
 
-	/* Enable lvmetad again if no duplicates are left. */
-	if (lvmetad_rescan) {
-		if (!lvmetad_connect(cmd)) {
-			log_warn("WARNING: Failed to connect to lvmetad.");
-			log_warn("WARNING: Update lvmetad with pvscan --cache.");
-			return ret;
-		}
-
-		if (!refresh_filters(cmd))
-			stack;
-
-		if (!lvmetad_pvscan_all_devs(cmd, 1)) {
-			log_warn("WARNING: Failed to scan devices.");
-			log_warn("WARNING: Update lvmetad with pvscan --cache.");
-		}
-	}
-
 	return ret;
 }
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index eab3d56..f2c785b 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -73,7 +73,6 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 	}
 
 	lvmcache_label_scan(cmd);
-	lvmcache_seed_infos_from_lvmetad(cmd);
 
 	if (strcmp(vg_name_to, vg_name_from) > 0)
 		lock_vg_from_first = 1;
diff --git a/tools/vgrename.c b/tools/vgrename.c
index 2e6157f..5e386cc 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -61,10 +61,8 @@ static int _vgrename_single(struct cmd_context *cmd, const char *vg_name,
 	 *
 	 * (FIXME: We could look for the new name in the list of all
 	 * VGs that process_each_vg created, but we don't have access
-	 * to that list here, so we have to look in lvmcache.
-	 * This requires populating lvmcache when using lvmetad.)
+	 * to that list here, so we have to look in lvmcache.)
 	 */
-	lvmcache_seed_infos_from_lvmetad(cmd);
 
 	if (lvmcache_vginfo_from_vgname(vp->vg_name_new, NULL)) {
 		log_error("New VG name \"%s\" already exists", vp->vg_name_new);
diff --git a/tools/vgscan.c b/tools/vgscan.c
index f9fa382..470e3d8 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -28,51 +28,10 @@ static int _vgscan_single(struct cmd_context *cmd, const char *vg_name,
 	return ECMD_PROCESSED;
 }
 
-/*
- * Two main vgscan cases related to lvmetad usage:
- * 1. vgscan
- * 2. vgscan --cache
- *
- * 1. The 'vgscan' command (without --cache) may or may not attempt to
- * repopulate the lvmetad cache, and may or may not use the lvmetad
- * cache to display VG info:
- *
- * i. If lvmetad is being used and is in a normal state, then 'vgscan'
- * will simply read and display VG info from the lvmetad cache.
- *
- * ii. If lvmetad is not being used, 'vgscan' will read all devices to
- * display the VG info.
- *
- * iii. If lvmetad is being used, but has been disabled (because of
- * duplicate devs), or has a non-matching token
- * (because the device filter is different from the device filter last
- * used to populate lvmetad), then 'vgscan' will begin by rescanning
- * devices to repopulate lvmetad.  If lvmetad is enabled after the
- * rescan, then 'vgscan' will simply read and display VG info from the
- * lvmetad cache (like case i).  If lvmetad is disabled after the
- * rescan, then 'vgscan' will read all devices to display VG info
- * (like case ii).
- *
- * 2. The 'vgscan --cache' command will always attempt to repopulate
- * the lvmetad cache by rescanning all devs (regardless of whether
- * lvmetad was previously disabled or had an unmatching token.)
- * lvmetad may be enabled or disabled after the rescan (depending
- * on whether duplicate devs were found).
- * If enabled, then it will simply read and display VG info from the
- * lvmetad cache (like case 1.i.).  If disabled, then it will
- * read all devices to display VG info (like case 1.ii.)
- */
-
 int vgscan(struct cmd_context *cmd, int argc, char **argv)
 {
-	const char *reason = NULL;
 	int maxret, ret;
 
-	if (argc) {
-		log_error("Too many parameters on command line");
-		return EINVALID_CMD_LINE;
-	}
-
 	if (arg_is_set(cmd, notifydbus_ARG)) {
 		if (!lvmnotify_is_supported()) {
 			log_error("Cannot notify dbus: lvm is not built with dbus support.");
@@ -93,29 +52,12 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	if (cmd->filter->wipe)
-		cmd->filter->wipe(cmd->filter);
-	lvmcache_destroy(cmd, 1, 0);
-
-	if (!lvmetad_used() && arg_is_set(cmd, cache_long_ARG))
-		log_verbose("Ignoring vgscan --cache command because lvmetad is not in use.");
-
-	if (lvmetad_used() && (arg_is_set(cmd, cache_long_ARG) || !lvmetad_token_matches(cmd) || lvmetad_is_disabled(cmd, &reason))) {
-		if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, arg_is_set(cmd, cache_long_ARG))) {
-			log_warn("WARNING: Not using lvmetad because cache update failed.");
-			lvmetad_make_unused(cmd);
-		}
-
-		if (lvmetad_used() && lvmetad_is_disabled(cmd, &reason)) {
-			log_warn("WARNING: Not using lvmetad because %s.", reason);
-			lvmetad_make_unused(cmd);
-		}
+	if (arg_is_set(cmd, cache_long_ARG)) {
+		log_warn("Ignoring vgscan --cache command because lvmetad is no longer used.");
+		return ECMD_PROCESSED;
 	}
 
-	if (!lvmetad_used())
-		log_print_unless_silent("Reading all physical volumes.  This may take a while...");
-	else
-		log_print_unless_silent("Reading volume groups from cache.");
+	log_print_unless_silent("Reading all physical volumes.  This may take a while...");
 
 	maxret = process_each_vg(cmd, argc, argv, NULL, NULL, 0, 0, NULL, &_vgscan_single);
 
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 7ec00f8..5824c82 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -582,7 +582,6 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	lvmcache_label_scan(cmd);
-	lvmcache_seed_infos_from_lvmetad(cmd);
 
 	if (strcmp(vg_name_to, vg_name_from) < 0)
 		lock_vg_from_first = 0;
@@ -728,8 +727,6 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	if (!vg_write(vg_to) || !vg_commit(vg_to))
 		goto_bad;
 
-	lvmetad_vg_update_finish(vg_to);
-
 	backup(vg_to);
 
 	/*
@@ -741,8 +738,6 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		if (!vg_write(vg_from) || !vg_commit(vg_from))
 			goto_bad;
 
-		lvmetad_vg_update_finish(vg_from);
-
 		backup(vg_from);
 	}
 
@@ -767,8 +762,6 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	if (!vg_write(vg_to) || !vg_commit(vg_to))
 		goto_bad;
 
-	lvmetad_vg_update_finish(vg_to);
-
 	backup(vg_to);
 
 	log_print_unless_silent("%s volume group \"%s\" successfully split from \"%s\"",


