From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 26 Mar 2016 09:34:19 +0000 (UTC)
Subject: v2_02_148 annotated tag has been created
Message-ID: <20160326093419.9E22760C79@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a6aef38fa130f71a4dd16de375027a72cf297b01
Commit:        a6aef38fa130f71a4dd16de375027a72cf297b01
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-03-26 09:05 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-03-26 09:05 +0000

annotated tag: v2_02_148 has been created
	    at a6aef38fa130f71a4dd16de375027a72cf297b01 (tag)
       tagging b9d07f7a12991ce7437630d2362fcc1a44a37e98 (commit)
      replaces v2_02_147

Release 2.02.148.

36 files changed, 744 insertions(+), 140 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlb2USEACgkQIoGRwVZ+LBdRtgCfZyNDqEKFStgfOKyG8nPINcaJ
wXsAn1ueHB9xQg1eB0r1bOFchY5q2XS8
=KVRq
-----END PGP SIGNATURE-----

Alasdair G Kergon (8):
      post-release
      report: Add pv_major, pv_minor to reports.
      activate: Use macros for target and module names.
      libdm: Change _advance_to_next_word to _skip_fields
      libdm: Move _skip_fields within file.
      raid: Tidy dm_get_status_raid. [HM]
      libdm: Raid status region units are sectors
      pre-release

Marian Csontos (5):
      test: Turn on dbus test
      test: Fix checks to skip lvmdbusd tests
      test: Fix lvmdbusd tests to work with installed testsuite
      test: Remove pidfile after killing the process
      test: Move bus configuration to prepare function

Peter Rajnoha (14):
      device: add DEV_OPEN_FAILURE flag
      dev: detect mismatch between devices used and devices assumed for an LV
      metadata: use own mem pool to report PV device mismatch in VG
      dev: be safer when reading sysfs properties
      tests: add vg-check-devs-used.sh
      dev: also check for blank sysfs value containing only '
'
      dev: also count with suffixes in UUID for LVs when constructing VGID and LVID index
      tests: update vg-check-devs-used.sh
      tests: update vg-check-devs-used.sh
      coverity: fix some issues reported by coverity for recent code
      properties: use proper 'get' variant for unimplemented _pv_major_get and _pv_minor_get fns
      monitoring: sync /dev content before contacting dmeventd for monitor/unmonitor
      WHATS_NEW: commit 6129d2e64d14047169048775dc7081135c0fcc50
      revert: 6129d2e64d14047169048775dc7081135c0fcc50

Tony Asleson (5):
      lvmdbusd: Remove --udev in service file
      lvmdbusd: Allow PV devices to be referenced by symlink(s)
      lvmdbusd: Add lvm flight recorder
      lvmdbusd: Change print statements to log_error
      lvmdbusd: Add '-' to allowable PV device path chars


