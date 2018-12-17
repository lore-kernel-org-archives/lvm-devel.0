From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Dec 2018 05:08:11 -0500
Subject: master - cmirror: link with libdm
Message-ID: <201812171008.wBHA8BWh024766@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a8cdd9e16a04ca837401cbcaa4677b2af50007b7
Commit:        a8cdd9e16a04ca837401cbcaa4677b2af50007b7
Parent:        701ecff0ff2c1a3d194a6d94b16b9ce6f0a2ba22
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 22:17:08 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 17 10:36:52 2018 +0100

cmirror: link with libdm

Since there is very little change there will be any new devel going
to happing with cmirror - avoid eating extra disk space and link
with already installed libdm which implements all use basic
function of dm list
---
 daemons/cmirrord/Makefile.in |    4 ++--
 daemons/cmirrord/cluster.h   |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/daemons/cmirrord/Makefile.in b/daemons/cmirrord/Makefile.in
index 0bcd73c..ff45225 100644
--- a/daemons/cmirrord/Makefile.in
+++ b/daemons/cmirrord/Makefile.in
@@ -28,10 +28,10 @@ LMLIBS += $(CPG_LIBS)
 CFLAGS += $(CPG_CFLAGS) $(EXTRA_EXEC_CFLAGS)
 LDFLAGS += $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS)
 
-cmirrord: $(OBJECTS) $(top_builddir)/lib/liblvm-internal.a
+cmirrord: $(OBJECTS)
 	@echo "    [CC] $@"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) \
-		$(LVMLIBS) $(LMLIBS) $(INTERNAL_LIBS) $(LIBS)
+		$(LMLIBS) -L$(top_builddir)/libdm -ldevmapper $(LIBS)
 
 install: $(TARGETS)
 	@echo "    [INSTALL] $<"
diff --git a/daemons/cmirrord/cluster.h b/daemons/cmirrord/cluster.h
index 01d4871..0efbd64 100644
--- a/daemons/cmirrord/cluster.h
+++ b/daemons/cmirrord/cluster.h
@@ -12,8 +12,8 @@
 #ifndef _LVM_CLOG_CLUSTER_H
 #define _LVM_CLOG_CLUSTER_H
 
-#include "device_mapper/misc/dm-log-userspace.h"
-#include "device_mapper/all.h"
+#include "libdm/misc/dm-log-userspace.h"
+#include "libdm/libdevmapper.h"
 
 #define DM_ULOG_RESPONSE 0x1000U /* in last byte of 32-bit value */
 #define DM_ULOG_CHECKPOINT_READY 21


