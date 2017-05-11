From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 10 May 2017 21:18:54 -0400
Subject: master - metadata: Fix metadata repair when devs still missing.
Message-ID: <201705110118.v4B1IsjP029443@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=80900dcf76d2c91d8892e54913367bfed1012056
Commit:        80900dcf76d2c91d8892e54913367bfed1012056
Parent:        d45531712d7c18035975980069a1683c218abec2
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu May 11 02:04:50 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu May 11 02:17:34 2017 +0100

metadata: Fix metadata repair when devs still missing.

_check_reappeared_pv() incorrectly clears the MISSING_PV flags of
PVs with unknown devices.
While one caller avoids passing such PVs into the function, the other
doesn't.  Move the check inside the function so it's not forgotten.

Without this patch, if the normal VG reading code tries to repair
inconsistent metadata while there is an unknown PV, it incorrectly
considers the missing PVs no longer to be missing and produces
incorrect 'pvs' output omitting the missing PV, for example.

Easy reproducer:
Create a VG with 3 PVs pv1, pv2, pv3.
Hide pv2.
Run vgreduce --removemissing.
Reinstate the hidden PV pv2 and at the same time hide a different PV
pv3.
Run 'pvs' - incorrect output.
Run 'pvs' again - correct output.

See https://bugzilla.redhat.com/1434054
---
 WHATS_NEW               |    1 +
 lib/metadata/metadata.c |   11 ++++++++---
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 79b6c67..e0741a9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.172 - 
 ===============================
+  Don't reinstate still-missing devices when correcting inconsistent metadata.
   Properly handle subshell return codes in fsadm.
   Disallow cachepool creation with policy cleaner and mode writeback.
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 972306e..a95b9e3 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3910,7 +3910,13 @@ static int _check_reappeared_pv(struct volume_group *correct_vg,
          * confusing.
          */
         if (correct_vg->cmd->handles_missing_pvs)
-            return rv;
+		return rv;
+
+	/*
+	 * Skip this if there is no underlying device present for this PV.
+	 */
+	if (!pv->dev)
+		return rv;
 
 	dm_list_iterate_items(pvl, &correct_vg->pvs)
 		if (pv->dev == pvl->pv->dev && is_missing_pv(pvl->pv)) {
@@ -4174,8 +4180,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	if (lvmetad_used() && !use_precommitted) {
 		if ((correct_vg = lvmcache_get_vg(cmd, vgname, vgid, precommitted))) {
 			dm_list_iterate_items(pvl, &correct_vg->pvs)
-				if (pvl->pv->dev)
-					reappeared += _check_reappeared_pv(correct_vg, pvl->pv, *consistent);
+				reappeared += _check_reappeared_pv(correct_vg, pvl->pv, *consistent);
 			if (reappeared && *consistent)
 				*consistent = _repair_inconsistent_vg(correct_vg);
 			else


