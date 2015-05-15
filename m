From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 15 May 2015 22:30:01 +0000 (UTC)
Subject: v2_02_120 annotated tag has been created
Message-ID: <20150515223001.4ED2560905@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3027329708f0db2f8fec15a6fc767424a349b8f4
Commit:        3027329708f0db2f8fec15a6fc767424a349b8f4
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2015-05-15 22:23 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2015-05-15 22:23 +0000

annotated tag: v2_02_120 has been created
	    at 3027329708f0db2f8fec15a6fc767424a349b8f4 (tag)
       tagging 0300730cc9ba058df830d9cb0981183b90ad17db (commit)
      replaces v2_02_119

Release 2.02.120.

299 files changed, 5668 insertions(+), 768 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlVWcd0ACgkQIoGRwVZ+LBfJ7QCaA1NwuuThZhaKxdulPsF63wpS
iMEAn2SP0OwoIJ3ApoRjTV4U6zyXbEMi
=kbmh
-----END PGP SIGNATURE-----

Alasdair G Kergon (4):
      post-release
      man: Fix recursive lvm-config man page.
      libdaemon: Fix socket reuse error paths.
      pre-release

David Teigland (16):
      lvmcache: update lvmcache with alternate device
      lvmcache: choose preferred device once
      toollib: avoid repeated lvmetad vg_lookup
      lvmcache: set device in label when switching devs
      lvmcache: set device in label when switching devs V2
      vgimport: fall back when lvmetad is not running
      config: avoid configurable description text
      config: description can refer to etc location
      lvm.conf: add more information to the comment header
      config: add comments to match current example.conf
      config: thin_pool_chunk_size_policy is not undefined
      config: thin_pool_chunk_size_policy should be commented
      config_settings.h: improve lvmpolld config description
      example.conf.in: apply previous improvements to example.conf
      config: remove UNDEFINED from thin_pool_discards and thin_pool_zero
      config: remove UNDEFINED from cache_pool_cachemode

Ondrej Kozina (41):
      polldaemon: move lvconvert_get_copy_vg code
      polldaemon: move lvconvert_get_copy_lv code
      polldaemon: respect lv_attr parm in poll_get_copy_lv
      lvconvert: code cleanup and preps for refactoring
      polldaemon: get get_copy_vg ready for refactoring
      polldaemon: optimise out waiting after polling
      polldaemon: refactor polling interfaces
      polldaemon: introduce _nanosleep function
      polldaemon: make wait_for_single_lv public
      WHATS_NEW: update for recent changes
      tests: do not restart lvmetad when not necessary
      lvmpolld: Add standalone polldaemon.
      lvmdump.sh: print out lvmpolld service status
      lib/polldaemon.h: remove trailing whitespace
      lvmpolld: set use counters properly in lvmpolld_store
      lvmpolld: by default spawn lvpoll cmd with -An
      tests: remove forgotten set -v in aux
      libdaemon: shutdown on idle also in non-systemd environment
      lvmpolld.8.in: clarify the timeout parameter
      new debug class for lvmpolld client code
      lvmpolld-client.c: be more specific about fallback on error
      libdm-common.c: remove trailing whitespace
      tests: remove forgotten -vvvv option
      lvmpolld-client.c: use lvmpolld debug class where appropriate
      lvmpolld: dump cleanup
      libdaemon: suggest daemon already running
      libdaemon: fprintf(stderr...) -> ERROR()
      lvmpolld: label known return codes
      lvmpolld-client.c: explain known return codes
      lvmpolld.8.in: hide origin of lvmpolld man page
      lvm-lvpoll.8.in: man page for built-in command
      commands.h: reorder lvpoll options
      lvmdump.8.in: describe lvmpolld related option
      lvm.8.in: add reference to lvpoll built-in command
      lvpoll.c: replace arg_count with arg_is_set
      lvpoll.c: harden the checks for proper LV name
      pvmove.c: relocate id components extraction
      lvmpolld: introduce client functionality
      lvmpolld: add long option variants for all short ones
      lvmpolld: don't return success on invalid option
      lvmpolld.8.in: man page rewrite

Peter Rajnoha (1):
      metadata: use log_debug_metadata instead of general log_debug for BA debug messages

Tony Asleson (5):
      lvm2app: Add signed numerical property values
      python: Build correct python value for numerical property
      python: Check for NULL value before constructing string property
      lvm2app: Correct missing string properties
      Python: Improve lv property test coverage

Zdenek Kabelac (73):
      clvmd: missed newline in help text
      configure: detect /run dir
      lvm2app: call fin_locking in lvm_quit
      tests: use odirect
      tests: use 800ms write delay
      tests: more waits on restart
      tests: dd needs to fail in this case
      tests: wait for scsi device to appear
      tests: validate passed LVM_TEST_DEVDIR
      tests: check for clvmd process entry
      tests: drop extra scsi init
      tests: check for open_count
      raid: reread status when 0 is reported
      tests: play better with mdadm
      lvmcache: copy just 32bytes
      pvcreate: fix test for wiping status
      format_text: properly validate PV size for restore
      format1: check for lvm1_system_id
      cleanup: drop unneeded int test
      cleanup: drop unneeded header file
      cleanup: indent mismatch
      cleanup: cast minor to dev_t
      cleanup: use 64bit ulongs
      debug: show sys errors
      debug: tracing error path
      debug: extra validation of passed segment
      tests: missing vg
      tests: better filter
      cleanup: remove extraneous parentheses
      cleanup: drop extra test for NULL
      tests: avoid clobering dmesg
      tests: missed conversion
      configure: use_lvmetad/polld configurable
      spec: writable instalation
      makefiles: dist and rpm target
      spec: now generated
      tests: disable lvmetad and lvmpolld
      makefile: cleanup after build
      makefiles: move clean
      tests: typo in aux
      nix: now some files are generate so keep them
      tests: split flavours
      makefiles: runtime spec.inc
      makefiles: use LN_S
      configure: spec.inc is generated at build
      tests: ndev by default
      spec: packaging polld
      nix: more base packages
      configure: start to use AS_IF
      makefiles: drop way too generic deps
      makefiles: testclient is not valid target
      makefiles: use fullpath when in assign
      nix: fix socat package name
      configure: preserve CXX/CFLAGS
      configure: set optimize flags when CFLAGS is unset
      makefiles: drop DEBUG mangling
      makefiles: assign vars before include
      makefiles: protect CFLAGS
      conf: system_id_source is referencing CONFDIR
      nix: socat is quite new package
      tests: do not use |&
      tests: respect @CONFDIR@/machine-id
      nix: add pkgconfig
      spec: package old sysv initscript for lvmpolld
      nix: add more packages
      nix: drop util-linux
      makefiles: use srcdir
      makefiles: disable po file targes
      nix: socat for f18, nc for f17
      libdm: new dm_task_get_info with internal_suspend
      man: missed y|n for wipesignatures
      spec: new man page
      mirror: use proper 64bit constants


