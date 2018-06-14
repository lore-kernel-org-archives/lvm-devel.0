From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Jun 2018 16:03:12 -0400
Subject: master - pvscan: move start of polling into vgchange
Message-ID: <201806142003.w5EK3CqW004057@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=218c57410c32bfa7bf7044cc6d94fd9253d6b547
Commit:        218c57410c32bfa7bf7044cc6d94fd9253d6b547
Parent:        752c39d91db55ae637fef3b8066e1a78f894609d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 14 21:07:59 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 14 22:02:01 2018 +0200

pvscan: move start of polling into vgchange

Restoring polling for activated volumes lost with my recent commit:
75fed05d3ef648583764ff56cc577e0f3eba1bba and move start of polling
directly into _activate_lvs_in_vg() - as there we know exactly
if there was some volume even activated.

Also make it sharing same code for pvscan -aay.
---
 tools/pvscan.c   |   10 ----------
 tools/vgchange.c |   25 +++++++++++++++++++------
 2 files changed, 19 insertions(+), 16 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 508f283..61530ee 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -248,16 +248,6 @@ static int _pvscan_autoactivate_single(struct cmd_context *cmd, const char *vg_n
 		goto out;
 	}
 
-	/*
-	 * After sucessfull activation we need to initialise polling
-	 * for all activated LVs in a VG. Possible enhancement would
-	 * be adding --poll y|n cmdline option for pvscan and call
-	 * init_background_polling routine in autoactivation handler.
-	 */
-	log_debug_activation("Starting background polling for VG %s.", vg_name);
-
-	if (!(vgchange_background_polling(cmd, vg)))
-		goto_out;
 out:
 	return ECMD_PROCESSED;
 }
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 55bc476..c513470 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -127,17 +127,29 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 
 	sigint_restore();
 
+	if (expected_count)
+		log_verbose("%sctivated %d logical volumes in volume group %s.",
+			    is_change_activating(activate) ? "A" : "Dea",
+			    count, vg->name);
+
+	/*
+	 * After sucessfull activation we need to initialise polling
+	 * for all activated LVs in a VG. Possible enhancement would
+	 * be adding --poll y|n cmdline option for pvscan and call
+	 * init_background_polling routine in autoactivation handler.
+	 */
+	if (count && is_change_activating(activate) &&
+	    !vgchange_background_polling(cmd, vg)) {
+		stack;
+		r = 0;
+	}
+
 	/* Wait until devices are available */
 	if (!sync_local_dev_names(vg->cmd)) {
 		log_error("Failed to sync local devices for VG %s.", vg->name);
 		r = 0;
 	}
 
-	if (expected_count)
-		log_verbose("%s %d logical volumes in volume group %s",
-			    is_change_activating(activate) ?
-			    "Activated" : "Deactivated", count, vg->name);
-
 	return r;
 }
 
@@ -163,7 +175,8 @@ int vgchange_background_polling(struct cmd_context *cmd, struct volume_group *vg
 	int polled;
 
 	if (background_polling()) {
-	        polled = _poll_lvs_in_vg(cmd, vg);
+		log_debug_activation("Starting background polling for volume group \"%s\".", vg->name);
+		polled = _poll_lvs_in_vg(cmd, vg);
 		if (polled)
 			log_print_unless_silent("Background polling started for %d logical volume(s) "
 						"in volume group \"%s\"",


