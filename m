From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 17 Jun 2016 13:20:15 +0000 (UTC)
Subject: v2_02_157 annotated tag has been created
Message-ID: <20160617132015.6650060398@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3fbdd8be03f229121b6c2245721617a26b152618
Commit:        3fbdd8be03f229121b6c2245721617a26b152618
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-06-17 13:12 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-06-17 13:12 +0000

annotated tag: v2_02_157 has been created
	    at 3fbdd8be03f229121b6c2245721617a26b152618 (tag)
       tagging 38cc03605ceff43a8a7733b72ed9da94f9598e00 (commit)
      replaces v2_02_156

Release 2.02.157.

Just one change this week, so the boot isn't broken
if lvmetad is expected to be running but isn't
available.

7 files changed, 184 insertions(+), 36 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAldj918ACgkQIoGRwVZ+LBf5UACff1NWccZca44LPgtcUq0dhtTt
3Z0An0yzTCL/o00tnL4wEg+OfiGBdwWJ
=/2Yg
-----END PGP SIGNATURE-----

Alasdair G Kergon (2):
      post-release
      pre-release

David Teigland (4):
      lvmlockd: fix rescanning VG
      pvscan: do activation when lvmetad is not running
      pvscan: fix lvmlockd global lock
      pvscan: don't activate LVs when use_lvmetad=0

Peter Rajnoha (1):
      tools: add missing destroy_processing_handle in pvscan and vgreduce code


