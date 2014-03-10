From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Mar 2014 11:27:11 +0000 (UTC)
Subject: master - cleanup: clvmd assign NULL to pointers
Message-ID: <20140310112711.00ECA603FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2cfe0840d2e33fd8aa1892aaf73498fac68040af
Commit:        2cfe0840d2e33fd8aa1892aaf73498fac68040af
Parent:        c824369fbdd93011a1daccbb7159d16f365dce50
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 10 12:16:09 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 10 12:24:09 2014 +0100

cleanup: clvmd assign NULL to pointers

Use NULL when assigning to void*.
---
 daemons/clvmd/clvmd-command.c |    7 +++----
 daemons/clvmd/clvmd.c         |    7 +++----
 2 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index 96eec92..611f6bf 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -307,9 +307,8 @@ int do_post_command(struct local_client *client)
 	init_test(0);
 	switch (header->cmd) {
 	case CLVMD_CMD_TEST:
-		status =
-		    sync_unlock("CLVMD_TEST", (int) (long) client->bits.localsock.private);
-		client->bits.localsock.private = 0;
+		status = sync_unlock("CLVMD_TEST", (int) (long) client->bits.localsock.private);
+		client->bits.localsock.private = NULL;
 		break;
 
 	case CLVMD_CMD_LOCK_LV:
@@ -350,7 +349,7 @@ void cmd_client_cleanup(struct local_client *client)
 	}
 
 	dm_hash_destroy(lock_hash);
-	client->bits.localsock.private = 0;
+	client->bits.localsock.private = NULL;
 }
 
 
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index c319013..0a8d591 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -724,9 +724,8 @@ static int local_pipe_callback(struct local_client *thisfd, char *buf,
 			log_sys_error("close", "local_pipe");
 
 		/* Clear out the cross-link */
-		if (thisfd->bits.pipe.client != NULL)
-			thisfd->bits.pipe.client->bits.localsock.pipe_client =
-			    NULL;
+		if (thisfd->bits.pipe.client)
+			thisfd->bits.pipe.client->bits.localsock.pipe_client = NULL;
 
 		/* Reap child thread */
 		if (thisfd->bits.pipe.threadid) {
@@ -1811,7 +1810,7 @@ next_pre:
 	}
 	pthread_mutex_unlock(&client->bits.localsock.mutex);
 	DEBUGLOG("Subthread finished\n");
-	pthread_exit((void *) 0);
+	pthread_exit(NULL);
 }
 
 /* Process a command on the local node and store the result */


