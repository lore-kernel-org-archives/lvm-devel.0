From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu,  9 Feb 2023 20:40:50 +0000 (GMT)
Subject: rhel-9.2.0 - udev: import previous results of blkid when in suspended state
Message-ID: <20230209204050.219333858C74@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=285c766877b54b24234f84c313bb5806c0dcfa21
Commit:        285c766877b54b24234f84c313bb5806c0dcfa21
Parent:        fba3614c3ed596b99d8adf2fe6c60886db10b2c0
Author:        Yu Watanabe <watanabe.yu+github@gmail.com>
AuthorDate:    Thu Feb 2 00:28:12 2023 +0900
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Feb 9 17:06:18 2023 +0100

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
(cherry picked from commit 94f77a4d8d9737fca05fb4e451678ec440c68670)
---
 WHATS_NEW_DM             |  4 ++++
 udev/13-dm-disk.rules.in | 14 ++++++++++++--
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index f676ff7e1..c129c7f8a 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,7 @@
+Version 1.02.191 - 
+=====================================
+  Import previous ID_FS_* udev records in 13-dm-disk.rules for suspended DM dev.
+
 Version 1.02.187 - 10th November 2022
 =====================================
   Add DM_REPORT_GROUP_JSON_STD for more JSON standard compliant output format.
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

