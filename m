From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 13 Sep 2017 15:57:09 -0400
Subject: v2_02_173 annotated tag has been created
Message-ID: <201709131957.v8DJv9kZ009319@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7e9d7a481be5042b433bc8986b7e39b6c1dba763
Commit:        7e9d7a481be5042b433bc8986b7e39b6c1dba763
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2017-07-20 15:59 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2017-07-20 15:59 +0000

annotated tag: v2_02_173 has been created
	    at 7e9d7a481be5042b433bc8986b7e39b6c1dba763 (tag)
       tagging 88f15659374042f7657d73393f73e267d752b4e1 (commit)
      replaces v2_02_172

Release 2.02.173

A variety of fixes including some important ones for clvmd to avoid some
reported crashes after machines have gone down.  Work is continuing to
improve the recently-added raid enhancements and in particular reshaping
so please continue to use these with caution.

371 files changed, 3942 insertions(+), 2646 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAllw1xQACgkQIoGRwVZ+LBd1XwCgrXO1CO1t7RNxKyA0IkdTSzi9
R70An0Whqb/fJaxeAyrgzcJ5cDRZ0uYo
=YeKN
-----END PGP SIGNATURE-----

Alasdair G Kergon (10):
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

David Teigland (8):
      lvmlockd: use lock on thin pool when command names tdata
      lvmlockd: fix revert in lvcreate
      lvmlockd: use DM_UUID_LEN for buffer size
      commands: centralize shell vs script vs command decision
      commands: fix handing of ENO_SUCH_CMD in script
      lvm: run help from -h|--help
      lvm: report error if options are set before command
      pvs: use dummy structs in duplicate processing

Eric Ren (3):
      comment: update
      cleanup: fix some typos
      man: specify slow device when creating origin LV

Heinz Mauelshagen (7):
      test: return 0 if ignoring 'a' device health chars is requested
      raid: fix allocation/activation of reshape space
      lvconvert: allow reshaping in the cluster and on open devices
      report: fix data_offset/new_data_offset reporting
      raid: use return_0 for better backtracking
      raid: add data_offset incompatibility segment type flag
      raid: add validation checks for segment data_offset member

Huan Zhang (1):
      lvmlockd: miss adopt orphaned resources

Marian Csontos (1):
      tests: utils.sh six stacktrace

Peter Rajnoha (1):
      udev: also create /dev/disk/by-part{label,uuid} and gpt-auto-root symlinks

Zdenek Kabelac (187):
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


