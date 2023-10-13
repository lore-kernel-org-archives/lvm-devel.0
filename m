From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Fri, 13 Oct 2023 12:37:22 +0000
Subject: [Git][lvmteam/lvm2][main] 11 commits: device_mapper: pair with libdm _create_and_load_v4
Message-ID: <65293a02b047c_2ca52f8204c@gitlab-sidekiq-low-urgency-cpu-bound-v2-868ddd547d-75g4c.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
fb124f08 by Zdenek Kabelac at 2023-10-13T14:24:49+02:00
device_mapper: pair with libdm _create_and_load_v4

Apply same enhancement also for internal device mapper library
from the commit: 25ef7a7b1a876f491bd361369423d7309358f6c1.

- - - - -
dc8837f0 by Adam Joseph at 2023-10-13T14:25:02+02:00
configure.ac: handle --disable-shared flag

Since LVM 2.02 it appears that compiling LVM on a platform which
lacks a shared library linker/loader will fail to produce any
binaries (dmsetup, lvm2, etc).

Adds support for the standard --disable-shared flag, and
use it to disable attempts at building shared libraries.

Modified-by: zkabelac

- - - - -
48fd9fbd by Zdenek Kabelac at 2023-10-13T14:25:02+02:00
configure.ac: support for static linking

Introduce couple configure options:

--without-blkid
--without-systemd
--without-udev

These can be useful for build with --disable-shared
where those libraries are often distibuted without
their static libraries.

However such compiled static binaries then have limitted usage.

- - - - -
f117d47f by Zdenek Kabelac at 2023-10-13T14:25:02+02:00
configure.ac: version checking for new dmpd tools

New rust version of thin_check returns now also binary name in version,
so adapt the version checking to handle this variant.

- - - - -
627535f3 by Zdenek Kabelac at 2023-10-13T14:25:02+02:00
tests: use function to restart dmeventd

Move restart to single function.

- - - - -
53da6464 by Zdenek Kabelac at 2023-10-13T14:25:02+02:00
tests: fail tests when machine have suspended devs

If the machine has suspended devices present in the DM table,
it&#39;s better to fail the test.

- - - - -
061c008e by Zdenek Kabelac at 2023-10-13T14:25:02+02:00
tests: some minor enhancement of udev test

Reduce pgrep usage.

- - - - -
be2b3d5a by Zdenek Kabelac at 2023-10-13T14:25:02+02:00
tests: increase delay

- - - - -
1605d39b by Zdenek Kabelac at 2023-10-13T14:25:02+02:00
tests: comment about version checking to aux.sh

If there would be futher version checking needed,
make a notice there are now two -V formats.

- - - - -
9fa36441 by Zdenek Kabelac at 2023-10-13T14:33:56+02:00
tests: skip for missing mkfs.xfs

- - - - -
8b8b8ac1 by Zdenek Kabelac at 2023-10-13T14:33:56+02:00
configure: update

- - - - -


13 changed files:

- configure
- configure.ac
- device_mapper/ioctl/libdm-iface.c
- libdm/Makefile.in
- libdm/dm-tools/Makefile.in
- libdm/make.tmpl.in
- make.tmpl.in
- test/lib/aux.sh
- test/lib/inittest.sh
- test/shell/dmeventd-restart.sh
- test/shell/dmsecuretest.sh
- test/shell/dmstats-filemap.sh
- tools/Makefile.in


Changes:

=====================================
configure
=====================================
@@ -681,6 +681,7 @@ STATIC_LDFLAGS
 STATICDIR
 SNAPSHOTS
 SILENT_RULES
+SHARED_LINK
 SELINUX_STATIC_LIBS
 SELINUX_PC
 SBINDIR
@@ -914,6 +915,10 @@ enable_option_checking
 enable_dependency_tracking
 enable_silent_rules
 enable_static_link
+enable_shared
+with_blkid
+with_systemd
+with_udev
 with_user
 with_group
 with_device_uid
@@ -1685,6 +1690,7 @@ Optional Features:
   --disable-silent-rules  disable silent building
   --enable-static_link    use this to link the tools to their libraries
                           statically (default is dynamic linking
+  --disable-shared        disable dynamic linking
   --disable-thin_check_needs_check
                           required if thin_check version is < 0.3.0
   --disable-cache_check_needs_check
@@ -1738,6 +1744,9 @@ Optional Features:
 Optional Packages:
   --with-PACKAGE[=ARG]    use PACKAGE [ARG=yes]
   --without-PACKAGE       do not use PACKAGE (same as --with-PACKAGE=no)
+  --without-blkid         do not build with blkid library
+  --without-systemd       do not build with systemd library
+  --without-udev          do not build with udev library
   --with-user=USER        set the owner of installed files [USER=]
   --with-group=GROUP      set the group owner of installed files [GROUP=]
   --with-device-uid=UID   set the owner used for new device nodes [UID=0]
@@ -9058,6 +9067,20 @@ fi
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $STATIC_LINK" >&5
 printf "%s\n" "$STATIC_LINK" >&6; }
 
+################################################################################
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to use dynamic linking" >&5
+printf %s "checking whether to use dynamic linking... " >&6; }
+# Check whether --enable-shared was given.
+if test ${enable_shared+y}
+then :
+  enableval=$enable_shared; SHARED_LINK=$enableval
+else $as_nop
+  SHARED_LINK="yes"
+fi
+
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $SHARED_LINK" >&5
+printf "%s\n" "$SHARED_LINK" >&6; }
+
 ################################################################################
 
 
@@ -9151,6 +9174,35 @@ test "$prefix" = "NONE" && prefix=$ac_default_prefix
 # Let make expand exec_prefix.
 test "$exec_prefix" = "NONE" && exec_prefix='${prefix}'
 
+
+
+# Check whether --with-blkid was given.
+if test ${with_blkid+y}
+then :
+  withval=$with_blkid;
+else $as_nop
+  with_blkid="yes"
+fi
+
+
+# Check whether --with-systemd was given.
+if test ${with_systemd+y}
+then :
+  withval=$with_systemd;
+else $as_nop
+  with_systemd="yes"
+fi
+
+
+# Check whether --with-udev was given.
+if test ${with_udev+y}
+then :
+  withval=$with_udev;
+else $as_nop
+  with_udev="yes"
+fi
+
+
 ################################################################################
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking file owner" >&5
 printf %s "checking file owner... " >&6; }
@@ -9627,6 +9679,7 @@ fi
 then :
 
 		THIN_CHECK_VSN=$("$THIN_CHECK_CMD" -V 2>/dev/null)
+		THIN_CHECK_VSN=${THIN_CHECK_VSN##* }  # trim away all before the first space
 		THIN_CHECK_VSN_MAJOR=$(echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $1}')
 		THIN_CHECK_VSN_MINOR=$(echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $2}')
 
@@ -10019,8 +10072,8 @@ fi
 
 fi
 
-	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether thin_check supports the needs-check flag" >&5
-printf %s "checking whether thin_check supports the needs-check flag... " >&6; }
+	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether $THIN_CHECK_CMD ($THIN_CHECK_VSN_MAJOR.$THIN_CHECK_VSN_MINOR) supports the needs-check flag" >&5
+printf %s "checking whether $THIN_CHECK_CMD ($THIN_CHECK_VSN_MAJOR.$THIN_CHECK_VSN_MINOR) supports the needs-check flag... " >&6; }
 	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $THIN_CHECK_NEEDS_CHECK" >&5
 printf "%s\n" "$THIN_CHECK_NEEDS_CHECK" >&6; }
 	if test "$THIN_CHECK_NEEDS_CHECK" = "yes"
@@ -10255,12 +10308,13 @@ fi
 	if test "$CACHE_CHECK_NEEDS_CHECK" = "yes" && test "$CACHE_CONFIGURE_WARN" != "y"
 then :
 
-		$CACHE_CHECK_CMD -V 2>/dev/null >conftest.tmp
+		"$CACHE_CHECK_CMD" -V 2>/dev/null >conftest.tmp
 		read -r CACHE_CHECK_VSN < conftest.tmp
 		IFS=.- read -r CACHE_CHECK_VSN_MAJOR CACHE_CHECK_VSN_MINOR CACHE_CHECK_VSN_PATCH LEFTOVER < conftest.tmp
 		rm -f conftest.tmp
 
 		# Require version >= 0.5.4 for --clear-needs-check-flag
+		CACHE_CHECK_VSN_MAJOR=${CACHE_CHECK_VSN_MAJOR##* }
 		if test -z "$CACHE_CHECK_VSN_MAJOR" \
 			|| test -z "$CACHE_CHECK_VSN_MINOR" \
 			|| test -z "$CACHE_CHECK_VSN_PATCH"
@@ -10666,8 +10720,8 @@ fi
 
 fi
 
-	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether cache_check supports the needs-check flag" >&5
-printf %s "checking whether cache_check supports the needs-check flag... " >&6; }
+	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether $CACHE_CHECK_CMD ($CACHE_CHECK_VSN_MAJOR.$CACHE_CHECK_VSN_MINOR.$CACHE_CHECK_VSN_PATCH) supports the needs-check flag" >&5
+printf %s "checking whether $CACHE_CHECK_CMD ($CACHE_CHECK_VSN_MAJOR.$CACHE_CHECK_VSN_MINOR.$CACHE_CHECK_VSN_PATCH) supports the needs-check flag... " >&6; }
 	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CACHE_CHECK_NEEDS_CHECK" >&5
 printf "%s\n" "$CACHE_CHECK_NEEDS_CHECK" >&6; }
 	if test "$CACHE_CHECK_NEEDS_CHECK" = "yes"
@@ -12611,21 +12665,27 @@ printf "%s\n" "#define DEFAULT_USE_LVMPOLLD $DEFAULT_USE_LVMPOLLD" >>confdefs.h
 
 
 SYSTEMD_MIN_VERSION=0
-if test -n "$PKG_CONFIG" && \
+SYSTEMD_JOURNAL_SUPPORT="no"
+APP_MACHINEID_SUPPORT="no"
+
+if test "$with_systemd" = "yes"
+then :
+  if test -n "$PKG_CONFIG" && \
     { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 221\""; } >&5
   ($PKG_CONFIG --exists --print-errors "systemd >= 221") 2>&5
   ac_status=$?
   printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  SYSTEMD_MIN_VERSION=221
+  SYSTEMD_MIN_VERSION=221 SYSTEMD_JOURNAL_SUPPORT="maybe"
 fi
-if test -n "$PKG_CONFIG" && \
+      if test -n "$PKG_CONFIG" && \
     { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 234\""; } >&5
   ($PKG_CONFIG --exists --print-errors "systemd >= 234") 2>&5
   ac_status=$?
   printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  SYSTEMD_MIN_VERSION=234
+  SYSTEMD_MIN_VERSION=234 APP_MACHINEID_SUPPORT="maybe"
+fi
 fi
 
 ################################################################################
@@ -12639,50 +12699,44 @@ else $as_nop
   NOTIFYDBUS_SUPPORT="no"
 fi
 
-if test "$NOTIFYDBUS_SUPPORT" = "yes" && test "$SYSTEMD_MIN_VERSION" -lt 221
-then :
-  as_fn_error $? "Enabling notify-dbus requires systemd >= 221" "$LINENO" 5
-fi
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $NOTIFYDBUS_SUPPORT" >&5
 printf "%s\n" "$NOTIFYDBUS_SUPPORT" >&6; }
 
 if test "$NOTIFYDBUS_SUPPORT" = "yes"
 then :
+  if test "$SYSTEMD_MIN_VERSION" -lt 221
+then :
+  as_fn_error $? "--enable-notify-dbus requires systemd >= 221. (--with-systemd=$with_systemd)" "$LINENO" 5
+fi
 
 printf "%s\n" "#define NOTIFYDBUS_SUPPORT 1" >>confdefs.h
 
 fi
 
 ################################################################################
-if test "$SYSTEMD_MIN_VERSION" -ge 221
+if test "$SYSTEMD_JOURNAL_SUPPORT" != "no"
 then :
-  SYSTEMD_JOURNAL_SUPPORT="maybe"
-else $as_nop
-  SYSTEMD_JOURNAL_SUPPORT="no"
-fi
-ac_fn_c_check_header_compile "$LINENO" "systemd/sd-journal.h" "ac_cv_header_systemd_sd_journal_h" "$ac_includes_default"
+  ac_fn_c_check_header_compile "$LINENO" "systemd/sd-journal.h" "ac_cv_header_systemd_sd_journal_h" "$ac_includes_default"
 if test "x$ac_cv_header_systemd_sd_journal_h" = xyes
-then :
-  if test "$SYSTEMD_JOURNAL_SUPPORT" != "no"
 then :
   SYSTEMD_JOURNAL_SUPPORT="yes"
-fi
 else $as_nop
   SYSTEMD_JOURNAL_SUPPORT="no"
 fi
 
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to log to systemd journal" >&5
-printf %s "checking whether to log to systemd journal... " >&6; }
+fi
 # Check whether --enable-systemd-journal was given.
 if test ${enable_systemd_journal+y}
 then :
   enableval=$enable_systemd_journal; if test "$enableval" = "yes" && test "$SYSTEMD_JOURNAL_SUPPORT" = "no"
 then :
-  as_fn_error $? "Enabling systemd journal requires systemd/sd-journal.h and systemd >= 221." "$LINENO" 5
+  as_fn_error $? "--enable-systemd-journal requires systemd/sd-journal.h and systemd >= 221. (--with-systemd=$with_systemd)" "$LINENO" 5
 fi
 	      SYSTEMD_JOURNAL_SUPPORT=$enableval
 fi
 
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to log to systemd journal" >&5
+printf %s "checking whether to log to systemd journal... " >&6; }
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $SYSTEMD_JOURNAL_SUPPORT" >&5
 printf "%s\n" "$SYSTEMD_JOURNAL_SUPPORT" >&6; }
 
@@ -12694,35 +12748,29 @@ printf "%s\n" "#define SYSTEMD_JOURNAL_SUPPORT 1" >>confdefs.h
 fi
 
 ################################################################################
-if test "$SYSTEMD_MIN_VERSION" -ge 234
+if test "$APP_MACHINEID_SUPPORT" != "no"
 then :
-  APP_MACHINEID_SUPPORT="maybe"
-else $as_nop
-  APP_MACHINEID_SUPPORT="no"
-fi
-ac_fn_c_check_header_compile "$LINENO" "systemd/sd-id128.h" "ac_cv_header_systemd_sd_id128_h" "$ac_includes_default"
+  ac_fn_c_check_header_compile "$LINENO" "systemd/sd-id128.h" "ac_cv_header_systemd_sd_id128_h" "$ac_includes_default"
 if test "x$ac_cv_header_systemd_sd_id128_h" = xyes
-then :
-  if test "$APP_MACHINEID_SUPPORT" != "no"
 then :
   APP_MACHINEID_SUPPORT="yes"
-fi
 else $as_nop
   APP_MACHINEID_SUPPORT="no"
 fi
 
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to support systemd appmachineid" >&5
-printf %s "checking whether to support systemd appmachineid... " >&6; }
+fi
 # Check whether --enable-app-machineid was given.
 if test ${enable_app_machineid+y}
 then :
   enableval=$enable_app_machineid; if test "$enableval" = "yes" && test "$APP_MACHINEID_SUPPORT" = "no"
 then :
-  as_fn_error $? "Enabling app machineid requires systemd/sd-id128.h and systemd >= 234." "$LINENO" 5
+  as_fn_error $? "--enable-app-machineid requires systemd/sd-id128.h and systemd >= 234. (--with-systemd=$with_systemd)" "$LINENO" 5
 fi
 	      APP_MACHINEID_SUPPORT=$enableval
 fi
 
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to support systemd appmachineid" >&5
+printf %s "checking whether to support systemd appmachineid... " >&6; }
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $APP_MACHINEID_SUPPORT" >&5
 printf "%s\n" "$APP_MACHINEID_SUPPORT" >&6; }
 
@@ -12962,31 +13010,25 @@ printf "%s\n" "$SYSTEMD_RUN_CMD" >&6; }
 
 ################################################################################
 
+# TODO: possibly detect right version of blkid with BLKID_SUBLKS_FSINFO support
+#       so lvresize can check detected flag here
+#
+DEFAULT_USE_BLKID_WIPING=0
 # Check whether --enable-blkid_wiping was given.
 if test ${enable_blkid_wiping+y}
 then :
   enableval=$enable_blkid_wiping; BLKID_WIPING=$enableval
 else $as_nop
+  if test "$with_blkid" = "yes"
+then :
   BLKID_WIPING="maybe"
+else $as_nop
+  BLKID_WIPING="no"
 fi
-
-
-# TODO: possibly detect right version of blkid with BLKID_SUBLKS_FSINFO support
-#       so lvresize can check detected flag here
-#
-DEFAULT_USE_BLKID_WIPING=0
-if test -n "$PKG_CONFIG" && \
-    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"blkid >= 2.24\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "blkid >= 2.24") 2>&5
-  ac_status=$?
-  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
-  test $ac_status = 0; }; then
-  HAVE_BLKID="yes"
-else
-  HAVE_BLKID="no"
 fi
 
-if test "$HAVE_BLKID" = "yes"
+
+if test "$BLKID_WIPING" != "no"
 then :
 
 
@@ -13048,39 +13090,28 @@ fi
         # Put the nasty error message in config.log where it belongs
         echo "$BLKID_PKG_ERRORS" >&5
 
-        as_fn_error $? "Package requirements (blkid >= 2.24) were not met:
-
-$BLKID_PKG_ERRORS
-
-Consider adjusting the PKG_CONFIG_PATH environment variable if you
-installed software in a non-standard prefix.
-
-Alternatively, you may set the environment variables BLKID_CFLAGS
-and BLKID_LIBS to avoid the need to call pkg-config.
-See the pkg-config man page for more details." "$LINENO" 5
+        if test "$BLKID_WIPING" = "yes"
+then :
+  BLKID_WIPING="error"
+else $as_nop
+  BLKID_WIPING="no"
+fi
 elif test $pkg_failed = untried; then
         { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
-        { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
-printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
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
+        if test "$BLKID_WIPING" = "yes"
+then :
+  BLKID_WIPING="error"
+else $as_nop
+  BLKID_WIPING="no"
+fi
 else
         BLKID_CFLAGS=$pkg_cv_BLKID_CFLAGS
         BLKID_LIBS=$pkg_cv_BLKID_LIBS
         { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 printf "%s\n" "yes" >&6; }
 
-
-	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for blkid.h defines BLKID_SUBLKS_FSINFO." >&5
+		{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for blkid.h defines BLKID_SUBLKS_FSINFO." >&5
 printf %s "checking for blkid.h defines BLKID_SUBLKS_FSINFO.... " >&6; }
 if test ${ac_cv_have_blkid_sublks_fsinfo+y}
 then :
@@ -13092,6 +13123,7 @@ else $as_nop
 #ifndef BLKID_SUBLKS_FSINFO
 #error BLKID_SUBLKS_FSINFO is missing
 #endif
+
 int
 main (void)
 {
@@ -13111,47 +13143,38 @@ fi
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_have_blkid_sublks_fsinfo" >&5
 printf "%s\n" "$ac_cv_have_blkid_sublks_fsinfo" >&6; }
 
-	if test $ac_cv_have_blkid_sublks_fsinfo = yes
+		if test $ac_cv_have_blkid_sublks_fsinfo = yes
 then :
 
 printf "%s\n" "#define HAVE_BLKID_SUBLKS_FSINFO 1" >>confdefs.h
 
 fi
 
-fi
-
-fi
-
-if test "$BLKID_WIPING" != "no"
+		if test "$with_blkid" = "no"
 then :
-
-	if test "$HAVE_BLKID" = "yes"
-then :
-
-		BLKID_WIPING="yes"
-		BLKID_PC="blkid"
-		DEFAULT_USE_BLKID_WIPING=1
-		BLKID_STATIC_LIBS=$("$PKG_CONFIG" --static --libs blkid)
-
-printf "%s\n" "#define BLKID_WIPING_SUPPORT 1" >>confdefs.h
-
-
+  BLKID_WIPING="error"
 else $as_nop
 
-		if test "$BLKID_WIPING" = "maybe"
-then :
+			BLKID_WIPING="yes"
+			BLKID_PC="blkid"
+			DEFAULT_USE_BLKID_WIPING=1
+			# pkg_config --static  does not really work ATM...
+			BLKID_STATIC_LIBS=$("$PKG_CONFIG" --static --libs blkid)
 
-			BLKID_WIPING=no
+printf "%s\n" "#define BLKID_WIPING_SUPPORT 1" >>confdefs.h
 
-else $as_nop
 
-			as_fn_error $? "bailing out... blkid library >= 2.24 is required" "$LINENO" 5
+fi
 
 fi
 
 fi
 
+if test "$BLKID_WIPING" = "error"
+then :
+  as_fn_error $? "--enable-blkid_wiping requires blkid library >= 2.24. (--with-blkid=$with_blkid)" "$LINENO" 5
 fi
+
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to enable libblkid detection of signatures when wiping" >&5
 printf %s "checking whether to enable libblkid detection of signatures when wiping... " >&6; }
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BLKID_WIPING" >&5
@@ -13173,6 +13196,10 @@ fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $UDEV_SYNC" >&5
 printf "%s\n" "$UDEV_SYNC" >&6; }
+if test "$UDEV_SYNC" = "yes" && test "$with_udev" = "no"
+then :
+  as_fn_error $? "--enable-udev_sync requires udev >= 143. (--with-udev=$with_udev)" "$LINENO" 5
+fi
 
 if test "$UDEV_SYNC" = "yes"
 then :
@@ -13439,7 +13466,11 @@ printf "%s\n" "$CMDLIB" >&6; }
 
 if test "$CMDLIB" = "yes"
 then :
-  LVM2CMD_LIB="-llvm2cmd"
+  if test "$SHARED_LINK" = "no"
+then :
+  as_fn_error $? "--enable-cmdlib requires dynamic linking." "$LINENO" 5
+fi
+       LVM2CMD_LIB="-llvm2cmd"
 else $as_nop
   LVM2CMD_LIB=
 fi
@@ -16246,6 +16277,7 @@ AIO_LIBS=${AIO_LIBS:--laio}
 
 
 
+
 
 
 ################################################################################


=====================================
configure.ac
=====================================
@@ -185,6 +185,14 @@ AC_ARG_ENABLE(static_link,
 	      STATIC_LINK=$enableval, STATIC_LINK="no")
 AC_MSG_RESULT([$STATIC_LINK])
 
+################################################################################
+dnl -- Disables shared linking
+AC_MSG_CHECKING([whether to use dynamic linking])
+AC_ARG_ENABLE(shared,
+	      AS_HELP_STRING([--disable-shared], [disable dynamic linking]),
+	      SHARED_LINK=$enableval, SHARED_LINK="yes")
+AC_MSG_RESULT([$SHARED_LINK])
+
 ################################################################################
 dnl -- Check if compiler/linker supports PIE and RELRO
 AC_TRY_CCFLAG([-pie], [HAVE_PIE], [], [])
@@ -204,6 +212,14 @@ test "$prefix" = "NONE" && prefix=$ac_default_prefix
 # Let make expand exec_prefix.
 test "$exec_prefix" = "NONE" && exec_prefix='${prefix}'
 
+
+AC_ARG_WITH(blkid, [AS_HELP_STRING([--without-blkid], [do not build with blkid library])],
+	    [], with_blkid="yes")
+AC_ARG_WITH(systemd, [AS_HELP_STRING([--without-systemd], [do not build with systemd library])],
+	    [], with_systemd="yes")
+AC_ARG_WITH(udev, [AS_HELP_STRING([--without-udev], [do not build with udev library])],
+	    [], with_udev="yes")
+
 ################################################################################
 dnl -- Setup the ownership of the files
 AC_MSG_CHECKING([file owner])
@@ -410,6 +426,7 @@ AS_CASE(["$THIN"],
 	])
 	AS_IF([test "$THIN_CHECK_NEEDS_CHECK" = "yes" && test "$THIN_CONFIGURE_WARN" != "y"], [
 		THIN_CHECK_VSN=$("$THIN_CHECK_CMD" -V 2>/dev/null)
+		THIN_CHECK_VSN=${THIN_CHECK_VSN##* }  # trim away all before the first space
 		THIN_CHECK_VSN_MAJOR=$(echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $1}')
 		THIN_CHECK_VSN_MINOR=$(echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $2}')
 
@@ -451,7 +468,7 @@ AS_CASE(["$THIN"],
 		])
 	])
 
-	AC_MSG_CHECKING([whether thin_check supports the needs-check flag])
+	AC_MSG_CHECKING([whether $THIN_CHECK_CMD ($THIN_CHECK_VSN_MAJOR.$THIN_CHECK_VSN_MINOR) supports the needs-check flag])
 	AC_MSG_RESULT([$THIN_CHECK_NEEDS_CHECK])
 	AS_IF([test "$THIN_CHECK_NEEDS_CHECK" = "yes"], [
 		AC_DEFINE([THIN_CHECK_NEEDS_CHECK], 1, [Define to 1 if the external 'thin_check' tool requires the --clear-needs-check-flag option])
@@ -521,12 +538,13 @@ AS_CASE(["$CACHE"],
 		])
 	])
 	AS_IF([test "$CACHE_CHECK_NEEDS_CHECK" = "yes" && test "$CACHE_CONFIGURE_WARN" != "y"], [
-		$CACHE_CHECK_CMD -V 2>/dev/null >conftest.tmp
+		"$CACHE_CHECK_CMD" -V 2>/dev/null >conftest.tmp
 		read -r CACHE_CHECK_VSN < conftest.tmp
 		IFS=.- read -r CACHE_CHECK_VSN_MAJOR CACHE_CHECK_VSN_MINOR CACHE_CHECK_VSN_PATCH LEFTOVER < conftest.tmp
 		rm -f conftest.tmp
 
 		# Require version >= 0.5.4 for --clear-needs-check-flag
+		CACHE_CHECK_VSN_MAJOR=${CACHE_CHECK_VSN_MAJOR##* }
 		AS_IF([test -z "$CACHE_CHECK_VSN_MAJOR" \
 			|| test -z "$CACHE_CHECK_VSN_MINOR" \
 			|| test -z "$CACHE_CHECK_VSN_PATCH"], [
@@ -574,7 +592,7 @@ AS_CASE(["$CACHE"],
 		])
 	])
 
-	AC_MSG_CHECKING([whether cache_check supports the needs-check flag])
+	AC_MSG_CHECKING([whether $CACHE_CHECK_CMD ($CACHE_CHECK_VSN_MAJOR.$CACHE_CHECK_VSN_MINOR.$CACHE_CHECK_VSN_PATCH) supports the needs-check flag])
 	AC_MSG_RESULT([$CACHE_CHECK_NEEDS_CHECK])
 	AS_IF([test "$CACHE_CHECK_NEEDS_CHECK" = "yes"], [
 		AC_DEFINE([CACHE_CHECK_NEEDS_CHECK], 1, [Define to 1 if the external 'cache_check' tool requires the --clear-needs-check-flag option])
@@ -1012,8 +1030,12 @@ AC_DEFINE_UNQUOTED(DEFAULT_USE_LVMPOLLD, [$DEFAULT_USE_LVMPOLLD],
 
 
 SYSTEMD_MIN_VERSION=0
-PKG_CHECK_EXISTS(systemd >= 221, [SYSTEMD_MIN_VERSION=221])
-PKG_CHECK_EXISTS(systemd >= 234, [SYSTEMD_MIN_VERSION=234])
+SYSTEMD_JOURNAL_SUPPORT="no"
+APP_MACHINEID_SUPPORT="no"
+
+AS_IF([test "$with_systemd" = "yes"],
+      PKG_CHECK_EXISTS(systemd >= 221, [SYSTEMD_MIN_VERSION=221 SYSTEMD_JOURNAL_SUPPORT="maybe"])
+      PKG_CHECK_EXISTS(systemd >= 234, [SYSTEMD_MIN_VERSION=234 APP_MACHINEID_SUPPORT="maybe"]))
 
 ################################################################################
 dnl -- Build notifydbus
@@ -1022,26 +1044,24 @@ AC_ARG_ENABLE(notify-dbus,
 	      AS_HELP_STRING([--enable-notify-dbus],
 			     [enable LVM notification using dbus]),
 	      NOTIFYDBUS_SUPPORT=$enableval, NOTIFYDBUS_SUPPORT="no")
-AS_IF([test "$NOTIFYDBUS_SUPPORT" = "yes" && test "$SYSTEMD_MIN_VERSION" -lt 221],
-      [AC_MSG_ERROR([Enabling notify-dbus requires systemd >= 221])])
 AC_MSG_RESULT([$NOTIFYDBUS_SUPPORT])
 
 AS_IF([test "$NOTIFYDBUS_SUPPORT" = "yes"],
+      AS_IF([test "$SYSTEMD_MIN_VERSION" -lt 221],
+            [AC_MSG_ERROR([--enable-notify-dbus requires systemd >= 221. (--with-systemd=$with_systemd)])])
       AC_DEFINE([NOTIFYDBUS_SUPPORT], 1, [Define to 1 to include code that uses dbus notification.]))
 
 ################################################################################
 dnl -- Build with systemd journaling when the header file is present
-AS_IF([test "$SYSTEMD_MIN_VERSION" -ge 221], [SYSTEMD_JOURNAL_SUPPORT="maybe"], [SYSTEMD_JOURNAL_SUPPORT="no"])
-AC_CHECK_HEADER([systemd/sd-journal.h],
-		[AS_IF([test "$SYSTEMD_JOURNAL_SUPPORT" != "no"], [SYSTEMD_JOURNAL_SUPPORT="yes"])],
-                [SYSTEMD_JOURNAL_SUPPORT="no"])
-AC_MSG_CHECKING([whether to log to systemd journal])
+AS_IF([test "$SYSTEMD_JOURNAL_SUPPORT" != "no"],
+      AC_CHECK_HEADER([systemd/sd-journal.h], [SYSTEMD_JOURNAL_SUPPORT="yes"], [SYSTEMD_JOURNAL_SUPPORT="no"]))
 AC_ARG_ENABLE(systemd-journal,
 	      AS_HELP_STRING([--disable-systemd-journal],
 			     [disable LVM systemd journaling]),
 	      AS_IF([test "$enableval" = "yes" && test "$SYSTEMD_JOURNAL_SUPPORT" = "no"],
-		    AC_MSG_ERROR([Enabling systemd journal requires systemd/sd-journal.h and systemd >= 221.]))
+		    AC_MSG_ERROR([--enable-systemd-journal requires systemd/sd-journal.h and systemd >= 221. (--with-systemd=$with_systemd)]))
 	      SYSTEMD_JOURNAL_SUPPORT=$enableval, [])
+AC_MSG_CHECKING([whether to log to systemd journal])
 AC_MSG_RESULT([$SYSTEMD_JOURNAL_SUPPORT])
 
 AS_IF([test "$SYSTEMD_JOURNAL_SUPPORT" = "yes"],
@@ -1049,17 +1069,15 @@ AS_IF([test "$SYSTEMD_JOURNAL_SUPPORT" = "yes"],
 
 ################################################################################
 dnl -- Build appmachineid when header file sd-id128.h is present
-AS_IF([test "$SYSTEMD_MIN_VERSION" -ge 234], [APP_MACHINEID_SUPPORT="maybe"], [APP_MACHINEID_SUPPORT="no"])
-AC_CHECK_HEADER([systemd/sd-id128.h],
-		[AS_IF([test "$APP_MACHINEID_SUPPORT" != "no"], [APP_MACHINEID_SUPPORT="yes"])],
-		[APP_MACHINEID_SUPPORT="no"])
-AC_MSG_CHECKING([whether to support systemd appmachineid])
+AS_IF([test "$APP_MACHINEID_SUPPORT" != "no"],
+      [AC_CHECK_HEADER([systemd/sd-id128.h], [APP_MACHINEID_SUPPORT="yes"], [APP_MACHINEID_SUPPORT="no"])])
 AC_ARG_ENABLE(app-machineid,
 	      AS_HELP_STRING([--disable-app-machineid],
 			     [disable LVM system ID using app-specific machine-id]),
 	      AS_IF([test "$enableval" = "yes" && test "$APP_MACHINEID_SUPPORT" = "no"],
-		    AC_MSG_ERROR([Enabling app machineid requires systemd/sd-id128.h and systemd >= 234.]))
+		    AC_MSG_ERROR([--enable-app-machineid requires systemd/sd-id128.h and systemd >= 234. (--with-systemd=$with_systemd)]))
 	      APP_MACHINEID_SUPPORT=$enableval, [])
+AC_MSG_CHECKING([whether to support systemd appmachineid])
 AC_MSG_RESULT([$APP_MACHINEID_SUPPORT])
 
 AS_IF([test "$APP_MACHINEID_SUPPORT" = "yes"],
@@ -1084,49 +1102,44 @@ AC_MSG_RESULT([$SYSTEMD_RUN_CMD])
 ################################################################################
 
 dnl -- Enable blkid wiping functionality
-AC_ARG_ENABLE(blkid_wiping,
-	      AS_HELP_STRING([--disable-blkid_wiping],
-			     [disable libblkid detection of signatures when wiping and use native code instead]),
-	      BLKID_WIPING=$enableval, BLKID_WIPING="maybe")
-
 # TODO: possibly detect right version of blkid with BLKID_SUBLKS_FSINFO support
 #       so lvresize can check detected flag here
 #
 DEFAULT_USE_BLKID_WIPING=0
-PKG_CHECK_EXISTS([blkid >= 2.24], [HAVE_BLKID="yes"], [HAVE_BLKID="no"])
+AC_ARG_ENABLE(blkid_wiping,
+	      AS_HELP_STRING([--disable-blkid_wiping],
+			     [disable libblkid detection of signatures when wiping and use native code instead]),
+	      BLKID_WIPING=$enableval,
+	      [AS_IF([test "$with_blkid" = "yes"], [BLKID_WIPING="maybe"], [BLKID_WIPING="no"])])
 
-AS_IF([test "$HAVE_BLKID" = "yes"], [
+AS_IF([test "$BLKID_WIPING" != "no"], [
 	PKG_CHECK_MODULES([BLKID], [blkid >= 2.24], [
-
-	AC_CACHE_CHECK([for blkid.h defines BLKID_SUBLKS_FSINFO.],
-		[ac_cv_have_blkid_sublks_fsinfo],
-		[AC_COMPILE_IFELSE([AC_LANG_PROGRAM([#include <blkid/blkid.h>
+		AC_CACHE_CHECK([for blkid.h defines BLKID_SUBLKS_FSINFO.],
+			[ac_cv_have_blkid_sublks_fsinfo],
+			[AC_COMPILE_IFELSE([AC_LANG_PROGRAM([#include <blkid/blkid.h>
 #ifndef BLKID_SUBLKS_FSINFO
 #error BLKID_SUBLKS_FSINFO is missing
-#endif])],
-		[ac_cv_have_blkid_sublks_fsinfo="yes"], [ac_cv_have_blkid_sublks_fsinfo="no"])])
-
-	AC_IF_YES(ac_cv_have_blkid_sublks_fsinfo,
-		  AC_DEFINE(HAVE_BLKID_SUBLKS_FSINFO, 1,
-			    [Define if blkid.h has BLKID_SUBLKS_FSINFO]))
-	])
+#endif
+			])], [ac_cv_have_blkid_sublks_fsinfo="yes"], [ac_cv_have_blkid_sublks_fsinfo="no"])])
+
+		AC_IF_YES(ac_cv_have_blkid_sublks_fsinfo,
+			  AC_DEFINE(HAVE_BLKID_SUBLKS_FSINFO, 1,
+				    [Define if blkid.h has BLKID_SUBLKS_FSINFO]))
+
+		AS_IF([test "$with_blkid" = "no"], [BLKID_WIPING="error"], [
+			BLKID_WIPING="yes"
+			BLKID_PC="blkid"
+			DEFAULT_USE_BLKID_WIPING=1
+			# pkg_config --static  does not really work ATM...
+			BLKID_STATIC_LIBS=$("$PKG_CONFIG" --static --libs blkid)
+			AC_DEFINE([BLKID_WIPING_SUPPORT], 1, [Define to 1 to use libblkid detection of signatures when wiping.])
+		      ])
+      ], [AS_IF([test "$BLKID_WIPING" = "yes"], [BLKID_WIPING="error"], [BLKID_WIPING="no"])])
 ])
 
-AS_IF([test "$BLKID_WIPING" != "no"], [
-	AS_IF([test "$HAVE_BLKID" = "yes"], [
-		BLKID_WIPING="yes"
-		BLKID_PC="blkid"
-		DEFAULT_USE_BLKID_WIPING=1
-		BLKID_STATIC_LIBS=$("$PKG_CONFIG" --static --libs blkid)
-		AC_DEFINE([BLKID_WIPING_SUPPORT], 1, [Define to 1 to use libblkid detection of signatures when wiping.])
-	], [
-		AS_IF([test "$BLKID_WIPING" = "maybe"], [
-			BLKID_WIPING=no
-		], [
-			AC_MSG_ERROR([bailing out... blkid library >= 2.24 is required])
-		])
-	])
-])
+AS_IF([test "$BLKID_WIPING" = "error"],
+	[AC_MSG_ERROR([--enable-blkid_wiping requires blkid library >= 2.24. (--with-blkid=$with_blkid)])])
+
 AC_MSG_CHECKING([whether to enable libblkid detection of signatures when wiping])
 AC_MSG_RESULT([$BLKID_WIPING])
 AC_DEFINE_UNQUOTED(DEFAULT_USE_BLKID_WIPING, [$DEFAULT_USE_BLKID_WIPING],
@@ -1140,6 +1153,8 @@ AC_ARG_ENABLE(udev_sync,
 			     [enable synchronization with udev processing]),
 	      UDEV_SYNC=$enableval, UDEV_SYNC="no")
 AC_MSG_RESULT([$UDEV_SYNC])
+AS_IF([test "$UDEV_SYNC" = "yes" && test "$with_udev" = "no"],
+	[AC_MSG_ERROR([--enable-udev_sync requires udev >= 143. (--with-udev=$with_udev)])])
 
 AS_IF([test "$UDEV_SYNC" = "yes"], [
 	PKG_CHECK_MODULES(UDEV, libudev >= 143, [UDEV_PC="libudev"])
@@ -1218,7 +1233,10 @@ AC_ARG_ENABLE(cmdlib,
 	      CMDLIB=$enableval, CMDLIB="no")
 AC_MSG_RESULT([$CMDLIB])
 AC_SUBST([LVM2CMD_LIB])
-AS_IF([test "$CMDLIB" = "yes"], [LVM2CMD_LIB="-llvm2cmd"], [LVM2CMD_LIB=])
+AS_IF([test "$CMDLIB" = "yes"],
+      [AS_IF([test "$SHARED_LINK" = "no"],
+	     [AC_MSG_ERROR([--enable-cmdlib requires dynamic linking.])])
+       LVM2CMD_LIB="-llvm2cmd"], [LVM2CMD_LIB=])
 
 ################################################################################
 dnl -- Enable D-Bus service
@@ -1322,7 +1340,7 @@ AC_MSG_RESULT([$BUILD_DMFILEMAPD])
 
 dnl -- dmfilemapd requires FIEMAP
 AS_IF([test "$BUILD_DMFILEMAPD" = "yes"],
-      [AC_CHECK_HEADER([linux/fiemap.h], [],    
+      [AC_CHECK_HEADER([linux/fiemap.h], [],
 		      ,[AC_MSG_ERROR(--enable-dmfilemapd requires fiemap.h)])
        AC_DEFINE([DMFILEMAPD], 1, [Define to 1 to enable the device-mapper filemap daemon.])])
 
@@ -1892,6 +1910,7 @@ AC_SUBST(SBINDIR)
 AC_SUBST(SELINUX_LIBS)
 AC_SUBST(SELINUX_PC)
 AC_SUBST(SELINUX_STATIC_LIBS)
+AC_SUBST(SHARED_LINK)
 AC_SUBST(SILENT_RULES)
 AC_SUBST(SNAPSHOTS)
 AC_SUBST(STATICDIR)


=====================================
device_mapper/ioctl/libdm-iface.c
=====================================
@@ -1620,7 +1620,7 @@ static int _check_uevent_generated(struct dm_ioctl *dmi)
 static int _create_and_load_v4(struct dm_task *dmt)
 {
 	struct dm_task *task;
-	int r;
+	int r, ioctl_errno = 0;
 	uint32_t cookie;
 
 	/* Use new task struct to create the device */
@@ -1646,8 +1646,10 @@ static int _create_and_load_v4(struct dm_task *dmt)
 	task->cookie_set = dmt->cookie_set;
 	task->add_node = dmt->add_node;
 
-	if (!dm_task_run(task))
+	if (!dm_task_run(task)) {
+		ioctl_errno = task->ioctl_errno;
 		goto_bad;
+	}
 
 	dm_task_destroy(task);
 
@@ -1673,6 +1675,8 @@ static int _create_and_load_v4(struct dm_task *dmt)
 	task->ima_measurement = dmt->ima_measurement;
 
 	r = dm_task_run(task);
+	if (!r)
+		ioctl_errno = task->ioctl_errno;
 
 	task->head = NULL;
 	task->tail = NULL;
@@ -1719,12 +1723,18 @@ static int _create_and_load_v4(struct dm_task *dmt)
 	if (!dm_task_run(dmt))
 		log_error("Failed to revert device creation.");
 
+	if (ioctl_errno != 0)
+		dmt->ioctl_errno =  ioctl_errno;
+
 	return 0;
 
       bad:
 	dm_task_destroy(task);
 	_udev_complete(dmt);
 
+	if (ioctl_errno != 0)
+		dmt->ioctl_errno =  ioctl_errno;
+
 	return 0;
 }
 


=====================================
libdm/Makefile.in
=====================================
@@ -47,7 +47,9 @@ endif
 
 LIB_SHARED = $(interface)/libdevmapper.$(LIB_SUFFIX)
 LIB_VERSION = $(LIB_VERSION_DM)
+ifeq ("@SHARED_LINK@", "yes")
 TARGETS = libdevmapper.$(LIB_SUFFIX) libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION) .symver_check
+endif
 
 CFLOW_LIST = $(SOURCES)
 CFLOW_LIST_TARGET = libdevmapper.cflow
@@ -103,7 +105,12 @@ install_dynamic: install_ at interface@
 
 install_static: install_ at interface@_static
 
+ifeq ("@SHARED_LINK@", "yes")
 install_ioctl: install_lib_shared
+endif
+ifeq ("@STATIC_LINK@", "yes")
+install_ioctl: install_ioctl_static
+endif
 
 install_pkgconfig: libdevmapper.pc
 	@echo "    [INSTALL] $<"


=====================================
libdm/dm-tools/Makefile.in
=====================================
@@ -19,13 +19,15 @@ top_builddir = @top_builddir@
 all: device-mapper
 
 SOURCES2 = dmsetup.c
-TARGETS_DM = dmsetup
 
 CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES2))
 CFLOW_TARGET := $(TARGETS_DM)
 -include $(top_builddir)/libdm/libdevmapper.cflow
 
-install_device-mapper: install_dmsetup_dynamic
+ifeq ("@SHARED_LINK@", "yes")
+  TARGETS_DM += dmsetup
+  install_device-mapper: install_dmsetup_dynamic
+endif
 
 ifeq ("@STATIC_LINK@", "yes")
   TARGETS_DM += dmsetup.static
@@ -35,8 +37,11 @@ endif
 # dmfilemapd support
 ifeq ("@BUILD_DMFILEMAPD@", "yes")
   SOURCES2 += dmfilemapd.c
-  TARGETS_DM += dmfilemapd
-  install_dmfilemapd: install_dmfilemapd_dynamic
+
+  ifeq ("@SHARED_LINK@", "yes")
+     TARGETS_DM += dmfilemapd
+     install_dmfilemapd: install_dmfilemapd_dynamic
+  endif
 
   ifeq ("@STATIC_LINK@", "yes")
     TARGETS_DM += dmfilemapd.static


=====================================
libdm/make.tmpl.in
=====================================
@@ -318,7 +318,12 @@ SUBDIRS.cflow := $(SUBDIRS:=.cflow)
 SUBDIRS.clean := $(SUBDIRS:=.clean)
 SUBDIRS.distclean := $(SUBDIRS:=.distclean)
 
-TARGETS += $(LIB_SHARED) $(LIB_STATIC)
+ifeq ("@SHARED_LINK@", "yes")
+  TARGETS += $(LIB_SHARED)
+endif
+ifeq ("@STATIC_LINK@", "yes")
+  TARGETS += $(LIB_STATIC)
+endif
 
 all: $(SUBDIRS) $(TARGETS)
 


=====================================
make.tmpl.in
=====================================
@@ -373,7 +373,12 @@ SUBDIRS.cflow := $(SUBDIRS:=.cflow)
 SUBDIRS.clean := $(SUBDIRS:=.clean)
 SUBDIRS.distclean := $(SUBDIRS:=.distclean)
 
-TARGETS += $(LIB_SHARED) $(LIB_STATIC)
+ifeq ("@SHARED_LINK@", "yes")
+  TARGETS += $(LIB_SHARED)
+endif
+ifeq ("@STATIC_LINK@", "yes")
+  TARGETS += $(LIB_STATIC)
+endif
 
 INTERNAL_LIBS = \
 	$(top_builddir)/libdaemon/client/libdaemonclient.a \


=====================================
test/lib/aux.sh
=====================================
@@ -1732,6 +1732,7 @@ thin_pool_error_works_32() {
 }
 
 thin_restore_needs_more_volumes() {
+	# Note: new version prints thin_restore first
 	case $("$LVM_TEST_THIN_RESTORE_CMD" -V) in
 		# With older version of thin-tool we got slightly more compact metadata
 		0.[0-6]*|0.7.0*) return 0 ;;
@@ -1741,13 +1742,15 @@ thin_restore_needs_more_volumes() {
 }
 
 udev_wait() {
-	pgrep udev >/dev/null || return 0
-	which udevadm &>/dev/null || return 0
-	if test -n "${1-}" ; then
-		udevadm settle --exit-if-exists="$1" 2>/dev/null || true
-	else
-		udevadm settle --timeout=15 2>/dev/null || true
-	fi
+	local arg="--timeout=15"
+	test -n "${1-}" && arg="--exit-if-exists=$1"
+
+	test -f UDEV_PID || {
+		pgrep udev >UDEV_PID 2>/dev/null || return 0
+		which udevadm &>/dev/null || { echo "" >UDEV_PID ; return 0 ; }
+	}
+
+	test ! -s UDEV_PID || { udevadm settle "$arg" 2>/dev/null || true ; }
 }
 
 # wait_for_sync <VG/LV>


=====================================
test/lib/inittest.sh
=====================================
@@ -81,7 +81,10 @@ PREFIX="${COMMON_PREFIX}$$"
 
 # Check we are not conflickting with some exiting setup
 if test -z "$SKIP_ROOT_DM_CHECK" ; then
-	dmsetup table | not grep "${PREFIX}[^0-9]" || die "DM table already has devices with prefix $PREFIX!"
+	d=$(dmsetup info -c -o name --noheadings --rows -S "suspended=Suspended||name=~${PREFIX}[^0-9]")
+	test "$d" = "No devices found" || {
+		die "DM table already has either suspended or $PREFIX prefixed devices: $d"
+	}
 fi
 
 test -n "$LVM_TEST_DIR" || LVM_TEST_DIR=${TMPDIR:-/tmp}


=====================================
test/shell/dmeventd-restart.sh
=====================================
@@ -15,6 +15,21 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+_restart_dmeventd() {
+	#rm -f debug.log*
+
+	dmeventd -R -fldddd -e "$PWD/test_nologin" > debug.log_DMEVENTD_$RANDOM 2>&1 &
+	echo $! >LOCAL_DMEVENTD
+
+	for i in $(seq 1 10); do
+		test "$(pgrep -o dmeventd)" = "$(< LOCAL_DMEVENTD)" && break
+		sleep .1
+	done
+	# wait a bit, so we talk to the new dmeventd later
+	# On some systems init of selinux contex may take a while...
+	sleep .5
+}
+
 aux prepare_dmeventd
 
 aux prepare_vg 5
@@ -27,9 +42,7 @@ lvchange --monitor y $vg/3way
 lvcreate -aey -l1 -n $lv1 $vg
 lvcreate -s -l1 -n $lv2 $vg/$lv1
 
-dmeventd -R -f &
-echo $! >LOCAL_DMEVENTD
-sleep 2 # wait a bit, so we talk to the new dmeventd later
+_restart_dmeventd
 
 check lv_field $vg/3way seg_monitor "monitored"
 check lv_field $vg/4way seg_monitor "monitored"
@@ -43,11 +56,10 @@ test -e LOCAL_CLVMD || grep 'already monitored' lvchange.out
 kill -9 "$(< LOCAL_DMEVENTD)"
 rm LOCAL_DMEVENTD debug.log*
 
-dmeventd -R -f &
-echo $! >LOCAL_DMEVENTD
+_restart_dmeventd
 
 # wait longer as tries 5s to communicate with killed daemon
-sleep 7
+sleep 6
 # now dmeventd should not be running
 not pgrep dmeventd
 rm LOCAL_DMEVENTD
@@ -63,16 +75,8 @@ test -e LOCAL_CLVMD || not grep 'already monitored' lvchange.out
 lvchange --monitor y --verbose $vg/$lv2 2>&1 | tee lvchange.out
 test -e LOCAL_CLVMD || not grep 'already monitored' lvchange.out
 
-rm -f debug.log*
-dmeventd -R -f -e "$PWD/test_nologin" -ldddd > debug.log_DMEVENTD_$RANDOM 2>&1 &
-echo $! >LOCAL_DMEVENTD
-
-for i in $(seq 1 10); do
-  test "$(pgrep -o dmeventd)" = "$(< LOCAL_DMEVENTD)" && break
-  sleep .1
-done
+_restart_dmeventd
 
-sleep 1 # wait a bit, so we talk to the new dmeventd later
 kill -INT "$(< LOCAL_DMEVENTD)"
 sleep 1
 


=====================================
test/shell/dmsecuretest.sh
=====================================
@@ -40,8 +40,9 @@ for j in empty existing ; do
 
 "$i" "$dev1" "$DMTEST" >cmdout 2>&1 &
 PID=$!
-sleep .5
+sleep .6
 
+# 0 8192 crypt aes-xts-plain64 434e0cbab02ca68ffba9268222c3789d703fe62427b78b308518b3228f6a2122 0 253:0 8192
 # crypt device should be loaded
 dmsetup status "$DMTEST"
 


=====================================
test/shell/dmstats-filemap.sh
=====================================
@@ -15,6 +15,8 @@ SKIP_WITH_LVMLOCKD=1
 
 . lib/inittest
 
+which mkfs.xfs || skip
+
 # Don't attempt to test stats with driver < 4.33.00
 aux driver_at_least 4 33 || skip
 


=====================================
tools/Makefile.in
=====================================
@@ -100,10 +100,12 @@ CLEAN_TARGETS = liblvm2cmd.$(LIB_SUFFIX) $(TARGETS_DM) \
 	$(LDDEPS) .exported_symbols_generated cmds.h \
 	command-lines-input.h command-count.h man-generator.c
 
+ifeq ("@SHARED_LINK@", "yes")
 ifeq ("@CMDLIB@", "yes")
 	TARGETS += liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION)
 	INSTALL_LVM_TARGETS += $(INSTALL_CMDLIB_TARGETS)
 endif
+endif
 
 EXPORTED_HEADER = $(srcdir)/lvm2cmd.h
 EXPORTED_FN_PREFIX = lvm2



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/0ff027ae2c40066e2dd49cb4a377884d7e10dcf2...8b8b8ac1f8a0196cd6e8f03f3eae5891dca077d3

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/0ff027ae2c40066e2dd49cb4a377884d7e10dcf2...8b8b8ac1f8a0196cd6e8f03f3eae5891dca077d3
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231013/9910de8a/attachment-0001.htm>
