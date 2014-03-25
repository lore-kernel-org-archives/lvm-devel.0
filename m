From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Mar 2014 10:23:32 +0000 (UTC)
Subject: master - clvmd: hardening leak on exit
Message-ID: <20140325102332.C246760F9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b522312678abaccd16b51299994e032d96a79267
Commit:        b522312678abaccd16b51299994e032d96a79267
Parent:        68d13b2517b49f53e395ea7754c6b8cf0b57dc0e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 25 10:50:36 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 25 11:22:57 2014 +0100

clvmd: hardening leak on exit

Operate with lvm_thread_exit while holding lvm_thread_mutex.
Don't leave unfinished work in the lvm thread queue
and always finish all queued tasks before exit,
so no cmd struct is left in the list.

(in-release fix)
---
 daemons/clvmd/clvmd.c |   23 +++++++++++++++--------
 1 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 4648450..bc98ccb 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -2020,11 +2020,8 @@ static void *lvm_thread_fn(void *arg)
 	/* Now wait for some actual work */
 	pthread_mutex_lock(&lvm_thread_mutex);
 
-	while (!lvm_thread_exit)
-		if (dm_list_empty(&lvm_cmd_head)) {
-			DEBUGLOG("LVM thread waiting for work\n");
-			pthread_cond_wait(&lvm_thread_cond, &lvm_thread_mutex);
-		} else {
+	for (;;) {
+		while (!dm_list_empty(&lvm_cmd_head)) {
 			cmd = dm_list_item(dm_list_first(&lvm_cmd_head),
 					   struct lvm_thread_cmd);
 			dm_list_del(&cmd->list);
@@ -2037,6 +2034,13 @@ static void *lvm_thread_fn(void *arg)
 			pthread_mutex_lock(&lvm_thread_mutex);
 		}
 
+		if  (lvm_thread_exit)
+			break;
+
+		DEBUGLOG("LVM thread waiting for work\n");
+		pthread_cond_wait(&lvm_thread_cond, &lvm_thread_mutex);
+	}
+
 	pthread_mutex_unlock(&lvm_thread_mutex);
 	DEBUGLOG("LVM thread exits\n");
 
@@ -2051,9 +2055,6 @@ static int add_to_lvmqueue(struct local_client *client, struct clvm_header *msg,
 {
 	struct lvm_thread_cmd *cmd;
 
-	if (lvm_thread_exit)
-		return -1; /* We are about to exit */
-
 	if (!(cmd = dm_malloc(sizeof(*cmd))))
 		return ENOMEM;
 
@@ -2081,6 +2082,12 @@ static int add_to_lvmqueue(struct local_client *client, struct clvm_header *msg,
 	DEBUGLOG("add_to_lvmqueue: cmd=%p. client=%p, msg=%p, len=%d, csid=%p, xid=%d\n",
 		 cmd, client, msg, msglen, csid, cmd->xid);
 	pthread_mutex_lock(&lvm_thread_mutex);
+	if (lvm_thread_exit) {
+		pthread_mutex_unlock(&lvm_thread_mutex);
+		dm_free(cmd->msg);
+		dm_free(cmd);
+		return -1; /* We are about to exit */
+	}
 	dm_list_add(&lvm_cmd_head, &cmd->list);
 	pthread_cond_signal(&lvm_thread_cond);
 	pthread_mutex_unlock(&lvm_thread_mutex);


