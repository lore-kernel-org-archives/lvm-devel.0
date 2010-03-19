From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 19 Mar 2010 15:39:08 -0400
Subject: lv-shared
In-Reply-To: <20100315220136.GA3461@redhat.com>
References: <Pine.LNX.4.64.1003151453350.4733@hs20-bc2-1.build.redhat.com>
	<20100315192925.GA29389@redhat.com>
	<Pine.LNX.4.64.1003151600470.17728@hs20-bc2-1.build.redhat.com>
	<20100315220136.GA3461@redhat.com>
Message-ID: <20100319193908.GB7345@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Mar 15 2010 at  6:01pm -0400,
Mike Snitzer <snitzer@redhat.com> wrote:

> On Mon, Mar 15 2010 at  4:06pm -0400,
> Mikulas Patocka <mpatocka@redhat.com> wrote:
> 
> > On Mon, 15 Mar 2010, Mike Snitzer wrote:
> > 
> > > On Mon, Mar 15 2010 at  3:00pm -0400,
> > > Mikulas Patocka <mpatocka@redhat.com> wrote:
> > > 
> > > > Hi
> > > > 
> > > > Why did you hide the "lv-shared" volume? With this hidden, the size and 
> > > > percentage can't be seen.
> > > 
> > > You can still see it with: lvs -a
> > > 
> > > I'll have to revisit why I made it hidden (aside from the fact that the
> > > associated DM device is also hidden).  There was some subtle reason that
> > > had to do with the refactoring of associations when I eliminated the
> > > distinct ->shared_snapshot pointer (otherwise the vg_validate() method
> > > would fail).
> > 
> > I know it can be seen with lvs -a, but I think it's inconvenient for the 
> > admin:
> > - the admin won't see that there is a shared store taking up space
> > - the admin won't see that the origin is a shared snapshot, he sees 'o', 
> > but nothing that refers to that 'o'
> > - the percentage usage of the shared snapshot is hidden
> > 
> > I think this information is important and should be displayed with plain 
> > "lvs" command without any flags. (for example, the percentage usage is 
> > critical, because it can overflow) --- so "lv-shared" shouldn't be hidden.
> 
> Sure, not a problem.
> 
> I've updated the relevant patch, see:
> http://people.redhat.com/msnitzer/patches/multisnap/lvm2/LVM2-2.02.62/lvm-shared-eliminate-shared_snapshot-in-lv.patch
> 
> The lib/metadata/metadata.c:snapshot_count() changes in this updated
> patch address the vg_validate() issue I was seeing.  The -shared cow was
> considered to be a normal "snapshot"; as such the vg_validate() checks
> failed.

Mikulas,

I've cleaned up my patches that layer on your a bit, and updated to
2.02.63:
http://people.redhat.com/msnitzer/patches/multisnap/lvm2/LVM2-2.02.63/

This patch saw some changes becuase I moved some functions around:
http://people.redhat.com/msnitzer/patches/multisnap/lvm2/LVM2-2.02.63/lvm-shared-additional-wrappers.patch

One fix associated with the changes is detailed at the end of the
following patch's header:
http://people.redhat.com/msnitzer/patches/multisnap/lvm2/LVM2-2.02.63/lvm-shared-eliminate-shared_snapshot-in-lv.patch

And I implemented the ACCESS_HIDDEN_LV flag we talked about with this
patch:
http://people.redhat.com/msnitzer/patches/multisnap/lvm2/LVM2-2.02.63/lvm-shared-add-ACCESS_HIDDEN_LV-flag.patch

With the result being:
# lvs
  LV               VG   Attr   LSize Origin  Snap%  Move Log Copy%  Convert
  testlv1          test owi-a- 4.00g                                       
  [testlv1-shared] test swi--- 1.00g testlv1   0.01                        
  testlv1_snap     test swi-a- 4.00g testlv1                

Mike


