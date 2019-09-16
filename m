From: David Teigland <teigland@sourceware.org>
Date: Mon, 16 Sep 2019 12:46:16 -0400
Subject: master - Revert "lvmlockd: use commonly used define NOTIFYDBUS_SUPPORT"
Message-ID: <201909161646.x8GGkGRR009577@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6e1cf248d4a9520b6e342dc583f1e4f7d4c5f8fa
Commit:        6e1cf248d4a9520b6e342dc583f1e4f7d4c5f8fa
Parent:        51c105702f24d64f1adc25a692ef37e20878cec5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Sep 16 11:42:23 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 16 11:44:42 2019 -0500

Revert "lvmlockd: use commonly used define NOTIFYDBUS_SUPPORT"

This reverts commit 71af650760c2b75b3c267277f47d8ba235421300.

It disabled sd_notify() which broke 'systemctl start lvmlockd'.
---
 daemons/lvmlockd/Makefile.in     |   21 ++++++++++++++-------
 daemons/lvmlockd/lvmlockd-core.c |    2 +-
 2 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/daemons/lvmlockd/Makefile.in b/daemons/lvmlockd/Makefile.in
index dca05b8..9c03401 100644
--- a/daemons/lvmlockd/Makefile.in
+++ b/daemons/lvmlockd/Makefile.in
@@ -38,18 +38,25 @@ TARGETS = lvmlockd lvmlockctl
 
 include $(top_builddir)/make.tmpl
 
-CFLAGS += $(EXTRA_EXEC_CFLAGS) $(SYSTEMD_CFLAGS)
+CFLAGS += $(EXTRA_EXEC_CFLAGS)
 INCLUDES += -I$(top_srcdir)/libdaemon/server
-LDFLAGS += $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS)
-LIBS += $(PTHREAD_LIBS) $(SYSTEMD_LIBS)
+LDFLAGS += -L$(top_builddir)/libdaemon/server $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS)
+LIBS += $(RT_LIBS) $(DAEMON_LIBS) $(PTHREAD_LIBS)
 
-lvmlockd: $(OBJECTS) $(top_builddir)/libdaemon/server/libdaemonserver.a $(INTERNAL_LIBS)
+
+ifeq ($(USE_SD_NOTIFY),yes)
+	CFLAGS += $(shell pkg-config --cflags libsystemd) -DUSE_SD_NOTIFY
+	LIBS += $(shell pkg-config --libs libsystemd)
+endif
+
+lvmlockd: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
+		    $(top_builddir)/libdaemon/server/libdaemonserver.a
 	@echo "    [CC] $@"
-	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $+ $(LOCK_LIBS) $(LIBS)
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(LOCK_LIBS) -ldaemonserver $(INTERNAL_LIBS) $(LIBS)
 
-lvmlockctl: lvmlockctl.o $(INTERNAL_LIBS)
+lvmlockctl: lvmlockctl.o $(top_builddir)/libdaemon/client/libdaemonclient.a
 	@echo "    [CC] $@"
-	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $+ $(LIBS)
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -o $@ lvmlockctl.o $(INTERNAL_LIBS) $(LIBS)
 
 install_lvmlockd: lvmlockd
 	@echo "    [INSTALL] $<"
diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 5609ccc..39275fb 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -31,7 +31,7 @@
 #include <sys/utsname.h>
 #include <sys/un.h>
 
-#ifdef NOTIFYDBUS_SUPPORT
+#ifdef USE_SD_NOTIFY
 #include <systemd/sd-daemon.h>
 #endif
 


