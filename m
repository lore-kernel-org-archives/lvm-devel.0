From: David Teigland <teigland@sourceware.org>
Date: Thu,  1 Dec 2022 18:07:24 +0000 (GMT)
Subject: main - lvmcache: fix strncpy len for wwid
Message-ID: <20221201180724.20E9B3858C52@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f80273a1071532115219ea7c23054e6bbb096039
Commit:        f80273a1071532115219ea7c23054e6bbb096039
Parent:        55b29c1c3d4b5c1366ec0a24fb680cfb81fc4961
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Dec 1 10:03:06 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Dec 1 10:03:06 2022 -0600

lvmcache: fix strncpy len for wwid

---
 lib/cache/lvmcache.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 1ae63b3fc..ec32b3be9 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -654,13 +654,13 @@ static int _all_multipath_components(struct cmd_context *cmd, struct lvmcache_in
 
 		if (dev_is_mp) {
 			if ((wwid1 = dev_mpath_component_wwid(cmd, dev))) {
-				strncpy(wwid1_buf, wwid1, DEV_WWID_SIZE);
+				strncpy(wwid1_buf, wwid1, DEV_WWID_SIZE-1);
 				dev_mp = dev;
 				dev1 = dev;
 			}
 		} else {
 			if ((wwid1 = device_id_system_read(cmd, dev, DEV_ID_TYPE_SYS_WWID))) {
-				strncpy(wwid1_buf, wwid1, DEV_WWID_SIZE);
+				strncpy(wwid1_buf, wwid1, DEV_WWID_SIZE-1);
 				free((char *)wwid1);
 				dev1 = dev;
 			}
@@ -673,10 +673,10 @@ static int _all_multipath_components(struct cmd_context *cmd, struct lvmcache_in
 
 		if (dev_is_mp) {
 			if ((wwid = dev_mpath_component_wwid(cmd, dev)))
-				strncpy(wwid_buf, wwid, DEV_WWID_SIZE);
+				strncpy(wwid_buf, wwid, DEV_WWID_SIZE-1);
 		} else {
 			if ((wwid = device_id_system_read(cmd, dev, DEV_ID_TYPE_SYS_WWID))) {
-				strncpy(wwid_buf, wwid, DEV_WWID_SIZE);
+				strncpy(wwid_buf, wwid, DEV_WWID_SIZE-1);
 				free((char *)wwid);
 			}
 		}
@@ -692,7 +692,7 @@ static int _all_multipath_components(struct cmd_context *cmd, struct lvmcache_in
 			continue;
 
 		if (!wwid1_buf[0]) {
-			memcpy(wwid1_buf, wwid_buf, DEV_WWID_SIZE);
+			memcpy(wwid1_buf, wwid_buf, DEV_WWID_SIZE-1);
 			dev1 = dev;
 			continue;
 		}

