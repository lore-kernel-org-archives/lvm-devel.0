From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 14 Aug 2017 14:29:43 +0200
Subject: Batch/queue LVM operations
In-Reply-To: <alpine.LRH.2.11.1708040036410.9683@mail.ewheeler.net>
References: <alpine.LRH.2.11.1707281919050.9683@mail.ewheeler.net>
	<32ff399c-7a79-5beb-abd5-d5dbad1486db@redhat.com>
	<alpine.LRH.2.11.1708011720490.9683@mail.ewheeler.net>
	<4c0a5ae7-2da4-7610-5d06-90d990bd41de@redhat.com>
	<alpine.LRH.2.11.1708040036410.9683@mail.ewheeler.net>
Message-ID: <1df2fbda-640a-e87b-49f1-f9b1ff8a0fae@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 4.8.2017 v 02:38 Eric Wheeler napsal(a):
> On Tue, 1 Aug 2017, Zdenek Kabelac wrote:
> 
>> Dne 1.8.2017 v 19:24 Eric Wheeler napsal(a):
>>> On Fri, 28 Jul 2017, Zdenek Kabelac wrote:
>>>
>>>> Dne 28.7.2017 v 21:22 Eric Wheeler napsal(a):
>>>>> Hello,
>>>>>
>>>>> Is there an option to batch LVM operations?
>>>>>
>>>>> For example, I would like to delete 100 thin snapshots without updating
>>>>> the vgmeta 100 times.
>>>>
>>>> You could possibly use --select feature to handle all removals with
>>>> just one lvremove command.
>>>
>>> I tried --select, but there is a long pause between removals so it is
>>> clearly doing a metadata operation for each removal.
>>>
>>> Is it possible to do something like this:
>>>
>>> 1. Hold a lock (how?)
>>> 2. vgcfgbackup -f /my-backup/file --ignorelocking-failure
>>> 3. Modify /my-backup/file (remove LVs)
>>> 4. dmsetup message pool 0 delete ID (each ID)
>>> 5. vgcfgrestore --ignorelocking-failure
>>> 6. Release lock
>>>
>>> --
>>> Eric Wheeler
>>>
>>
>> Hi
>>
>> Unfortunately this optimization is currently not possible.
> 
> Well, perhaps not by LVM at the moment, but is the procedure sound if I
> were to do this myself and accept any errors while deleting thin volumes?

Hi

Yes - surely you can write direct sequence of command to update lvm2 metadata
in different way -   lvm2 does nothing else then 'read-lvm2-metadata'
'do-some-work'  and 'write-updated-lvm2-metadata' - clearly between does steps
there is a lot of validation checking which operation are allowed at each
individual steps to minimize risk of any data-lose.
lvm2 however targets 'universal' sequences - so it's getting sub-optimal for 
certain workloads.
If you can ensure like 'no LVs' gets activated between you  'hacked' tooling 
work then you can surely  write a replacement of 'lvm2' work  via usage
of some 'dmsetup' & 'awk/sed'  work with using of vgcfgbackup/restore.
But as said - you will lose large chunk of extra protection - but you know 
what price you pay here...

> Can vgcfgrestore be done hot with existing active volumes?
> 
> Similarly, could I do this for mass renames with the backup/restore?

Yep - rename is typically easier to do - here lvm2 is able to protect you on 
'vgcfgrestore' at least against bad names..
Just be aware if you rename LVs to some 'existing' live/running names you can 
make such LVs inaccessible/unsable for lvm2.

Regards

Zdenek


