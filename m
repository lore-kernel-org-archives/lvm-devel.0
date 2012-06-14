From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 14 Jun 2012 14:47:15 +0200
Subject: [PATCH] Cleanup run directory configuration.
Message-ID: <4FD9DD53.7050003@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Remove hardcoded 'run directory' paths.
Add '--with-default-dm-run-dir' conf. setting for standalone dm code.
Add missing '--with-lvmetad-pidfile' conf. setting.
Change clvmd pidfile location from /var/run to /var/run/lvm for consistency.

There's already the "DEFAULT_RUN_DIR" which is set to "/var/run/lvm" by
default. For device-mapper related code, we should probably have
"DEFAULT_DM_RUN_DIR" which would be set to "/var/run" by default
(not to change any default path which is already used by current code)
though "/var/run/dm" would probably be nicer...

(also rhbz #742554)
---
 configure.in                                    |   46 ++++++++++++++++-------
 daemons/dmeventd/dmeventd.h                     |    4 +-
 daemons/lvmetad/lvmetad-core.c                  |    2 +-
 lib/misc/configure.h.in                         |    8 +++-
 scripts/Makefile.in                             |    8 ++--
 scripts/dm_event_systemd_red_hat.socket         |   11 ------
 scripts/dm_event_systemd_red_hat.socket.in      |   11 ++++++
 scripts/lvm2_lvmetad_systemd_red_hat.service.in |    2 +-
 8 files changed, 60 insertions(+), 32 deletions(-)
 delete mode 100644 scripts/dm_event_systemd_red_hat.socket
 create mode 100644 scripts/dm_event_systemd_red_hat.socket.in

diff --git a/configure.in b/configure.in
index f55a505..7e2bb10 100644
--- a/configure.in
+++ b/configure.in
@@ -470,6 +470,22 @@ pkg_config_init() {
 }
 
 ################################################################################
+dnl -- Set up run directory
+AH_TEMPLATE(DEFAULT_DM_RUN_DIR, [Name of default DM run directory.])
+AC_ARG_WITH(default-dm-run-dir,
+	    [  --with-default-dm-run-dir=DM_RUN_DIR Default DM run directory [[/var/run]] ],
+	    [ DEFAULT_DM_RUN_DIR="$withval" ],
+	    [ DEFAULT_DM_RUN_DIR="/var/run" ])
+AC_DEFINE_UNQUOTED(DEFAULT_DM_RUN_DIR,["$DEFAULT_DM_RUN_DIR"] )
+
+AH_TEMPLATE(DEFAULT_RUN_DIR, [Name of default LVM run directory.])
+AC_ARG_WITH(default-run-dir,
+	    [  --with-default-run-dir=RUN_DIR      Default LVM run directory [[/var/run/lvm]] ],
+	    [ DEFAULT_RUN_DIR="$withval" ],
+	    [ DEFAULT_RUN_DIR="/var/run/lvm" ])
+AC_DEFINE_UNQUOTED(DEFAULT_RUN_DIR,["$DEFAULT_RUN_DIR"] )
+
+################################################################################
 dnl -- Build cluster LVM daemon
 AC_MSG_CHECKING(whether to build cluster LVM daemon)
 AC_ARG_WITH(clvmd,
@@ -721,9 +737,9 @@ dnl -- clvmd pidfile
 if test "x$CLVMD" != xnone; then
 	AC_ARG_WITH(clvmd-pidfile,
 		    AC_HELP_STRING([--with-clvmd-pidfile=PATH],
-				   [clvmd pidfile [[/var/run/clvmd.pid]]]),
+				   [clvmd pidfile [[RUN_DIR/clvmd.pid]]]),
 		    CLVMD_PIDFILE=$withval,
-		    CLVMD_PIDFILE="/var/run/clvmd.pid")
+		    CLVMD_PIDFILE="$DEFAULT_RUN_DIR/clvmd.pid")
 	AC_DEFINE_UNQUOTED(CLVMD_PIDFILE, ["$CLVMD_PIDFILE"],
 			   [Path to clvmd pidfile.])
 fi
@@ -744,9 +760,9 @@ dnl -- cmirrord pidfile
 if test "x$BUILD_CMIRRORD" = xyes; then
 	AC_ARG_WITH(cmirrord-pidfile,
 		    AC_HELP_STRING([--with-cmirrord-pidfile=PATH],
-				   [cmirrord pidfile [[/var/run/cmirrord.pid]]]),
+				   [cmirrord pidfile [[DM_RUN_DIR/cmirrord.pid]]]),
 		    CMIRRORD_PIDFILE=$withval,
-		    CMIRRORD_PIDFILE="/var/run/cmirrord.pid")
+		    CMIRRORD_PIDFILE="$DEFAULT_DM_RUN_DIR/cmirrord.pid")
 	AC_DEFINE_UNQUOTED(CMIRRORD_PIDFILE, ["$CMIRRORD_PIDFILE"],
 			   [Path to cmirrord pidfile.])
 fi
@@ -872,6 +888,14 @@ BUILD_LVMETAD=$LVMETAD
 
 if test x$BUILD_LVMETAD = xyes; then
 	AC_DEFINE([LVMETAD_SUPPORT], 1, [Define to 1 to include code that uses lvmetad.])
+
+	AC_ARG_WITH(lvmetad-pidfile,
+		    AC_HELP_STRING([--with-lvmetad-pidfile=PATH],
+				   [lvmetad pidfile [[RUN_DIR/lvmetad.pid]]]),
+		    LVMETAD_PIDFILE=$withval,
+		    LVMETAD_PIDFILE="$DEFAULT_RUN_DIR/lvmetad.pid")
+	AC_DEFINE_UNQUOTED(LVMETAD_PIDFILE, ["$LVMETAD_PIDFILE"],
+			   [Path to lvmetad pidfile.])
 fi
 
 ################################################################################
@@ -1302,9 +1326,9 @@ dnl -- dmeventd pidfile and executable path
 if test "$BUILD_DMEVENTD" = yes; then
 	AC_ARG_WITH(dmeventd-pidfile,
 		    AC_HELP_STRING([--with-dmeventd-pidfile=PATH],
-				   [dmeventd pidfile [[/var/run/dmeventd.pid]]]),
+				   [dmeventd pidfile [[DM_RUN_DIR/dmeventd.pid]]]),
 		    DMEVENTD_PIDFILE=$withval,
-		    DMEVENTD_PIDFILE="/var/run/dmeventd.pid")
+		    DMEVENTD_PIDFILE="$DEFAULT_DM_RUN_DIR/dmeventd.pid")
 	AC_DEFINE_UNQUOTED(DMEVENTD_PIDFILE, ["$DMEVENTD_PIDFILE"],
 			   [Path to dmeventd pidfile.])
 fi
@@ -1319,13 +1343,6 @@ if test "$BUILD_DMEVENTD" = yes; then
 			   [Path to dmeventd binary.])
 fi
 
-AH_TEMPLATE(DEFAULT_RUN_DIR, [Name of default run directory.])
-AC_ARG_WITH(default-run-dir,
-	    [  --with-default-run-dir=DIR       Default run directory [[/var/run/lvm]] ],
-	    [ DEFAULT_RUN_DIR="$withval" ],
-	    [ DEFAULT_RUN_DIR="/var/run/lvm" ])
-AC_DEFINE_UNQUOTED(DEFAULT_RUN_DIR,["$DEFAULT_RUN_DIR"] )
-
 ################################################################################
 dnl -- various defaults
 AC_ARG_WITH(default-system-dir,
@@ -1437,6 +1454,7 @@ AC_SUBST(DEFAULT_BACKUP_SUBDIR)
 AC_SUBST(DEFAULT_CACHE_SUBDIR)
 AC_SUBST(DEFAULT_DATA_ALIGNMENT)
 AC_SUBST(DEFAULT_LOCK_DIR)
+AC_SUBST(DEFAULT_DM_RUN_DIR)
 AC_SUBST(DEFAULT_RUN_DIR)
 AC_SUBST(DEVMAPPER)
 AC_SUBST(DLM_CFLAGS)
@@ -1505,6 +1523,7 @@ AC_SUBST(CUNIT_LIBS)
 AC_SUBST(CUNIT_CFLAGS)
 AC_SUBST(WRITE_INSTALL)
 AC_SUBST(DMEVENTD_PIDFILE)
+AC_SUBST(LVMETAD_PIDFILE)
 AC_SUBST(interface)
 AC_SUBST(kerneldir)
 AC_SUBST(missingkernel)
@@ -1564,6 +1583,7 @@ scripts/lvm2_lvmetad_init_red_hat
 scripts/lvm2_lvmetad_systemd_red_hat.socket
 scripts/lvm2_lvmetad_systemd_red_hat.service
 scripts/lvm2_monitoring_init_red_hat
+scripts/dm_event_systemd_red_hat.socket
 scripts/dm_event_systemd_red_hat.service
 scripts/lvm2_monitoring_systemd_red_hat.service
 scripts/lvm2_tmpfiles_red_hat.conf
diff --git a/daemons/dmeventd/dmeventd.h b/daemons/dmeventd/dmeventd.h
index 81056e9..e21cf45 100644
--- a/daemons/dmeventd/dmeventd.h
+++ b/daemons/dmeventd/dmeventd.h
@@ -17,8 +17,8 @@
 
 /* FIXME This stuff must be configurable. */
 
-#define	DM_EVENT_FIFO_CLIENT	"/var/run/dmeventd-client"
-#define	DM_EVENT_FIFO_SERVER	"/var/run/dmeventd-server"
+#define	DM_EVENT_FIFO_CLIENT	DEFAULT_DM_RUN_DIR "/dmeventd-client"
+#define	DM_EVENT_FIFO_SERVER	DEFAULT_DM_RUN_DIR "/dmeventd-server"
 
 #define DM_EVENT_DEFAULT_TIMEOUT 10
 
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 5b34e21..d41a905 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1094,7 +1094,7 @@ int main(int argc, char *argv[])
 	s.socket_path = getenv("LVM_LVMETAD_SOCKET");
 	if (!s.socket_path)
 		s.socket_path = DEFAULT_RUN_DIR "/lvmetad.socket";
-	s.pidfile = DEFAULT_RUN_DIR "/lvmetad.pid";
+	s.pidfile = LVMETAD_PIDFILE;
         s.log_level = 0;
 	s.protocol = "lvmetad";
 	s.protocol_version = 1;
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 6d904f2..8e8b196 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -44,10 +44,13 @@
 /* Define default name mangling behaviour */
 #undef DEFAULT_DM_NAME_MANGLING
 
+/* Name of default DM run directory. */
+#undef DEFAULT_DM_RUN_DIR
+
 /* Name of default locking directory. */
 #undef DEFAULT_LOCK_DIR
 
-/* Name of default run directory. */
+/* Name of default LVM run directory. */
 #undef DEFAULT_RUN_DIR
 
 /* Define to 0 to reinstate the pre-2.02.54 handling of unit suffixes. */
@@ -455,6 +458,9 @@
 /* Define to 1 to include built-in support for LVM1 metadata. */
 #undef LVM1_INTERNAL
 
+/* Path to lvmetad pidfile. */
+#undef LVMETAD_PIDFILE
+
 /* Define to 1 to include code that uses lvmetad. */
 #undef LVMETAD_SUPPORT
 
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index be012d6..53c85f5 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -75,7 +75,9 @@ install_tmpfiles_configuration:
 	$(INSTALL_DIR) $(tmpfiles_dir)
 	$(INSTALL_DATA) lvm2_tmpfiles_red_hat.conf $(tmpfiles_dir)/lvm2.conf
 
-DISTCLEAN_TARGETS += clvmd_init_red_hat cmirrord_init_red_hat lvm2_monitoring_init_red_hat \
-		     dm_event_systemd_red_hat.service lvm2_monitoring_systemd_red_hat.service \
+DISTCLEAN_TARGETS += clvmd_init_red_hat cmirrord_init_red_hat \
+		     lvm2_monitoring_init_red_hat lvm2_lvmetad_init_red_hat \
+		     dm_event_systemd_red_hat.socket dm_event_systemd_red_hat.service \
+		     lvm2_monitoring_systemd_red_hat.service \
 		     lvm2_lvmetad_systemd_red_hat.socket lvm2_lvmetad_systemd_red_hat.service \
-		     lvm2_lvmetad_init_red_hat lvm2_tmpfiles_red_hat.conf
+		     lvm2_tmpfiles_red_hat.conf
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
index 0000000..c6c480c
--- /dev/null
+++ b/scripts/dm_event_systemd_red_hat.socket.in
@@ -0,0 +1,11 @@
+[Unit]
+Description=Device-mapper event daemon FIFOs
+DefaultDependencies=no
+
+[Socket]
+ListenFIFO=@DEFAULT_DM_RUN_DIR@/dmeventd-server
+ListenFIFO=@DEFAULT_DM_RUN_DIR@/dmeventd-client
+SocketMode=0600
+
+[Install]
+WantedBy=sockets.target
diff --git a/scripts/lvm2_lvmetad_systemd_red_hat.service.in b/scripts/lvm2_lvmetad_systemd_red_hat.service.in
index e32c8a1..2b6a7eb 100644
--- a/scripts/lvm2_lvmetad_systemd_red_hat.service.in
+++ b/scripts/lvm2_lvmetad_systemd_red_hat.service.in
@@ -13,7 +13,7 @@ ExecStartPost=@sbindir@/lvm pvscan --cache
 ExecReload=@sbindir@/lvmetad -R
 Environment=SD_ACTIVATION=1
 Restart=on-abort
-PIDFile=@DEFAULT_RUN_DIR@/lvmetad.pid
+PIDFile=@LVMETAD_PIDFILE@
 
 [Install]
 WantedBy=sysinit.target
-- 
1.7.10.2


