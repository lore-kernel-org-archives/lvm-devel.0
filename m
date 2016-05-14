From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 14 May 2016 01:12:47 +0000 (UTC)
Subject: v2_02_154 annotated tag has been created
Message-ID: <20160514011247.DD38B60FDB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=243e28d50aa071ed05774c4cd8b0187b3a087311
Commit:        243e28d50aa071ed05774c4cd8b0187b3a087311
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-05-14 01:01 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-05-14 01:01 +0000

annotated tag: v2_02_154 has been created
	    at 243e28d50aa071ed05774c4cd8b0187b3a087311 (tag)
       tagging 15ca5883fb7911d231a3931d085cc593eab95a39 (commit)
      replaces v2_02_153

Release 2.02.154.

A tiny update this week with a few fixes to some error paths.

12 files changed, 248 insertions(+), 197 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlc2eZkACgkQIoGRwVZ+LBcHCwCfUs34MeFDPf6L29ALrJfBCpPi
3F8AoNK9Rv7Igk66hfHnuakTQ3B2OJ0o
=aSIl
-----END PGP SIGNATURE-----

Alasdair G Kergon (5):
      post-release
      device:  Retry open without O_NOATIME if it fails.
      libdm: Show lib vsn even if driver vsn unavailable.
      lvmetad: Fix client error when socket access fails.
      pre-release

David Teigland (2):
      test: process-each-duplicate-pvs
      lib: fix init error handling

Peter Rajnoha (1):
      refactor: separate original _report fn into _report and _do_report fn


