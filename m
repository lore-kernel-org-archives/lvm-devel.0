From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 10 Aug 2016 02:03:21 +0000 (UTC)
Subject: v2_02_163 annotated tag has been created
Message-ID: <20160810020321.09DE660F61@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2ab65e7d5b2ab2ed1e26b4acecf165d8aa276612
Commit:        2ab65e7d5b2ab2ed1e26b4acecf165d8aa276612
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-08-10 01:43 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-08-10 01:43 +0000

annotated tag: v2_02_163 has been created
	    at 2ab65e7d5b2ab2ed1e26b4acecf165d8aa276612 (tag)
       tagging 37b8b84fee7459f0a78562c281c405484f25b9db (commit)
      replaces v2_02_162

Release 2.02.163.

Extensions to the JSON produced by the lvm shell for lvmdbusd to use.
Support for lvconvert between mirror and raid1, and between striped/raid0 and
raid4(*).

The next releases will focus on testing these new features and fixing bugs
in them.

(*) The lvconvert work requires an upstream kernel with bug fixes posted
on the dm-devel mailing list.

54 files changed, 2456 insertions(+), 681 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAleqiPAACgkQIoGRwVZ+LBfwTgCgrd9wY20EWMXNNe7NFVoqobZa
rQIAnRjgk2nJlImXLig+9NL/01RdezBX
=79Mb
-----END PGP SIGNATURE-----

Alasdair G Kergon (33):
      post-release
      lvconvert: Remove hard-coded segment names.
      lvconvert: Only obtain --type parameter once.
      lvconvert: Rearrange code that decides segtype.
      tools: Unify stripesize parameter validation.
      lvconvert: Move stripe validation code later.
      tools: mirror also supports stripesize
      tools: Also recognise segtype with thin and cache.
      lvconvert: Fix --type thin recognition.
      lvconvert: Rely upon lp->thin and lp->cache.
      lvconvert: Set lp->segtype in only one place.
      Revert "thin: when converting a thin pool data or metadata LV from"
      lvconvert: Forbid stripe parameters with --repair.
      lvconvert: Treat --repair as an independent case.
      lvconvert: Divide into 12 categories.
      lvconvert: Preserve mirror region size with --repair.
      lvconvert: Pass region_size to lv_raid_convert.
      lvconvert: Provide entry point for new functionality.
      lvconvert: Improve error message when no -m.
      striped: Add precise macros for original segtype.
      raid0: Validate presence of raid0 meta_areas more tightly.
      segtypes: Further segtype macros.
      raid: Turn lv_raid_change_image_count into wrapper
      raid: Tell lib whether stripesize was specified
      raid: Move two functions.
      raid: Pass list of LVs to remove into more fns.
      raid: Add workaround to prepare for raid4 conversions.
      raid: Report supported lvconvert conversions if invalid.
      lvconvert: Support raid0<->raid4 and mirror<->raid1.
      lvconvert: Limit --corelog and --mirrorlog to mirrors.
      test: Drop --mirrorlog when not a mirror.
      lvconvert: Fix repair and replace routing.
      pre-release

Bryn M. Reeves (2):
      man: minor fixes to dmstats.8.in
      man: explain deletion of 1st group member in dmstats.8.in

David Teigland (4):
      man: include info about disabled lvmetad
      man: minor corrections in pvscan
      lvconvert: add FIXME
      lvconvert: separate type raid to mirror

Heinz Mauelshagen (12):
      thin: when converting a thin pool data or metadata LV from
      vg_validate: new RAID segment checks in check_lv_segments()
      vg_validate: correct min_recovery_rate check message
      lvchange: Allow device specification when requesting a repair
      WHATS_NEW: add '--rebuild PV' option to lvchange to allow for PV selective rebuilds
      raid_manip: fix log print format from commit d2c3b23e6dc3
      WHATS_NEW: fixup order
      lvcreate: reject '--nosync' option for RAID6 LVs
      WHATS_NEW: reject --nosync option for RAID6 LVs in lvcreate
      test: add lvconvert-raid-takeover.sh
      test: fix lvcreate-large-raid.sh
      test: fix/enhance lvcreate-large-raid*.sh

Peter Rajnoha (18):
      lvmcmdline: do not refresh whole cmd context if profile dropped after processing LVM cmd
      log: separate output and make it possible to use given FDs
      shell: also collect last command's return code for subsequent 'lastlog' invocation
      refactor: move report grouping and log reporting handles from processing_handle to cmd_context
      lvmcmdline: return 0/NULL if cmd->arg_values not set and arg_count/grouped_arg_count/arg_value called
      libdm: report: add dm_report_destroy_rows
      libdm: report: postpone printing of JSON starting '{' character till it's needed
      libdm: report: add dm_report_group_output_and_pop_all
      lvm: shell: extend log report to cover whole lvm shell's main loop
      lvmcmdline: profile: early profile load for lvm shell
      lvm: shell: honor log/command_log_selection as default and reset to this value after lastlog
      conf: add lvmdbusd.profile
      refactor: modify original _check_profile fn and rename to config_force_check for general use
      config: add support for CFG_DISALLOW_INTERACTIVE flag to mark settings as not suitable for override in interactive mode
      conf: mark selected settings with CFG_DISALLOW_INTERACTIVE flag
      report: add report_reset_cmdlog_seqnum and call it for each new cmd executed in lvm shell
      man: add lvm fullreport man page
      man: fix references to names for --configreport arg in pvs, vgs and lvs man page


