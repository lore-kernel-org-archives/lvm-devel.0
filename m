From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  6 Mar 2014 16:31:07 +0000 (UTC)
Subject: master - configure: drop duplicated SUBST
Message-ID: <20140306163107.C7C6D6105D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=061acd177f4572f75107bac6a2f7379a55ceec93
Commit:        061acd177f4572f75107bac6a2f7379a55ceec93
Parent:        cfc9e178bf24982f14c4d1e9034056ff6c3d3e31
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 6 16:00:04 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 6 16:16:11 2014 +0100

configure: drop duplicated SUBST

These subst are already there from pkg_config
---
 configure.in |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/configure.in b/configure.in
index 58c7bdc..88edb29 100644
--- a/configure.in
+++ b/configure.in
@@ -1318,7 +1318,7 @@ AC_CHECK_HEADERS(getopt.h, AC_DEFINE([HAVE_GETOPTLONG], 1, [Define to 1 if getop
 
 ################################################################################
 dnl -- Check for readline (Shamelessly copied from parted 1.4.17)
-if test x$READLINE != xno; then
+if test "$READLINE" != no; then
 	lvm_saved_libs=$LIBS
 	AC_SEARCH_LIBS([tgetent], [tinfo ncurses curses termcap termlib],
 		READLINE_LIBS=$ac_cv_search_tgetent, [
@@ -1610,7 +1610,6 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[[()]]' '{print $2}'`
 ################################################################################
 AC_SUBST(APPLIB)
 AC_SUBST(AWK)
-AC_SUBST(BLKID_LIBS)
 AC_SUBST(BLKID_PC)
 AC_SUBST(BLKID_WIPING)
 AC_SUBST(BUILD_CMIRRORD)
@@ -1713,15 +1712,12 @@ AC_SUBST(THIN)
 AC_SUBST(THIN_CHECK_CMD)
 AC_SUBST(THIN_DUMP_CMD)
 AC_SUBST(THIN_REPAIR_CMD)
-AC_SUBST(UDEV_LIBS)
 AC_SUBST(UDEV_PC)
 AC_SUBST(UDEV_RULES)
 AC_SUBST(UDEV_SYNC)
 AC_SUBST(UDEV_SYSTEMD_BACKGROUND_JOBS)
 AC_SUBST(UDEV_RULE_EXEC_DETECTION)
 AC_SUBST(UDEV_HAS_BUILTIN_BLKID)
-AC_SUBST(CUNIT_LIBS)
-AC_SUBST(CUNIT_CFLAGS)
 AC_SUBST(WRITE_INSTALL)
 AC_SUBST(DMEVENTD_PIDFILE)
 AC_SUBST(LVMETAD_PIDFILE)


