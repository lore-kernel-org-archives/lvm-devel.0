From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 15 Nov 2011 08:54:31 -0500
Subject: [PATCH 1/5] Add static _check_pv_sizes() function to check all pv sizes for consistency.
In-Reply-To: <20111114213402.GK4396@agk-dp.fab.redhat.com>
References: <1321305181-28158-1-git-send-email-dwysocha@redhat.com>
	<1321305181-28158-2-git-send-email-dwysocha@redhat.com>
	<20111114213402.GK4396@agk-dp.fab.redhat.com>
Message-ID: <1321365271.1790.12.camel@f14-work>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 2011-11-14 at 21:34 +0000, Alasdair G Kergon wrote:
> On Mon, Nov 14, 2011 at 04:12:57PM -0500, Dave Wysochanski wrote:
> > This function should be called from vg_validate() and vg_read_internal() at
> > the very least, barring some condition I have not thought of.  Whether
> 
> --setphysicalvolumesize
> 
> Alasdair
> 

Hmmm.  So there's a reason we should allow someone to "pvresize
--setphysicalvolumesize" a larger size than the device itself?  What's
the use case, or are you just not wanting to be restrictive?

It did not seem to me we ever want to allow it.


