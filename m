From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:02:42 +0000 (UTC)
Subject: dev-mornfall-lvmcache - dmeventd: return error if device is not found
Message-ID: <20130605120242.CAA72613BE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a5ad1ee8587daf1001e64775d3478f345e77e324
Commit:        a5ad1ee8587daf1001e64775d3478f345e77e324
Parent:        8d004b51274b2d7638673c4985c0c298d253ef0d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 25 10:17:22 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 25 17:33:24 2013 +0200

dmeventd: return error if device is not found

Do not return 'ok' status if we have failed to found device.
(Since it looks like the device is monitored)
---
 WHATS_NEW_DM                          |    1 +
 daemons/dmeventd/libdevmapper-event.c |    9 ++++++---
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index afaf266..39ebcb2 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.78 - 
 ===================================
+  Report error for nonexisting devices in dmeventd communication.
   Prevent double free error after dmeventd call of _fill_device_data().
   Update dmevent structure message_data to simplify/fix error path handling.
   Validate passed params to dm_get_status_raid/thin/thin_pool(). 
diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index f7b586e..c692a88 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -714,12 +714,15 @@ int dm_event_get_registered_device(struct dm_event_handler *dmevh, int next)
 	char *reply_dso = NULL, *reply_uuid = NULL;
 	enum dm_event_mask reply_mask = 0;
 	struct dm_task *dmt = NULL;
-	struct dm_event_daemon_message msg = { 0, 0, NULL };
+	struct dm_event_daemon_message msg = { 0 };
 	struct dm_info info;
 
 	if (!(dmt = _get_device_info(dmevh))) {
-		stack;
-		return 0;
+		log_debug("Device does not exists (uuid=%s, name=%s, %d:%d).",
+			  dmevh->uuid, dmevh->dev_name,
+			  dmevh->major, dmevh->minor);
+		ret = -ENODEV;
+		goto fail;
 	}
 
 	uuid = dm_task_get_uuid(dmt);


