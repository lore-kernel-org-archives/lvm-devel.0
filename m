From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  9 Nov 2015 01:54:30 +0000 (UTC)
Subject: v2_02_134 annotated tag has been created
Message-ID: <20151109015430.17B8860DC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b67f6285b6ef68280dac05a08d147790eb78397b
Commit:        b67f6285b6ef68280dac05a08d147790eb78397b
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2015-11-09 01:46 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2015-11-09 01:46 +0000

annotated tag: v2_02_134 has been created
	    at b67f6285b6ef68280dac05a08d147790eb78397b (tag)
       tagging a3f77ed4ba4b6d35638f81cf9f58db2a730246e7 (commit)
      replaces v2_02_133

Release 2.02.134.

Another development checkpoint.

16 files changed, 1779 insertions(+), 343 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlY/+zYACgkQIoGRwVZ+LBfDqQCfa/W1/+VEKuqvFvDInCq4FfYD
l4gAnj4OoXpmpfuverE+9x1WInbXCuMb
=4Q2Y
-----END PGP SIGNATURE-----

Alasdair G Kergon (3):
      post-release
      mirror: Fix log size calc when more than 1 extent.
      pre-release

David Teigland (7):
      config: fix copy error in examples
      lvmetad: refactor and document
      tests: skip duplicate vg names test with lvmetad
      lvmetad: log duplicate PVs returned from lvmetad
      lvmcache: change log_verbose to log_warn
      vg_read: skip repair and wipe for foreign and shared VGs
      test: disable duplicate VG name test for lvmetad

Marian Csontos (3):
      spec: Add python bindings
      test: Run pytest with installed libs
      test: api subdirectory is needed in PATH by pytest


