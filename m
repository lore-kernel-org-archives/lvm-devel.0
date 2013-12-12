From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 12 Dec 2013 12:45:56 +0000 (UTC)
Subject: master - autoreconf: latest changes
Message-ID: <20131212124556.8E58260355@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aefab64e690cb5fbbd28a07d27a4f510d8aca32b
Commit:        aefab64e690cb5fbbd28a07d27a4f510d8aca32b
Parent:        6c0e44d5a2e82aa160d48e83992e7ca342bc4bdf
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Dec 12 13:45:48 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Dec 12 13:45:48 2013 +0100

autoreconf: latest changes

---
 configure |  265 +++++++++++++++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 230 insertions(+), 35 deletions(-)

diff --git a/configure b/configure
index ff7185d..f48c89b 100755
--- a/configure
+++ b/configure
@@ -1618,10 +1618,10 @@ Optional Packages:
   --with-replicators=TYPE replicator support: internal/shared/none
                           [[TYPE=none]]
   --with-thin=TYPE        thin provisioning support: internal/shared/none
-                          [[TYPE=none]]
-  --with-thin-check=PATH  thin_check tool: [[autodetect]]
-  --with-thin-dump=PATH   thin_dump tool: [[autodetect]]
-  --with-thin-repair=PATH thin_repair tool: [[autodetect]]
+                          [[TYPE=internal]]
+  --with-thin-check=PATH  thin_check tool: [[thin_check]]
+  --with-thin-dump=PATH   thin_dump tool: [[thin_dump]]
+  --with-thin-repair=PATH thin_repair tool: [[thin_repair]]
   --with-ocfdir=DIR       install OCF files in DIR
                           [[PREFIX/lib/ocf/resource.d/lvm2]]
   --with-default-pid-dir=PID_DIR
@@ -7146,9 +7146,34 @@ $as_echo_n "checking whether to include thin provisioning... " >&6; }
 if test "${with_thin+set}" = set; then :
   withval=$with_thin; THIN=$withval
 else
-  THIN=none
+  THIN=internal
 fi
 
+
+# Check whether --with-thin-check was given.
+if test "${with_thin_check+set}" = set; then :
+  withval=$with_thin_check; THIN_CHECK_CMD=$withval
+else
+  THIN_CHECK_CMD="thin_check"
+fi
+
+
+# Check whether --with-thin-dump was given.
+if test "${with_thin_dump+set}" = set; then :
+  withval=$with_thin_dump; THIN_DUMP_CMD=$withval
+else
+  THIN_DUMP_CMD="thin_dump"
+fi
+
+
+# Check whether --with-thin-repair was given.
+if test "${with_thin_repair+set}" = set; then :
+  withval=$with_thin_repair; THIN_REPAIR_CMD=$withval
+else
+  THIN_REPAIR_CMD="thin_repair"
+fi
+
+
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $THIN" >&5
 $as_echo "$THIN" >&6; }
 
@@ -7160,20 +7185,15 @@ $as_echo "#define THIN_INTERNAL 1" >>confdefs.h
   *) as_fn_error $? "--with-thin parameter invalid ($THIN)" "$LINENO" 5 ;;
 esac
 
+# Test if necessary thin tools are available
+# if not - use plain defaults and warn user
 case "$THIN" in
   internal|shared)
-
-# Check whether --with-thin-check was given.
-if test "${with_thin_check+set}" = set; then :
-  withval=$with_thin_check; THIN_CHECK_CMD=$withval
-else
-  THIN_CHECK_CMD="autodetect"
-fi
-
 	# Empty means a config way to ignore thin checking
-	if test "$THIN_CHECK_CMD" = "autodetect"; then
-		# Extract the first word of "thin_check", so it can be a program name with args.
-set dummy thin_check; ac_word=$2
+	if test "$THIN_CHECK_CMD" = "thin_check"; then
+		if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}thin_check", so it can be a program name with args.
+set dummy ${ac_tool_prefix}thin_check; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
 if test "${ac_cv_path_THIN_CHECK_CMD+set}" = set; then :
@@ -7212,20 +7232,75 @@ $as_echo "no" >&6; }
 fi
 
 
-		test -z "$THIN_CHECK_CMD" && as_fn_error $? "thin_check not found in path $PATH" "$LINENO" 5
-	fi
+fi
+if test -z "$ac_cv_path_THIN_CHECK_CMD"; then
+  ac_pt_THIN_CHECK_CMD=$THIN_CHECK_CMD
+  # Extract the first word of "thin_check", so it can be a program name with args.
+set dummy thin_check; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if test "${ac_cv_path_ac_pt_THIN_CHECK_CMD+set}" = set; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $ac_pt_THIN_CHECK_CMD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_ac_pt_THIN_CHECK_CMD="$ac_pt_THIN_CHECK_CMD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+    ac_cv_path_ac_pt_THIN_CHECK_CMD="$as_dir/$ac_word$ac_exec_ext"
+    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+  done
+IFS=$as_save_IFS
 
-# Check whether --with-thin-dump was given.
-if test "${with_thin_dump+set}" = set; then :
-  withval=$with_thin_dump; THIN_DUMP_CMD=$withval
+  ;;
+esac
+fi
+ac_pt_THIN_CHECK_CMD=$ac_cv_path_ac_pt_THIN_CHECK_CMD
+if test -n "$ac_pt_THIN_CHECK_CMD"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_THIN_CHECK_CMD" >&5
+$as_echo "$ac_pt_THIN_CHECK_CMD" >&6; }
 else
-  THIN_DUMP_CMD="autodetect"
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+  if test "x$ac_pt_THIN_CHECK_CMD" = x; then
+    THIN_CHECK_CMD="thin_check"
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    THIN_CHECK_CMD=$ac_pt_THIN_CHECK_CMD
+  fi
+else
+  THIN_CHECK_CMD="$ac_cv_path_THIN_CHECK_CMD"
 fi
 
+		test "$THIN_CHECK_CMD" = "thin_check" && {
+			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: thin_check not found in path $PATH" >&5
+$as_echo "$as_me: WARNING: thin_check not found in path $PATH" >&2;}
+			THIN_CHECK_CMD=thin_check
+			THIN_CONFIGURE_WARN=y
+		}
+	fi
 	# Empty means a config way to ignore thin checking
-	if test "$THIN_DUMP_CMD" = "autodetect"; then
-		# Extract the first word of "thin_dump", so it can be a program name with args.
-set dummy thin_dump; ac_word=$2
+	if test "$THIN_DUMP_CMD" = "thin_dump"; then
+		if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}thin_dump", so it can be a program name with args.
+set dummy ${ac_tool_prefix}thin_dump; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
 if test "${ac_cv_path_THIN_DUMP_CMD+set}" = set; then :
@@ -7264,20 +7339,75 @@ $as_echo "no" >&6; }
 fi
 
 
-		test -z "$THIN_DUMP_CMD" && as_fn_error $? "thin_dump not found in path $PATH" "$LINENO" 5
-	fi
+fi
+if test -z "$ac_cv_path_THIN_DUMP_CMD"; then
+  ac_pt_THIN_DUMP_CMD=$THIN_DUMP_CMD
+  # Extract the first word of "thin_dump", so it can be a program name with args.
+set dummy thin_dump; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if test "${ac_cv_path_ac_pt_THIN_DUMP_CMD+set}" = set; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $ac_pt_THIN_DUMP_CMD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_ac_pt_THIN_DUMP_CMD="$ac_pt_THIN_DUMP_CMD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+    ac_cv_path_ac_pt_THIN_DUMP_CMD="$as_dir/$ac_word$ac_exec_ext"
+    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+  done
+IFS=$as_save_IFS
 
-# Check whether --with-thin-repair was given.
-if test "${with_thin_repair+set}" = set; then :
-  withval=$with_thin_repair; THIN_REPAIR_CMD=$withval
+  ;;
+esac
+fi
+ac_pt_THIN_DUMP_CMD=$ac_cv_path_ac_pt_THIN_DUMP_CMD
+if test -n "$ac_pt_THIN_DUMP_CMD"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_THIN_DUMP_CMD" >&5
+$as_echo "$ac_pt_THIN_DUMP_CMD" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+  if test "x$ac_pt_THIN_DUMP_CMD" = x; then
+    THIN_DUMP_CMD="thin_dump"
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    THIN_DUMP_CMD=$ac_pt_THIN_DUMP_CMD
+  fi
 else
-  THIN_REPAIR_CMD="autodetect"
+  THIN_DUMP_CMD="$ac_cv_path_THIN_DUMP_CMD"
 fi
 
+		test "$THIN_DUMP_CMD" = "thin_dump" && {
+			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: thin_dump not found in path $PATH" >&5
+$as_echo "$as_me: WARNING: thin_dump not found in path $PATH" >&2;}
+			THIN_DUMP_CMD=thin_dump
+			THIN_CONFIGURE_WARN=y
+		}
+	fi
 	# Empty means a config way to ignore thin checking
-	if test "$THIN_REPAIR_CMD" = "autodetect"; then
-		# Extract the first word of "thin_repair", so it can be a program name with args.
-set dummy thin_repair; ac_word=$2
+	if test "$THIN_REPAIR_CMD" = "thin_repair"; then
+		if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}thin_repair", so it can be a program name with args.
+set dummy ${ac_tool_prefix}thin_repair; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
 if test "${ac_cv_path_THIN_REPAIR_CMD+set}" = set; then :
@@ -7316,7 +7446,69 @@ $as_echo "no" >&6; }
 fi
 
 
-		test -z "$THIN_REPAIR_CMD" && as_fn_error $? "thin_repair not found in path $PATH" "$LINENO" 5
+fi
+if test -z "$ac_cv_path_THIN_REPAIR_CMD"; then
+  ac_pt_THIN_REPAIR_CMD=$THIN_REPAIR_CMD
+  # Extract the first word of "thin_repair", so it can be a program name with args.
+set dummy thin_repair; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if test "${ac_cv_path_ac_pt_THIN_REPAIR_CMD+set}" = set; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $ac_pt_THIN_REPAIR_CMD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_ac_pt_THIN_REPAIR_CMD="$ac_pt_THIN_REPAIR_CMD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+    ac_cv_path_ac_pt_THIN_REPAIR_CMD="$as_dir/$ac_word$ac_exec_ext"
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
+ac_pt_THIN_REPAIR_CMD=$ac_cv_path_ac_pt_THIN_REPAIR_CMD
+if test -n "$ac_pt_THIN_REPAIR_CMD"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_THIN_REPAIR_CMD" >&5
+$as_echo "$ac_pt_THIN_REPAIR_CMD" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+  if test "x$ac_pt_THIN_REPAIR_CMD" = x; then
+    THIN_REPAIR_CMD=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    THIN_REPAIR_CMD=$ac_pt_THIN_REPAIR_CMD
+  fi
+else
+  THIN_REPAIR_CMD="$ac_cv_path_THIN_REPAIR_CMD"
+fi
+
+		test -z "$THIN_REPAIR_CMD" && {
+			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: thin_repair not found in path $PATH" >&5
+$as_echo "$as_me: WARNING: thin_repair not found in path $PATH" >&2;}
+			THIN_REPAIR_CMD=thin_repair
+			THIN_CONFIGURE_WARN=y
+		}
 	fi
 	;;
 esac
@@ -12574,6 +12766,9 @@ $as_echo "$as_me: WARNING: unrecognized options: $ac_unrecognized_opts" >&2;}
 fi
 
 
+test -n "$THIN_CONFIGURE_WARN" && { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Support for thin provisioning is limited since some thin provisioning tools are missing!" >&5
+$as_echo "$as_me: WARNING: Support for thin provisioning is limited since some thin provisioning tools are missing!" >&2;}
+
 if test x$ODIRECT != xyes; then
   { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Warning: O_DIRECT disabled: low-memory pvmove may lock up" >&5
 $as_echo "$as_me: WARNING: Warning: O_DIRECT disabled: low-memory pvmove may lock up" >&2;}


