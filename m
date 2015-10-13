From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 23:03:24 +0000 (UTC)
Subject: master - makefiles: switch to rpath-link
Message-ID: <20151013230324.3BDA560763@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bbef4edd06097a71601b1470a713ded17deb7cba
Commit:        bbef4edd06097a71601b1470a713ded17deb7cba
Parent:        3f1a3b7090d421d46f245454bc5c8ed299a9cc1d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 14 00:51:55 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 14 00:51:55 2015 +0200

makefiles: switch to rpath-link

Plain rpath is to invasive and gets into binary.
We only want to provide hint for linker.
---
 scripts/Makefile.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index bfa0fad..af2b299 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2006-2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2006-2015 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -26,7 +26,7 @@ ifeq ("@APPLIB@", "yes")
 	DEPLIBS += $(top_builddir)/liblvm/liblvm2app.so $(top_builddir)/libdm/libdevmapper.so
 	LDFLAGS += -L$(top_builddir)/liblvm
 ifeq ("@DMEVENTD@", "yes")
-	LDFLAGS += -Wl,-rpath,$(top_builddir)/daemons/dmeventd
+	LDFLAGS += -Wl,-rpath-link,$(top_builddir)/daemons/dmeventd
 endif
 	LVMLIBS = @LVM2APP_LIB@ -ldevmapper
 endif


