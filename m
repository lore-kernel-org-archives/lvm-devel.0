From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 16 Nov 2015 00:17:14 +0000 (UTC)
Subject: master - cleanup: just alphabetically sort links
Message-ID: <20151116001714.9587060D9C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0f4d96f1bd7c30e29cd9d10b555d4ce0b553f5b3
Commit:        0f4d96f1bd7c30e29cd9d10b555d4ce0b553f5b3
Parent:        dccbc3b621cdac035802cb9f60438a389acadcad
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 14 22:14:37 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 16 01:16:11 2015 +0100

cleanup: just alphabetically sort links

---
 include/.symlinks.in |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/.symlinks.in b/include/.symlinks.in
index 9b97eb4..98d6804 100644
--- a/include/.symlinks.in
+++ b/include/.symlinks.in
@@ -1,15 +1,13 @@
 @top_srcdir@/daemons/clvmd/clvm.h
 @top_srcdir@/daemons/dmeventd/libdevmapper-event.h
 @top_srcdir@/daemons/lvmetad/lvmetad-client.h
+ at top_srcdir@/daemons/lvmlockd/lvmlockd-client.h
 @top_srcdir@/daemons/lvmpolld/lvmpolld-protocol.h
 @top_srcdir@/daemons/lvmpolld/polling_ops.h
- at top_srcdir@/daemons/lvmlockd/lvmlockd-client.h
- at top_srcdir@/liblvm/lvm2app.h
 @top_srcdir@/lib/activate/activate.h
 @top_srcdir@/lib/activate/targets.h
 @top_srcdir@/lib/cache/lvmcache.h
 @top_srcdir@/lib/cache/lvmetad.h
- at top_srcdir@/lib/locking/lvmlockd.h
 @top_srcdir@/lib/commands/toolcontext.h
 @top_srcdir@/lib/config/config.h
 @top_srcdir@/lib/config/config_settings.h
@@ -19,8 +17,8 @@
 @top_srcdir@/lib/device/dev-cache.h
 @top_srcdir@/lib/device/dev-ext-udev-constants.h
 @top_srcdir@/lib/device/dev-type.h
- at top_srcdir@/lib/device/device.h
 @top_srcdir@/lib/device/device-types.h
+ at top_srcdir@/lib/device/device.h
 @top_srcdir@/lib/display/display.h
 @top_srcdir@/lib/filters/filter.h
 @top_srcdir@/lib/format1/format1.h
@@ -31,20 +29,19 @@
 @top_srcdir@/lib/format_text/text_import.h
 @top_srcdir@/lib/label/label.h
 @top_srcdir@/lib/locking/locking.h
+ at top_srcdir@/lib/locking/lvmlockd.h
 @top_srcdir@/lib/log/log.h
 @top_srcdir@/lib/log/lvm-logging.h
 @top_srcdir@/lib/lvmpolld/lvmpolld-client.h
 @top_srcdir@/lib/lvmpolld/polldaemon.h
 @top_srcdir@/lib/metadata/lv.h
 @top_srcdir@/lib/metadata/lv_alloc.h
- at top_srcdir@/lib/metadata/metadata.h
 @top_srcdir@/lib/metadata/metadata-exported.h
+ at top_srcdir@/lib/metadata/metadata.h
 @top_srcdir@/lib/metadata/pv.h
 @top_srcdir@/lib/metadata/pv_alloc.h
 @top_srcdir@/lib/metadata/segtype.h
 @top_srcdir@/lib/metadata/vg.h
- at top_srcdir@/lib/mm/memlock.h
- at top_srcdir@/lib/mm/xlate.h
 @top_srcdir@/lib/misc/crc.h
 @top_srcdir@/lib/misc/intl.h
 @top_srcdir@/lib/misc/last-path-component.h
@@ -53,25 +50,28 @@
 @top_srcdir@/lib/misc/lvm-file.h
 @top_srcdir@/lib/misc/lvm-flock.h
 @top_srcdir@/lib/misc/lvm-globals.h
+ at top_srcdir@/lib/misc/lvm-percent.h
 @top_srcdir@/lib/misc/lvm-signal.h
 @top_srcdir@/lib/misc/lvm-string.h
- at top_srcdir@/lib/misc/lvm-percent.h
 @top_srcdir@/lib/misc/lvm-wrappers.h
 @top_srcdir@/lib/misc/sharedlib.h
 @top_srcdir@/lib/misc/util.h
+ at top_srcdir@/lib/mm/memlock.h
+ at top_srcdir@/lib/mm/xlate.h
 @top_srcdir@/lib/properties/prop_common.h
 @top_srcdir@/lib/report/properties.h
 @top_srcdir@/lib/report/report.h
 @top_srcdir@/lib/uuid/uuid.h
+ at top_srcdir@/libdaemon/client/config-util.h
 @top_srcdir@/libdaemon/client/daemon-client.h
 @top_srcdir@/libdaemon/client/daemon-io.h
- at top_srcdir@/libdaemon/client/config-util.h
 @top_srcdir@/libdm/libdevmapper.h
 @top_srcdir@/libdm/misc/dm-ioctl.h
- at top_srcdir@/libdm/misc/dm-logging.h
 @top_srcdir@/libdm/misc/dm-log-userspace.h
+ at top_srcdir@/libdm/misc/dm-logging.h
 @top_srcdir@/libdm/misc/dmlib.h
 @top_srcdir@/libdm/misc/kdev_t.h
+ at top_srcdir@/liblvm/lvm2app.h
 @top_srcdir@/po/pogen.h
 @top_srcdir@/tools/lvm2cmd.h
 @top_srcdir@/tools/tool.h


