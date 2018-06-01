From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 1 Jun 2018 10:31:55 -0400
Subject: master - Merge branch 'master' into 2018-05-11-fork-libdm
Message-ID: <201806011431.w51EVtvc024988@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=89fdc0b5889d24fe785e7fa4c2be13659d1ed0b2
Commit:        89fdc0b5889d24fe785e7fa4c2be13659d1ed0b2
Parent:        ccc35e2647b3b78f2fb0d62c25f21fcccbf58950 7c852c75c3b3e719d57d3410bf0c2a5e61d67f4e
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Wed May 16 13:43:02 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Wed May 16 13:43:02 2018 +0100

Merge branch 'master' into 2018-05-11-fork-libdm


 Makefile.in                          |    8 +-
 WHATS_NEW                            |    4 +
 conf/example.conf.in                 |   27 +-
 configure                            |    5 +-
 configure.ac                         |    3 +-
 daemons/lvmlockd/Makefile.in         |    2 +
 doc/lvm-disk-reading.txt             |  107 ++++
 include/configure.h.in               |    3 +
 lib/cache/lvmcache.c                 |   68 ++-
 lib/cache/lvmcache.h                 |    1 -
 lib/config/config_settings.h         |    2 +-
 lib/device/bcache.c                  |    3 +-
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
 test/unit/Makefile.in                |    6 +-
 test/unit/bcache_t.c                 |   43 ++-
 test/unit/bcache_utils_t.c           |   31 +-
 test/unit/io_engine_t.c              |    7 +-
 test/unit/unit-test.sh               |   23 +
 tools/polldaemon.c                   |   11 +-
 tools/pvck.c                         |   28 +-
 tools/toollib.c                      |    3 +-
 61 files changed, 1692 insertions(+), 1383 deletions(-)

diff --cc Makefile.in
index a1c8746,e2f5a84..00b4f1e
--- a/Makefile.in
+++ b/Makefile.in
@@@ -61,6 -61,9 +61,7 @@@ po: tools daemon
  man: tools
  all_man: tools
  scripts: liblvm libdm
+ test: tools daemons
 -unit-test: lib
 -run-unit-test: unit-test
  
  lib.device-mapper: include.device-mapper
  libdm.device-mapper: include.device-mapper
@@@ -96,7 -99,7 +97,7 @@@ endi
  DISTCLEAN_TARGETS += cscope.out
  CLEAN_DIRS += autom4te.cache
  
- check check_system check_cluster check_local check_lvmetad check_lvmpolld check_lvmlockd_test check_lvmlockd_dlm check_lvmlockd_sanlock: all
 -check check_system check_cluster check_local check_lvmetad check_lvmpolld check_lvmlockd_test check_lvmlockd_dlm check_lvmlockd_sanlock unit-test run-unit-test: test
++check check_system check_cluster check_local check_lvmetad check_lvmpolld check_lvmlockd_test check_lvmlockd_dlm check_lvmlockd_sanlock: test
  	$(MAKE) -C test $(@)
  
  conf.generate man.generate: tools
diff --cc configure
index 60f51d6,7d945df..38ee4dc
--- a/configure
+++ b/configure
@@@ -15559,7 -15559,7 +15559,7 @@@ _ACEO
  
  
  ################################################################################
- ac_config_files="$ac_config_files Makefile make.tmpl libdm/make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile lib/locking/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/M
 akefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm
 2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile"
 -ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile device_mapper/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/locking/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm
 /libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring
 _init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/api/python_lvm_unit.py test/unit/Makefile tools/Makefile udev/Makefile"
++ac_config_files="$ac_config_files Makefile make.tmpl libdm/make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile lib/locking/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/M
 akefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm
 2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/api/python_lvm_unit.py test/unit/Makefile tools/Makefile udev/Makefile"
  
  cat >confcache <<\_ACEOF
  # This file is a shell script that caches the results of configure
diff --cc lib/device/bcache.c
index d213758e7,30df54a..d224436
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@@ -14,9 -14,9 +14,9 @@@
  
  #define _GNU_SOURCE
  
 -#include "bcache.h"
 -#include "lvm-logging.h"
 -#include "log.h"
 +#include "lib/device/bcache.h"
- #include "device_mapper/misc/dm-logging.h"
++#include "lib/log/lvm-logging.h"
 +#include "lib/log/log.h"
  
  #include <errno.h>
  #include <fcntl.h>
diff --cc lib/device/dev-io.c
index 225fb36,9a03d3a..65b3db4
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@@ -13,12 -13,11 +13,11 @@@
   * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
   */
  
 -#include "lib.h"
 -#include "device.h"
 -#include "metadata.h"
 -#include "memlock.h"
 -#include "locking.h"
 +#include "lib/misc/lib.h"
 +#include "lib/device/device.h"
 +#include "lib/metadata/metadata.h"
- #include "lib/cache/lvmcache.h"
 +#include "lib/mm/memlock.h"
 +#include "lib/locking/locking.h"
  
  #include <limits.h>
  #include <sys/stat.h>
diff --cc test/unit/Makefile.in
index 54b7d72,cb92fb1..ca36c57
--- a/test/unit/Makefile.in
+++ b/test/unit/Makefile.in
@@@ -10,38 -10,49 +10,38 @@@
  # along with this program; if not, write to the Free Software Foundation,
  # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  
 -srcdir = @srcdir@
 -top_srcdir = @top_srcdir@
 -top_builddir = @top_builddir@
 -
 -SOURCES=\
 -	radix-tree.c \
 -	status.c \
 +UNIT_SOURCE=\
 +	base/data-struct/radix-tree.c \
 +	device_mapper/vdo/status.c \
  	\
 -	bcache_t.c \
 -	bcache_utils_t.c \
 -	bitset_t.c \
 -	config_t.c \
 -	dmlist_t.c \
 -	dmstatus_t.c \
 -	framework.c \
 -	io_engine_t.c \
 -	matcher_t.c \
 -	percent_t.c \
 -	radix_tree_t.c \
 -	run.c \
 -	string_t.c \
 -	vdo_t.c
 -
 -TARGETS += unit-test
 -
 -# Using vpath for other src dirs
 -# FIXME: hopefully later we will just link libs without need to extract sources
 -# via usage of vpath
 -vpath %.c \
 -	$(top_srcdir)/base/data-struct \
 -	$(top_srcdir)/device_mapper/vdo
 -
 -include $(top_builddir)/make.tmpl
 -
 -UNIT_LDLIBS += $(LVMINTERNAL_LIBS) -ldevmapper -laio
 -INCLUDES += -I$(top_srcdir)
 -
 -unit-test: $(OBJECTS) $(top_builddir)/libdm/libdevmapper.$(LIB_SUFFIX) $(top_builddir)/lib/liblvm-internal.a
 +	test/unit/bcache_t.c \
 +	test/unit/bcache_utils_t.c \
 +	test/unit/bitset_t.c \
 +	test/unit/config_t.c \
 +	test/unit/dmlist_t.c \
 +	test/unit/dmstatus_t.c \
 +	test/unit/io_engine_t.c \
 +	test/unit/radix_tree_t.c \
 +	test/unit/matcher_t.c \
 +	test/unit/framework.c \
 +	test/unit/percent_t.c \
 +	test/unit/run.c \
 +	test/unit/string_t.c \
 +	test/unit/vdo_t.c
 +
 +UNIT_DEPENDS=$(subst .c,.d,$(UNIT_SOURCE))
 +UNIT_OBJECTS=$(UNIT_SOURCE:%.c=%.o)
 +CLEAN_TARGETS+=$(UNIT_DEPENDS) $(UNIT_OBJECTS)
 +UNIT_LDLIBS += $(LVMINTERNAL_LIBS) -laio
 +
- test/unit/unit-test: $(UNIT_OBJECTS) device_mapper/libdevice-mapper.a lib/liblvm-internal.a
++test/unit/unit-test: $(UNIT_OBJECTS) lib/liblvm-internal.a device_mapper/libdevice-mapper.a
  	@echo "    [LD] $@"
--	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) -L$(top_builddir)/libdm \
- 	      -o $@ $(UNIT_OBJECTS) $(UNIT_LDLIBS)
 -	      -o $@ $(OBJECTS) $(UNIT_LDLIBS)
++	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) \
++	      -o $@ $+ $(UNIT_LDLIBS) -lm
  
 -.PHONY: run-unit-test
 -run-unit-test: unit-test
 +.PHONEY: run-unit-test
 +run-unit-test: test/unit/unit-test
  	@echo Running unit tests
 -	LD_LIBRARY_PATH=$(top_builddir)/libdm ./unit-test run
 +	LD_LIBRARY_PATH=libdm test/unit/unit-test run
 +
 +-include $(UNIT_DEPENDS)
diff --cc test/unit/bcache_utils_t.c
index 2c3bb0e,9ddc194..66780ea
--- a/test/unit/bcache_utils_t.c
+++ b/test/unit/bcache_utils_t.c
@@@ -14,6 -14,10 +14,10 @@@
  
  #define _GNU_SOURCE
  
 -#include "bcache.h"
++#include "lib/device/bcache.h"
+ #include "framework.h"
+ #include "units.h"
+ 
  #include <errno.h>
  #include <stdio.h>
  #include <stdlib.h>


