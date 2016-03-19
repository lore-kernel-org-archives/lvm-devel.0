From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 19 Mar 2016 01:20:59 +0000 (UTC)
Subject: v2_02_147 annotated tag has been created
Message-ID: <20160319012059.BDEEA607B4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dc8010b173dcb764b805d700c6fd7a50ff941ba7
Commit:        dc8010b173dcb764b805d700c6fd7a50ff941ba7
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-03-19 01:14 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-03-19 01:14 +0000

annotated tag: v2_02_147 has been created
	    at dc8010b173dcb764b805d700c6fd7a50ff941ba7 (tag)
       tagging 0d4b6bdfc0bfc6939a70bd6ee4b15dad3cae09f5 (commit)
      replaces v2_02_146

Release 2.02.147.

Another development release with some minor fixes.

10 files changed, 114 insertions(+), 24 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlbsqC4ACgkQIoGRwVZ+LBdQdwCgpjzDN93H9BM2RmMY1HzCh0+b
9S8An0ZcmWi3V6RWHsEC1zR+ZkCLzJ2g
=EiFD
-----END PGP SIGNATURE-----

Alasdair G Kergon (3):
      post-release
      report: Use default  vg_name field width too.
      pre-release

Peter Rajnoha (2):
      fsadm: if available, use /proc/self/mountinfo to detect mounted volume
      fsadm: use stat to get major:minor pair for non-standard /dev layouts

Zdenek Kabelac (5):
      lvconvert: fix error path test
      tests: use own PID path for lvmetad checking
      tests: update lvconvert test
      lvresize: fix stacked resize
      tests: stacked resize of thin on raid


