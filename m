From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  2 Jul 2015 20:44:26 +0000 (UTC)
Subject: master - Add lvmlockd
Message-ID: <20150702204426.305D960C94@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fe70b03de2956b6493993990d9fb1cde3f41ebcd
Commit:        fe70b03de2956b6493993990d9fb1cde3f41ebcd
Parent:        a32d5a4afc5bdc4585132765fb02739a8f352e49
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 5 14:00:44 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jul 2 15:42:26 2015 -0500

Add lvmlockd

---
 configure                                          |  246 +-
 configure.in                                       |   57 +
 daemons/Makefile.in                                |    8 +-
 daemons/lvmlockd/Makefile.in                       |   53 +
 daemons/lvmlockd/lvmlockctl.c                      |  635 +++
 daemons/lvmlockd/lvmlockd-client.h                 |   49 +
 daemons/lvmlockd/lvmlockd-core.c                   | 5715 ++++++++++++++++++++
 daemons/lvmlockd/lvmlockd-dlm.c                    |  666 +++
 daemons/lvmlockd/lvmlockd-internal.h               |  373 ++
 daemons/lvmlockd/lvmlockd-sanlock.c                | 1716 ++++++
 include/.symlinks.in                               |    2 +
 lib/Makefile.in                                    |    5 +
 lib/cache/lvmetad.c                                |    8 +
 lib/commands/toolcontext.h                         |   16 +-
 lib/config/config_settings.h                       |   34 +
 lib/config/defaults.h                              |    5 +
 lib/display/display.c                              |   32 +
 lib/display/display.h                              |    3 +
 lib/format_text/export.c                           |    8 +-
 lib/format_text/flags.c                            |    1 +
 lib/format_text/import_vsn1.c                      |   17 +
 lib/locking/lvmlockd.c                             | 2588 +++++++++
 lib/locking/lvmlockd.h                             |  239 +
 lib/metadata/lv.c                                  |   24 +
 lib/metadata/lv.h                                  |    3 +
 lib/metadata/lv_manip.c                            |   33 +-
 lib/metadata/metadata-exported.h                   |   23 +-
 lib/metadata/metadata.c                            |  247 +-
 lib/metadata/raid_manip.c                          |    7 +
 lib/metadata/replicator_manip.c                    |    4 +-
 lib/metadata/vg.c                                  |   35 +-
 lib/metadata/vg.h                                  |    6 +
 lib/misc/configure.h.in                            |    9 +
 lib/report/columns.h                               |    5 +-
 lib/report/properties.c                            |    6 +
 lib/report/report.c                                |   30 +
 libdaemon/client/daemon-client.c                   |   16 +-
 libdaemon/server/daemon-log.c                      |    5 +-
 liblvm/lvm_vg.c                                    |    2 +-
 man/Makefile.in                                    |    9 +-
 man/lvmlockd.8.in                                  |  755 +++
 man/lvmsystemid.7.in                               |   25 +-
 nix/default.nix                                    |    1 +
 scripts/Makefile.in                                |    6 +
 scripts/lvm2_lvmlockd_systemd_red_hat.service.in   |   16 +
 scripts/lvm2_lvmlocking_systemd_red_hat.service.in |   24 +
 spec/build.inc                                     |    2 +
 spec/packages.inc                                  |   15 +
 spec/source.inc                                    |    2 +
 test/Makefile.in                                   |   30 +
 test/lib/aux.sh                                    |   10 +
 test/lib/flavour-udev-lvmlockd-dlm.sh              |    6 +
 test/lib/flavour-udev-lvmlockd-sanlock.sh          |    6 +
 test/lib/inittest.sh                               |    7 +
 test/lib/test-corosync-conf                        |   19 +
 test/lib/test-dlm-conf                             |    4 +
 test/lib/test-sanlock-conf                         |    2 +
 test/lib/utils.sh                                  |    2 +
 test/shell/dlm-hello-world.sh                      |   27 +
 test/shell/dlm-prepare.sh                          |   90 +
 test/shell/dlm-remove.sh                           |   20 +
 test/shell/process-each-lv.sh                      |   14 +-
 test/shell/process-each-pv.sh                      |  242 +-
 test/shell/process-each-vg.sh                      |   72 +-
 test/shell/process-each-vgreduce.sh                |  327 ++
 test/shell/sanlock-hello-world.sh                  |   27 +
 test/shell/sanlock-prepare.sh                      |   86 +
 test/shell/sanlock-remove.sh                       |   28 +
 tools/args.h                                       |    5 +
 tools/commands.h                                   |   43 +-
 tools/lvchange.c                                   |   32 +
 tools/lvconvert.c                                  |  131 +-
 tools/lvcreate.c                                   |   16 +-
 tools/lvmcmdline.c                                 |   57 +-
 tools/lvrename.c                                   |    6 +-
 tools/lvresize.c                                   |    6 +-
 tools/polldaemon.c                                 |   47 +-
 tools/pvchange.c                                   |    8 +
 tools/pvcreate.c                                   |    4 +
 tools/pvmove.c                                     |   63 +-
 tools/pvremove.c                                   |    4 +
 tools/pvresize.c                                   |    8 +
 tools/pvscan.c                                     |    7 +-
 tools/reporter.c                                   |    8 +
 tools/toollib.c                                    |  327 +-
 tools/tools.h                                      |    6 +-
 tools/vgchange.c                                   |  402 ++-
 tools/vgcreate.c                                   |   47 +
 tools/vgextend.c                                   |    4 +
 tools/vgmerge.c                                    |   13 +-
 tools/vgreduce.c                                   |   12 +-
 tools/vgremove.c                                   |   19 +
 tools/vgrename.c                                   |   24 +-
 tools/vgsplit.c                                    |   17 +-
 94 files changed, 15680 insertions(+), 441 deletions(-)

diff --git a/configure b/configure
index 13e40f8..3d650a1 100755
--- a/configure
+++ b/configure
@@ -636,6 +636,7 @@ kerneldir
 interface
 CMIRRORD_PIDFILE
 CLVMD_PIDFILE
+LVMLOCKD_PIDFILE
 LVMPOLLD_PIDFILE
 LVMETAD_PIDFILE
 DMEVENTD_PIDFILE
@@ -693,6 +694,7 @@ DMEVENTD_PATH
 DMEVENTD
 DL_LIBS
 DEVMAPPER
+DEFAULT_USE_LVMLOCKD
 DEFAULT_USE_LVMPOLLD
 DEFAULT_USE_LVMETAD
 DEFAULT_USE_BLKID_WIPING
@@ -722,6 +724,7 @@ CLDWHOLEARCHIVE
 CLDNOWHOLEARCHIVE
 CLDFLAGS
 CACHE
+BUILD_LVMLOCKD
 BUILD_LVMPOLLD
 BUILD_LVMETAD
 BUILD_DMEVENTD
@@ -740,6 +743,10 @@ SYSTEMD_LIBS
 SYSTEMD_CFLAGS
 BLKID_LIBS
 BLKID_CFLAGS
+LOCKD_DLM_LIBS
+LOCKD_DLM_CFLAGS
+LOCKD_SANLOCK_LIBS
+LOCKD_SANLOCK_CFLAGS
 VALGRIND_LIBS
 VALGRIND_CFLAGS
 CUNIT_LIBS
@@ -916,6 +923,9 @@ with_lvmetad_pidfile
 enable_lvmpolld
 enable_use_lvmpolld
 with_lvmpolld_pidfile
+enable_lvmlockd
+enable_use_lvmlockd
+with_lvmlockd_pidfile
 enable_blkid_wiping
 enable_udev_systemd_background_jobs
 enable_udev_sync
@@ -994,6 +1004,10 @@ CUNIT_CFLAGS
 CUNIT_LIBS
 VALGRIND_CFLAGS
 VALGRIND_LIBS
+LOCKD_SANLOCK_CFLAGS
+LOCKD_SANLOCK_LIBS
+LOCKD_DLM_CFLAGS
+LOCKD_DLM_LIBS
 BLKID_CFLAGS
 BLKID_LIBS
 SYSTEMD_CFLAGS
@@ -1632,6 +1646,8 @@ Optional Features:
   --disable-use-lvmetad   disable usage of LVM Metadata Daemon
   --enable-lvmpolld       enable the LVM Polling Daemon
   --disable-use-lvmpolld  disable usage of LVM Poll Daemon
+  --enable-lvmlockd       enable the LVM lock daemon
+  --disable-use-lvmlockd  disable usage of LVM lock daemon
   --disable-blkid_wiping  disable libblkid detection of signatures when wiping
                           and use native code instead
   --disable-udev-systemd-background-jobs
@@ -1725,6 +1741,8 @@ Optional Packages:
                           lvmetad pidfile [PID_DIR/lvmetad.pid]
   --with-lvmpolld-pidfile=PATH
                           lvmpolld pidfile [PID_DIR/lvmpolld.pid]
+  --with-lvmlockd-pidfile=PATH
+                          lvmlockd pidfile [PID_DIR/lvmlockd.pid]
   --with-localedir=DIR    locale-dependent data [DATAROOTDIR/locale]
   --with-confdir=DIR      configuration files in DIR [/etc]
   --with-staticdir=DIR    static binaries in DIR [EPREFIX/sbin]
@@ -1809,6 +1827,14 @@ Some influential environment variables:
               C compiler flags for VALGRIND, overriding pkg-config
   VALGRIND_LIBS
               linker flags for VALGRIND, overriding pkg-config
+  LOCKD_SANLOCK_CFLAGS
+              C compiler flags for LOCKD_SANLOCK, overriding pkg-config
+  LOCKD_SANLOCK_LIBS
+              linker flags for LOCKD_SANLOCK, overriding pkg-config
+  LOCKD_DLM_CFLAGS
+              C compiler flags for LOCKD_DLM, overriding pkg-config
+  LOCKD_DLM_LIBS
+              linker flags for LOCKD_DLM, overriding pkg-config
   BLKID_CFLAGS
               C compiler flags for BLKID, overriding pkg-config
   BLKID_LIBS  linker flags for BLKID, overriding pkg-config
@@ -3042,6 +3068,7 @@ case "$host_os" in
 		DEVMAPPER=yes
 		LVMETAD=no
 		LVMPOLLD=no
+		LVMLOCKD=no
 		ODIRECT=yes
 		DM_IOCTLS=yes
 		SELINUX=yes
@@ -10966,6 +10993,207 @@ _ACEOF
 
 
 ################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build lvmlockd" >&5
+$as_echo_n "checking whether to build lvmlockd... " >&6; }
+# Check whether --enable-lvmlockd was given.
+if test "${enable_lvmlockd+set}" = set; then :
+  enableval=$enable_lvmlockd; LVMLOCKD=$enableval
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $LVMLOCKD" >&5
+$as_echo "$LVMLOCKD" >&6; }
+
+BUILD_LVMLOCKD=$LVMLOCKD
+
+if test "$BUILD_LVMLOCKD" = yes; then
+	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking defaults for use_lvmlockd" >&5
+$as_echo_n "checking defaults for use_lvmlockd... " >&6; }
+	# Check whether --enable-use_lvmlockd was given.
+if test "${enable_use_lvmlockd+set}" = set; then :
+  enableval=$enable_use_lvmlockd; case ${enableval} in
+		       yes) DEFAULT_USE_LVMLOCKD=1 ;;
+		       *) DEFAULT_USE_LVMLOCKD=0 ;;
+		       esac
+else
+  DEFAULT_USE_LVMLOCKD=1
+fi
+
+	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $DEFAULT_USE_LVMLOCKD" >&5
+$as_echo "$DEFAULT_USE_LVMLOCKD" >&6; }
+
+$as_echo "#define LVMLOCKD_SUPPORT 1" >>confdefs.h
+
+
+
+# Check whether --with-lvmlockd-pidfile was given.
+if test "${with_lvmlockd_pidfile+set}" = set; then :
+  withval=$with_lvmlockd_pidfile; LVMLOCKD_PIDFILE=$withval
+else
+  LVMLOCKD_PIDFILE="$DEFAULT_PID_DIR/lvmlockd.pid"
+fi
+
+
+cat >>confdefs.h <<_ACEOF
+#define LVMLOCKD_PIDFILE "$LVMLOCKD_PIDFILE"
+_ACEOF
+
+else
+	DEFAULT_USE_LVMLOCKD=0
+fi
+
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_USE_LVMLOCKD $DEFAULT_USE_LVMLOCKD
+_ACEOF
+
+
+################################################################################
+if test "$BUILD_LVMLOCKD" = yes; then
+
+pkg_failed=no
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for LOCKD_SANLOCK" >&5
+$as_echo_n "checking for LOCKD_SANLOCK... " >&6; }
+
+if test -n "$LOCKD_SANLOCK_CFLAGS"; then
+    pkg_cv_LOCKD_SANLOCK_CFLAGS="$LOCKD_SANLOCK_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libsanlock_client\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "libsanlock_client") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_LOCKD_SANLOCK_CFLAGS=`$PKG_CONFIG --cflags "libsanlock_client" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$LOCKD_SANLOCK_LIBS"; then
+    pkg_cv_LOCKD_SANLOCK_LIBS="$LOCKD_SANLOCK_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libsanlock_client\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "libsanlock_client") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_LOCKD_SANLOCK_LIBS=`$PKG_CONFIG --libs "libsanlock_client" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+
+
+
+if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+
+if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
+        _pkg_short_errors_supported=yes
+else
+        _pkg_short_errors_supported=no
+fi
+        if test $_pkg_short_errors_supported = yes; then
+	        LOCKD_SANLOCK_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libsanlock_client" 2>&1`
+        else
+	        LOCKD_SANLOCK_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libsanlock_client" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$LOCKD_SANLOCK_PKG_ERRORS" >&5
+
+	$bailout
+elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+	$bailout
+else
+	LOCKD_SANLOCK_CFLAGS=$pkg_cv_LOCKD_SANLOCK_CFLAGS
+	LOCKD_SANLOCK_LIBS=$pkg_cv_LOCKD_SANLOCK_LIBS
+        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+	HAVE_LOCKD_SANLOCK=yes
+fi
+
+pkg_failed=no
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for LOCKD_DLM" >&5
+$as_echo_n "checking for LOCKD_DLM... " >&6; }
+
+if test -n "$LOCKD_DLM_CFLAGS"; then
+    pkg_cv_LOCKD_DLM_CFLAGS="$LOCKD_DLM_CFLAGS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libdlm\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "libdlm") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_LOCKD_DLM_CFLAGS=`$PKG_CONFIG --cflags "libdlm" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+if test -n "$LOCKD_DLM_LIBS"; then
+    pkg_cv_LOCKD_DLM_LIBS="$LOCKD_DLM_LIBS"
+ elif test -n "$PKG_CONFIG"; then
+    if test -n "$PKG_CONFIG" && \
+    { { $as_echo "$as_me:${as_lineno-$LINENO}: \$PKG_CONFIG --exists --print-errors \"libdlm\""; } >&5
+  ($PKG_CONFIG --exists --print-errors "libdlm") 2>&5
+  ac_status=$?
+  $as_echo "$as_me:${as_lineno-$LINENO}: \$? = $ac_status" >&5
+  test $ac_status = 0; }; then
+  pkg_cv_LOCKD_DLM_LIBS=`$PKG_CONFIG --libs "libdlm" 2>/dev/null`
+		      test "x$?" != "x0" && pkg_failed=yes
+else
+  pkg_failed=yes
+fi
+ else
+    pkg_failed=untried
+fi
+
+
+
+if test $pkg_failed = yes; then
+   	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+
+if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
+        _pkg_short_errors_supported=yes
+else
+        _pkg_short_errors_supported=no
+fi
+        if test $_pkg_short_errors_supported = yes; then
+	        LOCKD_DLM_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "libdlm" 2>&1`
+        else
+	        LOCKD_DLM_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "libdlm" 2>&1`
+        fi
+	# Put the nasty error message in config.log where it belongs
+	echo "$LOCKD_DLM_PKG_ERRORS" >&5
+
+	$bailout
+elif test $pkg_failed = untried; then
+     	{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
+$as_echo "no" >&6; }
+	$bailout
+else
+	LOCKD_DLM_CFLAGS=$pkg_cv_LOCKD_DLM_CFLAGS
+	LOCKD_DLM_LIBS=$pkg_cv_LOCKD_DLM_LIBS
+        { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
+$as_echo "yes" >&6; }
+	HAVE_LOCKD_DLM=yes
+fi
+fi
+
+################################################################################
+
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable libblkid detection of signatures when wiping" >&5
 $as_echo_n "checking whether to enable libblkid detection of signatures when wiping... " >&6; }
 # Check whether --enable-blkid_wiping was given.
@@ -13286,8 +13514,11 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
+
+
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile daemons/lvmpolld/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile 
 liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/
 Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdev
 mapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan
 _systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -13997,6 +14228,7 @@ do
     "daemons/dmeventd/plugins/thin/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/thin/Makefile" ;;
     "daemons/lvmetad/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmetad/Makefile" ;;
     "daemons/lvmpolld/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmpolld/Makefile" ;;
+    "daemons/lvmlockd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmlockd/Makefile" ;;
     "conf/Makefile") CONFIG_FILES="$CONFIG_FILES conf/Makefile" ;;
     "conf/example.conf") CONFIG_FILES="$CONFIG_FILES conf/example.conf" ;;
     "conf/lvmlocal.conf") CONFIG_FILES="$CONFIG_FILES conf/lvmlocal.conf" ;;
@@ -14043,6 +14275,8 @@ do
     "scripts/lvm2_lvmpolld_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmpolld_init_red_hat" ;;
     "scripts/lvm2_lvmpolld_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmpolld_systemd_red_hat.service" ;;
     "scripts/lvm2_lvmpolld_systemd_red_hat.socket") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmpolld_systemd_red_hat.socket" ;;
+    "scripts/lvm2_lvmlockd_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmlockd_systemd_red_hat.service" ;;
+    "scripts/lvm2_lvmlocking_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmlocking_systemd_red_hat.service" ;;
     "scripts/lvm2_monitoring_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_monitoring_init_red_hat" ;;
     "scripts/lvm2_monitoring_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_monitoring_systemd_red_hat.service" ;;
     "scripts/lvm2_pvscan_systemd_red_hat at .service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_pvscan_systemd_red_hat@.service" ;;
@@ -14668,3 +14902,13 @@ if test "$ODIRECT" != yes; then :
   { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&5
 $as_echo "$as_me: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&2;}
 fi
+
+if test "$BUILD_LVMLOCKD" == yes && test "$BUILD_LVMPOLLD" == no; then :
+  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: lvmlockd requires lvmpolld" >&5
+$as_echo "$as_me: WARNING: lvmlockd requires lvmpolld" >&2;}
+fi
+
+if test "$BUILD_LVMLOCKD" == yes && test "$BUILD_LVMETAD" == no; then :
+  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: lvmlockd requires lvmetad" >&5
+$as_echo "$as_me: WARNING: lvmlockd requires lvmetad" >&2;}
+fi
diff --git a/configure.in b/configure.in
index 0c310ca..21ce581 100644
--- a/configure.in
+++ b/configure.in
@@ -39,6 +39,7 @@ case "$host_os" in
 		DEVMAPPER=yes
 		LVMETAD=no
 		LVMPOLLD=no
+		LVMLOCKD=no
 		ODIRECT=yes
 		DM_IOCTLS=yes
 		SELINUX=yes
@@ -1138,6 +1139,50 @@ AC_DEFINE_UNQUOTED(DEFAULT_USE_LVMPOLLD, [$DEFAULT_USE_LVMPOLLD],
 		   [Use lvmpolld by default.])
 
 ################################################################################
+dnl -- Build lvmlockd
+AC_MSG_CHECKING(whether to build lvmlockd)
+AC_ARG_ENABLE(lvmlockd,
+	      AC_HELP_STRING([--enable-lvmlockd],
+			     [enable the LVM lock daemon]),
+	      LVMLOCKD=$enableval)
+AC_MSG_RESULT($LVMLOCKD)
+
+BUILD_LVMLOCKD=$LVMLOCKD
+
+if test "$BUILD_LVMLOCKD" = yes; then
+	AC_MSG_CHECKING([defaults for use_lvmlockd])
+	AC_ARG_ENABLE(use_lvmlockd,
+		      AC_HELP_STRING([--disable-use-lvmlockd],
+				     [disable usage of LVM lock daemon]),
+		      [case ${enableval} in
+		       yes) DEFAULT_USE_LVMLOCKD=1 ;;
+		       *) DEFAULT_USE_LVMLOCKD=0 ;;
+		       esac], DEFAULT_USE_LVMLOCKD=1)
+	AC_MSG_RESULT($DEFAULT_USE_LVMLOCKD)
+	AC_DEFINE([LVMLOCKD_SUPPORT], 1, [Define to 1 to include code that uses lvmlockd.])
+
+	AC_ARG_WITH(lvmlockd-pidfile,
+		    AC_HELP_STRING([--with-lvmlockd-pidfile=PATH],
+				   [lvmlockd pidfile [PID_DIR/lvmlockd.pid]]),
+		    LVMLOCKD_PIDFILE=$withval,
+		    LVMLOCKD_PIDFILE="$DEFAULT_PID_DIR/lvmlockd.pid")
+	AC_DEFINE_UNQUOTED(LVMLOCKD_PIDFILE, ["$LVMLOCKD_PIDFILE"],
+			   [Path to lvmlockd pidfile.])
+else
+	DEFAULT_USE_LVMLOCKD=0
+fi
+AC_DEFINE_UNQUOTED(DEFAULT_USE_LVMLOCKD, [$DEFAULT_USE_LVMLOCKD],
+		   [Use lvmlockd by default.])
+
+################################################################################
+dnl -- Look for sanlock and dlm libraries
+if test "$BUILD_LVMLOCKD" = yes; then
+	PKG_CHECK_MODULES(LOCKD_SANLOCK, libsanlock_client, [HAVE_LOCKD_SANLOCK=yes], $bailout)
+	PKG_CHECK_MODULES(LOCKD_DLM, libdlm, [HAVE_LOCKD_DLM=yes], $bailout)
+fi
+
+################################################################################
+
 dnl -- Enable blkid wiping functionality
 AC_MSG_CHECKING(whether to enable libblkid detection of signatures when wiping)
 AC_ARG_ENABLE(blkid_wiping,
@@ -1758,6 +1803,7 @@ AC_SUBST(BUILD_CMIRRORD)
 AC_SUBST(BUILD_DMEVENTD)
 AC_SUBST(BUILD_LVMETAD)
 AC_SUBST(BUILD_LVMPOLLD)
+AC_SUBST(BUILD_LVMLOCKD)
 AC_SUBST(CACHE)
 AC_SUBST(CFLAGS)
 AC_SUBST(CFLOW_CMD)
@@ -1798,6 +1844,7 @@ AC_SUBST(DEFAULT_SYS_DIR)
 AC_SUBST(DEFAULT_USE_BLKID_WIPING)
 AC_SUBST(DEFAULT_USE_LVMETAD)
 AC_SUBST(DEFAULT_USE_LVMPOLLD)
+AC_SUBST(DEFAULT_USE_LVMLOCKD)
 AC_SUBST(DEVMAPPER)
 AC_SUBST(DLM_CFLAGS)
 AC_SUBST(DLM_LIBS)
@@ -1875,6 +1922,7 @@ AC_SUBST(WRITE_INSTALL)
 AC_SUBST(DMEVENTD_PIDFILE)
 AC_SUBST(LVMETAD_PIDFILE)
 AC_SUBST(LVMPOLLD_PIDFILE)
+AC_SUBST(LVMLOCKD_PIDFILE)
 AC_SUBST(CLVMD_PIDFILE)
 AC_SUBST(CMIRRORD_PIDFILE)
 AC_SUBST(interface)
@@ -1909,6 +1957,7 @@ daemons/dmeventd/plugins/snapshot/Makefile
 daemons/dmeventd/plugins/thin/Makefile
 daemons/lvmetad/Makefile
 daemons/lvmpolld/Makefile
+daemons/lvmlockd/Makefile
 conf/Makefile
 conf/example.conf
 conf/lvmlocal.conf
@@ -1955,6 +2004,8 @@ scripts/lvm2_lvmetad_systemd_red_hat.socket
 scripts/lvm2_lvmpolld_init_red_hat
 scripts/lvm2_lvmpolld_systemd_red_hat.service
 scripts/lvm2_lvmpolld_systemd_red_hat.socket
+scripts/lvm2_lvmlockd_systemd_red_hat.service
+scripts/lvm2_lvmlocking_systemd_red_hat.service
 scripts/lvm2_monitoring_init_red_hat
 scripts/lvm2_monitoring_systemd_red_hat.service
 scripts/lvm2_pvscan_systemd_red_hat at .service
@@ -1982,3 +2033,9 @@ AS_IF([test -n "$CACHE_CONFIGURE_WARN"],
 
 AS_IF([test "$ODIRECT" != yes],
       [AC_MSG_WARN([O_DIRECT disabled: low-memory pvmove may lock up])])
+
+AS_IF([test "$BUILD_LVMLOCKD" == yes && test "$BUILD_LVMPOLLD" == no],
+      [AC_MSG_WARN([lvmlockd requires lvmpolld])])
+
+AS_IF([test "$BUILD_LVMLOCKD" == yes && test "$BUILD_LVMETAD" == no],
+      [AC_MSG_WARN([lvmlockd requires lvmetad])])
diff --git a/daemons/Makefile.in b/daemons/Makefile.in
index 8a466b3..a2e7094 100644
--- a/daemons/Makefile.in
+++ b/daemons/Makefile.in
@@ -15,7 +15,7 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-.PHONY: dmeventd clvmd cmirrord lvmetad lvmpolld
+.PHONY: dmeventd clvmd cmirrord lvmetad lvmpolld lvmlockd
 
 ifneq ("@CLVMD@", "none")
   SUBDIRS += clvmd
@@ -40,8 +40,12 @@ ifeq ("@BUILD_LVMPOLLD@", "yes")
   SUBDIRS += lvmpolld
 endif
 
+ifeq ("@BUILD_LVMLOCKD@", "yes")
+  SUBDIRS += lvmlockd 
+endif
+
 ifeq ($(MAKECMDGOALS),distclean)
-  SUBDIRS = clvmd cmirrord dmeventd lvmetad lvmpolld
+  SUBDIRS = clvmd cmirrord dmeventd lvmetad lvmpolld lvmlockd
 endif
 
 include $(top_builddir)/make.tmpl
diff --git a/daemons/lvmlockd/Makefile.in b/daemons/lvmlockd/Makefile.in
new file mode 100644
index 0000000..fcdce5c
--- /dev/null
+++ b/daemons/lvmlockd/Makefile.in
@@ -0,0 +1,53 @@
+#
+# Copyright (C) 2014-2015 Red Hat, Inc.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU Lesser General Public License v.2.1.
+#
+# You should have received a copy of the GNU Lesser General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+srcdir = @srcdir@
+top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
+
+SOURCES = \
+	lvmlockd-core.c \
+	lvmlockd-sanlock.c \
+	lvmlockd-dlm.c
+
+TARGETS = lvmlockd lvmlockctl
+
+.PHONY: install_lvmlockd
+
+include $(top_builddir)/make.tmpl
+
+INCLUDES += -I$(top_srcdir)/libdaemon/server
+LVMLIBS = -ldaemonserver $(LVMINTERNAL_LIBS) -ldevmapper
+
+LIBS += $(PTHREAD_LIBS) -ldlm_lt -lsanlock_client -lrt
+
+LDFLAGS += -L$(top_builddir)/libdaemon/server
+CLDFLAGS += -L$(top_builddir)/libdaemon/server
+
+lvmlockd: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
+		    $(top_builddir)/libdaemon/server/libdaemonserver.a
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(LVMLIBS) $(LIBS)
+
+lvmlockctl: lvmlockctl.o $(top_builddir)/libdaemon/client/libdaemonclient.a \
+		    $(top_builddir)/libdaemon/server/libdaemonserver.a
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ lvmlockctl.o $(LVMLIBS)
+
+install_lvmlockd: lvmlockd
+	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
+
+install_lvmlockctl: lvmlockctl
+	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
+
+install_lvm2: install_lvmlockd install_lvmlockctl
+
+install: install_lvm2
diff --git a/daemons/lvmlockd/lvmlockctl.c b/daemons/lvmlockd/lvmlockctl.c
new file mode 100644
index 0000000..b8ab9ed
--- /dev/null
+++ b/daemons/lvmlockd/lvmlockctl.c
@@ -0,0 +1,635 @@
+#define _GNU_SOURCE
+#include "configure.h"
+#include "lvmlockd-client.h"
+
+#include <stdio.h>
+#include <stdint.h>
+#include <stddef.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <getopt.h>
+#include <string.h>
+#include <signal.h>
+#include <errno.h>
+#include <fcntl.h>
+#include <sys/types.h>
+#include <sys/wait.h>
+#include <sys/socket.h>
+#include <sys/un.h>
+
+static int quit;
+static int info;
+static int dump;
+static int wait_opt;
+static int force_opt;
+static int gl_enable;
+static int gl_disable;
+static int stop_lockspaces;
+static char *able_vg_name;
+
+#define DUMP_SOCKET_NAME "lvmlockd-dump.sock"
+#define DUMP_BUF_SIZE (1024 * 1024)
+static char dump_buf[DUMP_BUF_SIZE];
+static int dump_len;
+static struct sockaddr_un dump_addr;
+static socklen_t dump_addrlen;
+
+daemon_handle _lvmlockd;
+
+#define log_debug(fmt, args...) \
+do { \
+	printf(fmt "\n", ##args); \
+} while (0)
+
+#define log_error(fmt, args...) \
+do { \
+	printf(fmt "\n", ##args); \
+} while (0)
+
+#define MAX_LINE 512
+
+/* copied from lvmlockd-internal.h */
+#define MAX_NAME 64
+#define MAX_ARGS 64
+
+/*
+ * lvmlockd dumps the client info before the lockspaces,
+ * so we can look up client info when printing lockspace info.
+ */
+
+#define MAX_CLIENTS 100
+
+struct client_info {
+	uint32_t client_id;
+	int pid;
+	char name[MAX_NAME+1];
+};
+
+static struct client_info clients[MAX_CLIENTS];
+static int num_clients;
+
+static void save_client_info(char *line)
+{
+	uint32_t pid = 0;
+	int fd = 0;
+	int pi = 0;
+	uint32_t client_id = 0;
+	char name[MAX_NAME+1] = { 0 };
+
+	sscanf(line, "info=client pid=%u fd=%d pi=%d id=%u name=%s",
+	       &pid, &fd, &pi, &client_id, name);
+
+	clients[num_clients].client_id = client_id;
+	clients[num_clients].pid = pid;
+	strcpy(clients[num_clients].name, name);
+	num_clients++;
+}
+
+static void find_client_info(uint32_t client_id, uint32_t *pid, char *cl_name)
+{
+	int i;
+
+	for (i = 0; i < num_clients; i++) {
+		if (clients[i].client_id == client_id) {
+			*pid = clients[i].pid;
+			strcpy(cl_name, clients[i].name);
+			return;
+		}
+	}
+}
+
+static void format_info_ls(char *line)
+{
+	char ls_name[MAX_NAME+1] = { 0 };
+	char vg_name[MAX_NAME+1] = { 0 };
+	char vg_uuid[MAX_NAME+1] = { 0 };
+	char vg_sysid[MAX_NAME+1] = { 0 };
+	char lock_args[MAX_ARGS+1] = { 0 };
+	char lock_type[MAX_NAME+1] = { 0 };
+
+	sscanf(line, "info=ls ls_name=%s vg_name=%s vg_uuid=%s vg_sysid=%s vg_args=%s lm_type=%s",
+	       ls_name, vg_name, vg_uuid, vg_sysid, lock_args, lock_type);
+
+	printf("\n");
+
+	printf("VG %s lock_type=%s %s\n", vg_name, lock_type, vg_uuid);
+
+	printf("LS %s %s\n", lock_type, ls_name);
+}
+
+static void format_info_ls_action(char *line)
+{
+	uint32_t client_id = 0;
+	char flags[MAX_NAME+1] = { 0 };
+	char version[MAX_NAME+1] = { 0 };
+	char op[MAX_NAME+1] = { 0 };
+	uint32_t pid = 0;
+	char cl_name[MAX_NAME+1] = { 0 };
+
+	sscanf(line, "info=ls_action client_id=%u %s %s op=%s",
+	       &client_id, flags, version, op);
+
+	find_client_info(client_id, &pid, cl_name);
+
+	printf("OP %s pid %u (%s)", op, pid, cl_name);
+}
+
+static void format_info_r(char *line, char *r_name_out, char *r_type_out)
+{
+	char r_name[MAX_NAME+1] = { 0 };
+	char r_type[4] = { 0 };
+	char mode[4] = { 0 };
+	char sh_count[MAX_NAME+1] = { 0 };
+	uint32_t ver = 0;
+
+	sscanf(line, "info=r name=%s type=%s mode=%s %s version=%u",
+	       r_name, r_type, mode, sh_count, &ver);
+
+	/* when mode is not un, wait and print each lk line */
+
+	if (strcmp(mode, "un")) {
+		strcpy(r_name_out, r_name);
+		strcpy(r_type_out, r_type);
+		return;
+	}
+
+	/* when mode is un, there will be no lk lines, so print now */
+
+	if (!strcmp(r_type, "gl")) {
+		printf("LK GL un ver %4u\n", ver);
+
+	} else if (!strcmp(r_type, "vg")) {
+		printf("LK VG un ver %4u\n", ver);
+
+	} else if (!strcmp(r_type, "lv")) {
+		printf("LK LV un %s\n", r_name);
+	}
+}
+
+static void format_info_lk(char *line, char *r_name, char *r_type)
+{
+	char mode[4] = { 0 };
+	uint32_t ver = 0;
+	char flags[MAX_NAME+1] = { 0 };
+	uint32_t client_id = 0;
+	uint32_t pid = 0;
+	char cl_name[MAX_NAME+1] = { 0 };
+
+	if (!r_name[0] || !r_type[0]) {
+		printf("format_info_lk error r_name %s r_type %s\n", r_name, r_type);
+		printf("%s\n", line);
+		return;
+	}
+
+	sscanf(line, "info=lk mode=%s version=%u %s client_id=%u",
+	       mode, &ver, flags, &client_id);
+
+	find_client_info(client_id, &pid, cl_name);
+
+	if (!strcmp(r_type, "gl")) {
+		printf("LK GL %s ver %4u pid %u (%s)\n", mode, ver, pid, cl_name);
+
+	} else if (!strcmp(r_type, "vg")) {
+		printf("LK VG %s ver %4u pid %u (%s)\n", mode, ver, pid, cl_name);
+
+	} else if (!strcmp(r_type, "lv")) {
+		printf("LK LV %s %s\n", mode, r_name);
+	}
+}
+
+static void format_info_r_action(char *line, char *r_name, char *r_type)
+{
+	uint32_t client_id = 0;
+	char flags[MAX_NAME+1] = { 0 };
+	char version[MAX_NAME+1] = { 0 };
+	char op[MAX_NAME+1] = { 0 };
+	char rt[4] = { 0 };
+	char mode[4] = { 0 };
+	char lm[MAX_NAME+1] = { 0 };
+	char result[MAX_NAME+1] = { 0 };
+	char lm_rv[MAX_NAME+1] = { 0 };
+	uint32_t pid = 0;
+	char cl_name[MAX_NAME+1] = { 0 };
+
+	if (!r_name[0] || !r_type[0]) {
+		printf("format_info_r_action error r_name %s r_type %s\n", r_name, r_type);
+		printf("%s\n", line);
+		return;
+	}
+
+	sscanf(line, "info=r_action client_id=%u %s %s op=%s rt=%s mode=%s %s %s %s",
+	       &client_id, flags, version, op, rt, mode, lm, result, lm_rv);
+
+	find_client_info(client_id, &pid, cl_name);
+
+	if (strcmp(op, "lock")) {
+		printf("OP %s pid %u (%s)", op, pid, cl_name);
+		return;
+	}
+
+	if (!strcmp(r_type, "gl")) {
+		printf("LW GL %s ver %4u pid %u (%s)\n", mode, 0, pid, cl_name);
+
+	} else if (!strcmp(r_type, "vg")) {
+		printf("LW VG %s ver %4u pid %u (%s)\n", mode, 0, pid, cl_name);
+
+	} else if (!strcmp(r_type, "lv")) {
+		printf("LW LV %s %s\n", mode, r_name);
+	}
+}
+
+static void format_info_line(char *line)
+{
+	char r_name[MAX_NAME+1];
+	char r_type[MAX_NAME+1];
+
+	if (!strncmp(line, "info=structs ", strlen("info=structs "))) {
+		printf("%s\n", line);
+
+	} else if (!strncmp(line, "info=client ", strlen("info=client "))) {
+		save_client_info(line);
+
+	} else if (!strncmp(line, "info=ls ", strlen("info=ls "))) {
+		format_info_ls(line);
+
+	} else if (!strncmp(line, "info=ls_action ", strlen("info=ls_action "))) {
+		format_info_ls_action(line);
+
+	} else if (!strncmp(line, "info=r ", strlen("info=r "))) {
+		memset(r_name, 0, sizeof(r_name));
+		memset(r_type, 0, sizeof(r_type));
+		format_info_r(line, r_name, r_type);
+
+	} else if (!strncmp(line, "info=lk ", strlen("info=lk "))) {
+		/* will use info from previous r */
+		format_info_lk(line, r_name, r_type);
+
+	} else if (!strncmp(line, "info=r_action ", strlen("info=r_action "))) {
+		/* will use info from previous r */
+		format_info_r_action(line, r_name, r_type);
+	} else {
+		printf("UN %s\n", line);
+	}
+}
+
+static void format_info(void)
+{
+	char line[MAX_LINE];
+	int i, j;
+
+	j = 0;
+	memset(line, 0, sizeof(line));
+
+	for (i = 0; i < dump_len; i++) {
+		line[j++] = dump_buf[i];
+
+		if ((line[j-1] == '\n') || (line[j-1] == '\0')) {
+			format_info_line(line);
+			j = 0;
+			memset(line, 0, sizeof(line));
+		}
+	}
+}
+
+
+static daemon_reply _lvmlockd_send(const char *req_name, ...)
+{
+	va_list ap;
+	daemon_reply repl;
+	daemon_request req;
+
+	req = daemon_request_make(req_name);
+
+	va_start(ap, req_name);
+	daemon_request_extend_v(req, ap);
+	va_end(ap);
+
+	repl = daemon_send(_lvmlockd, req);
+
+	daemon_request_destroy(req);
+
+	return repl;
+}
+
+/* See the same in lib/locking/lvmlockd.c */
+#define NO_LOCKD_RESULT -1000
+
+static int _lvmlockd_result(daemon_reply reply, int *result)
+{
+	int reply_result;
+	const char *reply_flags;
+	const char *lock_type;
+
+	if (reply.error) {
+		log_error("lvmlockd_result reply error %d", reply.error);
+		return 0;
+	}
+
+	if (strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
+		log_error("lvmlockd_result bad response");
+		return 0;
+	}
+
+	reply_result = daemon_reply_int(reply, "op_result", NO_LOCKD_RESULT);
+	if (reply_result == -1000) {
+		log_error("lvmlockd_result no op_result");
+		return 0;
+	}
+
+	/* The lock_type that lvmlockd used for locking. */
+	lock_type = daemon_reply_str(reply, "lock_type", "none");
+
+	*result = reply_result;
+
+	reply_flags = daemon_reply_str(reply, "result_flags", NULL);
+
+	log_debug("lvmlockd_result %d %s lm %s", reply_result, reply_flags, lock_type);
+	return 1;
+}
+
+static int do_quit(void)
+{
+	daemon_reply reply;
+	int rv = 0;
+
+	reply = daemon_send_simple(_lvmlockd, "quit", NULL);
+
+	if (reply.error) {
+		log_error("reply error %d", reply.error);
+		rv = reply.error;
+	}
+
+	daemon_reply_destroy(reply);
+	return rv;
+}
+
+static int setup_dump_socket(void)
+{
+	int s, rv;
+
+	s = socket(AF_LOCAL, SOCK_DGRAM, 0);
+	if (s < 0)
+		return s;
+
+	memset(&dump_addr, 0, sizeof(dump_addr));
+	dump_addr.sun_family = AF_LOCAL;
+	strcpy(&dump_addr.sun_path[1], DUMP_SOCKET_NAME);
+	dump_addrlen = sizeof(sa_family_t) + strlen(dump_addr.sun_path+1) + 1;
+
+	rv = bind(s, (struct sockaddr *) &dump_addr, dump_addrlen);
+	if (rv < 0)
+		return rv;
+
+	return s;
+}
+
+static int do_dump(const char *req_name)
+{
+	daemon_reply reply;
+	int result;
+	int fd, rv = 0;
+
+	fd = setup_dump_socket();
+	if (fd < 0) {
+		log_error("socket error %d", fd);
+		return fd;
+	}
+
+	reply = daemon_send_simple(_lvmlockd, req_name, NULL);
+
+	if (reply.error) {
+		log_error("reply error %d", reply.error);
+		rv = reply.error;
+		goto out;
+	}
+
+	result = daemon_reply_int(reply, "result", 0);
+	dump_len = daemon_reply_int(reply, "dump_len", 0);
+
+	daemon_reply_destroy(reply);
+
+	if (result < 0) {
+		rv = result;
+		log_error("result %d", result);
+	}
+
+	if (!dump_len)
+		goto out;
+
+	memset(dump_buf, 0, sizeof(dump_buf));
+
+	rv = recvfrom(fd, dump_buf, dump_len, MSG_WAITALL,
+		      (struct sockaddr *)&dump_addr, &dump_addrlen);
+	if (rv < 0) {
+		log_error("recvfrom error %d %d", rv, errno);
+		rv = -errno;
+		goto out;
+	}
+
+	rv = 0;
+	if ((info && dump) || !strcmp(req_name, "dump"))
+		printf("%s\n", dump_buf);
+	else
+		format_info();
+out:
+	close(fd);
+	return rv;
+}
+
+static int do_able(const char *req_name)
+{
+	daemon_reply reply;
+	int result;
+	int rv;
+
+	reply = _lvmlockd_send(req_name,
+				"cmd = %s", "lvmlock",
+				"pid = %d", getpid(),
+				"vg_name = %s", able_vg_name,
+				NULL);
+
+	if (!_lvmlockd_result(reply, &result)) {
+		log_error("lvmlockd result %d", result);
+		rv = result;
+	} else {
+		rv = 0;
+	}
+
+	daemon_reply_destroy(reply);
+	return rv;
+}
+
+static int do_stop_lockspaces(void)
+{
+	daemon_reply reply;
+	char opts[32];
+	int result;
+	int rv;
+
+	memset(opts, 0, sizeof(opts));
+
+	if (wait_opt)
+		strcat(opts, "wait ");
+	if (force_opt)
+		strcat(opts, "force ");
+
+	reply = _lvmlockd_send("stop_all",
+				"cmd = %s", "lvmlock",
+				"pid = %d", getpid(),
+				"opts = %s", opts[0] ? opts : "none",
+				NULL);
+
+	if (!_lvmlockd_result(reply, &result)) {
+		log_error("lvmlockd result %d", result);
+		rv = result;
+	} else {
+		rv = 0;
+	}
+
+	daemon_reply_destroy(reply);
+	return rv;
+}
+
+static void print_usage(void)
+{
+	printf("lvmlockctl options\n");
+	printf("Options:\n");
+	printf("--help | -h\n");
+	printf("      Show this help information.\n");
+	printf("--quit | -q\n");
+	printf("      Tell lvmlockd to quit.\n");
+	printf("--info | -i\n");
+	printf("      Print lock state information from lvmlockd.\n");
+	printf("--dump | -d\n");
+	printf("      Print log buffer from lvmlockd.\n");
+	printf("--wait | -w 0|1\n");
+	printf("      Wait option for other commands.\n");
+	printf("--force | -f 0|1>\n");
+	printf("      Force option for other commands.\n");
+	printf("--stop-lockspaces | -S\n");
+	printf("      Stop all lockspaces.\n");
+	printf("--gl-enable <vg_name>\n");
+	printf("      Tell lvmlockd to enable the global lock in a sanlock vg.\n");
+	printf("--gl-disable <vg_name>\n");
+	printf("      Tell lvmlockd to disable the global lock in a sanlock vg.\n");
+}
+
+static int read_options(int argc, char *argv[])
+{
+	int option_index = 0;
+	int c;
+
+	static struct option long_options[] = {
+		{"help",            no_argument,       0,  'h' },
+		{"quit",            no_argument,       0,  'q' },
+		{"info",            no_argument,       0,  'i' },
+		{"dump",            no_argument,       0,  'd' },
+		{"wait",            required_argument, 0,  'w' },
+		{"force",           required_argument, 0,  'f' },
+		{"gl-enable",       required_argument, 0,  'E' },
+		{"gl-disable",      required_argument, 0,  'D' },
+		{"stop-lockspaces", no_argument,       0,  'S' },
+		{0, 0, 0, 0 }
+	};
+
+	if (argc == 1) {
+		print_usage();
+		exit(0);
+	}
+
+	while (1) {
+		c = getopt_long(argc, argv, "hqidE:D:w:S", long_options, &option_index);
+		if (c == -1)
+			break;
+
+		switch (c) {
+		case 'h':
+			/* --help */
+			print_usage();
+			exit(0);
+		case 'q':
+			/* --quit */
+			quit = 1;
+			break;
+		case 'i':
+			/* --info */
+			info = 1;
+			break;
+		case 'd':
+			/* --dump */
+			dump = 1;
+			break;
+		case 'w':
+			wait_opt = atoi(optarg);
+			break;
+		case 'E':
+			gl_enable = 1;
+			able_vg_name = strdup(optarg);
+			break;
+		case 'D':
+			gl_disable = 1;
+			able_vg_name = strdup(optarg);
+			break;
+		case 'S':
+			stop_lockspaces = 1;
+			break;
+		default:
+			print_usage();
+			exit(1);
+		}
+	}
+
+
+	return 0;
+}
+
+int main(int argc, char **argv)
+{
+	int rv = 0;
+
+	rv = read_options(argc, argv);
+	if (rv < 0)
+		return rv;
+
+	_lvmlockd = lvmlockd_open(NULL);
+
+	if (_lvmlockd.socket_fd < 0 || _lvmlockd.error) {
+		log_error("lvmlockd open error %d", _lvmlockd.error);
+		return -1;
+	}
+
+	if (quit) {
+		rv = do_quit();
+		goto out;
+	}
+
+	if (info) {
+		rv = do_dump("info");
+		goto out;
+	}
+
+	if (dump) {
+		rv = do_dump("dump");
+		goto out;
+	}
+
+	if (gl_enable) {
+		rv = do_able("enable_gl");
+		goto out;
+	}
+
+	if (gl_disable) {
+		rv = do_able("disable_gl");
+		goto out;
+	}
+
+	if (stop_lockspaces) {
+		rv = do_stop_lockspaces();
+		goto out;
+	}
+
+out:
+	lvmlockd_close(_lvmlockd);
+	return rv;
+}
+
diff --git a/daemons/lvmlockd/lvmlockd-client.h b/daemons/lvmlockd/lvmlockd-client.h
new file mode 100644
index 0000000..0a3e4b2
--- /dev/null
+++ b/daemons/lvmlockd/lvmlockd-client.h
@@ -0,0 +1,49 @@
+/*
+ * Copyright (C) 2014 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ */
+
+#ifndef _LVM_LVMLOCKD_CLIENT_H
+#define _LVM_LVMLOCKD_CLIENT_H
+
+#include "daemon-client.h"
+
+#define LVMLOCKD_SOCKET DEFAULT_RUN_DIR "/lvmlockd.socket"
+
+/* Wrappers to open/close connection */
+
+static inline daemon_handle lvmlockd_open(const char *sock)
+{
+	daemon_info lvmlockd_info = {
+		.path = "lvmlockd",
+		.socket = sock ?: LVMLOCKD_SOCKET,
+		.protocol = "lvmlockd",
+		.protocol_version = 1,
+		.autostart = 0
+	};
+
+	return daemon_open(lvmlockd_info);
+}
+
+static inline void lvmlockd_close(daemon_handle h)
+{
+	return daemon_close(h);
+}
+
+/*
+ * Errors returned as the lvmlockd result value.
+ */
+#define ENOLS     210 /* lockspace not found */
+#define ESTARTING 211 /* lockspace is starting */
+#define EARGS     212
+#define EHOSTID   213
+#define EMANAGER  214
+#define EPREPARE  215
+#define ELOCKD    216
+
+#endif
diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
new file mode 100644
index 0000000..d058ea1
--- /dev/null
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -0,0 +1,5715 @@
+/*
+ * Copyright (C) 2014 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ */
+
+#define _XOPEN_SOURCE 500  /* pthread */
+#define _ISOC99_SOURCE
+#define _GNU_SOURCE
+
+#include "configure.h"
+#include "daemon-io.h"
+#include "daemon-server.h"
+#include "daemon-log.h"
+#include "config-util.h"
+#include "lvm-version.h"
+#include "lvmetad-client.h"
+#include "lvmlockd-client.h"
+
+#include <assert.h>
+#include <pthread.h>
+#include <stdint.h>
+#include <stddef.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <poll.h>
+#include <errno.h>
+#include <signal.h>
+#include <getopt.h>
+#include <syslog.h>
+#include <dirent.h>
+#include <time.h>
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <sys/utsname.h>
+#include <sys/un.h>
+
+#define EXTERN
+#include "lvmlockd-internal.h"
+
+/*
+ * Basic operation of lvmlockd
+ *
+ * lvmlockd main process runs main_loop() which uses poll().
+ * poll listens for new connections from lvm commands and for
+ * messages from existing connected lvm commands.
+ *
+ * lvm command starts and connects to lvmlockd.
+ *
+ * lvmlockd receives a connection request from command and adds a
+ * 'struct client' to keep track of the connection to the command.
+ * The client's fd is added to the set of fd's in poll().
+ *
+ * lvm command sends a lock request to lvmlockd.  The lock request
+ * can be for the global lock, a vg lock, or an lv lock.
+ *
+ * lvmlockd main_loop/poll sees a message from an existing client.
+ * It sets client.recv = 1, then wakes up client_thread_main.
+ *
+ * client_thread_main iterates through client structs (cl), looking
+ * for any that need processing, finds the one with cl->recv set,
+ * and calls client_recv_action(cl).
+ *
+ * client_recv_action(cl) reads the message/request from the client,
+ * allocates a new 'struct action' (act) to represent the request,
+ * sets the act with what is found in the request, then looks at
+ * the specific operation in act->op (LD_OP_FOO) to decide what to
+ * do with the action:
+ *
+ * . If the action is to start a lockspace, create a new thread
+ *   to manage that lockspace: add_lockspace(act).
+ *
+ * . If the action is a lock request, pass the act to the thread
+ *   that is managing that lockspace: add_lock_action(act).
+ *
+ * . Other misc actions are are passed to the worker_thread:
+ *   add_work_action(act).
+ *
+ * Onec the client_thread has passed the action off to another
+ * thread to process, it goes back to waiting for more client
+ * handling work to do.
+ *
+ * The thread that was given the action by the client_thread
+ * now processes that action according to the operation, act->op.
+ * This is either a lockspace_thread (for lock ops or ops that
+ * add/rem a lockspace), or the worker_thread.  See below for
+ * how these ops are processed by these threads.  When the
+ * given thread is done processing the action, the result is
+ * set in act->result, and the act struct for the completed action
+ * is passed back to the client_thread (client_results list).
+ *
+ * The client_thread takes completed actions (from client_results
+ * list), and sends the result back to the client that sent the
+ * request represented by the action.  The act struct is then freed.
+ *
+ * This completes the cycle of work between lvm commands (clients)
+ * and lvmlockd.  In summary:
+ *
+ * - main process polls for new client connections and new requests
+ *   from lvm commands
+ * - client_thread reads requests from clients
+ * - client_thread creates an action struct for each request
+ * - client_thread passes the act to another thread for processing
+ * - other threads pass completed act structs back to client_thread
+ * - client_thread sends the act result back to the client and frees the act
+ *
+ *
+ * Lockspace threads:
+ * Each lockd VG has its own lockspace that contains locks for that VG.
+ * Each 'struct lockspace' is managed by a separate lockspace_thread.
+ * When the lockspace_thread is first created, the first thing it does
+ * is join the lockspace in the lock manager.  This can take a long time.
+ * If the join fails, the thread exits.  After the join, the thread
+ * enters a loop waiting for lock actions to perform in the lockspace.
+ *
+ * The request to remove/leave a lockspace causes a flag to be set in
+ * the lockspace struct.  When the lockspace_thread sees this flag
+ * set, it leaves the lockspace, and exits.
+ *
+ * When the client_thread passes a new action to a lockspace_thread,
+ * i.e. a new lock request, the lockspace_thread identifies which resource
+ * is being locked (GL, VG, LV), and gets the 'struct resource' (r) for it.
+ * r->type will be LD_RT_GL, LD_RT_VG, or LD_RT_LV.  r->name is the
+ * resource name, and is fixed for GL and VG resources, but is based on
+ * the LV name for LV resources.  The act is added to the resource's
+ * list of actions: r->actions, i.e. outstanding lock requests on the
+ * resource.
+ *
+ * The lockspace thread then iterates through each resource in the
+ * lockspace, processing any outstanding actions on each: res_process(ls, r).
+ *
+ * res_process() compares the outstanding actions/requests in r->actions
+ * against any existing locks on the resource in r->locks.  If the
+ * action is blocked by existing locks, it's left on r->actions.  If not,
+ * the action/request is passed to the lock manager.  If the result from
+ * the lock manager is success, a new 'struct lock' is created for the
+ * action and saved on r->locks.  The result is set in act->result and
+ * the act is passed back to the client_thread to be returned to the client.
+ */
+
+static const char *lvmlockd_protocol = "lvmlockd";
+static const int lvmlockd_protocol_version = 1;
+static int daemon_quit;
+static int adopt_opt;
+
+static daemon_handle lvmetad_handle;
+static pthread_mutex_t lvmetad_mutex;
+static int lvmetad_connected;
+
+/*
+ * We use a separate socket for dumping daemon info.
+ * This will not interfere with normal operations, and allows
+ * free-form debug data to be dumped instead of the libdaemon
+ * protocol that wants all data in the cft format.
+ * 1MB should fit all the info we need to dump.
+ */
+#define DUMP_SOCKET_NAME "lvmlockd-dump.sock"
+#define DUMP_BUF_SIZE (1024 * 1024)
+static char dump_buf[DUMP_BUF_SIZE];
+static struct sockaddr_un dump_addr;
+static socklen_t dump_addrlen;
+
+/*
+ * Main program polls client connections, adds new clients,
+ * adds work for client thread.
+ *
+ * pollfd_mutex is used for adding vs removing entries,
+ * and for resume vs realloc.
+ */
+#define POLL_FD_UNUSED -1		/* slot if free */
+#define POLL_FD_IGNORE -2		/* slot is used but ignore in poll */
+#define ADD_POLL_SIZE 16		/* increment slots by this amount */
+
+static pthread_mutex_t pollfd_mutex;
+static struct pollfd *pollfd;
+static int pollfd_size;
+static int pollfd_maxi;
+static int listen_pi;
+static int listen_fd;
+static int restart_pi;
+static int restart_fds[2];
+
+/*
+ * Each lockspace has its own thread to do locking.
+ * The lockspace thread makes synchronous lock requests to dlm/sanlock.
+ * Every vg with a lockd type, i.e. "dlm", "sanlock", should be on this list.
+ *
+ * lockspaces_inactive holds old ls structs for vgs that have been
+ * stopped, or for vgs that failed to start.  The old ls structs
+ * are removed from the inactive list and freed when a new ls with
+ * the same name is started and added to the standard lockspaces list.
+ * Keeping this bit of "history" for the ls allows us to return a
+ * more informative error message if a vg lock request is made for
+ * an ls that has been stopped or failed to start.
+ */
+static pthread_mutex_t lockspaces_mutex;
+static struct list_head lockspaces;
+static struct list_head lockspaces_inactive;
+
+/*
+ * This flag is set to 1 if we see multiple vgs with the global
+ * lock enabled.  While this is set, we return a special flag
+ * with the vg lock result indicating to the lvm command that
+ * there is a duplicate gl in the vg which should be resolved.
+ * While this is set, find_lockspace_name has the side job of
+ * counting the number of lockspaces with enabled gl's so that
+ * this can be set back to zero when the duplicates are disabled.
+ */
+static int sanlock_gl_dup;
+
+/*
+ * Client thread reads client requests and writes client results.
+ */
+static pthread_t client_thread;
+static pthread_mutex_t client_mutex;
+static pthread_cond_t client_cond;
+static struct list_head client_list;    /* connected clients */
+static struct list_head client_results; /* actions to send back to clients */
+static uint32_t client_ids;             /* 0 and ADOPT_CLIENT_ID are skipped */
+static int client_stop;                 /* stop the thread */
+static int client_work;                 /* a client on client_list has work to do */
+
+#define ADOPT_CLIENT_ID 0xFFFFFFFF      /* special client_id for adopt actions */
+static struct list_head adopt_results;  /* special start actions from adopt_locks() */
+
+/*
+ * Worker thread performs misc non-locking actions, e.g. init/free.
+ */
+static pthread_t worker_thread;
+static pthread_mutex_t worker_mutex;
+static pthread_cond_t worker_cond;
+static struct list_head worker_list;    /* actions for worker_thread */
+static int worker_stop;                 /* stop the thread */
+static int worker_wake;                 /* wake the thread without adding work */
+
+/*
+ * The content of every log_foo() statement is saved in the
+ * circular buffer, which can be dumped to a client and printed.
+ */
+#define LOG_LINE_SIZE 256
+#define LOG_DUMP_SIZE DUMP_BUF_SIZE
+#define LOG_SYSLOG_PRIO LOG_WARNING
+static char log_dump[LOG_DUMP_SIZE];
+static unsigned int log_point;
+static unsigned int log_wrap;
+static pthread_mutex_t log_mutex;
+static int syslog_priority = LOG_SYSLOG_PRIO;
+
+/*
+ * Structure pools to avoid repeated malloc/free.
+ */
+#define MAX_UNUSED_ACTION 64
+#define MAX_UNUSED_CLIENT 64
+#define MAX_UNUSED_RESOURCE 64
+#define MAX_UNUSED_LOCK 64
+static pthread_mutex_t unused_struct_mutex;
+static struct list_head unused_action;
+static struct list_head unused_client;
+static struct list_head unused_resource;
+static struct list_head unused_lock;
+static int unused_action_count;
+static int unused_client_count;
+static int unused_resource_count;
+static int unused_lock_count;
+static int resource_lm_data_size; /* max size of lm_data from sanlock|dlm */
+static int alloc_new_structs; /* used for initializing in setup_structs */
+
+#define DO_STOP 1
+#define NO_STOP 0
+#define DO_FREE 1
+#define NO_FREE 0
+#define DO_FORCE 1
+#define NO_FORCE 0
+
+static int add_lock_action(struct action *act);
+static int str_to_lm(const char *str);
+static int clear_lockspace_inactive(char *name);
+
+static int _syslog_name_to_num(const char *name)
+{
+	if (!strcmp(name, "emerg"))
+		return LOG_EMERG;
+	if (!strcmp(name, "alert"))
+		return LOG_ALERT;
+	if (!strcmp(name, "crit"))
+		return LOG_CRIT;
+	if (!strcmp(name, "err") || !strcmp(name, "error"))
+		return LOG_ERR;
+	if (!strcmp(name, "warning") || !strcmp(name, "warn"))
+		return LOG_WARNING;
+	if (!strcmp(name, "notice"))
+		return LOG_NOTICE;
+	if (!strcmp(name, "info"))
+		return LOG_INFO;
+	if (!strcmp(name, "debug"))
+		return LOG_DEBUG;
+	return LOG_WARNING;
+}
+
+static const char *_syslog_num_to_name(int num)
+{
+	switch (num) {
+	case LOG_EMERG:
+		return "emerg";
+	case LOG_ALERT:
+		return "alert";
+	case LOG_CRIT:
+		return "crit";
+	case LOG_ERR:
+		return "err";
+	case LOG_WARNING:
+		return "warning";
+	case LOG_NOTICE:
+		return "notice";
+	case LOG_INFO:
+		return "info";
+	case LOG_DEBUG:
+		return "debug";
+	}
+	return "unknown";
+}
+
+static uint64_t monotime(void)
+{
+	struct timespec ts;
+	clock_gettime(CLOCK_MONOTONIC, &ts);
+	return ts.tv_sec;
+}
+
+static void log_save_line(int len, char *line,
+			  char *log_buf, unsigned int *point, unsigned int *wrap)
+{
+	unsigned int p = *point;
+	unsigned int w = *wrap;
+	int i;
+
+	if (len < LOG_DUMP_SIZE - p) {
+		memcpy(log_buf + p, line, len);
+		p += len;
+
+		if (p == LOG_DUMP_SIZE) {
+			p = 0;
+			w = 1;
+		}
+		goto out;
+	}
+
+	for (i = 0; i < len; i++) {
+		log_buf[p++] = line[i];
+
+		if (p == LOG_DUMP_SIZE) {
+			p = 0;
+			w = 1;
+		}
+	}
+ out:
+	*point = p;
+	*wrap = w;
+}
+
+void log_level(int level, const char *fmt, ...)
+{
+	char line[LOG_LINE_SIZE];
+	va_list ap;
+	int len = LOG_LINE_SIZE - 1;
+	int ret, pos = 0;
+
+	memset(line, 0, sizeof(line));
+
+	ret = snprintf(line, len, "%llu ", (unsigned long long)time(NULL));
+	pos += ret;
+
+	va_start(ap, fmt);
+	ret = vsnprintf(line + pos, len - pos, fmt, ap);
+	va_end(ap);
+
+	if (ret >= len - pos)
+		pos = len - 1;
+	else
+		pos += ret;
+
+	line[pos++] = '\n';
+	line[pos++] = '\0';
+
+	pthread_mutex_lock(&log_mutex);
+	log_save_line(pos - 1, line, log_dump, &log_point, &log_wrap);
+	pthread_mutex_unlock(&log_mutex);
+
+	if (level <= syslog_priority)
+		syslog(level, "%s", line);
+
+	if (daemon_debug)
+		fprintf(stderr, "%s", line);
+}
+
+static int dump_log(int *dump_len)
+{
+	int tail_len;
+
+	pthread_mutex_lock(&log_mutex);
+
+	if (!log_wrap && !log_point) {
+		*dump_len = 0;
+	} else if (log_wrap) {
+		tail_len = LOG_DUMP_SIZE - log_point;
+		memcpy(dump_buf, log_dump+log_point, tail_len);
+		if (log_point)
+			memcpy(dump_buf+tail_len, log_dump, log_point);
+		*dump_len = LOG_DUMP_SIZE;
+	} else {
+		memcpy(dump_buf, log_dump, log_point-1);
+		*dump_len = log_point-1;
+	}
+	pthread_mutex_unlock(&log_mutex);
+
+	return 0;
+}
+
+struct lockspace *alloc_lockspace(void)
+{
+	struct lockspace *ls;
+
+	if (!(ls = malloc(sizeof(struct lockspace)))) {
+		log_error("out of memory for lockspace");
+		return NULL;
+	}
+
+	memset(ls, 0, sizeof(struct lockspace));
+	INIT_LIST_HEAD(&ls->actions);
+	INIT_LIST_HEAD(&ls->resources);
+	pthread_mutex_init(&ls->mutex, NULL);
+	pthread_cond_init(&ls->cond, NULL);
+	return ls;
+}
+
+static struct action *alloc_action(void)
+{
+	struct action *act;
+
+	pthread_mutex_lock(&unused_struct_mutex);
+	if (!unused_action_count || alloc_new_structs) {
+		act = malloc(sizeof(struct action));
+	} else {
+		act = list_first_entry(&unused_action, struct action, list);
+		list_del(&act->list);
+		unused_action_count--;
+	}
+	pthread_mutex_unlock(&unused_struct_mutex);
+	if (act)
+		memset(act, 0, sizeof(struct action));
+	else
+		log_error("out of memory for action");
+	return act;
+}
+
+static struct client *alloc_client(void)
+{
+	struct client *cl;
+
+	pthread_mutex_lock(&unused_struct_mutex);
+	if (!unused_client_count || alloc_new_structs) {
+		cl = malloc(sizeof(struct client));
+	} else {
+		cl = list_first_entry(&unused_client, struct client, list);
+		list_del(&cl->list);
+		unused_client_count--;
+	}
+	pthread_mutex_unlock(&unused_struct_mutex);
+	if (cl)
+		memset(cl, 0, sizeof(struct client));
+	else
+		log_error("out of memory for client");
+	return cl;
+}
+
+static struct resource *alloc_resource(void)
+{
+	struct resource *r;
+
+	pthread_mutex_lock(&unused_struct_mutex);
+	if (!unused_resource_count || alloc_new_structs) {
+		r = malloc(sizeof(struct resource) + resource_lm_data_size);
+	} else {
+		r = list_first_entry(&unused_resource, struct resource, list);
+		list_del(&r->list);
+		unused_resource_count--;
+	}
+	pthread_mutex_unlock(&unused_struct_mutex);
+	if (r) {
+		memset(r, 0, sizeof(struct resource) + resource_lm_data_size);
+		INIT_LIST_HEAD(&r->locks);
+		INIT_LIST_HEAD(&r->actions);
+	} else {
+		log_error("out of memory for resource");
+	}
+	return r;
+}
+
+static struct lock *alloc_lock(void)
+{
+	struct lock *lk;
+
+	pthread_mutex_lock(&unused_struct_mutex);
+	if (!unused_lock_count || alloc_new_structs) {
+		lk = malloc(sizeof(struct lock));
+	} else {
+		lk = list_first_entry(&unused_lock, struct lock, list);
+		list_del(&lk->list);
+		unused_lock_count--;
+	}
+	pthread_mutex_unlock(&unused_struct_mutex);
+	if (lk)
+		memset(lk, 0, sizeof(struct lock));
+	else
+		log_error("out of memory for lock");
+	return lk;
+}
+
+static void free_action(struct action *act)
+{
+	pthread_mutex_lock(&unused_struct_mutex);
+	if (unused_action_count >= MAX_UNUSED_ACTION) {
+		free(act);
+	} else {
+		list_add_tail(&act->list, &unused_action);
+		unused_action_count++;
+	}
+	pthread_mutex_unlock(&unused_struct_mutex);
+}
+
+static void free_client(struct client *cl)
+{
+	pthread_mutex_lock(&unused_struct_mutex);
+	if (unused_client_count >= MAX_UNUSED_CLIENT) {
+		free(cl);
+	} else {
+		list_add_tail(&cl->list, &unused_client);
+		unused_client_count++;
+	}
+	pthread_mutex_unlock(&unused_struct_mutex);
+}
+
+static void free_resource(struct resource *r)
+{
+	pthread_mutex_lock(&unused_struct_mutex);
+	if (unused_resource_count >= MAX_UNUSED_RESOURCE) {
+		free(r);
+	} else {
+		list_add_tail(&r->list, &unused_resource);
+		unused_resource_count++;
+	}
+	pthread_mutex_unlock(&unused_struct_mutex);
+}
+
+static void free_lock(struct lock *lk)
+{
+	pthread_mutex_lock(&unused_struct_mutex);
+	if (unused_lock_count >= MAX_UNUSED_LOCK) {
+		free(lk);
+	} else {
+		list_add_tail(&lk->list, &unused_lock);
+		unused_lock_count++;
+	}
+	pthread_mutex_unlock(&unused_struct_mutex);
+}
+
+static int setup_structs(void)
+{
+	struct action *act;
+	struct client *cl;
+	struct resource *r;
+	struct lock *lk;
+	int data_san = lm_data_size_sanlock();
+	int data_dlm = lm_data_size_dlm();
+	int i;
+
+	resource_lm_data_size = data_san > data_dlm ? data_san : data_dlm;
+
+	pthread_mutex_init(&unused_struct_mutex, NULL);
+	INIT_LIST_HEAD(&unused_action);
+	INIT_LIST_HEAD(&unused_client);
+	INIT_LIST_HEAD(&unused_resource);
+	INIT_LIST_HEAD(&unused_lock);
+
+	/*
+	 * For setup, force the alloc_ functions to alloc new structs instead
+	 * of taking them unused.  This allows alloc_struct/free_struct loop to
+	 * populate the unused lists.
+	 */
+	alloc_new_structs = 1;
+
+	for (i = 0; i < MAX_UNUSED_ACTION/2; i++) {
+		if (!(act = alloc_action()))
+			goto fail;
+		free_action(act);
+	}
+
+	for (i = 0; i < MAX_UNUSED_CLIENT/2; i++) {
+		if (!(cl = alloc_client()))
+			goto fail;
+		free_client(cl);
+	}
+
+	for (i = 0; i < MAX_UNUSED_RESOURCE/2; i++) {
+		if (!(r = alloc_resource()))
+			goto fail;
+		free_resource(r);
+	}
+
+	for (i = 0; i < MAX_UNUSED_LOCK/2; i++) {
+		if (!(lk = alloc_lock()))
+			goto fail;
+		free_lock(lk);
+	}
+
+	alloc_new_structs = 0;
+	return 0;
+fail:
+	alloc_new_structs = 0;
+	return -ENOMEM;
+}
+
+static int add_pollfd(int fd)
+{
+	int i, new_size;
+
+	pthread_mutex_lock(&pollfd_mutex);
+	for (i = 0; i < pollfd_size; i++) {
+		if (pollfd[i].fd != POLL_FD_UNUSED)
+			continue;
+
+		pollfd[i].fd = fd;
+		pollfd[i].events = POLLIN;
+		pollfd[i].revents = 0;
+
+		if (i > pollfd_maxi)
+			pollfd_maxi = i;
+
+		pthread_mutex_unlock(&pollfd_mutex);
+		return i;
+	}
+
+	new_size = pollfd_size + ADD_POLL_SIZE;
+
+	pollfd = realloc(pollfd, new_size * sizeof(struct pollfd));
+	if (!pollfd) {
+		log_error("can't alloc new size %d for pollfd", new_size);
+		return -ENOMEM;
+	}
+
+	for (i = pollfd_size; i < new_size; i++) {
+		pollfd[i].fd = POLL_FD_UNUSED;
+		pollfd[i].events = 0;
+		pollfd[i].revents = 0;
+	}
+
+	i = pollfd_size;
+	pollfd[i].fd = fd;
+	pollfd[i].events = POLLIN;
+	pollfd[i].revents = 0;
+	pollfd_maxi = i;
+
+	pollfd_size = new_size;
+
+	pthread_mutex_unlock(&pollfd_mutex);
+	return i;
+}
+
+static void rem_pollfd(int pi)
+{
+	if (pi < 0) {
+		log_error("rem_pollfd %d", pi);
+		return;
+	}
+	pthread_mutex_lock(&pollfd_mutex);
+	pollfd[pi].fd = POLL_FD_UNUSED;
+	pollfd[pi].events = 0;
+	pollfd[pi].revents = 0;
+	pthread_mutex_unlock(&pollfd_mutex);
+}
+
+static const char *lm_str(int x)
+{
+	switch (x) {
+	case LD_LM_NONE:
+		return "none";
+	case LD_LM_DLM:
+		return "dlm";
+	case LD_LM_SANLOCK:
+		return "sanlock";
+	default:
+		return "lm_unknown";
+	}
+}
+
+static const char *rt_str(int x)
+{
+	switch (x) {
+	case LD_RT_GL:
+		return "gl";
+	case LD_RT_VG:
+		return "vg";
+	case LD_RT_LV:
+		return "lv";
+	default:
+		return ".";
+	};
+}
+
+static const char *op_str(int x)
+{
+	switch (x) {
+	case LD_OP_INIT:
+		return "init";
+	case LD_OP_FREE:
+		return "free";
+	case LD_OP_START:
+		return "start";
+	case LD_OP_STOP:
+		return "stop";
+	case LD_OP_LOCK:
+		return "lock";
+	case LD_OP_UPDATE:
+		return "update";
+	case LD_OP_CLOSE:
+		return "close";
+	case LD_OP_ENABLE:
+		return "enable";
+	case LD_OP_DISABLE:
+		return "disable";
+	case LD_OP_START_WAIT:
+		return "start_wait";
+	case LD_OP_STOP_ALL:
+		return "stop_all";
+	case LD_OP_RENAME_BEFORE:
+		return "rename_before";
+	case LD_OP_RENAME_FINAL:
+		return "rename_final";
+	case LD_OP_RUNNING_LM:
+		return "running_lm";
+	case LD_OP_FIND_FREE_LOCK:
+		return "find_free_lock";
+	case LD_OP_FORGET_VG_NAME:
+		return "forget_vg_name";
+	default:
+		return "op_unknown";
+	};
+}
+
+static const char *mode_str(int x)
+{
+	switch (x) {
+	case LD_LK_IV:
+		return "iv";
+	case LD_LK_UN:
+		return "un";
+	case LD_LK_NL:
+		return "nl";
+	case LD_LK_SH:
+		return "sh";
+	case LD_LK_EX:
+		return "ex";
+	default:
+		return ".";
+	};
+}
+
+int last_string_from_args(char *args_in, char *last)
+{
+	const char *args = args_in;
+	const char *colon, *str = NULL;
+
+	while (1) {
+		if (!args || (*args == '\0'))
+			break;
+		colon = strstr(args, ":");
+		if (!colon)
+			break;
+		str = colon;
+		args = colon + 1;
+        }
+
+	if (str) {
+		snprintf(last, MAX_ARGS, "%s", str + 1);
+		return 0;
+	}
+	return -1;
+}
+
+int version_from_args(char *args, unsigned int *major, unsigned int *minor, unsigned int *patch)
+{
+	char version[MAX_ARGS];
+	char *major_str, *minor_str, *patch_str;
+	char *n, *d1, *d2;
+
+	strncpy(version, args, MAX_ARGS);
+
+	n = strstr(version, ":");
+	if (n)
+		*n = '\0';
+
+	d1 = strstr(version, ".");
+	if (!d1)
+		return -1;
+
+	d2 = strstr(d1 + 1, ".");
+	if (!d2)
+		return -1;
+
+	major_str = version;
+	minor_str = d1 + 1;
+	patch_str = d2 + 1;
+
+	*d1 = '\0';
+	*d2 = '\0';
+
+	if (major)
+		*major = atoi(major_str);
+	if (minor)
+		*minor = atoi(minor_str);
+	if (patch)
+		*patch = atoi(patch_str);
+
+	return 0;
+}
+
+/*
+ * These are few enough that arrays of function pointers can
+ * be avoided.
+ */
+
+static int lm_prepare_lockspace(struct lockspace *ls, struct action *act)
+{
+	int rv;
+
+	if (ls->lm_type == LD_LM_DLM)
+		rv = lm_prepare_lockspace_dlm(ls);
+	else if (ls->lm_type == LD_LM_SANLOCK)
+		rv = lm_prepare_lockspace_sanlock(ls);
+	else
+		return -1;
+
+	if (act)
+		act->lm_rv = rv;
+	return rv;
+}
+
+static int lm_add_lockspace(struct lockspace *ls, struct action *act, int adopt)
+{
+	int rv;
+
+	if (ls->lm_type == LD_LM_DLM)
+		rv = lm_add_lockspace_dlm(ls, adopt);
+	else if (ls->lm_type == LD_LM_SANLOCK)
+		rv = lm_add_lockspace_sanlock(ls, adopt);
+	else
+		return -1;
+
+	if (act)
+		act->lm_rv = rv;
+	return rv;
+}
+
+static int lm_rem_lockspace(struct lockspace *ls, struct action *act, int free_vg)
+{
+	int rv;
+
+	if (ls->lm_type == LD_LM_DLM)
+		rv = lm_rem_lockspace_dlm(ls, free_vg);
+	else if (ls->lm_type == LD_LM_SANLOCK)
+		rv = lm_rem_lockspace_sanlock(ls, free_vg);
+	else
+		return -1;
+
+	if (act)
+		act->lm_rv = rv;
+	return rv;
+}
+
+static int lm_lock(struct lockspace *ls, struct resource *r, int mode, struct action *act,
+		   uint32_t *r_version, int *retry, int adopt)
+{
+	int rv;
+
+	if (ls->lm_type == LD_LM_DLM)
+		rv = lm_lock_dlm(ls, r, mode, r_version, adopt);
+	else if (ls->lm_type == LD_LM_SANLOCK)
+		rv = lm_lock_sanlock(ls, r, mode, r_version, retry, adopt);
+	else
+		return -1;
+
+	if (act)
+		act->lm_rv = rv;
+	return rv;
+}
+
+static int lm_convert(struct lockspace *ls, struct resource *r,
+		      int mode, struct action *act, uint32_t r_version)
+{
+	int rv;
+
+	if (ls->lm_type == LD_LM_DLM)
+		rv = lm_convert_dlm(ls, r, mode, r_version);
+	else if (ls->lm_type == LD_LM_SANLOCK)
+		rv = lm_convert_sanlock(ls, r, mode, r_version);
+	else
+		return -1;
+
+	if (act)
+		act->lm_rv = rv;
+	return rv;
+}
+
+static int lm_unlock(struct lockspace *ls, struct resource *r, struct action *act,
+		     uint32_t r_version, uint32_t lmu_flags)
+{
+	int rv;
+
+	if (ls->lm_type == LD_LM_DLM)
+		return lm_unlock_dlm(ls, r, r_version, lmu_flags);
+	else if (ls->lm_type == LD_LM_SANLOCK)
+		return lm_unlock_sanlock(ls, r, r_version, lmu_flags);
+	else
+		return -1;
+
+	if (act)
+		act->lm_rv = rv;
+	return rv;
+}
+
+static int lm_hosts(struct lockspace *ls, int notify)
+{
+	if (ls->lm_type == LD_LM_DLM)
+		return 0;
+	else if (ls->lm_type == LD_LM_SANLOCK)
+		return lm_hosts_sanlock(ls, notify);
+	return -1;
+}
+
+static void lm_rem_resource(struct lockspace *ls, struct resource *r)
+{
+	if (ls->lm_type == LD_LM_DLM)
+		lm_rem_resource_dlm(ls, r);
+	else if (ls->lm_type == LD_LM_SANLOCK)
+		lm_rem_resource_sanlock(ls, r);
+}
+
+static int lm_find_free_lock(struct lockspace *ls, uint64_t *free_offset)
+{
+	if (ls->lm_type == LD_LM_DLM)
+		return 0;
+	else if (ls->lm_type == LD_LM_SANLOCK)
+		return lm_find_free_lock_sanlock(ls, free_offset);
+	return -1;
+}
+
+/*
+ * While adopting locks, actions originate from the adopt_locks()
+ * function, not from a client.  So, these actions (flagged ADOPT),
+ * should be passed back to the adopt_locks() function through the
+ * adopt_results list, and not be sent back to a client via the
+ * client_list/client_thread.
+ */
+
+static void add_client_result(struct action *act)
+{
+	pthread_mutex_lock(&client_mutex);
+	if (act->flags & LD_AF_ADOPT)
+		list_add_tail(&act->list, &adopt_results);
+	else
+		list_add_tail(&act->list, &client_results);
+	pthread_cond_signal(&client_cond);
+	pthread_mutex_unlock(&client_mutex);
+}
+
+static struct lock *find_lock_client(struct resource *r, uint32_t client_id)
+{
+	struct lock *lk;
+
+	list_for_each_entry(lk, &r->locks, list) {
+		if (lk->client_id == client_id)
+			return lk;
+	}
+	return NULL;
+}
+
+static struct lock *find_lock_persistent(struct resource *r)
+{
+	struct lock *lk;
+
+	list_for_each_entry(lk, &r->locks, list) {
+		if (lk->flags & LD_LF_PERSISTENT)
+			return lk;
+	}
+	return NULL;
+}
+
+static struct action *find_action_client(struct resource *r, uint32_t client_id)
+{
+	struct action *act;
+
+	list_for_each_entry(act, &r->actions, list) {
+		if (act->client_id != client_id)
+			continue;
+		return act;
+	}
+	return NULL;
+}
+
+static void add_work_action(struct action *act)
+{
+	pthread_mutex_lock(&worker_mutex);
+	if (!worker_stop) {
+		list_add_tail(&act->list, &worker_list);
+		pthread_cond_signal(&worker_cond);
+	}
+	pthread_mutex_unlock(&worker_mutex);
+}
+
+static int res_lock(struct lockspace *ls, struct resource *r, struct action *act, int *retry)
+{
+	struct lock *lk;
+	uint32_t r_version = 0;
+	int rv;
+
+	log_debug("S %s R %s res_lock mode %s", ls->name, r->name, mode_str(act->mode));
+
+	if (r->mode == LD_LK_SH && act->mode == LD_LK_SH)
+		goto add_lk;
+
+	if (r->type == LD_RT_LV && act->lv_args[0])
+		memcpy(r->lv_args, act->lv_args, MAX_ARGS);
+
+	rv = lm_lock(ls, r, act->mode, act, &r_version, retry, act->flags & LD_AF_ADOPT);
+	if (rv == -EAGAIN)
+		return rv;
+	if (rv < 0) {
+		log_error("S %s R %s res_lock lm error %d", ls->name, r->name, rv);
+		return rv;
+	}
+
+	log_debug("S %s R %s res_lock lm done r_version %u",
+		  ls->name, r->name, r_version);
+
+	/* lm_lock() reads new r_version */
+
+	if ((r_version > r->version) || (!r->version && !r->version_zero_valid)) {
+		/*
+		 * New r_version of the lock: means that another
+		 * host has changed data protected by this lock
+		 * since the last time we acquired it.  We
+		 * should invalidate any local cache of the data
+		 * protected by this lock and reread it from disk.
+		 */
+		r->version = r_version;
+
+		/*
+		 * When a new global lock is enabled in a new vg,
+		 * it will have version zero, and the first time
+		 * we use it we need to validate the global cache
+		 * since we don't have any version history to know
+		 * the state of the cache.  The version could remain
+		 * zero for a long time if no global state is changed
+		 * to cause the GL version to be incremented to 1.
+		 */
+		r->version_zero_valid = 1;
+
+		/*
+		 * r is vglk: tell lvmetad to set the vg invalid
+		 * flag, and provide the new r_version.  If lvmetad finds
+		 * that its cached vg has seqno less than the value
+		 * we send here, it will set the vg invalid flag.
+		 * lvm commands that read the vg from lvmetad, will
+		 * see the invalid flag returned, will reread the
+		 * vg from disk, update the lvmetad copy, and go on.
+		 *
+		 * r is global: tell lvmetad to set the global invalid
+		 * flag.  When commands see this flag returned from lvmetad,
+		 * they will reread metadata from disk, update the lvmetad
+		 * caches, and tell lvmetad to set global invalid to 0.
+		 */
+
+		if ((r->type == LD_RT_VG) && lvmetad_connected) {
+			daemon_reply reply;
+			char *uuid;
+
+			log_debug("S %s R %s res_lock set lvmetad vg version %u",
+				  ls->name, r->name, r_version);
+	
+			if (!ls->vg_uuid[0] || !strcmp(ls->vg_uuid, "none"))
+				uuid = ls->name;
+			else
+				uuid = ls->vg_uuid;
+
+			pthread_mutex_lock(&lvmetad_mutex);
+			reply = daemon_send_simple(lvmetad_handle, "set_vg_info",
+						   "token = %s", "skip",
+						   "uuid = %s", uuid,
+						   "version = %d", (int)r_version,
+						   NULL);
+			pthread_mutex_unlock(&lvmetad_mutex);
+
+			if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK"))
+				log_error("set_vg_info in lvmetad failed %d", reply.error);
+			daemon_reply_destroy(reply);
+		}
+
+		if ((r->type == LD_RT_GL) && lvmetad_connected) {
+			daemon_reply reply;
+
+			log_debug("S %s R %s res_lock set lvmetad global invalid",
+				  ls->name, r->name);
+
+			pthread_mutex_lock(&lvmetad_mutex);
+			reply = daemon_send_simple(lvmetad_handle, "set_global_info",
+						   "token = %s", "skip",
+						   "global_invalid = %d", 1,
+						   NULL);
+			pthread_mutex_unlock(&lvmetad_mutex);
+
+			if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK"))
+				log_error("set_global_info in lvmetad failed %d", reply.error);
+			daemon_reply_destroy(reply);
+		}
+	}
+
+	r->mode = act->mode;
+
+add_lk:
+	if (r->mode == LD_LK_SH)
+		r->sh_count++;
+
+	if (!(lk = alloc_lock()))
+		return -ENOMEM;
+
+	lk->client_id = act->client_id;
+	lk->mode = act->mode;
+
+	if (act->flags & LD_AF_PERSISTENT) {
+		lk->flags |= LD_LF_PERSISTENT;
+		lk->client_id = 0;
+	}
+
+	list_add_tail(&lk->list, &r->locks);
+
+	return 0;
+}
+
+static int res_convert(struct lockspace *ls, struct resource *r,
+		       struct lock *lk, struct action *act)
+{
+	uint32_t r_version;
+	int rv;
+
+	log_debug("S %s R %s res_convert mode %d", ls->name, r->name, act->mode);
+
+	if (act->mode == LD_LK_EX && lk->mode == LD_LK_SH && r->sh_count > 1)
+		return -EAGAIN;
+
+	/*
+	 * lm_convert() writes new version (from ex)
+	 * Same as lm_unlock()
+	 */
+
+        if ((r->type == LD_RT_GL) && (r->mode == LD_LK_EX)) {
+		r->version++;
+		lk->version = r->version;
+		r_version = r->version;
+		log_debug("S %s R %s res_convert r_version inc %u",
+			  ls->name, r->name, r_version);
+
+	} else if ((r->type == LD_RT_VG) && (r->mode == LD_LK_EX) && (lk->version > r->version)) {
+		r->version = lk->version;
+		r_version = r->version;
+		log_debug("S %s R %s res_convert r_version new %u", ls->name, r->name, r_version);
+	} else {
+		r_version = 0;
+	}
+
+	rv = lm_convert(ls, r, act->mode, act, r_version);
+	if (rv < 0) {
+		log_error("S %s R %s res_convert lm error %d", ls->name, r->name, rv);
+		return rv;
+	}
+
+	log_debug("S %s R %s res_convert lm done", ls->name, r->name);
+
+	if (lk->mode == LD_LK_EX && act->mode == LD_LK_SH) {
+		r->sh_count = 1;
+	} else if (lk->mode == LD_LK_SH && act->mode == LD_LK_EX) {
+		r->sh_count = 0;
+	} else {
+		/* should not be possible */
+		log_error("S %s R %s res_convert invalid modes %d %d",
+			  ls->name, r->name, lk->mode, act->mode);
+		return -1;
+	}
+
+	r->mode = act->mode;
+	lk->mode = act->mode;
+
+	return 0;
+}
+
+static int res_cancel(struct lockspace *ls, struct resource *r,
+		      struct action *act)
+{
+	struct action *cact;
+
+	/*
+	 * a client can cancel its own non-persistent lock requests,
+	 * when could this happen?
+	 *
+	 * a client can cancel other client's persistent lock requests,
+	 * when could this happen?
+	 */
+
+	if (act->flags & LD_AF_PERSISTENT) {
+		list_for_each_entry(cact, &r->actions, list) {
+			if (!(cact->flags & LD_AF_PERSISTENT))
+				continue;
+			goto do_cancel;
+		}
+	} else {
+		cact = find_action_client(r, act->client_id);
+		if (cact)
+			goto do_cancel;
+	}
+
+	return -ENOENT;
+
+do_cancel:
+	log_debug("S %s R %s res_cancel client %d", ls->name, r->name, cact->client_id);
+	cact->result = -ECANCELED;
+	list_del(&cact->list);
+	add_client_result(cact);
+
+	return -ECANCELED;
+}
+
+/*
+ * lm_unlock() writes new a r_version (from ex)
+ *
+ * The r_version of the vg resource is incremented if
+ * an "update" was received for the vg lock.  The update
+ * contains the new vg seqno from the vg metadata which is
+ * used as the r_version.
+ *
+ * The r_version of the global resource is automatically
+ * incremented when it is unlocked from ex mode.
+ *
+ * r_version is incremented every time a command releases
+ * the global lock from ex.
+ */
+
+/*
+ * persistent locks will not be unlocked for OP_CLOSE/act_close
+ * because act_close->flags does not have the PERSISTENT flag
+ * set, and a persistent lk->client_id is zero, which will not
+ * match the client in act_close->client_id.
+ */
+
+static int res_unlock(struct lockspace *ls, struct resource *r,
+		      struct action *act)
+{
+	struct lock *lk;
+	uint32_t r_version;
+	int rv;
+
+	if (act->flags & LD_AF_PERSISTENT) {
+		lk = find_lock_persistent(r);
+		if (lk)
+			goto do_unlock;
+	} else {
+		lk = find_lock_client(r, act->client_id);
+		if (lk)
+			goto do_unlock;
+	}
+
+	if (act->op != LD_OP_CLOSE)
+		log_error("S %s R %s res_unlock no locks", ls->name, r->name);
+	return -ENOENT;
+
+do_unlock:
+	log_debug("S %s R %s res_unlock %s", ls->name, r->name,
+		  (act->op == LD_OP_CLOSE) ? "from close" : "");
+
+	/* send unlock to lm when last sh lock is unlocked */
+	if (lk->mode == LD_LK_SH) {
+		r->sh_count--;
+		if (r->sh_count > 0)
+			goto rem_lk;
+	}
+
+	if ((r->type == LD_RT_GL) && (r->mode == LD_LK_EX)) {
+		r->version++;
+		lk->version = r->version;
+		r_version = r->version;
+
+		log_debug("S %s R %s res_unlock r_version inc %u", ls->name, r->name, r_version);
+
+	} else if ((r->type == LD_RT_VG) && (r->mode == LD_LK_EX) && (lk->version > r->version)) {
+		r->version = lk->version;
+		r_version = r->version;
+
+		log_debug("S %s R %s res_unlock r_version new %u",
+			  ls->name, r->name, r_version);
+	} else {
+		r_version = 0;
+	}
+
+	rv = lm_unlock(ls, r, act, r_version, 0);
+	if (rv < 0) {
+		/* should never happen, retry? */
+		log_error("S %s R %s res_unlock lm error %d", ls->name, r->name, rv);
+		return rv;
+	}
+
+	log_debug("S %s R %s res_unlock lm done", ls->name, r->name);
+
+rem_lk:
+	list_del(&lk->list);
+	free_lock(lk);
+
+	if (list_empty(&r->locks))
+		r->mode = LD_LK_UN;
+
+	return 0;
+}
+
+static int res_update(struct lockspace *ls, struct resource *r,
+		      struct action *act)
+{
+	struct lock *lk;
+
+	lk = find_lock_client(r, act->client_id);
+	if (!lk) {
+		log_error("S %s R %s res_update client %u lock not found",
+			  ls->name, r->name, act->client_id);
+		return -ENOENT;
+	}
+
+	if (r->mode != LD_LK_EX) {
+		log_error("S %s R %s res_update version on non-ex lock",
+			  ls->name, r->name);
+		return -EINVAL;
+	}
+
+	/* lk version will be written to lm by unlock */
+
+	if (act->flags & LD_AF_NEXT_VERSION)
+		lk->version = r->version + 1;
+	else
+		lk->version = act->version;
+
+	log_debug("S %s R %s res_update lk version to %u", ls->name, r->name, lk->version);
+
+	return 0;
+}
+
+/*
+ * There is nothing to deallocate when freeing a dlm LV, the LV
+ * will simply be unlocked by rem_resource.
+ */
+
+static int free_lv(struct lockspace *ls, struct resource *r)
+{
+	if (ls->lm_type == LD_LM_SANLOCK)
+		return lm_free_lv_sanlock(ls, r);
+	else if (ls->lm_type == LD_LM_DLM)
+		return 0;
+	else
+		return -EINVAL;
+}
+
+/*
+ * NB. we can't do this if sanlock is holding any locks on
+ * the resource; we'd be rewriting the resource from under
+ * sanlock and would confuse or break it badly.  We don't
+ * know what another host is doing, so these must be used
+ * very carefully.
+ */
+
+static int res_able(struct lockspace *ls, struct resource *r,
+		    struct action *act)
+{
+	int rv;
+
+	if (ls->lm_type != LD_LM_SANLOCK) {
+		log_error("enable/disable only applies to sanlock");
+		return -EINVAL;
+	}
+
+	if (r->type != LD_RT_GL) {
+		log_error("enable/disable only applies to global lock");
+		return -EINVAL;
+	}
+
+	if (r->mode != LD_LK_UN) {
+		log_error("enable/disable only allowed on unlocked resource");
+		return -EINVAL;
+	}
+
+	if (act->op == LD_OP_ENABLE && gl_lsname_sanlock[0]) {
+		log_error("disable global lock in %s before enable in %s",
+			  gl_lsname_sanlock, ls->name);
+		return -EINVAL;
+	}
+
+	if ((act->op == LD_OP_DISABLE) && (act->flags & LD_AF_EX_DISABLE)) {
+		rv = lm_ex_disable_gl_sanlock(ls);
+		goto out;
+	}
+
+	rv = lm_able_gl_sanlock(ls, act->op == LD_OP_ENABLE);
+out:
+	return rv;
+}
+
+/*
+ * Go through queued actions, and make lock/unlock calls on the resource
+ * based on the actions and the existing lock state.
+ *
+ * All lock operations sent to the lock manager are non-blocking.
+ * This is because sanlock does not support lock queueing.
+ * Eventually we could enhance this to take advantage of lock
+ * queueing when available (i.e. for the dlm).
+ *
+ * act_close_list: list of CLOSE actions, identifying clients that have
+ * closed/terminated their lvmlockd connection, and whose locks should
+ * be released.  Do not remove these actions from act_close_list.
+ *
+ * retry_out: set to 1 if the lock manager said we should retry,
+ * meaning we should call res_process() again in a short while to retry.
+ */
+
+static void res_process(struct lockspace *ls, struct resource *r,
+			struct list_head *act_close_list, int *retry_out)
+{
+	struct action *act, *safe, *act_close;
+	struct lock *lk;
+	int lm_retry;
+	int rv;
+
+	/*
+	 * handle version updates for ex locks
+	 * (new version will be written by unlock)
+	 */
+
+	list_for_each_entry_safe(act, safe, &r->actions, list) {
+		if (act->op == LD_OP_UPDATE) {
+			rv = res_update(ls, r, act);
+			act->result = rv;
+			list_del(&act->list);
+			add_client_result(act);
+		}
+	}
+
+	/*
+	 * handle explicit unlock actions
+	 */
+
+	list_for_each_entry_safe(act, safe, &r->actions, list) {
+		if ((act->op == LD_OP_LOCK) &&
+		    (act->mode == LD_LK_IV || act->mode == LD_LK_NL)) {
+			act->result = -EINVAL;
+			list_del(&act->list);
+			add_client_result(act);
+		}
+
+		if (act->op == LD_OP_LOCK && act->mode == LD_LK_UN) {
+			rv = res_unlock(ls, r, act);
+
+			if (rv == -ENOENT && (act->flags & LD_AF_UNLOCK_CANCEL))
+				rv = res_cancel(ls, r, act);
+
+			/*
+			 * possible unlock results:
+			 * 0: unlock succeeded
+			 * -ECANCELED: cancel succeeded
+			 * -ENOENT: nothing to unlock or cancel
+			 */
+
+			act->result = rv;
+			list_del(&act->list);
+			add_client_result(act);
+		}
+	}
+
+	/*
+	 * handle implicit unlocks due to client exit,
+	 * also clear any outstanding actions for the client
+	 */
+
+	list_for_each_entry(act_close, act_close_list, list) {
+		res_unlock(ls, r, act_close);
+		res_cancel(ls, r, act_close);
+	}
+
+	/*
+	 * handle freeing a lock for an lv that has been removed
+	 */
+
+	list_for_each_entry_safe(act, safe, &r->actions, list) {
+		if (act->op == LD_OP_FREE && act->rt == LD_RT_LV) {
+			log_debug("S %s R %s free_lv", ls->name, r->name);
+			rv = free_lv(ls, r);
+			act->result = rv;
+			list_del(&act->list);
+			add_client_result(act);
+			goto r_free;
+
+		}
+	}
+
+	/*
+	 * handle enable/disable
+	 */
+
+	list_for_each_entry_safe(act, safe, &r->actions, list) {
+		if (act->op == LD_OP_ENABLE || act->op == LD_OP_DISABLE) {
+			rv = res_able(ls, r, act);
+			act->result = rv;
+			list_del(&act->list);
+			add_client_result(act);
+
+			if (!rv && act->op == LD_OP_DISABLE) {
+				log_debug("S %s R %s free disabled", ls->name, r->name);
+				goto r_free;
+			}
+		}
+	}
+
+	/*
+	 * transient requests on existing transient locks
+	 */
+
+	list_for_each_entry_safe(act, safe, &r->actions, list) {
+		if (act->flags & LD_AF_PERSISTENT)
+			continue;
+
+		lk = find_lock_client(r, act->client_id);
+		if (!lk)
+			continue;
+
+		if (lk->mode != act->mode) {
+			/* convert below */
+			/*
+			act->result = -EEXIST;
+			list_del(&act->list);
+			add_client_result(act);
+			*/
+			continue;
+		} else {
+			/* success */
+			act->result = -EALREADY;
+			list_del(&act->list);
+			add_client_result(act);
+		}
+	}
+
+	/*
+	 * persistent requests on existing persistent locks
+	 *
+	 * persistent locks are not owned by a client, so any
+	 * existing with matching mode satisfies a request.
+	 * only one persistent lock is kept on a resource.
+	 * a single "unowned" persistent lock satisfies
+	 * any/multiple client requests for a persistent lock.
+	 */
+
+	list_for_each_entry_safe(act, safe, &r->actions, list) {
+		if (!(act->flags & LD_AF_PERSISTENT))
+			continue;
+
+		lk = find_lock_persistent(r);
+		if (!lk)
+			continue;
+
+		if (lk->mode != act->mode) {
+			/* convert below */
+			/*
+			act->result = -EEXIST;
+			list_del(&act->list);
+			add_client_result(act);
+			*/
+			continue;
+		} else {
+			/* success */
+			act->result = -EALREADY;
+			list_del(&act->list);
+			add_client_result(act);
+		}
+	}
+
+	/*
+	 * transient requests with existing persistent locks
+	 *
+	 * Just grant the transient request and do not
+	 * keep a record of it.  Assume that the persistent
+	 * lock will not go away while the transient lock
+	 * is needed.
+	 *
+	 * This would be used when an ex, persistent lv lock
+	 * exists from activation, and then something like
+	 * lvextend asks for a transient ex lock to change
+	 * the lv.  The lv could not be unlocked by deactivation
+	 * while the lvextend was running.
+	 *
+	 * The logic here for mixing T/P locks is not general
+	 * support; there are a number of cases where it will
+	 * not work: updating version number (lv locks have
+	 * none), ex locks from multiple clients will not
+	 * conflict, explicit un of the transient lock will fail.
+	 */
+
+	list_for_each_entry_safe(act, safe, &r->actions, list) {
+		if (act->flags & LD_AF_PERSISTENT)
+			continue;
+
+		lk = find_lock_persistent(r);
+		if (!lk)
+			continue;
+
+		if ((lk->mode == LD_LK_EX) ||
+		    (lk->mode == LD_LK_SH && act->mode == LD_LK_SH)) {
+			act->result = 0;
+			list_del(&act->list);
+			add_client_result(act);
+		} else {
+			/* persistent lock is sh, transient request is ex */
+			/* FIXME: can we remove this case? do a convert here? */
+			log_debug("res_process %s existing persistent lock new transient", r->name);
+			act->result = -EEXIST;
+			list_del(&act->list);
+			add_client_result(act);
+		}
+	}
+
+	/*
+	 * persistent requests with existing transient locks
+	 *
+	 * If a client requests a P (persistent) lock for a T (transient)
+	 * lock it already holds, we can just change T to P.  Fail if the
+	 * same happens for locks from different clients.  Changing
+	 * another client's lock from T to P may cause problems
+	 * if that client tries to unlock or update version.
+	 *
+	 * I don't think this P/T combination will be used.
+	 * It might be used if a command was able to take a P
+	 * vg lock, in which case the T vg lock would already
+	 * be held for reading.  If the T lock was sh, it would
+	 * be converted to P ex.  If the T/P modes matched, the
+	 * lock could just be changed from T to P.
+	 */
+
+	list_for_each_entry_safe(act, safe, &r->actions, list) {
+		if (!(act->flags & LD_AF_PERSISTENT))
+			continue;
+
+		lk = find_lock_client(r, act->client_id);
+		if (!lk)
+			continue;
+
+		if (lk->mode != act->mode) {
+			/* FIXME: convert and change to persistent? */
+			log_debug("res_process %s existing transient lock new persistent", r->name);
+			act->result = -EEXIST;
+			list_del(&act->list);
+			add_client_result(act);
+		} else {
+			lk->flags |= LD_LF_PERSISTENT;
+			lk->client_id = 0;
+			act->result = 0;
+			list_del(&act->list);
+			add_client_result(act);
+		}
+	}
+
+	/*
+	 * convert mode of existing locks
+	 */
+
+	list_for_each_entry_safe(act, safe, &r->actions, list) {
+		if (act->flags & LD_AF_PERSISTENT)
+			lk = find_lock_persistent(r);
+		else
+			lk = find_lock_client(r, act->client_id);
+		if (!lk)
+			continue;
+
+		if (lk->mode == act->mode) {
+			/* should never happen, should be found above */
+			log_error("convert same mode");
+			continue;
+		}
+
+		/* convert fails immediately, no EAGAIN retry */
+		rv = res_convert(ls, r, lk, act);
+		act->result = rv;
+		list_del(&act->list);
+		add_client_result(act);
+	}
+
+	/*
+	 * Cases above are all requests addressed by existing locks.
+	 * Below handles the rest.  Transient and persistent are
+	 * handled the same, except
+	 * - if mode of existing lock is incompat with requested,
+	 *   leave the act on r->actions
+	 * - if r mode is EX, any lock action is blocked, just quit
+	 *
+	 * Retry a lock request that fails due to a lock conflict (-EAGAIN):
+	 * if we have not exceeded max retries and lm sets lm_retry (sanlock
+	 * transient conflicts from shared lock implementation), or r type
+	 * is gl or vg (transient real conflicts we want to hide from command).
+	 * lv lock conflicts won't be transient so don't retry them.
+	 */
+
+
+	if (r->mode == LD_LK_EX)
+		return;
+
+	/*
+	 * r mode is SH or UN, pass lock-sh actions to lm
+	 */
+
+	list_for_each_entry_safe(act, safe, &r->actions, list) {
+		/* grant in order, so break here */
+		if (act->op == LD_OP_LOCK && act->mode == LD_LK_EX)
+			break;
+
+		if (act->op == LD_OP_LOCK && act->mode == LD_LK_SH) {
+			lm_retry = 0;
+
+			rv = res_lock(ls, r, act, &lm_retry);
+			if ((rv == -EAGAIN) &&
+			    (act->retries <= act->max_retries) &&
+			    (lm_retry || (r->type != LD_RT_LV))) {
+				/* leave act on list */
+				log_debug("S %s R %s res_lock EAGAIN retry", ls->name, r->name);
+				act->retries++;
+				*retry_out = 1;
+			} else {
+				act->result = rv;
+				list_del(&act->list);
+				add_client_result(act);
+			}
+			if (rv == -EUNATCH)
+				goto r_free;
+		}
+	}
+
+	/*
+	 * r mode is SH, any ex lock action is blocked, just quit
+	 */
+
+	if (r->mode == LD_LK_SH)
+		return;
+
+	/*
+	 * r mode is UN, pass lock-ex action to lm
+	 */
+
+	list_for_each_entry_safe(act, safe, &r->actions, list) {
+		if (act->op == LD_OP_LOCK && act->mode == LD_LK_EX) {
+			lm_retry = 0;
+
+			rv = res_lock(ls, r, act, &lm_retry);
+			if ((rv == -EAGAIN) &&
+			    (act->retries <= act->max_retries) &&
+			    (lm_retry || (r->type != LD_RT_LV))) {
+				/* leave act on list */
+				log_debug("S %s R %s res_lock EAGAIN retry", ls->name, r->name);
+				act->retries++;
+				*retry_out = 1;
+			} else {
+				act->result = rv;
+				list_del(&act->list);
+				add_client_result(act);
+			}
+			if (rv == -EUNATCH)
+				goto r_free;
+			break;
+		}
+	}
+
+	return;
+
+r_free:
+	/* For the EUNATCH case it may be possible there are queued actions? */
+	list_for_each_entry_safe(act, safe, &r->actions, list) {
+		log_error("S %s R %s res_process r_free cancel %s client %d",
+			  ls->name, r->name, op_str(act->op), act->client_id);
+		act->result = -ECANCELED;
+		list_del(&act->list);
+		add_client_result(act);
+	}
+	log_debug("S %s R %s res_process free", ls->name, r->name);
+	lm_rem_resource(ls, r);
+	list_del(&r->list);
+	free_resource(r);
+}
+
+#define LOCKS_EXIST_ANY 1
+#define LOCKS_EXIST_GL  2
+#define LOCKS_EXIST_VG  3
+#define LOCKS_EXIST_LV  4
+
+static int for_each_lock(struct lockspace *ls, int locks_do)
+{
+	struct resource *r;
+	struct lock *lk;
+
+	list_for_each_entry(r, &ls->resources, list) {
+		list_for_each_entry(lk, &r->locks, list) {
+			if (locks_do == LOCKS_EXIST_ANY)
+				return 1;
+
+			if (locks_do == LOCKS_EXIST_GL && r->type == LD_RT_GL)
+				return 1;
+
+			if (locks_do == LOCKS_EXIST_VG && r->type == LD_RT_VG)
+				return 1;
+
+			if (locks_do == LOCKS_EXIST_LV && r->type == LD_RT_LV)
+				return 1;
+		}
+	}
+
+	return 0;
+}
+
+static int clear_locks(struct lockspace *ls, int free_vg)
+{
+	struct resource *r, *r_safe;
+	struct lock *lk, *lk_safe;
+	struct action *act, *act_safe;
+	uint32_t lk_version;
+	uint32_t r_version;
+	int lk_count = 0;
+	int rv;
+
+	list_for_each_entry_safe(r, r_safe, &ls->resources, list) {
+		lk_version = 0;
+
+		list_for_each_entry_safe(lk, lk_safe, &r->locks, list) {
+			lk_count++;
+
+			if (lk->flags & LD_LF_PERSISTENT)
+				log_error("S %s R %s clear lock persistent", ls->name, r->name);
+			else
+				log_error("S %s R %s clear lock client %d", ls->name, r->name, lk->client_id);
+
+			if (lk->version > lk_version)
+				lk_version = lk->version;
+
+			list_del(&lk->list);
+			free_lock(lk);
+		}
+
+		if (r->mode == LD_LK_UN)
+			goto r_free;
+
+		if ((r->type == LD_RT_GL) && (r->mode == LD_LK_EX)) {
+			r->version++;
+			r_version = r->version;
+			log_debug("S %s R %s clear_locks r_version inc %u",
+				  ls->name, r->name, r_version);
+
+		} else if ((r->type == LD_RT_VG) && (r->mode == LD_LK_EX) && (lk_version > r->version)) {
+			r->version = lk_version;
+			r_version = r->version;
+			log_debug("S %s R %s clear_locks r_version new %u",
+				  ls->name, r->name, r_version);
+
+		} else {
+			r_version = 0;
+		}
+
+		rv = lm_unlock(ls, r, NULL, r_version, free_vg ? LMUF_FREE_VG : 0);
+		if (rv < 0) {
+			/* should never happen */
+			log_error("S %s R %s clear_locks free %d lm unlock error %d",
+				  ls->name, r->name, free_vg, rv);
+		}
+
+		list_for_each_entry_safe(act, act_safe, &r->actions, list) {
+			log_error("S %s R %s clear_locks cancel %s client %d",
+				  ls->name, r->name, op_str(act->op), act->client_id);
+			act->result = -ECANCELED;
+			list_del(&act->list);
+			add_client_result(act);
+		}
+ r_free:
+		log_debug("S %s R %s free", ls->name, r->name);
+		lm_rem_resource(ls, r);
+		list_del(&r->list);
+		free_resource(r);
+	}
+
+	return lk_count;
+}
+
+/*
+ * find and return the resource that is referenced by the action
+ * - there is a single gl resource per lockspace
+ * - there is a single vg resource per lockspace
+ * - there can be many lv resources per lockspace, compare names
+ */
+
+static struct resource *find_resource_act(struct lockspace *ls,
+					  struct action *act,
+					  int nocreate)
+{
+	struct resource *r;
+
+	list_for_each_entry(r, &ls->resources, list) {
+		if (r->type != act->rt)
+			continue;
+
+		if (r->type == LD_RT_GL && act->rt == LD_RT_GL)
+			return r;
+
+		if (r->type == LD_RT_VG && act->rt == LD_RT_VG)
+			return r;
+
+		if (r->type == LD_RT_LV && act->rt == LD_RT_LV &&
+		    !strcmp(r->name, act->lv_uuid))
+			return r;
+	}
+
+	if (nocreate)
+		return NULL;
+
+	if (!(r = alloc_resource()))
+		return NULL;
+
+	r->type = act->rt;
+
+	r->mode = LD_LK_UN;
+
+	if (r->type == LD_RT_GL)
+		strncpy(r->name, R_NAME_GL, MAX_NAME);
+	else if (r->type == LD_RT_VG)
+		strncpy(r->name, R_NAME_VG, MAX_NAME);
+	else if (r->type == LD_RT_LV)
+		strncpy(r->name, act->lv_uuid, MAX_NAME);
+
+	list_add_tail(&r->list, &ls->resources);
+
+	return r;
+}
+
+static void free_ls_resources(struct lockspace *ls)
+{
+	struct resource *r, *r_safe;
+
+	list_for_each_entry_safe(r, r_safe, &ls->resources, list) {
+		lm_rem_resource(ls, r);
+		list_del(&r->list);
+		free_resource(r);
+	}
+}
+
+/*
+ * Process actions queued for this lockspace by
+ * client_recv_action / add_lock_action.
+ *
+ * The lockspace_thread can touch its own ls struct without holding
+ * lockspaces_mutex until it sets ls->thread_done, after which it
+ * cannot touch ls without holding lockspaces_mutex.
+ */
+
+#define LOCK_RETRY_MS 1000 /* milliseconds to delay between retry */
+
+static void *lockspace_thread_main(void *arg_in)
+{
+	struct lockspace *ls = arg_in;
+	struct resource *r, *r2;
+	struct action *add_act, *act, *safe;
+	struct list_head tmp_act;
+	struct list_head act_close;
+	int free_vg = 0;
+	int error = 0;
+	int adopt_flag = 0;
+	int wait_flag = 0;
+	int retry;
+	int rv;
+
+	INIT_LIST_HEAD(&act_close);
+
+	/* first action may be client add */
+	pthread_mutex_lock(&ls->mutex);
+	act = NULL;
+	add_act = NULL;
+	if (!list_empty(&ls->actions)) {
+		act = list_first_entry(&ls->actions, struct action, list);
+		if (act->op == LD_OP_START) {
+			add_act = act;
+			list_del(&add_act->list);
+
+			if (add_act->flags & LD_AF_WAIT)
+				wait_flag = 1;
+			if (add_act->flags & LD_AF_ADOPT)
+				adopt_flag = 1;
+		}
+	}
+	pthread_mutex_unlock(&ls->mutex);
+
+	log_debug("S %s lm_add_lockspace %s wait %d adopt %d",
+		  ls->name, lm_str(ls->lm_type), wait_flag, adopt_flag);
+
+	/*
+	 * The prepare step does not wait for anything and is quick;
+	 * it tells us if the parameters are valid and the lm is running.
+	 */
+	error = lm_prepare_lockspace(ls, add_act);
+
+	if (add_act && (!wait_flag || error)) {
+		/* send initial join result back to client */
+		add_act->result = error;
+		add_client_result(add_act);
+		add_act = NULL;
+	}
+
+	/*
+	 * The actual lockspace join can take a while.
+	 */
+	if (!error) {
+		error = lm_add_lockspace(ls, add_act, adopt_flag);
+
+		log_debug("S %s lm_add_lockspace done %d", ls->name, error);
+
+		if (ls->sanlock_gl_enabled && gl_lsname_sanlock[0] &&
+		    strcmp(ls->name, gl_lsname_sanlock))
+			sanlock_gl_dup = 1;
+
+		if (add_act) {
+			/* send final join result back to client */
+			add_act->result = error;
+			add_client_result(add_act);
+		}
+	}
+
+	pthread_mutex_lock(&ls->mutex);
+	if (error) {
+		ls->thread_stop = 1;
+		ls->create_fail = 1;
+	} else {
+		ls->create_done = 1;
+	}
+	pthread_mutex_unlock(&ls->mutex);
+
+	if (error)
+		goto out_act;
+
+	while (1) {
+		pthread_mutex_lock(&ls->mutex);
+		while (!ls->thread_work) {
+			if (ls->thread_stop) {
+				pthread_mutex_unlock(&ls->mutex);
+				goto out_rem;
+			}
+			pthread_cond_wait(&ls->cond, &ls->mutex);
+		}
+
+		/*
+		 * Process all the actions queued for this lockspace.
+		 * The client thread queues actions on ls->actions.
+		 *
+		 * Here, take all the actions off of ls->actions, and:
+		 *
+		 * - For lock operations, move the act to r->actions.
+		 *   These lock actions/operations processed by res_process().
+		 *
+		 * - For non-lock operations, e.g. related to managing
+		 *   the lockspace, process them in this loop.
+		 */
+
+		while (1) {
+			if (list_empty(&ls->actions)) {
+				ls->thread_work = 0;
+				break;
+			}
+
+			act = list_first_entry(&ls->actions, struct action, list);
+
+			if (sanlock_gl_dup && ls->sanlock_gl_enabled)
+				act->flags |= LD_AF_DUP_GL_LS;
+
+			if (act->op == LD_OP_STOP) {
+				ls->thread_work = 0;
+				break;
+			}
+
+			if (act->op == LD_OP_FREE && act->rt == LD_RT_VG) {
+				/* vgremove */
+				log_debug("S %s checking for lockspace hosts", ls->name);
+				rv = lm_hosts(ls, 1);
+				if (rv) {
+					/*
+					 * Checking for hosts here in addition to after the
+					 * main loop allows vgremove to fail and be rerun
+					 * after the ls is stopped on other hosts.
+					 */
+					log_error("S %s lockspace hosts %d", ls->name, rv);
+					list_del(&act->list);
+					act->result = -EBUSY;
+					add_client_result(act);
+					continue;
+				}
+				ls->thread_work = 0;
+				ls->thread_stop = 1;
+				free_vg = 1;
+				break;
+			}
+
+			if (act->op == LD_OP_RENAME_BEFORE && act->rt == LD_RT_VG) {
+				/* vgrename */
+				log_debug("S %s checking for lockspace hosts", ls->name);
+				rv = lm_hosts(ls, 1);
+				if (rv) {
+					log_error("S %s lockspace hosts %d", ls->name, rv);
+					list_del(&act->list);
+					act->result = -EBUSY;
+					add_client_result(act);
+					continue;
+				}
+				ls->thread_work = 0;
+				ls->thread_stop = 1;
+				/* Do we want to check hosts again below like vgremove? */
+				break;
+			}
+
+			if (act->op == LD_OP_FIND_FREE_LOCK && act->rt == LD_RT_VG) {
+				uint64_t free_offset = 0;
+				log_debug("S %s find free lock", ls->name);
+				rv = lm_find_free_lock(ls, &free_offset);
+				log_debug("S %s find free lock %d offset %llu",
+					  ls->name, rv, (unsigned long long)free_offset);
+				ls->free_lock_offset = free_offset;
+				list_del(&act->list);
+				act->result = rv;
+				add_client_result(act);
+				continue;
+			}
+
+			list_del(&act->list);
+
+			/* applies to all resources */
+			if (act->op == LD_OP_CLOSE) {
+				list_add(&act->list, &act_close);
+				continue;
+			}
+
+			/*
+			 * All the other op's are for locking.
+			 * Find the specific resource that the lock op is for,
+			 * and add the act to the resource's list of lock ops.
+			 *
+			 * (This creates a new resource if the one named in
+			 * the act is not found.)
+			 */
+
+			r = find_resource_act(ls, act, (act->op == LD_OP_FREE) ? 1 : 0);
+			if (!r) {
+				act->result = (act->op == LD_OP_FREE) ? -ENOENT : -ENOMEM;
+				add_client_result(act);
+				continue;
+			}
+
+			list_add_tail(&act->list, &r->actions);
+
+			log_debug("S %s R %s action %s %s", ls->name, r->name,
+				  op_str(act->op), mode_str(act->mode));
+		}
+		pthread_mutex_unlock(&ls->mutex);
+
+		/*
+		 * Process the lock operations that have been queued for each
+		 * resource.
+		 */
+
+		retry = 0;
+
+		list_for_each_entry_safe(r, r2, &ls->resources, list)
+			res_process(ls, r, &act_close, &retry);
+
+		list_for_each_entry_safe(act, safe, &act_close, list) {
+			list_del(&act->list);
+			free_action(act);
+		}
+
+		if (retry) {
+			ls->thread_work = 1;
+			usleep(LOCK_RETRY_MS * 1000);
+		}
+	}
+
+out_rem:
+	log_debug("S %s stopping", ls->name);
+
+	/*
+	 * For sanlock, we need to unlock any existing locks
+	 * before removing the lockspace, otherwise the sanlock
+	 * daemon will kill us when the lockspace goes away.
+	 * For dlm, we leave with force, so all locks will
+	 * automatically be dropped when we leave the lockspace,
+	 * so unlocking all before leaving could be skipped.
+	 *
+	 * Blindly dropping all existing locks must only be
+	 * allowed in emergency/force situations, otherwise it's
+	 * obviously dangerous, since the lock holders are still
+	 * operating under the assumption that they hold the lock.
+	 *
+	 * For vgremove of a sanlock vg, the vg lock will be held,
+	 * and possibly the gl lock if this vg holds the gl.
+	 * sanlock vgremove wants to unlock-rename these locks.
+	 */
+
+	log_debug("S %s clearing locks", ls->name);
+
+	rv = clear_locks(ls, free_vg);
+
+	/*
+	 * Tell any other hosts in the lockspace to leave it
+	 * before we remove it (for vgremove).  We do this
+	 * before leaving the lockspace ourself because we
+	 * need to be in the lockspace to see others.
+	 */
+
+	if (free_vg) {
+		log_debug("S %s checking for lockspace hosts", ls->name);
+		rv = lm_hosts(ls, 1);
+		if (rv)
+			log_error("S %s other lockspace hosts %d", ls->name, rv);
+	}
+
+	/*
+	 * Leave the lockspace.
+	 */
+
+	rv = lm_rem_lockspace(ls, NULL, free_vg);
+
+	log_debug("S %s rem_lockspace done %d", ls->name, rv);
+
+out_act:
+	/*
+	 * Move remaining actions to results; this will usually (always?)
+	 * be only the stop action.
+	 */
+	INIT_LIST_HEAD(&tmp_act);
+
+	pthread_mutex_lock(&ls->mutex);
+	list_for_each_entry_safe(act, safe, &ls->actions, list) {
+		if (act->op == LD_OP_FREE)
+			act->result = 0;
+		else if (act->op == LD_OP_STOP)
+			act->result = 0;
+		else if (act->op == LD_OP_RENAME_BEFORE)
+			act->result = 0;
+		else
+			act->result = -ENOLS;
+		list_del(&act->list);
+		list_add_tail(&act->list, &tmp_act);
+	}
+	pthread_mutex_unlock(&ls->mutex);
+
+	pthread_mutex_lock(&client_mutex);
+	list_for_each_entry_safe(act, safe, &tmp_act, list) {
+		list_del(&act->list);
+		list_add_tail(&act->list, &client_results);
+	}
+	pthread_cond_signal(&client_cond);
+	pthread_mutex_unlock(&client_mutex);
+
+	pthread_mutex_lock(&lockspaces_mutex);
+	ls->thread_done = 1;
+	pthread_mutex_unlock(&lockspaces_mutex);
+
+	/*
+	 * worker_thread will join this thread, and move the
+	 * ls struct from lockspaces list to lockspaces_inactive.
+	 */
+	pthread_mutex_lock(&worker_mutex);
+	worker_wake = 1;
+	pthread_cond_signal(&worker_cond);
+	pthread_mutex_unlock(&worker_mutex);
+
+	return NULL;
+}
+
+int lockspaces_empty(void)
+{
+	int rv;
+	pthread_mutex_lock(&lockspaces_mutex);
+	rv = list_empty(&lockspaces);
+	pthread_mutex_unlock(&lockspaces_mutex);
+	return rv;
+}
+
+/*
+ * lockspaces_mutex is locked
+ *
+ * When duplicate sanlock global locks have been seen,
+ * this function has a secondary job of counting the
+ * number of lockspaces that exist with the gl enabled,
+ * with the side effect of setting sanlock_gl_dup back to
+ * zero when the duplicates have been removed/disabled.
+ */
+
+static struct lockspace *find_lockspace_name(char *ls_name)
+{
+	struct lockspace *ls_found = NULL;
+	struct lockspace *ls;
+	int gl_count = 0;
+
+	list_for_each_entry(ls, &lockspaces, list) {
+		if (!strcmp(ls->name, ls_name))
+			ls_found = ls;
+
+		if (!sanlock_gl_dup && ls_found)
+			return ls_found;
+
+		if (sanlock_gl_dup && ls->sanlock_gl_enabled)
+			gl_count++;
+	}
+
+	/* this is the side effect we want from this function */
+	if (sanlock_gl_dup && gl_count < 2)
+		sanlock_gl_dup = 0;
+
+	return ls_found;
+}
+
+/*
+ * If lvm_<vg_name> is longer than max lockspace name (64) we just ignore the
+ * extra characters.  For sanlock vgs, the name is shortened further to 48 in
+ * the sanlock code.
+ */
+
+static int vg_ls_name(const char *vg_name, char *ls_name)
+{
+	if (strlen(vg_name) + 4 > MAX_NAME) {
+		log_error("vg name too long %s", vg_name);
+		return -1;
+	}
+
+	snprintf(ls_name, MAX_NAME, "%s%s", LVM_LS_PREFIX, vg_name);
+	return 0;
+}
+
+/* FIXME: add mutex for gl_lsname_ ? */
+
+static int gl_ls_name(char *ls_name)
+{
+	if (gl_use_dlm)
+		memcpy(ls_name, gl_lsname_dlm, MAX_NAME);
+	else if (gl_use_sanlock)
+		memcpy(ls_name, gl_lsname_sanlock, MAX_NAME);
+	else {
+		log_error("gl_ls_name: global lockspace type unknown");
+		return -1;
+	}
+	return 0;
+}
+
+/*
+ * When this function returns an error, the caller needs to deal
+ * with act (in the cases where act exists).
+ */
+
+static int add_lockspace_thread(const char *ls_name,
+				const char *vg_name,
+				const char *vg_uuid,
+				int lm_type, const char *vg_args,
+				struct action *act)
+{
+	struct lockspace *ls, *ls2;
+	struct resource *r;
+	uint32_t version = 0;
+	int rv;
+
+	if (act)
+		version = act->version;
+
+	log_debug("add_lockspace_thread %s %s version %u",
+		  lm_str(lm_type), ls_name, version);
+
+	if (!(ls = alloc_lockspace()))
+		return -ENOMEM;
+
+	strncpy(ls->name, ls_name, MAX_NAME);
+	ls->lm_type = lm_type;
+
+	if (act)
+		ls->start_client_id = act->client_id;
+
+	if (vg_uuid)
+		strncpy(ls->vg_uuid, vg_uuid, 64);
+
+	if (vg_name)
+		strncpy(ls->vg_name, vg_name, MAX_NAME);
+
+	if (vg_args)
+		strncpy(ls->vg_args, vg_args, MAX_ARGS);
+
+	if (act)
+		ls->host_id = act->host_id;
+
+	if (!(r = alloc_resource())) {
+		free(ls);
+		return -ENOMEM;
+	}
+
+	r->type = LD_RT_VG;
+	r->mode = LD_LK_UN;
+	r->version = version;
+	strncpy(r->name, R_NAME_VG, MAX_NAME);
+	list_add_tail(&r->list, &ls->resources);
+
+	pthread_mutex_lock(&lockspaces_mutex);
+	ls2 = find_lockspace_name(ls->name);
+	if (ls2) {
+		if (ls2->thread_stop)
+			rv = -EAGAIN;
+		else
+			rv = -EEXIST;
+		pthread_mutex_unlock(&lockspaces_mutex);
+		free_resource(r);
+		free(ls);
+		return rv;
+	}
+
+	/*
+	 * act will be null when this lockspace is added automatically/internally
+	 * and not by an explicit client action that wants a result.
+	 */
+	if (act)
+		list_add(&act->list, &ls->actions);
+
+	clear_lockspace_inactive(ls->name);
+
+	list_add_tail(&ls->list, &lockspaces);
+	pthread_mutex_unlock(&lockspaces_mutex);
+
+	rv = pthread_create(&ls->thread, NULL, lockspace_thread_main, ls);
+	if (rv < 0) {
+		pthread_mutex_lock(&lockspaces_mutex);
+		list_del(&ls->list);
+		pthread_mutex_unlock(&lockspaces_mutex);
+		free_resource(r);
+		free(ls);
+		return rv;
+	}
+
+	return 0;
+}
+
+/*
+ * There is no add_sanlock_global_lockspace or
+ * rem_sanlock_global_lockspace because with sanlock,
+ * the global lockspace is one of the vg lockspaces.
+ */
+
+static int add_dlm_global_lockspace(struct action *act)
+{
+	int rv;
+
+	if (gl_running_dlm)
+		return -EEXIST;
+
+	gl_running_dlm = 1;
+
+	/* Keep track of whether we automatically added
+	   the global ls, so we know to automatically
+	   remove it. */
+
+	if (act)
+		gl_auto_dlm = 0;
+	else
+		gl_auto_dlm = 1;
+
+	/*
+	 * There's a short period after which a previous gl lockspace thread
+	 * has set gl_running_dlm = 0, but before its ls struct has been
+	 * deleted, during which this add_lockspace_thread() can fail with
+	 * -EAGAIN.
+	 */
+
+	rv = add_lockspace_thread(gl_lsname_dlm, NULL, NULL, LD_LM_DLM, NULL, act);
+
+	if (rv < 0) {
+		log_error("add_dlm_global_lockspace add_lockspace_thread %d", rv);
+		gl_running_dlm = 0;
+		gl_auto_dlm = 0;
+	}
+
+	return rv;
+}
+
+/*
+ * If dlm gl lockspace is the only one left, then stop it.
+ * This is not used for an explicit rem_lockspace action from
+ * the client, only for auto remove.
+ */
+
+static int rem_dlm_global_lockspace(void)
+{
+	struct lockspace *ls, *ls_gl = NULL;
+	int others = 0;
+	int rv = 0;
+
+	pthread_mutex_lock(&lockspaces_mutex);
+	list_for_each_entry(ls, &lockspaces, list) {
+		if (!strcmp(ls->name, gl_lsname_dlm)) {
+			ls_gl = ls;
+			continue;
+		}
+		if (ls->thread_stop)
+			continue;
+		others++;
+		break;
+	}
+
+	if (others) {
+		rv = -EAGAIN;
+		goto out;
+	}
+
+	if (!ls_gl) {
+		rv = -ENOENT;
+		goto out;
+	}
+
+	ls = ls_gl;
+	pthread_mutex_lock(&ls->mutex);
+	ls->thread_stop = 1;
+	ls->thread_work = 1;
+	pthread_cond_signal(&ls->cond);
+	pthread_mutex_unlock(&ls->mutex);
+	rv = 0;
+out:
+	pthread_mutex_unlock(&lockspaces_mutex);
+	return rv;
+}
+
+/*
+ * When the first dlm lockspace is added for a vg,
+ * automatically add a separate dlm lockspace for the
+ * global lock if it hasn't been done explicitly.
+ * This is to make the dlm global lockspace work similarly to
+ * the sanlock global lockspace, which is "automatic" by
+ * nature of being one of the vg lockspaces.
+ *
+ * For sanlock, a separate lockspace is not used for
+ * the global lock, but the gl lock lives in a vg
+ * lockspace, (although it's recommended to create a
+ * special vg dedicated to holding the gl).
+ *
+ * N.B. for dlm, if this is an add+WAIT action for a vg
+ * lockspace, and this triggered the automatic addition
+ * of the global lockspace, then the action may complete
+ * for the vg ls add, while the gl ls add is still in
+ * progress.  If the caller wants to ensure that the
+ * gl ls add is complete, they should explicitly add+WAIT
+ * the gl ls.
+ *
+ * If this function returns and error, the caller
+ * will queue the act with that error for the client.
+ */
+
+static int add_lockspace(struct action *act)
+{
+	char ls_name[MAX_NAME+1];
+	int rv;
+
+	memset(ls_name, 0, sizeof(ls_name));
+
+	if (act->rt == LD_RT_GL) {
+		if (gl_use_dlm) {
+			rv = add_dlm_global_lockspace(act);
+			return rv;
+		} else {
+			return -EINVAL;
+		}
+	}
+
+	if (act->rt == LD_RT_VG) {
+		if (gl_use_dlm) {
+			rv = add_dlm_global_lockspace(NULL);
+			if (rv < 0 && rv != -EEXIST)
+				return rv;
+		}
+
+		vg_ls_name(act->vg_name, ls_name);
+
+		rv = add_lockspace_thread(ls_name, act->vg_name, act->vg_uuid,
+					  act->lm_type, act->vg_args,
+					  act);
+
+		if (rv)
+			log_error("add_lockspace %s add_lockspace_thread %d", ls_name, rv);
+		return rv;
+	}
+
+	log_error("add_lockspace bad type %d", act->rt);
+	return -1;
+}
+
+/*
+ * vgchange --lock-stop vgname will lock the vg ex, then send a stop,
+ * so we exect to find the ex vg lock held here, and will automatically
+ * unlock it when stopping.
+ *
+ * Should we attempt to stop the lockspace containing the gl last?
+ */
+
+static int rem_lockspace(struct action *act)
+{
+	struct lockspace *ls;
+	char ls_name[MAX_NAME+1];
+	int force = act->flags & LD_AF_FORCE;
+	int rt = act->rt;
+
+	if (act->rt == LD_RT_GL && act->lm_type != LD_LM_DLM)
+		return -EINVAL;
+
+	memset(ls_name, 0, sizeof(ls_name));
+
+	if (act->rt == LD_RT_GL)
+		gl_ls_name(ls_name);
+	else
+		vg_ls_name(act->vg_name, ls_name);
+
+	pthread_mutex_lock(&lockspaces_mutex);
+	ls = find_lockspace_name(ls_name);
+	if (!ls) {
+		pthread_mutex_unlock(&lockspaces_mutex);
+		return -ENOLS;
+	}
+
+	pthread_mutex_lock(&ls->mutex);
+	if (ls->thread_stop) {
+		pthread_mutex_unlock(&ls->mutex);
+		pthread_mutex_unlock(&lockspaces_mutex);
+		return -ESTALE;
+	}
+
+	if (!force && for_each_lock(ls, LOCKS_EXIST_LV)) {
+		pthread_mutex_unlock(&ls->mutex);
+		pthread_mutex_unlock(&lockspaces_mutex);
+		return -EBUSY;
+	}
+	ls->thread_work = 1;
+	ls->thread_stop = 1;
+	if (act)
+		list_add_tail(&act->list, &ls->actions);
+	pthread_cond_signal(&ls->cond);
+	pthread_mutex_unlock(&ls->mutex);
+	pthread_mutex_unlock(&lockspaces_mutex);
+
+	/*
+	 * If the dlm global lockspace was automatically added when
+	 * the first dlm vg lockspace was added, then reverse that
+	 * by automatically removing the dlm global lockspace when
+	 * the last dlm vg lockspace is removed.
+	 */
+
+	if (rt == LD_RT_VG && gl_use_dlm && gl_auto_dlm)
+		rem_dlm_global_lockspace();
+
+	return 0;
+}
+
+/*
+ * count how many lockspaces started by this client are still starting;
+ * the client will use this to wait for all its start operations to finish
+ * (START_WAIT).
+ */
+
+static int count_lockspace_starting(uint32_t client_id)
+{
+	struct lockspace *ls;
+	int count = 0;
+	int done = 0;
+	int fail = 0;
+
+	pthread_mutex_lock(&lockspaces_mutex);
+	list_for_each_entry(ls, &lockspaces, list) {
+		if (ls->start_client_id != client_id)
+			continue;
+
+		if (!ls->create_done && !ls->create_fail) {
+			count++;
+			continue;
+		}
+
+		if (ls->create_done)
+			done++;
+		if (ls->create_fail)
+			fail++;
+	}
+	pthread_mutex_unlock(&lockspaces_mutex);
+
+	log_debug("count_lockspace_starting client %u count %d done %d fail %d",
+		  client_id, count, done, fail);
+
+	return count;
+}
+
+/* lockspaces_mutex is held */
+static struct lockspace *find_lockspace_inactive(char *ls_name)
+{
+	struct lockspace *ls;
+
+	list_for_each_entry(ls, &lockspaces_inactive, list) {
+		if (!strcmp(ls->name, ls_name))
+			return ls;
+	}
+
+	return NULL;
+}
+
+/* lockspaces_mutex is held */
+static int clear_lockspace_inactive(char *ls_name)
+{
+	struct lockspace *ls;
+
+	ls = find_lockspace_inactive(ls_name);
+	if (ls) {
+		list_del(&ls->list);
+		free(ls);
+		return 1;
+	}
+
+	return 0;
+}
+
+static int forget_lockspace_inactive(char *vg_name)
+{
+	char ls_name[MAX_NAME+1];
+	int found;
+
+	memset(ls_name, 0, sizeof(ls_name));
+	vg_ls_name(vg_name, ls_name);
+
+	log_debug("forget_lockspace_inactive %s", ls_name);
+
+	pthread_mutex_lock(&lockspaces_mutex);
+	found = clear_lockspace_inactive(ls_name);
+	pthread_mutex_unlock(&lockspaces_mutex);
+
+	if (found)
+		return 0;
+	return -ENOENT;
+}
+
+static void free_lockspaces_inactive(void)
+{
+	struct lockspace *ls, *safe;
+
+	pthread_mutex_lock(&lockspaces_mutex);
+	list_for_each_entry_safe(ls, safe, &lockspaces_inactive, list) {
+		list_del(&ls->list);
+		free(ls);
+	}
+	pthread_mutex_unlock(&lockspaces_mutex);
+}
+
+/*
+ * Loop through all lockspaces, and:
+ * - if do_stop is set, stop any that are not stopped
+ * - if do_free is set, join any that are done stopping (and free ls)
+ *
+ * do_stop will not stop an ls with lv locks unless force is set.
+ *
+ * This function does not block or wait for anything.
+ *
+ * do_stop (no do_free):
+ * returns count of lockspaces that need stop (have locks and no force)
+ *
+ * do_free (no do_stop):
+ * returns count of lockspaces that are stopped and need freeing
+ *
+ * do_stop and do_free:
+ * returns sum of the previous two
+ */
+
+static int for_each_lockspace(int do_stop, int do_free, int do_force)
+{
+	struct lockspace *ls, *safe;
+	int need_stop = 0;
+	int need_free = 0;
+	int stop_count = 0;
+	int free_count = 0;
+	int done;
+	int stop;
+
+	pthread_mutex_lock(&lockspaces_mutex);
+
+	if (do_stop) {
+		list_for_each_entry(ls, &lockspaces, list) {
+
+			pthread_mutex_lock(&ls->mutex);
+			if (ls->thread_stop) {
+				pthread_mutex_unlock(&ls->mutex);
+				continue;
+			}
+
+			if (!do_force && for_each_lock(ls, LOCKS_EXIST_ANY)) {
+				need_stop++;
+			} else {
+				ls->thread_work = 1;
+				ls->thread_stop = 1;
+				pthread_cond_signal(&ls->cond);
+				stop_count++;
+			}
+			pthread_mutex_unlock(&ls->mutex);
+		}
+	}
+
+	if (do_free) {
+		list_for_each_entry_safe(ls, safe, &lockspaces, list) {
+
+			pthread_mutex_lock(&ls->mutex);
+			done = ls->thread_done;
+			stop = ls->thread_stop;
+			pthread_mutex_unlock(&ls->mutex);
+
+			/* This ls has locks and force is not set. */
+			if (!stop)
+				continue;
+
+			/*
+			 * Once thread_done is set, we know that the lockspace_thread
+			 * will not be using/touching the ls struct.  Any other
+			 * thread touches the ls struct under lockspaces_mutex.
+			 */
+			if (done) {
+				pthread_join(ls->thread, NULL);
+				list_del(&ls->list);
+
+				/* In future we may need to free ls->actions here */
+				free_ls_resources(ls);
+				list_add(&ls->list, &lockspaces_inactive);
+				free_count++;
+			} else {
+				need_free++;
+			}
+		}
+	}
+
+	if (list_empty(&lockspaces)) {
+		if (!gl_type_static) {
+			gl_use_dlm = 0;
+			gl_use_sanlock = 0;
+		}
+	}
+	pthread_mutex_unlock(&lockspaces_mutex);
+
+	if (stop_count || free_count || need_stop || need_free) {
+		log_debug("for_each_lockspace do_stop %d do_free %d "
+			  "stop_count %d free_count %d need_stop %d need_free %d",
+			  do_stop, do_free, stop_count, free_count, need_stop, need_free);
+	}
+
+	return need_stop + need_free;
+}
+
+/*
+ * This is only called when the daemon is exiting so the sleep/retry
+ * loop doesn't have any adverse impact.
+ */
+
+static void for_each_lockspace_retry(int do_stop, int do_free, int do_force)
+{
+	int count;
+
+	while (1) {
+		count = for_each_lockspace(do_stop, do_free, do_force);
+		if (!count)
+			break;
+
+		log_debug("for_each_lockspace_retry remaining %d", count);
+		sleep(1);
+	}
+}
+
+static int work_init_vg(struct action *act)
+{
+	struct lockspace *ls;
+	char ls_name[MAX_NAME+1];
+	int rv = 0;
+
+	memset(ls_name, 0, sizeof(ls_name));
+
+	vg_ls_name(act->vg_name, ls_name);
+
+	/*
+	 * The max dlm ls name is 64 and the max sanlock ls name is 48.  So,
+	 * after the "lvm_" prefix, only the first 60/44 characters of the VG
+	 * name are used for the lockspace name.  This will cause a collision
+	 * in the lock manager if two different VG names have the first 60/44
+	 * chars in common.  At the time of vgcreate (here), check if any other
+	 * VG's are known that would collide.  If the collision is not detected
+	 * at vgcreate time, it will be detected at start time and add_lockspace
+	 * will fail for the second of the two matching ls names.
+	 */
+	pthread_mutex_lock(&lockspaces_mutex);
+	list_for_each_entry(ls, &lockspaces, list) {
+		if ((ls->lm_type == LD_LM_SANLOCK) && !strncmp(ls->name, ls_name, 48)) {
+			rv = -EEXIST;
+			break;
+		}
+		if ((ls->lm_type == LD_LM_DLM) && !strcmp(ls->name, ls_name)) {
+			rv = -EEXIST;
+			break;
+		}
+	}
+	pthread_mutex_unlock(&lockspaces_mutex);
+
+	if (rv == -EEXIST) {
+		log_error("Existing lockspace name %s matches new %s VG names %s %s",
+			  ls->name, ls_name, ls->vg_name, act->vg_name);
+		return rv;
+	}
+
+	if (act->lm_type == LD_LM_SANLOCK)
+		rv = lm_init_vg_sanlock(ls_name, act->vg_name, act->flags, act->vg_args);
+	else if (act->lm_type == LD_LM_DLM)
+		rv = lm_init_vg_dlm(ls_name, act->vg_name, act->flags, act->vg_args);
+	else
+		rv = -EINVAL;
+
+	return rv;
+}
+
+static int work_rename_vg(struct action *act)
+{
+	char ls_name[MAX_NAME+1];
+	int rv = 0;
+
+	memset(ls_name, 0, sizeof(ls_name));
+
+	vg_ls_name(act->vg_name, ls_name);
+
+	if (act->lm_type == LD_LM_SANLOCK)
+		rv = lm_rename_vg_sanlock(ls_name, act->vg_name, act->flags, act->vg_args);
+	else if (act->lm_type == LD_LM_DLM)
+		return 0;
+	else
+		rv = -EINVAL;
+
+	return rv;
+}
+
+static void work_test_gl(void)
+{
+	struct lockspace *ls;
+	int is_enabled = 0;
+
+	pthread_mutex_lock(&lockspaces_mutex);
+	list_for_each_entry(ls, &lockspaces, list) {
+		if (ls->lm_type != LD_LM_SANLOCK)
+			continue;
+
+		pthread_mutex_lock(&ls->mutex);
+		if (ls->create_done && !ls->thread_stop) {
+			is_enabled = lm_gl_is_enabled(ls);
+			if (is_enabled) {
+				log_debug("S %s worker found gl_is_enabled", ls->name);
+				strncpy(gl_lsname_sanlock, ls->name, MAX_NAME);
+			}
+		}
+		pthread_mutex_unlock(&ls->mutex);
+
+		if (is_enabled)
+			break;
+	}
+
+	if (!is_enabled)
+		log_debug("worker found no gl_is_enabled");
+	pthread_mutex_unlock(&lockspaces_mutex);
+}
+
+static int work_init_lv(struct action *act)
+{
+	struct lockspace *ls;
+	char ls_name[MAX_NAME+1];
+	char vg_args[MAX_ARGS];
+	char lv_args[MAX_ARGS];
+	uint64_t free_offset = 0;
+	int lm_type = 0;
+	int rv = 0;
+
+	memset(ls_name, 0, sizeof(ls_name));
+	memset(vg_args, 0, MAX_ARGS);
+	memset(lv_args, 0, MAX_ARGS);
+
+	vg_ls_name(act->vg_name, ls_name);
+
+	pthread_mutex_lock(&lockspaces_mutex);
+	ls = find_lockspace_name(ls_name);
+	if (ls) {
+		lm_type = ls->lm_type;
+		memcpy(vg_args, ls->vg_args, MAX_ARGS);
+		free_offset = ls->free_lock_offset;
+		ls->free_lock_offset = 0;
+	}
+	pthread_mutex_unlock(&lockspaces_mutex);
+
+	if (!ls) {
+		lm_type = act->lm_type;
+		memcpy(vg_args, act->vg_args, MAX_ARGS);
+	}
+
+	if (act->lm_type != lm_type) {
+		log_error("init_lv ls_name %s wrong lm_type %d %d",
+			  ls_name, act->lm_type, lm_type);
+		return -EINVAL;
+	}
+
+	if (lm_type == LD_LM_SANLOCK) {
+		rv = lm_init_lv_sanlock(ls_name, act->vg_name, act->lv_uuid,
+					vg_args, lv_args, free_offset);
+
+		memcpy(act->lv_args, lv_args, MAX_ARGS);
+		return rv;
+
+	} else if (act->lm_type == LD_LM_DLM) {
+		return 0;
+	} else {
+		log_error("init_lv ls_name %s bad lm_type %d", ls_name, act->lm_type);
+		return -EINVAL;
+	}
+}
+
+/*
+ * When an action is queued for the worker_thread, it is processed right away.
+ * After processing, some actions need to be retried again in a short while.
+ * These actions are put on the delayed_list, and the worker_thread will
+ * process these delayed actions again in SHORT_DELAY_PERIOD.
+ */
+
+#define SHORT_DELAY_PERIOD 2
+#define LONG_DELAY_PERIOD 60
+
+static void *worker_thread_main(void *arg_in)
+{
+	struct list_head delayed_list;
+	struct timespec ts;
+	struct action *act, *safe;
+	uint64_t last_delayed_time = 0;
+	int delay_sec = LONG_DELAY_PERIOD;
+	int rv;
+
+	INIT_LIST_HEAD(&delayed_list);
+
+	while (1) {
+		pthread_mutex_lock(&worker_mutex);
+		clock_gettime(CLOCK_REALTIME, &ts);
+		ts.tv_sec += delay_sec;
+		rv = 0;
+		act = NULL;
+
+		while (list_empty(&worker_list) && !worker_stop && !worker_wake && !rv) {
+			rv = pthread_cond_timedwait(&worker_cond, &worker_mutex, &ts);
+		}
+		worker_wake = 0;
+
+		if (worker_stop) {
+			pthread_mutex_unlock(&worker_mutex);
+			goto out;
+		}
+
+		if (!list_empty(&worker_list)) {
+			act = list_first_entry(&worker_list, struct action, list);
+			list_del(&act->list);
+		}
+		pthread_mutex_unlock(&worker_mutex);
+
+		/*
+		 * Do new work actions before processing delayed work actions.
+		 */
+
+		if (!act)
+			goto delayed_work;
+
+		if (act->op == LD_OP_RUNNING_LM) {
+			int run_sanlock = lm_is_running_sanlock();
+			int run_dlm = lm_is_running_dlm();
+
+			if (run_sanlock && run_dlm)
+				act->result = -EXFULL;
+			else if (!run_sanlock && !run_dlm)
+				act->result = -ENOLCK;
+			else if (run_sanlock)
+				act->result = LD_LM_SANLOCK;
+			else if (run_dlm)
+				act->result = LD_LM_DLM;
+			add_client_result(act);
+
+		} else if ((act->op == LD_OP_LOCK) && (act->flags & LD_AF_SEARCH_LS)) {
+			/*
+			 * worker_thread used as a helper to search existing
+			 * sanlock vgs for an enabled gl.
+			 */
+			log_debug("work search for gl");
+			work_test_gl();
+
+			/* try again to find a gl lockspace for this act */
+			rv = add_lock_action(act);
+			if (rv < 0) {
+				act->result = rv;
+				add_client_result(act);
+			}
+
+		} else if ((act->op == LD_OP_INIT) && (act->rt == LD_RT_VG)) {
+			log_debug("work init_vg %s", act->vg_name);
+			act->result = work_init_vg(act);
+			add_client_result(act);
+
+		} else if ((act->op == LD_OP_INIT) && (act->rt == LD_RT_LV)) {
+			log_debug("work init_lv %s/%s uuid %s", act->vg_name, act->lv_name, act->lv_uuid);
+			act->result = work_init_lv(act);
+			add_client_result(act);
+
+		} else if ((act->op == LD_OP_RENAME_FINAL) && (act->rt == LD_RT_VG)) {
+			log_debug("work rename_vg %s", act->vg_name);
+			act->result = work_rename_vg(act);
+			add_client_result(act);
+
+		} else if (act->op == LD_OP_START_WAIT) {
+			act->result = count_lockspace_starting(act->client_id);
+			if (!act->result)
+				add_client_result(act);
+			else
+				list_add(&act->list, &delayed_list);
+
+		} else if (act->op == LD_OP_STOP_ALL) {
+			act->result = for_each_lockspace(DO_STOP, DO_FREE, (act->flags & LD_AF_FORCE) ? DO_FORCE : NO_FORCE);
+			if (!act->result || !(act->flags & LD_AF_WAIT))
+				add_client_result(act);
+			else
+				list_add(&act->list, &delayed_list);
+
+		} else {
+			log_error("work unknown op %d", act->op);
+			act->result = -EINVAL;
+			add_client_result(act);
+		}
+
+ delayed_work:
+		/*
+		 * We may want to track retry times per action so that
+		 * we can delay different actions by different amounts.
+		 */
+
+		if (monotime() - last_delayed_time < SHORT_DELAY_PERIOD) {
+			delay_sec = 1;
+			continue;
+		}
+		last_delayed_time = monotime();
+
+		list_for_each_entry_safe(act, safe, &delayed_list, list) {
+			if (act->op == LD_OP_START_WAIT) {
+				log_debug("work delayed start_wait for client %u", act->client_id);
+				act->result = count_lockspace_starting(act->client_id);
+				if (!act->result) {
+					list_del(&act->list);
+					add_client_result(act);
+				}
+
+			} else if (act->op == LD_OP_STOP_ALL) {
+				log_debug("work delayed stop_all");
+				act->result = for_each_lockspace(DO_STOP, DO_FREE, (act->flags & LD_AF_FORCE) ? DO_FORCE : NO_FORCE);
+				if (!act->result) {
+					list_del(&act->list);
+					act->result = 0;
+					add_client_result(act);
+				}
+			}
+		}
+
+		/*
+		 * This is not explicitly queued work, and not delayed work,
+		 * but lockspace thread cleanup that's needed when a
+		 * lockspace has been stopped/removed or failed to start.
+		 */
+
+		for_each_lockspace(NO_STOP, DO_FREE, NO_FORCE);
+
+		if (list_empty(&delayed_list))
+			delay_sec = LONG_DELAY_PERIOD;
+		else
+			delay_sec = 1;
+	}
+out:
+	list_for_each_entry_safe(act, safe, &delayed_list, list) {
+		list_del(&act->list);
+		free_action(act);
+	}
+
+	pthread_mutex_lock(&worker_mutex);
+	list_for_each_entry_safe(act, safe, &worker_list, list) {
+		list_del(&act->list);
+		free_action(act);
+	}
+	pthread_mutex_unlock(&worker_mutex);
+	return NULL;
+}
+
+static int setup_worker_thread(void)
+{
+	int rv;
+
+	INIT_LIST_HEAD(&worker_list);
+
+	pthread_mutex_init(&worker_mutex, NULL);
+	pthread_cond_init(&worker_cond, NULL);
+
+	rv = pthread_create(&worker_thread, NULL, worker_thread_main, NULL);
+	if (rv)
+		return -1;
+	return 0;
+}
+
+static void close_worker_thread(void)
+{
+	pthread_mutex_lock(&worker_mutex);
+	worker_stop = 1;
+	pthread_cond_signal(&worker_cond);
+	pthread_mutex_unlock(&worker_mutex);
+	pthread_join(worker_thread, NULL);
+}
+
+/* client_mutex is locked */
+static struct client *find_client_work(void)
+{
+	struct client *cl;
+
+	list_for_each_entry(cl, &client_list, list) {
+		if (cl->recv || cl->dead)
+			return cl;
+	}
+	return NULL;
+}
+
+/* client_mutex is locked */
+static struct client *find_client_id(uint32_t id)
+{
+	struct client *cl;
+
+	list_for_each_entry(cl, &client_list, list) {
+		if (cl->id == id)
+			return cl;
+	}
+	return NULL;
+}
+
+/* client_mutex is locked */
+static struct client *find_client_pi(int pi)
+{
+	struct client *cl;
+
+	list_for_each_entry(cl, &client_list, list) {
+		if (cl->pi == pi)
+			return cl;
+	}
+	return NULL;
+}
+
+/*
+ * wake up poll() because we have added an fd
+ * back into pollfd and poll() needs to be restarted
+ * to recognize it.
+ */
+static void restart_poll(void)
+{
+	int rv;
+	rv = write(restart_fds[1], "w", 1);
+	if (!rv || rv < 0)
+		log_debug("restart_poll write %d", errno);
+}
+
+/* poll will take requests from client again, cl->mutex must be held */
+static void client_resume(struct client *cl)
+{
+	if (cl->dead)
+		return;
+
+	if (!cl->poll_ignore || cl->fd == -1 || cl->pi == -1) {
+		/* shouldn't happen */
+		log_error("client_resume %d bad state ig %d fd %d pi %d",
+			  cl->id, cl->poll_ignore, cl->fd, cl->pi);
+		return;
+	}
+
+	pthread_mutex_lock(&pollfd_mutex);
+	if (pollfd[cl->pi].fd != POLL_FD_IGNORE) {
+		log_error("client_resume %d pi %d fd %d not IGNORE",
+			  cl->id, cl->pi, cl->fd);
+	}
+	pollfd[cl->pi].fd = cl->fd;
+	pollfd[cl->pi].events = POLLIN;
+	pthread_mutex_unlock(&pollfd_mutex);
+
+	restart_poll();
+}
+
+/* called from client_thread, cl->mutex is held */
+static void client_send_result(struct client *cl, struct action *act)
+{
+	response res;
+	char result_flags[128];
+
+	if (cl->dead) {
+		log_debug("client send %d skip dead", cl->id);
+		return;
+	}
+
+	memset(result_flags, 0, sizeof(result_flags));
+
+	buffer_init(&res.buffer);
+
+	/*
+	 * EUNATCH is returned when the global lock existed,
+	 * but had been disabled when we tried to lock it,
+	 * so we removed it, and no longer have a gl to lock.
+	 */
+
+	if (act->result == -EUNATCH)
+		act->result = -ENOLS;
+
+	/*
+	 * init_vg with dlm|sanlock returns vg_args
+	 * init_lv with sanlock returns lv_args
+	 */
+
+	if (act->result == -ENOLS) {
+		/*
+		 * The lockspace could not be found, in which case
+		 * the caller may want to know if any lockspaces exist
+		 * or if lockspaces exist, but not one with the global lock.
+		 * Given this detail, it may be able to procede without
+		 * the lock.
+		 *
+		 * FIXME: it would also help the caller to know if there
+		 * are other sanlock VGs that have not been started.
+		 * If there are, then one of them might have a global
+		 * lock enabled.  In that case, vgcreate may not want
+		 * to create a new sanlock vg with gl enabled.
+		 */
+		pthread_mutex_lock(&lockspaces_mutex);
+		if (list_empty(&lockspaces))
+			strcat(result_flags, "NO_LOCKSPACES,");
+		pthread_mutex_unlock(&lockspaces_mutex);
+
+		if (gl_use_sanlock && !gl_lsname_sanlock[0])
+			strcat(result_flags, "NO_GL_LS,");
+		else if (gl_use_dlm && !gl_lsname_dlm[0])
+			strcat(result_flags, "NO_GL_LS,");
+		else
+			strcat(result_flags, "NO_GL_LS,");
+	}
+
+	if (act->flags & LD_AF_DUP_GL_LS)
+		strcat(result_flags, "DUP_GL_LS,");
+
+	if (act->flags & LD_AF_INACTIVE_LS)
+		strcat(result_flags, "INACTIVE_LS,");
+
+	if (act->flags & LD_AF_ADD_LS_ERROR)
+		strcat(result_flags, "ADD_LS_ERROR,");
+	
+	if (act->op == LD_OP_INIT) {
+		/*
+		 * init is a special case where lock args need
+		 * to be passed back to the client.
+		 */
+		const char *vg_args = "none";
+		const char *lv_args = "none";
+
+		if (act->vg_args[0])
+			vg_args = act->vg_args;
+
+		if (act->lv_args[0])
+			lv_args = act->lv_args;
+
+		log_debug("send %s[%d.%u] %s %s rv %d vg_args %s lv_args %s",
+			  cl->name[0] ? cl->name : "client", cl->pid, cl->id,
+			  op_str(act->op), rt_str(act->rt),
+			  act->result, vg_args ? vg_args : "", lv_args ? lv_args : "");
+
+		res = daemon_reply_simple("OK",
+					  "op = %d", act->op,
+					  "op_result = %d", act->result,
+					  "lm_result = %d", act->lm_rv,
+					  "vg_lock_args = %s", vg_args,
+					  "lv_lock_args = %s", lv_args,
+					  "result_flags = %s", result_flags[0] ? result_flags : "none",
+					  NULL);
+	} else {
+		/*
+		 * A normal reply.
+		 */
+
+		log_debug("send %s[%d.%u] %s %s rv %d %s %s",
+			  cl->name[0] ? cl->name : "client", cl->pid, cl->id,
+			  op_str(act->op), rt_str(act->rt),
+			  act->result, (act->result == -ENOLS) ? "ENOLS" : "", result_flags);
+
+		res = daemon_reply_simple("OK",
+					  "op = %d", act->op,
+					  "lock_type = %s", lm_str(act->lm_type),
+					  "op_result = %d", act->result,
+					  "lm_result = %d", act->lm_rv,
+					  "result_flags = %s", result_flags[0] ? result_flags : "none",
+					  NULL);
+	}
+
+	buffer_write(cl->fd, &res.buffer);
+	buffer_destroy(&res.buffer);
+
+	client_resume(cl);
+}
+
+/* called from client_thread */
+static void client_purge(struct client *cl)
+{
+	struct lockspace *ls;
+	struct action *act;
+
+	pthread_mutex_lock(&lockspaces_mutex);
+	list_for_each_entry(ls, &lockspaces, list) {
+		if (!(act = alloc_action()))
+			continue;
+
+		act->op = LD_OP_CLOSE;
+		act->client_id = cl->id;
+
+		pthread_mutex_lock(&ls->mutex);
+		if (!ls->thread_stop) {
+			list_add_tail(&act->list, &ls->actions);
+			ls->thread_work = 1;
+			pthread_cond_signal(&ls->cond);
+		} else {
+			free_action(act);
+		}
+		pthread_mutex_unlock(&ls->mutex);
+	}
+	pthread_mutex_unlock(&lockspaces_mutex);
+}
+
+static int add_lock_action(struct action *act)
+{
+	struct lockspace *ls = NULL;
+	char ls_name[MAX_NAME+1];
+
+	memset(ls_name, 0, sizeof(ls_name));
+
+	/* Determine which lockspace this action is for, and set ls_name. */
+
+	if (act->rt == LD_RT_GL && gl_use_sanlock &&
+	    (act->op == LD_OP_ENABLE || act->op == LD_OP_DISABLE))
+		vg_ls_name(act->vg_name, ls_name);
+	else if (act->rt == LD_RT_GL)
+		gl_ls_name(ls_name);
+	else
+		vg_ls_name(act->vg_name, ls_name);
+
+ retry:
+	pthread_mutex_lock(&lockspaces_mutex);
+	if (ls_name[0])
+		ls = find_lockspace_name(ls_name);
+	if (!ls) {
+		int ls_inactive = 0;
+		int ls_create_fail = 0;
+
+		ls = find_lockspace_inactive(ls_name);
+		if (ls) {
+			ls_inactive = 1;
+			ls_create_fail = ls->create_fail;
+			ls = NULL;
+		}
+		pthread_mutex_unlock(&lockspaces_mutex);
+
+		if (act->op == LD_OP_UPDATE && act->rt == LD_RT_VG) {
+			log_debug("lockspace not found ignored for vg update");
+			return -ENOLS;
+
+		} else if (act->flags & LD_AF_SEARCH_LS) {
+			/* fail if we've already tried searching for the ls */
+			log_error("lockspace search repeated %s", ls_name);
+			return -ENOLS;
+
+		} else if (act->op == LD_OP_LOCK && act->rt == LD_RT_GL && gl_use_sanlock) {
+			/* gl may have been enabled in an existing vg */
+			log_debug("gl lockspace not found check sanlock vgs");
+			act->flags |= LD_AF_SEARCH_LS;
+			add_work_action(act);
+			return 0;
+
+		} else if (act->op == LD_OP_LOCK && act->rt == LD_RT_GL && gl_use_dlm) {
+			log_debug("gl lockspace not found add dlm global");
+			act->flags |= LD_AF_SEARCH_LS;
+			act->flags |= LD_AF_WAIT_STARTING;
+			add_dlm_global_lockspace(NULL);
+			gl_ls_name(ls_name);
+			goto retry;
+
+		} else if (act->op == LD_OP_LOCK && act->mode == LD_LK_UN) {
+			log_debug("lockspace not found ignored for unlock");
+			return -ENOLS;
+
+		} else if (act->op == LD_OP_LOCK && act->rt == LD_RT_VG && ls_inactive) {
+			/* ls has been stopped or previously failed to start */
+			log_debug("lockspace inactive create_fail %d %s",
+				  ls_create_fail, ls_name);
+			act->flags |= LD_AF_INACTIVE_LS;
+			if (ls_create_fail)
+				act->flags |= LD_AF_ADD_LS_ERROR;
+			return -ENOLS;
+
+		} else {
+			log_error("lockspace not found %s", ls_name);
+			return -ENOLS;
+		}
+	}
+
+	if (act->lm_type == LD_LM_NONE) {
+		/* return to the command the type we are using */
+		act->lm_type = ls->lm_type;
+	} else if (act->lm_type != ls->lm_type) {
+		/* should not happen */
+		log_error("S %s add_lock_action bad lm_type %d ls %d",
+			  ls_name, act->lm_type, ls->lm_type);
+		return -EINVAL;
+	}
+
+	pthread_mutex_lock(&ls->mutex);
+	if (ls->thread_stop && ls->thread_done) {
+		log_debug("lockspace is done finish cleanup %s", ls_name);
+		pthread_join(ls->thread, NULL);
+		list_del(&ls->list);
+		pthread_mutex_unlock(&ls->mutex);
+		free_ls_resources(ls);
+		free(ls);
+		pthread_mutex_unlock(&lockspaces_mutex);
+		goto retry;
+	}
+
+	if (ls->thread_stop) {
+		pthread_mutex_unlock(&ls->mutex);
+		pthread_mutex_unlock(&lockspaces_mutex);
+		log_error("lockspace is stopping %s", ls_name);
+		return -ESTALE;
+	}
+
+	if (!ls->create_fail && !ls->create_done && !(act->flags & LD_AF_WAIT_STARTING)) {
+		pthread_mutex_unlock(&ls->mutex);
+		pthread_mutex_unlock(&lockspaces_mutex);
+		log_debug("lockspace is starting %s", ls_name);
+		return -ESTARTING;
+	}
+
+	list_add_tail(&act->list, &ls->actions);
+	ls->thread_work = 1;
+	pthread_cond_signal(&ls->cond);
+	pthread_mutex_unlock(&ls->mutex);
+	pthread_mutex_unlock(&lockspaces_mutex);
+
+	/* lockspace_thread_main / res_process take it from here */
+
+	return 0;
+}
+
+static int str_to_op_rt(const char *req_name, int *op, int *rt)
+{
+	if (!req_name)
+		goto out;
+
+	if (!strcmp(req_name, "hello")) {
+		*op = LD_OP_HELLO;
+		*rt = 0;
+		return 0;
+	}
+	if (!strcmp(req_name, "quit")) {
+		*op = LD_OP_QUIT;
+		*rt = 0;
+		return 0;
+	}
+	if (!strcmp(req_name, "info")) {
+		*op = LD_OP_DUMP_INFO;
+		*rt = 0;
+		return 0;
+	}
+	if (!strcmp(req_name, "dump")) {
+		*op = LD_OP_DUMP_LOG;
+		*rt = 0;
+		return 0;
+	}
+	if (!strcmp(req_name, "init_vg")) {
+		*op = LD_OP_INIT;
+		*rt = LD_RT_VG;
+		return 0;
+	}
+	if (!strcmp(req_name, "init_lv")) {
+		*op = LD_OP_INIT;
+		*rt = LD_RT_LV;
+		return 0;
+	}
+	if (!strcmp(req_name, "free_vg")) {
+		*op = LD_OP_FREE;
+		*rt = LD_RT_VG;
+		return 0;
+	}
+	if (!strcmp(req_name, "free_lv")) {
+		*op = LD_OP_FREE;
+		*rt = LD_RT_LV;
+		return 0;
+	}
+	if (!strcmp(req_name, "start_vg")) {
+		*op = LD_OP_START;
+		*rt = LD_RT_VG;
+		return 0;
+	}
+	if (!strcmp(req_name, "stop_vg")) {
+		*op = LD_OP_STOP;
+		*rt = LD_RT_VG;
+		return 0;
+	}
+	if (!strcmp(req_name, "start_wait")) {
+		*op = LD_OP_START_WAIT;
+		*rt = 0;
+		return 0;
+	}
+	if (!strcmp(req_name, "stop_all")) {
+		*op = LD_OP_STOP_ALL;
+		*rt = 0;
+		return 0;
+	}
+	if (!strcmp(req_name, "lock_gl")) {
+		*op = LD_OP_LOCK;
+		*rt = LD_RT_GL;
+		return 0;
+	}
+	if (!strcmp(req_name, "lock_vg")) {
+		*op = LD_OP_LOCK;
+		*rt = LD_RT_VG;
+		return 0;
+	}
+	if (!strcmp(req_name, "lock_lv")) {
+		*op = LD_OP_LOCK;
+		*rt = LD_RT_LV;
+		return 0;
+	}
+	if (!strcmp(req_name, "vg_update")) {
+		*op = LD_OP_UPDATE;
+		*rt = LD_RT_VG;
+		return 0;
+	}
+	if (!strcmp(req_name, "enable_gl")) {
+		*op = LD_OP_ENABLE;
+		*rt = LD_RT_GL;
+		return 0;
+	}
+	if (!strcmp(req_name, "disable_gl")) {
+		*op = LD_OP_DISABLE;
+		*rt = LD_RT_GL;
+		return 0;
+	}
+	if (!strcmp(req_name, "rename_vg_before")) {
+		*op = LD_OP_RENAME_BEFORE;
+		*rt = LD_RT_VG;
+		return 0;
+	}
+	if (!strcmp(req_name, "rename_vg_final")) {
+		*op = LD_OP_RENAME_FINAL;
+		*rt = LD_RT_VG;
+		return 0;
+	}
+	if (!strcmp(req_name, "running_lm")) {
+		*op = LD_OP_RUNNING_LM;
+		*rt = 0;
+		return 0;
+	}
+	if (!strcmp(req_name, "find_free_lock")) {
+		*op = LD_OP_FIND_FREE_LOCK;
+		*rt = LD_RT_VG;
+		return 0;
+	}
+	if (!strcmp(req_name, "forget_vg_name")) {
+		*op = LD_OP_FORGET_VG_NAME;
+		*rt = LD_RT_VG;
+		return 0;
+	}
+out:
+	return -1;
+}
+
+static int str_to_mode(const char *str)
+{
+	if (!str)
+		goto out;
+	if (!strcmp(str, "un"))
+		return LD_LK_UN;
+	if (!strcmp(str, "nl"))
+		return LD_LK_NL;
+	if (!strcmp(str, "sh"))
+		return LD_LK_SH;
+	if (!strcmp(str, "ex"))
+		return LD_LK_EX;
+out:
+	return LD_LK_IV;
+}
+
+static int str_to_lm(const char *str)
+{
+	if (!str || !strcmp(str, "none"))
+		return LD_LM_NONE;
+	if (!strcmp(str, "sanlock"))
+		return LD_LM_SANLOCK;
+	if (!strcmp(str, "dlm"))
+		return LD_LM_DLM;
+	return -2; 
+}
+
+static uint32_t str_to_opts(const char *str)
+{
+	uint32_t flags = 0;
+
+	if (!str)
+		goto out;
+	if (strstr(str, "persistent"))
+		flags |= LD_AF_PERSISTENT;
+	if (strstr(str, "unlock_cancel"))
+		flags |= LD_AF_UNLOCK_CANCEL;
+	if (strstr(str, "next_version"))
+		flags |= LD_AF_NEXT_VERSION;
+	if (strstr(str, "wait"))
+		flags |= LD_AF_WAIT;
+	if (strstr(str, "force"))
+		flags |= LD_AF_FORCE;
+	if (strstr(str, "ex_disable"))
+		flags |= LD_AF_EX_DISABLE;
+	if (strstr(str, "enable"))
+		flags |= LD_AF_ENABLE;
+	if (strstr(str, "disable"))
+		flags |= LD_AF_DISABLE;
+out:
+	return flags;
+}
+
+/*
+ * dump info
+ * client_list: each client struct
+ * lockspaces: each lockspace struct
+ * lockspace actions: each action struct
+ * lockspace resources: each resource struct
+ * lockspace resource actions: each action struct
+ * lockspace resource locks: each lock struct
+ */
+
+static int setup_dump_socket(void)
+{
+	int s;
+
+	s = socket(AF_LOCAL, SOCK_DGRAM, 0);
+	if (s < 0)
+		return s;
+
+	memset(&dump_addr, 0, sizeof(dump_addr));
+	dump_addr.sun_family = AF_LOCAL;
+	strcpy(&dump_addr.sun_path[1], DUMP_SOCKET_NAME);
+	dump_addrlen = sizeof(sa_family_t) + strlen(dump_addr.sun_path+1) + 1;
+
+	return s;
+}
+
+static int send_dump_buf(int fd, int dump_len)
+{
+	int pos = 0;
+	int ret;
+
+retry:
+	ret = sendto(fd, dump_buf + pos, dump_len - pos, MSG_DONTWAIT | MSG_NOSIGNAL,
+		     (struct sockaddr *)&dump_addr, dump_addrlen);
+	if (ret <= 0)
+		return ret;
+
+	pos += ret;
+
+	if (pos < dump_len)
+		goto retry;
+
+	return 0;
+}
+
+static int print_structs(const char *prefix, int pos, int len)
+{
+	return snprintf(dump_buf + pos, len - pos,
+			"info=%s "
+			"unused_action_count=%d "
+			"unused_client_count=%d "
+			"unused_resource_count=%d "
+			"unused_lock_count=%d\n",
+			prefix,
+			unused_action_count,
+			unused_client_count,
+			unused_resource_count,
+			unused_lock_count);
+}
+
+static int print_client(struct client *cl, const char *prefix, int pos, int len)
+{
+	return snprintf(dump_buf + pos, len - pos,
+			"info=%s "
+			"pid=%d "
+			"fd=%d "
+			"pi=%d "
+			"id=%u "
+			"name=%s\n",
+			prefix,
+			cl->pid,
+			cl->fd,
+			cl->pi,
+			cl->id,
+			cl->name[0] ? cl->name : ".");
+}
+
+static int print_lockspace(struct lockspace *ls, const char *prefix, int pos, int len)
+{
+	return snprintf(dump_buf + pos, len - pos,
+			"info=%s "
+			"ls_name=%s "
+			"vg_name=%s "
+			"vg_uuid=%s "
+			"vg_sysid=%s "
+			"vg_args=%s "
+			"lm_type=%s "
+			"host_id=%llu "
+			"create_fail=%d "
+			"create_done=%d "
+			"thread_work=%d "
+			"thread_stop=%d "
+			"thread_done=%d "
+			"sanlock_gl_enabled=%d "
+			"sanlock_gl_dup=%d\n",
+			prefix,
+			ls->name,
+			ls->vg_name,
+			ls->vg_uuid,
+			ls->vg_sysid[0] ? ls->vg_sysid : ".",
+			ls->vg_args,
+			lm_str(ls->lm_type),
+			(unsigned long long)ls->host_id,
+			ls->create_fail ? 1 : 0,
+			ls->create_done ? 1 : 0,
+			ls->thread_work ? 1 : 0,
+			ls->thread_stop ? 1 : 0,
+			ls->thread_done ? 1 : 0,
+			ls->sanlock_gl_enabled ? 1 : 0,
+			ls->sanlock_gl_dup ? 1 : 0);
+}
+
+static int print_action(struct action *act, const char *prefix, int pos, int len)
+{
+	return snprintf(dump_buf + pos, len - pos,
+			"info=%s "
+			"client_id=%u "
+			"flags=0x%x "
+			"version=%u "
+			"op=%s "
+			"rt=%s "
+			"mode=%s "
+			"lm_type=%s "
+			"result=%d "
+			"lm_rv=%d\n",
+			prefix,
+			act->client_id,
+			act->flags,
+			act->version,
+			op_str(act->op),
+			rt_str(act->rt),
+			mode_str(act->mode),
+			lm_str(act->lm_type),
+			act->result,
+			act->lm_rv);
+}
+
+static int print_resource(struct resource *r, const char *prefix, int pos, int len)
+{
+	return snprintf(dump_buf + pos, len - pos,
+			"info=%s "
+			"name=%s "
+			"type=%s "
+			"mode=%s "
+			"sh_count=%d "
+			"version=%u\n",
+			prefix,
+			r->name,
+			rt_str(r->type),
+			mode_str(r->mode),
+			r->sh_count,
+			r->version);
+}
+
+static int print_lock(struct lock *lk, const char *prefix, int pos, int len)
+{
+	return snprintf(dump_buf + pos, len - pos,
+			"info=%s "
+			"mode=%s "
+			"version=%u "
+			"flags=0x%x "
+			"client_id=%u\n",
+			prefix,
+			mode_str(lk->mode),
+			lk->version,
+			lk->flags,
+			lk->client_id);
+}
+
+static int dump_info(int *dump_len)
+{
+	struct client *cl;
+	struct lockspace *ls;
+	struct resource *r;
+	struct lock *lk;
+	struct action *act;
+	int len, pos, ret;
+	int rv = 0;
+
+	memset(dump_buf, 0, sizeof(dump_buf));
+	len = sizeof(dump_buf);
+	pos = 0;
+
+	/*
+	 * memory
+	 */
+
+	pthread_mutex_lock(&unused_struct_mutex);
+	ret = print_structs("structs", pos, len);
+	if (ret >= len - pos) {
+		pthread_mutex_unlock(&unused_struct_mutex);
+		return -ENOSPC;
+	}
+	pos += ret;
+	pthread_mutex_unlock(&unused_struct_mutex);
+
+	/*
+	 * clients
+	 */
+
+	pthread_mutex_lock(&client_mutex);
+	list_for_each_entry(cl, &client_list, list) {
+		ret = print_client(cl, "client", pos, len);
+		if (ret >= len - pos) {
+			 rv = -ENOSPC;
+			 break;
+		}
+		pos += ret;
+	}
+	pthread_mutex_unlock(&client_mutex);
+
+	if (rv < 0)
+		return rv;
+
+	/*
+	 * lockspaces with their action/resource/lock info
+	 */
+
+	pthread_mutex_lock(&lockspaces_mutex);
+	list_for_each_entry(ls, &lockspaces, list) {
+
+		ret = print_lockspace(ls, "ls", pos, len);
+		if (ret >= len - pos) {
+			 rv = -ENOSPC;
+			 goto out;
+		}
+		pos += ret;
+
+		list_for_each_entry(act, &ls->actions, list) {
+			ret = print_action(act, "ls_action", pos, len);
+			if (ret >= len - pos) {
+				rv = -ENOSPC;
+				goto out;
+			}
+			pos += ret;
+		}
+
+		list_for_each_entry(r, &ls->resources, list) {
+			ret = print_resource(r, "r", pos, len);
+			if (ret >= len - pos) {
+				rv = -ENOSPC;
+				goto out;
+			}
+			pos += ret;
+
+			list_for_each_entry(lk, &r->locks, list) {
+				ret = print_lock(lk, "lk", pos, len);
+				if (ret >= len - pos) {
+					rv = -ENOSPC;
+					goto out;
+				}
+				pos += ret;
+			}
+
+			list_for_each_entry(act, &r->actions, list) {
+				ret = print_action(act, "r_action", pos, len);
+				if (ret >= len - pos) {
+					rv = -ENOSPC;
+					goto out;
+				}
+				pos += ret;
+			}
+		}
+	}
+out:
+	pthread_mutex_unlock(&lockspaces_mutex);
+
+	*dump_len = pos;
+
+	return rv;
+}
+
+/* called from client_thread, cl->mutex is held */
+static void client_recv_action(struct client *cl)
+{
+	request req;
+	response res;
+	struct action *act;
+	const char *cl_name;
+	const char *vg_name;
+	const char *vg_uuid;
+	const char *vg_sysid;
+	const char *str;
+	int64_t val;
+	uint32_t opts = 0;
+	int result = 0;
+	int cl_pid;
+	int op, rt, lm, mode;
+	int rv;
+
+	buffer_init(&req.buffer);
+
+	rv = buffer_read(cl->fd, &req.buffer);
+	if (!rv) {
+		if (errno == ECONNRESET) {
+			log_debug("client recv %d ECONNRESET", cl->id);
+			cl->dead = 1;
+		} else {
+			log_error("client recv %d buffer_read error %d", cl->id, errno);
+		}
+		buffer_destroy(&req.buffer);
+		client_resume(cl);
+		return;
+	}
+
+	req.cft = dm_config_from_string(req.buffer.mem);
+	if (!req.cft) {
+		log_error("client recv %d config_from_string error", cl->id);
+		buffer_destroy(&req.buffer);
+		client_resume(cl);
+		return;
+	}
+
+	str = daemon_request_str(req, "request", NULL);
+	rv = str_to_op_rt(str, &op, &rt);
+	if (rv < 0) {
+		log_error("client recv %d bad request name \"%s\"", cl->id, str ? str : "");
+		dm_config_destroy(req.cft);
+		buffer_destroy(&req.buffer);
+		client_resume(cl);
+		return;
+	}
+
+	if (op == LD_OP_HELLO || op == LD_OP_QUIT ||
+	    op == LD_OP_DUMP_INFO || op == LD_OP_DUMP_LOG) {
+
+		/*
+		 * FIXME: add the client command name to the hello messages
+		 * so it can be saved in cl->name here.
+		 */
+
+		result = 0;
+
+		if (op == LD_OP_QUIT) {
+			log_debug("op quit");
+			pthread_mutex_lock(&lockspaces_mutex);
+		       	if (list_empty(&lockspaces)) {
+				daemon_quit = 1;
+			} else {
+				result = -EBUSY;
+			}
+			pthread_mutex_unlock(&lockspaces_mutex);
+		}
+
+		buffer_init(&res.buffer);
+
+		if (op == LD_OP_DUMP_INFO || op == LD_OP_DUMP_LOG) {
+			int dump_len = 0;
+			int fd;
+
+			fd = setup_dump_socket();
+			if (fd < 0)
+				result = fd;
+			else if (op == LD_OP_DUMP_INFO)
+				result = dump_info(&dump_len);
+			else if (op == LD_OP_DUMP_LOG)
+				result = dump_log(&dump_len);
+			else
+				result = -EINVAL;
+
+			res = daemon_reply_simple("OK",
+					  "result = %d", result,
+					  "dump_len = %d", dump_len,
+					  NULL);
+			if (fd >= 0) {
+				send_dump_buf(fd, dump_len);
+				close(fd);
+			}
+
+		} else {
+			res = daemon_reply_simple("OK",
+					  "result = %d", result,
+					  "protocol = %s", lvmlockd_protocol,
+					  "version = %d", lvmlockd_protocol_version,
+					  NULL);
+		}
+
+		buffer_write(cl->fd, &res.buffer);
+		buffer_destroy(&res.buffer);
+		dm_config_destroy(req.cft);
+		buffer_destroy(&req.buffer);
+		client_resume(cl);
+		return;
+	}
+
+	cl_name = daemon_request_str(req, "cmd", NULL);
+	cl_pid = daemon_request_int(req, "pid", 0);
+	vg_name = daemon_request_str(req, "vg_name", NULL);
+	vg_uuid = daemon_request_str(req, "vg_uuid", NULL);
+	vg_sysid = daemon_request_str(req, "vg_sysid", NULL);
+	str = daemon_request_str(req, "mode", NULL);
+	mode = str_to_mode(str);
+	str = daemon_request_str(req, "opts", NULL);
+	opts = str_to_opts(str);
+	str = daemon_request_str(req, "vg_lock_type", NULL);
+	lm = str_to_lm(str);
+
+	if (cl_pid && cl_pid != cl->pid)
+		log_error("client recv bad message pid %d client %d", cl_pid, cl->pid);
+
+	/* FIXME: do this in hello message instead */
+	if (!cl->name[0] && cl_name)
+		strncpy(cl->name, cl_name, MAX_NAME);
+
+	if (!gl_use_dlm && !gl_use_sanlock && (lm > 0)) {
+		if (lm == LD_LM_DLM)
+			gl_use_dlm = 1;
+		else if (lm == LD_LM_SANLOCK)
+			gl_use_sanlock = 1;
+
+		log_debug("set gl_use_%s", lm_str(lm));
+	}
+
+	if (!(act = alloc_action())) {
+		log_error("No memory for action");
+		dm_config_destroy(req.cft);
+		buffer_destroy(&req.buffer);
+		client_resume(cl);
+		return;
+	}
+
+	act->client_id = cl->id;
+	act->op = op;
+	act->rt = rt;
+	act->mode = mode;
+	act->flags = opts;
+	act->lm_type = lm;
+
+	if (vg_name && strcmp(vg_name, "none"))
+		strncpy(act->vg_name, vg_name, MAX_NAME);
+
+	if (vg_uuid && strcmp(vg_uuid, "none"))
+		strncpy(act->vg_uuid, vg_uuid, 64);
+
+	if (vg_sysid && strcmp(vg_sysid, "none"))
+		strncpy(act->vg_sysid, vg_sysid, MAX_NAME);
+
+	str = daemon_request_str(req, "lv_name", NULL);
+	if (str && strcmp(str, "none"))
+		strncpy(act->lv_name, str, MAX_NAME);
+
+	str = daemon_request_str(req, "lv_uuid", NULL);
+	if (str && strcmp(str, "none"))
+		strncpy(act->lv_uuid, str, MAX_NAME);
+
+	val = daemon_request_int(req, "version", 0);
+	if (val)
+		act->version = (uint32_t)val;
+
+	str = daemon_request_str(req, "vg_lock_args", NULL);
+	if (str && strcmp(str, "none"))
+		strncpy(act->vg_args, str, MAX_ARGS);
+
+	str = daemon_request_str(req, "lv_lock_args", NULL);
+	if (str && strcmp(str, "none"))
+		strncpy(act->lv_args, str, MAX_ARGS);
+
+	/* start_vg will include lvmlocal.conf local/host_id here */
+	val = daemon_request_int(req, "host_id", 0);
+	if (val)
+		act->host_id = val;
+
+	act->max_retries = daemon_request_int(req, "max_retries", DEFAULT_MAX_RETRIES);
+
+	dm_config_destroy(req.cft);
+	buffer_destroy(&req.buffer);
+
+	log_debug("recv %s[%d.%u] %s %s \"%s\" mode %s flags %x",
+		  cl->name[0] ? cl->name : "client", cl->pid, cl->id,
+		  op_str(act->op), rt_str(act->rt), act->vg_name, mode_str(act->mode), opts);
+
+	switch (act->op) {
+	case LD_OP_START:
+		rv = add_lockspace(act);
+		break;
+	case LD_OP_STOP:
+		rv = rem_lockspace(act);
+		break;
+	case LD_OP_INIT:
+	case LD_OP_START_WAIT:
+	case LD_OP_STOP_ALL:
+	case LD_OP_RENAME_FINAL:
+	case LD_OP_RUNNING_LM:
+		add_work_action(act);
+		rv = 0;
+		break;
+	case LD_OP_LOCK:
+	case LD_OP_UPDATE:
+	case LD_OP_ENABLE:
+	case LD_OP_DISABLE:
+	case LD_OP_FREE:
+	case LD_OP_RENAME_BEFORE:
+	case LD_OP_FIND_FREE_LOCK:
+		rv = add_lock_action(act);
+		break;
+	case LD_OP_FORGET_VG_NAME:
+		act->result = forget_lockspace_inactive(act->vg_name);
+		add_client_result(act);
+		break;
+	default:
+		rv = -EINVAL;
+	};
+
+	if (rv < 0) {
+		act->result = rv;
+		add_client_result(act);
+	}
+}
+
+static void *client_thread_main(void *arg_in)
+{
+	struct client *cl;
+	struct action *act;
+
+	while (1) {
+		pthread_mutex_lock(&client_mutex);
+		while (!client_work && list_empty(&client_results)) {
+			if (client_stop) {
+				pthread_mutex_unlock(&client_mutex);
+				goto out;
+			}
+			pthread_cond_wait(&client_cond, &client_mutex);
+		}
+
+		/*
+		 * Send outgoing results back to clients
+		 */
+
+		if (!list_empty(&client_results)) {
+			act = list_first_entry(&client_results, struct action, list);
+			list_del(&act->list);
+			cl = find_client_id(act->client_id);
+			pthread_mutex_unlock(&client_mutex);
+
+			if (cl) {
+				pthread_mutex_lock(&cl->mutex);
+				client_send_result(cl, act);
+				pthread_mutex_unlock(&cl->mutex);
+			} else {
+				log_debug("no client for result");
+			}
+			free_action(act);
+			continue;
+		}
+
+		/*
+		 * Queue incoming actions for lockspace threads
+		 */
+
+		if (client_work) {
+			cl = find_client_work();
+			if (!cl)
+				client_work = 0;
+			pthread_mutex_unlock(&client_mutex);
+
+			if (!cl)
+				continue;
+
+			pthread_mutex_lock(&cl->mutex);
+
+			if (cl->recv) {
+				cl->recv = 0;
+				client_recv_action(cl);
+			}
+
+			if (cl->dead) {
+				/*
+				log_debug("client rem %d pi %d fd %d ig %d",
+					  cl->id, cl->pi, cl->fd, cl->poll_ignore);
+				*/
+				/*
+				 * If cl->dead was set in main_loop, then the
+				 * fd has already been closed and the pollfd
+				 * entry is already unused.
+				 * main_loop set dead=1, ignore=0, pi=-1, fd=-1
+				 *
+				 * if cl->dead was not set in main_loop, but
+				 * set in client_recv_action, then the main_loop
+				 * should be ignoring this client fd.
+				 * main_loop set ignore=1
+				 */
+
+				if (cl->poll_ignore) {
+					log_debug("client close %d pi %d fd %d",
+						  cl->id, cl->pi, cl->fd);
+					/* assert cl->pi != -1 */
+					/* assert pollfd[pi].fd == FD_IGNORE */
+					close(cl->fd);
+					rem_pollfd(cl->pi);
+					cl->pi = -1;
+					cl->fd = -1;
+					cl->poll_ignore = 0;
+				} else {
+					/* main thread should have closed */
+					if (cl->pi != -1 || cl->fd != -1) {
+						log_error("client %d bad state pi %d fd %d",
+							  cl->id, cl->pi, cl->fd);
+					}
+				}
+				pthread_mutex_unlock(&cl->mutex);
+
+				pthread_mutex_lock(&client_mutex);
+				list_del(&cl->list);
+				pthread_mutex_unlock(&client_mutex);
+
+				client_purge(cl);
+
+				free_client(cl);
+			} else {
+				pthread_mutex_unlock(&cl->mutex);
+			}
+		}
+		pthread_mutex_unlock(&client_mutex);
+	}
+out:
+	return NULL;
+}
+
+static int setup_client_thread(void)
+{
+	int rv;
+
+	INIT_LIST_HEAD(&client_list);
+	INIT_LIST_HEAD(&client_results);
+
+	pthread_mutex_init(&client_mutex, NULL);
+	pthread_cond_init(&client_cond, NULL);
+
+	rv = pthread_create(&client_thread, NULL, client_thread_main, NULL);
+	if (rv)
+		return -1;
+	return 0;
+}
+
+static void close_client_thread(void)
+{
+	pthread_mutex_lock(&client_mutex);
+	client_stop = 1;
+	pthread_cond_signal(&client_cond);
+	pthread_mutex_unlock(&client_mutex);
+	pthread_join(client_thread, NULL);
+}
+
+/*
+ * Get a list of all VGs with a lockd type (sanlock|dlm) from lvmetad.
+ * We'll match this list against a list of existing lockspaces that are
+ * found in the lock manager.
+ *
+ * For each of these VGs, also create a struct resource on ls->resources to
+ * represent each LV in the VG that uses a lock.  For each of these LVs
+ * that are active, we'll attempt to adopt a lock.
+ */
+
+static int get_lockd_vgs(struct list_head *vg_lockd)
+{
+	struct list_head update_vgs;
+	daemon_reply reply;
+	struct dm_config_node *cn;
+	struct dm_config_node *metadata;
+	struct dm_config_node *md_cn;
+	struct dm_config_node *lv_cn;
+	struct lockspace *ls, *safe;
+	struct resource *r;
+	const char *vg_name;
+	const char *vg_uuid;
+	const char *lv_uuid;
+	const char *lock_type;
+	const char *lock_args;
+	char find_str_path[PATH_MAX];
+	int mutex_unlocked = 0;
+	int rv = 0;
+
+	INIT_LIST_HEAD(&update_vgs);
+
+	pthread_mutex_lock(&lvmetad_mutex);
+	reply = daemon_send_simple(lvmetad_handle, "vg_list",
+				   "token = %s", "skip",
+				   NULL);
+
+	if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
+		log_error("vg_list from lvmetad failed %d", reply.error);
+		rv = -EINVAL;
+		goto destroy;
+	}
+
+	if (!(cn = dm_config_find_node(reply.cft->root, "volume_groups"))) {
+		log_error("get_lockd_vgs no vgs");
+		rv = -EINVAL;
+		goto destroy;
+	}
+
+	/* create an update_vgs list of all vg uuids */
+
+	for (cn = cn->child; cn; cn = cn->sib) {
+		vg_uuid = cn->key;
+
+		if (!(ls = alloc_lockspace())) {
+			rv = -ENOMEM;
+			break;
+		}
+
+		strncpy(ls->vg_uuid, vg_uuid, 64);
+		list_add_tail(&ls->list, &update_vgs);
+		log_debug("get_lockd_vgs %s", vg_uuid);
+	}
+ destroy:
+	daemon_reply_destroy(reply);
+
+	if (rv < 0)
+		goto out;
+
+	/* get vg_name and lock_type for each vg uuid entry in update_vgs */
+
+	list_for_each_entry(ls, &update_vgs, list) {
+		reply = daemon_send_simple(lvmetad_handle, "vg_lookup",
+					   "token = %s", "skip",
+					   "uuid = %s", ls->vg_uuid,
+					   NULL);
+
+		if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
+			log_error("vg_lookup from lvmetad failed %d", reply.error);
+			rv = -EINVAL;
+			goto next;
+		}
+
+		vg_name = daemon_reply_str(reply, "name", NULL);
+		if (!vg_name) {
+			log_error("get_lockd_vgs %s no name", ls->vg_uuid);
+			rv = -EINVAL;
+			goto next;
+		}
+
+		strncpy(ls->vg_name, vg_name, MAX_NAME);
+
+		metadata = dm_config_find_node(reply.cft->root, "metadata");
+		if (!metadata) {
+			log_error("get_lockd_vgs %s name %s no metadata",
+				  ls->vg_uuid, ls->vg_name);
+			rv = -EINVAL;
+			goto next;
+		}
+
+		lock_type = dm_config_find_str(metadata, "metadata/lock_type", NULL);
+		ls->lm_type = str_to_lm(lock_type);
+
+		if ((ls->lm_type != LD_LM_SANLOCK) && (ls->lm_type != LD_LM_DLM)) {
+			log_debug("get_lockd_vgs %s not lockd type", ls->vg_name);
+			continue;
+		}
+
+		lock_args = dm_config_find_str(metadata, "metadata/lock_args", NULL);
+		if (lock_args)
+			strncpy(ls->vg_args, lock_args, MAX_ARGS);
+
+		log_debug("get_lockd_vgs %s lock_type %s lock_args %s",
+			  ls->vg_name, lock_type, lock_args ?: "none");
+
+		/*
+		 * Make a record (struct resource) of each lv that uses a lock.
+		 * For any lv that uses a lock, we'll check if the lv is active
+		 * and if so try to adopt a lock for it.
+		 */
+
+		for (md_cn = metadata->child; md_cn; md_cn = md_cn->sib) {
+			if (strcmp(md_cn->key, "logical_volumes"))
+				continue;
+
+			for (lv_cn = md_cn->child; lv_cn; lv_cn = lv_cn->sib) {
+				snprintf(find_str_path, PATH_MAX, "%s/lock_type", lv_cn->key);
+				lock_type = dm_config_find_str(lv_cn, find_str_path, NULL);
+
+				if (!lock_type)
+					continue;
+
+				snprintf(find_str_path, PATH_MAX, "%s/lock_args", lv_cn->key);
+				lock_args = dm_config_find_str(lv_cn, find_str_path, NULL);
+
+				snprintf(find_str_path, PATH_MAX, "%s/id", lv_cn->key);
+				lv_uuid = dm_config_find_str(lv_cn, find_str_path, NULL);
+
+				if (!lv_uuid) {
+					log_error("get_lock_vgs no lv id for name %s", lv_cn->key);
+					continue;
+				}
+
+				if (!(r = alloc_resource())) {
+					rv = -ENOMEM;
+					goto next;
+				}
+
+				r->type = LD_RT_LV;
+				strncpy(r->name, lv_uuid, MAX_NAME);
+				if (lock_args)
+					strncpy(r->lv_args, lock_args, MAX_ARGS);
+				list_add_tail(&r->list, &ls->resources);
+				log_debug("get_lockd_vgs %s lv %s %s (name %s)",
+					  ls->vg_name, r->name, lock_args ? lock_args : "", lv_cn->key);
+			}
+		}
+ next:
+		daemon_reply_destroy(reply);
+
+		if (rv < 0)
+			break;
+	}
+	pthread_mutex_unlock(&lvmetad_mutex);
+	mutex_unlocked = 1;
+out:
+	/* Return lockd VG's on the vg_lockd list. */
+
+	list_for_each_entry_safe(ls, safe, &update_vgs, list) {
+		list_del(&ls->list);
+
+		if ((ls->lm_type == LD_LM_SANLOCK) || (ls->lm_type == LD_LM_DLM))
+			list_add_tail(&ls->list, vg_lockd);
+		else
+			free(ls);
+	}
+
+	if (!mutex_unlocked)
+		pthread_mutex_unlock(&lvmetad_mutex);
+
+	return rv;
+}
+
+static char _dm_uuid[64];
+
+static char *get_dm_uuid(char *dm_name)
+{
+	struct dm_info info;
+	struct dm_task *dmt;
+	const char *uuid;
+
+	if (!(dmt = dm_task_create(DM_DEVICE_INFO)))
+		goto fail_out;
+
+	if (!dm_task_set_name(dmt, dm_name))
+		goto fail;
+
+	if (!dm_task_run(dmt))
+		goto fail;
+
+	if (!dm_task_get_info(dmt, &info))
+		goto fail;
+
+	if (!info.exists)
+		goto fail;
+
+	uuid = dm_task_get_uuid(dmt);
+	if (!uuid) {
+		log_error("Failed to get uuid for device %s", dm_name);
+		goto fail;
+	}
+
+	if (strncmp(uuid, "LVM", 3)) {
+		log_debug("dm device %s is not from LVM", dm_name);
+		goto fail;
+	}
+
+	memset(_dm_uuid, 0, sizeof(_dm_uuid));
+	strcpy(_dm_uuid, uuid);
+	dm_task_destroy(dmt);
+	return _dm_uuid;
+
+fail:
+	dm_task_destroy(dmt);
+fail_out:
+	return NULL;
+}
+
+/*
+ * dm reports the LV uuid as:
+ * LVM-ydpRIdDWBDX25upmj2k0D4deat6oxH8er03T0f4xM8rPIV8XqIhwv3h8Y7xRWjMr
+ *
+ * the lock name for the LV is:
+ * r03T0f-4xM8-rPIV-8XqI-hwv3-h8Y7-xRWjMr
+ *
+ * This function formats both as:
+ * r03T0f4xM8rPIV8XqIhwv3h8Y7xRWjMr
+ *
+ * and returns 1 if they match.
+ */
+
+static int match_dm_uuid(char *dm_uuid, char *lv_lock_uuid)
+{
+	char buf1[64];
+	char buf2[64];
+	int i, j;
+
+	memset(buf1, 0, sizeof(buf1));
+	memset(buf2, 0, sizeof(buf2));
+
+	for (i = 0, j = 0; i < strlen(lv_lock_uuid); i++) {
+		if (lv_lock_uuid[i] == '-')
+			continue;
+		buf1[j] = lv_lock_uuid[i];
+		j++;
+	}
+
+	for (i = 36, j = 0; i < 69; i++) {
+		buf2[j] = dm_uuid[i];
+		j++;
+	}
+
+	if (!strcmp(buf1, buf2))
+		return 1;
+	return 0;
+}
+
+/*
+ * All LVs with a lock_type are on ls->resources.
+ * Remove any that are not active.  The remaining
+ * will have locks adopted.
+ */
+
+static int remove_inactive_lvs(struct list_head *vg_lockd)
+{
+	struct lockspace *ls;
+	struct resource *r, *rsafe;
+	struct dm_names *names;
+	struct dm_task *dmt;
+	char *dm_uuid;
+	char *vgname, *lvname, *layer;
+	char namebuf[MAX_NAME+1];
+	unsigned next = 0;
+	int rv = 0;
+
+	if (!(dmt = dm_task_create(DM_DEVICE_LIST)))
+		return -1;
+
+	if (!dm_task_run(dmt)) {
+		log_error("Failed to get dm devices");
+		rv = -1;
+		goto ret;
+	}
+
+	if (!(names = dm_task_get_names(dmt))) {
+		log_error("Failed to get dm names");
+		rv = -1;
+		goto ret;
+	}
+
+	if (!names->dev) {
+		log_debug("dm names none found");
+		goto out;
+	}
+
+	/*
+	 * For each dm name, compare it to each lv in each lockd vg.
+	 */
+
+	do {
+		names = (struct dm_names *)((char *) names + next);
+
+		dm_uuid = get_dm_uuid(names->name);
+		if (!dm_uuid)
+			goto next_dmname;
+
+		vgname = NULL;
+		lvname = NULL;
+		layer = NULL;
+
+		memset(namebuf, 0, sizeof(namebuf));
+		strncpy(namebuf, names->name, MAX_NAME);
+		vgname = namebuf;
+
+		dm_split_lvm_name(NULL, NULL, &vgname, &lvname, &layer);
+
+		log_debug("adopt remove_inactive dm name %s dm uuid %s vgname %s lvname %s",
+			  names->name, dm_uuid, vgname, lvname);
+
+		if (!vgname || !lvname) {
+			log_debug("dm name %s invalid split vg %s lv %s layer %s",
+				  names->name, vgname ? vgname : "", lvname ? lvname : "", layer ? layer : "");
+			goto next_dmname;
+		}
+
+		list_for_each_entry(ls, vg_lockd, list) {
+			if (strcmp(vgname, ls->vg_name))
+				continue;
+
+			if (!strcmp(lvname, "lvmlock"))
+				continue;
+
+			list_for_each_entry(r, &ls->resources, list) {
+				if (!match_dm_uuid(dm_uuid, r->name))
+					continue;
+
+				/* Found an active LV in a lockd VG. */
+				log_debug("dm device %s adopt in vg %s lv %s",
+					  names->name, ls->vg_name, r->name);
+				r->adopt = 1;
+				goto next_dmname;
+			}
+		}
+next_dmname:
+		next = names->next;
+	} while (next);
+
+out:
+	/* Remove any struct resources that do not need locks adopted. */
+	list_for_each_entry(ls, vg_lockd, list) {
+		list_for_each_entry_safe(r, rsafe, &ls->resources, list) {
+			if (r->adopt) {
+				r->adopt = 0;
+			} else {
+				log_debug("lockd vg %s remove inactive lv %s", ls->vg_name, r->name);
+				list_del(&r->list);
+				free_resource(r);
+			}
+		}
+	}
+ret:
+	dm_task_destroy(dmt);
+	return rv;
+}
+
+static void adopt_locks(void)
+{
+	struct list_head ls_found;
+	struct list_head vg_lockd;
+	struct list_head to_unlock;
+	struct lockspace *ls, *lsafe;
+	struct lockspace *ls1, *l1safe;
+	struct lockspace *ls2, *l2safe;
+	struct resource *r, *rsafe;
+	struct action *act, *asafe;
+	int count_start = 0, count_start_done = 0, count_start_fail = 0;
+	int count_adopt = 0, count_adopt_done = 0, count_adopt_fail = 0;
+	int found, rv;
+
+	INIT_LIST_HEAD(&adopt_results);
+
+	INIT_LIST_HEAD(&ls_found);
+	INIT_LIST_HEAD(&vg_lockd);
+	INIT_LIST_HEAD(&to_unlock);
+
+	/*
+	 * Get list of lockspaces from lock managers.
+	 * Get list of VGs from lvmetad with a lockd type.
+	 * Get list of active lockd type LVs from /dev.
+	 *
+	 * ECONNREFUSED means the lock manager is not running.
+	 * This is expected for at least one of them.
+	 */
+
+	rv = lm_get_lockspaces_dlm(&ls_found);
+	if ((rv < 0) && (rv != -ECONNREFUSED))
+		goto fail;
+
+	rv = lm_get_lockspaces_sanlock(&ls_found);
+	if ((rv < 0) && (rv != -ECONNREFUSED))
+		goto fail;
+
+	if (list_empty(&ls_found)) {
+		log_debug("No lockspaces found to adopt");
+		return;
+	}
+
+	/*
+	 * Adds a struct lockspace to vg_lockd for each lockd VG.
+	 * Adds a struct resource to ls->resources for each LV.
+	 */
+	rv = get_lockd_vgs(&vg_lockd);
+	if (rv < 0) {
+		log_error("adopt_locks get_lockd_vgs failed");
+		goto fail;
+	}
+
+	/*
+	 * For each resource on each lockspace, check if the
+	 * corresponding LV is active.  If so, leave the
+	 * resource struct, if not free the resource struct.
+	 * The remain entries need to have locks adopted.
+	 */
+	rv = remove_inactive_lvs(&vg_lockd);
+	if (rv < 0) {
+		log_error("adopt_locks remove_inactive_lvs failed");
+		goto fail;
+	}
+
+	list_for_each_entry(ls, &ls_found, list) {
+		if (ls->lm_type == LD_LM_DLM)
+			gl_use_dlm = 1;
+
+		log_debug("adopt %s lockspace %s vg %s",
+			  lm_str(ls->lm_type), ls->name, ls->vg_name);
+	}
+
+	if (!gl_use_dlm)
+		gl_use_sanlock = 1;
+
+	list_for_each_entry(ls, &vg_lockd, list) {
+		log_debug("adopt lvmetad vg %s lock_type %s lock_args %s",
+			  ls->vg_name, lm_str(ls->lm_type), ls->vg_args);
+
+		list_for_each_entry(r, &ls->resources, list)
+			log_debug("adopt lv %s %s", ls->vg_name, r->name);
+	}
+
+	/*
+	 * Compare and merge the list of lockspaces in ls_found
+	 * and the list of lockd VGs in vg_lockd.
+	 *
+	 * An ls from ls_found may not have had any active lvs when
+	 * previous lvmlockd died, but the ls should still be joined,
+	 * and checked for GL/VG locks.
+	 *
+	 * An ls from vg_lockd with active lvs should be in ls_found.
+	 * If it's not then we might want to join the ls and acquire locks
+	 * for the active lvs (as opposed to adopting orphans for them.)
+	 * The orphan lock in the ls should have prevented the ls in
+	 * the lock manager from going away.
+	 *
+	 * If an ls in vg_lockd has no active lvs and does not have
+	 * a matching entry in ls_found, then skip it.
+	 * 
+	 * An ls in ls_found should always have a matching ls in
+	 * vg_lockd.  If it doesn't, then maybe the vg has been
+	 * removed even though the lockspace for the vg is still
+	 * in the lock manager.  Just leave the ls in the lm
+	 * alone, and skip the ls_found entry.
+	 */
+
+	list_for_each_entry_safe(ls1, l1safe, &ls_found, list) {
+
+		/* The dlm global lockspace is special and doesn't match a VG. */
+		if (!strcmp(ls1->name, gl_lsname_dlm)) {
+			list_del(&ls1->list);
+			free(ls1);
+			continue;
+		}
+
+		found = 0;
+
+		list_for_each_entry_safe(ls2, l2safe, &vg_lockd, list) {
+			if (strcmp(ls1->vg_name, ls2->vg_name))
+				continue;
+
+			/*
+		 	 * LS in both ls_found and vg_lockd.
+		 	 */
+			log_debug("ls %s matches vg %s", ls1->name, ls2->vg_name);
+			memcpy(ls1->vg_uuid, ls2->vg_uuid, 64);
+			memcpy(ls1->vg_args, ls2->vg_args, MAX_ARGS);
+			list_for_each_entry_safe(r, rsafe, &ls2->resources, list) {
+				list_del(&r->list);
+				list_add(&r->list, &ls1->resources);
+			}
+			list_del(&ls2->list);
+			free(ls2);
+			found = 1;
+			break;
+		}
+
+		/*
+		 * LS in ls_found, not in vg_lockd.
+		 * An lvm lockspace found in the lock manager has no
+		 * corresponding VG in lvmetad.  This shouldn't usually
+		 * happen, but it's possible the VG could have been removed
+		 * while the orphaned lockspace from it was still around.
+		 * Report an error and leave the ls in the lm alone.
+		 */
+		if (!found) {
+			log_error("No VG %s found for lockspace %s %s",
+				  ls1->vg_name, ls1->name, lm_str(ls1->lm_type));
+			list_del(&ls1->list);
+			free(ls1);
+		}
+	}
+
+	/*
+	 * LS in vg_lockd, not in ls_found.
+	 * lockd vgs from lvmetad that do not have an existing lockspace.
+	 * This wouldn't be unusual; we just skip the vg.
+	 * But, if the vg has active lvs, then it should have had locks
+	 * and a lockspace.  Should we attempt to join the lockspace and
+	 * acquire (not adopt) locks for these LVs?
+	 */
+
+	list_for_each_entry_safe(ls, lsafe, &vg_lockd, list) {
+		if (!list_empty(&ls->resources)) {
+			/* We should have found a lockspace. */
+			/* add this ls and acquire locks for ls->resources? */
+			log_error("No lockspace %s %s found for VG %s with active LVs",
+				  ls->name, lm_str(ls->lm_type), ls->vg_name);
+		} else {
+			/* The VG wasn't started in the previous lvmlockd. */
+			log_debug("No ls found for vg %s", ls->vg_name);
+		}
+		
+		list_del(&ls->list);
+		free(ls);
+	}
+
+	/*
+	 * Create and queue start actions to add lockspaces.
+	 */
+
+	if (gl_use_dlm) {
+		if (!(act = alloc_action()))
+			goto fail;
+		log_debug("adopt add dlm global lockspace");
+		act->op = LD_OP_START;
+		act->flags = (LD_AF_ADOPT | LD_AF_WAIT);
+		act->rt = LD_RT_GL;
+		act->lm_type = LD_LM_DLM;
+		act->client_id = ADOPT_CLIENT_ID;
+		add_dlm_global_lockspace(act);
+		count_start++;
+	}
+
+	list_for_each_entry_safe(ls, lsafe, &ls_found, list) {
+		if (!(act = alloc_action()))
+			goto fail;
+		act->op = LD_OP_START;
+		act->flags = (LD_AF_ADOPT | LD_AF_WAIT);
+		act->rt = LD_RT_VG;
+		act->lm_type = ls->lm_type;
+		act->client_id = ADOPT_CLIENT_ID;
+		strncpy(act->vg_name, ls->vg_name, MAX_NAME);
+		memcpy(act->vg_uuid, ls->vg_uuid, 64);
+		memcpy(act->vg_args, ls->vg_args, MAX_ARGS);
+		act->host_id = ls->host_id;
+
+		/* set act->version from lvmetad data? */
+
+		log_debug("adopt add %s vg lockspace %s", lm_str(act->lm_type), act->vg_name);
+
+		rv = add_lockspace_thread(ls->name, act->vg_name, act->vg_uuid,
+					  act->lm_type, act->vg_args, act);
+		if (rv < 0) {
+			log_error("Failed to create lockspace thread for VG %s", ls->vg_name);
+			list_del(&ls->list);
+			free(ls);
+			free_action(act);
+			count_start_fail++;
+			continue;
+		}
+
+		/*
+		 * When the lockspace_thread is done with the start act,
+		 * it will see the act ADOPT flag and move the act onto
+		 * the adopt_results list for us to collect below.
+		 */
+		count_start++;
+	}
+
+	log_debug("adopt starting %d lockspaces", count_start);
+
+	/*
+	 * Wait for all start/rejoin actions to complete.  Each start action
+	 * queued above will appear on the adopt_results list when finished.
+	 */
+
+	while (count_start_done < count_start) {
+		sleep(1);
+		act = NULL;
+
+		pthread_mutex_lock(&client_mutex);
+		if (!list_empty(&adopt_results)) {
+			act = list_first_entry(&adopt_results, struct action, list);
+			list_del(&act->list);
+		}
+		pthread_mutex_unlock(&client_mutex);
+
+		if (!act)
+			continue;
+
+		if (act->result < 0) {
+			log_error("adopt add lockspace failed vg %s %d", act->vg_name, act->result);
+			count_start_fail++;
+		}
+
+		free_action(act);
+		count_start_done++;
+	}
+
+	log_debug("adopt started %d lockspaces done %d fail %d",
+		  count_start, count_start_done, count_start_fail);
+
+	/*
+	 * Create lock-adopt actions for active LVs (ls->resources),
+	 * and GL/VG locks (we don't know if these locks were held
+	 * and orphaned by the last lvmlockd, so try to adopt them
+	 * to see.)
+	 *
+	 * A proper struct lockspace now exists on the lockspaces list
+	 * for each ls in ls_found.  Lock ops for one of those
+	 * lockspaces can be done as OP_LOCK actions queued using
+	 * add_lock_action();
+	 *
+	 * Start by attempting to adopt the lock in the most likely
+	 * mode it was left in (ex for lvs, sh for vg/gl).  If
+	 * the mode is wrong, the lm will return an error and we
+	 * try again with the other mode.
+	 */
+
+	list_for_each_entry(ls, &ls_found, list) {
+
+		/*
+		 * Adopt orphan LV locks.
+		 */
+
+		list_for_each_entry(r, &ls->resources, list) {
+			if (!(act = alloc_action()))
+				goto fail;
+			act->op = LD_OP_LOCK;
+			act->rt = LD_RT_LV;
+			act->mode = LD_LK_EX;
+			act->flags = (LD_AF_ADOPT | LD_AF_PERSISTENT);
+			act->client_id = ADOPT_CLIENT_ID;
+			act->lm_type = ls->lm_type;
+			strncpy(act->vg_name, ls->vg_name, MAX_NAME);
+			strncpy(act->lv_uuid, r->name, MAX_NAME);
+			strncpy(act->lv_args, r->lv_args, MAX_ARGS);
+
+			log_debug("adopt lock for lv %s %s", act->vg_name, act->lv_uuid);
+
+			rv = add_lock_action(act);
+			if (rv < 0) {
+				log_error("adopt add_lock_action lv %s %s error %d", act->vg_name, act->lv_uuid, rv);
+				count_adopt_fail++;
+				free_action(act);
+			} else {
+				count_adopt++;
+			}
+		}
+
+		/*
+		 * Adopt orphan VG lock.
+		 */
+
+		if (!(act = alloc_action()))
+			goto fail;
+		act->op = LD_OP_LOCK;
+		act->rt = LD_RT_VG;
+		act->mode = LD_LK_SH;
+		act->flags = LD_AF_ADOPT;
+		act->client_id = ADOPT_CLIENT_ID;
+		act->lm_type = ls->lm_type;
+		strncpy(act->vg_name, ls->vg_name, MAX_NAME);
+
+		log_debug("adopt lock for vg %s", act->vg_name);
+
+		rv = add_lock_action(act);
+		if (rv < 0) {
+			log_error("adopt add_lock_action vg %s error %d", act->vg_name, rv);
+			count_adopt_fail++;
+			free_action(act);
+		} else {
+			count_adopt++;
+		}
+	}
+
+	/*
+	 * Adopt orphan GL lock.
+	 */
+
+	if (!(act = alloc_action()))
+		goto fail;
+	act->op = LD_OP_LOCK;
+	act->rt = LD_RT_GL;
+	act->mode = LD_LK_SH;
+	act->flags = LD_AF_ADOPT;
+	act->client_id = ADOPT_CLIENT_ID;
+	act->lm_type = (gl_use_sanlock ? LD_LM_SANLOCK : LD_LM_DLM);
+
+	log_debug("adopt lock for gl");
+
+	rv = add_lock_action(act);
+	if (rv < 0) {
+		log_error("adopt add_lock_action gl %s error %d", act->vg_name, rv);
+		count_adopt_fail++;
+		free_action(act);
+	} else {
+		count_adopt++;
+	}
+
+	/*
+	 * Wait for lock-adopt actions to complete.  The completed
+	 * actions are passed back here via the adopt_results list.
+	 */
+
+	while (count_adopt_done < count_adopt) {
+		sleep(1);
+		act = NULL;
+
+		pthread_mutex_lock(&client_mutex);
+		if (!list_empty(&adopt_results)) {
+			act = list_first_entry(&adopt_results, struct action, list);
+			list_del(&act->list);
+		}
+		pthread_mutex_unlock(&client_mutex);
+
+		if (!act)
+			continue;
+
+		/*
+		 * lock adopt results 
+		 */
+
+		if (act->result == -EUCLEAN) {
+			/*
+			 * Adopt failed because the orphan has a different mode
+			 * than initially requested.  Repeat the lock-adopt operation
+			 * with the other mode.  N.B. this logic depends on first
+			 * trying sh then ex for GL/VG locks, and ex then sh for
+			 * LV locks.
+			 */
+
+			if ((act->rt != LD_RT_LV) && (act->mode == LD_LK_SH)) {
+				/* GL/VG locks: attempt to adopt ex after sh failed. */
+				act->mode = LD_LK_EX;
+				rv = add_lock_action(act);
+
+			} else if ((act->rt == LD_RT_LV) && (act->mode == LD_LK_EX)) {
+				/* LV locks: attempt to adopt sh after ex failed. */
+				act->mode = LD_LK_SH;
+				rv = add_lock_action(act);
+
+			} else {
+				log_error("Failed to adopt %s lock in vg %s error %d",
+					  rt_str(act->rt), act->vg_name, act->result);
+				count_adopt_fail++;
+				count_adopt_done++;
+				free_action(act);
+				rv = 0;
+			}
+
+			if (rv < 0) {
+				log_error("adopt add_lock_action again %s", act->vg_name);
+				count_adopt_fail++;
+				count_adopt_done++;
+				free_action(act);
+			}
+
+		} else if (act->result == -ENOENT) {
+			/*
+			 * No orphan lock exists.  This is common for GL/VG locks
+			 * because they may not have been held when lvmlockd exited.
+			 * It's also expected for LV types that do not use a lock.
+			 */
+
+			if (act->rt == LD_RT_LV) {
+				/* Unexpected, we should have found an orphan. */
+				log_error("Failed to adopt LV lock for %s %s error %d",
+					  act->vg_name, act->lv_uuid, act->result);
+				count_adopt_fail++;
+			} else {
+				/* Normal, no GL/VG lock was orphaned. */
+				log_debug("Did not adopt %s lock in vg %s error %d",
+					   rt_str(act->rt), act->vg_name, act->result);
+			}
+
+			count_adopt_done++;
+			free_action(act);
+
+		} else if (act->result < 0) {
+			/*
+			 * Some unexpected error.
+			 */
+
+			log_error("adopt lock rt %s vg %s lv %s error %d",
+				  rt_str(act->rt), act->vg_name, act->lv_uuid, act->result);
+			count_adopt_fail++;
+			count_adopt_done++;
+			free_action(act);
+
+		} else {
+			/*
+			 * Adopt success.
+			 */
+
+			if (act->rt == LD_RT_LV) {
+				log_debug("adopt success lv %s %s %s", act->vg_name, act->lv_uuid, mode_str(act->mode));
+				free_action(act);
+			} else if (act->rt == LD_RT_VG) {
+				log_debug("adopt success vg %s %s", act->vg_name, mode_str(act->mode));
+				list_add_tail(&act->list, &to_unlock);
+			} else if (act->rt == LD_RT_GL) {
+				log_debug("adopt success gl %s %s", act->vg_name, mode_str(act->mode));
+				list_add_tail(&act->list, &to_unlock);
+			}
+			count_adopt_done++;
+		}
+	}
+
+	/*
+	 * Release adopted GL/VG locks.
+	 * The to_unlock actions were the ones used to lock-adopt the GL/VG locks;
+	 * now use them to do the unlocks.  These actions will again be placed
+	 * on adopt_results for us to collect because they have the ADOPT flag set.
+	 */
+
+	count_adopt = 0;
+	count_adopt_done = 0;
+
+	list_for_each_entry_safe(act, asafe, &to_unlock, list) {
+		list_del(&act->list);
+
+		if (act->mode == LD_LK_EX) {
+			/*
+			 * FIXME: we probably want to check somehow that
+			 * there's no lvm command still running that's
+			 * using this ex lock and changing things.
+			 */
+			log_warn("adopt releasing ex %s lock %s",
+				 rt_str(act->rt), act->vg_name);
+		}
+
+		act->mode = LD_LK_UN;
+
+		log_debug("adopt unlock for %s %s", rt_str(act->rt), act->vg_name);
+
+		rv = add_lock_action(act);
+		if (rv < 0) {
+			log_error("adopt unlock add_lock_action error %d", rv);
+			free_action(act);
+		} else {
+			count_adopt++;
+		}
+	}
+
+	/* Wait for the unlocks to complete. */
+
+	while (count_adopt_done < count_adopt) {
+		sleep(1);
+		act = NULL;
+
+		pthread_mutex_lock(&client_mutex);
+		if (!list_empty(&adopt_results)) {
+			act = list_first_entry(&adopt_results, struct action, list);
+			list_del(&act->list);
+		}
+		pthread_mutex_unlock(&client_mutex);
+
+		if (!act)
+			continue;
+
+		if (act->result < 0)
+			log_error("adopt unlock error %d", act->result);
+
+		count_adopt_done++;
+		free_action(act);
+	}
+
+
+	/* FIXME: purge any remaining orphan locks in each rejoined ls? */
+
+	if (count_start_fail || count_adopt_fail)
+		goto fail;
+
+	log_debug("adopt_locks done");
+	return;
+
+fail:
+	log_error("adopt_locks failed, reset host");
+}
+
+static int get_peer_pid(int fd)
+{
+	struct ucred cred;
+	unsigned int len = sizeof(cred);
+
+	if (getsockopt(fd, SOL_SOCKET, SO_PEERCRED, &cred, &len) != 0)
+		return -1;
+
+	return cred.pid;
+}
+
+static void process_listener(int poll_fd)
+{
+	struct client *cl;
+	int fd, pi;
+
+	/* assert poll_fd == listen_fd */
+
+	fd = accept(listen_fd, NULL, NULL);
+	if (fd < 0)
+		return;
+
+	if (!(cl = alloc_client()))
+		return;
+
+	pi = add_pollfd(fd);
+	if (pi < 0) {
+		log_error("process_listener add_pollfd error %d", pi);
+		free_client(cl);
+		return;
+	}
+
+	cl->pi = pi;
+	cl->fd = fd;
+	cl->pid = get_peer_pid(fd);
+
+	pthread_mutex_init(&cl->mutex, NULL);
+
+	pthread_mutex_lock(&client_mutex);
+	client_ids++;
+
+	if (client_ids == ADOPT_CLIENT_ID)
+		client_ids++;
+	if (!client_ids)
+		client_ids++;
+
+	cl->id = client_ids;
+	list_add_tail(&cl->list, &client_list);
+	pthread_mutex_unlock(&client_mutex);
+
+	log_debug("client add id %d pi %d fd %d", cl->id, cl->pi, cl->fd);
+}
+
+/*
+ * main loop polls on pipe[0] so that a thread can
+ * restart the poll by writing to pipe[1].
+ */
+static int setup_restart(void)
+{
+	if (pipe(restart_fds)) {
+		log_error("setup_restart pipe error %d", errno);
+		return -1;
+	}
+
+	restart_pi = add_pollfd(restart_fds[0]);
+	if (restart_pi < 0)
+		return restart_pi;
+
+	return 0;
+}
+
+/*
+ * thread wrote 'w' to restart_fds[1] to restart poll()
+ * after adding an fd back into pollfd.
+ */
+static void process_restart(int fd)
+{
+	char wake[1];
+	int rv;
+
+	/* assert fd == restart_fds[0] */
+
+	rv = read(restart_fds[0], wake, 1);
+	if (!rv || rv < 0)
+		log_debug("process_restart error %d", errno);
+}
+
+static void sigterm_handler(int sig __attribute__((unused)))
+{
+	daemon_quit = 1;
+}
+
+static int main_loop(daemon_state *ds_arg)
+{
+	struct client *cl;
+	int i, rv, is_recv, is_dead;
+
+	signal(SIGTERM, &sigterm_handler);
+
+	rv = setup_structs();
+	if (rv < 0) {
+		log_error("Can't allocate memory");
+		return rv;
+	}
+
+	strcpy(gl_lsname_dlm, S_NAME_GL_DLM);
+
+	INIT_LIST_HEAD(&lockspaces);
+	INIT_LIST_HEAD(&lockspaces_inactive);
+	pthread_mutex_init(&lockspaces_mutex, NULL);
+	pthread_mutex_init(&pollfd_mutex, NULL);
+	pthread_mutex_init(&log_mutex, NULL);
+
+	openlog("lvmlockd", LOG_CONS | LOG_PID, LOG_DAEMON);
+	log_warn("lvmlockd started");
+
+	listen_fd = ds_arg->socket_fd;
+	listen_pi = add_pollfd(listen_fd);
+
+	setup_client_thread();
+	setup_worker_thread();
+	setup_restart();
+
+	pthread_mutex_init(&lvmetad_mutex, NULL);
+	lvmetad_handle = lvmetad_open(NULL);
+	if (lvmetad_handle.error || lvmetad_handle.socket_fd < 0)
+		log_error("lvmetad_open error %d", lvmetad_handle.error);
+	else
+		lvmetad_connected = 1;
+
+	/*
+	 * Attempt to rejoin lockspaces and adopt locks from a previous
+	 * instance of lvmlockd that left behind lockspaces/locks.
+	 */
+	if (adopt_opt)
+		adopt_locks();
+
+	while (1) {
+		rv = poll(pollfd, pollfd_maxi + 1, -1);
+		if (rv == -1 && errno == EINTR) {
+			if (daemon_quit) {
+				int count;
+				/* first sigterm would trigger stops, and
+				   second sigterm may finish the joins. */
+				count = for_each_lockspace(DO_STOP, DO_FREE, NO_FORCE);
+				if (!count)
+					break;
+				log_debug("ignore shutdown for %d lockspaces", count);
+				daemon_quit = 0;
+			}
+			continue;
+		}
+		if (rv < 0) {
+			log_error("poll errno %d", errno);
+			break;
+		}
+
+		for (i = 0; i <= pollfd_maxi; i++) {
+			if (pollfd[i].fd < 0)
+				continue;
+
+			is_recv = 0;
+			is_dead = 0;
+
+			if (pollfd[i].revents & POLLIN)
+				is_recv = 1;
+			if (pollfd[i].revents & (POLLERR | POLLHUP | POLLNVAL))
+				is_dead = 1;
+
+			if (!is_recv && !is_dead)
+				continue;
+
+			if (i == listen_pi) {
+				process_listener(pollfd[i].fd);
+				continue;
+			}
+
+			if (i == restart_pi) {
+				process_restart(pollfd[i].fd);
+				continue;
+			}
+
+			/*
+			log_debug("poll pi %d fd %d revents %x",
+				  i, pollfd[i].fd, pollfd[i].revents);
+			*/
+
+			pthread_mutex_lock(&client_mutex);
+			cl = find_client_pi(i);
+			if (cl) {
+				pthread_mutex_lock(&cl->mutex);
+
+				if (cl->recv) {
+					/* should not happen */
+					log_error("main client %d already recv", cl->id);
+
+				} else if (cl->dead) {
+					/* should not happen */
+					log_error("main client %d already dead", cl->id);
+
+				} else if (is_dead) {
+					log_debug("close %s[%d.%u] fd %d",
+						  cl->name[0] ? cl->name : "client",
+						  cl->pid, cl->id, cl->fd);
+					cl->dead = 1;
+					cl->pi = -1;
+					cl->fd = -1;
+					cl->poll_ignore = 0;
+					close(pollfd[i].fd);
+					pollfd[i].fd = POLL_FD_UNUSED;
+					pollfd[i].events = 0;
+					pollfd[i].revents = 0;
+
+				} else if (is_recv) {
+					cl->recv = 1;
+					cl->poll_ignore = 1;
+					pollfd[i].fd = POLL_FD_IGNORE;
+					pollfd[i].events = 0;
+					pollfd[i].revents = 0;
+				}
+
+				pthread_mutex_unlock(&cl->mutex);
+
+				client_work = 1;
+				pthread_cond_signal(&client_cond);
+
+				/* client_thread will pick up and work on any
+				   client with cl->recv or cl->dead set */
+
+			} else {
+				/* don't think this can happen */
+				log_error("no client for index %d fd %d",
+					  i, pollfd[i].fd);
+				close(pollfd[i].fd);
+				pollfd[i].fd = POLL_FD_UNUSED;
+				pollfd[i].events = 0;
+				pollfd[i].revents = 0;
+			}
+			pthread_mutex_unlock(&client_mutex);
+
+			/* After set_dead, should we scan pollfd for
+			   last unused slot and reduce pollfd_maxi? */
+		}
+	}
+
+	for_each_lockspace_retry(DO_STOP, DO_FREE, DO_FORCE);
+	free_lockspaces_inactive();
+	close_worker_thread();
+	close_client_thread();
+	closelog();
+	daemon_close(lvmetad_handle);
+	return 0;
+}
+
+static void usage(char *prog, FILE *file)
+{
+	fprintf(file, "Usage:\n");
+	fprintf(file, "%s [options]\n\n", prog);
+	fprintf(file, "  --help | -h\n");
+	fprintf(file, "        Show this help information.\n");
+	fprintf(file, "  --version | -V\n");
+	fprintf(file, "        Show version of lvmlockd.\n");
+	fprintf(file, "  --test | -T\n");
+	fprintf(file, "        Test mode, do not call lock manager.\n");
+	fprintf(file, "  --foreground | -f\n");
+	fprintf(file, "        Don't fork.\n");
+	fprintf(file, "  --daemon-debug | -D\n");
+	fprintf(file, "        Don't fork and print debugging to stdout.\n");
+	fprintf(file, "  --pid-file | -p <path>\n");
+	fprintf(file, "        Set path to the pid file. [%s]\n", LVMLOCKD_PIDFILE);
+	fprintf(file, "  --socket-path | -s <path>\n");
+	fprintf(file, "        Set path to the socket to listen on. [%s]\n", LVMLOCKD_SOCKET);
+	fprintf(file, "  --syslog-priority | -S err|warning|debug\n");
+	fprintf(file, "        Write log messages from this level up to syslog. [%s]\n", _syslog_num_to_name(LOG_SYSLOG_PRIO));
+	fprintf(file, "  --gl-type | -g <str>\n");
+	fprintf(file, "        Set global lock type to be dlm|sanlock.\n");
+	fprintf(file, "  --host-id | -i <num>\n");
+	fprintf(file, "        Set the local sanlock host id.\n");
+	fprintf(file, "  --host-id-file | -F <path>\n");
+	fprintf(file, "        A file containing the local sanlock host_id.\n");
+	fprintf(file, "  --sanlock-timeout | -o <seconds>\n");
+	fprintf(file, "        Set the sanlock lockspace I/O timeout.\n");
+	fprintf(file, "  --adopt | -A 0|1\n");
+	fprintf(file, "        Adopt locks from a previous instance of lvmlockd.\n");
+}
+
+int main(int argc, char *argv[])
+{
+	daemon_state ds;
+
+	ds.daemon_main = main_loop;
+	ds.daemon_init = NULL;
+	ds.daemon_fini = NULL;
+	ds.pidfile = getenv("LVM_LVMLOCKD_PIDFILE");
+	ds.socket_path = getenv("LVM_LVMLOCKD_SOCKET");
+	ds.protocol = lvmlockd_protocol;
+	ds.protocol_version = lvmlockd_protocol_version;
+	ds.name = "lvmlockd";
+
+	static struct option long_options[] = {
+		{"help",            no_argument,       0, 'h' },
+		{"version",         no_argument,       0, 'V' },
+		{"test",            no_argument,       0, 'T' },
+		{"foreground",      no_argument,       0, 'f' },
+		{"daemon-debug",    no_argument,       0, 'D' },
+		{"pid-file",        required_argument, 0, 'p' },
+		{"socket-path",     required_argument, 0, 's' },
+		{"gl-type",         required_argument, 0, 'g' },
+		{"host-id",         required_argument, 0, 'i' },
+		{"host-id-file",    required_argument, 0, 'F' },
+		{"adopt",           required_argument, 0, 'A' },
+		{"syslog-priority", required_argument, 0, 'S' },
+		{"sanlock-timeout", required_argument, 0, 'o' },
+		{0, 0, 0, 0 }
+	};
+
+	while (1) {
+		int c;
+		int lm;
+		int option_index = 0;
+
+		c = getopt_long(argc, argv, "hVTfDp:s:l:g:S:I:A:o:",
+				long_options, &option_index);
+		if (c == -1)
+			break;
+
+		switch (c) {
+		case '0':
+			break;
+		case 'h':
+			usage(argv[0], stdout);
+			exit(EXIT_SUCCESS);
+		case 'V':
+			printf("lvmlockd version: " LVM_VERSION "\n");
+			exit(EXIT_SUCCESS);
+		case 'T':
+			daemon_test = 1;
+			break;
+		case 'f':
+			ds.foreground = 1;
+			break;
+		case 'D':
+			ds.foreground = 1;
+			daemon_debug = 1;
+			break;
+		case 'p':
+			ds.pidfile = strdup(optarg);
+			break;
+		case 's':
+			ds.socket_path = strdup(optarg);
+			break;
+		case 'g':
+			lm = str_to_lm(optarg);
+			if (lm == LD_LM_DLM)
+				gl_use_dlm = 1;
+			else if (lm == LD_LM_SANLOCK)
+				gl_use_sanlock = 1;
+			else {
+				fprintf(stderr, "invalid gl-type option");
+				exit(EXIT_FAILURE);
+			}
+			break;
+		case 'i':
+			daemon_host_id = atoi(optarg);
+			break;
+		case 'F':
+			daemon_host_id_file = strdup(optarg);
+			break;
+		case 'o':
+			sanlock_io_timeout = atoi(optarg);
+			break;
+		case 'A':
+			adopt_opt = atoi(optarg);
+			break;
+		case 'S':
+			syslog_priority = _syslog_name_to_num(optarg);
+			break;
+		case '?':
+		default:
+			usage(argv[0], stdout);
+			exit(EXIT_FAILURE);
+		}
+	}
+
+	if (!ds.pidfile)
+		ds.pidfile = LVMLOCKD_PIDFILE;
+
+	if (!ds.socket_path)
+		ds.socket_path = LVMLOCKD_SOCKET;
+
+	/* runs daemon_main/main_loop */
+	daemon_start(ds);
+
+	return 0;
+}
diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
new file mode 100644
index 0000000..5542968
--- /dev/null
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -0,0 +1,666 @@
+/*
+ * Copyright (C) 2014 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ */
+
+#define _XOPEN_SOURCE 500  /* pthread */
+#define _ISOC99_SOURCE
+#define _GNU_SOURCE
+
+#include <assert.h>
+#include <pthread.h>
+#include <stdint.h>
+#include <stddef.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <stdio.h>
+#include <poll.h>
+#include <errno.h>
+#include <string.h>
+#include <endian.h>
+#include <fcntl.h>
+#include <byteswap.h>
+#include <syslog.h>
+#include <dirent.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <sys/socket.h>
+
+#include "configure.h"
+#include "daemon-server.h"
+#include "daemon-log.h"
+#include "xlate.h"
+
+#include "lvmlockd-internal.h"
+#include "lvmlockd-client.h"
+
+/*
+ * Using synchronous _wait dlm apis so do not define _REENTRANT and
+ * link with non-threaded version of library, libdlm_lt.
+ */
+#include "libdlm.h"
+
+struct lm_dlm {
+	dlm_lshandle_t *dh;
+};
+
+struct rd_dlm {
+	struct dlm_lksb lksb;
+	struct val_blk *vb;
+};
+
+int lm_data_size_dlm(void)
+{
+	return sizeof(struct rd_dlm);
+}
+
+/*
+ * lock_args format
+ *
+ * vg_lock_args format for dlm is
+ * vg_version_string:undefined:cluster_name
+ *
+ * lv_lock_args are not used for dlm
+ *
+ * version_string is MAJOR.MINOR.PATCH
+ * undefined may contain ":"
+ */
+
+#define VG_LOCK_ARGS_MAJOR 1
+#define VG_LOCK_ARGS_MINOR 0
+#define VG_LOCK_ARGS_PATCH 0
+
+static int cluster_name_from_args(char *vg_args, char *clustername)
+{
+	return last_string_from_args(vg_args, clustername);
+}
+
+static int check_args_version(char *vg_args)
+{
+	unsigned int major = 0;
+	int rv;
+
+	rv = version_from_args(vg_args, &major, NULL, NULL);
+	if (rv < 0) {
+		log_error("check_args_version %s error %d", vg_args, rv);
+		return rv;
+	}
+
+	if (major > VG_LOCK_ARGS_MAJOR) {
+		log_error("check_args_version %s major %d %d", vg_args, major, VG_LOCK_ARGS_MAJOR);
+		return -1;
+	}
+
+	return 0;
+}
+
+/* This will be set after dlm_controld is started. */
+#define DLM_CLUSTER_NAME_PATH "/sys/kernel/config/dlm/cluster/cluster_name"
+
+static int read_cluster_name(char *clustername)
+{
+	char *n;
+	int fd;
+	int rv;
+
+	if (daemon_test) {
+		sprintf(clustername, "%s", "test");
+		return 0;
+	}
+
+	fd = open(DLM_CLUSTER_NAME_PATH, O_RDONLY);
+	if (fd < 0) {
+		log_debug("read_cluster_name: open error %d, check dlm_controld", fd);
+		return fd;
+	}
+
+	rv = read(fd, clustername, MAX_ARGS - 1);
+	if (rv < 0) {
+		log_error("read_cluster_name: cluster name read error %d, check dlm_controld", fd);
+		close(fd);
+		return rv;
+	}
+
+	n = strstr(clustername, "\n");
+	if (n)
+		*n = '\0';
+	close(fd);
+	return 0;
+}
+
+int lm_init_vg_dlm(char *ls_name, char *vg_name, uint32_t flags, char *vg_args)
+{
+	char clustername[MAX_ARGS];
+	char lock_args_version[MAX_ARGS];
+	int rv;
+
+	memset(clustername, 0, sizeof(clustername));
+	memset(lock_args_version, 0, sizeof(lock_args_version));
+
+	snprintf(lock_args_version, MAX_ARGS, "%u.%u.%u",
+		 VG_LOCK_ARGS_MAJOR, VG_LOCK_ARGS_MINOR, VG_LOCK_ARGS_PATCH);
+
+	rv = read_cluster_name(clustername);
+	if (rv < 0)
+		return -EMANAGER;
+
+	if (strlen(clustername) + strlen(lock_args_version) + 2 > MAX_ARGS) {
+		log_error("init_vg_dlm args too long");
+		return -EARGS;
+	}
+
+	snprintf(vg_args, MAX_ARGS, "%s:%s", lock_args_version, clustername);
+	rv = 0;
+
+	log_debug("init_vg_dlm done %s vg_args %s", ls_name, vg_args);
+	return rv;
+}
+
+int lm_prepare_lockspace_dlm(struct lockspace *ls)
+{
+	char sys_clustername[MAX_ARGS];
+	char arg_clustername[MAX_ARGS];
+	struct lm_dlm *lmd;
+	int rv;
+
+	memset(sys_clustername, 0, sizeof(sys_clustername));
+	memset(arg_clustername, 0, sizeof(arg_clustername));
+
+	rv = read_cluster_name(sys_clustername);
+	if (rv < 0)
+		return -EMANAGER;
+
+	if (!ls->vg_args[0]) {
+		/* global lockspace has no vg args */
+		goto skip_args;
+	}
+
+	rv = check_args_version(ls->vg_args);
+	if (rv < 0)
+		return -EARGS;
+
+	rv = cluster_name_from_args(ls->vg_args, arg_clustername);
+	if (rv < 0) {
+		log_error("prepare_lockspace_dlm %s no cluster name from args %s", ls->name, ls->vg_args);
+		return -EARGS;
+	}
+
+	if (strcmp(sys_clustername, arg_clustername)) {
+		log_error("prepare_lockspace_dlm %s mismatching cluster names sys %s arg %s",
+			  ls->name, sys_clustername, arg_clustername);
+		return -EARGS;
+	}
+
+ skip_args:
+	lmd = malloc(sizeof(struct lm_dlm));
+	if (!lmd)
+		return -ENOMEM;
+
+	ls->lm_data = lmd;
+	return 0;
+}
+
+int lm_add_lockspace_dlm(struct lockspace *ls, int adopt)
+{
+	struct lm_dlm *lmd = (struct lm_dlm *)ls->lm_data;
+
+	if (daemon_test)
+		return 0;
+
+	if (adopt)
+		lmd->dh = dlm_open_lockspace(ls->name);
+	else
+		lmd->dh = dlm_new_lockspace(ls->name, 0600, DLM_LSFL_NEWEXCL);
+
+	if (!lmd->dh) {
+		log_error("add_lockspace_dlm %s adopt %d error", ls->name, adopt);
+		free(lmd);
+		ls->lm_data = NULL;
+		return -1;
+	}
+
+	return 0;
+}
+
+int lm_rem_lockspace_dlm(struct lockspace *ls, int free_vg)
+{
+	struct lm_dlm *lmd = (struct lm_dlm *)ls->lm_data;
+	int rv;
+
+	if (daemon_test)
+		goto out;
+
+	/*
+	 * If free_vg is set, it means we are doing vgremove, and we may want
+	 * to tell any other nodes to leave the lockspace.  This is not really
+	 * necessary since there should be no harm in having an unused
+	 * lockspace sitting around.  A new "notification lock" would need to
+	 * be added with a callback to signal this. 
+	 */
+
+	rv = dlm_release_lockspace(ls->name, lmd->dh, 1);
+	if (rv < 0) {
+		log_error("rem_lockspace_dlm error %d", rv);
+		return rv;
+	}
+ out:
+	free(lmd);
+	ls->lm_data = NULL;
+
+	if (!strcmp(ls->name, gl_lsname_dlm)) {
+		gl_running_dlm = 0;
+		gl_auto_dlm = 0;
+	}
+
+	return 0;
+}
+
+static int lm_add_resource_dlm(struct lockspace *ls, struct resource *r, int with_lock_nl)
+{
+	struct lm_dlm *lmd = (struct lm_dlm *)ls->lm_data;
+	struct rd_dlm *rdd = (struct rd_dlm *)r->lm_data;
+	uint32_t flags = 0;
+	char *buf;
+	int rv;
+
+	if (r->type == LD_RT_GL || r->type == LD_RT_VG) {
+		buf = malloc(sizeof(struct val_blk) + DLM_LVB_LEN);
+		if (!buf)
+			return -ENOMEM;
+		memset(buf, 0, sizeof(struct val_blk) + DLM_LVB_LEN);
+
+		rdd->vb = (struct val_blk *)buf;
+		rdd->lksb.sb_lvbptr = buf + sizeof(struct val_blk);
+
+		flags |= LKF_VALBLK;
+	}
+
+	if (!with_lock_nl)
+		goto out;
+
+	/* because this is a new NL lock request */
+	flags |= LKF_EXPEDITE;
+
+	if (daemon_test)
+		goto out;
+
+	rv = dlm_ls_lock_wait(lmd->dh, LKM_NLMODE, &rdd->lksb, flags,
+			      r->name, strlen(r->name),
+			      0, NULL, NULL, NULL);
+	if (rv < 0) {
+		log_error("S %s R %s add_resource_dlm lock error %d", ls->name, r->name, rv);
+		return rv;
+	}
+ out:
+	return 0;
+}
+
+int lm_rem_resource_dlm(struct lockspace *ls, struct resource *r)
+{
+	struct lm_dlm *lmd = (struct lm_dlm *)ls->lm_data;
+	struct rd_dlm *rdd = (struct rd_dlm *)r->lm_data;
+	struct dlm_lksb *lksb;
+	int rv = 0;
+
+	if (daemon_test)
+		goto out;
+
+	lksb = &rdd->lksb;
+
+	if (!lksb->sb_lkid)
+		goto out;
+
+	rv = dlm_ls_unlock_wait(lmd->dh, lksb->sb_lkid, 0, lksb);
+	if (rv < 0) {
+		log_error("S %s R %s rem_resource_dlm unlock error %d", ls->name, r->name, rv);
+	}
+ out:
+	if (rdd->vb)
+		free(rdd->vb);
+
+	memset(rdd, 0, sizeof(struct rd_dlm));
+	r->lm_init = 0;
+	return rv;
+}
+
+static int to_dlm_mode(int ld_mode)
+{
+	switch (ld_mode) {
+	case LD_LK_EX:
+		return LKM_EXMODE;
+	case LD_LK_SH:
+		return LKM_PRMODE;
+	};
+	return -1;
+}
+
+static int lm_adopt_dlm(struct lockspace *ls, struct resource *r, int ld_mode,
+			uint32_t *r_version)
+{
+	struct lm_dlm *lmd = (struct lm_dlm *)ls->lm_data;
+	struct rd_dlm *rdd = (struct rd_dlm *)r->lm_data;
+	struct dlm_lksb *lksb;
+	uint32_t flags = 0;
+	int mode;
+	int rv;
+
+	*r_version = 0;
+
+	if (!r->lm_init) {
+		rv = lm_add_resource_dlm(ls, r, 0);
+		if (rv < 0)
+			return rv;
+		r->lm_init = 1;
+	}
+
+	lksb = &rdd->lksb;
+
+	flags |= LKF_PERSISTENT;
+	flags |= LKF_ORPHAN;
+
+	if (rdd->vb)
+		flags |= LKF_VALBLK;
+
+	mode = to_dlm_mode(ld_mode);
+	if (mode < 0) {
+		log_error("adopt_dlm invalid mode %d", ld_mode);
+		rv = -EINVAL;
+		goto fail;
+	}
+
+	log_debug("S %s R %s adopt_dlm", ls->name, r->name);
+
+	if (daemon_test)
+		return 0;
+
+	/*
+	 * dlm returns 0 for success, -EAGAIN if an orphan is
+	 * found with another mode, and -ENOENT if no orphan.
+	 *
+	 * cast/bast/param are (void *)1 because the kernel
+	 * returns errors if some are null.
+	 */
+
+	rv = dlm_ls_lockx(lmd->dh, mode, lksb, flags,
+			  r->name, strlen(r->name), 0,
+			  (void *)1, (void *)1, (void *)1,
+			  NULL, NULL);
+
+	if (rv == -EAGAIN) {
+		log_debug("S %s R %s adopt_dlm adopt mode %d try other mode",
+			  ls->name, r->name, ld_mode);
+		rv = -EUCLEAN;
+		goto fail;
+	}
+	if (rv < 0) {
+		log_debug("S %s R %s adopt_dlm mode %d flags %x error %d errno %d",
+			  ls->name, r->name, mode, flags, rv, errno);
+		goto fail;
+	}
+
+	/*
+	 * FIXME: For GL/VG locks we probably want to read the lvb,
+	 * especially if adopting an ex lock, because when we
+	 * release this adopted ex lock we may want to write new
+	 * lvb values based on the current lvb values (at lease
+	 * in the GL case where we increment the current values.)
+	 *
+	 * It should be possible to read the lvb by requesting
+	 * this lock in the same mode it's already in.
+	 */
+
+	return rv;
+
+ fail:
+	lm_rem_resource_dlm(ls, r);
+	return rv;
+}
+
+/*
+ * Use PERSISTENT so that if lvmlockd exits while holding locks,
+ * the locks will remain orphaned in the dlm, still protecting what
+ * they were acquired to protect.
+ */
+
+int lm_lock_dlm(struct lockspace *ls, struct resource *r, int ld_mode,
+		uint32_t *r_version, int adopt)
+{
+	struct lm_dlm *lmd = (struct lm_dlm *)ls->lm_data;
+	struct rd_dlm *rdd = (struct rd_dlm *)r->lm_data;
+	struct dlm_lksb *lksb;
+	struct val_blk vb;
+	uint32_t flags = 0;
+	uint16_t vb_version;
+	int mode;
+	int rv;
+
+	if (adopt) {
+		/* When adopting, we don't follow the normal method
+		   of acquiring a NL lock then converting it to the
+		   desired mode. */
+		return lm_adopt_dlm(ls, r, ld_mode, r_version);
+	}
+
+	if (!r->lm_init) {
+		rv = lm_add_resource_dlm(ls, r, 1);
+		if (rv < 0)
+			return rv;
+		r->lm_init = 1;
+	}
+
+	lksb = &rdd->lksb;
+
+	flags |= LKF_CONVERT;
+	flags |= LKF_NOQUEUE;
+	flags |= LKF_PERSISTENT;
+
+	if (rdd->vb)
+		flags |= LKF_VALBLK;
+
+	mode = to_dlm_mode(ld_mode);
+	if (mode < 0) {
+		log_error("lock_dlm invalid mode %d", ld_mode);
+		return -EINVAL;
+	}
+
+	log_debug("S %s R %s lock_dlm", ls->name, r->name);
+
+	if (daemon_test) {
+		*r_version = 0;
+		return 0;
+	}
+
+	rv = dlm_ls_lock_wait(lmd->dh, mode, lksb, flags,
+			      r->name, strlen(r->name),
+			      0, NULL, NULL, NULL);
+	if (rv == -EAGAIN) {
+		log_error("S %s R %s lock_dlm mode %d rv EAGAIN", ls->name, r->name, mode);
+		return -EAGAIN;
+	}
+	if (rv < 0) {
+		log_error("S %s R %s lock_dlm error %d", ls->name, r->name, rv);
+		return rv;
+	}
+
+	if (rdd->vb) {
+		if (lksb->sb_flags & DLM_SBF_VALNOTVALID) {
+			log_debug("S %s R %s lock_dlm VALNOTVALID", ls->name, r->name);
+			memset(rdd->vb, 0, sizeof(struct val_blk));
+			*r_version = 0;
+			goto out;
+		}
+
+		memcpy(&vb, lksb->sb_lvbptr, sizeof(struct val_blk));
+		vb_version = le16_to_cpu(vb.version);
+
+		if (vb_version && ((vb_version & 0xFF00) > (VAL_BLK_VERSION & 0xFF00))) {
+			log_error("S %s R %s lock_dlm ignore vb_version %x",
+				  ls->name, r->name, vb_version);
+			*r_version = 0;
+			free(rdd->vb);
+			rdd->vb = NULL;
+			lksb->sb_lvbptr = NULL;
+			goto out;
+		}
+
+		*r_version = le32_to_cpu(vb.r_version);
+		memcpy(rdd->vb, &vb, sizeof(vb)); /* rdd->vb saved as le */
+
+		log_debug("S %s R %s lock_dlm get r_version %u",
+			  ls->name, r->name, *r_version);
+	}
+out:
+	return 0;
+}
+
+int lm_convert_dlm(struct lockspace *ls, struct resource *r,
+		   int ld_mode, uint32_t r_version)
+{
+	struct lm_dlm *lmd = (struct lm_dlm *)ls->lm_data;
+	struct rd_dlm *rdd = (struct rd_dlm *)r->lm_data;
+	struct dlm_lksb *lksb = &rdd->lksb;
+	uint32_t mode;
+	uint32_t flags = 0;
+	int rv;
+
+	log_debug("S %s R %s convert_dlm", ls->name, r->name);
+
+	flags |= LKF_CONVERT;
+	flags |= LKF_NOQUEUE;
+	flags |= LKF_PERSISTENT;
+
+	if (rdd->vb && r_version && (r->mode == LD_LK_EX)) {
+		if (!rdd->vb->version) {
+			/* first time vb has been written */
+			rdd->vb->version = cpu_to_le16(VAL_BLK_VERSION);
+		}
+		rdd->vb->r_version = cpu_to_le32(r_version);
+		memcpy(lksb->sb_lvbptr, rdd->vb, sizeof(struct val_blk));
+
+		log_debug("S %s R %s convert_dlm set r_version %u",
+			  ls->name, r->name, r_version);
+
+		flags |= LKF_VALBLK;
+	}
+
+	mode = to_dlm_mode(ld_mode);
+
+	if (daemon_test)
+		return 0;
+
+	rv = dlm_ls_lock_wait(lmd->dh, mode, lksb, flags,
+			      r->name, strlen(r->name),
+			      0, NULL, NULL, NULL);
+	if (rv == -EAGAIN) {
+		/* FIXME: When does this happen?  Should something different be done? */
+		log_error("S %s R %s convert_dlm mode %d rv EAGAIN", ls->name, r->name, mode);
+		return -EAGAIN;
+	}
+	if (rv < 0) {
+		log_error("S %s R %s convert_dlm error %d", ls->name, r->name, rv);
+	}
+	return rv;
+}
+
+int lm_unlock_dlm(struct lockspace *ls, struct resource *r,
+		  uint32_t r_version, uint32_t lmuf_flags)
+{
+	struct lm_dlm *lmd = (struct lm_dlm *)ls->lm_data;
+	struct rd_dlm *rdd = (struct rd_dlm *)r->lm_data;
+	struct dlm_lksb *lksb = &rdd->lksb;
+	uint32_t flags = 0;
+	int rv;
+
+	log_debug("S %s R %s unlock_dlm r_version %u flags %x",
+		  ls->name, r->name, r_version, lmuf_flags);
+
+	/*
+	 * Do not set PERSISTENT, because we don't need an orphan
+	 * NL lock to protect anything.
+	 */
+
+	flags |= LKF_CONVERT;
+
+	if (rdd->vb && r_version && (r->mode == LD_LK_EX)) {
+		if (!rdd->vb->version) {
+			/* first time vb has been written */
+			rdd->vb->version = cpu_to_le16(VAL_BLK_VERSION);
+		}
+		if (r_version)
+			rdd->vb->r_version = cpu_to_le32(r_version);
+		memcpy(lksb->sb_lvbptr, rdd->vb, sizeof(struct val_blk));
+
+		log_debug("S %s R %s unlock_dlm set r_version %u",
+			  ls->name, r->name, r_version);
+
+		flags |= LKF_VALBLK;
+	}
+
+	if (daemon_test)
+		return 0;
+
+	rv = dlm_ls_lock_wait(lmd->dh, LKM_NLMODE, lksb, flags,
+			      r->name, strlen(r->name),
+			      0, NULL, NULL, NULL);
+	if (rv < 0) {
+		log_error("S %s R %s unlock_dlm error %d", ls->name, r->name, rv);
+	}
+
+	return rv;
+}
+
+/*
+ * This list could be read from dlm_controld via libdlmcontrol,
+ * but it's simpler to get it from sysfs.
+ */
+
+#define DLM_LOCKSPACES_PATH "/sys/kernel/config/dlm/cluster/spaces"
+
+int lm_get_lockspaces_dlm(struct list_head *ls_rejoin)
+{
+	struct lockspace *ls;
+	struct dirent *de;
+	DIR *ls_dir;
+
+	if (!(ls_dir = opendir(DLM_LOCKSPACES_PATH)))
+		return -ECONNREFUSED;
+
+	while ((de = readdir(ls_dir))) {
+		if (de->d_name[0] == '.')
+			continue;
+
+		if (strncmp(de->d_name, LVM_LS_PREFIX, strlen(LVM_LS_PREFIX)))
+			continue;
+
+		if (!(ls = alloc_lockspace())) {
+			closedir(ls_dir);
+			return -ENOMEM;
+		}
+
+		ls->lm_type = LD_LM_DLM;
+		strncpy(ls->name, de->d_name, MAX_NAME);
+		strncpy(ls->vg_name, ls->name + strlen(LVM_LS_PREFIX), MAX_NAME);
+		list_add_tail(&ls->list, ls_rejoin);
+	}
+
+	closedir(ls_dir);
+	return 0;
+}
+
+int lm_is_running_dlm(void)
+{
+	char sys_clustername[MAX_ARGS];
+	int rv;
+
+	memset(sys_clustername, 0, sizeof(sys_clustername));
+
+	rv = read_cluster_name(sys_clustername);
+	if (rv < 0)
+		return 0;
+	return 1;
+}
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
new file mode 100644
index 0000000..54d0a05
--- /dev/null
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -0,0 +1,373 @@
+/*
+ * Copyright (C) 2014 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ */
+
+#ifndef _LVM_LVMLOCKD_INTERNAL_H
+#define _LVM_LVMLOCKD_INTERNAL_H
+
+#define MAX_NAME 64
+#define MAX_ARGS 64
+
+#define R_NAME_GL_DISABLED "_GLLK_disabled"
+#define R_NAME_GL          "GLLK"
+#define R_NAME_VG          "VGLK"
+#define S_NAME_GL_DLM      "lvm_global"
+#define LVM_LS_PREFIX      "lvm_"           /* ls name is prefix + vg_name */
+/* global lockspace name for sanlock is a vg name */
+
+/* lock manager types */
+enum {
+	LD_LM_NONE = 0,
+	LD_LM_UNUSED = 1, /* place holder so values match lib/locking/lvmlockd.h */
+	LD_LM_DLM = 2,
+	LD_LM_SANLOCK = 3,
+};
+
+/* operation types */
+enum {
+	LD_OP_HELLO = 1,
+	LD_OP_QUIT,
+	LD_OP_INIT,
+	LD_OP_FREE,
+	LD_OP_START,
+	LD_OP_STOP,
+	LD_OP_LOCK,
+	LD_OP_UPDATE,
+	LD_OP_CLOSE,
+	LD_OP_ENABLE,
+	LD_OP_DISABLE,
+	LD_OP_START_WAIT,
+	LD_OP_STOP_ALL,
+	LD_OP_DUMP_INFO,
+	LD_OP_DUMP_LOG,
+	LD_OP_RENAME_BEFORE,
+	LD_OP_RENAME_FINAL,
+	LD_OP_RUNNING_LM,
+	LD_OP_FIND_FREE_LOCK,
+	LD_OP_FORGET_VG_NAME,
+};
+
+/* resource types */
+enum {
+	LD_RT_GL = 1,
+	LD_RT_VG,
+	LD_RT_LV,
+};
+
+/* lock modes, more restrictive must be larger value */
+enum {
+	LD_LK_IV = -1,
+	LD_LK_UN = 0,
+	LD_LK_NL = 1,
+	LD_LK_SH = 2,
+	LD_LK_EX = 3,
+};
+
+struct list_head {
+	struct list_head *next, *prev;
+};
+
+struct client {
+	struct list_head list;
+	pthread_mutex_t mutex;
+	int pid;
+	int fd;
+	int pi;
+	uint32_t id;
+	unsigned int recv : 1;
+	unsigned int dead : 1;
+	unsigned int poll_ignore : 1;
+	char name[MAX_NAME+1];
+};
+
+#define LD_AF_PERSISTENT           0x00000001
+#define LD_AF_UNUSED               0x00000002 /* use me */
+#define LD_AF_UNLOCK_CANCEL        0x00000004
+#define LD_AF_NEXT_VERSION         0x00000008
+#define LD_AF_WAIT                 0x00000010
+#define LD_AF_FORCE                0x00000020
+#define LD_AF_EX_DISABLE           0x00000040
+#define LD_AF_ENABLE               0x00000080
+#define LD_AF_DISABLE              0x00000100
+#define LD_AF_SEARCH_LS            0x00000200
+#define LD_AF_WAIT_STARTING        0x00001000
+#define LD_AF_DUP_GL_LS            0x00002000
+#define LD_AF_INACTIVE_LS          0x00004000
+#define LD_AF_ADD_LS_ERROR         0x00008000
+#define LD_AF_ADOPT                0x00010000
+
+/*
+ * Number of times to repeat a lock request after
+ * a lock conflict (-EAGAIN) if unspecified in the
+ * request.
+ */
+#define DEFAULT_MAX_RETRIES 4
+
+struct action {
+	struct list_head list;
+	uint32_t client_id;
+	uint32_t flags;			/* LD_AF_ */
+	uint32_t version;
+	uint64_t host_id;
+	int8_t op;			/* operation type LD_OP_ */
+	int8_t rt;			/* resource type LD_RT_ */
+	int8_t mode;			/* lock mode LD_LK_ */
+	int8_t lm_type;			/* lock manager: LM_DLM, LM_SANLOCK */
+	int retries;
+	int max_retries;
+	int result;
+	int lm_rv;			/* return value from lm_ function */
+	char vg_uuid[64];
+	char vg_name[MAX_NAME+1];
+	char lv_name[MAX_NAME+1];
+	char lv_uuid[MAX_NAME+1];
+	char vg_args[MAX_ARGS];
+	char lv_args[MAX_ARGS];
+	char vg_sysid[MAX_NAME+1];
+};
+
+struct resource {
+	struct list_head list;		/* lockspace.resources */
+	char name[MAX_NAME+1];		/* vg name or lv name */
+	int8_t type;			/* resource type LD_RT_ */
+	int8_t mode;
+	unsigned int sh_count;		/* number of sh locks on locks list */
+	uint32_t version;
+	unsigned int lm_init : 1;	/* lm_data is initialized */
+	unsigned int adopt : 1;		/* temp flag in remove_inactive_lvs */
+	unsigned int version_zero_valid : 1;
+	struct list_head locks;
+	struct list_head actions;
+	struct val_blk *vb;
+	char lv_args[MAX_ARGS];
+	char lm_data[0];		/* lock manager specific data */
+};
+
+#define LD_LF_PERSISTENT 0x00000001
+
+struct lock {
+	struct list_head list;		/* resource.locks */
+	int8_t mode;			/* lock mode LD_LK_ */
+	uint32_t version;
+	uint32_t flags;			/* LD_LF_ */
+	uint32_t client_id; /* may be 0 for persistent or internal locks */
+};
+
+struct lockspace {
+	struct list_head list;		/* lockspaces */
+	char name[MAX_NAME+1];
+	char vg_name[MAX_NAME+1];
+	char vg_uuid[64];
+	char vg_args[MAX_ARGS];		/* lock manager specific args */
+	char vg_sysid[MAX_NAME+1];
+	int8_t lm_type;			/* lock manager: LM_DLM, LM_SANLOCK */
+	void *lm_data;
+	uint64_t host_id;
+	uint64_t free_lock_offset;	/* start search for free lock here */
+
+	uint32_t start_client_id;	/* client_id that started the lockspace */
+	pthread_t thread;		/* makes synchronous lock requests */
+	pthread_cond_t cond;
+	pthread_mutex_t mutex;
+	unsigned int create_fail : 1;
+	unsigned int create_done : 1;
+	unsigned int thread_work : 1;
+	unsigned int thread_stop : 1;
+	unsigned int thread_done : 1;
+	unsigned int sanlock_gl_enabled: 1;
+	unsigned int sanlock_gl_dup: 1;
+
+	struct list_head actions;	/* new client actions */
+	struct list_head resources;	/* resource/lock state for gl/vg/lv */
+};
+
+#define VAL_BLK_VERSION 0x0101
+
+struct val_blk {
+	uint16_t version;
+	uint16_t flags;
+	uint32_t r_version;
+};
+
+/* lm_unlock flags */
+#define LMUF_FREE_VG 0x00000001
+
+struct lockspace *alloc_lockspace(void);
+int lockspaces_empty(void);
+int last_string_from_args(char *args_in, char *last);
+int version_from_args(char *args, unsigned int *major, unsigned int *minor, unsigned int *patch);
+
+int lm_init_vg_dlm(char *ls_name, char *vg_name, uint32_t flags, char *vg_args);
+int lm_prepare_lockspace_dlm(struct lockspace *ls);
+int lm_add_lockspace_dlm(struct lockspace *ls, int adopt);
+int lm_rem_lockspace_dlm(struct lockspace *ls, int free_vg);
+int lm_lock_dlm(struct lockspace *ls, struct resource *r, int ld_mode,
+		uint32_t *r_version, int adopt);
+int lm_convert_dlm(struct lockspace *ls, struct resource *r,
+		   int ld_mode, uint32_t r_version);
+int lm_unlock_dlm(struct lockspace *ls, struct resource *r,
+		  uint32_t r_version, uint32_t lmu_flags);
+int lm_rem_resource_dlm(struct lockspace *ls, struct resource *r);
+int lm_get_lockspaces_dlm(struct list_head *ls_rejoin);
+int lm_data_size_dlm(void);
+int lm_is_running_dlm(void);
+
+int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_args);
+int lm_init_lv_sanlock(char *ls_name, char *vg_name, char *lv_name, char *vg_args, char *lv_args, uint64_t free_offset);
+int lm_free_lv_sanlock(struct lockspace *ls, struct resource *r);
+int lm_rename_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_args);
+int lm_prepare_lockspace_sanlock(struct lockspace *ls);
+int lm_add_lockspace_sanlock(struct lockspace *ls, int adopt);
+int lm_rem_lockspace_sanlock(struct lockspace *ls, int free_vg);
+int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
+		    uint32_t *r_version, int *retry, int adopt);
+int lm_convert_sanlock(struct lockspace *ls, struct resource *r,
+		       int ld_mode, uint32_t r_version);
+int lm_unlock_sanlock(struct lockspace *ls, struct resource *r,
+		      uint32_t r_version, uint32_t lmu_flags);
+int lm_able_gl_sanlock(struct lockspace *ls, int enable);
+int lm_ex_disable_gl_sanlock(struct lockspace *ls);
+int lm_hosts_sanlock(struct lockspace *ls, int notify);
+int lm_rem_resource_sanlock(struct lockspace *ls, struct resource *r);
+int lm_gl_is_enabled(struct lockspace *ls);
+int lm_get_lockspaces_sanlock(struct list_head *ls_rejoin);
+int lm_data_size_sanlock(void);
+int lm_is_running_sanlock(void);
+int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free_offset);
+
+#define container_of(ptr, type, member) ({                      \
+	const typeof( ((type *)0)->member ) *__mptr = (ptr);    \
+	(type *)( (char *)__mptr - offsetof(type,member) );})
+
+static inline void INIT_LIST_HEAD(struct list_head *list)
+{
+	list->next = list;
+	list->prev = list;
+}
+
+static inline void __list_add(struct list_head *new,
+                              struct list_head *prev,
+                              struct list_head *next)
+{
+	next->prev = new;
+	new->next = next;
+	new->prev = prev;
+	prev->next = new;
+}
+
+static inline void __list_del(struct list_head *prev, struct list_head *next)
+{
+	next->prev = prev;
+	prev->next = next;
+}
+
+static inline void list_add(struct list_head *new, struct list_head *head)
+{
+	__list_add(new, head, head->next);
+}
+
+static inline void list_add_tail(struct list_head *new, struct list_head *head)
+{
+	__list_add(new, head->prev, head);
+}
+
+static inline void list_del(struct list_head *entry)
+{
+	__list_del(entry->prev, entry->next);
+}
+
+static inline int list_empty(const struct list_head *head)
+{
+	return head->next == head;
+}
+
+#define list_entry(ptr, type, member) \
+	container_of(ptr, type, member)
+
+#define list_first_entry(ptr, type, member) \
+	list_entry((ptr)->next, type, member)
+
+#define list_for_each_entry(pos, head, member)                          \
+	for (pos = list_entry((head)->next, typeof(*pos), member);      \
+	     &pos->member != (head);    \
+	     pos = list_entry(pos->member.next, typeof(*pos), member))
+
+#define list_for_each_entry_safe(pos, n, head, member)                  \
+	for (pos = list_entry((head)->next, typeof(*pos), member),      \
+	     n = list_entry(pos->member.next, typeof(*pos), member); \
+	     &pos->member != (head);                                    \
+	     pos = n, n = list_entry(n->member.next, typeof(*n), member))
+
+
+/* to improve readability */
+#define WAIT     1
+#define NO_WAIT  0
+#define FORCE    1
+#define NO_FORCE 0
+
+/*
+ * global variables
+ */
+
+#ifndef EXTERN
+#define EXTERN extern
+#define INIT(X)
+#else
+#undef EXTERN
+#define EXTERN
+#define INIT(X) =X
+#endif
+
+/*
+ * gl_type_static and gl_use_ are set by command line or config file
+ * to specify whether the global lock comes from dlm or sanlock.
+ * Without a static setting, lvmlockd will figure out where the
+ * global lock should be (but it could get mixed up in cases where
+ * both sanlock and dlm vgs exist.)
+ *
+ * gl_use_dlm means that the gl should come from lockspace gl_lsname_dlm
+ * gl_use_sanlock means that the gl should come from lockspace gl_lsname_sanlock
+ *
+ * gl_use_dlm has precedence over gl_use_sanlock, so if a node sees both
+ * dlm and sanlock vgs, it will use the dlm gl.
+ *
+ * gl_use_ is set when the first evidence of that lm_type is seen
+ * in any command.
+ *
+ * gl_lsname_sanlock is set when the first vg is seen in which an
+ * enabled gl is exists, or when init_vg creates a vg with gl enabled,
+ * or when enable_gl is used.
+ *
+ * gl_lsname_sanlock is cleared when free_vg deletes a vg with gl enabled
+ * or when disable_gl matches.
+ */
+
+EXTERN int gl_type_static;
+EXTERN int gl_use_dlm;
+EXTERN int gl_use_sanlock;
+EXTERN pthread_mutex_t gl_type_mutex;
+
+EXTERN char gl_lsname_dlm[MAX_NAME+1];
+EXTERN char gl_lsname_sanlock[MAX_NAME+1];
+
+EXTERN int gl_running_dlm;
+EXTERN int gl_auto_dlm;
+
+EXTERN int daemon_test; /* run as much as possible without a live lock manager */
+EXTERN int daemon_debug;
+EXTERN int daemon_host_id;
+EXTERN const char *daemon_host_id_file;
+EXTERN int sanlock_io_timeout;
+
+void log_level(int level, const char *fmt, ...)  __attribute__((format(printf, 2, 3)));
+#define log_debug(fmt, args...) log_level(LOG_DEBUG, fmt, ##args)
+#define log_error(fmt, args...) log_level(LOG_ERR, fmt, ##args)
+#define log_warn(fmt, args...) log_level(LOG_WARNING, fmt, ##args)
+
+#endif
diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
new file mode 100644
index 0000000..8f3ecff
--- /dev/null
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -0,0 +1,1716 @@
+/*
+ * Copyright (C) 2014 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ */
+
+#define _XOPEN_SOURCE 500  /* pthread */
+#define _ISOC99_SOURCE
+#define _GNU_SOURCE
+
+#include <assert.h>
+#include <pthread.h>
+#include <stdint.h>
+#include <stddef.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <stdio.h>
+#include <poll.h>
+#include <errno.h>
+#include <string.h>
+#include <syslog.h>
+#include <sys/types.h>
+#include <sys/socket.h>
+
+#include "configure.h"
+#include "daemon-server.h"
+#include "daemon-log.h"
+#include "xlate.h"
+
+#include "lvmlockd-internal.h"
+#include "lvmlockd-client.h"
+
+#include "sanlock.h"
+#include "sanlock_rv.h"
+#include "sanlock_admin.h"
+#include "sanlock_resource.h"
+
+/*
+ * If access to the pv containing the vg's leases is lost, sanlock cannot renew
+ * the leases we have acquired for locked LVs.  This means that we could soon
+ * loose the lease to another host which could activate our LV exclusively.  We
+ * do not want to get to the point of two hosts having the same LV active
+ * exclusively (it obviously violates the purpose of LV locks.)
+ *
+ * The default method of preventing this problem is for lvmlockd to do nothing,
+ * which produces a safe but potentially inconvenient result.  Doing nothing
+ * leads to our LV leases not being released, which leads to sanlock using the
+ * local watchdog to reset us before another host can acquire our lock.  It
+ * would often be preferrable to avoid the abrupt hard reset from the watchdog.
+ *
+ * There are other options to avoid being reset by our watchdog.  If we can
+ * quickly stop using the LVs in question and release the locks for them, then
+ * we could avoid a reset (there's a certain grace period of about 40 seconds
+ * in which we can attempt this.)  To do this, we can tell sanlock to run a
+ * specific program when it has lost access to our leases.  We could use this
+ * program to:
+ *
+ * 1. Deactivate all lvs in the effected vg.  If all the leases are
+ * deactivated, then our LV locks would be released and sanlock would no longer
+ * use the watchdog to reset us.  If file systems are mounted on the active
+ * lvs, then deactivating them would fail, so this option would be of limited
+ * usefulness.
+ *
+ * 2. Option 1 could be extended to kill pids using the fs on the lv, unmount
+ * the fs, and deactivate the lv.  This is probably out of scope for lvm
+ * directly, and would likely need the help of another system service.
+ *
+ * 3. Use dmsetup suspend to block access to lvs in the effected vg.  If this
+ * was successful, the local host could no longer write to the lvs, we could
+ * safely release the LV locks, and sanlock would no longer reset us.  At this
+ * point, with suspended lvs, the host would be in a fairly hobbled state, and
+ * would almost certainly need a manual, forcible reset.
+ *
+ * 4. Option 3 could be extended to monitor the lost storage, and if it is
+ * reconnected, the leases could be reacquired, and the suspended lvs resumed
+ * (reacquiring leases will fail if another host has acquired them since they
+ * were released.)  This complexity of this option, combined with the fact that
+ * the error conditions are often not as simple as storage being lost and then
+ * later connecting, will result in this option being too unreliable.
+ *
+ * Add a config option that we could use to select a different behavior than
+ * the default.  Then implement one of the simpler options as a proof of
+ * concept, which could be extended if needed.
+ */
+
+/*
+ * Each lockspace thread has its own sanlock daemon connection.
+ * If they shared one, sanlock acquire/release calls would be
+ * serialized.  Some aspects of sanlock expect a single connection
+ * from each pid: signals due to a sanlock_request, and
+ * acquire/release/convert/inquire.  The later can probably be
+ * addressed with a flag to indicate that the pid field should be
+ * interpretted as 'ci' (which the caller would need to figure
+ * out somehow.)
+ */
+
+struct lm_sanlock {
+	struct sanlk_lockspace ss;
+	int align_size;
+	int sock; /* sanlock daemon connection */
+};
+
+struct rd_sanlock {
+	union {
+		struct sanlk_resource rs;
+		char buf[sizeof(struct sanlk_resource) + sizeof(struct sanlk_disk)];
+	};
+	struct val_blk *vb;
+};
+
+struct sanlk_resourced {
+	union {
+		struct sanlk_resource rs;
+		char buf[sizeof(struct sanlk_resource) + sizeof(struct sanlk_disk)];
+	};
+};
+
+int lm_data_size_sanlock(void)
+{
+	return sizeof(struct rd_sanlock);
+}
+
+/*
+ * lock_args format
+ *
+ * vg_lock_args format for sanlock is
+ * vg_version_string:undefined:lock_lv_name
+ *
+ * lv_lock_args format for sanlock is
+ * lv_version_string:undefined:offset
+ *
+ * version_string is MAJOR.MINOR.PATCH
+ * undefined may contain ":"
+ *
+ * If a new version of the lock_args string cannot be
+ * handled by an old version of lvmlockd, then the
+ * new lock_args string should contain a larger major number.
+ */
+
+#define VG_LOCK_ARGS_MAJOR 1
+#define VG_LOCK_ARGS_MINOR 0
+#define VG_LOCK_ARGS_PATCH 0
+
+#define LV_LOCK_ARGS_MAJOR 1
+#define LV_LOCK_ARGS_MINOR 0
+#define LV_LOCK_ARGS_PATCH 0
+
+/*
+ * offset 0 is lockspace
+ * offset align_size * 1 is unused
+ * offset align_size * 2 is unused
+ * ...
+ * offset align_size * 64 is unused
+ * offset align_size * 65 is gl lock
+ * offset align_size * 66 is vg lock
+ * offset align_size * 67 is first lv lock
+ * offset align_size * 68 is second lv lock
+ * ...
+ */
+
+#define LS_BEGIN 0
+#define GL_LOCK_BEGIN 65
+#define VG_LOCK_BEGIN 66
+#define LV_LOCK_BEGIN 67
+
+static int lock_lv_name_from_args(char *vg_args, char *lock_lv_name)
+{
+	return last_string_from_args(vg_args, lock_lv_name);
+}
+
+static int lock_lv_offset_from_args(char *lv_args, uint64_t *lock_lv_offset)
+{
+	char offset_str[MAX_ARGS];
+	int rv;
+
+	memset(offset_str, 0, sizeof(offset_str));
+
+	rv = last_string_from_args(lv_args, offset_str);
+	if (rv < 0)
+		return rv;
+
+	*lock_lv_offset = strtoull(offset_str, NULL, 10);
+	return 0;
+}
+
+static int check_args_version(char *args, unsigned int our_major)
+{
+	unsigned int major = 0;
+	int rv;
+
+	rv = version_from_args(args, &major, NULL, NULL);
+	if (rv < 0) {
+		log_error("check_args_version %s error %d", args, rv);
+		return rv;
+	}
+
+	if (major > our_major) {
+		log_error("check_args_version %s major %u %u", args, major, our_major);
+		return -1;
+	}
+
+	return 0;
+}
+
+#define MAX_LINE 64
+
+static int read_host_id_file(void)
+{
+	FILE *file;
+	char line[MAX_LINE];
+	char key_str[MAX_LINE];
+	char val_str[MAX_LINE];
+	char *key, *val, *sep;
+	int host_id = 0;
+
+	file = fopen(daemon_host_id_file, "r");
+	if (!file)
+		goto out;
+
+	while (fgets(line, MAX_LINE, file)) {
+		if (line[0] == '#' || line[0] == '\n')
+			continue;
+
+		key = line;
+		sep = strstr(line, "=");
+		val = sep + 1;
+
+		if (!sep || !val)
+			continue;
+
+		*sep = '\0';
+		memset(key_str, 0, sizeof(key_str));
+		memset(val_str, 0, sizeof(val_str));
+		sscanf(key, "%s", key_str);
+		sscanf(val, "%s", val_str);
+
+		if (!strcmp(key_str, "host_id")) {
+			host_id = atoi(val_str);
+			break;
+		}
+	}
+	fclose(file);
+out:
+	log_debug("host_id %d from %s", host_id, daemon_host_id_file);
+	return host_id;
+}
+
+/*
+ * vgcreate
+ *
+ * For init_vg, vgcreate passes the internal lv name as vg_args.
+ * This constructs the full/proper vg_args format, containing the
+ * version and lv name, and returns the real lock_args in vg_args.
+ */
+
+int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_args)
+{
+	struct sanlk_lockspace ss;
+	struct sanlk_resourced rd;
+	struct sanlk_disk disk;
+	char lock_lv_name[MAX_ARGS];
+	char lock_args_version[MAX_ARGS];
+	const char *gl_name = NULL;
+	uint32_t daemon_version;
+	uint32_t daemon_proto;
+	uint64_t offset;
+	int align_size;
+	int i, rv;
+
+	memset(&ss, 0, sizeof(ss));
+	memset(&rd, 0, sizeof(rd));
+	memset(&disk, 0, sizeof(disk));
+	memset(lock_lv_name, 0, sizeof(lock_lv_name));
+	memset(lock_args_version, 0, sizeof(lock_args_version));
+
+	if (!vg_args || !vg_args[0] || !strcmp(vg_args, "none")) {
+		log_error("S %s init_vg_san vg_args missing", ls_name);
+		return -EARGS;
+	}
+
+	snprintf(lock_args_version, MAX_ARGS, "%u.%u.%u",
+		 VG_LOCK_ARGS_MAJOR, VG_LOCK_ARGS_MINOR, VG_LOCK_ARGS_PATCH);
+
+	/* see comment above about input vg_args being only lock_lv_name */
+	snprintf(lock_lv_name, MAX_ARGS, "%s", vg_args);
+
+	if (strlen(lock_lv_name) + strlen(lock_args_version) + 2 > MAX_ARGS)
+		return -EARGS;
+
+	snprintf(disk.path, SANLK_PATH_LEN, "/dev/mapper/%s-%s", vg_name, lock_lv_name);
+
+	log_debug("S %s init_vg_san path %s", ls_name, disk.path);
+
+	if (daemon_test) {
+		if (!gl_lsname_sanlock[0])
+			strncpy(gl_lsname_sanlock, ls_name, MAX_NAME);
+		return 0;
+	}
+
+	rv = sanlock_version(0, &daemon_version, &daemon_proto);
+	if (rv < 0) {
+		log_error("S %s init_vg_san failed to connect to sanlock daemon", ls_name);
+		return -EMANAGER;
+	}
+
+	log_debug("sanlock daemon version %08x proto %08x",
+		  daemon_version, daemon_proto);
+
+	align_size = sanlock_align(&disk);
+	if (align_size <= 0) {
+		log_error("S %s init_vg_san bad disk align size %d %s",
+			  ls_name, align_size, disk.path);
+		return -EARGS;
+	}
+
+	strncpy(ss.name, ls_name, SANLK_NAME_LEN);
+	memcpy(ss.host_id_disk.path, disk.path, SANLK_PATH_LEN);
+	ss.host_id_disk.offset = LS_BEGIN * align_size;
+
+	rv = sanlock_write_lockspace(&ss, 0, 0, sanlock_io_timeout);
+	if (rv < 0) {
+		log_error("S %s init_vg_san write_lockspace error %d %s",
+			  ls_name, rv, ss.host_id_disk.path);
+		return rv;
+	}
+	
+	/*
+	 * We want to create the global lock in the first sanlock vg.
+	 * If other sanlock vgs exist, then one of them must contain
+	 * the gl.  If gl_lsname_sanlock is not set, then perhaps
+	 * the sanlock vg with the gl has been removed or has not yet
+	 * been seen. (Would vgcreate get this far in that case?)
+	 * If dlm vgs exist, then we choose to use the dlm gl and
+	 * not a sanlock gl.
+	 */
+
+	if (flags & LD_AF_ENABLE)
+		gl_name = R_NAME_GL;
+	else if (flags & LD_AF_DISABLE)
+		gl_name = R_NAME_GL_DISABLED;
+	else if (!gl_use_sanlock || gl_lsname_sanlock[0] || !lockspaces_empty())
+		gl_name = R_NAME_GL_DISABLED;
+	else
+		gl_name = R_NAME_GL;
+
+	memcpy(rd.rs.lockspace_name, ss.name, SANLK_NAME_LEN);
+	strncpy(rd.rs.name, gl_name, SANLK_NAME_LEN);
+	memcpy(rd.rs.disks[0].path, disk.path, SANLK_PATH_LEN);
+	rd.rs.disks[0].offset = align_size * GL_LOCK_BEGIN;
+	rd.rs.num_disks = 1;
+
+	rv = sanlock_write_resource(&rd.rs, 0, 0, 0);
+	if (rv < 0) {
+		log_error("S %s init_vg_san write_resource gl error %d %s",
+			  ls_name, rv, rd.rs.disks[0].path);
+		return rv;
+	}
+
+	memcpy(rd.rs.lockspace_name, ss.name, SANLK_NAME_LEN);
+	strncpy(rd.rs.name, R_NAME_VG, SANLK_NAME_LEN);
+	memcpy(rd.rs.disks[0].path, disk.path, SANLK_PATH_LEN);
+	rd.rs.disks[0].offset = align_size * VG_LOCK_BEGIN;
+	rd.rs.num_disks = 1;
+
+	rv = sanlock_write_resource(&rd.rs, 0, 0, 0);
+	if (rv < 0) {
+		log_error("S %s init_vg_san write_resource vg error %d %s",
+			  ls_name, rv, rd.rs.disks[0].path);
+		return rv;
+	}
+
+	if (!strcmp(gl_name, R_NAME_GL))
+		strncpy(gl_lsname_sanlock, ls_name, MAX_NAME);
+ 
+	snprintf(vg_args, MAX_ARGS, "%s:%s", lock_args_version, lock_lv_name);
+
+	log_debug("S %s init_vg_san done vg_args %s", ls_name, vg_args);
+
+	/*
+	 * Go through all lv resource slots and initialize them with the
+	 * correct lockspace name but a special resource name that indicates
+	 * it is unused.
+	 */
+
+	memset(&rd, 0, sizeof(rd));
+	rd.rs.num_disks = 1;
+	memcpy(rd.rs.disks[0].path, disk.path, SANLK_PATH_LEN);
+	strncpy(rd.rs.lockspace_name, ls_name, SANLK_NAME_LEN);
+	strcpy(rd.rs.name, "#unused");
+
+	offset = align_size * LV_LOCK_BEGIN;
+
+	log_debug("S %s init_vg_san clearing lv lease areas", ls_name);
+
+	for (i = 0; ; i++) {
+		rd.rs.disks[0].offset = offset;
+
+		rv = sanlock_write_resource(&rd.rs, 0, 0, 0);
+		if (rv == -EMSGSIZE || rv == -ENOSPC) {
+			/* This indicates the end of the device is reached. */
+			rv = -EMSGSIZE;
+			break;
+		}
+
+		if (rv) {
+			log_error("clear lv resource area %llu error %d",
+				  (unsigned long long)offset, rv);
+			break;
+		}
+		offset += align_size;
+	}
+
+	return 0;
+}
+
+/*
+ * lvcreate
+ *
+ * The offset at which the lv lease is written is passed
+ * all the way back to the lvcreate command so that it
+ * can be saved in the lv's lock_args in the vg metadata.
+ */
+
+int lm_init_lv_sanlock(char *ls_name, char *vg_name, char *lv_name,
+		       char *vg_args, char *lv_args, uint64_t free_offset)
+{
+	struct sanlk_resourced rd;
+	char lock_lv_name[MAX_ARGS];
+	char lock_args_version[MAX_ARGS];
+	uint64_t offset;
+	int align_size;
+	int rv;
+
+	memset(&rd, 0, sizeof(rd));
+	memset(lock_lv_name, 0, sizeof(lock_lv_name));
+	memset(lock_args_version, 0, sizeof(lock_args_version));
+
+	rv = lock_lv_name_from_args(vg_args, lock_lv_name);
+	if (rv < 0) {
+		log_error("S %s init_lv_san lock_lv_name_from_args error %d %s",
+			  ls_name, rv, vg_args);
+		return rv;
+	}
+
+	snprintf(lock_args_version, MAX_ARGS, "%u.%u.%u",
+		 LV_LOCK_ARGS_MAJOR, LV_LOCK_ARGS_MINOR, LV_LOCK_ARGS_PATCH);
+
+	strncpy(rd.rs.lockspace_name, ls_name, SANLK_NAME_LEN);
+	rd.rs.num_disks = 1;
+	snprintf(rd.rs.disks[0].path, SANLK_PATH_LEN, "/dev/mapper/%s-%s", vg_name, lock_lv_name);
+
+	align_size = sanlock_align(&rd.rs.disks[0]);
+	if (align_size <= 0) {
+		log_error("S %s init_lv_san align error %d", ls_name, align_size);
+		return -EINVAL;
+	}
+
+	if (free_offset)
+		offset = free_offset;
+	else
+		offset = align_size * LV_LOCK_BEGIN;
+	rd.rs.disks[0].offset = offset;
+
+	if (daemon_test) {
+		snprintf(lv_args, MAX_ARGS, "%s:%llu",
+			 lock_args_version, (unsigned long long)1111);
+		return 0;
+	}
+
+	while (1) {
+		rd.rs.disks[0].offset = offset;
+
+		memset(rd.rs.name, 0, SANLK_NAME_LEN);
+
+		rv = sanlock_read_resource(&rd.rs, 0);
+		if (rv == -EMSGSIZE || rv == -ENOSPC) {
+			/* This indicates the end of the device is reached. */
+			log_debug("S %s init_lv_san read limit offset %llu",
+				  ls_name, (unsigned long long)offset);
+			rv = -EMSGSIZE;
+			return rv;
+		}
+
+		if (rv && rv != SANLK_LEADER_MAGIC) {
+			log_error("S %s init_lv_san read error %d offset %llu",
+				  ls_name, rv, (unsigned long long)offset);
+			break;
+		}
+
+		if (!strncmp(rd.rs.name, lv_name, SANLK_NAME_LEN)) {
+			log_error("S %s init_lv_san resource name %s already exists at %llu",
+				  ls_name, lv_name, (unsigned long long)offset);
+			return -EEXIST;
+		}
+
+		/*
+		 * If we read newly extended space, it will not be initialized
+		 * with an "#unused" resource, but will return SANLK_LEADER_MAGIC
+		 * indicating an uninitialized paxos structure on disk.
+		 */
+		if ((rv == SANLK_LEADER_MAGIC) || !strcmp(rd.rs.name, "#unused")) {
+			log_debug("S %s init_lv_san %s found unused area@%llu",
+				  ls_name, lv_name, (unsigned long long)offset);
+
+			strncpy(rd.rs.name, lv_name, SANLK_NAME_LEN);
+
+			rv = sanlock_write_resource(&rd.rs, 0, 0, 0);
+			if (!rv) {
+				snprintf(lv_args, MAX_ARGS, "%s:%llu",
+				         lock_args_version, (unsigned long long)offset);
+			} else {
+				log_error("S %s init_lv_san write error %d offset %llu",
+					  ls_name, rv, (unsigned long long)rv);
+			}
+			break;
+		}
+
+		offset += align_size;
+	}
+
+	return rv;
+}
+
+/*
+ * Read the lockspace and each resource, replace the lockspace name,
+ * and write it back.
+ */
+
+int lm_rename_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_args)
+{
+	struct sanlk_lockspace ss;
+	struct sanlk_resourced rd;
+	struct sanlk_disk disk;
+	char lock_lv_name[MAX_ARGS];
+	uint64_t offset;
+	uint32_t io_timeout;
+	int align_size;
+	int i, rv;
+
+	memset(&disk, 0, sizeof(disk));
+	memset(lock_lv_name, 0, sizeof(lock_lv_name));
+
+	if (!vg_args || !vg_args[0] || !strcmp(vg_args, "none")) {
+		log_error("S %s rename_vg_san vg_args missing", ls_name);
+		return -EINVAL;
+	}
+
+	rv = lock_lv_name_from_args(vg_args, lock_lv_name);
+	if (rv < 0) {
+		log_error("S %s init_lv_san lock_lv_name_from_args error %d %s",
+			  ls_name, rv, vg_args);
+		return rv;
+	}
+
+	snprintf(disk.path, SANLK_PATH_LEN, "/dev/mapper/%s-%s", vg_name, lock_lv_name);
+
+	log_debug("S %s rename_vg_san path %s", ls_name, disk.path);
+
+	if (daemon_test)
+		return 0;
+
+	/* FIXME: device is not always ready for us here */
+	sleep(1);
+
+	align_size = sanlock_align(&disk);
+	if (align_size <= 0) {
+		log_error("S %s rename_vg_san bad align size %d %s",
+			  ls_name, align_size, disk.path);
+		return -EINVAL;
+	}
+
+	/*
+	 * Lockspace
+	 */
+
+	memset(&ss, 0, sizeof(ss));
+	memcpy(ss.host_id_disk.path, disk.path, SANLK_PATH_LEN);
+	ss.host_id_disk.offset = LS_BEGIN * align_size;
+
+	rv = sanlock_read_lockspace(&ss, 0, &io_timeout);
+	if (rv < 0) {
+		log_error("S %s rename_vg_san read_lockspace error %d %s",
+			  ls_name, rv, ss.host_id_disk.path);
+		return rv;
+	}
+
+	strncpy(ss.name, ls_name, SANLK_NAME_LEN);
+
+	rv = sanlock_write_lockspace(&ss, 0, 0, sanlock_io_timeout);
+	if (rv < 0) {
+		log_error("S %s rename_vg_san write_lockspace error %d %s",
+			  ls_name, rv, ss.host_id_disk.path);
+		return rv;
+	}
+
+	/*
+	 * GL resource
+	 */
+
+	memset(&rd, 0, sizeof(rd));
+	memcpy(rd.rs.disks[0].path, disk.path, SANLK_PATH_LEN);
+	rd.rs.disks[0].offset = align_size * GL_LOCK_BEGIN;
+	rd.rs.num_disks = 1;
+
+	rv = sanlock_read_resource(&rd.rs, 0);
+	if (rv < 0) {
+		log_error("S %s rename_vg_san read_resource gl error %d %s",
+			  ls_name, rv, rd.rs.disks[0].path);
+		return rv;
+	}
+
+	strncpy(rd.rs.lockspace_name, ss.name, SANLK_NAME_LEN);
+
+	rv = sanlock_write_resource(&rd.rs, 0, 0, 0);
+	if (rv < 0) {
+		log_error("S %s rename_vg_san write_resource gl error %d %s",
+			  ls_name, rv, rd.rs.disks[0].path);
+		return rv;
+	}
+
+	/*
+	 * VG resource
+	 */
+
+	memset(&rd, 0, sizeof(rd));
+	memcpy(rd.rs.disks[0].path, disk.path, SANLK_PATH_LEN);
+	rd.rs.disks[0].offset = align_size * VG_LOCK_BEGIN;
+	rd.rs.num_disks = 1;
+
+	rv = sanlock_read_resource(&rd.rs, 0);
+	if (rv < 0) {
+		log_error("S %s rename_vg_san write_resource vg error %d %s",
+			  ls_name, rv, rd.rs.disks[0].path);
+		return rv;
+	}
+
+	strncpy(rd.rs.lockspace_name, ss.name, SANLK_NAME_LEN);
+
+	rv = sanlock_write_resource(&rd.rs, 0, 0, 0);
+	if (rv < 0) {
+		log_error("S %s rename_vg_san write_resource vg error %d %s",
+			  ls_name, rv, rd.rs.disks[0].path);
+		return rv;
+	}
+
+	/*
+	 * LV resources
+	 */
+
+	offset = align_size * LV_LOCK_BEGIN;
+
+	for (i = 0; ; i++) {
+		memset(&rd, 0, sizeof(rd));
+		memcpy(rd.rs.disks[0].path, disk.path, SANLK_PATH_LEN);
+		rd.rs.disks[0].offset = offset;
+		rd.rs.num_disks = 1;
+
+		rv = sanlock_read_resource(&rd.rs, 0);
+		if (rv == -EMSGSIZE || rv == -ENOSPC) {
+			/* This indicates the end of the device is reached. */
+			rv = -EMSGSIZE;
+			break;
+		}
+
+		if (rv < 0) {
+			log_error("S %s rename_vg_san read_resource resource area %llu error %d",
+				  ls_name, (unsigned long long)offset, rv);
+			break;
+		}
+
+		strncpy(rd.rs.lockspace_name, ss.name, SANLK_NAME_LEN);
+
+		rv = sanlock_write_resource(&rd.rs, 0, 0, 0);
+		if (rv) {
+			log_error("S %s rename_vg_san write_resource resource area %llu error %d",
+				  ls_name, (unsigned long long)offset, rv);
+			break;
+		}
+		offset += align_size;
+	}
+
+	return 0;
+}
+
+/* lvremove */
+int lm_free_lv_sanlock(struct lockspace *ls, struct resource *r)
+{
+	struct rd_sanlock *rds = (struct rd_sanlock *)r->lm_data;
+	struct sanlk_resource *rs = &rds->rs;
+	int rv;
+
+	log_debug("S %s R %s free_lv_san", ls->name, r->name);
+
+	if (daemon_test)
+		return 0;
+
+	strcpy(rs->name, "#unused");
+
+	rv = sanlock_write_resource(rs, 0, 0, 0);
+	if (rv < 0) {
+		log_error("S %s R %s free_lv_san write error %d",
+			  ls->name, r->name, rv);
+	}
+
+	return rv;
+}
+
+int lm_ex_disable_gl_sanlock(struct lockspace *ls)
+{
+	struct lm_sanlock *lms = (struct lm_sanlock *)ls->lm_data;
+	struct sanlk_resourced rd1;
+	struct sanlk_resourced rd2;
+	struct sanlk_resource *rs1;
+	struct sanlk_resource *rs2;
+	struct sanlk_resource **rs_args;
+	int rv;
+
+	rs_args = malloc(2 * sizeof(struct sanlk_resource *));
+	if (!rs_args)
+		return -ENOMEM;
+
+	rs1 = &rd1.rs;
+	rs2 = &rd2.rs;
+
+	memset(&rd1, 0, sizeof(rd1));
+	memset(&rd2, 0, sizeof(rd2));
+
+	strncpy(rd1.rs.lockspace_name, ls->name, SANLK_NAME_LEN);
+	strncpy(rd1.rs.name, R_NAME_GL, SANLK_NAME_LEN);
+
+	strncpy(rd2.rs.lockspace_name, ls->name, SANLK_NAME_LEN);
+	strncpy(rd2.rs.name, R_NAME_GL_DISABLED, SANLK_NAME_LEN);
+
+	rd1.rs.num_disks = 1;
+	strncpy(rd1.rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN);
+	rd1.rs.disks[0].offset = lms->align_size * GL_LOCK_BEGIN;
+
+	rv = sanlock_acquire(lms->sock, -1, 0, 1, &rs1, NULL);
+	if (rv < 0) {
+		log_error("S %s ex_disable_gl_san acquire error %d",
+			  ls->name, rv);
+		goto out;
+	}
+
+	rs_args[0] = rs1;
+	rs_args[1] = rs2;
+
+	rv = sanlock_release(lms->sock, -1, SANLK_REL_RENAME, 2, rs_args);
+	if (rv < 0) {
+		log_error("S %s ex_disable_gl_san release_rename error %d",
+			  ls->name, rv);
+	}
+
+out:
+	free(rs_args);
+	return rv;
+}
+
+/*
+ * enable/disable exist because each vg contains a global lock,
+ * but we only want to use the gl from one of them.  The first
+ * sanlock vg created, has its gl enabled, and subsequent
+ * sanlock vgs have their gl disabled.  If the vg containing the
+ * gl is removed, the gl from another sanlock vg needs to be
+ * enabled.  Or, if gl in multiple vgs are somehow enabled, we
+ * want to be able to disable one of them.
+ *
+ * Disable works by naming/renaming the gl resource to have a
+ * name that is different from the predefined name.
+ * When a host attempts to acquire the gl with its standard
+ * predefined name, it will fail because the resource's name
+ * on disk doesn't match.
+ */
+
+int lm_able_gl_sanlock(struct lockspace *ls, int enable)
+{
+	struct lm_sanlock *lms = (struct lm_sanlock *)ls->lm_data;
+	struct sanlk_resourced rd;
+	const char *gl_name;
+	int rv;
+
+	if (enable)
+		gl_name = R_NAME_GL;
+	else
+		gl_name = R_NAME_GL_DISABLED;
+
+	memset(&rd, 0, sizeof(rd));
+
+	strncpy(rd.rs.lockspace_name, ls->name, SANLK_NAME_LEN);
+	strncpy(rd.rs.name, gl_name, SANLK_NAME_LEN);
+
+	rd.rs.num_disks = 1;
+	strncpy(rd.rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN);
+	rd.rs.disks[0].offset = lms->align_size * GL_LOCK_BEGIN;
+
+	rv = sanlock_write_resource(&rd.rs, 0, 0, 0);
+	if (rv < 0) {
+		log_error("S %s able_gl %d write_resource gl error %d %s",
+			  ls->name, enable, rv, rd.rs.disks[0].path);
+		return rv;
+	}
+
+	log_debug("S %s able_gl %s", ls->name, gl_name);
+
+	ls->sanlock_gl_enabled = enable;
+	if (ls->sanlock_gl_dup && !enable)
+		ls->sanlock_gl_dup = 0;
+
+	if (enable)
+		strncpy(gl_lsname_sanlock, ls->name, MAX_NAME);
+
+	if (!enable && !strcmp(gl_lsname_sanlock, ls->name))
+		memset(gl_lsname_sanlock, 0, sizeof(gl_lsname_sanlock));
+
+	return 0;
+}
+
+static int gl_is_enabled(struct lockspace *ls, struct lm_sanlock *lms)
+{
+	char strname[SANLK_NAME_LEN + 1];
+	struct sanlk_resourced rd;
+	uint64_t offset;
+	int rv;
+
+	memset(&rd, 0, sizeof(rd));
+
+	strncpy(rd.rs.lockspace_name, ls->name, SANLK_NAME_LEN);
+
+	/* leave rs.name empty, it is what we're checking */
+
+	rd.rs.num_disks = 1;
+	strncpy(rd.rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN);
+
+	offset = lms->align_size * GL_LOCK_BEGIN;
+	rd.rs.disks[0].offset = offset;
+
+	rv = sanlock_read_resource(&rd.rs, 0);
+	if (rv < 0) {
+		log_error("gl_is_enabled read_resource error %d", rv);
+		return rv;
+	}
+
+	memset(strname, 0, sizeof(strname));
+	memcpy(strname, rd.rs.name, SANLK_NAME_LEN);
+
+	if (!strcmp(strname, R_NAME_GL_DISABLED)) {
+		return 0;
+	}
+
+	if (!strcmp(strname, R_NAME_GL)) {
+		return 1;
+	}
+
+	log_error("gl_is_enabled invalid gl name %s", strname);
+	return -1;
+}
+
+int lm_gl_is_enabled(struct lockspace *ls)
+{
+	int rv;
+	rv = gl_is_enabled(ls, ls->lm_data);
+	ls->sanlock_gl_enabled = rv;
+	return rv;
+}
+
+/*
+ * This is called at the beginning of lvcreate to
+ * ensure there is free space for a new LV lock.
+ * If not, lvcreate will extend the lvmlock lv
+ * before continuing with creating the new LV.
+ * This way, lm_init_lv_san() should find a free
+ * lock (unless the autoextend of lvmlock lv has
+ * been disabled.)
+ */
+
+int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free_offset)
+{
+	struct lm_sanlock *lms = (struct lm_sanlock *)ls->lm_data;
+	struct sanlk_resourced rd;
+	uint64_t offset;
+	int rv;
+
+	if (daemon_test)
+		return 0;
+
+	memset(&rd, 0, sizeof(rd));
+
+	strncpy(rd.rs.lockspace_name, ls->name, SANLK_NAME_LEN);
+	rd.rs.num_disks = 1;
+	strncpy(rd.rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN);
+
+	offset = lms->align_size * LV_LOCK_BEGIN;
+
+	while (1) {
+		rd.rs.disks[0].offset = offset;
+
+		memset(rd.rs.name, 0, SANLK_NAME_LEN);
+
+		rv = sanlock_read_resource(&rd.rs, 0);
+		if (rv == -EMSGSIZE || rv == -ENOSPC) {
+			/* This indicates the end of the device is reached. */
+			log_debug("S %s find_free_lock_san read limit offset %llu",
+				  ls->name, (unsigned long long)offset);
+			return -EMSGSIZE;
+		}
+
+		/*
+		 * If we read newly extended space, it will not be initialized
+		 * with an "#unused" resource, but will return an error about
+		 * an invalid paxos structure on disk.
+		 */
+		if (rv == SANLK_LEADER_MAGIC) {
+			log_debug("S %s find_free_lock_san found empty area at %llu",
+				  ls->name, (unsigned long long)offset);
+			*free_offset = offset;
+			return 0;
+		}
+
+		if (rv) {
+			log_error("S %s find_free_lock_san read error %d offset %llu",
+				  ls->name, rv, (unsigned long long)offset);
+			break;
+		}
+
+		if (!strcmp(rd.rs.name, "#unused")) {
+			log_debug("S %s find_free_lock_san found unused area at %llu",
+				  ls->name, (unsigned long long)offset);
+			*free_offset = offset;
+			return 0;
+		}
+
+		offset += lms->align_size;
+	}
+
+	return rv;
+}
+
+/*
+ * host A: start_vg/add_lockspace
+ * host B: vgremove
+ *
+ * The global lock cannot always be held around start_vg
+ * on host A because the gl is in a vg that may not be
+ * started yet, or may be in the vg we are starting.
+ *
+ * If B removes the vg, destroying the delta leases,
+ * while A is a lockspace member, it will cause A's
+ * sanlock delta lease renewal to fail, and lockspace
+ * recovery.
+ *
+ * I expect this overlap would usually cause a failure
+ * in the add_lockspace() on host A when it sees that
+ * the lockspace structures have been clobbered by B.
+ * Having add_lockspace() fail should be a fine result.
+ *
+ * If add_lockspace was somehow able to finish, the
+ * subsequent renewal would probably fail instead.
+ * This should also not create any major problems.
+ */
+
+int lm_prepare_lockspace_sanlock(struct lockspace *ls)
+{
+	struct stat st;
+	struct lm_sanlock *lms = NULL;
+	char lock_lv_name[MAX_ARGS];
+	char lsname[SANLK_NAME_LEN + 1];
+	char disk_path[SANLK_PATH_LEN];
+	int gl_found;
+	int ret, rv;
+
+	memset(disk_path, 0, sizeof(disk_path));
+	memset(lock_lv_name, 0, sizeof(lock_lv_name));
+
+	rv = check_args_version(ls->vg_args, VG_LOCK_ARGS_MAJOR);
+	if (rv < 0) {
+		ret = -EARGS;
+		goto fail;
+	}
+
+	rv = lock_lv_name_from_args(ls->vg_args, lock_lv_name);
+	if (rv < 0) {
+		log_error("S %s prepare_lockspace_san lock_lv_name_from_args error %d %s",
+			  ls->name, rv, ls->vg_args);
+		ret = -EARGS;
+		goto fail;
+	}
+
+	snprintf(disk_path, SANLK_PATH_LEN, "/dev/mapper/%s-%s",
+		 ls->vg_name, lock_lv_name);
+
+	/*
+	 * When a vg is started, the internal sanlock lv should be
+	 * activated before lvmlockd is asked to add the lockspace.
+	 * (sanlock needs to use the lv.)
+	 *
+	 * In the future we might be able to ask something on the system
+	 * to activate the sanlock lv from here, and with that we might be
+	 * able to start sanlock VGs without requiring a
+	 * vgchange --lock-start command.
+	 */
+
+	/* FIXME: device is not always ready for us here */
+	sleep(1);
+
+	rv = stat(disk_path, &st);
+	if (rv < 0) {
+		log_error("S %s prepare_lockspace_san stat error %d disk_path %s",
+			  ls->name, errno, disk_path);
+		ret = -EARGS;
+		goto fail;
+	}
+
+	if (!ls->host_id) {
+		if (daemon_host_id)
+			ls->host_id = daemon_host_id;
+		else if (daemon_host_id_file)
+			ls->host_id = read_host_id_file();
+	}
+
+	if (!ls->host_id || ls->host_id > 2000) {
+		log_error("S %s prepare_lockspace_san invalid host_id %llu",
+			  ls->name, (unsigned long long)ls->host_id);
+		ret = -EHOSTID;
+		goto fail;
+	}
+
+	lms = malloc(sizeof(struct lm_sanlock));
+	if (!lms) {
+		ret = -ENOMEM;
+		goto fail;
+	}
+
+	memset(lsname, 0, sizeof(lsname));
+	strncpy(lsname, ls->name, SANLK_NAME_LEN);
+
+	memset(lms, 0, sizeof(struct lm_sanlock));
+	memcpy(lms->ss.name, lsname, SANLK_NAME_LEN);
+	lms->ss.host_id_disk.offset = 0;
+	lms->ss.host_id = ls->host_id;
+	strncpy(lms->ss.host_id_disk.path, disk_path, SANLK_PATH_LEN);
+
+	if (daemon_test) {
+		if (!gl_lsname_sanlock[0]) {
+			strncpy(gl_lsname_sanlock, lsname, MAX_NAME);
+			log_debug("S %s prepare_lockspace_san use global lock", lsname);
+		}
+		goto out;
+	}
+
+	lms->sock = sanlock_register();
+	if (lms->sock < 0) {
+		log_error("S %s prepare_lockspace_san register error %d", lsname, lms->sock);
+		lms->sock = 0;
+		ret = -EMANAGER;
+		goto fail;
+	}
+
+	rv = sanlock_restrict(lms->sock, SANLK_RESTRICT_SIGKILL);
+	if (rv < 0) {
+		log_error("S %s restrict error %d", lsname, rv);
+		ret = -EMANAGER;
+		goto fail;
+	}
+
+	lms->align_size = sanlock_align(&lms->ss.host_id_disk);
+	if (lms->align_size <= 0) {
+		log_error("S %s prepare_lockspace_san align error %d", lsname, lms->align_size);
+		ret = -EMANAGER;
+		goto fail;
+	}
+
+	gl_found = gl_is_enabled(ls, lms);
+	if (gl_found < 0) {
+		log_error("S %s prepare_lockspace_san gl_enabled error %d", lsname, gl_found);
+		ret = -EARGS;
+		goto fail;
+	}
+
+	ls->sanlock_gl_enabled = gl_found;
+
+	if (gl_found) {
+		if (gl_use_dlm) {
+			log_error("S %s prepare_lockspace_san gl_use_dlm is set", lsname);
+		} else if (gl_lsname_sanlock[0] && strcmp(gl_lsname_sanlock, lsname)) {
+			log_error("S %s prepare_lockspace_san multiple sanlock global locks current %s",
+				  lsname, gl_lsname_sanlock);
+		} else {
+			strncpy(gl_lsname_sanlock, lsname, MAX_NAME);
+			log_debug("S %s prepare_lockspace_san use global lock %s",
+				  lsname, gl_lsname_sanlock);
+		}
+	}
+
+out:
+	ls->lm_data = lms;
+	log_debug("S %s prepare_lockspace_san done", lsname);
+	return 0;
+
+fail:
+	if (lms && lms->sock)
+		close(lms->sock);
+	if (lms)
+		free(lms);
+	return ret;
+}
+
+int lm_add_lockspace_sanlock(struct lockspace *ls, int adopt)
+{
+	struct lm_sanlock *lms = (struct lm_sanlock *)ls->lm_data;
+	int rv;
+
+	rv = sanlock_add_lockspace_timeout(&lms->ss, 0, sanlock_io_timeout);
+	if (rv == -EEXIST && adopt) {
+		/* We could alternatively just skip the sanlock call for adopt. */
+		log_debug("S %s add_lockspace_san adopt found ls", ls->name);
+		goto out;
+	}
+	if (rv < 0) {
+		/* retry for some errors? */
+		log_error("S %s add_lockspace_san add_lockspace error %d", ls->name, rv);
+		goto fail;
+	}
+
+	/*
+	 * Don't let the lockspace be cleanly released if orphan locks
+	 * exist, because the orphan locks are still protecting resources
+	 * that are being used on the host, e.g. active lvs.  If the
+	 * lockspace is cleanly released, another host could acquire the
+	 * orphan leases.
+	 */
+
+	rv = sanlock_set_config(ls->name, 0, SANLK_CONFIG_USED_BY_ORPHANS, NULL);
+	if (rv < 0) {
+		log_error("S %s add_lockspace_san set_config error %d", ls->name, rv);
+		sanlock_rem_lockspace(&lms->ss, 0);
+		goto fail;
+	}
+
+out:
+	log_debug("S %s add_lockspace_san done", ls->name);
+	return 0;
+
+fail:
+	close(lms->sock);
+	free(lms);
+	ls->lm_data = NULL;
+	return rv;
+}
+
+int lm_rem_lockspace_sanlock(struct lockspace *ls, int free_vg)
+{
+	struct lm_sanlock *lms = (struct lm_sanlock *)ls->lm_data;
+	int rv;
+
+	if (daemon_test)
+		goto out;
+
+	rv = sanlock_rem_lockspace(&lms->ss, 0);
+	if (rv < 0) {
+		log_error("S %s rem_lockspace_san error %d", ls->name, rv);
+		return rv;
+	}
+
+	if (free_vg) {
+		/*
+		 * Destroy sanlock lockspace (delta leases).  Forces failure for any
+		 * other host that is still using or attempts to use this lockspace.
+		 * This shouldn't be generally necessary, but there may some races
+		 * between nodes starting and removing a vg which this could help.
+		 */
+		strncpy(lms->ss.name, "#unused", SANLK_NAME_LEN);
+
+		rv = sanlock_write_lockspace(&lms->ss, 0, 0, sanlock_io_timeout);
+		if (rv < 0) {
+			log_error("S %s rem_lockspace free_vg write_lockspace error %d %s",
+				  ls->name, rv, lms->ss.host_id_disk.path);
+		}
+	}
+out:
+	close(lms->sock);
+
+	free(lms);
+	ls->lm_data = NULL;
+
+	/* FIXME: should we only clear gl_lsname when doing free_vg? */
+
+	if (!strcmp(ls->name, gl_lsname_sanlock))
+		memset(gl_lsname_sanlock, 0, sizeof(gl_lsname_sanlock));
+
+	return 0;
+}
+
+static int lm_add_resource_sanlock(struct lockspace *ls, struct resource *r)
+{
+	struct lm_sanlock *lms = (struct lm_sanlock *)ls->lm_data;
+	struct rd_sanlock *rds = (struct rd_sanlock *)r->lm_data;
+
+	strncpy(rds->rs.lockspace_name, ls->name, SANLK_NAME_LEN);
+	strncpy(rds->rs.name, r->name, SANLK_NAME_LEN);
+	rds->rs.num_disks = 1;
+	memcpy(rds->rs.disks[0].path, lms->ss.host_id_disk.path, SANLK_PATH_LEN);
+
+	if (r->type == LD_RT_GL)
+		rds->rs.disks[0].offset = GL_LOCK_BEGIN * lms->align_size;
+	else if (r->type == LD_RT_VG)
+		rds->rs.disks[0].offset = VG_LOCK_BEGIN * lms->align_size;
+
+	/* LD_RT_LV offset is set in each lm_lock call from lv_args. */
+
+	if (r->type == LD_RT_GL || r->type == LD_RT_VG) {
+		rds->vb = malloc(sizeof(struct val_blk));
+		if (!rds->vb)
+			return -ENOMEM;
+		memset(rds->vb, 0, sizeof(struct val_blk));
+	}
+
+	return 0;
+}
+
+int lm_rem_resource_sanlock(struct lockspace *ls, struct resource *r)
+{
+	struct rd_sanlock *rds = (struct rd_sanlock *)r->lm_data;
+
+	/* FIXME: assert r->mode == UN or unlock if it's not? */
+
+	if (rds->vb)
+		free(rds->vb);
+
+	memset(rds, 0, sizeof(struct rd_sanlock));
+	r->lm_init = 0;
+	return 0;
+}
+
+int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
+		    uint32_t *r_version, int *retry, int adopt)
+{
+	struct lm_sanlock *lms = (struct lm_sanlock *)ls->lm_data;
+	struct rd_sanlock *rds = (struct rd_sanlock *)r->lm_data;
+	struct sanlk_resource *rs;
+	uint64_t lock_lv_offset;
+	uint32_t flags = 0;
+	struct val_blk vb;
+	uint16_t vb_version;
+	int added = 0;
+	int rv;
+
+	if (!r->lm_init) {
+		rv = lm_add_resource_sanlock(ls, r);
+		if (rv < 0)
+			return rv;
+		r->lm_init = 1;
+		added = 1;
+	}
+
+	rs = &rds->rs;
+
+	if (r->type == LD_RT_LV) {
+		/*
+		 * The lv may have been removed and recreated with a new lease
+		 * offset, so we need to get the offset from lv_args each time
+		 * instead of reusing the value that we last set in rds->rs.
+		 * act->lv_args is copied to r->lv_args before every lm_lock().
+		 */
+
+		rv = check_args_version(r->lv_args, LV_LOCK_ARGS_MAJOR);
+		if (rv < 0) {
+			log_error("S %s R %s lock_san wrong lv_args version %s",
+				  ls->name, r->name, r->lv_args);
+			return rv;
+		}
+
+		rv = lock_lv_offset_from_args(r->lv_args, &lock_lv_offset);
+		if (rv < 0) {
+			log_error("S %s R %s lock_san lv_offset_from_args error %d %s",
+				  ls->name, r->name, rv, r->lv_args);
+			return rv;
+		}
+
+		if (!added && (rds->rs.disks[0].offset != lock_lv_offset)) {
+			log_debug("S %s R %s lock_san offset old %llu new %llu",
+				  ls->name, r->name,
+				  (unsigned long long)rds->rs.disks[0].offset,
+				  (unsigned long long)lock_lv_offset);
+		}
+
+		rds->rs.disks[0].offset = lock_lv_offset;
+	}
+
+	if (ld_mode == LD_LK_SH) {
+		rs->flags |= SANLK_RES_SHARED;
+	} else if (ld_mode == LD_LK_EX) {
+		rs->flags &= ~SANLK_RES_SHARED;
+	} else {
+		log_error("lock_san invalid mode %d", ld_mode);
+		return -EINVAL;
+	}
+
+	/*
+	 * Use PERSISTENT because if lvmlockd exits while holding
+	 * a lock, it's not safe to simply clear/drop the lock while
+	 * a command or lv is using it.
+	 */
+
+	rs->flags |= SANLK_RES_PERSISTENT;
+
+	log_debug("S %s R %s lock_san acquire %s:%llu",
+		  ls->name, r->name, rs->disks[0].path,
+		  (unsigned long long)rs->disks[0].offset);
+
+	if (daemon_test) {
+		*r_version = 0;
+		return 0;
+	}
+
+	if (rds->vb)
+		flags |= SANLK_ACQUIRE_LVB;
+	if (adopt)
+		flags |= SANLK_ACQUIRE_ORPHAN_ONLY;
+
+	rv = sanlock_acquire(lms->sock, -1, flags, 1, &rs, NULL);
+
+	if (rv == -EAGAIN) {
+		/*
+		 * It appears that sanlock_acquire returns EAGAIN when we request
+		 * a shared lock but the lock is held ex by another host.
+		 * There's no point in retrying this case, just return an error.
+		 */
+		log_debug("S %s R %s lock_san acquire mode %d rv EAGAIN", ls->name, r->name, ld_mode);
+		*retry = 0;
+		return -EAGAIN;
+	}
+
+	if ((rv == -EMSGSIZE) && (r->type == LD_RT_LV)) {
+		/*
+		 * sanlock tried to read beyond the end of the device,
+		 * so the offset of the lv lease is beyond the end of the
+		 * device, which means that the lease lv was extended, and
+		 * the lease for this lv was allocated in the new space.
+		 * The lvm command will see this error, refresh the lvmlock
+		 * lv, and try again.
+		 */
+		log_debug("S %s R %s lock_san acquire offset %llu rv EMSGSIZE",
+			  ls->name, r->name, (unsigned long long)rs->disks[0].offset);
+		*retry = 0;
+		return -EMSGSIZE;
+	}
+
+	if (adopt && (rv == -EUCLEAN)) {
+		/*
+		 * The orphan lock exists but in a different mode than we asked
+		 * for, so the caller should try again with the other mode.
+		 */
+		log_debug("S %s R %s lock_san adopt mode %d try other mode",
+			  ls->name, r->name, ld_mode);
+		*retry = 0;
+		return -EUCLEAN;
+	}
+
+	if (adopt && (rv == -ENOENT)) {
+		/*
+		 * No orphan lock exists.
+		 */
+		log_debug("S %s R %s lock_san adopt mode %d no orphan found",
+			  ls->name, r->name, ld_mode);
+		*retry = 0;
+		return -ENOENT;
+	}
+
+	if (rv == SANLK_ACQUIRE_IDLIVE || rv == SANLK_ACQUIRE_OWNED || rv == SANLK_ACQUIRE_OTHER) {
+		/*
+		 * The lock is held by another host.  These failures can
+		 * happen while multiple hosts are concurrently acquiring
+		 * shared locks.  We want to retry a couple times in this
+		 * case because we'll probably get the sh lock.
+		 *
+		 * I believe these are also the errors when requesting an
+		 * ex lock that another host holds ex.  We want to report
+		 * something like: "lock is held by another host" in this case.
+		 * Retry is pointless here.
+		 *
+		 * We can't distinguish between the two cases above,
+		 * so if requesting a sh lock, retry a couple times,
+		 * otherwise don't.
+		 */
+		log_debug("S %s R %s lock_san acquire mode %d rv %d", ls->name, r->name, ld_mode, rv);
+		*retry = (ld_mode == LD_LK_SH) ? 1 : 0;
+		return -EAGAIN;
+	}
+
+	if (rv < 0) {
+		log_error("S %s R %s lock_san acquire error %d",
+			  ls->name, r->name, rv);
+
+		if (added) {
+			lm_rem_resource_sanlock(ls, r);
+			return rv;
+		}
+
+		/* if the gl has been disabled, remove and free the gl resource */
+		if ((rv == SANLK_LEADER_RESOURCE) && (r->type == LD_RT_GL)) {
+			if (!lm_gl_is_enabled(ls)) {
+				log_error("S %s R %s lock_san gl has been disabled",
+					  ls->name, r->name);
+				if (!strcmp(gl_lsname_sanlock, ls->name))
+					memset(gl_lsname_sanlock, 0, sizeof(gl_lsname_sanlock));
+				return -EUNATCH;
+			}
+		}
+
+		return rv;
+	}
+
+	if (rds->vb) {
+		rv = sanlock_get_lvb(0, rs, (char *)&vb, sizeof(vb));
+		if (rv < 0) {
+			log_error("S %s R %s lock_san get_lvb error %d", ls->name, r->name, rv);
+			*r_version = 0;
+			goto out;
+		}
+
+		vb_version = le16_to_cpu(vb.version);
+
+		if (vb_version && ((vb_version & 0xFF00) > (VAL_BLK_VERSION & 0xFF00))) {
+			log_error("S %s R %s lock_san ignore vb_version %x",
+				  ls->name, r->name, vb_version);
+			*r_version = 0;
+			free(rds->vb);
+			rds->vb = NULL;
+			goto out;
+		}
+
+		*r_version = le32_to_cpu(vb.r_version);
+		memcpy(rds->vb, &vb, sizeof(vb)); /* rds->vb saved as le */
+
+		log_debug("S %s R %s lock_san get r_version %u",
+			  ls->name, r->name, *r_version);
+	}
+out:
+	return rv;
+}
+
+int lm_convert_sanlock(struct lockspace *ls, struct resource *r,
+		       int ld_mode, uint32_t r_version)
+{
+	struct lm_sanlock *lms = (struct lm_sanlock *)ls->lm_data;
+	struct rd_sanlock *rds = (struct rd_sanlock *)r->lm_data;
+	struct sanlk_resource *rs = &rds->rs;
+	struct val_blk vb;
+	uint32_t flags = 0;
+	int rv;
+
+	log_debug("S %s R %s convert_san", ls->name, r->name);
+
+	if (daemon_test)
+		goto rs_flag;
+
+	if (rds->vb && r_version && (r->mode == LD_LK_EX)) {
+		if (!rds->vb->version) {
+			/* first time vb has been written */
+			rds->vb->version = cpu_to_le16(VAL_BLK_VERSION);
+		}
+		if (r_version)
+			rds->vb->r_version = cpu_to_le32(r_version);
+		memcpy(&vb, rds->vb, sizeof(vb));
+
+		log_debug("S %s R %s convert_san set r_version %u",
+			  ls->name, r->name, r_version);
+
+		rv = sanlock_set_lvb(0, rs, (char *)&vb, sizeof(vb));
+		if (rv < 0) {
+			log_error("S %s R %s convert_san set_lvb error %d",
+				  ls->name, r->name, rv);
+		}
+	}
+
+ rs_flag:
+	if (ld_mode == LD_LK_SH)
+		rs->flags |= SANLK_RES_SHARED;
+	else
+		rs->flags &= ~SANLK_RES_SHARED;
+
+	if (daemon_test)
+		return 0;
+
+	rv = sanlock_convert(lms->sock, -1, flags, rs);
+	if (rv == -EAGAIN) {
+		/* FIXME: When could this happen?  Should something different be done? */
+		log_error("S %s R %s convert_san EAGAIN", ls->name, r->name);
+		return -EAGAIN;
+	}
+	if (rv < 0) {
+		log_error("S %s R %s convert_san convert error %d", ls->name, r->name, rv);
+	}
+
+	return rv;
+}
+
+static int release_rename(struct lockspace *ls, struct resource *r)
+{
+	struct rd_sanlock rd1;
+	struct rd_sanlock rd2;
+	struct sanlk_resource *res1;
+	struct sanlk_resource *res2;
+	struct sanlk_resource **res_args;
+	struct lm_sanlock *lms = (struct lm_sanlock *)ls->lm_data;
+	struct rd_sanlock *rds = (struct rd_sanlock *)r->lm_data;
+	int rv;
+
+	log_debug("S %s R %s release rename", ls->name, r->name);
+
+	res_args = malloc(2 * sizeof(struct sanlk_resource *));
+	if (!res_args)
+		return -ENOMEM;
+
+	memcpy(&rd1, rds, sizeof(struct rd_sanlock));
+	memcpy(&rd2, rds, sizeof(struct rd_sanlock));
+
+	res1 = (struct sanlk_resource *)&rd1;
+	res2 = (struct sanlk_resource *)&rd2;
+
+	strcpy(res2->name, "invalid_removed");
+
+	res_args[0] = res1;
+	res_args[1] = res2;
+
+	rv = sanlock_release(lms->sock, -1, SANLK_REL_RENAME, 2, res_args);
+	if (rv < 0) {
+		log_error("S %s R %s unlock_san release rename error %d", ls->name, r->name, rv);
+	}
+
+	free(res_args);
+
+	return rv;
+}
+
+/*
+ * rds->vb is stored in le
+ * 
+ * r_version is r->version
+ *
+ * for GL locks lvmlockd just increments this value
+ * each time the global lock is released from ex.
+ *
+ * for VG locks it is the seqno from the vg metadata.
+ */
+
+int lm_unlock_sanlock(struct lockspace *ls, struct resource *r,
+		      uint32_t r_version, uint32_t lmu_flags)
+{
+	struct lm_sanlock *lms = (struct lm_sanlock *)ls->lm_data;
+	struct rd_sanlock *rds = (struct rd_sanlock *)r->lm_data;
+	struct sanlk_resource *rs = &rds->rs;
+	struct val_blk vb;
+	int rv;
+
+	log_debug("S %s R %s unlock_san r_version %u flags %x",
+		  ls->name, r->name, r_version, lmu_flags);
+
+	if (daemon_test)
+		return 0;
+
+	if (rds->vb && r_version && (r->mode == LD_LK_EX)) {
+		if (!rds->vb->version) {
+			/* first time vb has been written */
+			rds->vb->version = cpu_to_le16(VAL_BLK_VERSION);
+		}
+		if (r_version)
+			rds->vb->r_version = cpu_to_le32(r_version);
+		memcpy(&vb, rds->vb, sizeof(vb));
+
+		log_debug("S %s R %s unlock_san set r_version %u",
+			  ls->name, r->name, r_version);
+
+		rv = sanlock_set_lvb(0, rs, (char *)&vb, sizeof(vb));
+		if (rv < 0) {
+			log_error("S %s R %s unlock_san set_lvb error %d",
+				  ls->name, r->name, rv);
+		}
+	}
+
+	/*
+	 * For vgremove (FREE_VG) we unlock-rename the vg and gl locks
+	 * so they cannot be reacquired.
+	 */
+	if ((lmu_flags & LMUF_FREE_VG) &&
+	    (r->type == LD_RT_GL || r->type == LD_RT_VG)) {
+		return release_rename(ls, r);
+	}
+
+	rv = sanlock_release(lms->sock, -1, 0, 1, &rs);
+	if (rv < 0) {
+		log_error("S %s R %s unlock_san release error %d", ls->name, r->name, rv);
+	}
+
+	return rv;
+}
+
+int lm_hosts_sanlock(struct lockspace *ls, int notify)
+{
+	struct sanlk_host *hss = NULL;
+	struct sanlk_host *hs;
+	uint32_t state;
+	int hss_count = 0;
+	int found_self = 0;
+	int found_others = 0;
+	int i, rv;
+
+	rv = sanlock_get_hosts(ls->name, 0, &hss, &hss_count, 0);
+	if (rv < 0) {
+		log_error("S %s hosts_san get_hosts error %d", ls->name, rv);
+		return 0;
+	}
+
+	if (!hss || !hss_count) {
+		log_error("S %s hosts_san zero hosts", ls->name);
+		return 0;
+	}
+
+	hs = hss;
+
+	for (i = 0; i < hss_count; i++) {
+		log_debug("S %s hosts_san host_id %llu gen %llu flags %x",
+			  ls->name,
+			  (unsigned long long)hs->host_id,
+			  (unsigned long long)hs->generation,
+			  hs->flags);
+
+		if (hs->host_id == ls->host_id) {
+			found_self = 1;
+			hs++;
+			continue;
+		}
+
+		state = hs->flags & SANLK_HOST_MASK;
+		if (state == SANLK_HOST_LIVE)
+			found_others++;
+		hs++;
+	}
+	free(hss);
+
+	if (found_others && notify) {
+		/*
+		 * We could use the sanlock event mechanism to notify lvmlockd
+		 * on other hosts to stop this VG.  lvmlockd would need to
+		 * register for and listen for sanlock events in the main loop.
+		 * The events are slow to propagate.  We'd need to retry for a
+		 * while before all the hosts see the event and stop the VG.
+		 * sanlock_set_event(ls->name, &he, SANLK_SETEV_ALL_HOSTS);
+		 *
+		 * Wait to try this until there appears to be real value/interest
+		 * in doing it.
+		 */
+	}
+
+	if (!found_self) {
+		log_error("S %s hosts_san self not found others %d", ls->name, found_others);
+		return 0;
+	}
+
+	return found_others;
+}
+
+int lm_get_lockspaces_sanlock(struct list_head *ls_rejoin)
+{
+	struct sanlk_lockspace *ss_all = NULL;
+	struct sanlk_lockspace *ss;
+	struct lockspace *ls;
+	int ss_count = 0;
+	int i, rv;
+
+	rv = sanlock_get_lockspaces(&ss_all, &ss_count, 0);
+	if (rv < 0)
+		return rv;
+
+	if (!ss_all || !ss_count)
+		return 0;
+
+	ss = ss_all;
+
+	for (i = 0; i < ss_count; i++) {
+
+		if (strncmp(ss->name, LVM_LS_PREFIX, strlen(LVM_LS_PREFIX)))
+			continue;
+
+		if (!(ls = alloc_lockspace()))
+			return -ENOMEM;
+
+		ls->lm_type = LD_LM_SANLOCK;
+		ls->host_id = ss->host_id;
+		strncpy(ls->name, ss->name, MAX_NAME);
+		strncpy(ls->vg_name, ss->name + strlen(LVM_LS_PREFIX), MAX_NAME);
+		list_add_tail(&ls->list, ls_rejoin);
+
+		ss++;
+	}
+
+	free(ss_all);
+	return 0;
+}
+
+int lm_is_running_sanlock(void)
+{
+	uint32_t daemon_version;
+	uint32_t daemon_proto;
+	int rv;
+
+	rv = sanlock_version(0, &daemon_version, &daemon_proto);
+	if (rv < 0)
+		return 0;
+	return 1;
+}
+
diff --git a/include/.symlinks.in b/include/.symlinks.in
index d6a95fd..dc4456a 100644
--- a/include/.symlinks.in
+++ b/include/.symlinks.in
@@ -3,11 +3,13 @@
 @top_srcdir@/daemons/lvmetad/lvmetad-client.h
 @top_srcdir@/daemons/lvmpolld/lvmpolld-protocol.h
 @top_srcdir@/daemons/lvmpolld/polling_ops.h
+ at top_srcdir@/daemons/lvmlockd/lvmlockd-client.h
 @top_srcdir@/liblvm/lvm2app.h
 @top_srcdir@/lib/activate/activate.h
 @top_srcdir@/lib/activate/targets.h
 @top_srcdir@/lib/cache/lvmcache.h
 @top_srcdir@/lib/cache/lvmetad.h
+@top_srcdir@/lib/locking/lvmlockd.h
 @top_srcdir@/lib/commands/toolcontext.h
 @top_srcdir@/lib/config/config.h
 @top_srcdir@/lib/config/config_settings.h
diff --git a/lib/Makefile.in b/lib/Makefile.in
index ffe18f0..dbd4e3f 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -200,6 +200,11 @@ ifeq ("@BUILD_LVMPOLLD@", "yes")
 	lvmpolld/lvmpolld-client.c
 endif
 
+ifeq ("@BUILD_LVMLOCKD@", "yes")
+  SOURCES +=\
+	locking/lvmlockd.c
+endif
+
 ifeq ("@DMEVENTD@", "yes")
   CLDFLAGS += -L$(top_builddir)/daemons/dmeventd
   LIBS += -ldevmapper-event
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 01c3f08..783a114 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -22,6 +22,7 @@
 #include "format-text.h" // TODO for disk_locn, used as a DA representation
 #include "crc.h"
 #include "lvm-signal.h"
+#include "lvmlockd.h"
 
 #define SCAN_TIMEOUT_SECONDS	80
 #define MAX_RESCANS		10	/* Maximum number of times to scan all PVs and retry if the daemon returns a token mismatch error */
@@ -1494,9 +1495,16 @@ void lvmetad_validate_global_cache(struct cmd_context *cmd, int force)
 	dm_list_init(&pvc_before);
 	dm_list_init(&pvc_after);
 
+	if (!lvmlockd_use()) {
+		log_error(INTERNAL_ERROR "validate global cache without lvmlockd");
+		return;
+	}
+
 	if (!lvmetad_used())
 		return;
 
+	log_debug_lvmetad("Validating global lvmetad cache");
+
 	if (force)
 		goto do_scan;
 
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 46d83b3..5e43dd8 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -99,9 +99,14 @@ struct cmd_context {
 
 	unsigned independent_metadata_areas:1;	/* Active formats have MDAs outside PVs */
 	unsigned unknown_system_id:1;
-	unsigned include_foreign_vgs:1;
-	unsigned include_active_foreign_vgs:1;
-	unsigned error_foreign_vgs:1;
+	unsigned include_foreign_vgs:1; /* report/display cmds can reveal foreign VGs */
+	unsigned include_shared_vgs:1;  /* report/display cmds can reveal lockd VGs */
+	unsigned include_active_foreign_vgs:1; /* cmd should process foreign VGs with active LVs */
+	unsigned vg_read_print_access_error:1; /* print access errors from vg_read */
+	unsigned lockd_gl_disable:1;
+	unsigned lockd_vg_disable:1;
+	unsigned lockd_lv_disable:1;
+	unsigned lockd_vg_default_sh:1;
 
 	struct dev_types *dev_types;
 
@@ -144,6 +149,11 @@ struct cmd_context {
 	const char *report_list_item_separator;
 	int hosttags;
 
+	/* Locking */
+	const char *lock_gl_mode; /* gl mode, from --lock-gl */
+	const char *lock_vg_mode; /* vg mode, from --lock-vg */
+	const char *lock_lv_mode; /* lv mode, from --lock-lv */
+
 	const char *lib_dir;		/* Cache value global/library_dir */
 	char system_dir[PATH_MAX];
 	char dev_dir[PATH_MAX];
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 68f593d..5d042c9 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -831,6 +831,27 @@ cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL,
 	"LVM prints warnings and ignores lvmetad if this combination\n"
 	"is seen.\n")
 
+cfg(global_use_lvmlockd_CFG, "use_lvmlockd", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 124), NULL, 0, NULL,
+	"Use lvmlockd for locking among hosts using LVM on shared storage.\n")
+
+cfg(global_lock_retries_CFG, "lock_retries", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_LOCK_RETRIES, vsn(2, 2, 124), NULL, 0, NULL,
+	"Retry lvmlockd lock requests this many times.\n")
+
+cfg(global_sanlock_lv_extend_CFG, "sanlock_lv_extend", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_SANLOCK_LV_EXTEND_MB, vsn(2, 2, 124), NULL, 0, NULL,
+	"Size in MiB to extend the internal LV holding sanlock locks.\n"
+	"The internal LV holds locks for each LV in the VG, and after\n"
+	"enough LVs have been created, the internal LV needs to be extended.\n"
+	"lvcreate will automatically extend the internal LV when needed by\n"
+	"the amount specified here.  Setting this to 0 disables the\n"
+	"automatic extension and can cause lvcreate to fail.\n")
+
+cfg(global_allow_override_lock_modes_CFG, "allow_override_lock_modes", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 124), NULL, 0, NULL,
+	"Allow command options to override normal locking.\n")
+
+cfg(global_read_only_lock_modes_CFG, "read_only_lock_modes", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 124), NULL, 0, NULL,
+	"Limit commands to actions that use read locks.\n"
+	"This disallows any actions that require a write (exclusive) lock.\n")
+
 cfg(global_thin_check_executable_CFG, "thin_check_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, THIN_CHECK_CMD, vsn(2, 2, 94), "@THIN_CHECK_CMD@", 0, NULL,
 	"The full path to the thin_check command.\n"
 	"LVM uses this command to check that a thin metadata\n"
@@ -1256,6 +1277,14 @@ cfg(activation_mode_CFG, "activation_mode", activation_CFG_SECTION, 0, CFG_TYPE_
 	"sometimes assist with data recovery.\n"
 	"The '--activationmode' option overrides this setting.\n")
 
+cfg_array(activation_lock_start_list_CFG, "lock_start_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY|CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 124), NULL, 0, NULL,
+	"Locking is started only for VGs selected by this list.\n"
+	"The rules are the same as those for LVs in volume_list.\n")
+
+cfg_array(activation_auto_lock_start_list_CFG, "auto_lock_start_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY|CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 124), NULL, 0, NULL,
+	"Locking is auto-started only for VGs selected by this list.\n"
+	"The rules are the same as those for LVs in auto_activation_volume_list.\n")
+
 cfg(metadata_pvmetadatacopies_CFG, "pvmetadatacopies", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_PVMETADATACOPIES, vsn(1, 0, 0), NULL, 0, NULL,
 	"Number of copies of metadata to store on each PV.\n"
 	"Possible options are: 0, 1, 2.\n"
@@ -1580,4 +1609,9 @@ cfg_array(local_extra_system_ids_CFG, "extra_system_ids", local_CFG_SECTION, CFG
 	"Use this only after consulting 'man lvmsystemid'\n"
 	"to be certain of correct usage and possible dangers.\n")
 
+cfg(local_host_id_CFG, "host_id", local_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, 0, vsn(2, 2, 124), NULL, 0, NULL,
+	"The lvmlockd sanlock host_id.\n"
+	"This must be a unique among all hosts,\n"
+	"and must be between 1 and 2000.\n")
+
 cfg(CFG_COUNT, NULL, root_CFG_SECTION, 0, CFG_TYPE_INT, 0, vsn(0, 0, 0), NULL, 0, NULL, NULL)
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 2d74c17..6d3fec0 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -51,11 +51,14 @@
 #define DEFAULT_FALLBACK_TO_LOCAL_LOCKING 1
 #define DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING 1
 #define DEFAULT_WAIT_FOR_LOCKS 1
+#define DEFAULT_LOCK_RETRIES 3
 #define DEFAULT_PRIORITISE_WRITE_LOCKS 1
 #define DEFAULT_USE_MLOCKALL 0
 #define DEFAULT_METADATA_READ_ONLY 0
 #define DEFAULT_LVDISPLAY_SHOWS_FULL_DEVICE_PATH 0
 
+#define DEFAULT_SANLOCK_LV_EXTEND_MB 256
+
 #define DEFAULT_MIRRORLOG MIRROR_LOG_DISK
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
 #define DEFAULT_MIRROR_IMAGE_FAULT_POLICY "remove"
@@ -221,4 +224,6 @@
 #define DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD 100
 #define DEFAULT_THIN_POOL_AUTOEXTEND_PERCENT 20
 
+#define DEFAULT_CY_LOCK_TYPE "sanlock"
+
 #endif				/* _LVM_DEFAULTS_H */
diff --git a/lib/display/display.c b/lib/display/display.c
index 98433e7..62ad1fe 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -86,6 +86,38 @@ alloc_policy_t get_alloc_from_string(const char *str)
 	return ALLOC_INVALID;
 }
 
+const char *get_lock_type_string(lock_type_t lock_type)
+{
+	switch (lock_type) {
+	case LOCK_TYPE_INVALID:
+		return "invalid";
+	case LOCK_TYPE_NONE:
+		return "none";
+	case LOCK_TYPE_CLVM:
+		return "clvm";
+	case LOCK_TYPE_DLM:
+		return "dlm";
+	case LOCK_TYPE_SANLOCK:
+		return "sanlock";
+	}
+	return "invalid";
+}
+
+lock_type_t get_lock_type_from_string(const char *str)
+{
+	if (!str)
+		return LOCK_TYPE_NONE;
+	if (!strcmp(str, "none"))
+		return LOCK_TYPE_NONE;
+	if (!strcmp(str, "clvm"))
+		return LOCK_TYPE_CLVM;
+	if (!strcmp(str, "dlm"))
+		return LOCK_TYPE_DLM;
+	if (!strcmp(str, "sanlock"))
+		return LOCK_TYPE_SANLOCK;
+	return LOCK_TYPE_INVALID;
+}
+
 static const char *_percent_types[7] = { "NONE", "VG", "FREE", "LV", "PVS", "ORIGIN" };
 
 const char *get_percent_string(percent_type_t def)
diff --git a/lib/display/display.h b/lib/display/display.h
index cc5654b..f4e766c 100644
--- a/lib/display/display.h
+++ b/lib/display/display.h
@@ -64,6 +64,9 @@ const char *get_alloc_string(alloc_policy_t alloc);
 char alloc_policy_char(alloc_policy_t alloc);
 alloc_policy_t get_alloc_from_string(const char *str);
 
+const char *get_lock_type_string(lock_type_t lock_type);
+lock_type_t get_lock_type_from_string(const char *str);
+
 const char *get_percent_string(percent_type_t def);
 
 char yes_no_prompt(const char *prompt, ...) __attribute__ ((format(printf, 1, 2)));
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 11766ac..ee9a9cf 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -472,8 +472,11 @@ static int _print_vg(struct formatter *f, struct volume_group *vg)
 	else if (vg->lvm1_system_id && *vg->lvm1_system_id)
 		outf(f, "system_id = \"%s\"", vg->lvm1_system_id);
 
-	if (vg->lock_type)
+	if (vg->lock_type) {
 		outf(f, "lock_type = \"%s\"", vg->lock_type);
+		if (vg->lock_args)
+			outf(f, "lock_args = \"%s\"", vg->lock_args);
+	}
 
 	outsize(f, (uint64_t) vg->extent_size, "extent_size = %u",
 		vg->extent_size);
@@ -699,6 +702,9 @@ static int _print_lv(struct formatter *f, struct logical_volume *lv)
 		      lv->timestamp);
 	}
 
+	if (lv->lock_args)
+		outf(f, "lock_args = \"%s\"", lv->lock_args);
+
 	if (lv->alloc != ALLOC_INHERIT)
 		outf(f, "allocation_policy = \"%s\"",
 		     get_alloc_string(lv->alloc));
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index bbd47c3..717ef65 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -67,6 +67,7 @@ static const struct flag _lv_flags[] = {
 	{LV_NOSCAN, NULL, 0},
 	{LV_TEMPORARY, NULL, 0},
 	{POOL_METADATA_SPARE, NULL, 0},
+	{LOCKD_SANLOCK_LV, NULL, 0},
 	{RAID, NULL, 0},
 	{RAID_META, NULL, 0},
 	{RAID_IMAGE, NULL, 0},
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 931aff8..3645fa2 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -20,6 +20,7 @@
 #include "toolcontext.h"
 #include "lvmcache.h"
 #include "lvmetad.h"
+#include "lvmlockd.h"
 #include "lv_alloc.h"
 #include "pv_alloc.h"
 #include "segtype.h"
@@ -599,6 +600,11 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 		return 0;
 	}
 
+	if (dm_config_get_str(lvn, "lock_args", &str)) {
+		if (!(lv->lock_args = dm_pool_strdup(mem, str)))
+			return_0;
+	}
+
 	lv->alloc = ALLOC_INHERIT;
 	if (dm_config_get_str(lvn, "allocation_policy", &str)) {
 		lv->alloc = get_alloc_from_string(str);
@@ -664,6 +670,12 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 		vg->pool_metadata_spare_lv = lv;
 	}
 
+	if (!lv_is_visible(lv) && !strcmp(lv->name, LOCKD_SANLOCK_LV_NAME)) {
+		log_debug_metadata("Logical volume %s is sanlock lv.", lv->name);
+		lv->status |= LOCKD_SANLOCK_LV;
+		vg->sanlock_lv = lv;
+	}
+
 	return 1;
 }
 
@@ -816,6 +828,11 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 			goto bad;
 	}
 
+	if (dm_config_get_str(vgn, "lock_args", &str)) {
+		if (!(vg->lock_args = dm_pool_strdup(vg->vgmem, str)))
+			goto bad;
+	}
+
 	if (!_read_id(&vg->id, vgn, "id")) {
 		log_error("Couldn't read uuid for volume group %s.", vg->name);
 		goto bad;
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
new file mode 100644
index 0000000..55a64a1
--- /dev/null
+++ b/lib/locking/lvmlockd.c
@@ -0,0 +1,2588 @@
+/*
+ * Copyright (C) 2014 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ */
+
+#include "lib.h"
+#include "toolcontext.h"
+#include "metadata.h"
+#include "segtype.h"
+#include "activate.h"
+#include "lvmetad.h"
+#include "lvmlockd.h"
+#include "lvmcache.h"
+#include "lvmlockd-client.h"
+
+static daemon_handle _lvmlockd;
+static const char *_lvmlockd_socket = NULL;
+static struct cmd_context *_lvmlockd_cmd = NULL;
+static int _use_lvmlockd = 0;         /* is 1 if command is configured to use lvmlockd */
+static int _lvmlockd_connected = 0;   /* is 1 if command is connected to lvmlockd */
+static int _lvmlockd_init_failed = 0; /* used to suppress further warnings */
+
+void lvmlockd_set_socket(const char *sock)
+{
+	_lvmlockd_socket = sock;
+}
+
+/*
+ * Set directly from global/use_lvmlockd
+ */
+void lvmlockd_set_use(int use)
+{
+	_use_lvmlockd = use;
+}
+
+/*
+ * Returns the value of global/use_lvmlockd being used by the command.
+ */
+int lvmlockd_use(void)
+{
+	return _use_lvmlockd;
+}
+
+/*
+ * The command continues even if init and/or connect fail,
+ * because the command is allowed to use local VGs without lvmlockd,
+ * and is allowed to read lockd VGs without locks from lvmlockd.
+ */
+void lvmlockd_init(struct cmd_context *cmd)
+{
+	if (!_use_lvmlockd) {
+		/* Should never happen, don't call init when not using lvmlockd. */
+		log_error("Should not initialize lvmlockd with use_lvmlockd=0.");
+	}
+
+	if (!_lvmlockd_socket) {
+		log_warn("WARNING: lvmlockd socket location is not configured.");
+		_lvmlockd_init_failed = 1;
+	}
+
+	if (!!access(LVMLOCKD_PIDFILE, F_OK)) {
+		log_warn("WARNING: lvmlockd process is not running.");
+		_lvmlockd_init_failed = 1;
+	} else {
+		_lvmlockd_init_failed = 0;
+	}
+
+	_lvmlockd_cmd = cmd;
+}
+
+void lvmlockd_connect(void)
+{
+	if (!_use_lvmlockd) {
+		/* Should never happen, don't call connect when not using lvmlockd. */
+		log_error("Should not connect to lvmlockd with use_lvmlockd=0.");
+	}
+
+	if (_lvmlockd_connected) {
+		/* Should never happen, only call connect once. */
+		log_error("lvmlockd is already connected.");
+	}
+
+	if (_lvmlockd_init_failed)
+		return;
+
+	_lvmlockd = lvmlockd_open(_lvmlockd_socket);
+
+	if (_lvmlockd.socket_fd >= 0 && !_lvmlockd.error) {
+		log_debug("Successfully connected to lvmlockd on fd %d.", _lvmlockd.socket_fd);
+		_lvmlockd_connected = 1;
+	} else {
+		log_warn("WARNING: lvmlockd connect failed.");
+	}
+}
+
+void lvmlockd_disconnect(void)
+{
+	if (_lvmlockd_connected)
+		daemon_close(_lvmlockd);
+	_lvmlockd_connected = 0;
+	_lvmlockd_cmd = NULL;
+}
+
+/* Translate the result strings from lvmlockd to bit flags. */
+static void _flags_str_to_lockd_flags(const char *flags_str, uint32_t *lockd_flags)
+{
+	if (strstr(flags_str, "NO_LOCKSPACES"))
+		*lockd_flags |= LD_RF_NO_LOCKSPACES;
+
+	if (strstr(flags_str, "NO_GL_LS"))
+		*lockd_flags |= LD_RF_NO_GL_LS;
+
+	if (strstr(flags_str, "LOCAL_LS"))
+		*lockd_flags |= LD_RF_LOCAL_LS;
+
+	if (strstr(flags_str, "DUP_GL_LS"))
+		*lockd_flags |= LD_RF_DUP_GL_LS;
+
+	if (strstr(flags_str, "INACTIVE_LS"))
+		*lockd_flags |= LD_RF_INACTIVE_LS;
+
+	if (strstr(flags_str, "ADD_LS_ERROR"))
+		*lockd_flags |= LD_RF_ADD_LS_ERROR;
+}
+
+/*
+ * evaluate the reply from lvmlockd, check for errors, extract
+ * the result and lockd_flags returned by lvmlockd.
+ * 0 failure (no result/lockd_flags set)
+ * 1 success (result/lockd_flags set)
+ */
+
+/*
+ * This is an arbitrary number that we know lvmlockd
+ * will not return.  daemon_reply_int reverts to this
+ * value if it finds no result value.
+ */
+#define NO_LOCKD_RESULT -1000
+
+static int _lockd_result(daemon_reply reply, int *result, uint32_t *lockd_flags)
+{
+	int reply_result;
+	const char *flags_str = NULL;
+	const char *lock_type = NULL;
+
+	if (reply.error) {
+		log_error("lockd_result reply error %d", reply.error);
+		return 0;
+	}
+
+	if (strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
+		log_error("lockd_result bad response");
+		return 0;
+	}
+
+	reply_result = daemon_reply_int(reply, "op_result", NO_LOCKD_RESULT);
+	if (reply_result == NO_LOCKD_RESULT) {
+		log_error("lockd_result no op_result");
+		return 0;
+	}
+
+	/* The lock_type that lvmlockd used for locking. */
+	lock_type = daemon_reply_str(reply, "lock_type", "none");
+
+	*result = reply_result;
+
+	if (lockd_flags) {
+		if ((flags_str = daemon_reply_str(reply, "result_flags", NULL)))
+			_flags_str_to_lockd_flags(flags_str, lockd_flags);
+	}
+
+	log_debug("lockd_result %d flags %s lm %s", reply_result,
+		  flags_str ? flags_str : "none", lock_type);
+	return 1;
+}
+
+static daemon_reply _lockd_send(const char *req_name, ...)
+{
+	va_list ap;
+	daemon_reply repl;
+	daemon_request req;
+
+	req = daemon_request_make(req_name);
+
+	va_start(ap, req_name);
+	daemon_request_extend_v(req, ap);
+	va_end(ap);
+
+	repl = daemon_send(_lvmlockd, req);
+
+	daemon_request_destroy(req);
+
+	return repl;
+}
+
+/*
+ * result/lockd_flags are values returned from lvmlockd.
+ *
+ * return 0 (failure)
+ * return 1 (result/lockd_flags indicate success/failure)
+ *
+ * return 1 result 0   (success)
+ * return 1 result < 0 (failure)
+ *
+ * caller may ignore result < 0 failure depending on
+ * lockd_flags and the specific command/mode.
+ *
+ * When this function returns 0 (failure), no result/lockd_flags
+ * were obtained from lvmlockd.
+ *
+ * When this function returns 1 (success), result/lockd_flags may
+ * have been obtained from lvmlockd.  This lvmlockd result may
+ * indicate a locking failure.
+ */
+
+static int _lockd_request(struct cmd_context *cmd,
+		          const char *req_name,
+		          const char *vg_name,
+		          const char *vg_lock_type,
+		          const char *vg_lock_args,
+		          const char *lv_name,
+		          const char *lv_uuid,
+		          const char *lv_lock_args,
+		          const char *mode,
+		          const char *opts,
+		          int *result,
+		          uint32_t *lockd_flags)
+{
+	const char *cmd_name = get_cmd_name();
+	daemon_reply reply;
+	int pid = getpid();
+
+	*result = 0;
+	*lockd_flags = 0;
+
+	if (!strcmp(mode, "na"))
+		return 1;
+
+	if (!_use_lvmlockd)
+		return 0;
+	if (!_lvmlockd_connected)
+		return 0;
+
+	/* cmd and pid are passed for informational and debugging purposes */
+
+	if (!cmd_name || !cmd_name[0])
+		cmd_name = "none";
+
+	if (vg_name && lv_name) {
+		reply = _lockd_send(req_name,
+					"cmd = %s", cmd_name,
+					"pid = %d", pid,
+					"mode = %s", mode,
+					"opts = %s", opts ?: "none",
+					"vg_name = %s", vg_name,
+					"lv_name = %s", lv_name,
+					"lv_uuid = %s", lv_uuid,
+					"vg_lock_type = %s", vg_lock_type ?: "none",
+					"vg_lock_args = %s", vg_lock_args ?: "none",
+					"lv_lock_args = %s", lv_lock_args ?: "none",
+					NULL);
+
+		if (!_lockd_result(reply, result, lockd_flags))
+			goto fail;
+
+		log_debug("lvmlockd %s %s vg %s lv %s result %d %x",
+			  req_name, mode, vg_name, lv_name, *result, *lockd_flags);
+
+	} else if (vg_name) {
+		reply = _lockd_send(req_name,
+					"cmd = %s", cmd_name,
+					"pid = %d", pid,
+					"mode = %s", mode,
+					"opts = %s", opts ?: "none",
+					"vg_name = %s", vg_name,
+					"vg_lock_type = %s", vg_lock_type ?: "none",
+					"vg_lock_args = %s", vg_lock_args ?: "none",
+					NULL);
+
+		if (!_lockd_result(reply, result, lockd_flags))
+			goto fail;
+
+		log_debug("lvmlockd %s %s vg %s result %d %x",
+			  req_name, mode, vg_name, *result, *lockd_flags);
+
+	} else {
+		reply = _lockd_send(req_name,
+					"cmd = %s", cmd_name,
+					"pid = %d", pid,
+					"mode = %s", mode,
+					"opts = %s", opts ?: "none",
+					"vg_lock_type = %s", vg_lock_type ?: "none",
+					NULL);
+
+		if (!_lockd_result(reply, result, lockd_flags))
+			goto fail;
+
+		log_debug("lvmlockd %s %s result %d %x",
+			  req_name, mode, *result, *lockd_flags);
+	}
+
+	daemon_reply_destroy(reply);
+
+	/* result/lockd_flags have lvmlockd result */
+	return 1;
+
+ fail:
+	/* no result was obtained from lvmlockd */
+
+	log_error("lvmlockd %s %s failed no result", req_name, mode);
+
+	daemon_reply_destroy(reply);
+	return 0;
+}
+
+/*
+ * Eventually add an option to specify which pv the lvmlock lv should be placed on.
+ * FIXME: when converting a VG from lock_type none to sanlock, we need to count
+ * the number of existing LVs to ensure that the new sanlock_lv is large enough
+ * for all of them that need locks.
+ */
+
+static int _create_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg,
+			      const char *lock_lv_name, int extend_mb)
+{
+	struct logical_volume *lv;
+	struct lvcreate_params lp = {
+		.activate = CHANGE_ALY,
+		.alloc = ALLOC_INHERIT,
+		.extents = (extend_mb * 1024 * 1024) / (vg->extent_size * SECTOR_SIZE),
+		.major = -1,
+		.minor = -1,
+		.permission = LVM_READ | LVM_WRITE,
+		.pvh = &vg->pvs,
+		.read_ahead = DM_READ_AHEAD_NONE,
+		.stripes = 1,
+		.vg_name = vg->name,
+		.lv_name = dm_pool_strdup(cmd->mem, lock_lv_name),
+		.zero = 1,
+	};
+
+	dm_list_init(&lp.tags);
+
+	if (!(lp.segtype = get_segtype_from_string(vg->cmd, "striped")))
+		return_0;
+
+	lv = lv_create_single(vg, &lp);
+	if (!lv) {
+		log_error("Failed to create sanlock lv %s in vg %s", lock_lv_name, vg->name);
+		return 0;
+	}
+
+	vg->sanlock_lv = lv;
+
+	return 1;
+}
+
+static int _remove_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg)
+{
+	if (!lv_remove(vg->sanlock_lv)) {
+		log_error("Failed to remove sanlock LV %s/%s", vg->name, vg->sanlock_lv->name);
+		return 0;
+	}
+
+	return 1;
+}
+
+static int _extend_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg, int extend_mb)
+{
+	struct logical_volume *lv = vg->sanlock_lv;
+	struct lvresize_params lp = {
+		.lv_name = vg->sanlock_lv->name,
+		.sign = SIGN_NONE,
+		.percent = PERCENT_NONE,
+		.resize = LV_EXTEND,
+		.ac_force = 1,
+		.sizeargs = 1,
+	};
+
+	lp.size = lv->size + ((extend_mb * 1024 * 1024) / SECTOR_SIZE);
+
+	if (!lv_resize_prepare(cmd, lv, &lp, &vg->pvs) ||
+	    !lv_resize(cmd, lv, &lp, &vg->pvs)) {
+		log_error("Extend LV %s/%s to size %llu failed.",
+			  vg->name, lv->name, (unsigned long long)lp.size);
+		return 0;
+	}
+
+	return 1;
+}
+
+/* When one host does _extend_sanlock_lv, the others need to refresh the size. */
+
+static int _refresh_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg)
+{
+	if (!lv_refresh_suspend_resume(cmd, vg->sanlock_lv)) {
+		log_error("Failed to refresh %s.", vg->sanlock_lv->name);
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
+ * Called at the beginning of lvcreate in a sanlock VG to ensure
+ * that there is space in the sanlock LV for a new lock.  If it's
+ * full, then this extends it.
+ */
+
+int handle_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg)
+{
+	daemon_reply reply;
+	int extend_mb;
+	int result;
+	int ret;
+
+	if (!_use_lvmlockd)
+		return 1;
+	if (!_lvmlockd_connected)
+		return 0;
+
+	extend_mb = find_config_tree_int(cmd, global_sanlock_lv_extend_CFG, NULL);
+
+	/*
+	 * User can choose to not automatically extend the lvmlock LV
+	 * so they can manually extend it.
+	 */
+	if (!extend_mb)
+		return 1;
+
+	/*
+	 * Another host may have extended the lvmlock LV already.
+	 * Refresh so that we'll find the new space they added
+	 * when we search for new space.
+	 */
+	if (!_refresh_sanlock_lv(cmd, vg))
+		return 0;
+
+	/*
+	 * Ask lvmlockd/sanlock to look for an unused lock.
+	 */
+	reply = _lockd_send("find_free_lock",
+			"pid = %d", getpid(),
+			"vg_name = %s", vg->name,
+			NULL);
+
+	if (!_lockd_result(reply, &result, NULL)) {
+		ret = 0;
+	} else {
+		ret = (result < 0) ? 0 : 1;
+	}
+
+	/* No space on the lvmlock lv for a new lease. */
+	if (result == -EMSGSIZE)
+		ret = _extend_sanlock_lv(cmd, vg, extend_mb);
+
+	daemon_reply_destroy(reply);
+
+	return ret;
+}
+
+static int _activate_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg)
+{
+	if (!activate_lv(cmd, vg->sanlock_lv)) {
+		log_error("Failed to activate sanlock lv %s/%s", vg->name, vg->sanlock_lv->name);
+		return 0;
+	}
+
+	return 1;
+}
+
+static int _deactivate_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg)
+{
+	if (!deactivate_lv(cmd, vg->sanlock_lv)) {
+		log_error("Failed to deactivate sanlock lv %s/%s", vg->name, vg->sanlock_lv->name);
+		return 0;
+	}
+
+	return 1;
+}
+
+static int _init_vg_dlm(struct cmd_context *cmd, struct volume_group *vg)
+{
+	daemon_reply reply;
+	const char *reply_str;
+	const char *vg_lock_args = NULL;
+	int result;
+	int ret;
+
+	if (!_use_lvmlockd)
+		return 0;
+	if (!_lvmlockd_connected)
+		return 0;
+
+	reply = _lockd_send("init_vg",
+				"pid = %d", getpid(),
+				"vg_name = %s", vg->name,
+				"vg_lock_type = %s", "dlm",
+				NULL);
+
+	if (!_lockd_result(reply, &result, NULL)) {
+		ret = 0;
+		result = -ELOCKD;
+	} else {
+		ret = (result < 0) ? 0 : 1;
+	}
+
+	switch (result) {
+	case 0:
+		break;
+	case -ELOCKD:
+		log_error("VG %s init failed: lvmlockd not available", vg->name);
+		break;
+	case -EARGS:
+		log_error("VG %s init failed: invalid parameters for dlm", vg->name);
+		break;
+	case -EMANAGER:
+		log_error("VG %s init failed: lock manager dlm is not running", vg->name);
+		break;
+	default:
+		log_error("VG %s init failed: %d", vg->name, result);
+	}
+
+	if (!ret)
+		goto out;
+
+	if (!(reply_str = daemon_reply_str(reply, "vg_lock_args", NULL))) {
+		log_error("VG %s init failed: lock_args not returned", vg->name);
+		ret = 0;
+		goto out;
+	}
+
+	if (!(vg_lock_args = dm_pool_strdup(cmd->mem, reply_str))) {
+		log_error("VG %s init failed: lock_args alloc failed", vg->name);
+		ret = 0;
+		goto out;
+	}
+
+	vg->lock_type = "dlm";
+	vg->lock_args = vg_lock_args;
+
+	if (!vg_write(vg) || !vg_commit(vg)) {
+		log_error("VG %s init failed: vg_write vg_commit", vg->name);
+		ret = 0;
+		goto out;
+	}
+
+	ret = 1;
+out:
+	daemon_reply_destroy(reply);
+	return ret;
+}
+
+static int _init_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg)
+{
+	daemon_reply reply;
+	const char *reply_str;
+	const char *vg_lock_args = NULL;
+	const char *opts = NULL;
+	int extend_mb;
+	int result;
+	int ret;
+
+	if (!_use_lvmlockd)
+		return 0;
+	if (!_lvmlockd_connected)
+		return 0;
+
+	/*
+	 * Automatic extension of the sanlock lv is disabled by
+	 * setting sanlock_lv_extend to 0.  Zero won't work as
+	 * an initial size, so in this case, use the default as
+	 * the initial size.
+	 */
+	if (!(extend_mb = find_config_tree_int(cmd, global_sanlock_lv_extend_CFG, NULL)))
+		extend_mb = DEFAULT_SANLOCK_LV_EXTEND_MB;
+
+	/*
+	 * Creating the sanlock LV writes the VG containing the new lvmlock
+	 * LV, then activates the lvmlock LV.  The lvmlock LV must be active
+	 * before we ask lvmlockd to initialize the VG because sanlock needs
+	 * to initialize leases on the lvmlock LV.
+	 */
+	if (!_create_sanlock_lv(cmd, vg, LOCKD_SANLOCK_LV_NAME, extend_mb)) {
+		log_error("Failed to create internal lv.");
+		return 0;
+	}
+
+	/*
+	 * N.B. this passes the sanlock lv name as vg_lock_args
+	 * even though it is only part of the final args string
+	 * which will be returned from lvmlockd.
+	 */
+
+	reply = _lockd_send("init_vg",
+				"pid = %d", getpid(),
+				"vg_name = %s", vg->name,
+				"vg_lock_type = %s", "sanlock",
+				"vg_lock_args = %s", vg->sanlock_lv->name,
+				"opts = %s", opts ?: "none",
+				NULL);
+
+	if (!_lockd_result(reply, &result, NULL)) {
+		ret = 0;
+		result = -ELOCKD;
+	} else {
+		ret = (result < 0) ? 0 : 1;
+	}
+
+	switch (result) {
+	case 0:
+		break;
+	case -ELOCKD:
+		log_error("VG %s init failed: lvmlockd not available", vg->name);
+		break;
+	case -EARGS:
+		log_error("VG %s init failed: invalid parameters for sanlock", vg->name);
+		break;
+	case -EMANAGER:
+		log_error("VG %s init failed: lock manager sanlock is not running", vg->name);
+		break;
+	case -EMSGSIZE:
+		log_error("VG %s init failed: no disk space for leases", vg->name);
+		break;
+	default:
+		log_error("VG %s init failed: %d", vg->name, result);
+	}
+
+	if (!ret)
+		goto out;
+
+	if (!(reply_str = daemon_reply_str(reply, "vg_lock_args", NULL))) {
+		log_error("VG %s init failed: lock_args not returned", vg->name);
+		ret = 0;
+		goto out;
+	}
+
+	if (!(vg_lock_args = dm_pool_strdup(cmd->mem, reply_str))) {
+		log_error("VG %s init failed: lock_args alloc failed", vg->name);
+		ret = 0;
+		goto out;
+	}
+
+	lv_set_hidden(vg->sanlock_lv);
+	vg->sanlock_lv->status |= LOCKD_SANLOCK_LV;
+
+	vg->lock_type = "sanlock";
+	vg->lock_args = vg_lock_args;
+
+	if (!vg_write(vg) || !vg_commit(vg)) {
+		log_error("VG %s init failed: vg_write vg_commit", vg->name);
+		ret = 0;
+		goto out;
+	}
+
+	ret = 1;
+out:
+	if (!ret) {
+		/*
+		 * The usleep delay gives sanlock time to close the lock lv,
+		 * and usually avoids having an annoying error printed.
+		 */
+		usleep(1000000);
+		_deactivate_sanlock_lv(cmd, vg);
+		_remove_sanlock_lv(cmd, vg);
+		if (!vg_write(vg) || !vg_commit(vg))
+			stack;
+	}
+
+	daemon_reply_destroy(reply);
+	return ret;
+}
+
+/* called after vg_remove on disk */
+
+static int _free_vg_dlm(struct cmd_context *cmd, struct volume_group *vg)
+{
+	uint32_t lockd_flags;
+	int result;
+	int ret;
+
+	if (!_use_lvmlockd)
+		return 0;
+	if (!_lvmlockd_connected)
+		return 0;
+
+	/*
+	 * Unlocking the vg lock here preempts the lvmlockd unlock in
+	 * toollib.c which happens too late since the lockspace is
+	 * left here.
+	 */
+
+	/* Equivalent to a standard unlock. */
+	ret = _lockd_request(cmd, "lock_vg",
+			     vg->name, NULL, NULL, NULL, NULL, NULL, "un", NULL,
+			     &result, &lockd_flags);
+
+	if (!ret || result < 0) {
+		log_error("_free_vg_dlm lvmlockd result %d", result);
+		return 0;
+	}
+
+	/* Leave the dlm lockspace. */
+	lockd_stop_vg(cmd, vg);
+
+	return 1;
+}
+
+/* called before vg_remove on disk */
+
+static int _free_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg)
+{
+	daemon_reply reply;
+	int result;
+	int ret;
+
+	if (!_use_lvmlockd)
+		return 0;
+	if (!_lvmlockd_connected)
+		return 0;
+
+	if (!vg->lock_args || !strlen(vg->lock_args)) {
+		/* Shouldn't happen in general, but maybe in some error cases? */
+		log_debug("_free_vg_sanlock %s no lock_args", vg->name);
+		return 1;
+	}
+
+	reply = _lockd_send("free_vg",
+				"pid = %d", getpid(),
+				"vg_name = %s", vg->name,
+				"vg_lock_type = %s", vg->lock_type,
+				"vg_lock_args = %s", vg->lock_args,
+				NULL);
+
+	if (!_lockd_result(reply, &result, NULL)) {
+		ret = 0;
+	} else {
+		ret = (result < 0) ? 0 : 1;
+	}
+
+	/*
+	 * Other hosts could still be joined to the lockspace, which means they
+	 * are using the internal sanlock LV, which means we cannot remove the
+	 * VG.  Once other hosts stop using the VG it can be removed.
+	 */
+	if (result == -EBUSY) {
+		log_error("Lockspace for \"%s\" not stopped on other hosts", vg->name);
+		goto out;
+	}
+
+	if (!ret) {
+		log_error("_free_vg_sanlock lvmlockd result %d", result);
+		goto out;
+	}
+
+	/*
+	 * The usleep delay gives sanlock time to close the lock lv,
+	 * and usually avoids having an annoying error printed.
+	 */
+	usleep(1000000);
+
+	_deactivate_sanlock_lv(cmd, vg);
+	_remove_sanlock_lv(cmd, vg);
+ out:
+	daemon_reply_destroy(reply);
+
+	return ret;
+}
+
+/*
+ * Tell lvmlockd to forget about an old VG name.
+ * lvmlockd remembers previous lockd VGs so that it can provide more
+ * informative error messages (see INACTIVE_LS, ADD_LS_ERROR).
+ *
+ * If a new local VG is created with the same name as a previous lockd VG,
+ * lvmlockd's memory of the previous lockd VG interferes (causes incorrect
+ * lockd_vg failures).
+ *
+ * We could also remove the list of inactive (old) VG names from lvmlockd,
+ * and then this function would not be needed, but this would also reduce
+ * the ability to have helpful error messages.
+ */
+
+static void _forget_vg_name(struct cmd_context *cmd, struct volume_group *vg)
+{
+	daemon_reply reply;
+
+	if (!_use_lvmlockd)
+		return;
+	if (!_lvmlockd_connected)
+		return;
+
+	reply = _lockd_send("forget_vg_name",
+				"pid = %d", getpid(),
+				"vg_name = %s", vg->name,
+				NULL);
+
+	daemon_reply_destroy(reply);
+}
+
+/* vgcreate */
+
+int lockd_init_vg(struct cmd_context *cmd, struct volume_group *vg,
+		  const char *lock_type)
+{
+	switch (get_lock_type_from_string(lock_type)) {
+	case LOCK_TYPE_NONE:
+		_forget_vg_name(cmd, vg);
+		return 1;
+	case LOCK_TYPE_CLVM:
+		return 1;
+	case LOCK_TYPE_DLM:
+		return _init_vg_dlm(cmd, vg);
+	case LOCK_TYPE_SANLOCK:
+		return _init_vg_sanlock(cmd, vg);
+	default:
+		log_error("Unknown lock_type.");
+		return 0;
+	}
+}
+
+/* vgremove before the vg is removed */
+
+int lockd_free_vg_before(struct cmd_context *cmd, struct volume_group *vg)
+{
+	if (cmd->lock_vg_mode && !strcmp(cmd->lock_vg_mode, "na"))
+		return 1;
+
+	switch (get_lock_type_from_string(vg->lock_type)) {
+	case LOCK_TYPE_NONE:
+	case LOCK_TYPE_CLVM:
+	case LOCK_TYPE_DLM:
+		return 1;
+	case LOCK_TYPE_SANLOCK:
+		/* returning an error will prevent vg_remove() */
+		return _free_vg_sanlock(cmd, vg);
+	default:
+		log_error("Unknown lock_type.");
+		return 0;
+	}
+}
+
+/* vgremove after the vg is removed */
+
+void lockd_free_vg_final(struct cmd_context *cmd, struct volume_group *vg)
+{
+	if (cmd->lock_vg_mode && !strcmp(cmd->lock_vg_mode, "na"))
+		return;
+
+	switch (get_lock_type_from_string(vg->lock_type)) {
+	case LOCK_TYPE_NONE:
+	case LOCK_TYPE_CLVM:
+	case LOCK_TYPE_SANLOCK:
+		break;
+	case LOCK_TYPE_DLM:
+		_free_vg_dlm(cmd, vg);
+		break;
+	default:
+		log_error("Unknown lock_type.");
+	}
+}
+
+/*
+ * Starting a vg involves:
+ * 1. reading the vg without a lock
+ * 2. getting the lock_type/lock_args from the vg metadata
+ * 3. doing start_vg in lvmlockd for the lock_type;
+ *    this means joining the lockspace
+ *
+ * The vg read in step 1 should not be used for anything
+ * other than getting the lock_type/lock_args/uuid necessary
+ * for starting the lockspace.  To use the vg after starting
+ * the lockspace, follow the standard method which is:
+ * lock the vg, read/use/write the vg, unlock the vg.
+ */
+
+int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg)
+{
+	char uuid[64] __attribute__((aligned(8)));
+	daemon_reply reply;
+	int host_id = 0;
+	int result;
+	int ret;
+
+	memset(uuid, 0, sizeof(uuid));
+
+	if (!is_lockd_type(vg->lock_type))
+		return 1;
+
+	/* Skip starting the vg lockspace when the vg lock is skipped. */
+	if (cmd->lock_vg_mode && !strcmp(cmd->lock_vg_mode, "na"))
+		return 1;
+
+	if (!_use_lvmlockd) {
+		log_error("VG %s start failed: lvmlockd is not enabled", vg->name);
+		return 0;
+	}
+	if (!_lvmlockd_connected) {
+		log_error("VG %s start failed: lvmlockd is not running", vg->name);
+		return 0;
+	}
+
+	log_debug("lockd start VG %s lock_type %s",
+		  vg->name, vg->lock_type ? vg->lock_type : "empty");
+
+	if (vg->lock_type && !strcmp(vg->lock_type, "sanlock")) {
+		/*
+		 * This is the big difference between starting
+		 * sanlock vgs vs starting dlm vgs: the internal
+		 * sanlock lv needs to be activated before lvmlockd
+		 * does the start because sanlock needs to use the lv
+		 * to access locks.
+		 */
+		if (!_activate_sanlock_lv(cmd, vg))
+			return 0;
+
+		host_id = find_config_tree_int(cmd, local_host_id_CFG, NULL);
+	}
+
+	id_write_format(&vg->id, uuid, sizeof(uuid));
+
+	reply = _lockd_send("start_vg",
+				"pid = %d", getpid(),
+				"vg_name = %s", vg->name,
+				"vg_lock_type = %s", vg->lock_type,
+				"vg_lock_args = %s", vg->lock_args ?: "none",
+				"vg_uuid = %s", uuid[0] ? uuid : "none",
+				"version = %d", (int64_t)vg->seqno,
+				"host_id = %d", host_id,
+				NULL);
+
+	if (!_lockd_result(reply, &result, NULL)) {
+		ret = 0;
+		result = -ELOCKD;
+	} else {
+		ret = (result < 0) ? 0 : 1;
+	}
+
+	switch (result) {
+	case 0:
+		log_print_unless_silent("VG %s starting %s lockspace", vg->name, vg->lock_type);
+		break;
+	case -ELOCKD:
+		log_error("VG %s start failed: lvmlockd not available", vg->name);
+		break;
+	case -EEXIST:
+		log_debug("VG %s start error: already started", vg->name);
+		ret = 1;
+		break;
+	case -EARGS:
+		log_error("VG %s start failed: invalid parameters for %s", vg->name, vg->lock_type);
+		break;
+	case -EHOSTID:
+		log_error("VG %s start failed: invalid sanlock host_id, set in lvmlocal.conf", vg->name);
+		break;
+	case -EMANAGER:
+		log_error("VG %s start failed: lock manager %s is not running", vg->name, vg->lock_type);
+		break;
+	default:
+		log_error("VG %s start failed: %d", vg->name, result);
+	}
+
+	daemon_reply_destroy(reply);
+
+	return ret;
+}
+
+int lockd_stop_vg(struct cmd_context *cmd, struct volume_group *vg)
+{
+	daemon_reply reply;
+	int result;
+	int ret;
+
+	if (!is_lockd_type(vg->lock_type))
+		return 1;
+	if (!_use_lvmlockd)
+		return 0;
+	if (!_lvmlockd_connected)
+		return 0;
+
+	log_debug("lockd stop VG %s lock_type %s",
+		  vg->name, vg->lock_type ? vg->lock_type : "empty");
+
+	reply = _lockd_send("stop_vg",
+			"pid = %d", getpid(),
+			"vg_name = %s", vg->name,
+			NULL);
+
+	if (!_lockd_result(reply, &result, NULL)) {
+		ret = 0;
+	} else {
+		ret = (result < 0) ? 0 : 1;
+	}
+
+	if (result == -ENOLS) {
+		ret = 1;
+		goto out;
+	}
+
+	if (result == -EBUSY) {
+		log_error("VG %s stop failed: LVs must first be deactivated", vg->name);
+		goto out;
+	}
+
+	if (!ret) {
+		log_error("VG %s stop failed: %d", vg->name, result);
+		goto out;
+	}
+
+	if (!strcmp(vg->lock_type, "sanlock")) {
+		log_debug("lockd_stop_vg deactivate sanlock lv");
+		_deactivate_sanlock_lv(cmd, vg);
+	}
+out:
+	daemon_reply_destroy(reply);
+
+	return ret;
+}
+
+int lockd_start_wait(struct cmd_context *cmd)
+{
+	daemon_reply reply;
+	int result;
+	int ret;
+
+	if (!_use_lvmlockd)
+		return 0;
+	if (!_lvmlockd_connected)
+		return 0;
+
+	reply = _lockd_send("start_wait",
+			"pid = %d", getpid(),
+			NULL);
+
+	if (!_lockd_result(reply, &result, NULL)) {
+		ret = 0;
+	} else {
+		ret = (result < 0) ? 0 : 1;
+	}
+
+	if (!ret)
+		log_error("Lock start failed");
+
+	/*
+	 * FIXME: get a list of vgs that started so we can
+	 * better report what worked and what didn't?
+	 */
+
+	daemon_reply_destroy(reply);
+
+	return ret;
+}
+
+static int _mode_num(const char *mode)
+{
+	if (!strcmp(mode, "na"))
+		return -2;
+	if (!strcmp(mode, "un"))
+		return -1;
+	if (!strcmp(mode, "nl"))
+		return 0;
+	if (!strcmp(mode, "sh"))
+		return 1;
+	if (!strcmp(mode, "ex"))
+		return 2;
+	return -3;
+}
+
+/* same rules as strcmp */
+static int _mode_compare(const char *m1, const char *m2)
+{
+	int n1 = _mode_num(m1);
+	int n2 = _mode_num(m2);
+
+	if (n1 < n2)
+		return -1;
+	if (n1 == n2)
+		return 0;
+	if (n1 > n2)
+		return 1;
+	return -2;
+}
+
+/*
+ * lockd_gl_create() is a variation of lockd_gl() used only by vgcreate.
+ * It handles the case that when using sanlock, the global lock does
+ * not exist until after the first vgcreate is complete, since the global
+ * lock exists on storage within an actual VG.  So, the first vgcreate
+ * needs special logic to detect this bootstrap case.
+ *
+ * When the vgcreate is not creating the first VG, then lockd_gl_create()
+ * behaves the same as lockd_gl().
+ *
+ * vgcreate will have a lock_type for the new VG which lockd_gl_create()
+ * can provide in the lock-gl call.
+ *
+ * lockd_gl() and lockd_gl_create() differ in the specific cases where
+ * ENOLS (no lockspace found) is overriden.  In the vgcreate case, the
+ * override cases are related to sanlock bootstrap, and the lock_type of
+ * the vg being created is needed.
+ *
+ * 1. vgcreate of the first lockd-type vg calls lockd_gl_create()
+ *    to acquire the global lock.
+ *
+ * 2. vgcreate/lockd_gl_create passes gl lock request to lvmlockd,
+ *    along with lock_type of the new vg.
+ *
+ * 3. lvmlockd finds no global lockspace/lock.
+ *
+ * 4. dlm:
+ *    If the lock_type from vgcreate is dlm, lvmlockd creates the
+ *    dlm global lockspace, and queues the global lock request
+ *    for vgcreate.  lockd_gl_create returns sucess with the gl held.
+ *
+ *    sanlock:
+ *    If the lock_type from vgcreate is sanlock, lvmlockd returns -ENOLS
+ *    with the NO_GL_LS flag.  lvmlockd cannot create or acquire a sanlock
+ *    global lock until the VG exists on disk (the locks live within the VG).
+ *
+ *    lockd_gl_create sees sanlock/ENOLS/NO_GL_LS (and optionally the
+ *    "enable" lock-gl arg), determines that this is the sanlock
+ *    bootstrap special case, and returns success without the global lock.
+ *
+ *    vgcreate creates the VG on disk, and calls lockd_init_vg() which
+ *    initializes/enables a global lock on the new VG's internal sanlock lv.
+ *    Future lockd_gl/lockd_gl_create calls will acquire the existing gl.
+ */
+
+int lockd_gl_create(struct cmd_context *cmd, const char *def_mode, const char *vg_lock_type)
+{
+	const char *mode = NULL;
+	uint32_t lockd_flags;
+	int retries = 0;
+	int result;
+
+	/*
+	 * There are four variations of creating a local/lockd VG
+	 * with/without use_lvmlockd set.
+	 *
+	 * use_lvmlockd=1, lockd VG:
+	 * This function should acquire or create the global lock.
+	 *
+	 * use_lvmlockd=0, local VG:
+	 * This function is a no-op, just returns 1.
+	 *
+	 * use_lvmlockd=0, lockd VG
+	 * An error is returned in vgcreate_params_set_from_args (before this is called).
+	 *
+	 * use_lvmlockd=1, local VG
+	 * This function should acquire the global lock.
+	 */
+	if (!_use_lvmlockd) {
+		if (!is_lockd_type(vg_lock_type))
+			return 1;
+		log_error("Cannot create VG with lock_type %s without lvmlockd.", vg_lock_type);
+		return 0;
+	}
+
+	/*
+	 * A specific lock mode was given on the command line.
+	 */
+	if (cmd->lock_gl_mode) {
+		mode = cmd->lock_gl_mode;
+		if (mode && def_mode && strcmp(mode, "enable") && (_mode_compare(mode, def_mode) < 0)) {
+			if (!find_config_tree_bool(cmd, global_allow_override_lock_modes_CFG, NULL)) {
+				log_error("Disallowed lock-gl mode \"%s\"", mode);
+				return 0;
+			} else {
+				log_warn("WARNING: overriding default global lock mode.");
+			}
+		}
+	}
+
+	log_debug("lockd global lock_type %s", vg_lock_type);
+
+	if (!mode)
+		mode = def_mode;
+	if (!mode) {
+		log_error("Unknown lock-gl mode");
+		return 0;
+	}
+
+	if (!strcmp(mode, "ex") && find_config_tree_bool(cmd, global_read_only_lock_modes_CFG, NULL)) {
+		log_error("Exclusive global lock not allowed with read_only_lock_modes");
+		return 0;
+	}
+
+ req:
+	if (!_lockd_request(cmd, "lock_gl",
+			      NULL, vg_lock_type, NULL, NULL, NULL, NULL, mode, NULL,
+			      &result, &lockd_flags)) {
+		/* No result from lvmlockd, it is probably not running. */
+		log_error("Global lock failed: check that lvmlockd is running.");
+		return 0;
+	}
+
+	if (result == -EAGAIN) {
+		if (retries < find_config_tree_int(cmd, global_lock_retries_CFG, NULL)) {
+			log_warn("Retrying %s global lock", mode);
+			sleep(1);
+			retries++;
+			goto req;
+		}
+	}
+
+	/*
+	 * ENOLS: no lockspace was found with a global lock.
+	 * It may not exist (perhaps this command is creating the first),
+	 * or it may not be visible or started on the system yet.
+	 */
+
+	if (result == -ENOLS) {
+		if (!strcmp(mode, "un"))
+			return 1;
+
+		/*
+		 * This is the explicit sanlock bootstrap condition for
+		 * proceding without the global lock: a chicken/egg case
+		 * for the first sanlock VG that is created.
+		 *
+		 * When creating the first sanlock VG, there is no global
+		 * lock to acquire because the gl will exist in the VG
+		 * being created.  The "enable" option makes explicit that
+		 * this is expected:
+		 *
+		 * vgcreate --lock-type sanlock --lock-gl enable
+		 *
+		 * There are three indications that this is the unique
+		 * first-sanlock-vg bootstrap case:
+		 *
+		 * - result from lvmlockd is -ENOLS because lvmlockd found
+		 *   no lockspace for this VG; expected because it's being
+		 *   created here.
+		 *
+		 * - result flag LD_RF_NO_GL_LS from lvmlockd means that
+		 *   lvmlockd has seen no other lockspace with a global lock.
+		 *   This implies that this is probably the first sanlock vg
+		 *   to be created.  If other sanlock vgs exist, the global
+		 *   lock should be available from one of them.
+		 *
+		 * - command line lock-gl arg is "enable" which means the
+		 *   user expects this to be the first sanlock vg, and the
+		 *   global lock should be enabled in it.
+		 */
+
+		if ((lockd_flags & LD_RF_NO_GL_LS) &&
+		    !strcmp(vg_lock_type, "sanlock") &&
+		    !strcmp(mode, "enable")) {
+			log_print_unless_silent("Enabling sanlock global lock");
+			lvmetad_validate_global_cache(cmd, 1);
+			return 1;
+		}
+
+		/*
+		 * This is an implicit sanlock bootstrap condition for
+		 * proceeding without the global lock.  The command line does
+		 * not indicate explicitly that this is a bootstrap situation
+		 * (via "enable"), but it seems likely to be because lvmlockd
+		 * has seen no lockd-type vgs.  It is possible that a global
+		 * lock does exist in a vg that has not yet been seen.  If that
+		 * vg appears after this creates a new vg with a new enabled
+		 * gl, then there will be two enabled global locks, and one
+		 * will need to be disabled.  (We could instead return an error
+		 * here and insist with an error message that the --lock-gl
+		 * enable option be used to exercise the explicit case above.)
+		 */
+
+		if ((lockd_flags & LD_RF_NO_GL_LS) &&
+		    (lockd_flags & LD_RF_NO_LOCKSPACES) &&
+		    !strcmp(vg_lock_type, "sanlock")) {
+			log_print_unless_silent("Enabling sanlock global lock");
+			lvmetad_validate_global_cache(cmd, 1);
+			return 1;
+		}
+
+		if (!strcmp(vg_lock_type, "sanlock"))
+			log_error("Global lock failed: check that VG holding global lock exists and is started.");
+		else
+			log_error("Global lock failed: check that global lockspace is started.");
+		return 0;
+	}
+
+	/*
+	 * Check for each specific error that can be returned so a helpful
+	 * message can be printed for it.
+	 */
+	if (result < 0) {
+		if (result == -ESTARTING)
+			log_error("Global lock failed: lockspace is starting.");
+		else if (result -EAGAIN)
+			log_error("Global lock failed: held by other host.");
+		else
+			log_error("Global lock failed: error %d", result);
+		return 0;
+	}
+
+	lvmetad_validate_global_cache(cmd, 1);
+
+	return 1;
+}
+
+/*
+ * The global lock protects:
+ *
+ * - The global VG namespace.  Two VGs cannot have the same name.
+ *   Used by any command that creates or removes a VG name,
+ *   e.g. vgcreate, vgremove, vgrename, vgsplit, vgmerge.
+ *
+ * - The set of orphan PVs.
+ *   Used by any command that changes a non-PV device into an orphan PV,
+ *   an orphan PV into a device, a non-orphan PV (in a VG) into an orphan PV
+ *   (not in a VG), or an orphan PV into a non-orphan PV,
+ *   e.g. pvcreate, pvremove, vgcreate, vgremove, vgextend, vgreduce.
+ *
+ * - The properties of orphan PVs.  It is possible to make changes to the
+ *   properties of an orphan PV, e.g. pvresize, pvchange.
+ *
+ * These are things that cannot be protected by a VG lock alone, since
+ * orphan PVs do not belong to a real VG (an artificial VG does not
+ * apply since a sanlock lock only exists on real storage.)
+ *
+ * If a command will change any of the things above, it must first acquire
+ * the global lock in exclusive mode.
+ *
+ * If command is reading any of the things above, it must acquire the global
+ * lock in shared mode.  A number of commands read the things above, including:
+ *
+ * - Reporting/display commands which show all VGs.  Any command that
+ *   will iterate through the entire VG namespace must first acquire the
+ *   global lock shared so that it has an accurate view of the namespace.
+ *
+ * - A command where a tag name is used to identify what to process.
+ *   A tag requires reading all VGs to check if they match the tag.
+ *
+ * In these cases, the global lock must be acquired before the list of
+ * all VGs is created.
+ *
+ * The global lock is not generally unlocked explicitly in the code.
+ * When the command disconnects from lvmlockd, lvmlockd automatically
+ * releases the locks held by the command.  The exception is if a command
+ * will continue running for a long time while not needing the global lock,
+ * e.g. commands that poll to report progress.
+ *
+ * Acquiring the global lock also updates the local lvmetad cache if
+ * necessary.  lockd_gl() first acquires the lock via lvmlockd, then
+ * before returning to the caller, it checks that the global information
+ * (e.g. VG namespace, set of orphans) is up to date in lvmetad.  If
+ * not, it scans disks and updates the lvmetad cache before returning
+ * to the caller.  It does this checking using a version number associated
+ * with the global lock.  The version number is incremented each time
+ * a change is made to the state associated with the global lock, and
+ * if the local version number is lower than the version number in the
+ * lock, then the local lvmetad state must be updated.
+ *
+ * There are two cases where the global lock can be taken in shared mode,
+ * and then later converted to ex.  pvchange and pvresize use process_each_pv
+ * which does lockd_gl("sh") to get the list of VGs.  Later, in the "_single"
+ * function called within process_each_pv, the PV may be an orphan, in which
+ * case the ex global lock is needed, so it's converted to ex@that point.
+ *
+ * Effects of misconfiguring use_lvmlockd.
+ *
+ * - Setting use_lvmlockd=1 tells lvm commands to use the global lock.
+ * This should not be set unless a lock manager and lockd VGs will
+ * be used.  Setting use_lvmlockd=1 without setting up a lock manager
+ * or using lockd VGs will cause lvm commands to fail when they attempt
+ * to change any global state (requiring the ex global lock), and will
+ * cause warnings when the commands read global state (requiring the sh
+ * global lock).  In this condition, lvm is nominally useful, and existing
+ * local VGs can continue to be used mostly as usual.  But, the
+ * warnings/errors should lead a user to either set up a lock manager
+ * and lockd VGs, or set use_lvmlockd to 0.
+ *
+ * - Setting use_lvmlockd=0 tells lvm commands to not use the global lock.
+ * If use_lvmlockd=0 when lockd VGs exist which require lvmlockd, the
+ * lockd_gl() calls become no-ops, but the lockd_vg() calls for the lockd
+ * VGs will fail.  The warnings/errors from accessing the lockd VGs
+ * should lead the user to set use_lvmlockd to 1 and run the necessary
+ * lock manager.  In this condition, lvm reverts to the behavior of
+ * the following case, in which system ID largely protects shared
+ * devices, but has limitations.
+ *
+ * - Setting use_lvmlockd=0 with shared devices, no lockd VGs and
+ * no lock manager is a recognized mode of operation that is
+ * described in the lvmsystemid man page.  Using lvm on shared
+ * devices this way is made safe by using system IDs to assign
+ * ownership of VGs to single hosts.  The main limitation of this
+ * mode (among others outlined in the man page), is that orphan PVs
+ * are unprotected.
+ */
+
+int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
+{
+	const char *mode = NULL;
+	const char *opts = NULL;
+	uint32_t lockd_flags;
+	int retries = 0;
+	int result;
+
+	if (!_use_lvmlockd)
+		return 1;
+
+	if (cmd->lockd_gl_disable)
+		return 1;
+
+	if (def_mode && !strcmp(def_mode, "un")) {
+		if (cmd->lock_gl_mode && !strcmp(cmd->lock_gl_mode, "na"))
+			return 1;
+
+		mode = "un";
+		goto req;
+	}
+
+	/*
+	 * A specific lock mode was given on the command line.
+	 */
+	if (cmd->lock_gl_mode) {
+		mode = cmd->lock_gl_mode;
+		if (mode && def_mode && (_mode_compare(mode, def_mode) < 0)) {
+			if (!find_config_tree_bool(cmd, global_allow_override_lock_modes_CFG, NULL)) {
+				log_error("Disallowed lock-gl mode \"%s\"", mode);
+				return 0;
+			} else {
+				log_warn("WARNING: overriding default global lock mode.");
+			}
+		}
+	}
+
+	if (!mode)
+		mode = def_mode;
+	if (!mode) {
+		log_error("Unknown lock-gl mode");
+		return 0;
+	}
+
+	if (!strcmp(mode, "ex") && find_config_tree_bool(cmd, global_read_only_lock_modes_CFG, NULL)) {
+		log_error("Exclusive global lock not allowed with read_only_lock_modes");
+		return 0;
+	}
+
+ req:
+	log_debug("lockd global mode %s", mode);
+
+	if (!_lockd_request(cmd, "lock_gl",
+			    NULL, NULL, NULL, NULL, NULL, NULL, mode, opts,
+			    &result, &lockd_flags)) {
+		/* No result from lvmlockd, it is probably not running. */
+
+		/* We don't care if an unlock fails. */
+		if (!strcmp(mode, "un"))
+			return 1;
+
+		/* We can continue reading if a shared lock fails. */
+		if (!strcmp(mode, "sh")) {
+			log_warn("Reading without shared global lock.");
+			lvmetad_validate_global_cache(cmd, 1);
+			return 1;
+		}
+
+		log_error("Global lock failed: check that lvmlockd is running.");
+		return 0;
+	}
+
+	if (result == -EAGAIN) {
+		if (retries < find_config_tree_int(cmd, global_lock_retries_CFG, NULL)) {
+			log_warn("Retrying %s global lock", mode);
+			sleep(1);
+			retries++;
+			goto req;
+		}
+	}
+
+	/*
+	 * ENOLS: no lockspace was found with a global lock.
+	 * The VG with the global lock may not be visible or started yet,
+	 * this should be a temporary condition.
+	 *
+	 * ESTARTING: the lockspace with the gl is starting.
+	 * The VG with the global lock is starting and should finish shortly.
+	 */
+
+	if (result == -ENOLS || result == -ESTARTING) {
+		if (!strcmp(mode, "un"))
+			return 1;
+
+		/*
+		 * If an ex global lock fails, then the command fails.
+		 */
+		if (strcmp(mode, "sh")) {
+			if (result == -ESTARTING)
+				log_error("Global lock failed: lockspace is starting.");
+			else if (result == -ENOLS)
+				log_error("Global lock failed: check that global lockspace is started.");
+			else
+				log_error("Global lock failed: error %d", result);
+			return 0;
+		}
+
+		/*
+		 * If a sh global lock fails, then the command can continue
+		 * reading without it, but force a global cache validation,
+		 * and print a warning.
+		 */
+
+		if (result == -ESTARTING) {
+			log_warn("Skipping global lock: lockspace is starting");
+			lvmetad_validate_global_cache(cmd, 1);
+			return 1;
+		}
+
+		if ((lockd_flags & LD_RF_NO_GL_LS) || (lockd_flags & LD_RF_NO_LOCKSPACES)) {
+			log_warn("Skipping global lock: lockspace not found or started");
+			lvmetad_validate_global_cache(cmd, 1);
+			return 1;
+		}
+
+		/*
+		 * This is for completeness.  If we reach here, then
+		 * a specific check for the error should be added above
+		 * with a more helpful message.
+		 */
+		log_error("Global lock failed: error %d", result);
+		return 0;
+	}
+
+	if ((lockd_flags & LD_RF_DUP_GL_LS) && strcmp(mode, "un"))
+		log_warn("Duplicate sanlock global locks should be corrected");
+
+	if (result < 0) {
+		if (ignorelockingfailure()) {
+			log_debug("Ignore failed locking for global lock");
+			lvmetad_validate_global_cache(cmd, 1);
+			return 1;
+		} else if (result == -EAGAIN) {
+			/*
+			 * Most of the time, retries should avoid this case.
+			 */
+			log_error("Global lock failed: held by other host.");
+			return 0;
+		} else {
+			/*
+			 * We don't intend to reach this.  We should check
+			 * any known/possible error specifically and print
+			 * a more helpful message.  This is for completeness.
+			 */
+			log_error("Global lock failed: error %d.", result);
+			return 0;
+		}
+	}
+
+	if (!(flags & LDGL_SKIP_CACHE_VALIDATE))
+		lvmetad_validate_global_cache(cmd, 0);
+
+	return 1;
+}
+
+/*
+ * VG lock
+ *
+ * Return 1: continue, lockd_state may still indicate an error
+ * Return 0: failure, do not continue
+ *
+ * lvmlockd could also return the lock_type that it used for the VG,
+ * and we could encode that in lockd_state, and verify later that it
+ * matches vg->lock_type.
+ *
+ * The result of the VG lock operation needs to be saved in lockd_state
+ * because the result needs to be passed into vg_read so it can be
+ * assessed in combination with vg->lock_state.
+ *
+ * The VG lock protects the VG metadata on disk from concurrent access
+ * among hosts.  The VG lock also ensures that the local lvmetad cache
+ * contains the latest version of the VG metadata from disk.  (Since
+ * another host may have changed the VG since it was last read.)
+ *
+ * The VG lock must be acquired before the VG is read, i.e. before vg_read().
+ * The result from lockd_vg() is saved in the "lockd_state" variable, and
+ * this result is passed into vg_read().  After vg_read() reads the VG,
+ * it checks if the VG lock_type (sanlock or dlm) requires a lock to be
+ * held, and if so, it verifies that the lock was correctly acquired by
+ * looking at lockd_state.  If vg_read() sees that the VG is a local VG,
+ * i.e. lock_type is not sanlock or dlm, then no lock is required, and it
+ * ignores lockd_state (which would indicate no lock was found.)
+ *
+ * When acquiring the VG lock, lvmlockd checks if the local cached copy
+ * of the VG metadata in lvmetad is up to date.  If not, it invalidates
+ * the VG cached in lvmetad.  This would happen if another host changed
+ * the VG since it was last read.  When lvm commands read the VG from
+ * lvmetad, they will check if the metadata is invalid, and if so they
+ * will reread it from disk, and update the copy in lvmetad.
+ */
+
+int lockd_vg(struct cmd_context *cmd, const char *vg_name, const char *def_mode,
+	     uint32_t flags, uint32_t *lockd_state)
+{
+	const char *mode = NULL;
+	uint32_t lockd_flags;
+	uint32_t prev_state = *lockd_state;
+	int retries = 0;
+	int result;
+	int ret;
+
+	*lockd_state = 0;
+
+	if (!is_real_vg(vg_name))
+		return 1;
+
+	/*
+	 * Some special cases need to disable the vg lock.
+	 */
+	if (cmd->lockd_vg_disable)
+		return 1;
+
+	/*
+	 * An unlock is simply sent or skipped without any need
+	 * for the mode checking for sh/ex.
+	 *
+	 * Look at lockd_state from the sh/ex lock, and if it failed,
+	 * don't bother sending the unlock to lvmlockd.  The main
+	 * purpose of this is to avoid sending an unnecessary unlock
+	 * for local VGs (the lockd_state from sh/ex on the local VG
+	 * will be failed.)  This implies that the lockd_state value
+	 * should be preserved from the sh/ex lockd_vg() call and
+	 * passed back to lockd_vg() for the corresponding unlock.
+	 */
+	if (def_mode && !strcmp(def_mode, "un")) {
+		if (cmd->lock_vg_mode && !strcmp(cmd->lock_vg_mode, "na"))
+			return 1;
+
+		if (prev_state & LDST_FAIL) {
+			log_debug("VG %s unlock skipped: lockd_state is failed", vg_name);
+			return 1;
+		}
+
+		mode = "un";
+		goto req;
+	}
+
+	/*
+	 * A specific lock mode was given on the command line.
+	 */
+	if (cmd->lock_vg_mode) {
+		mode = cmd->lock_vg_mode;
+		if (mode && def_mode && (_mode_compare(mode, def_mode) < 0)) {
+			if (!find_config_tree_bool(cmd, global_allow_override_lock_modes_CFG, NULL)) {
+				log_error("Disallowed lock-vg mode \"%s\"", mode);
+				return 0;
+			} else {
+				log_warn("WARNING: overriding default VG lock mode.");
+			}
+		}
+	}
+
+	/*
+	 * The default mode may not have been provided in the
+	 * function args.  This happens when lockd_vg is called
+	 * from a process_each function that handles different
+	 * commands.  Commands that only read/check/report/display
+	 * the vg have LOCKD_VG_SH set in commands.h, which is
+	 * copied to lockd_vg_default_sh.  Commands without this
+	 * set modify the vg and need ex.
+	 */
+	if (!mode)
+		mode = def_mode;
+	if (!mode)
+		mode = cmd->lockd_vg_default_sh ? "sh" : "ex";
+
+	if (!strcmp(mode, "ex") && find_config_tree_bool(cmd, global_read_only_lock_modes_CFG, NULL)) {
+		log_error("Exclusive VG lock not allowed with read_only_lock_modes");
+		return 0;
+	}
+
+	if (!strcmp(mode, "ex"))
+		*lockd_state |= LDST_EX;
+
+ req:
+	/*
+	 * This check is not at the top of the function so that
+	 * we can first set LDST_EX which will be used later to
+	 * decide whether a failure can be ignored or not.
+	 *
+	 * We do not know if this is a local VG or lockd VG yet,
+	 * so we must return success, go ahead and read the VG,
+	 * then check if the lock_type required lvmlockd or not.
+	 */
+	if (!_use_lvmlockd) {
+		*lockd_state |= LDST_FAIL_REQUEST;
+		return 1;
+	}
+
+	log_debug("lockd VG %s mode %s", vg_name, mode);
+
+	if (!_lockd_request(cmd, "lock_vg",
+			      vg_name, NULL, NULL, NULL, NULL, NULL, mode, NULL,
+			      &result, &lockd_flags)) {
+		/*
+		 * No result from lvmlockd, it is probably not running.
+		 * Decide if it is ok to continue without a lock in
+		 * access_vg_lock_type() after the VG has been read and
+		 * the lock_type can be checked.  We don't care about
+		 * this error for local VGs, but we do care for lockd VGs.
+		 */
+		*lockd_state |= LDST_FAIL_REQUEST;
+		return 1;
+	}
+
+	if (result == -EAGAIN) {
+		if (retries < find_config_tree_int(cmd, global_lock_retries_CFG, NULL)) {
+			log_warn("Retrying %s lock on VG %s", mode, vg_name);
+			sleep(1);
+			retries++;
+			goto req;
+		}
+	}
+
+	switch (result) {
+	case 0:
+		/* success */
+		break;
+	case -ENOLS:
+		*lockd_state |= LDST_FAIL_NOLS;
+		break;
+	case -ESTARTING:
+		*lockd_state |= LDST_FAIL_STARTING;
+		break;
+	default:
+		*lockd_state |= LDST_FAIL_OTHER;
+	}
+
+	/*
+	 * Normal success.
+	 */
+	if (!result) {
+		ret = 1;
+		goto out;
+	}
+
+	/*
+	 * The lockspace for the VG is starting (the VG must not
+	 * be local), and is not yet ready to do locking.  Allow
+	 * reading without a sh lock during this period.
+	 */
+	if (result == -ESTARTING) {
+		if (!strcmp(mode, "un")) {
+			ret = 1;
+			goto out;
+		} else if (!strcmp(mode, "sh")) {
+			log_warn("VG %s lock skipped: lock start in progress", vg_name);
+			ret = 1;
+			goto out;
+		} else {
+			log_error("VG %s lock failed: lock start in progress", vg_name);
+			ret = 0;
+			goto out;
+		}
+	}
+
+	/*
+	 * An unused/previous lockspace for the VG was found.
+	 * This means it must be a lockd VG, not local.  The
+	 * lockspace needs to be started to be used.
+	 */
+	if ((result == -ENOLS) && (lockd_flags & LD_RF_INACTIVE_LS)) {
+		if (!strcmp(mode, "un")) {
+			ret = 1;
+			goto out;
+		} else if (!strcmp(mode, "sh")) {
+			log_warn("VG %s lock skipped: lockspace is inactive", vg_name);
+			ret = 1;
+			goto out;
+		} else {
+			log_error("VG %s lock failed: lockspace is inactive", vg_name);
+			ret = 0;
+			goto out;
+		}
+	}
+
+	/*
+	 * An unused lockspace for the VG was found.  The previous
+	 * start of the lockspace failed, so we can print a more useful
+	 * error message.
+	 */
+	if ((result == -ENOLS) && (lockd_flags & LD_RF_ADD_LS_ERROR)) {
+		if (!strcmp(mode, "un")) {
+			ret = 1;
+			goto out;
+		} else if (!strcmp(mode, "sh")) {
+			log_warn("VG %s lock skipped: lockspace start error", vg_name);
+			ret = 1;
+			goto out;
+		} else {
+			log_error("VG %s lock failed: lockspace start error", vg_name);
+			ret = 0;
+			goto out;
+		}
+	}
+
+	/*
+	 * No lockspace for the VG was found.  It may be a local
+	 * VG that lvmlockd doesn't keep track of, or it may be
+	 * a lockd VG that lvmlockd doesn't yet know about (it hasn't
+	 * been started yet.)  Decide what to do after the VG is
+	 * read and we can see the lock_type.
+	 */
+	if (result == -ENOLS) {
+		ret = 1;
+		goto out;
+	}
+
+	/*
+	 * Another error.  We don't intend to reach here, but
+	 * want to check for each specific error above so that
+	 * a helpful message can be printed.
+	 */
+	if (result) {
+		if (!strcmp(mode, "un")) {
+			ret = 1;
+			goto out;
+		} else if (!strcmp(mode, "sh")) {
+			log_warn("VG %s lock skipped: error %d", vg_name, result);
+			ret = 1;
+			goto out;
+		} else {
+			log_error("VG %s lock failed: error %d", vg_name, result);
+			ret = 0;
+			goto out;
+		}
+	}
+
+out:
+	/*
+	 * A notice from lvmlockd that duplicate gl locks have been found.
+	 * It would be good for the user to disable one of them.
+	 */
+	if ((lockd_flags & LD_RF_DUP_GL_LS) && strcmp(mode, "un"))
+		log_warn("Duplicate sanlock global lock in VG %s", vg_name);
+ 
+	if (!ret && ignorelockingfailure()) {
+		log_debug("Ignore failed locking for VG %s", vg_name);
+		return 1;
+	}
+ 
+	return ret;
+}
+
+/*
+ * This must be called before a new version of the VG metadata is
+ * written to disk.  For local VGs, this is a no-op, but for lockd
+ * VGs, this notifies lvmlockd of the new VG seqno.  lvmlockd must
+ * know the latest VG seqno so that it can save it within the lock's
+ * LVB.  The VG seqno in the VG lock's LVB is used by other hosts to
+ * detect when their cached copy of the VG metadata is stale, i.e.
+ * the cached VG metadata has a lower seqno than the seqno seen in
+ * the VG lock.
+ */
+
+int lockd_vg_update(struct volume_group *vg)
+{
+	daemon_reply reply;
+	int result;
+	int ret;
+
+	if (!is_lockd_type(vg->lock_type))
+		return 1;
+	if (!_use_lvmlockd)
+		return 0;
+	if (!_lvmlockd_connected)
+		return 0;
+
+	reply = _lockd_send("vg_update",
+				"pid = %d", getpid(),
+				"vg_name = %s", vg->name,
+				"version = %d", (int64_t)vg->seqno,
+				NULL);
+
+	if (!_lockd_result(reply, &result, NULL)) {
+		ret = 0;
+	} else {
+		ret = (result < 0) ? 0 : 1;
+	}
+
+	daemon_reply_destroy(reply);
+	return ret;
+}
+
+/*
+ * When this is called directly (as opposed to being called from
+ * lockd_lv), the caller knows that the LV has a lock.
+ */
+
+int lockd_lv_name(struct cmd_context *cmd, struct volume_group *vg,
+		  const char *lv_name, struct id *lv_id,
+		  const char *lock_args, const char *def_mode, uint32_t flags)
+{
+	char lv_uuid[64] __attribute__((aligned(8)));
+	const char *mode = NULL;
+	const char *opts = NULL;
+	uint32_t lockd_flags;
+	int refreshed = 0;
+	int result;
+
+	if (cmd->lockd_lv_disable)
+		return 1;
+
+	if (!_use_lvmlockd)
+		return 0;
+	if (!_lvmlockd_connected)
+		return 0;
+
+	id_write_format(lv_id, lv_uuid, sizeof(lv_uuid));
+
+	/*
+	 * For lvchange/vgchange activation, def_mode is "sh" or "ex"
+	 * according to the specific -a{e,s}y mode designation.
+	 * No e,s designation gives NULL def_mode.
+	 *
+	 * The --lock-lv option is saved in cmd->lock_lv_mode.
+	 */
+
+	if (cmd->lock_lv_mode && def_mode && strcmp(cmd->lock_lv_mode, "na") &&
+	    strcmp(cmd->lock_lv_mode, def_mode)) {
+		log_error("Different LV lock modes from activation %s and lock-lv %s",
+			  def_mode, cmd->lock_lv_mode);
+		return 0;
+	}
+
+	/* A specific lock mode was given on the command line. */
+	if (cmd->lock_lv_mode && (_mode_compare(cmd->lock_lv_mode, "sh") < 0)) {
+		if (!find_config_tree_bool(cmd, global_allow_override_lock_modes_CFG, NULL)) {
+			log_error("Disallowed lock-lv mode \"%s\"", cmd->lock_lv_mode);
+			return 0;
+		} else {
+			log_warn("WARNING: overriding default LV lock mode.");
+		}
+	}
+
+	if (cmd->lock_lv_mode)
+		mode = cmd->lock_lv_mode;
+	else if (def_mode)
+		mode = def_mode;
+
+	if (mode && !strcmp(mode, "sh") && (flags & LDLV_MODE_NO_SH)) {
+		log_error("Shared activation not compatible with LV type: %s/%s",
+			  vg->name, lv_name);
+		return 0;
+	}
+
+	if (!mode)
+		mode = "ex";
+
+	if (flags & LDLV_PERSISTENT)
+		opts = "persistent";
+
+ retry:
+	log_debug("lockd LV %s/%s mode %s uuid %s", vg->name, lv_name, mode, lv_uuid);
+
+	if (!_lockd_request(cmd, "lock_lv",
+			       vg->name, vg->lock_type, vg->lock_args,
+			       lv_name, lv_uuid, lock_args, mode, opts,
+			       &result, &lockd_flags)) {
+		/* No result from lvmlockd, it is probably not running. */
+		log_error("Locking failed for LV %s/%s", vg->name, lv_name);
+		return 0;
+	}
+
+	/* The lv was not active/locked. */
+	if (result == -ENOENT && !strcmp(mode, "un"))
+		return 1;
+
+	if (result == -EALREADY)
+		return 1;
+
+	if (result == -EAGAIN) {
+		log_error("LV locked by other host: %s/%s", vg->name, lv_name);
+		return 0;
+	}
+
+	if (result == -EMSGSIZE) {
+		/* Another host probably extended lvmlock. */
+		if (!refreshed++) {
+			log_debug("Refresh lvmlock");
+		       	_refresh_sanlock_lv(cmd, vg);
+			goto retry;
+		}
+	}
+
+	if (result == -ENOLS) {
+		log_error("LV %s/%s lock failed: lockspace is inactive", vg->name, lv_name);
+		return 0;
+	}
+
+	if (result < 0) {
+		log_error("LV %s/%s lock failed: error %d", vg->name, lv_name, result);
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
+ * Direct the lock request to the pool LV.
+ * For a thin pool and all its thin volumes, one ex lock is used.
+ * It is the one specified in metadata of the pool data lv.
+ */
+
+static int _lockd_lv_thin(struct cmd_context *cmd, struct logical_volume *lv,
+			  const char *def_mode, uint32_t flags)
+{
+	struct logical_volume *pool_lv;
+
+	if (lv_is_thin_volume(lv)) {
+		struct lv_segment *pool_seg = first_seg(lv);
+		pool_lv = pool_seg ? pool_seg->pool_lv : NULL;
+
+	} else if (lv_is_thin_pool(lv)) {
+		pool_lv = lv;
+
+	} else {
+		/* This should not happen AFAIK. */
+		log_error("Lock on incorrect thin lv type %s/%s",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	if (!pool_lv) {
+		/* This should not happen. */
+		log_error("Cannot find thin pool for %s/%s",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	/*
+	 * Locking a locked lv (pool in this case) is a no-op.
+	 * Unlock when the pool is no longer active.
+	 */
+
+	if (def_mode && !strcmp(def_mode, "un") && pool_is_active(pool_lv))
+		return 1;
+
+	flags |= LDLV_MODE_NO_SH;
+
+	return lockd_lv_name(cmd, pool_lv->vg, pool_lv->name, &pool_lv->lvid.id[1],
+			     pool_lv->lock_args, def_mode, flags);
+}
+
+/*
+ * If the VG has no lock_type, then this function can return immediately.
+ * The LV itself may have no lock (NULL lv->lock_args), but the lock request
+ * may be directed to another lock, e.g. the pool LV lock in _lockd_lv_thin.
+ * If the lock request is not directed to another LV, and the LV has no
+ * lock_type set, it means that the LV has no lock, and no locking is done
+ * for it.
+ *
+ * An LV lock is acquired before the LV is activated, and released
+ * after the LV is deactivated.  If the LV lock cannot be acquired,
+ * it means that the LV is active on another host and the activation
+ * fails.  Commands that modify an inactive LV also acquire the LV lock.
+ *
+ * In non-lockd VGs, this is a no-op.
+ *
+ * In lockd VGs, normal LVs each have their own lock, but other
+ * LVs do not have their own lock, e.g. the lock for a thin LV is
+ * acquired on the thin pool LV, and a thin LV does not have a lock
+ * of its own.  A cache pool LV does not have a lock of its own.
+ * When the cache pool LV is linked to an origin LV, the lock of
+ * the orgin LV protects the combined origin + cache pool.
+ */
+
+int lockd_lv(struct cmd_context *cmd, struct logical_volume *lv,
+	     const char *def_mode, uint32_t flags)
+{
+	if (!is_lockd_type(lv->vg->lock_type))
+		return 1;
+
+	if (!_use_lvmlockd) {
+		log_error("LV in VG %s with lock_type %s requires lvmlockd.",
+			  lv->vg->name, lv->vg->lock_type);
+		return 0;
+	}
+
+	if (!_lvmlockd_connected)
+		return 0;
+
+	if (lv_is_thin_type(lv))
+		return _lockd_lv_thin(cmd, lv, def_mode, flags);
+
+	/*
+	 * An LV with NULL lock_args does not have a lock of its own.
+	 */
+	if (!lv->lock_args)
+		return 1;
+
+	/*
+	 * LV type cannot be active concurrently on multiple hosts,
+	 * so shared mode activation is not allowed.
+	 */
+	if (lv_is_external_origin(lv) ||
+	    lv_is_thin_type(lv) ||
+	    lv_is_mirror_type(lv) ||
+	    lv_is_raid_type(lv) ||
+	    lv_is_cache_type(lv)) {
+		flags |= LDLV_MODE_NO_SH;
+	}
+
+	return lockd_lv_name(cmd, lv->vg, lv->name, &lv->lvid.id[1],
+			     lv->lock_args, def_mode, flags);
+}
+
+static int _init_lv_sanlock(struct cmd_context *cmd, struct volume_group *vg,
+			    const char *lv_name, struct id *lv_id,
+			    const char **lock_args_ret)
+{
+	char lv_uuid[64] __attribute__((aligned(8)));
+	daemon_reply reply;
+	const char *reply_str;
+	const char *lv_lock_args = NULL;
+	int result;
+	int ret;
+
+	if (!_use_lvmlockd)
+		return 0;
+	if (!_lvmlockd_connected)
+		return 0;
+
+	id_write_format(lv_id, lv_uuid, sizeof(lv_uuid));
+
+	reply = _lockd_send("init_lv",
+				"pid = %d", getpid(),
+				"vg_name = %s", vg->name,
+				"lv_name = %s", lv_name,
+				"lv_uuid = %s", lv_uuid,
+				"vg_lock_type = %s", "sanlock",
+				"vg_lock_args = %s", vg->lock_args,
+				NULL);
+
+	if (!_lockd_result(reply, &result, NULL)) {
+		ret = 0;
+	} else {
+		ret = (result < 0) ? 0 : 1;
+	}
+
+	if (result == -EEXIST) {
+		log_error("Lock already exists for LV %s/%s", vg->name, lv_name);
+		goto out;
+	}
+
+	if (result == -EMSGSIZE) {
+		/*
+		 * No space on the lvmlock lv for a new lease, this should be
+		 * detected by handle_sanlock_lv() called before.
+		 */
+		log_error("No sanlock space for lock for LV %s/%s", vg->name, lv_name);
+		goto out;
+	}
+
+	if (!ret) {
+		log_error("_init_lv_sanlock lvmlockd result %d", result);
+		goto out;
+	}
+
+	if (!(reply_str = daemon_reply_str(reply, "lv_lock_args", NULL))) {
+		log_error("lv_lock_args not returned");
+		ret = 0;
+		goto out;
+	}
+
+	if (!(lv_lock_args = dm_pool_strdup(cmd->mem, reply_str))) {
+		log_error("lv_lock_args allocation failed");
+		ret = 0;
+	}
+out:
+	daemon_reply_destroy(reply);
+
+	*lock_args_ret = lv_lock_args;
+	return ret;
+}
+
+static int _free_lv(struct cmd_context *cmd, struct volume_group *vg,
+		    const char *lv_name, struct id *lv_id, const char *lock_args)
+{
+	char lv_uuid[64] __attribute__((aligned(8)));
+	daemon_reply reply;
+	int result;
+	int ret;
+
+	if (!_use_lvmlockd)
+		return 0;
+	if (!_lvmlockd_connected)
+		return 0;
+
+	id_write_format(lv_id, lv_uuid, sizeof(lv_uuid));
+
+	reply = _lockd_send("free_lv",
+				"pid = %d", getpid(),
+				"vg_name = %s", vg->name,
+				"lv_name = %s", lv_name,
+				"lv_uuid = %s", lv_uuid,
+				"vg_lock_type = %s", vg->lock_type,
+				"vg_lock_args = %s", vg->lock_args,
+				"lv_lock_args = %s", lock_args ?: "none",
+				NULL);
+
+	if (!_lockd_result(reply, &result, NULL)) {
+		ret = 0;
+	} else {
+		ret = (result < 0) ? 0 : 1;
+	}
+
+	if (!ret)
+		log_error("_free_lv lvmlockd result %d", result);
+
+	daemon_reply_destroy(reply);
+
+	return ret;
+}
+
+int lockd_init_lv_args(struct cmd_context *cmd, struct volume_group *vg,
+		       struct logical_volume *lv,
+		       const char *lock_type, const char **lock_args)
+{
+	/* sanlock is the only lock type that sets per-LV lock_args. */
+	if (!strcmp(lock_type, "sanlock"))
+		return _init_lv_sanlock(cmd, vg, lv->name, &lv->lvid.id[1], lock_args);
+	return 1;
+}
+
+/*
+ * lvcreate
+ *
+ * An LV created in a lockd VG inherits the lock_type of the VG.  In some
+ * cases, e.g. thin LVs, this function may decide that the LV should not be
+ * given a lock, in which case it sets lp lock_args to NULL, which will cause
+ * the LV to not have lock_args set in its metadata.  A lockd_lv() request on
+ * an LV with no lock_args will do nothing (unless the LV type causes the lock
+ * request to be directed to another LV with a lock, e.g. to the thin pool LV
+ * for thin LVs.)
+ *
+ * Current limitations:
+ * - cache-type LV's in a lockd VG must be created with lvconvert.
+ * - creating a thin pool and thin lv in one command is not allowed.
+ */
+
+int lockd_init_lv(struct cmd_context *cmd, struct volume_group *vg, struct logical_volume *lv,
+		  struct lvcreate_params *lp)
+{
+	int lock_type_num = get_lock_type_from_string(vg->lock_type);
+
+	if (cmd->lock_lv_mode && !strcmp(cmd->lock_lv_mode, "na"))
+		return 1;
+
+	switch (lock_type_num) {
+	case LOCK_TYPE_NONE:
+	case LOCK_TYPE_CLVM:
+		return 1;
+	case LOCK_TYPE_SANLOCK:
+	case LOCK_TYPE_DLM:
+		break;
+	default:
+		log_error("lockd_init_lv: unknown lock_type.");
+		return 0;
+	}
+
+	if (!_use_lvmlockd)
+		return 0;
+	if (!_lvmlockd_connected)
+		return 0;
+
+	if (!lp->needs_lockd_init) {
+		/* needs_lock_init is set for LVs that need a lockd lock. */
+		return 1;
+
+	} else if (seg_is_cache(lp) || seg_is_cache_pool(lp)) {
+		log_error("Use lvconvert for cache with lock type %s", vg->lock_type);
+		return 0;
+
+	} else if (!seg_is_thin_volume(lp) && lp->snapshot) {
+		struct logical_volume *origin_lv;
+
+		/*
+		 * COW snapshots are associated with their origin LV,
+		 * and only the origin LV needs its own lock, which
+		 * represents itself and all associated cow snapshots.
+		 */
+
+		if (!(origin_lv = find_lv(vg, lp->origin_name))) {
+			log_error("Failed to find origin LV %s/%s", vg->name, lp->origin_name);
+			return 0;
+		}
+		if (!lockd_lv(cmd, origin_lv, "ex", LDLV_PERSISTENT)) {
+			log_error("Failed to lock origin LV %s/%s", vg->name, lp->origin_name);
+			return 0;
+		}
+		lv->lock_args = NULL;
+		return 1;
+
+	} else if (seg_is_thin(lp)) {
+		if ((seg_is_thin_volume(lp) && !lp->create_pool) ||
+		    (!seg_is_thin_volume(lp) && lp->snapshot)) {
+			struct lv_list *lvl;
+
+			/*
+			 * Creating a new thin lv or snapshot.  These lvs do not get
+			 * their own lock but use the pool lock.  If an lv does not
+			 * use its own lock, its lock_args is set to NULL.
+			 */
+
+			if (!(lvl = find_lv_in_vg(vg, lp->pool_name))) {
+				log_error("Failed to find thin pool %s/%s", vg->name, lp->pool_name);
+				return 0;
+			}
+			if (!lockd_lv(cmd, lvl->lv, "ex", LDLV_PERSISTENT)) {
+				log_error("Failed to lock thin pool %s/%s", vg->name, lp->pool_name);
+				return 0;
+			}
+			lv->lock_args = NULL;
+			return 1;
+
+		} else if (seg_is_thin_volume(lp) && lp->create_pool) {
+			/*
+			 * Creating a thin pool and a thin lv in it.  We could
+			 * probably make this work.
+			 */
+			log_error("Create thin pool and thin LV separately with lock type %s",
+				  vg->lock_type);
+			return 0;
+
+		} else if (!seg_is_thin_volume(lp) && lp->create_pool) {
+			/* Creating a thin pool only. */
+			/* lv_name_lock = lp->pool_name; */
+
+		} else {
+			log_error("Unknown thin options for lock init.");
+			return 0;
+		}
+
+	} else {
+		/* Creating a normal lv. */
+		/* lv_name_lock = lv_name; */
+	}
+
+	/*
+	 * The LV gets its own lock, so set lock_args to non-NULL.
+	 *
+	 * lockd_init_lv_args() will be called during vg_write()
+	 * to complete the sanlock LV lock initialization, where
+	 * actual space on disk is allocated.  Waiting to do this
+	 * last step until vg_write() avoids the need to revert
+	 * the sanlock allocation if the lvcreate function isn't
+	 * completed.
+	 *
+	 * This works, but would leave the sanlock lease allocated
+	 * unless the lease was freed on each early exit path from
+	 * lvcreate:
+	 *
+	 * return lockd_init_lv_args(cmd, vg, lv_name_lock, lv_id,
+	 * 			     vg->lock_type, &lv->lock_args);
+	 */
+
+	if (!strcmp(vg->lock_type, "sanlock"))
+		lv->lock_args = "pending";
+	else if (!strcmp(vg->lock_type, "dlm"))
+		lv->lock_args = "dlm";
+
+	return 1;
+}
+
+/* lvremove */
+
+int lockd_free_lv(struct cmd_context *cmd, struct volume_group *vg,
+		  const char *lv_name, struct id *lv_id, const char *lock_args)
+{
+	if (cmd->lock_lv_mode && !strcmp(cmd->lock_lv_mode, "na"))
+		return 1;
+
+	switch (get_lock_type_from_string(vg->lock_type)) {
+	case LOCK_TYPE_NONE:
+	case LOCK_TYPE_CLVM:
+		return 1;
+	case LOCK_TYPE_DLM:
+	case LOCK_TYPE_SANLOCK:
+		if (!lock_args)
+			return 1;
+		return _free_lv(cmd, vg, lv_name, lv_id, lock_args);
+	default:
+		log_error("lockd_free_lv: unknown lock_type.");
+		return 0;
+	}
+}
+
+int lockd_rename_vg_before(struct cmd_context *cmd, struct volume_group *vg)
+{
+	struct lv_list *lvl;
+	daemon_reply reply;
+	int result;
+	int ret;
+
+	if (!is_lockd_type(vg->lock_type))
+		return 1;
+	if (!_use_lvmlockd)
+		return 0;
+	if (!_lvmlockd_connected)
+		return 0;
+
+	if (lvs_in_vg_activated(vg)) {
+		log_error("LVs must be inactive before vgrename.");
+		return 0;
+	}
+
+	/* Check that no LVs are active on other hosts. */
+
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (!lockd_lv(cmd, lvl->lv, "ex", 0)) {
+			log_error("LV %s/%s must be inactive on all hosts before vgrename.",
+				  vg->name, lvl->lv->name);
+			return 0;
+		}
+
+		if (!lockd_lv(cmd, lvl->lv, "un", 0)) {
+			log_error("Failed to unlock LV %s/%s.", vg->name, lvl->lv->name);
+			return 0;
+		}
+	}
+
+	/*
+	 * lvmlockd:
+	 * checks for other hosts in lockspace
+	 * leaves the lockspace
+	 */
+
+	reply = _lockd_send("rename_vg_before",
+			"pid = %d", getpid(),
+			"vg_name = %s", vg->name,
+			"vg_lock_type = %s", vg->lock_type,
+			"vg_lock_args = %s", vg->lock_args,
+			NULL);
+
+	if (!_lockd_result(reply, &result, NULL)) {
+		ret = 0;
+	} else {
+		ret = (result < 0) ? 0 : 1;
+	}
+
+	daemon_reply_destroy(reply);
+	
+	if (!ret) {
+		log_error("lockd_rename_vg_before lvmlockd result %d", result);
+		return 0;
+	}
+
+	if (!strcmp(vg->lock_type, "sanlock")) {
+		log_debug("lockd_rename_vg_before deactivate sanlock lv");
+		_deactivate_sanlock_lv(cmd, vg);
+	}
+
+	return 1;
+}
+
+int lockd_rename_vg_final(struct cmd_context *cmd, struct volume_group *vg, int success)
+{
+	daemon_reply reply;
+	int result;
+	int ret;
+
+	if (!is_lockd_type(vg->lock_type))
+		return 1;
+	if (!_use_lvmlockd)
+		return 0;
+	if (!_lvmlockd_connected)
+		return 0;
+
+	if (!success) {
+		/*
+		 * Depending on the problem that caused the rename to
+		 * fail, it may make sense to not restart the VG here.
+		 */
+		if (!lockd_start_vg(cmd, vg))
+			log_error("Failed to restart VG %s lockspace.", vg->name);
+		return 1;
+	}
+
+	if (!strcmp(vg->lock_type, "sanlock")) {
+		if (!_activate_sanlock_lv(cmd, vg))
+			return 0;
+
+		/*
+		 * lvmlockd needs to rewrite the leases on disk
+		 * with the new VG (lockspace) name.
+		 */
+		reply = _lockd_send("rename_vg_final",
+				"pid = %d", getpid(),
+				"vg_name = %s", vg->name,
+				"vg_lock_type = %s", vg->lock_type,
+				"vg_lock_args = %s", vg->lock_args,
+				NULL);
+
+		if (!_lockd_result(reply, &result, NULL)) {
+			ret = 0;
+		} else {
+			ret = (result < 0) ? 0 : 1;
+		}
+	
+		daemon_reply_destroy(reply);
+
+		if (!ret) {
+			/*
+			 * The VG has been renamed on disk, but renaming the
+			 * sanlock leases failed.  Cleaning this up can
+			 * probably be done by converting the VG to lock_type
+			 * none, then converting back to sanlock.
+			 */
+			log_error("lockd_rename_vg_final lvmlockd result %d", result);
+			return 0;
+		}
+	}
+
+	if (!lockd_start_vg(cmd, vg))
+		log_error("Failed to start VG %s lockspace.", vg->name);
+
+	return 1;
+}
+
+const char *lockd_running_lock_type(struct cmd_context *cmd)
+{
+	daemon_reply reply;
+	const char *lock_type = NULL;
+	int result;
+
+	if (!_use_lvmlockd)
+		return NULL;
+	if (!_lvmlockd_connected)
+		return NULL;
+
+	reply = _lockd_send("running_lm",
+			"pid = %d", getpid(),
+			NULL);
+
+	if (!_lockd_result(reply, &result, NULL)) {
+		log_error("Failed to get result from lvmlockd");
+		goto out;
+	}
+
+	switch (result) {
+	case -EXFULL:
+		log_error("lvmlockd found multiple lock managers, use --lock-type to select one.");
+		break;
+	case -ENOLCK:
+		log_error("lvmlockd found no lock manager running.");
+		break;
+	case LOCK_TYPE_SANLOCK:
+		log_debug("lvmlockd found sanlock");
+		lock_type = "sanlock";
+		break;
+	case LOCK_TYPE_DLM:
+		log_debug("lvmlockd found dlm");
+		lock_type = "dlm";
+		break;
+	default:
+		log_error("Failed to find a running lock manager.");
+		break;
+	}
+out:
+	daemon_reply_destroy(reply);
+
+	return lock_type;
+}
+
+/* Some LV types have no lock. */
+
+int lockd_lv_uses_lock(struct logical_volume *lv)
+{
+	if (!lv_is_visible(lv) ||
+	    lv_is_thin_volume(lv) ||
+	    lv_is_thin_pool_data(lv) ||
+	    lv_is_thin_pool_metadata(lv) ||
+	    lv_is_pool_metadata_spare(lv) ||
+	    lv_is_cache_pool(lv) ||
+	    lv_is_cache_pool_data(lv) ||
+	    lv_is_cache_pool_metadata(lv) ||
+	    lv_is_lockd_sanlock_lv(lv))
+		return 0;
+	return 1;
+}
+
diff --git a/lib/locking/lvmlockd.h b/lib/locking/lvmlockd.h
new file mode 100644
index 0000000..20cd7de
--- /dev/null
+++ b/lib/locking/lvmlockd.h
@@ -0,0 +1,239 @@
+/*
+ * Copyright (C) 2014 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ */
+
+#ifndef _LVMLOCKD_H
+#define _LVMLOCKD_H
+
+#include "config-util.h"
+#include "daemon-client.h"
+
+#define LOCKD_SANLOCK_LV_NAME "lvmlock"
+
+/* lockd_gl flags */
+#define LDGL_SKIP_CACHE_VALIDATE  0x00000001
+#define LDGL_UPDATE_NAMES         0x00000002
+
+/* lockd_lv flags */
+#define LDLV_MODE_NO_SH           0x00000001
+#define LDLV_PERSISTENT           0x00000002
+
+/* lvmlockd result flags */
+#define LD_RF_NO_LOCKSPACES     0x00000001
+#define LD_RF_NO_GL_LS          0x00000002
+#define LD_RF_LOCAL_LS          0x00000004
+#define LD_RF_DUP_GL_LS         0x00000008
+#define LD_RF_INACTIVE_LS       0x00000010
+#define LD_RF_ADD_LS_ERROR      0x00000020
+
+/* lockd_state flags */
+#define LDST_EX			0x00000001
+#define LDST_SH			0x00000002
+#define LDST_FAIL_REQUEST	0x00000004
+#define LDST_FAIL_NOLS		0x00000008
+#define LDST_FAIL_STARTING	0x00000010
+#define LDST_FAIL_OTHER		0x00000020
+#define LDST_FAIL		(LDST_FAIL_REQUEST | LDST_FAIL_NOLS | LDST_FAIL_STARTING | LDST_FAIL_OTHER)
+
+#ifdef LVMLOCKD_SUPPORT
+
+/* lvmlockd connection and communication */
+
+void lvmlockd_set_socket(const char *sock);
+void lvmlockd_set_use(int use);
+int lvmlockd_use(void);
+void lvmlockd_init(struct cmd_context *cmd);
+void lvmlockd_connect(void);
+void lvmlockd_disconnect(void);
+
+/* vgcreate/vgremove use init/free */
+
+int lockd_init_vg(struct cmd_context *cmd, struct volume_group *vg, const char *lock_type);
+int lockd_free_vg_before(struct cmd_context *cmd, struct volume_group *vg);
+void lockd_free_vg_final(struct cmd_context *cmd, struct volume_group *vg);
+
+/* vgrename */
+
+int lockd_rename_vg_before(struct cmd_context *cmd, struct volume_group *vg);
+int lockd_rename_vg_final(struct cmd_context *cmd, struct volume_group *vg, int success);
+
+/* start and stop the lockspace for a vg */
+
+int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg);
+int lockd_stop_vg(struct cmd_context *cmd, struct volume_group *vg);
+int lockd_start_wait(struct cmd_context *cmd);
+
+/* locking */
+
+int lockd_gl_create(struct cmd_context *cmd, const char *def_mode, const char *vg_lock_type);
+int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags);
+int lockd_vg(struct cmd_context *cmd, const char *vg_name, const char *def_mode,
+	     uint32_t flags, uint32_t *lockd_state);
+int lockd_vg_update(struct volume_group *vg);
+
+int lockd_lv_name(struct cmd_context *cmd, struct volume_group *vg,
+		  const char *lv_name, struct id *lv_id,
+		  const char *lock_args, const char *def_mode, uint32_t flags);
+int lockd_lv(struct cmd_context *cmd, struct logical_volume *lv,
+	     const char *def_mode, uint32_t flags);
+
+/* lvcreate/lvremove use init/free */
+
+int lockd_init_lv(struct cmd_context *cmd, struct volume_group *vg, struct logical_volume *lv,
+		  struct lvcreate_params *lp);
+int lockd_init_lv_args(struct cmd_context *cmd, struct volume_group *vg,
+		       struct logical_volume *lv, const char *lock_type, const char **lock_args);
+int lockd_free_lv(struct cmd_context *cmd, struct volume_group *vg,
+		  const char *lv_name, struct id *lv_id, const char *lock_args);
+
+const char *lockd_running_lock_type(struct cmd_context *cmd);
+
+int handle_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg);
+
+int lockd_lv_uses_lock(struct logical_volume *lv);
+
+#else /* LVMLOCKD_SUPPORT */
+
+static inline void lvmlockd_set_socket(const char *sock)
+{
+}
+
+static inline void lvmlockd_set_use(int use)
+{
+}
+
+static inline void lvmlockd_init(struct cmd_context *cmd)
+{
+}
+
+static inline void lvmlockd_disconnect(void)
+{
+}
+
+static inline void lvmlockd_connect(void)
+{
+}
+
+static inline int lvmlockd_use(void)
+{
+	return 0;
+}
+
+static inline int lockd_init_vg(struct cmd_context *cmd, struct volume_group *vg, const char *lock_type)
+{
+	return 1;
+}
+
+static inline int lockd_free_vg_before(struct cmd_context *cmd, struct volume_group *vg)
+{
+	return 1;
+}
+
+static inline void lockd_free_vg_final(struct cmd_context *cmd, struct volume_group *vg)
+{
+	return;
+}
+
+static inline int lockd_rename_vg_before(struct cmd_context *cmd, struct volume_group *vg)
+{
+	return 1;
+}
+
+static inline int lockd_rename_vg_final(struct cmd_context *cmd, struct volume_group *vg, int success)
+{
+	return 1;
+}
+
+static inline int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg)
+{
+	return 0;
+}
+
+static inline int lockd_stop_vg(struct cmd_context *cmd, struct volume_group *vg)
+{
+	return 0;
+}
+
+static inline int lockd_start_wait(struct cmd_context *cmd)
+{
+	return 0;
+}
+
+static inline int lockd_gl_create(struct cmd_context *cmd, const char *def_mode, const char *vg_lock_type)
+{
+	return 1;
+}
+
+static inline int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
+{
+	return 1;
+}
+
+static inline int lockd_vg(struct cmd_context *cmd, const char *vg_name, const char *def_mode,
+	     uint32_t flags, uint32_t *lockd_state)
+{
+	*lockd_state = 0;
+	return 1;
+}
+
+static inline int lockd_vg_update(struct volume_group *vg)
+{
+	return 1;
+}
+
+static inline int lockd_lv_name(struct cmd_context *cmd, struct volume_group *vg,
+		  const char *lv_name, struct id *lv_id,
+		  const char *lock_args, const char *def_mode, uint32_t flags)
+{
+	return 1;
+}
+
+static inline int lockd_lv(struct cmd_context *cmd, struct logical_volume *lv,
+	     const char *def_mode, uint32_t flags)
+{
+	return 1;
+}
+
+static inline int lockd_init_lv(struct cmd_context *cmd, struct volume_group *vg,
+		  	struct logical_volume *lv, struct lvcreate_params *lp)
+{
+	return 0;
+}
+
+static inline int lockd_init_lv_args(struct cmd_context *cmd, struct volume_group *vg,
+		       struct logical_volume *lv, const char *lock_type, const char **lock_args)
+{
+	return 0;
+}
+
+static inline int lockd_free_lv(struct cmd_context *cmd, struct volume_group *vg,
+		  const char *lv_name, struct id *lv_id, const char *lock_args)
+{
+	return 0;
+}
+
+static inline const char *lockd_running_lock_type(struct cmd_context *cmd)
+{
+	return NULL;
+}
+
+static inline int handle_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg)
+{
+	return 0;
+}
+
+static inline int lockd_lv_uses_lock(struct logical_volume *lv)
+{
+	return 0;
+}
+
+#endif /* LVMLOCKD_SUPPORT */
+
+#endif
+
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index f0a3d77..49d4a09 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -20,6 +20,7 @@
 #include "toolcontext.h"
 #include "segtype.h"
 #include "str_list.h"
+#include "lvmlockd.h"
 
 #include <time.h>
 #include <sys/utsname.h>
@@ -910,6 +911,19 @@ static int _lv_is_exclusive(struct logical_volume *lv)
 int lv_active_change(struct cmd_context *cmd, struct logical_volume *lv,
 		     enum activation_change activate, int needs_exclusive)
 {
+	const char *ay_with_mode = NULL;
+
+	if (activate == CHANGE_ASY)
+		ay_with_mode = "sh";
+	if (activate == CHANGE_AEY)
+		ay_with_mode = "ex";
+	
+	if (is_change_activating(activate) &&
+	    !lockd_lv(cmd, lv, ay_with_mode, LDLV_PERSISTENT)) {
+		log_error("Failed to lock logical volume %s/%s", lv->vg->name, lv->name);
+		return 0;
+	}
+
 	switch (activate) {
 	case CHANGE_AN:
 deactivate:
@@ -962,6 +976,10 @@ exclusive:
 			return_0;
 	}
 
+	if (!is_change_activating(activate) &&
+	    !lockd_lv(cmd, lv, "un", LDLV_PERSISTENT))
+		log_error("Failed to unlock logical volume %s/%s", lv->vg->name, lv->name);
+
 	return 1;
 }
 
@@ -1001,6 +1019,12 @@ char *lv_profile_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	return dm_pool_strdup(mem, profile_name);
 }
 
+char *lv_lock_args_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	const char *lock_args = lv->lock_args ? lv->lock_args : "";
+	return dm_pool_strdup(mem, lock_args);
+}
+
 /* For given LV find recursively the LV which holds lock for it */
 const struct logical_volume *lv_lock_holder(const struct logical_volume *lv)
 {
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index f7bbb1e..a2b0f6f 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -51,7 +51,9 @@ struct logical_volume {
 	struct dm_list segs_using_this_lv;
 
 	uint64_t timestamp;
+	unsigned new_lock_args:1;
 	const char *hostname;
+	const char *lock_args;
 };
 
 struct lv_with_info_and_seg_status;
@@ -103,6 +105,7 @@ const struct logical_volume *lv_lock_holder(const struct logical_volume *lv);
 const struct logical_volume *lv_ondisk(const struct logical_volume *lv);
 struct profile *lv_config_profile(const struct logical_volume *lv);
 char *lv_profile_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_lock_args_dup(struct dm_pool *mem, const struct logical_volume *lv);
 int lv_mirror_image_in_sync(const struct logical_volume *lv);
 int lv_raid_image_in_sync(const struct logical_volume *lv);
 int lv_raid_healthy(const struct logical_volume *lv);
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b539fde..87888a7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -30,6 +30,7 @@
 #include "lvm-exec.h"
 #include "lvm-signal.h"
 #include "memlock.h"
+#include "lvmlockd.h"
 
 typedef enum {
 	PREFERRED,
@@ -4588,7 +4589,9 @@ static int _lvresize_check_lv(struct cmd_context *cmd, struct logical_volume *lv
 		return 0;
 	}
 
-	if (!lv_is_visible(lv) && !lv_is_thin_pool_metadata(lv)) {
+	/* FIXME: use a status flag instead of the name "lvmlock". */
+
+	if (!lv_is_visible(lv) && !lv_is_thin_pool_metadata(lv) && strcmp(lv->name, "lvmlock")) {
 		log_error("Can't resize internal logical volume %s", lv->name);
 		return 0;
 	}
@@ -5238,6 +5241,13 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
+	/*
+	 * If the LV is locked from activation, this lock call is a no-op.
+	 * Otherwise, this acquires a transient lock on the lv (not PERSISTENT).
+	 */
+	if (!lockd_lv(cmd, lv, "ex", 0))
+		return_0;
+
 	if (lp->sizeargs &&
 	    !(lock_lv = _lvresize_volume(cmd, lv, lp, pvh)))
 		return_0;
@@ -5586,6 +5596,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	int format1_reload_required = 0;
 	int visible;
 	struct logical_volume *pool_lv = NULL;
+	struct logical_volume *lock_lv = lv;
 	struct lv_segment *cache_seg = NULL;
 	int ask_discard;
 	struct lv_list *lvl;
@@ -5632,14 +5643,19 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		log_error("Can't remove logical volume %s used by a pool.",
 			  lv->name);
 		return 0;
-	} else if (lv_is_thin_volume(lv))
+	} else if (lv_is_thin_volume(lv)) {
 		pool_lv = first_seg(lv)->pool_lv;
+		lock_lv = pool_lv;
+	}
 
 	if (lv_is_locked(lv)) {
 		log_error("Can't remove locked LV %s", lv->name);
 		return 0;
 	}
 
+	if (!lockd_lv(cmd, lock_lv, "ex", LDLV_PERSISTENT))
+		return_0;
+
 	/* FIXME Ensure not referred to by another existing LVs */
 	ask_discard = find_config_tree_bool(cmd, devices_issue_discards_CFG, NULL);
 
@@ -5814,6 +5830,9 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 	backup(vg);
 
+	lockd_lv(cmd, lock_lv, "un", LDLV_PERSISTENT);
+	lockd_free_lv(cmd, vg, lv->name, &lv->lvid.id[1], lv->lock_args);
+
 	if (!suppress_remove_message && visible)
 		log_print_unless_silent("Logical volume \"%s\" successfully removed", lv->name);
 
@@ -7201,6 +7220,14 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				   lv->major, lv->minor);
 	}
 
+	/*
+	 * The specific LV may not use a lock.  lockd_init_lv() sets
+	 * lv->lock_args to NULL if this LV does not use its own lock.
+	 */
+
+	if (!lockd_init_lv(vg->cmd, vg, lv, lp))
+		return_NULL;
+
 	dm_list_splice(&lv->tags, &lp->tags);
 
 	if (!lv_extend(lv, create_segtype,
@@ -7515,6 +7542,8 @@ deactivate_and_revert_new_lv:
 	}
 
 revert_new_lv:
+	lockd_free_lv(vg->cmd, vg, lp->lv_name, &lv->lvid.id[1], lp->lock_args);
+
 	/* FIXME Better to revert to backup of metadata? */
 	if (!lv_remove(lv) || !vg_write(vg) || !vg_commit(vg))
 		log_error("Manual intervention may be required to remove "
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index ff10a98..63a57ca 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -101,6 +101,7 @@
 #define THIN_POOL_DATA		UINT64_C(0x0000004000000000)	/* LV - Internal use only */
 #define THIN_POOL_METADATA	UINT64_C(0x0000008000000000)	/* LV - Internal use only */
 #define POOL_METADATA_SPARE	UINT64_C(0x0000010000000000)	/* LV - Internal use only */
+#define LOCKD_SANLOCK_LV	UINT64_C(0x0000020000000000)	/* LV - Internal use only */
 
 #define LV_WRITEMOSTLY		UINT64_C(0x0000020000000000)	/* LV (RAID1) */
 
@@ -228,6 +229,7 @@
 #define lv_is_pool_data(lv)		(((lv)->status & (CACHE_POOL_DATA | THIN_POOL_DATA)) ? 1 : 0)
 #define lv_is_pool_metadata(lv)		(((lv)->status & (CACHE_POOL_METADATA | THIN_POOL_METADATA)) ? 1 : 0)
 #define lv_is_pool_metadata_spare(lv)	(((lv)->status & POOL_METADATA_SPARE) ? 1 : 0)
+#define lv_is_lockd_sanlock_lv(lv)	(((lv)->status & LOCKD_SANLOCK_LV) ? 1 : 0)
 
 #define lv_is_rlog(lv)		(((lv)->status & REPLICATOR_LOG) ? 1 : 0)
 
@@ -262,6 +264,14 @@ typedef enum {
 	THIN_DISCARDS_PASSDOWN,
 } thin_discards_t;
 
+typedef enum {
+	LOCK_TYPE_INVALID = -1,
+	LOCK_TYPE_NONE = 0,
+	LOCK_TYPE_CLVM = 1,
+	LOCK_TYPE_DLM = 2,
+	LOCK_TYPE_SANLOCK = 3,
+} lock_type_t;
+
 struct cmd_context;
 struct format_handler;
 struct labeller;
@@ -640,9 +650,9 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
  * Return a handle to VG metadata.
  */
 struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name,
-			     const char *vgid, uint32_t flags);
+			     const char *vgid, uint32_t flags, uint32_t lockd_state);
 struct volume_group *vg_read_for_update(struct cmd_context *cmd, const char *vg_name,
-			 const char *vgid, uint32_t flags);
+			 const char *vgid, uint32_t flags, uint32_t lockd_state);
 
 /* 
  * Test validity of a VG handle.
@@ -685,6 +695,7 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name);
 int vg_remove_mdas(struct volume_group *vg);
 int vg_remove_check(struct volume_group *vg);
 void vg_remove_pvs(struct volume_group *vg);
+int vg_remove_direct(struct volume_group *vg);
 int vg_remove(struct volume_group *vg);
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
@@ -863,12 +874,15 @@ struct lvcreate_params {
 #define THIN_CHUNK_SIZE_CALC_METHOD_GENERIC 0x01
 #define THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE 0x02
 	int thin_chunk_size_calc_policy;
+	unsigned needs_lockd_init : 1;
 
 	const char *vg_name; /* only-used when VG is not yet opened (in /tools) */
 	const char *lv_name; /* all */
 	const char *origin_name; /* snap */
 	const char *pool_name;   /* thin */
 
+	const char *lock_args;
+
 	/* Keep args given by the user on command line */
 	/* FIXME: create some more universal solution here */
 #define PASS_ARG_CHUNK_SIZE		0x01
@@ -1211,6 +1225,8 @@ struct vgcreate_params {
 	int clustered; /* FIXME: put this into a 'status' variable instead? */
 	uint32_t vgmetadatacopies;
 	const char *system_id;
+	const char *lock_type;
+	const char *lock_args;
 };
 
 int validate_major_minor(const struct cmd_context *cmd,
@@ -1222,4 +1238,7 @@ int vgcreate_params_validate(struct cmd_context *cmd,
 int validate_vg_rename_params(struct cmd_context *cmd,
 			      const char *vg_name_old,
 			      const char *vg_name_new);
+
+int is_lockd_type(const char *lock_type);
+
 #endif
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 9b77daa..08bfe91 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -31,6 +31,7 @@
 #include "locking.h"
 #include "archiver.h"
 #include "defaults.h"
+#include "lvmlockd.h"
 
 #include <math.h>
 #include <sys/param.h>
@@ -557,20 +558,14 @@ void vg_remove_pvs(struct volume_group *vg)
 	}
 }
 
-int vg_remove(struct volume_group *vg)
+int vg_remove_direct(struct volume_group *vg)
 {
 	struct physical_volume *pv;
 	struct pv_list *pvl;
 	int ret = 1;
 
-	if (!lock_vol(vg->cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
-		log_error("Can't get lock for orphan PVs");
-		return 0;
-	}
-
 	if (!vg_remove_mdas(vg)) {
 		log_error("vg_remove_mdas %s failed", vg->name);
-		unlock_vg(vg->cmd, VG_ORPHANS);
 		return 0;
 	}
 
@@ -604,6 +599,8 @@ int vg_remove(struct volume_group *vg)
 	if (!lvmetad_vg_remove(vg))
 		stack;
 
+	lockd_vg_update(vg);
+
 	if (!backup_remove(vg->cmd, vg->name))
 		stack;
 
@@ -612,6 +609,20 @@ int vg_remove(struct volume_group *vg)
 	else
 		log_error("Volume group \"%s\" not properly removed", vg->name);
 
+	return ret;
+}
+
+int vg_remove(struct volume_group *vg)
+{
+	int ret;
+
+	if (!lock_vol(vg->cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
+		log_error("Can't get lock for orphan PVs");
+		return 0;
+	}
+
+	ret = vg_remove_direct(vg);
+
 	unlock_vg(vg->cmd, VG_ORPHANS);
 	return ret;
 }
@@ -2428,6 +2439,7 @@ struct validate_hash {
 	struct dm_hash_table *lvname;
 	struct dm_hash_table *lvid;
 	struct dm_hash_table *pvid;
+	struct dm_hash_table *lv_lock_args;
 };
 
 /*
@@ -2786,6 +2798,87 @@ int vg_validate(struct volume_group *vg)
 
 	if (vg_max_lv_reached(vg))
 		stack;
+
+	if (!(vhash.lv_lock_args = dm_hash_create(lv_count))) {
+		log_error("Failed to allocate lv_lock_args hash");
+		r = 0;
+		goto out;
+	}
+
+	if (is_lockd_type(vg->lock_type)) {
+		if (!vg->lock_args) {
+			log_error(INTERNAL_ERROR "VG %s with lock_type %s without lock_args",
+				  vg->name, vg->lock_type);
+			r = 0;
+		}
+
+		if (vg_is_clustered(vg)) {
+			log_error(INTERNAL_ERROR "VG %s with lock_type %s is clustered",
+				  vg->name, vg->lock_type);
+			r = 0;
+		}
+
+		if (vg->system_id && vg->system_id[0]) {
+			log_error(INTERNAL_ERROR "VG %s with lock_type %s has system_id %s",
+				  vg->name, vg->lock_type, vg->system_id);
+			r = 0;
+		}
+
+		if (strcmp(vg->lock_type, "sanlock") && strcmp(vg->lock_type, "dlm")) {
+			log_error(INTERNAL_ERROR "VG %s has unknown lock_type %s",
+				  vg->name, vg->lock_type);
+			r = 0;
+		}
+	} else {
+		if (vg->lock_args) {
+			log_error(INTERNAL_ERROR "VG %s has lock_args %s without lock_type",
+				  vg->name, vg->lock_args);
+			r = 0;
+		}
+	}
+
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (is_lockd_type(vg->lock_type)) {
+			if (lockd_lv_uses_lock(lvl->lv)) {
+				if (vg->skip_validate_lock_args) {
+					continue;
+				} else if (!lvl->lv->lock_args) {
+					log_error(INTERNAL_ERROR "LV %s/%s missing lock_args",
+						  vg->name, lvl->lv->name);
+					r = 0;
+				} else if (!strcmp(vg->lock_type, "sanlock")) {
+					if (dm_hash_lookup(vhash.lv_lock_args, lvl->lv->lock_args)) {
+						log_error(INTERNAL_ERROR "LV %s/%s has duplicate lock_args %s.",
+							  vg->name, lvl->lv->name, lvl->lv->lock_args);
+						r = 0;
+					}
+
+					if (!dm_hash_insert(vhash.lv_lock_args, lvl->lv->lock_args, lvl)) {
+						log_error("Failed to hash lvname.");
+						r = 0;
+					}
+
+				} else if (!strcmp(vg->lock_type, "dlm") && strcmp(lvl->lv->lock_args, "dlm")) {
+					log_error(INTERNAL_ERROR "LV %s/%s bad dlm lock_args %s",
+						  vg->name, lvl->lv->name, lvl->lv->lock_args);
+					r = 0;
+				}
+			} else {
+				if (lvl->lv->lock_args) {
+					log_error(INTERNAL_ERROR "LV %s/%s shouldn't have lock_args",
+						  vg->name, lvl->lv->name);
+					r = 0;
+				}
+			}
+		} else {
+			if (lvl->lv->lock_args) {
+				log_error(INTERNAL_ERROR "LV %s/%s with no lock_type has lock_args %s",
+					  vg->name, lvl->lv->name, lvl->lv->lock_args);
+				r = 0;
+			}
+		}
+	}
+
 out:
 	if (vhash.lvid)
 		dm_hash_destroy(vhash.lvid);
@@ -2793,6 +2886,8 @@ out:
 		dm_hash_destroy(vhash.lvname);
 	if (vhash.pvid)
 		dm_hash_destroy(vhash.pvid);
+	if (vhash.lv_lock_args)
+		dm_hash_destroy(vhash.lv_lock_args);
 
 	return r;
 }
@@ -2806,8 +2901,19 @@ int vg_write(struct volume_group *vg)
 	struct dm_list *mdah;
         struct pv_to_create *pv_to_create;
 	struct metadata_area *mda;
+	struct lv_list *lvl;
 	int revert = 0, wrote = 0;
 
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (lvl->lv->lock_args && !strcmp(lvl->lv->lock_args, "pending")) {
+			if (!lockd_init_lv_args(vg->cmd, vg, lvl->lv, vg->lock_type, &lvl->lv->lock_args)) {
+				log_error("Cannot allocate lock for new LV.");
+				return 0;
+			}
+			lvl->lv->new_lock_args = 1;
+		}
+	}
+
 	if (!vg_validate(vg))
 		return_0;
 
@@ -2974,6 +3080,8 @@ int vg_commit(struct volume_group *vg)
 
 	cache_updated = _vg_commit_mdas(vg);
 
+	lockd_vg_update(vg);
+
 	if (cache_updated) {
 		/* Instruct remote nodes to upgrade cached metadata. */
 		if (!remote_commit_cached_metadata(vg))
@@ -3007,6 +3115,14 @@ int vg_commit(struct volume_group *vg)
 void vg_revert(struct volume_group *vg)
 {
 	struct metadata_area *mda;
+	struct lv_list *lvl;
+
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (lvl->lv->new_lock_args) {
+			lockd_free_lv(vg->cmd, vg, lvl->lv->name, &lvl->lv->lvid.id[1], lvl->lv->lock_args);
+			lvl->lv->new_lock_args = 0;
+		}
+	}
 
 	release_vg(vg->vg_precommitted);  /* VG is no longer needed */
 	vg->vg_precommitted = NULL;
@@ -3821,6 +3937,16 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 		release_vg(vg);
 	}
 
+	/*
+	 * When using lvmlockd we should never reach this point.
+	 * The VG is locked, then vg_read() is done, which gets
+	 * the latest VG from lvmetad, or disk if lvmetad has
+	 * been invalidated.  When we get here the VG should
+	 * always be cached and returned above.
+	 */
+	if (lvmlockd_use())
+		log_error(INTERNAL_ERROR "vg_read_by_vgid failed with lvmlockd");
+
 	/* Mustn't scan if memory locked: ensure cache gets pre-populated! */
 	if (critical_section())
 		return_NULL;
@@ -4509,20 +4635,71 @@ static int _access_vg_clustered(struct cmd_context *cmd, struct volume_group *vg
 	return 1;
 }
 
-static int _access_vg_lock_type(struct cmd_context *cmd, struct volume_group *vg)
+static int _access_vg_lock_type(struct cmd_context *cmd, struct volume_group *vg,
+				uint32_t lockd_state)
 {
 	if (!is_real_vg(vg->name))
 		return 1;
 
+	if (cmd->lockd_vg_disable)
+		return 1;
+
 	/*
-	 * Until lock_type support is added, reject any VG that has a lock_type.
+	 * Local VG requires no lock from lvmlockd.
+	 */
+	if (!is_lockd_type(vg->lock_type))
+		return 1;
+
+	/*
+	 * When lvmlockd is not used, lockd VGs are ignored by lvm
+	 * and cannot be used, with two exceptions:
+	 *
+	 * . The --shared option allows them to be revealed with
+	 *   reporting/display commands.
+	 *
+	 * . If a command asks to operate on one specifically
+	 *   by name, then an error is printed.
 	 */
-	if (vg->lock_type && vg->lock_type[0] && strcmp(vg->lock_type, "none")) {
-		log_error("Cannot access VG %s with unsupported lock_type %s.",
-			  vg->name, vg->lock_type);
+	if (!lvmlockd_use()) {
+		/*
+	 	 * Some reporting/display commands have the --shared option
+		 * (like --foreign) to allow them to reveal lockd VGs that
+		 * are otherwise ignored.  The --shared option must only be
+		 * permitted in commands that read the VG for report or display,
+		 * not any that write the VG or activate LVs.
+	 	 */
+		if (cmd->include_shared_vgs)
+			return 1;
+
+		/*
+		 * Some commands want the error printed by vg_read, others by ignore_vg.
+		 * Those using ignore_vg may choose to skip the error.
+		 */
+		if (cmd->vg_read_print_access_error) {
+			log_error("Cannot access VG %s with lock type %s that requires lvmlockd.",
+				  vg->name, vg->lock_type);
+		}
+
 		return 0;
 	}
 
+	/*
+	 * The lock request from lvmlockd failed.  If the lock was ex,
+	 * we cannot continue.  If the lock was sh, we could also fail
+	 * to continue but since the lock was sh, it means the VG is
+	 * only being read, and it doesn't hurt to allow reading with
+	 * no lock.
+	 */
+	if (lockd_state & LDST_FAIL) {
+		if (lockd_state & LDST_EX) {
+			log_error("Cannot access VG %s due to failed lock.", vg->name);
+			return 0;
+		} else {
+			log_warn("Reading VG %s without a lock.", vg->name);
+			return 1;
+		}
+	}
+
 	return 1;
 }
 
@@ -4582,18 +4759,16 @@ static int _access_vg_systemid(struct cmd_context *cmd, struct volume_group *vg)
 	}
 
 	/*
-	 * Some commands always produce an error when accessing foreign VG.
+	 * Some commands want the error printed by vg_read, others by ignore_vg.
+	 * Those using ignore_vg may choose to skip the error.
 	 */
-	if (cmd->error_foreign_vgs) {
+	if (cmd->vg_read_print_access_error) {
 		log_error("Cannot access VG %s with system ID %s with local system ID %s.",
 			  vg->name, vg->system_id, cmd->system_id);
 		return 0;
 	}
 
-	/*
-	 * When include_foreign_vgs is 0 and error_foreign_vgs is 0,
-	 * the result is to silently ignore foreign vgs.
-	 */
+	/* Silently ignore foreign vgs. */
 
 	return 0;
 }
@@ -4601,7 +4776,8 @@ static int _access_vg_systemid(struct cmd_context *cmd, struct volume_group *vg)
 /*
  * FIXME: move _vg_bad_status_bits() checks in here.
  */
-static int _vg_access_permitted(struct cmd_context *cmd, struct volume_group *vg, uint32_t *failure)
+static int _vg_access_permitted(struct cmd_context *cmd, struct volume_group *vg,
+				uint32_t lockd_state, uint32_t *failure)
 {
 	if (!is_real_vg(vg->name)) {
 		/* Disallow use of LVM1 orphans when a host system ID is set. */
@@ -4617,7 +4793,7 @@ static int _vg_access_permitted(struct cmd_context *cmd, struct volume_group *vg
 		return 0;
 	}
 
-	if (!_access_vg_lock_type(cmd, vg)) {
+	if (!_access_vg_lock_type(cmd, vg, lockd_state)) {
 		*failure |= FAILED_LOCK_TYPE;
 		return 0;
 	}
@@ -4643,7 +4819,8 @@ static int _vg_access_permitted(struct cmd_context *cmd, struct volume_group *vg
  */
 static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
 			       const char *vgid, uint32_t lock_flags,
-			       uint64_t status_flags, uint32_t misc_flags)
+			       uint64_t status_flags, uint32_t misc_flags,
+			       uint32_t lockd_state)
 {
 	struct volume_group *vg = NULL;
 	int consistent = 1;
@@ -4689,7 +4866,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 		goto bad;
 	}
 
-	if (!_vg_access_permitted(cmd, vg, &failure))
+	if (!_vg_access_permitted(cmd, vg, lockd_state, &failure))
 		goto bad;
 
 	/* consistent == 0 when VG is not found, but failed == FAILED_NOTFOUND */
@@ -4765,7 +4942,7 @@ bad_no_unlock:
  * *consistent = 1.
  */
 struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name,
-			     const char *vgid, uint32_t flags)
+			     const char *vgid, uint32_t flags, uint32_t lockd_state)
 {
 	uint64_t status = UINT64_C(0);
 	uint32_t lock_flags = LCK_VG_READ;
@@ -4778,7 +4955,7 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name,
 	if (flags & READ_ALLOW_EXPORTED)
 		status &= ~EXPORTED_VG;
 
-	return _vg_lock_and_read(cmd, vg_name, vgid, lock_flags, status, flags);
+	return _vg_lock_and_read(cmd, vg_name, vgid, lock_flags, status, flags, lockd_state);
 }
 
 /*
@@ -4787,9 +4964,9 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name,
  * request the new metadata to be written and committed).
  */
 struct volume_group *vg_read_for_update(struct cmd_context *cmd, const char *vg_name,
-			 const char *vgid, uint32_t flags)
+			 const char *vgid, uint32_t flags, uint32_t lockd_state)
 {
-	return vg_read(cmd, vg_name, vgid, flags | READ_FOR_UPDATE);
+	return vg_read(cmd, vg_name, vgid, flags | READ_FOR_UPDATE, lockd_state);
 }
 
 /*
@@ -5221,3 +5398,21 @@ const struct logical_volume *lv_ondisk(const struct logical_volume *lv)
 
 	return lvl->lv;
 }
+
+/*
+ * Check if a lock_type uses lvmlockd.
+ * If not (none, clvm), return 0.
+ * If so (dlm, sanlock), return 1.
+ */
+
+int is_lockd_type(const char *lock_type)
+{
+	if (!lock_type)
+		return 0;
+	if (!strcmp(lock_type, "dlm"))
+		return 1;
+	if (!strcmp(lock_type, "sanlock"))
+		return 1;
+	return 0;
+}
+
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 8b9879c..c574a14 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -21,6 +21,7 @@
 #include "activate.h"
 #include "lv_alloc.h"
 #include "lvm-string.h"
+#include "lvmlockd.h"
 
 static int _lv_is_raid_with_tracking(const struct logical_volume *lv,
 				     struct logical_volume **tracking)
@@ -1087,6 +1088,12 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 	dm_list_init(&removal_list);
 	dm_list_init(&data_list);
 
+	if (is_lockd_type(lv->vg->lock_type)) {
+		log_error("Splitting raid image is not allowed with lock_type %s",
+			  lv->vg->lock_type);
+		return 0;
+	}
+
 	if ((old_count - new_count) != 1) {
 		log_error("Unable to split more than one image from %s/%s",
 			  lv->vg->name, lv->name);
diff --git a/lib/metadata/replicator_manip.c b/lib/metadata/replicator_manip.c
index 54dc759..fc4bf5f 100644
--- a/lib/metadata/replicator_manip.c
+++ b/lib/metadata/replicator_manip.c
@@ -566,7 +566,7 @@ int cmd_vg_read(struct cmd_context *cmd, struct dm_list *cmd_vgs)
 
 	/* Iterate through alphabeticaly ordered cmd_vg list */
 	dm_list_iterate_items(cvl, cmd_vgs) {
-		cvl->vg = vg_read(cmd, cvl->vg_name, cvl->vgid, cvl->flags);
+		cvl->vg = vg_read(cmd, cvl->vg_name, cvl->vgid, cvl->flags, 0);
 		if (vg_read_error(cvl->vg)) {
 			log_debug_metadata("Failed to vg_read %s", cvl->vg_name);
 			return 0;
@@ -644,7 +644,7 @@ int lv_read_replicator_vgs(const struct logical_volume *lv)
 	dm_list_iterate_items(rsite, &first_seg(lv)->replicator->rsites) {
 		if (!rsite->vg_name)
 			continue;
-		vg = vg_read(lv->vg->cmd, rsite->vg_name, 0, 0); // READ_WITHOUT_LOCK
+		vg = vg_read(lv->vg->cmd, rsite->vg_name, 0, 0, 0); // READ_WITHOUT_LOCK
 		if (vg_read_error(vg)) {
 			log_error("Unable to read volume group %s",
 				  rsite->vg_name);
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 1db8e75..0e5aee5 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -20,6 +20,7 @@
 #include "toolcontext.h"
 #include "lvmcache.h"
 #include "archiver.h"
+#include "lvmlockd.h"
 
 struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 			      const char *vg_name)
@@ -134,6 +135,16 @@ char *vg_system_id_dup(const struct volume_group *vg)
 	return dm_pool_strdup(vg->vgmem, vg->system_id ? : vg->lvm1_system_id ? : "");
 }
 
+char *vg_lock_type_dup(const struct volume_group *vg)
+{
+	return dm_pool_strdup(vg->vgmem, vg->lock_type ? : vg->lock_type ? : "");
+}
+
+char *vg_lock_args_dup(const struct volume_group *vg)
+{
+	return dm_pool_strdup(vg->vgmem, vg->lock_args ? : vg->lock_args ? : "");
+}
+
 char *vg_uuid_dup(const struct volume_group *vg)
 {
 	return id_format_and_copy(vg->vgmem, &vg->id);
@@ -637,6 +648,19 @@ int vg_set_system_id(struct volume_group *vg, const char *system_id)
 	return 1;
 }
 
+int vg_set_lock_type(struct volume_group *vg, const char *lock_type)
+{
+	if (!lock_type)
+		lock_type = "none";
+
+	if (!(vg->lock_type = dm_pool_strdup(vg->vgmem, lock_type))) {
+		log_error("vg_set_lock_type %s no mem", lock_type);
+		return 0;
+	}
+
+	return 1;
+}
+
 char *vg_attr_dup(struct dm_pool *mem, const struct volume_group *vg)
 {
 	char *repstr;
@@ -651,7 +675,14 @@ char *vg_attr_dup(struct dm_pool *mem, const struct volume_group *vg)
 	repstr[2] = (vg_is_exported(vg)) ? 'x' : '-';
 	repstr[3] = (vg_missing_pv_count(vg)) ? 'p' : '-';
 	repstr[4] = alloc_policy_char(vg->alloc);
-	repstr[5] = (vg_is_clustered(vg)) ? 'c' : '-';
+
+	if (vg_is_clustered(vg))
+		repstr[5] = 'c';
+	else if (is_lockd_type(vg->lock_type))
+		repstr[5] = 's';
+	else
+		repstr[5] = '-';
+
 	return repstr;
 }
 
@@ -706,7 +737,7 @@ int vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 	vg->extent_count -= pv_pe_count(pv);
 
 	orphan_vg = vg_read_for_update(cmd, vg->fid->fmt->orphan_vg_name,
-				       NULL, 0);
+				       NULL, 0, 0);
 
 	if (vg_read_error(orphan_vg))
 		goto bad;
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 2da5651..a21af8b 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -49,6 +49,7 @@ struct volume_group {
 	struct dm_list *cmd_vgs;/* List of wanted/locked and opened VGs */
 	uint32_t cmd_missing_vgs;/* Flag marks missing VG */
 	uint32_t seqno;		/* Metadata sequence number */
+	unsigned skip_validate_lock_args : 1;
 
 	/*
 	 * The parsed on-disk copy of this VG; is NULL if this is the on-disk
@@ -71,6 +72,7 @@ struct volume_group {
 	const char *system_id;
 	char *lvm1_system_id;
 	const char *lock_type;
+	const char *lock_args;
 
 	uint32_t extent_size;
 	uint32_t extent_count;
@@ -151,6 +153,7 @@ struct volume_group {
 
 	struct dm_hash_table *hostnames; /* map of creation hostnames */
 	struct logical_volume *pool_metadata_spare_lv; /* one per VG */
+	struct logical_volume *sanlock_lv; /* one per VG */
 };
 
 struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
@@ -166,11 +169,14 @@ void free_orphan_vg(struct volume_group *vg);
 char *vg_fmt_dup(const struct volume_group *vg);
 char *vg_name_dup(const struct volume_group *vg);
 char *vg_system_id_dup(const struct volume_group *vg);
+char *vg_lock_type_dup(const struct volume_group *vg);
+char *vg_lock_args_dup(const struct volume_group *vg);
 uint32_t vg_seqno(const struct volume_group *vg);
 uint64_t vg_status(const struct volume_group *vg);
 int vg_set_alloc_policy(struct volume_group *vg, alloc_policy_t alloc);
 int vg_set_clustered(struct volume_group *vg, int clustered);
 int vg_set_system_id(struct volume_group *vg, const char *system_id);
+int vg_set_lock_type(struct volume_group *vg, const char *lock_type);
 uint64_t vg_size(const struct volume_group *vg);
 uint64_t vg_free(const struct volume_group *vg);
 uint64_t vg_extent_size(const struct volume_group *vg);
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 6daf105..89b7a7b 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -105,6 +105,9 @@
 /* Use lvmetad by default. */
 #undef DEFAULT_USE_LVMETAD
 
+/* Use lvmlockd by default. */
+#undef DEFAULT_USE_LVMLOCKD
+
 /* Use lvmpolld by default. */
 #undef DEFAULT_USE_LVMPOLLD
 
@@ -534,6 +537,12 @@
 /* Define to 1 to include code that uses lvmetad. */
 #undef LVMETAD_SUPPORT
 
+/* Path to lvmlockd pidfile. */
+#undef LVMLOCKD_PIDFILE
+
+/* Define to 1 to include code that uses lvmlockd. */
+#undef LVMLOCKD_SUPPORT
+
 /* Path to lvmpolld pidfile. */
 #undef LVMPOLLD_PIDFILE
 
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 1576c28..22141d8 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -84,7 +84,8 @@ FIELD(LVS, lv, STR, "Meta", lvid, 4, metadatalv, metadata_lv, "For thin and cach
 FIELD(LVS, lv, STR, "Pool", lvid, 4, poollv, pool_lv, "For thin volumes, the thin pool LV for this volume.", 0)
 FIELD(LVS, lv, STR_LIST, "LV Tags", tags, 7, tags, lv_tags, "Tags, if any.", 0)
 FIELD(LVS, lv, STR, "LProfile", lvid, 8, lvprofile, lv_profile, "Configuration profile attached to this LV.", 0)
-FIELD(LVS, lv, TIM, "Time", lvid, 26, lvtime, lv_time, "Creation time of the LV, if known", 0)
+FIELD(LVS, lv, STR, "Lock Args", lvid, 9, lvlockargs, lv_lockargs, "Lock args of the LV used by lvmlockd.", 0)
+FIELD(LVS, lv, STR, "Time", lvid, 26, lvtime, lv_time, "Creation time of the LV, if known", 0)
 FIELD(LVS, lv, STR, "Host", lvid, 10, lvhost, lv_host, "Creation host of the LV, if known.", 0)
 FIELD(LVS, lv, STR_LIST, "Modules", lvid, 7, modules, lv_modules, "Kernel device-mapper modules required for this LV.", 0)
 
@@ -143,6 +144,8 @@ FIELD(VGS, vg, SIZ, "VSize", cmd, 5, vgsize, vg_size, "Total size of VG in curre
 FIELD(VGS, vg, SIZ, "VFree", cmd, 5, vgfree, vg_free, "Total amount of free space in current units.", 0)
 FIELD(VGS, vg, STR, "SYS ID", cmd, 6, vgsystemid, vg_sysid, "System ID of the VG indicating which host owns it.", 0)
 FIELD(VGS, vg, STR, "System ID", cmd, 9, vgsystemid, vg_systemid, "System ID of the VG indicating which host owns it.", 0)
+FIELD(VGS, vg, STR, "Lock Type", cmd, 9, vglocktype, vg_locktype, "Lock type of the VG used by lvmlockd.", 0)
+FIELD(VGS, vg, STR, "Lock Args", cmd, 9, vglockargs, vg_lockargs, "Lock args of the VG used by lvmlockd.", 0)
 FIELD(VGS, vg, SIZ, "Ext", extent_size, 3, size32, vg_extent_size, "Size of Physical Extents in current units.", 0)
 FIELD(VGS, vg, NUM, "#Ext", extent_count, 4, uint32, vg_extent_count, "Total number of Physical Extents.", 0)
 FIELD(VGS, vg, NUM, "Free", free_count, 4, uint32, vg_free_count, "Total number of unallocated Physical Extents.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 5cd3c4d..e38359b 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -350,6 +350,8 @@ GET_LV_STR_PROPERTY_FN(lv_active, lv_active_dup(lv->vg->vgmem, lv))
 #define _lv_active_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_profile, lv_profile_dup(lv->vg->vgmem, lv))
 #define _lv_profile_set prop_not_implemented_set
+GET_LV_STR_PROPERTY_FN(lv_lockargs, lv_lock_args_dup(lv->vg->vgmem, lv))
+#define _lv_lockargs_set prop_not_implemented_set
 
 /* VG */
 GET_VG_STR_PROPERTY_FN(vg_fmt, vg_fmt_dup(vg))
@@ -368,6 +370,10 @@ GET_VG_STR_PROPERTY_FN(vg_sysid, vg_system_id_dup(vg))
 #define _vg_sysid_set prop_not_implemented_set
 GET_VG_STR_PROPERTY_FN(vg_systemid, vg_system_id_dup(vg))
 #define _vg_systemid_set prop_not_implemented_set
+GET_VG_STR_PROPERTY_FN(vg_locktype, vg_lock_type_dup(vg))
+#define _vg_locktype_set prop_not_implemented_set
+GET_VG_STR_PROPERTY_FN(vg_lockargs, vg_lock_args_dup(vg))
+#define _vg_lockargs_set prop_not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_extent_size, (SECTOR_SIZE * vg->extent_size))
 #define _vg_extent_size_set prop_not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_extent_count, vg->extent_count)
diff --git a/lib/report/report.c b/lib/report/report.c
index 025b896..40f947f 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -377,6 +377,16 @@ static int _lvprofile_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _field_set_value(field, "", NULL);
 }
 
+static int _lvlockargs_disp(struct dm_report *rh, struct dm_pool *mem,
+			    struct dm_report_field *field,
+			    const void *data, void *private)
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	const char *repstr = lv->lock_args ? lv->lock_args : "";
+
+	return _string_disp(rh, mem, field, &repstr, private);
+}
+
 static int _vgfmt_disp(struct dm_report *rh, struct dm_pool *mem,
 		       struct dm_report_field *field,
 		       const void *data, void *private)
@@ -1108,6 +1118,26 @@ static int _vgsystemid_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _string_disp(rh, mem, field, &repstr, private);
 }
 
+static int _vglocktype_disp(struct dm_report *rh, struct dm_pool *mem,
+			    struct dm_report_field *field,
+			    const void *data, void *private)
+{
+	const struct volume_group *vg = (const struct volume_group *) data;
+	const char *repstr = vg->lock_type ? vg->lock_type : "";
+
+	return _string_disp(rh, mem, field, &repstr, private);
+}
+
+static int _vglockargs_disp(struct dm_report *rh, struct dm_pool *mem,
+			    struct dm_report_field *field,
+			    const void *data, void *private)
+{
+	const struct volume_group *vg = (const struct volume_group *) data;
+	const char *repstr = vg->lock_args ? vg->lock_args : "";
+
+	return _string_disp(rh, mem, field, &repstr, private);
+}
+
 static int _uuid_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
 		      struct dm_report_field *field,
 		      const void *data, void *private __attribute__((unused)))
diff --git a/libdaemon/client/daemon-client.c b/libdaemon/client/daemon-client.c
index d37b966..991bf8a 100644
--- a/libdaemon/client/daemon-client.c
+++ b/libdaemon/client/daemon-client.c
@@ -21,7 +21,6 @@
 #include <string.h>
 #include <stdio.h>
 #include <unistd.h>
-#include <assert.h>
 #include <errno.h> // ENOMEM
 
 daemon_handle daemon_open(daemon_info i)
@@ -100,7 +99,13 @@ daemon_reply daemon_send(daemon_handle h, daemon_request rq)
 {
 	struct buffer buffer;
 	daemon_reply reply = { 0 };
-	assert(h.socket_fd >= 0);
+
+	if (h.socket_fd < 0) {
+		log_error(INTERNAL_ERROR "Daemon send: socket fd cannot be negative %d", h.socket_fd);
+		reply.error = EINVAL;
+		return reply;
+	}
+
 	buffer = rq.buffer;
 
 	if (!buffer.mem)
@@ -109,7 +114,12 @@ daemon_reply daemon_send(daemon_handle h, daemon_request rq)
 			return reply;
 		}
 
-	assert(buffer.mem);
+	if (!buffer.mem) {
+		log_error(INTERNAL_ERROR "Daemon send: no memory available");
+		reply.error = ENOMEM;
+		return reply;
+	}
+
 	if (!buffer_write(h.socket_fd, &buffer))
 		reply.error = errno;
 
diff --git a/libdaemon/server/daemon-log.c b/libdaemon/server/daemon-log.c
index 87ad547..c1765de 100644
--- a/libdaemon/server/daemon-log.c
+++ b/libdaemon/server/daemon-log.c
@@ -1,7 +1,6 @@
 #include "daemon-server.h"
 #include "daemon-log.h"
 #include <syslog.h>
-#include <assert.h>
 
 struct backend {
 	int id;
@@ -129,7 +128,9 @@ void daemon_log_multi(log_state *s, int type, const char *prefix, const char *ms
 
 void daemon_log_enable(log_state *s, int outlet, int type, int enable)
 {
-	assert(type < 32);
+	if (type >= 32)
+		return;
+
 	if (enable)
 		s->log_config[type] |= outlet;
 	else
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 76c5c63..a2d42d2 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -218,7 +218,7 @@ static vg_t _lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
 		return NULL;
 	}
 
-	vg = vg_read((struct cmd_context *)libh, vgname, NULL, internal_flags);
+	vg = vg_read((struct cmd_context *)libh, vgname, NULL, internal_flags, 0);
 	if (vg_read_error(vg)) {
 		/* FIXME: use log_errno either here in inside vg_read */
 		release_vg(vg);
diff --git a/man/Makefile.in b/man/Makefile.in
index d75d916..0eca987 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -46,6 +46,12 @@ else
 LVMPOLLD =
 endif
 
+ifeq ("@BUILD_LVMLOCKD@", "yes")
+LVMLOCKD = lvmlockd.8
+else
+LVMLOCKD =
+endif
+
 MAN5=lvm.conf.5
 MAN7=lvmsystemid.7
 MAN8=lvm-config.8 lvm-dumpconfig.8 lvm-lvpoll.8 \
@@ -56,7 +62,8 @@ MAN8=lvm-config.8 lvm-dumpconfig.8 lvm-lvpoll.8 \
 	pvresize.8 pvs.8 pvscan.8 vgcfgbackup.8 vgcfgrestore.8 vgchange.8 \
 	vgck.8 vgcreate.8 vgconvert.8 vgdisplay.8 vgexport.8 vgextend.8 \
 	vgimport.8 vgimportclone.8 vgmerge.8 vgmknodes.8 vgreduce.8 vgremove.8 \
-	vgrename.8 vgs.8 vgscan.8 vgsplit.8 $(FSADMMAN) $(LVMETAD) $(LVMPOLLD)
+	vgrename.8 vgs.8 vgscan.8 vgsplit.8 $(FSADMMAN) $(LVMETAD) $(LVMPOLLD) \
+	$(LVMLOCKD)
 
 ifneq ("@CLVMD@", "none")
   MAN8CLUSTER=clvmd.8
diff --git a/man/lvmlockd.8.in b/man/lvmlockd.8.in
new file mode 100644
index 0000000..79a3218
--- /dev/null
+++ b/man/lvmlockd.8.in
@@ -0,0 +1,755 @@
+.TH "LVMLOCKD" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
+
+.SH NAME
+lvmlockd \(em LVM locking daemon
+
+.SH DESCRIPTION
+LVM commands use lvmlockd to coordinate access to shared storage.
+.br
+When LVM is used on devices shared by multiple hosts, locks will:
+
+.IP \[bu] 2
+coordinate reading and writing of LVM metadata
+.IP \[bu] 2
+validate caching of LVM metadata
+.IP \[bu] 2
+prevent concurrent activation of logical volumes
+
+.P
+
+lvmlockd uses an external lock manager to perform basic locking.
+.br
+Lock manager (lock type) options are:
+
+.IP \[bu] 2
+sanlock: places locks on disk within LVM storage.
+.IP \[bu] 2
+dlm: uses network communication and a cluster manager.
+
+.P
+
+.SH OPTIONS
+
+lvmlockd [options]
+
+For default settings, see lvmlockd -h.
+
+.B  --help | -h
+        Show this help information.
+
+.B  --version | -V
+        Show version of lvmlockd.
+
+.B  --test | -T
+        Test mode, do not call lock manager.
+
+.B  --foreground | -f
+        Don't fork.
+
+.B  --daemon-debug | -D
+        Don't fork and print debugging to stdout.
+
+.B  --pid-file | -p
+.I path
+        Set path to the pid file.
+
+.B  --socket-path | -s
+.I path
+        Set path to the socket to listen on.
+
+.B  --syslog-priority | -S err|warning|debug
+        Write log messages from this level up to syslog.
+
+.B  --gl-type | -g
+.I str
+        Set global lock type to be sanlock|dlm.
+
+.B  --host-id | -i
+.I num
+        Set the local sanlock host id.
+
+.B  --host-id-file | -F
+.I path
+        A file containing the local sanlock host_id.
+
+.B  --adopt | A 0|1
+        Adopt locks from a previous instance of lvmlockd.
+
+
+.SH USAGE
+
+.SS Initial set up
+
+Using LVM with lvmlockd for the first time includes some one-time set up
+steps:
+
+.SS 1. choose a lock manager
+
+.I dlm
+.br
+If dlm (or corosync) are already being used by other cluster
+software, then select dlm.  dlm uses corosync which requires additional
+configuration beyond the scope of this document.  See corosync and dlm
+documentation for instructions on configuration, setup and usage.
+
+.I sanlock
+.br
+Choose sanlock if dlm/corosync are not otherwise required.
+sanlock does not depend on any clustering software or configuration.
+
+.SS 2. configure hosts to use lvmlockd
+
+On all hosts running lvmlockd, configure lvm.conf:
+.nf
+locking_type = 1
+use_lvmlockd = 1
+use_lvmetad = 1
+.fi
+
+.I sanlock
+.br
+Assign each host a unique host_id in the range 1-2000 by setting
+.br
+/etc/lvm/lvmlocal.conf local/host_id = <num>
+
+.SS 3. start lvmlockd
+
+Use a service/init file if available, or just run "lvmlockd".
+
+.SS 4. start lock manager
+
+.I sanlock
+.br
+systemctl start wdmd sanlock
+
+.I dlm
+.br
+Follow external clustering documentation when applicable, otherwise:
+.br
+systemctl start corosync dlm
+
+.SS 5. create VGs on shared devices
+
+vgcreate --shared <vg_name> <devices>
+
+The vgcreate --shared option sets the VG lock type to sanlock or dlm
+depending on which lock manager is running.  LVM commands will perform
+locking for the VG using lvmlockd.
+
+.SS 6. start VGs on all hosts
+
+vgchange --lock-start
+
+lvmlockd requires shared VGs to be "started" before they are used.  This
+is a lock manager operation to start/join the VG lockspace, and it may
+take some time.  Until the start completes, locks for the VG are not
+available.  LVM commands are allowed to read the VG while start is in
+progress.  (A service/init file can be used to start VGs.)
+
+.SS 7. create and activate LVs
+
+Standard lvcreate and lvchange commands are used to create and activate
+LVs in a lockd VG.
+
+An LV activated exclusively on one host cannot be activated on another.
+When multiple hosts need to use the same LV concurrently, the LV can be
+activated with a shared lock (see lvchange options -aey vs -asy.)
+(Shared locks are disallowed for certain LV types that cannot be used from
+multiple hosts.)
+
+
+.SS Normal start up and shut down
+
+After initial set up, start up and shut down include the following general
+steps.  They can be performed manually or using the system init/service
+manager.
+
+.IP \[bu] 2
+start lvmetad
+.IP \[bu] 2
+start lvmlockd
+.IP \[bu] 2
+start lock manager
+.IP \[bu] 2
+vgchange --lock-start
+.IP \[bu] 2
+activate LVs in shared VGs
+
+.P
+
+The shut down sequence is the reverse:
+
+.IP \[bu] 2
+deactivate LVs in shared VGs
+.IP \[bu] 2
+vgchange --lock-stop
+.IP \[bu] 2
+stop lock manager
+.IP \[bu] 2
+stop lvmlockd
+.IP \[bu] 2
+stop lvmetad
+
+.P
+
+.SH TOPICS
+
+.SS locking terms
+
+The following terms are used to distinguish VGs that require locking from
+those that do not.
+
+.I "lockd VG"
+
+A "lockd VG" is a shared VG that has a "lock type" of dlm or sanlock.
+Using it requires lvmlockd.  These VGs exist on shared storage that is
+visible to multiple hosts.  LVM commands use lvmlockd to perform locking
+for these VGs when they are used.
+
+If the lock manager for a lock type is not available (e.g. not started or
+failed), lvmlockd is not able to acquire locks from it, and LVM commands
+are unable to fully use VGs with the given lock type.  Commands generally
+allow reading VGs in this condition, but changes and activation are not
+allowed.  Maintaining a properly running lock manager can require
+background not covered here.
+
+.I "local VG"
+
+A "local VG" is meant to be used by a single host.  It has no lock type or
+lock type "none".  LVM commands and lvmlockd do not perform locking for
+these VGs.  A local VG typically exists on local (non-shared) devices and
+cannot be used concurrently from different hosts.
+
+If a local VG does exist on shared devices, it should be owned by a single
+host by having its system ID set, see
+.BR lvmsystemid (7).
+Only the host with a matching system ID can use the local VG.  A VG
+with no lock type and no system ID should be excluded from all but one
+host using lvm.conf filters.  Without any of these protections, a local VG
+on shared devices can be easily damaged or destroyed.
+
+.I "clvm VG"
+
+A "clvm VG" is a VG on shared storage (like a lockd VG) that requires
+clvmd for clustering.  See below for converting a clvm VG to a lockd VG.
+
+
+.SS lockd VGs from hosts not using lvmlockd
+
+Only hosts that will use lockd VGs should be configured to run lvmlockd.
+However, devices with lockd VGs may be visible from hosts not using
+lvmlockd.  From a host not using lvmlockd, visible lockd VGs are ignored
+in the same way as foreign VGs, i.e. those with a foreign system ID, see
+.BR lvmsystemid (7).
+
+
+.SS vgcreate differences
+
+Forms of the vgcreate command:
+
+.B vgcreate <vg_name> <devices>
+
+.IP \[bu] 2
+Creates a local VG with the local system ID when neither lvmlockd nor clvm are configured.
+.IP \[bu] 2
+Creates a local VG with the local system ID when lvmlockd is configured.
+.IP \[bu] 2
+Creates a clvm VG when clvm is configured.
+
+.P
+
+.B vgcreate --shared <vg_name> <devices>
+.IP \[bu] 2
+Requires lvmlockd to be configured (use_lvmlockd=1).
+.IP \[bu] 2
+Creates a lockd VG with lock type sanlock|dlm depending on which is running.
+.IP \[bu] 2
+LVM commands request locks from lvmlockd to use the VG.
+.IP \[bu] 2
+lvmlockd obtains locks from the selected lock manager.
+
+.P
+
+.B vgcreate -c|--clustered y <vg_name> <devices>
+.IP \[bu] 2
+Requires clvm to be configured (locking_type=3).
+.IP \[bu] 2
+Creates a clvm VG with the "clustered" flag.
+.IP \[bu] 2
+LVM commands request locks from clvmd to use the VG.
+
+.P
+
+.SS using lockd VGs
+
+When use_lvmlockd is first enabled, and before the first lockd VG is
+created, no global lock will exist, and LVM commands will try and fail to
+acquire it.  LVM commands will report a warning until the first lockd VG
+is created which will create the global lock.  Before the global lock
+exists, VGs can still be read, but commands that require the global lock
+exclusively will fail.
+
+When a new lockd VG is created, its lockspace is automatically started on
+the host that creates the VG.  Other hosts will need to run 'vgcreate
+--lock-start' to start the new VG before they can use it.
+
+From the 'vgs' reporting command, lockd VGs are indicated by "s" (for
+shared) in the sixth attr field.  The specific lock type and lock args
+for a lockd VG can be displayed with 'vgs -o+locktype,lockargs'.
+
+
+.SS starting and stopping VGs
+
+Starting a lockd VG (vgchange --lock-start) causes the lock manager to
+start or join the lockspace for the VG.  This makes locks for the VG
+accessible to the host.  Stopping the VG leaves the lockspace and makes
+locks for the VG inaccessible to the host.
+
+Lockspaces should be started as early as possible because starting
+(joining) a lockspace can take a long time (potentially minutes after a
+host failure when using sanlock.)  A VG can be started after all the
+following are true:
+
+.nf
+- lvmlockd is running
+- lock manager is running
+- VG is visible to the system
+.fi
+
+All lockd VGs can be started/stopped using:
+.br
+vgchange --lock-start
+.br
+vgchange --lock-stop
+
+
+Individual VGs can be started/stopped using:
+.br
+vgchange --lock-start <vg_name> ...
+.br
+vgchange --lock-stop <vg_name> ...
+
+To make vgchange not wait for start to complete:
+.br
+vgchange --lock-start --lock-opt nowait
+.br
+vgchange --lock-start --lock-opt nowait <vg_name>
+
+To stop all lockspaces and wait for all to complete:
+.br
+lvmlockctl --stop-lockspaces --wait
+
+To start only selected lockd VGs, use the lvm.conf
+activation/lock_start_list.  When defined, only VG names in this list are
+started by vgchange.  If the list is not defined (the default), all
+visible lockd VGs are started.  To start only "vg1", use the following
+lvm.conf configuration:
+
+.nf
+activation {
+    lock_start_list = [ "vg1" ]
+    ...
+}
+.fi
+
+
+.SS automatic starting and automatic activation
+
+Scripts or programs on a host that automatically start VGs will use the
+"auto" option to indicate that the command is being run automatically by
+the system:
+
+vgchange --lock-start --lock-opt auto [vg_name ...]
+
+Without any additional configuration, including the "auto" option has no
+effect; all VGs are started unless restricted by lock_start_list.
+
+However, when the lvm.conf activation/auto_lock_start_list is defined, the
+auto start command performs an additional filtering phase to all VGs being
+started, testing each VG name against the auto_lock_start_list.  The
+auto_lock_start_list defines lockd VGs that will be started by the auto
+start command.  Visible lockd VGs not included in the list are ignored by
+the auto start command.  If the list is undefined, all VG names pass this
+filter.  (The lock_start_list is also still used to filter all VGs.)
+
+The auto_lock_start_list allows a user to select certain lockd VGs that
+should be automatically started by the system (or indirectly, those that
+should not).
+
+To use auto activation of lockd LVs (see auto_activation_volume_list),
+auto starting of the corresponding lockd VGs is necessary.
+
+
+.SS locking activity
+
+To optimize the use of LVM with lvmlockd, consider the three kinds of
+locks in lvmlockd and when they are used:
+
+.I GL lock
+
+The global lock (GL lock) is associated with global information, which is
+information not isolated to a single VG.  This includes:
+
+- The global VG namespace.
+.br
+- The set of orphan PVs and unused devices.
+.br
+- The properties of orphan PVs, e.g. PV size.
+
+The global lock is used in shared mode by commands that read this
+information, or in exclusive mode by commands that change it.
+
+The command 'vgs' acquires the global lock in shared mode because it
+reports the list of all VG names.
+
+The vgcreate command acquires the global lock in exclusive mode because it
+creates a new VG name, and it takes a PV from the list of unused PVs.
+
+When an LVM command is given a tag argument, or uses select, it must read
+all VGs to match the tag or selection, which causes the global lock to be
+acquired.  To avoid use of the global lock, avoid using tags and select,
+and specify VG name arguments.
+
+When use_lvmlockd is enabled, LVM commands attempt to acquire the global
+lock even if no lockd VGs exist.  For this reason, lvmlockd should not be
+enabled unless lockd VGs will be used.
+
+.I VG lock
+
+A VG lock is associated with each VG.  The VG lock is acquired in shared
+mode to read the VG and in exclusive mode to change the VG (modify the VG
+metadata).  This lock serializes modifications to a VG with all other LVM
+commands on other hosts.
+
+The command 'vgs' will not only acquire the GL lock to read the list of
+all VG names, but will acquire the VG lock for each VG prior to reading
+it.
+
+The command 'vgs <vg_name>' does not acquire the GL lock (it does not need
+the list of all VG names), but will acquire the VG lock on each VG name
+argument.
+
+.I LV lock
+
+An LV lock is acquired before the LV is activated, and is released after
+the LV is deactivated.  If the LV lock cannot be acquired, the LV is not
+activated.  LV locks are persistent and remain in place after the
+activation command is done.  GL and VG locks are transient, and are held
+only while an LVM command is running.
+
+.I retries
+
+If a request for a GL or VG lock fails due to a lock conflict with another
+host, lvmlockd automatically retries for a short time before returning a
+failure to the LVM command.  The LVM command will then retry the entire
+lock request a number of times specified by global/lock_retries before
+failing.  If a request for an LV lock fails due to a lock conflict, the
+command fails immediately.
+
+
+.SS sanlock global lock
+
+There are some special cases related to the global lock in sanlock VGs.
+
+The global lock exists in one of the sanlock VGs.  The first sanlock VG
+created will contain the global lock.  Subsequent sanlock VGs will each
+contain disabled global locks that can be enabled later if necessary.
+
+The VG containing the global lock must be visible to all hosts using
+sanlock VGs.  This can be a reason to create a small sanlock VG, visible
+to all hosts, and dedicated to just holding the global lock.  While not
+required, this strategy can help to avoid extra work in the future if VGs
+are moved or removed.
+
+The vgcreate command typically acquires the global lock, but in the case
+of the first sanlock VG, there will be no global lock to acquire until the
+initial vgcreate is complete.  So, creating the first sanlock VG is a
+special case that skips the global lock.
+
+vgcreate for a sanlock VG determines it is the first one to exist if no
+other sanlock VGs are visible.  It is possible that other sanlock VGs do
+exist but are not visible or started on the host running vgcreate.  This
+raises the possibility of more than one global lock existing.  If this
+happens, commands will warn of the condition, and it should be manually
+corrected.
+
+If the situation arises where more than one sanlock VG contains a global
+lock, the global lock should be manually disabled in all but one of them
+with the command:
+
+lvmlockctl --gl-disable <vg_name>
+
+(The one VG with the global lock enabled must be visible to all hosts.)
+
+An opposite problem can occur if the VG holding the global lock is
+removed.  In this case, no global lock will exist following the vgremove,
+and subsequent LVM commands will fail to acquire it.  In this case, the
+global lock needs to be manually enabled in one of the remaining sanlock
+VGs with the command:
+
+lvmlockctl --gl-enable <vg_name>
+
+A small sanlock VG dedicated to holding the global lock can avoid the case
+where the GL lock must be manually enabled after a vgremove.
+
+
+.SS changing lock type
+
+To change a local VG to a lockd VG:
+
+vgchange --lock-type sanlock|dlm <vg_name>
+
+All LVs must be inactive to change the lock type.
+
+To change a clvm VG to a lockd VG:
+
+vgchange --lock-type sanlock|dlm <vg_name>
+
+Changing a lockd VG to a local VG is not yet generally allowed.
+(It can be done partially in certain recovery cases.)
+
+
+.SS vgremove of a sanlock VG
+
+vgremove of a sanlock VG will fail if other hosts have the VG started.
+Run vgchange --lock-stop <vg_name> on all other hosts before vgremove.
+
+(It may take several seconds before vgremove recognizes that all hosts
+have stopped.)
+
+
+.SS shared LVs
+
+When an LV is used concurrently from multiple hosts (e.g. by a
+multi-host/cluster application or file system), the LV can be activated on
+multiple hosts concurrently using a shared lock.
+
+To activate the LV with a shared lock:  lvchange -asy vg/lv.
+
+With lvmlockd, an unspecified activation mode is always exclusive, i.e.
+-ay defaults to -aey.
+
+If the LV type does not allow the LV to be used concurrently from multiple
+hosts, then a shared activation lock is not allowed and the lvchange
+command will report an error.  LV types that cannot be used concurrently
+from multiple hosts include thin, cache, raid, mirror, and snapshot.
+
+lvextend on LV with shared locks is not yet allowed.  The LV must be
+deactivated, or activated exclusively to run lvextend.
+
+
+.SS recover from lost PV holding sanlock locks
+
+A number of special manual steps must be performed to restore sanlock
+locks if the PV holding the locks is lost.  Contact the LVM group for
+help with this process.
+
+
+.\" This is not clean or safe enough to suggest using without help.
+.\"
+.\" .SS recover from lost PV holding sanlock locks
+.\"
+.\" In a sanlock VG, the locks are stored on a PV within the VG.  If this PV
+.\" is lost, the locks need to be reconstructed as follows:
+.\"
+.\" 1. Enable the unsafe lock modes option in lvm.conf so that default locking requirements can be overriden.
+.\"
+.\" .nf
+.\" allow_override_lock_modes = 1
+.\" .fi
+.\"
+.\" 2. Remove missing PVs and partial LVs from the VG.
+.\"
+.\" Warning: this is a dangerous operation.  Read the man page
+.\" for vgreduce first, and try running with the test option.
+.\" Verify that the only missing PV is the PV holding the sanlock locks.
+.\"
+.\" .nf
+.\" vgreduce --removemissing --force --lock-gl na --lock-vg na <vg>
+.\" .fi
+.\"
+.\" 3. If step 2 does not remove the internal/hidden "lvmlock" lv, it should be removed.
+.\"
+.\" .nf
+.\" lvremove --lock-vg na --lock-lv na <vg>/lvmlock
+.\" .fi
+.\"
+.\" 4. Change the lock type to none.
+.\"
+.\" .nf
+.\" vgchange --lock-type none --force --lock-gl na --lock-vg na <vg>
+.\" .fi
+.\"
+.\" 5. VG space is needed to recreate the locks.  If there is not enough space, vgextend the vg.
+.\"
+.\" 6. Change the lock type back to sanlock.  This creates a new internal
+.\" lvmlock lv, and recreates locks.
+.\"
+.\" .nf
+.\" vgchange --lock-type sanlock <vg>
+.\" .fi
+
+.SS locking system failures
+
+.B lvmlockd failure
+
+If lvmlockd fails or is killed while holding locks, the locks are orphaned
+in the lock manager.  lvmlockd can be restarted, and it will adopt the
+locks from the lock manager that had been held by the previous instance.
+
+.B dlm/corosync failure
+
+If dlm or corosync fail, the clustering system will fence the host using a
+method configured within the dlm/corosync clustering environment.
+
+LVM commands on other hosts will be blocked from acquiring any locks until
+the dlm/corosync recovery process is complete.
+
+.B sanlock lock storage failure
+
+If access to the device containing the VG's locks is lost, sanlock cannot
+renew its leases for locked LVs.  This means that the host could soon lose
+the lease to another host which could activate the LV exclusively.
+sanlock is designed to never reach the point where two hosts hold the
+same lease exclusively at once, so the same LV should never be active on
+two hosts at once when activated exclusively.
+
+The current method of handling this involves no action from lvmlockd,
+while allowing sanlock to protect the leases itself.  This produces a safe
+but potentially inconvenient result.  Doing nothing from lvmlockd leads to
+the host's LV locks not being released, which leads to sanlock using the
+local watchdog to reset the host before another host can acquire any locks
+held by the local host.
+
+LVM commands on other hosts will be blocked from acquiring locks held by
+the failed/reset host until the sanlock recovery time expires (2-4
+minutes).  This includes activation of any LVs that were locked by the
+failed host.  It also includes GL/VG locks held by any LVM commands that
+happened to be running on the failed host at the time of the failure.
+
+(In the future, lvmlockd may have the option to suspend locked LVs in
+response the sanlock leases expiring.  This would avoid the need for
+sanlock to reset the host.)
+
+.B sanlock daemon failure
+
+If the sanlock daemon fails or exits while a lockspace is started, the
+local watchdog will reset the host.  See previous section for the impact
+on other hosts.
+
+
+.SS changing dlm cluster name
+
+When a dlm VG is created, the cluster name is saved in the VG metadata for
+the new VG.  To use the VG, a host must be in the named cluster.  If the
+cluster name is changed, or the VG is moved to a different cluster, the
+cluster name for the dlm VG must be changed.  To do this:
+
+1. Ensure the VG is not being used by any hosts.
+
+2. The new cluster must be active on the node making the change.
+.br
+   The current dlm cluster name can be seen by:
+.br
+   cat /sys/kernel/config/dlm/cluster/cluster_name
+
+3. Change the VG lock type to none:
+.br
+   vgchange --lock-type none --force <vg_name>
+
+4. Change the VG lock type back to dlm which sets the new cluster name:
+.br
+   vgchange --lock-type dlm <vg_name>
+
+
+.SS limitations of lvmlockd and lockd VGs
+
+lvmlockd currently requires using lvmetad and lvmpolld.
+
+If a lockd VG becomes visible after the initial system startup, it is not
+automatically started through the system service/init manager, and LVs in
+it are not autoactivated.
+
+Things that do not yet work in lockd VGs:
+.br
+- old style mirror LVs (only raid1)
+.br
+- creating a new thin pool and a new thin LV in a single command
+.br
+- using lvcreate to create cache pools or cache LVs (use lvconvert)
+.br
+- splitting raid1 mirror LVs
+.br
+- vgsplit
+.br
+- vgmerge
+.br
+- resizing an LV that is active in the shared mode on multiple hosts
+
+
+.SS clvmd to lvmlockd transition
+
+(See above for converting an existing clvm VG to a lockd VG.)
+
+While lvmlockd and clvmd are entirely different systems, LVM usage remains
+largely the same.  Differences are more notable when using lvmlockd's
+sanlock option.
+
+Visible usage differences between lockd VGs with lvmlockd and clvm VGs
+with clvmd:
+
+.IP \[bu] 2
+lvm.conf must be configured to use either lvmlockd (use_lvmlockd=1) or
+clvmd (locking_type=3), but not both.
+
+.IP \[bu] 2
+vgcreate --shared creates a lockd VG, and vgcreate --clustered y creates a
+clvm VG.
+
+.IP \[bu] 2
+lvmlockd adds the option of using sanlock for locking, avoiding the
+need for network clustering.
+
+.IP \[bu] 2
+lvmlockd does not require all hosts to see all the same shared devices.
+
+.IP \[bu] 2
+lvmlockd defaults to the exclusive activation mode whenever the activation
+mode is unspecified, i.e. -ay means -aey, not -asy.
+
+.IP \[bu] 2
+lvmlockd commands always apply to the local host, and never have an effect
+on a remote host.  (The activation option 'l' is not used.)
+
+.IP \[bu] 2
+lvmlockd works with thin and cache pools and LVs.
+
+.IP \[bu] 2
+lvmlockd saves the cluster name for a lockd VG using dlm.  Only hosts in
+the matching cluster can use the VG.
+
+.IP \[bu] 2
+lvmlockd requires starting/stopping lockd VGs with vgchange --lock-start
+and --lock-stop.
+
+.IP \[bu] 2
+vgremove of a sanlock VG may fail indicating that all hosts have not
+stopped the lockspace for the VG.  Stop the VG lockspace on all uses using
+vgchange --lock-stop.
+
+.IP \[bu] 2
+Long lasting lock contention among hosts may result in a command giving up
+and failing.  The number of lock retries can be adjusted with
+global/lock_retries.
+
+.IP \[bu] 2
+The reporting options locktype and lockargs can be used to view lockd VG
+and LV lock_type and lock_args fields, i.g. vgs -o+locktype,lockargs.
+In the sixth VG attr field, "s" for "shared" is displayed for lockd VGs.
+
+.IP \[bu] 2
+If lvmlockd fails or is killed while in use, locks it held remain but are
+orphaned in the lock manager.  lvmlockd can be restarted with an option to
+adopt the orphan locks from the previous instance of lvmlockd.
+
+.P
diff --git a/man/lvmsystemid.7.in b/man/lvmsystemid.7.in
index 76b0e83..37a01af 100644
--- a/man/lvmsystemid.7.in
+++ b/man/lvmsystemid.7.in
@@ -83,9 +83,10 @@ version without the system_id feature.
 .P
 
 .SS Types of VG access
-A "local VG" is meant to be used by a single host.
+
+A local VG is mean to be used by a single host.
 .br
-A "shared VG" is meant to be used by multiple hosts.
+A shared or clustered VG is meant to be used by multiple hosts.
 .br
 These can be further distinguished as:
 
@@ -107,9 +108,15 @@ A local VG that has been exported with vgexport and has no system_id.
 This VG type can only be accessed by vgimport which will change it to
 owned.
 
+.B Shared:
+A shared or "lockd" VG has lock_type set and no system_id.
+A shared VG is meant to be used on shared storage from multiple hosts,
+and is only accessible to hosts using lvmlockd.
+
 .B Clustered:
-A shared VG with the clustered flag set, and no system_id.  This VG type
-is only accessible to hosts using clvmd.
+A clustered or "clvm" VG has the clustered flag set and no system_id.
+A clustered VG is meant to be used on shared storage from multiple hosts,
+and is only accessible to hosts using clvmd.
 
 .SS system_id_source
 
@@ -297,10 +304,16 @@ system_id to its allow_system_id list, change the system_id of the foreign
 VG to its own, and remove the foreign system_id from its allow_system_id
 list.
 
+.SS shared VGs
+
+A shared/lockd VG has no system_id set, allowing multiple hosts to
+use it via lvmlockd.  Changing a VG to a lockd type will clear the
+existing system_id.
+
 .SS clustered VGs
 
-A "clustered" VG should have no system_id set, allowing multiple hosts to
-use it via clvm.  Changing a VG to clustered will clear the existing
+A clustered/clvm VG has no system_id set, allowing multiple hosts to
+use it via clvmd.  Changing a VG to clustered will clear the existing
 system_id.  Changing a VG to not clustered will set the system_id to the
 host running the vgchange command.
 
diff --git a/nix/default.nix b/nix/default.nix
index cd2fd33..c7462a0 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -367,6 +367,7 @@ let
       centos66 = centos65;
       centos70 = [ "dlm-devel" "dlm" "corosynclib-devel" "perl-Digest-MD5" "systemd-devel"
                    "socat" # used by test suite lvmpolld
+                   "sanlock" # used by test suite lvmlockd
                    "procps-ng" ];
 
       fedora17_18 = [ "dlm-devel" "corosynclib-devel" "libblkid" "libblkid-devel"
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index e9cce3a..2ae5325 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -121,6 +121,10 @@ ifeq ("@BUILD_LVMPOLLD@", "yes")
 	$(INSTALL_DATA) lvm2_lvmpolld_systemd_red_hat.socket $(systemd_unit_dir)/lvm2-lvmpolld.socket
 	$(INSTALL_DATA) lvm2_lvmpolld_systemd_red_hat.service $(systemd_unit_dir)/lvm2-lvmpolld.service
 endif
+ifeq ("@BUILD_LVMLOCKD@", "yes")
+	$(INSTALL_DATA) lvm2_lvmlockd_systemd_red_hat.service $(systemd_unit_dir)/lvm2-lvmlockd.service
+	$(INSTALL_DATA) lvm2_lvmlocking_systemd_red_hat.service $(systemd_unit_dir)/lvm2-lvmlocking.service
+endif
 ifneq ("@CLVMD@", "none")
 	$(INSTALL_DATA) lvm2_clvmd_systemd_red_hat.service $(systemd_unit_dir)/lvm2-clvmd.service
 	$(INSTALL_DATA) lvm2_cluster_activation_systemd_red_hat.service $(systemd_unit_dir)/lvm2-cluster-activation.service
@@ -151,6 +155,8 @@ DISTCLEAN_TARGETS += \
 	lvm2_lvmetad_systemd_red_hat.socket \
 	lvm2_lvmpolld_systemd_red_hat.service \
 	lvm2_lvmpolld_systemd_red_hat.socket \
+	lvm2_lvmlockd_systemd_red_hat.service \
+	lvm2_lvmlocking_systemd_red_hat.service \
 	lvm2_monitoring_init_red_hat \
 	lvm2_monitoring_systemd_red_hat.service \
 	lvm2_pvscan_systemd_red_hat at .service \
diff --git a/scripts/lvm2_lvmlockd_systemd_red_hat.service.in b/scripts/lvm2_lvmlockd_systemd_red_hat.service.in
new file mode 100644
index 0000000..17c7dbf
--- /dev/null
+++ b/scripts/lvm2_lvmlockd_systemd_red_hat.service.in
@@ -0,0 +1,16 @@
+[Unit]
+Description=LVM2 lock daemon
+Documentation=man:lvmlockd(8)
+After=lvm2-lvmetad.service
+
+[Service]
+Type=simple
+NonBlocking=true
+ExecStart=@sbindir@/lvmlockd -f
+Environment=SD_ACTIVATION=1
+PIDFile=@LVMLOCKD_PIDFILE@
+SendSIGKILL=no
+
+[Install]
+WantedBy=multi-user.target
+
diff --git a/scripts/lvm2_lvmlocking_systemd_red_hat.service.in b/scripts/lvm2_lvmlocking_systemd_red_hat.service.in
new file mode 100644
index 0000000..bfac578
--- /dev/null
+++ b/scripts/lvm2_lvmlocking_systemd_red_hat.service.in
@@ -0,0 +1,24 @@
+[Unit]
+Description=Availability of lockspaces in lvmlockd
+Documentation=man:lvmlockd(8)
+After=lvm2-lvmlockd.service sanlock.service dlm.service
+
+[Service]
+Type=oneshot
+RemainAfterExit=yes
+
+# start lockspaces and wait for them to finish starting
+ExecStart=@sbindir@/vgchange --lock-start --lock-opt autowait
+
+# auto activate LVs in the newly started lockd VGs
+ExecStart=@sbindir@/vgchange -aay -S 'locktype=sanlock || locktype=dlm'
+
+# deactivate LVs in lockd VGs
+ExecStop=@sbindir@/vgchange -an -S 'locktype=sanlock || locktype=dlm'
+
+# stop lockspaces and wait for them to finish stopping
+ExecStop=@sbindir@/lvmlockctl --stop-lockspaces --wait 1
+
+[Install]
+WantedBy=multi-user.target
+
diff --git a/spec/build.inc b/spec/build.inc
index 3979073..db9bcc2 100644
--- a/spec/build.inc
+++ b/spec/build.inc
@@ -6,6 +6,8 @@
 %enableif %{enable_lvmetad} lvmetad
 %global enable_lvmpolld %(if echo %{services} | grep -q lvmpolld; then echo 1; else echo 0; fi)
 %enableif %{enable_lvmpolld} lvmpolld
+%global enable_lvmlockd %(if echo %{services} | grep -q lvmlockd; then echo 1; else echo 0; fi)
+%enableif %{enable_lvmlockd} lvmlockd
 
 %build
 %configure \
diff --git a/spec/packages.inc b/spec/packages.inc
index b9caa65..8d2195a 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -86,6 +86,10 @@ fi
 %if %{have_service lvmpolld}
  %{_sbindir}/lvmpolld
 %endif
+%if %{have_service lvmlockd}
+ %{_sbindir}/lvmlockd
+ %{_sbindir}/lvmlockctl
+%endif
 %if %{have_with cache}
   %{_mandir}/man7/lvmcache.7.gz
 %endif
@@ -156,6 +160,9 @@ fi
   %{_mandir}/man8/lvmpolld.8.gz
   %{_mandir}/man8/lvm-lvpoll.8.gz
 %endif
+%if %{have_service lvmlockd}
+  %{_mandir}/man8/lvmlockd.8.gz
+%endif
 %dir %{_sysconfdir}/lvm
 %ghost %{_sysconfdir}/lvm/cache/.cache
 %config(noreplace) %verify(not md5 mtime size) %{_sysconfdir}/lvm/lvm.conf
@@ -182,6 +189,11 @@ fi
   %{_unitdir}/lvm2-lvmpolld.service
   %{_unitdir}/lvm2-lvmpolld.socket
  %endif
+ %if %{have_service lvmlockd}
+  %{_unitdir}/lvm2-lvmlockd.service
+  %{_unitdir}/lvm2-lvmlocking.service
+  #%{_unitdir}/lvm2-lvmlockd.socket
+ %endif
 %else
  %{_sysconfdir}/rc.d/init.d/lvm2-monitor
  %{_sysconfdir}/rc.d/init.d/blk-availability
@@ -191,6 +203,9 @@ fi
  %if %{have_service lvmpolld}
   %{_sysconfdir}/rc.d/init.d/lvm2-lvmpolld
  %endif
+ #%if %{have_service lvmlockd}
+ # %{_sysconfdir}/rc.d/init.d/lvm2-lvmlockd
+ #%endif
 %endif
 
 ##############################################################################
diff --git a/spec/source.inc b/spec/source.inc
index a11f4b7..00d5282 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -27,6 +27,8 @@
 
 %service lvmpolld 1
 
+%service lvmlockd 1
+
 ##############################################################
 
 %if %{fedora} == 16 || %{rhel} == 6
diff --git a/test/Makefile.in b/test/Makefile.in
index cd2c425..bba33db 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -70,6 +70,8 @@ help:
 	@echo "  check_cluster		Run tests with cluster daemon."
 	@echo "  check_lvmetad		Run tests with lvmetad daemon."
 	@echo "  check_lvmpolld         Run tests with lvmpolld daemon."
+	@echo "  check_lvmlockd_sanlock Run tests with lvmlockd and sanlock."
+	@echo "  check_lvmlockd_dlm     Run tests with lvmlockd and dlm."
 	@echo "  clean			Clean dir."
 	@echo "  help			Display callable targets."
 	@echo -e "\nSupported variables:"
@@ -138,6 +140,32 @@ check_lvmpolld: .tests-stamp
 		--flavours ndev-lvmpolld,ndev-cluster-lvmpolld,ndev-lvmetad-lvmpolld --only $(T) --skip $(S)
 endif
 
+ifeq ("@BUILD_LVMLOCKD@", "yes")
+check_lvmlockd_sanlock: .tests-stamp
+	VERBOSE=$(VERBOSE) ./lib/runner \
+		--testdir . --outdir results \
+		--flavours udev-lvmlockd-sanlock --only shell/sanlock-prepare.sh
+	VERBOSE=$(VERBOSE) ./lib/runner \
+		--testdir . --outdir results \
+		--flavours udev-lvmlockd-sanlock --only $(T) --skip $(S)
+	VERBOSE=$(VERBOSE) ./lib/runner \
+		--testdir . --outdir results \
+		--flavours udev-lvmlockd-sanlock --only shell/sanlock-remove.sh
+endif
+
+ifeq ("@BUILD_LVMLOCKD@", "yes")
+check_lvmlockd_dlm: .tests-stamp
+	VERBOSE=$(VERBOSE) ./lib/runner \
+		--testdir . --outdir results \
+		--flavours udev-lvmlockd-dlm --only shell/dlm-prepare.sh
+	VERBOSE=$(VERBOSE) ./lib/runner \
+		--testdir . --outdir results \
+		--flavours udev-lvmlockd-dlm --only $(T) --skip $(S)
+	VERBOSE=$(VERBOSE) ./lib/runner \
+		--testdir . --outdir results \
+		--flavours udev-lvmlockd-dlm --only shell/dlm-remove.sh
+endif
+
 DATADIR = $(datadir)/lvm2-testsuite
 EXECDIR = $(libexecdir)/lvm2-testsuite
 
@@ -153,6 +181,8 @@ LIB_FLAVOURS = \
  lib/flavour-udev-lvmetad-lvmpolld\
  lib/flavour-udev-lvmetad\
  lib/flavour-udev-lvmpolld\
+ lib/flavour-udev-lvmlockd-sanlock\
+ lib/flavour-udev-lvmlockd-dlm\
  lib/flavour-udev-vanilla
 
 LIB_LOCAL = lib/paths lib/runner
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 53ebd8a..459e7f1 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -542,6 +542,12 @@ prepare_devs() {
 	local pvname=${3:-pv}
 	local shift=0
 
+	# sanlock requires more space for the internal sanlock lv
+	# This could probably be lower, but what are the units?
+	if test -n "$LVM_TEST_LOCK_TYPE_SANLOCK" ; then
+		devsize = 1024
+	fi
+
 	touch DEVICES
 	prepare_backing_dev $(($n*$devsize))
 	# shift start of PV devices on /dev/loopXX by 1M
@@ -817,6 +823,9 @@ generate_config() {
 	LVM_TEST_LOCKING=${LVM_TEST_LOCKING:-1}
 	LVM_TEST_LVMETAD=${LVM_TEST_LVMETAD:-0}
 	LVM_TEST_LVMPOLLD=${LVM_TEST_LVMPOLLD:-0}
+	LVM_TEST_LVMLOCKD=${LVM_TEST_LVMLOCKD:-0}
+	LVM_TEST_LOCK_TYPE_SANLOCK=${LVM_TEST_LOCK_TYPE_SANLOCK:-0}
+	LVM_TEST_LOCK_TYPE_DLM=${LVM_TEST_LOCK_TYPE_DLM:-0}
 	if test "$DM_DEV_DIR" = "/dev"; then
 	    LVM_VERIFY_UDEV=${LVM_VERIFY_UDEV:-0}
 	else
@@ -859,6 +868,7 @@ global/thin_dump_executable = "$LVM_TEST_THIN_DUMP_CMD"
 global/thin_repair_executable = "$LVM_TEST_THIN_REPAIR_CMD"
 global/use_lvmetad = $LVM_TEST_LVMETAD
 global/use_lvmpolld = $LVM_TEST_LVMPOLLD
+global/use_lvmlockd = $LVM_TEST_LVMLOCKD
 log/activation = 1
 log/file = "$TESTDIR/debug.log"
 log/indent = 1
diff --git a/test/lib/flavour-udev-lvmlockd-dlm.sh b/test/lib/flavour-udev-lvmlockd-dlm.sh
new file mode 100644
index 0000000..5bd2749
--- /dev/null
+++ b/test/lib/flavour-udev-lvmlockd-dlm.sh
@@ -0,0 +1,6 @@
+export LVM_TEST_LOCKING=1
+export LVM_TEST_LVMETAD=1
+export LVM_TEST_LVMPOLLD=1
+export LVM_TEST_LVMLOCKD=1
+export LVM_TEST_LOCK_TYPE_DLM=1
+export LVM_TEST_DEVDIR=/dev
diff --git a/test/lib/flavour-udev-lvmlockd-sanlock.sh b/test/lib/flavour-udev-lvmlockd-sanlock.sh
new file mode 100644
index 0000000..859ee2e
--- /dev/null
+++ b/test/lib/flavour-udev-lvmlockd-sanlock.sh
@@ -0,0 +1,6 @@
+export LVM_TEST_LOCKING=1
+export LVM_TEST_LVMETAD=1
+export LVM_TEST_LVMPOLLD=1
+export LVM_TEST_LVMLOCKD=1
+export LVM_TEST_LOCK_TYPE_SANLOCK=1
+export LVM_TEST_DEVDIR=/dev
diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 0b898f3..a5eeb57 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -106,6 +106,13 @@ test -n "$LVM_TEST_LVMPOLLD" && {
 	aux prepare_lvmpolld
 }
 
+if test -n "$LVM_TEST_LVMLOCKD" ; then
+	if test -n "$LVM_TEST_LOCK_TYPE_SANLOCK" ; then
+		aux lvmconf 'local/host_id = 1'
+	fi
+	export SHARED="--shared"
+fi
+
 echo "<======== Processing test: \"$TESTNAME\" ========>"
 
 set -vx
diff --git a/test/lib/test-corosync-conf b/test/lib/test-corosync-conf
new file mode 100644
index 0000000..ccc958f
--- /dev/null
+++ b/test/lib/test-corosync-conf
@@ -0,0 +1,19 @@
+# created by lvm test suite
+totem {
+        version: 2
+        secauth: off
+        cluster_name: test
+}
+nodelist {
+        node {
+                ring0_addr: @LOCAL_NODE@
+                nodeid: 1
+        }
+}
+quorum {
+        provider: corosync_votequorum
+}
+logging {
+        to_syslog: yes
+}
+
diff --git a/test/lib/test-dlm-conf b/test/lib/test-dlm-conf
new file mode 100644
index 0000000..a93c93f
--- /dev/null
+++ b/test/lib/test-dlm-conf
@@ -0,0 +1,4 @@
+# created by lvm test suite
+log_debug=1
+enable_fencing=0
+
diff --git a/test/lib/test-sanlock-conf b/test/lib/test-sanlock-conf
new file mode 100644
index 0000000..d1df598
--- /dev/null
+++ b/test/lib/test-sanlock-conf
@@ -0,0 +1,2 @@
+# created by lvm test suite
+SANLOCKOPTS="-U sanlock -G sanlock -w 0"
diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index fe7ccd3..24c9076 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -57,6 +57,8 @@ mkdtemp() {
 	destdir=$1
 	template=$2
 
+        test -d "$destdir" || die "DIR ('$destdir') does not exist."
+
 	case "$template" in
 		*XXXX) ;;
 		*) die "Invalid template: $template (must have a suffix of at least 4 X's)";;
diff --git a/test/shell/dlm-hello-world.sh b/test/shell/dlm-hello-world.sh
new file mode 100644
index 0000000..3f5fc57
--- /dev/null
+++ b/test/shell/dlm-hello-world.sh
@@ -0,0 +1,27 @@
+#!/bin/sh
+# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Hello world for vgcreate with lvmlockd and dlm'
+
+. lib/inittest
+
+[ -z "$LVM_TEST_LOCK_TYPE_DLM" ] && skip;
+
+aux prepare_devs 1
+
+vgcreate $SHARED $vg "$dev1"
+
+vgs -o+locktype,lockargs $vg
+
+check vg_field $vg vg_locktype dlm
+
+vgremove $vg
+
diff --git a/test/shell/dlm-prepare.sh b/test/shell/dlm-prepare.sh
new file mode 100644
index 0000000..c4f02a4
--- /dev/null
+++ b/test/shell/dlm-prepare.sh
@@ -0,0 +1,90 @@
+#!/bin/sh
+# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Set up things to run tests with dlm'
+
+. lib/utils
+. lib/inittest
+
+[ -z "$LVM_TEST_LOCK_TYPE_DLM" ] && skip;
+
+COROSYNC_CONF="/etc/corosync/corosync.conf"
+COROSYNC_NODE="$(hostname)"
+create_corosync_conf() {
+	if test -a $COROSYNC_CONF; then
+		if ! grep "created by lvm test suite" $COROSYNC_CONF; then
+			rm $COROSYNC_CONF
+		else
+			mv $COROSYNC_CONF $COROSYNC_CONF.prelvmtest
+		fi
+	fi
+
+	sed -e "s/@LOCAL_NODE@/$COROSYNC_NODE/" lib/test-corosync-conf > $COROSYNC_CONF
+	echo "created new $COROSYNC_CONF"
+}
+
+DLM_CONF="/etc/dlm/dlm.conf"
+create_dlm_conf() {
+	if test -a $DLM_CONF; then
+		if ! grep "created by lvm test suite" $DLM_CONF; then
+			rm $DLM_CONF
+		else
+			mv $DLM_CONF $DLM_CONF.prelvmtest
+		fi
+	fi
+
+	cp lib/test-dlm-conf $DLM_CONF
+	echo "created new $DLM_CONF"
+}
+
+prepare_lvmlockd_dlm() {
+	if pgrep lvmlockd ; then
+		echo "Cannot run while existing lvmlockd process exists"
+		exit 1
+	fi
+
+	if pgrep dlm_controld ; then
+		echo "Cannot run while existing dlm_controld process exists"
+		exit 1
+	fi
+
+	if pgrep corosync; then
+		echo "Cannot run while existing corosync process exists"
+		exit 1
+	fi
+
+	create_corosync_conf
+	create_dlm_conf
+
+	systemctl start corosync
+	sleep 1
+	if ! pgrep corosync; then
+		echo "Failed to start corosync"
+		exit 1
+	fi
+
+	systemctl start dlm
+	sleep 1
+	if ! pgrep dlm_controld; then
+		echo "Failed to start dlm"
+		exit 1
+	fi
+
+	lvmlockd
+	sleep 1
+	if ! pgrep lvmlockd ; then
+		echo "Failed to start lvmlockd"
+		exit 1
+	fi
+}
+
+prepare_lvmlockd_dlm
+
diff --git a/test/shell/dlm-remove.sh b/test/shell/dlm-remove.sh
new file mode 100644
index 0000000..d7af46f
--- /dev/null
+++ b/test/shell/dlm-remove.sh
@@ -0,0 +1,20 @@
+#!/bin/sh
+# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Remove the dlm test setup'
+
+. lib/inittest
+
+[ -z "$LVM_TEST_LOCK_TYPE_DLM" ] && skip;
+
+systemctl stop dlm
+systemctl stop corosync
+killall lvmlockd
diff --git a/test/shell/process-each-lv.sh b/test/shell/process-each-lv.sh
index 78eb14e..52c97d4 100644
--- a/test/shell/process-each-lv.sh
+++ b/test/shell/process-each-lv.sh
@@ -16,8 +16,6 @@ export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux prepare_devs 10
 
 #
@@ -43,11 +41,11 @@ aux prepare_devs 10
 
 prepare_vgs_() {
 	# set up vgs/lvs that we will remove
-	vgcreate $vg1 "$dev1" "$dev2"
-	vgcreate $vg2 "$dev3" "$dev4"
-	vgcreate $vg3 "$dev5" "$dev6"
-	vgcreate $vg4 "$dev7" "$dev8"
-	vgcreate $vg5 "$dev9" "$dev10"
+	vgcreate $SHARED $vg1 "$dev1" "$dev2"
+	vgcreate $SHARED $vg2 "$dev3" "$dev4"
+	vgcreate $SHARED $vg3 "$dev5" "$dev6"
+	vgcreate $SHARED $vg4 "$dev7" "$dev8"
+	vgcreate $SHARED $vg5 "$dev9" "$dev10"
 	lvcreate -Zn -an -l 2 -n $lv1 $vg1
 	lvcreate -Zn -an -l 2 -n $lv1 $vg2
 	lvcreate -Zn -an -l 2 -n $lv2 $vg2
@@ -656,3 +654,5 @@ not grep $vg5-$lv2 err
 not grep $vg5-$lv3 err
 not grep $vg5-$lv4 err
 not grep $vg5-$lv5 err
+
+vgremove -f $vg1 $vg2 $vg3 $vg4 $vg5
diff --git a/test/shell/process-each-pv.sh b/test/shell/process-each-pv.sh
index f4b8fd1..426c3f1 100644
--- a/test/shell/process-each-pv.sh
+++ b/test/shell/process-each-pv.sh
@@ -13,8 +13,6 @@ test_description='Exercise toollib process_each_pv'
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux prepare_devs 14
 
 #
@@ -22,10 +20,9 @@ aux prepare_devs 14
 # pvdisplay
 # pvresize
 # pvs
-# vgreduce
 #
-# process-each-pvresize.sh covers pvresize,
-# the others are covered here.
+# process-each-pvresize.sh covers pvresize.
+# process-each-vgreduce.sh covers vgreduce.
 #
 
 
@@ -36,9 +33,9 @@ aux prepare_devs 14
 # dev1 matchines dev10,dev11,etc
 #
 
-vgcreate $vg1 "$dev10"
-vgcreate $vg2 "$dev2" "$dev3" "$dev4" "$dev5"
-vgcreate $vg3 "$dev6" "$dev7" "$dev8" "$dev9"
+vgcreate $SHARED $vg1 "$dev10"
+vgcreate $SHARED $vg2 "$dev2" "$dev3" "$dev4" "$dev5"
+vgcreate $SHARED $vg3 "$dev6" "$dev7" "$dev8" "$dev9"
 
 pvchange --addtag V2D3 "$dev3"
 pvchange --addtag V2D4 "$dev4"
@@ -714,173 +711,6 @@ not grep "$dev14" err
 
 
 #
-# test vgreduce
-#
-
-# fail without dev
-not vgreduce $vg2
-
-
-# fail with dev and -a
-not vgreduce $vg2 "$dev2" -a
-check pv_field "$dev2" vg_name $vg2
-check pv_field "$dev3" vg_name $vg2
-check pv_field "$dev4" vg_name $vg2
-check pv_field "$dev5" vg_name $vg2
-check pv_field "$dev6" vg_name $vg3
-check pv_field "$dev7" vg_name $vg3
-check pv_field "$dev8" vg_name $vg3
-check pv_field "$dev9" vg_name $vg3
-
-
-# remove one pv
-vgreduce $vg2 "$dev2"
-not check pv_field "$dev2" vg_name $vg2
-check pv_field "$dev3" vg_name $vg2
-check pv_field "$dev4" vg_name $vg2
-check pv_field "$dev5" vg_name $vg2
-check pv_field "$dev6" vg_name $vg3
-check pv_field "$dev7" vg_name $vg3
-check pv_field "$dev8" vg_name $vg3
-check pv_field "$dev9" vg_name $vg3
-# reset
-vgextend $vg2 "$dev2"
-
-
-# remove two pvs
-vgreduce $vg2 "$dev2" "$dev3"
-not check pv_field "$dev2" vg_name $vg2
-not check pv_field "$dev3" vg_name $vg2
-check pv_field "$dev4" vg_name $vg2
-check pv_field "$dev5" vg_name $vg2
-check pv_field "$dev6" vg_name $vg3
-check pv_field "$dev7" vg_name $vg3
-check pv_field "$dev8" vg_name $vg3
-check pv_field "$dev9" vg_name $vg3
-# reset
-vgextend $vg2 "$dev2" "$dev3"
-pvchange --addtag V2D3 "$dev3"
-
-
-# remove one pv with tag
-vgreduce $vg2 @V2D3
-check pv_field "$dev2" vg_name $vg2
-not check pv_field "$dev3" vg_name $vg2
-check pv_field "$dev4" vg_name $vg2
-check pv_field "$dev5" vg_name $vg2
-check pv_field "$dev6" vg_name $vg3
-check pv_field "$dev7" vg_name $vg3
-check pv_field "$dev8" vg_name $vg3
-check pv_field "$dev9" vg_name $vg3
-# reset
-vgextend $vg2 "$dev3"
-pvchange --addtag V2D3 "$dev3"
-
-
-# remove two pvs, each with different tag
-vgreduce $vg2 @V2D3 @V2D4
-check pv_field "$dev2" vg_name $vg2
-not check pv_field "$dev3" vg_name $vg2
-not check pv_field "$dev4" vg_name $vg2
-check pv_field "$dev5" vg_name $vg2
-check pv_field "$dev6" vg_name $vg3
-check pv_field "$dev7" vg_name $vg3
-check pv_field "$dev8" vg_name $vg3
-check pv_field "$dev9" vg_name $vg3
-# reset
-vgextend $vg2 "$dev3" "$dev4"
-pvchange --addtag V2D3 "$dev3"
-pvchange --addtag V2D4 "$dev4"
-pvchange --addtag V2D45 "$dev4"
-
-
-# remove two pvs, both with same tag
-vgreduce $vg2 @V2D45
-check pv_field "$dev2" vg_name $vg2
-check pv_field "$dev3" vg_name $vg2
-not check pv_field "$dev4" vg_name $vg2
-not check pv_field "$dev5" vg_name $vg2
-check pv_field "$dev6" vg_name $vg3
-check pv_field "$dev7" vg_name $vg3
-check pv_field "$dev8" vg_name $vg3
-check pv_field "$dev9" vg_name $vg3
-# reset
-vgextend $vg2 "$dev4" "$dev5"
-pvchange --addtag V2D4 "$dev4"
-pvchange --addtag V2D45 "$dev4"
-pvchange --addtag V2D5 "$dev5"
-pvchange --addtag V2D45 "$dev5"
-
-
-# remove two pvs, one by name, one by tag
-vgreduce $vg2 "$dev2" @V2D3
-not check pv_field "$dev2" vg_name $vg2
-not check pv_field "$dev3" vg_name $vg2
-check pv_field "$dev4" vg_name $vg2
-check pv_field "$dev5" vg_name $vg2
-check pv_field "$dev6" vg_name $vg3
-check pv_field "$dev7" vg_name $vg3
-check pv_field "$dev8" vg_name $vg3
-check pv_field "$dev9" vg_name $vg3
-# reset
-vgextend $vg2 "$dev2" "$dev3"
-pvchange --addtag V2D3 "$dev3"
-
-
-# remove one pv by tag, where another vg has a pv with same tag
-pvchange --addtag V2D5V3D9 "$dev5"
-pvchange --addtag V2D5V3D9 "$dev9"
-vgreduce $vg2 @V2D5V3D9
-check pv_field "$dev2" vg_name $vg2
-check pv_field "$dev3" vg_name $vg2
-check pv_field "$dev4" vg_name $vg2
-not check pv_field "$dev5" vg_name $vg2
-check pv_field "$dev6" vg_name $vg3
-check pv_field "$dev7" vg_name $vg3
-check pv_field "$dev8" vg_name $vg3
-check pv_field "$dev9" vg_name $vg3
-# reset
-vgextend $vg2 "$dev5"
-pvchange --addtag V2D5 "$dev5"
-pvchange --addtag V2D45 "$dev5"
-
-
-# fail to remove last pv (don't know which will be last)
-not vgreduce -a $vg2
-# reset
-vgremove $vg2
-vgcreate $vg2 "$dev2" "$dev3" "$dev4" "$dev5"
-pvchange --addtag V2D3 "$dev3"
-pvchange --addtag V2D4 "$dev4"
-pvchange --addtag V2D45 "$dev4"
-pvchange --addtag V2D5 "$dev5"
-pvchange --addtag V2D45 "$dev5"
-
-
-# lvcreate on one pv to make it used
-# remove all unused pvs
-lvcreate -n $lv1 -l 2 $vg2 "$dev2"
-not vgreduce -a $vg2
-check pv_field "$dev2" vg_name $vg2
-not check pv_field "$dev3" vg_name $vg2
-not check pv_field "$dev4" vg_name $vg2
-not check pv_field "$dev5" vg_name $vg2
-check pv_field "$dev6" vg_name $vg3
-check pv_field "$dev7" vg_name $vg3
-check pv_field "$dev8" vg_name $vg3
-check pv_field "$dev9" vg_name $vg3
-# reset
-vgextend $vg2 "$dev3" "$dev4" "$dev5"
-pvchange --addtag V2D3 "$dev3"
-pvchange --addtag V2D4 "$dev4"
-pvchange --addtag V2D45 "$dev4"
-pvchange --addtag V2D5 "$dev5"
-pvchange --addtag V2D45 "$dev5"
-lvchange -an $vg2/$lv1
-lvremove $vg2/$lv1
-
-
-#
 # tests including pvs without mdas
 #
 
@@ -917,9 +747,9 @@ pvcreate "$dev14" --metadatacopies 0
 # dev12
 # dev13
 
-vgcreate $vg1 "$dev10"
-vgcreate $vg2 "$dev2" "$dev3" "$dev4" "$dev5"
-vgcreate $vg3 "$dev6" "$dev7" "$dev8" "$dev9"
+vgcreate $SHARED $vg1 "$dev10"
+vgcreate $SHARED $vg2 "$dev2" "$dev3" "$dev4" "$dev5"
+vgcreate $SHARED $vg3 "$dev6" "$dev7" "$dev8" "$dev9"
 
 pvchange --addtag V2D3 "$dev3"
 pvchange --addtag V2D4 "$dev4"
@@ -1228,58 +1058,4 @@ grep "$dev12" err
 grep "$dev13" err
 grep "$dev14" err
 
-
-#
-# vgreduce including pvs without mdas
-#
-
-# remove pv without mda
-vgreduce $vg2 "$dev2"
-not check pv_field "$dev2" vg_name $vg2
-check pv_field "$dev3" vg_name $vg2
-check pv_field "$dev4" vg_name $vg2
-check pv_field "$dev5" vg_name $vg2
-check pv_field "$dev6" vg_name $vg3
-check pv_field "$dev7" vg_name $vg3
-check pv_field "$dev8" vg_name $vg3
-check pv_field "$dev9" vg_name $vg3
-# reset
-vgextend $vg2 "$dev2"
-
-# remove pv with mda and pv without mda
-vgreduce $vg2 "$dev2" "$dev3"
-not check pv_field "$dev2" vg_name $vg2
-not check pv_field "$dev3" vg_name $vg2
-check pv_field "$dev4" vg_name $vg2
-check pv_field "$dev5" vg_name $vg2
-check pv_field "$dev6" vg_name $vg3
-check pv_field "$dev7" vg_name $vg3
-check pv_field "$dev8" vg_name $vg3
-check pv_field "$dev9" vg_name $vg3
-# reset
-vgextend $vg2 "$dev2"
-vgextend $vg2 "$dev3"
-
-# fail to remove only pv with mda
-not vgreduce $vg3 "$dev9"
-check pv_field "$dev6" vg_name $vg3
-check pv_field "$dev7" vg_name $vg3
-check pv_field "$dev8" vg_name $vg3
-check pv_field "$dev9" vg_name $vg3
-check pv_field "$dev2" vg_name $vg2
-check pv_field "$dev3" vg_name $vg2
-check pv_field "$dev4" vg_name $vg2
-check pv_field "$dev5" vg_name $vg2
-
-# remove by tag a pv without mda
-vgreduce $vg3 @V3D8
-check pv_field "$dev6" vg_name $vg3
-check pv_field "$dev7" vg_name $vg3
-not check pv_field "$dev8" vg_name $vg3
-check pv_field "$dev9" vg_name $vg3
-check pv_field "$dev2" vg_name $vg2
-check pv_field "$dev3" vg_name $vg2
-check pv_field "$dev4" vg_name $vg2
-check pv_field "$dev5" vg_name $vg2
-# reset
-vgextend $vg3 "$dev8"
+vgremove $vg1 $vg2 $vg3
diff --git a/test/shell/process-each-vg.sh b/test/shell/process-each-vg.sh
index f93acda..49bc4f9 100644
--- a/test/shell/process-each-vg.sh
+++ b/test/shell/process-each-vg.sh
@@ -13,8 +13,6 @@ test_description='Exercise toollib process_each_vg'
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 aux prepare_devs 6
 
 #
@@ -28,16 +26,16 @@ aux prepare_devs 6
 #
 # set up four vgs that we will remove
 #
-vgcreate $vg1 "$dev1"
-vgcreate $vg2 "$dev2"
-vgcreate $vg3 "$dev3"
-vgcreate $vg4 "$dev4"
+vgcreate $SHARED $vg1 "$dev1"
+vgcreate $SHARED $vg2 "$dev2"
+vgcreate $SHARED $vg3 "$dev3"
+vgcreate $SHARED $vg4 "$dev4"
 
 # these two vgs will not be removed
-vgcreate $vg5 "$dev5"
+vgcreate $SHARED $vg5 "$dev5"
 vgchange --addtag tagvg5 $vg5
 lvcreate -l 4 -n $lv1 $vg5
-vgcreate $vg6 "$dev6"
+vgcreate $SHARED $vg6 "$dev6"
 lvcreate -l 4 -n $lv2 $vg6
 
 # should fail without any arg
@@ -67,10 +65,10 @@ not vgs $vg4
 #
 # set up four vgs that we will remove
 #
-vgcreate --addtag tagfoo $vg1 "$dev1"
-vgcreate --addtag tagfoo $vg2 "$dev2"
-vgcreate --addtag tagfoo2 $vg3 "$dev3"
-vgcreate --addtag tagbar $vg4 "$dev4"
+vgcreate $SHARED --addtag tagfoo $vg1 "$dev1"
+vgcreate $SHARED --addtag tagfoo $vg2 "$dev2"
+vgcreate $SHARED --addtag tagfoo2 $vg3 "$dev3"
+vgcreate $SHARED --addtag tagbar $vg4 "$dev4"
 vgchange --addtag foo $vg4
 
 # should do nothing and fail
@@ -95,10 +93,10 @@ not vgs $vg4
 #
 # set up four vgs that we will remove
 #
-vgcreate --addtag tagfoo $vg1 "$dev1"
-vgcreate --addtag tagfoo $vg2 "$dev2"
-vgcreate --addtag tagfoo2 $vg3 "$dev3"
-vgcreate --addtag tagbar $vg4 "$dev4"
+vgcreate $SHARED --addtag tagfoo $vg1 "$dev1"
+vgcreate $SHARED --addtag tagfoo $vg2 "$dev2"
+vgcreate $SHARED --addtag tagfoo2 $vg3 "$dev3"
+vgcreate $SHARED --addtag tagbar $vg4 "$dev4"
 vgchange --addtag foo $vg4
 
 vgremove @tagfoo
@@ -113,10 +111,10 @@ not vgs $vg4
 #
 # set up four vgs that we will remove
 #
-vgcreate --addtag tagfoo $vg1 "$dev1"
-vgcreate --addtag tagfoo $vg2 "$dev2"
-vgcreate --addtag tagfoo2 $vg3 "$dev3"
-vgcreate --addtag tagbar $vg4 "$dev4"
+vgcreate $SHARED --addtag tagfoo $vg1 "$dev1"
+vgcreate $SHARED --addtag tagfoo $vg2 "$dev2"
+vgcreate $SHARED --addtag tagfoo2 $vg3 "$dev3"
+vgcreate $SHARED --addtag tagbar $vg4 "$dev4"
 vgchange --addtag foo $vg4
 
 vgremove $vg1 @tagfoo2
@@ -131,10 +129,10 @@ not vgs $vg4
 #
 # set up four vgs that we will remove
 #
-vgcreate --addtag tagfoo $vg1 "$dev1"
-vgcreate --addtag tagfoo $vg2 "$dev2"
-vgcreate --addtag tagfoo2 $vg3 "$dev3"
-vgcreate --addtag tagbar $vg4 "$dev4"
+vgcreate $SHARED --addtag tagfoo $vg1 "$dev1"
+vgcreate $SHARED --addtag tagfoo $vg2 "$dev2"
+vgcreate $SHARED --addtag tagfoo2 $vg3 "$dev3"
+vgcreate $SHARED --addtag tagbar $vg4 "$dev4"
 vgchange --addtag foo $vg4
 
 vgremove @foo @tagfoo2 $vg1 $vg2
@@ -147,10 +145,10 @@ not vgs $vg4
 #
 # set up four vgs that we will remove
 #
-vgcreate --addtag tagfoo $vg1 "$dev1"
-vgcreate --addtag tagfoo $vg2 "$dev2"
-vgcreate --addtag tagfoo2 $vg3 "$dev3"
-vgcreate --addtag tagbar $vg4 "$dev4"
+vgcreate $SHARED --addtag tagfoo $vg1 "$dev1"
+vgcreate $SHARED --addtag tagfoo $vg2 "$dev2"
+vgcreate $SHARED --addtag tagfoo2 $vg3 "$dev3"
+vgcreate $SHARED --addtag tagbar $vg4 "$dev4"
 vgchange --addtag foo $vg4
 
 vgremove @tagfoo $vg1 @tagfoo @tagfoo2 $vg3 @tagbar
@@ -163,10 +161,10 @@ not vgs $vg4
 #
 # set up four vgs that we will remove
 #
-vgcreate --addtag tagfoo $vg1 "$dev1"
-vgcreate --addtag tagfoo $vg2 "$dev2"
-vgcreate --addtag tagfoo2 $vg3 "$dev3"
-vgcreate --addtag tagbar $vg4 "$dev4"
+vgcreate $SHARED --addtag tagfoo $vg1 "$dev1"
+vgcreate $SHARED --addtag tagfoo $vg2 "$dev2"
+vgcreate $SHARED --addtag tagfoo2 $vg3 "$dev3"
+vgcreate $SHARED --addtag tagbar $vg4 "$dev4"
 vgchange --addtag foo $vg4
 
 not vgremove garbage $vg1
@@ -198,10 +196,10 @@ not vgs $vg6
 #
 # set up four vgs that we will report
 #
-vgcreate --addtag tagfoo $vg1 "$dev1"
-vgcreate --addtag tagfoo $vg2 "$dev2"
-vgcreate --addtag tagfoo2 $vg3 "$dev3"
-vgcreate --addtag tagbar $vg4 "$dev4"
+vgcreate $SHARED --addtag tagfoo $vg1 "$dev1"
+vgcreate $SHARED --addtag tagfoo $vg2 "$dev2"
+vgcreate $SHARED --addtag tagfoo2 $vg3 "$dev3"
+vgcreate $SHARED --addtag tagbar $vg4 "$dev4"
 vgchange --addtag foo $vg4
 
 vgs >err
@@ -264,3 +262,5 @@ not grep $vg1 err
 not grep $vg2 err
 not grep $vg3 err
 
+vgremove -f $vg1 $vg2 $vg3 $vg4
+
diff --git a/test/shell/process-each-vgreduce.sh b/test/shell/process-each-vgreduce.sh
new file mode 100644
index 0000000..9c8c637
--- /dev/null
+++ b/test/shell/process-each-vgreduce.sh
@@ -0,0 +1,327 @@
+#!/bin/sh
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Exercise toollib process_each_pv with vgreduce'
+
+. lib/inittest
+
+aux prepare_devs 14
+
+#
+# set up
+#
+# FIXME: some of the setup may not be used by the tests
+# since this was split out from process-each-pv, where
+# some of the setup was used by other tests that only
+# remain in process-each-pv.
+#
+# use use dev10 instead of dev1 because simple grep for
+# dev1 matchines dev10,dev11,etc
+#
+
+vgcreate $vg1 "$dev10"
+vgcreate $vg2 "$dev2" "$dev3" "$dev4" "$dev5"
+vgcreate $vg3 "$dev6" "$dev7" "$dev8" "$dev9"
+
+pvchange --addtag V2D3 "$dev3"
+pvchange --addtag V2D4 "$dev4"
+pvchange --addtag V2D45 "$dev4"
+pvchange --addtag V2D5 "$dev5"
+pvchange --addtag V2D45 "$dev5"
+
+pvchange --addtag V3 "$dev6" "$dev7" "$dev8" "$dev9"
+pvchange --addtag V3D9 "$dev9"
+
+# orphan
+pvcreate "$dev11"
+
+# dev (a non-pv device)
+pvcreate "$dev12"
+pvremove "$dev12"
+
+# dev13 is intentionally untouched so we can
+# test that it is handled appropriately as a non-pv
+
+# orphan
+pvcreate "$dev14"
+
+
+# fail without dev
+not vgreduce $vg2
+
+
+# fail with dev and -a
+not vgreduce $vg2 "$dev2" -a
+check pv_field "$dev2" vg_name $vg2
+check pv_field "$dev3" vg_name $vg2
+check pv_field "$dev4" vg_name $vg2
+check pv_field "$dev5" vg_name $vg2
+check pv_field "$dev6" vg_name $vg3
+check pv_field "$dev7" vg_name $vg3
+check pv_field "$dev8" vg_name $vg3
+check pv_field "$dev9" vg_name $vg3
+
+
+# remove one pv
+vgreduce $vg2 "$dev2"
+not check pv_field "$dev2" vg_name $vg2
+check pv_field "$dev3" vg_name $vg2
+check pv_field "$dev4" vg_name $vg2
+check pv_field "$dev5" vg_name $vg2
+check pv_field "$dev6" vg_name $vg3
+check pv_field "$dev7" vg_name $vg3
+check pv_field "$dev8" vg_name $vg3
+check pv_field "$dev9" vg_name $vg3
+# reset
+vgextend $vg2 "$dev2"
+
+
+# remove two pvs
+vgreduce $vg2 "$dev2" "$dev3"
+not check pv_field "$dev2" vg_name $vg2
+not check pv_field "$dev3" vg_name $vg2
+check pv_field "$dev4" vg_name $vg2
+check pv_field "$dev5" vg_name $vg2
+check pv_field "$dev6" vg_name $vg3
+check pv_field "$dev7" vg_name $vg3
+check pv_field "$dev8" vg_name $vg3
+check pv_field "$dev9" vg_name $vg3
+# reset
+vgextend $vg2 "$dev2" "$dev3"
+pvchange --addtag V2D3 "$dev3"
+
+
+# remove one pv with tag
+vgreduce $vg2 @V2D3
+check pv_field "$dev2" vg_name $vg2
+not check pv_field "$dev3" vg_name $vg2
+check pv_field "$dev4" vg_name $vg2
+check pv_field "$dev5" vg_name $vg2
+check pv_field "$dev6" vg_name $vg3
+check pv_field "$dev7" vg_name $vg3
+check pv_field "$dev8" vg_name $vg3
+check pv_field "$dev9" vg_name $vg3
+# reset
+vgextend $vg2 "$dev3"
+pvchange --addtag V2D3 "$dev3"
+
+
+# remove two pvs, each with different tag
+vgreduce $vg2 @V2D3 @V2D4
+check pv_field "$dev2" vg_name $vg2
+not check pv_field "$dev3" vg_name $vg2
+not check pv_field "$dev4" vg_name $vg2
+check pv_field "$dev5" vg_name $vg2
+check pv_field "$dev6" vg_name $vg3
+check pv_field "$dev7" vg_name $vg3
+check pv_field "$dev8" vg_name $vg3
+check pv_field "$dev9" vg_name $vg3
+# reset
+vgextend $vg2 "$dev3" "$dev4"
+pvchange --addtag V2D3 "$dev3"
+pvchange --addtag V2D4 "$dev4"
+pvchange --addtag V2D45 "$dev4"
+
+
+# remove two pvs, both with same tag
+vgreduce $vg2 @V2D45
+check pv_field "$dev2" vg_name $vg2
+check pv_field "$dev3" vg_name $vg2
+not check pv_field "$dev4" vg_name $vg2
+not check pv_field "$dev5" vg_name $vg2
+check pv_field "$dev6" vg_name $vg3
+check pv_field "$dev7" vg_name $vg3
+check pv_field "$dev8" vg_name $vg3
+check pv_field "$dev9" vg_name $vg3
+# reset
+vgextend $vg2 "$dev4" "$dev5"
+pvchange --addtag V2D4 "$dev4"
+pvchange --addtag V2D45 "$dev4"
+pvchange --addtag V2D5 "$dev5"
+pvchange --addtag V2D45 "$dev5"
+
+
+# remove two pvs, one by name, one by tag
+vgreduce $vg2 "$dev2" @V2D3
+not check pv_field "$dev2" vg_name $vg2
+not check pv_field "$dev3" vg_name $vg2
+check pv_field "$dev4" vg_name $vg2
+check pv_field "$dev5" vg_name $vg2
+check pv_field "$dev6" vg_name $vg3
+check pv_field "$dev7" vg_name $vg3
+check pv_field "$dev8" vg_name $vg3
+check pv_field "$dev9" vg_name $vg3
+# reset
+vgextend $vg2 "$dev2" "$dev3"
+pvchange --addtag V2D3 "$dev3"
+
+
+# remove one pv by tag, where another vg has a pv with same tag
+pvchange --addtag V2D5V3D9 "$dev5"
+pvchange --addtag V2D5V3D9 "$dev9"
+vgreduce $vg2 @V2D5V3D9
+check pv_field "$dev2" vg_name $vg2
+check pv_field "$dev3" vg_name $vg2
+check pv_field "$dev4" vg_name $vg2
+not check pv_field "$dev5" vg_name $vg2
+check pv_field "$dev6" vg_name $vg3
+check pv_field "$dev7" vg_name $vg3
+check pv_field "$dev8" vg_name $vg3
+check pv_field "$dev9" vg_name $vg3
+# reset
+vgextend $vg2 "$dev5"
+pvchange --addtag V2D5 "$dev5"
+pvchange --addtag V2D45 "$dev5"
+
+
+# fail to remove last pv (don't know which will be last)
+not vgreduce -a $vg2
+# reset
+vgremove $vg2
+vgcreate $vg2 "$dev2" "$dev3" "$dev4" "$dev5"
+pvchange --addtag V2D3 "$dev3"
+pvchange --addtag V2D4 "$dev4"
+pvchange --addtag V2D45 "$dev4"
+pvchange --addtag V2D5 "$dev5"
+pvchange --addtag V2D45 "$dev5"
+
+
+# lvcreate on one pv to make it used
+# remove all unused pvs
+lvcreate -n $lv1 -l 2 $vg2 "$dev2"
+not vgreduce -a $vg2
+check pv_field "$dev2" vg_name $vg2
+not check pv_field "$dev3" vg_name $vg2
+not check pv_field "$dev4" vg_name $vg2
+not check pv_field "$dev5" vg_name $vg2
+check pv_field "$dev6" vg_name $vg3
+check pv_field "$dev7" vg_name $vg3
+check pv_field "$dev8" vg_name $vg3
+check pv_field "$dev9" vg_name $vg3
+# reset
+vgextend $vg2 "$dev3" "$dev4" "$dev5"
+pvchange --addtag V2D3 "$dev3"
+pvchange --addtag V2D4 "$dev4"
+pvchange --addtag V2D45 "$dev4"
+pvchange --addtag V2D5 "$dev5"
+pvchange --addtag V2D45 "$dev5"
+lvchange -an $vg2/$lv1
+lvremove $vg2/$lv1
+
+
+#
+# tests including pvs without mdas
+#
+
+# remove old config
+vgremove $vg1
+vgremove $vg2
+vgremove $vg3
+pvremove "$dev11"
+pvremove "$dev14"
+
+# new config with some pvs that have zero mdas
+
+# for vg1
+pvcreate "$dev10"
+
+# for vg2
+pvcreate "$dev2" --metadatacopies 0
+pvcreate "$dev3"
+pvcreate "$dev4"
+pvcreate "$dev5"
+
+# for vg3
+pvcreate "$dev6" --metadatacopies 0
+pvcreate "$dev7" --metadatacopies 0
+pvcreate "$dev8" --metadatacopies 0
+pvcreate "$dev9"
+
+# orphan with mda
+pvcreate "$dev11"
+# orphan without mda
+pvcreate "$dev14" --metadatacopies 0
+
+# non-pv devs
+# dev12
+# dev13
+
+vgcreate $vg1 "$dev10"
+vgcreate $vg2 "$dev2" "$dev3" "$dev4" "$dev5"
+vgcreate $vg3 "$dev6" "$dev7" "$dev8" "$dev9"
+
+pvchange --addtag V2D3 "$dev3"
+pvchange --addtag V2D4 "$dev4"
+pvchange --addtag V2D45 "$dev4"
+pvchange --addtag V2D5 "$dev5"
+pvchange --addtag V2D45 "$dev5"
+
+pvchange --addtag V3 "$dev6" "$dev7" "$dev8" "$dev9"
+pvchange --addtag V3D8 "$dev8"
+pvchange --addtag V3D9 "$dev9"
+
+
+#
+# vgreduce including pvs without mdas
+#
+
+# remove pv without mda
+vgreduce $vg2 "$dev2"
+not check pv_field "$dev2" vg_name $vg2
+check pv_field "$dev3" vg_name $vg2
+check pv_field "$dev4" vg_name $vg2
+check pv_field "$dev5" vg_name $vg2
+check pv_field "$dev6" vg_name $vg3
+check pv_field "$dev7" vg_name $vg3
+check pv_field "$dev8" vg_name $vg3
+check pv_field "$dev9" vg_name $vg3
+# reset
+vgextend $vg2 "$dev2"
+
+# remove pv with mda and pv without mda
+vgreduce $vg2 "$dev2" "$dev3"
+not check pv_field "$dev2" vg_name $vg2
+not check pv_field "$dev3" vg_name $vg2
+check pv_field "$dev4" vg_name $vg2
+check pv_field "$dev5" vg_name $vg2
+check pv_field "$dev6" vg_name $vg3
+check pv_field "$dev7" vg_name $vg3
+check pv_field "$dev8" vg_name $vg3
+check pv_field "$dev9" vg_name $vg3
+# reset
+vgextend $vg2 "$dev2"
+vgextend $vg2 "$dev3"
+
+# fail to remove only pv with mda
+not vgreduce $vg3 "$dev9"
+check pv_field "$dev6" vg_name $vg3
+check pv_field "$dev7" vg_name $vg3
+check pv_field "$dev8" vg_name $vg3
+check pv_field "$dev9" vg_name $vg3
+check pv_field "$dev2" vg_name $vg2
+check pv_field "$dev3" vg_name $vg2
+check pv_field "$dev4" vg_name $vg2
+check pv_field "$dev5" vg_name $vg2
+
+# remove by tag a pv without mda
+vgreduce $vg3 @V3D8
+check pv_field "$dev6" vg_name $vg3
+check pv_field "$dev7" vg_name $vg3
+not check pv_field "$dev8" vg_name $vg3
+check pv_field "$dev9" vg_name $vg3
+check pv_field "$dev2" vg_name $vg2
+check pv_field "$dev3" vg_name $vg2
+check pv_field "$dev4" vg_name $vg2
+check pv_field "$dev5" vg_name $vg2
+# reset
+vgextend $vg3 "$dev8"
+
+vgremove $vg1 $vg2 $vg3
diff --git a/test/shell/sanlock-hello-world.sh b/test/shell/sanlock-hello-world.sh
new file mode 100644
index 0000000..23cdc34
--- /dev/null
+++ b/test/shell/sanlock-hello-world.sh
@@ -0,0 +1,27 @@
+#!/bin/sh
+# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Hello world for vgcreate with lvmlockd and sanlock'
+
+. lib/inittest
+
+[ -z "$LVM_TEST_LOCK_TYPE_SANLOCK" ] && skip;
+
+aux prepare_pvs 1
+
+vgcreate $SHARED $vg "$dev1"
+
+vgs -o+locktype,lockargs $vg
+
+check vg_field $vg vg_locktype sanlock
+
+vgremove $vg
+
diff --git a/test/shell/sanlock-prepare.sh b/test/shell/sanlock-prepare.sh
new file mode 100644
index 0000000..289a481
--- /dev/null
+++ b/test/shell/sanlock-prepare.sh
@@ -0,0 +1,86 @@
+#!/bin/sh
+# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Set up things to run tests with sanlock'
+
+. lib/utils
+. lib/inittest
+
+[ -z "$LVM_TEST_LOCK_TYPE_SANLOCK" ] && skip;
+
+SANLOCK_CONF="/etc/sysconfig/sanlock"
+create_sanlock_conf() {
+	if test -a $SANLOCK_CONF; then
+		if ! grep "created by lvm test suite" $SANLOCK_CONF; then
+			rm $SANLOCK_CONF
+		else
+			mv $SANLOCK_CONF $SANLOCK_CONF.prelvmtest
+		fi
+	fi
+
+	cp lib/test-sanlock-conf $SANLOCK_CONF
+	echo "created new $SANLOCK_CONF"
+}
+
+prepare_lvmlockd_sanlock() {
+	if pgrep lvmlockd ; then
+		echo "Cannot run while existing lvmlockd process exists"
+		exit 1
+	fi
+
+	if pgrep sanlock ; then
+		echo "Cannot run while existing sanlock process exists"
+		exit 1
+	fi
+
+	create_sanlock_conf
+
+	# FIXME: use 'systemctl start sanlock' once we can pass options
+	sanlock daemon -U sanlock -G sanlock -w 0 -e testhostname
+	sleep 1
+	if ! pgrep sanlock; then
+		echo "Failed to start sanlock"
+		exit 1
+	fi
+
+	# FIXME: use 'systemctl start lvm2-lvmlockd' once we can pass -o 2
+	lvmlockd -o 2
+	sleep 1
+	if ! pgrep lvmlockd; then
+		echo "Failed to start lvmlockd"
+		exit 1
+	fi
+}
+
+# Create a device and a VG that are both outside the scope of
+# the standard lvm test suite so that they will not be removed
+# and will remain in place while all the tests are run.
+#
+# Use this VG to hold the sanlock global lock which will be used
+# by lvmlockd during other tests.
+#
+# This script will be run before any standard tests are run.
+# After all the tests are run, another script will be run
+# to remove this VG and device.
+
+GL_DEV="/dev/mapper/GL_DEV"
+GL_FILE="$PWD/gl_file.img"
+rm -f "$GL_FILE"
+dd if=/dev/zero of="$GL_FILE" bs=$((1024*1024)) count=1024 2> /dev/null
+GL_LOOP=$(losetup -f "$GL_FILE" --show)
+echo "0 `blockdev --getsize $GL_LOOP` linear $GL_LOOP 0" | dmsetup create GL_DEV
+
+prepare_lvmlockd_sanlock
+
+vgcreate --config 'devices { global_filter=["a|GL_DEV|", "r|.*|"] filter=["a|GL_DEV|", "r|.*|"]}' --lock-type sanlock --lock-gl enable --lock-opt wait glvg $GL_DEV
+
+vgs --config 'devices { global_filter=["a|GL_DEV|", "r|.*|"] filter=["a|GL_DEV|", "r|.*|"]}' -o+locktype,lockargs glvg
+
diff --git a/test/shell/sanlock-remove.sh b/test/shell/sanlock-remove.sh
new file mode 100644
index 0000000..47487d6
--- /dev/null
+++ b/test/shell/sanlock-remove.sh
@@ -0,0 +1,28 @@
+#!/bin/sh
+# Copyright (C) 2008-2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Remove the sanlock test setup'
+
+. lib/inittest
+
+[ -z "$LVM_TEST_LOCK_TYPE_SANLOCK" ] && skip;
+
+# Removes the VG with the global lock that was created by
+# the corresponding create script.
+
+vgremove --config 'devices { global_filter=["a|GL_DEV|", "r|.*|"] filter=["a|GL_DEV|", "r|.*|"]}' glvg
+
+
+killall lvmlockd
+killall sanlock
+
+dmsetup remove GL_DEV
+# dmsetup remove glvg-lvmlock
diff --git a/tools/args.h b/tools/args.h
index 7f7667d..c887774 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -50,6 +50,10 @@ arg(ignoremonitoring_ARG, '\0', "ignoremonitoring", NULL, 0)
 arg(ignoreskippedcluster_ARG, '\0', "ignoreskippedcluster", NULL, 0)
 arg(ignoreunsupported_ARG, '\0', "ignoreunsupported", NULL, 0)
 arg(labelsector_ARG, '\0', "labelsector", int_arg, 0)
+arg(lockopt_ARG, '\0', "lockopt", string_arg, 0)
+arg(lockstart_ARG, '\0', "lockstart", NULL, 0)
+arg(lockstop_ARG, '\0', "lockstop", NULL, 0)
+arg(locktype_ARG, '\0', "locktype", locktype_arg, 0)
 arg(maxrecoveryrate_ARG, '\0', "maxrecoveryrate", size_kb_arg, 0)
 arg(merge_ARG, '\0', "merge", NULL, 0)
 arg(mergedconfig_ARG, '\0', "mergedconfig", NULL, 0)
@@ -96,6 +100,7 @@ arg(resync_ARG, '\0', "resync", NULL, 0)
 arg(rows_ARG, '\0', "rows", NULL, 0)
 arg(segments_ARG, '\0', "segments", NULL, 0)
 arg(separator_ARG, '\0', "separator", string_arg, 0)
+arg(shared_ARG, '\0', "shared", NULL, 0)
 arg(split_ARG, '\0', "split", NULL, 0)
 arg(splitcache_ARG, '\0', "splitcache", NULL, 0)
 arg(splitmirrors_ARG, '\0', "splitmirrors", int_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 9fe4db1..43d5c80 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -394,7 +394,7 @@ xx(lvcreate,
 
 xx(lvdisplay,
    "Display information about a logical volume",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_FOREIGN_VGS,
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH,
    "lvdisplay\n"
    "\t[-a|--all]\n"
    "\t[-c|--colon]\n"
@@ -442,7 +442,7 @@ xx(lvdisplay,
     aligned_ARG, all_ARG, binary_ARG, colon_ARG, columns_ARG, foreign_ARG,
     ignorelockingfailure_ARG, ignoreskippedcluster_ARG, maps_ARG,
     noheadings_ARG, nosuffix_ARG, options_ARG, sort_ARG, partial_ARG,
-    readonly_ARG, segments_ARG, select_ARG, separator_ARG,
+    readonly_ARG, segments_ARG, select_ARG, separator_ARG, shared_ARG,
     unbuffered_ARG, units_ARG)
 
 xx(lvextend,
@@ -646,7 +646,7 @@ xx(lvresize,
 
 xx(lvs,
    "Display information about logical volumes",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_FOREIGN_VGS,
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH,
    "lvs\n"
    "\t[-a|--all]\n"
    "\t[--aligned]\n"
@@ -679,12 +679,12 @@ xx(lvs,
    aligned_ARG, all_ARG, binary_ARG, foreign_ARG, ignorelockingfailure_ARG,
    ignoreskippedcluster_ARG, nameprefixes_ARG, noheadings_ARG,
    nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG,
-   readonly_ARG, rows_ARG, segments_ARG, select_ARG, separator_ARG,
+   readonly_ARG, rows_ARG, segments_ARG, select_ARG, separator_ARG, shared_ARG,
    sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
 
 xx(lvscan,
    "List all logical volumes in all volume groups",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH,
    "lvscan\n"
    "\t[-a|--all]\n"
    "\t[-b|--blockdevice]\n"
@@ -744,7 +744,7 @@ xx(pvresize,
 
 xx(pvck,
    "Check the consistency of physical volume(s)",
-   0,
+   LOCKD_VG_SH,
    "pvck "
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
@@ -810,7 +810,7 @@ xx(pvdata,
 
 xx(pvdisplay,
    "Display various attributes of physical volume(s)",
-   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ENABLE_ALL_DEVS | ENABLE_FOREIGN_VGS,
+   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ENABLE_ALL_DEVS | LOCKD_VG_SH,
    "pvdisplay\n"
    "\t[-c|--colon]\n"
    "\t[--commandprofile ProfileName]\n"
@@ -855,7 +855,7 @@ xx(pvdisplay,
    aligned_ARG, all_ARG, binary_ARG, colon_ARG, columns_ARG, foreign_ARG,
    ignorelockingfailure_ARG, ignoreskippedcluster_ARG, maps_ARG,
    noheadings_ARG, nosuffix_ARG, options_ARG, readonly_ARG,
-   select_ARG, separator_ARG, short_ARG, sort_ARG, unbuffered_ARG,
+   select_ARG, separator_ARG, shared_ARG, short_ARG, sort_ARG, unbuffered_ARG,
    units_ARG)
 
 xx(pvmove,
@@ -919,7 +919,7 @@ xx(pvremove,
 
 xx(pvs,
    "Display information about physical volumes",
-   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_ALL_DEVS | ENABLE_FOREIGN_VGS,
+   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_ALL_DEVS | LOCKD_VG_SH,
    "pvs\n"
    "\t[-a|--all]\n"
    "\t[--aligned]\n"
@@ -952,12 +952,12 @@ xx(pvs,
    aligned_ARG, all_ARG, binary_ARG, foreign_ARG, ignorelockingfailure_ARG,
    ignoreskippedcluster_ARG, nameprefixes_ARG, noheadings_ARG, nolocking_ARG,
    nosuffix_ARG, options_ARG, partial_ARG, readonly_ARG, rows_ARG,
-   segments_ARG, select_ARG, separator_ARG, sort_ARG, trustcache_ARG,
+   segments_ARG, select_ARG, separator_ARG, shared_ARG, sort_ARG, trustcache_ARG,
    unbuffered_ARG, units_ARG, unquoted_ARG)
 
 xx(pvscan,
    "List all physical volumes",
-   PERMITTED_READ_ONLY | ENABLE_FOREIGN_VGS,
+   PERMITTED_READ_ONLY | LOCKD_VG_SH,
    "pvscan\n"
    "\t[-b|--background]\n"
    "\t[--cache [-a|--activate ay] [ DevicePath | -j|--major major --minor minor]...]\n"
@@ -994,7 +994,7 @@ xx(tags,
 
 xx(vgcfgbackup,
    "Backup volume group configuration(s)",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_FOREIGN_VGS,
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH,
    "vgcfgbackup\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
@@ -1074,11 +1074,12 @@ xx(vgchange,
    metadataprofile_ARG, monitor_ARG, noudevsync_ARG, metadatacopies_ARG,
    vgmetadatacopies_ARG, partial_ARG, physicalextentsize_ARG, poll_ARG,
    refresh_ARG, resizeable_ARG, resizable_ARG, select_ARG, sysinit_ARG,
-   systemid_ARG, test_ARG, uuid_ARG)
+   systemid_ARG, test_ARG, uuid_ARG, lockstart_ARG, lockstop_ARG, locktype_ARG, lockopt_ARG,
+   force_ARG)
 
 xx(vgck,
    "Check the consistency of volume group(s)",
-   ALL_VGS_IS_DEFAULT,
+   ALL_VGS_IS_DEFAULT | LOCKD_VG_SH,
    "vgck "
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
@@ -1138,11 +1139,11 @@ xx(vgcreate,
    physicalextentsize_ARG, test_ARG, force_ARG, zero_ARG, labelsector_ARG,
    metadatasize_ARG, pvmetadatacopies_ARG, metadatacopies_ARG,
    vgmetadatacopies_ARG, dataalignment_ARG, dataalignmentoffset_ARG,
-   systemid_ARG)
+   shared_ARG, systemid_ARG, locktype_ARG, lockopt_ARG)
 
 xx(vgdisplay,
    "Display volume group information",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_FOREIGN_VGS,
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH,
    "vgdisplay\n"
    "\t[-A|--activevolumegroups]\n"
    "\t[-c|--colon | -s|--short | -v|--verbose]\n"
@@ -1186,11 +1187,11 @@ xx(vgdisplay,
    activevolumegroups_ARG, aligned_ARG, binary_ARG, colon_ARG, columns_ARG,
    foreign_ARG, ignorelockingfailure_ARG, ignoreskippedcluster_ARG,
    noheadings_ARG, nosuffix_ARG, options_ARG, partial_ARG, readonly_ARG,
-   select_ARG, short_ARG, separator_ARG, sort_ARG, unbuffered_ARG, units_ARG)
+   select_ARG, shared_ARG, short_ARG, separator_ARG, sort_ARG, unbuffered_ARG, units_ARG)
 
 xx(vgexport,
    "Unregister volume group(s) from the system",
-   ALL_VGS_IS_DEFAULT,
+   ALL_VGS_IS_DEFAULT | LOCKD_VG_SH,
    "vgexport\n"
    "\t[-a|--all]\n"
    "\t[--commandprofile ProfileName]\n"
@@ -1330,7 +1331,7 @@ xx(vgrename,
 
 xx(vgs,
    "Display information about volume groups",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_FOREIGN_VGS,
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH,
    "vgs\n"
    "\t[--aligned]\n"
    "\t[--binary]\n"
@@ -1362,12 +1363,12 @@ xx(vgs,
    aligned_ARG, all_ARG, binary_ARG, foreign_ARG, ignorelockingfailure_ARG,
    ignoreskippedcluster_ARG, nameprefixes_ARG, noheadings_ARG,
    nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG,
-   readonly_ARG, rows_ARG, select_ARG, separator_ARG, sort_ARG,
+   readonly_ARG, rows_ARG, select_ARG, separator_ARG, shared_ARG, sort_ARG,
    trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
 
 xx(vgscan,
    "Search for all volume groups",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_FOREIGN_VGS,
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH,
    "vgscan "
    "\t[--cache]\n"
    "\t[--commandprofile ProfileName]\n"
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 1e1c0fe..2a57abb 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -606,6 +606,9 @@ static int _lvchange_persistent(struct cmd_context *cmd,
 {
 	enum activation_change activate = CHANGE_AN;
 
+	/* The LV lock in lvmlockd should remain as it is. */
+	cmd->lockd_lv_disable = 1;
+
 	if (!get_and_validate_major_minor(cmd, lv->vg->fid->fmt,
 					  &lv->major, &lv->minor))
 		return_0;
@@ -989,6 +992,22 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return ECMD_FAILED;
 	}
 
+	if (!arg_count(cmd, activate_ARG) && !arg_count(cmd, refresh_ARG)) {
+		/*
+		 * If a persistent lv lock already exists from activation
+		 * (with the needed mode or higher), this will be a no-op.
+		 * Otherwise, the lv lock will be taken as non-persistent
+		 * and released when this command exits.
+		 *
+		 * FIXME: use "sh" if the options imply that the lvchange
+		 * operation does not modify the LV.
+		 */
+		if (!lockd_lv(cmd, lv, "ex", 0)) {
+			stack;
+			return ECMD_FAILED;
+		}
+	}
+
 	/*
 	 * FIXME: DEFAULT_BACKGROUND_POLLING should be "unspecified".
 	 * If --poll is explicitly provided use it; otherwise polling
@@ -1259,9 +1278,22 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 
+	/*
+	 * Include foreign VGs that contain active LVs.
+	 * That shouldn't happen in general, but if it does by some
+	 * mistake, then we want to allow those LVs to be deactivated.
+	 */
 	if (arg_is_set(cmd, activate_ARG))
 		cmd->include_active_foreign_vgs = 1;
 
+	/*
+	 * The default vg lock mode for lvchange is ex, but these options
+	 * are cases where lvchange does not modify the vg, so they can use
+	 * the sh lock mode.
+	 */
+	if (arg_count(cmd, activate_ARG) || arg_count(cmd, refresh_ARG))
+		cmd->lockd_vg_default_sh = 1;
+
 	return process_each_lv(cmd, argc, argv,
 			       update ? READ_FOR_UPDATE : 0, NULL,
 			       &_lvchange_single);
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index fe8b761..00bab36 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -16,6 +16,7 @@
 #include "polldaemon.h"
 #include "lv_alloc.h"
 #include "lvconvert_poll.h"
+#include "lvmpolld-client.h"
 
 struct lvconvert_params {
 	int cache;
@@ -2524,6 +2525,12 @@ static int _lvconvert_thin(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (is_lockd_type(lv->vg->lock_type)) {
+		log_error("Can't use lock_type %s LV as external origin.",
+			  lv->vg->lock_type);
+		return 0;
+	}
+
 	dm_list_init(&lvc.tags);
 
 	if (!pool_supports_external_origin(first_seg(pool_lv), lv))
@@ -2641,6 +2648,12 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 	struct logical_volume *data_lv;
 	struct logical_volume *metadata_lv = NULL;
 	struct logical_volume *pool_metadata_lv;
+	char *lockd_data_args = NULL;
+	char *lockd_meta_args = NULL;
+	char *lockd_data_name = NULL;
+	char *lockd_meta_name = NULL;
+	struct id lockd_data_id;
+	struct id lockd_meta_id;
 	char metadata_name[NAME_LEN], data_name[NAME_LEN];
 	int activate_pool;
 
@@ -2657,6 +2670,13 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		}
 	}
 
+	/* An existing LV needs to have its lock freed once it becomes a data LV. */
+	if (is_lockd_type(vg->lock_type) && !lv_is_pool(pool_lv) && pool_lv->lock_args) {
+		lockd_data_args = dm_pool_strdup(cmd->mem, pool_lv->lock_args);
+		lockd_data_name = dm_pool_strdup(cmd->mem, pool_lv->name);
+		memcpy(&lockd_data_id, &pool_lv->lvid.id[1], sizeof(struct id));
+	}
+
 	if (!lv_is_visible(pool_lv)) {
 		log_error("Can't convert internal LV %s.", display_lvname(pool_lv));
 		return 0;
@@ -2712,6 +2732,13 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 		lp->pool_metadata_extents = lp->pool_metadata_lv->le_count;
 		metadata_lv = lp->pool_metadata_lv;
 
+		/* An existing LV needs to have its lock freed once it becomes a meta LV. */
+		if (is_lockd_type(vg->lock_type) && metadata_lv->lock_args) {
+			lockd_meta_args = dm_pool_strdup(cmd->mem, metadata_lv->lock_args);
+			lockd_meta_name = dm_pool_strdup(cmd->mem, metadata_lv->name);
+			memcpy(&lockd_meta_id, &metadata_lv->lvid.id[1], sizeof(struct id));
+		}
+
 		if (metadata_lv == pool_lv) {
 			log_error("Can't use same LV for pool data and metadata LV %s.",
 				  display_lvname(metadata_lv));
@@ -2974,6 +3001,27 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 	if (!attach_pool_data_lv(seg, data_lv))
 		return_0;
 
+	/*
+	 * Create a new lock for a thin pool LV.  A cache pool LV has no lock. 
+	 * Locks are removed from existing LVs that are being converted to
+	 * data and meta LVs (they are unlocked and deleted below.)
+	 */
+	if (is_lockd_type(vg->lock_type)) {
+		if (segtype_is_cache_pool(lp->segtype)) {
+			data_lv->lock_args = NULL;
+			metadata_lv->lock_args = NULL;
+		} else {
+			data_lv->lock_args = NULL;
+			metadata_lv->lock_args = NULL;
+
+			if (!strcmp(vg->lock_type, "sanlock"))
+				pool_lv->lock_args = "pending";
+			else if (!strcmp(vg->lock_type, "dlm"))
+				pool_lv->lock_args = "dlm";
+			/* The lock_args will be set in vg_write(). */
+		}
+	}
+
 	/* FIXME: revert renamed LVs in fail path? */
 	/* FIXME: any common code with metadata/thin_manip.c  extend_pool() ? */
 
@@ -3007,6 +3055,11 @@ mda_write:
 		log_warn("WARNING: Pool zeroing and large %s chunk size slows down "
 			 "provisioning.", display_size(cmd, seg->chunk_size));
 
+	if (activate_pool && !lockd_lv(cmd, pool_lv, "ex", LDLV_PERSISTENT)) {
+		log_error("Failed to lock pool LV %s/%s", vg->name, pool_lv->name);
+		goto out;
+	}
+
 	if (activate_pool &&
 	    !activate_lv_excl(cmd, pool_lv)) {
 		log_error("Failed to activate pool logical volume %s.",
@@ -3031,6 +3084,22 @@ out:
 					(segtype_is_cache_pool(lp->segtype)) ?
 					"cache" : "thin");
 
+	/*
+	 * Unlock and free the locks from existing LVs that became pool data
+	 * and meta LVs.
+	 */
+	if (lockd_data_name) {
+		if (!lockd_lv_name(cmd, vg, lockd_data_name, &lockd_data_id, lockd_data_args, "un", LDLV_PERSISTENT))
+			log_error("Failed to unlock pool data LV %s/%s", vg->name, lockd_data_name);
+		lockd_free_lv(cmd, vg, lockd_data_name, &lockd_data_id, lockd_data_args);
+	}
+
+	if (lockd_meta_name) {
+		if (!lockd_lv_name(cmd, vg, lockd_meta_name, &lockd_meta_id, lockd_meta_args, "un", LDLV_PERSISTENT))
+			log_error("Failed to unlock pool metadata LV %s/%s", vg->name, lockd_meta_name);
+		lockd_free_lv(cmd, vg, lockd_meta_name, &lockd_meta_id, lockd_meta_args);
+	}
+
 	return r;
 #if 0
 revert_new_lv:
@@ -3250,13 +3319,21 @@ static int lvconvert_single(struct cmd_context *cmd, struct lvconvert_params *lp
 	struct volume_group *vg;
 	int ret = ECMD_FAILED;
 	int saved_ignore_suspended_devices = ignore_suspended_devices();
+	uint32_t lockd_state;
 
 	if (arg_count(cmd, repair_ARG)) {
 		init_ignore_suspended_devices(1);
 		cmd->handles_missing_pvs = 1;
 	}
 
-	vg = vg_read(cmd, lp->vg_name, NULL, READ_FOR_UPDATE);
+	/*
+	 * The VG lock will be released when the command exits.
+	 * Commands that poll the LV will reacquire the VG lock.
+	 */
+	if (!lockd_vg(cmd, lp->vg_name, "ex", 0, &lockd_state))
+		goto_out;
+
+	vg = vg_read(cmd, lp->vg_name, NULL, READ_FOR_UPDATE, lockd_state);
 	if (vg_read_error(vg)) {
 		release_vg(vg);
 		goto_out;
@@ -3269,6 +3346,17 @@ static int lvconvert_single(struct cmd_context *cmd, struct lvconvert_params *lp
 	}
 
 	/*
+	 * If the lv is inactive before and after the command, the
+	 * use of PERSISTENT here means the lv will remain locked as
+	 * an effect of running the lvconvert.
+	 * To unlock it, it would need to be activated+deactivated.
+	 * Or, we could identify the commands for which the lv remains
+	 * inactive, and not use PERSISTENT here for those cases.
+	 */
+	if (!lockd_lv(cmd, lv, "ex", LDLV_PERSISTENT))
+		goto_bad;
+
+	/*
 	 * lp->pvh holds the list of PVs available for allocation or removal
 	 */
 	if (lp->pv_count) {
@@ -3288,6 +3376,12 @@ static int lvconvert_single(struct cmd_context *cmd, struct lvconvert_params *lp
 bad:
 	unlock_vg(cmd, lp->vg_name);
 
+	/*
+	 * The command may sit and monitor progress for some time,
+	 * and we do not need or want the VG lock held during that.
+	 */
+	lockd_vg(cmd, lp->vg_name, "un", 0, &lockd_state);
+
 	if (ret == ECMD_PROCESSED && lp->need_polling)
 		ret = _poll_logical_volume(cmd, lp->lv_to_poll,
 					  lp->wait_completion);
@@ -3306,6 +3400,7 @@ static int _lvconvert_merge_single(struct cmd_context *cmd, struct logical_volum
 	struct volume_group *vg_fresh;
 	struct logical_volume *lv_fresh;
 	int ret = ECMD_FAILED;
+	uint32_t lockd_state = 0; /* dummy placeholder, lvmlockd doesn't use this path */
 
 	/*
 	 * FIXME can't trust lv's VG to be current given that caller
@@ -3317,7 +3412,7 @@ static int _lvconvert_merge_single(struct cmd_context *cmd, struct logical_volum
 
 	vg_name = lv->vg->name;
 	unlock_vg(cmd, vg_name);
-	vg_fresh = vg_read(cmd, vg_name, NULL, READ_FOR_UPDATE);
+	vg_fresh = vg_read(cmd, vg_name, NULL, READ_FOR_UPDATE, lockd_state);
 	if (vg_read_error(vg_fresh)) {
 		log_error("ABORTING: Can't reread VG %s", vg_name);
 		goto out;
@@ -3356,6 +3451,26 @@ out:
 	return ret;
 }
 
+/*
+ * process_each_lv locks the VG, reads the VG, calls this which starts the
+ * conversion, then unlocks the VG.  The lvpoll command will come along later
+ * and lock the VG, read the VG, check the progress, unlock the VG, sleep and
+ * repeat until done.
+ */
+
+static int _lvconvert_lvmpolld_merge_single(struct cmd_context *cmd, struct logical_volume *lv,
+					    struct processing_handle *handle)
+{
+	struct lvconvert_params *lp = (struct lvconvert_params *) handle->custom_handle;
+	int ret;
+
+	lp->lv_to_poll = lv;
+	if ((ret = _lvconvert_single(cmd, lv, lp)) != ECMD_PROCESSED)
+		stack;
+
+	return ret;
+}
+
 int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 {
 	int ret;
@@ -3377,10 +3492,16 @@ int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 		goto_out;
 	}
 
-	if (lp.merge)
+	if (lp.merge) {
 		ret = process_each_lv(cmd, argc, argv, READ_FOR_UPDATE, handle,
-				    &_lvconvert_merge_single);
-	else
+				    lvmpolld_use() ? &_lvconvert_lvmpolld_merge_single :
+				    		     &_lvconvert_merge_single);
+
+		if (ret == ECMD_PROCESSED && lvmpolld_use() && lp.need_polling) {
+			if ((ret = _poll_logical_volume(cmd, lp.lv_to_poll, lp.wait_completion)) != ECMD_PROCESSED)
+				stack;
+		}
+	} else
 		ret = lvconvert_single(cmd, &lp);
 out:
 	destroy_processing_handle(cmd, handle);
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index e41f76c..f316767 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1453,6 +1453,7 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 	};
 	struct lvcreate_cmdline_params lcp = { 0 };
 	struct volume_group *vg;
+	uint32_t lockd_state;
 
 	if (!_lvcreate_params(cmd, argc, argv, &lp, &lcp)) {
 		stack;
@@ -1464,8 +1465,11 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
+	if (!lockd_vg(cmd, lp.vg_name, "ex", 0, &lockd_state))
+		return_ECMD_FAILED;
+
 	log_verbose("Finding volume group \"%s\"", lp.vg_name);
-	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
+	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0, lockd_state);
 	if (vg_read_error(vg)) {
 		release_vg(vg);
 		return_ECMD_FAILED;
@@ -1510,6 +1514,13 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 			    lp.pool_name ? : "with generated name", lp.vg_name, lp.segtype->name);
 	}
 
+	if (vg->lock_type && !strcmp(vg->lock_type, "sanlock")) {
+		if (!handle_sanlock_lv(cmd, vg)) {
+			log_error("No space for sanlock lock, extend the internal lvmlock LV.");
+			goto_out;
+		}
+	}
+
 	if (seg_is_thin_volume(&lp))
 		log_verbose("Making thin LV %s in pool %s in VG %s%s%s using segtype %s",
 			    lp.lv_name ? : "with generated name",
@@ -1517,6 +1528,9 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 			    lp.snapshot ? " as snapshot of " : "",
 			    lp.snapshot ? lp.origin_name : "", lp.segtype->name);
 
+	if (is_lockd_type(vg->lock_type))
+		lp.needs_lockd_init = 1;
+
 	if (!lv_create_single(vg, &lp))
 		goto_out;
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 023a3d6..7808c12 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -17,6 +17,7 @@
 #include "lvm2cmdline.h"
 #include "label.h"
 #include "lvm-version.h"
+#include "lvmlockd.h"
 
 #include "stub.h"
 #include "last-path-component.h"
@@ -625,6 +626,19 @@ int alloc_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values
 	return 1;
 }
 
+int locktype_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
+{
+	lock_type_t lock_type;
+
+	av->sign = SIGN_NONE;
+
+	lock_type = get_lock_type_from_string(av->value);
+	if (lock_type == LOCK_TYPE_INVALID)
+		return 0;
+
+	return 1;
+}
+
 int segtype_arg(struct cmd_context *cmd, struct arg_values *av)
 {
 	struct segment_type *segtype;
@@ -1045,6 +1059,9 @@ static int _get_settings(struct cmd_context *cmd)
 		cmd->current_settings.backup = 0;
 	}
 
+	if (cmd->command->flags & LOCKD_VG_SH)
+		cmd->lockd_vg_default_sh = 1;
+
 	cmd->partial_activation = 0;
 	cmd->degraded_activation = 0;
 	activation_mode = find_config_tree_str(cmd, activation_mode_CFG, NULL);
@@ -1081,9 +1098,14 @@ static int _get_settings(struct cmd_context *cmd)
 		init_ignorelockingfailure(0);
 
 	cmd->ignore_clustered_vgs = arg_is_set(cmd, ignoreskippedcluster_ARG);
-	cmd->error_foreign_vgs = cmd->command->flags & ENABLE_FOREIGN_VGS ? 0 : 1;
 	cmd->include_foreign_vgs = arg_is_set(cmd, foreign_ARG) ? 1 : 0;
-	cmd->include_active_foreign_vgs = cmd->command->flags & ENABLE_FOREIGN_VGS ? 1 : 0;
+	cmd->include_shared_vgs = arg_is_set(cmd, shared_ARG) ? 1 : 0;
+
+	/*
+	 * This is set to zero by process_each which wants to print errors
+	 * itself rather than having them printed in vg_read.
+	 */
+	cmd->vg_read_print_access_error = 1;
 		
 	if (!arg_count(cmd, sysinit_ARG))
 		lvmetad_connect_or_warn();
@@ -1407,6 +1429,31 @@ static int _prepare_profiles(struct cmd_context *cmd)
 	return 1;
 }
 
+static int _init_lvmlockd(struct cmd_context *cmd)
+{
+	const char *lvmlockd_socket;
+	int use_lvmlockd = find_config_tree_bool(cmd, global_use_lvmlockd_CFG, NULL);
+
+	if (use_lvmlockd && locking_is_clustered()) {
+		log_error("ERROR: configuration setting use_lvmlockd cannot be used with clustered locking_type 3.");
+		return 0;
+	}
+
+	lvmlockd_disconnect(); /* start over when tool context is refreshed */
+	lvmlockd_socket = getenv("LVM_LVMLOCKD_SOCKET");
+	if (!lvmlockd_socket)
+		lvmlockd_socket = DEFAULT_RUN_DIR "/lvmlockd.socket";
+
+	lvmlockd_set_socket(lvmlockd_socket);
+	lvmlockd_set_use(use_lvmlockd);
+	if (use_lvmlockd) {
+		lvmlockd_init(cmd);
+		lvmlockd_connect();
+	}
+
+	return 1;
+}
+
 int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct dm_config_tree *config_string_cft;
@@ -1534,6 +1581,11 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		goto_out;
 	}
 
+	if (!_init_lvmlockd(cmd)) {
+		ret = ECMD_FAILED;
+		goto_out;
+	}
+
 	/*
 	 * Other hosts might have changed foreign VGs so enforce a rescan
 	 * before processing any command using them.
@@ -1549,6 +1601,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	 */
 	ret = cmd->command->fn(cmd, argc, argv);
 
+	lvmlockd_disconnect();
 	fin_locking();
 
       out:
diff --git a/tools/lvrename.c b/tools/lvrename.c
index eeff76d..6bbf31b 100644
--- a/tools/lvrename.c
+++ b/tools/lvrename.c
@@ -27,6 +27,7 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 	char *st;
 	struct volume_group *vg;
 	struct lv_list *lvl;
+	uint32_t lockd_state;
 	int r = ECMD_FAILED;
 
 	if (argc == 3) {
@@ -98,8 +99,11 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
+	if (!lockd_vg(cmd, vg_name, "ex", 0, &lockd_state))
+		return_ECMD_FAILED;
+
 	log_verbose("Checking for existing volume group \"%s\"", vg_name);
-	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
+	vg = vg_read_for_update(cmd, vg_name, NULL, 0, lockd_state);
 	if (vg_read_error(vg)) {
 		release_vg(vg);
 		return_ECMD_FAILED;
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 08248bb..30ac4f9 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -169,13 +169,17 @@ int lvresize(struct cmd_context *cmd, int argc, char **argv)
 	struct volume_group *vg;
 	struct dm_list *pvh = NULL;
 	struct logical_volume *lv;
+	uint32_t lockd_state;
 	int r = ECMD_FAILED;
 
 	if (!_lvresize_params(cmd, argc, argv, &lp))
 		return EINVALID_CMD_LINE;
 
+	if (!lockd_vg(cmd, lp.vg_name, "ex", 0, &lockd_state))
+		return_ECMD_FAILED;
+
 	log_verbose("Finding volume group %s", lp.vg_name);
-	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
+	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0, lockd_state);
 	if (vg_read_error(vg)) {
 		release_vg(vg);
 		return_ECMD_FAILED;
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 2e86cb1..d7ba417 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -138,14 +138,20 @@ int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 	struct volume_group *vg;
 	struct logical_volume *lv;
 	int finished = 0;
+	uint32_t lockd_state;
 
 	/* Poll for completion */
 	while (!finished) {
 		if (parms->wait_before_testing)
 			_sleep_and_rescan_devices(parms);
 
+		if (!lockd_vg(cmd, id->vg_name, "sh", 0, &lockd_state)) {
+			log_error("ABORTING: Can't lock VG for %s.", id->display_name);
+			return 0;
+		}
+
 		/* Locks the (possibly renamed) VG again */
-		vg = vg_read(cmd, id->vg_name, NULL, READ_FOR_UPDATE);
+		vg = vg_read(cmd, id->vg_name, NULL, READ_FOR_UPDATE, lockd_state);
 		if (vg_read_error(vg)) {
 			release_vg(vg);
 			log_error("ABORTING: Can't reread VG for %s.", id->display_name);
@@ -189,6 +195,8 @@ int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 
 		unlock_and_release_vg(cmd, vg, vg->name);
 
+		lockd_vg(cmd, id->vg_name, "un", 0, &lockd_state);
+
 		/*
 		 * FIXME Sleeping after testing, while preferred, also works around
 		 * unreliable "finished" state checking in _percent_run.  If the
@@ -360,12 +368,32 @@ static int report_progress(struct cmd_context *cmd, struct poll_operation_id *id
 {
 	struct volume_group *vg;
 	struct logical_volume *lv;
+	uint32_t lockd_state;
+	int ret;
+
+	/*
+	 * FIXME: we don't really need to take the vg lock here,
+	 * because we only report the progress on the same host
+	 * where the pvmove/lvconvert is happening.  This means
+	 * that the local pvmove/lvconvert/lvpoll commands are
+	 * updating the local lvmetad with the latest info they
+	 * have, and we just need to read the latest info that
+	 * they have put into lvmetad about their progress.
+	 * No VG lock is needed to protect anything here
+	 * (we're just reading the VG), and no VG lock is
+	 * needed to force a VG read from disk to get changes
+	 * from other hosts, because the only change to the VG
+	 * we're interested in is the change done locally.
+	 */
+	if (!lockd_vg(cmd, id->vg_name, "sh", 0, &lockd_state))
+		return 0;
 
-	vg = vg_read(cmd, id->vg_name, NULL, 0);
+	vg = vg_read(cmd, id->vg_name, NULL, 0, lockd_state);
 	if (vg_read_error(vg)) {
 		release_vg(vg);
 		log_error("Can't reread VG for %s", id->display_name);
-		return 0;
+		ret = 0;
+		goto out_ret;
 	}
 
 	lv = find_lv(vg, id->lv_name);
@@ -382,23 +410,28 @@ static int report_progress(struct cmd_context *cmd, struct poll_operation_id *id
 		else
 			log_verbose("Can't find LV in %s for %s. Already finished or removed.",
 				    vg->name, id->display_name);
+		ret = 1;
 		goto out;
 	}
 
 	if (!lv_is_active_locally(lv)) {
 		log_verbose("%s: Interrupted: No longer active.", id->display_name);
+		ret = 1;
 		goto out;
 	}
 
 	if (parms->poll_fns->poll_progress(cmd, lv, id->display_name, parms) == PROGRESS_CHECK_FAILED) {
-		unlock_and_release_vg(cmd, vg, vg->name);
-		return_0;
+		ret = 0;
+		goto out;
 	}
 
+	ret = 1;
+
 out:
 	unlock_and_release_vg(cmd, vg, vg->name);
-
-	return 1;
+out_ret:
+	lockd_vg(cmd, id->vg_name, "un", 0, &lockd_state);
+	return ret;
 }
 
 static int _lvmpolld_init_poll_vg(struct cmd_context *cmd, const char *vgname,
diff --git a/tools/pvchange.c b/tools/pvchange.c
index 3e0894f..91e93c1 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -82,6 +82,14 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 		}
 	}
 
+	/*
+	 * Needed to change a property on an orphan PV.
+	 * i.e. the global lock is only needed for orphans.
+	 * Convert sh to ex.
+	 */
+	if (is_orphan(pv) && !lockd_gl(cmd, "ex", 0))
+		return_ECMD_FAILED;
+
 	if (tagargs) {
 		/* tag or deltag */
 		if (arg_count(cmd, addtag_ARG) && !change_tag(cmd, NULL, NULL, pv, addtag_ARG))
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 1398198..1f45ad9 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -96,6 +96,10 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 	int ret = ECMD_PROCESSED;
 	struct pvcreate_params pp;
 
+	/* Needed to change the set of orphan PVs. */
+	if (!lockd_gl(cmd, "ex", 0))
+		return_ECMD_FAILED;
+
 	pvcreate_params_set_defaults(&pp);
 
 	if (!pvcreate_restore_params_validate(cmd, argc, argv, &pp)) {
diff --git a/tools/pvmove.c b/tools/pvmove.c
index f4b9d6c..8efa6b0 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -17,6 +17,7 @@
 #include "polldaemon.h"
 #include "display.h"
 #include "pvmove_poll.h"
+#include "lvmpolld-client.h"
 
 #define PVMOVE_FIRST_TIME   0x00000001      /* Called for first time */
 
@@ -598,6 +599,7 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 	struct dm_list *lvs_changed;
 	struct physical_volume *pv;
 	struct logical_volume *lv_mirr;
+	uint32_t lockd_state;
 	unsigned flags = PVMOVE_FIRST_TIME;
 	unsigned exclusive;
 	int r = ECMD_FAILED;
@@ -631,10 +633,13 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 	/* Read VG */
 	log_verbose("Finding volume group \"%s\"", vg_name);
 
-	vg = vg_read(cmd, vg_name, NULL, READ_FOR_UPDATE);
+	if (!lockd_vg(cmd, vg_name, "ex", 0, &lockd_state))
+		return_ECMD_FAILED;
+
+	vg = vg_read(cmd, vg_name, NULL, READ_FOR_UPDATE, lockd_state);
 	if (vg_read_error(vg)) {
 		release_vg(vg);
-		return_ECMD_FAILED;
+		goto out_ret;
 	}
 
 	exclusive = _pvmove_is_exclusive(cmd, vg);
@@ -700,6 +705,14 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 out:
 	free_pv_fid(pv);
 	unlock_and_release_vg(cmd, vg, vg_name);
+out_ret:
+	/*
+	 * Release explicitly because the command may continue running
+	 * for some time monitoring the progress, and we don not want
+	 * or need the lockd lock held over that.
+	 */
+	lockd_vg(cmd, vg_name, "un", 0, &lockd_state);
+
 	return r;
 }
 
@@ -712,6 +725,7 @@ static int _read_poll_id_from_pvname(struct cmd_context *cmd, const char *pv_nam
 	struct logical_volume *lv;
 	struct physical_volume *pv;
 	struct volume_group *vg;
+	uint32_t lockd_state;
 
 	if (!pv_name) {
 		log_error(INTERNAL_ERROR "Invalid PV name parameter.");
@@ -723,13 +737,16 @@ static int _read_poll_id_from_pvname(struct cmd_context *cmd, const char *pv_nam
 
 	vg_name = pv_vg_name(pv);
 
+	if (!lockd_vg(cmd, vg_name, "sh", 0, &lockd_state))
+		return_0;
+
 	/* need read-only access */
-	vg = vg_read(cmd, vg_name, NULL, 0);
+	vg = vg_read(cmd, vg_name, NULL, 0, lockd_state);
 	if (vg_read_error(vg)) {
 		log_error("ABORTING: Can't read VG for %s.", pv_name);
 		release_vg(vg);
-		free_pv_fid(pv);
-		return 0;
+		ret = 0;
+		goto out;
 	}
 
 	if (!(lv = find_pvmove_lv(vg, pv_dev(pv), PVMOVE))) {
@@ -743,6 +760,8 @@ static int _read_poll_id_from_pvname(struct cmd_context *cmd, const char *pv_nam
 	}
 
 	unlock_and_release_vg(cmd, vg, vg_name);
+out:
+	lockd_vg(cmd, vg_name, "un", 0, &lockd_state);
 	free_pv_fid(pv);
 	return ret;
 }
@@ -828,6 +847,24 @@ int pvmove(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
+	if (lvmlockd_use() && !lvmpolld_use()) {
+		/*
+		 * Don't want to spend the time making lvmlockd
+		 * work without lvmpolld.
+		 */
+		log_error("Enable lvmpolld when using lvmlockd.");
+		return ECMD_FAILED;
+	}
+
+	if (lvmlockd_use() && !argc) {
+		/*
+		 * FIXME: move process_each_vg from polldaemon up to here,
+		 * then we can remove this limitation.
+		 */
+		log_error("Specify pvmove args when using lvmlockd.");
+		return ECMD_FAILED;
+	}
+
 	if (argc) {
 		if (!(lvid = dm_pool_alloc(cmd->mem, sizeof(*lvid)))) {
 			log_error("Failed to allocate lvid.");
@@ -845,6 +882,15 @@ int pvmove(struct cmd_context *cmd, int argc, char **argv)
 		if (colon)
 			*colon = '\0';
 
+		/*
+		 * To do a reverse mapping from PV name to VG name, we need the
+		 * correct global mapping of PVs to VGs.
+		 */
+		if (!lockd_gl(cmd, "sh", 0)) {
+			stack;
+			return ECMD_FAILED;
+		}
+
 		if (!arg_count(cmd, abort_ARG)) {
 			if ((ret = _set_up_pvmove(cmd, pv_name, argc, argv, lvid, &vg_name, &lv_name)) != ECMD_PROCESSED) {
 				stack;
@@ -857,6 +903,13 @@ int pvmove(struct cmd_context *cmd, int argc, char **argv)
 			if (!in_progress)
 				return ECMD_PROCESSED;
 		}
+
+		/*
+		 * The command may sit and report progress for some time,
+		 * and we do not want or need the lockd locks held during
+		 * that time.
+		 */
+		lockd_gl(cmd, "un", 0);
 	}
 
 	return pvmove_poll(cmd, pv_name, lvid ? lvid->s : NULL, vg_name, lv_name,
diff --git a/tools/pvremove.c b/tools/pvremove.c
index b40ff79..e6ae866 100644
--- a/tools/pvremove.c
+++ b/tools/pvremove.c
@@ -32,6 +32,10 @@ int pvremove(struct cmd_context *cmd, int argc, char **argv)
 
 	dm_list_init(&pv_names);
 
+	/* Needed to change the set of orphan PVs. */
+	if (!lockd_gl(cmd, "ex", 0))
+		return_ECMD_FAILED;
+
 	for (i = 0; i < argc; i++) {
 		dm_unescape_colons_and_at_signs(argv[i], NULL, NULL);
 		if (!str_list_add(cmd->mem, &pv_names, argv[i]))
diff --git a/tools/pvresize.c b/tools/pvresize.c
index 3057a7f..0b055e6 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -36,6 +36,14 @@ static int _pvresize_single(struct cmd_context *cmd,
 	}
 	params->total++;
 
+	/*
+	 * Needed to change a property on an orphan PV.
+	 * i.e. the global lock is only needed for orphans.
+	 * Convert sh to ex.
+	 */
+	if (is_orphan(pv) && !lockd_gl(cmd, "ex", 0))
+		return_ECMD_FAILED;
+
 	if (!pv_resize_single(cmd, vg, pv, params->new_size))
 		return_ECMD_FAILED;
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 51f5d2b..844aabd 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -106,7 +106,7 @@ static int _auto_activation_handler(struct cmd_context *cmd,
 		return_0;
 
 	/* NB. This is safe because we know lvmetad is running and we won't hit disk. */
-	vg = vg_read(cmd, vgname, (const char *)&vgid_raw, 0);
+	vg = vg_read(cmd, vgname, (const char *)&vgid_raw, 0, 0);
 	if (vg_read_error(vg)) {
 		log_error("Failed to read Volume Group \"%s\" (%s) during autoactivation.", vgname, vgid);
 		release_vg(vg);
@@ -322,7 +322,6 @@ out:
 	if (!sync_local_dev_names(cmd))
 		stack;
 	unlock_vg(cmd, VG_GLOBAL);
-
 	return ret;
 }
 
@@ -372,6 +371,10 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
+	/* Needed for a current listing of the global VG namespace. */
+	if (!lockd_gl(cmd, "sh", 0))
+		return_ECMD_FAILED;
+
 	if (cmd->full_filter->wipe)
 		cmd->full_filter->wipe(cmd->full_filter);
 	lvmcache_destroy(cmd, 1, 0);
diff --git a/tools/reporter.c b/tools/reporter.c
index eb6a4ed..c7a927b 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -626,6 +626,14 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	quoted = find_config_tree_bool(cmd, report_quoted_CFG, NULL);
 	columns_as_rows = find_config_tree_bool(cmd, report_colums_as_rows_CFG, NULL);
 
+	/*
+	 * Include foreign VGs that contain active LVs.
+	 * That shouldn't happen in general, but if it does by some
+	 * mistake, then we want to display those VGs and allow the
+	 * LVs to be deactivated.
+	 */
+	cmd->include_active_foreign_vgs = 1;
+
 	/* Check PV specifics and do extra changes/actions if needed. */
 	_check_pv_list(cmd, argc, argv, &report_type, &args_are_pvs);
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 5032e2c..6b8ce22 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -217,6 +217,22 @@ static int _ignore_vg(struct volume_group *vg, const char *vg_name,
 		}
 	}
 
+	/*
+	 * Accessing a lockd VG when lvmlockd is not used is similar
+	 * to accessing a foreign VG.
+	 */
+	if (read_error & FAILED_LOCK_TYPE) {
+		if (arg_vgnames && str_list_match_item(arg_vgnames, vg->name)) {
+			log_error("Cannot access VG %s with lock_type %s that requires lvmlockd.",
+				  vg->name, vg->lock_type);
+			return 1;
+		} else {
+			read_error &= ~FAILED_LOCK_TYPE; /* Check for other errors */
+			log_verbose("Skipping volume group %s", vg_name);
+			*skip = 1;
+		}
+	}
+
 	if (read_error == FAILED_CLUSTERED) {
 		*skip = 1;
 		stack;	/* Error already logged */
@@ -721,6 +737,11 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 				  struct vgcreate_params *vp_def)
 {
 	const char *system_id_arg_str;
+	const char *lock_type = NULL;
+	int locking_type;
+	int use_lvmlockd;
+	int use_clvmd;
+	lock_type_t lock_type_num;
 
 	vp_new->vg_name = skip_dev_dir(cmd, vp_def->vg_name, NULL);
 	vp_new->max_lv = arg_uint_value(cmd, maxlogicalvolumes_ARG,
@@ -733,12 +754,6 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 	vp_new->extent_size =
 	    arg_uint_value(cmd, physicalextentsize_ARG, vp_def->extent_size);
 
-	if (arg_count(cmd, clustered_ARG))
-		vp_new->clustered = arg_int_value(cmd, clustered_ARG, vp_def->clustered);
-	else
-		/* Default depends on current locking type */
-		vp_new->clustered = locking_is_clustered();
-
 	if (arg_sign_value(cmd, physicalextentsize_ARG, SIGN_NONE) == SIGN_MINUS) {
 		log_error(_pe_size_may_not_be_negative_msg);
 		return 0;
@@ -769,16 +784,9 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 	else
 		vp_new->vgmetadatacopies = find_config_tree_int(cmd, metadata_vgmetadatacopies_CFG, NULL);
 
-	/* A clustered VG has no system ID. */
-	if (vp_new->clustered) {
-		if (arg_is_set(cmd, systemid_ARG)) {
-			log_error("system ID cannot be set on clustered Volume Groups.");
-			return 0;
-		}
-		vp_new->system_id = NULL;
-	} else if (!(system_id_arg_str = arg_str_value(cmd, systemid_ARG, NULL)))
+	if (!(system_id_arg_str = arg_str_value(cmd, systemid_ARG, NULL))) {
 		vp_new->system_id = vp_def->system_id;
-	else {
+	} else {
 		if (!(vp_new->system_id = system_id_from_string(cmd, system_id_arg_str)))
 			return_0;
 
@@ -793,6 +801,186 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 		}
 	}
 
+	if ((system_id_arg_str = arg_str_value(cmd, systemid_ARG, NULL))) {
+		vp_new->system_id = system_id_from_string(cmd, system_id_arg_str);
+	} else {
+		vp_new->system_id = vp_def->system_id;
+	}
+
+	if (system_id_arg_str) {
+		if (!vp_new->system_id || !vp_new->system_id[0])
+			log_warn("WARNING: A VG without a system ID allows unsafe access from other hosts.");
+
+		if (vp_new->system_id && cmd->system_id &&
+		    strcmp(vp_new->system_id, cmd->system_id)) {
+			log_warn("VG with system ID %s might become inaccessible as local system ID is %s",
+				 vp_new->system_id, cmd->system_id);
+		}
+	}
+
+	/*
+	 * Locking: what kind of locking should be used for the
+	 * new VG, and is it compatible with current lvm.conf settings.
+	 *
+	 * The end result is to set vp_new->lock_type to:
+	 * none | clvm | dlm | sanlock.
+	 *
+	 * If 'vgcreate --lock-type <arg>' is set, the answer is given
+	 * directly by <arg> which is one of none|clvm|dlm|sanlock.
+	 *
+	 * 'vgcreate --clustered y' is the way to create clvm VGs.
+	 *
+	 * 'vgcreate --shared' is the way to create lockd VGs.
+	 * lock_type of sanlock or dlm is selected based on
+	 * which lock manager is running.
+	 *
+	 *
+	 * 1. Using neither clvmd nor lvmlockd.
+	 * ------------------------------------------------
+	 * lvm.conf:
+	 * global/use_lvmlockd = 0
+	 * global/locking_type = 1
+	 *
+	 * - no locking is enabled
+	 * - clvmd is not used
+	 * - lvmlockd is not used
+	 * - VGs with CLUSTERED set are ignored (requires clvmd)
+	 * - VGs with lockd type are ignored (requires lvmlockd)
+	 * - vgcreate can create new VGs with lock_type none
+	 * - 'vgcreate --clustered y' fails
+	 * - 'vgcreate --shared' fails
+	 * - 'vgcreate' (neither option) creates a local VG
+	 *
+	 * 2. Using clvmd.
+	 * ------------------------------------------------
+	 * lvm.conf:
+	 * global/use_lvmlockd = 0
+	 * global/locking_type = 3
+	 *
+	 * - locking through clvmd is enabled (traditional clvm config)
+	 * - clvmd is used
+	 * - lvmlockd is not used
+	 * - VGs with CLUSTERED set can be used
+	 * - VGs with lockd type are ignored (requires lvmlockd)
+	 * - vgcreate can create new VGs with CLUSTERED status flag
+	 * - 'vgcreate --clustered y' works
+	 * - 'vgcreate --shared' fails
+	 * - 'vgcreate' (neither option) creates a clvm VG
+	 *
+	 * 3. Using lvmlockd.
+	 * ------------------------------------------------
+	 * lvm.conf:
+	 * global/use_lvmlockd = 1
+	 * global/locking_type = 1
+	 *
+	 * - locking through lvmlockd is enabled
+	 * - clvmd is not used
+	 * - lvmlockd is used
+	 * - VGs with CLUSTERED set are ignored (requires clvmd)
+	 * - VGs with lockd type can be used
+	 * - vgcreate can create new VGs with lock_type sanlock or dlm
+	 * - 'vgcreate --clustered y' fails
+	 * - 'vgcreate --shared' works
+	 * - 'vgcreate' (neither option) creates a local VG
+	 */
+
+	locking_type = find_config_tree_int(cmd, global_locking_type_CFG, NULL);
+	use_lvmlockd = find_config_tree_bool(cmd, global_use_lvmlockd_CFG, NULL);
+	use_clvmd = (locking_type == 3);
+
+	if (arg_is_set(cmd, locktype_ARG)) {
+		if (arg_is_set(cmd, clustered_ARG) || arg_is_set(cmd, shared_ARG)) {
+			log_error("A lock type cannot be specified with --shared or --clustered.");
+			return 0;
+		}
+		lock_type = arg_str_value(cmd, locktype_ARG, "");
+
+	} else if (arg_is_set(cmd, clustered_ARG)) {
+		const char *arg_str = arg_str_value(cmd, clustered_ARG, "");
+		int clustery = strcmp(arg_str, "y") ? 0 : 1;
+
+		if (use_clvmd) {
+			lock_type = clustery ? "clvm" : "none";
+
+		} else if (use_lvmlockd) {
+			log_error("lvmlockd is configured, use --shared with lvmlockd, and --clustered with clvmd.");
+			return 0;
+
+		} else {
+			if (clustery) {
+				log_error("The --clustered option requires clvmd (locking_type=3).");
+				return 0;
+			} else {
+				lock_type = "none";
+			}
+		}
+
+	} else if (arg_is_set(cmd, shared_ARG)) {
+		if (use_lvmlockd) {
+			if (!(lock_type = lockd_running_lock_type(cmd))) {
+				log_error("Failed to detect a running lock manager to select lock_type.");
+				return 0;
+			}
+
+		} else if (use_clvmd) {
+			log_error("Use --shared with lvmlockd, and --clustered with clvmd.");
+			return 0;
+
+		} else {
+			log_error("The --shared option requires lvmlockd (use_lvmlockd=1).");
+			return 0;
+		}
+
+	} else {
+		if (use_clvmd)
+			lock_type = locking_is_clustered() ? "clvm" : "none";
+		else
+			lock_type = "none";
+	}
+
+	/*
+	 * Check that the lock_type is recognized, and is being
+	 * used with the correct lvm.conf settings.
+	 */
+	lock_type_num = get_lock_type_from_string(lock_type);
+
+	switch (lock_type_num) {
+	case LOCK_TYPE_INVALID:
+		log_error("lock_type %s is invalid", lock_type);
+		return 0;
+
+	case LOCK_TYPE_SANLOCK:
+	case LOCK_TYPE_DLM:
+		if (!use_lvmlockd) {
+			log_error("lock_type %s requires use_lvmlockd configuration setting", lock_type);
+			return 0;
+		}
+		break;
+	case LOCK_TYPE_CLVM:
+		if (!use_clvmd) {
+			log_error("lock_type clvm requires locking_type 3 configuration setting");
+			return 0;
+		}
+		break;
+	case LOCK_TYPE_NONE:
+		break;
+	};
+
+	/*
+	 * The vg is not owned by one host/system_id.
+	 * Locking coordinates access from multiple hosts.
+	 */
+	if (lock_type_num == LOCK_TYPE_DLM || lock_type_num == LOCK_TYPE_SANLOCK || lock_type_num == LOCK_TYPE_CLVM)
+		vp_new->system_id = NULL;
+
+	vp_new->lock_type = lock_type;
+
+	if (lock_type_num == LOCK_TYPE_CLVM)
+		vp_new->clustered = 1;
+	else
+		vp_new->clustered = 0;
+
+	log_debug("Setting lock_type to %s", vp_new->lock_type);
 	return 1;
 }
 
@@ -1700,6 +1888,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 	struct vgnameid_list *vgnl;
 	const char *vg_name;
 	const char *vg_uuid;
+	uint32_t lockd_state;
 	int selected;
 	int whole_selected = 0;
 	int ret_max = ECMD_PROCESSED;
@@ -1724,17 +1913,19 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 		vg_uuid = vgnl->vgid;
 		skip = 0;
 
-		vg = vg_read(cmd, vg_name, vg_uuid, flags);
-		if (_ignore_vg(vg, vg_name, arg_vgnames, flags & READ_ALLOW_INCONSISTENT, &skip)) {
-			stack;
+		if (!lockd_vg(cmd, vg_name, NULL, 0, &lockd_state)) {
 			ret_max = ECMD_FAILED;
-			release_vg(vg);
 			continue;
 		}
-		if (skip) {
-			release_vg(vg);
-			continue;
+
+		vg = vg_read(cmd, vg_name, vg_uuid, flags, lockd_state);
+		if (_ignore_vg(vg, vg_name, arg_vgnames, flags & READ_ALLOW_INCONSISTENT, &skip)) {
+			stack;
+			ret_max = ECMD_FAILED;
+			goto endvg;
 		}
+		if (skip)
+			goto endvg;
 
 		/* Process this VG? */
 		if ((process_all ||
@@ -1749,10 +1940,11 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 				ret_max = ret;
 		}
 
-		if (vg_read_error(vg))
-			release_vg(vg);
-		else
-			unlock_and_release_vg(cmd, vg, vg_name);
+		if (!vg_read_error(vg))
+			unlock_vg(cmd, vg_name);
+endvg:
+		release_vg(vg);
+		lockd_vg(cmd, vg_name, "un", 0, &lockd_state);
 	}
 
 	/* the VG is selected if at least one LV is selected */
@@ -1806,7 +1998,8 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	unsigned one_vgname_arg = (flags & ONE_VGNAME_ARG);
 	int ret;
 
-	cmd->error_foreign_vgs = 0;
+	/* Disable error in vg_read so we can print it from ignore_vg. */
+	cmd->vg_read_print_access_error = 0;
 
 	dm_list_init(&arg_tags);
 	dm_list_init(&arg_vgnames);
@@ -1824,9 +2017,16 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	 *   any tags were supplied and need resolving; or
 	 *   no VG names were given and the command defaults to processing all VGs.
 	 */
-	if (((dm_list_empty(&arg_vgnames) && enable_all_vgs) || !dm_list_empty(&arg_tags)) &&
-	    !get_vgnameids(cmd, &vgnameids_on_system, NULL, 0))
-		goto_out;
+	if ((dm_list_empty(&arg_vgnames) && enable_all_vgs) || !dm_list_empty(&arg_tags)) {
+		/* Needed for a current listing of the global VG namespace. */
+		if (!lockd_gl(cmd, "sh", 0)) {
+			ret = ECMD_FAILED;
+			goto_out;
+		}
+
+		if (!get_vgnameids(cmd, &vgnameids_on_system, NULL, 0))
+			goto_out;
+	}
 
 	if (dm_list_empty(&arg_vgnames) && dm_list_empty(&vgnameids_on_system)) {
 		/* FIXME Should be log_print, but suppressed for reporting cmds */
@@ -2140,6 +2340,7 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 	struct dm_str_list *sl;
 	struct dm_list *tags_arg;
 	struct dm_list lvnames;
+	uint32_t lockd_state;
 	const char *vg_name;
 	const char *vg_uuid;
 	const char *vgn;
@@ -2186,18 +2387,20 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 			}
 		}
 
-		vg = vg_read(cmd, vg_name, vg_uuid, flags);
+		if (!lockd_vg(cmd, vg_name, NULL, 0, &lockd_state)) {
+			ret_max = ECMD_FAILED;
+			continue;
+		}
+
+		vg = vg_read(cmd, vg_name, vg_uuid, flags, lockd_state);
 		if (_ignore_vg(vg, vg_name, arg_vgnames, flags & READ_ALLOW_INCONSISTENT, &skip)) {
 			stack;
 			ret_max = ECMD_FAILED;
-			release_vg(vg);
-			continue;
+			goto endvg;
 
 		}
-		if (skip) {
-			release_vg(vg);
-			continue;
-		}
+		if (skip)
+			goto endvg;
 
 		ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg, 0,
 					    handle, process_single_lv);
@@ -2206,7 +2409,10 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 		if (ret > ret_max)
 			ret_max = ret;
 
-		unlock_and_release_vg(cmd, vg, vg_name);
+		unlock_vg(cmd, vg_name);
+endvg:
+		release_vg(vg);
+		lockd_vg(cmd, vg_name, "un", 0, &lockd_state);
 	}
 
 	return ret_max;
@@ -2229,7 +2435,8 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t fla
 	int need_vgnameids = 0;
 	int ret;
 
-	cmd->error_foreign_vgs = 0;
+	/* Disable error in vg_read so we can print it from ignore_vg. */
+	cmd->vg_read_print_access_error = 0;
 
 	dm_list_init(&arg_tags);
 	dm_list_init(&arg_vgnames);
@@ -2263,8 +2470,16 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t fla
 	else if (dm_list_empty(&arg_vgnames) && handle->internal_report_for_select)
 		need_vgnameids = 1;
 
-	if (need_vgnameids && !get_vgnameids(cmd, &vgnameids_on_system, NULL, 0))
-		goto_out;
+	if (need_vgnameids) {
+		/* Needed for a current listing of the global VG namespace. */
+		if (!lockd_gl(cmd, "sh", 0)) {
+			ret = ECMD_FAILED;
+			goto_out;
+		}
+
+		if (!get_vgnameids(cmd, &vgnameids_on_system, NULL, 0))
+			goto_out;
+	}
 
 	if (dm_list_empty(&arg_vgnames) && dm_list_empty(&vgnameids_on_system)) {
 		/* FIXME Should be log_print, but suppressed for reporting cmds */
@@ -2657,6 +2872,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 	struct vgnameid_list *vgnl;
 	const char *vg_name;
 	const char *vg_uuid;
+	uint32_t lockd_state;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 	int skip;
@@ -2669,14 +2885,17 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 		vg_uuid = vgnl->vgid;
 		skip = 0;
 
-		vg = vg_read(cmd, vg_name, vg_uuid, flags | READ_WARN_INCONSISTENT);
+		if (!lockd_vg(cmd, vg_name, NULL, 0, &lockd_state)) {
+			ret_max = ECMD_FAILED;
+			continue;
+		}
+
+		vg = vg_read(cmd, vg_name, vg_uuid, flags | READ_WARN_INCONSISTENT, lockd_state);
 		if (_ignore_vg(vg, vg_name, NULL, flags & READ_ALLOW_INCONSISTENT, &skip)) {
 			stack;
 			ret_max = ECMD_FAILED;
-			if (!skip) {
-				release_vg(vg);
-				continue;
-			}
+			if (!skip)
+				goto endvg;
 			/* Drop through to eliminate a clustered VG's PVs from the devices list */
 		}
 		
@@ -2693,10 +2912,11 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 		if (ret > ret_max)
 			ret_max = ret;
 
-		if (skip)
-			release_vg(vg);
-		else
-			unlock_and_release_vg(cmd, vg, vg->name);
+		if (!skip)
+			unlock_vg(cmd, vg->name);
+endvg:
+		release_vg(vg);
+		lockd_vg(cmd, vg_name, "un", 0, &lockd_state);
 
 		/* Quit early when possible. */
 		if (!process_all_pvs && dm_list_empty(arg_tags) && dm_list_empty(arg_devices))
@@ -2724,7 +2944,8 @@ int process_each_pv(struct cmd_context *cmd,
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 
-	cmd->error_foreign_vgs = 0;
+	/* Disable error in vg_read so we can print it from ignore_vg. */
+	cmd->vg_read_print_access_error = 0;
 
 	dm_list_init(&arg_tags);
 	dm_list_init(&arg_pvnames);
@@ -2750,6 +2971,10 @@ int process_each_pv(struct cmd_context *cmd,
 	process_all_devices = process_all_pvs && (cmd->command->flags & ENABLE_ALL_DEVS) &&
 			      arg_count(cmd, all_ARG);
 
+	/* Needed for a current listing of the global VG namespace. */
+	if (!only_this_vgname && !lockd_gl(cmd, "sh", 0))
+		return_ECMD_FAILED;
+
 	/*
 	 * Need pvid's set on all PVs before processing so that pvid's
 	 * can be compared to find duplicates while processing.
diff --git a/tools/tools.h b/tools/tools.h
index e959d80..675867d 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -28,6 +28,7 @@
 #include "archiver.h"
 #include "lvmcache.h"
 #include "lvmetad.h"
+#include "lvmlockd.h"
 #include "lvm-version.h"
 #include "config.h"
 #include "defaults.h"
@@ -108,8 +109,8 @@ struct arg_value_group_list {
 #define ENABLE_ALL_DEVS		0x00000008	
 /* Exactly one VG name argument required. */
 #define ONE_VGNAME_ARG		0x00000010
-/* Command is allowed to read foreign VGs. */
-#define ENABLE_FOREIGN_VGS	0x00000020
+/* Command needs a shared lock on a VG; it only reads the VG. */
+#define LOCKD_VG_SH		0x00000020
  
 /* a register of the lvm commands */
 struct command {
@@ -146,6 +147,7 @@ int metadatatype_arg(struct cmd_context *cmd, struct arg_values *av);
 int units_arg(struct cmd_context *cmd, struct arg_values *av);
 int segtype_arg(struct cmd_context *cmd, struct arg_values *av);
 int alloc_arg(struct cmd_context *cmd, struct arg_values *av);
+int locktype_arg(struct cmd_context *cmd, struct arg_values *av);
 int readahead_arg(struct cmd_context *cmd, struct arg_values *av);
 int metadatacopies_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
 
diff --git a/tools/vgchange.c b/tools/vgchange.c
index f689c61..076fcb8 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -313,9 +313,18 @@ static int _vgchange_clustered(struct cmd_context *cmd,
 			       struct volume_group *vg)
 {
 	int clustered = arg_int_value(cmd, clustered_ARG, 0);
+	const char *lock_type = arg_str_value(cmd, locktype_ARG, NULL);
 	struct lv_list *lvl;
 	struct lv_segment *mirror_seg;
 
+	if (find_config_tree_bool(cmd, global_use_lvmlockd_CFG, NULL)) {
+		log_error("lvmlockd requires using the vgchange --lock-type option.");
+		return 0;
+	}
+
+	if (lock_type && !strcmp(lock_type, "clvm"))
+		clustered = 1;
+
 	if (clustered && vg_is_clustered(vg)) {
 		if (vg->system_id && *vg->system_id)
 			log_warn("WARNING: Clearing invalid system ID %s from volume group %s.",
@@ -511,6 +520,216 @@ static int _vgchange_profile(struct cmd_context *cmd,
 	return 1;
 }
 
+static int _vgchange_locktype(struct cmd_context *cmd,
+			      struct volume_group *vg)
+{
+	const char *lock_type = arg_str_value(cmd, locktype_ARG, NULL);
+	struct lv_list *lvl;
+	struct logical_volume *lv;
+
+	/*
+	 * This is a special/forced exception to change the lock type to none.
+	 * It's needed for recovery cases and skips the normal steps of undoing
+	 * the current lock type.  It's a way to forcibly get access to a VG
+	 * when the normal locking mechanisms are not working.
+	 *
+	 * It ignores: the current lvm locking config, lvmlockd, the state of
+	 * the vg on other hosts, etc.  It is meant to just remove any locking
+	 * related metadata from the VG (cluster/lock_type flags, lock_type,
+	 * lock_args).
+	 *
+	 * This can be necessary when manually recovering from certain failures.
+	 * e.g. when a pv is lost containing the lvmlock lv (holding sanlock
+	 * leases), the vg lock_type needs to be changed to none, and then
+	 * back to sanlock, which recreates the lvmlock lv and leases.
+	 */
+	if (!strcmp(lock_type, "none") && arg_is_set(cmd, force_ARG)) {
+		if (yes_no_prompt("Forcibly change VG %s lock type to none? [y/n]: ", vg->name) == 'n') {
+			log_error("VG lock type not changed.");
+			return 0;
+		}
+
+		vg->status &= ~CLUSTERED;
+		vg->lock_type = "none";
+		vg->lock_args = NULL;
+
+		dm_list_iterate_items(lvl, &vg->lvs)
+			lvl->lv->lock_args = NULL;
+
+		return 1;
+	}
+
+	if (!vg->lock_type) {
+		if (vg_is_clustered(vg))
+			vg->lock_type = "clvm";
+		else
+			vg->lock_type = "none";
+	}
+
+	if (!strcmp(vg->lock_type, lock_type)) {
+		log_warn("New lock_type %s matches the current lock_type %s.",
+			 lock_type, vg->lock_type);
+		return 1;
+	}
+
+	/*
+	 * When lvm is currently using clvm, this function is just an alternative
+	 * to vgchange -c{y,n}, and can:
+	 * - change none to clvm
+	 * - change clvm to none
+	 * - it CANNOT change to or from a lockd type
+	 */
+	if (locking_is_clustered()) {
+		if (is_lockd_type(lock_type)) {
+			log_error("Changing to lock type %s requires lvmlockd.", lock_type);
+			return 0;
+		}
+
+		return _vgchange_clustered(cmd, vg);
+	}
+
+	/*
+	 * When lvm is currently using lvmlockd, this function can:
+	 * - change none to lockd type
+	 * - change none to clvm (with warning about not being able to use it)
+	 * - change lockd type to none
+	 * - change lockd type to clvm (with warning about not being able to use it)
+	 * - change clvm to none
+	 * - change clvm to lockd type
+	 */
+
+	if (lvs_in_vg_activated(vg)) {
+		log_error("Changing VG %s lock type not allowed with active LVs",
+			  vg->name);
+		return 0;
+	}
+
+	/*
+	 * Check if there are any LV types in the VG that cannot be handled
+	 * with the new lock type.  Remove this once all LV types can be
+	 * handled.
+	 */
+	if (is_lockd_type(lock_type)) {
+		dm_list_iterate_items(lvl, &vg->lvs) {
+			lv = lvl->lv;
+
+			if ((lv->status & SNAPSHOT) || lv_is_cow(lv)) {
+				log_error("Changing to lock type %s is not allowed with cow snapshot LV %s/%s",
+					  lock_type, vg->name, lv->name);
+				return 0;
+			}
+		}
+	}
+
+	/* none to clvm */
+	if (!strcmp(vg->lock_type, "none") && !strcmp(lock_type, "clvm")) {
+		log_warn("New clvm lock type will not be usable with lvmlockd.");
+		vg->status |= CLUSTERED;
+		vg->lock_type = "clvm"; /* this is optional */
+		return 1;
+	}
+
+	/* clvm to none */
+	if (!strcmp(vg->lock_type, "clvm") && !strcmp(lock_type, "none")) {
+		vg->status &= ~CLUSTERED;
+		vg->lock_type = "none";
+		return 1;
+	}
+
+	/* clvm to ..., first undo clvm */
+	if (!strcmp(vg->lock_type, "clvm")) {
+		vg->status &= ~CLUSTERED;
+	}
+
+	/*
+	 * lockd type to ..., first undo lockd type
+	 *
+	 * To allow this, we need to do:
+	 * lockd_stop_vg();
+	 * lockd_free_vg_before();
+	 * lockd_free_vg_after();
+	 */
+	if (is_lockd_type(vg->lock_type)) {
+		/* FIXME: implement full undoing of the lock_type */
+		log_error("Changing VG %s from lock type %s not yet allowed.",
+			  vg->name, vg->lock_type);
+		return 0;
+	}
+
+	/* ... to clvm */
+	if (!strcmp(lock_type, "clvm")) {
+		log_warn("New clvm lock type will not be usable with lvmlockd.");
+		vg->status |= CLUSTERED;
+		vg->lock_type = "clvm"; /* this is optional */
+		vg->system_id = NULL;
+		return 1;
+	}
+
+	/* ... to lockd type */
+	if (is_lockd_type(lock_type)) {
+		/*
+		 * For lock_type dlm, lockd_init_vg() will do a single
+		 * vg_write() that sets lock_type, sets lock_args, clears
+		 * system_id, and sets all LV lock_args to dlm.
+		 */
+		if (!strcmp(lock_type, "dlm")) {
+			dm_list_iterate_items(lvl, &vg->lvs) {
+				lv = lvl->lv;
+				if (lockd_lv_uses_lock(lv))
+					lv->lock_args = "dlm";
+			}
+		}
+
+		/*
+		 * See below.  We cannot set valid LV lock_args until stage 1
+		 * of the change is done, so we need to skip the validation of
+		 * the lock_args during stage 1.
+		 */
+		if (!strcmp(lock_type, "sanlock"))
+			vg->skip_validate_lock_args = 1;
+
+		vg->system_id = NULL;
+
+		if (!lockd_init_vg(cmd, vg, lock_type)) {
+			log_error("Failed to initialize lock args for lock type %s", lock_type);
+			return 0;
+		}
+
+		/*
+		 * For lock_type sanlock, there must be multiple steps
+		 * because the VG needs an active lvmlock LV before
+		 * LV lock areas can be allocated, which must be done
+		 * before LV lock_args are written.  So, the LV lock_args
+		 * remain unset during the first stage of the conversion.
+		 *
+		 * Stage 1:
+		 * lockd_init_vg() creates and activates the lvmlock LV,
+		 * then sets lock_type, sets lock_args, and clears system_id.
+		 *
+		 * Stage 2:
+		 * We get here, and can now set LV lock_args.  This uses
+		 * the standard code path for allocating LV locks in
+		 * vg_write() by setting LV lock_args to "pending",
+		 * which tells vg_write() to call lockd_init_lv()
+		 * and sets the lv->lock_args value before writing the VG.
+		 */
+		if (!strcmp(lock_type, "sanlock")) {
+			dm_list_iterate_items(lvl, &vg->lvs) {
+				lv = lvl->lv;
+				if (lockd_lv_uses_lock(lv))
+					lv->lock_args = "pending";
+			}
+
+			vg->skip_validate_lock_args = 0;
+		}
+
+		return 1;
+	}
+
+	log_error("Unknown lock type");
+	return 0;
+}
+
 /*
  * This function will not be called unless the local host is allowed to use the
  * VG.  Either the VG has no system_id, or the VG and host have matching
@@ -582,9 +801,83 @@ static int _vgchange_system_id(struct cmd_context *cmd, struct volume_group *vg)
 	if (vg->lvm1_system_id)
 		*vg->lvm1_system_id = '\0';
 
+	/* update system_id in lvmlockd's record for this vg */
+	if (!lockd_start_vg(cmd, vg))
+		log_debug("Failed to update lvmlockd.");
+
 	return 1;
 }
 
+static int _passes_lock_start_filter(struct cmd_context *cmd,
+				     struct volume_group *vg,
+				     const int cfg_id)
+{
+	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
+	const char *str;
+
+	/* undefined list means no restrictions, all vg names pass */
+
+	cn = find_config_tree_node(cmd, cfg_id, NULL);
+	if (!cn)
+		return 1;
+
+	/* with a defined list, the vg name must be included to pass */
+
+	for (cv = cn->v; cv; cv = cv->next) {
+		if (cv->type == DM_CFG_EMPTY_ARRAY)
+			break;
+		if (cv->type != DM_CFG_STRING) {
+			log_error("Ignoring invalid string in lock_start list");
+			continue;
+		}
+		str = cv->v.str;
+		if (!*str) {
+			log_error("Ignoring empty string in config file");
+			continue;
+		}
+
+		/* ignoring tags for now */
+
+		if (!strcmp(str, vg->name))
+			return 1;
+	}
+
+	return 0;
+}
+
+static int _vgchange_lock_start(struct cmd_context *cmd, struct volume_group *vg)
+{
+	const char *start_opt = arg_str_value(cmd, lockopt_ARG, NULL);
+	int auto_opt = 0;
+
+	if (!start_opt || arg_is_set(cmd, force_ARG))
+		goto do_start;
+
+	if (!strcmp(start_opt, "auto") || !strcmp(start_opt, "autowait"))
+		auto_opt = 1;
+
+	if (!_passes_lock_start_filter(cmd, vg, activation_lock_start_list_CFG)) {
+		log_verbose("Not starting %s since it does not pass lock_start_list", vg->name);
+		return 1;
+	}
+
+	if (auto_opt && !_passes_lock_start_filter(cmd, vg, activation_auto_lock_start_list_CFG)) {
+		log_verbose("Not starting %s since it does not pass auto_lock_start_list", vg->name);
+		return 1;
+	}
+
+do_start:
+	return lockd_start_vg(cmd, vg);
+}
+
+static int _vgchange_lock_stop(struct cmd_context *cmd, struct volume_group *vg)
+{
+	/* Disable the unlock in toollib because it's pointless after the stop. */
+	cmd->lockd_vg_disable = 1;
+	return lockd_stop_vg(cmd, vg);
+}
+
 static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 			   struct volume_group *vg,
 			   struct processing_handle *handle __attribute__((unused)))
@@ -610,6 +903,7 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 		{ metadataprofile_ARG, &_vgchange_profile },
 		{ profile_ARG, &_vgchange_profile },
 		{ detachprofile_ARG, &_vgchange_profile },
+		{ locktype_ARG, &_vgchange_locktype },
 		{ systemid_ARG, &_vgchange_system_id },
 	};
 
@@ -699,13 +993,90 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 		if (!_vgchange_background_polling(cmd, vg))
 			return_ECMD_FAILED;
 
+	if (arg_is_set(cmd, lockstart_ARG)) {
+		if (!_vgchange_lock_start(cmd, vg))
+			return_ECMD_FAILED;
+	} else if (arg_is_set(cmd, lockstop_ARG)) {
+		if (!_vgchange_lock_stop(cmd, vg))
+			return_ECMD_FAILED;
+	}
+
         return ret;
 }
 
+/*
+ * vgchange can do different things that require different
+ * locking, so look at each of those things here.
+ *
+ * Set up overrides for the default VG locking for various special cases.
+ * The VG lock will be acquired in process_each_vg.
+ *
+ * Acquire the gl lock according to which kind of vgchange command this is.
+ */
+
+static int _lockd_vgchange(struct cmd_context *cmd, int argc, char **argv)
+{
+	/* The default vg lock mode is ex, but these options only need sh. */
+
+	if (arg_is_set(cmd, activate_ARG) || arg_is_set(cmd, refresh_ARG))
+		cmd->lockd_vg_default_sh = 1;
+
+	/* Starting a vg lockspace means there are no locks available yet. */
+
+	if (arg_is_set(cmd, lockstart_ARG))
+		cmd->lockd_vg_disable = 1;
+
+	/*
+	 * In most cases, lockd_vg does not apply when changing lock type.
+	 * (We don't generally allow changing *from* lockd type yet.)
+	 * lockd_vg could be called within _vgchange_locktype as needed.
+	 */
+
+	if (arg_is_set(cmd, locktype_ARG))
+		cmd->lockd_vg_disable = 1;
+
+	/*
+	 * Changing system_id or lock_type must only be done on explicitly
+	 * named vgs.
+	 */
+
+	if (arg_is_set(cmd, systemid_ARG) || arg_is_set(cmd, locktype_ARG))
+		cmd->command->flags &= ~ALL_VGS_IS_DEFAULT;
+
+	if (arg_is_set(cmd, lockstart_ARG)) {
+		/*
+		 * The lockstart condition takes the global lock to serialize
+		 * with any other host that tries to remove the VG while this
+		 * tries to start it.  (Zero argc means all VGs, in wich case
+		 * process_each_vg will acquire the global lock.)
+		 */
+		if (argc && !lockd_gl(cmd, "sh", 0))
+			return_ECMD_FAILED;
+
+	} else if (arg_is_set(cmd, systemid_ARG) || arg_is_set(cmd, locktype_ARG)) {
+		/*
+		 * This is a special case where taking the global lock is
+		 * not needed to protect global state, because the change is
+		 * only to an existing VG.  But, taking the global lock ex is
+		 * helpful in this case to trigger a global cache validation
+		 * on other hosts, to cause them to see the new system_id or
+		 * lock_type.
+		 */
+		if (!lockd_gl(cmd, "ex", LDGL_UPDATE_NAMES))
+			return_ECMD_FAILED;
+	}
+
+	return 1;
+}
+
 int vgchange(struct cmd_context *cmd, int argc, char **argv)
 {
+	int ret;
+
 	int noupdate =
 		arg_count(cmd, activate_ARG) ||
+		arg_count(cmd, lockstart_ARG) ||
+		arg_count(cmd, lockstop_ARG) ||
 		arg_count(cmd, monitor_ARG) ||
 		arg_count(cmd, poll_ARG) ||
 		arg_count(cmd, refresh_ARG);
@@ -726,6 +1097,7 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 		arg_count(cmd, clustered_ARG) ||
 		arg_count(cmd, alloc_ARG) ||
 		arg_count(cmd, vgmetadatacopies_ARG) ||
+		arg_count(cmd, locktype_ARG) ||
 		arg_count(cmd, systemid_ARG);
 
 	int update = update_partial_safe || update_partial_unsafe;
@@ -821,9 +1193,35 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 	if (!update || !update_partial_unsafe)
 		cmd->handles_missing_pvs = 1;
 
+	/*
+	 * Include foreign VGs that contain active LVs.
+	 * That shouldn't happen in general, but if it does by some
+	 * mistake, then we want to allow those LVs to be deactivated.
+	 */
 	if (arg_is_set(cmd, activate_ARG))
 		cmd->include_active_foreign_vgs = 1;
 
-	return process_each_vg(cmd, argc, argv, update ? READ_FOR_UPDATE : 0,
-			       NULL, &vgchange_single);
+	if (!_lockd_vgchange(cmd, argc, argv))
+		return_ECMD_FAILED;
+
+	ret = process_each_vg(cmd, argc, argv, update ? READ_FOR_UPDATE : 0,
+			      NULL, &vgchange_single);
+
+	/* Wait for lock-start ops that were initiated in vgchange_lockstart. */
+
+	if (arg_is_set(cmd, lockstart_ARG)) {
+		const char *start_opt = arg_str_value(cmd, lockopt_ARG, NULL);
+
+		lockd_gl(cmd, "un", 0);
+
+		if (!start_opt || !strcmp(start_opt, "wait") || !strcmp(start_opt, "autowait")) {
+			log_print_unless_silent("Starting locking.  Waiting until locks are ready...");
+			lockd_start_wait(cmd);
+
+		} else if (!strcmp(start_opt, "nowait")) {
+			log_print_unless_silent("Starting locking.  VG is read-only until locks are ready.");
+		}
+	}
+
+	return ret;
 }
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 0a6ad6f..20ba4aa 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -50,6 +50,13 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	if (!vgcreate_params_validate(cmd, &vp_new))
 	    return EINVALID_CMD_LINE;
 
+	/*
+	 * Needed to change the global VG namespace,
+	 * and to change the set of orphan PVs.
+	 */
+	if (!lockd_gl_create(cmd, "ex", vp_new.lock_type))
+		return ECMD_FAILED;
+
 	lvmcache_seed_infos_from_lvmetad(cmd);
 
 	/* Create the new VG */
@@ -119,6 +126,19 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	if (!vg_write(vg) || !vg_commit(vg))
 		goto_bad;
 
+	/*
+	 * The VG is initially written without lock_type set, i.e. it starts as
+	 * a local VG.  lockd_init_vg() then writes the VG a second time with
+	 * both lock_type and lock_args set.
+	 */
+	if (!lockd_init_vg(cmd, vg, vp_new.lock_type)) {
+		log_error("Failed to initialize lock args for lock type %s",
+			  vp_new.lock_type);
+		vg_remove_pvs(vg);
+		vg_remove_direct(vg);
+		goto_bad;
+	}
+
 	unlock_vg(cmd, VG_ORPHANS);
 	unlock_vg(cmd, vp_new.vg_name);
 
@@ -128,6 +148,33 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 				clustered_message, *clustered_message ? 'v' : 'V', vg->name,
 				vg->system_id ? " with system ID " : "", vg->system_id ? : "");
 
+	/*
+	 * Start the VG lockspace because it will likely be used right away.
+	 * Optionally wait for the start to complete so the VG can be fully
+	 * used after this command completes (otherwise, the VG can only be
+	 * read without locks until the lockspace is done starting.)
+	 */
+	if (is_lockd_type(vg->lock_type)) {
+		const char *start_opt = arg_str_value(cmd, lockopt_ARG, NULL);
+
+		if (!lockd_start_vg(cmd, vg)) {
+			log_error("Failed to start locking");
+			goto out;
+		}
+
+		lockd_gl(cmd, "un", 0);
+
+		if (!start_opt || !strcmp(start_opt, "wait")) {
+			/* It is OK if the user does Ctrl-C to cancel the wait. */
+			log_print_unless_silent("Starting locking.  Waiting until locks are ready...");
+			lockd_start_wait(cmd);
+
+		} else if (!strcmp(start_opt, "nowait")) {
+			log_print_unless_silent("Starting locking.  VG is read-only until locks are ready.");
+		}
+
+	}
+out:
 	release_vg(vg);
 	return ECMD_PROCESSED;
 
diff --git a/tools/vgextend.c b/tools/vgextend.c
index de6d862..581c211 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -165,6 +165,10 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 	 */
 	cmd->handles_missing_pvs = 1;
 
+	/* Needed to change the set of orphan PVs. */
+	if (!lockd_gl(cmd, "ex", 0))
+		return_ECMD_FAILED;
+
 	ret = process_each_vg(cmd, argc, argv,
 			      READ_FOR_UPDATE | ONE_VGNAME_ARG, handle,
 			      restoremissing ? &_vgextend_restoremissing : &_vgextend_single);
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index a17a636..c5ac332 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -20,11 +20,18 @@ static struct volume_group *_vgmerge_vg_read(struct cmd_context *cmd,
 {
 	struct volume_group *vg;
 	log_verbose("Checking for volume group \"%s\"", vg_name);
-	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
+	vg = vg_read_for_update(cmd, vg_name, NULL, 0, 0);
 	if (vg_read_error(vg)) {
 		release_vg(vg);
 		return NULL;
 	}
+
+	if (is_lockd_type(vg->lock_type)) {
+		log_error("vgmerge not allowed for lock_type %s", vg->lock_type);
+		unlock_and_release_vg(cmd, vg, vg_name);
+		return NULL;
+	}
+
 	return vg;
 }
 
@@ -194,6 +201,10 @@ int vgmerge(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
+	/* Needed change the global VG namespace. */
+	if (!lockd_gl(cmd, "ex", LDGL_UPDATE_NAMES))
+		return ECMD_FAILED;
+
 	vg_name_to = skip_dev_dir(cmd, argv[0], NULL);
 	argc--;
 	argv++;
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 0adf1bb..693f538 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -141,6 +141,7 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct volume_group *vg;
 	const char *vg_name;
+	uint32_t lockd_state;
 	int ret = ECMD_FAILED;
 	int fixed = 1;
 	int repairing = arg_count(cmd, removemissing_ARG);
@@ -195,7 +196,14 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 	init_ignore_suspended_devices(1);
 	cmd->handles_missing_pvs = 1;
 
-	vg = vg_read_for_update(cmd, vg_name, NULL, READ_ALLOW_EXPORTED);
+	/* Needed to change the set of orphan PVs. */
+	if (!lockd_gl(cmd, "ex", 0))
+		return_ECMD_FAILED;
+
+	if (!lockd_vg(cmd, vg_name, "ex", 0, &lockd_state))
+		return_ECMD_FAILED;
+
+	vg = vg_read_for_update(cmd, vg_name, NULL, READ_ALLOW_EXPORTED, lockd_state);
 	if (vg_read_error(vg) == FAILED_ALLOCATION ||
 	    vg_read_error(vg) == FAILED_NOTFOUND)
 		goto_out;
@@ -218,7 +226,7 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 	log_verbose("Trying to open VG %s for recovery...", vg_name);
 
 	vg = vg_read_for_update(cmd, vg_name, NULL,
-				READ_ALLOW_INCONSISTENT | READ_ALLOW_EXPORTED);
+				READ_ALLOW_INCONSISTENT | READ_ALLOW_EXPORTED, lockd_state);
 
 	locked |= !vg_read_error(vg);
 
diff --git a/tools/vgremove.c b/tools/vgremove.c
index fd97356..692d114 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -68,6 +68,9 @@ static int vgremove_single(struct cmd_context *cmd, const char *vg_name,
 		}
 	}
 
+	if (!lockd_free_vg_before(cmd, vg))
+		return_ECMD_FAILED;
+
 	if (!force && !vg_remove_check(vg))
 		return_ECMD_FAILED;
 
@@ -76,6 +79,8 @@ static int vgremove_single(struct cmd_context *cmd, const char *vg_name,
 	if (!vg_remove(vg))
 		return_ECMD_FAILED;
 
+	lockd_free_vg_final(cmd, vg);
+
 	return ECMD_PROCESSED;
 }
 
@@ -89,6 +94,20 @@ int vgremove(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
+	/*
+	 * Needed to change the global VG namespace,
+	 * and to change the set of orphan PVs.
+	 */
+	if (!lockd_gl(cmd, "ex", LDGL_UPDATE_NAMES))
+		return ECMD_FAILED;
+
+	/*
+	 * This is a special case: if vgremove is given a tag, it causes
+	 * process_each_vg to do lockd_gl(sh) when getting a list of all
+	 * VG names.  We don't want the gl converted to sh, so disable it.
+	 */
+	cmd->lockd_gl_disable = 1;
+
 	cmd->handles_missing_pvs = 1;
 	ret = process_each_vg(cmd, argc, argv,
 			      READ_FOR_UPDATE,
diff --git a/tools/vgrename.c b/tools/vgrename.c
index 860ccf1..188061b 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -17,13 +17,14 @@
 
 static struct volume_group *_get_old_vg_for_rename(struct cmd_context *cmd,
 						   const char *vg_name_old,
-						   const char *vgid)
+						   const char *vgid,
+						   uint32_t lockd_state)
 {
 	struct volume_group *vg;
 
 	/* FIXME we used to print an error about EXPORTED, but proceeded
 	   nevertheless. */
-	vg = vg_read_for_update(cmd, vg_name_old, vgid, READ_ALLOW_EXPORTED);
+	vg = vg_read_for_update(cmd, vg_name_old, vgid, READ_ALLOW_EXPORTED, lockd_state);
 	if (vg_read_error(vg)) {
 		release_vg(vg);
 		return_NULL;
@@ -67,6 +68,7 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 	const char *vgid = NULL, *vg_name, *vg_name_old;
 	char old_path[NAME_LEN], new_path[NAME_LEN];
 	struct volume_group *vg = NULL;
+	uint32_t lockd_state;
 	int lock_vg_old_first = 1;
 
 	vg_name_old = skip_dev_dir(cmd, old_vg_path, NULL);
@@ -114,11 +116,14 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 	} else
 		vgid = NULL;
 
+	if (!lockd_vg(cmd, vg_name_old, "ex", 0, &lockd_state))
+		return_0;
+
 	if (strcmp(vg_name_new, vg_name_old) < 0)
 		lock_vg_old_first = 0;
 
 	if (lock_vg_old_first) {
-		vg = _get_old_vg_for_rename(cmd, vg_name_old, vgid);
+		vg = _get_old_vg_for_rename(cmd, vg_name_old, vgid, lockd_state);
 		if (!vg)
 			return_0;
 
@@ -130,7 +135,7 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 		if (!_lock_new_vg_for_rename(cmd, vg_name_new))
 			return_0;
 
-		vg = _get_old_vg_for_rename(cmd, vg_name_old, vgid);
+		vg = _get_old_vg_for_rename(cmd, vg_name_old, vgid, lockd_state);
 		if (!vg) {
 			unlock_vg(cmd, vg_name_new);
 			return_0;
@@ -144,6 +149,9 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 	if (!drop_cached_metadata(vg))
 		stack;
 
+	if (!lockd_rename_vg_before(cmd, vg))
+		return_0;
+
 	/* Change the volume group name */
 	vg_rename(cmd, vg, vg_name_new);
 
@@ -171,6 +179,8 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 		}
 	}
 
+	lockd_rename_vg_final(cmd, vg, 1);
+
 	if (!backup(vg))
 		stack;
 	if (!backup_remove(cmd, vg_name_old))
@@ -190,6 +200,8 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 	return 1;
 
       error:
+	lockd_rename_vg_final(cmd, vg, 0);
+
 	if (lock_vg_old_first) {
 		unlock_vg(cmd, vg_name_new);
 		unlock_and_release_vg(cmd, vg, vg_name_old);
@@ -207,6 +219,10 @@ int vgrename(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
+	/* Needed change the global VG namespace. */
+	if (!lockd_gl(cmd, "ex", LDGL_UPDATE_NAMES))
+		return_ECMD_FAILED;
+
 	if (!vg_rename_path(cmd, argv[0], argv[1]))
 		return_ECMD_FAILED;
 
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 53f3975..7605bc4 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -422,7 +422,7 @@ static struct volume_group *_vgsplit_to(struct cmd_context *cmd,
 	if (vg_read_error(vg_to) == FAILED_EXIST) {
 		*existing_vg = 1;
 		release_vg(vg_to);
-		vg_to = vg_read_for_update(cmd, vg_name_to, NULL, 0);
+		vg_to = vg_read_for_update(cmd, vg_name_to, NULL, 0, 0);
 
 		if (vg_read_error(vg_to)) {
 			release_vg(vg_to);
@@ -448,11 +448,18 @@ static struct volume_group *_vgsplit_from(struct cmd_context *cmd,
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_from);
 
-	vg_from = vg_read_for_update(cmd, vg_name_from, NULL, 0);
+	vg_from = vg_read_for_update(cmd, vg_name_from, NULL, 0, 0);
 	if (vg_read_error(vg_from)) {
 		release_vg(vg_from);
 		return NULL;
 	}
+
+	if (is_lockd_type(vg_from->lock_type)) {
+		log_error("vgsplit not allowed for lock_type %s", vg_from->lock_type);
+		unlock_and_release_vg(cmd, vg_from, vg_name_from);
+		return NULL;
+	}
+
 	return vg_from;
 }
 
@@ -492,6 +499,10 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
+	/* Needed change the global VG namespace. */
+	if (!lockd_gl(cmd, "ex", LDGL_UPDATE_NAMES))
+		return_ECMD_FAILED;
+
 	if (arg_count(cmd, name_ARG))
 		lv_name = arg_value(cmd, name_ARG);
 	else
@@ -662,7 +673,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	if (!test_mode()) {
 		release_vg(vg_to);
 		vg_to = vg_read_for_update(cmd, vg_name_to, NULL,
-					   READ_ALLOW_EXPORTED);
+					   READ_ALLOW_EXPORTED, 0);
 		if (vg_read_error(vg_to)) {
 			log_error("Volume group \"%s\" became inconsistent: "
 				  "please fix manually", vg_name_to);


