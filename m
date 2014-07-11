From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 11:34:05 +0000 (UTC)
Subject: master - cache: add tool support
Message-ID: <20140711113405.18B2560B37@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f9d80c9d31d7113ab8bc08baf6bba96a7449261f
Commit:        f9d80c9d31d7113ab8bc08baf6bba96a7449261f
Parent:        5c3d8940136f39a017ab434651789647161350b1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 4 16:31:29 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 12:47:35 2014 +0200

cache: add tool support

Introducing cache tool support.
---
 WHATS_NEW                    |    1 +
 conf/example.conf.in         |   30 ++++++++++++++
 configure.in                 |   89 +++++++++++++++++++++++++++++++++++++++---
 lib/config/config_settings.h |    5 ++
 lib/config/defaults.h        |    2 +
 lib/misc/configure.h.in      |   12 ++++++
 6 files changed, 133 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 29a0aa3..77cc2d7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.108 -
 =================================
+  Add initial code to use cache tools (cache_check|dump|repair|restore).
   Add "degraded" activation mode and make it the default.
   Add separate lv_active_{locally,remotely,exclusively} LV reporting fields.
   Recognize "auto"/"unmanaged" values in selection for appropriate fields only.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 91768fb..2930054 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -744,6 +744,36 @@ global {
     #   external_origin_extend
     #
     # thin_disabled_features = [ "discards", "block_size" ]
+
+    # Full path of the utility called to check that a cache metadata device
+    # is in a state that allows it to be used.
+    # Each time a cached LV needs to be used or after it is deactivated
+    # this utility is executed. The activation will only proceed if the utility
+    # has an exit status of 0.
+    # Set to "" to skip this check.  (Not recommended.)
+    # The cache tools are available as part of the device-mapper-persistent-data
+    # package from https://github.com/jthornber/thin-provisioning-tools.
+    #
+    # cache_check_executable = "@CACHE_CHECK_CMD@"
+
+    # Array of string options passed with cache_check command. By default,
+    # option "-q" is for quiet output.
+    #
+    # cache_check_options = [ "-q" ]
+
+    # Full path of the utility called to repair a cache metadata device.
+    # Each time a cache metadata needs repair this utility is executed.
+    # See cache_check_executable how to obtain binaries.
+    #
+    # cache_repair_executable = "@CACHE_REPAIR_CMD@"
+
+    # Array of extra string options passed with cache_repair command.
+    # cache_repair_options = [ "" ]
+
+    # Full path of the utility called to dump cache metadata content.
+    # See cache_check_executable how to obtain binaries.
+    #
+    # cache_dump_executable = "@CACHE_DUMP_CMD@"
 }
 
 activation {
diff --git a/configure.in b/configure.in
index d92e03e..1b8c338 100644
--- a/configure.in
+++ b/configure.in
@@ -447,7 +447,7 @@ case "$THIN" in
 			THIN_CHECK_NEEDS_CHECK=no
 		fi
 	fi
-	# Empty means a config way to ignore thin checking
+	# Empty means a config way to ignore thin dumping
 	if test "$THIN_DUMP_CMD" = "autodetect"; then
 		AC_PATH_TOOL(THIN_DUMP_CMD, thin_dump)
 		test -z "$THIN_DUMP_CMD" && {
@@ -456,7 +456,7 @@ case "$THIN" in
 			THIN_CONFIGURE_WARN=y
 		}
 	fi
-	# Empty means a config way to ignore thin checking
+	# Empty means a config way to ignore thin repairing
 	if test "$THIN_REPAIR_CMD" = "autodetect"; then
 		AC_PATH_TOOL(THIN_REPAIR_CMD, thin_repair)
 		test -z "$THIN_REPAIR_CMD" && {
@@ -465,7 +465,7 @@ case "$THIN" in
 			THIN_CONFIGURE_WARN=y
 		}
 	fi
-	# Empty means a config way to ignore thin checking
+	# Empty means a config way to ignore thin restoring
 	if test "$THIN_RESTORE_CMD" = "autodetect"; then
 		AC_PATH_TOOL(THIN_RESTORE_CMD, thin_restore)
 		test -z "$THIN_RESTORE_CMD" && {
@@ -500,9 +500,24 @@ dnl -- cache inclusion type
 AC_MSG_CHECKING(whether to include cache)
 AC_ARG_WITH(cache,
 	    AC_HELP_STRING([--with-cache=TYPE],
-			   [cache support: internal/shared/none
-			    [[TYPE=none]]]),
-	    CACHE=$withval, CACHE=none)
+			   [cache support: internal/shared/none [[TYPE=none]]]),
+			   CACHE=$withval, CACHE="none")
+AC_ARG_WITH(cache-check,
+	    AC_HELP_STRING([--with-cache-check=PATH],
+			   [cache_check tool: [[autodetect]]]),
+			   CACHE_CHECK_CMD=$withval, CACHE_CHECK_CMD="autodetect")
+AC_ARG_WITH(cache-dump,
+	    AC_HELP_STRING([--with-cache-dump=PATH],
+			   [cache_dump tool: [[autodetect]]]),
+			   CACHE_DUMP_CMD=$withval, CACHE_DUMP_CMD="autodetect")
+AC_ARG_WITH(cache-repair,
+	    AC_HELP_STRING([--with-cache-repair=PATH],
+			   [cache_repair tool: [[autodetect]]]),
+			   CACHE_REPAIR_CMD=$withval, CACHE_REPAIR_CMD="autodetect")
+AC_ARG_WITH(cache-restore,
+	    AC_HELP_STRING([--with-cache-restore=PATH],
+			   [cache_restore tool: [[autodetect]]]),
+			   CACHE_RESTORE_CMD=$withval, CACHE_RESTORE_CMD="autodetect")
 AC_MSG_RESULT($CACHE)
 
 case "$CACHE" in
@@ -511,6 +526,62 @@ case "$CACHE" in
  *) AC_MSG_ERROR([--with-cache parameter invalid]) ;;
 esac
 
+# Test if necessary cache tools are available
+# if not - use plain defaults and warn user
+case "$CACHE" in
+  internal|shared)
+	# Empty means a config way to ignore cache checking
+	if test "$CACHE_CHECK_CMD" = "autodetect"; then
+		AC_PATH_TOOL(CACHE_CHECK_CMD, cache_check)
+		if test -z "$CACHE_CHECK_CMD"; then
+			AC_MSG_WARN([cache_check not found in path $PATH])
+			CACHE_CHECK_CMD=/usr/sbin/cache_check
+			CACHE_CONFIGURE_WARN=y
+		fi
+	fi
+	# Empty means a config way to ignore cache dumping
+	if test "$CACHE_DUMP_CMD" = "autodetect"; then
+		AC_PATH_TOOL(CACHE_DUMP_CMD, cache_dump)
+		test -z "$CACHE_DUMP_CMD" && {
+			AC_MSG_WARN(cache_dump not found in path $PATH)
+			CACHE_DUMP_CMD=/usr/sbin/cache_dump
+			CACHE_CONFIGURE_WARN=y
+		}
+	fi
+	# Empty means a config way to ignore cache repairing
+	if test "$CACHE_REPAIR_CMD" = "autodetect"; then
+		AC_PATH_TOOL(CACHE_REPAIR_CMD, cache_repair)
+		test -z "$CACHE_REPAIR_CMD" && {
+			AC_MSG_WARN(cache_repair not found in path $PATH)
+			CACHE_REPAIR_CMD=/usr/sbin/cache_repair
+			CACHE_CONFIGURE_WARN=y
+		}
+	fi
+	# Empty means a config way to ignore cache restoring
+	if test "$CACHE_RESTORE_CMD" = "autodetect"; then
+		AC_PATH_TOOL(CACHE_RESTORE_CMD, cache_restore)
+		test -z "$CACHE_RESTORE_CMD" && {
+			AC_MSG_WARN(cache_restore not found in path $PATH)
+			CACHE_RESTORE_CMD=/usr/sbin/cache_restore
+			CACHE_CONFIGURE_WARN=y
+		}
+	fi
+	;;
+esac
+
+AC_DEFINE_UNQUOTED([CACHE_CHECK_CMD], ["$CACHE_CHECK_CMD"],
+		   [The path to 'cache_check', if available.])
+
+AC_DEFINE_UNQUOTED([CACHE_DUMP_CMD], ["$CACHE_DUMP_CMD"],
+		   [The path to 'cache_dump', if available.])
+
+AC_DEFINE_UNQUOTED([CACHE_REPAIR_CMD], ["$CACHE_REPAIR_CMD"],
+		   [The path to 'cache_repair', if available.])
+
+AC_DEFINE_UNQUOTED([CACHE_RESTORE_CMD], ["$CACHE_RESTORE_CMD"],
+		   [The path to 'cache_restore', if available.])
+
+
 ################################################################################
 dnl -- Disable readline
 AC_MSG_CHECKING(whether to enable readline)
@@ -1660,6 +1731,10 @@ AC_SUBST(THIN_CHECK_CMD)
 AC_SUBST(THIN_DUMP_CMD)
 AC_SUBST(THIN_REPAIR_CMD)
 AC_SUBST(THIN_RESTORE_CMD)
+AC_SUBST(CACHE_CHECK_CMD)
+AC_SUBST(CACHE_DUMP_CMD)
+AC_SUBST(CACHE_REPAIR_CMD)
+AC_SUBST(CACHE_RESTORE_CMD)
 AC_SUBST(UDEV_PC)
 AC_SUBST(UDEV_RULES)
 AC_SUBST(UDEV_SYNC)
@@ -1764,4 +1839,6 @@ test -n "$THIN_CONFIGURE_WARN" && AC_MSG_WARN([Support for thin provisioning is
 
 test -n "$THIN_CHECK_VERSION_WARN" && AC_MSG_WARN([You should also install thin_check vsn 0.3.2 (or later) to use lvm2 thin provisioning])
 
+test -n "$CACHE_CONFIGURE_WARN" && AC_MSG_WARN([Support for cache is limited since some cache tools are missing!])
+
 test "$ODIRECT" = yes || AC_MSG_WARN([O_DIRECT disabled: low-memory pvmove may lock up])
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 455eb4f..c6be2e3 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -182,6 +182,11 @@ cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CF
 cfg(global_thin_dump_executable_CFG, "thin_dump_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, THIN_DUMP_CMD, vsn(2, 2, 100), NULL)
 cfg(global_thin_repair_executable_CFG, "thin_repair_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, THIN_REPAIR_CMD, vsn(2, 2, 100), NULL)
 cfg_array(global_thin_repair_options_CFG, "thin_repair_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_THIN_REPAIR_OPTIONS, vsn(2, 2, 100), NULL)
+cfg(global_cache_check_executable_CFG, "cache_check_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, CACHE_CHECK_CMD, vsn(2, 2, 108), NULL)
+cfg_array(global_cache_check_options_CFG, "cache_check_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_CACHE_CHECK_OPTIONS, vsn(2, 2, 108), NULL)
+cfg(global_cache_dump_executable_CFG, "cache_dump_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, CACHE_DUMP_CMD, vsn(2, 2, 108), NULL)
+cfg(global_cache_repair_executable_CFG, "cache_repair_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, CACHE_REPAIR_CMD, vsn(2, 2, 108), NULL)
+cfg_array(global_cache_repair_options_CFG, "cache_repair_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_CACHE_REPAIR_OPTIONS, vsn(2, 2, 108), NULL)
 
 cfg(activation_checks_CFG, "checks", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ACTIVATION_CHECKS, vsn(2, 2, 86), NULL)
 cfg(activation_udev_sync_CFG, "udev_sync", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_UDEV_SYNC, vsn(2, 2, 51), NULL)
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 815d6a3..05187b0 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -90,6 +90,8 @@
 #define DEFAULT_THIN_POOL_ZERO 1
 #define DEFAULT_POOL_METADATA_SPARE 1 /* thin + cache */
 
+#define DEFAULT_CACHE_CHECK_OPTIONS "-q"
+#define DEFAULT_CACHE_REPAIR_OPTIONS ""
 #define DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS 0
 #define DEFAULT_CACHE_POOL_CHUNK_SIZE 64 /* KB */
 #define DEFAULT_CACHE_POOL_MIN_METADATA_SIZE 2048  /* KB */
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index c618ff4..f137f14 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -3,9 +3,21 @@
 /* Define to 1 to use libblkid detection of signatures when wiping. */
 #undef BLKID_WIPING_SUPPORT
 
+/* The path to 'cache_check', if available. */
+#undef CACHE_CHECK_CMD
+
+/* The path to 'cache_dump', if available. */
+#undef CACHE_DUMP_CMD
+
 /* Define to 1 to include built-in support for cache. */
 #undef CACHE_INTERNAL
 
+/* The path to 'cache_repair', if available. */
+#undef CACHE_REPAIR_CMD
+
+/* The path to 'cache_restore', if available. */
+#undef CACHE_RESTORE_CMD
+
 /* Define to 1 if the `closedir' function returns void instead of `int'. */
 #undef CLOSEDIR_VOID
 


