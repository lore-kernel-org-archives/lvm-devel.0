From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Dec 2016 22:38:30 +0000 (UTC)
Subject: master - thin: refresh status when error processing fails
Message-ID: <20161222223830.27F28611D0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dd19b5698553b4eb0214825a6dcb88a5330b4097
Commit:        dd19b5698553b4eb0214825a6dcb88a5330b4097
Parent:        77997c7673bfca56f51ae4eb55a50bc76e40fe79
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 22 23:28:04 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 22 23:37:07 2016 +0100

thin: refresh status when error processing fails

When thin-pool processes event and 'lvextend --use-policies' fails
rather capture up-to-date new info as the fullness percentage may
have jumped noticable. This way we could use 'more' correct numbers
when checking for thresholds.
---
 WHATS_NEW_DM                                  |    1 +
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |   26 +++++++++++++++++++++++++
 2 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 3f9eeac..67aed5e 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.138 - 
 =====================================
+  Thin dmeventd plugin reacts faster on lvextend failure path with umount.
   Add dm_stats_bind_from_fd() to bind a stats handle from a file descriptor.
   Do not try call callback when reverting activation on error path.
   Fix file mapping for extents with physically adjacent extents.
diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index 0c26baf..65de465 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -328,6 +328,7 @@ void process_event(struct dm_task *dmt,
 	char *params;
 	int needs_policy = 0;
 	int needs_umount = 0;
+	struct dm_task *new_dmt = NULL;
 
 #if THIN_DEBUG
 	log_debug("Watch for tp-data:%.2f%%  tp-metadata:%.2f%%.",
@@ -346,6 +347,28 @@ void process_event(struct dm_task *dmt,
 			goto out;
 
 		stack;
+
+		/*
+		 * Rather update oldish status
+		 * since after 'command' processing
+		 * percentage info could have changed a lot.
+		 * If we would get above UMOUNT_THRESH
+		 * we would wait for next sigalarm.
+		 */
+		if (!(new_dmt = dm_task_create(DM_DEVICE_STATUS)))
+			goto_out;
+
+		if (!dm_task_set_uuid(new_dmt, dm_task_get_uuid(dmt)))
+			goto_out;
+
+		/* Non-blocking status read */
+		if (!dm_task_no_flush(new_dmt))
+			log_warn("WARNING: Can't set no_flush for dm status.");
+
+		if (!dm_task_run(new_dmt))
+			goto_out;
+
+		dmt = new_dmt;
 	}
 
 	dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
@@ -433,6 +456,9 @@ out:
 			 device, state->fails);
 		pthread_kill(pthread_self(), SIGALRM);
 	}
+
+	if (new_dmt)
+		dm_task_destroy(new_dmt);
 }
 
 int register_device(const char *device,


