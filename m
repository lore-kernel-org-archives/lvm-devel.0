From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 10 May 2018 08:05:41 -0400
Subject: master - Merge branch 'master' into 2018-04-30-vdo-support
Message-ID: <201805101205.w4AC5f0u032497@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=11d9b0cae7ef451e282ad17f6085450afc91b2ca
Commit:        11d9b0cae7ef451e282ad17f6085450afc91b2ca
Parent:        52ebad31bae64edd92244a244c8928fb2171c209 11436b00e0fa4a54ce504beba72b23bbf0682b27
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Wed May 2 10:09:20 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Wed May 2 10:09:20 2018 +0100

Merge branch 'master' into 2018-04-30-vdo-support


 Makefile.in                          |    2 -
 WHATS_NEW                            |    1 +
 configure                            |  111 +-----
 configure.ac                         |   69 +---
 daemons/clvmd/clvmd-command.c        |    1 -
 daemons/clvmd/lvm-functions.c        |   10 -
 daemons/clvmd/lvm-functions.h        |    1 -
 daemons/dmeventd/plugins/Makefile.in |    2 +-
 daemons/lvmetad/lvmetad-client.h     |    1 -
 daemons/lvmetad/lvmetad-core.c       |    9 +-
 include/.gitignore                   |    6 +-
 include/.symlinks.in                 |   80 ++++
 include/Makefile.in                  |   20 +-
 include/activate.h                   |    1 -
 include/archiver.h                   |    1 -
 include/bcache.h                     |    1 -
 include/btree.h                      |    1 -
 include/clvm.h                       |    1 -
 include/config-util.h                |    1 -
 include/config.h                     |    1 -
 include/config_settings.h            |    1 -
 include/configure.h.in               |   14 -
 include/crc.h                        |    1 -
 include/daemon-client.h              |    1 -
 include/daemon-io.h                  |    1 -
 include/defaults.h                   |    1 -
 include/dev-cache.h                  |    1 -
 include/dev-ext-udev-constants.h     |    1 -
 include/dev-type.h                   |    1 -
 include/device-types.h               |    1 -
 include/device.h                     |    1 -
 include/display.h                    |    1 -
 include/dm-ioctl.h                   |    1 -
 include/dm-log-userspace.h           |    1 -
 include/dm-logging.h                 |    1 -
 include/dmlib.h                      |    1 -
 include/filter.h                     |    1 -
 include/format-text.h                |    1 -
 include/format1.h                    |    1 -
 include/format_pool.h                |    1 -
 include/intl.h                       |    1 -
 include/kdev_t.h                     |    1 -
 include/label.h                      |    1 -
 include/last-path-component.h        |    1 -
 include/lib.h                        |    1 -
 include/libdevmapper-event.h         |    1 -
 include/libdevmapper.h               |    1 -
 include/locking.h                    |    1 -
 include/log.h                        |    1 -
 include/lv.h                         |    1 -
 include/lv_alloc.h                   |    1 -
 include/lvm-exec.h                   |    1 -
 include/lvm-file.h                   |    1 -
 include/lvm-flock.h                  |    1 -
 include/lvm-globals.h                |    1 -
 include/lvm-logging.h                |    1 -
 include/lvm-maths.h                  |    1 -
 include/lvm-percent.h                |    1 -
 include/lvm-signal.h                 |    1 -
 include/lvm-string.h                 |    1 -
 include/lvm-wrappers.h               |    1 -
 include/lvm2app.h                    |    1 -
 include/lvm2cmd.h                    |    1 -
 include/lvmcache.h                   |    1 -
 include/lvmetad-client.h             |    1 -
 include/lvmetad.h                    |    1 -
 include/lvmlockd-client.h            |    1 -
 include/lvmlockd.h                   |    1 -
 include/lvmnotify.h                  |    1 -
 include/lvmpolld-client.h            |    1 -
 include/lvmpolld-protocol.h          |    1 -
 include/memlock.h                    |    1 -
 include/metadata-exported.h          |    1 -
 include/metadata.h                   |    1 -
 include/pogen.h                      |    1 -
 include/polldaemon.h                 |    1 -
 include/polling_ops.h                |    1 -
 include/prop_common.h                |    1 -
 include/properties.h                 |    1 -
 include/pv.h                         |    1 -
 include/pv_alloc.h                   |    1 -
 include/report.h                     |    1 -
 include/segtype.h                    |    1 -
 include/sharedlib.h                  |    1 -
 include/str_list.h                   |    1 -
 include/targets.h                    |    1 -
 include/text_export.h                |    1 -
 include/text_import.h                |    1 -
 include/tool.h                       |    1 -
 include/toolcontext.h                |    1 -
 include/util.h                       |    1 -
 include/uuid.h                       |    1 -
 include/vg.h                         |    1 -
 include/xlate.h                      |    1 -
 lib/Makefile.in                      |   31 +--
 lib/activate/activate.c              |   13 -
 lib/activate/activate.h              |    1 -
 lib/cache/lvmcache.c                 |   10 +-
 lib/cache/lvmetad.c                  |   23 +-
 lib/commands/toolcontext.c           |   29 +-
 lib/config/config_settings.h         |   20 +-
 lib/device/bcache.c                  |  118 +++---
 lib/device/dev-lvm1-pool.c           |  174 ++++++++
 lib/device/dev-type.h                |    3 +
 lib/display/display.c                |    9 +-
 lib/filters/filter-signature.c       |   96 +++++
 lib/filters/filter.h                 |    1 +
 lib/format1/.exported_symbols        |    1 -
 lib/format1/Makefile.in              |   33 --
 lib/format1/disk-rep.c               |  761 ----------------------------------
 lib/format1/disk-rep.h               |  250 -----------
 lib/format1/format1.c                |  631 ----------------------------
 lib/format1/format1.h                |   29 --
 lib/format1/import-export.c          |  680 ------------------------------
 lib/format1/import-extents.c         |  377 -----------------
 lib/format1/layout.c                 |  172 --------
 lib/format1/lvm1-label.c             |  129 ------
 lib/format1/lvm1-label.h             |   23 -
 lib/format1/vg_number.c              |   60 ---
 lib/format_pool/.exported_symbols    |    1 -
 lib/format_pool/Makefile.in          |   30 --
 lib/format_pool/disk_rep.c           |  409 ------------------
 lib/format_pool/disk_rep.h           |  156 -------
 lib/format_pool/format_pool.c        |  338 ---------------
 lib/format_pool/format_pool.h        |   28 --
 lib/format_pool/import_export.c      |  285 -------------
 lib/format_pool/pool_label.c         |  104 -----
 lib/format_pool/pool_label.h         |   23 -
 lib/format_pool/sptype_names.h       |   42 --
 lib/format_text/export.c             |    2 -
 lib/format_text/format-text.c        |    4 +-
 lib/format_text/import_vsn1.c        |    9 +-
 lib/label/label.c                    |   18 +-
 lib/locking/locking.c                |   40 --
 lib/metadata/lv_manip.c              |   26 --
 lib/metadata/metadata-exported.h     |   10 +-
 lib/metadata/metadata.c              |   27 +-
 lib/metadata/segtype.h               |    2 +-
 lib/metadata/snapshot_manip.c        |   11 -
 lib/metadata/vg.c                    |   17 +-
 lib/metadata/vg.h                    |    1 -
 lib/report/report.c                  |    4 +-
 lib/striped/striped.c                |    2 +-
 make.tmpl.in                         |   11 +-
 man/vgconvert.8_des                  |    7 +-
 test/lib/aux.sh                      |    4 -
 test/shell/format-lvm1.sh            |   38 --
 test/shell/lvm1-basic.sh             |   36 --
 test/shell/lvmetad-disabled.sh       |   24 +-
 test/shell/pool-labels.sh            |   11 +-
 test/shell/snapshot-lvm1.sh          |   35 --
 test/shell/vgcreate-usage.sh         |    4 -
 test/unit/bcache_t.c                 |   39 ++-
 test/unit/io_engine_t.c              |   83 ++++-
 tools/args.h                         |    3 +-
 tools/lvconvert.c                    |    5 -
 tools/lvmcmdline.c                   |   58 +---
 tools/pvscan.c                       |    5 +-
 tools/stub.h                         |    1 -
 tools/toollib.c                      |   31 +--
 tools/vals.h                         |    4 +-
 tools/vgchange.c                     |   10 -
 tools/vgconvert.c                    |   53 +--
 tools/vgscan.c                       |    4 +-
 164 files changed, 668 insertions(+), 5468 deletions(-)

diff --cc Makefile.in
index 1b16945,746be15..3274f17
--- a/Makefile.in
+++ b/Makefile.in
@@@ -210,12 -210,8 +210,10 @@@ endi
  
  endif
  
- ifeq ("$(TESTING)", "yes")
  include test/unit/Makefile
- endif
  
 +include device-mapper/Makefile
 +
  ifneq ($(shell which ctags),)
  .PHONY: tags
  tags:


