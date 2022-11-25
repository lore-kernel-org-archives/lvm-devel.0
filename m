From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Nov 2022 15:43:01 +0000 (GMT)
Subject: main - configure: update
Message-ID: <20221125154301.560A8384F4AD@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ae916f77c92c1765c76fbb849a2eaeb5e0724768
Commit:        ae916f77c92c1765c76fbb849a2eaeb5e0724768
Parent:        fdd8feb60e7a7757aaa12d9df357cadeb1c31044
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 23 13:18:07 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 25 15:55:56 2022 +0100

configure: update

---
 configure | 111 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 107 insertions(+), 4 deletions(-)

diff --git a/configure b/configure
index ccd5a5938..718f281bc 100755
--- a/configure
+++ b/configure
@@ -850,6 +850,7 @@ CHMOD
 CSCOPE_CMD
 CFLOW_CMD
 AR
+READELF
 RANLIB
 MKDIR_P
 SET_MAKE
@@ -5162,11 +5163,11 @@ if test x$ac_prog_cxx_stdcxx = xno
 then :
   { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $CXX option to enable C++11 features" >&5
 printf %s "checking for $CXX option to enable C++11 features... " >&6; }
-if test ${ac_cv_prog_cxx_11+y}
+if test ${ac_cv_prog_cxx_cxx11+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
-  ac_cv_prog_cxx_11=no
+  ac_cv_prog_cxx_cxx11=no
 ac_save_CXX=$CXX
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
@@ -5208,11 +5209,11 @@ if test x$ac_prog_cxx_stdcxx = xno
 then :
   { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $CXX option to enable C++98 features" >&5
 printf %s "checking for $CXX option to enable C++98 features... " >&6; }
-if test ${ac_cv_prog_cxx_98+y}
+if test ${ac_cv_prog_cxx_cxx98+y}
 then :
   printf %s "(cached) " >&6
 else $as_nop
-  ac_cv_prog_cxx_98=no
+  ac_cv_prog_cxx_cxx98=no
 ac_save_CXX=$CXX
 cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
@@ -5874,6 +5875,108 @@ else
   RANLIB="$ac_cv_prog_RANLIB"
 fi
 
+if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}readelf", so it can be a program name with args.
+set dummy ${ac_tool_prefix}readelf; ac_word=$2
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_prog_READELF+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  if test -n "$READELF"; then
+  ac_cv_prog_READELF="$READELF" # Let the user override the test.
+else
+as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
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
+    ac_cv_prog_READELF="${ac_tool_prefix}readelf"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+  done
+IFS=$as_save_IFS
+
+fi
+fi
+READELF=$ac_cv_prog_READELF
+if test -n "$READELF"; then
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $READELF" >&5
+printf "%s\n" "$READELF" >&6; }
+else
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
+fi
+
+
+fi
+if test -z "$ac_cv_prog_READELF"; then
+  ac_ct_READELF=$READELF
+  # Extract the first word of "readelf", so it can be a program name with args.
+set dummy readelf; ac_word=$2
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_prog_ac_ct_READELF+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  if test -n "$ac_ct_READELF"; then
+  ac_cv_prog_ac_ct_READELF="$ac_ct_READELF" # Let the user override the test.
+else
+as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
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
+    ac_cv_prog_ac_ct_READELF="readelf"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+  done
+IFS=$as_save_IFS
+
+fi
+fi
+ac_ct_READELF=$ac_cv_prog_ac_ct_READELF
+if test -n "$ac_ct_READELF"; then
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_ct_READELF" >&5
+printf "%s\n" "$ac_ct_READELF" >&6; }
+else
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
+fi
+
+  if test "x$ac_ct_READELF" = x; then
+    READELF=""
+  else
+    case $cross_compiling:$ac_tool_warned in
+yes:)
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: using cross tools not prefixed with host triplet" >&5
+printf "%s\n" "$as_me: WARNING: using cross tools not prefixed with host triplet" >&2;}
+ac_tool_warned=yes ;;
+esac
+    READELF=$ac_ct_READELF
+  fi
+else
+  READELF="$ac_cv_prog_READELF"
+fi
+
 if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}ar", so it can be a program name with args.
 set dummy ${ac_tool_prefix}ar; ac_word=$2

