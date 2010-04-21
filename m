From: Mike Snitzer <snitzer@redhat.com>
Date: Wed, 21 Apr 2010 02:35:04 -0400
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM libdm/libdm-de ...
In-Reply-To: <20100419232509.GG4828@agk-dp.fab.redhat.com>
References: <20100407200443.26841.qmail@sourceware.org>
	<20100419223820.GA11273@redhat.com>
	<20100419232509.GG4828@agk-dp.fab.redhat.com>
Message-ID: <20100421063504.GA10083@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Apr 19 2010 at  7:25pm -0400,
Alasdair G Kergon <agk@redhat.com> wrote:

> On Mon, Apr 19, 2010 at 06:38:20PM -0400, Mike Snitzer wrote:
> > On Wed, Apr 07 2010 at  4:04pm -0400,
> > agk at sourceware.org <agk@sourceware.org> wrote:
>  
> > >  		/* Refresh open_count */
> > >  		if (!_info_by_dev(dinfo->major, dinfo->minor, 1, &info) ||
> > > -		    !info.exists || info.open_count)
> > > +		    !info.exists)
> > >  			continue;
> > >  
> > > +		if (info.open_count) {
> 
> > It would appear that the non-zero open_count associated with the -real
> > device is stale (during lvremove's dm_tree_deactivate_children).  
> 
> Shouldn't be - it follows a 'refresh'.

You're right, it's not stale at all.

So the 2 issues I've found:
1) removal of snapshot with pending onactivate merge doesn't cleanup
   snapshot like normal (normal being "case A" below) -- it does "case B"
2) completely tangential but: when a merge is active the merging
   snapshot LV is accessible (by user with lvremove); so removing the
   merging snapshot is currently allowed (stops merge, deletes
   snapshot); should it be allowed?

The following is more of a "note to self" that I've collected while
looking into this.. but feel free to review it ("case B" below
elaborates on why the t-snapshot-merge.sh test was failing).

"case B" preloads the origin when cleaning up for a merge (I believe
this explains why we attempt to cleanup -real early).  See commit
eaef92b02f968856 -- the vg_remove_snapshot changes in particular. 

I've yet to arrive at a fix for the attempt to cleanup -real too early
in case B (which triggers the _dm_tree_deactivate_children: r = 0); it
involves metadata/deptree associations not reflecting the kernel
(because of pending onactivate merge metadata) -- so vg_remove_snapshot
preloads origin.


A)
Here is a normal snapshot deactivate/remove:

# lvremove -f test/testlv1_snap
  _dm_tree_deactivate_children: deactivate test-testlv1_snap (253:3) level=0, open_count=0
  _dm_tree_deactivate_children: deactivate test-testlv1-real (253:4) level=1, open_count=1
  _dm_tree_deactivate_children: deactivate test-testlv1_snap-cow (253:5) level=1, open_count=0
  _dm_tree_deactivate_children: deactivate test-testlv1-real (253:4) level=0, open_count=0
  Logical volume "testlv1_snap" successfully removed

NOTE that the -real's level changes from 1 to 0 (this is because
snapshot-origin is still active).

Also NOTE that -real's open_count=1 above because test-testlv1 (still
using snapshot-origin) doesn't get reloaded to use the linear target
until the end (origin is _not_ preloaded by vg_remove_snapshot in this
case).


B)
Here is the sequence for the t-snapshot-merge.sh case that returns 0
from _dm_tree_deactivate_children (though I commented out the r = 0).
I refresh'd while the origin device was still mounted then lvremove; so
it has snapshot-merge metadata but snapshot is active in the kernel:

+ dmsetup table
LVMTEST9035vg-LV1: 0 98304 snapshot-origin 253:6
LVMTEST9035vg-LV1_snap: 0 98304 snapshot 253:6 253:7 P 8
LVMTEST9035vg-LV1_snap-cow: 0 16384 linear 253:3 98688
LVMTEST9035vg-LV1-real: 0 98304 linear 253:3 384

NOTE: first thing the following lvremove does is reload
LVMTEST9035vg-LV1 to use linear target, prior to reload
LVMTEST9035vg-LV1's only dep was -real.  But because of
snapshot-merge metadata LVMTEST9035vg-LV1-real has level=0 (because of
preload).

+ lvremove -f LVMTEST9035vg/LV1_snap
  _dm_tree_deactivate_children: deactivate LVMTEST9035vg-LV1-real (253:6) level=0, open_count=1
  Unable to deactivate open LVMTEST9035vg-LV1-real (253:6)
  _dm_tree_deactivate_children: deactivate LVMTEST9035vg-LV1_snap (253:5) level=0, open_count=0
  _dm_tree_deactivate_children: deactivate LVMTEST9035vg-LV1-real (253:6) level=1, open_count=0
  _dm_tree_deactivate_children: deactivate LVMTEST9035vg-LV1_snap-cow (253:7) level=1, open_count=0
  Logical volume "LV1_snap" successfully removed

NOTE that the -real's level changes from 0 to 1.


