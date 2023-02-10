From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Feb 2023 16:53:20 +0000 (GMT)
Subject: main - configure.ac: only use `AS_IF` for conditional blocks
Message-ID: <20230210165320.0C00F385840D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=583cb699cfc76237c5daf1165f599af05c4295dd
Commit:        583cb699cfc76237c5daf1165f599af05c4295dd
Parent:        d456c1f3c509f8a033f3ec5830caaf44e830b644
Author:        David Seifert <soap@gentoo.org>
AuthorDate:    Sun Nov 27 15:35:06 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 10 17:50:27 2023 +0100

configure.ac: only use `AS_IF` for conditional blocks

`AS_IF([...])` is more portable, as it respects macro expansions of
`AC_REQUIRE()`.

This is recommended Autoconf best practice, since in nested
conditionals, it is generally unknowable whether some macro invokes
`AC_REQUIRE()` deep down:
https://www.gnu.org/software/autoconf/manual/autoconf-2.71/html_node/Common-Shell-Constructs.html#index-AS_005fIF-1

As a result, the hacky `pkg_config_init` function is not needed
anymore, since any `PKG_*` invocation will ensure that
`PKG_PROG_PKG_CONFIG` will have been called, due to the fact that
`AC_REQUIRE()` will trickle up.
---
 configure.ac | 476 +++++++++++++++++++++++++++++------------------------------
 1 file changed, 237 insertions(+), 239 deletions(-)

diff --git a/configure.ac b/configure.ac
index f2cf48d8e..b29e676bb 100644
--- a/configure.ac
+++ b/configure.ac
@@ -415,62 +415,62 @@ AC_ARG_ENABLE(thin_check_needs_check,
 case "$THIN" in
   internal|shared)
 	# Empty means a config way to ignore thin checking
-	if test "$THIN_CHECK_CMD" = "autodetect"; then
+	AS_IF([test "$THIN_CHECK_CMD" = "autodetect"], [
 		AC_PATH_TOOL(THIN_CHECK_CMD, thin_check, [], [$PATH_SBIN])
-		if test -z "$THIN_CHECK_CMD"; then
+		AS_IF([test -z "$THIN_CHECK_CMD"], [
 			AC_MSG_WARN([thin_check not found in path $PATH])
 			THIN_CHECK_CMD=/usr/sbin/thin_check
 			THIN_CONFIGURE_WARN=y
-		fi
-	fi
-	if test "$THIN_CHECK_NEEDS_CHECK" = yes && test "$THIN_CONFIGURE_WARN" != y ; then
+		])
+	])
+	AS_IF([test "$THIN_CHECK_NEEDS_CHECK" = "yes" && test "$THIN_CONFIGURE_WARN" != "y"], [
 		THIN_CHECK_VSN=`"$THIN_CHECK_CMD" -V 2>/dev/null`
 		THIN_CHECK_VSN_MAJOR=`echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $1}'`
 		THIN_CHECK_VSN_MINOR=`echo "$THIN_CHECK_VSN" | $AWK -F '.' '{print $2}'`
 
-		if test -z "$THIN_CHECK_VSN_MAJOR" || test -z "$THIN_CHECK_VSN_MINOR"; then
+		AS_IF([test -z "$THIN_CHECK_VSN_MAJOR" || test -z "$THIN_CHECK_VSN_MINOR"], [
 			AC_MSG_WARN([$THIN_CHECK_CMD: Bad version "$THIN_CHECK_VSN" found])
 			THIN_CHECK_VERSION_WARN=y
 			THIN_CHECK_NEEDS_CHECK=no
-		elif test "$THIN_CHECK_VSN_MAJOR" -eq 0 && test "$THIN_CHECK_VSN_MINOR" -lt 3; then
+		], [test "$THIN_CHECK_VSN_MAJOR" -eq 0 && test "$THIN_CHECK_VSN_MINOR" -lt 3], [
 			AC_MSG_WARN([$THIN_CHECK_CMD: Old version "$THIN_CHECK_VSN" found])
 			THIN_CHECK_VERSION_WARN=y
 			THIN_CHECK_NEEDS_CHECK=no
-		fi
-	fi
+		])
+	])
 	# Empty means a config way to ignore thin dumping
-	if test "$THIN_DUMP_CMD" = "autodetect"; then
+	AS_IF([test "$THIN_DUMP_CMD" = "autodetect"], [
 		AC_PATH_TOOL(THIN_DUMP_CMD, thin_dump, [], [$PATH_SBIN])
-		test -z "$THIN_DUMP_CMD" && {
+		AS_IF([test -z "$THIN_DUMP_CMD"], [
 			AC_MSG_WARN(thin_dump not found in path $PATH)
 			THIN_DUMP_CMD=/usr/sbin/thin_dump
 			THIN_CONFIGURE_WARN=y
-		}
-	fi
+		])
+	])
 	# Empty means a config way to ignore thin repairing
-	if test "$THIN_REPAIR_CMD" = "autodetect"; then
+	AS_IF([test "$THIN_REPAIR_CMD" = "autodetect"], [
 		AC_PATH_TOOL(THIN_REPAIR_CMD, thin_repair, [], [$PATH_SBIN])
-		test -z "$THIN_REPAIR_CMD" && {
+		AS_IF([test -z "$THIN_REPAIR_CMD"], [
 			AC_MSG_WARN(thin_repair not found in path $PATH)
 			THIN_REPAIR_CMD=/usr/sbin/thin_repair
 			THIN_CONFIGURE_WARN=y
-		}
-	fi
+		])
+	])
 	# Empty means a config way to ignore thin restoring
-	if test "$THIN_RESTORE_CMD" = "autodetect"; then
+	AS_IF([test "$THIN_RESTORE_CMD" = "autodetect"], [
 		AC_PATH_TOOL(THIN_RESTORE_CMD, thin_restore, [], [$PATH_SBIN])
-		test -z "$THIN_RESTORE_CMD" && {
+		AS_IF([test -z "$THIN_RESTORE_CMD"], [
 			AC_MSG_WARN(thin_restore not found in path $PATH)
 			THIN_RESTORE_CMD=/usr/sbin/thin_restore
 			THIN_CONFIGURE_WARN=y
-		}
-	fi
+		])
+	])
 
 	AC_MSG_CHECKING([whether thin_check supports the needs-check flag])
 	AC_MSG_RESULT([$THIN_CHECK_NEEDS_CHECK])
-	if test "$THIN_CHECK_NEEDS_CHECK" = yes; then
+	AS_IF([test "$THIN_CHECK_NEEDS_CHECK" = "yes"], [
 		AC_DEFINE([THIN_CHECK_NEEDS_CHECK], 1, [Define to 1 if the external 'thin_check' tool requires the --clear-needs-check-flag option])
-	fi
+	])
 	;;
 esac
 
@@ -528,73 +528,73 @@ AC_ARG_ENABLE(cache_check_needs_check,
 case "$CACHE" in
   internal|shared)
 	# Empty means a config way to ignore cache checking
-	if test "$CACHE_CHECK_CMD" = "autodetect"; then
+	AS_IF([test "$CACHE_CHECK_CMD" = "autodetect"], [
 		AC_PATH_TOOL(CACHE_CHECK_CMD, cache_check, [], [$PATH_SBIN])
-		if test -z "$CACHE_CHECK_CMD"; then
+		AS_IF([test -z "$CACHE_CHECK_CMD"], [
 			AC_MSG_WARN([cache_check not found in path $PATH])
 			CACHE_CHECK_CMD=/usr/sbin/cache_check
 			CACHE_CONFIGURE_WARN=y
-		fi
-	fi
-	if test "$CACHE_CHECK_NEEDS_CHECK" = yes && test "$CACHE_CONFIGURE_WARN" != y ; then
+		])
+	])
+	AS_IF([test "$CACHE_CHECK_NEEDS_CHECK" = "yes" && test "$CACHE_CONFIGURE_WARN" != "y"], [
 		$CACHE_CHECK_CMD -V 2>/dev/null >conftest.tmp
 		read -r CACHE_CHECK_VSN < conftest.tmp
 		IFS=.- read -r CACHE_CHECK_VSN_MAJOR CACHE_CHECK_VSN_MINOR CACHE_CHECK_VSN_PATCH LEFTOVER < conftest.tmp
 		rm -f conftest.tmp
 
 		# Require version >= 0.5.4 for --clear-needs-check-flag
-		if test -z "$CACHE_CHECK_VSN_MAJOR" \
+		AS_IF([test -z "$CACHE_CHECK_VSN_MAJOR" \
 			|| test -z "$CACHE_CHECK_VSN_MINOR" \
-			|| test -z "$CACHE_CHECK_VSN_PATCH"; then
+			|| test -z "$CACHE_CHECK_VSN_PATCH"], [
 			AC_MSG_WARN([$CACHE_CHECK_CMD: Bad version "$CACHE_CHECK_VSN" found])
 			CACHE_CHECK_VERSION_WARN=y
 			CACHE_CHECK_NEEDS_CHECK=no
-		elif test "$CACHE_CHECK_VSN_MAJOR" -eq 0 ; then
-			if test "$CACHE_CHECK_VSN_MINOR" -lt 5 \
-				|| ( test "$CACHE_CHECK_VSN_MINOR" -eq 5 && test "$CACHE_CHECK_VSN_PATCH" -lt 4 ); then
+		], [test "$CACHE_CHECK_VSN_MAJOR" -eq 0], [
+			AS_IF([test "$CACHE_CHECK_VSN_MINOR" -lt 5 \
+				|| ( test "$CACHE_CHECK_VSN_MINOR" -eq 5 && test "$CACHE_CHECK_VSN_PATCH" -lt 4 )], [
 				AC_MSG_WARN([$CACHE_CHECK_CMD: Old version "$CACHE_CHECK_VSN" found])
 				CACHE_CHECK_VERSION_WARN=y
 				CACHE_CHECK_NEEDS_CHECK=no
-			fi
-			if test "$CACHE_CHECK_VSN_MINOR" -lt 7 ; then
+			])
+			AS_IF([test "$CACHE_CHECK_VSN_MINOR" -lt 7], [
 				AC_MSG_WARN([$CACHE_CHECK_CMD: Old version "$CACHE_CHECK_VSN" does not support new cache format V2])
 				CACHE_CHECK_VERSION_WARN=y
-			fi
-		fi
-	fi
+			])
+		])
+	])
 	# Empty means a config way to ignore cache dumping
-	if test "$CACHE_DUMP_CMD" = "autodetect"; then
+	AS_IF([test "$CACHE_DUMP_CMD" = "autodetect"], [
 		AC_PATH_TOOL(CACHE_DUMP_CMD, cache_dump, [], [$PATH_SBIN])
-		test -z "$CACHE_DUMP_CMD" && {
+		AS_IF([test -z "$CACHE_DUMP_CMD"], [
 			AC_MSG_WARN(cache_dump not found in path $PATH)
 			CACHE_DUMP_CMD=/usr/sbin/cache_dump
 			CACHE_CONFIGURE_WARN=y
-		}
-	fi
+		])
+	])
 	# Empty means a config way to ignore cache repairing
-	if test "$CACHE_REPAIR_CMD" = "autodetect"; then
+	AS_IF([test "$CACHE_REPAIR_CMD" = "autodetect"], [
 		AC_PATH_TOOL(CACHE_REPAIR_CMD, cache_repair, [], [$PATH_SBIN])
-		test -z "$CACHE_REPAIR_CMD" && {
+		AS_IF([test -z "$CACHE_REPAIR_CMD"], [
 			AC_MSG_WARN(cache_repair not found in path $PATH)
 			CACHE_REPAIR_CMD=/usr/sbin/cache_repair
 			CACHE_CONFIGURE_WARN=y
-		}
-	fi
+		])
+	])
 	# Empty means a config way to ignore cache restoring
-	if test "$CACHE_RESTORE_CMD" = "autodetect"; then
+	AS_IF([test "$CACHE_RESTORE_CMD" = "autodetect"], [
 		AC_PATH_TOOL(CACHE_RESTORE_CMD, cache_restore, [], [$PATH_SBIN])
-		test -z "$CACHE_RESTORE_CMD" && {
+		AS_IF([test -z "$CACHE_RESTORE_CMD"], [
 			AC_MSG_WARN(cache_restore not found in path $PATH)
 			CACHE_RESTORE_CMD=/usr/sbin/cache_restore
 			CACHE_CONFIGURE_WARN=y
-		}
-	fi
+		])
+	])
 
 	AC_MSG_CHECKING([whether cache_check supports the needs-check flag])
 	AC_MSG_RESULT([$CACHE_CHECK_NEEDS_CHECK])
-	if test "$CACHE_CHECK_NEEDS_CHECK" = yes; then
+	AS_IF([test "$CACHE_CHECK_NEEDS_CHECK" = "yes"], [
 		AC_DEFINE([CACHE_CHECK_NEEDS_CHECK], 1, [Define to 1 if the external 'cache_check' tool requires the --clear-needs-check-flag option])
-	fi
+	])
 	;;
 esac
 
@@ -628,14 +628,14 @@ case "$VDO" in
  no|none) ;;
  internal)
 	AC_DEFINE([VDO_INTERNAL], 1, [Define to 1 to include built-in support for vdo.])
-	if test "$VDO_FORMAT_CMD" = "autodetect"; then
+	AS_IF([test "$VDO_FORMAT_CMD" = "autodetect"], [
 		AC_PATH_TOOL(VDO_FORMAT_CMD, vdoformat, [], [$PATH])
-		if test -z "$VDO_FORMAT_CMD"; then
+		AS_IF([test -z "$VDO_FORMAT_CMD"], [
 			AC_MSG_WARN([vdoformat not found in path $PATH])
 			VDO_FORMAT_CMD=/usr/bin/vdoformat
 			VDO_CONFIGURE_WARN=y
-		fi
-	fi
+		])
+	])
 	;;
  *) AC_MSG_ERROR([--with-vdo parameter invalid]) ;;
 esac
@@ -735,19 +735,6 @@ AC_ARG_WITH(ocfdir,
 			   [install OCF files in [PREFIX/lib/ocf/resource.d/lvm2]]),
 	    OCFDIR=$withval, OCFDIR='${prefix}/lib/ocf/resource.d/lvm2')
 
-################################################################################
-dnl -- Init pkg-config with dummy invokation:
-dnl -- this is required because PKG_CHECK_MODULES macro is expanded
-dnl -- to initialize the pkg-config environment only at the first invokation,
-dnl -- that would be conditional in this configure.in.
-pkg_config_init() {
-	if test "$PKGCONFIG_INIT" != 1; then
-		PKG_CHECK_MODULES(PKGCONFIGINIT, pkgconfiginit, [],
-				  [AC_MSG_RESULT([pkg-config initialized])])
-		PKGCONFIG_INIT=1
-	fi
-}
-
 ################################################################################
 AC_MSG_CHECKING(for default run directory)
 RUN_DIR="/run"
@@ -791,7 +778,7 @@ BUILD_CMIRRORD=$CMIRRORD
 
 ################################################################################
 dnl -- cmirrord pidfile
-if test "$BUILD_CMIRRORD" = yes; then
+AS_IF([test "$BUILD_CMIRRORD" = "yes"], [
 	AC_ARG_WITH(cmirrord-pidfile,
 		    AS_HELP_STRING([--with-cmirrord-pidfile=PATH],
 				   [cmirrord pidfile [PID_DIR/cmirrord.pid]]),
@@ -799,17 +786,13 @@ if test "$BUILD_CMIRRORD" = yes; then
 		    CMIRRORD_PIDFILE="$DEFAULT_PID_DIR/cmirrord.pid")
 	AC_DEFINE_UNQUOTED(CMIRRORD_PIDFILE, ["$CMIRRORD_PIDFILE"],
 			   [Path to cmirrord pidfile.])
-fi
+])
 
 ################################################################################
 dnl -- Look for corosync libraries if required.
-if test "$BUILD_CMIRRORD" = yes; then
-	pkg_config_init
-
-	if test "$HAVE_CPG" != yes; then
-		PKG_CHECK_MODULES(CPG, libcpg)
-	fi
-fi
+AS_IF([test "$BUILD_CMIRRORD" = "yes" && test "$HAVE_CPG" != "yes"], [
+	PKG_CHECK_MODULES([CPG], [libcpg])
+])
 
 ################################################################################
 dnl -- Enable debugging
@@ -819,11 +802,7 @@ AC_ARG_ENABLE(debug, AS_HELP_STRING([--enable-debug], [enable debugging]),
 AC_MSG_RESULT($DEBUG)
 
 dnl -- Normally turn off optimisation for debug builds
-if test "$DEBUG" = yes; then
-	COPTIMISE_FLAG=
-else
-	CSCOPE_CMD=
-fi
+AS_IF([test "$DEBUG" = "yes"], [COPTIMISE_FLAG=""], [CSCOPE_CMD=""])
 
 dnl -- Check if compiler supports -Wjump-misses-init
 AC_TRY_CCFLAG([-Wjump-misses-init], [HAVE_WJUMP], [], [])
@@ -854,7 +833,7 @@ AC_ARG_WITH(symvers,
 			     esac], symvers=gnu)
 AC_MSG_RESULT($symvers)
 
-if test "$GCC" = "yes" && test "$symvers" = "gnu" ; then
+AS_IF([test "$GCC" = "yes" && test "$symvers" = "gnu"], [
 	AC_DEFINE(GNU_SYMVER, 1,
 		  [Define to use GNU versioning in the shared library.])
 		   case "$host_os" in
@@ -863,7 +842,7 @@ if test "$GCC" = "yes" && test "$symvers" = "gnu" ; then
 			LDDEPS="$LDDEPS .export.sym"
 			;;
 		   esac
-fi
+])
 
 ################################################################################
 dnl -- Enable profiling
@@ -874,24 +853,26 @@ AC_ARG_ENABLE(profiling,
 	      PROFILING=$enableval, PROFILING=no)
 AC_MSG_RESULT($PROFILING)
 
-if test "$PROFILING" = yes; then
+AS_IF([test "$PROFILING" = "yes"], [
   COPTIMISE_FLAG="$COPTIMISE_FLAG -fprofile-arcs -ftest-coverage"
   AC_PATH_TOOL(LCOV, lcov)
   AC_PATH_TOOL(GENHTML, genhtml)
-  test -z "$LCOV" -o -z "$GENHTML" && AC_MSG_ERROR([lcov and genhtml are required for profiling])
+  AS_IF([test -z "$LCOV" || test -z "$GENHTML"], [
+    AC_MSG_ERROR([lcov and genhtml are required for profiling])
+  ])
   AC_PATH_TOOL(GENPNG, genpng)
-  if test -n "$GENPNG"; then
+  AS_IF([test -n "$GENPNG"], [
     AC_MSG_CHECKING([whether $GENPNG has all required modules])
-    if "$GENPNG" --help > /dev/null 2>&1 ; then
+    AS_IF(["$GENPNG" --help > /dev/null 2>&1], [
       AC_MSG_RESULT(ok)
       GENHTML="$GENHTML --frames"
-    else
+    ], [
       AC_MSG_RESULT([not supported])
       AC_MSG_WARN([GD.pm perl module is not installed])
       GENPNG=
-    fi
-  fi
-fi
+    ])
+  ])
+])
 
 ################################################################################
 dnl -- Set LVM2 testsuite data
@@ -908,17 +889,18 @@ AC_ARG_ENABLE(valgrind_pool,
 	      VALGRIND_POOL=$enableval, VALGRIND_POOL=no)
 AC_MSG_RESULT($VALGRIND_POOL)
 
-pkg_config_init
-PKG_CHECK_MODULES(VALGRIND, valgrind, [HAVE_VALGRIND=yes], [if test x$VALGRIND_POOL = xyes; then AC_MSG_ERROR(bailing out); fi])
+PKG_CHECK_MODULES(VALGRIND, valgrind, [HAVE_VALGRIND=yes], [
+  AS_IF([test "$VALGRIND_POOL" = "yes"], [AC_MSG_ERROR(bailing out)])
+])
 AC_SUBST(VALGRIND_CFLAGS)
 
-if test x$HAVE_VALGRIND = xyes; then
+AS_IF([test "$HAVE_VALGRIND" = "yes"], [
 	AC_DEFINE([HAVE_VALGRIND], 1, [valgrind.h found])
-fi
+])
 
-if test x$VALGRIND_POOL = xyes; then
+AS_IF([test "$VALGRIND_POOL" = "yes"], [
 	AC_DEFINE([VALGRIND_POOL], 1, [Enable a valgrind aware build of pool])
-fi
+])
 
 ################################################################################
 dnl -- Disable devmapper
@@ -929,9 +911,9 @@ AC_ARG_ENABLE(devmapper,
 	      DEVMAPPER=$enableval)
 AC_MSG_RESULT($DEVMAPPER)
 
-if test "$DEVMAPPER" = yes; then
+AS_IF([test "$DEVMAPPER" = "yes"], [
 	AC_DEFINE([DEVMAPPER_SUPPORT], 1, [Define to 1 to enable LVM2 device-mapper interaction.])
-fi
+])
 
 ################################################################################
 dnl -- Build lvmpolld
@@ -957,11 +939,11 @@ AC_MSG_RESULT($LOCKDSANLOCK)
 BUILD_LOCKDSANLOCK=$LOCKDSANLOCK
 
 dnl -- Look for sanlock libraries
-if test "$BUILD_LOCKDSANLOCK" = yes; then
+AS_IF([test "$BUILD_LOCKDSANLOCK" = "yes"], [
 	PKG_CHECK_MODULES(LOCKD_SANLOCK, libsanlock_client >= 3.3.0, [HAVE_LOCKD_SANLOCK=yes], $bailout)
 	AC_DEFINE([LOCKDSANLOCK_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd sanlock option.])
 	BUILD_LVMLOCKD=yes
-fi
+])
 
 ################################################################################
 dnl -- Build lvmlockddlm
@@ -975,11 +957,11 @@ AC_MSG_RESULT($LOCKDDLM)
 BUILD_LOCKDDLM=$LOCKDDLM
 
 dnl -- Look for dlm libraries
-if test "$BUILD_LOCKDDLM" = yes; then
+AS_IF([test "$BUILD_LOCKDDLM" = "yes"], [
 	PKG_CHECK_MODULES(LOCKD_DLM, libdlm, [HAVE_LOCKD_DLM=yes], $bailout)
 	AC_DEFINE([LOCKDDLM_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd dlm option.])
 	BUILD_LVMLOCKD=yes
-fi
+])
 
 ################################################################################
 dnl -- Build lvmlockddlmcontrol
@@ -993,11 +975,11 @@ AC_MSG_RESULT($LOCKDDLM_CONTROL)
 BUILD_LOCKDDLM_CONTROL=$LOCKDDLM_CONTROL
 
 dnl -- Look for libdlmcontrol libraries
-if test "$BUILD_LOCKDDLM_CONTROL" = yes; then
+AS_IF([test "$BUILD_LOCKDDLM_CONTROL" = "yes"], [
 	PKG_CHECK_MODULES(LOCKD_DLM_CONTROL, libdlmcontrol >= 3.2, [HAVE_LOCKD_DLM_CONTROL=yes], $bailout)
 	AC_DEFINE([LOCKDDLM_CONTROL_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd dlm control option.])
 	BUILD_LVMLOCKD=yes
-fi
+])
 
 ################################################################################
 dnl -- Build lvmlockdidm
@@ -1011,21 +993,21 @@ AC_MSG_RESULT($LOCKDIDM)
 BUILD_LOCKDIDM=$LOCKDIDM
 
 dnl -- Look for Seagate IDM libraries
-if test "$BUILD_LOCKDIDM" = yes; then
+AS_IF([test "$BUILD_LOCKDIDM" = "yes"], [
 	PKG_CHECK_MODULES(LOCKD_IDM, libseagate_ilm >= 0.1.0, [HAVE_LOCKD_IDM=yes], $bailout)
 	PKG_CHECK_EXISTS(blkid >= 2.24, [HAVE_LOCKD_IDM=yes], $bailout)
 	AC_DEFINE([LOCKDIDM_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd IDM option.])
 	BUILD_LVMLOCKD=yes
-fi
+])
 
 ################################################################################
 dnl -- Build lvmlockd
 AC_MSG_CHECKING(whether to build lvmlockd)
 AC_MSG_RESULT($BUILD_LVMLOCKD)
 
-if test "$BUILD_LVMLOCKD" = yes; then
-	AS_IF([test "$LVMPOLLD" = no], [AC_MSG_ERROR([cannot build lvmlockd with --disable-lvmpolld.])])
-	AS_IF([test "$BUILD_LVMPOLLD" = no], [BUILD_LVMPOLLD=yes; AC_MSG_WARN([Enabling lvmpolld - required by lvmlockd.])])
+AS_IF([test "$BUILD_LVMLOCKD" = "yes"], [
+	AS_IF([test "$LVMPOLLD" = "no"], [AC_MSG_ERROR([cannot build lvmlockd with --disable-lvmpolld.])])
+	AS_IF([test "$BUILD_LVMPOLLD" = "no"], [BUILD_LVMPOLLD=yes; AC_MSG_WARN([Enabling lvmpolld - required by lvmlockd.])])
 	AC_MSG_CHECKING([defaults for use_lvmlockd])
 	AC_ARG_ENABLE(use_lvmlockd,
 		      AS_HELP_STRING([--disable-use-lvmlockd],
@@ -1044,15 +1026,15 @@ if test "$BUILD_LVMLOCKD" = yes; then
 		    LVMLOCKD_PIDFILE="$DEFAULT_PID_DIR/lvmlockd.pid")
 	AC_DEFINE_UNQUOTED(LVMLOCKD_PIDFILE, ["$LVMLOCKD_PIDFILE"],
 			   [Path to lvmlockd pidfile.])
-else
+], [
 	DEFAULT_USE_LVMLOCKD=0
-fi
+])
 AC_DEFINE_UNQUOTED(DEFAULT_USE_LVMLOCKD, [$DEFAULT_USE_LVMLOCKD],
 		   [Use lvmlockd by default.])
 
 ################################################################################
 dnl -- Check lvmpolld
-if test "$BUILD_LVMPOLLD" = yes; then
+AS_IF([test "$BUILD_LVMPOLLD" = "yes"], [
 	AC_MSG_CHECKING([defaults for use_lvmpolld])
 	AC_ARG_ENABLE(use_lvmpolld,
 		      AS_HELP_STRING([--disable-use-lvmpolld],
@@ -1071,9 +1053,9 @@ if test "$BUILD_LVMPOLLD" = yes; then
 		    LVMPOLLD_PIDFILE="$DEFAULT_PID_DIR/lvmpolld.pid")
 	AC_DEFINE_UNQUOTED(LVMPOLLD_PIDFILE, ["$LVMPOLLD_PIDFILE"],
 			   [Path to lvmpolld pidfile.])
-else
+], [
 	DEFAULT_USE_LVMPOLLD=0
-fi
+])
 AC_DEFINE_UNQUOTED(DEFAULT_USE_LVMPOLLD, [$DEFAULT_USE_LVMPOLLD],
 		   [Use lvmpolld by default.])
 
@@ -1087,12 +1069,11 @@ AC_MSG_RESULT($BUILD_DMFILEMAPD)
 AC_DEFINE([DMFILEMAPD], $BUILD_DMFILEMAPD, [Define to 1 to enable the device-mapper filemap daemon.])
 
 dnl -- dmfilemapd requires FIEMAP
-if test "$BUILD_DMFILEMAPD" = yes; then
+AS_IF([test "$BUILD_DMFILEMAPD" = "yes"], [
    AC_CHECK_HEADER([linux/fiemap.h], , [AC_MSG_ERROR(--enable-dmfilemapd requires fiemap.h)])
-fi
+])
 
 SYSTEMD_MIN_VERSION=0
-pkg_config_init
 PKG_CHECK_EXISTS(systemd >= 205, [SYSTEMD_MIN_VERSION=205], [])
 
 ################################################################################
@@ -1102,54 +1083,54 @@ AC_MSG_CHECKING(whether to build notifydbus)
 AC_ARG_ENABLE(notify-dbus,
 	      AS_HELP_STRING([--enable-notify-dbus],
 			     [enable LVM notification using dbus]),
-	      AS_IF([test "$enableval" = yes && test "$SYSTEMD_MIN_VERSION" -lt 221],
+	      AS_IF([test "$enableval" = "yes" && test "$SYSTEMD_MIN_VERSION" -lt 221],
 		    AC_MSG_ERROR([Enabling notify-dbus requires systemd >= 221]))
 	      NOTIFYDBUS_SUPPORT=$enableval, NOTIFYDBUS_SUPPORT=no)
 AC_MSG_RESULT($NOTIFYDBUS_SUPPORT)
 
-AS_IF([test "$NOTIFYDBUS_SUPPORT" = yes],
+AS_IF([test "$NOTIFYDBUS_SUPPORT" = "yes"],
       AC_DEFINE([NOTIFYDBUS_SUPPORT], 1, [Define to 1 to include code that uses dbus notification.]))
 
 ################################################################################
 dnl -- Build with systemd journaling when the header file is present
 AS_IF([test "$SYSTEMD_MIN_VERSION" -ge 221], [SYSTEMD_JOURNAL_SUPPORT=maybe], [SYSTEMD_JOURNAL_SUPPORT=no])
 AC_CHECK_HEADER([systemd/sd-journal.h],
-		[AS_IF([test "$SYSTEMD_JOURNAL_SUPPORT" != no], [SYSTEMD_JOURNAL_SUPPORT=yes])],
+		[AS_IF([test "$SYSTEMD_JOURNAL_SUPPORT" != "no"], [SYSTEMD_JOURNAL_SUPPORT=yes])],
                 [SYSTEMD_JOURNAL_SUPPORT=no])
 AC_MSG_CHECKING(whether to log to systemd journal)
 AC_ARG_ENABLE(systemd-journal,
 	      AS_HELP_STRING([--disable-systemd-journal],
 			     [disable LVM systemd journaling]),
-	      AS_IF([test "$enableval" = yes && test "$SYSTEMD_JOURNAL_SUPPORT" = no],
+	      AS_IF([test "$enableval" = "yes" && test "$SYSTEMD_JOURNAL_SUPPORT" = "no"],
 		    AC_MSG_ERROR([Enabling systemd journal requires systemd/sd-journal.h and systemd >= 221.]))
 	      SYSTEMD_JOURNAL_SUPPORT=$enableval, [])
 AC_MSG_RESULT($SYSTEMD_JOURNAL_SUPPORT)
 
-AS_IF([test "$SYSTEMD_JOURNAL_SUPPORT" = yes],
+AS_IF([test "$SYSTEMD_JOURNAL_SUPPORT" = "yes"],
       AC_DEFINE([SYSTEMD_JOURNAL_SUPPORT], 1, [Define to 1 to include code that uses systemd journal.]))
 
 ################################################################################
 dnl -- Build appmachineid when header file sd-id128.h is present
 PKG_CHECK_EXISTS(systemd >= 234, [SYSTEMD_MIN_VERSION=234  APP_MACHINEID_SUPPORT=maybe], [APP_MACHINEID_SUPPORT=no])
 AC_CHECK_HEADER([systemd/sd-id128.h],
-		[AS_IF([test "$APP_MACHINEID_SUPPORT" != no], [APP_MACHINEID_SUPPORT=yes])],
+		[AS_IF([test "$APP_MACHINEID_SUPPORT" != "no"], [APP_MACHINEID_SUPPORT=yes])],
 		[APP_MACHINEID_SUPPORT=no])
 AC_MSG_CHECKING(whether to support systemd appmachineid)
 AC_ARG_ENABLE(app-machineid,
 	      AS_HELP_STRING([--disable-app-machineid],
 			     [disable LVM system ID using app-specific machine-id]),
-	      AS_IF([test "$enableval" = yes && test "$APP_MACHINEID_SUPPORT" = no],
+	      AS_IF([test "$enableval" = "yes" && test "$APP_MACHINEID_SUPPORT" = "no"],
 		    AC_MSG_ERROR([Enabling app machineid requires systemd/sd-id128.h and systemd >= 234.]))
 	      APP_MACHINEID_SUPPORT=$enableval, [])
 AC_MSG_RESULT($APP_MACHINEID_SUPPORT)
 
-AS_IF([test "$APP_MACHINEID_SUPPORT" = yes],
+AS_IF([test "$APP_MACHINEID_SUPPORT" = "yes"],
       AC_DEFINE([APP_MACHINEID_SUPPORT], 1, [Define to 1 to include code that uses libsystemd machine-id apis.]))
 
 dnl -- Look for libsystemd libraries if needed
-AS_IF([test "$NOTIFYDBUS_SUPPORT" = yes || test "$SYSTEMD_JOURNAL_SUPPORT" = yes || test "$APP_MACHINEID_SUPPORT" = yes ] ,[
-      pkg_config_init
-      PKG_CHECK_MODULES(SYSTEMD, [systemd], [SYSTEMD_LIBS="-lsystemd"], $bailout) ])
+AS_IF([test "$NOTIFYDBUS_SUPPORT" = "yes" || test "$SYSTEMD_JOURNAL_SUPPORT" = "yes" || test "$APP_MACHINEID_SUPPORT" = "yes"], [
+	PKG_CHECK_MODULES(SYSTEMD, [systemd], [SYSTEMD_LIBS="-lsystemd"], $bailout)
+])
 
 ################################################################################
 
@@ -1160,19 +1141,20 @@ AC_ARG_ENABLE(blkid_wiping,
 	      BLKID_WIPING=$enableval, BLKID_WIPING=maybe)
 
 DEFAULT_USE_BLKID_WIPING=0
-if test "$BLKID_WIPING" != no; then
-	pkg_config_init
-	PKG_CHECK_MODULES(BLKID, blkid >= 2.24,
-			  [ BLKID_WIPING=yes
-			    BLKID_PC="blkid"
-			    DEFAULT_USE_BLKID_WIPING=1
-			    AC_DEFINE([BLKID_WIPING_SUPPORT], 1, [Define to 1 to use libblkid detection of signatures when wiping.])
-			  ], [if test "$BLKID_WIPING" = maybe; then
-				BLKID_WIPING=no
-			   else
-			        AC_MSG_ERROR([bailing out... blkid library >= 2.24 is required])
-			   fi])
-fi
+AS_IF([test "$BLKID_WIPING" != "no"], [
+	PKG_CHECK_MODULES([BLKID], [blkid >= 2.24], [
+		BLKID_WIPING=yes
+		BLKID_PC="blkid"
+		DEFAULT_USE_BLKID_WIPING=1
+		AC_DEFINE([BLKID_WIPING_SUPPORT], 1, [Define to 1 to use libblkid detection of signatures when wiping.])
+	], [
+		AS_IF([test "$BLKID_WIPING" = "maybe"], [
+			BLKID_WIPING=no
+		], [
+			AC_MSG_ERROR([bailing out... blkid library >= 2.24 is required])
+		])
+	])
+])
 AC_MSG_CHECKING([whether to enable libblkid detection of signatures when wiping])
 AC_MSG_RESULT($BLKID_WIPING)
 AC_DEFINE_UNQUOTED(DEFAULT_USE_BLKID_WIPING, [$DEFAULT_USE_BLKID_WIPING],
@@ -1187,13 +1169,17 @@ AC_ARG_ENABLE(udev-systemd-background-jobs,
 	      UDEV_SYSTEMD_BACKGROUND_JOBS=$enableval,
 	      UDEV_SYSTEMD_BACKGROUND_JOBS=maybe)
 
-if test "$UDEV_SYSTEMD_BACKGROUND_JOBS" != no; then
-	AS_IF([test "$SYSTEMD_MIN_VERSION" -ge 205],
-	      UDEV_SYSTEMD_BACKGROUND_JOBS=yes,
-	      AS_IF([test "$UDEV_SYSTEMD_BACKGROUND_JOBS" = maybe],
-		     [UDEV_SYSTEMD_BACKGROUND_JOBS=no],
-		     [AC_MSG_ERROR([bailing out... systemd >= 205 is required])]))
-fi
+AS_IF([test "$UDEV_SYSTEMD_BACKGROUND_JOBS" != "no"], [
+	AS_IF([test "$SYSTEMD_MIN_VERSION" -ge 205], [
+		UDEV_SYSTEMD_BACKGROUND_JOBS=yes
+	], [
+		AS_IF([test "$UDEV_SYSTEMD_BACKGROUND_JOBS" = "maybe"], [
+			UDEV_SYSTEMD_BACKGROUND_JOBS=no
+		], [
+			AC_MSG_ERROR([bailing out... systemd >= 205 is required])
+		])
+	])
+])
 
 AC_MSG_CHECKING(whether to use udev-systemd protocol for jobs in background)
 AC_MSG_RESULT($UDEV_SYSTEMD_BACKGROUND_JOBS)
@@ -1207,15 +1193,14 @@ AC_ARG_ENABLE(udev_sync,
 	      UDEV_SYNC=$enableval, UDEV_SYNC=no)
 AC_MSG_RESULT($UDEV_SYNC)
 
-if test "$UDEV_SYNC" = yes; then
-	pkg_config_init
+AS_IF([test "$UDEV_SYNC" = "yes"], [
 	PKG_CHECK_MODULES(UDEV, libudev >= 143, [UDEV_PC="libudev"])
 	AC_DEFINE([UDEV_SYNC_SUPPORT], 1, [Define to 1 to enable synchronisation with udev processing.])
 
 	AC_CHECK_LIB(udev, udev_device_get_is_initialized, AC_DEFINE([HAVE_LIBUDEV_UDEV_DEVICE_GET_IS_INITIALIZED], 1,
 	  [Define to 1 if udev_device_get_is_initialized is available.]))
 	LIBS=$ac_check_lib_save_LIBS
-fi
+])
 
 dnl -- Enable udev rules
 AC_MSG_CHECKING(whether to enable installation of udev rules required for synchronisation)
@@ -1233,16 +1218,15 @@ AC_ARG_ENABLE(udev_rule_exec_detection,
 AC_MSG_RESULT($UDEV_RULE_EXEC_DETECTION)
 
 dnl -- Check support for built-in blkid against target udev version
-if test "$UDEV_RULE" != no ; then
-	AC_MSG_CHECKING(whether udev supports built-in blkid)
-	pkg_config_init
-	if $("$PKG_CONFIG" --atleast-version=176 libudev); then
+AS_IF([test "$UDEV_RULE" != "no"], [
+	PKG_CHECK_EXISTS([libudev >= 176], [
 		UDEV_HAS_BUILTIN_BLKID=yes
-	else
+	], [
 		UDEV_HAS_BUILTIN_BLKID=no
-	fi
+	])
+	AC_MSG_CHECKING(whether udev supports built-in blkid)
 	AC_MSG_RESULT($UDEV_HAS_BUILTIN_BLKID)
-fi
+])
 
 ################################################################################
 dnl -- Compatible units suffix mode
@@ -1252,9 +1236,9 @@ AC_ARG_ENABLE(units-compat,
 			      that do not use KiB-style unit suffixes]),
 	      UNITS_COMPAT=$enableval, UNITS_COMPAT=no)
 
-if test "$UNITS_COMPAT" = yes; then
+AS_IF([test "$UNITS_COMPAT" = "yes"], [
 	AC_DEFINE([DEFAULT_SI_UNIT_CONSISTENCY], 0, [Define to 0 to reinstate the pre-2.02.54 handling of unit suffixes.])
-fi
+])
 
 ################################################################################
 dnl -- Disable ioctl
@@ -1262,7 +1246,7 @@ AC_ARG_ENABLE(ioctl,
 	      AS_HELP_STRING([--disable-ioctl],
 			     [disable ioctl calls to device-mapper in the kernel]),
 	      DM_IOCTLS=$enableval)
-AS_IF([test "$DM_IOCTLS" = yes],
+AS_IF([test "$DM_IOCTLS" = "yes"],
       [AC_DEFINE([DM_IOCTLS], 1, [Define to enable ioctls calls to kernel])])
 
 ################################################################################
@@ -1273,9 +1257,9 @@ AC_ARG_ENABLE(o_direct,
 	      ODIRECT=$enableval)
 AC_MSG_RESULT($ODIRECT)
 
-if test "$ODIRECT" = yes; then
+AS_IF([test "$ODIRECT" = "yes"], [
 	AC_DEFINE([O_DIRECT_SUPPORT], 1, [Define to 1 to enable O_DIRECT support.])
-fi
+])
 
 ################################################################################
 dnl -- Enable cmdlib
@@ -1285,9 +1269,11 @@ AC_ARG_ENABLE(cmdlib,
 	      CMDLIB=$enableval, CMDLIB=no)
 AC_MSG_RESULT($CMDLIB)
 AC_SUBST([LVM2CMD_LIB])
-test "$CMDLIB" = yes \
-  && LVM2CMD_LIB=-llvm2cmd \
-  || LVM2CMD_LIB=
+AS_IF([test "$CMDLIB" = "yes"], [
+	LVM2CMD_LIB="-llvm2cmd"
+], [
+	LVM2CMD_LIB=""
+])
 
 ################################################################################
 dnl -- Enable D-Bus service
@@ -1296,13 +1282,13 @@ AC_ARG_ENABLE(dbus-service,
 	      AS_HELP_STRING([--enable-dbus-service], [install D-Bus support]),
 	      BUILD_LVMDBUSD=$enableval, BUILD_LVMDBUSD=no)
 AC_MSG_RESULT($BUILD_LVMDBUSD)
-AS_IF([test "$NOTIFYDBUS_SUPPORT" = yes && test "BUILD_LVMDBUSD" = yes],
+AS_IF([test "$NOTIFYDBUS_SUPPORT" = "yes" && test "BUILD_LVMDBUSD" = "yes"],
       [AC_MSG_WARN([Building D-Bus support without D-Bus notifications.])])
 
 ################################################################################
 dnl -- Enable Python dbus library
 
-if test "$BUILD_LVMDBUSD" = yes; then
+AS_IF([test "$BUILD_LVMDBUSD" = "yes"], [
 	unset am_cv_pathless_PYTHON ac_cv_path_PYTHON am_cv_python_platform
 	unset am_cv_python_pythondir am_cv_python_version am_cv_python_pyexecdir
 	unset ac_cv_path_PYTHON_CONFIG ac_cv_path_ac_pt_PYTHON_CONFIG
@@ -1311,18 +1297,24 @@ if test "$BUILD_LVMDBUSD" = yes; then
 	python2.7 python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0 ])
 	AM_PATH_PYTHON([3])
 	PYTHON3=$PYTHON
-	test -z "$PYTHON3" && AC_MSG_ERROR([python3 is required for --enable-python3_bindings or --enable-dbus-service but cannot be found])
+	AS_IF([test -z "$PYTHON3"], [
+		AC_MSG_ERROR([python3 is required for --enable-python3_bindings or --enable-dbus-service but cannot be found])
+	])
 	AC_PATH_TOOL(PYTHON3_CONFIG, python3-config)
-	test -z "$PYTHON3_CONFIG" && AC_MSG_ERROR([python3 headers are required for --enable-python3_bindings or --enable-dbus-service but cannot be found])
+	AS_IF([test -z "$PYTHON3_CONFIG"], [
+		AC_MSG_ERROR([python3 headers are required for --enable-python3_bindings or --enable-dbus-service but cannot be found])
+	])
 	PYTHON3_INCDIRS=`"$PYTHON3_CONFIG" --includes`
 	PYTHON3_LIBDIRS=`"$PYTHON3_CONFIG" --libs`
 	PYTHON3DIR=$pythondir
-	test "$PYTHON3_BINDINGS" = yes && PYTHON_BINDINGS=yes
+	AS_IF([test "$PYTHON3_BINDINGS" = "yes"], [
+		PYTHON_BINDINGS=yes
+	])
 
 	# To get this macro, install autoconf-archive package then run autoreconf
 	AX_PYTHON_MODULE([pyudev], [Required], python3)
 	AX_PYTHON_MODULE([dbus], [Required], python3)
-fi
+])
 
 ################################################################################
 dnl -- Enable pkg-config
@@ -1368,16 +1360,16 @@ AC_ARG_ENABLE(dmeventd, AS_HELP_STRING([--enable-dmeventd],
 AC_MSG_RESULT($BUILD_DMEVENTD)
 
 dnl -- dmeventd currently requires internal mirror support
-if test "$BUILD_DMEVENTD" = yes; then
-   if test "$MIRRORS" != internal; then
+AS_IF([test "$BUILD_DMEVENTD" = "yes"], [
+   AS_IF([test "$MIRRORS" != "internal"], [
       AC_MSG_ERROR([--enable-dmeventd currently requires --with-mirrors=internal])
-   fi
-   if test "$CMDLIB" = no; then
+   ])
+   AS_IF([test "$CMDLIB" = "no"], [
       AC_MSG_ERROR([--enable-dmeventd requires --enable-cmdlib to be used as well])
-   fi
+   ])
 
    AC_DEFINE([DMEVENTD], 1, [Define to 1 to enable the device-mapper event daemon.])
-fi
+])
 
 ################################################################################
 dnl -- getline included in recent libc
@@ -1403,9 +1395,9 @@ AC_CHECK_LIB(dl, dlopen,
 
 ################################################################################
 dnl -- Check for shared/static conflicts
-if ( test "$LVM1" = shared || test "$POOL" = shared ) && test "$STATIC_LINK" = yes; then
+AS_IF([( test "$LVM1" = "shared" || test "$POOL" = "shared" ) && test "$STATIC_LINK" = "yes"], [
 	AC_MSG_ERROR([Features cannot be 'shared' when building statically])
-fi
+])
 
 ################################################################################
 AC_CHECK_LIB(m, log10,
@@ -1425,7 +1417,7 @@ AC_MSG_RESULT($SELINUX)
 
 ################################################################################
 dnl -- Check for selinux
-if test "$SELINUX" = yes; then
+AS_IF([test "$SELINUX" = "yes"], [
 	AC_CHECK_LIB([sepol], [sepol_check_context], [
 		AC_DEFINE([HAVE_SEPOL], 1, [Define to 1 if sepol_check_context is available.])
 		SELINUX_LIBS="-lsepol"])
@@ -1441,7 +1433,7 @@ if test "$SELINUX" = yes; then
 		SELINUX_LIBS=
 		SELINUX_PC=
 		HAVE_SELINUX=no ])
-fi
+])
 
 ################################################################################
 dnl -- Check BLKZEROOUT support
@@ -1461,12 +1453,12 @@ AC_ARG_ENABLE(blkzeroout,
 	      BLKZEROOUT=$enableval, BLKZEROOUT=yes)
 
 AC_MSG_CHECKING(whether to use BLKZEROOUT for device zeroing)
-if test "$BLKZEROOUT" = yes; then
+AS_IF([test "$BLKZEROOUT" = "yes"], [
 	AC_IF_YES(ac_cv_have_blkzeroout,
 		  AC_DEFINE(HAVE_BLKZEROOUT, 1,
 			    [Define if ioctl BLKZEROOUT can be used for device zeroing.]),
 		  BLKZEROOUT=no)
-fi
+])
 AC_MSG_RESULT($BLKZEROOUT)
 
 
@@ -1474,18 +1466,18 @@ AC_MSG_RESULT($BLKZEROOUT)
 dnl -- Check for realtime clock support
 RT_LIBS=
 HAVE_REALTIME=no
-if test "$REALTIME" = yes; then
+AS_IF([test "$REALTIME" = "yes"], [
 	AC_CHECK_FUNCS([clock_gettime], HAVE_REALTIME=yes)
 
-	AS_IF([test "$HAVE_REALTIME" != yes], [ # try again with -lrt
+	AS_IF([test "$HAVE_REALTIME" != "yes"], [ # try again with -lrt
 	      AC_CHECK_LIB([rt], [clock_gettime], RT_LIBS="-lrt"; HAVE_REALTIME=yes)])
 
-	if test "$HAVE_REALTIME" = yes; then
+	AS_IF([test "$HAVE_REALTIME" = "yes"], [
 		AC_DEFINE([HAVE_REALTIME], 1, [Define to 1 to include support for realtime clock.])
-	else
+	], [
 		AC_MSG_WARN(Disabling realtime clock)
-	fi
-fi
+	])
+])
 
 dnl Check if the system has struct stat st_ctim.
 AC_CACHE_CHECK([for struct stat has st_ctim.],
@@ -1505,21 +1497,21 @@ AC_CHECK_HEADERS(getopt.h, AC_DEFINE([HAVE_GETOPTLONG], 1, [Define to 1 if getop
 
 ################################################################################
 dnl -- Check for editline
-if test "$EDITLINE" = yes; then
+AS_IF([test "$EDITLINE" = "yes"], [
 	PKG_CHECK_MODULES([EDITLINE], [libedit], [
 		AC_DEFINE([EDITLINE_SUPPORT], 1,
 			[Define to 1 to include the LVM editline shell.])], AC_MSG_ERROR(
 [libedit could not be found which is required for the --enable-editline option.])
 	)
-fi
+])
 
 ################################################################################
 dnl -- Check for readline (Shamelessly copied from parted 1.4.17)
-if test "$READLINE" != no; then
+AS_IF([test "$READLINE" != "no"], [
 	lvm_saved_libs=$LIBS
 	AC_SEARCH_LIBS([tgetent], [tinfo ncurses curses termcap termlib],
 		READLINE_LIBS=$ac_cv_search_tgetent, [
-		if test "$READLINE" = yes; then
+		AS_IF([test "$READLINE" = "yes"], [
 			AC_MSG_ERROR(
 [termcap could not be found which is required for the
 --enable-readline option (which is enabled by default).  Either disable readline
@@ -1529,7 +1521,8 @@ Note: if you are using precompiled packages you will also need the development
   package as well (which may be called termcap-devel or something similar).
 Note: (n)curses also seems to work as a substitute for termcap.  This was
   not found either - but you could try installing that as well.])
-		fi])
+		])
+	])
 	dnl -- Old systems may need extra termcap dependency explicitly in LIBS
 	AC_CHECK_LIB([readline], [readline], [
 		AC_DEFINE([READLINE_SUPPORT], 1,
@@ -1543,7 +1536,7 @@ Note: (n)curses also seems to work as a substitute for termcap.  This was
 			  READLINE_LIBS="-lreadline $READLINE_LIBS"
 			]) ], [
 		READLINE_LIBS=
-		if test "$READLINE" = yes; then
+		AS_IF([test "$READLINE" = "yes"], [
 			AC_MSG_ERROR(
 [GNU Readline could not be found which is required for the
 --enable-readline option (which is enabled by default).  Either disable readline
@@ -1551,11 +1544,12 @@ support with --disable-readline or download and install readline from:
 	ftp.gnu.org/gnu/readline
 Note: if you are using precompiled packages you will also need the development
 package as well (which may be called readline-devel or something similar).])
-		fi ])
+		])
+	])
 	LIBS="$READLINE_LIBS $lvm_saved_libs"
 	AC_CHECK_FUNCS([rl_completion_matches])
 	LIBS=$lvm_saved_libs
-fi
+])
 
 ################################################################################
 dnl -- Internationalisation stuff
@@ -1565,7 +1559,7 @@ AC_ARG_ENABLE(nls,
 	      INTL=$enableval, INTL=no)
 AC_MSG_RESULT($INTL)
 
-if test "$INTL" = yes; then
+AS_IF([test "$INTL" = "yes"], [
 # FIXME - Move this - can be device-mapper too
 	INTL_PACKAGE="lvm2"
 	AC_PATH_TOOL(MSGFMT, msgfmt)
@@ -1579,7 +1573,7 @@ if test "$INTL" = yes; then
 	AC_DEFINE_UNQUOTED([INTL_PACKAGE], ["$INTL_PACKAGE"], [Internalization package])
 	# double eval needed ${datarootdir} -> ${prefix}/share -> real path
 	AC_DEFINE_UNQUOTED([LOCALEDIR], ["$(eval echo $(eval echo $localedir))"], [Locale-dependent data])
-fi
+])
 
 ################################################################################
 dnl -- FIXME: need to switch to regular option here  --sysconfdir
@@ -1626,16 +1620,19 @@ dnl -- Get the systemd system unit dir value from pkg_config automatically if va
 dnl -- This follows the recommendation for systemd integration best practices mentioned in daemon(7) manpage.
 AC_ARG_WITH(systemdsystemunitdir,
 	    AS_HELP_STRING([--with-systemdsystemunitdir=DIR],
-			   [systemd service files in DIR]),
-	    systemdsystemunitdir=$withval,
-	    pkg_config_init
-	    pkg_systemdsystemunitdir=$("$PKG_CONFIG" --variable=systemdsystemunitdir systemd))
-
-test -n "$pkg_systemdsystemunitdir" && systemdsystemunitdir=$pkg_systemdsystemunitdir
-test -z "$systemdsystemunitdir" && systemdsystemunitdir='${exec_prefix}/lib/systemd/system';
+			   [systemd service files in DIR]))
+
+AS_IF([test -z "$with_systemdsystemunitdir"], [
+	PKG_CHECK_VAR([systemdsystemunitdir], [systemd], [systemdsystemunitdir], [], [
+		systemdsystemunitdir='${exec_prefix}/lib/systemd/system'
+	])
+], [
+	systemdsystemunitdir="$with_systemdsystemunitdir"
+])
 
-systemdutildir=$("$PKG_CONFIG" --variable=systemdutildir systemd)
-test -z "$systemdutildir" && systemdutildir='${exec_prefix}/lib/systemd';
+PKG_CHECK_VAR([systemdutildir], [systemd], [systemdutildir], [], [
+	systemdutildir='${exec_prefix}/lib/systemd'
+])
 
 ################################################################################
 AC_ARG_WITH(tmpfilesdir,
@@ -1644,58 +1641,59 @@ AC_ARG_WITH(tmpfilesdir,
 			   tmpfilesdir=$withval, tmpfilesdir='${prefix}/lib/tmpfiles.d')
 ################################################################################
 dnl -- Ensure additional headers required
-if test "$READLINE" = yes; then
+AS_IF([test "$READLINE" = "yes"], [
 	AC_CHECK_HEADERS(readline/readline.h readline/history.h,,hard_bailout)
-fi
+])
 AC_MSG_CHECKING(whether to enable readline)
 AC_MSG_RESULT($READLINE)
 
-if test "$EDITLINE" = yes; then
+AS_IF([test "$EDITLINE" = "yes"], [
 	AC_CHECK_HEADERS(editline/readline.h,,hard_bailout)
-fi
+])
 AC_MSG_CHECKING(whether to enable editline)
 AC_MSG_RESULT($EDITLINE)
 
-if test "$BUILD_CMIRRORD" = yes; then
+AS_IF([test "$BUILD_CMIRRORD" = "yes"], [
 	AC_CHECK_FUNCS(atexit,,hard_bailout)
-fi
+])
 
-if test "$BUILD_LVMLOCKD" = yes; then
-	AS_IF([test "$HAVE_REALTIME" != yes], [AC_MSG_ERROR([Realtime clock support is mandatory for lvmlockd.])])
+AS_IF([test "$BUILD_LVMLOCKD" = "yes"], [
+	AS_IF([test "$HAVE_REALTIME" != "yes"], [
+		AC_MSG_ERROR([Realtime clock support is mandatory for lvmlockd.])])
 	AC_CHECK_FUNCS(strtoull,,hard_bailout)
-fi
+])
 
-if test "$BUILD_LVMPOLLD" = yes; then
+AS_IF([test "$BUILD_LVMPOLLD" = "yes"], [
 	AC_CHECK_FUNCS(strpbrk,,hard_bailout)
 	AC_FUNC_STRERROR_R
-fi
+])
 
-if test "$BUILD_DMEVENTD" = yes; then
+AS_IF([test "$BUILD_DMEVENTD" = "yes"], [
 	AC_CHECK_HEADERS(arpa/inet.h,,hard_bailout)
-fi
+])
 
-if test "$HAVE_LIBDL" = yes; then
+AS_IF([test "$HAVE_LIBDL" = "yes"], [
 	AC_CHECK_HEADERS(dlfcn.h,,hard_bailout)
-fi
+])
 
-if test "$INTL" = yes; then
+AS_IF([test "$INTL" = "yes"], [
 	AC_CHECK_HEADERS(libintl.h,,hard_bailout)
-fi
+])
 
-if test "$UDEV_SYNC" = yes; then
+AS_IF([test "$UDEV_SYNC" = "yes"], [
 	AC_CHECK_HEADERS(sys/ipc.h sys/sem.h,,hard_bailout)
-fi
+])
 
-if test "$BUILD_DMFILEMAPD" = yes; then
+AS_IF([test "$BUILD_DMFILEMAPD" = "yes"], [
 	AC_CHECK_HEADERS([sys/inotify.h],,hard_bailout)
-fi
+])
 
 ################################################################################
 AC_PATH_TOOL(MODPROBE_CMD, modprobe, [], [$PATH_SBIN])
 
-if test -n "$MODPROBE_CMD"; then
+AS_IF([test -n "$MODPROBE_CMD"], [
 	AC_DEFINE_UNQUOTED([MODPROBE_CMD], ["$MODPROBE_CMD"], [The path to 'modprobe', if available.])
-fi
+])
 
 SYSCONFDIR="$(eval echo $(eval echo $sysconfdir))"
 
@@ -1721,7 +1719,7 @@ AC_DEFINE_UNQUOTED(LVRESIZE_FS_HELPER_PATH, ["$LVRESIZE_FS_HELPER_PATH"], [Path
 
 ################################################################################
 dnl -- dmeventd pidfile and executable path
-if test "$BUILD_DMEVENTD" = yes; then
+AS_IF([test "$BUILD_DMEVENTD" = "yes"], [
 	AC_ARG_WITH(dmeventd-pidfile,
 		    AS_HELP_STRING([--with-dmeventd-pidfile=PATH],
 				   [dmeventd pidfile [PID_DIR/dmeventd.pid]]),
@@ -1729,9 +1727,9 @@ if test "$BUILD_DMEVENTD" = yes; then
 		    DMEVENTD_PIDFILE="$DEFAULT_PID_DIR/dmeventd.pid")
 	AC_DEFINE_UNQUOTED(DMEVENTD_PIDFILE, ["$DMEVENTD_PIDFILE"],
 			   [Path to dmeventd pidfile.])
-fi
+])
 
-if test "$BUILD_DMEVENTD" = yes; then
+AS_IF([test "$BUILD_DMEVENTD" = "yes"], [
 	AC_ARG_WITH(dmeventd-path,
 		    AS_HELP_STRING([--with-dmeventd-path=PATH],
 				   [dmeventd path [EPREFIX/sbin/dmeventd]]),
@@ -1739,7 +1737,7 @@ if test "$BUILD_DMEVENTD" = yes; then
 		    DMEVENTD_PATH="$SBINDIR/dmeventd")
 	AC_DEFINE_UNQUOTED(DMEVENTD_PATH, ["$DMEVENTD_PATH"],
 			   [Path to dmeventd binary.])
-fi
+])
 
 ################################################################################
 dnl -- various defaults

