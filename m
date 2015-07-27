From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 27 Jul 2015 13:28:14 +0000 (UTC)
Subject: master - configure: Add missing checks.
Message-ID: <20150727132814.E1D2260EFA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1568ed4d20c2ff67e6cf3e17e158d5153e5f48f8
Commit:        1568ed4d20c2ff67e6cf3e17e158d5153e5f48f8
Parent:        3934ade5a22367f31bb951ebb2a2cb1bfd326f8c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jul 27 14:26:56 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jul 27 14:26:56 2015 +0100

configure: Add missing checks.

---
 configure               |  756 +++++++++++++++++++++++++++++++++++++++--------
 configure.in            |   44 ++-
 lib/misc/configure.h.in |   52 ++++
 3 files changed, 716 insertions(+), 136 deletions(-)

diff --git a/configure b/configure
index 139f332..070f3a9 100755
--- a/configure
+++ b/configure
@@ -620,6 +620,7 @@ ac_includes_default="\
 #endif"
 
 ac_header_list=
+ac_func_list=
 ac_default_prefix=/usr
 ac_subst_vars='LTLIBOBJS
 usrsbindir
@@ -2252,116 +2253,116 @@ $as_echo "$ac_res" >&6; }
 
 } # ac_fn_c_check_header_compile
 
-# ac_fn_c_check_member LINENO AGGR MEMBER VAR INCLUDES
-# ----------------------------------------------------
-# Tries to find if the field MEMBER exists in type AGGR, after including
-# INCLUDES, setting cache variable VAR accordingly.
-ac_fn_c_check_member ()
+# ac_fn_c_check_type LINENO TYPE VAR INCLUDES
+# -------------------------------------------
+# Tests whether TYPE exists after having included INCLUDES, setting cache
+# variable VAR accordingly.
+ac_fn_c_check_type ()
 {
   as_lineno=${as_lineno-"$1"} as_lineno_stack=as_lineno_stack=$as_lineno_stack
-  { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $2.$3" >&5
-$as_echo_n "checking for $2.$3... " >&6; }
-if eval \${$4+:} false; then :
+  { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $2" >&5
+$as_echo_n "checking for $2... " >&6; }
+if eval \${$3+:} false; then :
   $as_echo_n "(cached) " >&6
 else
+  eval "$3=no"
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-$5
+$4
 int
 main ()
 {
-static $2 ac_aggr;
-if (ac_aggr.$3)
-return 0;
+if (sizeof ($2))
+	 return 0;
   ;
   return 0;
 }
 _ACEOF
 if ac_fn_c_try_compile "$LINENO"; then :
-  eval "$4=yes"
-else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-$5
+$4
 int
 main ()
 {
-static $2 ac_aggr;
-if (sizeof ac_aggr.$3)
-return 0;
+if (sizeof (($2)))
+	    return 0;
   ;
   return 0;
 }
 _ACEOF
 if ac_fn_c_try_compile "$LINENO"; then :
-  eval "$4=yes"
+
 else
-  eval "$4=no"
+  eval "$3=yes"
 fi
 rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
 fi
 rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
 fi
-eval ac_res=\$$4
+eval ac_res=\$$3
 	       { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
 $as_echo "$ac_res" >&6; }
   eval $as_lineno_stack; ${as_lineno_stack:+:} unset as_lineno
 
-} # ac_fn_c_check_member
+} # ac_fn_c_check_type
 
-# ac_fn_c_check_type LINENO TYPE VAR INCLUDES
-# -------------------------------------------
-# Tests whether TYPE exists after having included INCLUDES, setting cache
-# variable VAR accordingly.
-ac_fn_c_check_type ()
+# ac_fn_c_check_member LINENO AGGR MEMBER VAR INCLUDES
+# ----------------------------------------------------
+# Tries to find if the field MEMBER exists in type AGGR, after including
+# INCLUDES, setting cache variable VAR accordingly.
+ac_fn_c_check_member ()
 {
   as_lineno=${as_lineno-"$1"} as_lineno_stack=as_lineno_stack=$as_lineno_stack
-  { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $2" >&5
-$as_echo_n "checking for $2... " >&6; }
-if eval \${$3+:} false; then :
+  { $as_echo "$as_me:${as_lineno-$LINENO}: checking for $2.$3" >&5
+$as_echo_n "checking for $2.$3... " >&6; }
+if eval \${$4+:} false; then :
   $as_echo_n "(cached) " >&6
 else
-  eval "$3=no"
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-$4
+$5
 int
 main ()
 {
-if (sizeof ($2))
-	 return 0;
+static $2 ac_aggr;
+if (ac_aggr.$3)
+return 0;
   ;
   return 0;
 }
 _ACEOF
 if ac_fn_c_try_compile "$LINENO"; then :
+  eval "$4=yes"
+else
   cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
-$4
+$5
 int
 main ()
 {
-if (sizeof (($2)))
-	    return 0;
+static $2 ac_aggr;
+if (sizeof ac_aggr.$3)
+return 0;
   ;
   return 0;
 }
 _ACEOF
 if ac_fn_c_try_compile "$LINENO"; then :
-
+  eval "$4=yes"
 else
-  eval "$3=yes"
+  eval "$4=no"
 fi
 rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
 fi
 rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
 fi
-eval ac_res=\$$3
+eval ac_res=\$$4
 	       { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
 $as_echo "$ac_res" >&6; }
   eval $as_lineno_stack; ${as_lineno_stack:+:} unset as_lineno
 
-} # ac_fn_c_check_type
+} # ac_fn_c_check_member
 
 # ac_fn_c_find_intX_t LINENO BITS VAR
 # -----------------------------------
@@ -2559,6 +2560,52 @@ $as_echo "$ac_res" >&6; }
   eval $as_lineno_stack; ${as_lineno_stack:+:} unset as_lineno
 
 } # ac_fn_c_check_func
+
+# ac_fn_c_check_decl LINENO SYMBOL VAR INCLUDES
+# ---------------------------------------------
+# Tests whether SYMBOL is declared in INCLUDES, setting cache variable VAR
+# accordingly.
+ac_fn_c_check_decl ()
+{
+  as_lineno=${as_lineno-"$1"} as_lineno_stack=as_lineno_stack=$as_lineno_stack
+  as_decl_name=`echo $2|sed 's/ *(.*//'`
+  as_decl_use=`echo $2|sed -e 's/(/((/' -e 's/)/) 0&/' -e 's/,/) 0& (/g'`
+  { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $as_decl_name is declared" >&5
+$as_echo_n "checking whether $as_decl_name is declared... " >&6; }
+if eval \${$3+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+$4
+int
+main ()
+{
+#ifndef $as_decl_name
+#ifdef __cplusplus
+  (void) $as_decl_use;
+#else
+  (void) $as_decl_name;
+#endif
+#endif
+
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_compile "$LINENO"; then :
+  eval "$3=yes"
+else
+  eval "$3=no"
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+fi
+eval ac_res=\$$3
+	       { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_res" >&5
+$as_echo "$ac_res" >&6; }
+  eval $as_lineno_stack; ${as_lineno_stack:+:} unset as_lineno
+
+} # ac_fn_c_check_decl
 cat >config.log <<_ACEOF
 This file contains any messages produced by compilers while
 running configure, to aid debugging if configure makes a mistake.
@@ -2843,8 +2890,10 @@ $as_echo "$as_me: creating cache $cache_file" >&6;}
   >$cache_file
 fi
 
-as_fn_append ac_header_list " stdlib.h"
+as_fn_append ac_header_list " sys/time.h"
 as_fn_append ac_header_list " unistd.h"
+as_fn_append ac_func_list " alarm"
+as_fn_append ac_header_list " stdlib.h"
 as_fn_append ac_header_list " sys/param.h"
 # Check that the precious variables saved in the cache have kept the same
 # value.
@@ -5381,6 +5430,99 @@ fi
   fi
 fi
 
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for stdbool.h that conforms to C99" >&5
+$as_echo_n "checking for stdbool.h that conforms to C99... " >&6; }
+if ${ac_cv_header_stdbool_h+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+
+             #include <stdbool.h>
+             #ifndef bool
+              "error: bool is not defined"
+             #endif
+             #ifndef false
+              "error: false is not defined"
+             #endif
+             #if false
+              "error: false is not 0"
+             #endif
+             #ifndef true
+              "error: true is not defined"
+             #endif
+             #if true != 1
+              "error: true is not 1"
+             #endif
+             #ifndef __bool_true_false_are_defined
+              "error: __bool_true_false_are_defined is not defined"
+             #endif
+
+             struct s { _Bool s: 1; _Bool t; } s;
+
+             char a[true == 1 ? 1 : -1];
+             char b[false == 0 ? 1 : -1];
+             char c[__bool_true_false_are_defined == 1 ? 1 : -1];
+             char d[(bool) 0.5 == true ? 1 : -1];
+             /* See body of main program for 'e'.  */
+             char f[(_Bool) 0.0 == false ? 1 : -1];
+             char g[true];
+             char h[sizeof (_Bool)];
+             char i[sizeof s.t];
+             enum { j = false, k = true, l = false * true, m = true * 256 };
+             /* The following fails for
+                HP aC++/ANSI C B3910B A.05.55 [Dec 04 2003]. */
+             _Bool n[m];
+             char o[sizeof n == m * sizeof n[0] ? 1 : -1];
+             char p[-1 - (_Bool) 0 < 0 && -1 - (bool) 0 < 0 ? 1 : -1];
+             /* Catch a bug in an HP-UX C compiler.  See
+                http://gcc.gnu.org/ml/gcc-patches/2003-12/msg02303.html
+                http://lists.gnu.org/archive/html/bug-coreutils/2005-11/msg00161.html
+              */
+             _Bool q = true;
+             _Bool *pq = &q;
+
+int
+main ()
+{
+
+             bool e = &s;
+             *pq |= q;
+             *pq |= ! q;
+             /* Refer to every declared value, to avoid compiler optimizations.  */
+             return (!a + !b + !c + !d + !e + !f + !g + !h + !i + !!j + !k + !!l
+                     + !m + !n + !o + !p + !q + !pq);
+
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_compile "$LINENO"; then :
+  ac_cv_header_stdbool_h=yes
+else
+  ac_cv_header_stdbool_h=no
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_header_stdbool_h" >&5
+$as_echo "$ac_cv_header_stdbool_h" >&6; }
+   ac_fn_c_check_type "$LINENO" "_Bool" "ac_cv_type__Bool" "$ac_includes_default"
+if test "x$ac_cv_type__Bool" = xyes; then :
+
+cat >>confdefs.h <<_ACEOF
+#define HAVE__BOOL 1
+_ACEOF
+
+
+fi
+
+
+if test $ac_cv_header_stdbool_h = yes; then
+
+$as_echo "#define HAVE_STDBOOL_H 1" >>confdefs.h
+
+fi
+
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for ANSI C header files" >&5
 $as_echo_n "checking for ANSI C header files... " >&6; }
 if ${ac_cv_header_stdc+:} false; then :
@@ -5570,9 +5712,12 @@ $as_echo "#define TIME_WITH_SYS_TIME 1" >>confdefs.h
 fi
 
 
-for ac_header in locale.h stddef.h syslog.h sys/file.h sys/time.h assert.h \
-  langinfo.h libgen.h signal.h sys/mman.h sys/resource.h sys/utsname.h \
-  sys/wait.h time.h
+for ac_header in assert.h ctype.h dirent.h errno.h fcntl.h float.h \
+  getopt.h inttypes.h langinfo.h libgen.h limits.h locale.h paths.h \
+  signal.h stdarg.h stddef.h stdio.h stdlib.h string.h sys/file.h \
+  sys/ioctl.h syslog.h sys/mman.h sys/param.h sys/resource.h sys/stat.h \
+  sys/time.h sys/types.h sys/utsname.h sys/wait.h time.h \
+  unistd.h
 do :
   as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
 ac_fn_c_check_header_mongrel "$LINENO" "$ac_header" "$as_ac_Header" "$ac_includes_default"
@@ -5588,9 +5733,7 @@ fi
 done
 
 
-case "$host_os" in
-	linux*)
-		for ac_header in asm/byteorder.h linux/fs.h malloc.h
+for ac_header in termios.h sys/statvfs.h
 do :
   as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
 ac_fn_c_check_header_mongrel "$LINENO" "$ac_header" "$as_ac_Header" "$ac_includes_default"
@@ -5599,14 +5742,14 @@ if eval test \"x\$"$as_ac_Header"\" = x"yes"; then :
 #define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
 _ACEOF
 
-else
-  as_fn_error $? "bailing out" "$LINENO" 5
 fi
 
 done
- ;;
-	darwin*)
-		for ac_header in machine/endian.h sys/disk.h
+
+
+case "$host_os" in
+	linux*)
+		for ac_header in asm/byteorder.h linux/fs.h malloc.h
 do :
   as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
 ac_fn_c_check_header_mongrel "$LINENO" "$ac_header" "$as_ac_Header" "$ac_includes_default"
@@ -5621,11 +5764,8 @@ fi
 
 done
  ;;
-esac
-
-for ac_header in ctype.h dirent.h errno.h fcntl.h getopt.h inttypes.h limits.h \
-  stdarg.h stdio.h stdlib.h string.h sys/ioctl.h sys/param.h sys/stat.h \
-  sys/types.h unistd.h
+	darwin*)
+		for ac_header in machine/endian.h sys/disk.h
 do :
   as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
 ac_fn_c_check_header_mongrel "$LINENO" "$ac_header" "$as_ac_Header" "$ac_includes_default"
@@ -5639,20 +5779,8 @@ else
 fi
 
 done
-
-for ac_header in termios.h sys/statvfs.h
-do :
-  as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
-ac_fn_c_check_header_mongrel "$LINENO" "$ac_header" "$as_ac_Header" "$ac_includes_default"
-if eval test \"x\$"$as_ac_Header"\" = x"yes"; then :
-  cat >>confdefs.h <<_ACEOF
-#define `$as_echo "HAVE_$ac_header" | $as_tr_cpp` 1
-_ACEOF
-
-fi
-
-done
-
+ ;;
+esac
 
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for an ANSI C-conforming const" >&5
@@ -5788,6 +5916,51 @@ _ACEOF
 
 fi
 
+ac_fn_c_check_type "$LINENO" "ptrdiff_t" "ac_cv_type_ptrdiff_t" "$ac_includes_default"
+if test "x$ac_cv_type_ptrdiff_t" = xyes; then :
+
+cat >>confdefs.h <<_ACEOF
+#define HAVE_PTRDIFF_T 1
+_ACEOF
+
+
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether struct tm is in sys/time.h or time.h" >&5
+$as_echo_n "checking whether struct tm is in sys/time.h or time.h... " >&6; }
+if ${ac_cv_struct_tm+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#include <sys/types.h>
+#include <time.h>
+
+int
+main ()
+{
+struct tm tm;
+				     int *p = &tm.tm_sec;
+				     return !p;
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_compile "$LINENO"; then :
+  ac_cv_struct_tm=time.h
+else
+  ac_cv_struct_tm=sys/time.h
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_struct_tm" >&5
+$as_echo "$ac_cv_struct_tm" >&6; }
+if test $ac_cv_struct_tm = sys/time.h; then
+
+$as_echo "#define TM_IN_SYS_TIME 1" >>confdefs.h
+
+fi
+
 ac_fn_c_check_type "$LINENO" "off_t" "ac_cv_type_off_t" "$ac_includes_default"
 if test "x$ac_cv_type_off_t" = xyes; then :
 
@@ -6004,57 +6177,12 @@ _ACEOF
 ;;
   esac
 
-ac_fn_c_check_member "$LINENO" "struct stat" "st_rdev" "ac_cv_member_struct_stat_st_rdev" "$ac_includes_default"
-if test "x$ac_cv_member_struct_stat_st_rdev" = xyes; then :
-
-cat >>confdefs.h <<_ACEOF
-#define HAVE_STRUCT_STAT_ST_RDEV 1
-_ACEOF
-
-
-fi
-
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether struct tm is in sys/time.h or time.h" >&5
-$as_echo_n "checking whether struct tm is in sys/time.h or time.h... " >&6; }
-if ${ac_cv_struct_tm+:} false; then :
-  $as_echo_n "(cached) " >&6
-else
-  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
-/* end confdefs.h.  */
-#include <sys/types.h>
-#include <time.h>
-
-int
-main ()
-{
-struct tm tm;
-				     int *p = &tm.tm_sec;
-				     return !p;
-  ;
-  return 0;
-}
-_ACEOF
-if ac_fn_c_try_compile "$LINENO"; then :
-  ac_cv_struct_tm=time.h
-else
-  ac_cv_struct_tm=sys/time.h
-fi
-rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
-fi
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_struct_tm" >&5
-$as_echo "$ac_cv_struct_tm" >&6; }
-if test $ac_cv_struct_tm = sys/time.h; then
-
-$as_echo "#define TM_IN_SYS_TIME 1" >>confdefs.h
-
-fi
-
 
 ################################################################################
-for ac_func in ftruncate gethostname getpagesize \
-  gettimeofday memset mkdir mkfifo rmdir munmap nl_langinfo setenv setlocale \
-  strcasecmp strchr strcspn strspn strdup strncasecmp strerror strrchr \
-  strstr strtol strtoul uname
+for ac_func in ftruncate gethostname getpagesize gettimeofday localtime_r \
+  memchr memset mkdir mkfifo munmap nl_langinfo realpath rmdir setenv \
+  setlocale strcasecmp strchr strcspn strdup strerror strncasecmp strndup \
+  strrchr strspn strstr strtol strtoul uname
 do :
   as_ac_var=`$as_echo "ac_cv_func_$ac_func" | $as_tr_sh`
 ac_fn_c_check_func "$LINENO" "$ac_func" "$as_ac_var"
@@ -6835,6 +6963,250 @@ done
 
 
 
+  for ac_func in $ac_func_list
+do :
+  as_ac_var=`$as_echo "ac_cv_func_$ac_func" | $as_tr_sh`
+ac_fn_c_check_func "$LINENO" "$ac_func" "$as_ac_var"
+if eval test \"x\$"$as_ac_var"\" = x"yes"; then :
+  cat >>confdefs.h <<_ACEOF
+#define `$as_echo "HAVE_$ac_func" | $as_tr_cpp` 1
+_ACEOF
+
+fi
+done
+
+
+
+
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for working mktime" >&5
+$as_echo_n "checking for working mktime... " >&6; }
+if ${ac_cv_func_working_mktime+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  if test "$cross_compiling" = yes; then :
+  ac_cv_func_working_mktime=no
+else
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+/* Test program from Paul Eggert and Tony Leneis.  */
+#ifdef TIME_WITH_SYS_TIME
+# include <sys/time.h>
+# include <time.h>
+#else
+# ifdef HAVE_SYS_TIME_H
+#  include <sys/time.h>
+# else
+#  include <time.h>
+# endif
+#endif
+
+#include <limits.h>
+#include <stdlib.h>
+
+#ifdef HAVE_UNISTD_H
+# include <unistd.h>
+#endif
+
+#ifndef HAVE_ALARM
+# define alarm(X) /* empty */
+#endif
+
+/* Work around redefinition to rpl_putenv by other config tests.  */
+#undef putenv
+
+static time_t time_t_max;
+static time_t time_t_min;
+
+/* Values we'll use to set the TZ environment variable.  */
+static const char *tz_strings[] = {
+  (const char *) 0, "TZ=GMT0", "TZ=JST-9",
+  "TZ=EST+3EDT+2,M10.1.0/00:00:00,M2.3.0/00:00:00"
+};
+#define N_STRINGS (sizeof (tz_strings) / sizeof (tz_strings[0]))
+
+/* Return 0 if mktime fails to convert a date in the spring-forward gap.
+   Based on a problem report from Andreas Jaeger.  */
+static int
+spring_forward_gap ()
+{
+  /* glibc (up to about 1998-10-07) failed this test. */
+  struct tm tm;
+
+  /* Use the portable POSIX.1 specification "TZ=PST8PDT,M4.1.0,M10.5.0"
+     instead of "TZ=America/Vancouver" in order to detect the bug even
+     on systems that don't support the Olson extension, or don't have the
+     full zoneinfo tables installed.  */
+  putenv ((char*) "TZ=PST8PDT,M4.1.0,M10.5.0");
+
+  tm.tm_year = 98;
+  tm.tm_mon = 3;
+  tm.tm_mday = 5;
+  tm.tm_hour = 2;
+  tm.tm_min = 0;
+  tm.tm_sec = 0;
+  tm.tm_isdst = -1;
+  return mktime (&tm) != (time_t) -1;
+}
+
+static int
+mktime_test1 (time_t now)
+{
+  struct tm *lt;
+  return ! (lt = localtime (&now)) || mktime (lt) == now;
+}
+
+static int
+mktime_test (time_t now)
+{
+  return (mktime_test1 (now)
+	  && mktime_test1 ((time_t) (time_t_max - now))
+	  && mktime_test1 ((time_t) (time_t_min + now)));
+}
+
+static int
+irix_6_4_bug ()
+{
+  /* Based on code from Ariel Faigon.  */
+  struct tm tm;
+  tm.tm_year = 96;
+  tm.tm_mon = 3;
+  tm.tm_mday = 0;
+  tm.tm_hour = 0;
+  tm.tm_min = 0;
+  tm.tm_sec = 0;
+  tm.tm_isdst = -1;
+  mktime (&tm);
+  return tm.tm_mon == 2 && tm.tm_mday == 31;
+}
+
+static int
+bigtime_test (int j)
+{
+  struct tm tm;
+  time_t now;
+  tm.tm_year = tm.tm_mon = tm.tm_mday = tm.tm_hour = tm.tm_min = tm.tm_sec = j;
+  now = mktime (&tm);
+  if (now != (time_t) -1)
+    {
+      struct tm *lt = localtime (&now);
+      if (! (lt
+	     && lt->tm_year == tm.tm_year
+	     && lt->tm_mon == tm.tm_mon
+	     && lt->tm_mday == tm.tm_mday
+	     && lt->tm_hour == tm.tm_hour
+	     && lt->tm_min == tm.tm_min
+	     && lt->tm_sec == tm.tm_sec
+	     && lt->tm_yday == tm.tm_yday
+	     && lt->tm_wday == tm.tm_wday
+	     && ((lt->tm_isdst < 0 ? -1 : 0 < lt->tm_isdst)
+		  == (tm.tm_isdst < 0 ? -1 : 0 < tm.tm_isdst))))
+	return 0;
+    }
+  return 1;
+}
+
+static int
+year_2050_test ()
+{
+  /* The correct answer for 2050-02-01 00:00:00 in Pacific time,
+     ignoring leap seconds.  */
+  unsigned long int answer = 2527315200UL;
+
+  struct tm tm;
+  time_t t;
+  tm.tm_year = 2050 - 1900;
+  tm.tm_mon = 2 - 1;
+  tm.tm_mday = 1;
+  tm.tm_hour = tm.tm_min = tm.tm_sec = 0;
+  tm.tm_isdst = -1;
+
+  /* Use the portable POSIX.1 specification "TZ=PST8PDT,M4.1.0,M10.5.0"
+     instead of "TZ=America/Vancouver" in order to detect the bug even
+     on systems that don't support the Olson extension, or don't have the
+     full zoneinfo tables installed.  */
+  putenv ((char*) "TZ=PST8PDT,M4.1.0,M10.5.0");
+
+  t = mktime (&tm);
+
+  /* Check that the result is either a failure, or close enough
+     to the correct answer that we can assume the discrepancy is
+     due to leap seconds.  */
+  return (t == (time_t) -1
+	  || (0 < t && answer - 120 <= t && t <= answer + 120));
+}
+
+int
+main ()
+{
+  time_t t, delta;
+  int i, j;
+
+  /* This test makes some buggy mktime implementations loop.
+     Give up after 60 seconds; a mktime slower than that
+     isn't worth using anyway.  */
+  alarm (60);
+
+  for (;;)
+    {
+      t = (time_t_max << 1) + 1;
+      if (t <= time_t_max)
+	break;
+      time_t_max = t;
+    }
+  time_t_min = - ((time_t) ~ (time_t) 0 == (time_t) -1) - time_t_max;
+
+  delta = time_t_max / 997; /* a suitable prime number */
+  for (i = 0; i < N_STRINGS; i++)
+    {
+      if (tz_strings[i])
+	putenv ((char*) tz_strings[i]);
+
+      for (t = 0; t <= time_t_max - delta; t += delta)
+	if (! mktime_test (t))
+	  return 1;
+      if (! (mktime_test ((time_t) 1)
+	     && mktime_test ((time_t) (60 * 60))
+	     && mktime_test ((time_t) (60 * 60 * 24))))
+	return 1;
+
+      for (j = 1; ; j <<= 1)
+	if (! bigtime_test (j))
+	  return 1;
+	else if (INT_MAX / 2 < j)
+	  break;
+      if (! bigtime_test (INT_MAX))
+	return 1;
+    }
+  return ! (irix_6_4_bug () && spring_forward_gap () && year_2050_test ());
+}
+_ACEOF
+if ac_fn_c_try_run "$LINENO"; then :
+  ac_cv_func_working_mktime=yes
+else
+  ac_cv_func_working_mktime=no
+fi
+rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
+  conftest.$ac_objext conftest.beam conftest.$ac_ext
+fi
+
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_working_mktime" >&5
+$as_echo "$ac_cv_func_working_mktime" >&6; }
+if test $ac_cv_func_working_mktime = no; then
+  case " $LIBOBJS " in
+  *" mktime.$ac_objext "* ) ;;
+  *) LIBOBJS="$LIBOBJS mktime.$ac_objext"
+ ;;
+esac
+
+fi
+
+
+
+
+
+
 for ac_func in getpagesize
 do :
   ac_fn_c_check_func "$LINENO" "getpagesize" "ac_cv_func_getpagesize"
@@ -12909,6 +13281,147 @@ done
 
 fi
 
+if test "$BUILD_CMIRRORD" = yes; then
+	for ac_func in atexit
+do :
+  ac_fn_c_check_func "$LINENO" "atexit" "ac_cv_func_atexit"
+if test "x$ac_cv_func_atexit" = xyes; then :
+  cat >>confdefs.h <<_ACEOF
+#define HAVE_ATEXIT 1
+_ACEOF
+
+else
+  hard_bailout
+fi
+done
+
+fi
+
+if test "$BUILD_LVMLOCKD" = yes; then
+	for ac_func in clock_gettime strtoull
+do :
+  as_ac_var=`$as_echo "ac_cv_func_$ac_func" | $as_tr_sh`
+ac_fn_c_check_func "$LINENO" "$ac_func" "$as_ac_var"
+if eval test \"x\$"$as_ac_var"\" = x"yes"; then :
+  cat >>confdefs.h <<_ACEOF
+#define `$as_echo "HAVE_$ac_func" | $as_tr_cpp` 1
+_ACEOF
+
+else
+  hard_bailout
+fi
+done
+
+fi
+
+if test "$BUILD_LVMPOLLD" = yes; then
+	for ac_func in strpbrk
+do :
+  ac_fn_c_check_func "$LINENO" "strpbrk" "ac_cv_func_strpbrk"
+if test "x$ac_cv_func_strpbrk" = xyes; then :
+  cat >>confdefs.h <<_ACEOF
+#define HAVE_STRPBRK 1
+_ACEOF
+
+else
+  hard_bailout
+fi
+done
+
+	ac_fn_c_check_decl "$LINENO" "strerror_r" "ac_cv_have_decl_strerror_r" "$ac_includes_default"
+if test "x$ac_cv_have_decl_strerror_r" = xyes; then :
+  ac_have_decl=1
+else
+  ac_have_decl=0
+fi
+
+cat >>confdefs.h <<_ACEOF
+#define HAVE_DECL_STRERROR_R $ac_have_decl
+_ACEOF
+
+for ac_func in strerror_r
+do :
+  ac_fn_c_check_func "$LINENO" "strerror_r" "ac_cv_func_strerror_r"
+if test "x$ac_cv_func_strerror_r" = xyes; then :
+  cat >>confdefs.h <<_ACEOF
+#define HAVE_STRERROR_R 1
+_ACEOF
+
+fi
+done
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether strerror_r returns char *" >&5
+$as_echo_n "checking whether strerror_r returns char *... " >&6; }
+if ${ac_cv_func_strerror_r_char_p+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+
+    ac_cv_func_strerror_r_char_p=no
+    if test $ac_cv_have_decl_strerror_r = yes; then
+      cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+$ac_includes_default
+int
+main ()
+{
+
+	  char buf[100];
+	  char x = *strerror_r (0, buf, sizeof buf);
+	  char *p = strerror_r (0, buf, sizeof buf);
+	  return !p || x;
+
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_compile "$LINENO"; then :
+  ac_cv_func_strerror_r_char_p=yes
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+    else
+      # strerror_r is not declared.  Choose between
+      # systems that have relatively inaccessible declarations for the
+      # function.  BeOS and DEC UNIX 4.0 fall in this category, but the
+      # former has a strerror_r that returns char*, while the latter
+      # has a strerror_r that returns `int'.
+      # This test should segfault on the DEC system.
+      if test "$cross_compiling" = yes; then :
+  :
+else
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+$ac_includes_default
+	extern char *strerror_r ();
+int
+main ()
+{
+char buf[100];
+	  char x = *strerror_r (0, buf, sizeof buf);
+	  return ! isalpha (x);
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_run "$LINENO"; then :
+  ac_cv_func_strerror_r_char_p=yes
+fi
+rm -f core *.core core.conftest.* gmon.out bb.out conftest$ac_exeext \
+  conftest.$ac_objext conftest.beam conftest.$ac_ext
+fi
+
+    fi
+
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_func_strerror_r_char_p" >&5
+$as_echo "$ac_cv_func_strerror_r_char_p" >&6; }
+if test $ac_cv_func_strerror_r_char_p = yes; then
+
+$as_echo "#define STRERROR_R_CHAR_P 1" >>confdefs.h
+
+fi
+
+fi
+
 if test "$CLVMD" != none; then
 	for ac_header in mntent.h netdb.h netinet/in.h pthread.h search.h sys/mount.h sys/socket.h sys/uio.h sys/un.h utmpx.h
 do :
@@ -13625,6 +14138,7 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdev
 mapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan
 _systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
diff --git a/configure.in b/configure.in
index 7bb18a4..e64baa3 100644
--- a/configure.in
+++ b/configure.in
@@ -91,14 +91,19 @@ AC_PATH_TOOL(CSCOPE_CMD, cscope)
 dnl -- Check for header files.
 AC_HEADER_DIRENT
 AC_HEADER_MAJOR
+AC_HEADER_STDBOOL
 AC_HEADER_STDC
 AC_HEADER_SYS_WAIT
 AC_HEADER_TIME
 
-AC_CHECK_HEADERS([locale.h stddef.h syslog.h sys/file.h sys/time.h assert.h \
-  langinfo.h libgen.h signal.h sys/mman.h sys/resource.h sys/utsname.h \
-  sys/wait.h time.h], ,
-  [AC_MSG_ERROR(bailing out)])
+AC_CHECK_HEADERS([assert.h ctype.h dirent.h errno.h fcntl.h float.h \
+  getopt.h inttypes.h langinfo.h libgen.h limits.h locale.h paths.h \
+  signal.h stdarg.h stddef.h stdio.h stdlib.h string.h sys/file.h \
+  sys/ioctl.h syslog.h sys/mman.h sys/param.h sys/resource.h sys/stat.h \
+  sys/time.h sys/types.h sys/utsname.h sys/wait.h time.h \
+  unistd.h], , [AC_MSG_ERROR(bailing out)])
+
+AC_CHECK_HEADERS(termios.h sys/statvfs.h)
 
 case "$host_os" in
 	linux*)
@@ -107,16 +112,13 @@ case "$host_os" in
 		AC_CHECK_HEADERS(machine/endian.h sys/disk.h,,AC_MSG_ERROR(bailing out)) ;;
 esac
 
-AC_CHECK_HEADERS([ctype.h dirent.h errno.h fcntl.h getopt.h inttypes.h limits.h \
-  stdarg.h stdio.h stdlib.h string.h sys/ioctl.h sys/param.h sys/stat.h \
-  sys/types.h unistd.h], , [AC_MSG_ERROR(bailing out)])
-AC_CHECK_HEADERS(termios.h sys/statvfs.h)
-
 ################################################################################
 dnl -- Check for typedefs, structures, and compiler characteristics.
 AC_C_CONST
 AC_C_INLINE
 AC_CHECK_MEMBERS([struct stat.st_rdev])
+AC_CHECK_TYPES([ptrdiff_t])
+AC_STRUCT_TM
 AC_TYPE_OFF_T
 AC_TYPE_PID_T
 AC_TYPE_SIGNAL
@@ -132,15 +134,13 @@ AC_TYPE_UINT8_T
 AC_TYPE_UINT16_T
 AC_TYPE_UINT32_T
 AC_TYPE_UINT64_T
-AC_CHECK_MEMBERS([struct stat.st_rdev])
-AC_STRUCT_TM
 
 ################################################################################
 dnl -- Check for functions
-AC_CHECK_FUNCS([ftruncate gethostname getpagesize \
-  gettimeofday memset mkdir mkfifo rmdir munmap nl_langinfo setenv setlocale \
-  strcasecmp strchr strcspn strspn strdup strncasecmp strerror strrchr \
-  strstr strtol strtoul uname], , [AC_MSG_ERROR(bailing out)])
+AC_CHECK_FUNCS([ftruncate gethostname getpagesize gettimeofday localtime_r \
+  memchr memset mkdir mkfifo munmap nl_langinfo realpath rmdir setenv \
+  setlocale strcasecmp strchr strcspn strdup strerror strncasecmp strndup \
+  strrchr strspn strstr strtol strtoul uname], , [AC_MSG_ERROR(bailing out)])
 AC_FUNC_ALLOCA
 AC_FUNC_CLOSEDIR_VOID
 AC_FUNC_CHOWN
@@ -148,6 +148,7 @@ AC_FUNC_FORK
 AC_FUNC_LSTAT
 AC_FUNC_MALLOC
 AC_FUNC_MEMCMP
+AC_FUNC_MKTIME
 AC_FUNC_MMAP
 AC_FUNC_REALLOC
 AC_FUNC_STAT
@@ -1719,6 +1720,19 @@ if test "$READLINE" = yes; then
 	AC_CHECK_HEADERS(readline/readline.h readline/history.h,,hard_bailout)
 fi
 
+if test "$BUILD_CMIRRORD" = yes; then
+	AC_CHECK_FUNCS(atexit,,hard_bailout)
+fi
+
+if test "$BUILD_LVMLOCKD" = yes; then
+	AC_CHECK_FUNCS(clock_gettime strtoull,,hard_bailout) 
+fi
+
+if test "$BUILD_LVMPOLLD" = yes; then
+	AC_CHECK_FUNCS(strpbrk,,hard_bailout)
+	AC_FUNC_STRERROR_R
+fi
+
 if test "$CLVMD" != none; then
 	AC_CHECK_HEADERS(mntent.h netdb.h netinet/in.h pthread.h search.h sys/mount.h sys/socket.h sys/uio.h sys/un.h utmpx.h,,AC_MSG_ERROR(bailing out))
 	AC_CHECK_FUNCS(dup2 getmntent memmove select socket,,hard_bailout)
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 13e8a2d..750c75c 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -145,6 +145,9 @@
 /* Library version */
 #undef DM_LIB_VERSION
 
+/* Define to 1 if you have the `alarm' function. */
+#undef HAVE_ALARM
+
 /* Define to 1 if you have `alloca', as a function or macro. */
 #undef HAVE_ALLOCA
 
@@ -161,12 +164,18 @@
 /* Define to 1 if you have the <assert.h> header file. */
 #undef HAVE_ASSERT_H
 
+/* Define to 1 if you have the `atexit' function. */
+#undef HAVE_ATEXIT
+
 /* Define to 1 if canonicalize_file_name is available. */
 #undef HAVE_CANONICALIZE_FILE_NAME
 
 /* Define to 1 if your system has a working `chown' function. */
 #undef HAVE_CHOWN
 
+/* Define to 1 if you have the `clock_gettime' function. */
+#undef HAVE_CLOCK_GETTIME
+
 /* Define to 1 if you have the <corosync/cmap.h> header file. */
 #undef HAVE_COROSYNC_CMAP_H
 
@@ -176,6 +185,10 @@
 /* Define to 1 if you have the <ctype.h> header file. */
 #undef HAVE_CTYPE_H
 
+/* Define to 1 if you have the declaration of `strerror_r', and to 0 if you
+   don't. */
+#undef HAVE_DECL_STRERROR_R
+
 /* Define to 1 if you have the <dirent.h> header file. */
 #undef HAVE_DIRENT_H
 
@@ -194,6 +207,9 @@
 /* Define to 1 if you have the <fcntl.h> header file. */
 #undef HAVE_FCNTL_H
 
+/* Define to 1 if you have the <float.h> header file. */
+#undef HAVE_FLOAT_H
+
 /* Define to 1 if you have the `fork' function. */
 #undef HAVE_FORK
 
@@ -251,6 +267,9 @@
 /* Define to 1 if you have the <locale.h> header file. */
 #undef HAVE_LOCALE_H
 
+/* Define to 1 if you have the `localtime_r' function. */
+#undef HAVE_LOCALTIME_R
+
 /* Define to 1 if `lstat' has the bug that it succeeds when given the
    zero-length file name argument. */
 #undef HAVE_LSTAT_EMPTY_STRING_BUG
@@ -265,6 +284,9 @@
 /* Define to 1 if you have the <malloc.h> header file. */
 #undef HAVE_MALLOC_H
 
+/* Define to 1 if you have the `memchr' function. */
+#undef HAVE_MEMCHR
+
 /* Define to 1 if you have the `memmove' function. */
 #undef HAVE_MEMMOVE
 
@@ -301,9 +323,15 @@
 /* Define to 1 if you have the `nl_langinfo' function. */
 #undef HAVE_NL_LANGINFO
 
+/* Define to 1 if you have the <paths.h> header file. */
+#undef HAVE_PATHS_H
+
 /* Define to 1 if you have the <pthread.h> header file. */
 #undef HAVE_PTHREAD_H
 
+/* Define to 1 if the system has the type `ptrdiff_t'. */
+#undef HAVE_PTRDIFF_T
+
 /* Define to 1 if you have the <readline/history.h> header file. */
 #undef HAVE_READLINE_HISTORY_H
 
@@ -314,6 +342,9 @@
    and to 0 otherwise. */
 #undef HAVE_REALLOC
 
+/* Define to 1 if you have the `realpath' function. */
+#undef HAVE_REALPATH
+
 /* Define to 1 to include support for realtime clock. */
 #undef HAVE_REALTIME
 
@@ -363,6 +394,9 @@
 /* Define to 1 if you have the <stdarg.h> header file. */
 #undef HAVE_STDARG_H
 
+/* Define to 1 if stdbool.h conforms to C99. */
+#undef HAVE_STDBOOL_H
+
 /* Define to 1 if you have the <stddef.h> header file. */
 #undef HAVE_STDDEF_H
 
@@ -390,6 +424,9 @@
 /* Define to 1 if you have the `strerror' function. */
 #undef HAVE_STRERROR
 
+/* Define to 1 if you have the `strerror_r' function. */
+#undef HAVE_STRERROR_R
+
 /* Define to 1 if you have the <strings.h> header file. */
 #undef HAVE_STRINGS_H
 
@@ -399,6 +436,12 @@
 /* Define to 1 if you have the `strncasecmp' function. */
 #undef HAVE_STRNCASECMP
 
+/* Define to 1 if you have the `strndup' function. */
+#undef HAVE_STRNDUP
+
+/* Define to 1 if you have the `strpbrk' function. */
+#undef HAVE_STRPBRK
+
 /* Define to 1 if you have the `strrchr' function. */
 #undef HAVE_STRRCHR
 
@@ -414,6 +457,9 @@
 /* Define to 1 if you have the `strtoul' function. */
 #undef HAVE_STRTOUL
 
+/* Define to 1 if you have the `strtoull' function. */
+#undef HAVE_STRTOULL
+
 /* Define to 1 if `st_rdev' is member of `struct stat'. */
 #undef HAVE_STRUCT_STAT_ST_RDEV
 
@@ -518,6 +564,9 @@
 /* Define to 1 if `vfork' works. */
 #undef HAVE_WORKING_VFORK
 
+/* Define to 1 if the system has the type `_Bool'. */
+#undef HAVE__BOOL
+
 /* Internalization package */
 #undef INTL_PACKAGE
 
@@ -632,6 +681,9 @@
 /* Define to 1 if you have the ANSI C header files. */
 #undef STDC_HEADERS
 
+/* Define to 1 if strerror_r returns char *. */
+#undef STRERROR_R_CHAR_P
+
 /* Path to testsuite data */
 #undef TESTSUITE_DATA
 


