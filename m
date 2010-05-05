From: Takahiro Yasui <tyasui@redhat.com>
Date: Wed, 05 May 2010 11:26:14 -0400
Subject: dmeventd doesn't handle failures during mirror resync.
In-Reply-To: <18865F70-312F-4B17-844C-24BEA6B3A7E7@redhat.com>
References: <20100429170140.777db964@notabene.brown>	<874oim3h5i.fsf@twilight.int.mornfall.net.>
	<18865F70-312F-4B17-844C-24BEA6B3A7E7@redhat.com>
Message-ID: <4BE18E16.3060007@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 05/05/10 09:22, Jonathan Brassow wrote:
> On May 5, 2010, at 3:08 AM, Petr Rockai wrote:
>> Neil Brown <neilb@suse.de> writes:
>>
>>> I was surprised to discover that while a normal write error is
>>> handled properly - dmeventd runs 'lvconvert' to fix the array up,
>>> this does not happen in response to a write error while syncing
>>> the array.
>>>
>>> If I arrange for the new device to die, then
>>>          lvconvert --repair --use-policies
>>>
>>> will fix it up as I would expect, but dmeventd never asks it to do
>>> this.
>>>
>>> This seems to be a deliberate decision:  in _process_status_code
>>> in dmeventd_mirror.c, a status of 'F' will cause lvconvert to be
>>> run while 'S' and 'R' (sync and read errors) will not.
>>>
>>> Is there a reason for this?
>> I think the rationale is that:
>>
>> For read errors, we should *not* strip the mirror leg, since we want  
>> to
>> keep as much redundancy as possible in this scenario. The failure  
>> should
>> be logged, but I think that's it.
>>
>> For sync, I am not sure. It may be that the reason for this is that  
>> sync
>> is usually related to manual action and dmeventd intervention may be
>> unexpected and unwanted in this case. But that case could be argued.
>>
>>> Can we change dmeventd to response to sync (and read) errors in the  
>>> same
>>> way that it responds to write errors?
>> I think it's a bad idea for read errors, unless maybe we could have a
>> new feature for that -- one that'd upconvert the mirror first (if
>> there's a hotspare) and only if that finishes OK, kill the bad leg.  
>> Just
>> log the error if there are no hotspares.
>>
>> For sync errors, I am ambivalent. Any further opinions?
> 
> I think for sync errors, we should restart the sync.  This can be done  
> by a suspend/resume of the mirror device.  Effectively, we are  
> assuming a transient failure.  Perhaps if we have tried to clear the  
> fault a couple times, then we could remove the failed device.
> 
> Read errors I would definitely leave alone.  Drives can often relocate  
> bad sectors, but that is done on writes.  If the relocation fails, we  
> will know about it when the write fails.

Read errors can't be handled with the current device-mapper in kernel.
Sync error is reported by both read and write errors. Read error
occurs by reading a default mirror device and write error occurs
by writing data in non-default mirror devices. If sync error was
the one reported by read error, we will lose a default mirror, which
contains a valid data. Think a sync error when new disk is added.
If it is a transient error, we could save data by retrying sync,
for example as Jon suggested.

Also, I proposed the following patch a half year ago. The patch
handles only "write sync error." This approach could improve
an error handling, although this patch should be improved to
consider the case that a default mirror changed.

lvm2: sync error handling on secondary mirror in dmeventd
https://www.redhat.com/archives/lvm-devel/2009-November/msg00179.html

Thanks,
Taka


