From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 11 Sep 2009 02:51:35 -0400
Subject: Re: rebased snapshot-merge patches
In-Reply-To: <Pine.LNX.4.64.0909081002540.26574@hs20-bc2-1.build.redhat.com>
References: <20090831220834.GA15126@redhat.com>
	<Pine.LNX.4.64.0909081002540.26574@hs20-bc2-1.build.redhat.com>
Message-ID: <20090911065135.GA3210@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Sep 08 2009 at 10:17am -0400,
Mikulas Patocka <mpatocka@redhat.com> wrote:

> Hi
> 
> > The DM snapshot-merge patches are here:
> > http://people.redhat.com/msnitzer/patches/snapshot-merge/kernel/2.6.31/
> > 
> > The LVM2 snapshot-merge patches are here:
> > http://people.redhat.com/msnitzer/patches/snapshot-merge/lvm2/LVM2-2.02.52-cvs/
> > 
> > I threw some real work at snapshot-merge by taking a snap _before_
> > formatting a 100G LV with ext3.  Then merged all the exceptions.  One
> > observation is that the merge process is _quite_ slow in comparison to
> > how long it took to format the LV (with associated snapshot exception
> > copy-out).  Will need to look at this further shortly... it's likely a
> > function of using minimal system resources during the merge via kcopyd;
> > whereas the ext3 format puts excessive pressure on the system's page
> > cache to queue work for mkfs's immediate writeback.
> 
> I thought about this, see the comment:
> /* TODO: use larger I/O size once we verify that kcopyd handles it */
> 
> There was some bug that kcopyd didn't handle larget I/O but it is already 
> fixed, so it is possible to extend it.
> 
> s->store->type->prepare_merge returns the number of chunks that can be 
> linearly copied starting from the returned chunk numbers backward. (but 
> the caller is allowed to copy less, and the caller puts the number of 
> copied chunks to s->store->type->commit_merge)
> 
> I.e. if returned chunk numbers are old_chunk == 10 and new_chunk == 20 and 
> returned value is 3, then chunk 20 can be copied to 10, chunk 19 to 9 and 
> 18 to 8.
> 
> There is a variable, s->merge_write_interlock_n, that is now always one, 
> but can hold larger number --- the number of chunks that is being copied.
> 
> So it can be trivialy extended to copy more chunks at once.
> 
> 
> On the other hand, if the snapshot doesn't contain consecutive chunks (it 
> was created as a result of random writes, not as a result of one big 
> write), larger I/O can't be done and its merging will be slow by design. 
> It could be improved by spawning several concurrent kcopyd jobs, but I 
> wouldn't do it because it would complicate code too much and it would 
> damage interactive performance. (in a desktop or server environment, the 
> user typically cares more about interactive latency than about copy 
> throughput).

Mikulas,

I ran with your suggestion and it works quite well (results below).  It
proved a bit more involved to get working because I needed to:
1) Fix the fact that I was _always_ seeing a return from
   persistent_prepare_merge() that was equal to ps->current_committed
2) Fix areas that needed to properly use s->merge_write_interlock_n
   - assumption of only 1 chunk per dm_kcopyd_copy() was somewhat
     wide-spread

The changes are detailed at the end of this mail.  I still have a "TODO"
that you'll see in the patch that speaks to needing to have
snapshot_merge_process() check all origin chunks via __chunk_is_tracked()
rather than just the one check of the first chunk.  Your feedback here
would be much appreciated.  I'm not completely clear on the intent of
the __chunk_is_tracked() check there and what it now needs to do.

Here are performance results from some mkfs-based testing:

# lvcreate -n testlv -L 32G test
# lvcreate -n testlv_snap -s -L 7G test/testlv

# time mkfs.ext3 /dev/test/testlv
...
real    1m7.827s
user    0m0.116s
sys     0m11.017s

# lvs
  LV          VG   Attr   LSize  Origin Snap%  Move Log Copy%  Convert
  testlv      test owi-a- 32.00G
  testlv_snap test swi-a-  7.00G testlv   9.05

before:
-------
# time lvconvert -M test/testlv_snap
  Merging of volume testlv_snap started.
  ...
  Merge into logical volume testlv finished.
  Logical volume "snapshot1" successfully removed

real    22m33.100s
user    0m0.045s
sys     0m0.711s


after:
------
# time lvconvert -M test/testlv_snap
  Merging of volume testlv_snap started.
  testlv: Merged: 6.4%
  testlv: Merged: 3.5%
  testlv: Merged: 0.9%
  testlv: Merged: 0.0%
  Merge into logical volume testlv finished.
  Logical volume "snapshot1" successfully removed

real    1m0.881s [NOTE: we could be ~15 sec faster than reported]
user    0m0.015s
sys     0m0.560s


So we're now seeing _very_ respectible snapshot-merge performance; but
please review the following patch in case I'm somehow cheating, thanks!

Mike

---
 drivers/md/dm-snap-persistent.c |    6 ++--
 drivers/md/dm-snap.c            |   71 +++++++++++++++++++++++---------------
 2 files changed, 46 insertions(+), 31 deletions(-)

diff --git a/drivers/md/dm-snap-persistent.c b/drivers/md/dm-snap-persistent.c
index 23c3a48..27405a0 100644
--- a/drivers/md/dm-snap-persistent.c
+++ b/drivers/md/dm-snap-persistent.c
@@ -723,9 +723,9 @@ static int persistent_prepare_merge(struct dm_exception_store *store,
 
 	for (i = 1; i < ps->current_committed; i++) {
 		read_exception(ps, ps->current_committed - 1 - i, &de);
-		if (de.old_chunk == *old_chunk - i &&
-		    de.new_chunk == *new_chunk - i)
-			continue;
+		if (de.old_chunk != *old_chunk - i ||
+		    de.new_chunk != *new_chunk - i)
+			break;
 	}
 
 	return i;
diff --git a/drivers/md/dm-snap.c b/drivers/md/dm-snap.c
index c7252b2..98bcbb6 100644
--- a/drivers/md/dm-snap.c
+++ b/drivers/md/dm-snap.c
@@ -653,12 +653,13 @@ static void merge_callback(int read_err, unsigned long write_err,
 
 static void snapshot_merge_process(struct dm_snapshot *s)
 {
-	int r;
+	int r, linear_chunks;
 	chunk_t old_chunk, new_chunk;
 	struct origin *o;
 	chunk_t min_chunksize;
 	int must_wait;
 	struct dm_io_region src, dest;
+	sector_t io_size;
 
 	BUG_ON(!s->merge_running);
 	if (s->merge_shutdown)
@@ -674,34 +675,37 @@ static void snapshot_merge_process(struct dm_snapshot *s)
 		DMERR("target store does not support merging");
 		goto shut;
 	}
-	r = s->store->type->prepare_merge(s->store, &old_chunk, &new_chunk);
-	if (r <= 0) {
-		if (r < 0)
+	linear_chunks = s->store->type->prepare_merge(s->store,
+						      &old_chunk, &new_chunk);
+	if (linear_chunks <= 0) {
+		if (linear_chunks < 0)
 			DMERR("Read error in exception store, "
 			      "shutting down merge");
 		goto shut;
 	}
 
-	/* TODO: use larger I/O size once we verify that kcopyd handles it */
-
+	/*
+	 * Use one (potentially large) I/O to copy all 'linear_chunks'
+	 * from the exception store to the origin
+	 */
+	io_size = linear_chunks * s->store->chunk_size;
 	dest.bdev = s->origin->bdev;
-	dest.sector = chunk_to_sector(s->store, old_chunk);
-	dest.count = min((sector_t)s->store->chunk_size,
-			 get_dev_size(dest.bdev) - dest.sector);
+	dest.sector = chunk_to_sector(s->store, old_chunk + 1 - linear_chunks);
+	dest.count = min(io_size, get_dev_size(dest.bdev) - dest.sector);
 
 	src.bdev = s->cow->bdev;
-	src.sector = chunk_to_sector(s->store, new_chunk);
+	src.sector = chunk_to_sector(s->store, new_chunk + 1 - linear_chunks);
 	src.count = dest.count;
 
 test_again:
-	/* Reallocate other snapshots */
+	/* Reallocate other snapshots; must account for all 'linear_chunks' */
 	down_read(&_origins_lock);
 	o = __lookup_origin(s->origin->bdev);
 	must_wait = 0;
 	min_chunksize = minimum_chunk_size(o);
 	if (min_chunksize) {
 		chunk_t n;
-		for (n = 0; n < s->store->chunk_size; n += min_chunksize) {
+		for (n = 0; n < io_size; n += min_chunksize) {
 			r = __origin_write(&o->snapshots, dest.sector + n,
 					   NULL);
 			if (r == DM_MAPIO_SUBMITTED)
@@ -715,10 +719,12 @@ test_again:
 	}
 
 	down_write(&s->lock);
-	s->merge_write_interlock = old_chunk;
-	s->merge_write_interlock_n = 1;
+	s->merge_write_interlock = old_chunk + 1 - linear_chunks;
+	s->merge_write_interlock_n = linear_chunks;
 	up_write(&s->lock);
 
+	/* TODO: rather than only checking if the first chunk has a conflicting
+	   read; do all 'linear_chunks' need to be checked? */
 	while (__chunk_is_tracked(s, old_chunk))
 		msleep(1);
 
@@ -745,7 +751,7 @@ static inline void release_write_interlock(struct dm_snapshot *s, int err)
 
 static void merge_callback(int read_err, unsigned long write_err, void *context)
 {
-	int r;
+	int r, i;
 	struct dm_snapshot *s = context;
 	struct dm_snap_exception *e;
 
@@ -757,25 +763,34 @@ static void merge_callback(int read_err, unsigned long write_err, void *context)
 		goto shut;
 	}
 
-	r = s->store->type->commit_merge(s->store, 1);
+	r = s->store->type->commit_merge(s->store, s->merge_write_interlock_n);
 	if (r < 0) {
 		DMERR("Write error in exception store, shutting down merge");
 		goto shut;
 	}
 
 	down_write(&s->lock);
-	e = lookup_exception(&s->complete, s->merge_write_interlock);
-	if (!e) {
-		DMERR("exception for block %llu is on disk but not in memory",
-		      (unsigned long long)s->merge_write_interlock);
-		up_write(&s->lock);
-		goto shut;
-	}
-	if (dm_consecutive_chunk_count(e)) {
-		dm_consecutive_chunk_count_dec(e);
-	} else {
-		remove_exception(e);
-		free_exception(e);
+	/*
+	 * Must process chunks (and associated exceptions) in reverse
+	 * so that dm_consecutive_chunk_count_dec() accounting works
+	 */
+	for (i = s->merge_write_interlock_n - 1; i >= 0; i--) {
+		e = lookup_exception(&s->complete,
+				     s->merge_write_interlock + i);
+		if (!e) {
+			DMERR("exception for block %llu is on "
+			      "disk but not in memory",
+			      (unsigned long long)
+			      s->merge_write_interlock + i);
+			up_write(&s->lock);
+			goto shut;
+		}
+		if (dm_consecutive_chunk_count(e)) {
+			dm_consecutive_chunk_count_dec(e);
+		} else {
+			remove_exception(e);
+			free_exception(e);
+		}
 	}
 	release_write_interlock(s, 0);
 


