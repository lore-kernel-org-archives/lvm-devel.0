From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  4 Nov 2014 17:00:01 +0000 (UTC)
Subject: master - dmeventd: Include shutdown threads in responses.
Message-ID: <20141104170001.DA290607A5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=89f635a0759dd9499155b4bf6bf8c07090444ade
Commit:        89f635a0759dd9499155b4bf6bf8c07090444ade
Parent:        6b25faa218fc5cd1601e5418ce1481400386ecce
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Nov 4 16:58:14 2014 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Nov 4 16:58:14 2014 +0000

dmeventd: Include shutdown threads in responses.

When responding to DM_EVENT_CMD_GET_REGISTERED_DEVICE no longer
ignore threads that have already been unregistered but which
are still present.

This means the caller can unregister a device and poll dmeventd
to ensure the monitoring thread has gone away before removing
the device.  If a device was registered and unregistered in quick
succession and then removed, WAITEVENT could run in parallel with
the REMOVE.

Threads are moved to the _thread_registry_unused list when they
are unregistered.
---
 WHATS_NEW                   |    1 +
 daemons/dmeventd/dmeventd.c |   12 ++++++++++++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3914392..6c76fa9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Include threads being shutdown in dmeventd device registration responses.
   Inital support for external users of thin pools based on transaction_id.
   Report some basic percentage info for cache pools.
   Introduce size_mb_arg_with_percent() for advanced size arg reading.
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index faae5ba..1b950cf 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1177,6 +1177,18 @@ static int _get_registered_dev(struct message_data *message_data, int next)
 	if (hit && !next)
 		goto reg;
 
+	/*
+	 * If we didn't get a match, try the threads waiting to be deleted.
+	 * FIXME Do something similar if 'next' is set.
+	 */
+	if (!hit && !next)
+		dm_list_iterate_items(thread, &_thread_registry_unused)
+			if (_want_registered_device(message_data->dso_name,
+						    message_data->device_uuid, thread)) {
+				hit = thread;
+				goto reg;
+			}
+
 	if (!hit)
 		goto out;
 


