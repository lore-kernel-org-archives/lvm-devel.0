From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 12 Oct 2012 01:14:40 +0000 (UTC)
Subject: master - python: Add bindings for liblvm2app.
Message-ID: <20121012011440.B7953A1046@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ee3cfa41843b0af1ef220ecf8bf6db82676af8c8
Commit:        ee3cfa41843b0af1ef220ecf8bf6db82676af8c8
Parent:        4022fd3e79099fb22b2b7d3d6dca8de733a2a783
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Oct 12 02:08:47 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Oct 12 02:08:47 2012 +0100

python: Add bindings for liblvm2app.

Use configure --enable-python_bindings to generate them.

Note that the Makefiles do not yet control the owner or permissions of
the two new files on installation.
---
 Makefile.in             |   17 +-
 WHATS_NEW               |    1 +
 configure               |  216 ++++++-
 configure.in            |   40 ++
 lib/misc/configure.h.in |    3 -
 make.tmpl.in            |    3 +
 python/Makefile.in      |   39 ++
 python/example.py       |  125 ++++
 python/liblvm.c         | 1711 +++++++++++++++++++++++++++++++++++++++++++++++
 python/setup.py.in      |   35 +
 10 files changed, 2175 insertions(+), 15 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 6b153d3..bbfcf2c 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -32,13 +32,17 @@ ifeq ("@APPLIB@", "yes")
   SUBDIRS += liblvm
 endif
 
+ifeq ("@PYTHON_BINDINGS@", "yes")
+  SUBDIRS += python
+endif
+
 SUBDIRS += scripts
 
 # FIXME Should use intermediate Makefiles here!
 ifeq ($(MAKECMDGOALS),distclean)
   SUBDIRS = doc include man test scripts \
     libdaemon lib tools daemons libdm \
-    udev po liblvm \
+    udev po liblvm python \
     unit-tests/datastruct unit-tests/mm unit-tests/regex
 endif
 DISTCLEAN_DIRS += lcov_reports*
@@ -69,6 +73,10 @@ po.pofile: tools.pofile daemons.pofile
 pofile: po.pofile
 endif
 
+ifeq ("@PYTHON_BINDINGS@", "yes")
+python: liblvm
+endif
+
 ifneq ("$(CFLOW_CMD)", "")
 tools.cflow: libdm.cflow lib.cflow
 daemons.cflow: tools.cflow
@@ -103,6 +111,11 @@ install_systemd_generators:
 install_systemd_units:
 	$(MAKE) -C scripts install_systemd_units
 
+ifeq ("@PYTHON_BINDINGS@", "yes")
+install_python_bindings:
+	$(MAKE) -C liblvm/python install_python_bindings
+endif
+
 install_tmpfiles_configuration:
 	$(MAKE) -C scripts install_tmpfiles_configuration
 
@@ -148,7 +161,7 @@ ifeq ("$(TESTING)", "yes")
 # testing and report generation
 RUBY=ruby1.9 -Ireport-generators/lib -Ireport-generators/test
 
-.PHONEY: unit-test ruby-test test-programs
+.PHONY: unit-test ruby-test test-programs
 
 # FIXME: put dependencies on libdm and liblvm
 # FIXME: Should be handled by Makefiles in subdirs, not here at top level.
diff --git a/WHATS_NEW b/WHATS_NEW
index d614270..e419a46 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Add configure --enable-python_bindings for liblvm2app to new python subdir.
   Add implementation of lvm2api function lvm_percent_to_float.
   Allow non power of 2 thin chunk sizes if thin pool driver supports that.
   Allow limited metadata changes when PVs are missing via [vg|lv]change.
diff --git a/configure b/configure
index 13fb6d6..add489a 100755
--- a/configure
+++ b/configure
@@ -624,6 +624,9 @@ SELINUX_LIBS
 REPLICATORS
 READLINE_LIBS
 RAID
+PYTHON_LIBDIRS
+PYTHON_INCDIRS
+PYTHON_BINDINGS
 PTHREAD_LIBS
 POOL
 PKGCONFIG
@@ -686,10 +689,15 @@ BUILD_CMIRRORD
 APPLIB
 MODPROBE_CMD
 MSGFMT
+PYTHON_CONFIG
+PYTHON
 LVM2CMD_LIB
 LVM2APP_LIB
 UDEV_LIBS
 UDEV_CFLAGS
+VALGRIND_POOL
+VALGRIND_LIBS
+VALGRIND_CFLAGS
 CUNIT_LIBS
 CUNIT_CFLAGS
 GENPNG
@@ -842,6 +850,7 @@ enable_ioctl
 enable_o_direct
 enable_applib
 enable_cmdlib
+enable_python_bindings
 enable_pkgconfig
 enable_write_install
 enable_fsadm
@@ -901,6 +910,8 @@ SACKPT_CFLAGS
 SACKPT_LIBS
 CUNIT_CFLAGS
 CUNIT_LIBS
+VALGRIND_CFLAGS
+VALGRIND_LIBS
 UDEV_CFLAGS
 UDEV_LIBS'
 
@@ -1542,6 +1553,8 @@ Optional Features:
   --disable-o_direct      disable O_DIRECT
   --enable-applib         build application library
   --enable-cmdlib         build shared command library
+  --enable-python_bindings
+                          build Python applib bindings
   --enable-pkgconfig      install pkgconfig support
   --enable-write_install  install user writable files
   --disable-fsadm         disable fsadm
@@ -1678,6 +1691,10 @@ Some influential environment variables:
   CUNIT_CFLAGS
               C compiler flags for CUNIT, overriding pkg-config
   CUNIT_LIBS  linker flags for CUNIT, overriding pkg-config
+  VALGRIND_CFLAGS
+              C compiler flags for VALGRIND, overriding pkg-config
+  VALGRIND_LIBS
+              linker flags for VALGRIND, overriding pkg-config
   UDEV_CFLAGS C compiler flags for UDEV, overriding pkg-config
   UDEV_LIBS   linker flags for UDEV, overriding pkg-config
 
@@ -8814,23 +8831,80 @@ fi
 $as_echo "$VALGRIND_POOL" >&6; }
 
 if test "$VALGRIND_POOL" = yes; then
-    for ac_header in valgrind/memcheck.h
-do :
-  ac_fn_c_check_header_mongrel "$LINENO" "valgrind/memcheck.h" "ac_cv_header_valgrind_memcheck_h" "$ac_includes_default"
-if test "x$ac_cv_header_valgrind_memcheck_h" = x""yes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_VALGRIND_MEMCHECK_H 1
-_ACEOF
 
+pkg_failed=no
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for VALGRIND" >&5
+$as_echo_n "checking for VALGRIND... " >&6; }
+
+if test -n "$VALGRIND_CFLAGS"; then
+    pkg_cv_VALGRIND_CFLAGS="$VALGRIND_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"valgrind\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "valgrind") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_VALGRIND_CFLAGS=`$PKG_CONFIG --cflags "valgrind" 2>/dev/null`
 else
-  as_fn_error $? "bailing out" "$LINENO" 5
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$VALGRIND_LIBS"; then
+    pkg_cv_VALGRIND_LIBS="$VALGRIND_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"valgrind\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "valgrind") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_VALGRIND_LIBS=`$PKG_CONFIG --libs "valgrind" 2>/dev/null`
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
 fi
 
-done
 
 
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
+	        VALGRIND_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "valgrind" 2>&1`
+        else
+	        VALGRIND_PKG_ERRORS=`$PKG_CONFIG --print-errors "valgrind" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$VALGRIND_PKG_ERRORS" >&5
+
+	as_fn_error $? "bailing out" "$LINENO" 5
+elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+	as_fn_error $? "bailing out" "$LINENO" 5
+else
+	VALGRIND_CFLAGS=$pkg_cv_VALGRIND_CFLAGS
+	VALGRIND_LIBS=$pkg_cv_VALGRIND_LIBS
+        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+
+fi
+
 $as_echo "#define VALGRIND_POOL 1" >>confdefs.h
 
+
+
 fi
 
 ################################################################################
@@ -9121,6 +9195,122 @@ test x$CMDLIB = xyes \
   || LVM2CMD_LIB=
 
 ################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build Python wrapper for liblvm2app.so" >&5
+$as_echo_n "checking whether to build Python wrapper for liblvm2app.so... " >&6; }
+# Check whether --enable-python_bindings was given.
+if test "${enable_python_bindings+set}" = set; then :
+  enableval=$enable_python_bindings; PYTHON_BINDINGS=$enableval
+else
+  PYTHON_BINDINGS=no
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $PYTHON_BINDINGS" >&5
+$as_echo "$PYTHON_BINDINGS" >&6; }
+
+if test x$PYTHON_BINDINGS = xyes; then
+	if test x$APPLIB != xyes; then
+		as_fn_error $? "--enable-python_bindings requires --enable-applib
+		" "$LINENO" 5
+	fi
+
+	# Extract the first word of "python", so it can be a program name with args.
+set dummy python; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if test "${ac_cv_path_PYTHON+set}" = set; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $PYTHON in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_PYTHON="$PYTHON" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+    ac_cv_path_PYTHON="$as_dir/$ac_word$ac_exec_ext"
+    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+  done
+IFS=$as_save_IFS
+
+  test -z "$ac_cv_path_PYTHON" && ac_cv_path_PYTHON="notfound"
+  ;;
+esac
+fi
+PYTHON=$ac_cv_path_PYTHON
+if test -n "$PYTHON"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $PYTHON" >&5
+$as_echo "$PYTHON" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+
+	if test x$PYTHON == xnotfound; then
+		as_fn_error $? "python is required for --enable-python_bindings but cannot be found
+		" "$LINENO" 5
+	fi
+
+	# Extract the first word of "python-config", so it can be a program name with args.
+set dummy python-config; ac_word=$2
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+$as_echo_n "checking for $ac_word... " >&6; }
+if test "${ac_cv_path_PYTHON_CONFIG+set}" = set; then :
+  $as_echo_n "(cached) " >&6
+else
+  case $PYTHON_CONFIG in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_PYTHON_CONFIG="$PYTHON_CONFIG" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  test -z "$as_dir" && as_dir=.
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if { test -f "$as_dir/$ac_word$ac_exec_ext" && $as_test_x "$as_dir/$ac_word$ac_exec_ext"; }; then
+    ac_cv_path_PYTHON_CONFIG="$as_dir/$ac_word$ac_exec_ext"
+    $as_echo "$as_me:${as_lineno-$LINENO}: found $as_dir/$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+  done
+IFS=$as_save_IFS
+
+  test -z "$ac_cv_path_PYTHON_CONFIG" && ac_cv_path_PYTHON_CONFIG="notfound"
+  ;;
+esac
+fi
+PYTHON_CONFIG=$ac_cv_path_PYTHON_CONFIG
+if test -n "$PYTHON_CONFIG"; then
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: $PYTHON_CONFIG" >&5
+$as_echo "$PYTHON_CONFIG" >&6; }
+else
+  { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+fi
+
+
+	if test x$PYTHON_CONFIG == xnotfound; then
+		as_fn_error $? "python headers are required for --enable-python_bindings but cannot be found
+		" "$LINENO" 5
+	fi
+
+	PYTHON_INCDIRS=`$PYTHON_CONFIG --includes`
+	PYTHON_LIBDIRS=`$PYTHON_CONFIG --libs`
+
+fi
+
+################################################################################
 # Check whether --enable-pkgconfig was given.
 if test "${enable_pkgconfig+set}" = set; then :
   enableval=$enable_pkgconfig; PKGCONFIG=$enableval
@@ -10576,8 +10766,12 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
+
+
+
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_l
 vmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.socket scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvm
 etad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.socket scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -11303,6 +11497,8 @@ do
     "liblvm/liblvm2app.pc") CONFIG_FILES="$CONFIG_FILES liblvm/liblvm2app.pc" ;;
     "man/Makefile") CONFIG_FILES="$CONFIG_FILES man/Makefile" ;;
     "po/Makefile") CONFIG_FILES="$CONFIG_FILES po/Makefile" ;;
+    "python/Makefile") CONFIG_FILES="$CONFIG_FILES python/Makefile" ;;
+    "python/setup.py") CONFIG_FILES="$CONFIG_FILES python/setup.py" ;;
     "scripts/clvmd_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/clvmd_init_red_hat" ;;
     "scripts/cmirrord_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/cmirrord_init_red_hat" ;;
     "scripts/lvm2_lvmetad_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_init_red_hat" ;;
diff --git a/configure.in b/configure.in
index 16f91fb..eb20908 100644
--- a/configure.in
+++ b/configure.in
@@ -1027,6 +1027,40 @@ test x$CMDLIB = xyes \
   || LVM2CMD_LIB=
 
 ################################################################################
+dnl -- Enable Python liblvm2app bindings
+AC_MSG_CHECKING(whether to build Python wrapper for liblvm2app.so)
+AC_ARG_ENABLE(python_bindings,
+	      AC_HELP_STRING([--enable-python_bindings], [build Python applib bindings]),
+	      PYTHON_BINDINGS=$enableval, PYTHON_BINDINGS=no)
+AC_MSG_RESULT($PYTHON_BINDINGS)
+
+if test x$PYTHON_BINDINGS = xyes; then
+	if test x$APPLIB != xyes; then
+		AC_MSG_ERROR(
+			--enable-python_bindings requires --enable-applib
+		)
+	fi
+
+	AC_PATH_PROG(PYTHON, python, notfound)
+	if test x$PYTHON == xnotfound; then
+		AC_MSG_ERROR(
+[python is required for --enable-python_bindings but cannot be found]
+		)
+	fi
+
+	AC_PATH_PROG(PYTHON_CONFIG, python-config, notfound)
+	if test x$PYTHON_CONFIG == xnotfound; then
+		AC_MSG_ERROR(
+[python headers are required for --enable-python_bindings but cannot be found]
+		)
+	fi
+
+	PYTHON_INCDIRS=`$PYTHON_CONFIG --includes`
+	PYTHON_LIBDIRS=`$PYTHON_CONFIG --libs`
+
+fi
+
+################################################################################
 dnl -- Enable pkg-config
 AC_ARG_ENABLE(pkgconfig,
 	      AC_HELP_STRING([--enable-pkgconfig], [install pkgconfig support]),
@@ -1523,6 +1557,10 @@ AC_SUBST(OCFDIR)
 AC_SUBST(PKGCONFIG)
 AC_SUBST(POOL)
 AC_SUBST(PTHREAD_LIBS)
+AC_SUBST(PYTHON)
+AC_SUBST(PYTHON_BINDINGS)
+AC_SUBST(PYTHON_INCDIRS)
+AC_SUBST(PYTHON_LIBDIRS)
 AC_SUBST(QUORUM_CFLAGS)
 AC_SUBST(QUORUM_LIBS)
 AC_SUBST(RAID)
@@ -1605,6 +1643,8 @@ liblvm/Makefile
 liblvm/liblvm2app.pc
 man/Makefile
 po/Makefile
+python/Makefile
+python/setup.py
 scripts/clvmd_init_red_hat
 scripts/cmirrord_init_red_hat
 scripts/lvm2_lvmetad_init_red_hat
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index c1d1218..fdc5a26 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -432,9 +432,6 @@
 /* Define to 1 if you have the <utmpx.h> header file. */
 #undef HAVE_UTMPX_H
 
-/* Define to 1 if you have the <valgrind/memcheck.h> header file. */
-#undef HAVE_VALGRIND_MEMCHECK_H
-
 /* Define to 1 if you have the `vfork' function. */
 #undef HAVE_VFORK
 
diff --git a/make.tmpl.in b/make.tmpl.in
index 21fd415..8b56f01 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -28,6 +28,7 @@ LN_S = @LN_S@
 SED = @SED@
 CFLOW_CMD = @CFLOW_CMD@
 AWK = @AWK@
+PYTHON = @PYTHON@
 
 LIBS = @LIBS@
 # Extra libraries always linked with static binaries
@@ -52,6 +53,7 @@ prefix = @prefix@
 exec_prefix = @exec_prefix@
 udev_prefix = @udev_prefix@
 sysconfdir = @sysconfdir@
+rootdir = $(DESTDIR)/
 bindir = $(DESTDIR)@bindir@
 confdir = $(DESTDIR)@CONFDIR@/lvm
 includedir = $(DESTDIR)@includedir@
@@ -196,6 +198,7 @@ POTFILES = $(SOURCES:%.c=%.pot)
 .PHONY: install install_cluster install_device-mapper install_lvm2
 .PHONY: install_lib_shared install_dm_plugin install_lvm2_plugin
 .PHONY: install_ocf help
+.PHONY: python_bindings install_python_bindings
 .PHONY: $(SUBDIRS) $(SUBDIRS.install) $(SUBDIRS.clean) $(SUBDIRS.distclean)
 .PHONY: $(SUBDIRS.pofile) $(SUBDIRS.install_cluster) $(SUBDIRS.cflow)
 .PHONY: $(SUBDIRS.device-mapper) $(SUBDIRS.install-device-mapper)
diff --git a/python/Makefile.in b/python/Makefile.in
new file mode 100644
index 0000000..1fead22
--- /dev/null
+++ b/python/Makefile.in
@@ -0,0 +1,39 @@
+#
+# Copyright (C) 2011-2012 Red Hat, Inc.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU Lesser General Public License v.2.1.
+#
+# You should have received a copy of the GNU Lesser General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+srcdir = @srcdir@
+top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
+
+python_bindings: .liblvm_built
+
+.liblvm_built: liblvm_python.c
+	$(PYTHON) setup.py build
+	touch $@
+
+liblvm_python.c:
+	$(LN_S) $(srcdir)/liblvm.c $@
+
+include $(top_builddir)/make.tmpl
+
+install_python_bindings: python_bindings
+	$(PYTHON) setup.py install --skip-build --root $(rootdir)
+
+install_lvm2: install_python_bindings
+
+install: install_lvm2
+
+CLEAN_TARGETS += .liblvm_built liblvm_python.c
+
+DISTCLEAN_DIRS += build
+DISTCLEAN_TARGETS += setup.py
diff --git a/python/example.py b/python/example.py
new file mode 100644
index 0000000..67bb7e4
--- /dev/null
+++ b/python/example.py
@@ -0,0 +1,125 @@
+#
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This program is free software: you can redistribute it and/or modify
+# it under the terms of the GNU Lesser General Public License as published by
+# the Free Software Foundation, either version 2.1 of the License, or
+# (at your option) any later version.
+#
+# This program is distributed in the hope that it will be useful,
+# but WITHOUT ANY WARRANTY; without even the implied warranty of
+# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+# GNU Lesser General Public License for more details.
+#
+# You should have received a copy of the GNU Lesser General Public License
+# along with this program.  If not, see <http://www.gnu.org/licenses/>.
+#
+#-----------------------------
+# Python example code:
+#-----------------------------
+
+import lvm
+
+# Note: This example will create a logical unit, tag it and
+# 	delete it, don't run this on production box!
+
+#Dump information about PV
+def print_pv(pv):
+    print 'PV name: ', pv.getName(), ' ID: ', pv.getUuid(), 'Size: ', pv.getSize()
+
+
+#Dump some information about a specific volume group
+def print_vg(h, vg_name):
+    #Open read only
+    vg = h.vgOpen(vg_name, 'r')
+
+    print 'Volume group:', vg_name, 'Size: ', vg.getSize()
+
+    #Retrieve a list of Physical volumes for this volume group
+    pv_list = vg.listPVs()
+
+    #Print out the physical volumes
+    for p in pv_list:
+        print_pv(p)
+
+    #Get a list of logical volumes in this volume group
+    lv_list = vg.listLVs()
+    if len(lv_list):
+        for l in lv_list:
+            print 'LV name: ', l.getName(), ' ID: ', l.getUuid()
+    else:
+        print 'No logical volumes present!'
+
+    vg.close()
+
+#Returns the name of a vg with space available
+def find_vg_with_free_space(h):
+    free_space = 0
+    rc = None
+
+    vg_names = l.listVgNames()
+    for v in vg_names:
+        vg = h.vgOpen(v, 'r')
+        c_free = vg.getFreeSize()
+        if c_free > free_space:
+            free_space = c_free
+            rc = v
+        vg.close()
+
+    return rc
+
+#Walk through the volume groups and fine one with space in which we can
+#create a new logical volume
+def create_delete_logical_volume(h):
+    vg_name = find_vg_with_free_space(h)
+
+    print 'Using volume group ', vg_name, ' for example'
+
+    if vg_name:
+        vg = h.vgOpen(vg_name, 'w')
+        lv = vg.createLvLinear('python_lvm_ok_to_delete', vg.getFreeSize())
+
+        if lv:
+            print 'New lv, id= ', lv.getUuid()
+
+            #Create a tag
+            lv.addTag('Demo_tag')
+
+            #Get the tags
+            tags = lv.getTags()
+            for t in tags:
+                #Remove tag
+                lv.removeTag(t)
+
+            #Try to rename
+            lv.rename("python_lvm_ok_to_be_removed_shortly")
+            print 'LV name= ', lv.getName()
+
+            lv.deactivate()
+            lv.remove()
+
+        vg.close()
+    else:
+        print 'No free space available to create demo lv!'
+
+if __name__ == '__main__':
+    #Create a new LVM instance
+    l = lvm.Liblvm()
+
+    #What version
+    print 'lvm version=', l.getVersion()
+
+    #Get a list of volume group names
+    vg_names = l.listVgNames()
+
+    #For each volume group display some information about each of them
+    for vg_i in vg_names:
+        print_vg(l, vg_i)
+
+    #Demo creating a logical volume
+    create_delete_logical_volume(l)
+
+    #Close
+    l.close()
diff --git a/python/liblvm.c b/python/liblvm.c
new file mode 100644
index 0000000..cbfa170
--- /dev/null
+++ b/python/liblvm.c
@@ -0,0 +1,1711 @@
+/*
+ * Liblvm -- Python interface to LVM2 API.
+ *
+ * Copyright (C) 2010, 2012 Red Hat, Inc. All rights reserved.
+ *
+ * This program is free software: you can redistribute it and/or modify
+ * it under the terms of the GNU Lesser General Public License as published by
+ * the Free Software Foundation, either version 2.1 of the License, or
+ * (at your option) any later version.
+
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU Lesser General Public License for more details.
+
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * Authors: Lars Sjostrom (lars sjostrom redhat com)
+ *	    Andy Grover (agrover redhat com)
+ *	    Tony Asleson (tasleson redhat com)
+ */
+
+#include <Python.h>
+#include "lvm2app.h"
+
+typedef struct {
+	PyObject_HEAD
+	lvm_t    libh;		    /* lvm lib handle */
+} lvmobject;
+
+typedef struct {
+	PyObject_HEAD
+	vg_t      vg;		    /* vg handle */
+	lvmobject *lvm_obj;
+} vgobject;
+
+typedef struct {
+	PyObject_HEAD
+	lv_t      lv;		    /* lv handle */
+	lvmobject *lvm_obj;
+} lvobject;
+
+typedef struct {
+	PyObject_HEAD
+	pv_t      pv;		    /* pv handle */
+	lvmobject *lvm_obj;
+} pvobject;
+
+typedef struct {
+	PyObject_HEAD
+	lvseg_t    lv_seg;	      /* lv segment handle */
+	lvmobject *lvm_obj;
+} lvsegobject;
+
+typedef struct {
+	PyObject_HEAD
+	pvseg_t    pv_seg;	      /* pv segment handle */
+	lvmobject *lvm_obj;
+} pvsegobject;
+
+static PyTypeObject LibLVMvgType;
+static PyTypeObject LibLVMlvType;
+static PyTypeObject LibLVMpvType;
+static PyTypeObject LibLVMlvsegType;
+static PyTypeObject LibLVMpvsegType;
+
+static PyObject *LibLVMError;
+
+
+/* ----------------------------------------------------------------------
+ * LVM object initialization/deallocation
+ */
+
+static int
+liblvm_init(lvmobject *self, PyObject *arg)
+{
+	char *systemdir = NULL;
+
+	if (!PyArg_ParseTuple(arg, "|s", &systemdir))
+		return -1;
+
+	self->libh = lvm_init(systemdir);
+	if (lvm_errno(self->libh)) {
+		PyErr_SetFromErrno(PyExc_OSError);
+		return -1;
+	}
+
+	return 0;
+}
+
+static void
+liblvm_dealloc(lvmobject *self)
+{
+	/* if already closed, don't reclose it */
+	if (self->libh != NULL){
+		lvm_quit(self->libh);
+	}
+
+	PyObject_Del(self);
+}
+
+#define LVM_VALID(lvmobject)						\
+	do {								\
+		if (!lvmobject->libh) {					\
+			PyErr_SetString(PyExc_UnboundLocalError, "LVM object invalid"); \
+			return NULL;					\
+		}							\
+	} while (0)
+
+static PyObject *
+liblvm_get_last_error(lvmobject *self)
+{
+	PyObject *info;
+
+	LVM_VALID(self);
+
+	if((info = PyTuple_New(2)) == NULL)
+		return NULL;
+
+	PyTuple_SetItem(info, 0, PyInt_FromLong((long) lvm_errno(self->libh)));
+	PyTuple_SetItem(info, 1, PyString_FromString(lvm_errmsg(self->libh)));
+
+	return info;
+}
+
+static PyObject *
+liblvm_library_get_version(lvmobject *self)
+{
+	LVM_VALID(self);
+
+	return Py_BuildValue("s", lvm_library_get_version());
+}
+
+
+static PyObject *
+liblvm_close(lvmobject *self)
+{
+	LVM_VALID(self);
+
+	/* if already closed, don't reclose it */
+	if (self->libh != NULL)
+		lvm_quit(self->libh);
+
+	self->libh = NULL;
+
+	Py_INCREF(Py_None);
+	return Py_None;
+}
+
+static PyObject *
+liblvm_lvm_list_vg_names(lvmobject *self)
+{
+	struct dm_list *vgnames;
+	struct lvm_str_list *strl;
+	PyObject * pytuple;
+	int i = 0;
+
+	LVM_VALID(self);
+
+	vgnames = lvm_list_vg_names(self->libh);
+	if (!vgnames) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(self));
+		return NULL;
+	}
+
+	pytuple = PyTuple_New(dm_list_size(vgnames));
+	if (!pytuple)
+		return NULL;
+
+	dm_list_iterate_items(strl, vgnames) {
+		PyTuple_SET_ITEM(pytuple, i, PyString_FromString(strl->str));
+		i++;
+	}
+
+	return pytuple;
+}
+
+static PyObject *
+liblvm_lvm_list_vg_uuids(lvmobject *self)
+{
+	struct dm_list *uuids;
+	struct lvm_str_list *strl;
+	PyObject * pytuple;
+	int i = 0;
+
+	LVM_VALID(self);
+
+	uuids = lvm_list_vg_uuids(self->libh);
+	if (!uuids) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(self));
+		return NULL;
+	}
+
+	pytuple = PyTuple_New(dm_list_size(uuids));
+	if (!pytuple)
+		return NULL;
+
+	dm_list_iterate_items(strl, uuids) {
+		PyTuple_SET_ITEM(pytuple, i, PyString_FromString(strl->str));
+		i++;
+	}
+
+	return pytuple;
+}
+
+static PyObject *
+liblvm_lvm_percent_to_float(lvmobject *self, PyObject *arg)
+{
+	double converted;
+	int percent;
+
+	LVM_VALID(self);
+
+	if (!PyArg_ParseTuple(arg, "i", &percent))
+		return NULL;
+
+	converted = lvm_percent_to_float(percent);
+	return Py_BuildValue("d", converted);
+}
+
+static PyObject *
+liblvm_lvm_vgname_from_pvid(lvmobject *self, PyObject *arg)
+{
+	const char *pvid;
+	const char *vgname;
+
+	LVM_VALID(self);
+
+	if (!PyArg_ParseTuple(arg, "s", &pvid))
+		return NULL;
+
+	if((vgname = lvm_vgname_from_pvid(self->libh, pvid)) == NULL) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(self));
+		return NULL;
+	}
+
+	return Py_BuildValue("s", vgname);
+}
+
+static PyObject *
+liblvm_lvm_vgname_from_device(lvmobject *self, PyObject *arg)
+{
+	const char *device;
+	const char *vgname;
+
+	LVM_VALID(self);
+
+	if (!PyArg_ParseTuple(arg, "s", &device))
+		return NULL;
+
+	if((vgname = lvm_vgname_from_device(self->libh, device)) == NULL) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(self));
+		return NULL;
+	}
+
+	return Py_BuildValue("s", vgname);
+}
+
+
+static PyObject *
+liblvm_lvm_config_find_bool(lvmobject *self, PyObject *arg)
+{
+	const char *config;
+	int rval;
+	PyObject *rc;
+
+	LVM_VALID(self);
+
+	if (!PyArg_ParseTuple(arg, "s", &config))
+		return NULL;
+
+	if ((rval = lvm_config_find_bool(self->libh, config, -10)) == -10) {
+		/* Retrieving error information yields no error in this case */
+		PyErr_Format(PyExc_ValueError, "config path not found");
+		return NULL;
+	}
+
+	rc = (rval) ? Py_True: Py_False;
+
+	Py_INCREF(rc);
+	return rc;
+}
+
+static PyObject *
+liblvm_lvm_config_reload(lvmobject *self)
+{
+	int rval;
+
+	LVM_VALID(self);
+
+	if((rval = lvm_config_reload(self->libh)) == -1) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(self));
+		return NULL;
+	}
+
+	Py_INCREF(Py_None);
+	return Py_None;
+}
+
+
+static PyObject *
+liblvm_lvm_scan(lvmobject *self)
+{
+	int rval;
+
+	LVM_VALID(self);
+
+	if((rval = lvm_scan(self->libh)) == -1) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(self));
+		return NULL;
+	}
+
+	Py_INCREF(Py_None);
+	return Py_None;
+}
+
+static PyObject *
+liblvm_lvm_config_override(lvmobject *self, PyObject *arg)
+{
+	const char *config;
+	int rval;
+
+	LVM_VALID(self);
+
+	if (!PyArg_ParseTuple(arg, "s", &config))
+		return NULL;
+
+	if ((rval = lvm_config_override(self->libh, config)) == -1) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(self));
+		return NULL;
+	}
+
+	Py_INCREF(Py_None);
+	return Py_None;
+}
+/* ----------------------------------------------------------------------
+ * VG object initialization/deallocation
+ */
+
+
+static PyObject *
+liblvm_lvm_vg_open(lvmobject *lvm, PyObject *args)
+{
+	const char *vgname;
+	const char *mode = NULL;
+
+	vgobject *self;
+
+	LVM_VALID(lvm);
+
+	if (!PyArg_ParseTuple(args, "s|s", &vgname, &mode)) {
+		return NULL;
+	}
+
+	if (mode == NULL)
+		mode = "r";
+
+	if ((self = PyObject_New(vgobject, &LibLVMvgType)) == NULL)
+		return NULL;
+
+	if ((self->vg = lvm_vg_open(lvm->libh, vgname, mode, 0))== NULL) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(lvm));
+		Py_DECREF(self);
+		return NULL;
+	}
+	self->lvm_obj = lvm;
+
+	return (PyObject *)self;
+}
+
+static PyObject *
+liblvm_lvm_vg_create(lvmobject *lvm, PyObject *args)
+{
+	const char *vgname;
+	vgobject *self;
+
+	LVM_VALID(lvm);
+
+	if (!PyArg_ParseTuple(args, "s", &vgname)) {
+		return NULL;
+	}
+
+	if ((self = PyObject_New(vgobject, &LibLVMvgType)) == NULL)
+		return NULL;
+
+	if ((self->vg = lvm_vg_create(lvm->libh, vgname))== NULL) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(lvm));
+		Py_DECREF(self);
+		return NULL;
+	}
+	self->lvm_obj = lvm;
+
+	return (PyObject *)self;
+}
+
+static void
+liblvm_vg_dealloc(vgobject *self)
+{
+	/* if already closed, don't reclose it */
+	if (self->vg != NULL)
+		lvm_vg_close(self->vg);
+	PyObject_Del(self);
+}
+
+/* VG Methods */
+
+#define VG_VALID(vgobject)						\
+	do {								\
+		if (!vgobject->vg) {					\
+			PyErr_SetString(PyExc_UnboundLocalError, "VG object invalid"); \
+			return NULL;					\
+		}							\
+	} while (0)
+
+static PyObject *
+liblvm_lvm_vg_close(vgobject *self)
+{
+	/* if already closed, don't reclose it */
+	if (self->vg != NULL)
+		lvm_vg_close(self->vg);
+
+	self->vg = NULL;
+
+	Py_INCREF(Py_None);
+	return Py_None;
+}
+
+static PyObject *
+liblvm_lvm_vg_get_name(vgobject *self)
+{
+	VG_VALID(self);
+
+	return Py_BuildValue("s", lvm_vg_get_name(self->vg));
+}
+
+
+static PyObject *
+liblvm_lvm_vg_get_uuid(vgobject *self)
+{
+	VG_VALID(self);
+
+	return Py_BuildValue("s", lvm_vg_get_uuid(self->vg));
+}
+
+static PyObject *
+liblvm_lvm_vg_remove(vgobject *self)
+{
+	int rval;
+
+	VG_VALID(self);
+
+	if ((rval = lvm_vg_remove(self->vg)) == -1)
+		goto error;
+
+	if (lvm_vg_write(self->vg) == -1)
+		goto error;
+
+	self->vg = NULL;
+
+	Py_INCREF(Py_None);
+	return Py_None;
+
+error:
+	PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+	return NULL;
+}
+
+static PyObject *
+liblvm_lvm_vg_extend(vgobject *self, PyObject *args)
+{
+	const char *device;
+	int rval;
+
+	VG_VALID(self);
+
+	if (!PyArg_ParseTuple(args, "s", &device)) {
+		return NULL;
+	}
+
+	if ((rval = lvm_vg_extend(self->vg, device)) == -1)
+		goto error;
+
+	if (lvm_vg_write(self->vg) == -1)
+		goto error;
+
+	Py_INCREF(Py_None);
+	return Py_None;
+
+error:
+	PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+	return NULL;
+}
+
+static PyObject *
+liblvm_lvm_vg_reduce(vgobject *self, PyObject *args)
+{
+	const char *device;
+	int rval;
+
+	VG_VALID(self);
+
+	if (!PyArg_ParseTuple(args, "s", &device)) {
+		return NULL;
+	}
+
+	if ((rval = lvm_vg_reduce(self->vg, device)) == -1)
+		goto error;
+
+	if (lvm_vg_write(self->vg) == -1)
+		goto error;
+
+	Py_INCREF(Py_None);
+	return Py_None;
+
+error:
+	PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+	return NULL;
+}
+
+static PyObject *
+liblvm_lvm_vg_add_tag(vgobject *self, PyObject *args)
+{
+	const char *tag;
+	int rval;
+
+	VG_VALID(self);
+
+	if (!PyArg_ParseTuple(args, "s", &tag)) {
+		return NULL;
+	}
+	if ((rval = lvm_vg_add_tag(self->vg, tag)) == -1)
+		goto error;
+
+	if (lvm_vg_write(self->vg) == -1)
+		goto error;
+
+	return Py_BuildValue("i", rval);
+
+error:
+	PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+	return NULL;
+}
+
+static PyObject *
+liblvm_lvm_vg_remove_tag(vgobject *self, PyObject *args)
+{
+	const char *tag;
+	int rval;
+
+	VG_VALID(self);
+
+	if (!PyArg_ParseTuple(args, "s", &tag)) {
+		return NULL;
+	}
+
+	if ((rval = lvm_vg_remove_tag(self->vg, tag)) == -1)
+		goto error;
+
+	if (lvm_vg_write(self->vg) == -1)
+		goto error;
+
+	Py_INCREF(Py_None);
+	return Py_None;
+
+error:
+	PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+	return NULL;
+
+}
+
+static PyObject *
+liblvm_lvm_vg_is_clustered(vgobject *self)
+{
+	PyObject *rval;
+
+	VG_VALID(self);
+
+	rval = ( lvm_vg_is_clustered(self->vg) == 1) ? Py_True : Py_False;
+
+	Py_INCREF(rval);
+	return rval;
+}
+
+static PyObject *
+liblvm_lvm_vg_is_exported(vgobject *self)
+{
+	PyObject *rval;
+
+	VG_VALID(self);
+
+	rval = ( lvm_vg_is_exported(self->vg) == 1) ? Py_True : Py_False;
+
+	Py_INCREF(rval);
+	return rval;
+}
+
+static PyObject *
+liblvm_lvm_vg_is_partial(vgobject *self)
+{
+	PyObject *rval;
+
+	VG_VALID(self);
+
+	rval = ( lvm_vg_is_partial(self->vg) == 1) ? Py_True : Py_False;
+
+	Py_INCREF(rval);
+	return rval;
+}
+
+static PyObject *
+liblvm_lvm_vg_get_seqno(vgobject *self)
+{
+	VG_VALID(self);
+
+	return Py_BuildValue("l", lvm_vg_get_seqno(self->vg));
+}
+
+static PyObject *
+liblvm_lvm_vg_get_size(vgobject *self)
+{
+	VG_VALID(self);
+
+	return Py_BuildValue("l", lvm_vg_get_size(self->vg));
+}
+
+static PyObject *
+liblvm_lvm_vg_get_free_size(vgobject *self)
+{
+	VG_VALID(self);
+
+	return Py_BuildValue("l", lvm_vg_get_free_size(self->vg));
+}
+
+static PyObject *
+liblvm_lvm_vg_get_extent_size(vgobject *self)
+{
+	VG_VALID(self);
+
+	return Py_BuildValue("l", lvm_vg_get_extent_size(self->vg));
+}
+
+static PyObject *
+liblvm_lvm_vg_get_extent_count(vgobject *self)
+{
+	VG_VALID(self);
+
+	return Py_BuildValue("l", lvm_vg_get_extent_count(self->vg));
+}
+
+static PyObject *
+liblvm_lvm_vg_get_free_extent_count(vgobject *self)
+{
+	VG_VALID(self);
+
+	return Py_BuildValue("l", lvm_vg_get_free_extent_count(self->vg));
+}
+
+/* Builds a python tuple ([string|number], bool) from a struct lvm_property_value */
+static PyObject *
+get_property(lvmobject *h, struct lvm_property_value *prop)
+{
+	PyObject *pytuple;
+	PyObject *setable;
+
+	if( !prop->is_valid ) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(h));
+		return NULL;
+	}
+
+	pytuple = PyTuple_New(2);
+	if (!pytuple)
+		return NULL;
+
+	if( prop->is_integer ) {
+		PyTuple_SET_ITEM(pytuple, 0, Py_BuildValue("K", prop->value.integer));
+	} else {
+		PyTuple_SET_ITEM(pytuple, 0, PyString_FromString(prop->value.string));
+	}
+
+	if (prop->is_settable) {
+		setable = Py_True;
+	} else {
+		setable = Py_False;
+	}
+
+	Py_INCREF(setable);
+	PyTuple_SET_ITEM(pytuple, 1, setable);
+	return pytuple;
+}
+
+/* This will return a tuple of (value, bool) with the value being a string or
+   integer and bool indicating if property is settable */
+static PyObject *
+liblvm_lvm_vg_get_property(vgobject *self,  PyObject *args)
+{
+	const char *name;
+	struct lvm_property_value prop_value;
+
+	VG_VALID(self);
+
+	if (!PyArg_ParseTuple(args, "s", &name))
+		return NULL;
+
+	prop_value = lvm_vg_get_property(self->vg, name);
+	return get_property(self->lvm_obj, &prop_value);
+}
+
+static PyObject *
+liblvm_lvm_vg_set_property(vgobject *self,  PyObject *args)
+{
+	const char *property_name = NULL;
+	PyObject *variant_type_arg = NULL;
+	struct lvm_property_value lvm_property;
+	char *string_value = NULL;
+
+	VG_VALID(self);
+
+	if (!PyArg_ParseTuple(args, "sO", &property_name, &variant_type_arg))
+		return NULL;
+
+	lvm_property = lvm_vg_get_property(self->vg, property_name);
+
+	if( !lvm_property.is_valid ) {
+		goto lvmerror;
+	}
+
+	if(PyObject_IsInstance(variant_type_arg, (PyObject*)&PyString_Type)) {
+
+		if (!lvm_property.is_string) {
+			PyErr_Format(PyExc_ValueError, "Property requires string value");
+			goto bail;
+		}
+
+		/* Based on cursory code inspection this path may cause a memory
+		   leak when calling into set_property, need to verify*/
+		string_value = strdup(PyString_AsString(variant_type_arg));
+		lvm_property.value.string = string_value;
+		if(!lvm_property.value.string) {
+			PyErr_NoMemory();
+			goto bail;
+		}
+
+	} else {
+
+		if (!lvm_property.is_integer) {
+			PyErr_Format(PyExc_ValueError, "Property requires numeric value");
+			goto bail;
+		}
+
+		if(PyObject_IsInstance(variant_type_arg, (PyObject*)&PyInt_Type)) {
+			int temp_py_int = PyInt_AsLong(variant_type_arg);
+
+			/* -1 could be valid, need to see if an exception was gen. */
+			if( -1 == temp_py_int ) {
+				if( PyErr_Occurred() ) {
+					goto bail;
+				}
+			}
+
+			if (temp_py_int < 0) {
+				PyErr_Format(PyExc_ValueError, "Positive integers only!");
+				goto bail;
+			}
+
+			lvm_property.value.integer = temp_py_int;
+		} else if(PyObject_IsInstance(variant_type_arg, (PyObject*)&PyLong_Type)){
+			/* This will fail on negative numbers */
+			unsigned long long temp_py_long = PyLong_AsUnsignedLongLong(variant_type_arg);
+			if( (unsigned long long)-1 == temp_py_long ) {
+				goto bail;
+			}
+
+			lvm_property.value.integer = temp_py_long;
+		} else {
+			PyErr_Format(PyExc_ValueError, "supported value types are numeric and string");
+			goto bail;
+		}
+	}
+
+	if( -1 == lvm_vg_set_property(self->vg, property_name, &lvm_property) ) {
+		goto lvmerror;
+	}
+
+	if( -1 == lvm_vg_write(self->vg)) {
+		goto lvmerror;
+	}
+
+	Py_DECREF(variant_type_arg);
+	Py_INCREF(Py_None);
+	return Py_None;
+
+lvmerror:
+	PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+bail:
+	free(string_value);
+	if( variant_type_arg ) {
+		Py_DECREF(variant_type_arg);
+		variant_type_arg = NULL;
+	}
+	return NULL;
+}
+
+static PyObject *
+liblvm_lvm_vg_get_pv_count(vgobject *self)
+{
+	VG_VALID(self);
+
+	return Py_BuildValue("l", lvm_vg_get_pv_count(self->vg));
+}
+
+static PyObject *
+liblvm_lvm_vg_get_max_pv(vgobject *self)
+{
+	VG_VALID(self);
+
+	return Py_BuildValue("l", lvm_vg_get_max_pv(self->vg));
+}
+
+static PyObject *
+liblvm_lvm_vg_get_max_lv(vgobject *self)
+{
+	VG_VALID(self);
+
+	return Py_BuildValue("l", lvm_vg_get_max_lv(self->vg));
+}
+
+static PyObject *
+liblvm_lvm_vg_set_extent_size(vgobject *self, PyObject *args)
+{
+	uint32_t new_size;
+	int rval;
+
+	VG_VALID(self);
+
+	if (!PyArg_ParseTuple(args, "l", &new_size)) {
+		return NULL;
+	}
+
+	if ((rval = lvm_vg_set_extent_size(self->vg, new_size)) == -1) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+		return NULL;
+	}
+
+	Py_INCREF(Py_None);
+	return Py_None;
+}
+
+static PyObject *
+liblvm_lvm_vg_list_lvs(vgobject *vg)
+{
+	struct dm_list *lvs;
+	struct lvm_lv_list *lvl;
+	PyObject * pytuple;
+	lvobject * self;
+	int i = 0;
+
+	VG_VALID(vg);
+
+	/* unlike other LVM api calls, if there are no results, we get NULL */
+	lvs = lvm_vg_list_lvs(vg->vg);
+	if (!lvs)
+		return Py_BuildValue("()");
+
+	pytuple = PyTuple_New(dm_list_size(lvs));
+	if (!pytuple)
+		return NULL;
+
+	dm_list_iterate_items(lvl, lvs) {
+		/* Create and initialize the object */
+		self = PyObject_New(lvobject, &LibLVMlvType);
+		if (!self) {
+			Py_DECREF(pytuple);
+			return NULL;
+		}
+
+		self->lv = lvl->lv;
+		self->lvm_obj = vg->lvm_obj;
+		PyTuple_SET_ITEM(pytuple, i, (PyObject *) self);
+		i++;
+	}
+
+	return pytuple;
+}
+
+static PyObject *
+liblvm_lvm_vg_get_tags(vgobject *self)
+{
+	struct dm_list *tags;
+	struct lvm_str_list *strl;
+	PyObject * pytuple;
+	int i = 0;
+
+	VG_VALID(self);
+
+	tags = lvm_vg_get_tags(self->vg);
+	if (!tags) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+		return NULL;
+	}
+
+	pytuple = PyTuple_New(dm_list_size(tags));
+	if (!pytuple)
+		return NULL;
+
+	dm_list_iterate_items(strl, tags) {
+		PyTuple_SET_ITEM(pytuple, i, PyString_FromString(strl->str));
+		i++;
+	}
+
+	return pytuple;
+}
+
+static PyObject *
+liblvm_lvm_vg_create_lv_linear(vgobject *vg, PyObject *args)
+{
+	const char *vgname;
+	uint64_t size;
+	lvobject *self;
+
+	VG_VALID(vg);
+
+	if (!PyArg_ParseTuple(args, "sl", &vgname, &size)) {
+		return NULL;
+	}
+
+	if ((self = PyObject_New(lvobject, &LibLVMlvType)) == NULL)
+		return NULL;
+
+	if ((self->lv = lvm_vg_create_lv_linear(vg->vg, vgname, size))== NULL) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(vg->lvm_obj));
+		Py_DECREF(self);
+		return NULL;
+	}
+	self->lvm_obj = vg->lvm_obj;
+
+	return (PyObject *)self;
+}
+
+static void
+liblvm_lv_dealloc(lvobject *self)
+{
+	PyObject_Del(self);
+}
+
+static PyObject *
+liblvm_lvm_vg_list_pvs(vgobject *vg)
+{
+	struct dm_list *pvs;
+	struct lvm_pv_list *pvl;
+	PyObject * pytuple;
+	pvobject * self;
+	int i = 0;
+
+	VG_VALID(vg);
+
+	/* unlike other LVM api calls, if there are no results, we get NULL */
+	pvs = lvm_vg_list_pvs(vg->vg);
+	if (!pvs)
+		return Py_BuildValue("()");
+
+	pytuple = PyTuple_New(dm_list_size(pvs));
+	if (!pytuple)
+		return NULL;
+
+	dm_list_iterate_items(pvl, pvs) {
+		/* Create and initialize the object */
+		self = PyObject_New(pvobject, &LibLVMpvType);
+		if (!self) {
+			Py_DECREF(pytuple);
+			return NULL;
+		}
+
+		self->pv = pvl->pv;
+		self->lvm_obj = vg->lvm_obj;
+		PyTuple_SET_ITEM(pytuple, i, (PyObject *) self);
+		i++;
+	}
+
+	return pytuple;
+}
+
+typedef lv_t (*lv_fetch_by_N)(vg_t vg, const char *id);
+typedef pv_t (*pv_fetch_by_N)(vg_t vg, const char *id);
+
+static PyObject *
+liblvm_lvm_lv_from_N(vgobject *self, PyObject *arg, lv_fetch_by_N method)
+{
+	const char *id;
+	lvobject *rc;
+	lv_t lv = NULL;
+
+	VG_VALID(self);
+
+	if (!PyArg_ParseTuple(arg, "s", &id))
+		return NULL;
+
+	lv = method(self->vg, id);
+	if( !lv ) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+		return NULL;
+	}
+
+	rc = PyObject_New(lvobject, &LibLVMlvType);
+	if( !rc ) {
+		return NULL;
+	}
+
+	rc->lv = lv;
+	rc->lvm_obj = self->lvm_obj;
+	return (PyObject *)rc;
+}
+
+static PyObject *
+liblvm_lvm_lv_from_name(vgobject *self, PyObject *arg)
+{
+	return liblvm_lvm_lv_from_N(self, arg, lvm_lv_from_name);
+}
+
+static PyObject *
+liblvm_lvm_lv_from_uuid(vgobject *self, PyObject *arg)
+{
+	return liblvm_lvm_lv_from_N(self, arg, lvm_lv_from_uuid);
+}
+
+static PyObject *
+liblvm_lvm_pv_from_N(vgobject *self, PyObject *arg, pv_fetch_by_N method)
+{
+	const char *id;
+	pvobject *rc;
+	pv_t pv = NULL;
+
+	VG_VALID(self);
+
+	if (!PyArg_ParseTuple(arg, "s", &id))
+		return NULL;
+
+	pv = method(self->vg, id);
+	if( !pv ) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+		return NULL;
+	}
+
+	rc = PyObject_New(pvobject, &LibLVMpvType);
+	if( !rc ) {
+		return NULL;
+	}
+
+	rc->pv = pv;
+	rc->lvm_obj = self->lvm_obj;
+	return (PyObject *)rc;
+}
+
+static PyObject *
+liblvm_lvm_pv_from_name(vgobject *self, PyObject *arg)
+{
+	return liblvm_lvm_pv_from_N(self, arg, lvm_pv_from_name);
+}
+
+static PyObject *
+liblvm_lvm_pv_from_uuid(vgobject *self, PyObject *arg)
+{
+	return liblvm_lvm_pv_from_N(self, arg, lvm_pv_from_uuid);
+}
+
+static void
+liblvm_pv_dealloc(pvobject *self)
+{
+	PyObject_Del(self);
+}
+
+/* LV Methods */
+
+#define LV_VALID(lvobject)						\
+	do {								\
+		if (!lvobject->lv) {					\
+			PyErr_SetString(PyExc_UnboundLocalError, "LV object invalid"); \
+			return NULL;					\
+		}							\
+	} while (0)
+
+
+static PyObject *
+liblvm_lvm_lv_get_name(lvobject *self)
+{
+	LV_VALID(self);
+
+	return Py_BuildValue("s", lvm_lv_get_name(self->lv));
+}
+
+static PyObject *
+liblvm_lvm_lv_get_uuid(lvobject *self)
+{
+	LV_VALID(self);
+
+	return Py_BuildValue("s", lvm_lv_get_uuid(self->lv));
+}
+
+static PyObject *
+liblvm_lvm_lv_activate(lvobject *self)
+{
+	int rval;
+
+	LV_VALID(self);
+
+	if ((rval = lvm_lv_activate(self->lv)) == -1) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+		return NULL;
+	}
+
+	Py_INCREF(Py_None);
+	return Py_None;
+}
+
+static PyObject *
+liblvm_lvm_lv_deactivate(lvobject *self)
+{
+	int rval;
+
+	LV_VALID(self);
+
+	if ((rval = lvm_lv_deactivate(self->lv)) == -1) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+		return NULL;
+	}
+
+	Py_INCREF(Py_None);
+	return Py_None;
+}
+
+static PyObject *
+liblvm_lvm_vg_remove_lv(lvobject *self)
+{
+	int rval;
+
+	LV_VALID(self);
+
+	if ((rval = lvm_vg_remove_lv(self->lv)) == -1) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+		return NULL;
+	}
+
+	self->lv = NULL;
+
+	Py_INCREF(Py_None);
+	return Py_None;
+}
+
+/* This will return a tuple of (value, bool) with the value being a string or
+   integer and bool indicating if property is settable */
+static PyObject *
+liblvm_lvm_lv_get_property(lvobject *self,  PyObject *args)
+{
+	const char *name;
+	struct lvm_property_value prop_value;
+
+	LV_VALID(self);
+
+	if (!PyArg_ParseTuple(args, "s", &name))
+		return NULL;
+
+	prop_value = lvm_lv_get_property(self->lv, name);
+	return get_property(self->lvm_obj, &prop_value);
+}
+
+static PyObject *
+liblvm_lvm_lv_get_size(lvobject *self)
+{
+	LV_VALID(self);
+
+	return Py_BuildValue("l", lvm_lv_get_size(self->lv));
+}
+
+static PyObject *
+liblvm_lvm_lv_is_active(lvobject *self)
+{
+	PyObject *rval;
+
+	LV_VALID(self);
+
+	rval = ( lvm_lv_is_active(self->lv) == 1) ? Py_True : Py_False;
+
+	Py_INCREF(rval);
+	return rval;
+}
+
+static PyObject *
+liblvm_lvm_lv_is_suspended(lvobject *self)
+{
+	PyObject *rval;
+
+	LV_VALID(self);
+
+	rval = ( lvm_lv_is_suspended(self->lv) == 1) ? Py_True : Py_False;
+
+	Py_INCREF(rval);
+	return rval;
+}
+
+static PyObject *
+liblvm_lvm_lv_add_tag(lvobject *self, PyObject *args)
+{
+	const char *tag;
+	int rval;
+
+	LV_VALID(self);
+
+	if (!PyArg_ParseTuple(args, "s", &tag)) {
+		return NULL;
+	}
+
+	if ((rval = lvm_lv_add_tag(self->lv, tag)) == -1) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+		return NULL;
+	}
+
+	Py_INCREF(Py_None);
+	return Py_None;
+}
+
+static PyObject *
+liblvm_lvm_lv_remove_tag(lvobject *self, PyObject *args)
+{
+	const char *tag;
+	int rval;
+
+	LV_VALID(self);
+
+	if (!PyArg_ParseTuple(args, "s", &tag)) {
+		return NULL;
+	}
+
+	if ((rval = lvm_lv_remove_tag(self->lv, tag)) == -1) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+		return NULL;
+	}
+
+	Py_INCREF(Py_None);
+	return Py_None;
+}
+
+static PyObject *
+liblvm_lvm_lv_get_tags(lvobject *self)
+{
+	struct dm_list *tags;
+	struct lvm_str_list *strl;
+	PyObject * pytuple;
+	int i = 0;
+
+	LV_VALID(self);
+
+	tags = lvm_lv_get_tags(self->lv);
+	if (!tags) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+		return NULL;
+	}
+
+	pytuple = PyTuple_New(dm_list_size(tags));
+	if (!pytuple)
+		return NULL;
+
+	dm_list_iterate_items(strl, tags) {
+		PyTuple_SET_ITEM(pytuple, i, PyString_FromString(strl->str));
+		i++;
+	}
+
+	return pytuple;
+}
+
+static PyObject *
+liblvm_lvm_lv_rename(lvobject *self, PyObject *args)
+{
+	const char *new_name;
+	int rval;
+
+	LV_VALID(self);
+
+	if (!PyArg_ParseTuple(args, "s", &new_name))
+		return NULL;
+
+	if ((rval = lvm_lv_rename(self->lv, new_name)) == -1) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+		return NULL;
+	}
+
+	Py_INCREF(Py_None);
+	return Py_None;
+}
+
+static PyObject *
+liblvm_lvm_lv_resize(lvobject *self, PyObject *args)
+{
+	uint64_t new_size;
+	int rval;
+
+	LV_VALID(self);
+
+	if (!PyArg_ParseTuple(args, "l", &new_size)) {
+		return NULL;
+	}
+
+	if ((rval = lvm_lv_resize(self->lv, new_size)) == -1) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+		return NULL;
+	}
+
+	Py_INCREF(Py_None);
+	return Py_None;
+}
+
+static PyObject *
+liblvm_lvm_lv_list_lvsegs(lvobject *lv)
+{
+	struct dm_list  *lvsegs;
+	lvseg_list_t    *lvsegl;
+	PyObject * pytuple;
+	lvsegobject *self;
+	int i = 0;
+
+	LV_VALID(lv);
+
+	lvsegs = lvm_lv_list_lvsegs(lv->lv);
+	if(!lvsegs) {
+		return Py_BuildValue("()");
+	}
+
+	pytuple = PyTuple_New(dm_list_size(lvsegs));
+	if (!pytuple)
+		return NULL;
+
+	dm_list_iterate_items(lvsegl, lvsegs) {
+		/* Create and initialize the object */
+		self = PyObject_New(lvsegobject, &LibLVMlvsegType);
+		if (!self) {
+			Py_DECREF(pytuple);
+			return NULL;
+		}
+
+		self->lv_seg = lvsegl->lvseg;
+		self->lvm_obj = lv->lvm_obj;
+		PyTuple_SET_ITEM(pytuple, i, (PyObject *) self);
+		i++;
+	}
+
+	return pytuple;
+}
+
+/* PV Methods */
+
+#define PV_VALID(pvobject)						\
+	do {								\
+		if (!pvobject->pv || !pvobject->lvm_obj) {		\
+			PyErr_SetString(PyExc_UnboundLocalError, "PV object invalid"); \
+			return NULL;					\
+		}							\
+	} while (0)
+
+static PyObject *
+liblvm_lvm_pv_get_name(pvobject *self)
+{
+	return Py_BuildValue("s", lvm_pv_get_name(self->pv));
+}
+
+static PyObject *
+liblvm_lvm_pv_get_uuid(pvobject *self)
+{
+	return Py_BuildValue("s", lvm_pv_get_uuid(self->pv));
+}
+
+static PyObject *
+liblvm_lvm_pv_get_mda_count(pvobject *self)
+{
+	return Py_BuildValue("l", lvm_pv_get_mda_count(self->pv));
+}
+
+static PyObject *
+liblvm_lvm_pv_get_property(pvobject *self,  PyObject *args)
+{
+	const char *name;
+	struct lvm_property_value prop_value;
+
+	PV_VALID(self);
+
+	if (!PyArg_ParseTuple(args, "s", &name))
+		return NULL;
+
+	prop_value = lvm_pv_get_property(self->pv, name);
+	return get_property(self->lvm_obj, &prop_value);
+}
+
+static PyObject *
+liblvm_lvm_pv_get_dev_size(pvobject *self)
+{
+	return Py_BuildValue("l", lvm_pv_get_dev_size(self->pv));
+}
+
+static PyObject *
+liblvm_lvm_pv_get_size(pvobject *self)
+{
+	return Py_BuildValue("l", lvm_pv_get_size(self->pv));
+}
+
+static PyObject *
+liblvm_lvm_pv_get_free(pvobject *self)
+{
+	return Py_BuildValue("l", lvm_pv_get_free(self->pv));
+}
+
+static PyObject *
+liblvm_lvm_pv_resize(pvobject *self, PyObject *args)
+{
+	uint64_t new_size;
+	int rval;
+
+	if (!PyArg_ParseTuple(args, "l", &new_size)) {
+		return NULL;
+	}
+
+	if ((rval = lvm_pv_resize(self->pv, new_size)) == -1) {
+		PyErr_SetObject(LibLVMError, liblvm_get_last_error(self->lvm_obj));
+		return NULL;
+	}
+
+	Py_INCREF(Py_None);
+	return Py_None;
+}
+
+static PyObject *
+liblvm_lvm_lv_list_pvsegs(pvobject *pv)
+{
+	struct dm_list *pvsegs;
+	pvseg_list_t *pvsegl;
+	PyObject *pytuple;
+	pvsegobject *self;
+	int i = 0;
+
+	PV_VALID(pv);
+
+	pvsegs = lvm_pv_list_pvsegs(pv->pv);
+	if(!pvsegs) {
+		return Py_BuildValue("()");
+	}
+
+	pytuple = PyTuple_New(dm_list_size(pvsegs));
+	if (!pytuple)
+		return NULL;
+
+	dm_list_iterate_items(pvsegl, pvsegs) {
+		/* Create and initialize the object */
+		self = PyObject_New(pvsegobject, &LibLVMpvsegType);
+		if (!self) {
+			Py_DECREF(pytuple);
+			return NULL;
+		}
+
+		self->pv_seg = pvsegl->pvseg;
+		self->lvm_obj = pv->lvm_obj;
+		PyTuple_SET_ITEM(pytuple, i, (PyObject *) self);
+		i++;
+	}
+
+	return pytuple;
+}
+
+/* LV seg methods */
+
+static void
+liblvm_lvseg_dealloc(lvsegobject *self)
+{
+	PyObject_Del(self);
+}
+
+static PyObject *
+liblvm_lvm_lvseg_get_property(lvsegobject *self,  PyObject *args)
+{
+	const char *name;
+	struct lvm_property_value prop_value;
+
+	if (!PyArg_ParseTuple(args, "s", &name))
+		return NULL;
+
+	prop_value = lvm_lvseg_get_property(self->lv_seg, name);
+	return get_property(self->lvm_obj, &prop_value);
+}
+
+/* PV seg methods */
+
+static void
+liblvm_pvseg_dealloc(pvsegobject *self)
+{
+	PyObject_Del(self);
+}
+
+static PyObject *
+liblvm_lvm_pvseg_get_property(pvsegobject *self,  PyObject *args)
+{
+	const char *name;
+	struct lvm_property_value prop_value;
+
+	if (!PyArg_ParseTuple(args, "s", &name))
+		return NULL;
+
+	prop_value = lvm_pvseg_get_property(self->pv_seg, name);
+	return get_property(self->lvm_obj, &prop_value);
+}
+
+/* ----------------------------------------------------------------------
+ * Method tables and other bureaucracy
+ */
+
+static PyMethodDef Liblvm_methods[] = {
+	/* LVM methods */
+	{ "getVersion",		(PyCFunction)liblvm_library_get_version, METH_NOARGS },
+	{ "vgOpen",		(PyCFunction)liblvm_lvm_vg_open, METH_VARARGS },
+	{ "vgCreate",		(PyCFunction)liblvm_lvm_vg_create, METH_VARARGS },
+	{ "close",		(PyCFunction)liblvm_close, METH_NOARGS },
+	{ "configFindBool",	(PyCFunction)liblvm_lvm_config_find_bool, METH_VARARGS },
+	{ "configReload",	(PyCFunction)liblvm_lvm_config_reload, METH_NOARGS },
+	{ "configOverride",	(PyCFunction)liblvm_lvm_config_override, METH_VARARGS },
+	{ "scan",		(PyCFunction)liblvm_lvm_scan, METH_NOARGS },
+	{ "listVgNames",	(PyCFunction)liblvm_lvm_list_vg_names, METH_NOARGS },
+	{ "listVgUuids",	(PyCFunction)liblvm_lvm_list_vg_uuids, METH_NOARGS },
+	{ "percentToFloat",	(PyCFunction)liblvm_lvm_percent_to_float, METH_VARARGS },
+	{ "vgNameFromPvid",	(PyCFunction)liblvm_lvm_vgname_from_pvid, METH_VARARGS },
+	{ "vgNameFromDevice",	(PyCFunction)liblvm_lvm_vgname_from_device, METH_VARARGS },
+	{ NULL,	     NULL}	   /* sentinel */
+};
+
+static PyMethodDef liblvm_vg_methods[] = {
+	/* vg methods */
+	{ "getName",		(PyCFunction)liblvm_lvm_vg_get_name, METH_NOARGS },
+	{ "getUuid",		(PyCFunction)liblvm_lvm_vg_get_uuid, METH_NOARGS },
+	{ "close",		(PyCFunction)liblvm_lvm_vg_close, METH_NOARGS },
+	{ "remove",		(PyCFunction)liblvm_lvm_vg_remove, METH_NOARGS },
+	{ "extend",		(PyCFunction)liblvm_lvm_vg_extend, METH_VARARGS },
+	{ "reduce",		(PyCFunction)liblvm_lvm_vg_reduce, METH_VARARGS },
+	{ "addTag",		(PyCFunction)liblvm_lvm_vg_add_tag, METH_VARARGS },
+	{ "removeTag",		(PyCFunction)liblvm_lvm_vg_remove_tag, METH_VARARGS },
+	{ "setExtentSize",	(PyCFunction)liblvm_lvm_vg_set_extent_size, METH_VARARGS },
+	{ "isClustered",	(PyCFunction)liblvm_lvm_vg_is_clustered, METH_NOARGS },
+	{ "isExported",		(PyCFunction)liblvm_lvm_vg_is_exported, METH_NOARGS },
+	{ "isPartial",		(PyCFunction)liblvm_lvm_vg_is_partial, METH_NOARGS },
+	{ "getSeqno",		(PyCFunction)liblvm_lvm_vg_get_seqno, METH_NOARGS },
+	{ "getSize",		(PyCFunction)liblvm_lvm_vg_get_size, METH_NOARGS },
+	{ "getFreeSize",	(PyCFunction)liblvm_lvm_vg_get_free_size, METH_NOARGS },
+	{ "getExtentSize",	(PyCFunction)liblvm_lvm_vg_get_extent_size, METH_NOARGS },
+	{ "getExtentCount",	(PyCFunction)liblvm_lvm_vg_get_extent_count, METH_NOARGS },
+	{ "getFreeExtentCount",	(PyCFunction)liblvm_lvm_vg_get_free_extent_count, METH_NOARGS },
+	{ "getProperty",	(PyCFunction)liblvm_lvm_vg_get_property, METH_VARARGS },
+	{ "setProperty",	(PyCFunction)liblvm_lvm_vg_set_property, METH_VARARGS },
+	{ "getPvCount",		(PyCFunction)liblvm_lvm_vg_get_pv_count, METH_NOARGS },
+	{ "getMaxPv",		(PyCFunction)liblvm_lvm_vg_get_max_pv, METH_NOARGS },
+	{ "getMaxLv",		(PyCFunction)liblvm_lvm_vg_get_max_lv, METH_NOARGS },
+	{ "listLVs",		(PyCFunction)liblvm_lvm_vg_list_lvs, METH_NOARGS },
+	{ "listPVs",		(PyCFunction)liblvm_lvm_vg_list_pvs, METH_NOARGS },
+	{ "lvFromName", 	(PyCFunction)liblvm_lvm_lv_from_name, METH_VARARGS },
+	{ "lvFromUuid", 	(PyCFunction)liblvm_lvm_lv_from_uuid, METH_VARARGS },
+	{ "pvFromName", 	(PyCFunction)liblvm_lvm_pv_from_name, METH_VARARGS },
+	{ "pvFromUuid", 	(PyCFunction)liblvm_lvm_pv_from_uuid, METH_VARARGS },
+	{ "getTags",		(PyCFunction)liblvm_lvm_vg_get_tags, METH_NOARGS },
+	{ "createLvLinear",	(PyCFunction)liblvm_lvm_vg_create_lv_linear, METH_VARARGS },
+	{ NULL,	     NULL}   /* sentinel */
+};
+
+static PyMethodDef liblvm_lv_methods[] = {
+	/* lv methods */
+	{ "getName",		(PyCFunction)liblvm_lvm_lv_get_name, METH_NOARGS },
+	{ "getUuid",		(PyCFunction)liblvm_lvm_lv_get_uuid, METH_NOARGS },
+	{ "activate",		(PyCFunction)liblvm_lvm_lv_activate, METH_NOARGS },
+	{ "deactivate",		(PyCFunction)liblvm_lvm_lv_deactivate, METH_NOARGS },
+	{ "remove",		(PyCFunction)liblvm_lvm_vg_remove_lv, METH_NOARGS },
+	{ "getProperty",	(PyCFunction)liblvm_lvm_lv_get_property, METH_VARARGS },
+	{ "getSize",		(PyCFunction)liblvm_lvm_lv_get_size, METH_NOARGS },
+	{ "isActive",		(PyCFunction)liblvm_lvm_lv_is_active, METH_NOARGS },
+	{ "isSuspended",	(PyCFunction)liblvm_lvm_lv_is_suspended, METH_NOARGS },
+	{ "addTag",		(PyCFunction)liblvm_lvm_lv_add_tag, METH_VARARGS },
+	{ "removeTag",		(PyCFunction)liblvm_lvm_lv_remove_tag, METH_VARARGS },
+	{ "getTags",		(PyCFunction)liblvm_lvm_lv_get_tags, METH_NOARGS },
+	{ "rename",		(PyCFunction)liblvm_lvm_lv_rename, METH_VARARGS },
+	{ "resize",		(PyCFunction)liblvm_lvm_lv_resize, METH_VARARGS },
+	{ "listLVsegs",		(PyCFunction)liblvm_lvm_lv_list_lvsegs, METH_NOARGS },
+	{ NULL,	     NULL}   /* sentinel */
+};
+
+static PyMethodDef liblvm_pv_methods[] = {
+	/* pv methods */
+	{ "getName",		(PyCFunction)liblvm_lvm_pv_get_name, METH_NOARGS },
+	{ "getUuid",		(PyCFunction)liblvm_lvm_pv_get_uuid, METH_NOARGS },
+	{ "getMdaCount",	(PyCFunction)liblvm_lvm_pv_get_mda_count, METH_NOARGS },
+	{ "getProperty",	(PyCFunction)liblvm_lvm_pv_get_property, METH_VARARGS },
+	{ "getSize",		(PyCFunction)liblvm_lvm_pv_get_size, METH_NOARGS },
+	{ "getDevSize",		(PyCFunction)liblvm_lvm_pv_get_dev_size, METH_NOARGS },
+	{ "getFree",		(PyCFunction)liblvm_lvm_pv_get_free, METH_NOARGS },
+	{ "resize",		(PyCFunction)liblvm_lvm_pv_resize, METH_VARARGS },
+	{ "listPVsegs", 	(PyCFunction)liblvm_lvm_lv_list_pvsegs, METH_NOARGS },
+	{ NULL,	     NULL}   /* sentinel */
+};
+
+static PyMethodDef liblvm_lvseg_methods[] = {
+	{ "getProperty", 	(PyCFunction)liblvm_lvm_lvseg_get_property, METH_VARARGS },
+	{ NULL,	     NULL}   /* sentinel */
+};
+
+static PyMethodDef liblvm_pvseg_methods[] = {
+	{ "getProperty", 	(PyCFunction)liblvm_lvm_pvseg_get_property, METH_VARARGS },
+	{ NULL,	     NULL}   /* sentinel */
+};
+
+static PyTypeObject LiblvmType = {
+	PyObject_HEAD_INIT(&PyType_Type)
+	.tp_name = "liblvm.Liblvm",
+	.tp_basicsize = sizeof(lvmobject),
+	.tp_new = PyType_GenericNew,
+	.tp_dealloc = (destructor)liblvm_dealloc,
+	.tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_BASETYPE,
+	.tp_doc = "Liblvm objects",
+	.tp_methods = Liblvm_methods,
+	.tp_init = (initproc)liblvm_init,
+};
+
+static PyTypeObject LibLVMvgType = {
+	PyObject_HEAD_INIT(&PyType_Type)
+	.tp_name = "liblvm.Liblvm_vg",
+	.tp_basicsize = sizeof(vgobject),
+	.tp_new = PyType_GenericNew,
+	.tp_dealloc = (destructor)liblvm_vg_dealloc,
+	.tp_flags = Py_TPFLAGS_DEFAULT,
+	.tp_doc = "LVM Volume Group object",
+	.tp_methods = liblvm_vg_methods,
+};
+
+static PyTypeObject LibLVMlvType = {
+	PyObject_HEAD_INIT(&PyType_Type)
+	.tp_name = "liblvm.Liblvm_lv",
+	.tp_basicsize = sizeof(lvobject),
+	.tp_new = PyType_GenericNew,
+	.tp_dealloc = (destructor)liblvm_lv_dealloc,
+	.tp_flags = Py_TPFLAGS_DEFAULT,
+	.tp_doc = "LVM Logical Volume object",
+	.tp_methods = liblvm_lv_methods,
+};
+
+static PyTypeObject LibLVMpvType = {
+	PyObject_HEAD_INIT(&PyType_Type)
+	.tp_name = "liblvm.Liblvm_pv",
+	.tp_basicsize = sizeof(pvobject),
+	.tp_new = PyType_GenericNew,
+	.tp_dealloc = (destructor)liblvm_pv_dealloc,
+	.tp_flags = Py_TPFLAGS_DEFAULT,
+	.tp_doc = "LVM Physical Volume object",
+	.tp_methods = liblvm_pv_methods,
+};
+
+static PyTypeObject LibLVMlvsegType = {
+	PyObject_HEAD_INIT(&PyType_Type)
+	.tp_name = "liblvm.Liblvm_lvseg",
+	.tp_basicsize = sizeof(lvsegobject),
+	.tp_new = PyType_GenericNew,
+	.tp_dealloc = (destructor)liblvm_lvseg_dealloc,
+	.tp_flags = Py_TPFLAGS_DEFAULT,
+	.tp_doc = "LVM Logical Volume Segment object",
+	.tp_methods = liblvm_lvseg_methods,
+};
+
+static PyTypeObject LibLVMpvsegType = {
+	PyObject_HEAD_INIT(&PyType_Type)
+	.tp_name = "liblvm.Liblvm_pvseg",
+	.tp_basicsize = sizeof(pvsegobject),
+	.tp_new = PyType_GenericNew,
+	.tp_dealloc = (destructor)liblvm_pvseg_dealloc,
+	.tp_flags = Py_TPFLAGS_DEFAULT,
+	.tp_doc = "LVM Physical Volume Segment object",
+	.tp_methods = liblvm_pvseg_methods,
+};
+
+PyMODINIT_FUNC
+initlvm(void)
+{
+	PyObject *m;
+
+	if (PyType_Ready(&LiblvmType) < 0)
+		return;
+	if (PyType_Ready(&LibLVMvgType) < 0)
+		return;
+	if (PyType_Ready(&LibLVMlvType) < 0)
+		return;
+	if (PyType_Ready(&LibLVMpvType) < 0)
+		return;
+	if (PyType_Ready(&LibLVMlvsegType) < 0)
+		return;
+	if (PyType_Ready(&LibLVMpvsegType) < 0)
+		return;
+
+	m = Py_InitModule3("lvm", Liblvm_methods, "Liblvm module");
+	if (m == NULL)
+		return;
+
+	Py_INCREF(&LiblvmType);
+	PyModule_AddObject(m, "Liblvm", (PyObject *)&LiblvmType);
+
+	LibLVMError = PyErr_NewException("Liblvm.LibLVMError",
+					 NULL, NULL);
+	if (LibLVMError) {
+		/* Each call to PyModule_AddObject decrefs it; compensate: */
+		Py_INCREF(LibLVMError);
+		Py_INCREF(LibLVMError);
+		PyModule_AddObject(m, "error", LibLVMError);
+		PyModule_AddObject(m, "LibLVMError", LibLVMError);
+	}
+
+}
diff --git a/python/setup.py.in b/python/setup.py.in
new file mode 100644
index 0000000..6a44482
--- /dev/null
+++ b/python/setup.py.in
@@ -0,0 +1,35 @@
+#
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This program is free software: you can redistribute it and/or modify
+# it under the terms of the GNU Lesser General Public License as published by
+# the Free Software Foundation, either version 2.1 of the License, or
+# (at your option) any later version.
+#
+# This program is distributed in the hope that it will be useful,
+# but WITHOUT ANY WARRANTY; without even the implied warranty of
+# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+# GNU Lesser General Public License for more details.
+#
+# You should have received a copy of the GNU Lesser General Public License
+# along with this program.  If not, see <http://www.gnu.org/licenses/>.
+
+from distutils.core import setup, Extension
+
+liblvm = Extension('lvm',
+                    sources = ['liblvm_python.c'],
+                    libraries= ['lvm2app'],
+                    library_dirs= ['@top_builddir@/liblvm'],
+                    include_dirs= ['@top_builddir@/include'])
+
+setup (name='lvm',
+       version=@LVM_VERSION@,
+       description='Python bindings for liblvm2',
+       license="LGPLv2+",
+       maintainer='LVM2 maintainers',
+       maintainer_email='linux-lvm at redhat.com',
+       url='http://sourceware.org/lvm2/',
+       ext_modules=[liblvm],
+)


