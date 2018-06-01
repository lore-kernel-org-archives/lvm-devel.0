From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 1 Jun 2018 10:32:02 -0400
Subject: master - Merge branch 'master' into 2018-05-11-fork-libdm
Message-ID: <201806011432.w51EW2Su024999@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dbba1e9b93bac348c0df556b160676234cc8a8c4
Commit:        dbba1e9b93bac348c0df556b160676234cc8a8c4
Parent:        89fdc0b5889d24fe785e7fa4c2be13659d1ed0b2 cb379c86c4b468858b781695934d5ad5957108d2
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Jun 1 13:04:12 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri Jun 1 13:04:12 2018 +0100

Merge branch 'master' into 2018-05-11-fork-libdm


 .gitignore                                         |   52 +++-
 VERSION                                            |    2 +-
 VERSION_DM                                         |    2 +-
 WHATS_NEW                                          |   27 +-
 WHATS_NEW_DM                                       |    7 +-
 base/data-struct/radix-tree.c                      |  394 +++++++++++++++++---
 base/data-struct/radix-tree.h                      |   25 +-
 daemons/clvmd/lvm-functions.c                      |    2 +-
 daemons/lvmdbusd/Makefile.in                       |    2 +
 daemons/lvmdbusd/lv.py                             |    2 +-
 daemons/lvmlockd/lvmlockd-core.c                   |   38 ++-
 doc/release-notes/2.02.178                         |   53 +++
 lib/Makefile.in                                    |    1 +
 lib/cache/lvmcache.c                               |  125 ++++++-
 lib/cache/lvmcache.h                               |    2 +
 lib/cache/lvmetad.c                                |    2 +
 lib/device/bcache.c                                |  226 ++++++-----
 lib/device/dev-cache.c                             |  189 ++++++++--
 lib/device/dev-cache.h                             |    2 +
 lib/device/device.h                                |    1 +
 lib/filters/filter-md.c                            |   89 ++++-
 lib/filters/filter-persistent.c                    |   10 +-
 lib/format_text/archive.c                          |    4 +-
 lib/label/label.c                                  |  160 ++++++++-
 lib/label/label.h                                  |    1 +
 lib/locking/locking.c                              |   16 +-
 lib/locking/lvmlockd.c                             |   37 ++-
 lib/metadata/cache_manip.c                         |    4 +-
 lib/metadata/lv_manip.c                            |   22 +-
 lib/metadata/metadata-exported.h                   |    3 +-
 lib/metadata/metadata-liblvm.c                     |   13 +-
 lib/metadata/metadata.c                            |  104 +++---
 lib/metadata/mirror.c                              |    8 +
 lib/metadata/raid_manip.c                          |   20 +-
 lib/metadata/thin_manip.c                          |    2 +-
 lib/report/columns.h                               |    1 +
 lib/report/properties.c                            |    2 +
 lib/report/report.c                                |    8 +
 lib/report/values.h                                |    1 +
 liblvm/test/vgadd.c                                |   90 +++++
 liblvm/test/vgshow.c                               |   95 +++++
 make.tmpl.in                                       |    1 +
 man/dmeventd.8_main                                |    4 +-
 man/lvmlockd.8_main                                |   14 +-
 man/vgexport.8_des                                 |   19 +-
 man/vgexport.8_pregen                              |   19 +-
 scripts/code-stats.rb                              |   90 +++++
 test/Makefile.in                                   |   32 +-
 test/api/Makefile.in                               |    5 +
 test/api/pytest.sh                                 |   12 +-
 test/api/python_lvm_unit.py.in                     |   10 +-
 test/api/vgtest.c                                  |    2 +-
 test/dbus/lvmdbustest.py                           |   16 +-
 test/dbus/testlib.py                               |    2 +-
 test/dbus/validatestate.py                         |    2 +-
 test/lib/aux.sh                                    |   34 +-
 test/lib/flavour-udev-lvmlockd-dlm.sh              |    1 -
 test/lib/flavour-udev-lvmlockd-sanlock.sh          |    1 -
 test/lib/flavour-udev-lvmlockd-test-lvmetad.sh     |    9 +
 test/lib/flavour-udev-lvmlockd-test.sh             |    1 -
 test/lib/inittest.sh                               |    4 +-
 test/shell/000-basic.sh                            |    2 +-
 test/shell/activate-minor.sh                       |    2 +-
 test/shell/activate-missing-segment.sh             |    2 +-
 test/shell/activate-missing.sh                     |    2 +-
 test/shell/activate-partial.sh                     |    2 +-
 test/shell/activation-skip.sh                      |    2 +-
 test/shell/backup-read-only.sh                     |    2 +-
 test/shell/cache-metadata2.sh                      |    2 +-
 test/shell/component-cache.sh                      |    2 +-
 test/shell/component-raid.sh                       |    2 +-
 test/shell/component-thin.sh                       |    2 +-
 test/shell/covercmd.sh                             |    4 +-
 test/shell/discards-thin.sh                        |    6 +-
 test/shell/dmeventd-restart.sh                     |    2 +-
 test/shell/dmstats-create.sh                       |    1 +
 test/shell/dmstats-report.sh                       |    1 +
 test/shell/dumpconfig.sh                           |    2 +-
 test/shell/error-usage.sh                          |    2 +-
 test/shell/fsadm-crypt.sh                          |    2 +-
 test/shell/fsadm-renamed.sh                        |    2 +-
 test/shell/fsadm.sh                                |    2 +-
 test/shell/inconsistent-metadata.sh                |    4 +-
 test/shell/listings.sh                             |    9 +-
 test/shell/lock-blocking.sh                        |    6 +-
 test/shell/lock-parallel.sh                        |    2 +-
 test/shell/losetup-partscan.sh                     |    6 +-
 test/shell/lv-ancestry.sh                          |    3 +-
 test/shell/lvchange-cache-mode.sh                  |    2 +-
 test/shell/lvchange-cache-old.sh                   |    4 +-
 test/shell/lvchange-cache-syncaction-raid.sh       |    2 +-
 test/shell/lvchange-cache.sh                       |    2 +-
 test/shell/lvchange-mirror.sh                      |    2 +-
 test/shell/lvchange-partial-raid10.sh              |    2 +-
 test/shell/lvchange-partial.sh                     |    2 +-
 test/shell/lvchange-raid-transient-failures.sh     |    2 +-
 test/shell/lvchange-raid.sh                        |    2 +-
 test/shell/lvchange-raid1-writemostly.sh           |    2 +-
 test/shell/lvchange-rebuild-raid.sh                |    2 +-
 test/shell/lvchange-syncaction-raid.sh             |    2 +-
 test/shell/lvchange-thin.sh                        |    6 +-
 test/shell/lvconvert-cache-abort.sh                |    2 +-
 test/shell/lvconvert-cache-chunks.sh               |    2 +-
 test/shell/lvconvert-cache-raid.sh                 |    3 +-
 test/shell/lvconvert-cache-smq.sh                  |    2 +-
 test/shell/lvconvert-m-raid1-degraded.sh           |    2 +-
 test/shell/lvconvert-mirror-basic.sh               |    2 +-
 test/shell/lvconvert-mirror-updown.sh              |    4 +-
 test/shell/lvconvert-mirror.sh                     |    4 +-
 test/shell/lvconvert-raid-allocation.sh            |    4 +-
 test/shell/lvconvert-raid-regionsize.sh            |    2 +-
 .../lvconvert-raid-reshape-linear_to_striped.sh    |    1 -
 test/shell/lvconvert-raid-reshape-load.sh          |    4 +-
 .../lvconvert-raid-reshape-striped_to_linear.sh    |    2 +-
 .../lvconvert-raid-reshape-stripes-load-fail.sh    |    4 +-
 .../lvconvert-raid-reshape-stripes-load-reload.sh  |    4 +-
 test/shell/lvconvert-raid-reshape-stripes-load.sh  |    4 +-
 test/shell/lvconvert-raid-reshape.sh               |    4 +-
 test/shell/lvconvert-raid-status-validation.sh     |    4 +-
 .../shell/lvconvert-raid-takeover-alloc-failure.sh |    2 +-
 test/shell/lvconvert-raid-takeover-thin.sh         |    2 +-
 test/shell/lvconvert-raid-takeover.sh              |    2 +-
 test/shell/lvconvert-raid.sh                       |    3 +-
 test/shell/lvconvert-raid0_to_raid10.sh            |    4 +-
 test/shell/lvconvert-raid10.sh                     |    4 +-
 test/shell/lvconvert-raid456.sh                    |    2 +-
 test/shell/lvconvert-raid5_to_raid10.sh            |    2 +-
 test/shell/lvconvert-repair-cache.sh               |    2 +-
 test/shell/lvconvert-repair-dmeventd.sh            |    2 +-
 test/shell/lvconvert-repair-mirror.sh              |    4 +-
 test/shell/lvconvert-repair-policy.sh              |    2 +-
 test/shell/lvconvert-repair-raid-dmeventd.sh       |    2 +-
 test/shell/lvconvert-repair-raid.sh                |    2 +-
 test/shell/lvconvert-repair-replace.sh             |   12 +-
 test/shell/lvconvert-repair-snapshot.sh            |    2 +-
 test/shell/lvconvert-repair-thin-raid.sh           |    2 +-
 test/shell/lvconvert-repair-transient-dmeventd.sh  |    2 +-
 test/shell/lvconvert-repair-transient.sh           |    2 +-
 test/shell/lvconvert-repair.sh                     |    8 +-
 test/shell/lvconvert-thin-raid.sh                  |    1 -
 test/shell/lvconvert-twostep.sh                    |    2 +-
 test/shell/lvcreate-cache-fail.sh                  |    4 +-
 test/shell/lvcreate-cache-no-tools.sh              |    2 +-
 test/shell/lvcreate-cache-raid.sh                  |    2 +-
 test/shell/lvcreate-cache-snapshot.sh              |    3 +-
 test/shell/lvcreate-cache.sh                       |    2 +-
 test/shell/lvcreate-large-raid.sh                  |    4 +-
 test/shell/lvcreate-mirror.sh                      |    2 +-
 test/shell/lvcreate-missing.sh                     |    2 +-
 test/shell/lvcreate-operation.sh                   |    4 +-
 test/shell/lvcreate-pvtags.sh                      |    3 +-
 test/shell/lvcreate-raid-nosync.sh                 |    2 +-
 test/shell/lvcreate-raid-volume_list.sh            |    4 +-
 test/shell/lvcreate-raid.sh                        |    4 +-
 test/shell/lvcreate-raid10.sh                      |    2 +-
 test/shell/lvcreate-repair.sh                      |    5 +-
 test/shell/lvcreate-signature-wiping.sh            |    2 +-
 test/shell/lvcreate-small-snap.sh                  |    4 +-
 test/shell/lvcreate-striped-mirror.sh              |    2 +-
 test/shell/lvcreate-thin-big.sh                    |    4 +-
 test/shell/lvcreate-thin-cache.sh                  |    4 +-
 test/shell/lvcreate-thin-external-size.sh          |    4 +-
 test/shell/lvcreate-thin-external.sh               |    4 +-
 test/shell/lvcreate-thin-power2.sh                 |    4 +-
 test/shell/lvcreate-thin-snap.sh                   |    4 +-
 test/shell/lvcreate-thin.sh                        |    4 +-
 test/shell/lvcreate-usage.sh                       |   10 +-
 test/shell/lvextend-percent-extents.sh             |    4 +-
 test/shell/lvextend-snapshot-dmeventd.sh           |    1 -
 test/shell/lvextend-snapshot-policy.sh             |    2 +-
 test/shell/lvextend-thin-cache.sh                  |    2 +-
 test/shell/lvextend-thin-data-dmeventd.sh          |    4 +-
 test/shell/lvextend-thin-metadata-dmeventd.sh      |    4 +-
 test/shell/lvextend-thin-raid.sh                   |    2 +-
 test/shell/lvextend-thin.sh                        |    2 +-
 test/shell/lvm-init.sh                             |    2 +-
 test/shell/lvmetad-pvs.sh                          |    2 +-
 test/shell/lvmetad-pvscan-md.sh                    |    3 +-
 test/shell/lvmlockd-hello-world.sh                 |    2 +-
 test/shell/lvrename-cache-thin.sh                  |    2 +-
 test/shell/lvresize-full.sh                        |    2 +-
 test/shell/lvresize-mirror.sh                      |    2 +-
 test/shell/lvresize-raid.sh                        |    4 +-
 test/shell/lvresize-raid10.sh                      |    2 +-
 test/shell/lvresize-rounding.sh                    |    6 +-
 test/shell/lvresize-thin-metadata.sh               |    2 +-
 test/shell/lvresize-usage.sh                       |    2 +-
 test/shell/lvs-cache.sh                            |    2 +-
 test/shell/mda-rollback.sh                         |    4 +-
 test/shell/mdata-strings.sh                        |    3 +-
 test/shell/metadata-balance.sh                     |   49 ++--
 test/shell/metadata-dirs.sh                        |   14 +-
 test/shell/metadata.sh                             |    7 +-
 test/shell/mirror-names.sh                         |    2 +-
 test/shell/mirror-vgreduce-removemissing.sh        |    4 +-
 test/shell/name-mangling.sh                        |    2 +-
 test/shell/nomda-missing.sh                        |    4 +-
 test/shell/nomda-restoremissing.sh                 |    2 +-
 test/shell/orphan-ondisk.sh                        |    2 +-
 test/shell/pool-labels.sh                          |    2 +-
 test/shell/process-each-duplicate-pvs.sh           |   40 ++-
 test/shell/process-each-lv.sh                      |    2 +
 test/shell/process-each-pv-nomda.sh                |    2 +-
 test/shell/process-each-pvresize.sh                |    8 +-
 test/shell/process-each-vgreduce.sh                |   16 +-
 test/shell/profiles-cache.sh                       |    2 +-
 test/shell/profiles-thin.sh                        |    6 +-
 test/shell/profiles.sh                             |    4 +-
 test/shell/pv-check-dev-size.sh                    |    8 +-
 test/shell/pv-duplicate-uuid.sh                    |    7 +-
 test/shell/pv-ext-update.sh                        |    1 +
 test/shell/pv-min-size.sh                          |    2 +-
 test/shell/pv-range-overflow.sh                    |    2 +-
 test/shell/pvchange-usage.sh                       |   10 +-
 test/shell/pvcreate-bootloaderarea.sh              |    4 +-
 test/shell/pvcreate-md-fake-hdr.sh                 |   94 +++++
 test/shell/pvcreate-metadata0.sh                   |    4 +-
 test/shell/pvcreate-operation-md.sh                |   19 +-
 test/shell/pvcreate-operation.sh                   |   16 +-
 test/shell/pvcreate-usage.sh                       |   18 +-
 test/shell/pvmove-restart.sh                       |    6 +-
 test/shell/pvremove-thin.sh                        |    2 +-
 test/shell/pvremove-usage.sh                       |    6 +-
 test/shell/pvremove-warnings.sh                    |    4 +-
 test/shell/pvresize-mdas.sh                        |    2 +-
 test/shell/read-ahead.sh                           |    2 +-
 test/shell/relative-sign-options.sh                |    1 +
 test/shell/report-fields.sh                        |    2 +-
 test/shell/report-hidden.sh                        |    2 +-
 test/shell/select-report.sh                        |    8 +-
 test/shell/select-tools-thin.sh                    |    4 +-
 test/shell/select-tools.sh                         |    6 +-
 test/shell/snapshot-autoumount-dmeventd.sh         |    2 +-
 test/shell/snapshot-cluster.sh                     |    2 +-
 test/shell/snapshot-maxsize.sh                     |    4 +-
 test/shell/snapshot-merge-stack.sh                 |    2 +-
 test/shell/snapshot-merge.sh                       |    2 +-
 test/shell/snapshot-reactivate.sh                  |    2 +-
 test/shell/snapshot-rename.sh                      |    2 +-
 test/shell/snapshots-of-mirrors.sh                 |    2 +-
 test/shell/stray-device-node.sh                    |    4 +-
 test/shell/system_id.sh                            |    2 +
 test/shell/tags.sh                                 |   16 +-
 test/shell/test-partition.sh                       |    2 +-
 test/shell/thin-autoumount-dmeventd.sh             |    2 +-
 test/shell/thin-defaults.sh                        |    2 +-
 test/shell/thin-dmeventd-warns.sh                  |    2 +-
 test/shell/thin-foreign-dmeventd.sh                |    2 +-
 test/shell/thin-large.sh                           |    2 +-
 test/shell/thin-merge.sh                           |    2 +-
 test/shell/thin-overprovisioning.sh                |    2 +-
 test/shell/thin-resize-match.sh                    |    2 +-
 test/shell/thin-restore.sh                         |    2 +-
 test/shell/thin-vglock.sh                          |    2 +-
 test/shell/thin-volume-list.sh                     |    2 +-
 test/shell/topology-support.sh                     |    8 +-
 test/shell/unknown-segment.sh                      |    2 +-
 test/shell/unlost-pv.sh                            |    2 +-
 test/shell/vg-check-devs-used.sh                   |    3 +-
 test/shell/vg-name-from-env.sh                     |    6 +-
 test/shell/vgcfgbackup-lvm1.sh                     |    4 +-
 test/shell/vgcfgbackup-usage.sh                    |    8 +-
 test/shell/vgchange-many.sh                        |    4 +-
 test/shell/vgchange-maxlv.sh                       |    6 +-
 test/shell/vgchange-partial.sh                     |    2 +-
 test/shell/vgchange-sysinit.sh                     |   10 +-
 test/shell/vgchange-usage.sh                       |    7 +-
 test/shell/vgck.sh                                 |    2 +-
 test/shell/vgcreate-many-pvs.sh                    |    6 +-
 test/shell/vgcreate-usage.sh                       |   89 +++---
 test/shell/vgextend-restoremissing.sh              |    2 +-
 test/shell/vgextend-usage.sh                       |   22 +-
 test/shell/vgimportclone.sh                        |    5 +-
 test/shell/vgreduce-removemissing-snapshot.sh      |    2 +-
 test/shell/vgreduce-usage.sh                       |   14 +-
 test/shell/vgremove-corrupt-vg.sh                  |    2 +-
 test/shell/vgsplit-stacked.sh                      |    6 +-
 test/shell/zero-usage.sh                           |    2 +-
 test/unit/radix_tree_t.c                           |  275 +++++++++++++-
 tools/lvchange.c                                   |    8 +-
 tools/lvconvert.c                                  |    4 +-
 tools/lvcreate.c                                   |   14 +-
 tools/pvremove.c                                   |   13 +-
 tools/reporter.c                                   |    2 +
 tools/toollib.c                                    |    4 +-
 tools/vgimportclone.c                              |   15 +-
 286 files changed, 2624 insertions(+), 889 deletions(-)

diff --cc lib/device/bcache.c
index d224436,d9bacf8..8fda0bd
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@@ -14,9 -14,11 +14,11 @@@
  
  #define _GNU_SOURCE
  
 -#include "bcache.h"
 +#include "lib/device/bcache.h"
+ 
+ #include "base/data-struct/radix-tree.h"
 -#include "lvm-logging.h"
 -#include "log.h"
 +#include "lib/log/lvm-logging.h"
 +#include "lib/log/log.h"
  
  #include <errno.h>
  #include <fcntl.h>
diff --cc lib/metadata/raid_manip.c
index cef0427,0c631b4..f53915b
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@@ -12,15 -12,16 +12,16 @@@
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
 -#include "lvmlockd.h"
 +#include "lib/misc/lib.h"
 +#include "lib/format_text/archiver.h"
 +#include "lib/metadata/metadata.h"
 +#include "lib/commands/toolcontext.h"
 +#include "lib/metadata/segtype.h"
 +#include "lib/display/display.h"
 +#include "lib/activate/activate.h"
 +#include "lib/metadata/lv_alloc.h"
 +#include "lib/misc/lvm-string.h"
++#include "lib/locking/lvmlockd.h"
  
  typedef int (*fn_on_lv_t)(struct logical_volume *lv, void *data);
  static int _eliminate_extracted_lvs_optional_write_vg(struct volume_group *vg,
diff --cc make.tmpl.in
index c4d9d58,1f999ec..10075d4
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@@ -310,8 -308,10 +310,9 @@@ LIB_VERSION_APP := $(shell $(AWK) -F '[
  
  INCLUDES += -I$(top_srcdir) -I$(srcdir) -I$(top_builddir)/include
  
 -INC_LNS = $(top_builddir)/include/.symlinks_created
+ 
  DEPS = $(top_builddir)/make.tmpl $(top_srcdir)/VERSION \
 -       $(top_builddir)/Makefile $(INC_LNS)
 +       $(top_builddir)/Makefile
  
  OBJECTS = $(SOURCES:%.c=%.o) $(CXXSOURCES:%.cpp=%.o)
  POTFILES = $(SOURCES:%.c=%.pot)


