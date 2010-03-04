From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Mar 2010 12:08:28 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in ./ ...
Message-ID: <20100304120828.19562.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-04 12:08:27

Modified files:
	.              : WHATS_NEW configure configure.in make.tmpl.in 
	daemons/dmeventd: Makefile.in 
	libdm          : Makefile.in 
	tools          : Makefile.in 

Log message:
	This patch add SELINUX_LIBS and STATIC_LIBS variables.
	
	For static builds dependency for SELinux libs is not handled by 'ar'.
	Till better solution is found, for static builds STATIC_LIBS is used.
	
	Patch updates SELinux detection to use 3rd & 4th parameter for Success/Fail.
	Also removes detection of pthread from this check as we know which
	version of libdevmapper we are going to link with lvm after merge.
	
	SELinux header check moved to the SELinux test code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1451&r2=1.1452
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.118&r2=1.119
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.128&r2=1.129
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.80&r2=1.81
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/Makefile.in.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.109&r2=1.110

--- LVM2/WHATS_NEW	2010/03/04 12:03:54	1.1451
+++ LVM2/WHATS_NEW	2010/03/04 12:08:26	1.1452
@@ -1,5 +1,7 @@
 Version 2.02.62 -
 ====================================
+  Update check for selinux libraries and link them only when needed.
+  Define and use internal makefile variable SELINUX_LIBS and STATIC_LIBS.
   Remove -rdynamic from static builds.
   Update check for pthread library and link it only when needed.
   Define and use internal makefile variable PTHREAD_LIBS.
--- LVM2/configure	2010/03/04 11:21:05	1.118
+++ LVM2/configure	2010/03/04 12:08:26	1.119
@@ -673,7 +673,6 @@
 JOBS
 INTL_PACKAGE
 INTL
-HAVE_SELINUX
 HAVE_REALTIME
 HAVE_LIBDL
 GROUP
@@ -12864,20 +12863,15 @@
 { $as_echo "$as_me:$LINENO: result: $ac_cv_lib_sepol_sepol_check_context" >&5
 $as_echo "$ac_cv_lib_sepol_sepol_check_context" >&6; }
 if test "x$ac_cv_lib_sepol_sepol_check_context" = x""yes; then
-  HAVE_SEPOL=yes
-else
-  HAVE_SEPOL=no
-fi
-
 
-	if test x$HAVE_SEPOL = xyes; then
 
 cat >>confdefs.h <<\_ACEOF
 #define HAVE_SEPOL 1
 _ACEOF
 
-		SELINUX_LIBS="-lsepol $SELINUX_LIBS"
-	fi
+		SELINUX_LIBS="-lsepol"
+fi
+
 
 	{ $as_echo "$as_me:$LINENO: checking for is_selinux_enabled in -lselinux" >&5
 $as_echo_n "checking for is_selinux_enabled in -lselinux... " >&6; }
@@ -12945,75 +12939,43 @@
 { $as_echo "$as_me:$LINENO: result: $ac_cv_lib_selinux_is_selinux_enabled" >&5
 $as_echo "$ac_cv_lib_selinux_is_selinux_enabled" >&6; }
 if test "x$ac_cv_lib_selinux_is_selinux_enabled" = x""yes; then
-  HAVE_SELINUX=yes
-else
-  HAVE_SELINUX=no
-fi
-
 
-	if test x$HAVE_SELINUX = xyes; then
 
-cat >>confdefs.h <<\_ACEOF
-#define HAVE_SELINUX 1
-_ACEOF
-
-		SELINUX_LIBS="-lselinux $SELINUX_LIBS"
-	else
-		{ $as_echo "$as_me:$LINENO: WARNING: Disabling selinux" >&5
-$as_echo "$as_me: WARNING: Disabling selinux" >&2;}
-	fi
-	LIBS="$SELINUX_LIBS $LIBS"
-
-	# With --enable-static_link and selinux enabled, linking
-	# fails on at least Debian unstable due to unsatisfied references
-	# to pthread_mutex_lock and _unlock.  See if we need -lpthread.
-	if test "$STATIC_LINK-$HAVE_SELINUX" = yes-yes; then
-		lvm_saved_libs=$LIBS
-		LIBS="$LIBS -static"
-		{ $as_echo "$as_me:$LINENO: checking for library containing pthread_mutex_lock" >&5
-$as_echo_n "checking for library containing pthread_mutex_lock... " >&6; }
-if test "${ac_cv_search_pthread_mutex_lock+set}" = set; then
+for ac_header in selinux/selinux.h
+do
+as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  { $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
+$as_echo_n "checking for $ac_header... " >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
   $as_echo_n "(cached) " >&6
+fi
+ac_res=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
 else
-  ac_func_search_save_LIBS=$LIBS
+  # Is the header compilable?
+{ $as_echo "$as_me:$LINENO: checking $ac_header usability" >&5
+$as_echo_n "checking $ac_header usability... " >&6; }
 cat >conftest.$ac_ext <<_ACEOF
 /* confdefs.h.  */
 _ACEOF
 cat confdefs.h >>conftest.$ac_ext
 cat >>conftest.$ac_ext <<_ACEOF
 /* end confdefs.h.  */
-
-/* Override any GCC internal prototype to avoid an error.
-   Use char because int might match the return type of a GCC
-   builtin and then its argument prototype would still apply.  */
-#ifdef __cplusplus
-extern "C"
-#endif
-char pthread_mutex_lock ();
-int
-main ()
-{
-return pthread_mutex_lock ();
-  ;
-  return 0;
-}
+$ac_includes_default
+#include <$ac_header>
 _ACEOF
-for ac_lib in '' pthread; do
-  if test -z "$ac_lib"; then
-    ac_res="none required"
-  else
-    ac_res=-l$ac_lib
-    LIBS="-l$ac_lib  $ac_func_search_save_LIBS"
-  fi
-  rm -f conftest.$ac_objext conftest$ac_exeext
-if { (ac_try="$ac_link"
+rm -f conftest.$ac_objext
+if { (ac_try="$ac_compile"
 case "(($ac_try" in
   *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
   *) ac_try_echo=$ac_try;;
 esac
 eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
 $as_echo "$ac_try_echo") >&5
-  (eval "$ac_link") 2>conftest.er1
+  (eval "$ac_compile") 2>conftest.er1
   ac_status=$?
   grep -v '^ *+' conftest.er1 >conftest.err
   rm -f conftest.er1
@@ -13022,44 +12984,125 @@
   (exit $ac_status); } && {
 	 test -z "$ac_c_werror_flag" ||
 	 test ! -s conftest.err
-       } && test -s conftest$ac_exeext && {
-	 test "$cross_compiling" = yes ||
-	 $as_test_x conftest$ac_exeext
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
        }; then
-  ac_cv_search_pthread_mutex_lock=$ac_res
+  ac_header_preproc=yes
 else
   $as_echo "$as_me: failed program was:" >&5
 sed 's/^/| /' conftest.$ac_ext >&5
 
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
 
+    ;;
+esac
+{ $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
+$as_echo_n "checking for $ac_header... " >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  $as_echo_n "(cached) " >&6
+else
+  eval "$as_ac_Header=\$ac_header_preproc"
 fi
+ac_res=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
 
-rm -rf conftest.dSYM
-rm -f core conftest.err conftest.$ac_objext conftest_ipa8_conftest.oo \
-      conftest$ac_exeext
-  if test "${ac_cv_search_pthread_mutex_lock+set}" = set; then
-  break
 fi
-done
-if test "${ac_cv_search_pthread_mutex_lock+set}" = set; then
-  :
+as_val=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+   if test "x$as_val" = x""yes; then
+  cat >>confdefs.h <<_ACEOF
+#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
+_ACEOF
+
 else
-  ac_cv_search_pthread_mutex_lock=no
-fi
-rm conftest.$ac_ext
-LIBS=$ac_func_search_save_LIBS
+  hard_bailout
 fi
-{ $as_echo "$as_me:$LINENO: result: $ac_cv_search_pthread_mutex_lock" >&5
-$as_echo "$ac_cv_search_pthread_mutex_lock" >&6; }
-ac_res=$ac_cv_search_pthread_mutex_lock
-if test "$ac_res" != no; then
-  test "$ac_res" = "none required" || LIBS="$ac_res $LIBS"
-  test "$ac_cv_search_pthread_mutex_lock" = "none required" ||
-				LIB_PTHREAD=-lpthread
+
+done
+
+
+cat >>confdefs.h <<\_ACEOF
+#define HAVE_SELINUX 1
+_ACEOF
+
+		SELINUX_LIBS="-lselinux $SELINUX_LIBS"
+		HAVE_SELINUX=yes
+else
+
+		{ $as_echo "$as_me:$LINENO: WARNING: Disabling selinux" >&5
+$as_echo "$as_me: WARNING: Disabling selinux" >&2;}
+		SELINUX_LIBS=
+		HAVE_SELINUX=no
 fi
 
-		LIBS=$lvm_saved_libs
-	fi
 fi
 
 ################################################################################
@@ -15140,159 +15183,6 @@
 
 fi
 
-if test x$HAVE_SELINUX = xyes; then
-
-for ac_header in selinux/selinux.h
-do
-as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
-if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
-  { $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
-$as_echo_n "checking for $ac_header... " >&6; }
-if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
-  $as_echo_n "(cached) " >&6
-fi
-ac_res=`eval 'as_val=${'$as_ac_Header'}
-		 $as_echo "$as_val"'`
-	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
-$as_echo "$ac_res" >&6; }
-else
-  # Is the header compilable?
-{ $as_echo "$as_me:$LINENO: checking $ac_header usability" >&5
-$as_echo_n "checking $ac_header usability... " >&6; }
-cat >conftest.$ac_ext <<_ACEOF
-/* confdefs.h.  */
-_ACEOF
-cat confdefs.h >>conftest.$ac_ext
-cat >>conftest.$ac_ext <<_ACEOF
-/* end confdefs.h.  */
-$ac_includes_default
-#include <$ac_header>
-_ACEOF
-rm -f conftest.$ac_objext
-if { (ac_try="$ac_compile"
-case "(($ac_try" in
-  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
-  *) ac_try_echo=$ac_try;;
-esac
-eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
-$as_echo "$ac_try_echo") >&5
-  (eval "$ac_compile") 2>conftest.er1
-  ac_status=$?
-  grep -v '^ *+' conftest.er1 >conftest.err
-  rm -f conftest.er1
-  cat conftest.err >&5
-  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
-  (exit $ac_status); } && {
-	 test -z "$ac_c_werror_flag" ||
-	 test ! -s conftest.err
-       } && test -s conftest.$ac_objext; then
-  ac_header_compiler=yes
-else
-  $as_echo "$as_me: failed program was:" >&5
-sed 's/^/| /' conftest.$ac_ext >&5
-
-	ac_header_compiler=no
-fi
-
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
-{ $as_echo "$as_me:$LINENO: result: $ac_header_compiler" >&5
-$as_echo "$ac_header_compiler" >&6; }
-
-# Is the header present?
-{ $as_echo "$as_me:$LINENO: checking $ac_header presence" >&5
-$as_echo_n "checking $ac_header presence... " >&6; }
-cat >conftest.$ac_ext <<_ACEOF
-/* confdefs.h.  */
-_ACEOF
-cat confdefs.h >>conftest.$ac_ext
-cat >>conftest.$ac_ext <<_ACEOF
-/* end confdefs.h.  */
-#include <$ac_header>
-_ACEOF
-if { (ac_try="$ac_cpp conftest.$ac_ext"
-case "(($ac_try" in
-  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
-  *) ac_try_echo=$ac_try;;
-esac
-eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
-$as_echo "$ac_try_echo") >&5
-  (eval "$ac_cpp conftest.$ac_ext") 2>conftest.er1
-  ac_status=$?
-  grep -v '^ *+' conftest.er1 >conftest.err
-  rm -f conftest.er1
-  cat conftest.err >&5
-  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
-  (exit $ac_status); } >/dev/null && {
-	 test -z "$ac_c_preproc_warn_flag$ac_c_werror_flag" ||
-	 test ! -s conftest.err
-       }; then
-  ac_header_preproc=yes
-else
-  $as_echo "$as_me: failed program was:" >&5
-sed 's/^/| /' conftest.$ac_ext >&5
-
-  ac_header_preproc=no
-fi
-
-rm -f conftest.err conftest.$ac_ext
-{ $as_echo "$as_me:$LINENO: result: $ac_header_preproc" >&5
-$as_echo "$ac_header_preproc" >&6; }
-
-# So?  What about this header?
-case $ac_header_compiler:$ac_header_preproc:$ac_c_preproc_warn_flag in
-  yes:no: )
-    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&5
-$as_echo "$as_me: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&2;}
-    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the compiler's result" >&5
-$as_echo "$as_me: WARNING: $ac_header: proceeding with the compiler's result" >&2;}
-    ac_header_preproc=yes
-    ;;
-  no:yes:* )
-    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: present but cannot be compiled" >&5
-$as_echo "$as_me: WARNING: $ac_header: present but cannot be compiled" >&2;}
-    { $as_echo "$as_me:$LINENO: WARNING: $ac_header:     check for missing prerequisite headers?" >&5
-$as_echo "$as_me: WARNING: $ac_header:     check for missing prerequisite headers?" >&2;}
-    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: see the Autoconf documentation" >&5
-$as_echo "$as_me: WARNING: $ac_header: see the Autoconf documentation" >&2;}
-    { $as_echo "$as_me:$LINENO: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&5
-$as_echo "$as_me: WARNING: $ac_header:     section \"Present But Cannot Be Compiled\"" >&2;}
-    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the preprocessor's result" >&5
-$as_echo "$as_me: WARNING: $ac_header: proceeding with the preprocessor's result" >&2;}
-    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: in the future, the compiler will take precedence" >&5
-$as_echo "$as_me: WARNING: $ac_header: in the future, the compiler will take precedence" >&2;}
-
-    ;;
-esac
-{ $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
-$as_echo_n "checking for $ac_header... " >&6; }
-if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
-  $as_echo_n "(cached) " >&6
-else
-  eval "$as_ac_Header=\$ac_header_preproc"
-fi
-ac_res=`eval 'as_val=${'$as_ac_Header'}
-		 $as_echo "$as_val"'`
-	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
-$as_echo "$ac_res" >&6; }
-
-fi
-as_val=`eval 'as_val=${'$as_ac_Header'}
-		 $as_echo "$as_val"'`
-   if test "x$as_val" = x""yes; then
-  cat >>confdefs.h <<_ACEOF
-#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
-_ACEOF
-
-else
-  { { $as_echo "$as_me:$LINENO: error: bailing out" >&5
-$as_echo "$as_me: error: bailing out" >&2;}
-   { (exit 1); exit 1; }; }
-fi
-
-done
-
-fi
-
 if test x$UDEV_SYNC = xyes; then
 
 
@@ -15671,7 +15561,6 @@
 
 
 
-
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
 
--- LVM2/configure.in	2010/03/04 11:21:05	1.128
+++ LVM2/configure.in	2010/03/04 12:08:27	1.129
@@ -824,35 +824,18 @@
 ################################################################################
 dnl -- Check for selinux
 if test x$SELINUX = xyes; then
-	AC_CHECK_LIB(sepol, sepol_check_context, HAVE_SEPOL=yes, HAVE_SEPOL=no)
+	AC_CHECK_LIB([sepol], [sepol_check_context], [
+		AC_DEFINE([HAVE_SEPOL], 1, [Define to 1 if sepol_check_context is available.])
+		SELINUX_LIBS="-lsepol"])
 
-	if test x$HAVE_SEPOL = xyes; then
-		AC_DEFINE([HAVE_SEPOL], 1,
-		  [Define to 1 if sepol_check_context is available.])
-		SELINUX_LIBS="-lsepol $SELINUX_LIBS"
-	fi
-
-	AC_CHECK_LIB(selinux, is_selinux_enabled, HAVE_SELINUX=yes, HAVE_SELINUX=no)
-
-	if test x$HAVE_SELINUX = xyes; then
+	AC_CHECK_LIB([selinux], [is_selinux_enabled], [
+		AC_CHECK_HEADERS([selinux/selinux.h],, hard_bailout)
 		AC_DEFINE([HAVE_SELINUX], 1, [Define to 1 to include support for selinux.])
 		SELINUX_LIBS="-lselinux $SELINUX_LIBS"
-	else
+		HAVE_SELINUX=yes ], [
 		AC_MSG_WARN(Disabling selinux)
-	fi
-	LIBS="$SELINUX_LIBS $LIBS"
-
-	# With --enable-static_link and selinux enabled, linking
-	# fails on at least Debian unstable due to unsatisfied references
-	# to pthread_mutex_lock and _unlock.  See if we need -lpthread.
-	if test "$STATIC_LINK-$HAVE_SELINUX" = yes-yes; then
-		lvm_saved_libs=$LIBS
-		LIBS="$LIBS -static"
-		AC_SEARCH_LIBS([pthread_mutex_lock], [pthread],
-		  [test "$ac_cv_search_pthread_mutex_lock" = "none required" ||
-				LIB_PTHREAD=-lpthread])
-		LIBS=$lvm_saved_libs
-	fi
+		SELINUX_LIBS=
+		HAVE_SELINUX=no ])
 fi
 
 ################################################################################
@@ -997,10 +980,6 @@
 	AC_CHECK_HEADERS(libintl.h,,AC_MSG_ERROR(bailing out))
 fi
 
-if test x$HAVE_SELINUX = xyes; then
-	AC_CHECK_HEADERS(selinux/selinux.h,,AC_MSG_ERROR(bailing out))
-fi
-
 if test x$UDEV_SYNC = xyes; then
 	AC_CHECK_HEADERS(sys/ipc.h sys/sem.h,,AC_MSG_ERROR(bailing out))
 fi
@@ -1109,7 +1088,6 @@
 AC_SUBST(GULM_LIBS)
 AC_SUBST(HAVE_LIBDL)
 AC_SUBST(HAVE_REALTIME)
-AC_SUBST(HAVE_SELINUX)
 AC_SUBST(INTL)
 AC_SUBST(INTL_PACKAGE)
 AC_SUBST(JOBS)
--- LVM2/make.tmpl.in	2010/03/04 11:21:05	1.80
+++ LVM2/make.tmpl.in	2010/03/04 12:08:27	1.81
@@ -30,6 +30,8 @@
 CFLOW_CMD = @CFLOW_CMD@
 
 LIBS = @LIBS@
+# Extra libraries always linked with static binaries
+STATIC_LIBS = $(SELINUX_LIBS)
 DEFS += @DEFS@
 CFLAGS += @CFLAGS@
 CLDFLAGS += @CLDFLAGS@
@@ -39,6 +41,7 @@
 LVMINTERNAL_LIBS = -llvm-internal
 PTHREAD_LIBS = @PTHREAD_LIBS@
 READLINE_LIBS = @READLINE_LIBS@
+SELINUX_LIBS = @SELINUX_LIBS@
 
 # Setup directory variables
 prefix = @prefix@
--- LVM2/daemons/dmeventd/Makefile.in	2010/03/04 12:03:54	1.34
+++ LVM2/daemons/dmeventd/Makefile.in	2010/03/04 12:08:27	1.35
@@ -66,7 +66,7 @@
 
 dmeventd.static: $(LIB_STATIC) dmeventd.o $(interfacebuilddir)/libdevmapper.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -static -L. -L$(interfacebuilddir) -o $@ \
-	dmeventd.o $(LVMLIBS) $(LIBS)
+	dmeventd.o $(LVMLIBS) $(STATIC_LIBS) $(LIBS)
 
 ifeq ("@PKGCONFIG@", "yes")
   INSTALL_LIB_TARGETS += install_pkgconfig
--- LVM2/libdm/Makefile.in	2010/03/04 09:56:56	1.48
+++ LVM2/libdm/Makefile.in	2010/03/04 12:08:27	1.49
@@ -52,6 +52,8 @@
 DEFS += -DDM_DEVICE_UID=@DM_DEVICE_UID@ -DDM_DEVICE_GID=@DM_DEVICE_GID@ \
 	-DDM_DEVICE_MODE=@DM_DEVICE_MODE@
 
+LIBS += $(SELINUX_LIBS)
+
 device-mapper: all
 
 .PHONY: install_dynamic install_static install_include \
--- LVM2/tools/Makefile.in	2010/03/04 12:03:54	1.109
+++ LVM2/tools/Makefile.in	2010/03/04 12:08:27	1.110
@@ -115,7 +115,7 @@
 
 dmsetup.static: dmsetup.o $(interfacebuilddir)/libdevmapper.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) \
-	      -o $@ dmsetup.o -ldevmapper $(LIBS)
+	      -o $@ dmsetup.o -ldevmapper $(STATIC_LIBS) $(LIBS)
 
 all: device-mapper
 
@@ -125,7 +125,7 @@
 
 lvm.static: $(OBJECTS) lvm-static.o $(top_builddir)/lib/liblvm-internal.a  $(interfacebuilddir)/libdevmapper.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) -o $@ \
-	      $(OBJECTS) lvm-static.o $(LVMLIBS) $(LIBS)
+	      $(OBJECTS) lvm-static.o $(LVMLIBS) $(STATIC_LIBS) $(LIBS)
 
 liblvm2cmd.a: $(top_builddir)/lib/liblvm-internal.a $(OBJECTS) lvmcmdlib.o lvm2cmd.o
 	cat $(top_builddir)/lib/liblvm-internal.a > $@


