From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Feb 2023 16:53:22 +0000 (GMT)
Subject: main - lvresize: better detection of BLKID_SUBLKS_FSINFO
Message-ID: <20230210165322.853E0385840D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1fb5107eea2182415eef50ba7bec0fdf7600659c
Commit:        1fb5107eea2182415eef50ba7bec0fdf7600659c
Parent:        cf204ce55ea892ffaa4ff63dac548145544679fb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 8 14:39:43 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 10 17:50:27 2023 +0100

lvresize: better detection of BLKID_SUBLKS_FSINFO

Use configure detection instead of trying to directly include
blkid.h inside lvresize.c - where we do not pass in BLKID_CFLAGS
and since we actually do not need to use blkid there, introeduce
test variable HAVE_BLKID_SUBLKS_FSINFO and avoid trying to
use blkid.h in this place - this also fixes builing problem for
systems without blkid.h.
---
 configure.ac           | 25 ++++++++++++++++++++++++-
 include/configure.h.in |  3 +++
 tools/lvresize.c       |  4 +---
 3 files changed, 28 insertions(+), 4 deletions(-)

diff --git a/configure.ac b/configure.ac
index 4ddf0a430..95bc44b32 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1109,9 +1109,30 @@ AC_ARG_ENABLE(blkid_wiping,
 			     [disable libblkid detection of signatures when wiping and use native code instead]),
 	      BLKID_WIPING=$enableval, BLKID_WIPING=maybe)
 
+# TODO: possibly detect right version of blkid with BLKID_SUBLKS_FSINFO support
+#       so lvresize can check detected flag here
+#
 DEFAULT_USE_BLKID_WIPING=0
+AS_IF([test "$BLKID_WIPING" != "no"], [blkdir_version=">= 2.24"], [blkid_version=""])
+
+PKG_CHECK_MODULES([BLKID], [blkid $blkid_version ], [
+	HAVE_BLKID=1
+
+	AC_CACHE_CHECK([for blkdid.h supports SUBLKS_FSINFO.],
+		[ac_cv_have_blkid_sublks_fsinfo],
+		[AC_COMPILE_IFELSE([AC_LANG_PROGRAM([#include <blkid/blkid.h>
+#ifndef BLKID_SUBLKS_FSINFO
+#error BLKID_SUBLKS_FSINFO is missing
+#endif])],
+		[ac_cv_have_blkid_sublks_fsinfo="yes"], [ac_cv_have_blkid_sublks_fsinfo="no"])])
+
+		AC_IF_YES(ac_cv_have_blkid_sublks_fsinfo,
+			  AC_DEFINE(HAVE_BLKID_SUBLKS_FSINFO, 1,
+				    [Define if blkid.h has BLKID_SUBLKS_FSINFO]))
+])
+
 AS_IF([test "$BLKID_WIPING" != "no"], [
-	PKG_CHECK_MODULES([BLKID], [blkid >= 2.24], [
+	AS_IF([test "$HAVE_BLKID" = 1], [
 		BLKID_WIPING=yes
 		BLKID_PC="blkid"
 		DEFAULT_USE_BLKID_WIPING=1
@@ -1858,6 +1879,8 @@ AC_SUBST(FSADM)
 AC_SUBST(FSADM_PATH)
 AC_SUBST(LVRESIZE_FS_HELPER_PATH)
 AC_SUBST(BLKDEACTIVATE)
+AC_SUBST(HAVE_BLKID)
+AC_SUBST(HAVE_BLKID_SUBLKS_FSINFO)
 AC_SUBST(HAVE_LIBDL)
 AC_SUBST(HAVE_REALTIME)
 AC_SUBST(HAVE_VALGRIND)
diff --git a/include/configure.h.in b/include/configure.h.in
index e7abca2f1..fb5625156 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -154,6 +154,9 @@
 /* Define to 1 if you have the `atexit' function. */
 #undef HAVE_ATEXIT
 
+/* Define if blkid.h has BLKID_SUBLKS_FSINFO */
+#undef HAVE_BLKID_SUBLKS_FSINFO
+
 /* Define if ioctl BLKZEROOUT can be used for device zeroing. */
 #undef HAVE_BLKZEROOUT
 
diff --git a/tools/lvresize.c b/tools/lvresize.c
index f3cee8322..fc66bf0b8 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -15,8 +15,6 @@
 
 #include "tools.h"
 
-#include <blkid/blkid.h>
-
 static int _lvresize_params(struct cmd_context *cmd, struct lvresize_params *lp)
 {
 	const char *type_str = arg_str_value(cmd, type_ARG, NULL);
@@ -98,7 +96,7 @@ static int _lvresize_params(struct cmd_context *cmd, struct lvresize_params *lp)
 			return 0;
 		}
 
-#ifdef BLKID_SUBLKS_FSINFO
+#ifdef HAVE_BLKID_SUBLKS_FSINFO
 		/*
 		 * When the libblkid fs info feature is available, use the
 		 * the newer fs resizing capabability unless the older

