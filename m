From: David Teigland <teigland@sourceware.org>
Date: Thu, 24 Jun 2021 16:32:31 +0000 (GMT)
Subject: main - device_id: handle qemu wwid
Message-ID: <20210624163231.15858384F023@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=73a05c8f02e9e4575b1ffceebc3a907f2e43517b
Commit:        73a05c8f02e9e4575b1ffceebc3a907f2e43517b
Parent:        84bd394cf9aaa581b4bf980f764544dda26a0305
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 24 11:30:46 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 24 11:30:46 2021 -0500

device_id: handle qemu wwid

Ignore made-up wwid values reported for qemu devices
that contain the string "QEMU HARDDISK".  The devname
will be used as the device id.
---
 lib/device/device_id.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index ffeac3064..87a46a73a 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -312,6 +312,10 @@ const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, u
 		/* scsi_debug wwid begins "t10.Linux   scsi_debug ..." */
 		if (strstr(sysbuf, "scsi_debug"))
 			sysbuf[0] = '\0';
+
+		/* qemu wwid begins "t10.ATA     QEMU HARDDISK ..." */
+		if (strstr(sysbuf, "QEMU HARDDISK"))
+			sysbuf[0] = '\0';
 	}
 
 	else if (idtype == DEV_ID_TYPE_SYS_SERIAL)


