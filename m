From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 21 Dec 2010 16:41:44 +0100
Subject: [PATCH 12/23] Add tests for dm_task_set operations
In-Reply-To: <cover.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
Message-ID: <1f564d8fdc241e78ec0b7f3e612d7cb7dcffb500.1292945707.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Check for errors in dm_task_set calls and use  goto_bad macro with stack
Replace  label  failed: with bad:

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/dmeventd/libdevmapper-event.c |   27 +++++++++++++++------------
 1 files changed, 15 insertions(+), 12 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index bc8ad99..05ebf0a 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -538,34 +538,37 @@ static struct dm_task *_get_device_info(const struct dm_event_handler *dmevh)
 		return NULL;
 	}
 
-	if (dmevh->uuid)
-		dm_task_set_uuid(dmt, dmevh->uuid);
-	else if (dmevh->dev_name)
-		dm_task_set_name(dmt, dmevh->dev_name);
-	else if (dmevh->major && dmevh->minor) {
-		dm_task_set_major(dmt, dmevh->major);
-		dm_task_set_minor(dmt, dmevh->minor);
-        }
+	if (dmevh->uuid) {
+		if (!dm_task_set_uuid(dmt, dmevh->uuid))
+			goto_bad;
+	} else if (dmevh->dev_name) {
+		if (!dm_task_set_name(dmt, dmevh->dev_name))
+			goto_bad;
+	} else if (dmevh->major && dmevh->minor) {
+		if (!dm_task_set_major(dmt, dmevh->major) ||
+		    !dm_task_set_minor(dmt, dmevh->minor))
+			goto_bad;
+	}
 
 	/* FIXME Add name or uuid or devno to messages */
 	if (!dm_task_run(dmt)) {
 		log_error("_get_device_info: dm_task_run() failed");
-		goto failed;
+		goto bad;
 	}
 
 	if (!dm_task_get_info(dmt, &info)) {
 		log_error("_get_device_info: failed to get info for device");
-		goto failed;
+		goto bad;
 	}
 
 	if (!info.exists) {
 		log_error("_get_device_info: device not found");
-		goto failed;
+		goto bad;
 	}
 
 	return dmt;
 
-failed:
+      bad:
 	dm_task_destroy(dmt);
 	return NULL;
 }
-- 
1.7.3.4


