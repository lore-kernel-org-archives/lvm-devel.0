From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 16 Feb 2009 17:05:15 -0500
Subject: [PATCH] Use vgid as well as vgname in lvmcache_update_vg().
In-Reply-To: <20090216190806.GA26197@agk.fab.redhat.com>
References: <1234048029-29850-1-git-send-email-dwysocha@redhat.com>
	<20090216190806.GA26197@agk.fab.redhat.com>
Message-ID: <1234821915.2574.33.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 2009-02-16 at 19:08 +0000, Alasdair G Kergon wrote:
> On Sat, Feb 07, 2009 at 06:07:09PM -0500, Dave Wysochanski wrote:
> > With duplicate vgnames in a system, vg metadata could get
> > exported to the wrong lvmcache_vginfo structure.  Use the vg_uuid as
> > well as the name to lookup the vginfo structure before we store the
> > metadata.
>  
> Did you construct any test case where this actually goes wrong?
> 

I saw the problem when testing one series of liblvm patches that I
posted to lvm-devel.  I'm not sure I can hit the problem with the
existing tools.

The scenario I was testing involved duplicate vgnames in the system.  I
tried to open both VGs (different vgids) but noticed that I could only
ever open one of them.  I traced the bug to this piece of code and
submitted the patch.

I've reproduced the problem with my patches but I'm looking at the code
more carefully and trying to remember it all.


