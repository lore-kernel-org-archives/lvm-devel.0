From: Eric Wheeler <dm-devel@lists.ewheeler.net>
Date: Fri, 27 Sep 2019 18:45:33 +0000 (UTC)
Subject: kernel BUG at drivers/md/persistent-data/dm-space-map-disk.c:178 with scsi_mod.use_blk_mq=y
In-Reply-To: <20190927083239.xy6jwbkbektwqu3h@reti>
References: <alpine.LRH.2.11.1909251814220.15810@mx.ewheeler.net>
	<20190925200138.GA20584@redhat.com>
	<alpine.LRH.2.11.1909261819300.15810@mx.ewheeler.net>
	<20190927083239.xy6jwbkbektwqu3h@reti>
Message-ID: <alpine.LRH.2.11.1909271819450.20939@mx.ewheeler.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 27 Sep 2019, Joe Thornber wrote:

> Hi Eric,
> 
> On Thu, Sep 26, 2019 at 06:27:09PM +0000, Eric Wheeler wrote:
> > I pvmoved the tmeta to an SSD logical volume (dm-linear) on a non-bcache 
> > volume and we got the same trace this morning, so while the tdata still 
> > passes through bcache, all meta operations are direct to an SSD. This is 
> > still using multi-queue scsi, but dm_mod.use_blk_mq=N.
> > 
> > Since bcache is no longer involved with metadata operations, and since 
> > this appears to be a metadata issue, are there any other reasons to 
> > suspect bcache?
> 
> Did you recreate the pool, or are you just using the existing pool but with
> a different IO path?  If it's the latter then there could still be something
> wrong with the metadata, introduced while bcache was in the stack.

We did not create the pool after the initial problem, though the pool was 
new just before the problem occurred. 
 
> Would it be possible to send me a copy of the metadata device please so
> I can double check the space maps (I presume you've run thin_check on it)?

~]# /usr/local/bin/thin_check /dev/mapper/data-data--pool_tmeta 
examining superblock
TRANSACTION_ID=2347
METADATA_FREE_BLOCKS=4145151
examining devices tree
examining mapping tree
checking space map counts

~]# echo $?
0

~]# /usr/local/bin/thin_check -V
0.8.5

> [Assuming you're using the existing pool] Another useful experiment would be to 
> thump_dump and then thin_restore the metadata, which will create totally fresh
> metadata and see if you can still reproduce the issue.

It didn't lockup last night, but I'll keep working to reproduce the 
problem and let you know what we find.

Mike said it could be a race:

> The stack shows the call to sm_disk_new_block() is due to
> dm_pool_alloc_data_block().
> 
> sm_disk_new_block()'s BUG_ON(ev != SM_ALLOC) indicates that somehow it is
> getting called without the passed 'ev' being set to SM_ALLOC.  Only
> drivers/md/persistent-dat/dm-space-map-common.c:sm_ll_mutate() sets
> SM_ALLOC. sm_disk_new_block() is indirectly calling sm_ll_mutate()
> 
> sm_ll_mutate() will only return 0 if ll->save_ie() does, the ll_disk *ll
> should be ll_disk, and so disk_ll_save_ie()'s call to dm_btree_insert()
> returns 0 -- which simply means success.  And on success
> sm_disk_new_block() assumes ev was set to SM_ALLOC (by sm_ll_mutate).
> 
> sm_ll_mutate() decided to _not_ set SM_ALLOC because either:
> 1) ref_count wasn't set
> or
> 2) old was identified
> 
> So all said: somehow a new data block was found to already be in use.
> _WHY_ that is the case isn't clear from this stack...
>
> But it does speak to the possibility of data block allocation racing
> with other operations to the same block.  Which implies missing locking.

Would a spinlock on the block solve the issue?

Where might such a spinlock be added?


--
Eric Wheeler


> 
> Thanks,
> 
> - Joe
> 


