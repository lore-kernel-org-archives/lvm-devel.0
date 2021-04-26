From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon, 26 Apr 2021 12:27:42 +0000 (GMT)
Subject: dev-next - configure: update
Message-ID: <20210426122742.AE371385800A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2db6ceadaae0ead9e2ae917d572c0f64bcbaa314
Commit:        2db6ceadaae0ead9e2ae917d572c0f64bcbaa314
Parent:        dab7b1e13d81f286e5228feecfb7475ff855d4ce
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Apr 26 14:27:05 2021 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Apr 26 14:27:05 2021 +0200

configure: update

---
 configure              | 108 ++++++++++++++++++++++++++++++++++++++++++++++++-
 include/configure.h.in |   3 ++
 2 files changed, 110 insertions(+), 1 deletion(-)

diff --git a/configure b/configure
index 95c1d2758..5c74fa24c 100755
--- a/configure
+++ b/configure
@@ -772,6 +772,8 @@ SYSTEMD_LIBS
 SYSTEMD_CFLAGS
 BLKID_LIBS
 BLKID_CFLAGS
+APP_MACHINEID_LIBS
+APP_MACHINEID_CFLAGS
 NOTIFY_DBUS_LIBS
 NOTIFY_DBUS_CFLAGS
 LOCKD_DLM_CONTROL_LIBS
@@ -950,6 +952,7 @@ enable_use_lvmpolld
 with_lvmpolld_pidfile
 enable_dmfilemapd
 enable_notify_dbus
+enable_app_machineid
 enable_blkid_wiping
 enable_udev_systemd_background_jobs
 enable_udev_sync
@@ -1019,6 +1022,8 @@ LOCKD_DLM_CONTROL_CFLAGS
 LOCKD_DLM_CONTROL_LIBS
 NOTIFY_DBUS_CFLAGS
 NOTIFY_DBUS_LIBS
+APP_MACHINEID_CFLAGS
+APP_MACHINEID_LIBS
 BLKID_CFLAGS
 BLKID_LIBS
 SYSTEMD_CFLAGS
@@ -1680,6 +1685,7 @@ Optional Features:
   --disable-use-lvmpolld  disable usage of LVM Poll Daemon
   --enable-dmfilemapd     enable the dmstats filemap daemon
   --enable-notify-dbus    enable LVM notification using dbus
+  --enable-app-machineid  enable LVM system ID using app-specific machine-id
   --disable-blkid_wiping  disable libblkid detection of signatures when wiping
                           and use native code instead
   --disable-udev-systemd-background-jobs
@@ -1834,6 +1840,10 @@ Some influential environment variables:
               C compiler flags for NOTIFY_DBUS, overriding pkg-config
   NOTIFY_DBUS_LIBS
               linker flags for NOTIFY_DBUS, overriding pkg-config
+  APP_MACHINEID_CFLAGS
+              C compiler flags for APP_MACHINEID, overriding pkg-config
+  APP_MACHINEID_LIBS
+              linker flags for APP_MACHINEID, overriding pkg-config
   BLKID_CFLAGS
               C compiler flags for BLKID, overriding pkg-config
   BLKID_LIBS  linker flags for BLKID, overriding pkg-config
@@ -11407,6 +11417,101 @@ $as_echo "yes" >&6; }
 fi
 fi
 
+################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build appmachineid" >&5
+$as_echo_n "checking whether to build appmachineid... " >&6; }
+# Check whether --enable-app-machineid was given.
+if test "${enable_app_machineid+set}" = set; then :
+  enableval=$enable_app_machineid; APP_MACHINEID_SUPPORT=$enableval
+else
+  APP_MACHINEID_SUPPORT=no
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $APP_MACHINEID_SUPPORT" >&5
+$as_echo "$APP_MACHINEID_SUPPORT" >&6; }
+
+if test "$APP_MACHINEID_SUPPORT" = yes; then
+
+$as_echo "#define APP_MACHINEID_SUPPORT 1" >>confdefs.h
+
+	SYSTEMD_LIBS="-lsystemd"
+fi
+
+################################################################################
+if test "$APP_MACHINEID_SUPPORT" = yes; then
+
+pkg_failed=no
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for APP_MACHINEID" >&5
+$as_echo_n "checking for APP_MACHINEID... " >&6; }
+
+if test -n "$APP_MACHINEID_CFLAGS"; then
+    pkg_cv_APP_MACHINEID_CFLAGS="$APP_MACHINEID_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 234\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "systemd >= 234") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_APP_MACHINEID_CFLAGS=`$PKG_CONFIG --cflags "systemd >= 234" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$APP_MACHINEID_LIBS"; then
+    pkg_cv_APP_MACHINEID_LIBS="$APP_MACHINEID_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 234\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "systemd >= 234") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_APP_MACHINEID_LIBS=`$PKG_CONFIG --libs "systemd >= 234" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+
+
+
+if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+
+if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
+        _pkg_short_errors_supported=yes
+else
+        _pkg_short_errors_supported=no
+fi
+        if test $_pkg_short_errors_supported = yes; then
+	        APP_MACHINEID_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "systemd >= 234" 2>&1`
+        else
+	        APP_MACHINEID_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "systemd >= 234" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$APP_MACHINEID_PKG_ERRORS" >&5
+
+	$bailout
+elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+	$bailout
+else
+	APP_MACHINEID_CFLAGS=$pkg_cv_APP_MACHINEID_CFLAGS
+	APP_MACHINEID_LIBS=$pkg_cv_APP_MACHINEID_LIBS
+        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+	HAVE_APP_MACHINEID=yes
+fi
+fi
+
 ################################################################################
 
 # Check whether --enable-blkid_wiping was given.
@@ -14177,7 +14282,7 @@ _ACEOF
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl libdm/make.tmpl daemons/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmeventd/plugins/vdo/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/dm-tools/Makefile libdm/libdevmapper.pc man/Makefile po/Makefile scripts/lvm2-pvscan
 .service scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvmlockd.service scripts/lvmlocks.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile tools/Makefile udev/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl libdm/make.tmpl daemons/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmeventd/plugins/vdo/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/dm-tools/Makefile libdm/libdevmapper.pc man/Makefile po/Makefile scripts/lvm2-pvscan
 .service scripts/lvm-vgchange.service scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvmlockd.service scripts/lvmlocks.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile tools/Makefile udev/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -14910,6 +15015,7 @@ do
     "man/Makefile") CONFIG_FILES="$CONFIG_FILES man/Makefile" ;;
     "po/Makefile") CONFIG_FILES="$CONFIG_FILES po/Makefile" ;;
     "scripts/lvm2-pvscan.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2-pvscan.service" ;;
+    "scripts/lvm-vgchange.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm-vgchange.service" ;;
     "scripts/blkdeactivate.sh") CONFIG_FILES="$CONFIG_FILES scripts/blkdeactivate.sh" ;;
     "scripts/blk_availability_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/blk_availability_init_red_hat" ;;
     "scripts/blk_availability_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/blk_availability_systemd_red_hat.service" ;;
diff --git a/include/configure.h.in b/include/configure.h.in
index 671d201b2..c68052592 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -1,5 +1,8 @@
 /* include/configure.h.in.  Generated from configure.ac by autoheader.  */
 
+/* Define to 1 to include code that uses libsystemd machine-id apis. */
+#undef APP_MACHINEID_SUPPORT
+
 /* Define to 1 to use libblkid detection of signatures when wiping. */
 #undef BLKID_WIPING_SUPPORT
 


