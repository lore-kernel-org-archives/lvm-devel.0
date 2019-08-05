From: Lakshmi Narasimhan Sundararajan <lns@portworx.com>
Date: Mon, 5 Aug 2019 14:15:03 +0530
Subject: lvmcache lv destroy with no flush
In-Reply-To: <abe351bf-e73a-f7c2-9e52-fc8b542321fb@redhat.com>
References: <5d426f7f.1c69fb81.24900.f111@mx.google.com>
	<99f6e920-d920-4ec4-813a-48c5f22ae7f6@redhat.com>
	<5d443e89.1c69fb81.d73bc.00df@mx.google.com>
	<93895828-a482-7729-bf7e-132afd4bf767@redhat.com>
	<5d444783.1c69fb81.96e35.3a01@mx.google.com>
	<abe351bf-e73a-f7c2-9e52-fc8b542321fb@redhat.com>
Message-ID: <5d47ec90.1c69fb81.d27e3.c5e4@mx.google.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Thanks Zdenek, for your follow up email clarifying my questions.
I will have to check further and shall report back.

But, I also wonder why on a writeback cache even if I do submit blkdiscard to the whole device, the dirty blocks do not fall to zero?
Does blkdiscard on lvmcache device not work? 

> myhome$ sudo dmsetup status --target cache
> pxtest-pool: 0 20963328 cache 8 40/2048 2048 4096/10220 28 58 0 0 0 0 4096 1 writethrough 2 migration_threshold 2048 cleaner 0 rw -
> myhome$
> myhome$ sudo blkdev ?getsize64 /dev/pxtest/pool
<devsize>
>myhome$ sudo blkdiscard -o 0 -l ROUND_DISCARD_ALIGN(devsize) /dev/pxtest/pool

Even after the above discard, the lvmcache device in writeback mode holds dirty blocks. And has to be flushed. Can you please help explain the behavior here?

Regards
LN 
Sent from Mail for Windows 10

From: Zdenek Kabelac
Sent: Monday, August 5, 2019 1:53 PM
To: Lakshmi Narasimhan Sundararajan; LVM2 development
Subject: Re: [lvm-devel] lvmcache lv destroy with no flush

Dne 02. 08. 19 v 16:24 Lakshmi Narasimhan Sundararajan napsal(a):
>   * 1.) remove devices from DM table
>   * dmsetup remove_all
>   * (or just some selected device - whatever fits...)
>   *
>   * 2.) remove disk singatures of VG
>   * wipefs -a /dev/sdc
>   * wipefs -a /dev/nvme0n1
>   * (or pvremove -ff /dev/sdc /dev/nvme0n1)
>   *
>   * 3.) recreate empty VG from scratch
>   * vgcreate pxtest /dev/sdc /dev/nvme0n1
> 
> myhome$ sudo dmsetup status --target cache
> 
> pxtest-pool: 0 20963328 cache 8 40/2048 2048 4096/10220 28 58 0 0 0 0 4096 1 
> writethrough 2 migration_threshold 2048 cleaner 0 rw -
> 
> myhome$ sudo dmsetup remove pxtest-pool


Unfortunatelly you must remove ALL related device.


>  ? 0 logical volume(s) in volume group "pxtest" now active
> 
> myhome$ sudo pvremove -ff /dev/sdc /dev/nvme0n1
> 
> Really WIPE LABELS from physical volume "/dev/sdc" of volume group "pxtest" 
> [y/n]? y
> 
>  ? WARNING: Wiping physical volume label from /dev/sdc of volume group "pxtest"
> 
>  ? Can't open /dev/sdc exclusively - not removing. Mounted filesystem?

As you can see - you still have some device holding sdc open.

As said origin - all used of  your SDC & NVME device must be removed - so 
devices are 'free'.

You can't be killing VG while DM device are still running in memory.

> 
> Really WIPE LABELS from physical volume "/dev/nvme0n1" of volume group 
> "pxtest" [y/n]? y
> 
>  ? WARNING: Wiping physical volume label from /dev/nvme0n1 of volume group 
> "pxtest"
> 
>  ? Can't open /dev/nvme0n1 exclusively - not removing. Mounted filesystem?
> 
> myhome$
> 
> myhome$ sudo wipefs -a /dev/sdc /dev/nvme0n1
> 
> wipefs: error: /dev/sdc: probing initialization failed: Device or resource busy
> 
> myhome$
> 
> Doesn?t seem to work, there are still exclusive references on the drive held 
> by lvm!


Note - lvm2 never helds ANY reference - lvm2 is pure tool for manipulation 
with DM devices - aka you can do those DM devices yourself without any lvm2 in 
place - it's just way more work.

So back to question who keeps devices open - you can easily get this info from 
command like these:


dmsetup table

dmsetup ls --tree

lsbls
...


Before you start any device wiping for VG metadata - there must be no runing 
device holding those device open - and as you are basically bypassing lvm2 
when you run 'drastic' commands like 'dmsetup' or 'wipefs' yourself - you 
can't blame lvm2 for not being cooperative for such 'violence' usage :)
As has been originally said - advice was serious HACK in the lvm2 workflow....

Regards

Zdenek

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20190805/ee40a877/attachment.htm>
