From: Joe Thornber <thornber@redhat.com>
Date: Tue, 7 Jan 2020 10:35:46 +0000
Subject: [dm-devel] kernel BUG at drivers/md/persistent-data/dm-space-map-disk.c:178
In-Reply-To: <alpine.LRH.2.11.1912271946380.26683@mx.ewheeler.net>
References: <alpine.LRH.2.11.1909251814220.15810@mx.ewheeler.net>
	<alpine.LRH.2.11.1912201829300.26683@mx.ewheeler.net>
	<alpine.LRH.2.11.1912270137420.26683@mx.ewheeler.net>
	<alpine.LRH.2.11.1912271946380.26683@mx.ewheeler.net>
Message-ID: <20200107103546.asf4tmlfdmk6xsub@reti>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sat, Dec 28, 2019 at 02:13:07AM +0000, Eric Wheeler wrote:
> On Fri, 27 Dec 2019, Eric Wheeler wrote:

> > Just hit the bug again without mq-scsi (scsi_mod.use_blk_mq=n), all other 
> > times MQ has been turned on. 
> > 
> > I'm trying the -ENOSPC hack which will flag the pool as being out of space 
> > so I can recover more gracefully than a BUG_ON. Here's a first-draft 
> > patch, maybe the spinlock will even prevent the issue.
> > 
> > Compile tested, I'll try on a real system tomorrow.
> > 
> > Comments welcome:

Both sm_ll_find_free_block() and sm_ll_inc() can trigger synchronous IO.  So you
absolutely cannot use a spin lock.

dm_pool_alloc_data_block() holds a big rw semaphore which should prevent anything
else trying to allocate at the same time.

- Joe


