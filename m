From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 06 Apr 2010 09:48:29 -0400
Subject: [PATCH 5/5] Add pv->vg to solidify link between a pv and a vg.
In-Reply-To: <20100406132756.GE30760@agk-dp.fab.redhat.com>
References: <1270497099-13259-1-git-send-email-dwysocha@redhat.com>
	<1270497099-13259-2-git-send-email-dwysocha@redhat.com>
	<1270497099-13259-3-git-send-email-dwysocha@redhat.com>
	<1270497099-13259-4-git-send-email-dwysocha@redhat.com>
	<1270497099-13259-5-git-send-email-dwysocha@redhat.com>
	<1270497099-13259-6-git-send-email-dwysocha@redhat.com>
	<20100406132756.GE30760@agk-dp.fab.redhat.com>
Message-ID: <1270561709.16846.6.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, 2010-04-06 at 14:27 +0100, Alasdair G Kergon wrote:
> On Mon, Apr 05, 2010 at 03:51:39PM -0400, Dave Wysochanski wrote:
> > +++ b/lib/metadata/metadata-exported.h
> > @@ -184,6 +184,7 @@ struct physical_volume {
> >  	const char *vg_name;
> >  	struct id vgid;
> >  
> > +	struct volume_group *vg;
> >  	uint64_t status;
> >  	uint64_t size;
>  
> Put it at the end of the other group i.e. move the blank line.
> 
> There are now *three* entries in the PV struct referring to the VG.
> - vg_name
> - vgid
> - vg
> 
> Why do we need 3?
> - Historically, only the name was used.
> - We added vgid to distinguish between different VGs with the same name plugged
> into a system.
> - The new 'vg' field as proposed is *independent* of those two existing ones, and
> is set and maintained when the PV belongs to a 'pvs' list in a parent VG struct.
> Please make that clear in a comment by the field.
> 

Ok yes, I will add the comment/explanation.

I started to see if I could refactor such that I remove vgname and vgid
from struct physical_volume and just reference vg->name and vg->id, but
it may be more trouble than it is worth.  Ideally all we need is 'vg',
but this assumes the VG is constructed at all times when the vgname and
vgid fields are needed.  When we read labels though, and dip into the vg
metadata for the vgname, etc, we don't really construct the vg at this
point, so it might not be something that could be easily/safely
refactored.  Then again, longer term we may want to sub-divide the vg
into a "vg header" which contains just what we read at label_read()
time, and then we could conceivably refactor this I think.




