From: David Teigland <teigland@fedoraproject.org>
Date: Mon,  7 Mar 2016 20:26:32 +0000 (UTC)
Subject: master - toollib: always process in use pvs
Message-ID: <20160307202632.BF2CB60F6A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6cf1eff46d2ec32363576ea21318fc8036656e07
Commit:        6cf1eff46d2ec32363576ea21318fc8036656e07
Parent:        a8319e62c079e807af275f220dbd6ea875b0c0c6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Mar 7 14:15:33 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Mar 7 14:15:33 2016 -0600

toollib: always process in use pvs

With the recent conversion of pvcreate/pvremove to the
common toollib processing function, skipping in-use PVs
in _process_pvs_in_vg prevented them from being protected
as intended by the in-use flag.

The processing code for pvcreate/pvremove checks for the
in-use state itself and prevents using an in-use PV.
If a PV is skipped, it looks like an unused device and
is not protected from being used in pvcreate/pvremove.
---
 tools/toollib.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 14aca15..2ff5a3b 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3049,12 +3049,6 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 		pv = pvl->pv;
 		pv_name = pv_dev_name(pv);
 
-		if (cmd->system_id && is_orphan(pv) && is_used_pv(pv)) {
-			log_verbose("PV %s is used by a VG but its metadata is missing.", pv_name);
-			log_verbose("Skipping PV %s because it's not possible to decide whether it matches system id.", pv_name);
-			continue;
-		}
-
 		process_pv = process_all_pvs;
 
 		/* Remove each arg_devices entry as it is processed. */


