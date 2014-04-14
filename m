From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 14 Apr 2014 11:06:22 +0000 (UTC)
Subject: master - cleanup: clvmd reindent local_pipe_callback
Message-ID: <20140414110622.7C33D60CDC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e2f194952a218562b198c47e78f7337572cfb29e
Commit:        e2f194952a218562b198c47e78f7337572cfb29e
Parent:        eccc50d86199921e8f2e0cf349db96e517b2625d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 10 22:10:37 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 14 13:02:27 2014 +0200

cleanup: clvmd reindent local_pipe_callback

Move !node_up check in front and reindent
rest of the function to the left.
---
 daemons/clvmd/clvmd.c |   31 ++++++++++++++++---------------
 1 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index b1fe396..3e92490 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -779,25 +779,26 @@ static int local_pipe_callback(struct local_client *thisfd, char *buf,
 static void timedout_callback(struct local_client *client, const char *csid,
 			      int node_up)
 {
-	if (node_up) {
-		struct node_reply *reply;
-		char nodename[max_cluster_member_name_len];
+	struct node_reply *reply;
+	char nodename[max_cluster_member_name_len];
 
-		clops->name_from_csid(csid, nodename);
-		DEBUGLOG("Checking for a reply from %s\n", nodename);
-		pthread_mutex_lock(&client->bits.localsock.mutex);
+	if (!node_up)
+		return;
 
-		reply = client->bits.localsock.replies;
-		while (reply && strcmp(reply->node, nodename) != 0)
-			reply = reply->next;
+	clops->name_from_csid(csid, nodename);
+	DEBUGLOG("Checking for a reply from %s\n", nodename);
+	pthread_mutex_lock(&client->bits.localsock.mutex);
 
-		pthread_mutex_unlock(&client->bits.localsock.mutex);
+	reply = client->bits.localsock.replies;
+	while (reply && strcmp(reply->node, nodename) != 0)
+		reply = reply->next;
 
-		if (!reply) {
-			DEBUGLOG("Node %s timed-out\n", nodename);
-			add_reply_to_list(client, ETIMEDOUT, csid,
-					  "Command timed out", 18);
-		}
+	pthread_mutex_unlock(&client->bits.localsock.mutex);
+
+	if (!reply) {
+		DEBUGLOG("Node %s timed-out\n", nodename);
+		add_reply_to_list(client, ETIMEDOUT, csid,
+				  "Command timed out", 18);
 	}
 }
 


