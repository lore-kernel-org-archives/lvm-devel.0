From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 28 Jun 2016 01:34:08 +0000 (UTC)
Subject: v2_02_158 annotated tag has been created
Message-ID: <20160628013408.449AD614BC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d0c49df5b466e3d5f842272d76452fd2b9e5dec
Commit:        6d0c49df5b466e3d5f842272d76452fd2b9e5dec
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-06-25 19:35 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-06-25 19:35 +0000

annotated tag: v2_02_158 has been created
	    at 6d0c49df5b466e3d5f842272d76452fd2b9e5dec (tag)
       tagging 887f071b2545bb2b60e13de854898ab71a6b0ff5 (commit)
      replaces v2_02_157

Release 2.02.158.

An interim development release incorporating major extensions to the reporting
code (including a json facility).  The interface changes are not yet frozen.
The vgimportclone script is also replaced with a new built-in implementation.

133 files changed, 4796 insertions(+), 1818 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAldu3m8ACgkQIoGRwVZ+LBcy0gCg2xMhF+rYQSYsuztV/w3u6W3E
pP8An1UtPzdIRLbj3hmFBFFS97lV2aAl
=zD0Y
-----END PGP SIGNATURE-----

Alasdair G Kergon (7):
      post-release
      tools: Use arg_is_set instead of arg_count.
      lvconvert: Refactor argument handling code.
      lvconvert: Fix --stripes handling.
      Revert "locking: trace errors from dir creation"
      doc: Resync kernel docs.
      pre-release

David Teigland (9):
      lvmlockd: fix dropping PVs in rescanning VG
      vgreduce: fix location of lvmlockd global lock
      vgscan: fix process_each args
      vgcfgrestore: use lvmetad disabled state
      lvmetad: process new connections after shutdown signal
      lvmlockd: always try to connect to lvmetad
      vgcfgrestore: check for missing device
      vgcfgrestore: rescan to reenable lvmetad on error path
      vgimportclone: add native command

Peter Rajnoha (55):
      libdm: report: introduce dm_report_group
      libdm: report: implement DM_REPORT_GROUP_SINGLE for a group containing single report only
      libdm: report: implement DM_REPORT_GROUP_BASIC for extended report output
      libdm: report: implement DM_REPORT_GROUP_JSON for JSON report output
      report: add CMDLOG report type
      conf: add log/command_log_{sort,cols} config settings
      toollib: add report_format_init fn to create report group and to create/add log report handle
      conf: add report/output_format config setting
      conf: add log/report_command_log config setting
      report: separate common report and per-report args
      toollib: add report_group and log_rh to processing_handle and initialize cmd processing log report
      toollib: add 'parent' field to processing_handle; init report format only if there's no parent
      report: add current report to existing group
      commands: recognize --reportformat option for pvs,vgs,lvs and devtypes command
      commands: recognize --reportformat option for other commands
      commands: report: add lvm fullreport command
      conf: add report/{vgs,pvs,lvs,pvsegs,segs}_{cols,sort}_full config settings
      args: add priorities for grouping args
      args: add --configreport arg
      report: add _get_report_idx_from_name and _should_process_report_idx helper fns
      report: recognize list of fields to report (-o|--options) for each subreport
      report: recognize list of keys to sort report by (-O|--sort) for each subreport; make -O|--sort groupable
      report: recognize selection (-S|--select) for each subreport; make -S|--select groupable
      report: check report type and options used for full report's subreports
      toollib: make it possible to also process internal VGs, add 'include_internal' switch to process_each_vg fn
      log: log warnings and errors via report if set; add log_set_report* fns
      report: add report_current_object_cmdlog fn as a shortcut for reporting current object's log item
      log: also pass log_print through report and add log_print_bypass_report for use in libdm-report for direct print without report
      libdm: report: remember special field to display selection status in struct row's field_sel_status variable
      refactor: move field width calculation and sort preparation from _do_report_object to dm_report_output
      libdm: report: add DM_REPORT_OUTPUT_MULTIPLE_TIMES report flag to keep report data even after output is done
      libdm: report: add dm_report_set_selection
      report: add 'multiple_output' arg to report_init
      log: annotate processing code with log_set_report_{context,object_type,id_and_name}
      log: annotate processing code with report_current_object_cmdlog
      refactor: move 'interactive' field from struct command_line to struct cmd_context as 'is_interactive' switch
      tools: add 'lvm lastlog' command for interactive query and display of last command's log
      log: use separate 'orphan' report object type for orphan VGs
      conf: add log/command_log_selection config setting
      libdm: select: recognize special selection string 'all' as an alias for blank selection string
      report: use report type description for report's name if using DM_REPORT_GROUP_BASIC output format
      report: add --logonly arg to report only log for a command
      conf: regenerate profile templates
      commands: add --configreport arg for all relevant commands
      report: compare --configreport value with basic report type
      log: add 'label' log report object type; annotate process_each_label with log_set_report_object_{type, id_and_name} and report_log_ret_code
      cleanup: log: use hex numbers instead of decimal for _LOG_*
      conf: add more comments for new settings related to output format and log report
      filters: add comments about internal filter position in filter chain
      log: move original print_log code to _vprint_log and make print_log a wrapper over _vprint_log
      libdm: log: remove log_print_bypass_report calls and register new print_log_libdm for libdm during lvm initialization instead
      commands: fix typo in arg assignment
      commands: help: add missing --reportformat references
      man: document --configreport, --logonly, --reportformat
      man: lvs: move doc about --all so it's ordered alphabetically in the man page

Zdenek Kabelac (26):
      activation: switch to warning
      activation: _lv_active returns 0 on error
      monitoring: preserve monitoring status during update
      locking: trace errors from dir creation
      lvresize: move and extend resizefs ignoring check
      lvresize: inform about ignored args with --use-polices
      lvresize: drop extra sigint handling
      cleanup: code lines reodered
      cleanup: add dots to some messages
      cleanup: use display_lvname
      lvresize: update lvresize_params struct
      lvresize: check pvh list is vg->pvs
      lvresize: pass only needed params to _fsadm_cmd
      lvresize: do not pass struct cmd
      lvresize: support more resized LVs
      lvresize: return 0/1
      cleanup: remove unused sizearg variable
      cleanup: remove unused code
      cleanup: drop setting lv_name
      tests:  aux prepare_thin_metadata
      lvresize: fixes for recent commit
      lvresize: let pass even protected names like _tmeta
      cleanup: type cleanup
      tests: smaller number of devs created to fill metadata
      tests: update test for modified output
      cleanup: clean warns from older gcc


