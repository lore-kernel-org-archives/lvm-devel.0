From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sun, 21 Feb 2016 23:38:33 +0000 (UTC)
Subject: v2_02_143 annotated tag has been created
Message-ID: <20160221233833.5F59E60ED3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5734e4d24502ec787e584f245938ec632d7d08a7
Commit:        5734e4d24502ec787e584f245938ec632d7d08a7
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-02-21 23:32 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-02-21 23:32 +0000

annotated tag: v2_02_143 has been created
	    at 5734e4d24502ec787e584f245938ec632d7d08a7 (tag)
       tagging 3ef36f05b6269f752a6d8fb62e098e89843958fa (commit)
      replaces v2_02_142

Release 2.02.143.

Experimental release including lvmdbusd.
(No change related to lvmdbusd or python in this release should be considered
frozen.)

83 files changed, 9680 insertions(+), 305 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlbKSV4ACgkQIoGRwVZ+LBeGhACg7dpf3avexsf96iFauYCEk0Fm
NGIAoPT1iPI5ce6M4KPXL5tGWP/HQaAM
=s//r
-----END PGP SIGNATURE-----

Alasdair G Kergon (10):
      post-release
      lvmdbus: Add new daemon.
      WHATS_NEW
      lvmdbus: resync latest changes with original repo
      autoconf: Fix py-compile permissions
      lvmdbusd: Rename module to lvmdbusd
      .
      configure: Use python-config if python2-config not found.
      lbmdbusd: Support in-tree testing.
      pre-release

Marian Csontos (2):
      Fix rpm builds
      spec: Update python bindings and dbus-service

Peter Rajnoha (36):
      refactor: rename struct pv_to_create --> struct pv_to_write
      format: add FMT_PV_FLAGS to indicate format supports PV flags
      metadata: introduce PV_EXT_USED flag and bump PV_HEADER_EXTENSION_VSN
      lvmcache/lvmetad: cache PV extension flags
      lvmcache/lvmetad: cache PV extension version
      pv: add is_used_pv fn
      metadata: add_pv_to_vg: add 'new_pv' arg to state if the PV is about to be created
      metadata: schedule PV for header rewrite if adding a PV to VG or restoring VG
      pv: format-text: store PV_EXT_USED flag if PV is used and unset it otherwise
      pv: check for the PV_EXT_USED flag and deny pvcreate/pvchange/pvremove/vgcreate on such PV (unless forced)
      pv: issue different message of different type when we're overwriting existing PV header instead of creating a new one
      pv: _pvcreate_write: do label removal and zeroing only if creating a new PV
      report: add pv_in_use field to display whether PV is in use or not
      metadata: _vg_read: check if PV_EXT_USED flag is set correctly for orphan PVs and do a repair if needed
      metadata: check for PV extension version before doing any checks on PV extension flags
      report: add pv_ext_vsn field  to display PV header extension version used
      metadata: _vg_read: check if PV_EXT_USED flag is set correctly for non-orphan PVs and do a repair if needed
      backup: backup_restore_vg: register PVs that need writing via vg->pvs_to_write list
      report: always display 0 for pv_free field if we don't have any mda and PV is marked as used at the same time
      report: identify used PVs in pv_attr field with 'u' char
      format: format_text: add pv_needs_rewrite to format_handler and implemention for format_text
      vg: automatically update to newest PV ext version during vg_write
      tests: add pv-ext-flags.sh test
      tests: fix tests checking pv_attr - there's a new bit now
      WHATS_NEW: PV_EXT_USED flag and related
      cleanup: use is_used_pv fn to detect whether PV is in use while reporting pv_free field
      pv: mark fake PVs as not used
      toollib: skip PV if system ID is used and PV marked as used but metadata missing
      cleanup: make the message about marked PVs consistent with the others
      pv: use pv->fmt to check for fake PVs, not pv->vg
      refactor: add common _is_foreign_vg fn
      metadata: do not repair missing PV_EXT_USED flag for PVs belonging to foreign VG
      metadata: add missing _repair_inconsinstent_vg call during PV ext repair
      man: fix list of restricted LV name suffixes
      report: report -1, not 'unkown' for lv_{snapshot_invalid,merge_failed} with --binary
      metadata: ask for confirmation before really initializing/removing PV that is marked as belonging to a VG

Tony Asleson (1):
      lvmdbustest.py: resync latest changes

Zdenek Kabelac (8):
      libdm: thin status update
      thin: report PERCENT_INVALID for failed pool
      thin: report needs_check and fail state
      man: lvs updates
      tests: checking thin flags
      thin: fix test for nonexisting status
      tests: needs_check needs version 16
      thin: fix update_pool_lv error path


