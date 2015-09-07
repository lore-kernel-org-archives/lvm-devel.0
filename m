From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  7 Sep 2015 15:45:17 +0000 (UTC)
Subject: master - configure: support --disable-dependency-tracking
Message-ID: <20150907154517.AFC4E60F6B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fc4f0d3fce05a601e768dbfb315b0c7e6d6c0030
Commit:        fc4f0d3fce05a601e768dbfb315b0c7e6d6c0030
Parent:        9403edbb93a2c337df790408e9ff3d26566b7443
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 7 13:57:38 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 7 17:43:11 2015 +0200

configure: support --disable-dependency-tracking

One-time build may enjoy little speedup of build when dependencies are not
calculated.
---
 WHATS_NEW    |    1 +
 configure.in |   10 ++++++++++
 make.tmpl.in |    2 ++
 3 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5f8846b..1ce1c81 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.131 - 
 =====================================
+  Configure supports --disable-dependency-tracking for one-time builds.
   Fix usage of configure.h when building in srcdir != builddir.
 
 Version 2.02.130 - 5th September 2015
diff --git a/configure.in b/configure.in
index 3b58527..4843678 100644
--- a/configure.in
+++ b/configure.in
@@ -156,6 +156,15 @@ AC_FUNC_STRTOD
 AC_FUNC_VPRINTF
 
 ################################################################################
+dnl -- Disable dependency tracking
+AC_MSG_CHECKING(whether to disable dependency tracking)
+AC_ARG_ENABLE(dependency-tracking,
+	      AC_HELP_STRING([--disable-dependency-tracking],
+			     [speeds up one-time build.]),
+	      USE_TRACKING=$enableval, USE_TRACKING=yes)
+AC_MSG_RESULT($USE_TRACKING)
+
+################################################################################
 dnl -- Enables statically-linked tools
 AC_MSG_CHECKING(whether to use static linking)
 AC_ARG_ENABLE(static_link,
@@ -2023,6 +2032,7 @@ AC_SUBST(UDEV_SYNC)
 AC_SUBST(UDEV_SYSTEMD_BACKGROUND_JOBS)
 AC_SUBST(UDEV_RULE_EXEC_DETECTION)
 AC_SUBST(UDEV_HAS_BUILTIN_BLKID)
+AC_SUBST(USE_TRACKING)
 AC_SUBST(VALGRIND_POOL)
 AC_SUBST(WRITE_INSTALL)
 AC_SUBST(DMEVENTD_PIDFILE)
diff --git a/make.tmpl.in b/make.tmpl.in
index 6fc1195..3fd3410 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -511,6 +511,7 @@ else
 	) > $@
 endif
 
+ifeq ("@USE_TRACKING@","yes")
 ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov \
  help check check_local check_cluster check_lvmetad check_lvmpolld))
     ifdef SOURCES
@@ -520,3 +521,4 @@ ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov \
        -include $(SOURCES2:.c=.d)
     endif
 endif
+endif


