From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 10 Aug 2015 00:11:01 +0000 (UTC)
Subject: v2_02_127 annotated tag has been created
Message-ID: <20150810001101.3470560DA3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bc3d89c8c7a5537bc603e16c74702ac65f5418ff
Commit:        bc3d89c8c7a5537bc603e16c74702ac65f5418ff
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2015-08-09 23:40 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2015-08-09 23:40 +0000

annotated tag: v2_02_127 has been created
	    at bc3d89c8c7a5537bc603e16c74702ac65f5418ff (tag)
       tagging 0b05048341c6ededae7b271c08101decd7d0d184 (commit)
      replaces v2_02_126

Release 2.02.127.

This release introduces a new command, dmstats, for reporting device
I/O statistics.  This command is still undergoing active development
and we might still change any of the new interfaces in a subsequent
release (including command line options, output format and defaults,
field names, the new library functions etc.): they should not yet be
considered frozen.

82 files changed, 7353 insertions(+), 1330 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlXH5qIACgkQIoGRwVZ+LBdKuACgllek9x0oxhiV2KUYoUgosFBl
l8wAmgNhmMxkyY9HJGP4NB4nnbcwghgC
=3Xgr
-----END PGP SIGNATURE-----

Alasdair G Kergon (22):
      post-release
      post-release
      gitignore: Update for in-place build.
      configure: Add missing checks.
      configure: Enable realtime by default, if present.
      lvmlockd: Drop -lrt now handled by configure.
      libdm: Add dm_size_to_string to libdevmapper.
      dmsetup: Accept vg/lv name format.
      libdm: Add dm_timestamp functions.
      libdm: Require librt for new dm_timestamp.
      dmsetup: Rename _commands to _dmsetup_commands.
      dmsetup: Add _dmsetup to help and usage fns.
      dmsetup: _find_command returns const
      dmsetup: Add subcommand parameter.
      dmsetup: Allow commands to have subcommands.
      dmsetup: Tidy whitespace.
      libdm: Sort new exported symbols.
      libdm: Whitespace.
      libdm: Whitespace.
      dmsetup: Report timestamps of ioctls with -vvv.
      dmsetup: Also install dmstats.
      pre-release

Bryn M. Reeves (9):
      dmsetup: Add --count and --interval to reports.
      dmsetup: Use argcp and argvp.
      libdm: ensure new dm_timestamp objects are initialized
      libdm: fix report rows and headings memory and state leaks
      libdm: add dm_report_column_headings
      libdm: remove report interval support
      libdm: do not attempt to output column headings with --rows
      WHATS_NEW_DM: Update for preliminary stats commits
      dmstats: add libdm-stats library and 'dmsetup stats' command

David Teigland (13):
      lvmcache: add lock_type to VG summary and info structs
      vgcreate: improve checks for existing global lock
      vgremove: warn when removing sanlock global lock
      lvmlockd: small fixes and cleanup for lvmlockctl
      lvmlockd: create sanlock lv large enough for existing lvs
      vgchange/lvchange: allow deactivation without locking
      lockd: remove ignorelockingfailure checks
      lvmlockd: automatically remove the dlm global lockspace
      lvmlockd: handle loss of sanlock lease storage
      man lvmcache: mention LVs must be in the same VG
      man lvmlockd: update
      man: add lockd bits to relevant commands
      man: mention system ID in vgexport and vgimport

Marian Csontos (2):
      spec: lockd_dlm requires dlm-lib instead of dlm
      test: Update Makefiles

Peter Rajnoha (19):
      cache: fix regression causing some PVs to bypass filters
      dmsetup: remove dead code that covered "info -c -o help" case once
      refactor: toolcontext: add struct cmd_context_initialized_parts
      refactor: toolcontext: move lvmetad and lvmpolld init into separate function
      toolcontext: add switches to create_toolcontext for connections and filters init
      commands: add new NO_METADATA_PROCESSING flag to selected commands
      cleanup: toolcontext: make cmd_context more readable
      cleanup: toolcontext: move report_list_item_separator into its group
      toolcontext: use refresh_filters in refresh_toolcontext
      toolcontext: do not set cmd->initialized_connections = 0 on destroy_toolcontext
      report: recognize report field name variants without any underscores too
      report: update comment for _is_same_field fn
      report: also recognize variants without underscores for <prefix>_all fields
      coverity: fix possible resource leak in lvmpolld-core
      coverity: fix cppcheck warnings
      coverity: return value check in lvmlockd-dlm
      coverity: variable init must be done before its use
      coverity: check vg->lvm1_system_id is not NULL before calling strncmp with that
      man: document --nameprefixes


