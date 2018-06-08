From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 8 Jun 2018 09:26:11 -0400
Subject: master - Merge branch '2018-06-04-data-structs'
Message-ID: <201806081326.w58DQB5f015678@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7c4b19c335c7da9f2b58ef71de46b170b59a2f9d
Commit:        7c4b19c335c7da9f2b58ef71de46b170b59a2f9d
Parent:        0e2a358da926b75dabd5074fcff589cac0f22821 0ac89fb8603d891458cbb55d9071db0c5c057db3
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Jun 8 14:21:07 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri Jun 8 14:21:07 2018 +0100

Merge branch '2018-06-04-data-structs'


 base/Makefile                                      |    2 +
 base/data-struct/hash.c                            |  394 ++
 base/data-struct/hash.h                            |   94 +
 base/data-struct/list.c                            |  170 +
 base/data-struct/list.h                            |  209 ++
 configure                                          |    3 +-
 configure.ac                                       |    1 -
 daemons/cmirrord/cluster.h                         |    2 +-
 daemons/cmirrord/functions.c                       |   14 +-
 daemons/dmeventd/dmeventd.c                        |   73 +-
 daemons/dmeventd/libdevmapper-event.c              |   65 +-
 daemons/dmfilemapd/dmfilemapd.c                    |   14 +-
 daemons/lvmetad/lvmetad-core.c                     |   78 +-
 daemons/lvmpolld/lvmpolld-cmd-utils.c              |   10 +-
 daemons/lvmpolld/lvmpolld-core.c                   |   16 +-
 daemons/lvmpolld/lvmpolld-data-utils.c             |   54 +-
 device_mapper/Makefile                             |    3 -
 device_mapper/all.h                                | 3430 ++++++++++++++++++
 device_mapper/datastruct/bitset.c                  |    5 +-
 device_mapper/datastruct/hash.c                    |  392 --
 device_mapper/datastruct/list.c                    |  168 -
 device_mapper/ioctl/libdm-iface.c                  |   56 +-
 device_mapper/libdevmapper.h                       | 3755 --------------------
 device_mapper/libdm-common.c                       |   57 +-
 device_mapper/libdm-common.h                       |    2 +-
 device_mapper/libdm-config.c                       |    8 +-
 device_mapper/libdm-deptree.c                      |    5 +-
 device_mapper/libdm-file.c                         |    4 +-
 device_mapper/libdm-report.c                       |   45 +-
 device_mapper/libdm-stats.c                        |  119 +-
 device_mapper/libdm-string.c                       |   12 +-
 device_mapper/libdm-timestamp.c                    |    7 +-
 device_mapper/misc/dm-logging.h                    |    2 +-
 device_mapper/misc/dmlib.h                         |    2 +-
 device_mapper/mm/dbg_malloc.c                      |  413 ---
 device_mapper/mm/pool-debug.c                      |   20 +-
 device_mapper/mm/pool-fast.c                       |    9 +-
 device_mapper/vdo/status.c                         |    2 +-
 lib/activate/activate.c                            |    2 +-
 lib/activate/dev_manager.c                         |    4 +-
 lib/activate/fs.c                                  |    4 +-
 lib/cache/lvmcache.c                               |   57 +-
 lib/cache/lvmetad.c                                |    4 +-
 lib/cache_segtype/cache.c                          |    7 +-
 lib/commands/toolcontext.c                         |   15 +-
 lib/config/config.c                                |   16 +-
 lib/config/config.h                                |    2 +-
 lib/device/bcache.c                                |   40 +-
 lib/device/bcache.h                                |    2 +-
 lib/device/dev-cache.c                             |   29 +-
 lib/device/dev-io.c                                |    4 +-
 lib/device/dev-type.c                              |    5 +-
 lib/device/device.h                                |    2 +-
 lib/error/errseg.c                                 |    5 +-
 lib/filters/filter-composite.c                     |   11 +-
 lib/filters/filter-fwraid.c                        |    5 +-
 lib/filters/filter-internal.c                      |    5 +-
 lib/filters/filter-md.c                            |    5 +-
 lib/filters/filter-mpath.c                         |    5 +-
 lib/filters/filter-partitioned.c                   |    5 +-
 lib/filters/filter-persistent.c                    |   19 +-
 lib/filters/filter-signature.c                     |    5 +-
 lib/filters/filter-type.c                          |    5 +-
 lib/filters/filter-usable.c                        |   11 +-
 lib/format_text/archiver.c                         |    8 +-
 lib/format_text/export.c                           |   33 +-
 lib/format_text/flags.c                            |    4 +-
 lib/format_text/format-text.c                      |   32 +-
 lib/format_text/text_label.c                       |   19 +-
 lib/freeseg/freeseg.c                              |    5 +-
 lib/label/label.c                                  |   21 +-
 lib/log/log.c                                      |   10 +-
 lib/lvmpolld/lvmpolld-client.c                     |    4 +-
 lib/metadata/lv_manip.c                            |    6 +-
 lib/metadata/metadata-liblvm.c                     |    6 +-
 lib/metadata/pv.h                                  |    2 +-
 lib/metadata/vg.h                                  |    2 +-
 lib/mirror/mirrored.c                              |    7 +-
 lib/misc/lib.h                                     |    3 +-
 lib/misc/lvm-file.c                                |   10 +-
 lib/misc/lvm-flock.c                               |   14 +-
 lib/mm/memlock.c                                   |    4 +-
 lib/raid/raid.c                                    |   11 +-
 lib/report/properties.h                            |    2 +-
 lib/snapshot/snapshot.c                            |    7 +-
 lib/striped/striped.c                              |    5 +-
 lib/thin/thin.c                                    |    7 +-
 lib/unknown/unknown.c                              |   11 +-
 lib/zero/zero.c                                    |    5 +-
 libdaemon/client/config-util.c                     |   10 +-
 libdaemon/client/daemon-client.c                   |    6 +-
 libdaemon/server/daemon-log.c                      |   12 +-
 libdaemon/server/daemon-server.c                   |    4 +-
 libdm/misc/dmlib.h                                 |   67 +-
 .../lvm2_activation_generator_systemd_red_hat.c    |    2 +-
 test/unit/Makefile                                 |   47 +
 test/unit/Makefile.in                              |   47 -
 test/unit/activation-generator_t.c                 |    2 +-
 test/unit/bitset_t.c                               |    2 +-
 test/unit/config_t.c                               |    2 +-
 test/unit/dmlist_t.c                               |    2 +-
 test/unit/dmstatus_t.c                             |    2 +-
 test/unit/framework.h                              |    2 +-
 test/unit/matcher_t.c                              |    2 +-
 test/unit/percent_t.c                              |    2 +-
 test/unit/string_t.c                               |    2 +-
 tools/command.c                                    |   36 +-
 tools/dmsetup.c                                    |   95 +-
 tools/lvmcmdlib.c                                  |    4 +-
 tools/pvck.c                                       |    3 +-
 tools/tool.h                                       |    3 +-
 tools/toollib.c                                    |    2 +-
 tools/vgcfgbackup.c                                |   12 +-
 113 files changed, 5132 insertions(+), 5463 deletions(-)


