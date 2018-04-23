From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:47:40 -0400
Subject: master - [device/bcache] fix min() function
Message-ID: <201804231347.w3NDle79031330@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7be54bd687ead6aa21e04c8a85a648da369a3d88
Commit:        7be54bd687ead6aa21e04c8a85a648da369a3d88
Parent:        d9e6298edb0bc6533c22f7e95e613189abe89c99
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 8 11:16:19 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:12:50 2018 -0500

[device/bcache] fix min() function

---
 lib/device/bcache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index cea4db4..52be947 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -997,7 +997,7 @@ void bcache_prefetch_bytes(struct bcache *cache, int fd, off_t start, size_t len
 
 static off_t _min(off_t lhs, off_t rhs)
 {
-	if (rhs > lhs)
+	if (rhs < lhs)
 		return rhs;
 
 	return lhs;


