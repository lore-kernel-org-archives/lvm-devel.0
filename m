From: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Date: Fri, 20 May 2022 22:02:56 +0530
Subject: Reg cache target
In-Reply-To: <CAFe+wq1P-z94VTvfNnvCmC9f1KY4MEvkp5wO6MMVb-_1C86Grg@mail.gmail.com>
References: <CAFe+wq1P-z94VTvfNnvCmC9f1KY4MEvkp5wO6MMVb-_1C86Grg@mail.gmail.com>
Message-ID: <CAFe+wq3PSgfqfsR7Y5f7sntg-SAGf6cy622TtQvRAk3A2uG2KQ@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, May 20, 2022 at 9:45 AM Lakshmi Narasimhan Sundararajan <
lsundararajan@purestorage.com> wrote:

> Hi Team!
> A very good day to you.
>
> I have a lvm cache setup with 14TB cache on a origin device that is 110TB.
> The cache was configured with 1MB cache blocks, and 100MB migration
> bandwidth/smq policy/writeback. This setup has a large memory and high cpu
> count, so we relaxed the allocation/cache_pool_max_chunks to
> accommodate this. The setup was stable until the cache got full of dirty
> blocks.
> Under some cases, cache target seems to block submitted IO and only do
> migration and all IO that's incoming seems to be very slow.
> Does the cache target have a scenario where this may happen when the cache
> is full of dirty blocks?
>
> It looks like the migration bandwidth was underprovisioned as the cache
> got full of dirty blocks. Now I am trying to flush the cache and bring down
> the dirty block count on a live setup. Below are some options I tried and
> would like feedback to know what's the best way to bring down the dirty
> blocks without taking down the node.
>
>
> 1/ increase migration threshold to a larger value 1600 MB.
> 2/ change cache policy to cleaner
>
> Do these change take effect on the fly?
> I do not seem to see the dirty block count drop significantly.
>
> Can you please point me how to bring down the dirty block count
> immediately on a live setup?
>

More findings from the scenario.
Cache is currently configured at cleaner policy, 1600MBps migration
bandwidth, writeback mode.

Now in this state, it looks like the cache is still accumulating newer
writes within. Can this be confirmed?
Q: Does writeback cache still accumulate newer writes while in cleaner
policy? Does it only accumulate write overwrites for existing block in
cache?
Or does it only accumulate write overwrites on dirty block only in cache?

And if yes, does reconfiguring cache to writethrough mode make sense with
cleaner policy, to allow continual IO flush and maintaining data
consistency for those in-flight dirty blocks?

Q: It looks like when writethrough gets configured with dirty blocks, the
cli waits until flush gets complete before applying writethrough.
In my situation, this may take a very long time to drain. How can I ensure
cache does not accumulate any newer writes but only drain all dirty data.

Please help me understand behavior in the above situation.

Regards
LN



>
> Thanks for your help.
> Regards
> LN
>
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20220520/91192f03/attachment.htm>
