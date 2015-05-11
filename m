From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 11 May 2015 12:41:18 +0000 (UTC)
Subject: master - configure: use_lvmetad/polld configurable
Message-ID: <20150511124118.E00A8603E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=725136b57eef7a61e506a445d43e6632882dc0bf
Commit:        725136b57eef7a61e506a445d43e6632882dc0bf
Parent:        18066949282613fad1981804297b3bba01bcc3bd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 11 13:49:41 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 11 14:36:10 2015 +0200

configure: use_lvmetad/polld configurable

Configure provides proper settings for
use_lvmetad  and use_lvmpolld  conf setttings.

When the build of polld & lvmetad, these settings
are enabled by default unless explicitelly disabled
with --disable-use-lvmetad/--disable-use-lvmpolld.
---
 WHATS_NEW                    |    1 +
 conf/example.conf.in         |    4 +-
 configure                    |   50 ++++++++++++++++++++++++++++++++++++++++++
 configure.in                 |   28 +++++++++++++++++++++++
 lib/config/config_settings.h |    4 +-
 lib/misc/configure.h.in      |    6 +++++
 6 files changed, 89 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7052016..e4fe6b6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.120 -
 ===============================
+  Configure lvm.conf for use_lvmetad and use_lvmpolld.
   Add lvpoll for cmdline communication with lvmpolld.
   Add lvmpolld acting as a free-standing version of polldaemon.
   Properly validate PV size for pvcreate --restorefile.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index e16aa7f..843e62d 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -820,7 +820,7 @@ global {
 	# lvmetad is not compatible with locking_type 3 (clustering).
 	# LVM prints warnings and ignores lvmetad if this combination
 	# is seen.
-	use_lvmetad = 0
+	use_lvmetad = @DEFAULT_USE_LVMETAD@
 
 	# Configuration option global/thin_check_executable.
 	# The full path to the thin_check command.
@@ -947,7 +947,7 @@ global {
 	# spawned in lvmpolld's service cgroup.
 	#
 	# When set to 0 lvm falls back to classical polling.
-	use_lvmpolld = 0
+	use_lvmpolld = @DEFAULT_USE_LVMPOLLD@
 }
 
 # Configuration section activation.
diff --git a/configure b/configure
index 8c51c71..7c1ffe0 100755
--- a/configure
+++ b/configure
@@ -700,6 +700,8 @@ DMEVENTD_PATH
 DMEVENTD
 DL_LIBS
 DEVMAPPER
+DEFAULT_USE_LVMPOLLD
+DEFAULT_USE_LVMETAD
 DEFAULT_SYS_DIR
 DEFAULT_SPARSE_SEGTYPE
 DEFAULT_RUN_DIR
@@ -915,8 +917,10 @@ enable_testing
 enable_valgrind_pool
 enable_devmapper
 enable_lvmetad
+enable_use_lvmetad
 with_lvmetad_pidfile
 enable_lvmpolld
+enable_use_lvmpolld
 with_lvmpolld_pidfile
 enable_blkid_wiping
 enable_udev_systemd_background_jobs
@@ -1631,7 +1635,9 @@ Optional Features:
   --enable-valgrind-pool  enable valgrind awareness of pools
   --disable-devmapper     disable LVM2 device-mapper interaction
   --enable-lvmetad        enable the LVM Metadata Daemon
+  --disable-use-lvmetad   disable usage of LVM Metadata Daemon
   --enable-lvmpolld       enable the LVM Polling Daemon
+  --disable-use-lvmpolld  disable usage of LVM Poll Daemon
   --disable-blkid_wiping  disable libblkid detection of signatures when wiping
                           and use native code instead
   --disable-udev-systemd-background-jobs
@@ -10844,6 +10850,20 @@ $as_echo "$LVMETAD" >&6; }
 BUILD_LVMETAD=$LVMETAD
 
 if test "$BUILD_LVMETAD" = yes; then
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
 
 $as_echo "#define LVMETAD_SUPPORT 1" >>confdefs.h
 
@@ -10861,8 +10881,15 @@ cat >>confdefs.h <<_ACEOF
 #define LVMETAD_PIDFILE "$LVMETAD_PIDFILE"
 _ACEOF
 
+else
+	DEFAULT_USE_LVMETAD=0
 fi
 
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_USE_LVMETAD $DEFAULT_USE_LVMETAD
+_ACEOF
+
+
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build lvmpolld" >&5
 $as_echo_n "checking whether to build lvmpolld... " >&6; }
@@ -10877,6 +10904,20 @@ $as_echo "$LVMPOLLD" >&6; }
 BUILD_LVMPOLLD=$LVMPOLLD
 
 if test "$BUILD_LVMPOLLD" = yes; then
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
 
 $as_echo "#define LVMPOLLD_SUPPORT 1" >>confdefs.h
 
@@ -10894,8 +10935,15 @@ cat >>confdefs.h <<_ACEOF
 #define LVMPOLLD_PIDFILE "$LVMPOLLD_PIDFILE"
 _ACEOF
 
+else
+	DEFAULT_USE_LVMPOLLD=0
 fi
 
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_USE_LVMPOLLD $DEFAULT_USE_LVMPOLLD
+_ACEOF
+
+
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable libblkid detection of signatures when wiping" >&5
 $as_echo_n "checking whether to enable libblkid detection of signatures when wiping... " >&6; }
@@ -13190,6 +13238,8 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile daemons/lvmpolld/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile 
 liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/
 Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
diff --git a/configure.in b/configure.in
index 1887757..83358f5 100644
--- a/configure.in
+++ b/configure.in
@@ -1067,6 +1067,15 @@ AC_MSG_RESULT($LVMETAD)
 BUILD_LVMETAD=$LVMETAD
 
 if test "$BUILD_LVMETAD" = yes; then
+	AC_MSG_CHECKING([defaults for use_lvmetad])
+	AC_ARG_ENABLE(use_lvmetad,
+		      AC_HELP_STRING([--disable-use-lvmetad],
+				     [disable usage of LVM Metadata Daemon]),
+		      [case ${enableval} in
+		       yes) DEFAULT_USE_LVMETAD=1 ;;
+		       *) DEFAULT_USE_LVMETAD=0 ;;
+		       esac], DEFAULT_USE_LVMETAD=1)
+	AC_MSG_RESULT($DEFAULT_USE_LVMETAD)
 	AC_DEFINE([LVMETAD_SUPPORT], 1, [Define to 1 to include code that uses lvmetad.])
 
 	AC_ARG_WITH(lvmetad-pidfile,
@@ -1076,7 +1085,11 @@ if test "$BUILD_LVMETAD" = yes; then
 		    LVMETAD_PIDFILE="$DEFAULT_PID_DIR/lvmetad.pid")
 	AC_DEFINE_UNQUOTED(LVMETAD_PIDFILE, ["$LVMETAD_PIDFILE"],
 			   [Path to lvmetad pidfile.])
+else
+	DEFAULT_USE_LVMETAD=0
 fi
+AC_DEFINE_UNQUOTED(DEFAULT_USE_LVMETAD, [$DEFAULT_USE_LVMETAD],
+		   [Use lvmetad by default.])
 
 ################################################################################
 dnl -- Build lvmpolld
@@ -1090,6 +1103,15 @@ AC_MSG_RESULT($LVMPOLLD)
 BUILD_LVMPOLLD=$LVMPOLLD
 
 if test "$BUILD_LVMPOLLD" = yes; then
+	AC_MSG_CHECKING([defaults for use_lvmpolld])
+	AC_ARG_ENABLE(use_lvmpolld,
+		      AC_HELP_STRING([--disable-use-lvmpolld],
+				     [disable usage of LVM Poll Daemon]),
+		      [case ${enableval} in
+		       yes) DEFAULT_USE_LVMPOLLD=1 ;;
+		       *) DEFAULT_USE_LVMPOLLD=0 ;;
+		       esac], DEFAULT_USE_LVMPOLLD=1)
+	AC_MSG_RESULT($DEFAULT_USE_LVMPOLLD)
 	AC_DEFINE([LVMPOLLD_SUPPORT], 1, [Define to 1 to include code that uses lvmpolld.])
 
 	AC_ARG_WITH(lvmpolld-pidfile,
@@ -1099,7 +1121,11 @@ if test "$BUILD_LVMPOLLD" = yes; then
 		    LVMPOLLD_PIDFILE="$DEFAULT_PID_DIR/lvmpolld.pid")
 	AC_DEFINE_UNQUOTED(LVMPOLLD_PIDFILE, ["$LVMPOLLD_PIDFILE"],
 			   [Path to lvmpolld pidfile.])
+else
+	DEFAULT_USE_LVMPOLLD=0
 fi
+AC_DEFINE_UNQUOTED(DEFAULT_USE_LVMPOLLD, [$DEFAULT_USE_LVMPOLLD],
+		   [Use lvmpolld by default.])
 
 ################################################################################
 dnl -- Enable blkid wiping functionality
@@ -1748,6 +1774,8 @@ AC_SUBST(DEFAULT_RAID10_SEGTYPE)
 AC_SUBST(DEFAULT_RUN_DIR)
 AC_SUBST(DEFAULT_SPARSE_SEGTYPE)
 AC_SUBST(DEFAULT_SYS_DIR)
+AC_SUBST(DEFAULT_USE_LVMETAD)
+AC_SUBST(DEFAULT_USE_LVMPOLLD)
 AC_SUBST(DEVMAPPER)
 AC_SUBST(DLM_CFLAGS)
 AC_SUBST(DLM_LIBS)
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 59a7c1c..2bbafc3 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -780,7 +780,7 @@ cfg(global_lvdisplay_shows_full_device_path_CFG, "lvdisplay_shows_full_device_pa
 	"was never a valid path in the /dev filesystem.\n"
 	"Enable this option to reinstate the previous format.\n")
 
-cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 93), NULL, 0, NULL,
+cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_LVMETAD, vsn(2, 2, 93), NULL, 0, NULL,
 	"Use lvmetad to cache metadata and reduce disk scanning.\n"
 	"When enabled (and running), lvmetad provides LVM commands\n"
 	"with VG metadata and PV state.  LVM commands then avoid\n"
@@ -920,7 +920,7 @@ cfg(activation_checks_CFG, "checks", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, D
 	"Some of the checks may be expensive, so it's best to use\n"
 	"this only when there seems to be a problem.\n")
 
-cfg(global_use_lvmpolld_CFG, "use_lvmpolld", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 120), NULL, 0, NULL,
+cfg(global_use_lvmpolld_CFG, "use_lvmpolld", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_LVMPOLLD, vsn(2, 2, 120), NULL, 0, NULL,
 	"Indicates whether to use lvmpolld instead of classical polldaemon (a process\n"
 	"forked off an initiating lvm command) or not. When set to 1 and native systemd\n"
 	"service is installed in the system lvm starts using lvmpolld. lvmpolld gets\n"
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 45a8462..f28cc79 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -95,6 +95,12 @@
 /* Path to LVM system directory. */
 #undef DEFAULT_SYS_DIR
 
+/* Use lvmetad by default. */
+#undef DEFAULT_USE_LVMETAD
+
+/* Use lvmpolld by default. */
+#undef DEFAULT_USE_LVMPOLLD
+
 /* Define to 1 to enable LVM2 device-mapper interaction. */
 #undef DEVMAPPER_SUPPORT
 


