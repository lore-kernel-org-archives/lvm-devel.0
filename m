From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 10 Dec 2019 09:46:20 -0500
Subject: master - libdm: support device RELOAD with maj:min and devname set
Message-ID: <90530.119121009461601835@us-mta-234.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=df0bc5081c1b84c2ae7c8d8dc92305f90f161683
Commit:        df0bc5081c1b84c2ae7c8d8dc92305f90f161683
Parent:        338f4df54ba19244c4cf51c9ad6461ef5613ed5f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 10 13:28:16 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 10 15:42:59 2019 +0100

libdm: support device RELOAD with maj:min and devname set

When devices are created - we were not giving meaning error messages
when the failure happened on 'reload' part of creation.

With this patch we are now able to report both name and major:minor.

Enhancment is most visible with 'crypto' devices,
which are using 'secure' memory erase bit.
---
 WHATS_NEW_DM              |    1 +
 libdm/ioctl/libdm-iface.c |   14 ++++++++++----
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index b64a9a2..a1e233e 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.169 - 
 =====================================
+  Enhance error messages for device creation.
 
 Version 1.02.167 - 30th November 2019
 =====================================
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index dd46b67..ae44abf 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1238,8 +1238,12 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 	}
 
 	/* FIXME Until resume ioctl supplies name, use dev_name for readahead */
-	if (DEV_NAME(dmt) && (dmt->type != DM_DEVICE_RESUME || dmt->minor < 0 ||
-			      dmt->major < 0))
+	if (DEV_NAME(dmt) &&
+	    (((dmt->type != DM_DEVICE_RESUME) &&
+	      (dmt->type != DM_DEVICE_RELOAD)) ||
+	     (dmt->minor < 0) || (dmt->major < 0)))
+		/* When RESUME or RELOAD sets maj:min and dev_name, use just maj:min,
+		 * passed dev_name is useful for better error/debug messages */
 		strncpy(dmi->name, DEV_NAME(dmt), sizeof(dmi->name));
 
 	if (DEV_UUID(dmt))
@@ -1904,7 +1908,8 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 				log_verbose("device-mapper: %s ioctl on %s %s%s%.0d%s%.0d%s%s "
 					    "failed: %s",
 					    _cmd_data_v4[dmt->type].name,
-					    dmi->name, dmi->uuid,
+					    dmi->name[0] ? dmi->name : DEV_NAME(dmt) ? : "",
+					    dmi->uuid[0] ? dmi->uuid : DEV_UUID(dmt) ? : "",
 					    dmt->major > 0 ? "(" : "",
 					    dmt->major > 0 ? dmt->major : 0,
 					    dmt->major > 0 ? ":" : "",
@@ -1916,7 +1921,8 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 				log_error("device-mapper: %s ioctl on %s %s%s%.0d%s%.0d%s%s "
 					  "failed: %s",
 					  _cmd_data_v4[dmt->type].name,
-					  dmi->name, dmi->uuid,
+					  dmi->name[0] ? dmi->name : DEV_NAME(dmt) ? : "",
+					  dmi->uuid[0] ? dmi->uuid : DEV_UUID(dmt) ? : "",
 					  dmt->major > 0 ? "(" : "",
 					  dmt->major > 0 ? dmt->major : 0,
 					  dmt->major > 0 ? ":" : "",



