From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 10 Jan 2018 10:53:07 -0500
Subject: master - label: Rename a variable
Message-ID: <201801101553.w0AFr7O3004676@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b65246499bb126097ca8a81c3de0ca39f4f56320
Commit:        b65246499bb126097ca8a81c3de0ca39f4f56320
Parent:        ea96381534360d6a893f0a48db8dd15fcb9ced33
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jan 9 21:13:46 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jan 10 15:48:03 2018 +0000

label: Rename a variable

---
 lib/label/label.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index ccee95d..362a1b0 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -248,7 +248,7 @@ int label_remove(struct device *dev)
 	struct labeller_i *li;
 	struct label_header *lh;
 	struct lvmcache_info *info;
-	char *buf = NULL;
+	char *readbuf = NULL;
 
 	memset(labelbuf, 0, LABEL_SIZE);
 
@@ -263,7 +263,7 @@ int label_remove(struct device *dev)
 	 */
 	dev_flush(dev);
 
-	if (!(buf = dev_read(dev, UINT64_C(0), LABEL_SCAN_SIZE, DEV_IO_LABEL))) {
+	if (!(readbuf = dev_read(dev, UINT64_C(0), LABEL_SCAN_SIZE, DEV_IO_LABEL))) {
 		log_debug_devs("%s: Failed to read label area", dev_name(dev));
 		goto out;
 	}
@@ -271,7 +271,7 @@ int label_remove(struct device *dev)
 	/* Scan first few sectors for anything looking like a label */
 	for (sector = 0; sector < LABEL_SCAN_SECTORS;
 	     sector += LABEL_SIZE >> SECTOR_SHIFT) {
-		lh = (struct label_header *) (buf + (sector << SECTOR_SHIFT));
+		lh = (struct label_header *) (readbuf + (sector << SECTOR_SHIFT));
 
 		wipe = 0;
 
@@ -309,7 +309,7 @@ int label_remove(struct device *dev)
 	if (!dev_close(dev))
 		stack;
 
-	dm_free(buf);
+	dm_free(readbuf);
 	return r;
 }
 


