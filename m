From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 30 Sep 2014 16:13:19 -0400
Subject: dm-thinp feature request: skip allocation on writes of all zeroes
In-Reply-To: <alpine.DEB.2.00.1409301121470.26721@ware.dreamhost.com>
References: <alpine.DEB.2.00.1409301121470.26721@ware.dreamhost.com>
Message-ID: <20140930201319.GA11339@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Sep 30 2014 at  2:38pm -0400,
Eric Wheeler <lvm-dev@lists.ewheeler.net> wrote:

> Hello all,
> 
> We have been testing dm-thinp for the last couple years and it has
> been stable for the most part.
> 
> I have always wondered, does LVM ignore writes with blocks of all
> zeroes when the destination address is unallocated? From experience,
> it does not appear that this is so (or I cannot find the config
> option). This would reduce IOs, particularily when importing VM disk
> images from other sources. Currently, we must import, allocate lots
> of zeroes, then fstrim after the fact.

We don't inspect the data being written to infer WRITE SAME-like action.
And in your example fstrim wouldn't do anything for you.  The zeroed
data in the image is still valid isn't it?  fstrim is only useful to
reclaim blocks that are no longer used.

> I have paged through the dm-thinp code, but I am not quite certain
> what the best place to add this logic would be such that the IO is
> completed and the allocation is not performed.
> 
> I would be happy to work on a patch, but I need a little bit of direction:
> 
> What would it take to add this as a feature option to the dmsetup
> table string?
> 
> Where in the dm-thinp code would this best be addressed?

Honestly, you'd be better served to use deduplication.  A dm-dedup
target has been in development (and I'm reviewing it), see:
http://git.kernel.org/cgit/linux/kernel/git/snitzer/linux.git/log/?h=dm-dedup

It is very much in-development, but it gives you an idea.  You could
pair a dedup target with dm-thinp in a stacked configuration to achieve
your goals.


