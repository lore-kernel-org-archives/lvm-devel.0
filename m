From: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Date: Thu, 12 Oct 2023 22:09:52 +0530
Subject: Reg lvmcache and cache drain
In-Reply-To: <77c3a7dc-e9c5-4157-a3fc-87e46c636c17@gmail.com>
References: <CAFe+wq26RaHMPsC_nN+60ycQBAJYtR9Y9CQV=w89RkiwKOgY-g@mail.gmail.com>
 <77c3a7dc-e9c5-4157-a3fc-87e46c636c17@gmail.com>
Message-ID: <CAFe+wq0ih=Vb=i1KEN9s0uf8hs9ThT9CZTSFy1m0xHS2GJuO=Q@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Thanks Zdenek, below are my replies.

> Not clear which combination has been actually tested - but to quickly drain
cache, it should be switched to cleaner policy  (that within lvm should
automatically switches also a caching mode to 'writethrough'.

Yes cache policy switches to "cleaner" with higher
migration_threshold. While IO continues to hit the cache device,
write/read hits counter also increases and dirty block counter does
not show much difference. So my reading was newer IOs continue to
create newer dirty blocks and migration is slow (deferred or performed
at only one lru level) as the device is not idle. If the cache device
is writethrough while in cleaner policy, then dirty block counter
should decrease appreciably (very slow vs when IO load off) over
period of time, this does not line up with your recommendation.

Forcing cache mode to "writethrough" (in addition to applying cleaner
policy and higher migration_threshold) locked the lvm access out,
because cli is stuck waiting for cache to drain (Flushing xxx blocks
for cache xxx) and one could see the dirty drain very slow i.e. for
many many observed hours dirty counter does not decrease
significantly.

But if incoming IO is taken off, then cache drains immediately (i.e.
at a very fast rate, few hours likely to drain all good)
The time line for cache drain was for days with IO load on, it did not
show any significant decrease. While if IO is cut off then cache drain
is in hours.

> So if your 'draining' also switching to cleaner cache policy from smq.  ?

Yes


Setup is caching a thin pool device with multiple cache device in
concat mode. These are really heavy duty setups as one could observe.
details you had requested below.

a) dmsetup table

pwx0-cache_cdata: 0 18748121088 linear 8:96 2376064
pwx0-cache_cdata: 18748121088 18750496768 linear 8:128 384
pwx0-cache_cdata: 37498617856 18746023936 linear 8:32 2097536
pwx0-cache_cmeta: 0 2375680 linear 8:96 384
pwx0-pxpool: 0 527335596032 linear 253:5 0
pwx0-pxpool-tpool: 0 527335596032 thin-pool 253:0 253:4 2176 0 2
skip_block_zeroing no_discard_passdown
pwx0-pxpool_tdata: 0 527335596032 cache 253:2 253:1 253:3 2048 2
metadata2 writeback smq 2 migration_threshold 2048000
pwx0-pxpool_tdata_corig: 0 527335596032 linear 9:125 28235776 // md125 device
pwx0-pxpool_tmeta: 0 30302208 linear 9:125 527363831808 // md125 device


b) dmsetup status

pwx0-cache_cdata: 0 18748121088 linear
pwx0-cache_cdata: 18748121088 18750496768 linear
pwx0-cache_cdata: 37498617856 18746023936 linear
pwx0-cache_cmeta: 0 2375680 linear
pwx0-pxpool: 0 527335596032 linear
pwx0-pxpool-tpool: 0 527335596032 thin-pool 1058 1052066/3787776
176876736/242341726 - rw no_discard_passdown queue_if_no_space - 1024
pwx0-pxpool_tdata: 0 527335596032 cache 8 82136/296960 2048
27463202/27463204 503213080 353897673 2946987239 3588157975 1740371
1740642 27457769 3 metadata2 writeback no_discard_passdown 2
migration_threshold 2048000 smq 0 rw -
pwx0-pxpool_tdata_corig: 0 527335596032 linear
pwx0-pxpool_tmeta: 0 30302208 linear


c) lsblk -d

lsblk -d
NAME MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT

sdi    8:128  0  34.5T  0 disk
sdg    8:96   0   250G  0 disk
sdc    8:32   0  34.5T  0 disk

sdd    8:48   0 218.3T  0 disk
sdj    8:144  0 218.3T  0 disk


d) blkid

blkid -d

/dev/sdc: UUID="d6fa7f5e-a546-4ea1-7f9a-f353936110e0"
UUID_SUB="0d2a0220-9b3d-6521-b038-ffe416a8b722" LABEL="daas-ch2-s20:1"
TYPE="linux_raid_member"

/dev/sdi: UUID="d6fa7f5e-a546-4ea1-7f9a-f353936110e0"
UUID_SUB="5c6853ff-c4b1-212c-38a4-4c7d8b5d1e1c" LABEL="daas-ch2-s20:1"
TYPE="linux_raid_member"
/dev/sdg: UUID="ec5f625e-b0f8-52be-9c3b-a186d5ad0338"
UUID_SUB="3950581b-9b16-045b-ff3f-f728f36664d0" LABEL="daas-ch2-s20:0"
TYPE="linux_raid_member"

/dev/md127: UUID="6506d728-cd97-115a-568e-0bd0a43f9a46"
UUID_SUB="c6eb33ec-3997-e062-4e39-ba8d30d15a56" LABEL="any:pwx0"
TYPE="linux_raid_member"


e) mdstatus (md device)

md127 : active raid0 sdj[1] sdd[0]
      468753838080 blocks super 1.2 1280k chunks


f) and lastly each of the physical devices are sitting on a high end
raid controller device, each block device does 1-2MBps.

g) versions

uname -a ; lvm version
Linux daas-ch2-s01 5.14.15-1.el7.elrepo.x86_64 #1 SMP Tue Oct 26
11:43:20 EDT 2021 x86_64 x86_64 x86_64 GNU/Linux
File descriptor 63 (pipe:[584188137]) leaked on lvm invocation. Parent
PID 17877: bash
  LVM version:     2.02.187(2)-RHEL7 (2020-03-24)
  Library version: 1.02.170-RHEL7 (2020-03-24)
  Driver version:  4.45.0

h) cache device counters

TotalBlocks: 73249540
UsedBlocks: 73249539
DirtyBlocks: 72866906
ReadHits: 1292406883
ReadMisses: 336394808
WriteHits: 4238927778
WriteMisses: 961590033
Promotions: 0
Demotions: 0
BlockSize: 1048576
Mode: writeback
Policy: cleaner
Tunables: migration_threshold=8192000



On Thu, Oct 12, 2023 at 5:19?PM Zdenek Kabelac <zdenek.kabelac@gmail.com> wrote:
>
> Dne 11. 10. 23 v 6:14 Lakshmi Narasimhan Sundararajan napsal(a):
> > Hi Team,
> > A very good day to you all.
> > I am looking at your inputs to effectively configure cache to drain at
> > max speed while being online.
> >
> > I have a setup with lvm cache, writeback, smq, migration threshold to
> > support 100 cache blocks to start with (that gets relaxed to higher
> > values as dirty blocks increase). This cache device is operating near
> > full and switched to cleaner policy to enable effective cache drain of
> > dirty blocks.
> >
> > But the observation is as follows.
> > 1/ given cache is in writeback mode and online, newer IOs effectively
> > create new dirty blocks.
> >
> > 2/ incoming IOs to cache device do seem to have higher precedence vs
> > IO migration of dirty data from within cache to origin. Effectively
> > migration kick starts only from one level within (lru logic within)
> > when cache/origin is not idle. This effectively limits the clean
> > transition rate irrespective of the migration threshold.
> >
> > 3/ switching cache to writethrough effectively blocks the cli forever
> > and still the migration is not fast enough. Only taking the IO
> > offline, i.e. device should be IDLE within, triggers that burst of
> > migrations.
>
> Hi
>
> Not clear which combination has been actually tested - but to quickly drain
> cache, it should be switched to cleaner policy  (that within lvm should
> automatically switches also a caching mode to 'writethrough'.
>
> So if your 'draining' also switching to cleaner cache policy from smq.  ?
>
> Can you provide a bit more context with timing information and DM table line
> and DM status lines from your testing so we could more easily understand this
> issue ?
>
> Also show the kernel versions in use - was this vanilla ?
>
> Thanks
>
> Zdenek
>

