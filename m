From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  4 Feb 2013 18:08:16 +0000 (UTC)
Subject: master - thin: use noflush for obtaining transaction_id
Message-ID: <20130204180816.7E2343523@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a4870c79cad46e6063862d7cc828a2bbef9251c3
Commit:        a4870c79cad46e6063862d7cc828a2bbef9251c3
Parent:        153ce89af36e716ace78182d8fe0668a6e98053d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 17 10:54:41 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 4 19:05:56 2013 +0100

thin: use noflush for obtaining transaction_id

Do not flush thin pool data, when reading transation_id status.
---
 WHATS_NEW                  |    1 +
 lib/activate/activate.c    |    2 +-
 lib/activate/dev_manager.c |    6 +++++-
 lib/activate/dev_manager.h |    3 ++-
 libdm/libdm-deptree.c      |    3 +++
 5 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index cfaa152..272c6c8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Avoid flushing thin pool when quering for transaction_id.
   Add internal function lv_layer() to obtain layer name for LV.
   Report partial and in-sync RAID attribute based on kernel status
   Fix blkdeactivate to handle nested mountpoints and mangled mount paths.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index e39c04a..6187828 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -888,7 +888,7 @@ int lv_thin_pool_transaction_id(const struct logical_volume *lv,
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
 
-	if (!(r = dev_manager_thin_pool_status(dm, lv, &status)))
+	if (!(r = dev_manager_thin_pool_status(dm, lv, &status, 1)))
 		stack;
 	else
 		*transaction_id = status->transaction_id;
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index e4cb0c3..1916d3e 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1124,7 +1124,8 @@ static int _belong_to_vg(const char *vgname, const char *name)
 
 int dev_manager_thin_pool_status(struct dev_manager *dm,
 				 const struct logical_volume *lv,
-				 struct dm_status_thin_pool **status)
+				 struct dm_status_thin_pool **status,
+				 int noflush)
 {
 	const char *dlid;
 	struct dm_task *dmt;
@@ -1146,6 +1147,9 @@ int dev_manager_thin_pool_status(struct dev_manager *dm,
 	if (!dm_task_no_open_count(dmt))
 		log_error("Failed to disable open_count.");
 
+	if (noflush && !dm_task_no_flush(dmt))
+		log_warn("Can't set no_flush.");
+
 	if (!dm_task_run(dmt))
 		goto_out;
 
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index e363aed..a4556e7 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -59,7 +59,8 @@ int dev_manager_raid_status(struct dev_manager *dm,
 			    struct dm_status_raid **status);
 int dev_manager_thin_pool_status(struct dev_manager *dm,
 				 const struct logical_volume *lv,
-				 struct dm_status_thin_pool **status);
+				 struct dm_status_thin_pool **status,
+				 int noflush);
 int dev_manager_thin_pool_percent(struct dev_manager *dm,
 				  const struct logical_volume *lv,
 				  int metadata, percent_t *percent);
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 6a73859..5e938d7 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1360,6 +1360,9 @@ static int _thin_pool_status_transaction_id(struct dm_tree_node *dnode, uint64_t
 		goto out;
 	}
 
+	if (!dm_task_no_flush(dmt))
+		log_warn("Can't set no_flush flag."); /* Non fatal */
+
 	if (!dm_task_run(dmt))
 		goto_out;
 


