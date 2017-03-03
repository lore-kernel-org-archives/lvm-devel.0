From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 3 Mar 2017 16:10:46 -0500
Subject: master - dev_manager: remove reshape message
Message-ID: <201703032110.v23LAkWG015662@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=547bdb63e1757288586ea5b74b228f35bb8d2af2
Commit:        547bdb63e1757288586ea5b74b228f35bb8d2af2
Parent:        9a50df291a616e4fe2b0f569b41ac3b2b7d08a33
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 3 22:10:21 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 3 22:10:21 2017 +0100

dev_manager: remove reshape message

The dm-raid target doesn't support a "reshape" message.
---
 lib/activate/dev_manager.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 49d9ad3..a2e399d 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1316,14 +1316,13 @@ int dev_manager_raid_message(struct dev_manager *dm,
 		return 0;
 	}
 
-	/* These are the supported RAID messages for dm-raid v1.5.0 */
+	/* These are the supported RAID messages for dm-raid v1.9.0 */
 	if (strcmp(msg, "idle") &&
 	    strcmp(msg, "frozen") &&
 	    strcmp(msg, "resync") &&
 	    strcmp(msg, "recover") &&
 	    strcmp(msg, "check") &&
-	    strcmp(msg, "repair") &&
-	    strcmp(msg, "reshape")) {
+	    strcmp(msg, "repair")) {
 		log_error(INTERNAL_ERROR "Unknown RAID message: %s.", msg);
 		return 0;
 	}


