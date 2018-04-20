From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 20 Apr 2018 07:01:58 -0400
Subject: master - mirror: block_on_error only with monitoring
Message-ID: <201804201101.w3KB1wmt031229@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=55d83f9f6ee1892d419bdd9d50c3450ac41f6749
Commit:        55d83f9f6ee1892d419bdd9d50c3450ac41f6749
Parent:        66400d003d357611f19f99fb68500c364fbef547
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 29 21:10:58 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 20 12:13:51 2018 +0200

mirror: block_on_error only with monitoring

When user configured lvm2 to NOT user monitoring, activated mirror
actually hang upon error and it's quite unusable moment.

So instead Warn those 'brave' non-monitoring users about possible
problem and activation mirror without blocking error handling.

This also makes it a bit simpler for test suite to handle trouble
cases when test is running without  dmeventd.
---
 lib/commands/toolcontext.h |    1 +
 lib/mirror/mirrored.c      |   10 ++++++++--
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 4225c57..89d1088 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -169,6 +169,7 @@ struct cmd_context {
 	unsigned activate_component:1;		/* command activates component LV */
 	unsigned process_component_lvs:1;	/* command processes also component LVs */
 
+	unsigned mirror_warn_printed:1;		/* command already printed warning about non-monitored mirrors */
 	/*
 	 * Filtering.
 	 */
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index e6dc99b..10828e8 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -314,8 +314,14 @@ static int _add_log(struct dm_pool *mem, struct lv_segment *seg,
 	if (mirror_in_sync() && !(seg->status & PVMOVE))
 		log_flags |= DM_NOSYNC;
 
-	if (_block_on_error_available && !(seg->status & PVMOVE))
-		log_flags |= DM_BLOCK_ON_ERROR;
+	if (_block_on_error_available && !(seg->status & PVMOVE)) {
+		if (dmeventd_monitor_mode() > 0)
+			log_flags |= DM_BLOCK_ON_ERROR;
+		else {
+			log_warn_suppress(seg->lv->vg->cmd->mirror_warn_printed, "WARNING: Mirrors without monitoring will not react on failures.");
+			seg->lv->vg->cmd->mirror_warn_printed = 1;
+		}
+	}
 
 	return dm_tree_node_add_mirror_target_log(node, region_size, clustered, log_dlid, area_count, log_flags);
 }


