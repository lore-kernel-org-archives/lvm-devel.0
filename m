From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  7 May 2010 16:14:51 +0200
Subject: [PATCH 4/9] Plugins do not use pthread or lvm2cmd directly
In-Reply-To: <cover.1273241256.git.zkabelac@redhat.com>
References: <cover.1273241256.git.zkabelac@redhat.com>
Message-ID: <2cbe6ea0335a50025be3ee2373ce07772007a5b9.1273241256.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Plugins are using pthread and lvm2cmd library indirectly
via devmapper-event-lvm2.

Thus skip the linkage of these libs to created .so plugins.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/dmeventd/plugins/mirror/Makefile.in   |    2 +-
 daemons/dmeventd/plugins/snapshot/Makefile.in |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/plugins/mirror/Makefile.in b/daemons/dmeventd/plugins/mirror/Makefile.in
index 5966f24..3c3d468 100644
--- a/daemons/dmeventd/plugins/mirror/Makefile.in
+++ b/daemons/dmeventd/plugins/mirror/Makefile.in
@@ -30,7 +30,7 @@ CFLOW_LIST_TARGET = $(LIB_NAME).cflow
 
 include $(top_builddir)/make.tmpl
 
-LIBS += @LVM2CMD_LIB@ -ldevmapper-event-lvm2 -ldevmapper $(PTHREAD_LIBS)
+LIBS += -ldevmapper-event-lvm2 -ldevmapper
 
 install_lvm2: install_dm_plugin
 
diff --git a/daemons/dmeventd/plugins/snapshot/Makefile.in b/daemons/dmeventd/plugins/snapshot/Makefile.in
index 32a74af..87a55e7 100644
--- a/daemons/dmeventd/plugins/snapshot/Makefile.in
+++ b/daemons/dmeventd/plugins/snapshot/Makefile.in
@@ -26,7 +26,7 @@ LIB_VERSION = $(LIB_VERSION_LVM)
 
 include $(top_builddir)/make.tmpl
 
-LIBS += @LVM2CMD_LIB@ -ldevmapper-event-lvm2 -ldevmapper $(PTHREAD_LIBS)
+LIBS += -ldevmapper-event-lvm2 -ldevmapper
 
 install_lvm2: install_dm_plugin
 
-- 
1.7.0.1


