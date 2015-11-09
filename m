From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:41 +0000 (UTC)
Subject: master - devmanager: validate target params
Message-ID: <20151109092841.59E8460E54@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=164d7e72bfd6fa0564e195d0c0fdf64893566ad6
Commit:        164d7e72bfd6fa0564e195d0c0fdf64893566ad6
Parent:        4f8f8fcb52d1d1f2a46468aa6bb4a8da11804c5b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 09:27:18 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:19:20 2015 +0100

devmanager: validate target params

Coverity: ensure we do not read through NULL pointers for
target_type and params.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |   12 ++++++------
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7930631..00b7ee1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.135 - 
 ====================================
+  Add missing pointer validation after dm_get_next_target().
   Do not deref NULL pointer in debug message for _match_pv_tags().
   Drop unneeded stat() call when checking for sysfs file.
   Fix memory leak on error path of failing thin-pool percentage check.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 6ec9d22..0b24f86 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -498,14 +498,14 @@ static int _ignore_suspended_snapshot_component(struct device *dev)
 
 	do {
 		next = dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
-		if (!strcmp(target_type, "snapshot")) {
-			if (sscanf(params, "%d:%d %d:%d", &major1, &minor1, &major2, &minor2) != 4) {
+		if (!target_type || !strcmp(target_type, "snapshot")) {
+			if (!params || sscanf(params, "%d:%d %d:%d", &major1, &minor1, &major2, &minor2) != 4) {
 				log_error("Incorrect snapshot table found");
 				goto_out;
 			}
 			r = r || _device_is_suspended(major1, minor1) || _device_is_suspended(major2, minor2);
 		} else if (!strcmp(target_type, "snapshot-origin")) {
-			if (sscanf(params, "%d:%d", &major1, &minor1) != 2) {
+			if (!params || sscanf(params, "%d:%d", &major1, &minor1) != 2) {
 				log_error("Incorrect snapshot-origin table found");
 				goto_out;
 			}
@@ -545,7 +545,7 @@ static int _ignore_unusable_thins(struct device *dev)
 		goto out;
 	}
 	dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
-	if (sscanf(params, "%d:%d", &minor, &major) != 2) {
+	if (!params || sscanf(params, "%d:%d", &minor, &major) != 2) {
 		log_error("Failed to get thin-pool major:minor for thin device %d:%d.",
 			  (int)MAJOR(dev->dev), (int)MINOR(dev->dev));
 		goto out;
@@ -1678,12 +1678,12 @@ int dev_manager_thin_device_id(struct dev_manager *dm,
 		goto out;
 	}
 
-	if (strcmp(target_type, "thin")) {
+	if (!target_type || strcmp(target_type, "thin")) {
 		log_error("Unexpected target type %s found for thin %s.", target_type, lv->name);
 		goto out;
 	}
 
-	if (sscanf(params, "%*u:%*u %u", device_id) != 1) {
+	if (!params || sscanf(params, "%*u:%*u %u", device_id) != 1) {
 		log_error("Cannot parse table like parameters %s for %s.", params, lv->name);
 		goto out;
 	}


