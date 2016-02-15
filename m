From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 15 Feb 2016 10:49:03 +0000 (UTC)
Subject: v2_02_142 annotated tag has been created
Message-ID: <20160215104903.B53EC605CD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c7b8bc05f661105aeacac34813178c87bfefdb73
Commit:        c7b8bc05f661105aeacac34813178c87bfefdb73
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-02-15 10:35 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-02-15 10:35 +0000

annotated tag: v2_02_142 has been created
	    at c7b8bc05f661105aeacac34813178c87bfefdb73 (tag)
       tagging 228b8245e4fbae92968feeb8ded57697b567ceed (commit)
      replaces v2_02_141

Release 2.02.142.

28 files changed, 383 insertions(+), 229 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlbBqhcACgkQIoGRwVZ+LBdIkACg+zSPRaCCSfahIp5krxrsQNDa
gB4AoPi4oW/dsOsl8y/sL+NkS1QJCo2f
=3xtI
-----END PGP SIGNATURE-----

Alasdair G Kergon (2):
      post-release
      pre-release

David Teigland (1):
      lvmlockd: don't adopt locks from unused lm

M.H. Tsai (4):
      config: fix verbose type to int
      lvconvert: enable spare creation during conversion
      dm: fix thin-pool targer params order
      debug: cut_and_paste type in message

Ondrej Kozina (1):
      pvmove: fix possible memory pool corruption

Peter Rajnoha (5):
      filters: partitioned: fix partition table filter with external_device_info_source="udev" and blkid<2.20
      metadata: format: also delete bootloader areas from lvmcache when reading lvm1 and pool label
      filter: do not check for suspended devs in filter-usable in lvmetad mode
      conf: use use_blkid_wiping=0 if not defined in lvm.conf and support not compiled in
      man: pvresize: remove old comment about inability to resize PV with more mdas

Zdenek Kabelac (12):
      thin: fix low_water_mark threshold calc
      dm: alloc always 8byte aligned
      lvresize: check for given parameters
      cleanup: rename usepolicies
      cleanup: stripes_extents
      cleanup: relocate function to vg.c
      cleanup: drop unneeded assigns
      cleanup: update messages
      tests: check for automated dmeventd resize
      gcc: better code for older compiler
      tests: update test
      tests: indent


