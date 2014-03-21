From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:31:42 +0000 (UTC)
Subject: master - clvmd: update add_reply_to_list
Message-ID: <20140321213142.41A4C60F20@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=37396e2fe5c451c466f93f852a3559da023fc98c
Commit:        37396e2fe5c451c466f93f852a3559da023fc98c
Parent:        28479946249611f7f103c1caa33033a92ea0ce49
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 20 14:29:42 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:24 2014 +0100

clvmd: update add_reply_to_list

Take mutex lock after the allocation just before
the structure is merged into reply list.
---
 daemons/clvmd/clvmd.c |   39 ++++++++++++++++++---------------------
 1 files changed, 18 insertions(+), 21 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index ba3fc84..c3268a7 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1675,32 +1675,29 @@ static void add_reply_to_list(struct local_client *client, int status,
 {
 	struct node_reply *reply;
 
-	pthread_mutex_lock(&client->bits.localsock.reply_mutex);
-
 	/* Add it to the list of replies */
-	if ((reply = dm_malloc(sizeof(*reply)))) {
-		reply->status = status;
-		clops->name_from_csid(csid, reply->node);
-		DEBUGLOG("Reply from node %s: %d bytes\n", reply->node, len);
-
-		if (len > 0) {
-			if (!(reply->replymsg = dm_malloc(len)))
-				reply->status = ENOMEM;
-			else {
-				memcpy(reply->replymsg, buf, len);
-			}
-		} else {
-			reply->replymsg = NULL;
-		}
-		/* Hook it onto the reply chain */
-		reply->next = client->bits.localsock.replies;
-		client->bits.localsock.replies = reply;
-	} else {
+	if (!(reply = dm_zalloc(sizeof(*reply)))) {
 		/* It's all gone horribly wrong... */
-		pthread_mutex_unlock(&client->bits.localsock.reply_mutex);
 		send_local_reply(client, ENOMEM, client->fd);
 		return;
 	}
+
+	reply->status = status;
+	clops->name_from_csid(csid, reply->node);
+	DEBUGLOG("Reply from node %s: %d bytes\n", reply->node, len);
+
+	if (len > 0) {
+		if (!(reply->replymsg = dm_malloc(len)))
+			reply->status = ENOMEM;
+		else
+			memcpy(reply->replymsg, buf, len);
+	} else
+		reply->replymsg = NULL;
+
+	pthread_mutex_lock(&client->bits.localsock.reply_mutex);
+	/* Hook it onto the reply chain */
+	reply->next = client->bits.localsock.replies;
+	client->bits.localsock.replies = reply;
 	DEBUGLOG("Got %d replies, expecting: %d\n",
 		 client->bits.localsock.num_replies + 1,
 		 client->bits.localsock.expected_replies);


