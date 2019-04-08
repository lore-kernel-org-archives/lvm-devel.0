From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon, 8 Apr 2019 03:52:51 -0400
Subject: v2_03_02 annotated tag has been created
Message-ID: <201904080752.x387qpRU029251@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=95e710df30907d6a8117dc330a30807e7a2474c6
Commit:        95e710df30907d6a8117dc330a30807e7a2474c6
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2018-12-18 14:16 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2018-12-18 14:16 +0000

annotated tag: v2_03_02 has been created
	    at 95e710df30907d6a8117dc330a30807e7a2474c6 (tag)
       tagging 5230a1a9af99970add4c7fd4f80013323a937167 (commit)
      replaces v2_03_01

Release 2.03.02

Bugfix release.

Among other things, this resolves following issues:

* Fix (de)activation of RaidLVs with visible SubLVs,
* Prohibit mirrored 'mirror' log via lvcreate and lvconvert,
* Use sync io if async io_setup fails, or use_aio=0 is set in config,
* Fix libdevmapper-event library linking.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJcGQJIAAoJELkRJDHlCQOfEOgQAKNZt1JjnN/cG7Gd4XyNstbO
O1kfES+o1rNAMMGxdp2u3z5nxiHJMFVRB04EHvlxkX2wN5iYn3dWuH+OaCqUTI8x
C6El5EZFgOAmFYcT3Ad97pr7E+50886xzuhesnpAUG5KCH5VewbKoXvuKImCoa/d
tH5yEgtCpBuj58Tm5wmxjkrh4jDEqzWpuSItrN4ux1a4P4guulAgdo9hMuM6Q+cn
POAQ6O3/zcIZBzi+G473ssVKJgN4y7TOZrWDCZtf2kjg3wrKGlaEqPKoeIOKJDWA
ZEuiXGj/ILm/hEdDb3F6BpCzJWk3nH+xjLCo66KwvFSy8BmfM/Lnym6g7hS2OsVG
bNV6rFd0NoaMrFdy9g3Zrq+M7FZfKDLpj7YhcnTzNaiFJBt4ZvEAvbLxeFgXNKdC
edtvfwrOLSBZSj4WcRhaYK2cI8szt4xaO6dmcXvQQOhwWT9jbyNhhfCf43XD4mTy
aeHgILUpLSNrOp1Gjs5xwjPDWyvHqWwdO1nXcVUxGo+dSvYMRvvup7bdiH01Y1au
H6+Ccu0ABBqcVsOo6nGKQp5gKcxX+B1DkynnXQPjKQl2py1AA/VwHmV8XjtOFY5I
3qL4q0skTkljElU/A+DOihcxLApB5n0+7uewHEPlszyYtccbKA2o7QY6DJrcwdpi
wI4gFSBjy1P/bBsz5ISG
=jtdn
-----END PGP SIGNATURE-----

Bryn M. Reeves (2):
      libdm-stats: move no regions warning after dm_stats_list()
      dmsetup: fix stats report command output

David Teigland (30):
      lvmlockd: fix size/resizing of internal lvmlock LV for sanlock
      lvmlockd: deactivate lvmlock LV in vgchange
      lvmlockd: fix handling of sanlock release error
      devices: reuse bcache fd when getting block size
      man: lvmcache update
      man: remove cluster references
      man: remove clvmd man page
      man lvmdump: remove clvm reference
      man: remove lvmetad
      man pvscan: replace lvmetad text
      pvscan: background option is not used
      man: pvscan updates
      remove unused backgroundfork option
      man: remove scattered lvmetad references
      man: remove some clvmd references
      lvm2-monitoring service shouldn't refer to lvmetad
      scripts: remove lvmetad from makefile
      io: use sync io if aio fails
      bcache: sync io fixes
      pvscan systemd service for event based activation
      blk_availability service drop lvmetad
      lvmlockctl: wait by default when stopping
      lvmlockd: vgchange locktype with yes option
      config settings: fix version 3.0.0
      devs: use udev info to improve md component detection
      pvscan: use correct dev filters
      remove unused lvmetad filter
      remove unused full filter
      man lvmlockd: lvextend with gfs2
      lvmlockd: fix missing LV lock for lvconvert repair

Heinz Mauelshagen (4):
      lvcreate/lvconvert: prohibit creation of/conversion to mirrored mirror logs
      WHATS_NEW
      raid: fix (de)activation of RaidLVs with visible SubLVs
      man: document 's' RAID attribute bit

Marian Csontos (11):
      dmeventd: Fix libdevmapper-event linking
      udev: 69-dm-lvm-metad.rules is still needed
      build: Upse PYTHON_CONFIG env.variable when set
      post-release
      Revert "configure: update"
      configure: update
      tests: Remove unsupported mirrored mirrorlog
      build: Remove reference to undefined @BUILD_LVMETAD@
      build: Remove badly placed `@`
      build: make generate
      pre-release

Ming-Hung Tsai (1):
      lvmanip:  uninitialized members in struct pv_list (#10)

Peter Rajnoha (1):
      scan: md metadata version 0.90 is at the end of disk

Tony Asleson (4):
      lvmdbusd: Dump blackbox newest first
      lvmdbusd: Handle missing lv_attr table lookups
      lvmdbusd: Update table lookup for health lv_attr
      lvmdbusd: Update table lookup for state lv_attr

Zdenek Kabelac (98):
      label: add stack trace for failing dev_set_last_byte
      cov: remove uneeded code
      cov: split check for type assignment
      cov: explicit ignore if failures
      cov: overflow before widen
      cov: add missing check for dm_strncpy
      cov: trace failing pthread_kill
      cov: mark warning as expected one
      cov: hide intentionaly ptr arithmetic report
      cov: remove unused assigns
      cov: avoid unsing unchecked label_scan_open
      cleanup: move cast to det_t into MKDEV macro
      debug: missing backtrace
      pvscan: add error checking for write of online files
      tests: add wait for udev
      tests: fix shell quoting
      activation: trimming string is expected
      devicemapper: retry remove even for subLVs
      configure: update
      tests: keep results configurable
      devicemapper: retry mirror leg deactivation
      tests: add wait loop
      libdm: add memory barrier
      tests: secure data erase
      tests: extend
      tests: raise minsize of xfs
      tests: drop unwanted backup
      tests: makefile fixes
      tests: still more libs needs
      tests: correcting header file enclosure
      tests: prefer internal header
      tests: skip when gcore from gdb package is missing
      tests: skip portion of test for lvmpolld
      tests: create whole path with mkdir
      tests: skip part of test
      tests: update parm for new kernel
      tests: speed-up testing full of lvm2 metadata
      tests: generate slightly less volumes
      sanlock: update headers
      tests: missing copyright
      tests: update required raid target
      base: use calloc
      makefiles: improve lcov generator
      makefiles: updates for less verbosity
      makefiles: avoid dependency calcs for base dir
      makefiles: improving cleaning rules
      makefiles: add missing srcdir
      make: generate config update
      make: generate man update
      tests: add mising udev_wait
      tests: use select with dmsetup
      tests: requires at least 2 iterations
      tests: updates
      tests: reduce memory footprint
      tests: drop use_lvmetad from unit test
      configure: update
      makefiles: ignore missing files
      makefiles: clean unit-test
      tests: extend sleep
      rpm: install lvm2-pvscan again
      device_mapper: fix incorrect dm_strncpy usage
      device_mapper: optimize dm_pool_strndup
      libdm: optimize dm_pool_strndup
      device_mapper: move internal header to front
      makefiles: avoid clustering out
      makefiles: ensure test dir can run unit-test
      gcc: avoid shadowing index
      gcc: avoid shadowing activate_lv
      gcc: avoid shadowing use_aio
      gcc: ensure sector is initilized
      libdm: do not add params for resume and remove
      libdm: add DM_DEVICE_ARM_POLL
      libdm: print params only for ioctls using them
      libdm: use libdm header
      headers: use configure.h as 1st. header
      headers: use full path header instead of -I directive
      makefiles: correct libdm dependency
      makefiles: drop unneeded include path
      makefiles: local headers first
      makefiles: some leftovers from lvmetad
      cleanup: some local headers first
      debug: drop extra tracing
      lvconvert: ensure proper init of pv_list
      dmfilemapd: avoid linking with DL_LIBS
      dmeventd: fix linking with libdevmapper
      dmeventd: do not link internal libraries to plugins
      lvm: drop usage of dl library
      cmirror: link with libdm
      makefiles: sort
      makefiles: drop unneeded LIBS add
      makefiles: quite install
      makefiles: missing cleaning
      makefiles: no longer used define
      makefiles: allow to set LIBS in Makefiles
      makefiles: dm-tools improve Makefile
      makefiles: correcting login of makefile
      makefile: fixes build for older system
      makefiles: also fix build of unit test


