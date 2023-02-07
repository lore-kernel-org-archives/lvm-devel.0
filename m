From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Tue,  7 Feb 2023 08:38:35 +0000 (GMT)
Subject: main - udev: import previous results of blkid when in suspended state
Message-ID: <20230207083835.2BE053858D1E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=94f77a4d8d9737fca05fb4e451678ec440c68670
Commit:        94f77a4d8d9737fca05fb4e451678ec440c68670
Parent:        dc99f0def17b936f95c63612a56ae2a6ae81db0e
Author:        Yu Watanabe <watanabe.yu+github@gmail.com>
AuthorDate:    Thu Feb 2 00:28:12 2023 +0900
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 7 09:37:27 2023 +0100

udev: import previous results of blkid when in suspended state

Follow-up for e10f67e91728f1e576803df884049ecbd92874d0.

The commit e10f67e91728f1e576803df884049ecbd92874d0 tries to keep device
node symlinks even if the device is in the suspended state. However,
necessary properties that may previously obtained by the blkid command
were not imported at least in the .rules file. So, unless ID_FS_xyz
properties are imported by another earlier .rules file, the device node
symlinks are still lost when event is processed in the suspended state.

Let's explicitly import the necessary properties.

RHBZ: https://bugzilla.redhat.com/show_bug.cgi?id=2158628
GHPR: https://github.com/lvmteam/lvm2/pull/105
---
 WHATS_NEW_DM             |  1 +
 udev/13-dm-disk.rules.in | 14 ++++++++++++--
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 43bf62a29..020efe6f4 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.191 - 
 =====================================
+  Import previous ID_FS_* udev records in 13-dm-disk.rules for suspended DM dev.
   Remove NAME="mapper/control" rule from 10-dm.rules to avoid udev warnings.
 
 Version 1.02.189 - 22nd December 2022
diff --git a/udev/13-dm-disk.rules.in b/udev/13-dm-disk.rules.in
index 5cc08121e..dca00bc01 100644
--- a/udev/13-dm-disk.rules.in
+++ b/udev/13-dm-disk.rules.in
@@ -17,12 +17,22 @@ ENV{DM_UDEV_DISABLE_DISK_RULES_FLAG}=="1", GOTO="dm_end"
 SYMLINK+="disk/by-id/dm-name-$env{DM_NAME}"
 ENV{DM_UUID}=="?*", SYMLINK+="disk/by-id/dm-uuid-$env{DM_UUID}"
 
-ENV{DM_SUSPENDED}=="1", ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}=="1", GOTO="dm_link"
-ENV{DM_NOSCAN}=="1", ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}=="1", GOTO="dm_link"
+ENV{DM_SUSPENDED}=="1", ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}=="1", GOTO="dm_import"
+ENV{DM_NOSCAN}=="1", ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}=="1", GOTO="dm_import"
 ENV{DM_SUSPENDED}=="1", GOTO="dm_end"
 ENV{DM_NOSCAN}=="1", GOTO="dm_watch"
 
 (BLKID_RULE)
+GOTO="dm_link"
+
+LABEL="dm_import"
+IMPORT{db}="ID_FS_USAGE"
+IMPORT{db}="ID_FS_UUID_ENC"
+IMPORT{db}="ID_FS_LABEL_ENC"
+IMPORT{db}="ID_PART_ENTRY_NAME"
+IMPORT{db}="ID_PART_ENTRY_UUID"
+IMPORT{db}="ID_PART_ENTRY_SCHEME"
+IMPORT{db}="ID_PART_GPT_AUTO_ROOT"
 
 LABEL="dm_link"
 ENV{DM_UDEV_LOW_PRIORITY_FLAG}=="1", OPTIONS="link_priority=-100"

