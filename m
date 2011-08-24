From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Aug 2011 08:27:52 -0000
Subject: LVM2 ./configure ./configure.in lib/Makefile.i ...
Message-ID: <20110824082752.16608.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-08-24 08:27:51

Modified files:
	.              : configure configure.in 
	lib            : Makefile.in 
	lib/metadata   : segtype.h 
	lib/misc       : configure.h.in 
Added files:
	lib/thin       : .exported_symbols Makefile.in thin.c 

Log message:
	Initial code layout for thin provisioning target
	
	Only registers init_thin_segtype
	
	Option --with-thin=internal needed for compilation.
	For now useful only for developememt!

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.155&r2=1.156
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.169&r2=1.170
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.111&r2=1.112
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/.exported_symbols.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/Makefile.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/configure	2011/08/12 01:52:16	1.155
+++ LVM2/configure	2011/08/24 08:27:49	1.156
@@ -608,6 +608,7 @@
 UDEV_SYNC
 UDEV_RULES
 UDEV_PC
+THIN
 TESTING
 STATIC_LINK
 STATICDIR
@@ -796,6 +797,7 @@
 with_mirrors
 with_raid
 with_replicators
+with_thin
 enable_readline
 enable_realtime
 enable_ocf
@@ -1541,6 +1543,8 @@
                           [[TYPE=internal]]
   --with-replicators=TYPE replicator support: internal/shared/none
                           [[TYPE=none]]
+  --with-thin=TYPE        thin provisioning support: internal/shared/none
+                          [[TYPE=none]]
   --with-ocfdir=DIR       install OCF files in DIR
                           [[PREFIX/lib/ocf/resource.d/lvm2]]
   --with-clvmd=TYPE       build cluster LVM Daemon
@@ -6924,6 +6928,28 @@
 esac
 
 ################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include thin provisioning" >&5
+$as_echo_n "checking whether to include thin provisioning... " >&6; }
+
+# Check whether --with-thin was given.
+if test "${with_thin+set}" = set; then :
+  withval=$with_thin; THIN=$withval
+else
+  THIN=none
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $THIN" >&5
+$as_echo "$THIN" >&6; }
+
+case "$THIN" in
+  none|shared) ;;
+  internal)
+$as_echo "#define THIN_INTERNAL 1" >>confdefs.h
+ ;;
+  *) as_fn_error $? "--with-thin parameter invalid ($THIN)" "$LINENO" 5 ;;
+esac
+
+################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable readline" >&5
 $as_echo_n "checking whether to enable readline... " >&6; }
 # Check whether --enable-readline was given.
@@ -10160,8 +10186,9 @@
 
 
 
+
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makef!
 ile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/Makefile test/Makefile test/api/Makefile tools/M!
 akefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -10875,6 +10902,7 @@
     "lib/misc/lvm-version.h") CONFIG_FILES="$CONFIG_FILES lib/misc/lvm-version.h" ;;
     "lib/raid/Makefile") CONFIG_FILES="$CONFIG_FILES lib/raid/Makefile" ;;
     "lib/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES lib/snapshot/Makefile" ;;
+    "lib/thin/Makefile") CONFIG_FILES="$CONFIG_FILES lib/thin/Makefile" ;;
     "libdm/Makefile") CONFIG_FILES="$CONFIG_FILES libdm/Makefile" ;;
     "libdm/libdevmapper.pc") CONFIG_FILES="$CONFIG_FILES libdm/libdevmapper.pc" ;;
     "liblvm/Makefile") CONFIG_FILES="$CONFIG_FILES liblvm/Makefile" ;;
--- LVM2/configure.in	2011/08/12 01:52:17	1.169
+++ LVM2/configure.in	2011/08/24 08:27:50	1.170
@@ -378,6 +378,23 @@
 esac
 
 ################################################################################
+dnl -- thin provisioning
+AC_MSG_CHECKING(whether to include thin provisioning)
+AC_ARG_WITH(thin,
+	    AC_HELP_STRING([--with-thin=TYPE],
+			   [thin provisioning support: internal/shared/none
+			    [[TYPE=none]]]),
+	    THIN=$withval, THIN=none)
+AC_MSG_RESULT($THIN)
+
+case "$THIN" in
+  none|shared) ;;
+  internal) AC_DEFINE([THIN_INTERNAL], 1,
+		[Define to 1 to include built-in support for thin provisioning.]) ;;
+  *) AC_MSG_ERROR([--with-thin parameter invalid ($THIN)]) ;;
+esac
+
+################################################################################
 dnl -- Disable readline
 AC_MSG_CHECKING(whether to enable readline)
 AC_ARG_ENABLE([readline],
@@ -1351,6 +1368,7 @@
 AC_SUBST(STATICDIR)
 AC_SUBST(STATIC_LINK)
 AC_SUBST(TESTING)
+AC_SUBST(THIN)
 AC_SUBST(UDEV_LIBS)
 AC_SUBST(UDEV_PC)
 AC_SUBST(UDEV_RULES)
@@ -1396,6 +1414,7 @@
 lib/misc/lvm-version.h
 lib/raid/Makefile
 lib/snapshot/Makefile
+lib/thin/Makefile
 libdm/Makefile
 libdm/libdevmapper.pc
 liblvm/Makefile
--- LVM2/lib/Makefile.in	2011/08/11 18:24:41	1.111
+++ LVM2/lib/Makefile.in	2011/08/24 08:27:50	1.112
@@ -40,6 +40,10 @@
   SUBDIRS += replicator
 endif
 
+ifeq ("@THIN@", "shared")
+  SUBDIRS += thin
+endif
+
 SOURCES =\
 	activate/activate.c \
 	cache/lvmcache.c \
@@ -153,6 +157,10 @@
   SOURCES += replicator/replicator.c
 endif
 
+ifeq ("@THIN@", "internal")
+  SOURCES += thin/thin.c
+endif
+
 ifeq ("@DEVMAPPER@", "yes")
   SOURCES +=\
 	activate/dev_manager.c \
@@ -181,6 +189,7 @@
 	mirror \
 	raid \
 	replicator \
+	thin \
 	locking
 endif
 
--- LVM2/lib/metadata/segtype.h	2011/08/02 22:07:22	1.36
+++ LVM2/lib/metadata/segtype.h	2011/08/24 08:27:50	1.37
@@ -39,6 +39,7 @@
 #define SEG_REPLICATOR		0x00000100U
 #define SEG_REPLICATOR_DEV	0x00000200U
 #define SEG_RAID		0x00000400U
+#define SEG_THIN		0x00000800U
 #define SEG_UNKNOWN		0x80000000U
 
 #define seg_is_mirrored(seg)	((seg)->segtype->flags & SEG_AREAS_MIRRORED ? 1 : 0)
@@ -48,6 +49,7 @@
 #define seg_is_snapshot(seg)	((seg)->segtype->flags & SEG_SNAPSHOT ? 1 : 0)
 #define seg_is_virtual(seg)	((seg)->segtype->flags & SEG_VIRTUAL ? 1 : 0)
 #define seg_is_raid(seg)	((seg)->segtype->flags & SEG_RAID ? 1 : 0)
+#define seg_is_thin(seg)	((seg)->segtype->flags & SEG_THIN ? 1 : 0)
 #define seg_can_split(seg)	((seg)->segtype->flags & SEG_CAN_SPLIT ? 1 : 0)
 #define seg_cannot_be_zeroed(seg) ((seg)->segtype->flags & SEG_CANNOT_BE_ZEROED ? 1 : 0)
 #define seg_monitored(seg)	((seg)->segtype->flags & SEG_MONITORED ? 1 : 0)
@@ -56,6 +58,7 @@
 #define segtype_is_striped(segtype)	((segtype)->flags & SEG_AREAS_STRIPED ? 1 : 0)
 #define segtype_is_mirrored(segtype)	((segtype)->flags & SEG_AREAS_MIRRORED ? 1 : 0)
 #define segtype_is_raid(segtype)	((segtype)->flags & SEG_RAID ? 1 : 0)
+#define segtype_is_thin(segtype)	((segtype)->flags & SEG_THIN ? 1 : 0)
 #define segtype_is_virtual(segtype)	((segtype)->flags & SEG_VIRTUAL ? 1 : 0)
 
 struct segment_type {
@@ -156,4 +159,8 @@
 struct segment_type *init_crypt_segtype(struct cmd_context *cmd);
 #endif
 
+#ifdef THIN_INTERNAL
+struct segment_type *init_thin_segtype(struct cmd_context *cmd);
+#endif
+
 #endif
--- LVM2/lib/misc/configure.h.in	2011/08/09 18:14:49	1.34
+++ LVM2/lib/misc/configure.h.in	2011/08/24 08:27:51	1.35
@@ -522,6 +522,9 @@
 /* Define to 1 if you have the ANSI C header files. */
 #undef STDC_HEADERS
 
+/* Define to 1 to include built-in support for thin provisioning. */
+#undef THIN_INTERNAL
+
 /* Define to 1 if you can safely include both <sys/time.h> and <time.h>. */
 #undef TIME_WITH_SYS_TIME
 
/cvs/lvm2/LVM2/lib/thin/.exported_symbols,v  -->  standard output
revision 1.1
--- LVM2/lib/thin/.exported_symbols
+++ -	2011-08-24 08:27:52.336622000 +0000
@@ -0,0 +1 @@
+init_segtype
/cvs/lvm2/LVM2/lib/thin/Makefile.in,v  -->  standard output
revision 1.1
--- LVM2/lib/thin/Makefile.in
+++ -	2011-08-24 08:27:52.427431000 +0000
@@ -0,0 +1,25 @@
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
+SOURCES = thin.c
+
+LIB_SHARED = liblvm2thin.$(LIB_SUFFIX)
+LIB_VERSION = $(LIB_VERSION_LVM)
+
+include $(top_builddir)/make.tmpl
+
+install: install_lib_shared_plugin
/cvs/lvm2/LVM2/lib/thin/thin.c,v  -->  standard output
revision 1.1
--- LVM2/lib/thin/thin.c
+++ -	2011-08-24 08:27:52.517011000 +0000
@@ -0,0 +1,135 @@
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
+#include "toolcontext.h"
+#include "metadata.h"
+#include "segtype.h"
+#include "text_export.h"
+#include "text_import.h"
+#include "config.h"
+#include "activate.h"
+#include "str_list.h"
+
+#ifdef DMEVENTD
+#  include "sharedlib.h"
+#  include "libdevmapper-event.h"
+#endif
+
+/* Dm kernel module name for thin provisiong */
+#define THIN_MODULE "thin-pool"
+
+
+static const char *_thin_name(const struct lv_segment *seg)
+{
+	return seg->segtype->name;
+}
+
+static int _thin_text_import(struct lv_segment *seg, const struct config_node *sn,
+			struct dm_hash_table *pv_hash __attribute__((unused)))
+{
+	return 1;
+}
+
+static int _thin_text_export(const struct lv_segment *seg, struct formatter *f)
+{
+	return 1;
+}
+
+#ifdef DEVMAPPER_SUPPORT
+static int _thin_target_percent(void **target_state __attribute__((unused)),
+				percent_t *percent,
+				struct dm_pool *mem __attribute__((unused)),
+				struct cmd_context *cmd __attribute__((unused)),
+				struct lv_segment *seg __attribute__((unused)),
+				char *params, uint64_t *total_numerator,
+				uint64_t *total_denominator)
+{
+	return 1;
+}
+
+static int _thin_target_present(struct cmd_context *cmd,
+				const struct lv_segment *seg,
+				unsigned *attributes __attribute__((unused)))
+{
+	static int _checked = 0;
+	static int _present = 0;
+
+	if (!_checked) {
+		_present = target_present(cmd, "thin-pool", 1);
+		_checked = 1;
+	}
+
+	return _present;
+}
+
+#endif
+
+static int _thin_modules_needed(struct dm_pool *mem,
+				const struct lv_segment *seg __attribute__((unused)),
+				struct dm_list *modules)
+{
+	if (!str_list_add(mem, modules, THIN_MODULE)) {
+		log_error("thin string list allocation failed");
+		return 0;
+	}
+
+	return 1;
+}
+
+static void _thin_destroy(struct segment_type *segtype)
+{
+	dm_free(segtype);
+}
+
+static struct segtype_handler _thin_ops = {
+	.name = _thin_name,
+	.text_import = _thin_text_import,
+	.text_export = _thin_text_export,
+#ifdef DEVMAPPER_SUPPORT
+	.target_percent = _thin_target_percent,
+	.target_present = _thin_target_present,
+#endif
+	.modules_needed = _thin_modules_needed,
+	.destroy = _thin_destroy,
+};
+
+#ifdef THIN_INTERNAL
+struct segment_type *init_thin_segtype(struct cmd_context *cmd)
+#else				/* Shared */
+struct segment_type *init_segtype(struct cmd_context *cmd);
+struct segment_type *init_segtype(struct cmd_context *cmd)
+#endif
+{
+	struct segment_type *segtype = dm_zalloc(sizeof(*segtype));
+
+	if (!segtype)
+		return_NULL;
+
+	segtype->cmd = cmd;
+	segtype->ops = &_thin_ops;
+	segtype->name = "thin";
+	segtype->private = NULL;
+	segtype->flags = SEG_THIN;
+
+#ifdef DEVMAPPER_SUPPORT
+#  ifdef DMEVENTD
+	if (_get_thin_dso_path(cmd))
+		segtype->flags |= SEG_MONITORED;
+#  endif	/* DMEVENTD */
+#endif
+	log_very_verbose("Initialised segtype: %s", segtype->name);
+
+	return segtype;
+}


