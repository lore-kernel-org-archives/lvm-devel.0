From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 10 Nov 2022 13:22:38 +0000 (GMT)
Subject: v2_03_17 annotated tag has been created
Message-ID: <20221110132238.C06863858D1E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0ea00227b96a383479139e72db9168448eee48c9
Commit:        0ea00227b96a383479139e72db9168448eee48c9
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2022-11-10 13:11 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2022-11-10 13:11 +0000

annotated tag: v2_03_17 has been created
	    at 0ea00227b96a383479139e72db9168448eee48c9 (tag)
       tagging f8127c45c5fa8fc8e163565bfa2001a0bb8ae72e (commit)
      replaces v2_03_16

Release 2.03.17

Major feature is rework of lvresize (lvextend, lvreduce) handling of
nested file systems. New --fs and --fsmode options, see lvresize(8).

May bugfixes and improvements, noteworthy to lvmdbusd, VDO, and device_id.
-----BEGIN PGP SIGNATURE-----

iQJIBAABCAAyFiEE1QGkeEQK4v0TChvouREkMeUJA58FAmNs+JYUHG1jc29udG9z
QHJlZGhhdC5jb20ACgkQuREkMeUJA581/xAAoHPtvCyP/j9BChRLGqHKlmozYzbf
6CQlajiO+Kpj81LRSM+KeszzUFeaTBu2K65ca4bTecr/XKT8gmrWlPpuF9x35o4q
R500RlCQ1yXOPonCvzKSctVU7WH2OGlSOOGooTA+6GiZsQMwmluEUwYZb40BlwDl
Xz7trb/VP0N5WmO9wq1IY0iKPFCRb8QCYviL9vik3r6JQrTJ6pZF8wFKbujocC36
V5LTZWLrNzh+B6GVfAyssrLAy8BUleZdX80FiCnZfbC8vlU142AmJ/FG6VFQKOJ6
y13lLuClL6zBkk0VnVgyiw2+Gt6/ETuiek2us3y91MddnWwiUuxdLtAXzXHTl53v
OOIroqyJFHbccAg+koyB2XK3FtugB4g5FLUjdphbfJbAiq3ArUF09f+kRnwPClfu
P0Ju5RL7SP41WPY8ovjZZiXU7gl7886S66n5Wpd3AubaIHLFqKRepQK+bMN9tqOX
bGBXfvfbRwZBzZm1nLLhq8/c5hQYt/FfG6HRC80NZbXqOiuUVN+kPn9/r2eSSBoC
ruj3NLe23dS60xkhpGL1sC16Tzjpr7q+RQ8JcMSf7i46MwIAw3Zrt3fHc6+pPNnK
BWH7ePrsPBVIFWpS4EEr/fkgiDTYWMB48cr4UnmE/dGZWXeBKBdgJxXu4BOVWUTO
uDMN3ohSzbvaqQk=
=wqjW
-----END PGP SIGNATURE-----

David Teigland (42):
      devices file: move clean up after command is run
      devices file: fail if --devicesfile filename doesn't exist
      filter-mpath: handle other wwid types in blacklist
      filter-mpath: get wwids from sysfs vpd_pg83
      pvdisplay: restore --reportformat option
      exit with error when --devicesfile name doesn't exist
      apply multipath_component_detection=0 to duplicate PV handling
      devices file: fix pvcreate --uuid matching pvid entry with no device id
      vgimportdevices: change result when devices are not added
      vgimportdevices: fix locking when creating devices file
      fix fs block size detection
      remove libblkid flag BLKID_SUBLKS_FSINFO
      lvresize: restructure code
      lvresize: add new options and defaults for fs handling
      tests: skip new lvresize tests when missing new libblkid
      vgremove: remove online files in run dir
      covscan: free wwid strings in lvmcache
      make: move cmds.h
      lvreduce: use temporary flag when activating lv to check for fs
      change messages about libblkid features
      remove unused variables
      lvresize: let env var set lvresize_fs_helper_path
      lvresize: exclude new fs handling at build time
      lvresize: give special advice to reiserfs users
      blkid: fix BLKID_SUBLKS_FSINFO usage
      lvresize: move the lockd_lv earlier
      device id wwid adjustments
      device id: change space handling in t10 wwid
      device id: add new types using values from vpd_pg83
      tests: device ids using vpd data
      lvmdevices: use deviceidtype option strictly
      tests: skip lvresize tests without mkfs.xfs
      lvmlockd: fix warning
      tests: add comments to fsadm-renamed
      lvreduce: require active LV when no fs option is used
      lvreduce: change error message about --fs options
      cmd: save device_id_sysfs_dir
      device_id: remove debug trace
      vgchange systemid: use tag or select
      device_id: look for serial number in other locations
      device_id: handle duplicate serial numbers
      devices: factor common list functions

Lidong Zhong (1):
      lvmlockd: purge the lock resources left in previous lockspace

Marian Csontos (10):
      post-release
      spec: Use libedit for newer distributions
      configure: fix typo
      spec: use --with-default-use-devices-file=1 for rhel9+
      config: add correct unconfigured value for use_devicesfile
      configure: update
      spec: Workaround for failing build
      make: Fix build in chroot
      make: generate
      pre-release

Peter Rajnoha (24):
      shell: also output error message about max number of args hit with JSON format
      libdm: report: add DM_REPORT_GROUP_JSON_STD group
      libdm: report: remove double quotes around numeric values in JSON_STD output
      libdm: report: use 'null' for undefined numeric values in JSON_STD output
      libdm: report: enhance the way string list is stored internally
      libdm: report: separate basic and JSON+JSON_STD format in _output_field
      libdm: report: use proper JSON array for string list output in JSON_STD format
      config: recognize 'json_std' for report/output_format config setting
      args: recognize 'json_std' for --reportformat cmd line arg
      man: update lvmreport man page about json_std format
      make: generate
      report: fix pe_start column type from NUM to SIZ
      test: add report-format test
      WHATS_NEW: update
      report: report numeric values (not string synonyms) for NUM and BIN fields with json_std format
      lvmconfig: add --valuesonly option
      config: remove unnecessary copy of config line's space prefix before printing
      config: check for possible mempool errors in _out_line_fn
      shell: add pre-cmd log report object type and enable lastlog for it
      libdm: report: fix escaping of JSON quote char in reported fields
      args: add ARG_NONINTERACTIVE for cmds not supported in lvm shell
      report: values: add note about self-decriptive values to report
      report: fix lv_active column type from STR to BIN
      toollib: do not process just created historical LV

Tony Asleson (85):
      lvmdbusd: Correct conditional for lvm child process running
      lvmdbusd: Simplify child process env
      lvmdbusd: re-work lvm shell main
      lvmdbusd: Add debug output for which lvm binary is used
      lvmdbusd: Change unit test vdo minimum size
      lvmdbusd: Fix env variable LVM_DBUSD_TEST_MODE
      lvmdbusd: Remove the use of sub shell for lvm shell
      lvmdbusd: Job prop. Get/GetAll exec. immediately
      lvmdbusd: Don't require "lvm> " prompt for shell
      lvmdbusd: Correct grammar in lvm shell proxy comments
      lvmdbustest: Test job remove path when job not complete
      lvmdbustest: Correct comment spelling/grammar
      lvmdbustest: Increase number of LVs
      lvmdusd: Remove non lvm JSON output support
      lvmdbusd: Remove try/except for mkfifo
      lvmdbustest: Add test for property "Get"
      lvmdbustest: Use updated pyudev syntax
      lvmdbustest: Include major number 259
      lvmdbusd: Remove addl. checks on --nojson
      lvmdbusd: Move arg. setup/checking to function
      lvmdbusd: Add lockfile
      lvmdbustest: Remove force exception in _wait_for_job
      lvmdbusd: Re-work flight recorder data
      lvmdbusd: Add SIGUSR2 to dump flight recorder
      lvmdbusd: Remove unneeded command line args
      lvmdbusd: Remove exclusionary language
      lvmdbustest: nesting improvements
      lvmdbusd: Handle no lastlog
      lvmdbusd: Correct typos
      lvmdbusd: Make sure to set cfg.got_external_event
      lvmdbusd: Remove unused locking functionality
      lvmdbustest: Add test for passing log file in options
      lvmdbustest: Add test for external event
      lvmdbustest: Add test removing incomplete job
      lvmdbusd: fix hangs on SIGINT
      lvmdbusd: Correct typos
      lvmdbustest: Add DaemonInfo class
      lvmdbustest: Factor out tearDown implementation for re-use
      lvmdbustest: Add optional option to _create_num_lvs
      lvmdbustest: Add test_sigint test
      lvmdbustest: Add test for ensuring only 1 instance of daemon
      lvmdbustest: Add systemctl daemon start
      lvmdbusd: Set LVM_COMMAND_PROFILE=lvmdbusd
      lvmdbustest: Skip test_singleton_daemon running systemd svc.
      lvmdbusd: Add debug circular buffer
      lvmdbusd: WS, imports, grammar
      lvmdbusd: Don't report recoverable error
      lvmdbusd: Handle SIGINT quietly
      lvmdbusd: Re-work error handling for run_cmd
      lvmdbusd: refactor and correct fetch thread logic
      lvmdbustest: Skip test_nesting if scan_lvs is not enabled
      lvmdbusd: Don't output debug for fullreport exit code 5
      lvmdbusd: Use common function for traceback
      lvmdbusd: Re-work error handling
      lvmdbusd: Instruct lvm to output debug to file for fullreport
      lvmdbusd: Raise LvmBug exception for invalid JSON
      lvmdbusd: Remove duplicate code
      lvmdbustest: Utilize addCleanup in unit test
      lvmdbusd: Remove PID from log messages
      lvmdbusd: Use pseudo tty to get "lvm>" prompt again
      lvmdbusd: Handle 'exit' for lvm_shell_proxy
      lvmdbustest: Move signals to last
      lvmdbustest: Check for self.pvs
      lvmdbusd: Correct undefined var
      lvmdbusd: Use common func. for checking missing LV keys
      lvmdbusd: Check for KeyError in refresh
      lvmdbusd: Correct log_error for shell proxy
      lvmdbusd: Raise IOError instead of ignoring
      lvmdbusd: Call readlines instead of readline
      lvmdbusd: Include lvm debug output for lvmshell
      lvmdbustest: Add wrapper for injecting errors
      lvmdbusd: Remove --reportformat
      lvmdbusd: Correct get_object_path_by_uuid_lvm_id
      lvmdbusd: Register for SIGTERM
      lvmdbusd: Correct lvm shell signal & child process handling
      lvmdbustest: Make vg name suffix more unique
      lvmdbustest: Refuse to remove a VG we didn't create
      lvmdbustest: Re-work setUp
      lvmdbustest: Add test to stress mode changing
      lvmdbusd: Correct env. variable
      lvmnotify.c: Check to see if dbus daemon is running
      lvmdbustest: Add test for wipefs
      lvmdbusd: Always leverage udev
      lvmdbustest: Add test for copy signature
      lvmdbusd: Handle PV signature copy

Wu Guanghao (1):
      _vg_read_raw_area: fix segfault caused by using null pointer

Zdenek Kabelac (64):
      vdo: fix conversion of vdo_slab_size_mb
      tests: add lvm_vdo_wrapper
      tests: update for wrapper
      tests: skip running tests for non root user
      vdo: fix conversion of vdo_slab_size_mb 2nd
      man: space after size
      vdo: use single validator
      vdo: update info about memory
      vdo: use defines also for configuration defines
      vdo: report supported range in error path
      vdo: check vdo memory constrains
      vdo: add reformating to extent size aligned virtual size
      vdo: support v4 kernel target line
      vdo: enhance lvcreate validation
      vdo: suffle code for better error path handling
      cov: remove unused headers
      cov: restore disable_dm_devs also for error path
      make: generate
      lvconvert: correct test support for vdo-pool
      vdo: use only verbose log level for reformating
      vdo: fix --vdosettings parser
      autoreconf: support newer archs
      vdo: reset errno before strtoull
      vdo: extend volume and pool without flush
      mm: remove libaio from being skipped
      dmsetup: check also for ouf of range value
      devices: drop double // from sysfs path
      thin: rename internal function
      configure: check for mallinfo2
      configure: remove some obsolete or duplicate checks
      mm: preallocate memory only with glibc
      mm: use mallinfo2 when available
      gcc: eliminate warnings
      python: variable without destdir
      make: update make.tmpl
      tests: rework makefile
      tests: vdo emulation without vdo binary
      tests: skip this test for 5.19
      tests: remove slash
      tests: check for at least 1G of RAM
      tests: make damage optional
      tests: no caching for blkid in testing
      tests: lvextend update for 300M XFS
      tests: add thin requirement
      tests: add /dev requirement
      tests: use conv=fdatasync
      tests: writecache adapt to 300M XFS
      tests: fsadm 300m xfs
      tests: cache use 300M XFS
      gitignore: update
      tests: integrity switch to ext4
      makefiles: use single libs definition
      tests: discard update
      tests: validate CONFIG_HZ_1000
      make: generate
      configure: update use_devicesfile in example.conf
      device_mapper: add parser for vdo metadata
      dev_manager: accept misalined vdo pools.
      device_mapper: vdo V4 avoid messaging
      vdo: replace errors with debug
      vdo: enhance detection of virtual size
      tests: update test to handle different status
      lvcreate: fix error path return values
      vdo: improve validation message

corubba (1):
      lvmlockd: Fix sanlock lvmlock lv size calculation

