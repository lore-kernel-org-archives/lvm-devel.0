From: Eric Wheeler <lvm-dev@lists.ewheeler.net>
Date: Wed, 3 Dec 2014 23:05:08 -0800 (PST)
Subject: [PATCH] dm-thinp: skip allocation on writes of all zeros to unallocated blocks
In-Reply-To: <alpine.DEB.2.00.1409301121470.26721@ware.dreamhost.com>
References: <alpine.DEB.2.00.1409301121470.26721@ware.dreamhost.com>
Message-ID: <alpine.DEB.2.02.1412032237010.12556@ware.dreamhost.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch skips all-zero writes to unallocated blocks of dm-thinp 
volumes.

Unallocated zero-writes are 70x faster and never allocate space in this test:
         # dd if=/dev/zero of=/dev/test/test1 bs=1M count=1024
         1073741824 bytes (1.1 GB) copied, 0.794343 s, 1.4 GB/s

Without the patch, zero-writes allocate space and hit the disk:
         # dd if=/dev/zero of=/dev/test/test1 bs=1M count=1024
         1073741824 bytes (1.1 GB) copied, 53.8064 s, 20.0 MB/s

For the test below, notice the allocation difference for thin volumes
test1 and test2 (after dd if=test1 of=test2), even though they have the
same md5sum:
   LV    VG   Attr       LSize Pool  Origin Data%
   test1 test Vwi-a-tz-- 4.00g thinp         22.04
   test2 test Vwi-a-tz-- 4.00g thinp         18.33

An additional 3.71% of space was saved by the patch, and so were
the ~150MB of (possibly random) IOs that would have hit disk, not to
mention reads that now bypass the disk since they are unallocated.
We also save the metadata overhead of ~2400 allocations when calling
provision_block().

         # lvcreate -T test/thinp -L 5G
         # lvcreate -T test/thinp -V 4G -n test1
         # lvcreate -T test/thinp -V 4G -n test2

Simple ext4+kernel tree extract test:

First prepare two dm-thinp volumes test1 and test2 of equal size.  First
mkfs.ext4 /dev/test/test1 without the patch and then mount and extract
3.17.4's source tree onto the test1 filesystem, and unmount

Next, install patched dm_thin_pool.ko, then dd test1 over test2 and
verify checksums:
         # dd if=/dev/test/test1  of=/dev/test/test2 bs=1M
         # md5sum /dev/test/test?
         b210f032a6465178103317f3c40ab59f  /dev/test/test1
         b210f032a6465178103317f3c40ab59f  /dev/test/test2
Yes, they match!

Signed-off-by: Eric Wheeler <lvm-dev@lists.ewheeler.net>
---
  drivers/md/dm-thin.c |   45 +++++++++++++++++++++++++++++++++++++++++++++
  1 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/drivers/md/dm-thin.c b/drivers/md/dm-thin.c
index fc9c848..71dd545 100644
--- a/drivers/md/dm-thin.c
+++ b/drivers/md/dm-thin.c
@@ -1230,6 +1230,42 @@ static void process_shared_bio(struct thin_c *tc, struct bio *bio,
  	}
  }

+/* return true if bio data contains all 0x00's */
+bool bio_all_zeros(struct bio *bio) 
+{
+	unsigned long flags;
+	struct bio_vec bv;
+	struct bvec_iter iter;
+
+	char *data;
+	uint64_t *p;
+	int i, count;
+ 
+	bool allzeros = true;
+
+	bio_for_each_segment(bv, bio, iter) {
+		data = bvec_kmap_irq(&bv, &flags);
+
+		p = (uint64_t*)data;
+		count = bv.bv_len / sizeof(uint64_t);
+
+		for (i = 0; i < count; i++) {
+			if (*p)	{
+				allzeros = false;
+				break;
+			}
+			p++;
+		}
+
+		bvec_kunmap_irq(data, &flags);
+
+		if (likely(!allzeros))
+				break;
+	}
+
+	return allzeros;
+}
+
  static void provision_block(struct thin_c *tc, struct bio *bio, dm_block_t block,
  			    struct dm_bio_prison_cell *cell)
  {
@@ -1258,6 +1294,15 @@ static void provision_block(struct thin_c *tc, struct bio *bio, dm_block_t block
  		return;
  	}

+	/*
+	 * Skip writes of all zeroes
+	 */
+	if (bio_data_dir(bio) == WRITE && unlikely( bio_all_zeros(bio) )) {
+		cell_defer_no_holder(tc, cell);
+		bio_endio(bio, 0);
+		return;
+	}
+
  	r = alloc_data_block(tc, &data_block);
  	switch (r) {
  	case 0:
-- 
1.7.1


