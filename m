From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  2 Oct 2020 20:27:48 +0000 (GMT)
Subject: master - configure: use our ordered list of python names
Message-ID: <20201002202748.C79233945C25@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9885c9b43a6c72ea89852989f4fa4a9a4619014a
Commit:        9885c9b43a6c72ea89852989f4fa4a9a4619014a
Parent:        2df7ef58a547a62b83264d291295890ce72066d5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 20:40:52 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 2 20:52:38 2020 +0200

configure: use our ordered list of python names

Since it seems it's prefered now to use python3 in path name,
prefer this name as first in the list.
---
 WHATS_NEW    | 1 +
 configure    | 2 +-
 configure.ac | 3 +++
 3 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a8639ff65..c7a3207f9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.11 - 
 ==================================
+  Configure use own python path name order to prefer using python3.
   Add configure --enable-editline support as an alternative to readline.
   Enhance reporting and error handling when creating thin volumes.
   Enable vgsplit for VDO volumes.
diff --git a/configure b/configure
index 4020eaa80..29d19f249 100755
--- a/configure
+++ b/configure
@@ -11881,7 +11881,7 @@ if ${am_cv_pathless_PYTHON+:} false; then :
   $as_echo_n "(cached) " >&6
 else
 
-	for am_cv_pathless_PYTHON in python python2 python3  python3.9 python3.8 python3.7 python3.6 python3.5 python3.4 python3.3  python3.2 python3.1 python3.0  python2.7 python2.6 python2.5 python2.4 python2.3 python2.2 python2.1  python2.0 none; do
+	for am_cv_pathless_PYTHON in  python3 python2 python 	python3.9 python3.8 python3.7 python3.6 python3.5 python3.4 python3.3 python3.2 python3.1 python3.0 	python2.7 python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0  none; do
 	  test "$am_cv_pathless_PYTHON" = none && break
 	  prog="import sys
 # split strings by '.' and convert to numeric.  Append some zeros
diff --git a/configure.ac b/configure.ac
index 341591561..ee21b879d 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1224,6 +1224,9 @@ if test "$BUILD_LVMDBUSD" = yes; then
 	unset am_cv_pathless_PYTHON ac_cv_path_PYTHON am_cv_python_platform
 	unset am_cv_python_pythondir am_cv_python_version am_cv_python_pyexecdir
 	unset ac_cv_path_PYTHON_CONFIG ac_cv_path_ac_pt_PYTHON_CONFIG
+	m4_define_default([_AM_PYTHON_INTERPRETER_LIST],[ python3 python2 python dnl
+	python3.9 python3.8 python3.7 python3.6 python3.5 python3.4 python3.3 python3.2 python3.1 python3.0 dnl
+	python2.7 python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0 ])
 	AM_PATH_PYTHON([3])
 	PYTHON3=$PYTHON
 	test -z "$PYTHON3" && AC_MSG_ERROR([python3 is required for --enable-python3_bindings or --enable-dbus-service but cannot be found])


