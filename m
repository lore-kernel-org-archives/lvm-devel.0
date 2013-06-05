From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:04:10 +0000 (UTC)
Subject: dev-mornfall-lvmcache - snapshot: skip monitor for large cows
Message-ID: <20130605120410.9CC6B60F8B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9966842810b9044d0a59eebbf05856a3a10102b4
Commit:        9966842810b9044d0a59eebbf05856a3a10102b4
Parent:        77952151af683eda4210cbfe4f9928f736ee92a9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 27 10:20:06 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 27 10:35:43 2013 +0200

snapshot: skip monitor for large cows

If snapshot cow device is already big enough to
cover whole origin, do not monitor it.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |    7 +++++++
 lib/metadata/lv.c       |    2 ++
 3 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7f6c134..3b88732 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Skip monitoring of snapshots that are already bigger then origin.
   Add lv_is_cow_covering_origin() to check if cow covers origin size.
   Use libdm dm_get_status_snapshot() to parse snapshot status.
   Add detection of mounted fs also for vgchange deactivation.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index bb8f6f9..7f3d7c6 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1456,6 +1456,13 @@ int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
 		return 1;
 	}
 
+	/* Do not monitor snapshot that already covers origin */
+	if (monitor && lv_is_cow_covering_origin(lv)) {
+		log_debug_activation("Skipping monitor of snapshot larger "
+				     "then origin %s.", lv->name);
+		return 1;
+	}
+
 	/*
 	 * In case of a snapshot device, we monitor lv->snapshot->lv,
 	 * not the actual LV itself.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 4795032..b47b096 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -148,6 +148,8 @@ char *lvseg_monitor_dup(struct dm_pool *mem, const struct lv_segment *seg)
 	// log_debug("Query LV:%s mon:%s segm:%s tgtm:%p  segmon:%d statusm:%d", seg->lv->name, segm->lv->name, segm->segtype->name, segm->segtype->ops->target_monitored, seg_monitored(segm), (int)(segm->status & PVMOVE));
 	if (!segm->segtype->ops->target_monitored)
 		/* Nothing to do, monitoring not supported */;
+	else if (lv_is_cow_covering_origin(seg->lv))
+		/* Nothing to do, snapshot already covers origin */;
 	else if (!seg_monitored(segm) || (segm->status & PVMOVE))
 		s = "not monitored";
 	else if (lv_info(seg->lv->vg->cmd, seg->lv, 1, &info, 0, 0) && info.exists) {


