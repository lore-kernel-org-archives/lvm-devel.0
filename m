From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 10 Mar 2015 13:09:36 +0000 (UTC)
Subject: master - configure: check for sync-nand
Message-ID: <20150310130936.05AA261094@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0982c5c79f3467bcff1d64ac12cb30b25d446a5a
Commit:        0982c5c79f3467bcff1d64ac12cb30b25d446a5a
Parent:        47b704462eea3c93ab5f46d970e5a74a4a5d4e70
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 10 13:36:55 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 10 14:10:18 2015 +0100

configure: check for sync-nand

Check whether gcc support this flag.
Some older compilers (gcc version 4.3.2) miss it.
---
 configure    |   39 +++++++++++++++++++++++++++++++++++++++
 configure.in |    2 ++
 make.tmpl.in |    6 +++++-
 3 files changed, 46 insertions(+), 1 deletions(-)

diff --git a/configure b/configure
index c5c3b85..d85e7c9 100755
--- a/configure
+++ b/configure
@@ -749,6 +749,7 @@ CUNIT_CFLAGS
 GENPNG
 GENHTML
 LCOV
+HAVE_WSYNCNAND
 HAVE_WCLOBBERED
 HAVE_WJUMP
 SACKPT_LIBS
@@ -10214,6 +10215,44 @@ $as_echo "$ac_cv_flag_HAVE_WCLOBBERED" >&6; }
 
 
 
+
+    ac_save_CFLAGS=$CFLAGS
+    CFLAGS=-Wsync-nand
+    { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $CC accepts -Wsync-nand flag" >&5
+$as_echo_n "checking whether $CC accepts -Wsync-nand flag... " >&6; }
+if ${ac_cv_flag_HAVE_WSYNCNAND+:} false; then :
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
+  ac_cv_flag_HAVE_WSYNCNAND=yes
+else
+  ac_cv_flag_HAVE_WSYNCNAND=no
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_flag_HAVE_WSYNCNAND" >&5
+$as_echo "$ac_cv_flag_HAVE_WSYNCNAND" >&6; }
+    CFLAGS=$ac_save_CFLAGS
+    HAVE_WSYNCNAND=$ac_cv_flag_HAVE_WSYNCNAND
+    if test "HAVE_WSYNCNAND" = yes; then
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
index 15d371b..55c13a6 100644
--- a/configure.in
+++ b/configure.in
@@ -962,6 +962,8 @@ AC_TRY_CCFLAG([-Wjump-misses-init], [HAVE_WJUMP], [], [])
 AC_SUBST(HAVE_WJUMP)
 AC_TRY_CCFLAG([-Wclobbered], [HAVE_WCLOBBERED], [], [])
 AC_SUBST(HAVE_WCLOBBERED)
+AC_TRY_CCFLAG([-Wsync-nand], [HAVE_WSYNCNAND], [], [])
+AC_SUBST(HAVE_WSYNCNAND)
 
 ################################################################################
 dnl -- Override optimisation
diff --git a/make.tmpl.in b/make.tmpl.in
index 72e2613..11721f1 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -156,7 +156,11 @@ endif
 ifeq ("@HAVE_WCLOBBERED@", "yes")
 WFLAGS += -Wclobbered -Wempty-body -Wignored-qualifiers \
  -Wmissing-parameter-type -Wold-style-declaration -Woverride-init \
- -Wtype-limits -Wsync-nand -Wlogical-op
+ -Wtype-limits -Wlogical-op
+endif
+
+ifeq ("@HAVE_WSYNCNAND@", "yes")
+WFLAGS += -Wsync-nand
 endif
 
 ifneq ("@STATIC_LINK@", "yes")


