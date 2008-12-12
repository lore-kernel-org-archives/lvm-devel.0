From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 12 Dec 2008 01:42:12 +0000
Subject: [PATCH] (1/2) new library interface for vg_read
In-Reply-To: <1229027947.20795.16.camel@localhost.localdomain>
References: <87y6ypcn7l.fsf@eriador.mornfall.net>
	<1229027947.20795.16.camel@localhost.localdomain>
Message-ID: <20081212014212.GW24785@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Dec 11, 2008 at 03:39:07PM -0500, Dave Wysochanski wrote:
> On Tue, 2008-12-09 at 17:44 +0100, Petr Rockai wrote:
> > +++ new-lvmlib/lib/device/dev-io.c      2008-12-09 17:44:06.930396980
> > +0100
> > @@ -622,6 +622,11 @@ int dev_write(struct device *dev, uint64

> > +       if (!vg_write_lock_held()) {
> > +               log_error("Attempted to write unlocked VG's device.");
> > +               return_0;

If the code was correct that never would happen?
i.e. Label it as 'Internal error:'

Alasdair
-- 
agk at redhat.com


