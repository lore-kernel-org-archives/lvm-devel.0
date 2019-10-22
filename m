From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 22 Oct 2019 07:41:39 -0400
Subject: master - dm: fix compilation of dmsetup
Message-ID: <201910221141.x9MBfdk7025787@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3e01ff2783505f9b64f273fb492ee88e26afb568
Commit:        3e01ff2783505f9b64f273fb492ee88e26afb568
Parent:        65efacd0e077f61842cf3bf9ff1fc42230e08947
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Oct 21 16:31:53 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 22 13:39:45 2019 +0200

dm: fix compilation of dmsetup

Fix: 889c88e9dab33195efc4dc0400a4b0aaa3383948
Use correct enum DM_DEVICE_GET_TARGET_VERSION.
---
 WHATS_NEW                |    2 +-
 WHATS_NEW_DM             |    2 +-
 device_mapper/all.h      |    2 +-
 libdm/dm-tools/dmsetup.c |    2 +-
 libdm/libdevmapper.h     |    2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 001a12b..11b0acf 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -12,7 +12,7 @@ Version 2.03.06 -
   Preserve VDO write policy with vdopool.
   Increase default vdo bio threads to 4.
   Continue report when cache_status fails.
-  Add support for DM_GET_TARGET_VERSION into device_mapper.
+  Add support for DM_DEVICE_GET_TARGET_VERSION into device_mapper.
   Fix cmirrord usage of header files from device_mapper subdir.
   Allow standalone activation of VDO pool just like for thin-pools.
   Activate thin-pool layered volume as 'read-only' device.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 94492d4..ed56b89 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,6 +1,6 @@
 Version 1.02.165 - 
 =================================
-  Add support for DM_GET_TARGET_VERSION.
+  Add support for DM_DEVICE_GET_TARGET_VERSION.
   Add debug of dmsetup udevcomplete with hexa print DM_COOKIE_COMPLETED.
   Fix versioning of dm_stats_create_region and dm_stats_create_region.
 
diff --git a/device_mapper/all.h b/device_mapper/all.h
index 52b546f..57673b4 100644
--- a/device_mapper/all.h
+++ b/device_mapper/all.h
@@ -123,7 +123,7 @@ enum {
 
 	DM_DEVICE_ARM_POLL,
 
-	DM_GET_TARGET_VERSION
+	DM_DEVICE_GET_TARGET_VERSION
 };
 
 /*
diff --git a/libdm/dm-tools/dmsetup.c b/libdm/dm-tools/dmsetup.c
index 7d60d2f..269f86c 100644
--- a/libdm/dm-tools/dmsetup.c
+++ b/libdm/dm-tools/dmsetup.c
@@ -2596,7 +2596,7 @@ static int _target_version(CMD_ARGS)
 	struct dm_task *dmt;
 	struct dm_versions *target;
 
-	if (!(dmt = dm_task_create(DM_GET_TARGET_VERSION)))
+	if (!(dmt = dm_task_create(DM_DEVICE_GET_TARGET_VERSION)))
 		return_0;
 
 	if (!dm_task_set_name(dmt, argv[0]))
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 81c67dc..18fe9f9 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -123,7 +123,7 @@ enum {
 
 	DM_DEVICE_ARM_POLL,
 
-	DM_GET_TARGET_VERSION
+	DM_DEVICE_GET_TARGET_VERSION
 };
 
 /*


