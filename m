From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:55:12 +0000 (UTC)
Subject: master - makefiles: move subdir into same section
Message-ID: <20140418145512.CB10E60758@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e552824dc046b90f201de8041730f2dbf6969aa0
Commit:        e552824dc046b90f201de8041730f2dbf6969aa0
Parent:        07274f3dd4bd0aafb5dbf501906534c0668b1802
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 16 11:57:42 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:38:49 2014 +0200

makefiles: move subdir into same section

Just shift few lines
---
 daemons/Makefile.in |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/daemons/Makefile.in b/daemons/Makefile.in
index c83e0da..9a73516 100644
--- a/daemons/Makefile.in
+++ b/daemons/Makefile.in
@@ -15,10 +15,6 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-ifeq ("@BUILD_LVMETAD@", "yes")
-  SUBDIRS += lvmetad
-endif
-
 .PHONY: dmeventd clvmd cmirrord lvmetad
 
 ifneq ("@CLVMD@", "none")
@@ -36,6 +32,10 @@ daemons.cflow: dmeventd.cflow
 endif
 endif
 
+ifeq ("@BUILD_LVMETAD@", "yes")
+  SUBDIRS += lvmetad
+endif
+
 ifeq ($(MAKECMDGOALS),distclean)
   SUBDIRS = clvmd cmirrord dmeventd lvmetad
 endif


