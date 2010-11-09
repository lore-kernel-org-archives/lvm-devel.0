From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Nov 2010 11:14:12 -0000
Subject: LVM2 configure
Message-ID: <20101109111412.12215.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-11-09 11:14:09

Modified files:
	.              : configure 

Log message:
	forgotten to regenerate last time configure.in was updated

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.141&r2=1.142

--- LVM2/configure	2010/08/23 13:44:31	1.141
+++ LVM2/configure	2010/11/09 11:14:06	1.142
@@ -662,6 +662,7 @@
 POOL
 PKGCONFIG
 REPLICATORS
+OCF
 MIRRORS
 LVM_RELEASE_DATE
 LVM_RELEASE
@@ -835,6 +836,7 @@
 with_replicators
 enable_readline
 enable_realtime
+enable_ocf
 with_clvmd
 with_clvmd_pidfile
 enable_cmirrord
@@ -1539,6 +1541,8 @@
                           device-mapper is missing from the kernel
   --disable-readline      disable readline support
   --enable-realtime       enable realtime clock support
+  --enable-ocf            enable Open Cluster Framework (OCF) compliant
+                          resource agents
   --enable-cmirrord       enable the cluster mirror log daemon
   --enable-debug          enable debugging
   --enable-profiling      gather gcov profiling data
@@ -7892,96 +7896,8 @@
 
 
 ################################################################################
-{ $as_echo "$as_me:$LINENO: checking for library containing floor" >&5
-$as_echo_n "checking for library containing floor... " >&6; }
-if test "${ac_cv_search_floor+set}" = set; then
-  $as_echo_n "(cached) " >&6
-else
-  ac_func_search_save_LIBS=$LIBS
-cat >conftest.$ac_ext <<_ACEOF
-/* confdefs.h.  */
-_ACEOF
-cat confdefs.h >>conftest.$ac_ext
-cat >>conftest.$ac_ext <<_ACEOF
-/* end confdefs.h.  */
 
-/* Override any GCC internal prototype to avoid an error.
-   Use char because int might match the return type of a GCC
-   builtin and then its argument prototype would still apply.  */
-#ifdef __cplusplus
-extern "C"
-#endif
-char floor ();
-int
-main ()
-{
-return floor ();
-  ;
-  return 0;
-}
-_ACEOF
-for ac_lib in '' m; do
-  if test -z "$ac_lib"; then
-    ac_res="none required"
-  else
-    ac_res=-l$ac_lib
-    LIBS="-l$ac_lib  $ac_func_search_save_LIBS"
-  fi
-  rm -f conftest.$ac_objext conftest$ac_exeext
-if { (ac_try="$ac_link"
-case "(($ac_try" in
-  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
-  *) ac_try_echo=$ac_try;;
-esac
-eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
-$as_echo "$ac_try_echo") >&5
-  (eval "$ac_link") 2>conftest.er1
-  ac_status=$?
-  grep -v '^ *+' conftest.er1 >conftest.err
-  rm -f conftest.er1
-  cat conftest.err >&5
-  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
-  (exit $ac_status); } && {
-	 test -z "$ac_c_werror_flag" ||
-	 test ! -s conftest.err
-       } && test -s conftest$ac_exeext && {
-	 test "$cross_compiling" = yes ||
-	 $as_test_x conftest$ac_exeext
-       }; then
-  ac_cv_search_floor=$ac_res
-else
-  $as_echo "$as_me: failed program was:" >&5
-sed 's/^/| /' conftest.$ac_ext >&5
-
-
-fi
-
-rm -rf conftest.dSYM
-rm -f core conftest.err conftest.$ac_objext conftest_ipa8_conftest.oo \
-      conftest$ac_exeext
-  if test "${ac_cv_search_floor+set}" = set; then
-  break
-fi
-done
-if test "${ac_cv_search_floor+set}" = set; then
-  :
-else
-  ac_cv_search_floor=no
-fi
-rm conftest.$ac_ext
-LIBS=$ac_func_search_save_LIBS
-fi
-{ $as_echo "$as_me:$LINENO: result: $ac_cv_search_floor" >&5
-$as_echo "$ac_cv_search_floor" >&6; }
-ac_res=$ac_cv_search_floor
-if test "$ac_res" != no; then
-  test "$ac_res" = "none required" || LIBS="$ac_res $LIBS"
 
-else
-  { { $as_echo "$as_me:$LINENO: error: bailing out" >&5
-$as_echo "$as_me: error: bailing out" >&2;}
-   { (exit 1); exit 1; }; }
-fi
 
 
 
@@ -8004,11 +7920,7 @@
 
 
 
-
-
-
-
-for ac_func in floor ftruncate gethostname getpagesize \
+for ac_func in ftruncate gethostname getpagesize \
   gettimeofday memset mkdir mkfifo rmdir munmap nl_langinfo setenv setlocale \
   strcasecmp strchr strcspn strspn strdup strncasecmp strerror strrchr \
   strstr strtol strtoul uname
@@ -11423,6 +11335,19 @@
 $as_echo "$REALTIME" >&6; }
 
 ################################################################################
+{ $as_echo "$as_me:$LINENO: checking whether to enable OCF resource agents" >&5
+$as_echo_n "checking whether to enable OCF resource agents... " >&6; }
+# Check whether --enable-ocf was given.
+if test "${enable_ocf+set}" = set; then
+  enableval=$enable_ocf; OCF=$enableval
+else
+  OCF=no
+fi
+
+{ $as_echo "$as_me:$LINENO: result: $OCF" >&5
+$as_echo "$OCF" >&6; }
+
+################################################################################
 pkg_config_init() {
 
 
@@ -18264,6 +18189,7 @@
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 


