From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:55:10 +0000 (UTC)
Subject: master - makefiles: drop linking of deamon libs to plugins
Message-ID: <20140418145510.AB85460758@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=07274f3dd4bd0aafb5dbf501906534c0668b1802
Commit:        07274f3dd4bd0aafb5dbf501906534c0668b1802
Parent:        2b748e3118988222560392fa795e093cd2ce0af4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 17 14:12:02 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:38:49 2014 +0200

makefiles: drop linking of deamon libs to plugins

Daemon lib is linked into lvm2cmd library.
---
 daemons/dmeventd/plugins/lvm2/Makefile.in     |    4 ++--
 daemons/dmeventd/plugins/mirror/Makefile.in   |    8 ++++----
 daemons/dmeventd/plugins/raid/Makefile.in     |    6 +++---
 daemons/dmeventd/plugins/snapshot/Makefile.in |    8 ++++----
 daemons/dmeventd/plugins/thin/Makefile.in     |    6 +++---
 5 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/daemons/dmeventd/plugins/lvm2/Makefile.in b/daemons/dmeventd/plugins/lvm2/Makefile.in
index fcb2a0a..a7b9a2e 100644
--- a/daemons/dmeventd/plugins/lvm2/Makefile.in
+++ b/daemons/dmeventd/plugins/lvm2/Makefile.in
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2010-2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2010-2014 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -24,7 +24,7 @@ LIB_VERSION = $(LIB_VERSION_LVM)
 
 include $(top_builddir)/make.tmpl
 
-LIBS += @LVM2CMD_LIB@ -ldevmapper $(PTHREAD_LIBS) $(DAEMON_LIBS)
+LIBS += @LVM2CMD_LIB@ -ldevmapper $(PTHREAD_LIBS)
 
 install_lvm2: install_lib_shared
 
diff --git a/daemons/dmeventd/plugins/mirror/Makefile.in b/daemons/dmeventd/plugins/mirror/Makefile.in
index 85b33c9..4a2870a 100644
--- a/daemons/dmeventd/plugins/mirror/Makefile.in
+++ b/daemons/dmeventd/plugins/mirror/Makefile.in
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2005, 2008-2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2005, 2008-2014 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -16,8 +16,8 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-INCLUDES += -I$(top_srcdir)/tools -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
-CLDFLAGS += -L$(top_builddir)/tools -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
+INCLUDES += -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
+CLDFLAGS += -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
 
 SOURCES = dmeventd_mirror.c
 
@@ -30,7 +30,7 @@ CFLOW_LIST_TARGET = $(LIB_NAME).cflow
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper-event-lvm2 -ldevmapper $(DAEMON_LIBS)
+LIBS += -ldevmapper-event-lvm2 -ldevmapper
 
 install_lvm2: install_dm_plugin
 
diff --git a/daemons/dmeventd/plugins/raid/Makefile.in b/daemons/dmeventd/plugins/raid/Makefile.in
index a6b7788..47582ae 100644
--- a/daemons/dmeventd/plugins/raid/Makefile.in
+++ b/daemons/dmeventd/plugins/raid/Makefile.in
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2011-2014 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -15,8 +15,8 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-INCLUDES += -I$(top_srcdir)/tools -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
-CLDFLAGS += -L$(top_builddir)/tools -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
+INCLUDES += -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
+CLDFLAGS += -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
 
 SOURCES = dmeventd_raid.c
 
diff --git a/daemons/dmeventd/plugins/snapshot/Makefile.in b/daemons/dmeventd/plugins/snapshot/Makefile.in
index a4cff15..b766f16 100644
--- a/daemons/dmeventd/plugins/snapshot/Makefile.in
+++ b/daemons/dmeventd/plugins/snapshot/Makefile.in
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
 #
 # This file is part of the LVM2.
 #
@@ -16,8 +16,8 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-INCLUDES += -I$(top_srcdir)/tools -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
-CLDFLAGS += -L$(top_builddir)/tools -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
+INCLUDES += -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
+CLDFLAGS += -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
 
 SOURCES = dmeventd_snapshot.c
 
@@ -26,7 +26,7 @@ LIB_VERSION = $(LIB_VERSION_LVM)
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper-event-lvm2 -ldevmapper $(DAEMON_LIBS)
+LIBS += -ldevmapper-event-lvm2 -ldevmapper
 
 install_lvm2: install_dm_plugin
 
diff --git a/daemons/dmeventd/plugins/thin/Makefile.in b/daemons/dmeventd/plugins/thin/Makefile.in
index e964ab5..cfd473a 100644
--- a/daemons/dmeventd/plugins/thin/Makefile.in
+++ b/daemons/dmeventd/plugins/thin/Makefile.in
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2011-2014 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -15,8 +15,8 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-INCLUDES += -I$(top_srcdir)/tools -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
-CLDFLAGS += -L$(top_builddir)/tools -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
+INCLUDES += -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2
+CLDFLAGS += -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
 
 SOURCES = dmeventd_thin.c
 


