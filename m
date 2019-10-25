From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Oct 2019 18:55:40 -0400
Subject: stable-2.02 - snapshot: correctly check device id of merged thin
Message-ID: <201910252255.x9PMtexN012007@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=20d94e4072a93c199781e282d142ba7c80c9a437
Commit:        20d94e4072a93c199781e282d142ba7c80c9a437
Parent:        bc200e0b16676398eb0e2244ffa14315d25a1a5a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 25 23:31:08 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 26 00:39:20 2019 +0200

snapshot: correctly check device id of merged thin

When checking device id of a thin device that is just being
merged - the snapshot actually could have been already finished
which means  '-real' suffix for the LV is already gone and just LV
is there - so check explicitely for this condition and use
correct UUID for this case.
---
 lib/activate/dev_manager.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 886e11b..becbf6d 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1594,6 +1594,9 @@ int dev_manager_thin_percent(struct dev_manager *dm,
 	return 1;
 }
 
+/*
+ * Explore state of running DM table to obtain currently used deviceId
+ */
 int dev_manager_thin_device_id(struct dev_manager *dm,
 			       const struct logical_volume *lv,
 			       uint32_t *device_id)
@@ -1603,10 +1606,16 @@ int dev_manager_thin_device_id(struct dev_manager *dm,
 	struct dm_info info;
 	uint64_t start, length;
 	char *params, *target_type = NULL;
+	const char *layer = lv_layer(lv);
 	int r = 0;
 
+	if (lv_is_merging_origin(lv) && !lv_info(lv->vg->cmd, lv, 1, NULL, 0, 0))
+		/* If the merge has already happened, that table
+		 * can already be using correct LV without -real layer */
+		layer = NULL;
+
 	/* Build dlid for the thin layer */
-	if (!(dlid = build_dm_uuid(dm->mem, lv, lv_layer(lv))))
+	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
 		return_0;
 
 	if (!(dmt = _setup_task_run(DM_DEVICE_TABLE, &info, NULL, dlid, 0, 0, 0, 0, 1, 0)))


