From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 28 Nov 2015 01:35:29 +0000 (UTC)
Subject: v2_02_136 annotated tag has been created
Message-ID: <20151128013529.385FD60C8E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3a73164f53486e5c75a34f420c120ad2703ddcf8
Commit:        3a73164f53486e5c75a34f420c120ad2703ddcf8
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2015-11-28 01:28 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2015-11-28 01:28 +0000

annotated tag: v2_02_136 has been created
	    at 3a73164f53486e5c75a34f420c120ad2703ddcf8 (tag)
       tagging b4a3aaf910fc2216635c443deed5c26c535ab742 (commit)
      replaces v2_02_135

Release 2.02.136.

Another development release.  Do not ship this release.

36 files changed, 613 insertions(+), 529 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlZZAysACgkQIoGRwVZ+LBfh5wCfSVEnKWytXE0BvDHgkGEfiCiP
o8QAoIUBRoj6Te+eYC/mI5bYj4qK1sto
=wsdv
-----END PGP SIGNATURE-----

Alasdair G Kergon (2):
      post-release
      pre-release

David Teigland (1):
      man lvmcache: include chunk size

Peter Rajnoha (1):
      lvmconfig: add --sinceversion for --type new

Zdenek Kabelac (20):
      libdm: drop extra space from cache target line
      libdm: enhance thin-pool preload
      memlock: add more libs on ignore list
      thin: work with active thin-pool
      cleanup: move towards using direct LV pointers
      thin: skip detach preload from pools
      cleanup: use display_lvname
      tests: data correctness after thin-pool resize
      tests: improve teardown
      thin: fix previous update of partial tree building
      cleanup: rename vg_ondisk to vg_committed
      cleanup: change ondisk committed
      cleanup: rename lv_ondisk to lv_committed
      libdm: const raid params and error for unsupported type
      cleanup: avoid allocation for vg_name
      cleanup: remove unused code
      cleanup: using display_lvname
      debug: show LV name where dlid creation failed
      cleanup: clean gcc shadow declaration of version warning
      tests: make unit testing usable again


