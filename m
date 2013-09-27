From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 27 Sep 2013 13:38:42 +0000 (UTC)
Subject: master - udev: fix 3min udev timeout so that it is applied for all LVM volumes
Message-ID: <20130927133843.020B960DB9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e4c7236c07056ddc9af3ba6ad2314d649d6814f9
Commit:        e4c7236c07056ddc9af3ba6ad2314d649d6814f9
Parent:        b4637bd298a7a12e0ce9f15104d41158b96cb642
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Sep 27 15:37:16 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Sep 27 15:37:16 2013 +0200

udev: fix 3min udev timeout so that it is applied for all LVM volumes

The timeout should be set before any volume skipping.
---
 WHATS_NEW               |    1 +
 udev/11-dm-lvm.rules.in |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3a307c9..b813eb6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.103 - 
 ======================================
+  Fix 3min udev timeout so that it is applied for all LVM volumes.
   Fix RAID calculation for sufficient allocatable space.
   Conversion from linear to mirror or RAID1 now honors mirror_segtype_default.
   Add thin-performance configuration profile.
diff --git a/udev/11-dm-lvm.rules.in b/udev/11-dm-lvm.rules.in
index 90804f3..f21d0aa 100644
--- a/udev/11-dm-lvm.rules.in
+++ b/udev/11-dm-lvm.rules.in
@@ -22,6 +22,8 @@ IMPORT{program}="(DM_EXEC)/dmsetup splitname --nameprefixes --noheadings --rows
 
 ENV{DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG}=="1", GOTO="lvm_end"
 
+OPTIONS+="event_timeout=180"
+
 # Do not create symlinks for inappropriate subdevices.
 ENV{DM_LV_NAME}=="pvmove?*|?*_vorigin", GOTO="lvm_disable"
 ENV{DM_LV_LAYER}=="?*", GOTO="lvm_disable"
@@ -29,8 +31,6 @@ ENV{DM_LV_LAYER}=="?*", GOTO="lvm_disable"
 # Create symlinks for top-level devices only.
 ENV{DM_VG_NAME}=="?*", ENV{DM_LV_NAME}=="?*", SYMLINK+="$env{DM_VG_NAME}/$env{DM_LV_NAME}", GOTO="lvm_end"
 
-OPTIONS+="event_timeout=180"
-
 LABEL="lvm_disable"
 ENV{DM_UDEV_DISABLE_DISK_RULES_FLAG}="1"
 ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}="1"


