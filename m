From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Feb 2023 16:53:24 +0000 (GMT)
Subject: main - configure.ac: misc updates
Message-ID: <20230210165324.C93DA385840D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e67ebc5c40948bcbea536fd407535009a76ede00
Commit:        e67ebc5c40948bcbea536fd407535009a76ede00
Parent:        042fbd43d25f4cc69ceec1aea4d0658bec54b6e3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 9 17:37:17 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 10 17:50:27 2023 +0100

configure.ac: misc updates

Use literal assignments with "" for better visibility in text editor.
Use more [] for AC_ macro args.
---
 configure.ac | 468 +++++++++++++++++++++++++++++------------------------------
 1 file changed, 234 insertions(+), 234 deletions(-)

diff --git a/configure.ac b/configure.ac
index 907391406..7f9b3e664 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1,6 +1,6 @@
 ###############################################################################
 ## Copyright (C) 2000-2004 Sistina Software, Inc. All rights reserved.
-## Copyright (C) 2004-2016 Red Hat, Inc. All rights reserved.
+## Copyright (C) 2004-2022 Red Hat, Inc. All rights reserved.
 ##
 ## This copyrighted material is made available to anyone wishing to use,
 ## modify, copy, or redistribute it subject to the terms and conditions
@@ -35,28 +35,28 @@ AS_CASE(["$host_os"],
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
-		BLKDEACTIVATE=yes],
+		LIB_SUFFIX="so"
+		DEVMAPPER="yes"
+		BUILD_LVMPOLLD="no"
+		ODIRECT="yes"
+		DM_IOCTLS="yes"
+		SELINUX="yes"
+		FSADM="yes"
+		LVMIMPORTVDO="yes"
+		BLKDEACTIVATE="yes"],
 	[darwin*], [
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
-		BLKDEACTIVATE=no],
+		LIB_SUFFIX="dylib"
+		DEVMAPPER="yes"
+		ODIRECT="no"
+		DM_IOCTLS="no"
+		SELINUX="no"
+		FSADM="no"
+		LVMIMPORTVDO="no"
+		BLKDEACTIVATE="no"],
 	[CLDFLAGS="${CLDFLAGS-"$LDFLAGS"}"])
 
 ################################################################################
@@ -159,31 +159,31 @@ AC_FUNC_VPRINTF
 
 ################################################################################
 dnl -- Disable dependency tracking
-AC_MSG_CHECKING(whether to enable dependency tracking)
+AC_MSG_CHECKING([whether to enable dependency tracking])
 AC_ARG_ENABLE(dependency-tracking,
 	      AS_HELP_STRING([--disable-dependency-tracking],
 			     [speeds up one-time build.]),
-	      USE_TRACKING=$enableval, USE_TRACKING=yes)
-AC_MSG_RESULT($USE_TRACKING)
+	      USE_TRACKING=$enableval, USE_TRACKING="yes")
+AC_MSG_RESULT([$USE_TRACKING])
 
 ################################################################################
 dnl -- Disable silence rules
-AC_MSG_CHECKING(whether to build silently)
+AC_MSG_CHECKING([whether to build silently])
 AC_ARG_ENABLE(silent-rules,
 	      AS_HELP_STRING([--disable-silent-rules], [disable silent building]),
-	      SILENT_RULES=$enableval, SILENT_RULES=yes)
-AC_MSG_RESULT($SILENT_RULES)
+	      SILENT_RULES=$enableval, SILENT_RULES="yes")
+AC_MSG_RESULT([$SILENT_RULES])
 
 
 ################################################################################
 dnl -- Enables statically-linked tools
-AC_MSG_CHECKING(whether to use static linking)
+AC_MSG_CHECKING([whether to use static linking])
 AC_ARG_ENABLE(static_link,
 	      AS_HELP_STRING([--enable-static_link],
 			     [use this to link the tools to their libraries
 			      statically (default is dynamic linking]),
-	      STATIC_LINK=$enableval, STATIC_LINK=no)
-AC_MSG_RESULT($STATIC_LINK)
+	      STATIC_LINK=$enableval, STATIC_LINK="no")
+AC_MSG_RESULT([$STATIC_LINK])
 
 ################################################################################
 dnl -- Check if compiler/linker supports PIE and RELRO
@@ -200,64 +200,64 @@ AC_PREFIX_DEFAULT(/usr)
 dnl -- Clear default exec_prefix - install into /sbin rather than /usr/sbin
 test "$exec_prefix" = "NONE" && test "$prefix" = "NONE" && exec_prefix=""
 
-test "x$prefix" = xNONE && prefix=$ac_default_prefix
+test "$prefix" = "NONE" && prefix=$ac_default_prefix
 # Let make expand exec_prefix.
-test "x$exec_prefix" = xNONE && exec_prefix='${prefix}'
+test "$exec_prefix" = "NONE" && exec_prefix='${prefix}'
 
 ################################################################################
 dnl -- Setup the ownership of the files
-AC_MSG_CHECKING(file owner)
+AC_MSG_CHECKING([file owner])
 AC_ARG_WITH(user,
 	    AS_HELP_STRING([--with-user=USER],
 			   [set the owner of installed files [USER=]]),
 	    OWNER=$withval)
-AC_MSG_RESULT($OWNER)
+AC_MSG_RESULT([$OWNER])
 test -n "$OWNER" && INSTALL="$INSTALL -o $OWNER"
 
 ################################################################################
 dnl -- Setup the group ownership of the files
-AC_MSG_CHECKING(group owner)
+AC_MSG_CHECKING([group owner])
 AC_ARG_WITH(group,
 	    AS_HELP_STRING([--with-group=GROUP],
 			   [set the group owner of installed files [GROUP=]]),
 	    GROUP=$withval)
-AC_MSG_RESULT($GROUP)
+AC_MSG_RESULT([$GROUP])
 test -n "$GROUP" && INSTALL="$INSTALL -g $GROUP"
 
 ################################################################################
 dnl -- Setup device node ownership
-AC_MSG_CHECKING(device node uid)
+AC_MSG_CHECKING([device node uid])
 
 AC_ARG_WITH(device-uid,
 	    AS_HELP_STRING([--with-device-uid=UID],
 			   [set the owner used for new device nodes [UID=0]]),
 	    DM_DEVICE_UID=$withval, DM_DEVICE_UID=0)
-AC_MSG_RESULT($DM_DEVICE_UID)
+AC_MSG_RESULT([$DM_DEVICE_UID])
 AC_DEFINE_UNQUOTED([DM_DEVICE_UID], [$DM_DEVICE_UID], [Define default owner for device node])
 
 ################################################################################
 dnl -- Setup device group ownership
-AC_MSG_CHECKING(device node gid)
+AC_MSG_CHECKING([device node gid])
 
 AC_ARG_WITH(device-gid,
 	    AS_HELP_STRING([--with-device-gid=GID],
 			   [set the group used for new device nodes [GID=0]]),
 	    DM_DEVICE_GID=$withval, DM_DEVICE_GID=0)
-AC_MSG_RESULT($DM_DEVICE_GID)
+AC_MSG_RESULT([$DM_DEVICE_GID])
 AC_DEFINE_UNQUOTED([DM_DEVICE_GID], [$DM_DEVICE_GID], [Define default group for device node])
 
 ################################################################################
 dnl -- Setup device mode
-AC_MSG_CHECKING(device node mode)
+AC_MSG_CHECKING([device node mode])
 
 AC_ARG_WITH(device-mode,
 	    AS_HELP_STRING([--with-device-mode=MODE],
 			   [set the mode used for new device nodes [MODE=0600]]),
 	    DM_DEVICE_MODE=$withval, DM_DEVICE_MODE=0600)
-AC_MSG_RESULT($DM_DEVICE_MODE)
+AC_MSG_RESULT([$DM_DEVICE_MODE])
 AC_DEFINE_UNQUOTED([DM_DEVICE_MODE], [$DM_DEVICE_MODE], [Define default mode for device node])
 
-AC_MSG_CHECKING(when to create device nodes)
+AC_MSG_CHECKING([when to create device nodes])
 AC_ARG_WITH(device-nodes-on,
 	    AS_HELP_STRING([--with-device-nodes-on=ON],
 			   [create nodes on resume or create [ON=resume]]),
@@ -266,23 +266,23 @@ AS_CASE(["$ADD_NODE"],
 	[resume], [add_on=DM_ADD_NODE_ON_RESUME],
 	[create], [add_on=DM_ADD_NODE_ON_CREATE],
 	[AC_MSG_ERROR([--with-device-nodes-on parameter invalid])])
-AC_MSG_RESULT(on $ADD_NODE)
+AC_MSG_RESULT([on $ADD_NODE])
 AC_DEFINE_UNQUOTED([DEFAULT_DM_ADD_NODE], $add_on, [Define default node creation behavior with dmsetup create])
 
 
 dnl -- Default settings for lvm.conf { devices/use_devicesfile }
-AC_MSG_CHECKING(default for use_devicesfile)
+AC_MSG_CHECKING([default for use_devicesfile])
 AC_ARG_WITH(default-use-devices-file,
 	      AS_HELP_STRING([--with-default-use-devices-file], [default for lvm.conf devices/use_devicesfile = [0]]),
 	      DEFAULT_USE_DEVICES_FILE=$withval, DEFAULT_USE_DEVICES_FILE=0)
 AS_CASE(["$DEFAULT_USE_DEVICES_FILE"],
 	[0|1], [],
 	[AC_MSG_ERROR([--with-default-use-devices-file parameter invalid])])
-AC_MSG_RESULT($DEFAULT_USE_DEVICES_FILE)
+AC_MSG_RESULT([$DEFAULT_USE_DEVICES_FILE])
 AC_DEFINE_UNQUOTED(DEFAULT_USE_DEVICES_FILE, [$DEFAULT_USE_DEVICES_FILE],
 		   [Default for lvm.conf use_devicesfile.])
 
-AC_MSG_CHECKING(default name mangling)
+AC_MSG_CHECKING([default name mangling])
 AC_ARG_WITH(default-name-mangling,
 	    AS_HELP_STRING([--with-default-name-mangling=MANGLING],
 			   [default name mangling: auto/none/hex [auto]]),
@@ -292,17 +292,17 @@ AS_CASE(["$MANGLING"],
 	[no|none|disabled], [mangling=DM_STRING_MANGLING_NONE],
 	[hex], [mangling=DM_STRING_MANGLING_HEX],
 	[AC_MSG_ERROR([--with-default-name-mangling parameter invalid])])
-AC_MSG_RESULT($MANGLING)
+AC_MSG_RESULT([$MANGLING])
 AC_DEFINE_UNQUOTED([DEFAULT_DM_NAME_MANGLING], $mangling, [Define default name mangling behaviour])
 
 ################################################################################
 dnl -- snapshots inclusion type
-AC_MSG_CHECKING(whether to include snapshots)
+AC_MSG_CHECKING([whether to include snapshots])
 AC_ARG_WITH(snapshots,
 	    AS_HELP_STRING([--with-snapshots=TYPE],
 			   [snapshot support: internal/none [internal]]),
 	    SNAPSHOTS=$withval, SNAPSHOTS=internal)
-AC_MSG_RESULT($SNAPSHOTS)
+AC_MSG_RESULT([$SNAPSHOTS])
 
 AS_CASE(["$SNAPSHOTS"],
 	[no|none|shared], [],
@@ -312,12 +312,12 @@ AS_CASE(["$SNAPSHOTS"],
 
 ################################################################################
 dnl -- mirrors inclusion type
-AC_MSG_CHECKING(whether to include mirrors)
+AC_MSG_CHECKING([whether to include mirrors])
 AC_ARG_WITH(mirrors,
 	    AS_HELP_STRING([--with-mirrors=TYPE],
 			   [mirror support: internal/none [internal]]),
 	    MIRRORS=$withval, MIRRORS=internal)
-AC_MSG_RESULT($MIRRORS)
+AC_MSG_RESULT([$MIRRORS])
 
 AS_CASE(["$MIRRORS"],
 	[no|none|shared], [],
@@ -355,7 +355,7 @@ AC_ARG_WITH(default-sparse-segtype,
 
 ################################################################################
 dnl -- thin provisioning
-AC_MSG_CHECKING(whether to include thin provisioning)
+AC_MSG_CHECKING([whether to include thin provisioning])
 AC_ARG_WITH(thin,
 	    AS_HELP_STRING([--with-thin=TYPE],
 			   [thin provisioning support: internal/none [internal]]),
@@ -377,7 +377,7 @@ AC_ARG_WITH(thin-restore,
 			   [thin_restore tool: [autodetect]]),
 			   THIN_RESTORE_CMD=$withval, THIN_RESTORE_CMD="autodetect")
 
-AC_MSG_RESULT($THIN)
+AC_MSG_RESULT([$THIN])
 
 AS_CASE(["$THIN"],
 	[no|none], [test "$DEFAULT_SPARSE_SEGTYPE" = "thin" && DEFAULT_SPARSE_SEGTYPE="snapshot"],
@@ -393,7 +393,7 @@ dnl -- thin_check needs-check flag
 AC_ARG_ENABLE(thin_check_needs_check,
 	      AS_HELP_STRING([--disable-thin_check_needs_check],
 			     [required if thin_check version is < 0.3.0]),
-	      THIN_CHECK_NEEDS_CHECK=$enableval, THIN_CHECK_NEEDS_CHECK=yes)
+	      THIN_CHECK_NEEDS_CHECK=$enableval, THIN_CHECK_NEEDS_CHECK="yes")
 
 # Test if necessary thin tools are available
 # if not - use plain defaults and warn user
@@ -404,50 +404,50 @@ AS_CASE(["$THIN"],
 		AC_PATH_TOOL(THIN_CHECK_CMD, thin_check, [], [$PATH_SBIN])
 		AS_IF([test -z "$THIN_CHECK_CMD"], [
 			AC_MSG_WARN([thin_check not found in path $PATH])
-			THIN_CHECK_CMD=/usr/sbin/thin_check
-			THIN_CONFIGURE_WARN=y
+			THIN_CHECK_CMD="/usr/sbin/thin_check"
+			THIN_CONFIGURE_WARN="y"
 		])
 	])
 	AS_IF([test "$THIN_CHECK_NEEDS_CHECK" = "yes" && test "$THIN_CONFIGURE_WARN" != "y"], [
-		THIN_CHECK_VSN=`"$THIN_CHECK_CMD" -V 2>/dev/null`
-		THIN_CHECK_VSN_MAJOR=`echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $1}'`
-		THIN_CHECK_VSN_MINOR=`echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $2}'`
+		THIN_CHECK_VSN=$("$THIN_CHECK_CMD" -V 2>/dev/null)
+		THIN_CHECK_VSN_MAJOR=$(echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $1}')
+		THIN_CHECK_VSN_MINOR=$(echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $2}')
 
 		AS_IF([test -z "$THIN_CHECK_VSN_MAJOR" || test -z "$THIN_CHECK_VSN_MINOR"], [
 			AC_MSG_WARN([$THIN_CHECK_CMD: Bad version "$THIN_CHECK_VSN" found])
-			THIN_CHECK_VERSION_WARN=y
-			THIN_CHECK_NEEDS_CHECK=no
+			THIN_CHECK_VERSION_WARN="y"
+			THIN_CHECK_NEEDS_CHECK="no"
 		], [test "$THIN_CHECK_VSN_MAJOR" -eq 0 && test "$THIN_CHECK_VSN_MINOR" -lt 3], [
 			AC_MSG_WARN([$THIN_CHECK_CMD: Old version "$THIN_CHECK_VSN" found])
-			THIN_CHECK_VERSION_WARN=y
-			THIN_CHECK_NEEDS_CHECK=no
+			THIN_CHECK_VERSION_WARN="y"
+			THIN_CHECK_NEEDS_CHECK="no"
 		])
 	])
 	# Empty means a config way to ignore thin dumping
 	AS_IF([test "$THIN_DUMP_CMD" = "autodetect"], [
 		AC_PATH_TOOL(THIN_DUMP_CMD, thin_dump, [], [$PATH_SBIN])
 		AS_IF([test -z "$THIN_DUMP_CMD"], [
-			AC_MSG_WARN(thin_dump not found in path $PATH)
-			THIN_DUMP_CMD=/usr/sbin/thin_dump
-			THIN_CONFIGURE_WARN=y
+			AC_MSG_WARN(["thin_dump not found in path $PATH"])
+			THIN_DUMP_CMD="/usr/sbin/thin_dump"
+			THIN_CONFIGURE_WARN="y"
 		])
 	])
 	# Empty means a config way to ignore thin repairing
 	AS_IF([test "$THIN_REPAIR_CMD" = "autodetect"], [
 		AC_PATH_TOOL(THIN_REPAIR_CMD, thin_repair, [], [$PATH_SBIN])
 		AS_IF([test -z "$THIN_REPAIR_CMD"], [
-			AC_MSG_WARN(thin_repair not found in path $PATH)
-			THIN_REPAIR_CMD=/usr/sbin/thin_repair
-			THIN_CONFIGURE_WARN=y
+			AC_MSG_WARN(["thin_repair not found in path $PATH"])
+			THIN_REPAIR_CMD="/usr/sbin/thin_repair"
+			THIN_CONFIGURE_WARN="y"
 		])
 	])
 	# Empty means a config way to ignore thin restoring
 	AS_IF([test "$THIN_RESTORE_CMD" = "autodetect"], [
 		AC_PATH_TOOL(THIN_RESTORE_CMD, thin_restore, [], [$PATH_SBIN])
 		AS_IF([test -z "$THIN_RESTORE_CMD"], [
-			AC_MSG_WARN(thin_restore not found in path $PATH)
-			THIN_RESTORE_CMD=/usr/sbin/thin_restore
-			THIN_CONFIGURE_WARN=y
+			AC_MSG_WARN(["thin_restore not found in path $PATH"])
+			THIN_RESTORE_CMD="/usr/sbin/thin_restore"
+			THIN_CONFIGURE_WARN="y"
 		])
 	])
 
@@ -472,7 +472,7 @@ AC_DEFINE_UNQUOTED([THIN_RESTORE_CMD], ["$THIN_RESTORE_CMD"],
 
 ################################################################################
 dnl -- cache inclusion type
-AC_MSG_CHECKING(whether to include cache)
+AC_MSG_CHECKING([whether to include cache])
 AC_ARG_WITH(cache,
 	    AS_HELP_STRING([--with-cache=TYPE],
 			   [cache support: internal/none [internal]]),
@@ -493,7 +493,7 @@ AC_ARG_WITH(cache-restore,
 	    AS_HELP_STRING([--with-cache-restore=PATH],
 			   [cache_restore tool: [autodetect]]),
 			   CACHE_RESTORE_CMD=$withval, CACHE_RESTORE_CMD="autodetect")
-AC_MSG_RESULT($CACHE)
+AC_MSG_RESULT([$CACHE])
 
 AS_CASE(["$CACHE"],
 	[no|none|shared], [],
@@ -505,7 +505,7 @@ dnl -- cache_check needs-check flag
 AC_ARG_ENABLE(cache_check_needs_check,
 	      AS_HELP_STRING([--disable-cache_check_needs_check],
 			     [required if cache_check version is < 0.5]),
-	      CACHE_CHECK_NEEDS_CHECK=$enableval, CACHE_CHECK_NEEDS_CHECK=yes)
+	      CACHE_CHECK_NEEDS_CHECK=$enableval, CACHE_CHECK_NEEDS_CHECK="yes")
 
 # Test if necessary cache tools are available
 # if not - use plain defaults and warn user
@@ -516,8 +516,8 @@ AS_CASE(["$CACHE"],
 		AC_PATH_TOOL(CACHE_CHECK_CMD, cache_check, [], [$PATH_SBIN])
 		AS_IF([test -z "$CACHE_CHECK_CMD"], [
 			AC_MSG_WARN([cache_check not found in path $PATH])
-			CACHE_CHECK_CMD=/usr/sbin/cache_check
-			CACHE_CONFIGURE_WARN=y
+			CACHE_CHECK_CMD="/usr/sbin/cache_check"
+			CACHE_CONFIGURE_WARN="y"
 		])
 	])
 	AS_IF([test "$CACHE_CHECK_NEEDS_CHECK" = "yes" && test "$CACHE_CONFIGURE_WARN" != "y"], [
@@ -531,14 +531,14 @@ AS_CASE(["$CACHE"],
 			|| test -z "$CACHE_CHECK_VSN_MINOR" \
 			|| test -z "$CACHE_CHECK_VSN_PATCH"], [
 			AC_MSG_WARN([$CACHE_CHECK_CMD: Bad version "$CACHE_CHECK_VSN" found])
-			CACHE_CHECK_VERSION_WARN=y
-			CACHE_CHECK_NEEDS_CHECK=no
+			CACHE_CHECK_VERSION_WARN="y"
+			CACHE_CHECK_NEEDS_CHECK="no"
 		], [test "$CACHE_CHECK_VSN_MAJOR" -eq 0], [
 			AS_IF([test "$CACHE_CHECK_VSN_MINOR" -lt 5 \
 				|| ( test "$CACHE_CHECK_VSN_MINOR" -eq 5 && test "$CACHE_CHECK_VSN_PATCH" -lt 4 )], [
 				AC_MSG_WARN([$CACHE_CHECK_CMD: Old version "$CACHE_CHECK_VSN" found])
-				CACHE_CHECK_VERSION_WARN=y
-				CACHE_CHECK_NEEDS_CHECK=no
+				CACHE_CHECK_VERSION_WARN="y"
+				CACHE_CHECK_NEEDS_CHECK="no"
 			])
 			AS_IF([test "$CACHE_CHECK_VSN_MINOR" -lt 7], [
 				AC_MSG_WARN([$CACHE_CHECK_CMD: Old version "$CACHE_CHECK_VSN" does not support new cache format V2])
@@ -550,27 +550,27 @@ AS_CASE(["$CACHE"],
 	AS_IF([test "$CACHE_DUMP_CMD" = "autodetect"], [
 		AC_PATH_TOOL(CACHE_DUMP_CMD, cache_dump, [], [$PATH_SBIN])
 		AS_IF([test -z "$CACHE_DUMP_CMD"], [
-			AC_MSG_WARN(cache_dump not found in path $PATH)
-			CACHE_DUMP_CMD=/usr/sbin/cache_dump
-			CACHE_CONFIGURE_WARN=y
+			AC_MSG_WARN(["cache_dump not found in path $PATH"])
+			CACHE_DUMP_CMD="/usr/sbin/cache_dump"
+			CACHE_CONFIGURE_WARN="y"
 		])
 	])
 	# Empty means a config way to ignore cache repairing
 	AS_IF([test "$CACHE_REPAIR_CMD" = "autodetect"], [
 		AC_PATH_TOOL(CACHE_REPAIR_CMD, cache_repair, [], [$PATH_SBIN])
 		AS_IF([test -z "$CACHE_REPAIR_CMD"], [
-			AC_MSG_WARN(cache_repair not found in path $PATH)
-			CACHE_REPAIR_CMD=/usr/sbin/cache_repair
-			CACHE_CONFIGURE_WARN=y
+			AC_MSG_WARN(["cache_repair not found in path $PATH"])
+			CACHE_REPAIR_CMD="/usr/sbin/cache_repair"
+			CACHE_CONFIGURE_WARN="y"
 		])
 	])
 	# Empty means a config way to ignore cache restoring
 	AS_IF([test "$CACHE_RESTORE_CMD" = "autodetect"], [
 		AC_PATH_TOOL(CACHE_RESTORE_CMD, cache_restore, [], [$PATH_SBIN])
 		AS_IF([test -z "$CACHE_RESTORE_CMD"], [
-			AC_MSG_WARN(cache_restore not found in path $PATH)
-			CACHE_RESTORE_CMD=/usr/sbin/cache_restore
-			CACHE_CONFIGURE_WARN=y
+			AC_MSG_WARN(["cache_restore not found in path $PATH"])
+			CACHE_RESTORE_CMD="/usr/sbin/cache_restore"
+			CACHE_CONFIGURE_WARN="y"
 		])
 	])
 
@@ -595,13 +595,13 @@ AC_DEFINE_UNQUOTED([CACHE_RESTORE_CMD], ["$CACHE_RESTORE_CMD"],
 
 ################################################################################
 dnl -- cache inclusion type
-AC_MSG_CHECKING(whether to include vdo)
+AC_MSG_CHECKING([whether to include vdo])
 AC_ARG_WITH(vdo,
 	    AS_HELP_STRING([--with-vdo=TYPE],
 			   [vdo support: internal/none [internal]]),
 			   VDO=$withval, VDO="internal")
 
-AC_MSG_RESULT($VDO)
+AC_MSG_RESULT([$VDO])
 
 AC_ARG_WITH(vdo-format,
 	    AS_HELP_STRING([--with-vdo-format=PATH],
@@ -615,7 +615,7 @@ AS_CASE(["$VDO"],
 			AC_PATH_TOOL(VDO_FORMAT_CMD, vdoformat, [], [$PATH])
 			AS_IF([test -z "$VDO_FORMAT_CMD"], [
 				AC_MSG_WARN([vdoformat not found in path $PATH])
-				VDO_FORMAT_CMD=/usr/bin/vdoformat
+				VDO_FORMAT_CMD="/usr/bin/vdoformat"
 				VDO_CONFIGURE_WARN=y
 			])
 		])],
@@ -631,23 +631,23 @@ AC_DEFINE_UNQUOTED([VDO_FORMAT_CMD], ["$VDO_FORMAT_CMD"],
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
 dnl -- writecache inclusion type
-AC_MSG_CHECKING(whether to include writecache)
+AC_MSG_CHECKING([whether to include writecache])
 AC_ARG_WITH(writecache,
 	    AS_HELP_STRING([--with-writecache=TYPE],
 			   [writecache support: internal/none [internal]]),
 			   WRITECACHE=$withval, WRITECACHE="internal")
 
-AC_MSG_RESULT($WRITECACHE)
+AC_MSG_RESULT([$WRITECACHE])
 
 AS_CASE(["$WRITECACHE"],
 	[no|none], [],
@@ -657,13 +657,13 @@ AS_CASE(["$WRITECACHE"],
 
 ################################################################################
 dnl -- integrity inclusion type
-AC_MSG_CHECKING(whether to include integrity)
+AC_MSG_CHECKING([whether to include integrity])
 AC_ARG_WITH(integrity,
 	    AS_HELP_STRING([--with-integrity=TYPE],
 			   [integrity support: internal/none [internal]]),
 			   INTEGRITY=$withval, INTEGRITY="internal")
 
-AC_MSG_RESULT($INTEGRITY)
+AC_MSG_RESULT([$INTEGRITY])
 
 AS_CASE(["$INTEGRITY"],
 	[no|none], [],
@@ -683,40 +683,40 @@ AC_ARG_VAR([AIO_LIBS], [linker flags for AIO])
 dnl -- Disable readline
 AC_ARG_ENABLE([readline],
 	      AS_HELP_STRING([--disable-readline], [disable readline support]),
-	      READLINE=$enableval, READLINE=maybe)
+	      READLINE=$enableval, READLINE="maybe")
 
 ################################################################################
 dnl -- Disable editline
 AC_ARG_ENABLE([editline],
 	      AS_HELP_STRING([--enable-editline], [enable editline support]),
-	      EDITLINE=$enableval, EDITLINE=no)
+	      EDITLINE=$enableval, EDITLINE="no")
 
 ################################################################################
 dnl -- Disable realtime clock support
-AC_MSG_CHECKING(whether to enable realtime support)
+AC_MSG_CHECKING([whether to enable realtime support])
 AC_ARG_ENABLE(realtime,
 	      AS_HELP_STRING([--disable-realtime], [disable realtime clock support]),
-	      REALTIME=$enableval, REALTIME=yes)
-AC_MSG_RESULT($REALTIME)
+	      REALTIME=$enableval, REALTIME="yes")
+AC_MSG_RESULT([$REALTIME])
 
 ################################################################################
 dnl -- disable OCF resource agents
-AC_MSG_CHECKING(whether to enable OCF resource agents)
+AC_MSG_CHECKING([whether to enable OCF resource agents])
 AC_ARG_ENABLE(ocf,
 	      AS_HELP_STRING([--enable-ocf],
 			     [enable Open Cluster Framework (OCF) compliant resource agents]),
-	      OCF=$enableval, OCF=no)
-AC_MSG_RESULT($OCF)
+	      OCF=$enableval, OCF="no")
+AC_MSG_RESULT([$OCF])
 AC_ARG_WITH(ocfdir,
 	    AS_HELP_STRING([--with-ocfdir=DIR],
 			   [install OCF files in [PREFIX/lib/ocf/resource.d/lvm2]]),
 	    OCFDIR=$withval, OCFDIR='${prefix}/lib/ocf/resource.d/lvm2')
 
 ################################################################################
-AC_MSG_CHECKING(for default run directory)
+AC_MSG_CHECKING([for default run directory])
 RUN_DIR="/run"
 test -d "/run" || RUN_DIR="/var/run"
-AC_MSG_RESULT($RUN_DIR)
+AC_MSG_RESULT([$RUN_DIR])
 dnl -- Set up pidfile and run directory
 AH_TEMPLATE(DEFAULT_PID_DIR)
 AC_ARG_WITH(default-pid-dir,
@@ -744,12 +744,12 @@ AC_DEFINE_UNQUOTED(DEFAULT_RUN_DIR, ["$DEFAULT_RUN_DIR"],
 
 ################################################################################
 dnl -- Build cluster mirror log daemon
-AC_MSG_CHECKING(whether to build cluster mirror log daemon)
+AC_MSG_CHECKING([whether to build cluster mirror log daemon])
 AC_ARG_ENABLE(cmirrord,
 	      AS_HELP_STRING([--enable-cmirrord],
 			     [enable the cluster mirror log daemon]),
-	      CMIRRORD=$enableval, CMIRRORD=no)
-AC_MSG_RESULT($CMIRRORD)
+	      CMIRRORD=$enableval, CMIRRORD="no")
+AC_MSG_RESULT([$CMIRRORD])
 
 BUILD_CMIRRORD=$CMIRRORD
 
@@ -773,10 +773,10 @@ AS_IF([test "$BUILD_CMIRRORD" = "yes" && test "$HAVE_CPG" != "yes"], [
 
 ################################################################################
 dnl -- Enable debugging
-AC_MSG_CHECKING(whether to enable debugging)
+AC_MSG_CHECKING([whether to enable debugging])
 AC_ARG_ENABLE(debug, AS_HELP_STRING([--enable-debug], [enable debugging]),
-	      DEBUG=$enableval, DEBUG=no)
-AC_MSG_RESULT($DEBUG)
+	      DEBUG=$enableval, DEBUG="no")
+AC_MSG_RESULT([$DEBUG])
 
 dnl -- Normally turn off optimisation for debug builds
 AS_IF([test "$DEBUG" = "yes"], [COPTIMISE_FLAG=""], [CSCOPE_CMD=""])
@@ -791,24 +791,24 @@ AC_SUBST(HAVE_WSYNCNAND)
 
 ################################################################################
 dnl -- Override optimisation
-AC_MSG_CHECKING(for C optimisation flag)
+AC_MSG_CHECKING([for C optimisation flag])
 AC_ARG_WITH(optimisation,
 	    AS_HELP_STRING([--with-optimisation=OPT],
 			   [C optimisation flag [OPT=-O2]]),
 	    COPTIMISE_FLAG=$withval)
-AC_MSG_RESULT($COPTIMISE_FLAG)
+AC_MSG_RESULT([$COPTIMISE_FLAG])
 
 ################################################################################
 dnl -- Symbol versioning
-AC_MSG_CHECKING(whether to use symbol versioning)
+AC_MSG_CHECKING([whether to use symbol versioning])
 AC_ARG_WITH(symvers,
 	AS_HELP_STRING([--with-symvers=STYLE],
 		       [use symbol versioning of the shared library [default=gnu]]), [
 			AS_CASE(["$withval"],
 				[gnu|no], [symvers=$withval],
 				[AC_MSG_ERROR(--with-symvers parameter invalid)])],
-		       [symvers=gnu])
-AC_MSG_RESULT($symvers)
+		       [symvers="gnu"])
+AC_MSG_RESULT([$symvers])
 
 AS_IF([test "$GCC" = "yes" && test "$symvers" = "gnu"], [
 	AC_DEFINE(GNU_SYMVER, 1,
@@ -821,12 +821,12 @@ AS_IF([test "$GCC" = "yes" && test "$symvers" = "gnu"], [
 
 ################################################################################
 dnl -- Enable profiling
-AC_MSG_CHECKING(whether to gather gcov profiling data)
+AC_MSG_CHECKING([whether to gather gcov profiling data])
 AC_ARG_ENABLE(profiling,
 	      AS_HELP_STRING([--enable-profiling],
 			     [gather gcov profiling data]),
-	      PROFILING=$enableval, PROFILING=no)
-AC_MSG_RESULT($PROFILING)
+	      PROFILING=$enableval, PROFILING="no")
+AC_MSG_RESULT([$PROFILING])
 
 AS_IF([test "$PROFILING" = "yes"], [
   COPTIMISE_FLAG="$COPTIMISE_FLAG -fprofile-arcs -ftest-coverage"
@@ -839,7 +839,7 @@ AS_IF([test "$PROFILING" = "yes"], [
   AS_IF([test -n "$GENPNG"], [
     AC_MSG_CHECKING([whether $GENPNG has all required modules])
     AS_IF(["$GENPNG" --help > /dev/null 2>&1], [
-      AC_MSG_RESULT(ok)
+      AC_MSG_RESULT([ok])
       GENHTML="$GENHTML --frames"
     ], [
       AC_MSG_RESULT([not supported])
@@ -857,14 +857,14 @@ AC_DEFINE_UNQUOTED(TESTSUITE_DATA, ["$(eval echo $(eval echo $TESTSUITE_DATA))"]
 
 ################################################################################
 dnl -- Enable valgrind awareness of memory pools
-AC_MSG_CHECKING(whether to enable valgrind awareness of pools)
+AC_MSG_CHECKING([whether to enable valgrind awareness of pools])
 AC_ARG_ENABLE(valgrind_pool,
 	      AS_HELP_STRING([--enable-valgrind-pool],
 			     [enable valgrind awareness of pools]),
-	      VALGRIND_POOL=$enableval, VALGRIND_POOL=no)
-AC_MSG_RESULT($VALGRIND_POOL)
+	      VALGRIND_POOL=$enableval, VALGRIND_POOL="no")
+AC_MSG_RESULT([$VALGRIND_POOL])
 
-PKG_CHECK_MODULES(VALGRIND, valgrind, [HAVE_VALGRIND=yes], [
+PKG_CHECK_MODULES(VALGRIND, valgrind, [HAVE_VALGRIND="yes"], [
   AS_IF([test "$VALGRIND_POOL" = "yes"], [AC_MSG_ERROR(bailing out)])
 ])
 AC_SUBST(VALGRIND_CFLAGS)
@@ -879,12 +879,12 @@ AS_IF([test "$VALGRIND_POOL" = "yes"], [
 
 ################################################################################
 dnl -- Disable devmapper
-AC_MSG_CHECKING(whether to use device-mapper)
+AC_MSG_CHECKING([whether to use device-mapper])
 AC_ARG_ENABLE(devmapper,
 	      AS_HELP_STRING([--disable-devmapper],
 			     [disable LVM2 device-mapper interaction]),
 	      DEVMAPPER=$enableval)
-AC_MSG_RESULT($DEVMAPPER)
+AC_MSG_RESULT([$DEVMAPPER])
 
 AS_IF([test "$DEVMAPPER" = "yes"], [
 	AC_DEFINE([DEVMAPPER_SUPPORT], 1, [Define to 1 to enable LVM2 device-mapper interaction.])
@@ -892,24 +892,24 @@ AS_IF([test "$DEVMAPPER" = "yes"], [
 
 ################################################################################
 dnl -- Build lvmpolld
-AC_MSG_CHECKING(whether to build lvmpolld)
+AC_MSG_CHECKING([whether to build lvmpolld])
 AC_ARG_ENABLE(lvmpolld,
 	      AS_HELP_STRING([--enable-lvmpolld],
 			     [enable the LVM Polling Daemon]),
-	      LVMPOLLD=$enableval, LVMPOLLD=no)
+	      LVMPOLLD=$enableval, LVMPOLLD="no")
 test -n "$LVMPOLLD" && BUILD_LVMPOLLD=$LVMPOLLD
-AC_MSG_RESULT($BUILD_LVMPOLLD)
+AC_MSG_RESULT([$BUILD_LVMPOLLD])
 
 ################################################################################
 BUILD_LVMLOCKD=no
 
 dnl -- Build lvmlockdsanlock
-AC_MSG_CHECKING(whether to build lvmlockdsanlock)
+AC_MSG_CHECKING([whether to build lvmlockdsanlock])
 AC_ARG_ENABLE(lvmlockd-sanlock,
 	      AS_HELP_STRING([--enable-lvmlockd-sanlock],
 			     [enable the LVM lock daemon using sanlock]),
-	      LOCKDSANLOCK=$enableval, LOCKDSANLOCK=no)
-AC_MSG_RESULT($LOCKDSANLOCK)
+	      LOCKDSANLOCK=$enableval, LOCKDSANLOCK="no")
+AC_MSG_RESULT([$LOCKDSANLOCK])
 
 BUILD_LOCKDSANLOCK=$LOCKDSANLOCK
 
@@ -922,12 +922,12 @@ AS_IF([test "$BUILD_LOCKDSANLOCK" = "yes"], [
 
 ################################################################################
 dnl -- Build lvmlockddlm
-AC_MSG_CHECKING(whether to build lvmlockddlm)
+AC_MSG_CHECKING([whether to build lvmlockddlm])
 AC_ARG_ENABLE(lvmlockd-dlm,
 	      AS_HELP_STRING([--enable-lvmlockd-dlm],
 			     [enable the LVM lock daemon using dlm]),
-	      LOCKDDLM=$enableval, LOCKDDLM=no)
-AC_MSG_RESULT($LOCKDDLM)
+	      LOCKDDLM=$enableval, LOCKDDLM="no")
+AC_MSG_RESULT([$LOCKDDLM])
 
 BUILD_LOCKDDLM=$LOCKDDLM
 
@@ -940,12 +940,12 @@ AS_IF([test "$BUILD_LOCKDDLM" = "yes"], [
 
 ################################################################################
 dnl -- Build lvmlockddlmcontrol
-AC_MSG_CHECKING(whether to build lvmlockddlmcontrol)
+AC_MSG_CHECKING([whether to build lvmlockddlmcontrol])
 AC_ARG_ENABLE(lvmlockd-dlmcontrol,
 	      AS_HELP_STRING([--enable-lvmlockd-dlmcontrol],
 			     [enable lvmlockd remote refresh using libdlmcontrol]),
-	      LOCKDDLM_CONTROL=$enableval, LOCKDDLM_CONTROL=no)
-AC_MSG_RESULT($LOCKDDLM_CONTROL)
+	      LOCKDDLM_CONTROL=$enableval, LOCKDDLM_CONTROL="no")
+AC_MSG_RESULT([$LOCKDDLM_CONTROL])
 
 BUILD_LOCKDDLM_CONTROL=$LOCKDDLM_CONTROL
 
@@ -958,27 +958,27 @@ AS_IF([test "$BUILD_LOCKDDLM_CONTROL" = "yes"], [
 
 ################################################################################
 dnl -- Build lvmlockdidm
-AC_MSG_CHECKING(whether to build lvmlockdidm)
+AC_MSG_CHECKING([whether to build lvmlockdidm])
 AC_ARG_ENABLE(lvmlockd-idm,
 	      AS_HELP_STRING([--enable-lvmlockd-idm],
 			     [enable the LVM lock daemon using idm]),
-	      LOCKDIDM=$enableval, LOCKDIDM=no)
-AC_MSG_RESULT($LOCKDIDM)
+	      LOCKDIDM=$enableval, LOCKDIDM="no")
+AC_MSG_RESULT([$LOCKDIDM])
 
 BUILD_LOCKDIDM=$LOCKDIDM
 
 dnl -- Look for Seagate IDM libraries
 AS_IF([test "$BUILD_LOCKDIDM" = "yes"], [
 	PKG_CHECK_MODULES(LOCKD_IDM, libseagate_ilm >= 0.1.0, [HAVE_LOCKD_IDM=yes], $bailout)
-	PKG_CHECK_EXISTS(blkid >= 2.24, [HAVE_LOCKD_IDM=yes], $bailout)
+	PKG_CHECK_EXISTS(blkid >= 2.24, [HAVE_LOCKD_IDM="yes"], $bailout)
 	AC_DEFINE([LOCKDIDM_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd IDM option.])
 	BUILD_LVMLOCKD=yes
 ])
 
 ################################################################################
 dnl -- Build lvmlockd
-AC_MSG_CHECKING(whether to build lvmlockd)
-AC_MSG_RESULT($BUILD_LVMLOCKD)
+AC_MSG_CHECKING([whether to build lvmlockd])
+AC_MSG_RESULT([$BUILD_LVMLOCKD])
 
 AS_IF([test "$BUILD_LVMLOCKD" = "yes"], [
 	AS_IF([test "$LVMPOLLD" = "no"], [AC_MSG_ERROR([cannot build lvmlockd with --disable-lvmpolld.])])
@@ -988,7 +988,7 @@ AS_IF([test "$BUILD_LVMLOCKD" = "yes"], [
 		[AS_HELP_STRING([--disable-use-lvmlockd], [disable usage of LVM lock daemon])],
 		[AS_IF([test "$enableval" = "yes"], [DEFAULT_USE_LVMLOCKD=1], [DEFAULT_USE_LVMLOCKD=0])],
 		[DEFAULT_USE_LVMLOCKD=1])
-	AC_MSG_RESULT($DEFAULT_USE_LVMLOCKD)
+	AC_MSG_RESULT([$DEFAULT_USE_LVMLOCKD])
 	AC_DEFINE([LVMLOCKD_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd.])
 
 	AC_ARG_WITH(lvmlockd-pidfile,
@@ -1012,7 +1012,7 @@ AS_IF([test "$BUILD_LVMPOLLD" = "yes"], [
 		[AS_HELP_STRING([--disable-use-lvmpolld], [disable usage of LVM Poll Daemon])],
 		[AS_IF([test "$enableval" = "yes"], [DEFAULT_USE_LVMPOLLD=1], [DEFAULT_USE_LVMPOLLD=0])],
 		[DEFAULT_USE_LVMPOLLD=1])
-	AC_MSG_RESULT($DEFAULT_USE_LVMPOLLD)
+	AC_MSG_RESULT([$DEFAULT_USE_LVMPOLLD])
 	AC_DEFINE([LVMPOLLD_SUPPORT], 1, [Define to 1 to include code that uses lvmpolld.])
 
 	AC_ARG_WITH(lvmpolld-pidfile,
@@ -1030,11 +1030,11 @@ AC_DEFINE_UNQUOTED(DEFAULT_USE_LVMPOLLD, [$DEFAULT_USE_LVMPOLLD],
 
 ################################################################################
 dnl -- Check dmfilemapd
-AC_MSG_CHECKING(whether to build dmfilemapd)
+AC_MSG_CHECKING([whether to build dmfilemapd])
 AC_ARG_ENABLE(dmfilemapd, AS_HELP_STRING([--enable-dmfilemapd],
 					 [enable the dmstats filemap daemon]),
-	      BUILD_DMFILEMAPD=$enableval, BUILD_DMFILEMAPD=no)
-AC_MSG_RESULT($BUILD_DMFILEMAPD)
+	      BUILD_DMFILEMAPD=$enableval, BUILD_DMFILEMAPD="no")
+AC_MSG_RESULT([$BUILD_DMFILEMAPD])
 AC_DEFINE([DMFILEMAPD], $BUILD_DMFILEMAPD, [Define to 1 to enable the device-mapper filemap daemon.])
 
 dnl -- dmfilemapd requires FIEMAP
@@ -1048,32 +1048,32 @@ PKG_CHECK_EXISTS(systemd >= 205, [SYSTEMD_MIN_VERSION=205], [])
 ################################################################################
 dnl -- Build notifydbus
 PKG_CHECK_EXISTS(systemd >= 221, [SYSTEMD_MIN_VERSION=221], [])
-AC_MSG_CHECKING(whether to build notifydbus)
+AC_MSG_CHECKING([whether to build notifydbus])
 AC_ARG_ENABLE(notify-dbus,
 	      AS_HELP_STRING([--enable-notify-dbus],
 			     [enable LVM notification using dbus]),
 	      AS_IF([test "$enableval" = "yes" && test "$SYSTEMD_MIN_VERSION" -lt 221],
 		    AC_MSG_ERROR([Enabling notify-dbus requires systemd >= 221]))
-	      NOTIFYDBUS_SUPPORT=$enableval, NOTIFYDBUS_SUPPORT=no)
-AC_MSG_RESULT($NOTIFYDBUS_SUPPORT)
+	      NOTIFYDBUS_SUPPORT=$enableval, NOTIFYDBUS_SUPPORT="no")
+AC_MSG_RESULT([$NOTIFYDBUS_SUPPORT])
 
 AS_IF([test "$NOTIFYDBUS_SUPPORT" = "yes"],
       AC_DEFINE([NOTIFYDBUS_SUPPORT], 1, [Define to 1 to include code that uses dbus notification.]))
 
 ################################################################################
 dnl -- Build with systemd journaling when the header file is present
-AS_IF([test "$SYSTEMD_MIN_VERSION" -ge 221], [SYSTEMD_JOURNAL_SUPPORT=maybe], [SYSTEMD_JOURNAL_SUPPORT=no])
+AS_IF([test "$SYSTEMD_MIN_VERSION" -ge 221], [SYSTEMD_JOURNAL_SUPPORT="maybe"], [SYSTEMD_JOURNAL_SUPPORT="no"])
 AC_CHECK_HEADER([systemd/sd-journal.h],
-		[AS_IF([test "$SYSTEMD_JOURNAL_SUPPORT" != "no"], [SYSTEMD_JOURNAL_SUPPORT=yes])],
-                [SYSTEMD_JOURNAL_SUPPORT=no])
-AC_MSG_CHECKING(whether to log to systemd journal)
+		[AS_IF([test "$SYSTEMD_JOURNAL_SUPPORT" != "no"], [SYSTEMD_JOURNAL_SUPPORT="yes"])],
+                [SYSTEMD_JOURNAL_SUPPORT="no"])
+AC_MSG_CHECKING([whether to log to systemd journal])
 AC_ARG_ENABLE(systemd-journal,
 	      AS_HELP_STRING([--disable-systemd-journal],
 			     [disable LVM systemd journaling]),
 	      AS_IF([test "$enableval" = "yes" && test "$SYSTEMD_JOURNAL_SUPPORT" = "no"],
 		    AC_MSG_ERROR([Enabling systemd journal requires systemd/sd-journal.h and systemd >= 221.]))
 	      SYSTEMD_JOURNAL_SUPPORT=$enableval, [])
-AC_MSG_RESULT($SYSTEMD_JOURNAL_SUPPORT)
+AC_MSG_RESULT([$SYSTEMD_JOURNAL_SUPPORT])
 
 AS_IF([test "$SYSTEMD_JOURNAL_SUPPORT" = "yes"],
       AC_DEFINE([SYSTEMD_JOURNAL_SUPPORT], 1, [Define to 1 to include code that uses systemd journal.]))
@@ -1082,16 +1082,16 @@ AS_IF([test "$SYSTEMD_JOURNAL_SUPPORT" = "yes"],
 dnl -- Build appmachineid when header file sd-id128.h is present
 PKG_CHECK_EXISTS(systemd >= 234, [SYSTEMD_MIN_VERSION=234  APP_MACHINEID_SUPPORT=maybe], [APP_MACHINEID_SUPPORT=no])
 AC_CHECK_HEADER([systemd/sd-id128.h],
-		[AS_IF([test "$APP_MACHINEID_SUPPORT" != "no"], [APP_MACHINEID_SUPPORT=yes])],
+		[AS_IF([test "$APP_MACHINEID_SUPPORT" != "no"], [APP_MACHINEID_SUPPORT="yes"])],
 		[APP_MACHINEID_SUPPORT=no])
-AC_MSG_CHECKING(whether to support systemd appmachineid)
+AC_MSG_CHECKING([whether to support systemd appmachineid])
 AC_ARG_ENABLE(app-machineid,
 	      AS_HELP_STRING([--disable-app-machineid],
 			     [disable LVM system ID using app-specific machine-id]),
 	      AS_IF([test "$enableval" = "yes" && test "$APP_MACHINEID_SUPPORT" = "no"],
 		    AC_MSG_ERROR([Enabling app machineid requires systemd/sd-id128.h and systemd >= 234.]))
 	      APP_MACHINEID_SUPPORT=$enableval, [])
-AC_MSG_RESULT($APP_MACHINEID_SUPPORT)
+AC_MSG_RESULT([$APP_MACHINEID_SUPPORT])
 
 AS_IF([test "$APP_MACHINEID_SUPPORT" = "yes"],
       AC_DEFINE([APP_MACHINEID_SUPPORT], 1, [Define to 1 to include code that uses libsystemd machine-id apis.]))
@@ -1107,7 +1107,7 @@ dnl -- Enable blkid wiping functionality
 AC_ARG_ENABLE(blkid_wiping,
 	      AS_HELP_STRING([--disable-blkid_wiping],
 			     [disable libblkid detection of signatures when wiping and use native code instead]),
-	      BLKID_WIPING=$enableval, BLKID_WIPING=maybe)
+	      BLKID_WIPING=$enableval, BLKID_WIPING="maybe")
 
 # TODO: possibly detect right version of blkid with BLKID_SUBLKS_FSINFO support
 #       so lvresize can check detected flag here
@@ -1146,18 +1146,18 @@ AS_IF([test "$BLKID_WIPING" != "no"], [
 	])
 ])
 AC_MSG_CHECKING([whether to enable libblkid detection of signatures when wiping])
-AC_MSG_RESULT($BLKID_WIPING)
+AC_MSG_RESULT([$BLKID_WIPING])
 AC_DEFINE_UNQUOTED(DEFAULT_USE_BLKID_WIPING, [$DEFAULT_USE_BLKID_WIPING],
 		   [Use blkid wiping by default.])
 
 ################################################################################
 dnl -- Enable udev synchronisation
-AC_MSG_CHECKING(whether to enable synchronisation with udev processing)
+AC_MSG_CHECKING([whether to enable synchronisation with udev processing])
 AC_ARG_ENABLE(udev_sync,
 	      AS_HELP_STRING([--enable-udev_sync],
 			     [enable synchronisation with udev processing]),
-	      UDEV_SYNC=$enableval, UDEV_SYNC=no)
-AC_MSG_RESULT($UDEV_SYNC)
+	      UDEV_SYNC=$enableval, UDEV_SYNC="no")
+AC_MSG_RESULT([$UDEV_SYNC])
 
 AS_IF([test "$UDEV_SYNC" = "yes"], [
 	PKG_CHECK_MODULES(UDEV, libudev >= 143, [UDEV_PC="libudev"])
@@ -1169,29 +1169,29 @@ AS_IF([test "$UDEV_SYNC" = "yes"], [
 ])
 
 dnl -- Enable udev rules
-AC_MSG_CHECKING(whether to enable installation of udev rules required for synchronisation)
+AC_MSG_CHECKING([whether to enable installation of udev rules required for synchronisation])
 AC_ARG_ENABLE(udev_rules,
 	      AS_HELP_STRING([--enable-udev_rules],
 			     [install rule files needed for udev synchronisation]),
 	      UDEV_RULES=$enableval, UDEV_RULES=$UDEV_SYNC)
-AC_MSG_RESULT($UDEV_RULES)
+AC_MSG_RESULT([$UDEV_RULES])
 
-AC_MSG_CHECKING(whether to enable executable path detection in udev rules)
+AC_MSG_CHECKING([whether to enable executable path detection in udev rules])
 AC_ARG_ENABLE(udev_rule_exec_detection,
 	      AS_HELP_STRING([--enable-udev-rule-exec-detection],
 			     [enable executable path detection in udev rules]),
-	      UDEV_RULE_EXEC_DETECTION=$enableval, UDEV_RULE_EXEC_DETECTION=no)
-AC_MSG_RESULT($UDEV_RULE_EXEC_DETECTION)
+	      UDEV_RULE_EXEC_DETECTION=$enableval, UDEV_RULE_EXEC_DETECTION="no")
+AC_MSG_RESULT([$UDEV_RULE_EXEC_DETECTION])
 
 dnl -- Check support for built-in blkid against target udev version
 AS_IF([test "$UDEV_RULE" != "no"], [
 	PKG_CHECK_EXISTS([libudev >= 176], [
-		UDEV_HAS_BUILTIN_BLKID=yes
+		UDEV_HAS_BUILTIN_BLKID="yes"
 	], [
-		UDEV_HAS_BUILTIN_BLKID=no
+		UDEV_HAS_BUILTIN_BLKID="no"
 	])
-	AC_MSG_CHECKING(whether udev supports built-in blkid)
-	AC_MSG_RESULT($UDEV_HAS_BUILTIN_BLKID)
+	AC_MSG_CHECKING([whether udev supports built-in blkid])
+	AC_MSG_RESULT([$UDEV_HAS_BUILTIN_BLKID])
 ])
 
 ################################################################################
@@ -1200,7 +1200,7 @@ AC_ARG_ENABLE(units-compat,
 	      AS_HELP_STRING([--enable-units-compat],
 			     [enable output compatibility with old versions that
 			      that do not use KiB-style unit suffixes]),
-	      UNITS_COMPAT=$enableval, UNITS_COMPAT=no)
+	      UNITS_COMPAT=$enableval, UNITS_COMPAT="no")
 
 AS_IF([test "$UNITS_COMPAT" = "yes"], [
 	AC_DEFINE([DEFAULT_SI_UNIT_CONSISTENCY], 0, [Define to 0 to reinstate the pre-2.02.54 handling of unit suffixes.])
@@ -1217,11 +1217,11 @@ AS_IF([test "$DM_IOCTLS" = "yes"],
 
 ################################################################################
 dnl -- Disable O_DIRECT
-AC_MSG_CHECKING(whether to enable O_DIRECT)
+AC_MSG_CHECKING([whether to enable O_DIRECT])
 AC_ARG_ENABLE(o_direct,
 	      AS_HELP_STRING([--disable-o_direct], [disable O_DIRECT]),
 	      ODIRECT=$enableval)
-AC_MSG_RESULT($ODIRECT)
+AC_MSG_RESULT([$ODIRECT])
 
 AS_IF([test "$ODIRECT" = "yes"], [
 	AC_DEFINE([O_DIRECT_SUPPORT], 1, [Define to 1 to enable O_DIRECT support.])
@@ -1229,11 +1229,11 @@ AS_IF([test "$ODIRECT" = "yes"], [
 
 ################################################################################
 dnl -- Enable cmdlib
-AC_MSG_CHECKING(whether to compile liblvm2cmd.so)
+AC_MSG_CHECKING([whether to compile liblvm2cmd.so])
 AC_ARG_ENABLE(cmdlib,
 	      AS_HELP_STRING([--enable-cmdlib], [build shared command library]),
-	      CMDLIB=$enableval, CMDLIB=no)
-AC_MSG_RESULT($CMDLIB)
+	      CMDLIB=$enableval, CMDLIB="no")
+AC_MSG_RESULT([$CMDLIB])
 AC_SUBST([LVM2CMD_LIB])
 AS_IF([test "$CMDLIB" = "yes"], [
 	LVM2CMD_LIB="-llvm2cmd"
@@ -1243,11 +1243,11 @@ AS_IF([test "$CMDLIB" = "yes"], [
 
 ################################################################################
 dnl -- Enable D-Bus service
-AC_MSG_CHECKING(whether to include Python D-Bus support)
+AC_MSG_CHECKING([whether to include Python D-Bus support])
 AC_ARG_ENABLE(dbus-service,
 	      AS_HELP_STRING([--enable-dbus-service], [install D-Bus support]),
-	      BUILD_LVMDBUSD=$enableval, BUILD_LVMDBUSD=no)
-AC_MSG_RESULT($BUILD_LVMDBUSD)
+	      BUILD_LVMDBUSD=$enableval, BUILD_LVMDBUSD="no")
+AC_MSG_RESULT([$BUILD_LVMDBUSD])
 AS_IF([test "$NOTIFYDBUS_SUPPORT" = "yes" && test "BUILD_LVMDBUSD" = "yes"],
       [AC_MSG_WARN([Building D-Bus support without D-Bus notifications.])])
 
@@ -1274,7 +1274,7 @@ AS_IF([test "$BUILD_LVMDBUSD" = "yes"], [
 	PYTHON3_LIBDIRS=`"$PYTHON3_CONFIG" --libs`
 	PYTHON3DIR=$pythondir
 	AS_IF([test "$PYTHON3_BINDINGS" = "yes"], [
-		PYTHON_BINDINGS=yes
+		PYTHON_BINDINGS="yes"
 	])
 
 	# To get this macro, install autoconf-archive package then run autoreconf
@@ -1286,44 +1286,44 @@ AS_IF([test "$BUILD_LVMDBUSD" = "yes"], [
 dnl -- Enable pkg-config
 AC_ARG_ENABLE(pkgconfig,
 	      AS_HELP_STRING([--enable-pkgconfig], [install pkgconfig support]),
-	      PKGCONFIG=$enableval, PKGCONFIG=no)
+	      PKGCONFIG=$enableval, PKGCONFIG="no")
 
 ################################################################################
 dnl -- Enable installation of writable files by user
 AC_ARG_ENABLE(write_install,
 	      AS_HELP_STRING([--enable-write_install],
 			     [install user writable files]),
-	      WRITE_INSTALL=$enableval, WRITE_INSTALL=no)
+	      WRITE_INSTALL=$enableval, WRITE_INSTALL="no")
 
 ################################################################################
 dnl -- Enable fsadm
-AC_MSG_CHECKING(whether to install fsadm)
+AC_MSG_CHECKING([whether to install fsadm])
 AC_ARG_ENABLE(fsadm, AS_HELP_STRING([--disable-fsadm], [disable fsadm]),
 	      FSADM=$enableval)
-AC_MSG_RESULT($FSADM)
+AC_MSG_RESULT([$FSADM])
 
 
 ################################################################################
 dnl -- Enable lvm_import_vdo
-AC_MSG_CHECKING(whether to install lvm_import_vdo)
+AC_MSG_CHECKING([whether to install lvm_import_vdo])
 AC_ARG_ENABLE(lvmimportvdo, AS_HELP_STRING([--disable-lvmimportvdo], [disable lvm_import_vdo]),
 	      LVMIMPORTVDO=$enableval)
-AC_MSG_RESULT($LVMIMPORTVDO)
+AC_MSG_RESULT([$LVMIMPORTVDO])
 
 ################################################################################
 dnl -- Enable blkdeactivate
-AC_MSG_CHECKING(whether to install blkdeactivate)
+AC_MSG_CHECKING([whether to install blkdeactivate])
 AC_ARG_ENABLE(blkdeactivate, AS_HELP_STRING([--disable-blkdeactivate], [disable blkdeactivate]),
 	      BLKDEACTIVATE=$enableval)
-AC_MSG_RESULT($BLKDEACTIVATE)
+AC_MSG_RESULT([$BLKDEACTIVATE])
 
 ################################################################################
 dnl -- enable dmeventd handling
-AC_MSG_CHECKING(whether to use dmeventd)
+AC_MSG_CHECKING([whether to use dmeventd])
 AC_ARG_ENABLE(dmeventd, AS_HELP_STRING([--enable-dmeventd],
 				       [enable the device-mapper event daemon]),
-	      BUILD_DMEVENTD=$enableval, BUILD_DMEVENTD=no)
-AC_MSG_RESULT($BUILD_DMEVENTD)
+	      BUILD_DMEVENTD=$enableval, BUILD_DMEVENTD="no")
+AC_MSG_RESULT([$BUILD_DMEVENTD])
 
 dnl -- dmeventd currently requires internal mirror support
 AS_IF([test "$BUILD_DMEVENTD" = "yes"], [
@@ -1355,9 +1355,9 @@ dnl -- Check for dlopen
 AC_CHECK_LIB(dl, dlopen,
 	     [AC_DEFINE([HAVE_LIBDL], 1, [Define to 1 if dynamic libraries are available.])
 	      DL_LIBS="-ldl"
-	      HAVE_LIBDL=yes],
+	      HAVE_LIBDL="yes"],
 	     [DL_LIBS=
-	      HAVE_LIBDL=no ])
+	      HAVE_LIBDL="no" ])
 
 ################################################################################
 dnl -- Check for shared/static conflicts
@@ -1375,11 +1375,11 @@ AC_CHECK_LIB([pthread], [pthread_mutex_lock],
 
 ################################################################################
 dnl -- Disable selinux
-AC_MSG_CHECKING(whether to enable selinux support)
+AC_MSG_CHECKING([whether to enable selinux support])
 AC_ARG_ENABLE(selinux,
 	      AS_HELP_STRING([--disable-selinux], [disable selinux support]),
 	      SELINUX=$enableval)
-AC_MSG_RESULT($SELINUX)
+AC_MSG_RESULT([$SELINUX])
 
 ################################################################################
 dnl -- Check for selinux
@@ -1410,22 +1410,22 @@ AC_CACHE_CHECK([for BLKZEROOUT in sys/ioctl.h.],
 [#include <sys/ioctl.h>
 #include <linux/fs.h>
 int bar(void) { return ioctl(0, BLKZEROOUT, 0); }]
-	 )], [ac_cv_have_blkzeroout=yes], [ac_cv_have_blkzeroout=no])])
+	 )], [ac_cv_have_blkzeroout="yes"], [ac_cv_have_blkzeroout="no"])])
 
 
 AC_ARG_ENABLE(blkzeroout,
 	      AS_HELP_STRING([--disable-blkzeroout],
 			     [do not use BLKZEROOUT for device zeroing]),
-	      BLKZEROOUT=$enableval, BLKZEROOUT=yes)
+	      BLKZEROOUT=$enableval, BLKZEROOUT="yes")
 
-AC_MSG_CHECKING(whether to use BLKZEROOUT for device zeroing)
+AC_MSG_CHECKING([whether to use BLKZEROOUT for device zeroing])
 AS_IF([test "$BLKZEROOUT" = "yes"], [
 	AC_IF_YES(ac_cv_have_blkzeroout,
 		  AC_DEFINE(HAVE_BLKZEROOUT, 1,
 			    [Define if ioctl BLKZEROOUT can be used for device zeroing.]),
-		  BLKZEROOUT=no)
+		  BLKZEROOUT="no")
 ])
-AC_MSG_RESULT($BLKZEROOUT)
+AC_MSG_RESULT([$BLKZEROOUT])
 
 
 ################################################################################
@@ -1519,11 +1519,11 @@ package as well (which may be called readline-devel or something similar).])
 
 ################################################################################
 dnl -- Internationalisation stuff
-AC_MSG_CHECKING(whether to enable internationalisation)
+AC_MSG_CHECKING([whether to enable internationalisation])
 AC_ARG_ENABLE(nls,
 	      AS_HELP_STRING([--enable-nls], [enable Native Language Support]),
-	      INTL=$enableval, INTL=no)
-AC_MSG_RESULT($INTL)
+	      INTL=$enableval, INTL="no")
+AC_MSG_RESULT([$INTL])
 
 AS_IF([test "$INTL" = "yes"], [
 # FIXME - Move this - can be device-mapper too
@@ -1610,14 +1610,14 @@ dnl -- Ensure additional headers required
 AS_IF([test "$READLINE" = "yes"], [
 	AC_CHECK_HEADERS(readline/readline.h readline/history.h,,hard_bailout)
 ])
-AC_MSG_CHECKING(whether to enable readline)
-AC_MSG_RESULT($READLINE)
+AC_MSG_CHECKING([whether to enable readline])
+AC_MSG_RESULT([$READLINE])
 
 AS_IF([test "$EDITLINE" = "yes"], [
 	AC_CHECK_HEADERS(editline/readline.h,,hard_bailout)
 ])
-AC_MSG_CHECKING(whether to enable editline)
-AC_MSG_RESULT($EDITLINE)
+AC_MSG_CHECKING([whether to enable editline])
+AC_MSG_RESULT([$EDITLINE])
 
 AS_IF([test "$BUILD_CMIRRORD" = "yes"], [
 	AC_CHECK_FUNCS(atexit,,hard_bailout)
@@ -1718,28 +1718,28 @@ AC_DEFINE_UNQUOTED(DEFAULT_SYS_DIR, ["$DEFAULT_SYS_DIR"],
 AC_ARG_WITH(default-profile-subdir,
 	    AS_HELP_STRING([--with-default-profile-subdir=SUBDIR],
 			   [default configuration profile subdir [profile]]),
-	    DEFAULT_PROFILE_SUBDIR=$withval, DEFAULT_PROFILE_SUBDIR=profile)
+	    DEFAULT_PROFILE_SUBDIR=$withval, DEFAULT_PROFILE_SUBDIR="profile")
 AC_DEFINE_UNQUOTED(DEFAULT_PROFILE_SUBDIR, ["$DEFAULT_PROFILE_SUBDIR"],
 		   [Name of default configuration profile subdirectory.])
 
 AC_ARG_WITH(default-archive-subdir,
 	    AS_HELP_STRING([--with-default-archive-subdir=SUBDIR],
 			   [default metadata archive subdir [archive]]),
-	    DEFAULT_ARCHIVE_SUBDIR=$withval, DEFAULT_ARCHIVE_SUBDIR=archive)
+	    DEFAULT_ARCHIVE_SUBDIR=$withval, DEFAULT_ARCHIVE_SUBDIR="archive")
 AC_DEFINE_UNQUOTED(DEFAULT_ARCHIVE_SUBDIR, ["$DEFAULT_ARCHIVE_SUBDIR"],
 		   [Name of default metadata archive subdirectory.])
 
 AC_ARG_WITH(default-backup-subdir,
 	    AS_HELP_STRING([--with-default-backup-subdir=SUBDIR],
 			   [default metadata backup subdir [backup]]),
-	    DEFAULT_BACKUP_SUBDIR=$withval, DEFAULT_BACKUP_SUBDIR=backup)
+	    DEFAULT_BACKUP_SUBDIR=$withval, DEFAULT_BACKUP_SUBDIR="backup")
 AC_DEFINE_UNQUOTED(DEFAULT_BACKUP_SUBDIR, ["$DEFAULT_BACKUP_SUBDIR"],
                    [Name of default metadata backup subdirectory.])
 
 AC_ARG_WITH(default-cache-subdir,
 	    AS_HELP_STRING([--with-default-cache-subdir=SUBDIR],
 			   [default metadata cache subdir [cache]]),
-	    DEFAULT_CACHE_SUBDIR=$withval, DEFAULT_CACHE_SUBDIR=cache)
+	    DEFAULT_CACHE_SUBDIR=$withval, DEFAULT_CACHE_SUBDIR="cache")
 AC_DEFINE_UNQUOTED(DEFAULT_CACHE_SUBDIR, ["$DEFAULT_CACHE_SUBDIR"],
 		   [Name of default metadata cache subdirectory.])
 
@@ -1752,39 +1752,39 @@ AC_ARG_WITH(default-locking-dir,
 	    AS_HELP_STRING([--with-default-locking-dir=DIR],
 			   [default locking directory [autodetect_lock_dir/lvm]]),
 	    DEFAULT_LOCK_DIR=$withval,
-	    [AC_MSG_CHECKING(for default lock directory)
+	    [AC_MSG_CHECKING([for default lock directory])
 	     DEFAULT_LOCK_DIR="$DEFAULT_SYS_LOCK_DIR/lvm"
-	     AC_MSG_RESULT($DEFAULT_LOCK_DIR)])
+	     AC_MSG_RESULT([$DEFAULT_LOCK_DIR])])
 AC_DEFINE_UNQUOTED(DEFAULT_LOCK_DIR, ["$DEFAULT_LOCK_DIR"],
 		   [Name of default locking directory.])
 
 ################################################################################
 dnl -- which kernel interface to use (ioctl only)
-AC_MSG_CHECKING(for kernel interface choice)
+AC_MSG_CHECKING([for kernel interface choice])
 AC_ARG_WITH(interface,
 	    AS_HELP_STRING([--with-interface=IFACE],
 			   [choose kernel interface (ioctl) [ioctl]]),
-	    interface=$withval, interface=ioctl)
-test "$interface" != ioctl && AC_MSG_ERROR([--with-interface=ioctl required. fs no longer supported.])
-AC_MSG_RESULT($interface)
+	    interface=$withval, interface="ioctl")
+test "$interface" != "ioctl" && AC_MSG_ERROR([--with-interface=ioctl required. fs no longer supported.])
+AC_MSG_RESULT([$interface])
 
 ################################################################################
-read DM_LIB_VERSION < "$srcdir"/VERSION_DM 2>/dev/null || DM_LIB_VERSION=Unknown
+read DM_LIB_VERSION < "$srcdir"/VERSION_DM 2>/dev/null || DM_LIB_VERSION="Unknown"
 AC_DEFINE_UNQUOTED(DM_LIB_VERSION, "$DM_LIB_VERSION", [Library version])
 
-DM_LIB_PATCHLEVEL=`cat "$srcdir"/VERSION_DM | $AWK -F '[[-. ]]' '{printf "%s.%s.%s",$1,$2,$3}'`
+DM_LIB_PATCHLEVEL=$(cat "$srcdir"/VERSION_DM | $AWK -F '[[-. ]]' '{printf "%s.%s.%s",$1,$2,$3}')
 
 read VER < "$srcdir"/VERSION 2>/dev/null || VER=Unknown
 
 LVM_VERSION=\"$VER\"
-LVM_RELEASE_DATE="\"`echo $VER | $SED 's/.* (//;s/).*//'`\""
-VER=`echo "$VER" | $AWK '{print $1}'`
-LVM_RELEASE="\"`echo "$VER" | $AWK -F '-' '{print $2}'`\""
-VER=`echo "$VER" | $AWK -F '-' '{print $1}'`
-LVM_MAJOR=`echo "$VER" | $AWK -F '.' '{print $1}'`
-LVM_MINOR=`echo "$VER" | $AWK -F '.' '{print $2}'`
-LVM_PATCHLEVEL=`echo "$VER" | $AWK -F '[[(.]]' '{print $3}'`
-LVM_LIBAPI=`echo "$VER" | $AWK -F '[[()]]' '{print $2}'`
+LVM_RELEASE_DATE="\"$(echo $VER | $SED 's/.* (//;s/).*//')\""
+VER=$(echo "$VER" | $AWK '{print $1}')
+LVM_RELEASE="\"$(echo "$VER" | $AWK -F '-' '{print $2}')\""
+VER=$(echo "$VER" | $AWK -F '-' '{print $1}')
+LVM_MAJOR=$(echo "$VER" | $AWK -F '.' '{print $1}')
+LVM_MINOR=$(echo "$VER" | $AWK -F '.' '{print $2}')
+LVM_PATCHLEVEL=$(echo "$VER" | $AWK -F '[[(.]]' '{print $3}')
+LVM_LIBAPI=$(echo "$VER" | $AWK -F '[[()]]' '{print $2}')
 
 AC_DEFINE_UNQUOTED(LVM_CONFIGURE_LINE, "$CONFIGURE_LINE", [configure command line used])
 
@@ -2041,5 +2041,5 @@ AS_IF([test -n "$VDO_CONFIGURE_WARN"],
 AS_IF([test -n "$LVM_NEEDS_LIBAIO_WARN"],
       [AC_MSG_WARN([Only libdm part can be build without libaio:  make [[install_]]device-mapper])])
 
-AS_IF([test "$ODIRECT" != yes],
+AS_IF([test "$ODIRECT" != "yes"],
       [AC_MSG_WARN([O_DIRECT disabled: low-memory pvmove may lock up])])

