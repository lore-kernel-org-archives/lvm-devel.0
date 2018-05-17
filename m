From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 17 May 2018 04:48:00 -0400
Subject: master - bcache: don't use PAGE_SIZE compile const
Message-ID: <201805170848.w4H8m0Or012931@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c6ca81a38d7012ec9d18a9ea00eff321ff2c47d0
Commit:        c6ca81a38d7012ec9d18a9ea00eff321ff2c47d0
Parent:        8c453e2e5e5a660b1923629365c8bb87ef017a8f
Author:        Alex Benn??e <alex.bennee@linaro.org>
AuthorDate:    Wed May 16 21:19:03 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 17 10:38:16 2018 +0200

bcache: don't use PAGE_SIZE compile const

PAGE_SIZE is not a compile time constant. Use sysconf instead like
elsewhere in the code.

Signed-off-by: Alex Benn??e <alex.bennee@linaro.org>
---
 lib/device/bcache.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 30df54a..3f5a45e 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -162,8 +162,9 @@ static bool _async_issue(struct io_engine *ioe, enum dir d, int fd,
 	struct iocb *cb_array[1];
 	struct control_block *cb;
 	struct async_engine *e = _to_async(ioe);
+	long pgsize = sysconf(_SC_PAGESIZE);
 
-	if (((uintptr_t) data) & (PAGE_SIZE - 1)) {
+	if (((uintptr_t) data) & (pgsize - 1)) {
 		log_warn("misaligned data buffer");
 		return false;
 	}
@@ -547,8 +548,9 @@ static bool _init_free_list(struct bcache *cache, unsigned count)
 {
 	unsigned i;
 	size_t block_size = cache->block_sectors << SECTOR_SHIFT;
+	long pgsize = sysconf(_SC_PAGESIZE);
 	unsigned char *data =
-		(unsigned char *) _alloc_aligned(count * block_size, PAGE_SIZE);
+		(unsigned char *) _alloc_aligned(count * block_size, pgsize);
 
 	/* Allocate the data for each block.  We page align the data. */
 	if (!data)
@@ -899,6 +901,7 @@ struct bcache *bcache_create(sector_t block_sectors, unsigned nr_cache_blocks,
 {
 	struct bcache *cache;
 	unsigned max_io = engine->max_io(engine);
+	long pgsize = sysconf(_SC_PAGESIZE);
 
 	if (!nr_cache_blocks) {
 		log_warn("bcache must have at least one cache block");
@@ -910,7 +913,7 @@ struct bcache *bcache_create(sector_t block_sectors, unsigned nr_cache_blocks,
 		return NULL;
 	}
 
-	if (block_sectors & ((PAGE_SIZE >> SECTOR_SHIFT) - 1)) {
+	if (block_sectors & ((pgsize >> SECTOR_SHIFT) - 1)) {
 		log_warn("bcache block size must be a multiple of page size");
 		return NULL;
 	}


