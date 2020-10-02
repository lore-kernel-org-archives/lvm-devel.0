From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  2 Oct 2020 20:27:46 +0000 (GMT)
Subject: master - configure: check for BLKZEROOUT support
Message-ID: <20201002202746.82F43398E4B4@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ae96a43f05e7d5b9a420735bd4b652b275a3fe8f
Commit:        ae96a43f05e7d5b9a420735bd4b652b275a3fe8f
Parent:        91f869e43c8f3161d8bcc54477dfab4024a73a58
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 18:39:19 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 2 20:48:41 2020 +0200

configure: check for BLKZEROOUT support

---
 configure              | 57 ++++++++++++++++++++++++++++++++++++++++++++++++++
 configure.ac           | 27 ++++++++++++++++++++++++
 include/configure.h.in |  3 +++
 3 files changed, 87 insertions(+)

diff --git a/configure b/configure
index c125aade1..81f6d0875 100755
--- a/configure
+++ b/configure
@@ -963,6 +963,7 @@ enable_fsadm
 enable_blkdeactivate
 enable_dmeventd
 enable_selinux
+enable_blkzeroout
 enable_nls
 with_localedir
 with_confdir
@@ -1684,6 +1685,7 @@ Optional Features:
   --disable-blkdeactivate disable blkdeactivate
   --enable-dmeventd       enable the device-mapper event daemon
   --disable-selinux       disable selinux support
+  --disable-blkzeroout    do not use BLKZEROOUT for device zeroing
   --enable-nls            enable Native Language Support
 
 Optional Packages:
@@ -12707,6 +12709,61 @@ fi
 
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
index 148bde426..341591561 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1351,6 +1351,33 @@ if test "$SELINUX" = yes; then
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
index 46d5aef20..59b4da86f 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -154,6 +154,9 @@
 /* Define to 1 if you have the `atexit' function. */
 #undef HAVE_ATEXIT
 
+/* Define if ioctl BLKZEROOUT can be used for device zeroing. */
+#undef HAVE_BLKZEROOUT
+
 /* Define to 1 if canonicalize_file_name is available. */
 #undef HAVE_CANONICALIZE_FILE_NAME
 


