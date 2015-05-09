From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat,  9 May 2015 00:03:15 +0000 (UTC)
Subject: master - lvmpolld: Add standalone polldaemon.
Message-ID: <20150509000315.209EB60D95@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e587b0677b705786a78f21bac1966621f70b2752
Commit:        e587b0677b705786a78f21bac1966621f70b2752
Parent:        be23fae488b7df19147259d3e8505fc8301076cd
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Sat May 9 00:59:18 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat May 9 00:59:18 2015 +0100

lvmpolld: Add standalone polldaemon.

See doc/lvmpolld_overview.txt
---
 WHATS_NEW                                         |    2 +
 conf/example.conf.in                              |   10 +
 configure                                         |   49 ++-
 configure.in                                      |   30 +
 daemons/Makefile.in                               |   10 +-
 daemons/lvmpolld/Makefile.in                      |   49 ++
 daemons/lvmpolld/lvmpolld-cmd-utils.c             |  140 ++++
 daemons/lvmpolld/lvmpolld-cmd-utils.h             |   25 +
 daemons/lvmpolld/lvmpolld-common.h                |   36 +
 daemons/lvmpolld/lvmpolld-core.c                  |  817 +++++++++++++++++++++
 daemons/lvmpolld/lvmpolld-data-utils.c            |  388 ++++++++++
 daemons/lvmpolld/lvmpolld-data-utils.h            |  215 ++++++
 daemons/lvmpolld/lvmpolld-protocol.h              |   49 ++
 daemons/lvmpolld/polling_ops.h                    |   25 +
 doc/lvmpolld_overview.txt                         |   81 ++
 include/.symlinks.in                              |    4 +
 lib/Makefile.in                                   |    5 +
 lib/commands/toolcontext.c                        |   11 +
 lib/config/config_settings.h                      |    9 +
 lib/lvmpolld/lvmpolld-client.c                    |  311 ++++++++
 lib/lvmpolld/lvmpolld-client.h                    |   52 ++
 lib/lvmpolld/polldaemon.h                         |   93 +++
 lib/misc/configure.h.in                           |    6 +
 libdaemon/Makefile.in                             |    2 +-
 make.tmpl.in                                      |    2 +-
 man/Makefile.in                                   |    8 +-
 man/lvm.8.in                                      |    6 +
 man/lvmpolld.8.in                                 |   86 +++
 scripts/.gitignore                                |    3 +
 scripts/Makefile.in                               |    9 +
 scripts/lvm2_lvmpolld_init_red_hat.in             |  114 +++
 scripts/lvm2_lvmpolld_systemd_red_hat.service.in  |   17 +
 scripts/lvm2_lvmpolld_systemd_red_hat.socket.in   |   12 +
 scripts/lvmdump.sh                                |   24 +-
 test/Makefile.in                                  |   28 +-
 test/lib/aux.sh                                   |  100 +++-
 test/lib/flavour-ndev-cluster-lvmpolld.sh         |    2 +
 test/lib/flavour-ndev-lvmetad-lvmpolld.sh         |    3 +
 test/lib/flavour-ndev-lvmpolld.sh                 |    2 +
 test/lib/flavour-udev-cluster-lvmpolld.sh         |    3 +
 test/lib/flavour-udev-lvmetad-lvmpolld.sh         |    4 +
 test/lib/flavour-udev-lvmpolld.sh                 |    3 +
 test/lib/inittest.sh                              |    7 +
 test/shell/000-basic.sh                           |    2 +
 test/shell/activate-minor.sh                      |    1 +
 test/shell/activate-missing-segment.sh            |    2 +
 test/shell/activate-missing.sh                    |    2 +
 test/shell/activate-partial.sh                    |    2 +
 test/shell/activation-skip.sh                     |    2 +
 test/shell/clvmd-restart.sh                       |    1 +
 test/shell/covercmd.sh                            |    2 +
 test/shell/discards-thin.sh                       |    2 +
 test/shell/dmeventd-restart.sh                    |    2 +
 test/shell/dumpconfig.sh                          |    2 +
 test/shell/error-usage.sh                         |    2 +
 test/shell/fsadm.sh                               |    2 +
 test/shell/inconsistent-metadata.sh               |    2 +
 test/shell/listings.sh                            |    2 +
 test/shell/lock-blocking.sh                       |    4 +-
 test/shell/lock-parallel.sh                       |    2 +
 test/shell/lvchange-cache.sh                      |    2 +
 test/shell/lvchange-mirror.sh                     |    2 +
 test/shell/lvchange-partial-raid10.sh             |    2 +
 test/shell/lvchange-partial.sh                    |    1 +
 test/shell/lvchange-raid10.sh                     |    2 +
 test/shell/lvchange-raid456.sh                    |    2 +
 test/shell/lvchange-syncaction-raid.sh            |    2 +
 test/shell/lvchange-thin.sh                       |    2 +
 test/shell/lvconvert-cache-raid.sh                |    2 +
 test/shell/lvconvert-cache-thin.sh                |    2 +
 test/shell/lvconvert-cache.sh                     |    2 +
 test/shell/lvconvert-raid-allocation.sh           |    2 +
 test/shell/lvconvert-raid.sh                      |    2 +
 test/shell/lvconvert-raid10.sh                    |    2 +
 test/shell/lvconvert-raid456.sh                   |    2 +
 test/shell/lvconvert-repair-dmeventd.sh           |    2 +
 test/shell/lvconvert-repair-raid-dmeventd.sh      |    2 +
 test/shell/lvconvert-repair-raid.sh               |    2 +
 test/shell/lvconvert-repair-snapshot.sh           |    2 +
 test/shell/lvconvert-repair-thin.sh               |    2 +
 test/shell/lvconvert-repair-transient-dmeventd.sh |    2 +
 test/shell/lvconvert-repair-transient.sh          |    2 +
 test/shell/lvconvert-snapshot.sh                  |    2 +
 test/shell/lvconvert-thin-external.sh             |    2 +
 test/shell/lvconvert-thin-raid.sh                 |    2 +
 test/shell/lvconvert-thin.sh                      |    2 +
 test/shell/lvcreate-cache.sh                      |    2 +
 test/shell/lvcreate-large-raid.sh                 |    2 +
 test/shell/lvcreate-large-raid10.sh               |    2 +
 test/shell/lvcreate-large.sh                      |    2 +
 test/shell/lvcreate-mirror.sh                     |    3 +
 test/shell/lvcreate-missing.sh                    |    2 +
 test/shell/lvcreate-operation.sh                  |    2 +
 test/shell/lvcreate-pvtags.sh                     |    2 +
 test/shell/lvcreate-raid.sh                       |    2 +
 test/shell/lvcreate-raid10.sh                     |    2 +
 test/shell/lvcreate-repair.sh                     |    2 +
 test/shell/lvcreate-signature-wiping.sh           |    2 +
 test/shell/lvcreate-small-snap.sh                 |    2 +
 test/shell/lvcreate-striped-mirror.sh             |    2 +
 test/shell/lvcreate-thin-big.sh                   |    2 +
 test/shell/lvcreate-thin-external.sh              |    2 +
 test/shell/lvcreate-thin-power2.sh                |    2 +
 test/shell/lvcreate-thin-snap.sh                  |    2 +
 test/shell/lvcreate-thin.sh                       |    2 +
 test/shell/lvextend-percent-extents.sh            |    2 +
 test/shell/lvextend-snapshot-dmeventd.sh          |    2 +
 test/shell/lvextend-snapshot-policy.sh            |    2 +
 test/shell/lvextend-thin-metadata-dmeventd.sh     |    2 +
 test/shell/lvextend-thin.sh                       |    2 +
 test/shell/lvm-init.sh                            |    2 +
 test/shell/lvmcache-exercise.sh                   |    2 +
 test/shell/lvmetad-ambiguous.sh                   |    1 +
 test/shell/lvmetad-client-filter.sh               |    2 +
 test/shell/lvmetad-disabled.sh                    |    2 +
 test/shell/lvmetad-dump.sh                        |    2 +
 test/shell/lvmetad-lvm1.sh                        |    2 +
 test/shell/lvmetad-lvscan-cache.sh                |    1 +
 test/shell/lvmetad-no-cluster.sh                  |    2 +
 test/shell/lvmetad-override.sh                    |    2 +
 test/shell/lvmetad-pvs.sh                         |    2 +
 test/shell/lvmetad-pvscan-cache.sh                |    1 +
 test/shell/lvmetad-pvscan-filter.sh               |    1 +
 test/shell/lvmetad-pvscan-md.sh                   |    1 +
 test/shell/lvmetad-pvscan-nomda.sh                |    2 +
 test/shell/lvmetad-restart.sh                     |    2 +
 test/shell/lvmetad-test.sh                        |    2 +
 test/shell/lvmetad-warning.sh                     |    2 +
 test/shell/lvresize-mirror.sh                     |    2 +
 test/shell/lvresize-raid.sh                       |    2 +
 test/shell/lvresize-raid10.sh                     |    2 +
 test/shell/lvresize-rounding.sh                   |    2 +
 test/shell/lvresize-thin-external-origin.sh       |    2 +
 test/shell/lvresize-thin-metadata.sh              |    2 +
 test/shell/lvresize-usage.sh                      |    2 +
 test/shell/lvs-cache.sh                           |    2 +
 test/shell/mda-rollback.sh                        |    2 +
 test/shell/mdata-strings.sh                       |    2 +
 test/shell/metadata-balance.sh                    |    2 +
 test/shell/metadata-dirs.sh                       |    2 +
 test/shell/metadata.sh                            |    2 +
 test/shell/mirror-names.sh                        |   18 +
 test/shell/mirror-vgreduce-removemissing.sh       |    2 +
 test/shell/name-mangling.sh                       |    1 +
 test/shell/nomda-missing.sh                       |    2 +
 test/shell/nomda-restoremissing.sh                |    2 +
 test/shell/orphan-ondisk.sh                       |    2 +
 test/shell/pool-labels.sh                         |    1 +
 test/shell/process-each-duplicate-vgnames.sh      |    2 +
 test/shell/process-each-lv.sh                     |    2 +
 test/shell/process-each-pv-nomda-all.sh           |    2 +
 test/shell/process-each-pv-nomda.sh               |    2 +
 test/shell/process-each-pv.sh                     |    2 +
 test/shell/process-each-pvresize.sh               |    2 +
 test/shell/process-each-vg.sh                     |    2 +
 test/shell/profiles-thin.sh                       |    2 +
 test/shell/profiles.sh                            |    2 +
 test/shell/pv-duplicate-uuid.sh                   |    2 +
 test/shell/pv-duplicate.sh                        |    2 +
 test/shell/pv-min-size.sh                         |    2 +
 test/shell/pvchange-usage.sh                      |    2 +
 test/shell/pvcreate-bootloaderarea.sh             |    2 +
 test/shell/pvcreate-ff.sh                         |    2 +
 test/shell/pvcreate-metadata0.sh                  |    2 +
 test/shell/pvcreate-operation-md.sh               |    2 +
 test/shell/pvcreate-operation.sh                  |    2 +
 test/shell/pvcreate-usage.sh                      |    2 +
 test/shell/pvmove-restart.sh                      |    8 +-
 test/shell/pvmove-resume-1.sh                     |   64 ++-
 test/shell/pvmove-resume-2.sh                     |   42 +-
 test/shell/pvmove-resume-multiseg.sh              |   48 ++-
 test/shell/pvremove-thin.sh                       |    2 +
 test/shell/pvremove-usage.sh                      |    2 +
 test/shell/pvremove-warnings.sh                   |    2 +
 test/shell/read-ahead.sh                          |    2 +
 test/shell/select-report.sh                       |    2 +
 test/shell/select-tools-thin.sh                   |    2 +
 test/shell/select-tools.sh                        |    2 +
 test/shell/snapshot-autoumount-dmeventd.sh        |    2 +
 test/shell/snapshot-cluster.sh                    |    2 +
 test/shell/snapshot-lvm1.sh                       |    2 +
 test/shell/snapshot-maxsize.sh                    |    2 +
 test/shell/snapshot-reactivate.sh                 |    2 +
 test/shell/snapshot-rename.sh                     |    2 +
 test/shell/snapshot-usage-exa.sh                  |    2 +
 test/shell/snapshot-usage.sh                      |    2 +
 test/shell/stray-device-node.sh                   |    2 +
 test/shell/system_id.sh                           |    2 +
 test/shell/tags.sh                                |    2 +
 test/shell/test-partition.sh                      |    2 +
 test/shell/thin-autoumount-dmeventd.sh            |    2 +
 test/shell/thin-defaults.sh                       |    2 +
 test/shell/thin-restore.sh                        |    2 +
 test/shell/thin-volume-list.sh                    |    2 +
 test/shell/topology-support.sh                    |    2 +
 test/shell/unknown-segment.sh                     |    2 +
 test/shell/unlost-pv.sh                           |    2 +
 test/shell/vg-name-from-env.sh                    |    2 +
 test/shell/vgcfgbackup-usage.sh                   |    2 +
 test/shell/vgchange-many.sh                       |    2 +
 test/shell/vgchange-maxlv.sh                      |    2 +
 test/shell/vgchange-partial.sh                    |    2 +
 test/shell/vgchange-sysinit.sh                    |    1 +
 test/shell/vgchange-usage.sh                      |    2 +
 test/shell/vgck.sh                                |    2 +
 test/shell/vgcreate-many-pvs.sh                   |    2 +
 test/shell/vgcreate-usage.sh                      |    2 +
 test/shell/vgextend-restoremissing.sh             |    2 +
 test/shell/vgextend-usage.sh                      |    2 +
 test/shell/vgimportclone.sh                       |    2 +
 test/shell/vgmerge-operation.sh                   |    2 +
 test/shell/vgmerge-usage.sh                       |    2 +
 test/shell/vgreduce-usage.sh                      |    2 +
 test/shell/vgremove-corrupt-vg.sh                 |    2 +
 test/shell/vgrename-usage.sh                      |    2 +
 test/shell/vgsplit-operation.sh                   |    2 +
 test/shell/vgsplit-raid.sh                        |    2 +
 test/shell/vgsplit-stacked.sh                     |    2 +
 test/shell/vgsplit-thin.sh                        |    2 +
 test/shell/vgsplit-usage.sh                       |    2 +
 test/shell/zero-usage.sh                          |    2 +
 tools/Makefile.in                                 |    3 +-
 tools/args.h                                      |    2 +
 tools/commands.h                                  |   16 +
 tools/lvpoll.c                                    |  115 +++
 tools/polldaemon.c                                |  181 +++++-
 tools/polldaemon.h                                |   93 ---
 tools/pvmove.c                                    |    2 +-
 228 files changed, 3640 insertions(+), 142 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 24f0c76..7052016 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.120 -
 ===============================
+  Add lvpoll for cmdline communication with lvmpolld.
+  Add lvmpolld acting as a free-standing version of polldaemon.
   Properly validate PV size for pvcreate --restorefile.
   Fix check if pvcreate wiped device (2.02.117).
   Fix storing of vgid when caching metadata (2.02.118).
diff --git a/conf/example.conf.in b/conf/example.conf.in
index c1a8f03..e16aa7f 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -938,6 +938,16 @@ global {
 	# Comments starting with the character # are ignored.
 	# This configuration option does not have a default value defined.
 	# system_id_file = ""
+
+	# Indicates whether to use lvmpolld instead of classical polldaemon (a process
+	# forked off an initiating lvm command) or not. When set to 1 and native systemd
+	# service is installed in the system lvm starts using lvmpolld. lvmpolld gets
+	# auto-activated by systemd when a message lands on the respective lvmpolld socket.
+	# All commands that would require polling of in-progress operation are therefore
+	# spawned in lvmpolld's service cgroup.
+	#
+	# When set to 0 lvm falls back to classical polling.
+	use_lvmpolld = 0
 }
 
 # Configuration section activation.
diff --git a/configure b/configure
index 51a8f35..8c51c71 100755
--- a/configure
+++ b/configure
@@ -636,6 +636,7 @@ kerneldir
 interface
 CMIRRORD_PIDFILE
 CLVMD_PIDFILE
+LVMPOLLD_PIDFILE
 LVMETAD_PIDFILE
 DMEVENTD_PIDFILE
 WRITE_INSTALL
@@ -724,6 +725,7 @@ CLDWHOLEARCHIVE
 CLDNOWHOLEARCHIVE
 CLDFLAGS
 CACHE
+BUILD_LVMPOLLD
 BUILD_LVMETAD
 BUILD_DMEVENTD
 BUILD_CMIRRORD
@@ -914,6 +916,8 @@ enable_valgrind_pool
 enable_devmapper
 enable_lvmetad
 with_lvmetad_pidfile
+enable_lvmpolld
+with_lvmpolld_pidfile
 enable_blkid_wiping
 enable_udev_systemd_background_jobs
 enable_udev_sync
@@ -1627,6 +1631,7 @@ Optional Features:
   --enable-valgrind-pool  enable valgrind awareness of pools
   --disable-devmapper     disable LVM2 device-mapper interaction
   --enable-lvmetad        enable the LVM Metadata Daemon
+  --enable-lvmpolld       enable the LVM Polling Daemon
   --disable-blkid_wiping  disable libblkid detection of signatures when wiping
                           and use native code instead
   --disable-udev-systemd-background-jobs
@@ -1718,6 +1723,8 @@ Optional Packages:
   --with-optimisation=OPT C optimisation flag [OPT=-O2]
   --with-lvmetad-pidfile=PATH
                           lvmetad pidfile [PID_DIR/lvmetad.pid]
+  --with-lvmpolld-pidfile=PATH
+                          lvmpolld pidfile [PID_DIR/lvmpolld.pid]
   --with-localedir=DIR    translation files in DIR [PREFIX/share/locale]
   --with-confdir=DIR      configuration files in DIR [/etc]
   --with-staticdir=DIR    static binaries in DIR [EPREFIX/sbin]
@@ -3033,6 +3040,7 @@ case "$host_os" in
 		LIB_SUFFIX=so
 		DEVMAPPER=yes
 		LVMETAD=no
+		LVMPOLLD=no
 		ODIRECT=yes
 		DM_IOCTLS=yes
 		SELINUX=yes
@@ -10856,6 +10864,39 @@ _ACEOF
 fi
 
 ################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build lvmpolld" >&5
+$as_echo_n "checking whether to build lvmpolld... " >&6; }
+# Check whether --enable-lvmpolld was given.
+if test "${enable_lvmpolld+set}" = set; then :
+  enableval=$enable_lvmpolld; LVMPOLLD=$enableval
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $LVMPOLLD" >&5
+$as_echo "$LVMPOLLD" >&6; }
+
+BUILD_LVMPOLLD=$LVMPOLLD
+
+if test "$BUILD_LVMPOLLD" = yes; then
+
+$as_echo "#define LVMPOLLD_SUPPORT 1" >>confdefs.h
+
+
+
+# Check whether --with-lvmpolld-pidfile was given.
+if test "${with_lvmpolld_pidfile+set}" = set; then :
+  withval=$with_lvmpolld_pidfile; LVMPOLLD_PIDFILE=$withval
+else
+  LVMPOLLD_PIDFILE="$DEFAULT_PID_DIR/lvmpolld.pid"
+fi
+
+
+cat >>confdefs.h <<_ACEOF
+#define LVMPOLLD_PIDFILE "$LVMPOLLD_PIDFILE"
+_ACEOF
+
+fi
+
+################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable libblkid detection of signatures when wiping" >&5
 $as_echo_n "checking whether to enable libblkid detection of signatures when wiping... " >&6; }
 # Check whether --enable-blkid_wiping was given.
@@ -13147,8 +13188,10 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
+
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/M
 akefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile daemons/lvmpolld/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile 
 liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/
 Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -13857,6 +13900,7 @@ do
     "daemons/dmeventd/plugins/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/snapshot/Makefile" ;;
     "daemons/dmeventd/plugins/thin/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/thin/Makefile" ;;
     "daemons/lvmetad/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmetad/Makefile" ;;
+    "daemons/lvmpolld/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmpolld/Makefile" ;;
     "conf/Makefile") CONFIG_FILES="$CONFIG_FILES conf/Makefile" ;;
     "conf/example.conf") CONFIG_FILES="$CONFIG_FILES conf/example.conf" ;;
     "conf/lvmlocal.conf") CONFIG_FILES="$CONFIG_FILES conf/lvmlocal.conf" ;;
@@ -13900,6 +13944,9 @@ do
     "scripts/lvm2_lvmetad_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_init_red_hat" ;;
     "scripts/lvm2_lvmetad_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_systemd_red_hat.service" ;;
     "scripts/lvm2_lvmetad_systemd_red_hat.socket") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_systemd_red_hat.socket" ;;
+    "scripts/lvm2_lvmpolld_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmpolld_init_red_hat" ;;
+    "scripts/lvm2_lvmpolld_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmpolld_systemd_red_hat.service" ;;
+    "scripts/lvm2_lvmpolld_systemd_red_hat.socket") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmpolld_systemd_red_hat.socket" ;;
     "scripts/lvm2_monitoring_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_monitoring_init_red_hat" ;;
     "scripts/lvm2_monitoring_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_monitoring_systemd_red_hat.service" ;;
     "scripts/lvm2_pvscan_systemd_red_hat at .service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_pvscan_systemd_red_hat at .service" ;;
diff --git a/configure.in b/configure.in
index a14540f..1887757 100644
--- a/configure.in
+++ b/configure.in
@@ -39,6 +39,7 @@ case "$host_os" in
 		LIB_SUFFIX=so
 		DEVMAPPER=yes
 		LVMETAD=no
+		LVMPOLLD=no
 		ODIRECT=yes
 		DM_IOCTLS=yes
 		SELINUX=yes
@@ -1078,6 +1079,29 @@ if test "$BUILD_LVMETAD" = yes; then
 fi
 
 ################################################################################
+dnl -- Build lvmpolld
+AC_MSG_CHECKING(whether to build lvmpolld)
+AC_ARG_ENABLE(lvmpolld,
+	      AC_HELP_STRING([--enable-lvmpolld],
+			     [enable the LVM Polling Daemon]),
+	      LVMPOLLD=$enableval)
+AC_MSG_RESULT($LVMPOLLD)
+
+BUILD_LVMPOLLD=$LVMPOLLD
+
+if test "$BUILD_LVMPOLLD" = yes; then
+	AC_DEFINE([LVMPOLLD_SUPPORT], 1, [Define to 1 to include code that uses lvmpolld.])
+
+	AC_ARG_WITH(lvmpolld-pidfile,
+		    AC_HELP_STRING([--with-lvmpolld-pidfile=PATH],
+				   [lvmpolld pidfile [PID_DIR/lvmpolld.pid]]),
+		    LVMPOLLD_PIDFILE=$withval,
+		    LVMPOLLD_PIDFILE="$DEFAULT_PID_DIR/lvmpolld.pid")
+	AC_DEFINE_UNQUOTED(LVMPOLLD_PIDFILE, ["$LVMPOLLD_PIDFILE"],
+			   [Path to lvmpolld pidfile.])
+fi
+
+################################################################################
 dnl -- Enable blkid wiping functionality
 AC_MSG_CHECKING(whether to enable libblkid detection of signatures when wiping)
 AC_ARG_ENABLE(blkid_wiping,
@@ -1687,6 +1711,7 @@ AC_SUBST(BLKID_WIPING)
 AC_SUBST(BUILD_CMIRRORD)
 AC_SUBST(BUILD_DMEVENTD)
 AC_SUBST(BUILD_LVMETAD)
+AC_SUBST(BUILD_LVMPOLLD)
 AC_SUBST(CACHE)
 AC_SUBST(CFLAGS)
 AC_SUBST(CFLOW_CMD)
@@ -1805,6 +1830,7 @@ AC_SUBST(VALGRIND_POOL)
 AC_SUBST(WRITE_INSTALL)
 AC_SUBST(DMEVENTD_PIDFILE)
 AC_SUBST(LVMETAD_PIDFILE)
+AC_SUBST(LVMPOLLD_PIDFILE)
 AC_SUBST(CLVMD_PIDFILE)
 AC_SUBST(CMIRRORD_PIDFILE)
 AC_SUBST(interface)
@@ -1838,6 +1864,7 @@ daemons/dmeventd/plugins/mirror/Makefile
 daemons/dmeventd/plugins/snapshot/Makefile
 daemons/dmeventd/plugins/thin/Makefile
 daemons/lvmetad/Makefile
+daemons/lvmpolld/Makefile
 conf/Makefile
 conf/example.conf
 conf/lvmlocal.conf
@@ -1881,6 +1908,9 @@ scripts/lvm2_cmirrord_systemd_red_hat.service
 scripts/lvm2_lvmetad_init_red_hat
 scripts/lvm2_lvmetad_systemd_red_hat.service
 scripts/lvm2_lvmetad_systemd_red_hat.socket
+scripts/lvm2_lvmpolld_init_red_hat
+scripts/lvm2_lvmpolld_systemd_red_hat.service
+scripts/lvm2_lvmpolld_systemd_red_hat.socket
 scripts/lvm2_monitoring_init_red_hat
 scripts/lvm2_monitoring_systemd_red_hat.service
 scripts/lvm2_pvscan_systemd_red_hat@.service
diff --git a/daemons/Makefile.in b/daemons/Makefile.in
index 9a73516..8a466b3 100644
--- a/daemons/Makefile.in
+++ b/daemons/Makefile.in
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -15,7 +15,7 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-.PHONY: dmeventd clvmd cmirrord lvmetad
+.PHONY: dmeventd clvmd cmirrord lvmetad lvmpolld
 
 ifneq ("@CLVMD@", "none")
   SUBDIRS += clvmd
@@ -36,8 +36,12 @@ ifeq ("@BUILD_LVMETAD@", "yes")
   SUBDIRS += lvmetad
 endif
 
+ifeq ("@BUILD_LVMPOLLD@", "yes")
+  SUBDIRS += lvmpolld
+endif
+
 ifeq ($(MAKECMDGOALS),distclean)
-  SUBDIRS = clvmd cmirrord dmeventd lvmetad
+  SUBDIRS = clvmd cmirrord dmeventd lvmetad lvmpolld
 endif
 
 include $(top_builddir)/make.tmpl
diff --git a/daemons/lvmpolld/Makefile.in b/daemons/lvmpolld/Makefile.in
new file mode 100644
index 0000000..55f3dad
--- /dev/null
+++ b/daemons/lvmpolld/Makefile.in
@@ -0,0 +1,49 @@
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
+SOURCES = lvmpolld-core.c lvmpolld-data-utils.c lvmpolld-cmd-utils.c
+
+TARGETS = lvmpolld
+
+.PHONY: install_lvmpolld
+
+CFLOW_LIST = $(SOURCES)
+CFLOW_LIST_TARGET = $(LIB_NAME).cflow
+CFLOW_TARGET = lvmpolld
+
+include $(top_builddir)/make.tmpl
+
+INCLUDES += -I$(top_srcdir)/libdaemon/server
+LVMLIBS = -ldaemonserver $(LVMINTERNAL_LIBS) -ldevmapper
+
+LIBS += $(PTHREAD_LIBS)
+
+LDFLAGS += -L$(top_builddir)/libdaemon/server $(DAEMON_LDFLAGS)
+CLDFLAGS += -L$(top_builddir)/libdaemon/server
+CFLAGS += $(DAEMON_CFLAGS)
+
+lvmpolld: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
+		    $(top_builddir)/libdaemon/server/libdaemonserver.a
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) \
+	$(DL_LIBS) $(LVMLIBS) $(LIBS)
+
+install_lvmpolld: lvmpolld
+	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
+
+install_lvm2: install_lvmpolld
+
+install: install_lvm2
diff --git a/daemons/lvmpolld/lvmpolld-cmd-utils.c b/daemons/lvmpolld/lvmpolld-cmd-utils.c
new file mode 100644
index 0000000..cd789a3
--- /dev/null
+++ b/daemons/lvmpolld/lvmpolld-cmd-utils.c
@@ -0,0 +1,140 @@
+/*
+ * Copyright (C) 2015 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "lvmpolld-common.h"
+
+/* extract this info from autoconf/automake files */
+#define LVPOLL_CMD "lvpoll"
+
+#define MIN_ARGV_SIZE  8
+
+static const char *const const polling_ops[] = { [PVMOVE] = LVMPD_REQ_PVMOVE,
+						 [CONVERT] = LVMPD_REQ_CONVERT,
+						 [MERGE] = LVMPD_REQ_MERGE,
+						 [MERGE_THIN] = LVMPD_REQ_MERGE_THIN };
+
+const char *polling_op(enum poll_type type)
+{
+	return type < POLL_TYPE_MAX ? polling_ops[type] : "<undefined>";
+}
+
+static int add_to_cmd_arr(const char ***cmdargv, const char *str, unsigned *ind)
+{
+	const char **newargv = *cmdargv;
+
+	if (*ind && !(*ind % MIN_ARGV_SIZE)) {
+		newargv = dm_realloc(*cmdargv, (*ind / MIN_ARGV_SIZE + 1) * MIN_ARGV_SIZE * sizeof(char *));
+		if (!newargv)
+			return 0;
+		*cmdargv = newargv;
+	}
+
+	*(*cmdargv + (*ind)++) = str;
+
+	return 1;
+}
+
+const char **cmdargv_ctr(const struct lvmpolld_lv *pdlv, const char *lvm_binary, unsigned abort_polling, unsigned handle_missing_pvs)
+{
+	unsigned i = 0;
+	const char **cmd_argv = dm_malloc(MIN_ARGV_SIZE * sizeof(char *));
+
+	if (!cmd_argv)
+		return NULL;
+
+	/* path to lvm2 binary */
+	if (!add_to_cmd_arr(&cmd_argv, lvm_binary, &i))
+		goto err;
+
+	/* cmd to execute */
+	if (!add_to_cmd_arr(&cmd_argv, LVPOLL_CMD, &i))
+		goto err;
+
+	/* transfer internal polling interval */
+	if (pdlv->sinterval &&
+	    (!add_to_cmd_arr(&cmd_argv, "--interval", &i) ||
+	     !add_to_cmd_arr(&cmd_argv, pdlv->sinterval, &i)))
+		goto err;
+
+	/* pass abort param */
+	if (abort_polling &&
+	    !add_to_cmd_arr(&cmd_argv, "--abort", &i))
+		goto err;
+
+	/* pass handle-missing-pvs. used by mirror polling operation */
+	if (handle_missing_pvs &&
+	    !add_to_cmd_arr(&cmd_argv, "--handlemissingpvs", &i))
+		goto err;
+
+	/* one of: "convert", "pvmove", "merge", "merge_thin" */
+	if (!add_to_cmd_arr(&cmd_argv, "--polloperation", &i) ||
+	    !add_to_cmd_arr(&cmd_argv, polling_ops[pdlv->type], &i))
+		goto err;
+
+	/* vg/lv name */
+	if (!add_to_cmd_arr(&cmd_argv, pdlv->lvname, &i))
+		goto err;
+
+	/* terminating NULL */
+	if (!add_to_cmd_arr(&cmd_argv, NULL, &i))
+		goto err;
+
+	return cmd_argv;
+err:
+	dm_free(cmd_argv);
+	return NULL;
+}
+
+/* FIXME: in fact exclude should be va list */
+static int copy_env(const char ***cmd_envp, unsigned *i, const char *exclude)
+{
+	const char * const* tmp = (const char * const*) environ;
+
+	if (!tmp)
+		return 0;
+
+	while (*tmp) {
+		if (strncmp(*tmp, exclude, strlen(exclude)) && !add_to_cmd_arr(cmd_envp, *tmp, i))
+			return 0;
+		tmp++;
+	}
+
+	return 1;
+}
+
+const char **cmdenvp_ctr(const struct lvmpolld_lv *pdlv)
+{
+	unsigned i = 0;
+	const char **cmd_envp = dm_malloc(MIN_ARGV_SIZE * sizeof(char *));
+
+	if (!cmd_envp)
+		return NULL;
+
+	/* copy whole environment from lvmpolld, exclude LVM_SYSTEM_DIR if set */
+	if (!copy_env(&cmd_envp, &i, "LVM_SYSTEM_DIR="))
+		goto err;
+
+	/* Add per client LVM_SYSTEM_DIR variable if set */
+	if (*pdlv->lvm_system_dir_env && !add_to_cmd_arr(&cmd_envp, pdlv->lvm_system_dir_env, &i))
+		goto err;
+
+	/* terminating NULL */
+	if (!add_to_cmd_arr(&cmd_envp, NULL, &i))
+		goto err;
+
+	return cmd_envp;
+err:
+	dm_free(cmd_envp);
+	return NULL;
+}
diff --git a/daemons/lvmpolld/lvmpolld-cmd-utils.h b/daemons/lvmpolld/lvmpolld-cmd-utils.h
new file mode 100644
index 0000000..509c2e9
--- /dev/null
+++ b/daemons/lvmpolld/lvmpolld-cmd-utils.h
@@ -0,0 +1,25 @@
+/*
+ * Copyright (C) 2015 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef _LVM_LVMPOLLD_CMD_UTILS_H
+#define _LVM_LVMPOLLD_CMD_UTILS_H
+
+#include "lvmpolld-data-utils.h"
+
+const char **cmdargv_ctr(const struct lvmpolld_lv *pdlv, const char *lvm_binary, unsigned abort, unsigned handle_missing_pvs);
+const char **cmdenvp_ctr(const struct lvmpolld_lv *pdlv);
+
+const char *polling_op(enum poll_type);
+
+#endif /* _LVM_LVMPOLLD_CMD_UTILS_H */
diff --git a/daemons/lvmpolld/lvmpolld-common.h b/daemons/lvmpolld/lvmpolld-common.h
new file mode 100644
index 0000000..81423f0
--- /dev/null
+++ b/daemons/lvmpolld/lvmpolld-common.h
@@ -0,0 +1,36 @@
+/*
+ * Copyright (C) 2010-2015 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+/*
+ * This file must be included first by every lvmpolld source file.
+ */
+#ifndef _LVM_LVMPOLLD_COMMON_H
+#define _LVM_LVMPOLLD_COMMON_H
+
+#include "configure.h"
+
+#define _REENTRANT
+#define _GNU_SOURCE
+#define _FILE_OFFSET_BITS 64
+
+#include "libdevmapper.h"
+
+#include "lvmpolld-cmd-utils.h"
+#include "lvmpolld-protocol.h"
+
+#include <assert.h>
+#include <errno.h>
+#include <unistd.h>
+
+#endif	/* _LVM_LVMPOLLD_COMMON_H */
diff --git a/daemons/lvmpolld/lvmpolld-core.c b/daemons/lvmpolld/lvmpolld-core.c
new file mode 100644
index 0000000..a770f89
--- /dev/null
+++ b/daemons/lvmpolld/lvmpolld-core.c
@@ -0,0 +1,817 @@
+/*
+ * Copyright (C) 2014-2015 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "lvmpolld-common.h"
+
+#include "lvm-version.h"
+#include "daemon-server.h"
+#include "daemon-log.h"
+
+#include <poll.h>
+#include <wait.h>
+
+#define LVMPOLLD_SOCKET DEFAULT_RUN_DIR "/lvmpolld.socket"
+
+#define PD_LOG_PREFIX "LVMPOLLD"
+#define LVM2_LOG_PREFIX "\tLVPOLL"
+
+/* predefined reason for response = "failed" case */
+#define REASON_REQ_NOT_IMPLEMENTED "request not implemented"
+#define REASON_MISSING_LVID "request requires lvid set"
+#define REASON_MISSING_LVNAME "request requires lvname set"
+#define REASON_MISSING_VGNAME "request requires vgname set"
+#define REASON_POLLING_FAILED "polling of lvm command failed"
+#define REASON_ILLEGAL_ABORT_REQUEST "abort only supported with PVMOVE polling operation"
+#define REASON_DIFFERENT_OPERATION_IN_PROGRESS "Different operation on LV already in progress"
+#define REASON_INVALID_INTERVAL "request requires interval set"
+#define REASON_ENOMEM "not enough memory"
+
+struct lvmpolld_state {
+	daemon_idle *idle;
+	log_state *log;
+	const char *log_config;
+	const char *lvm_binary;
+
+	struct lvmpolld_store *id_to_pdlv_abort;
+	struct lvmpolld_store *id_to_pdlv_poll;
+};
+
+static pthread_key_t key;
+
+static const char *_strerror_r(int errnum, struct lvmpolld_thread_data *data)
+{
+#ifdef _GNU_SOURCE
+	return strerror_r(errnum, data->buf, sizeof(data->buf)); /* never returns NULL */
+#elif (_POSIX_C_SOURCE >= 200112L || _XOPEN_SOURCE >= 600)
+	return strerror_r(errnum, data->buf, sizeof(data->buf)) ? "" : data->buf;
+#else
+#	warning "Can't decide proper strerror_r implementation. lvmpolld will not issue specific system error messages"
+	return "";
+#endif
+}
+
+static void usage(const char *prog, FILE *file)
+{
+	fprintf(file, "Usage:\n"
+		"%s [-V] [-h] [-f] [-l {all|wire|debug}] [-s path]\n\n"
+		"   -V       Show version info\n"
+		"   -h       Show this help information\n"
+		"   -f       Don't fork, run in the foreground\n"
+		"   -l       Logging message level (-l {all|wire|debug})\n"
+		"   -p       Set path to the pidfile\n"
+		"   -s       Set path to the socket to listen on\n"
+		"   -B       Path to lvm2 binary\n"
+		"   -t       Time to wait in seconds before shutdown on idle (missing or 0 = inifinite)\n\n", prog);
+}
+
+static int init(struct daemon_state *s)
+{
+	struct lvmpolld_state *ls = s->private;
+	ls->log = s->log;
+
+	if (!daemon_log_parse(ls->log, DAEMON_LOG_OUTLET_STDERR, ls->log_config, 1))
+		return 0;
+
+	if (pthread_key_create(&key, lvmpolld_thread_data_destroy)) {
+		FATAL(ls, "%s: %s", PD_LOG_PREFIX, "Failed to create pthread key");
+		return 0;
+	}
+
+	ls->id_to_pdlv_poll = pdst_init("polling");
+	ls->id_to_pdlv_abort = pdst_init("abort");
+
+	if (!ls->id_to_pdlv_poll || !ls->id_to_pdlv_abort) {
+		FATAL(ls, "%s: %s", PD_LOG_PREFIX, "Failed to allocate internal data structures");
+		return 0;
+	}
+
+	ls->lvm_binary = ls->lvm_binary ?: LVM_PATH;
+
+	if (access(ls->lvm_binary, X_OK)) {
+		FATAL(ls, "%s: %s %s", PD_LOG_PREFIX, "Execute access rights denied on", ls->lvm_binary);
+		return 0;
+	}
+
+	if (ls->idle)
+		ls->idle->is_idle = 1;
+
+	return 1;
+}
+
+static void lvmpolld_stores_lock(struct lvmpolld_state *ls)
+{
+	pdst_lock(ls->id_to_pdlv_poll);
+	pdst_lock(ls->id_to_pdlv_abort);
+}
+
+static void lvmpolld_stores_unlock(struct lvmpolld_state *ls)
+{
+	pdst_unlock(ls->id_to_pdlv_abort);
+	pdst_unlock(ls->id_to_pdlv_poll);
+}
+
+static void lvmpolld_global_lock(struct lvmpolld_state *ls)
+{
+	lvmpolld_stores_lock(ls);
+
+	pdst_locked_lock_all_pdlvs(ls->id_to_pdlv_poll);
+	pdst_locked_lock_all_pdlvs(ls->id_to_pdlv_abort);
+}
+
+static void lvmpolld_global_unlock(struct lvmpolld_state *ls)
+{
+	pdst_locked_unlock_all_pdlvs(ls->id_to_pdlv_abort);
+	pdst_locked_unlock_all_pdlvs(ls->id_to_pdlv_poll);
+
+	lvmpolld_stores_unlock(ls);
+}
+
+static int fini(struct daemon_state *s)
+{
+	int done;
+	const struct timespec t = { .tv_nsec = 250000000 }; /* .25 sec */
+	struct lvmpolld_state *ls = s->private;
+
+	DEBUGLOG(s, "fini");
+
+	DEBUGLOG(s, "sending cancel requests");
+
+	lvmpolld_global_lock(ls);
+	pdst_locked_send_cancel(ls->id_to_pdlv_poll);
+	pdst_locked_send_cancel(ls->id_to_pdlv_abort);
+	lvmpolld_global_unlock(ls);
+
+	DEBUGLOG(s, "waiting for background threads to finish");
+
+	while(1) {
+		lvmpolld_stores_lock(ls);
+		done = !pdst_locked_get_active_count(ls->id_to_pdlv_poll) &&
+		       !pdst_locked_get_active_count(ls->id_to_pdlv_abort);
+		lvmpolld_stores_unlock(ls);
+		if (done)
+			break;
+		nanosleep(&t, NULL);
+	}
+
+	DEBUGLOG(s, "destroying internal data structures");
+
+	lvmpolld_stores_lock(ls);
+	pdst_locked_destroy_all_pdlvs(ls->id_to_pdlv_poll);
+	pdst_locked_destroy_all_pdlvs(ls->id_to_pdlv_abort);
+	lvmpolld_stores_unlock(ls);
+
+	pdst_destroy(ls->id_to_pdlv_poll);
+	pdst_destroy(ls->id_to_pdlv_abort);
+
+	pthread_key_delete(key);
+
+	return 1;
+}
+
+static response reply(const char *res, const char *reason)
+{
+	return daemon_reply_simple(res, "reason = %s", reason, NULL);
+}
+
+static int read_single_line(struct lvmpolld_thread_data *data, int err)
+{
+	ssize_t r = getline(&data->line, &data->line_size, err ? data->ferr : data->fout);
+
+	if (r > 0 && *(data->line + r - 1) == '\n')
+		*(data->line + r - 1) = '\0';
+
+	return (r > 0);
+}
+
+static void update_idle_state(struct lvmpolld_state *ls)
+{
+	if (!ls->idle)
+		return;
+
+	lvmpolld_stores_lock(ls);
+
+	ls->idle->is_idle = !pdst_locked_get_active_count(ls->id_to_pdlv_poll) &&
+			    !pdst_locked_get_active_count(ls->id_to_pdlv_abort);
+
+	lvmpolld_stores_unlock(ls);
+
+	DEBUGLOG(ls, "%s: %s %s%s", PD_LOG_PREFIX, "daemon is", ls->idle->is_idle ? "" : "not ", "idle");
+}
+
+/* make this configurable */
+#define MAX_TIMEOUT 2
+
+static int poll_for_output(struct lvmpolld_lv *pdlv, struct lvmpolld_thread_data *data)
+{
+	int ch_stat, r, err = 1, fds_count = 2, timeout = 0;
+	pid_t pid;
+	struct lvmpolld_cmd_stat cmd_state = { .retcode = -1, .signal = 0 };
+	struct pollfd fds[] = { { .fd = data->outpipe[0], .events = POLLIN },
+				{ .fd = data->errpipe[0], .events = POLLIN } };
+
+	if (!(data->fout = fdopen(data->outpipe[0], "r")) || !(data->ferr = fdopen(data->errpipe[0], "r"))) {
+		ERROR(pdlv->ls, "%s: %s: (%d) %s", PD_LOG_PREFIX, "failed to open file stream",
+		      errno, _strerror_r(errno, data));
+		goto out;
+	}
+
+	while (1) {
+		do {
+			r = poll(fds, 2, pdlv_get_timeout(pdlv) * 1000);
+		} while (r < 0 && errno == EINTR);
+
+		DEBUGLOG(pdlv->ls, "%s: %s %d", PD_LOG_PREFIX, "poll() returned", r);
+		if (r < 0) {
+			ERROR(pdlv->ls, "%s: %s (PID %d) failed: (%d) %s",
+			      PD_LOG_PREFIX, "poll() for LVM2 cmd", pdlv->cmd_pid,
+			      errno, _strerror_r(errno, data));
+			goto out;
+		} else if (!r) {
+			timeout++;
+
+			WARN(pdlv->ls, "%s: %s (PID %d) %s", PD_LOG_PREFIX,
+			     "polling for output of the lvm cmd", pdlv->cmd_pid,
+			     "has timed out");
+
+			if (timeout > MAX_TIMEOUT) {
+				ERROR(pdlv->ls, "%s: %s (PID %d) (no output for %d seconds)",
+				      PD_LOG_PREFIX,
+				      "LVM2 cmd is unresponsive too long",
+				      pdlv->cmd_pid,
+				      timeout * pdlv_get_timeout(pdlv));
+				goto out;
+			}
+
+			continue; /* while(1) */
+		}
+
+		timeout = 0;
+
+		/* handle the command's STDOUT */
+		if (fds[0].revents & POLLIN) {
+			DEBUGLOG(pdlv->ls, "%s: %s", PD_LOG_PREFIX, "caught input data in STDOUT");
+
+			assert(read_single_line(data, 0)); /* may block indef. anyway */
+			INFO(pdlv->ls, "%s: PID %d: %s: '%s'", LVM2_LOG_PREFIX,
+			     pdlv->cmd_pid, "STDOUT", data->line);
+		} else if (fds[0].revents) {
+			if (fds[0].revents & POLLHUP)
+				DEBUGLOG(pdlv->ls, "%s: %s", PD_LOG_PREFIX, "caught POLLHUP");
+			else
+				WARN(pdlv->ls, "%s: %s", PD_LOG_PREFIX, "poll for command's STDOUT failed");
+
+			fds[0].fd = -1;
+			fds_count--;
+		}
+
+		/* handle the command's STDERR */
+		if (fds[1].revents & POLLIN) {
+			DEBUGLOG(pdlv->ls, "%s: %s", PD_LOG_PREFIX,
+				 "caught input data in STDERR");
+
+			assert(read_single_line(data, 1)); /* may block indef. anyway */
+			INFO(pdlv->ls, "%s: PID %d: %s: '%s'", LVM2_LOG_PREFIX,
+			     pdlv->cmd_pid, "STDERR", data->line);
+		} else if (fds[1].revents) {
+			if (fds[1].revents & POLLHUP)
+				DEBUGLOG(pdlv->ls, "%s: %s", PD_LOG_PREFIX, "caught err POLLHUP");
+			else
+				WARN(pdlv->ls, "%s: %s", PD_LOG_PREFIX, "poll for command's STDOUT failed");
+
+			fds[1].fd = -1;
+			fds_count--;
+		}
+
+		do {
+			/*
+			 * fds_count == 0 means polling reached EOF
+			 * or received error on both descriptors.
+			 * In such case, just wait for command to finish
+			 */
+			pid = waitpid(pdlv->cmd_pid, &ch_stat, fds_count ? WNOHANG : 0);
+		} while (pid < 0 && errno == EINTR);
+
+		if (pid) {
+			if (pid < 0) {
+				ERROR(pdlv->ls, "%s: %s (PID %d) failed: (%d) %s",
+				      PD_LOG_PREFIX, "waitpid() for lvm2 cmd",
+				      pdlv->cmd_pid, errno,
+				      _strerror_r(errno, data));
+				goto out;
+			}
+			DEBUGLOG(pdlv->ls, "%s: %s", PD_LOG_PREFIX, "child exited");
+			break;
+		}
+	} /* while(1) */
+
+	DEBUGLOG(pdlv->ls, "%s: %s", PD_LOG_PREFIX, "about to collect remaining lines");
+	if (fds[0].fd >= 0)
+		while (read_single_line(data, 0)) {
+			assert(r > 0);
+			INFO(pdlv->ls, "%s: PID %d: %s: %s", LVM2_LOG_PREFIX, pdlv->cmd_pid, "STDOUT", data->line);
+		}
+	if (fds[1].fd >= 0)
+		while (read_single_line(data, 1)) {
+			assert(r > 0);
+			INFO(pdlv->ls, "%s: PID %d: %s: %s", LVM2_LOG_PREFIX, pdlv->cmd_pid, "STDERR", data->line);
+		}
+
+	if (WIFEXITED(ch_stat)) {
+		INFO(pdlv->ls, "%s: %s (PID %d) %s (%d)", PD_LOG_PREFIX,
+		     "lvm2 cmd", pdlv->cmd_pid, "exited with", WEXITSTATUS(ch_stat));
+		cmd_state.retcode = WEXITSTATUS(ch_stat);
+	} else if (WIFSIGNALED(ch_stat)) {
+		WARN(pdlv->ls, "%s: %s (PID %d) %s (%d)", PD_LOG_PREFIX,
+		     "lvm2 cmd", pdlv->cmd_pid, "got terminated by signal",
+		     WTERMSIG(ch_stat));
+		cmd_state.signal = WTERMSIG(ch_stat);
+	}
+
+	err = 0;
+out:
+	if (!err)
+		pdlv_set_cmd_state(pdlv, &cmd_state);
+
+	return err;
+}
+
+static void debug_print(struct lvmpolld_state *ls, const char * const* ptr)
+{
+	const char * const* tmp = ptr;
+
+	if (!tmp)
+		return;
+
+	while (*tmp) {
+		DEBUGLOG(ls, "%s: %s", PD_LOG_PREFIX, *tmp);
+		tmp++;
+	}
+}
+
+static void *fork_and_poll(void *args)
+{
+	int outfd, errfd, state;
+	struct lvmpolld_thread_data *data;
+	pid_t r;
+
+	int error = 1;
+	struct lvmpolld_lv *pdlv = (struct lvmpolld_lv *) args;
+	struct lvmpolld_state *ls = pdlv->ls;
+
+	pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &state);
+	data = lvmpolld_thread_data_constructor(pdlv);
+	pthread_setspecific(key, data);
+	pthread_setcancelstate(state, &state);
+
+	if (!data) {
+		ERROR(ls, "%s: %s", PD_LOG_PREFIX, "Failed to initialize per-thread data");
+		goto err;
+	}
+
+	DEBUGLOG(ls, "%s: %s", PD_LOG_PREFIX, "cmd line arguments:");
+	debug_print(ls, pdlv->cmdargv);
+	DEBUGLOG(ls, "%s: %s", PD_LOG_PREFIX, "---end---");
+
+	DEBUGLOG(ls, "%s: %s", PD_LOG_PREFIX, "cmd environment variables:");
+	debug_print(ls, pdlv->cmdenvp);
+	DEBUGLOG(ls, "%s: %s", PD_LOG_PREFIX, "---end---");
+
+	outfd = data->outpipe[1];
+	errfd = data->errpipe[1];
+
+	r = fork();
+	if (!r) {
+		/* child */
+		/* !!! Do not touch any posix thread primitives !!! */
+
+		if ((dup2(outfd, STDOUT_FILENO ) != STDOUT_FILENO) ||
+		    (dup2(errfd, STDERR_FILENO ) != STDERR_FILENO))
+			_exit(100);
+
+		execve(*(pdlv->cmdargv), (char *const *)pdlv->cmdargv, (char *const *)pdlv->cmdenvp);
+
+		_exit(101);
+	} else {
+		/* parent */
+		if (r == -1) {
+			ERROR(ls, "%s: %s: (%d) %s", PD_LOG_PREFIX, "fork failed",
+			      errno, _strerror_r(errno, data));
+			goto err;
+		}
+
+		INFO(ls, "%s: LVM2 cmd \"%s\" (PID: %d)", PD_LOG_PREFIX, *(pdlv->cmdargv), r);
+
+		pdlv->cmd_pid = r;
+
+		/* failure to close write end of any pipe will result in broken polling */
+		if (close(data->outpipe[1])) {
+			ERROR(ls, "%s: %s: (%d) %s", PD_LOG_PREFIX, "failed to close write end of pipe",
+			      errno, _strerror_r(errno, data));
+			goto err;
+		}
+		data->outpipe[1] = -1;
+
+		if (close(data->errpipe[1])) {
+			ERROR(ls, "%s: %s: (%d) %s", PD_LOG_PREFIX, "failed to close write end of err pipe",
+			      errno, _strerror_r(errno, data));
+			goto err;
+		}
+		data->errpipe[1] = -1;
+
+		error = poll_for_output(pdlv, data);
+		DEBUGLOG(ls, "%s: %s", PD_LOG_PREFIX, "polling for lvpoll output has finished");
+	}
+
+err:
+	r = 0;
+
+	pdst_lock(pdlv->pdst);
+
+	if (error) {
+		/* last reader is responsible for pdlv cleanup */
+		r = pdlv->cmd_pid;
+		pdlv_set_error(pdlv, 1);
+	}
+
+	pdlv_set_polling_finished(pdlv, 1);
+	if (data)
+		data->pdlv = NULL;
+
+	pdst_locked_dec(pdlv->pdst);
+
+	pdst_unlock(pdlv->pdst);
+
+	pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &state);
+	lvmpolld_thread_data_destroy(data);
+	pthread_setspecific(key, NULL);
+	pthread_setcancelstate(state, &state);
+
+	update_idle_state(ls);
+
+	/*
+	 * This is unfortunate case where we
+	 * know nothing about state of lvm cmd and
+	 * (eventually) ongoing progress.
+	 *
+	 * harvest zombies
+	 */
+	if (r)
+		while(waitpid(r, NULL, 0) < 0 && errno == EINTR);
+
+	return NULL;
+}
+
+static response progress_info(client_handle h, struct lvmpolld_state *ls, request req)
+{
+	char *id;
+	struct lvmpolld_lv *pdlv;
+	struct lvmpolld_store *pdst;
+	struct lvmpolld_lv_state st;
+	response r;
+	const char *lvid = daemon_request_str(req, LVMPD_PARM_LVID, NULL);
+	const char *sysdir = daemon_request_str(req, LVMPD_PARM_SYSDIR, NULL);
+	unsigned abort_polling = daemon_request_int(req, LVMPD_PARM_ABORT, 0);
+
+	if (!lvid)
+		return reply(LVMPD_RESP_FAILED, REASON_MISSING_LVID);
+
+	id = construct_id(sysdir, lvid);
+	if (!id) {
+		ERROR(ls, "%s: %s", PD_LOG_PREFIX, "progress_info request failed to construct ID.");
+		return reply(LVMPD_RESP_FAILED, REASON_ENOMEM);
+	}
+
+	DEBUGLOG(ls, "%s: %s: %s", PD_LOG_PREFIX, "ID", id);
+
+	pdst = abort_polling ? ls->id_to_pdlv_abort : ls->id_to_pdlv_poll;
+
+	pdst_lock(pdst);
+
+	pdlv = pdst_locked_lookup(pdst, id);
+	if (pdlv) {
+		/*
+		 * with store lock held, I'm the only reader accessing the pdlv
+		 */
+		st = pdlv_get_status(pdlv);
+
+		if (st.error || st.polling_finished) {
+			INFO(ls, "%s: %s %s", PD_LOG_PREFIX,
+			     "Polling finished. Removing related data structure for LV",
+			     lvid);
+			pdst_locked_remove(pdst, id);
+			pdlv_destroy(pdlv);
+		}
+	}
+	/* pdlv must not be dereferenced from now on */
+
+	pdst_unlock(pdst);
+
+	dm_free(id);
+
+	if (pdlv) {
+		if (st.error)
+			return reply(LVMPD_RESP_FAILED, REASON_POLLING_FAILED);
+
+		if (st.polling_finished)
+			r = daemon_reply_simple(LVMPD_RESP_FINISHED,
+						"reason = %s", st.cmd_state.signal ? LVMPD_REAS_SIGNAL : LVMPD_REAS_RETCODE,
+						LVMPD_PARM_VALUE " = %d", st.cmd_state.signal ?: st.cmd_state.retcode,
+						NULL);
+		else
+			r = daemon_reply_simple(LVMPD_RESP_IN_PROGRESS, NULL);
+	}
+	else
+		r = daemon_reply_simple(LVMPD_RESP_NOT_FOUND, NULL);
+
+	return r;
+}
+
+static struct lvmpolld_lv *construct_pdlv(request req, struct lvmpolld_state *ls,
+				     struct lvmpolld_store *pdst,
+				     const char *interval, const char *id,
+				     const char *vgname, const char *lvname,
+				     const char *sysdir, enum poll_type type,
+				     unsigned abort_polling, unsigned uinterval)
+{
+	const char **cmdargv, **cmdenvp;
+	struct lvmpolld_lv *pdlv;
+	unsigned handle_missing_pvs = daemon_request_int(req, LVMPD_PARM_HANDLE_MISSING_PVS, 0);
+
+	pdlv = pdlv_create(ls, id, vgname, lvname, sysdir, type,
+			   interval, uinterval, pdst);
+
+	if (!pdlv) {
+		ERROR(ls, "%s: %s", PD_LOG_PREFIX, "failed to create internal LV data structure.");
+		return NULL;
+	}
+
+	cmdargv = cmdargv_ctr(pdlv, pdlv->ls->lvm_binary, abort_polling, handle_missing_pvs);
+	if (!cmdargv) {
+		pdlv_destroy(pdlv);
+		ERROR(ls, "%s: %s", PD_LOG_PREFIX, "failed to construct cmd arguments for lvpoll command");
+		return NULL;
+	}
+
+	cmdenvp = cmdenvp_ctr(pdlv);
+	if (!cmdenvp) {
+		pdlv_destroy(pdlv);
+		ERROR(ls, "%s: %s", PD_LOG_PREFIX, "failed to construct cmd environment for lvpoll command");
+		return NULL;
+	}
+
+	pdlv->cmdargv = cmdargv;
+	pdlv->cmdenvp = cmdenvp;
+
+	return pdlv;
+}
+
+static int spawn_detached_thread(struct lvmpolld_lv *pdlv)
+{
+	int r;
+	pthread_attr_t attr;
+
+	pthread_attr_init(&attr);
+	pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
+
+	r = pthread_create(&pdlv->tid, &attr, fork_and_poll, (void *)pdlv);
+
+	pthread_attr_destroy(&attr);
+
+	return !r;
+}
+
+static response poll_init(client_handle h, struct lvmpolld_state *ls, request req, enum poll_type type)
+{
+	char *id;
+	struct lvmpolld_lv *pdlv;
+	struct lvmpolld_store *pdst;
+	unsigned uinterval;
+
+	const char *interval = daemon_request_str(req, LVMPD_PARM_INTERVAL, NULL);
+	const char *lvid = daemon_request_str(req, LVMPD_PARM_LVID, NULL);
+	const char *lvname = daemon_request_str(req, LVMPD_PARM_LVNAME, NULL);
+	const char *vgname = daemon_request_str(req, LVMPD_PARM_VGNAME, NULL);
+	const char *sysdir = daemon_request_str(req, LVMPD_PARM_SYSDIR, NULL);
+	unsigned abort_polling = daemon_request_int(req, LVMPD_PARM_ABORT, 0);
+
+	assert(type < POLL_TYPE_MAX);
+
+	if (abort_polling && type != PVMOVE)
+		return reply(LVMPD_RESP_EINVAL, REASON_ILLEGAL_ABORT_REQUEST);
+
+	if (!interval || strpbrk(interval, "-") || sscanf(interval, "%u", &uinterval) != 1)
+		return reply(LVMPD_RESP_EINVAL, REASON_INVALID_INTERVAL);
+
+	if (!lvname)
+		return reply(LVMPD_RESP_FAILED, REASON_MISSING_LVNAME);
+
+	if (!lvid)
+		return reply(LVMPD_RESP_FAILED, REASON_MISSING_LVID);
+
+	if (!vgname)
+		return reply(LVMPD_RESP_FAILED, REASON_MISSING_VGNAME);
+
+	id = construct_id(sysdir, lvid);
+	if (!id) {
+		ERROR(ls, "%s: %s", PD_LOG_PREFIX, "poll_init request failed to construct ID.");
+		return reply(LVMPD_RESP_FAILED, REASON_ENOMEM);
+	}
+
+	DEBUGLOG(ls, "%s: %s=%s", PD_LOG_PREFIX, "ID", id);
+
+	pdst = abort_polling ? ls->id_to_pdlv_abort : ls->id_to_pdlv_poll;
+
+	pdst_lock(pdst);
+
+	pdlv = pdst_locked_lookup(pdst, id);
+	if (pdlv && pdlv_get_polling_finished(pdlv)) {
+		WARN(ls, "%s: %s %s", PD_LOG_PREFIX, "Force removal of uncollected info for LV",
+			 lvid);
+		/* 
+		 * lvmpolld has to remove uncollected results in this case.
+		 * otherwise it would have to refuse request for new polling
+		 * lv with same id.
+		 */
+		pdst_locked_remove(pdst, id);
+		pdlv_destroy(pdlv);
+		pdlv = NULL;
+	}
+
+	if (pdlv) {
+		if (!pdlv_is_type(pdlv, type)) {
+			pdst_unlock(pdst);
+			ERROR(ls, "%s: %s '%s': expected: %s, requested: %s",
+			      PD_LOG_PREFIX, "poll operation type mismatch on LV identified by",
+			      id,
+			      polling_op(pdlv_get_type(pdlv)), polling_op(type));
+			dm_free(id);
+			return reply(LVMPD_RESP_EINVAL,
+				     REASON_DIFFERENT_OPERATION_IN_PROGRESS);
+		}
+		pdlv->init_rq_count++; /* safe. protected by store lock */
+	} else {
+		pdlv = construct_pdlv(req, ls, pdst, interval, id, vgname,
+				      lvname, sysdir, type, abort_polling, 2 * uinterval);
+		if (!pdlv) {
+			pdst_unlock(pdst);
+			dm_free(id);
+			return reply(LVMPD_RESP_FAILED, REASON_ENOMEM);
+		}
+		if (!pdst_locked_insert(pdst, id, pdlv)) {
+			pdlv_destroy(pdlv);
+			pdst_unlock(pdst);
+			ERROR(ls, "%s: %s", PD_LOG_PREFIX, "couldn't store internal LV data structure");
+			dm_free(id);
+			return reply(LVMPD_RESP_FAILED, REASON_ENOMEM);
+		}
+		if (!spawn_detached_thread(pdlv)) {
+			ERROR(ls, "%s: %s", PD_LOG_PREFIX, "failed to spawn detached monitoring thread");
+			pdst_locked_remove(pdst, id);
+			pdlv_destroy(pdlv);
+			pdst_unlock(pdst);
+			dm_free(id);
+			return reply(LVMPD_RESP_FAILED, REASON_ENOMEM);
+		}
+
+		pdst_locked_inc(pdst);
+		if (ls->idle)
+			ls->idle->is_idle = 0;
+	}
+
+	pdst_unlock(pdst);
+
+	dm_free(id);
+
+	return daemon_reply_simple(LVMPD_RESP_OK, NULL);
+}
+
+static response dump_state(client_handle h, struct lvmpolld_state *ls, request r)
+{
+	response res = { 0 };
+	struct buffer *b = &res.buffer;
+
+	buffer_init(b);
+
+	lvmpolld_global_lock(ls);
+
+	buffer_append(b, "# Registered polling operations\n\n");
+	buffer_append(b, "poll {\n");
+	pdst_locked_dump(ls->id_to_pdlv_poll, b);
+	buffer_append(b, "}\n\n");
+
+	buffer_append(b, "# Registered abort operations\n\n");
+	buffer_append(b, "abort {\n");
+	pdst_locked_dump(ls->id_to_pdlv_abort, b);
+	buffer_append(b, "}\n\n");
+
+	lvmpolld_global_unlock(ls);
+
+	return res;
+}
+
+static response handler(struct daemon_state s, client_handle h, request r)
+{
+	struct lvmpolld_state *ls = s.private;
+	const char *rq = daemon_request_str(r, "request", "NONE");
+
+	if (!strcmp(rq, LVMPD_REQ_PVMOVE))
+		return poll_init(h, ls, r, PVMOVE);
+	else if (!strcmp(rq, LVMPD_REQ_CONVERT))
+		return poll_init(h, ls, r, CONVERT);
+	else if (!strcmp(rq, LVMPD_REQ_MERGE))
+		return poll_init(h, ls, r, MERGE);
+	else if (!strcmp(rq, LVMPD_REQ_MERGE_THIN))
+		return poll_init(h, ls, r, MERGE_THIN);
+	else if (!strcmp(rq, LVMPD_REQ_PROGRESS))
+		return progress_info(h, ls, r);
+	else if (!strcmp(rq, LVMPD_REQ_DUMP))
+		return dump_state(h, ls, r);
+	else
+		return reply(LVMPD_RESP_EINVAL, REASON_REQ_NOT_IMPLEMENTED);
+}
+
+static int process_timeout_arg(const char *str, unsigned *max_timeouts)
+{
+	char *endptr;
+	unsigned long l;
+
+	l = strtoul(str, &endptr, 10);
+	if (errno || *endptr || l >= UINT_MAX)
+		return 0;
+
+	*max_timeouts = (unsigned) l;
+
+	return 1;
+}
+
+int main(int argc, char *argv[])
+{
+	signed char opt;
+	struct timeval timeout;
+	daemon_idle di = { .ptimeout = &timeout };
+	struct lvmpolld_state ls = { .log_config = "" };
+	daemon_state s = {
+		.daemon_fini = fini,
+		.daemon_init = init,
+		.handler = handler,
+		.name = "lvmpolld",
+		.pidfile = getenv("LVM_LVMPOLLD_PIDFILE") ?: LVMPOLLD_PIDFILE,
+		.private = &ls,
+		.protocol = LVMPOLLD_PROTOCOL,
+		.protocol_version = LVMPOLLD_PROTOCOL_VERSION,
+		.socket_path = getenv("LVM_LVMPOLLD_SOCKET") ?: LVMPOLLD_SOCKET,
+	};
+
+	while ((opt = getopt(argc, argv, "?fhVl:p:s:B:t:")) != EOF) {
+		switch (opt) {
+		case '?':
+			usage(argv[0], stderr);
+			exit(0);
+		case 'B': /* --binary */
+			ls.lvm_binary = optarg;
+			break;
+		case 'V':
+			printf("lvmpolld version: " LVM_VERSION "\n");
+			exit(1);
+		case 'f':
+			s.foreground = 1;
+			break;
+		case 'h':
+			usage(argv[0], stdout);
+			exit(0);
+		case 'l':
+			ls.log_config = optarg;
+			break;
+		case 'p':
+			s.pidfile = optarg;
+			break;
+		case 's': /* --socket */
+			s.socket_path = optarg;
+			break;
+		case 't': /* --timeout in seconds */
+			if (!process_timeout_arg(optarg, &di.max_timeouts)) {
+				fprintf(stderr, "Invalid value of timeout parameter");
+				exit(1);
+			}
+			/* 0 equals to wait indefinitely */
+			if (di.max_timeouts)
+				s.idle = ls.idle = &di;
+			break;
+		}
+	}
+
+	daemon_start(s);
+
+	return 0;
+}
diff --git a/daemons/lvmpolld/lvmpolld-data-utils.c b/daemons/lvmpolld/lvmpolld-data-utils.c
new file mode 100644
index 0000000..92147df
--- /dev/null
+++ b/daemons/lvmpolld/lvmpolld-data-utils.c
@@ -0,0 +1,388 @@
+/*
+ * Copyright (C) 2014-2015 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "lvmpolld-common.h"
+
+#include "config-util.h"
+
+#include <fcntl.h>
+#include <signal.h>
+
+static char *_construct_full_lvname(const char *vgname, const char *lvname)
+{
+	char *name;
+	size_t l;
+
+	l = strlen(vgname) + strlen(lvname) + 2; /* vg/lv and \0 */
+	name = (char *) dm_malloc(l * sizeof(char));
+	if (!name)
+		return NULL;
+
+	if (dm_snprintf(name, l, "%s/%s", vgname, lvname) < 0) {
+		dm_free(name);
+		name = NULL;
+	}
+
+	return name;
+}
+
+static char *_construct_lvm_system_dir_env(const char *sysdir)
+{
+	/*
+	 *  Store either "LVM_SYSTEM_DIR=/path/to..."
+	 *		    - or -
+	 *  just single char to store NULL byte
+	 */
+	size_t l = sysdir ? strlen(sysdir) + 16 : 1;
+	char *env = (char *) dm_malloc(l * sizeof(char));
+
+	if (!env)
+		return NULL;
+
+	*env = '\0';
+
+	if (sysdir && dm_snprintf(env, l, "LVM_SYSTEM_DIR=%s", sysdir) < 0) {
+		dm_free(env);
+		env = NULL;
+	}
+
+	return env;
+}
+
+static const char *_get_lvid(const char *lvmpolld_id, const char *sysdir)
+{
+	return lvmpolld_id ? (lvmpolld_id + (sysdir ? strlen(sysdir) : 0)) : NULL;
+}
+
+char *construct_id(const char *sysdir, const char *uuid)
+{
+	char *id;
+	int r;
+	size_t l;
+
+	l = strlen(uuid) + (sysdir ? strlen(sysdir) : 0) + 1;
+	id = (char *) dm_malloc(l * sizeof(char));
+	if (!id)
+		return NULL;
+
+	r = sysdir ? dm_snprintf(id, l, "%s%s", sysdir, uuid) :
+		     dm_snprintf(id, l, "%s", uuid);
+
+	if (r < 0) {
+		dm_free(id);
+		id = NULL;
+	}
+
+	return id;
+}
+
+struct lvmpolld_lv *pdlv_create(struct lvmpolld_state *ls, const char *id,
+			   const char *vgname, const char *lvname,
+			   const char *sysdir, enum poll_type type,
+			   const char *sinterval, unsigned pdtimeout,
+			   struct lvmpolld_store *pdst)
+{
+	char *lvmpolld_id = dm_strdup(id), /* copy */
+	     *full_lvname = _construct_full_lvname(vgname, lvname), /* copy */
+	     *lvm_system_dir_env = _construct_lvm_system_dir_env(sysdir); /* copy */
+
+	struct lvmpolld_lv tmp = {
+		.ls = ls,
+		.type = type,
+		.lvmpolld_id = lvmpolld_id,
+		.lvid = _get_lvid(lvmpolld_id, sysdir),
+		.lvname = full_lvname,
+		.lvm_system_dir_env = lvm_system_dir_env,
+		.sinterval = dm_strdup(sinterval), /* copy */
+		.pdtimeout = pdtimeout < MIN_POLLING_TIMEOUT ? MIN_POLLING_TIMEOUT : pdtimeout,
+		.cmd_state = { .retcode = -1, .signal = 0 },
+		.pdst = pdst,
+		.init_rq_count = 1
+	}, *pdlv = (struct lvmpolld_lv *) dm_malloc(sizeof(struct lvmpolld_lv));
+
+	if (!pdlv || !tmp.lvid || !tmp.lvname || !tmp.lvm_system_dir_env || !tmp.sinterval)
+		goto err;
+
+	memcpy(pdlv, &tmp, sizeof(*pdlv));
+
+	if (pthread_mutex_init(&pdlv->lock, NULL))
+		goto err;
+
+	return pdlv;
+
+err:
+	dm_free((void *)full_lvname);
+	dm_free((void *)lvmpolld_id);
+	dm_free((void *)lvm_system_dir_env);
+	dm_free((void *)tmp.sinterval);
+	dm_free((void *)pdlv);
+
+	return NULL;
+}
+
+void pdlv_destroy(struct lvmpolld_lv *pdlv)
+{
+	dm_free((void *)pdlv->lvmpolld_id);
+	dm_free((void *)pdlv->lvname);
+	dm_free((void *)pdlv->sinterval);
+	dm_free((void *)pdlv->lvm_system_dir_env);
+	dm_free((void *)pdlv->cmdargv);
+	dm_free((void *)pdlv->cmdenvp);
+
+	pthread_mutex_destroy(&pdlv->lock);
+
+	dm_free((void *)pdlv);
+}
+
+unsigned pdlv_get_polling_finished(struct lvmpolld_lv *pdlv)
+{
+	unsigned ret;
+
+	pdlv_lock(pdlv);
+	ret = pdlv->polling_finished;
+	pdlv_unlock(pdlv);
+
+	return ret;
+}
+
+struct lvmpolld_lv_state pdlv_get_status(struct lvmpolld_lv *pdlv)
+{
+	struct lvmpolld_lv_state r;
+
+	pdlv_lock(pdlv);
+	r.error = pdlv_locked_error(pdlv);
+	r.polling_finished = pdlv_locked_polling_finished(pdlv);
+	r.cmd_state = pdlv_locked_cmd_state(pdlv);
+	pdlv_unlock(pdlv);
+
+	return r;
+}
+
+void pdlv_set_cmd_state(struct lvmpolld_lv *pdlv, const struct lvmpolld_cmd_stat *cmd_state)
+{
+	pdlv_lock(pdlv);
+	pdlv->cmd_state = *cmd_state;
+	pdlv_unlock(pdlv);
+}
+
+void pdlv_set_error(struct lvmpolld_lv *pdlv, unsigned error)
+{
+	pdlv_lock(pdlv);
+	pdlv->error = error;
+	pdlv_unlock(pdlv);
+}
+
+void pdlv_set_polling_finished(struct lvmpolld_lv *pdlv, unsigned finished)
+{
+	pdlv_lock(pdlv);
+	pdlv->polling_finished = finished;
+	pdlv_unlock(pdlv);
+}
+
+struct lvmpolld_store *pdst_init(const char *name)
+{
+	struct lvmpolld_store *pdst = (struct lvmpolld_store *) dm_malloc(sizeof(struct lvmpolld_store));
+	if (!pdst)
+		return NULL;
+
+	pdst->store = dm_hash_create(32);
+	if (!pdst->store)
+		goto err_hash;
+	if (pthread_mutex_init(&pdst->lock, NULL))
+		goto err_mutex;
+
+	pdst->name = name;
+
+	return pdst;
+
+err_mutex:
+	dm_hash_destroy(pdst->store);
+err_hash:
+	dm_free(pdst);
+	return NULL;
+}
+
+void pdst_destroy(struct lvmpolld_store *pdst)
+{
+	if (!pdst)
+		return;
+
+	dm_hash_destroy(pdst->store);
+	pthread_mutex_destroy(&pdst->lock);
+	dm_free(pdst);
+}
+
+void pdst_locked_lock_all_pdlvs(const struct lvmpolld_store *pdst)
+{
+	struct dm_hash_node *n;
+
+	dm_hash_iterate(n, pdst->store)
+		pdlv_lock(dm_hash_get_data(pdst->store, n));
+}
+
+void pdst_locked_unlock_all_pdlvs(const struct lvmpolld_store *pdst)
+{
+	struct dm_hash_node *n;
+
+	dm_hash_iterate(n, pdst->store)
+		pdlv_unlock(dm_hash_get_data(pdst->store, n));
+}
+
+static void _pdlv_locked_dump(struct buffer *buff, const struct lvmpolld_lv *pdlv)
+{
+	char tmp[1024];
+	const struct lvmpolld_cmd_stat *cmd_state = &pdlv->cmd_state;
+
+	/* pdlv-section { */
+	if (dm_snprintf(tmp, sizeof(tmp), "\t%s {\n", pdlv->lvmpolld_id) > 0)
+		buffer_append(buff, tmp);
+
+	if (dm_snprintf(tmp, sizeof(tmp), "\t\tlvid=\"%s\"\n", pdlv->lvid) > 0)
+		buffer_append(buff, tmp);
+	if (dm_snprintf(tmp, sizeof(tmp), "\t\ttype=\"%s\"\n", polling_op(pdlv->type)) > 0)
+		buffer_append(buff, tmp);
+	if (dm_snprintf(tmp, sizeof(tmp), "\t\tlvname=\"%s\"\n", pdlv->lvname) > 0)
+		buffer_append(buff, tmp);
+	if (dm_snprintf(tmp, sizeof(tmp), "\t\tlvmpolld_internal_timeout=%d\n", pdlv->pdtimeout) > 0)
+		buffer_append(buff, tmp);
+	if (dm_snprintf(tmp, sizeof(tmp), "\t\tlvm_command_interval=\"%s\"\n", pdlv->sinterval ?: "<undefined>") > 0)
+		buffer_append(buff, tmp);
+	if (dm_snprintf(tmp, sizeof(tmp), "\t\tLVM_SYSTEM_DIR=\"%s\"\n",
+			(*pdlv->lvm_system_dir_env ? (pdlv->lvm_system_dir_env + strlen("LVM_SYSTEM_DIR=")) : "<undefined>")) > 0)
+		buffer_append(buff, tmp);
+	if (dm_snprintf(tmp, sizeof(tmp), "\t\tlvm_command_pid=%d\n", pdlv->cmd_pid) > 0)
+		buffer_append(buff, tmp);
+	if (dm_snprintf(tmp, sizeof(tmp), "\t\tpolling_finished=%d\n", pdlv->polling_finished) > 0)
+		buffer_append(buff, tmp);
+	if (dm_snprintf(tmp, sizeof(tmp), "\t\terror_occured=%d\n", pdlv->error) > 0)
+		buffer_append(buff, tmp);
+	if (dm_snprintf(tmp, sizeof(tmp), "\t\tinit_requests_count=%d\n", pdlv->init_rq_count) > 0)
+		buffer_append(buff, tmp);
+
+	/* lvm_commmand-section { */
+	buffer_append(buff, "\t\tlvm_command {\n");
+	if (cmd_state->retcode == -1 && !cmd_state->signal)
+		buffer_append(buff, "\t\t\tstate=\"" LVMPD_RESP_IN_PROGRESS "\"\n");
+	else {
+		buffer_append(buff, "\t\t\tstate=\"" LVMPD_RESP_FINISHED "\"\n");
+		if (dm_snprintf(tmp, sizeof(tmp), "\t\t\treason=\"%s\"\n\t\t\tvalue=%d\n",
+				(cmd_state->signal ? LVMPD_REAS_SIGNAL : LVMPD_REAS_RETCODE),
+				(cmd_state->signal ?: cmd_state->retcode)) > 0)
+			buffer_append(buff, tmp);
+	}
+	buffer_append(buff, "\t\t}\n");
+	/* } lvm_commmand-section */
+
+	buffer_append(buff, "\t}\n");
+	/* } pdlv-section */
+}
+
+void pdst_locked_dump(const struct lvmpolld_store *pdst, struct buffer *buff)
+{
+	struct dm_hash_node *n;
+
+	dm_hash_iterate(n, pdst->store)
+		_pdlv_locked_dump(buff, dm_hash_get_data(pdst->store, n));
+}
+
+void pdst_locked_send_cancel(const struct lvmpolld_store *pdst)
+{
+	struct lvmpolld_lv *pdlv;
+	struct dm_hash_node *n;
+
+	dm_hash_iterate(n, pdst->store) {
+		pdlv = dm_hash_get_data(pdst->store, n);
+		if (!pdlv_locked_polling_finished(pdlv))
+			pthread_cancel(pdlv->tid);
+	}
+}
+
+void pdst_locked_destroy_all_pdlvs(const struct lvmpolld_store *pdst)
+{
+	struct dm_hash_node *n;
+
+	dm_hash_iterate(n, pdst->store)
+		pdlv_destroy(dm_hash_get_data(pdst->store, n));
+}
+
+struct lvmpolld_thread_data *lvmpolld_thread_data_constructor(struct lvmpolld_lv *pdlv)
+{
+	struct lvmpolld_thread_data *data = (struct lvmpolld_thread_data *) dm_malloc(sizeof(struct lvmpolld_thread_data));
+	if (!data)
+		return NULL;
+
+	data->pdlv = NULL;
+	data->line = NULL;
+	data->fout = data->ferr = NULL;
+	data->outpipe[0] = data->outpipe[1] = data->errpipe[0] = data->errpipe[1] = -1;
+
+	if (pipe(data->outpipe) || pipe(data->errpipe)) {
+		lvmpolld_thread_data_destroy(data);
+		return NULL;
+	}
+
+	if (fcntl(data->outpipe[0], F_SETFD, FD_CLOEXEC) ||
+	    fcntl(data->outpipe[1], F_SETFD, FD_CLOEXEC) ||
+	    fcntl(data->errpipe[0], F_SETFD, FD_CLOEXEC) ||
+	    fcntl(data->errpipe[1], F_SETFD, FD_CLOEXEC)) {
+		lvmpolld_thread_data_destroy(data);
+		return NULL;
+	}
+
+	data->pdlv = pdlv;
+
+	return data;
+}
+
+void lvmpolld_thread_data_destroy(void *thread_private)
+{
+	struct lvmpolld_thread_data *data = (struct lvmpolld_thread_data *) thread_private;
+	if (!data)
+		return;
+
+	if (data->pdlv) {
+		pdst_lock(data->pdlv->pdst);
+		/*
+		 * FIXME: skip this step if lvmpolld is activated
+		 * 	  by systemd.
+		 */
+		if (!pdlv_get_polling_finished(data->pdlv))
+			kill(data->pdlv->cmd_pid, SIGTERM);
+		pdlv_set_polling_finished(data->pdlv, 1);
+		pdst_locked_dec(data->pdlv->pdst);
+		pdst_unlock(data->pdlv->pdst);
+	}
+
+	dm_free(data->line);
+
+	if (data->fout && !fclose(data->fout))
+		data->outpipe[0] = -1;
+
+	if (data->ferr && !fclose(data->ferr))
+		data->errpipe[0] = -1;
+
+	if (data->outpipe[0] >= 0)
+		close(data->outpipe[0]);
+
+	if (data->outpipe[1] >= 0)
+		close(data->outpipe[1]);
+
+	if (data->errpipe[0] >= 0)
+		close(data->errpipe[0]);
+
+	if (data->errpipe[1] >= 0)
+		close(data->errpipe[1]);
+
+	dm_free(data);
+}
diff --git a/daemons/lvmpolld/lvmpolld-data-utils.h b/daemons/lvmpolld/lvmpolld-data-utils.h
new file mode 100644
index 0000000..e3bede1
--- /dev/null
+++ b/daemons/lvmpolld/lvmpolld-data-utils.h
@@ -0,0 +1,215 @@
+/*
+ * Copyright (C) 2014-2015 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef _LVM_LVMPOLLD_DATA_UTILS_H
+#define _LVM_LVMPOLLD_DATA_UTILS_H
+
+#include <pthread.h>
+
+struct buffer;
+struct lvmpolld_state;
+
+enum poll_type {
+	PVMOVE = 0,
+	CONVERT,
+	MERGE,
+	MERGE_THIN,
+	POLL_TYPE_MAX
+};
+
+struct lvmpolld_cmd_stat {
+	int retcode;
+	int signal;
+};
+
+struct lvmpolld_store {
+	pthread_mutex_t lock;
+	void *store;
+	const char *name;
+	unsigned active_polling_count;
+};
+
+struct lvmpolld_lv {
+	/*
+	 * accessing following vars doesn't
+	 * require struct lvmpolld_lv lock
+	 */
+	struct lvmpolld_state *const ls;
+	const enum poll_type type;
+	const char *const lvid;
+	const char *const lvmpolld_id;
+	const char *const lvname; /* full vg/lv name */
+	const unsigned pdtimeout; /* in seconds */
+	const char *const sinterval;
+	const char *const lvm_system_dir_env;
+	struct lvmpolld_store *const pdst;
+	const char *const *cmdargv;
+	const char *const *cmdenvp;
+
+	/* only used by write */
+	pid_t cmd_pid;
+	pthread_t tid;
+
+	pthread_mutex_t lock;
+
+	/* block of shared variables protected by lock */
+	struct lvmpolld_cmd_stat cmd_state;
+	unsigned init_rq_count; /* for debuging purposes only */
+	unsigned polling_finished:1; /* no more updates */
+	unsigned error:1; /* unrecoverable error occured in lvmpolld */
+};
+
+typedef void (*lvmpolld_parse_output_fn_t) (struct lvmpolld_lv *pdlv, const char *line);
+
+/* TODO: replace with configuration option */
+#define MIN_POLLING_TIMEOUT 60
+
+struct lvmpolld_lv_state {
+	unsigned error:1;
+	unsigned polling_finished:1;
+	struct lvmpolld_cmd_stat cmd_state;
+};
+
+struct lvmpolld_thread_data {
+	char *line;
+	size_t line_size;
+	int outpipe[2];
+	int errpipe[2];
+	FILE *fout;
+	FILE *ferr;
+	char buf[1024];
+	struct lvmpolld_lv *pdlv;
+};
+
+char *construct_id(const char *sysdir, const char *lvid);
+
+/* LVMPOLLD_LV_T section */
+
+/* only call with appropriate struct lvmpolld_store lock held */
+struct lvmpolld_lv *pdlv_create(struct lvmpolld_state *ls, const char *id,
+			   const char *vgname, const char *lvname,
+			   const char *sysdir, enum poll_type type,
+			   const char *sinterval, unsigned pdtimeout,
+			   struct lvmpolld_store *pdst);
+
+/* only call with appropriate struct lvmpolld_store lock held */
+void pdlv_destroy(struct lvmpolld_lv *pdlv);
+
+static inline void pdlv_lock(struct lvmpolld_lv *pdlv)
+{
+	pthread_mutex_lock(&pdlv->lock);
+}
+
+static inline void pdlv_unlock(struct lvmpolld_lv *pdlv)
+{
+	pthread_mutex_unlock(&pdlv->lock);
+}
+
+/*
+ * no struct lvmpolld_lv lock required section
+ */
+static inline int pdlv_is_type(const struct lvmpolld_lv *pdlv, enum poll_type type)
+{
+	return pdlv->type == type;
+}
+
+static inline unsigned pdlv_get_timeout(const struct lvmpolld_lv *pdlv)
+{
+	return pdlv->pdtimeout;
+}
+
+static inline enum poll_type pdlv_get_type(const struct lvmpolld_lv *pdlv)
+{
+	return pdlv->type;
+}
+
+unsigned pdlv_get_polling_finished(struct lvmpolld_lv *pdlv);
+struct lvmpolld_lv_state pdlv_get_status(struct lvmpolld_lv *pdlv);
+void pdlv_set_cmd_state(struct lvmpolld_lv *pdlv, const struct lvmpolld_cmd_stat *cmd_state);
+void pdlv_set_error(struct lvmpolld_lv *pdlv, unsigned error);
+void pdlv_set_polling_finished(struct lvmpolld_lv *pdlv, unsigned finished);
+
+/*
+ * struct lvmpolld_lv lock required section
+ */
+static inline struct lvmpolld_cmd_stat pdlv_locked_cmd_state(const struct lvmpolld_lv *pdlv)
+{
+	return pdlv->cmd_state;
+}
+
+static inline int pdlv_locked_polling_finished(const struct lvmpolld_lv *pdlv)
+{
+	return pdlv->polling_finished;
+}
+
+static inline unsigned pdlv_locked_error(const struct lvmpolld_lv *pdlv)
+{
+	return pdlv->error;
+}
+
+/* struct lvmpolld_store manipulation routines */
+
+struct lvmpolld_store *pdst_init(const char *name);
+void pdst_destroy(struct lvmpolld_store *pdst);
+
+void pdst_locked_dump(const struct lvmpolld_store *pdst, struct buffer *buff);
+void pdst_locked_lock_all_pdlvs(const struct lvmpolld_store *pdst);
+void pdst_locked_unlock_all_pdlvs(const struct lvmpolld_store *pdst);
+void pdst_locked_destroy_all_pdlvs(const struct lvmpolld_store *pdst);
+void pdst_locked_send_cancel(const struct lvmpolld_store *pdst);
+
+static inline void pdst_lock(struct lvmpolld_store *pdst)
+{
+	pthread_mutex_lock(&pdst->lock);
+}
+
+static inline void pdst_unlock(struct lvmpolld_store *pdst)
+{
+	pthread_mutex_unlock(&pdst->lock);
+}
+
+static inline void pdst_locked_inc(struct lvmpolld_store *pdst)
+{
+	pdst->active_polling_count++;
+}
+
+static inline void pdst_locked_dec(struct lvmpolld_store *pdst)
+{
+	pdst->active_polling_count--;
+}
+
+static inline unsigned pdst_locked_get_active_count(const struct lvmpolld_store *pdst)
+{
+	return pdst->active_polling_count;
+}
+
+static inline int pdst_locked_insert(struct lvmpolld_store *pdst, const char *key, struct lvmpolld_lv *pdlv)
+{
+	return dm_hash_insert(pdst->store, key, pdlv);
+}
+
+static inline struct lvmpolld_lv *pdst_locked_lookup(struct lvmpolld_store *pdst, const char *key)
+{
+	return dm_hash_lookup(pdst->store, key);
+}
+
+static inline void pdst_locked_remove(struct lvmpolld_store *pdst, const char *key)
+{
+	dm_hash_remove(pdst->store, key);
+}
+
+struct lvmpolld_thread_data *lvmpolld_thread_data_constructor(struct lvmpolld_lv *pdlv);
+void lvmpolld_thread_data_destroy(void *thread_private);
+
+#endif /* _LVM_LVMPOLLD_DATA_UTILS_H */
diff --git a/daemons/lvmpolld/lvmpolld-protocol.h b/daemons/lvmpolld/lvmpolld-protocol.h
new file mode 100644
index 0000000..7d9821b
--- /dev/null
+++ b/daemons/lvmpolld/lvmpolld-protocol.h
@@ -0,0 +1,49 @@
+/*
+ * Copyright (C) 2015 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef _LVM_LVMPOLLD_PROTOCOL_H
+#define _LVM_LVMPOLLD_PROTOCOL_H
+
+#include "polling_ops.h"
+
+#define LVMPOLLD_PROTOCOL "lvmpolld"
+#define LVMPOLLD_PROTOCOL_VERSION 1
+
+#define LVMPD_REQ_CONVERT	CONVERT_POLL
+#define LVMPD_REQ_DUMP		"dump"
+#define LVMPD_REQ_MERGE		MERGE_POLL
+#define LVMPD_REQ_MERGE_THIN	MERGE_THIN_POLL
+#define LVMPD_REQ_PROGRESS	"progress_info"
+#define LVMPD_REQ_PVMOVE	PVMOVE_POLL
+
+#define LVMPD_PARM_ABORT		"abort"
+#define LVMPD_PARM_HANDLE_MISSING_PVS	"handle_missing_pvs"
+#define LVMPD_PARM_INTERVAL		"interval"
+#define LVMPD_PARM_LVID			"lvid"
+#define LVMPD_PARM_LVNAME		"lvname"
+#define LVMPD_PARM_SYSDIR		"sysdir"
+#define LVMPD_PARM_VALUE		"value" /* either retcode or signal value */
+#define LVMPD_PARM_VGNAME		"vgname"
+
+#define LVMPD_RESP_FAILED	"failed"
+#define LVMPD_RESP_FINISHED	"finished"
+#define LVMPD_RESP_IN_PROGRESS	"in_progress"
+#define LVMPD_RESP_EINVAL	"invalid"
+#define LVMPD_RESP_NOT_FOUND	"not_found"
+#define LVMPD_RESP_OK		"OK"
+
+#define LVMPD_REAS_RETCODE	"retcode" /* lvm cmd ret code */
+#define LVMPD_REAS_SIGNAL	"signal" /* lvm cmd terminating singal */
+
+#endif /* _LVM_LVMPOLLD_PROTOCOL_H */
diff --git a/daemons/lvmpolld/polling_ops.h b/daemons/lvmpolld/polling_ops.h
new file mode 100644
index 0000000..9f4dd58
--- /dev/null
+++ b/daemons/lvmpolld/polling_ops.h
@@ -0,0 +1,25 @@
+/*
+ * Copyright (C) 2014-2015 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef _LVM_TOOL_POLLING_OPS_H
+#define _LVM_TOOL_POLLING_OPS_H
+
+/* this file is also part of lvmpolld protocol */
+
+#define PVMOVE_POLL "pvmove"
+#define CONVERT_POLL "convert"
+#define MERGE_POLL "merge"
+#define MERGE_THIN_POLL "merge_thin"
+
+#endif /* _LVM_TOOL_POLLING_OPS_H */
diff --git a/doc/lvmpolld_overview.txt b/doc/lvmpolld_overview.txt
new file mode 100644
index 0000000..8c66e5e
--- /dev/null
+++ b/doc/lvmpolld_overview.txt
@@ -0,0 +1,81 @@
+LVM poll daemon overview
+========================
+
+(last updated: 2015-05-09)
+
+LVM poll daemon (lvmpolld) is the alternative for lvm2 classical polling
+mechanisms. The motivation behind new lvmpolld was to create persistent
+system service that would be more durable and transparent. It's suited
+particularly for any systemd enabled distribution.
+
+Before lvmpolld any background polling process originating in a lvm2 command
+initiated inside cgroup of a systemd service could get killed if the main
+process (service) exited in such cgroup. That could lead to premature termination
+of such lvm2 polling process.
+
+Also without lvmpolld there were no means to detect a particular polling process
+suited for monitoring of specific operation is already in-progress and therefore
+it's not desirable to start next one with exactly same task. lvmpolld is able to
+detect such duplicate requests and not spawn such redundant process.
+
+lvmpolld is primarily targeted for systems with systemd as init process. For systems
+without systemd there's no need to install lvmpolld because there is no issue
+with observation described in second paragraph. You can still benefit from
+avoiding duplicate polling process being spawned, but without systemd lvmpolld
+can't easily be run on-demand (activated by a socket maintained by systemd).
+
+lvmpolld implement shutdown on idle and can shutdown automatically when idle
+for requested time. 60 second is recommended default here. This behaviour can be
+turned off if found useless.
+
+Data structures
+---------------
+
+a) Logical Volume (struct lvmpolld_lv)
+
+Each operation is identified by LV. Internal identifier within lvmpolld
+is full LV uuid (vg_uuid+lv_uuid) prefixed with LVM_SYSTEM_DIR if set by client.
+
+such full identifier may look like:
+
+  "/etc/lvm/lvm.confWFd2dU67S8Av29IcJCnYzqQirdfElnxzhCdzEh7EJrfCn9R1TIQjIj58weUZDre4"
+
+or without LVM_SYSTEM_DIR being set explicitly:
+
+  "WFd2dU67S8Av29IcJCnYzqQirdfElnxzhCdzEh7EJrfCn9R1TIQjIj58weUZDre4"
+
+
+LV carries various metadata about polling operation. The most significant are:
+
+VG name
+LV name
+polling interval (usually --interval passed to lvm2 command or default from lvm2 
+		  configuration)
+operation type (one of: pvmove, convert, merge, thin_merge)
+LVM_SYSTEM_DIR (if set, this is also passed among environment variables of lvpoll
+		command spawned by lvmpolld)
+
+b) LV stores (struct lvmpolld_store)
+
+lvmpolld uses two stores for Logical volumes (struct lvmpolld_lv). One store for polling
+operations in-progress. These operations are as of now: PV move, mirror up-conversion,
+classical snapshot merge, thin snapshot merge.
+
+The second store is suited only for pvmove --abort operations in-progress. Both
+stores are independent and identical LVs (pvmove /dev/sda3 and pvmove --abort /dev/sda3)
+can be run concurently from lvmpolld point of view (on lvm2 side the consistency is
+guaranteed by lvm2 locking mechanism).
+
+Locking order
+-------------
+
+There are two types of locks in lvmpolld. Each store has own store lock and each LV has
+own lv lock.
+
+Locking order is:
+1) store lock
+2) LV lock
+
+Each LV has to be inside a store. When daemon requires to take both locks it has
+to take a store lock first and LV lock has to be taken afterwards (after the
+appropriate store lock where the LV is being stored :))
diff --git a/include/.symlinks.in b/include/.symlinks.in
index 96f4a01..d6a95fd 100644
--- a/include/.symlinks.in
+++ b/include/.symlinks.in
@@ -1,6 +1,8 @@
 @top_srcdir@/daemons/clvmd/clvm.h
 @top_srcdir@/daemons/dmeventd/libdevmapper-event.h
 @top_srcdir@/daemons/lvmetad/lvmetad-client.h
+ at top_srcdir@/daemons/lvmpolld/lvmpolld-protocol.h
+ at top_srcdir@/daemons/lvmpolld/polling_ops.h
 @top_srcdir@/liblvm/lvm2app.h
 @top_srcdir@/lib/activate/activate.h
 @top_srcdir@/lib/activate/targets.h
@@ -29,6 +31,8 @@
 @top_srcdir@/lib/locking/locking.h
 @top_srcdir@/lib/log/log.h
 @top_srcdir@/lib/log/lvm-logging.h
+ at top_srcdir@/lib/lvmpolld/lvmpolld-client.h
+ at top_srcdir@/lib/lvmpolld/polldaemon.h
 @top_srcdir@/lib/metadata/lv.h
 @top_srcdir@/lib/metadata/lv_alloc.h
 @top_srcdir@/lib/metadata/metadata.h
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 749342d..4a282eb 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -196,6 +196,11 @@ ifeq ("@BUILD_LVMETAD@", "yes")
 	cache/lvmetad.c
 endif
 
+ifeq ("@BUILD_LVMPOLLD@", "yes")
+  SOURCES +=\
+	lvmpolld/lvmpolld-client.c
+endif
+
 ifeq ("@DMEVENTD@", "yes")
   CLDFLAGS += -L$(top_builddir)/daemons/dmeventd
   LIBS += -ldevmapper-event
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index fb0e94d..43d878b 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -30,6 +30,7 @@
 #include "lvmcache.h"
 #include "lvmetad.h"
 #include "archiver.h"
+#include "lvmpolld-client.h"
 
 #ifdef HAVE_LIBDL
 #include "sharedlib.h"
@@ -475,6 +476,7 @@ static int _process_config(struct cmd_context *cmd)
 	const struct dm_config_value *cv;
 	int64_t pv_min_kb;
 	const char *lvmetad_socket;
+	const char *lvmpolld_socket;
 	int udev_disabled = 0;
 	char sysfs_dir[PATH_MAX];
 
@@ -618,6 +620,7 @@ static int _process_config(struct cmd_context *cmd)
 		(find_config_tree_bool(cmd, global_detect_internal_vg_cache_corruption_CFG, NULL));
 
 	lvmetad_disconnect();
+	lvmpolld_disconnect();
 
 	lvmetad_socket = getenv("LVM_LVMETAD_SOCKET");
 	if (!lvmetad_socket)
@@ -644,6 +647,13 @@ static int _process_config(struct cmd_context *cmd)
 	if (!_init_system_id(cmd))
 		return_0;
 
+	lvmpolld_socket = getenv("LVM_LVMPOLLD_SOCKET");
+	if (!lvmpolld_socket)
+		lvmpolld_socket = DEFAULT_RUN_DIR "/lvmpolld.socket";
+	lvmpolld_set_socket(lvmpolld_socket);
+
+	lvmpolld_set_active(find_config_tree_bool(cmd, global_use_lvmpolld_CFG, NULL));
+
 	return 1;
 }
 
@@ -2065,6 +2075,7 @@ void destroy_toolcontext(struct cmd_context *cmd)
 
 	lvmetad_release_token();
 	lvmetad_disconnect();
+	lvmpolld_disconnect();
 
 	release_log_memory();
 	activation_exit();
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 31609d4..59a7c1c 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -920,6 +920,15 @@ cfg(activation_checks_CFG, "checks", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, D
 	"Some of the checks may be expensive, so it's best to use\n"
 	"this only when there seems to be a problem.\n")
 
+cfg(global_use_lvmpolld_CFG, "use_lvmpolld", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 120), NULL, 0, NULL,
+	"Indicates whether to use lvmpolld instead of classical polldaemon (a process\n"
+	"forked off an initiating lvm command) or not. When set to 1 and native systemd\n"
+	"service is installed in the system lvm starts using lvmpolld. lvmpolld gets\n"
+	"auto-activated by systemd when a message lands on the respective lvmpolld socket.\n"
+	"All commands that would require polling of in-progress operation are therefore\n"
+	"spawned in lvmpolld's service cgroup.\n"
+	"When set to 0 lvm falls back to classical polling.\n")
+
 cfg(activation_udev_sync_CFG, "udev_sync", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_UDEV_SYNC, vsn(2, 2, 51), NULL, 0, NULL,
 	"Use udev notifications to synchronize udev and LVM.\n"
 	"When disabled, LVM commands will not wait for notifications\n"
diff --git a/lib/lvmpolld/lvmpolld-client.c b/lib/lvmpolld/lvmpolld-client.c
new file mode 100644
index 0000000..ee8860f
--- /dev/null
+++ b/lib/lvmpolld/lvmpolld-client.c
@@ -0,0 +1,311 @@
+/*
+ * Copyright (C) 2015 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "lib.h"
+
+#include "daemon-io.h"
+#include "lvmpolld-client.h"
+#include "lvmpolld-protocol.h"
+#include "metadata-exported.h"
+#include "polldaemon.h"
+#include "toolcontext.h"
+
+struct progress_info {
+	unsigned error:1;
+	unsigned finished:1;
+	int cmd_signal;
+	int cmd_retcode;
+};
+
+static int _lvmpolld_use;
+static int _lvmpolld_connected;
+static const char* _lvmpolld_socket;
+
+static daemon_handle _lvmpolld = { .error = 0 };
+
+static daemon_handle _lvmpolld_connect(const char *socket)
+{
+	daemon_info lvmpolld_info = {
+		.path = "lvmpolld",
+		.socket = socket ?: LVMPOLLD_SOCKET,
+		.protocol = LVMPOLLD_PROTOCOL,
+		.protocol_version = LVMPOLLD_PROTOCOL_VERSION
+	};
+
+	return daemon_open(lvmpolld_info);
+}
+
+void lvmpolld_set_active(int active)
+{
+	_lvmpolld_use = active;
+}
+
+void lvmpolld_set_socket(const char *socket)
+{
+	_lvmpolld_socket = socket;
+}
+
+int lvmpolld_use(void)
+{
+	if (!_lvmpolld_use)
+		return 0;
+
+	if (!_lvmpolld_connected && !_lvmpolld.error) {
+		_lvmpolld = _lvmpolld_connect(_lvmpolld_socket);
+		_lvmpolld_connected = _lvmpolld.socket_fd >= 0;
+	}
+
+	return _lvmpolld_connected;
+}
+
+void lvmpolld_disconnect(void)
+{
+	if (_lvmpolld_connected) {
+		daemon_close(_lvmpolld);
+		_lvmpolld_connected = 0;
+	}
+}
+
+static void _process_error_response(daemon_reply rep)
+{
+	if (!strcmp(daemon_reply_str(rep, "response", ""), LVMPD_RESP_FAILED))
+		log_error("lvmpolld failed to process a request. The reason was: %s.",
+			  daemon_reply_str(rep, "reason", "<empty>"));
+	else if (!strcmp(daemon_reply_str(rep, "response", ""), LVMPD_RESP_EINVAL))
+		log_error("lvmpolld couldn't handle a request. "
+			  "It might be due to daemon internal state. The reason was: %s.",
+			  daemon_reply_str(rep, "reason", "<empty>"));
+	else
+		log_error("Unexpected response %s. The reason: %s.",
+			  daemon_reply_str(rep, "response", "<empty>"),
+			  daemon_reply_str(rep, "reason", "<empty>"));
+
+	log_print_unless_silent("For more detailed information see lvmpolld log file.");
+}
+
+static struct progress_info _request_progress_info(const char *uuid, unsigned abort_polling)
+{
+	daemon_reply rep;
+	const char *e = getenv("LVM_SYSTEM_DIR");
+	struct progress_info ret = { .error = 1, .finished = 1 };
+	daemon_request req = daemon_request_make(LVMPD_REQ_PROGRESS);
+
+	if (!daemon_request_extend(req, LVMPD_PARM_LVID " = %s", uuid, NULL)) {
+		log_error("Failed to create " LVMPD_REQ_PROGRESS " request.");
+		goto out_req;
+	}
+
+	if (abort_polling &&
+	    !daemon_request_extend(req, LVMPD_PARM_ABORT " = %d", abort_polling, NULL)) {
+		log_error("Failed to create " LVMPD_REQ_PROGRESS " request.");
+		goto out_req;
+	}
+
+	if (e &&
+	    !(daemon_request_extend(req, LVMPD_PARM_SYSDIR " = %s",
+				    e, NULL))) {
+		log_error("Failed to create " LVMPD_REQ_PROGRESS " request.");
+		goto out_req;
+	}
+
+	rep = daemon_send(_lvmpolld, req);
+	if (rep.error) {
+		log_error("Failed to process request with error %s (errno: %d).",
+			  strerror(rep.error), rep.error);
+		goto out_rep;
+	}
+
+	if (!strcmp(daemon_reply_str(rep, "response", ""), LVMPD_RESP_IN_PROGRESS)) {
+		ret.finished = 0;
+		ret.error = 0;
+	} else if (!strcmp(daemon_reply_str(rep, "response", ""), LVMPD_RESP_FINISHED)) {
+		if (!strcmp(daemon_reply_str(rep, "reason", ""), LVMPD_REAS_SIGNAL))
+			ret.cmd_signal = daemon_reply_int(rep, LVMPD_PARM_VALUE, 0);
+		else
+			ret.cmd_retcode = daemon_reply_int(rep, LVMPD_PARM_VALUE, -1);
+		ret.error = 0;
+	} else if (!strcmp(daemon_reply_str(rep, "response", ""), LVMPD_RESP_NOT_FOUND)) {
+		log_verbose("No polling operation in progress regarding LV %s.", uuid);
+		ret.error = 0;
+	} else {
+		_process_error_response(rep);
+		stack;
+	}
+
+out_rep:
+	daemon_reply_destroy(rep);
+out_req:
+	daemon_request_destroy(req);
+
+	return ret;
+}
+
+/*
+ * interval in seconds long
+ * enough for more than a year
+ * of waiting
+ */
+#define INTERV_SIZE 10
+
+static int _process_poll_init(const struct cmd_context *cmd, const char *poll_type,
+			      const struct poll_operation_id *id, const struct daemon_parms *parms)
+{
+	char *str;
+	daemon_reply rep;
+	daemon_request req;
+	const char *e = getenv("LVM_SYSTEM_DIR");
+	int r = 0; 
+
+	str = dm_malloc(INTERV_SIZE * sizeof(char));
+	if (!str)
+		return r;
+
+	if (snprintf(str, INTERV_SIZE, "%u", parms->interval) >= INTERV_SIZE) {
+		log_warn("Interval string conversion got truncated.");
+		str[INTERV_SIZE - 1] = '\0';
+	}
+
+	req = daemon_request_make(poll_type);
+	if (!daemon_request_extend(req, LVMPD_PARM_LVID " = %s", id->uuid,
+					LVMPD_PARM_VGNAME " = %s", id->vg_name,
+					LVMPD_PARM_LVNAME " = %s", id->lv_name,
+					LVMPD_PARM_INTERVAL " = %s", str,
+					"cmdline = %s", cmd->cmd_line, /* FIXME: debug param only */
+					NULL)) {
+		log_error("Failed to create %s request.", poll_type);
+		goto out_req;
+	}
+
+	if (parms->aborting &&
+	    !(daemon_request_extend(req, LVMPD_PARM_ABORT " = %d", parms->aborting, NULL))) {
+		log_error("Failed to create %s request." , poll_type);
+		goto out_req;
+	}
+
+	if (cmd->handles_missing_pvs &&
+	    !(daemon_request_extend(req, LVMPD_PARM_HANDLE_MISSING_PVS " = %d",
+				    cmd->handles_missing_pvs, NULL))) {
+		log_error("Failed to create %s request." , poll_type);
+		goto out_req;
+	}
+
+	if (e &&
+	    !(daemon_request_extend(req, LVMPD_PARM_SYSDIR " = %s",
+				    e, NULL))) {
+		log_error("Failed to create %s request." , poll_type);
+		goto out_req;
+	}
+
+	rep = daemon_send(_lvmpolld, req);
+
+	if (rep.error) {
+		log_error("Failed to process request with error %s (errno: %d).",
+			  strerror(rep.error), rep.error);
+		goto out_rep;
+	}
+
+	if (!strcmp(daemon_reply_str(rep, "response", ""), LVMPD_RESP_OK))
+		r = 1;
+	else {
+		_process_error_response(rep);
+		stack;
+	}
+
+out_rep:
+	daemon_reply_destroy(rep);
+out_req:
+	daemon_request_destroy(req);
+	dm_free(str);
+
+	return r;
+}
+
+int lvmpolld_poll_init(const struct cmd_context *cmd, const struct poll_operation_id *id,
+		       const struct daemon_parms *parms)
+{
+	int r = 0;
+
+	if (!id->uuid) {
+		log_error(INTERNAL_ERROR "Use of lvmpolld requires uuid set");
+		return 0;
+	}
+
+	if (!id->vg_name) {
+		log_error(INTERNAL_ERROR "Use of lvmpolld requires vgname set");
+		return 0;
+	}
+
+	if (!id->lv_name) {
+		log_error(INTERNAL_ERROR "Use of lvmpolld requires lvname set");
+		return 0;
+	}
+
+	if (parms->lv_type & PVMOVE) {
+		log_verbose("lvmpolld: Requesting pvmove%s", parms->aborting ? " abort." : ".");
+		r =  _process_poll_init(cmd, LVMPD_REQ_PVMOVE, id, parms);
+	} else if (parms->lv_type & CONVERTING) {
+		log_verbose("lvmpolld: Requesting convert mirror.");
+		r =  _process_poll_init(cmd, LVMPD_REQ_CONVERT, id, parms);
+	} else if (parms->lv_type & MERGING) {
+		if (parms->lv_type & SNAPSHOT) {
+			log_verbose("lvmpolld: Requesting snapshot merge.");
+			r =  _process_poll_init(cmd, LVMPD_REQ_MERGE, id, parms);
+		}
+		else if (parms->lv_type & THIN_VOLUME) {
+			log_verbose("lvmpolld: Thin snapshot merge.");
+			r = _process_poll_init(cmd, LVMPD_REQ_MERGE_THIN, id, parms);
+		}
+		else {
+			log_error(INTERNAL_ERROR "Unsupported poll operation.");
+		}
+	} else
+		log_error(INTERNAL_ERROR "Unsupported poll operation");
+
+	return r;
+}
+
+int lvmpolld_request_info(const struct poll_operation_id *id, const struct daemon_parms *parms, unsigned *finished)
+{
+	struct progress_info info;
+	int ret = 0;
+
+	*finished = 1;
+
+	if (!id->uuid) {
+		log_error(INTERNAL_ERROR "use of lvmpolld requires uuid being set");
+		return 0;
+	}
+
+	info = _request_progress_info(id->uuid, parms->aborting);
+	*finished = info.finished;
+
+	if (info.error)
+		return_0;
+
+	if (info.finished) {
+		if (info.cmd_signal)
+			log_error("Polling command got terminated by signal (%d).",
+				  info.cmd_signal);
+		else if (info.cmd_retcode)
+			log_error("Polling command exited with return code: %d.",
+				  info.cmd_retcode);
+		else  {
+			log_verbose("Polling finished successfully.");
+			ret = 1;
+		}
+	} else
+		ret = 1;
+
+	return ret;
+}
diff --git a/lib/lvmpolld/lvmpolld-client.h b/lib/lvmpolld/lvmpolld-client.h
new file mode 100644
index 0000000..09dd959
--- /dev/null
+++ b/lib/lvmpolld/lvmpolld-client.h
@@ -0,0 +1,52 @@
+/*
+ * Copyright (C) 2014-2015 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef _LVM_LVMPOLLD_CLIENT_H
+#define _LVM_LVMPOLLD_CLIENT_H
+#  ifdef LVMPOLLD_SUPPORT
+
+#	include "daemon-client.h"
+
+#	define LVMPOLLD_SOCKET DEFAULT_RUN_DIR "/lvmpolld.socket"
+
+struct cmd_context;
+struct poll_operation_id;
+struct daemon_parms;
+
+void lvmpolld_disconnect(void);
+
+int lvmpolld_poll_init(const struct cmd_context *cmd, const struct poll_operation_id *id,
+		       const struct daemon_parms *parms);
+
+int lvmpolld_request_info(const struct poll_operation_id *id, const struct daemon_parms *parms,
+			  unsigned *finished);
+
+int lvmpolld_use(void);
+
+void lvmpolld_set_active(int active);
+
+void lvmpolld_set_socket(const char *socket);
+
+#  else
+
+#	define lvmpolld_disconnect() do {} while (0)
+#	define lvmpolld_poll_init(cmd, id, parms) (0)
+#	define lvmpolld_request_info(id, parms, finished) (0)
+#	define lvmpolld_use() (0)
+#	define lvmpolld_set_active(active) do {} while (0)
+#	define lvmpolld_set_socket(socket) do {} while (0)
+
+#  endif /* LVMPOLLD_SUPPORT */
+
+#endif /* _LVM_LVMPOLLD_CLIENT_H */
diff --git a/lib/lvmpolld/polldaemon.h b/lib/lvmpolld/polldaemon.h
new file mode 100644
index 0000000..6309a5f
--- /dev/null
+++ b/lib/lvmpolld/polldaemon.h
@@ -0,0 +1,93 @@
+/*
+ * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef _LVM_TOOL_POLLDAEMON_H
+#define _LVM_TOOL_POLLDAEMON_H
+
+#include "metadata-exported.h"
+
+typedef enum {
+	PROGRESS_CHECK_FAILED = 0,
+	PROGRESS_UNFINISHED = 1,
+	PROGRESS_FINISHED_SEGMENT = 2,
+	PROGRESS_FINISHED_ALL = 3
+} progress_t;
+
+struct daemon_parms;
+
+struct poll_functions {
+	const char *(*get_copy_name_from_lv) (const struct logical_volume *lv);
+	struct volume_group *(*get_copy_vg) (struct cmd_context *cmd,
+					     const char *name,
+					     const char *uuid,
+					     uint32_t flags);
+	struct logical_volume *(*get_copy_lv) (struct cmd_context *cmd,
+					       struct volume_group *vg,
+					       const char *name,
+					       const char *uuid,
+					       uint64_t lv_type);
+	progress_t (*poll_progress)(struct cmd_context *cmd,
+				    struct logical_volume *lv,
+				    const char *name,
+				    struct daemon_parms *parms);
+	int (*update_metadata) (struct cmd_context *cmd,
+				struct volume_group *vg,
+				struct logical_volume *lv,
+				struct dm_list *lvs_changed, unsigned flags);
+	int (*finish_copy) (struct cmd_context *cmd,
+			    struct volume_group *vg,
+			    struct logical_volume *lv,
+			    struct dm_list *lvs_changed);
+};
+
+struct poll_operation_id {
+	const char *vg_name;
+	const char *lv_name;
+	const char *display_name;
+	const char *uuid;
+};
+
+struct daemon_parms {
+	unsigned interval;
+	unsigned wait_before_testing;
+	unsigned aborting;
+	unsigned background;
+	unsigned outstanding_count;
+	unsigned progress_display;
+	const char *progress_title;
+	uint64_t lv_type;
+	struct poll_functions *poll_fns;
+};
+
+int poll_daemon(struct cmd_context *cmd, unsigned background,
+		uint64_t lv_type, struct poll_functions *poll_fns,
+		const char *progress_title, struct poll_operation_id *id);
+
+progress_t poll_mirror_progress(struct cmd_context *cmd,
+				struct logical_volume *lv, const char *name,
+				struct daemon_parms *parms);
+
+struct volume_group *poll_get_copy_vg(struct cmd_context *cmd, const char *name,
+				      const char *uuid, uint32_t flags);
+
+struct logical_volume *poll_get_copy_lv(struct cmd_context *cmd,
+					struct volume_group *vg,
+					const char *name, const char *uuid,
+					uint64_t lv_type);
+
+int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
+		       struct daemon_parms *parms);
+
+#endif
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 48ae3f6..45a8462 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -500,6 +500,12 @@
 /* Define to 1 to include code that uses lvmetad. */
 #undef LVMETAD_SUPPORT
 
+/* Path to lvmpolld pidfile. */
+#undef LVMPOLLD_PIDFILE
+
+/* Define to 1 to include code that uses lvmpolld. */
+#undef LVMPOLLD_SUPPORT
+
 /* Path to lvm binary. */
 #undef LVM_PATH
 
diff --git a/libdaemon/Makefile.in b/libdaemon/Makefile.in
index dbe6516..c0379a4 100644
--- a/libdaemon/Makefile.in
+++ b/libdaemon/Makefile.in
@@ -19,7 +19,7 @@ top_builddir = @top_builddir@
 
 SUBDIRS += client
 
-ifeq ("@BUILD_LVMETAD@", "yes")
+ifeq (yes, $(shell test @BUILD_LVMETAD@ == yes -o @BUILD_LVMPOLLD@ == yes && echo yes))
   SUBDIRS += server
 server: client
 endif
diff --git a/make.tmpl.in b/make.tmpl.in
index 5b98ae1..1cac75e 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -491,7 +491,7 @@ distclean: cleandir $(SUBDIRS.distclean)
 		 echo "	local:"; echo "		*;"; echo "};") > $@
 
 ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov \
- help check check_local check_cluster check_lvmetad))
+ help check check_local check_cluster check_lvmetad check_lvmpolld))
     ifdef SOURCES
        -include $(SOURCES:.c=.d) $(CXXSOURCES:.cpp=.d)
     endif
diff --git a/man/Makefile.in b/man/Makefile.in
index b93c5cb..fd92372 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -40,6 +40,12 @@ else
 LVMETAD =
 endif
 
+ifeq ("@BUILD_LVMPOLLD@", "yes")
+LVMPOLLD = lvmpolld.8
+else
+LVMPOLLD =
+endif
+
 MAN5=lvm.conf.5
 MAN7=lvmsystemid.7
 MAN8=lvm-config.8 lvm-dumpconfig.8 \
@@ -50,7 +56,7 @@ MAN8=lvm-config.8 lvm-dumpconfig.8 \
 	pvresize.8 pvs.8 pvscan.8 vgcfgbackup.8 vgcfgrestore.8 vgchange.8 \
 	vgck.8 vgcreate.8 vgconvert.8 vgdisplay.8 vgexport.8 vgextend.8 \
 	vgimport.8 vgimportclone.8 vgmerge.8 vgmknodes.8 vgreduce.8 vgremove.8 \
-	vgrename.8 vgs.8 vgscan.8 vgsplit.8 $(FSADMMAN) $(LVMETAD)
+	vgrename.8 vgs.8 vgscan.8 vgsplit.8 $(FSADMMAN) $(LVMETAD) $(LVMPOLLD)
 
 ifneq ("@CLVMD@", "none")
   MAN8CLUSTER=clvmd.8
diff --git a/man/lvm.8.in b/man/lvm.8.in
index 298d05b..28769d2 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -525,6 +525,12 @@ Path for the lvmetad pid file.
 .TP
 .B LVM_LVMETAD_SOCKET
 Path for the lvmetad socket file.
+.TP
+.B LVM_LVMPOLLD_PIDFILE
+Path for the lvmpolld pid file.
+.TP
+.B LVM_LVMPOLLD_SOCKET
+Path for the lvmpolld socket file.
 .SH FILES
 .I #DEFAULT_SYS_DIR#/lvm.conf
 .br
diff --git a/man/lvmpolld.8.in b/man/lvmpolld.8.in
new file mode 100644
index 0000000..8573395
--- /dev/null
+++ b/man/lvmpolld.8.in
@@ -0,0 +1,86 @@
+.TH LVMETAD 8 "LVM TOOLS #VERSION#" "Red Hat Inc" \" -*- nroff -*-
+.SH NAME
+lvmpolld \(em LVM poll daemon
+.SH SYNOPSIS
+.B lvmpolld
+.RB [ \-l
+.RI { all | wire | debug }]
+.RB [ \-p
+.IR pidfile_path ]
+.RB [ \-s
+.IR socket_path ]
+.RB [ \-B
+.IR lvm_binary_path ]
+.RB [ \-t
+.IR timeout_value ]
+.RB [ \-f ]
+.RB [ \-h ]
+.RB [ \-V ]
+.RB [ \-? ]
+.SH DESCRIPTION
+lvmpolld is polling daemon for LVM. The daemon receives requests for polling
+of already initialised operations originating in LVM2 command line tool.
+The requests for polling originates in \fBlvconvert\fP, \fBpvmove\fP,
+\fBlvchange\fP or \fBvgchange\fP LVM2 command.
+
+The purpose of lvmpolld is to reduce the number of spawned background processes
+per otherwise unique polling operation. There should be only one. It also eliminates
+the possibility of unsolicited termination of background process by external factors.
+
+lvmpolld is used by LVM only if it is enabled in \fBlvm.conf\fP(5) by specifying the
+\fBglobal/use_lvmpolld\fP setting. If this is not defined in the LVM configuration
+explicitly then default setting is used instead (see the output of
+\fBlvmconfig \-\-type default global/use_lvmpolld\fP command).
+.SH OPTIONS
+
+To run the daemon in a test environment both the pidfile_path and the
+socket_path should be changed from the defaults.
+.TP
+.B \-f
+Don't fork, but run in the foreground.
+.TP
+.BR \-h ", " \-?
+Show help information.
+.TP
+.IR \fB\-l " {" all | wire | debug }
+Select the type of log messages to generate.
+Messages are logged by syslog.
+Additionally, when \-f is given they are also sent to standard error.
+There are two classes of messages: wire and debug. Selecting 'all' supplies both
+and is equivalent to a comma-separated list \-l wire,debug.
+.TP
+.B \-p \fIpidfile_path
+Path to the pidfile. This overrides both the built-in default
+(#DEFAULT_PID_DIR#/lvmpolld.pid) and the environment variable
+\fBLVM_LVMPOLLD_PIDFILE\fP.  This file is used to prevent more
+than one instance of the daemon running simultaneously.
+.TP
+.B \-s \fIsocket_path
+Path to the socket file. This overrides both the built-in default
+(#DEFAULT_RUN_DIR#/lvmpolld.socket) and the environment variable
+\fBLVM_LVMPOLLD_SOCKET\fP.
+.TP
+.B \-t \fItimeout_value
+When runs as native systemd service daemon may shutdown after being
+idle for the given time (in seconds). When the option is omitted or
+the value given is zero the daemon never shutdowns on idle. When
+the daemon doesn't run as native systemd service the timeout is
+ignored and never shutdowns on idle.
+.TP
+.B \-B \fIlvm_binary_path
+Optional path to alternative LVM binary (default: #LVM_PATH#). Use for
+testing purposes only.
+.TP
+.B \-V
+Display the version of lvmpolld daemon.
+.SH ENVIRONMENT VARIABLES
+.TP
+.B LVM_LVMPOLLD_PIDFILE
+Path for the pid file.
+.TP
+.B LVM_LVMPOLLD_SOCKET
+Path for the socket file.
+
+.SH SEE ALSO
+.BR lvm (8),
+.BR lvm.conf (5)
diff --git a/scripts/.gitignore b/scripts/.gitignore
index 6fd8a2d..2b9162d 100644
--- a/scripts/.gitignore
+++ b/scripts/.gitignore
@@ -4,6 +4,9 @@ dm_event_systemd_red_hat.service
 lvm2_lvmetad_init_red_hat
 lvm2_lvmetad_systemd_red_hat.service
 lvm2_lvmetad_systemd_red_hat.socket
+lvm2_lvmpolld_init_red_hat
+lvm2_lvmpolld_systemd_red_hat.service
+lvm2_lvmpolld_systemd_red_hat.socket
 lvm2_monitoring_init_red_hat
 lvm2_monitoring_systemd_red_hat.service
 lvm2_tmpfiles_red_hat.conf
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 60797ef..e9cce3a 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -75,6 +75,9 @@ endif
 ifeq ("@BUILD_LVMETAD@", "yes")
 	$(INSTALL_SCRIPT) lvm2_lvmetad_init_red_hat $(initdir)/lvm2-lvmetad
 endif
+ifeq ("@BUILD_LVMPOLLD@", "yes")
+	$(INSTALL_SCRIPT) lvm2_lvmpolld_init_red_hat $(initdir)/lvm2-lvmpolld
+endif
 ifneq ("@CLVMD@", "none")
 	$(INSTALL_SCRIPT) clvmd_init_red_hat $(initdir)/clvmd
 endif
@@ -114,6 +117,10 @@ ifeq ("@BUILD_LVMETAD@", "yes")
 	$(INSTALL_DATA) lvm2_lvmetad_systemd_red_hat.service $(systemd_unit_dir)/lvm2-lvmetad.service
 	$(INSTALL_DATA) lvm2_pvscan_systemd_red_hat at .service $(systemd_unit_dir)/lvm2-pvscan at .service
 endif
+ifeq ("@BUILD_LVMPOLLD@", "yes")
+	$(INSTALL_DATA) lvm2_lvmpolld_systemd_red_hat.socket $(systemd_unit_dir)/lvm2-lvmpolld.socket
+	$(INSTALL_DATA) lvm2_lvmpolld_systemd_red_hat.service $(systemd_unit_dir)/lvm2-lvmpolld.service
+endif
 ifneq ("@CLVMD@", "none")
 	$(INSTALL_DATA) lvm2_clvmd_systemd_red_hat.service $(systemd_unit_dir)/lvm2-clvmd.service
 	$(INSTALL_DATA) lvm2_cluster_activation_systemd_red_hat.service $(systemd_unit_dir)/lvm2-cluster-activation.service
@@ -142,6 +149,8 @@ DISTCLEAN_TARGETS += \
 	lvm2_lvmetad_init_red_hat \
 	lvm2_lvmetad_systemd_red_hat.service \
 	lvm2_lvmetad_systemd_red_hat.socket \
+	lvm2_lvmpolld_systemd_red_hat.service \
+	lvm2_lvmpolld_systemd_red_hat.socket \
 	lvm2_monitoring_init_red_hat \
 	lvm2_monitoring_systemd_red_hat.service \
 	lvm2_pvscan_systemd_red_hat at .service \
diff --git a/scripts/lvm2_lvmpolld_init_red_hat.in b/scripts/lvm2_lvmpolld_init_red_hat.in
new file mode 100644
index 0000000..0a03f01
--- /dev/null
+++ b/scripts/lvm2_lvmpolld_init_red_hat.in
@@ -0,0 +1,114 @@
+#!/bin/bash
+#
+# Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+#
+# This file is part of LVM2.
+# It is required for the proper handling of failures of LVM2 mirror
+# devices that were created using the -m option of lvcreate.
+#
+#
+# chkconfig: 12345 02 99
+# description: Starts and stops LVM poll daemon
+#
+# For Red-Hat-based distributions such as Fedora, RHEL, CentOS.
+#
+### BEGIN INIT INFO
+# Provides: lvm2-lvmpolld
+# Required-Start: $local_fs
+# Required-Stop: $local_fs
+# Default-Start: 1 2 3 4 5
+# Default-Stop: 0 6
+# Short-Description: A daemon that is responsible for monitoring in-progress
+#		     and possibly longer term operations on logical volumes. 
+#		     It helps to reduce the number of spawned processes if same
+#                    logical volume is requested to get monitored multiple times.
+#                    Also avoids unsolicited termination due to external factors.
+### END INIT INFO
+
+. /etc/init.d/functions
+
+DAEMON=lvmpolld
+
+exec_prefix=@exec_prefix@
+sbindir=@sbindir@
+
+LOCK_FILE="/var/lock/subsys/$DAEMON"
+PID_FILE="@LVMPOLLD_PIDFILE@"
+
+rh_status() {
+	status -p $PID_FILE $DAEMON
+}
+
+rh_status_q() {
+	rh_status >/dev/null 2>&1
+}
+
+start()
+{
+	ret=0
+	action "Starting LVM poll daemon:" $DAEMON || ret=$?
+	return $ret
+}
+
+
+stop()
+{
+	ret=0
+	action "Signaling LVM poll daemon to exit:" killproc -p $PID_FILE $DAEMON -TERM || ret=$?
+	return $ret
+}
+
+rtrn=1
+
+# See how we were called.
+case "$1" in
+  start)
+	rh_status_q && exit 0
+	start
+	rtrn=$?
+	[ $rtrn = 0 ] && touch $LOCK_FILE
+	;;
+
+  stop|force-stop)
+	rh_status_q || exit 0
+	stop
+	rtrn=$?
+	[ $rtrn = 0 ] && rm -f $LOCK_FILE
+	;;
+
+  restart)
+	if stop
+	then
+		start
+	fi
+	rtrn=$?
+	;;
+
+  condrestart|try-restart)
+	rh_status_q || exit 0
+	if stop
+	then
+		start
+	fi
+	rtrn=$?
+	;;
+
+  status)
+	rh_status
+	rtrn=$?
+	;;
+
+  *)
+	echo $"Usage: $0 {start|stop|force-stop|restart|condrestart|try-restart|status}"
+	;;
+esac
+
+exit $rtrn
diff --git a/scripts/lvm2_lvmpolld_systemd_red_hat.service.in b/scripts/lvm2_lvmpolld_systemd_red_hat.service.in
new file mode 100644
index 0000000..d7ff492
--- /dev/null
+++ b/scripts/lvm2_lvmpolld_systemd_red_hat.service.in
@@ -0,0 +1,17 @@
+[Unit]
+Description=LVM2 poll daemon
+Documentation=man:lvmpolld(8)
+Requires=lvm2-lvmpolld.socket
+After=lvm2-lvmpolld.socket
+DefaultDependencies=no
+Conflicts=shutdown.target
+
+[Service]
+Type=simple
+NonBlocking=true
+ExecStart=@sbindir@/lvmpolld -t 60 -f
+Environment=SD_ACTIVATION=1
+PIDFile=@LVMPOLLD_PIDFILE@
+
+[Install]
+WantedBy=sysinit.target
diff --git a/scripts/lvm2_lvmpolld_systemd_red_hat.socket.in b/scripts/lvm2_lvmpolld_systemd_red_hat.socket.in
new file mode 100644
index 0000000..ca9f123
--- /dev/null
+++ b/scripts/lvm2_lvmpolld_systemd_red_hat.socket.in
@@ -0,0 +1,12 @@
+[Unit]
+Description=LVM2 poll daemon socket
+Documentation=man:lvmpolld(8)
+DefaultDependencies=no
+
+[Socket]
+ListenStream=@DEFAULT_RUN_DIR@/lvmpolld.socket
+SocketMode=0600
+RemoveOnStop=true
+
+[Install]
+WantedBy=sysinit.target
diff --git a/scripts/lvmdump.sh b/scripts/lvmdump.sh
index 9229912..879dd0c 100755
--- a/scripts/lvmdump.sh
+++ b/scripts/lvmdump.sh
@@ -1,7 +1,7 @@
 #!/bin/bash
 # We use some bash-isms (getopts?)
 
-# Copyright (C) 2007-2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2015 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -41,6 +41,7 @@ NC=nc
 LVM=${LVM_BINARY-lvm}
 DMSETUP=${DMSETUP_BINARY-dmsetup}
 LVMETAD_SOCKET=${LVM_LVMETAD_SOCKET-/var/run/lvm/lvmetad.socket}
+LVMPOLLD_SOCKET=${LVM_LVMPOLLD_SOCKET-/var/run/lvm/lvmpolld.socket}
 
 die() {
     code=$1; shift
@@ -59,6 +60,7 @@ function usage {
 	echo "    -c if running clvmd, gather cluster data as well"
 	echo "    -d <directory> dump into a directory instead of tarball"
 	echo "    -l gather lvmetad state if running"
+	echo "    -p gather lvmpolld state if running"
 	echo "    -m gather LVM metadata from the PVs"
 	echo "    -s gather system info and context"
 	echo "    -u gather udev info and context"
@@ -72,13 +74,14 @@ clustered=0
 metadata=0
 sysreport=0
 udev=0
-while getopts :acd:hlmus opt; do
+while getopts :acd:hlpmus opt; do
 	case $opt in 
 		a)	advanced=1 ;;
 		c)	clustered=1 ;;
 		d)	userdir=$OPTARG ;;
 		h)	usage ;;
 		l)	lvmetad=1 ;;
+		p)	lvmpolld=1 ;;
 		m)	metadata=1 ;;
 		s)      sysreport=1 ;;
 		u)	udev=1 ;;
@@ -236,6 +239,7 @@ if (( $metadata )); then
 	done
 fi
 
+# FIXME: add lvmpolld.service here
 if (( $sysreport )); then
 	myecho "Gathering system info..."
 
@@ -296,6 +300,22 @@ if (( $lvmetad )); then
     } > "$dir/lvmetad.txt"
 fi
 
+if (( $lvmpolld )); then
+    (echo 'request="dump"'; echo '##') | {
+	if type -p $SOCAT >& /dev/null; then
+	    echo "$SOCAT unix-connect:$LVMPOLLD_SOCKET -" >> "$log"
+	    $SOCAT "unix-connect:$LVMPOLLD_SOCKET" - 2>> "$log"
+	elif echo | $NC -U "$LVMPOLLD_SOCKET"; then
+	    echo "$NC -U $LVMPOLLD_SOCKET" >> "$log"
+	    $NC -U "$LVMPOLLD_SOCKET" 2>> "$log"
+	else
+	    myecho "WARNING: Neither socat nor nc -U seems to be available." 1>&2
+	    echo "# DUMP FAILED"
+	    return 1
+	fi
+    } > "$dir/lvmpolld.txt"
+fi
+
 if test -z "$userdir"; then
 	lvm_dump="$dirbase.tgz"
 	myecho "Creating report tarball in $HOME/$lvm_dump..."
diff --git a/test/Makefile.in b/test/Makefile.in
index 4144d14..051a38e 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -56,6 +56,11 @@ LVMETAD_NDEV_FLAVOUR = ,ndev-lvmetad
 LVMETAD_UDEV_FLAVOUR = ,udev-lvmetad
 endif
 
+ifeq ("@BUILD_LVMPOLLD@", "yes")
+LVMPOLLD_RUN_BASE = $(RUN_BASE)
+LVMPOLLD_NDEV_FLAVOUR = ,ndev-lvmpolld,ndev-cluster-lvmpolld,ndev-lvmetad-lvmpolld
+LVMPOLLD_UDEV_FLAVOUR = ,udev-lvmpolld,udev-cluster-lvmpolld,udev-lvmetad-lvmpolld
+endif
 
 # Shell quote;
 SHELL_PATH_SQ = $(subst ','\'',$(SHELL_PATH))
@@ -73,6 +78,7 @@ help:
 	@echo "  check_local		Run tests without clvmd and lvmetad."
 	@echo "  check_cluster		Run tests with cluster daemon."
 	@echo "  check_lvmetad		Run tests with lvmetad daemon."
+	@echo "  check_lvmpolld         Run tests with lvmpolld daemon."
 	@echo "  clean			Clean dir."
 	@echo "  help			Display callable targets."
 	@echo -e "\nSupported variables:"
@@ -83,6 +89,7 @@ help:
 	@echo "  LVM_TEST_LOCKING	Normal (1), Cluster (3)."
 	@echo "  LVM_TEST_LVMETAD	Start lvmetad (1)."
 	@echo "  LVM_TEST_LVMETAD_DEBUG_OPTS  Allows to override debug opts [-l all]."
+	@echo "  LVM_TEST_LVMPOLLD	Start lvmpolld"
 	@echo "  LVM_TEST_NODEBUG	Do not debug lvm commands."
 	@echo "  LVM_TEST_PARALLEL	May skip agresive wipe of LVMTEST resources."
 	@echo "  LVM_TEST_RESULTS	Where to create result files [results]."
@@ -109,12 +116,12 @@ help:
 check: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir $(LVM_TEST_RESULTS) \
-		--flavours ndev-vanilla,ndev-cluster$(LVMETAD_NDEV_FLAVOUR) --only $(T) --skip $(S)
+		--flavours ndev-vanilla,ndev-cluster$(LVMETAD_NDEV_FLAVOUR)$(LVMPOLLD_NDEV_FLAVOUR) --only $(T) --skip $(S)
 
 check_system: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir $(LVM_TEST_RESULTS) \
-		--flavours udev-vanilla,udev-cluster$(LVMETAD_UDEV_FLAVOUR) --only $(T) --skip $(S)
+		--flavours udev-vanilla,udev-cluster$(LVMETAD_UDEV_FLAVOUR)$(LVMPOLLD_UDEV_FLAVOUR) --only $(T) --skip $(S)
 
 check_cluster: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
@@ -133,11 +140,21 @@ check_lvmetad: .tests-stamp
 		--flavours ndev-lvmetad --only $(T) --skip $(S)
 endif
 
+ifeq ("@BUILD_LVMPOLLD@", "yes")
+check_lvmpolld: .tests-stamp
+	VERBOSE=$(VERBOSE) ./lib/runner \
+		--testdir . --outdir results \
+		--flavours udev-lvmpolld,udev-cluster-lvmpolld,udev-lvmetad-lvmpolld --only $(T) --skip $(S)
+endif
+
 DATADIR = $(datadir)/lvm2-testsuite
 EXECDIR = $(libexecdir)/lvm2-testsuite
 
 LIB_FLAVOURS = lib/flavour-ndev-vanilla lib/flavour-ndev-cluster lib/flavour-ndev-lvmetad \
-               lib/flavour-udev-vanilla lib/flavour-udev-cluster lib/flavour-udev-lvmetad
+               lib/flavour-udev-vanilla lib/flavour-udev-cluster lib/flavour-udev-lvmetad \
+	       lib/flavour-udev-lvmpolld lib/flavour-ndev-lvmpolld lib/flavour-ndev-cluster-lvmpolld \
+	       lib/flavour-ndev-lvmetad-lvmpolld lib/flavour-udev-lvmpolld lib/flavour-udev-cluster-lvmpolld \
+	       lib/flavour-udev-lvmetad-lvmpolld
 
 LIB_LOCAL = lib/paths lib/runner
 LIB_EXEC  = lib/not lib/invalid lib/fail lib/should
@@ -190,6 +207,7 @@ lib/paths-common: $(srcdir)/Makefile.in .lib-dir-stamp Makefile
 	echo 'export RAID=@RAID@' >> $@-t
 	echo 'export CACHE=@CACHE@' >> $@-t
 	echo 'export LVMETAD_PIDFILE="@LVMETAD_PIDFILE@"' >> $@-t
+	echo 'export LVMPOLLD_PIDFILE="@LVMPOLLD_PIDFILE@"' >> $@-t
 	echo 'export DMEVENTD_PIDFILE="@DMEVENTD_PIDFILE@"' >> $@-t
 	echo 'export CLVMD_PIDFILE="@CLVMD_PIDFILE@"' >> $@-t
 	echo 'export LVM_TEST_THIN_CHECK_CMD=$${LVM_TEST_THIN_CHECK_CMD- at THIN_CHECK_CMD@}' >> $@-t
@@ -240,6 +258,7 @@ LIB = $(LIB_SHARED) $(LIB_LOCAL) $(LIB_EXEC) $(LIB_FLAVOURS)
 	ln -fs $(abs_top_builddir)/daemons/clvmd/clvmd lib/clvmd
 	ln -fs $(abs_top_builddir)/daemons/dmeventd/dmeventd lib/dmeventd
 	ln -fs $(abs_top_builddir)/daemons/lvmetad/lvmetad lib/lvmetad
+	ln -fs $(abs_top_builddir)/daemons/lvmpolld/lvmpolld lib/lvmpolld
 	ln -fs $(abs_top_srcdir)/scripts/vgimportclone.sh lib/vgimportclone
 	ln -fs $(abs_top_srcdir)/scripts/fsadm.sh lib/fsadm
 	ln -fs $(abs_top_srcdir)/conf/thin-performance.profile lib/thin-performance.profile
@@ -256,7 +275,8 @@ CLEAN_TARGETS += .lib-dir-stamp .tests-stamp $(LIB) $(addprefix lib/,$(CMDS)) \
 	lib/clvmd lib/dmeventd lib/dmsetup lib/lvmetad lib/fsadm lib/vgimportclone \
 	lib/thin-performance.profile lib/harness \
 	lib/paths-installed lib/paths-installed-t \
-	lib/paths-common lib/paths-common-t
+	lib/paths-common lib/paths-common-t \
+	lib/lvmpolld
 
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index d1d38f8..cb0fe4f 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -136,6 +136,47 @@ notify_lvmetad() {
 	fi
 }
 
+prepare_lvmpolld() {
+	set -x
+	rm -f debug.log
+	# skip if we don't have our own lvmpolld...
+	(which lvmpolld 2>/dev/null | grep "$abs_builddir") || skip
+
+	lvmconf "global/use_lvmpolld = 1"
+
+	local run_valgrind=
+	test "${LVM_VALGRIND_LVMPOLLD:-0}" -eq 0 || run_valgrind="run_valgrind"
+
+	kill_sleep_kill_ LOCAL_LVMPOLLD ${LVM_VALGRIND_LVMPOLLD:-0}
+
+	echo "preparing lvmpolld..."
+	$run_valgrind lvmpolld -f "$@" -s "$TESTDIR/lvmpolld.socket" -B "$TESTDIR/lib/lvm" -l all &
+	echo $! > LOCAL_LVMPOLLD
+	while ! test -e "$TESTDIR/lvmpolld.socket"; do echo -n .; sleep .1; done # wait for the socket
+	echo ok
+}
+
+lvmpolld_talk() {
+	local use=nc
+	if type -p socat >& /dev/null; then
+		use=socat
+	elif echo | not nc -U "$TESTDIR/lvmpolld.socket" ; then
+		echo "WARNING: Neither socat nor nc -U seems to be available." 1>&2
+		echo "# failed to contact lvmpolld"
+		return 1
+	fi
+
+	if test "$use" = nc ; then
+		nc -U "$TESTDIR/lvmpolld.socket"
+	else
+		socat "unix-connect:$TESTDIR/lvmpolld.socket" -
+	fi | tee -a lvmpolld-talk.txt
+}
+
+lvmpolld_dump() {
+	(echo 'request="dump"'; echo '##') | lvmpolld_talk "$@"
+}
+
 teardown_devs_prefixed() {
 	local prefix=$1
 	local stray=${2:-0}
@@ -286,6 +327,10 @@ teardown() {
 			$vg $vg1 $vg2 $vg3 $vg4 &>/dev/null || rm -f debug.log strace.log
 	}
 
+	kill_sleep_kill_ LOCAL_LVMPOLLD ${LVM_VALGRIND_LVMPOLLD:-0}
+
+	echo -n .
+
 	kill_sleep_kill_ LOCAL_CLVMD ${LVM_VALGRIND_CLVMD:-0}
 
 	echo -n .
@@ -1094,16 +1139,57 @@ dmsetup_wrapped() {
 	dmsetup "$@"
 }
 
+awk_parse_init_count_in_lvmpolld_dump() {
+	printf '%s' \
+	\
+	$'BEGINFILE { x=0; answ=0; FS="="; key="[[:space:]]*"vkey }' \
+	$'{' \
+		$'if (/.*{$/) { x++ }' \
+		$'else if (/.*}$/) { x-- }' \
+		$'else if ( x == 2 && $1 ~ key) { value=substr($2, 2); value=substr(value, 1, length(value) - 1); }' \
+		$'if ( x == 2 && value == vvalue && $1 ~ /[[:space:]]*init_requests_count/) { answ=$2 }' \
+		$'if (answ > 0) { exit 0 }' \
+	$'}' \
+	$'END { printf "%d", answ }'
+}
+
+check_lvmpolld_init_rq_count() {
+	local ret=$(awk -v vvalue="$2" -v vkey=${3:-lvname} "$(awk_parse_init_count_in_lvmpolld_dump)" lvmpolld_dump.txt)
+	test $ret -eq $1 || {
+		echo "check_lvmpolld_init_rq_count failed. Expected $1, got $ret"
+		return 1
+	}
+}
+
 wait_pvmove_lv_ready() {
 	# given sleep .1 this is about 60 secs of waiting
 	local retries=${2:-300}
-	while : ; do
-		test $retries -le 0 && die "Waiting for pvmove LV to get activated has timed out"
-		dmsetup info -c -o tables_loaded $1 > out 2>/dev/null|| true;
-		not grep Live out >/dev/null || break
-		sleep .1
-		retries=$((retries-1))
-	done
+
+	if [ -e LOCAL_LVMPOLLD ]; then
+		local lvid
+		while : ; do
+			test $retries -le 0 && die "Waiting for lvmpolld timed out"
+			test -n "$lvid" || {
+				lvid=$(get lv_field ${1//-/\/} vg_uuid,lv_uuid -a 2>/dev/null)
+				lvid=${lvid//\ /}
+				lvid=${lvid//-/}
+			}
+			test -z "$lvid" || {
+				lvmpolld_dump > lvmpolld_dump.txt
+				! check_lvmpolld_init_rq_count 1 $lvid lvid || break;
+			}
+			sleep .1
+			retries=$((retries-1))
+		done
+	else
+		while : ; do
+			test $retries -le 0 && die "Waiting for pvmove LV to get activated has timed out"
+			dmsetup info -c -o tables_loaded $1 > out 2>/dev/null|| true;
+			not grep Live out >/dev/null || break
+			sleep .1
+			retries=$((retries-1))
+		done
+	fi
 }
 
 # return total memory size in kB units
diff --git a/test/lib/flavour-ndev-cluster-lvmpolld.sh b/test/lib/flavour-ndev-cluster-lvmpolld.sh
new file mode 100644
index 0000000..fe31bb4
--- /dev/null
+++ b/test/lib/flavour-ndev-cluster-lvmpolld.sh
@@ -0,0 +1,2 @@
+export LVM_TEST_LOCKING=3
+export LVM_TEST_LVMPOLLD=1
diff --git a/test/lib/flavour-ndev-lvmetad-lvmpolld.sh b/test/lib/flavour-ndev-lvmetad-lvmpolld.sh
new file mode 100644
index 0000000..496b3bc
--- /dev/null
+++ b/test/lib/flavour-ndev-lvmetad-lvmpolld.sh
@@ -0,0 +1,3 @@
+export LVM_TEST_LOCKING=1
+export LVM_TEST_LVMETAD=1
+export LVM_TEST_LVMPOLLD=1
diff --git a/test/lib/flavour-ndev-lvmpolld.sh b/test/lib/flavour-ndev-lvmpolld.sh
new file mode 100644
index 0000000..0a70703
--- /dev/null
+++ b/test/lib/flavour-ndev-lvmpolld.sh
@@ -0,0 +1,2 @@
+export LVM_TEST_LOCKING=1
+export LVM_TEST_LVMPOLLD=1
diff --git a/test/lib/flavour-udev-cluster-lvmpolld.sh b/test/lib/flavour-udev-cluster-lvmpolld.sh
new file mode 100644
index 0000000..abf76e9
--- /dev/null
+++ b/test/lib/flavour-udev-cluster-lvmpolld.sh
@@ -0,0 +1,3 @@
+export LVM_TEST_LOCKING=3
+export LVM_TEST_LVMPOLLD=1
+export LVM_TEST_DEVDIR=/dev
diff --git a/test/lib/flavour-udev-lvmetad-lvmpolld.sh b/test/lib/flavour-udev-lvmetad-lvmpolld.sh
new file mode 100644
index 0000000..64253d1
--- /dev/null
+++ b/test/lib/flavour-udev-lvmetad-lvmpolld.sh
@@ -0,0 +1,4 @@
+export LVM_TEST_LOCKING=1
+export LVM_TEST_LVMETAD=1
+export LVM_TEST_LVMPOLLD=1
+export LVM_TEST_DEVDIR=/dev
diff --git a/test/lib/flavour-udev-lvmpolld.sh b/test/lib/flavour-udev-lvmpolld.sh
new file mode 100644
index 0000000..c7f40b5
--- /dev/null
+++ b/test/lib/flavour-udev-lvmpolld.sh
@@ -0,0 +1,3 @@
+export LVM_TEST_LOCKING=1
+export LVM_TEST_LVMPOLLD=1
+export LVM_TEST_DEVDIR=/dev
diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index cd6471c..1af0503 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -100,6 +100,13 @@ else
 	aux prepare_clvmd
 fi
 
+echo "LVM_TEST_LVMPOLLD=$LVM_TEST_LVMPOLLD"
+test -n "$LVM_TEST_LVMPOLLD" && {
+	export LVM_LVMPOLLD_SOCKET="$TESTDIR/lvmpolld.socket"
+	export LVM_LVMPOLLD_PIDFILE="$TESTDIR/lvmpolld.pid"
+	aux prepare_lvmpolld
+}
+
 echo "<======== Processing test: \"$TESTNAME\" ========>"
 
 set -vx
diff --git a/test/shell/000-basic.sh b/test/shell/000-basic.sh
index 027969e..573bbd1 100644
--- a/test/shell/000-basic.sh
+++ b/test/shell/000-basic.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 lvm version
 
 test -n "$abs_top_builddir" || skip
diff --git a/test/shell/activate-minor.sh b/test/shell/activate-minor.sh
index 1c5386c..d7ae5f9 100644
--- a/test/shell/activate-minor.sh
+++ b/test/shell/activate-minor.sh
@@ -14,6 +14,7 @@
 # Just skip this test if minor is already in use...
 dmsetup info | tee info
 egrep "^Major, minor: *[0-9]+, 123" info && skip
+test -e LOCAL_LVMPOLLD && skip
 
 aux prepare_vg 2
 lvcreate -a n --zero n -l 1 -n foo $vg
diff --git a/test/shell/activate-missing-segment.sh b/test/shell/activate-missing-segment.sh
index 5f43c72..988c9cb 100644
--- a/test/shell/activate-missing-segment.sh
+++ b/test/shell/activate-missing-segment.sh
@@ -18,6 +18,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_vg 2
 
 lvcreate -l100%FREE -n span $vg
diff --git a/test/shell/activate-missing.sh b/test/shell/activate-missing.sh
index 8e2ff1e..e33a6ef 100644
--- a/test/shell/activate-missing.sh
+++ b/test/shell/activate-missing.sh
@@ -18,6 +18,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_vg 4
 
 lvcreate -l1 -n linear1 $vg "$dev1"
diff --git a/test/shell/activate-partial.sh b/test/shell/activate-partial.sh
index 0b5d1b6..3720e1d 100644
--- a/test/shell/activate-partial.sh
+++ b/test/shell/activate-partial.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_vg 3
 
 lvcreate -aey --type mirror -m 1 -l 1 --nosync -n mirror $vg
diff --git a/test/shell/activation-skip.sh b/test/shell/activation-skip.sh
index ca562a7..5259d9d 100644
--- a/test/shell/activation-skip.sh
+++ b/test/shell/activation-skip.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 # Test skip activation flag  -k|--setactivationskip
 
 aux prepare_vg
diff --git a/test/shell/clvmd-restart.sh b/test/shell/clvmd-restart.sh
index cb06bf6..afe4834 100644
--- a/test/shell/clvmd-restart.sh
+++ b/test/shell/clvmd-restart.sh
@@ -16,6 +16,7 @@ export LVM_BINARY=lvm
 . lib/inittest
 
 # only clvmd based test, skip otherwise
+test -e LOCAL_LVMPOLLD && skip
 test -e LOCAL_CLVMD || skip
 read LOCAL_CLVMD < LOCAL_CLVMD
 
diff --git a/test/shell/covercmd.sh b/test/shell/covercmd.sh
index c84c967..5e47bd9 100644
--- a/test/shell/covercmd.sh
+++ b/test/shell/covercmd.sh
@@ -16,6 +16,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_pvs 5
 get_devs
 
diff --git a/test/shell/discards-thin.sh b/test/shell/discards-thin.sh
index a2cac52..8acb20d 100644
--- a/test/shell/discards-thin.sh
+++ b/test/shell/discards-thin.sh
@@ -15,6 +15,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 #
 # Main
 #
diff --git a/test/shell/dmeventd-restart.sh b/test/shell/dmeventd-restart.sh
index 022b8a8..a64509e 100644
--- a/test/shell/dmeventd-restart.sh
+++ b/test/shell/dmeventd-restart.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_dmeventd
 
 aux prepare_vg 5
diff --git a/test/shell/dumpconfig.sh b/test/shell/dumpconfig.sh
index f52157f..0d33761 100644
--- a/test/shell/dumpconfig.sh
+++ b/test/shell/dumpconfig.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 flatten() {
 	cat > flatten.config
 	for s in `egrep '^[a-z]+ {$' flatten.config | sed -e s,{$,,`; do
diff --git a/test/shell/error-usage.sh b/test/shell/error-usage.sh
index 61e282b..f617b61 100644
--- a/test/shell/error-usage.sh
+++ b/test/shell/error-usage.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 which md5sum || skip
 
 aux prepare_pvs 1
diff --git a/test/shell/fsadm.sh b/test/shell/fsadm.sh
index 368e747..12f1593 100644
--- a/test/shell/fsadm.sh
+++ b/test/shell/fsadm.sh
@@ -13,6 +13,8 @@ test_description='Exercise fsadm filesystem resize'
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_vg 1 100
 
 # set to "skip" to avoid testing given fs and test warning result
diff --git a/test/shell/inconsistent-metadata.sh b/test/shell/inconsistent-metadata.sh
index 69d1f33..a606330 100644
--- a/test/shell/inconsistent-metadata.sh
+++ b/test/shell/inconsistent-metadata.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_vg 3 12
 
 lvcreate -aye --type mirror -m 1 -l 1 -n mirror $vg
diff --git a/test/shell/listings.sh b/test/shell/listings.sh
index fcf6308..d018510 100644
--- a/test/shell/listings.sh
+++ b/test/shell/listings.sh
@@ -15,6 +15,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 5
 get_devs
 
diff --git a/test/shell/lock-blocking.sh b/test/shell/lock-blocking.sh
index 7c33067..5c004c9 100644
--- a/test/shell/lock-blocking.sh
+++ b/test/shell/lock-blocking.sh
@@ -13,8 +13,10 @@ test_description='test some blocking / non-blocking multi-vg operations'
 
 . lib/inittest
 
-aux prepare_devs 3
+test -e LOCAL_LVMPOLLD && skip
 test -e LOCAL_CLVMD && skip
+
+aux prepare_devs 3
 pvcreate "$dev1" "$dev2"
 vgcreate $vg "$dev1" "$dev2"
 
diff --git a/test/shell/lock-parallel.sh b/test/shell/lock-parallel.sh
index 98d3d4c..ebe6336 100644
--- a/test/shell/lock-parallel.sh
+++ b/test/shell/lock-parallel.sh
@@ -14,6 +14,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 which mkfs.ext3 || skip
 which fsck || skip
 
diff --git a/test/shell/lvchange-cache.sh b/test/shell/lvchange-cache.sh
index 20826fb..9ce0314 100644
--- a/test/shell/lvchange-cache.sh
+++ b/test/shell/lvchange-cache.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux have_cache 1 3 0 || skip
 aux prepare_vg 3
 
diff --git a/test/shell/lvchange-mirror.sh b/test/shell/lvchange-mirror.sh
index f28e486..bd4c868 100644
--- a/test/shell/lvchange-mirror.sh
+++ b/test/shell/lvchange-mirror.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 # FIXME RESYNC doesn't work in cluster with exclusive activation
 # seriously broken!
 test -e LOCAL_CLVMD && skip
diff --git a/test/shell/lvchange-partial-raid10.sh b/test/shell/lvchange-partial-raid10.sh
index 8014abd..d83d193 100644
--- a/test/shell/lvchange-partial-raid10.sh
+++ b/test/shell/lvchange-partial-raid10.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux have_raid 1 3 2 || skip
 
 aux prepare_vg 4
diff --git a/test/shell/lvchange-partial.sh b/test/shell/lvchange-partial.sh
index c65c07b..7b1f68d 100644
--- a/test/shell/lvchange-partial.sh
+++ b/test/shell/lvchange-partial.sh
@@ -11,6 +11,7 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
 
 aux prepare_vg 4
 
diff --git a/test/shell/lvchange-raid10.sh b/test/shell/lvchange-raid10.sh
index 0d17928..574ac7d 100644
--- a/test/shell/lvchange-raid10.sh
+++ b/test/shell/lvchange-raid10.sh
@@ -13,6 +13,8 @@ TEST_RAID=raid10
 
 . shell/lvchange-raid.sh
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux have_raid 1 5 2 || skip
 
 run_types raid10 -m 1 -i 2 "$dev1" "$dev2" "$dev3" "$dev4"
diff --git a/test/shell/lvchange-raid456.sh b/test/shell/lvchange-raid456.sh
index b1dd1db..bdce2e6 100644
--- a/test/shell/lvchange-raid456.sh
+++ b/test/shell/lvchange-raid456.sh
@@ -13,6 +13,8 @@ TEST_RAID=raid456
 
 . shell/lvchange-raid.sh
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux raid456_replace_works || skip
 aux have_raid 1 5 2 || skip
 
diff --git a/test/shell/lvchange-syncaction-raid.sh b/test/shell/lvchange-syncaction-raid.sh
index 9c51299..558157b 100644
--- a/test/shell/lvchange-syncaction-raid.sh
+++ b/test/shell/lvchange-syncaction-raid.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 # Proper mismatch count 1.5.2+ upstream, 1.3.5 < x < 1.4.0 in RHEL6
 aux have_raid 1 3 5 &&
   ! aux have_raid 1 4 0 ||
diff --git a/test/shell/lvchange-thin.sh b/test/shell/lvchange-thin.sh
index 87919bc..763bc34 100644
--- a/test/shell/lvchange-thin.sh
+++ b/test/shell/lvchange-thin.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux have_thin 1 0 0 || skip
 
 aux prepare_pvs 3
diff --git a/test/shell/lvconvert-cache-raid.sh b/test/shell/lvconvert-cache-raid.sh
index faab251..b8333d9 100644
--- a/test/shell/lvconvert-cache-raid.sh
+++ b/test/shell/lvconvert-cache-raid.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux have_cache 1 3 0 || skip
 aux have_raid 1 0 0 || skip
 
diff --git a/test/shell/lvconvert-cache-thin.sh b/test/shell/lvconvert-cache-thin.sh
index 87256a4..12b8dfe 100644
--- a/test/shell/lvconvert-cache-thin.sh
+++ b/test/shell/lvconvert-cache-thin.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux have_cache 1 3 0 || skip
 aux have_thin 1 0 0 || skip
 
diff --git a/test/shell/lvconvert-cache.sh b/test/shell/lvconvert-cache.sh
index ed414ed..6ac62c4 100644
--- a/test/shell/lvconvert-cache.sh
+++ b/test/shell/lvconvert-cache.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux have_cache 1 3 0 || skip
 
 aux prepare_vg 5 80
diff --git a/test/shell/lvconvert-raid-allocation.sh b/test/shell/lvconvert-raid-allocation.sh
index a1b1c39..f118d9c 100644
--- a/test/shell/lvconvert-raid-allocation.sh
+++ b/test/shell/lvconvert-raid-allocation.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux have_raid 1 3 0 || skip
 
 aux prepare_pvs 5
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index d3253eb..6529ee2 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -14,6 +14,8 @@ export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 get_image_pvs() {
 	local d
 	local images
diff --git a/test/shell/lvconvert-raid10.sh b/test/shell/lvconvert-raid10.sh
index c4b92f1..244a79e 100644
--- a/test/shell/lvconvert-raid10.sh
+++ b/test/shell/lvconvert-raid10.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 get_image_pvs() {
 	local d
 	local images
diff --git a/test/shell/lvconvert-raid456.sh b/test/shell/lvconvert-raid456.sh
index 833b10e..0fb5a5b 100644
--- a/test/shell/lvconvert-raid456.sh
+++ b/test/shell/lvconvert-raid456.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 get_image_pvs() {
 	local d
 	local images
diff --git a/test/shell/lvconvert-repair-dmeventd.sh b/test/shell/lvconvert-repair-dmeventd.sh
index eed0819..2acf461 100644
--- a/test/shell/lvconvert-repair-dmeventd.sh
+++ b/test/shell/lvconvert-repair-dmeventd.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 which mkfs.ext2 || skip
 aux mirror_recovery_works || skip
 
diff --git a/test/shell/lvconvert-repair-raid-dmeventd.sh b/test/shell/lvconvert-repair-raid-dmeventd.sh
index eeb424e..df55449 100644
--- a/test/shell/lvconvert-repair-raid-dmeventd.sh
+++ b/test/shell/lvconvert-repair-raid-dmeventd.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 which mkfs.ext3 || skip
 aux have_raid 1 3 0 || skip
 
diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index 6b1e51f..580516e 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux have_raid 1 3 0 || skip
 aux raid456_replace_works || skip
 
diff --git a/test/shell/lvconvert-repair-snapshot.sh b/test/shell/lvconvert-repair-snapshot.sh
index a0c0399..1bb4138 100644
--- a/test/shell/lvconvert-repair-snapshot.sh
+++ b/test/shell/lvconvert-repair-snapshot.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_vg 5
 aux lvmconf 'allocation/maximise_cling = 0' \
 	    'allocation/mirror_logs_require_separate_pvs = 1'
diff --git a/test/shell/lvconvert-repair-thin.sh b/test/shell/lvconvert-repair-thin.sh
index 73f061c..c699e12 100644
--- a/test/shell/lvconvert-repair-thin.sh
+++ b/test/shell/lvconvert-repair-thin.sh
@@ -14,6 +14,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 which mkfs.ext2 || skip
 
 #
diff --git a/test/shell/lvconvert-repair-transient-dmeventd.sh b/test/shell/lvconvert-repair-transient-dmeventd.sh
index 4f6171d..30fd47c 100644
--- a/test/shell/lvconvert-repair-transient-dmeventd.sh
+++ b/test/shell/lvconvert-repair-transient-dmeventd.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_dmeventd
 aux mirror_recovery_works || skip
 aux prepare_vg 5
diff --git a/test/shell/lvconvert-repair-transient.sh b/test/shell/lvconvert-repair-transient.sh
index c9253f4..52e1825 100644
--- a/test/shell/lvconvert-repair-transient.sh
+++ b/test/shell/lvconvert-repair-transient.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux mirror_recovery_works || skip
 aux prepare_vg 5
 
diff --git a/test/shell/lvconvert-snapshot.sh b/test/shell/lvconvert-snapshot.sh
index 55fcb1a..ad500e2 100644
--- a/test/shell/lvconvert-snapshot.sh
+++ b/test/shell/lvconvert-snapshot.sh
@@ -14,6 +14,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_pvs 1
 
 vgcreate -s 1k $vg $(cat DEVICES)
diff --git a/test/shell/lvconvert-thin-external.sh b/test/shell/lvconvert-thin-external.sh
index 1e9887a..b688d3a 100644
--- a/test/shell/lvconvert-thin-external.sh
+++ b/test/shell/lvconvert-thin-external.sh
@@ -14,6 +14,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 which mkfs.ext2 || skip
 which fsck || skip
 
diff --git a/test/shell/lvconvert-thin-raid.sh b/test/shell/lvconvert-thin-raid.sh
index 3d7eee5..8b4052c 100644
--- a/test/shell/lvconvert-thin-raid.sh
+++ b/test/shell/lvconvert-thin-raid.sh
@@ -12,6 +12,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux have_thin 1 0 0 || skip
 aux have_raid 1 4 0 || skip
 
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 951f694..b510589 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -12,6 +12,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 prepare_lvs() {
 	lvremove -f $vg
 	lvcreate -L10M -n $lv1 $vg
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index 89efc4d..9e245c6 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -16,6 +16,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux have_cache 1 3 0 || skip
 
 # FIXME: parallel cache metadata allocator is crashing when used value 8000!
diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index 182b267..c59eded 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 # FIXME  update test to make something useful on <16T
 aux can_use_16T || skip
 
diff --git a/test/shell/lvcreate-large-raid10.sh b/test/shell/lvcreate-large-raid10.sh
index de1cc02..47dda2b 100644
--- a/test/shell/lvcreate-large-raid10.sh
+++ b/test/shell/lvcreate-large-raid10.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 # FIXME  update test to make something useful on <16T
 aux can_use_16T || skip
 
diff --git a/test/shell/lvcreate-large.sh b/test/shell/lvcreate-large.sh
index 29bdd33..e547fcc 100644
--- a/test/shell/lvcreate-large.sh
+++ b/test/shell/lvcreate-large.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 # FIXME  update test to make something useful on <16T
 aux can_use_16T || skip
 
diff --git a/test/shell/lvcreate-mirror.sh b/test/shell/lvcreate-mirror.sh
index f62bee7..275c036 100644
--- a/test/shell/lvcreate-mirror.sh
+++ b/test/shell/lvcreate-mirror.sh
@@ -10,6 +10,9 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . lib/inittest
+
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_vg 5 80
 aux lvmconf 'allocation/maximise_cling = 0' \
 	    'allocation/mirror_logs_require_separate_pvs = 1'
diff --git a/test/shell/lvcreate-missing.sh b/test/shell/lvcreate-missing.sh
index 4553e98..012962f 100644
--- a/test/shell/lvcreate-missing.sh
+++ b/test/shell/lvcreate-missing.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_vg 2
 
 aux disable_dev "$dev1"
diff --git a/test/shell/lvcreate-operation.sh b/test/shell/lvcreate-operation.sh
index fac7219..3947bf8 100644
--- a/test/shell/lvcreate-operation.sh
+++ b/test/shell/lvcreate-operation.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 cleanup_lvs() {
 	lvremove -ff $vg
 	(dm_table | not grep $vg) || \
diff --git a/test/shell/lvcreate-pvtags.sh b/test/shell/lvcreate-pvtags.sh
index 6bfb55b..99a7f07 100644
--- a/test/shell/lvcreate-pvtags.sh
+++ b/test/shell/lvcreate-pvtags.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_pvs 3
 aux lvmconf 'allocation/maximise_cling = 0' \
 	    'allocation/mirror_logs_require_separate_pvs = 1'
diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index 956ebb5..2ddc7e3 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 lv_devices() {
 	test $3 -eq $(get lv_devices $1/$2 | wc -w)
 }
diff --git a/test/shell/lvcreate-raid10.sh b/test/shell/lvcreate-raid10.sh
index 5f22a2d..884653b 100644
--- a/test/shell/lvcreate-raid10.sh
+++ b/test/shell/lvcreate-raid10.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 lv_devices() {
 	test $3 -eq $(get lv_devices $1/$2 | wc -w)
 }
diff --git a/test/shell/lvcreate-repair.sh b/test/shell/lvcreate-repair.sh
index 1690565..469bf39 100644
--- a/test/shell/lvcreate-repair.sh
+++ b/test/shell/lvcreate-repair.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_vg 3
 
 # fail multiple devices
diff --git a/test/shell/lvcreate-signature-wiping.sh b/test/shell/lvcreate-signature-wiping.sh
index 32ef363..d2d23c5 100644
--- a/test/shell/lvcreate-signature-wiping.sh
+++ b/test/shell/lvcreate-signature-wiping.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 init_lv_() {
 	mkswap "$DM_DEV_DIR/$vg/$lv1"
 }
diff --git a/test/shell/lvcreate-small-snap.sh b/test/shell/lvcreate-small-snap.sh
index b29c5f8..b5610c7 100644
--- a/test/shell/lvcreate-small-snap.sh
+++ b/test/shell/lvcreate-small-snap.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_pvs
 
 vgcreate -s 1k $vg $(cat DEVICES)
diff --git a/test/shell/lvcreate-striped-mirror.sh b/test/shell/lvcreate-striped-mirror.sh
index eaa7fb8..735b396 100644
--- a/test/shell/lvcreate-striped-mirror.sh
+++ b/test/shell/lvcreate-striped-mirror.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_vg 9
 
 lvcreate -aey --nosync -i2 -l2 --type mirror -m1 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
diff --git a/test/shell/lvcreate-thin-big.sh b/test/shell/lvcreate-thin-big.sh
index 1a8fa30..0ef5cbc 100644
--- a/test/shell/lvcreate-thin-big.sh
+++ b/test/shell/lvcreate-thin-big.sh
@@ -15,6 +15,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux have_thin 1 0 0 || skip
 
 # Test --poolmetadatasize range
diff --git a/test/shell/lvcreate-thin-external.sh b/test/shell/lvcreate-thin-external.sh
index 65401fb..bb5cef2 100644
--- a/test/shell/lvcreate-thin-external.sh
+++ b/test/shell/lvcreate-thin-external.sh
@@ -14,6 +14,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 which mkfs.ext2 || skip
 which fsck || skip
 
diff --git a/test/shell/lvcreate-thin-power2.sh b/test/shell/lvcreate-thin-power2.sh
index ed62db3..fcae643 100644
--- a/test/shell/lvcreate-thin-power2.sh
+++ b/test/shell/lvcreate-thin-power2.sh
@@ -15,6 +15,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 #
 # Main
 #
diff --git a/test/shell/lvcreate-thin-snap.sh b/test/shell/lvcreate-thin-snap.sh
index 784eb5d..d801d4a 100644
--- a/test/shell/lvcreate-thin-snap.sh
+++ b/test/shell/lvcreate-thin-snap.sh
@@ -12,6 +12,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 check_lv_field_modules_()
 {
 	mod=$1
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 66d986b..18e4644 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -15,6 +15,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 check_lv_field_modules_()
 {
 	mod=$1
diff --git a/test/shell/lvextend-percent-extents.sh b/test/shell/lvextend-percent-extents.sh
index 9b5dc5d..ec98e59 100644
--- a/test/shell/lvextend-percent-extents.sh
+++ b/test/shell/lvextend-percent-extents.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_pvs 2 128
 vgcreate $vg $(cat DEVICES)
 
diff --git a/test/shell/lvextend-snapshot-dmeventd.sh b/test/shell/lvextend-snapshot-dmeventd.sh
index f073a81..1ad4864 100644
--- a/test/shell/lvextend-snapshot-dmeventd.sh
+++ b/test/shell/lvextend-snapshot-dmeventd.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 extend() {
 	lvextend --use-policies --config "activation { snapshot_autoextend_threshold = $1 }" $vg/snap
 }
diff --git a/test/shell/lvextend-snapshot-policy.sh b/test/shell/lvextend-snapshot-policy.sh
index b0a611e..c76e36e 100644
--- a/test/shell/lvextend-snapshot-policy.sh
+++ b/test/shell/lvextend-snapshot-policy.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 which mkfs.ext2 || skip
 
 extend() {
diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index d7be3a2..78dce6d 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -12,6 +12,8 @@
 # Test autoextension of thin metadata volume
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 meta_percent_() {
 	get lv_field $vg/pool metadata_percent | cut -d. -f1
 }
diff --git a/test/shell/lvextend-thin.sh b/test/shell/lvextend-thin.sh
index f9e24ce..ab538a7 100644
--- a/test/shell/lvextend-thin.sh
+++ b/test/shell/lvextend-thin.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux have_thin 1 0 0 || skip
 
 aux prepare_vg 3
diff --git a/test/shell/lvm-init.sh b/test/shell/lvm-init.sh
index c3f7ecf..cfdd4cc 100644
--- a/test/shell/lvm-init.sh
+++ b/test/shell/lvm-init.sh
@@ -15,6 +15,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 5
 
 # invalid units
diff --git a/test/shell/lvmcache-exercise.sh b/test/shell/lvmcache-exercise.sh
index 2aaf650..f0d3ee9 100644
--- a/test/shell/lvmcache-exercise.sh
+++ b/test/shell/lvmcache-exercise.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_pvs 5
 
 vgcreate $vg1 "$dev1"
diff --git a/test/shell/lvmetad-ambiguous.sh b/test/shell/lvmetad-ambiguous.sh
index 2e7c6c5..777a63e 100644
--- a/test/shell/lvmetad-ambiguous.sh
+++ b/test/shell/lvmetad-ambiguous.sh
@@ -12,6 +12,7 @@
 . lib/inittest
 
 test -e LOCAL_LVMETAD || skip
+test -e LOCAL_LVMPOLLD && skip
 
 aux prepare_pvs 2
 
diff --git a/test/shell/lvmetad-client-filter.sh b/test/shell/lvmetad-client-filter.sh
index 3002a47..5e6d967 100644
--- a/test/shell/lvmetad-client-filter.sh
+++ b/test/shell/lvmetad-client-filter.sh
@@ -12,6 +12,8 @@
 . lib/inittest
 
 test -e LOCAL_LVMETAD || skip
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_pvs 2
 
 pvs --config 'devices { filter = [ "r%.*%" ] }' 2>&1 | grep rejected
diff --git a/test/shell/lvmetad-disabled.sh b/test/shell/lvmetad-disabled.sh
index efdca16..9c71717 100644
--- a/test/shell/lvmetad-disabled.sh
+++ b/test/shell/lvmetad-disabled.sh
@@ -12,6 +12,8 @@
 . lib/inittest
 
 test -e LOCAL_LVMETAD || skip
+test -e LOCAL_LVMPOLLD && skip
+
 kill $(< LOCAL_LVMETAD)
 while test -e "$TESTDIR/lvmetad.socket"; do echo -n .; sleep .1; done # wait for the socket close
 test ! -e "$LVM_LVMETAD_PIDFILE"
diff --git a/test/shell/lvmetad-dump.sh b/test/shell/lvmetad-dump.sh
index 14d5753..631636e 100644
--- a/test/shell/lvmetad-dump.sh
+++ b/test/shell/lvmetad-dump.sh
@@ -10,7 +10,9 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . lib/inittest
+
 test -e LOCAL_LVMETAD || skip
+test -e LOCAL_LVMPOLLD && skip
 
 aux prepare_pvs 2
 vgcreate $vg1 "$dev1" "$dev2"
diff --git a/test/shell/lvmetad-lvm1.sh b/test/shell/lvmetad-lvm1.sh
index f071b14..f234b15 100644
--- a/test/shell/lvmetad-lvm1.sh
+++ b/test/shell/lvmetad-lvm1.sh
@@ -12,6 +12,8 @@
 . lib/inittest
 
 test -e LOCAL_LVMETAD || skip
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 2
 pvcreate --metadatatype 1 "$dev1"
 should vgscan --cache
diff --git a/test/shell/lvmetad-lvscan-cache.sh b/test/shell/lvmetad-lvscan-cache.sh
index 1d9d8a4..220e464 100644
--- a/test/shell/lvmetad-lvscan-cache.sh
+++ b/test/shell/lvmetad-lvscan-cache.sh
@@ -12,6 +12,7 @@
 . lib/inittest
 
 test -e LOCAL_LVMETAD || skip
+test -e LOCAL_LVMPOLLD && skip
 
 aux prepare_pvs 2
 
diff --git a/test/shell/lvmetad-no-cluster.sh b/test/shell/lvmetad-no-cluster.sh
index 85c1ea9..83fee47 100644
--- a/test/shell/lvmetad-no-cluster.sh
+++ b/test/shell/lvmetad-no-cluster.sh
@@ -12,6 +12,8 @@
 . lib/inittest
 
 test -e LOCAL_CLVMD || skip
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_vg 2
 aux prepare_lvmetad
 vgs -vv 2> errs
diff --git a/test/shell/lvmetad-override.sh b/test/shell/lvmetad-override.sh
index ea76b35..15ada7b 100644
--- a/test/shell/lvmetad-override.sh
+++ b/test/shell/lvmetad-override.sh
@@ -12,6 +12,8 @@
 . lib/inittest
 
 test -e LOCAL_LVMETAD || skip
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_pvs 2
 
 vgcreate $vg1 "$dev1" "$dev2"
diff --git a/test/shell/lvmetad-pvs.sh b/test/shell/lvmetad-pvs.sh
index 7f25490..81174f4 100644
--- a/test/shell/lvmetad-pvs.sh
+++ b/test/shell/lvmetad-pvs.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_pvs 1 20000
 pvs $(cat DEVICES) | grep "$dev1"
 
diff --git a/test/shell/lvmetad-pvscan-cache.sh b/test/shell/lvmetad-pvscan-cache.sh
index 75890a5..33b4d94 100644
--- a/test/shell/lvmetad-pvscan-cache.sh
+++ b/test/shell/lvmetad-pvscan-cache.sh
@@ -12,6 +12,7 @@
 . lib/inittest
 
 test -e LOCAL_LVMETAD || skip
+test -e LOCAL_LVMPOLLD && skip
 
 aux prepare_pvs 2
 
diff --git a/test/shell/lvmetad-pvscan-filter.sh b/test/shell/lvmetad-pvscan-filter.sh
index 05666df..b7bdf33 100644
--- a/test/shell/lvmetad-pvscan-filter.sh
+++ b/test/shell/lvmetad-pvscan-filter.sh
@@ -12,6 +12,7 @@
 . lib/inittest
 
 test -e LOCAL_LVMETAD || skip
+test -e LOCAL_LVMPOLLD && skip
 
 aux prepare_pvs 2
 
diff --git a/test/shell/lvmetad-pvscan-md.sh b/test/shell/lvmetad-pvscan-md.sh
index bfa6171..9c5e3fa 100644
--- a/test/shell/lvmetad-pvscan-md.sh
+++ b/test/shell/lvmetad-pvscan-md.sh
@@ -12,6 +12,7 @@
 . lib/inittest
 
 test -e LOCAL_LVMETAD || skip
+test -e LOCAL_LVMPOLLD && skip
 
 test -f /proc/mdstat && grep -q raid0 /proc/mdstat || \
 	modprobe raid0 || skip
diff --git a/test/shell/lvmetad-pvscan-nomda.sh b/test/shell/lvmetad-pvscan-nomda.sh
index 395e326..f7e13a7 100644
--- a/test/shell/lvmetad-pvscan-nomda.sh
+++ b/test/shell/lvmetad-pvscan-nomda.sh
@@ -12,6 +12,8 @@
 . lib/inittest
 
 test -e LOCAL_LVMETAD || skip
+test -e LOCAL_LVMPOLLD && skip
+
 kill $(< LOCAL_LVMETAD)
 rm LOCAL_LVMETAD
 
diff --git a/test/shell/lvmetad-restart.sh b/test/shell/lvmetad-restart.sh
index e4136df..8805bc8 100644
--- a/test/shell/lvmetad-restart.sh
+++ b/test/shell/lvmetad-restart.sh
@@ -12,6 +12,8 @@
 . lib/inittest
 
 test -e LOCAL_LVMETAD || skip
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_pvs 2
 
 vgcreate $vg1 "$dev1" "$dev2"
diff --git a/test/shell/lvmetad-test.sh b/test/shell/lvmetad-test.sh
index 6ebd9ad..146a7f1 100644
--- a/test/shell/lvmetad-test.sh
+++ b/test/shell/lvmetad-test.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_pvs 2
 
 vgcreate $vg1 "$dev1" "$dev2" --test
diff --git a/test/shell/lvmetad-warning.sh b/test/shell/lvmetad-warning.sh
index 52bd885..44edb12 100644
--- a/test/shell/lvmetad-warning.sh
+++ b/test/shell/lvmetad-warning.sh
@@ -12,6 +12,8 @@
 . lib/inittest
 
 test -e LOCAL_LVMETAD || skip
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_pvs 2
 
 vgcreate $vg1 "$dev1" "$dev2"
diff --git a/test/shell/lvresize-mirror.sh b/test/shell/lvresize-mirror.sh
index 0b9f526..423c9ed 100644
--- a/test/shell/lvresize-mirror.sh
+++ b/test/shell/lvresize-mirror.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_vg 5
 
 for deactivate in true false; do
diff --git a/test/shell/lvresize-raid.sh b/test/shell/lvresize-raid.sh
index 8c7d909..1a1a75f 100644
--- a/test/shell/lvresize-raid.sh
+++ b/test/shell/lvresize-raid.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux have_raid 1 3 0 || skip
 
 aux prepare_pvs 6 80
diff --git a/test/shell/lvresize-raid10.sh b/test/shell/lvresize-raid10.sh
index aead385..4fe49f6 100644
--- a/test/shell/lvresize-raid10.sh
+++ b/test/shell/lvresize-raid10.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux have_raid 1 3 0 || skip
 
 aux prepare_vg 5
diff --git a/test/shell/lvresize-rounding.sh b/test/shell/lvresize-rounding.sh
index 5c30539..398740e 100644
--- a/test/shell/lvresize-rounding.sh
+++ b/test/shell/lvresize-rounding.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_pvs 3 22
 
 vgcreate -s 32K $vg $(cat DEVICES)
diff --git a/test/shell/lvresize-thin-external-origin.sh b/test/shell/lvresize-thin-external-origin.sh
index e4463e2..82b7f8b 100644
--- a/test/shell/lvresize-thin-external-origin.sh
+++ b/test/shell/lvresize-thin-external-origin.sh
@@ -12,6 +12,8 @@
 # Test resize of thin volume with external origin
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux have_thin 1 2 0 || skip
 
 # Pretend we miss the external_origin_extend feature
diff --git a/test/shell/lvresize-thin-metadata.sh b/test/shell/lvresize-thin-metadata.sh
index 9e2ae4d..4416b67 100644
--- a/test/shell/lvresize-thin-metadata.sh
+++ b/test/shell/lvresize-thin-metadata.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux have_thin 1 10 0 || skip
 
 aux prepare_pvs 3 1256
diff --git a/test/shell/lvresize-usage.sh b/test/shell/lvresize-usage.sh
index a3ba2cf..00bae14 100644
--- a/test/shell/lvresize-usage.sh
+++ b/test/shell/lvresize-usage.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_vg 2 80
 
 lvcreate -L 10M -n lv -i2 $vg
diff --git a/test/shell/lvs-cache.sh b/test/shell/lvs-cache.sh
index 08e83bd..73706b7 100644
--- a/test/shell/lvs-cache.sh
+++ b/test/shell/lvs-cache.sh
@@ -16,6 +16,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux have_cache 1 3 0 || skip
 aux prepare_vg 5 8000
 
diff --git a/test/shell/mda-rollback.sh b/test/shell/mda-rollback.sh
index fa8e376..5f348fb 100644
--- a/test/shell/mda-rollback.sh
+++ b/test/shell/mda-rollback.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 3
 
 vgcreate --metadatasize 128k $vg1 "$dev1" "$dev2" "$dev3"
diff --git a/test/shell/mdata-strings.sh b/test/shell/mdata-strings.sh
index a1598ad..529e599 100644
--- a/test/shell/mdata-strings.sh
+++ b/test/shell/mdata-strings.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 # For udev impossible to create
 test "$LVM_TEST_DEVDIR" = "/dev" && skip
 
diff --git a/test/shell/metadata-balance.sh b/test/shell/metadata-balance.sh
index 5ee0eba..869297e 100644
--- a/test/shell/metadata-balance.sh
+++ b/test/shell/metadata-balance.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 6
 
 echo Make sure we can ignore / un-ignore mdas on a per-PV basis
diff --git a/test/shell/metadata-dirs.sh b/test/shell/metadata-dirs.sh
index f4a41bc..eed6512 100644
--- a/test/shell/metadata-dirs.sh
+++ b/test/shell/metadata-dirs.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 3
 
 pvcreate --metadatacopies 0 $(cat DEVICES)
diff --git a/test/shell/metadata.sh b/test/shell/metadata.sh
index 251942f..8e3503f 100644
--- a/test/shell/metadata.sh
+++ b/test/shell/metadata.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 5
 
 pvcreate "$dev1"
diff --git a/test/shell/mirror-names.sh b/test/shell/mirror-names.sh
index aa640c2..22372e1 100644
--- a/test/shell/mirror-names.sh
+++ b/test/shell/mirror-names.sh
@@ -42,6 +42,22 @@ lv_convert_lv_() {
 	get lv_field $1 convert_lv
 }
 
+enable_devs() {
+	aux enable_dev "$dev1"
+	aux enable_dev "$dev2"
+	aux enable_dev "$dev3"
+	aux enable_dev "$dev4"
+	aux enable_dev "$dev5"
+}
+
+delay_devs() {
+	aux delay_dev "$dev1" 0 1000 $(get first_extent_sector "$dev1"):
+	aux delay_dev "$dev2" 0 1000 $(get first_extent_sector "$dev2"):
+	aux delay_dev "$dev3" 0 1000 $(get first_extent_sector "$dev3"):
+	aux delay_dev "$dev4" 0 1000 $(get first_extent_sector "$dev4"):
+	aux delay_dev "$dev5" 0 1000 $(get first_extent_sector "$dev5"):
+}
+
 # ---------------------------------------------------------------------
 # Common environment setup/cleanup for each sub testcases
 
@@ -101,12 +117,14 @@ check_and_cleanup_lvs_
 
 #COMM "converting mirror names is ${lv1}_mimagetmp_2"
 lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg
+delay_devs
 LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -i+40 -b $vg/$lv1
 convlv=$(lv_convert_lv_ $vg/$lv1)
 test $convlv = ${lv1}_mimagetmp_2
 lv_devices_ $vg/$lv1 $convlv ${lv1}_mimage_2
 lv_devices_ $vg/$convlv ${lv1}_mimage_0 ${lv1}_mimage_1
 lv_mirror_log_ $vg/$convlv ${lv1}_mlog
+enable_devs
 
 #COMM "mirror log name after re-adding is ${lv1}_mlog" \
 lvconvert -f --mirrorlog core $vg/$lv1
diff --git a/test/shell/mirror-vgreduce-removemissing.sh b/test/shell/mirror-vgreduce-removemissing.sh
index e4791f8..40a6503 100644
--- a/test/shell/mirror-vgreduce-removemissing.sh
+++ b/test/shell/mirror-vgreduce-removemissing.sh
@@ -17,6 +17,8 @@ export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 lv_is_on_ ()
 {
 	local lv=$vg/$1
diff --git a/test/shell/name-mangling.sh b/test/shell/name-mangling.sh
index ee34994..6bdf4a1 100644
--- a/test/shell/name-mangling.sh
+++ b/test/shell/name-mangling.sh
@@ -15,6 +15,7 @@
 # so skip duplicate CLMVD and lvmetad test
 test -e LOCAL_CLVMD && skip
 test -e LOCAL_LVMETAD && skip
+test -e LOCAL_LVMPOLLD && skip
 
 CHARACTER_WHITELIST="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789#+-.:=@_"
 FAIL_MIXED_STR="contains mixed mangled and unmangled characters"
diff --git a/test/shell/nomda-missing.sh b/test/shell/nomda-missing.sh
index 7de458b..39c2ac9 100644
--- a/test/shell/nomda-missing.sh
+++ b/test/shell/nomda-missing.sh
@@ -12,6 +12,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 4
 pvcreate "$dev1" "$dev2"
 pvcreate --metadatacopies 0 "$dev3" "$dev4"
diff --git a/test/shell/nomda-restoremissing.sh b/test/shell/nomda-restoremissing.sh
index 01a77d0..9380c8d 100644
--- a/test/shell/nomda-restoremissing.sh
+++ b/test/shell/nomda-restoremissing.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_vg 3
 
 pvchange --metadataignore y "$dev1"
diff --git a/test/shell/orphan-ondisk.sh b/test/shell/orphan-ondisk.sh
index 8395073..f4e18f4 100644
--- a/test/shell/orphan-ondisk.sh
+++ b/test/shell/orphan-ondisk.sh
@@ -11,5 +11,7 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_vg 2
 vgreduce $vg "$dev1" 2>&1 | not grep -i 'parse error'
diff --git a/test/shell/pool-labels.sh b/test/shell/pool-labels.sh
index a2163e8..70d5a64 100644
--- a/test/shell/pool-labels.sh
+++ b/test/shell/pool-labels.sh
@@ -13,6 +13,7 @@
 
 # lvmetad does not handle pool labels so skip test.
 test ! -e LOCAL_LVMETAD || skip
+test -e LOCAL_LVMPOLLD && skip
 
 env printf "" || skip # skip if printf is not available
 
diff --git a/test/shell/process-each-duplicate-vgnames.sh b/test/shell/process-each-duplicate-vgnames.sh
index 9b1f807..f2b4765 100644
--- a/test/shell/process-each-duplicate-vgnames.sh
+++ b/test/shell/process-each-duplicate-vgnames.sh
@@ -9,6 +9,8 @@ test_description='Test vgs with duplicate vg names'
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 2
 
 pvcreate "$dev1"
diff --git a/test/shell/process-each-lv.sh b/test/shell/process-each-lv.sh
index bd9e042..78eb14e 100644
--- a/test/shell/process-each-lv.sh
+++ b/test/shell/process-each-lv.sh
@@ -16,6 +16,8 @@ export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 10
 
 #
diff --git a/test/shell/process-each-pv-nomda-all.sh b/test/shell/process-each-pv-nomda-all.sh
index 44cde5a..1a2af58 100644
--- a/test/shell/process-each-pv-nomda-all.sh
+++ b/test/shell/process-each-pv-nomda-all.sh
@@ -13,6 +13,8 @@ test_description='Test process_each_pv with zero mda'
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 14
 
 # for vg1
diff --git a/test/shell/process-each-pv-nomda.sh b/test/shell/process-each-pv-nomda.sh
index 82e6bc4..642f2e4 100644
--- a/test/shell/process-each-pv-nomda.sh
+++ b/test/shell/process-each-pv-nomda.sh
@@ -13,6 +13,8 @@ test_description='Test process_each_pv with zero mda'
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 2
 
 pvcreate "$dev1" --metadatacopies 0
diff --git a/test/shell/process-each-pv.sh b/test/shell/process-each-pv.sh
index d3a1863..f4b8fd1 100644
--- a/test/shell/process-each-pv.sh
+++ b/test/shell/process-each-pv.sh
@@ -13,6 +13,8 @@ test_description='Exercise toollib process_each_pv'
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 14
 
 #
diff --git a/test/shell/process-each-pvresize.sh b/test/shell/process-each-pvresize.sh
index 02fe081..493c24b 100644
--- a/test/shell/process-each-pvresize.sh
+++ b/test/shell/process-each-pvresize.sh
@@ -13,6 +13,8 @@ test_description='Exercise toollib process_each_pv'
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 14
 
 #
diff --git a/test/shell/process-each-vg.sh b/test/shell/process-each-vg.sh
index e8690f5..f93acda 100644
--- a/test/shell/process-each-vg.sh
+++ b/test/shell/process-each-vg.sh
@@ -13,6 +13,8 @@ test_description='Exercise toollib process_each_vg'
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 6
 
 #
diff --git a/test/shell/profiles-thin.sh b/test/shell/profiles-thin.sh
index d3e282a..9578ed1 100644
--- a/test/shell/profiles-thin.sh
+++ b/test/shell/profiles-thin.sh
@@ -15,6 +15,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 DEV_SIZE=32
 
 # check we have thinp support compiled in
diff --git a/test/shell/profiles.sh b/test/shell/profiles.sh
index e054c88..8187129 100644
--- a/test/shell/profiles.sh
+++ b/test/shell/profiles.sh
@@ -15,6 +15,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 MSG_FAILED_TO_APPLY_CMD_PROFILE="Failed to apply command profile"
 MSG_IGNORING_INVALID_CMD_PROFILE="Ignoring invalid command profile"
 MSG_FAILED_TO_APPLY_MDA_PROFILE="Failed to apply metadata profile"
diff --git a/test/shell/pv-duplicate-uuid.sh b/test/shell/pv-duplicate-uuid.sh
index 1763142..cc98384 100644
--- a/test/shell/pv-duplicate-uuid.sh
+++ b/test/shell/pv-duplicate-uuid.sh
@@ -12,6 +12,8 @@
 # Test 'Found duplicate' is shown
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 3
 
 pvcreate "$dev1"
diff --git a/test/shell/pv-duplicate.sh b/test/shell/pv-duplicate.sh
index 9b218e6..ecd6125 100644
--- a/test/shell/pv-duplicate.sh
+++ b/test/shell/pv-duplicate.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 3
 
 pvcreate "$dev1"
diff --git a/test/shell/pv-min-size.sh b/test/shell/pv-min-size.sh
index d29e94c..eb62c73 100644
--- a/test/shell/pv-min-size.sh
+++ b/test/shell/pv-min-size.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 # use small default size  - 512KB
 aux lvmconf 'devices/pv_min_size = 512'
 
diff --git a/test/shell/pvchange-usage.sh b/test/shell/pvchange-usage.sh
index e5695b6..8cffb06 100644
--- a/test/shell/pvchange-usage.sh
+++ b/test/shell/pvchange-usage.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 check_changed_uuid_() {
 	test "$1" != "$(get pv_field "$2" uuid)" || die "UUID has not changed!"
 }
diff --git a/test/shell/pvcreate-bootloaderarea.sh b/test/shell/pvcreate-bootloaderarea.sh
index 6dd45f5..68c0882 100644
--- a/test/shell/pvcreate-bootloaderarea.sh
+++ b/test/shell/pvcreate-bootloaderarea.sh
@@ -13,6 +13,8 @@ test_description='Test pvcreate bootloader area support'
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 1
 aux lvmconf 'global/suffix=0' 'global/units="b"'
 
diff --git a/test/shell/pvcreate-ff.sh b/test/shell/pvcreate-ff.sh
index 1cbf0ff..4ac5a61 100644
--- a/test/shell/pvcreate-ff.sh
+++ b/test/shell/pvcreate-ff.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 2
 pvcreate "$dev1"
 vgcreate foo "$dev1"
diff --git a/test/shell/pvcreate-metadata0.sh b/test/shell/pvcreate-metadata0.sh
index 263bd88..48ebc83 100644
--- a/test/shell/pvcreate-metadata0.sh
+++ b/test/shell/pvcreate-metadata0.sh
@@ -17,6 +17,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 2 128
 
 #lv_snap=$lv2
diff --git a/test/shell/pvcreate-operation-md.sh b/test/shell/pvcreate-operation-md.sh
index 8291215..db53216 100644
--- a/test/shell/pvcreate-operation-md.sh
+++ b/test/shell/pvcreate-operation-md.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 # skip this test if mdadm or sfdisk (or others) aren't available
 which sfdisk || skip
 
diff --git a/test/shell/pvcreate-operation.sh b/test/shell/pvcreate-operation.sh
index e72f2b9..6593877 100644
--- a/test/shell/pvcreate-operation.sh
+++ b/test/shell/pvcreate-operation.sh
@@ -10,6 +10,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux lvmconf 'devices/md_component_detection = 1'
 
 aux prepare_devs 4
diff --git a/test/shell/pvcreate-usage.sh b/test/shell/pvcreate-usage.sh
index 5e916c3..ed3b4f4 100644
--- a/test/shell/pvcreate-usage.sh
+++ b/test/shell/pvcreate-usage.sh
@@ -14,6 +14,8 @@ PAGESIZE=$(getconf PAGESIZE)
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 4
 
 #COMM 'pvcreate rejects negative setphysicalvolumesize'
diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index 1ef9a24..4f93983 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -32,12 +32,16 @@ lvextend -l+10 $vg/$lv1 "$dev2"
 lvextend -l+5 $vg/$lv1 "$dev1"
 lvextend -l+10 $vg/$lv1 "$dev2"
 
-pvmove -i0 -n $vg/$lv1 "$dev1" "$dev3" $mode &
+pvmove -i10 -n $vg/$lv1 "$dev1" "$dev3" $mode &
 PVMOVE=$!
 # Let's wait a bit till pvmove starts and kill it
 aux wait_pvmove_lv_ready "$vg-pvmove0"
-
 kill -9 $PVMOVE
+
+if test -e LOCAL_LVMPOLLD; then
+	aux prepare_lvmpolld
+fi
+
 wait
 
 # Simulate reboot - forcibly remove related devices
diff --git a/test/shell/pvmove-resume-1.sh b/test/shell/pvmove-resume-1.sh
index acf35ee..e8564fa 100644
--- a/test/shell/pvmove-resume-1.sh
+++ b/test/shell/pvmove-resume-1.sh
@@ -107,26 +107,50 @@ lvchange_single() {
 	LVM_TEST_TAG="kill_me_$PREFIX" lvchange -aey $vg/$lv1
 	LVM_TEST_TAG="kill_me_$PREFIX" lvchange -aey $vg1/$lv1
 
-	test $(aux count_processes_with_tag) -eq $1
+	if test -e LOCAL_LVMPOLLD; then
+		aux lvmpolld_dump | tee lvmpolld_dump.txt
+		aux check_lvmpolld_init_rq_count 1 "$vg/pvmove0"
+		aux check_lvmpolld_init_rq_count 1 "$vg1/pvmove0"
+	else
+		check_spawned_bg_procs_count $1
+	fi
 }
 
 lvchange_all() {
 	LVM_TEST_TAG="kill_me_$PREFIX" lvchange -aey $vg/$lv1 $vg1/$lv1
 
-	test $(aux count_processes_with_tag) -eq $1
+	if test -e LOCAL_LVMPOLLD; then
+		aux lvmpolld_dump | tee lvmpolld_dump.txt
+		aux check_lvmpolld_init_rq_count 1 "$vg/pvmove0"
+		aux check_lvmpolld_init_rq_count 1 "$vg1/pvmove0"
+	else
+		test $(aux count_processes_with_tag) -eq $1
+	fi
 }
 
 vgchange_single() {
 	LVM_TEST_TAG="kill_me_$PREFIX" vgchange -aey $vg
 	LVM_TEST_TAG="kill_me_$PREFIX" vgchange -aey $vg1
 
-	test $(aux count_processes_with_tag) -eq $1
+	if test -e LOCAL_LVMPOLLD; then
+		aux lvmpolld_dump | tee lvmpolld_dump.txt
+		aux check_lvmpolld_init_rq_count 1 "$vg/pvmove0"
+		aux check_lvmpolld_init_rq_count 1 "$vg1/pvmove0"
+	else
+		test $(aux count_processes_with_tag) -eq $1
+	fi
 }
 
 vgchange_all()  {
 	LVM_TEST_TAG="kill_me_$PREFIX" vgchange -aey $vg $vg1
 
-	test $(aux count_processes_with_tag) -eq $1
+	if test -e LOCAL_LVMPOLLD; then
+		aux lvmpolld_dump | tee lvmpolld_dump.txt
+		aux check_lvmpolld_init_rq_count 1 "$vg/pvmove0"
+		aux check_lvmpolld_init_rq_count 1 "$vg1/pvmove0"
+	else
+		test $(aux count_processes_with_tag) -eq $1
+	fi
 }
 
 pvmove_fg() {
@@ -134,7 +158,13 @@ pvmove_fg() {
 	LVM_TEST_TAG="kill_me_$PREFIX" vgchange --config 'activation{polling_interval=10}' -aey --poll n $vg $vg1
 
 	# ...also vgchange --poll n must not spawn any bg processes...
-	test $(aux count_processes_with_tag) -eq 0
+	if test -e LOCAL_LVMPOLLD; then
+		aux lvmpolld_dump | tee lvmpolld_dump.txt
+		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove0"
+		aux check_lvmpolld_init_rq_count 0 "$vg1/pvmove0"
+	else
+		test $(aux count_processes_with_tag) -eq 0
+	fi
 
 	# ...thus finish polling
 	get lv_field $vg name -a | grep "^\[pvmove0\]"
@@ -153,7 +183,13 @@ pvmove_bg() {
 	LVM_TEST_TAG="kill_me_$PREFIX" vgchange --config 'activation{polling_interval=10}' -aey --poll n $vg $vg1
 
 	# ...also vgchange --poll n must not spawn any bg processes...
-	test $(aux count_processes_with_tag) -eq 0
+	if test -e LOCAL_LVMPOLLD; then
+		aux lvmpolld_dump | tee lvmpolld_dump.txt
+		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove0"
+		aux check_lvmpolld_init_rq_count 0 "$vg1/pvmove0"
+	else
+		test $(aux count_processes_with_tag) -eq 0
+	fi
 
 	# ...thus finish polling
 	get lv_field $vg name -a | grep "^\[pvmove0\]"
@@ -167,7 +203,13 @@ pvmove_fg_single() {
 	LVM_TEST_TAG="kill_me_$PREFIX" vgchange --config 'activation{polling_interval=10}' -aey --poll n $vg
 
 	# ...also vgchange --poll n must not spawn any bg processes...
-	test $(aux count_processes_with_tag) -eq 0
+	if test -e LOCAL_LVMPOLLD; then
+		aux lvmpolld_dump | tee lvmpolld_dump.txt
+		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove0"
+		aux check_lvmpolld_init_rq_count 0 "$vg1/pvmove0"
+	else
+		test $(aux count_processes_with_tag) -eq 0
+	fi
 
 	# ...thus finish polling
 	get lv_field $vg name -a | grep "^\[pvmove0\]"
@@ -187,7 +229,13 @@ pvmove_bg_single() {
 	LVM_TEST_TAG="kill_me_$PREFIX" vgchange --config 'activation{polling_interval=10}' -aey --poll n $vg
 
 	# ...also vgchange --poll n must not spawn any bg processes...
-	test $(aux count_processes_with_tag) -eq 0
+	if test -e LOCAL_LVMPOLLD; then
+		aux lvmpolld_dump | tee lvmpolld_dump.txt
+		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove0"
+		aux check_lvmpolld_init_rq_count 0 "$vg1/pvmove0"
+	else
+		test $(aux count_processes_with_tag) -eq 0
+	fi
 
 	# ...thus finish polling
 	get lv_field $vg name -a | grep "^\[pvmove0\]"
diff --git a/test/shell/pvmove-resume-2.sh b/test/shell/pvmove-resume-2.sh
index 37a552d..5bdfd7d 100644
--- a/test/shell/pvmove-resume-2.sh
+++ b/test/shell/pvmove-resume-2.sh
@@ -95,13 +95,23 @@ lvchange_all() {
 	LVM_TEST_TAG="kill_me_$PREFIX" lvchange -vvvv -aey $vg/$lv1 $vg/$lv2
 
 	# we don't want to spawn more than $1 background pollings
-	test $(aux count_processes_with_tag) -eq $1 || should false
+	if test -e LOCAL_LVMPOLLD; then
+		aux lvmpolld_dump | tee lvmpolld_dump.txt
+		aux check_lvmpolld_init_rq_count 1 "$vg/pvmove0" || should false
+	else
+		test $(aux count_processes_with_tag) -eq $1 || should false
+	fi
 }
 
 vgchange_single() {
 	LVM_TEST_TAG="kill_me_$PREFIX" vgchange -aey $vg
 
-	test $(aux count_processes_with_tag) -eq $1
+	if test -e LOCAL_LVMPOLLD; then
+		aux lvmpolld_dump | tee lvmpolld_dump.txt
+		aux check_lvmpolld_init_rq_count 1 "$vg/pvmove0"
+	else
+		test $(aux count_processes_with_tag) -eq $1
+	fi
 }
 
 pvmove_fg() {
@@ -109,7 +119,12 @@ pvmove_fg() {
 	LVM_TEST_TAG="kill_me_$PREFIX" vgchange --config 'activation{polling_interval=10}' -aey --poll n $vg
 
 	# ...also vgchange --poll n must not spawn any bg processes
-	test $(aux count_processes_with_tag) -eq 0
+	if test -e LOCAL_LVMPOLLD; then
+		aux lvmpolld_dump | tee lvmpolld_dump.txt
+		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove0"
+	else
+		test $(aux count_processes_with_tag) -eq 0
+	fi
 
 	# ...thus finish polling
 	get lv_field $vg name -a | grep "^\[pvmove0\]"
@@ -124,7 +139,12 @@ pvmove_bg() {
 	LVM_TEST_TAG="kill_me_$PREFIX" vgchange --config 'activation{polling_interval=10}' -aey --poll n $vg
 
 	# ...also vgchange --poll n must not spawn any bg processes
-	test $(aux count_processes_with_tag) -eq 0
+	if test -e LOCAL_LVMPOLLD; then
+		aux lvmpolld_dump | tee lvmpolld_dump.txt
+		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove0"
+	else
+		test $(aux count_processes_with_tag) -eq 0
+	fi
 
 	# ...thus finish polling
 	get lv_field $vg name -a | grep "^\[pvmove0\]"
@@ -137,7 +157,12 @@ pvmove_fg_single() {
 	LVM_TEST_TAG="kill_me_$PREFIX" vgchange --config 'activation{polling_interval=10}' -aey --poll n $vg
 
 	# ...also vgchange --poll n must not spawn any bg processes
-	test $(aux count_processes_with_tag) -eq 0
+	if test -e LOCAL_LVMPOLLD; then
+		aux lvmpolld_dump | tee lvmpolld_dump.txt
+		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove0"
+	else
+		test $(aux count_processes_with_tag) -eq 0
+	fi
 
 	# ...thus finish polling
 	get lv_field $vg name -a | grep "^\[pvmove0\]"
@@ -152,7 +177,12 @@ pvmove_bg_single() {
 	LVM_TEST_TAG="kill_me_$PREFIX" vgchange --config 'activation{polling_interval=10}' -aey --poll n $vg
 
 	# ...also vgchange --poll n must not spawn any bg processes...
-	test $(aux count_processes_with_tag) -eq 0
+	if test -e LOCAL_LVMPOLLD; then
+		aux lvmpolld_dump | tee lvmpolld_dump.txt
+		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove0"
+	else
+		test $(aux count_processes_with_tag) -eq 0
+	fi
 
 	# ...thus finish polling
 	get lv_field $vg name -a | grep "^\[pvmove0\]"
diff --git a/test/shell/pvmove-resume-multiseg.sh b/test/shell/pvmove-resume-multiseg.sh
index be21d56..713534f 100644
--- a/test/shell/pvmove-resume-multiseg.sh
+++ b/test/shell/pvmove-resume-multiseg.sh
@@ -106,13 +106,25 @@ lvchange_all() {
 	LVM_TEST_TAG="kill_me_$PREFIX" lvchange -aey $vg/$lv1 $vg/$lv2
 
 	# we don't want to spawn more than $1 background pollings
-	test $(aux count_processes_with_tag) -eq $1
+	if test -e LOCAL_LVMPOLLD; then
+		aux lvmpolld_dump | tee lvmpolld_dump.txt
+		aux check_lvmpolld_init_rq_count 1 "$vg/pvmove0"
+		aux check_lvmpolld_init_rq_count 1 "$vg/pvmove1"
+	else
+		test $(aux count_processes_with_tag) -eq $1
+	fi
 }
 
 vgchange_single() {
 	LVM_TEST_TAG="kill_me_$PREFIX" vgchange -aey $vg
 
-	test $(aux count_processes_with_tag) -eq $1
+	if test -e LOCAL_LVMPOLLD; then
+		aux lvmpolld_dump | tee lvmpolld_dump.txt
+		aux check_lvmpolld_init_rq_count 1 "$vg/pvmove0"
+		aux check_lvmpolld_init_rq_count 1 "$vg/pvmove1"
+	else
+		test $(aux count_processes_with_tag) -eq $1
+	fi
 }
 
 pvmove_fg() {
@@ -120,7 +132,13 @@ pvmove_fg() {
 	LVM_TEST_TAG="kill_me_$PREFIX" vgchange --config 'activation{polling_interval=10}' -aey --poll n $vg
 
 	# ...also vgchange --poll n must not spawn any bg processes...
-	test $(aux count_processes_with_tag) -eq 0
+	if test -e LOCAL_LVMPOLLD; then
+		aux lvmpolld_dump | tee lvmpolld_dump.txt
+		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove0"
+		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove1"
+	else
+		test $(aux count_processes_with_tag) -eq 0
+	fi
 
 	# ...thus finish polling
 	get lv_field $vg name -a | grep "^\[pvmove0\]"
@@ -139,7 +157,13 @@ pvmove_bg() {
 	LVM_TEST_TAG="kill_me_$PREFIX" vgchange --config 'activation{polling_interval=10}' -aey --poll n $vg
 
 	# ...also vgchange --poll n must not spawn any bg processes...
-	test $(aux count_processes_with_tag) -eq 0
+	if test -e LOCAL_LVMPOLLD; then
+		aux lvmpolld_dump | tee lvmpolld_dump.txt
+		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove0"
+		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove1"
+	else
+		test $(aux count_processes_with_tag) -eq 0
+	fi
 
 	# ...thus finish polling
 	get lv_field $vg name -a | grep "^\[pvmove0\]"
@@ -153,7 +177,13 @@ pvmove_fg_single() {
 	LVM_TEST_TAG="kill_me_$PREFIX" vgchange --config 'activation{polling_interval=10}' -aey --poll n $vg
 
 	# ...also vgchange --poll n must not spawn any bg processes...
-	test $(aux count_processes_with_tag) -eq 0
+	if test -e LOCAL_LVMPOLLD; then
+		aux lvmpolld_dump | tee lvmpolld_dump.txt
+		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove0"
+		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove1"
+	else
+		test $(aux count_processes_with_tag) -eq 0
+	fi
 
 	# ...thus finish polling
 	get lv_field $vg name -a | grep "^\[pvmove0\]"
@@ -173,7 +203,13 @@ pvmove_bg_single() {
 	LVM_TEST_TAG="kill_me_$PREFIX" vgchange --config 'activation{polling_interval=10}' -aey --poll n $vg
 
 	# ...also vgchange --poll n must not spawn any bg processes...
-	test $(aux count_processes_with_tag) -eq 0
+	if test -e LOCAL_LVMPOLLD; then
+		aux lvmpolld_dump | tee lvmpolld_dump.txt
+		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove0"
+		aux check_lvmpolld_init_rq_count 0 "$vg/pvmove1"
+	else
+		test $(aux count_processes_with_tag) -eq 0
+	fi
 
 	# ...thus finish polling
 	get lv_field $vg name -a | grep "^\[pvmove0\]"
diff --git a/test/shell/pvremove-thin.sh b/test/shell/pvremove-thin.sh
index 5bfb880..2400ac5 100644
--- a/test/shell/pvremove-thin.sh
+++ b/test/shell/pvremove-thin.sh
@@ -14,6 +14,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_vg
 
 aux have_thin 1 8 0 || skip
diff --git a/test/shell/pvremove-usage.sh b/test/shell/pvremove-usage.sh
index 52d26a6..5c55839 100644
--- a/test/shell/pvremove-usage.sh
+++ b/test/shell/pvremove-usage.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 3
 pvcreate "$dev1"
 pvcreate --metadatacopies 0 "$dev2"
diff --git a/test/shell/pvremove-warnings.sh b/test/shell/pvremove-warnings.sh
index c561483..f7ac95b 100644
--- a/test/shell/pvremove-warnings.sh
+++ b/test/shell/pvremove-warnings.sh
@@ -10,6 +10,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 2
 pvcreate "$dev1" "$dev2"
 pvremove "$dev1" "$dev2" 2>&1 | tee pvremove.txt
diff --git a/test/shell/read-ahead.sh b/test/shell/read-ahead.sh
index 764bef1..322a527 100644
--- a/test/shell/read-ahead.sh
+++ b/test/shell/read-ahead.sh
@@ -17,6 +17,8 @@ test_description='Test read-ahead functionality'
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_vg 5
 
 #COMM "test various read ahead settings (bz450922)"
diff --git a/test/shell/select-report.sh b/test/shell/select-report.sh
index f56aa21..a79457e 100644
--- a/test/shell/select-report.sh
+++ b/test/shell/select-report.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_pvs 6 16
 
 # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
diff --git a/test/shell/select-tools-thin.sh b/test/shell/select-tools-thin.sh
index f4d49eb..37c4856 100644
--- a/test/shell/select-tools-thin.sh
+++ b/test/shell/select-tools-thin.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux have_thin 1 0 0 || skip
 
 aux prepare_pvs 1 16
diff --git a/test/shell/select-tools.sh b/test/shell/select-tools.sh
index b9e4b2f..631c637 100644
--- a/test/shell/select-tools.sh
+++ b/test/shell/select-tools.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_pvs 4 12
 
 vgcreate -s 4m $vg1 "$dev1" "$dev2"
diff --git a/test/shell/snapshot-autoumount-dmeventd.sh b/test/shell/snapshot-autoumount-dmeventd.sh
index 860d170..d369dac 100644
--- a/test/shell/snapshot-autoumount-dmeventd.sh
+++ b/test/shell/snapshot-autoumount-dmeventd.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 which mkfs.ext2 || skip
 
 aux lvmconf "activation/snapshot_autoextend_percent = 0" \
diff --git a/test/shell/snapshot-cluster.sh b/test/shell/snapshot-cluster.sh
index 051c165..47c8d2e 100644
--- a/test/shell/snapshot-cluster.sh
+++ b/test/shell/snapshot-cluster.sh
@@ -14,6 +14,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_vg 1
 
 lvcreate -aey -L1 -n $lv1 $vg
diff --git a/test/shell/snapshot-lvm1.sh b/test/shell/snapshot-lvm1.sh
index f6afe14..0abba0c 100644
--- a/test/shell/snapshot-lvm1.sh
+++ b/test/shell/snapshot-lvm1.sh
@@ -14,6 +14,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 2
 
 vgcreate --metadatatype 1 $vg $(cat DEVICES)
diff --git a/test/shell/snapshot-maxsize.sh b/test/shell/snapshot-maxsize.sh
index 3949f19..e24f965 100644
--- a/test/shell/snapshot-maxsize.sh
+++ b/test/shell/snapshot-maxsize.sh
@@ -14,6 +14,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_pvs 1
 
 vgcreate -s 1K $vg $(cat DEVICES)
diff --git a/test/shell/snapshot-reactivate.sh b/test/shell/snapshot-reactivate.sh
index 0fbdc62..978f7c0 100644
--- a/test/shell/snapshot-reactivate.sh
+++ b/test/shell/snapshot-reactivate.sh
@@ -17,6 +17,8 @@
 #
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 # Snapshot should remain unmodified
 check_s_() {
 	check dev_md5sum $vg s
diff --git a/test/shell/snapshot-rename.sh b/test/shell/snapshot-rename.sh
index 8d1eefb..47bf213 100644
--- a/test/shell/snapshot-rename.sh
+++ b/test/shell/snapshot-rename.sh
@@ -14,6 +14,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_vg 1
 
 lvcreate -aey -L1 -n $lv1 $vg
diff --git a/test/shell/snapshot-usage-exa.sh b/test/shell/snapshot-usage-exa.sh
index ae5ca6d..133014b 100644
--- a/test/shell/snapshot-usage-exa.sh
+++ b/test/shell/snapshot-usage-exa.sh
@@ -14,6 +14,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux can_use_16T || skip
 
 aux prepare_pvs 1
diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index e3db1fb..68396aa 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 MKFS=mkfs.ext2
 which $MKFS || skip
 
diff --git a/test/shell/stray-device-node.sh b/test/shell/stray-device-node.sh
index 0ff4796..09d9e75 100644
--- a/test/shell/stray-device-node.sh
+++ b/test/shell/stray-device-node.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 3
 cp -r "$dev1" "$DM_DEV_DIR/stray"
 
diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index ff03e14..78067e9 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -13,6 +13,8 @@ test_description='Test system_id'
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 1
 
 # with clvm enabled, vgcreate with no -c option creates a clustered vg,
diff --git a/test/shell/tags.sh b/test/shell/tags.sh
index bc66d15..37d738f 100644
--- a/test/shell/tags.sh
+++ b/test/shell/tags.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_pvs 4
 
 # vgcreate with --addtag
diff --git a/test/shell/test-partition.sh b/test/shell/test-partition.sh
index f68d572..0cdaa87 100644
--- a/test/shell/test-partition.sh
+++ b/test/shell/test-partition.sh
@@ -19,6 +19,8 @@ LVM_TEST_CONFIG_DEVICES="types = [\"device-mapper\", 142]"
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 which sfdisk || skip
 
 aux prepare_pvs 1 30
diff --git a/test/shell/thin-autoumount-dmeventd.sh b/test/shell/thin-autoumount-dmeventd.sh
index a77ad08..00ea859 100644
--- a/test/shell/thin-autoumount-dmeventd.sh
+++ b/test/shell/thin-autoumount-dmeventd.sh
@@ -18,6 +18,8 @@ is_dir_mounted_()
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 #
 # Main
 #
diff --git a/test/shell/thin-defaults.sh b/test/shell/thin-defaults.sh
index 3a681a1..4341899 100644
--- a/test/shell/thin-defaults.sh
+++ b/test/shell/thin-defaults.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 #
 # Main
 #
diff --git a/test/shell/thin-restore.sh b/test/shell/thin-restore.sh
index fd4118f..1ac4f66 100644
--- a/test/shell/thin-restore.sh
+++ b/test/shell/thin-restore.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 #
 # Main
 #
diff --git a/test/shell/thin-volume-list.sh b/test/shell/thin-volume-list.sh
index 32d13b8..e173d87 100644
--- a/test/shell/thin-volume-list.sh
+++ b/test/shell/thin-volume-list.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 #
 # Main
 #
diff --git a/test/shell/topology-support.sh b/test/shell/topology-support.sh
index f1e42a8..ebb7220 100644
--- a/test/shell/topology-support.sh
+++ b/test/shell/topology-support.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 which mkfs.ext3 || skip
 
 lvdev_() {
diff --git a/test/shell/unknown-segment.sh b/test/shell/unknown-segment.sh
index b07e1b5..a1d3696 100644
--- a/test/shell/unknown-segment.sh
+++ b/test/shell/unknown-segment.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_vg 4
 
 lvcreate -an -Zn -l 1 -n $lv1 $vg
diff --git a/test/shell/unlost-pv.sh b/test/shell/unlost-pv.sh
index 980c451..09de21a 100644
--- a/test/shell/unlost-pv.sh
+++ b/test/shell/unlost-pv.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 check_() {
 	# vgscan needs --cache option for direct scan if lvmetad is used
 	test -e LOCAL_LVMETAD && cache="--cache"
diff --git a/test/shell/vg-name-from-env.sh b/test/shell/vg-name-from-env.sh
index 67ad5c5..a3d1b9a 100644
--- a/test/shell/vg-name-from-env.sh
+++ b/test/shell/vg-name-from-env.sh
@@ -9,6 +9,8 @@ test_description='Test the vg name for an lv from env var'
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 2
 
 pvcreate "$dev1"
diff --git a/test/shell/vgcfgbackup-usage.sh b/test/shell/vgcfgbackup-usage.sh
index eb36983..b0faf38 100644
--- a/test/shell/vgcfgbackup-usage.sh
+++ b/test/shell/vgcfgbackup-usage.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_pvs 4
 
 pvcreate --metadatacopies 0 "$dev4"
diff --git a/test/shell/vgchange-many.sh b/test/shell/vgchange-many.sh
index cbb4363..7b3d557 100644
--- a/test/shell/vgchange-many.sh
+++ b/test/shell/vgchange-many.sh
@@ -12,6 +12,8 @@
 # Check perfomance of activation and deactivation
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 # FIXME: lvmetad fails with i.e. 1500 device on memory failure...
 
 # Number of LVs to create
diff --git a/test/shell/vgchange-maxlv.sh b/test/shell/vgchange-maxlv.sh
index 35ce5d6..613d985 100644
--- a/test/shell/vgchange-maxlv.sh
+++ b/test/shell/vgchange-maxlv.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_dmeventd
 aux prepare_pvs 3
 
diff --git a/test/shell/vgchange-partial.sh b/test/shell/vgchange-partial.sh
index 7fd9840..f9c3ac0 100644
--- a/test/shell/vgchange-partial.sh
+++ b/test/shell/vgchange-partial.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_vg 2
 
 aux disable_dev "$dev1"
diff --git a/test/shell/vgchange-sysinit.sh b/test/shell/vgchange-sysinit.sh
index 4debf42..8450d63 100644
--- a/test/shell/vgchange-sysinit.sh
+++ b/test/shell/vgchange-sysinit.sh
@@ -12,6 +12,7 @@
 . lib/inittest
 
 test -e LOCAL_CLVMD && skip
+test -e LOCAL_LVMPOLLD && skip
 
 which mkfs.ext3 || skip
 
diff --git a/test/shell/vgchange-usage.sh b/test/shell/vgchange-usage.sh
index e564337..7ee42a9 100644
--- a/test/shell/vgchange-usage.sh
+++ b/test/shell/vgchange-usage.sh
@@ -13,6 +13,8 @@ test_description='Exercise some vgchange diagnostics'
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_pvs 4
 
 pvcreate --metadatacopies 0 "$dev1"
diff --git a/test/shell/vgck.sh b/test/shell/vgck.sh
index 629b6e7..a4930aa 100644
--- a/test/shell/vgck.sh
+++ b/test/shell/vgck.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_vg 3
 lvcreate -n blabla -L 1 $vg
 
diff --git a/test/shell/vgcreate-many-pvs.sh b/test/shell/vgcreate-many-pvs.sh
index c6d3852..bb78caf 100644
--- a/test/shell/vgcreate-many-pvs.sh
+++ b/test/shell/vgcreate-many-pvs.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 #
 # Test to exercise larger number of PVs in a VG
 # Related to https://bugzilla.redhat.com/show_bug.cgi?id=736027
diff --git a/test/shell/vgcreate-usage.sh b/test/shell/vgcreate-usage.sh
index a1d178d..df0094c 100644
--- a/test/shell/vgcreate-usage.sh
+++ b/test/shell/vgcreate-usage.sh
@@ -13,6 +13,8 @@ test_description='Exercise some vgcreate diagnostics'
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 3
 pvcreate "$dev1" "$dev2"
 pvcreate --metadatacopies 0 "$dev3"
diff --git a/test/shell/vgextend-restoremissing.sh b/test/shell/vgextend-restoremissing.sh
index 7b7748f..5af5520 100644
--- a/test/shell/vgextend-restoremissing.sh
+++ b/test/shell/vgextend-restoremissing.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_vg 3
 
 lvcreate -an -Zn --type mirror -m 1 -l 1 -n mirror $vg
diff --git a/test/shell/vgextend-usage.sh b/test/shell/vgextend-usage.sh
index 93401f0..65665bc 100644
--- a/test/shell/vgextend-usage.sh
+++ b/test/shell/vgextend-usage.sh
@@ -15,6 +15,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 5
 
 for mdatype in 1 2
diff --git a/test/shell/vgimportclone.sh b/test/shell/vgimportclone.sh
index c3d7e52..0b1af38 100644
--- a/test/shell/vgimportclone.sh
+++ b/test/shell/vgimportclone.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 2
 
 vgcreate --metadatasize 128k $vg1 "$dev1"
diff --git a/test/shell/vgmerge-operation.sh b/test/shell/vgmerge-operation.sh
index 261953e..42976c2 100644
--- a/test/shell/vgmerge-operation.sh
+++ b/test/shell/vgmerge-operation.sh
@@ -13,6 +13,8 @@ test_description='Test vgmerge operation'
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_pvs 4 64
 
 # 'vgmerge succeeds with single linear LV in source VG'
diff --git a/test/shell/vgmerge-usage.sh b/test/shell/vgmerge-usage.sh
index d8fa09c..981a964 100644
--- a/test/shell/vgmerge-usage.sh
+++ b/test/shell/vgmerge-usage.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_pvs 4
 
 # 'vgmerge normal operation'
diff --git a/test/shell/vgreduce-usage.sh b/test/shell/vgreduce-usage.sh
index 52c5f36..9f55395 100644
--- a/test/shell/vgreduce-usage.sh
+++ b/test/shell/vgreduce-usage.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 4
 
 for mdatype in 1 2
diff --git a/test/shell/vgremove-corrupt-vg.sh b/test/shell/vgremove-corrupt-vg.sh
index f709e4e..dc3c9db 100644
--- a/test/shell/vgremove-corrupt-vg.sh
+++ b/test/shell/vgremove-corrupt-vg.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_vg 3
 lvcreate -n blabla -L 1 $vg -an --zero n
 
diff --git a/test/shell/vgrename-usage.sh b/test/shell/vgrename-usage.sh
index de1b933..59c3397 100644
--- a/test/shell/vgrename-usage.sh
+++ b/test/shell/vgrename-usage.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 4
 pvcreate "$dev1" "$dev2"
 pvcreate --metadatacopies 0 "$dev3" "$dev4"
diff --git a/test/shell/vgsplit-operation.sh b/test/shell/vgsplit-operation.sh
index 91cdcdc..975e873 100644
--- a/test/shell/vgsplit-operation.sh
+++ b/test/shell/vgsplit-operation.sh
@@ -16,6 +16,8 @@ export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 COMM() {
 	LAST_TEST="$@"
 }
diff --git a/test/shell/vgsplit-raid.sh b/test/shell/vgsplit-raid.sh
index a7c9687..2fe734f 100644
--- a/test/shell/vgsplit-raid.sh
+++ b/test/shell/vgsplit-raid.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 COMM() {
 	LAST_TEST="$@"
 }
diff --git a/test/shell/vgsplit-stacked.sh b/test/shell/vgsplit-stacked.sh
index 42010fc..6a04f07 100644
--- a/test/shell/vgsplit-stacked.sh
+++ b/test/shell/vgsplit-stacked.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux extend_filter_LVMTEST
 aux prepare_pvs 3
 
diff --git a/test/shell/vgsplit-thin.sh b/test/shell/vgsplit-thin.sh
index 7b06132..0f6b427 100644
--- a/test/shell/vgsplit-thin.sh
+++ b/test/shell/vgsplit-thin.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux have_thin 1 0 0 || skip
 
 aux prepare_devs 5
diff --git a/test/shell/vgsplit-usage.sh b/test/shell/vgsplit-usage.sh
index fe999f9..b0422d5 100644
--- a/test/shell/vgsplit-usage.sh
+++ b/test/shell/vgsplit-usage.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 aux prepare_devs 5
 
 for mdatype in 1 2
diff --git a/test/shell/zero-usage.sh b/test/shell/zero-usage.sh
index 046b3f5..df90529 100644
--- a/test/shell/zero-usage.sh
+++ b/test/shell/zero-usage.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_LVMPOLLD && skip
+
 which md5sum || skip
 
 aux prepare_pvs 1
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 861ae82..20c988d 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -59,6 +59,7 @@ SOURCES =\
 	vgimport.c \
 	vgmerge.c \
 	vgmknodes.c \
+	lvpoll.c \
 	vgreduce.c \
 	vgremove.c \
 	vgrename.c \
@@ -168,7 +169,7 @@ liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION): liblvm2cmd.$(LIB_SUFFIX)
 
 .commands: $(srcdir)/commands.h $(srcdir)/cmdnames.h Makefile
 	$(CC) -E -P $(srcdir)/cmdnames.h 2> /dev/null | \
-		egrep -v '^ *(|#.*|config|devtypes|dumpconfig|formats|help|pvdata|segtypes|systemid|tags|version) *$$' > .commands
+		egrep -v '^ *(|#.*|config|devtypes|dumpconfig|formats|help|lvpoll|pvdata|segtypes|systemid|tags|version) *$$' > .commands
 
 ifneq ("$(CFLOW_CMD)", "")
 CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
diff --git a/tools/args.h b/tools/args.h
index 791aa4e..7b715f5 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -42,6 +42,7 @@ arg(driverloaded_ARG, '\0', "driverloaded", yes_no_arg, 0)
 arg(errorwhenfull_ARG, '\0', "errorwhenfull", yes_no_arg, 0)
 arg(force_long_ARG, '\0', "force", NULL, ARG_COUNTABLE)
 arg(foreign_ARG, '\0', "foreign", NULL, 0)
+arg(handlemissingpvs_ARG, '\0', "handlemissingpvs", NULL, 0)
 arg(ignoreadvanced_ARG, '\0', "ignoreadvanced", NULL, 0)
 arg(ignorelocal_ARG, '\0', "ignorelocal", NULL, 0)
 arg(ignorelockingfailure_ARG, '\0', "ignorelockingfailure", NULL, 0)
@@ -72,6 +73,7 @@ arg(noudevsync_ARG, '\0', "noudevsync", NULL, 0)
 arg(originname_ARG, '\0', "originname", string_arg, 0)
 arg(physicalvolumesize_ARG, '\0', "setphysicalvolumesize", size_mb_arg, 0)
 arg(poll_ARG, '\0', "poll", yes_no_arg, 0)
+arg(polloperation_ARG, '\0', "polloperation", string_arg, 0)
 arg(pooldatasize_ARG, '\0', "pooldatasize", size_mb_arg, 0)
 arg(poolmetadata_ARG, '\0', "poolmetadata", string_arg, 0)
 arg(poolmetadatasize_ARG, '\0', "poolmetadatasize", size_mb_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index f2878ab..2e53d8f 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -880,6 +880,22 @@ xx(pvmove,
    abort_ARG, alloc_ARG, atomic_ARG, autobackup_ARG, background_ARG,
    interval_ARG, name_ARG, noudevsync_ARG, test_ARG)
 
+xx(lvpoll,
+   "Continue already initiated poll operation on a logical volume",
+   0,
+   "\t[--abort]\n"
+   "\t[--handlemissingpvs]\n"
+   "\t[--polloperation\n"
+   "\t[-d|--debug]\n "
+   "\t[-h|-?|--help]\n"
+   "\t[-i|--interval seconds]\n"
+   "\t[-t|--test]\n "
+   "\t[-v|--verbose]\n "
+   "\t[--version]\n",
+
+   abort_ARG, handlemissingpvs_ARG, interval_ARG, polloperation_ARG,
+   test_ARG)
+
 xx(pvremove,
    "Remove LVM label(s) from physical volume(s)",
    0,
diff --git a/tools/lvpoll.c b/tools/lvpoll.c
new file mode 100644
index 0000000..6db0ade
--- /dev/null
+++ b/tools/lvpoll.c
@@ -0,0 +1,115 @@
+/*
+ * Copyright (C) 2014-2015 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "tools.h"
+#include "polldaemon.h"
+#include "pvmove_poll.h"
+#include "lvconvert_poll.h"
+#include "polling_ops.h"
+
+static struct poll_functions _pvmove_fns = {
+	.get_copy_lv = poll_get_copy_lv,
+	.get_copy_vg = poll_get_copy_vg,
+	.poll_progress = poll_mirror_progress,
+	.update_metadata = pvmove_update_metadata,
+	.finish_copy = pvmove_finish
+};
+
+static struct poll_functions _convert_fns = {
+	.get_copy_lv = poll_get_copy_lv,
+	.get_copy_vg = poll_get_copy_vg,
+	.poll_progress = poll_mirror_progress,
+	.finish_copy = lvconvert_mirror_finish
+};
+
+static struct poll_functions _merge_fns = {
+	.get_copy_lv = poll_get_copy_lv,
+	.get_copy_vg = poll_get_copy_vg,
+	.poll_progress = poll_merge_progress,
+	.finish_copy = lvconvert_merge_finish
+};
+
+static struct poll_functions _thin_merge_fns = {
+	.get_copy_lv = poll_get_copy_lv,
+	.get_copy_vg = poll_get_copy_vg,
+	.poll_progress = poll_thin_merge_progress,
+	.finish_copy = lvconvert_merge_finish
+};
+
+static int _set_daemon_parms(struct cmd_context *cmd, struct daemon_parms *parms)
+{
+	const char *poll_oper = arg_str_value(cmd, polloperation_ARG, "");
+
+	parms->interval = arg_uint_value(cmd, interval_ARG, 0);
+	parms->aborting = arg_count(cmd, abort_ARG);
+	parms->progress_display = 1;
+	parms->wait_before_testing = (arg_sign_value(cmd, interval_ARG, SIGN_NONE) == SIGN_PLUS);
+
+	if (!strcmp(poll_oper, PVMOVE_POLL)) {
+		parms->progress_title = "Moved";
+		parms->lv_type = PVMOVE;
+		parms->poll_fns = &_pvmove_fns;
+	} else if (!strcmp(poll_oper, CONVERT_POLL)) {
+		parms->progress_title = "Converted";
+		parms->poll_fns = &_convert_fns;
+	} else if (!strcmp(poll_oper, MERGE_POLL)) {
+		parms->progress_title = "Merged";
+		parms->poll_fns = &_merge_fns;
+	} else if (!strcmp(poll_oper, MERGE_THIN_POLL)) {
+		parms->progress_title = "Merged";
+		parms->poll_fns = &_thin_merge_fns;
+	} else {
+		log_error("Unknown polling operation %s", poll_oper);
+		return 0;
+	}
+
+	cmd->handles_missing_pvs = arg_count(cmd, handlemissingpvs_ARG);
+
+	return 1;
+}
+
+static int poll_lv(struct cmd_context *cmd, const char *lv_name)
+{
+	struct daemon_parms parms = { 0 };
+	struct poll_operation_id id = {
+		.vg_name = extract_vgname(cmd, lv_name),
+		.lv_name = strchr(lv_name, '/') + 1,
+		.display_name = lv_name
+	};
+
+	if (!_set_daemon_parms(cmd, &parms))
+		return_EINVALID_CMD_LINE;
+
+	return wait_for_single_lv(cmd, &id, &parms) ? ECMD_PROCESSED : ECMD_FAILED;
+}
+
+int lvpoll(struct cmd_context *cmd, int argc, char **argv)
+{
+	if (!arg_count(cmd, polloperation_ARG)) {
+		log_error("--polloperation parameter is mandatory");
+		return EINVALID_CMD_LINE;
+	}
+
+	if (arg_sign_value(cmd, interval_ARG, SIGN_NONE) == SIGN_MINUS) {
+		log_error("Argument to --interval cannot be negative");
+		return EINVALID_CMD_LINE;
+	}
+
+	if (!argc || !strchr(argv[0], '/')) {
+		log_error("Provide full VG/LV name");
+		return EINVALID_CMD_LINE;
+	}
+
+	return poll_lv(cmd, argv[0]);
+}
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 9c62ebf..83497b0 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -18,6 +18,7 @@
 #include "tools.h"
 #include "polldaemon.h"
 #include "lvm2cmdline.h"
+#include "lvmpolld-client.h"
 
 #define WAIT_AT_LEAST_NANOSECS 100000
 
@@ -182,7 +183,7 @@ int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 		lv = parms->poll_fns->get_copy_lv(cmd, vg, id->lv_name, id->uuid, parms->lv_type);
 
 		if (!lv && parms->lv_type == PVMOVE) {
-			log_print_unless_silent("%s: no pvmove in progress - already finished or aborted.",
+			log_print_unless_silent("%s: No pvmove in progress - already finished or aborted.",
 						id->display_name);
 			unlock_and_release_vg(cmd, vg, vg->name);
 			return 1;
@@ -365,6 +366,174 @@ static void _poll_for_all_vgs(struct cmd_context *cmd,
 	}
 }
 
+#ifdef LVMPOLLD_SUPPORT
+typedef struct {
+	struct daemon_parms *parms;
+	struct dm_list idls;
+} lvmpolld_parms_t;
+
+static int report_progress(struct cmd_context *cmd, struct poll_operation_id *id,
+			   struct daemon_parms *parms)
+{
+	struct volume_group *vg;
+	struct logical_volume *lv;
+
+	vg = parms->poll_fns->get_copy_vg(cmd, id->vg_name, NULL, 0);
+	if (vg_read_error(vg)) {
+		release_vg(vg);
+		log_error("Can't reread VG for %s", id->display_name);
+		return 0;
+	}
+
+	lv = parms->poll_fns->get_copy_lv(cmd, vg, id->lv_name, id->uuid, parms->lv_type);
+	if (!lv && parms->lv_type == PVMOVE) {
+		log_print_unless_silent("%s: No pvmove in progress - already finished or aborted.",
+					id->display_name);
+		unlock_and_release_vg(cmd, vg, vg->name);
+		return 1;
+	}
+
+	if (!lv) {
+		log_warn("Can't find LV in %s for %s. Already finished or removed.",
+			  vg->name, id->display_name);
+		unlock_and_release_vg(cmd, vg, vg->name);
+		return 1;
+	}
+
+	if (!lv_is_active_locally(lv)) {
+		log_print_unless_silent("%s: Interrupted: No longer active.", id->display_name);
+		unlock_and_release_vg(cmd, vg, vg->name);
+		return 1;
+	}
+
+	if (parms->poll_fns->poll_progress(cmd, lv, id->display_name, parms) == PROGRESS_CHECK_FAILED) {
+		unlock_and_release_vg(cmd, vg, vg->name);
+		return_0;
+	}
+
+	unlock_and_release_vg(cmd, vg, vg->name);
+
+	return 1;
+}
+
+static int _lvmpolld_init_poll_vg(struct cmd_context *cmd, const char *vgname,
+			          struct volume_group *vg, struct processing_handle *handle)
+{
+	int r;
+	struct lv_list *lvl;
+	struct logical_volume *lv;
+	struct poll_id_list *idl;
+	struct poll_operation_id id;
+	lvmpolld_parms_t *lpdp = (lvmpolld_parms_t *) handle->custom_handle;
+
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		lv = lvl->lv;
+		if (!(lv->status & lpdp->parms->lv_type))
+			continue;
+
+		id.display_name = lpdp->parms->poll_fns->get_copy_name_from_lv(lv);
+		if (!id.display_name && !lpdp->parms->aborting)
+			continue;
+
+		if (!lv->lvid.s) {
+			log_print_unless_silent("Missing LV uuid within: %s/%s", id.vg_name, id.lv_name);
+			continue;
+		}
+
+		id.vg_name = lv->vg->name;
+		id.lv_name = lv->name;
+		id.uuid = lv->lvid.s;
+
+		r = lvmpolld_poll_init(cmd, &id, lpdp->parms);
+
+		if (r && !lpdp->parms->background) {
+			if (!(idl = poll_id_list_create(cmd->mem, &id)))
+				return ECMD_FAILED;
+
+			dm_list_add(&lpdp->idls, &idl->list);
+		}
+	}
+
+	return ECMD_PROCESSED;
+}
+
+static void _lvmpolld_poll_for_all_vgs(struct cmd_context *cmd,
+				       struct daemon_parms *parms,
+				       struct processing_handle *handle)
+{
+	int r;
+	struct dm_list *first;
+	struct poll_id_list *idl, *tlv;
+	unsigned finished;
+	lvmpolld_parms_t lpdp = {
+		.parms = parms
+	};
+
+	dm_list_init(&lpdp.idls);
+
+	handle->custom_handle = &lpdp;
+
+	process_each_vg(cmd, 0, NULL, 0, handle, _lvmpolld_init_poll_vg);
+
+	first = dm_list_first(&lpdp.idls);
+
+	while (!dm_list_empty(&lpdp.idls)) {
+		dm_list_iterate_items_safe(idl, tlv, &lpdp.idls) {
+			r = lvmpolld_request_info(idl->id, lpdp.parms,
+						  &finished);
+			if (!r || finished)
+				dm_list_del(&idl->list);
+			else if (!parms->aborting)
+				report_progress(cmd, idl->id, lpdp.parms);
+		}
+
+		_nanosleep(lpdp.parms->interval, 0);
+	}
+
+	if (first)
+		dm_pool_free(cmd->mem, dm_list_item(first, struct poll_id_list));
+}
+
+static int _lvmpoll_daemon(struct cmd_context *cmd, struct poll_operation_id *id,
+			   struct daemon_parms *parms)
+{
+	int r;
+	struct processing_handle *handle = NULL;
+	unsigned finished = 0;
+
+	if (parms->aborting)
+		parms->interval = 0;
+
+	if (id) {
+		r = lvmpolld_poll_init(cmd, id, parms);
+		if (r && !parms->background) {
+			while (1) {
+				if (!(r = lvmpolld_request_info(id, parms, &finished)) ||
+				    finished ||
+				    (!parms->aborting && !(r = report_progress(cmd, id, parms))))
+					break;
+
+				_nanosleep(parms->interval, 0);
+			}
+		}
+
+		return r ? ECMD_PROCESSED : ECMD_FAILED;
+	} else {
+		/* process all in-flight operations */
+		if (!(handle = init_processing_handle(cmd))) {
+			log_error("Failed to initialize processing handle.");
+			return ECMD_FAILED;
+		} else {
+			_lvmpolld_poll_for_all_vgs(cmd, parms, handle);
+			destroy_processing_handle(cmd, handle);
+			return ECMD_PROCESSED;
+		}
+	}
+}
+#else
+#	define _lvmpoll_daemon(cmd, id, parms) (ECMD_FAILED)
+#endif /* LVMPOLLD_SUPPORT */
+
 /*
  * Only allow *one* return from poll_daemon() (the parent).
  * If there is a child it must exit (ignoring the memory leak messages).
@@ -463,7 +632,11 @@ int poll_daemon(struct cmd_context *cmd, unsigned background,
 	if (!_daemon_parms_init(cmd, &parms, background, poll_fns, progress_title, lv_type))
 		return_EINVALID_CMD_LINE;
 
-	/* classical polling allows only PMVOVE or 0 values */
-	parms.lv_type &= PVMOVE;
-	return _poll_daemon(cmd, id, &parms);
+	if (lvmpolld_use())
+		return _lvmpoll_daemon(cmd, id, &parms);
+	else {
+		/* classical polling allows only PMVOVE or 0 values */
+		parms.lv_type &= PVMOVE;
+		return _poll_daemon(cmd, id, &parms);
+	}
 }
diff --git a/tools/polldaemon.h b/tools/polldaemon.h
deleted file mode 100644
index 6309a5f..0000000
--- a/tools/polldaemon.h
+++ /dev/null
@@ -1,93 +0,0 @@
-/*
- * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU Lesser General Public License v.2.1.
- *
- * You should have received a copy of the GNU Lesser General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
- */
-
-#ifndef _LVM_TOOL_POLLDAEMON_H
-#define _LVM_TOOL_POLLDAEMON_H
-
-#include "metadata-exported.h"
-
-typedef enum {
-	PROGRESS_CHECK_FAILED = 0,
-	PROGRESS_UNFINISHED = 1,
-	PROGRESS_FINISHED_SEGMENT = 2,
-	PROGRESS_FINISHED_ALL = 3
-} progress_t;
-
-struct daemon_parms;
-
-struct poll_functions {
-	const char *(*get_copy_name_from_lv) (const struct logical_volume *lv);
-	struct volume_group *(*get_copy_vg) (struct cmd_context *cmd,
-					     const char *name,
-					     const char *uuid,
-					     uint32_t flags);
-	struct logical_volume *(*get_copy_lv) (struct cmd_context *cmd,
-					       struct volume_group *vg,
-					       const char *name,
-					       const char *uuid,
-					       uint64_t lv_type);
-	progress_t (*poll_progress)(struct cmd_context *cmd,
-				    struct logical_volume *lv,
-				    const char *name,
-				    struct daemon_parms *parms);
-	int (*update_metadata) (struct cmd_context *cmd,
-				struct volume_group *vg,
-				struct logical_volume *lv,
-				struct dm_list *lvs_changed, unsigned flags);
-	int (*finish_copy) (struct cmd_context *cmd,
-			    struct volume_group *vg,
-			    struct logical_volume *lv,
-			    struct dm_list *lvs_changed);
-};
-
-struct poll_operation_id {
-	const char *vg_name;
-	const char *lv_name;
-	const char *display_name;
-	const char *uuid;
-};
-
-struct daemon_parms {
-	unsigned interval;
-	unsigned wait_before_testing;
-	unsigned aborting;
-	unsigned background;
-	unsigned outstanding_count;
-	unsigned progress_display;
-	const char *progress_title;
-	uint64_t lv_type;
-	struct poll_functions *poll_fns;
-};
-
-int poll_daemon(struct cmd_context *cmd, unsigned background,
-		uint64_t lv_type, struct poll_functions *poll_fns,
-		const char *progress_title, struct poll_operation_id *id);
-
-progress_t poll_mirror_progress(struct cmd_context *cmd,
-				struct logical_volume *lv, const char *name,
-				struct daemon_parms *parms);
-
-struct volume_group *poll_get_copy_vg(struct cmd_context *cmd, const char *name,
-				      const char *uuid, uint32_t flags);
-
-struct logical_volume *poll_get_copy_lv(struct cmd_context *cmd,
-					struct volume_group *vg,
-					const char *name, const char *uuid,
-					uint64_t lv_type);
-
-int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
-		       struct daemon_parms *parms);
-
-#endif
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 70fba99..202c87c 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -728,7 +728,7 @@ static int _read_poll_id_from_pvname(struct cmd_context *cmd, const char *pv_nam
 	}
 
 	if (!(lv = find_pvmove_lv(vg, pv_dev(pv), PVMOVE))) {
-		log_print_unless_silent("%s: no pvmove in progress - already finished or aborted.",
+		log_print_unless_silent("%s: No pvmove in progress - already finished or aborted.",
 					pv_name);
 		ret = 1;
 		*in_progress = 0;


