From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 22 Apr 2016 23:47:41 +0000 (UTC)
Subject: v2_02_151 annotated tag has been created
Message-ID: <20160422234741.834F860DE4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ba03e128dc63fcd94f73bb786542c2afdda65c42
Commit:        ba03e128dc63fcd94f73bb786542c2afdda65c42
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-04-22 23:42 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-04-22 23:42 +0000

annotated tag: v2_02_151 has been created
	    at ba03e128dc63fcd94f73bb786542c2afdda65c42 (tag)
       tagging 546b2006dd4bc888a08631d6cb66245b0374eab2 (commit)
      replaces v2_02_150

Release 2.02.151

Another bug fix release.

77 files changed, 1867 insertions(+), 683 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlcatvMACgkQIoGRwVZ+LBcvPwCdGzBIjpI94AufS4l/13um/33+
/iQAnjBghsd72CZBumkBNgLK+sO4iq0I
=ZlBY
-----END PGP SIGNATURE-----

Alasdair G Kergon (9):
      post-release
      toollib: Fix misleading message when forking.
      snapshot: Don't deactivate fictional snapshot LV.
      activation: Add LV name to a debug message.
      activation: Log when pending snap merge postponed.
      activate: Improve snapshot merge initiation
      display: Avoid internal snapshot LV names in msgs.
      activate: Hide errors when snapshot merge delayed.
      pre-release

Bryn M. Reeves (1):
      libdm-stats: check for empty region and area lists

David Teigland (29):
      rename function read_vgname to read_vgsummary
      lvmetad: preemptively check and rescan in commands
      lvmetad: add FIXME to comment
      tests: lvmetad-lvm1 fix
      WHATS_NEW for lvmetad scanning changes
      tests: fix check_lvmlockd_test
      lvmlockd: skip unnecessary lvmetad cache update
      metadata: don't repair shared VGs
      toollib: remove unneeded call in process_each_pv
      lvmetad: add disabled state
      lvmetad: set disabled flag in lvmetad if lvm1 metadata is found
      lvmetad: use the disabled flag in commands
      lvmetad: clear the disabled flag in lvmetad
      lvmetad: disable if command uses lvm1
      test: update lvm1 test
      test: update lvmetad-disabled
      test: lvmetad-no-cluster
      test: lvmetad-override
      test: lvmetad-warning
      lvmetad: use defines for disabled reason strings
      lvmetad: rework command connection setup and checking
      test: lvmetad-override
      lvmetad: connect from forked polling process
      lvmetad: check for socket in connect
      lvmetad: check pid for warning case
      lvmetad: fix compile without lvmetad
      lvmetad: warn about making changes while not using lvmetad
      poll daemon: only call lvmetad_connect when needed
      WHATS_NEW: disable lvmetad for lvm1

Peter Rajnoha (1):
      refactor: factor out vg/lv/pv handling part from report_for_selection fn

Zdenek Kabelac (39):
      devcache: index devices also without udev
      devcache: do not insert devices without device node
      cleanup: avoid declaring var in the middle of code
      cleanup: gcc warn about comparing int with uint
      debug: unify some tracing messages
      thin: check runtime table line for merging
      thin: improve recognizing of merge in progress
      debug: fix error message
      debug: update message in libdm
      debug: use display_lvname
      snapshot: improve merge
      lvchange: improve refresh for merging thin volume
      tests: use bigger raid size
      tests: use should for failing test
      configure: detect for /var/lock dir
      configure: respect --disable-lvmetad/lvmpolld
      debug: move misplaced log_debug
      tests: document make parametr for tracing aux scripts
      tests: still show systems stas when command has not produced debug.log file
      tests: minor update
      lvmetad: fix compilation without lvmetad#
      tests: GLIBC decided to obsolete readdir_r
      cleanup: simplify code
      cleanup: use kdev_t header in lvm tree
      coverity: fix memory access
      coverity: fix error paths
      coverity: drop unused header file
      coverity: use wider type for whole expression
      coverity: return non-null string with internal error
      coverity: avoid using signed types for single bits
      coverity: drop abadoing object
      tests: keep using [] for hidden volumes
      cache: fix previous change and correct ()
      tests: make test independent on usage [] for hidden LVs
      coverity: is_used_pv needs valid pv pointer
      coverity: keep expression using 64bit
      coverity: ignore some dm_strncpy results
      coverity: check for sys error in clock call
      tests: drop cluster testing with pvmove


