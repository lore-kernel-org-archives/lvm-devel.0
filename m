From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 1 Aug 2017 20:39:20 +0200
Subject: Batch/queue LVM operations
In-Reply-To: <4c0a5ae7-2da4-7610-5d06-90d990bd41de@redhat.com>
References: <alpine.LRH.2.11.1707281919050.9683@mail.ewheeler.net>
	<32ff399c-7a79-5beb-abd5-d5dbad1486db@redhat.com>
	<alpine.LRH.2.11.1708011720490.9683@mail.ewheeler.net>
	<4c0a5ae7-2da4-7610-5d06-90d990bd41de@redhat.com>
Message-ID: <6aac428d-2c55-4d7f-4ad1-ebcd3b6f2ca6@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 1.8.2017 v 19:46 Zdenek Kabelac napsal(a):
> Dne 1.8.2017 v 19:24 Eric Wheeler napsal(a):
>> On Fri, 28 Jul 2017, Zdenek Kabelac wrote:
>>
>>> Dne 28.7.2017 v 21:22 Eric Wheeler napsal(a):
>>>> Hello,
>>>>
>>>> Is there an option to batch LVM operations?
>>>>
>>>> For example, I would like to delete 100 thin snapshots without updating
>>>> the vgmeta 100 times.
>>>
>>> You could possibly use --select feature to handle all removals with
>>> just one lvremove command.
>>
>> I tried --select, but there is a long pause between removals so it is
>> clearly doing a metadata operation for each removal.
>>
>> Is it possible to do something like this:
>>
>> 1. Hold a lock (how?)
>> 2. vgcfgbackup -f /my-backup/file --ignorelocking-failure
>> 3. Modify /my-backup/file (remove LVs)
>> 4. dmsetup message pool 0 delete ID (each ID)
>> 5. vgcfgrestore --ignorelocking-failure
>> 6. Release lock
>>


Also what is probably worthy exercise:

If you have thinLVs you want to 'remove' -

Deactivate all such LVs in one 'lvchange -an' command upfront.
Then as next step remove all such LVs with one  'lvremove' command.

Take a timed 'strace -ttt' and measure how much time is spend in actual 
'ioctl' and compare with the remaining time spend in lvm2 processing.

Then summarize  the output and your time-expectation  - possibly open RFE BZ 
for it.

Regards

Zdenek


