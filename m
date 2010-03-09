From: Mikulas Patocka <mpatocka@redhat.com>
Date: Tue, 9 Mar 2010 03:41:54 -0500 (EST)
Subject: edits for r16 of shared snapshot patches [was: Re: userspace patches for shared snapshots]
In-Reply-To: <20100305174747.GA777@redhat.com>
References: <Pine.LNX.4.64.1002101858410.15802@hs20-bc2-1.build.redhat.com>
	<20100225221324.GA29946@redhat.com>
	<Pine.LNX.4.64.1002252327100.29287@hs20-bc2-1.build.redhat.com>
	<20100226211702.GA23893@redhat.com> <20100303223740.GA12242@redhat.com>
	<Pine.LNX.4.64.1003040502020.16112@hs20-bc2-1.build.redhat.com>
	<20100304132228.GA20534@redhat.com> <20100305174747.GA777@redhat.com>
Message-ID: <Pine.LNX.4.64.1003090332350.21412@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> You can see the edits here:
> http://people.redhat.com/msnitzer/patches/multisnap/kernel/2.6.33/r16a/r16_edits.patch
> 
> Boils down to:
> * use __func__ rather than hardcoding the function name
>   - this fixed ~3 inconsistencies (incorrect function names) and should
>     help if/when we do any function renaming in later phases of review

It consumes one more stack word for every function where this conversion 
was performed ... I don't know if it's worth it ... likely it doesn't 
matter.

The problem here is that GCC is preallocating the space for all outgoing 
arguments in the function prologue, so if the function has something like 
this
if (bug_happened) {
	printk("%s: bug happened: %d %d %d %d %d %d %d %d", __func__, a, 
b, c, d, e, f, g, h, i);
}
the whole function always wastes 10 stack words, even if the bug doesn't 
happen :(

But that one word because of __func__ maybe doesn't matter (there are much 
more wasted already in these printks). Or do you think that it's better to 
not do this __func__ conversion?

Mikulas

> * s/Tomonorig/Tomonori/
> * a few more typo fixups
> * a few more whitespace cleanups.
> 
> I'd appreciate it if you pull these in for the basis of any follow-on
> release you make.
> 
> Also, I'm working to improve Documentation/device-mapper/dm-multisnapshot.txt
> I'll share this a bit later (hopefully today).
> 
> Mike
> 


