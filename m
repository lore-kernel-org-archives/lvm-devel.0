From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 14 Apr 2014 11:06:11 +0000 (UTC)
Subject: master - clvmd: set finished flag with mutex
Message-ID: <20140414110611.DB43D609E2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6115c0d112a181012775af4528e5757ec39072ad
Commit:        6115c0d112a181012775af4528e5757ec39072ad
Parent:        cc0096ebdd1168ebb0d482e88952bdc14caffd96
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 9 10:36:25 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 14 12:58:28 2014 +0200

clvmd: set finished flag with mutex

Setting this variable needs to be protected with mutex.
---
 WHATS_NEW             |    1 +
 daemons/clvmd/clvmd.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 16e39dc..ee6fccd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Protect manipulation with finished flag with mutex in clvmd. 
   Shift mutex creation and destroy for localsock in clvmd to correct place.
   Fix usage of --test option in clvmd.
   Skip more libraries to be mlocked in memory.
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 93c2224..6c186e8 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1149,8 +1149,6 @@ static int cleanup_zombie(struct local_client *thisfd)
 	DEBUGLOG("EOF on local socket: inprogress=%d\n",
 		 thisfd->bits.localsock.in_progress);
 
-	thisfd->bits.localsock.finished = 1;
-
 	if ((pipe_client = thisfd->bits.localsock.pipe_client))
 		pipe_client = pipe_client->bits.pipe.client;
 
@@ -1161,6 +1159,7 @@ static int cleanup_zombie(struct local_client *thisfd)
 		if (pthread_mutex_trylock(&thisfd->bits.localsock.mutex))
 			return 1;
 		thisfd->bits.localsock.state = POST_COMMAND;
+		thisfd->bits.localsock.finished = 1;
 		pthread_cond_signal(&thisfd->bits.localsock.cond);
 		pthread_mutex_unlock(&thisfd->bits.localsock.mutex);
 
@@ -1173,6 +1172,7 @@ static int cleanup_zombie(struct local_client *thisfd)
 		DEBUGLOG("Waiting for pre&post thread (%p)\n", pipe_client);
 		pthread_mutex_lock(&thisfd->bits.localsock.mutex);
 		thisfd->bits.localsock.state = PRE_COMMAND;
+		thisfd->bits.localsock.finished = 1;
 		pthread_cond_signal(&thisfd->bits.localsock.cond);
 		pthread_mutex_unlock(&thisfd->bits.localsock.mutex);
 


