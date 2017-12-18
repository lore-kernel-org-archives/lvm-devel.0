From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 18 Dec 2017 15:54:00 -0500
Subject: v2_02_177 annotated tag has been created
Message-ID: <201712182054.vBIKs0sJ026390@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6c8c8b1b244fc6a6a27c4b3888844ad8a4750394
Commit:        6c8c8b1b244fc6a6a27c4b3888844ad8a4750394
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2017-12-18 20:36 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2017-12-18 20:36 +0000

annotated tag: v2_02_177 has been created
	    at 6c8c8b1b244fc6a6a27c4b3888844ad8a4750394 (tag)
       tagging a1f7a483253b11e52ad5460b28cf0c75dba26659 (commit)
      replaces v2_02_176

Release 2.02.177.

A wide-ranging bug fix and tidy-up release, covering in particular raid,
pvmove, activation and also switching to aligned 4k blocks when writing
out on-disk volume group metadata.

124 files changed, 3119 insertions(+), 2485 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlo4KDgACgkQIoGRwVZ+LBfTKwCgsJYQcXtiuHP5MWpJcCiZSDvZ
rVkAnRcOvGOnfkpwX7aFrKecuoxjqTyv
=KKDA
-----END PGP SIGNATURE-----

Alasdair G Kergon (31):
      post-release
      persistent filter: Skip import before rescan
      log: Improve various device-related messages
      metadata: Remove unused vg.cft_precommitted
      metadata: Eliminate redundant nested VG metadata
      log: Add io debug class
      regenerate man and conf
      lvmdiskscan: Remove unnecessary read.
      device: log debug when I/O bounce buffer used
      label: Remove unused verify functions.
      device: categorise block i/o
      device: Skip read-modify-write if replacing whole block.
      device: Tag I/O for each mda on a device separately in log messages.
      lvmetad: drop stray underscore
      format_text: Use explicit alignment in wrapping calc.
      format_text: Replace PRI with FMT.
      format_text: Log additional circular buffer information.
      format_text: Move metadata size checking into separate fn.
      format_text: Use absolute alignment to calculate metadata usage
      format_text: Adjust metadata alignment calculation.
      device: Internal error if writing 0 bytes to dev.
      metadata: Consistently skip metadata areas that failed.
      device: Fix an unpaired device close.
      format_text: Refactor and document metadata offset calculation.
      format_text: More refactoring of metadata offset calcs
      format_text: Change metadata alignment from 512 to 4096.
      format_text: Round size written up to multiple of 4096.
      format_text: Supply mempool directly to raw_read_mda_header.
      format_text: Separate out code paths for buffer wraparound
      format_text: Transfer circular buf alloc to device layer.
      pre-release

David Teigland (11):
      lvmlockd: retry on other sanlock errors
      lvmlockd: override unknown lock manager error numbers
      man: lvmlockd steps for changing lock type
      lvconvert: prevent combining split snapshots in shared vg
      lvmlockd: avoid blocking in sanlock_convert
      lvmlockd: recognize normal errors from sanlock_convert
      lvmlockd: improve error message for VG lock conflict
      lvmlockd: fix log print
      lvmlockd: use pool lock for tmeta access
      lvmlock: return an error if lvb cannot be written
      lvmlockd: clear coverity complaint

Eric Ren (1):
      clvmd: supress ENOENT error on testing connection

Heinz Mauelshagen (17):
      raid: reject conversion request to striped/raid0 on 2-legged raid4/5
      raid: reject message for 2-legged raid4/5 -> striped
      raid: correct raid6_n_6 -> raid5 convenience type
      test: avoid have_raid overhead
      test: additional avoid have_raid overhead
      raid: add validation checks for reshape flags
      raid: ignore --stripesize on raid4/5 conversion to 1 stripe
      test: new reshape test under io load
      test: disable new reshape test until target version 1.13.1
      lv_manip: allow extension on --nosync raid lv
      test: cleanup command
      test: reduce pv sizes, fix comment and stripe size
      test: add large tests skip option
      test: allow to succeed in the cluster
      deactivate_lvs: deactivate any missing RaidLV legs
      test: new raid tests
      test: fix trap adding proper teardown to previous, new raid tests

Marian Csontos (15):
      test: Rename test nothing methods
      test: D-Bus test_nesting requires filter
      Update WHATS_NEW
      tests: Fix common_dev_ argument handling
      Update WHATS_NEW
      Update WHATS_NEW
      configure: applib is not required by dbusd
      lvmdbusd: Fix path to python3
      configure: Fix deprecation warning for lvmapp
      test: lvmdbusd is used for process name
      lvmdbusd: All tools use detected python3
      test: Fix condition when detecting lvmdbusd
      docs: Add TESTING file
      lvmdbusd: Make lvmdbusd executable
      lvm2app: Suppress deprecation warnings for our builds

Ondrej Kozina (2):
      dmsetup: hide integrity encryption keys on table output
      test: check dmsetup hides integrity encryption keys

Zdenek Kabelac (91):
      snapshot: prevent repeated merging
      coverity: avoid memleak
      coverity: avoid overflow_before_widen
      blkdeactive: use /sbin for mdamd
      shellcheck: fsadm cleanup
      cleanup: gcc const warning
      cleanup: update messages in lvconvert
      cleanup: drop unneeded headerfiles
      coverity: add some initilizers
      tests: snasphot merging
      lvconvert: update delaying message
      tests: have some space for 2nd mda
      tests: detect racy systemd version
      tests: allow to proceed futher with test
      raid: protect raid4 activation
      cleanup: constify lv parameter
      cleanup: remove stack tracing for ok path
      reload: do not take backup with suspended devices
      lvremove: for unused cache deactive sublv
      lv_lock_holder: unused cache-pool is not lock holder
      tests: use nonflusing status
      pvmove: snapshots need to go with origin device
      pvmove: return pvmove itself
      layers: collect only lock holding LVs
      activate_lvs: deactivate on uniterate
      activation: check subLV before skipping resume
      activation: suspend pvmove using lv.
      pvmove: always flush when working with pvmove tree
      activate_lvs: use exclusive activation
      cleanup: update log messages
      pvmove: change locking on finish
      pvmove: activation changes
      pvmove: remove unusued code
      tests: pvmove supports more cases
      suspend: handle start of pvmove
      resume: secure critical section
      locking: pvmove is locking holding LV
      libdm: preload propagates delayed resume
      mirror: use lv_update_and_reload_origin
      activation: automaticaly discover pvmove holders
      pvmove: finish no longer needs explicit resumed
      toollib: avoid printing default stripe size
      cache: use conditional in warning message
      cleanup: reduce couple debug lines
      cleanup: using max args consistently
      cleanup: update error messages
      tests: typo
      tests: more places where missing should not appear
      activation: enhance holders detection
      pvmove: enhance delayed_resume logic
      toollib: improve stripes args reading
      cmdline: avoid overrun on very large numbers.
      cleanup: reuse existing macro
      pvmove: move code from tools to lib
      pvmove: add missing segment merging
      activation: split priority from memory locking
      activation: extend resume validation
      activation: avoid rechecking pvmove node
      suspend: optimize generated list
      cleanup: simplify _deps code
      cleanup: remove debug code
      libdm: watch for failing _info_by_dev
      libdm: support for replicator target is dropped
      cleanup: drop unused header
      cleanup: futher code reduction
      cleanup: simplier error message
      cleanup: drop impossible test case
      cleanup: mark success at the end
      cleanup: stack tracing
      cleanup: use _node_name
      clenaup: use log_warn
      cleanup: use log_warn
      cleanup: use existing define with prefix
      cleanup: drop unused define
      cleanup: messsage cleanup
      cleanup: drop unneeded check
      activation: also lock memory for clustered locking
      thin: always clear memory before parsing status
      thin: missing type is error
      libdm: add help func _get_last_load_segment
      libdm: avoid checking status on activation
      libdm: use delay_resume_if_extended
      libdm: drop extra structure copy
      cleanup: reorder calling of pool checking tools
      cleanup: use log_warn
      debug: update debug msg
      vgchange: drop extra counting
      activation: keep priority till memlock_unlock
      thin: regression fix for metadata checking
      cleanup: switch to standard query
      cleanup: debug message


