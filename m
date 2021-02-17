From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 10:54:39 +0000 (GMT)
Subject: main - lvchange: remove unneeded call
Message-ID: <20210217105439.0DF47382E818@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f87ff95e329fce701ec93888a9bea7e7da7151a1
Commit:        f87ff95e329fce701ec93888a9bea7e7da7151a1
Parent:        096edeee718a4c5524e91fa613f015c9061d6a84
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 14 17:27:45 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 11:21:35 2021 +0100

lvchange: remove unneeded call

Sync is already happining in activate_and_wipe_lvlist().
---
 tools/lvchange.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index f37b68381..31633987b 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -410,13 +410,6 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
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


