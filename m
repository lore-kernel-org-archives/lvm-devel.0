From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 31 Jul 2013 13:59:23 +0000 (UTC)
Subject: master - configure: autoreconf
Message-ID: <20130731135923.9D2DD612B0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7db95d0d40c3608b7298cb19380430613fa9e532
Commit:        7db95d0d40c3608b7298cb19380430613fa9e532
Parent:        de0cba0e2d588a327867f17015cecba516364591
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 31 15:59:05 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 31 15:59:05 2013 +0200

configure: autoreconf

---
 configure |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/configure b/configure
index a9a2830..20a706a 100755
--- a/configure
+++ b/configure
@@ -7128,7 +7128,7 @@ fi
 set dummy thin_dump; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_THIN_DUMP_CMD+:} false; then :
+if test "${ac_cv_path_THIN_DUMP_CMD+set}" = set; then :
   $as_echo_n "(cached) " >&6
 else
   case $THIN_DUMP_CMD in
@@ -7142,7 +7142,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
     ac_cv_path_THIN_DUMP_CMD="$as_dir/$ac_word$ac_exec_ext"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2
@@ -7180,7 +7180,7 @@ fi
 set dummy thin_repair; ac_word=$2
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
 $as_echo_n "checking for $ac_word... " >&6; }
-if ${ac_cv_path_THIN_REPAIR_CMD+:} false; then :
+if test "${ac_cv_path_THIN_REPAIR_CMD+set}" = set; then :
   $as_echo_n "(cached) " >&6
 else
   case $THIN_REPAIR_CMD in
@@ -7194,7 +7194,7 @@ do
   IFS=$as_save_IFS
   test -z "$as_dir" && as_dir=.
     for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir/$ac_word$ac_exec_ext"; then
+  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
     ac_cv_path_THIN_REPAIR_CMD="$as_dir/$ac_word$ac_exec_ext"
     $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
     break 2


