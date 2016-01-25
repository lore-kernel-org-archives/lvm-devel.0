From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 25 Jan 2016 01:14:49 +0000 (UTC)
Subject: v2_02_141 annotated tag has been created
Message-ID: <20160125011449.25FC960EED@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1a083ffaadcead7c78538a704dca9aef6554540d
Commit:        1a083ffaadcead7c78538a704dca9aef6554540d
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-01-25 01:08 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-01-25 01:08 +0000

annotated tag: v2_02_141 has been created
	    at 1a083ffaadcead7c78538a704dca9aef6554540d (tag)
       tagging d05d7d974c5e66e9d9eb834df36a4487cb3c1016 (commit)
      replaces v2_02_140

Release 2.02.141.

704 files changed, 1502 insertions(+), 1160 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlaldZ4ACgkQIoGRwVZ+LBcyogCg7K/B6AsDwk9exXMspGvAhNEY
iRMAoJKdWR8NZErNMroSbUxSrq+fUWtM
=XjBP
-----END PGP SIGNATURE-----

Alasdair G Kergon (7):
      post-release
      report: Fix seg_pe_ranges LV sizes.
      locking: Add node parameter to query_resource.
      activation: Add lv_is_active_remotely.
      clvmd: Initialise udev.
      activation: remote node check doesn't work yet
      pre-release

David Teigland (8):
      pvchange, pvresize: fix lockd_gl() usage
      lvmlockd: fix lvb validation for conversion
      lvmlockd: cosemtic improvements to logging
      Revert "Revert "process_each_pv: remove unnecessary workaround""
      pvmove: use toollib
      toollib: add comment about missing device
      lvconvert: disallow test mode in shared VG
      lvmlockd: remove noisy log_debug

Peter Rajnoha (15):
      report: add kernel_cache_settings field
      refactor: add 'delimiter' variable for non-default delimiter when reporting string list
      report: change _format_pvsegs to return list instead of plain string, change associated report fields from STR to STR_LIST
      report: make devices, metadata_devices, seg_pe_ranges and seg_metadata_le_ranges fields consistent
      report: add seg_le_ranges report field
      report: add note about seg_pe_ranges and seg_le_ranges in -o help
      report: fix off-by-one error when reporting LV segment's metadata device extent count
      man: mention GPT id for LVM in pvcreate man page
      configure: fix configure to set proper use_blkid_wiping if autodetected as disabled
      vgimportclone: fix VG name variable reference in error message after failed PV uuid change
      device: also cache device size
      lvmcache: invalidate all cached dev sizes if all VGs got unlocked
      metadata: check PV dev size is not less than PV size
      conf: add metadata/check_pv_device_sizes
      tests: add pv-check-dev-size.sh

Zdenek Kabelac (14):
      cleanup: use log_print
      cleanup: shuffle check of threshold
      cleanup: update check function
      cleanup: adjust once
      cleanup: relocate size assign
      cleanup: drop extra cmd passed arg
      cleanup: reformat sentence about max sizes
      man: dmsetup
      man: show hidden pieces
      cleanup: join if/else
      doc: change fsf address
      toollib: use cmd mempool for list
      toollib: restore command break support
      cleanup: add missing prototype


