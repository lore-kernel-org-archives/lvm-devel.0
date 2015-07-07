From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  7 Jul 2015 07:57:50 +0000 (UTC)
Subject: master - cache: support clear-needs-check
Message-ID: <20150707075750.9980860E6A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0ac20a8fdb971c542790b8f50b32ee071b69f130
Commit:        0ac20a8fdb971c542790b8f50b32ee071b69f130
Parent:        d16332be72ff46d90b5245d25c4aa471913f0e91
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 7 09:51:40 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 7 09:57:27 2015 +0200

cache: support clear-needs-check

Support newer cache tool which support new option
--clear-needs-check-flag.

Code does same as for thin_check.
---
 WHATS_NEW                    |    1 +
 configure                    |   38 ++++++++++++++++++++++++++++++++++++++
 configure.in                 |   27 +++++++++++++++++++++++++++
 lib/activate/dev_manager.c   |    2 +-
 lib/config/config_settings.h |    4 +++-
 lib/config/defaults.h        |   12 ++++++++++--
 lib/misc/configure.h.in      |    4 ++++
 7 files changed, 84 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8ba1e43..82195d6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.125 -
 ================================
+  Add support --clear-needs-check-flag for cache_check of cache pool metadata.
   Replace --enable-lvmlockd by --enable-lockd-sanlock and --enable-lockd-dlm.
 
 Version 2.02.124 - 3rd July 2015
diff --git a/configure b/configure
index 4c4c843..48f5381 100755
--- a/configure
+++ b/configure
@@ -902,6 +902,7 @@ with_cache_check
 with_cache_dump
 with_cache_repair
 with_cache_restore
+enable_cache_check_needs_check
 enable_readline
 enable_realtime
 enable_ocf
@@ -1635,6 +1636,8 @@ Optional Features:
                           device-mapper is missing from the kernel
   --disable-thin_check_needs_check
                           required if thin_check version is < 0.3.0
+  --disable-cache_check_needs_check
+                          required if cache_check version is < 0.5
   --disable-readline      disable readline support
   --enable-realtime       enable realtime clock support
   --enable-ocf            enable Open Cluster Framework (OCF) compliant
@@ -8313,6 +8316,14 @@ $as_echo "#define CACHE_INTERNAL 1" >>confdefs.h
  *) as_fn_error $? "--with-cache parameter invalid" "$LINENO" 5 ;;
 esac
 
+# Check whether --enable-cache_check_needs_check was given.
+if test "${enable_cache_check_needs_check+set}" = set; then :
+  enableval=$enable_cache_check_needs_check; CACHE_CHECK_NEEDS_CHECK=$enableval
+else
+  CACHE_CHECK_NEEDS_CHECK=yes
+fi
+
+
 # Test if necessary cache tools are available
 # if not - use plain defaults and warn user
 case "$CACHE" in
@@ -8424,6 +8435,23 @@ $as_echo "$as_me: WARNING: cache_check not found in path $PATH" >&2;}
 			CACHE_CONFIGURE_WARN=y
 		fi
 	fi
+	if test "$CACHE_CHECK_NEEDS_CHECK" = yes; then
+		CACHE_CHECK_VSN=`"$CACHE_CHECK_CMD" -V 2>/dev/null`
+		CACHE_CHECK_VSN_MAJOR=`echo "$CACHE_CHECK_VSN" | $AWK -F '.' '{print $1}'`
+		CACHE_CHECK_VSN_MINOR=`echo "$CACHE_CHECK_VSN" | $AWK -F '.' '{print $2}'`
+
+		if test -z "$CACHE_CHECK_VSN_MAJOR" -o -z "$CACHE_CHECK_VSN_MINOR"; then
+			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: $CACHE_CHECK_CMD: Bad version \"$CACHE_CHECK_VSN\" found" >&5
+$as_echo "$as_me: WARNING: $CACHE_CHECK_CMD: Bad version \"$CACHE_CHECK_VSN\" found" >&2;}
+			CACHE_CHECK_VERSION_WARN=y
+			CACHE_CHECK_NEEDS_CHECK=no
+		elif test "$CACHE_CHECK_VSN_MAJOR" -eq 0 -a "$CACHE_CHECK_VSN_MINOR" -lt 5; then
+			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: $CACHE_CHECK_CMD: Old version \"$CACHE_CHECK_VSN\" found" >&5
+$as_echo "$as_me: WARNING: $CACHE_CHECK_CMD: Old version \"$CACHE_CHECK_VSN\" found" >&2;}
+			CACHE_CHECK_VERSION_WARN=y
+			CACHE_CHECK_NEEDS_CHECK=no
+		fi
+	fi
 	# Empty means a config way to ignore cache dumping
 	if test "$CACHE_DUMP_CMD" = "autodetect"; then
 		if test -n "$ac_tool_prefix"; then
@@ -8745,6 +8773,16 @@ $as_echo "$as_me: WARNING: cache_restore not found in path $PATH" >&2;}
 			CACHE_CONFIGURE_WARN=y
 		}
 	fi
+
+	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether cache_check supports the needs-check flag" >&5
+$as_echo_n "checking whether cache_check supports the needs-check flag... " >&6; }
+	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $CACHE_CHECK_NEEDS_CHECK" >&5
+$as_echo "$CACHE_CHECK_NEEDS_CHECK" >&6; }
+	if test "$CACHE_CHECK_NEEDS_CHECK" = yes; then
+
+$as_echo "#define CACHE_CHECK_NEEDS_CHECK 1" >>confdefs.h
+
+	fi
 	;;
 esac
 
diff --git a/configure.in b/configure.in
index 7839480..ca461af 100644
--- a/configure.in
+++ b/configure.in
@@ -560,6 +560,12 @@ case "$CACHE" in
  *) AC_MSG_ERROR([--with-cache parameter invalid]) ;;
 esac
 
+dnl -- cache_check needs-check flag
+AC_ARG_ENABLE(cache_check_needs_check,
+	      AC_HELP_STRING([--disable-cache_check_needs_check],
+			     [required if cache_check version is < 0.5]),
+	      CACHE_CHECK_NEEDS_CHECK=$enableval, CACHE_CHECK_NEEDS_CHECK=yes)
+
 # Test if necessary cache tools are available
 # if not - use plain defaults and warn user
 case "$CACHE" in
@@ -573,6 +579,21 @@ case "$CACHE" in
 			CACHE_CONFIGURE_WARN=y
 		fi
 	fi
+	if test "$CACHE_CHECK_NEEDS_CHECK" = yes; then
+		CACHE_CHECK_VSN=`"$CACHE_CHECK_CMD" -V 2>/dev/null`
+		CACHE_CHECK_VSN_MAJOR=`echo "$CACHE_CHECK_VSN" | $AWK -F '.' '{print $1}'`
+		CACHE_CHECK_VSN_MINOR=`echo "$CACHE_CHECK_VSN" | $AWK -F '.' '{print $2}'`
+
+		if test -z "$CACHE_CHECK_VSN_MAJOR" -o -z "$CACHE_CHECK_VSN_MINOR"; then
+			AC_MSG_WARN([$CACHE_CHECK_CMD: Bad version "$CACHE_CHECK_VSN" found])
+			CACHE_CHECK_VERSION_WARN=y
+			CACHE_CHECK_NEEDS_CHECK=no
+		elif test "$CACHE_CHECK_VSN_MAJOR" -eq 0 -a "$CACHE_CHECK_VSN_MINOR" -lt 5; then
+			AC_MSG_WARN([$CACHE_CHECK_CMD: Old version "$CACHE_CHECK_VSN" found])
+			CACHE_CHECK_VERSION_WARN=y
+			CACHE_CHECK_NEEDS_CHECK=no
+		fi
+	fi
 	# Empty means a config way to ignore cache dumping
 	if test "$CACHE_DUMP_CMD" = "autodetect"; then
 		AC_PATH_TOOL(CACHE_DUMP_CMD, cache_dump)
@@ -600,6 +621,12 @@ case "$CACHE" in
 			CACHE_CONFIGURE_WARN=y
 		}
 	fi
+
+	AC_MSG_CHECKING([whether cache_check supports the needs-check flag])
+	AC_MSG_RESULT([$CACHE_CHECK_NEEDS_CHECK])
+	if test "$CACHE_CHECK_NEEDS_CHECK" = yes; then
+		AC_DEFINE([CACHE_CHECK_NEEDS_CHECK], 1, [Define to 1 if the external 'cache_check' tool requires the --clear-needs-check-flag option])
+	fi
 	;;
 esac
 
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index e13b8e5..6a4da3c 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2055,7 +2055,7 @@ static int _pool_register_callback(struct dev_manager *dm,
 		data->skip_zero = dm->activation;
 		data->exec = global_cache_check_executable_CFG;
 		data->opts = global_cache_check_options_CFG;
-		data->defaults = DEFAULT_CACHE_CHECK_OPTION1;
+		data->defaults = DEFAULT_CACHE_CHECK_OPTION1 " " DEFAULT_CACHE_CHECK_OPTION2;
 		data->global = "cache";
 	} else {
 		log_error(INTERNAL_ERROR "Registering unsupported pool callback.");
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 74d421a..baa8609 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -900,7 +900,9 @@ cfg(global_cache_check_executable_CFG, "cache_check_executable", global_CFG_SECT
 	"Set to \"\" to skip this check.  (Not recommended.)\n"
 	"Also see cache_check_options.\n"
 	"The cache tools are available from the package\n"
-	"device-mapper-persistent-data.\n")
+	"device-mapper-persistent-data.\n"
+	"With cache_check version 5.0 or newer you should add\n"
+	"--clear-needs-check-flag.\n")
 
 cfg(global_cache_dump_executable_CFG, "cache_dump_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, CACHE_DUMP_CMD, vsn(2, 2, 108), "@CACHE_DUMP_CMD@", 0, NULL,
 	"The full path to the cache_dump command.\n"
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 491c64b..33f9d08 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -101,8 +101,16 @@
 #define DEFAULT_THIN_POOL_ZERO 1
 #define DEFAULT_POOL_METADATA_SPARE 1 /* thin + cache */
 
-#define DEFAULT_CACHE_CHECK_OPTION1 "-q"
-#define DEFAULT_CACHE_CHECK_OPTIONS_CONFIG "#S" DEFAULT_CACHE_CHECK_OPTION1
+#ifdef CACHE_CHECK_NEEDS_CHECK
+#  define DEFAULT_CACHE_CHECK_OPTION1 "-q"
+#  define DEFAULT_CACHE_CHECK_OPTION2 "--clear-needs-check-flag"
+#  define DEFAULT_CACHE_CHECK_OPTIONS_CONFIG "#S" DEFAULT_CACHE_CHECK_OPTION1 "#S" DEFAULT_CACHE_CHECK_OPTION2
+#else
+#  define DEFAULT_CACHE_CHECK_OPTION1 "-q"
+#  define DEFAULT_CACHE_CHECK_OPTION2 ""
+#  define DEFAULT_CACHE_CHECK_OPTIONS_CONFIG "#S" DEFAULT_CACHE_CHECK_OPTION1
+#endif
+
 #define DEFAULT_CACHE_REPAIR_OPTIONS ""
 #define DEFAULT_CACHE_REPAIR_OPTIONS_CONFIG NULL
 #define DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS 0
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 57de7a2..d9f5a7d 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -6,6 +6,10 @@
 /* The path to 'cache_check', if available. */
 #undef CACHE_CHECK_CMD
 
+/* Define to 1 if the external 'cache_check' tool requires the
+   --clear-needs-check-flag option */
+#undef CACHE_CHECK_NEEDS_CHECK
+
 /* The path to 'cache_dump', if available. */
 #undef CACHE_DUMP_CMD
 


