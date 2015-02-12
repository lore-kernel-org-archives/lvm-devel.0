From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Feb 2015 14:42:20 +0000 (UTC)
Subject: master - configure.in: AC_SUBST needs to be always executed
Message-ID: <20150212144220.3BCD660DBD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=425c04e4dc54f1c8aee261217b5b0fc00df643ae
Commit:        425c04e4dc54f1c8aee261217b5b0fc00df643ae
Parent:        d303d9973f2a60db3c58b831193686fdb467e4f4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 12 15:29:58 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 12 15:40:53 2015 +0100

configure.in: AC_SUBST needs to be always executed

---
 configure.in            |    4 ++--
 lib/misc/configure.h.in |    3 +++
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/configure.in b/configure.in
index 18e1c17..b4b9ec2 100644
--- a/configure.in
+++ b/configure.in
@@ -1029,12 +1029,10 @@ AC_SUBST(VALGRIND_CFLAGS)
 
 if test x$HAVE_VALGRIND = xyes; then
 	AC_DEFINE([HAVE_VALGRIND], 1, [valgrind.h found])
-	AC_SUBST(HAVE_VALGRIND)
 fi
 
 if test x$VALGRIND_POOL = xyes; then
 	AC_DEFINE([VALGRIND_POOL], 1, [Enable a valgrind aware build of pool])
-	AC_SUBST(VALGRIND_POOL)
 fi
 
 ################################################################################
@@ -1723,6 +1721,7 @@ AC_SUBST(FSADM)
 AC_SUBST(BLKDEACTIVATE)
 AC_SUBST(HAVE_LIBDL)
 AC_SUBST(HAVE_REALTIME)
+AC_SUBST(HAVE_VALGRIND)
 AC_SUBST(INTL)
 AC_SUBST(INTL_PACKAGE)
 AC_SUBST(JOBS)
@@ -1782,6 +1781,7 @@ AC_SUBST(UDEV_SYNC)
 AC_SUBST(UDEV_SYSTEMD_BACKGROUND_JOBS)
 AC_SUBST(UDEV_RULE_EXEC_DETECTION)
 AC_SUBST(UDEV_HAS_BUILTIN_BLKID)
+AC_SUBST(VALGRIND_POOL)
 AC_SUBST(WRITE_INSTALL)
 AC_SUBST(DMEVENTD_PIDFILE)
 AC_SUBST(LVMETAD_PIDFILE)
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 7c0d64c..9a002d2 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -459,6 +459,9 @@
 /* Define to 1 if you have the <utmpx.h> header file. */
 #undef HAVE_UTMPX_H
 
+/* valgrind.h found */
+#undef HAVE_VALGRIND
+
 /* Define to 1 if you have the `vfork' function. */
 #undef HAVE_VFORK
 


