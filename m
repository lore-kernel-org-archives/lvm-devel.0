From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 9 Jun 2017 16:56:44 -0400
Subject: master - configure: update
Message-ID: <201706092056.v59Kuinx018653@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=37cd8f9678c92281e2f832dff01dc888e0ce608c
Commit:        37cd8f9678c92281e2f832dff01dc888e0ce608c
Parent:        4b4a210e8397a37446fe7229242868055af9cd81
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 9 22:50:40 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 9 22:52:19 2017 +0200

configure: update

---
 configure |   93 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 93 insertions(+), 0 deletions(-)

diff --git a/configure b/configure
index 2a591aa..e1ae0e8 100755
--- a/configure
+++ b/configure
@@ -827,6 +827,7 @@ WC
 CHMOD
 CSCOPE_CMD
 CFLOW_CMD
+AR
 RANLIB
 MKDIR_P
 SET_MAKE
@@ -4948,6 +4949,98 @@ else
 fi
 
 if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}ar", so it can be a program name with args.
+set dummy ${ac_tool_prefix}ar; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_prog_AR+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  if test -n "$AR"; then
+  ac_cv_prog_AR="$AR" # Let the user override the test.
+else
+as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_prog_AR="${ac_tool_prefix}ar"
+    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+  done
+IFS=$as_save_IFS
+
+fi
+fi
+AR=$ac_cv_prog_AR
+if test -n "$AR"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $AR" >&5
+$as_echo "$AR" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+
+fi
+if test -z "$ac_cv_prog_AR"; then
+  ac_ct_AR=$AR
+  # Extract the first word of "ar", so it can be a program name with args.
+set dummy ar; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if ${ac_cv_prog_ac_ct_AR+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  if test -n "$ac_ct_AR"; then
+  ac_cv_prog_ac_ct_AR="$ac_ct_AR" # Let the user override the test.
+else
+as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+    ac_cv_prog_ac_ct_AR="ar"
+    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+  done
+IFS=$as_save_IFS
+
+fi
+fi
+ac_ct_AR=$ac_cv_prog_ac_ct_AR
+if test -n "$ac_ct_AR"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_ct_AR" >&5
+$as_echo "$ac_ct_AR" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+  if test "x$ac_ct_AR" = x; then
+    AR=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+$as_echo "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    AR=$ac_ct_AR
+  fi
+else
+  AR="$ac_cv_prog_AR"
+fi
+
+if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}cflow", so it can be a program name with args.
 set dummy ${ac_tool_prefix}cflow; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5


