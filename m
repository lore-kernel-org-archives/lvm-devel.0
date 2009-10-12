From: Fabio M. Di Nitto <fabbione@fabbione.net>
Date: Mon, 12 Oct 2009 11:06:58 +0200
Subject: [PATCH 08/11] debian: use selinux pkgconfig info instead of hardcoding
In-Reply-To: <20091008234450.GW3054@agk-dp.fab.redhat.com>
References: <8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
	<afcb9c9c64ef9416639b7c508add1e519a62fbb7.1255002311.git.fdinitto@redhat.com>
	<20091008234450.GW3054@agk-dp.fab.redhat.com>
Message-ID: <1255338418.10932.38.camel@cerberus.int.fabbione.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 2009-10-09 at 00:44 +0100, Alasdair G Kergon wrote:
> On Thu, Oct 08, 2009 at 02:49:15PM +0200, Fabio M. Di Nitto wrote:
> > use selinux pkgconfig file instead of hardcoding the contents
>  
> I don't think this patch goes far enough...
> The build should be using the pc file too (if present), as we now do for clvmd!

We need to differentiate as Bastian said.

For the internal view, we can switch to use PKG_CONFIG inside our
configure.in, but that means:

1) it will be a hard dependency (and we recently agreed to avoid that).

2) we assume that lvm2 developers and packagers will build/ship with
recent enough build dependencies to guarantee working pkg-config files.

While I am generally ok with this approach as it will make our
configure.in a lot simpler, it will kill the option to build on older
distro (I believe we only lose RHEL4 at this point, but it would require
cross-checking).

For the external view, as it is now, we can create the correct .pc file.
If we detect that selinux has pkg-config support, then we use the
"Requires.private: libselinux" that will automatically expand via
pkg-config. If we don't have selinux pkg-config, then we can hardcode as
we do now.

Fabio


