From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Dec 2018 05:43:11 -0500
Subject: master - makefile: fixes build for older system
Message-ID: <201812171043.wBHAhBEW031286@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5db56b36f168bddc4364fbffab1fcee07eb1d664
Commit:        5db56b36f168bddc4364fbffab1fcee07eb1d664
Parent:        94237354ddbf2abc0f04e7f06ee3c1263dfc6b6e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 17 11:41:38 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 17 11:41:38 2018 +0100

makefile: fixes build for older system

With older gcc - we need to resolve symbols linked with devmapper-event
that is now using -ldevmapper.

Also add forgotten systemd library needed for dbus notification.
---
 tools/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/Makefile.in b/tools/Makefile.in
index b45798e..2620daa 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -89,7 +89,7 @@ ifeq ("@STATIC_LINK@", "yes")
   INSTALL_CMDLIB_TARGETS += install_cmdlib_static
 endif
 
-LVMLIBS = $(LIBS) -laio
+LVMLIBS = $(SYSTEMD_LIBS) -L$(top_builddir)/libdm -ldevmapper $(LIBS) -laio
 LIB_VERSION = $(LIB_VERSION_LVM)
 INCLUDES = -I$(top_builddir)/tools
 


