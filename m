From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 20 Oct 2021 10:10:51 +0000 (GMT)
Subject: v2_03_14 annotated tag has been created
Message-ID: <20211020101051.F34563857C42@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e38f017a9f929a010995019bf9eadea229d28014
Commit:        e38f017a9f929a010995019bf9eadea229d28014
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2021-10-20 10:08 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2021-10-20 10:08 +0000

annotated tag: v2_03_14 has been created
	    at e38f017a9f929a010995019bf9eadea229d28014 (tag)
       tagging 819a35cc9133889b5efc4833d8191e3e71396552 (commit)
      replaces v2_03_13

Release 2.03.14

- New udev autoactivation.
- vdoimport renamed to lvm_import_vdo.
- Add IMA support with 'dmsetup measure' command.
- Improved VDO support.
- New appmachineid option for global/system_id_source config option.
- New log/journal config option (and --journal CLI option)
- Many bug fixes, improvements, and clean ups.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJhb+qfAAoJELkRJDHlCQOfgVwP/0YuD/B/WbPvaq8ArfoCaWOO
dARd2coatQH9vBX8fw7S4hbV9EFNKCdgG8esMz3DIXq79OnR2awf6mAtUFQx7MMm
yYYd7kKzvULDM5Z5qKX6s+PAjdGo3R6/SAYKNq+acSZMzDpHs+1mNP5wp1tF1s9a
NK4f3MGYSKJW5ne09YZi9OEPQ6ku/MX/9uPo8UqwLAVReRFJkUeEsZDpjdVI/2AY
LOKuoxVZZypG/ixH5im41xpd8Roji6GG7P0n3ysdbIjy1hBnFR85gl6RaEN1nM+Q
HaiYhsqGB7WE4F0+0Dj4q1PnLMvX1NoHlliiqWlZYOoZkjTsSr5q8cZNgTTfAv8d
dhG69KSUgqyxl3FWXYqNMqrfCLSdZhgqMb2Z+xBIH3hI3SX9rEuxzw74ZbFdlqUW
YhCiv4ZU26Z0u5SBtpuK8STANZKsSm+tNL1Nh7sLrBJvMdWxbdI5D3joI87o0I+P
X8I89kOm9hwgfSSdqbxFI4hPMT54DqanCe/jkLZCbp+fI5ZQx8THlYjXTTHJRvdG
SMTHVm+7dObIWdsFDcJXHQ2eEVcBgabPljbxjSrWDBr4sIVzF24VVab80lTib37B
anRZgtGZglCGghrhP6Q7jjVtKPDWraQwLi9uK60gjTHkO6O/a91sMHWngerFixRD
zd2uqSo/i+6v+iIuKWIj
=vQTo
-----END PGP SIGNATURE-----

Adrian Ratiu (1):
      man-generator: initialize struct stat to avoid MSAN error

Alasdair G Kergon (1):
      libdm: dmsetup measure support for IMA

Alex Xu (Hello71) (1):
      add missing sys/file.h include

David Teigland (30):
      toolcontext.h: use bit field in struct
      cov: lvmlockd: rewrite string copies to avoid warnings
      cov: clean up pvid and vgid usage
      lvmdevices: check yes option for adding duplicate
      tests: adjust for check_devicesfile
      devices: apply ignorelockingfailure to devices file lock
      logging: messages for found metadata
      devices file: recognize old locking_type 0
      vgimportclone: fix when duplicates are both in the devices file
      devices: restrict device id types to specific major numbers
      pvremove: apply devices file
      cov: lvmlockd read_adopt_file free structs on error path
      add --nohints option
      lvmdevices: allow deviceidtype with addpvid
      lvmcache: follow pv_id/pvid naming convention
      lvmlockd: update error message
      handle bad metadata text in vg_read path
      device_id: update stacked PVs for vgchange uuid
      config: comment all default settings
      config: change default use_devicesfile to 1
      system_id: new appmachineid option
      pvscan: add options listlvs listvg checkcomplete
      logging: to the systemd journal
      new udev autoactivation
      fix syslog setting
      devices file: unmatching system id should just be warning
      toollib: remove all devices list from process_each_pv
      fix lvmcache_add log_debug pvid
      fix segfault handling duplicate PVs
      pvscan: only add device args to dev cache

Marian Csontos (8):
      post-release
      vdo: Rename vdoimport to lvm_import_vdo.
      spec: Rename vdoimport to lvm_import_vdo.
      configure: update
      make: generate
      WHATS_NEW: update
      pre-release
      post-release

Vojtech Trefny (1):
      lvmdbusd: Use ID_FS_TYPE UDev property in udevwatch

Wu Guanghao (1):
      cmdlib_lvm2_init: release cmd on failure path

Yi Wang (1):
      lvchange: fix lvchange refresh failed for dm suspend or resume failed

Zdenek Kabelac (157):
      vdo: rename vdoimport to lvm_import_vdo
      vdo: skip zeroing for VDO LV
      vdo: fix conversion of large virtual sizes
      vdo: support lvcreate with skipped activation
      vdo: fixes
      makefiles: sanitize environment
      tests: remove all debug logs when using die
      vdo: add support for auto-unsafe writePolicy
      vdo: lvm_import_vdo fix max_discard size
      vdo: better message for missing device
      vdo: more lvm_import_vdo fixes
      vdo: read new sysfs path
      tests: check lvm2 parses vdo statistics
      vdo: lvm_import_vdo script needs to continue when vgname does not exist
      vdo: man page updates
      vdo: prompt with no return failure
      filters: fix memleak on mpath filter destroy
      cache: fix parentheses for migration_threshold
      cache: filter out unsupported policy settings
      cache: implement better revert path
      libdm: enhance tracking of activated LVs
      tests: add test for handling unknown cache settings
      tests: increase size of thin-pool for newer mkfs
      cov: fix copy from tmp_name buffer
      cov: do not try to change passed in argv
      cov: keep 64bit arithmetic
      cov: keep time calculation ready for 2038
      cov: initialize attr
      cov: initilized more struct members
      cov: add some initializers
      cov: hide false positive warning
      cov: make it aware we need these headers for muslC
      cov: remove unused variable setting
      gcc: remove invalid attribute
      gcc: remove unused vg setting
      clang: avoid double free on error path
      clang: keep final_opts_list initialized for all paths
      clang: keep metaname initialized
      clang: free on arg parsing
      cleanup: free already does NULL check
      debug: change message level
      lvm_import_vdo: --dry-run automatically verbose
      cleanup: typo fix
      lvmlockd: better error path
      clang: add explicit test for VG
      clang: ensure new_len is at least 1
      gcc-fanalyzer: notices 'du' could be NULL
      gcc-fanalyzer: explicit test null not pass
      gcc-fanalyzer: use zeroed memory
      gcc-fanalyzer: add extra check for origin_from_cow
      gcc-fanalyzer: better losetup error path
      gcc-fanalyzer: some explicit NULL checks for tests
      gcc-fanalyzer: rewrite _fetch_string
      gcc-fanalyzer: drop zeroing of pointers
      tests: fix test of read buffer
      tests: use single funtion to get random value
      cov: pvck validates setup_device return value
      cov: add error path for daemon_request_extend
      cov: check fid instance is created
      cov: handle teoretical sysconf failure
      cov: better handle reallocation of adapt_file
      cov: use different variable name
      cov: handle better leak reports
      cov: ensure data is not derefenced
      cov: check for possible NULL segtype
      cov: make read buffer obviously zero ended
      cov: add explicit NULL pointer check
      cov: better defined constructors
      cov: capture runtime exception
      cov: test for fixture being NULL pointer
      cov: validate syscall result
      cov: ignore syscall
      cov: hide reports from optarg being NULL
      cov: mask some warning about leakage
      cleanup: better wording
      tests: a bit more fancy way to initialized struct
      gcc: avoid warns on missing braces with older version
      gcc: avoid name colision with function pv_id() from metadata.h
      tests: len always initialized
      shellcheck: tests fixes
      shellcheck: warning enhancements
      clang: check for buffer existance
      gcc-fanalyzer: helping understand answer is not null
      gcc-fanalyzer: remove unneded zeroing
      gcc-fanalyzer: zallocate memory for clean buffer
      cov: ensuring buffer is zeroed
      cov: check strchr for NULL
      cov: check for function result
      cov: sanitize function environment
      cov: check dev_get_size result
      cov: ignore leak of fd descriptor
      tests: raise required version for conversion
      make: generate
      gcc: use more zero length arrays
      gcc: match types
      libdm: support DM_NAME_LIST_FLAG
      devicemapper: add DM_NAME_LIST_FLAG
      devicemapper: in sync with libdm
      dmsetup: fix measure handling
      metadata: remember crc32 when writing vg metadata
      metadata: remember parsing size of VG metadata
      metadata: optimize reading metadata copies in scan
      metadata: avoid excessive check of /etc/localtime
      cov: make more obvious buffer is zero ended
      configure: check ffs __builtin_ffs versionsort
      configure: replace AC_HELP_STRING with AS_
      utils: define macro for ffs
      make: fix compilation for some compiler
      make: fix compilation for undefined RAID_INTERNAL
      make: replace legacy use rindex with strrchr
      make: opened can be needed for either defines case
      make: build without versionsort
      cov: ignoring
      cov; matching enum type
      cleanup: use first parameter uint
      cleanup: reuse existing code for free path
      cleanup: use already known lv size
      debug: shorter code
      metadata: simplify code
      debug: fix stack tracing
      metadata: enhance internal error
      archiving: refactor code to allocate less memory
      cleanup: remove unused code
      cleanup: always initialize historical ptr
      cleanup: all lvmcache_add users pass char with 0
      cleanup: skip zeroing buffer overwritten by memcpy
      cleanup: use dm_list_empty
      archiving: update refactoring
      debug: better error message
      makefiles: use proper install prefix for python dbus
      configure.ac: improvement
      configure: updates
      log: also build without systemd_journal_support
      make: generate
      debug: reduce some debugging noise
      configure: missed braces
      gcc: archive reoder struct vars
      gcc: always initialize vg_complete
      configure: bash var typo
      unit-test: better check for O_DIRECT
      makefile: enhance run-unit-test target
      configure.ac: enhance systemd testing
      configure: update
      configure: fix use of withval
      cov: avoid using NULL info
      cov: validate subcommand existance
      cov: ignore close result
      cov: do not drop already known error state
      cov: check pointer before dereferencing
      cov: ensure id is always initialize
      cov: check device_ids_write return code
      dev-cache: skip different filesystems on dir scan
      cleanup: use const char buffer
      configure.ac: remove unused part
      configure: update
      dev-cache: better detection of filesystem
      dev-cache: enhance dir scan also for non-udev build


