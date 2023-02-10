From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Feb 2023 19:56:14 +0000 (GMT)
Subject: main - configure: update
Message-ID: <20230210195614.5C3FF3858414@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=21edfc4a5ea11d888f506b41d36a0ec983dc63c9
Commit:        21edfc4a5ea11d888f506b41d36a0ec983dc63c9
Parent:        391138ff303c85999782e1341a5e1d8a28810486
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 10 19:50:22 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 10 20:54:05 2023 +0100

configure: update

---
 configure | 164 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 147 insertions(+), 17 deletions(-)

diff --git a/configure b/configure
index 2406deddc..e84333ec7 100755
--- a/configure
+++ b/configure
@@ -805,6 +805,7 @@ UDEV_LIBS
 UDEV_CFLAGS
 BLKID_LIBS
 BLKID_CFLAGS
+SYSTEMD_RUN_CMD
 SYSTEMD_LIBS
 SYSTEMD_CFLAGS
 LOCKD_IDM_LIBS
@@ -988,6 +989,7 @@ enable_dmfilemapd
 enable_notify_dbus
 enable_systemd_journal
 enable_app_machineid
+with_systemd_run
 enable_blkid_wiping
 enable_udev_sync
 enable_udev_rules
@@ -1803,6 +1805,7 @@ Optional Packages:
                           lvmlockd pidfile [PID_DIR/lvmlockd.pid]
   --with-lvmpolld-pidfile=PATH
                           lvmpolld pidfile [PID_DIR/lvmpolld.pid]
+  --with-systemd-run=PATH systemd-run tool: [autodetect]
   --with-python-sys-prefix
                           use Python's sys.prefix and sys.exec_prefix values
   --with-python_prefix    override the default PYTHON_PREFIX
@@ -12785,6 +12788,138 @@ fi
 
 ################################################################################
 
+# Check whether --with-systemd-run was given.
+if test ${with_systemd_run+y}
+then :
+  withval=$with_systemd_run; SYSTEMD_RUN_CMD=$withval
+else $as_nop
+  SYSTEMD_RUN_CMD="autodetect"
+fi
+
+
+if test "$SYSTEMD_RUN_CMD" = "autodetect"
+then :
+  if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}systemd-run", so it can be a program name with args.
+set dummy ${ac_tool_prefix}systemd-run; ac_word=$2
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_SYSTEMD_RUN_CMD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  case $SYSTEMD_RUN_CMD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_SYSTEMD_RUN_CMD="$SYSTEMD_RUN_CMD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_SYSTEMD_RUN_CMD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+  done
+IFS=$as_save_IFS
+
+  ;;
+esac
+fi
+SYSTEMD_RUN_CMD=$ac_cv_path_SYSTEMD_RUN_CMD
+if test -n "$SYSTEMD_RUN_CMD"; then
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $SYSTEMD_RUN_CMD" >&5
+printf "%s\n" "$SYSTEMD_RUN_CMD" >&6; }
+else
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
+fi
+
+
+fi
+if test -z "$ac_cv_path_SYSTEMD_RUN_CMD"; then
+  ac_pt_SYSTEMD_RUN_CMD=$SYSTEMD_RUN_CMD
+  # Extract the first word of "systemd-run", so it can be a program name with args.
+set dummy systemd-run; ac_word=$2
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_ac_pt_SYSTEMD_RUN_CMD+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  case $ac_pt_SYSTEMD_RUN_CMD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_ac_pt_SYSTEMD_RUN_CMD="$ac_pt_SYSTEMD_RUN_CMD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_SYSTEMD_RUN_CMD="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+  done
+IFS=$as_save_IFS
+
+  ;;
+esac
+fi
+ac_pt_SYSTEMD_RUN_CMD=$ac_cv_path_ac_pt_SYSTEMD_RUN_CMD
+if test -n "$ac_pt_SYSTEMD_RUN_CMD"; then
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_pt_SYSTEMD_RUN_CMD" >&5
+printf "%s\n" "$ac_pt_SYSTEMD_RUN_CMD" >&6; }
+else
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
+fi
+
+  if test "x$ac_pt_SYSTEMD_RUN_CMD" = x; then
+    SYSTEMD_RUN_CMD=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    SYSTEMD_RUN_CMD=$ac_pt_SYSTEMD_RUN_CMD
+  fi
+else
+  SYSTEMD_RUN_CMD="$ac_cv_path_SYSTEMD_RUN_CMD"
+fi
+
+       if test -z "$SYSTEMD_RUN_CMD"
+then :
+  SYSTEMD_RUN_CMD="/usr/bin/systemd-run"
+fi
+else $as_nop
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for defined systemd-run" >&5
+printf %s "checking for defined systemd-run... " >&6; }
+       { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $SYSTEMD_RUN_CMD" >&5
+printf "%s\n" "$SYSTEMD_RUN_CMD" >&6; }
+fi
+
+################################################################################
+
 # Check whether --enable-blkid_wiping was given.
 if test ${enable_blkid_wiping+y}
 then :
@@ -12798,12 +12933,6 @@ fi
 #       so lvresize can check detected flag here
 #
 DEFAULT_USE_BLKID_WIPING=0
-if test "$BLKID_WIPING" != "no"
-then :
-  blkdir_version=">= 2.24"
-else $as_nop
-  blkid_version=""
-fi
 
 
 pkg_failed=no
@@ -12814,12 +12943,12 @@ if test -n "$BLKID_CFLAGS"; then
     pkg_cv_BLKID_CFLAGS="$BLKID_CFLAGS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"blkid \$blkid_version \""; } >&5
-  ($PKG_CONFIG --exists --print-errors "blkid $blkid_version ") 2>&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"blkid >= 2.24\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "blkid >= 2.24") 2>&5
   ac_status=$?
   printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  pkg_cv_BLKID_CFLAGS=`$PKG_CONFIG --cflags "blkid $blkid_version " 2>/dev/null`
+  pkg_cv_BLKID_CFLAGS=`$PKG_CONFIG --cflags "blkid >= 2.24" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
@@ -12831,12 +12960,12 @@ if test -n "$BLKID_LIBS"; then
     pkg_cv_BLKID_LIBS="$BLKID_LIBS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"blkid \$blkid_version \""; } >&5
-  ($PKG_CONFIG --exists --print-errors "blkid $blkid_version ") 2>&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"blkid >= 2.24\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "blkid >= 2.24") 2>&5
   ac_status=$?
   printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  pkg_cv_BLKID_LIBS=`$PKG_CONFIG --libs "blkid $blkid_version " 2>/dev/null`
+  pkg_cv_BLKID_LIBS=`$PKG_CONFIG --libs "blkid >= 2.24" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
@@ -12857,14 +12986,14 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        BLKID_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "blkid $blkid_version " 2>&1`
+	        BLKID_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "blkid >= 2.24" 2>&1`
         else
-	        BLKID_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "blkid $blkid_version " 2>&1`
+	        BLKID_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "blkid >= 2.24" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$BLKID_PKG_ERRORS" >&5
 
-	as_fn_error $? "Package requirements (blkid $blkid_version ) were not met:
+	as_fn_error $? "Package requirements (blkid >= 2.24) were not met:
 
 $BLKID_PKG_ERRORS
 
@@ -12897,8 +13026,8 @@ printf "%s\n" "yes" >&6; }
 
 	HAVE_BLKID=1
 
-	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for blkdid.h supports SUBLKS_FSINFO." >&5
-printf %s "checking for blkdid.h supports SUBLKS_FSINFO.... " >&6; }
+	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for blkdid.h defines BLKID_SUBLKS_FSINFO." >&5
+printf %s "checking for blkdid.h defines BLKID_SUBLKS_FSINFO.... " >&6; }
 if test ${ac_cv_have_blkid_sublks_fsinfo+y}
 then :
   printf %s "(cached) " >&6
@@ -15954,6 +16083,7 @@ printf "%s\n" "#define LVM_CONFIGURE_LINE \"$CONFIGURE_LINE\"" >>confdefs.h
 
 
 
+
 
 
 ################################################################################

