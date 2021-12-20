From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Dec 2021 15:14:04 +0000 (GMT)
Subject: main - toollib: avoid repeated remove of online vg
Message-ID: <20211220151404.EA9B33858409@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ed1651d11f42ea7157b7b0aebf498b97e56b98aa
Commit:        ed1651d11f42ea7157b7b0aebf498b97e56b98aa
Parent:        522561e64b5fe73cb9d01c2ee2d4b7624b0ddff4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 17 13:18:56 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 20 16:13:28 2021 +0100

toollib: avoid repeated remove of online vg

Call just once unlink after every deactivation of LV from VG.
---
 lib/commands/toolcontext.h | 1 +
 tools/toollib.c            | 7 ++++++-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index fb7182db6..4d7d4630d 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -202,6 +202,7 @@ struct cmd_context {
 	unsigned backup_disabled:1;		/* skip repeated debug message */
 	unsigned event_activation:1;		/* whether event_activation is set */
 	unsigned udevoutput:1;
+	unsigned online_vg_file_removed:1;
 
 	/*
 	 * Devices and filtering.
diff --git a/tools/toollib.c b/tools/toollib.c
index 33b704134..3b3a20689 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -829,8 +829,11 @@ int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
 	 * user may want to take charge of activation changes to the VG
 	 * and not have the system autoactivation interfere.
 	 */
-	if (!is_change_activating(activate) && cmd->event_activation)
+	if (!is_change_activating(activate) && cmd->event_activation &&
+	    !cmd->online_vg_file_removed) {
+		cmd->online_vg_file_removed = 1;
 		online_vg_file_remove(lv->vg->name);
+	}
 
 	set_lv_notify(lv->vg->cmd);
 
@@ -2983,6 +2986,8 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	struct glv_list *glvl, *tglvl;
 	int do_report_ret_code = 1;
 
+	cmd->online_vg_file_removed = 0;
+
 	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_LV);
 
 	vg_uuid[0] = '\0';


