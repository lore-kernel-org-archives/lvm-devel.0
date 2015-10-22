From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:33:56 +0000 (UTC)
Subject: master - dmeventd: code mode _get_device_status
Message-ID: <20151022213356.3775B6057E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=81e9ab3156badecc6a64447708c4ae4886e3c244
Commit:        81e9ab3156badecc6a64447708c4ae4886e3c244
Parent:        15dbd4b56a65dba2f19bb1685529731faa9894c6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 22 12:36:25 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:35:25 2015 +0200

dmeventd: code mode _get_device_status

Move _get_device_status() in code.
Use dm_task_no_flush() function when reading status.
(e.g. none blocking for thins pool)
---
 WHATS_NEW_DM                |    1 +
 daemons/dmeventd/dmeventd.c |   44 +++++++++++++++++++++++-------------------
 2 files changed, 25 insertions(+), 20 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 000bddd..5f92657 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.110 - 
 ======================================
+  Dmeventd read device status with 'noflush'.
   Dmeventd closes control device when no device is monitored.
   Thin plugin for dmeventd improved percentage usage.
   Snapshot plugin for dmeventd improved percentage usage.
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 26e611d..cde4f93 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -570,6 +570,30 @@ fail:
 	return ret;
 }
 
+static struct dm_task *_get_device_status(struct thread_status *ts)
+{
+	struct dm_task *dmt = dm_task_create(DM_DEVICE_STATUS);
+
+	if (!dmt)
+		return_NULL;
+
+	if (!dm_task_set_uuid(dmt, ts->device.uuid)) {
+		dm_task_destroy(dmt);
+		return_NULL;
+	}
+
+	/* Non-blocking status read */
+	if (!dm_task_no_flush(dmt))
+		log_warn("WARNING: Can't set no_flush for dm status.");
+
+	if (!dm_task_run(dmt)) {
+		dm_task_destroy(dmt);
+		return_NULL;
+	}
+
+	return dmt;
+}
+
 /*
  * Find an existing thread for a device.
  *
@@ -886,26 +910,6 @@ static void _monitor_unregister(void *arg)
 	_unlock_mutex();
 }
 
-static struct dm_task *_get_device_status(struct thread_status *ts)
-{
-	struct dm_task *dmt = dm_task_create(DM_DEVICE_STATUS);
-
-	if (!dmt)
-		return NULL;
-
-	if (!dm_task_set_uuid(dmt, ts->device.uuid)) {
-		dm_task_destroy(dmt);
-		return NULL;
-	}
-
-	if (!dm_task_run(dmt)) {
-		dm_task_destroy(dmt);
-		return NULL;
-	}
-
-	return dmt;
-}
-
 /* Device monitoring thread. */
 static void *_monitor_thread(void *arg)
 {


