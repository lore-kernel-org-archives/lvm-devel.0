From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 12 Apr 2017 21:21:27 -0400
Subject: v2_02_170 annotated tag has been created
Message-ID: <201704130121.v3D1LRrQ020601@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b369397f21869b3e1bb0fc8d005599d444ae2c8e
Commit:        b369397f21869b3e1bb0fc8d005599d444ae2c8e
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2017-04-12 23:43 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2017-04-12 23:43 +0000

annotated tag: v2_02_170 has been created
	    at b369397f21869b3e1bb0fc8d005599d444ae2c8e (tag)
       tagging b9a16fe73bdbed8a9bece3fb33fb754d62ffb8d4 (commit)
      replaces v2_02_169

Version 2.02.170

Another development checkpoint release.  We have stopped adding
features as we work towards the next stable release, but please still
only use this release for testing purposes.

88 files changed, 1657 insertions(+), 1902 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAljuveMACgkQIoGRwVZ+LBd71gCfVV7uj+tMPu+shH+830v6lsGT
cMEAnAqwkwI1SUnuA2NUuzIK9bMun80h
=B/vY
-----END PGP SIGNATURE-----

Alasdair G Kergon (4):
      post-release
      make generate
      autoconf
      pre-release

Bryn M. Reeves (30):
      dmfilemapd: log closedir errors with log_sys_error()
      dmfilemapd: do not closdir(pid_d) unless it is open
      dmfilemapd: pass correct dirp to closedir()
      dmfilemapd: use *argv[0] when testing for absolute path (coverity)
      dmfilemapd: always close check file descriptor (coverity)
      dmfilemapd: always terminate link buffer after readlink(2) (coverity)
      dmfilemapd: always close link check file descriptor (coverity)
      dmfilemapd: fix off-by-one in fd comparison (coverity)
      dmfilemapd: free region table at end of _update_regions() (coverity)
      libdm: do not leak FIEMAP extent buffer if pool allocation fails (coverity)
      libdm: abort filemap update if pool allocation fails (coverity)
      libdm: do not attempt filemap cleanup if dm_stats_list() fails (coverity)
      dmsetup: do not start dmfilemapd if region creation fails (coverity)
      dmsetup: always close fd when leaving _stats_update_file() (coverity)
      libdm: use log_sys_error if dmfilemapd exec fails
      dmsetup: simplify branching in _stats_update_file()
      libdm: use DM_STATS_GROUP_* constants in dm_stats_create_regions_from_fd
      dmfilemapd: make filemap_monitor->nr_regions uint64_t
      dmfilemapd: fix len type in _filemap_monitor_check_file_unlinked()
      dmfilemapd: cast sysconf() return value to int
      dmfilemapd: use log_sys_error in _filemap_monitor_set_notify
      dmfilemapd: cast return value of strto* functions when needed
      libdm: make _find_extent() nr_extents argument uint64_t
      libdm: make _stats_resize_group() num_regions argument uint64_t
      libdm: use size_t for buflen in _stats_group_file_regions()
      libdm: use uint64_t where possible in filemap routines
      libdm: fix incorrect format specifier in _stats_resize_group()
      libdm: use correct FMTu32 format specifier for uint32_t
      dmsetup: replace (f)printf("
") with putchar/putc
      WHATS_NEW_DM: add recent dmsetup and dmfilemapd entries

David Teigland (26):
      lvchange: refresh command missing activationmode option
      man: fix description of --partial option
      commands: ignore partial option in most cases
      commands: recognize ignored options
      help: include cmd def info in verbose output
      commands: missing comma in cmd def option list
      help: print all options in abbreviated help output
      lvconvert: fix converting hidden lv to pool
      vgchange/lvchange: fix poll and monitor use
      lvchange: fix --poll value when set from option
      commands: fix misspelling of option value
      lvchange: fix missing return value
      lvchange/lvconvert: fix missing lvmlockd LV locks
      commands: check required option value when matching command
      man lvcreate/lvconvert: minor clean up rewording
      lvconvert: validate vg name prefix for pool metadata name
      man lvmraid: improve text layout
      lvconvert: prevent duplicate use of metadata lv
      lvconvert: require different LV for pool
      man lvmraid: use same style as generated pages
      man lvmraid: fix line wrapping in examples
      raid_manip: fix typo warning message
      man lvmraid: wrap long lines
      commands: add rule for lvconvert commands that create pools
      WHATS_NEW: add items since last release
      commands: improve error message for option rules

Heinz Mauelshagen (40):
      man: regexp readability / use $(SED)
      man: de-duplicate lvmconfig, lvm-config and lvm-dumpconfig manuals
      man: simplify by avoiding different headers on de-duplication of lvmconfig, lvm-config and lvm-dumpconfig
      man: ranges/LV names/symbolic use regexp
      man-generator: catch missing command name
      man: use variable in Makefile / regexp
      man: Copyright
      man: raid cleanup
      man: add minor regexp
      man-generator: add '.' to all messages
      raid: address coverity issues
      raid: favour dm_list_first()
      raid: more coverity issues
      man-generator: don't ignore description file errors
      man-generator: enhance performance
      man-generator: shutdown stdout buffer
      man: pregen file change
      lvchange: persistent major/minor processing regression
      lvchange: persistent major/minor processing regression
      lvchange: avoid multiple metadata updates/reloads/backups
      man: '-pool' regexp
      lvchange: enhance avoiding multiple metadata updates/reloads/backups
      lvchange: tidy switch code in _lvchange_properties_single()
      lvconvert: allow --type with --regionsize
      raid: tidying
      man: lvmraid.7 raid6_n_6 fix
      raid: reload on removing images
      lvconvert: prompt on raid1 image changes
      lvconvert: avoid error message on raid1 -> raid4 conversion
      lvconvert: raid1 -> linear prompt
      lvconvert: fixe conversion message
      lvconvert: cleanup prompting
      signals: fix SIGINT blocking flaw causing inconsistent metadata
      signals: fix comparison flaw
      raid: handle insufficent PVs on takeover from striped/raid0
      lvconvert: add segment type raid10_near
      lvconvert: fix failing valid regionsize change
      lvconvert: better message on --regionsize
      WHATS_NEW: add recent RAID entries
      lvconvert: return error without conversion

Jonathan Brassow (1):
      Typo: change loose to lose

Marian Csontos (3):
      dmfilemapd: Fix install target
      spec: Add dmfilemapd
      dmstats: Fix path to static dmstats

Nir Soffer (1):
      dmsetup: Flush ouptut when using --interval

Peter Rajnoha (1):
      lvmconf: fix systemd unit existence check for lvmconf --services --startstopservices

Zdenek Kabelac (16):
      vgrename: use long enough buffer for path
      man: fix type
      tests: fix typo in makefile
      cache: scan kallsyms for kernel symbols
      tests: fix LD_LIBRARY_PATH
      dmfilemapd: keep 1 byte for 
      dmfilemapd: free path
      libdm: set min,maj
      cmdline: ensure command struct is defined
      thin: properly check for status for max sizes metadata
      fsadm: support configurable full path
      tests: restore some test changes
      tests: test for new supported commands
      raid: use log_error
      tests: aux defines fsadm path
      tests: use egrep to check for message


