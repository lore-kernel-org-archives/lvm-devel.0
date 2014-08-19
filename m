From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 19 Aug 2014 14:06:24 +0000 (UTC)
Subject: v2_02_109 annotated tag has been created
Message-ID: <20140819140624.A6E8161542@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=825573e72c7b7041d91702e3c82073a01b2ec6f9
Commit:        825573e72c7b7041d91702e3c82073a01b2ec6f9
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2014-08-05 01:08 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2014-08-05 01:08 +0000

annotated tag: v2_02_109 has been created
	    at 825573e72c7b7041d91702e3c82073a01b2ec6f9 (tag)
       tagging 9d4e1e51a944c07bad56fe41407b84afefb39357 (commit)
      replaces v2_02_108

Release 2.02.109.

Fixes for a few problems found in the previous release.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlPgLucACgkQIoGRwVZ+LBfizgCgz80ccvkw+PDz+5RT7j9my/gI
L18An1+9pnv/GHP8TW7jlxRFt/dQamQh
=Jh+N
-----END PGP SIGNATURE-----

Alasdair G Kergon (5):
      post-release
      activation: Fix upgrades using uuid suffixes.
      lvresize: Allow approximation with +%FREE.
      report: Remove lv_volume_type field.
      pre-release

Marian Csontos (1):
      test: Skip lvextend-thin when thin not available

Peter Rajnoha (2):
      metadata: remove spurious "Physical volume <dev_name> not found"
      filters: fix regression caused by commit e80884cd080cad7e10be4588e3493b9000649426

Petr Rockai (5):
      test: Add a test for lvextend -l+100%FREE of a striped thin pool.
      test: Add a test for lvscan --cache.
      lvscan: Make --cache impervious to already-missing devices.
      WHATS_NEW: lvscan --cache SEGV fix
      lvscan: Fix possible gcc warnings in --cache implementation.


