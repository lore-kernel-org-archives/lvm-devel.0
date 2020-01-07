From: Joe Thornber <thornber@redhat.com>
Date: Tue, 7 Jan 2020 10:46:27 +0000
Subject: [dm-devel] kernel BUG at drivers/md/persistent-data/dm-space-map-disk.c:178
In-Reply-To: <20200107103546.asf4tmlfdmk6xsub@reti>
References: <alpine.LRH.2.11.1909251814220.15810@mx.ewheeler.net>
	<alpine.LRH.2.11.1912201829300.26683@mx.ewheeler.net>
	<alpine.LRH.2.11.1912270137420.26683@mx.ewheeler.net>
	<alpine.LRH.2.11.1912271946380.26683@mx.ewheeler.net>
	<20200107103546.asf4tmlfdmk6xsub@reti>
Message-ID: <20200107104627.plviq37qhok2igt4@reti>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Jan 07, 2020 at 10:35:46AM +0000, Joe Thornber wrote:
> On Sat, Dec 28, 2019 at 02:13:07AM +0000, Eric Wheeler wrote:
> > On Fri, 27 Dec 2019, Eric Wheeler wrote:
> 
> > > Just hit the bug again without mq-scsi (scsi_mod.use_blk_mq=n), all other 
> > > times MQ has been turned on. 
> > > 
> > > I'm trying the -ENOSPC hack which will flag the pool as being out of space 
> > > so I can recover more gracefully than a BUG_ON. Here's a first-draft 
> > > patch, maybe the spinlock will even prevent the issue.
> > > 
> > > Compile tested, I'll try on a real system tomorrow.
> > > 
> > > Comments welcome:
> 
> Both sm_ll_find_free_block() and sm_ll_inc() can trigger synchronous IO.  So you
> absolutely cannot use a spin lock.
> 
> dm_pool_alloc_data_block() holds a big rw semaphore which should prevent anything
> else trying to allocate at the same time.

I suspect the problem is to do with the way we search for the new block in the 
space map for the previous transaction (sm->old_ll), and then increment in the current
transaction (sm->ll).

We keep old_ll around so we can ensure we never (re) allocate a block that's used in
the previous transaction.  This gives us our crash resistance, since if anything goes
wrong we effectively rollback to the previous transaction.

What I think we should be doing is running find_free on the old_ll, then double checking
it's not actually used in the current transaction.  ATM we're relying on smd->begin being
set properly everywhere, and I suspect this isn't the case.  A quick look shows sm_disk_inc_block()
doesn't adjust it.  sm_disk_inc_block() can be called when breaking sharing of a neighbouring entry
in a leaf btree node ... and we know you use snapshots very heavily.

I'll get a patch to you later today.

- Joe


