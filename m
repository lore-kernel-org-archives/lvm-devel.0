From: Joe Thornber <thornber@sourceware.org>
Date: Tue, 11 Sep 2018 08:27:18 -0400
Subject: master - [bcache] Remove unused 'hash' field from blocks.
Message-ID: <201809111227.w8BCRIUB002381@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3255e384dbd567a4d6ddec8dc3eaac2d16476d3c
Commit:        3255e384dbd567a4d6ddec8dc3eaac2d16476d3c
Parent:        4d964133e267b2b501a5dcd40c30cfdcfaa5903a
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Tue Sep 11 13:17:29 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Tue Sep 11 13:17:29 2018 +0100

[bcache] Remove unused 'hash' field from blocks.

We use a radix tree these days rather than a hash table.
---
 lib/device/bcache.c |    1 -
 lib/device/bcache.h |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index e759997..5e795c5 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -757,7 +757,6 @@ static struct block *_new_block(struct bcache *cache, int fd, block_address i, b
 
 	if (b) {
 		dm_list_init(&b->list);
-		dm_list_init(&b->hash);
 		b->flags = 0;
 		b->fd = fd;
 		b->index = i;
diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index ae5e69c..1d49af2 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -62,7 +62,6 @@ struct block {
 
 	struct bcache *cache;
 	struct dm_list list;
-	struct dm_list hash;
 
 	unsigned flags;
 	unsigned ref_count;


