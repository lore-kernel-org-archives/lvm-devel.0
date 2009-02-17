From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 17 Feb 2009 19:40:20 +0000
Subject: Deprecating LVM code / commands?
In-Reply-To: <1234805214.2574.29.camel@f10-node1>
References: <1234805214.2574.29.camel@f10-node1>
Message-ID: <20090217194020.GG26197@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I prefer the bit-rot approach: there are certain parts of the code we no
longer actively maintain and we have no idea whether people are still
using, but as long as nobody reports significant problems it's harmless
to leave them in there.

However, if it turns out that significant work is required in those
areas, that's when we deprecate them by announcing that unless
satisfactory patches are submitted by someone, the code will be gone.

For example, until yesterday I had no idea anyone was still making use
of --disable-o_direct, which was a debugging option I added a long time
ago and I'll happily remove if it gets in the way of some other change we
need.  It remains unmaintained, means pvmove (and probably more things)
can deadlock and really has no place outside a test or development
system.  If O_DIRECT is broken on a system, then please get it debugged
and fixed!

But lvm1 and pool?  Well it's unlikely people are using them on new
systems, but the hard work in offering those formats has already been
done and there's little point in ceasing to support them.  They are
already deprecated in the sense that we regularly add new features that
do not work with those formats.

Is now the time to shift them to a separate compat- sub-package instead
of building them in as a prelude to not installing the package by
default?  Possibly, but that would affect other packages too, so let's
not add to our problems for F11 here - maybe we'll do that in F12 and
meanwhile indicate in RHEL6 that support for lvm1 format will not be
present in RHEL7, assuming RHEL3 is no longer supported by then - we
need to keep it for as long as people might be accessing devices created
on RHEL3 systems.  Upstream however, it should stay pretty much
indefinitely (i.e.  until the next major rewrite).

Alasdair
-- 
agk at redhat.com


