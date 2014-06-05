From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 Jun 2014 15:54:24 +0000 (UTC)
Subject: master - configure: cleanups
Message-ID: <20140605155424.B6DFF610E9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7cead4afea91a8905ac1b250f542ad808239ba0f
Commit:        7cead4afea91a8905ac1b250f542ad808239ba0f
Parent:        b3ace4f9afaf36688820b72fdca7dcc54928151f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 5 17:28:03 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 5 17:47:23 2014 +0200

configure: cleanups

Replace AC_PATH_PROG with AC_PATH_TOOL.
Drop 'x' when already using "" around shell variable.
Simlify some long line and ifs.
Merge multiple test evaluation with '-a', '-o'.
Use 'case' instead if several ifs when it's more elegant.
Improve usage of pkg_config_init and add it where it's been missing.
Check for UDEV_HAS_BUILTIN_BLKID and when building udev-rules.
---
 configure.in |  531 ++++++++++++++++++++++++----------------------------------
 1 files changed, 215 insertions(+), 316 deletions(-)

diff --git a/configure.in b/configure.in
index b16d34a..a1dfee5 100644
--- a/configure.in
+++ b/configure.in
@@ -77,8 +77,8 @@ AC_PROG_LN_S
 AC_PROG_MAKE_SET
 AC_PROG_MKDIR_P
 AC_PROG_RANLIB
-AC_PATH_PROG(CFLOW_CMD, cflow)
-AC_PATH_PROG(CSCOPE_CMD, cscope)
+AC_PATH_TOOL(CFLOW_CMD, cflow)
+AC_PATH_TOOL(CSCOPE_CMD, cscope)
 
 ################################################################################
 dnl -- Check for header files.
@@ -176,10 +176,7 @@ AC_ARG_WITH(user,
 			   [set the owner of installed files [[USER=]]]),
 	    OWNER=$withval)
 AC_MSG_RESULT($OWNER)
-
-if test x$OWNER != x; then
-	INSTALL="$INSTALL -o $OWNER"
-fi
+test -n "$OWNER" && INSTALL="$INSTALL -o $OWNER"
 
 ################################################################################
 dnl -- Setup the group ownership of the files
@@ -189,10 +186,7 @@ AC_ARG_WITH(group,
 			   [set the group owner of installed files [[GROUP=]]]),
 	    GROUP=$withval)
 AC_MSG_RESULT($GROUP)
-
-if test x$GROUP != x; then
-	INSTALL="$INSTALL -g $GROUP"
-fi
+test -n "$GROUP" && INSTALL="$INSTALL -g $GROUP"
 
 ################################################################################
 dnl -- Setup device node ownership
@@ -261,7 +255,7 @@ AC_ARG_ENABLE(lvm1_fallback,
 	      LVM1_FALLBACK=$enableval, LVM1_FALLBACK=no)
 AC_MSG_RESULT($LVM1_FALLBACK)
 
-if test x$LVM1_FALLBACK = xyes; then
+if test "$LVM1_FALLBACK" = yes; then
 	AC_DEFINE([LVM1_FALLBACK], 1, [Define to 1 if 'lvm' should fall back to using LVM1 binaries if device-mapper is missing from the kernel])
 fi
 
@@ -273,17 +267,15 @@ AC_ARG_WITH(lvm1,
 			   [LVM1 metadata support: internal/shared/none
 			    [[TYPE=internal]]]),
 	    LVM1=$withval, LVM1=internal)
-AC_MSG_RESULT($LVM1)
 
-if [[ "x$LVM1" != xnone -a "x$LVM1" != xinternal -a "x$LVM1" != xshared ]];
- then  AC_MSG_ERROR(
---with-lvm1 parameter invalid
-)
-fi;
+AC_MSG_RESULT($LVM1)
 
-if test x$LVM1 = xinternal; then
-	AC_DEFINE([LVM1_INTERNAL], 1, [Define to 1 to include built-in support for LVM1 metadata.])
-fi
+case "$LVM1" in
+  none|share) ;;
+  internal) AC_DEFINE([LVM1_INTERNAL], 1,
+		      [Define to 1 to include built-in support for LVM1 metadata.]) ;;
+  *) AC_MSG_ERROR([--with-lvm1 parameter invalid]) ;;
+esac
 
 ################################################################################
 dnl -- format_pool inclusion type
@@ -295,15 +287,12 @@ AC_ARG_WITH(pool,
 	    POOL=$withval, POOL=internal)
 AC_MSG_RESULT($POOL)
 
-if [[ "x$POOL" != xnone -a "x$POOL" != xinternal -a "x$POOL" != xshared ]];
- then  AC_MSG_ERROR(
---with-pool parameter invalid
-)
-fi;
-
-if test x$POOL = xinternal; then
-	AC_DEFINE([POOL_INTERNAL], 1, [Define to 1 to include built-in support for GFS pool metadata.])
-fi
+case "$POOL" in
+  none|shared) ;;
+  internal) AC_DEFINE([POOL_INTERNAL], 1,
+		      [Define to 1 to include built-in support for GFS pool metadata.]) ;;
+  *) AC_MSG_ERROR([--with-pool parameter invalid])
+esac
 
 ################################################################################
 dnl -- cluster_locking inclusion type
@@ -315,15 +304,12 @@ AC_ARG_WITH(cluster,
 	    CLUSTER=$withval)
 AC_MSG_RESULT($CLUSTER)
 
-if [[ "x$CLUSTER" != xnone -a "x$CLUSTER" != xinternal -a "x$CLUSTER" != xshared ]];
- then  AC_MSG_ERROR(
---with-cluster parameter invalid
-)
-fi;
-
-if test x$CLUSTER = xinternal; then
-	AC_DEFINE([CLUSTER_LOCKING_INTERNAL], 1, [Define to 1 to include built-in support for clustered LVM locking.])
-fi
+case "$CLUSTER" in
+  none|shared) ;;
+  internal) AC_DEFINE([CLUSTER_LOCKING_INTERNAL], 1,
+		      [Define to 1 to include built-in support for clustered LVM locking.]) ;;
+  *) AC_MSG_ERROR([--with-cluster parameter invalid]) ;;
+esac
 
 ################################################################################
 dnl -- snapshots inclusion type
@@ -335,15 +321,12 @@ AC_ARG_WITH(snapshots,
 	    SNAPSHOTS=$withval, SNAPSHOTS=internal)
 AC_MSG_RESULT($SNAPSHOTS)
 
-if [[ "x$SNAPSHOTS" != xnone -a "x$SNAPSHOTS" != xinternal -a "x$SNAPSHOTS" != xshared ]];
- then  AC_MSG_ERROR(
---with-snapshots parameter invalid
-)
-fi;
-
-if test x$SNAPSHOTS = xinternal; then
-	AC_DEFINE([SNAPSHOT_INTERNAL], 1, [Define to 1 to include built-in support for snapshots.])
-fi
+case "$SNAPSHOTS" in
+  none|shared) ;;
+  internal) AC_DEFINE([SNAPSHOT_INTERNAL], 1,
+		      [Define to 1 to include built-in support for snapshots.]) ;;
+  *) AC_MSG_ERROR([--with-snapshots parameter invalid]) ;;
+esac
 
 ################################################################################
 dnl -- mirrors inclusion type
@@ -355,15 +338,12 @@ AC_ARG_WITH(mirrors,
 	    MIRRORS=$withval, MIRRORS=internal)
 AC_MSG_RESULT($MIRRORS)
 
-if [[ "x$MIRRORS" != xnone -a "x$MIRRORS" != xinternal -a "x$MIRRORS" != xshared ]];
- then  AC_MSG_ERROR(
---with-mirrors parameter invalid
-)
-fi;
-
-if test x$MIRRORS = xinternal; then
-	AC_DEFINE([MIRRORED_INTERNAL], 1, [Define to 1 to include built-in support for mirrors.])
-fi
+case "$MIRRORS" in
+  none|shared) ;;
+  internal) AC_DEFINE([MIRRORED_INTERNAL], 1,
+		      [Define to 1 to include built-in support for mirrors.]) ;;
+  *) AC_MSG_ERROR([--with-mirrors parameter invalid]) ;;
+esac
 
 ################################################################################
 dnl -- raid inclusion type
@@ -375,15 +355,12 @@ AC_ARG_WITH(raid,
 	    RAID=$withval, RAID=internal)
 AC_MSG_RESULT($RAID)
 
-if [[ "x$RAID" != xnone -a "x$RAID" != xinternal -a "x$RAID" != xshared ]];
- then  AC_MSG_ERROR(
---with-raid parameter invalid
-)
-fi;
-
-if test x$RAID = xinternal; then
-	AC_DEFINE([RAID_INTERNAL], 1, [Define to 1 to include built-in support for raid.])
-fi
+case "$RAID" in
+  none|shared) ;;
+  internal) AC_DEFINE([RAID_INTERNAL], 1,
+		      [Define to 1 to include built-in support for raid.]) ;;
+  *) AC_MSG_ERROR([--with-raid parameter invalid]) ;;
+esac
 
 ################################################################################
 dnl -- asynchronous volume replicator inclusion type
@@ -432,7 +409,7 @@ AC_MSG_RESULT($THIN)
 case "$THIN" in
   none|shared) ;;
   internal) AC_DEFINE([THIN_INTERNAL], 1,
-		[Define to 1 to include built-in support for thin provisioning.]) ;;
+		      [Define to 1 to include built-in support for thin provisioning.]) ;;
   *) AC_MSG_ERROR([--with-thin parameter invalid ($THIN)]) ;;
 esac
 
@@ -528,15 +505,11 @@ AC_ARG_WITH(cache,
 	    CACHE=$withval, CACHE=none)
 AC_MSG_RESULT($CACHE)
 
-if [[ "x$CACHE" != xnone -a "x$CACHE" != xinternal -a "x$CACHE" != xshared ]];
- then  AC_MSG_ERROR(
---with-cache parameter invalid
-)
-fi;
-
-if test x$CACHE = xinternal; then
-	AC_DEFINE([CACHE_INTERNAL], 1, [Define to 1 to include built-in support for cache.])
-fi
+case "$CACHE" in
+ none|shared) ;;
+ internal) AC_DEFINE([CACHE_INTERNAL], 1, [Define to 1 to include built-in support for cache.]) ;;
+ *) AC_MSG_ERROR([--with-cache parameter invalid]) ;;
+esac
 
 ################################################################################
 dnl -- Disable readline
@@ -573,9 +546,11 @@ dnl -- this is required because PKG_CHECK_MODULES macro is expanded
 dnl -- to initialize the pkg-config environment only at the first invokation,
 dnl -- that would be conditional in this configure.in.
 pkg_config_init() {
-	PKG_CHECK_MODULES(PKGCONFIGINIT, pkgconfiginit, [],
-		[AC_MSG_RESULT([pkg-config initialized])])
-	PKGCONFIG_INIT=1
+	if test "$PKGCONFIG_INIT" != 1; then
+		PKG_CHECK_MODULES(PKGCONFIGINIT, pkgconfiginit, [],
+				  [AC_MSG_RESULT([pkg-config initialized])])
+		PKGCONFIG_INIT=1
+	fi
 }
 
 ################################################################################
@@ -617,20 +592,14 @@ AC_ARG_WITH(clvmd,
                            * none                  (disable build)
                           [[TYPE=none]]],
 	    CLVMD=$withval, CLVMD=none)
-if test x$CLVMD = xyes; then
-	CLVMD=all
-fi
+test "$CLVMD" = yes && CLVMD=all
 AC_MSG_RESULT($CLVMD)
 
 dnl -- If clvmd enabled without cluster locking, automagically include it
-if  test x$CLVMD != xnone && test x$CLUSTER = xnone; then
-	CLUSTER=internal
-fi
+test "$CLVMD" != none -a "$CLUSTER" = none && CLUSTER=internal
 
 dnl -- init pkgconfig if required
-if test x$CLVMD != xnone && test x$PKGCONFIG_INIT != x1; then
-	pkg_config_init
-fi
+test "$CLVMD" != none && pkg_config_init
 
 dnl -- Express clvmd init script Required-Start / Required-Stop
 CLVMD_CMANAGERS=""
@@ -655,9 +624,7 @@ if [[ `expr x"$CLVMD" : '.*openais.*'` != 0 ]]; then
 	BUILDOPENAIS=yes
 	CLVMD_CMANAGERS="$CLVMD_CMANAGERS openais"
 fi
-if test x$CLVMD_NEEDS_QDISKD != xno; then
-	CLVMD_CMANAGERS="$CLVMD_CMANAGERS qdiskd"
-fi
+test "$CLVMD_NEEDS_QDISKD" != no && CLVMD_CMANAGERS="$CLVMD_CMANAGERS qdiskd"
 
 dnl -- define a soft bailout if we are autodetecting
 soft_bailout() {
@@ -668,10 +635,10 @@ hard_bailout() {
 	AC_MSG_ERROR([bailing out])
 }
 
-dnl -- if clvmd=all then set soft_bailout (we don't want to error)
+dnl -- if clvmd=all then set soft_bailout (we do not want to error)
 dnl -- and set all builds to yes. We need to do this here
 dnl -- to skip the openais|corosync sanity check above.
-if test x$CLVMD = xall; then
+if test "$CLVMD" = all; then
 	bailout=soft_bailout
 	BUILDCMAN=yes
 	BUILDCOROSYNC=yes
@@ -695,7 +662,7 @@ check_lib_no_libs() {
 }
 
 dnl -- Look for cman libraries if required.
-if test x$BUILDCMAN = xyes; then
+if test "$BUILDCMAN" = yes; then
 	PKG_CHECK_MODULES(CMAN, libcman, [HAVE_CMAN=yes],
 		[NOTFOUND=0
 		AC_CHECK_HEADERS(libcman.h,,$bailout)
@@ -709,25 +676,24 @@ if test x$BUILDCMAN = xyes; then
 	CHECKDLM=yes
 fi
 
-dnl -- Look for corosync that's required also for openais build
+dnl -- Look for corosync that is required also for openais build
 dnl -- only enough recent version of corosync ship pkg-config files.
 dnl -- We can safely rely on that to detect the correct bits.
-if test x$BUILDCOROSYNC = xyes || \
-   test x$BUILDOPENAIS = xyes; then
+if test "$BUILDCOROSYNC" = yes -o "$BUILDOPENAIS" = yes; then
 	PKG_CHECK_MODULES(COROSYNC, corosync, [HAVE_COROSYNC=yes], $bailout)
 	CHECKCONFDB=yes
 	CHECKCMAP=yes
 fi
 
 dnl -- Look for corosync libraries if required.
-if test x$BUILDCOROSYNC = xyes; then
+if test "$BUILDCOROSYNC" = yes; then
 	PKG_CHECK_MODULES(QUORUM, libquorum, [HAVE_QUORUM=yes], $bailout)
 	CHECKCPG=yes
 	CHECKDLM=yes
 fi
 
 dnl -- Look for openais libraries if required.
-if test x$BUILDOPENAIS = xyes; then
+if test "$BUILDOPENAIS" = yes; then
 	PKG_CHECK_MODULES(SALCK, libSaLck, [HAVE_SALCK=yes], $bailout)
 	CHECKCPG=yes
 fi
@@ -738,17 +704,14 @@ dnl -- Check confdb library.
 dnl -- mandatory for corosync < 2.0 build.
 dnl -- optional for openais/cman build.
 
-if test x$CHECKCONFDB = xyes; then
+if test "$CHECKCONFDB" = yes; then
 	PKG_CHECK_MODULES(CONFDB, libconfdb,
-			  [HAVE_CONFDB=yes],
-			  [HAVE_CONFDB=no])
+			  [HAVE_CONFDB=yes], [HAVE_CONFDB=no])
 
-	AC_CHECK_HEADERS(corosync/confdb.h,
-		[HAVE_CONFDB_H=yes],
-		[HAVE_CONFDB_H=no])
+	AC_CHECK_HEADERS([corosync/confdb.h],
+			 [HAVE_CONFDB_H=yes], [HAVE_CONFDB_H=no])
 
-	if test x$HAVE_CONFDB != xyes && \
-	   test x$HAVE_CONFDB_H = xyes; then
+	if test "$HAVE_CONFDB" != yes -a "$HAVE_CONFDB_H" = yes; then
 		check_lib_no_libs confdb confdb_initialize
 		AC_MSG_RESULT([no pkg for confdb, using -lconfdb])
 		CONFDB_LIBS="-lconfdb"
@@ -759,17 +722,14 @@ fi
 dnl -- Check cmap library
 dnl -- mandatory for corosync >= 2.0 build.
 
-if test x$CHECKCMAP = xyes; then
+if test "$CHECKCMAP" = yes; then
 	PKG_CHECK_MODULES(CMAP, libcmap,
-			  [HAVE_CMAP=yes],
-			  [HAVE_CMAP=no])
+			  [HAVE_CMAP=yes], [HAVE_CMAP=no])
 
-	AC_CHECK_HEADERS(corosync/cmap.h,
-		[HAVE_CMAP_H=yes],
-		[HAVE_CMAP_H=no])
+	AC_CHECK_HEADERS([corosync/cmap.h],
+			 [HAVE_CMAP_H=yes], [HAVE_CMAP_H=no])
 
-	if test x$HAVE_CMAP != xyes && \ 
-	   test x$HAVE_CMAP_H = xyes; then
+	if test "$HAVE_CMAP" != yes -a "$HAVE_CMAP_H" = yes; then
 		check_lib_no_libs cmap cmap_initialize
 		AC_MSG_RESULT([no pkg for cmap, using -lcmap])
 		CMAP_LIBS="-lcmap"
@@ -777,24 +737,21 @@ if test x$CHECKCMAP = xyes; then
 	fi
 fi
 
-if test x$BUILDCOROSYNC = xyes; then
-	if test x$HAVE_CMAP != xyes && \
-	   test x$HAVE_CONFDB != xyes && \
-	   test x$CLVMD != xall; then
-		AC_MSG_ERROR([bailing out... cmap (corosync >= 2.0) or confdb (corosync < 2.0) library is required])
-	fi
+if test "$BUILDCOROSYNC" = yes -a \
+	"$HAVE_CMAP" != yes -a "$HAVE_CONFDB" != yes -a "$CLVMD" != all; then
+	AC_MSG_ERROR([bailing out... cmap (corosync >= 2.0) or confdb (corosync < 2.0) library is required])
 fi
 
 dnl -- Check cpg library.
-if test x$CHECKCPG = xyes; then
-	PKG_CHECK_MODULES(CPG, libcpg, [HAVE_CPG=yes], $bailout)
+if test "$CHECKCPG" = yes; then
+	PKG_CHECK_MODULES(CPG, libcpg, [HAVE_CPG=yes], [$bailout])
 fi
 
 dnl -- Check dlm library.
-if test x$CHECKDLM = xyes; then
+if test "$CHECKDLM" = yes; then
 	PKG_CHECK_MODULES(DLM, libdlm, [HAVE_DLM=yes],
 		[NOTFOUND=0
-		AC_CHECK_HEADERS(libdlm.h,,$bailout)
+		AC_CHECK_HEADERS(libdlm.h,,[$bailout])
 		check_lib_no_libs dlm dlm_lock -lpthread
 		if test $NOTFOUND = 0; then
 			AC_MSG_RESULT([no pkg for libdlm, using -ldlm])
@@ -806,54 +763,48 @@ fi
 dnl -- If we are autodetecting, we need to re-create
 dnl -- the depedencies checks and set a proper CLVMD,
 dnl -- together with init script Required-Start/Stop entries.
-if test x$CLVMD = xall; then
+if test "$CLVMD" = all; then
 	CLVMD=none
 	CLVMD_CMANAGERS=""
 	CLVMD_NEEDS_QDISKD=no
-	if test x$HAVE_CMAN = xyes && \
-	   test x$HAVE_DLM = xyes; then
+	if test "$HAVE_CMAN" = yes -a \
+		"$HAVE_DLM" = yes; then
 		AC_MSG_RESULT([Enabling clvmd cman cluster manager])
 		CLVMD="$CLVMD,cman"
 		CLVMD_CMANAGERS="$CLVMD_CMANAGERS cman"
 		CLVMD_NEEDS_QDISKD=yes
 	fi
-	if test x$HAVE_COROSYNC = xyes && \
-	   test x$HAVE_QUORUM = xyes && \
-	   test x$HAVE_CPG = xyes && \
-	   test x$HAVE_DLM = xyes; then
-	   if test x$HAVE_CONFDB = xyes || test x$HAVE_CMAP = xyes; then
+	if test "$HAVE_COROSYNC" = yes -a \
+		"$HAVE_QUORUM" = yes -a \
+		"$HAVE_CPG" = yes -a \
+		"$HAVE_DLM" = yes; then
+	   if test "$HAVE_CONFDB" = yes -o "$HAVE_CMAP" = yes; then
 		AC_MSG_RESULT([Enabling clvmd corosync cluster manager])
 		CLVMD="$CLVMD,corosync"
 		CLVMD_CMANAGERS="$CLVMD_CMANAGERS corosync"
 	   fi
 	fi
-	if test x$HAVE_COROSYNC = xyes && \
-	   test x$HAVE_CPG = xyes && \
-	   test x$HAVE_SALCK = xyes; then
+	if test "$HAVE_COROSYNC" = yes -a \
+		"$HAVE_CPG" = yes -a \
+		"$HAVE_SALCK" = yes; then
 		AC_MSG_RESULT([Enabling clvmd openais cluster manager])
 		CLVMD="$CLVMD,openais"
 		CLVMD_CMANAGERS="$CLVMD_CMANAGERS openais"
 	fi
-	if test x$CLVMD_NEEDS_QDISKD != xno; then
-		CLVMD_CMANAGERS="$CLVMD_CMANAGERS qdiskd"
-	fi
-	if test x$CLVMD = xnone; then
-		AC_MSG_RESULT([Disabling clvmd build. No cluster manager detected.])
-	fi
+	test "$CLVMD_NEEDS_QDISKD" != no && CLVMD_CMANAGERS="$CLVMD_CMANAGERS qdiskd"
+	test "$CLVMD" = none && AC_MSG_RESULT([Disabling clvmd build. No cluster manager detected.])
 fi
 
 dnl -- Fixup CLVMD_CMANAGERS with new corosync
 dnl -- clvmd built with corosync >= 2.0 needs dlm (either init or systemd service)
 dnl -- to be started.
 if [[ `expr x"$CLVMD" : '.*corosync.*'` != 0 ]]; then
-   if test x$HAVE_CMAP = xyes; then
-	CLVMD_CMANAGERS="$CLVMD_CMANAGERS dlm"
-   fi
+   test "$HAVE_CMAP" = yes && CLVMD_CMANAGERS="$CLVMD_CMANAGERS dlm"
 fi
 
 ################################################################################
 dnl -- clvmd pidfile
-if test "x$CLVMD" != xnone; then
+if test "$CLVMD" != none; then
 	AC_ARG_WITH(clvmd-pidfile,
 		    AC_HELP_STRING([--with-clvmd-pidfile=PATH],
 				   [clvmd pidfile [[PID_DIR/clvmd.pid]]]),
@@ -876,7 +827,7 @@ BUILD_CMIRRORD=$CMIRRORD
 
 ################################################################################
 dnl -- cmirrord pidfile
-if test "x$BUILD_CMIRRORD" = xyes; then
+if test "$BUILD_CMIRRORD" = yes; then
 	AC_ARG_WITH(cmirrord-pidfile,
 		    AC_HELP_STRING([--with-cmirrord-pidfile=PATH],
 				   [cmirrord pidfile [[PID_DIR/cmirrord.pid]]]),
@@ -888,20 +839,15 @@ fi
 
 ################################################################################
 dnl -- Look for corosync libraries if required.
-if [[ "x$BUILD_CMIRRORD" = xyes ]]; then
-	dnl -- init pkgconfig if required
-	if  test x$PKGCONFIG_INIT != x1; then
-		pkg_config_init
-	fi
+if [[ "$BUILD_CMIRRORD" = yes ]]; then
+	pkg_config_init
 
 	AC_DEFINE([CMIRROR_HAS_CHECKPOINT], 1, [Define to 1 to include libSaCkpt.])
 	PKG_CHECK_MODULES(SACKPT, libSaCkpt, [HAVE_SACKPT=yes],
 		[AC_MSG_RESULT([no libSaCkpt, compiling without it])
 		AC_DEFINE([CMIRROR_HAS_CHECKPOINT], 0, [Define to 0 to exclude libSaCkpt.])])
 
-	if test x$HAVE_CPG != xyes; then
-		PKG_CHECK_MODULES(CPG, libcpg)
-	fi
+	test "$HAVE_CPG" != yes && PKG_CHECK_MODULES(CPG, libcpg)
 fi
 
 ################################################################################
@@ -912,7 +858,7 @@ AC_ARG_ENABLE(debug, AC_HELP_STRING([--enable-debug], [enable debugging]),
 AC_MSG_RESULT($DEBUG)
 
 dnl -- Normally turn off optimisation for debug builds
-if test x$DEBUG = xyes; then
+if test "$DEBUG" = yes; then
 	COPTIMISE_FLAG=
 else
 	CSCOPE_CMD=
@@ -937,25 +883,24 @@ AC_MSG_RESULT($COPTIMISE_FLAG)
 dnl -- Enable profiling
 AC_MSG_CHECKING(whether to gather gcov profiling data)
 AC_ARG_ENABLE(profiling,
-	      AC_HELP_STRING(--enable-profiling, [gather gcov profiling data]),
+	      AC_HELP_STRING([--enable-profiling],
+			     [gather gcov profiling data]),
 	      PROFILING=$enableval, PROFILING=no)
 AC_MSG_RESULT($PROFILING)
 
-if test "x$PROFILING" = xyes; then
+if test "$PROFILING" = yes; then
   COPTIMISE_FLAG="$COPTIMISE_FLAG -fprofile-arcs -ftest-coverage"
-  AC_PATH_PROG(LCOV, lcov)
-  AC_PATH_PROG(GENHTML, genhtml)
-  if test -z "$LCOV" -o -z "$GENHTML"; then
-    AC_MSG_ERROR([lcov and genhtml are required for profiling])
-  fi
-  AC_PATH_PROG(GENPNG, genpng)
+  AC_PATH_TOOL(LCOV, lcov)
+  AC_PATH_TOOL(GENHTML, genhtml)
+  test -z "$LCOV" -o -z "$GENHTML" && AC_MSG_ERROR([lcov and genhtml are required for profiling])
+  AC_PATH_TOOL(GENPNG, genpng)
   if test -n "$GENPNG"; then
     AC_MSG_CHECKING([whether $GENPNG has all required modules])
-    if $GENPNG --help > /dev/null 2>&1 ; then
+    if "$GENPNG" --help > /dev/null 2>&1 ; then
       AC_MSG_RESULT(ok)
       GENHTML="$GENHTML --frames"
     else
-      AC_MSG_RESULT(not supported)
+      AC_MSG_RESULT([not supported])
       AC_MSG_WARN([GD.pm perl module is not installed])
       GENPNG=
     fi
@@ -966,14 +911,13 @@ fi
 dnl -- Enable testing
 AC_MSG_CHECKING(whether to enable unit testing)
 AC_ARG_ENABLE(testing,
-              AC_HELP_STRING(--enable-testing, [enable testing targets in the makefile]),
-              TESTING=$enableval, TESTING=no)
+              AC_HELP_STRING([--enable-testing],
+			     [enable testing targets in the makefile]),
+	      TESTING=$enableval, TESTING=no)
 AC_MSG_RESULT($TESTING)
 
 if test "$TESTING" = yes; then
-	if  test x$PKGCONFIG_INIT != x1; then
-		pkg_config_init
-	fi
+	pkg_config_init
 	PKG_CHECK_MODULES(CUNIT, cunit >= 2.0)
 fi
 
@@ -981,15 +925,17 @@ fi
 dnl -- Enable valgrind awareness of memory pools
 AC_MSG_CHECKING(whether to enable valgrind awareness of pools)
 AC_ARG_ENABLE(valgrind_pool,
-              AC_HELP_STRING(--enable-valgrind-pool, [enable valgrind awareness of pools]),
+              AC_HELP_STRING([--enable-valgrind-pool],
+			     [enable valgrind awareness of pools]),
 	      VALGRIND_POOL=$enableval, VALGRIND_POOL=no)
 AC_MSG_RESULT($VALGRIND_POOL)
 
 if test "$VALGRIND_POOL" = yes; then
-    PKG_CHECK_MODULES(VALGRIND, valgrind, [], [AC_MSG_ERROR(bailing out)])
-    AC_DEFINE([VALGRIND_POOL], 1, [Enable a valgrind aware build of pool])
-    AC_SUBST(VALGRIND_POOL)
-    AC_SUBST(VALGRIND_CFLAGS)
+	pkg_config_init
+	PKG_CHECK_MODULES(VALGRIND, valgrind, [], [AC_MSG_ERROR(bailing out)])
+	AC_DEFINE([VALGRIND_POOL], 1, [Enable a valgrind aware build of pool])
+	AC_SUBST(VALGRIND_POOL)
+	AC_SUBST(VALGRIND_CFLAGS)
 fi
 
 ################################################################################
@@ -1001,7 +947,7 @@ AC_ARG_ENABLE(devmapper,
 	      DEVMAPPER=$enableval)
 AC_MSG_RESULT($DEVMAPPER)
 
-if test x$DEVMAPPER = xyes; then
+if test "$DEVMAPPER" = yes; then
 	AC_DEFINE([DEVMAPPER_SUPPORT], 1, [Define to 1 to enable LVM2 device-mapper interaction.])
 fi
 
@@ -1016,7 +962,7 @@ AC_MSG_RESULT($LVMETAD)
 
 BUILD_LVMETAD=$LVMETAD
 
-if test x$BUILD_LVMETAD = xyes; then
+if test "$BUILD_LVMETAD" = yes; then
 	AC_DEFINE([LVMETAD_SUPPORT], 1, [Define to 1 to include code that uses lvmetad.])
 
 	AC_ARG_WITH(lvmetad-pidfile,
@@ -1037,22 +983,16 @@ AC_ARG_ENABLE(blkid_wiping,
 	      BLKID_WIPING=$enableval, BLKID_WIPING=maybe)
 AC_MSG_RESULT($BLKID_WIPING)
 
-if test x$BLKID_WIPING != xno; then
-	dnl -- init pkgconfig if required
-	if test x$PKGCONFIG_INIT != x1; then
-		pkg_config_init
-	fi
+if test "$BLKID_WIPING" != no; then
+	pkg_config_init
 	PKG_CHECK_MODULES(BLKID, blkid >= 2.24,
-				[if test x$BLKID_WIPING = xmaybe; then
-					BLKID_WIPING=yes
-				 fi],
-				[if test x$BLKID_WIPING = xmaybe; then
-					BLKID_WIPING=no
-				 else
-					AC_MSG_ERROR([bailing out... blkid library >= 2.24 is required])
-				 fi
-				])
-	if test x$BLKID_WIPING = xyes; then
+			  [test "$BLKID_WIPING" = maybe && BLKID_WIPING=yes],
+			  [if test "$BLKID_WIPING" = maybe; then
+				BLKID_WIPING=no
+			   else
+			        AC_MSG_ERROR([bailing out... blkid library >= 2.24 is required])
+			   fi])
+	if test "$BLKID_WIPING" = yes; then
 		BLKID_PC="blkid"
 		AC_DEFINE([BLKID_WIPING_SUPPORT], 1, [Define to 1 to use libblkid detection of signatures when wiping.])
 	fi
@@ -1071,16 +1011,13 @@ AC_MSG_RESULT($UDEV_SYSTEMD_BACKGROUND_JOBS)
 dnl -- Enable udev synchronisation
 AC_MSG_CHECKING(whether to enable synchronisation with udev processing)
 AC_ARG_ENABLE(udev_sync,
-	      AC_HELP_STRING([--enable-udev_sync], 
+	      AC_HELP_STRING([--enable-udev_sync],
 			     [enable synchronisation with udev processing]),
 	      UDEV_SYNC=$enableval, UDEV_SYNC=no)
 AC_MSG_RESULT($UDEV_SYNC)
 
-if test x$UDEV_SYNC = xyes; then
-	dnl -- init pkgconfig if required
-	if  test x$PKGCONFIG_INIT != x1; then
-		pkg_config_init
-	fi
+if test "$UDEV_SYNC" = yes; then
+	pkg_config_init
 	PKG_CHECK_MODULES(UDEV, libudev >= 143, [UDEV_PC="libudev"])
 	AC_DEFINE([UDEV_SYNC_SUPPORT], 1, [Define to 1 to enable synchronisation with udev processing.])
 fi
@@ -1101,14 +1038,16 @@ AC_ARG_ENABLE(udev_rule_exec_detection,
 AC_MSG_RESULT($UDEV_RULE_EXEC_DETECTION)
 
 dnl -- Check support for built-in blkid against target udev version
-AC_MSG_CHECKING(whether udev supports built-in blkid)
-test x$PKGCONFIG_INIT != x1 && pkg_config_init
-if $($PKG_CONFIG --atleast-version=176 libudev); then
-	UDEV_HAS_BUILTIN_BLKID=yes
-else
-	UDEV_HAS_BUILTIN_BLKID=no
+if test "$UDEV_RULE" != no ; then
+	AC_MSG_CHECKING(whether udev supports built-in blkid)
+	pkg_config_init
+	if $("$PKG_CONFIG" --atleast-version=176 libudev); then
+		UDEV_HAS_BUILTIN_BLKID=yes
+	else
+		UDEV_HAS_BUILTIN_BLKID=no
+	fi
+	AC_MSG_RESULT($UDEV_HAS_BUILTIN_BLKID)
 fi
-AC_MSG_RESULT($UDEV_HAS_BUILTIN_BLKID)
 
 ################################################################################
 dnl -- Compatibility mode
@@ -1117,12 +1056,10 @@ AC_ARG_ENABLE(compat,
 			     [enable support for old device-mapper versions]),
 	      DM_COMPAT=$enableval, DM_COMPAT=no)
 
-if test x$DM_COMPAT = xyes; then
-	AC_MSG_ERROR(
-                 [--enable-compat is not currently supported.
-Since device-mapper version 1.02.66, only one version (4) of the device-mapper 
-ioctl protocol is supported.]
-	)
+if test "$DM_COMPAT" = yes; then
+	AC_MSG_ERROR([--enable-compat is not currently supported.
+Since device-mapper version 1.02.66, only one version (4) of the device-mapper
+ioctl protocol is supported.])
 fi
 
 ################################################################################
@@ -1133,7 +1070,7 @@ AC_ARG_ENABLE(units-compat,
 			      that do not use KiB-style unit suffixes]),
 	      UNITS_COMPAT=$enableval, UNITS_COMPAT=no)
 
-if test x$UNITS_COMPAT = xyes; then
+if test "$UNITS_COMPAT" = yes; then
 	AC_DEFINE([DEFAULT_SI_UNIT_CONSISTENCY], 0, [Define to 0 to reinstate the pre-2.02.54 handling of unit suffixes.])
 fi
 
@@ -1152,7 +1089,7 @@ AC_ARG_ENABLE(o_direct,
 	      ODIRECT=$enableval)
 AC_MSG_RESULT($ODIRECT)
 
-if test x$ODIRECT = xyes; then
+if test "$ODIRECT" = yes; then
 	AC_DEFINE([O_DIRECT_SUPPORT], 1, [Define to 1 to enable O_DIRECT support.])
 fi
 
@@ -1164,7 +1101,7 @@ AC_ARG_ENABLE(applib,
 	      APPLIB=$enableval, APPLIB=no)
 AC_MSG_RESULT($APPLIB)
 AC_SUBST([LVM2APP_LIB])
-test x$APPLIB = xyes \
+test "$APPLIB" = yes \
   && LVM2APP_LIB=-llvm2app \
   || LVM2APP_LIB=
 
@@ -1176,7 +1113,7 @@ AC_ARG_ENABLE(cmdlib,
 	      CMDLIB=$enableval, CMDLIB=no)
 AC_MSG_RESULT($CMDLIB)
 AC_SUBST([LVM2CMD_LIB])
-test x$CMDLIB = xyes \
+test "$CMDLIB" = yes \
   && LVM2CMD_LIB=-llvm2cmd \
   || LVM2CMD_LIB=
 
@@ -1188,30 +1125,17 @@ AC_ARG_ENABLE(python_bindings,
 	      PYTHON_BINDINGS=$enableval, PYTHON_BINDINGS=no)
 AC_MSG_RESULT($PYTHON_BINDINGS)
 
-if test x$PYTHON_BINDINGS = xyes; then
-	if test x$APPLIB != xyes; then
-		AC_MSG_ERROR(
-			--enable-python_bindings requires --enable-applib
-		)
-	fi
-
-	AC_PATH_PROG(PYTHON, python, notfound)
-	if test x$PYTHON == xnotfound; then
-		AC_MSG_ERROR(
-[python is required for --enable-python_bindings but cannot be found]
-		)
-	fi
+if test "$PYTHON_BINDINGS" = yes; then
+	test "$APPLIB" != yes && AC_MSG_ERROR([--enable-python_bindings requires --enable-applib])
 
-	AC_PATH_PROG(PYTHON_CONFIG, python-config, notfound)
-	if test x$PYTHON_CONFIG == xnotfound; then
-		AC_MSG_ERROR(
-[python headers are required for --enable-python_bindings but cannot be found]
-		)
-	fi
+	AC_PATH_TOOL(PYTHON, python)
+	test -z "$PYTHON" && AC_MSG_ERROR([python is required for --enable-python_bindings but cannot be found])
 
-	PYTHON_INCDIRS=`$PYTHON_CONFIG --includes`
-	PYTHON_LIBDIRS=`$PYTHON_CONFIG --libs`
+	AC_PATH_TOOL(PYTHON_CONFIG, python-config)
+	test -z "$PYTHON_CONFIG" && AC_MSG_ERROR([python headers are required for --enable-python_bindings but cannot be found])
 
+	PYTHON_INCDIRS=`"$PYTHON_CONFIG" --includes`
+	PYTHON_LIBDIRS=`"$PYTHON_CONFIG" --libs`
 fi
 
 ################################################################################
@@ -1252,21 +1176,15 @@ AC_MSG_RESULT($DMEVENTD)
 BUILD_DMEVENTD=$DMEVENTD
 
 dnl -- dmeventd currently requires internal mirror support
-if test x$DMEVENTD = xyes; then
-   if test x$MIRRORS != xinternal; then
-      AC_MSG_ERROR(
-	--enable-dmeventd currently requires --with-mirrors=internal
-      )
+if test "$DMEVENTD" = yes; then
+   if test "$MIRRORS" != internal; then
+      AC_MSG_ERROR([--enable-dmeventd currently requires --with-mirrors=internal])
    fi
-   if test x$CMDLIB = xno; then
-      AC_MSG_ERROR(
-        --enable-dmeventd requires --enable-cmdlib to be used as well
-      )
+   if test "$CMDLIB" = no; then
+      AC_MSG_ERROR([--enable-dmeventd requires --enable-cmdlib to be used as well])
    fi
-fi
 
-if test x$DMEVENTD = xyes; then
-	AC_DEFINE([DMEVENTD], 1, [Define to 1 to enable the device-mapper event daemon.])
+   AC_DEFINE([DMEVENTD], 1, [Define to 1 to enable the device-mapper event daemon.])
 fi
 
 ################################################################################
@@ -1284,29 +1202,24 @@ AC_CHECK_LIB(c, canonicalize_file_name,
 
 ################################################################################
 dnl -- Clear default exec_prefix - install into /sbin rather than /usr/sbin
-if [[ "x$exec_prefix" = xNONE -a "x$prefix" = xNONE ]];
- then  exec_prefix="";
-fi;
+test "$exec_prefix" = NONE -a "$prefix" = NONE && exec_prefix=""
 
 ################################################################################
 dnl -- Check for dlopen
-AC_CHECK_LIB(dl, dlopen, [
-	AC_DEFINE([HAVE_LIBDL], 1, [Define to 1 if dynamic libraries are available.])
-	DL_LIBS="-ldl"
-	HAVE_LIBDL=yes ], [
-	DL_LIBS=
-	HAVE_LIBDL=no ])
+AC_CHECK_LIB(dl, dlopen,
+	     [AC_DEFINE([HAVE_LIBDL], 1, [Define to 1 if dynamic libraries are available.])
+	      DL_LIBS="-ldl"
+	      HAVE_LIBDL=yes],
+	     [DL_LIBS=
+	      HAVE_LIBDL=no ])
 
 ################################################################################
 dnl -- Check for shared/static conflicts
-if [[ \( "x$LVM1" = xshared -o "x$POOL" = xshared -o "x$CLUSTER" = xshared \
-      -o "x$SNAPSHOTS" = xshared -o "x$MIRRORS" = xshared \
-      -o "x$RAID" = xshared \
-      -o "x$CACHE" = xshared \
-      \) -a "x$STATIC_LINK" = xyes ]];
- then  AC_MSG_ERROR(
-Features cannot be 'shared' when building statically
-)
+if [[ \( "$LVM1" = shared -o "$POOL" = shared -o "$CLUSTER" = shared \
+      -o "$SNAPSHOTS" = shared -o "$MIRRORS" = shared \
+      -o "$RAID" = shared -o "$CACHE" = shared \
+      \) -a "$STATIC_LINK" = yes ]]; then
+	AC_MSG_ERROR([Features cannot be 'shared' when building statically])
 fi
 
 ################################################################################
@@ -1323,7 +1236,7 @@ AC_MSG_RESULT($SELINUX)
 
 ################################################################################
 dnl -- Check for selinux
-if test x$SELINUX = xyes; then
+if test "$SELINUX" = yes; then
 	AC_CHECK_LIB([sepol], [sepol_check_context], [
 		AC_DEFINE([HAVE_SEPOL], 1, [Define to 1 if sepol_check_context is available.])
 		SELINUX_LIBS="-lsepol"])
@@ -1343,10 +1256,10 @@ fi
 
 ################################################################################
 dnl -- Check for realtime clock support
-if test x$REALTIME = xyes; then
+if test "$REALTIME" = yes; then
 	AC_CHECK_LIB(rt, clock_gettime, HAVE_REALTIME=yes, HAVE_REALTIME=no)
 
-	if test x$HAVE_REALTIME = xyes; then
+	if test "$HAVE_REALTIME" = yes; then
 		AC_DEFINE([HAVE_REALTIME], 1, [Define to 1 to include support for realtime clock.])
 		LIBS="-lrt $LIBS"
 	else
@@ -1409,15 +1322,13 @@ AC_ARG_ENABLE(nls,
 	      INTL=$enableval, INTL=no)
 AC_MSG_RESULT($INTL)
 
-if test x$INTL = xyes; then
+if test "$INTL" = yes; then
 # FIXME - Move this - can be device-mapper too
 	INTL_PACKAGE="lvm2"
-	AC_PATH_PROG(MSGFMT, msgfmt)
-	if [[ "x$MSGFMT" == x ]];
-		then  AC_MSG_ERROR(
-		msgfmt not found in path $PATH
-		)
-	fi;
+	AC_PATH_TOOL(MSGFMT, msgfmt)
+	if [[ -z "$MSGFMT" ]]; then
+		AC_MSG_ERROR([msgfmt not found in path $PATH])
+	fi
 
 	AC_ARG_WITH(localedir,
 		    AC_HELP_STRING([--with-localedir=DIR],
@@ -1466,22 +1377,15 @@ AC_ARG_WITH(systemdsystemunitdir,
 	    AC_HELP_STRING([--with-systemdsystemunitdir=DIR],
 			   [systemd service files in DIR]),
 	    systemdsystemunitdir=$withval,
-	    dnl -- init pkgconfig if required
-	    test x$PKGCONFIG_INIT != x1 && pkg_config_init
-	    pkg_systemdsystemunitdir=$($PKG_CONFIG --variable=systemdsystemunitdir systemd))
+	    pkg_config_init
+	    pkg_systemdsystemunitdir=$("$PKG_CONFIG" --variable=systemdsystemunitdir systemd))
 
-if test -n "$pkg_systemdsystemunitdir"; then
-	    systemdsystemunitdir=$pkg_systemdsystemunitdir;
-fi
+test -n "$pkg_systemdsystemunitdir" && systemdsystemunitdir=$pkg_systemdsystemunitdir
+test -z "$systemdsystemunitdir" && systemdsystemunitdir='${exec_prefix}/lib/systemd/system';
 
-if test -z "$systemdsystemunitdir"; then
-	    systemdsystemunitdir='${exec_prefix}/lib/systemd/system';
-fi
+systemdutildir=$("$PKG_CONFIG" --variable=systemdutildir systemd)
+test -z "$systemdutildir" && systemdutildir='${exec_prefix}/lib/systemd';
 
-systemdutildir=$($PKG_CONFIG --variable=systemdutildir systemd)
-if test -z "$systemdutildir"; then
-	    systemdutildir='${exec_prefix}/lib/systemd';
-fi
 ################################################################################
 AC_ARG_WITH(tmpfilesdir,
 	    AC_HELP_STRING([--with-tmpfilesdir=DIR],
@@ -1489,42 +1393,42 @@ AC_ARG_WITH(tmpfilesdir,
 			   tmpfilesdir=$withval, tmpfilesdir='${prefix}/lib/tmpfiles.d')
 ################################################################################
 dnl -- Ensure additional headers required
-if test x$READLINE = xyes; then
-	AC_CHECK_HEADERS(readline/readline.h readline/history.h,,AC_MSG_ERROR(bailing out))
+if test "$READLINE" = yes; then
+	AC_CHECK_HEADERS(readline/readline.h readline/history.h,,hard_bailout)
 fi
 
-if test x$CLVMD != xnone; then
+if test "$CLVMD" != none; then
 	AC_CHECK_HEADERS(mntent.h netdb.h netinet/in.h pthread.h search.h sys/mount.h sys/socket.h sys/uio.h sys/un.h utmpx.h,,AC_MSG_ERROR(bailing out))
-	AC_CHECK_FUNCS(dup2 getmntent memmove select socket,,AC_MSG_ERROR(bailing out))
+	AC_CHECK_FUNCS(dup2 getmntent memmove select socket,,hard_bailout)
 	AC_FUNC_GETMNTENT
 	AC_FUNC_SELECT_ARGTYPES
 fi
 
-if test x$CLUSTER != xnone; then
-	AC_CHECK_HEADERS(sys/socket.h sys/un.h,,AC_MSG_ERROR(bailing out))
-	AC_CHECK_FUNCS(socket,,AC_MSG_ERROR(bailing out))
+if test "$CLUSTER" != none; then
+	AC_CHECK_HEADERS(sys/socket.h sys/un.h,,hard_bailout)
+	AC_CHECK_FUNCS(socket,,hard_bailout)
 fi
 
-if test x$DMEVENTD = xyes; then
-	AC_CHECK_HEADERS(arpa/inet.h,,AC_MSG_ERROR(bailing out))
+if test "$DMEVENTD" = yes; then
+	AC_CHECK_HEADERS(arpa/inet.h,,hard_bailout)
 fi
 
-if test x$HAVE_LIBDL = xyes; then
-	AC_CHECK_HEADERS(dlfcn.h,,AC_MSG_ERROR(bailing out))
+if test "$HAVE_LIBDL" = yes; then
+	AC_CHECK_HEADERS(dlfcn.h,,hard_bailout)
 fi
 
-if test x$INTL = xyes; then
-	AC_CHECK_HEADERS(libintl.h,,AC_MSG_ERROR(bailing out))
+if test "$INTL" = yes; then
+	AC_CHECK_HEADERS(libintl.h,,hard_bailout)
 fi
 
-if test x$UDEV_SYNC = xyes; then
-	AC_CHECK_HEADERS(sys/ipc.h sys/sem.h,,AC_MSG_ERROR(bailing out))
+if test "$UDEV_SYNC" = yes; then
+	AC_CHECK_HEADERS(sys/ipc.h sys/sem.h,,hard_bailout)
 fi
 
 ################################################################################
-AC_PATH_PROG(MODPROBE_CMD, modprobe)
+AC_PATH_TOOL(MODPROBE_CMD, modprobe)
 
-if test x$MODPROBE_CMD != x; then
+if test -n "$MODPROBE_CMD"; then
 	AC_DEFINE_UNQUOTED([MODPROBE_CMD], ["$MODPROBE_CMD"], [The path to 'modprobe', if available.])
 fi
 
@@ -1536,9 +1440,9 @@ LVM_PATH="$lvm_exec_prefix/sbin/lvm"
 AC_DEFINE_UNQUOTED(LVM_PATH, ["$LVM_PATH"], [Path to lvm binary.])
 
 if  test "$CLVMD" != none; then
-        clvmd_prefix=$ac_default_prefix
-        CLVMD_PATH="$clvmd_prefix/sbin/clvmd"
-        test "$prefix" != NONE && clvmd_prefix=$prefix
+	clvmd_prefix=$ac_default_prefix
+	CLVMD_PATH="$clvmd_prefix/sbin/clvmd"
+	test "$prefix" != NONE && clvmd_prefix=$prefix
 	AC_DEFINE_UNQUOTED(CLVMD_PATH, ["$CLVMD_PATH"], [Path to clvmd binary.])
 fi
 
@@ -1625,10 +1529,7 @@ AC_ARG_WITH(interface,
 	    AC_HELP_STRING([--with-interface=IFACE],
 			   [choose kernel interface (ioctl) [[ioctl]]]),
 	    interface=$withval, interface=ioctl)
-if [[ "x$interface" != xioctl ]];
-then
-  AC_MSG_ERROR(--with-interface=ioctl required. fs no longer supported.)
-fi
+test "$interface" != ioctl && AC_MSG_ERROR([--with-interface=ioctl required. fs no longer supported.])
 AC_MSG_RESULT($interface)
 
 ################################################################################
@@ -1859,8 +1760,6 @@ AC_OUTPUT
 
 test -n "$THIN_CONFIGURE_WARN" && AC_MSG_WARN([Support for thin provisioning is limited since some thin provisioning tools are missing!])
 
-test -n "$THIN_CHECK_VERSION_WARN" && AC_MSG_WARN(You should also install thin_check vsn 0.3.2 (or later) to use lvm2 thin provisioning)
+test -n "$THIN_CHECK_VERSION_WARN" && AC_MSG_WARN([You should also install thin_check vsn 0.3.2 (or later) to use lvm2 thin provisioning])
 
-if test x$ODIRECT != xyes; then
-  AC_MSG_WARN(O_DIRECT disabled: low-memory pvmove may lock up)
-fi
+test "$ODIRECT" != yes && AC_MSG_WARN([O_DIRECT disabled: low-memory pvmove may lock up])


