From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 12 Apr 2013 14:40:41 +0200
Subject: [PATCH V4] lvm2app: Add thin and thin pool lv creation
In-Reply-To: <87zjx47x7a.fsf@in.ibm.com>
References: <1363713892-14704-1-git-send-email-mohan@in.ibm.com>
	<515DF3F3.70004@redhat.com> <87zjx47x7a.fsf@in.ibm.com>
Message-ID: <516800C9.8000505@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 12.4.2013 14:25, M. Mohan Kumar napsal(a):
> Tony Asleson <tasleson@redhat.com> writes:
>
>> Looked over the patch and have the following comments:
>>
>> The patch has a warning when building.  In the function lvm_lv_thinpool,
>> the variable lwmb is unused and can be removed.  The added functions
>> don't verify all the parameters.  We can't protect against everything,
>> but I still think it would be good to check for NULL on the pointer
>> arguments and non-zero length on strings?
>>
> Thanks Tony for the review. If the lvname parameter is NULL, lvm-library
> chooses a unique for the new LV. IMHO pool name and vg needs to be
> checked against NULL.
>
> If Zdenek is ok with this approach, I can send a V5 with this parameter
> checking and removing unused variable. Zdenek?

I'll not agree with anything exposing low_water_mark.

This is currently 'private' code for liblvm with not yet properly defined
usage - thus there is no point in exposing this value to lvm2api.
>>>   		/* FIXME: use lowwatermark  via lvm.conf global for all thinpools ? */
>>> -		first_seg(lv)->low_water_mark = 0;
>>> +		first_seg(lv)->low_water_mark = lp->low_water_mark;
>>>   	} else if (seg_is_thin_volume(lp)) {
>>>   		pool_lv = first_seg(lv)->pool_lv;


>>>   	uint32_t permission; /* all */
>>> diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
>>> index 93a78c3..0f8e39c 100644
>>> --- a/liblvm/lvm2app.h
>>> +++ b/liblvm/lvm2app.h
>>> @@ -1400,6 +1400,79 @@ int lvm_lv_resize(const lv_t lv, uint64_t new_size);
>>>    */
>>>   lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name, uint64_t max_snap_size);
>>>
>>> +
>>> +#define THIN_FL_DISCARDS_IGNORE          0x0001
>>> +#define THIN_FL_DISCARDS_NO_PASSDOWN     0x0010
>>> +#define THIN_FL_SKIP_ZERO                0x0100


>>> +
>>> +/**
>>> + * Create a thinpool in a given VG
>>> + *
>>> + * \param   vg
>>> + * Volume Group handle.
>>> + *
>>> + * \param   pool_name
>>> + * Name of the pool.
>>> + *
>>> + * \param   size
>>> + * size of the pool
>>> + *
>>> + * \param   chunk_size
>>> + * data block size of the pool
>>> + * Default value is DEFAULT_THIN_POOL_CHUNK_SIZE * 2 when 0 passed as chunk_size
>>> + * DM_THIN_MIN_DATA_BLOCK_SIZE < chunk_size < DM_THIN_MAX_DATA_BLOCK_SIZE
>>> + *
>>> + * \param  threshold in percentage
>>> + * When percentage of free blocks in the pool reaches <= this thresold a dm
>>> + * event is sent. For example if threshold is specified 25, an dm event will be
>>> + * generated when the percentage of free blocks goes <= 25%.
>>> + *
>>> + * Note: when 0 is passed as threshold, an event will be generated only when all
>>> + * blocks are consumed in the pool.
>>> + *
>>> + * \param meta_size
>>> + * Size of thin pool's metadata logical volume. Allowed range is 2MB-16GB.
>>> + * Default value (ie if 0) pool size / pool chunk size * 64
>>> + *
>>> + * \param flags
>>> + * As of now supported flags are
>>> + * THIN_FL_DISCARDS_IGNORE,
>>> + * THIN_FL_DISCARDS_NO_PASSDOWN,
>>> + * THIN_FL_SKIP_ZERO

These are unrelated - they should not be passed in as bit flag,

We really need here separate type of object to set all properties for thin.
(Since their amount will grow over the time) so you can't solve with any bit 
field - this is not extensible.

We need to create 'object' with properties, that can be controled in C++ like 
way - so we may extend it in future easily, without breaking API, and leaving
'old' unusable calls in the library.

Zdenek


