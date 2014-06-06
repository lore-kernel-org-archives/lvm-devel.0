From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  6 Jun 2014 08:32:36 +0000 (UTC)
Subject: master - configure: update libcpg test
Message-ID: <20140606083236.4905460DAC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f115a4a53fe6c3a3121e200c7f8796fb086c0c6e
Commit:        f115a4a53fe6c3a3121e200c7f8796fb086c0c6e
Parent:        14f482077dadd33e35a33cbd57bc80a884992794
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 6 10:29:47 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 6 10:31:45 2014 +0200

configure: update libcpg test

PKG_CHECK_MODULES needs old-way if;then;fi.
---
 configure    |    4 +++-
 configure.in |    8 +++++---
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/configure b/configure
index 034ee12..dec82de 100755
--- a/configure
+++ b/configure
@@ -9149,7 +9149,8 @@ $as_echo "yes" >&6; }
 	HAVE_SACKPT=yes
 fi
 
-	test "$HAVE_CPG" != yes &&
+	if test "$HAVE_CPG" != yes; then
+
 pkg_failed=no
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for CPG" >&5
 $as_echo_n "checking for CPG... " >&6; }
@@ -9240,6 +9241,7 @@ else
 $as_echo "yes" >&6; }
 
 fi
+	fi
 fi
 
 ################################################################################
diff --git a/configure.in b/configure.in
index 12404ba..d92e03e 100644
--- a/configure.in
+++ b/configure.in
@@ -847,7 +847,9 @@ if [[ "$BUILD_CMIRRORD" = yes ]]; then
 		[AC_MSG_RESULT([no libSaCkpt, compiling without it])
 		AC_DEFINE([CMIRROR_HAS_CHECKPOINT], 0, [Define to 0 to exclude libSaCkpt.])])
 
-	test "$HAVE_CPG" != yes && PKG_CHECK_MODULES(CPG, libcpg)
+	if test "$HAVE_CPG" != yes; then
+		PKG_CHECK_MODULES(CPG, libcpg)
+	fi
 fi
 
 ################################################################################
@@ -911,7 +913,7 @@ fi
 dnl -- Enable testing
 AC_MSG_CHECKING(whether to enable unit testing)
 AC_ARG_ENABLE(testing,
-              AC_HELP_STRING([--enable-testing],
+	      AC_HELP_STRING([--enable-testing],
 			     [enable testing targets in the makefile]),
 	      TESTING=$enableval, TESTING=no)
 AC_MSG_RESULT($TESTING)
@@ -925,7 +927,7 @@ fi
 dnl -- Enable valgrind awareness of memory pools
 AC_MSG_CHECKING(whether to enable valgrind awareness of pools)
 AC_ARG_ENABLE(valgrind_pool,
-              AC_HELP_STRING([--enable-valgrind-pool],
+	      AC_HELP_STRING([--enable-valgrind-pool],
 			     [enable valgrind awareness of pools]),
 	      VALGRIND_POOL=$enableval, VALGRIND_POOL=no)
 AC_MSG_RESULT($VALGRIND_POOL)


