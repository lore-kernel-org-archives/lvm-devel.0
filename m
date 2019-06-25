From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 25 Jun 2019 11:45:01 -0400
Subject: stable-2.02 - cov: check lv_info
Message-ID: <201906251545.x5PFj14m012714@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2cd6cd34394cb25d312c73b979f4e536d431c10b
Commit:        2cd6cd34394cb25d312c73b979f4e536d431c10b
Parent:        82e7426028a90fff891e0b3fafa15826758e18e8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 25 14:52:19 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 25 17:32:44 2019 +0200

cov: check lv_info

Use lv_info results only when valid.
---
 lib/label/label.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 6d8156e..83b4d99 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1139,10 +1139,11 @@ void label_scan_invalidate_lv(struct cmd_context *cmd, struct logical_volume *lv
 	struct device *dev;
 	dev_t devt;
 
-	lv_info(cmd, lv, 0, &lvinfo, 0, 0);
-	devt = MKDEV(lvinfo.major, lvinfo.minor);
-	if ((dev = dev_cache_get_by_devt(devt, NULL)))
-		label_scan_invalidate(dev);
+	if (lv_info(cmd, lv, 0, &lvinfo, 0, 0)) {
+		devt = MKDEV(lvinfo.major, lvinfo.minor);
+		if ((dev = dev_cache_get_by_devt(devt, NULL)))
+			label_scan_invalidate(dev);
+	}
 }
 
 /*


