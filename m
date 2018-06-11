From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 11 Jun 2018 16:27:55 -0400
Subject: master - build: link dmeventd plugins with internal libs
Message-ID: <201806112027.w5BKRtti029995@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9c7ee1e1c4e436060d3b1970c73084d41012f108
Commit:        9c7ee1e1c4e436060d3b1970c73084d41012f108
Parent:        5c2f7f083cc518b11e657b294f42e38a688404e1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 11 21:09:45 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 11 22:25:42 2018 +0200

build: link dmeventd plugins with internal libs

---
 daemons/dmeventd/plugins/lvm2/Makefile.in     |    2 +-
 daemons/dmeventd/plugins/mirror/Makefile.in   |    2 +-
 daemons/dmeventd/plugins/raid/Makefile.in     |    2 +-
 daemons/dmeventd/plugins/snapshot/Makefile.in |    2 +-
 daemons/dmeventd/plugins/thin/Makefile.in     |    2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/daemons/dmeventd/plugins/lvm2/Makefile.in b/daemons/dmeventd/plugins/lvm2/Makefile.in
index 7e4696c..e4eedc6 100644
--- a/daemons/dmeventd/plugins/lvm2/Makefile.in
+++ b/daemons/dmeventd/plugins/lvm2/Makefile.in
@@ -24,7 +24,7 @@ LIB_VERSION = $(LIB_VERSION_LVM)
 
 include $(top_builddir)/make.tmpl
 
-LIBS += @LVM2CMD_LIB@ $(PTHREAD_LIBS)
+LIBS += @LVM2CMD_LIB@ $(INTERNAL_LIBS) $(PTHREAD_LIBS)
 
 install_lvm2: install_lib_shared
 
diff --git a/daemons/dmeventd/plugins/mirror/Makefile.in b/daemons/dmeventd/plugins/mirror/Makefile.in
index 22832dd..a28b9e5 100644
--- a/daemons/dmeventd/plugins/mirror/Makefile.in
+++ b/daemons/dmeventd/plugins/mirror/Makefile.in
@@ -30,7 +30,7 @@ CFLOW_LIST_TARGET = $(LIB_NAME).cflow
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper-event-lvm2
+LIBS += -ldevmapper-event-lvm2 $(INTERNAL_LIBS)
 
 install_lvm2: install_dm_plugin
 
diff --git a/daemons/dmeventd/plugins/raid/Makefile.in b/daemons/dmeventd/plugins/raid/Makefile.in
index 54343b1..d38ca15 100644
--- a/daemons/dmeventd/plugins/raid/Makefile.in
+++ b/daemons/dmeventd/plugins/raid/Makefile.in
@@ -29,7 +29,7 @@ CFLOW_LIST_TARGET = $(LIB_NAME).cflow
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper-event-lvm2
+LIBS += -ldevmapper-event-lvm2 $(INTERNAL_LIBS)
 
 install_lvm2: install_dm_plugin
 
diff --git a/daemons/dmeventd/plugins/snapshot/Makefile.in b/daemons/dmeventd/plugins/snapshot/Makefile.in
index 75f4342..ab46b43 100644
--- a/daemons/dmeventd/plugins/snapshot/Makefile.in
+++ b/daemons/dmeventd/plugins/snapshot/Makefile.in
@@ -26,7 +26,7 @@ LIB_VERSION = $(LIB_VERSION_LVM)
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper-event-lvm2
+LIBS += -ldevmapper-event-lvm2 $(INTERNAL_LIBS)
 
 install_lvm2: install_dm_plugin
 
diff --git a/daemons/dmeventd/plugins/thin/Makefile.in b/daemons/dmeventd/plugins/thin/Makefile.in
index 9f1c2b3..b1e3e1b 100644
--- a/daemons/dmeventd/plugins/thin/Makefile.in
+++ b/daemons/dmeventd/plugins/thin/Makefile.in
@@ -29,7 +29,7 @@ CFLOW_LIST_TARGET = $(LIB_NAME).cflow
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper-event-lvm2
+LIBS += -ldevmapper-event-lvm2 $(INTERNAL_LIBS)
 
 install_lvm2: install_dm_plugin
 


