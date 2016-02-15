From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 14:17:49 +0000 (UTC)
Subject: master - toollib: skip PV if system ID is used and PV marked as used but metadata missing
Message-ID: <20160215141749.C1F736072F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cc9e683adcb6c56332d708baf02dec63eba4fba9
Commit:        cc9e683adcb6c56332d708baf02dec63eba4fba9
Parent:        0000db7f98a07aa31c5b1cf13938b612e7f2821b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Feb 15 15:11:54 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 15:17:36 2016 +0100

toollib: skip PV if system ID is used and PV marked as used but metadata missing

If we know that a PV belongs to some VG and we're missing metadata
(because we have only those PV(s) from VG present in the system that
don't have metadata areas), we should skip such PV when processing
under system ID.

This is because we know that the PV belongs to some VG, but we
really can't decide whether it matches system ID unless the VG
metadata is present again.
---
 WHATS_NEW       |    1 +
 tools/toollib.c |    6 ++++++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 47eb735..48f2fb3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.143 - 
 =====================================
+  If PV belongs to some VG and metadata missing, skip it if system ID is used.
   Automatically change PV header extension to latest version if writing PV/VG.
   Identify used PVs in pv_attr field by new 'u' character.
   Add pv_in_use reporting field to report if PV is used or not.
diff --git a/tools/toollib.c b/tools/toollib.c
index 7f8c2eb..1bdc113 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3067,6 +3067,12 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 		pv = pvl->pv;
 		pv_name = pv_dev_name(pv);
 
+		if (cmd->system_id && is_orphan(pv) && is_used_pv(pv)) {
+			log_verbose("PV %s is belonging to a VG but its metadata is missing.", pv_name);
+			log_verbose("Skipping PV %s because it's not possible to decide whether it matches system id.", pv_name);
+			continue;
+		}
+
 		process_pv = process_all_pvs;
 
 		/* Remove each arg_devices entry as it is processed. */


