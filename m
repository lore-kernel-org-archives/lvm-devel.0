From: David Teigland <teigland@sourceware.org>
Date: Thu,  1 Dec 2022 18:07:27 +0000 (GMT)
Subject: main - device_id: check return value of label_read_pvid
Message-ID: <20221201180727.8267B3858C54@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a74468116ea51542e409e4bc393c63dc7ddb20b6
Commit:        a74468116ea51542e409e4bc393c63dc7ddb20b6
Parent:        e71b434663e445ee9232fc72786e5bc2ac699f4b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Dec 1 11:49:51 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Dec 1 11:49:51 2022 -0600

device_id: check return value of label_read_pvid

for covscan
---
 lib/device/device_id.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 367b7dbb9..1f2ab5ad4 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -2489,6 +2489,7 @@ void device_ids_check_serial(struct cmd_context *cmd, struct dm_list *scan_devs,
 	int has_pvid;
 	int found;
 	int count;
+	int err;
 
 	dm_list_init(&dus_check);
 	dm_list_init(&devs_check);
@@ -2544,8 +2545,8 @@ void device_ids_check_serial(struct cmd_context *cmd, struct dm_list *scan_devs,
 		dev = devl->dev;
 		has_pvid = 0;
 
-		label_read_pvid(dev, &has_pvid);
-		if (!has_pvid) {
+		err = label_read_pvid(dev, &has_pvid);
+		if (!err || !has_pvid) {
 			log_debug("serial %s no pvid %s", idname, dev_name(devl->dev));
 			dm_list_del(&devl->list);
 			continue;

