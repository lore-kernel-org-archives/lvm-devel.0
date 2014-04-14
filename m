From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 14 Apr 2014 11:06:09 +0000 (UTC)
Subject: master - clvmd: move mutex init and detroy
Message-ID: <20140414110609.B7256609E2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cc0096ebdd1168ebb0d482e88952bdc14caffd96
Commit:        cc0096ebdd1168ebb0d482e88952bdc14caffd96
Parent:        91f4e09b48a2e9f909f3686c8d3a9dba274d1779
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 9 08:06:16 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 14 12:57:39 2014 +0200

clvmd: move mutex init and detroy

Move the pthread mutex and condition creation and destroy
to correct place right after client memory is allocatedd
or is going to be released.

In the original place it's been in race with lvm thread
which could have still unlock mutex while it's been already
destroyed.
---
 WHATS_NEW             |    1 +
 daemons/clvmd/clvmd.c |   19 +++++++------------
 2 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9c42344..16e39dc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Shift mutex creation and destroy for localsock in clvmd to correct place.
   Fix usage of --test option in clvmd.
   Skip more libraries to be mlocked in memory.
   Remove LOCKED flag for pvmove replaced with error target.
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 0ad0c3a..93c2224 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -685,6 +685,10 @@ static int local_rendezvous_callback(struct local_client *thisfd, char *buf,
 			return 1;
 		}
 
+		pthread_cond_init(&newfd->bits.localsock.cond, NULL);
+		pthread_mutex_init(&newfd->bits.localsock.mutex, NULL);
+		pthread_mutex_init(&newfd->bits.localsock.reply_mutex, NULL);
+
 		if (fcntl(client_fd, F_SETFD, 1))
 			DEBUGLOG("Setting CLOEXEC on client fd failed: %s\n", strerror(errno));
 
@@ -1179,8 +1183,6 @@ static int cleanup_zombie(struct local_client *thisfd)
 		DEBUGLOG("Joined pre&post thread\n");
 
 		thisfd->bits.localsock.threadid = 0;
-		pthread_cond_destroy(&thisfd->bits.localsock.cond);
-		pthread_mutex_destroy(&thisfd->bits.localsock.mutex);
 
 		/* Remove the pipe client */
 		if (thisfd->bits.localsock.pipe_client) {
@@ -1321,16 +1323,6 @@ static int read_from_local_sock(struct local_client *thisfd)
 		}
 	}
 
-	/*
-	 * Initialise and lock the mutex so the subthread will wait
-	 * after finishing the PRE routine
-	 */
-	if (!thisfd->bits.localsock.threadid) {
-		pthread_mutex_init(&thisfd->bits.localsock.mutex, NULL);
-		pthread_cond_init(&thisfd->bits.localsock.cond, NULL);
-		pthread_mutex_init(&thisfd->bits.localsock.reply_mutex, NULL);
-	}
-
 	/* Only run the command if all the cluster nodes are running CLVMD */
 	if (((inheader->flags & CLVMD_FLAG_LOCAL) == 0) &&
 	    (check_all_clvmds_running(thisfd) == -1)) {
@@ -1975,6 +1967,9 @@ static int process_work_item(struct lvm_thread_cmd *cmd)
 	if (cmd->msg == NULL) {
 		DEBUGLOG("process_work_item: free fd %d\n", cmd->client->fd);
 		cmd_client_cleanup(cmd->client);
+		pthread_mutex_destroy(&cmd->client->bits.localsock.reply_mutex);
+		pthread_mutex_destroy(&cmd->client->bits.localsock.mutex);
+		pthread_cond_destroy(&cmd->client->bits.localsock.cond);
 		dm_free(cmd->client);
 		return 0;
 	}


