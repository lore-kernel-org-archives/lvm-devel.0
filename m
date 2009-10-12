From: Bastian Blank <bastian@waldi.eu.org>
Date: Mon, 12 Oct 2009 12:45:10 +0200
Subject: [PATCH 08/11] debian: use selinux pkgconfig info instead of hardcoding
In-Reply-To: <20091012101838.GN19397@agk-dp.fab.redhat.com>
References: <8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
	<afcb9c9c64ef9416639b7c508add1e519a62fbb7.1255002311.git.fdinitto@redhat.com>
	<20091008234450.GW3054@agk-dp.fab.redhat.com>
	<1255338418.10932.38.camel@cerberus.int.fabbione.net>
	<20091012101838.GN19397@agk-dp.fab.redhat.com>
Message-ID: <20091012104510.GB4166@wavehammer.waldi.eu.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Oct 12, 2009 at 11:18:38AM +0100, Alasdair G Kergon wrote:
> So any switch would still need a fallback for when pkgconfig is not
> available.  (The real question is whether pkgconfig was generally
> available some time before selinux or not.  If it was, then you can
> argue that everyone with access to selinux also has access to pkgconfig.)

According to the Debian changelog, pkg-config was first usable in 2001,
long before selinux was even considered a good idea.

> > For the external view, as it is now, we can create the correct .pc file.
> > If we detect that selinux has pkg-config support, then we use the
> > "Requires.private: libselinux" that will automatically expand via
> > pkg-config. If we don't have selinux pkg-config, then we can hardcode as
> > we do now.
> Yes.

Well, libselinux at least ship the file since 1.28.

Bastian

-- 
No one may kill a man.  Not for any purpose.  It cannot be condoned.
		-- Kirk, "Spock's Brain", stardate 5431.6


