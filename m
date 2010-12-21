From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 21 Dec 2010 16:41:54 +0100
Subject: [PATCH 22/23] Remove dead assignment in dm_event_get_registered_device
In-Reply-To: <cover.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
Message-ID: <0e0eb44bdebea6c5d74cb20e3638987793fd4543.1292945707.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

ret assigned from _do_event was actually not used and replaced with next
assignment without any read of returned value.

Code is reformated - so error path is put in the if branch and normal
code is put after the 'if' together with FIXME comment.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/dmeventd/libdevmapper-event.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 05ebf0a..4859189 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -718,17 +718,17 @@ int dm_event_get_registered_device(struct dm_event_handler *dmevh, int next)
 
 	uuid = dm_task_get_uuid(dmt);
 
-	if (!(ret = _do_event(next ? DM_EVENT_CMD_GET_NEXT_REGISTERED_DEVICE :
-			     DM_EVENT_CMD_GET_REGISTERED_DEVICE, dmevh->dmeventd_path,
-			      &msg, dmevh->dso, uuid, dmevh->mask, 0))) {
-		/* FIXME this will probably horribly break if we get
-		   ill-formatted reply */
-		ret = _parse_message(&msg, &reply_dso, &reply_uuid, &reply_mask);
-	} else {
+	if (_do_event(next ? DM_EVENT_CMD_GET_NEXT_REGISTERED_DEVICE :
+		      DM_EVENT_CMD_GET_REGISTERED_DEVICE, dmevh->dmeventd_path,
+		      &msg, dmevh->dso, uuid, dmevh->mask, 0)) {
 		ret = -ENOENT;
 		goto fail;
 	}
 
+	/* FIXME this will probably horribly break if we get
+	   ill-formatted reply */
+	ret = _parse_message(&msg, &reply_dso, &reply_uuid, &reply_mask);
+
 	dm_task_destroy(dmt);
 	dmt = NULL;
 
-- 
1.7.3.4


