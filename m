From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Oct 2008 22:12:57 -0000
Subject: LVM2 ./configure lib/misc/configure.h.in
Message-ID: <20081031221257.13162.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-10-31 22:12:56

Modified files:
	.              : configure 
	lib/misc       : configure.h.in 

Log message:
	autoreconf

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.79&r2=1.80
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/configure	2008/10/08 12:50:12	1.79
+++ LVM2/configure	2008/10/31 22:12:55	1.80
@@ -732,6 +732,11 @@
 STATICDIR
 STATIC_LINK
 LIB_PTHREAD
+interface
+kerneldir
+missingkernel
+kernelvsn
+tmpdir
 usrlibdir
 usrsbindir
 LTLIBOBJS'
@@ -1324,9 +1329,12 @@
   --disable-realtime      Disable realtime clock support
   --enable-debug          Enable debugging
   --enable-profiling      Gather gcov profiling data
-  --disable-devmapper     Disable device-mapper interaction
+  --disable-devmapper     Disable LVM2 device-mapper interaction
+  --enable-compat         Enable support for old device-mapper versions
+  --disable-driver        Disable calls to device-mapper in the kernel
   --disable-o_direct      Disable O_DIRECT
   --enable-cmdlib         Build shared command library
+  --enable-pkgconfig      Install pkgconfig support
   --enable-fsadm          Enable fsadm
   --enable-dmeventd       Enable the device-mapper event daemon
   --enable-static_link    Use this to link the tools to their libraries
@@ -1339,6 +1347,7 @@
   --without-PACKAGE       do not use PACKAGE (same as --with-PACKAGE=no)
   --with-user=USER        Set the owner of installed files [USER=root]
   --with-group=GROUP      Set the group owner of installed files [GROUP=root]
+  --with-device-mode=MODE Set the mode used for new device nodes [MODE=0600]
   --with-lvm1=TYPE        LVM1 metadata support: internal/shared/none
                           TYPE=internal
   --with-pool=TYPE        GFS pool read-only support: internal/shared/none
@@ -1358,6 +1367,9 @@
   --with-dmdir=DIR        Build against device-mapper source tree in DIR
   --with-usrlibdir=DIR
   --with-usrsbindir=DIR
+  --with-dmeventd-pidfile=PATH    dmeventd pidfile [/var/run/dmeventd.pid]
+  --with-dmeventd-path=PATH       dmeventd path [${exec_prefix}/sbin/dmeventd]
+  --with-interface=IFACE  Choose kernel interface (ioctl) [ioctl]
 
 Some influential environment variables:
   CC          C compiler command
@@ -1971,7 +1983,7 @@
 		SELINUX=yes
 		REALTIME=yes
 		CLUSTER=internal
-		FSADM=no
+		FSADM=yes
 		;;
 	darwin*)
 		CFLAGS="$CFLAGS -no-cpp-precomp -fno-common"
@@ -8423,6 +8435,21 @@
 fi
 
 ################################################################################
+{ echo "$as_me:$LINENO: checking device node mode" >&5
+echo $ECHO_N "checking device node mode... $ECHO_C" >&6; }
+
+
+# Check whether --with-device-mode was given.
+if test "${with_device_mode+set}" = set; then
+  withval=$with_device_mode;  DM_DEVICE_MODE="$withval"
+else
+   DM_DEVICE_MODE="0600"
+fi
+
+{ echo "$as_me:$LINENO: result: $DM_DEVICE_MODE" >&5
+echo "${ECHO_T}$DM_DEVICE_MODE" >&6; }
+
+################################################################################
 { echo "$as_me:$LINENO: checking whether to enable lvm1 fallback" >&5
 echo $ECHO_N "checking whether to enable lvm1 fallback... $ECHO_C" >&6; }
 # Check whether --enable-lvm1_fallback was given.
@@ -8791,6 +8818,22 @@
 fi
 
 ################################################################################
+# Check whether --enable-compat was given.
+if test "${enable_compat+set}" = set; then
+  enableval=$enable_compat; DM_COMPAT=$enableval
+else
+  DM_COMPAT=no
+fi
+
+
+################################################################################
+# Check whether --enable-ioctl was given.
+if test "${enable_ioctl+set}" = set; then
+  enableval=$enable_ioctl; DM_IOCTLS=$enableval
+fi
+
+
+################################################################################
 { echo "$as_me:$LINENO: checking whether to enable O_DIRECT" >&5
 echo $ECHO_N "checking whether to enable O_DIRECT... $ECHO_C" >&6; }
 # Check whether --enable-o_direct was given.
@@ -8826,6 +8869,14 @@
   && LVM2CMD_LIB=-llvm2cmd \
   || LVM2CMD_LIB=
 
+################################################################################
+# Check whether --enable-pkgconfig was given.
+if test "${enable_pkgconfig+set}" = set; then
+  enableval=$enable_pkgconfig; PKGCONFIG=$enableval
+else
+  PKGCONFIG=no
+fi
+
 
 ################################################################################
 { echo "$as_me:$LINENO: checking whether to install fsadm" >&5
@@ -8849,6 +8900,8 @@
 { echo "$as_me:$LINENO: result: $DMEVENTD" >&5
 echo "${ECHO_T}$DMEVENTD" >&6; }
 
+BUILD_DMEVENTD=$DMEVENTD
+
 if test x$DMEVENTD = xyes; then
    if test x$MIRRORS != xinternal; then
       { { echo "$as_me:$LINENO: error: --enable-dmeventd currently requires --with-mirrors=internal
@@ -8873,6 +8926,151 @@
 _ACEOF
 
 fi
+
+################################################################################
+
+{ echo "$as_me:$LINENO: checking for getline in -lc" >&5
+echo $ECHO_N "checking for getline in -lc... $ECHO_C" >&6; }
+if test "${ac_cv_lib_c_getline+set}" = set; then
+  echo $ECHO_N "(cached) $ECHO_C" >&6
+else
+  ac_check_lib_save_LIBS=$LIBS
+LIBS="-lc  $LIBS"
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+
+/* Override any GCC internal prototype to avoid an error.
+   Use char because int might match the return type of a GCC
+   builtin and then its argument prototype would still apply.  */
+#ifdef __cplusplus
+extern "C"
+#endif
+char getline ();
+int
+main ()
+{
+return getline ();
+  ;
+  return 0;
+}
+_ACEOF
+rm -f conftest.$ac_objext conftest$ac_exeext
+if { (ac_try="$ac_link"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval "echo \"\$as_me:$LINENO: $ac_try_echo\"") >&5
+  (eval "$ac_link") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       } && test -s conftest$ac_exeext &&
+       $as_test_x conftest$ac_exeext; then
+  ac_cv_lib_c_getline=yes
+else
+  echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	ac_cv_lib_c_getline=no
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest_ipa8_conftest.oo \
+      conftest$ac_exeext conftest.$ac_ext
+LIBS=$ac_check_lib_save_LIBS
+fi
+{ echo "$as_me:$LINENO: result: $ac_cv_lib_c_getline" >&5
+echo "${ECHO_T}$ac_cv_lib_c_getline" >&6; }
+if test $ac_cv_lib_c_getline = yes; then
+
+cat >>confdefs.h <<\_ACEOF
+#define HAVE_GETLINE 1
+_ACEOF
+
+fi
+
+
+################################################################################
+
+{ echo "$as_me:$LINENO: checking for canonicalize_file_name in -lc" >&5
+echo $ECHO_N "checking for canonicalize_file_name in -lc... $ECHO_C" >&6; }
+if test "${ac_cv_lib_c_canonicalize_file_name+set}" = set; then
+  echo $ECHO_N "(cached) $ECHO_C" >&6
+else
+  ac_check_lib_save_LIBS=$LIBS
+LIBS="-lc  $LIBS"
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+
+/* Override any GCC internal prototype to avoid an error.
+   Use char because int might match the return type of a GCC
+   builtin and then its argument prototype would still apply.  */
+#ifdef __cplusplus
+extern "C"
+#endif
+char canonicalize_file_name ();
+int
+main ()
+{
+return canonicalize_file_name ();
+  ;
+  return 0;
+}
+_ACEOF
+rm -f conftest.$ac_objext conftest$ac_exeext
+if { (ac_try="$ac_link"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval "echo \"\$as_me:$LINENO: $ac_try_echo\"") >&5
+  (eval "$ac_link") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       } && test -s conftest$ac_exeext &&
+       $as_test_x conftest$ac_exeext; then
+  ac_cv_lib_c_canonicalize_file_name=yes
+else
+  echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	ac_cv_lib_c_canonicalize_file_name=no
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest_ipa8_conftest.oo \
+      conftest$ac_exeext conftest.$ac_ext
+LIBS=$ac_check_lib_save_LIBS
+fi
+{ echo "$as_me:$LINENO: result: $ac_cv_lib_c_canonicalize_file_name" >&5
+echo "${ECHO_T}$ac_cv_lib_c_canonicalize_file_name" >&6; }
+if test $ac_cv_lib_c_canonicalize_file_name = yes; then
+
+cat >>confdefs.h <<\_ACEOF
+#define HAVE_CANONICALIZE_FILE_NAME 1
+_ACEOF
+
+fi
+
+
 ################################################################################
 if [ "x$exec_prefix" = xNONE -a "x$prefix" = xNONE ];
  then  exec_prefix="";
@@ -9793,6 +9991,7 @@
 echo "${ECHO_T}$INTL" >&6; }
 
 if test x$INTL = xyes; then
+# FIXME - Move this - can be device-mapper too
 	INTL_PACKAGE="lvm2"
 	# Extract the first word of "msgfmt", so it can be a program name with args.
 set dummy msgfmt; ac_word=$2
@@ -11517,6 +11716,73 @@
 fi
 
 ################################################################################
+
+
+if test "$BUILD_DMEVENTD" = yes; then
+
+# Check whether --with-dmeventd-pidfile was given.
+if test "${with_dmeventd_pidfile+set}" = set; then
+  withval=$with_dmeventd_pidfile;  cat >>confdefs.h <<_ACEOF
+#define DMEVENTD_PIDFILE "$withval"
+_ACEOF
+
+else
+   cat >>confdefs.h <<_ACEOF
+#define DMEVENTD_PIDFILE "/var/run/dmeventd.pid"
+_ACEOF
+
+fi
+
+fi
+
+
+
+if test "$BUILD_DMEVENTD" = yes; then
+        dmeventd_prefix="$exec_prefix"
+        if test "x$dmeventd_prefix" = "xNONE"; then
+                dmeventd_prefix="$prefix"
+        fi
+        if test "x$dmeventd_prefix" = "xNONE"; then
+                dmeventd_prefix=""
+        fi
+
+# Check whether --with-dmeventd-path was given.
+if test "${with_dmeventd_path+set}" = set; then
+  withval=$with_dmeventd_path;  cat >>confdefs.h <<_ACEOF
+#define DMEVENTD_PATH "$withval"
+_ACEOF
+
+else
+   cat >>confdefs.h <<_ACEOF
+#define DMEVENTD_PATH "$dmeventd_prefix/sbin/dmeventd"
+_ACEOF
+
+fi
+
+fi
+
+################################################################################
+{ echo "$as_me:$LINENO: checking for kernel interface choice" >&5
+echo $ECHO_N "checking for kernel interface choice... $ECHO_C" >&6; }
+
+# Check whether --with-interface was given.
+if test "${with_interface+set}" = set; then
+  withval=$with_interface;  interface="$withval"
+else
+   interface=ioctl
+fi
+
+if [ "x$interface" != xioctl ];
+then
+  { { echo "$as_me:$LINENO: error: --with-interface=ioctl required. fs no longer supported." >&5
+echo "$as_me: error: --with-interface=ioctl required. fs no longer supported." >&2;}
+   { (exit 1); exit 1; }; }
+fi
+{ echo "$as_me:$LINENO: result: $interface" >&5
+echo "${ECHO_T}$interface" >&6; }
+
+################################################################################
+DM_LIB_VERSION="\"`cat VERSION_LIB 2>/dev/null || echo Unknown`\""
 LVM_VERSION="\"`cat VERSION 2>/dev/null || echo Unknown`\""
 
 ################################################################################
@@ -11534,7 +11800,6 @@
 
 
 
-# FIXME: rename to LVM_USE_DMEVENTD
 
 
 
@@ -11556,7 +11821,11 @@
 
 
 
-# FIXME: rename to LVM_CONF_DIR
+
+
+
+
+
 
 
 
@@ -11572,7 +11841,7 @@
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl include/Makefile lib/Makefile man/Makefile po/Makefile dmeventd/Makefile daemons/Makefile daemons/clvmd/Makefile dmeventd/mirror/Makefile dmeventd/snapshot/Makefile doc/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/snapshot/Makefile test/Makefile scripts/Makefile tools/Makefile tools/version.h"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc man/Makefile po/Makefile scripts/Makefile test/Makefile tools/Makefile tools/version.h"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -12131,23 +12400,26 @@
     "lib/misc/configure.h") CONFIG_HEADERS="$CONFIG_HEADERS lib/misc/configure.h" ;;
     "Makefile") CONFIG_FILES="$CONFIG_FILES Makefile" ;;
     "make.tmpl") CONFIG_FILES="$CONFIG_FILES make.tmpl" ;;
-    "include/Makefile") CONFIG_FILES="$CONFIG_FILES include/Makefile" ;;
-    "lib/Makefile") CONFIG_FILES="$CONFIG_FILES lib/Makefile" ;;
-    "man/Makefile") CONFIG_FILES="$CONFIG_FILES man/Makefile" ;;
-    "po/Makefile") CONFIG_FILES="$CONFIG_FILES po/Makefile" ;;
-    "dmeventd/Makefile") CONFIG_FILES="$CONFIG_FILES dmeventd/Makefile" ;;
     "daemons/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/Makefile" ;;
     "daemons/clvmd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/clvmd/Makefile" ;;
-    "dmeventd/mirror/Makefile") CONFIG_FILES="$CONFIG_FILES dmeventd/mirror/Makefile" ;;
-    "dmeventd/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES dmeventd/snapshot/Makefile" ;;
+    "daemons/dmeventd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/Makefile" ;;
+    "daemons/dmeventd/libdevmapper-event.pc") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/libdevmapper-event.pc" ;;
+    "daemons/dmeventd/plugins/mirror/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/mirror/Makefile" ;;
+    "daemons/dmeventd/plugins/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/snapshot/Makefile" ;;
     "doc/Makefile") CONFIG_FILES="$CONFIG_FILES doc/Makefile" ;;
+    "include/Makefile") CONFIG_FILES="$CONFIG_FILES include/Makefile" ;;
+    "lib/Makefile") CONFIG_FILES="$CONFIG_FILES lib/Makefile" ;;
     "lib/format1/Makefile") CONFIG_FILES="$CONFIG_FILES lib/format1/Makefile" ;;
     "lib/format_pool/Makefile") CONFIG_FILES="$CONFIG_FILES lib/format_pool/Makefile" ;;
     "lib/locking/Makefile") CONFIG_FILES="$CONFIG_FILES lib/locking/Makefile" ;;
     "lib/mirror/Makefile") CONFIG_FILES="$CONFIG_FILES lib/mirror/Makefile" ;;
     "lib/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES lib/snapshot/Makefile" ;;
-    "test/Makefile") CONFIG_FILES="$CONFIG_FILES test/Makefile" ;;
+    "libdm/Makefile") CONFIG_FILES="$CONFIG_FILES libdm/Makefile" ;;
+    "libdm/libdevmapper.pc") CONFIG_FILES="$CONFIG_FILES libdm/libdevmapper.pc" ;;
+    "man/Makefile") CONFIG_FILES="$CONFIG_FILES man/Makefile" ;;
+    "po/Makefile") CONFIG_FILES="$CONFIG_FILES po/Makefile" ;;
     "scripts/Makefile") CONFIG_FILES="$CONFIG_FILES scripts/Makefile" ;;
+    "test/Makefile") CONFIG_FILES="$CONFIG_FILES test/Makefile" ;;
     "tools/Makefile") CONFIG_FILES="$CONFIG_FILES tools/Makefile" ;;
     "tools/version.h") CONFIG_FILES="$CONFIG_FILES tools/version.h" ;;
 
@@ -12370,12 +12642,17 @@
 STATICDIR!$STATICDIR$ac_delim
 STATIC_LINK!$STATIC_LINK$ac_delim
 LIB_PTHREAD!$LIB_PTHREAD$ac_delim
+interface!$interface$ac_delim
+kerneldir!$kerneldir$ac_delim
+missingkernel!$missingkernel$ac_delim
+kernelvsn!$kernelvsn$ac_delim
+tmpdir!$tmpdir$ac_delim
 usrlibdir!$usrlibdir$ac_delim
 usrsbindir!$usrsbindir$ac_delim
 LTLIBOBJS!$LTLIBOBJS$ac_delim
 _ACEOF
 
-  if test `sed -n "s/.*$ac_delim\$/X/p" conf$$subs.sed | grep -c X` = 24; then
+  if test `sed -n "s/.*$ac_delim\$/X/p" conf$$subs.sed | grep -c X` = 29; then
     break
   elif $ac_last_try; then
     { { echo "$as_me:$LINENO: error: could not make $CONFIG_STATUS" >&5
@@ -12815,13 +13092,3 @@
   { echo "$as_me:$LINENO: WARNING: Warning: O_DIRECT disabled: low-memory pvmove may lock up" >&5
 echo "$as_me: WARNING: Warning: O_DIRECT disabled: low-memory pvmove may lock up" >&2;}
 fi
-
-if test x$FSADM == xyes; then
-  { echo "$as_me:$LINENO: WARNING: fsadm support is untested" >&5
-echo "$as_me: WARNING: fsadm support is untested" >&2;}
-fi
-
-if test x$DMEVENTD == xyes; then
-  { echo "$as_me:$LINENO: WARNING: dmeventd support is untested" >&5
-echo "$as_me: WARNING: dmeventd support is untested" >&2;}
-fi
--- LVM2/lib/misc/configure.h.in	2008/10/07 19:11:59	1.6
+++ LVM2/lib/misc/configure.h.in	2008/10/31 22:12:56	1.7
@@ -14,12 +14,18 @@
 /* Define to 1 if using `alloca.c'. */
 #undef C_ALLOCA
 
-/* Define to 1 to enable device-mapper interaction. */
+/* Define to 1 to enable LVM2 device-mapper interaction. */
 #undef DEVMAPPER_SUPPORT
 
 /* Define to 1 to enable the device-mapper event daemon. */
 #undef DMEVENTD
 
+/* Path to dmeventd binary. */
+#undef DMEVENTD_PATH
+
+/* Path to dmeventd pidfile. */
+#undef DMEVENTD_PIDFILE
+
 /* Define to 1 if you have `alloca', as a function or macro. */
 #undef HAVE_ALLOCA
 
@@ -33,6 +39,9 @@
 /* Define to 1 if you have the <assert.h> header file. */
 #undef HAVE_ASSERT_H
 
+/* Define to 1 if canonicalize_file_name is available. */
+#undef HAVE_CANONICALIZE_FILE_NAME
+
 /* Define to 1 if you have the <ctype.h> header file. */
 #undef HAVE_CTYPE_H
 
@@ -60,6 +69,9 @@
 /* Define to 1 if you have the `gethostname' function. */
 #undef HAVE_GETHOSTNAME
 
+/* Define to 1 if getline is available. */
+#undef HAVE_GETLINE
+
 /* Define to 1 if you have the `getmntent' function. */
 #undef HAVE_GETMNTENT
 


