From: Lukas Czerner <lczerner@redhat.com>
Date: Mon, 13 Jun 2011 12:54:30 +0200 (CEST)
Subject: [PATCH v1 00/30] Ext4 snapshots
In-Reply-To: <BANLkTikdmT5vjXJHnRTT-=z8zFVAx+Y6_w@mail.gmail.com>
References: <1307459283-22130-1-git-send-email-amir73il@users.sourceforge.net>
	<BANLkTikAB-RDDS8PMMrFK-OuY6PuavBixA@mail.gmail.com>
	<alpine.LFD.2.00.1106081114240.5026@dhcp-27-109.brq.redhat.com>
	<BANLkTi=T1OtyRSWNTA6xhkTy5uaHWqA_XA@mail.gmail.com>
	<alpine.LFD.2.00.1106081716200.6609@dhcp-27-109.brq.redhat.com>
	<BANLkTikUXdvMQROYEdxnyfcPuB0e9ozMOg@mail.gmail.com>
	<BANLkTinU9Hegr3iA5it2vNjE_RYbB+8+RQ@mail.gmail.com>
	<BANLkTik9Mnq5yqK795pxyr8SK-3EOzzNhA@mail.gmail.com>
	<alpine.LFD.2.00.1106090834270.4138@dhcp-27-109.brq.redhat.com>
	<BANLkTi=fugrRE0P5m8nMPrH_kZqPZB7ajA@mail.gmail.com>
	<alpine.LFD.2.00.1106091012030.4138@dhcp-27-109.brq.redhat.com>
	<BANLkTin0RKZbDmB1movombH9o4HDpTnvFw@mail.gmail.com>
	<alpine.LFD.2.00.1106091443370.4138@dhcp-27-109.brq.redhat.com>
	<BANLkTinEJ6235sPNz_f92nfN0ac4qSnHtw@mail.gmail.com>
	<alpine.LFD.2.00.1106101044350.4502@dhcp-27-109.brq.redhat.com>
	<BANLkTikdmT5vjXJHnRTT-=z8zFVAx+Y6_w@mail.gmail.com>
Message-ID: <alpine.LFD.2.00.1106131204330.4328@dhcp-27-109.brq.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 13 Jun 2011, Amir G. wrote:

> On Fri, Jun 10, 2011 at 12:00 PM, Lukas Czerner <lczerner@redhat.com> wrote:
> >
> > --snip--
> >
> > Hi Amir,
> >
> > that is why I spoke with several dm people and all of them had the same
> > opinion. When you are not using the advantage of being at fs level,
> > there is no reason to have shapshoting at this level.
> >
> > And no, I am not blinded. I am trying to understand why is multisnap a
> > huge win everyone is saying, so I already asked ejt to step in and
> > give us an overview on how dm-multisnap works and why is it better
> > than the old implementation. Also I am trying it myslef, and so far
> > it works quite well. I might have some numbers later.
> >
> 
> (Dropping LKML - had enough of that attention for 1 week...)
> 
> Hi Lukas,
> 
> So did you get any numbers? Joe said you were not able to get good results.

Hi, yes I did had some bad numbers, but it was due to stupid setup I
have created :) metadata and data volume on the same drive, but in the
different partition. In the postmark test the performance drop was about
100% and that is quite expected as it probably caused a LOT of seeks.

But when I separated data and metadata I have very good results. Results
differs with the data block size used by dm.

Filesystem on bare device.
113 76 657.89 661.60 2000.00 325.80 328.61 329.28 661.60 1980.88 332.09
24363052.00 76242168.00

dm-multisnap
bs=128
146 118 423.73 512.06 1923.08 209.84 211.64 212.08 512.06 1904.69 213.89
18856334.00 59009348.00

bs=256
151 96 520.83 495.11 943.40 257.93 260.15 260.68 495.11 934.38 262.91
18231952.00 57055396.00

bs=512
134 96 520.83 557.92 1515.15 257.93 260.15 260.68 557.92 1500.67 262.91
20544960.00 64293764.00

bs=1024
119 70 714.29 628.24 1470.59 353.73 356.77 357.50 628.24 1456.53 360.56
23134662.00 72398024.00

bs=2048
128 76 657.89 584.07 1190.48 325.80 328.61 329.28 584.07 1179.10 332.09
21508006.00 67307536.00

bs=4096
131 84 595.24 570.69 1851.85 294.77 297.31 297.92 570.69 1834.15 300.46
21015456.00 65766144.00

Legend:
-----------------------------------------------------------------------
Total_duration Duration_of_transactions Transactions/s
Files_created/s Creation_alone/s Creation_mixed_with_transaction/s
Read/s Append/s Deleted/s Deletion_alone/s
Deletion_mixed_with_transaction/s Read_B/s Write_B/s
-----------------------------------------------------------------------

I choosed postmark because it is doing a lot of operation on the file
and it is quite metadata intensive. Although it is still very simple
and limited test. However you can see that with data block size 1024B I
received almost the same results as in the case of bare device. It means
that there was almost none performance drop and I suspect that if I put
metadata on the SSD it would not be noticeable at all.

We can see that results are dropping to the bs of 1024B and rising
afterwards. I suspect that we are dealing with two variables with
opposite outcome. Thinp target works better with bigger block sizes as
it has less metadata to work with, but in the other hand snapshots are
then more expensive, because we have to deal with COW rather than simple
write when we are changing the whole block. But 1024 seems quite
reasonable and I also think that putting metadata on SSD (which is
easily doable) we can very well address the first one.

> 
> Did you come to understand the drawbacks of multisnap (physical fragmentation)?

Yes I did, but the fragmentation is problem for any thinly provisioned
storage. I also understand that your snapshot files has also proble with
fragmentation.

> 
> Did it make you change your mind about ext4 snapshots?

>From the first time I was interested in ext4 snapshgots, however as I
came to understand how it works (I must admit not *very* deeply) it all
seems like a hack to solve your problem at the time (several years
ago).

And now, when I see how the new dm-multisnap target works, what features it has,
how it performs (more-or-less) it seems to me that it is a lot more
flexible and desirable way of doing this.

On the other hand your snapshots disrupts a quite calm water of
stable filesystem with a very poor set of features and very limited
possibilities of improvements. Not talking about maintaining burden. But
yes, it might perform a bit better.

So to sum it up I see that dm-multisnap has superset of features your
ext4 snapshots has, in performs well enough, it is more generic solution
for all filesystems, it is also more flexibile, it does not require
intrusive change into stable fs code, and it has better possibilities of
future improvements.

Do even if the final decision does not belong to me, I think that we do
not need this code in ext4. If your snapshots were a *real* filesystem level
snapshots with all the cool features it provides, the situation would be
quite different, however even then I would be thinking if it is worth
it, when we have btrfs here and now, ready to use, and improving every
day to get at enterprise level (it will, hopefully, be a default
filesystem in Fedora 16, which is huge step forward to enterprise
environment).

And here I would very much like to see other ext4 developers opinions,
because they were really quiet on this matter and it is time to reveal
the cards on the table, so ?...


> 
> I am planning to join the ext4 weekly call today and ask if people think that
> we still have open issues with ext4 snapshots, which must be resolved
> before the merge.
> 
> I have 2 questions that should be answered before the merge:
> 1. Should 32bit ext4 move to 48bit snapshot file format after the
> format is implemented for 64bit ext4?
> 2. Should exclude bitmap be allocated only on mkfs time or should it
> also be possible to allocate it with tune2fs?
> Allocating it later will enable snapshots on existing fs, but will
> have sub-optimal on-disk layout.
> 
> If anyone has opinions on these 2 questions, please make them heard here or on
> the call today.
> 
> Thanks,
> Amir.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ext4" in
> the body of a message to majordomo at vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 


