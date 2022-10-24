From: David Teigland <teigland@sourceware.org>
Date: Mon, 24 Oct 2022 21:20:44 +0000 (GMT)
Subject: main - device_id: remove debug trace
Message-ID: <20221024212044.8AEED385841D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f188c9e40319d00a3d5bd59f1d01016325935da6
Commit:        f188c9e40319d00a3d5bd59f1d01016325935da6
Parent:        830ece75e80b1779de5e81e3424a8ee756f66f88
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 24 16:19:05 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Oct 24 16:20:28 2022 -0500

device_id: remove debug trace

for common case where a device id type is not used.
---
 lib/device/device_id.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 34469e262..bd9b3c4bf 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -529,7 +529,7 @@ const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, u
 	}
 
 	if (!sysbuf[0])
-		goto_bad;
+		goto bad;
 
 	if (!(idname = strdup(sysbuf)))
 		goto_bad;

