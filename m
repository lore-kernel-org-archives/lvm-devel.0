From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 18 Feb 2016 02:11:32 +0000 (UTC)
Subject: master - configure: Use python-config if python2-config not found.
Message-ID: <20160218021132.6475160DFB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e5fc48411a5e872eb7c34dff51aa7e0910812119
Commit:        e5fc48411a5e872eb7c34dff51aa7e0910812119
Parent:        7dce72ee182d80d85d5292c85877d826c283cf33
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Feb 18 02:10:35 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Feb 18 02:10:35 2016 +0000

configure: Use python-config if python2-config not found.

Assume that's good enough for older systems.
---
 configure    |   98 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 configure.in |    1 +
 2 files changed, 99 insertions(+), 0 deletions(-)

diff --git a/configure b/configure
index 93e0003..1d742ec 100755
--- a/configure
+++ b/configure
@@ -12827,6 +12827,104 @@ else
   PYTHON2_CONFIG="$ac_cv_path_PYTHON2_CONFIG"
 fi
 
+	test -z "$PYTHON2_CONFIG" && if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}python-config", so it can be a program name with args.
+set dummy ${ac_tool_prefix}python-config; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_PYTHON2_CONFIG+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $PYTHON2_CONFIG in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_PYTHON2_CONFIG="$PYTHON2_CONFIG" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_PYTHON2_CONFIG="$as_dir/$ac_word$ac_exec_ext"
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
+PYTHON2_CONFIG=$ac_cv_path_PYTHON2_CONFIG
+if test -n "$PYTHON2_CONFIG"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $PYTHON2_CONFIG" >&5
+$as_echo "$PYTHON2_CONFIG" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+
+fi
+if test -z "$ac_cv_path_PYTHON2_CONFIG"; then
+  ac_pt_PYTHON2_CONFIG=$PYTHON2_CONFIG
+  # Extract the first word of "python-config", so it can be a program name with args.
+set dummy python-config; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_path_ac_pt_PYTHON2_CONFIG+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $ac_pt_PYTHON2_CONFIG in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_ac_pt_PYTHON2_CONFIG="$ac_pt_PYTHON2_CONFIG" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_path_ac_pt_PYTHON2_CONFIG="$as_dir/$ac_word$ac_exec_ext"
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
+ac_pt_PYTHON2_CONFIG=$ac_cv_path_ac_pt_PYTHON2_CONFIG
+if test -n "$ac_pt_PYTHON2_CONFIG"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_pt_PYTHON2_CONFIG" >&5
+$as_echo "$ac_pt_PYTHON2_CONFIG" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+  if test "x$ac_pt_PYTHON2_CONFIG" = x; then
+    PYTHON2_CONFIG=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    PYTHON2_CONFIG=$ac_pt_PYTHON2_CONFIG
+  fi
+else
+  PYTHON2_CONFIG="$ac_cv_path_PYTHON2_CONFIG"
+fi
+
 	test -z "$PYTHON2_CONFIG" && as_fn_error $? "python headers are required for --enable-python2_bindings but cannot be found" "$LINENO" 5
 	PYTHON2_INCDIRS=`"$PYTHON2_CONFIG" --includes`
 	PYTHON2_LIBDIRS=`"$PYTHON2_CONFIG" --libs`
diff --git a/configure.in b/configure.in
index 22ba812..7a5aa5d 100644
--- a/configure.in
+++ b/configure.in
@@ -1476,6 +1476,7 @@ if test "$PYTHON2_BINDINGS" = yes; then
 	AC_PATH_TOOL(PYTHON2, python2)
 	test -z "$PYTHON2" && AC_MSG_ERROR([python2 is required for --enable-python2_bindings but cannot be found])
 	AC_PATH_TOOL(PYTHON2_CONFIG, python2-config)
+	test -z "$PYTHON2_CONFIG" && AC_PATH_TOOL(PYTHON2_CONFIG, python-config)
 	test -z "$PYTHON2_CONFIG" && AC_MSG_ERROR([python headers are required for --enable-python2_bindings but cannot be found])
 	PYTHON2_INCDIRS=`"$PYTHON2_CONFIG" --includes`
 	PYTHON2_LIBDIRS=`"$PYTHON2_CONFIG" --libs`


