From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 5 Nov 2018 11:27:00 -0500
Subject: master - label: add stack trace for failing dev_set_last_byte
Message-ID: <201811051627.wA5GR0UW005321@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1951e0db0f0cdeddc9d84fbea0fc174ed61e8b9a
Commit:        1951e0db0f0cdeddc9d84fbea0fc174ed61e8b9a
Parent:        5d747f724eb915007fa5d9bbe6539be3cd12d730
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 2 22:19:47 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 3 16:09:36 2018 +0100

label: add stack trace for failing dev_set_last_byte

Temporarily add check for failure, but whole function
needs to be likely traced for error result.

FIXME
---
 lib/label/label.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index c92d2cf..ca8502d 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1341,7 +1341,11 @@ void dev_set_last_byte(struct device *dev, uint64_t offset)
 	unsigned int phys_block_size = 0;
 	unsigned int block_size = 0;
 
-	dev_get_block_size(dev, &phys_block_size, &block_size);
+	if (!dev_get_block_size(dev, &phys_block_size, &block_size)) {
+		stack;
+		/* FIXME  ASSERT or regular error testing is missing */
+		return;
+	}
 
 	bcache_set_last_byte(scan_bcache, dev->bcache_fd, offset, phys_block_size);
 }


