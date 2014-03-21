From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:31:56 +0000 (UTC)
Subject: master - cleanup: clvmd drop goto
Message-ID: <20140321213156.C8E1A60F05@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4c97ea2ce55134735896967e719db955c9e74161
Commit:        4c97ea2ce55134735896967e719db955c9e74161
Parent:        7d49c33ffc41d58bd17ab032df23ca1a08f017b9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 20 09:18:10 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:25 2014 +0100

cleanup: clvmd drop goto

---
 daemons/clvmd/clvmd.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 05e5670..9af528c 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1167,7 +1167,7 @@ static int cleanup_zombie(struct local_client *thisfd)
 	if (thisfd->bits.localsock.in_progress) {
 		pthread_kill(thisfd->bits.localsock.threadid, SIGUSR2);
 		if (pthread_mutex_trylock(&thisfd->bits.localsock.mutex))
-			goto bail;
+			return 1;
 		thisfd->bits.localsock.state = POST_COMMAND;
 		pthread_cond_signal(&thisfd->bits.localsock.cond);
 		pthread_mutex_unlock(&thisfd->bits.localsock.mutex);
@@ -1228,8 +1228,6 @@ static int cleanup_zombie(struct local_client *thisfd)
 	safe_close(&(thisfd->fd));
 	thisfd->bits.localsock.cleanup_needed = 0;
 	return 0;
-bail:
-	return 1;
 }
 
 /* Called when we have a read from the local socket.


