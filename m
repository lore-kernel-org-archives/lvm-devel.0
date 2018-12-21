From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 21 Dec 2018 15:46:25 -0500
Subject: master - lvmlockd: use commonly used define NOTIFYDBUS_SUPPORT
Message-ID: <201812212046.wBLKkPLM021331@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=71af650760c2b75b3c267277f47d8ba235421300
Commit:        71af650760c2b75b3c267277f47d8ba235421300
Parent:        7832d3566868408ebf6d4c5d708e3efab3d48a67
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 21 11:17:43 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 21 21:42:30 2018 +0100

lvmlockd: use commonly used define NOTIFYDBUS_SUPPORT

Build with configured NOTIFYDBUS_SUPPORT, SYSTEMD_LIBS, SYSTEMD_CFLAGS.
Also add proper build dependencies on internal libraries.
---
 daemons/lvmlockd/Makefile.in     |   21 +++++++--------------
 daemons/lvmlockd/lvmlockd-core.c |    2 +-
 2 files changed, 8 insertions(+), 15 deletions(-)

diff --git a/daemons/lvmlockd/Makefile.in b/daemons/lvmlockd/Makefile.in
index 17fcb40..3ca4167 100644
--- a/daemons/lvmlockd/Makefile.in
+++ b/daemons/lvmlockd/Makefile.in
@@ -37,25 +37,18 @@ TARGETS = lvmlockd lvmlockctl
 
 include $(top_builddir)/make.tmpl
 
-CFLAGS += $(EXTRA_EXEC_CFLAGS)
+CFLAGS += $(EXTRA_EXEC_CFLAGS) $(SYSTEMD_CFLAGS)
 INCLUDES += -I$(top_srcdir)/libdaemon/server
-LDFLAGS += -L$(top_builddir)/libdaemon/server $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS)
-LIBS += $(RT_LIBS) $(DAEMON_LIBS) $(PTHREAD_LIBS)
+LDFLAGS += $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS)
+LIBS += $(PTHREAD_LIBS) $(SYSTEMD_LIBS)
 
-
-ifeq ($(USE_SD_NOTIFY),yes)
-	CFLAGS += $(shell pkg-config --cflags libsystemd) -DUSE_SD_NOTIFY
-	LIBS += $(shell pkg-config --libs libsystemd)
-endif
-
-lvmlockd: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
-		    $(top_builddir)/libdaemon/server/libdaemonserver.a
+lvmlockd: $(OBJECTS) $(top_builddir)/libdaemon/server/libdaemonserver.a $(INTERNAL_LIBS)
 	@echo "    [CC] $@"
-	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(LOCK_LIBS) -ldaemonserver $(INTERNAL_LIBS) $(LIBS)
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $+ $(LOCK_LIBS) $(LIBS)
 
-lvmlockctl: lvmlockctl.o $(top_builddir)/libdaemon/client/libdaemonclient.a
+lvmlockctl: lvmlockctl.o $(INTERNAL_LIBS)
 	@echo "    [CC] $@"
-	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -o $@ lvmlockctl.o $(INTERNAL_LIBS) $(LIBS)
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $+ $(LIBS)
 
 install_lvmlockd: lvmlockd
 	@echo "    [INSTALL] $<"
diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index dd52270..1c58d4d 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -34,7 +34,7 @@
 #include <sys/utsname.h>
 #include <sys/un.h>
 
-#ifdef USE_SD_NOTIFY
+#ifdef NOTIFYDBUS_SUPPORT
 #include <systemd/sd-daemon.h>
 #endif
 


