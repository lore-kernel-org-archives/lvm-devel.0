From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 24 Oct 2013 23:01:22 +0000 (UTC)
Subject: master - configure: check more compile flags
Message-ID: <20131024230122.E33E460F8B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7943a13141a8379f7697ee9d8764e088a4f127c3
Commit:        7943a13141a8379f7697ee9d8764e088a4f127c3
Parent:        d95751cb0b750ea698d665bd8ad8086fe9ee6945
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 25 01:00:10 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 25 01:00:10 2013 +0200

configure: check more compile flags

Check for clobbered (and put few others into same league)
---
 acinclude.m4 |    1 -
 configure    |   41 +++++++++++++++++++++++++++++++++++++++--
 configure.in |    2 ++
 make.tmpl.in |   12 ++++++++----
 4 files changed, 49 insertions(+), 7 deletions(-)

diff --git a/acinclude.m4 b/acinclude.m4
index 333abb5..bf9fe09 100644
--- a/acinclude.m4
+++ b/acinclude.m4
@@ -24,7 +24,6 @@ AC_DEFUN([AC_TRY_CCFLAG],
     AC_REQUIRE([AC_PROG_CC])
     ac_save_CFLAGS=$CFLAGS
     CFLAGS=$1
-    AC_MSG_RESULT([KOUKEJ $name])
     AC_CACHE_CHECK([whether $CC accepts $1 flag], [ac_cv_flag_$2],
 	[AC_COMPILE_IFELSE([AC_LANG_PROGRAM()],
 			   [AS_VAR_SET([ac_cv_flag_$2], [yes])],
diff --git a/configure b/configure
index 48dfdc6..9418d53 100755
--- a/configure
+++ b/configure
@@ -708,6 +708,7 @@ CUNIT_CFLAGS
 GENPNG
 GENHTML
 LCOV
+HAVE_WCLOBBERED
 HAVE_WJUMP
 SACKPT_LIBS
 SACKPT_CFLAGS
@@ -8682,8 +8683,6 @@ fi
 
     ac_save_CFLAGS=$CFLAGS
     CFLAGS=-Wjump-misses-init
-    { $as_echo "$as_me:${as_lineno-$LINENO}: result: KOUKEJ $name" >&5
-$as_echo "KOUKEJ $name" >&6; }
     { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $CC accepts -Wjump-misses-init flag" >&5
 $as_echo_n "checking whether $CC accepts -Wjump-misses-init flag... " >&6; }
 if test "${ac_cv_flag_HAVE_WJUMP+set}" = set; then :
@@ -8719,6 +8718,44 @@ $as_echo "$ac_cv_flag_HAVE_WJUMP" >&6; }
 
 
 
+
+    ac_save_CFLAGS=$CFLAGS
+    CFLAGS=-Wclobbered
+    { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $CC accepts -Wclobbered flag" >&5
+$as_echo_n "checking whether $CC accepts -Wclobbered flag... " >&6; }
+if test "${ac_cv_flag_HAVE_WCLOBBERED+set}" = set; then :
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
+  ac_cv_flag_HAVE_WCLOBBERED=yes
+else
+  ac_cv_flag_HAVE_WCLOBBERED=no
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_flag_HAVE_WCLOBBERED" >&5
+$as_echo "$ac_cv_flag_HAVE_WCLOBBERED" >&6; }
+    CFLAGS=$ac_save_CFLAGS
+    HAVE_WCLOBBERED=$ac_cv_flag_HAVE_WCLOBBERED
+    if test "HAVE_WCLOBBERED" = yes; then
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
index 3a25fef..cd80274 100644
--- a/configure.in
+++ b/configure.in
@@ -838,6 +838,8 @@ fi
 dnl -- Check if compiler supports -Wjump-misses-init
 AC_TRY_CCFLAG([-Wjump-misses-init], [HAVE_WJUMP], [], [])
 AC_SUBST(HAVE_WJUMP)
+AC_TRY_CCFLAG([-Wclobbered], [HAVE_WCLOBBERED], [], [])
+AC_SUBST(HAVE_WCLOBBERED)
 
 ################################################################################
 dnl -- Override optimisation
diff --git a/make.tmpl.in b/make.tmpl.in
index 08560a8..3eea85e 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -135,16 +135,20 @@ INSTALL_SCRIPT = $(INSTALL) -p $(M_INSTALL_PROGRAM)
 WFLAGS += -Wall -Wundef -Wshadow -Wcast-align -Wwrite-strings \
  -Wmissing-prototypes -Wmissing-declarations -Wnested-externs \
  -Winline -Wmissing-noreturn -Wformat-security -Wredundant-decls \
- -Wpointer-arith -Wclobbered -Wempty-body -Wignored-qualifiers \
- -Wmissing-parameter-type -Wold-style-declaration -Woverride-init \
- -Wtype-limits -Wuninitialized -Wmissing-include-dirs -Wsync-nand \
- -Wfloat-equal -Wlogical-op -Wstrict-prototypes \
+ -Wpointer-arith -Wuninitialized -Wmissing-include-dirs \
+ -Wfloat-equal -Wstrict-prototypes \
  -Wold-style-definition -Wmissing-format-attribute
 
 ifeq ("@HAVE_WJUMP@", "yes")
 WFLAGS += -Wjump-misses-init
 endif
 
+ifeq ("@HAVE_WCLOBBERED@", "yes")
+WFLAGS += -Wclobbered -Wempty-body -Wignored-qualifiers \
+ -Wmissing-parameter-type -Wold-style-declaration -Woverride-init \
+ -Wtype-limits -Wsync-nand -Wlogical-op
+endif
+
 #WFLAGS += -W -Wno-sign-compare -Wno-unused-parameter -Wno-missing-field-initializers
 #WFLAGS += -Wsign-compare -Wunused-parameter -Wmissing-field-initializers 
 #WFLAGS += -Wconversion -Wbad-function-cast -Wcast-qual -Waggregate-return -Wpacked


