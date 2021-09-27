From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 27 Sep 2021 16:57:44 +0000 (GMT)
Subject: main - configure: check ffs __builtin_ffs versionsort
Message-ID: <20210927165744.38CDE3858408@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ff788ef19c498967ba83fb54c14700de7d4c274a
Commit:        ff788ef19c498967ba83fb54c14700de7d4c274a
Parent:        27eef1b96402abaadbd328d8912f3ccce96df5e2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 24 18:04:39 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 27 18:56:13 2021 +0200

configure: check ffs __builtin_ffs versionsort

Check for presence of ffs(), __builtin_ffs() and versionsort().
---
 configure              | 65 +++++++++++++++++++++++++++++++++++++++++++-------
 configure.ac           |  3 ++-
 include/configure.h.in |  9 +++++++
 3 files changed, 68 insertions(+), 9 deletions(-)

diff --git a/configure b/configure
index 9b1508255..8a267d0f1 100755
--- a/configure
+++ b/configure
@@ -6701,6 +6701,46 @@ fi
 
 
 
+    { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for __builtin_ffs" >&5
+printf %s "checking for __builtin_ffs... " >&6; }
+if test ${ax_cv_have___builtin_ffs+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+
+        cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+
+int
+main (void)
+{
+
+            __builtin_ffs(0)
+
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_link "$LINENO"
+then :
+  ax_cv_have___builtin_ffs=yes
+else $as_nop
+  ax_cv_have___builtin_ffs=no
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam \
+    conftest$ac_exeext conftest.$ac_ext
+
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ax_cv_have___builtin_ffs" >&5
+printf "%s\n" "$ax_cv_have___builtin_ffs" >&6; }
+
+    if test yes = $ax_cv_have___builtin_ffs
+then :
+
+printf "%s\n" "#define HAVE___BUILTIN_FFS 1" >>confdefs.h
+
+fi
+
 $as_echo "#define _GNU_SOURCE 1" >>confdefs.h
 
 
@@ -6726,16 +6766,25 @@ else
 fi
 done
 
-for ac_func in prlimit
-do :
-  ac_fn_c_check_func "$LINENO" "prlimit" "ac_cv_func_prlimit"
-if test "x$ac_cv_func_prlimit" = xyes; then :
-  cat >>confdefs.h <<_ACEOF
-#define HAVE_PRLIMIT 1
-_ACEOF
+ac_fn_c_check_func "$LINENO" "ffs" "ac_cv_func_ffs"
+if test "x$ac_cv_func_ffs" = xyes
+then :
+  printf "%s\n" "#define HAVE_FFS 1" >>confdefs.h
 
 fi
-done
+ac_fn_c_check_func "$LINENO" "prlimit" "ac_cv_func_prlimit"
+if test "x$ac_cv_func_prlimit" = xyes
+then :
+  printf "%s\n" "#define HAVE_PRLIMIT 1" >>confdefs.h
+
+fi
+ac_fn_c_check_func "$LINENO" "versionsort" "ac_cv_func_versionsort"
+if test "x$ac_cv_func_versionsort" = xyes
+then :
+  printf "%s\n" "#define HAVE_VERSIONSORT 1" >>confdefs.h
+
+fi
+
 
 # The Ultrix 4.2 mips builtin alloca declared by alloca.h only works
 # for constant arguments.  Useless!
diff --git a/configure.ac b/configure.ac
index a821edf2a..a65a957e0 100644
--- a/configure.ac
+++ b/configure.ac
@@ -144,6 +144,7 @@ AC_TYPE_UINT32_T
 AC_TYPE_UINT64_T
 AX_GCC_BUILTIN([__builtin_clz])
 AX_GCC_BUILTIN([__builtin_clzll])
+AX_GCC_BUILTIN([__builtin_ffs])
 
 
 AC_DEFINE([_GNU_SOURCE], 1, [Define to get access to GNU/Linux extension])
@@ -156,7 +157,7 @@ AC_CHECK_FUNCS([ftruncate gethostname getpagesize gettimeofday localtime_r \
   memchr memset mkdir mkfifo munmap nl_langinfo pselect realpath rmdir setenv \
   setlocale strcasecmp strchr strcspn strdup strerror strncasecmp strndup \
   strrchr strspn strstr strtol strtoul uname], , [AC_MSG_ERROR(bailing out)])
-AC_CHECK_FUNCS([prlimit])
+AC_CHECK_FUNCS([ffs prlimit versionsort])
 AC_FUNC_ALLOCA
 AC_FUNC_CLOSEDIR_VOID
 AC_FUNC_CHOWN
diff --git a/include/configure.h.in b/include/configure.h.in
index 8fb5ca9fe..637bfc341 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -194,6 +194,9 @@
 /* Define to 1 if you have the <fcntl.h> header file. */
 #undef HAVE_FCNTL_H
 
+/* Define to 1 if you have the `ffs' function. */
+#undef HAVE_FFS
+
 /* Define to 1 if you have the <float.h> header file. */
 #undef HAVE_FLOAT_H
 
@@ -519,6 +522,9 @@
 /* valgrind.h found */
 #undef HAVE_VALGRIND
 
+/* Define to 1 if you have the `versionsort' function. */
+#undef HAVE_VERSIONSORT
+
 /* Define to 1 if you have the `vfork' function. */
 #undef HAVE_VFORK
 
@@ -543,6 +549,9 @@
 /* Define to 1 if the system has the `__builtin_clzll' built-in function */
 #undef HAVE___BUILTIN_CLZLL
 
+/* Define to 1 if the system has the `__builtin_ffs' built-in function */
+#undef HAVE___BUILTIN_FFS
+
 /* Define to 1 to include built-in support for integrity. */
 #undef INTEGRITY_INTERNAL
 


