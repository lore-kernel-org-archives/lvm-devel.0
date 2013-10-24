From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 24 Oct 2013 22:47:59 +0000 (UTC)
Subject: master - configure: detect compiler flag
Message-ID: <20131024224759.4CAF260D36@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d95751cb0b750ea698d665bd8ad8086fe9ee6945
Commit:        d95751cb0b750ea698d665bd8ad8086fe9ee6945
Parent:        772fa460d1ef7dede99478e30de756136ea0c7aa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 24 21:40:25 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 25 00:41:36 2013 +0200

configure: detect compiler flag

Use m4 macro AC_TRY_CCFLAG to detect presence of some compiler
option.
Use it to detect -Wjump-misses-init.
---
 acinclude.m4 |   39 +++++++++++++++++++++++++++++++++++++++
 aclocal.m4   |    1 +
 configure    |   42 ++++++++++++++++++++++++++++++++++++++++++
 configure.in |    4 ++++
 make.tmpl.in |    6 +++++-
 5 files changed, 91 insertions(+), 1 deletions(-)

diff --git a/acinclude.m4 b/acinclude.m4
new file mode 100644
index 0000000..333abb5
--- /dev/null
+++ b/acinclude.m4
@@ -0,0 +1,39 @@
+dnl AC_GCC_VERSION
+dnl check for compiler version
+dnl sets COMPILER_VERSION and GCC_VERSION
+
+AC_DEFUN([AC_CC_VERSION],
+[
+    AC_MSG_CHECKING([C compiler version])
+    COMPILER_VERSION=`$CC -v 2>&1 | grep version`
+    case "$COMPILER_VERSION" in
+        *gcc*)
+	   dnl Ok, how to turn $3 into the real $3
+	   GCC_VERSION=`echo $COMPILER_VERSION | \
+	   sed -e 's/[[^ ]]*\ [[^ ]]*\ \([[^ ]]*\)\ .*/\1/'` ;;
+	*) GCC_VERSION=unknown ;;
+    esac
+    AC_MSG_RESULT($GCC_VERSION)
+])
+
+dnl AC_TRY_CCFLAG([CCFLAG], [VAR], [ACTION-IF-WORKS], [ACTION-IF-FAILS])
+dnl check if $CC supports a given flag
+
+AC_DEFUN([AC_TRY_CCFLAG],
+[
+    AC_REQUIRE([AC_PROG_CC])
+    ac_save_CFLAGS=$CFLAGS
+    CFLAGS=$1
+    AC_MSG_RESULT([KOUKEJ $name])
+    AC_CACHE_CHECK([whether $CC accepts $1 flag], [ac_cv_flag_$2],
+	[AC_COMPILE_IFELSE([AC_LANG_PROGRAM()],
+			   [AS_VAR_SET([ac_cv_flag_$2], [yes])],
+			   [AS_VAR_SET([ac_cv_flag_$2], [no])])])
+    CFLAGS=$ac_save_CFLAGS
+    $2=AS_VAR_GET([ac_cv_flag_$2])
+    if test "$2" = yes; then
+        ifelse([$3], [], [:], [$3])
+    else
+        ifelse([$4], [], [:], [$4])
+    fi
+])
diff --git a/aclocal.m4 b/aclocal.m4
index 263b50e..165d9bc 100644
--- a/aclocal.m4
+++ b/aclocal.m4
@@ -169,3 +169,4 @@ else
 fi[]dnl
 ])# PKG_CHECK_MODULES
 
+m4_include([acinclude.m4])
diff --git a/configure b/configure
index 002a7d2..48dfdc6 100755
--- a/configure
+++ b/configure
@@ -708,6 +708,7 @@ CUNIT_CFLAGS
 GENPNG
 GENHTML
 LCOV
+HAVE_WJUMP
 SACKPT_LIBS
 SACKPT_CFLAGS
 DLM_LIBS
@@ -8677,6 +8678,47 @@ else
 	CSCOPE_CMD=
 fi
 
+
+
+    ac_save_CFLAGS=$CFLAGS
+    CFLAGS=-Wjump-misses-init
+    { $as_echo "$as_me:${as_lineno-$LINENO}: result: KOUKEJ $name" >&5
+$as_echo "KOUKEJ $name" >&6; }
+    { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $CC accepts -Wjump-misses-init flag" >&5
+$as_echo_n "checking whether $CC accepts -Wjump-misses-init flag... " >&6; }
+if test "${ac_cv_flag_HAVE_WJUMP+set}" = set; then :
+  $as_echo_n "(cached) " >&6
+else
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
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
+  ac_cv_flag_HAVE_WJUMP=yes
+else
+  ac_cv_flag_HAVE_WJUMP=no
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_flag_HAVE_WJUMP" >&5
+$as_echo "$ac_cv_flag_HAVE_WJUMP" >&6; }
+    CFLAGS=$ac_save_CFLAGS
+    HAVE_WJUMP=$ac_cv_flag_HAVE_WJUMP
+    if test "HAVE_WJUMP" = yes; then
+        :
+    else
+        :
+    fi
+
+
+
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for C optimisation flag" >&5
 $as_echo_n "checking for C optimisation flag... " >&6; }
diff --git a/configure.in b/configure.in
index 07b0afc..3a25fef 100644
--- a/configure.in
+++ b/configure.in
@@ -835,6 +835,10 @@ else
 	CSCOPE_CMD=
 fi
 
+dnl -- Check if compiler supports -Wjump-misses-init
+AC_TRY_CCFLAG([-Wjump-misses-init], [HAVE_WJUMP], [], [])
+AC_SUBST(HAVE_WJUMP)
+
 ################################################################################
 dnl -- Override optimisation
 AC_MSG_CHECKING(for C optimisation flag)
diff --git a/make.tmpl.in b/make.tmpl.in
index 788eb1d..08560a8 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -138,9 +138,13 @@ WFLAGS += -Wall -Wundef -Wshadow -Wcast-align -Wwrite-strings \
  -Wpointer-arith -Wclobbered -Wempty-body -Wignored-qualifiers \
  -Wmissing-parameter-type -Wold-style-declaration -Woverride-init \
  -Wtype-limits -Wuninitialized -Wmissing-include-dirs -Wsync-nand \
- -Wfloat-equal -Wjump-misses-init -Wlogical-op -Wstrict-prototypes \
+ -Wfloat-equal -Wlogical-op -Wstrict-prototypes \
  -Wold-style-definition -Wmissing-format-attribute
 
+ifeq ("@HAVE_WJUMP@", "yes")
+WFLAGS += -Wjump-misses-init
+endif
+
 #WFLAGS += -W -Wno-sign-compare -Wno-unused-parameter -Wno-missing-field-initializers
 #WFLAGS += -Wsign-compare -Wunused-parameter -Wmissing-field-initializers 
 #WFLAGS += -Wconversion -Wbad-function-cast -Wcast-qual -Waggregate-return -Wpacked


