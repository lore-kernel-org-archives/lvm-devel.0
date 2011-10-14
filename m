From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 14 Oct 2011 16:58:38 +0200
Subject: [PATCH 1/6][devname mangling] Move dm_task_set_newname to libdm-common.c
Message-ID: <4E984E1E.4050700@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add support for device name mangling (to comply with udev whitelist) patchset.

This is a more elaborate proposal of the former patch:
 [lvm-devel][PATCH] Add support for escaping device-mapper names (to be in sync with udev whitelist)

This patch #1 is just a preparation - the dm_task_set_newname is moved from
libdm-iface.c to libdm-common.c (where the dm_task_set_name is already). These
fns will call new functions for setting the name mangling.

Peter
---
 libdm/ioctl/libdm-iface.c |   21 ---------------------
 libdm/libdm-common.c      |   21 +++++++++++++++++++++
 2 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index aab6305..93cd770 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -745,27 +745,6 @@ int dm_task_set_newuuid(struct dm_task *dmt, const char *newuuid)
 	return 1;
 }
 
-int dm_task_set_newname(struct dm_task *dmt, const char *newname)
-{
-	if (strchr(newname, '/')) {
-		log_error("Name \"%s\" invalid. It contains \"/\".", newname);
-		return 0;
-	}
-
-	if (strlen(newname) >= DM_NAME_LEN) {
-		log_error("Name \"%s\" too long", newname);
-		return 0;
-	}
-
-	if (!(dmt->newname = dm_strdup(newname))) {
-		log_error("dm_task_set_newname: strdup(%s) failed", newname);
-		return 0;
-	}
-	dmt->new_uuid = 0;
-
-	return 1;
-}
-
 int dm_task_set_message(struct dm_task *dmt, const char *message)
 {
 	if (!(dmt->message = dm_strdup(message))) {
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 23539d7..1237c21 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -338,6 +338,27 @@ int dm_task_set_name(struct dm_task *dmt, const char *name)
 	return 1;
 }
 
+int dm_task_set_newname(struct dm_task *dmt, const char *newname)
+{
+	if (strchr(newname, '/')) {
+		log_error("Name \"%s\" invalid. It contains \"/\".", newname);
+		return 0;
+	}
+
+	if (strlen(newname) >= DM_NAME_LEN) {
+		log_error("Name \"%s\" too long", newname);
+		return 0;
+	}
+
+	if (!(dmt->newname = dm_strdup(newname))) {
+		log_error("dm_task_set_newname: strdup(%s) failed", newname);
+		return 0;
+	}
+	dmt->new_uuid = 0;
+
+	return 1;
+}
+
 int dm_task_set_uuid(struct dm_task *dmt, const char *uuid)
 {
 	dm_free(dmt->uuid);


