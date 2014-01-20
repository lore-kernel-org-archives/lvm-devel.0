From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 20 Jan 2014 19:40:31 +0000 (UTC)
Subject: v2_02_105 annotated tag has been created
Message-ID: <20140120194031.BC99560D8C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fc25ad57144eca52a2cf47f4cb7c1ff27c908c64
Commit:        fc25ad57144eca52a2cf47f4cb7c1ff27c908c64
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2014-01-20 19:24 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2014-01-20 19:24 +0000

annotated tag: v2_02_105 has been created
	    at fc25ad57144eca52a2cf47f4cb7c1ff27c908c64 (tag)
       tagging aa21e79991da6f6583f708f81ff32a1e2c0c3a42 (commit)
      replaces v2_02_104

release 2.02.105

174 files changed, 5390 insertions(+), 2097 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABAgAGBQJS3XgGAAoJEK2W1qbAHj1naxcP/2141q7iDIjo8rUfesygEXwQ
5Zl3cO+YdYISXULXU8p+lrVmRasYWNVYT+hzAd+INmErXPjIKRUJFdH0/SNL/+HX
xKIzK/8ityHELiE1Zk2mS3W168XI7/moAqeDEIHeaZiNA2/u3gQpvdtV1tPlHRVS
r0rTmpUy3SMy2ZK34oKQav0DqKqA3xZGEvg3rjaW8EOP5If4rO/PyATUARKF1ijY
fkGBP9Ahvu5QXHNB/6bLzMMYUg0X+GWHBuZG0xkkJKztwVWXBuPYfwC1sb+MwUUO
QqBd46wl40TjZ1xMu8p/qOnQG+TTrNfLr13Gq8YQpt+123bwMCnbr9O4ylQgs0xt
6PqEXW9lgezy5zhVR2nrRQUIvhLZzhHE2sAN3idmKoZ1zyO8c7D/MogB8ldoXfHd
LMbddZ2PisE5tup+KlVvfd8flyCi9gjSNG0u3DRosK8tqDoAkYaWSw53oeXdPv5H
RY7BTHC9yHqW6QYQn86M3PJ89BIAuLxD/J+wFasRpugoKlfZVOO7KNnRdxe+MGaK
MTLzPt1K+0rnFLWFR6DSgJabynsN2VKiB0nCZSPGbEWTpkv2FONbO3uk7glX4TDj
CpKeyeunAcn9c5ecf5YtqDIqqSOdZBGB+4WjcgAkk6OirGXX0C5EaciIwBnI9yKQ
HxPRoa5jFU7W9gr9bZux
=6+kD
-----END PGP SIGNATURE-----

Alasdair G Kergon (18):
      post-release
      toollib: Avoid undefined ignore_vg parameter.
      lvmetad: Add newline to missing socket error mesg
      lvmetad: extend socket/pid file handling
      pvcreate: Avoid spurious 'not found' messages.
      lvconvert: Fix reload after snapshot conversion.
      lvconvert: Implement --splitsnapshot.
      libdm: prevent empty config file section names
      lvmetad: remove unused override variables
      config: shorten new sig wiping option string
      lvmetad: free fid after vg lookup failure
      pvscan: use format feature flags in lvmetad code
      lvmcache: Invalidate cached VG if PV is orphaned.
      pvs: fix segfaults with orphans
      format1: Mark obsolete and do not use with lvmetad.
      pvresize: Avoid archiving orphan VG metadata.
      pvresize: Fix orphan PV size calculation.
      pre-release

Jonathan Brassow (1):
      Misc:  Get rid of some compiler warnings.

Peter Rajnoha (44):
      lv/vgchange: do not try to connect to lvmetad if socket absent and --sysinit -aay used
      activation: continue with autoactivation if refresh fails
      WHATS_NEW: commit 729b104
      activation: change log_error to log_warn if refresh before autoactivation fails
      device: cleanup signature wiping functions
      conf: add allocation/wipe_signatures_on_new_logical_volumes_when_zeroing
      lvcreate: recognize --wipesignatures arg
      lv_manip: rename set_lv -> wipe_lv and include signature wiping capability
      configure: add --enable-blkid_wiping
      conf: add allocation/use_blkid_wiping
      wiping: add support for blkid wiping
      man: lvcreate -W/--wipesignatures
      profile: wipe_signatures_on_new_logical_volumes_when_zeroing not yet profilable
      pvcreate: do not issue warning about any existing PV
      tests: initialize signature wiping
      tests: wipe fs signature manually in pvcreate-operation test
      tests: add test for lvcreate signature wiping
      configure: enable blkid_wiping by default if the blkid library is present
      configure: require libblkid >= 2.24 for blkid wiping
      vgdisplay: select only active volumes groups if -A option is used
      tests: one LV should be active and one inactive in covercmd test
      configure: check compiler/linker support for RELRO and PIE options
      daemons: use PIE and RELRO compiler/linker options
      make: CFLAGS, not CLDFLAGS
      configure: also LDFLAGS, not LDLAGS for proper restore
      compile/link: use RELRO/PIE compiler/linker options for executables
      compile/link: EXTRA_EXEC_CFLAGS must be applied for *.o
      lvmdump: follow symbolic links in /etc/lvm
      conf: clarify wipe_signatures_when_zeroing_new_lvs
      udev: fix SYSTEMD_READY assignment for foreign devices in lvmetad rules
      WHATS_NEW: commit 4c267c7286145165dfe078f77d18d194a21a2e1c
      autoreconf: latest changes
      autoreconf: latest changes
      man: -Z zeroes 4KiB, not just 1KiB
      device: add physical block size info and make sure VG extent size >= PV's phys. block size
      config: fix metadata/disk_areas config setting registration
      systemd: make sure lvm2-lvmetad.socket is available for lvm2-pvscan at .service
      device: use BLKPBSZGET for physical block size only if the op is available, otherwise use logical block size
      systemd: use only major:minor for pvscan in lvm2-pvscan at .service
      device: if BLKPBSZGET is unavailable, try to use BLKSSZGET with fallback to 512b
      thin: cleanup _thin_pool_add_message
      udev: do not drop SYSTEMD_READY for non-activating events
      thin: fix thin LV flagging for udev to skip scanning
      udev: clear temporary variable properly

Petr Rockai (47):
      metadata: Do not try to check vg_name of a NULL PV.
      toollib: Drop the pv_read optimisation.
      test: Add a test for the failing pv_read optimisation.
      pvresize: Do not use pv_read (get the PV from orphan VG).
      test: Fix fallout from pv_read changes.
      pvremove: Avoid using pv_read in favour of scanning.
      metadata: Avoid pv_read in find_pv_by_name.
      metadata: Fix handling of orphan PV linking & re-linking.
      metadata: Nuke the exported "pv_read" function.
      labeller: Make the use of "private" as "fmt" explicit.
      toollib: Implement process_each_label.
      metadata: Add lvmcache_info_mda_free as a companion to pv_mda_free.
      metadata: Add a pv_label accessor (go from a PV to its label).
      label: Track a device pointer in struct label.
      report: Make dev_size and dev_name columns' type "label".
      report: Add a proper "label" field type.
      report: Adapt _pvfmt_disp to label-based reporting.
      report: Make PMdaFree into a "label" field.
      report: Iterate over labels instead of PVs for label-only reports.
      report: Make PV UUID into a "label" type field.
      pv_label: NULL result is not always an internal error.
      toollib: Report errors on non-PV arguments to process_each_label.
      reporter: Deal correctly with dummy PVs/labels.
      reporter: Adapt pvseg reporting to label-type fields.
      report: Convert pv_mda_size to a type "label" field.
      dev-cache.c: Make dev_name a little more robust.
      metadata: Do not throw an error in pv_label for missing PVs.
      report: Print UUIDs for missing PVs when possible.
      test: Force label-based reporting in pv-duplicate.sh.
      lvmetad: Set up device pointers in synthetic lvmcache_infos.
      metadata: Make the fid mda routines a little more resilient.
      libdm-config: Allow quoted section (and key) names.
      test: Make the harness optionally less verbose (QUIET=1).
      pvscan --cache: Error out on pool-format VGs for now.
      pvscan --cache: Use FMT_LVM1_NAME instead of hardcoded "lvm1".
      test: Turn check_full into check_system complementary with normal check.
      toollib: Fix a mis-merge in _process_all_devs (duplicated pvs -a output).
      lvmetad: Fix a corruption-prone race in error path.
      lvmetad: Flush a VG if it goes completely missing due to pv_found.
      lvmetad: Fix getting vgid_old & avoid removing in-transition VGs.
      test: Add a regression test for pvcreate -ff.
      test: Use klogctl in the harness instead of reading /var/log/messages.
      test: Time out the entire testsuite after an hour.
      test: Increase the overall timeout to 3 hours.
      toollib: Fix a pool leak in _process_all_devs.
      report: Do not try to get dev_size of a NULL device.
      reporter: Set labeller on dummy labels (fixes missing fmt field).

Tony Asleson (16):
      python-lvm: Correct names
      python-lvm: Ensure library handle is correct after python gc() call
      vgreduce: Move _vgreduce_single functionality
      metadata.c: Call refactored vgreduce_single
      python-lvm: Test case change for vg.reduce
      lvm2app: Add ability to create PV with args
      python-lvm: Add addl. PV create arguments
      python-lvm: Update and enable unit test case
      lvm2app: Add VG/LV name validation
      python-lvm: VG/LV name validation.
      lvm2app: Reset buffer after retrieving error message
      lvm2app: Remove forward declarations.
      python_lvm_unit.py: Clean-up method names & scope
      python_lvm_unit.py: Add test for new name validate methods
      liblvm/python API: Additions & fixes
      liblvm: Save off and restore umask values

Ville Skytt?? (1):
      man: syntax and spelling fixes.

Zdenek Kabelac (115):
      report: add wrappers to set values and percents
      report: using _field_set_value
      report: fix dereference of string as uint64_t
      report: use _field_set_percent
      thin: report thin device id
      libdm: catch wrongly reported values
      cleanup: do not pass uninitialized space to selinux.
      cleanup: share the  nonremoval message
      tests: indent
      tests: used -n for fsck
      Makefile: fix build in non src dir
      tests: on 32bit test with <16T devs
      tests: skip raid test on 3.12.0
      filters: drop extra slash from sysfs path
      report: detect dev_get_size failure
      pv_write: check for lvmcache_add_mda failure
      snapshot: revert and move check to lvconvert
      snapshot: use lv_check_not_in_use
      activate: modify read_only when dev_manager exists
      dmeventd: move format text to printf
      dev-type: use text format as direct arg for printf
      archiver: add check for dm_pool_strdup
      do_flock: mark descriptor as closed
      fix missing header
      snapshot: code move
      dmeventd: drop duplicated code
      cleanup: use trigraph
      cleanup: use safe iterator
      cleanup: simplify  pv uuid display
      cleanup: use string directly
      cleanup: drop unused header
      cleanup: make gcc happier with initializers
      cleanup: use const format
      tests: add WARNED test to final list
      format-text: ensure aligment is not 0
      snapshot: drop find_merging_snapshot
      config: use int for type
      dmeventd: fifo init and close cleanup
      dmeventd: simplify error path
      snapshot: move code of old snapshot merge
      toollib: drop init of ret
      cleanup: use compound literals for wipe_lv
      cleanup: fold test into printf arg
      cleanup: drop extra dm_list_empty
      cleanup: use matching signed types
      cleanup: move declaration to the front
      cleanup: convert log_sys_error to log_sys_debug
      cleanup: convert log_error with log_warn
      cleanup: tab indent
      make: support per-object defines
      refresh: print error message with failing lv name
      snapshots: use lv_check_not_in_use
      lv_remove_single: add silent arg
      cleanup: code move
      cleanup: swap condition logic
      cleanup: size is already 64bit value
      merge: test only for meging origin
      thin: read table line with thin device id
      thin: snapshot merge support
      thin: merge support for device tree
      thin: merge removal
      thin: deactivation of merging thin snapshot
      thin: merge display
      thin: activation of merging thin snapshot
      thin: enable thin snapshot merge
      test: thin snapshot merge
      vgchange: move detection of remote exlusivness
      tests: monitor debug.log size
      tests: update pvmove-test
      tests: reuse timeout code for too long debug.log
      tests: replace built-in popen
      tests: drop RUN... already have this var elsewhere
      cleanup: gcc can't see the code path
      dev-cache: return success when ignoring dirs
      tests: harness prints debug.log
      lv_remove_single: update parameter name
      tests: do not run lvmetad tests without lvmetad
      tests: sysrq only when stuck with no output.
      tests: python test needs dmeventd
      tests: more limits for python test
      cleanup: tiny speedup of lib_dir checking
      cleanup: shorter raid initialization
      cleanup: share segtype macros
      thin: thin metadata resize unsupported with 1.9
      tests: count interrupted test as failed
      cleanup: simplify logging code
      cleanup: self compilable headers
      cleanup: remove duplicate code
      cleanup: improve tag processing
      cleanup: add missing backtrace in fail path
      thin: enable build of thin provisioning by default
      dmeventd: drop taking timeout mutex
      dmeventd: change locking code
      dmeventd: prevent busy looping on CPU
      dev-cache: skip double stat() call on each _insert
      cleanup: remove unused variable
      configure: update recent change
      tests: skip pool-label test for lvmetad
      tests: hide expected error message
      cleanup: skip double assign
      lv_dependency: scan also snapshots and extorigins
      tree_action: destroy devices from failing activation
      Revert "tree_action: destroy devices from failing activation"
      tests: clear inactive table before resuming in teardown
      device: if BLKPBSZGET is unavailable, enforce 512
      thin: accept const struct
      libdm: pass dnode to callback
      lvmetad: add parentheses around assignment
      liblvm: mark constant as unsigned
      tests: use compiled lvm for clvmd executed lvs
      cleanup: indent
      libdm: preload revert after failing callback
      libdm: WHATSNEW
      fsadm: use xfs_repair when available
      tests: update testing for xfs


