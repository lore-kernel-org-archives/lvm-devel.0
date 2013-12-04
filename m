From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  4 Dec 2013 12:30:19 +0000 (UTC)
Subject: master - configure: check compiler/linker support for RELRO and PIE options
Message-ID: <20131204123019.967F96030C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6c6bcc00e401262db3b906259674a3231a119603
Commit:        6c6bcc00e401262db3b906259674a3231a119603
Parent:        163666e513848e5d43d3e4f2f91b42d1a8f483a0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Dec 4 09:58:58 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Dec 4 13:30:08 2013 +0100

configure: check compiler/linker support for RELRO and PIE options

Also, add AC_TRY_LDFLAGS m4 macro to help with checking ld flags.
---
 WHATS_NEW    |    1 +
 acinclude.m4 |   21 +++++++++++++++
 configure    |   81 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 configure.in |    7 +++++
 4 files changed, 110 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 553edfd..9155ddf 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Automatically detect support for compiler/linker options to use RELRO and PIE.
   Add --splitsnapshot to lvconvert to separate out cow LV.
   Reinstate origin reload to complete lvconvert -s with active LVs. (2.02.98)
   Select only active volume groups if vgdisplay -A is used.
diff --git a/acinclude.m4 b/acinclude.m4
index bf9fe09..b9473db 100644
--- a/acinclude.m4
+++ b/acinclude.m4
@@ -36,3 +36,24 @@ AC_DEFUN([AC_TRY_CCFLAG],
         ifelse([$4], [], [:], [$4])
     fi
 ])
+
+dnl AC_TRY_LDFLAGS([LDFLAGS], [VAR], [ACTION-IF-WORKS], [ACTION-IF-FAILS])
+dnl check if $CC supports given ld flags
+
+AC_DEFUN([AC_TRY_LDFLAGS],
+[
+    AC_REQUIRE([AC_PROG_CC])
+    ac_save_LDFLAGS=$LDFLAGS
+    LDFLAGS=$1
+	AC_CACHE_CHECK([whether $CC accepts $1 ld flags], [ac_cv_flag_$2],
+	[AC_LINK_IFELSE([AC_LANG_PROGRAM()],
+			[AS_VAR_SET([ac_cv_flag_$2], [yes])],
+			[AS_VAR_SET([ac_cv_flag_$2], [no])])])
+    LDLAGS=$ac_save_LDFLAGS
+    $2=AS_VAR_GET([ac_cv_flag_$2])
+    if test "$2" = yes; then
+        ifelse([$3], [], [:], [$3])
+    else
+        ifelse([$4], [], [:], [$4])
+    fi
+])
diff --git a/configure b/configure
index 564d322..2ecc7ba 100755
--- a/configure
+++ b/configure
@@ -740,6 +740,8 @@ PKG_CONFIG
 THIN_REPAIR_CMD
 THIN_DUMP_CMD
 THIN_CHECK_CMD
+HAVE_FULL_RELRO
+HAVE_PIE
 POW_LIB
 LIBOBJS
 ALLOCA
@@ -6744,6 +6746,85 @@ $as_echo "$STATIC_LINK" >&6; }
 ################################################################################
 
 
+    ac_save_CFLAGS=$CFLAGS
+    CFLAGS=-pie
+    { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $CC accepts -pie flag" >&5
+$as_echo_n "checking whether $CC accepts -pie flag... " >&6; }
+if test "${ac_cv_flag_HAVE_PIE+set}" = set; then :
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
+  ac_cv_flag_HAVE_PIE=yes
+else
+  ac_cv_flag_HAVE_PIE=no
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_flag_HAVE_PIE" >&5
+$as_echo "$ac_cv_flag_HAVE_PIE" >&6; }
+    CFLAGS=$ac_save_CFLAGS
+    HAVE_PIE=$ac_cv_flag_HAVE_PIE
+    if test "HAVE_PIE" = yes; then
+        :
+    else
+        :
+    fi
+
+
+
+
+    ac_save_LDFLAGS=$LDFLAGS
+    LDFLAGS=-Wl,-z,relro,-z,now
+	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether $CC accepts -Wl,-z,relro,-z,now ld flags" >&5
+$as_echo_n "checking whether $CC accepts -Wl,-z,relro,-z,now ld flags... " >&6; }
+if test "${ac_cv_flag_HAVE_FULL_RELRO+set}" = set; then :
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
+if ac_fn_c_try_link "$LINENO"; then :
+  ac_cv_flag_HAVE_FULL_RELRO=yes
+else
+  ac_cv_flag_HAVE_FULL_RELRO=no
+fi
+rm -f core conftest.err conftest.$ac_objext \
+    conftest$ac_exeext conftest.$ac_ext
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_flag_HAVE_FULL_RELRO" >&5
+$as_echo "$ac_cv_flag_HAVE_FULL_RELRO" >&6; }
+    LDLAGS=$ac_save_LDFLAGS
+    HAVE_FULL_RELRO=$ac_cv_flag_HAVE_FULL_RELRO
+    if test "HAVE_FULL_RELRO" = yes; then
+        :
+    else
+        :
+    fi
+
+
+
+################################################################################
+
+
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking file owner" >&5
 $as_echo_n "checking file owner... " >&6; }
diff --git a/configure.in b/configure.in
index e4d0014..851d3f7 100644
--- a/configure.in
+++ b/configure.in
@@ -159,6 +159,13 @@ AC_ARG_ENABLE(static_link,
 AC_MSG_RESULT($STATIC_LINK)
 
 ################################################################################
+dnl -- Check if compiler/linker supports PIE and RELRO
+AC_TRY_CCFLAG([-pie], [HAVE_PIE], [], [])
+AC_SUBST(HAVE_PIE)
+AC_TRY_LDFLAGS([-Wl,-z,relro,-z,now], [HAVE_FULL_RELRO], [], [])
+AC_SUBST(HAVE_FULL_RELRO)
+
+################################################################################
 dnl -- Prefix is /usr by default, the exec_prefix default is setup later
 AC_PREFIX_DEFAULT(/usr)
 


