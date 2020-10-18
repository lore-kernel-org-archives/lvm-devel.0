From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 18 Oct 2020 21:02:37 +0000 (GMT)
Subject: stable-2.02 - configure: fix python paths
Message-ID: <20201018210237.480F43857C6F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0559ce6be098253fecb8d2cc42d391b270e75894
Commit:        0559ce6be098253fecb8d2cc42d391b270e75894
Parent:        789fc2a081545ff81c5cb11c3503e93701b96393
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 17 22:26:50 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 18 21:28:13 2020 +0200

configure: fix python paths

Stable branch supports also python2.
---
 configure    | 6 ++++--
 configure.ac | 8 ++++----
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/configure b/configure
index 3b52cf244..6859d51b1 100755
--- a/configure
+++ b/configure
@@ -12665,6 +12665,7 @@ if test "$PYTHON_BINDINGS" = yes; then
 	as_fn_error $? "--enable-python-bindings is replaced by --enable-python2-bindings and --enable-python3-bindings" "$LINENO" 5
 fi
 
+
 if test "$PYTHON2_BINDINGS" = yes; then
 
 
@@ -12707,7 +12708,7 @@ if ${am_cv_pathless_PYTHON+:} false; then :
   $as_echo_n "(cached) " >&6
 else
 
-	for am_cv_pathless_PYTHON in python python2 python3  python3.9 python3.8 python3.7 python3.6 python3.5 python3.4 python3.3  python3.2 python3.1 python3.0  python2.7 python2.6 python2.5 python2.4 python2.3 python2.2 python2.1  python2.0 none; do
+	for am_cv_pathless_PYTHON in  python3 python2 python python3.9 python3.8 python3.7 python3.6 python3.5 python3.4 python3.3 python3.2 python3.1 python3.0 python2.7 python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0  none; do
 	  test "$am_cv_pathless_PYTHON" = none && break
 	  prog="import sys
 # split strings by '.' and convert to numeric.  Append some zeros
@@ -13275,7 +13276,7 @@ if ${am_cv_pathless_PYTHON+:} false; then :
   $as_echo_n "(cached) " >&6
 else
 
-	for am_cv_pathless_PYTHON in  python3 python2 python 	python3.9 python3.8 python3.7 python3.6 python3.5 python3.4 python3.3 python3.2 python3.1 python3.0 	python2.7 python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0  none; do
+	for am_cv_pathless_PYTHON in  python3 python2 python python3.9 python3.8 python3.7 python3.6 python3.5 python3.4 python3.3 python3.2 python3.1 python3.0 python2.7 python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0  none; do
 	  test "$am_cv_pathless_PYTHON" = none && break
 	  prog="import sys
 # split strings by '.' and convert to numeric.  Append some zeros
@@ -15658,6 +15659,7 @@ _ACEOF
 
 
 
+
 
 
 
diff --git a/configure.ac b/configure.ac
index 41217c651..9d90ff062 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1433,6 +1433,9 @@ if test "$PYTHON_BINDINGS" = yes; then
 	AC_MSG_ERROR([--enable-python-bindings is replaced by --enable-python2-bindings and --enable-python3-bindings])
 fi
 
+m4_define_default([_AM_PYTHON_INTERPRETER_LIST],[ python3 python2 python dnl
+python3.9 python3.8 python3.7 python3.6 python3.5 python3.4 python3.3 python3.2 python3.1 python3.0 dnl
+python2.7 python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0 ])
 if test "$PYTHON2_BINDINGS" = yes; then
 	AM_PATH_PYTHON([2])
 	AC_PATH_TOOL(PYTHON2, python2)
@@ -1445,15 +1448,12 @@ if test "$PYTHON2_BINDINGS" = yes; then
 	PYTHON2DIR=$pythondir
 	PYTHON_BINDINGS=yes
 fi
-	
+
 if test "$PYTHON3_BINDINGS" = yes -o "$BUILD_LVMDBUSD" = yes; then
 	unset PYTHON PYTHON_CONFIG
 	unset am_cv_pathless_PYTHON ac_cv_path_PYTHON am_cv_python_platform
 	unset am_cv_python_pythondir am_cv_python_version am_cv_python_pyexecdir
 	unset ac_cv_path_PYTHON_CONFIG ac_cv_path_ac_pt_PYTHON_CONFIG
-	m4_define_default([_AM_PYTHON_INTERPRETER_LIST],[ python3 python2 python dnl
-	python3.9 python3.8 python3.7 python3.6 python3.5 python3.4 python3.3 python3.2 python3.1 python3.0 dnl
-	python2.7 python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0 ])
 	AM_PATH_PYTHON([3])
 	PYTHON3=$PYTHON
 	test -z "$PYTHON3" && AC_MSG_ERROR([python3 is required for --enable-python3_bindings or --enable-dbus-service but cannot be found])


