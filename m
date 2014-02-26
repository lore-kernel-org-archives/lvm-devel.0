From: dongmao zhang <dmzhang@suse.com>
Date: Wed, 26 Feb 2014 19:20:00 +0800
Subject: [PATCH] decrease expected_replies when remote node is down [V2]
Message-ID: <1393413600-14942-1-git-send-email-dmzhang@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

dear list,
I think the last patch is broken, because 
it has line:thisfd->bits.localsock.finished = 0
which may cause pre_post_thread ends.
This is the revised patch. So any comments?

>when clvmd is waiting for remote node's relies, but
>the remote node could be possiblly closed at the same
>time. This could result in a request timeout in mainloop.
>The default timeout is 60 seconds. This is still too large.
>
>https://bugzilla.novell.com/show_bug.cgi?id=837538
>https://bugzilla.novell.com/show_bug.cgi?id=862633
>clvmd users usually meet this when they call LVM command(like vgscan)
>in one node, while other nodes's clvmd is closing.
>
>My solution to this is to decrement in-flight request's
>expected_replies. The command could finish much faster in this
>situation.
---
 daemons/clvmd/clvmd-corosync.c |    7 ++++-
 daemons/clvmd/clvmd.c          |   52 +++++++++++++++++++++++++++++++++++++++-
 daemons/clvmd/clvmd.h          |    2 +
 3 files changed, 59 insertions(+), 2 deletions(-)

diff --git a/daemons/clvmd/clvmd-corosync.c b/daemons/clvmd/clvmd-corosync.c
index e68cb73..8e642ca 100644
--- a/daemons/clvmd/clvmd-corosync.c
+++ b/daemons/clvmd/clvmd-corosync.c
@@ -251,11 +251,16 @@ static void corosync_cpg_confchg_callback(cpg_handle_t handle,
 		ninfo = dm_hash_lookup_binary(node_hash,
 					      (char *)&left_list[i].nodeid,
 					      COROSYNC_CSID_LEN);
-		if (ninfo)
+		if (ninfo) {
 			ninfo->state = NODE_DOWN;
+			char name[MAX_CLUSTER_MEMBER_NAME_LEN];
+			sprintf(name, "%x", ninfo->nodeid);
+			decrease_inflight_expected_reply(name);
+		}
 	}
 
 	num_nodes = member_list_entries;
+
 }
 
 static int _init_cluster(void)
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index fc8cf6e..bd056f2 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1697,6 +1697,56 @@ static void process_remote_command(struct clvm_header *msg, int msglen, int fd,
 	free(replyargs);
 }
 
+void decrease_inflight_expected_reply(char *nodename)
+{
+	struct local_client * thisfd;
+	struct node_reply *reply;
+
+	DEBUGLOG("remote node %s down", nodename);
+
+	for (thisfd = &local_client_head; thisfd != NULL;
+	     thisfd = thisfd->next) {
+		/* in-flight request */
+		if (thisfd->type == LOCAL_SOCK
+		    && thisfd->bits.localsock.sent_out
+		    && thisfd->bits.localsock.in_progress
+		    && ! thisfd->bits.localsock.finished
+		    && thisfd->bits.localsock.expected_replies >
+		    thisfd->bits.localsock.num_replies) {
+
+			pthread_mutex_lock(&thisfd->bits.localsock.reply_mutex);
+
+			reply = thisfd->bits.localsock.replies;
+			while (reply && strcmp(reply->node, nodename) != 0) {
+				reply = reply->next;
+			}
+			/* if the remote down server has replies,do not decrease the expected_replies */
+			if (reply)
+				continue;
+
+			thisfd->bits.localsock.expected_replies--;
+			DEBUGLOG
+			    ("remote node down, decrement the expected replies to (%ld),num_replies(%ld)",
+			     thisfd->bits.localsock.expected_replies,
+			     thisfd->bits.localsock.num_replies)
+
+			if (thisfd->bits.localsock.expected_replies <= thisfd->bits.localsock.num_replies) {
+				/* tell pre_and_post thread to finish */
+				if (thisfd->bits.localsock.threadid) {
+					thisfd->bits.localsock.all_success = 0;
+					pthread_mutex_lock(&thisfd->bits.localsock.mutex);
+					thisfd->bits.localsock.state = POST_COMMAND;
+					pthread_cond_signal(&thisfd->bits.localsock.cond);
+					pthread_mutex_unlock(&thisfd->bits.localsock.mutex);
+				}
+			}
+			pthread_mutex_unlock(&thisfd->bits.localsock.reply_mutex);
+
+		}
+	}
+
+}
+
 /* Add a reply to a command to the list of replies for this client.
    If we have got a full set then send them to the waiting client down the local
    socket */
@@ -1738,7 +1788,7 @@ static void add_reply_to_list(struct local_client *client, int status,
 		 client->bits.localsock.expected_replies);
 
 	/* If we have the whole lot then do the post-process */
-	if (++client->bits.localsock.num_replies ==
+	if (++client->bits.localsock.num_replies >=
 	    client->bits.localsock.expected_replies) {
 		/* Post-process the command */
 		if (client->bits.localsock.threadid) {
diff --git a/daemons/clvmd/clvmd.h b/daemons/clvmd/clvmd.h
index 0f837dd..52e4e61 100644
--- a/daemons/clvmd/clvmd.h
+++ b/daemons/clvmd/clvmd.h
@@ -112,6 +112,8 @@ extern int do_post_command(struct local_client *client);
 extern void cmd_client_cleanup(struct local_client *client);
 extern int add_client(struct local_client *new_client);
 
+
+extern void decrease_inflight_expected_reply();
 extern void clvmd_cluster_init_completed(void);
 extern void process_message(struct local_client *client, char *buf,
 			    int len, const char *csid);
-- 
1.7.3.4


