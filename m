From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 5 Mar 2010 12:47:47 -0500
Subject: edits for r16 of shared snapshot patches [was: Re: userspace patches for shared snapshots]
In-Reply-To: <20100304132228.GA20534@redhat.com>
References: <Pine.LNX.4.64.1002101858410.15802@hs20-bc2-1.build.redhat.com>
	<20100225221324.GA29946@redhat.com>
	<Pine.LNX.4.64.1002252327100.29287@hs20-bc2-1.build.redhat.com>
	<20100226211702.GA23893@redhat.com>
	<20100303223740.GA12242@redhat.com>
	<Pine.LNX.4.64.1003040502020.16112@hs20-bc2-1.build.redhat.com>
	<20100304132228.GA20534@redhat.com>
Message-ID: <20100305174747.GA777@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Mar 04 2010 at  8:22am -0500,
Mike Snitzer <snitzer@redhat.com> wrote:

> On Thu, Mar 04 2010 at  5:11am -0500,
> Mikulas Patocka <mpatocka@redhat.com> wrote:
> 
> > I went through your kernel patch and uploaded a new version at 
> > http://people.redhat.com/mpatocka/patches/kernel/new-snapshots/r16/ . It 
> > contains fix for this 100% usage. It contains most of your changes (I 
> > rolled back that cycle change).
> 
> OK, I have made further edits that layered ontop of my other changes
> (primarily just making use of __func__ rather than hardcoding the
> function name in ERROR messages).  I'll have a look at your r16 and
> hopefully they'll apply there too.

I've uploaded my edits to r16 here:
http://people.redhat.com/msnitzer/patches/multisnap/kernel/2.6.33/r16a/

You can see the edits here:
http://people.redhat.com/msnitzer/patches/multisnap/kernel/2.6.33/r16a/r16_edits.patch

Boils down to:
* use __func__ rather than hardcoding the function name
  - this fixed ~3 inconsistencies (incorrect function names) and should
    help if/when we do any function renaming in later phases of review
* s/Tomonorig/Tomonori/
* a few more typo fixups
* a few more whitespace cleanups.

I'd appreciate it if you pull these in for the basis of any follow-on
release you make.

Also, I'm working to improve Documentation/device-mapper/dm-multisnapshot.txt
I'll share this a bit later (hopefully today).

Mike


