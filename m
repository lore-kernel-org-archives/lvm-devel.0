From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 28 Jul 2016 18:59:20 +0000 (UTC)
Subject: v2_02_162 annotated tag has been created
Message-ID: <20160728185920.BF50860E6B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=752a0d83dcd3ce8b40f42baa3522b6e5dbebf767
Commit:        752a0d83dcd3ce8b40f42baa3522b6e5dbebf767
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-07-28 18:45 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-07-28 18:45 +0000

annotated tag: v2_02_162 has been created
	    at 752a0d83dcd3ce8b40f42baa3522b6e5dbebf767 (tag)
       tagging 6f47e79a88ff73182825b7b07c29b4775c4698c4 (commit)
      replaces v2_02_161

Release 2.02.162.

A release that mostly consists of bug fixes.

Note one behavoural change that can be reverted by setting
allocation/raid_stripe_all_devices to 1.

43 files changed, 1516 insertions(+), 641 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAleaU7sACgkQIoGRwVZ+LBc1WACbB9/P+TwYNxSoOIiWje98jSGi
CUAAoMnhKZAJW0fS7Y9ze/Lb0aIqUmi6
=TC1b
-----END PGP SIGNATURE-----

Alasdair G Kergon (8):
      post-release
      raid_manip: Reorder some functions.
      raid_manip: Fix stripe_size type to uint32_t.
      raid_manip: Some validation functions.
      segtype: Fix unrecognised flag message.
      lvconvert: --trackchanges requires --splitmirrors
      lvconvert: --trackchanges requires --splitmirrors 1
      pre-release

Bryn M. Reeves (5):
      libdm: free hist_arg in _stats_create_file_regions() (Coverity)
      dmstats: free bounds string in _stats_create_file() (Coverity)
      libdm: document use of dm_free() with histogram bounds
      dmstats: check uuid, major, and alldevices before argc (Coverity)
      dmstats: fix bounds leak in _do_stats_create_regions() (Coverity)

David Teigland (11):
      lvmetad: free memory on exit
      lvmetad: use committed metadata to update
      lvmetad: fix use committed metadata to update
      lvconvert: allow implied cache pool convert
      lvconvert: change error message
      lvmlockd: improve activation locking error message
      lvmlockd: improve message for lock-start
      lvconvert: remove warnings about deprecated split option
      lvmlockd: improve error message about missing global lock
      man: lvmthin clean up syntax example
      vgsplit: restore check for thin pool external origin

Heinz Mauelshagen (10):
      lvconvert: raid0 replace attempt segfaults
      lvcreate: raid0 needs default number of stripes
      lvcreate: conditionally set stripesize
      vg_validate: segment check enhancements for raids to catch bogus metadata
      lvcreate.c: respect DEFAULT_RAID_MAX_IMAGES on creation of any RaidLV
      vg_validate: fix seg->extents_copied check introduced with
      vg_validate: add missing check for raid6 segment types
      vg_validate: only reject min_recovery_rate in case max_recovery_rate is set and smaller
      man: lvcreate correction on --stripes explanation and examples
      vgsplit: ea90a3d622 added an unconditional call to lv_is_on_pvs()

Peter Rajnoha (6):
      scripts: blkdeactivate: fix typo for DEV_DIR when executing blkdeactivate -m disablequeueing
      conf: regenerate example.conf.in
      man: add note about 'lastlog' built-in command
      libdm: report: fix json reporting to escape '"' character that may appear in reported string
      metadata: fix automatic updates of PV extension headers to newest version
      tests: add pv-ext-update.sh test

Tony Asleson (2):
      lvmdbusd: Fix hang for Job.Wait(n)
      lvmdbusd: Add '-y' to lvconvert for lv cache create

Zdenek Kabelac (12):
      lvconvert: enable work with partial LVs
      tests: enforce flush of cache target
      lvconvert: reusing old cache pool metadata needs -Zn
      man: drop .R
      tests: check thin resize of raid10
      lvconvert: suppress zeroing warning when converting to thin
      lvconvert: tune cache-pool zeroing
      lvconvert: support --zero for full cache pool conversion.
      tests: adapt for new cache-pool zeroing
      tests: check we don't warn when converting to thin LV
      config: keep new setting commented out
      tests: updates for new raid allocation logic


