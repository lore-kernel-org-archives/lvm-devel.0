From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 12:01:18 +0000 (GMT)
Subject: stable-2.02 - lvchange: remove unneeded call
Message-ID: <20210217120118.851F0389850A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b6dda4ade2bbf3ec98e10860213f345d15a28971
Commit:        b6dda4ade2bbf3ec98e10860213f345d15a28971
Parent:        5acbd709c18eab8ae455d0002892e756ed18fa13
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 14 17:27:45 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 11:56:13 2021 +0100

lvchange: remove unneeded call

Sync is already happining in activate_and_wipe_lvlist().
---
 tools/lvchange.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 7d0ec8ffd..e9f0f7c9a 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -436,13 +436,6 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 	if (!activate_and_wipe_lvlist(&device_list, 0))
 		return 0;
 
-	/* Wait until devices are away */
-	if (!sync_local_dev_names(lv->vg->cmd)) {
-		log_error("Failed to sync local devices after updating %s.",
-			  display_lvname(lv));
-		return 0;
-	}
-
 	/* Put metadata sub-LVs back in place */
 	if (!_attach_metadata_devices(seg, &device_list)) {
 		log_error("Failed to reattach %s device after clearing.",


