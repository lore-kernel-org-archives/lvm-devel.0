From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sat, 06 Dec 2008 11:16:06 -0500
Subject: [PATCH] Make _init_rand() thread safe - use rand_r() instead of rand().
In-Reply-To: <20081206135826.GG26097@agk.fab.redhat.com>
References: <1228517565-28873-1-git-send-email-dwysocha@redhat.com>
	<20081206022653.GF26097@agk.fab.redhat.com>
	<1228534064.21024.65.camel@localhost.localdomain>
	<20081206135826.GG26097@agk.fab.redhat.com>
Message-ID: <1228580166.1114.1.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Sat, 2008-12-06 at 13:58 +0000, Alasdair G Kergon wrote:
>  
> > > Does this patch do enough to ensure each thread will get a different value of
> > > 'seed'?
> > Probably not.  A better seed might use /dev/urandom or gettimeofday()
> > with tv_usec granularity.
>  
> Yup - the existing one-second granularity makes a collision likely - tv_usec
> ought to be adequate.
> 

Did not see this before I started adding the generic read_urandom()
function.


