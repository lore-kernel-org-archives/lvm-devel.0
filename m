From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:54:17 -0400
Subject: master - remove debugging print
Message-ID: <201804231354.w3NDsH7x001382@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=89f54a5094981c827ca557cb1381e5f1a028912c
Commit:        89f54a5094981c827ca557cb1381e5f1a028912c
Parent:        c29899b910811d0d1dc5607d200a1e59773eff0c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 13 15:53:59 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:46 2018 -0500

remove debugging print

---
 lib/label/label.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index f0ec92f..1268498 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -802,9 +802,7 @@ int label_read_sector(struct device *dev, struct label **labelp, uint64_t scan_s
 
 void label_scan_confirm(struct device *dev)
 {
-	if (!_in_bcache(dev)) {
-		log_warn("add dev %s to bcache", dev_name(dev));
+	if (!_in_bcache(dev))
 		label_read(dev, NULL, 0);
-	}
 }
 


