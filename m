From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 3 May 2018 09:23:42 -0400
Subject: master - configure.ac: Remove some more remnants of optional RAID
Message-ID: <201805031323.w43DNgEn013686@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9cab0057971eea27f31c8e3b2a83d69337d0155d
Commit:        9cab0057971eea27f31c8e3b2a83d69337d0155d
Parent:        90d0ff66362f3f21f79b5204bcc072c12185883b
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu May 3 14:21:21 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu May 3 14:21:21 2018 +0100

configure.ac: Remove some more remnants of optional RAID

(It's now always 'internal')
---
 configure.ac |   21 +++------------------
 1 files changed, 3 insertions(+), 18 deletions(-)

diff --git a/configure.ac b/configure.ac
index dc01a8e..6df883b 100644
--- a/configure.ac
+++ b/configure.ac
@@ -332,13 +332,6 @@ esac
 
 ################################################################################
 dnl -- raid inclusion type
-AC_MSG_CHECKING(whether to include raid)
-AC_ARG_WITH(raid,
-	    AC_HELP_STRING([--with-raid=TYPE],
-			   [raid support: internal/shared/none [internal]]),
-	    RAID=$withval, RAID=internal)
-AC_MSG_RESULT($RAID)
-
 AC_ARG_WITH(default-mirror-segtype,
 	    AC_HELP_STRING([--with-default-mirror-segtype=TYPE],
 			   [default mirror segtype: raid1/mirror [raid1]]),
@@ -347,14 +340,9 @@ AC_ARG_WITH(default-raid10-segtype,
 	    AC_HELP_STRING([--with-default-raid10-segtype=TYPE],
 			   [default mirror segtype: raid10/mirror [raid10]]),
 			   DEFAULT_RAID10_SEGTYPE=$withval, DEFAULT_RAID10_SEGTYPE="raid10")
-case "$RAID" in
-  none)  test "$DEFAULT_MIRROR_SEGTYPE" = "raid1" && DEFAULT_MIRROR_SEGTYPE="mirror"
-	test "$DEFAULT_RAID10_SEGTYPE" = "raid10" && DEFAULT_RAID10_SEGTYPE="mirror" ;;
-  shared) ;;
-  internal) AC_DEFINE([RAID_INTERNAL], 1,
-		      [Define to 1 to include built-in support for raid.]) ;;
-  *) AC_MSG_ERROR([--with-raid parameter invalid]) ;;
-esac
+
+AC_DEFINE([RAID_INTERNAL], 1,
+	  [Define to 1 to include built-in support for raid.]) ;;
 
 AC_DEFINE_UNQUOTED([DEFAULT_MIRROR_SEGTYPE], ["$DEFAULT_MIRROR_SEGTYPE"],
 		   [Default segtype used for mirror volumes.])
@@ -1551,8 +1539,6 @@ AC_CHECK_LIB(dl, dlopen,
 ################################################################################
 dnl -- Check for shared/static conflicts
 if [[ \( "$LVM1" = shared -o "$POOL" = shared -o "$CLUSTER" = shared \
-      -o "$SNAPSHOTS" = shared -o "$MIRRORS" = shared \
-      -o "$RAID" = shared -o "$CACHE" = shared \
       \) -a "$STATIC_LINK" = yes ]]; then
 	AC_MSG_ERROR([Features cannot be 'shared' when building statically])
 fi
@@ -2042,7 +2028,6 @@ AC_SUBST(PYTHON2DIR)
 AC_SUBST(PYTHON3DIR)
 AC_SUBST(QUORUM_CFLAGS)
 AC_SUBST(QUORUM_LIBS)
-AC_SUBST(RAID)
 AC_SUBST(RT_LIBS)
 AC_SUBST(READLINE_LIBS)
 AC_SUBST(REPLICATORS)


