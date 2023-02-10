From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Feb 2023 21:33:26 +0000 (GMT)
Subject: main - configure.ac: check for blkid when required
Message-ID: <20230210213326.560323858414@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1416bb383719f5d4dde42a9bfb123e0a7c38a36c
Commit:        1416bb383719f5d4dde42a9bfb123e0a7c38a36c
Parent:        d1bfa400a18c0223dcc60379dcec8b05b2ef6d5c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 10 21:31:07 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 10 22:29:33 2023 +0100

configure.ac: check for blkid  when required

We still need to support build without any blkid present,
so use PKG_CHECK_EXISTS() instead of direct failure
from PKG_CHECK_MODULES for too old version.
---
 configure.ac | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/configure.ac b/configure.ac
index 3177012e2..1c4d5fd1f 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1126,11 +1126,12 @@ AC_ARG_ENABLE(blkid_wiping,
 #       so lvresize can check detected flag here
 #
 DEFAULT_USE_BLKID_WIPING=0
+PKG_CHECK_EXISTS([blkid >= 2.24], [HAVE_BLKID="yes"], [HAVE_BLKID="no"])
 
-PKG_CHECK_MODULES([BLKID], [blkid >= 2.24], [
-	HAVE_BLKID=1
+AS_IF([test "$HAVE_BLKID" = "yes"], [
+	PKG_CHECK_MODULES([BLKID], [blkid >= 2.24], [
 
-	AC_CACHE_CHECK([for blkdid.h defines BLKID_SUBLKS_FSINFO.],
+	AC_CACHE_CHECK([for blkid.h defines BLKID_SUBLKS_FSINFO.],
 		[ac_cv_have_blkid_sublks_fsinfo],
 		[AC_COMPILE_IFELSE([AC_LANG_PROGRAM([#include <blkid/blkid.h>
 #ifndef BLKID_SUBLKS_FSINFO
@@ -1138,14 +1139,15 @@ PKG_CHECK_MODULES([BLKID], [blkid >= 2.24], [
 #endif])],
 		[ac_cv_have_blkid_sublks_fsinfo="yes"], [ac_cv_have_blkid_sublks_fsinfo="no"])])
 
-		AC_IF_YES(ac_cv_have_blkid_sublks_fsinfo,
-			  AC_DEFINE(HAVE_BLKID_SUBLKS_FSINFO, 1,
-				    [Define if blkid.h has BLKID_SUBLKS_FSINFO]))
+	AC_IF_YES(ac_cv_have_blkid_sublks_fsinfo,
+		  AC_DEFINE(HAVE_BLKID_SUBLKS_FSINFO, 1,
+			    [Define if blkid.h has BLKID_SUBLKS_FSINFO]))
+	])
 ])
 
 AS_IF([test "$BLKID_WIPING" != "no"], [
-	AS_IF([test "$HAVE_BLKID" = 1], [
-		BLKID_WIPING=yes
+	AS_IF([test "$HAVE_BLKID" = "yes"], [
+		BLKID_WIPING="yes"
 		BLKID_PC="blkid"
 		DEFAULT_USE_BLKID_WIPING=1
 		AC_DEFINE([BLKID_WIPING_SUPPORT], 1, [Define to 1 to use libblkid detection of signatures when wiping.])

