From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:56:01 -0400
Subject: master - cov: add missing error path check for label_scan_open
Message-ID: <201810151556.w9FFu1Fu020720@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=84f00f50584b0c1c0464a414c71cd112e4d30c22
Commit:        84f00f50584b0c1c0464a414c71cd112e4d30c22
Parent:        b57e73a0f1376ea114451c0172f0ef0adbd3123f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 16:39:28 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 17:49:44 2018 +0200

cov: add missing error path check for label_scan_open

---
 lib/label/label.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 3901a86..6c074d6 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1067,7 +1067,11 @@ int label_read_sector(struct device *dev, uint64_t read_sector)
 	block_sector = block_num * BCACHE_BLOCK_SIZE_IN_SECTORS;
 	start_sector = read_sector % BCACHE_BLOCK_SIZE_IN_SECTORS;
 
-	label_scan_open(dev);
+	if (!label_scan_open(dev)) {
+		log_error("Error opening device %s for prefetch %llu sector.",
+			  dev_name(dev), (unsigned long long)block_num);
+		return false;
+	}
 
 	bcache_prefetch(scan_bcache, dev->bcache_fd, block_num);
 


