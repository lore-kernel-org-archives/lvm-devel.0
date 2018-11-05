From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 5 Nov 2018 11:27:30 -0500
Subject: master - cov: avoid unsing unchecked label_scan_open
Message-ID: <201811051627.wA5GRUU2005449@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d3ebb18f4052fd90bb2d177089e79801b51f6242
Commit:        d3ebb18f4052fd90bb2d177089e79801b51f6242
Parent:        70e3d0a613fb53e52f7a7cb31d65bcc2fa7ab738
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 3 17:19:33 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 5 17:25:11 2018 +0100

cov: avoid unsing unchecked label_scan_open

Drop extra call too label_scan_open() without checking return value,
and let code go through next call bellow.
---
 lib/label/label.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index ca8502d..5387161 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1299,9 +1299,7 @@ bool dev_set_bytes(struct device *dev, uint64_t start, size_t len, uint8_t val)
 		log_debug("Close and reopen to write %s", dev_name(dev));
 		bcache_invalidate_fd(scan_bcache, dev->bcache_fd);
 		_scan_dev_close(dev);
-
-		dev->flags |= DEV_BCACHE_WRITE;
-		label_scan_open(dev);
+		/* goes to label_scan_open() since bcache_fd < 0 */
 	}
 
 	if (dev->bcache_fd <= 0) {


