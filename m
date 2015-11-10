From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 10 Nov 2015 20:42:04 +0000 (UTC)
Subject: master - raid: fix the string compare
Message-ID: <20151110204204.DE4CE603A0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a45cc0fe1460168f2e193c210aabaa1292fe0ea3
Commit:        a45cc0fe1460168f2e193c210aabaa1292fe0ea3
Parent:        59905100d1326bc651a3b5991fdaed563abcf41e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 10 21:32:46 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 10 21:40:28 2015 +0100

raid: fix the string compare

Coverity noticed this condition is always false and the error
path could never be visited.

So check for all mismatches of supported messages
and actually mark log_error as internal error.
---
 lib/activate/dev_manager.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 0b24f86..fd4d842 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1410,14 +1410,14 @@ int dev_manager_raid_message(struct dev_manager *dm,
 	}
 
 	/* These are the supported RAID messages for dm-raid v1.5.0 */
-	if (!strcmp(msg, "idle") &&
-	    !strcmp(msg, "frozen") &&
-	    !strcmp(msg, "resync") &&
-	    !strcmp(msg, "recover") &&
-	    !strcmp(msg, "check") &&
-	    !strcmp(msg, "repair") &&
-	    !strcmp(msg, "reshape")) {
-		log_error("Unknown RAID message: %s", msg);
+	if (strcmp(msg, "idle") &&
+	    strcmp(msg, "frozen") &&
+	    strcmp(msg, "resync") &&
+	    strcmp(msg, "recover") &&
+	    strcmp(msg, "check") &&
+	    strcmp(msg, "repair") &&
+	    strcmp(msg, "reshape")) {
+		log_error(INTERNAL_ERROR "Unknown RAID message: %s", msg);
 		return 0;
 	}
 


