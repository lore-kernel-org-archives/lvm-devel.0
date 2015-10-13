From: Ferenc Wágner <wferi@niif.hu>
Date: Tue, 13 Oct 2015 18:39:13 +0200
Subject: [PATCH] clvmd: send readiness notification to systemd
Message-ID: <201510131748.t9DHm4Un004608@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If libsystemd is available during configuration, report readiness to systemd
right before entering the main loop.  This avoids the double timeout handling
and the need for a PID file in the service definition, while enabling precise
startup ordering.

Signed-off-by: Ferenc W?gner <wferi@niif.hu>
---
 configure.in                                  |    5 +++++
 daemons/clvmd/Makefile.in                     |    6 ++++--
 daemons/clvmd/clvmd.c                         |    8 ++++++++
 scripts/lvm2_clvmd_systemd_red_hat.service.in |    7 ++-----
 4 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/configure.in b/configure.in
index c240b4b..40e86f7 100644
--- a/configure.in
+++ b/configure.in
@@ -1372,6 +1372,11 @@ if test "$UDEV_RULE" != no ; then
 fi
 
 ################################################################################
+dnl -- libsystemd
+PKG_CHECK_MODULES([LIBSYSTEMD], [libsystemd],
+    [AC_DEFINE([HAVE_LIBSYSTEMD], [1], [have systemd interface library])], [:])
+
+################################################################################
 dnl -- Compatibility mode
 AC_ARG_ENABLE(compat,
 	      AC_HELP_STRING([--enable-compat],
diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index 38ff1c7..5946862 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -29,6 +29,8 @@ QUORUM_LIBS = @QUORUM_LIBS@
 QUORUM_CFLAGS = @QUORUM_CFLAGS@
 SALCK_LIBS = @SALCK_LIBS@
 SALCK_CFLAGS = @SALCK_CFLAGS@
+LIBSYSTEMD_CFLAGS = @LIBSYSTEMD_CFLAGS@
+LIBSYSTEMD_LIBS = @LIBSYSTEMD_LIBS@
 
 SOURCES = \
 	clvmd-command.c  \
@@ -81,9 +83,9 @@ endif
 include $(top_builddir)/make.tmpl
 
 LVMLIBS += -ldevmapper
-LIBS += $(PTHREAD_LIBS)
+LIBS += $(PTHREAD_LIBS) $(LIBSYSTEMD_LIBS)
 
-CFLAGS += -fno-strict-aliasing $(EXTRA_EXEC_CFLAGS)
+CFLAGS += -fno-strict-aliasing $(EXTRA_EXEC_CFLAGS) $(LIBSYSTEMD_CFLAGS)
 LDFLAGS += $(EXTRA_EXEC_LDFLAGS)
 
 INSTALL_TARGETS = \
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 53daa8c..3a41e62 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -43,6 +43,10 @@
 #include <sys/un.h>
 #include <sys/utsname.h>
 
+#ifdef HAVE_LIBSYSTEMD
+#include <systemd/sd-daemon.h>
+#endif
+
 #ifndef TRUE
 #define TRUE 1
 #endif
@@ -620,6 +624,10 @@ int main(int argc, char *argv[])
 	signal(SIGTERM, sigterm_handler);
 	signal(SIGINT, sigterm_handler);
 
+#ifdef HAVE_LIBSYSTEMD
+	sd_notify (0, "READY=1");
+#endif
+
 	/* Do some work */
 	main_loop(cmd_timeout);
 
diff --git a/scripts/lvm2_clvmd_systemd_red_hat.service.in b/scripts/lvm2_clvmd_systemd_red_hat.service.in
index f506fa8..1238da4 100644
--- a/scripts/lvm2_clvmd_systemd_red_hat.service.in
+++ b/scripts/lvm2_clvmd_systemd_red_hat.service.in
@@ -11,13 +11,10 @@ DefaultDependencies=no
 Conflicts=shutdown.target
 
 [Service]
-Type=forking
-Environment=CLVMD_OPTS=-T30
+Type=notify
 EnvironmentFile=- at sysconfdir@/sysconfig/clvmd
-ExecStart=@sbindir@/clvmd $CLVMD_OPTS
-SuccessExitStatus=5
+ExecStart=@sbindir@/clvmd -f $CLVMD_OPTS
 TimeoutStartSec=30
 TimeoutStopSec=10
 OOMScoreAdjust=-1000
 Restart=on-abort
-PIDFile=@CLVMD_PIDFILE@
-- 
1.7.10.4


