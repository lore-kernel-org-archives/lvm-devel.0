From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon, 18 Jun 2018 01:49:37 -0400
Subject: v2_02_179 annotated tag has been created
Message-ID: <201806180549.w5I5nboU002099@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f426de669957e39d62ad26748b9e6704571f7456
Commit:        f426de669957e39d62ad26748b9e6704571f7456
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2018-06-18 05:22 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2018-06-18 05:22 +0000

annotated tag: v2_02_179 has been created
	    at f426de669957e39d62ad26748b9e6704571f7456 (tag)
       tagging 6283f5ea3f33fa022ec1f25baba630cbc5fdd1c5 (commit)
      replaces v2_02_178

Release 2.02.179

Bug fix release, fixing mostly problems with cache a lvmlockd.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJbJ0H2AAoJELkRJDHlCQOfCrQP/iWdSFUtDn2qnL5k6PMjV+co
iVVd0PAkMkbra6Xesxhz6tePAV6WyYdswQmdgGKhnko/BtjuO88kFjEriLqS0sux
YRakjqoXKOW7RZgTeEowYeGQX1Rxl0Oos/xG/KJRVS0O3/QAojQsOeQ6VSdpvlKV
10g/G2/pdIxa9bwMOlQMKQAJnoS8bRJ4+4W8c5wFNJi2OZLcPyoSQYwiLDpeUhYo
xqJlgnzvkqEfaMg/INpdWgqvpC0slXcV2I7fNvqZdEQTgFdSLjncGRB3lWR4Pl4A
f0/rLGgtOpCW48zNgUxpdx1TYOEf45OOXINfy8M/R8D1yoa1f3r1b6IRfrM+kXN4
Kv7q2TDfleO92nZ3xPyPVx3bLsX555sFLqK6OnKxoKHcHTLM+A6Qtdvd2I/xmZQv
TmUCmp+CGsmMx/IwWF9Buoq67hXeGn9YDiOK1bkVcKOr8p5Gp++2pN2yN8f1Kb83
Qi7HGWQf/P+Ya6+qf/BqFnWxy7BNstUXCRJ7cZdmiMiSB5oWNxrABopID/QfIcXo
B8tPm49P3N7U3dBrzl0Dz4KiK9B3MKOBx2AtvSkctXYOPrbOMOe20oOfBPj6XnD9
OaHqKvB8u+gVgonFf/oiuoEsQD95EYYZc3IFYOGJ0fb5dCTje4CkVVSujUyopU00
I5X+Y5te3LGivWIVZfNn
=M1dD
-----END PGP SIGNATURE-----

Alasdair G Kergon (1):
      format_text: Use versionsort to sort archive files

David Teigland (42):
      scan: refresh paths and retry open
      scan: removed failed paths for devices
      tests: fix skipping logic for lvmpolld and lvmlockd
      tests: some missed skip with lvmlockd
      lvmlockd: accept repeated global lock requests
      tests: separate lvmlockd tests with or without lvmetad
      lvmlockd: do not use an LV lock for some lvchange options
      config: revert to normal locking when no cluster
      lvmlockd: enable mirror split and merge with dlm lock_type
      lvmlockd: enable lvcreate of thin pool and thin lv in one command
      lvmlockd: enable creation of cache pool with lvcreate
      tests: enable lvmlockd for passing tests
      tests: vgcreate-usage update for lvmlockd
      tests: vgchange-usage update for lvmlockd
      lvmlockd: fix vgimportclone of a shared VG
      pvremove: skip lvmlockd locks for forced clearing
      tests: process-each-duplicate-pvs update for lvmlockd
      tests: add missing file
      lvmlockd: enable repairing shared VG while reading it
      tests: enable vg repair tests with lvmlockd
      tests: enable pvmove-restart with lvmlockd
      lvmlockd: enable lvcreate of new LV plus existing cache pool
      tests: enable lvcreate cache tests with lvmlockd
      tests: change lvcreate syntax to allow lvmlockd
      vgs: add report field for shared
      lvmlockd: enable lvcreate -H -L LV
      tests: enable lvmlockd with tests using lvcreate -H -L LV
      tests: enable metadata-balance with lvmlockd
      lvmlockd: fix reverting new lv in error path
      tests: enable lvcreate-pvtags with lvmlockd
      lvmlockd: improve error message for existing lockspace
      tests: enable more working tests with lvmlockd
      tests: enable non-working tests with lvmlockd
      man lvmlockd: update list of limitations
      devices: clean up io error messages
      lvmlockd: fix missing lock_type null check
      man lvmlockd: remove unnecessary reference to lvmetad
      lvmlockd: skip repair lock upgrade for non shared vgs
      WHATS_NEW for recent changes
      lvmlockd: update method for changing clustered VG
      man: updates to lvmlockd
      man: update lvmsystemid wording

Joe Thornber (8):
      radix_tree: add remove method
      radix_tree_t: knock out some debug
      data-struct/radix-tree: pass the value dtr into create.
      Merge branch '2018-05-29-radix-tree-iterate' into 2018-05-23-radix-tree-remove
      radix-tree: call the value dtr when removing an entry.
      radix-tree: radix_tree_remove_prefix()
      radix-tree: radix_tree_iterate()
      radix-tree: fix some bugs in remove_prefix and iterate

Marian Csontos (5):
      post-release
      Merge remote-tracking branch 'origin/master'
      post-release
      Merge branch 'dev-mcsontos-release' into stable
      pre-release

Zdenek Kabelac (2):
      man: another missed typo for thin plugin
      tests: improve usability on older systems


