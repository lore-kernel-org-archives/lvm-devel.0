From: M. Mohan Kumar <mohan@in.ibm.com>
Date: Thu, 28 Feb 2013 16:52:10 +0530
Subject: [PATCH 1/2] lvm2app: Add thin and thin pool lv creation
In-Reply-To: <512BBF6B.3060004@redhat.com>
References: <1360689876-13552-1-git-send-email-mohan@in.ibm.com>
	<1360689876-13552-2-git-send-email-mohan@in.ibm.com>
	<512BBF6B.3060004@redhat.com>
Message-ID: <87wqtsznrx.fsf@in.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Zdenek Kabelac <zkabelac@redhat.com> writes:

> Dne 12.2.2013 18:24, M. Mohan Kumar napsal(a):
>>   		first_seg(lv)->chunk_size = lp->chunk_size;
>>   		first_seg(lv)->discards = lp->discards;
>>   		/* FIXME: use lowwatermark  via lvm.conf global for all thinpools ? */
>> -		first_seg(lv)->low_water_mark = 0;
>> +		first_seg(lv)->low_water_mark = lp->low_water_mark;
>
> low_water_mark is not supported yet in the lvm2 stack,
> and there is not yet clear definition how is it going to be used.
>

IMHO there is no harm in adding support to specify low water mark during
thin pool creation. 

> For now dmeventd is based on 10sec polling interval.
>

Is it not possible to use the 'thin-pool' threshold dm-event instead of
10-sec polling in dmeventd? 

> However there needs to be made clean definition for various error path,
> and we have to also support 'clean' shutdown for those paths according
> to defined policy.
>

Could you please explain it further?

>> +lv_t lvm_lv_thin(const vg_t vg, const char *pool,
>> +		 const char *lvname, uint64_t size)
>> +{
>> +	struct lvcreate_params lp = { 0 };
>
> I think the lvm2app needs some extension here and rather
> make the 'lvcreate_params' structure a visible object with some methods,
> and use just one universal function call to create all types
> of LVs - so we can better match the internal lvm2 processing.
> i.e. there is going to be support for creation of thin
> lvs with external origins - so adding  lvm API call for every
> possible use case of thin pool is IMHO less clean then maintenance
> of 'lvcreate_params' object separately from lvm_lv_create() call.
>

I agree for a need of a single lv create function capable of creating
any LV type and I already posted a RFC version of that patch a month
ago.

But providing a simpler interface to create a specific type of LV may
also be a valid usecase, where an user does not want to
customize/specify each parameters in LV creation.

IIUC by 'support for creation of thin lvs with external origins' you
mean creating a thin snapshot LV from a linear LV. In this case
lvm_lv_snapshot function needs to be changed, while this function
lvm_lv_thin creates only thin Lvs (not thin snapshots) 



