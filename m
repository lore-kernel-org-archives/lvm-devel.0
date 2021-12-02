From: David Teigland <teigland@sourceware.org>
Date: Thu,  2 Dec 2021 19:33:41 +0000 (GMT)
Subject: main - device_id: handle wwid with spaces or control characters
Message-ID: <20211202193341.41995385841A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ae54e75176d787de2d447ec40142f85f4dcc47c4
Commit:        ae54e75176d787de2d447ec40142f85f4dcc47c4
Parent:        455c29b10dfd15a9fa2ad72c8f9de77572328d39
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Dec 2 13:30:36 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Dec 2 13:33:18 2021 -0600

device_id: handle wwid with spaces or control characters

non-standard wwid can be reported from sysfs with spaces/etc.
replace with "_"
---
 lib/device/device_id.c | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index bfee7d418..6e9107fff 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -304,6 +304,7 @@ const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, u
 {
 	char sysbuf[PATH_MAX] = { 0 };
 	const char *idname = NULL;
+	int i;
 
 	if (idtype == DEV_ID_TYPE_SYS_WWID) {
 		read_sys_block(cmd, dev, "device/wwid", sysbuf, sizeof(sysbuf));
@@ -311,18 +312,10 @@ const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, u
 		if (!sysbuf[0])
 			read_sys_block(cmd, dev, "wwid", sysbuf, sizeof(sysbuf));
 
-		/* scsi_debug wwid begins "t10.Linux   scsi_debug ..." */
-		if (strstr(sysbuf, "scsi_debug")) {
-                        int i;
-                        for (i = 0; i < strlen(sysbuf); i++) {
-                                if (sysbuf[i] == ' ')
-                                        sysbuf[i] = '_';
-                        }
-		}
-
 		/* qemu wwid begins "t10.ATA     QEMU HARDDISK ..." */
 		if (strstr(sysbuf, "QEMU HARDDISK"))
 			sysbuf[0] = '\0';
+
 	}
 
 	else if (idtype == DEV_ID_TYPE_SYS_SERIAL)
@@ -360,6 +353,11 @@ const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, u
 		return idname;
 	}
 
+	for (i = 0; i < strlen(sysbuf); i++) {
+		if (isblank(sysbuf[i]) || isspace(sysbuf[i]) || iscntrl(sysbuf[i]))
+			sysbuf[i] = '_';
+	}
+
 	if (!sysbuf[0])
 		goto_bad;
 


