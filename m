From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 26 Sep 2012 17:55:52 +0000 (UTC)
Subject: master - Makefiles: Build libdaemonclient unconditionally.
Message-ID: <20120926175552.3BA94A33AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0a87fed794f2886047298bbc7b21919e9fc04951
Commit:        0a87fed794f2886047298bbc7b21919e9fc04951
Parent:        ca0c8673b2064ceb840ee7f4cb5804b33e55f3c7
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Sep 10 07:40:00 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 26 17:26:23 2012 +0200

Makefiles: Build libdaemonclient unconditionally.

---
 Makefile.in           |    6 +-----
 libdaemon/Makefile.in |    4 +++-
 make.tmpl.in          |    8 +++-----
 3 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 4316190..6b153d3 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -26,16 +26,12 @@ ifeq ("@INTL@", "yes")
   SUBDIRS += po
 endif
 
-SUBDIRS += lib tools daemons libdm
+SUBDIRS += lib tools daemons libdm libdaemon
 
 ifeq ("@APPLIB@", "yes")
   SUBDIRS += liblvm
 endif
 
-ifeq ("@BUILD_LVMETAD@", "yes")
-  SUBDIRS += libdaemon
-endif
-
 SUBDIRS += scripts
 
 # FIXME Should use intermediate Makefiles here!
diff --git a/libdaemon/Makefile.in b/libdaemon/Makefile.in
index fbe5a08..dbe6516 100644
--- a/libdaemon/Makefile.in
+++ b/libdaemon/Makefile.in
@@ -17,8 +17,10 @@ top_builddir = @top_builddir@
 
 .PHONY: client server
 
+SUBDIRS += client
+
 ifeq ("@BUILD_LVMETAD@", "yes")
-  SUBDIRS += client server
+  SUBDIRS += server
 server: client
 endif
 
diff --git a/make.tmpl.in b/make.tmpl.in
index b8b127f..21fd415 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -144,11 +144,9 @@ endif
 LDFLAGS += -L$(top_builddir)/libdm -L$(top_builddir)/lib
 CLDFLAGS += -L$(top_builddir)/libdm -L$(top_builddir)/lib
 
-ifeq ("@BUILD_LVMETAD@", "yes")
-  DAEMON_LIBS = -ldaemonclient
-  LDFLAGS += -L$(top_builddir)/libdaemon/client
-  CLDFLAGS += -L$(top_builddir)/libdaemon/client
-endif
+DAEMON_LIBS = -ldaemonclient
+LDFLAGS += -L$(top_builddir)/libdaemon/client
+CLDFLAGS += -L$(top_builddir)/libdaemon/client
 
 ifeq ("@DMEVENTD@", "yes")
   LDFLAGS += -L$(top_builddir)/daemons/dmeventd


