From: Marian Csontos <mcsontos@redhat.com>
Date: Thu, 19 Nov 2009 15:19:29 +0100
Subject: LVM2 tools/lvmcmdlib.c lib/mm/memlock.h lib/mm ...
In-Reply-To: <4B054205.5030901@redhat.com>
References: <20091119011158.31472.qmail@sourceware.org>	<4B051CEB.1030204@redhat.com>	<87pr7ewwrs.fsf@twilight.int.mornfall.net.>
	<4B054205.5030901@redhat.com>
Message-ID: <4B0553F1.3080600@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 11/19/2009 02:03 PM, Marian Csontos wrote:
> On 11/19/2009 12:59 PM, Petr Rockai wrote:
>> Marian Csontos<mcsontos@redhat.com>  writes:
>>> Why not to zero _memlock_count here (and _memlock_count_daemon below)?
>>> IMO, simple log_error is not enough. Though I understand this should 
>>> not happen
>>> under any conditions, the Murphy's Law says it will happen. And when it
>>> happens...
>>>
>>> ...dropping below zero, will result in subsequent 
>>> memlock_inc/memloc_inc_daemon
>>> having no effect. (Q: How serious is this condition? Could it result 
>>> in data
>>> corruption?)
>> When the value is out of sync once, there's no really good way to
>> recover. Too high will prevent scans, too low will cause deadlocks, the
>> result always being non-functional code.
> If it is non functional scans and not data corruption as I had 
> thought, then it is safer to leave as is.
However, after better looking at the code, I am prone to think the 
current solution might lead to deadlock and not to non-functional scans 
(and that's what you have said too):

When one of _memlock_count* variables is 0 and the other one -1, the 
subsequent memlock_inc* will have no effect and thus would not prevent 
pages from being swapped out. Is not it this what is causing the 
deadlocks we are talking about?

If it is two bad solutions to choose from, which one is worse, deadlock 
or broken scan?

Could broken scan lead to data corruption, or would this affect VG 
administration tools only?

What are the consequences of deadlock we are talking about? Is it frozen 
system, or just frozen LVM user-space? I reckon it is system wide death, 
and thus much worse solution than not-working userspace tools, but still 
better than data corruption.

I see the tests are now fixed, so this is now, hopefully, hypothetical 
problem...

>>> On the other hand, if it were zeroed, the possible deadlock could be
>>> the only result.  However, this could happen only when memory is
>>> unlocked before it is locked.
>> See above.
>>
>>>> +/*
>>>> + * The memlock_*_daemon functions will force the mlockall() call 
>>>> that we need
>>>> + * to stay in memory, but they will have no effect on device scans 
>>>> (unlike
>>>> + * normal memlock_inc and memlock_dec). Memory is kept locked as 
>>>> long as either
>>>> + * of memlock or memlock_daemon is in effect.
>>>> + */
>>>>
>>> Q: It does not work as proposed now. Does the "will" mean it will once
>>> implemented?
>> Why not? As far as I can tell, this works as advertised, and testing
>> confirms that.
> Oh, I see. It must be the memlock function, what affects device scans.
> I apologize.
>
> I noticed some failures while looking at nevrast/waterfall, and in my 
> zeal reviewed changes what might be causing troubles. Of course the 
> changes were reviewed and tested carefully before, thus it is just my 
> reasoning what's wrong here and the mistake is elsewhere.
>
> Cheers,
>
> -- Marian
>
>> Yours,
>>     Petr.
>>
>> -- 
>> lvm-devel mailing list
>> lvm-devel at redhat.com
>> https://www.redhat.com/mailman/listinfo/lvm-devel
>
> -- 
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel


