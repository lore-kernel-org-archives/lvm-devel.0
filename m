From: meyering@sourceware.org <meyering@sourceware.org>
Date: 25 Jul 2008 08:00:41 -0000
Subject: LVM2 configure
Message-ID: <20080725080041.32055.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2008-07-25 08:00:41

Modified files:
	.              : configure 

Log message:
	configure: regenerate

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.75&r2=1.76

--- LVM2/configure	2008/07/24 14:54:26	1.75
+++ LVM2/configure	2008/07/25 08:00:40	1.76
@@ -9490,7 +9490,9 @@
 
 ################################################################################
 if test x$READLINE != xno; then
-	{ echo "$as_me:$LINENO: checking for readline in -lreadline" >&5
+	rl_found=yes
+
+{ echo "$as_me:$LINENO: checking for readline in -lreadline" >&5
 echo $ECHO_N "checking for readline in -lreadline... $ECHO_C" >&6; }
 if test "${ac_cv_lib_readline_readline+set}" = set; then
   echo $ECHO_N "(cached) $ECHO_C" >&6
@@ -9552,7 +9554,12 @@
 { echo "$as_me:$LINENO: result: $ac_cv_lib_readline_readline" >&5
 echo "${ECHO_T}$ac_cv_lib_readline_readline" >&6; }
 if test $ac_cv_lib_readline_readline = yes; then
-  rl_found=yes
+  cat >>confdefs.h <<_ACEOF
+#define HAVE_LIBREADLINE 1
+_ACEOF
+
+  LIBS="-lreadline $LIBS"
+
 else
   rl_found=no
 fi
@@ -9574,9 +9581,13 @@
 " >&2;}
    { (exit 1); exit 1; }; }
 	if test $rl_found = yes; then
-		{ echo "$as_me:$LINENO: checking for rl_completion_matches" >&5
-echo $ECHO_N "checking for rl_completion_matches... $ECHO_C" >&6; }
-if test "${ac_cv_func_rl_completion_matches+set}" = set; then
+
+for ac_func in rl_completion_matches
+do
+as_ac_var=`echo "ac_cv_func_$ac_func" | $as_tr_sh`
+{ echo "$as_me:$LINENO: checking for $ac_func" >&5
+echo $ECHO_N "checking for $ac_func... $ECHO_C" >&6; }
+if { as_var=$as_ac_var; eval "test \"\${$as_var+set}\" = set"; }; then
   echo $ECHO_N "(cached) $ECHO_C" >&6
 else
   cat >conftest.$ac_ext <<_ACEOF
@@ -9585,12 +9596,12 @@
 cat confdefs.h >>conftest.$ac_ext
 cat >>conftest.$ac_ext <<_ACEOF
 /* end confdefs.h.  */
-/* Define rl_completion_matches to an innocuous variant, in case <limits.h> declares rl_completion_matches.
+/* Define $ac_func to an innocuous variant, in case <limits.h> declares $ac_func.
    For example, HP-UX 11i <limits.h> declares gettimeofday.  */
-#define rl_completion_matches innocuous_rl_completion_matches
+#define $ac_func innocuous_$ac_func
 
 /* System header to define __stub macros and hopefully few prototypes,
-    which can conflict with char rl_completion_matches (); below.
+    which can conflict with char $ac_func (); below.
     Prefer <limits.h> to <assert.h> if __STDC__ is defined, since
     <limits.h> exists even on freestanding compilers.  */
 
@@ -9600,7 +9611,7 @@
 # include <assert.h>
 #endif
 
-#undef rl_completion_matches
+#undef $ac_func
 
 /* Override any GCC internal prototype to avoid an error.
    Use char because int might match the return type of a GCC
@@ -9608,18 +9619,18 @@
 #ifdef __cplusplus
 extern "C"
 #endif
-char rl_completion_matches ();
+char $ac_func ();
 /* The GNU C library defines this for functions which it implements
     to always fail with ENOSYS.  Some functions are actually named
     something starting with __ and the normal name is an alias.  */
-#if defined __stub_rl_completion_matches || defined __stub___rl_completion_matches
+#if defined __stub_$ac_func || defined __stub___$ac_func
 choke me
 #endif
 
 int
 main ()
 {
-return rl_completion_matches ();
+return $ac_func ();
   ;
   return 0;
 }
@@ -9642,26 +9653,27 @@
 	 test ! -s conftest.err
        } && test -s conftest$ac_exeext &&
        $as_test_x conftest$ac_exeext; then
-  ac_cv_func_rl_completion_matches=yes
+  eval "$as_ac_var=yes"
 else
   echo "$as_me: failed program was:" >&5
 sed 's/^/| /' conftest.$ac_ext >&5
 
-	ac_cv_func_rl_completion_matches=no
+	eval "$as_ac_var=no"
 fi
 
 rm -f core conftest.err conftest.$ac_objext conftest_ipa8_conftest.oo \
       conftest$ac_exeext conftest.$ac_ext
 fi
-{ echo "$as_me:$LINENO: result: $ac_cv_func_rl_completion_matches" >&5
-echo "${ECHO_T}$ac_cv_func_rl_completion_matches" >&6; }
-if test $ac_cv_func_rl_completion_matches = yes; then
-
-cat >>confdefs.h <<\_ACEOF
-#define HAVE_RL_COMPLETION_MATCHES 1
+ac_res=`eval echo '${'$as_ac_var'}'`
+	       { echo "$as_me:$LINENO: result: $ac_res" >&5
+echo "${ECHO_T}$ac_res" >&6; }
+if test `eval echo '${'$as_ac_var'}'` = yes; then
+  cat >>confdefs.h <<_ACEOF
+#define `echo "HAVE_$ac_func" | $as_tr_cpp` 1
 _ACEOF
 
 fi
+done
 
 
 cat >>confdefs.h <<\_ACEOF


