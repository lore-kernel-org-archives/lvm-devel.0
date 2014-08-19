From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 19 Aug 2014 14:06:24 +0000 (UTC)
Subject: v2_02_108 annotated tag has been created
Message-ID: <20140819140624.35BD36056F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fc922e47bfbc7dfb05352d300deddbd2829774c4
Commit:        fc922e47bfbc7dfb05352d300deddbd2829774c4
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2014-07-23 15:18 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2014-07-23 15:18 +0000

annotated tag: v2_02_108 has been created
	    at fc922e47bfbc7dfb05352d300deddbd2829774c4 (tag)
       tagging 52217f6ebd3dee25808344a9425fc085427075e4 (commit)
      replaces v2_02_107

Release 2.02.108.

116 files changed, 4625 insertions(+), 1830 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlPP0mIACgkQIoGRwVZ+LBf+zgCdEYCQgygUxopFZsMN9M/h1e9Z
nQ8An2k3MBAb+VvV9AAltwkOWsprCmNO
=Xehg
-----END PGP SIGNATURE-----

Alasdair G Kergon (15):
      post-release
      make: Fix pofile and .d file generation.
      report: Exclude hidden devices from lv_path field.
      report: Add lv_dm_path and lv_full_name fields.
      vgsplit: Fix VG component of lvid.
      report: Add lv_parent field.
      vgsplit: Improve message when LV still active.
      report: Rename common fields to special fields.
      raid: Correct degraded warning message level
      config: Adjust description of activation_mode.
      metadata: Reinstate system info in metadata.
      raid: Moved degraded activation code to raid_manip.
      report: Remove lv_target_type field.
      pre-release
      raid: Fix partial activation logic for non-raid.

David Teigland (4):
      man: lvmthin fix line breaks
      man: use macros for indenting in lvmthin
      man: lvmcache updates
      man: rework lvmcache to match lvmthin

Jonathan Brassow (6):
      test:  Test addition to show incorrect allocator behavior
      raid/misc: Allow creation of parallel areas by LV vs segment
      misc: after releasing a PV segment, merge it with any adjacent free space
      raid: Allow repair to reuse PVs from same image that suffered a PV failure
      activation: Add "degraded" activation mode
      test: Test failing due to too few PVs

Peter Rajnoha (41):
      coverity: fix issues reported by coverity
      coverity: mark new switch cases with 'fall through' comment for coverity to stop complaining
      filters: always reevaluate filter before creating a PV
      man: do not mention '(i)nherited' for alloc policy in vg_attr field
      libdm: fix double const for "value" in dm_report_reserved_value structure
      activation: fix typo in 'activation skip' message
      refactor: remove static modifier for lv_raid_image_in_sync and lv_raid_healthy fn
      lv_manip: add get_lv_type_name/lv_is_linear and lv_is_striped helper fns
      reporter: add separate LVSINFO report type
      refactor: use new LVSINFO report type for lv_kernel_{major,minor,read_ahead} field
      report: add separate fields for PV/VG/LV attributes
      tools: add --binary arg to pvs,vgs,lvs and {pv,vg,lv}display -C and report/binary_values_as_numeric lvm.conf option
      report: adapt selection code to recognize per-field reserved values
      report: define reserved values/synonyms for some attribute fields
      metadata: fix regression causing PVs not in VGs to be marked as allocatable
      report: fix segfault while reporting PV/LV segment fields together with LV fields needeing device status (LVSINFO)
      report: addendum for previous commit
      WHATS_NEW: commits a473435..7021c8f1
      lv_manip: pool-metadata-spare is just a spare LV, not tightly bound to thin or cache
      conf: comment out devices/preferred_names and filter setting
      report: report unknown/-1 for binary fields with unknown value
      cleanup: use macros for definition of reporting/selection reserved values
      report: 'whether' -> 'set if' in field description
      report: add lv_active_{locally,remotely,exclusively} LV reporting fields
      cleanup: move _lvactive_disp and _thinzero_disp under 'attribute' display functions
      report: also recognize 'yes'/'no' for selection criteria on binary fields
      report: add values.h for per-field reserved value declaration
      conf: command_profile_template: global/binary_values_as_numeric -> report/binary_values_as_numeric
      cleanup: report reserved value macros
      cleanup: also use values.h for final dm_report_reserved_value array composition
      report: reserved value: description for undefined value
      report: report LV's zero field as binary field
      tests: LV's zero field now reported as binary field
      libdm: report: fix string list internal representation if delimiter is composed of more than one char
      conf: add report/list_item_separator lvm.conf option
      report: also report linear and striped for lv_target_type
      report: display 'unknown' value for LVSINFO fields if unable to get info
      report: display 'unknown' value for active/active_locally/active_remotely/active_exclusively if info bypassed
      report: display 'unknown' value for lv_active_remotely field if the LV is also active locally
      metadata: fix ALLOCATABLE_PV for lvm1 format
      WHATS_NEW: recent commits

Petr Rockai (4):
      lvscan: Implement a --cache mode.
      dmeventd: Call lvscan --cache in the RAID plugin.
      WHATS_NEW: lvscan --cache, dmeventd RAID + lvmetad
      man: Update the lvscan manpage with a section on --cache.

Zdenek Kabelac (76):
      thin: repaired LV uses _meta%d
      thin: do not create reserved LVs
      cleanup: more lv_is_ functions
      uuid: add more private uuid sufixes
      cleanup: ignore vg_name in /lib
      uuid: revert uuids for mirrors and raids
      mirror: mirror_or_raid_type_requested update
      raid: switch to log_warn
      raid: don't skip prompt with force
      lvremove: remove thin volumes on damaged pools
      thin: fix chunk_size conversion prompt skip
      pool: delay conversion prompt
      fsadm: avoid using -a in test
      display: add display_lvname
      cleanup: libdm simplier error comparation
      cleanup: line indent
      cleanup: verbose in human readable size
      cleanup: a bit better error message
      cleanup: use unsigned type for command
      cleanup: add braces for if()
      tests: avoid hiding results in local
      tests: replace cat with $(<
      cleanup: drop inline and add prefix _ for static
      tests: ensure data hits cow
      dev-type: print log_sys_debug
      dev-type: print aborting log_error
      cleanup: drop unneeded initialization
      cleanup: just safely copy string
      cache: add tool support
      configure
      prompt: display 'n' for EOF
      lvconvert: fix return codes
      lvconvert: snapshot prompts to confirm conversion
      lv_is_pool: add new defines
      lvchange: just skip on cache pool
      display: show C only for cache and cachepool
      pool: move code to pool source file
      pool: callback handle cache
      tools: arg_is_any_set and arg_is_only_set
      lvconvert: relocate mirror tests
      cache: warn about metadata size limits
      cleanup: indent changes
      cleanup: move merge option
      cleanup: reorder code
      cleanup: shift detection of chunksize sign
      lvconvert: update for thin a cache
      lvconvert: update help
      man: lvconvert update
      cleanup: lvconvert reoder repair check
      tests: updates for new lvconvert
      cleanup: older gcc is not smart enough
      cleanup: drop unintend debug error line
      lvconvert: fix mirror path
      cleanup: lets make it really obvious for gcc
      lvconvert: fix missing repair option
      lvconvert: add missing option for repair
      lvconvert: move to single name validation
      lvconvert: improve splitsnapshot test
      lvconvert: improve merge validation
      cache: use get_cache_mode for validation
      metadata: use outfc for comments
      raid: support lvdisplay --maps
      cleanup: check arg_count once
      cleanup: typo in message
      cleanup: drop testing impossible path
      tests: use bigger metadata
      tools: switch logic for new arg_ func
      lvconvert: better testing order
      thin and cache: unify pool common code
      cleanup: show better messages
      man: lvconvert poolmetadataspare
      tests: use full option name
      tests: new lvconvert features
      tests: use exclusive activation
      tests: support cluster run
      tests: still unusable kernel


