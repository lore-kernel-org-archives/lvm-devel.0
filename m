From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 21 Oct 2011 11:50:02 +0200
Subject: [PATCH] Add configure option to select default run directory base and prepare for early /run use
Message-ID: <4EA1404A.5020500@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On systemd-enabled systems the /run is writeable and it's accessible early on
boot so we don't need to use --sysinit anymore on early boot's vgchange call
(the --sysint is just a shortcut for --ignorelockingfailure, --ignoremonitoring,
--poll n and setting the LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES).

This patch adds a new configure option "--with-default-run-dir-base" with which
it's possible to change the run directory base for all directories/files that
need to be moved to /run in one go easily.

This patch also removes some hardcoded defines (in dmeventd.h and dm-event.socket
files used for systemd).

The patch also changes the dependencies a bit (in Fedora, but the same logic
applies anywhere):

originally:

  <dm-event.socket>
  ...
  fedora-wait-storage.service
  fedora-storage-init.service (calling vgchange -a y --sysinit)
  dm-event.service
  lvm2-monitor.service

changing to:

  <dm-event.socket>
  ...
  fedora-wait-storage.service
  dm-event.service
  fedora-storage-init.service (calling vgchange -a y, without --sysinit!!!)
  lvm2-monitor.service (this is just for proper shutdown now since the dmevent
                        registration will happen within the vgchange -a y call
                        in previous step)


(For FIFO-based activation, the fifos are already prepared and hence the
dm-event service could be spawned already)

Once we have this patch upstream and in the distro, we can remove the --sysinit
from the vgchange call.

Peter
---

 configure.in                                |   29 +++++++++++++++++++-------
 daemons/dmeventd/dmeventd.h                 |    4 +-
 lib/misc/configure.h.in                     |    3 ++
 make.tmpl.in                                |    1 +
 scripts/dm_event_systemd_red_hat.service.in |    4 +-
 scripts/dm_event_systemd_red_hat.socket     |   11 ----------
 scripts/dm_event_systemd_red_hat.socket.in  |   11 ++++++++++
 7 files changed, 40 insertions(+), 23 deletions(-)

diff --git a/configure.in b/configure.in
index 5275b95..26eb268 100644
--- a/configure.in
+++ b/configure.in
@@ -425,6 +425,17 @@ AC_ARG_WITH(ocfdir,
 	    OCFDIR=$withval, OCFDIR='${prefix}/lib/ocf/resource.d/lvm2')
 
 ################################################################################
+dnl -- set run directory base
+AH_TEMPLATE(DEFAULT_RUN_DIR_BASE, [Name of default run directory base.])
+AC_ARG_WITH(default-run-dir-base,
+	    AC_HELP_STRING([--with-default-run-dir-base=RDIR],
+			   [Default run directory base [[/var/run]]]),
+	    [ DEFAULT_RUN_DIR_BASE="$withval" ],
+	    [ DEFAULT_RUN_DIR_BASE="/var/run" ])
+AC_DEFINE_UNQUOTED(DEFAULT_RUN_DIR_BASE, ["$DEFAULT_RUN_DIR_BASE"] )
+
+
+################################################################################
 dnl -- Init pkg-config with dummy invokation:
 dnl -- this is required because PKG_CHECK_MODULES macro is expanded
 dnl -- to initialize the pkg-config environment only at the first invokation,
@@ -653,9 +664,9 @@ dnl -- clvmd pidfile
 if test "x$CLVMD" != xnone; then
 	AC_ARG_WITH(clvmd-pidfile,
 		    AC_HELP_STRING([--with-clvmd-pidfile=PATH],
-				   [clvmd pidfile [[/var/run/clvmd.pid]]]),
+				   [clvmd pidfile [[RDIR/clvmd.pid]]]),
 		    CLVMD_PIDFILE=$withval,
-		    CLVMD_PIDFILE="/var/run/clvmd.pid")
+		    CLVMD_PIDFILE="$DEFAULT_RUN_DIR_BASE/clvmd.pid")
 	AC_DEFINE_UNQUOTED(CLVMD_PIDFILE, ["$CLVMD_PIDFILE"],
 			   [Path to clvmd pidfile.])
 fi
@@ -676,9 +687,9 @@ dnl -- cmirrord pidfile
 if test "x$BUILD_CMIRRORD" = xyes; then
 	AC_ARG_WITH(cmirrord-pidfile,
 		    AC_HELP_STRING([--with-cmirrord-pidfile=PATH],
-				   [cmirrord pidfile [[/var/run/cmirrord.pid]]]),
+				   [cmirrord pidfile [[RDIR/cmirrord.pid]]]),
 		    CMIRRORD_PIDFILE=$withval,
-		    CMIRRORD_PIDFILE="/var/run/cmirrord.pid")
+		    CMIRRORD_PIDFILE="$DEFAULT_RUN_DIR_BASE/cmirrord.pid")
 	AC_DEFINE_UNQUOTED(CMIRRORD_PIDFILE, ["$CMIRRORD_PIDFILE"],
 			   [Path to cmirrord pidfile.])
 fi
@@ -1195,9 +1206,9 @@ dnl -- dmeventd pidfile and executable path
 if test "$BUILD_DMEVENTD" = yes; then
 	AC_ARG_WITH(dmeventd-pidfile,
 		    AC_HELP_STRING([--with-dmeventd-pidfile=PATH],
-				   [dmeventd pidfile [[/var/run/dmeventd.pid]]]),
+				   [dmeventd pidfile [[RDIR/dmeventd.pid]]]),
 		    DMEVENTD_PIDFILE=$withval,
-		    DMEVENTD_PIDFILE="/var/run/dmeventd.pid")
+		    DMEVENTD_PIDFILE="$DEFAULT_RUN_DIR_BASE/dmeventd.pid")
 	AC_DEFINE_UNQUOTED(DMEVENTD_PIDFILE, ["$DMEVENTD_PIDFILE"],
 			   [Path to dmeventd pidfile.])
 fi
@@ -1214,9 +1225,9 @@ fi
 
 AH_TEMPLATE(DEFAULT_RUN_DIR, [Name of default run directory.])
 AC_ARG_WITH(default-run-dir,
-	    [  --with-default-run-dir=DIR       Default run directory [[/var/run/lvm]] ],
+	    [  --with-default-run-dir=DIR       Default run directory [[RDIR/lvm]] ],
 	    [ DEFAULT_RUN_DIR="$withval" ],
-	    [ DEFAULT_RUN_DIR="/var/run/lvm" ])
+	    [ DEFAULT_RUN_DIR="$DEFAULT_RUN_DIR_BASE/lvm" ])
 AC_DEFINE_UNQUOTED(DEFAULT_RUN_DIR,["$DEFAULT_RUN_DIR"] )
 
 ################################################################################
@@ -1328,6 +1339,7 @@ AC_SUBST(DEFAULT_BACKUP_SUBDIR)
 AC_SUBST(DEFAULT_CACHE_SUBDIR)
 AC_SUBST(DEFAULT_DATA_ALIGNMENT)
 AC_SUBST(DEFAULT_LOCK_DIR)
+AC_SUBST(DEFAULT_RUN_DIR_BASE)
 AC_SUBST(DEFAULT_RUN_DIR)
 AC_SUBST(DEVMAPPER)
 AC_SUBST(DLM_CFLAGS)
@@ -1442,6 +1454,7 @@ po/Makefile
 scripts/clvmd_init_red_hat
 scripts/cmirrord_init_red_hat
 scripts/lvm2_monitoring_init_red_hat
+scripts/dm_event_systemd_red_hat.socket
 scripts/dm_event_systemd_red_hat.service
 scripts/lvm2_monitoring_systemd_red_hat.service
 scripts/Makefile
diff --git a/daemons/dmeventd/dmeventd.h b/daemons/dmeventd/dmeventd.h
index c60d402..d4c54ec 100644
--- a/daemons/dmeventd/dmeventd.h
+++ b/daemons/dmeventd/dmeventd.h
@@ -17,8 +17,8 @@
 
 /* FIXME This stuff must be configurable. */
 
-#define	DM_EVENT_FIFO_CLIENT	"/var/run/dmeventd-client"
-#define	DM_EVENT_FIFO_SERVER	"/var/run/dmeventd-server"
+#define	DM_EVENT_FIFO_CLIENT	DEFAULT_RUN_DIR_BASE "/dmeventd-client"
+#define	DM_EVENT_FIFO_SERVER	DEFAULT_RUN_DIR_BASE "/dmeventd-server"
 
 #define DM_EVENT_DEFAULT_TIMEOUT 10
 
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 707445a..b739723 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -44,6 +44,9 @@
 /* Name of default run directory. */
 #undef DEFAULT_RUN_DIR
 
+/* Name of default run directory base. */
+#undef DEFAULT_RUN_DIR_BASE
+
 /* Define to 0 to reinstate the pre-2.02.54 handling of unit suffixes. */
 #undef DEFAULT_SI_UNIT_CONSISTENCY
 
diff --git a/make.tmpl.in b/make.tmpl.in
index 298fe31..ce0a09b 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -76,6 +76,7 @@ DEFAULT_ARCHIVE_DIR = $(DEFAULT_SYS_DIR)/@DEFAULT_ARCHIVE_SUBDIR@
 DEFAULT_BACKUP_DIR = $(DEFAULT_SYS_DIR)/@DEFAULT_BACKUP_SUBDIR@
 DEFAULT_CACHE_DIR = $(DEFAULT_SYS_DIR)/@DEFAULT_CACHE_SUBDIR@
 DEFAULT_LOCK_DIR = @DEFAULT_LOCK_DIR@
+DEFAULT_RUN_DIR_BASE = @DEFAULT_RUN_DIR_BASE@
 DEFAULT_RUN_DIR = @DEFAULT_RUN_DIR@
 
 # Setup vpath search paths for some suffixes
diff --git a/scripts/dm_event_systemd_red_hat.service.in b/scripts/dm_event_systemd_red_hat.service.in
index 32295d3..d9bb107 100644
--- a/scripts/dm_event_systemd_red_hat.service.in
+++ b/scripts/dm_event_systemd_red_hat.service.in
@@ -1,7 +1,7 @@
 [Unit]
 Description=Device-mapper event daemon
-After=fedora-storage-init.service fedora-storage-init-late.service
-Before=local-fs.target
+After=fedora-wait-storage.service
+Before=fedora-storage-init.service
 DefaultDependencies=no
 
 [Service]
diff --git a/scripts/dm_event_systemd_red_hat.socket b/scripts/dm_event_systemd_red_hat.socket
deleted file mode 100644
index c580555..0000000
--- a/scripts/dm_event_systemd_red_hat.socket
+++ /dev/null
@@ -1,11 +0,0 @@
-[Unit]
-Description=Device-mapper event daemon FIFOs
-DefaultDependencies=no
-
-[Socket]
-ListenFIFO=/var/run/dmeventd-server
-ListenFIFO=/var/run/dmeventd-client
-SocketMode=0600
-
-[Install]
-WantedBy=sockets.target
diff --git a/scripts/dm_event_systemd_red_hat.socket.in b/scripts/dm_event_systemd_red_hat.socket.in
new file mode 100644
index 0000000..7dbcd4c
--- /dev/null
+++ b/scripts/dm_event_systemd_red_hat.socket.in
@@ -0,0 +1,11 @@
+[Unit]
+Description=Device-mapper event daemon FIFOs
+DefaultDependencies=no
+
+[Socket]
+ListenFIFO=@DEFAULT_RUN_DIR_BASE@/dmeventd-server
+ListenFIFO=@DEFAULT_RUN_DIR_BASE@/dmeventd-client
+SocketMode=0600
+
+[Install]
+WantedBy=sockets.target


