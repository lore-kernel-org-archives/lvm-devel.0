From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 25 Oct 2017 16:04:37 -0400
Subject: master - configure: improve support for sbindir path
Message-ID: <201710252004.v9PK4bYH029357@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3f59969c3fcbff2a3bb177fc07262f1ea569e134
Commit:        3f59969c3fcbff2a3bb177fc07262f1ea569e134
Parent:        f32ef63b6c97fbf95568fee88aad8ef92e732c5a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 25 16:49:17 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 25 22:02:54 2017 +0200

configure: improve support for sbindir path

Introduce few more AC_SUBST vars for usage in *.in generation.

In some case we want to replace i.e. $sbindir with full path
instead of current ${exec_prefix}/sbin.

This patch provides:

USRSBINDIR
SBINDIR
DEFAULT_SYS_LOCK_DIR
SYSCONFDIR

At the same time properly use sbindir & usrsbindir with
lvm, fsadm, clvmd from one primary definition.
---
 configure    |   51 +++++++++++++++++++++++++++++++--------------------
 configure.in |   45 ++++++++++++++++++++++++++-------------------
 2 files changed, 57 insertions(+), 39 deletions(-)

diff --git a/configure b/configure
index e5f8e19..fc0a27a 100755
--- a/configure
+++ b/configure
@@ -643,6 +643,7 @@ LVMETAD_PIDFILE
 DMEVENTD_PIDFILE
 WRITE_INSTALL
 VALGRIND_POOL
+USRSBINDIR
 USE_TRACKING
 UDEV_HAS_BUILTIN_BLKID
 UDEV_RULE_EXEC_DETECTION
@@ -656,8 +657,10 @@ TESTING
 STATIC_LINK
 STATICDIR
 SNAPSHOTS
+SYSCONFDIR
 SELINUX_PC
 SELINUX_LIBS
+SBINDIR
 REPLICATORS
 READLINE_LIBS
 RT_LIBS
@@ -710,6 +713,7 @@ DEFAULT_USE_LVMLOCKD
 DEFAULT_USE_LVMPOLLD
 DEFAULT_USE_LVMETAD
 DEFAULT_USE_BLKID_WIPING
+DEFAULT_SYS_LOCK_DIR
 DEFAULT_SYS_DIR
 DEFAULT_SPARSE_SEGTYPE
 DEFAULT_RUN_DIR
@@ -8238,9 +8242,14 @@ $as_echo "$ac_cv_flag_HAVE_FULL_RELRO" >&6; }
 
 ################################################################################
 
-if test "$prefix" = NONE; then
-  datarootdir=${ac_default_prefix}/share
-fi
+
+################################################################################
+test "$exec_prefix" = NONE -a "$prefix" = NONE && exec_prefix=""
+
+test "x$prefix" = xNONE && prefix=$ac_default_prefix
+# Let make expand exec_prefix.
+test "x$exec_prefix" = xNONE && exec_prefix='${prefix}'
+
 
 ################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking file owner" >&5
@@ -12890,7 +12899,7 @@ if ${am_cv_pathless_PYTHON+:} false; then :
   $as_echo_n "(cached) " >&6
 else
 
-	for am_cv_pathless_PYTHON in python python2 python3 python3.3 python3.2 python3.1 python3.0 python2.7  python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0 none; do
+	for am_cv_pathless_PYTHON in python python2 python3 python3.5 python3.4 python3.3 python3.2 python3.1 python3.0 python2.7  python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0 none; do
 	  test "$am_cv_pathless_PYTHON" = none && break
 	  prog="import sys
 # split strings by '.' and convert to numeric.  Append some zeros
@@ -13458,7 +13467,7 @@ if ${am_cv_pathless_PYTHON+:} false; then :
   $as_echo_n "(cached) " >&6
 else
 
-	for am_cv_pathless_PYTHON in python python2 python3 python3.3 python3.2 python3.1 python3.0 python2.7  python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0 none; do
+	for am_cv_pathless_PYTHON in python python2 python3 python3.5 python3.4 python3.3 python3.2 python3.1 python3.0 python2.7  python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0 none; do
 	  test "$am_cv_pathless_PYTHON" = none && break
 	  prog="import sys
 # split strings by '.' and convert to numeric.  Append some zeros
@@ -14014,9 +14023,6 @@ fi
 
 
 ################################################################################
-test "$exec_prefix" = NONE -a "$prefix" = NONE && exec_prefix=""
-
-################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for dlopen in -ldl" >&5
 $as_echo_n "checking for dlopen in -ldl... " >&6; }
 if ${ac_cv_lib_dl_dlopen+:} false; then :
@@ -15397,28 +15403,25 @@ _ACEOF
 
 fi
 
+SYSCONFDIR="$(eval echo $(eval echo $sysconfdir))"
 
-lvm_exec_prefix=$exec_prefix
-test "$lvm_exec_prefix" = NONE && lvm_exec_prefix=$prefix
-test "$lvm_exec_prefix" = NONE && lvm_exec_prefix=$ac_default_prefix
-LVM_PATH="$lvm_exec_prefix/sbin/lvm"
+SBINDIR="$(eval echo $(eval echo $sbindir))"
+LVM_PATH="$SBINDIR/lvm"
 
 cat >>confdefs.h <<_ACEOF
 #define LVM_PATH "$LVM_PATH"
 _ACEOF
 
 
-clvmd_prefix=$ac_default_prefix
-test "$prefix" != NONE && clvmd_prefix=$prefix
-CLVMD_PATH="$clvmd_prefix/sbin/clvmd"
+USRSBINDIR="$(eval echo $(eval echo $usrsbindir))"
+CLVMD_PATH="$USRSBINDIR/clvmd"
 
 cat >>confdefs.h <<_ACEOF
 #define CLVMD_PATH "$CLVMD_PATH"
 _ACEOF
 
 
-
-FSADM_PATH="$lvm_exec_prefix/sbin/fsadm"
+FSADM_PATH="$SBINDIR/fsadm"
 
 cat >>confdefs.h <<_ACEOF
 #define FSADM_PATH "$FSADM_PATH"
@@ -15448,7 +15451,7 @@ if test "$BUILD_DMEVENTD" = yes; then
 if test "${with_dmeventd_path+set}" = set; then :
   withval=$with_dmeventd_path; DMEVENTD_PATH=$withval
 else
-  DMEVENTD_PATH="$lvm_exec_prefix/sbin/dmeventd"
+  DMEVENTD_PATH="$SBINDIR/dmeventd"
 fi
 
 
@@ -15529,6 +15532,11 @@ cat >>confdefs.h <<_ACEOF
 _ACEOF
 
 
+# Select default system locking dir, prefer /run/lock over /var/lock
+DEFAULT_SYS_LOCK_DIR="$RUN_DIR/lock"
+test -d "$DEFAULT_SYS_LOCK_DIR" || DEFAULT_SYS_LOCK_DIR="/var/lock"
+
+# Support configurable locking subdir for lvm
 
 # Check whether --with-default-locking-dir was given.
 if test "${with_default_locking_dir+set}" = set; then :
@@ -15536,8 +15544,7 @@ if test "${with_default_locking_dir+set}" = set; then :
 else
   { $as_echo "$as_me:${as_lineno-$LINENO}: checking for default lock directory" >&5
 $as_echo_n "checking for default lock directory... " >&6; }
-	     DEFAULT_LOCK_DIR="$RUN_DIR/lock/lvm"
-	     test -d "$RUN_DIR/lock" || DEFAULT_LOCK_DIR="/var/lock/lvm"
+	     DEFAULT_LOCK_DIR="$DEFAULT_SYS_LOCK_DIR/lvm"
 	     { $as_echo "$as_me:${as_lineno-$LINENO}: result: $DEFAULT_LOCK_DIR" >&5
 $as_echo "$DEFAULT_LOCK_DIR" >&6; }
 fi
@@ -15766,6 +15773,10 @@ _ACEOF
 
 
 
+
+
+
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile include/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaem
 on/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_
 red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
diff --git a/configure.in b/configure.in
index 1366dc4..7d4f5b3 100644
--- a/configure.in
+++ b/configure.in
@@ -191,9 +191,15 @@ AC_SUBST(HAVE_FULL_RELRO)
 ################################################################################
 dnl -- Prefix is /usr by default, the exec_prefix default is setup later
 AC_PREFIX_DEFAULT(/usr)
-if test "$prefix" = NONE; then
-  datarootdir=${ac_default_prefix}/share
-fi
+
+################################################################################
+dnl -- Clear default exec_prefix - install into /sbin rather than /usr/sbin
+test "$exec_prefix" = NONE -a "$prefix" = NONE && exec_prefix=""
+
+test "x$prefix" = xNONE && prefix=$ac_default_prefix
+# Let make expand exec_prefix.
+test "x$exec_prefix" = xNONE && exec_prefix='${prefix}'
+
 
 ################################################################################
 dnl -- Setup the ownership of the files
@@ -1599,10 +1605,6 @@ AC_CHECK_LIB(c, canonicalize_file_name,
     [Define to 1 if canonicalize_file_name is available.]))
 
 ################################################################################
-dnl -- Clear default exec_prefix - install into /sbin rather than /usr/sbin
-test "$exec_prefix" = NONE -a "$prefix" = NONE && exec_prefix=""
-
-################################################################################
 dnl -- Check for dlopen
 AC_CHECK_LIB(dl, dlopen,
 	     [AC_DEFINE([HAVE_LIBDL], 1, [Define to 1 if dynamic libraries are available.])
@@ -1874,20 +1876,17 @@ if test -n "$MODPROBE_CMD"; then
 	AC_DEFINE_UNQUOTED([MODPROBE_CMD], ["$MODPROBE_CMD"], [The path to 'modprobe', if available.])
 fi
 
+SYSCONFDIR="$(eval echo $(eval echo $sysconfdir))"
 
-lvm_exec_prefix=$exec_prefix
-test "$lvm_exec_prefix" = NONE && lvm_exec_prefix=$prefix
-test "$lvm_exec_prefix" = NONE && lvm_exec_prefix=$ac_default_prefix
-LVM_PATH="$lvm_exec_prefix/sbin/lvm"
+SBINDIR="$(eval echo $(eval echo $sbindir))"
+LVM_PATH="$SBINDIR/lvm"
 AC_DEFINE_UNQUOTED(LVM_PATH, ["$LVM_PATH"], [Path to lvm binary.])
 
-clvmd_prefix=$ac_default_prefix
-test "$prefix" != NONE && clvmd_prefix=$prefix
-CLVMD_PATH="$clvmd_prefix/sbin/clvmd"
+USRSBINDIR="$(eval echo $(eval echo $usrsbindir))"
+CLVMD_PATH="$USRSBINDIR/clvmd"
 AC_DEFINE_UNQUOTED(CLVMD_PATH, ["$CLVMD_PATH"], [Path to clvmd binary.])
 
-
-FSADM_PATH="$lvm_exec_prefix/sbin/fsadm"
+FSADM_PATH="$SBINDIR/fsadm"
 AC_DEFINE_UNQUOTED(FSADM_PATH, ["$FSADM_PATH"], [Path to fsadm binary.])
 
 ################################################################################
@@ -1907,7 +1906,7 @@ if test "$BUILD_DMEVENTD" = yes; then
 		    AC_HELP_STRING([--with-dmeventd-path=PATH],
 				   [dmeventd path [EPREFIX/sbin/dmeventd]]),
 		    DMEVENTD_PATH=$withval,
-		    DMEVENTD_PATH="$lvm_exec_prefix/sbin/dmeventd")
+		    DMEVENTD_PATH="$SBINDIR/dmeventd")
 	AC_DEFINE_UNQUOTED(DMEVENTD_PATH, ["$DMEVENTD_PATH"],
 			   [Path to dmeventd binary.])
 fi
@@ -1950,13 +1949,17 @@ AC_ARG_WITH(default-cache-subdir,
 AC_DEFINE_UNQUOTED(DEFAULT_CACHE_SUBDIR, ["$DEFAULT_CACHE_SUBDIR"],
 		   [Name of default metadata cache subdirectory.])
 
+# Select default system locking dir, prefer /run/lock over /var/lock
+DEFAULT_SYS_LOCK_DIR="$RUN_DIR/lock"
+test -d "$DEFAULT_SYS_LOCK_DIR" || DEFAULT_SYS_LOCK_DIR="/var/lock"
+
+# Support configurable locking subdir for lvm
 AC_ARG_WITH(default-locking-dir,
 	    AC_HELP_STRING([--with-default-locking-dir=DIR],
 			   [default locking directory [autodetect_lock_dir/lvm]]),
 	    DEFAULT_LOCK_DIR=$withval,
 	    [AC_MSG_CHECKING(for default lock directory)
-	     DEFAULT_LOCK_DIR="$RUN_DIR/lock/lvm"
-	     test -d "$RUN_DIR/lock" || DEFAULT_LOCK_DIR="/var/lock/lvm"
+	     DEFAULT_LOCK_DIR="$DEFAULT_SYS_LOCK_DIR/lvm"
 	     AC_MSG_RESULT($DEFAULT_LOCK_DIR)])
 AC_DEFINE_UNQUOTED(DEFAULT_LOCK_DIR, ["$DEFAULT_LOCK_DIR"],
 		   [Name of default locking directory.])
@@ -2051,6 +2054,7 @@ AC_SUBST(DEFAULT_RAID10_SEGTYPE)
 AC_SUBST(DEFAULT_RUN_DIR)
 AC_SUBST(DEFAULT_SPARSE_SEGTYPE)
 AC_SUBST(DEFAULT_SYS_DIR)
+AC_SUBST(DEFAULT_SYS_LOCK_DIR)
 AC_SUBST(DEFAULT_USE_BLKID_WIPING)
 AC_SUBST(DEFAULT_USE_LVMETAD)
 AC_SUBST(DEFAULT_USE_LVMPOLLD)
@@ -2115,8 +2119,10 @@ AC_SUBST(SACKPT_CFLAGS)
 AC_SUBST(SACKPT_LIBS)
 AC_SUBST(SALCK_CFLAGS)
 AC_SUBST(SALCK_LIBS)
+AC_SUBST(SBINDIR)
 AC_SUBST(SELINUX_LIBS)
 AC_SUBST(SELINUX_PC)
+AC_SUBST(SYSCONFDIR)
 AC_SUBST(SYSTEMD_LIBS)
 AC_SUBST(SNAPSHOTS)
 AC_SUBST(STATICDIR)
@@ -2139,6 +2145,7 @@ AC_SUBST(UDEV_SYSTEMD_BACKGROUND_JOBS)
 AC_SUBST(UDEV_RULE_EXEC_DETECTION)
 AC_SUBST(UDEV_HAS_BUILTIN_BLKID)
 AC_SUBST(USE_TRACKING)
+AC_SUBST(USRSBINDIR)
 AC_SUBST(VALGRIND_POOL)
 AC_SUBST(WRITE_INSTALL)
 AC_SUBST(DMEVENTD_PIDFILE)


