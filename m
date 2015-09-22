From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 22 Sep 2015 15:07:15 +0000 (UTC)
Subject: v2_02_132 annotated tag has been created
Message-ID: <20150922150715.17F1261028@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=49eab66208d21cb7718f56ac72fd58632251482e
Commit:        49eab66208d21cb7718f56ac72fd58632251482e
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2015-09-22 15:00 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2015-09-22 15:00 +0000

annotated tag: v2_02_132 has been created
	    at 49eab66208d21cb7718f56ac72fd58632251482e (tag)
       tagging 629398d0f275e6ee5abf7929bc80e671e9f141c7 (commit)
      replaces v2_02_131

Release 2.02.132.

38 files changed, 1191 insertions(+), 629 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlYBbSAACgkQIoGRwVZ+LBd3FACfWkD5EI1nvmWmgYJCofFmDddw
GXsAnRICDM2H7tyDEl965wgBo0aT+8fc
=BcQY
-----END PGP SIGNATURE-----

Alasdair G Kergon (3):
      post-release
      lvmcache: Remove verbose msg when rescanning dev.
      pre-release

David Teigland (1):
      lvmlockd: unlock lv if command fails before lock completes

Heinz Mauelshagen (1):
      uuid: Report invalid character.

Peter Rajnoha (19):
      format-text: label: fix missing dev assignment for struct label in _text_pv_write
      libdm: report: make it possible to use blank value as selection for string list report field
      libdm: dev_node: use lstat instead of stat while removing and renaming nodes
      libdm: file: add proper checks for directory components in dm_create_dir
      WHATS_NEW: commit 6c0b4a2769067048fa144814e298a3272564c475
      cleanup: report: reuse existing _uuid_disp fn to report pv_uuid field
      lv: add 'mem' arg for lv_uuid_dup
      report: add lv_pool_lv_uuid field
      report: add lv_origin_uuid field
      report: add lv_metadata_lv_uuid field
      report: add lv_data_lv_uuid field
      report: add lv_mirror_log_uuid field
      pv: add 'mem' arg for pv_uuid_dup and pv_name_dup
      report: add lv_move_pv_uuid field
      report: add lv_convert_lv_uuid field
      WHATS_NEW: commits cb8f29d1473d993d890387fe24331c9b9fe4713c - a54b4bba3578e371bb36ddb3b040a71825a62814
      wiping: warn if use_blkid_wiping=1 is set and LVM not compiled with blkid_wiping support
      lvmconf: set locking_type=2 if external library is requested
      man: drop superfluous '--' in lvmconf man page for --enable/disable-halvm

Zdenek Kabelac (12):
      libdm: parse Overflow string from snapshot status
      dmsetup: use noflush with force removal
      dmsetup: improve help text
      man: enhance dmsetup/dmstats
      man: use PD/HP for compressed lines
      tests: use remount-ro for extfs
      tests: check dmsetup remove --force
      clvmd: update help test
      man: update man pages
      lvchange: update help text
      tests: check for block device
      tests: update removal test


