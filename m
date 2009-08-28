From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Aug 2009 19:22:06 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in da ...
Message-ID: <20090828192206.14439.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-08-28 19:22:05

Modified files:
	.              : WHATS_NEW configure configure.in 
	daemons/clvmd  : Makefile.in clvmd-comms.h clvmd-corosync.c 
	                 clvmd-openais.c 
	lib/misc       : configure.h.in 

Log message:
	Rewrite clvmd configuration code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1244&r2=1.1245
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.100&r2=1.101
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.107&r2=1.108
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/Makefile.in.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-comms.h.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-corosync.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-openais.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/WHATS_NEW	2009/08/24 11:37:20	1.1244
+++ LVM2/WHATS_NEW	2009/08/28 19:22:05	1.1245
@@ -1,5 +1,6 @@
 Version 2.02.52 -
 =================================
+  Rewrite clvmd configuration code to cope with all combinations of libs.
   Fix global locking in PV reporting commands (2.02.49).
   Fix pvcreate string termination in duplicate uuid warning message.
   Fix pvcreate on a partition (2.02.51).
--- LVM2/configure	2009/07/31 13:31:53	1.100
+++ LVM2/configure	2009/08/28 19:22:05	1.101
@@ -688,6 +688,7 @@
 COPTIMISE_FLAG
 CONFDIR
 CMDLIB
+CLOGD
 CLVMD
 CLUSTER
 CLDWHOLEARCHIVE
@@ -701,12 +702,26 @@
 LVM2APP_LIB
 GENHTML
 LCOV
+DLM_LIBS
+DLM_CFLAGS
 CPG_LIBS
 CPG_CFLAGS
 CONFDB_LIBS
 CONFDB_CFLAGS
+SALCK_LIBS
+SALCK_CFLAGS
 QUORUM_LIBS
 QUORUM_CFLAGS
+COROSYNC_LIBS
+COROSYNC_CFLAGS
+CMAN_LIBS
+CMAN_CFLAGS
+GULM_LIBS
+GULM_CFLAGS
+CCS_LIBS
+CCS_CFLAGS
+PKGCONFIGINIT_LIBS
+PKGCONFIGINIT_CFLAGS
 PKG_CONFIG
 POW_LIB
 LIBOBJS
@@ -799,6 +814,7 @@
 enable_readline
 enable_realtime
 with_clvmd
+enable_clogd
 enable_debug
 with_optimisation
 enable_profiling
@@ -836,12 +852,26 @@
 CPPFLAGS
 CPP
 PKG_CONFIG
+PKGCONFIGINIT_CFLAGS
+PKGCONFIGINIT_LIBS
+CCS_CFLAGS
+CCS_LIBS
+GULM_CFLAGS
+GULM_LIBS
+CMAN_CFLAGS
+CMAN_LIBS
+COROSYNC_CFLAGS
+COROSYNC_LIBS
 QUORUM_CFLAGS
 QUORUM_LIBS
+SALCK_CFLAGS
+SALCK_LIBS
 CONFDB_CFLAGS
 CONFDB_LIBS
 CPG_CFLAGS
-CPG_LIBS'
+CPG_LIBS
+DLM_CFLAGS
+DLM_LIBS'
 
 
 # Initialize some variables set by options.
@@ -1472,6 +1502,7 @@
                           device-mapper is missing from the kernel
   --disable-readline      Disable readline support
   --disable-realtime      Disable realtime clock support
+  --enable-clogd          Enable the cluster log daemon
   --enable-debug          Enable debugging
   --enable-profiling      Gather gcov profiling data
   --disable-devmapper     Disable LVM2 device-mapper interaction
@@ -1506,7 +1537,13 @@
                           TYPE=internal
   --with-mirrors=TYPE     Mirror support: internal/shared/none
                           TYPE=internal
-  --with-clvmd=TYPE       Build cluster LVM Daemon: cman/gulm/corosync/none/all
+  --with-clvmd=TYPE       Build cluster LVM Daemon.
+                          The following locking combinations are valid:
+                           * cman,gulm             (RHEL4 or equivalent)
+                           * cman                  (RHEL5 or equivalent)
+                           * cman,corosync,openais (or selection of them)
+                           * all                   (autodetect)
+                           * none                  (disable build)
                           TYPE=none
   --with-optimisation=OPT C optimisation flag [OPT=-O2]
   --with-localedir=DIR    Translation files in DIR [PREFIX/share/locale]
@@ -1530,14 +1567,33 @@
               you have headers in a nonstandard directory <include dir>
   CPP         C preprocessor
   PKG_CONFIG  path to pkg-config utility
+  PKGCONFIGINIT_CFLAGS
+              C compiler flags for PKGCONFIGINIT, overriding pkg-config
+  PKGCONFIGINIT_LIBS
+              linker flags for PKGCONFIGINIT, overriding pkg-config
+  CCS_CFLAGS  C compiler flags for CCS, overriding pkg-config
+  CCS_LIBS    linker flags for CCS, overriding pkg-config
+  GULM_CFLAGS C compiler flags for GULM, overriding pkg-config
+  GULM_LIBS   linker flags for GULM, overriding pkg-config
+  CMAN_CFLAGS C compiler flags for CMAN, overriding pkg-config
+  CMAN_LIBS   linker flags for CMAN, overriding pkg-config
+  COROSYNC_CFLAGS
+              C compiler flags for COROSYNC, overriding pkg-config
+  COROSYNC_LIBS
+              linker flags for COROSYNC, overriding pkg-config
   QUORUM_CFLAGS
               C compiler flags for QUORUM, overriding pkg-config
   QUORUM_LIBS linker flags for QUORUM, overriding pkg-config
+  SALCK_CFLAGS
+              C compiler flags for SALCK, overriding pkg-config
+  SALCK_LIBS  linker flags for SALCK, overriding pkg-config
   CONFDB_CFLAGS
               C compiler flags for CONFDB, overriding pkg-config
   CONFDB_LIBS linker flags for CONFDB, overriding pkg-config
   CPG_CFLAGS  C compiler flags for CPG, overriding pkg-config
   CPG_LIBS    linker flags for CPG, overriding pkg-config
+  DLM_CFLAGS  C compiler flags for DLM, overriding pkg-config
+  DLM_LIBS    linker flags for DLM, overriding pkg-config
 
 Use these variables to override the choices made by `configure' or to help
 it to find libraries and programs with nonstandard names/locations.
@@ -9201,7 +9257,29 @@
 	CLUSTER=internal
 fi
 
-if [ "x$CLVMD" = xall -o `expr x"$CLVMD" : '.*corosync.*'` != 0 ]; then
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
+fi
+
+if  test x$CLVMD != xnone; then
 
 
 if test "x$ac_cv_env_PKG_CONFIG_set" != "xset"; then
@@ -9320,35 +9398,35 @@
 fi
 
 pkg_failed=no
-{ $as_echo "$as_me:$LINENO: checking for QUORUM" >&5
-$as_echo_n "checking for QUORUM... " >&6; }
+{ $as_echo "$as_me:$LINENO: checking for PKGCONFIGINIT" >&5
+$as_echo_n "checking for PKGCONFIGINIT... " >&6; }
 
-if test -n "$QUORUM_CFLAGS"; then
-    pkg_cv_QUORUM_CFLAGS="$QUORUM_CFLAGS"
+if test -n "$PKGCONFIGINIT_CFLAGS"; then
+    pkg_cv_PKGCONFIGINIT_CFLAGS="$PKGCONFIGINIT_CFLAGS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libquorum\"") >&5
-  ($PKG_CONFIG --exists --print-errors "libquorum") 2>&5
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"pkgconfiginit\"") >&5
+  ($PKG_CONFIG --exists --print-errors "pkgconfiginit") 2>&5
   ac_status=$?
   $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
   (exit $ac_status); }; then
-  pkg_cv_QUORUM_CFLAGS=`$PKG_CONFIG --cflags "libquorum" 2>/dev/null`
+  pkg_cv_PKGCONFIGINIT_CFLAGS=`$PKG_CONFIG --cflags "pkgconfiginit" 2>/dev/null`
 else
   pkg_failed=yes
 fi
  else
     pkg_failed=untried
 fi
-if test -n "$QUORUM_LIBS"; then
-    pkg_cv_QUORUM_LIBS="$QUORUM_LIBS"
+if test -n "$PKGCONFIGINIT_LIBS"; then
+    pkg_cv_PKGCONFIGINIT_LIBS="$PKGCONFIGINIT_LIBS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libquorum\"") >&5
-  ($PKG_CONFIG --exists --print-errors "libquorum") 2>&5
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"pkgconfiginit\"") >&5
+  ($PKG_CONFIG --exists --print-errors "pkgconfiginit") 2>&5
   ac_status=$?
   $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
   (exit $ac_status); }; then
-  pkg_cv_QUORUM_LIBS=`$PKG_CONFIG --libs "libquorum" 2>/dev/null`
+  pkg_cv_PKGCONFIGINIT_LIBS=`$PKG_CONFIG --libs "pkgconfiginit" 2>/dev/null`
 else
   pkg_failed=yes
 fi
@@ -9366,131 +9444,172 @@
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        QUORUM_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libquorum" 2>&1`
+	        PKGCONFIGINIT_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "pkgconfiginit" 2>&1`
         else
-	        QUORUM_PKG_ERRORS=`$PKG_CONFIG --print-errors "libquorum" 2>&1`
+	        PKGCONFIGINIT_PKG_ERRORS=`$PKG_CONFIG --print-errors "pkgconfiginit" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
-	echo "$QUORUM_PKG_ERRORS" >&5
+	echo "$PKGCONFIGINIT_PKG_ERRORS" >&5
 
 	{ $as_echo "$as_me:$LINENO: result: no" >&5
 $as_echo "no" >&6; }
-                { $as_echo "$as_me:$LINENO: result: no pkg for quorum library, using -lquorum" >&5
-$as_echo "no pkg for quorum library, using -lquorum" >&6; };
-		QUORUM_LIBS="-lquorum"
+                { $as_echo "$as_me:$LINENO: result: pkg-config initialized" >&5
+$as_echo "pkg-config initialized" >&6; }
 elif test $pkg_failed = untried; then
-	{ $as_echo "$as_me:$LINENO: result: no pkg for quorum library, using -lquorum" >&5
-$as_echo "no pkg for quorum library, using -lquorum" >&6; };
-		QUORUM_LIBS="-lquorum"
+	{ $as_echo "$as_me:$LINENO: result: pkg-config initialized" >&5
+$as_echo "pkg-config initialized" >&6; }
 else
-	QUORUM_CFLAGS=$pkg_cv_QUORUM_CFLAGS
-	QUORUM_LIBS=$pkg_cv_QUORUM_LIBS
+	PKGCONFIGINIT_CFLAGS=$pkg_cv_PKGCONFIGINIT_CFLAGS
+	PKGCONFIGINIT_LIBS=$pkg_cv_PKGCONFIGINIT_LIBS
         { $as_echo "$as_me:$LINENO: result: yes" >&5
 $as_echo "yes" >&6; }
 	:
 fi
+fi
 
-pkg_failed=no
-{ $as_echo "$as_me:$LINENO: checking for CONFDB" >&5
-$as_echo_n "checking for CONFDB... " >&6; }
+soft_bailout() {
+	NOTFOUND=1
+}
 
-if test -n "$CONFDB_CFLAGS"; then
-    pkg_cv_CONFDB_CFLAGS="$CONFDB_CFLAGS"
- elif test -n "$PKG_CONFIG"; then
-    if test -n "$PKG_CONFIG" && \
-    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libconfdb\"") >&5
-  ($PKG_CONFIG --exists --print-errors "libconfdb") 2>&5
-  ac_status=$?
-  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
-  (exit $ac_status); }; then
-  pkg_cv_CONFDB_CFLAGS=`$PKG_CONFIG --cflags "libconfdb" 2>/dev/null`
+hard_bailout() {
+	{ { $as_echo "$as_me:$LINENO: error: bailing out" >&5
+$as_echo "$as_me: error: bailing out" >&2;}
+   { (exit 1); exit 1; }; }
+}
+
+if test x$CLVMD = xall; then
+	bailout=soft_bailout
+	BUILDGULM=yes
+	BUILDCMAN=yes
+	BUILDCOROSYNC=yes
+	BUILDOPENAIS=yes
+else
+	bailout=hard_bailout
+fi
+
+check_lib_no_libs() {
+	lib_no_libs_arg1=$1
+	shift
+	lib_no_libs_arg2=$1
+	shift
+	lib_no_libs_args=$@
+
+as_ac_Lib=`$as_echo "ac_cv_lib_$lib_no_libs_arg1''_$lib_no_libs_arg2" | $as_tr_sh`
+{ $as_echo "$as_me:$LINENO: checking for $lib_no_libs_arg2 in -l$lib_no_libs_arg1" >&5
+$as_echo_n "checking for $lib_no_libs_arg2 in -l$lib_no_libs_arg1... " >&6; }
+if { as_var=$as_ac_Lib; eval "test \"\${$as_var+set}\" = set"; }; then
+  $as_echo_n "(cached) " >&6
 else
-  pkg_failed=yes
-fi
- else
-    pkg_failed=untried
-fi
-if test -n "$CONFDB_LIBS"; then
-    pkg_cv_CONFDB_LIBS="$CONFDB_LIBS"
- elif test -n "$PKG_CONFIG"; then
-    if test -n "$PKG_CONFIG" && \
-    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libconfdb\"") >&5
-  ($PKG_CONFIG --exists --print-errors "libconfdb") 2>&5
+  ac_check_lib_save_LIBS=$LIBS
+LIBS="-l$lib_no_libs_arg1 $lib_no_libs_args $LIBS"
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
+char $lib_no_libs_arg2 ();
+int
+main ()
+{
+return $lib_no_libs_arg2 ();
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
   ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
   $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
-  (exit $ac_status); }; then
-  pkg_cv_CONFDB_LIBS=`$PKG_CONFIG --libs "libconfdb" 2>/dev/null`
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       } && test -s conftest$ac_exeext && {
+	 test "$cross_compiling" = yes ||
+	 $as_test_x conftest$ac_exeext
+       }; then
+  eval "$as_ac_Lib=yes"
 else
-  pkg_failed=yes
-fi
- else
-    pkg_failed=untried
-fi
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
 
+	eval "$as_ac_Lib=no"
+fi
 
+rm -rf conftest.dSYM
+rm -f core conftest.err conftest.$ac_objext conftest_ipa8_conftest.oo \
+      conftest$ac_exeext conftest.$ac_ext
+LIBS=$ac_check_lib_save_LIBS
+fi
+ac_res=`eval 'as_val=${'$as_ac_Lib'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+as_val=`eval 'as_val=${'$as_ac_Lib'}
+		 $as_echo "$as_val"'`
+   if test "x$as_val" = x""yes; then
+  cat >>confdefs.h <<_ACEOF
+#define `$as_echo "HAVE_LIB$lib_no_libs_arg1" | $as_tr_cpp` 1
+_ACEOF
 
-if test $pkg_failed = yes; then
+  LIBS="-l$lib_no_libs_arg1 $LIBS"
 
-if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
-        _pkg_short_errors_supported=yes
 else
-        _pkg_short_errors_supported=no
+  $bailout
 fi
-        if test $_pkg_short_errors_supported = yes; then
-	        CONFDB_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libconfdb" 2>&1`
-        else
-	        CONFDB_PKG_ERRORS=`$PKG_CONFIG --print-errors "libconfdb" 2>&1`
-        fi
-	# Put the nasty error message in config.log where it belongs
-	echo "$CONFDB_PKG_ERRORS" >&5
 
-	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
-                { $as_echo "$as_me:$LINENO: result: no pkg for confdb library, using -lconfdb" >&5
-$as_echo "no pkg for confdb library, using -lconfdb" >&6; };
-		CONFDB_LIBS="-lconfdb"
-elif test $pkg_failed = untried; then
-	{ $as_echo "$as_me:$LINENO: result: no pkg for confdb library, using -lconfdb" >&5
-$as_echo "no pkg for confdb library, using -lconfdb" >&6; };
-		CONFDB_LIBS="-lconfdb"
-else
-	CONFDB_CFLAGS=$pkg_cv_CONFDB_CFLAGS
-	CONFDB_LIBS=$pkg_cv_CONFDB_LIBS
-        { $as_echo "$as_me:$LINENO: result: yes" >&5
-$as_echo "yes" >&6; }
-	:
-fi
+	LIBS=$ac_check_lib_save_LIBS
+}
+
+if test x$BUILDGULM = xyes; then
 
 pkg_failed=no
-{ $as_echo "$as_me:$LINENO: checking for CPG" >&5
-$as_echo_n "checking for CPG... " >&6; }
+{ $as_echo "$as_me:$LINENO: checking for CCS" >&5
+$as_echo_n "checking for CCS... " >&6; }
 
-if test -n "$CPG_CFLAGS"; then
-    pkg_cv_CPG_CFLAGS="$CPG_CFLAGS"
+if test -n "$CCS_CFLAGS"; then
+    pkg_cv_CCS_CFLAGS="$CCS_CFLAGS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libcpg\"") >&5
-  ($PKG_CONFIG --exists --print-errors "libcpg") 2>&5
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libccs\"") >&5
+  ($PKG_CONFIG --exists --print-errors "libccs") 2>&5
   ac_status=$?
   $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
   (exit $ac_status); }; then
-  pkg_cv_CPG_CFLAGS=`$PKG_CONFIG --cflags "libcpg" 2>/dev/null`
+  pkg_cv_CCS_CFLAGS=`$PKG_CONFIG --cflags "libccs" 2>/dev/null`
 else
   pkg_failed=yes
 fi
  else
     pkg_failed=untried
 fi
-if test -n "$CPG_LIBS"; then
-    pkg_cv_CPG_LIBS="$CPG_LIBS"
+if test -n "$CCS_LIBS"; then
+    pkg_cv_CCS_LIBS="$CCS_LIBS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libcpg\"") >&5
-  ($PKG_CONFIG --exists --print-errors "libcpg") 2>&5
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libccs\"") >&5
+  ($PKG_CONFIG --exists --print-errors "libccs") 2>&5
   ac_status=$?
   $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
   (exit $ac_status); }; then
-  pkg_cv_CPG_LIBS=`$PKG_CONFIG --libs "libcpg" 2>/dev/null`
+  pkg_cv_CCS_LIBS=`$PKG_CONFIG --libs "libccs" 2>/dev/null`
 else
   pkg_failed=yes
 fi
@@ -9508,69 +9627,2157 @@
         _pkg_short_errors_supported=no
 fi
         if test $_pkg_short_errors_supported = yes; then
-	        CPG_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libcpg" 2>&1`
+	        CCS_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libccs" 2>&1`
         else
-	        CPG_PKG_ERRORS=`$PKG_CONFIG --print-errors "libcpg" 2>&1`
+	        CCS_PKG_ERRORS=`$PKG_CONFIG --print-errors "libccs" 2>&1`
         fi
 	# Put the nasty error message in config.log where it belongs
-	echo "$CPG_PKG_ERRORS" >&5
+	echo "$CCS_PKG_ERRORS" >&5
 
 	{ $as_echo "$as_me:$LINENO: result: no" >&5
 $as_echo "no" >&6; }
-                { $as_echo "$as_me:$LINENO: result: no pkg for libcpg library, using -lcpg" >&5
-$as_echo "no pkg for libcpg library, using -lcpg" >&6; };
-		CPG_LIBS="-lcpg"
-elif test $pkg_failed = untried; then
-	{ $as_echo "$as_me:$LINENO: result: no pkg for libcpg library, using -lcpg" >&5
-$as_echo "no pkg for libcpg library, using -lcpg" >&6; };
-		CPG_LIBS="-lcpg"
-else
-	CPG_CFLAGS=$pkg_cv_CPG_CFLAGS
-	CPG_LIBS=$pkg_cv_CPG_LIBS
-        { $as_echo "$as_me:$LINENO: result: yes" >&5
-$as_echo "yes" >&6; }
-	:
-fi
-fi
+                NOTFOUND=0
 
-################################################################################
-{ $as_echo "$as_me:$LINENO: checking whether to enable debugging" >&5
-$as_echo_n "checking whether to enable debugging... " >&6; }
-# Check whether --enable-debug was given.
-if test "${enable_debug+set}" = set; then
-  enableval=$enable_debug; DEBUG=$enableval
-else
-  DEBUG=no
+for ac_header in ccs.h
+do
+as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  { $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
+$as_echo_n "checking for $ac_header... " >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  $as_echo_n "(cached) " >&6
 fi
-
-{ $as_echo "$as_me:$LINENO: result: $DEBUG" >&5
-$as_echo "$DEBUG" >&6; }
-
-if test x$DEBUG = xyes; then
-	COPTIMISE_FLAG=
+ac_res=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
 else
-	CSCOPE_CMD=
-fi
-
-################################################################################
-{ $as_echo "$as_me:$LINENO: checking for C optimisation flag" >&5
-$as_echo_n "checking for C optimisation flag... " >&6; }
+  # Is the header compilable?
+{ $as_echo "$as_me:$LINENO: checking $ac_header usability" >&5
+$as_echo_n "checking $ac_header usability... " >&6; }
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+$ac_includes_default
+#include <$ac_header>
+_ACEOF
+rm -f conftest.$ac_objext
+if { (ac_try="$ac_compile"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_compile") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       } && test -s conftest.$ac_objext; then
+  ac_header_compiler=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
 
-# Check whether --with-optimisation was given.
-if test "${with_optimisation+set}" = set; then
-  withval=$with_optimisation;  COPTIMISE_FLAG="$withval"
+	ac_header_compiler=no
 fi
 
-{ $as_echo "$as_me:$LINENO: result: $COPTIMISE_FLAG" >&5
-$as_echo "$COPTIMISE_FLAG" >&6; }
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+{ $as_echo "$as_me:$LINENO: result: $ac_header_compiler" >&5
+$as_echo "$ac_header_compiler" >&6; }
 
-################################################################################
-{ $as_echo "$as_me:$LINENO: checking whether to gather gcov profiling data" >&5
-$as_echo_n "checking whether to gather gcov profiling data... " >&6; }
-# Check whether --enable-profiling was given.
-if test "${enable_profiling+set}" = set; then
-  enableval=$enable_profiling; PROFILING=$enableval
-else
+# Is the header present?
+{ $as_echo "$as_me:$LINENO: checking $ac_header presence" >&5
+$as_echo_n "checking $ac_header presence... " >&6; }
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+#include <$ac_header>
+_ACEOF
+if { (ac_try="$ac_cpp conftest.$ac_ext"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_cpp conftest.$ac_ext") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } >/dev/null && {
+	 test -z "$ac_c_preproc_warn_flag$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       }; then
+  ac_header_preproc=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+  ac_header_preproc=no
+fi
+
+rm -f conftest.err conftest.$ac_ext
+{ $as_echo "$as_me:$LINENO: result: $ac_header_preproc" >&5
+$as_echo "$ac_header_preproc" >&6; }
+
+# So?  What about this header?
+case $ac_header_compiler:$ac_header_preproc:$ac_c_preproc_warn_flag in
+  yes:no: )
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&5
+$as_echo "$as_me: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the compiler's result" >&5
+$as_echo "$as_me: WARNING: $ac_header: proceeding with the compiler's result" >&2;}
+    ac_header_preproc=yes
+    ;;
+  no:yes:* )
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: present but cannot be compiled" >&5
+$as_echo "$as_me: WARNING: $ac_header: present but cannot be compiled" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header:     check for missing prerequisite headers?" >&5
+$as_echo "$as_me: WARNING: $ac_header:     check for missing prerequisite headers?" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: see the Autoconf documentation" >&5
+$as_echo "$as_me: WARNING: $ac_header: see the Autoconf documentation" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&5
+$as_echo "$as_me: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the preprocessor's result" >&5
+$as_echo "$as_me: WARNING: $ac_header: proceeding with the preprocessor's result" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: in the future, the compiler will take precedence" >&5
+$as_echo "$as_me: WARNING: $ac_header: in the future, the compiler will take precedence" >&2;}
+
+    ;;
+esac
+{ $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
+$as_echo_n "checking for $ac_header... " >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  $as_echo_n "(cached) " >&6
+else
+  eval "$as_ac_Header=\$ac_header_preproc"
+fi
+ac_res=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+
+fi
+as_val=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+   if test "x$as_val" = x""yes; then
+  cat >>confdefs.h <<_ACEOF
+#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
+_ACEOF
+
+else
+  $bailout
+fi
+
+done
+
+		check_lib_no_libs ccs ccs_connect
+		if test $NOTFOUND = 0; then
+			{ $as_echo "$as_me:$LINENO: result: no pkg for libccs, using -lccs" >&5
+$as_echo "no pkg for libccs, using -lccs" >&6; }
+			CCS_LIBS="-lccs"
+			HAVE_CCS=yes
+		fi
+elif test $pkg_failed = untried; then
+	NOTFOUND=0
+
+for ac_header in ccs.h
+do
+as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  { $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
+$as_echo_n "checking for $ac_header... " >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  $as_echo_n "(cached) " >&6
+fi
+ac_res=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+else
+  # Is the header compilable?
+{ $as_echo "$as_me:$LINENO: checking $ac_header usability" >&5
+$as_echo_n "checking $ac_header usability... " >&6; }
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+$ac_includes_default
+#include <$ac_header>
+_ACEOF
+rm -f conftest.$ac_objext
+if { (ac_try="$ac_compile"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_compile") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       } && test -s conftest.$ac_objext; then
+  ac_header_compiler=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	ac_header_compiler=no
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+{ $as_echo "$as_me:$LINENO: result: $ac_header_compiler" >&5
+$as_echo "$ac_header_compiler" >&6; }
+
+# Is the header present?
+{ $as_echo "$as_me:$LINENO: checking $ac_header presence" >&5
+$as_echo_n "checking $ac_header presence... " >&6; }
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+#include <$ac_header>
+_ACEOF
+if { (ac_try="$ac_cpp conftest.$ac_ext"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_cpp conftest.$ac_ext") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } >/dev/null && {
+	 test -z "$ac_c_preproc_warn_flag$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       }; then
+  ac_header_preproc=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+  ac_header_preproc=no
+fi
+
+rm -f conftest.err conftest.$ac_ext
+{ $as_echo "$as_me:$LINENO: result: $ac_header_preproc" >&5
+$as_echo "$ac_header_preproc" >&6; }
+
+# So?  What about this header?
+case $ac_header_compiler:$ac_header_preproc:$ac_c_preproc_warn_flag in
+  yes:no: )
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&5
+$as_echo "$as_me: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the compiler's result" >&5
+$as_echo "$as_me: WARNING: $ac_header: proceeding with the compiler's result" >&2;}
+    ac_header_preproc=yes
+    ;;
+  no:yes:* )
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: present but cannot be compiled" >&5
+$as_echo "$as_me: WARNING: $ac_header: present but cannot be compiled" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header:     check for missing prerequisite headers?" >&5
+$as_echo "$as_me: WARNING: $ac_header:     check for missing prerequisite headers?" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: see the Autoconf documentation" >&5
+$as_echo "$as_me: WARNING: $ac_header: see the Autoconf documentation" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&5
+$as_echo "$as_me: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the preprocessor's result" >&5
+$as_echo "$as_me: WARNING: $ac_header: proceeding with the preprocessor's result" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: in the future, the compiler will take precedence" >&5
+$as_echo "$as_me: WARNING: $ac_header: in the future, the compiler will take precedence" >&2;}
+
+    ;;
+esac
+{ $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
+$as_echo_n "checking for $ac_header... " >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  $as_echo_n "(cached) " >&6
+else
+  eval "$as_ac_Header=\$ac_header_preproc"
+fi
+ac_res=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+
+fi
+as_val=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+   if test "x$as_val" = x""yes; then
+  cat >>confdefs.h <<_ACEOF
+#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
+_ACEOF
+
+else
+  $bailout
+fi
+
+done
+
+		check_lib_no_libs ccs ccs_connect
+		if test $NOTFOUND = 0; then
+			{ $as_echo "$as_me:$LINENO: result: no pkg for libccs, using -lccs" >&5
+$as_echo "no pkg for libccs, using -lccs" >&6; }
+			CCS_LIBS="-lccs"
+			HAVE_CCS=yes
+		fi
+else
+	CCS_CFLAGS=$pkg_cv_CCS_CFLAGS
+	CCS_LIBS=$pkg_cv_CCS_LIBS
+        { $as_echo "$as_me:$LINENO: result: yes" >&5
+$as_echo "yes" >&6; }
+	HAVE_CCS=yes
+fi
+
+pkg_failed=no
+{ $as_echo "$as_me:$LINENO: checking for GULM" >&5
+$as_echo_n "checking for GULM... " >&6; }
+
+if test -n "$GULM_CFLAGS"; then
+    pkg_cv_GULM_CFLAGS="$GULM_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libgulm\"") >&5
+  ($PKG_CONFIG --exists --print-errors "libgulm") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; then
+  pkg_cv_GULM_CFLAGS=`$PKG_CONFIG --cflags "libgulm" 2>/dev/null`
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$GULM_LIBS"; then
+    pkg_cv_GULM_LIBS="$GULM_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libgulm\"") >&5
+  ($PKG_CONFIG --exists --print-errors "libgulm") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; then
+  pkg_cv_GULM_LIBS=`$PKG_CONFIG --libs "libgulm" 2>/dev/null`
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
+	        GULM_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libgulm" 2>&1`
+        else
+	        GULM_PKG_ERRORS=`$PKG_CONFIG --print-errors "libgulm" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$GULM_PKG_ERRORS" >&5
+
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+                NOTFOUND=0
+
+for ac_header in libgulm.h
+do
+as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  { $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
+$as_echo_n "checking for $ac_header... " >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  $as_echo_n "(cached) " >&6
+fi
+ac_res=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+else
+  # Is the header compilable?
+{ $as_echo "$as_me:$LINENO: checking $ac_header usability" >&5
+$as_echo_n "checking $ac_header usability... " >&6; }
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+$ac_includes_default
+#include <$ac_header>
+_ACEOF
+rm -f conftest.$ac_objext
+if { (ac_try="$ac_compile"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_compile") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       } && test -s conftest.$ac_objext; then
+  ac_header_compiler=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	ac_header_compiler=no
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+{ $as_echo "$as_me:$LINENO: result: $ac_header_compiler" >&5
+$as_echo "$ac_header_compiler" >&6; }
+
+# Is the header present?
+{ $as_echo "$as_me:$LINENO: checking $ac_header presence" >&5
+$as_echo_n "checking $ac_header presence... " >&6; }
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+#include <$ac_header>
+_ACEOF
+if { (ac_try="$ac_cpp conftest.$ac_ext"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_cpp conftest.$ac_ext") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } >/dev/null && {
+	 test -z "$ac_c_preproc_warn_flag$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       }; then
+  ac_header_preproc=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+  ac_header_preproc=no
+fi
+
+rm -f conftest.err conftest.$ac_ext
+{ $as_echo "$as_me:$LINENO: result: $ac_header_preproc" >&5
+$as_echo "$ac_header_preproc" >&6; }
+
+# So?  What about this header?
+case $ac_header_compiler:$ac_header_preproc:$ac_c_preproc_warn_flag in
+  yes:no: )
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&5
+$as_echo "$as_me: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the compiler's result" >&5
+$as_echo "$as_me: WARNING: $ac_header: proceeding with the compiler's result" >&2;}
+    ac_header_preproc=yes
+    ;;
+  no:yes:* )
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: present but cannot be compiled" >&5
+$as_echo "$as_me: WARNING: $ac_header: present but cannot be compiled" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header:     check for missing prerequisite headers?" >&5
+$as_echo "$as_me: WARNING: $ac_header:     check for missing prerequisite headers?" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: see the Autoconf documentation" >&5
+$as_echo "$as_me: WARNING: $ac_header: see the Autoconf documentation" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&5
+$as_echo "$as_me: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the preprocessor's result" >&5
+$as_echo "$as_me: WARNING: $ac_header: proceeding with the preprocessor's result" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: in the future, the compiler will take precedence" >&5
+$as_echo "$as_me: WARNING: $ac_header: in the future, the compiler will take precedence" >&2;}
+
+    ;;
+esac
+{ $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
+$as_echo_n "checking for $ac_header... " >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  $as_echo_n "(cached) " >&6
+else
+  eval "$as_ac_Header=\$ac_header_preproc"
+fi
+ac_res=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+
+fi
+as_val=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+   if test "x$as_val" = x""yes; then
+  cat >>confdefs.h <<_ACEOF
+#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
+_ACEOF
+
+else
+  $bailout
+fi
+
+done
+
+		check_lib_no_libs gulm lg_core_login
+		if test $NOTFOUND = 0; then
+			{ $as_echo "$as_me:$LINENO: result: no pkg for libgulm, using -lgulm" >&5
+$as_echo "no pkg for libgulm, using -lgulm" >&6; }
+			GULM_LIBS="-lgulm"
+			HAVE_GULM=yes
+		fi
+elif test $pkg_failed = untried; then
+	NOTFOUND=0
+
+for ac_header in libgulm.h
+do
+as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  { $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
+$as_echo_n "checking for $ac_header... " >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  $as_echo_n "(cached) " >&6
+fi
+ac_res=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+else
+  # Is the header compilable?
+{ $as_echo "$as_me:$LINENO: checking $ac_header usability" >&5
+$as_echo_n "checking $ac_header usability... " >&6; }
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+$ac_includes_default
+#include <$ac_header>
+_ACEOF
+rm -f conftest.$ac_objext
+if { (ac_try="$ac_compile"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_compile") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       } && test -s conftest.$ac_objext; then
+  ac_header_compiler=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	ac_header_compiler=no
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+{ $as_echo "$as_me:$LINENO: result: $ac_header_compiler" >&5
+$as_echo "$ac_header_compiler" >&6; }
+
+# Is the header present?
+{ $as_echo "$as_me:$LINENO: checking $ac_header presence" >&5
+$as_echo_n "checking $ac_header presence... " >&6; }
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+#include <$ac_header>
+_ACEOF
+if { (ac_try="$ac_cpp conftest.$ac_ext"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_cpp conftest.$ac_ext") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } >/dev/null && {
+	 test -z "$ac_c_preproc_warn_flag$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       }; then
+  ac_header_preproc=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+  ac_header_preproc=no
+fi
+
+rm -f conftest.err conftest.$ac_ext
+{ $as_echo "$as_me:$LINENO: result: $ac_header_preproc" >&5
+$as_echo "$ac_header_preproc" >&6; }
+
+# So?  What about this header?
+case $ac_header_compiler:$ac_header_preproc:$ac_c_preproc_warn_flag in
+  yes:no: )
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&5
+$as_echo "$as_me: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the compiler's result" >&5
+$as_echo "$as_me: WARNING: $ac_header: proceeding with the compiler's result" >&2;}
+    ac_header_preproc=yes
+    ;;
+  no:yes:* )
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: present but cannot be compiled" >&5
+$as_echo "$as_me: WARNING: $ac_header: present but cannot be compiled" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header:     check for missing prerequisite headers?" >&5
+$as_echo "$as_me: WARNING: $ac_header:     check for missing prerequisite headers?" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: see the Autoconf documentation" >&5
+$as_echo "$as_me: WARNING: $ac_header: see the Autoconf documentation" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&5
+$as_echo "$as_me: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the preprocessor's result" >&5
+$as_echo "$as_me: WARNING: $ac_header: proceeding with the preprocessor's result" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: in the future, the compiler will take precedence" >&5
+$as_echo "$as_me: WARNING: $ac_header: in the future, the compiler will take precedence" >&2;}
+
+    ;;
+esac
+{ $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
+$as_echo_n "checking for $ac_header... " >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  $as_echo_n "(cached) " >&6
+else
+  eval "$as_ac_Header=\$ac_header_preproc"
+fi
+ac_res=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+
+fi
+as_val=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+   if test "x$as_val" = x""yes; then
+  cat >>confdefs.h <<_ACEOF
+#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
+_ACEOF
+
+else
+  $bailout
+fi
+
+done
+
+		check_lib_no_libs gulm lg_core_login
+		if test $NOTFOUND = 0; then
+			{ $as_echo "$as_me:$LINENO: result: no pkg for libgulm, using -lgulm" >&5
+$as_echo "no pkg for libgulm, using -lgulm" >&6; }
+			GULM_LIBS="-lgulm"
+			HAVE_GULM=yes
+		fi
+else
+	GULM_CFLAGS=$pkg_cv_GULM_CFLAGS
+	GULM_LIBS=$pkg_cv_GULM_LIBS
+        { $as_echo "$as_me:$LINENO: result: yes" >&5
+$as_echo "yes" >&6; }
+	HAVE_GULM=yes
+fi
+fi
+
+if test x$BUILDCMAN = xyes; then
+
+pkg_failed=no
+{ $as_echo "$as_me:$LINENO: checking for CMAN" >&5
+$as_echo_n "checking for CMAN... " >&6; }
+
+if test -n "$CMAN_CFLAGS"; then
+    pkg_cv_CMAN_CFLAGS="$CMAN_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libcman\"") >&5
+  ($PKG_CONFIG --exists --print-errors "libcman") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; then
+  pkg_cv_CMAN_CFLAGS=`$PKG_CONFIG --cflags "libcman" 2>/dev/null`
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$CMAN_LIBS"; then
+    pkg_cv_CMAN_LIBS="$CMAN_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libcman\"") >&5
+  ($PKG_CONFIG --exists --print-errors "libcman") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; then
+  pkg_cv_CMAN_LIBS=`$PKG_CONFIG --libs "libcman" 2>/dev/null`
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
+	        CMAN_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libcman" 2>&1`
+        else
+	        CMAN_PKG_ERRORS=`$PKG_CONFIG --print-errors "libcman" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$CMAN_PKG_ERRORS" >&5
+
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+                NOTFOUND=0
+
+for ac_header in libcman.h
+do
+as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  { $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
+$as_echo_n "checking for $ac_header... " >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  $as_echo_n "(cached) " >&6
+fi
+ac_res=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+else
+  # Is the header compilable?
+{ $as_echo "$as_me:$LINENO: checking $ac_header usability" >&5
+$as_echo_n "checking $ac_header usability... " >&6; }
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+$ac_includes_default
+#include <$ac_header>
+_ACEOF
+rm -f conftest.$ac_objext
+if { (ac_try="$ac_compile"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_compile") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       } && test -s conftest.$ac_objext; then
+  ac_header_compiler=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	ac_header_compiler=no
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+{ $as_echo "$as_me:$LINENO: result: $ac_header_compiler" >&5
+$as_echo "$ac_header_compiler" >&6; }
+
+# Is the header present?
+{ $as_echo "$as_me:$LINENO: checking $ac_header presence" >&5
+$as_echo_n "checking $ac_header presence... " >&6; }
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+#include <$ac_header>
+_ACEOF
+if { (ac_try="$ac_cpp conftest.$ac_ext"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_cpp conftest.$ac_ext") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } >/dev/null && {
+	 test -z "$ac_c_preproc_warn_flag$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       }; then
+  ac_header_preproc=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+  ac_header_preproc=no
+fi
+
+rm -f conftest.err conftest.$ac_ext
+{ $as_echo "$as_me:$LINENO: result: $ac_header_preproc" >&5
+$as_echo "$ac_header_preproc" >&6; }
+
+# So?  What about this header?
+case $ac_header_compiler:$ac_header_preproc:$ac_c_preproc_warn_flag in
+  yes:no: )
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&5
+$as_echo "$as_me: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the compiler's result" >&5
+$as_echo "$as_me: WARNING: $ac_header: proceeding with the compiler's result" >&2;}
+    ac_header_preproc=yes
+    ;;
+  no:yes:* )
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: present but cannot be compiled" >&5
+$as_echo "$as_me: WARNING: $ac_header: present but cannot be compiled" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header:     check for missing prerequisite headers?" >&5
+$as_echo "$as_me: WARNING: $ac_header:     check for missing prerequisite headers?" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: see the Autoconf documentation" >&5
+$as_echo "$as_me: WARNING: $ac_header: see the Autoconf documentation" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&5
+$as_echo "$as_me: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the preprocessor's result" >&5
+$as_echo "$as_me: WARNING: $ac_header: proceeding with the preprocessor's result" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: in the future, the compiler will take precedence" >&5
+$as_echo "$as_me: WARNING: $ac_header: in the future, the compiler will take precedence" >&2;}
+
+    ;;
+esac
+{ $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
+$as_echo_n "checking for $ac_header... " >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  $as_echo_n "(cached) " >&6
+else
+  eval "$as_ac_Header=\$ac_header_preproc"
+fi
+ac_res=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+
+fi
+as_val=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+   if test "x$as_val" = x""yes; then
+  cat >>confdefs.h <<_ACEOF
+#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
+_ACEOF
+
+else
+  $bailout
+fi
+
+done
+
+		check_lib_no_libs cman cman_init
+		if test $NOTFOUND = 0; then
+			{ $as_echo "$as_me:$LINENO: result: no pkg for libcman, using -lcman" >&5
+$as_echo "no pkg for libcman, using -lcman" >&6; }
+			CMAN_LIBS="-lcman"
+			HAVE_CMAN=yes
+		fi
+elif test $pkg_failed = untried; then
+	NOTFOUND=0
+
+for ac_header in libcman.h
+do
+as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  { $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
+$as_echo_n "checking for $ac_header... " >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  $as_echo_n "(cached) " >&6
+fi
+ac_res=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+else
+  # Is the header compilable?
+{ $as_echo "$as_me:$LINENO: checking $ac_header usability" >&5
+$as_echo_n "checking $ac_header usability... " >&6; }
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+$ac_includes_default
+#include <$ac_header>
+_ACEOF
+rm -f conftest.$ac_objext
+if { (ac_try="$ac_compile"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_compile") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       } && test -s conftest.$ac_objext; then
+  ac_header_compiler=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	ac_header_compiler=no
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+{ $as_echo "$as_me:$LINENO: result: $ac_header_compiler" >&5
+$as_echo "$ac_header_compiler" >&6; }
+
+# Is the header present?
+{ $as_echo "$as_me:$LINENO: checking $ac_header presence" >&5
+$as_echo_n "checking $ac_header presence... " >&6; }
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+#include <$ac_header>
+_ACEOF
+if { (ac_try="$ac_cpp conftest.$ac_ext"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_cpp conftest.$ac_ext") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } >/dev/null && {
+	 test -z "$ac_c_preproc_warn_flag$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       }; then
+  ac_header_preproc=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+  ac_header_preproc=no
+fi
+
+rm -f conftest.err conftest.$ac_ext
+{ $as_echo "$as_me:$LINENO: result: $ac_header_preproc" >&5
+$as_echo "$ac_header_preproc" >&6; }
+
+# So?  What about this header?
+case $ac_header_compiler:$ac_header_preproc:$ac_c_preproc_warn_flag in
+  yes:no: )
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&5
+$as_echo "$as_me: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the compiler's result" >&5
+$as_echo "$as_me: WARNING: $ac_header: proceeding with the compiler's result" >&2;}
+    ac_header_preproc=yes
+    ;;
+  no:yes:* )
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: present but cannot be compiled" >&5
+$as_echo "$as_me: WARNING: $ac_header: present but cannot be compiled" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header:     check for missing prerequisite headers?" >&5
+$as_echo "$as_me: WARNING: $ac_header:     check for missing prerequisite headers?" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: see the Autoconf documentation" >&5
+$as_echo "$as_me: WARNING: $ac_header: see the Autoconf documentation" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&5
+$as_echo "$as_me: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the preprocessor's result" >&5
+$as_echo "$as_me: WARNING: $ac_header: proceeding with the preprocessor's result" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: in the future, the compiler will take precedence" >&5
+$as_echo "$as_me: WARNING: $ac_header: in the future, the compiler will take precedence" >&2;}
+
+    ;;
+esac
+{ $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
+$as_echo_n "checking for $ac_header... " >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  $as_echo_n "(cached) " >&6
+else
+  eval "$as_ac_Header=\$ac_header_preproc"
+fi
+ac_res=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+
+fi
+as_val=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+   if test "x$as_val" = x""yes; then
+  cat >>confdefs.h <<_ACEOF
+#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
+_ACEOF
+
+else
+  $bailout
+fi
+
+done
+
+		check_lib_no_libs cman cman_init
+		if test $NOTFOUND = 0; then
+			{ $as_echo "$as_me:$LINENO: result: no pkg for libcman, using -lcman" >&5
+$as_echo "no pkg for libcman, using -lcman" >&6; }
+			CMAN_LIBS="-lcman"
+			HAVE_CMAN=yes
+		fi
+else
+	CMAN_CFLAGS=$pkg_cv_CMAN_CFLAGS
+	CMAN_LIBS=$pkg_cv_CMAN_LIBS
+        { $as_echo "$as_me:$LINENO: result: yes" >&5
+$as_echo "yes" >&6; }
+	HAVE_CMAN=yes
+fi
+	CHECKCONFDB=yes
+	CHECKDLM=yes
+fi
+
+if test x$BUILDCOROSYNC = xyes || \
+   test x$BUILDOPENAIS = xyes; then
+
+pkg_failed=no
+{ $as_echo "$as_me:$LINENO: checking for COROSYNC" >&5
+$as_echo_n "checking for COROSYNC... " >&6; }
+
+if test -n "$COROSYNC_CFLAGS"; then
+    pkg_cv_COROSYNC_CFLAGS="$COROSYNC_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"corosync\"") >&5
+  ($PKG_CONFIG --exists --print-errors "corosync") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; then
+  pkg_cv_COROSYNC_CFLAGS=`$PKG_CONFIG --cflags "corosync" 2>/dev/null`
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$COROSYNC_LIBS"; then
+    pkg_cv_COROSYNC_LIBS="$COROSYNC_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"corosync\"") >&5
+  ($PKG_CONFIG --exists --print-errors "corosync") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; then
+  pkg_cv_COROSYNC_LIBS=`$PKG_CONFIG --libs "corosync" 2>/dev/null`
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
+	        COROSYNC_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "corosync" 2>&1`
+        else
+	        COROSYNC_PKG_ERRORS=`$PKG_CONFIG --print-errors "corosync" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$COROSYNC_PKG_ERRORS" >&5
+
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+                $bailout
+elif test $pkg_failed = untried; then
+	$bailout
+else
+	COROSYNC_CFLAGS=$pkg_cv_COROSYNC_CFLAGS
+	COROSYNC_LIBS=$pkg_cv_COROSYNC_LIBS
+        { $as_echo "$as_me:$LINENO: result: yes" >&5
+$as_echo "yes" >&6; }
+	HAVE_COROSYNC=yes
+fi
+	CHECKCONFDB=yes
+fi
+
+if test x$BUILDCOROSYNC = xyes; then
+
+pkg_failed=no
+{ $as_echo "$as_me:$LINENO: checking for QUORUM" >&5
+$as_echo_n "checking for QUORUM... " >&6; }
+
+if test -n "$QUORUM_CFLAGS"; then
+    pkg_cv_QUORUM_CFLAGS="$QUORUM_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libquorum\"") >&5
+  ($PKG_CONFIG --exists --print-errors "libquorum") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; then
+  pkg_cv_QUORUM_CFLAGS=`$PKG_CONFIG --cflags "libquorum" 2>/dev/null`
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$QUORUM_LIBS"; then
+    pkg_cv_QUORUM_LIBS="$QUORUM_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libquorum\"") >&5
+  ($PKG_CONFIG --exists --print-errors "libquorum") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; then
+  pkg_cv_QUORUM_LIBS=`$PKG_CONFIG --libs "libquorum" 2>/dev/null`
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
+	        QUORUM_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libquorum" 2>&1`
+        else
+	        QUORUM_PKG_ERRORS=`$PKG_CONFIG --print-errors "libquorum" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$QUORUM_PKG_ERRORS" >&5
+
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+                $bailout
+elif test $pkg_failed = untried; then
+	$bailout
+else
+	QUORUM_CFLAGS=$pkg_cv_QUORUM_CFLAGS
+	QUORUM_LIBS=$pkg_cv_QUORUM_LIBS
+        { $as_echo "$as_me:$LINENO: result: yes" >&5
+$as_echo "yes" >&6; }
+	HAVE_QUORUM=yes
+fi
+	CHECKCPG=yes
+	CHECKDLM=yes
+fi
+
+if test x$BUILDOPENAIS = xyes; then
+
+pkg_failed=no
+{ $as_echo "$as_me:$LINENO: checking for SALCK" >&5
+$as_echo_n "checking for SALCK... " >&6; }
+
+if test -n "$SALCK_CFLAGS"; then
+    pkg_cv_SALCK_CFLAGS="$SALCK_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libSaLck\"") >&5
+  ($PKG_CONFIG --exists --print-errors "libSaLck") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; then
+  pkg_cv_SALCK_CFLAGS=`$PKG_CONFIG --cflags "libSaLck" 2>/dev/null`
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$SALCK_LIBS"; then
+    pkg_cv_SALCK_LIBS="$SALCK_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libSaLck\"") >&5
+  ($PKG_CONFIG --exists --print-errors "libSaLck") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; then
+  pkg_cv_SALCK_LIBS=`$PKG_CONFIG --libs "libSaLck" 2>/dev/null`
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
+	        SALCK_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libSaLck" 2>&1`
+        else
+	        SALCK_PKG_ERRORS=`$PKG_CONFIG --print-errors "libSaLck" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$SALCK_PKG_ERRORS" >&5
+
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+                $bailout
+elif test $pkg_failed = untried; then
+	$bailout
+else
+	SALCK_CFLAGS=$pkg_cv_SALCK_CFLAGS
+	SALCK_LIBS=$pkg_cv_SALCK_LIBS
+        { $as_echo "$as_me:$LINENO: result: yes" >&5
+$as_echo "yes" >&6; }
+	HAVE_SALCK=yes
+fi
+	CHECKCPG=yes
+fi
+
+
+
+if test x$CHECKCONFDB = xyes; then
+
+pkg_failed=no
+{ $as_echo "$as_me:$LINENO: checking for CONFDB" >&5
+$as_echo_n "checking for CONFDB... " >&6; }
+
+if test -n "$CONFDB_CFLAGS"; then
+    pkg_cv_CONFDB_CFLAGS="$CONFDB_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libconfdb\"") >&5
+  ($PKG_CONFIG --exists --print-errors "libconfdb") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; then
+  pkg_cv_CONFDB_CFLAGS=`$PKG_CONFIG --cflags "libconfdb" 2>/dev/null`
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$CONFDB_LIBS"; then
+    pkg_cv_CONFDB_LIBS="$CONFDB_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libconfdb\"") >&5
+  ($PKG_CONFIG --exists --print-errors "libconfdb") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; then
+  pkg_cv_CONFDB_LIBS=`$PKG_CONFIG --libs "libconfdb" 2>/dev/null`
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
+	        CONFDB_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libconfdb" 2>&1`
+        else
+	        CONFDB_PKG_ERRORS=`$PKG_CONFIG --print-errors "libconfdb" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$CONFDB_PKG_ERRORS" >&5
+
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+                HAVE_CONFDB=no
+elif test $pkg_failed = untried; then
+	HAVE_CONFDB=no
+else
+	CONFDB_CFLAGS=$pkg_cv_CONFDB_CFLAGS
+	CONFDB_LIBS=$pkg_cv_CONFDB_LIBS
+        { $as_echo "$as_me:$LINENO: result: yes" >&5
+$as_echo "yes" >&6; }
+	HAVE_CONFDB=yes
+fi
+
+
+for ac_header in corosync/confdb.h
+do
+as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  { $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
+$as_echo_n "checking for $ac_header... " >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  $as_echo_n "(cached) " >&6
+fi
+ac_res=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+else
+  # Is the header compilable?
+{ $as_echo "$as_me:$LINENO: checking $ac_header usability" >&5
+$as_echo_n "checking $ac_header usability... " >&6; }
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+$ac_includes_default
+#include <$ac_header>
+_ACEOF
+rm -f conftest.$ac_objext
+if { (ac_try="$ac_compile"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_compile") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       } && test -s conftest.$ac_objext; then
+  ac_header_compiler=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	ac_header_compiler=no
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+{ $as_echo "$as_me:$LINENO: result: $ac_header_compiler" >&5
+$as_echo "$ac_header_compiler" >&6; }
+
+# Is the header present?
+{ $as_echo "$as_me:$LINENO: checking $ac_header presence" >&5
+$as_echo_n "checking $ac_header presence... " >&6; }
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+#include <$ac_header>
+_ACEOF
+if { (ac_try="$ac_cpp conftest.$ac_ext"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_cpp conftest.$ac_ext") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } >/dev/null && {
+	 test -z "$ac_c_preproc_warn_flag$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       }; then
+  ac_header_preproc=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+  ac_header_preproc=no
+fi
+
+rm -f conftest.err conftest.$ac_ext
+{ $as_echo "$as_me:$LINENO: result: $ac_header_preproc" >&5
+$as_echo "$ac_header_preproc" >&6; }
+
+# So?  What about this header?
+case $ac_header_compiler:$ac_header_preproc:$ac_c_preproc_warn_flag in
+  yes:no: )
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&5
+$as_echo "$as_me: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the compiler's result" >&5
+$as_echo "$as_me: WARNING: $ac_header: proceeding with the compiler's result" >&2;}
+    ac_header_preproc=yes
+    ;;
+  no:yes:* )
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: present but cannot be compiled" >&5
+$as_echo "$as_me: WARNING: $ac_header: present but cannot be compiled" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header:     check for missing prerequisite headers?" >&5
+$as_echo "$as_me: WARNING: $ac_header:     check for missing prerequisite headers?" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: see the Autoconf documentation" >&5
+$as_echo "$as_me: WARNING: $ac_header: see the Autoconf documentation" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&5
+$as_echo "$as_me: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the preprocessor's result" >&5
+$as_echo "$as_me: WARNING: $ac_header: proceeding with the preprocessor's result" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: in the future, the compiler will take precedence" >&5
+$as_echo "$as_me: WARNING: $ac_header: in the future, the compiler will take precedence" >&2;}
+
+    ;;
+esac
+{ $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
+$as_echo_n "checking for $ac_header... " >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  $as_echo_n "(cached) " >&6
+else
+  eval "$as_ac_Header=\$ac_header_preproc"
+fi
+ac_res=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+
+fi
+as_val=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+   if test "x$as_val" = x""yes; then
+  cat >>confdefs.h <<_ACEOF
+#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
+_ACEOF
+ HAVE_CONFDB_H=yes
+else
+  HAVE_CONFDB_H=no
+fi
+
+done
+
+
+	if test x$HAVE_CONFDB != xyes && \
+	   test x$HAVE_CONFDB_H = xyes; then
+		check_lib_no_libs confdb confdb_initialize
+		{ $as_echo "$as_me:$LINENO: result: no pkg for confdb, using -lconfdb" >&5
+$as_echo "no pkg for confdb, using -lconfdb" >&6; }
+		CONFDB_LIBS="-lconfdb"
+		HAVE_CONFDB=yes
+	fi
+
+	if test x$BUILDCOROSYNC = xyes && \
+	   test x$HAVE_CONFDB != xyes &&
+	   test x$CLVMD != xall; then
+		{ { $as_echo "$as_me:$LINENO: error: bailing out... confdb library is required" >&5
+$as_echo "$as_me: error: bailing out... confdb library is required" >&2;}
+   { (exit 1); exit 1; }; }
+	fi
+fi
+
+if test x$CHECKCPG = xyes; then
+
+pkg_failed=no
+{ $as_echo "$as_me:$LINENO: checking for CPG" >&5
+$as_echo_n "checking for CPG... " >&6; }
+
+if test -n "$CPG_CFLAGS"; then
+    pkg_cv_CPG_CFLAGS="$CPG_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libcpg\"") >&5
+  ($PKG_CONFIG --exists --print-errors "libcpg") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; then
+  pkg_cv_CPG_CFLAGS=`$PKG_CONFIG --cflags "libcpg" 2>/dev/null`
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$CPG_LIBS"; then
+    pkg_cv_CPG_LIBS="$CPG_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libcpg\"") >&5
+  ($PKG_CONFIG --exists --print-errors "libcpg") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; then
+  pkg_cv_CPG_LIBS=`$PKG_CONFIG --libs "libcpg" 2>/dev/null`
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
+	        CPG_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libcpg" 2>&1`
+        else
+	        CPG_PKG_ERRORS=`$PKG_CONFIG --print-errors "libcpg" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$CPG_PKG_ERRORS" >&5
+
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+                $bailout
+elif test $pkg_failed = untried; then
+	$bailout
+else
+	CPG_CFLAGS=$pkg_cv_CPG_CFLAGS
+	CPG_LIBS=$pkg_cv_CPG_LIBS
+        { $as_echo "$as_me:$LINENO: result: yes" >&5
+$as_echo "yes" >&6; }
+	HAVE_CPG=yes
+fi
+fi
+
+if test x$CHECKDLM = xyes; then
+
+pkg_failed=no
+{ $as_echo "$as_me:$LINENO: checking for DLM" >&5
+$as_echo_n "checking for DLM... " >&6; }
+
+if test -n "$DLM_CFLAGS"; then
+    pkg_cv_DLM_CFLAGS="$DLM_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libdlm\"") >&5
+  ($PKG_CONFIG --exists --print-errors "libdlm") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; then
+  pkg_cv_DLM_CFLAGS=`$PKG_CONFIG --cflags "libdlm" 2>/dev/null`
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$DLM_LIBS"; then
+    pkg_cv_DLM_LIBS="$DLM_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libdlm\"") >&5
+  ($PKG_CONFIG --exists --print-errors "libdlm") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; then
+  pkg_cv_DLM_LIBS=`$PKG_CONFIG --libs "libdlm" 2>/dev/null`
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
+	        DLM_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libdlm" 2>&1`
+        else
+	        DLM_PKG_ERRORS=`$PKG_CONFIG --print-errors "libdlm" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$DLM_PKG_ERRORS" >&5
+
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+                NOTFOUND=0
+
+for ac_header in libdlm.h
+do
+as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  { $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
+$as_echo_n "checking for $ac_header... " >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  $as_echo_n "(cached) " >&6
+fi
+ac_res=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+else
+  # Is the header compilable?
+{ $as_echo "$as_me:$LINENO: checking $ac_header usability" >&5
+$as_echo_n "checking $ac_header usability... " >&6; }
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+$ac_includes_default
+#include <$ac_header>
+_ACEOF
+rm -f conftest.$ac_objext
+if { (ac_try="$ac_compile"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_compile") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       } && test -s conftest.$ac_objext; then
+  ac_header_compiler=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	ac_header_compiler=no
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+{ $as_echo "$as_me:$LINENO: result: $ac_header_compiler" >&5
+$as_echo "$ac_header_compiler" >&6; }
+
+# Is the header present?
+{ $as_echo "$as_me:$LINENO: checking $ac_header presence" >&5
+$as_echo_n "checking $ac_header presence... " >&6; }
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+#include <$ac_header>
+_ACEOF
+if { (ac_try="$ac_cpp conftest.$ac_ext"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_cpp conftest.$ac_ext") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } >/dev/null && {
+	 test -z "$ac_c_preproc_warn_flag$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       }; then
+  ac_header_preproc=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+  ac_header_preproc=no
+fi
+
+rm -f conftest.err conftest.$ac_ext
+{ $as_echo "$as_me:$LINENO: result: $ac_header_preproc" >&5
+$as_echo "$ac_header_preproc" >&6; }
+
+# So?  What about this header?
+case $ac_header_compiler:$ac_header_preproc:$ac_c_preproc_warn_flag in
+  yes:no: )
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&5
+$as_echo "$as_me: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the compiler's result" >&5
+$as_echo "$as_me: WARNING: $ac_header: proceeding with the compiler's result" >&2;}
+    ac_header_preproc=yes
+    ;;
+  no:yes:* )
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: present but cannot be compiled" >&5
+$as_echo "$as_me: WARNING: $ac_header: present but cannot be compiled" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header:     check for missing prerequisite headers?" >&5
+$as_echo "$as_me: WARNING: $ac_header:     check for missing prerequisite headers?" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: see the Autoconf documentation" >&5
+$as_echo "$as_me: WARNING: $ac_header: see the Autoconf documentation" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&5
+$as_echo "$as_me: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the preprocessor's result" >&5
+$as_echo "$as_me: WARNING: $ac_header: proceeding with the preprocessor's result" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: in the future, the compiler will take precedence" >&5
+$as_echo "$as_me: WARNING: $ac_header: in the future, the compiler will take precedence" >&2;}
+
+    ;;
+esac
+{ $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
+$as_echo_n "checking for $ac_header... " >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  $as_echo_n "(cached) " >&6
+else
+  eval "$as_ac_Header=\$ac_header_preproc"
+fi
+ac_res=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+
+fi
+as_val=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+   if test "x$as_val" = x""yes; then
+  cat >>confdefs.h <<_ACEOF
+#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
+_ACEOF
+
+else
+  $bailout
+fi
+
+done
+
+		check_lib_no_libs dlm dlm_lock -lpthread
+		if test $NOTFOUND = 0; then
+			{ $as_echo "$as_me:$LINENO: result: no pkg for libdlm, using -ldlm" >&5
+$as_echo "no pkg for libdlm, using -ldlm" >&6; }
+			DLM_LIBS="-ldlm -lpthread"
+			HAVE_DLM=yes
+		fi
+elif test $pkg_failed = untried; then
+	NOTFOUND=0
+
+for ac_header in libdlm.h
+do
+as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  { $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
+$as_echo_n "checking for $ac_header... " >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  $as_echo_n "(cached) " >&6
+fi
+ac_res=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+else
+  # Is the header compilable?
+{ $as_echo "$as_me:$LINENO: checking $ac_header usability" >&5
+$as_echo_n "checking $ac_header usability... " >&6; }
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+$ac_includes_default
+#include <$ac_header>
+_ACEOF
+rm -f conftest.$ac_objext
+if { (ac_try="$ac_compile"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_compile") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       } && test -s conftest.$ac_objext; then
+  ac_header_compiler=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	ac_header_compiler=no
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+{ $as_echo "$as_me:$LINENO: result: $ac_header_compiler" >&5
+$as_echo "$ac_header_compiler" >&6; }
+
+# Is the header present?
+{ $as_echo "$as_me:$LINENO: checking $ac_header presence" >&5
+$as_echo_n "checking $ac_header presence... " >&6; }
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+#include <$ac_header>
+_ACEOF
+if { (ac_try="$ac_cpp conftest.$ac_ext"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_cpp conftest.$ac_ext") 2>conftest.er1
+  ac_status=$?
+  grep -v '^ *+' conftest.er1 >conftest.err
+  rm -f conftest.er1
+  cat conftest.err >&5
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } >/dev/null && {
+	 test -z "$ac_c_preproc_warn_flag$ac_c_werror_flag" ||
+	 test ! -s conftest.err
+       }; then
+  ac_header_preproc=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+  ac_header_preproc=no
+fi
+
+rm -f conftest.err conftest.$ac_ext
+{ $as_echo "$as_me:$LINENO: result: $ac_header_preproc" >&5
+$as_echo "$ac_header_preproc" >&6; }
+
+# So?  What about this header?
+case $ac_header_compiler:$ac_header_preproc:$ac_c_preproc_warn_flag in
+  yes:no: )
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&5
+$as_echo "$as_me: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the compiler's result" >&5
+$as_echo "$as_me: WARNING: $ac_header: proceeding with the compiler's result" >&2;}
+    ac_header_preproc=yes
+    ;;
+  no:yes:* )
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: present but cannot be compiled" >&5
+$as_echo "$as_me: WARNING: $ac_header: present but cannot be compiled" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header:     check for missing prerequisite headers?" >&5
+$as_echo "$as_me: WARNING: $ac_header:     check for missing prerequisite headers?" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: see the Autoconf documentation" >&5
+$as_echo "$as_me: WARNING: $ac_header: see the Autoconf documentation" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&5
+$as_echo "$as_me: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the preprocessor's result" >&5
+$as_echo "$as_me: WARNING: $ac_header: proceeding with the preprocessor's result" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: in the future, the compiler will take precedence" >&5
+$as_echo "$as_me: WARNING: $ac_header: in the future, the compiler will take precedence" >&2;}
+
+    ;;
+esac
+{ $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
+$as_echo_n "checking for $ac_header... " >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  $as_echo_n "(cached) " >&6
+else
+  eval "$as_ac_Header=\$ac_header_preproc"
+fi
+ac_res=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+
+fi
+as_val=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+   if test "x$as_val" = x""yes; then
+  cat >>confdefs.h <<_ACEOF
+#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
+_ACEOF
+
+else
+  $bailout
+fi
+
+done
+
+		check_lib_no_libs dlm dlm_lock -lpthread
+		if test $NOTFOUND = 0; then
+			{ $as_echo "$as_me:$LINENO: result: no pkg for libdlm, using -ldlm" >&5
+$as_echo "no pkg for libdlm, using -ldlm" >&6; }
+			DLM_LIBS="-ldlm -lpthread"
+			HAVE_DLM=yes
+		fi
+else
+	DLM_CFLAGS=$pkg_cv_DLM_CFLAGS
+	DLM_LIBS=$pkg_cv_DLM_LIBS
+        { $as_echo "$as_me:$LINENO: result: yes" >&5
+$as_echo "yes" >&6; }
+	HAVE_DLM=yes
+fi
+fi
+
+if test x$CLVMD = xall; then
+	if test x$HAVE_CCS = xyes && \
+	   test x$HAVE_GULM = xyes; then
+		{ $as_echo "$as_me:$LINENO: result: Enabling clvmd gulm backend" >&5
+$as_echo "Enabling clvmd gulm backend" >&6; }
+		NEWCLVMD="$NEWCLVMD,gulm"
+	fi
+	if test x$HAVE_CMAN = xyes && \
+	   test x$HAVE_DLM = xyes; then
+		{ $as_echo "$as_me:$LINENO: result: Enabling clvmd cman backend" >&5
+$as_echo "Enabling clvmd cman backend" >&6; }
+		NEWCLVMD="$NEWCLVMD,cman"
+	fi
+	if test x$HAVE_COROSYNC = xyes && \
+	   test x$HAVE_QUORUM = xyes && \
+	   test x$HAVE_CPG = xyes && \
+	   test x$HAVE_DLM = xyes && \
+	   test x$HAVE_CONFDB = xyes; then
+		{ $as_echo "$as_me:$LINENO: result: Enabling clvmd corosync backend" >&5
+$as_echo "Enabling clvmd corosync backend" >&6; }
+		NEWCLVMD="$NEWCLVMD,corosync"
+	fi
+	if test x$HAVE_COROSYNC = xyes && \
+	   test x$HAVE_CPG = xyes && \
+	   test x$HAVE_SALCK = xyes; then
+		{ $as_echo "$as_me:$LINENO: result: Enabling clvmd openais backend" >&5
+$as_echo "Enabling clvmd openais backend" >&6; }
+		NEWCLVMD="$NEWCLVMD,openais"
+	fi
+	CLVMD="$NEWCLVMD"
+fi
+
+################################################################################
+{ $as_echo "$as_me:$LINENO: checking whether to build cluster log daemon" >&5
+$as_echo_n "checking whether to build cluster log daemon... " >&6; }
+# Check whether --enable-clogd was given.
+if test "${enable_clogd+set}" = set; then
+  enableval=$enable_clogd; CLOGD=$enableval
+fi
+
+{ $as_echo "$as_me:$LINENO: result: $CLOGD" >&5
+$as_echo "$CLOGD" >&6; }
+
+if [ "x$CLOGD" = xall -o `expr x"$CLOGD" : '.*corosync.*'` != 0 ]; then
+#
+#       FIXME: ALSO NEED TO CHECK FOR CHECKPOINT MODULE
+#
+
+pkg_failed=no
+{ $as_echo "$as_me:$LINENO: checking for CPG" >&5
+$as_echo_n "checking for CPG... " >&6; }
+
+if test -n "$CPG_CFLAGS"; then
+    pkg_cv_CPG_CFLAGS="$CPG_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libcpg\"") >&5
+  ($PKG_CONFIG --exists --print-errors "libcpg") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; then
+  pkg_cv_CPG_CFLAGS=`$PKG_CONFIG --cflags "libcpg" 2>/dev/null`
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$CPG_LIBS"; then
+    pkg_cv_CPG_LIBS="$CPG_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { ($as_echo "$as_me:$LINENO: \$PKG_CONFIG --exists --print-errors \"libcpg\"") >&5
+  ($PKG_CONFIG --exists --print-errors "libcpg") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; then
+  pkg_cv_CPG_LIBS=`$PKG_CONFIG --libs "libcpg" 2>/dev/null`
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
+	        CPG_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors "libcpg" 2>&1`
+        else
+	        CPG_PKG_ERRORS=`$PKG_CONFIG --print-errors "libcpg" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$CPG_PKG_ERRORS" >&5
+
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+                { $as_echo "$as_me:$LINENO: result: no pkg for libcpg library, using -lcpg" >&5
+$as_echo "no pkg for libcpg library, using -lcpg" >&6; };
+		CPG_LIBS="-lcpg"
+elif test $pkg_failed = untried; then
+	{ $as_echo "$as_me:$LINENO: result: no pkg for libcpg library, using -lcpg" >&5
+$as_echo "no pkg for libcpg library, using -lcpg" >&6; };
+		CPG_LIBS="-lcpg"
+else
+	CPG_CFLAGS=$pkg_cv_CPG_CFLAGS
+	CPG_LIBS=$pkg_cv_CPG_LIBS
+        { $as_echo "$as_me:$LINENO: result: yes" >&5
+$as_echo "yes" >&6; }
+	:
+fi
+fi
+
+################################################################################
+{ $as_echo "$as_me:$LINENO: checking whether to enable debugging" >&5
+$as_echo_n "checking whether to enable debugging... " >&6; }
+# Check whether --enable-debug was given.
+if test "${enable_debug+set}" = set; then
+  enableval=$enable_debug; DEBUG=$enableval
+else
+  DEBUG=no
+fi
+
+{ $as_echo "$as_me:$LINENO: result: $DEBUG" >&5
+$as_echo "$DEBUG" >&6; }
+
+if test x$DEBUG = xyes; then
+	COPTIMISE_FLAG=
+else
+	CSCOPE_CMD=
+fi
+
+################################################################################
+{ $as_echo "$as_me:$LINENO: checking for C optimisation flag" >&5
+$as_echo_n "checking for C optimisation flag... " >&6; }
+
+# Check whether --with-optimisation was given.
+if test "${with_optimisation+set}" = set; then
+  withval=$with_optimisation;  COPTIMISE_FLAG="$withval"
+fi
+
+{ $as_echo "$as_me:$LINENO: result: $COPTIMISE_FLAG" >&5
+$as_echo "$COPTIMISE_FLAG" >&6; }
+
+################################################################################
+{ $as_echo "$as_me:$LINENO: checking whether to gather gcov profiling data" >&5
+$as_echo_n "checking whether to gather gcov profiling data... " >&6; }
+# Check whether --enable-profiling was given.
+if test "${enable_profiling+set}" = set; then
+  enableval=$enable_profiling; PROFILING=$enableval
+else
   PROFILING=no
 fi
 
@@ -12904,8 +15111,19 @@
 
 
 
+
+
+
+
+
+
+
+
+
+
+
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/clogd/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -13508,6 +15726,7 @@
     "make.tmpl") CONFIG_FILES="$CONFIG_FILES make.tmpl" ;;
     "daemons/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/Makefile" ;;
     "daemons/clvmd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/clvmd/Makefile" ;;
+    "daemons/clogd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/clogd/Makefile" ;;
     "daemons/dmeventd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/Makefile" ;;
     "daemons/dmeventd/libdevmapper-event.pc") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/libdevmapper-event.pc" ;;
     "daemons/dmeventd/plugins/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/Makefile" ;;
--- LVM2/configure.in	2009/08/13 20:23:01	1.107
+++ LVM2/configure.in	2009/08/28 19:22:05	1.108
@@ -325,7 +325,13 @@
 dnl -- Build cluster LVM daemon
 AC_MSG_CHECKING(whether to build cluster LVM daemon)
 AC_ARG_WITH(clvmd,
-  [  --with-clvmd=TYPE       Build cluster LVM Daemon: cman/gulm/corosync/none/all
+  [  --with-clvmd=TYPE       Build cluster LVM Daemon.
+                          The following locking combinations are valid:
+                           * cman,gulm             (RHEL4 or equivalent)
+                           * cman                  (RHEL5 or equivalent)
+                           * cman,corosync,openais (or selection of them)
+                           * all                   (autodetect)
+                           * none                  (disable build)
                           [TYPE=none] ],
   [ CLVMD="$withval" ],
   [ CLVMD="none" ])
@@ -339,17 +345,208 @@
 	CLUSTER=internal
 fi
 
+dnl -- define build types
+if [[ `expr x"$CLVMD" : '.*gulm.*'` != 0 ]]; then
+	BUILDGULM=yes
+fi
+if [[ `expr x"$CLVMD" : '.*corosync.*'` != 0 ]]; then
+	BUILDCOROSYNC=yes
+fi
+if [[ `expr x"$CLVMD" : '.*openais.*'` != 0 ]]; then
+	BUILDOPENAIS=yes
+fi
+if [[ `expr x"$CLVMD" : '.*cman.*'` != 0 ]]; then
+	BUILDCMAN=yes
+fi
+
+dnl -- sanity check around user selection
+if test x$BUILDGULM = xyes; then
+	if test x$BUILDCOROSYNC = xyes || \
+	   test x$BUILDOPENAIS = xyes; then
+		AC_MSG_ERROR([requested clvmd configuration is not valid])
+	fi
+fi
+
+dnl -- Init pkg-config with dummy invokation:
+dnl -- this is required because PKG_CHECK_MODULES macro is expanded
+dnl -- to initialize the pkg-config environment only@the first invokation,
+dnl -- that would be conditional in this configure.in.
+if  test x$CLVMD != xnone; then
+	PKG_CHECK_MODULES(PKGCONFIGINIT, pkgconfiginit, [],
+		[AC_MSG_RESULT([pkg-config initialized])])
+fi
+
+dnl -- define a soft bailout if we are autodetecting
+soft_bailout() {
+	NOTFOUND=1
+}
+
+hard_bailout() {
+	AC_MSG_ERROR([bailing out])
+}
+
+dnl -- if clvmd=all then set soft_bailout (we don't want to error)
+dnl -- and set all builds to yes. We need to do this here
+dnl -- to skip the gulm + openais|corosync sanity check above.
+if test x$CLVMD = xall; then
+	bailout=soft_bailout
+	BUILDGULM=yes
+	BUILDCMAN=yes
+	BUILDCOROSYNC=yes
+	BUILDOPENAIS=yes
+else
+	bailout=hard_bailout
+fi
+
+dnl -- helper macro to check libs without adding them to LIBS
+check_lib_no_libs() {
+	lib_no_libs_arg1=$1
+	shift
+	lib_no_libs_arg2=$1
+	shift
+	lib_no_libs_args=$@
+	AC_CHECK_LIB([$lib_no_libs_arg1],
+		     [$lib_no_libs_arg2],,
+		     [$bailout],
+		     [$lib_no_libs_args])
+	LIBS=$ac_check_lib_save_LIBS
+}
+
+dnl -- Look for gulm libraries if required.
+if test x$BUILDGULM = xyes; then
+	PKG_CHECK_MODULES(CCS, libccs, [HAVE_CCS=yes],
+		[NOTFOUND=0
+		AC_CHECK_HEADERS(ccs.h,,$bailout)
+		check_lib_no_libs ccs ccs_connect
+		if test $NOTFOUND = 0; then
+			AC_MSG_RESULT([no pkg for libccs, using -lccs])
+			CCS_LIBS="-lccs"
+			HAVE_CCS=yes
+		fi])
+	PKG_CHECK_MODULES(GULM, libgulm, [HAVE_GULM=yes],
+		[NOTFOUND=0
+		AC_CHECK_HEADERS(libgulm.h,,$bailout)
+		check_lib_no_libs gulm lg_core_login
+		if test $NOTFOUND = 0; then
+			AC_MSG_RESULT([no pkg for libgulm, using -lgulm])
+			GULM_LIBS="-lgulm"
+			HAVE_GULM=yes
+		fi])
+fi
+
+dnl -- Look for cman libraries if required.
+if test x$BUILDCMAN = xyes; then
+	PKG_CHECK_MODULES(CMAN, libcman, [HAVE_CMAN=yes],
+		[NOTFOUND=0
+		AC_CHECK_HEADERS(libcman.h,,$bailout)
+		check_lib_no_libs cman cman_init
+		if test $NOTFOUND = 0; then
+			AC_MSG_RESULT([no pkg for libcman, using -lcman])
+			CMAN_LIBS="-lcman"
+			HAVE_CMAN=yes
+		fi])
+	CHECKCONFDB=yes
+	CHECKDLM=yes
+fi
+
+dnl -- Look for corosync that's required also for openais build
+dnl -- only enough recent version of corosync ship pkg-config files.
+dnl -- We can safely rely on that to detect the correct bits.
+if test x$BUILDCOROSYNC = xyes || \
+   test x$BUILDOPENAIS = xyes; then
+	PKG_CHECK_MODULES(COROSYNC, corosync, [HAVE_COROSYNC=yes], $bailout)
+	CHECKCONFDB=yes
+fi
+
 dnl -- Look for corosync libraries if required.
-if [[ "x$CLVMD" = xall -o `expr x"$CLVMD" : '.*corosync.*'` != 0 ]]; then
-	PKG_CHECK_MODULES(QUORUM, libquorum, [],
-		[AC_MSG_RESULT([no pkg for quorum library, using -lquorum]);
-		QUORUM_LIBS="-lquorum"])
-	PKG_CHECK_MODULES(CONFDB, libconfdb, [],
-		[AC_MSG_RESULT([no pkg for confdb library, using -lconfdb]);
-		CONFDB_LIBS="-lconfdb"])
-	PKG_CHECK_MODULES(CPG, libcpg, [],
-		[AC_MSG_RESULT([no pkg for libcpg library, using -lcpg]);
-		CPG_LIBS="-lcpg"])
+if test x$BUILDCOROSYNC = xyes; then
+	PKG_CHECK_MODULES(QUORUM, libquorum, [HAVE_QUORUM=yes], $bailout)
+	CHECKCPG=yes
+	CHECKDLM=yes
+fi
+
+dnl -- Look for openais libraries if required.
+if test x$BUILDOPENAIS = xyes; then
+	PKG_CHECK_MODULES(SALCK, libSaLck, [HAVE_SALCK=yes], $bailout)
+	CHECKCPG=yes
+fi
+
+dnl -- Below are checks for libraries common to more than one build.
+
+dnl -- Check confdb library.
+dnl -- mandatory for corosync build.
+dnl -- optional for openais/cman build.
+
+if test x$CHECKCONFDB = xyes; then
+	PKG_CHECK_MODULES(CONFDB, libconfdb,
+			  [HAVE_CONFDB=yes],
+			  [HAVE_CONFDB=no])
+
+	AC_CHECK_HEADERS(corosync/confdb.h,
+		[HAVE_CONFDB_H=yes],
+		[HAVE_CONFDB_H=no])
+
+	if test x$HAVE_CONFDB != xyes && \
+	   test x$HAVE_CONFDB_H = xyes; then
+		check_lib_no_libs confdb confdb_initialize
+		AC_MSG_RESULT([no pkg for confdb, using -lconfdb])
+		CONFDB_LIBS="-lconfdb"
+		HAVE_CONFDB=yes
+	fi
+
+	if test x$BUILDCOROSYNC = xyes && \
+	   test x$HAVE_CONFDB != xyes &&
+	   test x$CLVMD != xall; then
+		AC_MSG_ERROR([bailing out... confdb library is required])
+	fi
+fi
+
+dnl -- Check cpg library.
+if test x$CHECKCPG = xyes; then
+	PKG_CHECK_MODULES(CPG, libcpg, [HAVE_CPG=yes], $bailout)
+fi
+
+dnl -- Check dlm library.
+if test x$CHECKDLM = xyes; then
+	PKG_CHECK_MODULES(DLM, libdlm, [HAVE_DLM=yes],
+		[NOTFOUND=0
+		AC_CHECK_HEADERS(libdlm.h,,$bailout)
+		check_lib_no_libs dlm dlm_lock -lpthread
+		if test $NOTFOUND = 0; then
+			AC_MSG_RESULT([no pkg for libdlm, using -ldlm])
+			DLM_LIBS="-ldlm -lpthread"
+			HAVE_DLM=yes
+		fi])
+fi
+
+dnl -- If we are autodetecting, we need to re-create
+dnl -- the depedencies checks and set a proper CLVMD.
+if test x$CLVMD = xall; then
+	if test x$HAVE_CCS = xyes && \
+	   test x$HAVE_GULM = xyes; then
+		AC_MSG_RESULT([Enabling clvmd gulm backend])
+		NEWCLVMD="$NEWCLVMD,gulm"
+	fi
+	if test x$HAVE_CMAN = xyes && \
+	   test x$HAVE_DLM = xyes; then
+		AC_MSG_RESULT([Enabling clvmd cman backend])
+		NEWCLVMD="$NEWCLVMD,cman"
+	fi
+	if test x$HAVE_COROSYNC = xyes && \
+	   test x$HAVE_QUORUM = xyes && \
+	   test x$HAVE_CPG = xyes && \
+	   test x$HAVE_DLM = xyes && \
+	   test x$HAVE_CONFDB = xyes; then
+		AC_MSG_RESULT([Enabling clvmd corosync backend])
+		NEWCLVMD="$NEWCLVMD,corosync"
+	fi
+	if test x$HAVE_COROSYNC = xyes && \
+	   test x$HAVE_CPG = xyes && \
+	   test x$HAVE_SALCK = xyes; then
+		AC_MSG_RESULT([Enabling clvmd openais backend])
+		NEWCLVMD="$NEWCLVMD,openais"
+	fi
+	CLVMD="$NEWCLVMD"
 fi
 
 ################################################################################
@@ -811,6 +1008,8 @@
 ################################################################################
 AC_SUBST(APPLIB)
 AC_SUBST(BUILD_DMEVENTD)
+AC_SUBST(CCS_CFLAGS)
+AC_SUBST(CCS_LIBS)
 AC_SUBST(CFLAGS)
 AC_SUBST(CFLOW_CMD)
 AC_SUBST(CLDFLAGS)
@@ -819,6 +1018,8 @@
 AC_SUBST(CLUSTER)
 AC_SUBST(CLVMD)
 AC_SUBST(CLOGD)
+AC_SUBST(CMAN_CFLAGS)
+AC_SUBST(CMAN_LIBS)
 AC_SUBST(CMDLIB)
 AC_SUBST(CONFDB_CFLAGS)
 AC_SUBST(CONFDB_LIBS)
@@ -829,6 +1030,8 @@
 AC_SUBST(CSCOPE_CMD)
 AC_SUBST(DEBUG)
 AC_SUBST(DEVMAPPER)
+AC_SUBST(DLM_CFLAGS)
+AC_SUBST(DLM_LIBS)
 AC_SUBST(DMEVENTD)
 AC_SUBST(DM_COMPAT)
 AC_SUBST(DM_DEVICE_GID)
@@ -839,6 +1042,8 @@
 AC_SUBST(DM_LIB_PATCHLEVEL)
 AC_SUBST(FSADM)
 AC_SUBST(GROUP)
+AC_SUBST(GULM_CFLAGS)
+AC_SUBST(GULM_LIBS)
 AC_SUBST(HAVE_LIBDL)
 AC_SUBST(HAVE_REALTIME)
 AC_SUBST(HAVE_SELINUX)
@@ -865,6 +1070,8 @@
 AC_SUBST(POOL)
 AC_SUBST(QUORUM_CFLAGS)
 AC_SUBST(QUORUM_LIBS)
+AC_SUBST(SALCK_CFLAGS)
+AC_SUBST(SALCK_LIBS)
 AC_SUBST(SNAPSHOTS)
 AC_SUBST(STATICDIR)
 AC_SUBST(STATIC_LINK)
--- LVM2/daemons/clvmd/Makefile.in	2009/03/10 12:10:12	1.29
+++ LVM2/daemons/clvmd/Makefile.in	2009/08/28 19:22:05	1.30
@@ -15,12 +15,22 @@
 top_srcdir = @top_srcdir@
 VPATH = @srcdir@
 
-QUORUM_LIBS = @QUORUM_LIBS@
-QUORUM_CFLAGS = @QUORUM_CFLAGS@
+CCS_LIBS = @CCS_LIBS@
+CCS_CFLAGS = @CCS_CFLAGS@
+CMAN_LIBS = @CMAN_LIBS@
+CMAN_CFLAGS = @CMAN_CFLAGS@
 CONFDB_LIBS = @CONFDB_LIBS@
 CONFDB_CFLAGS = @CONFDB_CFLAGS@
 CPG_LIBS = @CPG_LIBS@
 CPG_CFLAGS = @CPG_CFLAGS@
+DLM_LIBS = @DLM_LIBS@
+DLM_CFLAGS = @DLM_CFLAGS@
+GULM_LIBS = @GULM_LIBS@
+GULM_CFLAGS = @GULM_CFLAGS@
+QUORUM_LIBS = @QUORUM_LIBS@
+QUORUM_CFLAGS = @QUORUM_CFLAGS@
+SALCK_LIBS = @SALCK_LIBS@
+SALCK_CFLAGS = @SALCK_CFLAGS@
 
 SOURCES = \
 	clvmd-command.c  \
@@ -28,55 +38,35 @@
 	lvm-functions.c  \
 	refresh_clvmd.c
 
-ifneq (,$(findstring gulm,, "@CLVMD@,"))
-	GULM = yes
-endif
-
-ifneq (,$(findstring cman,, "@CLVMD@,"))
-	CMAN = yes
-endif
-
-ifneq (,$(findstring openais,, "@CLVMD@,"))
-	OPENAIS = yes
-endif
-
-ifneq (,$(findstring corosync,, "@CLVMD@,"))
-	COROSYNC = yes
-endif
-
-ifneq (,$(findstring all,, "@CLVMD@,"))
-	GULM = yes
-	CMAN = yes
-	OPENAIS = yes
-	COROSYNC = yes
-endif
-
 ifeq ("@DEBUG@", "yes")
 	DEFS += -DDEBUG
 endif
 
-ifeq ("$(GULM)", "yes")
+ifneq (,$(findstring gulm,, "@CLVMD@,"))
 	SOURCES += clvmd-gulm.c tcp-comms.c
-	LMLIBS += -lccs -lgulm
+	LMLIBS += $(CCS_LIBS) $(GULM_LIBS)
+	CFLAGS += $(CCS_CFLAGS) $(GULM_CFLAGS)
 	DEFS += -DUSE_GULM
 endif
 
-ifeq ("$(CMAN)", "yes")
+ifneq (,$(findstring cman,, "@CLVMD@,"))
 	SOURCES += clvmd-cman.c
-	LMLIBS += -ldlm -lcman
+	LMLIBS += $(CMAN_LIBS) $(CONFDB_LIBS) $(DLM_LIBS)
+	CFLAGS += $(CMAN_CFLAGS) $(CONFDB_CFLAGS) $(DLM_CFLAGS)
 	DEFS += -DUSE_CMAN
 endif
 
-ifeq ("$(OPENAIS)", "yes")
+ifneq (,$(findstring openais,, "@CLVMD@,"))
 	SOURCES += clvmd-openais.c
-	LMLIBS += -lSaLck -lcpg
+	LMLIBS += $(CONFDB_LIBS) $(CPG_LIBS) $(SALCK_LIBS)
+	CFLAGS += $(CONFDB_CFLAGS) $(CPG_CFLAGS) $(SALCK_CFLAGS)
 	DEFS += -DUSE_OPENAIS
 endif
 
-ifeq ("$(COROSYNC)", "yes")
+ifneq (,$(findstring corosync,, "@CLVMD@,"))
 	SOURCES += clvmd-corosync.c
-	LMLIBS += $(QUORUM_LIBS) $(CONFDB_LIBS) $(CPG_LIBS) -ldlm
-	CFLAGS += $(QUORUM_CFLAGS) $(CONFDB_CFLAGS) $(CPG_CFLAGS)
+	LMLIBS += $(CONFDB_LIBS) $(CPG_LIBS) $(DLM_LIBS) $(QUORUM_LIBS)
+	CFLAGS += $(CONFDB_CFLAGS) $(CPG_CFLAGS) $(DLM_CFLAGS) $(QUORUM_CFLAGS)
 	DEFS += -DUSE_COROSYNC
 endif
 
--- LVM2/daemons/clvmd/clvmd-comms.h	2009/01/22 10:21:12	1.9
+++ LVM2/daemons/clvmd/clvmd-comms.h	2009/08/28 19:22:05	1.10
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -77,7 +77,7 @@
 
 #ifdef USE_OPENAIS
 #  include <openais/saAis.h>
-#  include <openais/totem/totem.h>
+#  include <corosync/totem/totem.h>
 #  define OPENAIS_CSID_LEN (sizeof(int))
 #  define OPENAIS_MAX_CLUSTER_MESSAGE         MESSAGE_SIZE_MAX
 #  define OPENAIS_MAX_CLUSTER_MEMBER_NAME_LEN SA_MAX_NAME_LENGTH
--- LVM2/daemons/clvmd/clvmd-corosync.c	2009/06/03 13:42:02	1.10
+++ LVM2/daemons/clvmd/clvmd-corosync.c	2009/08/28 19:22:05	1.11
@@ -55,13 +55,13 @@
 /* Timeout value for several corosync calls */
 #define LOCKSPACE_NAME "clvmd"
 
-static void cpg_deliver_callback (cpg_handle_t handle,
+static void corosync_cpg_deliver_callback (cpg_handle_t handle,
 				  const struct cpg_name *groupName,
 				  uint32_t nodeid,
 				  uint32_t pid,
 				  void *msg,
 				  size_t msg_len);
-static void cpg_confchg_callback(cpg_handle_t handle,
+static void corosync_cpg_confchg_callback(cpg_handle_t handle,
 				 const struct cpg_name *groupName,
 				 const struct cpg_address *member_list, size_t member_list_entries,
 				 const struct cpg_address *left_list, size_t left_list_entries,
@@ -87,9 +87,9 @@
 static struct cpg_name cpg_group_name;
 
 /* Corosync callback structs */
-cpg_callbacks_t cpg_callbacks = {
-	.cpg_deliver_fn =            cpg_deliver_callback,
-	.cpg_confchg_fn =            cpg_confchg_callback,
+cpg_callbacks_t corosync_cpg_callbacks = {
+	.cpg_deliver_fn =            corosync_cpg_deliver_callback,
+	.cpg_confchg_fn =            corosync_cpg_confchg_callback,
 };
 
 quorum_callbacks_t quorum_callbacks = {
@@ -205,7 +205,7 @@
 	return buf;
 }
 
-static void cpg_deliver_callback (cpg_handle_t handle,
+static void corosync_cpg_deliver_callback (cpg_handle_t handle,
 				  const struct cpg_name *groupName,
 				  uint32_t nodeid,
 				  uint32_t pid,
@@ -225,7 +225,7 @@
 					msg_len-COROSYNC_CSID_LEN, (char*)&nodeid);
 }
 
-static void cpg_confchg_callback(cpg_handle_t handle,
+static void corosync_cpg_confchg_callback(cpg_handle_t handle,
 				 const struct cpg_name *groupName,
 				 const struct cpg_address *member_list, size_t member_list_entries,
 				 const struct cpg_address *left_list, size_t left_list_entries,
@@ -294,7 +294,7 @@
 	node_hash = dm_hash_create(100);
 
 	err = cpg_initialize(&cpg_handle,
-			     &cpg_callbacks);
+			     &corosync_cpg_callbacks);
 	if (err != CS_OK) {
 		syslog(LOG_ERR, "Cannot initialise Corosync CPG service: %d",
 		       err);
--- LVM2/daemons/clvmd/clvmd-openais.c	2009/04/21 13:11:28	1.11
+++ LVM2/daemons/clvmd/clvmd-openais.c	2009/08/28 19:22:05	1.12
@@ -1,7 +1,7 @@
 /******************************************************************************
 *******************************************************************************
 **
-**  Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+**  Copyright (C) 2007-2009 Red Hat, Inc. All rights reserved.
 **
 *******************************************************************************
 ******************************************************************************/
@@ -41,7 +41,9 @@
 
 #include <openais/saAis.h>
 #include <openais/saLck.h>
-#include <openais/cpg.h>
+
+#include <corosync/corotypes.h>
+#include <corosync/cpg.h>
 
 #include "locking.h"
 #include "lvm-logging.h"
@@ -53,17 +55,18 @@
 /* Timeout value for several openais calls */
 #define TIMEOUT 10
 
-static void cpg_deliver_callback (cpg_handle_t handle,
-				  struct cpg_name *groupName,
+static void openais_cpg_deliver_callback (cpg_handle_t handle,
+				  const struct cpg_name *groupName,
 				  uint32_t nodeid,
 				  uint32_t pid,
 				  void *msg,
-				  int msg_len);
-static void cpg_confchg_callback(cpg_handle_t handle,
-				 struct cpg_name *groupName,
-				 struct cpg_address *member_list, int member_list_entries,
-				 struct cpg_address *left_list, int left_list_entries,
-				 struct cpg_address *joined_list, int joined_list_entries);
+				  size_t msg_len);
+static void openais_cpg_confchg_callback(cpg_handle_t handle,
+				 const struct cpg_name *groupName,
+				 const struct cpg_address *member_list, size_t member_list_entries,
+				 const struct cpg_address *left_list, size_t left_list_entries,
+				 const struct cpg_address *joined_list, size_t joined_list_entries);
+
 static void _cluster_closedown(void);
 
 /* Hash list of nodes in the cluster */
@@ -85,9 +88,9 @@
 static struct cpg_name cpg_group_name;
 
 /* Openais callback structs */
-cpg_callbacks_t cpg_callbacks = {
-	.cpg_deliver_fn =            cpg_deliver_callback,
-	.cpg_confchg_fn =            cpg_confchg_callback,
+cpg_callbacks_t openais_cpg_callbacks = {
+	.cpg_deliver_fn =            openais_cpg_deliver_callback,
+	.cpg_confchg_fn =            openais_cpg_confchg_callback,
 };
 
 struct node_info
@@ -230,12 +233,12 @@
 	return 0;
 }
 
-static void cpg_deliver_callback (cpg_handle_t handle,
-				  struct cpg_name *groupName,
+static void openais_cpg_deliver_callback (cpg_handle_t handle,
+				  const struct cpg_name *groupName,
 				  uint32_t nodeid,
 				  uint32_t pid,
 				  void *msg,
-				  int msg_len)
+				  size_t msg_len)
 {
 	int target_nodeid;
 
@@ -250,11 +253,11 @@
 					msg_len-OPENAIS_CSID_LEN, (char*)&nodeid);
 }
 
-static void cpg_confchg_callback(cpg_handle_t handle,
-				 struct cpg_name *groupName,
-				 struct cpg_address *member_list, int member_list_entries,
-				 struct cpg_address *left_list, int left_list_entries,
-				 struct cpg_address *joined_list, int joined_list_entries)
+static void openais_cpg_confchg_callback(cpg_handle_t handle,
+				 const struct cpg_name *groupName,
+				 const struct cpg_address *member_list, size_t member_list_entries,
+				 const struct cpg_address *left_list, size_t left_list_entries,
+				 const struct cpg_address *joined_list, size_t joined_list_entries)
 {
 	int i;
 	struct node_info *ninfo;
@@ -330,7 +333,7 @@
 	lock_hash = dm_hash_create(10);
 
 	err = cpg_initialize(&cpg_handle,
-			     &cpg_callbacks);
+			     &openais_cpg_callbacks);
 	if (err != SA_AIS_OK) {
 		syslog(LOG_ERR, "Cannot initialise OpenAIS CPG service: %d",
 		       err);
@@ -342,7 +345,7 @@
 					NULL,
 			      &ver);
 	if (err != SA_AIS_OK) {
-		cpg_initialize(&cpg_handle, &cpg_callbacks);
+		cpg_initialize(&cpg_handle, &openais_cpg_callbacks);
 		syslog(LOG_ERR, "Cannot initialise OpenAIS lock service: %d",
 		       err);
 		DEBUGLOG("Cannot initialise OpenAIS lock service: %d\n\n", err);
--- LVM2/lib/misc/configure.h.in	2009/07/31 11:49:53	1.10
+++ LVM2/lib/misc/configure.h.in	2009/08/28 19:22:05	1.11
@@ -45,6 +45,12 @@
 /* Define to 1 if canonicalize_file_name is available. */
 #undef HAVE_CANONICALIZE_FILE_NAME
 
+/* Define to 1 if you have the <ccs.h> header file. */
+#undef HAVE_CCS_H
+
+/* Define to 1 if you have the <corosync/confdb.h> header file. */
+#undef HAVE_COROSYNC_CONFDB_H
+
 /* Define to 1 if you have the <ctype.h> header file. */
 #undef HAVE_CTYPE_H
 
@@ -90,12 +96,21 @@
 /* Define to 1 if you have the <inttypes.h> header file. */
 #undef HAVE_INTTYPES_H
 
+/* Define to 1 if you have the <libcman.h> header file. */
+#undef HAVE_LIBCMAN_H
+
 /* Define to 1 if dynamic libraries are available. */
 #undef HAVE_LIBDL
 
+/* Define to 1 if you have the <libdlm.h> header file. */
+#undef HAVE_LIBDLM_H
+
 /* Define to 1 if you have the <libgen.h> header file. */
 #undef HAVE_LIBGEN_H
 
+/* Define to 1 if you have the <libgulm.h> header file. */
+#undef HAVE_LIBGULM_H
+
 /* Define to 1 if you have the <libintl.h> header file. */
 #undef HAVE_LIBINTL_H
 


