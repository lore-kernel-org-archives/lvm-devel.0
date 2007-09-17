From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 17 Sep 2007 20:34:50 +0100
Subject: fix for link pthread-related link failure on Debian
In-Reply-To: <87lkb5b1l0.fsf@rho.meyering.net>
References: <877imvsty8.fsf@rho.meyering.net>
	<1189620953.4435.2.camel@linux-cxyg>
	<873axjrb3u.fsf@rho.meyering.net>
	<20070917175407.GJ18444@agk.fab.redhat.com>
	<87lkb5b1l0.fsf@rho.meyering.net>
Message-ID: <20070917193450.GO18444@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Sep 17, 2007 at 08:15:23PM +0200, Jim Meyering wrote:
> How about making it so autoconf is required, only if you modify
> configure.in or otherwise fiddle with mtimes to make it look like
> configure is out of date?
 
I still think that is too much risk for the build environment.
A warning message, yes, but blocking the build, no.
I don't want any chance of autoconf running unless people specifically
ask for it.

> Why cater to developers who lack the required version of autoconf?

It's the build/packaging environment I consider primary here.  I do not
want builds from tarball to acquire an autoconf dependency, and if
there's a rule saying that 'configure' sometimes needs rebuilding
automatically then that dependency exists - even if you consider
the possibility only theoretical, timestamps may get messed up under
some configurations.

Another way to do this would be to flip the --enable-autoreconf default
setting in the release tarballs.  (E.g. Only attempt the autoreconf if
the version ends in -cvs.)

Alasdair
-- 
agk at redhat.com


