From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Mar 2021 00:00:38 +0000 (GMT)
Subject: main - device_is_usable: minor improve
Message-ID: <20210317000038.EEF5E3851C26@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4d75c4f597b28e4ea014ef61082074187dc6245a
Commit:        4d75c4f597b28e4ea014ef61082074187dc6245a
Parent:        0363e4de70148c7fad5c46c40bc4db30be123545
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 16 10:10:10 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 17 00:49:11 2021 +0100

device_is_usable: minor improve

Replace allocated buffer with local vg_name which doesn't
pass pointer to allocation.

Join some conditions together.
---
 lib/activate/dev_manager.c | 77 ++++++++++++++++++++++++----------------------
 1 file changed, 41 insertions(+), 36 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 1a8f848ac..cd9d27e11 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -627,7 +627,8 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check, i
 	const char *name, *uuid;
 	uint64_t start, length;
 	char *target_type = NULL;
-	char *params, *vgname = NULL, *lvname, *layer;
+	char *params, *vgname, *lvname, *layer;
+	char vg_name[NAME_LEN];
 	void *next = NULL;
 	int only_error_target = 1;
 	int r = 0;
@@ -652,44 +653,49 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check, i
 		goto out;
 	}
 
-	/* Check internal lvm devices */
-	if (check.check_reserved &&
-	    uuid && !strncmp(uuid, UUID_PREFIX, sizeof(UUID_PREFIX) - 1)) {
-		if (strlen(uuid) > (sizeof(UUID_PREFIX) + 2 * ID_LEN)) { /* 68 */
-			log_debug_activation("%s: Reserved uuid %s on internal LV device %s not usable.",
-					     dev_name(dev), uuid, name);
-			goto out;
-		}
+	if (uuid && (check.check_reserved || check.check_lv)) {
+		if (!strncmp(uuid, UUID_PREFIX, sizeof(UUID_PREFIX) - 1)) { /* with LVM- prefix */
+			if (check.check_reserved) {
+				/* Check internal lvm devices */
+				if (strlen(uuid) > (sizeof(UUID_PREFIX) + 2 * ID_LEN)) { /* 68 with suffix */
+					log_debug_activation("%s: Reserved uuid %s on internal LV device %s not usable.",
+							     dev_name(dev), uuid, name);
+					goto out;
+				}
 
-		if (!(vgname = strdup(name)) ||
-		    !dm_split_lvm_name(NULL, NULL, &vgname, &lvname, &layer))
-			goto_out;
+				/* Recognize some older reserved LVs just from the LV name (snapshot, pvmove...) */
+				vgname = vg_name;
+				if (!dm_strncpy(vg_name, name, sizeof(vg_name)) ||
+				    !dm_split_lvm_name(NULL, NULL, &vgname, &lvname, &layer))
+					goto_out;
 
-		/* FIXME: fails to handle dev aliases i.e. /dev/dm-5, replace with UUID suffix */
-		if (lvname && (is_reserved_lvname(lvname) || *layer)) {
-			log_debug_activation("%s: Reserved internal LV device %s/%s%s%s not usable.",
-					     dev_name(dev), vgname, lvname, *layer ? "-" : "", layer);
-			goto out;
-		}
-	}
+				/* FIXME: fails to handle dev aliases i.e. /dev/dm-5, replace with UUID suffix */
+				if (lvname && (is_reserved_lvname(lvname) || *layer)) {
+					log_debug_activation("%s: Reserved internal LV device %s/%s%s%s not usable.",
+							     dev_name(dev), vgname, lvname, *layer ? "-" : "", layer);
+					goto out;
+				}
+			}
 
-	if (check.check_lv && uuid && !strncmp(uuid, "LVM-", 4)) {
-		/* Skip LVs */
-		if (is_lv)
-			*is_lv = 1;
-		goto out;
-	}
+			if (check.check_lv) {
+				/* Skip LVs */
+				if (is_lv)
+					*is_lv = 1;
+				goto out;
+			}
+		}
 
-	if (check.check_reserved && uuid &&
-	    (!strncmp(uuid, CRYPT_TEMP, sizeof(CRYPT_TEMP) - 1) ||
-	     !strncmp(uuid, CRYPT_SUBDEV, sizeof(CRYPT_SUBDEV) - 1) ||
-	     !strncmp(uuid, STRATIS, sizeof(STRATIS) - 1))) {
-		/* Skip private crypto devices */
-		log_debug_activation("%s: Reserved uuid %s on %s device %s not usable.",
-				     dev_name(dev), uuid,
-				     uuid[0] == 'C' ? "crypto" : "stratis",
-				     name);
-		goto out;
+		if (check.check_reserved &&
+		    (!strncmp(uuid, CRYPT_TEMP, sizeof(CRYPT_TEMP) - 1) ||
+		     !strncmp(uuid, CRYPT_SUBDEV, sizeof(CRYPT_SUBDEV) - 1) ||
+		     !strncmp(uuid, STRATIS, sizeof(STRATIS) - 1))) {
+			/* Skip private crypto devices */
+			log_debug_activation("%s: Reserved uuid %s on %s device %s not usable.",
+					     dev_name(dev), uuid,
+					     uuid[0] == 'C' ? "crypto" : "stratis",
+					     name);
+			goto out;
+		}
 	}
 
 	/* FIXME Also check for mpath no paths */
@@ -777,7 +783,6 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check, i
 	r = 1;
 
       out:
-	free(vgname);
 	dm_task_destroy(dmt);
 	return r;
 }


