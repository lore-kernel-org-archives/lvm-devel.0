From: David Teigland <teigland@sourceware.org>
Date: Mon, 29 Apr 2019 16:48:04 -0400
Subject: master - pvscan: remove fixme comment that is fixed
Message-ID: <201904292048.x3TKm4SD026189@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6d0f09f4783061054152ae0013d7ebfad949c343
Commit:        6d0f09f4783061054152ae0013d7ebfad949c343
Parent:        c3e385c1087321986ae1bc9346f2b00f5790e75c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 29 15:42:20 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 29 15:44:57 2019 -0500

pvscan: remove fixme comment that is fixed

Remove the fixme comment describing the case that was
fixed by aa75b31db54782fb24b6b7e3c681a61b3579117c
  "pvscan: handle case of scanning PV without metadata last"
---
 tools/pvscan.c |   12 ------------
 1 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 61d9cc8..d3b2b8e 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1062,18 +1062,6 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 		cmd->pvscan_recreate_hints = 1;
 		pvscan_recreate_hints_begin(cmd);
 
-		/*
-		 * FIXME: if _online_pvscan_all_devs scans a PV without
-		 * metadata as the final PV to complete the VG, then
-		 * that VG is not added to the complete_vgnames list.
-		 * To fix this, we could also keep an incomplete_vg list,
-		 * and each incomplete_vg entry would list the PVIDs it
-		 * still needed.  If a PV without metadata is scanned,
-		 * its PVID would be removed from the incomplete_vg entry,
-		 * and if the entry had no remaining PVs needed, the vgname
-		 * would be added to complete_vgnames.
-		 */
-
 		log_verbose("pvscan all devices for requested refresh.");
 		_online_files_remove(_pvs_online_dir);
 		_online_files_remove(_vgs_online_dir);


