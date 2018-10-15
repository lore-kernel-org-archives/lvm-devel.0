From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:55:58 -0400
Subject: master - cov: make sure label scans valid lvinfo
Message-ID: <201810151555.w9FFtwB5020707@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b57e73a0f1376ea114451c0172f0ef0adbd3123f
Commit:        b57e73a0f1376ea114451c0172f0ef0adbd3123f
Parent:        70950bbd977020593b19ac704fd7571b4b2826cd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 16:29:09 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 17:49:44 2018 +0200

cov: make sure label scans valid lvinfo

---
 lib/label/label.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 9fe11f6..3901a86 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -970,7 +970,9 @@ void label_scan_invalidate_lv(struct cmd_context *cmd, struct logical_volume *lv
 	struct device *dev;
 	dev_t devt;
 
-	lv_info(cmd, lv, 0, &lvinfo, 0, 0);
+	if (!lv_info(cmd, lv, 0, &lvinfo, 0, 0))
+		return;
+
 	devt = MKDEV(lvinfo.major, lvinfo.minor);
 	if ((dev = dev_cache_get_by_devt(cmd, devt, NULL)))
 		label_scan_invalidate(dev);


