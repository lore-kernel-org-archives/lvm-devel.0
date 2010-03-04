From: Mike Snitzer <snitzer@redhat.com>
Date: Thu, 4 Mar 2010 08:22:28 -0500
Subject: userspace patches for shared snapshots
In-Reply-To: <Pine.LNX.4.64.1003040502020.16112@hs20-bc2-1.build.redhat.com>
References: <Pine.LNX.4.64.1002101858410.15802@hs20-bc2-1.build.redhat.com>
	<20100225221324.GA29946@redhat.com>
	<Pine.LNX.4.64.1002252327100.29287@hs20-bc2-1.build.redhat.com>
	<20100226211702.GA23893@redhat.com>
	<20100303223740.GA12242@redhat.com>
	<Pine.LNX.4.64.1003040502020.16112@hs20-bc2-1.build.redhat.com>
Message-ID: <20100304132228.GA20534@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Mar 04 2010 at  5:11am -0500,
Mikulas Patocka <mpatocka@redhat.com> wrote:

> 
> 
> On Wed, 3 Mar 2010, Mike Snitzer wrote:
> 
> > On Fri, Feb 26 2010 at  4:17pm -0500,
> > Mike Snitzer <snitzer@redhat.com> wrote:
> > 
> > > On Thu, Feb 25 2010 at 11:52pm -0500,
> > > Mikulas Patocka <mpatocka@redhat.com> wrote:
> > 
> > > > > # lvs
> > > > >   LV             VG   Attr   LSize Origin  Snap%  Move Log Copy%  Convert
> > > > >   testlv1        test owi-a- 4.00g                                       
> > > > >   testlv1-shared test swi--- 1.00g testlv1 100.00                        
> > > > > 
> > > > > NOTE: strikes me as odd that the testlv1-shared Snap% is 100%.  I've
> > > > > fixed the same with the snapshot-merge code before; will dig deeper in a
> > > > > bit.
> > > > 
> > > > This is actually bug in the kernel, it starts with the smallest possible 
> > > > size and extends the internal data structures when the first operation is 
> > > > performed. So, if you ask for status without performing any operation, it 
> > > > reports 100%.
> > > > 
> > > > Thanks for finding it, I overlooked it. I'l fix that.
> > > 
> > > Sure, I'll be interested to see your fix.  I'm not clear on what you're
> > > referring to.
> 
> Each time someone locks the exception store, it checks the device size. If 
> the size of the device has grown, the exception store extends itself.
> 
> So the problem was, that if you queried the percentage the first time 
> before any locking operation, it wasn't extended yet and it reported 100%. 
> I fixed it by adding a test for extension just after initialization.
> 
> > BTW, the patches I posted earlier change this behaviour, in particular
> > this patch:
> > http://people.redhat.com/msnitzer/patches/multisnap/lvm2/LVM2-2.02.62/lvm-shared-eliminate-shared_snapshot-in-lv.patch
> > 
> > Now the -shared store is hidden:
> > 
> > # lvs
> >   LV      VG   Attr   LSize Origin Snap%  Move Log Copy%  Convert
> >   testlv1 test owi-a- 4.00g                                      
> > 
> > # lvs -a
> >   LV               VG   Attr   LSize Origin  Snap%  Move Log Copy%  Convert
> >   testlv1          test owi-a- 4.00g                                       
> >   [testlv1-shared] test swi--- 1.00g testlv1   0.00                        
> > 
> > You'll also note that Snap% is no longer 100%
> 
> No, it didn't fix that. See above.

Interesting, yeap you're right.

> I went through your kernel patch and uploaded a new version at 
> http://people.redhat.com/mpatocka/patches/kernel/new-snapshots/r16/ . It 
> contains fix for this 100% usage. It contains most of your changes (I 
> rolled back that cycle change).

OK, I have made further edits that layered ontop of my other changes
(primarily just making use of __func__ rather than hardcoding the
function name in ERROR messages).  I'll have a look at your r16 and
hopefully they'll apply there too.

As for the 'goto midcycle', why do you want to keep that?  IMO it's
quite ugly.  What was wrong with what I did?

@@ -638,15 +641,7 @@ dispatch_write:
        }
 
        i = 0;
-       goto midcycle;
        for (; i < DM_MULTISNAP_MAX_CHUNKS_TO_REMAP; i++) {
-               r = s->store->query_next_remap(s->p, chunk);
-               if (unlikely(r < 0))
-                       goto free_err_endio;
-               if (likely(!r))
-                       break;
-
-midcycle:
                s->store->add_next_remap(s->p, &pe->desc[i], &new_chunk);
                if (unlikely(dm_multisnap_has_error(s)))
                        goto free_err_endio;
@@ -654,6 +649,14 @@ midcycle:
                dests[i].bdev = s->snapshot->bdev;
                dests[i].sector = chunk_to_sector(s, new_chunk);
                dests[i].count = s->chunk_size >> SECTOR_SHIFT;
+
+               r = s->store->query_next_remap(s->p, chunk);
+               if (unlikely(r < 0))
+                       goto free_err_endio;
+               if (likely(!r)) {
+                       i++;
+                       break;
+               }
        }
 
        dispatch_kcopyd(s, pe, 0, chunk, bio, dests, i);


Is it that I made the loop less logically ideal (where ideal is:
query_next_remap then add_next_remap)?  Problem is you already did the
first query_next_remap.  Anyway, I'd be very surprised if that goto
makes it past Alasdair.. but either way its not a big deal to me.

Mike


