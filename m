From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 18 Oct 2021 17:19:31 +0000 (GMT)
Subject: main - configure: update
Message-ID: <20211018171931.99821385840D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c60bac466175949b56b768b5e8d01ea5655a423e
Commit:        c60bac466175949b56b768b5e8d01ea5655a423e
Parent:        1b104ddb5539f998389afa3394cbc81d9410b390
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 18 19:13:58 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 18 19:17:27 2021 +0200

configure: update

---
 configure              | 116 +++++++++----------------------------------------
 include/configure.h.in |   3 --
 2 files changed, 21 insertions(+), 98 deletions(-)

diff --git a/configure b/configure
index 5719be836..cfad36e51 100755
--- a/configure
+++ b/configure
@@ -773,10 +773,10 @@ PYTHON
 LVM2CMD_LIB
 UDEV_LIBS
 UDEV_CFLAGS
-SYSTEMD_LIBS
-SYSTEMD_CFLAGS
 BLKID_LIBS
 BLKID_CFLAGS
+SYSTEMD_LIBS
+SYSTEMD_CFLAGS
 LOCKD_IDM_LIBS
 LOCKD_IDM_CFLAGS
 LOCKD_DLM_CONTROL_LIBS
@@ -964,7 +964,6 @@ enable_udev_systemd_background_jobs
 enable_udev_sync
 enable_udev_rules
 enable_udev_rule_exec_detection
-enable_compat
 enable_units_compat
 enable_ioctl
 enable_o_direct
@@ -1029,10 +1028,10 @@ LOCKD_DLM_CONTROL_CFLAGS
 LOCKD_DLM_CONTROL_LIBS
 LOCKD_IDM_CFLAGS
 LOCKD_IDM_LIBS
-BLKID_CFLAGS
-BLKID_LIBS
 SYSTEMD_CFLAGS
 SYSTEMD_LIBS
+BLKID_CFLAGS
+BLKID_LIBS
 UDEV_CFLAGS
 UDEV_LIBS
 PYTHON
@@ -1705,7 +1704,6 @@ Optional Features:
   --enable-udev_rules     install rule files needed for udev synchronisation
   --enable-udev-rule-exec-detection
                           enable executable path detection in udev rules
-  --enable-compat         enable support for old device-mapper versions
   --enable-units-compat   enable output compatibility with old versions that
                           that do not use KiB-style unit suffixes
   --disable-ioctl         disable ioctl calls to device-mapper in the kernel
@@ -1853,13 +1851,13 @@ Some influential environment variables:
               C compiler flags for LOCKD_IDM, overriding pkg-config
   LOCKD_IDM_LIBS
               linker flags for LOCKD_IDM, overriding pkg-config
-  BLKID_CFLAGS
-              C compiler flags for BLKID, overriding pkg-config
-  BLKID_LIBS  linker flags for BLKID, overriding pkg-config
   SYSTEMD_CFLAGS
               C compiler flags for SYSTEMD, overriding pkg-config
   SYSTEMD_LIBS
               linker flags for SYSTEMD, overriding pkg-config
+  BLKID_CFLAGS
+              C compiler flags for BLKID, overriding pkg-config
+  BLKID_LIBS  linker flags for BLKID, overriding pkg-config
   UDEV_CFLAGS C compiler flags for UDEV, overriding pkg-config
   UDEV_LIBS   linker flags for UDEV, overriding pkg-config
   PYTHON      the Python interpreter
@@ -3142,10 +3140,6 @@ case "$host_os" in
 		LIB_SUFFIX=so
 		DEVMAPPER=yes
 		BUILD_LVMPOLLD=no
-		LOCKDSANLOCK=no
-		LOCKDDLM=no
-		LOCKDDLM_CONTROL=no
-		LOCKDIDM=no
 		ODIRECT=yes
 		DM_IOCTLS=yes
 		SELINUX=yes
@@ -8471,6 +8465,7 @@ if test "${with_default_use_devices_file+set}" = set; then :
 else
   DEFAULT_USE_DEVICES_FILE=0
 fi
+
 case "$DEFAULT_USE_DEVICES_FILE" in
  0|1);;
  *) as_fn_error $? "--with-default-use-devices-file parameter invalid" "$LINENO" 5;;
@@ -11000,6 +10995,8 @@ $as_echo_n "checking whether to build lvmpolld... " >&6; }
 # Check whether --enable-lvmpolld was given.
 if test "${enable_lvmpolld+set}" = set; then :
   enableval=$enable_lvmpolld; LVMPOLLD=$enableval
+else
+  LVMPOLLD=no
 fi
 
 test -n "$LVMPOLLD" && BUILD_LVMPOLLD=$LVMPOLLD
@@ -11014,6 +11011,8 @@ $as_echo_n "checking whether to build lvmlockdsanlock... " >&6; }
 # Check whether --enable-lvmlockd-sanlock was given.
 if test "${enable_lvmlockd_sanlock+set}" = set; then :
   enableval=$enable_lvmlockd_sanlock; LOCKDSANLOCK=$enableval
+else
+  LOCKDSANLOCK=no
 fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $LOCKDSANLOCK" >&5
@@ -11105,6 +11104,8 @@ $as_echo_n "checking whether to build lvmlockddlm... " >&6; }
 # Check whether --enable-lvmlockd-dlm was given.
 if test "${enable_lvmlockd_dlm+set}" = set; then :
   enableval=$enable_lvmlockd_dlm; LOCKDDLM=$enableval
+else
+  LOCKDDLM=no
 fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $LOCKDDLM" >&5
@@ -11196,6 +11197,8 @@ $as_echo_n "checking whether to build lvmlockddlmcontrol... " >&6; }
 # Check whether --enable-lvmlockd-dlmcontrol was given.
 if test "${enable_lvmlockd_dlmcontrol+set}" = set; then :
   enableval=$enable_lvmlockd_dlmcontrol; LOCKDDLM_CONTROL=$enableval
+else
+  LOCKDDLM_CONTROL=no
 fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $LOCKDDLM_CONTROL" >&5
@@ -11287,6 +11290,8 @@ $as_echo_n "checking whether to build lvmlockdidm... " >&6; }
 # Check whether --enable-lvmlockd-idm was given.
 if test "${enable_lvmlockd_idm+set}" = set; then :
   enableval=$enable_lvmlockd_idm; LOCKDIDM=$enableval
+else
+  LOCKDIDM=no
 fi
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $LOCKDIDM" >&5
@@ -11366,76 +11371,15 @@ else
 $as_echo "yes" >&6; }
 	HAVE_LOCKD_IDM=yes
 fi
-
-pkg_failed=no
-{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for BLKID" >&5
-$as_echo_n "checking for BLKID... " >&6; }
-
-if test -n "$BLKID_CFLAGS"; then
-    pkg_cv_BLKID_CFLAGS="$BLKID_CFLAGS"
- elif test -n "$PKG_CONFIG"; then
-    if test -n "$PKG_CONFIG" && \
+	if test -n "$PKG_CONFIG" && \
     { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"blkid >= 2.24\""; } >&5
   ($PKG_CONFIG --exists --print-errors "blkid >= 2.24") 2>&5
   ac_status=$?
   $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  pkg_cv_BLKID_CFLAGS=`$PKG_CONFIG --cflags "blkid >= 2.24" 2>/dev/null`
-		      test "x$?" != "x0" && pkg_failed=yes
+  HAVE_LOCKD_IDM=yes
 else
-  pkg_failed=yes
-fi
- else
-    pkg_failed=untried
-fi
-if test -n "$BLKID_LIBS"; then
-    pkg_cv_BLKID_LIBS="$BLKID_LIBS"
- elif test -n "$PKG_CONFIG"; then
-    if test -n "$PKG_CONFIG" && \
-    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"blkid >= 2.24\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "blkid >= 2.24") 2>&5
-  ac_status=$?
-  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
-  test $ac_status = 0; }; then
-  pkg_cv_BLKID_LIBS=`$PKG_CONFIG --libs "blkid >= 2.24" 2>/dev/null`
-		      test "x$?" != "x0" && pkg_failed=yes
-else
-  pkg_failed=yes
-fi
- else
-    pkg_failed=untried
-fi
-
-
-
-if test $pkg_failed = yes; then
-   	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
-
-if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
-        _pkg_short_errors_supported=yes
-else
-        _pkg_short_errors_supported=no
-fi
-        if test $_pkg_short_errors_supported = yes; then
-	        BLKID_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "blkid >= 2.24" 2>&1`
-        else
-	        BLKID_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "blkid >= 2.24" 2>&1`
-        fi
-	# Put the nasty error message in config.log where it belongs
-	echo "$BLKID_PKG_ERRORS" >&5
-
-	$bailout
-elif test $pkg_failed = untried; then
-     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
-	$bailout
-else
-	BLKID_CFLAGS=$pkg_cv_BLKID_CFLAGS
-	BLKID_LIBS=$pkg_cv_BLKID_LIBS
-        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-$as_echo "yes" >&6; }
-	HAVE_LOCKD_IDM=yes
+  $bailout
 fi
 
 $as_echo "#define LOCKDIDM_SUPPORT 1" >>confdefs.h
@@ -12085,24 +12029,6 @@ $as_echo_n "checking whether udev supports built-in blkid... " >&6; }
 $as_echo "$UDEV_HAS_BUILTIN_BLKID" >&6; }
 fi
 
-################################################################################
-# Check whether --enable-compat was given.
-if test "${enable_compat+set}" = set; then :
-  enableval=$enable_compat; DM_COMPAT=$enableval
-else
-  DM_COMPAT=no
-fi
-
-
-if test "$DM_COMPAT" = yes; then :
-
-$as_echo "#define DM_COMPAT 1" >>confdefs.h
-
-      as_fn_error $? "--enable-compat is not currently supported.
-Since device-mapper version 1.02.66, only one version (4) of the device-mapper
-ioctl protocol is supported." "$LINENO" 5
-fi
-
 ################################################################################
 # Check whether --enable-units-compat was given.
 if test "${enable_units_compat+set}" = set; then :
diff --git a/include/configure.h.in b/include/configure.h.in
index 7efa83661..e0d971bbf 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -114,9 +114,6 @@
 /* Define to 1 to enable the device-mapper filemap daemon. */
 #undef DMFILEMAPD
 
-/* Define to enable compat protocol */
-#undef DM_COMPAT
-
 /* Define default group for device node */
 #undef DM_DEVICE_GID
 


