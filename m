From: David Teigland <teigland@sourceware.org>
Date: Tue, 22 Jun 2021 18:38:08 +0000 (GMT)
Subject: main - device_id: handle scsi_debug wwid
Message-ID: <20210622183808.0EA8C3877404@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1139a05939f85bd86a756b451a8f194bc7a72a2c
Commit:        1139a05939f85bd86a756b451a8f194bc7a72a2c
Parent:        c35f7722d588009edad22d59c68c82150bb5c216
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 22 13:36:10 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 22 13:36:10 2021 -0500

device_id: handle scsi_debug wwid

Ignore the wwid value reported by scsi_debug devices
that begin "t10.Linux   scsi_debug".  The devname
will be used as the device id.
---
 lib/device/device_id.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 65912b9b6..ffeac3064 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -308,6 +308,10 @@ const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, u
 
 		if (!sysbuf[0])
 			_read_sys_block(cmd, dev, "wwid", sysbuf, sizeof(sysbuf));
+
+		/* scsi_debug wwid begins "t10.Linux   scsi_debug ..." */
+		if (strstr(sysbuf, "scsi_debug"))
+			sysbuf[0] = '\0';
 	}
 
 	else if (idtype == DEV_ID_TYPE_SYS_SERIAL)


