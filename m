From: Robert Schwebel <r.schwebel@pengutronix.de>
Date: Thu, 23 Dec 2010 11:04:37 +0100
Subject: [Buildroot] Release tarballs location
In-Reply-To: <20101222144901.5d2bb8c7@surf>
References: <20101222144901.5d2bb8c7@surf>
Message-ID: <20101223100437.GS4233@pengutronix.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello,

On Wed, Dec 22, 2010 at 02:49:01PM +0100, Thomas Petazzoni wrote:
> I am a contributor of Buildroot, a tool that allows to easily build
> embedded Linux systems. We create recipes to cross-compile software
> that are useful on embedded systems, and LVM2 is one of them.
>
> Unfortunately, it looks like when a release is made, the tarball is
> placed at ftp://sources.redhat.com/pub/lvm2/, but as once as a newer
> release is made, the previous tarball is moved into
> ftp://sources.redhat.com/pub/lvm2/old/. Unfortunately, this doesn't
> work well with how embedded Linux build systems work, since they code
> an URL and a version for each software they build. This is usually not
> a problem, since most of the software tarballs are available from a
> fixed location.
>
> Would it be possible to change the release tarball location policy in
> order not to move them ? If you really want to have only the latest one
> in ftp://sources.redhat.com/pub/lvm2/, could you also put the latest
> available version in ftp://sources.redhat.com/pub/lvm2/old/ at the
> moment of the release ?

I second Thomas' position - we have the same problem in PTXdist as well.

Robert
-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |


