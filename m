From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 23 Sep 2013 10:16:09 +0000 (UTC)
Subject: master - cleanup: monitoring more readable
Message-ID: <20130923101609.2239461165@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=861a3b2f1940cd3667cc353c762ff3d1ef75c37b
Commit:        861a3b2f1940cd3667cc353c762ff3d1ef75c37b
Parent:        cafde608909b87aedeb76f0eda1397f7bf98fea4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 5 11:32:42 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 23 11:35:15 2013 +0200

cleanup: monitoring more readable

Put continue path into one code segment.
---
 lib/activate/activate.c |   18 +++++++-----------
 1 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 7b535c6..ecd35b2 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1514,22 +1514,18 @@ int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
 		    !monitor_dev_for_events(cmd, seg->metadata_lv, NULL, monitor))
 			r = 0;
 
-		if (!seg_monitored(seg) || (seg->status & PVMOVE))
+		if (!seg_monitored(seg) ||
+		    (seg->status & PVMOVE) ||
+		    !seg->segtype->ops->target_monitored) /* doesn't support registration */
 			continue;
 
-		monitor_fn = NULL;
-
-		/* Check monitoring status */
-		if (seg->segtype->ops->target_monitored)
-			monitored = seg->segtype->ops->target_monitored(seg, &pending);
-		else
-			continue;  /* segtype doesn't support registration */
+		monitored = seg->segtype->ops->target_monitored(seg, &pending);
 
-		/*
-		 * FIXME: We should really try again if pending
-		 */
+		/* FIXME: We should really try again if pending */
 		monitored = (pending) ? 0 : monitored;
 
+		monitor_fn = NULL;
+
 		if (monitor) {
 			if (monitored)
 				log_verbose("%s/%s already monitored.", lv->vg->name, lv->name);


