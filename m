From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 18 Dec 2017 15:53:53 -0500
Subject: v2.02.174 annotated tag has been created
Message-ID: <201712182053.vBIKrrYN026376@lists01.pubmisc.prod.ext.phx2.redhat.com>
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
      replaces v2_02_173

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

Alasdair G Kergon (14):
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

David Teigland (16):
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

Heinz Mauelshagen (1):
      raid: more validation checks for segment data_offset member

Peter Rajnoha (2):
      pvcreate: fix check for 2nd mda at end of disk fits if using pvcreate --restorefile
      test: pvcreate-bootloaderarea: pvcreate --restorefile --bootloaderarea not supported anymore

Zdenek Kabelac (31):
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


