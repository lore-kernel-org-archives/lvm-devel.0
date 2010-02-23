From: Takahiro Yasui <tyasui@redhat.com>
Date: Tue, 23 Feb 2010 13:45:02 -0500
Subject: [RFC][PATCH 1/4] dm: restore presuspend status
Message-ID: <4B84222E.10304@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When suspend procedure was interrupted just after a target's presuspend
method was executed, dm_suspend() calls the target's resume method to
cancel the target's state changes.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 drivers/md/dm.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

Index: linux-2.6.33-rc1-dm/drivers/md/dm.c
===================================================================
--- linux-2.6.33-rc1-dm.orig/drivers/md/dm.c
+++ linux-2.6.33-rc1-dm/drivers/md/dm.c
@@ -2475,7 +2475,6 @@ int dm_suspend(struct mapped_device *md,
 	if (noflush)
 		set_bit(DMF_NOFLUSH_SUSPENDING, &md->flags);
 
-	/* This does not get reverted if there's an error later. */
 	dm_table_presuspend_targets(map);
 
 	/*
@@ -2486,8 +2485,10 @@ int dm_suspend(struct mapped_device *md,
 	 */
 	if (!noflush && do_lockfs) {
 		r = lock_fs(md);
-		if (r)
+		if (r) {
+			dm_table_resume_targets(map);
 			goto out;
+		}
 	}
 
 	/*
@@ -2541,6 +2542,8 @@ int dm_suspend(struct mapped_device *md,
 			start_queue(md->queue);
 
 		unlock_fs(md);
+
+		dm_table_resume_targets(map);
 		goto out; /* pushback list is already flushed, so skip flush */
 	}
 


