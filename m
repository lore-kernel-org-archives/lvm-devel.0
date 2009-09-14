From: agk@sourceware.org <agk@sourceware.org>
Date: 14 Sep 2009 22:57:47 -0000
Subject: LVM2 ./configure ./configure.in daemons/cmirro ...
Message-ID: <20090914225747.32635.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-14 22:57:46

Modified files:
	.              : configure configure.in 
	daemons/cmirrord: Makefile.in clogd.c cluster.c 
	lib/misc       : configure.h.in 

Log message:
	More cmirror makefile fixes from Fabio.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.104&r2=1.105
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.112&r2=1.113
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/Makefile.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/clogd.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/cluster.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/configure	2009/09/02 19:32:37	1.104
+++ LVM2/configure	2009/09/14 22:57:46	1.105
@@ -702,6 +702,8 @@
 LVM2APP_LIB
 GENHTML
 LCOV
+SACKPT_LIBS
+SACKPT_CFLAGS
 DLM_LIBS
 DLM_CFLAGS
 CPG_LIBS
@@ -872,7 +874,9 @@
 CPG_CFLAGS
 CPG_LIBS
 DLM_CFLAGS
-DLM_LIBS'
+DLM_LIBS
+SACKPT_CFLAGS
+SACKPT_LIBS'
 
 
 # Initialize some variables set by options.
@@ -1596,6 +1600,9 @@
   CPG_LIBS    linker flags for CPG, overriding pkg-config
   DLM_CFLAGS  C compiler flags for DLM, overriding pkg-config
   DLM_LIBS    linker flags for DLM, overriding pkg-config
+  SACKPT_CFLAGS
+              C compiler flags for SACKPT, overriding pkg-config
+  SACKPT_LIBS linker flags for SACKPT, overriding pkg-config
 
 Use these variables to override the choices made by `configure' or to help
 it to find libraries and programs with nonstandard names/locations.
@@ -9239,49 +9246,7 @@
 $as_echo "$REALTIME" >&6; }
 
 ################################################################################
-{ $as_echo "$as_me:$LINENO: checking whether to build cluster LVM daemon" >&5
-$as_echo_n "checking whether to build cluster LVM daemon... " >&6; }
-
-# Check whether --with-clvmd was given.
-if test "${with_clvmd+set}" = set; then
-  withval=$with_clvmd;  CLVMD="$withval"
-else
-   CLVMD="none"
-fi
-
-if test x$CLVMD = xyes; then
-	CLVMD=all
-fi
-{ $as_echo "$as_me:$LINENO: result: $CLVMD" >&5
-$as_echo "$CLVMD" >&6; }
-
-if  test x$CLVMD != xnone && test x$CLUSTER = xnone; then
-	CLUSTER=internal
-fi
-
-if [ `expr x"$CLVMD" : '.*gulm.*'` != 0 ]; then
-	BUILDGULM=yes
-fi
-if [ `expr x"$CLVMD" : '.*corosync.*'` != 0 ]; then
-	BUILDCOROSYNC=yes
-fi
-if [ `expr x"$CLVMD" : '.*openais.*'` != 0 ]; then
-	BUILDOPENAIS=yes
-fi
-if [ `expr x"$CLVMD" : '.*cman.*'` != 0 ]; then
-	BUILDCMAN=yes
-fi
-
-if test x$BUILDGULM = xyes; then
-	if test x$BUILDCOROSYNC = xyes || \
-	   test x$BUILDOPENAIS = xyes; then
-		{ { $as_echo "$as_me:$LINENO: error: requested clvmd configuration is not valid" >&5
-$as_echo "$as_me: error: requested clvmd configuration is not valid" >&2;}
-   { (exit 1); exit 1; }; }
-	fi
-fi
-
-if  test x$CLVMD != xnone; then
+pkg_config_init() {
 
 
 if test "x$ac_cv_env_PKG_CONFIG_set" != "xset"; then
@@ -9467,6 +9432,55 @@
 $as_echo "yes" >&6; }
 	:
 fi
+	PKGCONFIG_INIT=1
+}
+
+################################################################################
+{ $as_echo "$as_me:$LINENO: checking whether to build cluster LVM daemon" >&5
+$as_echo_n "checking whether to build cluster LVM daemon... " >&6; }
+
+# Check whether --with-clvmd was given.
+if test "${with_clvmd+set}" = set; then
+  withval=$with_clvmd;  CLVMD="$withval"
+else
+   CLVMD="none"
+fi
+
+if test x$CLVMD = xyes; then
+	CLVMD=all
+fi
+{ $as_echo "$as_me:$LINENO: result: $CLVMD" >&5
+$as_echo "$CLVMD" >&6; }
+
+if  test x$CLVMD != xnone && test x$CLUSTER = xnone; then
+	CLUSTER=internal
+fi
+
+if  test x$CLVMD != xnone && test x$PKGCONFIG_INIT != x1; then
+	pkg_config_init
+fi
+
+
+if [ `expr x"$CLVMD" : '.*gulm.*'` != 0 ]; then
+	BUILDGULM=yes
+fi
+if [ `expr x"$CLVMD" : '.*corosync.*'` != 0 ]; then
+	BUILDCOROSYNC=yes
+fi
+if [ `expr x"$CLVMD" : '.*openais.*'` != 0 ]; then
+	BUILDOPENAIS=yes
+fi
+if [ `expr x"$CLVMD" : '.*cman.*'` != 0 ]; then
+	BUILDCMAN=yes
+fi
+
+if test x$BUILDGULM = xyes; then
+	if test x$BUILDCOROSYNC = xyes || \
+	   test x$BUILDOPENAIS = xyes; then
+		{ { $as_echo "$as_me:$LINENO: error: requested clvmd configuration is not valid" >&5
+$as_echo "$as_me: error: requested clvmd configuration is not valid" >&2;}
+   { (exit 1); exit 1; }; }
+	fi
 fi
 
 soft_bailout() {
@@ -11695,10 +11709,119 @@
 
 ################################################################################
 if [ "x$BUILD_CMIRRORD" = xyes ]; then
-#
-#       FIXME: ALSO NEED TO CHECK FOR CHECKPOINT MODULE
-#       FIXME: Merge this with the new clvmd logic
-#
+		if  test x$PKGCONFIG_INIT != x1; then
+		pkg_config_init
+	fi
+
+pkg_failed=no
+{ $as_echo "$as_me:$LINENO: checking for SACKPT" >&5
+$as_echo_n "checking for SACKPT... " >&6; }
+
+if test -n "$SACKPT_CFLAGS"; then
+    pkg_cv_SACKPT_CFLAGS="$SACKPT_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libSaCkpt\"") >&5
+  ($PKG_CONFIG --exists --print-errors "libSaCkpt") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; then
+  pkg_cv_SACKPT_CFLAGS=`$PKG_CONFIG --cflags "libSaCkpt" 2>/dev/null`
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$SACKPT_LIBS"; then
+    pkg_cv_SACKPT_LIBS="$SACKPT_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libSaCkpt\"") >&5
+  ($PKG_CONFIG --exists --print-errors "libSaCkpt") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; then
+  pkg_cv_SACKPT_LIBS=`$PKG_CONFIG --libs "libSaCkpt" 2>/dev/null`
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
+
+if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
+        _pkg_short_errors_supported=yes
+else
+        _pkg_short_errors_supported=no
+fi
+        if test $_pkg_short_errors_supported = yes; then
+	        SACKPT_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libSaCkpt" 2>&1`
+        else
+	        SACKPT_PKG_ERRORS=`$PKG_CONFIG --print-errors "libSaCkpt" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$SACKPT_PKG_ERRORS" >&5
+
+	{ { $as_echo "$as_me:$LINENO: error: Package requirements (libSaCkpt) were not met:
+
+$SACKPT_PKG_ERRORS
+
+Consider adjusting the PKG_CONFIG_PATH environment variable if you
+installed software in a non-standard prefix.
+
+Alternatively, you may set the environment variables SACKPT_CFLAGS
+and SACKPT_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details.
+" >&5
+$as_echo "$as_me: error: Package requirements (libSaCkpt) were not met:
+
+$SACKPT_PKG_ERRORS
+
+Consider adjusting the PKG_CONFIG_PATH environment variable if you
+installed software in a non-standard prefix.
+
+Alternatively, you may set the environment variables SACKPT_CFLAGS
+and SACKPT_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details.
+" >&2;}
+   { (exit 1); exit 1; }; }
+elif test $pkg_failed = untried; then
+	{ { $as_echo "$as_me:$LINENO: error: in \`$ac_pwd':" >&5
+$as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
+{ { $as_echo "$as_me:$LINENO: error: The pkg-config script could not be found or is too old.  Make sure it
+is in your PATH or set the PKG_CONFIG environment variable to the full
+path to pkg-config.
+
+Alternatively, you may set the environment variables SACKPT_CFLAGS
+and SACKPT_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details.
+
+To get pkg-config, see <http://pkg-config.freedesktop.org/>.
+See \`config.log' for more details." >&5
+$as_echo "$as_me: error: The pkg-config script could not be found or is too old.  Make sure it
+is in your PATH or set the PKG_CONFIG environment variable to the full
+path to pkg-config.
+
+Alternatively, you may set the environment variables SACKPT_CFLAGS
+and SACKPT_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details.
+
+To get pkg-config, see <http://pkg-config.freedesktop.org/>.
+See \`config.log' for more details." >&2;}
+   { (exit 1); exit 1; }; }; }
+else
+	SACKPT_CFLAGS=$pkg_cv_SACKPT_CFLAGS
+	SACKPT_LIBS=$pkg_cv_SACKPT_LIBS
+        { $as_echo "$as_me:$LINENO: result: yes" >&5
+$as_echo "yes" >&6; }
+	:
+fi
+	if test x$HAVE_CPG != xyes; then
 
 pkg_failed=no
 { $as_echo "$as_me:$LINENO: checking for CPG" >&5
@@ -11754,15 +11877,53 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$CPG_PKG_ERRORS" >&5
 
-	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
-                { $as_echo "$as_me:$LINENO: result: no pkg for libcpg library, using -lcpg" >&5
-$as_echo "no pkg for libcpg library, using -lcpg" >&6; };
-		CPG_LIBS="-lcpg"
+	{ { $as_echo "$as_me:$LINENO: error: Package requirements (libcpg) were not met:
+
+$CPG_PKG_ERRORS
+
+Consider adjusting the PKG_CONFIG_PATH environment variable if you
+installed software in a non-standard prefix.
+
+Alternatively, you may set the environment variables CPG_CFLAGS
+and CPG_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details.
+" >&5
+$as_echo "$as_me: error: Package requirements (libcpg) were not met:
+
+$CPG_PKG_ERRORS
+
+Consider adjusting the PKG_CONFIG_PATH environment variable if you
+installed software in a non-standard prefix.
+
+Alternatively, you may set the environment variables CPG_CFLAGS
+and CPG_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details.
+" >&2;}
+   { (exit 1); exit 1; }; }
 elif test $pkg_failed = untried; then
-	{ $as_echo "$as_me:$LINENO: result: no pkg for libcpg library, using -lcpg" >&5
-$as_echo "no pkg for libcpg library, using -lcpg" >&6; };
-		CPG_LIBS="-lcpg"
+	{ { $as_echo "$as_me:$LINENO: error: in \`$ac_pwd':" >&5
+$as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
+{ { $as_echo "$as_me:$LINENO: error: The pkg-config script could not be found or is too old.  Make sure it
+is in your PATH or set the PKG_CONFIG environment variable to the full
+path to pkg-config.
+
+Alternatively, you may set the environment variables CPG_CFLAGS
+and CPG_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details.
+
+To get pkg-config, see <http://pkg-config.freedesktop.org/>.
+See \`config.log' for more details." >&5
+$as_echo "$as_me: error: The pkg-config script could not be found or is too old.  Make sure it
+is in your PATH or set the PKG_CONFIG environment variable to the full
+path to pkg-config.
+
+Alternatively, you may set the environment variables CPG_CFLAGS
+and CPG_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details.
+
+To get pkg-config, see <http://pkg-config.freedesktop.org/>.
+See \`config.log' for more details." >&2;}
+   { (exit 1); exit 1; }; }; }
 else
 	CPG_CFLAGS=$pkg_cv_CPG_CFLAGS
 	CPG_LIBS=$pkg_cv_CPG_LIBS
@@ -11770,6 +11931,7 @@
 $as_echo "yes" >&6; }
 	:
 fi
+	fi
 fi
 
 ################################################################################
@@ -11960,6 +12122,91 @@
 $as_echo "$UDEV_RULES" >&6; }
 
 ################################################################################
+
+if test x$UDEV_SYNC = xyes; then
+	{ $as_echo "$as_me:$LINENO: checking for udev_queue_get_udev_is_active in -ludev" >&5
+$as_echo_n "checking for udev_queue_get_udev_is_active in -ludev... " >&6; }
+if test "${ac_cv_lib_udev_udev_queue_get_udev_is_active+set}" = set; then
+  $as_echo_n "(cached) " >&6
+else
+  ac_check_lib_save_LIBS=$LIBS
+LIBS="-ludev  $LIBS"
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
+char udev_queue_get_udev_is_active ();
+int
+main ()
+{
+return udev_queue_get_udev_is_active ();
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
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_link") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       } && test -s conftest$ac_exeext && {
+	 test "$cross_compiling" = yes ||
+	 $as_test_x conftest$ac_exeext
+       }; then
+  ac_cv_lib_udev_udev_queue_get_udev_is_active=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	ac_cv_lib_udev_udev_queue_get_udev_is_active=no
+fi
+
+rm -rf conftest.dSYM
+rm -f core conftest.err conftest.$ac_objext conftest_ipa8_conftest.oo \
+      conftest$ac_exeext conftest.$ac_ext
+LIBS=$ac_check_lib_save_LIBS
+fi
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_lib_udev_udev_queue_get_udev_is_active" >&5
+$as_echo "$ac_cv_lib_udev_udev_queue_get_udev_is_active" >&6; }
+if test "x$ac_cv_lib_udev_udev_queue_get_udev_is_active" = x""yes; then
+  HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE=yes
+else
+  HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE=no
+fi
+
+
+		if test x$HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE = xyes; then
+
+cat >>confdefs.h <<\_ACEOF
+#define HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE 1
+_ACEOF
+
+			LIBS="-ludev $LIBS"
+		fi
+fi
+
+################################################################################
 # Check whether --enable-compat was given.
 if test "${enable_compat+set}" = set; then
   enableval=$enable_compat; DM_COMPAT=$enableval
@@ -15154,6 +15401,8 @@
 
 
 
+
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
 
--- LVM2/configure.in	2009/09/11 15:55:07	1.112
+++ LVM2/configure.in	2009/09/14 22:57:46	1.113
@@ -322,6 +322,17 @@
 AC_MSG_RESULT($REALTIME)
 
 ################################################################################
+dnl -- Init pkg-config with dummy invokation:
+dnl -- this is required because PKG_CHECK_MODULES macro is expanded
+dnl -- to initialize the pkg-config environment only at the first invokation,
+dnl -- that would be conditional in this configure.in.
+pkg_config_init() {
+	PKG_CHECK_MODULES(PKGCONFIGINIT, pkgconfiginit, [],
+		[AC_MSG_RESULT([pkg-config initialized])])
+	PKGCONFIG_INIT=1
+}
+
+################################################################################
 dnl -- Build cluster LVM daemon
 AC_MSG_CHECKING(whether to build cluster LVM daemon)
 AC_ARG_WITH(clvmd,
@@ -345,6 +356,12 @@
 	CLUSTER=internal
 fi
 
+dnl -- init pkgconfig if required
+if  test x$CLVMD != xnone && test x$PKGCONFIG_INIT != x1; then
+	pkg_config_init
+fi
+
+
 dnl -- define build types
 if [[ `expr x"$CLVMD" : '.*gulm.*'` != 0 ]]; then
 	BUILDGULM=yes
@@ -367,15 +384,6 @@
 	fi
 fi
 
-dnl -- Init pkg-config with dummy invokation:
-dnl -- this is required because PKG_CHECK_MODULES macro is expanded
-dnl -- to initialize the pkg-config environment only@the first invokation,
-dnl -- that would be conditional in this configure.in.
-if  test x$CLVMD != xnone; then
-	PKG_CHECK_MODULES(PKGCONFIGINIT, pkgconfiginit, [],
-		[AC_MSG_RESULT([pkg-config initialized])])
-fi
-
 dnl -- define a soft bailout if we are autodetecting
 soft_bailout() {
 	NOTFOUND=1
@@ -574,13 +582,14 @@
 ################################################################################
 dnl -- Look for corosync libraries if required.
 if [[ "x$BUILD_CMIRRORD" = xyes ]]; then
-#
-#       FIXME: ALSO NEED TO CHECK FOR CHECKPOINT MODULE
-#       FIXME: Merge this with the new clvmd logic
-#
-	PKG_CHECK_MODULES(CPG, libcpg, [],
-		[AC_MSG_RESULT([no pkg for libcpg library, using -lcpg]);
-		CPG_LIBS="-lcpg"])
+	dnl -- init pkgconfig if required
+	if  test x$PKGCONFIG_INIT != x1; then
+		pkg_config_init
+	fi
+	PKG_CHECK_MODULES(SACKPT, libSaCkpt)
+	if test x$HAVE_CPG != xyes; then
+		PKG_CHECK_MODULES(CPG, libcpg)
+	fi
 fi
 
 ################################################################################
@@ -1101,6 +1110,8 @@
 AC_SUBST(POOL)
 AC_SUBST(QUORUM_CFLAGS)
 AC_SUBST(QUORUM_LIBS)
+AC_SUBST(SACKPT_CFLAGS)
+AC_SUBST(SACKPT_LIBS)
 AC_SUBST(SALCK_CFLAGS)
 AC_SUBST(SALCK_LIBS)
 AC_SUBST(SNAPSHOTS)
--- LVM2/daemons/cmirrord/Makefile.in	2009/08/28 20:51:41	1.2
+++ LVM2/daemons/cmirrord/Makefile.in	2009/09/14 22:57:46	1.3
@@ -15,17 +15,23 @@
 top_srcdir = @top_srcdir@
 VPATH = @srcdir@
 
+CPG_LIBS = @CPG_LIBS@
+CPG_CFLAGS = @CPG_CFLAGS@
+SACKPT_LIBS = @SACKPT_LIBS@
+SACKPT_CFLAGS = @SACKPT_CFLAGS@
+
 SOURCES = clogd.c cluster.c functions.c link_mon.c local.c logging.c
 
 TARGETS = cmirrord
 
 include $(top_srcdir)/make.tmpl
 
-LDFLAGS += -L$(usrlibdir)/openais
-LIBS += -lcpg -lSaCkpt -ldevmapper
+LIBS += -ldevmapper
+LMLIBS += $(CPG_LIBS) $(SACKPT_LIBS)
+CFLAGS += $(CPG_CFLAGS) $(SACKPT_CFLAGS)
 
 cmirrord: $(OBJECTS) $(top_srcdir)/lib/liblvm-internal.a
-	$(CC) -o cmirrord $(OBJECTS) $(CFLAGS) $(LDFLAGS) \
+	$(CC) -o cmirrord $(OBJECTS) $(LDFLAGS) \
 		$(LVMLIBS) $(LMLIBS) $(LIBS)
 
 install: $(TARGETS)
--- LVM2/daemons/cmirrord/clogd.c	2009/08/28 20:51:41	1.5
+++ LVM2/daemons/cmirrord/clogd.c	2009/09/14 22:57:46	1.6
@@ -9,6 +9,9 @@
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
+
+#include "configure.h"
+
 #include <stdio.h>
 #include <stdlib.h>
 #include <stdint.h>
--- LVM2/daemons/cmirrord/cluster.c	2009/08/13 16:34:07	1.8
+++ LVM2/daemons/cmirrord/cluster.c	2009/09/14 22:57:46	1.9
@@ -21,8 +21,9 @@
 #include <sys/un.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>
+#include <corosync/corotypes.h>
+#include <corosync/cpg.h>
 #include <openais/saAis.h>
-#include <openais/cpg.h>
 #include <openais/saCkpt.h>
 
 #include "dm-log-userspace.h"
@@ -932,9 +933,9 @@
 	return 0;
 }
 
-static void cpg_message_callback(cpg_handle_t handle, struct cpg_name *gname,
+static void cpg_message_callback(cpg_handle_t handle, const struct cpg_name *gname,
 				 uint32_t nodeid, uint32_t pid,
-				 void *msg, int msg_len)
+				 void *msg, size_t msg_len)
 {
 	int i;
 	int r = 0;
@@ -1154,9 +1155,9 @@
 }
 
 static void cpg_join_callback(struct clog_cpg *match,
-			      struct cpg_address *joined,
-			      struct cpg_address *member_list,
-			      int member_list_entries)
+			      const struct cpg_address *joined,
+			      const struct cpg_address *member_list,
+			      size_t member_list_entries)
 {
 	int i;
 	int my_pid = getpid();
@@ -1233,9 +1234,9 @@
 }
 
 static void cpg_leave_callback(struct clog_cpg *match,
-			       struct cpg_address *left,
-			       struct cpg_address *member_list,
-			       int member_list_entries)
+			       const struct cpg_address *left,
+			       const struct cpg_address *member_list,
+			       size_t member_list_entries)
 {
 	int i, j, fd;
 	uint32_t lowest = match->lowest_id;
@@ -1366,13 +1367,13 @@
 	}
 }
 
-static void cpg_config_callback(cpg_handle_t handle, struct cpg_name *gname,
-				struct cpg_address *member_list,
-				int member_list_entries,
-				struct cpg_address *left_list,
-				int left_list_entries,
-				struct cpg_address *joined_list,
-				int joined_list_entries)
+static void cpg_config_callback(cpg_handle_t handle, const struct cpg_name *gname,
+				const struct cpg_address *member_list,
+				size_t member_list_entries,
+				const struct cpg_address *left_list,
+				size_t left_list_entries,
+				const struct cpg_address *joined_list,
+				size_t joined_list_entries)
 {
 	struct clog_cpg *match;
 	int found = 0;
--- LVM2/lib/misc/configure.h.in	2009/08/28 20:51:41	1.12
+++ LVM2/lib/misc/configure.h.in	2009/09/14 22:57:46	1.13
@@ -344,6 +344,10 @@
 /* Define to 1 if you have the <time.h> header file. */
 #undef HAVE_TIME_H
 
+/* Define to 1 if libudev's udev_queue_get_udev_is_active function is
+   available. */
+#undef HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE
+
 /* Define to 1 if you have the `uname' function. */
 #undef HAVE_UNAME
 


