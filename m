From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:31:31 +0000 (UTC)
Subject: master - clvmd: always set cleanup_needed
Message-ID: <20140321213131.D144060919@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=05a532e1711e9e5e03dc879b790a92fb2a2464c8
Commit:        05a532e1711e9e5e03dc879b790a92fb2a2464c8
Parent:        5bea2b5c8208db7c0277d7bd8672a4db26fbf6d6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 21 11:46:50 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:23 2014 +0100

clvmd: always set cleanup_needed

When thread is created, set the cleanup_needed flag
immediately so it could be used properly any time later
when cleanup_zombie() is needed.
---
 daemons/clvmd/clvmd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 00945da..a3f4354 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1261,7 +1261,6 @@ static int read_from_local_sock(struct local_client *thisfd)
 
 	/* EOF or error on socket */
 	if (len <= 0) {
-		thisfd->bits.localsock.cleanup_needed = 1;
 		cleanup_zombie(thisfd); /* we ignore errors here */
 		return 0;
 	} else {
@@ -1457,6 +1456,7 @@ static int read_from_local_sock(struct local_client *thisfd)
 		/* Run the pre routine */
 		thisfd->bits.localsock.in_progress = TRUE;
 		thisfd->bits.localsock.state = PRE_COMMAND;
+		thisfd->bits.localsock.cleanup_needed = 1;
 		DEBUGLOG("Creating pre&post thread\n");
 		status = pthread_create(&thisfd->bits.localsock.threadid,
 					&stack_attr, pre_and_post_thread, thisfd);


