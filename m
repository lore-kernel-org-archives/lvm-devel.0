From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 04 Feb 2009 15:27:36 -0500
Subject: [PATCH 06/13] Add lvm_vg_close().
In-Reply-To: <1233767486.4048.50.camel@localhost.localdomain>
References: <1233607809-1087-1-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-2-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-3-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-4-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-5-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-6-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-7-git-send-email-dwysocha@redhat.com>
	<87d4e0769u.fsf@eriador.mornfall.net>
	<1233767486.4048.50.camel@localhost.localdomain>
Message-ID: <1233779256.4048.57.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Wed, 2009-02-04 at 12:11 -0500, Dave Wysochanski wrote:
> On Tue, 2009-02-03 at 00:45 +0100, Petr Rockai wrote:
> > Dave Wysochanski <dwysocha@redhat.com> writes:
> > > +void lvm_vg_close(vg_t *vg)
> > > +{
> > > +	if (vgname_is_locked(vg->name))
> > > +		unlock_vg(vg->cmd, vg->name);
> > > +}
> > Do we want to do reference counting in here? Might be moot if we don't allow
> > multiple opens. But contrary to what I said on IRC last time, it might be worth
> > to have proper lock upgrading procedure, and it would be sort of nice if that
> > could be achieved (for the user) by just calling the open function again on the
> > same VG, with write permission request. One use case is automated recovery,
> > which could be probably reformulated elegantly in terms of a lock upgrade.
> > 
> 
> Well, calling the open function again on the same VG would be a new
> interface that we'd have to explain so I'd lean against it.  Is there an
> example elsewhere we could point at?  If we went this route we'd need to
> keep a list of handles internally (we may end up needing this anyway for
> true handle validation) and then just pass back the same one.
> 
> Also I think Thomas was opposed to the lock upgrading.
> 

There are plenty of examples of lock upgrading though normally it's on
some sort of lock call, not an open.  I know we said we wanted to hide
the locking - maybe still possible.  But if we need lock upgrading it
might be clearer if we exposed a lock API directly.  *gasp*




