From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  8 Oct 2013 11:42:50 +0000 (UTC)
Subject: master - udev: add support for "NOSCAN" flag
Message-ID: <20131008114250.87E0B60F40@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6a80d7538110405dc4f8fc5fe5ae462b32dfe562
Commit:        6a80d7538110405dc4f8fc5fe5ae462b32dfe562
Parent:        57d2daff6e6f8758fbfe5758b283fdb6d43e713a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Oct 8 13:33:28 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Oct 8 13:42:23 2013 +0200

udev: add support for "NOSCAN" flag

Recognize DM_SUBSYSTEM_UDEV_FLAG0 which for LVM is the "LVM_NOSCAN"
flag that causes the scanning to be skipped (mainly blkid) and
also directs all the foreign rules to be skipped as well.

Important thing here is that the "watch" udev rules is still set
as well as the /dev/disk/by-id content created (which does not
require any scanning to be done). Also, the flag is dropped on
any subsequent event and scanning done...
---
 WHATS_NEW                     |    1 +
 udev/11-dm-lvm.rules.in       |   15 +++++++++++++++
 udev/13-dm-disk.rules.in      |    3 ++-
 udev/69-dm-lvm-metad.rules.in |    2 ++
 4 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5957924..cd239dd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.104
 ===================================
+  Recognize new flag to skip udev scanning in udev rules and act appropriately.
   Add support for flagging an LV to skip udev scanning during activation.
   Improve message when unable to change discards setting on active thin pool.
 
diff --git a/udev/11-dm-lvm.rules.in b/udev/11-dm-lvm.rules.in
index f21d0aa..5032280 100644
--- a/udev/11-dm-lvm.rules.in
+++ b/udev/11-dm-lvm.rules.in
@@ -20,6 +20,21 @@ ENV{DM_UUID}!="LVM-?*", GOTO="lvm_end"
 # Use DM name and split it up into its VG/LV/layer constituents.
 IMPORT{program}="(DM_EXEC)/dmsetup splitname --nameprefixes --noheadings --rows $env{DM_NAME}"
 
+# DM_SUBSYSTEM_UDEV_FLAG0 is the 'NOSCAN' flag for LVM subsystem.
+# This flag is used to temporarily disable selected rules to prevent any
+# processing or scanning done on the LVM volume before LVM has any chance
+# to zero any stale metadata found within the LV data area. Such stale
+# metadata could cause false claim of the LV device, keeping it open etc.
+#
+# If the NOSCAN flag is present, backup selected existing flags used to
+# disable rules, then set them firmly so those selected rules are surely skipped.
+# Restore these flags once the NOSCAN flag is dropped (which is normally any
+# uevent that follows for this LV, even an artificially generated one).
+ENV{DM_SUBSYSTEM_UDEV_FLAG0}=="1", ENV{DM_NOSCAN}="1", ENV{DM_DISABLE_OTHER_RULES_FLAG_OLD}="$env{DM_UDEV_DISABLE_OTHER_RULES_FLAG}", ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}="1"
+ENV{DM_SUBSYSTEM_UDEV_FLAG0}!="1", IMPORT{db}="DM_NOSCAN", IMPORT{db}="DM_DISABLE_OTHER_RULES_FLAG_OLD"
+ENV{DM_SUBSYSTEM_UDEV_FLAG0}!="1", ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}="$env{DM_DISABLE_OTHER_RULES_FLAG_OLD}", \
+				   ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG_OLD}="", ENV{DM_NOSCAN}=""
+
 ENV{DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG}=="1", GOTO="lvm_end"
 
 OPTIONS+="event_timeout=180"
diff --git a/udev/13-dm-disk.rules.in b/udev/13-dm-disk.rules.in
index 1920260..4b64dd6 100644
--- a/udev/13-dm-disk.rules.in
+++ b/udev/13-dm-disk.rules.in
@@ -18,6 +18,7 @@ SYMLINK+="disk/by-id/dm-name-$env{DM_NAME}"
 ENV{DM_UUID}=="?*", SYMLINK+="disk/by-id/dm-uuid-$env{DM_UUID}"
 
 ENV{DM_SUSPENDED}=="1", GOTO="dm_end"
+ENV{DM_NOSCAN}=="1", GOTO="dm_watch"
 
 (BLKID_RULE)
 ENV{DM_UDEV_LOW_PRIORITY_FLAG}=="1", OPTIONS="link_priority=-100"
@@ -32,7 +33,7 @@ ENV{ID_FS_USAGE}=="filesystem|other", ENV{ID_FS_LABEL_ENC}=="?*", SYMLINK+="disk
 # (like creating a filesystem, changing filesystem label etc.).
 #
 # But let's use this until we have something better...
-
+LABEL="dm_watch"
 OPTIONS+="watch"
 
 LABEL="dm_end"
diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index ba43396..3303f4d 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -17,6 +17,8 @@
 SUBSYSTEM!="block", GOTO="lvm_end"
 (LVM_EXEC_RULE)
 
+ENV{DM_NOSCAN}=="1", GOTO="lvm_end"
+
 # If the PV label got lost, inform lvmetad immediately.
 # Detect the lost PV label by comparing previous ID_FS_TYPE value with current one.
 ENV{.ID_FS_TYPE_NEW}="$env{ID_FS_TYPE}"


