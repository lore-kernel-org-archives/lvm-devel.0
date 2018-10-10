From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 10 Oct 2018 07:29:00 -0400
Subject: master - build: Use PYTHON env. variable when provided
Message-ID: <201810101129.w9ABT0ka031736@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6462e8dffc7ed53973ce796cec18fecc0fb89d77
Commit:        6462e8dffc7ed53973ce796cec18fecc0fb89d77
Parent:        9ed869cce19bdfa1b6c7ecf4574911e40df21c14
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Oct 10 12:40:09 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Oct 10 13:27:16 2018 +0200

build: Use PYTHON env. variable when provided

---
 configure    |    2 +-
 configure.ac |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/configure b/configure
index 3e1d5d7..286733c 100755
--- a/configure
+++ b/configure
@@ -11638,7 +11638,7 @@ fi
 ################################################################################
 
 if test "$BUILD_LVMDBUSD" = yes; then
-	unset PYTHON PYTHON_CONFIG
+	unset PYTHON_CONFIG
 	unset am_cv_pathless_PYTHON ac_cv_path_PYTHON am_cv_python_platform
 	unset am_cv_python_pythondir am_cv_python_version am_cv_python_pyexecdir
 	unset ac_cv_path_PYTHON_CONFIG ac_cv_path_ac_pt_PYTHON_CONFIG
diff --git a/configure.ac b/configure.ac
index 32cd921..c5d3207 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1151,7 +1151,7 @@ AS_IF([test "$NOTIFYDBUS_SUPPORT" = yes && test "BUILD_LVMDBUSD" = yes],
 dnl -- Enable Python dbus library
 
 if test "$BUILD_LVMDBUSD" = yes; then
-	unset PYTHON PYTHON_CONFIG
+	unset PYTHON_CONFIG
 	unset am_cv_pathless_PYTHON ac_cv_path_PYTHON am_cv_python_platform
 	unset am_cv_python_pythondir am_cv_python_version am_cv_python_pyexecdir
 	unset ac_cv_path_PYTHON_CONFIG ac_cv_path_ac_pt_PYTHON_CONFIG


