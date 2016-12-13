From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue, 13 Dec 2016 21:04:31 +0000 (UTC)
Subject: master - configure: check for __builtin_clz()
Message-ID: <20161213210431.1BC30603AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=83a9cd5258fbd1acf293734cb4c3aba0f9ffcc9b
Commit:        83a9cd5258fbd1acf293734cb4c3aba0f9ffcc9b
Parent:        930b0b4c9e4ca466d955f8729644ef26a939937c
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Dec 12 12:03:16 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Dec 13 20:38:40 2016 +0000

configure: check for __builtin_clz()

---
 aclocal.m4             |  171 ++++++++++++++++++++++++++++++++++++++++++++++++
 configure              |   44 ++++++++++++
 configure.in           |    1 +
 include/configure.h.in |    3 +
 4 files changed, 219 insertions(+), 0 deletions(-)

diff --git a/aclocal.m4 b/aclocal.m4
index 35107ac..1f02c2b 100644
--- a/aclocal.m4
+++ b/aclocal.m4
@@ -536,4 +536,175 @@ AC_DEFUN([AM_RUN_LOG],
    echo "$as_me:$LINENO: \$? = $ac_status" >&AS_MESSAGE_LOG_FD
    (exit $ac_status); }])
 
+# ===========================================================================
+#      http://www.gnu.org/software/autoconf-archive/ax_gcc_builtin.html
+# ===========================================================================
+#
+# SYNOPSIS
+#
+#   AX_GCC_BUILTIN(BUILTIN)
+#
+# DESCRIPTION
+#
+#   This macro checks if the compiler supports one of GCC's built-in
+#   functions; many other compilers also provide those same built-ins.
+#
+#   The BUILTIN parameter is the name of the built-in function.
+#
+#   If BUILTIN is supported define HAVE_<BUILTIN>. Keep in mind that since
+#   builtins usually start with two underscores they will be copied over
+#   into the HAVE_<BUILTIN> definition (e.g. HAVE___BUILTIN_EXPECT for
+#   __builtin_expect()).
+#
+#   The macro caches its result in the ax_cv_have_<BUILTIN> variable (e.g.
+#   ax_cv_have___builtin_expect).
+#
+#   The macro currently supports the following built-in functions:
+#
+#    __builtin_assume_aligned
+#    __builtin_bswap16
+#    __builtin_bswap32
+#    __builtin_bswap64
+#    __builtin_choose_expr
+#    __builtin___clear_cache
+#    __builtin_clrsb
+#    __builtin_clrsbl
+#    __builtin_clrsbll
+#    __builtin_clz
+#    __builtin_clzl
+#    __builtin_clzll
+#    __builtin_complex
+#    __builtin_constant_p
+#    __builtin_ctz
+#    __builtin_ctzl
+#    __builtin_ctzll
+#    __builtin_expect
+#    __builtin_ffs
+#    __builtin_ffsl
+#    __builtin_ffsll
+#    __builtin_fpclassify
+#    __builtin_huge_val
+#    __builtin_huge_valf
+#    __builtin_huge_vall
+#    __builtin_inf
+#    __builtin_infd128
+#    __builtin_infd32
+#    __builtin_infd64
+#    __builtin_inff
+#    __builtin_infl
+#    __builtin_isinf_sign
+#    __builtin_nan
+#    __builtin_nand128
+#    __builtin_nand32
+#    __builtin_nand64
+#    __builtin_nanf
+#    __builtin_nanl
+#    __builtin_nans
+#    __builtin_nansf
+#    __builtin_nansl
+#    __builtin_object_size
+#    __builtin_parity
+#    __builtin_parityl
+#    __builtin_parityll
+#    __builtin_popcount
+#    __builtin_popcountl
+#    __builtin_popcountll
+#    __builtin_powi
+#    __builtin_powif
+#    __builtin_powil
+#    __builtin_prefetch
+#    __builtin_trap
+#    __builtin_types_compatible_p
+#    __builtin_unreachable
+#
+#   Unsuppored built-ins will be tested with an empty parameter set and the
+#   result of the check might be wrong or meaningless so use with care.
+#
+# LICENSE
+#
+#   Copyright (c) 2013 Gabriele Svelto <gabriele.svelto@gmail.com>
+#
+#   Copying and distribution of this file, with or without modification, are
+#   permitted in any medium without royalty provided the copyright notice
+#   and this notice are preserved.  This file is offered as-is, without any
+#   warranty.
+
+#serial 3
+
+AC_DEFUN([AX_GCC_BUILTIN], [
+    AS_VAR_PUSHDEF([ac_var], [ax_cv_have_$1])
+
+    AC_CACHE_CHECK([for $1], [ac_var], [
+        AC_LINK_IFELSE([AC_LANG_PROGRAM([], [
+            m4_case([$1],
+                [__builtin_assume_aligned], [$1("", 0)],
+                [__builtin_bswap16], [$1(0)],
+                [__builtin_bswap32], [$1(0)],
+                [__builtin_bswap64], [$1(0)],
+                [__builtin_choose_expr], [$1(0, 0, 0)],
+                [__builtin___clear_cache], [$1("", "")],
+                [__builtin_clrsb], [$1(0)],
+                [__builtin_clrsbl], [$1(0)],
+                [__builtin_clrsbll], [$1(0)],
+                [__builtin_clz], [$1(0)],
+                [__builtin_clzl], [$1(0)],
+                [__builtin_clzll], [$1(0)],
+                [__builtin_complex], [$1(0.0, 0.0)],
+                [__builtin_constant_p], [$1(0)],
+                [__builtin_ctz], [$1(0)],
+                [__builtin_ctzl], [$1(0)],
+                [__builtin_ctzll], [$1(0)],
+                [__builtin_expect], [$1(0, 0)],
+                [__builtin_ffs], [$1(0)],
+                [__builtin_ffsl], [$1(0)],
+                [__builtin_ffsll], [$1(0)],
+                [__builtin_fpclassify], [$1(0, 1, 2, 3, 4, 0.0)],
+                [__builtin_huge_val], [$1()],
+                [__builtin_huge_valf], [$1()],
+                [__builtin_huge_vall], [$1()],
+                [__builtin_inf], [$1()],
+                [__builtin_infd128], [$1()],
+                [__builtin_infd32], [$1()],
+                [__builtin_infd64], [$1()],
+                [__builtin_inff], [$1()],
+                [__builtin_infl], [$1()],
+                [__builtin_isinf_sign], [$1(0.0)],
+                [__builtin_nan], [$1("")],
+                [__builtin_nand128], [$1("")],
+                [__builtin_nand32], [$1("")],
+                [__builtin_nand64], [$1("")],
+                [__builtin_nanf], [$1("")],
+                [__builtin_nanl], [$1("")],
+                [__builtin_nans], [$1("")],
+                [__builtin_nansf], [$1("")],
+                [__builtin_nansl], [$1("")],
+                [__builtin_object_size], [$1("", 0)],
+                [__builtin_parity], [$1(0)],
+                [__builtin_parityl], [$1(0)],
+                [__builtin_parityll], [$1(0)],
+                [__builtin_popcount], [$1(0)],
+                [__builtin_popcountl], [$1(0)],
+                [__builtin_popcountll], [$1(0)],
+                [__builtin_powi], [$1(0, 0)],
+                [__builtin_powif], [$1(0, 0)],
+                [__builtin_powil], [$1(0, 0)],
+                [__builtin_prefetch], [$1("")],
+                [__builtin_trap], [$1()],
+                [__builtin_types_compatible_p], [$1(int, int)],
+                [__builtin_unreachable], [$1()],
+                [m4_warn([syntax], [Unsupported built-in $1, the test may fail])
+                 $1()]
+            )
+            ])],
+            [AS_VAR_SET([ac_var], [yes])],
+            [AS_VAR_SET([ac_var], [no])])
+    ])
+
+    AS_IF([test yes = AS_VAR_GET([ac_var])],
+        [AC_DEFINE_UNQUOTED(AS_TR_CPP(HAVE_$1), 1,
+            [Define to 1 if the system has the `$1' built-in function])], [])
+
+    AS_VAR_POPDEF([ac_var])
+])
+
 m4_include([acinclude.m4])
diff --git a/configure b/configure
index c82a19b..1cb4b54 100755
--- a/configure
+++ b/configure
@@ -6321,6 +6321,50 @@ _ACEOF
   esac
 
 
+
+
+    { $as_echo "$as_me:${as_lineno-$LINENO}: checking for __builtin_clz" >&5
+$as_echo_n "checking for __builtin_clz... " >&6; }
+if ${ax_cv_have___builtin_clz+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+
+        cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+
+int
+main ()
+{
+
+            __builtin_clz(0)
+
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_link "$LINENO"; then :
+  ax_cv_have___builtin_clz=yes
+else
+  ax_cv_have___builtin_clz=no
+fi
+rm -f core conftest.err conftest.$ac_objext \
+    conftest$ac_exeext conftest.$ac_ext
+
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ax_cv_have___builtin_clz" >&5
+$as_echo "$ax_cv_have___builtin_clz" >&6; }
+
+    if test yes = $ax_cv_have___builtin_clz; then :
+
+cat >>confdefs.h <<_ACEOF
+#define HAVE___BUILTIN_CLZ 1
+_ACEOF
+
+fi
+
+
+
+
 ################################################################################
 for ac_func in ftruncate gethostname getpagesize gettimeofday localtime_r \
   memchr memset mkdir mkfifo munmap nl_langinfo realpath rmdir setenv \
diff --git a/configure.in b/configure.in
index cc77aab..8ec65c8 100644
--- a/configure.in
+++ b/configure.in
@@ -134,6 +134,7 @@ AC_TYPE_UINT8_T
 AC_TYPE_UINT16_T
 AC_TYPE_UINT32_T
 AC_TYPE_UINT64_T
+AX_GCC_BUILTIN([__builtin_clz])
 
 ################################################################################
 dnl -- Check for functions
diff --git a/include/configure.h.in b/include/configure.h.in
index 3c43bd5..cf8dc94 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -341,6 +341,9 @@
 /* Define to 1 if the system has the type `ptrdiff_t'. */
 #undef HAVE_PTRDIFF_T
 
+/* Define to 1 if the compiler has the `__builtin_clz` builtin. */
+#undef HAVE___BUILTIN_CLZ
+
 /* Define to 1 if you have the <readline/history.h> header file. */
 #undef HAVE_READLINE_HISTORY_H
 


