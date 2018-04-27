From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 27 Apr 2018 10:21:11 -0400
Subject: master - build: Stop creating the symlinks in include/ on the fly.
Message-ID: <201804271421.w3RELBTj022816@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f8f621951315087c4e7720682be495941dc3cf37
Commit:        f8f621951315087c4e7720682be495941dc3cf37
Parent:        54856b2965f4dc9fa05201af6407c1ed89577bb8
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Apr 27 15:12:15 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri Apr 27 15:12:15 2018 +0100

build: Stop creating the symlinks in include/ on the fly.

Git handles symlinks, tar handles symlinks.  So I've just put the
links themselves into git.

This simplifies dependencies a little, and stop some build loops I was
hitting.
---
 configure                        |    3 +-
 configure.in                     |    1 -
 include/.gitignore               |    6 +--
 include/.symlinks.in             |   80 --------------------------------------
 include/Makefile.in              |   20 +---------
 include/activate.h               |    1 +
 include/archiver.h               |    1 +
 include/bcache.h                 |    1 +
 include/btree.h                  |    1 +
 include/clvm.h                   |    1 +
 include/config-util.h            |    1 +
 include/config.h                 |    1 +
 include/config_settings.h        |    1 +
 include/crc.h                    |    1 +
 include/daemon-client.h          |    1 +
 include/daemon-io.h              |    1 +
 include/defaults.h               |    1 +
 include/dev-cache.h              |    1 +
 include/dev-ext-udev-constants.h |    1 +
 include/dev-type.h               |    1 +
 include/device-types.h           |    1 +
 include/device.h                 |    1 +
 include/display.h                |    1 +
 include/dm-ioctl.h               |    1 +
 include/dm-log-userspace.h       |    1 +
 include/dm-logging.h             |    1 +
 include/dmlib.h                  |    1 +
 include/filter.h                 |    1 +
 include/format-text.h            |    1 +
 include/format1.h                |    1 +
 include/format_pool.h            |    1 +
 include/intl.h                   |    1 +
 include/kdev_t.h                 |    1 +
 include/label.h                  |    1 +
 include/last-path-component.h    |    1 +
 include/lib.h                    |    1 +
 include/libdevmapper-event.h     |    1 +
 include/libdevmapper.h           |    1 +
 include/locking.h                |    1 +
 include/log.h                    |    1 +
 include/lv.h                     |    1 +
 include/lv_alloc.h               |    1 +
 include/lvm-exec.h               |    1 +
 include/lvm-file.h               |    1 +
 include/lvm-flock.h              |    1 +
 include/lvm-globals.h            |    1 +
 include/lvm-logging.h            |    1 +
 include/lvm-maths.h              |    1 +
 include/lvm-percent.h            |    1 +
 include/lvm-signal.h             |    1 +
 include/lvm-string.h             |    1 +
 include/lvm-wrappers.h           |    1 +
 include/lvm2app.h                |    1 +
 include/lvm2cmd.h                |    1 +
 include/lvmcache.h               |    1 +
 include/lvmetad-client.h         |    1 +
 include/lvmetad.h                |    1 +
 include/lvmlockd-client.h        |    1 +
 include/lvmlockd.h               |    1 +
 include/lvmnotify.h              |    1 +
 include/lvmpolld-client.h        |    1 +
 include/lvmpolld-protocol.h      |    1 +
 include/memlock.h                |    1 +
 include/metadata-exported.h      |    1 +
 include/metadata.h               |    1 +
 include/pogen.h                  |    1 +
 include/polldaemon.h             |    1 +
 include/polling_ops.h            |    1 +
 include/prop_common.h            |    1 +
 include/properties.h             |    1 +
 include/pv.h                     |    1 +
 include/pv_alloc.h               |    1 +
 include/report.h                 |    1 +
 include/segtype.h                |    1 +
 include/sharedlib.h              |    1 +
 include/str_list.h               |    1 +
 include/targets.h                |    1 +
 include/text_export.h            |    1 +
 include/text_import.h            |    1 +
 include/tool.h                   |    1 +
 include/toolcontext.h            |    1 +
 include/util.h                   |    1 +
 include/uuid.h                   |    1 +
 include/vg.h                     |    1 +
 include/xlate.h                  |    1 +
 make.tmpl.in                     |    6 +--
 86 files changed, 86 insertions(+), 110 deletions(-)

diff --git a/configure b/configure
index 63ca480..7ef73f0 100755
--- a/configure
+++ b/configure
@@ -15689,7 +15689,7 @@ _ACEOF
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile include/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/
 Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_h
 at.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile unit-test/Makefile tools/Makefile udev/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile include/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache
 _segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/
 lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile unit-test/Makefile tools/Makefile udev/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -16411,7 +16411,6 @@ do
     "conf/lvmlocal.conf") CONFIG_FILES="$CONFIG_FILES conf/lvmlocal.conf" ;;
     "conf/command_profile_template.profile") CONFIG_FILES="$CONFIG_FILES conf/command_profile_template.profile" ;;
     "conf/metadata_profile_template.profile") CONFIG_FILES="$CONFIG_FILES conf/metadata_profile_template.profile" ;;
-    "include/.symlinks") CONFIG_FILES="$CONFIG_FILES include/.symlinks" ;;
     "include/Makefile") CONFIG_FILES="$CONFIG_FILES include/Makefile" ;;
     "lib/Makefile") CONFIG_FILES="$CONFIG_FILES lib/Makefile" ;;
     "lib/format1/Makefile") CONFIG_FILES="$CONFIG_FILES lib/format1/Makefile" ;;
diff --git a/configure.in b/configure.in
index 461c21b..f65e35e 100644
--- a/configure.in
+++ b/configure.in
@@ -2194,7 +2194,6 @@ conf/example.conf
 conf/lvmlocal.conf
 conf/command_profile_template.profile
 conf/metadata_profile_template.profile
-include/.symlinks
 include/Makefile
 lib/Makefile
 lib/format1/Makefile
diff --git a/include/.gitignore b/include/.gitignore
index 4971e07..396884b 100644
--- a/include/.gitignore
+++ b/include/.gitignore
@@ -1,4 +1,2 @@
-.symlinks
-.symlinks_created
-
-*.h
+configure.h
+lvm-version.h
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
index b2571fd..e5c09b5 100644
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
+DISTCLEAN_TARGETS += configure.h lvm-version.h
diff --git a/include/activate.h b/include/activate.h
new file mode 120000
index 0000000..3c8d94a
--- /dev/null
+++ b/include/activate.h
@@ -0,0 +1 @@
+../lib/activate/activate.h
\ No newline at end of file
diff --git a/include/archiver.h b/include/archiver.h
new file mode 120000
index 0000000..bac9048
--- /dev/null
+++ b/include/archiver.h
@@ -0,0 +1 @@
+../lib/format_text/archiver.h
\ No newline at end of file
diff --git a/include/bcache.h b/include/bcache.h
new file mode 120000
index 0000000..5855f8d
--- /dev/null
+++ b/include/bcache.h
@@ -0,0 +1 @@
+../lib/device/bcache.h
\ No newline at end of file
diff --git a/include/btree.h b/include/btree.h
new file mode 120000
index 0000000..e45aee4
--- /dev/null
+++ b/include/btree.h
@@ -0,0 +1 @@
+../lib/datastruct/btree.h
\ No newline at end of file
diff --git a/include/clvm.h b/include/clvm.h
new file mode 120000
index 0000000..9740db4
--- /dev/null
+++ b/include/clvm.h
@@ -0,0 +1 @@
+../daemons/clvmd/clvm.h
\ No newline at end of file
diff --git a/include/config-util.h b/include/config-util.h
new file mode 120000
index 0000000..4b7b220
--- /dev/null
+++ b/include/config-util.h
@@ -0,0 +1 @@
+../libdaemon/client/config-util.h
\ No newline at end of file
diff --git a/include/config.h b/include/config.h
new file mode 120000
index 0000000..a733942
--- /dev/null
+++ b/include/config.h
@@ -0,0 +1 @@
+../lib/config/config.h
\ No newline at end of file
diff --git a/include/config_settings.h b/include/config_settings.h
new file mode 120000
index 0000000..407d594
--- /dev/null
+++ b/include/config_settings.h
@@ -0,0 +1 @@
+../lib/config/config_settings.h
\ No newline at end of file
diff --git a/include/crc.h b/include/crc.h
new file mode 120000
index 0000000..25c761a
--- /dev/null
+++ b/include/crc.h
@@ -0,0 +1 @@
+../lib/misc/crc.h
\ No newline at end of file
diff --git a/include/daemon-client.h b/include/daemon-client.h
new file mode 120000
index 0000000..7dbf53f
--- /dev/null
+++ b/include/daemon-client.h
@@ -0,0 +1 @@
+../libdaemon/client/daemon-client.h
\ No newline at end of file
diff --git a/include/daemon-io.h b/include/daemon-io.h
new file mode 120000
index 0000000..79612d9
--- /dev/null
+++ b/include/daemon-io.h
@@ -0,0 +1 @@
+../libdaemon/client/daemon-io.h
\ No newline at end of file
diff --git a/include/defaults.h b/include/defaults.h
new file mode 120000
index 0000000..c97f06f
--- /dev/null
+++ b/include/defaults.h
@@ -0,0 +1 @@
+../lib/config/defaults.h
\ No newline at end of file
diff --git a/include/dev-cache.h b/include/dev-cache.h
new file mode 120000
index 0000000..edb7395
--- /dev/null
+++ b/include/dev-cache.h
@@ -0,0 +1 @@
+../lib/device/dev-cache.h
\ No newline at end of file
diff --git a/include/dev-ext-udev-constants.h b/include/dev-ext-udev-constants.h
new file mode 120000
index 0000000..97258ef
--- /dev/null
+++ b/include/dev-ext-udev-constants.h
@@ -0,0 +1 @@
+../lib/device/dev-ext-udev-constants.h
\ No newline at end of file
diff --git a/include/dev-type.h b/include/dev-type.h
new file mode 120000
index 0000000..8082a76
--- /dev/null
+++ b/include/dev-type.h
@@ -0,0 +1 @@
+../lib/device/dev-type.h
\ No newline at end of file
diff --git a/include/device-types.h b/include/device-types.h
new file mode 120000
index 0000000..452a6fa
--- /dev/null
+++ b/include/device-types.h
@@ -0,0 +1 @@
+../lib/device/device-types.h
\ No newline at end of file
diff --git a/include/device.h b/include/device.h
new file mode 120000
index 0000000..ee365d9
--- /dev/null
+++ b/include/device.h
@@ -0,0 +1 @@
+../lib/device/device.h
\ No newline at end of file
diff --git a/include/display.h b/include/display.h
new file mode 120000
index 0000000..b614ede
--- /dev/null
+++ b/include/display.h
@@ -0,0 +1 @@
+../lib/display/display.h
\ No newline at end of file
diff --git a/include/dm-ioctl.h b/include/dm-ioctl.h
new file mode 120000
index 0000000..4acd5a5
--- /dev/null
+++ b/include/dm-ioctl.h
@@ -0,0 +1 @@
+../libdm/misc/dm-ioctl.h
\ No newline at end of file
diff --git a/include/dm-log-userspace.h b/include/dm-log-userspace.h
new file mode 120000
index 0000000..37c9fea
--- /dev/null
+++ b/include/dm-log-userspace.h
@@ -0,0 +1 @@
+../libdm/misc/dm-log-userspace.h
\ No newline at end of file
diff --git a/include/dm-logging.h b/include/dm-logging.h
new file mode 120000
index 0000000..2af311e
--- /dev/null
+++ b/include/dm-logging.h
@@ -0,0 +1 @@
+../libdm/misc/dm-logging.h
\ No newline at end of file
diff --git a/include/dmlib.h b/include/dmlib.h
new file mode 120000
index 0000000..6e99e60
--- /dev/null
+++ b/include/dmlib.h
@@ -0,0 +1 @@
+../libdm/misc/dmlib.h
\ No newline at end of file
diff --git a/include/filter.h b/include/filter.h
new file mode 120000
index 0000000..c22ea16
--- /dev/null
+++ b/include/filter.h
@@ -0,0 +1 @@
+../lib/filters/filter.h
\ No newline at end of file
diff --git a/include/format-text.h b/include/format-text.h
new file mode 120000
index 0000000..ca81b1d
--- /dev/null
+++ b/include/format-text.h
@@ -0,0 +1 @@
+../lib/format_text/format-text.h
\ No newline at end of file
diff --git a/include/format1.h b/include/format1.h
new file mode 120000
index 0000000..4e23bc9
--- /dev/null
+++ b/include/format1.h
@@ -0,0 +1 @@
+../lib/format1/format1.h
\ No newline at end of file
diff --git a/include/format_pool.h b/include/format_pool.h
new file mode 120000
index 0000000..7198a37
--- /dev/null
+++ b/include/format_pool.h
@@ -0,0 +1 @@
+../lib/format_pool/format_pool.h
\ No newline at end of file
diff --git a/include/intl.h b/include/intl.h
new file mode 120000
index 0000000..6db3a2b
--- /dev/null
+++ b/include/intl.h
@@ -0,0 +1 @@
+../lib/misc/intl.h
\ No newline at end of file
diff --git a/include/kdev_t.h b/include/kdev_t.h
new file mode 120000
index 0000000..1d04a72
--- /dev/null
+++ b/include/kdev_t.h
@@ -0,0 +1 @@
+../libdm/misc/kdev_t.h
\ No newline at end of file
diff --git a/include/label.h b/include/label.h
new file mode 120000
index 0000000..0af47ca
--- /dev/null
+++ b/include/label.h
@@ -0,0 +1 @@
+../lib/label/label.h
\ No newline at end of file
diff --git a/include/last-path-component.h b/include/last-path-component.h
new file mode 120000
index 0000000..58f8bad
--- /dev/null
+++ b/include/last-path-component.h
@@ -0,0 +1 @@
+../lib/misc/last-path-component.h
\ No newline at end of file
diff --git a/include/lib.h b/include/lib.h
new file mode 120000
index 0000000..912ac0c
--- /dev/null
+++ b/include/lib.h
@@ -0,0 +1 @@
+../lib/misc/lib.h
\ No newline at end of file
diff --git a/include/libdevmapper-event.h b/include/libdevmapper-event.h
new file mode 120000
index 0000000..a54561d
--- /dev/null
+++ b/include/libdevmapper-event.h
@@ -0,0 +1 @@
+../daemons/dmeventd/libdevmapper-event.h
\ No newline at end of file
diff --git a/include/libdevmapper.h b/include/libdevmapper.h
new file mode 120000
index 0000000..a88009b
--- /dev/null
+++ b/include/libdevmapper.h
@@ -0,0 +1 @@
+../libdm/libdevmapper.h
\ No newline at end of file
diff --git a/include/locking.h b/include/locking.h
new file mode 120000
index 0000000..6ea3343
--- /dev/null
+++ b/include/locking.h
@@ -0,0 +1 @@
+../lib/locking/locking.h
\ No newline at end of file
diff --git a/include/log.h b/include/log.h
new file mode 120000
index 0000000..245ac3d
--- /dev/null
+++ b/include/log.h
@@ -0,0 +1 @@
+../lib/log/log.h
\ No newline at end of file
diff --git a/include/lv.h b/include/lv.h
new file mode 120000
index 0000000..7cd7de6
--- /dev/null
+++ b/include/lv.h
@@ -0,0 +1 @@
+../lib/metadata/lv.h
\ No newline at end of file
diff --git a/include/lv_alloc.h b/include/lv_alloc.h
new file mode 120000
index 0000000..bbb691c
--- /dev/null
+++ b/include/lv_alloc.h
@@ -0,0 +1 @@
+../lib/metadata/lv_alloc.h
\ No newline at end of file
diff --git a/include/lvm-exec.h b/include/lvm-exec.h
new file mode 120000
index 0000000..5b5232a
--- /dev/null
+++ b/include/lvm-exec.h
@@ -0,0 +1 @@
+../lib/misc/lvm-exec.h
\ No newline at end of file
diff --git a/include/lvm-file.h b/include/lvm-file.h
new file mode 120000
index 0000000..bcb8288
--- /dev/null
+++ b/include/lvm-file.h
@@ -0,0 +1 @@
+../lib/misc/lvm-file.h
\ No newline at end of file
diff --git a/include/lvm-flock.h b/include/lvm-flock.h
new file mode 120000
index 0000000..e1ef682
--- /dev/null
+++ b/include/lvm-flock.h
@@ -0,0 +1 @@
+../lib/misc/lvm-flock.h
\ No newline at end of file
diff --git a/include/lvm-globals.h b/include/lvm-globals.h
new file mode 120000
index 0000000..767f63d
--- /dev/null
+++ b/include/lvm-globals.h
@@ -0,0 +1 @@
+../lib/misc/lvm-globals.h
\ No newline at end of file
diff --git a/include/lvm-logging.h b/include/lvm-logging.h
new file mode 120000
index 0000000..9236bad
--- /dev/null
+++ b/include/lvm-logging.h
@@ -0,0 +1 @@
+../lib/log/lvm-logging.h
\ No newline at end of file
diff --git a/include/lvm-maths.h b/include/lvm-maths.h
new file mode 120000
index 0000000..45a0815
--- /dev/null
+++ b/include/lvm-maths.h
@@ -0,0 +1 @@
+../lib/misc/lvm-maths.h
\ No newline at end of file
diff --git a/include/lvm-percent.h b/include/lvm-percent.h
new file mode 120000
index 0000000..3160573
--- /dev/null
+++ b/include/lvm-percent.h
@@ -0,0 +1 @@
+../lib/misc/lvm-percent.h
\ No newline at end of file
diff --git a/include/lvm-signal.h b/include/lvm-signal.h
new file mode 120000
index 0000000..d987311
--- /dev/null
+++ b/include/lvm-signal.h
@@ -0,0 +1 @@
+../lib/misc/lvm-signal.h
\ No newline at end of file
diff --git a/include/lvm-string.h b/include/lvm-string.h
new file mode 120000
index 0000000..f727b1e
--- /dev/null
+++ b/include/lvm-string.h
@@ -0,0 +1 @@
+../lib/misc/lvm-string.h
\ No newline at end of file
diff --git a/include/lvm-wrappers.h b/include/lvm-wrappers.h
new file mode 120000
index 0000000..424679a
--- /dev/null
+++ b/include/lvm-wrappers.h
@@ -0,0 +1 @@
+../lib/misc/lvm-wrappers.h
\ No newline at end of file
diff --git a/include/lvm2app.h b/include/lvm2app.h
new file mode 120000
index 0000000..17f2006
--- /dev/null
+++ b/include/lvm2app.h
@@ -0,0 +1 @@
+../liblvm/lvm2app.h
\ No newline at end of file
diff --git a/include/lvm2cmd.h b/include/lvm2cmd.h
new file mode 120000
index 0000000..9d27330
--- /dev/null
+++ b/include/lvm2cmd.h
@@ -0,0 +1 @@
+../tools/lvm2cmd.h
\ No newline at end of file
diff --git a/include/lvmcache.h b/include/lvmcache.h
new file mode 120000
index 0000000..ba1399c
--- /dev/null
+++ b/include/lvmcache.h
@@ -0,0 +1 @@
+../lib/cache/lvmcache.h
\ No newline at end of file
diff --git a/include/lvmetad-client.h b/include/lvmetad-client.h
new file mode 120000
index 0000000..54b8f1f
--- /dev/null
+++ b/include/lvmetad-client.h
@@ -0,0 +1 @@
+../daemons/lvmetad/lvmetad-client.h
\ No newline at end of file
diff --git a/include/lvmetad.h b/include/lvmetad.h
new file mode 120000
index 0000000..65c561c
--- /dev/null
+++ b/include/lvmetad.h
@@ -0,0 +1 @@
+../lib/cache/lvmetad.h
\ No newline at end of file
diff --git a/include/lvmlockd-client.h b/include/lvmlockd-client.h
new file mode 120000
index 0000000..23291c2
--- /dev/null
+++ b/include/lvmlockd-client.h
@@ -0,0 +1 @@
+../daemons/lvmlockd/lvmlockd-client.h
\ No newline at end of file
diff --git a/include/lvmlockd.h b/include/lvmlockd.h
new file mode 120000
index 0000000..1fe51a6
--- /dev/null
+++ b/include/lvmlockd.h
@@ -0,0 +1 @@
+../lib/locking/lvmlockd.h
\ No newline at end of file
diff --git a/include/lvmnotify.h b/include/lvmnotify.h
new file mode 120000
index 0000000..7c624a7
--- /dev/null
+++ b/include/lvmnotify.h
@@ -0,0 +1 @@
+../lib/notify/lvmnotify.h
\ No newline at end of file
diff --git a/include/lvmpolld-client.h b/include/lvmpolld-client.h
new file mode 120000
index 0000000..78de8c6
--- /dev/null
+++ b/include/lvmpolld-client.h
@@ -0,0 +1 @@
+../lib/lvmpolld/lvmpolld-client.h
\ No newline at end of file
diff --git a/include/lvmpolld-protocol.h b/include/lvmpolld-protocol.h
new file mode 120000
index 0000000..5f5ecb5
--- /dev/null
+++ b/include/lvmpolld-protocol.h
@@ -0,0 +1 @@
+../daemons/lvmpolld/lvmpolld-protocol.h
\ No newline at end of file
diff --git a/include/memlock.h b/include/memlock.h
new file mode 120000
index 0000000..8d9bc4b
--- /dev/null
+++ b/include/memlock.h
@@ -0,0 +1 @@
+../lib/mm/memlock.h
\ No newline at end of file
diff --git a/include/metadata-exported.h b/include/metadata-exported.h
new file mode 120000
index 0000000..570ab36
--- /dev/null
+++ b/include/metadata-exported.h
@@ -0,0 +1 @@
+../lib/metadata/metadata-exported.h
\ No newline at end of file
diff --git a/include/metadata.h b/include/metadata.h
new file mode 120000
index 0000000..94fbad4
--- /dev/null
+++ b/include/metadata.h
@@ -0,0 +1 @@
+../lib/metadata/metadata.h
\ No newline at end of file
diff --git a/include/pogen.h b/include/pogen.h
new file mode 120000
index 0000000..9721487
--- /dev/null
+++ b/include/pogen.h
@@ -0,0 +1 @@
+../po/pogen.h
\ No newline at end of file
diff --git a/include/polldaemon.h b/include/polldaemon.h
new file mode 120000
index 0000000..7816b0b
--- /dev/null
+++ b/include/polldaemon.h
@@ -0,0 +1 @@
+../lib/lvmpolld/polldaemon.h
\ No newline at end of file
diff --git a/include/polling_ops.h b/include/polling_ops.h
new file mode 120000
index 0000000..4ec0a30
--- /dev/null
+++ b/include/polling_ops.h
@@ -0,0 +1 @@
+../daemons/lvmpolld/polling_ops.h
\ No newline at end of file
diff --git a/include/prop_common.h b/include/prop_common.h
new file mode 120000
index 0000000..40b570e
--- /dev/null
+++ b/include/prop_common.h
@@ -0,0 +1 @@
+../lib/properties/prop_common.h
\ No newline at end of file
diff --git a/include/properties.h b/include/properties.h
new file mode 120000
index 0000000..f34e413
--- /dev/null
+++ b/include/properties.h
@@ -0,0 +1 @@
+../lib/report/properties.h
\ No newline at end of file
diff --git a/include/pv.h b/include/pv.h
new file mode 120000
index 0000000..dd3267b
--- /dev/null
+++ b/include/pv.h
@@ -0,0 +1 @@
+../lib/metadata/pv.h
\ No newline at end of file
diff --git a/include/pv_alloc.h b/include/pv_alloc.h
new file mode 120000
index 0000000..2364a8d
--- /dev/null
+++ b/include/pv_alloc.h
@@ -0,0 +1 @@
+../lib/metadata/pv_alloc.h
\ No newline at end of file
diff --git a/include/report.h b/include/report.h
new file mode 120000
index 0000000..339bf85
--- /dev/null
+++ b/include/report.h
@@ -0,0 +1 @@
+../lib/report/report.h
\ No newline at end of file
diff --git a/include/segtype.h b/include/segtype.h
new file mode 120000
index 0000000..6b69bfd
--- /dev/null
+++ b/include/segtype.h
@@ -0,0 +1 @@
+../lib/metadata/segtype.h
\ No newline at end of file
diff --git a/include/sharedlib.h b/include/sharedlib.h
new file mode 120000
index 0000000..dacb595
--- /dev/null
+++ b/include/sharedlib.h
@@ -0,0 +1 @@
+../lib/misc/sharedlib.h
\ No newline at end of file
diff --git a/include/str_list.h b/include/str_list.h
new file mode 120000
index 0000000..dd91b1d
--- /dev/null
+++ b/include/str_list.h
@@ -0,0 +1 @@
+../lib/datastruct/str_list.h
\ No newline at end of file
diff --git a/include/targets.h b/include/targets.h
new file mode 120000
index 0000000..a63c09a
--- /dev/null
+++ b/include/targets.h
@@ -0,0 +1 @@
+../lib/activate/targets.h
\ No newline at end of file
diff --git a/include/text_export.h b/include/text_export.h
new file mode 120000
index 0000000..4ef5b96
--- /dev/null
+++ b/include/text_export.h
@@ -0,0 +1 @@
+../lib/format_text/text_export.h
\ No newline at end of file
diff --git a/include/text_import.h b/include/text_import.h
new file mode 120000
index 0000000..33509d3
--- /dev/null
+++ b/include/text_import.h
@@ -0,0 +1 @@
+../lib/format_text/text_import.h
\ No newline at end of file
diff --git a/include/tool.h b/include/tool.h
new file mode 120000
index 0000000..d8b2651
--- /dev/null
+++ b/include/tool.h
@@ -0,0 +1 @@
+../tools/tool.h
\ No newline at end of file
diff --git a/include/toolcontext.h b/include/toolcontext.h
new file mode 120000
index 0000000..c26097f
--- /dev/null
+++ b/include/toolcontext.h
@@ -0,0 +1 @@
+../lib/commands/toolcontext.h
\ No newline at end of file
diff --git a/include/util.h b/include/util.h
new file mode 120000
index 0000000..d9ca624
--- /dev/null
+++ b/include/util.h
@@ -0,0 +1 @@
+../lib/misc/util.h
\ No newline at end of file
diff --git a/include/uuid.h b/include/uuid.h
new file mode 120000
index 0000000..1b70f6e
--- /dev/null
+++ b/include/uuid.h
@@ -0,0 +1 @@
+../lib/uuid/uuid.h
\ No newline at end of file
diff --git a/include/vg.h b/include/vg.h
new file mode 120000
index 0000000..3f705b2
--- /dev/null
+++ b/include/vg.h
@@ -0,0 +1 @@
+../lib/metadata/vg.h
\ No newline at end of file
diff --git a/include/xlate.h b/include/xlate.h
new file mode 120000
index 0000000..4ab1c83
--- /dev/null
+++ b/include/xlate.h
@@ -0,0 +1 @@
+../lib/mm/xlate.h
\ No newline@end of file
diff --git a/make.tmpl.in b/make.tmpl.in
index 75134ca..f9b3d0e 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -309,10 +309,8 @@ LIB_VERSION_APP := $(shell $(AWK) -F '[(). ]' '{printf "%s.%s",$$1,$$4}' $(top_s
 
 INCLUDES += -I$(srcdir) -I$(top_builddir)/include
 
-INC_LNS = $(top_builddir)/include/.symlinks_created
-
 DEPS = $(top_builddir)/make.tmpl $(top_srcdir)/VERSION \
-       $(top_builddir)/Makefile $(INC_LNS)
+       $(top_builddir)/Makefile
 
 OBJECTS = $(SOURCES:%.c=%.o) $(CXXSOURCES:%.cpp=%.o)
 POTFILES = $(SOURCES:%.c=%.pot)
@@ -505,7 +503,7 @@ $(LIB_STATIC): $(OBJECTS)
 	$(Q) $(RM) $@
 	$(Q) $(AR) rsv $@ $(OBJECTS) > /dev/null
 
-%.d: %.c $(INC_LNS)
+%.d: %.c
 	@echo "    [DEP] $<"
 	$(Q) $(MKDIR_P) $(dir $@); \
 	set -e; \


