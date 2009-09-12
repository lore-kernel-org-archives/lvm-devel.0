From: Mikulas Patocka <mpatocka@redhat.com>
Date: Sat, 12 Sep 2009 03:54:36 -0400 (EDT)
Subject: Re: rebased snapshot-merge patches
In-Reply-To: <20090912065608.GA1864@redhat.com>
References: <20090831220834.GA15126@redhat.com>
	<Pine.LNX.4.64.0909081002540.26574@hs20-bc2-1.build.redhat.com>
	<20090911065135.GA3210@redhat.com> <20090912065608.GA1864@redhat.com>
Message-ID: <Pine.LNX.4.64.0909120350300.22286@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sat, 12 Sep 2009, Mike Snitzer wrote:

> On Fri, Sep 11 2009 at  2:51am -0400,
> Mike Snitzer <snitzer@redhat.com> wrote:
> 
> > Mikulas,
> > 
> > I ran with your suggestion and it works quite well (results below).
> ...
> > The changes are detailed at the end of this mail.  I still have a "TODO"
> > that you'll see in the patch that speaks to needing to have
> > snapshot_merge_process() check all origin chunks via __chunk_is_tracked()
> > rather than just the one check of the first chunk.  Your feedback here
> > would be much appreciated.  I'm not completely clear on the intent of
> > the __chunk_is_tracked() check there and what it now needs to do.
> 
> I believe I've sorted this out.  The TODO should've read something like:
> snapshot_merge_process() should delay the merging of _all_ chunks
> that have in-progress writes; not just the first chunk in the region
> that is to be merged.
> 
> The revised patch (relative to Jon's unified snapshot tree) is here:
> http://people.redhat.com/msnitzer/patches/snapshot-merge/kernel_unified/2.6.31/dm-snapshot-merge-use-larger-io-when-merging.patch
> 
> Pretty sure it _should_ work; but can't test until we get this unified
> snapshot patchset working properly.

Yes, that's right. The purpose of the tracking while merging is to exclude 
pending writes to the region that is being merged --- so we must wait for 
writes on all chunks. The patch seems fine.

Mikulas


