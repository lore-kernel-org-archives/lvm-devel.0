From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 24 Jul 2015 22:39:08 +0000 (UTC)
Subject: v2_02_126 annotated tag has been created
Message-ID: <20150724223909.000D260EEF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f488bbb3dce8e5bccd7f89f7501706a0c5caa22c
Commit:        f488bbb3dce8e5bccd7f89f7501706a0c5caa22c
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2015-07-24 22:20 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2015-07-24 22:20 +0000

annotated tag: v2_02_126 has been created
	    at f488bbb3dce8e5bccd7f89f7501706a0c5caa22c (tag)
       tagging 33eb7d7dfb772c432251f0926f6a0fb8fb824772 (commit)
      replaces v2_02_125

Release 2.02.126.

83 files changed, 1687 insertions(+), 759 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlWyumkACgkQIoGRwVZ+LBeYXwCfcFW6vdZJ68vZpjlePKudbAyJ
XsIAn3rSLnlD1LeC1CDMpjKm1UlSFNHB
=BvSx
-----END PGP SIGNATURE-----

Alasdair G Kergon (8):
      post-release
      alloc: Fix lvextend failure when varying stripes.
      test: Ignore known concurrent VG clvmd failure.
      log: Add DM_ABORT_ON_INTERNAL_ERRORS lvm override.
      libdm: Use wrappers for all malloc functions.
      clvmd: Fix freeze if client dies holding locks.
      tools: Streamline long option hyphen removal.
      pre-release

Andy Grover (1):
      man: add lvmlocal.conf to config cascade

David Teigland (33):
      toollib: skip processing the sanlock LV unless named or all
      lvmlockctl: fix uninitialized names
      lvmlockd: fix unreachable code
      lvmlockd: remove log_error instances for normal conditions
      vgchange: don't disable VG lock in lock_stop
      coverity: cleanup related to lvmlockd
      metadata: vg_validate lock_args
      metadata: add comments describing lock_args for lvmlockd
      pvcreate: remove recent warning message
      vgchange: fix disallowed LV types in lockd VG
      metadata: fix duplicated LV flag
      lockd: disable part of lock_args validation
      lvconvert: disallow splitting in lockd VGs
      vgchange: allow changing to lockd type when mirrors exist
      lockd: note that external origins don't work in lockd VGs
      vgexport: do not allow lockd VG to be exported
      lockd: allow nolocking and readonly options
      lockd: allow vgexport and vgimport
      man lvmlockd: update method for changing lock type
      lockd: fix error message after a failing to get lock
      vgchange: fix lock-start filtering and waiting
      metadata: change function name to _allow_extra_system_id
      vgexport: fix the all VGs case
      vgimport: fix the all VGs case
      lockd: fix error cases when built without lvmlockd
      lvmlockd: improve errors when lvm is built without a lock manager
      vgchange/lvchange: enforce the shared VG lock from lvmlockd
      lvconvert: fix polling outside of core lvconvert
      lvconvert: merge polling fixes for lockd
      pvscan: skip autoactivation for lockd VGs
      lvmlockd: improve check for duplicate global locks
      Fix dehyphenation cases
      lockd: remove an unreachable global lock condition

Marian Csontos (6):
      spec: Update to use enable_lockd_*
      spec: Move lvm2-lockd into separate package
      test: Fix syntax error in prepare_devs
      lvmpolld: Fix segfault on 32 bit architectures
      test: Fix hardcoded /usr/share in testsuite
      test: Help, default and relative paths in runner

Ondrej Kozina (2):
      lvconvert: retain retcode consistency
      lvconvert: remove unused struct members

Peter Rajnoha (22):
      config: add find_config_tree_array
      config: replace find_config_tree_node with find_config_tree_array where appropriate
      coverity: fix resource leaks
      coverity: fix uninitialized values and other reported problems
      coverity: missing break in switch expression
      coverity: previous commit - not "break" but "fall through"
      coverity: fix missing initialization
      coverity: fix NULL check in lv->lvid.s
      lvmconf: fix ignored --startstopservices in lvmconf ... --mirrorservice on systemd
      coverity: fix possible invalid dereferences
      coverity: missing return value for dm_split_lvm_name pass proper DM name instead of NULL value
      coverity: missing return value checks
      libdaemon: config_make_nodes_v needs fixing
      config: {thin,cache}_{check,repair}_options are never undefined
      config: add "defaulting to" message in case we fall back to defaults in find_config_tree_array
      config: use find_config_tree_array for all arrays
      config: also log the value used if defined in config, not just defaults
      config: make a difference between "not found" and "is empty" in log msg for devices/preferred_names
      wiping: ignore errors during detection if use_blkid_wiping=1 and --force is used
      wiping: log_warn instead of log_error if blkid wipe ignored for a signature
      wiping: add "Wiping skipped." for the message context to be complete
      config: add CFG_SECTION_NO_CHECK flag

Zdenek Kabelac (11):
      coverity: fix regresions from 16e9b32c2f1
      tests: follow symlinks
      thin: fix warning for overprovisioning
      cache: move setting of cache policy
      cache: handle policy_name separately
      cache: capture missing policy name
      cache: enhance cache-pool validation
      makefiles: adding target for generating ctags
      cleanup: drop duplicated seg test
      cleanup: avoid double assign
      cleanup: drop unused header file


