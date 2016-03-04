From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  4 Mar 2016 18:07:59 +0000 (UTC)
Subject: v2_02_145 annotated tag has been created
Message-ID: <20160304180759.08BE560E2A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7a03ddc3744a8cef3728a7feb7d7302f3d7b1e48
Commit:        7a03ddc3744a8cef3728a7feb7d7302f3d7b1e48
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-03-04 18:02 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-03-04 18:02 +0000

annotated tag: v2_02_145 has been created
	    at 7a03ddc3744a8cef3728a7feb7d7302f3d7b1e48 (tag)
       tagging 68ec240b99fca4e0860cb6e1b17ce4b888eb2585 (commit)
      replaces v2_02_144

Release 2.02.145.

Another development release - recent interface changes are still not frozen.

83 files changed, 2694 insertions(+), 607 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlbZzeQACgkQIoGRwVZ+LBcrYQCfVvBtj1E6fhR6wbk91SYH83OI
NpUAoLAOGoHKFuWJqN5CB0RXzxM8WfcC
=TpKw
-----END PGP SIGNATURE-----

Alasdair G Kergon (3):
      post-release
      man: Add some information about historical LVs.
      pre-release

David Teigland (6):
      pvs: display VG name [unknown] for used PV without metadata
      tests: check [unknown] in lvmetad-pvscan-cache
      update WHATS_NEW
      pvs: replace 'unknown device' with [unknown]
      WHATS_NEW: [unknown] replaces 'unknown device'
      tests: direct control of lvm1 usage in tests

Marian Csontos (1):
      dbustest.sh: Get dbus test to work on buildbot

Peter Rajnoha (44):
      metadata: add infrastructure to track LV history
      metadata: add get_or_create_glv and get_or_create_glvl
      metadata: add add_glv_to_indirect_glvs and remove_glv_from_indirect_glvs
      metadata: create historical LVs when LVs are removed and interconnect with live LVs
      metadata: format_text: also export historical LVs
      metadata: format_text: reuse _print_timestamp fn
      metadata: format_text: import historical LVs
      metadata: add find_historical_glv fn
      metadata: add support for interconnection of thin pool LV segment with indirect origin
      metadata: format_text: interconnect historical LVs among each other and also with live LVs
      metadata: add lv_is_historical fn to test if the LV is historical one
      cmd: add '-H|--history' switch and wire it up in cmd_context and processing_handle
      toollib: honour '-H|--history' switch while executing process_each_lv_in_vg
      report: display lv_name,lv_uuid,vg_name,lv_time and new lv_time_removed for historical LVs
      commands: lvs: recognize -H|--history switch
      report: add lv_historical field to identify historical LVs
      report: display (h)istorical state in lv_attr field
      report: report historical LV names with '-' prefix
      report: add full_ancestors field to display ancestors with history
      report: add full_descendants field to display descendants with history
      report: add new 'none' lv_layout and 'history' lv_role and mark historical LVs that way
      cmd: add 'nohistory' option and wire it up in cmd_context
      metadata: honour 'nohistory' switch when removing thin LVs
      commands: lvremove: recognize --nohistory option
      conf: add metadata/record_lvs_history configuration setting
      metadata: add historical_glv_remove
      commands: lvremove: also process historical LVs
      metadata: add vg_strip_outdated_historical_lvs fn and call it during VG read
      conf: add metadata/lvs_history_timeout configuration setting
      conf: regenerate example.conf.in
      metadata: also look at historical LVs when checking LV name availability
      metadata: also validate historical LVs in VG in vg_validate and check_lv_segments
      metadata: automatically remove invalid (dangling) historical LVs
      lvmdump: also list historical LVs in lvmdump
      tests: add "get lvh_field" for "lvs -H"
      tests: add lv-ancestry.sh test
      commands: lvdisplay: recognize -H|--history switch
      lvrename: support renaming historical logical volumes
      cleanup: comment in the code for renaming historical LVs
      man: lvrename: also mention possibility to rename historical logical volumes
      WHATS_NEW: historical LVs
      libdm: config: remove 4096 char limit due to buffer size if writing dm_config_node
      cleanup: previous patch with libdm config node buffer size
      libdm: config: fix dm_config_write_node and variants to properly return error on failures

Tony Asleson (1):
      lvmdbusd: Set locale

Zdenek Kabelac (13):
      coverity: missing error path
      coverity: eliminate DEADCODE
      cleanup: indent and dots
      man: fix mising braces
      makefile: handle dm-version-expected
      cleanup: missplaced .
      cache: add kernel_cache_policy option
      man: lvconvert updates
      man: minor updates
      cleanup: use _field_string
      cleanup: use lv_is_partial
      tests: check kernel_cache_ funcs
      tests: drop check for md5sum


