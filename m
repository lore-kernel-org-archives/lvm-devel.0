From: Joe Thornber <thornber@sourceware.org>
Date: Wed, 16 May 2018 05:15:05 -0400
Subject: master - Merge branch 'master' of git://sourceware.org/git/lvm2
Message-ID: <201805160915.w4G9F5t2025652@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e296f784c974eaa76deb3af58baf79a70095b308
Commit:        e296f784c974eaa76deb3af58baf79a70095b308
Parent:        df2acbbb97dbda000053afd40d2e4a707e226b52 ed799404f887339ebf8bc6ca4504c8bff6b1f491
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Wed May 16 10:11:58 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Wed May 16 10:11:58 2018 +0100

Merge branch 'master' of git://sourceware.org/git/lvm2


 Makefile.in                          |   18 +-
 WHATS_NEW                            |    4 +
 conf/example.conf.in                 |   27 +-
 configure                            |    6 +-
 configure.ac                         |    4 +-
 daemons/lvmlockd/Makefile.in         |    2 +
 device-mapper/Makefile               |   20 -
 device-mapper/vdo/status.c           |  248 --------
 device-mapper/vdo/target.h           |   68 ---
 device_mapper/Makefile.in            |   23 +
 device_mapper/vdo/status.c           |  248 ++++++++
 device_mapper/vdo/target.h           |   68 +++
 doc/lvm-disk-reading.txt             |  107 ++++
 include/configure.h.in               |    3 +
 lib/cache/lvmcache.c                 |   68 ++-
 lib/cache/lvmcache.h                 |    1 -
 lib/config/config_settings.h         |    2 +-
 lib/device/bcache.c                  |    2 +-
 lib/device/dev-cache.c               |    1 -
 lib/device/dev-io.c                  |   35 +-
 lib/device/dev-md.c                  |   10 +-
 lib/device/dev-type.c                |    3 +
 lib/device/device.h                  |    2 -
 lib/label/label.c                    |  205 ++++---
 lib/label/label.h                    |    4 +-
 lib/metadata/metadata-liblvm.c       |    3 +-
 lib/metadata/metadata.c              |    4 +-
 lib/misc/lvm-exec.c                  |    1 -
 liblvm/lvm_vg.c                      |    2 +
 man/lvconvert.8_pregen               |    8 +-
 man/pvcreate.8_pregen                |    7 +-
 man/vgcfgrestore.8_pregen            |    9 +-
 man/vgconvert.8_pregen               |   14 +-
 man/vgcreate.8_pregen                |    7 +-
 man/vgextend.8_pregen                |    7 +-
 man/vgsplit.8_pregen                 |    7 +-
 python/setup.py.in                   |    2 +-
 test/Makefile.in                     |   15 +-
 test/api/pytest.sh                   |    4 +-
 test/api/python_lvm_unit.py          | 1048 ----------------------------------
 test/api/python_lvm_unit.py.in       | 1048 ++++++++++++++++++++++++++++++++++
 test/lib/aux.sh                      |   76 +++-
 test/lib/check.sh                    |    3 +-
 test/lib/inittest.sh                 |   20 +-
 test/shell/fsadm-crypt.sh            |    4 +
 test/shell/fsadm-renamed.sh          |    2 +-
 test/shell/lvconvert-mirror.sh       |   22 +-
 test/shell/lvconvert-raid-reshape.sh |    2 +-
 test/shell/lvconvert-snapshot.sh     |    2 +-
 test/shell/lvcreate-small-snap.sh    |   12 +-
 test/shell/lvmetad-disabled.sh       |    6 +-
 test/shell/mirror-names.sh           |   16 +-
 test/shell/pvmove-abort-all.sh       |   21 +-
 test/shell/pvmove-abort.sh           |   21 +-
 test/shell/snapshot-maxsize.sh       |    2 +-
 test/shell/snapshot-usage.sh         |   26 +-
 test/shell/thin-merge.sh             |    1 +
 test/shell/topology-support.sh       |    2 +-
 test/shell/vgcreate-usage.sh         |    6 +-
 test/unit/Makefile.in                |   67 ++-
 test/unit/bcache_utils_t.c           |   31 +-
 test/unit/io_engine_t.c              |    7 +-
 test/unit/unit-test.sh               |   23 +
 test/unit/vdo_t.c                    |    2 +-
 tools/polldaemon.c                   |   11 +-
 tools/pvck.c                         |   28 +-
 tools/toollib.c                      |    3 +-
 67 files changed, 2031 insertions(+), 1750 deletions(-)


