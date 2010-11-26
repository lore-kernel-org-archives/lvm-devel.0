From: Dave W <wysochanski@pobox.com>
Date: Fri, 26 Nov 2010 09:56:44 -0800 (PST)
Subject: Fw: [PATCH 1/2] Update errno codes for vg_read() and lvm2app lvm_vg_open().
In-Reply-To: <8762vlo3wj.fsf@twilight.int.mornfall.net.>
References: <1290488470-21743-1-git-send-email-wysochanski@pobox.com>
	<1290488470-21743-2-git-send-email-wysochanski@pobox.com>
	<8762vlo3wj.fsf@twilight.int.mornfall.net.>
Message-ID: <707057.9725.qm@web113401.mail.gq1.yahoo.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Meant to send to the list - my responses to Petr below.


----- Forwarded Message ----
> From: Dave W <wysochanski@pobox.com>
> To: Petr Rockai <prockai@redhat.com>
> Sent: Fri, November 26, 2010 12:55:36 PM
> Subject: Re: [lvm-devel] [PATCH 1/2] Update errno codes for vg_read() and 
>lvm2app lvm_vg_open().
> 
> ----- Original Message ----
> > From: Petr Rockai <prockai@redhat.com>
> > To: lvm-devel at redhat.com
> > Cc: benscott at nwlink.com; Dave Wysochanski  <wysochanski@pobox.com>
> > Sent:  Thu, November 25, 2010 9:48:28 AM
> > Subject: Re: [lvm-devel] [PATCH 1/2]  Update errno codes for vg_read() and 
> >lvm2app lvm_vg_open().
> > 
> > Hi,
> > 
> > I am not checking this in yet, I would like to  discuss the value  choices
> > first a bit. Presumably, once we set  them, we are sort of stuck with  the
> > choices, so we should be  careful.
> > 
> > Dave Wysochanski <wysochanski@pobox.com>   writes:
> > 
> > > Update errno codes for vg_read error  paths:
> > > -  EINVAL: invalid vg_name
> > > - ENOLCK:  lock_vol fails
> > EBUSY? (But really,  this probably depends on *why*  _lock_vol
> > failed... maybe we need to drill  down here?)
> > 
> 
> 
> For this patch I was just concerning myself with the  top-most
> error path, and trying to ensure errno was set to something
> sane  for each path.  I don't think EBUSY fits as well at this
> high of a  level.
> 
> Keep in mind the motivation for this change came with the  bug
> reported by Ben who was using lvm2app and asked for a
> specific code  for the "skipping clustered VG" case.  So I
> expanded the scope to  include most all paths of lvm_vg_open().
> 
> It may be worth drilling down  here and setting errno inside
> lock_vol().  If this is the case, we  should maybe split
> this errno code into a separate patch?
> 
> 
> >  > - ENODEV: VG 'vgname' does not exist
> > > -  EPROTOTYPE: VG is  clustered but locking not clustered
> > What about just EPROTO?  Or  ENOLCK?
> > 
> 
> 
> This was the one that was the motivation for the  patch.
> I think there are multiple reasonable possibilities here,
> none of  which really fits 100%.  Some others I thought might
> fit too, such as  ENOPROTOOPT ("protocol not available"), EPROTO
> ("protocol error").
> 
> I  guess one might want to think about the other
> possible cluster errors we  could get in this function and how they
> might want to map to errnos.   Such a process runs the risk
> of taking a long time to complete  though.
> 
> > > - EROFS: VG is read-only
> > If we want to re-use  existing  errnos, I would go with EACCESS or EPERM
> > here. EROFS  *sounds* similar, but is  IMHO a semantical misfit.
> > 
> 
> I think  EACCESS or EPERM would fit as well, and as you say may be better than 

> EROFS.
> I guess I thought of "read only" being the most specific to that  path for that 
>
> call and less
> likely to conflict.  The fact we are  limited in errno values we have to try to 
>
> think about
> what other codes we  might need.  You may want to reserve EPERM for a day when 

> for
> instance a user gives a value of 'flags' that are invalid.  In  the end it is 
> hard to predict
> the future though.
> 
> > > -  EUCLEAN: VG is inconsistent
> > This one  is tricky. I would almost not  assign an errno here at least  for
> > now.
> > 
> 
> 
> Might  be another good candidate for a separate patch.  As you know, the 
> inconsistent
> VG case is probably a very important one once recovery APIs  are added to 
> lvm2app.
> 
> 


