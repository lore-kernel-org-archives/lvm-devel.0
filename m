From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Dec 2018 05:08:06 -0500
Subject: master - dmeventd: do not link internal libraries to plugins
Message-ID: <201812171008.wBHA869h024746@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8bf445b2deed25f101e2861656ee19151ea7e335
Commit:        8bf445b2deed25f101e2861656ee19151ea7e335
Parent:        035a7b9a4bf77798d9d7ecdb7cfa8dfd77a92729
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 16:58:56 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 17 10:36:52 2018 +0100

dmeventd: do not link internal libraries to plugins

Avoid linking internal device-mapper and link dynamically libdevmapper.
This considerably reduced size of installed binaries.
---
 daemons/dmeventd/plugins/lvm2/Makefile.in     |    3 +--
 daemons/dmeventd/plugins/mirror/Makefile.in   |    3 +--
 daemons/dmeventd/plugins/raid/Makefile.in     |    3 +--
 daemons/dmeventd/plugins/snapshot/Makefile.in |    3 +--
 daemons/dmeventd/plugins/thin/Makefile.in     |    3 +--
 daemons/dmeventd/plugins/vdo/Makefile.in      |    3 +--
 6 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/daemons/dmeventd/plugins/lvm2/Makefile.in b/daemons/dmeventd/plugins/lvm2/Makefile.in
index e4eedc6..858de9d 100644
--- a/daemons/dmeventd/plugins/lvm2/Makefile.in
+++ b/daemons/dmeventd/plugins/lvm2/Makefile.in
@@ -16,6 +16,7 @@ top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
 CLDFLAGS += -L$(top_builddir)/tools
+LIBS += $(DMEVENT_LIBS) $(PTHREAD_LIBS) @LVM2CMD_LIB@
 
 SOURCES = dmeventd_lvm.c
 
@@ -24,8 +25,6 @@ LIB_VERSION = $(LIB_VERSION_LVM)
 
 include $(top_builddir)/make.tmpl
 
-LIBS += @LVM2CMD_LIB@ $(INTERNAL_LIBS) $(PTHREAD_LIBS)
-
 install_lvm2: install_lib_shared
 
 install: install_lvm2
diff --git a/daemons/dmeventd/plugins/mirror/Makefile.in b/daemons/dmeventd/plugins/mirror/Makefile.in
index 2c0d5d7..62d94c9 100644
--- a/daemons/dmeventd/plugins/mirror/Makefile.in
+++ b/daemons/dmeventd/plugins/mirror/Makefile.in
@@ -17,6 +17,7 @@ top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
 CLDFLAGS += -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
+LIBS += -ldevmapper-event-lvm2
 
 SOURCES = dmeventd_mirror.c
 
@@ -29,8 +30,6 @@ CFLOW_LIST_TARGET = $(LIB_NAME).cflow
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper-event-lvm2 $(INTERNAL_LIBS)
-
 install_lvm2: install_dm_plugin
 
 install: install_lvm2
diff --git a/daemons/dmeventd/plugins/raid/Makefile.in b/daemons/dmeventd/plugins/raid/Makefile.in
index c00e624..abc935d 100644
--- a/daemons/dmeventd/plugins/raid/Makefile.in
+++ b/daemons/dmeventd/plugins/raid/Makefile.in
@@ -16,6 +16,7 @@ top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
 CLDFLAGS += -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
+LIBS += -ldevmapper-event-lvm2
 
 SOURCES = dmeventd_raid.c
 
@@ -28,8 +29,6 @@ CFLOW_LIST_TARGET = $(LIB_NAME).cflow
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper-event-lvm2 $(INTERNAL_LIBS)
-
 install_lvm2: install_dm_plugin
 
 install: install_lvm2
diff --git a/daemons/dmeventd/plugins/snapshot/Makefile.in b/daemons/dmeventd/plugins/snapshot/Makefile.in
index adbb3e2..c5f71b8 100644
--- a/daemons/dmeventd/plugins/snapshot/Makefile.in
+++ b/daemons/dmeventd/plugins/snapshot/Makefile.in
@@ -17,6 +17,7 @@ top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
 CLDFLAGS += -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
+LIBS += -ldevmapper-event-lvm2
 
 SOURCES = dmeventd_snapshot.c
 
@@ -25,8 +26,6 @@ LIB_VERSION = $(LIB_VERSION_LVM)
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper-event-lvm2 $(INTERNAL_LIBS)
-
 install_lvm2: install_dm_plugin
 
 install: install_lvm2
diff --git a/daemons/dmeventd/plugins/thin/Makefile.in b/daemons/dmeventd/plugins/thin/Makefile.in
index 7968504..c1cbee7 100644
--- a/daemons/dmeventd/plugins/thin/Makefile.in
+++ b/daemons/dmeventd/plugins/thin/Makefile.in
@@ -16,6 +16,7 @@ top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
 CLDFLAGS += -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
+LIBS += -ldevmapper-event-lvm2
 
 SOURCES = dmeventd_thin.c
 
@@ -28,8 +29,6 @@ CFLOW_LIST_TARGET = $(LIB_NAME).cflow
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper-event-lvm2 $(INTERNAL_LIBS)
-
 install_lvm2: install_dm_plugin
 
 install: install_lvm2
diff --git a/daemons/dmeventd/plugins/vdo/Makefile.in b/daemons/dmeventd/plugins/vdo/Makefile.in
index 8e90e27..84adb74 100644
--- a/daemons/dmeventd/plugins/vdo/Makefile.in
+++ b/daemons/dmeventd/plugins/vdo/Makefile.in
@@ -16,6 +16,7 @@ top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
 CLDFLAGS += -L$(top_builddir)/daemons/dmeventd/plugins/lvm2
+LIBS += -ldevmapper-event-lvm2
 
 SOURCES = dmeventd_vdo.c
 
@@ -28,8 +29,6 @@ CFLOW_LIST_TARGET = $(LIB_NAME).cflow
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper-event-lvm2 $(INTERNAL_LIBS)
-
 install_lvm2: install_dm_plugin
 
 install: install_lvm2


