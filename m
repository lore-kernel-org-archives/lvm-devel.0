From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 21 Dec 2010 16:41:38 +0100
Subject: [PATCH 06/23] Log of pthread_join operation
In-Reply-To: <cover.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
Message-ID: <430a5babe48297b2305a3a67a0e0e013f86408de.1292945707.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Value jstat is unused - so replace it with logging via log_sys_error().

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvmd.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index a6839f4..7bb28a3 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -666,7 +666,6 @@ static int local_pipe_callback(struct local_client *thisfd, char *buf,
 
 	/* EOF on pipe or an error, close it */
 	if (len <= 0) {
-		int jstat;
 		void *ret = &status;
 		close(thisfd->fd);
 
@@ -677,7 +676,9 @@ static int local_pipe_callback(struct local_client *thisfd, char *buf,
 
 		/* Reap child thread */
 		if (thisfd->bits.pipe.threadid) {
-			jstat = pthread_join(thisfd->bits.pipe.threadid, &ret);
+			if (pthread_join(thisfd->bits.pipe.threadid, &ret))
+				log_sys_error("pthread_join", "");
+
 			thisfd->bits.pipe.threadid = 0;
 			if (thisfd->bits.pipe.client != NULL)
 				thisfd->bits.pipe.client->bits.localsock.
@@ -1039,7 +1040,6 @@ static int read_from_local_sock(struct local_client *thisfd)
 	/* EOF or error on socket */
 	if (len <= 0) {
 		int *status;
-		int jstat;
 
 		DEBUGLOG("EOF on local socket: inprogress=%d\n",
 			 thisfd->bits.localsock.in_progress);
@@ -1066,9 +1066,10 @@ static int read_from_local_sock(struct local_client *thisfd)
 			pthread_cond_signal(&thisfd->bits.localsock.cond);
 			pthread_mutex_unlock(&thisfd->bits.localsock.mutex);
 
-			jstat =
-			    pthread_join(thisfd->bits.localsock.threadid,
-					 (void **) &status);
+			if (pthread_join(thisfd->bits.localsock.threadid,
+					 (void **) &status))
+				log_sys_error("pthread_join", "");
+
 			DEBUGLOG("Joined child thread\n");
 
 			thisfd->bits.localsock.threadid = 0;
-- 
1.7.3.4


