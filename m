From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:32:07 +0000 (UTC)
Subject: master - cleanup: clvmd zombie removal loop
Message-ID: <20140321213207.3B5E860F05@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9196274c1efb16731ec4ce53adb46366411b7c14
Commit:        9196274c1efb16731ec4ce53adb46366411b7c14
Parent:        5740c00f3b6160147a5bb72217dae9ce5359a525
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 21 12:56:35 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:27 2014 +0100

cleanup: clvmd zombie removal loop

Simplier code to start scan from the next node,
and remove matching pipe client.
---
 daemons/clvmd/clvmd.c |   23 +++++++----------------
 1 files changed, 7 insertions(+), 16 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 3d7d072..9e58fd0 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1179,29 +1179,20 @@ static int cleanup_zombie(struct local_client *thisfd)
 
 		/* Remove the pipe client */
 		if (thisfd->bits.localsock.pipe_client) {
-			struct local_client *newfd;
-			struct local_client *lastfd = NULL;
-			struct local_client *free_fd = NULL;
+			struct local_client *delfd;
+			struct local_client *lastfd;
 
 			(void) close(thisfd->bits.localsock.pipe_client->fd);	/* Close pipe */
 			(void) close(thisfd->bits.localsock.pipe);
 
 			/* Remove pipe client */
-			for (newfd = &local_client_head; newfd != NULL;
-			     newfd = newfd->next) {
-				if (thisfd->bits.localsock.
-				    pipe_client == newfd) {
-					thisfd->bits.localsock.
-					    pipe_client = NULL;
-
-					lastfd->next = newfd->next;
-					free_fd = newfd;
-					newfd->next = lastfd;
-					dm_free(free_fd);
+			for (lastfd = &local_client_head; (delfd = lastfd->next); lastfd = delfd)
+				if (thisfd->bits.localsock.pipe_client == delfd) {
+					thisfd->bits.localsock.pipe_client = NULL;
+					lastfd->next = delfd->next;
+					dm_free(delfd);
 					break;
 				}
-				lastfd = newfd;
-			}
 		}
 	}
 


