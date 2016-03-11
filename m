From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 11 Mar 2016 00:24:01 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20160311002401.B6F4260D52@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2159a1429d65adb824e67a1577625663d910516e
Commit:        2159a1429d65adb824e67a1577625663d910516e
Parent:        6807eb88634fd0db95cdccbbc65570b2d96c989a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Mar 11 00:19:16 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Mar 11 00:19:16 2016 +0000

pre-release

---
 VERSION                |    2 +-
 VERSION_DM             |    2 +-
 WHATS_NEW              |    4 +-
 WHATS_NEW_DM           |    4 +-
 conf/example.conf.in   |   14 ++++++-
 configure              |  107 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/configure.h.in |    3 +
 lib/device/dev-type.c  |    2 +-
 8 files changed, 130 insertions(+), 8 deletions(-)

diff --git a/VERSION b/VERSION
index 4b10296..dc1b9ea 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.146(2)-git (2016-03-04)
+2.02.146(2)-git (2016-03-11)
diff --git a/VERSION_DM b/VERSION_DM
index 3c381cc..1678ddf 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.120-git (2016-03-04)
+1.02.120-git (2016-03-11)
diff --git a/WHATS_NEW b/WHATS_NEW
index 685cdad..27abb4a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.146 - 
-=================================
+Version 2.02.146 - 11th March 2016
+==================================
   More man page cleanups in lvconvert.
   Fix makefile vpath in /udev when generating udev rules files.
   Another attempt to improve VG name parsing for lvconvert (2.02.144).
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 274d1b9..ec27a19 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.120 - 
-=================================
+Version 1.02.120 - 11th March 2016
+==================================
   Improve parsing of cache status and report Fail, Error, needs_check, ro.
 
 Version 1.02.119 - 4th March 2016
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 975f514..a21dd96 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -525,7 +525,7 @@ log {
 	# debug output if the class is listed here. Classes currently
 	# available: memory, devices, activation, allocation, lvmetad,
 	# metadata, cache, locking, lvmpolld. Use "all" to see everything.
-	debug_classes = [ "memory", "devices", "activation", "allocation", "lvmetad", "metadata", "cache", "locking", "lvmpolld" ]
+	debug_classes = [ "memory", "devices", "activation", "allocation", "lvmetad", "metadata", "cache", "locking", "lvmpolld", "dbus" ]
 }
 
 # Configuration section backup.
@@ -1015,6 +1015,12 @@ global {
 	# and to use its own control group. When this option is disabled, LVM
 	# commands will supervise long running operations by forking themselves.
 	use_lvmpolld = @DEFAULT_USE_LVMPOLLD@
+
+	# Configuration option global/notify_dbus.
+	# Enable D-Bus notification from LVM commands.
+	# When enabled, an LVM command that changes PVs, changes VG metadata,
+	# or changes the activation state of an LV will send a notification.
+	notify_dbus = 1
 }
 
 # Configuration section activation.
@@ -1840,6 +1846,12 @@ activation {
 	# Use brackets [] to mark hidden devices.
 	# This configuration option has an automatic default value.
 	# mark_hidden_devices = 1
+
+	# Configuration option report/two_word_unknown_device.
+	# Use the two words 'unknown device' in place of '[unknown]'.
+	# This is displayed when the device for a PV is not known.
+	# This configuration option has an automatic default value.
+	# two_word_unknown_device = 0
 # }
 
 # Configuration section dmeventd.
diff --git a/configure b/configure
index 75967d7..eb55243 100755
--- a/configure
+++ b/configure
@@ -735,6 +735,7 @@ CLDWHOLEARCHIVE
 CLDNOWHOLEARCHIVE
 CLDFLAGS
 CACHE
+BUILD_NOTIFYDBUS
 BUILD_LOCKDDLM
 BUILD_LOCKDSANLOCK
 BUILD_LVMLOCKD
@@ -767,6 +768,8 @@ SYSTEMD_LIBS
 SYSTEMD_CFLAGS
 BLKID_LIBS
 BLKID_CFLAGS
+NOTIFY_DBUS_LIBS
+NOTIFY_DBUS_CFLAGS
 LOCKD_DLM_LIBS
 LOCKD_DLM_CFLAGS
 LOCKD_SANLOCK_LIBS
@@ -954,6 +957,7 @@ enable_use_lvmetad
 with_lvmetad_pidfile
 enable_use_lvmpolld
 with_lvmpolld_pidfile
+enable_notify_dbus
 enable_blkid_wiping
 enable_udev_systemd_background_jobs
 enable_udev_sync
@@ -1039,6 +1043,8 @@ LOCKD_SANLOCK_CFLAGS
 LOCKD_SANLOCK_LIBS
 LOCKD_DLM_CFLAGS
 LOCKD_DLM_LIBS
+NOTIFY_DBUS_CFLAGS
+NOTIFY_DBUS_LIBS
 BLKID_CFLAGS
 BLKID_LIBS
 SYSTEMD_CFLAGS
@@ -1685,6 +1691,7 @@ Optional Features:
   --disable-use-lvmlockd  disable usage of LVM lock daemon
   --disable-use-lvmetad   disable usage of LVM Metadata Daemon
   --disable-use-lvmpolld  disable usage of LVM Poll Daemon
+  --enable-notify-dbus    enable LVM notification using dbus
   --disable-blkid_wiping  disable libblkid detection of signatures when wiping
                           and use native code instead
   --disable-udev-systemd-background-jobs
@@ -1877,6 +1884,10 @@ Some influential environment variables:
               C compiler flags for LOCKD_DLM, overriding pkg-config
   LOCKD_DLM_LIBS
               linker flags for LOCKD_DLM, overriding pkg-config
+  NOTIFY_DBUS_CFLAGS
+              C compiler flags for NOTIFY_DBUS, overriding pkg-config
+  NOTIFY_DBUS_LIBS
+              linker flags for NOTIFY_DBUS, overriding pkg-config
   BLKID_CFLAGS
               C compiler flags for BLKID, overriding pkg-config
   BLKID_LIBS  linker flags for BLKID, overriding pkg-config
@@ -11817,6 +11828,101 @@ _ACEOF
 
 
 ################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build notifydbus" >&5
+$as_echo_n "checking whether to build notifydbus... " >&6; }
+# Check whether --enable-notify-dbus was given.
+if test "${enable_notify_dbus+set}" = set; then :
+  enableval=$enable_notify_dbus; NOTIFYDBUS=$enableval
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $NOTIFYDBUS" >&5
+$as_echo "$NOTIFYDBUS" >&6; }
+
+BUILD_NOTIFYDBUS=$NOTIFYDBUS
+
+if test "$BUILD_NOTIFYDBUS" = yes; then
+
+$as_echo "#define NOTIFYDBUS_SUPPORT 1" >>confdefs.h
+
+	LIBS="-lsystemd $LIBS"
+fi
+
+################################################################################
+if test "$BUILD_NOTIFYDBUS" = yes; then
+
+pkg_failed=no
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for NOTIFY_DBUS" >&5
+$as_echo_n "checking for NOTIFY_DBUS... " >&6; }
+
+if test -n "$NOTIFY_DBUS_CFLAGS"; then
+    pkg_cv_NOTIFY_DBUS_CFLAGS="$NOTIFY_DBUS_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 221\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "systemd >= 221") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_NOTIFY_DBUS_CFLAGS=`$PKG_CONFIG --cflags "systemd >= 221" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$NOTIFY_DBUS_LIBS"; then
+    pkg_cv_NOTIFY_DBUS_LIBS="$NOTIFY_DBUS_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 221\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "systemd >= 221") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_NOTIFY_DBUS_LIBS=`$PKG_CONFIG --libs "systemd >= 221" 2>/dev/null`
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
+	        NOTIFY_DBUS_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "systemd >= 221" 2>&1`
+        else
+	        NOTIFY_DBUS_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "systemd >= 221" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$NOTIFY_DBUS_PKG_ERRORS" >&5
+
+	$bailout
+elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+	$bailout
+else
+	NOTIFY_DBUS_CFLAGS=$pkg_cv_NOTIFY_DBUS_CFLAGS
+	NOTIFY_DBUS_LIBS=$pkg_cv_NOTIFY_DBUS_LIBS
+        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+	HAVE_NOTIFY_DBUS=yes
+fi
+fi
+
+################################################################################
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable libblkid detection of signatures when wiping" >&5
 $as_echo_n "checking whether to enable libblkid detection of signatures when wiping... " >&6; }
@@ -15225,6 +15331,7 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile include/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile lib
 daemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlock
 ing_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
diff --git a/include/configure.h.in b/include/configure.h.in
index 1681af0..d94d55d 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -631,6 +631,9 @@
 /* The path to 'modprobe', if available. */
 #undef MODPROBE_CMD
 
+/* Define to 1 to include code that uses dbus notification. */
+#undef NOTIFYDBUS_SUPPORT
+
 /* Define to 1 to enable O_DIRECT support. */
 #undef O_DIRECT_SUPPORT
 
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 689809a..f9f1418 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -854,7 +854,7 @@ static unsigned long _dev_topology_attribute(struct dev_types *dt,
 	result = value >> SECTOR_SHIFT;
 
 	if (!result && value) {
-		log_warn("WARNING: Device %s: %s is %lu and is unexpectedly less then sector.",
+		log_warn("WARNING: Device %s: %s is %lu and is unexpectedly less than sector.",
 			 dev_name(dev), attribute, value);
 		result = 1;
 	}


