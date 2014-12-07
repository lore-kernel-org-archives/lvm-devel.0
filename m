From: Eric Wheeler <lvm-dev@lists.ewheeler.net>
Date: Sat, 6 Dec 2014 22:45:19 -0800 (PST)
Subject: dm thin: optimize away writing all zeroes to unprovisioned blocks
In-Reply-To: <alpine.DEB.2.02.1412062028500.15919@ware.dreamhost.com>
References: <alpine.DEB.2.00.1409301121470.26721@ware.dreamhost.com>
	<alpine.DEB.2.02.1412032237010.12556@ware.dreamhost.com>
	<alpine.DEB.2.02.1412032318290.29609@ware.dreamhost.com>
	<20141204153358.GA19315@redhat.com> <5481EB1C.4000202@kernel.dk>
	<20141205183342.GA27397@redhat.com>
	<alpine.DEB.2.02.1412061437430.19773@ware.dreamhost.com>
	<5483B04D.5030606@kernel.dk>
	<alpine.DEB.2.02.1412062028500.15919@ware.dreamhost.com>
Message-ID: <alpine.DEB.2.02.1412062239220.27558@ware.dreamhost.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Introduce bio_is_zero_filled() and use it to optimize away writing all
zeroes to unprovisioned blocks.  Subsequent reads to the associated
unprovisioned blocks will be zero filled.  bio_is_zero_filled now 
works with unaligned bvec data.

Signed-off-by: Eric Wheeler <dm-devel@lists.ewheeler.net>
Cc: Mike Snitzer <snitzer@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>

---
> Also, attached is the patch that supports uintptr_t word sized 0-checks. 
Re-sending.  I think I've fixed my MUA's tendency to break patches.

 block/bio.c          |   67 ++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/md/dm-thin.c |   10 +++++++
 include/linux/bio.h  |    1 +
 3 files changed, 78 insertions(+), 0 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index 8c2e55e..9100d35 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -511,6 +511,73 @@ void zero_fill_bio(struct bio *bio)
 }
 EXPORT_SYMBOL(zero_fill_bio);
 
+bool bio_is_zero_filled(struct bio *bio)
+{
+	unsigned i, count;
+	unsigned long flags;
+	struct bio_vec bv;
+	struct bvec_iter iter;
+	bio_for_each_segment(bv, bio, iter) {
+		char *data = bvec_kmap_irq(&bv, &flags);
+		char *p = data;
+		uintptr_t *parch;
+		int left = bv.bv_len;
+
+		if (unlikely( data == NULL ))
+			continue;
+
+
+		/* check unaligned bytes at the beginning of p */
+		if (unlikely( ( (uintptr_t)p & (sizeof(uintptr_t)-1) ) != 0 )) {
+			count = sizeof(uintptr_t) - ( (uintptr_t)p & (sizeof(uintptr_t)-1) );
+			for (i = 0; i < count; i++) {
+				if (*p) {
+					bvec_kunmap_irq(data, &flags);
+					return false;
+				}
+				p++;
+			}
+			left -= count;
+		}
+
+		/* we should be word aligned now */
+		BUG_ON(unlikely( ((uintptr_t)p & (sizeof(uintptr_t)-1) ) != 0 ));
+
+		/* now check in word-sized chunks */
+		parch = (uintptr_t*)p;
+		count = left >> ilog2(sizeof(uintptr_t)); /* count = left / sizeof(uintptr_t) */;
+		for (i = 0; i < count; i++) {
+			if (*parch) {
+				bvec_kunmap_irq(data, &flags);
+				return false;
+			}
+			parch++;
+		}
+		left -= count << ilog2(sizeof(uintptr_t)); /* left -= count*sizeof(uintptr_t) */
+
+		/* check remaining unaligned values@the end */
+		p = (char*)parch;
+		if (unlikely(left > 0))
+		{
+			for (i = 0; i < left; i++) {
+				if (*p) {
+					bvec_kunmap_irq(data, &flags);
+					return false;
+				}
+				p++; 
+			}
+			left = 0;
+		}
+
+		bvec_kunmap_irq(data, &flags);
+		BUG_ON(unlikely( left > 0 ));
+		BUG_ON(unlikely( data+bv.bv_len != p ));
+	}
+
+	return true;
+}
+EXPORT_SYMBOL(bio_is_zero_filled);
+
 /**
  * bio_put - release a reference to a bio
  * @bio:   bio to release reference to
diff --git a/drivers/md/dm-thin.c b/drivers/md/dm-thin.c
index fc9c848..6a0c2c0 100644
--- a/drivers/md/dm-thin.c
+++ b/drivers/md/dm-thin.c
@@ -1258,6 +1258,16 @@ static void provision_block(struct thin_c *tc, struct bio *bio, dm_block_t block
 		return;
 	}
 
+	/*
+	* Optimize away writes of all zeroes, subsequent reads to
+	* associated unprovisioned blocks will be zero filled.
+	*/
+	if (unlikely(bio_is_zero_filled(bio))) {
+		cell_defer_no_holder(tc, cell);
+		bio_endio(bio, 0);
+		return;
+	}
+
 	r = alloc_data_block(tc, &data_block);
 	switch (r) {
 	case 0:
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 5a64576..abb46f7 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -419,6 +419,7 @@ extern struct bio *bio_copy_user_iov(struct request_queue *,
 				     int, int, gfp_t);
 extern int bio_uncopy_user(struct bio *);
 void zero_fill_bio(struct bio *bio);
+bool bio_is_zero_filled(struct bio *bio);
 extern struct bio_vec *bvec_alloc(gfp_t, int, unsigned long *, mempool_t *);
 extern void bvec_free(mempool_t *, struct bio_vec *, unsigned int);
 extern unsigned int bvec_nr_vecs(unsigned short idx);
-- 
1.7.1


