From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 14 Mar 2012 17:09:07 -0000
Subject: LVM2 ./configure ./configure.in ./WHATS_NEW li ...
Message-ID: <20120314170907.7456.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-14 17:09:00

Modified files:
	.              : configure configure.in WHATS_NEW 
	lib/misc       : configure.h.in 

Log message:
	Add --with-thin-check configure option
	
	If specified - use given path without test (Path could be empty)
	If autodetection is in use - check for command in available PATH.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.175&r2=1.176
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.190&r2=1.191
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2354&r2=1.2355
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.39&r2=1.40

--- LVM2/configure	2012/02/29 21:15:34	1.175
+++ LVM2/configure	2012/03/14 17:09:00	1.176
@@ -714,6 +714,7 @@
 PKG_CONFIG_LIBDIR
 PKG_CONFIG_PATH
 PKG_CONFIG
+THIN_CHECK_CMD
 POW_LIB
 LIBOBJS
 ALLOCA
@@ -808,6 +809,7 @@
 with_raid
 with_replicators
 with_thin
+with_thin_check
 enable_readline
 enable_realtime
 enable_ocf
@@ -1566,6 +1568,7 @@
                           [[TYPE=none]]
   --with-thin=TYPE        thin provisioning support: internal/shared/none
                           [[TYPE=none]]
+  --with-thin-check=PATH  thin_check tool: [[autodetect]]
   --with-ocfdir=DIR       install OCF files in DIR
                           [[PREFIX/lib/ocf/resource.d/lvm2]]
   --with-clvmd=TYPE       build cluster LVM Daemon
@@ -7007,6 +7010,70 @@
   *) as_fn_error $? "--with-thin parameter invalid ($THIN)" "$LINENO" 5 ;;
 esac
 
+case "$THIN" in
+  internal|shared)
+
+# Check whether --with-thin-check was given.
+if test "${with_thin_check+set}" = set; then :
+  withval=$with_thin_check; THIN_CHECK_CMD=$withval
+else
+  THIN_CHECK_CMD="autodetect"
+fi
+
+	# Empty means a config way to ignore thin checking
+	if test "$THIN_CHECK_CMD" = "autodetect"; then
+		# Extract the first word of "thin_check", so it can be a program name with args.
+set dummy thin_check; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if test "${ac_cv_path_THIN_CHECK_CMD+set}" = set; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $THIN_CHECK_CMD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_THIN_CHECK_CMD="$THIN_CHECK_CMD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+    ac_cv_path_THIN_CHECK_CMD="$as_dir/$ac_word$ac_exec_ext"
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
+THIN_CHECK_CMD=$ac_cv_path_THIN_CHECK_CMD
+if test -n "$THIN_CHECK_CMD"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $THIN_CHECK_CMD" >&5
+$as_echo "$THIN_CHECK_CMD" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+
+		test -z "$THIN_CHECK_CMD" && as_fn_error $? "thin_check not found in path $PATH" "$LINENO" 5
+	fi
+
+
+cat >>confdefs.h <<_ACEOF
+#define THIN_CHECK_CMD "$THIN_CHECK_CMD"
+_ACEOF
+
+	;;
+esac
+
+
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable readline" >&5
 $as_echo_n "checking whether to enable readline... " >&6; }
@@ -10422,6 +10489,7 @@
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_!
 lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
--- LVM2/configure.in	2012/02/29 21:15:34	1.190
+++ LVM2/configure.in	2012/03/14 17:09:00	1.191
@@ -411,6 +411,24 @@
   *) AC_MSG_ERROR([--with-thin parameter invalid ($THIN)]) ;;
 esac
 
+case "$THIN" in
+  internal|shared)
+	AC_ARG_WITH(thin-check,
+		AC_HELP_STRING([--with-thin-check=PATH],
+			       [thin_check tool: [[autodetect]]]),
+			       THIN_CHECK_CMD=$withval, THIN_CHECK_CMD="autodetect")
+	# Empty means a config way to ignore thin checking
+	if test "$THIN_CHECK_CMD" = "autodetect"; then
+		AC_PATH_PROG(THIN_CHECK_CMD, thin_check)
+		test -z "$THIN_CHECK_CMD" && AC_MSG_ERROR(thin_check not found in path $PATH)
+	fi
+
+	AC_DEFINE_UNQUOTED([THIN_CHECK_CMD], ["$THIN_CHECK_CMD"],
+			   [The path to 'thin_check', if available.])
+	;;
+esac
+
+
 ################################################################################
 dnl -- Disable readline
 AC_MSG_CHECKING(whether to enable readline)
@@ -1475,6 +1493,7 @@
 AC_SUBST(STATIC_LINK)
 AC_SUBST(TESTING)
 AC_SUBST(THIN)
+AC_SUBST(THIN_CHECK_CMD)
 AC_SUBST(UDEV_LIBS)
 AC_SUBST(UDEV_PC)
 AC_SUBST(UDEV_RULES)
--- LVM2/WHATS_NEW	2012/03/14 12:12:21	1.2354
+++ LVM2/WHATS_NEW	2012/03/14 17:09:00	1.2355
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Add --with-thin-check configure option for path to thin_check.
   Detect lvm binary path in lvmetad udev rules.
   Fix error message when pvmove LV activation fails with name already in use.
   Better structure layout for device_info in dev_subsystem_name().
--- LVM2/lib/misc/configure.h.in	2012/02/29 21:15:34	1.39
+++ LVM2/lib/misc/configure.h.in	2012/03/14 17:09:00	1.40
@@ -534,6 +534,9 @@
 /* Define to 1 if you have the ANSI C header files. */
 #undef STDC_HEADERS
 
+/* The path to 'thin_check', if available. */
+#undef THIN_CHECK_CMD
+
 /* Define to 1 to include built-in support for thin provisioning. */
 #undef THIN_INTERNAL
 


