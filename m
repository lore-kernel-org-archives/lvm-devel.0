From: David Teigland <teigland@sourceware.org>
Date: Mon, 30 Apr 2018 16:57:09 -0400
Subject: master - clvmd: don't repair vg from vg_read in clvmd
Message-ID: <201804302057.w3UKv9Wg019504@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=029a76b4f830750cc312c062d77cdaa4d1a1bba9
Commit:        029a76b4f830750cc312c062d77cdaa4d1a1bba9
Parent:        c365d7de4f49a0b175772548c92961143c078921
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 30 15:47:00 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 30 15:56:51 2018 -0500

clvmd: don't repair vg from vg_read in clvmd

The mixed up vg repair code in vg_read was trying
to repair a vg when vg_read was called by clvmd.
The clvmd daemon isn't supposed to be repairing
or writing a vg.

(This is a temporary workaround; vg repair will soon
be pulled out of vg_read so it can be called in a
controlled way and consolidated instead of spread
around.)
---
 lib/metadata/metadata.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 97225df..5e376f3 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4282,6 +4282,11 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			return correct_vg;
 		}
 
+		if (cmd->is_clvmd) {
+			_free_pv_list(&all_pvs);
+			return correct_vg;
+		}
+
 		if (skipped_rescan) {
 			log_warn("Not repairing metadata for VG %s.", vgname);
 			_free_pv_list(&all_pvs);
@@ -4335,7 +4340,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	}
 
 	/* We have the VG now finally, check if PV ext info is in sync with VG metadata. */
-	if (!_check_or_repair_pv_ext(cmd, correct_vg,
+	if (!cmd->is_clvmd && !_check_or_repair_pv_ext(cmd, correct_vg,
 				     skipped_rescan ? 0 : *consistent,
 				     &inconsistent_pvs)) {
 		release_vg(correct_vg);
@@ -4344,7 +4349,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 
 	*consistent = !inconsistent_pvs;
 
-	if (correct_vg && *consistent && !skipped_rescan) {
+	if (!cmd->is_clvmd && correct_vg && *consistent && !skipped_rescan) {
 		if (update_old_pv_ext && !_vg_update_old_pv_ext_if_needed(correct_vg)) {
 			release_vg(correct_vg);
 			return_NULL;


