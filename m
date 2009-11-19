From: Petr Rockai <prockai@redhat.com>
Date: Thu, 19 Nov 2009 12:59:19 +0100
Subject: LVM2 tools/lvmcmdlib.c lib/mm/memlock.h lib/mm ...
In-Reply-To: <4B051CEB.1030204@redhat.com> (Marian Csontos's message of "Thu, 
	19 Nov 2009 11:24:43 +0100")
References: <20091119011158.31472.qmail@sourceware.org>
	<4B051CEB.1030204@redhat.com>
Message-ID: <87pr7ewwrs.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Marian Csontos <mcsontos@redhat.com> writes:
> Why not to zero _memlock_count here (and _memlock_count_daemon below)?
> IMO, simple log_error is not enough. Though I understand this should not happen
> under any conditions, the Murphy's Law says it will happen. And when it
> happens...
>
> ...dropping below zero, will result in subsequent memlock_inc/memloc_inc_daemon
> having no effect. (Q: How serious is this condition? Could it result in data
> corruption?)
When the value is out of sync once, there's no really good way to
recover. Too high will prevent scans, too low will cause deadlocks, the
result always being non-functional code.

> On the other hand, if it were zeroed, the possible deadlock could be
> the only result.  However, this could happen only when memory is
> unlocked before it is locked.
See above.

>> +/*
>> + * The memlock_*_daemon functions will force the mlockall() call that we need
>> + * to stay in memory, but they will have no effect on device scans (unlike
>> + * normal memlock_inc and memlock_dec). Memory is kept locked as long as either
>> + * of memlock or memlock_daemon is in effect.
>> + */
>>    
> Q: It does not work as proposed now. Does the "will" mean it will once
> implemented?
Why not? As far as I can tell, this works as advertised, and testing
confirms that.

Yours,
   Petr.


