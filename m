From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 14 Apr 2014 11:06:18 +0000 (UTC)
Subject: master - clvmd: skip adding reply when finished
Message-ID: <20140414110618.2D01560CDC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=639983b6b7ac3257fc305624f22325fd3f6f0261
Commit:        639983b6b7ac3257fc305624f22325fd3f6f0261
Parent:        7236b92857cb8a0207376d1349e42ba26172a519
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 14 12:40:23 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 14 13:01:42 2014 +0200

clvmd: skip adding reply when finished

Prior adding new reply to the list, check
if the reply thread is not already finished.
In that case discard adding message
(which would otherwise be leaked).
---
 WHATS_NEW             |    1 +
 daemons/clvmd/clvmd.c |   26 +++++++++++++++-----------
 2 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a90906e..efc296d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Skip adding replies to already finished reply thread.
   Use mutex to check number of replies in request_timed_out() in clvmd.
   Drop usage of extra reply_mutex for localsock in clvmd.
   Protect manipulation with finished flag with mutex in clvmd. 
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index ec24be9..ee6e301 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1636,21 +1636,25 @@ static void add_reply_to_list(struct local_client *client, int status,
 		reply->replymsg = NULL;
 
 	pthread_mutex_lock(&client->bits.localsock.mutex);
-	/* Hook it onto the reply chain */
-	reply->next = client->bits.localsock.replies;
-	client->bits.localsock.replies = reply;
-	DEBUGLOG("Got %d replies, expecting: %d\n",
-		 client->bits.localsock.num_replies + 1,
-		 client->bits.localsock.expected_replies);
-
-	/* If we have the whole lot then do the post-process */
-	if (++client->bits.localsock.num_replies ==
-	    client->bits.localsock.expected_replies) {
+
+	if (client->bits.localsock.finished) {
+		dm_free(reply->replymsg);
+		dm_free(reply);
+	} else {
+		/* Hook it onto the reply chain */
+		reply->next = client->bits.localsock.replies;
+		client->bits.localsock.replies = reply;
+
+		/* If we have the whole lot then do the post-process */
 		/* Post-process the command */
-		if (client->bits.localsock.threadid) {
+		if (++client->bits.localsock.num_replies ==
+		    client->bits.localsock.expected_replies) {
 			client->bits.localsock.state = POST_COMMAND;
 			pthread_cond_signal(&client->bits.localsock.cond);
 		}
+		DEBUGLOG("Got %d replies, expecting: %d\n",
+			 client->bits.localsock.num_replies,
+			 client->bits.localsock.expected_replies);
 	}
 	pthread_mutex_unlock(&client->bits.localsock.mutex);
 }


