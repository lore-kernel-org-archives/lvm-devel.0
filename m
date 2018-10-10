From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 10 Oct 2018 07:30:00 -0400
Subject: v2_03_00 annotated tag has been created
Message-ID: <201810101130.w9ABU0sK031757@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=03996bb0970d94d9ed5b8a0a9a0041ee87305c73
Commit:        03996bb0970d94d9ed5b8a0a9a0041ee87305c73
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2018-10-10 09:27 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2018-10-10 09:27 +0000

annotated tag: v2_03_00 has been created
	    at 03996bb0970d94d9ed5b8a0a9a0041ee87305c73 (tag)
       tagging f8462cff9224594385c3b9f89785c28995151824 (commit)
      replaces v2_02_178-rc1

Release 2.03.00

This is the first release from the 2.03 branch.

Major changes:

* Deduplication and compression - support for VDO volumes.
* Dropped clvmd with lvmlockd as a replacement.
* Dropped liblvm2app with D-Bus API or libblockdev as possible replacement.
* Dropped lvmetad without replacement.

Plus many changes inside.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJbvcYQAAoJELkRJDHlCQOf2PAP/R/FAbUk0HT+4UIv2I1YneeT
5Eqg/hKU1iOCR/TvDqQD25OzjANKxnvZCGocStuN8Gc96YR/wHIqUZSDcSJDdqPW
DqLwjrKPQNiqUvNDACChl03f04aWt+9PycTCANsq1PrcNhz3McUg9A64BvshjUEC
txCyY1VSsdZTZ/ZqKqa6CPOY6lDyFoJ5bNVV4ZTngSnTA6onNUX42DpP1odhoTx0
a1Q9keF5NfgdjFXoDatXC+rll7aotuxOLhvC4T0VbOa23ppZ8RNFcpmatG41+id8
cS+AO1ebz/0HBAb3pQUh/NIhMZ0ocJhlMLM54BZo4pw8mv0r8TM7Gj5ikipsAw+2
TQvc3kv+fZh18SRcQ8CIaev5gOooR2T/ATSrYHiss4L0cnl2zY//IGZY2dKmxEd0
SRwDY36dM8nwsYyJSqzrC3KhjuqlFlgUbozqHcKP4MGxYvC5qPxyjlVa2Wn9grQx
Q37zS+dRUBsj+jO/h4wqDT3ESGV8c9//EkNBrre77ojX7nj5ZggTuTSJWenOAcrh
rChf+yrmo0UIFm13cdtOaOz/8bPMaPFCxSsWywWCHRzU/HIyB9qd9Tv8L7lO0ZGk
HhFF2nttgciet3RdU5kAE/zDJUIymHyVHqQB8r4jLLx/x1sWFWsr6Xu0xLIgSWM6
ZwxDrjjcR8luZf2WSYnB
=Zb78
-----END PGP SIGNATURE-----

Alasdair G Kergon (1):
      format_text: Use versionsort to sort archive files

Bryn M. Reeves (1):
      dmsetup: fix error propagation in _display_info_cols()

David Teigland (134):
      scan: refresh paths and retry open
      scan: removed failed paths for devices
      tests: fix skipping logic for lvmpolld and lvmlockd
      tests: some missed skip with lvmlockd
      lvmlockd: accept repeated global lock requests
      tests: separate lvmlockd tests with or without lvmetad
      lvmlockd: do not use an LV lock for some lvchange options
      config: revert to normal locking when no cluster
      lvmlockd: enable mirror split and merge with dlm lock_type
      lvmlockd: enable lvcreate of thin pool and thin lv in one command
      lvmlockd: enable creation of cache pool with lvcreate
      tests: enable lvmlockd for passing tests
      tests: vgcreate-usage update for lvmlockd
      tests: vgchange-usage update for lvmlockd
      lvmlockd: fix vgimportclone of a shared VG
      pvremove: skip lvmlockd locks for forced clearing
      tests: process-each-duplicate-pvs update for lvmlockd
      tests: add missing file
      lvmlockd: enable repairing shared VG while reading it
      tests: enable vg repair tests with lvmlockd
      tests: enable pvmove-restart with lvmlockd
      lvmlockd: enable lvcreate of new LV plus existing cache pool
      tests: enable lvcreate cache tests with lvmlockd
      tests: change lvcreate syntax to allow lvmlockd
      vgs: add report field for shared
      lvmlockd: enable lvcreate -H -L LV
      tests: enable lvmlockd with tests using lvcreate -H -L LV
      tests: enable metadata-balance with lvmlockd
      lvmlockd: fix reverting new lv in error path
      tests: enable lvcreate-pvtags with lvmlockd
      lvmlockd: improve error message for existing lockspace
      tests: enable more working tests with lvmlockd
      tests: enable non-working tests with lvmlockd
      man lvmlockd: update list of limitations
      lvmlockd: primarily use vg_is_shared
      lvmlockd: clarify lock_type use for coverity
      devs: clear coverity warning about null info
      scan: clean exit for alloc failure
      Remove clvmd and associated code
      devices: clean up io error messages
      lvmlockd: fix missing lock_type null check
      Remove more clvm code
      Remove unused clvm variations for active LVs
      Remove VG lock ordering check
      use exclusive file lock on VG for activation
      Remove locking infrastructure from activation paths
      tests: remove -cn option from some commands
      tests: system_id remove clustered vg test
      Implement lock-override options without locking type
      devices: clean up io error messages
      lvmlockd: fix missing lock_type null check
      Remove more clvm code
      Remove unused clvm variations for active LVs
      Remove VG lock ordering check
      use exclusive file lock on VG for activation
      Remove locking infrastructure from activation paths
      tests: remove -cn option from some commands
      tests: system_id remove clustered vg test
      Implement lock-override options without locking type
      man lvmlockd: remove unnecessary reference to lvmetad
      Rework lock-override options and locking_type settings
      Remove more code that was only used by liblvm2app
      tests: don't look for liblvm
      Remove header declarations for removed functions
      Remove python bindings for liblvm2app
      tests: remove use of vgcreate -c option
      Removing locking layer from sync_local_dev_names
      Remove unused cache management from locking
      Remove unused cluster-related locking flags
      tests: remove vgsplit-usage cluster test
      Remove locking for non-vgs
      Remove lvmcache CACHE_LOCKED flag
      lvmlockd: skip repair lock upgrade for non shared vgs
      Remove checking for locked VGs
      Fix use of orphan lock in commands
      Clean up repair and result values in vg_read
      Remove the unused lock_hash in lvmcache
      tests: lvconvert-repair remove cluster test
      tests: lvmetad-pvscan-cache expect command to fail
      Remove code for loading other metadata formats
      Remove independent metadata areas
      filters: remove cache file in persistent filter
      Remove vgconvert
      tests: remove metadata-dirs
      tests: remove vgconvert usage
      Remove systemd script for starting shared VG
      Remove makefile entries for removed script
      lvmlockd: update method for changing clustered VG
      man: updates to lvmlockd
      man: update lvmsystemid wording
      Add cmd arg to more functions
      scan: use full md filter when md 1.0 devices are present
      config: add deprecated version for recently removed settings
      Remove unused device error counting
      report: show empty lock_type for none
      Drop --ignoreskippedcluster option
      Print advice about changing clustered VGs to shared
      bcache: remove extraneous error message
      scan: work around udev problems by avoiding open RDWR
      lvmlockd: fix another missing lock_type null check
      Remove code for using files as devices
      filter: use pointers to real addresses
      man: fix lvreduce example
      Revert "man: fix lvreduce example"
      pvscan: autoactivate without lvmetad
      tests: autoactivation tests for use without lvmetad
      tests: fix mkdir pvs_online
      Remove lvmetad
      tests: remove lvmetad tests
      lvconvert: restrict command matching for no option variant
      lvconvert: improve text about splitmirrors
      vgcreate: close exclusive fd after pvcreate
      mirrors: fix read_only_volume_list
      config: improve use_blkid_wiping
      bcache: reduce MAX_IO to 256
      filter: add config setting to skip scanning LVs
      tests: add scan-lvs
      tests: drop lvmetad bits
      tests: drop lvmetad parts of system_id test
      tests: remove lvmetad variation
      metadata: improve write and commit code
      tests: add metadata-full
      fix readonly activation override options
      remove unneded check to skip filter init
      lvmlockd: improve systemd service file
      Remove init scripts related to clvm and lvmetad
      add lvmlocks service to start and stop lockspaces
      More cleanup needed for dropped scripts
      radix-tree: default to simple version
      metadata: remove an unused and incorrect overflow check
      metadata: add comment about negative impact of rounding
      metadata: remove incorrect comment about alignment
      metadata: add direct size limit
      metadata: clarify comments about max size

Heinz Mauelshagen (18):
      segtype: add linear
      lvconvert: support linear <-> striped convenience conversions
      test: add convcenience conversion tests linear <-> striped
      WHATS_NEW
      lvconvert: reject conversions of LVs under snapshot
      test: new lvcreate-raid1-error-read.sh
      lvconvert: reject conversions on raid1 split trackchanges SubLVs
      lvconvert: reject conversions on raid1 split trackchanges LVs
      lvconvert: fix regression preventing direct striped conversion
      lvconvert: fix conversion attempts to linear
      test: add striped -> raid0 test script
      test: comment fixes
      lvconvert: avoid superfluous interim raid type
      lvconvert: fix interim segtype regression on raid6 conversions
      lvconvert: allow raid4 -> linear conversion request
      tests: adjust target version to enable reshape tests
      tests: bump dm-raid version to 1.14.0
      tests: fix lvconvert-raid-reshape-linear_to_striped-single-type.sh

Joe Thornber (64):
      Revert "Revert "build: Calculate dependencies at same time as compiling.""
      build: Don't generate symlinks in include/ dir
      device-mapper: Fork libdm internally.
      Merge branch 'master' into 2018-05-11-fork-libdm
      radix_tree: add remove method
      radix_tree_t: knock out some debug
      data-struct/radix-tree: pass the value dtr into create.
      Merge branch '2018-05-29-radix-tree-iterate' into 2018-05-23-radix-tree-remove
      radix-tree: call the value dtr when removing an entry.
      radix-tree: radix_tree_remove_prefix()
      radix-tree: radix_tree_iterate()
      radix-tree: fix some bugs in remove_prefix and iterate
      bcache: switch to storing blocks in a radix tree.
      radix-tree: fix some bugs in remove_prefix and iterate
      Merge branch 'master' into 2018-05-30-bcache-radix-tree
      Merge branch '2018-05-30-bcache-radix-tree'
      Merge branch 'master' into 2018-05-11-fork-libdm
      build: make sure selinux, udev and blkid libraries are linked.
      build: Link with -lrt
      build: get clvmd building again
      Merge branch 'master' of git+ssh://sourceware.org/git/lvm2
      build: link lvm2_activation_generator_systemd_red_hat with libdevice-mapper.a
      build: Get python dir building without the include/ dir
      Merge branch 'master' of git+ssh://sourceware.org/git/lvm2
      build: More tweaks to python include dirs.
      build: get separate builddir working again
      build: libbase.a
      build: base/Makefile
      device_mapper: fixup a couple of includes
      scripts/lvm2_activation_generator_systemd_red_hat: rewrite to use lvmconfig
      Merge branch 'master' of git+ssh://sourceware.org/git/lvm2
      test/unit: activation generator unit tests
      liblvm: remove lvmapi
      Update WHATS_NEW
      Merge branch '2018-06-05-remove-applib'
      test/unit: Rename Makefile.in -> Makefile
      base: Move list to base/data-struct
      device_mapper: rename libdevmapper.h -> all.h
      libdm: Stop libdm/misc/dmlib.h from including lib/misc/lib.h
      device_mapper: remove dbg_malloc.
      device_mapper: remove c++ guards from the header
      device_mapper: move hash.[hc] to base/data-struct
      various: some missing #include zalloc.h
      Merge branch '2018-06-04-data-structs'
      dmsetup: move to libdm/dm-tools/dmsetup
      dmfilemapd: Move to libdm/dm-tools
      device_mapper: remove libdm-stats.c
      radix-tree: FIx various bugs to do with removal
      radix_tree: add new test case
      radix-tree: More debugging of remove
      radix-tree: fix bug when erasing elts in remove_prefix
      Merge branch 'master' of git+ssh://sourceware.org/git/lvm2
      radix-tree: squash a pointer arithmetic warning
      radix-tree: Fix bug in remove_prefix()
      [radix-tree] alternative radix-tree implementation.
      [bcache] Remove unused 'hash' field from blocks.
      Merge branch 'master' of git://sourceware.org/git/lvm2
      [radix-tree] Add some extra checks to is_well_formed()
      [radix-tree] Fix bug in _dump
      [radix-tree] Fix bug in _degrade_to_n16
      [radix-tree] tidy up _degrade_to_n48
      [unit-test/radix-tree] Add a huge test case
      [build] switch back to the adaptive radix tree
      Merge branch '2018-09-13-radix-tree-bug'

Marian Csontos (20):
      post-release
      Merge remote-tracking branch 'origin/master'
      bcache: Fix null pointer dereferencing
      spec: Remove lvmetad
      spec: Remove python bindings
      spec: Remove unsupported config options
      build: Remove lvmetad leftovers
      spec: Add vdo files
      build: Update configure
      spec: Fix conditional
      test: Remove excessive comma resulting in empty flavour
      test: Check flavour is used and exists
      Add BSD 2-Clause License
      spec: Remove lvmconf refernces
      build: Update configure
      libdm: fix buffer overflow
      spec: No %ghost for dirs at tmpfiles.d
      build: make generate
      build: gcc can be fussy about order of libs
      pre-release

Peter Rajnoha (4):
      scripts: add After=rbdmap.service to {lvm2-activation-net,blk-availability}.service
      scripts: lvm2-activation-generator: add prefix for all kmsg messages
      scripts: lvm2-activation-generator: also log possible execv error
      configure: fix LVMCONFIG_PATH assignment

Zdenek Kabelac (110):
      man: another missed typo for thin plugin
      tests: improve usability on older systems
      build: compile fixes
      build: remove any leftover file
      build: fixes
      pvmove: improve lvs
      pvresize: add missing return
      pvresize: update message
      cache:  cleaner policy also uses fmt2
      build: drop exported symbols
      cleanup: updates message with dots
      tests: check proper support of fmt2 with cleaner policy
      tests: initial testing code for lvs while pvmove runs
      tests: drop unit subdir
      tests: updates test for raid scanning
      tests: check pvresize with metadata size
      build: update configure
      build: make generate
      build: link dmeventd plugins with internal libs
      build: use internal libs for lvm2cmd
      vgchange: start polling with option
      snapshot: improve checking of merging snapshot
      build: ensure configure.h comes first
      build: ensure libdm is built before dm-tools
      build: drop some lvm references from libdm making
      build: drop libdm referring from lvm code
      build: better srcdir builddir support
      device_mapper: drop unneeded function
      vgchange: fix error code in error path
      vgchange: move active assing
      vgchange: trace faling activation
      pvscan: code reshape
      pvscan: move start of polling into vgchange
      vgchange: start polling with activation
      systemd: add conficting sockets
      debug: missing trace
      tests: bigger lv
      build: cmirrord with internal dm lib
      tests: drop some clvmd refs
      man-generator: drop macro redefines
      man: stop installing clvmd man page
      scripts: clvmd gone
      tests: more tolerable makefile
      rpm: drop no longer present clvmd, lvm2app
      build: make generate
      build: include configure.h
      build: support --disable-silent-rules
      tests: fix rules for mke2fs.conf install
      utils: add clzll
      lv_manip: add extra internal error
      vcfgrestore: add prompt with active volumes
      cache: set areas count prior using it
      lv_manip: add new internal api function
      cache: use new api function
      lv_manip: use vgmem pool
      tests: update with --yes
      device_mapper: split _node_send_message
      device_mapper: split code for sending message
      device_mapper: add new _dm_task_create_device_status
      build: avoid rebuild deps for top-level makefiles
      build: drop some more old files
      locking: memory locking ONLY with suspending reason
      memlock: extend exception list
      lv_manip: add name of failing LV into error message
      lv_manip: do not check extents for any virtual target
      device_mapper: deactive new nodes when load fails
      device_mapper: relocate code for sending messages
      vdo: enhance status parser
      allocator: fix thin-pool allocation
      dev_io: no discard in testmode
      build: libdm preload dir is no longer needed
      cleanup: use last_seg
      tests: check how thin-pool allocation works
      allocation: add check for passing log allocation
      vdo: fix parsing vdo status
      build: unit test Makefile update
      device_mapper: convert vdo to use dm_ prefix
      tests: update vdo unit test to dm prefix
      build: not yet merged
      dmeventd: base vdo plugin
      activate: kvdo modprobe workaround
      build: add vdo configuration option --with-vdo=
      lib: new vdo segment configurable options
      device_mapper: basic support for vdo dm target
      build: install VDO small allocation profile
      vdo: introduce segment types and manip functions
      vdo: with created names use vpool
      vdo: component activation of VDO data LV
      vdo: support functions to map enums to string names
      vdo_manip: parsing status of VDO device
      check_lv_segment: internal vdo segment validation
      lv_manip: layout and role support for vdo segment
      dev_manager: add dev_manager_vdo_pool_status
      display: basic vdo segment lvdisplay and lvs support
      vdo: data percentage
      toollib: support new command rules queries
      args: new options for vdo segment
      lvresize: vdo support
      lvcreate: vdo support
      lvchange: vdo support compression deduplication change
      lvconvert: support to convert lv into vdopool
      vgchange: vdo support
      dmeventd: lvm vdo support
      tests: initial vdo tests
      cache: drop metadata_format validation
      mirror: fix splitmirrors for mirror type
      tests: splitmirror for mirror type
      tests: check policy mq can be used with format2
      dmeventd: lvm2 plugin uses envvar registry
      tests: check activation of many thin-pool


