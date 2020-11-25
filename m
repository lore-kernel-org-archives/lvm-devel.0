From: David Teigland <teigland@sourceware.org>
Date: Wed, 25 Nov 2020 22:58:35 +0000 (GMT)
Subject: main - udev rule: remove lvmetad comments
Message-ID: <20201125225835.89D993857022@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=10a095a58b3c564d54ded4d59c2286546fc83b74
Commit:        10a095a58b3c564d54ded4d59c2286546fc83b74
Parent:        b68141a49d94db7fa98beb345bc5a583d874e9e7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Nov 25 16:57:54 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 25 16:57:54 2020 -0600

udev rule: remove lvmetad comments

---
 udev/69-dm-lvm-metad.rules.in | 15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index d51006496..78f506520 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -4,14 +4,7 @@
 
 # Udev rules for LVM.
 #
-# Scan all block devices having a PV label for LVM metadata.
-# Store this information in LVMetaD (the LVM metadata daemon) and maintain LVM
-# metadata state for improved performance by avoiding further scans while
-# running subsequent LVM commands or while using lvm2app library.
-# Also, notify LVMetaD about any relevant block device removal.
-#
-# This rule is essential for having the information in LVMetaD up-to-date.
-# It also requires blkid to be called on block devices before so only devices
+# This rule requires blkid to be called on block devices before so only devices
 # used as LVM PVs are processed (ID_FS_TYPE="LVM2_member" or "LVM1_member").
 
 SUBSYSTEM!="block", GOTO="lvm_end"
@@ -19,8 +12,7 @@ SUBSYSTEM!="block", GOTO="lvm_end"
 
 ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}=="1", GOTO="lvm_end"
 
-# If the PV label got lost, inform lvmetad immediately.
-# Detect the lost PV label by comparing previous ID_FS_TYPE value with current one.
+# Detect removed PV label by comparing previous ID_FS_TYPE value with current one.
 ENV{.ID_FS_TYPE_NEW}="$env{ID_FS_TYPE}"
 IMPORT{db}="ID_FS_TYPE"
 ENV{ID_FS_TYPE}=="LVM2_member|LVM1_member", ENV{.ID_FS_TYPE_NEW}!="LVM2_member|LVM1_member", ENV{LVM_PV_GONE}="1"
@@ -31,7 +23,6 @@ ENV{LVM_PV_GONE}=="1", GOTO="lvm_scan"
 ENV{ID_FS_TYPE}!="LVM2_member|LVM1_member", GOTO="lvm_end"
 ENV{DM_MULTIPATH_DEVICE_PATH}=="1", GOTO="lvm_end"
 
-# Inform lvmetad about any PV that is gone.
 ACTION=="remove", GOTO="lvm_scan"
 
 # Create /dev/disk/by-id/lvm-pv-uuid-<PV_UUID> symlink for each PV
@@ -69,7 +60,6 @@ ENV{LVM_LOOP_PV_ACTIVATED}!="1", ENV{SYSTEMD_READY}="0"
 GOTO="lvm_end"
 
 # If the PV is not a special device listed above, scan only if necessary.
-# For "direct_pvscan" mode (see below), this means run rules only an ADD events.
 # For "systemd_background" mode, systemd takes care of this by activating
 # the lvm2-pvscan at .service only once.
 LABEL="next"
@@ -113,6 +103,7 @@ ENV{SYSTEMD_ALIAS}="/dev/block/$major:$minor"
 ENV{SYSTEMD_WANTS}+="lvm2-pvscan@$major:$minor.service"
 GOTO="lvm_end"
 
+# FIXME: this mode is not used and should be removed.
 LABEL="direct_pvscan"
 
 # The table below summarises the situations in which we reach the LABEL="lvm_scan"


