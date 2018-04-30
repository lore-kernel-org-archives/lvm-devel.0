From: David Teigland <teigland@sourceware.org>
Date: Mon, 30 Apr 2018 17:59:43 -0400
Subject: master - Remove lvm1 and pool disk formats
Message-ID: <201804302159.w3ULxhBL027908@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c1cd18f21ef233fa19e948cf130e97c005a349ad
Commit:        c1cd18f21ef233fa19e948cf130e97c005a349ad
Parent:        029a76b4f830750cc312c062d77cdaa4d1a1bba9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 27 16:22:46 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 30 16:55:02 2018 -0500

Remove lvm1 and pool disk formats

There are likely more bits of code that can be removed,
e.g. lvm1/pool-specific bits of code that were identified
using FMT flags.

The vgconvert command can likely be reduced further.

The lvm1-specific config settings should probably have
some other fields set for proper deprecation.
---
 configure.ac                      |   58 ---
 daemons/clvmd/clvmd-command.c     |    1 -
 daemons/clvmd/lvm-functions.c     |   10 -
 daemons/clvmd/lvm-functions.h     |    1 -
 daemons/lvmetad/lvmetad-client.h  |    1 -
 daemons/lvmetad/lvmetad-core.c    |    9 +-
 lib/Makefile.in                   |   29 --
 lib/activate/activate.c           |   13 -
 lib/activate/activate.h           |    1 -
 lib/cache/lvmcache.c              |    4 -
 lib/cache/lvmetad.c               |   23 +-
 lib/commands/toolcontext.c        |   22 -
 lib/config/config_settings.h      |   20 +-
 lib/display/display.c             |    9 +-
 lib/format1/.exported_symbols     |    1 -
 lib/format1/Makefile.in           |   33 --
 lib/format1/disk-rep.c            |  761 -------------------------------------
 lib/format1/disk-rep.h            |  250 ------------
 lib/format1/format1.c             |  631 ------------------------------
 lib/format1/format1.h             |   29 --
 lib/format1/import-export.c       |  680 ---------------------------------
 lib/format1/import-extents.c      |  377 ------------------
 lib/format1/layout.c              |  172 ---------
 lib/format1/lvm1-label.c          |  129 -------
 lib/format1/lvm1-label.h          |   23 --
 lib/format1/vg_number.c           |   60 ---
 lib/format_pool/.exported_symbols |    1 -
 lib/format_pool/Makefile.in       |   30 --
 lib/format_pool/disk_rep.c        |  409 --------------------
 lib/format_pool/disk_rep.h        |  156 --------
 lib/format_pool/format_pool.c     |  338 ----------------
 lib/format_pool/format_pool.h     |   28 --
 lib/format_pool/import_export.c   |  285 --------------
 lib/format_pool/pool_label.c      |  104 -----
 lib/format_pool/pool_label.h      |   23 --
 lib/format_pool/sptype_names.h    |   42 --
 lib/format_text/export.c          |    2 -
 lib/format_text/format-text.c     |    4 +-
 lib/format_text/import_vsn1.c     |    9 +-
 lib/locking/locking.c             |   40 --
 lib/metadata/lv_manip.c           |   26 --
 lib/metadata/metadata-exported.h  |   10 +-
 lib/metadata/metadata.c           |   18 +-
 lib/metadata/segtype.h            |    2 +-
 lib/metadata/snapshot_manip.c     |   11 -
 lib/metadata/vg.c                 |   17 +-
 lib/metadata/vg.h                 |    1 -
 lib/report/report.c               |    4 +-
 lib/striped/striped.c             |    2 +-
 man/vgconvert.8_des               |    7 +-
 test/shell/format-lvm1.sh         |   38 --
 test/shell/lvm1-basic.sh          |   36 --
 test/shell/snapshot-lvm1.sh       |   35 --
 tools/args.h                      |    3 +-
 tools/lvconvert.c                 |    5 -
 tools/lvmcmdline.c                |   58 +---
 tools/pvscan.c                    |    5 +-
 tools/stub.h                      |    1 -
 tools/toollib.c                   |   29 +--
 tools/vals.h                      |    4 +-
 tools/vgchange.c                  |   10 -
 tools/vgconvert.c                 |   53 +--
 tools/vgscan.c                    |    4 +-
 63 files changed, 51 insertions(+), 5146 deletions(-)

diff --git a/configure.ac b/configure.ac
index 69b97e0..811357f 100644
--- a/configure.ac
+++ b/configure.ac
@@ -283,58 +283,6 @@ AC_MSG_RESULT($MANGLING)
 AC_DEFINE_UNQUOTED([DEFAULT_DM_NAME_MANGLING], $mangling, [Define default name mangling behaviour])
 
 ################################################################################
-dnl -- LVM1 tool fallback option
-AC_MSG_CHECKING(whether to enable lvm1 fallback)
-AC_ARG_ENABLE(lvm1_fallback,
-	      AC_HELP_STRING([--enable-lvm1_fallback],
-			     [use this to fall back and use LVM1 binaries if
-			      device-mapper is missing from the kernel]),
-	      LVM1_FALLBACK=$enableval, LVM1_FALLBACK=no)
-AC_MSG_RESULT($LVM1_FALLBACK)
-
-if test "$LVM1_FALLBACK" = yes; then
-	DEFAULT_FALLBACK_TO_LVM1=1
-	AC_DEFINE([LVM1_FALLBACK], 1, [Define to 1 if 'lvm' should fall back to using LVM1 binaries if device-mapper is missing from the kernel])
-else
-	DEFAULT_FALLBACK_TO_LVM1=0
-fi
-AC_DEFINE_UNQUOTED(DEFAULT_FALLBACK_TO_LVM1, [$DEFAULT_FALLBACK_TO_LVM1],
-		   [Fall back to LVM1 by default if device-mapper is missing from the kernel.])
-
-################################################################################
-dnl -- format1 inclusion type
-AC_MSG_CHECKING(whether to include support for lvm1 metadata)
-AC_ARG_WITH(lvm1,
-	    AC_HELP_STRING([--with-lvm1=TYPE],
-			   [LVM1 metadata support: internal/shared/none [internal]]),
-	    LVM1=$withval, LVM1=internal)
-
-AC_MSG_RESULT($LVM1)
-
-case "$LVM1" in
-  none|shared) ;;
-  internal) AC_DEFINE([LVM1_INTERNAL], 1,
-		      [Define to 1 to include built-in support for LVM1 metadata.]) ;;
-  *) AC_MSG_ERROR([--with-lvm1 parameter invalid]) ;;
-esac
-
-################################################################################
-dnl -- format_pool inclusion type
-AC_MSG_CHECKING(whether to include support for GFS pool metadata)
-AC_ARG_WITH(pool,
-	    AC_HELP_STRING([--with-pool=TYPE],
-			   [GFS pool read-only support: internal/shared/none [internal]]),
-	    POOL=$withval, POOL=internal)
-AC_MSG_RESULT($POOL)
-
-case "$POOL" in
-  none|shared) ;;
-  internal) AC_DEFINE([POOL_INTERNAL], 1,
-		      [Define to 1 to include built-in support for GFS pool metadata.]) ;;
-  *) AC_MSG_ERROR([--with-pool parameter invalid])
-esac
-
-################################################################################
 dnl -- cluster_locking inclusion type
 AC_MSG_CHECKING(whether to include support for cluster locking)
 AC_ARG_WITH(cluster,
@@ -2033,7 +1981,6 @@ AC_SUBST(DEFAULT_CACHE_SUBDIR)
 AC_SUBST(DEFAULT_DATA_ALIGNMENT)
 AC_SUBST(DEFAULT_DM_RUN_DIR)
 AC_SUBST(DEFAULT_LOCK_DIR)
-AC_SUBST(DEFAULT_FALLBACK_TO_LVM1)
 AC_SUBST(DEFAULT_MIRROR_SEGTYPE)
 AC_SUBST(DEFAULT_PID_DIR)
 AC_SUBST(DEFAULT_PROFILE_SUBDIR)
@@ -2064,8 +2011,6 @@ AC_SUBST(JOBS)
 AC_SUBST(LDDEPS)
 AC_SUBST(LIBS)
 AC_SUBST(LIB_SUFFIX)
-AC_SUBST(LVM1)
-AC_SUBST(LVM1_FALLBACK)
 AC_SUBST(LVM_VERSION)
 AC_SUBST(LVM_LIBAPI)
 AC_SUBST(LVM_MAJOR)
@@ -2082,7 +2027,6 @@ AC_SUBST(OCF)
 AC_SUBST(OCFDIR)
 AC_SUBST(ODIRECT)
 AC_SUBST(PKGCONFIG)
-AC_SUBST(POOL)
 AC_SUBST(M_LIBS)
 AC_SUBST(PTHREAD_LIBS)
 AC_SUBST(PYTHON2)
@@ -2186,8 +2130,6 @@ conf/command_profile_template.profile
 conf/metadata_profile_template.profile
 include/Makefile
 lib/Makefile
-lib/format1/Makefile
-lib/format_pool/Makefile
 lib/locking/Makefile
 include/lvm-version.h
 libdaemon/Makefile
diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index 2971ecb..ce7f500 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -108,7 +108,6 @@ int do_command(struct local_client *client, struct clvm_header *msg, int msglen,
 		lock_flags = args[1];
 		lockname = &args[2];
 		/* Check to see if the VG is in use by LVM1 */
-		status = do_check_lvm1(lockname);
 		do_lock_vg(lock_cmd, lock_flags, lockname);
 		break;
 
diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 7e7b992..3bb00d3 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -639,16 +639,6 @@ int post_lock_lv(unsigned char command, unsigned char lock_flags,
 	return 0;
 }
 
-/* Check if a VG is in use by LVM1 so we don't stomp on it */
-int do_check_lvm1(const char *vgname)
-{
-	int status;
-
-	status = check_lvm1_vg_inactive(cmd, vgname);
-
-	return status == 1 ? 0 : EBUSY;
-}
-
 int do_refresh_cache(void)
 {
 	DEBUGLOG("Refreshing context\n");
diff --git a/daemons/clvmd/lvm-functions.h b/daemons/clvmd/lvm-functions.h
index eac966f..6785997 100644
--- a/daemons/clvmd/lvm-functions.h
+++ b/daemons/clvmd/lvm-functions.h
@@ -25,7 +25,6 @@ extern int do_lock_lv(unsigned char lock_cmd, unsigned char lock_flags,
 extern const char *do_lock_query(char *resource);
 extern int post_lock_lv(unsigned char lock_cmd, unsigned char lock_flags,
 			char *resource);
-extern int do_check_lvm1(const char *vgname);
 extern int do_refresh_cache(void);
 extern int init_clvm(struct dm_hash_table *excl_uuid);
 extern void destroy_lvm(void);
diff --git a/daemons/lvmetad/lvmetad-client.h b/daemons/lvmetad/lvmetad-client.h
index a2adfe6..be2623a 100644
--- a/daemons/lvmetad/lvmetad-client.h
+++ b/daemons/lvmetad/lvmetad-client.h
@@ -22,7 +22,6 @@
 #define LVMETAD_TOKEN_UPDATE_IN_PROGRESS "update in progress"
 
 #define LVMETAD_DISABLE_REASON_DIRECT		"DIRECT"
-#define LVMETAD_DISABLE_REASON_LVM1		"LVM1"
 #define LVMETAD_DISABLE_REASON_DUPLICATES	"DUPLICATES"
 #define LVMETAD_DISABLE_REASON_VGRESTORE	"VGRESTORE"
 #define LVMETAD_DISABLE_REASON_REPAIR		"REPAIR"
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index f4f5f42..72473d7 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -200,12 +200,12 @@ struct vg_info {
 #define GLFL_INVALID                   0x00000001
 #define GLFL_DISABLE                   0x00000002
 #define GLFL_DISABLE_REASON_DIRECT     0x00000004
-#define GLFL_DISABLE_REASON_LVM1       0x00000008
+				    /* 0x00000008 */
 #define GLFL_DISABLE_REASON_DUPLICATES 0x00000010
 #define GLFL_DISABLE_REASON_VGRESTORE  0x00000020
 #define GLFL_DISABLE_REASON_REPAIR     0x00000040
 
-#define GLFL_DISABLE_REASON_ALL (GLFL_DISABLE_REASON_DIRECT | GLFL_DISABLE_REASON_REPAIR | GLFL_DISABLE_REASON_LVM1 | GLFL_DISABLE_REASON_DUPLICATES | GLFL_DISABLE_REASON_VGRESTORE)
+#define GLFL_DISABLE_REASON_ALL (GLFL_DISABLE_REASON_DIRECT | GLFL_DISABLE_REASON_REPAIR | GLFL_DISABLE_REASON_DUPLICATES | GLFL_DISABLE_REASON_VGRESTORE)
 
 #define VGFL_INVALID 0x00000001
 
@@ -2369,8 +2369,6 @@ static response set_global_info(lvmetad_state *s, request r)
 			reason_flags |= GLFL_DISABLE_REASON_DIRECT;
 		if (strstr(reason, LVMETAD_DISABLE_REASON_REPAIR))
 			reason_flags |= GLFL_DISABLE_REASON_REPAIR;
-		if (strstr(reason, LVMETAD_DISABLE_REASON_LVM1))
-			reason_flags |= GLFL_DISABLE_REASON_LVM1;
 		if (strstr(reason, LVMETAD_DISABLE_REASON_DUPLICATES))
 			reason_flags |= GLFL_DISABLE_REASON_DUPLICATES;
 		if (strstr(reason, LVMETAD_DISABLE_REASON_VGRESTORE))
@@ -2429,10 +2427,9 @@ static response get_global_info(lvmetad_state *s, request r)
 	pid = (int)daemon_request_int(r, "pid", 0);
 
 	if (s->flags & GLFL_DISABLE) {
-		snprintf(reason, REASON_BUF_SIZE, "%s%s%s%s%s",
+		snprintf(reason, REASON_BUF_SIZE, "%s%s%s%s",
 			 (s->flags & GLFL_DISABLE_REASON_DIRECT)     ? LVMETAD_DISABLE_REASON_DIRECT "," : "",
 			 (s->flags & GLFL_DISABLE_REASON_REPAIR)     ? LVMETAD_DISABLE_REASON_REPAIR "," : "",
-			 (s->flags & GLFL_DISABLE_REASON_LVM1)       ? LVMETAD_DISABLE_REASON_LVM1 "," : "",
 			 (s->flags & GLFL_DISABLE_REASON_DUPLICATES) ? LVMETAD_DISABLE_REASON_DUPLICATES "," : "",
 			 (s->flags & GLFL_DISABLE_REASON_VGRESTORE)  ? LVMETAD_DISABLE_REASON_VGRESTORE "," : "");
 	}
diff --git a/lib/Makefile.in b/lib/Makefile.in
index e532626..8b87662 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -16,14 +16,6 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-ifeq ("@LVM1@", "shared")
-  SUBDIRS = format1
-endif
-
-ifeq ("@POOL@", "shared")
-  SUBDIRS += format_pool
-endif
-
 ifeq ("@CLUSTER@", "shared")
   SUBDIRS += locking
 endif
@@ -112,25 +104,6 @@ SOURCES =\
 	uuid/uuid.c \
 	zero/zero.c
 
-ifeq ("@LVM1@", "internal")
-  SOURCES +=\
-	format1/disk-rep.c \
-	format1/format1.c \
-	format1/import-export.c \
-	format1/import-extents.c \
-	format1/layout.c \
-	format1/lvm1-label.c \
-	format1/vg_number.c
-endif
-
-ifeq ("@POOL@", "internal")
-  SOURCES +=\
-	format_pool/disk_rep.c \
-	format_pool/format_pool.c \
-	format_pool/import_export.c \
-	format_pool/pool_label.c
-endif
-
 ifeq ("@CLUSTER@", "internal")
   SOURCES += locking/cluster_locking.c
 endif
@@ -167,8 +140,6 @@ LIB_STATIC = $(LIB_NAME).a
 
 ifeq ($(MAKECMDGOALS),distclean)
   SUBDIRS =\
-	format1 \
-	format_pool \
 	notify \
 	locking
 endif
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index a7113f1..2d00dc6 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -37,19 +37,6 @@
 
 #define _skip(fmt, args...) log_very_verbose("Skipping: " fmt , ## args)
 
-int lvm1_present(struct cmd_context *cmd)
-{
-	static char path[PATH_MAX];
-
-	if (dm_snprintf(path, sizeof(path), "%s/lvm/global", cmd->proc_dir)
-	    < 0) {
-		log_error("LVM1 proc global snprintf failed");
-		return 0;
-	}
-
-	return (path_exists(path)) ? 1 : 0;
-}
-
 int list_segment_modules(struct dm_pool *mem, const struct lv_segment *seg,
 			 struct dm_list *modules)
 {
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 2fc74ce..d2c6db7 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -91,7 +91,6 @@ int activation(void);
 
 int driver_version(char *version, size_t size);
 int library_version(char *version, size_t size);
-int lvm1_present(struct cmd_context *cmd);
 
 int module_present(struct cmd_context *cmd, const char *target_name);
 int target_present_version(struct cmd_context *cmd, const char *target_name,
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index cb19030..8ba8b3c 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -22,8 +22,6 @@
 #include "memlock.h"
 #include "str_list.h"
 #include "format-text.h"
-#include "format_pool.h"
-#include "format1.h"
 #include "config.h"
 
 #include "lvmetad.h"
@@ -481,8 +479,6 @@ void lvmcache_drop_metadata(const char *vgname, int drop_precommitted)
 	/* For VG_ORPHANS, we need to invalidate all labels on orphan PVs. */
 	if (!strcmp(vgname, VG_ORPHANS)) {
 		_drop_metadata(FMT_TEXT_ORPHAN_VG_NAME, 0);
-		_drop_metadata(FMT_LVM1_ORPHAN_VG_NAME, 0);
-		_drop_metadata(FMT_POOL_ORPHAN_VG_NAME, 0);
 	} else
 		_drop_metadata(vgname, drop_precommitted);
 }
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index ed0bcde..f21829c 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -37,8 +37,6 @@ static const char *_lvmetad_socket = NULL;
 static struct cmd_context *_lvmetad_cmd = NULL;
 static int64_t _lvmetad_update_timeout;
 
-static int _found_lvm1_metadata = 0;
-
 static struct volume_group *_lvmetad_pvscan_vg(struct cmd_context *cmd, struct volume_group *vg, const char *vgid, struct format_type *fmt);
 
 static uint64_t _monotonic_seconds(void)
@@ -2279,18 +2277,6 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 	if (!baton.fid)
 		goto_bad;
 
-	if (fmt->features & FMT_OBSOLETE) {
-		fmt->ops->destroy_instance(baton.fid);
-		log_warn("WARNING: Disabling lvmetad cache which does not support obsolete (lvm1) metadata.");
-		lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_LVM1);
-		_found_lvm1_metadata = 1;
-		/*
-		 * return 1 (success) so that we'll continue to populate lvmetad
-		 * instead of leaving the update incomplete.
-		 */
-		return 1;
-	}
-
 	lvmcache_foreach_mda(info, _lvmetad_pvscan_single, &baton);
 
 	if (!baton.vg)
@@ -2452,11 +2438,9 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait)
 	}
 
 	/*
-	 * If lvmetad is disabled, and no lvm1 metadata was seen and no
-	 * duplicate PVs were seen, then re-enable lvmetad.
+	 * If lvmetad is disabled, and no duplicate PVs were seen, then re-enable lvmetad.
 	 */
-	if (lvmetad_is_disabled(cmd, &reason) &&
-	    !lvmcache_found_duplicate_pvs() && !_found_lvm1_metadata) {
+	if (lvmetad_is_disabled(cmd, &reason) && !lvmcache_found_duplicate_pvs()) {
 		log_debug_lvmetad("Enabling lvmetad which was previously disabled.");
 		lvmetad_clear_disabled(cmd);
 	}
@@ -3072,9 +3056,6 @@ int lvmetad_is_disabled(struct cmd_context *cmd, const char **reason)
 		} else if (strstr(reply_reason, LVMETAD_DISABLE_REASON_REPAIR)) {
 			*reason = "a repair command was run";
 
-		} else if (strstr(reply_reason, LVMETAD_DISABLE_REASON_LVM1)) {
-			*reason = "LVM1 metadata was found";
-
 		} else if (strstr(reply_reason, LVMETAD_DISABLE_REASON_DUPLICATES)) {
 			*reason = "duplicate PVs were found";
 
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index a54f4d7..64c9b1a 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -36,14 +36,6 @@
 #include "sharedlib.h"
 #endif
 
-#ifdef LVM1_INTERNAL
-#include "format1.h"
-#endif
-
-#ifdef POOL_INTERNAL
-#include "format_pool.h"
-#endif
-
 #include <locale.h>
 #include <sys/stat.h>
 #include <sys/syscall.h>
@@ -1341,20 +1333,6 @@ static int _init_formats(struct cmd_context *cmd)
 	const struct dm_config_node *cn;
 #endif
 
-#ifdef LVM1_INTERNAL
-	if (!(fmt = init_lvm1_format(cmd)))
-		return 0;
-	fmt->library = NULL;
-	dm_list_add(&cmd->formats, &fmt->list);
-#endif
-
-#ifdef POOL_INTERNAL
-	if (!(fmt = init_pool_format(cmd)))
-		return 0;
-	fmt->library = NULL;
-	dm_list_add(&cmd->formats, &fmt->list);
-#endif
-
 #ifdef HAVE_LIBDL
 	/* Load any formats in shared libs if not static */
 	if (!is_static() &&
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index b778f4c..d8db7df 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -767,26 +767,14 @@ cfg(global_activation_CFG, "activation", global_CFG_SECTION, 0, CFG_TYPE_BOOL, D
 	"is not present in the kernel, disabling this should suppress\n"
 	"the error messages.\n")
 
-cfg(global_fallback_to_lvm1_CFG, "fallback_to_lvm1", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_LVM1, vsn(1, 0, 18), "@DEFAULT_FALLBACK_TO_LVM1@", 0, NULL,
-	"Try running LVM1 tools if LVM cannot communicate with DM.\n"
-	"This option only applies to 2.4 kernels and is provided to help\n"
-	"switch between device-mapper kernels and LVM1 kernels. The LVM1\n"
-	"tools need to be installed with .lvm1 suffices, e.g. vgscan.lvm1.\n"
-	"They will stop working once the lvm2 on-disk metadata format is used.\n")
+cfg(global_fallback_to_lvm1_CFG, "fallback_to_lvm1", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, 0, vsn(1, 0, 18), NULL, 0, NULL,
+	"This setting setting no longer used.\n")
 
 cfg(global_format_CFG, "format", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_FORMAT, vsn(1, 0, 0), NULL, 0, NULL,
-	"The default metadata format that commands should use.\n"
-	"The -M 1|2 option overrides this setting.\n"
-	"#\n"
-	"Accepted values:\n"
-	"  lvm1\n"
-	"  lvm2\n"
-	"#\n")
+	"This setting is no longer used.\n")
 
 cfg_array(global_format_libraries_CFG, "format_libraries", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
-	"Shared libraries that process different metadata formats.\n"
-	"If support for LVM1 metadata was compiled as a shared library use\n"
-	"format_libraries = \"liblvm2format1.so\"\n")
+	"This setting is no longer used.")
 
 cfg_array(global_segment_libraries_CFG, "segment_libraries", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL, 0, NULL, NULL)
 
diff --git a/lib/display/display.c b/lib/display/display.c
index 9a928d9..9b4be88 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -705,13 +705,10 @@ void vgdisplay_full(const struct volume_group *vg)
 
 	log_print("--- Volume group ---");
 	log_print("VG Name               %s", vg->name);
-	log_print("System ID             %s", (vg->system_id && *vg->system_id) ? vg->system_id : vg->lvm1_system_id ? : "");
+	log_print("System ID             %s", (vg->system_id && *vg->system_id) ? vg->system_id : "");
 	log_print("Format                %s", vg->fid->fmt->name);
-	if (vg->fid->fmt->features & FMT_MDAS) {
-		log_print("Metadata Areas        %d",
-			  vg_mda_count(vg));
-		log_print("Metadata Sequence No  %d", vg->seqno);
-	}
+	log_print("Metadata Areas        %d", vg_mda_count(vg));
+	log_print("Metadata Sequence No  %d", vg->seqno);
 	access_str = vg->status & (LVM_READ | LVM_WRITE);
 	log_print("VG Access             %s%s%s%s",
 		  access_str == (LVM_READ | LVM_WRITE) ? "read/write" : "",
diff --git a/lib/format1/.exported_symbols b/lib/format1/.exported_symbols
deleted file mode 100644
index e9fac2e..0000000
--- a/lib/format1/.exported_symbols
+++ /dev/null
@@ -1 +0,0 @@
-init_format
diff --git a/lib/format1/Makefile.in b/lib/format1/Makefile.in
deleted file mode 100644
index 4a905c0..0000000
--- a/lib/format1/Makefile.in
+++ /dev/null
@@ -1,33 +0,0 @@
-#
-# Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
-#
-# This file is part of LVM2.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-srcdir = @srcdir@
-top_srcdir = @top_srcdir@
-top_builddir = @top_builddir@
-
-SOURCES =\
-	disk-rep.c \
-	format1.c \
-	import-export.c \
-	import-extents.c \
-	layout.c \
-	lvm1-label.c \
-	vg_number.c
-
-LIB_SHARED = liblvm2format1.$(LIB_SUFFIX)
-LIB_VERSION = $(LIB_VERSION_LVM)
-
-include $(top_builddir)/make.tmpl
-
-install: install_lvm2_plugin
diff --git a/lib/format1/disk-rep.c b/lib/format1/disk-rep.c
deleted file mode 100644
index 281adc1..0000000
--- a/lib/format1/disk-rep.c
+++ /dev/null
@@ -1,761 +0,0 @@
-/*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
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
-#include "lib.h"
-#include "disk-rep.h"
-#include "xlate.h"
-#include "lvmcache.h"
-#include "metadata-exported.h"
-
-#include <fcntl.h>
-
-#define xx16(v) disk->v = xlate16(disk->v)
-#define xx32(v) disk->v = xlate32(disk->v)
-#define xx64(v) disk->v = xlate64(disk->v)
-
-/*
- * Functions to perform the endian conversion
- * between disk and core.  The same code works
- * both ways of course.
- */
-static void _xlate_pvd(struct pv_disk *disk)
-{
-	xx16(version);
-
-	xx32(pv_on_disk.base);
-	xx32(pv_on_disk.size);
-	xx32(vg_on_disk.base);
-	xx32(vg_on_disk.size);
-	xx32(pv_uuidlist_on_disk.base);
-	xx32(pv_uuidlist_on_disk.size);
-	xx32(lv_on_disk.base);
-	xx32(lv_on_disk.size);
-	xx32(pe_on_disk.base);
-	xx32(pe_on_disk.size);
-
-	xx32(pv_major);
-	xx32(pv_number);
-	xx32(pv_status);
-	xx32(pv_allocatable);
-	xx32(pv_size);
-	xx32(lv_cur);
-	xx32(pe_size);
-	xx32(pe_total);
-	xx32(pe_allocated);
-	xx32(pe_start);
-}
-
-static void _xlate_lvd(struct lv_disk *disk)
-{
-	xx32(lv_access);
-	xx32(lv_status);
-	xx32(lv_open);
-	xx32(lv_dev);
-	xx32(lv_number);
-	xx32(lv_mirror_copies);
-	xx32(lv_recovery);
-	xx32(lv_schedule);
-	xx32(lv_size);
-	xx32(lv_snapshot_minor);
-	xx16(lv_chunk_size);
-	xx16(dummy);
-	xx32(lv_allocated_le);
-	xx32(lv_stripes);
-	xx32(lv_stripesize);
-	xx32(lv_badblock);
-	xx32(lv_allocation);
-	xx32(lv_io_timeout);
-	xx32(lv_read_ahead);
-}
-
-static void _xlate_vgd(struct vg_disk *disk)
-{
-	xx32(vg_number);
-	xx32(vg_access);
-	xx32(vg_status);
-	xx32(lv_max);
-	xx32(lv_cur);
-	xx32(lv_open);
-	xx32(pv_max);
-	xx32(pv_cur);
-	xx32(pv_act);
-	xx32(dummy);
-	xx32(vgda);
-	xx32(pe_size);
-	xx32(pe_total);
-	xx32(pe_allocated);
-	xx32(pvg_total);
-}
-
-static void _xlate_extents(struct pe_disk *extents, uint32_t count)
-{
-	unsigned i;
-
-	for (i = 0; i < count; i++) {
-		extents[i].lv_num = xlate16(extents[i].lv_num);
-		extents[i].le_num = xlate16(extents[i].le_num);
-	}
-}
-
-/*
- * Handle both minor metadata formats.
- */
-static int _munge_formats(struct pv_disk *pvd)
-{
-	uint32_t pe_start;
-	unsigned b, e;
-
-	switch (pvd->version) {
-	case 1:
-		pvd->pe_start = ((pvd->pe_on_disk.base +
-				  pvd->pe_on_disk.size) >> SECTOR_SHIFT);
-		break;
-
-	case 2:
-		pvd->version = 1;
-		pe_start = pvd->pe_start << SECTOR_SHIFT;
-		pvd->pe_on_disk.size = pe_start - pvd->pe_on_disk.base;
-		break;
-
-	default:
-		return 0;
-	}
-
-	/* UUID too long? */
-	if (pvd->pv_uuid[ID_LEN]) {
-		/* Retain ID_LEN chars from end */
-		for (e = ID_LEN; e < sizeof(pvd->pv_uuid); e++) {
-			if (!pvd->pv_uuid[e]) {
-				e--;
-				break;
-			}
-		}
-		for (b = 0; b < ID_LEN; b++) {
-			pvd->pv_uuid[b] = pvd->pv_uuid[++e - ID_LEN];
-			/* FIXME Remove all invalid chars */
-			if (pvd->pv_uuid[b] == '/')
-				pvd->pv_uuid[b] = '#';
-		}
-		memset(&pvd->pv_uuid[ID_LEN], 0, sizeof(pvd->pv_uuid) - ID_LEN);
-	}
-
-	/* If UUID is missing, create one */
-	if (pvd->pv_uuid[0] == '\0') {
-		uuid_from_num((char *)pvd->pv_uuid, pvd->pv_number);
-		pvd->pv_uuid[ID_LEN] = '\0';
-	}
-
-	return 1;
-}
-
-/*
- * If exported, remove "PV_EXP" from end of VG name
- */
-static void _munge_exported_vg(struct pv_disk *pvd)
-{
-	int l;
-	size_t s;
-
-	/* Return if PV not in a VG */
-	if ((!*pvd->vg_name))
-		return;
-	/* FIXME also check vgd->status & VG_EXPORTED? */
-
-	l = strlen((char *)pvd->vg_name);
-	s = sizeof(EXPORTED_TAG);
-	if (!strncmp((char *)pvd->vg_name + l - s + 1, EXPORTED_TAG, s)) {
-		pvd->vg_name[l - s + 1] = '\0';
-		pvd->pv_status |= VG_EXPORTED;
-	}
-}
-
-int munge_pvd(struct device *dev, struct pv_disk *pvd)
-{
-	_xlate_pvd(pvd);
-
-	if (pvd->id[0] != 'H' || pvd->id[1] != 'M') {
-		log_very_verbose("%s does not have a valid LVM1 PV identifier",
-				 dev_name(dev));
-		return 0;
-	}
-
-	if (!_munge_formats(pvd)) {
-		log_very_verbose("format1: Unknown metadata version %d "
-				 "found on %s", pvd->version, dev_name(dev));
-		return 0;
-	}
-
-	/* If VG is exported, set VG name back to the real name */
-	_munge_exported_vg(pvd);
-
-	return 1;
-}
-
-static int _read_pvd(struct device *dev, struct pv_disk *pvd)
-{
-	if (!dev_read(dev, UINT64_C(0), sizeof(*pvd), DEV_IO_FMT1, pvd)) {
-		log_very_verbose("Failed to read PV data from %s",
-				 dev_name(dev));
-		return 0;
-	}
-
-	return munge_pvd(dev, pvd);
-}
-
-static int _read_lvd(struct device *dev, uint64_t pos, struct lv_disk *disk)
-{
-	if (!dev_read(dev, pos, sizeof(*disk), DEV_IO_FMT1, disk))
-		return_0;
-
-	_xlate_lvd(disk);
-
-	return 1;
-}
-
-int read_vgd(struct device *dev, struct vg_disk *vgd, struct pv_disk *pvd)
-{
-	uint64_t pos = pvd->vg_on_disk.base;
-
-	if (!dev_read(dev, pos, sizeof(*vgd), DEV_IO_FMT1, vgd))
-		return_0;
-
-	_xlate_vgd(vgd);
-
-	if ((vgd->lv_max > MAX_LV) || (vgd->pv_max > MAX_PV))
-		return_0;
-		
-	/* If UUID is missing, create one */
-	if (vgd->vg_uuid[0] == '\0')
-		uuid_from_num((char *)vgd->vg_uuid, vgd->vg_number);
-
-	return 1;
-}
-
-static int _read_uuids(struct disk_list *data)
-{
-	unsigned num_read = 0;
-	struct uuid_list *ul;
-	char buffer[NAME_LEN] __attribute__((aligned(8)));
-	uint64_t pos = data->pvd.pv_uuidlist_on_disk.base;
-	uint64_t end = pos + data->pvd.pv_uuidlist_on_disk.size;
-
-	while (pos < end && num_read < data->vgd.pv_cur) {
-		if (!dev_read(data->dev, pos, sizeof(buffer), DEV_IO_FMT1, buffer))
-			return_0;
-
-		if (!(ul = dm_pool_alloc(data->mem, sizeof(*ul))))
-			return_0;
-
-		memcpy(ul->uuid, buffer, NAME_LEN);
-		ul->uuid[NAME_LEN - 1] = '\0';
-
-		dm_list_add(&data->uuids, &ul->list);
-
-		pos += NAME_LEN;
-		num_read++;
-	}
-
-	return 1;
-}
-
-static int _check_lvd(struct lv_disk *lvd)
-{
-	return !(lvd->lv_name[0] == '\0');
-}
-
-static int _read_lvs(struct disk_list *data)
-{
-	unsigned int i, lvs_read = 0;
-	uint64_t pos;
-	struct lvd_list *ll;
-	struct vg_disk *vgd = &data->vgd;
-
-	for (i = 0; (i < vgd->lv_max) && (lvs_read < vgd->lv_cur); i++) {
-		pos = data->pvd.lv_on_disk.base + (i * sizeof(struct lv_disk));
-		ll = dm_pool_alloc(data->mem, sizeof(*ll));
-
-		if (!ll)
-			return_0;
-
-		if (!_read_lvd(data->dev, pos, &ll->lvd))
-			return_0;
-
-		if (!_check_lvd(&ll->lvd))
-			continue;
-
-		lvs_read++;
-		dm_list_add(&data->lvds, &ll->list);
-	}
-
-	return 1;
-}
-
-static int _read_extents(struct disk_list *data)
-{
-	size_t len = sizeof(struct pe_disk) * data->pvd.pe_total;
-	struct pe_disk *extents = dm_pool_alloc(data->mem, len);
-	uint64_t pos = data->pvd.pe_on_disk.base;
-
-	if (!extents)
-		return_0;
-
-	if (!dev_read(data->dev, pos, len, DEV_IO_FMT1, extents))
-		return_0;
-
-	_xlate_extents(extents, data->pvd.pe_total);
-	data->extents = extents;
-
-	return 1;
-}
-
-static void __update_lvmcache(const struct format_type *fmt,
-			      struct disk_list *dl,
-			      struct device *dev, const char *vgid,
-			      unsigned exported)
-{
-	struct lvmcache_info *info;
-	const char *vgname = *((char *)dl->pvd.vg_name) ?
-			     (char *)dl->pvd.vg_name : fmt->orphan_vg_name;
-
-	if (!(info = lvmcache_add(fmt->labeller, (char *)dl->pvd.pv_uuid, dev,
-				  vgname, vgid, exported ? EXPORTED_VG : 0))) {
-		stack;
-		return;
-	}
-
-	lvmcache_set_device_size(info, ((uint64_t)xlate32(dl->pvd.pv_size)) << SECTOR_SHIFT);
-	lvmcache_del_mdas(info);
-}
-
-static struct disk_list *__read_disk(const struct format_type *fmt,
-				     struct device *dev, struct dm_pool *mem,
-				     const char *vg_name)
-{
-	struct disk_list *dl = dm_pool_zalloc(mem, sizeof(*dl));
-	const char *name = dev_name(dev);
-
-	if (!dl)
-		return_NULL;
-
-	dl->dev = dev;
-	dl->mem = mem;
-	dm_list_init(&dl->uuids);
-	dm_list_init(&dl->lvds);
-
-	if (!_read_pvd(dev, &dl->pvd))
-		goto_bad;
-
-	/*
-	 * is it an orphan ?
-	 */
-	if (!*dl->pvd.vg_name) {
-		log_very_verbose("%s is not a member of any format1 VG", name);
-
-		__update_lvmcache(fmt, dl, dev, fmt->orphan_vg_name, 0);
-		return (vg_name) ? NULL : dl;
-	}
-
-	if (!read_vgd(dl->dev, &dl->vgd, &dl->pvd)) {
-		log_error("Failed to read VG data from PV (%s)", name);
-		__update_lvmcache(fmt, dl, dev, fmt->orphan_vg_name, 0);
-		goto bad;
-	}
-
-	if (vg_name && strcmp(vg_name, (char *)dl->pvd.vg_name)) {
-		log_very_verbose("%s is not a member of the VG %s",
-				 name, vg_name);
-		__update_lvmcache(fmt, dl, dev, fmt->orphan_vg_name, 0);
-		goto bad;
-	}
-
-	__update_lvmcache(fmt, dl, dev, (char *)dl->vgd.vg_uuid,
-			  dl->vgd.vg_status & VG_EXPORTED);
-
-	if (!_read_uuids(dl)) {
-		log_error("Failed to read PV uuid list from %s", name);
-		goto bad;
-	}
-
-	if (!_read_lvs(dl)) {
-		log_error("Failed to read LV's from %s", name);
-		goto bad;
-	}
-
-	if (!_read_extents(dl)) {
-		log_error("Failed to read extents from %s", name);
-		goto bad;
-	}
-
-	log_very_verbose("Found %s in %sVG %s", name,
-			 (dl->vgd.vg_status & VG_EXPORTED) ? "exported " : "",
-			 dl->pvd.vg_name);
-
-	return dl;
-
-      bad:
-	dm_pool_free(dl->mem, dl);
-	return NULL;
-}
-
-struct disk_list *read_disk(const struct format_type *fmt, struct device *dev,
-			    struct dm_pool *mem, const char *vg_name)
-{
-	struct disk_list *dl;
-
-	if (!dev_open_readonly(dev))
-		return_NULL;
-
-	dl = __read_disk(fmt, dev, mem, vg_name);
-
-	if (!dev_close(dev))
-		stack;
-
-	return dl;
-}
-
-static void _add_pv_to_list(struct cmd_context *cmd, struct dm_list *head, struct disk_list *data)
-{
-	struct pv_disk *pvd;
-	struct disk_list *diskl;
-
-	dm_list_iterate_items(diskl, head) {
-		pvd = &diskl->pvd;
-		if (!strncmp((char *)data->pvd.pv_uuid, (char *)pvd->pv_uuid,
-			     sizeof(pvd->pv_uuid))) {
-			if (!dev_subsystem_part_major(cmd->dev_types, data->dev)) {
-				log_very_verbose("Ignoring duplicate PV %s on "
-						 "%s", pvd->pv_uuid,
-						 dev_name(data->dev));
-				return;
-			}
-			log_very_verbose("Duplicate PV %s - using %s %s",
-					 pvd->pv_uuid, dev_subsystem_name(cmd->dev_types, data->dev),
-					 dev_name(data->dev));
-			dm_list_del(&diskl->list);
-			break;
-		}
-	}
-	dm_list_add(head, &data->list);
-}
-
-struct _read_pvs_in_vg_baton {
-	const char *vg_name;
-	struct dm_list *head;
-	struct disk_list *data;
-	struct dm_pool *mem;
-	int empty;
-};
-
-static int _read_pv_in_vg(struct lvmcache_info *info, void *baton)
-{
-	struct _read_pvs_in_vg_baton *b = baton;
-
-	b->empty = 0;
-
-	if (!lvmcache_device(info) ||
-	    !(b->data = read_disk(lvmcache_fmt(info), lvmcache_device(info), b->mem, b->vg_name)))
-		return 0; /* stop here */
-
-	_add_pv_to_list(lvmcache_fmt(info)->cmd, b->head, b->data);
-	return 1;
-}
-
-/*
- * Build a list of pv_d's structures, allocated from mem.
- * We keep track of the first object allocated from the pool
- * so we can free off all the memory if something goes wrong.
- */
-int read_pvs_in_vg(const struct format_type *fmt, const char *vg_name,
-		   struct dev_filter *filter, struct dm_pool *mem,
-		   struct dm_list *head)
-{
-	struct dev_iter *iter;
-	struct device *dev;
-	struct lvmcache_vginfo *vginfo;
-	struct _read_pvs_in_vg_baton baton;
-
-	baton.head = head;
-	baton.empty = 1;
-	baton.data = NULL;
-	baton.mem = mem;
-	baton.vg_name = vg_name;
-
-	/* Fast path if we already saw this VG and cached the list of PVs */
-	if (vg_name && (vginfo = lvmcache_vginfo_from_vgname(vg_name, NULL))) {
-
-		lvmcache_foreach_pv(vginfo, _read_pv_in_vg, &baton);
-
-		if (!baton.empty) {
-			/* Did we find the whole VG? */
-			if (!vg_name || is_orphan_vg(vg_name) ||
-			    (baton.data && *baton.data->pvd.vg_name &&
-			     dm_list_size(head) == baton.data->vgd.pv_cur))
-				return 1;
-
-			/* Failed */
-			dm_list_init(head);
-			/* vgcache_del(vg_name); */
-		}
-	}
-
-	if (!(iter = dev_iter_create(filter, 1))) {
-		log_error("read_pvs_in_vg: dev_iter_create failed");
-		return 0;
-	}
-
-	/* Otherwise do a complete scan */
-	for (dev = dev_iter_get(iter); dev; dev = dev_iter_get(iter)) {
-		if ((baton.data = read_disk(fmt, dev, mem, vg_name))) {
-			_add_pv_to_list(fmt->cmd, head, baton.data);
-		}
-	}
-	dev_iter_destroy(iter);
-
-	if (dm_list_empty(head))
-		return 0;
-
-	return 1;
-}
-
-static int _write_vgd(struct disk_list *data)
-{
-	struct vg_disk *vgd = &data->vgd;
-	uint64_t pos = data->pvd.vg_on_disk.base;
-
-	log_debug_metadata("Writing %s VG metadata to %s at %" PRIu64 " len %" PRIsize_t,
-			   data->pvd.vg_name, dev_name(data->dev), pos, sizeof(*vgd));
-
-	_xlate_vgd(vgd);
-	if (!dev_write(data->dev, pos, sizeof(*vgd), DEV_IO_FMT1, vgd))
-		return_0;
-
-	_xlate_vgd(vgd);
-
-	return 1;
-}
-
-static int _write_uuids(struct disk_list *data)
-{
-	struct uuid_list *ul;
-	uint64_t pos = data->pvd.pv_uuidlist_on_disk.base;
-	uint64_t end = pos + data->pvd.pv_uuidlist_on_disk.size;
-
-	dm_list_iterate_items(ul, &data->uuids) {
-		if (pos >= end) {
-			log_error("Too many uuids to fit on %s",
-				  dev_name(data->dev));
-			return 0;
-		}
-
-		log_debug_metadata("Writing %s uuidlist to %s at %" PRIu64 " len %d",
-				   data->pvd.vg_name, dev_name(data->dev),
-				   pos, NAME_LEN);
-
-		if (!dev_write(data->dev, pos, NAME_LEN, DEV_IO_FMT1, ul->uuid))
-			return_0;
-
-		pos += NAME_LEN;
-	}
-
-	return 1;
-}
-
-static int _write_lvd(struct device *dev, uint64_t pos, struct lv_disk *disk)
-{
-	log_debug_metadata("Writing %s LV %s metadata to %s at %" PRIu64 " len %"
-			   PRIsize_t, disk->vg_name, disk->lv_name, dev_name(dev),
-			   pos, sizeof(*disk));
-
-	_xlate_lvd(disk);
-	if (!dev_write(dev, pos, sizeof(*disk), DEV_IO_FMT1, disk))
-		return_0;
-
-	_xlate_lvd(disk);
-
-	return 1;
-}
-
-static int _write_lvs(struct disk_list *data)
-{
-	struct lvd_list *ll;
-	uint64_t pos, offset;
-
-	pos = data->pvd.lv_on_disk.base;
-
-	if (!dev_set(data->dev, pos, data->pvd.lv_on_disk.size, DEV_IO_FMT1, 0)) {
-		log_error("Couldn't zero lv area on device '%s'",
-			  dev_name(data->dev));
-		return 0;
-	}
-
-	dm_list_iterate_items(ll, &data->lvds) {
-		offset = sizeof(struct lv_disk) * ll->lvd.lv_number;
-		if (offset + sizeof(struct lv_disk) > data->pvd.lv_on_disk.size) {
-			log_error("lv_number %d too large", ll->lvd.lv_number);
-			return 0;
-		}
-
-		if (!_write_lvd(data->dev, pos + offset, &ll->lvd))
-			return_0;
-	}
-
-	return 1;
-}
-
-static int _write_extents(struct disk_list *data)
-{
-	size_t len = sizeof(struct pe_disk) * data->pvd.pe_total;
-	struct pe_disk *extents = data->extents;
-	uint64_t pos = data->pvd.pe_on_disk.base;
-
-	log_debug_metadata("Writing %s extents metadata to %s at %" PRIu64 " len %"
-			   PRIsize_t, data->pvd.vg_name, dev_name(data->dev),
-			   pos, len);
-
-	_xlate_extents(extents, data->pvd.pe_total);
-	if (!dev_write(data->dev, pos, len, DEV_IO_FMT1, extents))
-		return_0;
-
-	_xlate_extents(extents, data->pvd.pe_total);
-
-	return 1;
-}
-
-static int _write_pvd(struct disk_list *data)
-{
-	char *buf;
-	uint64_t pos = data->pvd.pv_on_disk.base;
-	size_t size = data->pvd.pv_on_disk.size;
-
-	if (size < sizeof(struct pv_disk)) {
-		log_error("Invalid PV structure size.");
-		return 0;
-	}
-
-	/* Make sure that the gap between the PV structure and
-	   the next one is zeroed in order to make non LVM tools
-	   happy (idea from AED) */
-	buf = dm_zalloc(size);
-	if (!buf) {
-		log_error("Couldn't allocate temporary PV buffer.");
-		return 0;
-	}
-
-	memcpy(buf, &data->pvd, sizeof(struct pv_disk));
-
-	log_debug_metadata("Writing %s PV metadata to %s at %" PRIu64 " len %"
-			   PRIsize_t, data->pvd.vg_name, dev_name(data->dev),
-			   pos, size);
-
-	_xlate_pvd((struct pv_disk *) buf);
-	if (!dev_write(data->dev, pos, size, DEV_IO_FMT1, buf)) {
-		dm_free(buf);
-		return_0;
-	}
-
-	dm_free(buf);
-	return 1;
-}
-
-/*
- * assumes the device has been opened.
- */
-static int __write_all_pvd(const struct format_type *fmt __attribute__((unused)),
-			   struct disk_list *data, int write_vg_metadata)
-{
-	const char *pv_name = dev_name(data->dev);
-
-	if (!_write_pvd(data)) {
-		log_error("Failed to write PV structure onto %s", pv_name);
-		return 0;
-	}
-
-	/* vgcache_add(data->pvd.vg_name, data->vgd.vg_uuid, data->dev, fmt); */
-	/*
-	 * Stop here for orphan PVs or if VG metadata write not requested.
-	 */
-	if ((data->pvd.vg_name[0] == '\0') || !write_vg_metadata) {
-		/* if (!test_mode())
-		   vgcache_add(data->pvd.vg_name, NULL, data->dev, fmt); */
-		return 1;
-	}
-
-	/* if (!test_mode())
-	   vgcache_add(data->pvd.vg_name, data->vgd.vg_uuid, data->dev,
-	   fmt); */
-
-	if (!_write_vgd(data)) {
-		log_error("Failed to write VG data to %s", pv_name);
-		return 0;
-	}
-
-	if (!_write_uuids(data)) {
-		log_error("Failed to write PV uuid list to %s", pv_name);
-		return 0;
-	}
-
-	if (!_write_lvs(data)) {
-		log_error("Failed to write LV's to %s", pv_name);
-		return 0;
-	}
-
-	if (!_write_extents(data)) {
-		log_error("Failed to write extents to %s", pv_name);
-		return 0;
-	}
-
-	return 1;
-}
-
-/*
- * opens the device and hands to the above fn.
- */
-static int _write_all_pvd(const struct format_type *fmt, struct disk_list *data, int write_vg_metadata)
-{
-	int r;
-
-	if (!data->dev)
-		return_0;
-
-	if (!dev_open(data->dev))
-		return_0;
-
-	r = __write_all_pvd(fmt, data, write_vg_metadata);
-
-	if (!dev_close(data->dev))
-		stack;
-
-	return r;
-}
-
-/*
- * Writes all the given pv's to disk.  Does very
- * little sanity checking, so make sure correct
- * data is passed to here.
- */
-int write_disks(const struct format_type *fmt, struct dm_list *pvs, int write_vg_metadata)
-{
-	struct disk_list *dl;
-
-	dm_list_iterate_items(dl, pvs) {
-		if (!(_write_all_pvd(fmt, dl, write_vg_metadata)))
-			return_0;
-
-		log_very_verbose("Successfully wrote data to %s",
-				 dev_name(dl->dev));
-	}
-
-	return 1;
-}
diff --git a/lib/format1/disk-rep.h b/lib/format1/disk-rep.h
deleted file mode 100644
index 221ae8e..0000000
--- a/lib/format1/disk-rep.h
+++ /dev/null
@@ -1,250 +0,0 @@
-/*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
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
-#ifndef DISK_REP_FORMAT1_H
-#define DISK_REP_FORMAT1_H
-
-#include "metadata.h"
-#include "toolcontext.h"
-
-#define MAX_PV 256
-#define MAX_LV 256
-#define MAX_VG 99
-
-#define LVM_BLK_MAJOR 58
-
-#define MAX_PV_SIZE	((uint32_t) -1)	/* 2TB in sectors - 1 */
-#define PE_SIZE_PV_SIZE_REL 5	/* PV size must be at least 5 times PE size */
-#define	MAX_LE_TOTAL	65534	/* 2^16 - 2 */
-#define	MAX_PE_TOTAL	((uint32_t) -2)
-
-#define UNMAPPED_EXTENT 0
-
-/* volume group */
-#define	VG_ACTIVE            0x01	/* vg_status */
-#define	VG_EXPORTED          0x02	/*     "     */
-#define	VG_EXTENDABLE        0x04	/*     "     */
-
-#define	VG_READ              0x01	/* vg_access */
-#define	VG_WRITE             0x02	/*     "     */
-#define	VG_CLUSTERED         0x04	/*     "     */
-#define	VG_SHARED            0x08	/*     "     */
-
-/* logical volume */
-#define	LV_ACTIVE            0x01	/* lv_status */
-#define	LV_SPINDOWN          0x02	/*     "     */
-#define LV_PERSISTENT_MINOR  0x04	/*     "     */
-
-#define	LV_READ              0x01	/* lv_access */
-#define	LV_WRITE             0x02	/*     "     */
-#define	LV_SNAPSHOT          0x04	/*     "     */
-#define	LV_SNAPSHOT_ORG      0x08	/*     "     */
-
-#define	LV_BADBLOCK_ON       0x01	/* lv_badblock */
-
-#define	LV_STRICT            0x01	/* lv_allocation */
-#define	LV_CONTIGUOUS        0x02	/*       "       */
-
-/* physical volume */
-#define	PV_ACTIVE            0x01	/* pv_status */
-#define	PV_ALLOCATABLE       0x02	/* pv_allocatable */
-
-#define EXPORTED_TAG "PV_EXP"	/* Identifier for exported PV */
-#define IMPORTED_TAG "PV_IMP"	/* Identifier for imported PV */
-
-struct data_area {
-	uint32_t base;
-	uint32_t size;
-} __attribute__ ((packed));
-
-struct pv_disk {
-	int8_t id[2];
-	uint16_t version;	/* lvm version */
-	struct data_area pv_on_disk;
-	struct data_area vg_on_disk;
-	struct data_area pv_uuidlist_on_disk;
-	struct data_area lv_on_disk;
-	struct data_area pe_on_disk;
-	int8_t pv_uuid[NAME_LEN];
-	int8_t vg_name[NAME_LEN];
-	int8_t system_id[NAME_LEN];	/* for vgexport/vgimport */
-	uint32_t pv_major;
-	uint32_t pv_number;
-	uint32_t pv_status;
-	uint32_t pv_allocatable;
-	uint32_t pv_size;
-	uint32_t lv_cur;
-	uint32_t pe_size;
-	uint32_t pe_total;
-	uint32_t pe_allocated;
-
-	/* only present on version == 2 pv's */
-	uint32_t pe_start;
-} __attribute__ ((packed));
-
-struct lv_disk {
-	int8_t lv_name[NAME_LEN];
-	int8_t vg_name[NAME_LEN];
-	uint32_t lv_access;
-	uint32_t lv_status;
-	uint32_t lv_open;
-	uint32_t lv_dev;
-	uint32_t lv_number;
-	uint32_t lv_mirror_copies;	/* for future use */
-	uint32_t lv_recovery;	/*       "        */
-	uint32_t lv_schedule;	/*       "        */
-	uint32_t lv_size;
-	uint32_t lv_snapshot_minor;	/* minor number of original */
-	uint16_t lv_chunk_size;	/* chunk size of snapshot */
-	uint16_t dummy;
-	uint32_t lv_allocated_le;
-	uint32_t lv_stripes;
-	uint32_t lv_stripesize;
-	uint32_t lv_badblock;	/* for future use */
-	uint32_t lv_allocation;
-	uint32_t lv_io_timeout;	/* for future use */
-	uint32_t lv_read_ahead;
-} __attribute__ ((packed));
-
-struct vg_disk {
-	int8_t vg_uuid[ID_LEN];	/* volume group UUID */
-	int8_t vg_name_dummy[NAME_LEN - ID_LEN];	/* rest of v1 VG name */
-	uint32_t vg_number;	/* volume group number */
-	uint32_t vg_access;	/* read/write */
-	uint32_t vg_status;	/* active or not */
-	uint32_t lv_max;	/* maximum logical volumes */
-	uint32_t lv_cur;	/* current logical volumes */
-	uint32_t lv_open;	/* open logical volumes */
-	uint32_t pv_max;	/* maximum physical volumes */
-	uint32_t pv_cur;	/* current physical volumes FU */
-	uint32_t pv_act;	/* active physical volumes */
-	uint32_t dummy;
-	uint32_t vgda;		/* volume group descriptor arrays FU */
-	uint32_t pe_size;	/* physical extent size in sectors */
-	uint32_t pe_total;	/* total of physical extents */
-	uint32_t pe_allocated;	/* allocated physical extents */
-	uint32_t pvg_total;	/* physical volume groups FU */
-} __attribute__ ((packed));
-
-struct pe_disk {
-	uint16_t lv_num;
-	uint16_t le_num;
-} __attribute__ ((packed));
-
-struct uuid_list {
-	struct dm_list list;
-	char uuid[NAME_LEN] __attribute__((aligned(8)));
-};
-
-struct lvd_list {
-	struct dm_list list;
-	struct lv_disk lvd;
-};
-
-struct disk_list {
-	struct dm_list list;
-	struct dm_pool *mem;
-	struct device *dev;
-
-	struct pv_disk pvd __attribute__((aligned(8)));
-	struct vg_disk vgd __attribute__((aligned(8)));
-	struct dm_list uuids __attribute__((aligned(8)));
-	struct dm_list lvds __attribute__((aligned(8)));
-	struct pe_disk *extents __attribute__((aligned(8)));
-};
-
-/*
- * Layout constants.
- */
-#define METADATA_ALIGN 4096UL
-#define LVM1_PE_ALIGN (65536UL >> SECTOR_SHIFT)      /* PE alignment */
-
-#define	METADATA_BASE 0UL
-#define	PV_SIZE 1024UL
-#define	VG_SIZE 4096UL
-
-/*
- * Functions to calculate layout info.
- */
-int calculate_layout(struct disk_list *dl);
-int calculate_extent_count(struct physical_volume *pv, uint32_t extent_size,
-			   uint32_t max_extent_count, uint64_t pe_start);
-
-/*
- * Low level io routines which read/write
- * disk_lists.
- */
-
-struct disk_list *read_disk(const struct format_type *fmt, struct device *dev,
-			    struct dm_pool *mem, const char *vg_name);
-
-int read_pvs_in_vg(const struct format_type *fmt, const char *vg_name,
-		   struct dev_filter *filter,
-		   struct dm_pool *mem, struct dm_list *results);
-
-int write_disks(const struct format_type *fmt, struct dm_list *pvds,
-		int write_vg_metadata);
-
-/*
- * Functions to translate to between disk and in
- * core structures.
- */
-int import_pv(const struct format_type *fmt, struct dm_pool *mem,
-	      struct device *dev, struct volume_group *vg,
-	      struct physical_volume *pv, struct pv_disk *pvd,
-	      struct vg_disk *vgd);
-int export_pv(struct cmd_context *cmd, struct dm_pool *mem,
-	      struct volume_group *vg,
-	      struct pv_disk *pvd, struct physical_volume *pv);
-
-int import_vg(struct dm_pool *mem,
-	      struct volume_group *vg, struct disk_list *dl);
-int export_vg(struct vg_disk *vgd, struct volume_group *vg);
-
-int import_lv(struct cmd_context *cmd, struct dm_pool *mem,
-	      struct logical_volume *lv, struct lv_disk *lvd);
-
-int import_extents(struct cmd_context *cmd, struct volume_group *vg,
-		   struct dm_list *pvds);
-int export_extents(struct disk_list *dl, uint32_t lv_num,
-		   struct logical_volume *lv, struct physical_volume *pv);
-
-int import_pvs(const struct format_type *fmt, struct dm_pool *mem,
-	       struct volume_group *vg, struct dm_list *pvds);
-
-int import_lvs(struct dm_pool *mem, struct volume_group *vg, struct dm_list *pvds);
-int export_lvs(struct disk_list *dl, struct volume_group *vg,
-	       struct physical_volume *pv, const char *dev_dir);
-
-int import_snapshots(struct dm_pool *mem, struct volume_group *vg,
-		     struct dm_list *pvds);
-
-int export_uuids(struct disk_list *dl, struct volume_group *vg);
-
-void export_numbers(struct dm_list *pvds, struct volume_group *vg);
-
-void export_pv_act(struct dm_list *pvds);
-int munge_pvd(struct device *dev, struct pv_disk *pvd);
-int read_vgd(struct device *dev, struct vg_disk *vgd, struct pv_disk *pvd);
-
-/* blech */
-int get_free_vg_number(struct format_instance *fid, struct dev_filter *filter,
-		       const char *candidate_vg, int *result);
-int export_vg_number(struct format_instance *fid, struct dm_list *pvds,
-		     const char *vg_name, struct dev_filter *filter);
-
-int generate_lvm1_system_id(struct cmd_context *cmd, char *s, const char *prefix);
-
-#endif
diff --git a/lib/format1/format1.c b/lib/format1/format1.c
deleted file mode 100644
index b3569e0..0000000
--- a/lib/format1/format1.c
+++ /dev/null
@@ -1,631 +0,0 @@
-/*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
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
-#include "lib.h"
-#include "disk-rep.h"
-#include "limits.h"
-#include "display.h"
-#include "toolcontext.h"
-#include "lvm1-label.h"
-#include "format1.h"
-#include "segtype.h"
-#include "pv_alloc.h"
-
-/* VG consistency checks */
-static int _check_vgs(struct dm_list *pvs, struct volume_group *vg)
-{
-	struct dm_list *pvh, *t;
-	struct disk_list *dl = NULL;
-	struct disk_list *first = NULL;
-
-	uint32_t pv_count = 0;
-	uint32_t exported = 0;
-	int first_time = 1;
-
-	/*
-	 * If there are exported and unexported PVs, ignore exported ones.
-	 * This means an active VG won't be affected if disks are inserted
-	 * bearing an exported VG with the same name.
-	 */
-	dm_list_iterate_items(dl, pvs) {
-		if (first_time) {
-			exported = dl->pvd.pv_status & VG_EXPORTED;
-			first_time = 0;
-			continue;
-		}
-
-		if (exported != (dl->pvd.pv_status & VG_EXPORTED)) {
-			/* Remove exported PVs */
-			dm_list_iterate_safe(pvh, t, pvs) {
-				dl = dm_list_item(pvh, struct disk_list);
-				if (dl->pvd.pv_status & VG_EXPORTED)
-					dm_list_del(pvh);
-			}
-			break;
-		}
-	}
-
-	/* Remove any PVs with VG structs that differ from the first */
-	dm_list_iterate_safe(pvh, t, pvs) {
-		dl = dm_list_item(pvh, struct disk_list);
-
-		if (!first)
-			first = dl;
-
-		else if (memcmp(&first->vgd, &dl->vgd, sizeof(first->vgd))) {
-			log_error("VG data differs between PVs %s and %s",
-				  dev_name(first->dev), dev_name(dl->dev));
-			log_debug_metadata("VG data on %s: %s %s %" PRIu32 " %" PRIu32
-					   "  %" PRIu32 " %" PRIu32 " %" PRIu32 " %"
-					   PRIu32 " %" PRIu32 " %" PRIu32 " %" PRIu32
-					   " %" PRIu32 " %" PRIu32 " %" PRIu32 " %"
-					   PRIu32 " %" PRIu32 " %" PRIu32,
-					   dev_name(first->dev), first->vgd.vg_uuid,
-					   first->vgd.vg_name_dummy,
-					   first->vgd.vg_number, first->vgd.vg_access,
-					   first->vgd.vg_status, first->vgd.lv_max,
-					   first->vgd.lv_cur, first->vgd.lv_open,
-					   first->vgd.pv_max, first->vgd.pv_cur,
-					   first->vgd.pv_act, first->vgd.dummy,
-					   first->vgd.vgda, first->vgd.pe_size,
-					   first->vgd.pe_total, first->vgd.pe_allocated,
-					   first->vgd.pvg_total);
-			log_debug_metadata("VG data on %s: %s %s %" PRIu32 " %" PRIu32
-					   "  %" PRIu32 " %" PRIu32 " %" PRIu32 " %"
-					   PRIu32 " %" PRIu32 " %" PRIu32 " %" PRIu32
-					   " %" PRIu32 " %" PRIu32 " %" PRIu32 " %"
-					   PRIu32 " %" PRIu32 " %" PRIu32,
-					   dev_name(dl->dev), dl->vgd.vg_uuid,
-					   dl->vgd.vg_name_dummy, dl->vgd.vg_number,
-					   dl->vgd.vg_access, dl->vgd.vg_status,
-					   dl->vgd.lv_max, dl->vgd.lv_cur,
-					   dl->vgd.lv_open, dl->vgd.pv_max,
-					   dl->vgd.pv_cur, dl->vgd.pv_act, dl->vgd.dummy,
-					   dl->vgd.vgda, dl->vgd.pe_size,
-					   dl->vgd.pe_total, dl->vgd.pe_allocated,
-					   dl->vgd.pvg_total);
-			dm_list_del(pvh);
-			return 0;
-		}
-		pv_count++;
-	}
-
-	/* On entry to fn, list known to be non-empty */
-	if (pv_count != first->vgd.pv_cur) {
-		log_error("%d PV(s) found for VG %s: expected %d",
-			  pv_count, first->pvd.vg_name, first->vgd.pv_cur);
-		vg->status |= PARTIAL_VG;
-	}
-
-	return 1;
-}
-
-static int _fix_partial_vg(struct volume_group *vg, struct dm_list *pvs)
-{
-	uint32_t extent_count = 0;
-	struct disk_list *dl;
-	struct dm_list *pvh;
-	struct pv_list *pvl;
-	struct lv_list *ll;
-	struct lv_segment *seg;
-
-	/*
-	 * FIXME: code should remap missing segments to error segment.
-	 * Also current mapping code allocates 1 segment per missing extent.
-	 * For now bail out completely - allocated structures are not complete
-	 */
-	dm_list_iterate_items(ll, &vg->lvs)
-		dm_list_iterate_items(seg, &ll->lv->segments) {
-
-			/* area_count is always 1 here, s == 0 */
-			if (seg_type(seg, 0) != AREA_PV)
-				continue;
-
-			if (seg_pv(seg, 0))
-				continue;
-
-			log_error("Partial mode support for missing lvm1 PVs and "
-				  "partially available LVs is currently not implemented.");
-			return 0;
-	}
-
-	dm_list_iterate(pvh, pvs) {
-		dl = dm_list_item(pvh, struct disk_list);
-		extent_count += dl->pvd.pe_total;
-	}
-
-	/* FIXME: move this to one place to pv_manip */
-	if (!(pvl = dm_pool_zalloc(vg->vgmem, sizeof(*pvl))) ||
-	    !(pvl->pv = dm_pool_zalloc(vg->vgmem, sizeof(*pvl->pv))))
-		return_0;
-
-	/* Use vg uuid with replaced first chars to "missing" as missing PV UUID */
-	memcpy(&pvl->pv->id.uuid, vg->id.uuid, sizeof(pvl->pv->id.uuid));
-	memcpy(&pvl->pv->id.uuid, "missing", 7);
-
-	if (!(pvl->pv->vg_name = dm_pool_strdup(vg->vgmem, vg->name)))
-		goto_out;
-	memcpy(&pvl->pv->vgid, &vg->id, sizeof(vg->id));
-	pvl->pv->status |= MISSING_PV;
-	dm_list_init(&pvl->pv->tags);
-	dm_list_init(&pvl->pv->segments);
-
-	pvl->pv->pe_size = vg->extent_size;
-	pvl->pv->pe_count = vg->extent_count - extent_count;
-	if (!alloc_pv_segment_whole_pv(vg->vgmem, pvl->pv))
-		goto_out;
-
-	add_pvl_to_vgs(vg, pvl);
-	log_debug_metadata("%s: partial VG, allocated missing PV using %d extents.",
-			   vg->name, pvl->pv->pe_count);
-
-	return 1;
-out:
-	dm_pool_free(vg->vgmem, pvl);
-	return 0;
-}
-
-static struct volume_group *_format1_vg_read(struct format_instance *fid,
-				     const char *vg_name,
-				     struct metadata_area *mda __attribute__((unused)),
-				     struct cached_vg_fmtdata **vg_fmtdata __attribute__((unused)),
-				     unsigned *use_previous_vg __attribute__((unused)),
-				     int single_device __attribute__((unused)))
-{
-	struct volume_group *vg;
-	struct disk_list *dl;
-	DM_LIST_INIT(pvs);
-
-	/* Strip dev_dir if present */
-	if (vg_name)
-		vg_name = strip_dir(vg_name, fid->fmt->cmd->dev_dir);
-
-	if (!(vg = alloc_vg("format1_vg_read", fid->fmt->cmd, NULL)))
-		return_NULL;
-
-	if (!read_pvs_in_vg(fid->fmt, vg_name, fid->fmt->cmd->filter,
-			    vg->vgmem, &pvs))
-		goto_bad;
-
-	if (dm_list_empty(&pvs))
-		goto_bad;
-
-	if (!_check_vgs(&pvs, vg))
-		goto_bad;
-
-	dl = dm_list_item(pvs.n, struct disk_list);
-
-	if (!import_vg(vg->vgmem, vg, dl))
-		goto_bad;
-
-	if (!import_pvs(fid->fmt, vg->vgmem, vg, &pvs))
-		goto_bad;
-
-	if (!import_lvs(vg->vgmem, vg, &pvs))
-		goto_bad;
-
-	if (!import_extents(fid->fmt->cmd, vg, &pvs))
-		goto_bad;
-
-	/* FIXME: workaround - temporary assignment of fid */
-	vg->fid = fid;
-	if (!import_snapshots(vg->vgmem, vg, &pvs)) {
-		vg->fid = NULL;
-		goto_bad;
-	}
-	vg->fid = NULL;
-
-	/* Fix extents counts by adding missing PV if partial VG */
-	if ((vg->status & PARTIAL_VG) && !_fix_partial_vg(vg, &pvs))
-		goto_bad;
-
-	vg_set_fid(vg, fid);
-
-	return vg;
-
-bad:
-	release_vg(vg);
-
-	return NULL;
-}
-
-static struct disk_list *_flatten_pv(struct format_instance *fid,
-				     struct dm_pool *mem, struct volume_group *vg,
-				     struct physical_volume *pv,
-				     const char *dev_dir)
-{
-	struct disk_list *dl = dm_pool_alloc(mem, sizeof(*dl));
-
-	if (!dl)
-		return_NULL;
-
-	dl->mem = mem;
-	dl->dev = pv->dev;
-
-	dm_list_init(&dl->uuids);
-	dm_list_init(&dl->lvds);
-
-	if (!export_pv(fid->fmt->cmd, mem, vg, &dl->pvd, pv) ||
-	    !export_vg(&dl->vgd, vg) ||
-	    !export_uuids(dl, vg) ||
-	    !export_lvs(dl, vg, pv, dev_dir) || !calculate_layout(dl)) {
-		dm_pool_free(mem, dl);
-		return_NULL;
-	}
-
-	return dl;
-}
-
-static int _flatten_vg(struct format_instance *fid, struct dm_pool *mem,
-		       struct volume_group *vg,
-		       struct dm_list *pvds, const char *dev_dir,
-		       struct dev_filter *filter)
-{
-	struct pv_list *pvl;
-	struct disk_list *data;
-
-	dm_list_iterate_items(pvl, &vg->pvs) {
-		if (!(data = _flatten_pv(fid, mem, vg, pvl->pv, dev_dir)))
-			return_0;
-
-		dm_list_add(pvds, &data->list);
-	}
-
-	export_numbers(pvds, vg);
-	export_pv_act(pvds);
-
-	if (!export_vg_number(fid, pvds, vg->name, filter))
-		return_0;
-
-	return 1;
-}
-
-static int _format1_vg_write(struct format_instance *fid, struct volume_group *vg,
-		     struct metadata_area *mda __attribute__((unused)))
-{
-	struct dm_pool *mem = dm_pool_create("lvm1 vg_write", VG_MEMPOOL_CHUNK);
-	struct dm_list pvds;
-	int r = 0;
-
-	if (!mem)
-		return_0;
-
-	dm_list_init(&pvds);
-
-	r = (_flatten_vg(fid, mem, vg, &pvds, fid->fmt->cmd->dev_dir,
-			 fid->fmt->cmd->filter) &&
-	     write_disks(fid->fmt, &pvds, 1));
-
-	lvmcache_update_vg(vg, 0);
-	dm_pool_destroy(mem);
-	return r;
-}
-
-static int _format1_pv_read(const struct format_type *fmt, const char *pv_name,
-		    struct physical_volume *pv, int scan_label_only __attribute__((unused)))
-{
-	struct dm_pool *mem = dm_pool_create("lvm1 pv_read", 1024);
-	struct disk_list *dl;
-	struct device *dev;
-	int r = 0;
-
-	log_very_verbose("Reading physical volume data %s from disk", pv_name);
-
-	if (!mem)
-		return_0;
-
-	if (!(dev = dev_cache_get(pv_name, fmt->cmd->filter)))
-		goto_out;
-
-	if (!(dl = read_disk(fmt, dev, mem, NULL)))
-		goto_out;
-
-	if (!import_pv(fmt, fmt->cmd->mem, dl->dev, NULL, pv, &dl->pvd, &dl->vgd))
-		goto_out;
-
-	pv->fmt = fmt;
-
-	r = 1;
-
-      out:
-	dm_pool_destroy(mem);
-	return r;
-}
-
-static int _format1_pv_initialise(const struct format_type * fmt,
-				  struct pv_create_args *pva,
-				  struct physical_volume * pv)
-{
-	if (pv->size > MAX_PV_SIZE)
-		pv->size--;
-	if (pv->size > MAX_PV_SIZE) {
-		log_error("Physical volumes cannot be bigger than %s",
-			  display_size(fmt->cmd, (uint64_t) MAX_PV_SIZE));
-		return 0;
-	}
-
-	/* Nothing more to do if extent size isn't provided */
-	if (!pva->extent_size)
-		return 1;
-
-	/*
-	 * This works out pe_start and pe_count.
-	 */
-	if (!calculate_extent_count(pv, pva->extent_size, pva->extent_count, pva->pe_start))
-		return_0;
-
-	/* Retain existing extent locations exactly */
-	if (((pva->pe_start || pva->extent_count) && (pva->pe_start != pv->pe_start)) ||
-	    (pva->extent_count && (pva->extent_count != pv->pe_count))) {
-		log_error("Metadata would overwrite physical extents");
-		return 0;
-	}
-
-	return 1;
-}
-
-static int _format1_pv_setup(const struct format_type *fmt,
-			     struct physical_volume *pv,
-			     struct volume_group *vg)
-{
-	struct pv_create_args pva = { .id = {{0}},
-				      .idp = NULL,
-				      .ba_start = 0,
-				      .ba_size = 0,
-				      .pe_start = 0,
-				      .extent_count = 0,
-				      .extent_size = vg->extent_size};
-
-	return _format1_pv_initialise(fmt, &pva, pv);
-}
-
-static int _format1_lv_setup(struct format_instance *fid, struct logical_volume *lv)
-{
-	uint64_t max_size = UINT_MAX;
-
-	if (!*lv->lvid.s)
-		lvid_from_lvnum(&lv->lvid, &lv->vg->id, find_free_lvnum(lv));
-
-	if (lv->le_count > MAX_LE_TOTAL) {
-		log_error("logical volumes cannot contain more than "
-			  "%d extents.", MAX_LE_TOTAL);
-		return 0;
-	}
-	if (lv->size > max_size) {
-		log_error("logical volumes cannot be larger than %s",
-			  display_size(fid->fmt->cmd, max_size));
-		return 0;
-	}
-
-	return 1;
-}
-
-static int _format1_pv_write(const struct format_type *fmt, struct physical_volume *pv)
-{
-	struct dm_pool *mem;
-	struct disk_list *dl;
-	struct dm_list pvs;
-	struct lvmcache_info *info;
-	int pe_count, pe_size, pe_start;
-	int r = 1;
-
-	if (!(info = lvmcache_add(fmt->labeller, (char *) &pv->id, pv->dev,
-				  pv->vg_name, NULL, 0)))
-		return_0;
-
-	lvmcache_update_pv(info, pv, fmt);
-	lvmcache_del_mdas(info);
-	lvmcache_del_das(info);
-	lvmcache_del_bas(info);
-
-	dm_list_init(&pvs);
-
-	pe_count = pv->pe_count;
-	pe_size = pv->pe_size;
-	pe_start = pv->pe_start;
-
-	/* Ensure any residual PE structure is gone */
-	pv->pe_size = pv->pe_count = 0;
-	pv->pe_start = LVM1_PE_ALIGN;
-
-	if (!(mem = dm_pool_create("lvm1 pv_write", 1024)))
-		return_0;
-
-	if (!(dl = dm_pool_alloc(mem, sizeof(*dl))))
-		goto_bad;
-
-	dl->mem = mem;
-	dl->dev = pv->dev;
-	dm_list_init(&dl->uuids);
-	dm_list_init(&dl->lvds);
-
-	if (!export_pv(fmt->cmd, mem, NULL, &dl->pvd, pv))
-		goto_bad;
-
-	/* must be set to be able to zero gap after PV structure in
-	   dev_write in order to make other disk tools happy */
-	dl->pvd.pv_on_disk.base = METADATA_BASE;
-	dl->pvd.pv_on_disk.size = PV_SIZE;
-	dl->pvd.pe_on_disk.base = LVM1_PE_ALIGN << SECTOR_SHIFT;
-
-	dm_list_add(&pvs, &dl->list);
-	if (!write_disks(fmt, &pvs, 0))
-		goto_bad;
-
-	goto out;
-
-      bad:
-	r = 0;
-
-      out:
-	pv->pe_size = pe_size;
-	pv->pe_count = pe_count;
-	pv->pe_start = pe_start;
-
-	dm_pool_destroy(mem);
-	return r;
-}
-
-static int _format1_vg_setup(struct format_instance *fid, struct volume_group *vg)
-{
-	/* just check max_pv and max_lv */
-	if (!vg->max_lv || vg->max_lv >= MAX_LV)
-		vg->max_lv = MAX_LV - 1;
-
-	if (!vg->max_pv || vg->max_pv >= MAX_PV)
-		vg->max_pv = MAX_PV - 1;
-
-	if (!vg_check_new_extent_size(vg->fid->fmt, vg->extent_size))
-		return_0;
-
-        /* Generate lvm1_system_id if not yet set */
-        if (!*vg->lvm1_system_id &&
-            !generate_lvm1_system_id(vg->cmd, vg->lvm1_system_id, ""))
-		return_0;
-
-	return 1;
-}
-
-static int _format1_segtype_supported(struct format_instance *fid __attribute__((unused)),
-				      const struct segment_type *segtype)
-{
-	if (!(segtype->flags & SEG_FORMAT1_SUPPORT))
-		return_0;
-
-	return 1;
-}
-
-static struct metadata_area_ops _metadata_format1_ops = {
-	.vg_read = _format1_vg_read,
-	.vg_write = _format1_vg_write,
-};
-
-static struct format_instance *_format1_create_instance(const struct format_type *fmt,
-							const struct format_instance_ctx *fic)
-{
-	struct format_instance *fid;
-	struct metadata_area *mda;
-
-	if (!(fid = alloc_fid(fmt, fic)))
-		return_NULL;
-
-	/* Define a NULL metadata area */
-	if (!(mda = dm_pool_zalloc(fid->mem, sizeof(*mda)))) {
-		log_error("Unable to allocate metadata area structure "
-			  "for lvm1 format");
-		goto bad;
-	}
-
-	mda->ops = &_metadata_format1_ops;
-	mda->metadata_locn = NULL;
-	mda->status = 0;
-	dm_list_add(&fid->metadata_areas_in_use, &mda->list);
-
-	return fid;
-
-bad:
-	dm_pool_destroy(fid->mem);
-	return NULL;
-}
-
-static void _format1_destroy_instance(struct format_instance *fid)
-{
-	if (--fid->ref_count <= 1)
-		dm_pool_destroy(fid->mem);
-}
-
-static void _format1_destroy(struct format_type *fmt)
-{
-	if (fmt->orphan_vg)
-		free_orphan_vg(fmt->orphan_vg);
-
-	dm_free(fmt);
-}
-
-static struct format_handler _format1_ops = {
-	.pv_read = _format1_pv_read,
-	.pv_initialise = _format1_pv_initialise,
-	.pv_setup = _format1_pv_setup,
-	.pv_write = _format1_pv_write,
-	.lv_setup = _format1_lv_setup,
-	.vg_setup = _format1_vg_setup,
-	.segtype_supported = _format1_segtype_supported,
-	.create_instance = _format1_create_instance,
-	.destroy_instance = _format1_destroy_instance,
-	.destroy = _format1_destroy,
-};
-
-#ifdef LVM1_INTERNAL
-struct format_type *init_lvm1_format(struct cmd_context *cmd)
-#else				/* Shared */
-struct format_type *init_format(struct cmd_context *cmd);
-struct format_type *init_format(struct cmd_context *cmd)
-#endif
-{
-	struct format_type *fmt = dm_malloc(sizeof(*fmt));
-	struct format_instance_ctx fic;
-	struct format_instance *fid;
-
-	if (!fmt) {
-		log_error("Failed to allocate format1 format type structure.");
-		return NULL;
-	}
-
-	fmt->cmd = cmd;
-	fmt->ops = &_format1_ops;
-	fmt->name = FMT_LVM1_NAME;
-	fmt->alias = NULL;
-	fmt->orphan_vg_name = FMT_LVM1_ORPHAN_VG_NAME;
-	fmt->features = FMT_RESTRICTED_LVIDS | FMT_ORPHAN_ALLOCATABLE |
-			FMT_RESTRICTED_READAHEAD | FMT_OBSOLETE |
-			FMT_SYSTEMID_ON_PVS;
-	fmt->private = NULL;
-
-	dm_list_init(&fmt->mda_ops);
-
-	if (!(fmt->labeller = lvm1_labeller_create(fmt))) {
-		log_error("Couldn't create lvm1 label handler.");
-		dm_free(fmt);
-		return NULL;
-	}
-
-	if (!(label_register_handler(fmt->labeller))) {
-		log_error("Couldn't register lvm1 label handler.");
-		fmt->labeller->ops->destroy(fmt->labeller);
-		dm_free(fmt);
-		return NULL;
-	}
-
-	if (!(fmt->orphan_vg = alloc_vg("format1_orphan", cmd, fmt->orphan_vg_name))) {
-		log_error("Couldn't create lvm1 orphan VG.");
-		dm_free(fmt);
-		return NULL;
-	}
-
-	fic.type = FMT_INSTANCE_AUX_MDAS;
-	fic.context.vg_ref.vg_name = fmt->orphan_vg_name;
-	fic.context.vg_ref.vg_id = NULL;
-
-	if (!(fid = _format1_create_instance(fmt, &fic))) {
-		_format1_destroy(fmt);
-		return_NULL;
-	}
-
-	vg_set_fid(fmt->orphan_vg, fid);
-
-	log_very_verbose("Initialised format: %s", fmt->name);
-
-	return fmt;
-}
diff --git a/lib/format1/format1.h b/lib/format1/format1.h
deleted file mode 100644
index 42ddc66..0000000
--- a/lib/format1/format1.h
+++ /dev/null
@@ -1,29 +0,0 @@
-/*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
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
-#ifndef _LVM_FORMAT1_H
-#define _LVM_FORMAT1_H
-
-#include "metadata.h"
-#include "lvmcache.h"
-
-#define FMT_LVM1_NAME "lvm1"
-#define FMT_LVM1_ORPHAN_VG_NAME ORPHAN_VG_NAME(FMT_LVM1_NAME)
-
-#ifdef LVM1_INTERNAL
-struct format_type *init_lvm1_format(struct cmd_context *cmd);
-#endif
-
-#endif
diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
deleted file mode 100644
index c29527b..0000000
--- a/lib/format1/import-export.c
+++ /dev/null
@@ -1,680 +0,0 @@
-/*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
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
-/*
- * Translates between disk and in-core formats.
- */
-
-#include "lib.h"
-#include "disk-rep.h"
-#include "lvm-string.h"
-#include "toolcontext.h"
-#include "segtype.h"
-#include "pv_alloc.h"
-#include "display.h"
-#include "metadata.h"
-
-#include <time.h>
-
-static int _check_vg_name(const char *name)
-{
-	return strlen(name) < NAME_LEN;
-}
-
-/*
- * Extracts the last part of a path.
- */
-static char *_create_lv_name(struct dm_pool *mem, const char *full_name)
-{
-	const char *ptr = strrchr(full_name, '/');
-
-	if (!ptr)
-		ptr = full_name;
-	else
-		ptr++;
-
-	return dm_pool_strdup(mem, ptr);
-}
-
-int import_pv(const struct format_type *fmt, struct dm_pool *mem,
-	      struct device *dev, struct volume_group *vg,
-	      struct physical_volume *pv, struct pv_disk *pvd,
-	      struct vg_disk *vgd)
-{
-	uint64_t size;
-
-	memset(pv, 0, sizeof(*pv));
-	memcpy(&pv->id, pvd->pv_uuid, ID_LEN);
-
-	pv->dev = dev;
-	if (!*pvd->vg_name)
-		pv->vg_name = fmt->orphan_vg_name;
-	else if (!(pv->vg_name = dm_pool_strdup(mem, (char *)pvd->vg_name))) {
-		log_error("Volume Group name allocation failed.");
-		return 0;
-	}
-
-	memcpy(&pv->vgid, vgd->vg_uuid, sizeof(vg->id));
-
-	/* Store system_id from first PV if PV belongs to a VG */
-	if (vg && !*vg->lvm1_system_id)
-		strncpy(vg->lvm1_system_id, (char *)pvd->system_id, NAME_LEN);
-
-	if (vg &&
-	    strncmp(vg->lvm1_system_id, (char *)pvd->system_id, sizeof(pvd->system_id)))
-		    log_very_verbose("System ID %s on %s differs from %s for "
-				     "volume group", pvd->system_id,
-				     pv_dev_name(pv), vg->lvm1_system_id);
-
-	/*
-	 * If exported, we still need to flag in pv->status too because
-	 * we don't always have a struct volume_group when we need this.
-	 */
-	if (pvd->pv_status & VG_EXPORTED)
-		pv->status |= EXPORTED_VG;
-
-	if (pvd->pv_allocatable)
-		pv->status |= ALLOCATABLE_PV;
-
-	pv->size = pvd->pv_size;
-	pv->pe_size = pvd->pe_size;
-	pv->pe_start = pvd->pe_start;
-	pv->pe_count = pvd->pe_total;
-	pv->pe_alloc_count = 0;
-	pv->pe_align = 0;
-        pv->is_labelled = 0; /* format1 PVs have no label */
-        pv->label_sector = 0;
-
-	/* Fix up pv size if missing or impossibly large */
-	if (!pv->size || pv->size > (1ULL << 62)) {
-		if (!dev_get_size(dev, &pv->size)) {
-			log_error("%s: Couldn't get size.", pv_dev_name(pv));
-			return 0;
-		}
-		log_verbose("Fixing up missing format1 size (%s) "
-			    "for PV %s", display_size(fmt->cmd, pv->size),
-			    pv_dev_name(pv));
-		if (vg) {
-			size = pv->pe_count * (uint64_t) vg->extent_size +
-			       pv->pe_start;
-			if (size > pv->size)
-				log_warn("WARNING: Physical Volume %s is too "
-					 "large for underlying device",
-					 pv_dev_name(pv));
-		}
-	}
-
-	dm_list_init(&pv->tags);
-	dm_list_init(&pv->segments);
-
-	if (!alloc_pv_segment_whole_pv(mem, pv))
-		return_0;
-
-	return 1;
-}
-
-int generate_lvm1_system_id(struct cmd_context *cmd, char *s, const char *prefix)
-{
-
-	if (dm_snprintf(s, NAME_LEN, "%s%s" FMTu64,
-			prefix, cmd->hostname, (uint64_t)time(NULL)) < 0) {
-		log_error("Generated LVM1 format system_id too long");
-		return 0;
-	}
-
-	return 1;
-}
-
-int export_pv(struct cmd_context *cmd, struct dm_pool *mem __attribute__((unused)),
-	      struct volume_group *vg,
-	      struct pv_disk *pvd, struct physical_volume *pv)
-{
-	memset(pvd, 0, sizeof(*pvd));
-
-	pvd->id[0] = 'H';
-	pvd->id[1] = 'M';
-	pvd->version = 1;
-
-	memcpy(pvd->pv_uuid, pv->id.uuid, ID_LEN);
-
-	if (pv->vg_name && !is_orphan(pv) && !(pv->status & UNLABELLED_PV)) {
-		if (!_check_vg_name(pv->vg_name))
-			return_0;
-		strncpy((char *)pvd->vg_name, pv->vg_name, sizeof(pvd->vg_name));
-	}
-
-	/* Preserve existing system_id if it exists */
-	if (vg && vg->lvm1_system_id && *vg->lvm1_system_id)
-		strncpy((char *)pvd->system_id, vg->lvm1_system_id, sizeof(pvd->system_id));
-	else if (vg && vg->system_id && *vg->system_id)
-		strncpy((char *)pvd->system_id, vg->system_id, sizeof(pvd->system_id));
-
-	/* Is VG already exported or being exported? */
-	if (vg && vg_is_exported(vg)) {
-		/* Does system_id need setting? */
-		if (!vg->lvm1_system_id || !*vg->lvm1_system_id ||
-		    strncmp(vg->lvm1_system_id, EXPORTED_TAG,
-			    sizeof(EXPORTED_TAG) - 1)) {
-			if (!generate_lvm1_system_id(cmd, (char *)pvd->system_id, EXPORTED_TAG))
-				return_0;
-		}
-		if (strlen((char *)pvd->vg_name) + sizeof(EXPORTED_TAG) >
-		    sizeof(pvd->vg_name)) {
-			log_error("Volume group name %s too long to export",
-				  pvd->vg_name);
-			return 0;
-		}
-		strcat((char *)pvd->vg_name, EXPORTED_TAG);
-	}
-
-	/* Is VG being imported? */
-	if (vg && !vg_is_exported(vg) && vg->lvm1_system_id && *vg->lvm1_system_id &&
-	    !strncmp(vg->lvm1_system_id, EXPORTED_TAG, sizeof(EXPORTED_TAG) - 1)) {
-		if (!generate_lvm1_system_id(cmd, (char *)pvd->system_id, IMPORTED_TAG))
-			return_0;
-	}
-
-	/* Generate system_id if PV is in VG */
-	if (!pvd->system_id[0])
-		if (!generate_lvm1_system_id(cmd, (char *)pvd->system_id, ""))
-			return_0;
-
-	/* Update internal system_id if we changed it */
-	if (vg && vg->lvm1_system_id &&
-	    (!*vg->lvm1_system_id ||
-	     strncmp(vg->lvm1_system_id, (char *)pvd->system_id, sizeof(pvd->system_id))))
-		    strncpy(vg->lvm1_system_id, (char *)pvd->system_id, NAME_LEN);
-
-	//pvd->pv_major = MAJOR(pv->dev);
-
-	if (pv->status & ALLOCATABLE_PV)
-		pvd->pv_allocatable = PV_ALLOCATABLE;
-
-	pvd->pv_size = pv->size;
-	pvd->lv_cur = 0;	/* this is set when exporting the lv list */
-	if (vg)
-		pvd->pe_size = vg->extent_size;
-	else
-		pvd->pe_size = pv->pe_size;
-	pvd->pe_total = pv->pe_count;
-	pvd->pe_allocated = pv->pe_alloc_count;
-	pvd->pe_start = pv->pe_start;
-
-	return 1;
-}
-
-int import_vg(struct dm_pool *mem,
-	      struct volume_group *vg, struct disk_list *dl)
-{
-	struct vg_disk *vgd = &dl->vgd;
-	memcpy(vg->id.uuid, vgd->vg_uuid, ID_LEN);
-
-	if (!_check_vg_name((char *)dl->pvd.vg_name))
-		return_0;
-
-	if (!(vg->name = dm_pool_strdup(mem, (char *)dl->pvd.vg_name)))
-		return_0;
-
-	if (!(vg->lvm1_system_id = dm_pool_zalloc(mem, NAME_LEN + 1)))
-		return_0;
-
-	if (vgd->vg_status & VG_EXPORTED)
-		vg->status |= EXPORTED_VG;
-
-	if (vgd->vg_status & VG_EXTENDABLE)
-		vg->status |= RESIZEABLE_VG;
-
-	if (vgd->vg_access & VG_READ)
-		vg->status |= LVM_READ;
-
-	if (vgd->vg_access & VG_WRITE)
-		vg->status |= LVM_WRITE;
-
-	if (vgd->vg_access & VG_CLUSTERED)
-		vg->status |= CLUSTERED;
-
-	if (vgd->vg_access & VG_SHARED)
-		vg->status |= SHARED;
-
-	vg->extent_size = vgd->pe_size;
-	vg->extent_count = vgd->pe_total;
-	vg->free_count = vgd->pe_total;
-	vg->max_lv = vgd->lv_max;
-	vg->max_pv = vgd->pv_max;
-	vg->alloc = ALLOC_NORMAL;
-
-	return 1;
-}
-
-int export_vg(struct vg_disk *vgd, struct volume_group *vg)
-{
-	memset(vgd, 0, sizeof(*vgd));
-	memcpy(vgd->vg_uuid, vg->id.uuid, ID_LEN);
-
-	if (vg->status & LVM_READ)
-		vgd->vg_access |= VG_READ;
-
-	if (vg->status & LVM_WRITE)
-		vgd->vg_access |= VG_WRITE;
-
-	if (vg_is_clustered(vg))
-		vgd->vg_access |= VG_CLUSTERED;
-
-	if (vg->status & SHARED)
-		vgd->vg_access |= VG_SHARED;
-
-	if (vg_is_exported(vg))
-		vgd->vg_status |= VG_EXPORTED;
-
-	if (vg_is_resizeable(vg))
-		vgd->vg_status |= VG_EXTENDABLE;
-
-	vgd->lv_max = vg->max_lv;
-	vgd->lv_cur = vg_visible_lvs(vg) + snapshot_count(vg);
-
-	vgd->pv_max = vg->max_pv;
-	vgd->pv_cur = vg->pv_count;
-
-	vgd->pe_size = vg->extent_size;
-	vgd->pe_total = vg->extent_count;
-	vgd->pe_allocated = vg->extent_count - vg->free_count;
-
-	return 1;
-}
-
-int import_lv(struct cmd_context *cmd, struct dm_pool *mem,
-	      struct logical_volume *lv, struct lv_disk *lvd)
-{
-	if (!(lv->name = _create_lv_name(mem, (char *)lvd->lv_name)))
-		return_0;
-
-	lv->status |= VISIBLE_LV;
-
-	if (lvd->lv_status & LV_SPINDOWN)
-		lv->status |= SPINDOWN_LV;
-
-	if (lvd->lv_status & LV_PERSISTENT_MINOR) {
-		lv->status |= FIXED_MINOR;
-		lv->minor = MINOR(lvd->lv_dev);
-		lv->major = MAJOR(lvd->lv_dev);
-	} else {
-		lv->major = -1;
-		lv->minor = -1;
-	}
-
-	if (lvd->lv_access & LV_READ)
-		lv->status |= LVM_READ;
-
-	if (lvd->lv_access & LV_WRITE)
-		lv->status |= LVM_WRITE;
-
-	if (lvd->lv_badblock)
-		lv->status |= BADBLOCK_ON;
-
-	/* Drop the unused LV_STRICT here */
-	if (lvd->lv_allocation & LV_CONTIGUOUS)
-		lv->alloc = ALLOC_CONTIGUOUS;
-	else
-		lv->alloc = ALLOC_NORMAL;
-
-	if (!lvd->lv_read_ahead)
-		lv->read_ahead = cmd->default_settings.read_ahead;
-	else
-		lv->read_ahead = lvd->lv_read_ahead;
-
-	lv->size = lvd->lv_size;
-	lv->le_count = lvd->lv_allocated_le;
-
-	return 1;
-}
-
-static void _export_lv(struct lv_disk *lvd, struct volume_group *vg,
-		       struct logical_volume *lv, const char *dev_dir)
-{
-	memset(lvd, 0, sizeof(*lvd));
-	snprintf((char *)lvd->lv_name, sizeof(lvd->lv_name), "%s%s/%s",
-		 dev_dir, vg->name, lv->name);
-
-	(void) dm_strncpy((char *)lvd->vg_name, vg->name, sizeof(lvd->vg_name));
-
-	if (lv->status & LVM_READ)
-		lvd->lv_access |= LV_READ;
-
-	if (lv->status & LVM_WRITE)
-		lvd->lv_access |= LV_WRITE;
-
-	if (lv->status & SPINDOWN_LV)
-		lvd->lv_status |= LV_SPINDOWN;
-
-	if (lv->status & FIXED_MINOR) {
-		lvd->lv_status |= LV_PERSISTENT_MINOR;
-		lvd->lv_dev = MKDEV(lv->major, lv->minor);
-	} else {
-		lvd->lv_dev = MKDEV(LVM_BLK_MAJOR, lvnum_from_lvid(&lv->lvid));
-	}
-
-	if (lv->read_ahead == DM_READ_AHEAD_AUTO ||
-	    lv->read_ahead == DM_READ_AHEAD_NONE)
-		lvd->lv_read_ahead = 0;
-	else
-		lvd->lv_read_ahead = lv->read_ahead;
-
-	lvd->lv_stripes =
-	    dm_list_item(lv->segments.n, struct lv_segment)->area_count;
-	lvd->lv_stripesize =
-	    dm_list_item(lv->segments.n, struct lv_segment)->stripe_size;
-
-	lvd->lv_size = lv->size;
-	lvd->lv_allocated_le = lv->le_count;
-
-	if (lv->status & BADBLOCK_ON)
-		lvd->lv_badblock = LV_BADBLOCK_ON;
-
-	if (lv->alloc == ALLOC_CONTIGUOUS)
-		lvd->lv_allocation |= LV_CONTIGUOUS;
-}
-
-int export_extents(struct disk_list *dl, uint32_t lv_num,
-		   struct logical_volume *lv, struct physical_volume *pv)
-{
-	struct pe_disk *ped;
-	struct lv_segment *seg;
-	uint32_t pe, s;
-
-	dm_list_iterate_items(seg, &lv->segments) {
-		for (s = 0; s < seg->area_count; s++) {
-			if (!(seg->segtype->flags & SEG_FORMAT1_SUPPORT)) {
-				log_error("Segment type %s in LV %s: "
-					  "unsupported by format1",
-					  lvseg_name(seg), lv->name);
-				return 0;
-			}
-			if (seg_type(seg, s) != AREA_PV) {
-				log_error("Non-PV stripe found in LV %s: "
-					  "unsupported by format1", lv->name);
-				return 0;
-			}
-			if (seg_pv(seg, s) != pv)
-				continue;	/* not our pv */
-
-			for (pe = 0; pe < (seg->len / seg->area_count); pe++) {
-				ped = &dl->extents[pe + seg_pe(seg, s)];
-				ped->lv_num = lv_num;
-				ped->le_num = (seg->le / seg->area_count) + pe +
-				    s * (lv->le_count / seg->area_count);
-			}
-		}
-	}
-
-	return 1;
-}
-
-int import_pvs(const struct format_type *fmt, struct dm_pool *mem,
-	       struct volume_group *vg, struct dm_list *pvds)
-{
-	struct disk_list *dl;
-	struct pv_list *pvl;
-
-	vg->pv_count = 0;
-	dm_list_iterate_items(dl, pvds) {
-		if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl))) ||
-		    !(pvl->pv = dm_pool_alloc(mem, sizeof(*pvl->pv))))
-			return_0;
-
-		if (!import_pv(fmt, mem, dl->dev, vg, pvl->pv, &dl->pvd, &dl->vgd))
-			return_0;
-
-		pvl->pv->fmt = fmt;
-		add_pvl_to_vgs(vg, pvl);
-	}
-
-	return 1;
-}
-
-static struct logical_volume *_add_lv(struct dm_pool *mem,
-				      struct volume_group *vg,
-				      struct lv_disk *lvd)
-{
-	struct logical_volume *lv;
-
-	if (!(lv = alloc_lv(mem)))
-		return_NULL;
-
-	lvid_from_lvnum(&lv->lvid, &vg->id, lvd->lv_number);
-
-	if (!import_lv(vg->cmd, mem, lv, lvd)) 
-		goto_bad;
-
-	if (!link_lv_to_vg(vg, lv))
-		goto_bad;
-
-	return lv;
-bad:
-	dm_pool_free(mem, lv);
-	return NULL;
-}
-
-int import_lvs(struct dm_pool *mem, struct volume_group *vg, struct dm_list *pvds)
-{
-	struct disk_list *dl;
-	struct lvd_list *ll;
-	struct lv_disk *lvd;
-
-	dm_list_iterate_items(dl, pvds) {
-		dm_list_iterate_items(ll, &dl->lvds) {
-			lvd = &ll->lvd;
-
-			if (!find_lv(vg, (char *)lvd->lv_name) &&
-			    !_add_lv(mem, vg, lvd))
-				return_0;
-		}
-	}
-
-	return 1;
-}
-
-/* FIXME: tidy */
-int export_lvs(struct disk_list *dl, struct volume_group *vg,
-	       struct physical_volume *pv, const char *dev_dir)
-{
-	int r = 0;
-	struct lv_list *ll;
-	struct lvd_list *lvdl;
-	size_t len;
-	uint32_t lv_num;
-	struct dm_hash_table *lvd_hash;
-
-	if (!_check_vg_name(vg->name))
-		return_0;
-
-	if (!(lvd_hash = dm_hash_create(32)))
-		return_0;
-
-	/*
-	 * setup the pv's extents array
-	 */
-	len = sizeof(struct pe_disk) * dl->pvd.pe_total;
-	if (!(dl->extents = dm_pool_zalloc(dl->mem, len)))
-		goto_out;
-
-	dm_list_iterate_items(ll, &vg->lvs) {
-		if (lv_is_snapshot(ll->lv))
-			continue;
-
-		if (!(lvdl = dm_pool_alloc(dl->mem, sizeof(*lvdl))))
-			goto_out;
-
-		_export_lv(&lvdl->lvd, vg, ll->lv, dev_dir);
-
-		lv_num = lvnum_from_lvid(&ll->lv->lvid);
-		lvdl->lvd.lv_number = lv_num;
-
-		if (!dm_hash_insert(lvd_hash, ll->lv->name, &lvdl->lvd))
-			goto_out;
-
-		if (!export_extents(dl, lv_num + 1, ll->lv, pv))
-			goto_out;
-
-		if (lv_is_origin(ll->lv))
-			lvdl->lvd.lv_access |= LV_SNAPSHOT_ORG;
-
-		if (lv_is_cow(ll->lv)) {
-			lvdl->lvd.lv_access |= LV_SNAPSHOT;
-			lvdl->lvd.lv_chunk_size = ll->lv->snapshot->chunk_size;
-			lvdl->lvd.lv_snapshot_minor =
-			    lvnum_from_lvid(&ll->lv->snapshot->origin->lvid);
-		}
-
-		dm_list_add(&dl->lvds, &lvdl->list);
-		dl->pvd.lv_cur++;
-	}
-
-	r = 1;
-
-      out:
-	dm_hash_destroy(lvd_hash);
-	return r;
-}
-
-/*
- * FIXME: More inefficient code.
- */
-int import_snapshots(struct dm_pool *mem __attribute__((unused)), struct volume_group *vg,
-		     struct dm_list *pvds)
-{
-	struct logical_volume *lvs[MAX_LV] = { 0 };
-	struct disk_list *dl;
-	struct lvd_list *ll;
-	struct lv_disk *lvd;
-	int lvnum;
-	struct logical_volume *org, *cow;
-
-	/* build an index of lv numbers */
-	dm_list_iterate_items(dl, pvds) {
-		dm_list_iterate_items(ll, &dl->lvds) {
-			lvd = &ll->lvd;
-
-			lvnum = lvd->lv_number;
-
-			if (lvnum >= MAX_LV) {
-				log_error("Logical volume number "
-					  "out of bounds.");
-				return 0;
-			}
-
-			if (!lvs[lvnum] &&
-			    !(lvs[lvnum] = find_lv(vg, (char *)lvd->lv_name))) {
-				log_error("Couldn't find logical volume '%s'.",
-					  lvd->lv_name);
-				return 0;
-			}
-		}
-	}
-
-	/*
-	 * Now iterate through yet again adding the snapshots.
-	 */
-	dm_list_iterate_items(dl, pvds) {
-		dm_list_iterate_items(ll, &dl->lvds) {
-			lvd = &ll->lvd;
-
-			if (!(lvd->lv_access & LV_SNAPSHOT))
-				continue;
-
-			lvnum = lvd->lv_number;
-			cow = lvs[lvnum];
-			if (!(org = lvs[lvd->lv_snapshot_minor])) {
-				log_error("Couldn't find origin logical volume "
-					  "for snapshot '%s'.", lvd->lv_name);
-				return 0;
-			}
-
-			/* we may have already added this snapshot */
-			if (lv_is_cow(cow))
-				continue;
-
-			/* insert the snapshot */
-			if (!vg_add_snapshot(org, cow, NULL,
-					     org->le_count,
-					     lvd->lv_chunk_size)) {
-				log_error("Couldn't add snapshot.");
-				return 0;
-			}
-		}
-	}
-
-	return 1;
-}
-
-int export_uuids(struct disk_list *dl, struct volume_group *vg)
-{
-	struct uuid_list *ul;
-	struct pv_list *pvl;
-
-	dm_list_iterate_items(pvl, &vg->pvs) {
-		if (!(ul = dm_pool_alloc(dl->mem, sizeof(*ul))))
-			return_0;
-
-		memset(ul->uuid, 0, sizeof(ul->uuid));
-		memcpy(ul->uuid, pvl->pv->id.uuid, ID_LEN);
-
-		dm_list_add(&dl->uuids, &ul->list);
-	}
-	return 1;
-}
-
-/*
- * This calculates the nasty pv_number field
- * used by LVM1.
- */
-void export_numbers(struct dm_list *pvds, struct volume_group *vg __attribute__((unused)))
-{
-	struct disk_list *dl;
-	int pv_num = 1;
-
-	dm_list_iterate_items(dl, pvds)
-		dl->pvd.pv_number = pv_num++;
-}
-
-/*
- * Calculate vg_disk->pv_act.
- */
-void export_pv_act(struct dm_list *pvds)
-{
-	struct disk_list *dl;
-	int act = 0;
-
-	dm_list_iterate_items(dl, pvds)
-		if (dl->pvd.pv_status & PV_ACTIVE)
-			act++;
-
-	dm_list_iterate_items(dl, pvds)
-		dl->vgd.pv_act = act;
-}
-
-int export_vg_number(struct format_instance *fid, struct dm_list *pvds,
-		     const char *vg_name, struct dev_filter *filter)
-{
-	struct disk_list *dl;
-	int vg_num;
-
-	if (!get_free_vg_number(fid, filter, vg_name, &vg_num))
-		return_0;
-
-	dm_list_iterate_items(dl, pvds)
-		dl->vgd.vg_number = vg_num;
-
-	return 1;
-}
diff --git a/lib/format1/import-extents.c b/lib/format1/import-extents.c
deleted file mode 100644
index c583741..0000000
--- a/lib/format1/import-extents.c
+++ /dev/null
@@ -1,377 +0,0 @@
-/*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
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
-#include "lib.h"
-#include "metadata.h"
-#include "disk-rep.h"
-#include "lv_alloc.h"
-#include "display.h"
-#include "segtype.h"
-
-/*
- * After much thought I have decided it is easier,
- * and probably no less efficient, to convert the
- * pe->le map to a full le->pe map, and then
- * process this to get the segments form that
- * we're after.  Any code which goes directly from
- * the pe->le map to segments would be gladly
- * accepted, if it is less complicated than this
- * file.
- */
-struct pe_specifier {
-	struct physical_volume *pv;
-	uint32_t pe;
-};
-
-struct lv_map {
-	struct logical_volume *lv;
-	uint32_t stripes;
-	uint32_t stripe_size;
-	struct pe_specifier *map;
-};
-
-static struct dm_hash_table *_create_lv_maps(struct dm_pool *mem,
-					  struct volume_group *vg)
-{
-	struct dm_hash_table *maps = dm_hash_create(32);
-	struct lv_list *ll;
-	struct lv_map *lvm;
-
-	if (!maps) {
-		log_error("Unable to create hash table for holding "
-			  "extent maps.");
-		return NULL;
-	}
-
-	dm_list_iterate_items(ll, &vg->lvs) {
-		if (lv_is_snapshot(ll->lv))
-			continue;
-
-		if (!(lvm = dm_pool_alloc(mem, sizeof(*lvm))))
-			goto_bad;
-
-		lvm->lv = ll->lv;
-		/*
-		 * Alloc 1 extra element, so the loop in _area_length() and
-		 * _check_stripe() finds the last map member as noncontinuous.
-		 */
-		if (!(lvm->map = dm_pool_zalloc(mem, sizeof(*lvm->map)
-					     * (ll->lv->le_count + 1))))
-			goto_bad;
-
-		if (!dm_hash_insert(maps, ll->lv->name, lvm))
-			goto_bad;
-	}
-
-	return maps;
-
-      bad:
-	dm_hash_destroy(maps);
-	return NULL;
-}
-
-static int _fill_lv_array(struct lv_map **lvs,
-			  struct dm_hash_table *maps, struct disk_list *dl)
-{
-	struct lvd_list *ll;
-	struct lv_map *lvm;
-
-	memset(lvs, 0, sizeof(*lvs) * MAX_LV);
-
-	dm_list_iterate_items(ll, &dl->lvds) {
-		if (!(lvm = dm_hash_lookup(maps, strrchr((char *)ll->lvd.lv_name, '/')
-					+ 1))) {
-			log_error("Physical volume (%s) contains an "
-				  "unknown logical volume (%s).",
-				dev_name(dl->dev), ll->lvd.lv_name);
-			return 0;
-		}
-
-		lvm->stripes = ll->lvd.lv_stripes;
-		lvm->stripe_size = ll->lvd.lv_stripesize;
-
-		lvs[ll->lvd.lv_number] = lvm;
-	}
-
-	return 1;
-}
-
-static int _fill_maps(struct dm_hash_table *maps, struct volume_group *vg,
-		      struct dm_list *pvds)
-{
-	struct disk_list *dl;
-	struct physical_volume *pv;
-	struct lv_map *lvms[MAX_LV], *lvm;
-	struct pe_disk *e;
-	uint32_t i, lv_num, le;
-
-	dm_list_iterate_items(dl, pvds) {
-		if (!(pv = find_pv(vg, dl->dev))) {
-			log_error("PV %s not found.", dl->dev->pvid);
-			return 0;
-		}
-		e = dl->extents;
-
-		/* build an array of lv's for this pv */
-		if (!_fill_lv_array(lvms, maps, dl))
-			return_0;
-
-		for (i = 0; i < dl->pvd.pe_total; i++) {
-			lv_num = e[i].lv_num;
-
-			if (lv_num == UNMAPPED_EXTENT)
-				continue;
-
-			lv_num--;
-			lvm = lvms[lv_num];
-
-			if (!lvm) {
-				log_error("Invalid LV in extent map "
-					  "(PV %s, PE %" PRIu32
-					  ", LV %" PRIu32
-					  ", LE %" PRIu32 ")",
-					  dev_name(pv->dev), i,
-					  lv_num, e[i].le_num);
-				return 0;
-			}
-
-			le = e[i].le_num;
-
-			if (le >= lvm->lv->le_count) {
-				log_error("logical extent number "
-					  "out of bounds");
-				return 0;
-			}
-
-			if (lvm->map[le].pv) {
-				log_error("logical extent (%u) "
-					  "already mapped.", le);
-				return 0;
-			}
-
-			lvm->map[le].pv = pv;
-			lvm->map[le].pe = i;
-		}
-	}
-
-	return 1;
-}
-
-static int _check_single_map(struct lv_map *lvm)
-{
-	uint32_t i;
-
-	for (i = 0; i < lvm->lv->le_count; i++) {
-		if (!lvm->map[i].pv) {
-			log_error("Logical volume (%s) contains an incomplete "
-				  "mapping table.", lvm->lv->name);
-			return 0;
-		}
-	}
-
-	return 1;
-}
-
-static int _check_maps_are_complete(struct dm_hash_table *maps)
-{
-	struct dm_hash_node *n;
-	struct lv_map *lvm;
-
-	for (n = dm_hash_get_first(maps); n; n = dm_hash_get_next(maps, n)) {
-		lvm = (struct lv_map *) dm_hash_get_data(maps, n);
-
-		if (!_check_single_map(lvm))
-			return_0;
-	}
-	return 1;
-}
-
-static uint32_t _area_length(struct lv_map *lvm, uint32_t le)
-{
-	uint32_t len = 0;
-
-	do
-		len++;
-	while ((lvm->map[le + len].pv == lvm->map[le].pv) &&
-		 (lvm->map[le].pv &&
-		  lvm->map[le + len].pe == lvm->map[le].pe + len));
-
-	return len;
-}
-
-static int _read_linear(struct cmd_context *cmd, struct lv_map *lvm)
-{
-	uint32_t le = 0, len;
-	struct lv_segment *seg;
-	struct segment_type *segtype;
-
-	if (!(segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_STRIPED)))
-		return_0;
-
-	while (le < lvm->lv->le_count) {
-		len = _area_length(lvm, le);
-
-		if (!(seg = alloc_lv_segment(segtype, lvm->lv, le, len, 0, 0, 0,
-					     NULL, 1, len, 0, 0, 0, 0, NULL))) {
-			log_error("Failed to allocate linear segment.");
-			return 0;
-		}
-
-		if (!set_lv_segment_area_pv(seg, 0, lvm->map[le].pv,
-					    lvm->map[le].pe))
-			return_0;
-
-		dm_list_add(&lvm->lv->segments, &seg->list);
-
-		le += seg->len;
-	}
-
-	return 1;
-}
-
-static int _check_stripe(struct lv_map *lvm, uint32_t area_count,
-			 uint32_t area_len, uint32_t base_le,
-			 uint32_t total_area_len)
-{
-	uint32_t st;
-
-	/*
-	 * Is the next physical extent in every stripe adjacent to the last?
-	 */
-	for (st = 0; st < area_count; st++)
-		if ((lvm->map[base_le + st * total_area_len + area_len].pv !=
-		     lvm->map[base_le + st * total_area_len].pv) ||
-		    (lvm->map[base_le + st * total_area_len].pv &&
-		     lvm->map[base_le + st * total_area_len + area_len].pe !=
-		     lvm->map[base_le + st * total_area_len].pe + area_len))
-			return 0;
-
-	return 1;
-}
-
-static int _read_stripes(struct cmd_context *cmd, struct lv_map *lvm)
-{
-	uint32_t st, first_area_le = 0, total_area_len;
-	uint32_t area_len;
-	struct lv_segment *seg;
-	struct segment_type *segtype;
-
-	/*
-	 * Work out overall striped length
-	 */
-	if (lvm->lv->le_count % lvm->stripes) {
-		log_error("Number of stripes (%u) incompatible "
-			  "with logical extent count (%u) for %s",
-			  lvm->stripes, lvm->lv->le_count, lvm->lv->name);
-	}
-
-	total_area_len = lvm->lv->le_count / lvm->stripes;
-
-	if (!(segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_STRIPED)))
-		return_0;
-
-	while (first_area_le < total_area_len) {
-		area_len = 1;
-
-		/*
-		 * Find how many extents are contiguous in all stripes
-		 * and so can form part of this segment
-		 */
-		while (_check_stripe(lvm, lvm->stripes,
-				     area_len, first_area_le, total_area_len))
-			area_len++;
-
-		if (!(seg = alloc_lv_segment(segtype, lvm->lv,
-					     lvm->stripes * first_area_le,
-					     lvm->stripes * area_len, 0,
-					     0, lvm->stripe_size, NULL,
-					     lvm->stripes,
-					     area_len, 0, 0, 0, 0, NULL))) {
-			log_error("Failed to allocate striped segment.");
-			return 0;
-		}
-
-		/*
-		 * Set up start positions of each stripe in this segment
-		 */
-		for (st = 0; st < seg->area_count; st++)
-			if (!set_lv_segment_area_pv(seg, st,
-			      lvm->map[first_area_le + st * total_area_len].pv,
-			      lvm->map[first_area_le + st * total_area_len].pe))
-				return_0;
-
-		dm_list_add(&lvm->lv->segments, &seg->list);
-
-		first_area_le += area_len;
-	}
-
-	return 1;
-}
-
-static int _build_segments(struct cmd_context *cmd, struct lv_map *lvm)
-{
-	return (lvm->stripes > 1 ? _read_stripes(cmd, lvm) :
-		_read_linear(cmd, lvm));
-}
-
-static int _build_all_segments(struct cmd_context *cmd, struct dm_hash_table *maps)
-{
-	struct dm_hash_node *n;
-	struct lv_map *lvm;
-
-	for (n = dm_hash_get_first(maps); n; n = dm_hash_get_next(maps, n)) {
-		lvm = (struct lv_map *) dm_hash_get_data(maps, n);
-		if (!_build_segments(cmd, lvm))
-			return_0;
-	}
-
-	return 1;
-}
-
-int import_extents(struct cmd_context *cmd, struct volume_group *vg,
-		   struct dm_list *pvds)
-{
-	int r = 0;
-	struct dm_pool *scratch = dm_pool_create("lvm1 import_extents", 10 * 1024);
-	struct dm_hash_table *maps;
-
-	if (!scratch)
-		return_0;
-
-	if (!(maps = _create_lv_maps(scratch, vg))) {
-		log_error("Couldn't allocate logical volume maps.");
-		goto out;
-	}
-
-	if (!_fill_maps(maps, vg, pvds)) {
-		log_error("Couldn't fill logical volume maps.");
-		goto out;
-	}
-
-	if (!_check_maps_are_complete(maps) && !(vg->status & PARTIAL_VG))
-		goto_out;
-
-	if (!_build_all_segments(cmd, maps)) {
-		log_error("Couldn't build extent segments.");
-		goto out;
-	}
-	r = 1;
-
-      out:
-	if (maps)
-		dm_hash_destroy(maps);
-	dm_pool_destroy(scratch);
-	return r;
-}
diff --git a/lib/format1/layout.c b/lib/format1/layout.c
deleted file mode 100644
index 380a983..0000000
--- a/lib/format1/layout.c
+++ /dev/null
@@ -1,172 +0,0 @@
-/*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
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
-#include "lib.h"
-#include "disk-rep.h"
-
-/*
- * Only works with powers of 2.
- */
-static uint32_t _round_up(uint32_t n, uint32_t size)
-{
-	size--;
-	return (n + size) & ~size;
-}
-
-/* Unused.
-static uint32_t _div_up(uint32_t n, uint32_t size)
-{
-	return _round_up(n, size) / size;
-}
-*/
-
-/*
- * Each chunk of metadata should be aligned to
- * METADATA_ALIGN.
- */
-static uint32_t _next_base(struct data_area *area)
-{
-	return _round_up(area->base + area->size, METADATA_ALIGN);
-}
-
-/*
- * Quick calculation based on pe_start.
- */
-static int _adjust_pe_on_disk(struct pv_disk *pvd)
-{
-	uint32_t pe_start = pvd->pe_start << SECTOR_SHIFT;
-
-	if (pe_start < pvd->pe_on_disk.base + pvd->pe_on_disk.size)
-		return 0;
-
-	pvd->pe_on_disk.size = pe_start - pvd->pe_on_disk.base;
-	return 1;
-}
-
-static void _calc_simple_layout(struct pv_disk *pvd)
-{
-	pvd->pv_on_disk.base = METADATA_BASE;
-	pvd->pv_on_disk.size = PV_SIZE;
-
-	pvd->vg_on_disk.base = _next_base(&pvd->pv_on_disk);
-	pvd->vg_on_disk.size = VG_SIZE;
-
-	pvd->pv_uuidlist_on_disk.base = _next_base(&pvd->vg_on_disk);
-	pvd->pv_uuidlist_on_disk.size = MAX_PV * NAME_LEN;
-
-	pvd->lv_on_disk.base = _next_base(&pvd->pv_uuidlist_on_disk);
-	pvd->lv_on_disk.size = MAX_LV * sizeof(struct lv_disk);
-
-	pvd->pe_on_disk.base = _next_base(&pvd->lv_on_disk);
-	pvd->pe_on_disk.size = pvd->pe_total * sizeof(struct pe_disk);
-}
-
-static int _check_vg_limits(struct disk_list *dl)
-{
-	if (dl->vgd.lv_max > MAX_LV) {
-		log_error("MaxLogicalVolumes of %d exceeds format limit of %d "
-			  "for VG '%s'", dl->vgd.lv_max, MAX_LV - 1,
-			  dl->pvd.vg_name);
-		return 0;
-	}
-
-	if (dl->vgd.pv_max > MAX_PV) {
-		log_error("MaxPhysicalVolumes of %d exceeds format limit of %d "
-			  "for VG '%s'", dl->vgd.pv_max, MAX_PV - 1,
-			  dl->pvd.vg_name);
-		return 0;
-	}
-
-	return 1;
-}
-
-/*
- * This assumes pe_count and pe_start have already
- * been calculated correctly.
- */
-int calculate_layout(struct disk_list *dl)
-{
-	struct pv_disk *pvd = &dl->pvd;
-
-	_calc_simple_layout(pvd);
-	if (!_adjust_pe_on_disk(pvd)) {
-		log_error("Insufficient space for metadata and PE's.");
-		return 0;
-	}
-
-	if (!_check_vg_limits(dl))
-		return 0;
-
-	return 1;
-}
-
-/*
- * The number of extents that can fit on a disk is metadata format dependant.
- * pe_start is any existing value for pe_start
- */
-int calculate_extent_count(struct physical_volume *pv, uint32_t extent_size,
-			   uint32_t max_extent_count, uint64_t pe_start)
-{
-	struct pv_disk *pvd = dm_malloc(sizeof(*pvd));
-	uint32_t end;
-
-	if (!pvd)
-		return_0;
-
-	/*
-	 * Guess how many extents will fit, bearing in mind that
-	 * one is going to be knocked off at the start of the
-	 * next loop.
-	 */
-	if (max_extent_count)
-		pvd->pe_total = max_extent_count + 1;
-	else
-		pvd->pe_total = (pv->size / extent_size);
-
-	if (pvd->pe_total < PE_SIZE_PV_SIZE_REL) {
-		log_error("Too few extents on %s.  Try smaller extent size.",
-			  pv_dev_name(pv));
-		dm_free(pvd);
-		return 0;
-	}
-
-	do {
-		pvd->pe_total--;
-		_calc_simple_layout(pvd);
-		end = ((pvd->pe_on_disk.base + pvd->pe_on_disk.size +
-			SECTOR_SIZE - 1) >> SECTOR_SHIFT);
-
-		if (pe_start && end < pe_start)
-			end = pe_start;
-
-		pvd->pe_start = _round_up(end, LVM1_PE_ALIGN);
-
-	} while ((pvd->pe_start + ((uint64_t)pvd->pe_total * extent_size))
-		 > pv->size);
-
-	if (pvd->pe_total > MAX_PE_TOTAL) {
-		log_error("Metadata extent limit (%u) exceeded for %s - "
-			  "%u required", MAX_PE_TOTAL, pv_dev_name(pv),
-			  pvd->pe_total);
-		dm_free(pvd);
-		return 0;
-	}
-
-	pv->pe_count = pvd->pe_total;
-	pv->pe_start = pvd->pe_start;
-	/* We can't set pe_size here without breaking LVM1 compatibility */
-	dm_free(pvd);
-	return 1;
-}
diff --git a/lib/format1/lvm1-label.c b/lib/format1/lvm1-label.c
deleted file mode 100644
index 691a05a..0000000
--- a/lib/format1/lvm1-label.c
+++ /dev/null
@@ -1,129 +0,0 @@
-/*
- * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
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
-#include "lib.h"
-#include "lvm1-label.h"
-#include "disk-rep.h"
-#include "label.h"
-#include "metadata.h"
-#include "xlate.h"
-#include "format1.h"
-
-#include <sys/stat.h>
-#include <fcntl.h>
-
-static void _not_supported(const char *op)
-{
-	log_error("The '%s' operation is not supported for the lvm1 labeller.",
-		  op);
-}
-
-static int _lvm1_can_handle(struct labeller *l __attribute__((unused)), void *buf, uint64_t sector)
-{
-	struct pv_disk *pvd = (struct pv_disk *) buf;
-	uint32_t version;
-
-	/* LVM1 label must always be in first sector */
-	if (sector)
-		return 0;
-
-	version = xlate16(pvd->version);
-
-	if (pvd->id[0] == 'H' && pvd->id[1] == 'M' &&
-	    (version == 1 || version == 2))
-		return 1;
-
-	return 0;
-}
-
-static int _lvm1_write(struct label *label __attribute__((unused)), void *buf __attribute__((unused)))
-{
-	_not_supported("write");
-	return 0;
-}
-
-static int _lvm1_read(struct labeller *l, struct device *dev, void *buf,
-		 struct label **label)
-{
-	struct pv_disk *pvd = (struct pv_disk *) buf;
-	struct vg_disk vgd;
-	struct lvmcache_info *info;
-	const char *vgid = FMT_LVM1_ORPHAN_VG_NAME;
-	const char *vgname = FMT_LVM1_ORPHAN_VG_NAME;
-	unsigned exported = 0;
-
-	munge_pvd(dev, pvd);
-
-	if (*pvd->vg_name) {
-		if (!read_vgd(dev, &vgd, pvd))
-			return_0;
-		vgid = (char *) vgd.vg_uuid;
-		vgname = (char *) pvd->vg_name;
-		exported = pvd->pv_status & VG_EXPORTED;
-	}
-
-	if (!(info = lvmcache_add(l, (char *)pvd->pv_uuid, dev, vgname, vgid,
-				  exported)))
-		return_0;
-	*label = lvmcache_get_label(info);
-
-	lvmcache_set_device_size(info, ((uint64_t)xlate32(pvd->pv_size)) << SECTOR_SHIFT);
-	lvmcache_set_ext_version(info, 0);
-	lvmcache_set_ext_flags(info, 0);
-	lvmcache_del_mdas(info);
-	lvmcache_del_bas(info);
-
-	return 1;
-}
-
-static int _lvm1_initialise_label(struct labeller *l __attribute__((unused)), struct label *label)
-{
-	strcpy(label->type, "LVM1");
-
-	return 1;
-}
-
-static void _lvm1_destroy_label(struct labeller *l __attribute__((unused)), struct label *label __attribute__((unused)))
-{
-}
-
-static void _lvm1_destroy(struct labeller *l)
-{
-	dm_free(l);
-}
-
-struct label_ops _lvm1_ops = {
-	.can_handle = _lvm1_can_handle,
-	.write = _lvm1_write,
-	.read = _lvm1_read,
-	.initialise_label = _lvm1_initialise_label,
-	.destroy_label = _lvm1_destroy_label,
-	.destroy = _lvm1_destroy,
-};
-
-struct labeller *lvm1_labeller_create(struct format_type *fmt)
-{
-	struct labeller *l;
-
-	if (!(l = dm_malloc(sizeof(*l)))) {
-		log_error("Couldn't allocate labeller object.");
-		return NULL;
-	}
-
-	l->ops = &_lvm1_ops;
-	l->fmt = fmt;
-
-	return l;
-}
diff --git a/lib/format1/lvm1-label.h b/lib/format1/lvm1-label.h
deleted file mode 100644
index 27f2f51..0000000
--- a/lib/format1/lvm1-label.h
+++ /dev/null
@@ -1,23 +0,0 @@
-/*
- * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
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
-#ifndef _LVM_LVM1_LABEL_H
-#define _LVM_LVM1_LABEL_H
-
-#include "metadata.h"
-
-struct labeller *lvm1_labeller_create(struct format_type *fmt);
-
-#endif
diff --git a/lib/format1/vg_number.c b/lib/format1/vg_number.c
deleted file mode 100644
index 8b1a803..0000000
--- a/lib/format1/vg_number.c
+++ /dev/null
@@ -1,60 +0,0 @@
-/*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
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
-#include "lib.h"
-#include "disk-rep.h"
-
-/*
- * FIXME: Quick hack.  We can use caching to
- * prevent a total re-read, even so vg_number
- * causes the tools to check *every* pv.  Yuck.
- * Put in separate file so it wouldn't contaminate
- * other code.
- */
-int get_free_vg_number(struct format_instance *fid, struct dev_filter *filter,
-		       const char *candidate_vg, int *result)
-{
-	struct dm_list all_pvs;
-	struct disk_list *dl;
-	struct dm_pool *mem = dm_pool_create("lvm1 vg_number", 10 * 1024);
-	int i, r = 0, numbers[MAX_VG] = { 0 };
-
-	dm_list_init(&all_pvs);
-
-	if (!mem)
-		return_0;
-
-	if (!read_pvs_in_vg(fid->fmt, NULL, filter, mem, &all_pvs))
-		goto_out;
-
-	dm_list_iterate_items(dl, &all_pvs) {
-		if (!*dl->pvd.vg_name || !strcmp((char *)dl->pvd.vg_name, candidate_vg))
-			continue;
-
-		numbers[dl->vgd.vg_number] = 1;
-	}
-
-	for (i = 0; i < MAX_VG; i++) {
-		if (!numbers[i]) {
-			r = 1;
-			*result = i;
-			break;
-		}
-	}
-
-      out:
-	dm_pool_destroy(mem);
-	return r;
-}
diff --git a/lib/format_pool/.exported_symbols b/lib/format_pool/.exported_symbols
deleted file mode 100644
index e9fac2e..0000000
--- a/lib/format_pool/.exported_symbols
+++ /dev/null
@@ -1 +0,0 @@
-init_format
diff --git a/lib/format_pool/Makefile.in b/lib/format_pool/Makefile.in
deleted file mode 100644
index 05d1b0c..0000000
--- a/lib/format_pool/Makefile.in
+++ /dev/null
@@ -1,30 +0,0 @@
-#
-# Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
-#
-# This file is part of LVM2.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-srcdir = @srcdir@
-top_srcdir = @top_srcdir@
-top_builddir = @top_builddir@
-
-SOURCES =\
-	disk_rep.c \
-	format_pool.c \
-	import_export.c \
-	pool_label.c
-
-LIB_SHARED = liblvm2formatpool.$(LIB_SUFFIX)
-LIB_VERSION = $(LIB_VERSION_LVM)
-
-include $(top_builddir)/make.tmpl
-
-install: install_lvm2_plugin
diff --git a/lib/format_pool/disk_rep.c b/lib/format_pool/disk_rep.c
deleted file mode 100644
index fe9b03e..0000000
--- a/lib/format_pool/disk_rep.c
+++ /dev/null
@@ -1,409 +0,0 @@
-/*
- * Copyright (C) 1997-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
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
-#include "lib.h"
-#include "label.h"
-#include "metadata.h"
-#include "lvmcache.h"
-#include "xlate.h"
-#include "disk_rep.h"
-#include "toolcontext.h"
-
-#include <assert.h>
-
-/* FIXME: memcpy might not be portable */
-#define CPIN_8(x, y, z) {memcpy((x), (y), (z));}
-#define CPOUT_8(x, y, z) {memcpy((y), (x), (z));}
-#define CPIN_16(x, y) {(x) = xlate16_be((y));}
-#define CPOUT_16(x, y) {(y) = xlate16_be((x));}
-#define CPIN_32(x, y) {(x) = xlate32_be((y));}
-#define CPOUT_32(x, y) {(y) = xlate32_be((x));}
-#define CPIN_64(x, y) {(x) = xlate64_be((y));}
-#define CPOUT_64(x, y) {(y) = xlate64_be((x));}
-
-static int __read_pool_disk(const struct format_type *fmt, struct device *dev,
-			    struct dm_pool *mem __attribute__((unused)), struct pool_list *pl,
-			    const char *vg_name __attribute__((unused)))
-{
-	char buf[512] __attribute__((aligned(8)));
-
-	/* FIXME: Need to check the cache here first */
-	if (!dev_read(dev, UINT64_C(0), 512, DEV_IO_POOL, buf)) {
-		log_very_verbose("Failed to read PV data from %s",
-				 dev_name(dev));
-		return 0;
-	}
-
-	if (!read_pool_label(pl, fmt->labeller, dev, buf, NULL))
-		return_0;
-
-	return 1;
-}
-
-static void _add_pl_to_list(struct cmd_context *cmd, struct dm_list *head, struct pool_list *data)
-{
-	struct pool_list *pl;
-
-	dm_list_iterate_items(pl, head) {
-		if (id_equal(&data->pv_uuid, &pl->pv_uuid)) {
-			char uuid[ID_LEN + 7] __attribute__((aligned(8)));
-
-			if (!id_write_format(&pl->pv_uuid, uuid, ID_LEN + 7))
-				stack;
-
-			if (!dev_subsystem_part_major(cmd->dev_types, data->dev)) {
-				log_very_verbose("Ignoring duplicate PV %s on "
-						 "%s", uuid,
-						 dev_name(data->dev));
-				return;
-			}
-			log_very_verbose("Duplicate PV %s - using %s %s",
-					 uuid, dev_subsystem_name(cmd->dev_types, data->dev),
-					 dev_name(data->dev));
-			dm_list_del(&pl->list);
-			break;
-		}
-	}
-	dm_list_add(head, &data->list);
-}
-
-int read_pool_label(struct pool_list *pl, struct labeller *l,
-		    struct device *dev, char *buf, struct label **label)
-{
-	struct lvmcache_info *info;
-	struct id pvid;
-	struct id vgid;
-	char uuid[ID_LEN + 7] __attribute__((aligned(8)));
-	struct pool_disk *pd = &pl->pd;
-
-	pool_label_in(pd, buf);
-
-	get_pool_pv_uuid(&pvid, pd);
-	if (!id_write_format(&pvid, uuid, ID_LEN + 7))
-		stack;
-	log_debug_metadata("Calculated uuid %s for %s", uuid, dev_name(dev));
-
-	get_pool_vg_uuid(&vgid, pd);
-	if (!id_write_format(&vgid, uuid, ID_LEN + 7))
-		stack;
-	log_debug_metadata("Calculated uuid %s for %s", uuid, pd->pl_pool_name);
-
-	if (!(info = lvmcache_add(l, (char *) &pvid, dev, pd->pl_pool_name,
-				  (char *) &vgid, 0)))
-		return_0;
-	if (label)
-		*label = lvmcache_get_label(info);
-
-	lvmcache_set_device_size(info, ((uint64_t)xlate32_be(pd->pl_blocks)) << SECTOR_SHIFT);
-	lvmcache_set_ext_version(info, 0);
-	lvmcache_set_ext_flags(info, 0);
-	lvmcache_del_mdas(info);
-	lvmcache_del_bas(info);
-
-	pl->dev = dev;
-	pl->pv = NULL;
-	memcpy(&pl->pv_uuid, &pvid, sizeof(pvid));
-
-	return 1;
-}
-
-/**
- * pool_label_out - copies a pool_label_t into a char buffer
- * @pl: ptr to a pool_label_t struct
- * @buf: ptr to raw space where label info will be copied
- *
- * This function is important because it takes care of all of
- * the endian issues when copying to disk.  This way, when
- * machines of different architectures are used, they will
- * be able to interpret ondisk labels correctly.  Always use
- * this function before writing to disk.
- */
-void pool_label_out(struct pool_disk *pl, void *buf)
-{
-	struct pool_disk *bufpl = (struct pool_disk *) buf;
-
-	CPOUT_64(pl->pl_magic, bufpl->pl_magic);
-	CPOUT_64(pl->pl_pool_id, bufpl->pl_pool_id);
-	CPOUT_8(pl->pl_pool_name, bufpl->pl_pool_name, POOL_NAME_SIZE);
-	CPOUT_32(pl->pl_version, bufpl->pl_version);
-	CPOUT_32(pl->pl_subpools, bufpl->pl_subpools);
-	CPOUT_32(pl->pl_sp_id, bufpl->pl_sp_id);
-	CPOUT_32(pl->pl_sp_devs, bufpl->pl_sp_devs);
-	CPOUT_32(pl->pl_sp_devid, bufpl->pl_sp_devid);
-	CPOUT_32(pl->pl_sp_type, bufpl->pl_sp_type);
-	CPOUT_64(pl->pl_blocks, bufpl->pl_blocks);
-	CPOUT_32(pl->pl_striping, bufpl->pl_striping);
-	CPOUT_32(pl->pl_sp_dmepdevs, bufpl->pl_sp_dmepdevs);
-	CPOUT_32(pl->pl_sp_dmepid, bufpl->pl_sp_dmepid);
-	CPOUT_32(pl->pl_sp_weight, bufpl->pl_sp_weight);
-	CPOUT_32(pl->pl_minor, bufpl->pl_minor);
-	CPOUT_32(pl->pl_padding, bufpl->pl_padding);
-	CPOUT_8(pl->pl_reserve, bufpl->pl_reserve, 184);
-}
-
-/**
- * pool_label_in - copies a char buffer into a pool_label_t
- * @pl: ptr to a pool_label_t struct
- * @buf: ptr to raw space where label info is copied from
- *
- * This function is important because it takes care of all of
- * the endian issues when information from disk is about to be
- * used.  This way, when machines of different architectures
- * are used, they will be able to interpret ondisk labels
- * correctly.  Always use this function before using labels that
- * were read from disk.
- */
-void pool_label_in(struct pool_disk *pl, void *buf)
-{
-	struct pool_disk *bufpl = (struct pool_disk *) buf;
-
-	CPIN_64(pl->pl_magic, bufpl->pl_magic);
-	CPIN_64(pl->pl_pool_id, bufpl->pl_pool_id);
-	CPIN_8(pl->pl_pool_name, bufpl->pl_pool_name, POOL_NAME_SIZE);
-	CPIN_32(pl->pl_version, bufpl->pl_version);
-	CPIN_32(pl->pl_subpools, bufpl->pl_subpools);
-	CPIN_32(pl->pl_sp_id, bufpl->pl_sp_id);
-	CPIN_32(pl->pl_sp_devs, bufpl->pl_sp_devs);
-	CPIN_32(pl->pl_sp_devid, bufpl->pl_sp_devid);
-	CPIN_32(pl->pl_sp_type, bufpl->pl_sp_type);
-	CPIN_64(pl->pl_blocks, bufpl->pl_blocks);
-	CPIN_32(pl->pl_striping, bufpl->pl_striping);
-	CPIN_32(pl->pl_sp_dmepdevs, bufpl->pl_sp_dmepdevs);
-	CPIN_32(pl->pl_sp_dmepid, bufpl->pl_sp_dmepid);
-	CPIN_32(pl->pl_sp_weight, bufpl->pl_sp_weight);
-	CPIN_32(pl->pl_minor, bufpl->pl_minor);
-	CPIN_32(pl->pl_padding, bufpl->pl_padding);
-	CPIN_8(pl->pl_reserve, bufpl->pl_reserve, 184);
-}
-
-static char _calc_char(unsigned int id)
-{
-	/*
-	 * [0-9A-Za-z!#] - 64 printable chars (6-bits)
-	 */
-
-	if (id < 10)
-		return id + 48;
-	if (id < 36)
-		return (id - 10) + 65;
-	if (id < 62)
-		return (id - 36) + 97;
-	if (id == 62)
-		return '!';
-	if (id == 63)
-		return '#';
-
-	return '%';
-}
-
-void get_pool_uuid(char *uuid, uint64_t poolid, uint32_t spid, uint32_t devid)
-{
-	int i;
-	unsigned shifter = 0x003F;
-
-	assert(ID_LEN == 32);
-	memset(uuid, 0, ID_LEN);
-	strcat(uuid, "POOL0000000000");
-
-	/* We grab the entire 64 bits (+2 that get shifted in) */
-	for (i = 13; i < 24; i++) {
-		uuid[i] = _calc_char(((unsigned) poolid) & shifter);
-		poolid = poolid >> 6;
-	}
-
-	/* We grab the entire 32 bits (+4 that get shifted in) */
-	for (i = 24; i < 30; i++) {
-		uuid[i] = _calc_char((unsigned) (spid & shifter));
-		spid = spid >> 6;
-	}
-
-	/*
-	 * Since we can only have 128 devices, we only worry about the
-	 * last 12 bits
-	 */
-	for (i = 30; i < 32; i++) {
-		uuid[i] = _calc_char((unsigned) (devid & shifter));
-		devid = devid >> 6;
-	}
-
-}
-
-struct _read_pool_pv_baton {
-	const struct format_type *fmt;
-	struct dm_pool *mem, *tmpmem;
-	struct pool_list *pl;
-	struct dm_list *head;
-	const char *vgname;
-	uint32_t *sp_devs;
-	uint32_t sp_count;
-	int failed;
-	int empty;
-};
-
-static int _read_pool_pv(struct lvmcache_info *info, void *baton)
-{
-	struct _read_pool_pv_baton *b = baton;
-
-	b->empty = 0;
-
-	if (lvmcache_device(info) &&
-	    !(b->pl = read_pool_disk(b->fmt, lvmcache_device(info), b->mem, b->vgname)))
-		return 0;
-
-	/*
-	 * We need to keep track of the total expected number
-	 * of devices per subpool
-	 */
-	if (!b->sp_count) {
-		/* FIXME pl left uninitialised if !info->dev */
-		if (!b->pl) {
-			log_error(INTERNAL_ERROR "device is missing");
-			dm_pool_destroy(b->tmpmem);
-			b->failed = 1;
-			return 0;
-		}
-		b->sp_count = b->pl->pd.pl_subpools;
-		if (!(b->sp_devs =
-		      dm_pool_zalloc(b->tmpmem,
-				     sizeof(uint32_t) * b->sp_count))) {
-			log_error("Unable to allocate %d 32-bit uints",
-				  b->sp_count);
-			dm_pool_destroy(b->tmpmem);
-			b->failed = 1;
-			return 0;
-		}
-	}
-
-	/*
-	 * watch out for a pool label with a different subpool
-	 * count than the original - give up if it does
-	 */
-	if (b->sp_count != b->pl->pd.pl_subpools)
-		return 0;
-
-	_add_pl_to_list(lvmcache_fmt(info)->cmd, b->head, b->pl);
-
-	if (b->sp_count > b->pl->pd.pl_sp_id && b->sp_devs[b->pl->pd.pl_sp_id] == 0)
-		b->sp_devs[b->pl->pd.pl_sp_id] = b->pl->pd.pl_sp_devs;
-
-	return 1;
-}
-
-static int _read_vg_pds(struct _read_pool_pv_baton *b,
-			struct lvmcache_vginfo *vginfo,
-			uint32_t *devcount)
-{
-	uint32_t i;
-
-	b->sp_count = 0;
-	b->sp_devs = NULL;
-	b->failed = 0;
-	b->pl = NULL;
-
-	/* FIXME: maybe should return a different error in memory
-	 * allocation failure */
-	if (!(b->tmpmem = dm_pool_create("pool read_vg", 512)))
-		return_0;
-
-	lvmcache_foreach_pv(vginfo, _read_pool_pv, b);
-
-	*devcount = 0;
-	for (i = 0; i < b->sp_count; i++)
-		*devcount += b->sp_devs[i];
-
-	dm_pool_destroy(b->tmpmem);
-
-	if (b->pl && *b->pl->pd.pl_pool_name)
-		return 1;
-
-	return 0;
-
-}
-
-int read_pool_pds(const struct format_type *fmt, const char *vg_name,
-		  struct dm_pool *mem, struct dm_list *pdhead)
-{
-	struct lvmcache_vginfo *vginfo;
-	uint32_t totaldevs;
-	int full_scan = -1;
-
-	struct _read_pool_pv_baton baton;
-
-	baton.vgname = vg_name;
-	baton.mem = mem;
-	baton.fmt = fmt;
-	baton.head = pdhead;
-	baton.empty = 1;
-
-	do {
-		/*
-		 * If the cache scanning doesn't work, this will never work
-		 */
-		if (vg_name && (vginfo = lvmcache_vginfo_from_vgname(vg_name, NULL)) &&
-		    _read_vg_pds(&baton, vginfo, &totaldevs) && !baton.empty)
-		{
-			/*
-			 * If we found all the devices we were expecting, return
-			 * success
-			 */
-			if (dm_list_size(pdhead) == totaldevs)
-				return 1;
-
-			/*
-			 * accept partial pool if we've done a full rescan of
-			 * the cache
-			 */
-			if (full_scan > 0)
-				return 1;
-		}
-
-		/* Failed */
-		dm_list_init(pdhead);
-
-		full_scan++;
-		if (full_scan > 1) {
-			log_debug_metadata("No devices for vg %s found in cache",
-					   vg_name);
-			return 0;
-		}
-		lvmcache_label_scan(fmt->cmd);
-
-	} while (1);
-
-}
-
-struct pool_list *read_pool_disk(const struct format_type *fmt,
-				 struct device *dev, struct dm_pool *mem,
-				 const char *vg_name)
-{
-	struct pool_list *pl;
-
-	if (!dev_open_readonly(dev))
-		return_NULL;
-
-	if (!(pl = dm_pool_zalloc(mem, sizeof(*pl)))) {
-		log_error("Unable to allocate pool list structure");
-		return 0;
-	}
-
-	if (!__read_pool_disk(fmt, dev, mem, pl, vg_name))
-		return_NULL;
-
-	if (!dev_close(dev))
-		stack;
-
-	return pl;
-
-}
diff --git a/lib/format_pool/disk_rep.h b/lib/format_pool/disk_rep.h
deleted file mode 100644
index 37e942e..0000000
--- a/lib/format_pool/disk_rep.h
+++ /dev/null
@@ -1,156 +0,0 @@
-/*
- * Copyright (C) 1997-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
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
-#ifndef DISK_REP_FORMAT_POOL_H
-#define DISK_REP_FORMAT_POOL_H
-
-#include "label.h"
-#include "metadata.h"
-
-#define MINOR_OFFSET 65536
-
-/* From NSP.cf */
-#define NSPMajorVersion	4
-#define NSPMinorVersion	1
-#define NSPUpdateLevel	3
-
-/* From pool_std.h */
-#define POOL_NAME_SIZE          (256)
-#define POOL_MAGIC 		0x011670
-#define POOL_MAJOR              (121)
-#define POOL_MAX_DEVICES 	128
-
-/* When checking for version matching, the first two numbers **
-** are important for metadata formats, a.k.a pool labels.   **
-** All the numbers are important when checking if the user  **
-** space tools match up with the kernel module............. */
-#define POOL_VERSION		(NSPMajorVersion << 16 | \
-				 NSPMinorVersion <<  8 | \
-				 NSPUpdateLevel)
-
-/* Pool label is@the head of every pool disk partition */
-#define SIZEOF_POOL_LABEL       (8192)
-
-/* in sectors */
-#define POOL_PE_SIZE     (SIZEOF_POOL_LABEL >> SECTOR_SHIFT)
-#define POOL_PE_START    (SIZEOF_POOL_LABEL >> SECTOR_SHIFT)
-
-/* Helper fxns */
-#define get_pool_vg_uuid(id, pd) do { get_pool_uuid((char *)(id), \
-                                                    (pd)->pl_pool_id, 0, 0); \
-                                    } while(0)
-#define get_pool_pv_uuid(id, pd) do { get_pool_uuid((char *)(id), \
-                                                    (pd)->pl_pool_id, \
-                                                    (pd)->pl_sp_id, \
-                                                    (pd)->pl_sp_devid); \
-                                    } while(0)
-#define get_pool_lv_uuid(id, pd) do { get_pool_uuid((char *)&(id)[0], \
-                                                    (pd)->pl_pool_id, 0, 0); \
-                                      get_pool_uuid((char*)&(id)[1], \
-                                                    (pd)->pl_pool_id, 0, 0); \
-                                    } while(0)
-
-struct pool_disk;
-struct pool_list;
-struct user_subpool;
-struct user_device;
-
-struct pool_disk {
-	uint64_t pl_magic;	/* Pool magic number */
-	uint64_t pl_pool_id;	/* Unique pool identifier */
-	char pl_pool_name[POOL_NAME_SIZE];	/* Name of pool */
-	uint32_t pl_version;	/* Pool version */
-	uint32_t pl_subpools;	/* Number of subpools in this pool */
-	uint32_t pl_sp_id;	/* Subpool number within pool */
-	uint32_t pl_sp_devs;	/* Number of data partitions in this subpool */
-	uint32_t pl_sp_devid;	/* Partition number within subpool */
-	uint32_t pl_sp_type;	/* Partition type */
-	uint64_t pl_blocks;	/* Number of blocks in this partition */
-	uint32_t pl_striping;	/* Striping size within subpool */
-	/*
-	 * If the number of DMEP devices is zero, then the next field **
-	 * ** (pl_sp_dmepid) becomes the subpool ID for redirection.  In **
-	 * ** other words, if this subpool does not have the capability  **
-	 * ** to do DMEP, then it must specify which subpool will do it  **
-	 * ** in it's place
-	 */
-
-	/*
-	 * While the next 3 field are no longer used, they must stay to keep **
-	 * ** backward compatibility...........................................
-	 */
-	uint32_t pl_sp_dmepdevs;/* Number of dmep devices in this subpool */
-	uint32_t pl_sp_dmepid;	/* Dmep device number within subpool */
-	uint32_t pl_sp_weight;	/* if dmep dev, pref to using it */
-
-	uint32_t pl_minor;	/* the pool minor number */
-	uint32_t pl_padding;	/* reminder - think about alignment */
-
-	/*
-	 * Even though we're zeroing out 8k at the front of the disk before
-	 * writing the label, putting this in
-	 */
-	char pl_reserve[184];	/* bump the structure size out to 512 bytes */
-};
-
-struct pool_list {
-	struct dm_list list;
-	struct pool_disk pd;
-	struct physical_volume *pv;
-	struct id pv_uuid;
-	struct device *dev;
-};
-
-struct user_subpool {
-	uint32_t initialized;
-	uint32_t id;
-	uint32_t striping;
-	uint32_t num_devs;
-	uint32_t type;
-	uint32_t dummy;
-	struct user_device *devs;
-};
-
-struct user_device {
-	uint32_t initialized;
-	uint32_t sp_id;
-	uint32_t devid;
-	uint32_t dummy;
-	uint64_t blocks;
-	struct physical_volume *pv;
-};
-
-int read_pool_label(struct pool_list *pl, struct labeller *l,
-		    struct device *dev, char *buf, struct label **label);
-void pool_label_out(struct pool_disk *pl, void *buf);
-void pool_label_in(struct pool_disk *pl, void *buf);
-void get_pool_uuid(char *uuid, uint64_t poolid, uint32_t spid, uint32_t devid);
-int import_pool_vg(struct volume_group *vg, struct dm_pool *mem, struct dm_list *pls);
-int import_pool_lvs(struct volume_group *vg, struct dm_pool *mem,
-		    struct dm_list *pls);
-int import_pool_pvs(const struct format_type *fmt, struct volume_group *vg,
-		    struct dm_pool *mem, struct dm_list *pls);
-int import_pool_pv(const struct format_type *fmt, struct dm_pool *mem,
-		   struct volume_group *vg, struct physical_volume *pv,
-		   struct pool_list *pl);
-int import_pool_segments(struct dm_list *lvs, struct dm_pool *mem,
-			 struct user_subpool *usp, int sp_count);
-int read_pool_pds(const struct format_type *fmt, const char *vgname,
-		  struct dm_pool *mem, struct dm_list *head);
-struct pool_list *read_pool_disk(const struct format_type *fmt,
-				 struct device *dev, struct dm_pool *mem,
-				 const char *vg_name);
-
-#endif				/* DISK_REP_POOL_FORMAT_H */
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
deleted file mode 100644
index f6e5e01..0000000
--- a/lib/format_pool/format_pool.c
+++ /dev/null
@@ -1,338 +0,0 @@
-/*
- * Copyright (C) 1997-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
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
-#include "lib.h"
-#include "label.h"
-#include "metadata.h"
-#include "limits.h"
-#include "display.h"
-#include "toolcontext.h"
-#include "lvmcache.h"
-#include "disk_rep.h"
-#include "format_pool.h"
-#include "pool_label.h"
-
-/* Must be called after pvs are imported */
-static struct user_subpool *_build_usp(struct dm_list *pls, struct dm_pool *mem,
-				       int *sps)
-{
-	struct pool_list *pl;
-	struct user_subpool *usp = NULL, *cur_sp = NULL;
-	struct user_device *cur_dev = NULL;
-
-	/*
-	 * FIXME: Need to do some checks here - I'm tempted to add a
-	 * user_pool structure and build the entire thing to check against.
-	 */
-	dm_list_iterate_items(pl, pls) {
-		*sps = pl->pd.pl_subpools;
-		if (!usp && (!(usp = dm_pool_zalloc(mem, sizeof(*usp) * (*sps))))) {
-			log_error("Unable to allocate %d subpool structures",
-				  *sps);
-			return 0;
-		}
-
-		if (cur_sp != &usp[pl->pd.pl_sp_id]) {
-			cur_sp = &usp[pl->pd.pl_sp_id];
-
-			cur_sp->id = pl->pd.pl_sp_id;
-			cur_sp->striping = pl->pd.pl_striping;
-			cur_sp->num_devs = pl->pd.pl_sp_devs;
-			cur_sp->type = pl->pd.pl_sp_type;
-			cur_sp->initialized = 1;
-		}
-
-		if (!cur_sp->devs &&
-		    (!(cur_sp->devs =
-		       dm_pool_zalloc(mem,
-				   sizeof(*usp->devs) * pl->pd.pl_sp_devs)))) {
-
-			log_error("Unable to allocate %d pool_device "
-				  "structures", pl->pd.pl_sp_devs);
-			return 0;
-		}
-
-		cur_dev = &cur_sp->devs[pl->pd.pl_sp_devid];
-		cur_dev->sp_id = cur_sp->id;
-		cur_dev->devid = pl->pd.pl_sp_id;
-		cur_dev->blocks = pl->pd.pl_blocks;
-		cur_dev->pv = pl->pv;
-		cur_dev->initialized = 1;
-	}
-
-	return usp;
-}
-
-static int _check_usp(const char *vgname, struct user_subpool *usp, int sp_count)
-{
-	int i;
-	unsigned j;
-
-	for (i = 0; i < sp_count; i++) {
-		if (!usp[i].initialized) {
-			log_error("Missing subpool %d in pool %s", i, vgname);
-			return 0;
-		}
-		for (j = 0; j < usp[i].num_devs; j++) {
-			if (!usp[i].devs[j].initialized) {
-				log_error("Missing device %u for subpool %d"
-					  " in pool %s", j, i, vgname);
-				return 0;
-			}
-
-		}
-	}
-
-	return 1;
-}
-
-static struct volume_group *_pool_vg_read(struct format_instance *fid,
-					  const char *vg_name,
-					  struct metadata_area *mda __attribute__((unused)),
-					  struct cached_vg_fmtdata **vg_fmtdata __attribute__((unused)),
-					  unsigned *use_previous_vg __attribute__((unused)),
-					  int single_device __attribute__((unused)))
-{
-	struct volume_group *vg;
-	struct user_subpool *usp;
-	int sp_count;
-	DM_LIST_INIT(pds);
-
-	/* We can safely ignore the mda passed in */
-
-	/* Strip dev_dir if present */
-	if (vg_name)
-		vg_name = strip_dir(vg_name, fid->fmt->cmd->dev_dir);
-
-	/* Set vg_name through read_pool_pds() */
-	if (!(vg = alloc_vg("pool_vg_read", fid->fmt->cmd, NULL)))
-		return_NULL;
-
-	/* Read all the pvs in the vg */
-	if (!read_pool_pds(fid->fmt, vg_name, vg->vgmem, &pds))
-		goto_bad;
-
-	/* Setting pool seqno to 1 because the code always did this,
-	 * although we don't think it's needed. */
-	vg->seqno = 1;
-
-	if (!import_pool_vg(vg, vg->vgmem, &pds))
-		goto_bad;
-
-	if (!import_pool_pvs(fid->fmt, vg, vg->vgmem, &pds))
-		goto_bad;
-
-	if (!import_pool_lvs(vg, vg->vgmem, &pds))
-		goto_bad;
-
-	/*
-	 * I need an intermediate subpool structure that contains all the
-	 * relevant info for this.  Then i can iterate through the subpool
-	 * structures for checking, and create the segments
-	 */
-	if (!(usp = _build_usp(&pds, vg->vgmem, &sp_count)))
-		goto_bad;
-
-	/*
-	 * check the subpool structures - we can't handle partial VGs in
-	 * the pool format, so this will error out if we're missing PVs
-	 */
-	if (!_check_usp(vg->name, usp, sp_count))
-		goto_bad;
-
-	if (!import_pool_segments(&vg->lvs, vg->vgmem, usp, sp_count))
-		goto_bad;
-
-	vg_set_fid(vg, fid);
-
-	return vg;
-
-bad:
-	release_vg(vg);
-
-	return NULL;
-}
-
-static int _pool_pv_initialise(const struct format_type *fmt __attribute__((unused)),
-			       struct pv_create_args *pva __attribute__((unused)),
-			       struct physical_volume *pv __attribute__((unused)))
-{
-	return 1;
-}
-
-static int _pool_pv_setup(const struct format_type *fmt __attribute__((unused)),
-			  struct physical_volume *pv __attribute__((unused)),
-			  struct volume_group *vg __attribute__((unused)))
-{
-	return 1;
-}
-
-static int _pool_pv_read(const struct format_type *fmt, const char *pv_name,
-			 struct physical_volume *pv,
-			 int scan_label_only __attribute__((unused)))
-{
-	struct dm_pool *mem = dm_pool_create("pool pv_read", 1024);
-	struct pool_list *pl;
-	struct device *dev;
-	int r = 0;
-
-	log_very_verbose("Reading physical volume data %s from disk", pv_name);
-
-	if (!mem)
-		return_0;
-
-	if (!(dev = dev_cache_get(pv_name, fmt->cmd->filter)))
-		goto_out;
-
-	/*
-	 * I need to read the disk and populate a pv structure here
-	 * I'll probably need to abstract some of this later for the
-	 * vg_read code
-	 */
-	if (!(pl = read_pool_disk(fmt, dev, mem, NULL)))
-		goto_out;
-
-	if (!import_pool_pv(fmt, fmt->cmd->mem, NULL, pv, pl))
-		goto_out;
-
-	pv->fmt = fmt;
-
-	r = 1;
-
-      out:
-	dm_pool_destroy(mem);
-	return r;
-}
-
-/* *INDENT-OFF* */
-static struct metadata_area_ops _metadata_format_pool_ops = {
-	.vg_read = _pool_vg_read,
-};
-/* *INDENT-ON* */
-
-static struct format_instance *_pool_create_instance(const struct format_type *fmt,
-						     const struct format_instance_ctx *fic)
-{
-	struct format_instance *fid;
-	struct metadata_area *mda;
-
-	if (!(fid = alloc_fid(fmt, fic)))
-		return_NULL;
-
-	/* Define a NULL metadata area */
-	if (!(mda = dm_pool_zalloc(fid->mem, sizeof(*mda)))) {
-		log_error("Unable to allocate metadata area structure "
-			  "for pool format");
-		goto bad;
-	}
-
-	mda->ops = &_metadata_format_pool_ops;
-	mda->metadata_locn = NULL;
-	mda->status = 0;
-	dm_list_add(&fid->metadata_areas_in_use, &mda->list);
-
-	return fid;
-
-bad:
-	dm_pool_destroy(fid->mem);
-	return NULL;
-}
-
-static void _pool_destroy_instance(struct format_instance *fid)
-{
-	if (--fid->ref_count <= 1)
-		dm_pool_destroy(fid->mem);
-}
-
-static void _pool_destroy(struct format_type *fmt)
-{
-	if (fmt->orphan_vg)
-		free_orphan_vg(fmt->orphan_vg);
-
-	dm_free(fmt);
-}
-
-/* *INDENT-OFF* */
-static struct format_handler _format_pool_ops = {
-	.pv_read = _pool_pv_read,
-	.pv_initialise = _pool_pv_initialise,
-	.pv_setup = _pool_pv_setup,
-	.create_instance = _pool_create_instance,
-	.destroy_instance = _pool_destroy_instance,
-	.destroy = _pool_destroy,
-};
-/* *INDENT-ON */
-
-#ifdef POOL_INTERNAL
-struct format_type *init_pool_format(struct cmd_context *cmd)
-#else				/* Shared */
-struct format_type *init_format(struct cmd_context *cmd);
-struct format_type *init_format(struct cmd_context *cmd)
-#endif
-{
-	struct format_type *fmt = dm_malloc(sizeof(*fmt));
-	struct format_instance_ctx fic;
-	struct format_instance *fid;
-
-	if (!fmt) {
-		log_error("Unable to allocate format type structure for pool "
-			  "format");
-		return NULL;
-	}
-
-	fmt->cmd = cmd;
-	fmt->ops = &_format_pool_ops;
-	fmt->name = FMT_POOL_NAME;
-	fmt->alias = NULL;
-	fmt->orphan_vg_name = FMT_POOL_ORPHAN_VG_NAME;
-	fmt->features = FMT_OBSOLETE;
-	fmt->private = NULL;
-
-	dm_list_init(&fmt->mda_ops);
-
-	if (!(fmt->labeller = pool_labeller_create(fmt))) {
-		log_error("Couldn't create pool label handler.");
-		dm_free(fmt);
-		return NULL;
-	}
-
-	if (!(label_register_handler(fmt->labeller))) {
-		log_error("Couldn't register pool label handler.");
-		fmt->labeller->ops->destroy(fmt->labeller);
-		dm_free(fmt);
-		return NULL;
-	}
-
-	if (!(fmt->orphan_vg = alloc_vg("pool_orphan", cmd, fmt->orphan_vg_name))) {
-		log_error("Couldn't create pool orphan VG.");
-		dm_free(fmt);
-		return NULL;
-	}
-
-	fic.type = FMT_INSTANCE_AUX_MDAS;
-	fic.context.vg_ref.vg_name = fmt->orphan_vg_name;
-	fic.context.vg_ref.vg_id = NULL;
-
-	if (!(fid = _pool_create_instance(fmt, &fic))) {
-		_pool_destroy(fmt);
-		return NULL;
-	}
-
-	vg_set_fid(fmt->orphan_vg, fid);
-
-	log_very_verbose("Initialised format: %s", fmt->name);
-
-	return fmt;
-}
diff --git a/lib/format_pool/format_pool.h b/lib/format_pool/format_pool.h
deleted file mode 100644
index 8ad7eb5..0000000
--- a/lib/format_pool/format_pool.h
+++ /dev/null
@@ -1,28 +0,0 @@
-/*
- * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
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
-#ifndef _LVM_FORMAT_POOL_H
-#define _LVM_FORMAT_POOL_H
-
-#include "metadata.h"
-
-#define FMT_POOL_NAME "pool"
-#define FMT_POOL_ORPHAN_VG_NAME ORPHAN_VG_NAME(FMT_POOL_NAME)
-
-#ifdef POOL_INTERNAL
-struct format_type *init_pool_format(struct cmd_context *cmd);
-#endif
-
-#endif
diff --git a/lib/format_pool/import_export.c b/lib/format_pool/import_export.c
deleted file mode 100644
index f4097a7..0000000
--- a/lib/format_pool/import_export.c
+++ /dev/null
@@ -1,285 +0,0 @@
-/*
- * Copyright (C) 1997-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
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
-#include "lib.h"
-#include "label.h"
-#include "metadata.h"
-#include "disk_rep.h"
-#include "sptype_names.h"
-#include "lv_alloc.h"
-#include "pv_alloc.h"
-#include "str_list.h"
-#include "display.h"
-#include "segtype.h"
-#include "toolcontext.h"
-
-/* This file contains only imports at the moment... */
-
-int import_pool_vg(struct volume_group *vg, struct dm_pool *mem, struct dm_list *pls)
-{
-	struct pool_list *pl;
-
-	dm_list_iterate_items(pl, pls) {
-		vg->extent_count +=
-		    ((pl->pd.pl_blocks) / POOL_PE_SIZE);
-
-		vg->free_count = vg->extent_count;
-
-		if (vg->name)
-			continue;
-
-		vg->name = dm_pool_strdup(mem, pl->pd.pl_pool_name);
-		get_pool_vg_uuid(&vg->id, &pl->pd);
-		vg->extent_size = POOL_PE_SIZE;
-		vg->status |= LVM_READ | LVM_WRITE | CLUSTERED | SHARED;
-		vg->max_lv = 1;
-		vg->max_pv = POOL_MAX_DEVICES;
-		vg->alloc = ALLOC_NORMAL;
-	}
-
-	return 1;
-}
-
-int import_pool_lvs(struct volume_group *vg, struct dm_pool *mem, struct dm_list *pls)
-{
-	struct pool_list *pl;
-	struct logical_volume *lv;
-
-	if (!(lv = alloc_lv(mem)))
-		return_0;
-
-	lv->status = 0;
-	lv->alloc = ALLOC_NORMAL;
-	lv->size = 0;
-	lv->name = NULL;
-	lv->le_count = 0;
-	lv->read_ahead = vg->cmd->default_settings.read_ahead;
-
-	dm_list_iterate_items(pl, pls) {
-		lv->size += pl->pd.pl_blocks;
-
-		if (lv->name)
-			continue;
-
-		if (!(lv->name = dm_pool_strdup(mem, pl->pd.pl_pool_name)))
-			return_0;
-
-		get_pool_lv_uuid(lv->lvid.id, &pl->pd);
-		log_debug_metadata("Calculated lv uuid for lv %s: %s", lv->name,
-				   lv->lvid.s);
-
-		lv->status |= VISIBLE_LV | LVM_READ | LVM_WRITE;
-		lv->major = POOL_MAJOR;
-
-		/* for pool a minor of 0 is dynamic */
-		if (pl->pd.pl_minor) {
-			lv->status |= FIXED_MINOR;
-			lv->minor = pl->pd.pl_minor + MINOR_OFFSET;
-		} else {
-			lv->minor = -1;
-		}
-	}
-
-	lv->le_count = lv->size / POOL_PE_SIZE;
-
-	return link_lv_to_vg(vg, lv);
-}
-
-int import_pool_pvs(const struct format_type *fmt, struct volume_group *vg,
-		    struct dm_pool *mem, struct dm_list *pls)
-{
-	struct pv_list *pvl;
-	struct pool_list *pl;
-
-	dm_list_iterate_items(pl, pls) {
-		if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl)))) {
-			log_error("Unable to allocate pv list structure");
-			return 0;
-		}
-		if (!(pvl->pv = dm_pool_zalloc(mem, sizeof(*pvl->pv)))) {
-			log_error("Unable to allocate pv structure");
-			return 0;
-		}
-		if (!import_pool_pv(fmt, mem, vg, pvl->pv, pl)) {
-			return 0;
-		}
-		pl->pv = pvl->pv;
-		pvl->mdas = NULL;
-		pvl->pe_ranges = NULL;
-		add_pvl_to_vgs(vg, pvl);
-	}
-
-	return 1;
-}
-
-int import_pool_pv(const struct format_type *fmt, struct dm_pool *mem,
-		   struct volume_group *vg, struct physical_volume *pv,
-		   struct pool_list *pl)
-{
-	struct pool_disk *pd = &pl->pd;
-
-	memset(pv, 0, sizeof(*pv));
-
-	get_pool_pv_uuid(&pv->id, pd);
-	pv->fmt = fmt;
-
-	pv->dev = pl->dev;
-	if (!(pv->vg_name = dm_pool_strdup(mem, pd->pl_pool_name))) {
-		log_error("Unable to duplicate vg_name string");
-		return 0;
-	}
-	if (vg != NULL)
-		memcpy(&pv->vgid, &vg->id, sizeof(vg->id));
-	pv->status = 0;
-	pv->size = pd->pl_blocks;
-	pv->pe_size = POOL_PE_SIZE;
-	pv->pe_start = POOL_PE_START;
-	pv->pe_count = pv->size / POOL_PE_SIZE;
-	pv->pe_alloc_count = 0;
-	pv->pe_align = 0;
-
-	dm_list_init(&pv->tags);
-	dm_list_init(&pv->segments);
-
-	if (!alloc_pv_segment_whole_pv(mem, pv))
-		return_0;
-
-	return 1;
-}
-
-static const char *_cvt_sptype(uint32_t sptype)
-{
-	int i;
-	for (i = 0; sptype_names[i].name[0]; i++) {
-		if (sptype == sptype_names[i].label) {
-			break;
-		}
-	}
-	log_debug_metadata("Found sptype %X and converted it to %s",
-			   sptype, sptype_names[i].name);
-	return sptype_names[i].name;
-}
-
-static int _add_stripe_seg(struct dm_pool *mem,
-			   struct user_subpool *usp, struct logical_volume *lv,
-			   uint32_t *le_cur)
-{
-	struct lv_segment *seg;
-	struct segment_type *segtype;
-	unsigned j;
-	uint32_t area_len;
-
-	if (!is_power_of_2(usp->striping)) {
-		log_error("Stripe size must be a power of 2");
-		return 0;
-	}
-
-	area_len = (usp->devs[0].blocks) / POOL_PE_SIZE;
-
-	if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
-		return_0;
-
-	if (!(seg = alloc_lv_segment(segtype, lv, *le_cur,
-				     area_len * usp->num_devs, 0, 0,
-				     usp->striping, NULL, usp->num_devs,
-				     area_len, 0, 0, 0, 0, NULL))) {
-		log_error("Unable to allocate striped lv_segment structure");
-		return 0;
-	}
-
-	for (j = 0; j < usp->num_devs; j++)
-		if (!set_lv_segment_area_pv(seg, j, usp->devs[j].pv, 0))
-			return_0;
-
-	/* add the subpool type to the segment tag list */
-	if (!str_list_add(mem, &seg->tags, _cvt_sptype(usp->type))) {
-		log_error("Allocation failed for str_list.");
-		return 0;
-	}
-
-	dm_list_add(&lv->segments, &seg->list);
-
-	*le_cur += seg->len;
-
-	return 1;
-}
-
-static int _add_linear_seg(struct dm_pool *mem,
-			   struct user_subpool *usp, struct logical_volume *lv,
-			   uint32_t *le_cur)
-{
-	struct lv_segment *seg;
-	struct segment_type *segtype;
-	unsigned j;
-	uint32_t area_len;
-
-	if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_STRIPED)))
-		return_0;
-
-	for (j = 0; j < usp->num_devs; j++) {
-		area_len = (usp->devs[j].blocks) / POOL_PE_SIZE;
-
-		if (!(seg = alloc_lv_segment(segtype, lv, *le_cur,
-					     area_len, 0, 0, usp->striping,
-					     NULL, 1, area_len, 0,
-					     POOL_PE_SIZE, 0, 0, NULL))) {
-			log_error("Unable to allocate linear lv_segment "
-				  "structure");
-			return 0;
-		}
-
-		/* add the subpool type to the segment tag list */
-		if (!str_list_add(mem, &seg->tags, _cvt_sptype(usp->type))) {
-			log_error("Allocation failed for str_list.");
-			return 0;
-		}
-
-		if (!set_lv_segment_area_pv(seg, 0, usp->devs[j].pv, 0))
-			return_0;
-		dm_list_add(&lv->segments, &seg->list);
-
-		*le_cur += seg->len;
-	}
-
-	return 1;
-}
-
-int import_pool_segments(struct dm_list *lvs, struct dm_pool *mem,
-			 struct user_subpool *usp, int subpools)
-{
-	struct lv_list *lvl;
-	struct logical_volume *lv;
-	uint32_t le_cur = 0;
-	int i;
-
-	dm_list_iterate_items(lvl, lvs) {
-		lv = lvl->lv;
-
-		if (lv_is_snapshot(lv))
-			continue;
-
-		for (i = 0; i < subpools; i++) {
-			if (usp[i].striping) {
-				if (!_add_stripe_seg(mem, &usp[i], lv, &le_cur))
-					return_0;
-			} else {
-				if (!_add_linear_seg(mem, &usp[i], lv, &le_cur))
-					return_0;
-			}
-		}
-	}
-
-	return 1;
-}
diff --git a/lib/format_pool/pool_label.c b/lib/format_pool/pool_label.c
deleted file mode 100644
index 2e30a7b..0000000
--- a/lib/format_pool/pool_label.c
+++ /dev/null
@@ -1,104 +0,0 @@
-/*
- * Copyright (C) 1997-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
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
-#include "lib.h"
-#include "label.h"
-#include "metadata.h"
-#include "disk_rep.h"
-#include "pool_label.h"
-
-#include <sys/stat.h>
-#include <fcntl.h>
-
-static void _pool_not_supported(const char *op)
-{
-	log_error("The '%s' operation is not supported for the pool labeller.",
-		  op);
-}
-
-static int _pool_can_handle(struct labeller *l __attribute__((unused)), void *buf, uint64_t sector)
-{
-
-	struct pool_disk pd;
-
-	/*
-	 * POOL label must always be in first sector
-	 */
-	if (sector)
-		return 0;
-
-	pool_label_in(&pd, buf);
-
-	/* can ignore 8 rightmost bits for ondisk format check */
-	if ((pd.pl_magic == POOL_MAGIC) &&
-	    (pd.pl_version >> 8 == POOL_VERSION >> 8))
-		return 1;
-
-	return 0;
-}
-
-static int _pool_write(struct label *label __attribute__((unused)), void *buf __attribute__((unused)))
-{
-	_pool_not_supported("write");
-	return 0;
-}
-
-static int _pool_read(struct labeller *l, struct device *dev, void *buf,
-		 struct label **label)
-{
-	struct pool_list pl;
-
-	return read_pool_label(&pl, l, dev, buf, label);
-}
-
-static int _pool_initialise_label(struct labeller *l __attribute__((unused)), struct label *label)
-{
-	strcpy(label->type, "POOL");
-
-	return 1;
-}
-
-static void _pool_destroy_label(struct labeller *l __attribute__((unused)), struct label *label __attribute__((unused)))
-{
-}
-
-static void _label_pool_destroy(struct labeller *l)
-{
-	dm_free(l);
-}
-
-struct label_ops _pool_ops = {
-      .can_handle = _pool_can_handle,
-      .write = _pool_write,
-      .read = _pool_read,
-      .initialise_label = _pool_initialise_label,
-      .destroy_label = _pool_destroy_label,
-      .destroy = _label_pool_destroy,
-};
-
-struct labeller *pool_labeller_create(struct format_type *fmt)
-{
-	struct labeller *l;
-
-	if (!(l = dm_malloc(sizeof(*l)))) {
-		log_error("Couldn't allocate labeller object.");
-		return NULL;
-	}
-
-	l->ops = &_pool_ops;
-	l->fmt = fmt;
-
-	return l;
-}
diff --git a/lib/format_pool/pool_label.h b/lib/format_pool/pool_label.h
deleted file mode 100644
index 1a529a4..0000000
--- a/lib/format_pool/pool_label.h
+++ /dev/null
@@ -1,23 +0,0 @@
-/*
- * Copyright (C) 1997-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
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
-#ifndef _LVM_POOL_LABEL_H
-#define _LVM_POOL_LABEL_H
-
-#include "metadata.h"
-
-struct labeller *pool_labeller_create(struct format_type *fmt);
-
-#endif
diff --git a/lib/format_pool/sptype_names.h b/lib/format_pool/sptype_names.h
deleted file mode 100644
index 5812adb..0000000
--- a/lib/format_pool/sptype_names.h
+++ /dev/null
@@ -1,42 +0,0 @@
-/*
- * Copyright (C) 1997-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
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
-#ifndef SPTYPE_NAMES_H
-#define SPTYPE_NAMES_H
-
-/* This must be kept up to date with sistina/pool/module/pool_sptypes.h */
-
-/*  Generic Labels  */
-#define SPTYPE_DATA                (0x00000000)
-
-/*  GFS specific labels  */
-#define SPTYPE_GFS_DATA            (0x68011670)
-#define SPTYPE_GFS_JOURNAL         (0x69011670)
-
-struct sptype_name {
-	const char *name;
-	uint32_t label;
-};
-
-static const struct sptype_name sptype_names[] = {
-	{"data",	SPTYPE_DATA},
-
-	{"gfs_data",	SPTYPE_GFS_DATA},
-	{"gfs_journal",	SPTYPE_GFS_JOURNAL},
-
-	{"", 0x0}		/*  This must be the last flag.  */
-};
-
-#endif
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index e535237..7866d56 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -467,8 +467,6 @@ static int _print_vg(struct formatter *f, struct volume_group *vg)
  
 	if (vg->system_id && *vg->system_id)
 		outf(f, "system_id = \"%s\"", vg->system_id);
-	else if (vg->lvm1_system_id && *vg->lvm1_system_id)
-		outf(f, "system_id = \"%s\"", vg->lvm1_system_id);
 
 	if (vg->lock_type) {
 		outf(f, "lock_type = \"%s\"", vg->lock_type);
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 792d75a..5c7b72f 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2545,9 +2545,9 @@ struct format_type *create_text_format(struct cmd_context *cmd)
 	fmt->name = FMT_TEXT_NAME;
 	fmt->alias = FMT_TEXT_ALIAS;
 	fmt->orphan_vg_name = ORPHAN_VG_NAME(FMT_TEXT_NAME);
-	fmt->features = FMT_SEGMENTS | FMT_MDAS | FMT_TAGS | FMT_PRECOMMIT |
+	fmt->features = FMT_SEGMENTS | FMT_TAGS | FMT_PRECOMMIT |
 			FMT_UNLIMITED_VOLS | FMT_RESIZE_PV |
-			FMT_UNLIMITED_STRIPESIZE | FMT_BAS | FMT_CONFIG_PROFILE |
+			FMT_UNLIMITED_STRIPESIZE | FMT_CONFIG_PROFILE |
 			FMT_NON_POWER2_EXTENTS | FMT_PV_FLAGS;
 
 	if (!(mda_lists = dm_malloc(sizeof(struct mda_lists)))) {
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index e038a27..58f517e 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -1084,15 +1084,8 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 		goto bad;
 	}
 
-	/*
-	 * A system id without WRITE_LOCKED is an old lvm1 system id.
-	 */
 	if (dm_config_get_str(vgn, "system_id", &system_id)) {
-		if (!(vgstatus & LVM_WRITE_LOCKED)) {
-			if (!(vg->lvm1_system_id = dm_pool_zalloc(vg->vgmem, NAME_LEN + 1)))
-				goto_bad;
-			strncpy(vg->lvm1_system_id, system_id, NAME_LEN);
-		} else if (!(vg->system_id = dm_pool_strdup(vg->vgmem, system_id))) {
+		if (!(vg->system_id = dm_pool_strdup(vg->vgmem, system_id))) {
 			log_error("Failed to allocate memory for system_id in _read_vg.");
 			goto bad;
 		}
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index f90bd2d..105419a 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -207,42 +207,6 @@ void fin_locking(void)
 }
 
 /*
- * Does the LVM1 driver know of this VG name?
- */
-int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname)
-{
-	struct stat info;
-	char path[PATH_MAX];
-
-	/* We'll allow operations on orphans */
-	if (!is_real_vg(vgname))
-		return 1;
-
-	/* LVM1 is only present in 2.4 kernels. */
-	if (strncmp(cmd->kernel_vsn, "2.4.", 4))
-		return 1;
-
-	if (dm_snprintf(path, sizeof(path), "%s/lvm/VGs/%s", cmd->proc_dir,
-			 vgname) < 0) {
-		log_error("LVM1 proc VG pathname too long for %s", vgname);
-		return 0;
-	}
-
-	if (stat(path, &info) == 0) {
-		log_error("%s exists: Is the original LVM driver using "
-			  "this volume group?", path);
-		return 0;
-	}
-
-	if (errno != ENOENT && errno != ENOTDIR) {
-		log_sys_error("stat", path);
-		return 0;
-	}
-
-	return 1;
-}
-
-/*
  * VG locking is by VG name.
  * FIXME This should become VG uuid.
  */
@@ -354,10 +318,6 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
 			lvmcache_drop_metadata(vol, 0);
 		}
 
-		/* Lock VG to change on-disk metadata. */
-		/* If LVM1 driver knows about the VG, it can't be accessed. */
-		if (!check_lvm1_vg_inactive(cmd, vol))
-			return_0;
 		break;
 	case LCK_LV:
 		/* All LV locks are non-blocking. */
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 7f9cf0b..8bf9379 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5976,8 +5976,6 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		     force_t force, int suppress_remove_message)
 {
 	struct volume_group *vg;
-	struct logical_volume *format1_origin = NULL;
-	int format1_reload_required = 0;
 	int visible, historical;
 	struct logical_volume *pool_lv = NULL;
 	struct logical_volume *lock_lv = lv;
@@ -6130,10 +6128,6 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 
 	if (lv_is_cow(lv)) {
-		/* Old format1 code */
-		if (!(lv->vg->fid->fmt->features & FMT_MDAS))
-			format1_origin = origin_from_cow(lv);
-
 		log_verbose("Removing snapshot volume %s.", display_lvname(lv));
 		/* vg_remove_snapshot() will preload origin/former snapshots */
 		if (!vg_remove_snapshot(lv))
@@ -6189,30 +6183,10 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
-	/*
-	 * Old format1 code: If no snapshots left reload without -real.
-	 */
-	if (format1_origin && !lv_is_origin(format1_origin)) {
-		log_warn("WARNING: Support for snapshots with old LVM1-style metadata is deprecated.");
-		log_warn("WARNING: Please use lvconvert to update to lvm2 metadata at your convenience.");
-		format1_reload_required = 1;
-	}
-
 	/* store it on disks */
 	if (!vg_write(vg) || !vg_commit(vg))
 		return_0;
 
-	/* format1 */
-	if (format1_reload_required) {
-		if (!suspend_lv(cmd, format1_origin))
-			log_error("Failed to refresh %s without snapshot.", format1_origin->name);
-
-		if (!resume_lv(cmd, format1_origin)) {
-			log_error("Failed to resume %s.", format1_origin->name);
-			return 0;
-		}
-	}
-
 	/* Release unneeded blocks in thin pool */
 	/* TODO: defer when multiple LVs relased at once */
 	if (pool_lv && !update_pool_lv(pool_lv, 1)) {
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index e8ecfd6..120dbb0 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -149,7 +149,7 @@
 
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
-#define FMT_MDAS		0x00000002U	/* Proper metadata areas? */
+// #define FMT_MDAS		0x00000002U	/* Proper metadata areas? */
 #define FMT_TAGS		0x00000004U	/* Tagging? */
 #define FMT_UNLIMITED_VOLS	0x00000008U	/* Unlimited PVs/LVs? */
 #define FMT_RESTRICTED_LVIDS	0x00000010U	/* LVID <= 255 */
@@ -158,15 +158,13 @@
 #define FMT_RESIZE_PV		0x00000080U	/* Supports pvresize? */
 #define FMT_UNLIMITED_STRIPESIZE 0x00000100U	/* Unlimited stripe size? */
 #define FMT_RESTRICTED_READAHEAD 0x00000200U	/* Readahead restricted to 2-120? */
-#define FMT_BAS			0x000000400U	/* Supports bootloader areas? */
+// #define FMT_BAS			0x000000400U	/* Supports bootloader areas? */
 #define FMT_CONFIG_PROFILE	0x000000800U	/* Supports configuration profiles? */
-#define FMT_OBSOLETE		0x000001000U	/* Obsolete format? */
+// #define FMT_OBSOLETE		0x000001000U	/* Obsolete format? */
 #define FMT_NON_POWER2_EXTENTS	0x000002000U	/* Non-power-of-2 extent sizes? */
-#define FMT_SYSTEMID_ON_PVS	0x000004000U	/* System ID is stored on PVs not VG */
+// #define FMT_SYSTEMID_ON_PVS	0x000004000U	/* System ID is stored on PVs not VG */
 #define FMT_PV_FLAGS		0x000008000U	/* Supports PV flags */
 
-#define systemid_on_pvs(vg)	((vg)->fid->fmt->features & FMT_SYSTEMID_ON_PVS)
-
 /* Mirror conversion type flags */
 #define MIRROR_BY_SEG		0x00000001U	/* segment-by-segment mirror */
 #define MIRROR_BY_LV		0x00000002U	/* mirror using whole mimage LVs */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5e376f3..d65daaf 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1011,8 +1011,6 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
 
 	vg->status = (RESIZEABLE_VG | LVM_READ | LVM_WRITE);
 	vg->system_id = NULL;
-	if (!(vg->lvm1_system_id = dm_pool_zalloc(vg->vgmem, NAME_LEN + 1)))
-		goto_bad;
 
 	vg->extent_size = DEFAULT_EXTENT_SIZE * 2;
 	vg->max_lv = DEFAULT_MAX_LV;
@@ -2973,7 +2971,7 @@ int vg_write(struct volume_group *vg)
 		return 0;
 	}
 
-	if ((vg->fid->fmt->features & FMT_MDAS) && !_vg_adjust_ignored_mdas(vg))
+	if (!_vg_adjust_ignored_mdas(vg))
 		return_0;
 
 	if (!vg_mda_used_count(vg)) {
@@ -5357,15 +5355,6 @@ int is_system_id_allowed(struct cmd_context *cmd, const char *system_id)
 static int _access_vg_systemid(struct cmd_context *cmd, struct volume_group *vg)
 {
 	/*
-	 * LVM1 VGs must not be accessed if a new-style LVM2 system ID is set.
-	 */
-	if (cmd->system_id && systemid_on_pvs(vg)) {
-		log_error("Cannot access VG %s with LVM1 system ID %s when host system ID is set.",
-			  vg->name, vg->lvm1_system_id);
-		return 0;
-	}
-
-	/*
 	 * A few commands allow read-only access to foreign VGs.
 	 */
 	if (cmd->include_foreign_vgs)
@@ -5417,11 +5406,6 @@ static int _vg_access_permitted(struct cmd_context *cmd, struct volume_group *vg
 				uint32_t lockd_state, uint32_t *failure)
 {
 	if (!is_real_vg(vg->name)) {
-		/* Disallow use of LVM1 orphans when a host system ID is set. */
-		if (cmd->system_id && *cmd->system_id && systemid_on_pvs(vg)) {
-			*failure |= FAILED_SYSTEMID;
-			return_0;
-		}
 		return 1;
 	}
 
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 3941612..40b41ec 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -32,7 +32,7 @@ struct dev_manager;
 #define SEG_AREAS_STRIPED	(1ULL <<  1)
 #define SEG_AREAS_MIRRORED	(1ULL <<  2)
 #define SEG_SNAPSHOT		(1ULL <<  3)
-#define SEG_FORMAT1_SUPPORT	(1ULL <<  4)
+/* #define SEG_FORMAT1_SUPPORT	(1ULL <<  4) */
 #define SEG_VIRTUAL		(1ULL <<  5)
 #define SEG_CANNOT_BE_ZEROED	(1ULL <<  6)
 #define SEG_MONITORED		(1ULL <<  7)
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 8357ea0..76d78f3 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -332,17 +332,6 @@ int vg_remove_snapshot(struct logical_volume *cow)
 	cow->snapshot = NULL;
 	lv_set_visible(cow);
 
-	/* format1 must do the change in one step, with the commit last. */
-	if (!(origin->vg->fid->fmt->features & FMT_MDAS)) {
-		/* Get the lock for COW volume */
-		if (is_origin_active && !activate_lv(cow->vg->cmd, cow)) {
-			log_error("Unable to activate logical volume \"%s\"",
-				  cow->name);
-			return 0;
-		}
-		return 1;
-	}
-
 	if (!vg_write(origin->vg))
 		return_0;
 
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 1020a67..b8b1501 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -42,12 +42,6 @@ struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 		return NULL;
 	}
 
-	if (!(vg->lvm1_system_id = dm_pool_zalloc(vgmem, NAME_LEN + 1))) {
-		log_error("Failed to allocate VG systemd id.");
-		dm_pool_destroy(vgmem);
-		return NULL;
-	}
-
 	vg->system_id = "";
 
 	vg->cmd = cmd;
@@ -178,7 +172,7 @@ char *vg_name_dup(const struct volume_group *vg)
 
 char *vg_system_id_dup(const struct volume_group *vg)
 {
-	return dm_pool_strdup(vg->vgmem, vg->system_id ? : vg->lvm1_system_id ? : "");
+	return dm_pool_strdup(vg->vgmem, vg->system_id ? : "");
 }
 
 char *vg_lock_type_dup(const struct volume_group *vg)
@@ -677,20 +671,11 @@ int vg_set_system_id(struct volume_group *vg, const char *system_id)
 		return 1;
 	}
 
-	if (systemid_on_pvs(vg)) {
-		log_error("Metadata format %s does not support this type of system ID.",
-			  vg->fid->fmt->name);
-		return 0;
-	}
-
 	if (!(vg->system_id = dm_pool_strdup(vg->vgmem, system_id))) {
 		log_error("Failed to allocate memory for system_id in vg_set_system_id.");
 		return 0;
 	}
 
-	if (vg->lvm1_system_id)
-		*vg->lvm1_system_id = '\0';
-
 	return 1;
 }
 
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 29d88f8..7ecfafe 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -70,7 +70,6 @@ struct volume_group {
 	const char *name;
 	const char *old_name;		/* Set during vgrename and vgcfgrestore */
 	const char *system_id;
-	char *lvm1_system_id;
 	const char *lock_type;
 	const char *lock_args;
 
diff --git a/lib/report/report.c b/lib/report/report.c
index 6d6289e..01ab627 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2845,7 +2845,7 @@ static int _vgsystemid_disp(struct dm_report *rh, struct dm_pool *mem,
 			    const void *data, void *private)
 {
 	const struct volume_group *vg = (const struct volume_group *) data;
-	const char *repstr = (vg->system_id && *vg->system_id) ? vg->system_id : vg->lvm1_system_id ? : "";
+	const char *repstr = (vg->system_id && *vg->system_id) ? vg->system_id : "";
 
 	return _field_string(rh, field, repstr);
 }
@@ -3822,7 +3822,6 @@ static struct volume_group _dummy_vg = {
 	.fid = &_dummy_fid,
 	.name = "",
 	.system_id = (char *) "",
-	.lvm1_system_id = (char *) "",
 	.pvs = DM_LIST_HEAD_INIT(_dummy_vg.pvs),
 	.lvs = DM_LIST_HEAD_INIT(_dummy_vg.lvs),
 	.historical_lvs = DM_LIST_HEAD_INIT(_dummy_vg.historical_lvs),
@@ -3833,7 +3832,6 @@ static struct volume_group _unknown_vg = {
 	.fid = &_dummy_fid,
 	.name = "[unknown]",
 	.system_id = (char *) "",
-	.lvm1_system_id = (char *) "",
 	.pvs = DM_LIST_HEAD_INIT(_unknown_vg.pvs),
 	.lvs = DM_LIST_HEAD_INIT(_unknown_vg.lvs),
 	.historical_lvs = DM_LIST_HEAD_INIT(_unknown_vg.historical_lvs),
diff --git a/lib/striped/striped.c b/lib/striped/striped.c
index e1de9c9..bca4c2c 100644
--- a/lib/striped/striped.c
+++ b/lib/striped/striped.c
@@ -240,7 +240,7 @@ struct segment_type *init_striped_segtype(struct cmd_context *cmd)
 	segtype->ops = &_striped_ops;
 	segtype->name = SEG_TYPE_NAME_STRIPED;
 	segtype->flags = SEG_STRIPED_TARGET |
-	    SEG_CAN_SPLIT | SEG_AREAS_STRIPED | SEG_FORMAT1_SUPPORT;
+	    SEG_CAN_SPLIT | SEG_AREAS_STRIPED;
 
 	log_very_verbose("Initialised segtype: %s", segtype->name);
 
diff --git a/man/vgconvert.8_des b/man/vgconvert.8_des
index a0d34fd..8519063 100644
--- a/man/vgconvert.8_des
+++ b/man/vgconvert.8_des
@@ -1,6 +1,3 @@
-vgconvert converts VG metadata from one format to another.  The new
-metadata format must be able to fit into the space provided by the old
+vgconvert converts VG metadata from one format to another.  This command
+is no longer used because this version of lvm no longer supports the LVM1
 format.
-
-Because the LVM1 format should no longer be used, this command is no
-longer needed in general.
diff --git a/test/shell/format-lvm1.sh b/test/shell/format-lvm1.sh
deleted file mode 100644
index b88579f..0000000
--- a/test/shell/format-lvm1.sh
+++ /dev/null
@@ -1,38 +0,0 @@
-#!/usr/bin/env bash
-
-# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-test_description='Test lvm1 format'
-
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-aux prepare_devs 1
-
-if test -n "$LVM_TEST_LVM1" ; then
-pvcreate -M1 "$dev1"
-vgcreate -M1 $vg "$dev1"
-check vg_field $vg fmt "lvm1"
-fi
-
-# TODO: if we decide to make using lvm1 with lvmetad an error,
-# then if lvmetad is being used, then verify:
-# not pvcreate -M1 "$dev1"
-# not vgcreate -M1 $vg "$dev1"
-#
-# TODO: if we decide to allow using lvm1 with lvmetad, but disable lvmetad
-# when it happens, then verify:
-# pvcreate -M1 "$dev1" | tee err
-# grep "disabled" err
-# vgcreate -M1 $vg "$dev1" | tee err
-# grep "disabled" err
-
diff --git a/test/shell/lvm1-basic.sh b/test/shell/lvm1-basic.sh
deleted file mode 100644
index 93509c4..0000000
--- a/test/shell/lvm1-basic.sh
+++ /dev/null
@@ -1,36 +0,0 @@
-#!/usr/bin/env bash
-
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-SKIP_WITH_LVMLOCKD=1
-SKIP_WITHOUT_LVMETAD=1
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-aux prepare_devs 2
-pvcreate --metadatatype 1 "$dev1"
-pvs | tee out
-grep "$dev1" out
-vgcreate --metadatatype 1 $vg1 "$dev1"
-vgs | tee out
-grep $vg1 out
-pvs | tee out
-grep "$dev1" out
-
-# check for RHBZ 1080189 -- SEGV in lvremove/vgremove
-pvcreate -ff -y --metadatatype 1 "$dev1" "$dev2"
-vgcreate --metadatatype 1 $vg1 "$dev1" "$dev2"
-lvcreate -l1 $vg1 "$dev1"
-pvremove -ff -y "$dev2"
-vgchange -an $vg1
-not lvremove $vg1
-not vgremove -ff -y $vg1
diff --git a/test/shell/snapshot-lvm1.sh b/test/shell/snapshot-lvm1.sh
deleted file mode 100644
index 75c97cb..0000000
--- a/test/shell/snapshot-lvm1.sh
+++ /dev/null
@@ -1,35 +0,0 @@
-#!/usr/bin/env bash
-
-# Copyright (C) 2013 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-# regression test for lvmetad reporting error:
-# Internal error: LV snap_with_lvm1_meta (00000000000000000000000000000001) missing from preload metadata
-
-SKIP_WITH_LVMLOCKD=1
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-aux prepare_devs 2
-get_devs
-
-vgcreate --metadatatype 1 "$vg" "${DEVICES[@]}"
-
-# Make origin volume
-lvcreate -ae -l5 $vg -n origin
-
-# Create a snap of origin
-lvcreate -s $vg/origin -n snap_with_lvm1_meta -l4
-
-# Remove volume snapper/snap_with_lvm1_meta
-lvremove -f $vg/snap_with_lvm1_meta
-
-vgremove -ff $vg
diff --git a/tools/args.h b/tools/args.h
index b80b8da..603a0cf 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -1207,8 +1207,7 @@ arg(mirrors_ARG, 'm', "mirrors", number_VAL, 0, 0,
 arg(metadatatype_ARG, 'M', "metadatatype", metadatatype_VAL, 0, 0,
     "Specifies the type of on-disk metadata to use.\n"
     "\\fBlvm2\\fP (or just \\fB2\\fP) is the current, standard format.\n"
-    "\\fBlvm1\\fP (or just \\fB1\\fP) is a historical format that\n"
-    "can be used for accessing old data.\n")
+    "\\fBlvm1\\fP (or just \\fB1\\fP) is no longer used.\n")
 
 arg(name_ARG, 'n', "name", string_VAL, 0, 0,
     "#lvcreate\n"
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index abdcf2c..72f840a 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1802,11 +1802,6 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 		return 0;
 	}
 
-	if (!(vg->fid->fmt->features & FMT_MDAS)) {
-		log_error("Unable to split off snapshot %s using old LVM1-style metadata.", cow_name);
-		return 0;
-	}
-
 	if (is_lockd_type(vg->lock_type)) {
 		/* FIXME: we need to create a lock for the new LV. */
 		log_error("Unable to split snapshots in VG with lock_type %s.", vg->lock_type);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 0600b1c..0dd24ec 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -23,7 +23,6 @@
 
 #include "stub.h"
 #include "last-path-component.h"
-#include "format1.h"
 
 #include <signal.h>
 #include <sys/stat.h>
@@ -2900,13 +2899,6 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		goto out;
 	}
 
-	if (!strcmp(cmd->fmt->name, FMT_LVM1_NAME) && lvmetad_used()) {
-		log_warn("WARNING: Disabling lvmetad cache which does not support obsolete metadata.");
-		lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_LVM1);
-		log_warn("WARNING: Not using lvmetad because lvm1 format is used.");
-		lvmetad_make_unused(cmd);
-	}
-
 	if (cmd->command->command_enum == lvconvert_repair_CMD) {
 		log_warn("WARNING: Disabling lvmetad cache for repair command.");
 		lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_REPAIR);
@@ -2971,7 +2963,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	 *   by different token values.)
 	 *
 	 * lvmetad may have been previously disabled (or disabled during the
-	 * rescan done here) because duplicate devices or lvm1 metadata were seen.
+	 * rescan done here) because duplicate devices were seen.
 	 * In this case, disable the *use* of lvmetad by this command, reverting to
 	 * disk scanning.
 	 */
@@ -3396,41 +3388,6 @@ static int _run_script(struct cmd_context *cmd, int argc, char **argv)
 	return ret;
 }
 
-/*
- * Determine whether we should fall back and exec the equivalent LVM1 tool
- */
-static int _lvm1_fallback(struct cmd_context *cmd)
-{
-	char vsn[80];
-	int dm_present;
-
-	if (!find_config_tree_bool(cmd, global_fallback_to_lvm1_CFG, NULL) ||
-	    strncmp(cmd->kernel_vsn, "2.4.", 4))
-		return 0;
-
-	log_suppress(1);
-	dm_present = driver_version(vsn, sizeof(vsn));
-	log_suppress(0);
-
-	if (dm_present || !lvm1_present(cmd))
-		return 0;
-
-	return 1;
-}
-
-static void _exec_lvm1_command(char **argv)
-{
-	char path[PATH_MAX];
-
-	if (dm_snprintf(path, sizeof(path), "%s.lvm1", argv[0]) < 0) {
-		log_error("Failed to create LVM1 tool pathname");
-		return;
-	}
-
-	execvp(path, argv);
-	log_sys_error("execvp", path);
-}
-
 static void _nonroot_warning(void)
 {
 	if (getuid() || geteuid())
@@ -3520,19 +3477,6 @@ int lvm2_main(int argc, char **argv)
 	} else
 		run_name = dm_basename(argv[0]);
 
-	if (_lvm1_fallback(cmd)) {
-		/* Attempt to run equivalent LVM1 tool instead */
-		if (!argc) {
-			log_error("Falling back to LVM1 tools, but no "
-				  "command specified.");
-			ret = ECMD_FAILED;
-			goto out;
-		}
-		_exec_lvm1_command(argv);
-		ret = ECMD_FAILED;
-		goto_out;
-	}
-
 	/*
 	 * Decide if we are running a shell or a command or a script.  When
 	 * there is no run_name, it's a shell, when run_name is a recognized
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 1fcf606..5796309 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -595,7 +595,7 @@ out:
  * display the PV info.
  *
  * iii. If lvmetad is being used, but has been disabled (because of
- * duplicate devs or lvm1 metadata), or has a non-matching token
+ * duplicate devs), or has a non-matching token
  * (because the device filter is different from the device filter last
  * used to populate lvmetad), then 'pvscan' will begin by rescanning
  * devices to repopulate lvmetad.  If lvmetad is enabled after the
@@ -608,8 +608,7 @@ out:
  * attempt to repopulate the lvmetad cache by rescanning all devs
  * (regardless of whether lvmetad was previously disabled or had an
  * unmatching token.)  lvmetad may be enabled or disabled after the
- * rescan (depending on whether duplicate devs or lvm1 metadata was
- * found).
+ * rescan (depending on whether duplicate devs).
  *
  * 3. The 'pvscan --cache <dev>' command will attempt to repopulate the
  * lvmetad cache by rescanning all devs if lvmetad has a non-matching
diff --git a/tools/stub.h b/tools/stub.h
index f03e5d3..1d58387 100644
--- a/tools/stub.h
+++ b/tools/stub.h
@@ -37,7 +37,6 @@ int pvdata(struct cmd_context *cmd __attribute__((unused)),
 {
 	log_error("There's no 'pvdata' command in LVM2.");
 	log_error("Use lvs, pvs, vgs instead; or use vgcfgbackup and read the text file backup.");
-	log_error("Metadata in LVM1 format can still be displayed using LVM1's pvdata command.");
 	return ECMD_FAILED;
 }
 
diff --git a/tools/toollib.c b/tools/toollib.c
index b9e6bd2..53e7f9a 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -14,7 +14,6 @@
  */
 
 #include "tools.h"
-#include "format1.h"
 #include "format-text.h"
 
 #include <sys/stat.h>
@@ -4112,7 +4111,6 @@ static int _process_duplicate_pvs(struct cmd_context *cmd,
 		.fid = &dummy_fid,
 		.name = "",
 		.system_id = (char *) "",
-		.lvm1_system_id = (char *) "",
 		.pvs = DM_LIST_HEAD_INIT(dummy_vg.pvs),
 		.lvs = DM_LIST_HEAD_INIT(dummy_vg.lvs),
 		.historical_lvs = DM_LIST_HEAD_INIT(dummy_vg.historical_lvs),
@@ -4750,23 +4748,6 @@ int pvcreate_params_from_args(struct cmd_context *cmd, struct pvcreate_params *p
 	pp->pva.label_sector = arg_int64_value(cmd, labelsector_ARG,
 					       DEFAULT_LABELSECTOR);
 
-	if (!(cmd->fmt->features & FMT_MDAS) &&
-	    (arg_is_set(cmd, pvmetadatacopies_ARG) ||
-	     arg_is_set(cmd, metadatasize_ARG)   ||
-	     arg_is_set(cmd, dataalignment_ARG)  ||
-	     arg_is_set(cmd, dataalignmentoffset_ARG))) {
-		log_error("Metadata and data alignment parameters only "
-			  "apply to text format.");
-		return 0;
-	}
-
-	if (!(cmd->fmt->features & FMT_BAS) &&
-	    arg_is_set(cmd, bootloaderareasize_ARG)) {
-		log_error("Bootloader area parameters only "
-			  "apply to text format.");
-		return 0;
-	}
-
 	if (arg_is_set(cmd, metadataignore_ARG))
 		pp->pva.metadataignore = arg_int_value(cmd, metadataignore_ARG,
 						   DEFAULT_PVMETADATAIGNORE);
@@ -5126,10 +5107,7 @@ static int _pvcreate_check_single(struct cmd_context *cmd,
 			pd->is_orphan_pv = 1;
 		}
 
-		if (!strcmp(vg->name, FMT_LVM1_ORPHAN_VG_NAME))
-			pp->orphan_vg_name = FMT_LVM1_ORPHAN_VG_NAME;
-		else
-			pp->orphan_vg_name = FMT_TEXT_ORPHAN_VG_NAME;
+		pp->orphan_vg_name = FMT_TEXT_ORPHAN_VG_NAME;
 	} else {
 		log_debug("Found pvcreate arg %s: device is not a PV.", pd->name);
 		/* Device is not a PV. */
@@ -5358,10 +5336,7 @@ static int _pvremove_check_single(struct cmd_context *cmd,
 			pd->is_orphan_pv = 1;
 		}
 
-		if (!strcmp(vg->name, FMT_LVM1_ORPHAN_VG_NAME))
-			pp->orphan_vg_name = FMT_LVM1_ORPHAN_VG_NAME;
-		else
-			pp->orphan_vg_name = FMT_TEXT_ORPHAN_VG_NAME;
+		pp->orphan_vg_name = FMT_TEXT_ORPHAN_VG_NAME;
 	} else {
 		/* FIXME: is it possible to reach here? */
 		log_debug("Found pvremove arg %s: device is not a PV.", pd->name);
diff --git a/tools/vals.h b/tools/vals.h
index 95dc8b2..79c48b5 100644
--- a/tools/vals.h
+++ b/tools/vals.h
@@ -77,7 +77,7 @@
  *
  * FIXME: are there some specialized or irrelevant
  * options included in the usage text below that should
- * be removed?  Should "lvm1" be removed?
+ * be removed?
  *
  * Size is a Number that takes an optional unit.
  * A full usage could be "Size[b|B|s|S|k|K|m|M|g|G|t|T|p|P|e|E]"
@@ -126,7 +126,7 @@ val(sextents_VAL, sextents_arg, "SExtents", "[+|-]Number[PERCENT]")
 val(pextents_VAL, pextents_arg, "PExtents", "[+]Number[PERCENT]")
 val(nextents_VAL, nextents_arg, "NExtents", "[-]Number[PERCENT]")
 val(permission_VAL, permission_arg, "Permission", "rw|r")
-val(metadatatype_VAL, metadatatype_arg, "MetadataType", "lvm2|lvm1")
+val(metadatatype_VAL, metadatatype_arg, "MetadataType", "lvm2")
 val(units_VAL, string_arg, "Units", "r|R|h|H|b|B|s|S|k|K|m|M|g|G|t|T|p|P|e|E")
 val(segtype_VAL, segtype_arg, "SegType", "linear|striped|snapshot|mirror|raid|thin|cache|thin-pool|cache-pool")
 val(alloc_VAL, alloc_arg, "Alloc", "contiguous|cling|cling_by_tags|normal|anywhere|inherit")
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 61b78df..e231c86 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -534,13 +534,6 @@ static int _vgchange_system_id(struct cmd_context *cmd, struct volume_group *vg)
 	const char *system_id;
 	const char *system_id_arg_str = arg_str_value(cmd, systemid_ARG, NULL);
 
-	/* FIXME Merge with vg_set_system_id() */
-	if (systemid_on_pvs(vg)) {
-		log_error("Metadata format %s does not support this type of system ID.",
-			  vg->fid->fmt->name);
-		return 0;
-	}
-
 	if (!(system_id = system_id_from_string(cmd, system_id_arg_str))) {
 		log_error("Unable to set system ID.");
 		return 0;
@@ -590,9 +583,6 @@ static int _vgchange_system_id(struct cmd_context *cmd, struct volume_group *vg)
 
 	vg->system_id = system_id;
 	
-	if (vg->lvm1_system_id)
-		*vg->lvm1_system_id = '\0';
-
 	return 1;
 }
 
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index 8bdf8be..ca9615c 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -34,30 +34,26 @@ static int _vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 		return ECMD_FAILED;
 	}
 
-	if (cmd->fmt->features & FMT_MDAS) {
-		if (arg_sign_value(cmd, metadatasize_ARG, SIGN_NONE) == SIGN_MINUS) {
-			log_error("Metadata size may not be negative");
-			return EINVALID_CMD_LINE;
-		}
-
-		pva.pvmetadatasize = arg_uint64_value(cmd, metadatasize_ARG, UINT64_C(0));
-		if (!pva.pvmetadatasize)
-			pva.pvmetadatasize = find_config_tree_int(cmd, metadata_pvmetadatasize_CFG, NULL);
-
-		pva.pvmetadatacopies = arg_int_value(cmd, pvmetadatacopies_ARG, -1);
-		if (pva.pvmetadatacopies < 0)
-			pva.pvmetadatacopies = find_config_tree_int(cmd, metadata_pvmetadatacopies_CFG, NULL);
+	if (arg_sign_value(cmd, metadatasize_ARG, SIGN_NONE) == SIGN_MINUS) {
+		log_error("Metadata size may not be negative");
+		return EINVALID_CMD_LINE;
 	}
 
-	if (cmd->fmt->features & FMT_BAS) {
-		if (arg_sign_value(cmd, bootloaderareasize_ARG, SIGN_NONE) == SIGN_MINUS) {
-			log_error("Bootloader area size may not be negative");
-			return EINVALID_CMD_LINE;
-		}
+	pva.pvmetadatasize = arg_uint64_value(cmd, metadatasize_ARG, UINT64_C(0));
+	if (!pva.pvmetadatasize)
+		pva.pvmetadatasize = find_config_tree_int(cmd, metadata_pvmetadatasize_CFG, NULL);
 
-		pva.ba_size = arg_uint64_value(cmd, bootloaderareasize_ARG, UINT64_C(0));
+	pva.pvmetadatacopies = arg_int_value(cmd, pvmetadatacopies_ARG, -1);
+	if (pva.pvmetadatacopies < 0)
+		pva.pvmetadatacopies = find_config_tree_int(cmd, metadata_pvmetadatacopies_CFG, NULL);
+
+	if (arg_sign_value(cmd, bootloaderareasize_ARG, SIGN_NONE) == SIGN_MINUS) {
+		log_error("Bootloader area size may not be negative");
+		return EINVALID_CMD_LINE;
 	}
 
+	pva.ba_size = arg_uint64_value(cmd, bootloaderareasize_ARG, UINT64_C(0));
+
 	if (!vg_check_new_extent_size(cmd->fmt, vg->extent_size))
 		return_ECMD_FAILED;
 
@@ -86,13 +82,6 @@ static int _vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 				return ECMD_FAILED;
 			}
 
-	/* New-style system ID supported? */ 
-	if (vg->system_id && *vg->system_id && (cmd->fmt->features & FMT_SYSTEMID_ON_PVS)) {
-		log_error("Unable to convert VG %s while it has a system ID set (%s).", vg->name,
-			  vg->system_id);
-		return ECMD_FAILED;
-	}
-
 	/* Attempt to change any LVIDs that are too big */
 	if (cmd->fmt->features & FMT_RESTRICTED_LVIDS) {
 		dm_list_iterate_items(lvl, &vg->lvs) {
@@ -157,18 +146,6 @@ int vgconvert(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (!(cmd->fmt->features & FMT_MDAS) &&
-	    arg_is_set(cmd, pvmetadatacopies_ARG)) {
-		log_error("Metadata parameters only apply to text format");
-		return EINVALID_CMD_LINE;
-	}
-
-	if (!(cmd->fmt->features & FMT_BAS) &&
-		arg_is_set(cmd, bootloaderareasize_ARG)) {
-		log_error("Bootloader area parameters only apply to text format");
-		return EINVALID_CMD_LINE;
-	}
-
 	return process_each_vg(cmd, argc, argv, NULL, NULL, READ_FOR_UPDATE, 0, NULL,
 			       &_vgconvert_single);
 }
diff --git a/tools/vgscan.c b/tools/vgscan.c
index 1ec9083..f9fa382 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -44,7 +44,7 @@ static int _vgscan_single(struct cmd_context *cmd, const char *vg_name,
  * display the VG info.
  *
  * iii. If lvmetad is being used, but has been disabled (because of
- * duplicate devs or lvm1 metadata), or has a non-matching token
+ * duplicate devs), or has a non-matching token
  * (because the device filter is different from the device filter last
  * used to populate lvmetad), then 'vgscan' will begin by rescanning
  * devices to repopulate lvmetad.  If lvmetad is enabled after the
@@ -57,7 +57,7 @@ static int _vgscan_single(struct cmd_context *cmd, const char *vg_name,
  * the lvmetad cache by rescanning all devs (regardless of whether
  * lvmetad was previously disabled or had an unmatching token.)
  * lvmetad may be enabled or disabled after the rescan (depending
- * on whether duplicate devs or lvm1 metadata was found).
+ * on whether duplicate devs were found).
  * If enabled, then it will simply read and display VG info from the
  * lvmetad cache (like case 1.i.).  If disabled, then it will
  * read all devices to display VG info (like case 1.ii.)


