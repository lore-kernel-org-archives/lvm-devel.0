From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:35 +0000 (GMT)
Subject: main - label: check only with active device for rescan
Message-ID: <20210302215835.EB73D395180D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=00531186fc4ebc3cfeb934c5cb30b54d2f34d30d
Commit:        00531186fc4ebc3cfeb934c5cb30b54d2f34d30d
Parent:        56620b903955e245d4a257847f5825bb44d6db1e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 27 21:20:37 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:54:40 2021 +0100

label: check only with active device for rescan

When 'lv_info()' is called with &info structure,
the presence of node has to be checked from this structure.
Without this we were needlesly trying to look out 0:0 device.
---
 lib/label/label.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 318cf4d6c..8cbed7dd8 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1424,12 +1424,12 @@ void label_scan_invalidate_lv(struct cmd_context *cmd, struct logical_volume *lv
 	struct device *dev;
 	dev_t devt;
 
-	if (!lv_info(cmd, lv, 0, &lvinfo, 0, 0))
-		return;
-
-	devt = MKDEV(lvinfo.major, lvinfo.minor);
-	if ((dev = dev_cache_get_by_devt(cmd, devt, NULL, NULL)))
-		label_scan_invalidate(dev);
+	if (lv_info(cmd, lv, 0, &lvinfo, 0, 0) && lvinfo.exists) {
+		/* FIXME: Still unclear what is it supposed to find */
+		devt = MKDEV(lvinfo.major, lvinfo.minor);
+		if ((dev = dev_cache_get_by_devt(cmd, devt, NULL, NULL)))
+			label_scan_invalidate(dev);
+	}
 }
 
 /*


