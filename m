From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Mon, 12 Oct 2009 16:07:42 +0200
Subject: [PATCH 08/11] debian: use selinux pkgconfig info instead of hardcoding
In-Reply-To: <20091012101838.GN19397@agk-dp.fab.redhat.com>
References: <8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
	<afcb9c9c64ef9416639b7c508add1e519a62fbb7.1255002311.git.fdinitto@redhat.com>
	<20091008234450.GW3054@agk-dp.fab.redhat.com>
	<1255338418.10932.38.camel@cerberus.int.fabbione.net>
	<20091012101838.GN19397@agk-dp.fab.redhat.com>
Message-ID: <1255356462.10932.68.camel@cerberus.int.fabbione.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 2009-10-12 at 11:18 +0100, Alasdair G Kergon wrote:
> On Mon, Oct 12, 2009 at 11:06:58AM +0200, Fabio M. Di Nitto wrote:
> > For the internal view, we can switch to use PKG_CONFIG inside our
> > configure.in, but that means:
> > 1) it will be a hard dependency (and we recently agreed to avoid that).
> > 2) we assume that lvm2 developers and packagers will build/ship with
> > recent enough build dependencies to guarantee working pkg-config files.
>  
> So any switch would still need a fallback for when pkgconfig is not
> available.  (The real question is whether pkgconfig was generally
> available some time before selinux or not.  If it was, then you can
> argue that everyone with access to selinux also has access to pkgconfig.)

Ok, this will take some more time to be done properly across the board.
I don't want to special case every library/pkgconfig in a different way.

Fabio


