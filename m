From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 28 Jun 2017 12:01:42 -0400
Subject: v2_02_172 annotated tag has been created
Message-ID: <201706281601.v5SG1gpo008371@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=115d3236a2c5283a0b312d19d1becf55c459d3ae
Commit:        115d3236a2c5283a0b312d19d1becf55c459d3ae
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2017-06-28 15:39 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2017-06-28 15:39 +0000

annotated tag: v2_02_172 has been created
	    at 115d3236a2c5283a0b312d19d1becf55c459d3ae (tag)
       tagging 08ce545449a7076965e153e6a9df1c49f833d33e (commit)
      replaces v2_02_171

Release 2.02.172

This release is another development checkpoint which addresses, in
particular, some problems with backwards compatibility of the recent
on-disk metadata extensions and improves some raid device handling.
Please again use this release only for testing and report problems
you discover.

155 files changed, 3197 insertions(+), 961 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAllT0SMACgkQIoGRwVZ+LBe2AgCg2DdRNixiRbO3AwnBIBADsEo/
DhAAoIconhw6mtNdlGfyhiRGKEHw9VQa
=Ul+a
-----END PGP SIGNATURE-----

Alasdair G Kergon (10):
      post-release
      metadata: Fix metadata repair when devs still missing.
      lvcreate: Fix mirror percentage size calculations.
      lvcreate: Fix last commit for virtual sizes.
      format_text: More internal errors if given invalid internal metadata
      metadata: Unlock VG on more _vg_make_handle error paths
      raid: Drop unnecessary/incorrect use of dm_pool_free
      log: fix message prefix truncation
      man: regenerate
      pre-release

Bryn M. Reeves (5):
      dmfilemapd: clear filemap_monitor before calling _parse_args()
      dmfilemapd: always initialise 'same' local variable (Coverity)
      libdm: allow truncated files in dm_stats_update_regions_from_fd()
      dmfilemapd: update file block count at daemon start
      dmfilemapd: do not wait if file has been truncated

David Teigland (26):
      man lvmlockd: minor wording updates
      commands: check for memory failures
      man pvchange: add description for --all
      man pvchange: mention one option is required
      man vgimport: add description for --all
      man pvscan: add description for --activate
      pvscan: define command as taking only -aay
      man lvm.conf: say how to get a description of settings
      man: reference other man pages with bold
      man clvmd: mention lvmlockd is another option
      man lvm fullreport and lvpoll references
      man vgexport: reference to vgimport
      man lvmconfig: add descriptions for typeconfig and ignorelocal
      lvcreate: cachemode writeback and cachepolicy cleaner is invalid
      WHATS_NEW: cache pool options
      man lvmetad: mention repair as a reason for disabling
      vg_read: check for NULL dev to avoid segfault
      man lvmcache: add info about metadata formats
      config: keep description lines under 80
      lvchange: allow changing properties on thin pool data lv
      man lvmraid: indirect conversions
      man lvmraid: add more indirect conversion info
      man lvmsystemid: change some wording
      add comment about PV in-use repair
      disable repairing in-use flag on orphan PVs
      print warning about in-use orphans

Heiko Becker (1):
      configure: search for (a possibly prefixed) ar

Heinz Mauelshagen (25):
      test: add missing yes option to lvconvert stripe removal
      lvconvert: enhance automatic settings of possible (raid) LV types
      lvconvert: fix indent and typo in last commit
      lvconvert: fix logic in automatic settings of possible (raid) LV types
      Fix typo
      Proper dm_snprintf return checks
      lvconvert: reject changing number of stripes on single core
      lvconvert: choose direct path to desired raid level
      lvconvert: reject RAID conversions on inactive LVs
      raid: add reshape segtype flag support
      lvconvert: fix detached SubLV deactivation in cluster
      raid: change reshape segtype flags
      Revert "lvconvert: reject changing number of stripes on single core
      raid: adjust reshape feature flag check
      lvconvert: disable reshaping of RAID LVs in the cluster
      lvconvert: disable conversion of RAID LV under snapshot
      lvconvert: enhance message
      lvconvert: disable reshaping of open RAID LV
      lvconvert: enhance disable reshaping of open RAID LV
      lvconvert: check open count to disable reshaping of open RAID LV
      raid: provide clickable URL BZ references
      raid: avoid explicit activation of SubLVs on reshape/takeover
      lvconvert: provide better reshape reject message for open RaidLV
      raid: fix segfault
      mirror: reformat conditional

Jonathan Brassow (8):
      lvconvert:  linear -> raid1 upconvert should cause "recover" not "resync"
      lvconvert:  Don't require a 'force' option during RAID repair.
      RAID (lvconvert/dmeventd):  Cleanly handle primary failure during 'recover' op
      lvconvert: Disallow removal of primary when up-converting (recovering)
      clean-ups:  remove unused var, add 'static' for local fn, adjust test
      clean-up:  Very picky update to comment - hopefully making it clearer
      test: New test file for validating kernel status during sync ops
      test: New test file for validating kernel status during sync ops

Marian Csontos (9):
      test: Update condition for changing RAID regionsize
      test: Fix previous commit - skip only RAID6 part
      test: Fix skipped cleanup
      test: Fix condition
      lvmdbusd: Fix notify_dbus mangling config option
      lvmdbusd: Fix missed rename
      spec: Enable notify-dbus in builds with dbus
      test: Use _pv suffix for nested devices
      test: Fix dbus testing using testsuite

Tony Asleson (5):
      lvmdbustest.py: Add PV symlink testing
      lvmdbusd: Correct PV lookups
      lvmdbusd: cmdhandler.py vg_reduce, remove extranous '--all'
      lvmdbusd: Add background command to flight recorder
      lvmdbusd: Prevent stall when update thread gets exception

Zdenek Kabelac (112):
      dmeventd: restore multiple warnings
      fsadm: fix test of subshell return value
      fsadm: some cleanup
      fsadm: all path define MAJOR MINOR
      tests: better skip
      fsadm: always detect mounted fs with extX
      fsadm: enhance detection of already mounted volumes
      tests: catch some fsadm tricky paths
      fsadm: avoid hidden --yes
      tests: fix test for fsadm
      tests: wait for raid in sync
      cleanup: bad flag is internal error here
      cleanup: separate type and mask
      cleanup: backtrace
      flags: add read and print of segtype flag
      flags: add segtype flag support
      flags: restore same logic with MISSING
      flags: improve unknown flags logic
      tests: also check new flag with segtype
      tests: drop extra debug vvvv
      tests: missed to export lvm binary for fsadm
      tests: skip reshaping raid10
      tests: add some extra udev waits
      tests: longer delay
      cleanup: rename internal define
      cleanup: use DM limit define
      thin: disallow creation of too big thin pools
      tests: check thin-pool boundary sizes
      tests: fix compilation of unit tests
      cache: lvcreate --cachepool checks for cache pool
      configure: report yes or no for wiping and system
      tests: no longer allowed too big thin-pools for small chunks
      snapshot: fix reporting for merged old snapshot
      cleanup: define really uses KB
      cleanup: update message
      indent: properly indent goto
      configure: warn about older version of cache_check
      configure: improve reporting about readline
      configure: update
      libdm: workarounds reported raid status info
      raid: report percent with segtype info
      cleanup: use 'dm_get_status_raid'
      cleanup: improve debug tracing
      cleanup: show what happens when passed prompt
      cleanup: drop unused parameter
      debug: passing non-raid seg would be internal error
      tests: use exclusive activation
      fsadm: restore no answer
      thin: restore conversion to raid
      tests: check conversion of thin-pool
      activation: fix usage of origin_only
      tests: avoid double lines
      tests: test also different lock holder
      raid: more origin_only updates
      raid: drop debug code
      raid: report error when specified devices are not contained
      raid: use log_error on error path
      debug: missing traces
      raid: update path for repair
      lvresize: support passing --yes to fsadm
      tests: lvresize needs --yes
      cache: make syncing abortable by user
      cache: drop usage of origin_only
      cache: fix lvdisplay --maps
      cache: fix lvdisplay output
      debug: show message only when origin_only was set
      tests: check lvdisplay for cache works
      tests: flushing of cache is abortable
      raid: improving messages for regionsize change
      raid: switch message to verbose
      cache: restore origin only reload
      debug: add missing internal error message
      cleanup: update messages
      tests: handle su login difference
      tests: request 1.12 for reshaping raid
      raid: recognize transient failed raid leg
      raid: plugin does not to use --config
      tests: require also no 'a' for in-sync
      tests: add transient failure test
      tests: use allocate policy in raid test
      dmeventd: improve more raid status reporting
      libdm: implement dm_percent_to_round_float
      libdm: use rounded float for percent print
      display: add display_percent function
      cleanup: use display_percent
      tests: unit test for percent printing
      tests: correct percent values are reported
      raid: allow more sync action for extraction
      tests: slightly longer delay
      tests: show more debug info
      libdm: fix initialization of head for reused structure
      cmdline: fix missing NULL at end of array of args
      raid: fix write_commit_backup
      dev_manager: add missing validation for usable target_name
      cleanup: remove unused code
      debug: check for fail in id validation
      debug: tracing error path
      debug: fail in backup is not traced nor error
      debug: fix error path
      debug: use display_lvname
      coverity: add some error path for failed allocs
      coverity: validate retval from get_only_segment_using_this_lv
      debug: more display_lvname usage
      coverity: extra check for find_pool_seg
      coverity: use better function
      coverity: check malloc results
      coverity: validate length of renaming path
      coverity: drop unneeded assigns
      coverity: move initilization of count variable
      coverity: model few more functions
      coverity: checked_return of close
      command: we don't have all standard macros


