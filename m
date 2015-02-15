From: Eric Wheeler <dm-devel@lists.ewheeler.net>
Date: Sat, 14 Feb 2015 16:31:18 -0800 (PST)
Subject: dm thin: optimize away writing all zeroes to unprovisioned blocks
In-Reply-To: <alpine.DEB.2.02.1501251848330.15396@ware.dreamhost.com>
References: <alpine.DEB.2.00.1409301121470.26721@ware.dreamhost.com>
	<alpine.DEB.2.02.1412032237010.12556@ware.dreamhost.com>
	<alpine.DEB.2.02.1412032318290.29609@ware.dreamhost.com>
	<20141204153358.GA19315@redhat.com> <5481EB1C.4000202@kernel.dk>
	<20141205183342.GA27397@redhat.com>
	<alpine.DEB.2.02.1412061437430.19773@ware.dreamhost.com>
	<5483B04D.5030606@kernel.dk>
	<alpine.DEB.2.02.1412062028500.15919@ware.dreamhost.com>
	<5485D86C.9040800@kernel.dk>
	<alpine.DEB.2.02.1412082258460.10718@ware.dreamhost.com>
	<548715D2.1000509@kernel.dk>
	<alpine.DEB.2.02.1501251848330.15396@ware.dreamhost.com>
Message-ID: <alpine.DEB.2.02.1502141620130.21479@ware.dreamhost.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hey Jens / Joe / Mike / Marian:

I'm checking in for additional feedback on the patch below (intact in 
previous email of this thread) in the hope of meeting the merge window for 
3.20.

I have implemented the following based on your suggestions:
  * pipelining for performance
  * showed that memcmp against zero page is far slower than 
    directly checking for zero
  * minimized cache effects of nonzero data with early minimal nonzero 
    testing before hitting the pipeline
  * implemented configurability via table reload (pf->skip_zero_writes)
  * implemented status via dmsetup status

Do you have any additional considerations that should be addressed before 
pushing this upstream?

-Eric


On Sun, 25 Jan 2015, Eric Wheeler wrote:

> Introduce bio_is_zero_filled() and use it to optimize away writing all
> zeroes to unprovisioned blocks.  Subsequent reads to the associated
> unprovisioned blocks will be zero filled.  
> 
> Single-thread performance evaluates zero bio's at ~8137MB/s under KVM on a
> Xeon E3-1230.  Zero-checks attempt to minimize cache effects on non-zero
> data. bio_is_zero_filled works with unaligned bvec data. (Using memcmp
> and comparing against the zero page is ~5x slower, so this implementation
> was optimized to increase pipelined exectution.)
> 
> The pool_feature pf.skip_zero_writes is implemented and configurable at
> creation time or via table reload.  
> 
> To test we prepare two dm-thinp volumes test1 and test2 of equal size.
> We format test1 without the patch, mount, and extract the Linux source
> tree onto the test1 filesystem, and unmount.  Finally, we activate
> skip_zero_writes, dd test1 over test2, and verify checksums:
>         b210f032a6465178103317f3c40ab59f  /dev/test/test1
>         b210f032a6465178103317f3c40ab59f  /dev/test/test2
> 
> Notice the allocation difference for thin volumes test1 and test2 (after
> dd if=test1 of=test2), even though they have the same md5sum:
>   LV    VG   Attr       LSize Pool  Origin Data%
>   test1 test Vwi-a-tz-- 4.00g thinp         22.04
>   test2 test Vwi-a-tz-- 4.00g thinp         18.33
> 
> An additional 3.71% of space was saved by the patch, and so were the
> ~150MB of (possibly random) IOs that would have hit disk, not to mention
> reads that now bypass the disk since they are unallocated.  We also save
> the metadata overhead of ~2400 provision_block() allocations.
> 
> 
> Signed-off-by: Eric Wheeler <dm-devel@lists.ewheeler.net>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: ejt at redhat.com
> 
> ---
>  Documentation/device-mapper/thin-provisioning.txt |    2 +
>  block/bio.c                                       |  103 +++++++++++++++++++++
>  drivers/md/dm-thin.c                              |   27 ++++++
>  include/linux/bio.h                               |    1 +
>  4 files changed, 133 insertions(+), 0 deletions(-)
>  http://www.globallinuxsecurity.pro/
> 
> diff --git a/Documentation/device-mapper/thin-provisioning.txt b/Documentation/device-mapper/thin-provisioning.txt
> index 2f51735..7304ccf 100644
> --- a/Documentation/device-mapper/thin-provisioning.txt
> +++ b/Documentation/device-mapper/thin-provisioning.txt
> @@ -266,6 +266,8 @@ i) Constructor
>  
>        error_if_no_space: Error IOs, instead of queueing, if no space.
>  
> +	  enable_zero_writes: Enable all-zero writes to unallocated blocks. 
> +    
>      Data block size must be between 64KB (128 sectors) and 1GB
>      (2097152 sectors) inclusive.
>  
> diff --git a/block/bio.c b/block/bio.c
> index 8c2e55e..7e372b7 100644
> --- a/block/bio.c
> +++ b/block/bio.c
> @@ -511,6 +511,109 @@ void zero_fill_bio(struct bio *bio)
>  }
>  EXPORT_SYMBOL(zero_fill_bio);
>  
> +__attribute__((optimize("unroll-loops")))
> +bool bio_is_zero_filled(struct bio *bio)
> +{
> +	struct bio_vec bv;
> +	struct bvec_iter iter;
> +	char *data, *p;
> +	__uint128_t *p128;
> +
> +	unsigned i, count, left;
> +	unsigned long flags;
> +
> +	/* Align to the data chunk size */
> +	const int align_to = sizeof(__uint128_t);
> +
> +	p128 = NULL;
> +	bio_for_each_segment(bv, bio, iter) {
> +		data = bvec_kmap_irq(&bv, &flags);
> +		p = data;
> +		left = bv.bv_len;
> +
> +		if (unlikely( data == NULL ))
> +			continue;
> +
> +		/* check unaligned bytes at the beginning of p, if any */
> +		if (unlikely( ( (uintptr_t)p & (align_to-1) ) != 0 )) {
> +			count = align_to - ( (uintptr_t)p & (align_to-1) );
> +			for (i = 0; i < count; i++) {
> +				if (*p) 
> +					break;
> +				p++;
> +			}
> +			if (i < count)
> +				goto out_false;
> +			left -= count;
> +		}
> +
> +		/* we should be align_to-byte aligned now */
> +		BUG_ON(unlikely( ((uintptr_t)p & (align_to-1) ) != 0 ));
> +
> +		p128 = (__uint128_t*)p;
> +		count = left >> 9; /* count = left / (32*16) */
> +
> +		/* Quickly sample first, middle, and last values 
> +		 * and exit early without hitting the loop if nonzero.
> +		 * This reduces cache effects for non-zero data and has almost
> +		 * no effective penalty since these values will probably be in 
> +		 * cache when we test them below.
> +		 */
> +		if (likely(count) &&
> +			   (p128[0] || p128[left>>5] || p128[(left>>4)-1]))
> +			goto out_false;
> +
> +		/* We are using __uint128_t here, so 32*16=512 bytes per loop 
> +		 * Writing out the 32 operations helps with pipelining. */
> +		for (i = 0; i < count; i++) {
> +			if (p128[ 0] | p128[ 1] | p128[ 2] | p128[ 3] |
> +			    p128[ 4] | p128[ 5] | p128[ 6] | p128[ 7] |
> +			    p128[ 8] | p128[ 9] | p128[10] | p128[11] |
> +			    p128[12] | p128[13] | p128[14] | p128[15] |
> +			    p128[16] | p128[17] | p128[18] | p128[19] |
> +			    p128[20] | p128[21] | p128[22] | p128[23] |
> +			    p128[24] | p128[25] | p128[26] | p128[27] |
> +			    p128[28] | p128[29] | p128[30] | p128[31])
> +				break;
> +
> +			p128 += 32;
> +		}
> +		if (i < count)
> +			goto out_false;
> +
> +		left -= count << 9; /* left -= count * 32*16 */
> +
> +		/* check remaining unaligned values at the end, if any */
> +		if (unlikely(left > 0))	{
> +			p = (char*)p128;
> +			for (i = 0; i < left; i++) {
> +				if (*p)
> +					break;
> +				p++;
> +			}
> +			if (i < left)
> +				goto out_false;
> +
> +			/* Fixup values for the BUG_ON checks below */
> +			p128 = (__uint128_t*)p;
> +			left = 0;
> +		}
> +
> +		bvec_kunmap_irq(data, &flags);
> +		BUG_ON(unlikely( left > 0 ));
> +		BUG_ON(unlikely( data+bv.bv_len != (char*)p128 ));
> +	}
> +
> +	return true;
> +
> +out_false:
> +	if (likely(data != NULL))
> +		bvec_kunmap_irq(data, &flags);
> +
> +	return false;
> +}
> +EXPORT_SYMBOL(bio_is_zero_filled);
> +
>  /**
>   * bio_put - release a reference to a bio
>   * @bio:   bio to release reference to
> diff --git a/drivers/md/dm-thin.c b/drivers/md/dm-thin.c
> index fc9c848..d0cebd2 100644
> --- a/drivers/md/dm-thin.c
> +++ b/drivers/md/dm-thin.c
> @@ -151,6 +151,7 @@ struct pool_features {
>  	bool discard_enabled:1;
>  	bool discard_passdown:1;
>  	bool error_if_no_space:1;
> +	bool skip_zero_writes:1;
>  };
>  
>  struct thin_c;
> @@ -1258,6 +1259,16 @@ static void provision_block(struct thin_c *tc, struct bio *bio, dm_block_t block
>  		return;
>  	}
>  
> +        /*
> +	 *  Skip writes of all zeroes to unprovisioned blocks.
> +	 */
> +
> +	if (tc->pool->pf.skip_zero_writes && bio_is_zero_filled(bio) ) {
> +		cell_defer_no_holder(tc, cell);
> +		bio_endio(bio, 0);
> +		return;
> +	}
> +
>  	r = alloc_data_block(tc, &data_block);
>  	switch (r) {
>  	case 0:
> @@ -2063,6 +2074,7 @@ static void pool_features_init(struct pool_features *pf)
>  	pf->discard_enabled = true;
>  	pf->discard_passdown = true;
>  	pf->error_if_no_space = false;
> +	pf->skip_zero_writes = true;
>  }
>  
>  static void __pool_destroy(struct pool *pool)
> @@ -2310,6 +2322,9 @@ static int parse_pool_features(struct dm_arg_set *as, struct pool_features *pf,
>  		else if (!strcasecmp(arg_name, "error_if_no_space"))
>  			pf->error_if_no_space = true;
>  
> +		else if (!strcasecmp(arg_name, "enable_zero_writes"))
> +			pf->skip_zero_writes = false;
> +
>  		else {
>  			ti->error = "Unrecognised pool feature requested";
>  			r = -EINVAL;
> @@ -2393,6 +2408,7 @@ static dm_block_t calc_metadata_threshold(struct pool_c *pt)
>   *	     no_discard_passdown: don't pass discards down to the data device
>   *	     read_only: Don't allow any changes to be made to the pool metadata.
>   *	     error_if_no_space: error IOs, instead of queueing, if no space.
> + *	     enable_zero_writes: Enable all-zero writes to unallocated blocks.
>   */
>  static int pool_ctr(struct dm_target *ti, unsigned argc, char **argv)
>  {
> @@ -2511,6 +2527,9 @@ static int pool_ctr(struct dm_target *ti, unsigned argc, char **argv)
>  	}
>  	ti->private = pt;
>  
> +	/* The pf skip_zero_writes is safe to change at any time */
> +	pool->pf.skip_zero_writes = pf.skip_zero_writes;
> +
>  	r = dm_pool_register_metadata_threshold(pt->pool->pmd,
>  						calc_metadata_threshold(pt),
>  						metadata_low_callback,
> @@ -2936,6 +2955,9 @@ static void emit_flags(struct pool_features *pf, char *result,
>  
>  	if (pf->error_if_no_space)
>  		DMEMIT("error_if_no_space ");
> +	
> +	if (!pf->skip_zero_writes)
> +		DMEMIT("enable_zero_writes ");
>  }
>  
>  /*
> @@ -3043,6 +3065,11 @@ static void pool_status(struct dm_target *ti, status_type_t type,
>  		else
>  			DMEMIT("queue_if_no_space ");
>  
> +		if (!pool->pf.skip_zero_writes)
> +			DMEMIT("enable_zero_writes ");
> +		else
> +			DMEMIT("skip_zero_writes ");
> +
>  		break;
>  
>  	case STATUSTYPE_TABLE:
> diff --git a/include/linux/bio.h b/include/linux/bio.h
> index 5a64576..abb46f7 100644
> --- a/include/linux/bio.h
> +++ b/include/linux/bio.h
> @@ -419,6 +419,7 @@ extern struct bio *bio_copy_user_iov(struct request_queue *,
>  				     int, int, gfp_t);
>  extern int bio_uncopy_user(struct bio *);
>  void zero_fill_bio(struct bio *bio);
> +bool bio_is_zero_filled(struct bio *bio);
>  extern struct bio_vec *bvec_alloc(gfp_t, int, unsigned long *, mempool_t *);
>  extern void bvec_free(mempool_t *, struct bio_vec *, unsigned int);
>  extern unsigned int bvec_nr_vecs(unsigned short idx);
> -- 
> 1.7.1
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
> 


