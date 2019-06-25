From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 25 Jun 2019 11:45:01 -0400
Subject: stable-2.02 - cov: check result of dev_get_block_size
Message-ID: <201906251545.x5PFj1Je012731@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=82e7426028a90fff891e0b3fafa15826758e18e8
Commit:        82e7426028a90fff891e0b3fafa15826758e18e8
Parent:        862899cc88e1697211d478de58b2ddc0eaec9cd9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 25 14:56:07 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 25 17:32:44 2019 +0200

cov: check result of dev_get_block_size

---
 lib/label/label.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 9a3f8df..6d8156e 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1498,7 +1498,10 @@ void dev_set_last_byte(struct device *dev, uint64_t offset)
 	unsigned int phys_block_size = 0;
 	unsigned int block_size = 0;
 
-	dev_get_block_size(dev, &phys_block_size, &block_size);
+	if (!dev_get_block_size(dev, &phys_block_size, &block_size)) {
+		stack;
+		return; /* FIXME: error path ? */
+	}
 
 	bcache_set_last_byte(scan_bcache, dev->bcache_fd, offset, phys_block_size);
 }


