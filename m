From: Mikulas Patocka <mpatocka@redhat.com>
Date: Tue, 8 Sep 2009 10:17:45 -0400 (EDT)
Subject: Re: [dm-devel] rebased snapshot-merge patches
In-Reply-To: <20090831220834.GA15126@redhat.com>
References: <20090831220834.GA15126@redhat.com>
Message-ID: <Pine.LNX.4.64.0909081002540.26574@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

> The DM snapshot-merge patches are here:
> http://people.redhat.com/msnitzer/patches/snapshot-merge/kernel/2.6.31/
> 
> The LVM2 snapshot-merge patches are here:
> http://people.redhat.com/msnitzer/patches/snapshot-merge/lvm2/LVM2-2.02.52-cvs/
> 
> I threw some real work at snapshot-merge by taking a snap _before_
> formatting a 100G LV with ext3.  Then merged all the exceptions.  One
> observation is that the merge process is _quite_ slow in comparison to
> how long it took to format the LV (with associated snapshot exception
> copy-out).  Will need to look at this further shortly... it's likely a
> function of using minimal system resources during the merge via kcopyd;
> whereas the ext3 format puts excessive pressure on the system's page
> cache to queue work for mkfs's immediate writeback.

I thought about this, see the comment:
/* TODO: use larger I/O size once we verify that kcopyd handles it */

There was some bug that kcopyd didn't handle larget I/O but it is already 
fixed, so it is possible to extend it.

s->store->type->prepare_merge returns the number of chunks that can be 
linearly copied starting from the returned chunk numbers backward. (but 
the caller is allowed to copy less, and the caller puts the number of 
copied chunks to s->store->type->commit_merge)

I.e. if returned chunk numbers are old_chunk == 10 and new_chunk == 20 and 
returned value is 3, then chunk 20 can be copied to 10, chunk 19 to 9 and 
18 to 8.

There is a variable, s->merge_write_interlock_n, that is now always one, 
but can hold larger number --- the number of chunks that is being copied.

So it can be trivialy extended to copy more chunks at once.


On the other hand, if the snapshot doesn't contain consecutive chunks (it 
was created as a result of random writes, not as a result of one big 
write), larger I/O can't be done and its merging will be slow by design. 
It could be improved by spawning several concurrent kcopyd jobs, but I 
wouldn't do it because it would complicate code too much and it would 
damage interactive performance. (in a desktop or server environment, the 
user typically cares more about interactive latency than about copy 
throughput).

Mikulas


