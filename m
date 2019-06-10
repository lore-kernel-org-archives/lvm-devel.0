From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon, 10 Jun 2019 11:06:55 -0400
Subject: master - build: autoreconf
Message-ID: <201906101506.x5AF6tZr013233@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=07d41de74c40e6472a708fc0112ad668477305b5
Commit:        07d41de74c40e6472a708fc0112ad668477305b5
Parent:        24bd35b4ce77a5111ee234f554ca139df4b7dd99
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Jun 7 17:56:56 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Jun 7 17:56:56 2019 +0200

build: autoreconf

---
 configure              |  105 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/configure.h.in |    6 +-
 2 files changed, 108 insertions(+), 3 deletions(-)

diff --git a/configure b/configure
index cced7bd..ff3a59b 100755
--- a/configure
+++ b/configure
@@ -742,6 +742,7 @@ CLDNOWHOLEARCHIVE
 CLDFLAGS
 CACHE
 BUILD_DMFILEMAPD
+BUILD_LOCKDDLM_CONTROL
 BUILD_LOCKDDLM
 BUILD_LOCKDSANLOCK
 BUILD_LVMLOCKD
@@ -771,6 +772,8 @@ BLKID_LIBS
 BLKID_CFLAGS
 NOTIFY_DBUS_LIBS
 NOTIFY_DBUS_CFLAGS
+LOCKD_DLM_CONTROL_LIBS
+LOCKD_DLM_CONTROL_CFLAGS
 LOCKD_DLM_LIBS
 LOCKD_DLM_CFLAGS
 LOCKD_SANLOCK_LIBS
@@ -932,6 +935,7 @@ enable_devmapper
 enable_lvmpolld
 enable_lvmlockd_sanlock
 enable_lvmlockd_dlm
+enable_lvmlockd_dlmcontrol
 enable_use_lvmlockd
 with_lvmlockd_pidfile
 enable_use_lvmpolld
@@ -1000,6 +1004,8 @@ LOCKD_SANLOCK_CFLAGS
 LOCKD_SANLOCK_LIBS
 LOCKD_DLM_CFLAGS
 LOCKD_DLM_LIBS
+LOCKD_DLM_CONTROL_CFLAGS
+LOCKD_DLM_CONTROL_LIBS
 NOTIFY_DBUS_CFLAGS
 NOTIFY_DBUS_LIBS
 BLKID_CFLAGS
@@ -1643,6 +1649,8 @@ Optional Features:
   --enable-lvmlockd-sanlock
                           enable the LVM lock daemon using sanlock
   --enable-lvmlockd-dlm   enable the LVM lock daemon using dlm
+  --enable-lvmlockd-dlmcontrol
+                          enable lvmlockd remote refresh using libdlmcontrol
   --disable-use-lvmlockd  disable usage of LVM lock daemon
   --disable-use-lvmpolld  disable usage of LVM Poll Daemon
   --enable-dmfilemapd     enable the dmstats filemap daemon
@@ -1788,6 +1796,10 @@ Some influential environment variables:
               C compiler flags for LOCKD_DLM, overriding pkg-config
   LOCKD_DLM_LIBS
               linker flags for LOCKD_DLM, overriding pkg-config
+  LOCKD_DLM_CONTROL_CFLAGS
+              C compiler flags for LOCKD_DLM_CONTROL, overriding pkg-config
+  LOCKD_DLM_CONTROL_LIBS
+              linker flags for LOCKD_DLM_CONTROL, overriding pkg-config
   NOTIFY_DBUS_CFLAGS
               C compiler flags for NOTIFY_DBUS, overriding pkg-config
   NOTIFY_DBUS_LIBS
@@ -3077,6 +3089,7 @@ case "$host_os" in
 		BUILD_LVMPOLLD=no
 		LOCKDSANLOCK=no
 		LOCKDDLM=no
+		LOCKDDLM_CONTROL=no
 		ODIRECT=yes
 		DM_IOCTLS=yes
 		SELINUX=yes
@@ -10959,6 +10972,97 @@ $as_echo "#define LOCKDDLM_SUPPORT 1" >>confdefs.h
 fi
 
 ################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build lvmlockddlmcontrol" >&5
+$as_echo_n "checking whether to build lvmlockddlmcontrol... " >&6; }
+# Check whether --enable-lvmlockd-dlmcontrol was given.
+if test "${enable_lvmlockd_dlmcontrol+set}" = set; then :
+  enableval=$enable_lvmlockd_dlmcontrol; LOCKDDLM_CONTROL=$enableval
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $LOCKDDLM_CONTROL" >&5
+$as_echo "$LOCKDDLM_CONTROL" >&6; }
+
+BUILD_LOCKDDLM_CONTROL=$LOCKDDLM_CONTROL
+
+if test "$BUILD_LOCKDDLM_CONTROL" = yes; then
+
+pkg_failed=no
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for LOCKD_DLM_CONTROL" >&5
+$as_echo_n "checking for LOCKD_DLM_CONTROL... " >&6; }
+
+if test -n "$LOCKD_DLM_CONTROL_CFLAGS"; then
+    pkg_cv_LOCKD_DLM_CONTROL_CFLAGS="$LOCKD_DLM_CONTROL_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libdlmcontrol >= 3.2\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "libdlmcontrol >= 3.2") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_LOCKD_DLM_CONTROL_CFLAGS=`$PKG_CONFIG --cflags "libdlmcontrol >= 3.2" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$LOCKD_DLM_CONTROL_LIBS"; then
+    pkg_cv_LOCKD_DLM_CONTROL_LIBS="$LOCKD_DLM_CONTROL_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libdlmcontrol >= 3.2\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "libdlmcontrol >= 3.2") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_LOCKD_DLM_CONTROL_LIBS=`$PKG_CONFIG --libs "libdlmcontrol >= 3.2" 2>/dev/null`
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
+	        LOCKD_DLM_CONTROL_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libdlmcontrol >= 3.2" 2>&1`
+        else
+	        LOCKD_DLM_CONTROL_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libdlmcontrol >= 3.2" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$LOCKD_DLM_CONTROL_PKG_ERRORS" >&5
+
+	$bailout
+elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+	$bailout
+else
+	LOCKD_DLM_CONTROL_CFLAGS=$pkg_cv_LOCKD_DLM_CONTROL_CFLAGS
+	LOCKD_DLM_CONTROL_LIBS=$pkg_cv_LOCKD_DLM_CONTROL_LIBS
+        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+	HAVE_LOCKD_DLM_CONTROL=yes
+fi
+
+$as_echo "#define LOCKDDLM_CONTROL_SUPPORT 1" >>confdefs.h
+
+	BUILD_LVMLOCKD=yes
+fi
+
+################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build lvmlockd" >&5
 $as_echo_n "checking whether to build lvmlockd... " >&6; }
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $BUILD_LVMLOCKD" >&5
@@ -13786,6 +13890,7 @@ _ACEOF
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl libdm/make.tmpl daemons/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmeventd/plugins/vdo/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/dm-tools/Makefile libdm/libdevmapper.pc man/Makefile po/Makefile scripts/lvm2-pvscan
 .service scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvmlockd.service scripts/lvmlocks.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile tools/Makefile udev/Makefile"
 
diff --git a/include/configure.h.in b/include/configure.h.in
index ce4c326..a43053a 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -295,9 +295,6 @@
 /* Define to 1 if you have the `pselect' function. */
 #undef HAVE_PSELECT
 
-/* Define to 1 if you have the <pthread.h> header file. */
-#undef HAVE_PTHREAD_H
-
 /* Define to 1 if the system has the type `ptrdiff_t'. */
 #undef HAVE_PTRDIFF_T
 
@@ -537,6 +534,9 @@
 /* Locale-dependent data */
 #undef LOCALEDIR
 
+/* Define to 1 to include code that uses lvmlockd dlm control option. */
+#undef LOCKDDLM_CONTROL_SUPPORT
+
 /* Define to 1 to include code that uses lvmlockd dlm option. */
 #undef LOCKDDLM_SUPPORT
 


