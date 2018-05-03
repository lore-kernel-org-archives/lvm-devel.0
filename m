From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 3 May 2018 15:17:34 -0400
Subject: master - bcache: add bcache_block_sectors() query fn
Message-ID: <201805031917.w43JHYJt012408@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b3c41bce3db2124af9296722bd5cda720c943462
Commit:        b3c41bce3db2124af9296722bd5cda720c943462
Parent:        65912ce44dcf8d8b3d9d17a88363f913160a338a
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu May 3 09:33:55 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu May 3 09:33:55 2018 +0100

bcache: add bcache_block_sectors() query fn

---
 lib/device/bcache.c |    5 +++++
 lib/device/bcache.h |    1 +
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 742b7ee..2b50ae5 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -863,6 +863,11 @@ void bcache_destroy(struct bcache *cache)
 	dm_free(cache);
 }
 
+sector_t bcache_block_sectors(struct bcache *cache)
+{
+	return cache->block_sectors;
+}
+
 unsigned bcache_nr_cache_blocks(struct bcache *cache)
 {
 	return cache->nr_cache_blocks;
diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index 6a18d33..db41eeb 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -97,6 +97,7 @@ enum bcache_get_flags {
 	GF_DIRTY = (1 << 1)
 };
 
+sector_t bcache_block_sectors(struct bcache *cache);
 unsigned bcache_nr_cache_blocks(struct bcache *cache);
 unsigned bcache_max_prefetches(struct bcache *cache);
 


