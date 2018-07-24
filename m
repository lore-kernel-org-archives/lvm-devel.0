From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 24 Jul 2018 09:41:55 -0400
Subject: master - build: Remove lvmetad leftovers
Message-ID: <201807241341.w6ODftO6002289@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=97506a7e2ac4cd4e9a6fd77e4a49a45fd565c3e5
Commit:        97506a7e2ac4cd4e9a6fd77e4a49a45fd565c3e5
Parent:        7709b70f976a13b3428679679cded47d2d642f30
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Jul 24 15:02:32 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Jul 24 15:02:32 2018 +0200

build: Remove lvmetad leftovers

---
 daemons/Makefile.in |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/daemons/Makefile.in b/daemons/Makefile.in
index 5226a5e..e548b15 100644
--- a/daemons/Makefile.in
+++ b/daemons/Makefile.in
@@ -15,7 +15,7 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-.PHONY: dmeventd cmirrord lvmetad lvmpolld lvmlockd
+.PHONY: dmeventd cmirrord lvmpolld lvmlockd
 
 ifeq ("@BUILD_CMIRRORD@", "yes")
   SUBDIRS += cmirrord
@@ -28,10 +28,6 @@ daemons.cflow: dmeventd.cflow
 endif
 endif
 
-ifeq ("@BUILD_LVMETAD@", "yes")
-  SUBDIRS += lvmetad
-endif
-
 ifeq ("@BUILD_LVMPOLLD@", "yes")
   SUBDIRS += lvmpolld
 endif
@@ -45,7 +41,7 @@ ifeq ("@BUILD_LVMDBUSD@", "yes")
 endif
 
 ifeq ($(MAKECMDGOALS),distclean)
-  SUBDIRS = cmirrord dmeventd lvmetad lvmpolld lvmlockd lvmdbusd
+  SUBDIRS = cmirrord dmeventd lvmpolld lvmlockd lvmdbusd
 endif
 
 include $(top_builddir)/make.tmpl


