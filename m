From: Mikulas Patocka <mpatocka@redhat.com>
Date: Mon, 8 Mar 2010 22:18:07 -0500 (EST)
Subject: userspace patches for shared snapshots
In-Reply-To: <20100304132228.GA20534@redhat.com>
References: <Pine.LNX.4.64.1002101858410.15802@hs20-bc2-1.build.redhat.com>
	<20100225221324.GA29946@redhat.com>
	<Pine.LNX.4.64.1002252327100.29287@hs20-bc2-1.build.redhat.com>
	<20100226211702.GA23893@redhat.com> <20100303223740.GA12242@redhat.com>
	<Pine.LNX.4.64.1003040502020.16112@hs20-bc2-1.build.redhat.com>
	<20100304132228.GA20534@redhat.com>
Message-ID: <Pine.LNX.4.64.1003082209210.21624@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> > I went through your kernel patch and uploaded a new version at 
> > http://people.redhat.com/mpatocka/patches/kernel/new-snapshots/r16/ . It 
> > contains fix for this 100% usage. It contains most of your changes (I 
> > rolled back that cycle change).
> 
> OK, I have made further edits that layered ontop of my other changes
> (primarily just making use of __func__ rather than hardcoding the
> function name in ERROR messages).  I'll have a look at your r16 and
> hopefully they'll apply there too.
> 
> As for the 'goto midcycle', why do you want to keep that?  IMO it's
> quite ugly.  What was wrong with what I did?
> 
> @@ -638,15 +641,7 @@ dispatch_write:
>         }
>  
>         i = 0;
> -       goto midcycle;
>         for (; i < DM_MULTISNAP_MAX_CHUNKS_TO_REMAP; i++) {
> -               r = s->store->query_next_remap(s->p, chunk);
> -               if (unlikely(r < 0))
> -                       goto free_err_endio;
> -               if (likely(!r))
> -                       break;
> -
> -midcycle:
>                 s->store->add_next_remap(s->p, &pe->desc[i], &new_chunk);
>                 if (unlikely(dm_multisnap_has_error(s)))
>                         goto free_err_endio;
> @@ -654,6 +649,14 @@ midcycle:
>                 dests[i].bdev = s->snapshot->bdev;
>                 dests[i].sector = chunk_to_sector(s, new_chunk);
>                 dests[i].count = s->chunk_size >> SECTOR_SHIFT;
> +
> +               r = s->store->query_next_remap(s->p, chunk);
> +               if (unlikely(r < 0))
> +                       goto free_err_endio;
> +               if (likely(!r)) {
> +                       i++;
> +                       break;
> +               }
>         }
>  
>         dispatch_kcopyd(s, pe, 0, chunk, bio, dests, i);
> 
> 
> Is it that I made the loop less logically ideal (where ideal is:
> query_next_remap then add_next_remap)?  Problem is you already did the
> first query_next_remap.  Anyway, I'd be very surprised if that goto
> makes it past Alasdair.. but either way its not a big deal to me.
> 
> Mike

The patch causes one more excess call to s->store->query_next_remap (it 
wouldn't matter much).

But more importantly, the patch makes the code harder to understand, not 
easier:

The code should be written to follow the thinking of the programmer. So, 
if the logic is that we first ask for the chunk to remap and then perform 
that remapping --- then asking for the remap should be before performing 
that remap in the source code (your patch reversed that).

In my code, since we asked for the first remap already (before calling 
dm_multisnap_alloc_pending_exception), the first ask inside the cycle is 
skipped with goto. I don't see anything wrong with it.

Just don't follow dummy Dijsktra's rules.

Mikulas


