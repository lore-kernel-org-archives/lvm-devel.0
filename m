From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 24 Sep 2007 12:39:03 -0400
Subject: RFC: Clarifying the usage of pvs on the lvextend command line, especially %VG and %FREE
Message-ID: <1190651943.4431.28.camel@linux-cxyg>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I just did a quick survey of the size (-L) and extent (-l) options to
lvextend / lvresize when combined with PVS on the cmdline.  The analysis
led me to ponder whether there should be some clarification or
restriction as to when PVs should be given with lvextend / lvresize.
Options seem to be an explicit check in the code or a
clarification/suggestion in the man page.

In particular, I'm wondering about the cases of %VG and %FREE with pvs
on the cmdline.  Are there cases people can think of where it would be
useful for a user to specify PVS on the cmdline with %VG and/or %FREE?
I'm wondering whether allowing pvs here just makes things more confusing
to the user.

Here's what I came up with that led me to question this:

When we put pvs on the cmdline, we are saying "use these PVs to do the 
allocation needed".  They do not specify how much allocation to do, the
only exception being the %PVS option.

Case 1: -L size option.  If you specify pvs with a size, the allocation
is
done based on the size and the pool of PVS is given on the cmdline.  If
you
don't specify pvs with a size, then all PVS in the vg are used.  This
usage
seems to make sense.  So pvs on the cmdline with -L is fine.

Case 2: -l extents option.  There are many cases within this one with
all
the different percentage options.
  	a) Simple extents number, w/out percentage.  In this case, we
 	either get an absolute number of extents or a delta of extents.
	In both cases, we are using the pvs on the cmdline to get the
	extents needed.
	b) %VG as extents number.  Here we specify a percentage of the
	volume group size to use for the lvextend.  If we specify a 
	subset of the overall pvs in the vg on the cmdline, this percentage
	might not make as much sense.  So perhaps it does not make much
	sense to allow pvs on the cmdline with %VG?  Does this just open
	the door to users being confused?
	c) %FREE as extents number.  We specify the percentage of free 
	space in the volume group to get the number of extents, but again
	the allocation is qualified with the pvs on the cmdline.  Does this
	make sense?  Would a user ever want this or does it just create 
	confusion?  Would someone naturally think %FREE is associated with
	free space on the PVS?
	d) %LV as extents number.  Here we want to change the size of the
	LV relative to itself (for example, double the size of the LV) and
	we specify PVS on the cmdline so we know where the space comes from.
	This seems to be a sensible thing the user might want.
	e) %PVS as extents number.  Clearly we need pvs on the cmdline as
	the extents calculation depends on it.




