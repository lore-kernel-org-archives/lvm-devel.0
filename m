From: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Date: Fri, 10 Dec 2021 22:48:49 +0530
Subject: thin vol write performance variance
In-Reply-To: <CAFe+wq3g17abUGVz66-9BxB_dGWG3gQzjoWwHggJteNVPX_Ldw@mail.gmail.com>
References: <CAFe+wq3DUszqSVG6O5vOSMBv-EsAQ3Nru5jrhSK1nbz4uUPNgA@mail.gmail.com>
	<0e77c758-d804-61b6-73f1-3a268b03b6b2@redhat.com>
	<CAFe+wq2FRw7O_j0YeaKZANkPpqdus9DR675MO9Z42+kOiKPVyw@mail.gmail.com>
	<CAFe+wq2KVpPoESYEAhMW1dzzNSWRj6jwJ0m90bxA_AfW=UxvOg@mail.gmail.com>
	<CAFe+wq0k0HKJyngKQL6vgoZvW2Ht0xzDbFpnEgY43WeGWt42eg@mail.gmail.com>
	<CAFe+wq1hhi9v3q09edkpg5eFf-8SNO2n8dLtY51TT1d3v-FO=Q@mail.gmail.com>
	<b99b0c5b-80ab-13d8-d1d9-207d1fe6aa89@gmail.com>
	<CAFe+wq3g17abUGVz66-9BxB_dGWG3gQzjoWwHggJteNVPX_Ldw@mail.gmail.com>
Message-ID: <CAFe+wq0REBKhgNkEtJf2mz+uok_emzVcWDH9bP=ccT8WkmYCpw@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Zdenek and team!

This issue looks very similar to dm block IO handling not using blkmq
driver.
IIRC the queue limits are not honoured for non blkmq devices.

So how can thin pool/thin dm devices be forced to use blkmq rq based device
driver?
As noted in this thread, we are seeing a huge number of inflight IO on the
dm device and any sync takes a huge time to complete.
Please advise.

As a reference I compared a root ssd with the thin device and the
appropriate sysfs dir(mq) is missing for dm devices, clearly
indicating that dm device do not use blkmq rq based driver. See further
logs below.

```
A sample thin device.
[root at ip-70-0-75-200 ~]# dmsetup table pwx0-1076133386023951605
0 20971520 thin 253:2 17
[root at ip-70-0-75-200 ~]# dmsetup info !$
dmsetup info pwx0-1076133386023951605
Name:              pwx0-1076133386023951605
State:             ACTIVE
Read Ahead:        0
Tables present:    LIVE
Open count:        2
Event number:      0
Major, minor:      253, 14
Number of targets: 1
UUID: LVM-fREck6REefH765WAA8XAPZn6j78uhNBQHKcYDE9TSjDIk2tLGk5cDz0y7GNcz94C

[root at ip-70-0-75-200 ~]# ls -al /dev/mapper/pwx0-1076133386023951605
lrwxrwxrwx 1 root root 8 Dec 10 16:49 /dev/mapper/pwx0-1076133386023951605
-> ../dm-14
[root at ip-70-0-75-200 ~]# ls -l /sys/block/dm-14/ <<<<<< NOTE no mq sysfs
file here
total 0
-r--r--r-- 1 root root 4096 Dec 10 17:13 alignment_offset
lrwxrwxrwx 1 root root    0 Dec 10 17:13 bdi -> ../../bdi/253:14
-r--r--r-- 1 root root 4096 Dec 10 17:13 capability
-r--r--r-- 1 root root 4096 Dec 10 17:08 dev
-r--r--r-- 1 root root 4096 Dec 10 17:13 discard_alignment
drwxr-xr-x 2 root root    0 Dec 10 17:08 dm
-r--r--r-- 1 root root 4096 Dec 10 17:13 events
-r--r--r-- 1 root root 4096 Dec 10 17:13 events_async
-rw-r--r-- 1 root root 4096 Dec 10 17:13 events_poll_msecs
-r--r--r-- 1 root root 4096 Dec 10 17:13 ext_range
-r--r--r-- 1 root root 4096 Dec 10 17:13 hidden
drwxr-xr-x 2 root root    0 Dec 10 17:08 holders
-r--r--r-- 1 root root 4096 Dec 10 17:13 inflight
drwxr-xr-x 2 root root    0 Dec 10 17:13 integrity
drwxr-xr-x 2 root root    0 Dec 10 17:13 power
drwxr-xr-x 2 root root    0 Dec 10 17:08 queue
-r--r--r-- 1 root root 4096 Dec 10 17:13 range
-r--r--r-- 1 root root 4096 Dec 10 17:13 removable
-r--r--r-- 1 root root 4096 Dec 10 17:13 ro
-r--r--r-- 1 root root 4096 Dec 10 17:08 size
drwxr-xr-x 2 root root    0 Dec 10 17:08 slaves
-r--r--r-- 1 root root 4096 Dec 10 17:13 stat
lrwxrwxrwx 1 root root    0 Dec 10 17:08 subsystem ->
../../../../class/block
drwxr-xr-x 2 root root    0 Dec 10 17:13 trace
-rw-r--r-- 1 root root 4096 Dec 10 16:48 uevent
[root at ip-70-0-75-200 ~]# ls -l /sys/block/dm-14/dm
total 0
-r--r--r-- 1 root root 4096 Dec 10 17:08 name
-rw-r--r-- 1 root root 4096 Dec 10 17:13 rq_based_seq_io_merge_deadline
-r--r--r-- 1 root root 4096 Dec 10 17:13 suspended
-r--r--r-- 1 root root 4096 Dec 10 17:13 use_blk_mq
-r--r--r-- 1 root root 4096 Dec 10 17:08 uuid
[root at ip-70-0-75-200 ~]# cat /sys/block/dm-14/dm/use_blk_mq <<<<< THIS IS
STUBBED TO BE ALWAYS '1'
1
[root at ip-70-0-75-200 ~]#
[root at ip-70-0-75-200 ~]#
[root@ip-70-0-75-200 ~]# ls -al /sys/block/sda/
total 0
drwxr-xr-x 11 root root    0 Dec 10 17:08 .
drwxr-xr-x  3 root root    0 Dec 10 17:08 ..
-r--r--r--  1 root root 4096 Dec 10 17:14 alignment_offset
lrwxrwxrwx  1 root root    0 Dec 10 17:14 bdi ->
../../../../../../../virtual/bdi/8:0
-r--r--r--  1 root root 4096 Dec 10 17:14 capability
-r--r--r--  1 root root 4096 Dec 10 17:08 dev
lrwxrwxrwx  1 root root    0 Dec 10 17:08 device -> ../../../2:0:0:0
-r--r--r--  1 root root 4096 Dec 10 17:14 discard_alignment
-r--r--r--  1 root root 4096 Dec 10 17:14 events
-r--r--r--  1 root root 4096 Dec 10 17:14 events_async
-rw-r--r--  1 root root 4096 Dec 10 17:14 events_poll_msecs
-r--r--r--  1 root root 4096 Dec 10 17:14 ext_range
-r--r--r--  1 root root 4096 Dec 10 17:14 hidden
drwxr-xr-x  2 root root    0 Dec 10 17:08 holders
-r--r--r--  1 root root 4096 Dec 10 17:14 inflight
drwxr-xr-x  2 root root    0 Dec 10 17:14 integrity
drwxr-xr-x  3 root root    0 Dec 10 17:14 mq <<<<<<<<<<<< root SSD has 'mq'
sysfs directory for blkmq implementation
drwxr-xr-x  2 root root    0 Dec 10 17:14 power
drwxr-xr-x  3 root root    0 Dec 10 17:14 queue
-r--r--r--  1 root root 4096 Dec 10 17:14 range
-r--r--r--  1 root root 4096 Dec 10 17:14 removable
-r--r--r--  1 root root 4096 Dec 10 17:14 ro
drwxr-xr-x  5 root root    0 Dec 10 17:08 sda1
drwxr-xr-x  5 root root    0 Dec 10 17:08 sda2
-r--r--r--  1 root root 4096 Dec 10 17:14 size
drwxr-xr-x  2 root root    0 Dec 10 17:14 slaves
-r--r--r--  1 root root 4096 Dec 10 17:14 stat
lrwxrwxrwx  1 root root    0 Dec 10 17:08 subsystem ->
../../../../../../../../class/block
drwxr-xr-x  2 root root    0 Dec 10 17:14 trace
-rw-r--r--  1 root root 4096 Dec 10 16:49 uevent
[root at ip-70-0-75-200 ~]# ls -al /sys/block/sda/mq
total 0
drwxr-xr-x  3 root root 0 Dec 10 17:14 .
drwxr-xr-x 11 root root 0 Dec 10 17:08 ..
drwxr-xr-x  6 root root 0 Dec 10 17:14 0
[root at ip-70-0-75-200 ~]# ls -al /sys/block/sda/mq/0
total 0
drwxr-xr-x 6 root root    0 Dec 10 17:14 .
drwxr-xr-x 3 root root    0 Dec 10 17:14 ..
drwxr-xr-x 2 root root    0 Dec 10 17:14 cpu0
drwxr-xr-x 2 root root    0 Dec 10 17:14 cpu1
drwxr-xr-x 2 root root    0 Dec 10 17:14 cpu2
drwxr-xr-x 2 root root    0 Dec 10 17:14 cpu3
-r--r--r-- 1 root root 4096 Dec 10 17:14 cpu_list
-r--r--r-- 1 root root 4096 Dec 10 17:14 nr_reserved_tags
-r--r--r-- 1 root root 4096 Dec 10 17:14 nr_tags
[root at ip-70-0-75-200 ~]#
```



On Wed, Dec 8, 2021 at 10:38 PM Lakshmi Narasimhan Sundararajan <
lsundararajan@purestorage.com> wrote:

> Hi Zdenek,
> Thanks for the reply.
> I have confirmation on the Zeroing of thin chunks, they are disabled.
> And I followed it up further to post additional details I collected on the
> same write performance issue.
>
> The summary is, for buffered IO there seems to be way more IOs queued than
> by the configured limit (queue/nr_requests).
> The thin dm device is not honouring this limit and has so many excess IO
> in flight, that any sync IO eventually stalls for a very long time.
>
> The details are in the thread. Can you confirm if this is a known issue?
> And what workaround would you suggest?
> If not pointers, to possible areas to explore?
>
> Regards
>
>
>
>
>
>
>
>
> On Mon, Dec 6, 2021 at 7:27 PM Zdenek Kabelac <zdenek.kabelac@gmail.com>
> wrote:
>
>> Dne 06. 12. 21 v 7:11 Lakshmi Narasimhan Sundararajan napsal(a):
>> > Bumping this thread, any inputs would be appreciated.
>> >
>> >>>>> Do you measure writes while provisioning thin chunks or on already
>> provisioned
>> >>>>> device?
>> >>>>>
>> >>>>
>> >>>> Hi Zdenek,
>> >>>> These are traditional HDDs. Both the thin pool data/metadata reside
>> on
>> >>>> the same set of drive(s).
>> >>>> I understand where you are going with this, I will look further into
>> >>>> defining the hardware/disk before I bring it to your attention.
>> >>>>
>> >>>> This run was not on an already provisioned device. I do see improved
>> >>>> performance of the same volume after the first write.
>> >>>> I understand this perf gain to be the overhead that is avoided during
>> >>>> the subsequent run where no mappings need to be established.
>> >>>>
>> >>>> But, you mentioned zeroing of provisioned blocks as an issue.
>> >>>> 1/ during lvcreate -Z from the man pages reports only controls the
>> >>>> first 4K block. And also implies this is a MUST otherwise fs may
>> hang.
>> >>>> So, we are using this. Are you saying this controls zeroing of each
>> >>>> chunk that's mapped to the thin volume?
>>
>> Yes - for 'lvcreate --type thin-pool' the option -Z controls 'zeroing' of
>> thin-pool's thin volumes
>>
>> The bigger the chunks are, the bigger the impact of zeroing will be.
>>
>>
>> >>>>
>> >>>> 2/ The other about zeroing all the data chunks mapped to the thin
>> >>>> volume, I could see only reference in the lvm.conf under
>> >>>> thin_pool_zero,
>> >>>> This is default enabled. So are you suggesting I disable this?
>>
>> If you don't need it - disable it - it's kind of more secure to have it
>> enabled - but if you use 'filesystem' like  ext4 on top - zeroing doesn't
>> help
>> as user of filesystem cannot read unwritten data. However if you read
>> device as root - you might be able to read 'stale' data from unwritten
>> parts
>> of data from provisioned chunks.
>>
>>
>> >>>>
>> >>>> Please confirm the above items. I will come back with more precise
>> >>>> details on the details you had requested for.
>> >>>>
>>
>>
>> As a side note - metadata device should preferabl sit on different
>> spindle
>> (SSD, nvme,...) as this is high-bandwith device and might frequently
>> collide
>> with your  _tdata volume writes.
>>
>> Regrards
>>
>> Zdenek
>>
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20211210/ebff5a43/attachment.htm>
