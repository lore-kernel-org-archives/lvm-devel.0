From: agk@sourceware.org <agk@sourceware.org>
Date: 5 Jul 2010 22:23:20 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in li ...
Message-ID: <20100705222320.8217.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-05 22:23:15

Modified files:
	.              : WHATS_NEW configure configure.in 
	lib/metadata   : metadata.c 
	lib/misc       : configure.h.in 

Log message:
	Randomly select which mdas to use or ignore.
	Add some missing standard configure.in checks.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1651&r2=1.1652
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.132&r2=1.133
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.143&r2=1.144
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.378&r2=1.379
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/WHATS_NEW	2010/07/02 21:16:50	1.1651
+++ LVM2/WHATS_NEW	2010/07/05 22:23:15	1.1652
@@ -1,5 +1,7 @@
 Version 2.02.70 - 
 ================================
+  Randomly select which mdas to use or ignore.
+  Add some missing standard configure.in checks.
   Add printf format attributes to yes_no_prompt and fix a caller.
   Always pass unsuspended dm devices through persistent filter to other filters.
   Move test for suspended dm devices ahead of other filters.
--- LVM2/configure	2010/06/07 14:31:59	1.132
+++ LVM2/configure	2010/07/05 22:23:15	1.133
@@ -736,8 +736,6 @@
 CCS_CFLAGS
 PKGCONFIGINIT_LIBS
 PKGCONFIGINIT_CFLAGS
-PKG_CONFIG_LIBDIR
-PKG_CONFIG_PATH
 PKG_CONFIG
 POW_LIB
 LIBOBJS
@@ -877,8 +875,6 @@
 CPPFLAGS
 CPP
 PKG_CONFIG
-PKG_CONFIG_PATH
-PKG_CONFIG_LIBDIR
 PKGCONFIGINIT_CFLAGS
 PKGCONFIGINIT_LIBS
 CCS_CFLAGS
@@ -1607,10 +1603,6 @@
               you have headers in a nonstandard directory <include dir>
   CPP         C preprocessor
   PKG_CONFIG  path to pkg-config utility
-  PKG_CONFIG_PATH
-              directories to add to pkg-config's search path
-  PKG_CONFIG_LIBDIR
-              path overriding pkg-config's built-in search path
   PKGCONFIGINIT_CFLAGS
               C compiler flags for PKGCONFIGINIT, overriding pkg-config
   PKGCONFIGINIT_LIBS
@@ -4531,77 +4523,23 @@
 
 fi
 
-{ $as_echo "$as_me:$LINENO: checking for sys/wait.h that is POSIX.1 compatible" >&5
-$as_echo_n "checking for sys/wait.h that is POSIX.1 compatible... " >&6; }
-if test "${ac_cv_header_sys_wait_h+set}" = set; then
-  $as_echo_n "(cached) " >&6
-else
-  cat >conftest.$ac_ext <<_ACEOF
-/* confdefs.h.  */
-_ACEOF
-cat confdefs.h >>conftest.$ac_ext
-cat >>conftest.$ac_ext <<_ACEOF
-/* end confdefs.h.  */
-#include <sys/types.h>
-#include <sys/wait.h>
-#ifndef WEXITSTATUS
-# define WEXITSTATUS(stat_val) ((unsigned int) (stat_val) >> 8)
-#endif
-#ifndef WIFEXITED
-# define WIFEXITED(stat_val) (((stat_val) & 255) == 0)
-#endif
+# On IRIX 5.3, sys/types and inttypes.h are conflicting.
 
-int
-main ()
-{
-  int s;
-  wait (&s);
-  s = WIFEXITED (s) ? WEXITSTATUS (s) : 1;
-  ;
-  return 0;
-}
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
-  ac_cv_header_sys_wait_h=yes
-else
-  $as_echo "$as_me: failed program was:" >&5
-sed 's/^/| /' conftest.$ac_ext >&5
 
-	ac_cv_header_sys_wait_h=no
-fi
 
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
-fi
-{ $as_echo "$as_me:$LINENO: result: $ac_cv_header_sys_wait_h" >&5
-$as_echo "$ac_cv_header_sys_wait_h" >&6; }
-if test $ac_cv_header_sys_wait_h = yes; then
 
-cat >>confdefs.h <<\_ACEOF
-#define HAVE_SYS_WAIT_H 1
-_ACEOF
 
-fi
 
-{ $as_echo "$as_me:$LINENO: checking whether time.h and sys/time.h may both be included" >&5
-$as_echo_n "checking whether time.h and sys/time.h may both be included... " >&6; }
-if test "${ac_cv_header_time+set}" = set; then
+
+
+
+for ac_header in sys/types.h sys/stat.h stdlib.h string.h memory.h strings.h \
+		  inttypes.h stdint.h unistd.h
+do
+as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
+{ $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
+$as_echo_n "checking for $ac_header... " >&6; }
+if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
   $as_echo_n "(cached) " >&6
 else
   cat >conftest.$ac_ext <<_ACEOF
@@ -4610,18 +4548,9 @@
 cat confdefs.h >>conftest.$ac_ext
 cat >>conftest.$ac_ext <<_ACEOF
 /* end confdefs.h.  */
-#include <sys/types.h>
-#include <sys/time.h>
-#include <time.h>
+$ac_includes_default
 
-int
-main ()
-{
-if ((struct tm *) 0)
-return 0;
-  ;
-  return 0;
-}
+#include <$ac_header>
 _ACEOF
 rm -f conftest.$ac_objext
 if { (ac_try="$ac_compile"
@@ -4641,44 +4570,35 @@
 	 test -z "$ac_c_werror_flag" ||
 	 test ! -s conftest.err
        } && test -s conftest.$ac_objext; then
-  ac_cv_header_time=yes
+  eval "$as_ac_Header=yes"
 else
   $as_echo "$as_me: failed program was:" >&5
 sed 's/^/| /' conftest.$ac_ext >&5
 
-	ac_cv_header_time=no
+	eval "$as_ac_Header=no"
 fi
 
 rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
 fi
-{ $as_echo "$as_me:$LINENO: result: $ac_cv_header_time" >&5
-$as_echo "$ac_cv_header_time" >&6; }
-if test $ac_cv_header_time = yes; then
-
-cat >>confdefs.h <<\_ACEOF
-#define TIME_WITH_SYS_TIME 1
+ac_res=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+as_val=`eval 'as_val=${'$as_ac_Header'}
+		 $as_echo "$as_val"'`
+   if test "x$as_val" = x""yes; then
+  cat >>confdefs.h <<_ACEOF
+#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
 _ACEOF
 
 fi
 
-
-# On IRIX 5.3, sys/types and inttypes.h are conflicting.
-
-
-
-
-
-
-
+done
 
 
-for ac_header in sys/types.h sys/stat.h stdlib.h string.h memory.h strings.h \
-		  inttypes.h stdint.h unistd.h
-do
-as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
-{ $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
-$as_echo_n "checking for $ac_header... " >&6; }
-if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+{ $as_echo "$as_me:$LINENO: checking whether sys/types.h defines makedev" >&5
+$as_echo_n "checking whether sys/types.h defines makedev... " >&6; }
+if test "${ac_cv_header_sys_types_h_makedev+set}" = set; then
   $as_echo_n "(cached) " >&6
 else
   cat >conftest.$ac_ext <<_ACEOF
@@ -4687,19 +4607,24 @@
 cat confdefs.h >>conftest.$ac_ext
 cat >>conftest.$ac_ext <<_ACEOF
 /* end confdefs.h.  */
-$ac_includes_default
-
-#include <$ac_header>
+#include <sys/types.h>
+int
+main ()
+{
+return makedev(0, 0);
+  ;
+  return 0;
+}
 _ACEOF
-rm -f conftest.$ac_objext
-if { (ac_try="$ac_compile"
+rm -f conftest.$ac_objext conftest$ac_exeext
+if { (ac_try="$ac_link"
 case "(($ac_try" in
   *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
   *) ac_try_echo=$ac_try;;
 esac
 eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
 $as_echo "$ac_try_echo") >&5
-  (eval "$ac_compile") 2>conftest.er1
+  (eval "$ac_link") 2>conftest.er1
   ac_status=$?
   grep -v '^ *+' conftest.er1 >conftest.err
   rm -f conftest.er1
@@ -4708,64 +4633,39 @@
   (exit $ac_status); } && {
 	 test -z "$ac_c_werror_flag" ||
 	 test ! -s conftest.err
-       } && test -s conftest.$ac_objext; then
-  eval "$as_ac_Header=yes"
+       } && test -s conftest$ac_exeext && {
+	 test "$cross_compiling" = yes ||
+	 $as_test_x conftest$ac_exeext
+       }; then
+  ac_cv_header_sys_types_h_makedev=yes
 else
   $as_echo "$as_me: failed program was:" >&5
 sed 's/^/| /' conftest.$ac_ext >&5
 
-	eval "$as_ac_Header=no"
+	ac_cv_header_sys_types_h_makedev=no
 fi
 
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
-fi
-ac_res=`eval 'as_val=${'$as_ac_Header'}
-		 $as_echo "$as_val"'`
-	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
-$as_echo "$ac_res" >&6; }
-as_val=`eval 'as_val=${'$as_ac_Header'}
-		 $as_echo "$as_val"'`
-   if test "x$as_val" = x""yes; then
-  cat >>confdefs.h <<_ACEOF
-#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
-_ACEOF
+rm -rf conftest.dSYM
+rm -f core conftest.err conftest.$ac_objext conftest_ipa8_conftest.oo \
+      conftest$ac_exeext conftest.$ac_ext
 
 fi
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_header_sys_types_h_makedev" >&5
+$as_echo "$ac_cv_header_sys_types_h_makedev" >&6; }
 
-done
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-for ac_header in locale.h stddef.h syslog.h sys/file.h sys/time.h assert.h \
-  libgen.h signal.h sys/mman.h sys/resource.h sys/utsname.h sys/wait.h time.h
-do
-as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
-if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
-  { $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
-$as_echo_n "checking for $ac_header... " >&6; }
-if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+if test $ac_cv_header_sys_types_h_makedev = no; then
+if test "${ac_cv_header_sys_mkdev_h+set}" = set; then
+  { $as_echo "$as_me:$LINENO: checking for sys/mkdev.h" >&5
+$as_echo_n "checking for sys/mkdev.h... " >&6; }
+if test "${ac_cv_header_sys_mkdev_h+set}" = set; then
   $as_echo_n "(cached) " >&6
 fi
-ac_res=`eval 'as_val=${'$as_ac_Header'}
-		 $as_echo "$as_val"'`
-	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
-$as_echo "$ac_res" >&6; }
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_header_sys_mkdev_h" >&5
+$as_echo "$ac_cv_header_sys_mkdev_h" >&6; }
 else
   # Is the header compilable?
-{ $as_echo "$as_me:$LINENO: checking $ac_header usability" >&5
-$as_echo_n "checking $ac_header usability... " >&6; }
+{ $as_echo "$as_me:$LINENO: checking sys/mkdev.h usability" >&5
+$as_echo_n "checking sys/mkdev.h usability... " >&6; }
 cat >conftest.$ac_ext <<_ACEOF
 /* confdefs.h.  */
 _ACEOF
@@ -4773,7 +4673,7 @@
 cat >>conftest.$ac_ext <<_ACEOF
 /* end confdefs.h.  */
 $ac_includes_default
-#include <$ac_header>
+#include <sys/mkdev.h>
 _ACEOF
 rm -f conftest.$ac_objext
 if { (ac_try="$ac_compile"
@@ -4806,15 +4706,15 @@
 $as_echo "$ac_header_compiler" >&6; }
 
 # Is the header present?
-{ $as_echo "$as_me:$LINENO: checking $ac_header presence" >&5
-$as_echo_n "checking $ac_header presence... " >&6; }
+{ $as_echo "$as_me:$LINENO: checking sys/mkdev.h presence" >&5
+$as_echo_n "checking sys/mkdev.h presence... " >&6; }
 cat >conftest.$ac_ext <<_ACEOF
 /* confdefs.h.  */
 _ACEOF
 cat confdefs.h >>conftest.$ac_ext
 cat >>conftest.$ac_ext <<_ACEOF
 /* end confdefs.h.  */
-#include <$ac_header>
+#include <sys/mkdev.h>
 _ACEOF
 if { (ac_try="$ac_cpp conftest.$ac_ext"
 case "(($ac_try" in
@@ -4848,79 +4748,62 @@
 # So?  What about this header?
 case $ac_header_compiler:$ac_header_preproc:$ac_c_preproc_warn_flag in
   yes:no: )
-    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&5
-$as_echo "$as_me: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&2;}
-    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the compiler's result" >&5
-$as_echo "$as_me: WARNING: $ac_header: proceeding with the compiler's result" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: sys/mkdev.h: accepted by the compiler, rejected by the preprocessor!" >&5
+$as_echo "$as_me: WARNING: sys/mkdev.h: accepted by the compiler, rejected by the preprocessor!" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: sys/mkdev.h: proceeding with the compiler's result" >&5
+$as_echo "$as_me: WARNING: sys/mkdev.h: proceeding with the compiler's result" >&2;}
     ac_header_preproc=yes
     ;;
   no:yes:* )
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
+    { $as_echo "$as_me:$LINENO: WARNING: sys/mkdev.h: present but cannot be compiled" >&5
+$as_echo "$as_me: WARNING: sys/mkdev.h: present but cannot be compiled" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: sys/mkdev.h:     check for missing prerequisite headers?" >&5
+$as_echo "$as_me: WARNING: sys/mkdev.h:     check for missing prerequisite headers?" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: sys/mkdev.h: see the Autoconf documentation" >&5
+$as_echo "$as_me: WARNING: sys/mkdev.h: see the Autoconf documentation" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: sys/mkdev.h:     section \"Present But Cannot Be Compiled\"" >&5
+$as_echo "$as_me: WARNING: sys/mkdev.h:     section \"Present But Cannot Be Compiled\"" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: sys/mkdev.h: proceeding with the preprocessor's result" >&5
+$as_echo "$as_me: WARNING: sys/mkdev.h: proceeding with the preprocessor's result" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: sys/mkdev.h: in the future, the compiler will take precedence" >&5
+$as_echo "$as_me: WARNING: sys/mkdev.h: in the future, the compiler will take precedence" >&2;}
 
     ;;
 esac
-{ $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
-$as_echo_n "checking for $ac_header... " >&6; }
-if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+{ $as_echo "$as_me:$LINENO: checking for sys/mkdev.h" >&5
+$as_echo_n "checking for sys/mkdev.h... " >&6; }
+if test "${ac_cv_header_sys_mkdev_h+set}" = set; then
   $as_echo_n "(cached) " >&6
 else
-  eval "$as_ac_Header=\$ac_header_preproc"
+  ac_cv_header_sys_mkdev_h=$ac_header_preproc
 fi
-ac_res=`eval 'as_val=${'$as_ac_Header'}
-		 $as_echo "$as_val"'`
-	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
-$as_echo "$ac_res" >&6; }
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_header_sys_mkdev_h" >&5
+$as_echo "$ac_cv_header_sys_mkdev_h" >&6; }
 
 fi
-as_val=`eval 'as_val=${'$as_ac_Header'}
-		 $as_echo "$as_val"'`
-   if test "x$as_val" = x""yes; then
-  cat >>confdefs.h <<_ACEOF
-#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
+if test "x$ac_cv_header_sys_mkdev_h" = x""yes; then
+
+cat >>confdefs.h <<\_ACEOF
+#define MAJOR_IN_MKDEV 1
 _ACEOF
 
-else
-  { { $as_echo "$as_me:$LINENO: error: bailing out" >&5
-$as_echo "$as_me: error: bailing out" >&2;}
-   { (exit 1); exit 1; }; }
 fi
 
-done
-
-
-case "$host_os" in
-	linux*)
-
 
 
-for ac_header in asm/byteorder.h linux/fs.h malloc.h
-do
-as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
-if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
-  { $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
-$as_echo_n "checking for $ac_header... " >&6; }
-if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  if test $ac_cv_header_sys_mkdev_h = no; then
+    if test "${ac_cv_header_sys_sysmacros_h+set}" = set; then
+  { $as_echo "$as_me:$LINENO: checking for sys/sysmacros.h" >&5
+$as_echo_n "checking for sys/sysmacros.h... " >&6; }
+if test "${ac_cv_header_sys_sysmacros_h+set}" = set; then
   $as_echo_n "(cached) " >&6
 fi
-ac_res=`eval 'as_val=${'$as_ac_Header'}
-		 $as_echo "$as_val"'`
-	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
-$as_echo "$ac_res" >&6; }
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_header_sys_sysmacros_h" >&5
+$as_echo "$ac_cv_header_sys_sysmacros_h" >&6; }
 else
   # Is the header compilable?
-{ $as_echo "$as_me:$LINENO: checking $ac_header usability" >&5
-$as_echo_n "checking $ac_header usability... " >&6; }
+{ $as_echo "$as_me:$LINENO: checking sys/sysmacros.h usability" >&5
+$as_echo_n "checking sys/sysmacros.h usability... " >&6; }
 cat >conftest.$ac_ext <<_ACEOF
 /* confdefs.h.  */
 _ACEOF
@@ -4928,7 +4811,7 @@
 cat >>conftest.$ac_ext <<_ACEOF
 /* end confdefs.h.  */
 $ac_includes_default
-#include <$ac_header>
+#include <sys/sysmacros.h>
 _ACEOF
 rm -f conftest.$ac_objext
 if { (ac_try="$ac_compile"
@@ -4961,15 +4844,15 @@
 $as_echo "$ac_header_compiler" >&6; }
 
 # Is the header present?
-{ $as_echo "$as_me:$LINENO: checking $ac_header presence" >&5
-$as_echo_n "checking $ac_header presence... " >&6; }
+{ $as_echo "$as_me:$LINENO: checking sys/sysmacros.h presence" >&5
+$as_echo_n "checking sys/sysmacros.h presence... " >&6; }
 cat >conftest.$ac_ext <<_ACEOF
 /* confdefs.h.  */
 _ACEOF
 cat confdefs.h >>conftest.$ac_ext
 cat >>conftest.$ac_ext <<_ACEOF
 /* end confdefs.h.  */
-#include <$ac_header>
+#include <sys/sysmacros.h>
 _ACEOF
 if { (ac_try="$ac_cpp conftest.$ac_ext"
 case "(($ac_try" in
@@ -5003,84 +4886,74 @@
 # So?  What about this header?
 case $ac_header_compiler:$ac_header_preproc:$ac_c_preproc_warn_flag in
   yes:no: )
-    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&5
-$as_echo "$as_me: WARNING: $ac_header: accepted by the compiler, rejected by the preprocessor!" >&2;}
-    { $as_echo "$as_me:$LINENO: WARNING: $ac_header: proceeding with the compiler's result" >&5
-$as_echo "$as_me: WARNING: $ac_header: proceeding with the compiler's result" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: sys/sysmacros.h: accepted by the compiler, rejected by the preprocessor!" >&5
+$as_echo "$as_me: WARNING: sys/sysmacros.h: accepted by the compiler, rejected by the preprocessor!" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: sys/sysmacros.h: proceeding with the compiler's result" >&5
+$as_echo "$as_me: WARNING: sys/sysmacros.h: proceeding with the compiler's result" >&2;}
     ac_header_preproc=yes
     ;;
   no:yes:* )
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
+    { $as_echo "$as_me:$LINENO: WARNING: sys/sysmacros.h: present but cannot be compiled" >&5
+$as_echo "$as_me: WARNING: sys/sysmacros.h: present but cannot be compiled" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: sys/sysmacros.h:     check for missing prerequisite headers?" >&5
+$as_echo "$as_me: WARNING: sys/sysmacros.h:     check for missing prerequisite headers?" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: sys/sysmacros.h: see the Autoconf documentation" >&5
+$as_echo "$as_me: WARNING: sys/sysmacros.h: see the Autoconf documentation" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: sys/sysmacros.h:     section \"Present But Cannot Be Compiled\"" >&5
+$as_echo "$as_me: WARNING: sys/sysmacros.h:     section \"Present But Cannot Be Compiled\"" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: sys/sysmacros.h: proceeding with the preprocessor's result" >&5
+$as_echo "$as_me: WARNING: sys/sysmacros.h: proceeding with the preprocessor's result" >&2;}
+    { $as_echo "$as_me:$LINENO: WARNING: sys/sysmacros.h: in the future, the compiler will take precedence" >&5
+$as_echo "$as_me: WARNING: sys/sysmacros.h: in the future, the compiler will take precedence" >&2;}
 
     ;;
 esac
-{ $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
-$as_echo_n "checking for $ac_header... " >&6; }
-if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+{ $as_echo "$as_me:$LINENO: checking for sys/sysmacros.h" >&5
+$as_echo_n "checking for sys/sysmacros.h... " >&6; }
+if test "${ac_cv_header_sys_sysmacros_h+set}" = set; then
   $as_echo_n "(cached) " >&6
 else
-  eval "$as_ac_Header=\$ac_header_preproc"
+  ac_cv_header_sys_sysmacros_h=$ac_header_preproc
 fi
-ac_res=`eval 'as_val=${'$as_ac_Header'}
-		 $as_echo "$as_val"'`
-	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
-$as_echo "$ac_res" >&6; }
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_header_sys_sysmacros_h" >&5
+$as_echo "$ac_cv_header_sys_sysmacros_h" >&6; }
 
 fi
-as_val=`eval 'as_val=${'$as_ac_Header'}
-		 $as_echo "$as_val"'`
-   if test "x$as_val" = x""yes; then
-  cat >>confdefs.h <<_ACEOF
-#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
+if test "x$ac_cv_header_sys_sysmacros_h" = x""yes; then
+
+cat >>confdefs.h <<\_ACEOF
+#define MAJOR_IN_SYSMACROS 1
 _ACEOF
 
-else
-  { { $as_echo "$as_me:$LINENO: error: bailing out" >&5
-$as_echo "$as_me: error: bailing out" >&2;}
-   { (exit 1); exit 1; }; }
 fi
 
-done
- ;;
-	darwin*)
 
+  fi
+fi
 
-for ac_header in machine/endian.h sys/disk.h
-do
-as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
-if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
-  { $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
-$as_echo_n "checking for $ac_header... " >&6; }
-if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+{ $as_echo "$as_me:$LINENO: checking for ANSI C header files" >&5
+$as_echo_n "checking for ANSI C header files... " >&6; }
+if test "${ac_cv_header_stdc+set}" = set; then
   $as_echo_n "(cached) " >&6
-fi
-ac_res=`eval 'as_val=${'$as_ac_Header'}
-		 $as_echo "$as_val"'`
-	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
-$as_echo "$ac_res" >&6; }
 else
-  # Is the header compilable?
-{ $as_echo "$as_me:$LINENO: checking $ac_header usability" >&5
-$as_echo_n "checking $ac_header usability... " >&6; }
-cat >conftest.$ac_ext <<_ACEOF
+  cat >conftest.$ac_ext <<_ACEOF
 /* confdefs.h.  */
 _ACEOF
 cat confdefs.h >>conftest.$ac_ext
 cat >>conftest.$ac_ext <<_ACEOF
 /* end confdefs.h.  */
-$ac_includes_default
-#include <$ac_header>
+#include <stdlib.h>
+#include <stdarg.h>
+#include <string.h>
+#include <float.h>
+
+int
+main ()
+{
+
+  ;
+  return 0;
+}
 _ACEOF
 rm -f conftest.$ac_objext
 if { (ac_try="$ac_compile"
@@ -5100,57 +4973,384 @@
 	 test -z "$ac_c_werror_flag" ||
 	 test ! -s conftest.err
        } && test -s conftest.$ac_objext; then
-  ac_header_compiler=yes
+  ac_cv_header_stdc=yes
 else
   $as_echo "$as_me: failed program was:" >&5
 sed 's/^/| /' conftest.$ac_ext >&5
 
-	ac_header_compiler=no
+	ac_cv_header_stdc=no
 fi
 
 rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
-{ $as_echo "$as_me:$LINENO: result: $ac_header_compiler" >&5
-$as_echo "$ac_header_compiler" >&6; }
 
-# Is the header present?
-{ $as_echo "$as_me:$LINENO: checking $ac_header presence" >&5
-$as_echo_n "checking $ac_header presence... " >&6; }
-cat >conftest.$ac_ext <<_ACEOF
+if test $ac_cv_header_stdc = yes; then
+  # SunOS 4.x string.h does not declare mem*, contrary to ANSI.
+  cat >conftest.$ac_ext <<_ACEOF
 /* confdefs.h.  */
 _ACEOF
 cat confdefs.h >>conftest.$ac_ext
 cat >>conftest.$ac_ext <<_ACEOF
 /* end confdefs.h.  */
-#include <$ac_header>
+#include <string.h>
+
 _ACEOF
-if { (ac_try="$ac_cpp conftest.$ac_ext"
+if (eval "$ac_cpp conftest.$ac_ext") 2>&5 |
+  $EGREP "memchr" >/dev/null 2>&1; then
+  :
+else
+  ac_cv_header_stdc=no
+fi
+rm -f conftest*
+
+fi
+
+if test $ac_cv_header_stdc = yes; then
+  # ISC 2.0.2 stdlib.h does not declare free, contrary to ANSI.
+  cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+#include <stdlib.h>
+
+_ACEOF
+if (eval "$ac_cpp conftest.$ac_ext") 2>&5 |
+  $EGREP "free" >/dev/null 2>&1; then
+  :
+else
+  ac_cv_header_stdc=no
+fi
+rm -f conftest*
+
+fi
+
+if test $ac_cv_header_stdc = yes; then
+  # /bin/cc in Irix-4.0.5 gets non-ANSI ctype macros unless using -ansi.
+  if test "$cross_compiling" = yes; then
+  :
+else
+  cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+#include <ctype.h>
+#include <stdlib.h>
+#if ((' ' & 0x0FF) == 0x020)
+# define ISLOWER(c) ('a' <= (c) && (c) <= 'z')
+# define TOUPPER(c) (ISLOWER(c) ? 'A' + ((c) - 'a') : (c))
+#else
+# define ISLOWER(c) \
+		   (('a' <= (c) && (c) <= 'i') \
+		     || ('j' <= (c) && (c) <= 'r') \
+		     || ('s' <= (c) && (c) <= 'z'))
+# define TOUPPER(c) (ISLOWER(c) ? ((c) | 0x40) : (c))
+#endif
+
+#define XOR(e, f) (((e) && !(f)) || (!(e) && (f)))
+int
+main ()
+{
+  int i;
+  for (i = 0; i < 256; i++)
+    if (XOR (islower (i), ISLOWER (i))
+	|| toupper (i) != TOUPPER (i))
+      return 2;
+  return 0;
+}
+_ACEOF
+rm -f conftest$ac_exeext
+if { (ac_try="$ac_link"
 case "(($ac_try" in
   *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
   *) ac_try_echo=$ac_try;;
 esac
 eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
 $as_echo "$ac_try_echo") >&5
-  (eval "$ac_cpp conftest.$ac_ext") 2>conftest.er1
+  (eval "$ac_link") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && { ac_try='./conftest$ac_exeext'
+  { (case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_try") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; }; then
+  :
+else
+  $as_echo "$as_me: program exited with status $ac_status" >&5
+$as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+( exit $ac_status )
+ac_cv_header_stdc=no
+fi
+rm -rf conftest.dSYM
+rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext conftest.$ac_objext conftest.$ac_ext
+fi
+
+
+fi
+fi
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_header_stdc" >&5
+$as_echo "$ac_cv_header_stdc" >&6; }
+if test $ac_cv_header_stdc = yes; then
+
+cat >>confdefs.h <<\_ACEOF
+#define STDC_HEADERS 1
+_ACEOF
+
+fi
+
+{ $as_echo "$as_me:$LINENO: checking for sys/wait.h that is POSIX.1 compatible" >&5
+$as_echo_n "checking for sys/wait.h that is POSIX.1 compatible... " >&6; }
+if test "${ac_cv_header_sys_wait_h+set}" = set; then
+  $as_echo_n "(cached) " >&6
+else
+  cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+#include <sys/types.h>
+#include <sys/wait.h>
+#ifndef WEXITSTATUS
+# define WEXITSTATUS(stat_val) ((unsigned int) (stat_val) >> 8)
+#endif
+#ifndef WIFEXITED
+# define WIFEXITED(stat_val) (((stat_val) & 255) == 0)
+#endif
+
+int
+main ()
+{
+  int s;
+  wait (&s);
+  s = WIFEXITED (s) ? WEXITSTATUS (s) : 1;
+  ;
+  return 0;
+}
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
   ac_status=$?
   grep -v '^ *+' conftest.er1 >conftest.err
   rm -f conftest.er1
   cat conftest.err >&5
   $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
-  (exit $ac_status); } >/dev/null && {
-	 test -z "$ac_c_preproc_warn_flag$ac_c_werror_flag" ||
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
 	 test ! -s conftest.err
-       }; then
-  ac_header_preproc=yes
+       } && test -s conftest.$ac_objext; then
+  ac_cv_header_sys_wait_h=yes
 else
   $as_echo "$as_me: failed program was:" >&5
 sed 's/^/| /' conftest.$ac_ext >&5
 
-  ac_header_preproc=no
+	ac_cv_header_sys_wait_h=no
 fi
 
-rm -f conftest.err conftest.$ac_ext
-{ $as_echo "$as_me:$LINENO: result: $ac_header_preproc" >&5
-$as_echo "$ac_header_preproc" >&6; }
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+fi
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_header_sys_wait_h" >&5
+$as_echo "$ac_cv_header_sys_wait_h" >&6; }
+if test $ac_cv_header_sys_wait_h = yes; then
+
+cat >>confdefs.h <<\_ACEOF
+#define HAVE_SYS_WAIT_H 1
+_ACEOF
+
+fi
+
+{ $as_echo "$as_me:$LINENO: checking whether time.h and sys/time.h may both be included" >&5
+$as_echo_n "checking whether time.h and sys/time.h may both be included... " >&6; }
+if test "${ac_cv_header_time+set}" = set; then
+  $as_echo_n "(cached) " >&6
+else
+  cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+#include <sys/types.h>
+#include <sys/time.h>
+#include <time.h>
+
+int
+main ()
+{
+if ((struct tm *) 0)
+return 0;
+  ;
+  return 0;
+}
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
+  ac_cv_header_time=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	ac_cv_header_time=no
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+fi
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_header_time" >&5
+$as_echo "$ac_cv_header_time" >&6; }
+if test $ac_cv_header_time = yes; then
+
+cat >>confdefs.h <<\_ACEOF
+#define TIME_WITH_SYS_TIME 1
+_ACEOF
+
+fi
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
+
+
+
+
+
+for ac_header in locale.h stddef.h syslog.h sys/file.h sys/time.h assert.h \
+  langinfo.h libgen.h signal.h sys/mman.h sys/resource.h sys/utsname.h \
+  sys/wait.h time.h
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
 
 # So?  What about this header?
 case $ac_header_compiler:$ac_header_preproc:$ac_c_preproc_warn_flag in
@@ -5177,71 +5377,1316 @@
 
     ;;
 esac
-{ $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
-$as_echo_n "checking for $ac_header... " >&6; }
-if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
-  $as_echo_n "(cached) " >&6
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
+  { { $as_echo "$as_me:$LINENO: error: bailing out" >&5
+$as_echo "$as_me: error: bailing out" >&2;}
+   { (exit 1); exit 1; }; }
+fi
+
+done
+
+
+case "$host_os" in
+	linux*)
+
+
+
+for ac_header in asm/byteorder.h linux/fs.h malloc.h
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
+  { { $as_echo "$as_me:$LINENO: error: bailing out" >&5
+$as_echo "$as_me: error: bailing out" >&2;}
+   { (exit 1); exit 1; }; }
+fi
+
+done
+ ;;
+	darwin*)
+
+
+for ac_header in machine/endian.h sys/disk.h
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
+  { { $as_echo "$as_me:$LINENO: error: bailing out" >&5
+$as_echo "$as_me: error: bailing out" >&2;}
+   { (exit 1); exit 1; }; }
+fi
+
+done
+ ;;
+esac
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
+
+
+
+
+
+
+for ac_header in ctype.h dirent.h errno.h fcntl.h getopt.h inttypes.h limits.h \
+  stdarg.h stdio.h stdlib.h string.h sys/ioctl.h sys/param.h sys/stat.h \
+  sys/types.h unistd.h
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
+  { { $as_echo "$as_me:$LINENO: error: bailing out" >&5
+$as_echo "$as_me: error: bailing out" >&2;}
+   { (exit 1); exit 1; }; }
+fi
+
+done
+
+
+
+for ac_header in termios.h sys/statvfs.h
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
+fi
+
+done
+
+
+################################################################################
+{ $as_echo "$as_me:$LINENO: checking for an ANSI C-conforming const" >&5
+$as_echo_n "checking for an ANSI C-conforming const... " >&6; }
+if test "${ac_cv_c_const+set}" = set; then
+  $as_echo_n "(cached) " >&6
+else
+  cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+
+int
+main ()
+{
+/* FIXME: Include the comments suggested by Paul. */
+#ifndef __cplusplus
+  /* Ultrix mips cc rejects this.  */
+  typedef int charset[2];
+  const charset cs;
+  /* SunOS 4.1.1 cc rejects this.  */
+  char const *const *pcpcc;
+  char **ppc;
+  /* NEC SVR4.0.2 mips cc rejects this.  */
+  struct point {int x, y;};
+  static struct point const zero = {0,0};
+  /* AIX XL C 1.02.0.0 rejects this.
+     It does not let you subtract one const X* pointer from another in
+     an arm of an if-expression whose if-part is not a constant
+     expression */
+  const char *g = "string";
+  pcpcc = &g + (g ? g-g : 0);
+  /* HPUX 7.0 cc rejects these. */
+  ++pcpcc;
+  ppc = (char**) pcpcc;
+  pcpcc = (char const *const *) ppc;
+  { /* SCO 3.2v4 cc rejects this.  */
+    char *t;
+    char const *s = 0 ? (char *) 0 : (char const *) 0;
+
+    *t++ = 0;
+    if (s) return 0;
+  }
+  { /* Someone thinks the Sun supposedly-ANSI compiler will reject this.  */
+    int x[] = {25, 17};
+    const int *foo = &x[0];
+    ++foo;
+  }
+  { /* Sun SC1.0 ANSI compiler rejects this -- but not the above. */
+    typedef const int *iptr;
+    iptr p = 0;
+    ++p;
+  }
+  { /* AIX XL C 1.02.0.0 rejects this saying
+       "k.c", line 2.27: 1506-025 (S) Operand must be a modifiable lvalue. */
+    struct s { int j; const int *ap[3]; };
+    struct s *b; b->j = 5;
+  }
+  { /* ULTRIX-32 V3.1 (Rev 9) vcc rejects this */
+    const int foo = 10;
+    if (!foo) return 0;
+  }
+  return !cs[0] && !zero.x;
+#endif
+
+  ;
+  return 0;
+}
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
+  ac_cv_c_const=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	ac_cv_c_const=no
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+fi
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_c_const" >&5
+$as_echo "$ac_cv_c_const" >&6; }
+if test $ac_cv_c_const = no; then
+
+cat >>confdefs.h <<\_ACEOF
+#define const /**/
+_ACEOF
+
+fi
+
+{ $as_echo "$as_me:$LINENO: checking for inline" >&5
+$as_echo_n "checking for inline... " >&6; }
+if test "${ac_cv_c_inline+set}" = set; then
+  $as_echo_n "(cached) " >&6
+else
+  ac_cv_c_inline=no
+for ac_kw in inline __inline__ __inline; do
+  cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+#ifndef __cplusplus
+typedef int foo_t;
+static $ac_kw foo_t static_foo () {return 0; }
+$ac_kw foo_t foo () {return 0; }
+#endif
+
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
+  ac_cv_c_inline=$ac_kw
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+  test "$ac_cv_c_inline" != no && break
+done
+
+fi
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_c_inline" >&5
+$as_echo "$ac_cv_c_inline" >&6; }
+
+
+case $ac_cv_c_inline in
+  inline | yes) ;;
+  *)
+    case $ac_cv_c_inline in
+      no) ac_val=;;
+      *) ac_val=$ac_cv_c_inline;;
+    esac
+    cat >>confdefs.h <<_ACEOF
+#ifndef __cplusplus
+#define inline $ac_val
+#endif
+_ACEOF
+    ;;
+esac
+
+{ $as_echo "$as_me:$LINENO: checking for struct stat.st_rdev" >&5
+$as_echo_n "checking for struct stat.st_rdev... " >&6; }
+if test "${ac_cv_member_struct_stat_st_rdev+set}" = set; then
+  $as_echo_n "(cached) " >&6
+else
+  cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+$ac_includes_default
+int
+main ()
+{
+static struct stat ac_aggr;
+if (ac_aggr.st_rdev)
+return 0;
+  ;
+  return 0;
+}
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
+  ac_cv_member_struct_stat_st_rdev=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+$ac_includes_default
+int
+main ()
+{
+static struct stat ac_aggr;
+if (sizeof ac_aggr.st_rdev)
+return 0;
+  ;
+  return 0;
+}
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
+  ac_cv_member_struct_stat_st_rdev=yes
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	ac_cv_member_struct_stat_st_rdev=no
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+fi
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_member_struct_stat_st_rdev" >&5
+$as_echo "$ac_cv_member_struct_stat_st_rdev" >&6; }
+if test "x$ac_cv_member_struct_stat_st_rdev" = x""yes; then
+
+cat >>confdefs.h <<_ACEOF
+#define HAVE_STRUCT_STAT_ST_RDEV 1
+_ACEOF
+
+
+fi
+
+{ $as_echo "$as_me:$LINENO: checking for off_t" >&5
+$as_echo_n "checking for off_t... " >&6; }
+if test "${ac_cv_type_off_t+set}" = set; then
+  $as_echo_n "(cached) " >&6
+else
+  ac_cv_type_off_t=no
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+$ac_includes_default
+int
+main ()
+{
+if (sizeof (off_t))
+       return 0;
+  ;
+  return 0;
+}
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
+  cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+$ac_includes_default
+int
+main ()
+{
+if (sizeof ((off_t)))
+	  return 0;
+  ;
+  return 0;
+}
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
+  :
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	ac_cv_type_off_t=yes
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+fi
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_type_off_t" >&5
+$as_echo "$ac_cv_type_off_t" >&6; }
+if test "x$ac_cv_type_off_t" = x""yes; then
+  :
+else
+
+cat >>confdefs.h <<_ACEOF
+#define off_t long int
+_ACEOF
+
+fi
+
+{ $as_echo "$as_me:$LINENO: checking for pid_t" >&5
+$as_echo_n "checking for pid_t... " >&6; }
+if test "${ac_cv_type_pid_t+set}" = set; then
+  $as_echo_n "(cached) " >&6
+else
+  ac_cv_type_pid_t=no
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+$ac_includes_default
+int
+main ()
+{
+if (sizeof (pid_t))
+       return 0;
+  ;
+  return 0;
+}
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
+  cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+$ac_includes_default
+int
+main ()
+{
+if (sizeof ((pid_t)))
+	  return 0;
+  ;
+  return 0;
+}
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
+  :
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	ac_cv_type_pid_t=yes
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+fi
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_type_pid_t" >&5
+$as_echo "$ac_cv_type_pid_t" >&6; }
+if test "x$ac_cv_type_pid_t" = x""yes; then
+  :
+else
+
+cat >>confdefs.h <<_ACEOF
+#define pid_t int
+_ACEOF
+
+fi
+
+{ $as_echo "$as_me:$LINENO: checking return type of signal handlers" >&5
+$as_echo_n "checking return type of signal handlers... " >&6; }
+if test "${ac_cv_type_signal+set}" = set; then
+  $as_echo_n "(cached) " >&6
+else
+  cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+#include <sys/types.h>
+#include <signal.h>
+
+int
+main ()
+{
+return *(signal (0, 0)) (0) == 1;
+  ;
+  return 0;
+}
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
+  ac_cv_type_signal=int
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	ac_cv_type_signal=void
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+fi
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_type_signal" >&5
+$as_echo "$ac_cv_type_signal" >&6; }
+
+cat >>confdefs.h <<_ACEOF
+#define RETSIGTYPE $ac_cv_type_signal
+_ACEOF
+
+
+{ $as_echo "$as_me:$LINENO: checking for size_t" >&5
+$as_echo_n "checking for size_t... " >&6; }
+if test "${ac_cv_type_size_t+set}" = set; then
+  $as_echo_n "(cached) " >&6
+else
+  ac_cv_type_size_t=no
+cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+$ac_includes_default
+int
+main ()
+{
+if (sizeof (size_t))
+       return 0;
+  ;
+  return 0;
+}
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
+  cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+$ac_includes_default
+int
+main ()
+{
+if (sizeof ((size_t)))
+	  return 0;
+  ;
+  return 0;
+}
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
+  :
 else
-  eval "$as_ac_Header=\$ac_header_preproc"
-fi
-ac_res=`eval 'as_val=${'$as_ac_Header'}
-		 $as_echo "$as_val"'`
-	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
-$as_echo "$ac_res" >&6; }
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
 
+	ac_cv_type_size_t=yes
 fi
-as_val=`eval 'as_val=${'$as_ac_Header'}
-		 $as_echo "$as_val"'`
-   if test "x$as_val" = x""yes; then
-  cat >>confdefs.h <<_ACEOF
-#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
-_ACEOF
 
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
 else
-  { { $as_echo "$as_me:$LINENO: error: bailing out" >&5
-$as_echo "$as_me: error: bailing out" >&2;}
-   { (exit 1); exit 1; }; }
-fi
-
-done
- ;;
-esac
-
-
-
-
-
-
-
-
-
-
-
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
 
 
+fi
 
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+fi
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_type_size_t" >&5
+$as_echo "$ac_cv_type_size_t" >&6; }
+if test "x$ac_cv_type_size_t" = x""yes; then
+  :
+else
 
+cat >>confdefs.h <<_ACEOF
+#define size_t unsigned int
+_ACEOF
 
+fi
 
-for ac_header in ctype.h dirent.h errno.h fcntl.h getopt.h inttypes.h limits.h \
-  stdarg.h stdio.h stdlib.h string.h sys/ioctl.h sys/param.h sys/stat.h \
-  sys/types.h unistd.h
-do
-as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
-if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
-  { $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
-$as_echo_n "checking for $ac_header... " >&6; }
-if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+{ $as_echo "$as_me:$LINENO: checking for mode_t" >&5
+$as_echo_n "checking for mode_t... " >&6; }
+if test "${ac_cv_type_mode_t+set}" = set; then
   $as_echo_n "(cached) " >&6
-fi
-ac_res=`eval 'as_val=${'$as_ac_Header'}
-		 $as_echo "$as_val"'`
-	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
-$as_echo "$ac_res" >&6; }
 else
-  # Is the header compilable?
-{ $as_echo "$as_me:$LINENO: checking $ac_header usability" >&5
-$as_echo_n "checking $ac_header usability... " >&6; }
+  ac_cv_type_mode_t=no
 cat >conftest.$ac_ext <<_ACEOF
 /* confdefs.h.  */
 _ACEOF
@@ -5249,7 +6694,14 @@
 cat >>conftest.$ac_ext <<_ACEOF
 /* end confdefs.h.  */
 $ac_includes_default
-#include <$ac_header>
+int
+main ()
+{
+if (sizeof (mode_t))
+       return 0;
+  ;
+  return 0;
+}
 _ACEOF
 rm -f conftest.$ac_objext
 if { (ac_try="$ac_compile"
@@ -5269,138 +6721,95 @@
 	 test -z "$ac_c_werror_flag" ||
 	 test ! -s conftest.err
        } && test -s conftest.$ac_objext; then
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
+  cat >conftest.$ac_ext <<_ACEOF
 /* confdefs.h.  */
 _ACEOF
 cat confdefs.h >>conftest.$ac_ext
 cat >>conftest.$ac_ext <<_ACEOF
 /* end confdefs.h.  */
-#include <$ac_header>
+$ac_includes_default
+int
+main ()
+{
+if (sizeof ((mode_t)))
+	  return 0;
+  ;
+  return 0;
+}
 _ACEOF
-if { (ac_try="$ac_cpp conftest.$ac_ext"
+rm -f conftest.$ac_objext
+if { (ac_try="$ac_compile"
 case "(($ac_try" in
   *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
   *) ac_try_echo=$ac_try;;
 esac
 eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
 $as_echo "$ac_try_echo") >&5
-  (eval "$ac_cpp conftest.$ac_ext") 2>conftest.er1
+  (eval "$ac_compile") 2>conftest.er1
   ac_status=$?
   grep -v '^ *+' conftest.er1 >conftest.err
   rm -f conftest.er1
   cat conftest.err >&5
   $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
-  (exit $ac_status); } >/dev/null && {
-	 test -z "$ac_c_preproc_warn_flag$ac_c_werror_flag" ||
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
 	 test ! -s conftest.err
-       }; then
-  ac_header_preproc=yes
+       } && test -s conftest.$ac_objext; then
+  :
 else
   $as_echo "$as_me: failed program was:" >&5
 sed 's/^/| /' conftest.$ac_ext >&5
 
-  ac_header_preproc=no
+	ac_cv_type_mode_t=yes
 fi
 
-rm -f conftest.err conftest.$ac_ext
-{ $as_echo "$as_me:$LINENO: result: $ac_header_preproc" >&5
-$as_echo "$ac_header_preproc" >&6; }
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
 
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
 
-    ;;
-esac
-{ $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
-$as_echo_n "checking for $ac_header... " >&6; }
-if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
-  $as_echo_n "(cached) " >&6
-else
-  eval "$as_ac_Header=\$ac_header_preproc"
 fi
-ac_res=`eval 'as_val=${'$as_ac_Header'}
-		 $as_echo "$as_val"'`
-	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
-$as_echo "$ac_res" >&6; }
 
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
 fi
-as_val=`eval 'as_val=${'$as_ac_Header'}
-		 $as_echo "$as_val"'`
-   if test "x$as_val" = x""yes; then
-  cat >>confdefs.h <<_ACEOF
-#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
-_ACEOF
-
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_type_mode_t" >&5
+$as_echo "$ac_cv_type_mode_t" >&6; }
+if test "x$ac_cv_type_mode_t" = x""yes; then
+  :
 else
-  { { $as_echo "$as_me:$LINENO: error: bailing out" >&5
-$as_echo "$as_me: error: bailing out" >&2;}
-   { (exit 1); exit 1; }; }
-fi
 
-done
+cat >>confdefs.h <<_ACEOF
+#define mode_t int
+_ACEOF
 
+fi
 
 
-for ac_header in termios.h sys/statvfs.h
-do
-as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
-if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
-  { $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
-$as_echo_n "checking for $ac_header... " >&6; }
-if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
+  { $as_echo "$as_me:$LINENO: checking for int8_t" >&5
+$as_echo_n "checking for int8_t... " >&6; }
+if test "${ac_cv_c_int8_t+set}" = set; then
   $as_echo_n "(cached) " >&6
-fi
-ac_res=`eval 'as_val=${'$as_ac_Header'}
-		 $as_echo "$as_val"'`
-	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
-$as_echo "$ac_res" >&6; }
 else
-  # Is the header compilable?
-{ $as_echo "$as_me:$LINENO: checking $ac_header usability" >&5
-$as_echo_n "checking $ac_header usability... " >&6; }
-cat >conftest.$ac_ext <<_ACEOF
+  ac_cv_c_int8_t=no
+     for ac_type in 'int8_t' 'int' 'long int' \
+	 'long long int' 'short int' 'signed char'; do
+       cat >conftest.$ac_ext <<_ACEOF
 /* confdefs.h.  */
 _ACEOF
 cat confdefs.h >>conftest.$ac_ext
 cat >>conftest.$ac_ext <<_ACEOF
 /* end confdefs.h.  */
 $ac_includes_default
-#include <$ac_header>
+int
+main ()
+{
+static int test_array [1 - 2 * !(0 < ($ac_type) (((($ac_type) 1 << (8 - 2)) - 1) * 2 + 1))];
+test_array [0] = 0
+
+  ;
+  return 0;
+}
 _ACEOF
 rm -f conftest.$ac_objext
 if { (ac_try="$ac_compile"
@@ -5420,173 +6829,99 @@
 	 test -z "$ac_c_werror_flag" ||
 	 test ! -s conftest.err
        } && test -s conftest.$ac_objext; then
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
+  cat >conftest.$ac_ext <<_ACEOF
 /* confdefs.h.  */
 _ACEOF
 cat confdefs.h >>conftest.$ac_ext
 cat >>conftest.$ac_ext <<_ACEOF
 /* end confdefs.h.  */
-#include <$ac_header>
+$ac_includes_default
+int
+main ()
+{
+static int test_array [1 - 2 * !(($ac_type) (((($ac_type) 1 << (8 - 2)) - 1) * 2 + 1)
+		 < ($ac_type) (((($ac_type) 1 << (8 - 2)) - 1) * 2 + 2))];
+test_array [0] = 0
+
+  ;
+  return 0;
+}
 _ACEOF
-if { (ac_try="$ac_cpp conftest.$ac_ext"
+rm -f conftest.$ac_objext
+if { (ac_try="$ac_compile"
 case "(($ac_try" in
   *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
   *) ac_try_echo=$ac_try;;
 esac
 eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
 $as_echo "$ac_try_echo") >&5
-  (eval "$ac_cpp conftest.$ac_ext") 2>conftest.er1
+  (eval "$ac_compile") 2>conftest.er1
   ac_status=$?
   grep -v '^ *+' conftest.er1 >conftest.err
   rm -f conftest.er1
   cat conftest.err >&5
   $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
-  (exit $ac_status); } >/dev/null && {
-	 test -z "$ac_c_preproc_warn_flag$ac_c_werror_flag" ||
+  (exit $ac_status); } && {
+	 test -z "$ac_c_werror_flag" ||
 	 test ! -s conftest.err
-       }; then
-  ac_header_preproc=yes
+       } && test -s conftest.$ac_objext; then
+  :
 else
   $as_echo "$as_me: failed program was:" >&5
 sed 's/^/| /' conftest.$ac_ext >&5
 
-  ac_header_preproc=no
-fi
-
-rm -f conftest.err conftest.$ac_ext
-{ $as_echo "$as_me:$LINENO: result: $ac_header_preproc" >&5
-$as_echo "$ac_header_preproc" >&6; }
+	case $ac_type in
+  int8_t) ac_cv_c_int8_t=yes ;;
+  *) ac_cv_c_int8_t=$ac_type ;;
+esac
 
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
+fi
 
-    ;;
-esac
-{ $as_echo "$as_me:$LINENO: checking for $ac_header" >&5
-$as_echo_n "checking for $ac_header... " >&6; }
-if { as_var=$as_ac_Header; eval "test \"\${$as_var+set}\" = set"; }; then
-  $as_echo_n "(cached) " >&6
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
 else
-  eval "$as_ac_Header=\$ac_header_preproc"
-fi
-ac_res=`eval 'as_val=${'$as_ac_Header'}
-		 $as_echo "$as_val"'`
-	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
-$as_echo "$ac_res" >&6; }
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
 
 fi
-as_val=`eval 'as_val=${'$as_ac_Header'}
-		 $as_echo "$as_val"'`
-   if test "x$as_val" = x""yes; then
-  cat >>confdefs.h <<_ACEOF
-#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
-_ACEOF
 
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+       test "$ac_cv_c_int8_t" != no && break
+     done
 fi
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_c_int8_t" >&5
+$as_echo "$ac_cv_c_int8_t" >&6; }
+  case $ac_cv_c_int8_t in #(
+  no|yes) ;; #(
+  *)
 
-done
+cat >>confdefs.h <<_ACEOF
+#define int8_t $ac_cv_c_int8_t
+_ACEOF
+;;
+  esac
 
 
-################################################################################
-{ $as_echo "$as_me:$LINENO: checking for an ANSI C-conforming const" >&5
-$as_echo_n "checking for an ANSI C-conforming const... " >&6; }
-if test "${ac_cv_c_const+set}" = set; then
+  { $as_echo "$as_me:$LINENO: checking for int16_t" >&5
+$as_echo_n "checking for int16_t... " >&6; }
+if test "${ac_cv_c_int16_t+set}" = set; then
   $as_echo_n "(cached) " >&6
 else
-  cat >conftest.$ac_ext <<_ACEOF
+  ac_cv_c_int16_t=no
+     for ac_type in 'int16_t' 'int' 'long int' \
+	 'long long int' 'short int' 'signed char'; do
+       cat >conftest.$ac_ext <<_ACEOF
 /* confdefs.h.  */
 _ACEOF
 cat confdefs.h >>conftest.$ac_ext
 cat >>conftest.$ac_ext <<_ACEOF
 /* end confdefs.h.  */
-
+$ac_includes_default
 int
 main ()
 {
-/* FIXME: Include the comments suggested by Paul. */
-#ifndef __cplusplus
-  /* Ultrix mips cc rejects this.  */
-  typedef int charset[2];
-  const charset cs;
-  /* SunOS 4.1.1 cc rejects this.  */
-  char const *const *pcpcc;
-  char **ppc;
-  /* NEC SVR4.0.2 mips cc rejects this.  */
-  struct point {int x, y;};
-  static struct point const zero = {0,0};
-  /* AIX XL C 1.02.0.0 rejects this.
-     It does not let you subtract one const X* pointer from another in
-     an arm of an if-expression whose if-part is not a constant
-     expression */
-  const char *g = "string";
-  pcpcc = &g + (g ? g-g : 0);
-  /* HPUX 7.0 cc rejects these. */
-  ++pcpcc;
-  ppc = (char**) pcpcc;
-  pcpcc = (char const *const *) ppc;
-  { /* SCO 3.2v4 cc rejects this.  */
-    char *t;
-    char const *s = 0 ? (char *) 0 : (char const *) 0;
-
-    *t++ = 0;
-    if (s) return 0;
-  }
-  { /* Someone thinks the Sun supposedly-ANSI compiler will reject this.  */
-    int x[] = {25, 17};
-    const int *foo = &x[0];
-    ++foo;
-  }
-  { /* Sun SC1.0 ANSI compiler rejects this -- but not the above. */
-    typedef const int *iptr;
-    iptr p = 0;
-    ++p;
-  }
-  { /* AIX XL C 1.02.0.0 rejects this saying
-       "k.c", line 2.27: 1506-025 (S) Operand must be a modifiable lvalue. */
-    struct s { int j; const int *ap[3]; };
-    struct s *b; b->j = 5;
-  }
-  { /* ULTRIX-32 V3.1 (Rev 9) vcc rejects this */
-    const int foo = 10;
-    if (!foo) return 0;
-  }
-  return !cs[0] && !zero.x;
-#endif
+static int test_array [1 - 2 * !(0 < ($ac_type) (((($ac_type) 1 << (16 - 2)) - 1) * 2 + 1))];
+test_array [0] = 0
 
   ;
   return 0;
@@ -5610,45 +6945,23 @@
 	 test -z "$ac_c_werror_flag" ||
 	 test ! -s conftest.err
        } && test -s conftest.$ac_objext; then
-  ac_cv_c_const=yes
-else
-  $as_echo "$as_me: failed program was:" >&5
-sed 's/^/| /' conftest.$ac_ext >&5
-
-	ac_cv_c_const=no
-fi
-
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
-fi
-{ $as_echo "$as_me:$LINENO: result: $ac_cv_c_const" >&5
-$as_echo "$ac_cv_c_const" >&6; }
-if test $ac_cv_c_const = no; then
-
-cat >>confdefs.h <<\_ACEOF
-#define const /**/
-_ACEOF
-
-fi
-
-{ $as_echo "$as_me:$LINENO: checking for inline" >&5
-$as_echo_n "checking for inline... " >&6; }
-if test "${ac_cv_c_inline+set}" = set; then
-  $as_echo_n "(cached) " >&6
-else
-  ac_cv_c_inline=no
-for ac_kw in inline __inline__ __inline; do
   cat >conftest.$ac_ext <<_ACEOF
 /* confdefs.h.  */
 _ACEOF
 cat confdefs.h >>conftest.$ac_ext
 cat >>conftest.$ac_ext <<_ACEOF
 /* end confdefs.h.  */
-#ifndef __cplusplus
-typedef int foo_t;
-static $ac_kw foo_t static_foo () {return 0; }
-$ac_kw foo_t foo () {return 0; }
-#endif
+$ac_includes_default
+int
+main ()
+{
+static int test_array [1 - 2 * !(($ac_type) (((($ac_type) 1 << (16 - 2)) - 1) * 2 + 1)
+		 < ($ac_type) (((($ac_type) 1 << (16 - 2)) - 1) * 2 + 2))];
+test_array [0] = 0
 
+  ;
+  return 0;
+}
 _ACEOF
 rm -f conftest.$ac_objext
 if { (ac_try="$ac_compile"
@@ -5668,44 +6981,52 @@
 	 test -z "$ac_c_werror_flag" ||
 	 test ! -s conftest.err
        } && test -s conftest.$ac_objext; then
-  ac_cv_c_inline=$ac_kw
+  :
 else
   $as_echo "$as_me: failed program was:" >&5
 sed 's/^/| /' conftest.$ac_ext >&5
 
+	case $ac_type in
+  int16_t) ac_cv_c_int16_t=yes ;;
+  *) ac_cv_c_int16_t=$ac_type ;;
+esac
 
 fi
 
 rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
-  test "$ac_cv_c_inline" != no && break
-done
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
 
-fi
-{ $as_echo "$as_me:$LINENO: result: $ac_cv_c_inline" >&5
-$as_echo "$ac_cv_c_inline" >&6; }
 
+fi
 
-case $ac_cv_c_inline in
-  inline | yes) ;;
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+       test "$ac_cv_c_int16_t" != no && break
+     done
+fi
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_c_int16_t" >&5
+$as_echo "$ac_cv_c_int16_t" >&6; }
+  case $ac_cv_c_int16_t in #(
+  no|yes) ;; #(
   *)
-    case $ac_cv_c_inline in
-      no) ac_val=;;
-      *) ac_val=$ac_cv_c_inline;;
-    esac
-    cat >>confdefs.h <<_ACEOF
-#ifndef __cplusplus
-#define inline $ac_val
-#endif
+
+cat >>confdefs.h <<_ACEOF
+#define int16_t $ac_cv_c_int16_t
 _ACEOF
-    ;;
-esac
+;;
+  esac
 
-{ $as_echo "$as_me:$LINENO: checking for struct stat.st_rdev" >&5
-$as_echo_n "checking for struct stat.st_rdev... " >&6; }
-if test "${ac_cv_member_struct_stat_st_rdev+set}" = set; then
+
+  { $as_echo "$as_me:$LINENO: checking for int32_t" >&5
+$as_echo_n "checking for int32_t... " >&6; }
+if test "${ac_cv_c_int32_t+set}" = set; then
   $as_echo_n "(cached) " >&6
 else
-  cat >conftest.$ac_ext <<_ACEOF
+  ac_cv_c_int32_t=no
+     for ac_type in 'int32_t' 'int' 'long int' \
+	 'long long int' 'short int' 'signed char'; do
+       cat >conftest.$ac_ext <<_ACEOF
 /* confdefs.h.  */
 _ACEOF
 cat confdefs.h >>conftest.$ac_ext
@@ -5715,9 +7036,9 @@
 int
 main ()
 {
-static struct stat ac_aggr;
-if (ac_aggr.st_rdev)
-return 0;
+static int test_array [1 - 2 * !(0 < ($ac_type) (((($ac_type) 1 << (32 - 2)) - 1) * 2 + 1))];
+test_array [0] = 0
+
   ;
   return 0;
 }
@@ -5740,12 +7061,7 @@
 	 test -z "$ac_c_werror_flag" ||
 	 test ! -s conftest.err
        } && test -s conftest.$ac_objext; then
-  ac_cv_member_struct_stat_st_rdev=yes
-else
-  $as_echo "$as_me: failed program was:" >&5
-sed 's/^/| /' conftest.$ac_ext >&5
-
-	cat >conftest.$ac_ext <<_ACEOF
+  cat >conftest.$ac_ext <<_ACEOF
 /* confdefs.h.  */
 _ACEOF
 cat confdefs.h >>conftest.$ac_ext
@@ -5755,9 +7071,10 @@
 int
 main ()
 {
-static struct stat ac_aggr;
-if (sizeof ac_aggr.st_rdev)
-return 0;
+static int test_array [1 - 2 * !(($ac_type) (((($ac_type) 1 << (32 - 2)) - 1) * 2 + 1)
+		 < ($ac_type) (((($ac_type) 1 << (32 - 2)) - 1) * 2 + 2))];
+test_array [0] = 0
+
   ;
   return 0;
 }
@@ -5780,37 +7097,52 @@
 	 test -z "$ac_c_werror_flag" ||
 	 test ! -s conftest.err
        } && test -s conftest.$ac_objext; then
-  ac_cv_member_struct_stat_st_rdev=yes
+  :
 else
   $as_echo "$as_me: failed program was:" >&5
 sed 's/^/| /' conftest.$ac_ext >&5
 
-	ac_cv_member_struct_stat_st_rdev=no
+	case $ac_type in
+  int32_t) ac_cv_c_int32_t=yes ;;
+  *) ac_cv_c_int32_t=$ac_type ;;
+esac
+
 fi
 
 rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+
 fi
 
 rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+       test "$ac_cv_c_int32_t" != no && break
+     done
 fi
-{ $as_echo "$as_me:$LINENO: result: $ac_cv_member_struct_stat_st_rdev" >&5
-$as_echo "$ac_cv_member_struct_stat_st_rdev" >&6; }
-if test "x$ac_cv_member_struct_stat_st_rdev" = x""yes; then
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_c_int32_t" >&5
+$as_echo "$ac_cv_c_int32_t" >&6; }
+  case $ac_cv_c_int32_t in #(
+  no|yes) ;; #(
+  *)
 
 cat >>confdefs.h <<_ACEOF
-#define HAVE_STRUCT_STAT_ST_RDEV 1
+#define int32_t $ac_cv_c_int32_t
 _ACEOF
+;;
+  esac
 
 
-fi
-
-{ $as_echo "$as_me:$LINENO: checking for off_t" >&5
-$as_echo_n "checking for off_t... " >&6; }
-if test "${ac_cv_type_off_t+set}" = set; then
+  { $as_echo "$as_me:$LINENO: checking for int64_t" >&5
+$as_echo_n "checking for int64_t... " >&6; }
+if test "${ac_cv_c_int64_t+set}" = set; then
   $as_echo_n "(cached) " >&6
 else
-  ac_cv_type_off_t=no
-cat >conftest.$ac_ext <<_ACEOF
+  ac_cv_c_int64_t=no
+     for ac_type in 'int64_t' 'int' 'long int' \
+	 'long long int' 'short int' 'signed char'; do
+       cat >conftest.$ac_ext <<_ACEOF
 /* confdefs.h.  */
 _ACEOF
 cat confdefs.h >>conftest.$ac_ext
@@ -5820,8 +7152,9 @@
 int
 main ()
 {
-if (sizeof (off_t))
-       return 0;
+static int test_array [1 - 2 * !(0 < ($ac_type) (((($ac_type) 1 << (64 - 2)) - 1) * 2 + 1))];
+test_array [0] = 0
+
   ;
   return 0;
 }
@@ -5854,8 +7187,10 @@
 int
 main ()
 {
-if (sizeof ((off_t)))
-	  return 0;
+static int test_array [1 - 2 * !(($ac_type) (((($ac_type) 1 << (64 - 2)) - 1) * 2 + 1)
+		 < ($ac_type) (((($ac_type) 1 << (64 - 2)) - 1) * 2 + 2))];
+test_array [0] = 0
+
   ;
   return 0;
 }
@@ -5883,7 +7218,11 @@
   $as_echo "$as_me: failed program was:" >&5
 sed 's/^/| /' conftest.$ac_ext >&5
 
-	ac_cv_type_off_t=yes
+	case $ac_type in
+  int64_t) ac_cv_c_int64_t=yes ;;
+  *) ac_cv_c_int64_t=$ac_type ;;
+esac
+
 fi
 
 rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
@@ -5895,25 +7234,27 @@
 fi
 
 rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+       test "$ac_cv_c_int64_t" != no && break
+     done
 fi
-{ $as_echo "$as_me:$LINENO: result: $ac_cv_type_off_t" >&5
-$as_echo "$ac_cv_type_off_t" >&6; }
-if test "x$ac_cv_type_off_t" = x""yes; then
-  :
-else
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_c_int64_t" >&5
+$as_echo "$ac_cv_c_int64_t" >&6; }
+  case $ac_cv_c_int64_t in #(
+  no|yes) ;; #(
+  *)
 
 cat >>confdefs.h <<_ACEOF
-#define off_t long int
+#define int64_t $ac_cv_c_int64_t
 _ACEOF
+;;
+  esac
 
-fi
-
-{ $as_echo "$as_me:$LINENO: checking for pid_t" >&5
-$as_echo_n "checking for pid_t... " >&6; }
-if test "${ac_cv_type_pid_t+set}" = set; then
+{ $as_echo "$as_me:$LINENO: checking for ssize_t" >&5
+$as_echo_n "checking for ssize_t... " >&6; }
+if test "${ac_cv_type_ssize_t+set}" = set; then
   $as_echo_n "(cached) " >&6
 else
-  ac_cv_type_pid_t=no
+  ac_cv_type_ssize_t=no
 cat >conftest.$ac_ext <<_ACEOF
 /* confdefs.h.  */
 _ACEOF
@@ -5924,7 +7265,7 @@
 int
 main ()
 {
-if (sizeof (pid_t))
+if (sizeof (ssize_t))
        return 0;
   ;
   return 0;
@@ -5958,7 +7299,7 @@
 int
 main ()
 {
-if (sizeof ((pid_t)))
+if (sizeof ((ssize_t)))
 	  return 0;
   ;
   return 0;
@@ -5987,7 +7328,7 @@
   $as_echo "$as_me: failed program was:" >&5
 sed 's/^/| /' conftest.$ac_ext >&5
 
-	ac_cv_type_pid_t=yes
+	ac_cv_type_ssize_t=yes
 fi
 
 rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
@@ -6000,21 +7341,21 @@
 
 rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
 fi
-{ $as_echo "$as_me:$LINENO: result: $ac_cv_type_pid_t" >&5
-$as_echo "$ac_cv_type_pid_t" >&6; }
-if test "x$ac_cv_type_pid_t" = x""yes; then
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_type_ssize_t" >&5
+$as_echo "$ac_cv_type_ssize_t" >&6; }
+if test "x$ac_cv_type_ssize_t" = x""yes; then
   :
 else
 
 cat >>confdefs.h <<_ACEOF
-#define pid_t int
+#define ssize_t int
 _ACEOF
 
 fi
 
-{ $as_echo "$as_me:$LINENO: checking return type of signal handlers" >&5
-$as_echo_n "checking return type of signal handlers... " >&6; }
-if test "${ac_cv_type_signal+set}" = set; then
+{ $as_echo "$as_me:$LINENO: checking for uid_t in sys/types.h" >&5
+$as_echo_n "checking for uid_t in sys/types.h... " >&6; }
+if test "${ac_cv_type_uid_t+set}" = set; then
   $as_echo_n "(cached) " >&6
 else
   cat >conftest.$ac_ext <<_ACEOF
@@ -6024,59 +7365,42 @@
 cat >>conftest.$ac_ext <<_ACEOF
 /* end confdefs.h.  */
 #include <sys/types.h>
-#include <signal.h>
 
-int
-main ()
-{
-return *(signal (0, 0)) (0) == 1;
-  ;
-  return 0;
-}
 _ACEOF
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
-  ac_cv_type_signal=int
+if (eval "$ac_cpp conftest.$ac_ext") 2>&5 |
+  $EGREP "uid_t" >/dev/null 2>&1; then
+  ac_cv_type_uid_t=yes
 else
-  $as_echo "$as_me: failed program was:" >&5
-sed 's/^/| /' conftest.$ac_ext >&5
-
-	ac_cv_type_signal=void
+  ac_cv_type_uid_t=no
 fi
+rm -f conftest*
 
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
 fi
-{ $as_echo "$as_me:$LINENO: result: $ac_cv_type_signal" >&5
-$as_echo "$ac_cv_type_signal" >&6; }
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_type_uid_t" >&5
+$as_echo "$ac_cv_type_uid_t" >&6; }
+if test $ac_cv_type_uid_t = no; then
 
-cat >>confdefs.h <<_ACEOF
-#define RETSIGTYPE $ac_cv_type_signal
+cat >>confdefs.h <<\_ACEOF
+#define uid_t int
 _ACEOF
 
 
-{ $as_echo "$as_me:$LINENO: checking for size_t" >&5
-$as_echo_n "checking for size_t... " >&6; }
-if test "${ac_cv_type_size_t+set}" = set; then
+cat >>confdefs.h <<\_ACEOF
+#define gid_t int
+_ACEOF
+
+fi
+
+
+  { $as_echo "$as_me:$LINENO: checking for uint8_t" >&5
+$as_echo_n "checking for uint8_t... " >&6; }
+if test "${ac_cv_c_uint8_t+set}" = set; then
   $as_echo_n "(cached) " >&6
 else
-  ac_cv_type_size_t=no
-cat >conftest.$ac_ext <<_ACEOF
+  ac_cv_c_uint8_t=no
+     for ac_type in 'uint8_t' 'unsigned int' 'unsigned long int' \
+	 'unsigned long long int' 'unsigned short int' 'unsigned char'; do
+       cat >conftest.$ac_ext <<_ACEOF
 /* confdefs.h.  */
 _ACEOF
 cat confdefs.h >>conftest.$ac_ext
@@ -6086,8 +7410,9 @@
 int
 main ()
 {
-if (sizeof (size_t))
-       return 0;
+static int test_array [1 - 2 * !(($ac_type) -1 >> (8 - 1) == 1)];
+test_array [0] = 0
+
   ;
   return 0;
 }
@@ -6110,7 +7435,49 @@
 	 test -z "$ac_c_werror_flag" ||
 	 test ! -s conftest.err
        } && test -s conftest.$ac_objext; then
-  cat >conftest.$ac_ext <<_ACEOF
+  case $ac_type in
+  uint8_t) ac_cv_c_uint8_t=yes ;;
+  *) ac_cv_c_uint8_t=$ac_type ;;
+esac
+
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+       test "$ac_cv_c_uint8_t" != no && break
+     done
+fi
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_c_uint8_t" >&5
+$as_echo "$ac_cv_c_uint8_t" >&6; }
+  case $ac_cv_c_uint8_t in #(
+  no|yes) ;; #(
+  *)
+
+cat >>confdefs.h <<\_ACEOF
+#define _UINT8_T 1
+_ACEOF
+
+
+cat >>confdefs.h <<_ACEOF
+#define uint8_t $ac_cv_c_uint8_t
+_ACEOF
+;;
+  esac
+
+
+  { $as_echo "$as_me:$LINENO: checking for uint16_t" >&5
+$as_echo_n "checking for uint16_t... " >&6; }
+if test "${ac_cv_c_uint16_t+set}" = set; then
+  $as_echo_n "(cached) " >&6
+else
+  ac_cv_c_uint16_t=no
+     for ac_type in 'uint16_t' 'unsigned int' 'unsigned long int' \
+	 'unsigned long long int' 'unsigned short int' 'unsigned char'; do
+       cat >conftest.$ac_ext <<_ACEOF
 /* confdefs.h.  */
 _ACEOF
 cat confdefs.h >>conftest.$ac_ext
@@ -6120,8 +7487,9 @@
 int
 main ()
 {
-if (sizeof ((size_t)))
-	  return 0;
+static int test_array [1 - 2 * !(($ac_type) -1 >> (16 - 1) == 1)];
+test_array [0] = 0
+
   ;
   return 0;
 }
@@ -6144,15 +7512,11 @@
 	 test -z "$ac_c_werror_flag" ||
 	 test ! -s conftest.err
        } && test -s conftest.$ac_objext; then
-  :
-else
-  $as_echo "$as_me: failed program was:" >&5
-sed 's/^/| /' conftest.$ac_ext >&5
-
-	ac_cv_type_size_t=yes
-fi
+  case $ac_type in
+  uint16_t) ac_cv_c_uint16_t=yes ;;
+  *) ac_cv_c_uint16_t=$ac_type ;;
+esac
 
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
 else
   $as_echo "$as_me: failed program was:" >&5
 sed 's/^/| /' conftest.$ac_ext >&5
@@ -6161,26 +7525,32 @@
 fi
 
 rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+       test "$ac_cv_c_uint16_t" != no && break
+     done
 fi
-{ $as_echo "$as_me:$LINENO: result: $ac_cv_type_size_t" >&5
-$as_echo "$ac_cv_type_size_t" >&6; }
-if test "x$ac_cv_type_size_t" = x""yes; then
-  :
-else
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_c_uint16_t" >&5
+$as_echo "$ac_cv_c_uint16_t" >&6; }
+  case $ac_cv_c_uint16_t in #(
+  no|yes) ;; #(
+  *)
+
 
 cat >>confdefs.h <<_ACEOF
-#define size_t unsigned int
+#define uint16_t $ac_cv_c_uint16_t
 _ACEOF
+;;
+  esac
 
-fi
 
-{ $as_echo "$as_me:$LINENO: checking for mode_t" >&5
-$as_echo_n "checking for mode_t... " >&6; }
-if test "${ac_cv_type_mode_t+set}" = set; then
+  { $as_echo "$as_me:$LINENO: checking for uint32_t" >&5
+$as_echo_n "checking for uint32_t... " >&6; }
+if test "${ac_cv_c_uint32_t+set}" = set; then
   $as_echo_n "(cached) " >&6
 else
-  ac_cv_type_mode_t=no
-cat >conftest.$ac_ext <<_ACEOF
+  ac_cv_c_uint32_t=no
+     for ac_type in 'uint32_t' 'unsigned int' 'unsigned long int' \
+	 'unsigned long long int' 'unsigned short int' 'unsigned char'; do
+       cat >conftest.$ac_ext <<_ACEOF
 /* confdefs.h.  */
 _ACEOF
 cat confdefs.h >>conftest.$ac_ext
@@ -6190,8 +7560,9 @@
 int
 main ()
 {
-if (sizeof (mode_t))
-       return 0;
+static int test_array [1 - 2 * !(($ac_type) -1 >> (32 - 1) == 1)];
+test_array [0] = 0
+
   ;
   return 0;
 }
@@ -6214,7 +7585,49 @@
 	 test -z "$ac_c_werror_flag" ||
 	 test ! -s conftest.err
        } && test -s conftest.$ac_objext; then
-  cat >conftest.$ac_ext <<_ACEOF
+  case $ac_type in
+  uint32_t) ac_cv_c_uint32_t=yes ;;
+  *) ac_cv_c_uint32_t=$ac_type ;;
+esac
+
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+       test "$ac_cv_c_uint32_t" != no && break
+     done
+fi
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_c_uint32_t" >&5
+$as_echo "$ac_cv_c_uint32_t" >&6; }
+  case $ac_cv_c_uint32_t in #(
+  no|yes) ;; #(
+  *)
+
+cat >>confdefs.h <<\_ACEOF
+#define _UINT32_T 1
+_ACEOF
+
+
+cat >>confdefs.h <<_ACEOF
+#define uint32_t $ac_cv_c_uint32_t
+_ACEOF
+;;
+  esac
+
+
+  { $as_echo "$as_me:$LINENO: checking for uint64_t" >&5
+$as_echo_n "checking for uint64_t... " >&6; }
+if test "${ac_cv_c_uint64_t+set}" = set; then
+  $as_echo_n "(cached) " >&6
+else
+  ac_cv_c_uint64_t=no
+     for ac_type in 'uint64_t' 'unsigned int' 'unsigned long int' \
+	 'unsigned long long int' 'unsigned short int' 'unsigned char'; do
+       cat >conftest.$ac_ext <<_ACEOF
 /* confdefs.h.  */
 _ACEOF
 cat confdefs.h >>conftest.$ac_ext
@@ -6224,8 +7637,9 @@
 int
 main ()
 {
-if (sizeof ((mode_t)))
-	  return 0;
+static int test_array [1 - 2 * !(($ac_type) -1 >> (64 - 1) == 1)];
+test_array [0] = 0
+
   ;
   return 0;
 }
@@ -6248,15 +7662,11 @@
 	 test -z "$ac_c_werror_flag" ||
 	 test ! -s conftest.err
        } && test -s conftest.$ac_objext; then
-  :
-else
-  $as_echo "$as_me: failed program was:" >&5
-sed 's/^/| /' conftest.$ac_ext >&5
-
-	ac_cv_type_mode_t=yes
-fi
+  case $ac_type in
+  uint64_t) ac_cv_c_uint64_t=yes ;;
+  *) ac_cv_c_uint64_t=$ac_type ;;
+esac
 
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
 else
   $as_echo "$as_me: failed program was:" >&5
 sed 's/^/| /' conftest.$ac_ext >&5
@@ -6265,18 +7675,25 @@
 fi
 
 rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+       test "$ac_cv_c_uint64_t" != no && break
+     done
 fi
-{ $as_echo "$as_me:$LINENO: result: $ac_cv_type_mode_t" >&5
-$as_echo "$ac_cv_type_mode_t" >&6; }
-if test "x$ac_cv_type_mode_t" = x""yes; then
-  :
-else
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_c_uint64_t" >&5
+$as_echo "$ac_cv_c_uint64_t" >&6; }
+  case $ac_cv_c_uint64_t in #(
+  no|yes) ;; #(
+  *)
 
-cat >>confdefs.h <<_ACEOF
-#define mode_t int
+cat >>confdefs.h <<\_ACEOF
+#define _UINT64_T 1
 _ACEOF
 
-fi
+
+cat >>confdefs.h <<_ACEOF
+#define uint64_t $ac_cv_c_uint64_t
+_ACEOF
+;;
+  esac
 
 { $as_echo "$as_me:$LINENO: checking for struct stat.st_rdev" >&5
 $as_echo_n "checking for struct stat.st_rdev... " >&6; }
@@ -6423,29 +7840,121 @@
   (exit $ac_status); } && {
 	 test -z "$ac_c_werror_flag" ||
 	 test ! -s conftest.err
-       } && test -s conftest.$ac_objext; then
-  ac_cv_struct_tm=time.h
+       } && test -s conftest.$ac_objext; then
+  ac_cv_struct_tm=time.h
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	ac_cv_struct_tm=sys/time.h
+fi
+
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+fi
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_struct_tm" >&5
+$as_echo "$ac_cv_struct_tm" >&6; }
+if test $ac_cv_struct_tm = sys/time.h; then
+
+cat >>confdefs.h <<\_ACEOF
+#define TM_IN_SYS_TIME 1
+_ACEOF
+
+fi
+
+
+################################################################################
+{ $as_echo "$as_me:$LINENO: checking for library containing floor" >&5
+$as_echo_n "checking for library containing floor... " >&6; }
+if test "${ac_cv_search_floor+set}" = set; then
+  $as_echo_n "(cached) " >&6
+else
+  ac_func_search_save_LIBS=$LIBS
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
+char floor ();
+int
+main ()
+{
+return floor ();
+  ;
+  return 0;
+}
+_ACEOF
+for ac_lib in '' m; do
+  if test -z "$ac_lib"; then
+    ac_res="none required"
+  else
+    ac_res=-l$ac_lib
+    LIBS="-l$ac_lib  $ac_func_search_save_LIBS"
+  fi
+  rm -f conftest.$ac_objext conftest$ac_exeext
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
+  ac_cv_search_floor=$ac_res
 else
   $as_echo "$as_me: failed program was:" >&5
 sed 's/^/| /' conftest.$ac_ext >&5
 
-	ac_cv_struct_tm=sys/time.h
-fi
 
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
 fi
-{ $as_echo "$as_me:$LINENO: result: $ac_cv_struct_tm" >&5
-$as_echo "$ac_cv_struct_tm" >&6; }
-if test $ac_cv_struct_tm = sys/time.h; then
 
-cat >>confdefs.h <<\_ACEOF
-#define TM_IN_SYS_TIME 1
-_ACEOF
+rm -rf conftest.dSYM
+rm -f core conftest.err conftest.$ac_objext conftest_ipa8_conftest.oo \
+      conftest$ac_exeext
+  if test "${ac_cv_search_floor+set}" = set; then
+  break
+fi
+done
+if test "${ac_cv_search_floor+set}" = set; then
+  :
+else
+  ac_cv_search_floor=no
+fi
+rm conftest.$ac_ext
+LIBS=$ac_func_search_save_LIBS
+fi
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_search_floor" >&5
+$as_echo "$ac_cv_search_floor" >&6; }
+ac_res=$ac_cv_search_floor
+if test "$ac_res" != no; then
+  test "$ac_res" = "none required" || LIBS="$ac_res $LIBS"
 
+else
+  { { $as_echo "$as_me:$LINENO: error: bailing out" >&5
+$as_echo "$as_me: error: bailing out" >&2;}
+   { (exit 1); exit 1; }; }
 fi
 
 
-################################################################################
 
 
 
@@ -6463,9 +7972,17 @@
 
 
 
-for ac_func in gethostname getpagesize memset mkdir rmdir munmap setlocale \
-  strcasecmp strchr strdup strncasecmp strerror strrchr strstr strtol strtoul \
-  uname
+
+
+
+
+
+
+
+for ac_func in floor ftruncate gethostname getpagesize \
+  gettimeofday memset mkdir mkfifo rmdir munmap nl_langinfo setenv setlocale \
+  strcasecmp strchr strcspn strspn strdup strncasecmp strerror strrchr \
+  strstr strtol strtoul uname
 do
 as_ac_var=`$as_echo "ac_cv_func_$ac_func" | $as_tr_sh`
 { $as_echo "$as_me:$LINENO: checking for $ac_func" >&5
@@ -7040,20 +8557,241 @@
 { $as_echo "$as_me:$LINENO: result: $ac_cv_c_stack_direction" >&5
 $as_echo "$ac_cv_c_stack_direction" >&6; }
 
-cat >>confdefs.h <<_ACEOF
-#define STACK_DIRECTION $ac_cv_c_stack_direction
+cat >>confdefs.h <<_ACEOF
+#define STACK_DIRECTION $ac_cv_c_stack_direction
+_ACEOF
+
+
+fi
+
+{ $as_echo "$as_me:$LINENO: checking whether closedir returns void" >&5
+$as_echo_n "checking whether closedir returns void... " >&6; }
+if test "${ac_cv_func_closedir_void+set}" = set; then
+  $as_echo_n "(cached) " >&6
+else
+  if test "$cross_compiling" = yes; then
+  ac_cv_func_closedir_void=yes
+else
+  cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+$ac_includes_default
+#include <$ac_header_dirent>
+#ifndef __cplusplus
+int closedir ();
+#endif
+
+int
+main ()
+{
+return closedir (opendir (".")) != 0;
+  ;
+  return 0;
+}
+_ACEOF
+rm -f conftest$ac_exeext
+if { (ac_try="$ac_link"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_link") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && { ac_try='./conftest$ac_exeext'
+  { (case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_try") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; }; then
+  ac_cv_func_closedir_void=no
+else
+  $as_echo "$as_me: program exited with status $ac_status" >&5
+$as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+( exit $ac_status )
+ac_cv_func_closedir_void=yes
+fi
+rm -rf conftest.dSYM
+rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext conftest.$ac_objext conftest.$ac_ext
+fi
+
+
+fi
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_func_closedir_void" >&5
+$as_echo "$ac_cv_func_closedir_void" >&6; }
+if test $ac_cv_func_closedir_void = yes; then
+
+cat >>confdefs.h <<\_ACEOF
+#define CLOSEDIR_VOID 1
+_ACEOF
+
+fi
+
+
+for ac_header in unistd.h
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
 _ACEOF
 
-
 fi
 
-{ $as_echo "$as_me:$LINENO: checking whether closedir returns void" >&5
-$as_echo_n "checking whether closedir returns void... " >&6; }
-if test "${ac_cv_func_closedir_void+set}" = set; then
+done
+
+{ $as_echo "$as_me:$LINENO: checking for working chown" >&5
+$as_echo_n "checking for working chown... " >&6; }
+if test "${ac_cv_func_chown_works+set}" = set; then
   $as_echo_n "(cached) " >&6
 else
   if test "$cross_compiling" = yes; then
-  ac_cv_func_closedir_void=yes
+  ac_cv_func_chown_works=no
 else
   cat >conftest.$ac_ext <<_ACEOF
 /* confdefs.h.  */
@@ -7062,15 +8800,24 @@
 cat >>conftest.$ac_ext <<_ACEOF
 /* end confdefs.h.  */
 $ac_includes_default
-#include <$ac_header_dirent>
-#ifndef __cplusplus
-int closedir ();
-#endif
+#include <fcntl.h>
 
 int
 main ()
 {
-return closedir (opendir (".")) != 0;
+  char *f = "conftest.chown";
+  struct stat before, after;
+
+  if (creat (f, 0600) < 0)
+    return 1;
+  if (stat (f, &before) < 0)
+    return 1;
+  if (chown (f, (uid_t) -1, (gid_t) -1) == -1)
+    return 1;
+  if (stat (f, &after) < 0)
+    return 1;
+  return ! (before.st_uid == after.st_uid && before.st_gid == after.st_gid);
+
   ;
   return 0;
 }
@@ -7097,27 +8844,29 @@
   ac_status=$?
   $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
   (exit $ac_status); }; }; then
-  ac_cv_func_closedir_void=no
+  ac_cv_func_chown_works=yes
 else
   $as_echo "$as_me: program exited with status $ac_status" >&5
 $as_echo "$as_me: failed program was:" >&5
 sed 's/^/| /' conftest.$ac_ext >&5
 
 ( exit $ac_status )
-ac_cv_func_closedir_void=yes
+ac_cv_func_chown_works=no
 fi
 rm -rf conftest.dSYM
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext conftest.$ac_objext conftest.$ac_ext
 fi
 
 
+rm -f conftest.chown
+
 fi
-{ $as_echo "$as_me:$LINENO: result: $ac_cv_func_closedir_void" >&5
-$as_echo "$ac_cv_func_closedir_void" >&6; }
-if test $ac_cv_func_closedir_void = yes; then
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_func_chown_works" >&5
+$as_echo "$ac_cv_func_chown_works" >&6; }
+if test $ac_cv_func_chown_works = yes; then
 
 cat >>confdefs.h <<\_ACEOF
-#define CLOSEDIR_VOID 1
+#define HAVE_CHOWN 1
 _ACEOF
 
 fi
@@ -8501,20 +10250,242 @@
     if (*(data + i) != *(data2 + i))
       return 1;
 
-  /* Finally, make sure that changes to the mapped area do not
-     percolate back to the file as seen by read().  (This is a bug on
-     some variants of i386 svr4.0.)  */
-  for (i = 0; i < pagesize; ++i)
-    *(data2 + i) = *(data2 + i) + 1;
-  data3 = (char *) malloc (pagesize);
-  if (!data3)
-    return 1;
-  if (read (fd, data3, pagesize) != pagesize)
-    return 1;
-  for (i = 0; i < pagesize; ++i)
-    if (*(data + i) != *(data3 + i))
-      return 1;
-  close (fd);
+  /* Finally, make sure that changes to the mapped area do not
+     percolate back to the file as seen by read().  (This is a bug on
+     some variants of i386 svr4.0.)  */
+  for (i = 0; i < pagesize; ++i)
+    *(data2 + i) = *(data2 + i) + 1;
+  data3 = (char *) malloc (pagesize);
+  if (!data3)
+    return 1;
+  if (read (fd, data3, pagesize) != pagesize)
+    return 1;
+  for (i = 0; i < pagesize; ++i)
+    if (*(data + i) != *(data3 + i))
+      return 1;
+  close (fd);
+  return 0;
+}
+_ACEOF
+rm -f conftest$ac_exeext
+if { (ac_try="$ac_link"
+case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_link") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); } && { ac_try='./conftest$ac_exeext'
+  { (case "(($ac_try" in
+  *\"* | *\`* | *\\*) ac_try_echo=\$ac_try;;
+  *) ac_try_echo=$ac_try;;
+esac
+eval ac_try_echo="\"\$as_me:$LINENO: $ac_try_echo\""
+$as_echo "$ac_try_echo") >&5
+  (eval "$ac_try") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
+  (exit $ac_status); }; }; then
+  ac_cv_func_mmap_fixed_mapped=yes
+else
+  $as_echo "$as_me: program exited with status $ac_status" >&5
+$as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+( exit $ac_status )
+ac_cv_func_mmap_fixed_mapped=no
+fi
+rm -rf conftest.dSYM
+rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext conftest.$ac_objext conftest.$ac_ext
+fi
+
+
+fi
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_func_mmap_fixed_mapped" >&5
+$as_echo "$ac_cv_func_mmap_fixed_mapped" >&6; }
+if test $ac_cv_func_mmap_fixed_mapped = yes; then
+
+cat >>confdefs.h <<\_ACEOF
+#define HAVE_MMAP 1
+_ACEOF
+
+fi
+rm -f conftest.mmap
+
+
+for ac_header in stdlib.h
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
+fi
+
+done
+
+{ $as_echo "$as_me:$LINENO: checking for GNU libc compatible realloc" >&5
+$as_echo_n "checking for GNU libc compatible realloc... " >&6; }
+if test "${ac_cv_func_realloc_0_nonnull+set}" = set; then
+  $as_echo_n "(cached) " >&6
+else
+  if test "$cross_compiling" = yes; then
+  ac_cv_func_realloc_0_nonnull=no
+else
+  cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+#if defined STDC_HEADERS || defined HAVE_STDLIB_H
+# include <stdlib.h>
+#else
+char *realloc ();
+#endif
+
+int
+main ()
+{
+return ! realloc (0, 0);
+  ;
   return 0;
 }
 _ACEOF
@@ -8540,14 +10511,14 @@
   ac_status=$?
   $as_echo "$as_me:$LINENO: \$? = $ac_status" >&5
   (exit $ac_status); }; }; then
-  ac_cv_func_mmap_fixed_mapped=yes
+  ac_cv_func_realloc_0_nonnull=yes
 else
   $as_echo "$as_me: program exited with status $ac_status" >&5
 $as_echo "$as_me: failed program was:" >&5
 sed 's/^/| /' conftest.$ac_ext >&5
 
 ( exit $ac_status )
-ac_cv_func_mmap_fixed_mapped=no
+ac_cv_func_realloc_0_nonnull=no
 fi
 rm -rf conftest.dSYM
 rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext conftest.$ac_objext conftest.$ac_ext
@@ -8555,16 +10526,33 @@
 
 
 fi
-{ $as_echo "$as_me:$LINENO: result: $ac_cv_func_mmap_fixed_mapped" >&5
-$as_echo "$ac_cv_func_mmap_fixed_mapped" >&6; }
-if test $ac_cv_func_mmap_fixed_mapped = yes; then
+{ $as_echo "$as_me:$LINENO: result: $ac_cv_func_realloc_0_nonnull" >&5
+$as_echo "$ac_cv_func_realloc_0_nonnull" >&6; }
+if test $ac_cv_func_realloc_0_nonnull = yes; then
 
 cat >>confdefs.h <<\_ACEOF
-#define HAVE_MMAP 1
+#define HAVE_REALLOC 1
+_ACEOF
+
+else
+  cat >>confdefs.h <<\_ACEOF
+#define HAVE_REALLOC 0
+_ACEOF
+
+   case " $LIBOBJS " in
+  *" realloc.$ac_objext "* ) ;;
+  *) LIBOBJS="$LIBOBJS realloc.$ac_objext"
+ ;;
+esac
+
+
+cat >>confdefs.h <<\_ACEOF
+#define realloc rpl_realloc
 _ACEOF
 
 fi
-rm -f conftest.mmap
+
+
 
 { $as_echo "$as_me:$LINENO: checking whether stat accepts an empty string" >&5
 $as_echo_n "checking whether stat accepts an empty string... " >&6; }
@@ -9409,10 +11397,6 @@
 pkg_config_init() {
 
 
-
-
-
-
 if test "x$ac_cv_env_PKG_CONFIG_set" != "xset"; then
 	if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}pkg-config", so it can be a program name with args.
@@ -9525,6 +11509,7 @@
 $as_echo "no" >&6; }
 		PKG_CONFIG=""
 	fi
+
 fi
 
 pkg_failed=no
@@ -9567,8 +11552,6 @@
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -9583,11 +11566,11 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$PKGCONFIGINIT_PKG_ERRORS" >&5
 
-	{ $as_echo "$as_me:$LINENO: result: pkg-config initialized" >&5
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+                { $as_echo "$as_me:$LINENO: result: pkg-config initialized" >&5
 $as_echo "pkg-config initialized" >&6; }
 elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 	{ $as_echo "$as_me:$LINENO: result: pkg-config initialized" >&5
 $as_echo "pkg-config initialized" >&6; }
 else
@@ -9595,7 +11578,7 @@
 	PKGCONFIGINIT_LIBS=$pkg_cv_PKGCONFIGINIT_LIBS
         { $as_echo "$as_me:$LINENO: result: yes" >&5
 $as_echo "yes" >&6; }
-
+	:
 fi
 	PKGCONFIG_INIT=1
 }
@@ -9801,8 +11784,6 @@
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -9817,7 +11798,9 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$CCS_PKG_ERRORS" >&5
 
-	NOTFOUND=0
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+                NOTFOUND=0
 
 for ac_header in ccs.h
 do
@@ -9974,8 +11957,6 @@
 			HAVE_CCS=yes
 		fi
 elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 	NOTFOUND=0
 
 for ac_header in ccs.h
@@ -10180,8 +12161,6 @@
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -10196,7 +12175,9 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$GULM_PKG_ERRORS" >&5
 
-	NOTFOUND=0
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+                NOTFOUND=0
 
 for ac_header in libgulm.h
 do
@@ -10353,8 +12334,6 @@
 			HAVE_GULM=yes
 		fi
 elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 	NOTFOUND=0
 
 for ac_header in libgulm.h
@@ -10562,8 +12541,6 @@
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -10578,7 +12555,9 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$CMAN_PKG_ERRORS" >&5
 
-	NOTFOUND=0
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+                NOTFOUND=0
 
 for ac_header in libcman.h
 do
@@ -10735,8 +12714,6 @@
 			HAVE_CMAN=yes
 		fi
 elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 	NOTFOUND=0
 
 for ac_header in libcman.h
@@ -10947,8 +12924,6 @@
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -10963,10 +12938,10 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$COROSYNC_PKG_ERRORS" >&5
 
-	$bailout
-elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
 $as_echo "no" >&6; }
+                $bailout
+elif test $pkg_failed = untried; then
 	$bailout
 else
 	COROSYNC_CFLAGS=$pkg_cv_COROSYNC_CFLAGS
@@ -11020,8 +12995,6 @@
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -11036,10 +13009,10 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$QUORUM_PKG_ERRORS" >&5
 
-	$bailout
-elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
 $as_echo "no" >&6; }
+                $bailout
+elif test $pkg_failed = untried; then
 	$bailout
 else
 	QUORUM_CFLAGS=$pkg_cv_QUORUM_CFLAGS
@@ -11094,8 +13067,6 @@
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -11110,10 +13081,10 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$SALCK_PKG_ERRORS" >&5
 
-	$bailout
-elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
 $as_echo "no" >&6; }
+                $bailout
+elif test $pkg_failed = untried; then
 	$bailout
 else
 	SALCK_CFLAGS=$pkg_cv_SALCK_CFLAGS
@@ -11169,8 +13140,6 @@
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -11185,10 +13154,10 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$CONFDB_PKG_ERRORS" >&5
 
-	HAVE_CONFDB=no
-elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
 $as_echo "no" >&6; }
+                HAVE_CONFDB=no
+elif test $pkg_failed = untried; then
 	HAVE_CONFDB=no
 else
 	CONFDB_CFLAGS=$pkg_cv_CONFDB_CFLAGS
@@ -11407,8 +13376,6 @@
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -11423,10 +13390,10 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$CPG_PKG_ERRORS" >&5
 
-	$bailout
-elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:$LINENO: result: no" >&5
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
 $as_echo "no" >&6; }
+                $bailout
+elif test $pkg_failed = untried; then
 	$bailout
 else
 	CPG_CFLAGS=$pkg_cv_CPG_CFLAGS
@@ -11479,8 +13446,6 @@
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -11495,7 +13460,9 @@
 	# Put the nasty error message in config.log where it belongs
 	echo "$DLM_PKG_ERRORS" >&5
 
-	NOTFOUND=0
+	{ $as_echo "$as_me:$LINENO: result: no" >&5
+$as_echo "no" >&6; }
+                NOTFOUND=0
 
 for ac_header in libdlm.h
 do
@@ -11652,8 +13619,6 @@
 			HAVE_DLM=yes
 		fi
 elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 	NOTFOUND=0
 
 for ac_header in libdlm.h
@@ -11936,8 +13901,6 @@
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -11961,7 +13924,8 @@
 
 Alternatively, you may set the environment variables SACKPT_CFLAGS
 and SACKPT_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details." >&5
+See the pkg-config man page for more details.
+" >&5
 $as_echo "$as_me: error: Package requirements (libSaCkpt) were not met:
 
 $SACKPT_PKG_ERRORS
@@ -11971,11 +13935,10 @@
 
 Alternatively, you may set the environment variables SACKPT_CFLAGS
 and SACKPT_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details." >&2;}
+See the pkg-config man page for more details.
+" >&2;}
    { (exit 1); exit 1; }; }
 elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 	{ { $as_echo "$as_me:$LINENO: error: in \`$ac_pwd':" >&5
 $as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
 { { $as_echo "$as_me:$LINENO: error: The pkg-config script could not be found or is too old.  Make sure it
@@ -12004,7 +13967,7 @@
 	SACKPT_LIBS=$pkg_cv_SACKPT_LIBS
         { $as_echo "$as_me:$LINENO: result: yes" >&5
 $as_echo "yes" >&6; }
-
+	:
 fi
 	if test x$HAVE_CPG != xyes; then
 
@@ -12048,8 +14011,6 @@
 
 
 if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 
 if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
         _pkg_short_errors_supported=yes
@@ -12073,7 +14034,8 @@
 
 Alternatively, you may set the environment variables CPG_CFLAGS
 and CPG_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details." >&5
+See the pkg-config man page for more details.
+" >&5
 $as_echo "$as_me: error: Package requirements (libcpg) were not met:
 
 $CPG_PKG_ERRORS
@@ -12083,11 +14045,10 @@
 
 Alternatively, you may set the environment variables CPG_CFLAGS
 and CPG_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details." >&2;}
+See the pkg-config man page for more details.
+" >&2;}
    { (exit 1); exit 1; }; }
 elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:$LINENO: result: no" >&5
-$as_echo "no" >&6; }
 	{ { $as_echo "$as_me:$LINENO: error: in \`$ac_pwd':" >&5
 $as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
 { { $as_echo "$as_me:$LINENO: error: The pkg-config script could not be found or is too old.  Make sure it
@@ -12116,7 +14077,7 @@
 	CPG_LIBS=$pkg_cv_CPG_LIBS
         { $as_echo "$as_me:$LINENO: result: yes" >&5
 $as_echo "yes" >&6; }
-
+	:
 fi
 	fi
 fi
@@ -14509,7 +16470,6 @@
 fi
 
 
-#	AC_FUNC_REALLOC
 
 
 for ac_header in sys/select.h sys/socket.h
@@ -15007,6 +16967,159 @@
 
 fi
 
+if test x$DMEVENTD = xyes; then
+
+for ac_header in arpa/inet.h
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
+  { { $as_echo "$as_me:$LINENO: error: bailing out" >&5
+$as_echo "$as_me: error: bailing out" >&2;}
+   { (exit 1); exit 1; }; }
+fi
+
+done
+
+fi
+
 if test x$HAVE_LIBDL = xyes; then
 
 for ac_header in dlfcn.h
--- LVM2/configure.in	2010/06/07 14:32:01	1.143
+++ LVM2/configure.in	2010/07/05 22:23:15	1.144
@@ -78,12 +78,14 @@
 ################################################################################
 dnl -- Check for header files.
 AC_HEADER_DIRENT
+AC_HEADER_MAJOR
 AC_HEADER_STDC
 AC_HEADER_SYS_WAIT
 AC_HEADER_TIME
 
 AC_CHECK_HEADERS([locale.h stddef.h syslog.h sys/file.h sys/time.h assert.h \
-  libgen.h signal.h sys/mman.h sys/resource.h sys/utsname.h sys/wait.h time.h], ,
+  langinfo.h libgen.h signal.h sys/mman.h sys/resource.h sys/utsname.h \
+  sys/wait.h time.h], ,
   [AC_MSG_ERROR(bailing out)])
 
 case "$host_os" in
@@ -108,22 +110,36 @@
 AC_TYPE_SIGNAL
 AC_TYPE_SIZE_T
 AC_TYPE_MODE_T
+AC_TYPE_INT8_T
+AC_TYPE_INT16_T
+AC_TYPE_INT32_T
+AC_TYPE_INT64_T
+AC_TYPE_SSIZE_T
+AC_TYPE_UID_T
+AC_TYPE_UINT8_T
+AC_TYPE_UINT16_T
+AC_TYPE_UINT32_T
+AC_TYPE_UINT64_T
 AC_CHECK_MEMBERS([struct stat.st_rdev])
 AC_STRUCT_TM
 
 ################################################################################
 dnl -- Check for functions
-AC_CHECK_FUNCS([gethostname getpagesize memset mkdir rmdir munmap setlocale \
-  strcasecmp strchr strdup strncasecmp strerror strrchr strstr strtol strtoul \
-  uname], , [AC_MSG_ERROR(bailing out)])
+AC_SEARCH_LIBS([floor], [m], , [AC_MSG_ERROR(bailing out)])
+AC_CHECK_FUNCS([floor ftruncate gethostname getpagesize \
+  gettimeofday memset mkdir mkfifo rmdir munmap nl_langinfo setenv setlocale \
+  strcasecmp strchr strcspn strspn strdup strncasecmp strerror strrchr \
+  strstr strtol strtoul uname], , [AC_MSG_ERROR(bailing out)])
 AC_CHECK_FUNCS(siginterrupt)
 AC_FUNC_ALLOCA
 AC_FUNC_CLOSEDIR_VOID
+AC_FUNC_CHOWN
 AC_FUNC_FORK
 AC_FUNC_LSTAT
 AC_FUNC_MALLOC
 AC_FUNC_MEMCMP
 AC_FUNC_MMAP
+AC_FUNC_REALLOC
 AC_FUNC_STAT
 AC_FUNC_STRTOD
 AC_FUNC_VPRINTF
@@ -981,7 +997,6 @@
 	AC_CHECK_HEADERS(mntent.h netdb.h netinet/in.h pthread.h search.h sys/mount.h sys/socket.h sys/uio.h sys/un.h utmpx.h,,AC_MSG_ERROR(bailing out))
 	AC_CHECK_FUNCS(dup2 getmntent memmove select socket,,AC_MSG_ERROR(bailing out))
 	AC_FUNC_GETMNTENT
-#	AC_FUNC_REALLOC
 	AC_FUNC_SELECT_ARGTYPES
 fi
 
@@ -990,6 +1005,10 @@
 	AC_CHECK_FUNCS(socket,,AC_MSG_ERROR(bailing out))
 fi
 
+if test x$DMEVENTD = xyes; then
+	AC_CHECK_HEADERS(arpa/inet.h,,AC_MSG_ERROR(bailing out))
+fi
+
 if test x$HAVE_LIBDL = xyes; then
 	AC_CHECK_HEADERS(dlfcn.h,,AC_MSG_ERROR(bailing out))
 fi
--- LVM2/lib/metadata/metadata.c	2010/06/30 20:03:52	1.378
+++ LVM2/lib/metadata/metadata.c	2010/07/05 22:23:15	1.379
@@ -31,6 +31,7 @@
 #include "defaults.h"
 #include "filter-persistent.h"
 
+#include <math.h>
 #include <sys/param.h>
 
 /*
@@ -1013,63 +1014,140 @@
 	return 1;
 }
 
+static dm_bitset_t _bitset_with_random_bits(struct dm_pool *mem, uint32_t num_bits,
+					    uint32_t num_set_bits, unsigned *seed)
+{
+	dm_bitset_t bs;
+	unsigned bit_selected;
+	char buf[32];
+	uint32_t i = num_bits - num_set_bits;
+
+	if (!(bs = dm_bitset_create(mem, (unsigned) num_bits))) {
+		log_error("Failed to allocate bitset for setting random bits.");
+		return NULL;
+	}
+
+        if (!dm_pool_begin_object(mem, 512)) {
+                log_error("dm_pool_begin_object failed for random list of bits.");
+		dm_pool_free(mem, bs);
+                return NULL;
+        }
+
+	/* Perform loop num_set_bits times, selecting one bit each time */
+	while (i++ < num_bits) {
+		/* Select a random bit between 0 and (i-1) inclusive. */
+		bit_selected = (unsigned) floor(i * (rand_r(seed) / (RAND_MAX + 1.0)));
+
+		/*
+		 * If the bit was already set, set the new bit that became
+		 * choosable for the first time during this pass.
+		 * This maintains a uniform probability distribution by compensating
+		 * for being unable to select it until this pass.
+		 */
+		if (dm_bit(bs, bit_selected))
+			bit_selected = i - 1;
+
+		dm_bit_set(bs, bit_selected);
+
+		if (dm_snprintf(buf, sizeof(buf), "%u ", bit_selected) < 0) {
+			log_error("snprintf random bit failed.");
+			dm_pool_free(mem, bs);
+                	return NULL;
+		}
+		if (!dm_pool_grow_object(mem, buf, strlen(buf))) {
+			log_error("Failed to generate list of random bits.");
+			dm_pool_free(mem, bs);
+                	return NULL;
+		}
+	}
+
+	log_debug("Selected %" PRIu32 " random bits from %" PRIu32 ": %s", num_set_bits, num_bits, (char *) dm_pool_end_object(mem));
+
+	return bs;
+}
+
 static int _vg_ignore_mdas(struct volume_group *vg, uint32_t num_to_ignore)
 {
 	struct metadata_area *mda;
+	uint32_t mda_used_count = vg_mda_used_count(vg);
+	dm_bitset_t mda_to_ignore_bs;
+	int r = 1;
 
-	log_debug("Adjusting ignored mdas on vg %s: %" PRIu32 " mdas in use "
+	log_debug("Adjusting ignored mdas on vg %s: %" PRIu32 " of %" PRIu32 " mdas in use "
 		  "but %" PRIu32 " required.  Changing %" PRIu32 " flags.",
-		  vg->name, vg_mda_copies(vg), vg_mda_used_count(vg), num_to_ignore);
+		  vg->name, mda_used_count, vg_mda_count(vg), vg_mda_copies(vg), num_to_ignore);
 
 	if (!num_to_ignore)
 		return 1;
 
-	/* FIXME: flip bits on random mdas */
+	if (!(mda_to_ignore_bs = _bitset_with_random_bits(vg->vgmem, mda_used_count,
+							  num_to_ignore, &vg->cmd->rand_seed)))
+		return_0;
+
 	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use)
-		if (!mda_is_ignored(mda)) {
+		if (!mda_is_ignored(mda) && (--mda_used_count,
+		    dm_bit(mda_to_ignore_bs, mda_used_count))) {
 			mda_set_ignored(mda, 1);
 			if (!--num_to_ignore)
-				return 1;
+				goto out;
 		}
 
 	log_error(INTERNAL_ERROR "Unable to find %"PRIu32" metadata areas to ignore "
 		  "on volume group %s", num_to_ignore, vg->name);
 
-	return 0;
+	r = 0;
+
+out:
+	dm_pool_free(vg->vgmem, mda_to_ignore_bs);
+	return r;
 }
 
 static int _vg_unignore_mdas(struct volume_group *vg, uint32_t num_to_unignore)
 {
 	struct metadata_area *mda, *tmda;
+	uint32_t mda_used_count = vg_mda_used_count(vg);
+	uint32_t mda_count = vg_mda_count(vg);
+	uint32_t mda_free_count = mda_count - mda_used_count;
+	dm_bitset_t mda_to_unignore_bs;
+	int r = 1;
 
 	if (!num_to_unignore)
 		return 1;
 
-	log_debug("Adjusting ignored mdas on vg %s: %" PRIu32 " mdas in use "
+	log_debug("Adjusting ignored mdas on vg %s: %" PRIu32 " of %" PRIu32 " mdas in use "
 		  "but %" PRIu32 " required.  Changing %" PRIu32 " flags.",
-		  vg->name, vg_mda_copies(vg), vg_mda_used_count(vg), num_to_unignore);
+		  vg->name, vg_mda_copies(vg), mda_count, mda_used_count, num_to_unignore);
+
+	if (!(mda_to_unignore_bs = _bitset_with_random_bits(vg->vgmem, mda_free_count,
+							    num_to_unignore, &vg->cmd->rand_seed)))
+		return_0;
 
-	/* FIXME: Select mdas to change at random */
 	dm_list_iterate_items_safe(mda, tmda, &vg->fid->metadata_areas_ignored)
-		if (mda_is_ignored(mda)) {
+		if (mda_is_ignored(mda) && (--mda_free_count,
+		    dm_bit(mda_to_unignore_bs, mda_free_count))) {
 			mda_set_ignored(mda, 0);
 			dm_list_move(&vg->fid->metadata_areas_in_use,
 				     &mda->list);
 			if (!--num_to_unignore)
-				return 1;
+				goto out;
 		}
 
 	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use)
-		if (mda_is_ignored(mda)) {
+		if (mda_is_ignored(mda) &&
+		    dm_bit(mda_to_unignore_bs, num_to_unignore - 1)) {
 			mda_set_ignored(mda, 0);
 			if (!--num_to_unignore)
-				return 1;
+				goto out;
 		}
 
 	log_error(INTERNAL_ERROR "Unable to find %"PRIu32" metadata areas to unignore "
 		 "on volume group %s", num_to_unignore, vg->name);
 
-	return 0;
+	r = 0;
+
+out:
+	dm_pool_free(vg->vgmem, mda_to_unignore_bs);
+	return r;
 }
 
 static int _vg_adjust_ignored_mdas(struct volume_group *vg)
@@ -1673,11 +1751,9 @@
 	log_very_verbose("Writing physical volume data to disk \"%s\"",
 			 pv_name);
 
-	if (pp->metadataignore) {
-		dm_list_iterate_items(mda, &mdas) {
+	if (pp->metadataignore)
+		dm_list_iterate_items(mda, &mdas)
 			mda_set_ignored(mda, 1);
-		}
-	}
 
 	if (!(pv_write(cmd, pv, &mdas, pp->labelsector))) {
 		log_error("Failed to write physical volume \"%s\"", pv_name);
--- LVM2/lib/misc/configure.h.in	2010/06/03 13:50:27	1.23
+++ LVM2/lib/misc/configure.h.in	2010/07/05 22:23:15	1.24
@@ -60,6 +60,9 @@
    */
 #undef HAVE_ALLOCA_H
 
+/* Define to 1 if you have the <arpa/inet.h> header file. */
+#undef HAVE_ARPA_INET_H
+
 /* Define to 1 if you have the <asm/byteorder.h> header file. */
 #undef HAVE_ASM_BYTEORDER_H
 
@@ -72,6 +75,9 @@
 /* Define to 1 if you have the <ccs.h> header file. */
 #undef HAVE_CCS_H
 
+/* Define to 1 if your system has a working `chown' function. */
+#undef HAVE_CHOWN
+
 /* Define to 1 if you have the <corosync/confdb.h> header file. */
 #undef HAVE_COROSYNC_CONFDB_H
 
@@ -96,9 +102,15 @@
 /* Define to 1 if you have the <fcntl.h> header file. */
 #undef HAVE_FCNTL_H
 
+/* Define to 1 if you have the `floor' function. */
+#undef HAVE_FLOOR
+
 /* Define to 1 if you have the `fork' function. */
 #undef HAVE_FORK
 
+/* Define to 1 if you have the `ftruncate' function. */
+#undef HAVE_FTRUNCATE
+
 /* Define to 1 if you have the `gethostname' function. */
 #undef HAVE_GETHOSTNAME
 
@@ -117,9 +129,15 @@
 /* Define to 1 if you have the `getpagesize' function. */
 #undef HAVE_GETPAGESIZE
 
+/* Define to 1 if you have the `gettimeofday' function. */
+#undef HAVE_GETTIMEOFDAY
+
 /* Define to 1 if you have the <inttypes.h> header file. */
 #undef HAVE_INTTYPES_H
 
+/* Define to 1 if you have the <langinfo.h> header file. */
+#undef HAVE_LANGINFO_H
+
 /* Define to 1 if you have the <libcman.h> header file. */
 #undef HAVE_LIBCMAN_H
 
@@ -173,6 +191,9 @@
 /* Define to 1 if you have the `mkdir' function. */
 #undef HAVE_MKDIR
 
+/* Define to 1 if you have the `mkfifo' function. */
+#undef HAVE_MKFIFO
+
 /* Define to 1 if you have a working `mmap' system call. */
 #undef HAVE_MMAP
 
@@ -191,6 +212,9 @@
 /* Define to 1 if you have the <netinet/in.h> header file. */
 #undef HAVE_NETINET_IN_H
 
+/* Define to 1 if you have the `nl_langinfo' function. */
+#undef HAVE_NL_LANGINFO
+
 /* Define to 1 if you have the <pthread.h> header file. */
 #undef HAVE_PTHREAD_H
 
@@ -200,6 +224,10 @@
 /* Define to 1 if you have the <readline/readline.h> header file. */
 #undef HAVE_READLINE_READLINE_H
 
+/* Define to 1 if your system has a GNU libc compatible `realloc' function,
+   and to 0 otherwise. */
+#undef HAVE_REALLOC
+
 /* Define to 1 to include support for realtime clock. */
 #undef HAVE_REALTIME
 
@@ -224,6 +252,9 @@
 /* Define to 1 if sepol_check_context is available. */
 #undef HAVE_SEPOL
 
+/* Define to 1 if you have the `setenv' function. */
+#undef HAVE_SETENV
+
 /* Define to 1 if you have the `setlocale' function. */
 #undef HAVE_SETLOCALE
 
@@ -261,6 +292,9 @@
 /* Define to 1 if you have the `strchr' function. */
 #undef HAVE_STRCHR
 
+/* Define to 1 if you have the `strcspn' function. */
+#undef HAVE_STRCSPN
+
 /* Define to 1 if you have the `strdup' function. */
 #undef HAVE_STRDUP
 
@@ -279,6 +313,9 @@
 /* Define to 1 if you have the `strrchr' function. */
 #undef HAVE_STRRCHR
 
+/* Define to 1 if you have the `strspn' function. */
+#undef HAVE_STRSPN
+
 /* Define to 1 if you have the `strstr' function. */
 #undef HAVE_STRSTR
 
@@ -403,6 +440,14 @@
 /* Path to lvm binary. */
 #undef LVM_PATH
 
+/* Define to 1 if `major', `minor', and `makedev' are declared in <mkdev.h>.
+   */
+#undef MAJOR_IN_MKDEV
+
+/* Define to 1 if `major', `minor', and `makedev' are declared in
+   <sysmacros.h>. */
+#undef MAJOR_IN_SYSMACROS
+
 /* Define to 1 to include built-in support for mirrors. */
 #undef MIRRORED_INTERNAL
 
@@ -471,15 +516,49 @@
 /* Define to 1 to enable synchronisation with udev processing. */
 #undef UDEV_SYNC_SUPPORT
 
+/* Define for Solaris 2.5.1 so the uint32_t typedef from <sys/synch.h>,
+   <pthread.h>, or <semaphore.h> is not used. If the typedef were allowed, the
+   #define below would cause a syntax error. */
+#undef _UINT32_T
+
+/* Define for Solaris 2.5.1 so the uint64_t typedef from <sys/synch.h>,
+   <pthread.h>, or <semaphore.h> is not used. If the typedef were allowed, the
+   #define below would cause a syntax error. */
+#undef _UINT64_T
+
+/* Define for Solaris 2.5.1 so the uint8_t typedef from <sys/synch.h>,
+   <pthread.h>, or <semaphore.h> is not used. If the typedef were allowed, the
+   #define below would cause a syntax error. */
+#undef _UINT8_T
+
 /* Define to empty if `const' does not conform to ANSI C. */
 #undef const
 
+/* Define to `int' if <sys/types.h> doesn't define. */
+#undef gid_t
+
 /* Define to `__inline__' or `__inline' if that's what the C compiler
    calls it, or to nothing if 'inline' is not supported under any name.  */
 #ifndef __cplusplus
 #undef inline
 #endif
 
+/* Define to the type of a signed integer type of width exactly 16 bits if
+   such a type exists and the standard includes do not define it. */
+#undef int16_t
+
+/* Define to the type of a signed integer type of width exactly 32 bits if
+   such a type exists and the standard includes do not define it. */
+#undef int32_t
+
+/* Define to the type of a signed integer type of width exactly 64 bits if
+   such a type exists and the standard includes do not define it. */
+#undef int64_t
+
+/* Define to the type of a signed integer type of width exactly 8 bits if such
+   a type exists and the standard includes do not define it. */
+#undef int8_t
+
 /* Define to rpl_malloc if the replacement function should be used. */
 #undef malloc
 
@@ -492,8 +571,33 @@
 /* Define to `int' if <sys/types.h> does not define. */
 #undef pid_t
 
+/* Define to rpl_realloc if the replacement function should be used. */
+#undef realloc
+
 /* Define to `unsigned int' if <sys/types.h> does not define. */
 #undef size_t
 
+/* Define to `int' if <sys/types.h> does not define. */
+#undef ssize_t
+
+/* Define to `int' if <sys/types.h> doesn't define. */
+#undef uid_t
+
+/* Define to the type of an unsigned integer type of width exactly 16 bits if
+   such a type exists and the standard includes do not define it. */
+#undef uint16_t
+
+/* Define to the type of an unsigned integer type of width exactly 32 bits if
+   such a type exists and the standard includes do not define it. */
+#undef uint32_t
+
+/* Define to the type of an unsigned integer type of width exactly 64 bits if
+   such a type exists and the standard includes do not define it. */
+#undef uint64_t
+
+/* Define to the type of an unsigned integer type of width exactly 8 bits if
+   such a type exists and the standard includes do not define it. */
+#undef uint8_t
+
 /* Define as `fork' if `vfork' does not work. */
 #undef vfork


