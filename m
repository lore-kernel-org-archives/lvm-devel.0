From: Mike Snitzer <snitzer@redhat.com>
Date: Thu, 4 Dec 2014 10:33:59 -0500
Subject: [PATCH] dm thin: optimize away writing all zeroes to unprovisioned blocks
In-Reply-To: <alpine.DEB.2.02.1412032318290.29609@ware.dreamhost.com>
References: <alpine.DEB.2.00.1409301121470.26721@ware.dreamhost.com>
	<alpine.DEB.2.02.1412032237010.12556@ware.dreamhost.com>
	<alpine.DEB.2.02.1412032318290.29609@ware.dreamhost.com>
Message-ID: <20141204153358.GA19315@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

In the future please send DM changes to dm-devel at redhat.com

Comments inlined below, and I've provided a revised patch at the end.

On Thu, Dec 04 2014 at  2:25am -0500,
Eric Wheeler <ewheeler@ewheeler.net> wrote:

> This patch skips all-zero writes to unallocated blocks of dm-thinp volumes.
> 
> Unallocated zero-writes are 70x faster and never allocate space in this test:
>         # dd if=/dev/zero of=/dev/test/test1 bs=1M count=1024
>         1073741824 bytes (1.1 GB) copied, 0.794343 s, 1.4 GB/s
> 
> Without the patch, zero-writes allocate space and hit the disk:
>         # dd if=/dev/zero of=/dev/test/test1 bs=1M count=1024
>         1073741824 bytes (1.1 GB) copied, 53.8064 s, 20.0 MB/s
> 
> For the test below, notice the allocation difference for thin volumes
> test1 and test2 (after dd if=test1 of=test2), even though they have the
> same md5sum:
>   LV    VG   Attr       LSize Pool  Origin Data%
>   test1 test Vwi-a-tz-- 4.00g thinp         22.04
>   test2 test Vwi-a-tz-- 4.00g thinp         18.33
> 
> An additional 3.71% of space was saved by the patch, and so were
> the ~150MB of (possibly random) IOs that would have hit disk, not to
> mention reads that now bypass the disk since they are unallocated.
> We also save the metadata overhead of ~2400 allocations when calling
> provision_block().
> 
>         # lvcreate -T test/thinp -L 5G
>         # lvcreate -T test/thinp -V 4G -n test1
>         # lvcreate -T test/thinp -V 4G -n test2
> 
> Simple ext4+kernel tree extract test:
> 
> First prepare two dm-thinp volumes test1 and test2 of equal size.  First
> mkfs.ext4 /dev/test/test1 without the patch and then mount and extract
> 3.17.4's source tree onto the test1 filesystem, and unmount
> 
> Next, install patched dm_thin_pool.ko, then dd test1 over test2 and
> verify checksums:
>         # dd if=/dev/test/test1  of=/dev/test/test2 bs=1M
>         # md5sum /dev/test/test?
>         b210f032a6465178103317f3c40ab59f  /dev/test/test1
>         b210f032a6465178103317f3c40ab59f  /dev/test/test2
> Yes, they match!
> 
> 
> Signed-off-by: Eric Wheeler <lvm-dev@lists.ewheeler.net>
> ---
>  Resending the patch as it was malformed on the first try.

The resend was also malformed.. but don't worry about resending for this
patch.

> diff --git a/drivers/md/dm-thin.c b/drivers/md/dm-thin.c
> index fc9c848..71dd545 100644
> --- a/drivers/md/dm-thin.c
> +++ b/drivers/md/dm-thin.c
> @@ -1230,6 +1230,42 @@ static void process_shared_bio(struct thin_c *tc, struct bio *bio,
>  	}
>  }

A helper like this really belongs in block/bio.c:

> +/* return true if bio data contains all 0x00's */
> +bool bio_all_zeros(struct bio *bio) +{
> +	unsigned long flags;
> +	struct bio_vec bv;
> +	struct bvec_iter iter;
> +
> +	char *data;
> +	uint64_t *p;
> +	int i, count;
> + +	bool allzeros = true;
> +
> +	bio_for_each_segment(bv, bio, iter) {
> +		data = bvec_kmap_irq(&bv, &flags);
> +
> +		p = (uint64_t*)data;
> +		count = bv.bv_len / sizeof(uint64_t);

Addressing a bio's contents in terms of uint64_t has the potential to
access beyond bv.bv_len (byte addressing vs 64bit addressing).  I can
see you were just looking to be more efficient about checking the bios'
contents but I'm not convinced it would always be safe.

I'm open to something more efficient than what I implemented below, but
it is the most straight-forward code I thought of.

> +
> +		for (i = 0; i < count; i++) {
> +			if (*p)	{
> +				allzeros = false;
> +				break;
> +			}
> +			p++;
> +		}
> +
> +		bvec_kunmap_irq(data, &flags);
> +
> +		if (likely(!allzeros))
> +				break;
> +	}
> +
> +	return allzeros;
> +}
> +
>  static void provision_block(struct thin_c *tc, struct bio *bio, dm_block_t block,
>  			    struct dm_bio_prison_cell *cell)
>  {
> @@ -1258,6 +1294,15 @@ static void provision_block(struct thin_c *tc, struct bio *bio, dm_block_t block
>  		return;
>  	}
> 
> +	/*
> +	 * Skip writes of all zeroes
> +	 */
> +	if (bio_data_dir(bio) == WRITE && unlikely( bio_all_zeros(bio) )) {
> +		cell_defer_no_holder(tc, cell);
> +		bio_endio(bio, 0);
> +		return;
> +	}
> +

No need to check for bio_data_dir(bio) == WRITE (at this point in
provision_block() we already know it is a WRITE).

Here is a revised patch that is more like I'd expect to land upstream.
Jens are you OK with us adding bio_is_zero_filled to block/bio.c?  If so
should I split it out as a separate patch for you to pick up or just
carry it as part of the patch that lands in linux-dm.git?


From: Mike Snitzer <snitzer@redhat.com>
Date: Thu, 4 Dec 2014 10:18:32 -0500
Subject: [PATCH] dm thin: optimize away writing all zeroes to unprovisioned blocks

Introduce bio_is_zero_filled() and use it to optimize away writing all
zeroes to unprovisioned blocks.  Subsequent reads to the associated
unprovisioned blocks will be zero filled.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
Cc: Eric Wheeler <ewheeler@ewheeler.net>
Cc: Jens Axboe <axboe@kernel.dk>
---
 block/bio.c          |   25 +++++++++++++++++++++++++
 drivers/md/dm-thin.c |   10 ++++++++++
 include/linux/bio.h  |    1 +
 3 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index 3e6e198..7d07593 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -515,6 +515,31 @@ void zero_fill_bio(struct bio *bio)
 }
 EXPORT_SYMBOL(zero_fill_bio);
 
+bool bio_is_zero_filled(struct bio *bio)
+{
+	unsigned i;
+	unsigned long flags;
+	struct bio_vec bv;
+	struct bvec_iter iter;
+
+	bio_for_each_segment(bv, bio, iter) {
+		char *data = bvec_kmap_irq(&bv, &flags);
+		char *p = data;
+
+		for (i = 0; i < bv.bv_len; i++) {
+			if (*p) {
+				bvec_kunmap_irq(data, &flags);
+				return false;
+			}
+			p++;
+		}
+		bvec_kunmap_irq(data, &flags);
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
index 8735543..13aff8c 100644
--- a/drivers/md/dm-thin.c
+++ b/drivers/md/dm-thin.c
@@ -1501,6 +1501,16 @@ static void provision_block(struct thin_c *tc, struct bio *bio, dm_block_t block
 		return;
 	}
 
+	/*
+	 * Optimize away writes of all zeroes, subsequent reads to
+	 * associated unprovisioned blocks will be zero filled.
+	 */
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
index 7347f48..602094b 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -465,6 +465,7 @@ extern struct bio *bio_copy_user_iov(struct request_queue *,
 				     int, int, gfp_t);
 extern int bio_uncopy_user(struct bio *);
 void zero_fill_bio(struct bio *bio);
+bool bio_is_zero_filled(struct bio *bio);
 extern struct bio_vec *bvec_alloc(gfp_t, int, unsigned long *, mempool_t *);
 extern void bvec_free(mempool_t *, struct bio_vec *, unsigned int);
 extern unsigned int bvec_nr_vecs(unsigned short idx);
-- 
1.7.4.4


