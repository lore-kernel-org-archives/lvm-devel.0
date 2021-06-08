From: David Teigland <teigland@sourceware.org>
Date: Tue,  8 Jun 2021 17:18:10 +0000 (GMT)
Subject: main - devices: don't use deleted loop backing file for device id
Message-ID: <20210608171810.CD3153853828@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ca930bd936de2e7d4a83fa64add800baf6cfd116
Commit:        ca930bd936de2e7d4a83fa64add800baf6cfd116
Parent:        5e17203ff5dd4296760e5dad683e4cc84df2801d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 8 12:16:06 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 8 12:16:06 2021 -0500

devices: don't use deleted loop backing file for device id

check for "(deleted)" in the backing_file string and
fall back to devname for id.

$ cat /sys/block/loop0/loop/backing_file
/root/looptmp (deleted)
---
 lib/device/device_id.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 67f72e51b..1b98487ab 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -325,8 +325,12 @@ const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, u
 	else if (idtype == DEV_ID_TYPE_MD_UUID)
 		_read_sys_block(cmd, dev, "md/uuid", sysbuf, sizeof(sysbuf));
 
-	else if (idtype == DEV_ID_TYPE_LOOP_FILE)
+	else if (idtype == DEV_ID_TYPE_LOOP_FILE) {
 		_read_sys_block(cmd, dev, "loop/backing_file", sysbuf, sizeof(sysbuf));
+		/* if backing file is deleted, fall back to devname */
+		if (strstr(sysbuf, "(deleted)"))
+			sysbuf[0] = '\0';
+	}
 
 	else if (idtype == DEV_ID_TYPE_DEVNAME) {
 		if (!(idname = strdup(dev_name(dev))))


