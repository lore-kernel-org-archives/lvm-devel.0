From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 19 Oct 2009 19:17:54 -0400
Subject: [PATCH] Change process_each_lv_in_vg() iterator to only process non-hidden LVs.
In-Reply-To: <4AD83740.5070704@redhat.com>
References: <1255615650-3655-1-git-send-email-dwysocha@redhat.com>
	<4AD83740.5070704@redhat.com>
Message-ID: <1255994274.2499.25.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 2009-10-16 at 11:05 +0200, Milan Broz wrote:
> On 10/15/2009 04:07 PM, Dave Wysochanski wrote:
> > Unless the "--all" flag is given, the iterator functions should not be
> > processing hidden LVs.  I have checked all the tools and this seems to
> > be how they all behave.  Somehow before I missed the fact I could re-use
> > the "--all" flag to qualify the hidden LV check (perhaps it's because
> > the all flag is not documented well).  If there are things I've overlooked
> > I can deal with them in another patch.  I am working on patches to clarify
> > and document the usage of "--all".
> 
> Ack for the intention (see my previous patch) but nack to use of all_ARG :-)
> 
> We should really document --all first, missing in man pages
> (lvs, lvdisplay, lvscan, pvs, pvdisplay, vgs)
> 

Right - I'm working on that.

Basically the way --all behaves today is:
- PV: process all devices, even if they don't have a label on them
- LV: process all LVs, even hidden/internal ones
- VG: process all VGs

There are some small inconsistencies but this is basically it.


> 
> > --- a/tools/toollib.c
> > +++ b/tools/toollib.c
> > @@ -122,6 +122,9 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
> >  		if (lvl->lv->status & SNAPSHOT)
> >  			continue;
> >  
> > +		if (!lv_is_visible(lvl->lv) && !arg_count(cmd, all_ARG))
> > +			continue;
> > +
> 
> This function is used used in process_each_lv().
> 
> If you do this and command uses all_ARG, caller can activate hidden
> volumes directly (see lvchange).
> 

if you try --all on lvchange it will fail earlier since --all is not
allowed and conflicts with the allocation policy.  The only commands
that allow --all I've checked (see commands.h)


> But you cannot remove hidden volumes now (see lvremove, it has no all arg).
> 
> I think that
> 
>  - not visible (hidden) volumes must be always be activated through some
> visible LV or other operation
> (I have special hidden keystore volume and I never want user to activate it
> explicitly for example.)

Agreed.  I think this patch preserves that.

>  - we should allow user to remove hidden volume (if it is unreferenced),
> (like hidden orphaned mirror log when something went wrong)
> 
Ok, this is a different story.  Why is this?  Shouldn't they be using
dmsetup if LVM failed in such a way?  It seems like the scenario(s) you
describe will only take place when there's an LVM bug, which should be
fixed.  Can you envision another recovery scenario that is not an LVM
bug?

> - also see my previous patch for vgchange, it should be cleaned similar way
> (adding exceptions for every type of hidden volume is not ideal,
> lv_is_visible() seems to be ok here)
> 

I would like to put a stake in the ground and say the iterators do not
process hidden LVs and users should not really be operating on hidden
LVs by specifying them on the commandline.  The LV abstraction starts to
break down if we do that (what does "lvcreate -m1" mean then - it
creates multiple LVs, or is it one LV, a mirror?) and I'd rather not,
unless maybe in some select recovery scenarios as you say.  Even then we
should handle this some other way IMO.

I looked at adding a flag to the iterators but I didn't think it was
worth it.  I guess I just did not see an alternative to:
1) adding a flag to the iterators.  Maybe you would prefer this?
2) not adding flag to iterators and handling hidden LVs a different way
(by using --all or some other cmdline option)

I also thought --all was not the right flag to handle this longer term,
but wanted to preserve the existing behavior of the tools as a first
step.  Honestly --all is a bit goofy if you ask me but I understand
where it is used and why.


