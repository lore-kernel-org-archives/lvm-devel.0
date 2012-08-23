From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:42:50 +0000 (UTC)
Subject: master - cleanup: add error message and simplify creation
Message-ID: <20120823124250.2181FA0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=15891d366d34fa6ea7235ec803ee0c5445a17101
Commit:        15891d366d34fa6ea7235ec803ee0c5445a17101
Parent:        195fe0307526ffc8307842618a7eeb4a421cacf9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 20 10:35:24 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:37:38 2012 +0200

cleanup: add error message and simplify creation

Report error for malloc failure, and use zeroed allocation
to initialize handler structure.
---
 daemons/dmeventd/libdevmapper-event.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 386a4fa..1f8fbef 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -59,14 +59,10 @@ struct dm_event_handler *dm_event_handler_create(void)
 {
 	struct dm_event_handler *dmevh = NULL;
 
-	if (!(dmevh = dm_malloc(sizeof(*dmevh))))
+	if (!(dmevh = dm_zalloc(sizeof(*dmevh)))) {
+		log_error("Failed to allocate event handler.");
 		return NULL;
-
-	dmevh->dmeventd_path = NULL;
-	dmevh->dso = dmevh->dev_name = dmevh->uuid = NULL;
-	dmevh->major = dmevh->minor = 0;
-	dmevh->mask = 0;
-	dmevh->timeout = 0;
+	}
 
 	return dmevh;
 }


