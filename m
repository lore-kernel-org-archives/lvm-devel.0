From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Sep 2009 21:23:03 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in li ...
Message-ID: <20090928212303.32092.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-28 21:23:03

Modified files:
	.              : WHATS_NEW configure configure.in 
	lib/misc       : configure.h.in lvm-wrappers.h 

Log message:
	Provide alternative implementation of obsolete siginterrupt().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1276&r2=1.1277
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.107&r2=1.108
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.115&r2=1.116
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-wrappers.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/WHATS_NEW	2009/09/28 17:46:15	1.1276
+++ LVM2/WHATS_NEW	2009/09/28 21:23:02	1.1277
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Provide alternative implementation of obsolete siginterrupt().
   Consolidate LV allocation into alloc_lv().
   Treat input units of both 's' and 'S' as 512-byte sectors.  (2.02.49)
   Use standard output units for 'PE Size' and 'Stripe size' in pv/lvdisplay.
--- LVM2/configure	2009/09/28 16:23:45	1.107
+++ LVM2/configure	2009/09/28 21:23:02	1.108
@@ -6536,6 +6536,107 @@
 fi
 done
 
+
+for ac_func in siginterrupt
+do
+as_ac_var=`$as_echo "ac_cv_func_$ac_func" | $as_tr_sh`
+{ $as_echo "$as_me:$LINENO: checking for $ac_func" >&5
+$as_echo_n "checking for $ac_func... " >&6; }
+if { as_var=$as_ac_var; eval "test \"\${$as_var+set}\" = set"; }; then
+  $as_echo_n "(cached) " >&6
+else
+  cat >conftest.$ac_ext <<_ACEOF
+/* confdefs.h.  */
+_ACEOF
+cat confdefs.h >>conftest.$ac_ext
+cat >>conftest.$ac_ext <<_ACEOF
+/* end confdefs.h.  */
+/* Define $ac_func to an innocuous variant, in case <limits.h> declares $ac_func.
+   For example, HP-UX 11i <limits.h> declares gettimeofday.  */
+#define $ac_func innocuous_$ac_func
+
+/* System header to define __stub macros and hopefully few prototypes,
+    which can conflict with char $ac_func (); below.
+    Prefer <limits.h> to <assert.h> if __STDC__ is defined, since
+    <limits.h> exists even on freestanding compilers.  */
+
+#ifdef __STDC__
+# include <limits.h>
+#else
+# include <assert.h>
+#endif
+
+#undef $ac_func
+
+/* Override any GCC internal prototype to avoid an error.
+   Use char because int might match the return type of a GCC
+   builtin and then its argument prototype would still apply.  */
+#ifdef __cplusplus
+extern "C"
+#endif
+char $ac_func ();
+/* The GNU C library defines this for functions which it implements
+    to always fail with ENOSYS.  Some functions are actually named
+    something starting with __ and the normal name is an alias.  */
+#if defined __stub_$ac_func || defined __stub___$ac_func
+choke me
+#endif
+
+int
+main ()
+{
+return $ac_func ();
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
+  eval "$as_ac_var=yes"
+else
+  $as_echo "$as_me: failed program was:" >&5
+sed 's/^/| /' conftest.$ac_ext >&5
+
+	eval "$as_ac_var=no"
+fi
+
+rm -rf conftest.dSYM
+rm -f core conftest.err conftest.$ac_objext conftest_ipa8_conftest.oo \
+      conftest$ac_exeext conftest.$ac_ext
+fi
+ac_res=`eval 'as_val=${'$as_ac_var'}
+		 $as_echo "$as_val"'`
+	       { $as_echo "$as_me:$LINENO: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+as_val=`eval 'as_val=${'$as_ac_var'}
+		 $as_echo "$as_val"'`
+   if test "x$as_val" = x""yes; then
+  cat >>confdefs.h <<_ACEOF
+#define `$as_echo "HAVE_$ac_func" | $as_tr_cpp` 1
+_ACEOF
+
+fi
+done
+
 # The Ultrix 4.2 mips builtin alloca declared by alloca.h only works
 # for constant arguments.  Useless!
 { $as_echo "$as_me:$LINENO: checking for working alloca.h" >&5
--- LVM2/configure.in	2009/09/28 16:23:45	1.115
+++ LVM2/configure.in	2009/09/28 21:23:02	1.116
@@ -118,6 +118,7 @@
 AC_CHECK_FUNCS([gethostname getpagesize memset mkdir rmdir munmap setlocale \
   strcasecmp strchr strdup strncasecmp strerror strrchr strstr strtol strtoul \
   uname], , [AC_MSG_ERROR(bailing out)])
+AC_CHECK_FUNCS(siginterrupt)
 AC_FUNC_ALLOCA
 AC_FUNC_CLOSEDIR_VOID
 AC_FUNC_FORK
--- LVM2/lib/misc/configure.h.in	2009/09/28 16:23:46	1.14
+++ LVM2/lib/misc/configure.h.in	2009/09/28 21:23:02	1.15
@@ -212,6 +212,9 @@
 /* Define to 1 if you have the `setlocale' function. */
 #undef HAVE_SETLOCALE
 
+/* Define to 1 if you have the `siginterrupt' function. */
+#undef HAVE_SIGINTERRUPT
+
 /* Define to 1 if you have the <signal.h> header file. */
 #undef HAVE_SIGNAL_H
 
--- LVM2/lib/misc/lvm-wrappers.h	2008/12/07 04:23:37	1.3
+++ LVM2/lib/misc/lvm-wrappers.h	2009/09/28 21:23:02	1.4
@@ -23,4 +23,19 @@
  */
 int read_urandom(void *buf, size_t len);
 
+#  ifndef HAVE_SIGINTERRUPT
+#    define siginterrupt(sig, flag) \
+	do { \
+		int ret; \
+		struct sigaction act; \
+		(void) sigaction(sig, NULL, &act); \
+		if (flag) \
+			act.sa_flags &= SA_RESTART; \
+		else \
+			act.sa_flags |= SA_RESTART; \
+		ret = sigaction(sig, &act, NULL); \
+		return ret; \
+	while (0)
+#  endif
+
 #endif


