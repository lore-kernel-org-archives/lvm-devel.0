From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Mar 2014 10:23:39 +0000 (UTC)
Subject: master - cleanup: indent
Message-ID: <20140325102339.101E860F9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5c9165705a3303d6ac98c828420566e01c2d128e
Commit:        5c9165705a3303d6ac98c828420566e01c2d128e
Parent:        c7b2c08a6b30422cfa95da0348876f54b6f4cf6f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 24 09:19:37 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 25 11:22:58 2014 +0100

cleanup: indent

---
 daemons/dmeventd/libdevmapper-event.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 1e723d7..8775449 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -553,8 +553,8 @@ static struct dm_task *_get_device_info(const struct dm_event_handler *dmevh)
 
 	if (!info.exists) {
 		log_error("_get_device_info: %s%s%s%.0d%s%.0d%s%s: device not found",
-			  dmevh->uuid ? : "", 
-			  (!dmevh->uuid && dmevh->dev_name) ? dmevh->dev_name : "", 
+			  dmevh->uuid ? : "",
+			  (!dmevh->uuid && dmevh->dev_name) ? dmevh->dev_name : "",
 			  (!dmevh->uuid && !dmevh->dev_name && dmevh->major > 0) ? "(" : "",
 			  (!dmevh->uuid && !dmevh->dev_name && dmevh->major > 0) ? dmevh->major : 0,
 			  (!dmevh->uuid && !dmevh->dev_name && dmevh->major > 0) ? ":" : "",
@@ -564,7 +564,6 @@ static struct dm_task *_get_device_info(const struct dm_event_handler *dmevh)
 		goto bad;
 	}
 
-		  
 	return dmt;
 
       bad:


