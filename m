From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 26 Jun 2018 11:18:14 -0400
Subject: 2018-06-01-stable - bcache: Fix null pointer dereferencing
Message-ID: <201806261518.w5QFIEv2020601@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=69907e0780e0ca5be61d5e5e40d23275937a8c11
Commit:        69907e0780e0ca5be61d5e5e40d23275937a8c11
Parent:        b90d4b38e53f72b8144bd71f1d41a95d0a2f1570
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Jun 26 17:04:18 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Jun 26 17:09:58 2018 +0200

bcache: Fix null pointer dereferencing

(cherry picked from commit a14f21bf1ddbb93b13a917cad8720fed6c94d6de)

Conflicts:
	lib/device/bcache.c
---
 lib/device/bcache.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 3b78047..c7c1909 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -559,11 +559,13 @@ static bool _init_free_list(struct bcache *cache, unsigned count, unsigned pgsiz
 	if (!data)
 		return false;
 
-	cache->raw_data = data;
 	cache->raw_blocks = dm_malloc(count * sizeof(*cache->raw_blocks));
-
 	if (!cache->raw_blocks)
-		dm_free(cache->raw_data);
+		free(data);
+		return false;
+	}
+
+	cache->raw_data = data;
 
 	for (i = 0; i < count; i++) {
 		struct block *b = cache->raw_blocks + i;


