From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 1 Aug 2017 06:01:15 -0400
Subject: master - libdm: log_warn
Message-ID: <201708011001.v71A1Fvg011487@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2593777f65da806e24d9b1a2c9cab25ff59c5351
Commit:        2593777f65da806e24d9b1a2c9cab25ff59c5351
Parent:        c1b5f38bbe30e14f33a0cd76eed74c48280865ee
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 24 14:40:41 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 1 11:53:12 2017 +0200

libdm: log_warn

No real effect anyway - function returs '1' in all paths,
but just make sure we do not have 'log_error()' on non-error path.
---
 libdm/libdm-deptree.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index cf4fd62..b0a48f3 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -938,7 +938,7 @@ static int _info_by_dev(uint32_t major, uint32_t minor, int with_open_count,
 	}
 
 	if (!with_open_count && !dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count");
+		log_warn("WARNING: Failed to disable open_count.");
 
 	if (!(r = dm_task_run(dmt)))
 		goto_out;
@@ -1053,7 +1053,7 @@ static int _deactivate_node(const char *name, uint32_t major, uint32_t minor,
 	}
 
 	if (!dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count");
+		log_warn("WARNING: Failed to disable open_count.");
 
 	if (cookie)
 		if (!dm_task_set_cookie(dmt, cookie, udev_flags))
@@ -1343,7 +1343,7 @@ static int _rename_node(const char *old_name, const char *new_name, uint32_t maj
 		goto_out;
 
 	if (!dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count");
+		log_warn("WARNING: Failed to disable open_count.");
 
 	if (!dm_task_set_cookie(dmt, cookie, udev_flags))
 		goto out;
@@ -1384,10 +1384,10 @@ static int _resume_node(const char *name, uint32_t major, uint32_t minor,
 	}
 
 	if (!dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count");
+		log_warn("WARNING: Failed to disable open_count.");
 
 	if (!dm_task_set_read_ahead(dmt, read_ahead, read_ahead_flags))
-		log_error("Failed to set read ahead");
+		log_warn("WARNING: Failed to set read ahead.");
 
 	if (!dm_task_set_cookie(dmt, cookie, udev_flags))
 		goto_out;
@@ -1430,13 +1430,13 @@ static int _suspend_node(const char *name, uint32_t major, uint32_t minor,
 	}
 
 	if (!dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count");
+		log_warn("WARNING: Failed to disable open_count.");
 
 	if (skip_lockfs && !dm_task_skip_lockfs(dmt))
-		log_error("Failed to set skip_lockfs flag.");
+		log_warn("WARNING: Failed to set skip_lockfs flag.");
 
 	if (no_flush && !dm_task_no_flush(dmt))
-		log_error("Failed to set no_flush flag.");
+		log_warn("WARNING: Failed to set no_flush flag.");
 
 	if ((r = dm_task_run(dmt))) {
 		inc_suspended();
@@ -1467,7 +1467,7 @@ static int _thin_pool_get_status(struct dm_tree_node *dnode,
 	}
 
 	if (!dm_task_no_flush(dmt))
-		log_warn("Can't set no_flush flag."); /* Non fatal */
+		log_warn("WARNING: Can't set no_flush flag."); /* Non fatal */
 
 	if (!dm_task_run(dmt))
 		goto_out;
@@ -2031,7 +2031,7 @@ static int _create_node(struct dm_tree_node *dnode)
 	}
 
 	if (!dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count");
+		log_warn("WARNING: Failed to disable open_count.");
 
 	if ((r = dm_task_run(dmt))) {
 		if (!(r = dm_task_get_info(dmt, &dnode->info)))


