From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat,  7 Sep 2013 07:19:58 +0000 (UTC)
Subject: master - thin: fix monitoring of thin pool volume
Message-ID: <20130907071958.1ADD4610C9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=655296609eaab2d3255178b22b15910c4771b864
Commit:        655296609eaab2d3255178b22b15910c4771b864
Parent:        4c001a78544d29688f6609b1ceafe123af280323
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 7 02:46:48 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Sep 7 03:31:04 2013 +0200

thin: fix monitoring of thin pool volume

Properly skip unmonitoring of thin pool volume in deactivation code
path. Code makes sure if there is just any thin pool user
it stays monitored with all its resources.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |   16 ++++++++--------
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 11f31aa..8bc95c2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Fix dmeventd unmonitoring of thin pools.
   Fix lvresize for stacked thin pool volumes (i.e. mirrors).
   Write Completed debug message before reinstating log defaults after command.
   Skip pvmove of RAID, thin, snapshot, origin, or mirror LVs in a cluster.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 61dbc02..1706ae5 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1416,7 +1416,6 @@ int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
 	int (*monitor_fn) (struct lv_segment *s, int e);
 	uint32_t s;
 	static const struct lv_activate_opts zlaopts = { 0 };
-	static const struct lv_activate_opts thinopts = { .skip_in_use = 1 };
 	struct lvinfo info;
 
 	if (!laopts)
@@ -1435,11 +1434,12 @@ int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
 	/*
 	 * Allow to unmonitor thin pool via explicit pool unmonitor
 	 * or unmonitor before the last thin pool user deactivation
-	 * Skip unmonitor, if invoked via unmonitor of thin volume
+	 * Skip unmonitor, if invoked via deactivation of thin volume
 	 * and there is another thin pool user (open_count > 1)
+	 * FIXME  think about watch ruler influence.
 	 */
-	if (laopts->skip_in_use && lv_info(lv->vg->cmd, lv, 1, &info, 1, 0) &&
-	    (info.open_count != 1)) {
+	if (laopts->skip_in_use && lv_is_thin_pool(lv) &&
+	    lv_info(lv->vg->cmd, lv, 1, &info, 1, 0) && (info.open_count > 1)) {
 		log_debug_activation("Skipping unmonitor of opened %s (open:%d)",
 				     lv->name, info.open_count);
 		return 1;
@@ -1495,14 +1495,13 @@ int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 
 		/*
-		 * If requested unmonitoring of thin volume, request test
-		 * if there is no other thin pool user
+		 * If requested unmonitoring of thin volume, preserve skip_in_use flag.
 		 *
 		 * FIXME: code here looks like _lv_postorder()
 		 */
 		if (seg->pool_lv &&
 		    !monitor_dev_for_events(cmd, seg->pool_lv,
-					    (!monitor) ? &thinopts : NULL, monitor))
+					    (!monitor) ? laopts : NULL, monitor))
 			r = 0;
 
 		if (seg->metadata_lv &&
@@ -1912,6 +1911,7 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, struct logical_vo
 {
 	struct logical_volume *lv_to_free = NULL;
 	struct lvinfo info;
+	static const struct lv_activate_opts laopts = { .skip_in_use = 1 };
 	int r = 0;
 
 	if (!activation())
@@ -1949,7 +1949,7 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, struct logical_vo
 
 	lv_calculate_readahead(lv, NULL);
 
-	if (!monitor_dev_for_events(cmd, lv, NULL, 0))
+	if (!monitor_dev_for_events(cmd, lv, &laopts, 0))
 		stack;
 
 	critical_section_inc(cmd, "deactivating");


