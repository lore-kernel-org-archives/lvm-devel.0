From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 18 Oct 2020 21:02:41 +0000 (GMT)
Subject: stable-2.02 - configure: check for BLKZEROOUT support
Message-ID: <20201018210241.CFE0B38618DF@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ac5cf1544efef5a585f7e66edf2d3cfbf7bbbe8d
Commit:        ac5cf1544efef5a585f7e66edf2d3cfbf7bbbe8d
Parent:        e9241860a85df1fc42cd958ca4109be850c1f8fd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 18:39:19 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 18 21:28:13 2020 +0200

configure: check for BLKZEROOUT support

---
 configure              | 57 ++++++++++++++++++++++++++++++++++++++++++++++++++
 configure.ac           | 27 ++++++++++++++++++++++++
 include/configure.h.in |  3 +++
 3 files changed, 87 insertions(+)

diff --git a/configure b/configure
index 6859d51b1..bb8d50220 100755
--- a/configure
+++ b/configure
@@ -978,6 +978,7 @@ enable_fsadm
 enable_blkdeactivate
 enable_dmeventd
 enable_selinux
+enable_blkzeroout
 enable_nls
 with_localedir
 with_confdir
@@ -1731,6 +1732,7 @@ Optional Features:
   --disable-blkdeactivate disable blkdeactivate
   --enable-dmeventd       enable the device-mapper event daemon
   --disable-selinux       disable selinux support
+  --disable-blkzeroout    do not use BLKZEROOUT for device zeroing
   --enable-nls            enable Native Language Support
 
 Optional Packages:
@@ -14113,6 +14115,61 @@ fi
 
 fi
 
+################################################################################
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for BLKZEROOUT in sys/ioctl.h." >&5
+$as_echo_n "checking for BLKZEROOUT in sys/ioctl.h.... " >&6; }
+if ${ac_cv_have_blkzeroout+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#include <sys/ioctl.h>
+#include <linux/fs.h>
+int bar(void) { return ioctl(0, BLKZEROOUT, 0); }
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
+  ac_cv_have_blkzeroout=yes
+else
+  ac_cv_have_blkzeroout=no
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.$ac_ext
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_have_blkzeroout" >&5
+$as_echo "$ac_cv_have_blkzeroout" >&6; }
+
+
+# Check whether --enable-blkzeroout was given.
+if test "${enable_blkzeroout+set}" = set; then :
+  enableval=$enable_blkzeroout; BLKZEROOUT=$enableval
+else
+  BLKZEROOUT=yes
+fi
+
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to use BLKZEROOUT for device zeroing" >&5
+$as_echo_n "checking whether to use BLKZEROOUT for device zeroing... " >&6; }
+if test "$BLKZEROOUT" = yes; then
+	if test $ac_cv_have_blkzeroout = yes; then :
+
+$as_echo "#define HAVE_BLKZEROOUT 1" >>confdefs.h
+
+else
+  BLKZEROOUT=no
+fi
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $BLKZEROOUT" >&5
+$as_echo "$BLKZEROOUT" >&6; }
+
+
 ################################################################################
 RT_LIBS=
 HAVE_REALTIME=no
diff --git a/configure.ac b/configure.ac
index 9d90ff062..f040a5a71 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1588,6 +1588,33 @@ if test "$SELINUX" = yes; then
 		HAVE_SELINUX=no ])
 fi
 
+################################################################################
+dnl -- Check BLKZEROOUT support
+
+AC_CACHE_CHECK([for BLKZEROOUT in sys/ioctl.h.],
+	[ac_cv_have_blkzeroout],
+	[AC_COMPILE_IFELSE([AC_LANG_PROGRAM(
+[#include <sys/ioctl.h>
+#include <linux/fs.h>
+int bar(void) { return ioctl(0, BLKZEROOUT, 0); }]
+	 )], [ac_cv_have_blkzeroout=yes], [ac_cv_have_blkzeroout=no])])
+
+
+AC_ARG_ENABLE(blkzeroout,
+	      AC_HELP_STRING([--disable-blkzeroout],
+			     [do not use BLKZEROOUT for device zeroing]),
+	      BLKZEROOUT=$enableval, BLKZEROOUT=yes)
+
+AC_MSG_CHECKING(whether to use BLKZEROOUT for device zeroing)
+if test "$BLKZEROOUT" = yes; then
+	AC_IF_YES(ac_cv_have_blkzeroout,
+		  AC_DEFINE(HAVE_BLKZEROOUT, 1,
+			    [Define if ioctl BLKZEROOUT can be used for device zeroing.]),
+		  BLKZEROOUT=no)
+fi
+AC_MSG_RESULT($BLKZEROOUT)
+
+
 ################################################################################
 dnl -- Check for realtime clock support
 RT_LIBS=
diff --git a/include/configure.h.in b/include/configure.h.in
index 94f755c82..49663e484 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -172,6 +172,9 @@
 /* Define to 1 if you have the `atexit' function. */
 #undef HAVE_ATEXIT
 
+/* Define if ioctl BLKZEROOUT can be used for device zeroing. */
+#undef HAVE_BLKZEROOUT
+
 /* Define to 1 if canonicalize_file_name is available. */
 #undef HAVE_CANONICALIZE_FILE_NAME
 


