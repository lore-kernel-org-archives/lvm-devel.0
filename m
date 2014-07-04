From: Alasdair G Kergon <agk@redhat.com>
Date: Sat, 5 Jul 2014 00:42:18 +0100
Subject: master - dev-type: print log_sys_debug
In-Reply-To: <53B70B5F.9030309@redhat.com>
References: <20140704103204.1476260C22@fedorahosted.org>
	<20140704172218.GB27805@agk-dp.fab.redhat.com>
	<53B70B5F.9030309@redhat.com>
Message-ID: <20140704234217.GC27805@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jul 04, 2014 at 10:15:27PM +0200, Zdenek Kabelac wrote:
> If we would left log_error() as is - then 'error' usage is already marked,
> and the 'real' error might not be actually printed (forgotten to be added 
> to the code) - thus user could get misleading idea what's been the real 
> reason for error.

That doesn't concern me, as we consider the likelihood of the first non-fatal
error should be rare enough already - it's not important if the "less-important"
error code is the one returned should there be a further error later on: all
errors should be investigated in that case.

Alasdair


