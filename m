From: Joe Thornber <thornber@redhat.com>
Date: Fri, 27 Sep 2019 09:32:39 +0100
Subject: kernel BUG at drivers/md/persistent-data/dm-space-map-disk.c:178 with scsi_mod.use_blk_mq=y
In-Reply-To: <alpine.LRH.2.11.1909261819300.15810@mx.ewheeler.net>
References: <alpine.LRH.2.11.1909251814220.15810@mx.ewheeler.net>
	<20190925200138.GA20584@redhat.com>
	<alpine.LRH.2.11.1909261819300.15810@mx.ewheeler.net>
Message-ID: <20190927083239.xy6jwbkbektwqu3h@reti>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Eric,

On Thu, Sep 26, 2019 at 06:27:09PM +0000, Eric Wheeler wrote:
> I pvmoved the tmeta to an SSD logical volume (dm-linear) on a non-bcache 
> volume and we got the same trace this morning, so while the tdata still 
> passes through bcache, all meta operations are direct to an SSD. This is 
> still using multi-queue scsi, but dm_mod.use_blk_mq=N.
> 
> Since bcache is no longer involved with metadata operations, and since 
> this appears to be a metadata issue, are there any other reasons to 
> suspect bcache?

Did you recreate the pool, or are you just using the existing pool but with
a different IO path?  If it's the latter then there could still be something
wrong with the metadata, introduced while bcache was in the stack.

Would it be possible to send me a copy of the metadata device please so
I can double check the space maps (I presume you've run thin_check on it)?

[Assuming you're using the existing pool] Another useful experiment would be to 
thump_dump and then thin_restore the metadata, which will create totally fresh
metadata and see if you can still reproduce the issue.

Thanks,

- Joe


