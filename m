From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 15 Nov 2013 16:02:07 +0100
Subject: [PATCH 5/6] configure: add --enable-blkid_wiping
Message-ID: <5286376F.6070406@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 configure               | 126 ++++++++++++++++++++++++++++++++++++++++++++++++
 configure.in            |  21 ++++++++
 lib/misc/configure.h.in |   3 ++
 make.tmpl.in            |   5 +-
 tools/Makefile.in       |   2 +-
 5 files changed, 154 insertions(+), 3 deletions(-)

diff --git a/configure b/configure
index 9418d53..de3a2ec 100755
--- a/configure
+++ b/configure
@@ -691,6 +691,7 @@ CLDFLAGS
 BUILD_LVMETAD
 BUILD_DMEVENTD
 BUILD_CMIRRORD
+BLKID_WIPING
 APPLIB
 MODPROBE_CMD
 MSGFMT
@@ -700,6 +701,8 @@ LVM2CMD_LIB
 LVM2APP_LIB
 UDEV_LIBS
 UDEV_CFLAGS
+BLKID_LIBS
+BLKID_CFLAGS
 VALGRIND_POOL
 VALGRIND_LIBS
 VALGRIND_CFLAGS
@@ -852,6 +855,7 @@ enable_valgrind_pool
 enable_devmapper
 enable_lvmetad
 with_lvmetad_pidfile
+enable_blkid_wiping
 enable_udev_systemd_background_jobs
 enable_udev_sync
 enable_udev_rules
@@ -926,6 +930,8 @@ CUNIT_CFLAGS
 CUNIT_LIBS
 VALGRIND_CFLAGS
 VALGRIND_LIBS
+BLKID_CFLAGS
+BLKID_LIBS
 UDEV_CFLAGS
 UDEV_LIBS'
 
@@ -1556,6 +1562,7 @@ Optional Features:
   --enable-valgrind-pool  enable valgrind awareness of pools
   --disable-devmapper     disable LVM2 device-mapper interaction
   --enable-lvmetad        enable the LVM Metadata Daemon
+  --enable-blkid_wiping   use wiping functionality provided by libblkid
   --enable-udev-systemd-background-jobs
                           enable udev-systemd protocol to instantiate a
                           service for background job
@@ -1716,6 +1723,9 @@ Some influential environment variables:
               C compiler flags for VALGRIND, overriding pkg-config
   VALGRIND_LIBS
               linker flags for VALGRIND, overriding pkg-config
+  BLKID_CFLAGS
+              C compiler flags for BLKID, overriding pkg-config
+  BLKID_LIBS  linker flags for BLKID, overriding pkg-config
   UDEV_CFLAGS C compiler flags for UDEV, overriding pkg-config
   UDEV_LIBS   linker flags for UDEV, overriding pkg-config
 
@@ -9174,6 +9184,120 @@ _ACEOF
 fi
 
 ################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to use blkid wiping functionality" >&5
+$as_echo_n "checking whether to use blkid wiping functionality... " >&6; }
+# Check whether --enable-blkid-wiping was given.
+if test "${enable_blkid_wiping+set}" = set; then :
+  enableval=$enable_blkid_wiping; BLKID_WIPING=$enableval
+else
+  BLKID_WIPING=no
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $BLKID_WIPING" >&5
+$as_echo "$BLKID_WIPING" >&6; }
+
+
+if test x$BLKID_WIPING = xyes; then
+		if test x$PKGCONFIG_INIT != x1; then
+		pkg_config_init
+	fi
+
+pkg_failed=no
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for BLKID" >&5
+$as_echo_n "checking for BLKID... " >&6; }
+
+if test -n "$BLKID_CFLAGS"; then
+    pkg_cv_BLKID_CFLAGS="$BLKID_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"blkid >= 2.22\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "blkid >= 2.22") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_BLKID_CFLAGS=`$PKG_CONFIG --cflags "blkid >= 2.22" 2>/dev/null`
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$BLKID_LIBS"; then
+    pkg_cv_BLKID_LIBS="$BLKID_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"blkid >= 2.22\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "blkid >= 2.22") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_BLKID_LIBS=`$PKG_CONFIG --libs "blkid >= 2.22" 2>/dev/null`
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
+	        BLKID_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "blkid >= 2.22" 2>&1`
+        else
+	        BLKID_PKG_ERRORS=`$PKG_CONFIG --print-errors "blkid >= 2.22" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$BLKID_PKG_ERRORS" >&5
+
+	as_fn_error $? "Package requirements (blkid >= 2.22) were not met:
+
+$BLKID_PKG_ERRORS
+
+Consider adjusting the PKG_CONFIG_PATH environment variable if you
+installed software in a non-standard prefix.
+
+Alternatively, you may set the environment variables BLKID_CFLAGS
+and BLKID_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details." "$LINENO" 5
+
+elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+	{ { $as_echo "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+$as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
+as_fn_error $? "The pkg-config script could not be found or is too old.  Make sure it
+is in your PATH or set the PKG_CONFIG environment variable to the full
+path to pkg-config.
+
+Alternatively, you may set the environment variables BLKID_CFLAGS
+and BLKID_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details.
+
+To get pkg-config, see <http://pkg-config.freedesktop.org/>.
+See \`config.log' for more details" "$LINENO" 5; }
+
+else
+	BLKID_CFLAGS=$pkg_cv_BLKID_CFLAGS
+	BLKID_LIBS=$pkg_cv_BLKID_LIBS
+        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+	BLKID_PC="blkid"
+fi
+
+$as_echo "#define BLKID_WIPING_SUPPORT 1" >>confdefs.h
+
+fi
+
+################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to use udev-systemd protocol for jobs in background" >&5
 $as_echo_n "checking whether to use udev-systemd protocol for jobs in background... " >&6; }
 # Check whether --enable-udev-systemd-background-jobs was given.
@@ -11029,6 +11153,8 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile conf/Makefile conf/example.conf conf/default.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability!
 _init_red_
hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.socket scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
diff --git a/configure.in b/configure.in
index cd80274..ee832ae 100644
--- a/configure.in
+++ b/configure.in
@@ -946,6 +946,25 @@ if test x$BUILD_LVMETAD = xyes; then
 fi
 
 ################################################################################
+dnl -- Enable blkid wiping functionality
+AC_MSG_CHECKING(whether to use blkid wiping functionality)
+AC_ARG_ENABLE(blkid-wiping,
+	      AC_HELP_STRING([--enable-blkid_wiping],
+			     [use wiping functionality provided by libblkid]),
+	      BLKID_WIPING=$enableval, BLKID_WIPING=no)
+AC_MSG_RESULT($BLKID_WIPING)
+
+
+if test x$BLKID_WIPING = xyes; then
+	dnl -- init pkgconfig if required
+	if test x$PKGCONFIG_INIT != x1; then
+		pkg_config_init
+	fi
+	PKG_CHECK_MODULES(BLKID, blkid >= 2.22, [BLKID_PC="blkid"])
+	AC_DEFINE([BLKID_WIPING_SUPPORT], 1, [Define to 1 to use wiping functionality provided by libblkid.])
+fi
+
+################################################################################
 dnl -- Enable udev-systemd protocol to instantiate a service for background jobs
 AC_MSG_CHECKING(whether to use udev-systemd protocol for jobs in background)
 AC_ARG_ENABLE(udev-systemd-background-jobs,
@@ -1538,6 +1557,8 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[[()]]' '{print $2}'`
 ################################################################################
 AC_SUBST(APPLIB)
 AC_SUBST(AWK)
+AC_SUBST(BLKID_LIBS)
+AC_SUBST(BLKID_WIPING)
 AC_SUBST(BUILD_CMIRRORD)
 AC_SUBST(BUILD_DMEVENTD)
 AC_SUBST(BUILD_LVMETAD)
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 13ba882..51db42e 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -1,5 +1,8 @@
 /* lib/misc/configure.h.in.  Generated from configure.in by autoheader.  */
 
+/* Define to 1 to use wiping functionality provided by libblkid. */
+#undef BLKID_WIPING_SUPPORT
+
 /* Define to 1 if the `closedir' function returns void instead of `int'. */
 #undef CLOSEDIR_VOID
 
diff --git a/make.tmpl.in b/make.tmpl.in
index 3eea85e..35a47be 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -43,7 +43,7 @@ PYTHON = @PYTHON@
 
 LIBS = @LIBS@
 # Extra libraries always linked with static binaries
-STATIC_LIBS = $(SELINUX_LIBS) $(UDEV_LIBS)
+STATIC_LIBS = $(SELINUX_LIBS) $(UDEV_LIBS) $(BLKID_LIBS)
 DEFS += @DEFS@
 # FIXME set this only where it's needed, not globally?
 CFLAGS += @CFLAGS@ @UDEV_CFLAGS@
@@ -52,12 +52,13 @@ ELDFLAGS += @ELDFLAGS@
 LDDEPS += @LDDEPS@
 LDFLAGS += @LDFLAGS@
 LIB_SUFFIX = @LIB_SUFFIX@
-LVMINTERNAL_LIBS = -llvm-internal $(DAEMON_LIBS) $(UDEV_LIBS) $(DL_LIBS)
+LVMINTERNAL_LIBS = -llvm-internal $(DAEMON_LIBS) $(UDEV_LIBS) $(DL_LIBS) $(BLKID_LIBS)
 DL_LIBS = @DL_LIBS@
 PTHREAD_LIBS = @PTHREAD_LIBS@
 READLINE_LIBS = @READLINE_LIBS@
 SELINUX_LIBS = @SELINUX_LIBS@
 UDEV_LIBS = @UDEV_LIBS@
+BLKID_LIBS=@BLKID_LIBS@
 TESTING = @TESTING@
 
 # Setup directory variables
diff --git a/tools/Makefile.in b/tools/Makefile.in
index f90cfae..f8e4934 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -117,7 +117,7 @@ CFLOW_TARGET = lvm
 
 include $(top_builddir)/make.tmpl
 
-LIBS += $(UDEV_LIBS)
+LIBS += $(UDEV_LIBS) $(BLKID_LIBS)
 
 device-mapper: $(TARGETS_DM)
 
-- 
1.8.4.2


