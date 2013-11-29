From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 29 Nov 2013 14:28:48 +0000 (UTC)
Subject: master - configure: enable blkid_wiping by default if the blkid library is present
Message-ID: <20131129142848.B9FA861144@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=75628f341ad38b68aae33eae0b5700be2a6e5769
Commit:        75628f341ad38b68aae33eae0b5700be2a6e5769
Parent:        b3074560eb36d0b1c8ec61f50e71b0b27dbda982
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Nov 29 15:27:56 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Nov 29 15:27:56 2013 +0100

configure: enable blkid_wiping by default if the blkid library is present

---
 WHATS_NEW               |    3 +-
 configure               |   53 ++++++++++++++++++++--------------------------
 configure.in            |   29 +++++++++++++++++--------
 lib/misc/configure.h.in |    2 +-
 4 files changed, 46 insertions(+), 41 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6aac94a..0101b49 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -3,7 +3,8 @@ Version 2.02.105 -
   Append missing newline to lvmetad missing socket path error message.
   Check for non-zero aligment in _text_pv_add_metadata_area() to not div by 0.
   Add allocation/use_blkid_wiping to lvm.conf to enable blkid wiping.
-  Add configure --enable-blkid_wiping to use libblkid to detect signatures.
+  Enable blkid_wiping by default if the blkid library is present.
+  Add configure --disable-blkid_wiping to disable libblkid signature detection.
   Add -W/--wipesignatures lvcreate option to support wiping on new LVs.
   Add allocation/wipe_signatures_on_new_logical_volumes_when_zeroing to lvm.conf.
   Do not fail the whole autoactivation if the VG refresh done before fails.
diff --git a/configure b/configure
index 8247ddd..5d81dac 100755
--- a/configure
+++ b/configure
@@ -1563,7 +1563,8 @@ Optional Features:
   --enable-valgrind-pool  enable valgrind awareness of pools
   --disable-devmapper     disable LVM2 device-mapper interaction
   --enable-lvmetad        enable the LVM Metadata Daemon
-  --enable-blkid_wiping   use wiping functionality provided by libblkid
+  --disable-blkid_wiping  disable libblkid detection of signatures when wiping
+                          and use native code instead
   --enable-udev-systemd-background-jobs
                           enable udev-systemd protocol to instantiate a
                           service for background job
@@ -9185,20 +9186,19 @@ _ACEOF
 fi
 
 ################################################################################
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to use blkid wiping functionality" >&5
-$as_echo_n "checking whether to use blkid wiping functionality... " >&6; }
-# Check whether --enable-blkid-wiping was given.
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable libblkid detection of signatures when wiping" >&5
+$as_echo_n "checking whether to enable libblkid detection of signatures when wiping... " >&6; }
+# Check whether --enable-blkid_wiping was given.
 if test "${enable_blkid_wiping+set}" = set; then :
   enableval=$enable_blkid_wiping; BLKID_WIPING=$enableval
 else
-  BLKID_WIPING=no
+  BLKID_WIPING=maybe
 fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $BLKID_WIPING" >&5
 $as_echo "$BLKID_WIPING" >&6; }
 
-
-if test x$BLKID_WIPING = xyes; then
+if test x$BLKID_WIPING != xno; then
 		if test x$PKGCONFIG_INIT != x1; then
 		pkg_config_init
 	fi
@@ -9259,43 +9259,36 @@ fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$BLKID_PKG_ERRORS" >&5
 
-	as_fn_error $? "Package requirements (blkid >= 2.22) were not met:
-
-$BLKID_PKG_ERRORS
-
-Consider adjusting the PKG_CONFIG_PATH environment variable if you
-installed software in a non-standard prefix.
-
-Alternatively, you may set the environment variables BLKID_CFLAGS
-and BLKID_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details." "$LINENO" 5
+	if test x$BLKID_WIPING = xmaybe; then
+					BLKID_WIPING=no
+				 else
+					as_fn_error $? "bailing out... blkid library >= 2.22 is required" "$LINENO" 5
+				 fi
 
 elif test $pkg_failed = untried; then
      	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
 $as_echo "no" >&6; }
-	{ { $as_echo "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
-$as_echo "$as_me: error: in \`$ac_pwd':" >&2;}
-as_fn_error $? "The pkg-config script could not be found or is too old.  Make sure it
-is in your PATH or set the PKG_CONFIG environment variable to the full
-path to pkg-config.
-
-Alternatively, you may set the environment variables BLKID_CFLAGS
-and BLKID_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details.
-
-To get pkg-config, see <http://pkg-config.freedesktop.org/>.
-See \`config.log' for more details" "$LINENO" 5; }
+	if test x$BLKID_WIPING = xmaybe; then
+					BLKID_WIPING=no
+				 else
+					as_fn_error $? "bailing out... blkid library >= 2.22 is required" "$LINENO" 5
+				 fi
 
 else
 	BLKID_CFLAGS=$pkg_cv_BLKID_CFLAGS
 	BLKID_LIBS=$pkg_cv_BLKID_LIBS
         { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 $as_echo "yes" >&6; }
-	BLKID_PC="blkid"
+	if test x$BLKID_WIPING = xmaybe; then
+					BLKID_WIPING=yes
+				 fi
 fi
+	if test x$BLKID_WIPING = xyes; then
+		BLKID_PC="blkid"
 
 $as_echo "#define BLKID_WIPING_SUPPORT 1" >>confdefs.h
 
+	fi
 fi
 
 ################################################################################
diff --git a/configure.in b/configure.in
index ff9bf81..b4a407a 100644
--- a/configure.in
+++ b/configure.in
@@ -947,21 +947,32 @@ fi
 
 ################################################################################
 dnl -- Enable blkid wiping functionality
-AC_MSG_CHECKING(whether to use blkid wiping functionality)
-AC_ARG_ENABLE(blkid-wiping,
-	      AC_HELP_STRING([--enable-blkid_wiping],
-			     [use wiping functionality provided by libblkid]),
-	      BLKID_WIPING=$enableval, BLKID_WIPING=no)
+AC_MSG_CHECKING(whether to enable libblkid detection of signatures when wiping)
+AC_ARG_ENABLE(blkid_wiping,
+	      AC_HELP_STRING([--disable-blkid_wiping],
+			     [disable libblkid detection of signatures when wiping and use native code instead]),
+	      BLKID_WIPING=$enableval, BLKID_WIPING=maybe)
 AC_MSG_RESULT($BLKID_WIPING)
 
-
-if test x$BLKID_WIPING = xyes; then
+if test x$BLKID_WIPING != xno; then
 	dnl -- init pkgconfig if required
 	if test x$PKGCONFIG_INIT != x1; then
 		pkg_config_init
 	fi
-	PKG_CHECK_MODULES(BLKID, blkid >= 2.22, [BLKID_PC="blkid"])
-	AC_DEFINE([BLKID_WIPING_SUPPORT], 1, [Define to 1 to use wiping functionality provided by libblkid.])
+	PKG_CHECK_MODULES(BLKID, blkid >= 2.22,
+				[if test x$BLKID_WIPING = xmaybe; then
+					BLKID_WIPING=yes
+				 fi],
+				[if test x$BLKID_WIPING = xmaybe; then
+					BLKID_WIPING=no
+				 else
+					AC_MSG_ERROR([bailing out... blkid library >= 2.22 is required])
+				 fi
+				])
+	if test x$BLKID_WIPING = xyes; then
+		BLKID_PC="blkid"
+		AC_DEFINE([BLKID_WIPING_SUPPORT], 1, [Define to 1 to use libblkid detection of signatures when wiping.])
+	fi
 fi
 
 ################################################################################
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 51db42e..4e9ffd1 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -1,6 +1,6 @@
 /* lib/misc/configure.h.in.  Generated from configure.in by autoheader.  */
 
-/* Define to 1 to use wiping functionality provided by libblkid. */
+/* Define to 1 to use libblkid detection of signatures when wiping. */
 #undef BLKID_WIPING_SUPPORT
 
 /* Define to 1 if the `closedir' function returns void instead of `int'. */


