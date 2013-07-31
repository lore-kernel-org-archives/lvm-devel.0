From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 31 Jul 2013 13:36:33 +0000 (UTC)
Subject: master - thin: add thin_repair and thin_dump options
Message-ID: <20130731133633.1404460319@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=22fc80982aa08ef8a907fc858a29a30c2d9293a7
Commit:        22fc80982aa08ef8a907fc858a29a30c2d9293a7
Parent:        ea605d1ec72960cf8076fb0260dd151a32750ff6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 31 14:38:10 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 31 15:30:47 2013 +0200

thin: add thin_repair and thin_dump options

Add new configure lvm.conf options for binaries thin_repair
and thin_dump.

Those are part of device-mapper-persistent-data package
and will be used for recovery of thin_pool.
---
 WHATS_NEW                    |    2 +
 conf/example.conf.in         |   28 ++++++++--
 configure                    |  124 ++++++++++++++++++++++++++++++++++++++++++
 configure.in                 |   26 +++++++++
 lib/config/config_settings.h |    3 +
 lib/config/defaults.h        |    1 +
 lib/misc/configure.h.in      |    6 ++
 7 files changed, 186 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 71228c9..6d59265 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.100 -
 ================================
+  Add --with-thin-repair and --with-thin-dump configure options.
+  Add lvm.conf thin_repair/dump_executable and thin_repair_options.
   Require 1.9 thin pool target version for online thin pool metadata resize.
   Ignore previous LV seg with alloc contiguous & cling when num stripes varies.
   Fix segfault if devices/global_filter is not specified correctly.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 2032a81..0e313c8 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -561,11 +561,29 @@ global {
     # The thin tools are available as part of the device-mapper-persistent-data
     # package from https://github.com/jthornber/thin-provisioning-tools.
     #
-    thin_check_executable = "@THIN_CHECK_CMD@"
+    # thin_check_executable = "@THIN_CHECK_CMD@"
 
-    # String with options passed with thin_check command. By default,
-    # option '-q' is for quiet output.
-    thin_check_options = [ "-q" ]
+    # Array of string options passed with thin_check command. By default,
+    # option "-q" is for quiet output.
+    # With thin_check version 2.1 or newer you can add "--ignore-non-fatal-errors"
+    # to let it pass through ignoreable errors and fix them later.
+    #
+    # thin_check_options = [ "-q" ]
+
+    # Full path of the utility called to repair a thin metadata device
+    # is in a state that allows it to be used.
+    # Each time a thin pool needs repair this utility is executed.
+    # See thin_check_executable how to obtain binaries.
+    #
+    # thin_repair_executable = "@THIN_REPAIR_CMD@"
+
+    # Array of extra string options passed with thin_repair command.
+    # thin_repair_options = [ "" ]
+
+    # Full path of the utility called to dump thin metadata content.
+    # See thin_check_executable how to obtain binaries.
+    #
+    # thin_dump_executable = "@THIN_DUMP_CMD@"
 
     # If set, given features are not used by thin driver.
     # This can be helpful not just for testing, but i.e. allows to avoid
@@ -574,6 +592,8 @@ global {
     #   block_size
     #   discards
     #   discards_non_power_2
+    #   external_origin
+    #   metadata_resize
     #
     # thin_disabled_features = [ "discards", "block_size" ]
 }
diff --git a/configure b/configure
index 12272d1..a9a2830 100755
--- a/configure
+++ b/configure
@@ -730,6 +730,8 @@ PKGCONFIGINIT_CFLAGS
 PKG_CONFIG_LIBDIR
 PKG_CONFIG_PATH
 PKG_CONFIG
+THIN_REPAIR_CMD
+THIN_DUMP_CMD
 THIN_CHECK_CMD
 POW_LIB
 LIBOBJS
@@ -826,6 +828,8 @@ with_raid
 with_replicators
 with_thin
 with_thin_check
+with_thin_dump
+with_thin_repair
 enable_readline
 enable_realtime
 enable_ocf
@@ -1598,6 +1602,8 @@ Optional Packages:
   --with-thin=TYPE        thin provisioning support: internal/shared/none
                           [[TYPE=none]]
   --with-thin-check=PATH  thin_check tool: [[autodetect]]
+  --with-thin-dump=PATH   thin_dump tool: [[autodetect]]
+  --with-thin-repair=PATH thin_repair tool: [[autodetect]]
   --with-ocfdir=DIR       install OCF files in DIR
                           [[PREFIX/lib/ocf/resource.d/lvm2]]
   --with-default-pid-dir=PID_DIR
@@ -7108,6 +7114,110 @@ fi
 
 		test -z "$THIN_CHECK_CMD" && as_fn_error $? "thin_check not found in path $PATH" "$LINENO" 5
 	fi
+
+# Check whether --with-thin-dump was given.
+if test "${with_thin_dump+set}" = set; then :
+  withval=$with_thin_dump; THIN_DUMP_CMD=$withval
+else
+  THIN_DUMP_CMD="autodetect"
+fi
+
+	# Empty means a config way to ignore thin checking
+	if test "$THIN_DUMP_CMD" = "autodetect"; then
+		# Extract the first word of "thin_dump", so it can be a program name with args.
+set dummy thin_dump; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_THIN_DUMP_CMD+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $THIN_DUMP_CMD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_THIN_DUMP_CMD="$THIN_DUMP_CMD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_THIN_DUMP_CMD="$as_dir/$ac_word$ac_exec_ext"
+    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+  done
+IFS=$as_save_IFS
+
+  ;;
+esac
+fi
+THIN_DUMP_CMD=$ac_cv_path_THIN_DUMP_CMD
+if test -n "$THIN_DUMP_CMD"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $THIN_DUMP_CMD" >&5
+$as_echo "$THIN_DUMP_CMD" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+
+		test -z "$THIN_DUMP_CMD" && as_fn_error $? "thin_dump not found in path $PATH" "$LINENO" 5
+	fi
+
+# Check whether --with-thin-repair was given.
+if test "${with_thin_repair+set}" = set; then :
+  withval=$with_thin_repair; THIN_REPAIR_CMD=$withval
+else
+  THIN_REPAIR_CMD="autodetect"
+fi
+
+	# Empty means a config way to ignore thin checking
+	if test "$THIN_REPAIR_CMD" = "autodetect"; then
+		# Extract the first word of "thin_repair", so it can be a program name with args.
+set dummy thin_repair; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_THIN_REPAIR_CMD+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $THIN_REPAIR_CMD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_THIN_REPAIR_CMD="$THIN_REPAIR_CMD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_THIN_REPAIR_CMD="$as_dir/$ac_word$ac_exec_ext"
+    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+  done
+IFS=$as_save_IFS
+
+  ;;
+esac
+fi
+THIN_REPAIR_CMD=$ac_cv_path_THIN_REPAIR_CMD
+if test -n "$THIN_REPAIR_CMD"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $THIN_REPAIR_CMD" >&5
+$as_echo "$THIN_REPAIR_CMD" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+
+		test -z "$THIN_REPAIR_CMD" && as_fn_error $? "thin_repair not found in path $PATH" "$LINENO" 5
+	fi
 	;;
 esac
 
@@ -7118,6 +7228,18 @@ _ACEOF
 
 
 
+cat >>confdefs.h <<_ACEOF
+#define THIN_DUMP_CMD "$THIN_DUMP_CMD"
+_ACEOF
+
+
+
+cat >>confdefs.h <<_ACEOF
+#define THIN_REPAIR_CMD "$THIN_REPAIR_CMD"
+_ACEOF
+
+
+
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable readline" >&5
 $as_echo_n "checking whether to enable readline... " >&6; }
@@ -10809,6 +10931,8 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile conf/Makefile conf/example.conf conf/default.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_
 init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.socket scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
diff --git a/configure.in b/configure.in
index 97ddc1d..611ab37 100644
--- a/configure.in
+++ b/configure.in
@@ -424,12 +424,36 @@ case "$THIN" in
 		AC_PATH_PROG(THIN_CHECK_CMD, thin_check)
 		test -z "$THIN_CHECK_CMD" && AC_MSG_ERROR(thin_check not found in path $PATH)
 	fi
+	AC_ARG_WITH(thin-dump,
+		AC_HELP_STRING([--with-thin-dump=PATH],
+			       [thin_dump tool: [[autodetect]]]),
+			       THIN_DUMP_CMD=$withval, THIN_DUMP_CMD="autodetect")
+	# Empty means a config way to ignore thin checking
+	if test "$THIN_DUMP_CMD" = "autodetect"; then
+		AC_PATH_PROG(THIN_DUMP_CMD, thin_dump)
+		test -z "$THIN_DUMP_CMD" && AC_MSG_ERROR(thin_dump not found in path $PATH)
+	fi
+	AC_ARG_WITH(thin-repair,
+		AC_HELP_STRING([--with-thin-repair=PATH],
+			       [thin_repair tool: [[autodetect]]]),
+			       THIN_REPAIR_CMD=$withval, THIN_REPAIR_CMD="autodetect")
+	# Empty means a config way to ignore thin checking
+	if test "$THIN_REPAIR_CMD" = "autodetect"; then
+		AC_PATH_PROG(THIN_REPAIR_CMD, thin_repair)
+		test -z "$THIN_REPAIR_CMD" && AC_MSG_ERROR(thin_repair not found in path $PATH)
+	fi
 	;;
 esac
 
 AC_DEFINE_UNQUOTED([THIN_CHECK_CMD], ["$THIN_CHECK_CMD"],
 		   [The path to 'thin_check', if available.])
 
+AC_DEFINE_UNQUOTED([THIN_DUMP_CMD], ["$THIN_DUMP_CMD"],
+		   [The path to 'thin_dump', if available.])
+
+AC_DEFINE_UNQUOTED([THIN_REPAIR_CMD], ["$THIN_REPAIR_CMD"],
+		   [The path to 'thin_repair', if available.])
+
 
 ################################################################################
 dnl -- Disable readline
@@ -1598,6 +1622,8 @@ AC_SUBST(STATIC_LINK)
 AC_SUBST(TESTING)
 AC_SUBST(THIN)
 AC_SUBST(THIN_CHECK_CMD)
+AC_SUBST(THIN_DUMP_CMD)
+AC_SUBST(THIN_REPAIR_CMD)
 AC_SUBST(UDEV_LIBS)
 AC_SUBST(UDEV_PC)
 AC_SUBST(UDEV_RULES)
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 16a9437..3992764 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -160,6 +160,9 @@ cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL,
 cfg(global_thin_check_executable_CFG, "thin_check_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, THIN_CHECK_CMD, vsn(2, 2, 94), NULL)
 cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_THIN_CHECK_OPTIONS, vsn(2, 2, 96), NULL)
 cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S", vsn(2, 2, 99), NULL)
+cfg(global_thin_dump_executable_CFG, "thin_dump_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, THIN_DUMP_CMD, vsn(2, 2, 100), NULL)
+cfg(global_thin_repair_executable_CFG, "thin_repair_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, THIN_REPAIR_CMD, vsn(2, 2, 100), NULL)
+cfg_array(global_thin_repair_options_CFG, "thin_repair_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_THIN_REPAIR_OPTIONS, vsn(2, 2, 100), NULL)
 
 cfg(activation_checks_CFG, "checks", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ACTIVATION_CHECKS, vsn(2, 2, 86), NULL)
 cfg(activation_udev_sync_CFG, "udev_sync", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_UDEV_SYNC, vsn(2, 2, 51), NULL)
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 34ce2ea..5af0f00 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -66,6 +66,7 @@
 #define DEFAULT_BACKGROUND_POLLING 1
 
 #define DEFAULT_THIN_CHECK_OPTIONS "-q"
+#define DEFAULT_THIN_REPAIR_OPTIONS ""
 #define DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS 0
 #define DEFAULT_THIN_POOL_MAX_METADATA_SIZE (16 * 1024 * 1024)  /* KB */
 #define DEFAULT_THIN_POOL_MIN_METADATA_SIZE 2048  /* KB */
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index aae4f24..13ba882 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -546,9 +546,15 @@
 /* The path to 'thin_check', if available. */
 #undef THIN_CHECK_CMD
 
+/* The path to 'thin_dump', if available. */
+#undef THIN_DUMP_CMD
+
 /* Define to 1 to include built-in support for thin provisioning. */
 #undef THIN_INTERNAL
 
+/* The path to 'thin_repair', if available. */
+#undef THIN_REPAIR_CMD
+
 /* Define to 1 if you can safely include both <sys/time.h> and <time.h>. */
 #undef TIME_WITH_SYS_TIME
 


