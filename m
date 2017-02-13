From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 13 Feb 2017 23:06:10 +0000 (UTC)
Subject: master - configure: update
Message-ID: <20170213230610.01D3860D36@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6118b0fb93502e1ba06e5a4a696a264c0e4af0ed
Commit:        6118b0fb93502e1ba06e5a4a696a264c0e4af0ed
Parent:        65b82a80720b137e24077c29f9c52d6ad43f93a5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 13 22:55:30 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 14 00:05:04 2017 +0100

configure: update

---
 configure |  198 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 198 insertions(+), 0 deletions(-)

diff --git a/configure b/configure
index 1cb4b54..9b69964 100755
--- a/configure
+++ b/configure
@@ -821,6 +821,8 @@ HAVE_PIE
 POW_LIB
 LIBOBJS
 ALLOCA
+SORT
+WC
 CHMOD
 CSCOPE_CMD
 CFLOW_CMD
@@ -5234,6 +5236,202 @@ else
   CHMOD="$ac_cv_path_CHMOD"
 fi
 
+if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}wc", so it can be a program name with args.
+set dummy ${ac_tool_prefix}wc; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_WC+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $WC in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_WC="$WC" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_WC="$as_dir/$ac_word$ac_exec_ext"
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
+WC=$ac_cv_path_WC
+if test -n "$WC"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $WC" >&5
+$as_echo "$WC" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+
+fi
+if test -z "$ac_cv_path_WC"; then
+  ac_pt_WC=$WC
+  # Extract the first word of "wc", so it can be a program name with args.
+set dummy wc; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_ac_pt_WC+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $ac_pt_WC in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_ac_pt_WC="$ac_pt_WC" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_WC="$as_dir/$ac_word$ac_exec_ext"
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
+ac_pt_WC=$ac_cv_path_ac_pt_WC
+if test -n "$ac_pt_WC"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_WC" >&5
+$as_echo "$ac_pt_WC" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+  if test "x$ac_pt_WC" = x; then
+    WC=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    WC=$ac_pt_WC
+  fi
+else
+  WC="$ac_cv_path_WC"
+fi
+
+if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}sort", so it can be a program name with args.
+set dummy ${ac_tool_prefix}sort; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_SORT+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $SORT in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_SORT="$SORT" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_SORT="$as_dir/$ac_word$ac_exec_ext"
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
+SORT=$ac_cv_path_SORT
+if test -n "$SORT"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $SORT" >&5
+$as_echo "$SORT" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+
+fi
+if test -z "$ac_cv_path_SORT"; then
+  ac_pt_SORT=$SORT
+  # Extract the first word of "sort", so it can be a program name with args.
+set dummy sort; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_ac_pt_SORT+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $ac_pt_SORT in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_ac_pt_SORT="$ac_pt_SORT" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_SORT="$as_dir/$ac_word$ac_exec_ext"
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
+ac_pt_SORT=$ac_cv_path_ac_pt_SORT
+if test -n "$ac_pt_SORT"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_SORT" >&5
+$as_echo "$ac_pt_SORT" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+  if test "x$ac_pt_SORT" = x; then
+    SORT=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    SORT=$ac_pt_SORT
+  fi
+else
+  SORT="$ac_cv_path_SORT"
+fi
+
 
 ################################################################################
 ac_header_dirent=no


