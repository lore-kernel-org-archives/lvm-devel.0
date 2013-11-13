From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 13 Nov 2013 14:09:47 +0000 (UTC)
Subject: v2_02_104 annotated tag has been created
Message-ID: <20131113140947.9FF6560F07@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0bd40cf32618d4c872586b975cba12c8e71080cb
Commit:        0bd40cf32618d4c872586b975cba12c8e71080cb
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2013-11-13 14:08 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2013-11-13 14:08 +0000

annotated tag: v2_02_104 has been created
	    at 0bd40cf32618d4c872586b975cba12c8e71080cb (tag)
       tagging 77a1efeb8eb0fe73c858ade05b578c3cfe3ddd9f (commit)
      replaces v2_02_102

Release 2.02.104

87 files changed, 1207 insertions(+), 294 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABAgAGBQJSg4gKAAoJEK2W1qbAHj1nlksP/1YbZ+5+3sWul5YRUWdXrgST
2lK2cKh34wgtcMniGfi1ZLW9YMJuZ16Ur3fSbzIAr3Msf7aCNDRvzaAp3nK/NGnS
LGmxL1hfryfJJtke8vZGc4O0qqDphU26E3wPcaUf726TNeF0GTFrx2215wn4ni5j
8XbVj/1AfZz7oxxhBM5YhUGplZvXNrIOP9t286fXfF+sFugtW4VuiyAsjDJFlI2C
0C8S7/rLZg/usXk3oS/WxwBHRj/q3ahjztmTMheSeNzpIEqoEQdgwz2dw3emLFN7
nJK1dViKeS8L/gCyvCn2tDCCAsVSVkRLjBOXWE9iqhfIsuxlO8FZXaSrvgx+HlfF
xIpvxhcLdxP052VqZ3xCnOANWp6huH8LTcLEUM++XHG8T1GqcZ6gXaQ4dI6esD6k
qn8hd2VXxlE1aZzbZtaRIbX4GjZKne890xwx1T9+wHu1S+A+a4GYgHWUqmjEXUvX
78fmgJlKAyGZ27LXmikLNKRpXSCxQwGUHltZVzxhSWj0OB0EKCeMn1oYtY+x4bF7
qcFlnBOEhm9Wm7E5p4xnzRvdiTr7EttlpsnzP79C9H1OogueITgDq2onuRG4/30B
nf8VuXnZnNCAWtJMjXhyKupXyWNgTsIvMaaXmdJwCJ9qThMq0C2QKIu92Lu2hoB6
TQvyjPvCtAAmQNMMQrib
=eaDw
-----END PGP SIGNATURE-----

Alasdair G Kergon (15):
      post-release
      pvmove: clean exit on failed pvmove restart
      pvmove: Accept PE ranges as start+length.
      pvmove: clean exit on failed pvmove restart
      cmdline: Accept PE ranges as start+length.
      Merge branch 'master' of /data/agk/git/lvm2-upstream
      lvs: Add seg_size_pe field.
      cmdline: Add --ignoreskippedcluster.
      release 2.02.103
      post-release
      lvchange: improve discards when pool active error
      filters: Add NVM Express (nvme).
      build: Use additional gcc warning flags.
      gcc: replace #ifdef linux with __linux__
      release 2.02.104

David Teigland (1):
      clvmd: fix verify message rejection of REMOTE flag

Jonathan Brassow (11):
      RAID: Fix broken allocation policies for parity RAID types
      Test/clean-up: Indent clean-up and additional RAID resize test
      mirror/RAID: Honor mirror_segtype_default when converting from linear
      WHATS_NEW: description for previous commit
      RAID: Fix _sufficient_pes_free calculation for RAID
      RAID: Report RAID images split with tracking as out-of-sync ("I").
      RAID: Better error message when attempting scrubbing op on thinpool LV
      TEST: Test was trying to kill 2 devices in RAID5 instead of RAID6
      Mirror: Fix hangs and lock-ups caused by attempting label reads of mirrors
      clean-up: Remove redundant faulty logic
      mirror: Handle failures in tmp mirror used when up-converting.

Mike Snitzer (1):
      vgimportclone: remove 2>/dev/null from three lvm commands

Mikulas Patocka (1):
      libdm: fix races with udev

Peter Rajnoha (43):
      tools: don't install separate command symlink for lvm devtypes
      lvmconf: use_lvmetad=0 on --enable-cluster, reset to default on --disable-cluster
      conf: add allocation/thin_pool_chunk_size_calculation
      thin: use appropriate default value based on allocation/thin_pool_chunk_size_calculation setting
      thin: calculate thin pool chunk size based on device IO hints
      profile: add thin-performance.profile
      fix: make it possible to compile with --disable-devmapper again
      udev: fix 3min udev timeout so that it is applied for all LVM volumes
      fix: also make commit b4637 work without dmeventd
      thin: better dbg msgs and avoid uninit. value on chunk size recalc
      udev: make subsystem rules responsible for importing subsystem flags
      libdm: export DM_UDEV_SUBSYSTEM_FLAG names for subystem udev flags
      thin: rename thin_pool_chunk_size_calculation -> ..size_policy and rename "default" policy to "generic"
      WHATS_NEW: renamed thin_pool_chunk_size_calculation -> policy
      activation: add support for flagging an LV to skip udev scanning during activation
      udev: add support for "NOSCAN" flag
      cleanup: remove 'discards 'const' qualifier' compilation warning
      WHATS_NEW: commit d888a05 and 808a5d9
      WHATS_NEW: commit 0decd75
      cleanup: WHATS_NEW + compiler warning about discarding const
      metadata: properly register LV_NOSCAN flag
      metadata: add INTERNAL_ERROR to "Metadata inconsistency" msg
      activation: check for open count with a timeout before removal/deactivation of an LV
      coverity: assigned variable not used and reassigned later
      coverity: sscanf should use "%u" instead of "%i"
      udev+systemd: make pvscan --cache -aay run as systemd background job from udev
      pvscan: use major:minor as short form of --major and --minor arg for pvscan --cache
      udev+systemd: refine lvm2-pvscan at .service to better track device existence
      make: correct sed line in udev's Makefile
      blkdeactivate: fix endless loop if device(s) given and unable to umount/deactivate
      WHATS_NEW: typo
      cleanup: for commit 546db1c
      activation: flag temporary LVs internally
      WHATS_NEW: commit 4c0db84
      udev: proper reset of DM_UDEV_DISABLE_OTHER_RULES_FLAG and honour this flag in lvmetad rules
      lvconvert: use LV_TEMPORARY when necessary during lvconvert to thin pool
      WHATS_NEW: commit 9d06212
      udev: no need to check DM_NOSCAN in lvmetad rules
      udev: properly trigger LVM scan for MD partitions
      udev: wrong line in previous commit
      profile: add thin_pool_chunk_size_policy to default.profile
      corosync: fix some gcc warnings
      pvscan: retry VG refresh before autoactivation if it fails

Petr Rockai (12):
      lvmetad: Fix vgname->vgid hash updates w/ duplicate VG names.
      lvmetad: Clean up pvid->vgid map when last PV in a VG disappears.
      lvmetad: Properly grab locks in pv_gone.
      libdaemon: Fix an invalid memory read.
      test: Make comma a separator as in make check T=lvconvert,lvcreate
      metadata: Fix metadata repair paths when lvmetad is used.
      test: Correctly trigger inconsistent metadata repair in lvmcache-exercise.
      lvmetad: Do not try to lock a NULL vgid.
      libdm: Link to libpthread unconditionally.
      libdm: Fix a data race in dm_pool_{create,destroy}.
      lvmetad: Fix a possible deadlock in pv_clear_all.
      libdaemon: Fix a subtle race in worker thread creation.

Zdenek Kabelac (33):
      vgrename: run fullscan
      thin: fix lvconvert in external origin conversion
      tests: vgrename duplicate rename
      tests: lvconvert more thin extorg conversions
      tests: reappering device
      tests: needed --type mirror
      snapshot: move virtsnap code from tool to lib
      snapshot: disable merging for virtual snaps
      snapshot: deactivate virtual snapshot first
      snapshot: rework parsing of snapshot metadata
      tests: harness updates
      tests: lvcreate and snapshot update
      thin: fix lvconvert for active pool.
      tests: add wait
      tests: test repairability of thin pool
      thin: missed check for thin_pool in last update
      tests: correct LVM_TEST_THIN_CHECK_CMD
      libdm: do not show holders missing error
      tests: use bash for bash script
      tests: fix exporting content of make vars
      tests: workaround udevd compromising tests
      tests: fix last commit
      tests: older losetup allows only single device name
      tests: drop settle for old systems
      configure: detect compiler flag
      configure: check more compile flags
      tests: fix old-style gcc warning
      gcc: fix comparing floating point warning
      locking: activate_lv_excl return correct error code
      activation: _lv_activate is ok when filtered.
      activation: improve activation
      dmsetup: report error on stderr
      tests: testing thin lvchange

mpatocka at redhat.com (1):
      headers: use __linux__ instead of linux


