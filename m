From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat,  2 May 2015 00:58:44 +0000 (UTC)
Subject: v2_02_119 annotated tag has been created
Message-ID: <20150502005844.E0EEF60643@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a6247f7eac41fc926843033c2ebfcf006ac531e6
Commit:        a6247f7eac41fc926843033c2ebfcf006ac531e6
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2015-05-02 00:42 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2015-05-02 00:42 +0000

annotated tag: v2_02_119 has been created
	    at a6247f7eac41fc926843033c2ebfcf006ac531e6 (tag)
       tagging bee2df3903d0956ba2e09ce9ae9ae55dfc5d3fd1 (commit)
      replaces v2_02_118

Release 2.02.119

151 files changed, 8960 insertions(+), 4140 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlVEHXUACgkQIoGRwVZ+LBeDKwCg+RI3yaFIxtElqY9fd7GxZ/bz
P4UAoP2uNCxWA1DCdlRVefBxJ2K0v5PO
=QPJU
-----END PGP SIGNATURE-----

Alasdair G Kergon (16):
      post-release
      datastruct: Add str_list_add_list.
      metadata: Move alloc_handle init/destroy fns.
      alloc: Only report cling tag errors once.
      alloc: Pass alloc_handle through to _reserve_area.
      alloc: Log PV tags when reserving areas.
      cache: Set correct vgid when changing PV header.
      alloc: Add A_PARTITION_BY_TAGS to avoid sharing.
      alloc: Respect cling_tag_list in contig alloc.
      doc: Update dm kernel files.
      libdm: Add DM_INTERNAL_SUSPEND_FLAG.
      libdm: Add uuid/devno to ioctl failure log message.
      conf: Avoid temp files when generating config.
      config: Introduce lvmconfig.
      config: Remove newly-exposed default settings.
      pre-release

David Teigland (30):
      tests: add clvm case to system_id.sh
      config: include full comments
      config: update description
      config: comments update
      config: editing descriptions
      config: update descriptions
      config: fix description syntax errors
      config: edit descriptions
      dumpconfig: add --withfullcomments option
      config: edit descriptions
      dumpconfig: add --unconfigured option
      toollib: fix duplicate handling in process_each_pv
      dumpconfig: add --ignorelocal
      config: remove duplication of settings
      generate example.conf.in, lvmlocal.conf.in
      config: thin_repair_options and cache_repair_options are undefined
      make: let generate use the just built libdm
      make: autoconfisms for generate
      Improve duplicate PV handling
      config: thin_disabled_features default should be undefined
      config: fix check_options array
      config: fix a couple mistakes with defaults
      example.conf.in: regenerate
      config: improve the description of options lists
      devices: improve handling of duplicate PVs
      man: 'lvm config' is preferred over 'lvm lvmconfig'
      man: 'lvmconfig' is preferred over 'lvm config'
      man: lvmthin section about use-policies
      man: expanded explanation of pvscan
      man: expanded explanation of lvmetad

Heinz Mauelshagen (1):
      lvcreate: do not silently accept '-m #' with raid4/5/6

Michael Lass (2):
      README: fix link to lvm-devel mailing list
      systemd: stop lvm2-pvscan at .service before lvm2-lvmetad.service

Ondrej Kozina (28):
      tests: fix check for existence of a pvmove Lv
      tests: add helper routine for pvmove status check
      pvmove: fix pvmove --abort or pvmove w/o parameters
      tests: add pvmove --abort test
      tests: add pvmove --abort for all moves in progress
      polldaemon: proper error check in _poll_vg fn
      polldaemon: fix indentation in _poll_vg fn
      pvmove: move poll code in before refactoring
      lvconvert: move poll code in before refactoring
      pvmove: split pvmove_update_metadata function
      polldaemon: prepare wrapper poll_daemon function
      polldaemon: separate daemon_parms initialisation
      polldaemon: alter few lines related to interval
      vgchange: remove redundant check
      toollib: do not spawn polling in lv_change_activate
      toollib: close connection to lvmetad after fork
      tests: [new] check pvmove resume works as expected
      pvmove: fix wrong error path in _update_metadata
      WHATS_NEW: update for various commits
      tests: add double quotes around add_to_kill_list parms
      tests: simplify removal of dangling bg procs
      tests: try harder to kill all dangling procs
      update copyright info in various files
      pvmove: make log messages more comprehensible
      polldaemon: remove redundant log messages
      toollib: code cleanup in lv_spawn_background_polling
      libdaemon: introduce support for exit on idle
      WHATS_NEW: commit  e0a62b8fdc8d041c14ca523643e319

Peter Rajnoha (35):
      metadata: process_each_lv_in_vg: get the list of LVs to process first, then do the processing
      metadata: vg: add removed_lvs field to collect LVs which have been removed
      tests: select-tools.sh: add test for fix in commit c9f021de0b4d2c873ef5b97d17c602d0380359fd
      tests: move thin-related test from select-tools.sh to select-tools-thin.sh
      lvm.conf: fix typo as -> is in read_only_volume_list comments
      systemd: stop lvm2-monitor.service before dm-event.service
      select: mention { } use in lvm.8 man page and '-S help' properly
      config: add note about 'vsn' macro use in config_settings.h
      report: lv_metadata_size, data_lv and metadata_lv also reports properties for cache pools
      lvmconf: add --enable-halvm, --disable-halvm, --services, --mirrorservice, --startstopservices options and use proper global/use_lvmetad default value
      WHATS_NEW: previous commit f814d7wq
      man: lvmconf: more notes on --services option
      blkdeactivate: check for lvm binary and skip LVM processing if not present
      make: move blkdeactivate script and blkdeactivate.8 man page installation from install_lvm2 to install_device-mapper target
      WHATS_NEW: commit 375ed98
      man: fix some formatting and also mention -vv
      select: fix matching reserved values while <,<=,>,>= is used in selection criteria
      report: add lv_ancestors and lv_descendants reporting fields
      cleanup: ancestors -> lv_ancestors, descendants -> lv_descendants
      refactor: rename struct cfg_def_item's 'unconfigured_path' to 'unconfigured_value'
      config: make it possible to set default unconfigured_value for settings of all types, not just strings
      config: also evaluate default unconfigured values in runtime for 'cfg_runtime' settings
      refactor: dumpconfig: keep --withcomments to display full comment and use --withsummary for one line summary
      lvmconfig: add --type list and -l|--list
      config: consolidate CFG_UNSUPPORTED and CFG_ADVANCED settings
      cleanup: lvmconfig man page typo
      lvmconfig: comment out settings with proper space/tab prefix
      lvmconfig: allow --withversions alone with --type list
      cleanup: config_settings.h: add some comments
      cleanup: config_settings.h: comments
      config: preparation for marking configuration nodes as deprecated
      config_settings: devices/cache, activation/mirror_region_size and activation/mirror_device_fault_policy are deprecated
      lvmconfig: add supporting code for handling deprecated settings
      man: lvmconfig: also mention '--type list' in synopsis
      config: add CFG_DEFAULT_COMMENTED to comment out default value on output

Petr Rockai (10):
      libdaemon: Export chain_node from config-utils.c.
      lvmetad: Track alternate devices for PVs.
      lvmetad: Issue warnings about duplicate PV UUIDs (client-side).
      NIX: Disable profiling in all but one configuration.
      test: Show all lvmetad messages (errors, warnings), not just debug+wire.
      NIX: Also install device-mapper-persistent-data on CentOS 7 & FC 19+.
      man: Escape single quotes in an example to avoid groff's unicode conversion.
      lvmetad: Avoid duplicate entries in the list of alternate devices.
      man: Fix references to lvmcache(7) that mentioned section 8 by mistake.
      spec: Pull in lvmconfig and associated manpages.

Tony Asleson (3):
      python: Make lv addTag/removeTag persistent
      python: Unit test ws fixes
      python: Fix ws liblvm.c

Zdenek Kabelac (104):
      tests: avoid multiple pids
      tests: update aux
      tests: temporarily trace  prepare_vg
      tests: pvmove better delay check
      tests: skip system_id test in cluster
      tests: drop vg2 at end of test
      lvmcache: skip drop when vg_write lock is not held
      debug: log scanned value
      tests: more duplicate testing
      tests: move exa test to separate file
      tests: add check sysfs_queue
      tests: deal with kernel and broken  lcm
      tests: fix test warning
      tests: drop check for awk
      tests: split bigger test
      tests: slowdown pvmove devs more
      tests: simplify check sysfs_queue
      tests: add  get first_extent_sector
      tests: enhance delay_dev
      tests: hide unwanted output
      tests: test update
      tests: delay only data area
      tests: better check for empty set
      tests: delay only data portion of device
      pvmove: don't crash when name is not found
      tests: slow down devices in outer loop
      tests: change default to 30s.
      tests: skip clvmd testing of mirrored LV vgsplit
      tests: when test fails collect more info
      tests: check scsi_debug support opt_blks
      clvmd: singlenode signals only when lock changes
      tests: put "" around dev path
      tests: use single lvmconf call
      tests: slowdown write on dev3 even more
      tests: handle debug.log from clvmd
      tests: extend delay
      cleanup: typo in comment
      cleanup: put easier tests first
      tests: slowdown mirroring more
      tests: hide unwanted output
      tests: sections in test separated
      tests: log parallel debug.log usage as problem
      tests: update runner
      makefiles: skip lvmetad tests
      tests: avoid dup of lvm.conf
      tests: stacktrace understands fullpath
      tests: integrate default thin/cache tool paths
      makefiles: check lcov file has content
      tests: rusage skipped only for skipped
      tests: update pvmove tests
      makefiles: fix usage of default value
      tests: preserve "" around dev
      tests: no tables for no devices
      tests: fix aux have test
      tests: hide error output
      tests: move stamp handling
      tests: align test result in batch mode
      tests: move print of replaced vars
      tests: shell-fu
      debug: add new envvar
      debug: use epoch for dmeventd logging
      tests: use new debug logging feature
      debug: change envvar
      tests: add extra keyword for timing control
      tests: update to renamed envvars
      nix: install also mdadm
      tests: allow to use sysfs filter
      tests: explicitely ignore result code
      tests: notify drops log always
      tests: use 800ms delay
      tests: drop DEBUG log after success
      tests: install also api test
      makefiles: avoid // in datadir usage
      tests: simplify teardown
      tests: aux works better with installed_testsuite
      tests: add missing "" around dev
      tests: fix md raid test on real /dev
      tests: try more advanced clean
      tests: check sysfs more generically
      tests: allow add printable skip message
      tests: aux for mdadm
      tests: use new help in aux
      tests: drop debug test
      tests: more descriptive aux
      tests: always zero disk header
      tests: more help#
      lvmetad: drop unused vars
      tests: bash-fu for lvmconf
      tests: minimize teardown when uneeded
      tests: lvmconf update
      tests: watch out for RAM size
      tests: move kernel_at_least to aux
      tests: wait between remount
      tests: hide error message
      tests: move conf preparing
      tests: rename kill_tagged_processes
      tests: lower version of dm-delay
      tests: no lvmetad reload for debugless output
      tests: run api tests from startup dir
      tests: disable usage of fuser
      tests: minor simplifications
      tests: free -h is quite new option
      tests: configure use_lvmetad when needed
      tests: more advance cleanup of running pvmove

bkabrda at redhat.com (1):
      python: python 3 compat patch for lvm2


