From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 23 Feb 2023 15:49:02 +0000 (GMT)
Subject: main - configure: update
Message-ID: <20230223154902.8A07A385840F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=86ac529b99d04cb7feb9b52fae3cbeda6144660c
Commit:        86ac529b99d04cb7feb9b52fae3cbeda6144660c
Parent:        551d27a327bdf504306ae047adb765100a81103d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 20 21:04:58 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 23 16:46:35 2023 +0100

configure: update

---
 configure    | 398 ++++++++++++++++++++++++++++++++++++++++++++++-------------
 make.tmpl.in |   1 +
 2 files changed, 315 insertions(+), 84 deletions(-)

diff --git a/configure b/configure
index c2eee6ba7..7f50d6fe3 100755
--- a/configure
+++ b/configure
@@ -651,18 +651,14 @@ ac_default_prefix=/usr
 ac_subst_vars='LTLIBOBJS
 usrsbindir
 usrlibdir
-tmpfilesdir
-udevdir
 udev_prefix
+udevdir
+tmpfilesdir
 tmpdir
-kernelvsn
 missingkernel
+kernelvsn
 kerneldir
 interface
-CMIRRORD_PIDFILE
-LVMLOCKD_PIDFILE
-LVMPOLLD_PIDFILE
-DMEVENTD_PIDFILE
 WRITE_INSTALL
 WRITECACHE
 VDO_LIB
@@ -670,37 +666,39 @@ VDO_INCLUDE
 VDO
 VALGRIND_POOL
 USRSBINDIR
-SILENT_RULES
 USE_TRACKING
-UDEV_HAS_BUILTIN_BLKID
-UDEV_RULE_EXEC_DETECTION
 UDEV_SYNC
+UDEV_STATIC_LIBS
+UDEV_RULE_EXEC_DETECTION
 UDEV_RULES
 UDEV_PC
+UDEV_HAS_BUILTIN_BLKID
 THIN
 TESTSUITE_DATA
+SYSCONFDIR
 STATIC_LINK
+STATIC_LDFLAGS
 STATICDIR
 SNAPSHOTS
-SYSCONFDIR
+SILENT_RULES
+SELINUX_STATIC_LIBS
 SELINUX_PC
-SELINUX_LIBS
 SBINDIR
 RT_LIBS
 PYTHON3DIR
-PYTHON2DIR
 PYTHON3
+PYTHON2DIR
 PYTHON2
 PTHREAD_LIBS
-M_LIBS
 PKGCONFIG
 ODIRECT
 OCFDIR
 OCF
+M_LIBS
 MIRRORS
 MANGLING
-LVMIMPORTVDO_PATH
-LVMIMPORTVDO
+LVRESIZE_FS_HELPER_PATH
+LVM_VERSION
 LVM_RELEASE_DATE
 LVM_RELEASE
 LVM_PATH
@@ -708,23 +706,25 @@ LVM_PATCHLEVEL
 LVM_MINOR
 LVM_MAJOR
 LVM_LIBAPI
-LVM_VERSION
+LVMPOLLD_PIDFILE
+LVMLOCKD_PIDFILE
+LVMIMPORTVDO_PATH
+LVMIMPORTVDO
 LIB_SUFFIX
 LDDEPS
 JOBS
 INTL
 INTEGRITY
-BLKDEACTIVATE
-LVRESIZE_FS_HELPER_PATH
 FSADM_PATH
 FSADM
 ELDFLAGS
 DM_LIB_PATCHLEVEL
+DMEVENTD_PIDFILE
 DMEVENTD_PATH
 DL_LIBS
 DEVMAPPER
-DEFAULT_USE_LVMLOCKD
 DEFAULT_USE_LVMPOLLD
+DEFAULT_USE_LVMLOCKD
 DEFAULT_USE_DEVICES_FILE
 DEFAULT_USE_BLKID_WIPING
 DEFAULT_SYS_LOCK_DIR
@@ -743,30 +743,37 @@ DEFAULT_ARCHIVE_SUBDIR
 DEBUG
 COPTIMISE_FLAG
 CONFDIR
+CMIRRORD_PIDFILE
 CMDLIB
 CLDWHOLEARCHIVE
 CLDNOWHOLEARCHIVE
 CLDFLAGS
 CACHE
-BUILD_DMFILEMAPD
+BUILD_LVMPOLLD
+BUILD_LVMLOCKD
+BUILD_LVMDBUSD
+BUILD_LOCKDSANLOCK
 BUILD_LOCKDIDM
 BUILD_LOCKDDLM_CONTROL
 BUILD_LOCKDDLM
-BUILD_LOCKDSANLOCK
-BUILD_LVMLOCKD
-BUILD_LVMPOLLD
-BUILD_LVMDBUSD
+BUILD_DMFILEMAPD
 BUILD_DMEVENTD
 BUILD_CMIRRORD
+BLKID_STATIC_LIBS
 BLKID_PC
+BLKDEACTIVATE
 READLINE_LIBS
 READLINE_CFLAGS
+AIO_LIBS
+AIO_CFLAGS
 MODPROBE_CMD
 systemdutildir
 systemdsystemunitdir
 MSGFMT
 EDITLINE_LIBS
 EDITLINE_CFLAGS
+SELINUX_LIBS
+SELINUX_CFLAGS
 PYTHON3_CONFIG
 pkgpyexecdir
 pyexecdir
@@ -806,8 +813,6 @@ CPG_CFLAGS
 PKG_CONFIG_LIBDIR
 PKG_CONFIG_PATH
 PKG_CONFIG
-AIO_LIBS
-AIO_CFLAGS
 VDO_FORMAT_CMD
 CACHE_RESTORE_CMD
 CACHE_REPAIR_CMD
@@ -1020,8 +1025,6 @@ CXX
 CXXFLAGS
 CCC
 CPP
-AIO_CFLAGS
-AIO_LIBS
 PKG_CONFIG
 PKG_CONFIG_PATH
 PKG_CONFIG_LIBDIR
@@ -1044,10 +1047,14 @@ BLKID_LIBS
 UDEV_CFLAGS
 UDEV_LIBS
 PYTHON
+SELINUX_CFLAGS
+SELINUX_LIBS
 EDITLINE_CFLAGS
 EDITLINE_LIBS
 systemdsystemunitdir
 systemdutildir
+AIO_CFLAGS
+AIO_LIBS
 READLINE_CFLAGS
 READLINE_LIBS'
 
@@ -1831,8 +1838,6 @@ Some influential environment variables:
   CXX         C++ compiler command
   CXXFLAGS    C++ compiler flags
   CPP         C preprocessor
-  AIO_CFLAGS  C compiler flags for AIO
-  AIO_LIBS    linker flags for AIO
   PKG_CONFIG  path to pkg-config utility
   PKG_CONFIG_PATH
               directories to add to pkg-config's search path
@@ -1869,6 +1874,10 @@ Some influential environment variables:
   UDEV_CFLAGS C compiler flags for UDEV, overriding pkg-config
   UDEV_LIBS   linker flags for UDEV, overriding pkg-config
   PYTHON      the Python interpreter
+  SELINUX_CFLAGS
+              C compiler flags for SELINUX, overriding pkg-config
+  SELINUX_LIBS
+              linker flags for SELINUX, overriding pkg-config
   EDITLINE_CFLAGS
               C compiler flags for EDITLINE, overriding pkg-config
   EDITLINE_LIBS
@@ -1877,6 +1886,8 @@ Some influential environment variables:
               value of systemdsystemunitdir for systemd, overriding pkg-config
   systemdutildir
               value of systemdutildir for systemd, overriding pkg-config
+  AIO_CFLAGS  C compiler flags for AIO
+  AIO_LIBS    linker flags for AIO
   READLINE_CFLAGS
               C compiler flags for readline
   READLINE_LIBS
@@ -3707,12 +3718,12 @@ case "$host_os" in #(
 
 		# equivalent to -rdynamic
 		ELDFLAGS="-Wl,--export-dynamic"
+		STATIC_LDFLAGS="-Wl,--no-export-dynamic"
 		# FIXME Generate list and use --dynamic-list=.dlopen.sym
 		CLDWHOLEARCHIVE="-Wl,-whole-archive"
 		CLDNOWHOLEARCHIVE="-Wl,-no-whole-archive"
 		LIB_SUFFIX="so"
 		DEVMAPPER="yes"
-		BUILD_LVMPOLLD="no"
 		ODIRECT="yes"
 		DM_IOCTLS="yes"
 		SELINUX="yes"
@@ -10917,14 +10928,6 @@ printf "%s\n" "#define INTEGRITY_INTERNAL 1" >>confdefs.h
     as_fn_error $? "--with-integrity parameter invalid" "$LINENO" 5 ;;
 esac
 
-################################################################################
-# Allow users to override default location for libaio
-# there seems to be no pkg-config support available
-AIO_CFLAGS=
-AIO_LIBS=${AIO_LIBS:--laio}
-
-
-
 ################################################################################
 # Check whether --enable-readline was given.
 if test ${enable_readline+y}
@@ -10986,7 +10989,10 @@ fi
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for default run directory" >&5
 printf %s "checking for default run directory... " >&6; }
 RUN_DIR="/run"
-test -d "/run" || RUN_DIR="/var/run"
+if test ! -d "$RUN_DIR"
+then :
+  RUN_DIR="/var/run"
+fi
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $RUN_DIR" >&5
 printf "%s\n" "$RUN_DIR" >&6; }
 
@@ -11037,15 +11043,13 @@ printf %s "checking whether to build cluster mirror log daemon... " >&6; }
 # Check whether --enable-cmirrord was given.
 if test ${enable_cmirrord+y}
 then :
-  enableval=$enable_cmirrord; CMIRRORD=$enableval
+  enableval=$enable_cmirrord; BUILD_CMIRRORD=$enableval
 else $as_nop
-  CMIRRORD="no"
+  BUILD_CMIRRORD="no"
 fi
 
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CMIRRORD" >&5
-printf "%s\n" "$CMIRRORD" >&6; }
-
-BUILD_CMIRRORD=$CMIRRORD
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BUILD_CMIRRORD" >&5
+printf "%s\n" "$BUILD_CMIRRORD" >&6; }
 
 ################################################################################
 if test "$BUILD_CMIRRORD" = "yes"
@@ -12010,12 +12014,11 @@ printf %s "checking whether to build lvmpolld... " >&6; }
 # Check whether --enable-lvmpolld was given.
 if test ${enable_lvmpolld+y}
 then :
-  enableval=$enable_lvmpolld; LVMPOLLD=$enableval
+  enableval=$enable_lvmpolld; BUILD_LVMPOLLD=$enableval
 else $as_nop
-  LVMPOLLD="no"
+  BUILD_LVMPOLLD="no"
 fi
 
-test -n "$LVMPOLLD" && BUILD_LVMPOLLD=$LVMPOLLD
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BUILD_LVMPOLLD" >&5
 printf "%s\n" "$BUILD_LVMPOLLD" >&6; }
 
@@ -12097,11 +12100,31 @@ fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$LIBSANLOCKCLIENT_PKG_ERRORS" >&5
 
-	$bailout
+	as_fn_error $? "Package requirements (libsanlock_client >= 3.3.0) were not met:
+
+$LIBSANLOCKCLIENT_PKG_ERRORS
+
+Consider adjusting the PKG_CONFIG_PATH environment variable if you
+installed software in a non-standard prefix.
+
+Alternatively, you may set the environment variables LIBSANLOCKCLIENT_CFLAGS
+and LIBSANLOCKCLIENT_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details." "$LINENO" 5
 elif test $pkg_failed = untried; then
      	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
-	$bailout
+	{ { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
+as_fn_error $? "The pkg-config script could not be found or is too old.  Make sure it
+is in your PATH or set the PKG_CONFIG environment variable to the full
+path to pkg-config.
+
+Alternatively, you may set the environment variables LIBSANLOCKCLIENT_CFLAGS
+and LIBSANLOCKCLIENT_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details.
+
+To get pkg-config, see <http://pkg-config.freedesktop.org/>.
+See \`config.log' for more details" "$LINENO" 5; }
 else
 	LIBSANLOCKCLIENT_CFLAGS=$pkg_cv_LIBSANLOCKCLIENT_CFLAGS
 	LIBSANLOCKCLIENT_LIBS=$pkg_cv_LIBSANLOCKCLIENT_LIBS
@@ -12141,12 +12164,12 @@ if test -n "$LIBDLM_CFLAGS"; then
     pkg_cv_LIBDLM_CFLAGS="$LIBDLM_CFLAGS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libdlm\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "libdlm") 2>&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libdlm_lt\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "libdlm_lt") 2>&5
   ac_status=$?
   printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  pkg_cv_LIBDLM_CFLAGS=`$PKG_CONFIG --cflags "libdlm" 2>/dev/null`
+  pkg_cv_LIBDLM_CFLAGS=`$PKG_CONFIG --cflags "libdlm_lt" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
@@ -12158,12 +12181,12 @@ if test -n "$LIBDLM_LIBS"; then
     pkg_cv_LIBDLM_LIBS="$LIBDLM_LIBS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libdlm\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "libdlm") 2>&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libdlm_lt\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "libdlm_lt") 2>&5
   ac_status=$?
   printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  pkg_cv_LIBDLM_LIBS=`$PKG_CONFIG --libs "libdlm" 2>/dev/null`
+  pkg_cv_LIBDLM_LIBS=`$PKG_CONFIG --libs "libdlm_lt" 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
@@ -12184,18 +12207,38 @@ else
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        LIBDLM_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libdlm" 2>&1`
+	        LIBDLM_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libdlm_lt" 2>&1`
         else
-	        LIBDLM_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libdlm" 2>&1`
+	        LIBDLM_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libdlm_lt" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$LIBDLM_PKG_ERRORS" >&5
 
-	$bailout
+	as_fn_error $? "Package requirements (libdlm_lt) were not met:
+
+$LIBDLM_PKG_ERRORS
+
+Consider adjusting the PKG_CONFIG_PATH environment variable if you
+installed software in a non-standard prefix.
+
+Alternatively, you may set the environment variables LIBDLM_CFLAGS
+and LIBDLM_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details." "$LINENO" 5
 elif test $pkg_failed = untried; then
      	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
-	$bailout
+	{ { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
+as_fn_error $? "The pkg-config script could not be found or is too old.  Make sure it
+is in your PATH or set the PKG_CONFIG environment variable to the full
+path to pkg-config.
+
+Alternatively, you may set the environment variables LIBDLM_CFLAGS
+and LIBDLM_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details.
+
+To get pkg-config, see <http://pkg-config.freedesktop.org/>.
+See \`config.log' for more details" "$LINENO" 5; }
 else
 	LIBDLM_CFLAGS=$pkg_cv_LIBDLM_CFLAGS
 	LIBDLM_LIBS=$pkg_cv_LIBDLM_LIBS
@@ -12206,6 +12249,15 @@ fi
 
 printf "%s\n" "#define LOCKDDLM_SUPPORT 1" >>confdefs.h
 
+	case "$LIBDLM_LIBS" in #(
+  *lpthread*) :
+
+						{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: replacing pkg-config --libs libdlm_lt \"$LIBDLM_LIBS\" with... -ldlm_lt" >&5
+printf "%s\n" "replacing pkg-config --libs libdlm_lt \"$LIBDLM_LIBS\" with... -ldlm_lt" >&6; }
+			LIBDLM_LIBS="${LIBDLM_LIBS%%ldlm*}ldlm_lt" ;; #(
+  *) :
+     ;;
+esac
 
 fi
 
@@ -12285,11 +12337,31 @@ fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$LIBDLMCONTROL_PKG_ERRORS" >&5
 
-	$bailout
+	as_fn_error $? "Package requirements (libdlmcontrol >= 3.2) were not met:
+
+$LIBDLMCONTROL_PKG_ERRORS
+
+Consider adjusting the PKG_CONFIG_PATH environment variable if you
+installed software in a non-standard prefix.
+
+Alternatively, you may set the environment variables LIBDLMCONTROL_CFLAGS
+and LIBDLMCONTROL_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details." "$LINENO" 5
 elif test $pkg_failed = untried; then
      	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
-	$bailout
+	{ { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
+as_fn_error $? "The pkg-config script could not be found or is too old.  Make sure it
+is in your PATH or set the PKG_CONFIG environment variable to the full
+path to pkg-config.
+
+Alternatively, you may set the environment variables LIBDLMCONTROL_CFLAGS
+and LIBDLMCONTROL_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details.
+
+To get pkg-config, see <http://pkg-config.freedesktop.org/>.
+See \`config.log' for more details" "$LINENO" 5; }
 else
 	LIBDLMCONTROL_CFLAGS=$pkg_cv_LIBDLMCONTROL_CFLAGS
 	LIBDLMCONTROL_LIBS=$pkg_cv_LIBDLMCONTROL_LIBS
@@ -12386,11 +12458,31 @@ fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$LIBSEAGATEILM_PKG_ERRORS" >&5
 
-	$bailout
+	as_fn_error $? "Package requirements (libseagate_ilm >= 0.1.0) were not met:
+
+$LIBSEAGATEILM_PKG_ERRORS
+
+Consider adjusting the PKG_CONFIG_PATH environment variable if you
+installed software in a non-standard prefix.
+
+Alternatively, you may set the environment variables LIBSEAGATEILM_CFLAGS
+and LIBSEAGATEILM_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details." "$LINENO" 5
 elif test $pkg_failed = untried; then
      	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
-	$bailout
+	{ { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
+as_fn_error $? "The pkg-config script could not be found or is too old.  Make sure it
+is in your PATH or set the PKG_CONFIG environment variable to the full
+path to pkg-config.
+
+Alternatively, you may set the environment variables LIBSEAGATEILM_CFLAGS
+and LIBSEAGATEILM_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details.
+
+To get pkg-config, see <http://pkg-config.freedesktop.org/>.
+See \`config.log' for more details" "$LINENO" 5; }
 else
 	LIBSEAGATEILM_CFLAGS=$pkg_cv_LIBSEAGATEILM_CFLAGS
 	LIBSEAGATEILM_LIBS=$pkg_cv_LIBSEAGATEILM_LIBS
@@ -12401,6 +12493,10 @@ fi
 
 printf "%s\n" "#define LOCKDIDM_SUPPORT 1" >>confdefs.h
 
+		if test -z "$LIBSEAGATEILM_LIBS"
+then :
+  LIBSEAGATEILM_LIBS="-lseagate_ilm"
+fi
 
 else
   $bailout
@@ -12736,11 +12832,31 @@ fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$LIBSYSTEMD_PKG_ERRORS" >&5
 
-	$bailout
+	as_fn_error $? "Package requirements (libsystemd) were not met:
+
+$LIBSYSTEMD_PKG_ERRORS
+
+Consider adjusting the PKG_CONFIG_PATH environment variable if you
+installed software in a non-standard prefix.
+
+Alternatively, you may set the environment variables LIBSYSTEMD_CFLAGS
+and LIBSYSTEMD_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details." "$LINENO" 5
 elif test $pkg_failed = untried; then
      	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
-	$bailout
+	{ { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
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
 else
 	LIBSYSTEMD_CFLAGS=$pkg_cv_LIBSYSTEMD_CFLAGS
 	LIBSYSTEMD_LIBS=$pkg_cv_LIBSYSTEMD_LIBS
@@ -13054,6 +13170,7 @@ then :
 		BLKID_WIPING="yes"
 		BLKID_PC="blkid"
 		DEFAULT_USE_BLKID_WIPING=1
+		BLKID_STATIC_LIBS=$("$PKG_CONFIG" --static --libs blkid)
 
 printf "%s\n" "#define BLKID_WIPING_SUPPORT 1" >>confdefs.h
 
@@ -13190,6 +13307,7 @@ else
 printf "%s\n" "yes" >&6; }
 	UDEV_PC="libudev"
 fi
+	UDEV_STATIC_LIBS=$("$PKG_CONFIG" --static --libs libudev)
 
 printf "%s\n" "#define UDEV_SYNC_SUPPORT 1" >>confdefs.h
 
@@ -14367,9 +14485,108 @@ then :
 
 printf "%s\n" "#define HAVE_SEPOL 1" >>confdefs.h
 
-		SELINUX_LIBS="-lsepol"
+		SEPOL_LIBS="-lsepol"
+fi
+
+
+	if test -n "$PKG_CONFIG" && \
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libselinux\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "libselinux") 2>&5
+  ac_status=$?
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+
+pkg_failed=no
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for SELINUX" >&5
+printf %s "checking for SELINUX... " >&6; }
+
+if test -n "$SELINUX_CFLAGS"; then
+    pkg_cv_SELINUX_CFLAGS="$SELINUX_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libselinux\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "libselinux") 2>&5
+  ac_status=$?
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_SELINUX_CFLAGS=`$PKG_CONFIG --cflags "libselinux" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$SELINUX_LIBS"; then
+    pkg_cv_SELINUX_LIBS="$SELINUX_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libselinux\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "libselinux") 2>&5
+  ac_status=$?
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_SELINUX_LIBS=`$PKG_CONFIG --libs "libselinux" 2>/dev/null`
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
+   	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
+
+if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
+        _pkg_short_errors_supported=yes
+else
+        _pkg_short_errors_supported=no
 fi
+        if test $_pkg_short_errors_supported = yes; then
+	        SELINUX_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libselinux" 2>&1`
+        else
+	        SELINUX_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libselinux" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$SELINUX_PKG_ERRORS" >&5
 
+	as_fn_error $? "Package requirements (libselinux) were not met:
+
+$SELINUX_PKG_ERRORS
+
+Consider adjusting the PKG_CONFIG_PATH environment variable if you
+installed software in a non-standard prefix.
+
+Alternatively, you may set the environment variables SELINUX_CFLAGS
+and SELINUX_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details." "$LINENO" 5
+elif test $pkg_failed = untried; then
+     	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
+	{ { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
+as_fn_error $? "The pkg-config script could not be found or is too old.  Make sure it
+is in your PATH or set the PKG_CONFIG environment variable to the full
+path to pkg-config.
+
+Alternatively, you may set the environment variables SELINUX_CFLAGS
+and SELINUX_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details.
+
+To get pkg-config, see <http://pkg-config.freedesktop.org/>.
+See \`config.log' for more details" "$LINENO" 5; }
+else
+	SELINUX_CFLAGS=$pkg_cv_SELINUX_CFLAGS
+	SELINUX_LIBS=$pkg_cv_SELINUX_LIBS
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+printf "%s\n" "yes" >&6; }
+	SELINUX_STATIC_LIBS=$("$PKG_CONFIG" --static --libs libselinux)
+fi
+fi
 
 	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for is_selinux_enabled in -lselinux" >&5
 printf %s "checking for is_selinux_enabled in -lselinux... " >&6; }
@@ -14431,7 +14648,8 @@ fi
 
 printf "%s\n" "#define HAVE_SELINUX 1" >>confdefs.h
 
-		SELINUX_LIBS="-lselinux $SELINUX_LIBS"
+		SELINUX_LIBS=${SELINUX_LIBS:--lselinux}
+		SELINUX_STATIC_LIBS=${SELINUX_STATIC_LIBS:-$SELINUX_LIBS $SEPOL_LIBS}
 		SELINUX_PC="libselinux"
 		HAVE_SELINUX=yes
 else $as_nop
@@ -14439,6 +14657,7 @@ else $as_nop
 		{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: Disabling selinux" >&5
 printf "%s\n" "$as_me: WARNING: Disabling selinux" >&2;}
 		SELINUX_LIBS=
+		SELINUX_STATIC_LIBS=
 		SELINUX_PC=
 		HAVE_SELINUX=no
 fi
@@ -15724,9 +15943,6 @@ printf "%s\n" "#define LVRESIZE_FS_HELPER_PATH \"$LVRESIZE_FS_HELPER_PATH\"" >>c
 
 
 ################################################################################
-if test "$BUILD_DMEVENTD" = "yes"
-then :
-
 
 # Check whether --with-dmeventd-pidfile was given.
 if test ${with_dmeventd_pidfile+y}
@@ -15737,15 +15953,6 @@ else $as_nop
 fi
 
 
-printf "%s\n" "#define DMEVENTD_PIDFILE \"$DMEVENTD_PIDFILE\"" >>confdefs.h
-
-
-fi
-
-if test "$BUILD_DMEVENTD" = "yes"
-then :
-
-
 # Check whether --with-dmeventd-path was given.
 if test ${with_dmeventd_path+y}
 then :
@@ -15755,6 +15962,13 @@ else $as_nop
 fi
 
 
+if test "$BUILD_DMEVENTD" = "yes"
+then :
+
+
+printf "%s\n" "#define DMEVENTD_PIDFILE \"$DMEVENTD_PIDFILE\"" >>confdefs.h
+
+
 printf "%s\n" "#define DMEVENTD_PATH \"$DMEVENTD_PATH\"" >>confdefs.h
 
 
@@ -15860,7 +16074,10 @@ else $as_nop
   interface="ioctl"
 fi
 
-test "$interface" != "ioctl" && as_fn_error $? "--with-interface=ioctl required. fs no longer supported." "$LINENO" 5
+if test "$interface" != "ioctl"
+then :
+  as_fn_error $? "--with-interface=ioctl required. fs no longer supported." "$LINENO" 5
+fi
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $interface" >&5
 printf "%s\n" "$interface" >&6; }
 
@@ -15870,7 +16087,7 @@ read DM_LIB_VERSION < "$srcdir"/VERSION_DM 2>/dev/null || DM_LIB_VERSION="Unknow
 printf "%s\n" "#define DM_LIB_VERSION \"$DM_LIB_VERSION\"" >>confdefs.h
 
 
-DM_LIB_PATCHLEVEL=$(cat "$srcdir"/VERSION_DM | $AWK -F '[-. ]' '{printf "%s.%s.%s",$1,$2,$3}')
+DM_LIB_PATCHLEVEL=$($AWK -F '[-. ]' '{printf "%s.%s.%s",$1,$2,$3}' "$srcdir"/VERSION_DM)
 
 read VER < "$srcdir"/VERSION 2>/dev/null || VER=Unknown
 
@@ -15888,6 +16105,14 @@ LVM_LIBAPI=$(echo "$VER" | $AWK -F '[()]' '{print $2}')
 printf "%s\n" "#define LVM_CONFIGURE_LINE \"$CONFIGURE_LINE\"" >>confdefs.h
 
 
+################################################################################
+# Allow users to override default location for libaio
+# there seems to be no pkg-config support available
+AIO_CFLAGS=${AIO_CFLAGS:-}
+AIO_LIBS=${AIO_LIBS:--laio}
+
+
+
 
 
 
@@ -16018,6 +16243,11 @@ printf "%s\n" "#define LVM_CONFIGURE_LINE \"$CONFIGURE_LINE\"" >>confdefs.h
 
 
 
+
+
+
+
+
 
 
 
diff --git a/make.tmpl.in b/make.tmpl.in
index 6025c166c..20f8a5245 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -65,6 +65,7 @@ DEFS += @DEFS@
 CFLAGS ?= @COPTIMISE_FLAG@ @CFLAGS@
 CPPFLAGS ?= @CPPFLAGS@
 LDFLAGS ?= @LDFLAGS@
+STATIC_LDFLAGS += @STATIC_LDFLAGS@
 CLDFLAGS += @CLDFLAGS@
 ELDFLAGS += @ELDFLAGS@
 LDDEPS += @LDDEPS@

