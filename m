From: Oliver Rath <rath@mglug.de>
Date: Wed, 05 Feb 2014 08:35:56 +0100
Subject: cache support
In-Reply-To: <096101cf2214$d241ed60$76c5c820$@acm.org>
References: <096101cf2214$d241ed60$76c5c820$@acm.org>
Message-ID: <52F1E9DC.60809@mglug.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Paul,

you can create a cache-device with dm-cache, i.e. /dev/mapper/cache0,
which consists your underlying disks cached by your ssd. The critical
point is imho, that you have to create the cache device first, then the
PV on the *cache device* cache0, then to create the VG consisting on
cache0, getting the right name for this. As result you get the disk ids
twice, so you have to filter the ids by lvm.conf.

@list: Is there a solution for this "doubling" case?

Alternativly you can use bcache, which needs a "superblock" on both
devices, so that you arent offended by doubling ID. Or you can try
enhanceIO (not in standard kernel yet), which caches your device
transparently without using the dm-mechanism and creating a virtual new
device.

Hth
Oliver


On 05.02.2014 02:51, Paul B. Henson wrote:
> So I was browsing through the last month or so of list archives and
> reviewing the cache support under development, and had a question regarding
> use cases. Unless I am misunderstanding, it looks like the support being
> built so far addresses the use case of taking two lv's (a large slow origin
> lv and a small fast cache lv) and combining them into a third lv.
>
> Is there any intention to support a use case where you can attach a cache to
> the underlying pv, and have every single lv created on that pv cached? On a
> virtualization server I'm working on, I have an md raid1 of two 256G SSD's,
> and an md raid10 of four 2TB hard drives. What I'd like to do is create a
> cache device consisting of those two raid devices, and create a pv/vg on top
> of that. I know that is possible with the raw underlying dm-cache
> implementation, but it didn't look like the initial code dropped in lvm so
> far would support something like that?
>
> Thanks.
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel


