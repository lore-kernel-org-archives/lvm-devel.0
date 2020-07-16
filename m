From: Lakshmi Narasimhan Sundararajan <lns@portworx.com>
Date: Thu, 16 Jul 2020 19:24:44 +0530
Subject: cache flush dirty block gets reset and stalls
In-Reply-To: <CAHFy8gBkpm6LbhPM-qvSHExMXoECZPWm=o3OVWi=ik+YuvyGXA@mail.gmail.com>
References: <CAHFy8gBkpm6LbhPM-qvSHExMXoECZPWm=o3OVWi=ik+YuvyGXA@mail.gmail.com>
Message-ID: <CAHFy8gDKDbDY7WGzc=KstjaK_Y2CUiJmc1WODtyWM2Z9tx0BMQ@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Bumping the thread again.
I would appreciate knowing under what scenarios would cache dirty
count reset to (likely) all blocks or pointers to understand below
issue further.

Regards

On Wed, Jul 15, 2020 at 4:20 PM Lakshmi Narasimhan Sundararajan
<lns@portworx.com> wrote:
>
> Hi Team!
> I have a strange issue with lvm cache flush operation with the dirty
> block count that I seek your inputs on.
>
> I have a lvm cache setup.
> First up, I down the application and confirm there is no IO to the lvm volume.
> I had to flush the cache, and in that regard I configure the cache to
> "cleaner" policy (lvchange --cachepolicy cleaner lvname)
> Monitor the statistics through dm(dmsetup status lvname) and wait for
> the dirty block count to fall to zero.
> First time, it does fall to zero, and the policy is reset back to smq,
> and immediately dirty blocks get reset to all blocks being dirty.
> This issue is not easily reproducible, but I wonder if you are aware
> of any race conditions that could make this happen.
>
> flush begins with dirty blocks of `DirtyBlocks:  22924 `
> but after initiating the cache flush, I see this: `DirtyBlocks: 716092`
>
> other params:
>         Cache Drives:
>         0:0: /dev/sdb, capacity of 12 TiB, Online
>                 Status:  Active
>                 TotalBlocks:  762954
>                 UsedBlocks:  762933
>                 DirtyBlocks:  22924 // start value
>                 ReadHits:  279814819
>                 ReadMisses:  9167869
>                 WriteHits:  2403296698
>                 WriteMisses:  53680397
>                 Promotions:  1082433
>                 Demotions:  1082443
>                 BlockSize:  16777216
>                 Mode:  writeback
>                 Policy:  smq
>                 Tunables:  migration_threshold=4915200
>
>
> In continuing from the above scenario, since the dirty blocks are
> huge, I reset migration threshold to a larger value, to allow the
> flush
> to drain fast, but now, cache flush is stuck (lvchange --cachesettings
> "migration_threshold=4915200000"). The command passes, but there is no
> change in status report from dm. And in addition to that, the cache
> drain is stuck and is not progressing at all.
> [root at daas-ch2-s03 ~]# dmsetup status <lvname>
> 0 234398408704 cache 8 2273/10240 32768 762938/762954 127886048
> 4873858 3596075403 27445796 0 0 __761121__ 1 writeback 2
> migration_threshold 4915200 smq 0 rw -
> [root at daas-ch2-s03 ~]#
>
> Below are the relevant versions.
> [root at daas-ch2-s03 ~]# lvm version
>   LVM version:     2.02.186(2)-RHEL7 (2019-08-27)
>   Library version: 1.02.164-RHEL7 (2019-08-27)
>   Driver version:  4.39.0
> [root at daas-ch2-s03 ~]# dmsetup version
> Library version:   1.02.164-RHEL7 (2019-08-27)
> Driver version:    4.39.0
>
> The setup is lost, I have the lvmdump output and can share if needed.
> And the issue is not easily reproducible at all.
>
> I would sincerely appreciate, if someone can point me to understand
> this issue better.
>
> Regards
> LN


