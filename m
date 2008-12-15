From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 15 Dec 2008 14:23:54 -0500
Subject: [PATCH] (1/2) new library interface for vg_read
In-Reply-To: <87r649a0uz.fsf@eriador.mornfall.net>
References: <87y6ypcn7l.fsf@eriador.mornfall.net>
	<1229027813.20795.15.camel@localhost.localdomain>
	<87ljulbvgu.fsf@eriador.mornfall.net>
	<1229104225.16499.21.camel@localhost.localdomain>
	<87r649a0uz.fsf@eriador.mornfall.net>
Message-ID: <1229369034.19225.10.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Mon, 2008-12-15 at 16:56 +0100, Petr Rockai wrote:
> Hi,
> 
> Dave Wysochanski <dwysocha@redhat.com> writes:
> > Well, doesn't this cause a bug in this path though for the !consistent
> > case?  First patch drops the consistent variable in this vgremove path,
> > but things like _process_one_vg() do not use the new APIs (which sets
> > the proper error codes) until the second patch.  You mention in your
> > patch intro this first patch should apply and make a completely workable
> > LVM so I'm assuming you mean no bugs.
> Oh, hm, you are apparently right. Interestingly enough, the presumably buggy
> code does pass the testsuite, so something's wrong with the testsuite, I
> suppose. It might be good to have a test triggering that problem. I will
> re-split the patch and resubmit later today.
> 
The other thing I had wondered about was your changing
vg_lock_and_read() significantly (in particular the return value /
handle) but not changing any of the callers until the second patch.  I
have not thought this through but are you confident the existing callers
will be ok without the second patch?



