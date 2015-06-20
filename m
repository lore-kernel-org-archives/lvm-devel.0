From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 20 Jun 2015 00:04:23 +0000 (UTC)
Subject: v2_02_122 annotated tag has been created
Message-ID: <20150620000423.EC76260EAA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b954451675ce88799e5bd03339201033a245a8cd
Commit:        b954451675ce88799e5bd03339201033a245a8cd
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2015-06-19 23:58 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2015-06-19 23:58 +0000

annotated tag: v2_02_122 has been created
	    at b954451675ce88799e5bd03339201033a245a8cd (tag)
       tagging 134b727b4f577c3e4b1a210e41d20136bc8bd876 (commit)
      replaces v2_02_121

Release 2.02.122.

36 files changed, 585 insertions(+), 229 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlWErK0ACgkQIoGRwVZ+LBfXuQCgpgDX9iPgKTcxMsytAxjgefOu
trgAoNXEjJOlFvacGMP1zPsPJBng7+e7
=aB5W
-----END PGP SIGNATURE-----

Alasdair G Kergon (2):
      post-release
      pre-release

David Teigland (9):
      lvmcache: mention lvconvert --cachemode
      xlate: add new variants
      Ignore hyphens in long option names
      Add the 's' activation mode
      man lvm: mention hyphens in option names
      man vgchange lvchange: mention activation option s
      lv_refresh: move the bulk of the function into lib
      Add a global get_cmd_name()
      libdaemon: move compare_config to lib

Peter Rajnoha (4):
      config: fix some settings incorrectly marked as CFG_DEFAULT_COMMENTED instead of CFG_DEFAULT_UNDEFINED and causing segfault
      filter: filter-usable: consider snapshot and origin LV as unusable if its component is suspended
      cleanup: || instead of |
      cleanup: missing target_type check in device_is_usable filter

Zdenek Kabelac (13):
      dmeventd: drop pthread_cancel
      dmeventd: drop stack
      dmeventd: better debug
      cleanup: drop double const
      libdm: better debug message
      debug: better tracing messages
      libdm: add dm_tree_node_set_thin_pool_read_only
      thin: drop limitation for extension of reduced thin volume
      thin: support unaligned size of external origin and thin pool
      display: drop allocation from display_lvname
      lvm: move hyphen mangling code
      log: flush stdout before print to stderr
      tests: external origin updates


