From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 27 Jun 2012 10:12:54 +0000 (UTC)
Subject: master - configure: run directory configuration cleanup
Message-ID: <20120627101254.566FA171E@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9a96f930a762418f1014f6a9da9546cb1f501f04
Commit:        9a96f930a762418f1014f6a9da9546cb1f501f04
Parent:        c8591b2ac7c99ea43e7f94f3dfb183019c2fed6e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 21 08:41:52 2012 -0400
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 27 12:11:47 2012 +0200

configure: run directory configuration cleanup

There were several hard-coded values for run directory around the code.
Also, some tools are DM specific only, others are LVM specific and there
was no distinction made here before. With this patch applied, we have
this cleaned up a bit (subsystem in brackets, defaults in parentheses):

          [common] configurable PID_DIR     (/var/run)

 lvm      [lvm]    configurable RUN_DIR     (/var/run/lvm)
                   configurable locking dir (/var/lock/lvm)

 clvmd    [lvm]    configurable pid file    (PID_DIR/clvmd.pid)
                   socket                   (RUN_DIR/clvmd.sock)

 lvmetad  [lvm]    configurable pid file    (PID_DIR/lvmetad.pid)
                   socket                   (RUN_DIR/lvmetad.socket)

 dm       [dm]     configurable DM_RUN_DIR  (/var/run)

 cmirrord [dm]     configurable pid file    (PID_DIR/cmirrord.pid)

 dmeventd [dm]     configurable pid file    (PID_DIR/dmeventd.pid)
                   server fifo              (DM_RUN_DIR/dmeventd-server)
                   client fifo              (DM_RUN_DIR/dmeventd-client)

The changes briefly:
  - added configure --with-default-pid-dir
  - added configure --with-default-dm-run-dir
  - added configure --with-lvmetad-pidfile
  - by default, using one common pid directory for everything
    (only lvmetad was not following this before)
---
 WHATS_NEW_DM                                    |    4 ++
 configure.in                                    |   56 +++++++++++++++++-----
 daemons/dmeventd/dmeventd.h                     |    4 +-
 daemons/lvmetad/lvmetad-core.c                  |    2 +-
 lib/misc/configure.h.in                         |   11 ++++-
 scripts/Makefile.in                             |    8 ++-
 scripts/dm_event_systemd_red_hat.socket         |   12 -----
 scripts/dm_event_systemd_red_hat.socket.in      |   11 +++++
 scripts/lvm2_lvmetad_init_red_hat.in            |    2 +-
 scripts/lvm2_lvmetad_systemd_red_hat.service.in |    2 +-
 10 files changed, 78 insertions(+), 34 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 33f8515..f6596c1 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,9 @@
 Version 1.02.76 - 
 ===============================
+  Remove hard-coded paths for dmeventd fifos and use default-dm-run-dir.
+  Add configure --with-lvmetad-pidfile to remove hard-coded value.
+  Add configure --with-default-pid-dir for common directory with pid files.
+  Add configure --with-default-dm-run-dir to set run directory for dm tools.
   Add documentation references in systemd units.
   Remove veritysetup.  Now maintained with cryptsetup.
 
diff --git a/configure.in b/configure.in
index f55a505..814c0bd 100644
--- a/configure.in
+++ b/configure.in
@@ -470,6 +470,32 @@ pkg_config_init() {
 }
 
 ################################################################################
+dnl -- Set up pidfile and run directory
+AH_TEMPLATE(DEFAULT_PID_DIR)
+AC_ARG_WITH(default-pid-dir,
+	    AC_HELP_STRING([--with-default-pid-dir=PID_DIR],
+			   [Default directory to keep PID files in. [[/var/run]]]),
+	    DEFAULT_PID_DIR="$withval", DEFAULT_PID_DIR="/var/run")
+AC_DEFINE_UNQUOTED(DEFAULT_PID_DIR, ["$DEFAULT_PID_DIR"],
+		   [Default directory to keep PID files in.])
+
+AH_TEMPLATE(DEFAULT_DM_RUN_DIR, [Name of default DM run directory.])
+AC_ARG_WITH(default-dm-run-dir,
+	    AC_HELP_STRING([--with-default-dm-run-dir=DM_RUN_DIR],
+			   [ Default DM run directory. [[/var/run]]]),
+	    DEFAULT_DM_RUN_DIR="$withval", DEFAULT_DM_RUN_DIR="/var/run")
+AC_DEFINE_UNQUOTED(DEFAULT_DM_RUN_DIR, ["$DEFAULT_DM_RUN_DIR"],
+		   [Default DM run directory.])
+
+AH_TEMPLATE(DEFAULT_RUN_DIR, [Name of default LVM run directory.])
+AC_ARG_WITH(default-run-dir,
+	    AC_HELP_STRING([--with-default-run-dir=RUN_DIR],
+			   [Default LVM run directory. [[/var/run/lvm]]]),
+	    DEFAULT_RUN_DIR="$withval", DEFAULT_RUN_DIR="/var/run/lvm")
+AC_DEFINE_UNQUOTED(DEFAULT_RUN_DIR, ["$DEFAULT_RUN_DIR"],
+		   [Default LVM run directory.])
+
+################################################################################
 dnl -- Build cluster LVM daemon
 AC_MSG_CHECKING(whether to build cluster LVM daemon)
 AC_ARG_WITH(clvmd,
@@ -721,9 +747,9 @@ dnl -- clvmd pidfile
 if test "x$CLVMD" != xnone; then
 	AC_ARG_WITH(clvmd-pidfile,
 		    AC_HELP_STRING([--with-clvmd-pidfile=PATH],
-				   [clvmd pidfile [[/var/run/clvmd.pid]]]),
+				   [clvmd pidfile [[PID_DIR/clvmd.pid]]]),
 		    CLVMD_PIDFILE=$withval,
-		    CLVMD_PIDFILE="/var/run/clvmd.pid")
+		    CLVMD_PIDFILE="$DEFAULT_PID_DIR/clvmd.pid")
 	AC_DEFINE_UNQUOTED(CLVMD_PIDFILE, ["$CLVMD_PIDFILE"],
 			   [Path to clvmd pidfile.])
 fi
@@ -744,9 +770,9 @@ dnl -- cmirrord pidfile
 if test "x$BUILD_CMIRRORD" = xyes; then
 	AC_ARG_WITH(cmirrord-pidfile,
 		    AC_HELP_STRING([--with-cmirrord-pidfile=PATH],
-				   [cmirrord pidfile [[/var/run/cmirrord.pid]]]),
+				   [cmirrord pidfile [[PID_DIR/cmirrord.pid]]]),
 		    CMIRRORD_PIDFILE=$withval,
-		    CMIRRORD_PIDFILE="/var/run/cmirrord.pid")
+		    CMIRRORD_PIDFILE="$DEFAULT_PID_DIR/cmirrord.pid")
 	AC_DEFINE_UNQUOTED(CMIRRORD_PIDFILE, ["$CMIRRORD_PIDFILE"],
 			   [Path to cmirrord pidfile.])
 fi
@@ -872,6 +898,14 @@ BUILD_LVMETAD=$LVMETAD
 
 if test x$BUILD_LVMETAD = xyes; then
 	AC_DEFINE([LVMETAD_SUPPORT], 1, [Define to 1 to include code that uses lvmetad.])
+
+	AC_ARG_WITH(lvmetad-pidfile,
+		    AC_HELP_STRING([--with-lvmetad-pidfile=PATH],
+				   [lvmetad pidfile [[PID_DIR/lvmetad.pid]]]),
+		    LVMETAD_PIDFILE=$withval,
+		    LVMETAD_PIDFILE="$DEFAULT_PID_DIR/lvmetad.pid")
+	AC_DEFINE_UNQUOTED(LVMETAD_PIDFILE, ["$LVMETAD_PIDFILE"],
+			   [Path to lvmetad pidfile.])
 fi
 
 ################################################################################
@@ -1302,9 +1336,9 @@ dnl -- dmeventd pidfile and executable path
 if test "$BUILD_DMEVENTD" = yes; then
 	AC_ARG_WITH(dmeventd-pidfile,
 		    AC_HELP_STRING([--with-dmeventd-pidfile=PATH],
-				   [dmeventd pidfile [[/var/run/dmeventd.pid]]]),
+				   [dmeventd pidfile [[PID_DIR/dmeventd.pid]]]),
 		    DMEVENTD_PIDFILE=$withval,
-		    DMEVENTD_PIDFILE="/var/run/dmeventd.pid")
+		    DMEVENTD_PIDFILE="$DEFAULT_PID_DIR/dmeventd.pid")
 	AC_DEFINE_UNQUOTED(DMEVENTD_PIDFILE, ["$DMEVENTD_PIDFILE"],
 			   [Path to dmeventd pidfile.])
 fi
@@ -1319,13 +1353,6 @@ if test "$BUILD_DMEVENTD" = yes; then
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
@@ -1437,6 +1464,7 @@ AC_SUBST(DEFAULT_BACKUP_SUBDIR)
 AC_SUBST(DEFAULT_CACHE_SUBDIR)
 AC_SUBST(DEFAULT_DATA_ALIGNMENT)
 AC_SUBST(DEFAULT_LOCK_DIR)
+AC_SUBST(DEFAULT_DM_RUN_DIR)
 AC_SUBST(DEFAULT_RUN_DIR)
 AC_SUBST(DEVMAPPER)
 AC_SUBST(DLM_CFLAGS)
@@ -1505,6 +1533,7 @@ AC_SUBST(CUNIT_LIBS)
 AC_SUBST(CUNIT_CFLAGS)
 AC_SUBST(WRITE_INSTALL)
 AC_SUBST(DMEVENTD_PIDFILE)
+AC_SUBST(LVMETAD_PIDFILE)
 AC_SUBST(interface)
 AC_SUBST(kerneldir)
 AC_SUBST(missingkernel)
@@ -1564,6 +1593,7 @@ scripts/lvm2_lvmetad_init_red_hat
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
index 6d904f2..c1d1218 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -44,10 +44,16 @@
 /* Define default name mangling behaviour */
 #undef DEFAULT_DM_NAME_MANGLING
 
+/* Default DM run directory. */
+#undef DEFAULT_DM_RUN_DIR
+
 /* Name of default locking directory. */
 #undef DEFAULT_LOCK_DIR
 
-/* Name of default run directory. */
+/* Default directory to keep PID files in. */
+#undef DEFAULT_PID_DIR
+
+/* Default LVM run directory. */
 #undef DEFAULT_RUN_DIR
 
 /* Define to 0 to reinstate the pre-2.02.54 handling of unit suffixes. */
@@ -455,6 +461,9 @@
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
index bfc8ea1..0000000
--- a/scripts/dm_event_systemd_red_hat.socket
+++ /dev/null
@@ -1,12 +0,0 @@
-[Unit]
-Description=Device-mapper event daemon FIFOs
-Documentation=man:dmeventd(8)
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
diff --git a/scripts/lvm2_lvmetad_init_red_hat.in b/scripts/lvm2_lvmetad_init_red_hat.in
index 886944e..888c730 100644
--- a/scripts/lvm2_lvmetad_init_red_hat.in
+++ b/scripts/lvm2_lvmetad_init_red_hat.in
@@ -41,7 +41,7 @@ sbindir=@sbindir@
 lvm_pvscan="${sbindir}/lvm pvscan --cache"
 
 LOCK_FILE="/var/lock/subsys/$DAEMON"
-PID_FILE="@DEFAULT_RUN_DIR@/${DAEMON}.pid"
+PID_FILE="@LVMETAD_PIDFILE@"
 
 
 rh_status() {
diff --git a/scripts/lvm2_lvmetad_systemd_red_hat.service.in b/scripts/lvm2_lvmetad_systemd_red_hat.service.in
index 7552240..e527369 100644
--- a/scripts/lvm2_lvmetad_systemd_red_hat.service.in
+++ b/scripts/lvm2_lvmetad_systemd_red_hat.service.in
@@ -14,7 +14,7 @@ ExecStartPost=@sbindir@/lvm pvscan --cache
 ExecReload=@sbindir@/lvmetad -R
 Environment=SD_ACTIVATION=1
 Restart=on-abort
-PIDFile=@DEFAULT_RUN_DIR@/lvmetad.pid
+PIDFile=@LVMETAD_PIDFILE@
 
 [Install]
 WantedBy=sysinit.target


