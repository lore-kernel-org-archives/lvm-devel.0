From: David Teigland <teigland@sourceware.org>
Date: Thu, 1 Nov 2018 14:26:11 -0400
Subject: master - lvmlockd: deactivate lvmlock LV in vgchange
Message-ID: <201811011826.wA1IQB88020335@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f6a54a50a0f5e1a06e1a4da6ca17f9e84773eb88
Commit:        f6a54a50a0f5e1a06e1a4da6ca17f9e84773eb88
Parent:        7a170873aa13cc09dcc2b4d0a918e45278c4c4dd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 25 10:51:25 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 1 13:25:21 2018 -0500

lvmlockd: deactivate lvmlock LV in vgchange

When changing a VG to lock_type sanlock, the internal
lvmlock LV was left active at the end of vgchange.
It shouldn't be active until lockstart.
---
 tools/vgchange.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index c8f894d..13b72cc 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -993,6 +993,18 @@ static int _vgchange_locktype_single(struct cmd_context *cmd, const char *vg_nam
 
 	backup(vg);
 
+	/*
+	 * When init_vg_sanlock is called for vgcreate, the lockspace remains
+	 * started and lvmlock remains active, but when called for
+	 * vgchange --locktype sanlock, the lockspace is not started so the
+	 * lvmlock LV should be deactivated at the end.  vg_write writes the
+	 * new leases to lvmlock, so we need to wait until after vg_write to
+	 * deactivate it.
+	 */
+	if (vg->lock_type && !strcmp(vg->lock_type, "sanlock") &&
+	    (cmd->command->command_enum == vgchange_locktype_CMD))
+		deactivate_lv(cmd, vg->sanlock_lv);
+
 	log_print_unless_silent("Volume group \"%s\" successfully changed", vg->name);
 
 	return ECMD_PROCESSED;


