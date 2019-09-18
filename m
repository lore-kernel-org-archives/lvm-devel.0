From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 18 Sep 2019 06:47:20 -0400
Subject: stable-2.02 - devices: crypto skip
Message-ID: <201909181047.x8IAlKEO016756@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2caae8a572f5d31f9dececf75aa4126be439bcba
Commit:        2caae8a572f5d31f9dececf75aa4126be439bcba
Parent:        2694f93bb4b670d5afc51ff656f51e1e2945664a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 13 13:22:07 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 17 15:29:11 2019 +0200

devices: crypto skip

Devices with UUID signature CRYPT-SUBDEV are internal crypto devices.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8a597ba..32298c8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.187 - 
 ===================================
+  Ignore crypto devices with UUID signature CRYPT-SUBDEV.
   Enhance validation for thin and cache pool conversion and swapping.
 
 Version 2.02.186 - 27th August 2019
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index dc64159..657b046 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -33,6 +33,7 @@
 #define MAX_TARGET_PARAMSIZE 50000
 #define LVM_UDEV_NOSCAN_FLAG DM_SUBSYSTEM_UDEV_FLAG0
 #define CRYPT_TEMP	"CRYPT-TEMP"
+#define CRYPT_SUBDEV	"CRYPT-SUBDEV"
 #define STRATIS		"stratis-"
 
 typedef enum {
@@ -646,6 +647,7 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check)
 
 	if (check.check_reserved && uuid &&
 	    (!strncmp(uuid, CRYPT_TEMP, sizeof(CRYPT_TEMP) - 1) ||
+	     !strncmp(uuid, CRYPT_SUBDEV, sizeof(CRYPT_SUBDEV) - 1) ||
 	     !strncmp(uuid, STRATIS, sizeof(STRATIS) - 1))) {
 		/* Skip private crypto devices */
 		log_debug_activation("%s: Reserved uuid %s on %s device %s not usable.",


