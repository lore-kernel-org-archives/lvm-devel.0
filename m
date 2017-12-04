From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 4 Dec 2017 09:57:39 -0500
Subject: master - cleanup: simplier error message
Message-ID: <201712041457.vB4Evdir007112@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1f6d79ab4827929420e032f4fb77e03393f336a8
Commit:        1f6d79ab4827929420e032f4fb77e03393f336a8
Parent:        7379a2624beb6bbefff6f6d6222b1eac9f5980e6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 4 11:25:01 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 4 15:38:50 2017 +0100

cleanup: simplier error message

Use single 'error' message just with different reason.
---
 libdm/libdm-deptree.c |   33 +++++++++++++--------------------
 1 files changed, 13 insertions(+), 20 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 8fac4a1..9bc16c9 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -917,33 +917,26 @@ out:
 
 static int _check_device_not_in_use(const char *name, struct dm_info *info)
 {
+	const char *reason;
+
 	if (!info->exists)
 		return 1;
 
 	/* If sysfs is not used, use open_count information only. */
 	if (!*dm_sysfs_dir()) {
-		if (info->open_count) {
-			log_error("Device %s (%" PRIu32 ":%" PRIu32 ") in use",
-				  name, info->major, info->minor);
-			return 0;
-		}
-
+		if (!info->open_count)
+			return 1;
+		reason = "in use";
+	} else if (dm_device_has_holders(info->major, info->minor))
+		reason = "is used by another device";
+	else if (dm_device_has_mounted_fs(info->major, info->minor))
+		reason = "constains a filesystem in use";
+	else
 		return 1;
-	}
 
-	if (dm_device_has_holders(info->major, info->minor)) {
-		log_error("Device %s (%" PRIu32 ":%" PRIu32 ") is used "
-			  "by another device.", name, info->major, info->minor);
-		return 0;
-	}
-
-	if (dm_device_has_mounted_fs(info->major, info->minor)) {
-		log_error("Device %s (%" PRIu32 ":%" PRIu32 ") contains "
-			  "a filesystem in use.", name, info->major, info->minor);
-		return 0;
-	}
-
-	return 1;
+	log_error("Device %s (" FMTu32 ":" FMTu32 ") %s.",
+		  name, info->major, info->minor, reason);
+	return 0;
 }
 
 /* Check if all parent nodes of given node have open_count == 0 */


