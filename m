From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  1 Sep 2014 00:58:23 +0000 (UTC)
Subject: v2_02_111 annotated tag has been created
Message-ID: <20140901005823.0C6A060324@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a92570c639c892093d73951262428fb276475632
Commit:        a92570c639c892093d73951262428fb276475632
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2014-09-01 00:52 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2014-09-01 00:52 +0000

annotated tag: v2_02_111 has been created
	    at a92570c639c892093d73951262428fb276475632 (tag)
       tagging fcb433abec7c3ed7919fcc6688988e2225e83f40 (commit)
      replaces v2_02_110

Release 2.02.111.

14 files changed, 39 insertions(+), 24 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlQDw3AACgkQIoGRwVZ+LBd6xwCgmz6khkzvIhZ0o9Q1n09gq+KR
x7MAmwURpuaKrYtbTa0yOOQn59pUCZXM
=XuFG
-----END PGP SIGNATURE-----

Alasdair G Kergon (3):
      post-release
      lvextend: Reinstate --nosync logic for mirrors.
      pre-release

Jonathan Brassow (1):
      cache: Clean-up error message.

Zdenek Kabelac (10):
      cache: fix allocation size
      WHATS_NEW
      libdm: revert incorrect path length size for sscanf
      WHATS_NEW_DM
      clvmd: use correctly sized buffers for sscanf
      WHATS_NEW
      makefiles: include path missing
      cleanup: assignment into ()
      cleanup: drop duplicate const
      cleanup: drop extra ()


