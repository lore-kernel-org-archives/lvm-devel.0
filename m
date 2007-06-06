From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 6 Jun 2007 19:40:36 +0100
Subject: [PATCH] add vg_check_status to consolidate vg status checks and error messages
In-Reply-To: <1180982410.3830.18.camel@linux-cxyg>
References: <1180982410.3830.18.camel@linux-cxyg>
Message-ID: <20070606184036.GL25091@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Jun 04, 2007 at 02:40:10PM -0400, Dave Wysochanski wrote:
> Minor functional changes:
> 1) Some checks are not in the exact order as before, but this should not
> matter (other than possible error message sequencing)

Not a problem.

> 2) Very slight differences in some error messages as a result of the
> messages printed from a single function (e.g. some vg names displayed
> were in double quotes, others were not)

Not a problem.  LVM1 used quotes; I preferred not to.

> 3) Now using "vg->name" in the log_error messages, instead of the
> variety of different variables being used.  I traced the prior call to
> vg_read though, and if we get non-NULL there, vg->name should be valid,
> so I'm fairly certain this is ok.

OK
 
> RFC items:
> 1) Possible unlock errors in 2 places of existing code involving the
> CLUSTERED check (see pvchange.c and pvmove.c).  I think an unlock should
> be added here but left it out to keep as close to existing code as
> possible and to call out this possible change.

Well a successful lock_vol on a VG must be followed eventually by an
unlock_vg on all paths - including error paths - so an inconsistency
between the different error paths while holding the lock is a bug.

> 2) Not sure if lib/metadata.c is the right place for this.  Should I
> create a lib/metadata/vg_manip.c or put it elsewhere
 
lib/metadata.c is fine.
tools/toollib.c would also be OK.
There isn't yet a clear policy - though ECMD_* errors shouldn't be
used outside the tools directory.

Alasdair
-- 
agk at redhat.com


