From: M. Mohan Kumar <mohan@in.ibm.com>
Date: Fri, 12 Apr 2013 17:55:13 +0530
Subject: [PATCH V4] lvm2app: Add thin and thin pool lv creation
In-Reply-To: <515DF3F3.70004@redhat.com>
References: <1363713892-14704-1-git-send-email-mohan@in.ibm.com>
	<515DF3F3.70004@redhat.com>
Message-ID: <87zjx47x7a.fsf@in.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Tony Asleson <tasleson@redhat.com> writes:

> Looked over the patch and have the following comments:
>
> The patch has a warning when building.  In the function lvm_lv_thinpool,
> the variable lwmb is unused and can be removed.  The added functions
> don't verify all the parameters.  We can't protect against everything,
> but I still think it would be good to check for NULL on the pointer
> arguments and non-zero length on strings?
>
Thanks Tony for the review. If the lvname parameter is NULL, lvm-library
chooses a unique for the new LV. IMHO pool name and vg needs to be
checked against NULL.

If Zdenek is ok with this approach, I can send a V5 with this parameter
checking and removing unused variable. Zdenek?

>
>
> On 03/19/2013 12:24 PM, M. Mohan Kumar wrote:
>> From: "M. Mohan Kumar" <mohan@in.ibm.com>
>> 
>> Add thin and thin pool lv creation support to lvm library
>> 
>> Signed-off-by: M. Mohan Kumar <mohan@in.ibm.com>
>> ---
>> Changes from V3:
>> * Added paramater to specify metadata size, flags
>> 
>> Changes from V2:
>> * Specify percentage for low water mark threshold instead of number of
>>   blocks
>> 
>> Changes from previous version:
>> * Add support to specify data block size and low water mark thresold for
>> newly created thin pool.
>> 
>>  lib/metadata/lv_manip.c          |   2 +-
>>  lib/metadata/metadata-exported.h |   1 +
>>  liblvm/lvm2app.h                 |  73 +++++++++++++++++++
>>  liblvm/lvm_lv.c                  | 154 +++++++++++++++++++++++++++++++++++++++
>>  4 files changed, 229 insertions(+), 1 deletion(-)
>> 
>> diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
>> index c1437eb..4dd5ebf 100644
>> --- a/lib/metadata/lv_manip.c
>> +++ b/lib/metadata/lv_manip.c
>> @@ -4518,7 +4518,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
>>  		first_seg(lv)->chunk_size = lp->chunk_size;
>>  		first_seg(lv)->discards = lp->discards;
>>  		/* FIXME: use lowwatermark  via lvm.conf global for all thinpools ? */
>> -		first_seg(lv)->low_water_mark = 0;
>> +		first_seg(lv)->low_water_mark = lp->low_water_mark;
>>  	} else if (seg_is_thin_volume(lp)) {
>>  		pool_lv = first_seg(lv)->pool_lv;
>>  
>> diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
>> index ffec129..40519f5 100644
>> --- a/lib/metadata/metadata-exported.h
>> +++ b/lib/metadata/metadata-exported.h
>> @@ -617,6 +617,7 @@ struct lvcreate_params {
>>  	uint64_t voriginsize; /* snapshot */
>>  	uint32_t poolmetadataextents; /* thin pool */
>>  	uint64_t poolmetadatasize; /* thin pool */
>> +	uint64_t low_water_mark;  /* thin_pool */
>>  	struct dm_list *pvh; /* all */
>>  
>>  	uint32_t permission; /* all */
>> diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
>> index 93a78c3..0f8e39c 100644
>> --- a/liblvm/lvm2app.h
>> +++ b/liblvm/lvm2app.h
>> @@ -1400,6 +1400,79 @@ int lvm_lv_resize(const lv_t lv, uint64_t new_size);
>>   */
>>  lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name, uint64_t max_snap_size);
>>  
>> +
>> +#define THIN_FL_DISCARDS_IGNORE          0x0001
>> +#define THIN_FL_DISCARDS_NO_PASSDOWN     0x0010
>> +#define THIN_FL_SKIP_ZERO                0x0100
>> +
>> +/**
>> + * Create a thinpool in a given VG
>> + *
>> + * \param   vg
>> + * Volume Group handle.
>> + *
>> + * \param   pool_name
>> + * Name of the pool.
>> + *
>> + * \param   size
>> + * size of the pool
>> + *
>> + * \param   chunk_size
>> + * data block size of the pool
>> + * Default value is DEFAULT_THIN_POOL_CHUNK_SIZE * 2 when 0 passed as chunk_size
>> + * DM_THIN_MIN_DATA_BLOCK_SIZE < chunk_size < DM_THIN_MAX_DATA_BLOCK_SIZE
>> + *
>> + * \param  threshold in percentage
>> + * When percentage of free blocks in the pool reaches <= this thresold a dm
>> + * event is sent. For example if threshold is specified 25, an dm event will be
>> + * generated when the percentage of free blocks goes <= 25%.
>> + *
>> + * Note: when 0 is passed as threshold, an event will be generated only when all
>> + * blocks are consumed in the pool.
>> + *
>> + * \param meta_size
>> + * Size of thin pool's metadata logical volume. Allowed range is 2MB-16GB.
>> + * Default value (ie if 0) pool size / pool chunk size * 64
>> + *
>> + * \param flags
>> + * As of now supported flags are
>> + * THIN_FL_DISCARDS_IGNORE,
>> + * THIN_FL_DISCARDS_NO_PASSDOWN,
>> + * THIN_FL_SKIP_ZERO
>> + *
>> + * If none of Discard related flag passed THIN_DISCARDS_PASSDOWN is enabled.
>> + *
>> + * \return
>> + * Valid lv pointer on success, else NULL on error.
>> + *
>> + */
>> +lv_t lvm_lv_thinpool(const vg_t vg, const char *pool_name, uint64_t size,
>> +		     uint32_t chunk_size, uint64_t meta_size, int threshold,
>> +		     int flags);
>> +
>> +/**
>> + * Create a thin LV in a given VG & thin pool
>> + *
>> + * \param   vg
>> + * Volume Group handle.
>> + *
>> + * \param   pool_name
>> + * Name of the pool.
>> + *
>> + * \param lvname
>> + * Name of the LV to create
>> + *
>> + * \param   size
>> + * Size of logical volume
>> + *
>> + * \return
>> + * Valid lv pointer on success, else NULL on error.
>> + *
>> + */
>> +
>> +lv_t lvm_lv_thin(const vg_t vg, const char *pool_name, const char *lvname,
>> +		uint64_t size);
>> +
>>  /************************** physical volume handling ************************/
>>  
>>  /**
>> diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
>> index 91948a6..d4645f4 100644
>> --- a/liblvm/lvm_lv.c
>> +++ b/liblvm/lvm_lv.c
>> @@ -350,3 +350,157 @@ lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name, uint64_t max_snap_siz
>>  		return NULL;
>>  	return (lv_t) lvl->lv;
>>  }
>> +
>> +/* Set defaults for thin pool specific LV parameters */
>> +static void _lv_set_pool_params(struct lvcreate_params *lp,
>> +				vg_t vg, const char *pool,
>> +				uint64_t extents, uint64_t meta_size)
>> +{
>> +	_lv_set_default_params(lp, vg, NULL, extents);
>> +
>> +	lp->pool = pool;
>> +
>> +	lp->create_thin_pool = 1;
>> +	lp->segtype = get_segtype_from_string(vg->cmd, "thin-pool");
>> +	lp->stripes = 1;
>> +
>> +	if (!meta_size) {
>> +		lp->poolmetadatasize = extents * vg->extent_size /
>> +			(lp->chunk_size * (SECTOR_SIZE / 64));
>> +		while ((lp->poolmetadatasize >
>> +			(2 * DEFAULT_THIN_POOL_OPTIMAL_SIZE / SECTOR_SIZE)) &&
>> +		       lp->chunk_size < DM_THIN_MAX_DATA_BLOCK_SIZE) {
>> +			lp->chunk_size <<= 1;
>> +			lp->poolmetadatasize >>= 1;
>> +	         }
>> +	} else
>> +		lp->poolmetadatasize = meta_size;
>> +
>> +	if (lp->poolmetadatasize % vg->extent_size)
>> +		lp->poolmetadatasize +=
>> +			vg->extent_size - lp->poolmetadatasize % vg->extent_size;
>> +
>> +	lp->poolmetadataextents =
>> +		extents_from_size(vg->cmd, lp->poolmetadatasize / SECTOR_SIZE,
>> +						   vg->extent_size);
>> +}
>> +
>> +lv_t lvm_lv_thinpool(const vg_t vg, const char *pool, uint64_t size,
>> +		     uint32_t chunk_size, uint64_t meta_size, int threshold,
>> +		     int flags)
>> +{
>> +	struct lvcreate_params lp = { 0 };
>> +	uint64_t extents = 0;
>> +	struct lv_list *lvl = NULL;
>> +	uint64_t lwmb = 0;
>> +
>> +	if (meta_size > (2 * DEFAULT_THIN_POOL_MAX_METADATA_SIZE)) {
>> +		log_error("Invalid metadata size");
>> +		return NULL;
>> +	}
>> +
>> +	if (meta_size &&
>> +	    meta_size < (2 * DEFAULT_THIN_POOL_MIN_METADATA_SIZE)) {
>> +		log_error("Invalid metadata size");
>> +		return NULL;
>> +	}
>> +
>> +	if (vg_read_error(vg))
>> +		return NULL;
>> +
>> +	if (!vg_check_write_mode(vg))
>> +		return NULL;
>> +
>> +	if (threshold < 0 || threshold > 100) {
>> +		log_error("Invalid threshold, should be between 0-100");
>> +		return NULL;
>> +	}
>> +	if (!(extents = extents_from_size(vg->cmd, size / SECTOR_SIZE,
>> +					  vg->extent_size))) {
>> +		log_error("Unable to create LV thin pool without size.");
>> +		return NULL;
>> +	}
>> +
>> +	if (flags & THIN_FL_DISCARDS_NO_PASSDOWN)
>> +		lp.discards = THIN_DISCARDS_NO_PASSDOWN;
>> +	else if (flags & THIN_FL_DISCARDS_IGNORE)
>> +		lp.discards = THIN_DISCARDS_IGNORE;
>> +	else
>> +		lp.discards = THIN_DISCARDS_PASSDOWN;
>> +
>> +	if (chunk_size)
>> +		lp.chunk_size = chunk_size;
>> +	else
>> +		lp.chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE * 2;
>> +
>> +	if (lp.chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE ||
>> +	    lp.chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE) {
>> +		log_error("Invalid chunk_size");
>> +		return NULL;
>> +	}
>> +
>> +	_lv_set_pool_params(&lp, vg, pool, extents, meta_size);
>> +
>> +	if (flags & THIN_FL_SKIP_ZERO)
>> +		lp.zero = 0;
>> +	/*
>> +	  threshold specified in percentage, convert that into
>> +	  number of blocks
>> +	*/
>> +	lp.low_water_mark = size / (chunk_size * SECTOR_SIZE) * threshold / 100;
>> +	if (!lp.segtype)
>> +		return_NULL;
>> +	if (!lv_create_single(vg, &lp))
>> +		return_NULL;
>> +	if (!(lvl = find_lv_in_vg(vg, pool)))
>> +		return_NULL;
>> +	return (lv_t) lvl->lv;
>> +}
>> +
>> +/* Set defaults for thin LV specific parameters */
>> +static void _lv_set_thin_params(struct lvcreate_params *lp,
>> +				vg_t vg, const char *pool,
>> +				const char *lvname,
>> +				uint64_t extents)
>> +{
>> +	_lv_set_default_params(lp, vg, lvname, extents);
>> +
>> +	lp->thin = 1;
>> +	lp->pool = pool;
>> +	lp->segtype = get_segtype_from_string(vg->cmd, "thin");
>> +
>> +	lp->voriginsize = extents * vg->extent_size;
>> +	lp->voriginextents = extents_from_size(vg->cmd, lp->voriginsize,
>> +						   vg->extent_size);
>> +
>> +	lp->stripes = 1;
>> +}
>> +
>> +lv_t lvm_lv_thin(const vg_t vg, const char *pool,
>> +		 const char *lvname, uint64_t size)
>> +{
>> +	struct lvcreate_params lp = { 0 };
>> +	uint64_t extents = 0;
>> +	struct lv_list *lvl = NULL;
>> +
>> +	if (vg_read_error(vg))
>> +		return NULL;
>> +	if (!vg_check_write_mode(vg))
>> +		return NULL;
>> +
>> +	if (!(extents = extents_from_size(vg->cmd, size / SECTOR_SIZE,
>> +					  vg->extent_size))) {
>> +		log_error("Unable to create thin LV without size.");
>> +		return NULL;
>> +	}
>> +
>> +	_lv_set_thin_params(&lp, vg, pool, lvname, extents);
>> +
>> +	if (!lp.segtype)
>> +		return_NULL;
>> +	if (!lv_create_single(vg, &lp))
>> +		return_NULL;
>> +	if (!(lvl = find_lv_in_vg(vg, pool)))
>> +		return_NULL;
>> +	return (lv_t) lvl->lv;
>> +}


