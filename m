From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 Sep 2013 20:55:51 +0000 (UTC)
Subject: v2_02_101 annotated tag has been created
Message-ID: <20130923205551.08A9960D19@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=29320b7169a863c78c0d9fb7710e66f66c1b167d
Commit:        29320b7169a863c78c0d9fb7710e66f66c1b167d
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2013-09-20 13:01 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2013-09-20 13:01 +0000

annotated tag: v2_02_101 has been created
	    at 29320b7169a863c78c0d9fb7710e66f66c1b167d (tag)
       tagging bd75844024ad4a2e66c7743c50e189a00c233284 (commit)
      replaces v2_02_100

Release 2.02.101

112 files changed, 4131 insertions(+), 1312 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABAgAGBQJSPEcYAAoJEK2W1qbAHj1nnN4P/2dRbjvYx3aOFk4JmZmRmCZI
3M7k4rroanNKF8t9Da05IVqa8G/gTpb3WVJqAkVuuEHdYCWdApRqu3hODe9E4071
T4HENJDtgIKeB7oCqTC3KI6kefJANkZSvcpgXad0yiDiGgenxFQ5wrFdi44T8WE0
LU4g55rDZPJeFVAf0zUpHQlxT5vhiSLdoEwPLRjXpzZsE5cFZrZJjYI3QgnjmqdW
0VCYam22eVjzrvN82MlAu+Q8U/+mUSu2x06Ao0712BQQZ+rlUeCKQdnESMCswN1B
9CGPx1pgUrjHClgM3BWwhqPEh11+r0V+hch++oY6hvlydG4FCB8nNJ6c9QKzhifE
k630C324hDJrkEtwBmQu4KAGRS7smz2sjXIj9buk/BsGUiKsOy6Ag3sr46oiMrry
3QYyU4xDa2txDZd0nWT6z67l7+uUW2ROAnYTYb10oMYAHlEwa+I9zSjFVBMJTORW
3jb+iDHei6d+PJvXluwMZpulnXfxxWGHUwR4AvJUhkybyW/XhcCikA/iGBthav6K
595mdTBxCqa9WHKHPy6sbs0K+l/BvUoYgVyi8nm8s1lP+4TSB3gu78GEp0nN1j3d
rbihonn+gnhmVoS8dzaqyFq/b+XtuyKjWjdFwhNixaUZS7laZz0RG+PsMXg58ba3
1wqrLiFcz4fcw6pcqeJ1
=428K
-----END PGP SIGNATURE-----

Alasdair G Kergon (17):
      post-release
      vgchange: require confirmation with -c and no VGs
      filters: check for mpath before opening devs
      dmsetup: display any message output from kernel
      activation: Fix segfault with inactive pvmove LV.
      toolcontext: Only reopen stdin if readable.
      tools: Use backgroundfork_ARG for pvscan -b
      logging: Write Completed message before resetting.
      toollib: tweak background forking
      filters: Add bcache.
      Makefiles: Fix CC variable override.
      debug: Use // for commented out debug #defines
      reporting: Add devtypes command.
      libdm: avoid leak if dm_task_set_* fn called again
      tools: Avoid overflow in _get_int_arg.
      dmsetup: Detect invalid sector supplied to message.
      release 2.02.101

David Teigland (4):
      test: add vg-name-from-env
      test: add process-each-duplicate-vgnames
      test: add process-each-vg and process-each-lv
      test: fix process-each-duplicate-vgnames

Jonathan Brassow (19):
      cmirrord: Prevent secondary checkpoints from corrupting bitmaps
      Misc: Make get_pv_list_for_lv() available to more than just RAID
      Thin: Make 'lv_is_on_pv(s)' work with thin types
      pvmove: Add support for RAID, mirror, and thin
      pvmove: Ability to move thin volumes
      misc: make lv_is_on_pv use for_each_sub_lv to walk LV tree
      pvmove: Fix inability to specify LV name when moving RAID, mirror, or thin LV
      pvmove:  Allow moving snapshot/origin.  Disallow converting and merging LVs
      test: pvmove tests for all the different segment types.
      TEST: Add tests for lvchange actions of RAID under thin
      TEST: pvmove-all-segtypes.sh should not be run in a cluster
      pvmove: Skip pvmove of RAID, thin, snapshot, origin, and mirror LVs in cluster
      Misc/RAID: Enable resume_lv to handle some renaming conflicts.
      RAID: Make RAID single-machine-exclusive capable in a cluster
      Mirror/Thin: Disallow thinpools on mirror logical volumes
      TEST: Unaccounted possible output causing failure
      WHATS_NEW: Better description for commit 82228ac
      man: lvs man page was not accurate on the volume health bit of lv_attr
      RAID: Don't allow syncaction changes on non-RAID LVs

Marian Csontos (1):
      test: Fix false positives due to open devices

Michael Stapelberg (1):
      systemd: use LVM_PATH instead of hardcoded value in activation generator

Peter Rajnoha (33):
      blkdeactivate: change the way blkdeactivate reports status
      blkdeactivate: add support for bind mounts
      WHATS_NEW: one more for a85439
      WHATS_NEW: be more precise
      WHATS_NEW: for 0da72743ca46ae9f8185cd12d5c78b3c2b801872
      autoactivation: refresh existing VG before autoactivation
      fix: some issues reported by coverity
      fix: ambiguity in log_sys_error call from previous commit
      udev: fix lvmetad rules to not ignore loop device configuration
      dumpconfig: also mention profilable type if giving hint about known types
      filter-mpath: remove superfluous error message about mpath major not equal to dm major
      systemd: lvm2-activation-generator: report only error otherwise be silent
      conf: more comments about use_lvmetad + autoactivation relation
      udev: inform lvmetad about lost PV label
      WHATS_NEW: for 4d3b5724e0b51782000a45027de00e0fed1c9833
      man: lvmdump: add doc for -l and -u
      systemd: lvm2-activation-generator: remove default dir if args not specified and require all args to be given
      man: lvmdump -u -l
      revert: commit 82d83a01ce2cac77fec2e9b763061fbfb5f01ce8
      pvscan: show -aay with --cache for help
      tools: add -b/--background for pvscan --cache -aay
      reinstate: commit 82d83a01ce2cac77fec2e9b763061fbfb5f01ce8
      udev: also inform lvmetad about lost LVM1 PV label
      udev: DM_ID_FS_TYPE should be ID_FS_TYPE when comparing with old value
      udev: fix pvscan --cache -aay to trigger on relevant events
      udev: override new udev default timeout of 30s to original 3min
      WHATS_NEW: for commit 8d1d8350 and 72a9d4f
      WHATS_NEW: one more for commit 8d1d835
      udev: keep DM_ACTIVATION and DM_UDEV_PRIMARY_SOURCE_FLAG meaning as before commit 8d1d835
      WHATS_NEW: some missing lines
      systemd: run lvm2-activation-net.service after lvm2-activation.service
      doc: add a note about device filtering while lvmetad is used
      udev: remove unused line in 69-dm-lvm-metad.rules

Petr Rockai (15):
      vgck: Fix #894136, notice on-disk corruption in spite of lvmetad.
      TEST: Add a timeout to the harness, killing tests after 2 minutes.
      test: Make timeouts a little more robust & verbose.
      test: Remove a redundant drain() from the timeout path.
      test: Check for flavoured variables earlier.
      test: Add a new "check_full" target, which also tests with real /dev.
      test: Set the timeout to 3 minutes (was 5s accidentally).
      test: Skip tests involving mirror recovery on known bad kernels.
      test: Fix a spurious failure in skip_if_mirror_recovery_broken.
      test: Include tests that timed out in the final summary.
      test: Add the 64b fc17 kernel to the mirror recovery blacklist.
      vgcfgrestore: Remove the VG from lvmetad before overwriting it.
      vgcfgrestore: Remove VG rom lvmetad later, to better deal with errors.
      vgconvert: Do not call lvmetad_vg_remove (path shared with vgcfgbackup).
      clvmd: Avoid a 3-way deadlock in dead-client cleanup.

Tony Asleson (1):
      lvm2app: lvm_list_pvs_free seg. fault when no PVs

Zdenek Kabelac (22):
      thin: support lvchange for data and metadata
      libdm: new name can't be empty
      tests: add delay_dev
      tests: test pvmove behavior after restart
      thin: fix resize of stacked thin pool volume
      thin: fix monitoring of thin pool volume
      thin: validation catch multiseg thin pool/volumes
      deactivate: drop readahead calc in deactivation
      test: timeout when no write happens since last written line
      cleanup: drop within comment gcc warning
      cleanup: hide gcc warning
      clvmd: add missing debug newline
      tests: singlenode updates
      tests: singlenode cleanup for prev commit
      tests: extend harness with output of /var/log/messages
      tests: add help function
      tests: update die
      tests: update check and get
      tests: use check for raid test
      tests: enhance pvmove testing
      tests: update vgcfgrestore test
      tests: no activate LV


