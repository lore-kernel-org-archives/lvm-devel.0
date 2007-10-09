From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 9 Oct 2007 12:56:37 +0100
Subject: Allow $DM_DEVDIR envvar to override default of "/dev".
In-Reply-To: <87wstwy0md.fsf@rho.meyering.net>
References: <87przp1psr.fsf@rho.meyering.net>
	<20071009020040.GR10006@agk.fab.redhat.com>
	<87wstwy0md.fsf@rho.meyering.net>
Message-ID: <20071009115637.GT10006@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Oct 09, 2007 at 01:43:22PM +0200, Jim Meyering wrote:
> I can do that, but then the diagnostic can no longer say that
> the DM_DEV_DIR envvar is at fault.  

Then do the 'stack' or 'return_0' macro thing - or log the
detailed error with log_debug so people will normally just
see the 'clean' error.

Alasdair
-- 
agk at redhat.com


