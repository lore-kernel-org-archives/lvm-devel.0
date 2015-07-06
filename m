From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  6 Jul 2015 17:21:07 +0000 (UTC)
Subject: master - configure: Separate sanlock and dlm lock config.
Message-ID: <20150706172107.1148760D72@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c923dee8de0fd01ca1538ecf783fb6c1dfa9d127
Commit:        c923dee8de0fd01ca1538ecf783fb6c1dfa9d127
Parent:        633aea92fbcb228417ac2b4a1ac3d808460d8df5
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jul 6 18:20:20 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jul 6 18:20:20 2015 +0100

configure: Separate sanlock and dlm lock config.

---
 WHATS_NEW               |    1 +
 configure               |  340 +++++++++++++++++++++++++++--------------------
 configure.in            |  189 +++++++++++++--------------
 lib/misc/configure.h.in |   11 +-
 4 files changed, 292 insertions(+), 249 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f22f0eb..8ba1e43 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.125 -
 ================================
+  Replace --enable-lvmlockd by --enable-lockd-sanlock and --enable-lockd-dlm.
 
 Version 2.02.124 - 3rd July 2015
 ================================
diff --git a/configure b/configure
index 3d650a1..4c4c843 100755
--- a/configure
+++ b/configure
@@ -724,6 +724,8 @@ CLDWHOLEARCHIVE
 CLDNOWHOLEARCHIVE
 CLDFLAGS
 CACHE
+BUILD_LOCKDDLM
+BUILD_LOCKDSANLOCK
 BUILD_LVMLOCKD
 BUILD_LVMPOLLD
 BUILD_LVMETAD
@@ -918,14 +920,15 @@ enable_testing
 enable_valgrind_pool
 enable_devmapper
 enable_lvmetad
+enable_lvmpolld
+enable_lockd_sanlock
+enable_lockd_dlm
+enable_use_lvmlockd
+with_lvmlockd_pidfile
 enable_use_lvmetad
 with_lvmetad_pidfile
-enable_lvmpolld
 enable_use_lvmpolld
 with_lvmpolld_pidfile
-enable_lvmlockd
-enable_use_lvmlockd
-with_lvmlockd_pidfile
 enable_blkid_wiping
 enable_udev_systemd_background_jobs
 enable_udev_sync
@@ -1643,11 +1646,12 @@ Optional Features:
   --enable-valgrind-pool  enable valgrind awareness of pools
   --disable-devmapper     disable LVM2 device-mapper interaction
   --enable-lvmetad        enable the LVM Metadata Daemon
-  --disable-use-lvmetad   disable usage of LVM Metadata Daemon
   --enable-lvmpolld       enable the LVM Polling Daemon
-  --disable-use-lvmpolld  disable usage of LVM Poll Daemon
-  --enable-lvmlockd       enable the LVM lock daemon
+  --enable-lockd-sanlock  enable the LVM lock daemon using sanlock
+  --enable-lockd-dlm      enable the LVM lock daemon using dlm
   --disable-use-lvmlockd  disable usage of LVM lock daemon
+  --disable-use-lvmetad   disable usage of LVM Metadata Daemon
+  --disable-use-lvmpolld  disable usage of LVM Poll Daemon
   --disable-blkid_wiping  disable libblkid detection of signatures when wiping
                           and use native code instead
   --disable-udev-systemd-background-jobs
@@ -1737,12 +1741,12 @@ Optional Packages:
   --with-cmirrord-pidfile=PATH
                           cmirrord pidfile [PID_DIR/cmirrord.pid]
   --with-optimisation=OPT C optimisation flag [OPT=-O2]
+  --with-lvmlockd-pidfile=PATH
+                          lvmlockd pidfile [PID_DIR/lvmlockd.pid]
   --with-lvmetad-pidfile=PATH
                           lvmetad pidfile [PID_DIR/lvmetad.pid]
   --with-lvmpolld-pidfile=PATH
                           lvmpolld pidfile [PID_DIR/lvmpolld.pid]
-  --with-lvmlockd-pidfile=PATH
-                          lvmlockd pidfile [PID_DIR/lvmlockd.pid]
   --with-localedir=DIR    locale-dependent data [DATAROOTDIR/locale]
   --with-confdir=DIR      configuration files in DIR [/etc]
   --with-staticdir=DIR    static binaries in DIR [EPREFIX/sbin]
@@ -3069,6 +3073,8 @@ case "$host_os" in
 		LVMETAD=no
 		LVMPOLLD=no
 		LVMLOCKD=no
+		LOCKDSANLOCK=no
+		LOCKDDLM=no
 		ODIRECT=yes
 		DM_IOCTLS=yes
 		SELINUX=yes
@@ -10897,47 +10903,6 @@ $as_echo "$LVMETAD" >&6; }
 
 BUILD_LVMETAD=$LVMETAD
 
-if test "$BUILD_LVMETAD" = yes; then
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking defaults for use_lvmetad" >&5
-$as_echo_n "checking defaults for use_lvmetad... " >&6; }
-	# Check whether --enable-use_lvmetad was given.
-if test "${enable_use_lvmetad+set}" = set; then :
-  enableval=$enable_use_lvmetad; case ${enableval} in
-		       yes) DEFAULT_USE_LVMETAD=1 ;;
-		       *) DEFAULT_USE_LVMETAD=0 ;;
-		       esac
-else
-  DEFAULT_USE_LVMETAD=1
-fi
-
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $DEFAULT_USE_LVMETAD" >&5
-$as_echo "$DEFAULT_USE_LVMETAD" >&6; }
-
-$as_echo "#define LVMETAD_SUPPORT 1" >>confdefs.h
-
-
-
-# Check whether --with-lvmetad-pidfile was given.
-if test "${with_lvmetad_pidfile+set}" = set; then :
-  withval=$with_lvmetad_pidfile; LVMETAD_PIDFILE=$withval
-else
-  LVMETAD_PIDFILE="$DEFAULT_PID_DIR/lvmetad.pid"
-fi
-
-
-cat >>confdefs.h <<_ACEOF
-#define LVMETAD_PIDFILE "$LVMETAD_PIDFILE"
-_ACEOF
-
-else
-	DEFAULT_USE_LVMETAD=0
-fi
-
-cat >>confdefs.h <<_ACEOF
-#define DEFAULT_USE_LVMETAD $DEFAULT_USE_LVMETAD
-_ACEOF
-
-
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build lvmpolld" >&5
 $as_echo_n "checking whether to build lvmpolld... " >&6; }
@@ -10951,103 +10916,27 @@ $as_echo "$LVMPOLLD" >&6; }
 
 BUILD_LVMPOLLD=$LVMPOLLD
 
-if test "$BUILD_LVMPOLLD" = yes; then
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking defaults for use_lvmpolld" >&5
-$as_echo_n "checking defaults for use_lvmpolld... " >&6; }
-	# Check whether --enable-use_lvmpolld was given.
-if test "${enable_use_lvmpolld+set}" = set; then :
-  enableval=$enable_use_lvmpolld; case ${enableval} in
-		       yes) DEFAULT_USE_LVMPOLLD=1 ;;
-		       *) DEFAULT_USE_LVMPOLLD=0 ;;
-		       esac
-else
-  DEFAULT_USE_LVMPOLLD=1
-fi
-
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $DEFAULT_USE_LVMPOLLD" >&5
-$as_echo "$DEFAULT_USE_LVMPOLLD" >&6; }
-
-$as_echo "#define LVMPOLLD_SUPPORT 1" >>confdefs.h
-
-
-
-# Check whether --with-lvmpolld-pidfile was given.
-if test "${with_lvmpolld_pidfile+set}" = set; then :
-  withval=$with_lvmpolld_pidfile; LVMPOLLD_PIDFILE=$withval
-else
-  LVMPOLLD_PIDFILE="$DEFAULT_PID_DIR/lvmpolld.pid"
-fi
-
-
-cat >>confdefs.h <<_ACEOF
-#define LVMPOLLD_PIDFILE "$LVMPOLLD_PIDFILE"
-_ACEOF
-
-else
-	DEFAULT_USE_LVMPOLLD=0
-fi
-
-cat >>confdefs.h <<_ACEOF
-#define DEFAULT_USE_LVMPOLLD $DEFAULT_USE_LVMPOLLD
-_ACEOF
-
-
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build lvmlockd" >&5
-$as_echo_n "checking whether to build lvmlockd... " >&6; }
-# Check whether --enable-lvmlockd was given.
-if test "${enable_lvmlockd+set}" = set; then :
-  enableval=$enable_lvmlockd; LVMLOCKD=$enableval
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build lockdsanlock" >&5
+$as_echo_n "checking whether to build lockdsanlock... " >&6; }
+# Check whether --enable-lockd-sanlock was given.
+if test "${enable_lockd_sanlock+set}" = set; then :
+  enableval=$enable_lockd_sanlock; LOCKDSANLOCK=$enableval
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $LVMLOCKD" >&5
-$as_echo "$LVMLOCKD" >&6; }
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $LOCKDSANLOCK" >&5
+$as_echo "$LOCKDSANLOCK" >&6; }
 
-BUILD_LVMLOCKD=$LVMLOCKD
+BUILD_LOCKDSANLOCK=$LOCKDSANLOCK
 
-if test "$BUILD_LVMLOCKD" = yes; then
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking defaults for use_lvmlockd" >&5
-$as_echo_n "checking defaults for use_lvmlockd... " >&6; }
-	# Check whether --enable-use_lvmlockd was given.
-if test "${enable_use_lvmlockd+set}" = set; then :
-  enableval=$enable_use_lvmlockd; case ${enableval} in
-		       yes) DEFAULT_USE_LVMLOCKD=1 ;;
-		       *) DEFAULT_USE_LVMLOCKD=0 ;;
-		       esac
-else
-  DEFAULT_USE_LVMLOCKD=1
-fi
+if test "$BUILD_LOCKDSANLOCK" = yes; then
 
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $DEFAULT_USE_LVMLOCKD" >&5
-$as_echo "$DEFAULT_USE_LVMLOCKD" >&6; }
+$as_echo "#define LOCKDSANLOCK_SUPPORT 1" >>confdefs.h
 
-$as_echo "#define LVMLOCKD_SUPPORT 1" >>confdefs.h
-
-
-
-# Check whether --with-lvmlockd-pidfile was given.
-if test "${with_lvmlockd_pidfile+set}" = set; then :
-  withval=$with_lvmlockd_pidfile; LVMLOCKD_PIDFILE=$withval
-else
-  LVMLOCKD_PIDFILE="$DEFAULT_PID_DIR/lvmlockd.pid"
 fi
 
-
-cat >>confdefs.h <<_ACEOF
-#define LVMLOCKD_PIDFILE "$LVMLOCKD_PIDFILE"
-_ACEOF
-
-else
-	DEFAULT_USE_LVMLOCKD=0
-fi
-
-cat >>confdefs.h <<_ACEOF
-#define DEFAULT_USE_LVMLOCKD $DEFAULT_USE_LVMLOCKD
-_ACEOF
-
-
 ################################################################################
-if test "$BUILD_LVMLOCKD" = yes; then
+if test "$BUILD_LOCKDSANLOCK" = yes; then
 
 pkg_failed=no
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for LOCKD_SANLOCK" >&5
@@ -11119,6 +11008,30 @@ else
 $as_echo "yes" >&6; }
 	HAVE_LOCKD_SANLOCK=yes
 fi
+	BUILD_LVMLOCKD=yes
+fi
+
+################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build lockddlm" >&5
+$as_echo_n "checking whether to build lockddlm... " >&6; }
+# Check whether --enable-lockd-dlm was given.
+if test "${enable_lockd_dlm+set}" = set; then :
+  enableval=$enable_lockd_dlm; LOCKDDLM=$enableval
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $LOCKDDLM" >&5
+$as_echo "$LOCKDDLM" >&6; }
+
+BUILD_LOCKDDLM=$LOCKDDLM
+
+if test "$BUILD_LOCKDDLM" = yes; then
+
+$as_echo "#define LOCKDDLM_SUPPORT 1" >>confdefs.h
+
+fi
+
+################################################################################
+if test "$BUILD_LOCKDDLM" = yes; then
 
 pkg_failed=no
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for LOCKD_DLM" >&5
@@ -11190,8 +11103,149 @@ else
 $as_echo "yes" >&6; }
 	HAVE_LOCKD_DLM=yes
 fi
+	BUILD_LVMLOCKD=yes
+fi
+
+################################################################################
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build lvmlockd" >&5
+$as_echo_n "checking whether to build lvmlockd... " >&6; }
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $BUILD_LVMLOCKD" >&5
+$as_echo "$BUILD_LVMLOCKD" >&6; }
+
+if test "$BUILD_LVMLOCKD" = yes; then
+	if test -n "$BUILD_LVMPOLLD"; then :
+  BUILD_LVMPOLLD=yes; { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Enabling lvmpolld - required by lvmlockd." >&5
+$as_echo "$as_me: WARNING: Enabling lvmpolld - required by lvmlockd." >&2;}
+fi
+	if test -n "$BUILD_LVMETAD"; then :
+  BUILD_LVMETAD=yes; { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Enabling lvmetad - required by lvmlockd." >&5
+$as_echo "$as_me: WARNING: Enabling lvmetad - required by lvmlockd." >&2;}
+fi
+	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking defaults for use_lvmlockd" >&5
+$as_echo_n "checking defaults for use_lvmlockd... " >&6; }
+	# Check whether --enable-use_lvmlockd was given.
+if test "${enable_use_lvmlockd+set}" = set; then :
+  enableval=$enable_use_lvmlockd; case ${enableval} in
+		       yes) DEFAULT_USE_LVMLOCKD=1 ;;
+		       *) DEFAULT_USE_LVMLOCKD=0 ;;
+		       esac
+else
+  DEFAULT_USE_LVMLOCKD=1
+fi
+
+	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $DEFAULT_USE_LVMLOCKD" >&5
+$as_echo "$DEFAULT_USE_LVMLOCKD" >&6; }
+
+$as_echo "#define LVMLOCKD_SUPPORT 1" >>confdefs.h
+
+
+
+# Check whether --with-lvmlockd-pidfile was given.
+if test "${with_lvmlockd_pidfile+set}" = set; then :
+  withval=$with_lvmlockd_pidfile; LVMLOCKD_PIDFILE=$withval
+else
+  LVMLOCKD_PIDFILE="$DEFAULT_PID_DIR/lvmlockd.pid"
+fi
+
+
+cat >>confdefs.h <<_ACEOF
+#define LVMLOCKD_PIDFILE "$LVMLOCKD_PIDFILE"
+_ACEOF
+
+else
+	DEFAULT_USE_LVMLOCKD=0
 fi
 
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_USE_LVMLOCKD $DEFAULT_USE_LVMLOCKD
+_ACEOF
+
+
+################################################################################
+if test "$BUILD_LVMETAD" = yes; then
+	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking defaults for use_lvmetad" >&5
+$as_echo_n "checking defaults for use_lvmetad... " >&6; }
+	# Check whether --enable-use_lvmetad was given.
+if test "${enable_use_lvmetad+set}" = set; then :
+  enableval=$enable_use_lvmetad; case ${enableval} in
+		       yes) DEFAULT_USE_LVMETAD=1 ;;
+		       *) DEFAULT_USE_LVMETAD=0 ;;
+		       esac
+else
+  DEFAULT_USE_LVMETAD=1
+fi
+
+	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $DEFAULT_USE_LVMETAD" >&5
+$as_echo "$DEFAULT_USE_LVMETAD" >&6; }
+
+$as_echo "#define LVMETAD_SUPPORT 1" >>confdefs.h
+
+
+
+# Check whether --with-lvmetad-pidfile was given.
+if test "${with_lvmetad_pidfile+set}" = set; then :
+  withval=$with_lvmetad_pidfile; LVMETAD_PIDFILE=$withval
+else
+  LVMETAD_PIDFILE="$DEFAULT_PID_DIR/lvmetad.pid"
+fi
+
+
+cat >>confdefs.h <<_ACEOF
+#define LVMETAD_PIDFILE "$LVMETAD_PIDFILE"
+_ACEOF
+
+else
+	DEFAULT_USE_LVMETAD=0
+fi
+
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_USE_LVMETAD $DEFAULT_USE_LVMETAD
+_ACEOF
+
+
+################################################################################
+if test "$BUILD_LVMPOLLD" = yes; then
+	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking defaults for use_lvmpolld" >&5
+$as_echo_n "checking defaults for use_lvmpolld... " >&6; }
+	# Check whether --enable-use_lvmpolld was given.
+if test "${enable_use_lvmpolld+set}" = set; then :
+  enableval=$enable_use_lvmpolld; case ${enableval} in
+		       yes) DEFAULT_USE_LVMPOLLD=1 ;;
+		       *) DEFAULT_USE_LVMPOLLD=0 ;;
+		       esac
+else
+  DEFAULT_USE_LVMPOLLD=1
+fi
+
+	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $DEFAULT_USE_LVMPOLLD" >&5
+$as_echo "$DEFAULT_USE_LVMPOLLD" >&6; }
+
+$as_echo "#define LVMPOLLD_SUPPORT 1" >>confdefs.h
+
+
+
+# Check whether --with-lvmpolld-pidfile was given.
+if test "${with_lvmpolld_pidfile+set}" = set; then :
+  withval=$with_lvmpolld_pidfile; LVMPOLLD_PIDFILE=$withval
+else
+  LVMPOLLD_PIDFILE="$DEFAULT_PID_DIR/lvmpolld.pid"
+fi
+
+
+cat >>confdefs.h <<_ACEOF
+#define LVMPOLLD_PIDFILE "$LVMPOLLD_PIDFILE"
+_ACEOF
+
+else
+	DEFAULT_USE_LVMPOLLD=0
+fi
+
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_USE_LVMPOLLD $DEFAULT_USE_LVMPOLLD
+_ACEOF
+
+
 ################################################################################
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable libblkid detection of signatures when wiping" >&5
@@ -13517,6 +13571,8 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdev
 mapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan
 _systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
@@ -14902,13 +14958,3 @@ if test "$ODIRECT" != yes; then :
   { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&5
 $as_echo "$as_me: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&2;}
 fi
-
-if test "$BUILD_LVMLOCKD" == yes && test "$BUILD_LVMPOLLD" == no; then :
-  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: lvmlockd requires lvmpolld" >&5
-$as_echo "$as_me: WARNING: lvmlockd requires lvmpolld" >&2;}
-fi
-
-if test "$BUILD_LVMLOCKD" == yes && test "$BUILD_LVMETAD" == no; then :
-  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: lvmlockd requires lvmetad" >&5
-$as_echo "$as_me: WARNING: lvmlockd requires lvmetad" >&2;}
-fi
diff --git a/configure.in b/configure.in
index 9e713aa..7839480 100644
--- a/configure.in
+++ b/configure.in
@@ -1079,31 +1079,6 @@ AC_MSG_RESULT($LVMETAD)
 
 BUILD_LVMETAD=$LVMETAD
 
-if test "$BUILD_LVMETAD" = yes; then
-	AC_MSG_CHECKING([defaults for use_lvmetad])
-	AC_ARG_ENABLE(use_lvmetad,
-		      AC_HELP_STRING([--disable-use-lvmetad],
-				     [disable usage of LVM Metadata Daemon]),
-		      [case ${enableval} in
-		       yes) DEFAULT_USE_LVMETAD=1 ;;
-		       *) DEFAULT_USE_LVMETAD=0 ;;
-		       esac], DEFAULT_USE_LVMETAD=1)
-	AC_MSG_RESULT($DEFAULT_USE_LVMETAD)
-	AC_DEFINE([LVMETAD_SUPPORT], 1, [Define to 1 to include code that uses lvmetad.])
-
-	AC_ARG_WITH(lvmetad-pidfile,
-		    AC_HELP_STRING([--with-lvmetad-pidfile=PATH],
-				   [lvmetad pidfile [PID_DIR/lvmetad.pid]]),
-		    LVMETAD_PIDFILE=$withval,
-		    LVMETAD_PIDFILE="$DEFAULT_PID_DIR/lvmetad.pid")
-	AC_DEFINE_UNQUOTED(LVMETAD_PIDFILE, ["$LVMETAD_PIDFILE"],
-			   [Path to lvmetad pidfile.])
-else
-	DEFAULT_USE_LVMETAD=0
-fi
-AC_DEFINE_UNQUOTED(DEFAULT_USE_LVMETAD, [$DEFAULT_USE_LVMETAD],
-		   [Use lvmetad by default.])
-
 ################################################################################
 dnl -- Build lvmpolld
 AC_MSG_CHECKING(whether to build lvmpolld)
@@ -1115,43 +1090,59 @@ AC_MSG_RESULT($LVMPOLLD)
 
 BUILD_LVMPOLLD=$LVMPOLLD
 
-if test "$BUILD_LVMPOLLD" = yes; then
-	AC_MSG_CHECKING([defaults for use_lvmpolld])
-	AC_ARG_ENABLE(use_lvmpolld,
-		      AC_HELP_STRING([--disable-use-lvmpolld],
-				     [disable usage of LVM Poll Daemon]),
-		      [case ${enableval} in
-		       yes) DEFAULT_USE_LVMPOLLD=1 ;;
-		       *) DEFAULT_USE_LVMPOLLD=0 ;;
-		       esac], DEFAULT_USE_LVMPOLLD=1)
-	AC_MSG_RESULT($DEFAULT_USE_LVMPOLLD)
-	AC_DEFINE([LVMPOLLD_SUPPORT], 1, [Define to 1 to include code that uses lvmpolld.])
+################################################################################
+dnl -- Build lockdsanlock
+AC_MSG_CHECKING(whether to build lockdsanlock)
+AC_ARG_ENABLE(lockd-sanlock,
+	      AC_HELP_STRING([--enable-lockd-sanlock],
+			     [enable the LVM lock daemon using sanlock]),
+	      LOCKDSANLOCK=$enableval)
+AC_MSG_RESULT($LOCKDSANLOCK)
 
-	AC_ARG_WITH(lvmpolld-pidfile,
-		    AC_HELP_STRING([--with-lvmpolld-pidfile=PATH],
-				   [lvmpolld pidfile [PID_DIR/lvmpolld.pid]]),
-		    LVMPOLLD_PIDFILE=$withval,
-		    LVMPOLLD_PIDFILE="$DEFAULT_PID_DIR/lvmpolld.pid")
-	AC_DEFINE_UNQUOTED(LVMPOLLD_PIDFILE, ["$LVMPOLLD_PIDFILE"],
-			   [Path to lvmpolld pidfile.])
-else
-	DEFAULT_USE_LVMPOLLD=0
+BUILD_LOCKDSANLOCK=$LOCKDSANLOCK
+
+if test "$BUILD_LOCKDSANLOCK" = yes; then
+	AC_DEFINE([LOCKDSANLOCK_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd sanlock option.])
+fi
+
+################################################################################
+dnl -- Look for sanlock libraries
+if test "$BUILD_LOCKDSANLOCK" = yes; then
+	PKG_CHECK_MODULES(LOCKD_SANLOCK, libsanlock_client, [HAVE_LOCKD_SANLOCK=yes], $bailout)
+	BUILD_LVMLOCKD=yes
+fi
+
+################################################################################
+dnl -- Build lockddlm
+AC_MSG_CHECKING(whether to build lockddlm)
+AC_ARG_ENABLE(lockd-dlm,
+	      AC_HELP_STRING([--enable-lockd-dlm],
+			     [enable the LVM lock daemon using dlm]),
+	      LOCKDDLM=$enableval)
+AC_MSG_RESULT($LOCKDDLM)
+
+BUILD_LOCKDDLM=$LOCKDDLM
+
+if test "$BUILD_LOCKDDLM" = yes; then
+	AC_DEFINE([LOCKDDLM_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd dlm option.])
+fi
+
+################################################################################
+dnl -- Look for dlm libraries
+if test "$BUILD_LOCKDDLM" = yes; then
+	PKG_CHECK_MODULES(LOCKD_DLM, libdlm, [HAVE_LOCKD_DLM=yes], $bailout)
+	BUILD_LVMLOCKD=yes
 fi
-AC_DEFINE_UNQUOTED(DEFAULT_USE_LVMPOLLD, [$DEFAULT_USE_LVMPOLLD],
-		   [Use lvmpolld by default.])
 
 ################################################################################
 dnl -- Build lvmlockd
-AC_MSG_CHECKING(whether to build lvmlockd)
-AC_ARG_ENABLE(lvmlockd,
-	      AC_HELP_STRING([--enable-lvmlockd],
-			     [enable the LVM lock daemon]),
-	      LVMLOCKD=$enableval)
-AC_MSG_RESULT($LVMLOCKD)
 
-BUILD_LVMLOCKD=$LVMLOCKD
+AC_MSG_CHECKING(whether to build lvmlockd)
+AC_MSG_RESULT($BUILD_LVMLOCKD)
 
 if test "$BUILD_LVMLOCKD" = yes; then
+	AS_IF([test -n "$BUILD_LVMPOLLD"], [BUILD_LVMPOLLD=yes; AC_MSG_WARN([Enabling lvmpolld - required by lvmlockd.])])
+	AS_IF([test -n "$BUILD_LVMETAD"], [BUILD_LVMETAD=yes; AC_MSG_WARN([Enabling lvmetad - required by lvmlockd.])])
 	AC_MSG_CHECKING([defaults for use_lvmlockd])
 	AC_ARG_ENABLE(use_lvmlockd,
 		      AC_HELP_STRING([--disable-use-lvmlockd],
@@ -1177,46 +1168,58 @@ AC_DEFINE_UNQUOTED(DEFAULT_USE_LVMLOCKD, [$DEFAULT_USE_LVMLOCKD],
 		   [Use lvmlockd by default.])
 
 ################################################################################
-dnl -- Build lockdsanlock
-AC_MSG_CHECKING(whether to build lockdsanlock)
-AC_ARG_ENABLE(lockd-sanlock,
-	      AC_HELP_STRING([--enable-lockd-sanlock],
-			     [enable the LVM lock daemon sanlock option]),
-	      LOCKDSANLOCK=$enableval)
-AC_MSG_RESULT($LOCKDSANLOCK)
-
-BUILD_LOCKDSANLOCK=$LOCKDSANLOCK
-
-if test "$BUILD_LOCKDSANLOCK" = yes; then
-	AC_DEFINE([LOCKDSANLOCK_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd sanlock option.])
-fi
-
-################################################################################
-dnl -- Build lockddlm
-AC_MSG_CHECKING(whether to build lockddlm)
-AC_ARG_ENABLE(lockd-dlm,
-	      AC_HELP_STRING([--enable-lockd-dlm],
-			     [enable the LVM lock daemon dlm option]),
-	      LOCKDDLM=$enableval)
-AC_MSG_RESULT($LOCKDDLM)
-
-BUILD_LOCKDDLM=$LOCKDDLM
+dnl -- Check lvmetad
+if test "$BUILD_LVMETAD" = yes; then
+	AC_MSG_CHECKING([defaults for use_lvmetad])
+	AC_ARG_ENABLE(use_lvmetad,
+		      AC_HELP_STRING([--disable-use-lvmetad],
+				     [disable usage of LVM Metadata Daemon]),
+		      [case ${enableval} in
+		       yes) DEFAULT_USE_LVMETAD=1 ;;
+		       *) DEFAULT_USE_LVMETAD=0 ;;
+		       esac], DEFAULT_USE_LVMETAD=1)
+	AC_MSG_RESULT($DEFAULT_USE_LVMETAD)
+	AC_DEFINE([LVMETAD_SUPPORT], 1, [Define to 1 to include code that uses lvmetad.])
 
-if test "$BUILD_LOCKDDLM" = yes; then
-	AC_DEFINE([LOCKDDLM_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd dlm option.])
+	AC_ARG_WITH(lvmetad-pidfile,
+		    AC_HELP_STRING([--with-lvmetad-pidfile=PATH],
+				   [lvmetad pidfile [PID_DIR/lvmetad.pid]]),
+		    LVMETAD_PIDFILE=$withval,
+		    LVMETAD_PIDFILE="$DEFAULT_PID_DIR/lvmetad.pid")
+	AC_DEFINE_UNQUOTED(LVMETAD_PIDFILE, ["$LVMETAD_PIDFILE"],
+			   [Path to lvmetad pidfile.])
+else
+	DEFAULT_USE_LVMETAD=0
 fi
+AC_DEFINE_UNQUOTED(DEFAULT_USE_LVMETAD, [$DEFAULT_USE_LVMETAD],
+		   [Use lvmetad by default.])
 
 ################################################################################
-dnl -- Look for sanlock libraries
-if test "$BUILD_LOCKDSANLOCK" = yes; then
-	PKG_CHECK_MODULES(LOCKD_SANLOCK, libsanlock_client, [HAVE_LOCKD_SANLOCK=yes], $bailout)
-fi
+dnl -- Check lvmpolld
+if test "$BUILD_LVMPOLLD" = yes; then
+	AC_MSG_CHECKING([defaults for use_lvmpolld])
+	AC_ARG_ENABLE(use_lvmpolld,
+		      AC_HELP_STRING([--disable-use-lvmpolld],
+				     [disable usage of LVM Poll Daemon]),
+		      [case ${enableval} in
+		       yes) DEFAULT_USE_LVMPOLLD=1 ;;
+		       *) DEFAULT_USE_LVMPOLLD=0 ;;
+		       esac], DEFAULT_USE_LVMPOLLD=1)
+	AC_MSG_RESULT($DEFAULT_USE_LVMPOLLD)
+	AC_DEFINE([LVMPOLLD_SUPPORT], 1, [Define to 1 to include code that uses lvmpolld.])
 
-################################################################################
-dnl -- Look for dlm libraries
-if test "$BUILD_LOCKDDLM" = yes; then
-	PKG_CHECK_MODULES(LOCKD_DLM, libdlm, [HAVE_LOCKD_DLM=yes], $bailout)
+	AC_ARG_WITH(lvmpolld-pidfile,
+		    AC_HELP_STRING([--with-lvmpolld-pidfile=PATH],
+				   [lvmpolld pidfile [PID_DIR/lvmpolld.pid]]),
+		    LVMPOLLD_PIDFILE=$withval,
+		    LVMPOLLD_PIDFILE="$DEFAULT_PID_DIR/lvmpolld.pid")
+	AC_DEFINE_UNQUOTED(LVMPOLLD_PIDFILE, ["$LVMPOLLD_PIDFILE"],
+			   [Path to lvmpolld pidfile.])
+else
+	DEFAULT_USE_LVMPOLLD=0
 fi
+AC_DEFINE_UNQUOTED(DEFAULT_USE_LVMPOLLD, [$DEFAULT_USE_LVMPOLLD],
+		   [Use lvmpolld by default.])
 
 ################################################################################
 
@@ -2072,13 +2075,3 @@ AS_IF([test -n "$CACHE_CONFIGURE_WARN"],
 
 AS_IF([test "$ODIRECT" != yes],
       [AC_MSG_WARN([O_DIRECT disabled: low-memory pvmove may lock up])])
-
-AS_IF([test "$BUILD_LVMLOCKD" == yes && test "$BUILD_LVMPOLLD" == no],
-      [AC_MSG_WARN([lvmlockd requires lvmpolld])])
-
-AS_IF([test "$BUILD_LVMLOCKD" == yes && test "$BUILD_LVMETAD" == no],
-      [AC_MSG_WARN([lvmlockd requires lvmetad])])
-
-AS_IF([test "$BUILD_LVMLOCKD" == yes && test "$BUILD_LOCKDDLM" == no && test "$BUILD_LOCKDSANLOCK" == no],
-      [AC_MSG_WARN([lvmlockd requires enabling sanlock or dlm or both])])
-
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 89b7a7b..57de7a2 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -410,7 +410,7 @@
 /* Define to 1 if you have the `strtoul' function. */
 #undef HAVE_STRTOUL
 
-/* Define to 1 if `st_rdev' is a member of `struct stat'. */
+/* Define to 1 if `st_rdev' is member of `struct stat'. */
 #undef HAVE_STRUCT_STAT_ST_RDEV
 
 /* Define to 1 if you have the <syslog.h> header file. */
@@ -520,6 +520,12 @@
 /* Locale-dependent data */
 #undef LOCALEDIR
 
+/* Define to 1 to include code that uses lvmlockd dlm option. */
+#undef LOCKDDLM_SUPPORT
+
+/* Define to 1 to include code that uses lvmlockd sanlock option. */
+#undef LOCKDSANLOCK_SUPPORT
+
 /* Define to 1 if `lstat' dereferences a symlink specified with a trailing
    slash. */
 #undef LSTAT_FOLLOWS_SLASHED_SYMLINK
@@ -581,9 +587,6 @@
 /* Define to the one symbol short name of this package. */
 #undef PACKAGE_TARNAME
 
-/* Define to the home page for this package. */
-#undef PACKAGE_URL
-
 /* Define to the version of this package. */
 #undef PACKAGE_VERSION
 


