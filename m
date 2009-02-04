From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 04 Feb 2009 12:11:26 -0500
Subject: [PATCH 06/13] Add lvm_vg_close().
In-Reply-To: <87d4e0769u.fsf@eriador.mornfall.net>
References: <1233607809-1087-1-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-2-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-3-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-4-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-5-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-6-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-7-git-send-email-dwysocha@redhat.com>
	<87d4e0769u.fsf@eriador.mornfall.net>
Message-ID: <1233767486.4048.50.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Tue, 2009-02-03 at 00:45 +0100, Petr Rockai wrote:
> Dave Wysochanski <dwysocha@redhat.com> writes:
> > +void lvm_vg_close(vg_t *vg)
> > +{
> > +	if (vgname_is_locked(vg->name))
> > +		unlock_vg(vg->cmd, vg->name);
> > +}
> Do we want to do reference counting in here? Might be moot if we don't allow
> multiple opens. But contrary to what I said on IRC last time, it might be worth
> to have proper lock upgrading procedure, and it would be sort of nice if that
> could be achieved (for the user) by just calling the open function again on the
> same VG, with write permission request. One use case is automated recovery,
> which could be probably reformulated elegantly in terms of a lock upgrade.
> 

Well, calling the open function again on the same VG would be a new
interface that we'd have to explain so I'd lean against it.  Is there an
example elsewhere we could point at?  If we went this route we'd need to
keep a list of handles internally (we may end up needing this anyway for
true handle validation) and then just pass back the same one.

Also I think Thomas was opposed to the lock upgrading.


> Another is the one you have mentioned, "read in the vg, wibble around a little
> and then decide you want to change it". The solution I proposed back then, to
> close and open for writing again, is inherently race-prone, so you would need
> to do all your wibbling again. Of course, the lock upgrade might fail, in which
> case, you will have to anyway, but maybe it still makes the API a little more
> friendly and less tempting to do the wrong thing.
> 

Right - we'll need to weigh pros and cons.  Might need to prototype each
approach and see what we find.


> However, now I think about it, even that probably doesn't need refcounting if
> we structure the lock upgrade API accordingly. Ok, clear.
> 
> I'm getting pretty tangential now, but another thought: should be the locking
> state encapsulated in the library handle, as opposed to process-global? This
> probably depends whether the locks can actually prevent the same process (in
> say different thread) from acquiring the lock second time (ie. whether they are
> effective in preventing unintended concurrent accesses from same process). If
> they are, it wouldn't be so hard to make the proposed lvmlib API thread-safe,
> by requiring that each thread owns its own library handle. This might be of
> direct benefit to eg. dmeventd, which currently has a fairly ugly mutex hack
> instead.
> 
By lock state, do you mean the type of locking, the locks on the
open/reads, or both?  The open/read mode we'd of course have to tie to
the vg handles.  

Does it makes sense to allow 2 threads to call init_locking() with
different lock types?

Like other areas the locking code needs work if we're serious about
thread safety.


