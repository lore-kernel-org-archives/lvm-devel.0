From: Eric Wheeler <dm-devel@lists.ewheeler.net>
Date: Tue, 7 Jan 2020 18:47:36 +0000 (UTC)
Subject: [dm-devel] kernel BUG at drivers/md/persistent-data/dm-space-map-disk.c:178
In-Reply-To: <20200107122825.qr7o5d6dpwa6kv62@reti>
References: <alpine.LRH.2.11.1909251814220.15810@mx.ewheeler.net>
	<alpine.LRH.2.11.1912201829300.26683@mx.ewheeler.net>
	<alpine.LRH.2.11.1912270137420.26683@mx.ewheeler.net>
	<alpine.LRH.2.11.1912271946380.26683@mx.ewheeler.net>
	<20200107103546.asf4tmlfdmk6xsub@reti>
	<20200107104627.plviq37qhok2igt4@reti>
	<20200107122825.qr7o5d6dpwa6kv62@reti>
Message-ID: <alpine.LRH.2.11.2001071845350.2074@mx.ewheeler.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, 7 Jan 2020, Joe Thornber wrote:

> On Tue, Jan 07, 2020 at 10:46:27AM +0000, Joe Thornber wrote:
> > I'll get a patch to you later today.
> 
> Eric,
> 
> Patch below.  I've run it through a bunch of tests in the dm test suite.  But
> obviously I have never hit your issue.  Will do more testing today.


Thank you Joe, I'll apply the patch and pull out the spinlock.  

I'm not familiar with how sync IO prevents a spinlock.  Can you give a 
brief explaination or point me at documentation?

--
Eric Wheeler



> 
> - Joe
> 
> 
> 
> Author: Joe Thornber <ejt@redhat.com>
> Date:   Tue Jan 7 11:58:42 2020 +0000
> 
>     [dm-thin, dm-cache] Fix bug in space-maps.
>     
>     The space-maps track the reference counts for disk blocks.  There are variants
>     for tracking metadata blocks, and data blocks.
>     
>     We implement transactionality by never touching blocks from the previous
>     transaction, so we can rollback in the event of a crash.
>     
>     When allocating a new block we need to ensure the block is free (has reference
>     count of 0) in both the current and previous transaction.  Prior to this patch we
>     were doing this by searching for a free block in the previous transaction, and
>     relying on a 'begin' counter to track where the last allocation in the current
>     transaction was.  This 'begin' field was not being updated in all code paths (eg,
>     increment of a data block reference count due to breaking sharing of a neighbour
>     block in the same btree leaf).
>     
>     This patch keeps the 'begin' field, but now it's just a hint to speed up the search.
>     Instead we search the current transaction for a free block, and then double check
>     it's free in the old transaction.  Much simpler.
> 
> diff --git a/drivers/md/persistent-data/dm-space-map-common.c b/drivers/md/persistent-data/dm-space-map-common.c
> index bd68f6fef694..b4983e4022e6 100644
> --- a/drivers/md/persistent-data/dm-space-map-common.c
> +++ b/drivers/md/persistent-data/dm-space-map-common.c
> @@ -380,6 +380,34 @@ int sm_ll_find_free_block(struct ll_disk *ll, dm_block_t begin,
>  	return -ENOSPC;
>  }
>  
> +int sm_ll_find_common_free_block(struct ll_disk *old_ll, struct ll_disk *new_ll,
> +	                         dm_block_t begin, dm_block_t end, dm_block_t *b)
> +{
> +	int r;
> +	uint32_t count;
> +
> +	do {
> +		r = sm_ll_find_free_block(new_ll, begin, new_ll->nr_blocks, b);
> +		if (r)
> +			break;
> +
> +		/* double check this block wasn't used in the old transaction */
> +		if (*b >= old_ll->nr_blocks)
> +			count = 0;
> +
> +		else {
> +			r = sm_ll_lookup(old_ll, *b, &count);
> +			if (r)
> +				break;
> +
> +			if (count)
> +				begin = *b + 1;
> +		}
> +	} while (count);
> +
> +	return r;
> +}
> +
>  static int sm_ll_mutate(struct ll_disk *ll, dm_block_t b,
>  			int (*mutator)(void *context, uint32_t old, uint32_t *new),
>  			void *context, enum allocation_event *ev)
> diff --git a/drivers/md/persistent-data/dm-space-map-common.h b/drivers/md/persistent-data/dm-space-map-common.h
> index b3078d5eda0c..8de63ce39bdd 100644
> --- a/drivers/md/persistent-data/dm-space-map-common.h
> +++ b/drivers/md/persistent-data/dm-space-map-common.h
> @@ -109,6 +109,8 @@ int sm_ll_lookup_bitmap(struct ll_disk *ll, dm_block_t b, uint32_t *result);
>  int sm_ll_lookup(struct ll_disk *ll, dm_block_t b, uint32_t *result);
>  int sm_ll_find_free_block(struct ll_disk *ll, dm_block_t begin,
>  			  dm_block_t end, dm_block_t *result);
> +int sm_ll_find_common_free_block(struct ll_disk *old_ll, struct ll_disk *new_ll,
> +	                         dm_block_t begin, dm_block_t end, dm_block_t *result);
>  int sm_ll_insert(struct ll_disk *ll, dm_block_t b, uint32_t ref_count, enum allocation_event *ev);
>  int sm_ll_inc(struct ll_disk *ll, dm_block_t b, enum allocation_event *ev);
>  int sm_ll_dec(struct ll_disk *ll, dm_block_t b, enum allocation_event *ev);
> diff --git a/drivers/md/persistent-data/dm-space-map-disk.c b/drivers/md/persistent-data/dm-space-map-disk.c
> index 32adf6b4a9c7..bf4c5e2ccb6f 100644
> --- a/drivers/md/persistent-data/dm-space-map-disk.c
> +++ b/drivers/md/persistent-data/dm-space-map-disk.c
> @@ -167,8 +167,10 @@ static int sm_disk_new_block(struct dm_space_map *sm, dm_block_t *b)
>  	enum allocation_event ev;
>  	struct sm_disk *smd = container_of(sm, struct sm_disk, sm);
>  
> -	/* FIXME: we should loop round a couple of times */
> -	r = sm_ll_find_free_block(&smd->old_ll, smd->begin, smd->old_ll.nr_blocks, b);
> +	/*
> +	 * Any block we allocate has to be free in both the old and current ll.
> +	 */
> +	r = sm_ll_find_common_free_block(&smd->old_ll, &smd->ll, smd->begin, smd->ll.nr_blocks, b);
>  	if (r)
>  		return r;
>  
> diff --git a/drivers/md/persistent-data/dm-space-map-metadata.c b/drivers/md/persistent-data/dm-space-map-metadata.c
> index 25328582cc48..9e3c64ec2026 100644
> --- a/drivers/md/persistent-data/dm-space-map-metadata.c
> +++ b/drivers/md/persistent-data/dm-space-map-metadata.c
> @@ -448,7 +448,10 @@ static int sm_metadata_new_block_(struct dm_space_map *sm, dm_block_t *b)
>  	enum allocation_event ev;
>  	struct sm_metadata *smm = container_of(sm, struct sm_metadata, sm);
>  
> -	r = sm_ll_find_free_block(&smm->old_ll, smm->begin, smm->old_ll.nr_blocks, b);
> +	/*
> +	 * Any block we allocate has to be free in both the old and current ll.
> +	 */
> +	r = sm_ll_find_common_free_block(&smm->old_ll, &smm->ll, smm->begin, smm->ll.nr_blocks, b);
>  	if (r)
>  		return r;
>  
> 
> --
> dm-devel mailing list
> dm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/dm-devel
> 
> 



