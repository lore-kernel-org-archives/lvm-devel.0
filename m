From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  4 Mar 2015 14:11:39 +0000 (UTC)
Subject: v2_02_117 annotated tag has been created
Message-ID: <20150304141139.25E2B60B69@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e518dc4ec835a03a044ae169bf283e983f27d4c1
Commit:        e518dc4ec835a03a044ae169bf283e983f27d4c1
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2015-03-04 13:51 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2015-03-04 13:51 +0000

annotated tag: v2_02_117 has been created
	    at e518dc4ec835a03a044ae169bf283e983f27d4c1 (tag)
       tagging 930fa3290debbdecca44f334426d960e3160e7bf (commit)
      replaces v2_02_116

Release 2.02.117.

148 files changed, 6636 insertions(+), 1287 deletions(-)

The system ID documentation included in this release relates
to code that is still under development and the code that
lets you set a system ID has not yet been enabled.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlT3DvIACgkQIoGRwVZ+LBfbhgCeLj1aGiB48lVV/l8PI8naYXpm
VVcAoLmX+qnzBHk72FALuof6y4r4j8OK
=Mk0s
-----END PGP SIGNATURE-----

Alasdair G Kergon (34):
      post-release
      pvchange: Use process_each_pv.
      conf: Set default global/etc from --with-confdir.
      lvmetad: Add fn to scan only foreign VGs.
      lvm-string: Fix HYPEN typo.
      systemid: Add built-in systemid command.
      config: Reinstate recursive tags setting.
      format_text: Store creation_host_system_id.
      format_text: Fix creation_host_system_id.
      systemid: Require alphanumeric 1st character.
      toolcontext: Move lvmlocal.conf loading.
      toolcontext: Include system_id in refresh.
      systemid: Add warnings if invalid.
      systemid: Define file content more precisely.
      config: Adjust system_id defaults.
      config: Rename allow_system_id to extra_system_ids.
      lvm1: Reenable sys ID.
      systemid: Fix access restrictions.
      systemid: Extend --foreign to reporting commands.
      systemid: Allow empty systemid with warnings.
      systemid: Improve concurrent warning.
      example.conf: Update systemid comments.
      toolcontext: Fix lvmlocal.conf load fail path.
      lvchange: Allow -prw to change kernel only.
      mirror: Avoid region size compiler warning.
      mirror: Explicit cast in region_size_max
      lvchange: Allow -pr to change kernel only.
      archives: Preserve format type in file.
      format1: Export generate_lvm1_system_id.
      vgchange: Prevent lvm1 system ID changes.
      systemid: Init and merge lvm2 and lvm1 fields.
      systemid: Add ACCESS_NEEDS_SYSTEM_ID VG flag.
      systemid: Disable --systemid.
      pre-release

David Teigland (31):
      toollib: prepare select_match_{pv,vg,lv} hooks
      vgextend: Use process_each_vg.
      system_id: use for VG ownership
      WHATS_NEW for system_id
      toollib: add underscore to static ignore_vg function
      system_id: omit leading hyphens from system_id
      system_id: warn if the system_id_file cannot be opened
      man: update lvmthin about repair and recovery
      doc: explanation of caching foreign VGs
      tests: add system_id test
      report: fix foreign reporting without lvmetad
      man lvmsystemid: expanded limitations and warnings
      tests: skip system_id machineid case when not available
      man: systemid option for vgcreate and vgchange
      vgchange, vgcreate: add systemid option to command help
      man lvm: document --foreign option
      man lvmsystemid: update changing the system_id
      systemid: silently ignore foreign vgs unless named
      vgcfgbackup: enable foreign VG access
      lvchange: deactivate is always possible in foreign vgs
      tests: add more systemid tests
      tests: fix the system_id tests
      WHATS_NEW: vgimport with lvmetad
      pvscan, vgscan: include foreign vgs with --cache
      tests: add more system_id tests
      man: lvmsystemid: empty string equals no system_id
      tests: more system_id tests
      system_id: remove unwanted foreign error for some commands
      system_id: apply consistent naming
      vgchange: deactivate LVs in foreign VG
      lvchange, vgchange: fix the system_id check

Jonathan Brassow (1):
      cmirror: Adjust region size to work around CPG msg limit to avoid hang.

Jose Castillo (1):
      initscripts: lvm2-monitor: implement status action

Marian Csontos (2):
      test: Fix harness not building on RHEL5
      test: Fix missing return in new test harness.

Ondrej Kozina (2):
      libdaemon: set CLOEXEC on client socket fd
      libdaemon: set CLOEXEC flag on systemd socket

Peter Rajnoha (55):
      reporter: properly check for _do_info_and_status return value and free the mempool if created within the fn
      lvm: recognize LVM_COMMAND_PROFILE env var for default command profile to use in LVM commands
      libdm: report: add dm_report_object_is_selected
      cleanup: make report type condition consistent with the rest of the code
      toollib: replace void *handle with struct processing_handle for use in processing functions (process_each_*/process_single_* and related)
      report: add report_init_for_selection fn and modify report_object to support reporting for selection only
      toollib: pass struct processing_handle to _select_match_* functions
      toollib: add init_processing_handle, init_selection_handle and destroy_processing_handle helper functions
      toollib: initialize handles (including reporting for selection) for _select_match_* used in process_each_* fns
      toollib: select the whole structure if at least one of its items is selected
      refactor: report: factor out code to determine final report type
      report: add report_for_selection and use it in select_match_{pv,vg,lv}
      report: implement report_for_selection
      pvchange: use processing_handle when processing items for pvchange
      tools: allow -S|--select for vgchange, lvchange and pvchange
      tools: allow -S|--select for vgremove and lvremove
      tools: allow -S|--select for vgdisplay, lvdisplay and pvdisplay without -C
      tools: allow -S|--select for vgexport and vgimport
      select: initialize selection handle for process_each_* fns with initial report type
      man: dumpconfig: mention LVM_COMMAND_PROFILE env var and add more references to --mergedconfig option
      toollib: select: issue an error message for failed VG/LV/PV selection
      man: reference -S/--select in {vg,lv,pv}change, {vg,lv}remove, {vg,lv,pv}display and vg{import,export} man pages
      conf: update profile templates for recent changes
      report: define ba_start, vg_free and seg_start fields as DM_REPORT_FIELD_TYPE_SIZE instead of DM_REPORT_FIELD_TYPE_NUM
      tests: rename report-select.sh to select-report.sh
      tests: add select-tools.sh to test selection support in toollib
      config: fix version of introduction for devices/external_device_info_source (v115->v116)
      toollib: process_each_pv: do not acquire list of all devices if not necessary
      toollib: process_each_pv: use cmd->full_filter, not cmd->filter if we're getting full list of PV-capable devices (not just PVs)
      toollib: process_each_pv: fix commit d38d047e which worked for processing "all devices", but didn't work for "all PVs"
      autoreconf: recent changes
      lvchange: change msg about required params (LV or selection) to be consistent with msgs used in other tools
      pvchange: no need to initialize selection handle directly, process_each_pv will do that automatically
      cleanup: replace static struct processing_handle initializer with common init_processing_handle
      cleanup: remove deallocate_handle_root arg from destroy_procesing_handle fnw
      tests: select-tools.sh: pvchange now uses process_each_pv
      tolllib: process_each_pv: always use full_filter unconditionally when getting all devices
      tests: comment in select-tools.sh
      tests: fix pvcreate-operation-md test to properly clean up devs before their reuse
      pvcreate: switch to "none" dev-ext source during pvcreate
      filters: no need to refresh filters/rescan if no signature is wiped during pvcreate at all
      wiping: blkid: do not count skipped signatures in final number of wipes
      pvcreate: switch to "none" dev-ext source during pvcreate
      configure: typo in configure --with-default-raid10-segtype causing it to be unrecognized
      conf: be more clear about wipe_signatures_when_zeroing_new_lvs option in comments
      report: fix handling of reports with pure label fields
      report: one more comment explaining change of report type when tags are used for original LABEL reporting
      cleanup: change check order in condition in _check_pv_list fn
      initscripts: lvm2-monitor: use @DMEVENTD_PIDFILE@ instead of hardcoded /var/run/dmeventd.pid
      report: check value of args_are_pvs, not the pointer (fix for commit 9ea77b7)
      metadata: vg: add missing vg->lvm1_system_id initialization
      metadata: vg: alloc lvm1_system_id in alloc_vg sooner
      vgremove: select: direct selection to be done per-VG, not per-LV
      config: add CFG_DISABLED flag and mark system_id settings with that flag
      cleanup: tools: "or use -S for selection" --> "or use --select for selection"

Petr Rockai (113):
      test: Import first draft of a new test runner.
      configure: Allow C++ components.
      configure: Add libexecdir/datadir to make.tmpl.in.
      test: Build the new test runner.
      test: Use the new runner in make check.
      test: Split up the new runner into multiple files.
      test: Implement journalling and --continue.
      test: Clean up fds properly in the runner.
      test: Write a results/list at the end of a test run.
      test: Add new flavour definition files.
      test: Allow test devices backed by a permanent block device.
      test: Make runner use bigger IO buffers, put them on stack.
      test: Implement a file-backed IO sink in the runner.
      test: Add a buffer-backed IO sink (for interactive runs).
      test: Fix IO sink destructors in the runner.
      test: Use the new flavour setup files in lib/inittest.
      test: Make it possible to run tests from an installed location.
      test: Makefile updates.
      test: Fix handling of envvars in the runner.
      test: Implement flavours in the runner.
      test: Make the runner's journal more reliable.
      test: Improve tracking of silence (stuck testcases) in the runner.
      test: Improve IO handling in the runner.
      test: Run the testcases chdir'd into --testdir.
      test: Targets and sources can't have the same name if builddir == srcdir.
      test: Rename the --quiet option to --batch.
      test: Run in /tmp if LVM_TEST_DIR is unset.
      test: Avoid sleeps in the runner monitoring loop.
      test: Print a heartbeat file (every 20s) in the runner.
      test: Add time/rusage formatting to the runner.
      test: Implement specialised --batch output style w/ rusage stats.
      test: Use append for journal maintenance instead of rename.
      test: Fix a precedence bug in the runner.
      test: Add a missing copyright/licence notice to journal.h.
      test: Fix loading of an append-mode journal.
      test: Implement --only option to runner.
      spec: Add an (optional) lvm2-testsuite subpackage.
      NIX: Refactor around the new test runner.
      NIX: Use --batch mode for running the testsuite.
      NIX: Implement a smarter VM monitoring loop.
      NIX: Adapt to the append-based test journal.
      NIX: Use nixpkgs kernel for building, distro kernel for testing.
      NIX: Drop -h from rpm invocations as it messes up logs.
      NIX: Existence of results list no longer indicates that the suite has finished.
      NIX: Add Fedora 20 jobs.
      NIX: Re-work VM monitoring.
      test: Disable lvmetad logging in lvconvert-{mirror,raid}*.
      test: Make the runner's heartbeat more reliable.
      test: Implement --fatal-timeouts to allow a timely VM restart.
      NIX: Pass --fatal-timeouts to the testsuite.
      test: Package up the test runner in a reusable C++ "brick".
      NIX: Use the new --heartbeat option on lvm2-testsuite.
      test: Update brick-shelltest, adding timestamps to logs.
      libdaemon: Use select to yield CPU on a blocked read or write.
      NIX: Use IDE drive emulation instead of virtio.
      NIX: Some kernels need ide/ata modules (i.e. no builtin ata).
      NIX: Keep the udev log out of tmpfs.
      test: Update brick-shelltest.h.
      NIX: Add --kmsg to lvm2-testsuite invocations.
      NIX: Run each test flavour as a separate derivation.
      NIX: Do not fail aggregation when a sub-job fails to produce output.
      NIX: Update path to /xchg (was /tmp/xchg with older nixpkgs).
      test: Fix implementation of check targets with new flavour system.
      test: Do not rely on dev/mapper/* nodes in pvmove-restart.sh.
      NIX: Mark builds with failed tests as such.
      test: Update brick-shelltest (configurable timeout, better banner, exit code).
      test: Fix 100%FREE RAID tests since test device sizes changed slightly.
      test: Avoid running 'dmsetup remove' with no devices.
      test: Fix failures due to undefined abs_top_builddir.
      NIX: Avoid a spurious failure when all tests pass.
      NIX: Detect that the VM booted up more directly.
      test: Re-try with loopback if a backing device is too small.
      test: Avoid passing -c to flock.
      test: Fix prepare_scsi_debug_dev.
      NIX: Make timeout and test envvars configurable via --arg.
      NIX: Install valgrind, gdb and strace in the test environment.
      test: Make lvm-wrapper available in the installed testsuite, too.
      test: Add support for running LVM commands in tests through strace.
      configure: Look for valgrind.h independently of VALGRIND_POOLS.
      memlock: Do not check memory balance if RUNNING_ON_VALGRIND.
      NIX: Add valgrind-devel to the build environment.
      test: Call $VALGRIND directly in lvm-wrapper.
      test: Disable lvmetad debug log on another bunch of tests.
      test: Make killing local (test) daemons more robust.
      test: Make dmsetup remove more robust in pvmove-restart.
      test: Allow a longer timeout for lvextend-snapshot-dmeventd.
      test: Only force an IO sync when the testcase has finished.
      test: Properly detect warnings from testcases.
      test: Remove spurious set -x in lvm-wrapper.
      test: It is not an error for a test daemon to exit before teardown.
      test: Fix a segfault in the test runner.
      NIX: Add a CentOS 7.0 64b build.
      NIX: Set ulimit -c to unlimited, to get backtraces in logs.
      NIX: Allow adding/overriding test configurations.
      NIX: Move corosynclib-devel & valgrind-devel out of common.
      NIX: We need to install lcov for ./configure now as well.
      NIX: Adjust install_rpms (kernel rpm is now required).
      NIX: Request {fedora,centos}-release packages explicitly.
      configure: Fix a warning about test/Makefile.in.
      test: Fix a typo in shell/pvmove-restart.sh.
      NIX: Adjust lists of extra RPMs to install.
      NIX: Drop Fedora 16 builds.
      NIX: Resolve issues with fedora-release and kernel-modules-extra.
      NIX: Fix CentOS builds.
      spec: Include lvmsystemid.7 in RPMs.
      NIX: Fix a typo that broke evaluation of fc19+.
      test: Make pvmove0 device removal more robust, in pvmove-restart.sh.
      test: Avoid a race in pvmove-restart.sh.
      clvmd: Fix BZ 1140095 by updating lastfd upon EINTR.
      cache: Fix a segfault when passing --cachepolicy without --cachesettings.
      lvmcache.7: add a section on --cachepolicy/--cachesettings
      lvcreate.8: Mention --cachepolicy and --cachesettings.
      spec: Add lvmlocal.conf to RPMs.

Zdenek Kabelac (17):
      tests: respect LVM_TEST_DIR
      makefiles: more _CFLAGS for -MM
      tests: don't crash if checked string is shorter
      tests: ensure array is synchronized
      tests: BACKING_DEV
      configure.in: AC_SUBST needs to be always executed
      memory: disable check with valgrind pool build
      valgrind: when executed within valrind skip close
      tests: ensure lv1 goes away first
      tests: syncaction update
      cleanup: drop unused val
      cleanup: drop !! from code
      cleanup: fix compate of return value
      tests: hide uninteresting output
      cleanup: drop unused value assign
      cleanup: simplify error path code
      cleanup: drop unused header file


