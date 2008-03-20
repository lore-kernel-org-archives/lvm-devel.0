From: Bryn M. Reeves <breeves@redhat.com>
Date: Thu, 20 Mar 2008 13:45:12 +0000
Subject: Posting a patch
In-Reply-To: <A78DB34D00374344A0AB65B6523C05DC02CDD316@marsden.win.datacash.com>
References: <A78DB34D00374344A0AB65B6523C05DC02CDD316@marsden.win.datacash.com>
Message-ID: <47E26A68.1040202@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Gerrard Geldenhuis wrote:
> I have written a small patch for the man page lvm.8 that I want to
> submit. However I am unsure whether I should be creating a diff with cvs
> or diff and then if I use either what type of diff needs to be
> submitted.

Hi Gerrard,

You can generate the patch either way - whichever you prefer. Either one
should be generated in unified diff format (-u). When I am taking
patches from CVS I normally do:

cd ~/cvs/LVM2
cvs diff -up 2>/dev/null > the.patch

The "-p" causes the diff to include the declaration for the function
being changed - very handy for patches to .c files but probably not
necessary for a man page patch.

Otherwise, I'd do something like:

cd LVM2/
diff -Nurp man/lvm.8.orig man/lvm.8 > the.patch

Again, the -Nrp options probably aren't needed for a man page patch but
that's what I use for generating most of my patches.

Regards,
Bryn.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFH4mpo6YSQoMYUY94RAibJAKDJq84LVcWj6EzgC8/PkzZAET7tJACfSBlD
tajy6BSeCkM1F+sM2LSsNyM=
=6w4B
-----END PGP SIGNATURE-----


