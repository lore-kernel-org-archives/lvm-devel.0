From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Feb 2023 16:53:21 +0000 (GMT)
Subject: main - configure.ac: only use `AS_CASE` for conditional blocks
Message-ID: <20230210165321.498803858C5F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cf204ce55ea892ffaa4ff63dac548145544679fb
Commit:        cf204ce55ea892ffaa4ff63dac548145544679fb
Parent:        583cb699cfc76237c5daf1165f599af05c4295dd
Author:        David Seifert <soap@gentoo.org>
AuthorDate:    Sun Nov 27 15:35:07 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 10 17:50:27 2023 +0100

configure.ac: only use `AS_CASE` for conditional blocks

Like `AS_IF([...])`, `AS_CASE` bubbles nested `AC_REQUIRE()` to the
top-level.
---
 configure.ac | 213 +++++++++++++++++++++++++----------------------------------
 1 file changed, 91 insertions(+), 122 deletions(-)

diff --git a/configure.ac b/configure.ac
index b29e676bb..4ddf0a430 100644
--- a/configure.ac
+++ b/configure.ac
@@ -28,8 +28,8 @@ dnl -- Get system type
 AC_CANONICAL_TARGET([])
 
 AS_IF([test -z "$CFLAGS"], [COPTIMISE_FLAG="-O2"])
-case "$host_os" in
-	linux*)
+AS_CASE(["$host_os"],
+	[linux*], [
 		# equivalent to -rdynamic
 		ELDFLAGS="-Wl,--export-dynamic"
 		# FIXME Generate list and use --dynamic-list=.dlopen.sym
@@ -43,9 +43,8 @@ case "$host_os" in
 		SELINUX=yes
 		FSADM=yes
 		LVMIMPORTVDO=yes
-		BLKDEACTIVATE=yes
-		;;
-	darwin*)
+		BLKDEACTIVATE=yes],
+	[darwin*], [
 		CFLAGS="$CFLAGS -no-cpp-precomp -fno-common"
 		ELDFLAGS=
 		CLDWHOLEARCHIVE="-all_load"
@@ -57,12 +56,8 @@ case "$host_os" in
 		SELINUX=no
 		FSADM=no
 		LVMIMPORTVDO=no
-		BLKDEACTIVATE=no
-		;;
-	*)
-		CLDFLAGS="${CLDFLAGS-"$LDFLAGS"}"
-		;;
-esac
+		BLKDEACTIVATE=no],
+	[CLDFLAGS="${CLDFLAGS-"$LDFLAGS"}"])
 
 ################################################################################
 dnl -- Checks for programs.
@@ -106,12 +101,9 @@ AC_CHECK_HEADERS([assert.h ctype.h dirent.h errno.h fcntl.h float.h \
 
 AC_CHECK_HEADERS(termios.h sys/statvfs.h sys/timerfd.h sys/vfs.h linux/magic.h linux/fiemap.h)
 AC_CHECK_HEADERS(libaio.h,LVM_NEEDS_LIBAIO_WARN=,LVM_NEEDS_LIBAIO_WARN=y)
-case "$host_os" in
-	linux*)
-		AC_CHECK_HEADERS(asm/byteorder.h linux/fs.h malloc.h,,AC_MSG_ERROR(bailing out)) ;;
-	darwin*)
-		AC_CHECK_HEADERS(machine/endian.h sys/disk.h,,AC_MSG_ERROR(bailing out)) ;;
-esac
+AS_CASE(["$host_os"],
+	[linux*], [AC_CHECK_HEADERS([asm/byteorder.h linux/fs.h malloc.h], [], [AC_MSG_ERROR(bailing out)])],
+	[darwin*], [AC_CHECK_HEADERS([machine/endian.h sys/disk.h], [], [AC_MSG_ERROR(bailing out)])])
 
 ################################################################################
 dnl -- Check for typedefs, structures, and compiler characteristics.
@@ -270,11 +262,10 @@ AC_ARG_WITH(device-nodes-on,
 	    AS_HELP_STRING([--with-device-nodes-on=ON],
 			   [create nodes on resume or create [ON=resume]]),
 	    ADD_NODE=$withval, ADD_NODE=resume)
-case "$ADD_NODE" in
- resume) add_on=DM_ADD_NODE_ON_RESUME;;
- create) add_on=DM_ADD_NODE_ON_CREATE;;
- *) AC_MSG_ERROR([--with-device-nodes-on parameter invalid]);;
-esac
+AS_CASE(["$ADD_NODE"],
+	[resume], [add_on=DM_ADD_NODE_ON_RESUME],
+	[create], [add_on=DM_ADD_NODE_ON_CREATE],
+	[AC_MSG_ERROR([--with-device-nodes-on parameter invalid])])
 AC_MSG_RESULT(on $ADD_NODE)
 AC_DEFINE_UNQUOTED([DEFAULT_DM_ADD_NODE], $add_on, [Define default node creation behavior with dmsetup create])
 
@@ -284,10 +275,9 @@ AC_MSG_CHECKING(default for use_devicesfile)
 AC_ARG_WITH(default-use-devices-file,
 	      AS_HELP_STRING([--with-default-use-devices-file], [default for lvm.conf devices/use_devicesfile = [0]]),
 	      DEFAULT_USE_DEVICES_FILE=$withval, DEFAULT_USE_DEVICES_FILE=0)
-case "$DEFAULT_USE_DEVICES_FILE" in
- 0|1);;
- *) AC_MSG_ERROR([--with-default-use-devices-file parameter invalid]);;
-esac
+AS_CASE(["$DEFAULT_USE_DEVICES_FILE"],
+	[0|1], [],
+	[AC_MSG_ERROR([--with-default-use-devices-file parameter invalid])])
 AC_MSG_RESULT($DEFAULT_USE_DEVICES_FILE)
 AC_DEFINE_UNQUOTED(DEFAULT_USE_DEVICES_FILE, [$DEFAULT_USE_DEVICES_FILE],
 		   [Default for lvm.conf use_devicesfile.])
@@ -297,12 +287,11 @@ AC_ARG_WITH(default-name-mangling,
 	    AS_HELP_STRING([--with-default-name-mangling=MANGLING],
 			   [default name mangling: auto/none/hex [auto]]),
 	    MANGLING=$withval, MANGLING=auto)
-case "$MANGLING" in
- auto) mangling=DM_STRING_MANGLING_AUTO;;
- no|none|disabled) mangling=DM_STRING_MANGLING_NONE;;
- hex) mangling=DM_STRING_MANGLING_HEX;;
- *) AC_MSG_ERROR([--with-default-name-mangling parameter invalid]);;
-esac
+AS_CASE(["$MANGLING"],
+	[auto], [mangling=DM_STRING_MANGLING_AUTO],
+	[no|none|disabled], [mangling=DM_STRING_MANGLING_NONE],
+	[hex], [mangling=DM_STRING_MANGLING_HEX],
+	[AC_MSG_ERROR([--with-default-name-mangling parameter invalid])])
 AC_MSG_RESULT($MANGLING)
 AC_DEFINE_UNQUOTED([DEFAULT_DM_NAME_MANGLING], $mangling, [Define default name mangling behaviour])
 
@@ -315,12 +304,11 @@ AC_ARG_WITH(snapshots,
 	    SNAPSHOTS=$withval, SNAPSHOTS=internal)
 AC_MSG_RESULT($SNAPSHOTS)
 
-case "$SNAPSHOTS" in
-  no|none|shared) ;;
-  internal) AC_DEFINE([SNAPSHOT_INTERNAL], 1,
-		      [Define to 1 to include built-in support for snapshots.]) ;;
-  *) AC_MSG_ERROR([--with-snapshots parameter invalid]) ;;
-esac
+AS_CASE(["$SNAPSHOTS"],
+	[no|none|shared], [],
+	[internal], [
+		AC_DEFINE([SNAPSHOT_INTERNAL], 1, [Define to 1 to include built-in support for snapshots.])],
+	[AC_MSG_ERROR([--with-snapshots parameter invalid])])
 
 ################################################################################
 dnl -- mirrors inclusion type
@@ -331,12 +319,11 @@ AC_ARG_WITH(mirrors,
 	    MIRRORS=$withval, MIRRORS=internal)
 AC_MSG_RESULT($MIRRORS)
 
-case "$MIRRORS" in
-  no|none|shared) ;;
-  internal) AC_DEFINE([MIRRORED_INTERNAL], 1,
-		      [Define to 1 to include built-in support for mirrors.]) ;;
-  *) AC_MSG_ERROR([--with-mirrors parameter invalid]) ;;
-esac
+AS_CASE(["$MIRRORS"],
+	[no|none|shared], [],
+	[internal], [
+		AC_DEFINE([MIRRORED_INTERNAL], 1, [Define to 1 to include built-in support for mirrors.])],
+	[AC_MSG_ERROR([--with-mirrors parameter invalid])])
 
 ################################################################################
 dnl -- raid inclusion type
@@ -360,12 +347,11 @@ AC_DEFINE_UNQUOTED([DEFAULT_RAID10_SEGTYPE], ["$DEFAULT_RAID10_SEGTYPE"],
 
 ################################################################################
 AC_ARG_WITH(default-sparse-segtype,
-	    AS_HELP_STRING([--with-default-sparse-segtype=TYPE],
-			   [default sparse segtype: thin/snapshot [thin]]),
-			   [ case "$withval" in
-				thin|snapshot) DEFAULT_SPARSE_SEGTYPE=$withval ;;
-				*) AC_MSG_ERROR(--with-default-sparse-segtype parameter invalid) ;;
-			     esac], DEFAULT_SPARSE_SEGTYPE="thin")
+	AS_HELP_STRING([--with-default-sparse-segtype=TYPE], [default sparse segtype: thin/snapshot [thin]]), [
+		AS_CASE(["$withval"],
+			[thin|snapshot], [DEFAULT_SPARSE_SEGTYPE=$withval],
+			[AC_MSG_ERROR([--with-default-sparse-segtype parameter invalid])])
+		], [DEFAULT_SPARSE_SEGTYPE="thin"])
 
 ################################################################################
 dnl -- thin provisioning
@@ -393,13 +379,12 @@ AC_ARG_WITH(thin-restore,
 
 AC_MSG_RESULT($THIN)
 
-case "$THIN" in
-  no|none)  test "$DEFAULT_SPARSE_SEGTYPE" = "thin" && DEFAULT_SPARSE_SEGTYPE="snapshot" ;;
-  shared) ;;
-  internal) AC_DEFINE([THIN_INTERNAL], 1,
-		      [Define to 1 to include built-in support for thin provisioning.]) ;;
-  *) AC_MSG_ERROR([--with-thin parameter invalid ($THIN)]) ;;
-esac
+AS_CASE(["$THIN"],
+	[no|none], [test "$DEFAULT_SPARSE_SEGTYPE" = "thin" && DEFAULT_SPARSE_SEGTYPE="snapshot"],
+	[shared], [],
+	[internal], [
+		AC_DEFINE([THIN_INTERNAL], 1, [Define to 1 to include built-in support for thin provisioning.])],
+	[AC_MSG_ERROR([--with-thin parameter invalid ($THIN)])])
 
 AC_DEFINE_UNQUOTED([DEFAULT_SPARSE_SEGTYPE], ["$DEFAULT_SPARSE_SEGTYPE"],
 		   [Default segtype used for sparse volumes.])
@@ -412,8 +397,8 @@ AC_ARG_ENABLE(thin_check_needs_check,
 
 # Test if necessary thin tools are available
 # if not - use plain defaults and warn user
-case "$THIN" in
-  internal|shared)
+AS_CASE(["$THIN"],
+	[internal|shared], [
 	# Empty means a config way to ignore thin checking
 	AS_IF([test "$THIN_CHECK_CMD" = "autodetect"], [
 		AC_PATH_TOOL(THIN_CHECK_CMD, thin_check, [], [$PATH_SBIN])
@@ -471,8 +456,7 @@ case "$THIN" in
 	AS_IF([test "$THIN_CHECK_NEEDS_CHECK" = "yes"], [
 		AC_DEFINE([THIN_CHECK_NEEDS_CHECK], 1, [Define to 1 if the external 'thin_check' tool requires the --clear-needs-check-flag option])
 	])
-	;;
-esac
+])
 
 AC_DEFINE_UNQUOTED([THIN_CHECK_CMD], ["$THIN_CHECK_CMD"],
 		   [The path to 'thin_check', if available.])
@@ -511,11 +495,11 @@ AC_ARG_WITH(cache-restore,
 			   CACHE_RESTORE_CMD=$withval, CACHE_RESTORE_CMD="autodetect")
 AC_MSG_RESULT($CACHE)
 
-case "$CACHE" in
- no|none|shared) ;;
- internal) AC_DEFINE([CACHE_INTERNAL], 1, [Define to 1 to include built-in support for cache.]) ;;
- *) AC_MSG_ERROR([--with-cache parameter invalid]) ;;
-esac
+AS_CASE(["$CACHE"],
+	[no|none|shared], [],
+	[internal], [
+		AC_DEFINE([CACHE_INTERNAL], 1, [Define to 1 to include built-in support for cache.])],
+	[AC_MSG_ERROR([--with-cache parameter invalid])])
 
 dnl -- cache_check needs-check flag
 AC_ARG_ENABLE(cache_check_needs_check,
@@ -525,8 +509,8 @@ AC_ARG_ENABLE(cache_check_needs_check,
 
 # Test if necessary cache tools are available
 # if not - use plain defaults and warn user
-case "$CACHE" in
-  internal|shared)
+AS_CASE(["$CACHE"],
+	[internal|shared], [
 	# Empty means a config way to ignore cache checking
 	AS_IF([test "$CACHE_CHECK_CMD" = "autodetect"], [
 		AC_PATH_TOOL(CACHE_CHECK_CMD, cache_check, [], [$PATH_SBIN])
@@ -595,8 +579,7 @@ case "$CACHE" in
 	AS_IF([test "$CACHE_CHECK_NEEDS_CHECK" = "yes"], [
 		AC_DEFINE([CACHE_CHECK_NEEDS_CHECK], 1, [Define to 1 if the external 'cache_check' tool requires the --clear-needs-check-flag option])
 	])
-	;;
-esac
+])
 
 AC_DEFINE_UNQUOTED([CACHE_CHECK_CMD], ["$CACHE_CHECK_CMD"],
 		   [The path to 'cache_check', if available.])
@@ -624,21 +607,19 @@ AC_ARG_WITH(vdo-format,
 	    AS_HELP_STRING([--with-vdo-format=PATH],
 			   [vdoformat tool: [autodetect]]),
 			   VDO_FORMAT_CMD=$withval, VDO_FORMAT_CMD="autodetect")
-case "$VDO" in
- no|none) ;;
- internal)
-	AC_DEFINE([VDO_INTERNAL], 1, [Define to 1 to include built-in support for vdo.])
-	AS_IF([test "$VDO_FORMAT_CMD" = "autodetect"], [
-		AC_PATH_TOOL(VDO_FORMAT_CMD, vdoformat, [], [$PATH])
-		AS_IF([test -z "$VDO_FORMAT_CMD"], [
-			AC_MSG_WARN([vdoformat not found in path $PATH])
-			VDO_FORMAT_CMD=/usr/bin/vdoformat
-			VDO_CONFIGURE_WARN=y
-		])
-	])
-	;;
- *) AC_MSG_ERROR([--with-vdo parameter invalid]) ;;
-esac
+AS_CASE(["$VDO"],
+	[no|none], [],
+	[internal], [
+		AC_DEFINE([VDO_INTERNAL], 1, [Define to 1 to include built-in support for vdo.])
+		AS_IF([test "$VDO_FORMAT_CMD" = "autodetect"], [
+			AC_PATH_TOOL(VDO_FORMAT_CMD, vdoformat, [], [$PATH])
+			AS_IF([test -z "$VDO_FORMAT_CMD"], [
+				AC_MSG_WARN([vdoformat not found in path $PATH])
+				VDO_FORMAT_CMD=/usr/bin/vdoformat
+				VDO_CONFIGURE_WARN=y
+			])
+		])],
+	[AC_MSG_ERROR([--with-vdo parameter invalid])])
 
 AC_DEFINE_UNQUOTED([VDO_FORMAT_CMD], ["$VDO_FORMAT_CMD"],
 		   [The path to 'vdoformat', if available.])
@@ -668,13 +649,11 @@ AC_ARG_WITH(writecache,
 
 AC_MSG_RESULT($WRITECACHE)
 
-case "$WRITECACHE" in
- no|none) ;;
- internal)
-	AC_DEFINE([WRITECACHE_INTERNAL], 1, [Define to 1 to include built-in support for writecache.])
-	;;
- *) AC_MSG_ERROR([--with-writecache parameter invalid]) ;;
-esac
+AS_CASE(["$WRITECACHE"],
+	[no|none], [],
+	[internal], [
+		AC_DEFINE([WRITECACHE_INTERNAL], 1, [Define to 1 to include built-in support for writecache.])],
+	[AC_MSG_ERROR([--with-writecache parameter invalid])])
 
 ################################################################################
 dnl -- integrity inclusion type
@@ -686,13 +665,11 @@ AC_ARG_WITH(integrity,
 
 AC_MSG_RESULT($INTEGRITY)
 
-case "$INTEGRITY" in
- no|none) ;;
- internal)
-	AC_DEFINE([INTEGRITY_INTERNAL], 1, [Define to 1 to include built-in support for integrity.])
-	;;
- *) AC_MSG_ERROR([--with-integrity parameter invalid]) ;;
-esac
+AS_CASE(["$INTEGRITY"],
+	[no|none], [],
+	[internal], [
+		AC_DEFINE([INTEGRITY_INTERNAL], 1, [Define to 1 to include built-in support for integrity.])],
+	[AC_MSG_ERROR([--with-integrity parameter invalid])])
 
 ################################################################################
 # Allow users to override default location for libaio
@@ -825,23 +802,21 @@ AC_MSG_RESULT($COPTIMISE_FLAG)
 dnl -- Symbol versioning
 AC_MSG_CHECKING(whether to use symbol versioning)
 AC_ARG_WITH(symvers,
-	    AS_HELP_STRING([--with-symvers=STYLE],
-			   [use symbol versioning of the shared library [default=gnu]]),
-			   [ case "$withval" in
-				gnu|no) symvers=$withval ;;
-				*) AC_MSG_ERROR(--with-symvers parameter invalid) ;;
-			     esac], symvers=gnu)
+	AS_HELP_STRING([--with-symvers=STYLE],
+		       [use symbol versioning of the shared library [default=gnu]]), [
+			AS_CASE(["$withval"],
+				[gnu|no], [symvers=$withval],
+				[AC_MSG_ERROR(--with-symvers parameter invalid)])],
+		       [symvers=gnu])
 AC_MSG_RESULT($symvers)
 
 AS_IF([test "$GCC" = "yes" && test "$symvers" = "gnu"], [
 	AC_DEFINE(GNU_SYMVER, 1,
 		  [Define to use GNU versioning in the shared library.])
-		   case "$host_os" in
-			linux*)
+	AS_CASE(["$host_os"],
+		[linux*], [
 			CLDFLAGS="${CLDFLAGS-"$LDFLAGS"} -Wl,--version-script,.export.sym"
-			LDDEPS="$LDDEPS .export.sym"
-			;;
-		   esac
+			LDDEPS="$LDDEPS .export.sym"])
 ])
 
 ################################################################################
@@ -1010,12 +985,9 @@ AS_IF([test "$BUILD_LVMLOCKD" = "yes"], [
 	AS_IF([test "$BUILD_LVMPOLLD" = "no"], [BUILD_LVMPOLLD=yes; AC_MSG_WARN([Enabling lvmpolld - required by lvmlockd.])])
 	AC_MSG_CHECKING([defaults for use_lvmlockd])
 	AC_ARG_ENABLE(use_lvmlockd,
-		      AS_HELP_STRING([--disable-use-lvmlockd],
-				     [disable usage of LVM lock daemon]),
-		      [case ${enableval} in
-		       yes) DEFAULT_USE_LVMLOCKD=1 ;;
-		       *) DEFAULT_USE_LVMLOCKD=0 ;;
-		       esac], DEFAULT_USE_LVMLOCKD=1)
+		[AS_HELP_STRING([--disable-use-lvmlockd], [disable usage of LVM lock daemon])],
+		[AS_IF([test "$enableval" = "yes"], [DEFAULT_USE_LVMLOCKD=1], [DEFAULT_USE_LVMLOCKD=0])],
+		[DEFAULT_USE_LVMLOCKD=1])
 	AC_MSG_RESULT($DEFAULT_USE_LVMLOCKD)
 	AC_DEFINE([LVMLOCKD_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd.])
 
@@ -1037,12 +1009,9 @@ dnl -- Check lvmpolld
 AS_IF([test "$BUILD_LVMPOLLD" = "yes"], [
 	AC_MSG_CHECKING([defaults for use_lvmpolld])
 	AC_ARG_ENABLE(use_lvmpolld,
-		      AS_HELP_STRING([--disable-use-lvmpolld],
-				     [disable usage of LVM Poll Daemon]),
-		      [case ${enableval} in
-		       yes) DEFAULT_USE_LVMPOLLD=1 ;;
-		       *) DEFAULT_USE_LVMPOLLD=0 ;;
-		       esac], DEFAULT_USE_LVMPOLLD=1)
+		[AS_HELP_STRING([--disable-use-lvmpolld], [disable usage of LVM Poll Daemon])],
+		[AS_IF([test "$enableval" = "yes"], [DEFAULT_USE_LVMPOLLD=1], [DEFAULT_USE_LVMPOLLD=0])],
+		[DEFAULT_USE_LVMPOLLD=1])
 	AC_MSG_RESULT($DEFAULT_USE_LVMPOLLD)
 	AC_DEFINE([LVMPOLLD_SUPPORT], 1, [Define to 1 to include code that uses lvmpolld.])
 

