From: Ian Stakenvicius <axs@gentoo.org>
Date: Thu, 08 Aug 2013 12:01:53 -0400
Subject: [PATCH] build-system fixes for --enable-static
In-Reply-To: <5203BFF4.2030005@gentoo.org>
References: <5203BFF4.2030005@gentoo.org>
Message-ID: <5203C0F1.2070305@gentoo.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

On 08/08/13 11:57 AM, Ian Stakenvicius wrote:
> The following patch fixes missing LDFLAGS from dependent packages
> when building lvm2 statically.  It also adjusts the build system
> for libselinux CFLAGS/LIBS, to attempt to grab them from pkg-config
> first.
> 


err.. oops. the first two lines of that file is cruft, please ignore
when evaluating the patch.  A cleaner attachment is below.  Sorry for
the second email.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iF4EAREIAAYFAlIDwPEACgkQ2ugaI38ACPCdaQD/bEHVd/Pdtvyd/YwW3pZCHqrN
qZbPHAVyhWtH23daoWgBALv+m+4YKNovLXp4sHJOQYsk9/CMvZ0S7djh2GYgt5OV
=VHZ/
-----END PGP SIGNATURE-----
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-2.02.99-static.patch
Type: text/x-patch
Size: 4287 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20130808/a0380b2b/attachment.bin>
