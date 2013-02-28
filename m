From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 28 Feb 2013 16:35:04 +0100
Subject: [PATCH 1/2] lvm2app: Add thin and thin pool lv creation
In-Reply-To: <87wqtsznrx.fsf@in.ibm.com>
References: <1360689876-13552-1-git-send-email-mohan@in.ibm.com>
	<1360689876-13552-2-git-send-email-mohan@in.ibm.com>
	<512BBF6B.3060004@redhat.com> <87wqtsznrx.fsf@in.ibm.com>
Message-ID: <512F7928.80209@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 28.2.2013 12:22, M. Mohan Kumar napsal(a):
> Zdenek Kabelac <zkabelac@redhat.com> writes:
>
>> Dne 12.2.2013 18:24, M. Mohan Kumar napsal(a):
>>>    		first_seg(lv)->chunk_size = lp->chunk_size;
>>>    		first_seg(lv)->discards = lp->discards;
>>>    		/* FIXME: use lowwatermark  via lvm.conf global for all thinpools ? */
>>> -		first_seg(lv)->low_water_mark = 0;
>>> +		first_seg(lv)->low_water_mark = lp->low_water_mark;
>>
>> low_water_mark is not supported yet in the lvm2 stack,
>> and there is not yet clear definition how is it going to be used.
>>
>
> IMHO there is no harm in adding support to specify low water mark during
> thin pool creation.

It's not yet even decided what would be the unit on lvm side. It could be 
percentage either as int - or  percent_t, or the size in blocks or something 
like that.

>
>> For now dmeventd is based on 10sec polling interval.
>>
>
> Is it not possible to use the 'thin-pool' threshold dm-event instead of
> 10-sec polling in dmeventd?

That's the key problem here. We need to have policy defined - since i.e.
if you set watermark on 75% and you start the pool already 80% full
(and you don't know the fullness until pool is started) there would be no 
message -> no trial to expand the pool. On the other hand it's valid request 
to start thinpool which is above the threshold - but how it should behave in 
this case must be driven by some rules. There could be 'soft' watermark - to 
run even tools like 'fstrim' and then there could be 'hard' watermark to 
support activation only in 'read-only' mode or even avoid activation 
completely. As you can see there could be tons of options but on the other 
hand we should avoid creating some hardly configurable policies here where 
user would need to spend week to even understand them.


>> However there needs to be made clean definition for various error path,
>> and we have to also support 'clean' shutdown for those paths according
>> to defined policy.
>>
>
> Could you please explain it further?

One of current problems in lvm2 is if you have overfilled pool - it stays
stuck awaiting on pool extension - and there is no way to shutdown
machine 'cleanly' in this state (i.e. user has no drive to attach, or simply 
needs to reboot)


> I agree for a need of a single lv create function capable of creating
> any LV type and I already posted a RFC version of that patch a month
> ago.
>
> But providing a simpler interface to create a specific type of LV may
> also be a valid usecase, where an user does not want to
> customize/specify each parameters in LV creation.

Simplier interfaces have the problem - it could make the future extension of 
interface much harder if you want to keep them supported.

i.e. lot's of decision in lvm2 is currently based on lvm.conf.
But lvm2api is currently missing these - so this needs to be addressed as well.


>
> IIUC by 'support for creation of thin lvs with external origins' you
> mean creating a thin snapshot LV from a linear LV. In this case
> lvm_lv_snapshot function needs to be changed, while this function
> lvm_lv_thin creates only thin Lvs (not thin snapshots)

As you could see yourself - it's getting to be a lvm2api user's problem to 
figure out, how to actually create a specific LV - API user would need to scan 
number of 'lvcreate' function and try to figure out which function to call, 
instead of having single call with  'lvcreate_params' - so IMHO I'd prefer to 
avoid creating this 'array' of 'simple' interfaces even though all those 
functions could be possible later turned into wrappers calling one universal 
function - but why not start directly with the proper way.

Zdenek


