From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  3 Jun 2016 22:43:36 +0000 (UTC)
Subject: v2_02_155 annotated tag has been created
Message-ID: <20160603224336.E211960CD2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d0af97e64d143d466013d7480ec3abd4e34b82ef
Commit:        d0af97e64d143d466013d7480ec3abd4e34b82ef
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-06-03 22:17 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-06-03 22:17 +0000

annotated tag: v2_02_155 has been created
	    at d0af97e64d143d466013d7480ec3abd4e34b82ef (tag)
       tagging 767c9d653eb9c6deec576c23823781c6f184dea0 (commit)
      replaces v2_02_154

Release 2.02.155.

A development release with an assortment of small enhancements and fixes
including limited support for striping using the dm-raid raid0 target.

97 files changed, 1964 insertions(+), 1288 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAldSApEACgkQIoGRwVZ+LBfzhwCfbtZNyjFQjV2vjlLQxCEcPD24
pZQAoIWjo4ahEadsLS2lri2dfSGNoxiE
=QAhm
-----END PGP SIGNATURE-----

Alasdair G Kergon (8):
      post-release
      raid0: Add raid0 segment type.
      raid0: Standardise meta_areas checks before access.
      raid10: Fix new use of area multiple calc.
      metadata: Tidy merge.c
      raid: Revert _lv_extend_layered_lv non-raid0 area_multiple.
      Revert "libdm: trace missing settings"
      pre-release

David Teigland (16):
      python: move lvm_init
      lvmetad: add request level thread locking
      lvmetad: remove old thread locking
      pvremove: allow clearing a duplicate PV
      liblvm: allow config settings to be read without full lvm cmd
      lvm2_activation_generator: don't create full context for liblvm2app
      WHATS_NEW: include recent changes
      tools: improve error message about VG name and select
      toollib: add vg name list arg to process_each_vg
      pvscan: use process_each_vg for autoactivate
      test: lvmetad-pvscan-filter
      test: lvmetad-disabled
      lvconvert: use process_each_lv
      vgreduce: use process_each_vg
      WHATS_NEW: include recent changes
      pvmove: disallow tag args

Peter Rajnoha (12):
      refactor: split _report fn further into init and config part
      toollib: simplify internal selection calls for non-reporting tools
      report: fix lvm devtypes internal error if -S is used with field name from pvs/vgs/lvs
      toollib: properly reset selection handle on selection failure in select_match_{pv,vg,lv}
      tests: add dmstats to CLEAN_TARGETS for make clean
      coverity: fix possible resource leak of descendants_buffer in _print_historical_lv fn
      coverity: blkdeactivate: separate format and args for printf and declare and assign separately to avoid masking return values
      coverity: missing check for id_write_format return value
      coverity: fix warnings about missing return value check for sscanf
      make: add generated parts of lvmdbusd to DISTCLEAN_TARGETS for make distclean
      lvmconfig: fix lvmconfig --type diff to display complete diff if config cascade used
      man: lvmconfig: add note about --type diff and --mergedconfig

Tobias Stoeckmann (1):
      man: fixed typo in lvcreate.8

Zdenek Kabelac (28):
      libdm: cache status reports passthrough cache mode
      libdm: trace missing settings
      lvchange: allow change of cache mode
      debug: use display_lvname
      tests: test change of cache mode
      report: fix report copy_percent value
      snapshot: check merging_cow is cow
      setup_task: add with_flush
      cache: call status only on cache pool in use
      cache: enhance lv_cache_wait_for_clean
      cleanup: substract integers
      cleanup: drop cmd and constify lv for lv_refresh_suspend_resume()
      refresh: call resume after failing suspend
      lvstatus: enhance seg_status to handle snapshot
      lv: introduce lvseg_percent_with_info_and_seg_status
      snapshot: use seg_status for attrs
      report: convert more options to use single status
      cache: add log_error on error path
      debug: use display_lvname
      tests: check cache_mode change on cachepool
      tests: stacked snapshot merge
      snapshot: for invalid snapshot show 100%
      tests: check thin is not flushed for status
      devices: handle partscan loop devices
      tests: extend prepare_loop
      tests: check losetup -P is correctly handled
      cleanup: use display_name
      cleanup: compile fixes for --disable-devmapper


