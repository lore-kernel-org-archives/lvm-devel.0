From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 5 Nov 2008 16:28:19 +0000
Subject: [PATCH] (2/11) various minor cleanups
In-Reply-To: <1225900465.11788.10.camel@localhost.localdomain>
References: <87wsfq3r91.fsf@eriador.mornfall.net>
	<1225900465.11788.10.camel@localhost.localdomain>
Message-ID: <20081105162819.GS14593@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Nov 05, 2008 at 10:54:24AM -0500, Dave Wysochanski wrote:
> On Thu, 2008-10-30 at 18:52 +0100, Petr Rockai wrote:
> > +               log_error("Attempted to write unlocked VG's device.");

> Probably want a WHATS_NEW comment like:
> Do not allow dev_write() to proceed unless a VG write lock is held.
 
And make the error message useful by including specific details in it:-)

Alasdair
-- 
agk at redhat.com


