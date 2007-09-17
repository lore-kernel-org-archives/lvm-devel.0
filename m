From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 17 Sep 2007 18:54:07 +0100
Subject: fix for link pthread-related link failure on Debian
In-Reply-To: <873axjrb3u.fsf@rho.meyering.net>
References: <877imvsty8.fsf@rho.meyering.net>
	<1189620953.4435.2.camel@linux-cxyg>
	<873axjrb3u.fsf@rho.meyering.net>
Message-ID: <20070917175407.GJ18444@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Sep 12, 2007 at 08:29:25PM +0200, Jim Meyering wrote:
> I've just rerun autoconf and committed the new, regenerated file.
> This is one of the reasons I really like to have complete and
> accurate dependencies.  Does anyone know why we lack this particular one?

Because we ship the 'configure' file etc. and that is all that we
support in build environments: autoconf etc. should not be a requirement
to build the code.

> Would anyone object to my adding the missing rule?

Only if not done in such a way that it was optional and disabled by
default in build environments (though a non-fatal warning message would
be OK).

E.g. configure --enable-autoreconf would require the autoconf tools to
be present and then cause the makefiles to detect when they are
out-of-date and attempt to reconfigure themselves and relaunch etc.

Alasdair
-- 
agk at redhat.com


