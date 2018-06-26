From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 26 Jun 2018 11:06:37 -0400
Subject: master - bcache: Fix null pointer dereferencing
Message-ID: <201806261506.w5QF6bW5019086@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a14f21bf1ddbb93b13a917cad8720fed6c94d6de
Commit:        a14f21bf1ddbb93b13a917cad8720fed6c94d6de
Parent:        4194fc9bbdc9107120ba09c22e56612d854fdd41
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Jun 26 17:04:18 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Jun 26 17:04:18 2018 +0200

bcache: Fix null pointer dereferencing

---
 lib/device/bcache.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index f315b2a..8d55c36 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -528,11 +528,13 @@ static bool _init_free_list(struct bcache *cache, unsigned count, unsigned pgsiz
 	if (!data)
 		return false;
 
-	cache->raw_data = data;
 	cache->raw_blocks = malloc(count * sizeof(*cache->raw_blocks));
+	if (!cache->raw_blocks) {
+		free(data);
+		return false;
+	}
 
-	if (!cache->raw_blocks)
-		free(cache->raw_data);
+	cache->raw_data = data;
 
 	for (i = 0; i < count; i++) {
 		struct block *b = cache->raw_blocks + i;


