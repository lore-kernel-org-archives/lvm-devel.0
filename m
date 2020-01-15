From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 14 Jan 2020 20:22:35 -0500
Subject: kernel BUG at drivers/md/persistent-data/dm-space-map-disk.c:178
In-Reply-To: <20200114215248.GK41220@gmail.com>
References: <alpine.LRH.2.11.1909251814220.15810@mx.ewheeler.net>
	<alpine.LRH.2.11.1912201829300.26683@mx.ewheeler.net>
	<alpine.LRH.2.11.1912270137420.26683@mx.ewheeler.net>
	<alpine.LRH.2.11.1912271946380.26683@mx.ewheeler.net>
	<20200107103546.asf4tmlfdmk6xsub@reti>
	<20200107104627.plviq37qhok2igt4@reti>
	<20200107122825.qr7o5d6dpwa6kv62@reti>
	<20200114215248.GK41220@gmail.com>
Message-ID: <CAMM=eLfODVMDtGahspZsGsBM5Ty_dt+8idJVTyeudzHZQqsDdA@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Jan 14, 2020 at 4:53 PM Eric Biggers <ebiggers@kernel.org> wrote:
>
> On Tue, Jan 07, 2020 at 12:28:25PM +0000, Joe Thornber wrote:
> > On Tue, Jan 07, 2020 at 10:46:27AM +0000, Joe Thornber wrote:
> > > I'll get a patch to you later today.
> >
> > Eric,
> >
> > Patch below.  I've run it through a bunch of tests in the dm test suite.  But
> > obviously I have never hit your issue.  Will do more testing today.
> >
> > - Joe
> >
> >
> >
> > Author: Joe Thornber <ejt@redhat.com>
> > Date:   Tue Jan 7 11:58:42 2020 +0000
> >
> >     [dm-thin, dm-cache] Fix bug in space-maps.
> >
> >     The space-maps track the reference counts for disk blocks.  There are variants
> >     for tracking metadata blocks, and data blocks.
> >
> >     We implement transactionality by never touching blocks from the previous
> >     transaction, so we can rollback in the event of a crash.
> >
> >     When allocating a new block we need to ensure the block is free (has reference
> >     count of 0) in both the current and previous transaction.  Prior to this patch we
> >     were doing this by searching for a free block in the previous transaction, and
> >     relying on a 'begin' counter to track where the last allocation in the current
> >     transaction was.  This 'begin' field was not being updated in all code paths (eg,
> >     increment of a data block reference count due to breaking sharing of a neighbour
> >     block in the same btree leaf).
> >
> >     This patch keeps the 'begin' field, but now it's just a hint to speed up the search.
> >     Instead we search the current transaction for a free block, and then double check
> >     it's free in the old transaction.  Much simpler.
> >
>
> I happened to notice this patch is on the linux-dm/for-next branch
> (https://git.kernel.org/pub/scm/linux/kernel/git/device-mapper/linux-dm.git/commit/?h=for-next&id=2137c0dcc04b24efb4c38d4b46b7194575718dd5)
> and it has:
>
>         Reported-by: Eric Biggers <ebiggers@google.com>
>
> This is wrong, I didn't report this.  I think you meant to put:
>
>         Reported-by: Eric Wheeler <dm-devel@lists.ewheeler.net>
>
> - Eric (the other one)

Fixed it up, not sure how that happened, sorry about that!



