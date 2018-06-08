From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 8 Jun 2018 09:25:45 -0400
Subject: master - device_mapper: remove c++ guards from the header
Message-ID: <201806081325.w58DPjPv015631@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=962a3eb3faced455b0a10f8e7d4575bed65b8dbd
Commit:        962a3eb3faced455b0a10f8e7d4575bed65b8dbd
Parent:        d5da55ed85248adb066d293c2a1b863ce17d2779
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Jun 8 13:44:43 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri Jun 8 13:44:43 2018 +0100

device_mapper: remove c++ guards from the header

This isn't a public header anymore, so not needed.
---
 device_mapper/all.h |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/device_mapper/all.h b/device_mapper/all.h
index b1d5a8c..ca0dbc7 100644
--- a/device_mapper/all.h
+++ b/device_mapper/all.h
@@ -43,10 +43,6 @@
 
 #define DM_ARRAY_SIZE(a) (sizeof(a) / sizeof((a)[0]))
 
-#ifdef __cplusplus
-extern "C" {
-#endif
-
 /*****************************************************************
  * The first section of this file provides direct access to the
  * individual device-mapper ioctls.  Since it is quite laborious to
@@ -3518,7 +3514,4 @@ int dm_udev_wait_immediate(uint32_t cookie, int *ready);
 #define DM_DEV_DIR_UMASK 0022
 #define DM_CONTROL_NODE_UMASK 0177
 
-#ifdef __cplusplus
-}
-#endif
 #endif				/* LIB_DEVICE_MAPPER_H */


