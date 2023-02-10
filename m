From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Feb 2023 16:53:18 +0000 (GMT)
Subject: main - configure.ac: use only portable POSIX shell
Message-ID: <20230210165318.DEE7A3858C5F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d456c1f3c509f8a033f3ec5830caaf44e830b644
Commit:        d456c1f3c509f8a033f3ec5830caaf44e830b644
Parent:        631762d6db1390487694e6b7ae1de885911458b2
Author:        David Seifert <soap@gentoo.org>
AuthorDate:    Sun Nov 27 15:35:05 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 10 17:50:27 2023 +0100

configure.ac: use only portable POSIX shell

`[[ ... ]]` only works in bash, and not in POSIX sh, specifically
dash fails on this, which is a popular alternative to bash for running
configure scripts.

test's `-a` and `-o` options are considered obsolescent by POSIX,
because they interact badly with expressions and can become ambiguous
depending on string arguments:
https://pubs.opengroup.org/onlinepubs/9699919799/utilities/test.html

`==` only works in bash.
---
 configure.ac | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/configure.ac b/configure.ac
index f39c87d08..f2cf48d8e 100644
--- a/configure.ac
+++ b/configure.ac
@@ -206,7 +206,7 @@ AC_PREFIX_DEFAULT(/usr)
 
 ################################################################################
 dnl -- Clear default exec_prefix - install into /sbin rather than /usr/sbin
-test "$exec_prefix" = NONE -a "$prefix" = NONE && exec_prefix=""
+test "$exec_prefix" = "NONE" && test "$prefix" = "NONE" && exec_prefix=""
 
 test "x$prefix" = xNONE && prefix=$ac_default_prefix
 # Let make expand exec_prefix.
@@ -428,11 +428,11 @@ case "$THIN" in
 		THIN_CHECK_VSN_MAJOR=`echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $1}'`
 		THIN_CHECK_VSN_MINOR=`echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $2}'`
 
-		if test -z "$THIN_CHECK_VSN_MAJOR" -o -z "$THIN_CHECK_VSN_MINOR"; then
+		if test -z "$THIN_CHECK_VSN_MAJOR" || test -z "$THIN_CHECK_VSN_MINOR"; then
 			AC_MSG_WARN([$THIN_CHECK_CMD: Bad version "$THIN_CHECK_VSN" found])
 			THIN_CHECK_VERSION_WARN=y
 			THIN_CHECK_NEEDS_CHECK=no
-		elif test "$THIN_CHECK_VSN_MAJOR" -eq 0 -a "$THIN_CHECK_VSN_MINOR" -lt 3; then
+		elif test "$THIN_CHECK_VSN_MAJOR" -eq 0 && test "$THIN_CHECK_VSN_MINOR" -lt 3; then
 			AC_MSG_WARN([$THIN_CHECK_CMD: Old version "$THIN_CHECK_VSN" found])
 			THIN_CHECK_VERSION_WARN=y
 			THIN_CHECK_NEEDS_CHECK=no
@@ -551,7 +551,7 @@ case "$CACHE" in
 			CACHE_CHECK_NEEDS_CHECK=no
 		elif test "$CACHE_CHECK_VSN_MAJOR" -eq 0 ; then
 			if test "$CACHE_CHECK_VSN_MINOR" -lt 5 \
-				|| test "$CACHE_CHECK_VSN_MINOR" -eq 5 -a "$CACHE_CHECK_VSN_PATCH" -lt 4; then
+				|| ( test "$CACHE_CHECK_VSN_MINOR" -eq 5 && test "$CACHE_CHECK_VSN_PATCH" -lt 4 ); then
 				AC_MSG_WARN([$CACHE_CHECK_CMD: Old version "$CACHE_CHECK_VSN" found])
 				CACHE_CHECK_VERSION_WARN=y
 				CACHE_CHECK_NEEDS_CHECK=no
@@ -803,7 +803,7 @@ fi
 
 ################################################################################
 dnl -- Look for corosync libraries if required.
-if [[ "$BUILD_CMIRRORD" = yes ]]; then
+if test "$BUILD_CMIRRORD" = yes; then
 	pkg_config_init
 
 	if test "$HAVE_CPG" != yes; then
@@ -1403,8 +1403,7 @@ AC_CHECK_LIB(dl, dlopen,
 
 ################################################################################
 dnl -- Check for shared/static conflicts
-if [[ \( "$LVM1" = shared -o "$POOL" = shared \
-      \) -a "$STATIC_LINK" = yes ]]; then
+if ( test "$LVM1" = shared || test "$POOL" = shared ) && test "$STATIC_LINK" = yes; then
 	AC_MSG_ERROR([Features cannot be 'shared' when building statically])
 fi
 
@@ -1506,7 +1505,7 @@ AC_CHECK_HEADERS(getopt.h, AC_DEFINE([HAVE_GETOPTLONG], 1, [Define to 1 if getop
 
 ################################################################################
 dnl -- Check for editline
-if test "$EDITLINE" == yes; then
+if test "$EDITLINE" = yes; then
 	PKG_CHECK_MODULES([EDITLINE], [libedit], [
 		AC_DEFINE([EDITLINE_SUPPORT], 1,
 			[Define to 1 to include the LVM editline shell.])], AC_MSG_ERROR(

