From: John Drescher <drescherjm@gmail.com>
Date: Fri, 25 Feb 2011 09:40:22 -0500
Subject: pvcreate problem with 2 metadata areas.
In-Reply-To: <AANLkTin0RsuoVZfU9XtySSrpnYzUUwOKZ80Wix6q2z-B@mail.gmail.com>
References: <AANLkTikj8hnsTYne61TXzFyubmLLNvo1QD4kgBudxubt@mail.gmail.com>
	<4D63D54C.5020605@redhat.com>
	<AANLkTin0RsuoVZfU9XtySSrpnYzUUwOKZ80Wix6q2z-B@mail.gmail.com>
Message-ID: <AANLkTikFJbTW1_pD2Qfgc-GdTYXE0fGDu86qxPu9TVcJ@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Feb 25, 2011 at 9:30 AM, John Drescher <drescherjm@gmail.com> wrote:
> On Tue, Feb 22, 2011 at 10:25 AM, Peter Rajnoha <prajnoha@redhat.com> wrote:
>> On 02/22/2011 03:57 PM +0100, John Drescher wrote:
>>> localhost ~ # pvcreate /dev/md0 --pvmetadatacopies 2
>>> ? Physical volume "/dev/md0" successfully created
>>> localhost ~ # pvck -v /dev/md0
>>> ? ? Scanning /dev/md0
>>> ? Found label on /dev/md0, sector 1, type=LVM2 001
>>> ? Found text metadata area: offset=4096, size=1044480
>>> ? Found text metadata area: offset=3215852032, size=1048576
>>> ? /dev/md0: lseek 3216900096 failed: Invalid argument
>>> ? Read from /dev/md0 failed
>>>
>>> It looks like the second metadata copy is 4096 bytes too large.
>>>
>>
>> The last patches sent upstream yesterday are quite risky and we
>> are still testing these changes. However, the best way we found
>> was to put these changes upstream directly for even more thorough
>> testing.
>>
>> We're still working on this and we expect some time (hopefully
>> short) to catch and fix all remaining bugs.
>>
>> Thank you very much for the feedback. You're welcome to report
>> any other issues you hit. This will help us a lot to resolve all
>> remaining problems.
>>
>
> With todays update the creation of 2 pvmetadataareas works for me.
>
> localhost ~ # pvcreate /dev/md0 --pvmetadatacopies 2
> ?Physical volume "/dev/md0" successfully created
> localhost ~ # pvck -v /dev/md0
> ? ?Scanning /dev/md0
> ?Found label on /dev/md0, sector 1, type=LVM2 001
> ?Found text metadata area: offset=4096, size=1044480
> ?Found text metadata area: offset=3214934016, size=1048576
> localhost ~ #
>
> I will now try expanding the array. This failed before this change
> with a checksum error.

localhost ~ # mdadm -G /dev/md0 -l 5 -n 4
mdadm: Need to backup 3072K of critical section..
localhost ~ # cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] [raid0] [raid1] [raid10]
md0 : active raid5 sdf1[4] sde1[3] sdd1[1] sdc1[0]
      3140608 blocks super 1.2 level 5, 512k chunk, algorithm 2 [4/4] [UUUU]
      [>....................]  reshape =  2.7% (42524/1570304)
finish=2.3min speed=10631K/sec

unused devices: <none>
localhost ~ # pvresize /dev/md0
  Physical volume "/dev/md0" changed
  1 physical volume(s) resized / 0 physical volume(s) not resized
localhost ~ # pvck -v /dev/md0
    Scanning /dev/md0
  Found label on /dev/md0, sector 1, type=LVM2 001
  Found text metadata area: offset=4096, size=1044480
  Found text metadata area: offset=3214934016, size=1048576

Hmm. It looks like mdadm is not expanding the size until the grow
finishes.. Should lvm2 have tried to resize a pv by 0 bytes?

Okay now waiting a few minutes for the grow to almost finish:

localhost ~ # cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] [raid0] [raid1] [raid10]
md0 : active raid5 sdf1[4] sde1[3] sdd1[1] sdc1[0]
      3140608 blocks super 1.2 level 5, 512k chunk, algorithm 2 [4/4] [UUUU]
      [===================>.]  reshape = 98.6% (1550336/1570304)
finish=0.0min speed=17867K/sec

unused devices: <none>
localhost ~ # cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] [raid0] [raid1] [raid10]
md0 : active raid5 sdf1[4] sde1[3] sdd1[1] sdc1[0]
      4710912 blocks super 1.2 level 5, 512k chunk, algorithm 2 [4/4] [UUUU]

unused devices: <none>

localhost ~ # pvresize /dev/md0 -v
    Using physical volume(s) on command line
    Wiping cache of LVM-capable devices
    Wiping cache of LVM-capable devices
    Resizing volume "/dev/md0" to 6281216 sectors.
    Updating physical volume "/dev/md0"
  Physical volume "/dev/md0" changed
  1 physical volume(s) resized / 0 physical volume(s) not resized
localhost ~ # pvck -v /dev/md0
    Scanning /dev/md0
  Found label on /dev/md0, sector 1, type=LVM2 001
  Found text metadata area: offset=4096, size=1044480
  Found text metadata area: offset=4822925312, size=1048576
localhost ~ #

Looks like that worked now.

Thank You.
-- 
John M. Drescher


