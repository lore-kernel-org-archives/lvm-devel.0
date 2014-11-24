From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 24 Nov 2014 17:49:40 +0000 (UTC)
Subject: v2_02_113 annotated tag has been created
Message-ID: <20141124174940.697D26102F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0c55275fc53c301dc2d7ad1dd5cc114f17b2a318
Commit:        0c55275fc53c301dc2d7ad1dd5cc114f17b2a318
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2014-11-24 17:47 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2014-11-24 17:47 +0000

annotated tag: v2_02_113 has been created
	    at 0c55275fc53c301dc2d7ad1dd5cc114f17b2a318 (tag)
       tagging 2aca8347243b64751a98052d1a9801b489d48c4c (commit)
      replaces v2_02_112

Release 2.02.113.

65 files changed, 1630 insertions(+), 805 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlRzb0YACgkQIoGRwVZ+LBe87gCcDA5FE38HDPu25TwU7okNjWFs
hnAAoLfRTjpQDCtFsbWeaB5ORe4afEBS
=hcG0
-----END PGP SIGNATURE-----

Alasdair G Kergon (3):
      post-release
      pvck: Use non-zero exit status after failure.
      pre-release

David Teigland (4):
      lvmcache.7: remove unwanted line continuation syntax
      lvmcache: remove unnecessary line break syntax
      toollib: fixes and cleanup of recent changes
      toollib: improve ignore_vg case in _process_pvs_in_vgs

Peter Rajnoha (15):
      coverity: fix resource leaks
      coverity: remove redundant condition
      coverity: fix compiler warning
      coverity: fix possible integer overflow
      coverity: fix possible dereference of NULL pointer
      coverity: commit ba2302346 - report log_sys_error properly
      cleanup: cleanup internal interface to acquire segment status
      cleanup: unify LV info and LV segment status reporting in combination with LVS, SEGS and PVSEGS reporting
      cleanup: free mempool memory used for LV status in PVSEGS reporting
      configure: make configure --enable-udev-systemd-background-jobs only for systemd >= 205
      configure: expand prefix and exec_prefix directly in configure
      systemd: clvmd and cmirrord systemd unit - use usrsbindir instead of sbindir
      revert: 7639eae and 4a52a92
      report: add some comments about how string list is stored internally
      report: add some comments about how string list is stored internally

Petr Rockai (17):
      memlock: Make malloc reserve more robust against glibc tricks.
      libdm-config: Allow paths (section/key = value) in config files.
      libdm-config: Re-link config trees to reflect file order of keys/sections.
      libdm-config: Implement dm_config_flatten.
      libdm-config: Interpret barewords after '=' as strings.
      libdm-config: Implement dm_config_remove_node.
      libdm-config: Warn about duplicate keys.
      cache: Add lv_cache_setpolicy to cache_manip.c.
      toollib: Add --cachepolicy and implement get_cachepolicy_params.
      lvchange: Accept --cachepolicy.
      test: Add a test for lvchange --cachepolicy.
      toollib: Split --cachesettings from --cachepolicy.
      cache: Implement 'default' as a policy settings value to clear the record.
      test: Also test repeated --cachesettings in lvchange-cache.
      Update WHATS_NEW.
      man/lvm.conf: Update to reflect changes in config parser.
      man/lvchange: Mention --cachepolicy and --cachesettings.

St??phane Aulery (2):
      man: fix (\+) syntax warning of Groff
      lvconvert.8: fix bold and italic syntax mistake

Zdenek Kabelac (49):
      cache: fix clean_tree
      cache: improve pending_delete
      pool: fix removal of pool metadata spare
      cleanu: drop duplicate const
      cache: wrong feature in seg is internal error
      reporter: drop mem on error path
      lvm2api: use fully initilized struct
      cleanup: validate pointers
      cleanup: remove unused headers
      vg_read: use new error flag
      toolib: fix ignore_vg
      vg_read: correct warning
      cleanup: add '.' to log messages
      debug: better message for pool zeroing state
      debug: switch to verbose
      tests: explicit raid sync
      toollib: ignore_vg() with skip is not locked
      tests: skip another older kernel from raid456
      tests: reduce number of sync waiting
      tests: thin repair testing
      tests: deactivate repaired before swap
      locking: rename LCK_CONVERT
      cleanup: drop unused var
      man: lvchange update
      man: blkdeactivate help output
      man: clvmd help output
      man: clvmd updates
      thin: fix error path
      tests: prepare control node before clvmd
      tests: use snapshot targets
      toollib: release vg on ignore path
      cache: check for internal error
      cleanup: drop unused vars
      configure: fix CLVMD_PATH location
      dev_manager: fix mknodes
      makefiles: standard usage of make.tmpl
      libdm: fix reporting of empty string list
      tests: use old virt snaps in the test
      tests: reduce thin test
      pool: prevent pool conversion with same name
      libdm: report fix memleak on error path
      cleanup: warning: declaration of 'remove' shadows a  global declaration
      cleanup: add missing error path check
      libdm: there is no element in item 0
      man: fix pages for generators
      lvconvert: earlier detection of conflicting names
      tests: use proper LVMTEST prefix for VG name
      man: update
      cache: comment out unsupported pooldatasize


