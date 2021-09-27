From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 27 Sep 2021 16:57:45 +0000 (GMT)
Subject: main - configure: replace AC_HELP_STRING with AS_
Message-ID: <20210927165745.5A093385840B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6a186dd1e85cecac84f0bc5cc32c0e47fd33994f
Commit:        6a186dd1e85cecac84f0bc5cc32c0e47fd33994f
Parent:        ff788ef19c498967ba83fb54c14700de7d4c274a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 24 18:06:28 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 27 18:56:13 2021 +0200

configure: replace AC_HELP_STRING with AS_

Upgrade to newer autoconf setup is approaching...
Will cause large set of configure changes.
---
 configure.ac | 196 +++++++++++++++++++++++++++++------------------------------
 1 file changed, 98 insertions(+), 98 deletions(-)

diff --git a/configure.ac b/configure.ac
index a65a957e0..6b1ea9854 100644
--- a/configure.ac
+++ b/configure.ac
@@ -176,7 +176,7 @@ AC_FUNC_VPRINTF
 dnl -- Disable dependency tracking
 AC_MSG_CHECKING(whether to enable dependency tracking)
 AC_ARG_ENABLE(dependency-tracking,
-	      AC_HELP_STRING([--disable-dependency-tracking],
+	      AS_HELP_STRING([--disable-dependency-tracking],
 			     [speeds up one-time build.]),
 	      USE_TRACKING=$enableval, USE_TRACKING=yes)
 AC_MSG_RESULT($USE_TRACKING)
@@ -185,7 +185,7 @@ AC_MSG_RESULT($USE_TRACKING)
 dnl -- Disable silence rules
 AC_MSG_CHECKING(whether to build silently)
 AC_ARG_ENABLE(silent-rules,
-	      AC_HELP_STRING([--disable-silent-rules], [disable silent building]),
+	      AS_HELP_STRING([--disable-silent-rules], [disable silent building]),
 	      SILENT_RULES=$enableval, SILENT_RULES=yes)
 AC_MSG_RESULT($SILENT_RULES)
 
@@ -194,7 +194,7 @@ AC_MSG_RESULT($SILENT_RULES)
 dnl -- Enables statically-linked tools
 AC_MSG_CHECKING(whether to use static linking)
 AC_ARG_ENABLE(static_link,
-	      AC_HELP_STRING([--enable-static_link],
+	      AS_HELP_STRING([--enable-static_link],
 			     [use this to link the tools to their libraries
 			      statically (default is dynamic linking]),
 	      STATIC_LINK=$enableval, STATIC_LINK=no)
@@ -224,7 +224,7 @@ test "x$exec_prefix" = xNONE && exec_prefix='${prefix}'
 dnl -- Setup the ownership of the files
 AC_MSG_CHECKING(file owner)
 AC_ARG_WITH(user,
-	    AC_HELP_STRING([--with-user=USER],
+	    AS_HELP_STRING([--with-user=USER],
 			   [set the owner of installed files [USER=]]),
 	    OWNER=$withval)
 AC_MSG_RESULT($OWNER)
@@ -234,7 +234,7 @@ test -n "$OWNER" && INSTALL="$INSTALL -o $OWNER"
 dnl -- Setup the group ownership of the files
 AC_MSG_CHECKING(group owner)
 AC_ARG_WITH(group,
-	    AC_HELP_STRING([--with-group=GROUP],
+	    AS_HELP_STRING([--with-group=GROUP],
 			   [set the group owner of installed files [GROUP=]]),
 	    GROUP=$withval)
 AC_MSG_RESULT($GROUP)
@@ -245,7 +245,7 @@ dnl -- Setup device node ownership
 AC_MSG_CHECKING(device node uid)
 
 AC_ARG_WITH(device-uid,
-	    AC_HELP_STRING([--with-device-uid=UID],
+	    AS_HELP_STRING([--with-device-uid=UID],
 			   [set the owner used for new device nodes [UID=0]]),
 	    DM_DEVICE_UID=$withval, DM_DEVICE_UID=0)
 AC_MSG_RESULT($DM_DEVICE_UID)
@@ -256,7 +256,7 @@ dnl -- Setup device group ownership
 AC_MSG_CHECKING(device node gid)
 
 AC_ARG_WITH(device-gid,
-	    AC_HELP_STRING([--with-device-gid=GID],
+	    AS_HELP_STRING([--with-device-gid=GID],
 			   [set the group used for new device nodes [GID=0]]),
 	    DM_DEVICE_GID=$withval, DM_DEVICE_GID=0)
 AC_MSG_RESULT($DM_DEVICE_GID)
@@ -267,7 +267,7 @@ dnl -- Setup device mode
 AC_MSG_CHECKING(device node mode)
 
 AC_ARG_WITH(device-mode,
-	    AC_HELP_STRING([--with-device-mode=MODE],
+	    AS_HELP_STRING([--with-device-mode=MODE],
 			   [set the mode used for new device nodes [MODE=0600]]),
 	    DM_DEVICE_MODE=$withval, DM_DEVICE_MODE=0600)
 AC_MSG_RESULT($DM_DEVICE_MODE)
@@ -275,7 +275,7 @@ AC_DEFINE_UNQUOTED([DM_DEVICE_MODE], [$DM_DEVICE_MODE], [Define default mode for
 
 AC_MSG_CHECKING(when to create device nodes)
 AC_ARG_WITH(device-nodes-on,
-	    AC_HELP_STRING([--with-device-nodes-on=ON],
+	    AS_HELP_STRING([--with-device-nodes-on=ON],
 			   [create nodes on resume or create [ON=resume]]),
 	    ADD_NODE=$withval, ADD_NODE=resume)
 case "$ADD_NODE" in
@@ -288,7 +288,7 @@ AC_DEFINE_UNQUOTED([DEFAULT_DM_ADD_NODE], $add_on, [Define default node creation
 
 AC_MSG_CHECKING(default name mangling)
 AC_ARG_WITH(default-name-mangling,
-	    AC_HELP_STRING([--with-default-name-mangling=MANGLING],
+	    AS_HELP_STRING([--with-default-name-mangling=MANGLING],
 			   [default name mangling: auto/none/hex [auto]]),
 	    MANGLING=$withval, MANGLING=auto)
 case "$MANGLING" in
@@ -304,7 +304,7 @@ AC_DEFINE_UNQUOTED([DEFAULT_DM_NAME_MANGLING], $mangling, [Define default name m
 dnl -- snapshots inclusion type
 AC_MSG_CHECKING(whether to include snapshots)
 AC_ARG_WITH(snapshots,
-	    AC_HELP_STRING([--with-snapshots=TYPE],
+	    AS_HELP_STRING([--with-snapshots=TYPE],
 			   [snapshot support: internal/none [internal]]),
 	    SNAPSHOTS=$withval, SNAPSHOTS=internal)
 AC_MSG_RESULT($SNAPSHOTS)
@@ -320,7 +320,7 @@ esac
 dnl -- mirrors inclusion type
 AC_MSG_CHECKING(whether to include mirrors)
 AC_ARG_WITH(mirrors,
-	    AC_HELP_STRING([--with-mirrors=TYPE],
+	    AS_HELP_STRING([--with-mirrors=TYPE],
 			   [mirror support: internal/none [internal]]),
 	    MIRRORS=$withval, MIRRORS=internal)
 AC_MSG_RESULT($MIRRORS)
@@ -335,11 +335,11 @@ esac
 ################################################################################
 dnl -- raid inclusion type
 AC_ARG_WITH(default-mirror-segtype,
-	    AC_HELP_STRING([--with-default-mirror-segtype=TYPE],
+	    AS_HELP_STRING([--with-default-mirror-segtype=TYPE],
 			   [default mirror segtype: raid1/mirror [raid1]]),
 			   DEFAULT_MIRROR_SEGTYPE=$withval, DEFAULT_MIRROR_SEGTYPE="raid1")
 AC_ARG_WITH(default-raid10-segtype,
-	    AC_HELP_STRING([--with-default-raid10-segtype=TYPE],
+	    AS_HELP_STRING([--with-default-raid10-segtype=TYPE],
 			   [default mirror segtype: raid10/mirror [raid10]]),
 			   DEFAULT_RAID10_SEGTYPE=$withval, DEFAULT_RAID10_SEGTYPE="raid10")
 
@@ -354,7 +354,7 @@ AC_DEFINE_UNQUOTED([DEFAULT_RAID10_SEGTYPE], ["$DEFAULT_RAID10_SEGTYPE"],
 
 ################################################################################
 AC_ARG_WITH(default-sparse-segtype,
-	    AC_HELP_STRING([--with-default-sparse-segtype=TYPE],
+	    AS_HELP_STRING([--with-default-sparse-segtype=TYPE],
 			   [default sparse segtype: thin/snapshot [thin]]),
 			   [ case "$withval" in
 				thin|snapshot) DEFAULT_SPARSE_SEGTYPE=$withval ;;
@@ -365,23 +365,23 @@ AC_ARG_WITH(default-sparse-segtype,
 dnl -- thin provisioning
 AC_MSG_CHECKING(whether to include thin provisioning)
 AC_ARG_WITH(thin,
-	    AC_HELP_STRING([--with-thin=TYPE],
+	    AS_HELP_STRING([--with-thin=TYPE],
 			   [thin provisioning support: internal/none [internal]]),
 	    THIN=$withval, THIN=internal)
 AC_ARG_WITH(thin-check,
-	    AC_HELP_STRING([--with-thin-check=PATH],
+	    AS_HELP_STRING([--with-thin-check=PATH],
 			   [thin_check tool: [autodetect]]),
 			   THIN_CHECK_CMD=$withval, THIN_CHECK_CMD="autodetect")
 AC_ARG_WITH(thin-dump,
-	    AC_HELP_STRING([--with-thin-dump=PATH],
+	    AS_HELP_STRING([--with-thin-dump=PATH],
 			   [thin_dump tool: [autodetect]]),
 			   THIN_DUMP_CMD=$withval, THIN_DUMP_CMD="autodetect")
 AC_ARG_WITH(thin-repair,
-	    AC_HELP_STRING([--with-thin-repair=PATH],
+	    AS_HELP_STRING([--with-thin-repair=PATH],
 			   [thin_repair tool: [autodetect]]),
 			   THIN_REPAIR_CMD=$withval, THIN_REPAIR_CMD="autodetect")
 AC_ARG_WITH(thin-restore,
-	    AC_HELP_STRING([--with-thin-restore=PATH],
+	    AS_HELP_STRING([--with-thin-restore=PATH],
 			   [thin_restore tool: [autodetect]]),
 			   THIN_RESTORE_CMD=$withval, THIN_RESTORE_CMD="autodetect")
 
@@ -400,7 +400,7 @@ AC_DEFINE_UNQUOTED([DEFAULT_SPARSE_SEGTYPE], ["$DEFAULT_SPARSE_SEGTYPE"],
 
 dnl -- thin_check needs-check flag
 AC_ARG_ENABLE(thin_check_needs_check,
-	      AC_HELP_STRING([--disable-thin_check_needs_check],
+	      AS_HELP_STRING([--disable-thin_check_needs_check],
 			     [required if thin_check version is < 0.3.0]),
 	      THIN_CHECK_NEEDS_CHECK=$enableval, THIN_CHECK_NEEDS_CHECK=yes)
 
@@ -484,23 +484,23 @@ AC_DEFINE_UNQUOTED([THIN_RESTORE_CMD], ["$THIN_RESTORE_CMD"],
 dnl -- cache inclusion type
 AC_MSG_CHECKING(whether to include cache)
 AC_ARG_WITH(cache,
-	    AC_HELP_STRING([--with-cache=TYPE],
+	    AS_HELP_STRING([--with-cache=TYPE],
 			   [cache support: internal/none [internal]]),
 			   CACHE=$withval, CACHE="internal")
 AC_ARG_WITH(cache-check,
-	    AC_HELP_STRING([--with-cache-check=PATH],
+	    AS_HELP_STRING([--with-cache-check=PATH],
 			   [cache_check tool: [autodetect]]),
 			   CACHE_CHECK_CMD=$withval, CACHE_CHECK_CMD="autodetect")
 AC_ARG_WITH(cache-dump,
-	    AC_HELP_STRING([--with-cache-dump=PATH],
+	    AS_HELP_STRING([--with-cache-dump=PATH],
 			   [cache_dump tool: [autodetect]]),
 			   CACHE_DUMP_CMD=$withval, CACHE_DUMP_CMD="autodetect")
 AC_ARG_WITH(cache-repair,
-	    AC_HELP_STRING([--with-cache-repair=PATH],
+	    AS_HELP_STRING([--with-cache-repair=PATH],
 			   [cache_repair tool: [autodetect]]),
 			   CACHE_REPAIR_CMD=$withval, CACHE_REPAIR_CMD="autodetect")
 AC_ARG_WITH(cache-restore,
-	    AC_HELP_STRING([--with-cache-restore=PATH],
+	    AS_HELP_STRING([--with-cache-restore=PATH],
 			   [cache_restore tool: [autodetect]]),
 			   CACHE_RESTORE_CMD=$withval, CACHE_RESTORE_CMD="autodetect")
 AC_MSG_RESULT($CACHE)
@@ -513,7 +513,7 @@ esac
 
 dnl -- cache_check needs-check flag
 AC_ARG_ENABLE(cache_check_needs_check,
-	      AC_HELP_STRING([--disable-cache_check_needs_check],
+	      AS_HELP_STRING([--disable-cache_check_needs_check],
 			     [required if cache_check version is < 0.5]),
 	      CACHE_CHECK_NEEDS_CHECK=$enableval, CACHE_CHECK_NEEDS_CHECK=yes)
 
@@ -608,14 +608,14 @@ AC_DEFINE_UNQUOTED([CACHE_RESTORE_CMD], ["$CACHE_RESTORE_CMD"],
 dnl -- cache inclusion type
 AC_MSG_CHECKING(whether to include vdo)
 AC_ARG_WITH(vdo,
-	    AC_HELP_STRING([--with-vdo=TYPE],
+	    AS_HELP_STRING([--with-vdo=TYPE],
 			   [vdo support: internal/none [internal]]),
 			   VDO=$withval, VDO="internal")
 
 AC_MSG_RESULT($VDO)
 
 AC_ARG_WITH(vdo-format,
-	    AC_HELP_STRING([--with-vdo-format=PATH],
+	    AS_HELP_STRING([--with-vdo-format=PATH],
 			   [vdoformat tool: [autodetect]]),
 			   VDO_FORMAT_CMD=$withval, VDO_FORMAT_CMD="autodetect")
 case "$VDO" in
@@ -641,13 +641,13 @@ AC_DEFINE_UNQUOTED([VDO_FORMAT_CMD], ["$VDO_FORMAT_CMD"],
 # Do we want to link lvm2 with a big library for vdoformating ?
 #
 #AC_ARG_WITH(vdo-include,
-#	    AC_HELP_STRING([--with-vdo-include=PATH],
+#	    AS_HELP_STRING([--with-vdo-include=PATH],
 #			   [vdo support: Path to utils headers: [/usr/include/vdo/utils]]),
 #			   VDO_INCLUDE=$withval, VDO_INCLUDE="/usr/include/vdo/utils")
 #AC_MSG_RESULT($VDO_INCLUDE)
 #
 #AC_ARG_WITH(vdo-lib,
-#            AC_HELP_STRING([--with-vdo-lib=PATH],
+#            AS_HELP_STRING([--with-vdo-lib=PATH],
 #                           [vdo support: Path to utils lib: [/usr/lib]]),
 #                           VDO_LIB=$withval, VDO_LIB="/usr/lib")
 #AC_MSG_RESULT($VDO_LIB)
@@ -656,7 +656,7 @@ AC_DEFINE_UNQUOTED([VDO_FORMAT_CMD], ["$VDO_FORMAT_CMD"],
 dnl -- writecache inclusion type
 AC_MSG_CHECKING(whether to include writecache)
 AC_ARG_WITH(writecache,
-	    AC_HELP_STRING([--with-writecache=TYPE],
+	    AS_HELP_STRING([--with-writecache=TYPE],
 			   [writecache support: internal/none [internal]]),
 			   WRITECACHE=$withval, WRITECACHE="internal")
 
@@ -674,7 +674,7 @@ esac
 dnl -- integrity inclusion type
 AC_MSG_CHECKING(whether to include integrity)
 AC_ARG_WITH(integrity,
-	    AC_HELP_STRING([--with-integrity=TYPE],
+	    AS_HELP_STRING([--with-integrity=TYPE],
 			   [integrity support: internal/none [internal]]),
 			   INTEGRITY=$withval, INTEGRITY="internal")
 
@@ -699,20 +699,20 @@ AC_ARG_VAR([AIO_LIBS], [linker flags for AIO])
 ################################################################################
 dnl -- Disable readline
 AC_ARG_ENABLE([readline],
-	      AC_HELP_STRING([--disable-readline], [disable readline support]),
+	      AS_HELP_STRING([--disable-readline], [disable readline support]),
 	      READLINE=$enableval, READLINE=maybe)
 
 ################################################################################
 dnl -- Disable editline
 AC_ARG_ENABLE([editline],
-	      AC_HELP_STRING([--enable-editline], [enable editline support]),
+	      AS_HELP_STRING([--enable-editline], [enable editline support]),
 	      EDITLINE=$enableval, EDITLINE=no)
 
 ################################################################################
 dnl -- Disable realtime clock support
 AC_MSG_CHECKING(whether to enable realtime support)
 AC_ARG_ENABLE(realtime,
-	      AC_HELP_STRING([--disable-realtime], [disable realtime clock support]),
+	      AS_HELP_STRING([--disable-realtime], [disable realtime clock support]),
 	      REALTIME=$enableval, REALTIME=yes)
 AC_MSG_RESULT($REALTIME)
 
@@ -720,12 +720,12 @@ AC_MSG_RESULT($REALTIME)
 dnl -- disable OCF resource agents
 AC_MSG_CHECKING(whether to enable OCF resource agents)
 AC_ARG_ENABLE(ocf,
-	      AC_HELP_STRING([--enable-ocf],
+	      AS_HELP_STRING([--enable-ocf],
 			     [enable Open Cluster Framework (OCF) compliant resource agents]),
 	      OCF=$enableval, OCF=no)
 AC_MSG_RESULT($OCF)
 AC_ARG_WITH(ocfdir,
-	    AC_HELP_STRING([--with-ocfdir=DIR],
+	    AS_HELP_STRING([--with-ocfdir=DIR],
 			   [install OCF files in [PREFIX/lib/ocf/resource.d/lvm2]]),
 	    OCFDIR=$withval, OCFDIR='${prefix}/lib/ocf/resource.d/lvm2')
 
@@ -750,7 +750,7 @@ AC_MSG_RESULT($RUN_DIR)
 dnl -- Set up pidfile and run directory
 AH_TEMPLATE(DEFAULT_PID_DIR)
 AC_ARG_WITH(default-pid-dir,
-	    AC_HELP_STRING([--with-default-pid-dir=PID_DIR],
+	    AS_HELP_STRING([--with-default-pid-dir=PID_DIR],
 			   [default directory to keep PID files in [autodetect]]),
 	    DEFAULT_PID_DIR="$withval", DEFAULT_PID_DIR=$RUN_DIR)
 AC_DEFINE_UNQUOTED(DEFAULT_PID_DIR, ["$DEFAULT_PID_DIR"],
@@ -758,7 +758,7 @@ AC_DEFINE_UNQUOTED(DEFAULT_PID_DIR, ["$DEFAULT_PID_DIR"],
 
 AH_TEMPLATE(DEFAULT_DM_RUN_DIR, [Name of default DM run directory.])
 AC_ARG_WITH(default-dm-run-dir,
-	    AC_HELP_STRING([--with-default-dm-run-dir=DM_RUN_DIR],
+	    AS_HELP_STRING([--with-default-dm-run-dir=DM_RUN_DIR],
 			   [default DM run directory [autodetect]]),
 	    DEFAULT_DM_RUN_DIR="$withval", DEFAULT_DM_RUN_DIR=$RUN_DIR)
 AC_DEFINE_UNQUOTED(DEFAULT_DM_RUN_DIR, ["$DEFAULT_DM_RUN_DIR"],
@@ -766,7 +766,7 @@ AC_DEFINE_UNQUOTED(DEFAULT_DM_RUN_DIR, ["$DEFAULT_DM_RUN_DIR"],
 
 AH_TEMPLATE(DEFAULT_RUN_DIR, [Name of default LVM run directory.])
 AC_ARG_WITH(default-run-dir,
-	    AC_HELP_STRING([--with-default-run-dir=RUN_DIR],
+	    AS_HELP_STRING([--with-default-run-dir=RUN_DIR],
 			   [default LVM run directory [autodetect_run_dir/lvm]]),
 	    DEFAULT_RUN_DIR="$withval", DEFAULT_RUN_DIR="$RUN_DIR/lvm")
 AC_DEFINE_UNQUOTED(DEFAULT_RUN_DIR, ["$DEFAULT_RUN_DIR"],
@@ -776,7 +776,7 @@ AC_DEFINE_UNQUOTED(DEFAULT_RUN_DIR, ["$DEFAULT_RUN_DIR"],
 dnl -- Build cluster mirror log daemon
 AC_MSG_CHECKING(whether to build cluster mirror log daemon)
 AC_ARG_ENABLE(cmirrord,
-	      AC_HELP_STRING([--enable-cmirrord],
+	      AS_HELP_STRING([--enable-cmirrord],
 			     [enable the cluster mirror log daemon]),
 	      CMIRRORD=$enableval, CMIRRORD=no)
 AC_MSG_RESULT($CMIRRORD)
@@ -787,7 +787,7 @@ BUILD_CMIRRORD=$CMIRRORD
 dnl -- cmirrord pidfile
 if test "$BUILD_CMIRRORD" = yes; then
 	AC_ARG_WITH(cmirrord-pidfile,
-		    AC_HELP_STRING([--with-cmirrord-pidfile=PATH],
+		    AS_HELP_STRING([--with-cmirrord-pidfile=PATH],
 				   [cmirrord pidfile [PID_DIR/cmirrord.pid]]),
 		    CMIRRORD_PIDFILE=$withval,
 		    CMIRRORD_PIDFILE="$DEFAULT_PID_DIR/cmirrord.pid")
@@ -808,7 +808,7 @@ fi
 ################################################################################
 dnl -- Enable debugging
 AC_MSG_CHECKING(whether to enable debugging)
-AC_ARG_ENABLE(debug, AC_HELP_STRING([--enable-debug], [enable debugging]),
+AC_ARG_ENABLE(debug, AS_HELP_STRING([--enable-debug], [enable debugging]),
 	      DEBUG=$enableval, DEBUG=no)
 AC_MSG_RESULT($DEBUG)
 
@@ -831,7 +831,7 @@ AC_SUBST(HAVE_WSYNCNAND)
 dnl -- Override optimisation
 AC_MSG_CHECKING(for C optimisation flag)
 AC_ARG_WITH(optimisation,
-	    AC_HELP_STRING([--with-optimisation=OPT],
+	    AS_HELP_STRING([--with-optimisation=OPT],
 			   [C optimisation flag [OPT=-O2]]),
 	    COPTIMISE_FLAG=$withval)
 AC_MSG_RESULT($COPTIMISE_FLAG)
@@ -840,7 +840,7 @@ AC_MSG_RESULT($COPTIMISE_FLAG)
 dnl -- Symbol versioning
 AC_MSG_CHECKING(whether to use symbol versioning)
 AC_ARG_WITH(symvers,
-	    AC_HELP_STRING([--with-symvers=STYLE],
+	    AS_HELP_STRING([--with-symvers=STYLE],
 			   [use symbol versioning of the shared library [default=gnu]]),
 			   [ case "$withval" in
 				gnu|no) symvers=$withval ;;
@@ -863,7 +863,7 @@ fi
 dnl -- Enable profiling
 AC_MSG_CHECKING(whether to gather gcov profiling data)
 AC_ARG_ENABLE(profiling,
-	      AC_HELP_STRING([--enable-profiling],
+	      AS_HELP_STRING([--enable-profiling],
 			     [gather gcov profiling data]),
 	      PROFILING=$enableval, PROFILING=no)
 AC_MSG_RESULT($PROFILING)
@@ -897,7 +897,7 @@ AC_DEFINE_UNQUOTED(TESTSUITE_DATA, ["$(eval echo $(eval echo $TESTSUITE_DATA))"]
 dnl -- Enable valgrind awareness of memory pools
 AC_MSG_CHECKING(whether to enable valgrind awareness of pools)
 AC_ARG_ENABLE(valgrind_pool,
-	      AC_HELP_STRING([--enable-valgrind-pool],
+	      AS_HELP_STRING([--enable-valgrind-pool],
 			     [enable valgrind awareness of pools]),
 	      VALGRIND_POOL=$enableval, VALGRIND_POOL=no)
 AC_MSG_RESULT($VALGRIND_POOL)
@@ -918,7 +918,7 @@ fi
 dnl -- Disable devmapper
 AC_MSG_CHECKING(whether to use device-mapper)
 AC_ARG_ENABLE(devmapper,
-	      AC_HELP_STRING([--disable-devmapper],
+	      AS_HELP_STRING([--disable-devmapper],
 			     [disable LVM2 device-mapper interaction]),
 	      DEVMAPPER=$enableval)
 AC_MSG_RESULT($DEVMAPPER)
@@ -931,7 +931,7 @@ fi
 dnl -- Build lvmpolld
 AC_MSG_CHECKING(whether to build lvmpolld)
 AC_ARG_ENABLE(lvmpolld,
-	      AC_HELP_STRING([--enable-lvmpolld],
+	      AS_HELP_STRING([--enable-lvmpolld],
 			     [enable the LVM Polling Daemon]),
 	      LVMPOLLD=$enableval)
 test -n "$LVMPOLLD" && BUILD_LVMPOLLD=$LVMPOLLD
@@ -943,7 +943,7 @@ BUILD_LVMLOCKD=no
 dnl -- Build lvmlockdsanlock
 AC_MSG_CHECKING(whether to build lvmlockdsanlock)
 AC_ARG_ENABLE(lvmlockd-sanlock,
-	      AC_HELP_STRING([--enable-lvmlockd-sanlock],
+	      AS_HELP_STRING([--enable-lvmlockd-sanlock],
 			     [enable the LVM lock daemon using sanlock]),
 	      LOCKDSANLOCK=$enableval)
 AC_MSG_RESULT($LOCKDSANLOCK)
@@ -961,7 +961,7 @@ fi
 dnl -- Build lvmlockddlm
 AC_MSG_CHECKING(whether to build lvmlockddlm)
 AC_ARG_ENABLE(lvmlockd-dlm,
-	      AC_HELP_STRING([--enable-lvmlockd-dlm],
+	      AS_HELP_STRING([--enable-lvmlockd-dlm],
 			     [enable the LVM lock daemon using dlm]),
 	      LOCKDDLM=$enableval)
 AC_MSG_RESULT($LOCKDDLM)
@@ -979,7 +979,7 @@ fi
 dnl -- Build lvmlockddlmcontrol
 AC_MSG_CHECKING(whether to build lvmlockddlmcontrol)
 AC_ARG_ENABLE(lvmlockd-dlmcontrol,
-	      AC_HELP_STRING([--enable-lvmlockd-dlmcontrol],
+	      AS_HELP_STRING([--enable-lvmlockd-dlmcontrol],
 			     [enable lvmlockd remote refresh using libdlmcontrol]),
 	      LOCKDDLM_CONTROL=$enableval)
 AC_MSG_RESULT($LOCKDDLM_CONTROL)
@@ -997,7 +997,7 @@ fi
 dnl -- Build lvmlockdidm
 AC_MSG_CHECKING(whether to build lvmlockdidm)
 AC_ARG_ENABLE(lvmlockd-idm,
-	      AC_HELP_STRING([--enable-lvmlockd-idm],
+	      AS_HELP_STRING([--enable-lvmlockd-idm],
 			     [enable the LVM lock daemon using idm]),
 	      LOCKDIDM=$enableval)
 AC_MSG_RESULT($LOCKDIDM)
@@ -1022,7 +1022,7 @@ if test "$BUILD_LVMLOCKD" = yes; then
 	AS_IF([test "$BUILD_LVMPOLLD" = no], [BUILD_LVMPOLLD=yes; AC_MSG_WARN([Enabling lvmpolld - required by lvmlockd.])])
 	AC_MSG_CHECKING([defaults for use_lvmlockd])
 	AC_ARG_ENABLE(use_lvmlockd,
-		      AC_HELP_STRING([--disable-use-lvmlockd],
+		      AS_HELP_STRING([--disable-use-lvmlockd],
 				     [disable usage of LVM lock daemon]),
 		      [case ${enableval} in
 		       yes) DEFAULT_USE_LVMLOCKD=1 ;;
@@ -1032,7 +1032,7 @@ if test "$BUILD_LVMLOCKD" = yes; then
 	AC_DEFINE([LVMLOCKD_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd.])
 
 	AC_ARG_WITH(lvmlockd-pidfile,
-		    AC_HELP_STRING([--with-lvmlockd-pidfile=PATH],
+		    AS_HELP_STRING([--with-lvmlockd-pidfile=PATH],
 				   [lvmlockd pidfile [PID_DIR/lvmlockd.pid]]),
 		    LVMLOCKD_PIDFILE=$withval,
 		    LVMLOCKD_PIDFILE="$DEFAULT_PID_DIR/lvmlockd.pid")
@@ -1049,7 +1049,7 @@ dnl -- Check lvmpolld
 if test "$BUILD_LVMPOLLD" = yes; then
 	AC_MSG_CHECKING([defaults for use_lvmpolld])
 	AC_ARG_ENABLE(use_lvmpolld,
-		      AC_HELP_STRING([--disable-use-lvmpolld],
+		      AS_HELP_STRING([--disable-use-lvmpolld],
 				     [disable usage of LVM Poll Daemon]),
 		      [case ${enableval} in
 		       yes) DEFAULT_USE_LVMPOLLD=1 ;;
@@ -1059,7 +1059,7 @@ if test "$BUILD_LVMPOLLD" = yes; then
 	AC_DEFINE([LVMPOLLD_SUPPORT], 1, [Define to 1 to include code that uses lvmpolld.])
 
 	AC_ARG_WITH(lvmpolld-pidfile,
-		    AC_HELP_STRING([--with-lvmpolld-pidfile=PATH],
+		    AS_HELP_STRING([--with-lvmpolld-pidfile=PATH],
 				   [lvmpolld pidfile [PID_DIR/lvmpolld.pid]]),
 		    LVMPOLLD_PIDFILE=$withval,
 		    LVMPOLLD_PIDFILE="$DEFAULT_PID_DIR/lvmpolld.pid")
@@ -1074,7 +1074,7 @@ AC_DEFINE_UNQUOTED(DEFAULT_USE_LVMPOLLD, [$DEFAULT_USE_LVMPOLLD],
 ################################################################################
 dnl -- Check dmfilemapd
 AC_MSG_CHECKING(whether to build dmfilemapd)
-AC_ARG_ENABLE(dmfilemapd, AC_HELP_STRING([--enable-dmfilemapd],
+AC_ARG_ENABLE(dmfilemapd, AS_HELP_STRING([--enable-dmfilemapd],
 					 [enable the dmstats filemap daemon]),
 	      BUILD_DMFILEMAPD=$enableval, BUILD_DMFILEMAPD=no)
 AC_MSG_RESULT($BUILD_DMFILEMAPD)
@@ -1089,7 +1089,7 @@ fi
 dnl -- Build notifydbus
 AC_MSG_CHECKING(whether to build notifydbus)
 AC_ARG_ENABLE(notify-dbus,
-	      AC_HELP_STRING([--enable-notify-dbus],
+	      AS_HELP_STRING([--enable-notify-dbus],
 			     [enable LVM notification using dbus]),
 	      NOTIFYDBUS_SUPPORT=$enableval, NOTIFYDBUS_SUPPORT=no)
 AC_MSG_RESULT($NOTIFYDBUS_SUPPORT)
@@ -1109,7 +1109,7 @@ fi
 
 dnl -- Enable blkid wiping functionality
 AC_ARG_ENABLE(blkid_wiping,
-	      AC_HELP_STRING([--disable-blkid_wiping],
+	      AS_HELP_STRING([--disable-blkid_wiping],
 			     [disable libblkid detection of signatures when wiping and use native code instead]),
 	      BLKID_WIPING=$enableval, BLKID_WIPING=maybe)
 
@@ -1136,7 +1136,7 @@ AC_DEFINE_UNQUOTED(DEFAULT_USE_BLKID_WIPING, [$DEFAULT_USE_BLKID_WIPING],
 dnl -- Enable udev-systemd protocol to instantiate a service for background jobs
 dnl -- Requires systemd version 205@least (including support for systemd-run)
 AC_ARG_ENABLE(udev-systemd-background-jobs,
-	      AC_HELP_STRING([--disable-udev-systemd-background-jobs],
+	      AS_HELP_STRING([--disable-udev-systemd-background-jobs],
 			     [disable udev-systemd protocol to instantiate a service for background job]),
 	      UDEV_SYSTEMD_BACKGROUND_JOBS=$enableval,
 	      UDEV_SYSTEMD_BACKGROUND_JOBS=maybe)
@@ -1159,7 +1159,7 @@ AC_MSG_RESULT($UDEV_SYSTEMD_BACKGROUND_JOBS)
 dnl -- Enable udev synchronisation
 AC_MSG_CHECKING(whether to enable synchronisation with udev processing)
 AC_ARG_ENABLE(udev_sync,
-	      AC_HELP_STRING([--enable-udev_sync],
+	      AS_HELP_STRING([--enable-udev_sync],
 			     [enable synchronisation with udev processing]),
 	      UDEV_SYNC=$enableval, UDEV_SYNC=no)
 AC_MSG_RESULT($UDEV_SYNC)
@@ -1177,14 +1177,14 @@ fi
 dnl -- Enable udev rules
 AC_MSG_CHECKING(whether to enable installation of udev rules required for synchronisation)
 AC_ARG_ENABLE(udev_rules,
-	      AC_HELP_STRING([--enable-udev_rules],
+	      AS_HELP_STRING([--enable-udev_rules],
 			     [install rule files needed for udev synchronisation]),
 	      UDEV_RULES=$enableval, UDEV_RULES=$UDEV_SYNC)
 AC_MSG_RESULT($UDEV_RULES)
 
 AC_MSG_CHECKING(whether to enable executable path detection in udev rules)
 AC_ARG_ENABLE(udev_rule_exec_detection,
-	      AC_HELP_STRING([--enable-udev-rule-exec-detection],
+	      AS_HELP_STRING([--enable-udev-rule-exec-detection],
 			     [enable executable path detection in udev rules]),
 	      UDEV_RULE_EXEC_DETECTION=$enableval, UDEV_RULE_EXEC_DETECTION=no)
 AC_MSG_RESULT($UDEV_RULE_EXEC_DETECTION)
@@ -1204,7 +1204,7 @@ fi
 ################################################################################
 dnl -- Compatibility mode
 AC_ARG_ENABLE(compat,
-	      AC_HELP_STRING([--enable-compat],
+	      AS_HELP_STRING([--enable-compat],
 			     [enable support for old device-mapper versions]),
 	      DM_COMPAT=$enableval, DM_COMPAT=no)
 
@@ -1217,7 +1217,7 @@ ioctl protocol is supported.])])
 ################################################################################
 dnl -- Compatible units suffix mode
 AC_ARG_ENABLE(units-compat,
-	      AC_HELP_STRING([--enable-units-compat],
+	      AS_HELP_STRING([--enable-units-compat],
 			     [enable output compatibility with old versions that
 			      that do not use KiB-style unit suffixes]),
 	      UNITS_COMPAT=$enableval, UNITS_COMPAT=no)
@@ -1229,7 +1229,7 @@ fi
 ################################################################################
 dnl -- Disable ioctl
 AC_ARG_ENABLE(ioctl,
-	      AC_HELP_STRING([--disable-ioctl],
+	      AS_HELP_STRING([--disable-ioctl],
 			     [disable ioctl calls to device-mapper in the kernel]),
 	      DM_IOCTLS=$enableval)
 AS_IF([test "$DM_IOCTLS" = yes],
@@ -1239,7 +1239,7 @@ AS_IF([test "$DM_IOCTLS" = yes],
 dnl -- Disable O_DIRECT
 AC_MSG_CHECKING(whether to enable O_DIRECT)
 AC_ARG_ENABLE(o_direct,
-	      AC_HELP_STRING([--disable-o_direct], [disable O_DIRECT]),
+	      AS_HELP_STRING([--disable-o_direct], [disable O_DIRECT]),
 	      ODIRECT=$enableval)
 AC_MSG_RESULT($ODIRECT)
 
@@ -1251,7 +1251,7 @@ fi
 dnl -- Enable cmdlib
 AC_MSG_CHECKING(whether to compile liblvm2cmd.so)
 AC_ARG_ENABLE(cmdlib,
-	      AC_HELP_STRING([--enable-cmdlib], [build shared command library]),
+	      AS_HELP_STRING([--enable-cmdlib], [build shared command library]),
 	      CMDLIB=$enableval, CMDLIB=no)
 AC_MSG_RESULT($CMDLIB)
 AC_SUBST([LVM2CMD_LIB])
@@ -1263,7 +1263,7 @@ test "$CMDLIB" = yes \
 dnl -- Enable D-Bus service
 AC_MSG_CHECKING(whether to include Python D-Bus support)
 AC_ARG_ENABLE(dbus-service,
-	      AC_HELP_STRING([--enable-dbus-service], [install D-Bus support]),
+	      AS_HELP_STRING([--enable-dbus-service], [install D-Bus support]),
 	      BUILD_LVMDBUSD=$enableval, BUILD_LVMDBUSD=no)
 AC_MSG_RESULT($BUILD_LVMDBUSD)
 AS_IF([test "$NOTIFYDBUS_SUPPORT" = yes && test "BUILD_LVMDBUSD" = yes],
@@ -1297,20 +1297,20 @@ fi
 ################################################################################
 dnl -- Enable pkg-config
 AC_ARG_ENABLE(pkgconfig,
-	      AC_HELP_STRING([--enable-pkgconfig], [install pkgconfig support]),
+	      AS_HELP_STRING([--enable-pkgconfig], [install pkgconfig support]),
 	      PKGCONFIG=$enableval, PKGCONFIG=no)
 
 ################################################################################
 dnl -- Enable installation of writable files by user
 AC_ARG_ENABLE(write_install,
-	      AC_HELP_STRING([--enable-write_install],
+	      AS_HELP_STRING([--enable-write_install],
 			     [install user writable files]),
 	      WRITE_INSTALL=$enableval, WRITE_INSTALL=no)
 
 ################################################################################
 dnl -- Enable fsadm
 AC_MSG_CHECKING(whether to install fsadm)
-AC_ARG_ENABLE(fsadm, AC_HELP_STRING([--disable-fsadm], [disable fsadm]),
+AC_ARG_ENABLE(fsadm, AS_HELP_STRING([--disable-fsadm], [disable fsadm]),
 	      FSADM=$enableval)
 AC_MSG_RESULT($FSADM)
 
@@ -1318,21 +1318,21 @@ AC_MSG_RESULT($FSADM)
 ################################################################################
 dnl -- Enable lvm_import_vdo
 AC_MSG_CHECKING(whether to install lvm_import_vdo)
-AC_ARG_ENABLE(lvmimportvdo, AC_HELP_STRING([--disable-lvmimportvdo], [disable lvm_import_vdo]),
+AC_ARG_ENABLE(lvmimportvdo, AS_HELP_STRING([--disable-lvmimportvdo], [disable lvm_import_vdo]),
 	      LVMIMPORTVDO=$enableval)
 AC_MSG_RESULT($LVMIMPORTVDO)
 
 ################################################################################
 dnl -- Enable blkdeactivate
 AC_MSG_CHECKING(whether to install blkdeactivate)
-AC_ARG_ENABLE(blkdeactivate, AC_HELP_STRING([--disable-blkdeactivate], [disable blkdeactivate]),
+AC_ARG_ENABLE(blkdeactivate, AS_HELP_STRING([--disable-blkdeactivate], [disable blkdeactivate]),
 	      BLKDEACTIVATE=$enableval)
 AC_MSG_RESULT($BLKDEACTIVATE)
 
 ################################################################################
 dnl -- enable dmeventd handling
 AC_MSG_CHECKING(whether to use dmeventd)
-AC_ARG_ENABLE(dmeventd, AC_HELP_STRING([--enable-dmeventd],
+AC_ARG_ENABLE(dmeventd, AS_HELP_STRING([--enable-dmeventd],
 				       [enable the device-mapper event daemon]),
 	      BUILD_DMEVENTD=$enableval, BUILD_DMEVENTD=no)
 AC_MSG_RESULT($BUILD_DMEVENTD)
@@ -1390,7 +1390,7 @@ AC_CHECK_LIB([pthread], [pthread_mutex_lock],
 dnl -- Disable selinux
 AC_MSG_CHECKING(whether to enable selinux support)
 AC_ARG_ENABLE(selinux,
-	      AC_HELP_STRING([--disable-selinux], [disable selinux support]),
+	      AS_HELP_STRING([--disable-selinux], [disable selinux support]),
 	      SELINUX=$enableval)
 AC_MSG_RESULT($SELINUX)
 
@@ -1427,7 +1427,7 @@ int bar(void) { return ioctl(0, BLKZEROOUT, 0); }]
 
 
 AC_ARG_ENABLE(blkzeroout,
-	      AC_HELP_STRING([--disable-blkzeroout],
+	      AS_HELP_STRING([--disable-blkzeroout],
 			     [do not use BLKZEROOUT for device zeroing]),
 	      BLKZEROOUT=$enableval, BLKZEROOUT=yes)
 
@@ -1532,7 +1532,7 @@ fi
 dnl -- Internationalisation stuff
 AC_MSG_CHECKING(whether to enable internationalisation)
 AC_ARG_ENABLE(nls,
-	      AC_HELP_STRING([--enable-nls], [enable Native Language Support]),
+	      AS_HELP_STRING([--enable-nls], [enable Native Language Support]),
 	      INTL=$enableval, INTL=no)
 AC_MSG_RESULT($INTL)
 
@@ -1544,7 +1544,7 @@ if test "$INTL" = yes; then
 	AS_IF([test -z "$MSGFMT"], [AC_MSG_ERROR([msgfmt not found in path $PATH])])
 
 	AC_ARG_WITH(localedir,
-		    AC_HELP_STRING([--with-localedir=DIR],
+		    AS_HELP_STRING([--with-localedir=DIR],
 				   [locale-dependent data [DATAROOTDIR/locale]]),
 		    localedir=$withval, localedir=${localedir-'${datarootdir}/locale'})
 	AC_DEFINE_UNQUOTED([INTL_PACKAGE], ["$INTL_PACKAGE"], [Internalization package])
@@ -1555,35 +1555,35 @@ fi
 ################################################################################
 dnl -- FIXME: need to switch to regular option here  --sysconfdir
 AC_ARG_WITH(confdir,
-	    AC_HELP_STRING([--with-confdir=DIR],
+	    AS_HELP_STRING([--with-confdir=DIR],
 			   [configuration files in DIR [/etc]]),
 	    CONFDIR=$withval, CONFDIR='/etc')
 AC_DEFINE_UNQUOTED(DEFAULT_ETC_DIR, ["$CONFDIR"],
 		   [Default system configuration directory.])
 
 AC_ARG_WITH(staticdir,
-	    AC_HELP_STRING([--with-staticdir=DIR],
+	    AS_HELP_STRING([--with-staticdir=DIR],
 			   [static binaries in DIR [EPREFIX/sbin]]),
 	    STATICDIR=$withval, STATICDIR='${exec_prefix}/sbin')
 
 AC_ARG_WITH(usrlibdir,
-	    AC_HELP_STRING([--with-usrlibdir=DIR],
+	    AS_HELP_STRING([--with-usrlibdir=DIR],
 			   [usrlib in DIR [PREFIX/lib]]),
 	    usrlibdir=$withval, usrlibdir='${prefix}/lib')
 
 AC_ARG_WITH(usrsbindir,
-	    AC_HELP_STRING([--with-usrsbindir=DIR],
+	    AS_HELP_STRING([--with-usrsbindir=DIR],
 			   [usrsbin executables in DIR [PREFIX/sbin]]),
 	    usrsbindir=$withval, usrsbindir='${prefix}/sbin')
 
 ################################################################################
 AC_ARG_WITH(udev_prefix,
-	    AC_HELP_STRING([--with-udev-prefix=UPREFIX],
+	    AS_HELP_STRING([--with-udev-prefix=UPREFIX],
 			   [install udev rule files in UPREFIX [EPREFIX]]),
 	    udev_prefix=$withval, udev_prefix='${exec_prefix}')
 
 AC_ARG_WITH(udevdir,
-	    AC_HELP_STRING([--with-udevdir=DIR],
+	    AS_HELP_STRING([--with-udevdir=DIR],
 			   [udev rules in DIR [UPREFIX/lib/udev/rules.d]]),
 	    udevdir=$withval, udevdir='${udev_prefix}/lib/udev/rules.d')
 
@@ -1591,7 +1591,7 @@ AC_ARG_WITH(udevdir,
 dnl -- Get the systemd system unit dir value from pkg_config automatically if value not given explicitly.
 dnl -- This follows the recommendation for systemd integration best practices mentioned in daemon(7) manpage.
 AC_ARG_WITH(systemdsystemunitdir,
-	    AC_HELP_STRING([--with-systemdsystemunitdir=DIR],
+	    AS_HELP_STRING([--with-systemdsystemunitdir=DIR],
 			   [systemd service files in DIR]),
 	    systemdsystemunitdir=$withval,
 	    pkg_config_init
@@ -1605,7 +1605,7 @@ test -z "$systemdutildir" && systemdutildir='${exec_prefix}/lib/systemd';
 
 ################################################################################
 AC_ARG_WITH(tmpfilesdir,
-	    AC_HELP_STRING([--with-tmpfilesdir=DIR],
+	    AS_HELP_STRING([--with-tmpfilesdir=DIR],
 			   [install configuration files for management of volatile files and directories in DIR [PREFIX/lib/tmpfiles.d]]),
 			   tmpfilesdir=$withval, tmpfilesdir='${prefix}/lib/tmpfiles.d')
 ################################################################################
@@ -1684,7 +1684,7 @@ AC_DEFINE_UNQUOTED(LVMIMPORTVDO_PATH, ["$LVMIMPORTVDO_PATH"], [Path to lvm_impor
 dnl -- dmeventd pidfile and executable path
 if test "$BUILD_DMEVENTD" = yes; then
 	AC_ARG_WITH(dmeventd-pidfile,
-		    AC_HELP_STRING([--with-dmeventd-pidfile=PATH],
+		    AS_HELP_STRING([--with-dmeventd-pidfile=PATH],
 				   [dmeventd pidfile [PID_DIR/dmeventd.pid]]),
 		    DMEVENTD_PIDFILE=$withval,
 		    DMEVENTD_PIDFILE="$DEFAULT_PID_DIR/dmeventd.pid")
@@ -1694,7 +1694,7 @@ fi
 
 if test "$BUILD_DMEVENTD" = yes; then
 	AC_ARG_WITH(dmeventd-path,
-		    AC_HELP_STRING([--with-dmeventd-path=PATH],
+		    AS_HELP_STRING([--with-dmeventd-path=PATH],
 				   [dmeventd path [EPREFIX/sbin/dmeventd]]),
 		    DMEVENTD_PATH=$withval,
 		    DMEVENTD_PATH="$SBINDIR/dmeventd")
@@ -1706,35 +1706,35 @@ fi
 dnl -- various defaults
 dnl -- FIXME: need to switch to regular option here  --sysconfdir
 AC_ARG_WITH(default-system-dir,
-	    AC_HELP_STRING([--with-default-system-dir=DIR],
+	    AS_HELP_STRING([--with-default-system-dir=DIR],
 			   [default LVM system directory [/etc/lvm]]),
 	    DEFAULT_SYS_DIR=$withval, DEFAULT_SYS_DIR="/etc/lvm")
 AC_DEFINE_UNQUOTED(DEFAULT_SYS_DIR, ["$DEFAULT_SYS_DIR"],
 		   [Path to LVM system directory.])
 
 AC_ARG_WITH(default-profile-subdir,
-	    AC_HELP_STRING([--with-default-profile-subdir=SUBDIR],
+	    AS_HELP_STRING([--with-default-profile-subdir=SUBDIR],
 			   [default configuration profile subdir [profile]]),
 	    DEFAULT_PROFILE_SUBDIR=$withval, DEFAULT_PROFILE_SUBDIR=profile)
 AC_DEFINE_UNQUOTED(DEFAULT_PROFILE_SUBDIR, ["$DEFAULT_PROFILE_SUBDIR"],
 		   [Name of default configuration profile subdirectory.])
 
 AC_ARG_WITH(default-archive-subdir,
-	    AC_HELP_STRING([--with-default-archive-subdir=SUBDIR],
+	    AS_HELP_STRING([--with-default-archive-subdir=SUBDIR],
 			   [default metadata archive subdir [archive]]),
 	    DEFAULT_ARCHIVE_SUBDIR=$withval, DEFAULT_ARCHIVE_SUBDIR=archive)
 AC_DEFINE_UNQUOTED(DEFAULT_ARCHIVE_SUBDIR, ["$DEFAULT_ARCHIVE_SUBDIR"],
 		   [Name of default metadata archive subdirectory.])
 
 AC_ARG_WITH(default-backup-subdir,
-	    AC_HELP_STRING([--with-default-backup-subdir=SUBDIR],
+	    AS_HELP_STRING([--with-default-backup-subdir=SUBDIR],
 			   [default metadata backup subdir [backup]]),
 	    DEFAULT_BACKUP_SUBDIR=$withval, DEFAULT_BACKUP_SUBDIR=backup)
 AC_DEFINE_UNQUOTED(DEFAULT_BACKUP_SUBDIR, ["$DEFAULT_BACKUP_SUBDIR"],
                    [Name of default metadata backup subdirectory.])
 
 AC_ARG_WITH(default-cache-subdir,
-	    AC_HELP_STRING([--with-default-cache-subdir=SUBDIR],
+	    AS_HELP_STRING([--with-default-cache-subdir=SUBDIR],
 			   [default metadata cache subdir [cache]]),
 	    DEFAULT_CACHE_SUBDIR=$withval, DEFAULT_CACHE_SUBDIR=cache)
 AC_DEFINE_UNQUOTED(DEFAULT_CACHE_SUBDIR, ["$DEFAULT_CACHE_SUBDIR"],
@@ -1746,7 +1746,7 @@ test -d "$DEFAULT_SYS_LOCK_DIR" || DEFAULT_SYS_LOCK_DIR="/var/lock"
 
 # Support configurable locking subdir for lvm
 AC_ARG_WITH(default-locking-dir,
-	    AC_HELP_STRING([--with-default-locking-dir=DIR],
+	    AS_HELP_STRING([--with-default-locking-dir=DIR],
 			   [default locking directory [autodetect_lock_dir/lvm]]),
 	    DEFAULT_LOCK_DIR=$withval,
 	    [AC_MSG_CHECKING(for default lock directory)
@@ -1759,7 +1759,7 @@ AC_DEFINE_UNQUOTED(DEFAULT_LOCK_DIR, ["$DEFAULT_LOCK_DIR"],
 dnl -- which kernel interface to use (ioctl only)
 AC_MSG_CHECKING(for kernel interface choice)
 AC_ARG_WITH(interface,
-	    AC_HELP_STRING([--with-interface=IFACE],
+	    AS_HELP_STRING([--with-interface=IFACE],
 			   [choose kernel interface (ioctl) [ioctl]]),
 	    interface=$withval, interface=ioctl)
 test "$interface" != ioctl && AC_MSG_ERROR([--with-interface=ioctl required. fs no longer supported.])


