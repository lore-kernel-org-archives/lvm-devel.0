From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 14 Apr 2014 11:06:16 +0000 (UTC)
Subject: master - clvmd: improve mutex usage in request_timed_out
Message-ID: <20140414110616.154C760CDC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7236b92857cb8a0207376d1349e42ba26172a519
Commit:        7236b92857cb8a0207376d1349e42ba26172a519
Parent:        7075656034858e8f825635c8e8a6a0e5122924ae
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 14 11:39:24 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 14 13:00:51 2014 +0200

clvmd: improve mutex usage in request_timed_out

Use mutex to access localsock values, so check
num_replies when the thread is not yet finished.

Check for threadid prior the mutex taking
(though this check is probably not really needed)
---
 WHATS_NEW             |    1 +
 daemons/clvmd/clvmd.c |   20 ++++++++++++--------
 2 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 19ee0a7..a90906e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Use mutex to check number of replies in request_timed_out() in clvmd.
   Drop usage of extra reply_mutex for localsock in clvmd.
   Protect manipulation with finished flag with mutex in clvmd. 
   Shift mutex creation and destroy for localsock in clvmd to correct place.
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index b70543b..ec24be9 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -812,16 +812,20 @@ static void request_timed_out(struct local_client *client)
 	DEBUGLOG("Request timed-out. padding\n");
 	clops->cluster_do_node_callback(client, timedout_callback);
 
-	if (client->bits.localsock.num_replies !=
-	    client->bits.localsock.expected_replies) {
+	if (!client->bits.localsock.threadid)
+		return;
+
+	pthread_mutex_lock(&client->bits.localsock.mutex);
+
+	if (!client->bits.localsock.finished &&
+	    (client->bits.localsock.num_replies !=
+	     client->bits.localsock.expected_replies)) {
 		/* Post-process the command */
-		if (client->bits.localsock.threadid) {
-			pthread_mutex_lock(&client->bits.localsock.mutex);
-			client->bits.localsock.state = POST_COMMAND;
-			pthread_cond_signal(&client->bits.localsock.cond);
-			pthread_mutex_unlock(&client->bits.localsock.mutex);
-		}
+		client->bits.localsock.state = POST_COMMAND;
+		pthread_cond_signal(&client->bits.localsock.cond);
 	}
+
+	pthread_mutex_unlock(&client->bits.localsock.mutex);
 }
 
 /* This is where the real work happens */


