From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 13 Mar 2018 08:03:55 -0400
Subject: master - scanning: skip more private devices
Message-ID: <201803131203.w2DC3tCw002318@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1bd57b4c1d4a6d715d24ab5dc162c350b97fc613
Commit:        1bd57b4c1d4a6d715d24ab5dc162c350b97fc613
Parent:        e095586d9e280877be336ed312368e657114ce14
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 9 14:49:38 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 13 12:57:33 2018 +0100

scanning: skip more private devices

Just like lvm2 has internal devices like _tdata which is using UUID with
suffix, there is similar private type of device for crypto device where
they are using CRYPT-TEMP uuid prefix.

Also ignore stratis.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |   13 +++++++++++++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a27b307..1d9e61c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Skip private crypto and stratis devices.
   Skip frozen raid devices from scanning.
   Activate RAID SubLVs on read_only_volume_list readwrite
   Offer convenience type raid5_n converting to raid10
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 499bf9a..ae3db80 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -32,6 +32,8 @@
 
 #define MAX_TARGET_PARAMSIZE 50000
 #define LVM_UDEV_NOSCAN_FLAG DM_SUBSYSTEM_UDEV_FLAG0
+#define CRYPT_TEMP	"CRYPT-TEMP"
+#define STRATIS		"stratis-"
 
 typedef enum {
 	PRELOAD,
@@ -637,6 +639,17 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check)
 		}
 	}
 
+	if (check.check_reserved && uuid &&
+	    (!strncmp(uuid, CRYPT_TEMP, sizeof(CRYPT_TEMP) - 1) ||
+	     !strncmp(uuid, STRATIS, sizeof(STRATIS) - 1))) {
+		/* Skip private crypto devices */
+		log_debug_activation("%s: Reserved uuid %s on %s device %s not usable.",
+				     dev_name(dev), uuid,
+				     uuid[0] == 'C' ? "crypto" : "stratis",
+				     name);
+		goto out;
+	}
+
 	/* FIXME Also check for mpath no paths */
 	do {
 		next = dm_get_next_target(dmt, next, &start, &length,


