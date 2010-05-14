From: Takahiro Yasui <tyasui@redhat.com>
Date: Fri, 14 May 2010 18:52:34 -0400
Subject: [PATCH] handle transient errors in lvconvert --repair
In-Reply-To: <87y6fxos3x.fsf@twilight.int.mornfall.net.>
References: <87y6g99bbg.fsf@twilight.int.mornfall.net.>	<87pr1kai2k.fsf@twilight.int.mornfall.net.>
	<87y6fxos3x.fsf@twilight.int.mornfall.net.>
Message-ID: <4BEDD432.4010800@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Petr,

> I have rebased the patch against current CVS. Also, I have added a guard
> to _mirrored_transient_status to ensure that we alloca() only very
> modest (and, more importantly, bounded) amount of memory.

This patch is just a rebase against current CVS, so it doesn't support
mirrored log, yet. Do you have a plan to support mirrored log?

I also tested this patch for a lvm mirror with core/disk log. When
a mirror log failed, the mirror log was removed from a mirror volume,
but a log voluem is not removed from its volume group. This always
happens both on a transient and persistent error.

Here is an output of lvs command in my testing environment. lv00_mlog
should be removed from vg00.

# dmsetup ls
vg00-lv00_mimage_1      (253, 2)
vg00-lv00_mimage_0      (253, 1)
vg00-lv00       (253, 3)

# lvs
  LV        VG   Attr   LSize  Origin Snap%  Move Log Copy%  Convert
  lv00      vg00 mwi-a- 12.00M                        100.00
  lv00_mlog vg00 -wi---  4.00M

I will report if I get the reason of this.

Thanks,
Taka


