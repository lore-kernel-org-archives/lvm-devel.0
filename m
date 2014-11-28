From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 28 Nov 2014 23:11:22 +0000 (UTC)
Subject: v2_02_114 annotated tag has been created
Message-ID: <20141128231122.CE60A60FC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=95ae8022ff34337ff81d1e9829a970108bc19622
Commit:        95ae8022ff34337ff81d1e9829a970108bc19622
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2014-11-28 23:06 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2014-11-28 23:06 +0000

annotated tag: v2_02_114 has been created
	    at 95ae8022ff34337ff81d1e9829a970108bc19622 (tag)
       tagging e492861749195311cc71910aaacb084110a9ddbb (commit)
      replaces v2_02_113

Release 2.02.114.

19 files changed, 154 insertions(+), 36 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlR5AA4ACgkQIoGRwVZ+LBdbZACgpGyyHYDWMHIE7PswYHIssKZH
rdgAoLGvssqqpq/R8evtl78ExaX2MvqZ
=7bcm
-----END PGP SIGNATURE-----

Alasdair G Kergon (3):
      post-release
      libdaemon: Fix some client leaks.
      pre-release

Peter Rajnoha (5):
      pvresize: fix size in 'Resizing to ...' verbose message to show proper result size
      initscripts: fix typo in clvmd initscript causing CLVMD_STOP_TIMEOUT variable to be ignored
      coverity: remove dead code in lv_info_with_seg_status
      coverity: fix possible NULL dereference
      coverity: remove dead code in lv_info_with_seg_status (continued)

Petr Rockai (4):
      toollib: Fix uninitialised config value type in get_cachepolicy_params.
      metadata: Add cache_policy to lvcreate_params and honour it.
      lvcreate: Implement --cachepolicy/--cachesettings.
      Update WHATS_NEW.

Zdenek Kabelac (3):
      thin: add missing 64KB rounding
      makefiles: avoid regeneration of Makefile
      toollib: fix regression in parsing /dev/mapper/vg-lv


