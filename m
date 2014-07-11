From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 11:34:07 +0000 (UTC)
Subject: master - configure
Message-ID: <20140711113407.48E41610F1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=39cb8aa3abd4e3eea7bbbdcc24225e8475c3aff3
Commit:        39cb8aa3abd4e3eea7bbbdcc24225e8475c3aff3
Parent:        f9d80c9d31d7113ab8bc08baf6bba96a7449261f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 4 16:31:05 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 12:47:41 2014 +0200

configure

---
 configure |  521 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 517 insertions(+), 4 deletions(-)

diff --git a/configure b/configure
index dec82de..40ab256 100755
--- a/configure
+++ b/configure
@@ -768,6 +768,10 @@ PKGCONFIGINIT_CFLAGS
 PKG_CONFIG_LIBDIR
 PKG_CONFIG_PATH
 PKG_CONFIG
+CACHE_RESTORE_CMD
+CACHE_REPAIR_CMD
+CACHE_DUMP_CMD
+CACHE_CHECK_CMD
 THIN_RESTORE_CMD
 THIN_REPAIR_CMD
 THIN_DUMP_CMD
@@ -874,6 +878,10 @@ with_thin_repair
 with_thin_restore
 enable_thin_check_needs_check
 with_cache
+with_cache_check
+with_cache_dump
+with_cache_repair
+with_cache_restore
 enable_readline
 enable_realtime
 enable_ocf
@@ -1661,6 +1669,12 @@ Optional Packages:
   --with-thin-restore=PATH
                           thin_restore tool: [[autodetect]]
   --with-cache=TYPE       cache support: internal/shared/none [[TYPE=none]]
+  --with-cache-check=PATH cache_check tool: [[autodetect]]
+  --with-cache-dump=PATH  cache_dump tool: [[autodetect]]
+  --with-cache-repair=PATH
+                          cache_repair tool: [[autodetect]]
+  --with-cache-restore=PATH
+                          cache_restore tool: [[autodetect]]
   --with-ocfdir=DIR       install OCF files in DIR
                           [[PREFIX/lib/ocf/resource.d/lvm2]]
   --with-default-pid-dir=PID_DIR
@@ -7450,7 +7464,7 @@ $as_echo "$as_me: WARNING: $THIN_CHECK_CMD: Old version \"$THIN_CHECK_VSN\" foun
 			THIN_CHECK_NEEDS_CHECK=no
 		fi
 	fi
-	# Empty means a config way to ignore thin checking
+	# Empty means a config way to ignore thin dumping
 	if test "$THIN_DUMP_CMD" = "autodetect"; then
 		if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}thin_dump", so it can be a program name with args.
@@ -7557,7 +7571,7 @@ $as_echo "$as_me: WARNING: thin_dump not found in path $PATH" >&2;}
 			THIN_CONFIGURE_WARN=y
 		}
 	fi
-	# Empty means a config way to ignore thin checking
+	# Empty means a config way to ignore thin repairing
 	if test "$THIN_REPAIR_CMD" = "autodetect"; then
 		if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}thin_repair", so it can be a program name with args.
@@ -7664,7 +7678,7 @@ $as_echo "$as_me: WARNING: thin_repair not found in path $PATH" >&2;}
 			THIN_CONFIGURE_WARN=y
 		}
 	fi
-	# Empty means a config way to ignore thin checking
+	# Empty means a config way to ignore thin restoring
 	if test "$THIN_RESTORE_CMD" = "autodetect"; then
 		if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}thin_restore", so it can be a program name with args.
@@ -7816,7 +7830,39 @@ $as_echo_n "checking whether to include cache... " >&6; }
 if test "${with_cache+set}" = set; then :
   withval=$with_cache; CACHE=$withval
 else
-  CACHE=none
+  CACHE="none"
+fi
+
+
+# Check whether --with-cache-check was given.
+if test "${with_cache_check+set}" = set; then :
+  withval=$with_cache_check; CACHE_CHECK_CMD=$withval
+else
+  CACHE_CHECK_CMD="autodetect"
+fi
+
+
+# Check whether --with-cache-dump was given.
+if test "${with_cache_dump+set}" = set; then :
+  withval=$with_cache_dump; CACHE_DUMP_CMD=$withval
+else
+  CACHE_DUMP_CMD="autodetect"
+fi
+
+
+# Check whether --with-cache-repair was given.
+if test "${with_cache_repair+set}" = set; then :
+  withval=$with_cache_repair; CACHE_REPAIR_CMD=$withval
+else
+  CACHE_REPAIR_CMD="autodetect"
+fi
+
+
+# Check whether --with-cache-restore was given.
+if test "${with_cache_restore+set}" = set; then :
+  withval=$with_cache_restore; CACHE_RESTORE_CMD=$withval
+else
+  CACHE_RESTORE_CMD="autodetect"
 fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $CACHE" >&5
@@ -7830,6 +7876,466 @@ $as_echo "#define CACHE_INTERNAL 1" >>confdefs.h
  *) as_fn_error $? "--with-cache parameter invalid" "$LINENO" 5 ;;
 esac
 
+# Test if necessary cache tools are available
+# if not - use plain defaults and warn user
+case "$CACHE" in
+  internal|shared)
+	# Empty means a config way to ignore cache checking
+	if test "$CACHE_CHECK_CMD" = "autodetect"; then
+		if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}cache_check", so it can be a program name with args.
+set dummy ${ac_tool_prefix}cache_check; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_CACHE_CHECK_CMD+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $CACHE_CHECK_CMD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_CACHE_CHECK_CMD="$CACHE_CHECK_CMD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_CACHE_CHECK_CMD="$as_dir/$ac_word$ac_exec_ext"
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
+CACHE_CHECK_CMD=$ac_cv_path_CACHE_CHECK_CMD
+if test -n "$CACHE_CHECK_CMD"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $CACHE_CHECK_CMD" >&5
+$as_echo "$CACHE_CHECK_CMD" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+
+fi
+if test -z "$ac_cv_path_CACHE_CHECK_CMD"; then
+  ac_pt_CACHE_CHECK_CMD=$CACHE_CHECK_CMD
+  # Extract the first word of "cache_check", so it can be a program name with args.
+set dummy cache_check; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_ac_pt_CACHE_CHECK_CMD+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $ac_pt_CACHE_CHECK_CMD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_ac_pt_CACHE_CHECK_CMD="$ac_pt_CACHE_CHECK_CMD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_CACHE_CHECK_CMD="$as_dir/$ac_word$ac_exec_ext"
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
+ac_pt_CACHE_CHECK_CMD=$ac_cv_path_ac_pt_CACHE_CHECK_CMD
+if test -n "$ac_pt_CACHE_CHECK_CMD"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_CACHE_CHECK_CMD" >&5
+$as_echo "$ac_pt_CACHE_CHECK_CMD" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+  if test "x$ac_pt_CACHE_CHECK_CMD" = x; then
+    CACHE_CHECK_CMD=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    CACHE_CHECK_CMD=$ac_pt_CACHE_CHECK_CMD
+  fi
+else
+  CACHE_CHECK_CMD="$ac_cv_path_CACHE_CHECK_CMD"
+fi
+
+		if test -z "$CACHE_CHECK_CMD"; then
+			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: cache_check not found in path $PATH" >&5
+$as_echo "$as_me: WARNING: cache_check not found in path $PATH" >&2;}
+			CACHE_CHECK_CMD=/usr/sbin/cache_check
+			CACHE_CONFIGURE_WARN=y
+		fi
+	fi
+	# Empty means a config way to ignore cache dumping
+	if test "$CACHE_DUMP_CMD" = "autodetect"; then
+		if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}cache_dump", so it can be a program name with args.
+set dummy ${ac_tool_prefix}cache_dump; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_CACHE_DUMP_CMD+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $CACHE_DUMP_CMD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_CACHE_DUMP_CMD="$CACHE_DUMP_CMD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_CACHE_DUMP_CMD="$as_dir/$ac_word$ac_exec_ext"
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
+CACHE_DUMP_CMD=$ac_cv_path_CACHE_DUMP_CMD
+if test -n "$CACHE_DUMP_CMD"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $CACHE_DUMP_CMD" >&5
+$as_echo "$CACHE_DUMP_CMD" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+
+fi
+if test -z "$ac_cv_path_CACHE_DUMP_CMD"; then
+  ac_pt_CACHE_DUMP_CMD=$CACHE_DUMP_CMD
+  # Extract the first word of "cache_dump", so it can be a program name with args.
+set dummy cache_dump; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_ac_pt_CACHE_DUMP_CMD+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $ac_pt_CACHE_DUMP_CMD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_ac_pt_CACHE_DUMP_CMD="$ac_pt_CACHE_DUMP_CMD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_CACHE_DUMP_CMD="$as_dir/$ac_word$ac_exec_ext"
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
+ac_pt_CACHE_DUMP_CMD=$ac_cv_path_ac_pt_CACHE_DUMP_CMD
+if test -n "$ac_pt_CACHE_DUMP_CMD"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_CACHE_DUMP_CMD" >&5
+$as_echo "$ac_pt_CACHE_DUMP_CMD" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+  if test "x$ac_pt_CACHE_DUMP_CMD" = x; then
+    CACHE_DUMP_CMD=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    CACHE_DUMP_CMD=$ac_pt_CACHE_DUMP_CMD
+  fi
+else
+  CACHE_DUMP_CMD="$ac_cv_path_CACHE_DUMP_CMD"
+fi
+
+		test -z "$CACHE_DUMP_CMD" && {
+			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: cache_dump not found in path $PATH" >&5
+$as_echo "$as_me: WARNING: cache_dump not found in path $PATH" >&2;}
+			CACHE_DUMP_CMD=/usr/sbin/cache_dump
+			CACHE_CONFIGURE_WARN=y
+		}
+	fi
+	# Empty means a config way to ignore cache repairing
+	if test "$CACHE_REPAIR_CMD" = "autodetect"; then
+		if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}cache_repair", so it can be a program name with args.
+set dummy ${ac_tool_prefix}cache_repair; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_CACHE_REPAIR_CMD+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $CACHE_REPAIR_CMD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_CACHE_REPAIR_CMD="$CACHE_REPAIR_CMD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_CACHE_REPAIR_CMD="$as_dir/$ac_word$ac_exec_ext"
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
+CACHE_REPAIR_CMD=$ac_cv_path_CACHE_REPAIR_CMD
+if test -n "$CACHE_REPAIR_CMD"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $CACHE_REPAIR_CMD" >&5
+$as_echo "$CACHE_REPAIR_CMD" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+
+fi
+if test -z "$ac_cv_path_CACHE_REPAIR_CMD"; then
+  ac_pt_CACHE_REPAIR_CMD=$CACHE_REPAIR_CMD
+  # Extract the first word of "cache_repair", so it can be a program name with args.
+set dummy cache_repair; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_ac_pt_CACHE_REPAIR_CMD+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $ac_pt_CACHE_REPAIR_CMD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_ac_pt_CACHE_REPAIR_CMD="$ac_pt_CACHE_REPAIR_CMD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_CACHE_REPAIR_CMD="$as_dir/$ac_word$ac_exec_ext"
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
+ac_pt_CACHE_REPAIR_CMD=$ac_cv_path_ac_pt_CACHE_REPAIR_CMD
+if test -n "$ac_pt_CACHE_REPAIR_CMD"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_CACHE_REPAIR_CMD" >&5
+$as_echo "$ac_pt_CACHE_REPAIR_CMD" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+  if test "x$ac_pt_CACHE_REPAIR_CMD" = x; then
+    CACHE_REPAIR_CMD=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    CACHE_REPAIR_CMD=$ac_pt_CACHE_REPAIR_CMD
+  fi
+else
+  CACHE_REPAIR_CMD="$ac_cv_path_CACHE_REPAIR_CMD"
+fi
+
+		test -z "$CACHE_REPAIR_CMD" && {
+			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: cache_repair not found in path $PATH" >&5
+$as_echo "$as_me: WARNING: cache_repair not found in path $PATH" >&2;}
+			CACHE_REPAIR_CMD=/usr/sbin/cache_repair
+			CACHE_CONFIGURE_WARN=y
+		}
+	fi
+	# Empty means a config way to ignore cache restoring
+	if test "$CACHE_RESTORE_CMD" = "autodetect"; then
+		if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}cache_restore", so it can be a program name with args.
+set dummy ${ac_tool_prefix}cache_restore; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_CACHE_RESTORE_CMD+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $CACHE_RESTORE_CMD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_CACHE_RESTORE_CMD="$CACHE_RESTORE_CMD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_CACHE_RESTORE_CMD="$as_dir/$ac_word$ac_exec_ext"
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
+CACHE_RESTORE_CMD=$ac_cv_path_CACHE_RESTORE_CMD
+if test -n "$CACHE_RESTORE_CMD"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $CACHE_RESTORE_CMD" >&5
+$as_echo "$CACHE_RESTORE_CMD" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+
+fi
+if test -z "$ac_cv_path_CACHE_RESTORE_CMD"; then
+  ac_pt_CACHE_RESTORE_CMD=$CACHE_RESTORE_CMD
+  # Extract the first word of "cache_restore", so it can be a program name with args.
+set dummy cache_restore; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_ac_pt_CACHE_RESTORE_CMD+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $ac_pt_CACHE_RESTORE_CMD in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_ac_pt_CACHE_RESTORE_CMD="$ac_pt_CACHE_RESTORE_CMD" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_CACHE_RESTORE_CMD="$as_dir/$ac_word$ac_exec_ext"
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
+ac_pt_CACHE_RESTORE_CMD=$ac_cv_path_ac_pt_CACHE_RESTORE_CMD
+if test -n "$ac_pt_CACHE_RESTORE_CMD"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_CACHE_RESTORE_CMD" >&5
+$as_echo "$ac_pt_CACHE_RESTORE_CMD" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+  if test "x$ac_pt_CACHE_RESTORE_CMD" = x; then
+    CACHE_RESTORE_CMD=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    CACHE_RESTORE_CMD=$ac_pt_CACHE_RESTORE_CMD
+  fi
+else
+  CACHE_RESTORE_CMD="$ac_cv_path_CACHE_RESTORE_CMD"
+fi
+
+		test -z "$CACHE_RESTORE_CMD" && {
+			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: cache_restore not found in path $PATH" >&5
+$as_echo "$as_me: WARNING: cache_restore not found in path $PATH" >&2;}
+			CACHE_RESTORE_CMD=/usr/sbin/cache_restore
+			CACHE_CONFIGURE_WARN=y
+		}
+	fi
+	;;
+esac
+
+
+cat >>confdefs.h <<_ACEOF
+#define CACHE_CHECK_CMD "$CACHE_CHECK_CMD"
+_ACEOF
+
+
+
+cat >>confdefs.h <<_ACEOF
+#define CACHE_DUMP_CMD "$CACHE_DUMP_CMD"
+_ACEOF
+
+
+
+cat >>confdefs.h <<_ACEOF
+#define CACHE_REPAIR_CMD "$CACHE_REPAIR_CMD"
+_ACEOF
+
+
+
+cat >>confdefs.h <<_ACEOF
+#define CACHE_RESTORE_CMD "$CACHE_RESTORE_CMD"
+_ACEOF
+
+
+
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable readline" >&5
 $as_echo_n "checking whether to enable readline... " >&6; }
@@ -12091,6 +12597,10 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
+
+
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile conf/Makefile conf/example.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile
  python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
@@ -13455,5 +13965,8 @@ $as_echo "$as_me: WARNING: Support for thin provisioning is limited since some t
 test -n "$THIN_CHECK_VERSION_WARN" && { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: You should also install thin_check vsn 0.3.2 (or later) to use lvm2 thin provisioning" >&5
 $as_echo "$as_me: WARNING: You should also install thin_check vsn 0.3.2 (or later) to use lvm2 thin provisioning" >&2;}
 
+test -n "$CACHE_CONFIGURE_WARN" && { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Support for cache is limited since some cache tools are missing!" >&5
+$as_echo "$as_me: WARNING: Support for cache is limited since some cache tools are missing!" >&2;}
+
 test "$ODIRECT" = yes || { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&5
 $as_echo "$as_me: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&2;}


