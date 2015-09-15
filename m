From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 15 Sep 2015 13:09:41 +0000 (UTC)
Subject: v2_02_131 annotated tag has been created
Message-ID: <20150915130941.4CCAD60FE5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=10619ffc87ca3f7c3e2bc9cb7ecafb692d13b2d8
Commit:        10619ffc87ca3f7c3e2bc9cb7ecafb692d13b2d8
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2015-09-15 12:18 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2015-09-15 12:18 +0000

annotated tag: v2_02_131 has been created
	    at 10619ffc87ca3f7c3e2bc9cb7ecafb692d13b2d8 (tag)
       tagging a729b1aa294ab4525e09c83f392560bcf59a5b81 (commit)
      replaces v2_02_130

Release 2.02.131.

66 files changed, 2457 insertions(+), 1719 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlX4DKAACgkQIoGRwVZ+LBdiTQCg7ot+g1jnQcLU26on6n6NfNJC
btUAoPBnpR9WaSm0r0dkbrC/L8XBlkF5
=axmX
-----END PGP SIGNATURE-----

Alasdair G Kergon (4):
      style: Standardise some error paths.
      post-release
      man: Add all_man Makefile target.
      pre-release

Bryn M. Reeves (9):
      dmsetup: fix bounds leak in _do_stats_create_regions()
      libdm: add missing error handling in _stats_parse_histogram()
      libdm: check dm_pool_begin_object() return value.
      libdm: handle pool errors in dm_histogram_to_string()
      libdm: fix dm_stats leak in dm_stats_create()
      libdm: only free the first histogram explicitly (Coverity)
      libdm: clean up _build_histogram_arg()
      libdm: fix display of nsec suffixes in histogram strings
      libdm: clean up stats local variable use

David Teigland (13):
      man lvmlockd: mention device used for first vgcreate
      man lvmlockd: fix typo
      vgchange: lock-stop only needs shared lock
      lockd: add start_init arg to lockd_start_vg
      lvmlockd: rename ADOPT_CLIENT_ID
      lvmlockd: flag for internal actions
      lvmlockd: check all variations of lvb values
      lockd: fix rescanning VG metadata
      lvmlockd: optimize dlm global lockspace creation
      lvmlockd: remove shortcut for lockspace thread cleanup
      lvmlockd: prevent vgremove of dlm VG while lockspace is used
      man lvmlockd: move and update text about vgremove
      vgcreate: initialize new PVs only in first vg_write

Peter Rajnoha (3):
      filters: make sure regex filter is evaluated before any filter that needs disk access
      WHATS_NEW: commit b77497cbd86a854add3ffa4ce09a35f165c0d2ba
      dev-cache: ignore persistent cache if configuration changed

Zdenek Kabelac (34):
      configure: relocate generated headers
      configure: support --disable-dependency-tracking
      configure: simpler version reading
      configure: regenerate
      makefiles: deps depends on header links
      makefiles: do not generate tags for everyone
      tests: update install rules
      specs: package lvmlockctl man page
      cleanup: assign seg_name once
      specs: install lvmlockctl only when built
      tests: skip raid testing on 4.[1,2] fc24 kernels
      makefiles: ensure no old .h are left
      tests: better check for compiled version
      tests: ensure dd flushed all data before exit
      lib: when moving segtypes, move LV bits
      cache: warn if caching causes troubles
      cache: disallow stripes/size for cache pool
      tests: check cache stripe and raid behavior
      tests: fix check lv_not_exist
      tests: remove only existing loops
      spec: upgrade
      configure: correct message
      configure: relocate configure.h
      thin: lvconvert use passed PVs for _pmspare
      thin: improve swapping of identifiers
      pool: validate pool_metadata has proper suffix
      makefiles: distclean missing files
      tests: new thin tests
      tests: wait for sync before deactivation
      vgimporeclone: use correct cache dir path
      libdm: no validate for pool without messages
      thin: show message on error path
      tests: lvextend of full thin pool
      tests: early check for snapshot-merge


