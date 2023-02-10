From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Feb 2023 19:56:12 +0000 (GMT)
Subject: main - configure.ac: better blkid test
Message-ID: <20230210195612.1AE9A3858414@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2a72f8a49cf6601db7c987c7c4d6a72a29a59a1e
Commit:        2a72f8a49cf6601db7c987c7c4d6a72a29a59a1e
Parent:        7d419b374a0bd2ebcc56e77d2578684aee998cbd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 10 19:19:31 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 10 20:53:10 2023 +0100

configure.ac: better blkid test

Previous commit e67ebc5c40948bcbea536fd407535009a76ede00 used incorrect check
for blkid version.
Fix it by always checking for at least version 2.24,
as we can't use older version anyway.
Added BLKID_SUBLKS_FSINFO is present in newer version.
---
 configure.ac | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/configure.ac b/configure.ac
index 7f9b3e664..49b06145d 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1113,12 +1113,11 @@ AC_ARG_ENABLE(blkid_wiping,
 #       so lvresize can check detected flag here
 #
 DEFAULT_USE_BLKID_WIPING=0
-AS_IF([test "$BLKID_WIPING" != "no"], [blkdir_version=">= 2.24"], [blkid_version=""])
 
-PKG_CHECK_MODULES([BLKID], [blkid $blkid_version ], [
+PKG_CHECK_MODULES([BLKID], [blkid >= 2.24], [
 	HAVE_BLKID=1
 
-	AC_CACHE_CHECK([for blkdid.h supports SUBLKS_FSINFO.],
+	AC_CACHE_CHECK([for blkdid.h defines BLKID_SUBLKS_FSINFO.],
 		[ac_cv_have_blkid_sublks_fsinfo],
 		[AC_COMPILE_IFELSE([AC_LANG_PROGRAM([#include <blkid/blkid.h>
 #ifndef BLKID_SUBLKS_FSINFO

