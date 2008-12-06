From: Alasdair G Kergon <agk@redhat.com>
Date: Sat, 6 Dec 2008 13:58:26 +0000
Subject: [PATCH] Make _init_rand() thread safe - use rand_r() instead of rand().
In-Reply-To: <1228534064.21024.65.camel@localhost.localdomain>
References: <1228517565-28873-1-git-send-email-dwysocha@redhat.com>
	<20081206022653.GF26097@agk.fab.redhat.com>
	<1228534064.21024.65.camel@localhost.localdomain>
Message-ID: <20081206135826.GG26097@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Dec 05, 2008 at 10:27:44PM -0500, Dave Wysochanski wrote:
> On Sat, 2008-12-06 at 02:26 +0000, Alasdair G Kergon wrote:
> > On Fri, Dec 05, 2008 at 05:52:45PM -0500, Dave Wysochanski wrote:

> > > +	if (!create_temp_name(temp_dir, temp_file, sizeof(temp_file), &fd,
> > > +			      &vg->cmd->rand_seed)) {
> > Just pass 'cmd'? (as first arg)

> I originally did that but then thought it might be better to avoid
> polluting lvm-file.c with includes just so I could dereference cmd.

Doesn't really matter as lvm-file.c is within the library, and the include
you need is also internal.  Not important though, don't bother changing
it now if you don't want to.
 
> > Does this patch do enough to ensure each thread will get a different value of
> > 'seed'?
> Probably not.  A better seed might use /dev/urandom or gettimeofday()
> with tv_usec granularity.
 
Yup - the existing one-second granularity makes a collision likely - tv_usec
ought to be adequate.

Alasdair
-- 
agk at redhat.com


