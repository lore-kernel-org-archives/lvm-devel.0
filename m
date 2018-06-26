From: David Teigland <teigland@sourceware.org>
Date: Tue, 26 Jun 2018 13:16:50 -0400
Subject: 2018-06-01-stable - bcache.c add missing {
Message-ID: <201806261716.w5QHGon2005671@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=49147cbaa7b3f73d273593f2353058a0ebf850ba
Commit:        49147cbaa7b3f73d273593f2353058a0ebf850ba
Parent:        69907e0780e0ca5be61d5e5e40d23275937a8c11
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 26 12:15:07 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 26 12:15:43 2018 -0500

bcache.c add missing {

---
 lib/device/bcache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index c7c1909..b1f7d2a 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -560,7 +560,7 @@ static bool _init_free_list(struct bcache *cache, unsigned count, unsigned pgsiz
 		return false;
 
 	cache->raw_blocks = dm_malloc(count * sizeof(*cache->raw_blocks));
-	if (!cache->raw_blocks)
+	if (!cache->raw_blocks) {
 		free(data);
 		return false;
 	}


