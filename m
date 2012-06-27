From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 27 Jun 2012 10:12:58 +0000 (UTC)
Subject: master - configure: autoreconf
Message-ID: <20120627101258.EDF44171E@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5723db017ab62c40697329e1725ecb3b32b4d217
Commit:        5723db017ab62c40697329e1725ecb3b32b4d217
Parent:        e6f8d86409e54300aeda05a82aad9b072d22ed4d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 21 08:43:38 2012 -0400
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 27 12:12:08 2012 +0200

configure: autoreconf

---
 configure |  144 ++++++++++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 110 insertions(+), 34 deletions(-)

diff --git a/configure b/configure
index 1bddccc..e54efd3 100755
--- a/configure
+++ b/configure
@@ -605,9 +605,11 @@ kernelvsn
 missingkernel
 kerneldir
 interface
+LVMETAD_PIDFILE
 DMEVENTD_PIDFILE
 WRITE_INSTALL
 UDEV_HAS_BUILTIN_BLKID
+UDEV_RULE_EXEC_DETECTION
 UDEV_SYNC
 UDEV_RULES
 UDEV_PC
@@ -659,6 +661,7 @@ DMEVENTD
 DL_LIBS
 DEVMAPPER
 DEFAULT_RUN_DIR
+DEFAULT_DM_RUN_DIR
 DEFAULT_LOCK_DIR
 DEFAULT_DATA_ALIGNMENT
 DEFAULT_CACHE_SUBDIR
@@ -814,6 +817,9 @@ enable_readline
 enable_realtime
 enable_ocf
 with_ocfdir
+with_default_pid_dir
+with_default_dm_run_dir
+with_default_run_dir
 with_clvmd
 with_clvmd_pidfile
 enable_cmirrord
@@ -825,8 +831,10 @@ enable_testing
 enable_valgrind_pool
 enable_devmapper
 enable_lvmetad
+with_lvmetad_pidfile
 enable_udev_sync
 enable_udev_rules
+enable_udev_rule_exec_detection
 enable_compat
 enable_units_compat
 enable_ioctl
@@ -850,7 +858,6 @@ with_systemdsystemunitdir
 with_tmpfilesdir
 with_dmeventd_pidfile
 with_dmeventd_path
-with_default_run_dir
 with_default_system_dir
 with_default_archive_subdir
 with_default_backup_subdir
@@ -1525,6 +1532,8 @@ Optional Features:
   --enable-lvmetad        enable the LVM Metadata Daemon
   --enable-udev_sync      enable synchronisation with udev processing
   --enable-udev_rules     install rule files needed for udev synchronisation
+  --enable-udev-rule-exec-detection
+                          enable executable path detection in udev rules
   --enable-compat         enable support for old device-mapper versions
   --enable-units-compat   enable output compatibility with old versions that
                           that do not use KiB-style unit suffixes
@@ -1571,6 +1580,12 @@ Optional Packages:
   --with-thin-check=PATH  thin_check tool: [[autodetect]]
   --with-ocfdir=DIR       install OCF files in DIR
                           [[PREFIX/lib/ocf/resource.d/lvm2]]
+  --with-default-pid-dir=PID_DIR
+                          Default directory to keep PID files in. [[/var/run]]
+  --with-default-dm-run-dir=DM_RUN_DIR
+                          Default DM run directory. [[/var/run]]
+  --with-default-run-dir=RUN_DIR
+                          Default LVM run directory. [[/var/run/lvm]]
   --with-clvmd=TYPE       build cluster LVM Daemon
                           The following cluster manager combinations are valid:
                            * cman                  (RHEL5 or equivalent)
@@ -1580,10 +1595,12 @@ Optional Packages:
                            * none                  (disable build)
                           [TYPE=none]
   --with-clvmd-pidfile=PATH
-                          clvmd pidfile [[/var/run/clvmd.pid]]
+                          clvmd pidfile [[PID_DIR/clvmd.pid]]
   --with-cmirrord-pidfile=PATH
-                          cmirrord pidfile [[/var/run/cmirrord.pid]]
+                          cmirrord pidfile [[PID_DIR/cmirrord.pid]]
   --with-optimisation=OPT C optimisation flag [[OPT=-O2]]
+  --with-lvmetad-pidfile=PATH
+                          lvmetad pidfile [[PID_DIR/lvmetad.pid]]
   --with-localedir=DIR    translation files in DIR [[PREFIX/share/locale]]
   --with-confdir=DIR      configuration files in DIR [[/etc]]
   --with-staticdir=DIR    static binaries in DIR [[EPREFIX/sbin]]
@@ -1598,10 +1615,9 @@ Optional Packages:
                           volatile files and directories in DIR
                           [[SYSCONFDIR/tmpfiles.d]]
   --with-dmeventd-pidfile=PATH
-                          dmeventd pidfile [[/var/run/dmeventd.pid]]
+                          dmeventd pidfile [[PID_DIR/dmeventd.pid]]
   --with-dmeventd-path=PATH
                           dmeventd path [[EPREFIX/sbin/dmeventd]]
-  --with-default-run-dir=DIR       Default run directory [/var/run/lvm]
   --with-default-system-dir=DIR
                           default LVM system directory [[/etc/lvm]]
   --with-default-archive-subdir=SUBDIR
@@ -7315,6 +7331,52 @@ fi
 }
 
 ################################################################################
+
+
+# Check whether --with-default-pid-dir was given.
+if test "${with_default_pid_dir+set}" = set; then :
+  withval=$with_default_pid_dir; DEFAULT_PID_DIR="$withval"
+else
+  DEFAULT_PID_DIR="/var/run"
+fi
+
+
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_PID_DIR "$DEFAULT_PID_DIR"
+_ACEOF
+
+
+
+
+# Check whether --with-default-dm-run-dir was given.
+if test "${with_default_dm_run_dir+set}" = set; then :
+  withval=$with_default_dm_run_dir; DEFAULT_DM_RUN_DIR="$withval"
+else
+  DEFAULT_DM_RUN_DIR="/var/run"
+fi
+
+
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_DM_RUN_DIR "$DEFAULT_DM_RUN_DIR"
+_ACEOF
+
+
+
+
+# Check whether --with-default-run-dir was given.
+if test "${with_default_run_dir+set}" = set; then :
+  withval=$with_default_run_dir; DEFAULT_RUN_DIR="$withval"
+else
+  DEFAULT_RUN_DIR="/var/run/lvm"
+fi
+
+
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_RUN_DIR "$DEFAULT_RUN_DIR"
+_ACEOF
+
+
+################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build cluster LVM daemon" >&5
 $as_echo_n "checking whether to build cluster LVM daemon... " >&6; }
 
@@ -8217,7 +8279,7 @@ if test "x$CLVMD" != xnone; then
 if test "${with_clvmd_pidfile+set}" = set; then :
   withval=$with_clvmd_pidfile; CLVMD_PIDFILE=$withval
 else
-  CLVMD_PIDFILE="/var/run/clvmd.pid"
+  CLVMD_PIDFILE="$DEFAULT_PID_DIR/clvmd.pid"
 fi
 
 
@@ -8249,7 +8311,7 @@ if test "x$BUILD_CMIRRORD" = xyes; then
 if test "${with_cmirrord_pidfile+set}" = set; then :
   withval=$with_cmirrord_pidfile; CMIRRORD_PIDFILE=$withval
 else
-  CMIRRORD_PIDFILE="/var/run/cmirrord.pid"
+  CMIRRORD_PIDFILE="$DEFAULT_PID_DIR/cmirrord.pid"
 fi
 
 
@@ -8801,6 +8863,20 @@ if test x$BUILD_LVMETAD = xyes; then
 
 $as_echo "#define LVMETAD_SUPPORT 1" >>confdefs.h
 
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
 fi
 
 ################################################################################
@@ -8928,18 +9004,28 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $UDEV_RULES" >&5
 $as_echo "$UDEV_RULES" >&6; }
 
-if test x$UDEV_RULES = xyes; then
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether udev supports builtin blkid" >&5
-$as_echo_n "checking whether udev supports builtin blkid... " >&6; }
-	udev_version=$(udevadm info --version 2>/dev/null)
-	if test -n "$udev_version" && test "$udev_version" -ge 176; then
-		UDEV_HAS_BUILTIN_BLKID=yes
-	else
-		UDEV_HAS_BUILTIN_BLKID=no
-	fi
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $UDEV_HAS_BUILTIN_BLKID" >&5
-$as_echo "$UDEV_HAS_BUILTIN_BLKID" >&6; }
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable executable path detection in udev rules" >&5
+$as_echo_n "checking whether to enable executable path detection in udev rules... " >&6; }
+# Check whether --enable-udev_rule_exec_detection was given.
+if test "${enable_udev_rule_exec_detection+set}" = set; then :
+  enableval=$enable_udev_rule_exec_detection; UDEV_RULE_EXEC_DETECTION=$enableval
+else
+  UDEV_RULE_EXEC_DETECTION=no
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $UDEV_RULE_EXEC_DETECTION" >&5
+$as_echo "$UDEV_RULE_EXEC_DETECTION" >&6; }
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether udev supports built-in blkid" >&5
+$as_echo_n "checking whether udev supports built-in blkid... " >&6; }
+test x$PKGCONFIG_INIT != x1 && pkg_config_init
+if $($PKG_CONFIG --atleast-version=176 libudev); then
+	UDEV_HAS_BUILTIN_BLKID=yes
+else
+	UDEV_HAS_BUILTIN_BLKID=no
 fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $UDEV_HAS_BUILTIN_BLKID" >&5
+$as_echo "$UDEV_HAS_BUILTIN_BLKID" >&6; }
 
 ################################################################################
 # Check whether --enable-compat was given.
@@ -10211,7 +10297,7 @@ if test "$BUILD_DMEVENTD" = yes; then
 if test "${with_dmeventd_pidfile+set}" = set; then :
   withval=$with_dmeventd_pidfile; DMEVENTD_PIDFILE=$withval
 else
-  DMEVENTD_PIDFILE="/var/run/dmeventd.pid"
+  DMEVENTD_PIDFILE="$DEFAULT_PID_DIR/dmeventd.pid"
 fi
 
 
@@ -10237,20 +10323,6 @@ _ACEOF
 
 fi
 
-
-
-# Check whether --with-default-run-dir was given.
-if test "${with_default_run_dir+set}" = set; then :
-  withval=$with_default_run_dir;  DEFAULT_RUN_DIR="$withval"
-else
-   DEFAULT_RUN_DIR="/var/run/lvm"
-fi
-
-cat >>confdefs.h <<_ACEOF
-#define DEFAULT_RUN_DIR "$DEFAULT_RUN_DIR"
-_ACEOF
-
-
 ################################################################################
 
 # Check whether --with-default-system-dir was given.
@@ -10491,8 +10563,11 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
+
+
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_l
 vmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_l
 vmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.socket scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -11224,6 +11299,7 @@ do
     "scripts/lvm2_lvmetad_systemd_red_hat.socket") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_systemd_red_hat.socket" ;;
     "scripts/lvm2_lvmetad_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_systemd_red_hat.service" ;;
     "scripts/lvm2_monitoring_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_monitoring_init_red_hat" ;;
+    "scripts/dm_event_systemd_red_hat.socket") CONFIG_FILES="$CONFIG_FILES scripts/dm_event_systemd_red_hat.socket" ;;
     "scripts/dm_event_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/dm_event_systemd_red_hat.service" ;;
     "scripts/lvm2_monitoring_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_monitoring_systemd_red_hat.service" ;;
     "scripts/lvm2_tmpfiles_red_hat.conf") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_tmpfiles_red_hat.conf" ;;


