From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 27 Jan 2014 22:21:41 +0000 (UTC)
Subject: master - cache: New 'cachepool' segment type
Message-ID: <20140127222141.9222061171@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=90bbed325544365efa177a9823019c44f5109dbb
Commit:        90bbed325544365efa177a9823019c44f5109dbb
Parent:        94377dfd5ee7bbbdeb8836eeeea2198bc32c07f5
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Jan 27 05:27:16 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Jan 27 05:27:16 2014 -0600

cache:  New 'cachepool' segment type

This patch adds the new cachepool segment type - the first of two
necessary to eventually create 'cache' logical volumes.  In addition
to the new segment type, updates to makefiles, configure files, the
lv_segment struct, and some necessary libdevmapper flags.

The cachepool is the LV and corresponding segment type that will hold
all information pertinent to the cache itself - it's size, cachemode,
cache policy, core arguments (like migration_threshold), etc.
---
 configure                           |   32 ++++-
 configure.in                        |   22 +++
 lib/Makefile.in                     |   11 +-
 lib/cache_segtype/.exported_symbols |    1 +
 lib/cache_segtype/Makefile.in       |   24 +++
 lib/cache_segtype/cache.c           |  316 +++++++++++++++++++++++++++++++++++
 lib/commands/toolcontext.c          |    9 +-
 lib/metadata/metadata-exported.h    |    7 +
 lib/metadata/segtype.h              |   10 +
 lib/misc/configure.h.in             |    3 +
 libdm/libdevmapper.h                |    4 +
 11 files changed, 435 insertions(+), 4 deletions(-)

diff --git a/configure b/configure
index a156460..20d99dd 100755
--- a/configure
+++ b/configure
@@ -606,6 +606,7 @@ kernelvsn
 missingkernel
 kerneldir
 interface
+CACHE
 CMIRRORD_PIDFILE
 CLVMD_PIDFILE
 LVMETAD_PIDFILE
@@ -839,6 +840,7 @@ with_thin
 with_thin_check
 with_thin_dump
 with_thin_repair
+with_cache
 enable_readline
 enable_realtime
 enable_ocf
@@ -1615,6 +1617,7 @@ Optional Packages:
   --with-mirrors=TYPE     mirror support: internal/shared/none
                           [[TYPE=internal]]
   --with-raid=TYPE        raid support: internal/shared/none [[TYPE=internal]]
+  --with-cache=TYPE       cache support: internal/shared/none [[TYPE=internal]]
   --with-replicators=TYPE replicator support: internal/shared/none
                           [[TYPE=none]]
   --with-thin=TYPE        thin provisioning support: internal/shared/none
@@ -7117,6 +7120,31 @@ $as_echo "#define RAID_INTERNAL 1" >>confdefs.h
 fi
 
 ################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include cache" >&5
+$as_echo_n "checking whether to include cache... " >&6; }
+
+# Check whether --with-cache was given.
+if test "${with_cache+set}" = set; then :
+  withval=$with_cache; CACHE=$withval
+else
+  CACHE=internal
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $CACHE" >&5
+$as_echo "$CACHE" >&6; }
+
+if [ "x$CACHE" != xnone -a "x$CACHE" != xinternal -a "x$CACHE" != xshared ];
+ then  as_fn_error $? "--with-cache parameter invalid
+" "$LINENO" 5
+fi;
+
+if test x$CACHE = xinternal; then
+
+$as_echo "#define CACHE_INTERNAL 1" >>confdefs.h
+
+fi
+
+################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to include replicators" >&5
 $as_echo_n "checking whether to include replicators... " >&6; }
 
@@ -10150,6 +10178,7 @@ fi
 if [ \( "x$LVM1" = xshared -o "x$POOL" = xshared -o "x$CLUSTER" = xshared \
       -o "x$SNAPSHOTS" = xshared -o "x$MIRRORS" = xshared \
       -o "x$RAID" = xshared \
+      -o "x$CACHE" = xshared \
       \) -a "x$STATIC_LINK" = xyes ];
  then  as_fn_error $? "Features cannot be 'shared' when building statically
 " "$LINENO" 5
@@ -11424,7 +11453,7 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile conf/Makefile conf/example.conf conf/default.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_
 init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.socket scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile conf/Makefile conf/example.conf conf/default.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/cache_segtype/Makefile lib/snapshot/Makefile lib/thin/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.s
 h scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.socket scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -12140,6 +12169,7 @@ do
     "lib/replicator/Makefile") CONFIG_FILES="$CONFIG_FILES lib/replicator/Makefile" ;;
     "lib/misc/lvm-version.h") CONFIG_FILES="$CONFIG_FILES lib/misc/lvm-version.h" ;;
     "lib/raid/Makefile") CONFIG_FILES="$CONFIG_FILES lib/raid/Makefile" ;;
+    "lib/cache_segtype/Makefile") CONFIG_FILES="$CONFIG_FILES lib/cache_segtype/Makefile" ;;
     "lib/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES lib/snapshot/Makefile" ;;
     "lib/thin/Makefile") CONFIG_FILES="$CONFIG_FILES lib/thin/Makefile" ;;
     "libdaemon/Makefile") CONFIG_FILES="$CONFIG_FILES libdaemon/Makefile" ;;
diff --git a/configure.in b/configure.in
index 3e0e508..7b56b13 100644
--- a/configure.in
+++ b/configure.in
@@ -476,6 +476,25 @@ AC_DEFINE_UNQUOTED([THIN_DUMP_CMD], ["$THIN_DUMP_CMD"],
 AC_DEFINE_UNQUOTED([THIN_REPAIR_CMD], ["$THIN_REPAIR_CMD"],
 		   [The path to 'thin_repair', if available.])
 
+################################################################################
+dnl -- cache inclusion type
+AC_MSG_CHECKING(whether to include cache)
+AC_ARG_WITH(cache,
+	    AC_HELP_STRING([--with-cache=TYPE],
+			   [cache support: internal/shared/none
+			    [[TYPE=internal]]]),
+	    CACHE=$withval, CACHE=internal)
+AC_MSG_RESULT($CACHE)
+
+if [[ "x$CACHE" != xnone -a "x$CACHE" != xinternal -a "x$CACHE" != xshared ]];
+ then  AC_MSG_ERROR(
+--with-cache parameter invalid
+)
+fi;
+
+if test x$CACHE = xinternal; then
+	AC_DEFINE([CACHE_INTERNAL], 1, [Define to 1 to include built-in support for cache.])
+fi
 
 ################################################################################
 dnl -- Disable readline
@@ -1241,6 +1260,7 @@ dnl -- Check for shared/static conflicts
 if [[ \( "x$LVM1" = xshared -o "x$POOL" = xshared -o "x$CLUSTER" = xshared \
       -o "x$SNAPSHOTS" = xshared -o "x$MIRRORS" = xshared \
       -o "x$RAID" = xshared \
+      -o "x$CACHE" = xshared \
       \) -a "x$STATIC_LINK" = xyes ]];
  then  AC_MSG_ERROR(
 Features cannot be 'shared' when building statically
@@ -1596,6 +1616,7 @@ AC_SUBST(BLKID_WIPING)
 AC_SUBST(BUILD_CMIRRORD)
 AC_SUBST(BUILD_DMEVENTD)
 AC_SUBST(BUILD_LVMETAD)
+AC_SUBST(CACHE)
 AC_SUBST(CFLAGS)
 AC_SUBST(CFLOW_CMD)
 AC_SUBST(CLDFLAGS)
@@ -1752,6 +1773,7 @@ lib/misc/lvm-version.h
 lib/raid/Makefile
 lib/snapshot/Makefile
 lib/thin/Makefile
+lib/cache_segtype/Makefile
 libdaemon/Makefile
 libdaemon/client/Makefile
 libdaemon/server/Makefile
diff --git a/lib/Makefile.in b/lib/Makefile.in
index c3ace5f..3808269 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -44,6 +44,10 @@ ifeq ("@THIN@", "shared")
   SUBDIRS += thin
 endif
 
+ifeq ("@CACHE@", "shared")
+  SUBDIRS += cache_segtype
+endif
+
 SOURCES =\
 	activate/activate.c \
 	cache/lvmcache.c \
@@ -165,6 +169,10 @@ ifeq ("@THIN@", "internal")
   SOURCES += thin/thin.c
 endif
 
+ifeq ("@CACHE@", "internal")
+  SOURCES += cache_segtype/cache.c
+endif
+
 ifeq ("@DEVMAPPER@", "yes")
   SOURCES +=\
 	activate/dev_manager.c \
@@ -199,6 +207,7 @@ ifeq ($(MAKECMDGOALS),distclean)
 	raid \
 	replicator \
 	thin \
+	cache_segtype \
 	locking
 endif
 
diff --git a/lib/cache_segtype/.exported_symbols b/lib/cache_segtype/.exported_symbols
new file mode 100644
index 0000000..95cb3ff
--- /dev/null
+++ b/lib/cache_segtype/.exported_symbols
@@ -0,0 +1 @@
+init_cache_segtypes
diff --git a/lib/cache_segtype/Makefile.in b/lib/cache_segtype/Makefile.in
new file mode 100644
index 0000000..32a1f2b
--- /dev/null
+++ b/lib/cache_segtype/Makefile.in
@@ -0,0 +1,24 @@
+# Copyright (C) 2013-2014 Red Hat, Inc. All rights reserved.
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
+SOURCES = cache.c
+
+LIB_SHARED = liblvm2cache.$(LIB_SUFFIX)
+LIB_VERSION = $(LIB_VERSION_LVM)
+
+include $(top_builddir)/make.tmpl
+
+install: install_lvm2_plugin
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
new file mode 100644
index 0000000..0c60b7e
--- /dev/null
+++ b/lib/cache_segtype/cache.c
@@ -0,0 +1,316 @@
+/*
+ * Copyright (C) 2013-2014 Red Hat, Inc. All rights reserved.
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
+#include "segtype.h"
+#include "display.h"
+#include "text_export.h"
+#include "text_import.h"
+#include "config.h"
+#include "str_list.h"
+#include "targets.h"
+#include "lvm-string.h"
+#include "activate.h"
+#include "metadata.h"
+#include "lv_alloc.h"
+#include "defaults.h"
+
+#define SEG_LOG_ERROR(t, p...) \
+        log_error(t " segment %s of logical volume %s.", ## p,	\
+                  dm_config_parent_name(sn), seg->lv->name), 0;
+
+
+static const char *_name(const struct lv_segment *seg)
+{
+	return seg->segtype->name;
+}
+
+static int _cache_pool_text_import(struct lv_segment *seg,
+				   const struct dm_config_node *sn,
+				   struct dm_hash_table *pv_hash __attribute__((unused)))
+{
+	uint32_t chunk_size;
+	struct logical_volume *data_lv, *meta_lv;
+	const char *str = NULL;
+	char *argv_str;
+	struct dm_pool *mem = seg->lv->vg->vgmem; //FIXME: what mempool should be used?
+
+	if (!dm_config_has_node(sn, "data"))
+		return SEG_LOG_ERROR("Cache data not specified in");
+	if (!(str = dm_config_find_str(sn, "data", NULL)))
+		return SEG_LOG_ERROR("Cache data must be a string in");
+	if (!(data_lv = find_lv(seg->lv->vg, str)))
+		return SEG_LOG_ERROR("Unknown logical volume %s specified for "
+			  "cache data in", str);
+
+	if (!dm_config_has_node(sn, "metadata"))
+		return SEG_LOG_ERROR("Cache metadata not specified in");
+	if (!(str = dm_config_find_str(sn, "metadata", NULL)))
+		return SEG_LOG_ERROR("Cache metadata must be a string in");
+	if (!(meta_lv = find_lv(seg->lv->vg, str)))
+		return SEG_LOG_ERROR("Unknown logical volume %s specified for "
+			  "cache metadata in", str);
+
+	if (!dm_config_get_uint32(sn, "chunk_size", &chunk_size))
+		return SEG_LOG_ERROR("Couldn't read cache chunk_size in");
+
+	/*
+	 * Read in features:
+	 *   cache_mode = {writethrough|writeback}
+	 *
+	 *   'cache_mode' does not have to be present.
+	 */
+	if (dm_config_has_node(sn, "cache_mode")) {
+		if (!(str = dm_config_find_str(sn, "cache_mode", NULL)))
+			return SEG_LOG_ERROR("cache_mode must be a string in");
+		if (!strcmp(str, "writethrough"))
+			seg->feature_flags |= DM_CACHE_FEATURE_WRITETHROUGH;
+		else if (!strcmp(str, "writeback"))
+			seg->feature_flags |= DM_CACHE_FEATURE_WRITEBACK;
+		else
+			return SEG_LOG_ERROR("Unknown cache_mode in");
+	}
+
+	/*
+	 * Read in core arguments (these are key/value pairs)
+	 *   core_argc = <# args>
+	 *   core_argv = "[<key> <value>]..."
+	 *
+	 *   'core_argc' does not have to be present.  If it is not present,
+	 *   any other core_* fields are ignored.  If it is present, then
+	 *   'core_argv' must be present - even if they are
+	 *   'core_argc = 0' and 'core_argv = ""'.
+	 */
+	if (dm_config_has_node(sn, "core_argc")) {
+		if (!dm_config_has_node(sn, "core_argv"))
+			return SEG_LOG_ERROR("not all core arguments defined in");
+
+		if (!dm_config_get_int(sn, "core_argc", &seg->core_argc))
+			return SEG_LOG_ERROR("Unable to read core_argc in");
+
+		str = dm_config_find_str(sn, "core_argv", NULL);
+		if ((str && !seg->core_argc) || (!str && seg->core_argc))
+			return SEG_LOG_ERROR("core_argc and core_argv do"
+					     " not match in");
+
+		if (!(seg->core_argv =
+		      dm_pool_alloc(mem, sizeof(char *) * seg->core_argc)))
+			return_0;
+		if (str &&
+		    (!(argv_str = dm_pool_strdup(mem, str)) ||
+		     (seg->core_argc != dm_split_words(argv_str, seg->core_argc,
+						       0, seg->core_argv))))
+			return SEG_LOG_ERROR("core_argc and core_argv do"
+					     " not match in");
+	}
+
+	/*
+	 * Read in policy:
+	 *   policy_name = "<policy_name>"
+	 *   policy_argc = <# args>
+	 *   policy_argv = "[<key> <value>]..."
+	 *
+	 *   'policy_name' does not have to be present.  If it is not present,
+	 *   any other policy_* fields are ignored.  If it is present, then
+	 *   the other policy_* fields must be present - even if they are
+	 *   'policy_argc = 0' and 'policy_argv = ""'.
+	 */
+	if (dm_config_has_node(sn, "policy_name")) {
+		if (!dm_config_has_node(sn, "policy_argc") ||
+		    !dm_config_has_node(sn, "policy_argv"))
+			return SEG_LOG_ERROR("not all policy arguments defined in");
+		if (!(str = dm_config_find_str(sn, "policy_name", NULL)))
+			return SEG_LOG_ERROR("policy_name must be a string in");
+		seg->policy_name = dm_pool_strdup(mem, str);
+
+		if (!dm_config_get_int(sn, "policy_argc", &seg->policy_argc))
+			return SEG_LOG_ERROR("Unable to read policy_argc in");
+
+		str = dm_config_find_str(sn, "policy_argv", NULL);
+		if ((str && !seg->policy_argc) || (!str && seg->policy_argc))
+			return SEG_LOG_ERROR("policy_argc and policy_argv do"
+					     " not match in");
+
+		if (!(seg->policy_argv =
+		      dm_pool_alloc(mem, sizeof(char *) * seg->policy_argc)))
+			return_0;
+		if (str &&
+		    (!(argv_str = dm_pool_strdup(mem, str)) ||
+		     (seg->policy_argc != dm_split_words(argv_str,
+							 seg->policy_argc,
+							 0, seg->policy_argv))))
+			return SEG_LOG_ERROR("policy_argc and policy_argv do"
+					     " not match in");
+	}
+
+	if (!attach_pool_data_lv(seg, data_lv))
+		return_0;
+	if (!attach_pool_metadata_lv(seg, meta_lv))
+		return_0;
+	seg->chunk_size = chunk_size;
+
+	return 1;
+}
+
+static int _cache_pool_text_import_area_count(const struct dm_config_node *sn,
+					      uint32_t *area_count)
+{
+	*area_count = 1;
+
+	return 1;
+}
+
+static int _cache_pool_text_export(const struct lv_segment *seg,
+				   struct formatter *f)
+{
+	int i;
+	char buf[256]; //FIXME: IS THERE AN 'outf' THAT DOESN'T DO NEWLINE?!?
+	uint32_t feature_flags = seg->feature_flags;
+
+	outf(f, "data = \"%s\"", seg_lv(seg, 0)->name);
+	outf(f, "metadata = \"%s\"", seg->metadata_lv->name);
+	outf(f, "chunk_size = %" PRIu32, seg->chunk_size);
+
+	if (feature_flags) {
+		if (feature_flags & DM_CACHE_FEATURE_WRITETHROUGH) {
+			outf(f, "cache_mode = \"writethrough\"");
+			feature_flags &= ~DM_CACHE_FEATURE_WRITETHROUGH;
+		} else if (feature_flags & DM_CACHE_FEATURE_WRITEBACK) {
+			outf(f, "cache_mode = \"writeback\"");
+			feature_flags &= ~DM_CACHE_FEATURE_WRITEBACK;
+		} else {
+			log_error(INTERNAL_ERROR "Unknown feature flags "
+				  "in cache_pool segment for %s", seg->lv->name);
+			return 0;
+		}
+	}
+
+	if (seg->core_argc) {
+		outf(f, "core_argc = %d", seg->core_argc);
+		outf(f, "core_argv = \"");
+		for (i = 0; i < seg->core_argc; i++)
+			outf(f, "%s%s", i ? " " : "", seg->core_argv[i]);
+		outf(f, "\"");
+	}
+
+	if (seg->policy_name) {
+		outf(f, "policy_name = \"%s\"", seg->policy_name);
+		outf(f, "policy_argc = %d", seg->policy_argc);
+		buf[0] = '\0';
+		for (i = 0; i < seg->policy_argc; i++)
+			sprintf(buf, "%s%s", i ? " " : "", seg->policy_argv[i]);
+		outf(f, "policy_argv = \"%s\"", buf);
+	}
+
+	return 1;
+}
+
+static int _cache_pool_add_target_line(struct dev_manager *dm,
+				       struct dm_pool *mem,
+				       struct cmd_context *cmd __attribute__((unused)),
+				       void **target_state __attribute__((unused)),
+				       struct lv_segment *seg,
+				       const struct lv_activate_opts *laopts __attribute__((unused)),
+				       struct dm_tree_node *node, uint64_t len,
+				       uint32_t *pvmove_mirror_count __attribute__((unused)))
+{
+	/*
+	 * This /could/ be directed at _cdata, but I prefer
+	 * not to give a user direct access to a sub-LV via
+	 * this cache_pool.
+	 */
+	return dm_tree_node_add_error_target(node, len);
+}
+
+static int _modules_needed(struct dm_pool *mem,
+			   const struct lv_segment *seg __attribute__((unused)),
+			   struct dm_list *modules)
+{
+	if (!str_list_add(mem, modules, "cache")) {
+		log_error("cache module string list allocation failed");
+		return 0;
+	}
+
+	return 1;
+}
+
+static void _destroy(struct segment_type *segtype)
+{
+	dm_free((void *) segtype);
+}
+
+#ifdef DEVMAPPER_SUPPORT
+static int _target_present(struct cmd_context *cmd,
+				const struct lv_segment *seg __attribute__((unused)),
+				unsigned *attributes __attribute__((unused)))
+{
+	static int _cache_checked = 0;
+	static int _cache_present = 0;
+
+	if (!_cache_checked)
+		_cache_present = target_present(cmd, "cache", 1);
+
+	_cache_checked = 1;
+
+	return _cache_present;
+}
+
+#endif /* DEVMAPPER_SUPPORT */
+
+static struct segtype_handler _cache_pool_ops = {
+	.name = _name,
+	.text_import = _cache_pool_text_import,
+	.text_import_area_count = _cache_pool_text_import_area_count,
+	.text_export = _cache_pool_text_export,
+	.add_target_line = _cache_pool_add_target_line,
+#ifdef DEVMAPPER_SUPPORT
+	.target_present = _target_present,
+#  ifdef DMEVENTD
+#  endif        /* DMEVENTD */
+#endif
+	.modules_needed = _modules_needed,
+	.destroy = _destroy,
+};
+
+#ifdef CACHE_INTERNAL /* Shared */
+int init_cache_segtypes(struct cmd_context *cmd,
+			struct segtype_library *seglib)
+#else
+int init_cache_segtypes(struct cmd_context *cmd,
+			struct segtype_library *seglib);
+int init_cache_segtypes(struct cmd_context *cmd,
+			struct segtype_library *seglib)
+#endif
+{
+	struct segment_type *segtype = dm_zalloc(sizeof(*segtype));
+
+	if (!segtype) {
+		log_error("Failed to allocate memory for cache_pool segtype");
+		return 0;
+	}
+	segtype->cmd = cmd;
+
+	segtype->name = "cache_pool";
+	segtype->flags = SEG_CACHE_POOL;
+	segtype->ops = &_cache_pool_ops;
+	segtype->private = NULL;
+
+	if (!lvm_register_segtype(seglib, segtype))
+		return_0;
+	log_very_verbose("Initialised segtype: %s", segtype->name);
+
+	return 1;
+}
+
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 9d6ef5e..a709284 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1,6 +1,6 @@
-		/*
+/*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -1181,6 +1181,11 @@ static int _init_segtypes(struct cmd_context *cmd)
 		return 0;
 #endif
 
+#ifdef CACHE_INTERNAL
+	if (!init_cache_segtypes(cmd, &seglib))
+		return 0;
+#endif
+
 #ifdef HAVE_LIBDL
 	/* Load any formats in shared libs unless static */
 	if (!is_static() &&
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 2f1f9ec..bdf5c9d 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -385,6 +385,13 @@ struct lv_segment {
 	struct logical_volume *pool_lv;		/* For thin */
 	uint32_t device_id;			/* For thin, 24bit */
 
+	uint32_t feature_flags;			/* For cache */
+	int core_argc;				/* For cache */
+	char **core_argv;			/* For cache */
+	char *policy_name;			/* For cache */
+	int policy_argc;			/* For cache */
+	char **policy_argv;			/* For cache */
+
 	struct logical_volume *replicator;/* For replicator-devs - link to replicator LV */
 	struct logical_volume *rlog_lv;	/* For replicators */
 	const char *rlog_type;		/* For replicators */
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 2c02d1b..75429b4 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -41,8 +41,12 @@ struct dev_manager;
 #define SEG_RAID		0x00000400U
 #define SEG_THIN_POOL		0x00000800U
 #define SEG_THIN_VOLUME		0x00001000U
+#define SEG_CACHE		0x00002000U
+#define SEG_CACHE_POOL		0x00004000U
 #define SEG_UNKNOWN		0x80000000U
 
+#define segtype_is_cache(segtype)	((segtype)->flags & SEG_CACHE ? 1 : 0)
+#define segtype_is_cache_pool(segtype)	((segtype)->flags & SEG_CACHE_POOL ? 1 : 0)
 #define segtype_is_mirrored(segtype)	((segtype)->flags & SEG_AREAS_MIRRORED ? 1 : 0)
 #define segtype_is_raid(segtype)	((segtype)->flags & SEG_RAID ? 1 : 0)
 #define segtype_is_striped(segtype)	((segtype)->flags & SEG_AREAS_STRIPED ? 1 : 0)
@@ -51,6 +55,8 @@ struct dev_manager;
 #define segtype_is_thin_volume(segtype)	((segtype)->flags & SEG_THIN_VOLUME ? 1 : 0)
 #define segtype_is_virtual(segtype)	((segtype)->flags & SEG_VIRTUAL ? 1 : 0)
 
+#define seg_is_cache(seg)	segtype_is_cache((seg)->segtype)
+#define seg_is_cache_pool(seg)	segtype_is_cache_pool((seg)->segtype)
 #define seg_is_linear(seg)	(seg_is_striped(seg) && ((seg)->area_count == 1))
 #define seg_is_mirrored(seg)	segtype_is_mirrored((seg)->segtype)
 #define seg_is_raid(seg)	segtype_is_raid((seg)->segtype)
@@ -147,6 +153,10 @@ int init_replicator_segtype(struct cmd_context *cmd, struct segtype_library *seg
 int init_thin_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
 #endif
 
+#ifdef CACHE_INTERNAL
+int init_cache_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
+#endif
+
 #ifdef SNAPSHOT_INTERNAL
 struct segment_type *init_snapshot_segtype(struct cmd_context *cmd);
 #endif
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 4e9ffd1..0acb9b7 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -558,6 +558,9 @@
 /* The path to 'thin_repair', if available. */
 #undef THIN_REPAIR_CMD
 
+/* Define to 1 to include built-in support for cache[pool] segment types. */
+#undef CACHE_INTERNAL
+
 /* Define to 1 if you can safely include both <sys/time.h> and <time.h>. */
 #undef TIME_WITH_SYS_TIME
 
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 3bf8bd6..3074500 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -712,6 +712,10 @@ int dm_tree_node_add_raid_target_with_params(struct dm_tree_node *node,
 					     uint64_t size,
 					     struct dm_tree_node_raid_params *p);
 
+/* Cache feature_flags */
+#define DM_CACHE_FEATURE_WRITEBACK    0x00000001
+#define DM_CACHE_FEATURE_WRITETHROUGH 0x00000002
+
 /*
  * Replicator operation mode
  * Note: API for Replicator is not yet stable


