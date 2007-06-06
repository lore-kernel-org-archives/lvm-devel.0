From: Bryn M. Reeves <breeves@redhat.com>
Date: Thu, 07 Jun 2007 00:01:56 +0100
Subject: [PATCH] allow filenames with vgcfgrestore -l
Message-ID: <46673CE4.4010801@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Simple patch to permit a metadata backup file to be specified on the
vgcfgrestore command line using -f when listing backups, for e.g.:

vgcfgrestore -l -f /tmp/VolGroup

LVM1 allowed this behavior and it's been requested a couple of times on
the mailing list.


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFGZzzk6YSQoMYUY94RAi+gAJ9xiDIQhdcV1a+78ko9TEaGijVTvgCgrag+
u1Fmzww3vn68W4AJ7CUvKfA=
=V+OQ
-----END PGP SIGNATURE-----
-------------- next part --------------
A non-text attachment was scrubbed...
Name: vgcfgrestore_list_file.patch
Type: text/x-patch
Size: 4080 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070607/c51132e8/attachment.bin>
