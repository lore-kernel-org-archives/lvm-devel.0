From: David Teigland <teigland@sourceware.org>
Date: Wed, 21 Sep 2022 17:15:50 +0000 (GMT)
Subject: main - covscan: free wwid strings in lvmcache
Message-ID: <20220921171550.0E8E33858CDB@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c21783d4929ffd60f567ea90c9ae7c644d793d12
Commit:        c21783d4929ffd60f567ea90c9ae7c644d793d12
Parent:        e97cf8552c7e47ab0a85e9dbec2d3581e34e2cc3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 21 12:15:13 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 21 12:15:13 2022 -0500

covscan: free wwid strings in lvmcache

---
 lib/cache/lvmcache.c | 46 +++++++++++++++++++++++++++++++---------------
 1 file changed, 31 insertions(+), 15 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 00916885c..2cb904fd4 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -644,8 +644,10 @@ static int _all_multipath_components(struct cmd_context *cmd, struct lvmcache_in
 	struct device *dev_mp = NULL;
 	struct device *dev1 = NULL;
 	struct device *dev;
+	char wwid1_buf[DEV_WWID_SIZE] = { 0 };
+	char wwid_buf[DEV_WWID_SIZE] = { 0 };
 	const char *wwid1 = NULL;
-	const char *wwid;
+	const char *wwid = NULL;
 	int diff_wwid = 0;
 	int same_wwid = 0;
 	int dev_is_mp;
@@ -667,14 +669,23 @@ static int _all_multipath_components(struct cmd_context *cmd, struct lvmcache_in
 		dev = info->dev;
 		dev_is_mp = (cmd->dev_types->device_mapper_major == MAJOR(dev->dev)) && dev_has_mpath_uuid(cmd, dev, NULL);
 
+		/*
+		 * dev_mpath_component_wwid allocates wwid from dm_pool,
+		 * device_id_system_read does not and needs free.
+		 */
+
 		if (dev_is_mp) {
 			if ((wwid1 = dev_mpath_component_wwid(cmd, dev))) {
+				strncpy(wwid1_buf, wwid1, DEV_WWID_SIZE);
 				dev_mp = dev;
 				dev1 = dev;
 			}
 		} else {
-			if ((wwid1 = device_id_system_read(cmd, dev, DEV_ID_TYPE_SYS_WWID)))
+			if ((wwid1 = device_id_system_read(cmd, dev, DEV_ID_TYPE_SYS_WWID))) {
+				strncpy(wwid1_buf, wwid1, DEV_WWID_SIZE);
+				free((char *)wwid1);
 				dev1 = dev;
+			}
 		}
 	}
 
@@ -682,31 +693,36 @@ static int _all_multipath_components(struct cmd_context *cmd, struct lvmcache_in
 		dev = devl->dev;
 		dev_is_mp = (cmd->dev_types->device_mapper_major == MAJOR(dev->dev)) && dev_has_mpath_uuid(cmd, dev, NULL);
 
-		if (dev_is_mp)
-			wwid = dev_mpath_component_wwid(cmd, dev);
-		else
-			wwid = device_id_system_read(cmd, dev, DEV_ID_TYPE_SYS_WWID);
+		if (dev_is_mp) {
+			if ((wwid = dev_mpath_component_wwid(cmd, dev)))
+				strncpy(wwid_buf, wwid, DEV_WWID_SIZE);
+		} else {
+			if ((wwid = device_id_system_read(cmd, dev, DEV_ID_TYPE_SYS_WWID))) {
+				strncpy(wwid_buf, wwid, DEV_WWID_SIZE);
+				free((char *)wwid);
+			}
+		}
 
-		if (!wwid && wwid1) {
+		if (!wwid_buf[0] && wwid1_buf[0]) {
 			log_debug("Different wwids for duplicate PVs %s %s %s none",
-				  dev_name(dev1), wwid1, dev_name(dev));
+				  dev_name(dev1), wwid1_buf, dev_name(dev));
 			diff_wwid++;
 			continue;
 		}
 
-		if (!wwid)
+		if (!wwid_buf[0])
 			continue;
 
-		if (!wwid1) {
-			wwid1 = wwid;
+		if (!wwid1_buf[0]) {
+			memcpy(wwid1_buf, wwid_buf, DEV_WWID_SIZE);
 			dev1 = dev;
 			continue;
 		}
 
 		/* Different wwids indicates these are not multipath components. */
-		if (strcmp(wwid1, wwid)) {
+		if (strcmp(wwid1_buf, wwid_buf)) {
 			log_debug("Different wwids for duplicate PVs %s %s %s %s",
-				  dev_name(dev1), wwid1, dev_name(dev), wwid);
+				  dev_name(dev1), wwid1_buf, dev_name(dev), wwid_buf);
 			diff_wwid++;
 			continue;
 		}
@@ -714,7 +730,7 @@ static int _all_multipath_components(struct cmd_context *cmd, struct lvmcache_in
 		/* Different mpath devs with the same wwid shouldn't happen. */
 		if (dev_is_mp && dev_mp) {
 			log_print("Found multiple multipath devices for PVID %s WWID %s: %s %s",
-				   pvid, wwid1, dev_name(dev_mp), dev_name(dev));
+				   pvid, wwid1_buf, dev_name(dev_mp), dev_name(dev));
 			continue;
 		}
 
@@ -730,7 +746,7 @@ static int _all_multipath_components(struct cmd_context *cmd, struct lvmcache_in
 		return 0;
 
 	if (dev_mp)
-		log_debug("Found multipath device %s for PVID %s WWID %s.", dev_name(dev_mp), pvid, wwid1);
+		log_debug("Found multipath device %s for PVID %s WWID %s.", dev_name(dev_mp), pvid, wwid1_buf);
 
 	*dev_mpath = dev_mp;
 	return 1;

