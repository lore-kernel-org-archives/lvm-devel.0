From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 27 Apr 2018 10:31:19 -0400
Subject: master - Revert "build: Stop creating the symlinks in include/ on the fly."
Message-ID: <201804271431.w3REVJm9024300@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5c878167a25728fa73a6b7866785a318ba5da7e3
Commit:        5c878167a25728fa73a6b7866785a318ba5da7e3
Parent:        f8f621951315087c4e7720682be495941dc3cf37
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Apr 27 15:30:08 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri Apr 27 15:30:08 2018 +0100

Revert "build: Stop creating the symlinks in include/ on the fly."

This reverts commit f8f621951315087c4e7720682be495941dc3cf37.

It wasn't taking builds outside the src dir into account.
---
 configure                        |    3 +-
 configure.in                     |    1 +
 include/.gitignore               |    6 ++-
 include/.symlinks.in             |   80 ++++++++++++++++++++++++++++++++++++++
 include/Makefile.in              |   20 +++++++++-
 include/activate.h               |    1 -
 include/archiver.h               |    1 -
 include/bcache.h                 |    1 -
 include/btree.h                  |    1 -
 include/clvm.h                   |    1 -
 include/config-util.h            |    1 -
 include/config.h                 |    1 -
 include/config_settings.h        |    1 -
 include/crc.h                    |    1 -
 include/daemon-client.h          |    1 -
 include/daemon-io.h              |    1 -
 include/defaults.h               |    1 -
 include/dev-cache.h              |    1 -
 include/dev-ext-udev-constants.h |    1 -
 include/dev-type.h               |    1 -
 include/device-types.h           |    1 -
 include/device.h                 |    1 -
 include/display.h                |    1 -
 include/dm-ioctl.h               |    1 -
 include/dm-log-userspace.h       |    1 -
 include/dm-logging.h             |    1 -
 include/dmlib.h                  |    1 -
 include/filter.h                 |    1 -
 include/format-text.h            |    1 -
 include/format1.h                |    1 -
 include/format_pool.h            |    1 -
 include/intl.h                   |    1 -
 include/kdev_t.h                 |    1 -
 include/label.h                  |    1 -
 include/last-path-component.h    |    1 -
 include/lib.h                    |    1 -
 include/libdevmapper-event.h     |    1 -
 include/libdevmapper.h           |    1 -
 include/locking.h                |    1 -
 include/log.h                    |    1 -
 include/lv.h                     |    1 -
 include/lv_alloc.h               |    1 -
 include/lvm-exec.h               |    1 -
 include/lvm-file.h               |    1 -
 include/lvm-flock.h              |    1 -
 include/lvm-globals.h            |    1 -
 include/lvm-logging.h            |    1 -
 include/lvm-maths.h              |    1 -
 include/lvm-percent.h            |    1 -
 include/lvm-signal.h             |    1 -
 include/lvm-string.h             |    1 -
 include/lvm-wrappers.h           |    1 -
 include/lvm2app.h                |    1 -
 include/lvm2cmd.h                |    1 -
 include/lvmcache.h               |    1 -
 include/lvmetad-client.h         |    1 -
 include/lvmetad.h                |    1 -
 include/lvmlockd-client.h        |    1 -
 include/lvmlockd.h               |    1 -
 include/lvmnotify.h              |    1 -
 include/lvmpolld-client.h        |    1 -
 include/lvmpolld-protocol.h      |    1 -
 include/memlock.h                |    1 -
 include/metadata-exported.h      |    1 -
 include/metadata.h               |    1 -
 include/pogen.h                  |    1 -
 include/polldaemon.h             |    1 -
 include/polling_ops.h            |    1 -
 include/prop_common.h            |    1 -
 include/properties.h             |    1 -
 include/pv.h                     |    1 -
 include/pv_alloc.h               |    1 -
 include/report.h                 |    1 -
 include/segtype.h                |    1 -
 include/sharedlib.h              |    1 -
 include/str_list.h               |    1 -
 include/targets.h                |    1 -
 include/text_export.h            |    1 -
 include/text_import.h            |    1 -
 include/tool.h                   |    1 -
 include/toolcontext.h            |    1 -
 include/util.h                   |    1 -
 include/uuid.h                   |    1 -
 include/vg.h                     |    1 -
 include/xlate.h                  |    1 -
 make.tmpl.in                     |    6 ++-
 86 files changed, 110 insertions(+), 86 deletions(-)

diff --git a/configure b/configure
index 7ef73f0..63ca480 100755
--- a/configure
+++ b/configure
@@ -15689,7 +15689,7 @@ _ACEOF
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile include/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache
 _segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/
 lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile unit-test/Makefile tools/Makefile udev/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile include/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/
 Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_h
 at.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile unit-test/Makefile tools/Makefile udev/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -16411,6 +16411,7 @@ do
     "conf/lvmlocal.conf") CONFIG_FILES="$CONFIG_FILES conf/lvmlocal.conf" ;;
     "conf/command_profile_template.profile") CONFIG_FILES="$CONFIG_FILES conf/command_profile_template.profile" ;;
     "conf/metadata_profile_template.profile") CONFIG_FILES="$CONFIG_FILES conf/metadata_profile_template.profile" ;;
+    "include/.symlinks") CONFIG_FILES="$CONFIG_FILES include/.symlinks" ;;
     "include/Makefile") CONFIG_FILES="$CONFIG_FILES include/Makefile" ;;
     "lib/Makefile") CONFIG_FILES="$CONFIG_FILES lib/Makefile" ;;
     "lib/format1/Makefile") CONFIG_FILES="$CONFIG_FILES lib/format1/Makefile" ;;
diff --git a/configure.in b/configure.in
index f65e35e..461c21b 100644
--- a/configure.in
+++ b/configure.in
@@ -2194,6 +2194,7 @@ conf/example.conf
 conf/lvmlocal.conf
 conf/command_profile_template.profile
 conf/metadata_profile_template.profile
+include/.symlinks
 include/Makefile
 lib/Makefile
 lib/format1/Makefile
diff --git a/include/.gitignore b/include/.gitignore
index 396884b..4971e07 100644
--- a/include/.gitignore
+++ b/include/.gitignore
@@ -1,2 +1,4 @@
-configure.h
-lvm-version.h
+.symlinks
+.symlinks_created
+
+*.h
diff --git a/include/.symlinks.in b/include/.symlinks.in
new file mode 100644
index 0000000..3d50750
--- /dev/null
+++ b/include/.symlinks.in
@@ -0,0 +1,80 @@
+ at top_srcdir@/daemons/clvmd/clvm.h
+ at top_srcdir@/daemons/dmeventd/libdevmapper-event.h
+ at top_srcdir@/daemons/lvmetad/lvmetad-client.h
+ at top_srcdir@/daemons/lvmlockd/lvmlockd-client.h
+ at top_srcdir@/daemons/lvmpolld/lvmpolld-protocol.h
+ at top_srcdir@/daemons/lvmpolld/polling_ops.h
+ at top_srcdir@/lib/activate/activate.h
+ at top_srcdir@/lib/activate/targets.h
+ at top_srcdir@/lib/cache/lvmcache.h
+ at top_srcdir@/lib/cache/lvmetad.h
+ at top_srcdir@/lib/commands/toolcontext.h
+ at top_srcdir@/lib/config/config.h
+ at top_srcdir@/lib/config/config_settings.h
+ at top_srcdir@/lib/config/defaults.h
+ at top_srcdir@/lib/datastruct/btree.h
+ at top_srcdir@/lib/datastruct/str_list.h
+ at top_srcdir@/lib/device/bcache.h
+ at top_srcdir@/lib/device/dev-cache.h
+ at top_srcdir@/lib/device/dev-ext-udev-constants.h
+ at top_srcdir@/lib/device/dev-type.h
+ at top_srcdir@/lib/device/device-types.h
+ at top_srcdir@/lib/device/device.h
+ at top_srcdir@/lib/display/display.h
+ at top_srcdir@/lib/filters/filter.h
+ at top_srcdir@/lib/format1/format1.h
+ at top_srcdir@/lib/format_pool/format_pool.h
+ at top_srcdir@/lib/format_text/archiver.h
+ at top_srcdir@/lib/format_text/format-text.h
+ at top_srcdir@/lib/format_text/text_export.h
+ at top_srcdir@/lib/format_text/text_import.h
+ at top_srcdir@/lib/label/label.h
+ at top_srcdir@/lib/locking/locking.h
+ at top_srcdir@/lib/locking/lvmlockd.h
+ at top_srcdir@/lib/log/log.h
+ at top_srcdir@/lib/log/lvm-logging.h
+ at top_srcdir@/lib/lvmpolld/lvmpolld-client.h
+ at top_srcdir@/lib/lvmpolld/polldaemon.h
+ at top_srcdir@/lib/metadata/lv.h
+ at top_srcdir@/lib/metadata/lv_alloc.h
+ at top_srcdir@/lib/metadata/metadata-exported.h
+ at top_srcdir@/lib/metadata/metadata.h
+ at top_srcdir@/lib/metadata/pv.h
+ at top_srcdir@/lib/metadata/pv_alloc.h
+ at top_srcdir@/lib/metadata/segtype.h
+ at top_srcdir@/lib/metadata/vg.h
+ at top_srcdir@/lib/misc/crc.h
+ at top_srcdir@/lib/misc/intl.h
+ at top_srcdir@/lib/misc/last-path-component.h
+ at top_srcdir@/lib/misc/lib.h
+ at top_srcdir@/lib/misc/lvm-exec.h
+ at top_srcdir@/lib/misc/lvm-file.h
+ at top_srcdir@/lib/misc/lvm-flock.h
+ at top_srcdir@/lib/misc/lvm-globals.h
+ at top_srcdir@/lib/misc/lvm-maths.h
+ at top_srcdir@/lib/misc/lvm-percent.h
+ at top_srcdir@/lib/misc/lvm-signal.h
+ at top_srcdir@/lib/misc/lvm-string.h
+ at top_srcdir@/lib/misc/lvm-wrappers.h
+ at top_srcdir@/lib/misc/sharedlib.h
+ at top_srcdir@/lib/misc/util.h
+ at top_srcdir@/lib/mm/memlock.h
+ at top_srcdir@/lib/mm/xlate.h
+ at top_srcdir@/lib/notify/lvmnotify.h
+ at top_srcdir@/lib/properties/prop_common.h
+ at top_srcdir@/lib/report/properties.h
+ at top_srcdir@/lib/report/report.h
+ at top_srcdir@/lib/uuid/uuid.h
+ at top_srcdir@/libdaemon/client/config-util.h
+ at top_srcdir@/libdaemon/client/daemon-client.h
+ at top_srcdir@/libdaemon/client/daemon-io.h
+ at top_srcdir@/libdm/libdevmapper.h
+ at top_srcdir@/libdm/misc/dm-ioctl.h
+ at top_srcdir@/libdm/misc/dm-log-userspace.h
+ at top_srcdir@/libdm/misc/dm-logging.h
+ at top_srcdir@/libdm/misc/dmlib.h
+ at top_srcdir@/libdm/misc/kdev_t.h
+ at top_srcdir@/liblvm/lvm2app.h
+ at top_srcdir@/po/pogen.h
+ at top_srcdir@/tools/lvm2cmd.h
+ at top_srcdir@/tools/tool.h
diff --git a/include/Makefile.in b/include/Makefile.in
index e5c09b5..b2571fd 100644
--- a/include/Makefile.in
+++ b/include/Makefile.in
@@ -18,4 +18,22 @@ top_builddir = @top_builddir@
 
 include $(top_builddir)/make.tmpl
 
-DISTCLEAN_TARGETS += configure.h lvm-version.h
+all: .symlinks_created
+
+LINKS := $(shell find . -maxdepth 1 -type l)
+
+.symlinks_created: .symlinks
+ifneq (,$(firstword $(LINKS)))
+	$(RM) $(LINKS)
+endif
+	for i in `cat $<`; do $(LN_S) $$i ; done
+	touch $@
+
+pofile: all
+
+device-mapper: all
+
+cflow: all
+
+DISTCLEAN_TARGETS += .symlinks configure.h lvm-version.h
+CLEAN_TARGETS += $(LINKS) .include_symlinks .symlinks_created
diff --git a/include/activate.h b/include/activate.h
deleted file mode 120000
index 3c8d94a..0000000
--- a/include/activate.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/activate/activate.h
\ No newline at end of file
diff --git a/include/archiver.h b/include/archiver.h
deleted file mode 120000
index bac9048..0000000
--- a/include/archiver.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/format_text/archiver.h
\ No newline at end of file
diff --git a/include/bcache.h b/include/bcache.h
deleted file mode 120000
index 5855f8d..0000000
--- a/include/bcache.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/device/bcache.h
\ No newline at end of file
diff --git a/include/btree.h b/include/btree.h
deleted file mode 120000
index e45aee4..0000000
--- a/include/btree.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/datastruct/btree.h
\ No newline at end of file
diff --git a/include/clvm.h b/include/clvm.h
deleted file mode 120000
index 9740db4..0000000
--- a/include/clvm.h
+++ /dev/null
@@ -1 +0,0 @@
-../daemons/clvmd/clvm.h
\ No newline at end of file
diff --git a/include/config-util.h b/include/config-util.h
deleted file mode 120000
index 4b7b220..0000000
--- a/include/config-util.h
+++ /dev/null
@@ -1 +0,0 @@
-../libdaemon/client/config-util.h
\ No newline at end of file
diff --git a/include/config.h b/include/config.h
deleted file mode 120000
index a733942..0000000
--- a/include/config.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/config/config.h
\ No newline at end of file
diff --git a/include/config_settings.h b/include/config_settings.h
deleted file mode 120000
index 407d594..0000000
--- a/include/config_settings.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/config/config_settings.h
\ No newline at end of file
diff --git a/include/crc.h b/include/crc.h
deleted file mode 120000
index 25c761a..0000000
--- a/include/crc.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/misc/crc.h
\ No newline at end of file
diff --git a/include/daemon-client.h b/include/daemon-client.h
deleted file mode 120000
index 7dbf53f..0000000
--- a/include/daemon-client.h
+++ /dev/null
@@ -1 +0,0 @@
-../libdaemon/client/daemon-client.h
\ No newline at end of file
diff --git a/include/daemon-io.h b/include/daemon-io.h
deleted file mode 120000
index 79612d9..0000000
--- a/include/daemon-io.h
+++ /dev/null
@@ -1 +0,0 @@
-../libdaemon/client/daemon-io.h
\ No newline at end of file
diff --git a/include/defaults.h b/include/defaults.h
deleted file mode 120000
index c97f06f..0000000
--- a/include/defaults.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/config/defaults.h
\ No newline at end of file
diff --git a/include/dev-cache.h b/include/dev-cache.h
deleted file mode 120000
index edb7395..0000000
--- a/include/dev-cache.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/device/dev-cache.h
\ No newline at end of file
diff --git a/include/dev-ext-udev-constants.h b/include/dev-ext-udev-constants.h
deleted file mode 120000
index 97258ef..0000000
--- a/include/dev-ext-udev-constants.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/device/dev-ext-udev-constants.h
\ No newline at end of file
diff --git a/include/dev-type.h b/include/dev-type.h
deleted file mode 120000
index 8082a76..0000000
--- a/include/dev-type.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/device/dev-type.h
\ No newline at end of file
diff --git a/include/device-types.h b/include/device-types.h
deleted file mode 120000
index 452a6fa..0000000
--- a/include/device-types.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/device/device-types.h
\ No newline at end of file
diff --git a/include/device.h b/include/device.h
deleted file mode 120000
index ee365d9..0000000
--- a/include/device.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/device/device.h
\ No newline at end of file
diff --git a/include/display.h b/include/display.h
deleted file mode 120000
index b614ede..0000000
--- a/include/display.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/display/display.h
\ No newline at end of file
diff --git a/include/dm-ioctl.h b/include/dm-ioctl.h
deleted file mode 120000
index 4acd5a5..0000000
--- a/include/dm-ioctl.h
+++ /dev/null
@@ -1 +0,0 @@
-../libdm/misc/dm-ioctl.h
\ No newline at end of file
diff --git a/include/dm-log-userspace.h b/include/dm-log-userspace.h
deleted file mode 120000
index 37c9fea..0000000
--- a/include/dm-log-userspace.h
+++ /dev/null
@@ -1 +0,0 @@
-../libdm/misc/dm-log-userspace.h
\ No newline at end of file
diff --git a/include/dm-logging.h b/include/dm-logging.h
deleted file mode 120000
index 2af311e..0000000
--- a/include/dm-logging.h
+++ /dev/null
@@ -1 +0,0 @@
-../libdm/misc/dm-logging.h
\ No newline at end of file
diff --git a/include/dmlib.h b/include/dmlib.h
deleted file mode 120000
index 6e99e60..0000000
--- a/include/dmlib.h
+++ /dev/null
@@ -1 +0,0 @@
-../libdm/misc/dmlib.h
\ No newline at end of file
diff --git a/include/filter.h b/include/filter.h
deleted file mode 120000
index c22ea16..0000000
--- a/include/filter.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/filters/filter.h
\ No newline at end of file
diff --git a/include/format-text.h b/include/format-text.h
deleted file mode 120000
index ca81b1d..0000000
--- a/include/format-text.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/format_text/format-text.h
\ No newline at end of file
diff --git a/include/format1.h b/include/format1.h
deleted file mode 120000
index 4e23bc9..0000000
--- a/include/format1.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/format1/format1.h
\ No newline at end of file
diff --git a/include/format_pool.h b/include/format_pool.h
deleted file mode 120000
index 7198a37..0000000
--- a/include/format_pool.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/format_pool/format_pool.h
\ No newline at end of file
diff --git a/include/intl.h b/include/intl.h
deleted file mode 120000
index 6db3a2b..0000000
--- a/include/intl.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/misc/intl.h
\ No newline at end of file
diff --git a/include/kdev_t.h b/include/kdev_t.h
deleted file mode 120000
index 1d04a72..0000000
--- a/include/kdev_t.h
+++ /dev/null
@@ -1 +0,0 @@
-../libdm/misc/kdev_t.h
\ No newline at end of file
diff --git a/include/label.h b/include/label.h
deleted file mode 120000
index 0af47ca..0000000
--- a/include/label.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/label/label.h
\ No newline at end of file
diff --git a/include/last-path-component.h b/include/last-path-component.h
deleted file mode 120000
index 58f8bad..0000000
--- a/include/last-path-component.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/misc/last-path-component.h
\ No newline at end of file
diff --git a/include/lib.h b/include/lib.h
deleted file mode 120000
index 912ac0c..0000000
--- a/include/lib.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/misc/lib.h
\ No newline at end of file
diff --git a/include/libdevmapper-event.h b/include/libdevmapper-event.h
deleted file mode 120000
index a54561d..0000000
--- a/include/libdevmapper-event.h
+++ /dev/null
@@ -1 +0,0 @@
-../daemons/dmeventd/libdevmapper-event.h
\ No newline at end of file
diff --git a/include/libdevmapper.h b/include/libdevmapper.h
deleted file mode 120000
index a88009b..0000000
--- a/include/libdevmapper.h
+++ /dev/null
@@ -1 +0,0 @@
-../libdm/libdevmapper.h
\ No newline at end of file
diff --git a/include/locking.h b/include/locking.h
deleted file mode 120000
index 6ea3343..0000000
--- a/include/locking.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/locking/locking.h
\ No newline at end of file
diff --git a/include/log.h b/include/log.h
deleted file mode 120000
index 245ac3d..0000000
--- a/include/log.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/log/log.h
\ No newline at end of file
diff --git a/include/lv.h b/include/lv.h
deleted file mode 120000
index 7cd7de6..0000000
--- a/include/lv.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/metadata/lv.h
\ No newline at end of file
diff --git a/include/lv_alloc.h b/include/lv_alloc.h
deleted file mode 120000
index bbb691c..0000000
--- a/include/lv_alloc.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/metadata/lv_alloc.h
\ No newline at end of file
diff --git a/include/lvm-exec.h b/include/lvm-exec.h
deleted file mode 120000
index 5b5232a..0000000
--- a/include/lvm-exec.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/misc/lvm-exec.h
\ No newline at end of file
diff --git a/include/lvm-file.h b/include/lvm-file.h
deleted file mode 120000
index bcb8288..0000000
--- a/include/lvm-file.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/misc/lvm-file.h
\ No newline at end of file
diff --git a/include/lvm-flock.h b/include/lvm-flock.h
deleted file mode 120000
index e1ef682..0000000
--- a/include/lvm-flock.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/misc/lvm-flock.h
\ No newline at end of file
diff --git a/include/lvm-globals.h b/include/lvm-globals.h
deleted file mode 120000
index 767f63d..0000000
--- a/include/lvm-globals.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/misc/lvm-globals.h
\ No newline at end of file
diff --git a/include/lvm-logging.h b/include/lvm-logging.h
deleted file mode 120000
index 9236bad..0000000
--- a/include/lvm-logging.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/log/lvm-logging.h
\ No newline at end of file
diff --git a/include/lvm-maths.h b/include/lvm-maths.h
deleted file mode 120000
index 45a0815..0000000
--- a/include/lvm-maths.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/misc/lvm-maths.h
\ No newline at end of file
diff --git a/include/lvm-percent.h b/include/lvm-percent.h
deleted file mode 120000
index 3160573..0000000
--- a/include/lvm-percent.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/misc/lvm-percent.h
\ No newline at end of file
diff --git a/include/lvm-signal.h b/include/lvm-signal.h
deleted file mode 120000
index d987311..0000000
--- a/include/lvm-signal.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/misc/lvm-signal.h
\ No newline at end of file
diff --git a/include/lvm-string.h b/include/lvm-string.h
deleted file mode 120000
index f727b1e..0000000
--- a/include/lvm-string.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/misc/lvm-string.h
\ No newline at end of file
diff --git a/include/lvm-wrappers.h b/include/lvm-wrappers.h
deleted file mode 120000
index 424679a..0000000
--- a/include/lvm-wrappers.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/misc/lvm-wrappers.h
\ No newline at end of file
diff --git a/include/lvm2app.h b/include/lvm2app.h
deleted file mode 120000
index 17f2006..0000000
--- a/include/lvm2app.h
+++ /dev/null
@@ -1 +0,0 @@
-../liblvm/lvm2app.h
\ No newline at end of file
diff --git a/include/lvm2cmd.h b/include/lvm2cmd.h
deleted file mode 120000
index 9d27330..0000000
--- a/include/lvm2cmd.h
+++ /dev/null
@@ -1 +0,0 @@
-../tools/lvm2cmd.h
\ No newline at end of file
diff --git a/include/lvmcache.h b/include/lvmcache.h
deleted file mode 120000
index ba1399c..0000000
--- a/include/lvmcache.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/cache/lvmcache.h
\ No newline at end of file
diff --git a/include/lvmetad-client.h b/include/lvmetad-client.h
deleted file mode 120000
index 54b8f1f..0000000
--- a/include/lvmetad-client.h
+++ /dev/null
@@ -1 +0,0 @@
-../daemons/lvmetad/lvmetad-client.h
\ No newline at end of file
diff --git a/include/lvmetad.h b/include/lvmetad.h
deleted file mode 120000
index 65c561c..0000000
--- a/include/lvmetad.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/cache/lvmetad.h
\ No newline at end of file
diff --git a/include/lvmlockd-client.h b/include/lvmlockd-client.h
deleted file mode 120000
index 23291c2..0000000
--- a/include/lvmlockd-client.h
+++ /dev/null
@@ -1 +0,0 @@
-../daemons/lvmlockd/lvmlockd-client.h
\ No newline at end of file
diff --git a/include/lvmlockd.h b/include/lvmlockd.h
deleted file mode 120000
index 1fe51a6..0000000
--- a/include/lvmlockd.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/locking/lvmlockd.h
\ No newline at end of file
diff --git a/include/lvmnotify.h b/include/lvmnotify.h
deleted file mode 120000
index 7c624a7..0000000
--- a/include/lvmnotify.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/notify/lvmnotify.h
\ No newline at end of file
diff --git a/include/lvmpolld-client.h b/include/lvmpolld-client.h
deleted file mode 120000
index 78de8c6..0000000
--- a/include/lvmpolld-client.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/lvmpolld/lvmpolld-client.h
\ No newline at end of file
diff --git a/include/lvmpolld-protocol.h b/include/lvmpolld-protocol.h
deleted file mode 120000
index 5f5ecb5..0000000
--- a/include/lvmpolld-protocol.h
+++ /dev/null
@@ -1 +0,0 @@
-../daemons/lvmpolld/lvmpolld-protocol.h
\ No newline at end of file
diff --git a/include/memlock.h b/include/memlock.h
deleted file mode 120000
index 8d9bc4b..0000000
--- a/include/memlock.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/mm/memlock.h
\ No newline at end of file
diff --git a/include/metadata-exported.h b/include/metadata-exported.h
deleted file mode 120000
index 570ab36..0000000
--- a/include/metadata-exported.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/metadata/metadata-exported.h
\ No newline at end of file
diff --git a/include/metadata.h b/include/metadata.h
deleted file mode 120000
index 94fbad4..0000000
--- a/include/metadata.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/metadata/metadata.h
\ No newline at end of file
diff --git a/include/pogen.h b/include/pogen.h
deleted file mode 120000
index 9721487..0000000
--- a/include/pogen.h
+++ /dev/null
@@ -1 +0,0 @@
-../po/pogen.h
\ No newline at end of file
diff --git a/include/polldaemon.h b/include/polldaemon.h
deleted file mode 120000
index 7816b0b..0000000
--- a/include/polldaemon.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/lvmpolld/polldaemon.h
\ No newline at end of file
diff --git a/include/polling_ops.h b/include/polling_ops.h
deleted file mode 120000
index 4ec0a30..0000000
--- a/include/polling_ops.h
+++ /dev/null
@@ -1 +0,0 @@
-../daemons/lvmpolld/polling_ops.h
\ No newline at end of file
diff --git a/include/prop_common.h b/include/prop_common.h
deleted file mode 120000
index 40b570e..0000000
--- a/include/prop_common.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/properties/prop_common.h
\ No newline at end of file
diff --git a/include/properties.h b/include/properties.h
deleted file mode 120000
index f34e413..0000000
--- a/include/properties.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/report/properties.h
\ No newline at end of file
diff --git a/include/pv.h b/include/pv.h
deleted file mode 120000
index dd3267b..0000000
--- a/include/pv.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/metadata/pv.h
\ No newline at end of file
diff --git a/include/pv_alloc.h b/include/pv_alloc.h
deleted file mode 120000
index 2364a8d..0000000
--- a/include/pv_alloc.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/metadata/pv_alloc.h
\ No newline at end of file
diff --git a/include/report.h b/include/report.h
deleted file mode 120000
index 339bf85..0000000
--- a/include/report.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/report/report.h
\ No newline at end of file
diff --git a/include/segtype.h b/include/segtype.h
deleted file mode 120000
index 6b69bfd..0000000
--- a/include/segtype.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/metadata/segtype.h
\ No newline at end of file
diff --git a/include/sharedlib.h b/include/sharedlib.h
deleted file mode 120000
index dacb595..0000000
--- a/include/sharedlib.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/misc/sharedlib.h
\ No newline at end of file
diff --git a/include/str_list.h b/include/str_list.h
deleted file mode 120000
index dd91b1d..0000000
--- a/include/str_list.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/datastruct/str_list.h
\ No newline at end of file
diff --git a/include/targets.h b/include/targets.h
deleted file mode 120000
index a63c09a..0000000
--- a/include/targets.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/activate/targets.h
\ No newline at end of file
diff --git a/include/text_export.h b/include/text_export.h
deleted file mode 120000
index 4ef5b96..0000000
--- a/include/text_export.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/format_text/text_export.h
\ No newline at end of file
diff --git a/include/text_import.h b/include/text_import.h
deleted file mode 120000
index 33509d3..0000000
--- a/include/text_import.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/format_text/text_import.h
\ No newline at end of file
diff --git a/include/tool.h b/include/tool.h
deleted file mode 120000
index d8b2651..0000000
--- a/include/tool.h
+++ /dev/null
@@ -1 +0,0 @@
-../tools/tool.h
\ No newline at end of file
diff --git a/include/toolcontext.h b/include/toolcontext.h
deleted file mode 120000
index c26097f..0000000
--- a/include/toolcontext.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/commands/toolcontext.h
\ No newline at end of file
diff --git a/include/util.h b/include/util.h
deleted file mode 120000
index d9ca624..0000000
--- a/include/util.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/misc/util.h
\ No newline at end of file
diff --git a/include/uuid.h b/include/uuid.h
deleted file mode 120000
index 1b70f6e..0000000
--- a/include/uuid.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/uuid/uuid.h
\ No newline at end of file
diff --git a/include/vg.h b/include/vg.h
deleted file mode 120000
index 3f705b2..0000000
--- a/include/vg.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/metadata/vg.h
\ No newline at end of file
diff --git a/include/xlate.h b/include/xlate.h
deleted file mode 120000
index 4ab1c83..0000000
--- a/include/xlate.h
+++ /dev/null
@@ -1 +0,0 @@
-../lib/mm/xlate.h
\ No newline@end of file
diff --git a/make.tmpl.in b/make.tmpl.in
index f9b3d0e..75134ca 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -309,8 +309,10 @@ LIB_VERSION_APP := $(shell $(AWK) -F '[(). ]' '{printf "%s.%s",$$1,$$4}' $(top_s
 
 INCLUDES += -I$(srcdir) -I$(top_builddir)/include
 
+INC_LNS = $(top_builddir)/include/.symlinks_created
+
 DEPS = $(top_builddir)/make.tmpl $(top_srcdir)/VERSION \
-       $(top_builddir)/Makefile
+       $(top_builddir)/Makefile $(INC_LNS)
 
 OBJECTS = $(SOURCES:%.c=%.o) $(CXXSOURCES:%.cpp=%.o)
 POTFILES = $(SOURCES:%.c=%.pot)
@@ -503,7 +505,7 @@ $(LIB_STATIC): $(OBJECTS)
 	$(Q) $(RM) $@
 	$(Q) $(AR) rsv $@ $(OBJECTS) > /dev/null
 
-%.d: %.c
+%.d: %.c $(INC_LNS)
 	@echo "    [DEP] $<"
 	$(Q) $(MKDIR_P) $(dir $@); \
 	set -e; \


