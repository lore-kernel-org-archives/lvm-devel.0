From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 20 Apr 2015 22:08:16 +0000 (UTC)
Subject: master - toollib: fix duplicate handling in process_each_pv
Message-ID: <20150420220816.B774960C97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0d0d50182d1bf6b11b80fe8fe701f654b953f2fa
Commit:        0d0d50182d1bf6b11b80fe8fe701f654b953f2fa
Parent:        caa9223c8549b4a937c2cc13eb7f306f55e4beee
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 20 14:35:35 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 20 17:07:58 2015 -0500

toollib: fix duplicate handling in process_each_pv

With use_lvmetad=0, duplicate PVs /dev/loop0 and /dev/loop1,
where in this example, /dev/loop1 is the cached device
referenced by pv->dev, the command 'pvs /dev/loop0' reports:

Failed to find physical volume "/dev/loop0".

This is because the duplicate PV detection by pvid is
not working because _get_all_devices() is not setting
any dev->pvid for any entries.  This is because the
pvid information has not yet been saved in lvmcache.
This is fixed by calling _get_vgnameids_on_system()
before _get_all_devices(), which has the effect of
caching the necessary pvid information.

With this fix, running pvs /dev/loop0, or pvs /dev/loop1,
produces no error and one line of output for the PV (the
device printed is the one cached in pv->dev, in this
example /dev/loop1.)

Running 'pvs /dev/loop0 /dev/loop1' produces no error
and two lines of output, with each device displayed
on one of the lines.

Running 'pvs -a' shows two PVs, one with loop0 and one
with loop1, and both shown as a member of the same VG.

Running 'pvs' shows only one of the duplicate PVs,
and that shows the device cached in pv->dev (loop1).

The above output is what the duplicate handling code
was previously designed to output in commits:

b64da4d8b521 toollib: search for duplicate PVs only when needed
3a7c47af0e88 toollib: pvs -a should display VG name for each duplicate PV
57d74a45a05e toollib: override the PV device with duplicates
c1f246fedfc3 toollib: handle duplicate pvs in process_in_pv

As a further step after this, we may choose to change
some of those.

For all of these commands, a warning is printed about
the existence of the duplicate PVs:

Found duplicate PV ...: using /dev/loop1 not /dev/loop0
---
 tools/toollib.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 26810b2..2268b7e 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2821,6 +2821,16 @@ int process_each_pv(struct cmd_context *cmd,
 			      arg_count(cmd, all_ARG);
 
 	/*
+	 * Read all the vgs here because this has the effect of initializing
+	 * device/lvmcache info so that dev->pvid is available when creating
+	 * a list of devices.
+	 */
+	if ((ret = _get_vgnameids_on_system(cmd, &all_vgnameids, only_this_vgname, 1) != ECMD_PROCESSED)) {
+		stack;
+		return ret;
+	}
+
+	/*
 	 * If the caller wants to process all devices (not just PVs), then all PVs
 	 * from all VGs are processed first, removing them from all_devices.  Then
 	 * any devs remaining in all_devices are processed.
@@ -2834,15 +2844,6 @@ int process_each_pv(struct cmd_context *cmd,
 		/* get_arg_devices reports the error for any PV names not found. */
 		ret_max = ECMD_FAILED;
 
-	/*
-	 * Read all the vgs first because this has the effect of initializing
-	 * other device/lvmcache info that is needed when creating device lists.
-	 */
-	if ((ret = _get_vgnameids_on_system(cmd, &all_vgnameids, only_this_vgname, 1) != ECMD_PROCESSED)) {
-		stack;
-		return ret;
-	}
-
 	ret = _process_pvs_in_vgs(cmd, flags, &all_vgnameids, &all_devices,
 				  &arg_devices, &arg_tags,
 				  process_all_pvs, process_all_devices,


