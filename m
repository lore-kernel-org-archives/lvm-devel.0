From: Petr Rockai <prockai@redhat.com>
Date: Wed, 04 Feb 2009 09:36:19 +0100
Subject: [PATCH] A different implementation of --ignorelockingfailure.
In-Reply-To: <1233714534.16492.10.camel@localhost.localdomain> (Dave
	Wysochanski's message of "Tue, 03 Feb 2009 21:28:54 -0500")
References: <871vuva9yn.fsf@eriador.mornfall.net>
	<1233714534.16492.10.camel@localhost.localdomain>
Message-ID: <873aeuk398.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski <dwysocha@redhat.com> writes:
> 1. Why call it 'boottime_locking' - why not readonly_locking which is
> clearer?
boottime is to show clearly that it should never be used elsewhere than
boottime. It's *not* readonly locking. It's locking that will grant read access
*without taking any locks*. Ie. inherently dangerous. Under normal operation,
this is a locking violation that may lead to corrupt metadata reads.

> 2. If you make this change you'll also need to modify lvchange.c to take
> a READ lock if the request is for an availability change (vgchange has a
> conditional).*  Otherwise, lvchange will fail when before it would
> succeed.
Oh. Ok, I will need to investigate that. From a glance, it seems like a simple
omission where lvchange doesn't check that it doesn't need a write lock in some
cases. I'll amend my patch with a fix for that and resend.

Will also see if I can come up with some test for the suite...

> 3. Introducing boottime/readonly as a "type" of locking seems out of
> place with the current set of locking types - file operations, cluster
> operations.
There's also "nolocking" as a locking type, so a boottime one that is
restriction of nolocking seems in line to me.

> * Then again, lvchange and vgchange seem to have different code for
> changing availability of an LV (?) so there may be a subtle reason
> lvchange always takes a WRITE lock.
It doesn't seem so (see above). It however might be related to the pvmove_poll
and lvconvert_poll bits that are invoked by lvchange -a y (but not vgchange -a
y). This discrepancy alone looks a little odd at best. However, the polldaemons
do their own locking. This is not really a reason for lvchange requiring a
write lock. What does happen is though that the polldaemons inherit the locking
type, so if anyone runs lvchange -a y --ignorelockingfailure, they might be in
for serious trouble if pvmove (or lvconvert maybe) was in progress, since they
will get unlocked metadata writes on a live system that way.

However, at least on Debian, the initscripts don't use lvchange at all, they
just use vgchange -a y --ignorelockingfailure and I imagine this is the case
with most distributions? In which case, we don't really need to care about
lvchange all that much. (Also note that this patch fixes the above corruption
bug induced by lvchange -a y --ignorelockingfailure, since it will disallow the
polldaemon to write metadata, and it should fail in some reasonable controlled
fashion. Well, it will disallow lvchange -a y altogether, but that can be fixed
by not requiring write lock for the activation itself...)

Thanks for review,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


