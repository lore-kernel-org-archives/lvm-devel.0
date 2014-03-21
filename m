From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:31:46 +0000 (UTC)
Subject: master - clvmd: drop dead code
Message-ID: <20140321213146.6FCE3610FC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7041c8bf51844c314fd4ed3b5f20779959524320
Commit:        7041c8bf51844c314fd4ed3b5f20779959524320
Parent:        73978f8d7dd638806f514a7914884a204afd95c1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 21 16:50:45 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:24 2014 +0100

clvmd: drop dead code

Since pipe_client has been already reset to NULL,
remove this dead code.
---
 daemons/clvmd/clvmd.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 572c5b7..dd3548f 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1223,11 +1223,6 @@ static int cleanup_zombie(struct local_client *thisfd)
 	/* Free the command buffer */
 	dm_free(thisfd->bits.localsock.cmd);
 
-	/* Clear out the cross-link */
-	if (thisfd->bits.localsock.pipe_client != NULL)
-		thisfd->bits.localsock.pipe_client->bits.pipe.client =
-		    NULL;
-
 	safe_close(&(thisfd->fd));
 	thisfd->bits.localsock.cleanup_needed = 0;
 	return 0;


