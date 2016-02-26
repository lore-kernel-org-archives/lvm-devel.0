From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 26 Feb 2016 21:14:39 +0000 (UTC)
Subject: v2_02_144 annotated tag has been created
Message-ID: <20160226211439.8DE0A605F3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=68cfdd55335d6f8af8e00ec559353a2fbafb683a
Commit:        68cfdd55335d6f8af8e00ec559353a2fbafb683a
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-02-26 21:04 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-02-26 21:04 +0000

annotated tag: v2_02_144 has been created
	    at 68cfdd55335d6f8af8e00ec559353a2fbafb683a (tag)
       tagging 731a9c1354481524a5d8674f10f0ca57c503c655 (commit)
      replaces v2_02_143

Release 2.02.144.

Another development release - recent interface changes are not yet frozen.

322 files changed, 3212 insertions(+), 1389 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlbQvf0ACgkQIoGRwVZ+LBdxKwCggAq4Adeq0NXrfHxALe37Q4T3
M/8AoNXdvyGP/BE97ZXtRyKPZdDUKA2P
=NZ11
-----END PGP SIGNATURE-----

Alasdair G Kergon (4):
      post-release
      configure
      report: Shift (u)sed pv_attr under (a)llocatable.
      pre-release

Bryn M. Reeves (8):
      dmstats: create dmstats symlink in test/lib
      tests: add basic dmstats tests
      tests: add driver_at_least() to aux.sh
      tests: add template tests/shell/dmstats-create.sh
      tests: install does not depend on lib/version-expected
      tests: make lib/expected-version-dm a dependency of .tests-stamp
      tests: add dmstats create tests
      tests: add simple dmstats report tests

David Teigland (28):
      test: add make check_lvmlockd_test
      lvmlockd: invalidate name in lockspace struct after remove
      tests: fix clean up after lvmlockd tests
      tests: add SKIP_WITH_LVMLOCKD
      tests: updates for check_lvmlockd
      lvmlockd: set default result value
      lvmlockd: fix sparse snapshot case
      tests: include lvmlockd in default make check
      lvmlockd: use new sanlock flag to avoid blocking
      configure: require sanlock 3.3.0
      vg_write: add list of pvs to write
      metadata: refactor part of add_pv_to_vg
      metadata: use pv_write_list for _check_old_pv_ext_for_vg
      vgconvert: refactor to avoid pvcreate code
      toollib: add two phase pv processing code
      pvcreate: use the common toollib pv create
      vgextend: use the common toollib pv create
      vgcreate: use the common toollib pv create
      liblvm: replace pvcreate_single with pvcreate_vol
      toollib: remove unsed pvcreate params function
      pvremove: use common toollib processing code
      metadata: add fixme about code used only by liblvm
      redefine pvcreate structs
      replace pvcreate_params with pvcreate_each_params
      pvcreate: fix setting uuid arg
      Use a common message for a used PV
      pvcreate: fix error from pv_write
      pvcreate: fix data alignment error check

Marian Csontos (3):
      spec: Fix 04ab1fa572bb: Remove left-overs
      lvmdbusd: Fix make install for python >= 3.5
      make: Add check_lvmlockd_* targets to top-level

Peter Rajnoha (1):
      lvmcache: fix missing free of vginfo->system_id causing mem leak

Tony Asleson (10):
      lvmdbustest.py: Make executable
      lvmdbusd: background.py, fix stdout parse error
      lvmdbus: Make unit tests work in test env
      lvmdbusd: Add env variable to use session bus
      lvmdbusd: Remove unlimited retries
      lvmdbusd: Initial unit test driver script
      lvmdbusd: Reduce unnecessary state refreshes
      lvmdbustest.py: Move helper code to testlib.py
      lvmdbusd testing: Add validatestate.py utility
      lvmdbusd: Do only 1 refresh for Vg.Change()

Vratislav Podzimek (1):
      dbus: fix the systemd service providing the DBus service

Zdenek Kabelac (38):
      lvmetad: fix error path
      libdm: grow with initialized struct content
      cleanup: libdm clang warnings
      cleanup: indent changes
      cleanup: use char arrays.
      tests: skip thin-flags test on 32bit el6 kernel
      thin: fix read size compare
      cache: enforce header check
      gcc: cleanup some sign warnings
      cleanup: drop double ;
      pvremove: add warn when removing PV in use
      gcc: cleanup  Wunused-const-variable
      gcc: logical-op warning go away
      tests: check warn about belong is printed
      libdm: fix string boundary
      coverity: drop unneeded header
      coverity: check for info pointer existance
      coverity: check for zero length buffer
      coverity: drop unused assignments
      coverity: ensure non-null pointers are used
      coverity: check cmd pointer exists
      coverity: check for dm_snprintf
      coverity: use same arithmetic for both major and minor
      coverity: ensure thin_pool_seg is not NULL
      cleanup: use braces around macro params
      cleanup: use sizeof instead of macro.
      lvresize: fix regression with zero size arg
      lvconvert: fix vg parameter
      lvconvert: simplify handler processing
      lvconvert: use more display_lvname
      lvconvert: use lp->repair
      cleanup: poll better check for internal errors
      cleanup: indent
      cleanup: drop unneeded test
      tests: lvresize with zero arg
      makefiles: add more dirs for lcov output
      coverity: helping coverity with NULL pointer
      tests: skip on older version


