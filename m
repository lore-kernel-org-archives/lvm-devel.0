From: David Teigland <teigland@sourceware.org>
Date: Thu, 13 Sep 2018 10:55:15 -0400
Subject: master - lvmlockd: improve systemd service file
Message-ID: <201809131455.w8DEtFMt015519@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=297f6d51228d0f0d5debca9e95785f3623e0ef9d
Commit:        297f6d51228d0f0d5debca9e95785f3623e0ef9d
Parent:        1365f0d4c8f977cd3e426708891ee8d39ffe6527
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 13 09:52:39 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 13 09:52:39 2018 -0500

lvmlockd: improve systemd service file

use notify type so the daemon is ready
immediately after start.
---
 daemons/lvmlockd/Makefile.in                     |    8 ++++++++
 daemons/lvmlockd/lvmlockd-core.c                 |    8 ++++++++
 scripts/lvm2_lvmlockd_systemd_red_hat.service.in |    9 +++------
 3 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/daemons/lvmlockd/Makefile.in b/daemons/lvmlockd/Makefile.in
index 6dcc207..01abaca 100644
--- a/daemons/lvmlockd/Makefile.in
+++ b/daemons/lvmlockd/Makefile.in
@@ -15,6 +15,8 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
+USE_SD_NOTIFY=yes
+
 SOURCES = lvmlockd-core.c
 
 ifeq ("@BUILD_LOCKDSANLOCK@", "yes")
@@ -40,6 +42,12 @@ INCLUDES += -I$(top_srcdir)/libdaemon/server
 LDFLAGS += -L$(top_builddir)/libdaemon/server $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS)
 LIBS += $(RT_LIBS) $(DAEMON_LIBS) $(PTHREAD_LIBS)
 
+
+ifeq ($(USE_SD_NOTIFY),yes)
+	CFLAGS += $(shell pkg-config --cflags libsystemd) -DUSE_SD_NOTIFY
+	LDFLAGS += $(shell pkg-config --libs libsystemd)
+endif
+
 lvmlockd: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
 		    $(top_builddir)/libdaemon/server/libdaemonserver.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(LOCK_LIBS) -ldaemonserver $(INTERNAL_LIBS) $(LIBS)
diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index d6ff8cc..6490b40 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -35,6 +35,10 @@
 #include <sys/utsname.h>
 #include <sys/un.h>
 
+#ifdef USE_SD_NOTIFY
+#include <systemd/sd-daemon.h>
+#endif
+
 #define EXTERN
 #include "lvmlockd-internal.h"
 
@@ -5786,6 +5790,10 @@ static int main_loop(daemon_state *ds_arg)
 	setup_worker_thread();
 	setup_restart();
 
+#ifdef USE_SD_NOTIFY
+	sd_notify(0, "READY=1");
+#endif
+
 	/*
 	 * Attempt to rejoin lockspaces and adopt locks from a previous
 	 * instance of lvmlockd that left behind lockspaces/locks.
diff --git a/scripts/lvm2_lvmlockd_systemd_red_hat.service.in b/scripts/lvm2_lvmlockd_systemd_red_hat.service.in
index 2a7544a..efe489a 100644
--- a/scripts/lvm2_lvmlockd_systemd_red_hat.service.in
+++ b/scripts/lvm2_lvmlockd_systemd_red_hat.service.in
@@ -1,13 +1,10 @@
 [Unit]
-Description=LVM2 lock daemon
+Description=LVM lock daemon
 Documentation=man:lvmlockd(8)
-After=lvm2-lvmetad.service
 
 [Service]
-Type=simple
-NonBlocking=true
-ExecStart=@SBINDIR@/lvmlockd -f
-Environment=SD_ACTIVATION=1
+Type=notify
+ExecStart=@SBINDIR@/lvmlockd --foreground
 PIDFile=@LVMLOCKD_PIDFILE@
 SendSIGKILL=no
 


