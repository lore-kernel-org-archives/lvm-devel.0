From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 6 Dec 2018 04:52:50 -0500
Subject: master - build: Upse PYTHON_CONFIG env.variable when set
Message-ID: <201812060952.wB69qoV1027895@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=92b0d014aab12eee3fe1f757a5fb9ecfe9f4b58c
Commit:        92b0d014aab12eee3fe1f757a5fb9ecfe9f4b58c
Parent:        73687b7b75c4f12b6f21ba829898b4d13422db1c
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Nov 2 10:06:51 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Dec 6 09:02:47 2018 +0100

build: Upse PYTHON_CONFIG env.variable when set

This adds up to Commit 6462e8dffc7ed53973ce796cec18fecc0fb89d77.
---
 configure    |    1 -
 configure.ac |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/configure b/configure
index efd438c..66acdb2 100755
--- a/configure
+++ b/configure
@@ -11664,7 +11664,6 @@ fi
 ################################################################################
 
 if test "$BUILD_LVMDBUSD" = yes; then
-	unset PYTHON_CONFIG
 	unset am_cv_pathless_PYTHON ac_cv_path_PYTHON am_cv_python_platform
 	unset am_cv_python_pythondir am_cv_python_version am_cv_python_pyexecdir
 	unset ac_cv_path_PYTHON_CONFIG ac_cv_path_ac_pt_PYTHON_CONFIG
diff --git a/configure.ac b/configure.ac
index 3578f7b..2b29210 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1172,7 +1172,6 @@ AS_IF([test "$NOTIFYDBUS_SUPPORT" = yes && test "BUILD_LVMDBUSD" = yes],
 dnl -- Enable Python dbus library
 
 if test "$BUILD_LVMDBUSD" = yes; then
-	unset PYTHON_CONFIG
 	unset am_cv_pathless_PYTHON ac_cv_path_PYTHON am_cv_python_platform
 	unset am_cv_python_pythondir am_cv_python_version am_cv_python_pyexecdir
 	unset ac_cv_path_PYTHON_CONFIG ac_cv_path_ac_pt_PYTHON_CONFIG


