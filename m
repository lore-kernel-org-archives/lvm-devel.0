From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 21 Apr 2013 21:16:23 +0000 (UTC)
Subject: master - dmeventd: check for msg.data nonnull
Message-ID: <20130421211623.E61DE145A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=45f396f2a075054f4e047abdef5eafffca72a281
Commit:        45f396f2a075054f4e047abdef5eafffca72a281
Parent:        ba3cee36300d56efcdcb0af883141b1b0a6129a1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 19 17:03:50 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 22:56:59 2013 +0200

dmeventd: check for msg.data nonnull

Ensure we will not use  msg.data as NULL for strchr.
---
 daemons/dmeventd/libdevmapper-event.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 1f8fbef..f7b586e 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -815,13 +815,13 @@ int dm_event_get_version(struct dm_event_fifos *fifos, int *version) {
 	p = msg.data;
 	*version = 0;
 
-	p = strchr(p, ' '); /* Message ID */
-        if (!p) return 0;
-	p = strchr(p + 1, ' '); /* HELLO */
-        if (!p) return 0;
-	p = strchr(p + 1, ' '); /* HELLO, once more */
-	if (p)
+	if (!p || !(p = strchr(p, ' '))) /* Message ID */
+		return 0;
+	if (!(p = strchr(p + 1, ' '))) /* HELLO */
+		return 0;
+	if ((p = strchr(p + 1, ' '))) /* HELLO, once more */
 		*version = atoi(p);
+
 	return 1;
 }
 


