From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 30 Jun 2015 16:18:02 +0000 (UTC)
Subject: v2_02_123 annotated tag has been created
Message-ID: <20150630161802.D53FB60B69@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=769ec24a488d654d13f45c49c2d33013df6db2f6
Commit:        769ec24a488d654d13f45c49c2d33013df6db2f6
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2015-06-30 16:11 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2015-06-30 16:11 +0000

annotated tag: v2_02_123 has been created
	    at 769ec24a488d654d13f45c49c2d33013df6db2f6 (tag)
       tagging a3af8b062654efda7f07196ede6e25262c88852c (commit)
      replaces v2_02_122

Release 2.02.123.

54 files changed, 2345 insertions(+), 433 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlWSv+EACgkQIoGRwVZ+LBcV4ACgwZMPxsFj4aJLKk537GRq7C2D
KdQAn1Ul231IkRUeTPSAUzoUFG5FjEkN
=YcMN
-----END PGP SIGNATURE-----

Alasdair G Kergon (5):
      post-release
      man: Add missing env vars to lvm man page.
      libdm: Rename struct time_value variables.
      conf: Regenerate.
      pre-release

David Teigland (6):
      lvmetad: add invalidation method
      Reread a VG if the lvmetad copy is stale
      Reread global state the lvmetad copy is stale
      doc: mention new invalid states in lvmetad_design
      libdaemon: allow main processing function to be specified
      libdaemon: add comment about using main and init

Ferenc W??gner (1):
      makefiles: avoid bash == operator syntax, use = instead

Peter Rajnoha (29):
      config: add support for config value formatting flags
      config: cleanup default values for some configuration settings with array values
      config: use proper unconfigured default values for use_lvmetad and use_lvmpolld settings
      config: display global/umask in octal form
      configure: add DEFAULT_USE_BLKID_WIPING
      config: allow empty values for {thin,cache}_{check,repair}_options
      config: devices/filter and devices/global_filter setting have 'a/.*/' as default value
      config: regenerate configure.in to accomodate all recent changes
      WHATS_NEW: recent commits - config value format flags
      lvmconfig: add --withspaces option
      make: use lvmconfig ... --withspaces when generating lvm.conf and lvmlocal.conf
      commands: --withspaces also for config and lvmconfig cmd aliases
      config: also clone associated id when cloning node using dm_config_clone_node{_with_mem}
      lvmconfig: add --type full to display full tree of settings
      lvmconfig: display comment about value from existing config being used
      lvmconfig: do not display settings with undefined default values
      refactor: rename read_tags fn to _read_str_list and use it for string lists in general
      refactor: rename alloc_printed_tags fn to _alloc_printed_str_list and use it for string lists in general
      cleanup: remove unused tags.c file
      refactor: rename _out_tags fn to _out_list and use it for string lists in general
      config: regenerate lvm.conf.in and lvmlocal.conf.in
      conf: make time format configurable
      toolcontext: use proper set of chars to check time format against
      lv: time: increase buffer to 4k in lv_time_dup
      cleanup: time: error out on incorrect time_format and indentation in config_settings.h
      select: add support for range reserved values and flagging named-only values
      cleanup: report: use internal wrapper for various variables used for handling reserved values
      configure: set DEFAULT_FALLBACK_TO_LVM1 in configure and use it in config_settings.h
      report: add support for time (basic)

Zdenek Kabelac (8):
      cleanup: avoid printing gcc warning
      tests: newer version needed for ext-orig
      tests: skip when snapshot does not work
      tests: use vgscan after enable_dev
      snapshot: add synchronization point
      tests: workaround udev problem
      tests: deactivate before remove
      tests: tests needs pre 1.13 thin-pool extorg


