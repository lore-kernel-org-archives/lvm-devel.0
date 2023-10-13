From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Fri, 13 Oct 2023 23:09:41 +0000
Subject: [Git][lvmteam/lvm2][main] 6 commits: libdm: versionion symbol for enhanced dm_task_run
Message-ID: <6529ce35d80d0_2ca54603563b@gitlab-sidekiq-low-urgency-cpu-bound-v2-59d68cd46b-kcjfh.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
85c76293 by Zdenek Kabelac at 2023-10-14T01:04:10+02:00
libdm: versionion symbol for enhanced dm_task_run

When new app links with current dm_task_run() that propagates ioctl()
errno - ensure it will not be usable with older version without this
supported feature.

- - - - -
46eeb62b by Zdenek Kabelac at 2023-10-14T01:04:10+02:00
pool: fix recalculate of pool chunk_size

Before checking seg_type of the first area, check there is
some existing area.
Since we now support error and zero segtypes, these do not have
any PV area present.

- - - - -
afe1b2be by Zdenek Kabelac at 2023-10-14T01:04:10+02:00
debug: initialize empty string

- - - - -
dd7663d2 by Zdenek Kabelac at 2023-10-14T01:04:10+02:00
configure.ac: enhancemetns

Simplify configuration with enabling options:
- For --enable-dmeventd automatically --enable-cmdlib.
- For --enable-dbus-service auto --enable-notify-dbus.

Fix check linux/fiemap.h for dmfilemapd.

- - - - -
0627716f by Zdenek Kabelac at 2023-10-14T01:04:10+02:00
configure: update

- - - - -
43020cc4 by Zdenek Kabelac at 2023-10-14T01:04:10+02:00
WHATS_NEW{_DM}: update

- - - - -


8 changed files:

- WHATS_NEW
- WHATS_NEW_DM
- configure
- configure.ac
- lib/metadata/pool_manip.c
- + libdm/.exported_symbols.DM_1_02_197
- libdm/ioctl/libdm-iface.c
- tools/lvconvert.c


Changes:

=====================================
WHATS_NEW
=====================================
@@ -1,5 +1,9 @@
 version 2.03.23 - 
 ==================================
+  Configure automatically enables cmdlib for dmeventd and notify-dbus for dbus.
+  Fix hint calculation for pools with zero or error segment.
+  Configure supports --disable-shared to build only static binaries.
+  Configure supports --without-{blkid|systemd|udev} for easierstatic build.
   Fix pvmove when specifying raid components as moved LVs.
   Enhance error detection for lvm_import_vdo.
   Support PV lists with thin lvconvert.


=====================================
WHATS_NEW_DM
=====================================
@@ -1,6 +1,8 @@
 Version 1.02.197 - 
 ===================================
-  Add support for exit-on file for dmevent to reduce shutdown delays.
+  Propagate ioctl errno from dm_task_run when creating new table line.
+  Add support for group aliases in dmstats.
+  Add support for exit-on file for dmeventd to reduce shutdown delays.
   Add configure option --with-dmeventd-exit-on-path to specify default path.
   Add dmsetup --headings none|abbrev|full to set report headings type.
   Add DM_REPORT_OUTPUT_FIELD_IDS_IN_HEADINGS to provide alternative headings.


=====================================
configure
=====================================
@@ -711,6 +711,7 @@ LVMPOLLD_PIDFILE
 LVMLOCKD_PIDFILE
 LVMIMPORTVDO_PATH
 LVMIMPORTVDO
+LVM2CMD_LIB
 LIB_SUFFIX
 LDDEPS
 JOBS
@@ -786,14 +787,13 @@ PYTHON_PREFIX
 PYTHON_PLATFORM
 PYTHON_VERSION
 PYTHON
-LVM2CMD_LIB
+LIBSYSTEMD_LIBS
+LIBSYSTEMD_CFLAGS
 UDEV_LIBS
 UDEV_CFLAGS
 BLKID_LIBS
 BLKID_CFLAGS
 SYSTEMD_RUN_CMD
-LIBSYSTEMD_LIBS
-LIBSYSTEMD_CFLAGS
 LIBSEAGATEILM_LIBS
 LIBSEAGATEILM_CFLAGS
 LIBDLMCONTROL_LIBS
@@ -973,7 +973,6 @@ enable_use_lvmlockd
 with_lvmlockd_pidfile
 enable_use_lvmpolld
 with_lvmpolld_pidfile
-enable_notify_dbus
 enable_systemd_journal
 enable_app_machineid
 with_systemd_run
@@ -984,8 +983,8 @@ enable_udev_rule_exec_detection
 enable_units_compat
 enable_ioctl
 enable_o_direct
-enable_cmdlib
 enable_dbus_service
+enable_notify_dbus
 with_python_sys_prefix
 with_python_prefix
 with_python_exec_prefix
@@ -995,6 +994,7 @@ enable_fsadm
 enable_lvmimportvdo
 enable_blkdeactivate
 enable_dmeventd
+enable_cmdlib
 enable_dmfilemapd
 enable_selinux
 enable_blkzeroout
@@ -1047,12 +1047,12 @@ LIBDLMCONTROL_CFLAGS
 LIBDLMCONTROL_LIBS
 LIBSEAGATEILM_CFLAGS
 LIBSEAGATEILM_LIBS
-LIBSYSTEMD_CFLAGS
-LIBSYSTEMD_LIBS
 BLKID_CFLAGS
 BLKID_LIBS
 UDEV_CFLAGS
 UDEV_LIBS
+LIBSYSTEMD_CFLAGS
+LIBSYSTEMD_LIBS
 PYTHON
 SELINUX_CFLAGS
 SELINUX_LIBS
@@ -1714,7 +1714,6 @@ Optional Features:
   --enable-lvmlockd-idm   enable the LVM lock daemon using idm
   --disable-use-lvmlockd  disable usage of LVM lock daemon
   --disable-use-lvmpolld  disable usage of LVM Poll Daemon
-  --enable-notify-dbus    enable LVM notification using dbus
   --disable-systemd-journal
                           disable LVM systemd journaling
   --disable-app-machineid disable LVM system ID using app-specific machine-id
@@ -1728,14 +1727,15 @@ Optional Features:
                           that do not use KiB-style unit suffixes
   --disable-ioctl         disable ioctl calls to device-mapper in the kernel
   --disable-o_direct      disable O_DIRECT
-  --enable-cmdlib         build shared command library
   --enable-dbus-service   install D-Bus support
+  --enable-notify-dbus    enable LVM notification using dbus
   --enable-pkgconfig      install pkgconfig support
   --enable-write_install  install user writable files
   --disable-fsadm         disable fsadm
   --disable-lvmimportvdo  disable lvm_import_vdo
   --disable-blkdeactivate disable blkdeactivate
   --enable-dmeventd       enable the device-mapper event daemon
+  --enable-cmdlib         build shared command library
   --enable-dmfilemapd     enable the dmstats filemap daemon
   --disable-selinux       disable selinux support
   --disable-blkzeroout    do not use BLKZEROOUT for device zeroing
@@ -1878,15 +1878,15 @@ Some influential environment variables:
               C compiler flags for LIBSEAGATEILM, overriding pkg-config
   LIBSEAGATEILM_LIBS
               linker flags for LIBSEAGATEILM, overriding pkg-config
-  LIBSYSTEMD_CFLAGS
-              C compiler flags for LIBSYSTEMD, overriding pkg-config
-  LIBSYSTEMD_LIBS
-              linker flags for LIBSYSTEMD, overriding pkg-config
   BLKID_CFLAGS
               C compiler flags for BLKID, overriding pkg-config
   BLKID_LIBS  linker flags for BLKID, overriding pkg-config
   UDEV_CFLAGS C compiler flags for UDEV, overriding pkg-config
   UDEV_LIBS   linker flags for UDEV, overriding pkg-config
+  LIBSYSTEMD_CFLAGS
+              C compiler flags for LIBSYSTEMD, overriding pkg-config
+  LIBSYSTEMD_LIBS
+              linker flags for LIBSYSTEMD, overriding pkg-config
   PYTHON      the Python interpreter
   SELINUX_CFLAGS
               C compiler flags for SELINUX, overriding pkg-config
@@ -12665,9 +12665,9 @@ printf "%s\n" "#define DEFAULT_USE_LVMPOLLD $DEFAULT_USE_LVMPOLLD" >>confdefs.h
 
 
 SYSTEMD_MIN_VERSION=0
+NOTIFYDBUS_SUPPORT="no"
 SYSTEMD_JOURNAL_SUPPORT="no"
 APP_MACHINEID_SUPPORT="no"
-
 if test "$with_systemd" = "yes"
 then :
   if test -n "$PKG_CONFIG" && \
@@ -12676,7 +12676,7 @@ then :
   ac_status=$?
   printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  SYSTEMD_MIN_VERSION=221 SYSTEMD_JOURNAL_SUPPORT="maybe"
+  SYSTEMD_MIN_VERSION=221 NOTIFYDBUS_SUPPORT="maybe" SYSTEMD_JOURNAL_SUPPORT="maybe"
 fi
       if test -n "$PKG_CONFIG" && \
     { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 234\""; } >&5
@@ -12688,31 +12688,6 @@ fi
 fi
 fi
 
-################################################################################
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to build notifydbus" >&5
-printf %s "checking whether to build notifydbus... " >&6; }
-# Check whether --enable-notify-dbus was given.
-if test ${enable_notify_dbus+y}
-then :
-  enableval=$enable_notify_dbus; NOTIFYDBUS_SUPPORT=$enableval
-else $as_nop
-  NOTIFYDBUS_SUPPORT="no"
-fi
-
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $NOTIFYDBUS_SUPPORT" >&5
-printf "%s\n" "$NOTIFYDBUS_SUPPORT" >&6; }
-
-if test "$NOTIFYDBUS_SUPPORT" = "yes"
-then :
-  if test "$SYSTEMD_MIN_VERSION" -lt 221
-then :
-  as_fn_error $? "--enable-notify-dbus requires systemd >= 221. (--with-systemd=$with_systemd)" "$LINENO" 5
-fi
-
-printf "%s\n" "#define NOTIFYDBUS_SUPPORT 1" >>confdefs.h
-
-fi
-
 ################################################################################
 if test "$SYSTEMD_JOURNAL_SUPPORT" != "no"
 then :
@@ -12781,103 +12756,6 @@ printf "%s\n" "#define APP_MACHINEID_SUPPORT 1" >>confdefs.h
 
 fi
 
-if test "$NOTIFYDBUS_SUPPORT" = "yes" || test "$SYSTEMD_JOURNAL_SUPPORT" = "yes" || test "$APP_MACHINEID_SUPPORT" = "yes"
-then :
-
-
-pkg_failed=no
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for libsystemd" >&5
-printf %s "checking for libsystemd... " >&6; }
-
-if test -n "$LIBSYSTEMD_CFLAGS"; then
-    pkg_cv_LIBSYSTEMD_CFLAGS="$LIBSYSTEMD_CFLAGS"
- elif test -n "$PKG_CONFIG"; then
-    if test -n "$PKG_CONFIG" && \
-    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libsystemd\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "libsystemd") 2>&5
-  ac_status=$?
-  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
-  test $ac_status = 0; }; then
-  pkg_cv_LIBSYSTEMD_CFLAGS=`$PKG_CONFIG --cflags "libsystemd" 2>/dev/null`
-		      test "x$?" != "x0" && pkg_failed=yes
-else
-  pkg_failed=yes
-fi
- else
-    pkg_failed=untried
-fi
-if test -n "$LIBSYSTEMD_LIBS"; then
-    pkg_cv_LIBSYSTEMD_LIBS="$LIBSYSTEMD_LIBS"
- elif test -n "$PKG_CONFIG"; then
-    if test -n "$PKG_CONFIG" && \
-    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libsystemd\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "libsystemd") 2>&5
-  ac_status=$?
-  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
-  test $ac_status = 0; }; then
-  pkg_cv_LIBSYSTEMD_LIBS=`$PKG_CONFIG --libs "libsystemd" 2>/dev/null`
-		      test "x$?" != "x0" && pkg_failed=yes
-else
-  pkg_failed=yes
-fi
- else
-    pkg_failed=untried
-fi
-
-
-
-if test $pkg_failed = yes; then
-        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
-printf "%s\n" "no" >&6; }
-
-if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
-        _pkg_short_errors_supported=yes
-else
-        _pkg_short_errors_supported=no
-fi
-        if test $_pkg_short_errors_supported = yes; then
-                LIBSYSTEMD_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libsystemd" 2>&1`
-        else
-                LIBSYSTEMD_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libsystemd" 2>&1`
-        fi
-        # Put the nasty error message in config.log where it belongs
-        echo "$LIBSYSTEMD_PKG_ERRORS" >&5
-
-        as_fn_error $? "Package requirements (libsystemd) were not met:
-
-$LIBSYSTEMD_PKG_ERRORS
-
-Consider adjusting the PKG_CONFIG_PATH environment variable if you
-installed software in a non-standard prefix.
-
-Alternatively, you may set the environment variables LIBSYSTEMD_CFLAGS
-and LIBSYSTEMD_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details." "$LINENO" 5
-elif test $pkg_failed = untried; then
-        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
-printf "%s\n" "no" >&6; }
-        { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
-printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
-as_fn_error $? "The pkg-config script could not be found or is too old.  Make sure it
-is in your PATH or set the PKG_CONFIG environment variable to the full
-path to pkg-config.
-
-Alternatively, you may set the environment variables LIBSYSTEMD_CFLAGS
-and LIBSYSTEMD_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details.
-
-To get pkg-config, see <http://pkg-config.freedesktop.org/>.
-See \`config.log' for more details" "$LINENO" 5; }
-else
-        LIBSYSTEMD_CFLAGS=$pkg_cv_LIBSYSTEMD_CFLAGS
-        LIBSYSTEMD_LIBS=$pkg_cv_LIBSYSTEMD_LIBS
-        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-printf "%s\n" "yes" >&6; }
-
-fi
-
-fi
-
 ################################################################################
 
 # Check whether --with-systemd-run was given.
@@ -13451,47 +13329,149 @@ printf "%s\n" "#define O_DIRECT_SUPPORT 1" >>confdefs.h
 fi
 
 ################################################################################
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to compile liblvm2cmd.so" >&5
-printf %s "checking whether to compile liblvm2cmd.so... " >&6; }
-# Check whether --enable-cmdlib was given.
-if test ${enable_cmdlib+y}
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to include Python D-Bus support" >&5
+printf %s "checking whether to include Python D-Bus support... " >&6; }
+# Check whether --enable-dbus-service was given.
+if test ${enable_dbus_service+y}
 then :
-  enableval=$enable_cmdlib; CMDLIB=$enableval
+  enableval=$enable_dbus_service; BUILD_LVMDBUSD=$enableval
 else $as_nop
-  CMDLIB="no"
+  BUILD_LVMDBUSD="no"
 fi
 
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CMDLIB" >&5
-printf "%s\n" "$CMDLIB" >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BUILD_LVMDBUSD" >&5
+printf "%s\n" "$BUILD_LVMDBUSD" >&6; }
 
-if test "$CMDLIB" = "yes"
-then :
-  if test "$SHARED_LINK" = "no"
+################################################################################
+# Check whether --enable-notify-dbus was given.
+if test ${enable_notify_dbus+y}
 then :
-  as_fn_error $? "--enable-cmdlib requires dynamic linking." "$LINENO" 5
+  enableval=$enable_notify_dbus; NOTIFYDBUS_SUPPORT=$enableval
 fi
-       LVM2CMD_LIB="-llvm2cmd"
+
+
+if test "$NOTIFYDBUS_SUPPORT" = "maybe"
+then :
+  if test "$BUILD_LVMDBUSD" = "yes"
+then :
+  NOTIFYDBUS_SUPPORT="yes"
 else $as_nop
-  LVM2CMD_LIB=
+  NOTIFYDBUS_SUPPORT="no"
+fi
 fi
 
-################################################################################
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to include Python D-Bus support" >&5
-printf %s "checking whether to include Python D-Bus support... " >&6; }
-# Check whether --enable-dbus-service was given.
-if test ${enable_dbus_service+y}
+if test "$NOTIFYDBUS_SUPPORT" = "yes"
 then :
-  enableval=$enable_dbus_service; BUILD_LVMDBUSD=$enableval
-else $as_nop
-  BUILD_LVMDBUSD="no"
+  if test "$SYSTEMD_MIN_VERSION" -lt 221
+then :
+  as_fn_error $? "--enable-notify-dbus requires systemd >= 221. (--with-systemd=$with_systemd)" "$LINENO" 5
 fi
 
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BUILD_LVMDBUSD" >&5
-printf "%s\n" "$BUILD_LVMDBUSD" >&6; }
-if test "$NOTIFYDBUS_SUPPORT" = "no" && test "$BUILD_LVMDBUSD" = "yes"
+printf "%s\n" "#define NOTIFYDBUS_SUPPORT 1" >>confdefs.h
+
+fi
+
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to build notifydbus" >&5
+printf %s "checking whether to build notifydbus... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $NOTIFYDBUS_SUPPORT" >&5
+printf "%s\n" "$NOTIFYDBUS_SUPPORT" >&6; }
+
+################################################################################
+if test "$NOTIFYDBUS_SUPPORT" = "yes" || test "$SYSTEMD_JOURNAL_SUPPORT" = "yes" || test "$APP_MACHINEID_SUPPORT" = "yes"
 then :
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: Building D-Bus support without D-Bus notifications." >&5
-printf "%s\n" "$as_me: WARNING: Building D-Bus support without D-Bus notifications." >&2;}
+
+
+pkg_failed=no
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for libsystemd" >&5
+printf %s "checking for libsystemd... " >&6; }
+
+if test -n "$LIBSYSTEMD_CFLAGS"; then
+    pkg_cv_LIBSYSTEMD_CFLAGS="$LIBSYSTEMD_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libsystemd\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "libsystemd") 2>&5
+  ac_status=$?
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_LIBSYSTEMD_CFLAGS=`$PKG_CONFIG --cflags "libsystemd" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$LIBSYSTEMD_LIBS"; then
+    pkg_cv_LIBSYSTEMD_LIBS="$LIBSYSTEMD_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libsystemd\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "libsystemd") 2>&5
+  ac_status=$?
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_LIBSYSTEMD_LIBS=`$PKG_CONFIG --libs "libsystemd" 2>/dev/null`
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
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
+
+if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
+        _pkg_short_errors_supported=yes
+else
+        _pkg_short_errors_supported=no
+fi
+        if test $_pkg_short_errors_supported = yes; then
+                LIBSYSTEMD_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libsystemd" 2>&1`
+        else
+                LIBSYSTEMD_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libsystemd" 2>&1`
+        fi
+        # Put the nasty error message in config.log where it belongs
+        echo "$LIBSYSTEMD_PKG_ERRORS" >&5
+
+        as_fn_error $? "Package requirements (libsystemd) were not met:
+
+$LIBSYSTEMD_PKG_ERRORS
+
+Consider adjusting the PKG_CONFIG_PATH environment variable if you
+installed software in a non-standard prefix.
+
+Alternatively, you may set the environment variables LIBSYSTEMD_CFLAGS
+and LIBSYSTEMD_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details." "$LINENO" 5
+elif test $pkg_failed = untried; then
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
+        { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
+as_fn_error $? "The pkg-config script could not be found or is too old.  Make sure it
+is in your PATH or set the PKG_CONFIG environment variable to the full
+path to pkg-config.
+
+Alternatively, you may set the environment variables LIBSYSTEMD_CFLAGS
+and LIBSYSTEMD_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details.
+
+To get pkg-config, see <http://pkg-config.freedesktop.org/>.
+See \`config.log' for more details" "$LINENO" 5; }
+else
+        LIBSYSTEMD_CFLAGS=$pkg_cv_LIBSYSTEMD_CFLAGS
+        LIBSYSTEMD_LIBS=$pkg_cv_LIBSYSTEMD_LIBS
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+printf "%s\n" "yes" >&6; }
+
+fi
+
 fi
 
 ################################################################################
@@ -14166,25 +14146,53 @@ printf "%s\n" "$BUILD_DMEVENTD" >&6; }
 if test "$BUILD_DMEVENTD" = "yes"
 then :
 
-   if test "$MIRRORS" != "internal"
+      if test "$MIRRORS" != "internal"
 then :
+  as_fn_error $? "--enable-dmeventd currently requires --with-mirrors=internal" "$LINENO" 5
+fi
 
-      as_fn_error $? "--enable-dmeventd currently requires --with-mirrors=internal" "$LINENO" 5
+printf "%s\n" "#define DMEVENTD 1" >>confdefs.h
 
 fi
-   if test "$CMDLIB" = "no"
+
+################################################################################
+# Check whether --enable-cmdlib was given.
+if test ${enable_cmdlib+y}
 then :
+  enableval=$enable_cmdlib; CMDLIB=$enableval
+else $as_nop
+  CMDLIB="maybe"
+fi
 
-      as_fn_error $? "--enable-dmeventd requires --enable-cmdlib to be used as well" "$LINENO" 5
 
+if test "$BUILD_DMEVENTD" = "yes"
+then :
+  if test "$CMDLIB" = "no"
+then :
+  as_fn_error $? "--enable-dmeventd requires --enable-cmdlib to be used as well" "$LINENO" 5
+else $as_nop
+  CMDLIB="yes"
+fi
 fi
 
+if test "$CMDLIB" != "yes"
+then :
+  CMDLIB="no" LVM2CMD_LIB=
+else $as_nop
+  LVM2CMD_LIB="-llvm2cmd"
+fi
 
-printf "%s\n" "#define DMEVENTD 1" >>confdefs.h
-
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to compile liblvm2cmd.so" >&5
+printf %s "checking whether to compile liblvm2cmd.so... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CMDLIB" >&5
+printf "%s\n" "$CMDLIB" >&6; }
 
+if test "$CMDLIB" == "yes" && test "$SHARED_LINK" = "no"
+then :
+  as_fn_error $? "--enable-cmdlib requires dynamic linking." "$LINENO" 5
 fi
 
+
 ################################################################################
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to build dmfilemapd" >&5
 printf %s "checking whether to build dmfilemapd... " >&6; }
@@ -14201,11 +14209,12 @@ printf "%s\n" "$BUILD_DMFILEMAPD" >&6; }
 
 if test "$BUILD_DMFILEMAPD" = "yes"
 then :
-  ac_fn_c_check_header_compile "$LINENO" "linux/fiemap.h" "ac_cv_header_linux_fiemap_h" "as_fn_error $? "--enable-dmfilemapd requires fiemap.h" "$LINENO" 5
-"
+  ac_fn_c_check_header_compile "$LINENO" "linux/fiemap.h" "ac_cv_header_linux_fiemap_h" "$ac_includes_default"
 if test "x$ac_cv_header_linux_fiemap_h" = xyes
 then :
 
+else $as_nop
+  as_fn_error $? "--enable-dmfilemapd requires fiemap.h" "$LINENO" 5
 fi
 
 
@@ -16278,6 +16287,7 @@ AIO_LIBS=${AIO_LIBS:--laio}
 
 
 
+
 
 
 ################################################################################
@@ -17666,3 +17676,9 @@ then :
 printf "%s\n" "$as_me: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&2;}
 fi
 
+if test "$BUILD_LVMDBUSD" = "yes" && test "$NOTIFYDBUS_SUPPORT" = "no"
+then :
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: Building D-Bus support without D-Bus notifications!" >&5
+printf "%s\n" "$as_me: WARNING: Building D-Bus support without D-Bus notifications!" >&2;}
+fi
+


=====================================
configure.ac
=====================================
@@ -1030,27 +1030,13 @@ AC_DEFINE_UNQUOTED(DEFAULT_USE_LVMPOLLD, [$DEFAULT_USE_LVMPOLLD],
 
 
 SYSTEMD_MIN_VERSION=0
+NOTIFYDBUS_SUPPORT="no"
 SYSTEMD_JOURNAL_SUPPORT="no"
 APP_MACHINEID_SUPPORT="no"
-
 AS_IF([test "$with_systemd" = "yes"],
-      PKG_CHECK_EXISTS(systemd >= 221, [SYSTEMD_MIN_VERSION=221 SYSTEMD_JOURNAL_SUPPORT="maybe"])
+      PKG_CHECK_EXISTS(systemd >= 221, [SYSTEMD_MIN_VERSION=221 NOTIFYDBUS_SUPPORT="maybe" SYSTEMD_JOURNAL_SUPPORT="maybe"])
       PKG_CHECK_EXISTS(systemd >= 234, [SYSTEMD_MIN_VERSION=234 APP_MACHINEID_SUPPORT="maybe"]))
 
-################################################################################
-dnl -- Build notifydbus
-AC_MSG_CHECKING([whether to build notifydbus])
-AC_ARG_ENABLE(notify-dbus,
-	      AS_HELP_STRING([--enable-notify-dbus],
-			     [enable LVM notification using dbus]),
-	      NOTIFYDBUS_SUPPORT=$enableval, NOTIFYDBUS_SUPPORT="no")
-AC_MSG_RESULT([$NOTIFYDBUS_SUPPORT])
-
-AS_IF([test "$NOTIFYDBUS_SUPPORT" = "yes"],
-      AS_IF([test "$SYSTEMD_MIN_VERSION" -lt 221],
-            [AC_MSG_ERROR([--enable-notify-dbus requires systemd >= 221. (--with-systemd=$with_systemd)])])
-      AC_DEFINE([NOTIFYDBUS_SUPPORT], 1, [Define to 1 to include code that uses dbus notification.]))
-
 ################################################################################
 dnl -- Build with systemd journaling when the header file is present
 AS_IF([test "$SYSTEMD_JOURNAL_SUPPORT" != "no"],
@@ -1083,11 +1069,6 @@ AC_MSG_RESULT([$APP_MACHINEID_SUPPORT])
 AS_IF([test "$APP_MACHINEID_SUPPORT" = "yes"],
       AC_DEFINE([APP_MACHINEID_SUPPORT], 1, [Define to 1 to include code that uses libsystemd machine-id apis.]))
 
-dnl -- Look for libsystemd libraries if needed
-AS_IF([test "$NOTIFYDBUS_SUPPORT" = "yes" || test "$SYSTEMD_JOURNAL_SUPPORT" = "yes" || test "$APP_MACHINEID_SUPPORT" = "yes"], [
-	PKG_CHECK_MODULES(LIBSYSTEMD, [libsystemd])
-])
-
 ################################################################################
 dnl -- Support override for systemd-run path if they need to (NixOS builds)
 AC_ARG_WITH(systemd-run,
@@ -1225,19 +1206,6 @@ AS_IF([test "$ODIRECT" = "yes"], [
 	AC_DEFINE([O_DIRECT_SUPPORT], 1, [Define to 1 to enable O_DIRECT support.])
 ])
 
-################################################################################
-dnl -- Enable cmdlib
-AC_MSG_CHECKING([whether to compile liblvm2cmd.so])
-AC_ARG_ENABLE(cmdlib,
-	      AS_HELP_STRING([--enable-cmdlib], [build shared command library]),
-	      CMDLIB=$enableval, CMDLIB="no")
-AC_MSG_RESULT([$CMDLIB])
-AC_SUBST([LVM2CMD_LIB])
-AS_IF([test "$CMDLIB" = "yes"],
-      [AS_IF([test "$SHARED_LINK" = "no"],
-	     [AC_MSG_ERROR([--enable-cmdlib requires dynamic linking.])])
-       LVM2CMD_LIB="-llvm2cmd"], [LVM2CMD_LIB=])
-
 ################################################################################
 dnl -- Enable D-Bus service
 AC_MSG_CHECKING([whether to include Python D-Bus support])
@@ -1245,8 +1213,29 @@ AC_ARG_ENABLE(dbus-service,
 	      AS_HELP_STRING([--enable-dbus-service], [install D-Bus support]),
 	      BUILD_LVMDBUSD=$enableval, BUILD_LVMDBUSD="no")
 AC_MSG_RESULT([$BUILD_LVMDBUSD])
-AS_IF([test "$NOTIFYDBUS_SUPPORT" = "no" && test "$BUILD_LVMDBUSD" = "yes"],
-      [AC_MSG_WARN([Building D-Bus support without D-Bus notifications.])])
+
+################################################################################
+dnl -- Build notifydbus
+AC_ARG_ENABLE(notify-dbus,
+	      [AS_HELP_STRING([--enable-notify-dbus], [enable LVM notification using dbus])],
+	      [NOTIFYDBUS_SUPPORT=$enableval])
+
+AS_IF([test "$NOTIFYDBUS_SUPPORT" = "maybe"],
+      [AS_IF([test "$BUILD_LVMDBUSD" = "yes"], [NOTIFYDBUS_SUPPORT="yes"], [NOTIFYDBUS_SUPPORT="no"])])
+
+AS_IF([test "$NOTIFYDBUS_SUPPORT" = "yes"],
+      [AS_IF([test "$SYSTEMD_MIN_VERSION" -lt 221],
+	    [AC_MSG_ERROR([--enable-notify-dbus requires systemd >= 221. (--with-systemd=$with_systemd)])])
+       AC_DEFINE([NOTIFYDBUS_SUPPORT], 1, [Define to 1 to include code that uses dbus notification.])])
+
+AC_MSG_CHECKING([whether to build notifydbus])
+AC_MSG_RESULT([$NOTIFYDBUS_SUPPORT])
+
+################################################################################
+dnl -- Look for libsystemd libraries if needed
+AS_IF([test "$NOTIFYDBUS_SUPPORT" = "yes" || test "$SYSTEMD_JOURNAL_SUPPORT" = "yes" || test "$APP_MACHINEID_SUPPORT" = "yes"], [
+	PKG_CHECK_MODULES(LIBSYSTEMD, [libsystemd])
+])
 
 ################################################################################
 dnl -- Enable Python dbus library
@@ -1320,15 +1309,28 @@ AC_MSG_RESULT([$BUILD_DMEVENTD])
 
 dnl -- dmeventd currently requires internal mirror support
 AS_IF([test "$BUILD_DMEVENTD" = "yes"], [
-   AS_IF([test "$MIRRORS" != "internal"], [
-      AC_MSG_ERROR([--enable-dmeventd currently requires --with-mirrors=internal])
-   ])
-   AS_IF([test "$CMDLIB" = "no"], [
-      AC_MSG_ERROR([--enable-dmeventd requires --enable-cmdlib to be used as well])
-   ])
-
-   AC_DEFINE([DMEVENTD], 1, [Define to 1 to enable the device-mapper event daemon.])
-])
+      AS_IF([test "$MIRRORS" != "internal"],
+	    [AC_MSG_ERROR([--enable-dmeventd currently requires --with-mirrors=internal])])
+      AC_DEFINE([DMEVENTD], 1, [Define to 1 to enable the device-mapper event daemon.])])
+
+################################################################################
+dnl -- Enable cmdlib
+AC_ARG_ENABLE(cmdlib, [AS_HELP_STRING([--enable-cmdlib], [build shared command library])],
+	      CMDLIB=$enableval, CMDLIB="maybe")
+
+AS_IF([test "$BUILD_DMEVENTD" = "yes"],
+      [AS_IF([test "$CMDLIB" = "no"],
+             [AC_MSG_ERROR([--enable-dmeventd requires --enable-cmdlib to be used as well])],
+             [CMDLIB="yes"])])
+
+AS_IF([test "$CMDLIB" != "yes"], [CMDLIB="no" LVM2CMD_LIB=], [LVM2CMD_LIB="-llvm2cmd"])
+
+AC_MSG_CHECKING([whether to compile liblvm2cmd.so])
+AC_MSG_RESULT([$CMDLIB])
+
+AS_IF([test "$CMDLIB" == "yes" && test "$SHARED_LINK" = "no"],
+      [AC_MSG_ERROR([--enable-cmdlib requires dynamic linking.])])
+
 
 ################################################################################
 dnl -- Check dmfilemapd
@@ -1340,8 +1342,7 @@ AC_MSG_RESULT([$BUILD_DMFILEMAPD])
 
 dnl -- dmfilemapd requires FIEMAP
 AS_IF([test "$BUILD_DMFILEMAPD" = "yes"],
-      [AC_CHECK_HEADER([linux/fiemap.h], [],
-		      ,[AC_MSG_ERROR(--enable-dmfilemapd requires fiemap.h)])
+      [AC_CHECK_HEADER([linux/fiemap.h], [], [AC_MSG_ERROR(--enable-dmfilemapd requires fiemap.h)])
        AC_DEFINE([DMFILEMAPD], 1, [Define to 1 to enable the device-mapper filemap daemon.])])
 
 ################################################################################
@@ -1879,6 +1880,7 @@ AC_SUBST(LDDEPS)
 AC_SUBST(LIBS)
 AC_SUBST(LIB_SUFFIX)
 AC_SUBST(localedir)
+AC_SUBST(LVM2CMD_LIB)
 AC_SUBST(LVMIMPORTVDO)
 AC_SUBST(LVMIMPORTVDO_PATH)
 AC_SUBST(LVMLOCKD_PIDFILE)
@@ -2040,3 +2042,6 @@ AS_IF([test -n "$LVM_NEEDS_LIBAIO_WARN"],
 
 AS_IF([test "$ODIRECT" != "yes"],
       [AC_MSG_WARN([O_DIRECT disabled: low-memory pvmove may lock up])])
+
+AS_IF([test "$BUILD_LVMDBUSD" = "yes" && test "$NOTIFYDBUS_SUPPORT" = "no"],
+      [AC_MSG_WARN([Building D-Bus support without D-Bus notifications!])])


=====================================
lib/metadata/pool_manip.c
=====================================
@@ -440,7 +440,7 @@ int recalculate_pool_chunk_size_with_dev_hints(struct logical_volume *pool_lv,
 	}
 
 	dm_list_iterate_items(seg, &pool_data_lv->segments) {
-		switch (seg_type(seg, 0)) {
+		switch (seg->area_count ? seg_type(seg, 0) : AREA_UNASSIGNED) {
 		case AREA_PV:
 			pv = seg_pv(seg, 0);
 			if (chunk_size_calc_policy == THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE)


=====================================
libdm/.exported_symbols.DM_1_02_197
=====================================
@@ -0,0 +1 @@
+dm_task_run


=====================================
libdm/ioctl/libdm-iface.c
=====================================
@@ -2055,7 +2055,21 @@ int dm_task_get_errno(struct dm_task *dmt)
 	return dmt->ioctl_errno;
 }
 
-int dm_task_run(struct dm_task *dmt)
+#if defined(GNU_SYMVER)
+/*
+ * Enforce new version 1_02_197 of dm_task_run() that propagates
+ * ioctl() errno is being linked to app.
+ */
+DM_EXPORT_SYMBOL_BASE(dm_task_run)
+int dm_task_run_base(struct dm_task *dmt);
+int dm_task_run_base(struct dm_task *dmt)
+{
+	return dm_task_run(dmt);
+}
+#endif
+
+DM_EXPORT_NEW_SYMBOL(int, dm_task_run, 1_02_197)
+	(struct dm_task *dmt)
 {
 	struct dm_ioctl *dmi;
 	unsigned command;


=====================================
tools/lvconvert.c
=====================================
@@ -3071,7 +3071,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	struct logical_volume *data_lv;             /* lv arg renamed */
 	struct logical_volume *pool_lv = NULL;             /* new lv created here */
 	const char *pool_metadata_name;             /* user-specified lv name */
-	char converted_names[3*NAME_LEN];	    /* preserve names of converted lv */
+	char converted_names[3*NAME_LEN] = { 0 };   /* preserve names of converted lv */
 	struct segment_type *pool_segtype;          /* thinpool or cachepool */
 	const char *str_seg_type = to_cachepool ? SEG_TYPE_NAME_CACHE_POOL : SEG_TYPE_NAME_THIN_POOL;
 	struct lv_segment *seg;



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/b16247539137964736c6274a80c603cc83c0faf3...43020cc474caa2242c337fb26f709eaf3bab81fe

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/b16247539137964736c6274a80c603cc83c0faf3...43020cc474caa2242c337fb26f709eaf3bab81fe
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231013/4332102a/attachment-0001.htm>
