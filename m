From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 5 Apr 2017 10:05:19 +0200
Subject: [BISECT] Regression: SEGV: 9156c5d dmeventd rework locking code
In-Reply-To: <alpine.LRH.2.11.1704041618560.4709@mail.ewheeler.net>
References: <alpine.LRH.2.11.1703311519160.19447@mail.ewheeler.net>
	<916b3fa0-e99f-a5de-2d86-f7539c7f2ca7@redhat.com>
	<alpine.LRH.2.11.1704041618560.4709@mail.ewheeler.net>
Message-ID: <2c30ac68-b531-9fd2-985e-05cf31f7beb0@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 5.4.2017 v 01:22 Eric Wheeler napsal(a):
> On Sat, 1 Apr 2017, Zdenek Kabelac wrote:
>
>> Dne 1.4.2017 v 00:19 Eric Wheeler napsal(a):

>>> (gdb) bt
>>> #0  _touch_memory (size=<optimized out>, mem=<optimized out>) at
>>> mm/memlock.c:141
>>> #1  _allocate_memory () at mm/memlock.c:163
>>
>>
>> Hi
>>
>> Hmm few theories -  from your gdb backtrace it suggests it has failed on libc
>> syscall  (getpagesize()) ??
>> So have you upgraded all related packages ?  (device-mapper*,  kernel*)
>> or it's some 'mixture' in use ?
>>
>> Also don't you have some large/changed values of 'reserved_stack'   or
>> 'reserved_memory' in your lvm.conf ?
>
> Yes! Actually, reserved_stack was the problem. By trial and error we found
> that when reserved_stack is 290 or more, dmeventd will segfault. We tried
> on servers with far fewer logical volumes and did not have a problem, so
> while I am not going to try and figure out how many logical volumes hit
> this stack limit, this is the problem!
>
> Is there some kind of hard limit to reserved_stack that should be
> enforced?
>
> I seem to recall increasing these values because lvcreate (or lvchange or
> something) suggested that the values were too small.
>
> Do you still want a bugzilla report?


Hi

Yep - so this explains it. Not clear we need BZ yet.
I'll explain the reason of limitation.

Dmeventd is using threads - and to minimize the RAM usage by memlocked process 
with number of threads - we picked 'relatively' low value for pthread_stack 
with assumption noone will ever need bigger value than this :)

Now lvm.conf does defined 'reserved_stack' amount - and this stack is then 
'mapped' in dmeventd lvm plugin thread.  However this is after 'dmeventd' has 
created thread with 128K stack limit (dmeventd itself doesn't 'see/use' 
lvm.conf so can't create threads with different settings)

So clearly a logical problem we can't really solve in any easy way.
We limited amount of stack used by lvm2 code - so current defaults should be 
rather good enough for almost every possible use-case.

So before we start to fix this  'catch 42' case - could you check and 
eventually describe which use-case was not working well we 'default' 
reserved_stack  so you had to raise the value to 290 to make it work ?

Otherwise I think the best solution would be to simply internally limit
the 'accepted' value and ignore any higher setting and just document it.


Regards

Zdenek


