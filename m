From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 8 Jun 2018 09:25:26 -0400
Subject: master - test/unit: Rename Makefile.in -> Makefile
Message-ID: <201806081325.w58DPQoQ015604@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9573ff3a3bbd61fb178ea73e24c689822b9aca85
Commit:        9573ff3a3bbd61fb178ea73e24c689822b9aca85
Parent:        b67ef90438052d3e01f563cdd25e2268f4e02c20
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Jun 8 09:50:40 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri Jun 8 09:50:40 2018 +0100

test/unit: Rename Makefile.in -> Makefile

There's nothing being expanded.
---
 configure             |    3 +--
 configure.ac          |    1 -
 test/unit/Makefile    |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 test/unit/Makefile.in |   47 -----------------------------------------------
 4 files changed, 48 insertions(+), 50 deletions(-)

diff --git a/configure b/configure
index 09d20af..953539f 100755
--- a/configure
+++ b/configure
@@ -13611,7 +13611,7 @@ _ACEOF
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl libdm/make.tmpl daemons/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc man/Makefile po/Makefile python/Makefile python/setup
 .py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/api/python_lvm_unit.py test/unit/Makefile tools/Makefile udev
 /Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl libdm/make.tmpl daemons/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc man/Makefile po/Makefile python/Makefile python/setup
 .py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/api/python_lvm_unit.py tools/Makefile udev/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -14371,7 +14371,6 @@ do
     "test/Makefile") CONFIG_FILES="$CONFIG_FILES test/Makefile" ;;
     "test/api/Makefile") CONFIG_FILES="$CONFIG_FILES test/api/Makefile" ;;
     "test/api/python_lvm_unit.py") CONFIG_FILES="$CONFIG_FILES test/api/python_lvm_unit.py" ;;
-    "test/unit/Makefile") CONFIG_FILES="$CONFIG_FILES test/unit/Makefile" ;;
     "tools/Makefile") CONFIG_FILES="$CONFIG_FILES tools/Makefile" ;;
     "udev/Makefile") CONFIG_FILES="$CONFIG_FILES udev/Makefile" ;;
 
diff --git a/configure.ac b/configure.ac
index 9b5d055..d8bfb47 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1816,7 +1816,6 @@ scripts/Makefile
 test/Makefile
 test/api/Makefile
 test/api/python_lvm_unit.py
-test/unit/Makefile
 tools/Makefile
 udev/Makefile
 ])
diff --git a/test/unit/Makefile b/test/unit/Makefile
new file mode 100644
index 0000000..e7cc852
--- /dev/null
+++ b/test/unit/Makefile
@@ -0,0 +1,47 @@
+# Copyright (C) 2011-2018 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+UNIT_SOURCE=\
+	base/data-struct/radix-tree.c \
+	device_mapper/vdo/status.c \
+	\
+	test/unit/activation-generator_t.c \
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
+
+test/unit/unit-test: $(UNIT_OBJECTS) lib/liblvm-internal.a libdaemon/client/libdaemonclient.a $(INTERNAL_LIBS)
+	@echo "    [LD] $@"
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) \
+	      -o $@ $+ $(LIBS) -lm -ldl -laio
+
+.PHONEY: run-unit-test
+run-unit-test: test/unit/unit-test
+	@echo Running unit tests
+	LD_LIBRARY_PATH=libdm test/unit/unit-test run
+
+-include $(UNIT_DEPENDS)
diff --git a/test/unit/Makefile.in b/test/unit/Makefile.in
deleted file mode 100644
index e7cc852..0000000
--- a/test/unit/Makefile.in
+++ /dev/null
@@ -1,47 +0,0 @@
-# Copyright (C) 2011-2018 Red Hat, Inc. All rights reserved.
-#
-# This file is part of LVM2.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-UNIT_SOURCE=\
-	base/data-struct/radix-tree.c \
-	device_mapper/vdo/status.c \
-	\
-	test/unit/activation-generator_t.c \
-	test/unit/bcache_t.c \
-	test/unit/bcache_utils_t.c \
-	test/unit/bitset_t.c \
-	test/unit/config_t.c \
-	test/unit/dmlist_t.c \
-	test/unit/dmstatus_t.c \
-	test/unit/io_engine_t.c \
-	test/unit/radix_tree_t.c \
-	test/unit/matcher_t.c \
-	test/unit/framework.c \
-	test/unit/percent_t.c \
-	test/unit/run.c \
-	test/unit/string_t.c \
-	test/unit/vdo_t.c
-
-UNIT_DEPENDS=$(subst .c,.d,$(UNIT_SOURCE))
-UNIT_OBJECTS=$(UNIT_SOURCE:%.c=%.o)
-CLEAN_TARGETS+=$(UNIT_DEPENDS) $(UNIT_OBJECTS)
-
-test/unit/unit-test: $(UNIT_OBJECTS) lib/liblvm-internal.a libdaemon/client/libdaemonclient.a $(INTERNAL_LIBS)
-	@echo "    [LD] $@"
-	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) \
-	      -o $@ $+ $(LIBS) -lm -ldl -laio
-
-.PHONEY: run-unit-test
-run-unit-test: test/unit/unit-test
-	@echo Running unit tests
-	LD_LIBRARY_PATH=libdm test/unit/unit-test run
-
--include $(UNIT_DEPENDS)


