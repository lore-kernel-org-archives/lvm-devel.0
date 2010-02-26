From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 26 Feb 2010 16:17:02 -0500
Subject: userspace patches for shared snapshots
In-Reply-To: <Pine.LNX.4.64.1002252327100.29287@hs20-bc2-1.build.redhat.com>
References: <Pine.LNX.4.64.1002101858410.15802@hs20-bc2-1.build.redhat.com>
	<20100225221324.GA29946@redhat.com>
	<Pine.LNX.4.64.1002252327100.29287@hs20-bc2-1.build.redhat.com>
Message-ID: <20100226211702.GA23893@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Feb 25 2010 at 11:52pm -0500,
Mikulas Patocka <mpatocka@redhat.com> wrote:

> Hi
> 
> On Thu, 25 Feb 2010, Mike Snitzer wrote:
> 
> > On Wed, Feb 10 2010 at  6:59pm -0500,
> > Mikulas Patocka <mpatocka@redhat.com> wrote:
> > 
> > > Hi
> > > 
> > > I uploaded the current version of userspace shared snapshots here:
> > > http://people.redhat.com/mpatocka/patches/userspace/new-snapshots/lvm-2.02.60/
> > 
> > I've refreshed these patches to apply against the latest upstream lvm2:
> > http://people.redhat.com/msnitzer/patches/multisnap/lvm2/LVM2-2.02.62/
> > 
> > Seems these lvm2 patches can be cleaned up a bit to use wrappers much
> > like was done for the snapshot-merge support:
> > http://sources.redhat.com/git/gitweb.cgi?p=lvm2.git;a=commit;h=cad03afc54f565c
> 
> Yes. I did it at some places, but you can find more where it could be 
> done.

Yeap, my recent patch posting adds find_shared_cow() and
lv_is_shared_cow().  This helps clean up the code to be more clear.
 
> > And I'm wondering whether we _really_ need a distinct 'shared_snapshot'
> > in 'struct logical_volume'.  I was able to remove 'merging_snapshot'
> > from the lvm2 snapshot-merge support:
> > http://sources.redhat.com/git/gitweb.cgi?p=lvm2.git;a=commit;h=fa684a97dae2e36
> 
> We don't need "shared_snapshot" entry, the pointer could be definitely 
> stuffed into some existing structure entry, but I wouldn't do it.
> 
> If you use one structure entry for multiple things, you are increasing the 
> possibility of bugs (you write it as one thing and read it as another 
> thing).
> 
> In my opinion, it is not worth trying to save 8 bytes per logical volume 
> at the cost of increasing bug possibilities.

I was of the same opinion when Alasdair suggested I do the same
(removing 'merging_snapshot').  But it actually doesn't pose a risk once
you have proper wrappers in place.  Do you agree? (see my patch#3 in my
recent patch series).

> > # lvs
> >   LV             VG   Attr   LSize Origin  Snap%  Move Log Copy%  Convert
> >   testlv1        test owi-a- 4.00g                                       
> >   testlv1-shared test swi--- 1.00g testlv1 100.00                        
> > 
> > NOTE: strikes me as odd that the testlv1-shared Snap% is 100%.  I've
> > fixed the same with the snapshot-merge code before; will dig deeper in a
> > bit.
> 
> This is actually bug in the kernel, it starts with the smallest possible 
> size and extends the internal data structures when the first operation is 
> performed. So, if you ask for status without performing any operation, it 
> reports 100%.
> 
> Thanks for finding it, I overlooked it. I'l fix that.

Sure, I'll be interested to see your fix.  I'm not clear on what you're
referring to.

> > # lvcreate -L 128M -s -n testlv1_snap test/testlv1
> >   Logical volume "testlv1_snap" created
> 
> That "-L" argument is ignored because it is a shared store. If you want to 
> extend the shared store, extend "testlv1-shared" (you can't shrink it).

OK, but if we can extend and reduce the virtual size (as you shared
below) shouldn't we honor the requested size (-L) as the virtual
snapshot's size?

> > # dmsetup ls
> > test-testlv1    (253, 0)
> > test-testlv1_snap       (253, 3)
> > test-testlv1-cow        (253, 2)
> > test-testlv1-real       (253, 1)
> > 
> > # lvs
> >   LV             VG   Attr   LSize Origin  Snap%  Move Log Copy%  Convert
> >   testlv1        test owi-a- 4.00g                                       
> >   testlv1-shared test swi--- 1.00g testlv1   0.01                        
> >   testlv1_snap   test swi-a- 4.00g testlv1                               
> > 
> > NOTE: how can we claim the snapshot is 4G when the shared snap store is
> > only 1G?
> 
> 4G is the virtual size of the snapshot. It is the same as the origin size 
> (but it can be shrunk or extended). The physical size of the shared store 
> is reported testlv1-shared. The physical size of individual snapshots is 
> not reported because the store is shared.

Mike


