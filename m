From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 14 Apr 2014 11:06:14 +0000 (UTC)
Subject: master - clvmd: drop reply_mutex
Message-ID: <20140414110614.01EEB609E2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7075656034858e8f825635c8e8a6a0e5122924ae
Commit:        7075656034858e8f825635c8e8a6a0e5122924ae
Parent:        6115c0d112a181012775af4528e5757ec39072ad
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 9 08:12:13 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 14 12:59:07 2014 +0200

clvmd: drop reply_mutex

Added complexity with extra reply mutex is not worth the troubles.
The only place which may slightly benefit from this mutex is timeout
and since this is rather error case - let's convert it to
localsock.mutex and keep it simple.
---
 WHATS_NEW             |    1 +
 daemons/clvmd/clvmd.c |   12 ++++--------
 daemons/clvmd/clvmd.h |    2 --
 3 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ee6fccd..19ee0a7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Drop usage of extra reply_mutex for localsock in clvmd.
   Protect manipulation with finished flag with mutex in clvmd. 
   Shift mutex creation and destroy for localsock in clvmd to correct place.
   Fix usage of --test option in clvmd.
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 6c186e8..b70543b 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -687,7 +687,6 @@ static int local_rendezvous_callback(struct local_client *thisfd, char *buf,
 
 		pthread_cond_init(&newfd->bits.localsock.cond, NULL);
 		pthread_mutex_init(&newfd->bits.localsock.mutex, NULL);
-		pthread_mutex_init(&newfd->bits.localsock.reply_mutex, NULL);
 
 		if (fcntl(client_fd, F_SETFD, 1))
 			DEBUGLOG("Setting CLOEXEC on client fd failed: %s\n", strerror(errno));
@@ -785,13 +784,13 @@ static void timedout_callback(struct local_client *client, const char *csid,
 
 		clops->name_from_csid(csid, nodename);
 		DEBUGLOG("Checking for a reply from %s\n", nodename);
-		pthread_mutex_lock(&client->bits.localsock.reply_mutex);
+		pthread_mutex_lock(&client->bits.localsock.mutex);
 
 		reply = client->bits.localsock.replies;
 		while (reply && strcmp(reply->node, nodename) != 0)
 			reply = reply->next;
 
-		pthread_mutex_unlock(&client->bits.localsock.reply_mutex);
+		pthread_mutex_unlock(&client->bits.localsock.mutex);
 
 		if (!reply) {
 			DEBUGLOG("Node %s timed-out\n", nodename);
@@ -1632,7 +1631,7 @@ static void add_reply_to_list(struct local_client *client, int status,
 	} else
 		reply->replymsg = NULL;
 
-	pthread_mutex_lock(&client->bits.localsock.reply_mutex);
+	pthread_mutex_lock(&client->bits.localsock.mutex);
 	/* Hook it onto the reply chain */
 	reply->next = client->bits.localsock.replies;
 	client->bits.localsock.replies = reply;
@@ -1645,13 +1644,11 @@ static void add_reply_to_list(struct local_client *client, int status,
 	    client->bits.localsock.expected_replies) {
 		/* Post-process the command */
 		if (client->bits.localsock.threadid) {
-			pthread_mutex_lock(&client->bits.localsock.mutex);
 			client->bits.localsock.state = POST_COMMAND;
 			pthread_cond_signal(&client->bits.localsock.cond);
-			pthread_mutex_unlock(&client->bits.localsock.mutex);
 		}
 	}
-	pthread_mutex_unlock(&client->bits.localsock.reply_mutex);
+	pthread_mutex_unlock(&client->bits.localsock.mutex);
 }
 
 /* This is the thread that runs the PRE and post commands for a particular connection */
@@ -1967,7 +1964,6 @@ static int process_work_item(struct lvm_thread_cmd *cmd)
 	if (cmd->msg == NULL) {
 		DEBUGLOG("process_work_item: free fd %d\n", cmd->client->fd);
 		cmd_client_cleanup(cmd->client);
-		pthread_mutex_destroy(&cmd->client->bits.localsock.reply_mutex);
 		pthread_mutex_destroy(&cmd->client->bits.localsock.mutex);
 		pthread_cond_destroy(&cmd->client->bits.localsock.cond);
 		dm_free(cmd->client);
diff --git a/daemons/clvmd/clvmd.h b/daemons/clvmd/clvmd.h
index 0f837dd..5ecf582 100644
--- a/daemons/clvmd/clvmd.h
+++ b/daemons/clvmd/clvmd.h
@@ -59,8 +59,6 @@ struct localsock_bits {
 	enum { PRE_COMMAND, POST_COMMAND, QUIT } state;
 	pthread_mutex_t mutex;	/* Main thread and worker synchronisation */
 	pthread_cond_t cond;
-
-	pthread_mutex_t reply_mutex;	/* Protect reply structure */
 };
 
 /* Entries for PIPE clients */


