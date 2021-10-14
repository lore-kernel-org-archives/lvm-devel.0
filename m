From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Oct 2021 21:37:10 +0000 (GMT)
Subject: main - configure: updates
Message-ID: <20211014213710.CD8893858419@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b73e1cd4b3edb5dabc631cca78f780012beb93fa
Commit:        b73e1cd4b3edb5dabc631cca78f780012beb93fa
Parent:        6635ff77e3680290c464a90ba9b2ee0170a2dc84
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 14 22:41:09 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 14 23:34:11 2021 +0200

configure: updates

---
 configure              | 292 +++++++++++++++++++++++--------------------------
 include/configure.h.in |   6 +
 lib/config/defaults.h  |   1 -
 make.tmpl.in           |  19 +++-
 4 files changed, 155 insertions(+), 163 deletions(-)

diff --git a/configure b/configure
index 1f333a6f2..1b3fe7080 100755
--- a/configure
+++ b/configure
@@ -668,7 +668,6 @@ SALCK_CFLAGS
 SACKPT_LIBS
 SACKPT_CFLAGS
 REPLICATORS
-READLINE_LIBS
 RT_LIBS
 QUORUM_LIBS
 QUORUM_CFLAGS
@@ -755,6 +754,8 @@ BUILD_LVMDBUSD
 BUILD_DMEVENTD
 BUILD_CMIRRORD
 BLKID_PC
+READLINE_LIBS
+READLINE_CFLAGS
 MODPROBE_CMD
 MSGFMT
 EDITLINE_LIBS
@@ -776,12 +777,6 @@ SYSTEMD_LIBS
 SYSTEMD_CFLAGS
 BLKID_LIBS
 BLKID_CFLAGS
-APP_MACHINEID_LIBS
-APP_MACHINEID_CFLAGS
-NOTIFY_DBUS_LIBS
-NOTIFY_DBUS_CFLAGS
-BLKID_LIBS
-BLKID_CFLAGS
 LOCKD_IDM_LIBS
 LOCKD_IDM_CFLAGS
 LOCKD_DLM_CONTROL_LIBS
@@ -912,6 +907,7 @@ with_device_uid
 with_device_gid
 with_device_mode
 with_device_nodes_on
+with_default_use_devices_file
 with_default_name_mangling
 with_snapshots
 with_mirrors
@@ -961,6 +957,7 @@ enable_use_lvmpolld
 with_lvmpolld_pidfile
 enable_dmfilemapd
 enable_notify_dbus
+enable_systemd_journal
 enable_app_machineid
 enable_blkid_wiping
 enable_udev_systemd_background_jobs
@@ -1032,21 +1029,17 @@ LOCKD_DLM_CONTROL_CFLAGS
 LOCKD_DLM_CONTROL_LIBS
 LOCKD_IDM_CFLAGS
 LOCKD_IDM_LIBS
-NOTIFY_DBUS_CFLAGS
-NOTIFY_DBUS_LIBS
-APP_MACHINEID_CFLAGS
-APP_MACHINEID_LIBS
 BLKID_CFLAGS
 BLKID_LIBS
-NOTIFY_DBUS_CFLAGS
-NOTIFY_DBUS_LIBS
 SYSTEMD_CFLAGS
 SYSTEMD_LIBS
 UDEV_CFLAGS
 UDEV_LIBS
 PYTHON
 EDITLINE_CFLAGS
-EDITLINE_LIBS'
+EDITLINE_LIBS
+READLINE_CFLAGS
+READLINE_LIBS'
 
 
 # Initialize some variables set by options.
@@ -1700,7 +1693,9 @@ Optional Features:
   --disable-use-lvmpolld  disable usage of LVM Poll Daemon
   --enable-dmfilemapd     enable the dmstats filemap daemon
   --enable-notify-dbus    enable LVM notification using dbus
-  --enable-app-machineid  enable LVM system ID using app-specific machine-id
+  --disable-systemd-journal
+                          disable LVM systemd journaling
+  --disable-app-machineid disable LVM system ID using app-specific machine-id
   --disable-blkid_wiping  disable libblkid detection of signatures when wiping
                           and use native code instead
   --disable-udev-systemd-background-jobs
@@ -1737,6 +1732,8 @@ Optional Packages:
   --with-device-mode=MODE set the mode used for new device nodes [MODE=0600]
   --with-device-nodes-on=ON
                           create nodes on resume or create [ON=resume]
+  --with-default-use-devices-file
+                          default for lvm.conf devices/use_devicesfile = [0]
   --with-default-name-mangling=MANGLING
                           default name mangling: auto/none/hex [auto]
   --with-snapshots=TYPE   snapshot support: internal/none [internal]
@@ -1859,21 +1856,6 @@ Some influential environment variables:
   BLKID_CFLAGS
               C compiler flags for BLKID, overriding pkg-config
   BLKID_LIBS  linker flags for BLKID, overriding pkg-config
-  NOTIFY_DBUS_CFLAGS
-              C compiler flags for NOTIFY_DBUS, overriding pkg-config
-  NOTIFY_DBUS_LIBS
-              linker flags for NOTIFY_DBUS, overriding pkg-config
-  APP_MACHINEID_CFLAGS
-              C compiler flags for APP_MACHINEID, overriding pkg-config
-  APP_MACHINEID_LIBS
-              linker flags for APP_MACHINEID, overriding pkg-config
-  BLKID_CFLAGS
-              C compiler flags for BLKID, overriding pkg-config
-  BLKID_LIBS  linker flags for BLKID, overriding pkg-config
-  SYSTEMD_CFLAGS
-              C compiler flags for SYSTEMD, overriding pkg-config
-  SYSTEMD_LIBS
-              linker flags for SYSTEMD, overriding pkg-config
   UDEV_CFLAGS C compiler flags for UDEV, overriding pkg-config
   UDEV_LIBS   linker flags for UDEV, overriding pkg-config
   PYTHON      the Python interpreter
@@ -1881,6 +1863,10 @@ Some influential environment variables:
               C compiler flags for EDITLINE, overriding pkg-config
   EDITLINE_LIBS
               linker flags for EDITLINE, overriding pkg-config
+  READLINE_CFLAGS
+              C compiler flags for readline
+  READLINE_LIBS
+              linker flags for readline
 
 Use these variables to override the choices made by `configure' or to help
 it to find libraries and programs with nonstandard names/locations.
@@ -6718,18 +6704,17 @@ fi
 
 
 
-    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for __builtin_ffs" >&5
-printf %s "checking for __builtin_ffs... " >&6; }
-if test ${ax_cv_have___builtin_ffs+y}
-then :
-  printf %s "(cached) " >&6
-else $as_nop
+    { $as_echo "$as_me:${as_lineno-$LINENO}: checking for __builtin_ffs" >&5
+$as_echo_n "checking for __builtin_ffs... " >&6; }
+if ${ax_cv_have___builtin_ffs+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
 
         cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
 int
-main (void)
+main ()
 {
 
             __builtin_ffs(0)
@@ -6738,26 +6723,31 @@ main (void)
   return 0;
 }
 _ACEOF
-if ac_fn_c_try_link "$LINENO"
-then :
+if ac_fn_c_try_link "$LINENO"; then :
   ax_cv_have___builtin_ffs=yes
-else $as_nop
+else
   ax_cv_have___builtin_ffs=no
 fi
-rm -f core conftest.err conftest.$ac_objext conftest.beam \
+rm -f core conftest.err conftest.$ac_objext \
     conftest$ac_exeext conftest.$ac_ext
 
 fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ax_cv_have___builtin_ffs" >&5
-printf "%s\n" "$ax_cv_have___builtin_ffs" >&6; }
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ax_cv_have___builtin_ffs" >&5
+$as_echo "$ax_cv_have___builtin_ffs" >&6; }
 
-    if test yes = $ax_cv_have___builtin_ffs
-then :
+    if test yes = $ax_cv_have___builtin_ffs; then :
 
-printf "%s\n" "#define HAVE___BUILTIN_FFS 1" >>confdefs.h
+cat >>confdefs.h <<_ACEOF
+#define HAVE___BUILTIN_FFS 1
+_ACEOF
 
 fi
 
+
+
+
+
+
 $as_echo "#define _GNU_SOURCE 1" >>confdefs.h
 
 
@@ -6783,25 +6773,17 @@ else
 fi
 done
 
-ac_fn_c_check_func "$LINENO" "ffs" "ac_cv_func_ffs"
-if test "x$ac_cv_func_ffs" = xyes
-then :
-  printf "%s\n" "#define HAVE_FFS 1" >>confdefs.h
-
-fi
-ac_fn_c_check_func "$LINENO" "prlimit" "ac_cv_func_prlimit"
-if test "x$ac_cv_func_prlimit" = xyes
-then :
-  printf "%s\n" "#define HAVE_PRLIMIT 1" >>confdefs.h
-
-fi
-ac_fn_c_check_func "$LINENO" "versionsort" "ac_cv_func_versionsort"
-if test "x$ac_cv_func_versionsort" = xyes
-then :
-  printf "%s\n" "#define HAVE_VERSIONSORT 1" >>confdefs.h
+for ac_func in ffs prlimit versionsort
+do :
+  as_ac_var=`$as_echo "ac_cv_func_$ac_func" | $as_tr_sh`
+ac_fn_c_check_func "$LINENO" "$ac_func" "$as_ac_var"
+if eval test \"x\$"$as_ac_var"\" = x"yes"; then :
+  cat >>confdefs.h <<_ACEOF
+#define `$as_echo "HAVE_$ac_func" | $as_tr_cpp` 1
+_ACEOF
 
 fi
-
+done
 
 # The Ultrix 4.2 mips builtin alloca declared by alloca.h only works
 # for constant arguments.  Useless!
@@ -8366,7 +8348,6 @@ test "x$prefix" = xNONE && prefix=$ac_default_prefix
 # Let make expand exec_prefix.
 test "x$exec_prefix" = xNONE && exec_prefix='${prefix}'
 
-
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking file owner" >&5
 $as_echo_n "checking file owner... " >&6; }
@@ -8476,6 +8457,29 @@ cat >>confdefs.h <<_ACEOF
 _ACEOF
 
 
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking default for use_devicesfile" >&5
+$as_echo_n "checking default for use_devicesfile... " >&6; }
+
+# Check whether --with-default-use-devices-file was given.
+if test "${with_default_use_devices_file+set}" = set; then :
+  withval=$with_default_use_devices_file; DEFAULT_USE_DEVICES_FILE=$enableval
+else
+  DEFAULT_USE_DEVICES_FILE=0
+fi
+
+case "$DEFAULT_USE_DEVICES_FILE" in
+ 0|1);;
+ *) as_fn_error $? "--with-default-use-devices-file parameter invalid" "$LINENO" 5;;
+esac
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $DEFAULT_USE_DEVICES_FILE" >&5
+$as_echo "$DEFAULT_USE_DEVICES_FILE" >&6; }
+
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_USE_DEVICES_FILE $DEFAULT_USE_DEVICES_FILE
+_ACEOF
+
+
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking default name mangling" >&5
 $as_echo_n "checking default name mangling... " >&6; }
 
@@ -9856,13 +9860,13 @@ _ACEOF
 # Do we want to link lvm2 with a big library for vdoformating ?
 #
 #AC_ARG_WITH(vdo-include,
-#	    AC_HELP_STRING([--with-vdo-include=PATH],
+#	    AS_HELP_STRING([--with-vdo-include=PATH],
 #			   [vdo support: Path to utils headers: [/usr/include/vdo/utils]]),
 #			   VDO_INCLUDE=$withval, VDO_INCLUDE="/usr/include/vdo/utils")
 #AC_MSG_RESULT($VDO_INCLUDE)
 #
 #AC_ARG_WITH(vdo-lib,
-#            AC_HELP_STRING([--with-vdo-lib=PATH],
+#            AS_HELP_STRING([--with-vdo-lib=PATH],
 #                           [vdo support: Path to utils lib: [/usr/lib]]),
 #                           VDO_LIB=$withval, VDO_LIB="/usr/lib")
 #AC_MSG_RESULT($VDO_LIB)
@@ -11559,6 +11563,7 @@ fi
 
 fi
 
+SYSTEMD_MIN_VERSION=
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build notifydbus" >&5
 $as_echo_n "checking whether to build notifydbus... " >&6; }
@@ -11572,125 +11577,91 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $NOTIFYDBUS_SUPPORT" >&5
 $as_echo "$NOTIFYDBUS_SUPPORT" >&6; }
 
-if test "$NOTIFYDBUS_SUPPORT" = yes; then
+if test "$NOTIFYDBUS_SUPPORT" = yes; then :
 
 $as_echo "#define NOTIFYDBUS_SUPPORT 1" >>confdefs.h
 
-	SYSTEMD_LIBS="-lsystemd"
+      SYSTEMD_MIN_VERSION=221
 fi
 
 ################################################################################
-if test "$NOTIFYDBUS_SUPPORT" = yes; then
-
-pkg_failed=no
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for NOTIFY_DBUS" >&5
-$as_echo_n "checking for NOTIFY_DBUS... " >&6; }
-
-if test -n "$NOTIFY_DBUS_CFLAGS"; then
-    pkg_cv_NOTIFY_DBUS_CFLAGS="$NOTIFY_DBUS_CFLAGS"
- elif test -n "$PKG_CONFIG"; then
-    if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 221\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "systemd >= 221") 2>&5
-  ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
-  test $ac_status = 0; }; then
-  pkg_cv_NOTIFY_DBUS_CFLAGS=`$PKG_CONFIG --cflags "systemd >= 221" 2>/dev/null`
-		      test "x$?" != "x0" && pkg_failed=yes
+ac_fn_c_check_header_mongrel "$LINENO" "systemd/sd-journal.h" "ac_cv_header_systemd_sd_journal_h" "$ac_includes_default"
+if test "x$ac_cv_header_systemd_sd_journal_h" = xyes; then :
+  SYSTEMD_JOURNAL_SUPPORT=yes
 else
-  pkg_failed=yes
-fi
- else
-    pkg_failed=untried
+  SYSTEMD_JOURNAL_SUPPORT=no
 fi
-if test -n "$NOTIFY_DBUS_LIBS"; then
-    pkg_cv_NOTIFY_DBUS_LIBS="$NOTIFY_DBUS_LIBS"
- elif test -n "$PKG_CONFIG"; then
-    if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 221\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "systemd >= 221") 2>&5
-  ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
-  test $ac_status = 0; }; then
-  pkg_cv_NOTIFY_DBUS_LIBS=`$PKG_CONFIG --libs "systemd >= 221" 2>/dev/null`
-		      test "x$?" != "x0" && pkg_failed=yes
-else
-  pkg_failed=yes
+
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to log to systemd journal" >&5
+$as_echo_n "checking whether to log to systemd journal... " >&6; }
+# Check whether --enable-systemd-journal was given.
+if test "${enable_systemd_journal+set}" = set; then :
+  enableval=$enable_systemd_journal; if test "$enableval" = yes && test "$SYSTEMD_JOURNAL_SUPPORT" = no; then :
+  as_fn_error $? "Enabling systemd journaling requires systemd/sd-journal.h." "$LINENO" 5
 fi
- else
-    pkg_failed=untried
+	      SYSTEMD_JOURNAL_SUPPORT=$enableval
 fi
 
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $SYSTEMD_JOURNAL_SUPPORT" >&5
+$as_echo "$SYSTEMD_JOURNAL_SUPPORT" >&6; }
 
+if test "$SYSTEMD_JOURNAL_SUPPORT" = yes; then :
 
-if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+$as_echo "#define SYSTEMD_JOURNAL_SUPPORT 1" >>confdefs.h
 
-if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
-        _pkg_short_errors_supported=yes
-else
-        _pkg_short_errors_supported=no
+      SYSTEMD_MIN_VERSION=221
 fi
-        if test $_pkg_short_errors_supported = yes; then
-	        NOTIFY_DBUS_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "systemd >= 221" 2>&1`
-        else
-	        NOTIFY_DBUS_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "systemd >= 221" 2>&1`
-        fi
-	# Put the nasty error message in config.log where it belongs
-	echo "$NOTIFY_DBUS_PKG_ERRORS" >&5
 
-	$bailout
-elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
-	$bailout
+################################################################################
+ac_fn_c_check_header_mongrel "$LINENO" "systemd/sd-id128.h" "ac_cv_header_systemd_sd_id128_h" "$ac_includes_default"
+if test "x$ac_cv_header_systemd_sd_id128_h" = xyes; then :
+  APP_MACHINEID_SUPPORT=yes
 else
-	NOTIFY_DBUS_CFLAGS=$pkg_cv_NOTIFY_DBUS_CFLAGS
-	NOTIFY_DBUS_LIBS=$pkg_cv_NOTIFY_DBUS_LIBS
-        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-$as_echo "yes" >&6; }
-	HAVE_NOTIFY_DBUS=yes
-fi
+  APP_MACHINEID_SUPPORT=no
 fi
 
-################################################################################
+
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build appmachineid" >&5
 $as_echo_n "checking whether to build appmachineid... " >&6; }
 # Check whether --enable-app-machineid was given.
 if test "${enable_app_machineid+set}" = set; then :
-  enableval=$enable_app_machineid; APP_MACHINEID_SUPPORT=$enableval
-else
-  APP_MACHINEID_SUPPORT=no
+  enableval=$enable_app_machineid; if test "$enableval" = yes && test "$APP_MACHINEID_SUPPORT" = no; then :
+  as_fn_error $? "Enabling app machineid requires systemd/sd-id128.h." "$LINENO" 5
+fi
+	      APP_MACHINEID_SUPPORT=$enableval
 fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $APP_MACHINEID_SUPPORT" >&5
 $as_echo "$APP_MACHINEID_SUPPORT" >&6; }
 
-if test "$APP_MACHINEID_SUPPORT" = yes; then
+if test "$APP_MACHINEID_SUPPORT" = yes; then :
 
 $as_echo "#define APP_MACHINEID_SUPPORT 1" >>confdefs.h
 
-	SYSTEMD_LIBS="-lsystemd"
+      SYSTEMD_MIN_VERSION=234
 fi
 
-################################################################################
-if test "$APP_MACHINEID_SUPPORT" = yes; then
+if test -n "SYSTEMD_MIN_VERSION"; then :
+    SYSTEMD_CFLAGS
+              C compiler flags for SYSTEMD, overriding pkg-config
+  SYSTEMD_LIBS
+              linker flags for SYSTEMD, overriding pkg-config
 
 pkg_failed=no
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for APP_MACHINEID" >&5
-$as_echo_n "checking for APP_MACHINEID... " >&6; }
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for SYSTEMD" >&5
+$as_echo_n "checking for SYSTEMD... " >&6; }
 
-if test -n "$APP_MACHINEID_CFLAGS"; then
-    pkg_cv_APP_MACHINEID_CFLAGS="$APP_MACHINEID_CFLAGS"
+if test -n "$SYSTEMD_CFLAGS"; then
+    pkg_cv_SYSTEMD_CFLAGS="$SYSTEMD_CFLAGS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 234\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "systemd >= 234") 2>&5
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= \"\$SYSTEMD_MIN_VERSION\"\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "systemd >= "$SYSTEMD_MIN_VERSION"") 2>&5
   ac_status=$?
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  pkg_cv_APP_MACHINEID_CFLAGS=`$PKG_CONFIG --cflags "systemd >= 234" 2>/dev/null`
+  pkg_cv_SYSTEMD_CFLAGS=`$PKG_CONFIG --cflags "systemd >= "$SYSTEMD_MIN_VERSION"" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
@@ -11698,16 +11669,16 @@ fi
  else
     pkg_failed=untried
 fi
-if test -n "$APP_MACHINEID_LIBS"; then
-    pkg_cv_APP_MACHINEID_LIBS="$APP_MACHINEID_LIBS"
+if test -n "$SYSTEMD_LIBS"; then
+    pkg_cv_SYSTEMD_LIBS="$SYSTEMD_LIBS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 234\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "systemd >= 234") 2>&5
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= \"\$SYSTEMD_MIN_VERSION\"\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "systemd >= "$SYSTEMD_MIN_VERSION"") 2>&5
   ac_status=$?
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  pkg_cv_APP_MACHINEID_LIBS=`$PKG_CONFIG --libs "systemd >= 234" 2>/dev/null`
+  pkg_cv_SYSTEMD_LIBS=`$PKG_CONFIG --libs "systemd >= "$SYSTEMD_MIN_VERSION"" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
@@ -11728,12 +11699,12 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        APP_MACHINEID_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "systemd >= 234" 2>&1`
+	        SYSTEMD_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "systemd >= "$SYSTEMD_MIN_VERSION"" 2>&1`
         else
-	        APP_MACHINEID_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "systemd >= 234" 2>&1`
+	        SYSTEMD_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "systemd >= "$SYSTEMD_MIN_VERSION"" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
-	echo "$APP_MACHINEID_PKG_ERRORS" >&5
+	echo "$SYSTEMD_PKG_ERRORS" >&5
 
 	$bailout
 elif test $pkg_failed = untried; then
@@ -11741,12 +11712,13 @@ elif test $pkg_failed = untried; then
 $as_echo "no" >&6; }
 	$bailout
 else
-	APP_MACHINEID_CFLAGS=$pkg_cv_APP_MACHINEID_CFLAGS
-	APP_MACHINEID_LIBS=$pkg_cv_APP_MACHINEID_LIBS
+	SYSTEMD_CFLAGS=$pkg_cv_SYSTEMD_CFLAGS
+	SYSTEMD_LIBS=$pkg_cv_SYSTEMD_LIBS
         { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 $as_echo "yes" >&6; }
-	HAVE_APP_MACHINEID=yes
+
 fi
+      SYSTEMD_LIBS="-lsystemd"
 fi
 
 ################################################################################
@@ -14386,7 +14358,6 @@ cat >>confdefs.h <<_ACEOF
 _ACEOF
 
 
-################################################################################
 
 
 
@@ -14400,6 +14371,15 @@ _ACEOF
 
 
 
+################################################################################
+
+
+
+
+
+
+
+
 
 
 
diff --git a/include/configure.h.in b/include/configure.h.in
index 703ac0432..7efa83661 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -90,6 +90,9 @@
 /* Use blkid wiping by default. */
 #undef DEFAULT_USE_BLKID_WIPING
 
+/* Default for lvm.conf use_devicefile. */
+#undef DEFAULT_USE_DEVICES_FILE
+
 /* Use lvmlockd by default. */
 #undef DEFAULT_USE_LVMLOCKD
 
@@ -668,6 +671,9 @@
 /* Define to 1 if strerror_r returns char *. */
 #undef STRERROR_R_CHAR_P
 
+/* Define to 1 to include code that uses systemd journal. */
+#undef SYSTEMD_JOURNAL_SUPPORT
+
 /* Path to testsuite data */
 #undef TESTSUITE_DATA
 
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 54eba3723..1b1568a7b 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -322,7 +322,6 @@
 
 #define DEFAULT_MD_COMPONENT_CHECKS "auto"
 
-#define DEFAULT_USE_DEVICES_FILE 1
 #define DEFAULT_DEVICES_FILE "system.devices"
 
 #define DEFAULT_SEARCH_FOR_DEVNAMES "auto"
diff --git a/make.tmpl.in b/make.tmpl.in
index 1e6393a7b..cccda10d6 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -73,22 +73,29 @@ CLDFLAGS += @CLDFLAGS@
 ELDFLAGS += @ELDFLAGS@
 LDDEPS += @LDDEPS@
 LIB_SUFFIX = @LIB_SUFFIX@
+USE_TRACKING = @USE_TRACKING@
+
 DL_LIBS = @DL_LIBS@
 RT_LIBS = @RT_LIBS@
 M_LIBS = @M_LIBS@
-AIO_LIBS = @AIO_LIBS@
 AIO_CFLAGS = @AIO_CFLAGS@
+AIO_LIBS = @AIO_LIBS@
+BLKID_CFLAGS = @BLKID_CFLAGS@
+BLKID_LIBS = @BLKID_LIBS@
+CPG_CFLAGS = @CPG_CFLAGS@
+CPG_LIBS = @CPG_LIBS@
+EDITLINE_CFLAGS = @EDITLINE_CFLAGS@
+EDITLINE_LIBS = @EDITLINE_LIBS@
 PTHREAD_LIBS = @PTHREAD_LIBS@
+READLINE_CFLAGS = @READLINE_CFLAGS@
 READLINE_LIBS = @READLINE_LIBS@
-EDITLINE_LIBS = @EDITLINE_LIBS@
 SELINUX_LIBS = @SELINUX_LIBS@
+SYSTEMD_CFLAGS = @SYSTEMD_CFLAGS@
+SYSTEMD_LIBS = @SYSTEMD_LIBS@
 UDEV_CFLAGS = @UDEV_CFLAGS@
 UDEV_LIBS = @UDEV_LIBS@
-BLKID_CFLAGS = @BLKID_CFLAGS@
-BLKID_LIBS = @BLKID_LIBS@
-SYSTEMD_LIBS = @SYSTEMD_LIBS@
 VALGRIND_CFLAGS = @VALGRIND_CFLAGS@
-USE_TRACKING = @USE_TRACKING@
+VALGRIND_LIBS = @VALGRIND_LIBS@
 
 # Setup directory variables
 prefix = @prefix@


