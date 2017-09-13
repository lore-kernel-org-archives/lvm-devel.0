From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 13 Sep 2017 15:56:59 -0400
Subject: v2.02.174 annotated tag has been created
Message-ID: <201709131956.v8DJuxkI008984@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=761691e233fabddfbf678b3a988fce99d39591f4
Commit:        761691e233fabddfbf678b3a988fce99d39591f4
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2017-09-13 19:38 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2017-09-13 19:38 +0000

annotated tag: v2.02.174 has been created
	    at 761691e233fabddfbf678b3a988fce99d39591f4 (tag)
       tagging 918f0a92daef84867e0df4b422c3de2a36997f17 (commit)
      replaces v2_02_172

Release 2.02.174

Assorted fixes and small improvements, including an extension to
dmsetup for activating more than one device with a single command.

As of this release, we're also pushing the code to github:
  https://github.com/lvmteam/lvm2
and will handle any issues reported at
  https://github.com/lvmteam/lvm2/issues

81 files changed, 1782 insertions(+), 857 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlm5iu8ACgkQIoGRwVZ+LBdCwgCfWI67MvWO3jaZ0/xvgwl5qjU1
KBwAoM8aCqMfl6N6X8jDEhR8FGDoKJ62
=oAdS
-----END PGP SIGNATURE-----

Alasdair G Kergon (24):
      post-release
      clvmd: add debuglog mutex
      clvmd: add client id to debug log messages
      clvmd: Fix client list corruption
      lvmetad: Suppress accept error on clean shutdown
      commands: fix lvm shell segfaults
      docs: Refresh kernel target docs
      format_text: Extend FIXME to reduce label scans
      raid: avoid lv_size compiler warning
      pre-release
      post-release
      dmsetup: Add concise table output format.
      make generate
      dmsetup: Add minor number to concise table output format.
      tools: Introduce exit code EINIT_FAILED.
      toolcontext: Improve invalid units error message.
      ioctl: Allow minor without major.
      dmsetup: Add --concise to dmsetup create.
      lvmconfig: Add options to produce file preamble
      pvcreate: Disallow --bootloaderareasize with --restorefile.
      pvcreate: Wipe cached bootloaderarea when wiping label.
      pvcreate: Use maximum metadata area size with --restorefile
      README: Include new github links
      pre-release

David Teigland (24):
      lvmlockd: use lock on thin pool when command names tdata
      lvmlockd: fix revert in lvcreate
      lvmlockd: use DM_UUID_LEN for buffer size
      commands: centralize shell vs script vs command decision
      commands: fix handing of ENO_SUCH_CMD in script
      lvm: run help from -h|--help
      lvm: report error if options are set before command
      pvs: use dummy structs in duplicate processing
      vgchange: separate change locktype and allow recovery
      vgchange: split out code for lockstart and lockstop
      vgchange: split out code for systemid
      man: remove hyphen escapes from source
      commands: expand comment on configuring option vals
      lvmlockd: fix lm running check during adoption
      lvmlockd: global name doesn't apply to sanlock
      commands: recognize -? for help
      commands: recognize lvm command -?
      lvmlockd: zero extended lvmlock LV
      lvmlockd: add comment about temp ls name
      lvmlockd: fix mutex unlock
      man lvmthin: change fsck references
      lvmlockd: print error about starting lock manager
      lvmlockd: fix check for no running lock manager
      lvmlockd: always disallow mirror splitting

Eric Ren (3):
      comment: update
      cleanup: fix some typos
      man: specify slow device when creating origin LV

Heinz Mauelshagen (8):
      test: return 0 if ignoring 'a' device health chars is requested
      raid: fix allocation/activation of reshape space
      lvconvert: allow reshaping in the cluster and on open devices
      report: fix data_offset/new_data_offset reporting
      raid: use return_0 for better backtracking
      raid: add data_offset incompatibility segment type flag
      raid: add validation checks for segment data_offset member
      raid: more validation checks for segment data_offset member

Huan Zhang (1):
      lvmlockd: miss adopt orphaned resources

Marian Csontos (1):
      tests: utils.sh six stacktrace

Peter Rajnoha (3):
      udev: also create /dev/disk/by-part{label,uuid} and gpt-auto-root symlinks
      pvcreate: fix check for 2nd mda at end of disk fits if using pvcreate --restorefile
      test: pvcreate-bootloaderarea: pvcreate --restorefile --bootloaderarea not supported anymore

Zdenek Kabelac (218):
      fsadm: fix shell globbing
      fsadm: remove surrounding $()
      fsadm: split local var dev
      fsadm: no mixing string and array
      fsadm: add -r to read
      fsadm: make if statement more clear
      blkdeactivate: replace obsoleted syntax
      blkdeactivate: double quote
      blkdeactivate: drop unused var
      blkdeactivate: split local declaration and assign
      blkdeactivate: more readable if-then-else-fi
      blkdeactivate: quote literal
      lvmconf: fix test for setting external locking type
      lvmconf: double quote
      lvmconf: prefer well defined and
      lvmdump: double quote
      lvmdump: replace printf
      lvmdump: drop extra $
      lvmdump: legacy syntax
      lvmdump: drop useless cat
      lvmdump: replace individual redirects
      lvmconf_lockingtype2: preferable syntax
      lvmconf_lockingtype2: double quote
      lvm2_cluster_activation_red_hat.sh: double quote
      vgimportclone.sh: no mixing string and array
      vgimportclone.sh: double quote
      vgimportclone.sh: cannot trap signal 9
      vgimportclone.sh: avoid legacy syntax
      vgimportclone.sh: add -r to read
      vgimportclone.sh: drop extra $
      vgimportclone.sh: use well defined tests
      vgimportclone.sh: do not quote regex
      clvmd_fix_conf.sh: legacy code
      clvmd_fix_conf.sh: double quote
      tests: aux.sh double quote
      tests: aux.sh use pgrep
      tests: aux.sh drop unnecessary $
      tests: aux.sh no mixing string
      tests: aux.sh using grep -c
      tests: aux.sh separately assign
      tests: aux.sh array assing
      tests: aux.sh add -r to read
      tests: aux.sh fix pid handling
      tests: check.sh double quote
      tests: check.sh assign separately
      tests: check.sh no mixing string
      tests: check.sh using grep -F
      tests: check.sh drop unnecessary $
      tests: check.sh better if
      tests: check.sh eliminate useless cat
      tests: inittest.sh  double quote and mixing string
      tests: lvm-wrapper.sh double quote
      tests: lvm-wrapper.sh legacy syntax
      tests: utils.sh double quote
      tests: utils.sh no mixed string array
      tests: utils.sh arithmetic
      tests: utils.sh avoid iterating over ls output
      tests: utils.sh separately assign
      tests: get.sh double quote
      tests: get.sh declare and assign separately
      tests: api updates
      tests: check.sh uses array for list
      tests: check LV in proper VG
      tests: aux do not specify bitmap for raid0
      tests: aux prepares lvmdbusd
      tests: correcting  globbing usage
      tests: aux.sh use subshell for simple redirection
      raid: ensure enum is defined
      man_generator: release buffer after use
      coverity: just make impossible division by zero
      tests: aux.sh fix pattern
      tests: export many shell vars with 1 command
      tests: aux.sh check cd result
      tests: aux.sh drop useless echo
      tests: aux.sh use grep -E
      tests: aux.sh replace sed call
      tests: aux.sh double quote
      tests: aux.sh check for already present config
      tests: get.sh use simplier tr
      tests: utils.sh assign directly
      tests: correcting usage of '==' in bash
      tests: double quote
      tests: use bash
      tests: drop wc -l when grep -c works
      tests: use bash array
      tests: replace egrep
      tests: use read -r
      tests: scripts double quote
      tests: cleanup msg
      tests: aux.sh move corosyn
      tests: aux.sh common pattern for starting daemons
      tests: aus.sh avoid duplicating arg list
      tests: aux.sh  tweaks
      tests: math drop uncessary $/${}
      tests: avoid masking return values
      tests: fix possible misspelling
      tests: drop unneeded cat
      tests: drop unneeded echo
      tests: drop unneeded check
      tests: drop unneeded ;
      tests: drop useless literal
      tests: drop extra sourcing of utils
      tests: fix quoting
      tests: replace legacy code
      tests: fix tests variable
      tests: add space to split words
      tests: replace cat usage
      tests: check result directly
      tests: improve loop
      tests: secure rm call
      tests: assign as string
      tests: correcting usage of $@
      tests: check mirror_images_on fixed
      tests: fix working with devs in array
      tests: fix caller of mirror_images_on
      tests: mixes string and array
      tests: cleaner written eval
      tests: use well defined test
      tests: simplify and doublequote
      tests: fix array usage
      tests: assign path
      tests: using prepare_vg
      tests: avoid using readarray
      cleanup: whitespace
      tests: improve test logic
      tests: avoid unbound shell var usage
      tests: correct typo
      tests: double quote
      tests: check.sh simplify in_sync
      tests: hardening - no unbound vars
      tests: improve logic for a race to catch abortion
      tests: aux.sh better loop logic
      tests: more vars bounded
      tests: more exact test
      tests: drop type
      tests: bounds still more vars
      tests: utils.sh  drop gdb_commands.txt
      tests: fix detection of running dmeventd after test
      tests: use properly quoted device list
      tests: properly check variables were defined
      tests: fix for new hardened bash
      tests: add some delay after dmsetup
      tests: delay read of cache pool data
      tests: bound variables
      tests: wait for udev to minize race windows
      tests: aux.sh better teardown loop
      tests: skip test for non dirty cache
      tests: aux.sh integrate both teardown loops
      tests: aux.sh fix double quote
      tests: add udev_wait before tearing scsi_debug
      tests: utils.sh looks for more dumps
      tests: use get_devs
      lvmetad: fix memory leaks
      devcache: correct logging severity for connection
      clvmd: fix valgrind warning
      clvmd: fix valgrind memory report
      lvmcmdline: validate size as double
      numbers: strtod or strtoul need reset of errno
      cleanup: drop const from allocated value
      cleanup: shorten dump output code
      cleanup: drop extra compare
      lvmcmdline: enhance acceptance of size numbers
      dev-cache: avoid hashing same data again
      lvmetad: cleanup
      tests: extend lvcreate size validation
      tests: utils.sh look for more coredump places
      tests: aux.sh also uses increseed hardening protection
      tests: aux.sh correcting bounder values
      test: repeat rediscovery few times
      tests: aux.sh some backward compatible updates
      tests: better support for unbound vars for older shell
      lvmcmdline: restore digit check
      lvmcmdline: enhance locales check
      tests: aux.sh limit device
      tests: avoid endless loops
      tests: aus.sh better defaults
      tests: aux.sh fix wait_pvmove_lv_ready
      dmsetup: simplify check of parsed cookie value
      cleanup: constify used parameter
      cleanup: add braces in macro
      tidy: prefer not using else after return
      tidy: else after continue
      tidy: drop unneeded return
      tidy: name all parameters
      tidy: drop unneeded cast
      tests: aus.sh fix md teardown
      raid: move syncing with udev into function
      raid: reshape synchronization point
      tidy: declaration names match implementation
      thin: warn about too big chunks size
      man: fix generated paths
      libdm: log_warn
      makefiles: RT_LIB
      makefiles: use gcc warns with gcc only
      makefiles: fixing linking
      makefiles: cleanups
      tests: update makefile
      configure: improve test for realtime clock
      configure: tune  BUILD_DMEVENTD
      makefiles: fix tested vars
      makefiles: script executable missed dynamic
      makefiles: add DEFS_$@ for cxx
      tests: update makefiles
      tests: update checked message
      libdm: fix errpath for control node creation
      lvmlockd: shorter code
      lvmcache: check for lvmcache_foreach_mda return code
      debug: add stack trace point
      locking: avoid descriptor leak for nonblocking mode
      daemonize: more unified code
      lvmlockd: avoid double unlock of client_mutex
      lvmlockctl: fix check for failing close
      lvmlockd: log pthread_join errno code
      reporting: validate time parsing with strtol
      dmsetup: add missing -- for option
      dmsetup: validate strtol reading
      cleanup: easier to read code
      deamonize: restore detection of errors

Zhang Huan (1):
      lvmlockd: reduce io impact for finding sanlock lv free lock offset


