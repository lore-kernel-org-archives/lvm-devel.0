From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 18 Mar 2015 12:46:43 +0000 (UTC)
Subject: master - configure: detect st_ctim
Message-ID: <20150318124643.1AFCD60C9B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=17583f1b591bc4f84acf1e6be76083ddd84020ac
Commit:        17583f1b591bc4f84acf1e6be76083ddd84020ac
Parent:        a10a11bd54d9f33842eee8c168dc3c47aebec05b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 18 10:52:40 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 18 13:42:24 2015 +0100

configure: detect st_ctim

Check stat has nanosecond precision for ctim.
---
 acinclude.m4            |    4 ++++
 configure               |   34 ++++++++++++++++++++++++++++++++++
 configure.in            |   12 ++++++++++++
 lib/misc/configure.h.in |    3 +++
 4 files changed, 53 insertions(+), 0 deletions(-)

diff --git a/acinclude.m4 b/acinclude.m4
index 601ae9d..b6c9b18 100644
--- a/acinclude.m4
+++ b/acinclude.m4
@@ -37,6 +37,10 @@ AC_DEFUN([AC_TRY_CCFLAG],
     fi
 ])
 
+dnl AC_IF_YES([TEST-FOR-YES], [ACTION-IF-TRUE], [ACTION-IF-FALSE])
+dnl AS_IF() abstraction, checks shell variable for 'yes'
+AC_DEFUN([AC_IF_YES], [AS_IF([test $$1 = yes], [$2], [$3])])
+
 dnl AC_TRY_LDFLAGS([LDFLAGS], [VAR], [ACTION-IF-WORKS], [ACTION-IF-FAILS])
 dnl check if $CC supports given ld flags
 
diff --git a/configure b/configure
index d85e7c9..34d2a50 100755
--- a/configure
+++ b/configure
@@ -11958,6 +11958,40 @@ $as_echo "$as_me: WARNING: Disabling realtime clock" >&2;}
 	fi
 fi
 
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for struct stat has st_ctim." >&5
+$as_echo_n "checking for struct stat has st_ctim.... " >&6; }
+if ${ac_cv_stat_st_ctim+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#include <sys/stat.h>
+long bar(void) { struct stat s; return (long)(s.st_ctim.tv_sec + s.st_ctim.tv_nsec);}
+
+int
+main ()
+{
+
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_compile "$LINENO"; then :
+  ac_cv_stat_st_ctim=yes
+else
+  ac_cv_stat_st_ctim=no
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_stat_st_ctim" >&5
+$as_echo "$ac_cv_stat_st_ctim" >&6; }
+
+if test $ac_cv_stat_st_ctim = yes; then :
+
+$as_echo "#define HAVE_STAT_ST_CTIM 1" >>confdefs.h
+
+fi
+
 ################################################################################
 for ac_header in getopt.h
 do :
diff --git a/configure.in b/configure.in
index 55c13a6..38c7b51 100644
--- a/configure.in
+++ b/configure.in
@@ -1379,6 +1379,18 @@ if test "$REALTIME" = yes; then
 	fi
 fi
 
+dnl Check if the system has struct stat st_ctim.
+AC_CACHE_CHECK([for struct stat has st_ctim.],
+	[ac_cv_stat_st_ctim],
+	[AC_COMPILE_IFELSE([AC_LANG_PROGRAM(
+[#include <sys/stat.h>
+long bar(void) { struct stat s; return (long)(s.st_ctim.tv_sec + s.st_ctim.tv_nsec);}]
+	 )], [ac_cv_stat_st_ctim=yes], [ac_cv_stat_st_ctim=no])])
+
+AC_IF_YES(ac_cv_stat_st_ctim,
+	  AC_DEFINE(HAVE_STAT_ST_CTIM, 1,
+		    [Define if struct stat has a field st_ctim with timespec for ctime]))
+
 ################################################################################
 dnl -- Check for getopt
 AC_CHECK_HEADERS(getopt.h, AC_DEFINE([HAVE_GETOPTLONG], 1, [Define to 1 if getopt_long is available.]))
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index ee9f859..48ae3f6 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -322,6 +322,9 @@
    zero-length file name argument. */
 #undef HAVE_STAT_EMPTY_STRING_BUG
 
+/* Define if struct stat has a field st_ctim with timespec for ctime */
+#undef HAVE_STAT_ST_CTIM
+
 /* Define to 1 if you have the <stdarg.h> header file. */
 #undef HAVE_STDARG_H
 


