From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 12 Oct 2009 11:18:38 +0100
Subject: [PATCH 08/11] debian: use selinux pkgconfig info instead of hardcoding
In-Reply-To: <1255338418.10932.38.camel@cerberus.int.fabbione.net>
References: <8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
	<afcb9c9c64ef9416639b7c508add1e519a62fbb7.1255002311.git.fdinitto@redhat.com>
	<20091008234450.GW3054@agk-dp.fab.redhat.com>
	<1255338418.10932.38.camel@cerberus.int.fabbione.net>
Message-ID: <20091012101838.GN19397@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Oct 12, 2009 at 11:06:58AM +0200, Fabio M. Di Nitto wrote:
> For the internal view, we can switch to use PKG_CONFIG inside our
> configure.in, but that means:
> 1) it will be a hard dependency (and we recently agreed to avoid that).
> 2) we assume that lvm2 developers and packagers will build/ship with
> recent enough build dependencies to guarantee working pkg-config files.
 
So any switch would still need a fallback for when pkgconfig is not
available.  (The real question is whether pkgconfig was generally
available some time before selinux or not.  If it was, then you can
argue that everyone with access to selinux also has access to pkgconfig.)

> For the external view, as it is now, we can create the correct .pc file.
> If we detect that selinux has pkg-config support, then we use the
> "Requires.private: libselinux" that will automatically expand via
> pkg-config. If we don't have selinux pkg-config, then we can hardcode as
> we do now.
 
Yes.

Alasdair


