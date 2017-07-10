From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Mon, 10 Jul 2017 06:45:44 -0400
Subject: master - udev: also create /dev/disk/by-part{label, uuid} and gpt-auto-root symlinks
Message-ID: <201707101045.v6AAjiq9003987@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c48149cf80c6582c2369bc7f8a33d794021d9dae
Commit:        c48149cf80c6582c2369bc7f8a33d794021d9dae
Parent:        cf3a6bbbe881d9a4ba6d108304f0c07ee6cd8d1a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jul 10 12:35:53 2017 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jul 10 12:36:39 2017 +0200

udev: also create /dev/disk/by-part{label,uuid} and gpt-auto-root symlinks

The blkid we call in 13-dm-disk.rules also returns identifiers for
partitions based on which the /dev/disk/by-part{uuid,label} and
gpt-auto-root symlinks should be created in the same manner as we
already create symlinks for filesystem labels and uuids.

This is because we handle blkid calls and symlink creation under
/dev/disk ourselves in our 13-dm-disk.rules for device-mapper devices
for us to have more control over this process.

See also https://lists.freedesktop.org/archives/systemd-devel/2017-July/039220.html
and original report http://tracker.ceph.com/issues/19489 for
the exact case where these symlinks were missing.
---
 WHATS_NEW_DM             |    1 +
 udev/13-dm-disk.rules.in |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 923f25d..40fb4f4 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.142 -
 =================================
+  Create /dev/disk/by-part{uuid,label} and gpt-auto-root symlinks with udev.
 
 Version 1.02.141 - 28th June 2017
 =================================
diff --git a/udev/13-dm-disk.rules.in b/udev/13-dm-disk.rules.in
index 4b64dd6..5355810 100644
--- a/udev/13-dm-disk.rules.in
+++ b/udev/13-dm-disk.rules.in
@@ -24,6 +24,9 @@ ENV{DM_NOSCAN}=="1", GOTO="dm_watch"
 ENV{DM_UDEV_LOW_PRIORITY_FLAG}=="1", OPTIONS="link_priority=-100"
 ENV{ID_FS_USAGE}=="filesystem|other|crypto", ENV{ID_FS_UUID_ENC}=="?*", SYMLINK+="disk/by-uuid/$env{ID_FS_UUID_ENC}"
 ENV{ID_FS_USAGE}=="filesystem|other", ENV{ID_FS_LABEL_ENC}=="?*", SYMLINK+="disk/by-label/$env{ID_FS_LABEL_ENC}"
+ENV{ID_PART_ENTRY_UUID}=="?*", SYMLINK+="disk/by-partuuid/$env{ID_PART_ENTRY_UUID}"
+ENV{ID_PART_ENTRY_SCHEME}=="gpt", ENV{ID_PART_ENTRY_NAME}=="?*", SYMLINK+="disk/by-partlabel/$env{ID_PART_ENTRY_NAME}"
+ENV{ID_PART_ENTRY_SCHEME}=="gpt", ENV{ID_PART_GPT_AUTO_ROOT}=="1", SYMLINK+="gpt-auto-root"
 
 # Add inotify watch to track changes on this device.
 # Using the watch rule is not optimal - it generates a lot of spurious


