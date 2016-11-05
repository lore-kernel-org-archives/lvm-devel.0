From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat,  5 Nov 2016 01:14:40 +0000 (UTC)
Subject: v2_02_167 annotated tag has been created
Message-ID: <20161105011440.176666067A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=18d101d178dc8b9d3f19b1ddb1b5ab5ee95f63e4
Commit:        18d101d178dc8b9d3f19b1ddb1b5ab5ee95f63e4
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-11-05 01:03 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-11-05 01:03 +0000

annotated tag: v2_02_167 has been created
	    at 18d101d178dc8b9d3f19b1ddb1b5ab5ee95f63e4 (tag)
       tagging eed708dbd985f06ff73494cf688ab7ee54e2d1e7 (commit)
      replaces v2_02_166

Release 2.02.167

Final bug fix release before more enhancements and refactoring.

67 files changed, 1659 insertions(+), 766 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlgdMEYACgkQIoGRwVZ+LBd52wCdGW+8BBY0yk6xp2OnkZUyAMY8
K/EAn1qQ08ycECL49wTojax6cxYzRQWV
=AS29
-----END PGP SIGNATURE-----

Alasdair G Kergon (6):
      post-release
      lvconvert: Disable thin pool raid conversion while active.
      Revert "cleanup: simplier assign of cmd vars"
      dmsetup: Produce partial output if dev disappears.
      tests: Disable 3-leg raid1 pre-sync repair attempt
      pre-release

Bryn M. Reeves (5):
      libdm: fix stats walk compatibility with older dmsetup
      libdm: fix dm_stats_delete_region() backwards compat
      libdm: convert FIEMAP buffer allocation from stack to dm_zalloc
      dmsetup: obey --programid when deleting regions
      dmsetup: remove stray '
' in delete log message

David Teigland (4):
      lvmlockd: fix segfault in error path
      toollib: clean up coverity issue
      pvscan: fix autoactivation of exported VG
      tests: check that pvscan cannot activate exported VG

Heinz Mauelshagen (11):
      lvconvert: certain repair of cache raid volumes fails "Cannot convert internal LV"
      lvconvert: fix RAID SubLV --splitmirror regression
      lvconvert: position dedicated parity device in raid4 conversions porperly
      raid_manip: fix typo
      lvconvert: revert to only letting raid4 through to lv_raid_convert()
      lvchange/vgchange/lvconvert: prevent raid4 creation/activation/conversion on non-supporting raid targets
      lvconvert-raid-takeover.sh: fix test
      lvconvert: check for supported raid0/raid4 segtypes
      lvconvert: prevent non-synced raid1 primary leg repair
      lvconvert: fix raid repair regression
      test: add raid4 checks to respective tests

Peter Rajnoha (3):
      systemd: disable service start rate limiting for lvm2-pvscan at .service
      spec: move dmeventd -R from post to posttrans script for device-mapper-event package
      blkdeactivate: deactivate dev stack if dev on top already unmounted

Tony Asleson (30):
      lvmdbustest.py: Make env variable work
      lvmdbusd: Clean up objectmanager.get_object_path_by_uuid_lvm_id
      lvmdbusd: Allow PV device names to be '[unknown]'
      lvmdbustest.py: Make sure to test for hidden lookups
      lvmdbusd: Add diagnostic validate for look ups
      lvmdbusd: Remove extraneous parameter
      lvmdbusd: Use 'pv_missing' column instead of '[unknown]'
      lvmdbusd: Add properties to LvCommon
      lvmdbusd: Add LvCommon.MovePv
      lvmdbusd: Add LvCommon.DataPercent
      lvmdbusd: Ensure lvm shell still exists
      lvmdbusd: Ensure tmp dir gets cleaned up
      lvmdbustest.py: Ensure we exit non-zero on fail
      lvmdbustest.py: Print to stderr
      lvmdbustest.py: Denote failure if set_execution fails
      lvmdbustest.py: Skip test_job_handling_timer on loopback
      lvmdbustest.py: Add profile and path for lvm binary
      lvmdbusd: Disable lvm abort on too much log output
      lvmdbusd: Remove log ouput when ec=0 & stderr != 0 bytes
      lvmdbustest.py: Use more compatible syntax
      lvmdbustest.py: Add $PREFIX support
      lvmdbustest.py: ws fixes
      lvmdbusd: Use timer instead of thread
      lvmdbusd: Return results in main thread
      lvmdbusd: Execute load in main thread
      lvmdbusd: Don't use dbus lib in worker thread
      lvmdbusd: main.py: change debug msg text
      lvmdbusd: Stop using threads for job wait
      lvmdbusd: Take out background thread
      lvmdbusd: Remove the periodic timer task

Zdenek Kabelac (30):
      raid: dmeventd plugin use 64bit arithmetic
      libdm: check for mem when _canonicalize_field_ids
      dmeventd: pthread_sigmask in single function
      cleanup: simplier assign of cmd vars
      cleanup: drop assign before use
      cleanup: drop test for NULL
      cleanup :drop unneeded header file
      tests: proper wait usage
      lvconvert: fix error value
      lvconvert: use _read_conversion_type
      cleanup: reorder code
      cleanup: use already set values
      cleanup: lvconvert drop unused variable
      cleanup: indent
      tests: notify dbus only for dbus test
      lvconvert: still use  strcmp for now
      logging: add more log macros
      libdm: report logging with errno as changed default
      dmeventd: abort on internal error
      dmeventd: debug only subsystemd with # sign
      dmeventd: separate dm and dmeventd logging
      cleanup: drop unused attribute
      cleanup: add 'static' for local struct
      libdm: use dm_log_with_errno always
      cleanup: log_info to log_error
      log_info to log_warn
      log_info to log_very_verbose
      cleanup: remove goto
      cleanup: use WARNING prefix for log_warn
      dmeventd: provide message context


