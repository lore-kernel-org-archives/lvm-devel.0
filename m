From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Feb 2023 16:53:26 +0000 (GMT)
Subject: main - configure: update
Message-ID: <20230210165326.116543858414@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b681b774dcacd35d08f16d8952ec99d1e85433d6
Commit:        b681b774dcacd35d08f16d8952ec99d1e85433d6
Parent:        e67ebc5c40948bcbea536fd407535009a76ede00
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 8 16:15:26 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 10 17:50:27 2023 +0100

configure: update

---
 configure | 1708 +++++++++++++++++++++++++++++++++++++------------------------
 1 file changed, 1030 insertions(+), 678 deletions(-)

diff --git a/configure b/configure
index 718f281bc..2406deddc 100755
--- a/configure
+++ b/configure
@@ -652,8 +652,6 @@ ac_subst_vars='LTLIBOBJS
 usrsbindir
 usrlibdir
 tmpfilesdir
-systemdutildir
-systemdsystemunitdir
 udevdir
 udev_prefix
 tmpdir
@@ -734,6 +732,8 @@ INTEGRITY
 HAVE_VALGRIND
 HAVE_REALTIME
 HAVE_LIBDL
+HAVE_BLKID_SUBLKS_FSINFO
+HAVE_BLKID
 BLKDEACTIVATE
 LVRESIZE_FS_HELPER_PATH
 FSADM_PATH
@@ -785,6 +785,8 @@ BLKID_PC
 READLINE_LIBS
 READLINE_CFLAGS
 MODPROBE_CMD
+systemdutildir
+systemdsystemunitdir
 MSGFMT
 EDITLINE_LIBS
 EDITLINE_CFLAGS
@@ -823,8 +825,6 @@ HAVE_WCLOBBERED
 HAVE_WJUMP
 CPG_LIBS
 CPG_CFLAGS
-PKGCONFIGINIT_LIBS
-PKGCONFIGINIT_CFLAGS
 PKG_CONFIG_LIBDIR
 PKG_CONFIG_PATH
 PKG_CONFIG
@@ -989,7 +989,6 @@ enable_notify_dbus
 enable_systemd_journal
 enable_app_machineid
 enable_blkid_wiping
-enable_udev_systemd_background_jobs
 enable_udev_sync
 enable_udev_rules
 enable_udev_rule_exec_detection
@@ -1047,8 +1046,6 @@ AIO_LIBS
 PKG_CONFIG
 PKG_CONFIG_PATH
 PKG_CONFIG_LIBDIR
-PKGCONFIGINIT_CFLAGS
-PKGCONFIGINIT_LIBS
 CPG_CFLAGS
 CPG_LIBS
 VALGRIND_CFLAGS
@@ -1070,6 +1067,8 @@ UDEV_LIBS
 PYTHON
 EDITLINE_CFLAGS
 EDITLINE_LIBS
+systemdsystemunitdir
+systemdutildir
 READLINE_CFLAGS
 READLINE_LIBS'
 
@@ -1728,9 +1727,6 @@ Optional Features:
   --disable-app-machineid disable LVM system ID using app-specific machine-id
   --disable-blkid_wiping  disable libblkid detection of signatures when wiping
                           and use native code instead
-  --disable-udev-systemd-background-jobs
-                          disable udev-systemd protocol to instantiate a
-                          service for background job
   --enable-udev_sync      enable synchronisation with udev processing
   --enable-udev_rules     install rule files needed for udev synchronisation
   --enable-udev-rule-exec-detection
@@ -1862,10 +1858,6 @@ Some influential environment variables:
               directories to add to pkg-config's search path
   PKG_CONFIG_LIBDIR
               path overriding pkg-config's built-in search path
-  PKGCONFIGINIT_CFLAGS
-              C compiler flags for PKGCONFIGINIT, overriding pkg-config
-  PKGCONFIGINIT_LIBS
-              linker flags for PKGCONFIGINIT, overriding pkg-config
   CPG_CFLAGS  C compiler flags for CPG, overriding pkg-config
   CPG_LIBS    linker flags for CPG, overriding pkg-config
   VALGRIND_CFLAGS
@@ -1902,6 +1894,10 @@ Some influential environment variables:
               C compiler flags for EDITLINE, overriding pkg-config
   EDITLINE_LIBS
               linker flags for EDITLINE, overriding pkg-config
+  systemdsystemunitdir
+              value of systemdsystemunitdir for systemd, overriding pkg-config
+  systemdutildir
+              value of systemdutildir for systemd, overriding pkg-config
   READLINE_CFLAGS
               C compiler flags for readline
   READLINE_LIBS
@@ -3727,40 +3723,39 @@ if test -z "$CFLAGS"
 then :
   COPTIMISE_FLAG="-O2"
 fi
-case "$host_os" in
-	linux*)
+case "$host_os" in #(
+  linux*) :
+
 		# equivalent to -rdynamic
 		ELDFLAGS="-Wl,--export-dynamic"
 		# FIXME Generate list and use --dynamic-list=.dlopen.sym
 		CLDWHOLEARCHIVE="-Wl,-whole-archive"
 		CLDNOWHOLEARCHIVE="-Wl,-no-whole-archive"
-		LIB_SUFFIX=so
-		DEVMAPPER=yes
-		BUILD_LVMPOLLD=no
-		ODIRECT=yes
-		DM_IOCTLS=yes
-		SELINUX=yes
-		FSADM=yes
-		LVMIMPORTVDO=yes
-		BLKDEACTIVATE=yes
-		;;
-	darwin*)
+		LIB_SUFFIX="so"
+		DEVMAPPER="yes"
+		BUILD_LVMPOLLD="no"
+		ODIRECT="yes"
+		DM_IOCTLS="yes"
+		SELINUX="yes"
+		FSADM="yes"
+		LVMIMPORTVDO="yes"
+		BLKDEACTIVATE="yes" ;; #(
+  darwin*) :
+
 		CFLAGS="$CFLAGS -no-cpp-precomp -fno-common"
 		ELDFLAGS=
 		CLDWHOLEARCHIVE="-all_load"
 		CLDNOWHOLEARCHIVE=
-		LIB_SUFFIX=dylib
-		DEVMAPPER=yes
-		ODIRECT=no
-		DM_IOCTLS=no
-		SELINUX=no
-		FSADM=no
-		LVMIMPORTVDO=no
-		BLKDEACTIVATE=no
-		;;
-	*)
-		CLDFLAGS="${CLDFLAGS-"$LDFLAGS"}"
-		;;
+		LIB_SUFFIX="dylib"
+		DEVMAPPER="yes"
+		ODIRECT="no"
+		DM_IOCTLS="no"
+		SELINUX="no"
+		FSADM="no"
+		LVMIMPORTVDO="no"
+		BLKDEACTIVATE="no" ;; #(
+  *) :
+    CLDFLAGS="${CLDFLAGS-"$LDFLAGS"}" ;;
 esac
 
 ################################################################################
@@ -7045,9 +7040,9 @@ else $as_nop
 fi
 
 done
-case "$host_os" in
-	linux*)
-		       for ac_header in asm/byteorder.h linux/fs.h malloc.h
+case "$host_os" in #(
+  linux*) :
+           for ac_header in asm/byteorder.h linux/fs.h malloc.h
 do :
   as_ac_Header=`printf "%s\n" "ac_cv_header_$ac_header" | $as_tr_sh`
 ac_fn_c_check_header_compile "$LINENO" "$ac_header" "$as_ac_Header" "$ac_includes_default"
@@ -7061,9 +7056,9 @@ else $as_nop
   as_fn_error $? "bailing out" "$LINENO" 5
 fi
 
-done ;;
-	darwin*)
-		       for ac_header in machine/endian.h sys/disk.h
+done ;; #(
+  darwin*) :
+           for ac_header in machine/endian.h sys/disk.h
 do :
   as_ac_Header=`printf "%s\n" "ac_cv_header_$ac_header" | $as_tr_sh`
 ac_fn_c_check_header_compile "$LINENO" "$ac_header" "$as_ac_Header" "$ac_includes_default"
@@ -7077,7 +7072,9 @@ else $as_nop
   as_fn_error $? "bailing out" "$LINENO" 5
 fi
 
-done ;;
+done ;; #(
+  *) :
+     ;;
 esac
 
 ################################################################################
@@ -9031,7 +9028,7 @@ if test ${enable_dependency_tracking+y}
 then :
   enableval=$enable_dependency_tracking; USE_TRACKING=$enableval
 else $as_nop
-  USE_TRACKING=yes
+  USE_TRACKING="yes"
 fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $USE_TRACKING" >&5
@@ -9045,7 +9042,7 @@ if test ${enable_silent_rules+y}
 then :
   enableval=$enable_silent_rules; SILENT_RULES=$enableval
 else $as_nop
-  SILENT_RULES=yes
+  SILENT_RULES="yes"
 fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $SILENT_RULES" >&5
@@ -9060,7 +9057,7 @@ if test ${enable_static_link+y}
 then :
   enableval=$enable_static_link; STATIC_LINK=$enableval
 else $as_nop
-  STATIC_LINK=no
+  STATIC_LINK="no"
 fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $STATIC_LINK" >&5
@@ -9153,11 +9150,11 @@ printf "%s\n" "$ac_cv_flag_HAVE_FULL_RELRO" >&6; }
 
 
 ################################################################################
-test "$exec_prefix" = NONE -a "$prefix" = NONE && exec_prefix=""
+test "$exec_prefix" = "NONE" && test "$prefix" = "NONE" && exec_prefix=""
 
-test "x$prefix" = xNONE && prefix=$ac_default_prefix
+test "$prefix" = "NONE" && prefix=$ac_default_prefix
 # Let make expand exec_prefix.
-test "x$exec_prefix" = xNONE && exec_prefix='${prefix}'
+test "$exec_prefix" = "NONE" && exec_prefix='${prefix}'
 
 ################################################################################
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking file owner" >&5
@@ -9255,10 +9252,13 @@ else $as_nop
   ADD_NODE=resume
 fi
 
-case "$ADD_NODE" in
- resume) add_on=DM_ADD_NODE_ON_RESUME;;
- create) add_on=DM_ADD_NODE_ON_CREATE;;
- *) as_fn_error $? "--with-device-nodes-on parameter invalid" "$LINENO" 5;;
+case "$ADD_NODE" in #(
+  resume) :
+    add_on=DM_ADD_NODE_ON_RESUME ;; #(
+  create) :
+    add_on=DM_ADD_NODE_ON_CREATE ;; #(
+  *) :
+    as_fn_error $? "--with-device-nodes-on parameter invalid" "$LINENO" 5 ;;
 esac
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: on $ADD_NODE" >&5
 printf "%s\n" "on $ADD_NODE" >&6; }
@@ -9278,9 +9278,11 @@ else $as_nop
   DEFAULT_USE_DEVICES_FILE=0
 fi
 
-case "$DEFAULT_USE_DEVICES_FILE" in
- 0|1);;
- *) as_fn_error $? "--with-default-use-devices-file parameter invalid" "$LINENO" 5;;
+case "$DEFAULT_USE_DEVICES_FILE" in #(
+  0|1) :
+     ;; #(
+  *) :
+    as_fn_error $? "--with-default-use-devices-file parameter invalid" "$LINENO" 5 ;;
 esac
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $DEFAULT_USE_DEVICES_FILE" >&5
 printf "%s\n" "$DEFAULT_USE_DEVICES_FILE" >&6; }
@@ -9299,11 +9301,15 @@ else $as_nop
   MANGLING=auto
 fi
 
-case "$MANGLING" in
- auto) mangling=DM_STRING_MANGLING_AUTO;;
- no|none|disabled) mangling=DM_STRING_MANGLING_NONE;;
- hex) mangling=DM_STRING_MANGLING_HEX;;
- *) as_fn_error $? "--with-default-name-mangling parameter invalid" "$LINENO" 5;;
+case "$MANGLING" in #(
+  auto) :
+    mangling=DM_STRING_MANGLING_AUTO ;; #(
+  no|none|disabled) :
+    mangling=DM_STRING_MANGLING_NONE ;; #(
+  hex) :
+    mangling=DM_STRING_MANGLING_HEX ;; #(
+  *) :
+    as_fn_error $? "--with-default-name-mangling parameter invalid" "$LINENO" 5 ;;
 esac
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $MANGLING" >&5
 printf "%s\n" "$MANGLING" >&6; }
@@ -9326,12 +9332,16 @@ fi
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $SNAPSHOTS" >&5
 printf "%s\n" "$SNAPSHOTS" >&6; }
 
-case "$SNAPSHOTS" in
-  no|none|shared) ;;
-  internal)
+case "$SNAPSHOTS" in #(
+  no|none|shared) :
+     ;; #(
+  internal) :
+
+
 printf "%s\n" "#define SNAPSHOT_INTERNAL 1" >>confdefs.h
- ;;
-  *) as_fn_error $? "--with-snapshots parameter invalid" "$LINENO" 5 ;;
+ ;; #(
+  *) :
+    as_fn_error $? "--with-snapshots parameter invalid" "$LINENO" 5 ;;
 esac
 
 ################################################################################
@@ -9349,12 +9359,16 @@ fi
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $MIRRORS" >&5
 printf "%s\n" "$MIRRORS" >&6; }
 
-case "$MIRRORS" in
-  no|none|shared) ;;
-  internal)
+case "$MIRRORS" in #(
+  no|none|shared) :
+     ;; #(
+  internal) :
+
+
 printf "%s\n" "#define MIRRORED_INTERNAL 1" >>confdefs.h
- ;;
-  *) as_fn_error $? "--with-mirrors parameter invalid" "$LINENO" 5 ;;
+ ;; #(
+  *) :
+    as_fn_error $? "--with-mirrors parameter invalid" "$LINENO" 5 ;;
 esac
 
 ################################################################################
@@ -9394,10 +9408,14 @@ printf "%s\n" "#define DEFAULT_RAID10_SEGTYPE \"$DEFAULT_RAID10_SEGTYPE\"" >>con
 # Check whether --with-default-sparse-segtype was given.
 if test ${with_default_sparse_segtype+y}
 then :
-  withval=$with_default_sparse_segtype;  case "$withval" in
-				thin|snapshot) DEFAULT_SPARSE_SEGTYPE=$withval ;;
-				*) as_fn_error $? "--with-default-sparse-segtype parameter invalid" "$LINENO" 5 ;;
-			     esac
+  withval=$with_default_sparse_segtype;
+		case "$withval" in #(
+  thin|snapshot) :
+    DEFAULT_SPARSE_SEGTYPE=$withval ;; #(
+  *) :
+    as_fn_error $? "--with-default-sparse-segtype parameter invalid" "$LINENO" 5 ;;
+esac
+
 else $as_nop
   DEFAULT_SPARSE_SEGTYPE="thin"
 fi
@@ -9455,13 +9473,18 @@ fi
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $THIN" >&5
 printf "%s\n" "$THIN" >&6; }
 
-case "$THIN" in
-  no|none)  test "$DEFAULT_SPARSE_SEGTYPE" = "thin" && DEFAULT_SPARSE_SEGTYPE="snapshot" ;;
-  shared) ;;
-  internal)
+case "$THIN" in #(
+  no|none) :
+    test "$DEFAULT_SPARSE_SEGTYPE" = "thin" && DEFAULT_SPARSE_SEGTYPE="snapshot" ;; #(
+  shared) :
+     ;; #(
+  internal) :
+
+
 printf "%s\n" "#define THIN_INTERNAL 1" >>confdefs.h
- ;;
-  *) as_fn_error $? "--with-thin parameter invalid ($THIN)" "$LINENO" 5 ;;
+ ;; #(
+  *) :
+    as_fn_error $? "--with-thin parameter invalid ($THIN)" "$LINENO" 5 ;;
 esac
 
 
@@ -9473,16 +9496,19 @@ if test ${enable_thin_check_needs_check+y}
 then :
   enableval=$enable_thin_check_needs_check; THIN_CHECK_NEEDS_CHECK=$enableval
 else $as_nop
-  THIN_CHECK_NEEDS_CHECK=yes
+  THIN_CHECK_NEEDS_CHECK="yes"
 fi
 
 
 # Test if necessary thin tools are available
 # if not - use plain defaults and warn user
-case "$THIN" in
-  internal|shared)
+case "$THIN" in #(
+  internal|shared) :
+
 	# Empty means a config way to ignore thin checking
-	if test "$THIN_CHECK_CMD" = "autodetect"; then
+	if test "$THIN_CHECK_CMD" = "autodetect"
+then :
+
 		if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}thin_check", so it can be a program name with args.
 set dummy ${ac_tool_prefix}thin_check; ac_word=$2
@@ -9591,32 +9617,47 @@ else
   THIN_CHECK_CMD="$ac_cv_path_THIN_CHECK_CMD"
 fi
 
-		if test -z "$THIN_CHECK_CMD"; then
+		if test -z "$THIN_CHECK_CMD"
+then :
+
 			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: thin_check not found in path $PATH" >&5
 printf "%s\n" "$as_me: WARNING: thin_check not found in path $PATH" >&2;}
-			THIN_CHECK_CMD=/usr/sbin/thin_check
-			THIN_CONFIGURE_WARN=y
-		fi
-	fi
-	if test "$THIN_CHECK_NEEDS_CHECK" = yes && test "$THIN_CONFIGURE_WARN" != y ; then
-		THIN_CHECK_VSN=`"$THIN_CHECK_CMD" -V 2>/dev/null`
-		THIN_CHECK_VSN_MAJOR=`echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $1}'`
-		THIN_CHECK_VSN_MINOR=`echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $2}'`
+			THIN_CHECK_CMD="/usr/sbin/thin_check"
+			THIN_CONFIGURE_WARN="y"
+
+fi
+
+fi
+	if test "$THIN_CHECK_NEEDS_CHECK" = "yes" && test "$THIN_CONFIGURE_WARN" != "y"
+then :
+
+		THIN_CHECK_VSN=$("$THIN_CHECK_CMD" -V 2>/dev/null)
+		THIN_CHECK_VSN_MAJOR=$(echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $1}')
+		THIN_CHECK_VSN_MINOR=$(echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $2}')
+
+		if test -z "$THIN_CHECK_VSN_MAJOR" || test -z "$THIN_CHECK_VSN_MINOR"
+then :
 
-		if test -z "$THIN_CHECK_VSN_MAJOR" -o -z "$THIN_CHECK_VSN_MINOR"; then
 			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: $THIN_CHECK_CMD: Bad version \"$THIN_CHECK_VSN\" found" >&5
 printf "%s\n" "$as_me: WARNING: $THIN_CHECK_CMD: Bad version \"$THIN_CHECK_VSN\" found" >&2;}
-			THIN_CHECK_VERSION_WARN=y
-			THIN_CHECK_NEEDS_CHECK=no
-		elif test "$THIN_CHECK_VSN_MAJOR" -eq 0 -a "$THIN_CHECK_VSN_MINOR" -lt 3; then
+			THIN_CHECK_VERSION_WARN="y"
+			THIN_CHECK_NEEDS_CHECK="no"
+
+elif test "$THIN_CHECK_VSN_MAJOR" -eq 0 && test "$THIN_CHECK_VSN_MINOR" -lt 3
+then :
+
 			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: $THIN_CHECK_CMD: Old version \"$THIN_CHECK_VSN\" found" >&5
 printf "%s\n" "$as_me: WARNING: $THIN_CHECK_CMD: Old version \"$THIN_CHECK_VSN\" found" >&2;}
-			THIN_CHECK_VERSION_WARN=y
-			THIN_CHECK_NEEDS_CHECK=no
-		fi
-	fi
+			THIN_CHECK_VERSION_WARN="y"
+			THIN_CHECK_NEEDS_CHECK="no"
+
+fi
+
+fi
 	# Empty means a config way to ignore thin dumping
-	if test "$THIN_DUMP_CMD" = "autodetect"; then
+	if test "$THIN_DUMP_CMD" = "autodetect"
+then :
+
 		if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}thin_dump", so it can be a program name with args.
 set dummy ${ac_tool_prefix}thin_dump; ac_word=$2
@@ -9725,15 +9766,21 @@ else
   THIN_DUMP_CMD="$ac_cv_path_THIN_DUMP_CMD"
 fi
 
-		test -z "$THIN_DUMP_CMD" && {
-			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: thin_dump not found in path $PATH" >&5
-printf "%s\n" "$as_me: WARNING: thin_dump not found in path $PATH" >&2;}
-			THIN_DUMP_CMD=/usr/sbin/thin_dump
-			THIN_CONFIGURE_WARN=y
-		}
-	fi
+		if test -z "$THIN_DUMP_CMD"
+then :
+
+			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: \"thin_dump not found in path $PATH\"" >&5
+printf "%s\n" "$as_me: WARNING: \"thin_dump not found in path $PATH\"" >&2;}
+			THIN_DUMP_CMD="/usr/sbin/thin_dump"
+			THIN_CONFIGURE_WARN="y"
+
+fi
+
+fi
 	# Empty means a config way to ignore thin repairing
-	if test "$THIN_REPAIR_CMD" = "autodetect"; then
+	if test "$THIN_REPAIR_CMD" = "autodetect"
+then :
+
 		if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}thin_repair", so it can be a program name with args.
 set dummy ${ac_tool_prefix}thin_repair; ac_word=$2
@@ -9842,15 +9889,21 @@ else
   THIN_REPAIR_CMD="$ac_cv_path_THIN_REPAIR_CMD"
 fi
 
-		test -z "$THIN_REPAIR_CMD" && {
-			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: thin_repair not found in path $PATH" >&5
-printf "%s\n" "$as_me: WARNING: thin_repair not found in path $PATH" >&2;}
-			THIN_REPAIR_CMD=/usr/sbin/thin_repair
-			THIN_CONFIGURE_WARN=y
-		}
-	fi
+		if test -z "$THIN_REPAIR_CMD"
+then :
+
+			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: \"thin_repair not found in path $PATH\"" >&5
+printf "%s\n" "$as_me: WARNING: \"thin_repair not found in path $PATH\"" >&2;}
+			THIN_REPAIR_CMD="/usr/sbin/thin_repair"
+			THIN_CONFIGURE_WARN="y"
+
+fi
+
+fi
 	# Empty means a config way to ignore thin restoring
-	if test "$THIN_RESTORE_CMD" = "autodetect"; then
+	if test "$THIN_RESTORE_CMD" = "autodetect"
+then :
+
 		if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}thin_restore", so it can be a program name with args.
 set dummy ${ac_tool_prefix}thin_restore; ac_word=$2
@@ -9959,24 +10012,33 @@ else
   THIN_RESTORE_CMD="$ac_cv_path_THIN_RESTORE_CMD"
 fi
 
-		test -z "$THIN_RESTORE_CMD" && {
-			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: thin_restore not found in path $PATH" >&5
-printf "%s\n" "$as_me: WARNING: thin_restore not found in path $PATH" >&2;}
-			THIN_RESTORE_CMD=/usr/sbin/thin_restore
-			THIN_CONFIGURE_WARN=y
-		}
-	fi
+		if test -z "$THIN_RESTORE_CMD"
+then :
+
+			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: \"thin_restore not found in path $PATH\"" >&5
+printf "%s\n" "$as_me: WARNING: \"thin_restore not found in path $PATH\"" >&2;}
+			THIN_RESTORE_CMD="/usr/sbin/thin_restore"
+			THIN_CONFIGURE_WARN="y"
+
+fi
+
+fi
 
 	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether thin_check supports the needs-check flag" >&5
 printf %s "checking whether thin_check supports the needs-check flag... " >&6; }
 	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $THIN_CHECK_NEEDS_CHECK" >&5
 printf "%s\n" "$THIN_CHECK_NEEDS_CHECK" >&6; }
-	if test "$THIN_CHECK_NEEDS_CHECK" = yes; then
+	if test "$THIN_CHECK_NEEDS_CHECK" = "yes"
+then :
+
 
 printf "%s\n" "#define THIN_CHECK_NEEDS_CHECK 1" >>confdefs.h
 
-	fi
-	;;
+
+fi
+ ;; #(
+  *) :
+     ;;
 esac
 
 
@@ -10046,12 +10108,16 @@ fi
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CACHE" >&5
 printf "%s\n" "$CACHE" >&6; }
 
-case "$CACHE" in
- no|none|shared) ;;
- internal)
+case "$CACHE" in #(
+  no|none|shared) :
+     ;; #(
+  internal) :
+
+
 printf "%s\n" "#define CACHE_INTERNAL 1" >>confdefs.h
- ;;
- *) as_fn_error $? "--with-cache parameter invalid" "$LINENO" 5 ;;
+ ;; #(
+  *) :
+    as_fn_error $? "--with-cache parameter invalid" "$LINENO" 5 ;;
 esac
 
 # Check whether --enable-cache_check_needs_check was given.
@@ -10059,16 +10125,19 @@ if test ${enable_cache_check_needs_check+y}
 then :
   enableval=$enable_cache_check_needs_check; CACHE_CHECK_NEEDS_CHECK=$enableval
 else $as_nop
-  CACHE_CHECK_NEEDS_CHECK=yes
+  CACHE_CHECK_NEEDS_CHECK="yes"
 fi
 
 
 # Test if necessary cache tools are available
 # if not - use plain defaults and warn user
-case "$CACHE" in
-  internal|shared)
+case "$CACHE" in #(
+  internal|shared) :
+
 	# Empty means a config way to ignore cache checking
-	if test "$CACHE_CHECK_CMD" = "autodetect"; then
+	if test "$CACHE_CHECK_CMD" = "autodetect"
+then :
+
 		if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}cache_check", so it can be a program name with args.
 set dummy ${ac_tool_prefix}cache_check; ac_word=$2
@@ -10177,14 +10246,20 @@ else
   CACHE_CHECK_CMD="$ac_cv_path_CACHE_CHECK_CMD"
 fi
 
-		if test -z "$CACHE_CHECK_CMD"; then
+		if test -z "$CACHE_CHECK_CMD"
+then :
+
 			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: cache_check not found in path $PATH" >&5
 printf "%s\n" "$as_me: WARNING: cache_check not found in path $PATH" >&2;}
-			CACHE_CHECK_CMD=/usr/sbin/cache_check
-			CACHE_CONFIGURE_WARN=y
-		fi
-	fi
-	if test "$CACHE_CHECK_NEEDS_CHECK" = yes && test "$CACHE_CONFIGURE_WARN" != y ; then
+			CACHE_CHECK_CMD="/usr/sbin/cache_check"
+			CACHE_CONFIGURE_WARN="y"
+
+fi
+
+fi
+	if test "$CACHE_CHECK_NEEDS_CHECK" = "yes" && test "$CACHE_CONFIGURE_WARN" != "y"
+then :
+
 		$CACHE_CHECK_CMD -V 2>/dev/null >conftest.tmp
 		read -r CACHE_CHECK_VSN < conftest.tmp
 		IFS=.- read -r CACHE_CHECK_VSN_MAJOR CACHE_CHECK_VSN_MINOR CACHE_CHECK_VSN_PATCH LEFTOVER < conftest.tmp
@@ -10193,28 +10268,43 @@ printf "%s\n" "$as_me: WARNING: cache_check not found in path $PATH" >&2;}
 		# Require version >= 0.5.4 for --clear-needs-check-flag
 		if test -z "$CACHE_CHECK_VSN_MAJOR" \
 			|| test -z "$CACHE_CHECK_VSN_MINOR" \
-			|| test -z "$CACHE_CHECK_VSN_PATCH"; then
+			|| test -z "$CACHE_CHECK_VSN_PATCH"
+then :
+
 			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: $CACHE_CHECK_CMD: Bad version \"$CACHE_CHECK_VSN\" found" >&5
 printf "%s\n" "$as_me: WARNING: $CACHE_CHECK_CMD: Bad version \"$CACHE_CHECK_VSN\" found" >&2;}
-			CACHE_CHECK_VERSION_WARN=y
-			CACHE_CHECK_NEEDS_CHECK=no
-		elif test "$CACHE_CHECK_VSN_MAJOR" -eq 0 ; then
+			CACHE_CHECK_VERSION_WARN="y"
+			CACHE_CHECK_NEEDS_CHECK="no"
+
+elif test "$CACHE_CHECK_VSN_MAJOR" -eq 0
+then :
+
 			if test "$CACHE_CHECK_VSN_MINOR" -lt 5 \
-				|| test "$CACHE_CHECK_VSN_MINOR" -eq 5 -a "$CACHE_CHECK_VSN_PATCH" -lt 4; then
+				|| ( test "$CACHE_CHECK_VSN_MINOR" -eq 5 && test "$CACHE_CHECK_VSN_PATCH" -lt 4 )
+then :
+
 				{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: $CACHE_CHECK_CMD: Old version \"$CACHE_CHECK_VSN\" found" >&5
 printf "%s\n" "$as_me: WARNING: $CACHE_CHECK_CMD: Old version \"$CACHE_CHECK_VSN\" found" >&2;}
-				CACHE_CHECK_VERSION_WARN=y
-				CACHE_CHECK_NEEDS_CHECK=no
-			fi
-			if test "$CACHE_CHECK_VSN_MINOR" -lt 7 ; then
+				CACHE_CHECK_VERSION_WARN="y"
+				CACHE_CHECK_NEEDS_CHECK="no"
+
+fi
+			if test "$CACHE_CHECK_VSN_MINOR" -lt 7
+then :
+
 				{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: $CACHE_CHECK_CMD: Old version \"$CACHE_CHECK_VSN\" does not support new cache format V2" >&5
 printf "%s\n" "$as_me: WARNING: $CACHE_CHECK_CMD: Old version \"$CACHE_CHECK_VSN\" does not support new cache format V2" >&2;}
 				CACHE_CHECK_VERSION_WARN=y
-			fi
-		fi
-	fi
+
+fi
+
+fi
+
+fi
 	# Empty means a config way to ignore cache dumping
-	if test "$CACHE_DUMP_CMD" = "autodetect"; then
+	if test "$CACHE_DUMP_CMD" = "autodetect"
+then :
+
 		if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}cache_dump", so it can be a program name with args.
 set dummy ${ac_tool_prefix}cache_dump; ac_word=$2
@@ -10323,15 +10413,21 @@ else
   CACHE_DUMP_CMD="$ac_cv_path_CACHE_DUMP_CMD"
 fi
 
-		test -z "$CACHE_DUMP_CMD" && {
-			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: cache_dump not found in path $PATH" >&5
-printf "%s\n" "$as_me: WARNING: cache_dump not found in path $PATH" >&2;}
-			CACHE_DUMP_CMD=/usr/sbin/cache_dump
-			CACHE_CONFIGURE_WARN=y
-		}
-	fi
+		if test -z "$CACHE_DUMP_CMD"
+then :
+
+			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: \"cache_dump not found in path $PATH\"" >&5
+printf "%s\n" "$as_me: WARNING: \"cache_dump not found in path $PATH\"" >&2;}
+			CACHE_DUMP_CMD="/usr/sbin/cache_dump"
+			CACHE_CONFIGURE_WARN="y"
+
+fi
+
+fi
 	# Empty means a config way to ignore cache repairing
-	if test "$CACHE_REPAIR_CMD" = "autodetect"; then
+	if test "$CACHE_REPAIR_CMD" = "autodetect"
+then :
+
 		if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}cache_repair", so it can be a program name with args.
 set dummy ${ac_tool_prefix}cache_repair; ac_word=$2
@@ -10440,15 +10536,21 @@ else
   CACHE_REPAIR_CMD="$ac_cv_path_CACHE_REPAIR_CMD"
 fi
 
-		test -z "$CACHE_REPAIR_CMD" && {
-			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: cache_repair not found in path $PATH" >&5
-printf "%s\n" "$as_me: WARNING: cache_repair not found in path $PATH" >&2;}
-			CACHE_REPAIR_CMD=/usr/sbin/cache_repair
-			CACHE_CONFIGURE_WARN=y
-		}
-	fi
+		if test -z "$CACHE_REPAIR_CMD"
+then :
+
+			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: \"cache_repair not found in path $PATH\"" >&5
+printf "%s\n" "$as_me: WARNING: \"cache_repair not found in path $PATH\"" >&2;}
+			CACHE_REPAIR_CMD="/usr/sbin/cache_repair"
+			CACHE_CONFIGURE_WARN="y"
+
+fi
+
+fi
 	# Empty means a config way to ignore cache restoring
-	if test "$CACHE_RESTORE_CMD" = "autodetect"; then
+	if test "$CACHE_RESTORE_CMD" = "autodetect"
+then :
+
 		if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}cache_restore", so it can be a program name with args.
 set dummy ${ac_tool_prefix}cache_restore; ac_word=$2
@@ -10557,24 +10659,33 @@ else
   CACHE_RESTORE_CMD="$ac_cv_path_CACHE_RESTORE_CMD"
 fi
 
-		test -z "$CACHE_RESTORE_CMD" && {
-			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: cache_restore not found in path $PATH" >&5
-printf "%s\n" "$as_me: WARNING: cache_restore not found in path $PATH" >&2;}
-			CACHE_RESTORE_CMD=/usr/sbin/cache_restore
-			CACHE_CONFIGURE_WARN=y
-		}
-	fi
+		if test -z "$CACHE_RESTORE_CMD"
+then :
+
+			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: \"cache_restore not found in path $PATH\"" >&5
+printf "%s\n" "$as_me: WARNING: \"cache_restore not found in path $PATH\"" >&2;}
+			CACHE_RESTORE_CMD="/usr/sbin/cache_restore"
+			CACHE_CONFIGURE_WARN="y"
+
+fi
+
+fi
 
 	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether cache_check supports the needs-check flag" >&5
 printf %s "checking whether cache_check supports the needs-check flag... " >&6; }
 	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CACHE_CHECK_NEEDS_CHECK" >&5
 printf "%s\n" "$CACHE_CHECK_NEEDS_CHECK" >&6; }
-	if test "$CACHE_CHECK_NEEDS_CHECK" = yes; then
+	if test "$CACHE_CHECK_NEEDS_CHECK" = "yes"
+then :
+
 
 printf "%s\n" "#define CACHE_CHECK_NEEDS_CHECK 1" >>confdefs.h
 
-	fi
-	;;
+
+fi
+ ;; #(
+  *) :
+     ;;
 esac
 
 
@@ -10618,14 +10729,18 @@ else $as_nop
   VDO_FORMAT_CMD="autodetect"
 fi
 
-case "$VDO" in
- no|none) ;;
- internal)
+case "$VDO" in #(
+  no|none) :
+     ;; #(
+  internal) :
+
 
 printf "%s\n" "#define VDO_INTERNAL 1" >>confdefs.h
 
-	if test "$VDO_FORMAT_CMD" = "autodetect"; then
-		if test -n "$ac_tool_prefix"; then
+		if test "$VDO_FORMAT_CMD" = "autodetect"
+then :
+
+			if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}vdoformat", so it can be a program name with args.
 set dummy ${ac_tool_prefix}vdoformat; ac_word=$2
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
@@ -10733,15 +10848,19 @@ else
   VDO_FORMAT_CMD="$ac_cv_path_VDO_FORMAT_CMD"
 fi
 
-		if test -z "$VDO_FORMAT_CMD"; then
-			{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: vdoformat not found in path $PATH" >&5
+			if test -z "$VDO_FORMAT_CMD"
+then :
+
+				{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: vdoformat not found in path $PATH" >&5
 printf "%s\n" "$as_me: WARNING: vdoformat not found in path $PATH" >&2;}
-			VDO_FORMAT_CMD=/usr/bin/vdoformat
-			VDO_CONFIGURE_WARN=y
-		fi
-	fi
-	;;
- *) as_fn_error $? "--with-vdo parameter invalid" "$LINENO" 5 ;;
+				VDO_FORMAT_CMD="/usr/bin/vdoformat"
+				VDO_CONFIGURE_WARN=y
+
+fi
+
+fi ;; #(
+  *) :
+    as_fn_error $? "--with-vdo parameter invalid" "$LINENO" 5 ;;
 esac
 
 
@@ -10755,13 +10874,13 @@ printf "%s\n" "#define VDO_FORMAT_CMD \"$VDO_FORMAT_CMD\"" >>confdefs.h
 #	    AS_HELP_STRING([--with-vdo-include=PATH],
 #			   [vdo support: Path to utils headers: [/usr/include/vdo/utils]]),
 #			   VDO_INCLUDE=$withval, VDO_INCLUDE="/usr/include/vdo/utils")
-#AC_MSG_RESULT($VDO_INCLUDE)
+#AC_MSG_RESULT([$VDO_INCLUDE])
 #
 #AC_ARG_WITH(vdo-lib,
 #            AS_HELP_STRING([--with-vdo-lib=PATH],
 #                           [vdo support: Path to utils lib: [/usr/lib]]),
 #                           VDO_LIB=$withval, VDO_LIB="/usr/lib")
-#AC_MSG_RESULT($VDO_LIB)
+#AC_MSG_RESULT([$VDO_LIB])
 
 ################################################################################
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to include writecache" >&5
@@ -10779,14 +10898,16 @@ fi
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $WRITECACHE" >&5
 printf "%s\n" "$WRITECACHE" >&6; }
 
-case "$WRITECACHE" in
- no|none) ;;
- internal)
+case "$WRITECACHE" in #(
+  no|none) :
+     ;; #(
+  internal) :
 
-printf "%s\n" "#define WRITECACHE_INTERNAL 1" >>confdefs.h
 
-	;;
- *) as_fn_error $? "--with-writecache parameter invalid" "$LINENO" 5 ;;
+printf "%s\n" "#define WRITECACHE_INTERNAL 1" >>confdefs.h
+ ;; #(
+  *) :
+    as_fn_error $? "--with-writecache parameter invalid" "$LINENO" 5 ;;
 esac
 
 ################################################################################
@@ -10805,14 +10926,16 @@ fi
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $INTEGRITY" >&5
 printf "%s\n" "$INTEGRITY" >&6; }
 
-case "$INTEGRITY" in
- no|none) ;;
- internal)
+case "$INTEGRITY" in #(
+  no|none) :
+     ;; #(
+  internal) :
 
-printf "%s\n" "#define INTEGRITY_INTERNAL 1" >>confdefs.h
 
-	;;
- *) as_fn_error $? "--with-integrity parameter invalid" "$LINENO" 5 ;;
+printf "%s\n" "#define INTEGRITY_INTERNAL 1" >>confdefs.h
+ ;; #(
+  *) :
+    as_fn_error $? "--with-integrity parameter invalid" "$LINENO" 5 ;;
 esac
 
 ################################################################################
@@ -10829,7 +10952,7 @@ if test ${enable_readline+y}
 then :
   enableval=$enable_readline; READLINE=$enableval
 else $as_nop
-  READLINE=maybe
+  READLINE="maybe"
 fi
 
 
@@ -10839,7 +10962,7 @@ if test ${enable_editline+y}
 then :
   enableval=$enable_editline; EDITLINE=$enableval
 else $as_nop
-  EDITLINE=no
+  EDITLINE="no"
 fi
 
 
@@ -10851,7 +10974,7 @@ if test ${enable_realtime+y}
 then :
   enableval=$enable_realtime; REALTIME=$enableval
 else $as_nop
-  REALTIME=yes
+  REALTIME="yes"
 fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $REALTIME" >&5
@@ -10865,7 +10988,7 @@ if test ${enable_ocf+y}
 then :
   enableval=$enable_ocf; OCF=$enableval
 else $as_nop
-  OCF=no
+  OCF="no"
 fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $OCF" >&5
@@ -10881,71 +11004,153 @@ fi
 
 
 ################################################################################
-pkg_config_init() {
-	if test "$PKGCONFIG_INIT" != 1; then
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for default run directory" >&5
+printf %s "checking for default run directory... " >&6; }
+RUN_DIR="/run"
+test -d "/run" || RUN_DIR="/var/run"
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $RUN_DIR" >&5
+printf "%s\n" "$RUN_DIR" >&6; }
 
 
+# Check whether --with-default-pid-dir was given.
+if test ${with_default_pid_dir+y}
+then :
+  withval=$with_default_pid_dir; DEFAULT_PID_DIR="$withval"
+else $as_nop
+  DEFAULT_PID_DIR=$RUN_DIR
+fi
+
 
+printf "%s\n" "#define DEFAULT_PID_DIR \"$DEFAULT_PID_DIR\"" >>confdefs.h
 
 
 
 
-if test "x$ac_cv_env_PKG_CONFIG_set" != "xset"; then
-	if test -n "$ac_tool_prefix"; then
-  # Extract the first word of "${ac_tool_prefix}pkg-config", so it can be a program name with args.
-set dummy ${ac_tool_prefix}pkg-config; ac_word=$2
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-printf %s "checking for $ac_word... " >&6; }
-if test ${ac_cv_path_PKG_CONFIG+y}
+# Check whether --with-default-dm-run-dir was given.
+if test ${with_default_dm_run_dir+y}
 then :
-  printf %s "(cached) " >&6
+  withval=$with_default_dm_run_dir; DEFAULT_DM_RUN_DIR="$withval"
 else $as_nop
-  case $PKG_CONFIG in
-  [\\/]* | ?:[\\/]*)
-  ac_cv_path_PKG_CONFIG="$PKG_CONFIG" # Let the user override the test with a path.
-  ;;
-  *)
-  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
-for as_dir in $PATH
-do
-  IFS=$as_save_IFS
-  case $as_dir in #(((
-    '') as_dir=./ ;;
-    */) ;;
-    *) as_dir=$as_dir/ ;;
-  esac
-    for ac_exec_ext in '' $ac_executable_extensions; do
-  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
-    ac_cv_path_PKG_CONFIG="$as_dir$ac_word$ac_exec_ext"
-    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
-    break 2
-  fi
-done
-  done
-IFS=$as_save_IFS
-
-  ;;
-esac
-fi
-PKG_CONFIG=$ac_cv_path_PKG_CONFIG
-if test -n "$PKG_CONFIG"; then
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $PKG_CONFIG" >&5
-printf "%s\n" "$PKG_CONFIG" >&6; }
-else
-  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
-printf "%s\n" "no" >&6; }
+  DEFAULT_DM_RUN_DIR=$RUN_DIR
 fi
 
 
-fi
-if test -z "$ac_cv_path_PKG_CONFIG"; then
-  ac_pt_PKG_CONFIG=$PKG_CONFIG
-  # Extract the first word of "pkg-config", so it can be a program name with args.
-set dummy pkg-config; ac_word=$2
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
-printf %s "checking for $ac_word... " >&6; }
-if test ${ac_cv_path_ac_pt_PKG_CONFIG+y}
-then :
+printf "%s\n" "#define DEFAULT_DM_RUN_DIR \"$DEFAULT_DM_RUN_DIR\"" >>confdefs.h
+
+
+
+
+# Check whether --with-default-run-dir was given.
+if test ${with_default_run_dir+y}
+then :
+  withval=$with_default_run_dir; DEFAULT_RUN_DIR="$withval"
+else $as_nop
+  DEFAULT_RUN_DIR="$RUN_DIR/lvm"
+fi
+
+
+printf "%s\n" "#define DEFAULT_RUN_DIR \"$DEFAULT_RUN_DIR\"" >>confdefs.h
+
+
+################################################################################
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to build cluster mirror log daemon" >&5
+printf %s "checking whether to build cluster mirror log daemon... " >&6; }
+# Check whether --enable-cmirrord was given.
+if test ${enable_cmirrord+y}
+then :
+  enableval=$enable_cmirrord; CMIRRORD=$enableval
+else $as_nop
+  CMIRRORD="no"
+fi
+
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CMIRRORD" >&5
+printf "%s\n" "$CMIRRORD" >&6; }
+
+BUILD_CMIRRORD=$CMIRRORD
+
+################################################################################
+if test "$BUILD_CMIRRORD" = "yes"
+then :
+
+
+# Check whether --with-cmirrord-pidfile was given.
+if test ${with_cmirrord_pidfile+y}
+then :
+  withval=$with_cmirrord_pidfile; CMIRRORD_PIDFILE=$withval
+else $as_nop
+  CMIRRORD_PIDFILE="$DEFAULT_PID_DIR/cmirrord.pid"
+fi
+
+
+printf "%s\n" "#define CMIRRORD_PIDFILE \"$CMIRRORD_PIDFILE\"" >>confdefs.h
+
+
+fi
+
+################################################################################
+
+
+
+
+
+
+
+if test "x$ac_cv_env_PKG_CONFIG_set" != "xset"; then
+	if test -n "$ac_tool_prefix"; then
+  # Extract the first word of "${ac_tool_prefix}pkg-config", so it can be a program name with args.
+set dummy ${ac_tool_prefix}pkg-config; ac_word=$2
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_PKG_CONFIG+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  case $PKG_CONFIG in
+  [\\/]* | ?:[\\/]*)
+  ac_cv_path_PKG_CONFIG="$PKG_CONFIG" # Let the user override the test with a path.
+  ;;
+  *)
+  as_save_IFS=$IFS; IFS=$PATH_SEPARATOR
+for as_dir in $PATH
+do
+  IFS=$as_save_IFS
+  case $as_dir in #(((
+    '') as_dir=./ ;;
+    */) ;;
+    *) as_dir=$as_dir/ ;;
+  esac
+    for ac_exec_ext in '' $ac_executable_extensions; do
+  if as_fn_executable_p "$as_dir$ac_word$ac_exec_ext"; then
+    ac_cv_path_PKG_CONFIG="$as_dir$ac_word$ac_exec_ext"
+    printf "%s\n" "$as_me:${as_lineno-$LINENO}: found $as_dir$ac_word$ac_exec_ext" >&5
+    break 2
+  fi
+done
+  done
+IFS=$as_save_IFS
+
+  ;;
+esac
+fi
+PKG_CONFIG=$ac_cv_path_PKG_CONFIG
+if test -n "$PKG_CONFIG"; then
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $PKG_CONFIG" >&5
+printf "%s\n" "$PKG_CONFIG" >&6; }
+else
+  { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
+fi
+
+
+fi
+if test -z "$ac_cv_path_PKG_CONFIG"; then
+  ac_pt_PKG_CONFIG=$PKG_CONFIG
+  # Extract the first word of "pkg-config", so it can be a program name with args.
+set dummy pkg-config; ac_word=$2
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $ac_word" >&5
+printf %s "checking for $ac_word... " >&6; }
+if test ${ac_cv_path_ac_pt_PKG_CONFIG+y}
+then :
   printf %s "(cached) " >&6
 else $as_nop
   case $ac_pt_PKG_CONFIG in
@@ -11013,170 +11218,10 @@ printf "%s\n" "no" >&6; }
 		PKG_CONFIG=""
 	fi
 fi
-
-pkg_failed=no
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for PKGCONFIGINIT" >&5
-printf %s "checking for PKGCONFIGINIT... " >&6; }
-
-if test -n "$PKGCONFIGINIT_CFLAGS"; then
-    pkg_cv_PKGCONFIGINIT_CFLAGS="$PKGCONFIGINIT_CFLAGS"
- elif test -n "$PKG_CONFIG"; then
-    if test -n "$PKG_CONFIG" && \
-    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"pkgconfiginit\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "pkgconfiginit") 2>&5
-  ac_status=$?
-  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
-  test $ac_status = 0; }; then
-  pkg_cv_PKGCONFIGINIT_CFLAGS=`$PKG_CONFIG --cflags "pkgconfiginit" 2>/dev/null`
-		      test "x$?" != "x0" && pkg_failed=yes
-else
-  pkg_failed=yes
-fi
- else
-    pkg_failed=untried
-fi
-if test -n "$PKGCONFIGINIT_LIBS"; then
-    pkg_cv_PKGCONFIGINIT_LIBS="$PKGCONFIGINIT_LIBS"
- elif test -n "$PKG_CONFIG"; then
-    if test -n "$PKG_CONFIG" && \
-    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"pkgconfiginit\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "pkgconfiginit") 2>&5
-  ac_status=$?
-  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
-  test $ac_status = 0; }; then
-  pkg_cv_PKGCONFIGINIT_LIBS=`$PKG_CONFIG --libs "pkgconfiginit" 2>/dev/null`
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
-   	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
-printf "%s\n" "no" >&6; }
-
-if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
-        _pkg_short_errors_supported=yes
-else
-        _pkg_short_errors_supported=no
-fi
-        if test $_pkg_short_errors_supported = yes; then
-	        PKGCONFIGINIT_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "pkgconfiginit" 2>&1`
-        else
-	        PKGCONFIGINIT_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "pkgconfiginit" 2>&1`
-        fi
-	# Put the nasty error message in config.log where it belongs
-	echo "$PKGCONFIGINIT_PKG_ERRORS" >&5
-
-	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: pkg-config initialized" >&5
-printf "%s\n" "pkg-config initialized" >&6; }
-elif test $pkg_failed = untried; then
-     	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
-printf "%s\n" "no" >&6; }
-	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: pkg-config initialized" >&5
-printf "%s\n" "pkg-config initialized" >&6; }
-else
-	PKGCONFIGINIT_CFLAGS=$pkg_cv_PKGCONFIGINIT_CFLAGS
-	PKGCONFIGINIT_LIBS=$pkg_cv_PKGCONFIGINIT_LIBS
-        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-printf "%s\n" "yes" >&6; }
-
-fi
-		PKGCONFIG_INIT=1
-	fi
-}
-
-################################################################################
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for default run directory" >&5
-printf %s "checking for default run directory... " >&6; }
-RUN_DIR="/run"
-test -d "/run" || RUN_DIR="/var/run"
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $RUN_DIR" >&5
-printf "%s\n" "$RUN_DIR" >&6; }
-
-
-# Check whether --with-default-pid-dir was given.
-if test ${with_default_pid_dir+y}
-then :
-  withval=$with_default_pid_dir; DEFAULT_PID_DIR="$withval"
-else $as_nop
-  DEFAULT_PID_DIR=$RUN_DIR
-fi
-
-
-printf "%s\n" "#define DEFAULT_PID_DIR \"$DEFAULT_PID_DIR\"" >>confdefs.h
-
-
-
-
-# Check whether --with-default-dm-run-dir was given.
-if test ${with_default_dm_run_dir+y}
+if test "$BUILD_CMIRRORD" = "yes" && test "$HAVE_CPG" != "yes"
 then :
-  withval=$with_default_dm_run_dir; DEFAULT_DM_RUN_DIR="$withval"
-else $as_nop
-  DEFAULT_DM_RUN_DIR=$RUN_DIR
-fi
-
-
-printf "%s\n" "#define DEFAULT_DM_RUN_DIR \"$DEFAULT_DM_RUN_DIR\"" >>confdefs.h
 
 
-
-
-# Check whether --with-default-run-dir was given.
-if test ${with_default_run_dir+y}
-then :
-  withval=$with_default_run_dir; DEFAULT_RUN_DIR="$withval"
-else $as_nop
-  DEFAULT_RUN_DIR="$RUN_DIR/lvm"
-fi
-
-
-printf "%s\n" "#define DEFAULT_RUN_DIR \"$DEFAULT_RUN_DIR\"" >>confdefs.h
-
-
-################################################################################
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to build cluster mirror log daemon" >&5
-printf %s "checking whether to build cluster mirror log daemon... " >&6; }
-# Check whether --enable-cmirrord was given.
-if test ${enable_cmirrord+y}
-then :
-  enableval=$enable_cmirrord; CMIRRORD=$enableval
-else $as_nop
-  CMIRRORD=no
-fi
-
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CMIRRORD" >&5
-printf "%s\n" "$CMIRRORD" >&6; }
-
-BUILD_CMIRRORD=$CMIRRORD
-
-################################################################################
-if test "$BUILD_CMIRRORD" = yes; then
-
-# Check whether --with-cmirrord-pidfile was given.
-if test ${with_cmirrord_pidfile+y}
-then :
-  withval=$with_cmirrord_pidfile; CMIRRORD_PIDFILE=$withval
-else $as_nop
-  CMIRRORD_PIDFILE="$DEFAULT_PID_DIR/cmirrord.pid"
-fi
-
-
-printf "%s\n" "#define CMIRRORD_PIDFILE \"$CMIRRORD_PIDFILE\"" >>confdefs.h
-
-fi
-
-################################################################################
-if [ "$BUILD_CMIRRORD" = yes ]; then
-	pkg_config_init
-
-	if test "$HAVE_CPG" != yes; then
-
 pkg_failed=no
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for CPG" >&5
 printf %s "checking for CPG... " >&6; }
@@ -11267,7 +11312,7 @@ else
 printf "%s\n" "yes" >&6; }
 
 fi
-	fi
+
 fi
 
 ################################################################################
@@ -11278,16 +11323,17 @@ if test ${enable_debug+y}
 then :
   enableval=$enable_debug; DEBUG=$enableval
 else $as_nop
-  DEBUG=no
+  DEBUG="no"
 fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $DEBUG" >&5
 printf "%s\n" "$DEBUG" >&6; }
 
-if test "$DEBUG" = yes; then
-	COPTIMISE_FLAG=
-else
-	CSCOPE_CMD=
+if test "$DEBUG" = "yes"
+then :
+  COPTIMISE_FLAG=""
+else $as_nop
+  CSCOPE_CMD=""
 fi
 
 
@@ -11431,27 +11477,35 @@ printf %s "checking whether to use symbol versioning... " >&6; }
 # Check whether --with-symvers was given.
 if test ${with_symvers+y}
 then :
-  withval=$with_symvers;  case "$withval" in
-				gnu|no) symvers=$withval ;;
-				*) as_fn_error $? "--with-symvers parameter invalid" "$LINENO" 5 ;;
-			     esac
+  withval=$with_symvers;
+			case "$withval" in #(
+  gnu|no) :
+    symvers=$withval ;; #(
+  *) :
+    as_fn_error $? "--with-symvers parameter invalid" "$LINENO" 5 ;;
+esac
 else $as_nop
-  symvers=gnu
+  symvers="gnu"
 fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $symvers" >&5
 printf "%s\n" "$symvers" >&6; }
 
-if test "$GCC" = "yes" && test "$symvers" = "gnu" ; then
+if test "$GCC" = "yes" && test "$symvers" = "gnu"
+then :
+
 
 printf "%s\n" "#define GNU_SYMVER 1" >>confdefs.h
 
-		   case "$host_os" in
-			linux*)
+	case "$host_os" in #(
+  linux*) :
+
 			CLDFLAGS="${CLDFLAGS-"$LDFLAGS"} -Wl,--version-script,.export.sym"
-			LDDEPS="$LDDEPS .export.sym"
-			;;
-		   esac
+			LDDEPS="$LDDEPS .export.sym" ;; #(
+  *) :
+     ;;
+esac
+
 fi
 
 ################################################################################
@@ -11462,13 +11516,15 @@ if test ${enable_profiling+y}
 then :
   enableval=$enable_profiling; PROFILING=$enableval
 else $as_nop
-  PROFILING=no
+  PROFILING="no"
 fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $PROFILING" >&5
 printf "%s\n" "$PROFILING" >&6; }
 
-if test "$PROFILING" = yes; then
+if test "$PROFILING" = "yes"
+then :
+
   COPTIMISE_FLAG="$COPTIMISE_FLAG -fprofile-arcs -ftest-coverage"
   if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}lcov", so it can be a program name with args.
@@ -11686,7 +11742,12 @@ else
   GENHTML="$ac_cv_path_GENHTML"
 fi
 
-  test -z "$LCOV" -o -z "$GENHTML" && as_fn_error $? "lcov and genhtml are required for profiling" "$LINENO" 5
+  if test -z "$LCOV" || test -z "$GENHTML"
+then :
+
+    as_fn_error $? "lcov and genhtml are required for profiling" "$LINENO" 5
+
+fi
   if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}genpng", so it can be a program name with args.
 set dummy ${ac_tool_prefix}genpng; ac_word=$2
@@ -11795,21 +11856,30 @@ else
   GENPNG="$ac_cv_path_GENPNG"
 fi
 
-  if test -n "$GENPNG"; then
+  if test -n "$GENPNG"
+then :
+
     { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether $GENPNG has all required modules" >&5
 printf %s "checking whether $GENPNG has all required modules... " >&6; }
-    if "$GENPNG" --help > /dev/null 2>&1 ; then
+    if "$GENPNG" --help > /dev/null 2>&1
+then :
+
       { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: ok" >&5
 printf "%s\n" "ok" >&6; }
       GENHTML="$GENHTML --frames"
-    else
+
+else $as_nop
+
       { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: not supported" >&5
 printf "%s\n" "not supported" >&6; }
       { printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: GD.pm perl module is not installed" >&5
 printf "%s\n" "$as_me: WARNING: GD.pm perl module is not installed" >&2;}
       GENPNG=
-    fi
-  fi
+
+fi
+
+fi
+
 fi
 
 ################################################################################
@@ -11827,13 +11897,12 @@ if test ${enable_valgrind_pool+y}
 then :
   enableval=$enable_valgrind_pool; VALGRIND_POOL=$enableval
 else $as_nop
-  VALGRIND_POOL=no
+  VALGRIND_POOL="no"
 fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $VALGRIND_POOL" >&5
 printf "%s\n" "$VALGRIND_POOL" >&6; }
 
-pkg_config_init
 
 pkg_failed=no
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for VALGRIND" >&5
@@ -11893,30 +11962,46 @@ fi
 	# Put the nasty error message in config.log where it belongs
 	echo "$VALGRIND_PKG_ERRORS" >&5
 
-	if test x$VALGRIND_POOL = xyes; then as_fn_error $? "bailing out" "$LINENO" 5; fi
+
+  if test "$VALGRIND_POOL" = "yes"
+then :
+  as_fn_error $? "bailing out" "$LINENO" 5
+fi
+
 elif test $pkg_failed = untried; then
      	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
 printf "%s\n" "no" >&6; }
-	if test x$VALGRIND_POOL = xyes; then as_fn_error $? "bailing out" "$LINENO" 5; fi
+
+  if test "$VALGRIND_POOL" = "yes"
+then :
+  as_fn_error $? "bailing out" "$LINENO" 5
+fi
+
 else
 	VALGRIND_CFLAGS=$pkg_cv_VALGRIND_CFLAGS
 	VALGRIND_LIBS=$pkg_cv_VALGRIND_LIBS
         { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 printf "%s\n" "yes" >&6; }
-	HAVE_VALGRIND=yes
+	HAVE_VALGRIND="yes"
 fi
 
 
-if test x$HAVE_VALGRIND = xyes; then
+if test "$HAVE_VALGRIND" = "yes"
+then :
+
 
 printf "%s\n" "#define HAVE_VALGRIND 1" >>confdefs.h
 
+
 fi
 
-if test x$VALGRIND_POOL = xyes; then
+if test "$VALGRIND_POOL" = "yes"
+then :
+
 
 printf "%s\n" "#define VALGRIND_POOL 1" >>confdefs.h
 
+
 fi
 
 ################################################################################
@@ -11931,10 +12016,13 @@ fi
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $DEVMAPPER" >&5
 printf "%s\n" "$DEVMAPPER" >&6; }
 
-if test "$DEVMAPPER" = yes; then
+if test "$DEVMAPPER" = "yes"
+then :
+
 
 printf "%s\n" "#define DEVMAPPER_SUPPORT 1" >>confdefs.h
 
+
 fi
 
 ################################################################################
@@ -11945,7 +12033,7 @@ if test ${enable_lvmpolld+y}
 then :
   enableval=$enable_lvmpolld; LVMPOLLD=$enableval
 else $as_nop
-  LVMPOLLD=no
+  LVMPOLLD="no"
 fi
 
 test -n "$LVMPOLLD" && BUILD_LVMPOLLD=$LVMPOLLD
@@ -11962,7 +12050,7 @@ if test ${enable_lvmlockd_sanlock+y}
 then :
   enableval=$enable_lvmlockd_sanlock; LOCKDSANLOCK=$enableval
 else $as_nop
-  LOCKDSANLOCK=no
+  LOCKDSANLOCK="no"
 fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $LOCKDSANLOCK" >&5
@@ -11970,7 +12058,9 @@ printf "%s\n" "$LOCKDSANLOCK" >&6; }
 
 BUILD_LOCKDSANLOCK=$LOCKDSANLOCK
 
-if test "$BUILD_LOCKDSANLOCK" = yes; then
+if test "$BUILD_LOCKDSANLOCK" = "yes"
+then :
+
 
 pkg_failed=no
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for LOCKD_SANLOCK" >&5
@@ -12046,6 +12136,7 @@ fi
 printf "%s\n" "#define LOCKDSANLOCK_SUPPORT 1" >>confdefs.h
 
 	BUILD_LVMLOCKD=yes
+
 fi
 
 ################################################################################
@@ -12056,7 +12147,7 @@ if test ${enable_lvmlockd_dlm+y}
 then :
   enableval=$enable_lvmlockd_dlm; LOCKDDLM=$enableval
 else $as_nop
-  LOCKDDLM=no
+  LOCKDDLM="no"
 fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $LOCKDDLM" >&5
@@ -12064,7 +12155,9 @@ printf "%s\n" "$LOCKDDLM" >&6; }
 
 BUILD_LOCKDDLM=$LOCKDDLM
 
-if test "$BUILD_LOCKDDLM" = yes; then
+if test "$BUILD_LOCKDDLM" = "yes"
+then :
+
 
 pkg_failed=no
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for LOCKD_DLM" >&5
@@ -12140,6 +12233,7 @@ fi
 printf "%s\n" "#define LOCKDDLM_SUPPORT 1" >>confdefs.h
 
 	BUILD_LVMLOCKD=yes
+
 fi
 
 ################################################################################
@@ -12150,7 +12244,7 @@ if test ${enable_lvmlockd_dlmcontrol+y}
 then :
   enableval=$enable_lvmlockd_dlmcontrol; LOCKDDLM_CONTROL=$enableval
 else $as_nop
-  LOCKDDLM_CONTROL=no
+  LOCKDDLM_CONTROL="no"
 fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $LOCKDDLM_CONTROL" >&5
@@ -12158,7 +12252,9 @@ printf "%s\n" "$LOCKDDLM_CONTROL" >&6; }
 
 BUILD_LOCKDDLM_CONTROL=$LOCKDDLM_CONTROL
 
-if test "$BUILD_LOCKDDLM_CONTROL" = yes; then
+if test "$BUILD_LOCKDDLM_CONTROL" = "yes"
+then :
+
 
 pkg_failed=no
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for LOCKD_DLM_CONTROL" >&5
@@ -12234,6 +12330,7 @@ fi
 printf "%s\n" "#define LOCKDDLM_CONTROL_SUPPORT 1" >>confdefs.h
 
 	BUILD_LVMLOCKD=yes
+
 fi
 
 ################################################################################
@@ -12244,7 +12341,7 @@ if test ${enable_lvmlockd_idm+y}
 then :
   enableval=$enable_lvmlockd_idm; LOCKDIDM=$enableval
 else $as_nop
-  LOCKDIDM=no
+  LOCKDIDM="no"
 fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $LOCKDIDM" >&5
@@ -12252,7 +12349,9 @@ printf "%s\n" "$LOCKDIDM" >&6; }
 
 BUILD_LOCKDIDM=$LOCKDIDM
 
-if test "$BUILD_LOCKDIDM" = yes; then
+if test "$BUILD_LOCKDIDM" = "yes"
+then :
+
 
 pkg_failed=no
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for LOCKD_IDM" >&5
@@ -12330,7 +12429,7 @@ fi
   ac_status=$?
   printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  HAVE_LOCKD_IDM=yes
+  HAVE_LOCKD_IDM="yes"
 else
   $bailout
 fi
@@ -12338,6 +12437,7 @@ fi
 printf "%s\n" "#define LOCKDIDM_SUPPORT 1" >>confdefs.h
 
 	BUILD_LVMLOCKD=yes
+
 fi
 
 ################################################################################
@@ -12346,12 +12446,14 @@ printf %s "checking whether to build lvmlockd... " >&6; }
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BUILD_LVMLOCKD" >&5
 printf "%s\n" "$BUILD_LVMLOCKD" >&6; }
 
-if test "$BUILD_LVMLOCKD" = yes; then
-	if test "$LVMPOLLD" = no
+if test "$BUILD_LVMLOCKD" = "yes"
+then :
+
+	if test "$LVMPOLLD" = "no"
 then :
   as_fn_error $? "cannot build lvmlockd with --disable-lvmpolld." "$LINENO" 5
 fi
-	if test "$BUILD_LVMPOLLD" = no
+	if test "$BUILD_LVMPOLLD" = "no"
 then :
   BUILD_LVMPOLLD=yes; { printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: Enabling lvmpolld - required by lvmlockd." >&5
 printf "%s\n" "$as_me: WARNING: Enabling lvmpolld - required by lvmlockd." >&2;}
@@ -12361,10 +12463,12 @@ printf %s "checking defaults for use_lvmlockd... " >&6; }
 	# Check whether --enable-use_lvmlockd was given.
 if test ${enable_use_lvmlockd+y}
 then :
-  enableval=$enable_use_lvmlockd; case ${enableval} in
-		       yes) DEFAULT_USE_LVMLOCKD=1 ;;
-		       *) DEFAULT_USE_LVMLOCKD=0 ;;
-		       esac
+  enableval=$enable_use_lvmlockd; if test "$enableval" = "yes"
+then :
+  DEFAULT_USE_LVMLOCKD=1
+else $as_nop
+  DEFAULT_USE_LVMLOCKD=0
+fi
 else $as_nop
   DEFAULT_USE_LVMLOCKD=1
 fi
@@ -12387,24 +12491,31 @@ fi
 
 printf "%s\n" "#define LVMLOCKD_PIDFILE \"$LVMLOCKD_PIDFILE\"" >>confdefs.h
 
-else
+
+else $as_nop
+
 	DEFAULT_USE_LVMLOCKD=0
+
 fi
 
 printf "%s\n" "#define DEFAULT_USE_LVMLOCKD $DEFAULT_USE_LVMLOCKD" >>confdefs.h
 
 
 ################################################################################
-if test "$BUILD_LVMPOLLD" = yes; then
+if test "$BUILD_LVMPOLLD" = "yes"
+then :
+
 	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking defaults for use_lvmpolld" >&5
 printf %s "checking defaults for use_lvmpolld... " >&6; }
 	# Check whether --enable-use_lvmpolld was given.
 if test ${enable_use_lvmpolld+y}
 then :
-  enableval=$enable_use_lvmpolld; case ${enableval} in
-		       yes) DEFAULT_USE_LVMPOLLD=1 ;;
-		       *) DEFAULT_USE_LVMPOLLD=0 ;;
-		       esac
+  enableval=$enable_use_lvmpolld; if test "$enableval" = "yes"
+then :
+  DEFAULT_USE_LVMPOLLD=1
+else $as_nop
+  DEFAULT_USE_LVMPOLLD=0
+fi
 else $as_nop
   DEFAULT_USE_LVMPOLLD=1
 fi
@@ -12427,8 +12538,11 @@ fi
 
 printf "%s\n" "#define LVMPOLLD_PIDFILE \"$LVMPOLLD_PIDFILE\"" >>confdefs.h
 
-else
+
+else $as_nop
+
 	DEFAULT_USE_LVMPOLLD=0
+
 fi
 
 printf "%s\n" "#define DEFAULT_USE_LVMPOLLD $DEFAULT_USE_LVMPOLLD" >>confdefs.h
@@ -12442,7 +12556,7 @@ if test ${enable_dmfilemapd+y}
 then :
   enableval=$enable_dmfilemapd; BUILD_DMFILEMAPD=$enableval
 else $as_nop
-  BUILD_DMFILEMAPD=no
+  BUILD_DMFILEMAPD="no"
 fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BUILD_DMFILEMAPD" >&5
@@ -12451,7 +12565,9 @@ printf "%s\n" "$BUILD_DMFILEMAPD" >&6; }
 printf "%s\n" "#define DMFILEMAPD \$BUILD_DMFILEMAPD" >>confdefs.h
 
 
-if test "$BUILD_DMFILEMAPD" = yes; then
+if test "$BUILD_DMFILEMAPD" = "yes"
+then :
+
    ac_fn_c_check_header_compile "$LINENO" "linux/fiemap.h" "ac_cv_header_linux_fiemap_h" "$ac_includes_default"
 if test "x$ac_cv_header_linux_fiemap_h" = xyes
 then :
@@ -12460,10 +12576,10 @@ else $as_nop
   as_fn_error $? "--enable-dmfilemapd requires fiemap.h" "$LINENO" 5
 fi
 
+
 fi
 
 SYSTEMD_MIN_VERSION=0
-pkg_config_init
 if test -n "$PKG_CONFIG" && \
     { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd >= 205\""; } >&5
   ($PKG_CONFIG --exists --print-errors "systemd >= 205") 2>&5
@@ -12487,19 +12603,19 @@ printf %s "checking whether to build notifydbus... " >&6; }
 # Check whether --enable-notify-dbus was given.
 if test ${enable_notify_dbus+y}
 then :
-  enableval=$enable_notify_dbus; if test "$enableval" = yes && test "$SYSTEMD_MIN_VERSION" -lt 221
+  enableval=$enable_notify_dbus; if test "$enableval" = "yes" && test "$SYSTEMD_MIN_VERSION" -lt 221
 then :
   as_fn_error $? "Enabling notify-dbus requires systemd >= 221" "$LINENO" 5
 fi
 	      NOTIFYDBUS_SUPPORT=$enableval
 else $as_nop
-  NOTIFYDBUS_SUPPORT=no
+  NOTIFYDBUS_SUPPORT="no"
 fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $NOTIFYDBUS_SUPPORT" >&5
 printf "%s\n" "$NOTIFYDBUS_SUPPORT" >&6; }
 
-if test "$NOTIFYDBUS_SUPPORT" = yes
+if test "$NOTIFYDBUS_SUPPORT" = "yes"
 then :
 
 printf "%s\n" "#define NOTIFYDBUS_SUPPORT 1" >>confdefs.h
@@ -12509,19 +12625,19 @@ fi
 ################################################################################
 if test "$SYSTEMD_MIN_VERSION" -ge 221
 then :
-  SYSTEMD_JOURNAL_SUPPORT=maybe
+  SYSTEMD_JOURNAL_SUPPORT="maybe"
 else $as_nop
-  SYSTEMD_JOURNAL_SUPPORT=no
+  SYSTEMD_JOURNAL_SUPPORT="no"
 fi
 ac_fn_c_check_header_compile "$LINENO" "systemd/sd-journal.h" "ac_cv_header_systemd_sd_journal_h" "$ac_includes_default"
 if test "x$ac_cv_header_systemd_sd_journal_h" = xyes
 then :
-  if test "$SYSTEMD_JOURNAL_SUPPORT" != no
+  if test "$SYSTEMD_JOURNAL_SUPPORT" != "no"
 then :
-  SYSTEMD_JOURNAL_SUPPORT=yes
+  SYSTEMD_JOURNAL_SUPPORT="yes"
 fi
 else $as_nop
-  SYSTEMD_JOURNAL_SUPPORT=no
+  SYSTEMD_JOURNAL_SUPPORT="no"
 fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to log to systemd journal" >&5
@@ -12529,7 +12645,7 @@ printf %s "checking whether to log to systemd journal... " >&6; }
 # Check whether --enable-systemd-journal was given.
 if test ${enable_systemd_journal+y}
 then :
-  enableval=$enable_systemd_journal; if test "$enableval" = yes && test "$SYSTEMD_JOURNAL_SUPPORT" = no
+  enableval=$enable_systemd_journal; if test "$enableval" = "yes" && test "$SYSTEMD_JOURNAL_SUPPORT" = "no"
 then :
   as_fn_error $? "Enabling systemd journal requires systemd/sd-journal.h and systemd >= 221." "$LINENO" 5
 fi
@@ -12539,7 +12655,7 @@ fi
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $SYSTEMD_JOURNAL_SUPPORT" >&5
 printf "%s\n" "$SYSTEMD_JOURNAL_SUPPORT" >&6; }
 
-if test "$SYSTEMD_JOURNAL_SUPPORT" = yes
+if test "$SYSTEMD_JOURNAL_SUPPORT" = "yes"
 then :
 
 printf "%s\n" "#define SYSTEMD_JOURNAL_SUPPORT 1" >>confdefs.h
@@ -12560,9 +12676,9 @@ fi
 ac_fn_c_check_header_compile "$LINENO" "systemd/sd-id128.h" "ac_cv_header_systemd_sd_id128_h" "$ac_includes_default"
 if test "x$ac_cv_header_systemd_sd_id128_h" = xyes
 then :
-  if test "$APP_MACHINEID_SUPPORT" != no
+  if test "$APP_MACHINEID_SUPPORT" != "no"
 then :
-  APP_MACHINEID_SUPPORT=yes
+  APP_MACHINEID_SUPPORT="yes"
 fi
 else $as_nop
   APP_MACHINEID_SUPPORT=no
@@ -12573,7 +12689,7 @@ printf %s "checking whether to support systemd appmachineid... " >&6; }
 # Check whether --enable-app-machineid was given.
 if test ${enable_app_machineid+y}
 then :
-  enableval=$enable_app_machineid; if test "$enableval" = yes && test "$APP_MACHINEID_SUPPORT" = no
+  enableval=$enable_app_machineid; if test "$enableval" = "yes" && test "$APP_MACHINEID_SUPPORT" = "no"
 then :
   as_fn_error $? "Enabling app machineid requires systemd/sd-id128.h and systemd >= 234." "$LINENO" 5
 fi
@@ -12583,17 +12699,16 @@ fi
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $APP_MACHINEID_SUPPORT" >&5
 printf "%s\n" "$APP_MACHINEID_SUPPORT" >&6; }
 
-if test "$APP_MACHINEID_SUPPORT" = yes
+if test "$APP_MACHINEID_SUPPORT" = "yes"
 then :
 
 printf "%s\n" "#define APP_MACHINEID_SUPPORT 1" >>confdefs.h
 
 fi
 
-if test "$NOTIFYDBUS_SUPPORT" = yes || test "$SYSTEMD_JOURNAL_SUPPORT" = yes || test "$APP_MACHINEID_SUPPORT" = yes
+if test "$NOTIFYDBUS_SUPPORT" = "yes" || test "$SYSTEMD_JOURNAL_SUPPORT" = "yes" || test "$APP_MACHINEID_SUPPORT" = "yes"
 then :
 
-      pkg_config_init
 
 pkg_failed=no
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for SYSTEMD" >&5
@@ -12665,6 +12780,7 @@ else
 printf "%s\n" "yes" >&6; }
 	SYSTEMD_LIBS="-lsystemd"
 fi
+
 fi
 
 ################################################################################
@@ -12674,13 +12790,21 @@ if test ${enable_blkid_wiping+y}
 then :
   enableval=$enable_blkid_wiping; BLKID_WIPING=$enableval
 else $as_nop
-  BLKID_WIPING=maybe
+  BLKID_WIPING="maybe"
 fi
 
 
+# TODO: possibly detect right version of blkid with BLKID_SUBLKS_FSINFO support
+#       so lvresize can check detected flag here
+#
 DEFAULT_USE_BLKID_WIPING=0
-if test "$BLKID_WIPING" != no; then
-	pkg_config_init
+if test "$BLKID_WIPING" != "no"
+then :
+  blkdir_version=">= 2.24"
+else $as_nop
+  blkid_version=""
+fi
+
 
 pkg_failed=no
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for BLKID" >&5
@@ -12690,12 +12814,12 @@ if test -n "$BLKID_CFLAGS"; then
     pkg_cv_BLKID_CFLAGS="$BLKID_CFLAGS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"blkid >= 2.24\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "blkid >= 2.24") 2>&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"blkid \$blkid_version \""; } >&5
+  ($PKG_CONFIG --exists --print-errors "blkid $blkid_version ") 2>&5
   ac_status=$?
   printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  pkg_cv_BLKID_CFLAGS=`$PKG_CONFIG --cflags "blkid >= 2.24" 2>/dev/null`
+  pkg_cv_BLKID_CFLAGS=`$PKG_CONFIG --cflags "blkid $blkid_version " 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
@@ -12707,12 +12831,12 @@ if test -n "$BLKID_LIBS"; then
     pkg_cv_BLKID_LIBS="$BLKID_LIBS"
  elif test -n "$PKG_CONFIG"; then
     if test -n "$PKG_CONFIG" && \
-    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"blkid >= 2.24\""; } >&5
-  ($PKG_CONFIG --exists --print-errors "blkid >= 2.24") 2>&5
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"blkid \$blkid_version \""; } >&5
+  ($PKG_CONFIG --exists --print-errors "blkid $blkid_version ") 2>&5
   ac_status=$?
   printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
   test $ac_status = 0; }; then
-  pkg_cv_BLKID_LIBS=`$PKG_CONFIG --libs "blkid >= 2.24" 2>/dev/null`
+  pkg_cv_BLKID_LIBS=`$PKG_CONFIG --libs "blkid $blkid_version " 2>/dev/null`
 		      test "x$?" != "x0" && pkg_failed=yes
 else
   pkg_failed=yes
@@ -12732,77 +12856,123 @@ if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
 else
         _pkg_short_errors_supported=no
 fi
-        if test $_pkg_short_errors_supported = yes; then
-	        BLKID_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "blkid >= 2.24" 2>&1`
-        else
-	        BLKID_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "blkid >= 2.24" 2>&1`
-        fi
-	# Put the nasty error message in config.log where it belongs
-	echo "$BLKID_PKG_ERRORS" >&5
-
-	if test "$BLKID_WIPING" = maybe; then
-				BLKID_WIPING=no
-			   else
-			        as_fn_error $? "bailing out... blkid library >= 2.24 is required" "$LINENO" 5
-			   fi
-elif test $pkg_failed = untried; then
-     	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
-printf "%s\n" "no" >&6; }
-	if test "$BLKID_WIPING" = maybe; then
-				BLKID_WIPING=no
-			   else
-			        as_fn_error $? "bailing out... blkid library >= 2.24 is required" "$LINENO" 5
-			   fi
-else
-	BLKID_CFLAGS=$pkg_cv_BLKID_CFLAGS
-	BLKID_LIBS=$pkg_cv_BLKID_LIBS
-        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
-printf "%s\n" "yes" >&6; }
-	 BLKID_WIPING=yes
-			    BLKID_PC="blkid"
-			    DEFAULT_USE_BLKID_WIPING=1
+        if test $_pkg_short_errors_supported = yes; then
+	        BLKID_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "blkid $blkid_version " 2>&1`
+        else
+	        BLKID_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "blkid $blkid_version " 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$BLKID_PKG_ERRORS" >&5
+
+	as_fn_error $? "Package requirements (blkid $blkid_version ) were not met:
+
+$BLKID_PKG_ERRORS
+
+Consider adjusting the PKG_CONFIG_PATH environment variable if you
+installed software in a non-standard prefix.
+
+Alternatively, you may set the environment variables BLKID_CFLAGS
+and BLKID_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details." "$LINENO" 5
+elif test $pkg_failed = untried; then
+     	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: no" >&5
+printf "%s\n" "no" >&6; }
+	{ { printf "%s\n" "$as_me:${as_lineno-$LINENO}: error: in \`$ac_pwd':" >&5
+printf "%s\n" "$as_me: error: in \`$ac_pwd':" >&2;}
+as_fn_error $? "The pkg-config script could not be found or is too old.  Make sure it
+is in your PATH or set the PKG_CONFIG environment variable to the full
+path to pkg-config.
+
+Alternatively, you may set the environment variables BLKID_CFLAGS
+and BLKID_LIBS to avoid the need to call pkg-config.
+See the pkg-config man page for more details.
+
+To get pkg-config, see <http://pkg-config.freedesktop.org/>.
+See \`config.log' for more details" "$LINENO" 5; }
+else
+	BLKID_CFLAGS=$pkg_cv_BLKID_CFLAGS
+	BLKID_LIBS=$pkg_cv_BLKID_LIBS
+        { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+printf "%s\n" "yes" >&6; }
+
+	HAVE_BLKID=1
+
+	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for blkdid.h supports SUBLKS_FSINFO." >&5
+printf %s "checking for blkdid.h supports SUBLKS_FSINFO.... " >&6; }
+if test ${ac_cv_have_blkid_sublks_fsinfo+y}
+then :
+  printf %s "(cached) " >&6
+else $as_nop
+  cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+#include <blkid/blkid.h>
+#ifndef BLKID_SUBLKS_FSINFO
+#error BLKID_SUBLKS_FSINFO is missing
+#endif
+int
+main (void)
+{
+
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_compile "$LINENO"
+then :
+  ac_cv_have_blkid_sublks_fsinfo="yes"
+else $as_nop
+  ac_cv_have_blkid_sublks_fsinfo="no"
+fi
+rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
+fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ac_cv_have_blkid_sublks_fsinfo" >&5
+printf "%s\n" "$ac_cv_have_blkid_sublks_fsinfo" >&6; }
 
-printf "%s\n" "#define BLKID_WIPING_SUPPORT 1" >>confdefs.h
+		if test $ac_cv_have_blkid_sublks_fsinfo = yes
+then :
 
+printf "%s\n" "#define HAVE_BLKID_SUBLKS_FSINFO 1" >>confdefs.h
 
 fi
-fi
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to enable libblkid detection of signatures when wiping" >&5
-printf %s "checking whether to enable libblkid detection of signatures when wiping... " >&6; }
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BLKID_WIPING" >&5
-printf "%s\n" "$BLKID_WIPING" >&6; }
 
-printf "%s\n" "#define DEFAULT_USE_BLKID_WIPING $DEFAULT_USE_BLKID_WIPING" >>confdefs.h
+fi
 
+if test "$BLKID_WIPING" != "no"
+then :
 
-################################################################################
-# Check whether --enable-udev-systemd-background-jobs was given.
-if test ${enable_udev_systemd_background_jobs+y}
+	if test "$HAVE_BLKID" = 1
 then :
-  enableval=$enable_udev_systemd_background_jobs; UDEV_SYSTEMD_BACKGROUND_JOBS=$enableval
-else $as_nop
-  UDEV_SYSTEMD_BACKGROUND_JOBS=maybe
-fi
+
+		BLKID_WIPING=yes
+		BLKID_PC="blkid"
+		DEFAULT_USE_BLKID_WIPING=1
+
+printf "%s\n" "#define BLKID_WIPING_SUPPORT 1" >>confdefs.h
 
 
-if test "$UDEV_SYSTEMD_BACKGROUND_JOBS" != no; then
-	if test "$SYSTEMD_MIN_VERSION" -ge 205
-then :
-  UDEV_SYSTEMD_BACKGROUND_JOBS=yes
 else $as_nop
-  if test "$UDEV_SYSTEMD_BACKGROUND_JOBS" = maybe
+
+		if test "$BLKID_WIPING" = "maybe"
 then :
-  UDEV_SYSTEMD_BACKGROUND_JOBS=no
+
+			BLKID_WIPING=no
+
 else $as_nop
-  as_fn_error $? "bailing out... systemd >= 205 is required" "$LINENO" 5
+
+			as_fn_error $? "bailing out... blkid library >= 2.24 is required" "$LINENO" 5
+
 fi
+
 fi
+
 fi
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to enable libblkid detection of signatures when wiping" >&5
+printf %s "checking whether to enable libblkid detection of signatures when wiping... " >&6; }
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BLKID_WIPING" >&5
+printf "%s\n" "$BLKID_WIPING" >&6; }
+
+printf "%s\n" "#define DEFAULT_USE_BLKID_WIPING $DEFAULT_USE_BLKID_WIPING" >>confdefs.h
 
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to use udev-systemd protocol for jobs in background" >&5
-printf %s "checking whether to use udev-systemd protocol for jobs in background... " >&6; }
-{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $UDEV_SYSTEMD_BACKGROUND_JOBS" >&5
-printf "%s\n" "$UDEV_SYSTEMD_BACKGROUND_JOBS" >&6; }
 
 ################################################################################
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to enable synchronisation with udev processing" >&5
@@ -12812,14 +12982,15 @@ if test ${enable_udev_sync+y}
 then :
   enableval=$enable_udev_sync; UDEV_SYNC=$enableval
 else $as_nop
-  UDEV_SYNC=no
+  UDEV_SYNC="no"
 fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $UDEV_SYNC" >&5
 printf "%s\n" "$UDEV_SYNC" >&6; }
 
-if test "$UDEV_SYNC" = yes; then
-	pkg_config_init
+if test "$UDEV_SYNC" = "yes"
+then :
+
 
 pkg_failed=no
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for UDEV" >&5
@@ -12958,6 +13129,7 @@ printf "%s\n" "#define HAVE_LIBUDEV_UDEV_DEVICE_GET_IS_INITIALIZED 1" >>confdefs
 fi
 
 	LIBS=$ac_check_lib_save_LIBS
+
 fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to enable installation of udev rules required for synchronisation" >&5
@@ -12980,23 +13152,34 @@ if test ${enable_udev_rule_exec_detection+y}
 then :
   enableval=$enable_udev_rule_exec_detection; UDEV_RULE_EXEC_DETECTION=$enableval
 else $as_nop
-  UDEV_RULE_EXEC_DETECTION=no
+  UDEV_RULE_EXEC_DETECTION="no"
 fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $UDEV_RULE_EXEC_DETECTION" >&5
 printf "%s\n" "$UDEV_RULE_EXEC_DETECTION" >&6; }
 
-if test "$UDEV_RULE" != no ; then
+if test "$UDEV_RULE" != "no"
+then :
+
+	if test -n "$PKG_CONFIG" && \
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libudev >= 176\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "libudev >= 176") 2>&5
+  ac_status=$?
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+
+		UDEV_HAS_BUILTIN_BLKID="yes"
+
+else
+
+		UDEV_HAS_BUILTIN_BLKID="no"
+
+fi
 	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether udev supports built-in blkid" >&5
 printf %s "checking whether udev supports built-in blkid... " >&6; }
-	pkg_config_init
-	if $("$PKG_CONFIG" --atleast-version=176 libudev); then
-		UDEV_HAS_BUILTIN_BLKID=yes
-	else
-		UDEV_HAS_BUILTIN_BLKID=no
-	fi
 	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $UDEV_HAS_BUILTIN_BLKID" >&5
 printf "%s\n" "$UDEV_HAS_BUILTIN_BLKID" >&6; }
+
 fi
 
 ################################################################################
@@ -13005,14 +13188,17 @@ if test ${enable_units_compat+y}
 then :
   enableval=$enable_units_compat; UNITS_COMPAT=$enableval
 else $as_nop
-  UNITS_COMPAT=no
+  UNITS_COMPAT="no"
 fi
 
 
-if test "$UNITS_COMPAT" = yes; then
+if test "$UNITS_COMPAT" = "yes"
+then :
+
 
 printf "%s\n" "#define DEFAULT_SI_UNIT_CONSISTENCY 0" >>confdefs.h
 
+
 fi
 
 ################################################################################
@@ -13022,7 +13208,7 @@ then :
   enableval=$enable_ioctl; DM_IOCTLS=$enableval
 fi
 
-if test "$DM_IOCTLS" = yes
+if test "$DM_IOCTLS" = "yes"
 then :
 
 printf "%s\n" "#define DM_IOCTLS 1" >>confdefs.h
@@ -13041,10 +13227,13 @@ fi
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $ODIRECT" >&5
 printf "%s\n" "$ODIRECT" >&6; }
 
-if test "$ODIRECT" = yes; then
+if test "$ODIRECT" = "yes"
+then :
+
 
 printf "%s\n" "#define O_DIRECT_SUPPORT 1" >>confdefs.h
 
+
 fi
 
 ################################################################################
@@ -13055,15 +13244,22 @@ if test ${enable_cmdlib+y}
 then :
   enableval=$enable_cmdlib; CMDLIB=$enableval
 else $as_nop
-  CMDLIB=no
+  CMDLIB="no"
 fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $CMDLIB" >&5
 printf "%s\n" "$CMDLIB" >&6; }
 
-test "$CMDLIB" = yes \
-  && LVM2CMD_LIB=-llvm2cmd \
-  || LVM2CMD_LIB=
+if test "$CMDLIB" = "yes"
+then :
+
+	LVM2CMD_LIB="-llvm2cmd"
+
+else $as_nop
+
+	LVM2CMD_LIB=""
+
+fi
 
 ################################################################################
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to include Python D-Bus support" >&5
@@ -13073,12 +13269,12 @@ if test ${enable_dbus_service+y}
 then :
   enableval=$enable_dbus_service; BUILD_LVMDBUSD=$enableval
 else $as_nop
-  BUILD_LVMDBUSD=no
+  BUILD_LVMDBUSD="no"
 fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BUILD_LVMDBUSD" >&5
 printf "%s\n" "$BUILD_LVMDBUSD" >&6; }
-if test "$NOTIFYDBUS_SUPPORT" = yes && test "BUILD_LVMDBUSD" = yes
+if test "$NOTIFYDBUS_SUPPORT" = "yes" && test "BUILD_LVMDBUSD" = "yes"
 then :
   { printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: Building D-Bus support without D-Bus notifications." >&5
 printf "%s\n" "$as_me: WARNING: Building D-Bus support without D-Bus notifications." >&2;}
@@ -13086,7 +13282,9 @@ fi
 
 ################################################################################
 
-if test "$BUILD_LVMDBUSD" = yes; then
+if test "$BUILD_LVMDBUSD" = "yes"
+then :
+
 	unset am_cv_pathless_PYTHON ac_cv_path_PYTHON am_cv_python_platform
 	unset am_cv_python_pythondir am_cv_python_version am_cv_python_pyexecdir
 	unset ac_cv_path_PYTHON_CONFIG ac_cv_path_ac_pt_PYTHON_CONFIG
@@ -13488,7 +13686,12 @@ printf "%s\n" "$am_cv_python_pyexecdir" >&6; }
   fi
 
 	PYTHON3=$PYTHON
-	test -z "$PYTHON3" && as_fn_error $? "python3 is required for --enable-python3_bindings or --enable-dbus-service but cannot be found" "$LINENO" 5
+	if test -z "$PYTHON3"
+then :
+
+		as_fn_error $? "python3 is required for --enable-python3_bindings or --enable-dbus-service but cannot be found" "$LINENO" 5
+
+fi
 	if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}python3-config", so it can be a program name with args.
 set dummy ${ac_tool_prefix}python3-config; ac_word=$2
@@ -13597,11 +13800,21 @@ else
   PYTHON3_CONFIG="$ac_cv_path_PYTHON3_CONFIG"
 fi
 
-	test -z "$PYTHON3_CONFIG" && as_fn_error $? "python3 headers are required for --enable-python3_bindings or --enable-dbus-service but cannot be found" "$LINENO" 5
+	if test -z "$PYTHON3_CONFIG"
+then :
+
+		as_fn_error $? "python3 headers are required for --enable-python3_bindings or --enable-dbus-service but cannot be found" "$LINENO" 5
+
+fi
 	PYTHON3_INCDIRS=`"$PYTHON3_CONFIG" --includes`
 	PYTHON3_LIBDIRS=`"$PYTHON3_CONFIG" --libs`
 	PYTHON3DIR=$pythondir
-	test "$PYTHON3_BINDINGS" = yes && PYTHON_BINDINGS=yes
+	if test "$PYTHON3_BINDINGS" = "yes"
+then :
+
+		PYTHON_BINDINGS="yes"
+
+fi
 
 	# To get this macro, install autoconf-archive package then run autoreconf
 
@@ -13666,6 +13879,7 @@ printf "%s\n" "no" >&6; }
         fi
     fi
 
+
 fi
 
 ################################################################################
@@ -13674,7 +13888,7 @@ if test ${enable_pkgconfig+y}
 then :
   enableval=$enable_pkgconfig; PKGCONFIG=$enableval
 else $as_nop
-  PKGCONFIG=no
+  PKGCONFIG="no"
 fi
 
 
@@ -13684,7 +13898,7 @@ if test ${enable_write_install+y}
 then :
   enableval=$enable_write_install; WRITE_INSTALL=$enableval
 else $as_nop
-  WRITE_INSTALL=no
+  WRITE_INSTALL="no"
 fi
 
 
@@ -13733,23 +13947,32 @@ if test ${enable_dmeventd+y}
 then :
   enableval=$enable_dmeventd; BUILD_DMEVENTD=$enableval
 else $as_nop
-  BUILD_DMEVENTD=no
+  BUILD_DMEVENTD="no"
 fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BUILD_DMEVENTD" >&5
 printf "%s\n" "$BUILD_DMEVENTD" >&6; }
 
-if test "$BUILD_DMEVENTD" = yes; then
-   if test "$MIRRORS" != internal; then
+if test "$BUILD_DMEVENTD" = "yes"
+then :
+
+   if test "$MIRRORS" != "internal"
+then :
+
       as_fn_error $? "--enable-dmeventd currently requires --with-mirrors=internal" "$LINENO" 5
-   fi
-   if test "$CMDLIB" = no; then
+
+fi
+   if test "$CMDLIB" = "no"
+then :
+
       as_fn_error $? "--enable-dmeventd requires --enable-cmdlib to be used as well" "$LINENO" 5
-   fi
+
+fi
 
 
 printf "%s\n" "#define DMEVENTD 1" >>confdefs.h
 
+
 fi
 
 ################################################################################
@@ -13884,17 +14107,19 @@ then :
 printf "%s\n" "#define HAVE_LIBDL 1" >>confdefs.h
 
 	      DL_LIBS="-ldl"
-	      HAVE_LIBDL=yes
+	      HAVE_LIBDL="yes"
 else $as_nop
   DL_LIBS=
-	      HAVE_LIBDL=no
+	      HAVE_LIBDL="no"
 fi
 
 
 ################################################################################
-if [ \( "$LVM1" = shared -o "$POOL" = shared \
-      \) -a "$STATIC_LINK" = yes ]; then
+if ( test "$LVM1" = "shared" || test "$POOL" = "shared" ) && test "$STATIC_LINK" = "yes"
+then :
+
 	as_fn_error $? "Features cannot be 'shared' when building statically" "$LINENO" 5
+
 fi
 
 ################################################################################
@@ -13998,7 +14223,9 @@ fi
 printf "%s\n" "$SELINUX" >&6; }
 
 ################################################################################
-if test "$SELINUX" = yes; then
+if test "$SELINUX" = "yes"
+then :
+
 	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for sepol_check_context in -lsepol" >&5
 printf %s "checking for sepol_check_context in -lsepol... " >&6; }
 if test ${ac_cv_lib_sepol_sepol_check_context+y}
@@ -14116,6 +14343,7 @@ printf "%s\n" "$as_me: WARNING: Disabling selinux" >&2;}
 		HAVE_SELINUX=no
 fi
 
+
 fi
 
 ################################################################################
@@ -14142,9 +14370,9 @@ main (void)
 _ACEOF
 if ac_fn_c_try_compile "$LINENO"
 then :
-  ac_cv_have_blkzeroout=yes
+  ac_cv_have_blkzeroout="yes"
 else $as_nop
-  ac_cv_have_blkzeroout=no
+  ac_cv_have_blkzeroout="no"
 fi
 rm -f core conftest.err conftest.$ac_objext conftest.beam conftest.$ac_ext
 fi
@@ -14157,21 +14385,24 @@ if test ${enable_blkzeroout+y}
 then :
   enableval=$enable_blkzeroout; BLKZEROOUT=$enableval
 else $as_nop
-  BLKZEROOUT=yes
+  BLKZEROOUT="yes"
 fi
 
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to use BLKZEROOUT for device zeroing" >&5
 printf %s "checking whether to use BLKZEROOUT for device zeroing... " >&6; }
-if test "$BLKZEROOUT" = yes; then
+if test "$BLKZEROOUT" = "yes"
+then :
+
 	if test $ac_cv_have_blkzeroout = yes
 then :
 
 printf "%s\n" "#define HAVE_BLKZEROOUT 1" >>confdefs.h
 
 else $as_nop
-  BLKZEROOUT=no
+  BLKZEROOUT="no"
 fi
+
 fi
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $BLKZEROOUT" >&5
 printf "%s\n" "$BLKZEROOUT" >&6; }
@@ -14180,7 +14411,9 @@ printf "%s\n" "$BLKZEROOUT" >&6; }
 ################################################################################
 RT_LIBS=
 HAVE_REALTIME=no
-if test "$REALTIME" = yes; then
+if test "$REALTIME" = "yes"
+then :
+
 
   for ac_func in clock_gettime
 do :
@@ -14193,7 +14426,7 @@ fi
 
 done
 
-	if test "$HAVE_REALTIME" != yes
+	if test "$HAVE_REALTIME" != "yes"
 then :
    # try again with -lrt
 	      { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for clock_gettime in -lrt" >&5
@@ -14238,14 +14471,20 @@ fi
 
 fi
 
-	if test "$HAVE_REALTIME" = yes; then
+	if test "$HAVE_REALTIME" = "yes"
+then :
+
 
 printf "%s\n" "#define HAVE_REALTIME 1" >>confdefs.h
 
-	else
+
+else $as_nop
+
 		{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: Disabling realtime clock" >&5
 printf "%s\n" "$as_me: WARNING: Disabling realtime clock" >&2;}
-	fi
+
+fi
+
 fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for struct stat has st_ctim." >&5
@@ -14300,7 +14539,9 @@ fi
 done
 
 ################################################################################
-if test "$EDITLINE" == yes; then
+if test "$EDITLINE" = "yes"
+then :
+
 
 pkg_failed=no
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for EDITLINE" >&5
@@ -14377,10 +14618,13 @@ printf "%s\n" "yes" >&6; }
 printf "%s\n" "#define EDITLINE_SUPPORT 1" >>confdefs.h
 
 fi
+
 fi
 
 ################################################################################
-if test "$READLINE" != no; then
+if test "$READLINE" != "no"
+then :
+
 	lvm_saved_libs=$LIBS
 	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for library containing tgetent" >&5
 printf %s "checking for library containing tgetent... " >&6; }
@@ -14441,7 +14685,9 @@ then :
   READLINE_LIBS=$ac_cv_search_tgetent
 else $as_nop
 
-		if test "$READLINE" = yes; then
+		if test "$READLINE" = "yes"
+then :
+
 			as_fn_error $? "termcap could not be found which is required for the
 --enable-readline option (which is enabled by default).  Either disable readline
 support with --disable-readline or download and install termcap from:
@@ -14450,7 +14696,9 @@ Note: if you are using precompiled packages you will also need the development
   package as well (which may be called termcap-devel or something similar).
 Note: (n)curses also seems to work as a substitute for termcap.  This was
   not found either - but you could try installing that as well." "$LINENO" 5
-		fi
+
+fi
+
 fi
 
 		{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for readline in -lreadline" >&5
@@ -14545,14 +14793,18 @@ fi
 else $as_nop
 
 		READLINE_LIBS=
-		if test "$READLINE" = yes; then
+		if test "$READLINE" = "yes"
+then :
+
 			as_fn_error $? "GNU Readline could not be found which is required for the
 --enable-readline option (which is enabled by default).  Either disable readline
 support with --disable-readline or download and install readline from:
 	ftp.gnu.org/gnu/readline
 Note: if you are using precompiled packages you will also need the development
 package as well (which may be called readline-devel or something similar)." "$LINENO" 5
-		fi
+
+fi
+
 fi
 
 	LIBS="$READLINE_LIBS $lvm_saved_libs"
@@ -14564,6 +14816,7 @@ then :
 fi
 
 	LIBS=$lvm_saved_libs
+
 fi
 
 ################################################################################
@@ -14574,13 +14827,15 @@ if test ${enable_nls+y}
 then :
   enableval=$enable_nls; INTL=$enableval
 else $as_nop
-  INTL=no
+  INTL="no"
 fi
 
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $INTL" >&5
 printf "%s\n" "$INTL" >&6; }
 
-if test "$INTL" = yes; then
+if test "$INTL" = "yes"
+then :
+
 # FIXME - Move this - can be device-mapper too
 	INTL_PACKAGE="lvm2"
 	if test -n "$ac_tool_prefix"; then
@@ -14713,6 +14968,7 @@ printf "%s\n" "#define INTL_PACKAGE \"$INTL_PACKAGE\"" >>confdefs.h
 
 printf "%s\n" "#define LOCALEDIR \"$(eval echo $(eval echo $localedir))\"" >>confdefs.h
 
+
 fi
 
 ################################################################################
@@ -14795,18 +15051,72 @@ fi
 # Check whether --with-systemdsystemunitdir was given.
 if test ${with_systemdsystemunitdir+y}
 then :
-  withval=$with_systemdsystemunitdir; systemdsystemunitdir=$withval
+  withval=$with_systemdsystemunitdir;
+fi
+
+
+if test -z "$with_systemdsystemunitdir"
+then :
+
+
+if test -n "$systemdsystemunitdir"; then
+    pkg_cv_systemdsystemunitdir="$systemdsystemunitdir"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "systemd") 2>&5
+  ac_status=$?
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_systemdsystemunitdir=`$PKG_CONFIG --variable="systemdsystemunitdir" "systemd" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+systemdsystemunitdir=$pkg_cv_systemdsystemunitdir
+
+if test "x$systemdsystemunitdir" = x""
+then :
+
+		systemdsystemunitdir='${exec_prefix}/lib/systemd/system'
+
+fi
+
 else $as_nop
-  pkg_config_init
-	    pkg_systemdsystemunitdir=$("$PKG_CONFIG" --variable=systemdsystemunitdir systemd)
+
+	systemdsystemunitdir="$with_systemdsystemunitdir"
+
+fi
+
+
+if test -n "$systemdutildir"; then
+    pkg_cv_systemdutildir="$systemdutildir"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"systemd\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "systemd") 2>&5
+  ac_status=$?
+  printf "%s\n" "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_systemdutildir=`$PKG_CONFIG --variable="systemdutildir" "systemd" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
+else
+  pkg_failed=yes
 fi
+ else
+    pkg_failed=untried
+fi
+systemdutildir=$pkg_cv_systemdutildir
 
+if test "x$systemdutildir" = x""
+then :
 
-test -n "$pkg_systemdsystemunitdir" && systemdsystemunitdir=$pkg_systemdsystemunitdir
-test -z "$systemdsystemunitdir" && systemdsystemunitdir='${exec_prefix}/lib/systemd/system';
+	systemdutildir='${exec_prefix}/lib/systemd'
 
-systemdutildir=$("$PKG_CONFIG" --variable=systemdutildir systemd)
-test -z "$systemdutildir" && systemdutildir='${exec_prefix}/lib/systemd';
+fi
 
 ################################################################################
 
@@ -14819,7 +15129,9 @@ else $as_nop
 fi
 
 ################################################################################
-if test "$READLINE" = yes; then
+if test "$READLINE" = "yes"
+then :
+
 	       for ac_header in readline/readline.h readline/history.h
 do :
   as_ac_Header=`printf "%s\n" "ac_cv_header_$ac_header" | $as_tr_sh`
@@ -14835,13 +15147,16 @@ else $as_nop
 fi
 
 done
+
 fi
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to enable readline" >&5
 printf %s "checking whether to enable readline... " >&6; }
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $READLINE" >&5
 printf "%s\n" "$READLINE" >&6; }
 
-if test "$EDITLINE" = yes; then
+if test "$EDITLINE" = "yes"
+then :
+
 	       for ac_header in editline/readline.h
 do :
   ac_fn_c_check_header_compile "$LINENO" "editline/readline.h" "ac_cv_header_editline_readline_h" "$ac_includes_default"
@@ -14854,13 +15169,16 @@ else $as_nop
 fi
 
 done
+
 fi
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking whether to enable editline" >&5
 printf %s "checking whether to enable editline... " >&6; }
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $EDITLINE" >&5
 printf "%s\n" "$EDITLINE" >&6; }
 
-if test "$BUILD_CMIRRORD" = yes; then
+if test "$BUILD_CMIRRORD" = "yes"
+then :
+
 
   for ac_func in atexit
 do :
@@ -14874,12 +15192,16 @@ else $as_nop
 fi
 
 done
+
 fi
 
-if test "$BUILD_LVMLOCKD" = yes; then
-	if test "$HAVE_REALTIME" != yes
+if test "$BUILD_LVMLOCKD" = "yes"
+then :
+
+	if test "$HAVE_REALTIME" != "yes"
 then :
-  as_fn_error $? "Realtime clock support is mandatory for lvmlockd." "$LINENO" 5
+
+		as_fn_error $? "Realtime clock support is mandatory for lvmlockd." "$LINENO" 5
 fi
 
   for ac_func in strtoull
@@ -14894,23 +15216,10 @@ else $as_nop
 fi
 
 done
-fi
-
-if test "$BUILD_LVMPOLLD" = yes; then
-
-  for ac_func in strpbrk
-do :
-  ac_fn_c_check_func "$LINENO" "strpbrk" "ac_cv_func_strpbrk"
-if test "x$ac_cv_func_strpbrk" = xyes
-then :
-  printf "%s\n" "#define HAVE_STRPBRK 1" >>confdefs.h
 
-else $as_nop
-  hard_bailout
 fi
 
-done
-	{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $CC options needed to detect all undeclared functions" >&5
+{ printf "%s\n" "$as_me:${as_lineno-$LINENO}: checking for $CC options needed to detect all undeclared functions" >&5
 printf %s "checking for $CC options needed to detect all undeclared functions... " >&6; }
 if test ${ac_cv_c_undeclared_builtin_options+y}
 then :
@@ -14999,6 +15308,22 @@ else $as_nop
 fi
 printf "%s\n" "#define HAVE_DECL_STRERROR_R $ac_have_decl" >>confdefs.h
 
+if test "$BUILD_LVMPOLLD" = "yes"
+then :
+
+
+  for ac_func in strpbrk
+do :
+  ac_fn_c_check_func "$LINENO" "strpbrk" "ac_cv_func_strpbrk"
+if test "x$ac_cv_func_strpbrk" = xyes
+then :
+  printf "%s\n" "#define HAVE_STRPBRK 1" >>confdefs.h
+
+else $as_nop
+  hard_bailout
+fi
+
+done
 
 if test $ac_cv_have_decl_strerror_r = yes; then
   # For backward compatibility's sake, define HAVE_STRERROR_R.
@@ -15051,9 +15376,12 @@ printf "%s\n" "#define STRERROR_R_CHAR_P 1" >>confdefs.h
 
 fi
 
+
 fi
 
-if test "$BUILD_DMEVENTD" = yes; then
+if test "$BUILD_DMEVENTD" = "yes"
+then :
+
 	       for ac_header in arpa/inet.h
 do :
   ac_fn_c_check_header_compile "$LINENO" "arpa/inet.h" "ac_cv_header_arpa_inet_h" "$ac_includes_default"
@@ -15066,9 +15394,12 @@ else $as_nop
 fi
 
 done
+
 fi
 
-if test "$HAVE_LIBDL" = yes; then
+if test "$HAVE_LIBDL" = "yes"
+then :
+
 	       for ac_header in dlfcn.h
 do :
   ac_fn_c_check_header_compile "$LINENO" "dlfcn.h" "ac_cv_header_dlfcn_h" "$ac_includes_default"
@@ -15081,9 +15412,12 @@ else $as_nop
 fi
 
 done
+
 fi
 
-if test "$INTL" = yes; then
+if test "$INTL" = "yes"
+then :
+
 	       for ac_header in libintl.h
 do :
   ac_fn_c_check_header_compile "$LINENO" "libintl.h" "ac_cv_header_libintl_h" "$ac_includes_default"
@@ -15096,9 +15430,12 @@ else $as_nop
 fi
 
 done
+
 fi
 
-if test "$UDEV_SYNC" = yes; then
+if test "$UDEV_SYNC" = "yes"
+then :
+
 	       for ac_header in sys/ipc.h sys/sem.h
 do :
   as_ac_Header=`printf "%s\n" "ac_cv_header_$ac_header" | $as_tr_sh`
@@ -15114,9 +15451,12 @@ else $as_nop
 fi
 
 done
+
 fi
 
-if test "$BUILD_DMFILEMAPD" = yes; then
+if test "$BUILD_DMFILEMAPD" = "yes"
+then :
+
 	       for ac_header in sys/inotify.h
 do :
   ac_fn_c_check_header_compile "$LINENO" "sys/inotify.h" "ac_cv_header_sys_inotify_h" "$ac_includes_default"
@@ -15129,6 +15469,7 @@ else $as_nop
 fi
 
 done
+
 fi
 
 ################################################################################
@@ -15241,10 +15582,13 @@ else
 fi
 
 
-if test -n "$MODPROBE_CMD"; then
+if test -n "$MODPROBE_CMD"
+then :
+
 
 printf "%s\n" "#define MODPROBE_CMD \"$MODPROBE_CMD\"" >>confdefs.h
 
+
 fi
 
 SYSCONFDIR="$(eval echo $(eval echo $sysconfdir))"
@@ -15280,7 +15624,9 @@ printf "%s\n" "#define LVRESIZE_FS_HELPER_PATH \"$LVRESIZE_FS_HELPER_PATH\"" >>c
 
 
 ################################################################################
-if test "$BUILD_DMEVENTD" = yes; then
+if test "$BUILD_DMEVENTD" = "yes"
+then :
+
 
 # Check whether --with-dmeventd-pidfile was given.
 if test ${with_dmeventd_pidfile+y}
@@ -15293,9 +15639,12 @@ fi
 
 printf "%s\n" "#define DMEVENTD_PIDFILE \"$DMEVENTD_PIDFILE\"" >>confdefs.h
 
+
 fi
 
-if test "$BUILD_DMEVENTD" = yes; then
+if test "$BUILD_DMEVENTD" = "yes"
+then :
+
 
 # Check whether --with-dmeventd-path was given.
 if test ${with_dmeventd_path+y}
@@ -15308,6 +15657,7 @@ fi
 
 printf "%s\n" "#define DMEVENTD_PATH \"$DMEVENTD_PATH\"" >>confdefs.h
 
+
 fi
 
 ################################################################################
@@ -15330,7 +15680,7 @@ if test ${with_default_profile_subdir+y}
 then :
   withval=$with_default_profile_subdir; DEFAULT_PROFILE_SUBDIR=$withval
 else $as_nop
-  DEFAULT_PROFILE_SUBDIR=profile
+  DEFAULT_PROFILE_SUBDIR="profile"
 fi
 
 
@@ -15343,7 +15693,7 @@ if test ${with_default_archive_subdir+y}
 then :
   withval=$with_default_archive_subdir; DEFAULT_ARCHIVE_SUBDIR=$withval
 else $as_nop
-  DEFAULT_ARCHIVE_SUBDIR=archive
+  DEFAULT_ARCHIVE_SUBDIR="archive"
 fi
 
 
@@ -15356,7 +15706,7 @@ if test ${with_default_backup_subdir+y}
 then :
   withval=$with_default_backup_subdir; DEFAULT_BACKUP_SUBDIR=$withval
 else $as_nop
-  DEFAULT_BACKUP_SUBDIR=backup
+  DEFAULT_BACKUP_SUBDIR="backup"
 fi
 
 
@@ -15369,7 +15719,7 @@ if test ${with_default_cache_subdir+y}
 then :
   withval=$with_default_cache_subdir; DEFAULT_CACHE_SUBDIR=$withval
 else $as_nop
-  DEFAULT_CACHE_SUBDIR=cache
+  DEFAULT_CACHE_SUBDIR="cache"
 fi
 
 
@@ -15407,32 +15757,32 @@ if test ${with_interface+y}
 then :
   withval=$with_interface; interface=$withval
 else $as_nop
-  interface=ioctl
+  interface="ioctl"
 fi
 
-test "$interface" != ioctl && as_fn_error $? "--with-interface=ioctl required. fs no longer supported." "$LINENO" 5
+test "$interface" != "ioctl" && as_fn_error $? "--with-interface=ioctl required. fs no longer supported." "$LINENO" 5
 { printf "%s\n" "$as_me:${as_lineno-$LINENO}: result: $interface" >&5
 printf "%s\n" "$interface" >&6; }
 
 ################################################################################
-read DM_LIB_VERSION < "$srcdir"/VERSION_DM 2>/dev/null || DM_LIB_VERSION=Unknown
+read DM_LIB_VERSION < "$srcdir"/VERSION_DM 2>/dev/null || DM_LIB_VERSION="Unknown"
 
 printf "%s\n" "#define DM_LIB_VERSION \"$DM_LIB_VERSION\"" >>confdefs.h
 
 
-DM_LIB_PATCHLEVEL=`cat "$srcdir"/VERSION_DM | $AWK -F '[-. ]' '{printf "%s.%s.%s",$1,$2,$3}'`
+DM_LIB_PATCHLEVEL=$(cat "$srcdir"/VERSION_DM | $AWK -F '[-. ]' '{printf "%s.%s.%s",$1,$2,$3}')
 
 read VER < "$srcdir"/VERSION 2>/dev/null || VER=Unknown
 
 LVM_VERSION=\"$VER\"
-LVM_RELEASE_DATE="\"`echo $VER | $SED 's/.* (//;s/).*//'`\""
-VER=`echo "$VER" | $AWK '{print $1}'`
-LVM_RELEASE="\"`echo "$VER" | $AWK -F '-' '{print $2}'`\""
-VER=`echo "$VER" | $AWK -F '-' '{print $1}'`
-LVM_MAJOR=`echo "$VER" | $AWK -F '.' '{print $1}'`
-LVM_MINOR=`echo "$VER" | $AWK -F '.' '{print $2}'`
-LVM_PATCHLEVEL=`echo "$VER" | $AWK -F '[(.]' '{print $3}'`
-LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
+LVM_RELEASE_DATE="\"$(echo $VER | $SED 's/.* (//;s/).*//')\""
+VER=$(echo "$VER" | $AWK '{print $1}')
+LVM_RELEASE="\"$(echo "$VER" | $AWK -F '-' '{print $2}')\""
+VER=$(echo "$VER" | $AWK -F '-' '{print $1}')
+LVM_MAJOR=$(echo "$VER" | $AWK -F '.' '{print $1}')
+LVM_MINOR=$(echo "$VER" | $AWK -F '.' '{print $2}')
+LVM_PATCHLEVEL=$(echo "$VER" | $AWK -F '[(.]' '{print $3}')
+LVM_LIBAPI=$(echo "$VER" | $AWK -F '[()]' '{print $2}')
 
 
 printf "%s\n" "#define LVM_CONFIGURE_LINE \"$CONFIGURE_LINE\"" >>confdefs.h
@@ -15601,6 +15951,8 @@ printf "%s\n" "#define LVM_CONFIGURE_LINE \"$CONFIGURE_LINE\"" >>confdefs.h
 
 
 
+
+
 
 
 
@@ -16984,7 +17336,7 @@ then :
 printf "%s\n" "$as_me: WARNING: Only libdm part can be build without libaio:  make [install_]device-mapper" >&2;}
 fi
 
-if test "$ODIRECT" != yes
+if test "$ODIRECT" != "yes"
 then :
   { printf "%s\n" "$as_me:${as_lineno-$LINENO}: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&5
 printf "%s\n" "$as_me: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&2;}

