From: David Teigland <teigland@sourceware.org>
Date: Thu,  1 Dec 2022 18:07:26 +0000 (GMT)
Subject: main - device_id: _get_devs_with_serial_numbers add missing free
Message-ID: <20221201180726.61C8F3858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e71b434663e445ee9232fc72786e5bc2ac699f4b
Commit:        e71b434663e445ee9232fc72786e5bc2ac699f4b
Parent:        7552ed9010f823d2ac2b99349c62dce8cd6fd506
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Dec 1 11:43:24 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Dec 1 11:43:24 2022 -0600

device_id: _get_devs_with_serial_numbers add missing free

on malloc failure path
---
 lib/device/device_id.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 4fa02edc7..367b7dbb9 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -2124,11 +2124,11 @@ static void _get_devs_with_serial_numbers(struct cmd_context *cmd, struct dm_lis
 			if (id->idtype == DEV_ID_TYPE_SYS_SERIAL) {
 				if (str_list_match_item(serial_str_list, id->idname)) {
 					if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
-						goto next_dev;
+						goto next_continue;
 					devl->dev = dev;
 					dm_list_add(devs, &devl->list);
 				}
-				goto next_dev;
+				goto next_continue;
 			}
 		}
 
@@ -2145,20 +2145,22 @@ static void _get_devs_with_serial_numbers(struct cmd_context *cmd, struct dm_lis
 		if ((idname = device_id_system_read(cmd, dev, DEV_ID_TYPE_SYS_SERIAL))) {
 			if (str_list_match_item(serial_str_list, idname)) {
 				if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
-					goto next_dev;
+					goto next_free;
 				if (!(id = zalloc(sizeof(struct dev_id))))
-					goto next_dev;
+					goto next_free;
 				id->idtype = DEV_ID_TYPE_SYS_SERIAL;
 				id->idname = (char *)idname;
 				id->dev = dev;
 				dm_list_add(&dev->ids, &id->list);
 				devl->dev = dev;
 				dm_list_add(devs, &devl->list);
-			} else {
-				free((char *)idname);
+				idname = NULL;
 			}
 		}
- next_dev:
+ next_free:
+		if (idname)
+			free((char *)idname);
+ next_continue:
 		continue;
 	}
 	dev_iter_destroy(iter);

