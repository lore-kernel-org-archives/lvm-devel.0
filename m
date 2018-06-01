From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 1 Jun 2018 10:31:24 -0400
Subject: master - build: Don't generate symlinks in include/ dir
Message-ID: <201806011431.w51EVObF024963@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7f97c7ea9ade36bab817aca9eeee5c5177550127
Commit:        7f97c7ea9ade36bab817aca9eeee5c5177550127
Parent:        02b99be57eab4f55bd0db045a3873bdf5e500b92
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon May 14 10:30:20 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Mon May 14 10:30:20 2018 +0100

build: Don't generate symlinks in include/ dir

As we start refactoring the code to break dependencies (see doc/refactoring.txt),
I want us to use full paths in the includes (eg, #include "base/data-struct/list.h").
This makes it more obvious when we're breaking abstraction boundaries, eg, including a file in
metadata/ from base/
---
 configure                                          |    3 +-
 configure.ac                                       |    1 -
 daemons/clvmd/clvmd-cman.c                         |    2 +-
 daemons/clvmd/clvmd-command.c                      |    6 +-
 daemons/clvmd/clvmd-common.h                       |    4 +-
 daemons/clvmd/clvmd-corosync.c                     |    4 +-
 daemons/clvmd/clvmd-openais.c                      |    4 +-
 daemons/clvmd/clvmd-singlenode.c                   |    4 +-
 daemons/clvmd/clvmd.c                              |    2 +-
 daemons/clvmd/lvm-functions.c                      |   14 ++--
 daemons/clvmd/refresh_clvmd.c                      |    2 +-
 daemons/cmirrord/cluster.c                         |    2 +-
 daemons/cmirrord/cluster.h                         |    4 +-
 daemons/cmirrord/compat.c                          |    2 +-
 daemons/cmirrord/functions.h                       |    2 +-
 daemons/dmeventd/dmeventd.c                        |    6 +-
 daemons/dmeventd/libdevmapper-event.c              |    6 +-
 daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c       |    6 +-
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c  |    6 +-
 daemons/dmeventd/plugins/raid/dmeventd_raid.c      |    6 +-
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |    4 +-
 daemons/dmeventd/plugins/thin/dmeventd_thin.c      |    6 +-
 daemons/dmfilemapd/dmfilemapd.c                    |    6 +-
 daemons/lvmetad/lvmetactl.c                        |    4 +-
 daemons/lvmetad/lvmetad-client.h                   |    2 +-
 daemons/lvmetad/lvmetad-core.c                     |    6 +-
 daemons/lvmetad/testclient.c                       |   10 +-
 daemons/lvmlockd/lvmlockctl.c                      |    4 +-
 daemons/lvmlockd/lvmlockd-client.h                 |    2 +-
 daemons/lvmlockd/lvmlockd-core.c                   |   10 +-
 daemons/lvmlockd/lvmlockd-dlm.c                    |    6 +-
 daemons/lvmlockd/lvmlockd-sanlock.c                |    6 +-
 daemons/lvmpolld/lvmpolld-common.h                 |    4 +-
 daemons/lvmpolld/lvmpolld-data-utils.c             |    2 +-
 daemons/lvmpolld/lvmpolld-protocol.h               |    2 +-
 device-mapper/vdo/status.c                         |    2 +-
 doc/example_cmdlib.c                               |    2 +-
 include/.symlinks.in                               |   80 --------------------
 include/Makefile.in                                |   20 +-----
 lib/activate/activate.c                            |   32 ++++----
 lib/activate/activate.h                            |    2 +-
 lib/activate/dev_manager.c                         |   22 +++---
 lib/activate/dev_manager.h                         |    2 +-
 lib/activate/fs.c                                  |   12 ++--
 lib/activate/fs.h                                  |    2 +-
 lib/cache/lvmcache.c                               |   24 +++---
 lib/cache/lvmcache.h                               |   10 +-
 lib/cache/lvmetad.c                                |   24 +++---
 lib/cache/lvmetad.h                                |    2 +-
 lib/cache_segtype/cache.c                          |   24 +++---
 lib/commands/toolcontext.c                         |   38 +++++-----
 lib/commands/toolcontext.h                         |    4 +-
 lib/config/config.c                                |   20 +++---
 lib/config/config.h                                |    6 +-
 lib/config/config_settings.h                       |    2 +-
 lib/datastruct/btree.c                             |    4 +-
 lib/datastruct/str_list.c                          |    4 +-
 lib/device/bcache-utils.c                          |    2 +-
 lib/device/bcache.c                                |    6 +-
 lib/device/bcache.h                                |    2 +-
 lib/device/dev-cache.c                             |   12 ++--
 lib/device/dev-cache.h                             |    4 +-
 lib/device/dev-dasd.c                              |    6 +-
 lib/device/dev-ext.c                               |    4 +-
 lib/device/dev-io.c                                |   12 ++--
 lib/device/dev-luks.c                              |    4 +-
 lib/device/dev-lvm1-pool.c                         |    6 +-
 lib/device/dev-md.c                                |    8 +-
 lib/device/dev-swap.c                              |    4 +-
 lib/device/dev-type.c                              |   18 ++--
 lib/device/dev-type.h                              |    8 +-
 lib/device/device.h                                |    2 +-
 lib/display/display.c                              |   16 ++--
 lib/display/display.h                              |    6 +-
 lib/error/errseg.c                                 |   16 ++--
 lib/filters/filter-composite.c                     |    6 +-
 lib/filters/filter-fwraid.c                        |    6 +-
 lib/filters/filter-internal.c                      |    4 +-
 lib/filters/filter-md.c                            |    4 +-
 lib/filters/filter-mpath.c                         |    8 +-
 lib/filters/filter-partitioned.c                   |    4 +-
 lib/filters/filter-persistent.c                    |    8 +-
 lib/filters/filter-regex.c                         |    4 +-
 lib/filters/filter-signature.c                     |    4 +-
 lib/filters/filter-sysfs.c                         |    4 +-
 lib/filters/filter-type.c                          |    4 +-
 lib/filters/filter-usable.c                        |    8 +-
 lib/filters/filter.h                               |    4 +-
 lib/format_text/archive.c                          |   12 ++--
 lib/format_text/archiver.c                         |   18 ++--
 lib/format_text/archiver.h                         |    2 +-
 lib/format_text/export.c                           |   16 ++--
 lib/format_text/flags.c                            |    6 +-
 lib/format_text/format-text.c                      |   30 ++++----
 lib/format_text/format-text.h                      |    2 +-
 lib/format_text/import-export.h                    |    6 +-
 lib/format_text/import.c                           |    4 +-
 lib/format_text/import_vsn1.c                      |   26 +++---
 lib/format_text/layout.h                           |    8 +-
 lib/format_text/text_label.c                       |   10 +-
 lib/freeseg/freeseg.c                              |    6 +-
 lib/label/label.c                                  |   16 ++--
 lib/label/label.h                                  |    8 +-
 lib/locking/cluster_locking.c                      |   10 +-
 lib/locking/external_locking.c                     |   10 +-
 lib/locking/file_locking.c                         |   14 ++--
 lib/locking/locking.c                              |   18 ++--
 lib/locking/locking.h                              |    4 +-
 lib/locking/locking_types.h                        |    4 +-
 lib/locking/lvmlockd.c                             |   18 ++--
 lib/locking/lvmlockd.h                             |    4 +-
 lib/locking/no_locking.c                           |    8 +-
 lib/log/log.c                                      |   12 ++--
 lib/log/lvm-logging.h                              |    4 +-
 lib/lvmpolld/lvmpolld-client.c                     |   16 ++--
 lib/lvmpolld/polldaemon.h                          |    2 +-
 lib/metadata/cache_manip.c                         |   22 +++---
 lib/metadata/lv.c                                  |   16 ++--
 lib/metadata/lv.h                                  |    2 +-
 lib/metadata/lv_alloc.h                            |    2 +-
 lib/metadata/lv_manip.c                            |   34 ++++----
 lib/metadata/merge.c                               |   14 ++--
 lib/metadata/metadata-exported.h                   |   10 +-
 lib/metadata/metadata-liblvm.c                     |   16 ++--
 lib/metadata/metadata.c                            |   38 +++++-----
 lib/metadata/metadata.h                            |    6 +-
 lib/metadata/mirror.c                              |   26 +++---
 lib/metadata/pool_manip.c                          |   20 +++---
 lib/metadata/pv.c                                  |    6 +-
 lib/metadata/pv.h                                  |    4 +-
 lib/metadata/pv_manip.c                            |   16 ++--
 lib/metadata/pv_map.c                              |    2 +-
 lib/metadata/pv_map.h                              |    2 +-
 lib/metadata/raid_manip.c                          |   18 ++--
 lib/metadata/segtype.c                             |    6 +-
 lib/metadata/segtype.h                             |    2 +-
 lib/metadata/snapshot_manip.c                      |   14 ++--
 lib/metadata/thin_manip.c                          |   16 ++--
 lib/metadata/vg.c                                  |   16 ++--
 lib/metadata/vg.h                                  |    4 +-
 lib/mirror/mirrored.c                              |   24 +++---
 lib/misc/crc.c                                     |    6 +-
 lib/misc/crc_gen.c                                 |    2 +-
 lib/misc/lib.h                                     |   16 ++--
 lib/misc/lvm-exec.c                                |   10 +-
 lib/misc/lvm-exec.h                                |    2 +-
 lib/misc/lvm-file.c                                |    4 +-
 lib/misc/lvm-flock.c                               |   10 +-
 lib/misc/lvm-globals.c                             |   10 +-
 lib/misc/lvm-maths.c                               |    2 +-
 lib/misc/lvm-percent.c                             |    4 +-
 lib/misc/lvm-signal.c                              |    6 +-
 lib/misc/lvm-string.c                              |    8 +-
 lib/misc/lvm-wrappers.c                            |    2 +-
 lib/misc/sharedlib.c                               |    8 +-
 lib/misc/sharedlib.h                               |    2 +-
 lib/mm/memlock.c                                   |   10 +-
 lib/notify/lvmnotify.c                             |    6 +-
 lib/properties/prop_common.c                       |    4 +-
 lib/raid/raid.c                                    |   22 +++---
 lib/report/properties.c                            |    8 +-
 lib/report/properties.h                            |    8 +-
 lib/report/report.c                                |   22 +++---
 lib/report/report.h                                |    6 +-
 lib/snapshot/snapshot.c                            |   14 ++--
 lib/striped/striped.c                              |   26 +++---
 lib/thin/thin.c                                    |   16 ++--
 lib/unknown/unknown.c                              |   10 +-
 lib/uuid/uuid.c                                    |    6 +-
 lib/zero/zero.c                                    |    8 +-
 libdaemon/client/config-util.c                     |    6 +-
 libdaemon/client/daemon-client.c                   |    8 +-
 libdaemon/client/daemon-client.h                   |    2 +-
 libdaemon/client/daemon-io.c                       |    4 +-
 libdaemon/client/daemon-io.h                       |    2 +-
 libdaemon/server/daemon-log.c                      |    2 +-
 libdaemon/server/daemon-server.c                   |    4 +-
 libdaemon/server/daemon-server.h                   |    2 +-
 libdm/datastruct/bitset.c                          |    2 +-
 libdm/datastruct/hash.c                            |    2 +-
 libdm/datastruct/list.c                            |    2 +-
 libdm/ioctl/libdm-iface.c                          |    6 +-
 libdm/libdm-common.c                               |    6 +-
 libdm/libdm-common.h                               |    2 +-
 libdm/libdm-config.c                               |    2 +-
 libdm/libdm-deptree.c                              |    6 +-
 libdm/libdm-file.c                                 |    2 +-
 libdm/libdm-report.c                               |    2 +-
 libdm/libdm-stats.c                                |    4 +-
 libdm/libdm-string.c                               |    2 +-
 libdm/libdm-targets.c                              |    2 +-
 libdm/libdm-timestamp.c                            |    2 +-
 libdm/misc/dm-log-userspace.h                      |    2 +-
 libdm/misc/dm-logging.h                            |    4 +-
 libdm/misc/dmlib.h                                 |    2 +-
 libdm/mm/dbg_malloc.c                              |    2 +-
 libdm/mm/pool-debug.c                              |    2 +-
 libdm/mm/pool-fast.c                               |    2 +-
 libdm/mm/pool.c                                    |    2 +-
 libdm/regex/matcher.c                              |    2 +-
 libdm/regex/parse_rx.c                             |    2 +-
 libdm/regex/ttree.c                                |    2 +-
 liblvm/lvm_base.c                                  |   10 +-
 liblvm/lvm_lv.c                                    |   16 ++--
 liblvm/lvm_misc.c                                  |    6 +-
 liblvm/lvm_misc.h                                  |    8 +-
 liblvm/lvm_prop.c                                  |    4 +-
 liblvm/lvm_prop.h                                  |    2 +-
 liblvm/lvm_pv.c                                    |   16 ++--
 liblvm/lvm_vg.c                                    |   20 +++---
 make.tmpl.in                                       |    8 +-
 python/liblvm.c                                    |    4 +-
 .../lvm2_activation_generator_systemd_red_hat.c    |    4 +-
 test/api/lvtest.c                                  |    2 +-
 test/api/pe_start.c                                |    2 +-
 test/api/percent.c                                 |    2 +-
 test/api/test.c                                    |    2 +-
 test/api/thin_percent.c                            |    2 +-
 test/api/vglist.c                                  |    2 +-
 test/api/vgtest.c                                  |    2 +-
 test/unit/bcache_t.c                               |    2 +-
 test/unit/bcache_utils_t.c                         |    2 +-
 test/unit/bitset_t.c                               |    2 +-
 test/unit/config_t.c                               |    2 +-
 test/unit/dmlist_t.c                               |    2 +-
 test/unit/dmstatus_t.c                             |    2 +-
 test/unit/framework.h                              |    2 +-
 test/unit/io_engine_t.c                            |    2 +-
 test/unit/matcher_t.c                              |    2 +-
 test/unit/percent_t.c                              |    2 +-
 test/unit/string_t.c                               |    2 +-
 tools/dmsetup.c                                    |    6 +-
 tools/lvchange.c                                   |    2 +-
 tools/lvconvert.c                                  |    4 +-
 tools/lvconvert_poll.h                             |    2 +-
 tools/lvm2cmd-static.c                             |    2 +-
 tools/lvm2cmd.c                                    |    2 +-
 tools/lvmcmdlib.c                                  |    6 +-
 tools/lvmcmdline.c                                 |    8 +-
 tools/lvpoll.c                                     |    4 +-
 tools/polldaemon.c                                 |    4 +-
 tools/pvmove.c                                     |    6 +-
 tools/pvscan.c                                     |    4 +-
 tools/reporter.c                                   |    2 +-
 tools/tool.h                                       |    4 +-
 tools/toollib.c                                    |    2 +-
 tools/toollib.h                                    |    4 +-
 tools/tools.h                                      |   44 ++++++------
 tools/vgcfgrestore.c                               |    2 +-
 tools/vgimportclone.c                              |    6 +-
 250 files changed, 915 insertions(+), 1017 deletions(-)

diff --git a/configure b/configure
index e874932..3b88dad 100755
--- a/configure
+++ b/configure
@@ -15559,7 +15559,7 @@ _ACEOF
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/locking/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/
 Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lv
 m2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile lib/locking/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/li
 blvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_syst
 emd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -16281,7 +16281,6 @@ do
     "conf/lvmlocal.conf") CONFIG_FILES="$CONFIG_FILES conf/lvmlocal.conf" ;;
     "conf/command_profile_template.profile") CONFIG_FILES="$CONFIG_FILES conf/command_profile_template.profile" ;;
     "conf/metadata_profile_template.profile") CONFIG_FILES="$CONFIG_FILES conf/metadata_profile_template.profile" ;;
-    "include/.symlinks") CONFIG_FILES="$CONFIG_FILES include/.symlinks" ;;
     "include/Makefile") CONFIG_FILES="$CONFIG_FILES include/Makefile" ;;
     "lib/Makefile") CONFIG_FILES="$CONFIG_FILES lib/Makefile" ;;
     "lib/locking/Makefile") CONFIG_FILES="$CONFIG_FILES lib/locking/Makefile" ;;
diff --git a/configure.ac b/configure.ac
index 5738b05..a05f051 100644
--- a/configure.ac
+++ b/configure.ac
@@ -2113,7 +2113,6 @@ conf/example.conf
 conf/lvmlocal.conf
 conf/command_profile_template.profile
 conf/metadata_profile_template.profile
-include/.symlinks
 include/Makefile
 lib/Makefile
 lib/locking/Makefile
diff --git a/daemons/clvmd/clvmd-cman.c b/daemons/clvmd/clvmd-cman.c
index ece9229..8cf7f17 100644
--- a/daemons/clvmd/clvmd-cman.c
+++ b/daemons/clvmd/clvmd-cman.c
@@ -22,7 +22,7 @@
 #include <pthread.h>
 
 #include "clvmd-comms.h"
-#include "clvm.h"
+#include "daemons/clvmd/clvm.h"
 #include "clvmd.h"
 #include "lvm-functions.h"
 
diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index ce7f500..342adda 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -52,12 +52,12 @@
 
 #include "clvmd-common.h"
 #include "clvmd-comms.h"
-#include "clvm.h"
+#include "daemons/clvmd/clvm.h"
 #include "clvmd.h"
-#include "lvm-globals.h"
+#include "lib/misc/lvm-globals.h"
 #include "lvm-functions.h"
 
-#include "locking.h"
+#include "lib/locking/locking.h"
 
 #include <sys/utsname.h>
 
diff --git a/daemons/clvmd/clvmd-common.h b/daemons/clvmd/clvmd-common.h
index 3be0e1d..fb1c487 100644
--- a/daemons/clvmd/clvmd-common.h
+++ b/daemons/clvmd/clvmd-common.h
@@ -20,8 +20,8 @@
 
 #define _REENTRANT
 
-#include "tool.h"
+#include "tools/tool.h"
 
-#include "lvm-logging.h"
+#include "lib/log/lvm-logging.h"
 
 #endif
diff --git a/daemons/clvmd/clvmd-corosync.c b/daemons/clvmd/clvmd-corosync.c
index 2227cbf..6a9705d 100644
--- a/daemons/clvmd/clvmd-corosync.c
+++ b/daemons/clvmd/clvmd-corosync.c
@@ -21,12 +21,12 @@
 
 #include <pthread.h>
 
-#include "clvm.h"
+#include "daemons/clvmd/clvm.h"
 #include "clvmd-comms.h"
 #include "clvmd.h"
 #include "lvm-functions.h"
 
-#include "locking.h"
+#include "lib/locking/locking.h"
 
 #include <corosync/cpg.h>
 #include <corosync/quorum.h>
diff --git a/daemons/clvmd/clvmd-openais.c b/daemons/clvmd/clvmd-openais.c
index 6e09bf6..6b4fb10 100644
--- a/daemons/clvmd/clvmd-openais.c
+++ b/daemons/clvmd/clvmd-openais.c
@@ -29,8 +29,8 @@
 #include <corosync/corotypes.h>
 #include <corosync/cpg.h>
 
-#include "locking.h"
-#include "clvm.h"
+#include "lib/locking/locking.h"
+#include "daemons/clvmd/clvm.h"
 #include "clvmd-comms.h"
 #include "lvm-functions.h"
 #include "clvmd.h"
diff --git a/daemons/clvmd/clvmd-singlenode.c b/daemons/clvmd/clvmd-singlenode.c
index af0a544..2d53f13 100644
--- a/daemons/clvmd/clvmd-singlenode.c
+++ b/daemons/clvmd/clvmd-singlenode.c
@@ -16,8 +16,8 @@
 
 #include <pthread.h>
 
-#include "locking.h"
-#include "clvm.h"
+#include "lib/locking/locking.h"
+#include "daemons/clvmd/clvm.h"
 #include "clvmd-comms.h"
 #include "clvmd.h"
 
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 829c5e5..73f4711 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -20,7 +20,7 @@
 #include "clvmd-common.h"
 
 #include "clvmd-comms.h"
-#include "clvm.h"
+#include "daemons/clvmd/clvm.h"
 #include "clvmd.h"
 #include "lvm-functions.h"
 #include "lvm-version.h"
diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 34da66d..c287fad 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -17,18 +17,18 @@
 
 #include <pthread.h>
 
-#include "clvm.h"
+#include "daemons/clvmd/clvm.h"
 #include "clvmd-comms.h"
 #include "clvmd.h"
 #include "lvm-functions.h"
 
 /* LVM2 headers */
-#include "toolcontext.h"
-#include "lvmcache.h"
-#include "lvm-globals.h"
-#include "activate.h"
-#include "archiver.h"
-#include "memlock.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/cache/lvmcache.h"
+#include "lib/misc/lvm-globals.h"
+#include "lib/activate/activate.h"
+#include "lib/format_text/archiver.h"
+#include "lib/mm/memlock.h"
 
 #include <syslog.h>
 
diff --git a/daemons/clvmd/refresh_clvmd.c b/daemons/clvmd/refresh_clvmd.c
index 6f89566..c80e09f 100644
--- a/daemons/clvmd/refresh_clvmd.c
+++ b/daemons/clvmd/refresh_clvmd.c
@@ -21,7 +21,7 @@
 
 #include "clvmd-common.h"
 
-#include "clvm.h"
+#include "daemons/clvmd/clvm.h"
 #include "refresh_clvmd.h"
 
 #include <stddef.h>
diff --git a/daemons/cmirrord/cluster.c b/daemons/cmirrord/cluster.c
index 180e34a..6bb9d63 100644
--- a/daemons/cmirrord/cluster.c
+++ b/daemons/cmirrord/cluster.c
@@ -16,7 +16,7 @@
 #include "functions.h"
 #include "link_mon.h"
 #include "local.h"
-#include "xlate.h"
+#include "lib/mm/xlate.h"
 
 #include <corosync/cpg.h>
 #include <errno.h>
diff --git a/daemons/cmirrord/cluster.h b/daemons/cmirrord/cluster.h
index 5b1e58b..0efbd64 100644
--- a/daemons/cmirrord/cluster.h
+++ b/daemons/cmirrord/cluster.h
@@ -12,8 +12,8 @@
 #ifndef _LVM_CLOG_CLUSTER_H
 #define _LVM_CLOG_CLUSTER_H
 
-#include "dm-log-userspace.h"
-#include "libdevmapper.h"
+#include "libdm/misc/dm-log-userspace.h"
+#include "libdm/libdevmapper.h"
 
 #define DM_ULOG_RESPONSE 0x1000U /* in last byte of 32-bit value */
 #define DM_ULOG_CHECKPOINT_READY 21
diff --git a/daemons/cmirrord/compat.c b/daemons/cmirrord/compat.c
index a9696d7..c0dd793 100644
--- a/daemons/cmirrord/compat.c
+++ b/daemons/cmirrord/compat.c
@@ -8,7 +8,7 @@
 #include "logging.h"
 #include "cluster.h"
 #include "compat.h"
-#include "xlate.h"
+#include "lib/mm/xlate.h"
 
 #include <errno.h>
 
diff --git a/daemons/cmirrord/functions.h b/daemons/cmirrord/functions.h
index 4620f99..c770459 100644
--- a/daemons/cmirrord/functions.h
+++ b/daemons/cmirrord/functions.h
@@ -12,7 +12,7 @@
 #ifndef _LVM_CLOG_FUNCTIONS_H
 #define _LVM_CLOG_FUNCTIONS_H
 
-#include "dm-log-userspace.h"
+#include "libdm/misc/dm-log-userspace.h"
 #include "cluster.h"
 
 #define LOG_RESUMED   1
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 8917422..438cf16 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -16,12 +16,12 @@
  * dmeventd - dm event daemon to monitor active mapped devices
  */
 
-#include "dm-logging.h"
+#include "libdm/misc/dm-logging.h"
 
-#include "libdevmapper-event.h"
+#include "daemons/dmeventd/libdevmapper-event.h"
 #include "dmeventd.h"
 
-#include "tool.h"
+#include "tools/tool.h"
 
 #include <dlfcn.h>
 #include <pthread.h>
diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 9aeb4c5..a75924c 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -12,9 +12,9 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "dm-logging.h"
-#include "dmlib.h"
-#include "libdevmapper-event.h"
+#include "libdm/misc/dm-logging.h"
+#include "libdm/misc/dmlib.h"
+#include "daemons/dmeventd/libdevmapper-event.h"
 #include "dmeventd.h"
 
 #include <fcntl.h>
diff --git a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
index 930f9fc..5861154 100644
--- a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
+++ b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
@@ -12,10 +12,10 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
+#include "lib/misc/lib.h"
 #include "dmeventd_lvm.h"
-#include "libdevmapper-event.h"
-#include "lvm2cmd.h"
+#include "daemons/dmeventd/libdevmapper-event.h"
+#include "tools/lvm2cmd.h"
 
 #include <pthread.h>
 
diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index 071fb16..ca483fd 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -12,10 +12,10 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "libdevmapper-event.h"
+#include "lib/misc/lib.h"
+#include "daemons/dmeventd/libdevmapper-event.h"
 #include "dmeventd_lvm.h"
-#include "activate.h"	/* For TARGET_NAME* */
+#include "lib/activate/activate.h"
 
 /* FIXME Reformat to 80 char lines. */
 
diff --git a/daemons/dmeventd/plugins/raid/dmeventd_raid.c b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
index 52cf43d..7871500 100644
--- a/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -12,10 +12,10 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "defaults.h"
+#include "lib/misc/lib.h"
+#include "lib/config/defaults.h"
 #include "dmeventd_lvm.h"
-#include "libdevmapper-event.h"
+#include "daemons/dmeventd/libdevmapper-event.h"
 
 /* Hold enough elements for the mximum number of RAID images */
 #define	RAID_DEVS_ELEMS	((DEFAULT_RAID_MAX_IMAGES + 63) / 64)
diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index 93697a0..6ffa9fc 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -12,9 +12,9 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
+#include "lib/misc/lib.h"
 #include "dmeventd_lvm.h"
-#include "libdevmapper-event.h"
+#include "daemons/dmeventd/libdevmapper-event.h"
 
 #include <sys/sysmacros.h>
 #include <sys/wait.h>
diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index 29b0391..14bfd80 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -12,16 +12,16 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"	/* using here lvm log */
+#include "lib/misc/lib.h"
 #include "dmeventd_lvm.h"
-#include "libdevmapper-event.h"
+#include "daemons/dmeventd/libdevmapper-event.h"
 
 #include <sys/wait.h>
 #include <stdarg.h>
 
 /* TODO - move this mountinfo code into library to be reusable */
 #ifdef __linux__
-#  include "kdev_t.h"
+#  include "libdm/misc/kdev_t.h"
 #else
 #  define MAJOR(x) major((x))
 #  define MINOR(x) minor((x))
diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index 7519799..7fc95c8 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -14,11 +14,11 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "tool.h"
+#include "tools/tool.h"
 
-#include "dm-logging.h"
+#include "libdm/misc/dm-logging.h"
 
-#include "defaults.h"
+#include "lib/config/defaults.h"
 
 #include <sys/types.h>
 #include <sys/stat.h>
diff --git a/daemons/lvmetad/lvmetactl.c b/daemons/lvmetad/lvmetactl.c
index dd2ee1e..7805409 100644
--- a/daemons/lvmetad/lvmetactl.c
+++ b/daemons/lvmetad/lvmetactl.c
@@ -8,9 +8,9 @@
  * of the GNU Lesser General Public License v.2.1.
  */
 
-#include "tool.h"
+#include "tools/tool.h"
 
-#include "lvmetad-client.h"
+#include "daemons/lvmetad/lvmetad-client.h"
 
 daemon_handle h;
 
diff --git a/daemons/lvmetad/lvmetad-client.h b/daemons/lvmetad/lvmetad-client.h
index be2623a..a9d4d83 100644
--- a/daemons/lvmetad/lvmetad-client.h
+++ b/daemons/lvmetad/lvmetad-client.h
@@ -15,7 +15,7 @@
 #ifndef _LVM_LVMETAD_CLIENT_H
 #define _LVM_LVMETAD_CLIENT_H
 
-#include "daemon-client.h"
+#include "libdaemon/client/daemon-client.h"
 
 #define LVMETAD_SOCKET DEFAULT_RUN_DIR "/lvmetad.socket"
 
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 72473d7..8858e29 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -16,13 +16,13 @@
 
 #define _REENTRANT
 
-#include "tool.h"
+#include "tools/tool.h"
 
-#include "daemon-io.h"
+#include "libdaemon/client/daemon-io.h"
 #include "daemon-server.h"
 #include "daemon-log.h"
 #include "lvm-version.h"
-#include "lvmetad-client.h"
+#include "daemons/lvmetad/lvmetad-client.h"
 
 #include <assert.h>
 #include <errno.h>
diff --git a/daemons/lvmetad/testclient.c b/daemons/lvmetad/testclient.c
index c9efbe6..06fa332 100644
--- a/daemons/lvmetad/testclient.c
+++ b/daemons/lvmetad/testclient.c
@@ -11,12 +11,12 @@
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
-#include "tool.h"
+#include "tools/tool.h"
 
-#include "lvmetad-client.h"
-#include "label.h"
-#include "lvmcache.h"
-#include "metadata.h"
+#include "daemons/lvmetad/lvmetad-client.h"
+#include "lib/label/label.h"
+#include "lib/cache/lvmcache.h"
+#include "lib/metadata/metadata.h"
 
 const char *uuid1 = "abcd-efgh";
 const char *uuid2 = "bbcd-efgh";
diff --git a/daemons/lvmlockd/lvmlockctl.c b/daemons/lvmlockd/lvmlockctl.c
index 436221d..2442b46 100644
--- a/daemons/lvmlockd/lvmlockctl.c
+++ b/daemons/lvmlockd/lvmlockctl.c
@@ -8,9 +8,9 @@
  * of the GNU Lesser General Public License v.2.1.
  */
 
-#include "tool.h"
+#include "tools/tool.h"
 
-#include "lvmlockd-client.h"
+#include "daemons/lvmlockd/lvmlockd-client.h"
 
 #include <stddef.h>
 #include <getopt.h>
diff --git a/daemons/lvmlockd/lvmlockd-client.h b/daemons/lvmlockd/lvmlockd-client.h
index bc90596..16d1613 100644
--- a/daemons/lvmlockd/lvmlockd-client.h
+++ b/daemons/lvmlockd/lvmlockd-client.h
@@ -11,7 +11,7 @@
 #ifndef _LVM_LVMLOCKD_CLIENT_H
 #define _LVM_LVMLOCKD_CLIENT_H
 
-#include "daemon-client.h"
+#include "libdaemon/client/daemon-client.h"
 
 #define LVMLOCKD_SOCKET DEFAULT_RUN_DIR "/lvmlockd.socket"
 
diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index df6e214..e75d02b 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -12,14 +12,14 @@
 #define _ISOC99_SOURCE
 #define _REENTRANT
 
-#include "tool.h"
+#include "tools/tool.h"
 
-#include "daemon-io.h"
+#include "libdaemon/client/daemon-io.h"
 #include "daemon-server.h"
 #include "lvm-version.h"
-#include "lvmetad-client.h"
-#include "lvmlockd-client.h"
-#include "dm-ioctl.h" /* for DM_UUID_LEN */
+#include "daemons/lvmetad/lvmetad-client.h"
+#include "daemons/lvmlockd/lvmlockd-client.h"
+#include "libdm/misc/dm-ioctl.h"
 
 /* #include <assert.h> */
 #include <errno.h>
diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index d9dfabb..668c75b 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -11,13 +11,13 @@
 #define _XOPEN_SOURCE 500  /* pthread */
 #define _ISOC99_SOURCE
 
-#include "tool.h"
+#include "tools/tool.h"
 
 #include "daemon-server.h"
-#include "xlate.h"
+#include "lib/mm/xlate.h"
 
 #include "lvmlockd-internal.h"
-#include "lvmlockd-client.h"
+#include "daemons/lvmlockd/lvmlockd-client.h"
 
 /*
  * Using synchronous _wait dlm apis so do not define _REENTRANT and
diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index a91218b..d5d6864 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -11,13 +11,13 @@
 #define _XOPEN_SOURCE 500  /* pthread */
 #define _ISOC99_SOURCE
 
-#include "tool.h"
+#include "tools/tool.h"
 
 #include "daemon-server.h"
-#include "xlate.h"
+#include "lib/mm/xlate.h"
 
 #include "lvmlockd-internal.h"
-#include "lvmlockd-client.h"
+#include "daemons/lvmlockd/lvmlockd-client.h"
 
 #include "sanlock.h"
 #include "sanlock_rv.h"
diff --git a/daemons/lvmpolld/lvmpolld-common.h b/daemons/lvmpolld/lvmpolld-common.h
index b31081a..4ada581 100644
--- a/daemons/lvmpolld/lvmpolld-common.h
+++ b/daemons/lvmpolld/lvmpolld-common.h
@@ -20,10 +20,10 @@
 
 #define _REENTRANT
 
-#include "tool.h"
+#include "tools/tool.h"
 
 #include "lvmpolld-cmd-utils.h"
-#include "lvmpolld-protocol.h"
+#include "daemons/lvmpolld/lvmpolld-protocol.h"
 
 #include <assert.h>
 #include <errno.h>
diff --git a/daemons/lvmpolld/lvmpolld-data-utils.c b/daemons/lvmpolld/lvmpolld-data-utils.c
index 8debcdd..d5e1139 100644
--- a/daemons/lvmpolld/lvmpolld-data-utils.c
+++ b/daemons/lvmpolld/lvmpolld-data-utils.c
@@ -14,7 +14,7 @@
 
 #include "lvmpolld-common.h"
 
-#include "config-util.h"
+#include "libdaemon/client/config-util.h"
 
 #include <fcntl.h>
 #include <signal.h>
diff --git a/daemons/lvmpolld/lvmpolld-protocol.h b/daemons/lvmpolld/lvmpolld-protocol.h
index 4e6ae9e..9b9890d 100644
--- a/daemons/lvmpolld/lvmpolld-protocol.h
+++ b/daemons/lvmpolld/lvmpolld-protocol.h
@@ -15,7 +15,7 @@
 #ifndef _LVM_LVMPOLLD_PROTOCOL_H
 #define _LVM_LVMPOLLD_PROTOCOL_H
 
-#include "polling_ops.h"
+#include "daemons/lvmpolld/polling_ops.h"
 
 #define LVMPOLLD_PROTOCOL "lvmpolld"
 #define LVMPOLLD_PROTOCOL_VERSION 1
diff --git a/device-mapper/vdo/status.c b/device-mapper/vdo/status.c
index 157111f..1739a7e 100644
--- a/device-mapper/vdo/status.c
+++ b/device-mapper/vdo/status.c
@@ -1,7 +1,7 @@
 #include "target.h"
 
 // For DM_ARRAY_SIZE!
-#include "libdevmapper.h"
+#include "libdm/libdevmapper.h"
 
 #include <ctype.h>
 #include <stdlib.h>
diff --git a/doc/example_cmdlib.c b/doc/example_cmdlib.c
index 66e3532..ec5e028 100644
--- a/doc/example_cmdlib.c
+++ b/doc/example_cmdlib.c
@@ -12,7 +12,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lvm2cmd.h"
+#include "tools/lvm2cmd.h"
 #include <stdio.h>
 
 /* All output gets passed to this function line-by-line */
diff --git a/include/.symlinks.in b/include/.symlinks.in
deleted file mode 100644
index 3d50750..0000000
--- a/include/.symlinks.in
+++ /dev/null
@@ -1,80 +0,0 @@
- at top_srcdir@/daemons/clvmd/clvm.h
- at top_srcdir@/daemons/dmeventd/libdevmapper-event.h
- at top_srcdir@/daemons/lvmetad/lvmetad-client.h
- at top_srcdir@/daemons/lvmlockd/lvmlockd-client.h
- at top_srcdir@/daemons/lvmpolld/lvmpolld-protocol.h
- at top_srcdir@/daemons/lvmpolld/polling_ops.h
- at top_srcdir@/lib/activate/activate.h
- at top_srcdir@/lib/activate/targets.h
- at top_srcdir@/lib/cache/lvmcache.h
- at top_srcdir@/lib/cache/lvmetad.h
- at top_srcdir@/lib/commands/toolcontext.h
- at top_srcdir@/lib/config/config.h
- at top_srcdir@/lib/config/config_settings.h
- at top_srcdir@/lib/config/defaults.h
- at top_srcdir@/lib/datastruct/btree.h
- at top_srcdir@/lib/datastruct/str_list.h
- at top_srcdir@/lib/device/bcache.h
- at top_srcdir@/lib/device/dev-cache.h
- at top_srcdir@/lib/device/dev-ext-udev-constants.h
- at top_srcdir@/lib/device/dev-type.h
- at top_srcdir@/lib/device/device-types.h
- at top_srcdir@/lib/device/device.h
- at top_srcdir@/lib/display/display.h
- at top_srcdir@/lib/filters/filter.h
- at top_srcdir@/lib/format1/format1.h
- at top_srcdir@/lib/format_pool/format_pool.h
- at top_srcdir@/lib/format_text/archiver.h
- at top_srcdir@/lib/format_text/format-text.h
- at top_srcdir@/lib/format_text/text_export.h
- at top_srcdir@/lib/format_text/text_import.h
- at top_srcdir@/lib/label/label.h
- at top_srcdir@/lib/locking/locking.h
- at top_srcdir@/lib/locking/lvmlockd.h
- at top_srcdir@/lib/log/log.h
- at top_srcdir@/lib/log/lvm-logging.h
- at top_srcdir@/lib/lvmpolld/lvmpolld-client.h
- at top_srcdir@/lib/lvmpolld/polldaemon.h
- at top_srcdir@/lib/metadata/lv.h
- at top_srcdir@/lib/metadata/lv_alloc.h
- at top_srcdir@/lib/metadata/metadata-exported.h
- at top_srcdir@/lib/metadata/metadata.h
- at top_srcdir@/lib/metadata/pv.h
- at top_srcdir@/lib/metadata/pv_alloc.h
- at top_srcdir@/lib/metadata/segtype.h
- at top_srcdir@/lib/metadata/vg.h
- at top_srcdir@/lib/misc/crc.h
- at top_srcdir@/lib/misc/intl.h
- at top_srcdir@/lib/misc/last-path-component.h
- at top_srcdir@/lib/misc/lib.h
- at top_srcdir@/lib/misc/lvm-exec.h
- at top_srcdir@/lib/misc/lvm-file.h
- at top_srcdir@/lib/misc/lvm-flock.h
- at top_srcdir@/lib/misc/lvm-globals.h
- at top_srcdir@/lib/misc/lvm-maths.h
- at top_srcdir@/lib/misc/lvm-percent.h
- at top_srcdir@/lib/misc/lvm-signal.h
- at top_srcdir@/lib/misc/lvm-string.h
- at top_srcdir@/lib/misc/lvm-wrappers.h
- at top_srcdir@/lib/misc/sharedlib.h
- at top_srcdir@/lib/misc/util.h
- at top_srcdir@/lib/mm/memlock.h
- at top_srcdir@/lib/mm/xlate.h
- at top_srcdir@/lib/notify/lvmnotify.h
- at top_srcdir@/lib/properties/prop_common.h
- at top_srcdir@/lib/report/properties.h
- at top_srcdir@/lib/report/report.h
- at top_srcdir@/lib/uuid/uuid.h
- at top_srcdir@/libdaemon/client/config-util.h
- at top_srcdir@/libdaemon/client/daemon-client.h
- at top_srcdir@/libdaemon/client/daemon-io.h
- at top_srcdir@/libdm/libdevmapper.h
- at top_srcdir@/libdm/misc/dm-ioctl.h
- at top_srcdir@/libdm/misc/dm-log-userspace.h
- at top_srcdir@/libdm/misc/dm-logging.h
- at top_srcdir@/libdm/misc/dmlib.h
- at top_srcdir@/libdm/misc/kdev_t.h
- at top_srcdir@/liblvm/lvm2app.h
- at top_srcdir@/po/pogen.h
- at top_srcdir@/tools/lvm2cmd.h
- at top_srcdir@/tools/tool.h
diff --git a/include/Makefile.in b/include/Makefile.in
index b2571fd..cbbc003 100644
--- a/include/Makefile.in
+++ b/include/Makefile.in
@@ -18,22 +18,4 @@ top_builddir = @top_builddir@
 
 include $(top_builddir)/make.tmpl
 
-all: .symlinks_created
-
-LINKS := $(shell find . -maxdepth 1 -type l)
-
-.symlinks_created: .symlinks
-ifneq (,$(firstword $(LINKS)))
-	$(RM) $(LINKS)
-endif
-	for i in `cat $<`; do $(LN_S) $$i ; done
-	touch $@
-
-pofile: all
-
-device-mapper: all
-
-cflow: all
-
-DISTCLEAN_TARGETS += .symlinks configure.h lvm-version.h
-CLEAN_TARGETS += $(LINKS) .include_symlinks .symlinks_created
+DISTCLEAN_TARGETS += .configure.h lvm-version.h
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 985215a..a15a2d7 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -13,23 +13,23 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "metadata.h"
-#include "activate.h"
-#include "memlock.h"
-#include "display.h"
+#include "lib/misc/lib.h"
+#include "lib/metadata/metadata.h"
+#include "lib/activate/activate.h"
+#include "lib/mm/memlock.h"
+#include "lib/display/display.h"
 #include "fs.h"
-#include "lvm-exec.h"
-#include "lvm-file.h"
-#include "lvm-string.h"
-#include "toolcontext.h"
+#include "lib/misc/lvm-exec.h"
+#include "lib/misc/lvm-file.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/commands/toolcontext.h"
 #include "dev_manager.h"
-#include "str_list.h"
-#include "config.h"
-#include "segtype.h"
-#include "sharedlib.h"
-#include "lvmcache.h"
-#include "metadata.h"
+#include "lib/datastruct/str_list.h"
+#include "lib/config/config.h"
+#include "lib/metadata/segtype.h"
+#include "lib/misc/sharedlib.h"
+#include "lib/cache/lvmcache.h"
+#include "lib/metadata/metadata.h"
 
 #include <limits.h>
 #include <fcntl.h>
@@ -413,7 +413,7 @@ void fs_unlock(void)
 {
 }
 /* dev_manager.c */
-#include "targets.h"
+#include "lib/activate/targets.h"
 int add_areas_line(struct dev_manager *dm, struct lv_segment *seg,
 		   struct dm_tree_node *node, uint32_t start_area,
 		   uint32_t areas)
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index d2c6db7..60ee4a7 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -16,7 +16,7 @@
 #ifndef LVM_ACTIVATE_H
 #define LVM_ACTIVATE_H
 
-#include "metadata-exported.h"
+#include "lib/metadata/metadata-exported.h"
 
 struct lvinfo {
 	int exists;
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index a7947d8..5dd0e6f 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -13,19 +13,19 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
+#include "lib/misc/lib.h"
 #include "dev_manager.h"
-#include "lvm-string.h"
+#include "lib/misc/lvm-string.h"
 #include "fs.h"
-#include "defaults.h"
-#include "segtype.h"
-#include "display.h"
-#include "toolcontext.h"
-#include "targets.h"
-#include "config.h"
-#include "activate.h"
-#include "lvm-exec.h"
-#include "str_list.h"
+#include "lib/config/defaults.h"
+#include "lib/metadata/segtype.h"
+#include "lib/display/display.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/activate/targets.h"
+#include "lib/config/config.h"
+#include "lib/activate/activate.h"
+#include "lib/misc/lvm-exec.h"
+#include "lib/datastruct/str_list.h"
 
 #include <limits.h>
 #include <dirent.h>
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index 5be417b..809fd04 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -16,7 +16,7 @@
 #ifndef _LVM_DEV_MANAGER_H
 #define _LVM_DEV_MANAGER_H
 
-#include "metadata-exported.h"
+#include "lib/metadata/metadata-exported.h"
 
 struct logical_volume;
 struct lv_activate_opts;
diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index 498ec8f..6e07eda 100644
--- a/lib/activate/fs.c
+++ b/lib/activate/fs.c
@@ -13,13 +13,13 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
+#include "lib/misc/lib.h"
 #include "fs.h"
-#include "activate.h"
-#include "toolcontext.h"
-#include "lvm-string.h"
-#include "lvm-file.h"
-#include "memlock.h"
+#include "lib/activate/activate.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/misc/lvm-file.h"
+#include "lib/mm/memlock.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>
diff --git a/lib/activate/fs.h b/lib/activate/fs.h
index 37938ec..b0dbadc 100644
--- a/lib/activate/fs.h
+++ b/lib/activate/fs.h
@@ -16,7 +16,7 @@
 #ifndef _LVM_FS_H
 #define _LVM_FS_H
 
-#include "metadata.h"
+#include "lib/metadata/metadata.h"
 
 /*
  * These calls, private to the activate unit, set
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 290d733..dc72dee 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -13,19 +13,19 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "lvmcache.h"
-#include "toolcontext.h"
-#include "dev-cache.h"
-#include "locking.h"
-#include "metadata.h"
-#include "memlock.h"
-#include "str_list.h"
-#include "format-text.h"
-#include "config.h"
-
-#include "lvmetad.h"
-#include "lvmetad-client.h"
+#include "lib/misc/lib.h"
+#include "lib/cache/lvmcache.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/device/dev-cache.h"
+#include "lib/locking/locking.h"
+#include "lib/metadata/metadata.h"
+#include "lib/mm/memlock.h"
+#include "lib/datastruct/str_list.h"
+#include "lib/format_text/format-text.h"
+#include "lib/config/config.h"
+
+#include "lib/cache/lvmetad.h"
+#include "daemons/lvmetad/lvmetad-client.h"
 
 #define CACHE_LOCKED	0x00000002
 
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 797ff21..3bda64a 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -16,11 +16,11 @@
 #ifndef _LVM_CACHE_H
 #define _LVM_CACHE_H
 
-#include "dev-cache.h"
-#include "dev-type.h"
-#include "uuid.h"
-#include "label.h"
-#include "locking.h"
+#include "lib/device/dev-cache.h"
+#include "lib/device/dev-type.h"
+#include "lib/uuid/uuid.h"
+#include "lib/label/label.h"
+#include "lib/locking/locking.h"
 
 #define ORPHAN_PREFIX VG_ORPHANS
 #define ORPHAN_VG_NAME(fmt) ORPHAN_PREFIX "_" fmt
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 235f72b..757d269 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -12,18 +12,18 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "toolcontext.h"
-#include "metadata.h"
-#include "device.h"
-#include "lvmetad.h"
-#include "lvmcache.h"
-#include "lvmetad-client.h"
-#include "format-text.h" // TODO for disk_locn, used as a DA representation
-#include "crc.h"
-#include "lvm-signal.h"
-#include "lvmlockd.h"
-#include "str_list.h"
+#include "lib/misc/lib.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/metadata/metadata.h"
+#include "lib/device/device.h"
+#include "lib/cache/lvmetad.h"
+#include "lib/cache/lvmcache.h"
+#include "daemons/lvmetad/lvmetad-client.h"
+#include "lib/format_text/format-text.h"
+#include "lib/misc/crc.h"
+#include "lib/misc/lvm-signal.h"
+#include "lib/locking/lvmlockd.h"
+#include "lib/datastruct/str_list.h"
 
 #include <time.h>
 
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 73c2645..3363607 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -15,7 +15,7 @@
 #ifndef _LVM_METAD_H
 #define _LVM_METAD_H
 
-#include "config-util.h"
+#include "libdaemon/client/config-util.h"
 
 #include <stdint.h>
 
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 26f3e32..b7119d2 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -12,18 +12,18 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "toolcontext.h"
-#include "segtype.h"
-#include "display.h"
-#include "text_export.h"
-#include "config.h"
-#include "str_list.h"
-#include "lvm-string.h"
-#include "activate.h"
-#include "metadata.h"
-#include "lv_alloc.h"
-#include "defaults.h"
+#include "lib/misc/lib.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/metadata/segtype.h"
+#include "lib/display/display.h"
+#include "lib/format_text/text_export.h"
+#include "lib/config/config.h"
+#include "lib/datastruct/str_list.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/activate/activate.h"
+#include "lib/metadata/metadata.h"
+#include "lib/metadata/lv_alloc.h"
+#include "lib/config/defaults.h"
 
 static const char _cache_module[] = "cache";
 #define CACHE_POLICY_WHEN_MISSING   "mq"
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index e9f9357..7d0640a 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -13,27 +13,27 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "toolcontext.h"
-#include "metadata.h"
-#include "defaults.h"
-#include "lvm-string.h"
-#include "activate.h"
-#include "filter.h"
-#include "label.h"
-#include "lvm-file.h"
-#include "format-text.h"
-#include "display.h"
-#include "memlock.h"
-#include "str_list.h"
-#include "segtype.h"
-#include "lvmcache.h"
-#include "lvmetad.h"
-#include "archiver.h"
-#include "lvmpolld-client.h"
+#include "lib/misc/lib.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/metadata/metadata.h"
+#include "lib/config/defaults.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/activate/activate.h"
+#include "lib/filters/filter.h"
+#include "lib/label/label.h"
+#include "lib/misc/lvm-file.h"
+#include "lib/format_text/format-text.h"
+#include "lib/display/display.h"
+#include "lib/mm/memlock.h"
+#include "lib/datastruct/str_list.h"
+#include "lib/metadata/segtype.h"
+#include "lib/cache/lvmcache.h"
+#include "lib/cache/lvmetad.h"
+#include "lib/format_text/archiver.h"
+#include "lib/lvmpolld/lvmpolld-client.h"
 
 #ifdef HAVE_LIBDL
-#include "sharedlib.h"
+#include "lib/misc/sharedlib.h"
 #endif
 
 #include <locale.h>
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 83c8e82..b46e301 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -16,8 +16,8 @@
 #ifndef _LVM_TOOLCONTEXT_H
 #define _LVM_TOOLCONTEXT_H
 
-#include "dev-cache.h"
-#include "dev-type.h"
+#include "lib/device/dev-cache.h"
+#include "lib/device/dev-type.h"
 
 #include <limits.h>
 
diff --git a/lib/config/config.c b/lib/config/config.c
index ad816c2..c638d75 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -14,16 +14,16 @@
  */
 
 
-#include "lib.h"
+#include "lib/misc/lib.h"
 
-#include "config.h"
-#include "crc.h"
-#include "device.h"
-#include "str_list.h"
-#include "toolcontext.h"
-#include "lvm-file.h"
-#include "memlock.h"
-#include "label.h"
+#include "lib/config/config.h"
+#include "lib/misc/crc.h"
+#include "lib/device/device.h"
+#include "lib/datastruct/str_list.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/misc/lvm-file.h"
+#include "lib/mm/memlock.h"
+#include "lib/label/label.h"
 
 #include <sys/stat.h>
 #include <sys/mman.h>
@@ -71,7 +71,7 @@ static struct cfg_def_item _cfg_def_items[CFG_COUNT + 1] = {
 #define cfg_runtime(id, name, parent, flags, type, since_version, deprecated_since_version, deprecation_comment, comment) {id, parent, name, type, {.fn_##type = get_default_##id}, (flags) | CFG_DEFAULT_RUN_TIME, since_version, {.fn_UNCONFIGURED = get_default_unconfigured_##id}, deprecated_since_version, (deprecation_comment), comment},
 #define cfg_array(id, name, parent, flags, types, default_value, since_version, unconfigured_value, deprecated_since_version, deprecation_comment, comment) {id, parent, name, CFG_TYPE_ARRAY | (types), {.v_CFG_TYPE_STRING = (default_value)}, (flags), (since_version), {.v_UNCONFIGURED = (unconfigured_value)}, deprecated_since_version, deprecation_comment, comment},
 #define cfg_array_runtime(id, name, parent, flags, types, since_version, deprecated_since_version, deprecation_comment, comment) {id, parent, name, CFG_TYPE_ARRAY | (types), {.fn_CFG_TYPE_STRING = get_default_##id}, (flags) | CFG_DEFAULT_RUN_TIME, (since_version), {.fn_UNCONFIGURED = get_default_unconfigured_##id}, deprecated_since_version, deprecation_comment, comment},
-#include "config_settings.h"
+#include "lib/config/config_settings.h"
 #undef cfg_section
 #undef cfg
 #undef cfg_runtime
diff --git a/lib/config/config.h b/lib/config/config.h
index d01306b..b797c78 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -16,8 +16,8 @@
 #ifndef _LVM_CONFIG_H
 #define _LVM_CONFIG_H
 
-#include "libdevmapper.h"
-#include "device.h"
+#include "libdm/libdevmapper.h"
+#include "lib/device/device.h"
 
 /* 16 bits: 3 bits for major, 4 bits for minor, 9 bits for patchlevel */
 /* FIXME Max LVM version supported: 7.15.511. Extend bits when needed. */
@@ -196,7 +196,7 @@ enum {
 #define cfg_runtime(id, name, parent, flags, type, since_version, deprecated_since_version, deprecation_comment, comment) id,
 #define cfg_array(id, name, parent, flags, types, default_value, since_version, unconfigured_value, deprecated_since_version, deprecation_comment, comment) id,
 #define cfg_array_runtime(id, name, parent, flags, types, since_version, deprecated_since_version, deprecation_comment, comment) id,
-#include "config_settings.h"
+#include "lib/config/config_settings.h"
 #undef cfg_section
 #undef cfg
 #undef cfg_runtime
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index d8db7df..c591b8a 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -117,7 +117,7 @@
  * default values, the new defaults are used by LVM unless
  * the previous default value was set (uncommented) in lvm.conf.
  */
-#include "defaults.h"
+#include "lib/config/defaults.h"
 
 cfg_section(root_CFG_SECTION, "(root)", root_CFG_SECTION, 0, vsn(0, 0, 0), 0, NULL, NULL)
 
diff --git a/lib/datastruct/btree.c b/lib/datastruct/btree.c
index 67d1492..efb2166 100644
--- a/lib/datastruct/btree.c
+++ b/lib/datastruct/btree.c
@@ -13,8 +13,8 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "btree.h"
+#include "lib/misc/lib.h"
+#include "lib/datastruct/btree.h"
 
 struct node {
 	uint32_t key;
diff --git a/lib/datastruct/str_list.c b/lib/datastruct/str_list.c
index 6fe5672..efbdeda 100644
--- a/lib/datastruct/str_list.c
+++ b/lib/datastruct/str_list.c
@@ -13,8 +13,8 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "str_list.h"
+#include "lib/misc/lib.h"
+#include "lib/datastruct/str_list.h"
 
 struct dm_list *str_list_create(struct dm_pool *mem)
 {
diff --git a/lib/device/bcache-utils.c b/lib/device/bcache-utils.c
index a533a66..2553554 100644
--- a/lib/device/bcache-utils.c
+++ b/lib/device/bcache-utils.c
@@ -12,7 +12,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "bcache.h"
+#include "lib/device/bcache.h"
 
 // FIXME: need to define this in a common place (that doesn't pull in deps)
 #ifndef SECTOR_SHIFT
diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 9085d87..aa6bb7a 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -14,9 +14,9 @@
 
 #define _GNU_SOURCE
 
-#include "bcache.h"
-#include "dm-logging.h"
-#include "log.h"
+#include "lib/device/bcache.h"
+#include "libdm/misc/dm-logging.h"
+#include "lib/log/log.h"
 
 #include <errno.h>
 #include <fcntl.h>
diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index b0aebb4..cf3d668 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -15,7 +15,7 @@
 #ifndef BCACHE_H
 #define BCACHE_H
 
-#include "libdevmapper.h"
+#include "libdm/libdevmapper.h"
 
 #include <linux/fs.h>
 #include <stdint.h>
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 15d4cdf..f3c2326 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -13,12 +13,12 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "btree.h"
-#include "config.h"
-#include "toolcontext.h"
-#include "dm-ioctl.h" /* for DM_UUID_LEN */
-#include "lvm-string.h" /* for LVM's UUID_PREFIX */
+#include "lib/misc/lib.h"
+#include "lib/datastruct/btree.h"
+#include "lib/config/config.h"
+#include "lib/commands/toolcontext.h"
+#include "libdm/misc/dm-ioctl.h"
+#include "lib/misc/lvm-string.h"
 
 #ifdef UDEV_SYNC_SUPPORT
 #include <libudev.h>
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index 4797274..1a822b8 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -16,8 +16,8 @@
 #ifndef _LVM_DEV_CACHE_H
 #define _LVM_DEV_CACHE_H
 
-#include "device.h"
-#include "lvm-wrappers.h"
+#include "lib/device/device.h"
+#include "lib/misc/lvm-wrappers.h"
 
 /*
  * predicate for devices.
diff --git a/lib/device/dev-dasd.c b/lib/device/dev-dasd.c
index ab9b00f..dc11030 100644
--- a/lib/device/dev-dasd.c
+++ b/lib/device/dev-dasd.c
@@ -12,9 +12,9 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "metadata.h"
-#include "dev-type.h"
+#include "lib/misc/lib.h"
+#include "lib/metadata/metadata.h"
+#include "lib/device/dev-type.h"
 #include <sys/ioctl.h>
 
 #ifdef __linux__
diff --git a/lib/device/dev-ext.c b/lib/device/dev-ext.c
index 0c3b435..15e9c2b 100644
--- a/lib/device/dev-ext.c
+++ b/lib/device/dev-ext.c
@@ -12,8 +12,8 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "device.h"
+#include "lib/misc/lib.h"
+#include "lib/device/device.h"
 
 #ifdef UDEV_SYNC_SUPPORT
 #include <libudev.h>
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index cce5a94..225fb36 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -13,12 +13,12 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "device.h"
-#include "metadata.h"
-#include "lvmcache.h"
-#include "memlock.h"
-#include "locking.h"
+#include "lib/misc/lib.h"
+#include "lib/device/device.h"
+#include "lib/metadata/metadata.h"
+#include "lib/cache/lvmcache.h"
+#include "lib/mm/memlock.h"
+#include "lib/locking/locking.h"
 
 #include <limits.h>
 #include <sys/stat.h>
diff --git a/lib/device/dev-luks.c b/lib/device/dev-luks.c
index 25a8b2c..344a554 100644
--- a/lib/device/dev-luks.c
+++ b/lib/device/dev-luks.c
@@ -12,8 +12,8 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "dev-type.h"
+#include "lib/misc/lib.h"
+#include "lib/device/dev-type.h"
 
 #define LUKS_SIGNATURE "LUKS\xba\xbe"
 #define LUKS_SIGNATURE_SIZE 6
diff --git a/lib/device/dev-lvm1-pool.c b/lib/device/dev-lvm1-pool.c
index 1fc3805..b51aba5 100644
--- a/lib/device/dev-lvm1-pool.c
+++ b/lib/device/dev-lvm1-pool.c
@@ -12,9 +12,9 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "dev-type.h"
-#include "xlate.h"
+#include "lib/misc/lib.h"
+#include "lib/device/dev-type.h"
+#include "lib/mm/xlate.h"
 
 /*
  * These lvm1 structs just used NAME_LEN in the previous format1 lvm2 code, but
diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index f32c1c3..6e69e45 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -13,12 +13,12 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "dev-type.h"
-#include "xlate.h"
+#include "lib/misc/lib.h"
+#include "lib/device/dev-type.h"
+#include "lib/mm/xlate.h"
 #ifdef UDEV_SYNC_SUPPORT
 #include <libudev.h> /* for MD detection using udev db records */
-#include "dev-ext-udev-constants.h"
+#include "lib/device/dev-ext-udev-constants.h"
 #endif
 
 #ifdef __linux__
diff --git a/lib/device/dev-swap.c b/lib/device/dev-swap.c
index 3bfb72b..564bb58 100644
--- a/lib/device/dev-swap.c
+++ b/lib/device/dev-swap.c
@@ -12,8 +12,8 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "dev-type.h"
+#include "lib/misc/lib.h"
+#include "lib/device/dev-type.h"
 
 #ifdef __linux__
 
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 8d4a403..eb33b81 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -12,13 +12,13 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "dev-type.h"
-#include "xlate.h"
-#include "config.h"
-#include "metadata.h"
-#include "bcache.h"
-#include "label.h"
+#include "lib/misc/lib.h"
+#include "lib/device/dev-type.h"
+#include "lib/mm/xlate.h"
+#include "lib/config/config.h"
+#include "lib/metadata/metadata.h"
+#include "lib/device/bcache.h"
+#include "lib/label/label.h"
 
 #include <libgen.h>
 #include <ctype.h>
@@ -29,10 +29,10 @@
 
 #ifdef UDEV_SYNC_SUPPORT
 #include <libudev.h>
-#include "dev-ext-udev-constants.h"
+#include "lib/device/dev-ext-udev-constants.h"
 #endif
 
-#include "device-types.h"
+#include "lib/device/device-types.h"
 
 struct dev_types *create_dev_types(const char *proc_dir,
 				   const struct dm_config_node *cn)
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index 843e254..210a316 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -15,14 +15,14 @@
 #ifndef _LVM_DEV_TYPE_H
 #define _LVM_DEV_TYPE_H
 
-#include "device.h"
-#include "display.h"
-#include "label.h"
+#include "lib/device/device.h"
+#include "lib/display/display.h"
+#include "lib/label/label.h"
 
 #define NUMBER_OF_MAJORS 4096
 
 #ifdef __linux__
-#  include "kdev_t.h"
+#  include "libdm/misc/kdev_t.h"
 #else
 #  define MAJOR(x) major((x))
 #  define MINOR(x) minor((x))
diff --git a/lib/device/device.h b/lib/device/device.h
index fd8cbb7..18b4150 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -16,7 +16,7 @@
 #ifndef _LVM_DEVICE_H
 #define _LVM_DEVICE_H
 
-#include "uuid.h"
+#include "lib/uuid/uuid.h"
 
 #include <fcntl.h>
 
diff --git a/lib/display/display.c b/lib/display/display.c
index 9b4be88..c6f855b 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -13,14 +13,14 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "metadata.h"
-#include "display.h"
-#include "activate.h"
-#include "toolcontext.h"
-#include "segtype.h"
-#include "defaults.h"
-#include "lvm-signal.h"
+#include "lib/misc/lib.h"
+#include "lib/metadata/metadata.h"
+#include "lib/display/display.h"
+#include "lib/activate/activate.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/metadata/segtype.h"
+#include "lib/config/defaults.h"
+#include "lib/misc/lvm-signal.h"
 
 #include <stdarg.h>
 
diff --git a/lib/display/display.h b/lib/display/display.h
index 9f9afe9..9911321 100644
--- a/lib/display/display.h
+++ b/lib/display/display.h
@@ -16,9 +16,9 @@
 #ifndef _LVM_DISPLAY_H
 #define _LVM_DISPLAY_H
 
-#include "metadata-exported.h"
-#include "locking.h"
-#include "lvm-string.h"
+#include "lib/metadata/metadata-exported.h"
+#include "lib/locking/locking.h"
+#include "lib/misc/lvm-string.h"
 
 #include <stdint.h>
 
diff --git a/lib/error/errseg.c b/lib/error/errseg.c
index 6b355fc..9f0262a 100644
--- a/lib/error/errseg.c
+++ b/lib/error/errseg.c
@@ -12,14 +12,14 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "toolcontext.h"
-#include "segtype.h"
-#include "display.h"
-#include "config.h"
-#include "str_list.h"
-#include "activate.h"
-#include "str_list.h"
+#include "lib/misc/lib.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/metadata/segtype.h"
+#include "lib/display/display.h"
+#include "lib/config/config.h"
+#include "lib/datastruct/str_list.h"
+#include "lib/activate/activate.h"
+#include "lib/datastruct/str_list.h"
 
 static int _errseg_merge_segments(struct lv_segment *seg1, struct lv_segment *seg2)
 {
diff --git a/lib/filters/filter-composite.c b/lib/filters/filter-composite.c
index f15ff12..8d9e061 100644
--- a/lib/filters/filter-composite.c
+++ b/lib/filters/filter-composite.c
@@ -13,9 +13,9 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "filter.h"
-#include "device.h"
+#include "lib/misc/lib.h"
+#include "lib/filters/filter.h"
+#include "lib/device/device.h"
 
 static int _and_p(struct dev_filter *f, struct device *dev)
 {
diff --git a/lib/filters/filter-fwraid.c b/lib/filters/filter-fwraid.c
index 22ef74a..62022b3 100644
--- a/lib/filters/filter-fwraid.c
+++ b/lib/filters/filter-fwraid.c
@@ -12,12 +12,12 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "filter.h"
+#include "lib/misc/lib.h"
+#include "lib/filters/filter.h"
 
 #ifdef UDEV_SYNC_SUPPORT
 #include <libudev.h>
-#include "dev-ext-udev-constants.h"
+#include "lib/device/dev-ext-udev-constants.h"
 #endif
 
 #ifdef __linux__
diff --git a/lib/filters/filter-internal.c b/lib/filters/filter-internal.c
index cdaee4e..ebbee7e 100644
--- a/lib/filters/filter-internal.c
+++ b/lib/filters/filter-internal.c
@@ -12,8 +12,8 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "filter.h"
+#include "lib/misc/lib.h"
+#include "lib/filters/filter.h"
 
 static DM_LIST_INIT(_allow_devs);
 
diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
index bb8a7cf..40d674a 100644
--- a/lib/filters/filter-md.c
+++ b/lib/filters/filter-md.c
@@ -13,8 +13,8 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "filter.h"
+#include "lib/misc/lib.h"
+#include "lib/filters/filter.h"
 
 #ifdef __linux__
 
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 6763be3..a7dc12e 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -12,12 +12,12 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "filter.h"
-#include "activate.h"
+#include "lib/misc/lib.h"
+#include "lib/filters/filter.h"
+#include "lib/activate/activate.h"
 #ifdef UDEV_SYNC_SUPPORT
 #include <libudev.h>
-#include "dev-ext-udev-constants.h"
+#include "lib/device/dev-ext-udev-constants.h"
 #endif
 
 #ifdef __linux__
diff --git a/lib/filters/filter-partitioned.c b/lib/filters/filter-partitioned.c
index 5e1c4e8..a85e182 100644
--- a/lib/filters/filter-partitioned.c
+++ b/lib/filters/filter-partitioned.c
@@ -13,8 +13,8 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "filter.h"
+#include "lib/misc/lib.h"
+#include "lib/filters/filter.h"
 
 #define MSG_SKIPPING "%s: Skipping: Partition table signature found"
 
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 3fa57f1..4a17189 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -13,10 +13,10 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "filter.h"
-#include "config.h"
-#include "lvm-file.h"
+#include "lib/misc/lib.h"
+#include "lib/filters/filter.h"
+#include "lib/config/config.h"
+#include "lib/misc/lvm-file.h"
 
 struct pfilter {
 	char *file;
diff --git a/lib/filters/filter-regex.c b/lib/filters/filter-regex.c
index f7cc072..c642ec4 100644
--- a/lib/filters/filter-regex.c
+++ b/lib/filters/filter-regex.c
@@ -13,8 +13,8 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "filter.h"
+#include "lib/misc/lib.h"
+#include "lib/filters/filter.h"
 
 struct rfilter {
 	struct dm_pool *mem;
diff --git a/lib/filters/filter-signature.c b/lib/filters/filter-signature.c
index 23b01e7..3aa6284 100644
--- a/lib/filters/filter-signature.c
+++ b/lib/filters/filter-signature.c
@@ -13,8 +13,8 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "filter.h"
+#include "lib/misc/lib.h"
+#include "lib/filters/filter.h"
 
 #ifdef __linux__
 
diff --git a/lib/filters/filter-sysfs.c b/lib/filters/filter-sysfs.c
index 93862e6..5b54312 100644
--- a/lib/filters/filter-sysfs.c
+++ b/lib/filters/filter-sysfs.c
@@ -12,8 +12,8 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "filter.h"
+#include "lib/misc/lib.h"
+#include "lib/filters/filter.h"
 
 #ifdef __linux__
 
diff --git a/lib/filters/filter-type.c b/lib/filters/filter-type.c
index 092b023..8ec3025 100644
--- a/lib/filters/filter-type.c
+++ b/lib/filters/filter-type.c
@@ -13,8 +13,8 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "filter.h"
+#include "lib/misc/lib.h"
+#include "lib/filters/filter.h"
 
 static int _passes_lvm_type_device_filter(struct dev_filter *f, struct device *dev)
 {
diff --git a/lib/filters/filter-usable.c b/lib/filters/filter-usable.c
index 2de2a0f..45c7832 100644
--- a/lib/filters/filter-usable.c
+++ b/lib/filters/filter-usable.c
@@ -12,12 +12,12 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "filter.h"
-#include "activate.h" /* device_is_usable */
+#include "lib/misc/lib.h"
+#include "lib/filters/filter.h"
+#include "lib/activate/activate.h"
 #ifdef UDEV_SYNC_SUPPORT
 #include <libudev.h>
-#include "dev-ext-udev-constants.h"
+#include "lib/device/dev-ext-udev-constants.h"
 #endif
 
 static const char *_too_small_to_hold_pv_msg = "Too small to hold a PV";
diff --git a/lib/filters/filter.h b/lib/filters/filter.h
index 6245827..ff9cc1b 100644
--- a/lib/filters/filter.h
+++ b/lib/filters/filter.h
@@ -17,8 +17,8 @@
 #ifndef _LVM_FILTER_H
 #define _LVM_FILTER_H
 
-#include "dev-cache.h"
-#include "dev-type.h"
+#include "lib/device/dev-cache.h"
+#include "lib/device/dev-type.h"
 
 struct dev_filter *composite_filter_create(int n, int use_dev_ext_info, struct dev_filter **filters);
 
diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
index 690bc74..f0c4392 100644
--- a/lib/format_text/archive.c
+++ b/lib/format_text/archive.c
@@ -13,14 +13,14 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "format-text.h"
+#include "lib/misc/lib.h"
+#include "lib/format_text/format-text.h"
 
-#include "config.h"
+#include "lib/config/config.h"
 #include "import-export.h"
-#include "lvm-string.h"
-#include "lvm-file.h"
-#include "toolcontext.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/misc/lvm-file.h"
+#include "lib/commands/toolcontext.h"
 
 #include <dirent.h>
 #include <unistd.h>
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index c8aeb47..9d7be95 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -13,15 +13,15 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "archiver.h"
-#include "format-text.h"
-#include "lvm-string.h"
-#include "lvmcache.h"
-#include "lvmetad.h"
-#include "memlock.h"
-#include "toolcontext.h"
-#include "locking.h"
+#include "lib/misc/lib.h"
+#include "lib/format_text/archiver.h"
+#include "lib/format_text/format-text.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/cache/lvmcache.h"
+#include "lib/cache/lvmetad.h"
+#include "lib/mm/memlock.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/locking/locking.h"
 
 #include <unistd.h>
 
diff --git a/lib/format_text/archiver.h b/lib/format_text/archiver.h
index e949751..fa4c1a4 100644
--- a/lib/format_text/archiver.h
+++ b/lib/format_text/archiver.h
@@ -16,7 +16,7 @@
 #ifndef _LVM_TOOL_ARCHIVE_H
 #define _LVM_TOOL_ARCHIVE_H
 
-#include "metadata-exported.h"
+#include "lib/metadata/metadata-exported.h"
 
 /*
  * There are two operations that come under the general area of
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 7866d56..2924aea 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -13,16 +13,16 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
+#include "lib/misc/lib.h"
 #include "import-export.h"
-#include "metadata.h"
-#include "display.h"
-#include "lvm-string.h"
-#include "segtype.h"
-#include "text_export.h"
+#include "lib/metadata/metadata.h"
+#include "lib/display/display.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/metadata/segtype.h"
+#include "lib/format_text/text_export.h"
 #include "lvm-version.h"
-#include "toolcontext.h"
-#include "config-util.h"
+#include "lib/commands/toolcontext.h"
+#include "libdaemon/client/config-util.h"
 
 #include <stdarg.h>
 #include <time.h>
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 7e793b3..69d8afc 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -13,10 +13,10 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "metadata.h"
+#include "lib/misc/lib.h"
+#include "lib/metadata/metadata.h"
 #include "import-export.h"
-#include "lvm-string.h"
+#include "lib/misc/lvm-string.h"
 
 /*
  * Bitsets held in the 'status' flags get
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 5c7b72f..c834335 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -13,23 +13,23 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "format-text.h"
+#include "lib/misc/lib.h"
+#include "lib/format_text/format-text.h"
 #include "import-export.h"
-#include "device.h"
-#include "lvm-file.h"
-#include "config.h"
-#include "display.h"
-#include "toolcontext.h"
-#include "lvm-string.h"
-#include "uuid.h"
+#include "lib/device/device.h"
+#include "lib/misc/lvm-file.h"
+#include "lib/config/config.h"
+#include "lib/display/display.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/uuid/uuid.h"
 #include "layout.h"
-#include "crc.h"
-#include "xlate.h"
-#include "label.h"
-#include "lvmcache.h"
-#include "lvmetad.h"
-#include "memlock.h"
+#include "lib/misc/crc.h"
+#include "lib/mm/xlate.h"
+#include "lib/label/label.h"
+#include "lib/cache/lvmcache.h"
+#include "lib/cache/lvmetad.h"
+#include "lib/mm/memlock.h"
 
 #include <unistd.h>
 #include <sys/param.h>
diff --git a/lib/format_text/format-text.h b/lib/format_text/format-text.h
index d6e6b03..1300e58 100644
--- a/lib/format_text/format-text.h
+++ b/lib/format_text/format-text.h
@@ -16,7 +16,7 @@
 #ifndef _LVM_FORMAT_TEXT_H
 #define _LVM_FORMAT_TEXT_H
 
-#include "metadata.h"
+#include "lib/metadata/metadata.h"
 
 #define FMT_TEXT_NAME "lvm2"
 #define FMT_TEXT_ALIAS "text"
diff --git a/lib/format_text/import-export.h b/lib/format_text/import-export.h
index 920eb3e..b7a8fa6 100644
--- a/lib/format_text/import-export.h
+++ b/lib/format_text/import-export.h
@@ -16,9 +16,9 @@
 #ifndef _LVM_TEXT_IMPORT_EXPORT_H
 #define _LVM_TEXT_IMPORT_EXPORT_H
 
-#include "config.h"
-#include "metadata.h"
-#include "lvmcache.h"
+#include "lib/config/config.h"
+#include "lib/metadata/metadata.h"
+#include "lib/cache/lvmcache.h"
 
 #include <stdio.h>
 
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 4b34485..0836662 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -13,8 +13,8 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "metadata.h"
+#include "lib/misc/lib.h"
+#include "lib/metadata/metadata.h"
 #include "import-export.h"
 
 /* FIXME Use tidier inclusion method */
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 58f517e..15d4422 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -13,20 +13,20 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "metadata.h"
+#include "lib/misc/lib.h"
+#include "lib/metadata/metadata.h"
 #include "import-export.h"
-#include "display.h"
-#include "toolcontext.h"
-#include "lvmcache.h"
-#include "lvmetad.h"
-#include "lvmlockd.h"
-#include "lv_alloc.h"
-#include "pv_alloc.h"
-#include "segtype.h"
-#include "text_import.h"
-#include "defaults.h"
-#include "str_list.h"
+#include "lib/display/display.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/cache/lvmcache.h"
+#include "lib/cache/lvmetad.h"
+#include "lib/locking/lvmlockd.h"
+#include "lib/metadata/lv_alloc.h"
+#include "lib/metadata/pv_alloc.h"
+#include "lib/metadata/segtype.h"
+#include "lib/format_text/text_import.h"
+#include "lib/config/defaults.h"
+#include "lib/datastruct/str_list.h"
 
 typedef int (*section_fn) (struct format_instance * fid,
 			   struct volume_group * vg, const struct dm_config_node * pvn,
diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index 2671bbf..0a63708 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -16,10 +16,10 @@
 #ifndef _LVM_TEXT_LAYOUT_H
 #define _LVM_TEXT_LAYOUT_H
 
-#include "config.h"
-#include "metadata.h"
-#include "lvmcache.h"
-#include "uuid.h"
+#include "lib/config/config.h"
+#include "lib/metadata/metadata.h"
+#include "lib/cache/lvmcache.h"
+#include "lib/uuid/uuid.h"
 
 /* disk_locn and data_area_list are defined in format-text.h */
 
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 7d10e06..a7eaa6e 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -13,12 +13,12 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "format-text.h"
+#include "lib/misc/lib.h"
+#include "lib/format_text/format-text.h"
 #include "layout.h"
-#include "label.h"
-#include "xlate.h"
-#include "lvmcache.h"
+#include "lib/label/label.h"
+#include "lib/mm/xlate.h"
+#include "lib/cache/lvmcache.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>
diff --git a/lib/freeseg/freeseg.c b/lib/freeseg/freeseg.c
index 5e22615..90e9cd3 100644
--- a/lib/freeseg/freeseg.c
+++ b/lib/freeseg/freeseg.c
@@ -12,9 +12,9 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "toolcontext.h"
-#include "segtype.h"
+#include "lib/misc/lib.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/metadata/segtype.h"
 
 static void _freeseg_destroy(struct segment_type *segtype)
 {
diff --git a/lib/label/label.c b/lib/label/label.c
index 071c2e7..ba34c7d 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -13,14 +13,14 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "label.h"
-#include "crc.h"
-#include "xlate.h"
-#include "lvmcache.h"
-#include "bcache.h"
-#include "toolcontext.h"
-#include "activate.h"
+#include "lib/misc/lib.h"
+#include "lib/label/label.h"
+#include "lib/misc/crc.h"
+#include "lib/mm/xlate.h"
+#include "lib/cache/lvmcache.h"
+#include "lib/device/bcache.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/activate/activate.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>
diff --git a/lib/label/label.h b/lib/label/label.h
index 3483321..287d6d6 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -16,10 +16,10 @@
 #ifndef _LVM_LABEL_H
 #define _LVM_LABEL_H
 
-#include "uuid.h"
-#include "device.h"
-#include "bcache.h"
-#include "toolcontext.h"
+#include "lib/uuid/uuid.h"
+#include "lib/device/device.h"
+#include "lib/device/bcache.h"
+#include "lib/commands/toolcontext.h"
 
 #define LABEL_ID "LABELONE"
 #define LABEL_SIZE SECTOR_SIZE	/* Think very carefully before changing this */
diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index 038f6b6..0830b48 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -19,12 +19,12 @@
  * management operations across a cluster.
  */
 
-#include "lib.h"
-#include "clvm.h"
-#include "lvm-string.h"
-#include "locking.h"
+#include "lib/misc/lib.h"
+#include "daemons/clvmd/clvm.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/locking/locking.h"
 #include "locking_types.h"
-#include "toolcontext.h"
+#include "lib/commands/toolcontext.h"
 
 #include <assert.h>
 #include <stddef.h>
diff --git a/lib/locking/external_locking.c b/lib/locking/external_locking.c
index c89a167..a1169a5 100644
--- a/lib/locking/external_locking.c
+++ b/lib/locking/external_locking.c
@@ -13,12 +13,12 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
+#include "lib/misc/lib.h"
 #include "locking_types.h"
-#include "defaults.h"
-#include "sharedlib.h"
-#include "toolcontext.h"
-#include "activate.h"
+#include "lib/config/defaults.h"
+#include "lib/misc/sharedlib.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/activate/activate.h"
 
 static void *_locking_lib = NULL;
 static void (*_reset_fn) (void) = NULL;
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 8dbc54e..d4f47c6 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -13,14 +13,14 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "locking.h"
+#include "lib/misc/lib.h"
+#include "lib/locking/locking.h"
 #include "locking_types.h"
-#include "activate.h"
-#include "config.h"
-#include "defaults.h"
-#include "lvm-string.h"
-#include "lvm-flock.h"
+#include "lib/activate/activate.h"
+#include "lib/config/config.h"
+#include "lib/config/defaults.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/misc/lvm-flock.h"
 
 #include <limits.h>
 #include <unistd.h>
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 105419a..9db006f 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -13,16 +13,16 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "locking.h"
+#include "lib/misc/lib.h"
+#include "lib/locking/locking.h"
 #include "locking_types.h"
-#include "lvm-string.h"
-#include "activate.h"
-#include "toolcontext.h"
-#include "memlock.h"
-#include "defaults.h"
-#include "lvmcache.h"
-#include "lvm-signal.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/activate/activate.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/mm/memlock.h"
+#include "lib/config/defaults.h"
+#include "lib/cache/lvmcache.h"
+#include "lib/misc/lvm-signal.h"
 
 #include <assert.h>
 #include <sys/stat.h>
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index f2fbb00..8322bae 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -16,8 +16,8 @@
 #ifndef _LVM_LOCKING_H
 #define _LVM_LOCKING_H
 
-#include "uuid.h"
-#include "config.h"
+#include "lib/uuid/uuid.h"
+#include "lib/config/config.h"
 
 struct logical_volume;
 
diff --git a/lib/locking/locking_types.h b/lib/locking/locking_types.h
index 3306a8b..c4c832a 100644
--- a/lib/locking/locking_types.h
+++ b/lib/locking/locking_types.h
@@ -13,8 +13,8 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "metadata.h"
-#include "config.h"
+#include "lib/metadata/metadata.h"
+#include "lib/config/config.h"
 
 typedef int (*lock_resource_fn) (struct cmd_context * cmd, const char *resource,
 				 uint32_t flags, const struct logical_volume *lv);
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index d78b35c..6c67cf9 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -8,15 +8,15 @@
  * of the GNU Lesser General Public License v.2.1.
  */
 
-#include "lib.h"
-#include "toolcontext.h"
-#include "metadata.h"
-#include "segtype.h"
-#include "activate.h"
-#include "lvmetad.h"
-#include "lvmlockd.h"
-#include "lvmcache.h"
-#include "lvmlockd-client.h"
+#include "lib/misc/lib.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/metadata/metadata.h"
+#include "lib/metadata/segtype.h"
+#include "lib/activate/activate.h"
+#include "lib/cache/lvmetad.h"
+#include "lib/locking/lvmlockd.h"
+#include "lib/cache/lvmcache.h"
+#include "daemons/lvmlockd/lvmlockd-client.h"
 
 static daemon_handle _lvmlockd;
 static const char *_lvmlockd_socket = NULL;
diff --git a/lib/locking/lvmlockd.h b/lib/locking/lvmlockd.h
index cf23e9b..0a6ea96 100644
--- a/lib/locking/lvmlockd.h
+++ b/lib/locking/lvmlockd.h
@@ -11,8 +11,8 @@
 #ifndef _LVMLOCKD_H
 #define _LVMLOCKD_H
 
-#include "config-util.h"
-#include "daemon-client.h"
+#include "libdaemon/client/config-util.h"
+#include "libdaemon/client/daemon-client.h"
 
 #define LOCKD_SANLOCK_LV_NAME "lvmlock"
 
diff --git a/lib/locking/no_locking.c b/lib/locking/no_locking.c
index 3011746..fa066cc 100644
--- a/lib/locking/no_locking.c
+++ b/lib/locking/no_locking.c
@@ -13,11 +13,11 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "locking.h"
+#include "lib/misc/lib.h"
+#include "lib/locking/locking.h"
 #include "locking_types.h"
-#include "lvm-string.h"
-#include "activate.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/activate/activate.h"
 
 /*
  * No locking
diff --git a/lib/log/log.c b/lib/log/log.c
index 79fbd7a..a040ca5 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -13,12 +13,12 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "device.h"
-#include "memlock.h"
-#include "defaults.h"
-#include "report.h"
-#include "lvm-file.h"
+#include "lib/misc/lib.h"
+#include "lib/device/device.h"
+#include "lib/mm/memlock.h"
+#include "lib/config/defaults.h"
+#include "lib/report/report.h"
+#include "lib/misc/lvm-file.h"
 
 #include <stdio.h>
 #include <stdarg.h>
diff --git a/lib/log/lvm-logging.h b/lib/log/lvm-logging.h
index 64c1928..ca93ff4 100644
--- a/lib/log/lvm-logging.h
+++ b/lib/log/lvm-logging.h
@@ -16,7 +16,7 @@
 #ifndef _LVM_LOGGING_H
 #define _LVM_LOGGING_H
 
-#include "lvm-file.h"
+#include "lib/misc/lvm-file.h"
 
 __attribute__ ((format(printf, 5, 6)))
 void print_log(int level, const char *file, int line, int dm_errno_or_class,
@@ -35,7 +35,7 @@ void print_log_libdm(int level, const char *file, int line, int dm_errno_or_clas
 #define LOG_LINE_WITH_CLASS(l, c, x...) \
     print_log(l, __FILE__, __LINE__ , c, ## x)
 
-#include "log.h"
+#include "lib/log/log.h"
 
 int init_custom_log_streams(struct custom_fds *custom_fds);
 int reopen_standard_stream(FILE **stream, const char *mode);
diff --git a/lib/lvmpolld/lvmpolld-client.c b/lib/lvmpolld/lvmpolld-client.c
index 6d52f2a..78cf813 100644
--- a/lib/lvmpolld/lvmpolld-client.c
+++ b/lib/lvmpolld/lvmpolld-client.c
@@ -12,15 +12,15 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-
-#include "daemon-io.h"
-#include "lvmpolld-client.h"
-#include "lvmpolld-protocol.h"
-#include "metadata-exported.h"
-#include "polldaemon.h"
-#include "toolcontext.h"
-#include "lvm2cmd.h"
+#include "lib/misc/lib.h"
+
+#include "libdaemon/client/daemon-io.h"
+#include "lib/lvmpolld/lvmpolld-client.h"
+#include "daemons/lvmpolld/lvmpolld-protocol.h"
+#include "lib/metadata/metadata-exported.h"
+#include "lib/lvmpolld/polldaemon.h"
+#include "lib/commands/toolcontext.h"
+#include "tools/lvm2cmd.h"
 
 struct progress_info {
 	unsigned error:1;
diff --git a/lib/lvmpolld/polldaemon.h b/lib/lvmpolld/polldaemon.h
index 11688fe..17ef7cb 100644
--- a/lib/lvmpolld/polldaemon.h
+++ b/lib/lvmpolld/polldaemon.h
@@ -16,7 +16,7 @@
 #ifndef _LVM_TOOL_POLLDAEMON_H
 #define _LVM_TOOL_POLLDAEMON_H
 
-#include "metadata-exported.h"
+#include "lib/metadata/metadata-exported.h"
 
 typedef enum {
 	PROGRESS_CHECK_FAILED = 0,
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 2a54682..41a193d 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -12,17 +12,17 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "metadata.h"
-#include "locking.h"
-#include "lvm-string.h"
-#include "toolcontext.h"
-#include "display.h"
-#include "segtype.h"
-#include "activate.h"
-#include "defaults.h"
-#include "lv_alloc.h"
-#include "lvm-signal.h"
+#include "lib/misc/lib.h"
+#include "lib/metadata/metadata.h"
+#include "lib/locking/locking.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/display/display.h"
+#include "lib/metadata/segtype.h"
+#include "lib/activate/activate.h"
+#include "lib/config/defaults.h"
+#include "lib/metadata/lv_alloc.h"
+#include "lib/misc/lvm-signal.h"
 
 /* https://github.com/jthornber/thin-provisioning-tools/blob/master/caching/cache_metadata_size.cc */
 #define DM_TRANSACTION_OVERHEAD		4096  /* KiB */
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index b19ae34..54edc88 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -13,14 +13,14 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "metadata.h"
-#include "display.h"
-#include "activate.h"
-#include "toolcontext.h"
-#include "segtype.h"
-#include "str_list.h"
-#include "lvmlockd.h"
+#include "lib/misc/lib.h"
+#include "lib/metadata/metadata.h"
+#include "lib/display/display.h"
+#include "lib/activate/activate.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/metadata/segtype.h"
+#include "lib/datastruct/str_list.h"
+#include "lib/locking/lvmlockd.h"
 
 #include <time.h>
 #include <sys/utsname.h>
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 3fb10ae..920bcb5 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -15,7 +15,7 @@
 #ifndef _LVM_LV_H
 #define _LVM_LV_H
 
-#include "vg.h"
+#include "lib/metadata/vg.h"
 
 union lvid;
 struct lv_segment;
diff --git a/lib/metadata/lv_alloc.h b/lib/metadata/lv_alloc.h
index df51df2..ec672d0 100644
--- a/lib/metadata/lv_alloc.h
+++ b/lib/metadata/lv_alloc.h
@@ -16,7 +16,7 @@
 #ifndef _LVM_LV_ALLOC_H
 #define _LVM_LV_ALLOC_H
 
-#include "metadata-exported.h"
+#include "lib/metadata/metadata-exported.h"
 
 struct lv_segment *alloc_lv_segment(const struct segment_type *segtype,
 				    struct logical_volume *lv,
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8c76a38..affc50b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -13,24 +13,24 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "metadata.h"
-#include "locking.h"
+#include "lib/misc/lib.h"
+#include "lib/metadata/metadata.h"
+#include "lib/locking/locking.h"
 #include "pv_map.h"
-#include "lvm-string.h"
-#include "toolcontext.h"
-#include "lv_alloc.h"
-#include "pv_alloc.h"
-#include "display.h"
-#include "segtype.h"
-#include "archiver.h"
-#include "activate.h"
-#include "str_list.h"
-#include "defaults.h"
-#include "lvm-exec.h"
-#include "memlock.h"
-#include "lvmlockd.h"
-#include "label.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/metadata/lv_alloc.h"
+#include "lib/metadata/pv_alloc.h"
+#include "lib/display/display.h"
+#include "lib/metadata/segtype.h"
+#include "lib/format_text/archiver.h"
+#include "lib/activate/activate.h"
+#include "lib/datastruct/str_list.h"
+#include "lib/config/defaults.h"
+#include "lib/misc/lvm-exec.h"
+#include "lib/mm/memlock.h"
+#include "lib/locking/lvmlockd.h"
+#include "lib/label/label.h"
 
 typedef enum {
 	PREFERRED,
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 7299620..cf8789c 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -13,13 +13,13 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include <defaults.h>
-#include "metadata.h"
-#include "lv_alloc.h"
-#include "pv_alloc.h"
-#include "str_list.h"
-#include "segtype.h"
+#include "lib/misc/lib.h"
+#include "lib/config/defaults.h"
+#include "lib/metadata/metadata.h"
+#include "lib/metadata/lv_alloc.h"
+#include "lib/metadata/pv_alloc.h"
+#include "lib/datastruct/str_list.h"
+#include "lib/metadata/segtype.h"
 
 /*
  * Attempt to merge two adjacent segments.
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 97184ed..b09c0e6 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -21,11 +21,11 @@
 #ifndef _LVM_METADATA_EXPORTED_H
 #define _LVM_METADATA_EXPORTED_H
 
-#include "uuid.h"
-#include "pv.h"
-#include "vg.h"
-#include "lv.h"
-#include "lvm-percent.h"
+#include "lib/uuid/uuid.h"
+#include "lib/metadata/pv.h"
+#include "lib/metadata/vg.h"
+#include "lib/metadata/lv.h"
+#include "lib/misc/lvm-percent.h"
 
 #define MAX_STRIPES 128U
 #define SECTOR_SHIFT 9L
diff --git a/lib/metadata/metadata-liblvm.c b/lib/metadata/metadata-liblvm.c
index f7a07a5..cd34724 100644
--- a/lib/metadata/metadata-liblvm.c
+++ b/lib/metadata/metadata-liblvm.c
@@ -18,14 +18,14 @@
  * Ideally this file should be empty as liblvm and toollib should be doing identical things.
  * FIXME Merge all the code into different parts of the tree.
  */
-#include "lib.h"
-#include "toolcontext.h"
-#include "lvm-string.h"
-#include "metadata.h"
-#include "label.h"
-#include "lvm-signal.h"
-#include "lvmcache.h"
-#include "lvmetad.h"
+#include "lib/misc/lib.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/metadata/metadata.h"
+#include "lib/label/label.h"
+#include "lib/misc/lvm-signal.h"
+#include "lib/cache/lvmcache.h"
+#include "lib/cache/lvmetad.h"
 
 int vg_reduce(struct volume_group *vg, const char *pv_name)
 {
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b8f1b97..ddb0fd7 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -13,26 +13,26 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "device.h"
-#include "metadata.h"
-#include "toolcontext.h"
-#include "lvm-string.h"
-#include "lvm-file.h"
-#include "lvmcache.h"
-#include "lvmetad.h"
-#include "memlock.h"
-#include "str_list.h"
-#include "pv_alloc.h"
-#include "segtype.h"
-#include "activate.h"
-#include "display.h"
-#include "locking.h"
-#include "archiver.h"
-#include "defaults.h"
-#include "lvmlockd.h"
+#include "lib/misc/lib.h"
+#include "lib/device/device.h"
+#include "lib/metadata/metadata.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/misc/lvm-file.h"
+#include "lib/cache/lvmcache.h"
+#include "lib/cache/lvmetad.h"
+#include "lib/mm/memlock.h"
+#include "lib/datastruct/str_list.h"
+#include "lib/metadata/pv_alloc.h"
+#include "lib/metadata/segtype.h"
+#include "lib/activate/activate.h"
+#include "lib/display/display.h"
+#include "lib/locking/locking.h"
+#include "lib/format_text/archiver.h"
+#include "lib/config/defaults.h"
+#include "lib/locking/lvmlockd.h"
 #include "time.h"
-#include "lvmnotify.h"
+#include "lib/notify/lvmnotify.h"
 
 #include <math.h>
 #include <sys/param.h>
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 1e3dd1b..3d6750f 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -22,9 +22,9 @@
 #define _LVM_METADATA_H
 
 #include "ctype.h"
-#include "dev-cache.h"
-#include "lvm-string.h"
-#include "metadata-exported.h"
+#include "lib/device/dev-cache.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/metadata/metadata-exported.h"
 
 //#define MAX_STRIPES 128U
 //#define SECTOR_SHIFT 9L
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 054ca99..807259f 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -13,22 +13,22 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "metadata.h"
-#include "toolcontext.h"
-#include "segtype.h"
-#include "display.h"
-#include "archiver.h"
-#include "activate.h"
-#include "lv_alloc.h"
-#include "lvm-string.h"
-#include "str_list.h"
-#include "locking.h"	/* FIXME Should not be used in this file */
-
-#include "defaults.h" /* FIXME: should this be defaults.h? */
+#include "lib/misc/lib.h"
+#include "lib/metadata/metadata.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/metadata/segtype.h"
+#include "lib/display/display.h"
+#include "lib/format_text/archiver.h"
+#include "lib/activate/activate.h"
+#include "lib/metadata/lv_alloc.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/datastruct/str_list.h"
+#include "lib/locking/locking.h"
+
+#include "lib/config/defaults.h"
 
 /* These are necessary for _write_log_header() */
-#include "xlate.h"
+#include "lib/mm/xlate.h"
 #define MIRROR_MAGIC 0x4D695272
 #define MIRROR_DISK_VERSION 2
 
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index b832db7..20224d1 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -16,16 +16,16 @@
  * This file holds common pool functions.
  */
 
-#include "lib.h"
-#include "activate.h"
-#include "locking.h"
-#include "metadata.h"
-#include "segtype.h"
-#include "lv_alloc.h"
-#include "defaults.h"
-#include "dev-type.h"
-#include "display.h"
-#include "toolcontext.h"
+#include "lib/misc/lib.h"
+#include "lib/activate/activate.h"
+#include "lib/locking/locking.h"
+#include "lib/metadata/metadata.h"
+#include "lib/metadata/segtype.h"
+#include "lib/metadata/lv_alloc.h"
+#include "lib/config/defaults.h"
+#include "lib/device/dev-type.h"
+#include "lib/display/display.h"
+#include "lib/commands/toolcontext.h"
 #include <stddef.h>
 
 int attach_pool_metadata_lv(struct lv_segment *pool_seg,
diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index 9bf6075..7b6f778 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -13,9 +13,9 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "metadata.h"
-#include "lvmcache.h"
+#include "lib/misc/lib.h"
+#include "lib/metadata/metadata.h"
+#include "lib/cache/lvmcache.h"
 
 /*
  * FIXME: Check for valid handle before dereferencing field or log error?
diff --git a/lib/metadata/pv.h b/lib/metadata/pv.h
index e452ece..23d2bd7 100644
--- a/lib/metadata/pv.h
+++ b/lib/metadata/pv.h
@@ -15,8 +15,8 @@
 #ifndef _LVM_PV_H
 #define _LVM_PV_H
 
-#include "uuid.h"
-#include "libdevmapper.h"
+#include "lib/uuid/uuid.h"
+#include "libdm/libdevmapper.h"
 
 struct device;
 struct format_type;
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index e75be76..eaaa5e6 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -13,14 +13,14 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "metadata.h"
-#include "pv_alloc.h"
-#include "toolcontext.h"
-#include "locking.h"
-#include "defaults.h"
-#include "display.h"
-#include "archiver.h"
+#include "lib/misc/lib.h"
+#include "lib/metadata/metadata.h"
+#include "lib/metadata/pv_alloc.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/locking/locking.h"
+#include "lib/config/defaults.h"
+#include "lib/display/display.h"
+#include "lib/format_text/archiver.h"
 
 static struct pv_segment *_alloc_pv_segment(struct dm_pool *mem,
 					    struct physical_volume *pv,
diff --git a/lib/metadata/pv_map.c b/lib/metadata/pv_map.c
index 3707643..3ddb5c8 100644
--- a/lib/metadata/pv_map.c
+++ b/lib/metadata/pv_map.c
@@ -13,7 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
+#include "lib/misc/lib.h"
 #include "pv_map.h"
 
 #include <assert.h>
diff --git a/lib/metadata/pv_map.h b/lib/metadata/pv_map.h
index 4f8d0aa..6ffe36d 100644
--- a/lib/metadata/pv_map.h
+++ b/lib/metadata/pv_map.h
@@ -16,7 +16,7 @@
 #ifndef _LVM_PV_MAP_H
 #define _LVM_PV_MAP_H
 
-#include "metadata.h"
+#include "lib/metadata/metadata.h"
 
 /*
  * The in core rep. only stores a mapping from
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 703f285..cef0427 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -12,15 +12,15 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "archiver.h"
-#include "metadata.h"
-#include "toolcontext.h"
-#include "segtype.h"
-#include "display.h"
-#include "activate.h"
-#include "lv_alloc.h"
-#include "lvm-string.h"
+#include "lib/misc/lib.h"
+#include "lib/format_text/archiver.h"
+#include "lib/metadata/metadata.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/metadata/segtype.h"
+#include "lib/display/display.h"
+#include "lib/activate/activate.h"
+#include "lib/metadata/lv_alloc.h"
+#include "lib/misc/lvm-string.h"
 
 typedef int (*fn_on_lv_t)(struct logical_volume *lv, void *data);
 static int _eliminate_extracted_lvs_optional_write_vg(struct volume_group *vg,
diff --git a/lib/metadata/segtype.c b/lib/metadata/segtype.c
index d0508ca..2fdbaa3 100644
--- a/lib/metadata/segtype.c
+++ b/lib/metadata/segtype.c
@@ -13,9 +13,9 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "toolcontext.h"
-#include "segtype.h"
+#include "lib/misc/lib.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/metadata/segtype.h"
 
 struct segment_type *get_segtype_from_string(struct cmd_context *cmd,
 					     const char *str)
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 40b41ec..fe19b34 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -16,7 +16,7 @@
 #ifndef _SEGTYPES_H
 #define _SEGTYPES_H
 
-#include "metadata-exported.h"
+#include "lib/metadata/metadata-exported.h"
 
 struct segtype_handler;
 struct cmd_context;
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 76d78f3..e3669ef 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -13,13 +13,13 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "metadata.h"
-#include "segtype.h"
-#include "locking.h"
-#include "toolcontext.h"
-#include "lv_alloc.h"
-#include "activate.h"
+#include "lib/misc/lib.h"
+#include "lib/metadata/metadata.h"
+#include "lib/metadata/segtype.h"
+#include "lib/locking/locking.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/metadata/lv_alloc.h"
+#include "lib/activate/activate.h"
 
 #define SNAPSHOT_MIN_CHUNKS	3       /* Minimum number of chunks in snapshot */
 
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 3dfbcc1..c5d2ffd 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -12,14 +12,14 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "activate.h"
-#include "locking.h"
-#include "memlock.h"
-#include "metadata.h"
-#include "segtype.h"
-#include "defaults.h"
-#include "display.h"
+#include "lib/misc/lib.h"
+#include "lib/activate/activate.h"
+#include "lib/locking/locking.h"
+#include "lib/mm/memlock.h"
+#include "lib/metadata/metadata.h"
+#include "lib/metadata/segtype.h"
+#include "lib/config/defaults.h"
+#include "lib/display/display.h"
 
 /* TODO: drop unused no_update */
 int attach_pool_message(struct lv_segment *pool_seg, dm_thin_message_t type,
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index b8b1501..71f6e14 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -13,14 +13,14 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "metadata.h"
-#include "display.h"
-#include "activate.h"
-#include "toolcontext.h"
-#include "lvmcache.h"
-#include "archiver.h"
-#include "lvmetad.h"
+#include "lib/misc/lib.h"
+#include "lib/metadata/metadata.h"
+#include "lib/display/display.h"
+#include "lib/activate/activate.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/cache/lvmcache.h"
+#include "lib/format_text/archiver.h"
+#include "lib/cache/lvmetad.h"
 
 struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 			      const char *vg_name)
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 7ecfafe..b37c01d 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -15,8 +15,8 @@
 #ifndef _LVM_VG_H
 #define _LVM_VG_H
 
-#include "uuid.h"
-#include "libdevmapper.h"
+#include "lib/uuid/uuid.h"
+#include "libdm/libdevmapper.h"
 
 struct cmd_context;
 struct format_instance;
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 7c5c0a6..6746b1a 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -13,18 +13,18 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "toolcontext.h"
-#include "metadata.h"
-#include "segtype.h"
-#include "display.h"
-#include "text_export.h"
-#include "text_import.h"
-#include "config.h"
-#include "lvm-string.h"
-#include "targets.h"
-#include "activate.h"
-#include "str_list.h"
+#include "lib/misc/lib.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/metadata/metadata.h"
+#include "lib/metadata/segtype.h"
+#include "lib/display/display.h"
+#include "lib/format_text/text_export.h"
+#include "lib/format_text/text_import.h"
+#include "lib/config/config.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/activate/targets.h"
+#include "lib/activate/activate.h"
+#include "lib/datastruct/str_list.h"
 
 #include <sys/utsname.h>
 
diff --git a/lib/misc/crc.c b/lib/misc/crc.c
index aacd82d..8dc107f 100644
--- a/lib/misc/crc.c
+++ b/lib/misc/crc.c
@@ -13,10 +13,10 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
+#include "lib/misc/lib.h"
 
-#include "crc.h"
-#include "xlate.h"
+#include "lib/misc/crc.h"
+#include "lib/mm/xlate.h"
 
 /* Calculate an endian-independent CRC of supplied buffer */
 #ifndef DEBUG_CRC32
diff --git a/lib/misc/crc_gen.c b/lib/misc/crc_gen.c
index 1ed0186..56f2d25 100644
--- a/lib/misc/crc_gen.c
+++ b/lib/misc/crc_gen.c
@@ -15,7 +15,7 @@
 /*
  * Helper program to generate table included in crc.c.
  */
-#include "lib.h"
+#include "lib/misc/lib.h"
 
 int main(int argc, char **argv)
 {
diff --git a/lib/misc/lib.h b/lib/misc/lib.h
index d7fa5c7..13c7110 100644
--- a/lib/misc/lib.h
+++ b/lib/misc/lib.h
@@ -78,17 +78,17 @@
 #endif
 
 
-#include "intl.h"
-#include "libdevmapper.h"
-#include "util.h"
+#include "lib/misc/intl.h"
+#include "libdm/libdevmapper.h"
+#include "lib/misc/util.h"
 
 #ifdef DM
-#  include "dm-logging.h"
+#  include "libdm/misc/dm-logging.h"
 #else
-#  include "lvm-logging.h"
-#  include "lvm-globals.h"
-#  include "lvm-wrappers.h"
-#  include "lvm-maths.h"
+#  include "lib/log/lvm-logging.h"
+#  include "lib/misc/lvm-globals.h"
+#  include "lib/misc/lvm-wrappers.h"
+#  include "lib/misc/lvm-maths.h"
 #endif
 
 #include <unistd.h>
diff --git a/lib/misc/lvm-exec.c b/lib/misc/lvm-exec.c
index 190d426..aea2abb 100644
--- a/lib/misc/lvm-exec.c
+++ b/lib/misc/lvm-exec.c
@@ -13,11 +13,11 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "device.h"
-#include "locking.h"
-#include "lvm-exec.h"
-#include "toolcontext.h"
+#include "lib/misc/lib.h"
+#include "lib/device/device.h"
+#include "lib/locking/locking.h"
+#include "lib/misc/lvm-exec.h"
+#include "lib/commands/toolcontext.h"
 
 #include <unistd.h>
 #include <sys/wait.h>
diff --git a/lib/misc/lvm-exec.h b/lib/misc/lvm-exec.h
index 43c5a42..8db9a35 100644
--- a/lib/misc/lvm-exec.h
+++ b/lib/misc/lvm-exec.h
@@ -16,7 +16,7 @@
 #ifndef _LVM_EXEC_H
 #define _LVM_EXEC_H
 
-#include "lib.h"
+#include "lib/misc/lib.h"
 
 struct cmd_context;
 
diff --git a/lib/misc/lvm-file.c b/lib/misc/lvm-file.c
index 36caaa7..5c23b0a 100644
--- a/lib/misc/lvm-file.c
+++ b/lib/misc/lvm-file.c
@@ -13,8 +13,8 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "lvm-file.h"
+#include "lib/misc/lib.h"
+#include "lib/misc/lvm-file.h"
 
 #include <unistd.h>
 #include <sys/stat.h>
diff --git a/lib/misc/lvm-flock.c b/lib/misc/lvm-flock.c
index 4196313..00d74de 100644
--- a/lib/misc/lvm-flock.c
+++ b/lib/misc/lvm-flock.c
@@ -13,11 +13,11 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "config.h"
-#include "lvm-flock.h"
-#include "lvm-signal.h"
-#include "locking.h"
+#include "lib/misc/lib.h"
+#include "lib/config/config.h"
+#include "lib/misc/lvm-flock.h"
+#include "lib/misc/lvm-signal.h"
+#include "lib/locking/locking.h"
 
 #include <sys/file.h>
 #include <fcntl.h>
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 9941489..b76ddb9 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -13,11 +13,11 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "device.h"
-#include "lvm-string.h"
-#include "defaults.h"
-#include "metadata-exported.h"
+#include "lib/misc/lib.h"
+#include "lib/device/device.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/config/defaults.h"
+#include "lib/metadata/metadata-exported.h"
 
 #include <stdarg.h>
 
diff --git a/lib/misc/lvm-maths.c b/lib/misc/lvm-maths.c
index df3aa0a..ede073b 100644
--- a/lib/misc/lvm-maths.c
+++ b/lib/misc/lvm-maths.c
@@ -12,7 +12,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
+#include "lib/misc/lib.h"
 
 /* Greatest common divisor */
 unsigned long gcd(unsigned long n1, unsigned long n2)
diff --git a/lib/misc/lvm-percent.c b/lib/misc/lvm-percent.c
index 30238f3..f76ae81 100644
--- a/lib/misc/lvm-percent.c
+++ b/lib/misc/lvm-percent.c
@@ -12,8 +12,8 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "lvm-percent.h"
+#include "lib/misc/lib.h"
+#include "lib/misc/lvm-percent.h"
 
 uint32_t percent_of_extents(uint32_t percents, uint32_t count, int roundup)
 {
diff --git a/lib/misc/lvm-signal.c b/lib/misc/lvm-signal.c
index 8a4ead4..b90a2db 100644
--- a/lib/misc/lvm-signal.c
+++ b/lib/misc/lvm-signal.c
@@ -13,9 +13,9 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "lvm-signal.h"
-#include "memlock.h"
+#include "lib/misc/lib.h"
+#include "lib/misc/lvm-signal.h"
+#include "lib/mm/memlock.h"
 
 #include <signal.h>
 
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index a2098fd..1e9af66 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -13,10 +13,10 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "lvm-string.h"
-#include "metadata-exported.h"
-#include "display.h"
+#include "lib/misc/lib.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/metadata/metadata-exported.h"
+#include "lib/display/display.h"
 
 #include <ctype.h>
 #include <stdarg.h>
diff --git a/lib/misc/lvm-wrappers.c b/lib/misc/lvm-wrappers.c
index e2b14aa..c36e2cf 100644
--- a/lib/misc/lvm-wrappers.c
+++ b/lib/misc/lvm-wrappers.c
@@ -12,7 +12,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
+#include "lib/misc/lib.h"
 
 #include <unistd.h>
 #include <fcntl.h>
diff --git a/lib/misc/sharedlib.c b/lib/misc/sharedlib.c
index 2532f79..d594470 100644
--- a/lib/misc/sharedlib.c
+++ b/lib/misc/sharedlib.c
@@ -13,10 +13,10 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "config.h"
-#include "sharedlib.h"
-#include "toolcontext.h"
+#include "lib/misc/lib.h"
+#include "lib/config/config.h"
+#include "lib/misc/sharedlib.h"
+#include "lib/commands/toolcontext.h"
 
 #include <limits.h>
 #include <sys/stat.h>
diff --git a/lib/misc/sharedlib.h b/lib/misc/sharedlib.h
index 825482d..5ff2dcb 100644
--- a/lib/misc/sharedlib.h
+++ b/lib/misc/sharedlib.h
@@ -16,7 +16,7 @@
 #ifndef _LVM_SHAREDLIB_H
 #define _LVM_SHAREDLIB_H
 
-#include "config.h"
+#include "lib/config/config.h"
 #include <dlfcn.h>
 
 void get_shared_library_path(struct cmd_context *cmd, const char *libname,
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index b15058e..571caab 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -13,11 +13,11 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "memlock.h"
-#include "defaults.h"
-#include "config.h"
-#include "toolcontext.h"
+#include "lib/misc/lib.h"
+#include "lib/mm/memlock.h"
+#include "lib/config/defaults.h"
+#include "lib/config/config.h"
+#include "lib/commands/toolcontext.h"
 
 #include <limits.h>
 #include <fcntl.h>
diff --git a/lib/notify/lvmnotify.c b/lib/notify/lvmnotify.c
index 1daee1e..e24b0ac 100644
--- a/lib/notify/lvmnotify.c
+++ b/lib/notify/lvmnotify.c
@@ -8,9 +8,9 @@
  * of the GNU Lesser General Public License v.2.1.
  */
 
-#include "lib.h"
-#include "toolcontext.h"
-#include "lvmnotify.h"
+#include "lib/misc/lib.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/notify/lvmnotify.h"
 
 #define LVM_DBUS_DESTINATION "com.redhat.lvmdbus1"
 #define LVM_DBUS_PATH        "/com/redhat/lvmdbus1/Manager"
diff --git a/lib/properties/prop_common.c b/lib/properties/prop_common.c
index 3fd9697..f8b63d6 100644
--- a/lib/properties/prop_common.c
+++ b/lib/properties/prop_common.c
@@ -12,8 +12,8 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "prop_common.h"
+#include "lib/misc/lib.h"
+#include "lib/properties/prop_common.h"
 
 int prop_not_implemented_get(const void *obj, struct lvm_property_type *prop)
 {
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index e926ae1..2efaf19 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -12,17 +12,17 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "segtype.h"
-#include "display.h"
-#include "text_export.h"
-#include "config.h"
-#include "str_list.h"
-#include "targets.h"
-#include "lvm-string.h"
-#include "activate.h"
-#include "metadata.h"
-#include "lv_alloc.h"
+#include "lib/misc/lib.h"
+#include "lib/metadata/segtype.h"
+#include "lib/display/display.h"
+#include "lib/format_text/text_export.h"
+#include "lib/config/config.h"
+#include "lib/datastruct/str_list.h"
+#include "lib/activate/targets.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/activate/activate.h"
+#include "lib/metadata/metadata.h"
+#include "lib/metadata/lv_alloc.h"
 
 static int _raid_target_present(struct cmd_context *cmd,
 				const struct lv_segment *seg __attribute__((unused)),
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 8e86b7a..d944750 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -12,10 +12,10 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "properties.h"
-#include "activate.h"
-#include "metadata.h"
+#include "lib/misc/lib.h"
+#include "lib/report/properties.h"
+#include "lib/activate/activate.h"
+#include "lib/metadata/metadata.h"
 
 
 #define GET_VG_NUM_PROPERTY_FN(NAME, VALUE) \
diff --git a/lib/report/properties.h b/lib/report/properties.h
index 6b9ab40..f52705e 100644
--- a/lib/report/properties.h
+++ b/lib/report/properties.h
@@ -14,10 +14,10 @@
 #ifndef _LVM_PROPERTIES_H
 #define _LVM_PROPERTIES_H
 
-#include "libdevmapper.h"
-#include "metadata.h"
-#include "report.h"
-#include "prop_common.h"
+#include "libdm/libdevmapper.h"
+#include "lib/metadata/metadata.h"
+#include "lib/report/report.h"
+#include "lib/properties/prop_common.h"
 
 int lvseg_get_property(const struct lv_segment *lvseg,
 		       struct lvm_property_type *prop);
diff --git a/lib/report/report.c b/lib/report/report.c
index 01ab627..ad54ea7 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -13,17 +13,17 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "metadata.h"
-#include "report.h"
-#include "toolcontext.h"
-#include "lvm-string.h"
-#include "display.h"
-#include "activate.h"
-#include "segtype.h"
-#include "lvmcache.h"
-#include "device-types.h"
-#include "str_list.h"
+#include "lib/misc/lib.h"
+#include "lib/metadata/metadata.h"
+#include "lib/report/report.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/display/display.h"
+#include "lib/activate/activate.h"
+#include "lib/metadata/segtype.h"
+#include "lib/cache/lvmcache.h"
+#include "lib/device/device-types.h"
+#include "lib/datastruct/str_list.h"
 
 #include <stddef.h> /* offsetof() */
 #include <float.h> /* DBL_MAX */
diff --git a/lib/report/report.h b/lib/report/report.h
index c787f56..380538a 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -16,9 +16,9 @@
 #ifndef _LVM_REPORT_H
 #define _LVM_REPORT_H
 
-#include "metadata-exported.h"
-#include "label.h"
-#include "activate.h"
+#include "lib/metadata/metadata-exported.h"
+#include "lib/label/label.h"
+#include "lib/activate/activate.h"
 
 typedef enum {
 	CMDLOG		= 1,
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index 5fd39e9..4d9cd7e 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -13,13 +13,13 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "metadata.h"
-#include "segtype.h"
-#include "text_export.h"
-#include "config.h"
-#include "activate.h"
-#include "str_list.h"
+#include "lib/misc/lib.h"
+#include "lib/metadata/metadata.h"
+#include "lib/metadata/segtype.h"
+#include "lib/format_text/text_export.h"
+#include "lib/config/config.h"
+#include "lib/activate/activate.h"
+#include "lib/datastruct/str_list.h"
 
 #define SEG_LOG_ERROR(t, p...) \
 	log_error(t " segment %s of logical volume %s.", ## p, \
diff --git a/lib/striped/striped.c b/lib/striped/striped.c
index bca4c2c..9c8408c 100644
--- a/lib/striped/striped.c
+++ b/lib/striped/striped.c
@@ -13,19 +13,19 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "toolcontext.h"
-#include "segtype.h"
-#include "display.h"
-#include "text_export.h"
-#include "text_import.h"
-#include "config.h"
-#include "str_list.h"
-#include "targets.h"
-#include "lvm-string.h"
-#include "activate.h"
-#include "pv_alloc.h"
-#include "metadata.h"
+#include "lib/misc/lib.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/metadata/segtype.h"
+#include "lib/display/display.h"
+#include "lib/format_text/text_export.h"
+#include "lib/format_text/text_import.h"
+#include "lib/config/config.h"
+#include "lib/datastruct/str_list.h"
+#include "lib/activate/targets.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/activate/activate.h"
+#include "lib/metadata/pv_alloc.h"
+#include "lib/metadata/metadata.h"
 
 static const char *_striped_name(const struct lv_segment *seg)
 {
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index b6eb3aa..3c62008 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -12,14 +12,14 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "display.h"
-#include "metadata.h"
-#include "segtype.h"
-#include "text_export.h"
-#include "config.h"
-#include "activate.h"
-#include "str_list.h"
+#include "lib/misc/lib.h"
+#include "lib/display/display.h"
+#include "lib/metadata/metadata.h"
+#include "lib/metadata/segtype.h"
+#include "lib/format_text/text_export.h"
+#include "lib/config/config.h"
+#include "lib/activate/activate.h"
+#include "lib/datastruct/str_list.h"
 
 /* Dm kernel module name for thin provisiong */
 static const char _thin_pool_module[] = "thin-pool";
diff --git a/lib/unknown/unknown.c b/lib/unknown/unknown.c
index 7728545..7c2a54c 100644
--- a/lib/unknown/unknown.c
+++ b/lib/unknown/unknown.c
@@ -12,11 +12,11 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "toolcontext.h"
-#include "segtype.h"
-#include "text_export.h"
-#include "config.h"
+#include "lib/misc/lib.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/metadata/segtype.h"
+#include "lib/format_text/text_export.h"
+#include "lib/config/config.h"
 
 static int _unknown_text_import(struct lv_segment *seg, const struct dm_config_node *sn,
 				struct dm_hash_table *pv_hash)
diff --git a/lib/uuid/uuid.c b/lib/uuid/uuid.c
index 1833f2c..be4cbc3 100644
--- a/lib/uuid/uuid.c
+++ b/lib/uuid/uuid.c
@@ -13,9 +13,9 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "uuid.h"
-#include "lvm-wrappers.h"
+#include "lib/misc/lib.h"
+#include "lib/uuid/uuid.h"
+#include "lib/misc/lvm-wrappers.h"
 
 #include <assert.h>
 #include <sys/stat.h>
diff --git a/lib/zero/zero.c b/lib/zero/zero.c
index fc021cd..f1e4831 100644
--- a/lib/zero/zero.c
+++ b/lib/zero/zero.c
@@ -12,10 +12,10 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "segtype.h"
-#include "str_list.h"
-#include "activate.h"
+#include "lib/misc/lib.h"
+#include "lib/metadata/segtype.h"
+#include "lib/datastruct/str_list.h"
+#include "lib/activate/activate.h"
 
 static int _zero_merge_segments(struct lv_segment *seg1, struct lv_segment *seg2)
 {
diff --git a/libdaemon/client/config-util.c b/libdaemon/client/config-util.c
index 32f36f6..12baa99 100644
--- a/libdaemon/client/config-util.c
+++ b/libdaemon/client/config-util.c
@@ -14,10 +14,10 @@
 
 #define _REENTRANT
 
-#include "tool.h"
+#include "tools/tool.h"
 
-#include "daemon-io.h"
-#include "dm-logging.h"
+#include "libdaemon/client/daemon-io.h"
+#include "libdm/misc/dm-logging.h"
 
 #include <math.h>  /* fabs() */
 #include <float.h> /* DBL_EPSILON */
diff --git a/libdaemon/client/daemon-client.c b/libdaemon/client/daemon-client.c
index 5ce1fc0..b5dfbf1 100644
--- a/libdaemon/client/daemon-client.c
+++ b/libdaemon/client/daemon-client.c
@@ -14,11 +14,11 @@
 
 #define _REENTRANT
 
-#include "tool.h"
+#include "tools/tool.h"
 
-#include "daemon-io.h"
-#include "daemon-client.h"
-#include "dm-logging.h"
+#include "libdaemon/client/daemon-io.h"
+#include "libdaemon/client/daemon-client.h"
+#include "libdm/misc/dm-logging.h"
 
 #include <sys/un.h>
 #include <sys/socket.h>
diff --git a/libdaemon/client/daemon-client.h b/libdaemon/client/daemon-client.h
index 5235bea..e1671a7 100644
--- a/libdaemon/client/daemon-client.h
+++ b/libdaemon/client/daemon-client.h
@@ -15,7 +15,7 @@
 #ifndef _LVM_DAEMON_CLIENT_H
 #define _LVM_DAEMON_CLIENT_H
 
-#include "config-util.h"
+#include "libdaemon/client/config-util.h"
 
 typedef struct {
 	int socket_fd; /* the fd we use to talk to the daemon */
diff --git a/libdaemon/client/daemon-io.c b/libdaemon/client/daemon-io.c
index 5419d40..bd24cdb 100644
--- a/libdaemon/client/daemon-io.c
+++ b/libdaemon/client/daemon-io.c
@@ -14,9 +14,9 @@
 
 #define _REENTRANT
 
-#include "tool.h"
+#include "tools/tool.h"
 
-#include "daemon-io.h"
+#include "libdaemon/client/daemon-io.h"
 
 #include <errno.h>
 
diff --git a/libdaemon/client/daemon-io.h b/libdaemon/client/daemon-io.h
index 013b0c8..761d468 100644
--- a/libdaemon/client/daemon-io.h
+++ b/libdaemon/client/daemon-io.h
@@ -15,7 +15,7 @@
 #ifndef _LVM_DAEMON_IO_H
 #define _LVM_DAEMON_IO_H
 
-#include "config-util.h"
+#include "libdaemon/client/config-util.h"
 
 /* TODO function names */
 
diff --git a/libdaemon/server/daemon-log.c b/libdaemon/server/daemon-log.c
index 3be5573..8c2a208 100644
--- a/libdaemon/server/daemon-log.c
+++ b/libdaemon/server/daemon-log.c
@@ -12,7 +12,7 @@
 
 #define _REENTRANT
 
-#include "tool.h"
+#include "tools/tool.h"
 
 #include "daemon-server.h"
 #include "daemon-log.h"
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 3b19883..4acb00e 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -12,9 +12,9 @@
 
 #define _REENTRANT
 
-#include "tool.h"
+#include "tools/tool.h"
 
-#include "daemon-io.h"
+#include "libdaemon/client/daemon-io.h"
 #include "daemon-server.h"
 #include "daemon-log.h"
 
diff --git a/libdaemon/server/daemon-server.h b/libdaemon/server/daemon-server.h
index 2b9ceac..f8c0ca6 100644
--- a/libdaemon/server/daemon-server.h
+++ b/libdaemon/server/daemon-server.h
@@ -15,7 +15,7 @@
 #ifndef _LVM_DAEMON_SERVER_H
 #define _LVM_DAEMON_SERVER_H
 
-#include "daemon-client.h"
+#include "libdaemon/client/daemon-client.h"
 
 typedef struct {
 	int socket_fd; /* the fd we use to talk to the client */
diff --git a/libdm/datastruct/bitset.c b/libdm/datastruct/bitset.c
index b0826e1..06bd31a 100644
--- a/libdm/datastruct/bitset.c
+++ b/libdm/datastruct/bitset.c
@@ -13,7 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "dmlib.h"
+#include "libdm/misc/dmlib.h"
 
 #include <ctype.h>
 
diff --git a/libdm/datastruct/hash.c b/libdm/datastruct/hash.c
index fb153ce..4c94003 100644
--- a/libdm/datastruct/hash.c
+++ b/libdm/datastruct/hash.c
@@ -13,7 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "dmlib.h"
+#include "libdm/misc/dmlib.h"
 
 struct dm_hash_node {
 	struct dm_hash_node *next;
diff --git a/libdm/datastruct/list.c b/libdm/datastruct/list.c
index bdd3b19..d80cb9a 100644
--- a/libdm/datastruct/list.c
+++ b/libdm/datastruct/list.c
@@ -13,7 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
+#include "lib/misc/lib.h"
 #include <assert.h>
 
 /*
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 769b69c..e775da7 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -13,7 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "dmlib.h"
+#include "libdm/misc/dmlib.h"
 #include "libdm-targets.h"
 #include "libdm-common.h"
 
@@ -25,7 +25,7 @@
 #include <limits.h>
 
 #ifdef __linux__
-#  include "kdev_t.h"
+#  include "libdm/misc/kdev_t.h"
 #  include <linux/limits.h>
 #else
 #  define MAJOR(x) major((x))
@@ -33,7 +33,7 @@
 #  define MKDEV(x,y) makedev((x),(y))
 #endif
 
-#include "dm-ioctl.h"
+#include "libdm/misc/dm-ioctl.h"
 
 /*
  * Ensure build compatibility.  
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 094e618..7c740d8 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -13,11 +13,11 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "dmlib.h"
+#include "libdm/misc/dmlib.h"
 #include "libdm-targets.h"
 #include "libdm-common.h"
-#include "kdev_t.h"
-#include "dm-ioctl.h"
+#include "libdm/misc/kdev_t.h"
+#include "libdm/misc/dm-ioctl.h"
 
 #include <stdarg.h>
 #include <sys/param.h>
diff --git a/libdm/libdm-common.h b/libdm/libdm-common.h
index 010d876..30adac0 100644
--- a/libdm/libdm-common.h
+++ b/libdm/libdm-common.h
@@ -16,7 +16,7 @@
 #ifndef LIB_DMCOMMON_H
 #define LIB_DMCOMMON_H
 
-#include "libdevmapper.h"
+#include "libdm/libdevmapper.h"
 
 #define DM_DEFAULT_NAME_MANGLING_MODE_ENV_VAR_NAME "DM_DEFAULT_NAME_MANGLING_MODE"
 
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index 3f0d251..3666fc9 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -13,7 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "dmlib.h"
+#include "libdm/misc/dmlib.h"
 
 #include <sys/stat.h>
 #include <sys/mman.h>
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index ab05456..3e602e2 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -12,11 +12,11 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "dmlib.h"
+#include "libdm/misc/dmlib.h"
 #include "libdm-targets.h"
 #include "libdm-common.h"
-#include "kdev_t.h"
-#include "dm-ioctl.h"
+#include "libdm/misc/kdev_t.h"
+#include "libdm/misc/dm-ioctl.h"
 
 #include <stdarg.h>
 #include <sys/param.h>
diff --git a/libdm/libdm-file.c b/libdm/libdm-file.c
index e7416f1..fc93dda 100644
--- a/libdm/libdm-file.c
+++ b/libdm/libdm-file.c
@@ -13,7 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "dmlib.h"
+#include "libdm/misc/dmlib.h"
 
 #include <sys/file.h>
 #include <fcntl.h>
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 6d140af..01255b4 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -13,7 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "dmlib.h"
+#include "libdm/misc/dmlib.h"
 
 #include <ctype.h>
 #include <math.h>  /* fabs() */
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 94ad380..e9bfa9d 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -15,8 +15,8 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "dmlib.h"
-#include "kdev_t.h"
+#include "libdm/misc/dmlib.h"
+#include "libdm/misc/kdev_t.h"
 
 #include "math.h" /* log10() */
 
diff --git a/libdm/libdm-string.c b/libdm/libdm-string.c
index cf9690c..1542229 100644
--- a/libdm/libdm-string.c
+++ b/libdm/libdm-string.c
@@ -12,7 +12,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "dmlib.h"
+#include "libdm/misc/dmlib.h"
 
 #include <ctype.h>
 #include <stdarg.h>
diff --git a/libdm/libdm-targets.c b/libdm/libdm-targets.c
index 8766789..f2bac51 100644
--- a/libdm/libdm-targets.c
+++ b/libdm/libdm-targets.c
@@ -12,7 +12,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "dmlib.h"
+#include "libdm/misc/dmlib.h"
 #include "libdm-common.h"
 
 int dm_get_status_snapshot(struct dm_pool *mem, const char *params,
diff --git a/libdm/libdm-timestamp.c b/libdm/libdm-timestamp.c
index 6164885..04b1006 100644
--- a/libdm/libdm-timestamp.c
+++ b/libdm/libdm-timestamp.c
@@ -18,7 +18,7 @@
  * the results of these routines should stay in-core.  
  */
 
-#include "dmlib.h"
+#include "libdm/misc/dmlib.h"
 
 #include <stdlib.h>
 
diff --git a/libdm/misc/dm-log-userspace.h b/libdm/misc/dm-log-userspace.h
index a770ae6..b243194 100644
--- a/libdm/misc/dm-log-userspace.h
+++ b/libdm/misc/dm-log-userspace.h
@@ -9,7 +9,7 @@
 
 #include <inttypes.h>
 
-#include "dm-ioctl.h" /* For DM_UUID_LEN */
+#include "libdm/misc/dm-ioctl.h"
 
 /*
  * The device-mapper userspace log module consists of a kernel component and
diff --git a/libdm/misc/dm-logging.h b/libdm/misc/dm-logging.h
index 083664d..5bf16a7 100644
--- a/libdm/misc/dm-logging.h
+++ b/libdm/misc/dm-logging.h
@@ -16,7 +16,7 @@
 #ifndef _DM_LOGGING_H
 #define _DM_LOGGING_H
 
-#include "libdevmapper.h"
+#include "libdm/libdevmapper.h"
 
 extern dm_log_with_errno_fn dm_log_with_errno;
 
@@ -29,6 +29,6 @@ extern dm_log_with_errno_fn dm_log_with_errno;
 /* Debug messages may have a type instead of an errno */
 #define LOG_LINE_WITH_CLASS(l, c, x...) LOG_MESG(l, __FILE__, __LINE__, c, ## x)
 
-#include "log.h"
+#include "lib/log/log.h"
 
 #endif
diff --git a/libdm/misc/dmlib.h b/libdm/misc/dmlib.h
index 7d73657..bc14ece 100644
--- a/libdm/misc/dmlib.h
+++ b/libdm/misc/dmlib.h
@@ -21,6 +21,6 @@
 
 #define DM
 
-#include "lib.h"
+#include "lib/misc/lib.h"
 
 #endif
diff --git a/libdm/mm/dbg_malloc.c b/libdm/mm/dbg_malloc.c
index 280213b..d8799d7 100644
--- a/libdm/mm/dbg_malloc.c
+++ b/libdm/mm/dbg_malloc.c
@@ -13,7 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "dmlib.h"
+#include "libdm/misc/dmlib.h"
 
 #ifdef VALGRIND_POOL
 #include "memcheck.h"
diff --git a/libdm/mm/pool-debug.c b/libdm/mm/pool-debug.c
index c523238..170c51d 100644
--- a/libdm/mm/pool-debug.c
+++ b/libdm/mm/pool-debug.c
@@ -13,7 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "dmlib.h"
+#include "libdm/misc/dmlib.h"
 #include <assert.h>
 
 struct block {
diff --git a/libdm/mm/pool-fast.c b/libdm/mm/pool-fast.c
index 614e903..7be0788 100644
--- a/libdm/mm/pool-fast.c
+++ b/libdm/mm/pool-fast.c
@@ -17,7 +17,7 @@
 #include "memcheck.h"
 #endif
 
-#include "dmlib.h"
+#include "libdm/misc/dmlib.h"
 #include <stddef.h>	/* For musl libc */
 #include <malloc.h>
 
diff --git a/libdm/mm/pool.c b/libdm/mm/pool.c
index 1321cc7..a8fe732 100644
--- a/libdm/mm/pool.c
+++ b/libdm/mm/pool.c
@@ -13,7 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "dmlib.h"
+#include "libdm/misc/dmlib.h"
 #include <sys/mman.h>
 #include <pthread.h>
 
diff --git a/libdm/regex/matcher.c b/libdm/regex/matcher.c
index a837162..459ed2e 100644
--- a/libdm/regex/matcher.c
+++ b/libdm/regex/matcher.c
@@ -13,7 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "dmlib.h"
+#include "libdm/misc/dmlib.h"
 #include "parse_rx.h"
 #include "ttree.h"
 #include "assert.h"
diff --git a/libdm/regex/parse_rx.c b/libdm/regex/parse_rx.c
index 80e97a4..fb5233f 100644
--- a/libdm/regex/parse_rx.c
+++ b/libdm/regex/parse_rx.c
@@ -13,7 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "dmlib.h"
+#include "libdm/misc/dmlib.h"
 #include "parse_rx.h"
 
 #ifdef DEBUG
diff --git a/libdm/regex/ttree.c b/libdm/regex/ttree.c
index 0f54d04..0eb51fe 100644
--- a/libdm/regex/ttree.c
+++ b/libdm/regex/ttree.c
@@ -13,7 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "dmlib.h"
+#include "libdm/misc/dmlib.h"
 #include "ttree.h"
 
 struct node {
diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index fce994c..791c629 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -12,12 +12,12 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "toolcontext.h"
-#include "locking.h"
+#include "lib/misc/lib.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/locking/locking.h"
 #include "lvm-version.h"
-#include "metadata-exported.h"
-#include "lvm2app.h"
+#include "lib/metadata/metadata-exported.h"
+#include "liblvm/lvm2app.h"
 #include "lvm_misc.h"
 
 const char *lvm_library_get_version(void)
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index e5a35c4..48774df 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -12,15 +12,15 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "metadata-exported.h"
-#include "lvm-string.h"
-#include "defaults.h"
-#include "segtype.h"
-#include "locking.h"
-#include "activate.h"
+#include "lib/misc/lib.h"
+#include "lib/metadata/metadata-exported.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/config/defaults.h"
+#include "lib/metadata/segtype.h"
+#include "lib/locking/locking.h"
+#include "lib/activate/activate.h"
 #include "lvm_misc.h"
-#include "lvm2app.h"
+#include "liblvm/lvm2app.h"
 
 /* FIXME Improve all the log messages to include context. Which VG/LV as a minimum? */
 
diff --git a/liblvm/lvm_misc.c b/liblvm/lvm_misc.c
index 373ccde..2b24de2 100644
--- a/liblvm/lvm_misc.c
+++ b/liblvm/lvm_misc.c
@@ -12,10 +12,10 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "properties.h"
+#include "lib/misc/lib.h"
+#include "lib/report/properties.h"
 #include "lvm_misc.h"
-#include "lvm2app.h"
+#include "liblvm/lvm2app.h"
 #include "lvm_prop.h"
 
 struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list)
diff --git a/liblvm/lvm_misc.h b/liblvm/lvm_misc.h
index 0a3fd73..62f91ce 100644
--- a/liblvm/lvm_misc.h
+++ b/liblvm/lvm_misc.h
@@ -14,10 +14,10 @@
 #ifndef _LVM2APP_MISC_H
 #define _LVM2APP_MISC_H
 
-#include "libdevmapper.h"
-#include "lvm2app.h"
-#include "metadata-exported.h"
-#include "toolcontext.h"
+#include "libdm/libdevmapper.h"
+#include "liblvm/lvm2app.h"
+#include "lib/metadata/metadata-exported.h"
+#include "lib/commands/toolcontext.h"
 
 #include <sys/types.h>
 #include <sys/stat.h>
diff --git a/liblvm/lvm_prop.c b/liblvm/lvm_prop.c
index d5b1493..1997596 100644
--- a/liblvm/lvm_prop.c
+++ b/liblvm/lvm_prop.c
@@ -13,8 +13,8 @@
  */
 
 #include "lvm_prop.h"
-#include "libdevmapper.h"
-#include "metadata.h"
+#include "libdm/libdevmapper.h"
+#include "lib/metadata/metadata.h"
 
 /* lv create parameters */
 GET_LVCREATEPARAMS_NUM_PROPERTY_FN(skip_zero, lvcp->zero)
diff --git a/liblvm/lvm_prop.h b/liblvm/lvm_prop.h
index 00e7e48..5a30a76 100644
--- a/liblvm/lvm_prop.h
+++ b/liblvm/lvm_prop.h
@@ -11,7 +11,7 @@
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
-#include "prop_common.h"
+#include "lib/properties/prop_common.h"
 
 #ifndef _LIB_LVM_PROP_H
 #define _LIB_LVM_PROP_H
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 143545b..bd6ee4f 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -13,16 +13,16 @@
  */
 
 #include <stddef.h>
-#include "lib.h"
-#include "metadata-exported.h"
-#include "lvm-string.h"
-#include "str_list.h"
+#include "lib/misc/lib.h"
+#include "lib/metadata/metadata-exported.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/datastruct/str_list.h"
 #include "lvm_misc.h"
-#include "lvm2app.h"
-#include "locking.h"
-#include "toolcontext.h"
+#include "liblvm/lvm2app.h"
+#include "lib/locking/locking.h"
+#include "lib/commands/toolcontext.h"
 #include "lvm_misc.h"
-#include "lvmetad.h"
+#include "lib/cache/lvmetad.h"
 
 struct lvm_pv_create_params
 {
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 616c78f..e8354e5 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -12,17 +12,17 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib.h"
-#include "toolcontext.h"
-#include "metadata.h"
-#include "archiver.h"
-#include "locking.h"
-#include "lvmcache.h"
-#include "lvmetad.h"
+#include "lib/misc/lib.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/metadata/metadata.h"
+#include "lib/format_text/archiver.h"
+#include "lib/locking/locking.h"
+#include "lib/cache/lvmcache.h"
+#include "lib/cache/lvmetad.h"
 #include "lvm_misc.h"
-#include "lvm2app.h"
-#include "display.h"
-#include "lvmetad.h"
+#include "liblvm/lvm2app.h"
+#include "lib/display/display.h"
+#include "lib/cache/lvmetad.h"
 
 int lvm_vg_add_tag(vg_t vg, const char *tag)
 {
diff --git a/make.tmpl.in b/make.tmpl.in
index d3a80ef..7e3f4a4 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -306,12 +306,10 @@ LIB_VERSION_DM := $(shell $(AWK) -F '.' '{printf "%s.%s",$$1,$$2}' $(top_srcdir)
 
 LIB_VERSION_APP := $(shell $(AWK) -F '[(). ]' '{printf "%s.%s",$$1,$$4}' $(top_srcdir)/VERSION)
 
-INCLUDES += -I$(srcdir) -I$(top_builddir)/include
-
-INC_LNS = $(top_builddir)/include/.symlinks_created
+INCLUDES += -I$(top_srcdir) -I$(srcdir) -I$(top_builddir)/include
 
 DEPS = $(top_builddir)/make.tmpl $(top_srcdir)/VERSION \
-       $(top_builddir)/Makefile $(INC_LNS)
+       $(top_builddir)/Makefile
 
 OBJECTS = $(SOURCES:%.c=%.o) $(CXXSOURCES:%.cpp=%.o)
 POTFILES = $(SOURCES:%.c=%.pot)
@@ -509,7 +507,7 @@ $(LIB_STATIC): $(OBJECTS)
 	$(Q) $(RM) $@
 	$(Q) $(AR) rsv $@ $(OBJECTS) > /dev/null
 
-%.d: $(INC_LNS)
+%.d:
 .PRECIOUS: %.d
 	
 %.mo: %.po
diff --git a/python/liblvm.c b/python/liblvm.c
index 06120e6..ea9697a 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -23,8 +23,8 @@
 
 #include <Python.h>
 #define _BUILDING_LVM
-#include "lvm2app.h"
-#include "defaults.h"
+#include "liblvm/lvm2app.h"
+#include "lib/config/defaults.h"
 
 #if PY_MAJOR_VERSION >= 3
 #define IS_PY3K
diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index 0f7f89c..551b29a 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -21,8 +21,8 @@
 #include <sys/stat.h>
 #include <fcntl.h>
 #include <limits.h>		/* For PATH_MAX for musl libc */
-#include "lvm2app.h"
-#include "configure.h"		/* for LVM_PATH */
+#include "liblvm/lvm2app.h"
+#include "configure.h"
 
 #define KMSG_DEV_PATH		"/dev/kmsg"
 #define LVM_CONF_USE_LVMETAD	"global/use_lvmetad"
diff --git a/test/api/lvtest.c b/test/api/lvtest.c
index 081c946..9a5fc22 100644
--- a/test/api/lvtest.c
+++ b/test/api/lvtest.c
@@ -14,7 +14,7 @@
 
 #undef NDEBUG
 
-#include "lvm2app.h"
+#include "liblvm/lvm2app.h"
 #include "assert.h"
 
 #define err(args...) \
diff --git a/test/api/pe_start.c b/test/api/pe_start.c
index 5e36c45..16b4c0d 100644
--- a/test/api/pe_start.c
+++ b/test/api/pe_start.c
@@ -14,7 +14,7 @@
 
 #undef NDEBUG
 
-#include "lvm2app.h"
+#include "liblvm/lvm2app.h"
 #include "assert.h"
 
 int main(int argc, char *argv[])
diff --git a/test/api/percent.c b/test/api/percent.c
index d0d1606..afc361c 100644
--- a/test/api/percent.c
+++ b/test/api/percent.c
@@ -14,7 +14,7 @@
 
 #undef NDEBUG
 
-#include "lvm2app.h"
+#include "liblvm/lvm2app.h"
 #include "assert.h"
 
 int main(int argc, char *argv[])
diff --git a/test/api/test.c b/test/api/test.c
index a79afc1..a4d200b 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -19,7 +19,7 @@
 #include <ctype.h>
 
 #include "configure.h"
-#include "lvm2app.h"
+#include "liblvm/lvm2app.h"
 
 #ifdef READLINE_SUPPORT
 #include <readline/readline.h>
diff --git a/test/api/thin_percent.c b/test/api/thin_percent.c
index fdb48c3..7f99abf 100644
--- a/test/api/thin_percent.c
+++ b/test/api/thin_percent.c
@@ -14,7 +14,7 @@
 
 #undef NDEBUG
 
-#include "lvm2app.h"
+#include "liblvm/lvm2app.h"
 #include "assert.h"
 
 int main(int argc, char *argv[])
diff --git a/test/api/vglist.c b/test/api/vglist.c
index f9cd59c..daa21c2 100644
--- a/test/api/vglist.c
+++ b/test/api/vglist.c
@@ -17,7 +17,7 @@
 #include <inttypes.h>
 #include <assert.h>
 
-#include "lvm2app.h"
+#include "liblvm/lvm2app.h"
 
 lvm_t handle;
 vg_t vg;
diff --git a/test/api/vgtest.c b/test/api/vgtest.c
index da04dda..ffc4ee1 100644
--- a/test/api/vgtest.c
+++ b/test/api/vgtest.c
@@ -21,7 +21,7 @@
 #include <unistd.h>
 #include <inttypes.h>
 
-#include "lvm2app.h"
+#include "liblvm/lvm2app.h"
 
 lvm_t handle;
 vg_t vg;
diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
index e1c0e85..fcd121c 100644
--- a/test/unit/bcache_t.c
+++ b/test/unit/bcache_t.c
@@ -17,7 +17,7 @@
 #include <stdlib.h>
 #include <unistd.h>
 
-#include "bcache.h"
+#include "lib/device/bcache.h"
 #include "framework.h"
 #include "units.h"
 
diff --git a/test/unit/bcache_utils_t.c b/test/unit/bcache_utils_t.c
index 4f15591..2c3bb0e 100644
--- a/test/unit/bcache_utils_t.c
+++ b/test/unit/bcache_utils_t.c
@@ -22,7 +22,7 @@
 #include <fcntl.h>
 #include <unistd.h>
 
-#include "bcache.h"
+#include "lib/device/bcache.h"
 #include "framework.h"
 #include "units.h"
 
diff --git a/test/unit/bitset_t.c b/test/unit/bitset_t.c
index 106f60f..66e0d32 100644
--- a/test/unit/bitset_t.c
+++ b/test/unit/bitset_t.c
@@ -13,7 +13,7 @@
  */
 
 #include "units.h"
-#include "libdevmapper.h"
+#include "libdm/libdevmapper.h"
 
 enum {
         NR_BITS = 137
diff --git a/test/unit/config_t.c b/test/unit/config_t.c
index 5331f79..e988706 100644
--- a/test/unit/config_t.c
+++ b/test/unit/config_t.c
@@ -13,7 +13,7 @@
  */
 
 #include "units.h"
-#include "libdevmapper.h"
+#include "libdm/libdevmapper.h"
 
 static void *_mem_init(void)
 {
diff --git a/test/unit/dmlist_t.c b/test/unit/dmlist_t.c
index 82789ba..5a4951e 100644
--- a/test/unit/dmlist_t.c
+++ b/test/unit/dmlist_t.c
@@ -13,7 +13,7 @@
  */
 
 #include "units.h"
-#include "libdevmapper.h"
+#include "libdm/libdevmapper.h"
 
 static void test_dmlist_splice(void *fixture)
 {
diff --git a/test/unit/dmstatus_t.c b/test/unit/dmstatus_t.c
index ae185ca..43fb0bf 100644
--- a/test/unit/dmstatus_t.c
+++ b/test/unit/dmstatus_t.c
@@ -13,7 +13,7 @@
  */
 
 #include "units.h"
-#include "libdevmapper.h"
+#include "libdm/libdevmapper.h"
 
 static void *_mem_init(void)
 {
diff --git a/test/unit/framework.h b/test/unit/framework.h
index 5a33ca6..a90a6e2 100644
--- a/test/unit/framework.h
+++ b/test/unit/framework.h
@@ -1,7 +1,7 @@
 #ifndef TEST_UNIT_FRAMEWORK_H
 #define TEST_UNIT_FRAMEWORK_H
 
-#include "libdevmapper.h"
+#include "libdm/libdevmapper.h"
 
 #include <stdbool.h>
 #include <stdint.h>
diff --git a/test/unit/io_engine_t.c b/test/unit/io_engine_t.c
index 01f659e..7eded30 100644
--- a/test/unit/io_engine_t.c
+++ b/test/unit/io_engine_t.c
@@ -22,7 +22,7 @@
 #include <fcntl.h>
 #include <unistd.h>
 
-#include "bcache.h"
+#include "lib/device/bcache.h"
 #include "framework.h"
 #include "units.h"
 
diff --git a/test/unit/matcher_t.c b/test/unit/matcher_t.c
index 31109d2..8405a34 100644
--- a/test/unit/matcher_t.c
+++ b/test/unit/matcher_t.c
@@ -14,7 +14,7 @@
  */
 
 #include "units.h"
-#include "libdevmapper.h"
+#include "libdm/libdevmapper.h"
 
 #include "matcher_data.h"
 
diff --git a/test/unit/percent_t.c b/test/unit/percent_t.c
index 84dd3bd..fc168d4 100644
--- a/test/unit/percent_t.c
+++ b/test/unit/percent_t.c
@@ -13,7 +13,7 @@
  */
 
 #include "units.h"
-#include "libdevmapper.h"
+#include "libdm/libdevmapper.h"
 
 #include <stdio.h>
 #include <string.h>
diff --git a/test/unit/string_t.c b/test/unit/string_t.c
index 2af0f37..74886f0 100644
--- a/test/unit/string_t.c
+++ b/test/unit/string_t.c
@@ -13,7 +13,7 @@
  */
 
 #include "units.h"
-#include "libdevmapper.h"
+#include "libdm/libdevmapper.h"
 
 #include <stdio.h>
 #include <string.h>
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 95a15dd..d3080bb 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -15,9 +15,9 @@
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
-#include "tool.h"
+#include "tools/tool.h"
 
-#include "dm-logging.h"
+#include "libdm/misc/dm-logging.h"
 
 #include <ctype.h>
 #include <dirent.h>
@@ -79,7 +79,7 @@ extern char *optarg;
 #endif
 
 #ifdef __linux__
-#  include "kdev_t.h"
+#  include "libdm/misc/kdev_t.h"
 #else
 #  define MAJOR(x) major((x))
 #  define MINOR(x) minor((x))
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 0aac5ac..0f53d8a 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -15,7 +15,7 @@
 
 #include "tools.h"
 
-#include "memlock.h"
+#include "lib/mm/memlock.h"
 
 /*
  * Passed back from callee to request caller to
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 72f840a..c44f3aa 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -14,8 +14,8 @@
 
 #include "tools.h"
 
-#include "polldaemon.h"
-#include "lv_alloc.h"
+#include "lib/lvmpolld/polldaemon.h"
+#include "lib/metadata/lv_alloc.h"
 #include "lvconvert_poll.h"
 
 #define MAX_PDATA_ARGS	10	/* Max number of accepted args for d-m-p-d tools */
diff --git a/tools/lvconvert_poll.h b/tools/lvconvert_poll.h
index 7fdcb14..dcbc16b 100644
--- a/tools/lvconvert_poll.h
+++ b/tools/lvconvert_poll.h
@@ -15,7 +15,7 @@
 #ifndef _LVM_LVCONVERT_H
 #define _LVM_LVCONVERT_H
 
-#include "polldaemon.h"
+#include "lib/lvmpolld/polldaemon.h"
 
 struct cmd_context;
 struct logical_volume;
diff --git a/tools/lvm2cmd-static.c b/tools/lvm2cmd-static.c
index 4fb109c..2b5f300 100644
--- a/tools/lvm2cmd-static.c
+++ b/tools/lvm2cmd-static.c
@@ -13,7 +13,7 @@
  */
 
 #include "lvm2cmdline.h"
-#include "lvm2cmd.h"
+#include "tools/lvm2cmd.h"
 
 void *lvm2_init(void)
 {
diff --git a/tools/lvm2cmd.c b/tools/lvm2cmd.c
index 235540c..54090ca 100644
--- a/tools/lvm2cmd.c
+++ b/tools/lvm2cmd.c
@@ -13,7 +13,7 @@
  */
 
 #include "lvm2cmdline.h"
-#include "lvm2cmd.h"
+#include "tools/lvm2cmd.h"
 
 void *lvm2_init(void)
 {
diff --git a/tools/lvmcmdlib.c b/tools/lvmcmdlib.c
index 5944576..9f94b5c 100644
--- a/tools/lvmcmdlib.c
+++ b/tools/lvmcmdlib.c
@@ -16,10 +16,10 @@
 #include "tools.h"
 
 #include "lvm2cmdline.h"
-#include "label.h"
-#include "memlock.h"
+#include "lib/label/label.h"
+#include "lib/mm/memlock.h"
 
-#include "lvm2cmd.h"
+#include "tools/lvm2cmd.h"
 
 #include <signal.h>
 #include <sys/stat.h>
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 0dd24ec..be2a31b 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -16,13 +16,13 @@
 #include "tools.h"
 
 #include "lvm2cmdline.h"
-#include "label.h"
+#include "lib/label/label.h"
 #include "lvm-version.h"
-#include "lvmlockd.h"
-#include "lvmetad-client.h"
+#include "lib/locking/lvmlockd.h"
+#include "daemons/lvmetad/lvmetad-client.h"
 
 #include "stub.h"
-#include "last-path-component.h"
+#include "lib/misc/last-path-component.h"
 
 #include <signal.h>
 #include <sys/stat.h>
diff --git a/tools/lvpoll.c b/tools/lvpoll.c
index 8b4580f..a4a698b 100644
--- a/tools/lvpoll.c
+++ b/tools/lvpoll.c
@@ -14,10 +14,10 @@
 
 #include "tools.h"
 
-#include "polldaemon.h"
+#include "lib/lvmpolld/polldaemon.h"
 #include "pvmove_poll.h"
 #include "lvconvert_poll.h"
-#include "polling_ops.h"
+#include "daemons/lvmpolld/polling_ops.h"
 
 static struct poll_functions _pvmove_fns = {
 	.poll_progress = poll_mirror_progress,
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 5b5f57f..f2578ad 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -15,9 +15,9 @@
 
 #include "tools.h"
 
-#include "polldaemon.h"
+#include "lib/lvmpolld/polldaemon.h"
 #include "lvm2cmdline.h"
-#include "lvmpolld-client.h"
+#include "lib/lvmpolld/lvmpolld-client.h"
 
 #include <time.h>
 
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 754bd58..2f7bf60 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -15,10 +15,10 @@
 
 #include "tools.h"
 
-#include "polldaemon.h"
-#include "display.h"
+#include "lib/lvmpolld/polldaemon.h"
+#include "lib/display/display.h"
 #include "pvmove_poll.h"
-#include "lvmpolld-client.h"
+#include "lib/lvmpolld/lvmpolld-client.h"
 
 #define PVMOVE_FIRST_TIME   0x00000001      /* Called for first time */
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 8493eaa..e31c7f9 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -15,8 +15,8 @@
 
 #include "tools.h"
 
-#include "lvmetad.h"
-#include "lvmcache.h"
+#include "lib/cache/lvmetad.h"
+#include "lib/cache/lvmcache.h"
 
 struct pvscan_params {
 	int new_pvs_found;
diff --git a/tools/reporter.c b/tools/reporter.c
index 98e3d12..7f5ad56 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -15,7 +15,7 @@
 
 #include "tools.h"
 
-#include "report.h"
+#include "lib/report/report.h"
 
 typedef enum {
 	REPORT_IDX_NULL = -1,
diff --git a/tools/tool.h b/tools/tool.h
index a2c8572..656234c 100644
--- a/tools/tool.h
+++ b/tools/tool.h
@@ -24,7 +24,7 @@
 
 #include <unistd.h>
 
-#include "libdevmapper.h"
-#include "util.h"
+#include "libdm/libdevmapper.h"
+#include "lib/misc/util.h"
 
 #endif	/* _LVM_TOOL_H */
diff --git a/tools/toollib.c b/tools/toollib.c
index e633cdd..464dfff 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -14,7 +14,7 @@
  */
 
 #include "tools.h"
-#include "format-text.h"
+#include "lib/format_text/format-text.h"
 
 #include <sys/stat.h>
 #include <signal.h>
diff --git a/tools/toollib.h b/tools/toollib.h
index 0c9404c..9102f55 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -16,8 +16,8 @@
 #ifndef _LVM_TOOLLIB_H
 #define _LVM_TOOLLIB_H
 
-#include "metadata-exported.h"
-#include "report.h"
+#include "lib/metadata/metadata-exported.h"
+#include "lib/report/report.h"
 
 int become_daemon(struct cmd_context *cmd, int skip_lvm);
 
diff --git a/tools/tools.h b/tools/tools.h
index 5fe3ba8..508da84 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -16,33 +16,33 @@
 #ifndef _LVM_TOOLS_H
 #define _LVM_TOOLS_H
 
-#include "tool.h"
+#include "tools/tool.h"
 
-#include "lvm-logging.h"
+#include "lib/log/lvm-logging.h"
 
-#include "activate.h"
-#include "archiver.h"
-#include "lvmcache.h"
-#include "lvmetad.h"
-#include "lvmlockd.h"
+#include "lib/activate/activate.h"
+#include "lib/format_text/archiver.h"
+#include "lib/cache/lvmcache.h"
+#include "lib/cache/lvmetad.h"
+#include "lib/locking/lvmlockd.h"
 #include "lvm-version.h"
-#include "config.h"
-#include "defaults.h"
-#include "dev-cache.h"
-#include "device.h"
-#include "display.h"
+#include "lib/config/config.h"
+#include "lib/config/defaults.h"
+#include "lib/device/dev-cache.h"
+#include "lib/device/device.h"
+#include "lib/display/display.h"
 #include "errors.h"
-#include "metadata-exported.h"
-#include "locking.h"
-#include "lvm-exec.h"
-#include "lvm-file.h"
-#include "lvm-signal.h"
-#include "lvm-string.h"
-#include "segtype.h"
-#include "str_list.h"
-#include "toolcontext.h"
+#include "lib/metadata/metadata-exported.h"
+#include "lib/locking/locking.h"
+#include "lib/misc/lvm-exec.h"
+#include "lib/misc/lvm-file.h"
+#include "lib/misc/lvm-signal.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/metadata/segtype.h"
+#include "lib/datastruct/str_list.h"
+#include "lib/commands/toolcontext.h"
 #include "toollib.h"
-#include "lvmnotify.h"
+#include "lib/notify/lvmnotify.h"
 
 #include <ctype.h>
 #include <sys/types.h>
diff --git a/tools/vgcfgrestore.c b/tools/vgcfgrestore.c
index e9f1a4c..adcd45a 100644
--- a/tools/vgcfgrestore.c
+++ b/tools/vgcfgrestore.c
@@ -14,7 +14,7 @@
  */
 
 #include "tools.h"
-#include "lvmetad-client.h"
+#include "daemons/lvmetad/lvmetad-client.h"
 
 int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 {
diff --git a/tools/vgimportclone.c b/tools/vgimportclone.c
index 224d0b5..d1509bf 100644
--- a/tools/vgimportclone.c
+++ b/tools/vgimportclone.c
@@ -13,9 +13,9 @@
  */
 
 #include "tools.h"
-#include "lvmcache.h"
-#include "lvmetad-client.h"
-#include "filter.h"
+#include "lib/cache/lvmcache.h"
+#include "daemons/lvmetad/lvmetad-client.h"
+#include "lib/filters/filter.h"
 
 struct vgimportclone_params {
 	unsigned done;


