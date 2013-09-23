From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 23 Sep 2013 10:16:30 +0000 (UTC)
Subject: master - Makefile: add missing deps
Message-ID: <20130923101630.0798A61326@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ebf66ac316da27399308d8cd553988c78f7ea150
Commit:        ebf66ac316da27399308d8cd553988c78f7ea150
Parent:        1fdead8d97376c757af01b55d7556e3411255124
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 5 11:32:42 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 23 12:13:51 2013 +0200

Makefile: add missing deps

Add missing deps for device-mapper build of scripts dir.
Cleanup multiple SUBDIR lines together.
---
 Makefile.in |    7 ++-----
 WHATS_NEW   |    1 +
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 81002ea..e1178ee 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -16,7 +16,7 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-SUBDIRS = conf include man
+SUBDIRS = conf daemons include lib libdaemon libdm man scripts tools
 
 ifeq ("@UDEV_RULES@", "yes")
   SUBDIRS += udev
@@ -26,8 +26,6 @@ ifeq ("@INTL@", "yes")
   SUBDIRS += po
 endif
 
-SUBDIRS += lib tools daemons libdm libdaemon
-
 ifeq ("@APPLIB@", "yes")
   SUBDIRS += liblvm
 endif
@@ -36,8 +34,6 @@ ifeq ("@PYTHON_BINDINGS@", "yes")
   SUBDIRS += python
 endif
 
-SUBDIRS += scripts
-
 ifeq ($(MAKECMDGOALS),clean)
   SUBDIRS += test
 endif
@@ -67,6 +63,7 @@ libdm.device-mapper: include.device-mapper
 liblvm.device-mapper: include.device-mapper
 daemons.device-mapper: libdm.device-mapper
 tools.device-mapper: libdm.device-mapper
+scripts.device-mapper: include.device-mapper
 device-mapper: tools.device-mapper daemons.device-mapper man.device-mapper
 
 ifeq ("@INTL@", "yes")
diff --git a/WHATS_NEW b/WHATS_NEW
index cca4c0e..983e582 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.102
 ======================================
+  Fix missing build dependency for scripts subdir in Makefile.
   Extend lv_info() for more efficient lv_is_active_locally() check.
 
 Version 2.02.101 - 20th September 2013


